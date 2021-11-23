/*******************************************************************
@Class Name:SFO_PortfolioManagementCaseHelper
@Sprint :20.09  & P2OB-6272 , 20.12 &  P2OB-8608 && P2OB-7201 && P2OB-9317
@Author:SFO Team (Pallavi B,Sravanthi)
@CreateDate: 09/07/2020
@description: Assigment of Portfolio Code From Case to Account When Portfolio Management Case is created and approved.
@Related Test Class : SFO_PortfolioManagementCaseHelperTest
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*********************************************************************/
public without sharing class SFO_PortfolioManagementCaseHelper {
    private static Case caseRecord;	//to hold the current case record
    private static Map<ID, Account> accRecordsMap = new Map<ID, Account>(); //to load the current case related account and all child accounts
    private static List<Portfolio_Code__c> lstofPortCodeRevtoUpdate = new List<Portfolio_Code__c>(); //to hold the list of portcods to update with revenue target
    private static String newUltimateParentCIDN; //to update current Account's Ultimate_Parent_CIDN__c
    private static Boolean doCIDNsUpdate; //to check whether source account's parent and Ultimate CIDN need to be update or not 
    private static Boolean doCIDNsUpdateSubsidaryToUltimate; //Case Records which are only WorkRequired_PortfolioManagement and RecordType_ChannelCare
    private static Boolean caseEnterpriseToSB; //to check for businessunit Enterprise to Small Business
    private static Boolean caseSBToEnterprise; //to check for businessunit Enterprise to Small Business
    private static String newChurnPropensity;
    private static Boolean checkHierarchy;
    private static Boolean isCaseUpdatePortCode ;
    /*******************************************************************
@Method Name    :   portfolioManagementInvocableMethod
@Sprint         :   20.10  & P2OB-6272 
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   its invoked from process builder and will perform the respective action based on the transfer type
@References     :   Process Builder : CaseOrFeedbackClose& PDUA rights ChatterNotification(CaseOrFeedbackCloseChatterNotification)
                    Node Name : checkForPortFolioCodeChange
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.11  & P2OB-8414, P2OB-8415, P2OB-8416,20.12 &  P2OB-8608 ,20.13 && P2OB-9317 && P2OB-9016 && 20.14 P2OB-6280
*********************************************************************/
    @InvocableMethod
    public static void portfolioManagementInvocableMethod(List<Id> caseId) {
        //public static void portfolioManagementInvocableMethod(List<Id> caseId) {
        //this would runs for single record only otherwise will get a limit issue
        //as dicussed and confirmed with program attachment of confirmation is available on P2OB-6273
        try{
            if(caseId <> null && !caseId.isEmpty()){
                   
            caseRecord = [Select Id,CaseNumber, salesup_Portfolio_Code__c,Churn_Propensity__c,Business_Unit_for_Transfer__c, salesup_Gaining_Portfolio_Code__c, New_Revenue_Target__c, salesup_Work_Required__c, Transfer_Type__c, AccountId, Account.CIDN__c, Account.Parent_CIDN__c, Account.Ultimate_Parent_CIDN__c, New_Parent_Account__c, New_Parent_Account__r.CIDN__c, New_Parent_Account__r.Ultimate_Parent_CIDN__c    from Case where Id =:caseId limit 1];

            caseEnterpriseToSB = (caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Telstra_Enterprise_to_Small_Business && 
                                  caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Accounts );
 			caseSBToEnterprise =  (caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Small_Business_to_Telstra_Enterprise&& 
                                   caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Accounts );
            /*P2OB-9317 For within telstra enterprise Instead of Move Accounts we are using new picklist value Child to Child
            P2OB-9016 : Move Accounts to Insolvency logic added for parent account portfolio code & Target updates
			P2OB-7201 - Excluding Portfolio Updates for SBtoENT 
			P2OB-6280 : Move Accounts out of Insolvency logic added for parent account portfolio code & Target updates  */
            checkHierarchy = ((caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Ultimate_to_Subsidiary ||
                                     caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Subsidiary_to_Ultimate ||
                                     caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Accounts || 
                                     caseRecord.Transfer_Type__c == Label.Case_Request_Type_Value || 
                                     caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Subsidiary_to_subsidiary ||
                                     caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Account_to_Insolvency||
									 caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Account_Out_of_Insolvency) && !(caseSBToEnterprise) );
            Boolean caseAccountcidnCheck = (String.isNotBlank(caseRecord.AccountId) && String.isNotBlank(caseRecord.Account.CIDN__c));
            
            isCaseUpdatePortCode = (caseRecord.Transfer_Type__c == Label.Case_Request_Type_Value &&
                                            caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise);                         
            // Boolean caseAccountcidnCheck = (String.isNotBlank(caseRecord.AccountId) && String.isNotBlank(caseRecord.Account.CIDN__c));
            caseEnterpriseToSB = (caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Telstra_Enterprise_to_Small_Business && 
                                  caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Accounts );
            caseSBToEnterprise =  (caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Small_Business_to_Telstra_Enterprise&& 
                                   caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Move_Accounts );
			if(checkHierarchy && caseAccountcidnCheck) { //if source account & account.CIDN are there 
				//to get the all child accounts related to the current/source account on case 
				List<String> listOfCDINs = new List<String>();
                listOfCDINs.add(caseRecord.Account.CIDN__c);
                
                SFO_AccountPortfolioHierarchy.getAllChildCIDNs(listOfCDINs);
                
                accRecordsMap = SFO_AccountPortfolioHierarchy.accRecordsMap;
                doCIDNsUpdate = ((caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Ultimate_to_Subsidiary  || 
                                  caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Subsidiary_to_subsidiary) && 
                                  String.isNotBlank(caseRecord.New_Parent_Account__c) && 
                                  (caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise));
				
                doCIDNsUpdateSubsidaryToUltimate = (caseRecord.Transfer_Type__c == Label.Case_Transfer_Type_Subsidiary_to_Ultimate && 
                                                    caseRecord.Business_Unit_for_Transfer__c == Label.Case_BusUnit_for_Transfer_Within_Telstra_Enterprise);
                
				setAccountUpdateFields();
                
			}
            if(String.isNotBlank(caseRecord.salesup_Gaining_Portfolio_Code__c)){  //if target portfoliocode is there 
                lstofPortCodeRevtoUpdate=SFO_PortfolioManagementTargetUpdates.setPortfolioCodeRevTargets(caseRecord, caseEnterpriseToSB, caseSBToEnterprise);
            }
            if(!accRecordsMap.isEmpty() || !lstofPortCodeRevtoUpdate.isEmpty()){ // if any data to update is there
				updateRecords(); //to update the list of accounts and the list of portcodes            
			}else {
				System.debug('portfolioManagementInvocableMethod NO DATA TO UPDATE FOR THE CASE ::: ' + caseRecord);
            }
        }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'portfolioManagementInvocableMethod Exception ::: ' +ex.getMessage());
        }
    }
    /*******************************************************************
@Method Name    :   setAccountUpdateFields
@Sprint         :   20.12  & P2OB-7201
@Author         :   SFO Team (Sravanthi)
@CreateDate     :   14/9/2020
@description    :   To set fields of all accounts in heirarchy.
@References     :   portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.13 && P2OB-9317
*********************************************************************/
    private static void setAccountUpdateFields(){
        try{
            //P2OB-10492 - child account updates required for into insolvency.
            Boolean isChildAccUpdateReq=(!accRecordsMap.values().isEmpty());
            if(doCIDNsUpdate && caseRecord.New_Parent_Account__r.Ultimate_Parent_CIDN__c <> null){ //if new account have the 'ultimate parent CIDN' value
                newUltimateParentCIDN = caseRecord.New_Parent_Account__r.Ultimate_Parent_CIDN__c;
            }else if(doCIDNsUpdate){ //if new account is not having 'ultimate parent CIDN' value
                newUltimateParentCIDN = caseRecord.New_Parent_Account__r.CIDN__c;
            }else if(doCIDNsUpdateSubsidaryToUltimate || caseEnterpriseToSB){ //to set current account as ultimate parent account 
                newUltimateParentCIDN = caseRecord.Account.CIDN__c;
            }
            if(caseRecord.Churn_Propensity__c != Label.CasePicklistUnknown){
                newChurnPropensity = caseRecord.Churn_Propensity__c;
            }
            Boolean isAccRecordsMap=!accRecordsMap.values().isEmpty();
            if(isAccRecordsMap){
                setChildAccounts(); //to set the portcode and CIDN values for all the child accounts
            }
            setParentAccount(); //to set the portcode and CIDN values for current account
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'setAccountUpdateFields Exception ::: ' +ex.getMessage());
        }
        
        
    }   

    /*******************************************************************
@Method Name    :   setChildAccounts
@Sprint         :   20.10  & P2OB-6272 
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   To set the child accounts information
@References     :   portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.11  & P2OB-8414, P2OB-8415, P2OB-8416,20.12 &  P2OB-8608
*********************************************************************/
    private static void setChildAccounts(){
        try{
            for(Account act:accRecordsMap.values()){
				if(caseRecord.salesup_Gaining_Portfolio_Code__c <> null){
					act.Portfolio_Code__c = caseRecord.salesup_Gaining_Portfolio_Code__c.toUpperCase();
                    act.Portfolio_Management_Flag__c = True; // to skip the account owner udpate from AccountTriggerHelper
				}
                if(caseEnterpriseToSB && caseRecord.salesup_Gaining_Portfolio_Code__c <> null){
                    act.APTPS_Tier__c = null; 
                }
				if(String.isNotBlank(newUltimateParentCIDN)){
					act.Ultimate_Parent_CIDN__c = newUltimateParentCIDN;
				}
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'setChildAccounts Exception ::: ' +ex.getMessage());
        }
    }
    
    /*******************************************************************
@Method Name    :   setParentAccount
@Sprint         :   20.10  & P2OB-6272
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   To set the parent/current account information
@References     :   portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.11  & P2OB-8414, P2OB-8415, P2OB-8416,20.12 &  P2OB-8608 ,20.13 && P2OB-9317
*********************************************************************/
    private static void setParentAccount(){
        try{
            Boolean doChurnupdate = false;
            //get the current account details
            Account currentAccount = [select Id, Name,Churn_Propensity_New__c,Portfolio_Code__c, CIDN__c, Parent_CIDN__c, Ultimate_Parent_CIDN__c from Account where id=:caseRecord.AccountId];
            if(String.isNotBlank(caseRecord.salesup_Gaining_Portfolio_Code__c)){
				currentAccount.Portfolio_Code__c = caseRecord.salesup_Gaining_Portfolio_Code__c.toUpperCase();
                currentAccount.Portfolio_Management_Flag__c = True; // to skip the account owner udpate from AccountTriggerHelper
            }
            if(String.isNotBlank(caseRecord.salesup_Gaining_Portfolio_Code__c) && caseEnterpriseToSB){
                currentAccount.APTPS_Tier__c = null; 
                currentAccount.Parent_CIDN__c = null;
                currentAccount.Ultimate_Parent_CIDN__c = null;
			}
            if(doCIDNsUpdate){
                currentAccount.Parent_CIDN__c = caseRecord.New_Parent_Account__r.CIDN__c;
                currentAccount.Ultimate_Parent_CIDN__c = newUltimateParentCIDN;
            }
            if(doCIDNsUpdateSubsidaryToUltimate){
                currentAccount.Parent_CIDN__c = null;
                currentAccount.Ultimate_Parent_CIDN__c = null;
            }
            accRecordsMap.put(currentAccount.id, currentAccount);         
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN,'setParentAccount Exception ::: ' +ex.getMessage());
        }
    } 
    /*******************************************************************
@Method Name    :   updateRecords
@Sprint         :   20.10  & P2OB-6272
@Author         :   SFO Team (Pallavi,Sravanthi)
@CreateDate     :   09/07/2020
@description    :   To update the Account and Portfolio_Code__c records
@References     :   portfolioManagementInvocableMethod
@TestCoverage   :   SFO_PortfolioManagementCaseHelperTest
@Updated        :   20.11  & P2OB-8414, P2OB-8415, P2OB-8416,
*********************************************************************/
    private static void updateRecords(){
        // Create a savepoint before to update the accounts and portfolio codes
        Savepoint sp = Database.setSavepoint();
        try{
            // update the list of accounts
            if(!accRecordsMap.isEmpty()){
                Database.SaveResult[] actsSR = Database.update(accRecordsMap.values()); //update accRecordsMap.values();
            }
            
            // update the list of portfolio codes
            if(!lstofPortCodeRevtoUpdate.isEmpty()){
                Database.SaveResult[] portcodesSR = Database.update(lstofPortCodeRevtoUpdate); //update lstofPortCodeRevtoUpdate;
            }
            
        }catch(Exception ex){
            // Rollback to the previous 
            Database.rollback(sp);
            System.debug(LoggingLevel.WARN,'updateRecords Exception ::: ' +ex.getStackTraceString());
        }
    }
}