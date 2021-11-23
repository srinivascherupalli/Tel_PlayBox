/*
 * DEVELOPERS : Anil,Tejes
 * TEAM: Napier
 * DESCRIPTION : This class handles the invocations from OneFund Trigger through Trigger Framework package
 * This class should not have Logic
 * EDGE-113060, EDGE-112655
*/
public class NapierTeamOneFundTriggerHandler extends ATF_AbstractDomainHandler {
	
    List<OneFund__c> oldFunds=trigger.old;
    List<OneFund__c> updatedFunds=trigger.new;
    //Map<ID, SObject> oldRecordsMap=trigger.oldMap;
    //Map<ID, OneFund__c>oldFundsMap=(Map<ID, OneFund__c>)oldRecordsMap;
    Map<ID, SObject> updatedRecordsMap=trigger.newMap;
    Map<ID, SObject> oldRecordsMap=trigger.oldMap;
    Map<ID, OneFund__c>updatedFundsMap=(Map<ID, OneFund__c>)updatedRecordsMap;

    public override void handleBeforeInsert(){
        system.debug('+++++++handlebeforeInsert');
        //EDGE-124394 Method call added by prashant to put validation on CIDN and Billing Account Duplication
        ValidationForCIDNAndBillingAccount.validateCIDN(updatedFunds);
        system.debug('+++updatedFunds'+updatedFunds);
        //Invoking method to calculate StartDate, EndDate according to Contract Duration
        OneFundTriggerHelper.calculateStartDateEndDate(updatedFunds);
    }
    
    public override void handleAfterInsert(){
        //Invoking method to create OneFund Transaction for OneFund Record
      OneFundTriggerHelper.createNewOneFundTransactionRecord(updatedFunds);
    }
    
    public override void handleBeforeUpdate(Map<ID, SObject> oldRecordsMap){
        
        Map<ID, OneFund__c>oldFundsMap=(Map<ID, OneFund__c>)oldRecordsMap;
        //Invoking method to calculate EndDate according to Updated Contract Duration
        OneFundTriggerHelper.calculateEndDate(oldFunds, updatedFunds, oldFundsMap, updatedFundsMap);   
         //EDGE-124394 Method call added by prashant to put validation on CIDN and Billing Account Duplication
       for(OneFund__c updatedFund: updatedFunds){
            oneFund__c old = oldFundsMap.get(updatedFund.id);
            if(old.Billing_Account__c != updatedFund.Billing_Account__c || old.CIDN__c != updatedFund.CIDN__c){
                ValidationForCIDNAndBillingAccount.validateCIDN(updatedFunds);
            }
        }
    }
    
    public override void handleAfterUpdate(Map<ID, SObject> oldRecordsMap){
        
        Map<ID, OneFund__c>oldFundsMap=(Map<ID, OneFund__c>)oldRecordsMap;
        //Invoking method to calculate OneFund Amount for Contract Upgrade/Downgrade in contract variation
		OneFundTriggerContractVariation.calculateOneFundCharge(oldFunds, updatedFunds,oldFundsMap,updatedFundsMap);        
    }
}