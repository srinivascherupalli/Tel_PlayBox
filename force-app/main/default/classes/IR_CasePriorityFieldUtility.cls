public with sharing class IR_CasePriorityFieldUtility {
    public static void setPriority(List<Case> caseRecords){

        Set<String> recordTypeIDS = new Set<String>();
        Boolean recordsFound = false;
        // Get comma separated record type names from custom label
        String recordTypes = System.Label.srvsup_Priority_Automation_Record_Types;
        // Check if label value is blank if yes then return
        if(String.isBlank(recordTypes)) return;
        
        // Add record type IDS in set
        for(String str : recordTypes.split(',')){
            Id  IssueRegisterRecordTypeId = Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get(str.trim()).getRecordTypeId();
            recordTypeIDS.add(IssueRegisterRecordTypeId);
        }
        
        // Check whether list contains atleasr one record of record types mentioned in custom label if not then don;t proceed.
        for(Case c : caseRecords){
            if(recordTypeIDS.contains(c.recordTypeId)) {
                recordsFound = true;
                break;
            }
        }     
        // If recordsFound is false it means not record for the record types mentioned in custom label found. hence return.
        if(recordsFound == false) return;

        map<string, IR_Priority_Automation__mdt> keyValuePair = getPriorityMapping();
        for(Case c : caseRecords){
            String key = c.IR_Issue_Assessment__c+'-'+c.IR_Likelihood_to_Occur__c;
            if(recordTypeIDS.contains(c.recordTypeId) && keyValuePair.containsKey(key)){
                IR_Priority_Automation__mdt xyz = keyValuePair.get(key);
                c.Priority = xyz.IR_Priority__c;
            }
        } 
    }  

    // method to return priority assessment mapping from custom metadata type
    private static map<string, IR_Priority_Automation__mdt>  getPriorityMapping(){
        map<string, IR_Priority_Automation__mdt> keyValuePair = new map<string, IR_Priority_Automation__mdt>();
        for(IR_Priority_Automation__mdt prior : [SELECT IR_Initial_Issue_Assessment__c, IR_Likelihood_to_Occur__c, IR_Priority__c FROM IR_Priority_Automation__mdt limit 1000]){
           string key = prior.IR_Initial_Issue_Assessment__c+'-'+prior.IR_Likelihood_to_Occur__c;
           keyValuePair.put(key, prior);
        }
        return keyValuePair;
    }
}