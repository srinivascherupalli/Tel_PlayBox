/*
 * DEVELOPER : Anil
 * TEAM: Napier
 * DESCRIPTION : This class is not being used. Please refer NapierTeamOneFundTriggerHandler class for Trigger framework.
 * This class should not have Logic
*/
public with sharing class OneFundTriggerHandler{
	
    private OneFundTriggerHelper OneFundTriggerHelperObj = null;
    private static boolean isRunOnceForOffShoreRestrictedUpdate=false;
    private Interface_Activation__c iActivationProcessBuilder = null;
    private EventPublishOnAccount eventPublishOnAccountObj = null;
    public static boolean stopRecursivebeforeupdate = false;
    public OneFundTriggerHandler(){
        OneFundTriggerHelperObj = new OneFundTriggerHelper();
        iActivationProcessBuilder = Interface_Activation__c.getValues(Label.Process_Builder);
        eventPublishOnAccountObj = new EventPublishOnAccount();
    }
    
    //Commentting code as Trigger Framework is implementated and NapierTeamOneFundTriggerHandler class is being used for it.

    /*
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public void onBeforeInsert(List<OneFund__c> newFunds){                
        //Calculating StartDate, EndDate acc to New Contract Duration
        OneFundTriggerHelper.calculateStartDateEndDate(newFunds);
    }
    
    public void onAfterInsert(List<OneFund__c> newFunds){
		OneFundTriggerHelper.createNewOneFundTransactionRecord(newFunds);
    }  
    
    public void onBeforeUpdate(List<OneFund__c> oldFunds, List<OneFund__c> updatedFunds, Map<ID, OneFund__c> oldFundsMap, Map<ID, OneFund__c> updatedFundsMap){        
        OneFundTriggerHelper.calculateEndDate(oldFunds, updatedFunds, oldFundsMap, updatedFundsMap);
    }                                 

    public void onAfterUpdate(List<OneFund__c> oldFunds, List<OneFund__c> updatedFunds, Map<ID, OneFund__c> oldFundsMap, Map<ID, OneFund__c> updatedFundsMap){
        OneFundTriggerContractVariation.calculateOneFundCharge(oldFunds, updatedFunds,oldFundsMap,updatedFundsMap);               
    }
	*/
}