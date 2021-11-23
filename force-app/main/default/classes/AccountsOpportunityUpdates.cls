/*
    EDGE-24836 
    AUTHOR : SFO
    DESCRIPTION : This class handles the invocations from Account Trigger
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*/
public without sharing class AccountsOpportunityUpdates{

   
   //Method to Close opportunities of Inactive Accounts EDGE-24836
    public void updateOpportunitiesForInactiveAccounts( Account[] updatedAccounts, Map<ID, Account> newAccountsMap,Account[] oldAccounts,Map<ID, Account> oldAccountsMap){
        try{  
            
            List<Active_Account_Customer_Status_List__mdt> activCustomerStatusList=[SELECT DeveloperName,id FROM Active_Account_Customer_Status_List__mdt];
            List<String> customerStatusList = new List<String>();
            If(activCustomerStatusList.size() <> null){
                For (Active_Account_Customer_Status_List__mdt status : activCustomerStatusList){
                    customerStatusList.add(status.DeveloperName);
                }
            }
            //Retired Before Update Account list 
            list<Account> oldRetiredAccountList = new list<Account>();
            for(Account updtAcct : oldAccountsMap.values()){
                if(customerStatusList.contains(updtAcct.Customer_Status__c)  ){
                    oldRetiredAccountList.add(updtAcct);
                }
            }
            //Retired After Update Account list 
            list<Account> newRetiredAccountList = new list<Account>();
            for(Account updtAcct : newAccountsMap.values()){
                if(customerStatusList.contains(updtAcct.Customer_Status__c)){
                    newRetiredAccountList.add(updtAcct);
                }
            }
            list<Id> retiredUpdateAccountsIDs = new list<ID>();
            for(Account updtAcct : newRetiredAccountList){
                if(!oldRetiredAccountList.contains(updtAcct)){
                    retiredUpdateAccountsIDs.add(updtAcct.Id);
                }
            }
            if(retiredUpdateAccountsIDs.size()>0){
                //Opportunity list for all the NewInActiveAccount
                //EDGE-68099 Removed Hard Coding
                //Modified condition in below query from OR to AND to solve Production Issue
                List<Opportunity> retiredUpdateAccountOpps =[SELECT id,StageName,Won_Lost_Reason__c,Accountid FROM opportunity WHERE (StageName !=:system.Label.Opp_Stage_ClosedWon  AND StageName !=: Label.Opp_Stage_ClosedLost) AND Accountid IN : retiredUpdateAccountsIDs];
                   if(retiredUpdateAccountOpps.size()>0){
                    //Opportunities which are not in closed won or closed lost
                    list<Opportunity> opptyListActiveList = new list<Opportunity>();
                    for(Opportunity oppty : retiredUpdateAccountOpps){
                        if(!oppty.StageName.equals(Label.Opp_Stage_ClosedWon) && !oppty.StageName.equals(Label.Opp_Stage_ClosedLost)){
                            oppty.StageName=Label.Opp_Stage_ClosedLost;
                            oppty.RetiedAccOpp__c=True;
                            oppty.Won_Lost_Reason__c=Label.Opp_Won_Lost_Reason;
                            opptyListActiveList.add(oppty);
                        }
                    }
                   
                       If(opptyListActiveList.size()>0){
                        update opptyListActiveList;
                    }
                }
            }
        }catch (DmlException ex) {
            system.debug('DmlException-------->AccountTrigger --> AccountTriggerHandler --> AccountsOpportunityUpdates--> Method : UpdateOpportunitiesForInactiveAccounts ----->'+ex); 
        }catch(QueryException ex){
            system.debug('QueryException-------->AccountTrigger --> AccountTriggerHandler --> AccountsOpportunityUpdates--> Method : UpdateOpportunitiesForInactiveAccounts ----->'+ex); 
        }catch(NullPointerException ex){
            system.debug('NullPointerException-------->AccountTrigger --> AccountTriggerHandler --> AccountsOpportunityUpdates--> Method : UpdateOpportunitiesForInactiveAccounts ----->'+ex); 
        }
    }
}