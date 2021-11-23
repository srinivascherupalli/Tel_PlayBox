public without sharing class APTPS_ExportSchedulesController {
    
    public List<APTPS_ScheduleWrapper> schedules {get; set;}
    public id parentAgreementId {get; set;}
    public String retUrl = '';

    //This is constructor for getting the obligations data and export to csv.
    public APTPS_ExportSchedulesController(){  
        parentAgreementId = System.currentPageReference().getParameters().get('Id');   
     
    }
  
    public void generateCSV(){
        
        schedules = new List<APTPS_ScheduleWrapper>();
        List<Apttus__APTS_Agreement__c> agreementSchedules = [select Id, Name, Apttus__FF_Agreement_Number__c, RecordTypeId, Apttus__Status_Category__c, Apttus__Status__c, 
                                                              Apttus__Agreement_Category__c, APTPS_Agreement_Subcategory__c, Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c 
                                                              where Apttus__Parent_Agreement__c =:parentAgreementId];
        
        for(Apttus__APTS_Agreement__c agr : agreementSchedules)
        {
            schedules.add(new APTPS_ScheduleWrapper (agr));
        }
  
    }
  
    @AuraEnabled
    public static  List<APTPS_ScheduleWrapper> generateCSV(Id parentAgreementId){
        
        List<APTPS_ScheduleWrapper> schedules = new List<APTPS_ScheduleWrapper>();
        List<Apttus__APTS_Agreement__c> agreementSchedules = [select Id, Name, Apttus__FF_Agreement_Number__c, RecordTypeId, Apttus__Status_Category__c, Apttus__Status__c, 
                                                              Apttus__Agreement_Category__c, APTPS_Agreement_Subcategory__c, Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c 
                                                              where Apttus__Parent_Agreement__c =:parentAgreementId];
        
        for(Apttus__APTS_Agreement__c agr : agreementSchedules){
            schedules.add(new APTPS_ScheduleWrapper (agr));
        }
      
        return schedules;
        
    }
}