public without sharing class APTPS_ScheduleWrapper {
    
    @AuraEnabled
    public string agreementNumber {get; set;}
    @AuraEnabled
    public string scheduleRecordType {get; set;}
    @AuraEnabled
    public string statusCategory {get; set;}
    @AuraEnabled
    public string agreementstatus {get; set;}
    @AuraEnabled
    public string agreementCategory {get; set;}
    @AuraEnabled
    public string agreementSubCategory {get; set;}
    @AuraEnabled
    public Boolean isInserted {get; set;}
    @AuraEnabled
    public string displayImage {get; set;}
    @AuraEnabled
    public string status {get; set;}
    
    
    public APTPS_ScheduleWrapper(Apttus__APTS_Agreement__c agreement)
    {
        agreementNumber = agreement.Apttus__FF_Agreement_Number__c;
        
        RecordType recordTypeobj = [SELECT Id,Name FROM RecordType WHERE Id =:agreement.RecordTypeId];
        
        scheduleRecordType = recordTypeobj.Name;
        statusCategory = agreement.Apttus__Status_Category__c;
        agreementstatus = agreement.Apttus__Status__c;
        agreementCategory = agreement.Apttus__Agreement_Category__c;
        agreementSubCategory = agreement.APTPS_Agreement_Subcategory__c;
    }
 
}