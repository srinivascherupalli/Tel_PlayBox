/*
@ DEVELOPER : Shishir  
@ TEAM: Istanbul
@ DESCRIPTION : DIGI-6188: This is helper class for BulkUploadSiteDataController, all methods written in this class are called from BulkUploadSiteDataController
@ Test Class: BulkUploadSiteDataControllerTest
******************************************************** CHANGE LOG ********************************************************
1. Omkar Jante         07/Oct/2021     DIGI-28081 : Updated logic for soft delete
2. Nitin Kumar         08/Nov/2021     DIGI-28079 : added insertLogger method
*/
public class BulkUploadSiteDataHelper {
	/**
     *  Method Name :- insertSiteData
     *  Author : Ajith Kumar
     *  Description:- This method is used to insert site Data records into Orchestration Technical Object
     */
    public static Map<String, String> insertSiteData(Boolean isCSVValid, List<String> csvFileLines, Map<string,integer> headerInstanceMapping, Id accountId, Id contentDocumentId){
        Map<String,String> mapOfPropertyToValue = new Map<String, String>();
        List<SiteDataWrapper> siteWrapperList = new List<SiteDataWrapper>();        
        Map<String,Map<String,String>> siteDataMap=new Map<String,Map<String,String>>();
        try{
            for(Integer i = 1; i < csvFileLines.size(); i++) {
                SiteDataWrapper wrapperObject = new SiteDataWrapper();
                String csvDataAfterProcess = removeCommaAndQutoes(csvFileLines[i]);
                List<String> csvRecordData = csvDataAfterProcess.split(',');
                wrapperObject.accountId = accountId;
				wrapperObject.siteName = csvRecordData[headerInstanceMapping.get('SiteName')].replaceAll(':quotes:', '').replaceAll(':comma:', '');
                wrapperObject.adborId = csvRecordData[headerInstanceMapping.get('AdborID')].replaceAll(':quotes:', '').replaceAll(':comma:', '');
                wrapperObject.address = csvRecordData[headerInstanceMapping.get('SiteAddress')].replaceAll(':quotes:', '').replaceAll(':comma:', '');
                wrapperObject.status = Coms_BulkSiteUploadUtils.STATUS_NEW;
                wrapperObject.isDelete = Coms_BulkSiteUploadUtils.IS_DELETE_FALSE; //DIGI-28081
                siteDataMap.put('SiteDataWrapper'+i,new Map<String,String>{'accountId'=>wrapperObject.accountId,'siteName'=>wrapperObject.siteName,'adborId'=>wrapperObject.adborId,'address'=>wrapperObject.address,'status'=>wrapperObject.status, 'isDelete'=>wrapperObject.isDelete});
                siteWrapperList.add(wrapperObject);
            }
            
            if(siteWrapperList.isEmpty() && siteWrapperList==null){
                mapOfPropertyToValue.put('isCSVValid',String.valueOf(isCSVValid));
                mapOfPropertyToValue.put('recordSize','0');                
            }
            else{
                Coms_BulkSiteUploadUtils.insertOrchestrationTechnicals(siteDataMap);
                deleteDocument(contentDocumentId);
                 
                Id BatchProcessId = Database.executebatch(new SearchAddressBatch(accountId,Coms_BulkSiteUploadUtils.insertedLogger,Coms_BulkSiteUploadUtils.submittedTime),Coms_BulkSiteUploadUtils.Batch_Size); //DIGI-28079 moving batch size in static variable
                mapOfPropertyToValue.put('isCSVValid', String.valueOf(isCSVValid));
                mapOfPropertyToValue.put('recordSize', String.valueOf(siteWrapperList.size()));
                mapOfPropertyToValue.put('batchId', BatchProcessId);                
            }
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }    
        return mapOfPropertyToValue;
    }
    
    
    /**
     *  Method Name :- updateOrchestrationTechnicals
     *  Author : Shishir
     *  Description:- This method is used to update OrchestrationTechnical Object
     */
    public static void updateOrchestrationTechnicals(String otRecordId, String selectedAddress){
        List<Orchestration_Technical__c> otRecords = new List<Orchestration_Technical__c>();
        otRecords.add(new Orchestration_Technical__c(Id= otRecordId,Field_5__c = selectedAddress,Field_3__c='Site Created'));
        Coms_BulkSiteUploadUtils.updateOrchestrationTechnicals(otRecords);   
    }
     /**
     *  Method Name :- removeCommaAndQutoes
     *  Author : Shishir
     *  Description:- This method is used to remove extra commas and quotes
     */
    @TestVisible
    private static String removeCommaAndQutoes(String csvLine) {
        Integer startIndex;
        Integer endIndex;
        while(csvLine.indexOf('"') > -1){
            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }
            
            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        return csvLine;
    }
    /**
     *  Method Name :- deleteDocument
     *  Author : Nitin
     *  Description:- This method is called to delete the file attachments after the site created
     */
    public static void deleteDocument(Id contentDocumentId){
        try{
            ContentDocument uploadedFile = [Select Id from ContentDocument where Id =: contentDocumentId];
            if(uploadedFile != null){
                Delete uploadedFile;
            }
        }
        catch(Exception ex){
            GenericUtilityClass.logException('BulkUploadSiteDataController','deleteDocument','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during the file deletion',C2O_ExceptionHandler.Capability.ORD);
        }
    }

    /**
     *  Method Name :- insertLogger
     *  Author : Nitin
     *  Description:- DIGI-28079 This method is called to create application log to calculate the timeframe in uploading sites and first response
     */
    @AuraEnabled
    public static Id insertLogger(String processName,String message, Id accId){
        String correlationid = EDISSingleManager.getUID();
        String SiteuploadHandler ='BulkSiteUploadHandler';
        Logger2 logger = Logger2.getLogger(SiteuploadHandler);
        List<ApplicationLog__c> logList=new List<ApplicationLog__c>();
        ApplicationLog__c logresponse=new ApplicationLog__c(); 
        logresponse = logger.logMessage(processName + '_' + accId,message,false,null,correlationid,SiteuploadHandler);
        if(logresponse!=null)
            logList.add(logresponse);

        if(!logList.isEmpty() && logList.size()>0){
            insert logList;
        }
        if(logresponse!= null)
            return logresponse.Id;
        else 
            return null;    
    }
}