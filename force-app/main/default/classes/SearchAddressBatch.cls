/*
@ DEVELOPER : Ajith Kumar / Nitin Kumar
@ TEAM: Istanbul
@ DESCRIPTION : This class deals with batch insertion of site upload records into Orchestration Technical
@ DIGI-13813, DIGI-28079
@ Test class : SearchAddressBatchTest
*/
global  class SearchAddressBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    public String batchAccountId;
    //DIGI-28079
    public static final String IS_DELETE_FALSE = Coms_BulkSiteUploadUtils.IS_DELETE_FALSE; 
    public static final String STATUS_NEW = Coms_BulkSiteUploadUtils.STATUS_NEW;
    public static final String STATUS_FAILED = Coms_BulkSiteUploadUtils.STATUS_FAILED;
    public Id insertedLogger; 
    public DateTime submittedTime;
    //DIGI-28079

    public SearchAddressBatch(String accountId,Id tempLogger, DateTime fileUploadTime){
        batchAccountId=accountId;
        // DIGI-28079 added to update the application log to calculate the processing time
        insertedLogger = tempLogger;
        submittedTime = fileUploadTime;
    }

   //DIGI-13813 Start method to query Orchestration Technical records with status New or Failed
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;  
        List<string> fields = Coms_BulkSiteUploadUtils.mdtGetDynamicQueryFields('Orchestration_Technical__c');
        string query=' SELECT ' + String.join(fields, ',')
        + ' FROM ' + sobType
        + ' WHERE  External_Id_1__c =:batchAccountId' + ' AND ' + '('+'Field_3__c =:STATUS_NEW' + ' OR Field_3__c =:STATUS_FAILED'+')' + ' AND Field_7__c =:IS_DELETE_FALSE';
        return Database.getQueryLocator(query);
    }

    //DIGI-13813 execute method process to get the address from the API 
    global void execute(Database.BatchableContext BC, List<Orchestration_Technical__c> scopeSiteList) {
        try{
            SearchAddressHandler addressSearch=new SearchAddressHandler();
            addressSearch.searchAddressByAdborId(scopeSiteList);            
        }
        catch(Exception ex){            
            GenericUtilityClass.logException('SearchAddressBatch','execute','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during the batch',C2O_ExceptionHandler.Capability.ORD);
        }
    }

    global void finish(Database.BatchableContext BC){
        
        // DIGI-28079 added to update the application log
        if(String.isNotBlank(insertedLogger)){
            ApplicationLog__c logresponse = new ApplicationLog__c(Id=insertedLogger); 
            Long totalTime =  DateTime.now().getTime()-submittedTime.getTime();
            logresponse.Message__c = 'File processing completed in : ' + String.valueOf(totalTime) + 'ms';
            upsert logresponse;
        }
        // DIGI-28079
         
        
        
    }    
}