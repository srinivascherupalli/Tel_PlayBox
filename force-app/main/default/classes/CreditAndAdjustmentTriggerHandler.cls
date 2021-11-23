/*
 * DEVELOPERS : Vamshi
 * TEAM: Napier
 * DESCRIPTION : This class handles the invocations from CreditAndAdjsutmentTrigger  through Trigger Framework package
 * This class should not have Logic
 * EDGE-135560
 ******************************************************** CHANGE LOG ********************************************************
 * SL.No    Name                Date            Description
 * 1.       Pooja Bhat         20/Jul/2021      EDGE-228125:To rollup Lastest Credit Date Given to the Customer on Parent Case. Added Logic in after event Insert,Update,Delete,Undelete
 * 2.       Shishir Pareek     04/Aug/2021      DIGI-2781: Refactored the code for new trigger handler framework and added filter for records
 */
public class CreditAndAdjustmentTriggerHandler extends SYS_TriggerHandler {
    public final static Id creditRecTypeId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByDeveloperName().get('Retrospective_Redemption_CA').getRecordTypeId();
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Class constructor
    */
    public CreditAndAdjustmentTriggerHandler(String sobjectType) {
        super(sObjectType);
        this.setHandlerName('CreditAndAdjustmentTriggerHandler');// helps improve performance when explicitly set
        this.setMaxLoopCount(2);
    }
    
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for beforeInsert Event and related Helper method calling
    */
    public override void beforeInsert(){
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        Set<Id> setOfCaseIds = new Set<Id>();
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.new) {
            if(cr.Case_Number__c != null && cr.Total_Determination__c != null) {
                listOfRecordsToProcess.add(cr);
                setOfCaseIds.add(cr.Case_Number__c);
            }
        }    
        CreditsAndAdjustmentsTriggerHelper.updateCreditAndAdjustmentAndCallApprovalProcess(listOfRecordsToProcess, setOfCaseIds);
    }

    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for beforeUpdate Event and related Helper method calling
    */
    public override void beforeUpdate() {
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        List<String> listOfFieldsChanged = new List<String>{'Redemption_Status__c'};
        Map<Id,Set<String>> mapOfRecordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,listOfFieldsChanged);
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.new) {
            if(mapOfRecordsWithChanges.get(cr.Id).contains('Redemption_Status__c') 
               && cr.Redemption_Status__c == 'Not Approved' && cr.RecordTypeId == creditRecTypeId){ // replaces Trigger.oldmap.get(acc.id).Industry != Trigger.newMap.get(acc.id).Industry
                
                listOfRecordsToProcess.add(cr); 
            }
        }
        CreditsAndAdjustmentsTriggerHelper.makeCommentsMandatoryAtRejection(listOfRecordsToProcess);
    }

    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for afterInsert Event and related Helper method calling
    */
    public override void afterInsert(){
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        List<Credits_and_Adjustments__c> listOfRecords = new List<Credits_and_Adjustments__c>();
        Set<Id> setOfCaseIds = new Set<Id>();
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.new) {
            if(cr.Case_Number__c != null) {
                listOfRecordsToProcess.add(cr);
            } 
            if(cr.Case_Number__c != null && cr.Total_Determination__c != null) {
                listOfRecords.add(cr);
                setOfCaseIds.add(cr.Case_Number__c);
            }
        }
        CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase(listOfRecordsToProcess);  
          //EDGE-228125: To rollup Lastest Credit Date Given to the Customer on Parent Case
        CreditsAndAdjustmentsTriggerHelper.updateCreditAndAdjustmentAndCallApprovalProcess(listOfRecords, setOfCaseIds);
        CreditsAndAdjustmentsTriggerHelper.updateRelatedCases();
    }
    
    
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for afterUpdate Event and related Helper method calling
    */
    public override void afterUpdate() {
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        List<Credits_and_Adjustments__c> listOfRecords = new List<Credits_and_Adjustments__c>();
        List<String> listOfFieldsChanged = new List<String>{'Date_when_credit_was_given_to_customer__c', 
        'Determination_Status__c','Redemption_Status__c'};
        Set<Id> setOfCaseIds = new Set<Id>();
        List<String> listOfStatus = new List<String>{'Approved','Not Approved','Pending'};
        Map<Id,Set<String>> mapOfRecordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,listOfFieldsChanged);
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.new) {
            if(cr.Case_Number__c != null) {
                if(mapOfRecordsWithChanges.get(cr.Id).contains('Date_when_credit_was_given_to_customer__c') || mapOfRecordsWithChanges.get(cr.Id).contains('Determination_Status__c')) { // replaces Trigger.oldmap.get(acc.id).Industry != Trigger.newMap.get(acc.id).Industry
                    listOfRecordsToProcess.add(cr);
                } 
                if((mapOfRecordsWithChanges.get(cr.Id).contains('Redemption_Status__c') || 
                    mapOfRecordsWithChanges.get(cr.Id).contains('Determination_Status__c')) && 
                    (listOfStatus.contains(cr.Determination_Status__c) || listOfStatus.contains(cr.Redemption_Status__c))) {
                   
                    listOfRecords.add(cr);
                    setOfCaseIds.add(cr.Case_Number__c);
                }    
            }
        }
        CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase(listOfRecordsToProcess);
        CreditsAndAdjustmentsTriggerHelper.updateRelatedCaseRecord(listOfRecords, setOfCaseIds);
        CreditsAndAdjustmentsTriggerHelper.updateRelatedCases();
    }
    
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for afterDelete Event and related Helper method calling
    */
    public override void afterDelete(){
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.old) {
            if(cr.Case_Number__c != null) {
                listOfRecordsToProcess.add(cr);
            }
        } 
        CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase(listOfRecordsToProcess); //EDGE-228125: To rollup Lastest Credit Date Given to the Customer on Parent Case
        CreditsAndAdjustmentsTriggerHelper.updateRelatedCases();
    }
    
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI-2781
    @ Description   :   Override method for afterUndelete Event and related Helper method calling
    */
    public override void afterUndelete(){
        List<Credits_and_Adjustments__c> listOfRecordsToProcess = new List<Credits_and_Adjustments__c>();
        for(Credits_and_Adjustments__c cr : (List<Credits_and_Adjustments__c>)Trigger.new) {
            if(cr.Case_Number__c != null) {
                listOfRecordsToProcess.add(cr);
            }
        } 
        CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase(listOfRecordsToProcess); //EDGE-228125: To rollup Lastest Credit Date Given to the Customer on Parent Case
        CreditsAndAdjustmentsTriggerHelper.updateRelatedCases();
    }
}