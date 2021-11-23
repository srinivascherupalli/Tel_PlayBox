/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class handles the invocations from Account Trigger
*/
/*
 * Modified By : Team Lisbon

 * Date : 22/11/2020
 * Jira : P2OB-9997  
	Description : making changes in After update trigger hander of Account Object. 
				 So that specific field update for this object will trigger CustomerMS event. To Monitor Fields we have 
                 created CustomMetadata.Utility Class check Update against specific Field: FieldUpdateIdentifier

@Last Modified      : 
No.       Developer Name        Date            Story Description 
********************************************************************************
1.		  Sravanthi			07/01/2021	   Sprint 21.01 - P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
2.        Pallavi           13/09/2021     Sprint 21.13 - DIGI-8909  invoking "sendChatterNotesOnPortCodeChange" method from After Update
3.        Sri		        23/09/2021     Sprint 21.13 - DIGI-15107 invoking "updateManualNoSellCreditHealth" method from OnBeforeUpdate

*******************************************************************************/


public without sharing class AccountTriggerHandler{


    private AccountTriggerHelper accountTriggerHelperObj = null;
    private static boolean isRunOnceForOffShoreRestrictedUpdate=false;
    private Interface_Activation__c iActivationProcessBuilder = null;
    private EventPublishOnAccount eventPublishOnAccountObj = null;
    private static boolean stopRecursiveOnBeforeInsert = false;
    private static boolean stopRecursiveOnBeforeUpdate = false;
    private static boolean stopRecursiveOnAfterInsert = false;
    private static boolean stopRecursiveOnAfterUpdate = false;
    public AccountTriggerHandler(){
        accountTriggerHelperObj = new AccountTriggerHelper();
        iActivationProcessBuilder = Interface_Activation__c.getValues(Label.Process_Builder); //EDGE-68099 Removed Hard Coding
        eventPublishOnAccountObj = new EventPublishOnAccount();
    }

    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    public void OnBeforeInsert(Account[] newAccounts){
        

        if(!stopRecursiveOnBeforeInsert){
            AccountLegacyOwnerShipCodeDAO accLOSC = new AccountLegacyOwnerShipCodeDAO();
            AccountTriggerHelper.updateAccountOwner(null,newAccounts,null);
            //Added below Method(UpdatePrimaryAddress) AS PART OF SFO Sprint 20.05[P2OB-5483] in before insert method to populate primary Account Address to Billing Address
            AccountTriggerHelper.updatePrimaryAddress(newAccounts,null,null);
            MaintainAccountCIDNRelationship.createCIDNRelationships(newAccounts);
            accLOSC.updateLegacyOwnerShipCode(newAccounts);
        }
        stopRecursiveOnBeforeInsert=True;
        if(iActivationProcessBuilder!=null && iActivationProcessBuilder.Status__c){
            //EDGE-27948: calling "markAccountAsVerified", and "updateAccountBusinessUnit" Methods
            accountTriggerHelperObj.markAccountAsVerified(newAccounts);
            accountTriggerHelperObj.updateAccountBusinessUnit(newAccounts);
        }   
    }

    public void OnAfterInsert(Account[] newAccounts){
    AccountTriggerHelper.createNewAccountAddressRelationship(newAccounts);
        if(!stopRecursiveOnAfterInsert){  // Nirvana Production Fix Case Number : 00018544
            
            if(!system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled()){
                TCMCustomerHandlerQueueable.onAfterInsert(newAccounts);
            }

            if(!EnvironmentalSettings.isSeedingEnabled()){
                AccountTriggerHelper.runTerritoryAssignmentRule(null,newAccounts,null);
            }
            accountTriggerHelperObj.publishCreateEvents(newAccounts,EventConstants.CREATE_OPERATION);
            eventPublishOnAccountObj.eventPublishOnAccCreation(newAccounts);
        }
        stopRecursiveOnAfterInsert = true;
    }

    public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){

        if(iActivationProcessBuilder!=null && iActivationProcessBuilder.Status__c){
            //EDGE-27948: calling "updateAccountLastVerifiedDate" Methods
            accountTriggerHelperObj.updateAccountLastVerifiedDate(updatedAccounts, newAccountsMap, oldAccountsMap);
        }
        if(!stopRecursiveOnBeforeUpdate){
            AccountROUDAO accROUDAO = new AccountROUDAO();
            AccountsOpportunityUpdates accOppUp = new AccountsOpportunityUpdates();
            AccountLegacyOwnerShipCodeDAO accLOSC = new AccountLegacyOwnerShipCodeDAO();
            
            if(!system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled()){
                TCMCustomerHandlerQueueable.OnBeforeUpdate(oldAccountsMap,newAccountsMap);
            }
            AccountTriggerHelper.updateAccountOwner(oldAccounts,updatedAccounts,newAccountsMap);
            //As part of SFO Sprint 20.13 DIGI-15107
            AccountTriggerHelper.updateManualNoSellCreditHealth(oldAccountsMap,updatedAccounts);
            //Added below Method(UpdatePrimaryAddress) AS PART OF SFO Sprint 20.05[P2OB-5483] in before insert method to populate primary Account Address to Billing Address
            AccountTriggerHelper.updatePrimaryAddress(updatedAccounts,oldAccountsMap,newAccountsMap);
            if(!EnvironmentalSettings.isSeedingEnabled()){
                AccountTriggerHelper.runTerritoryAssignmentRule(oldAccounts,updatedAccounts,newAccountsMap);
            }

            accROUDAO.updateAccountROU(oldAccountsMap,newAccountsMap);
            accLOSC.updateLegacyOwnerShipCode(updatedAccounts);
            if(AccountTriggerHelper.isLOCROUCalculationRequired()){
                AccountLOCROUCalculation.calculateLOC(oldAccountsMap,updatedAccounts);
            }
            accOppUp.updateOpportunitiesForInactiveAccounts(updatedAccounts,newAccountsMap,oldAccounts,oldAccountsMap);
        }
        MaintainAccountCIDNRelationship.createCIDNRelationshipsWrapper(oldAccounts, newAccountsMap);
        stopRecursiveOnBeforeUpdate=true;
    }

    public void OnAfterUpdate(Account[] oldAccounts, Map<ID, Account> oldAccountMap,
                              Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        
        AccountTriggerHelper.updateAccountAddressRelationship(oldAccounts,oldAccountMap,updatedAccounts,updateAccountsMap);
         //Added as part of Sprint 21.13 .Starts here                         
        if(FeatureEligibilityChecker.determineFeatureEligiblity('AccountNotificationProcessing', 'PortfolioChangeNotifications')){                          
        AccountTriggerHelper.sendChatterNotesOnPortCodeChange(oldAccountMap,updatedAccounts); 
        } //Ends Here
                                  
        //P2OB-9997 :CustomerMS event based on specific account Field Update
		            FieldUpdateIdentifier fui = new FieldUpdateIdentifier(Account.SobjectType,Label.CustomerMS_Integration);
                    Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(updateAccountsMap,oldAccountMap);
                    if(!matches.isEmpty()){
						accountTriggerHelperObj.publishCreateEvents(matches.values(),EventConstants.UPDATE_OPERATION);
                    }
                                  
        List<Account> updateAgreementOffshoreflag = new List<Account>();
        if(iActivationProcessBuilder != null && iActivationProcessBuilder.Status__c){
            //EDGE-32392: replacing process builder (Account Tier Update) with trigger to update 'Account Tier Field' and 'Offshore Restricted' on Agreement
            //start
            for(Account newAccount: updatedAccounts){
             if(newAccount.APTPS_Off_Shore_Restricted__c != oldAccountMap.get(newAccount.Id).APTPS_Off_Shore_Restricted__c
             || newAccount.APTPS_Tier__c != oldAccountMap.get(newAccount.Id).APTPS_Tier__c){
             updateAgreementOffshoreflag.add(newAccount);
            }
        }
        if(!updateAgreementOffshoreflag.isEmpty()){
         accountTriggerHelperObj.updateAgreement(updateAgreementOffshoreflag);
       }
         
        isRunOnceForOffShoreRestrictedUpdate=true;
        }
        //end

        eventPublishOnAccountObj.eventPublishOnAccChange(oldAccounts,oldAccountMap,updatedAccounts,updateAccountsMap);
                                     
                                    }
    public void OnAfterDelete(Account[] deletedAccounts, Map<ID, Account> accountsMap){
        System.debug('OnAfterDelete old: ' + accountsMap);
    }

    //EDGE-38 : calling field update method from helper for manage invocation
    public static void identifyFieldUpdates(Map<Id,Account> newMap,Map<Id,Account> oldMap){
        System.debug('AccountTriggerHandler - identifyFieldUpdates');
        //EDGE-68099 Removed Hard Coding
        Interface_Activation__c iActivation = Interface_Activation__c.getValues(Label.Manage_Customer);
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        Map<id, Sobject> matches = null;
        if(iActivation!=null && iSettings!=null && iActivation.Status__c && System.UserInfo.getUserName() != iSettings.Integration_API_User__c){
            matches= AccountTriggerHelper.fieldupdateidentifier(newMap,oldMap);
        }
        if(matches != null && !matches.isEmpty()){
            System.debug('AccountTriggerHandler - identifyFieldUpdates, tcm field updated manage will be triggered');
            AccountTriggerHandler.ManageCustomer();
        }
    }

    public static void manageCustomer() {
        System.debug('!@#$% AccountTriggerHandler.ManagerCustomer() is invoked');

        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues(Label.Manage_Customer); //EDGE-68099 Removed Hard Coding

        List<Account> accounts = Trigger.new;
        Map<Id,SObject> oldAccountMap = Trigger.oldMap;

        for(Account a : accounts) {
            String event;
            if(a.Customer_ID__c != null && String.isNotBlank(a.Customer_ID__c) && !EnvironmentalSettings.isSeedingEnabled()) {
                if((Trigger.isInsert) && (System.UserInfo.getUserName() == iSettings.Integration_API_User__c || a.Imported__c)){
                    System.debug('!@#$% Trigger detected as insert');
                    System.debug('!@#$% Setting event to crossref as insert done by API user');
                    event = ManageCustomerHandler.EVENT_ACTION_CROSSREF;
                    TestRun.Uirun = false;
                } else if(Trigger.isUpdate){
                    System.debug('!@#$% Trigger detected as update');
                    String oldCustomerId = String.valueOf(oldAccountMap.get(a.Id).get(Schema.Account.Customer_ID__c));
                    if(a.Customer_ID__c != oldCustomerId) {
                        if(!a.Imported__c && iActivation.Status__c){
                            System.debug(iActivation);
                            System.debug('!@#$% Customer ID is changed. Setting event to Create');
                            event = ManageCustomerHandler.EVENT_ACTION_CREATE;
                        } else if(a.Imported__c) {
                            System.debug('!@#$% Customer ID is changed. Setting event to Create');
                            event = ManageCustomerHandler.EVENT_ACTION_CROSSREF;
                        }
                    } else {
                        if(System.UserInfo.getUserName() != iSettings.Integration_API_User__c && iActivation.Status__c){
                            System.debug('!@#$% Record is NOT updated by API user. Setting event to Update');
                            event = ManageCustomerHandler.EVENT_ACTION_UPDATE;
                        }
                        if(TestRun.Uirun == false){
                            event = ManageCustomerHandler.EVENT_ACTION_UPDATE;
                            TestRun.Uirun = true;
                        }
                    }
                }

                //Overriding Event Action temporarily
                if(a.Send_Create_Event__c){
                    System.debug('!@#$% Overriding event type !!!!! ');
                    event = ManageCustomerHandler.EVENT_ACTION_CREATE;
                }

                System.debug('!@#$% Event is calculated as : ' + event);
                system.debug('****Customer Seeding Field value in the Trigger:'+EnvironmentalSettings.isSeedingEnabled());
                //Prepare request
                if(event != null && String.isNotBlank(event) && !Test.isRunningTest()){
                    if(system.isBatch() && !EnvironmentalSettings.isSeedingEnabled()){
                        triggerManageCustomerHandler(event,a);
                    } else if(!system.isBatch()){
                        triggerManageCustomerHandler(event,a);
                    }
                }
            }
        }
    }

    public static void triggerManageCustomerHandler(String event, Account a){
        System.debug('!@#$% Invoking ManageCustomer with ' + event + ' event');
        String mcReq = '';
        String mcReqUpdateQueueable = '';
        if(event == ManageCustomerHandler.EVENT_ACTION_CROSSREF){
            // Prepare request for cross reference
            mcReq = ManageCustomerHandler.generateManageCustomerRequest(a, event);
            if(system.isQueueable()) {
                mcReqUpdateQueueable = ManageCustomerHandler.generateManageCustomerRequest(a, ManageCustomerHandler.EVENT_ACTION_UPDATE);
            }
        } else {
            // Prepare request
            mcReq = ManageCustomerHandler.generateManageCustomerRequest(a, event);
        }

        
        if(!system.isFuture() && !system.isBatch()){
            if(system.isQueueable()){
                ManageCustomerHandler.sendManageCustomer(mcReq, event, a.Customer_ID__c);
                ManageCustomerHandler.sendManageCustomer(mcReqUpdateQueueable, ManageCustomerHandler.EVENT_ACTION_UPDATE, a.Customer_ID__c);
            } else {
                ManageCustomerHandler.sendManageCustomer(mcReq, event, a.Customer_ID__c);
            }
        }
        System.debug('!@#$% ManageCustomer request sent to TCM | Account ID : ' + a.Id);
        System.debug('!@#$% ManageCustomer request sent to TCM | Account UUID : ' + a.Account_UUID__c);
    }

    /*EDGE-85839
    Created By: Sasidhar Devarapalli
    Description: Invoking this method from SyncUpWithTCM batch class
    */
    public static void manageCustomerHandlerSync(String event, Account acc){
        triggerManageCustomerHandler('EVENT_ACTION_UPDATE', acc);
    }

   
     //added temporarily for checking the 101 soql error
    public static void UpdateAccreditationStatus(Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){ 
        
        Map<String, PRM_Partner_License_Limit__mdt> mpPartnerLicense = new Map<String, PRM_Partner_License_Limit__mdt>();
        //see if the query can be moved
        for(PRM_Partner_License_Limit__mdt objPRMRank : [SELECT Accreditation_Level__c,Rank__c,License_Limit__c FROM PRM_Partner_License_Limit__mdt])
            mpPartnerLicense.put(objPRMRank.Accreditation_Level__c,objPRMRank);
          Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        for(Account objAcc:newAccountsMap.values()){
            if(oldAccountsMap!=null && oldAccountsMap.get(objAcc.id)!=null && objAcc.RecordTypeId == partnerAccRecID)
            {
                if(mpPartnerLicense.ContainsKey(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c) && mpPartnerLicense.ContainsKey(objAcc.Overall_Accreditation__c))
                {           
                    If(mpPartnerLicense.get(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c).Rank__c < mpPartnerLicense.get(objAcc.Overall_Accreditation__c).Rank__c)
                    {
                        objAcc.Old_OverallAccreditation_Status__c=oldAccountsMap.get(objAcc.id).Overall_Accreditation__c;
                        objAcc.Accreditation_Status__c=objAcc.Accreditation_Status__c=='Relegated'?'Relegated Again':objAcc.Accreditation_Status__c=='Relegated Again'?'Relegated':'Relegated';
                        objAcc.Old_PRM_License_Limit__c=oldAccountsMap.get(objAcc.id).PRM_License_Limit__c;
                        objAcc.Deactivation_Date__c= DateTime.Now().AddDays(28);
                        
                    }
                    else if(mpPartnerLicense.get(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c).Rank__c > mpPartnerLicense.get(objAcc.Overall_Accreditation__c).Rank__c){
                        objAcc.Old_OverallAccreditation_Status__c=oldAccountsMap.get(objAcc.id).Overall_Accreditation__c;
                        objAcc.Old_PRM_License_Limit__c=oldAccountsMap.get(objAcc.id).PRM_License_Limit__c;
                        objAcc.Accreditation_Status__c='Promoted';
                        
                    }   
                }
            }
        }
    }    
}