/**
 * Created by Chandrakanth_B02 on 12/09/2019.
 * P2OB-6753 - Hawaii - 05/06/2020 - commenting the method populatePRMLicenseonAccount calling 
 */

public with sharing class AccountTriggerHandlerPRM {

    private List<Account> prmAccounts = null;
    private static boolean stopRecursivebeforeupdate = false;
    private AccountTriggerHelper accountTriggerHelperObj = null;
    private EventPublishOnAccount eventPublishOnAccountObj = null;
    private Interface_Activation__c iActivationProcessBuilder = null;
    private static final Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();

    public AccountTriggerHandlerPRM(List<Account> newAccounts){
        this.prmAccounts = new List<Account>();
        accountTriggerHelperObj = new AccountTriggerHelper();
        eventPublishOnAccountObj = new EventPublishOnAccount();
        this.iActivationProcessBuilder = Interface_Activation__c.getValues(Label.Process_Builder); //EDGE-68099 Removed Hard Coding

        if(newAccounts != NULL){


        for(Account account : newAccounts){
            if(account.RecordTypeId != null && account.RecordTypeId == partnerRecordID){
                prmAccounts.add(account);
            }
          }
        }

    }



    public Boolean hasPRMAccounts(){
        return (!this.prmAccounts.isEmpty());
    }

    public void OnBeforeInsert(Account[] newAccounts){
        AccountTriggerHelperPRM.updateDistributorName(null,this.prmAccounts,null); //added by saran
    }

    public void OnAfterInsert(Account[] newAccounts){
        if(!stopRecursivebeforeupdate){
            if(iActivationProcessBuilder != null && iActivationProcessBuilder.Status__c){
                AccountTriggerHelperPRM.createTOSAApplication(this.prmAccounts,null); //added by saran
            }
            //P2OB-6753 - Hawaii - 05/06/2020 - commenting the method calling
            //AccountTriggerHelperPRM.populatePRMLicenseonAccount(null,null,this.prmAccounts,null);//added by uday on Aug 29th 2018
            accountTriggerHelperObj.publishCreateEvents(this.prmAccounts,EventConstants.CREATE_OPERATION);
            eventPublishOnAccountObj.eventPublishOnAccCreation(this.prmAccounts);
        }
        stopRecursivebeforeupdate = true;
    }

    public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){
        if(iActivationProcessBuilder != null && iActivationProcessBuilder.Status__c){
            AccountTriggerHelperPRM.updateDistributorName(oldAccounts,this.prmAccounts,newAccountsMap);//added by saran
            AccountTriggerHelperPRM.deactivateReactivateOrg(oldAccounts,this.prmAccounts,oldAccountsMap,newAccountsMap);//added by saran
            //P2OB-6753 - Hawaii - 05/06/2020 - commenting the method calling
            //AccountTriggerHelperPRM.populatePRMLicenseonAccount(oldAccounts,oldAccountsMap,this.prmAccounts,newAccountsMap);// added by uday on Aug29th 2018
            AccountTriggerHelperPRM.updateAccreditationStatus(oldAccountsMap, newAccountsMap);
        }
    }

    //Make sure if you can runOnce for after update.
    public void OnAfterUpdate(Account[] oldAccounts, Map<ID, Account> oldAccountMap, Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        accountTriggerHelperObj.publishCreateEvents(this.prmAccounts,EventConstants.UPDATE_OPERATION);//EDGE-150897 moved out of if block
        eventPublishOnAccountObj.eventPublishOnAccChange(oldAccounts,oldAccountMap,this.prmAccounts,updateAccountsMap);//EDGE-150897 moved out of if block      
        if(iActivationProcessBuilder != null && iActivationProcessBuilder.Status__c){
            AccountTriggerHelperPRM.createTOSAApplication(this.prmAccounts,oldAccountMap);//added by Saran
            AccountTriggerHelperPRM.updateContactOnboardingStatus(oldAccounts,oldAccountMap,this.prmAccounts,updateAccountsMap); //added by Ramya on 11-04
            AccountTriggerHelperPRM.toUpdateUsersToSuperUsers(oldAccounts, oldAccountMap, this.prmAccounts, updateAccountsMap);//added by uday on 24-09-2018
            AccountTriggerHelperPRM.updateApplicationChecks(oldAccounts, oldAccountMap, this.prmAccounts, updateAccountsMap);//added by uday on 16-07-2018
        }
    }

}