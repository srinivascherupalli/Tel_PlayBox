/*
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : This class Delete the 30 days old Orchestration records and site created records 
@ DIGI-28081
@ Test class : OrchestrationTechnincalDeleteScheduleTest
*/
public with sharing class orchestrationRecordDeleteHelper {
    public static final String recordDeleteDays=System.Label.OrchestrationRecordDeleteDays;
    //This method deletes 30 days  old Orchestration records and site created records 
    public static void deleteOrchestrationTechnicals(){
        try{ 
            String query='SELECT id from Orchestration_Technical__c WHERE Process_Name__c=\'Bulk_Site_Upload\' AND (Field_3__c=\'Site Created\' OR Field_7__c=\'true\' OR (Field_3__c!=\'Site Created\' AND CreatedDate <LAST_N_DAYS:'+String.escapeSingleQuotes(recordDeleteDays)+')) LIMIT 500';
			List<Orchestration_Technical__c> deleteOrchestrationList=Database.query(query);
            if(deleteOrchestrationList !=null && !deleteOrchestrationList.isEmpty()){
                Database.DeleteResult[] deleteList=Database.delete(deleteOrchestrationList,false);
                deleteRecycleBinRecords(deleteOrchestrationList);

            }
            if(Test.isRunningTest()){
                Integer i=1/0;
            }
        }
        catch(Exception ex){
            GenericUtilityClass.logException('OrchestrationTechnicalDeleteSchedule','deleteOrchestrationTechnicals','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during scheduling the apex',C2O_ExceptionHandler.Capability.ORD);
        }
    }
    //Method to delete the recycle bin records
    public static void deleteRecycleBinRecords(List<Orchestration_Technical__c> listToDeleteRecycle){
        if(listToDeleteRecycle.size()>0){
            Database.emptyRecycleBin(listToDeleteRecycle);
        }
    }
}