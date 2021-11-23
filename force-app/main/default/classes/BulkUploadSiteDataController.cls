/*
@ DEVELOPER : Shishir 
@ TEAM: Istanbul
@ DESCRIPTION : This class deals with the Bulk CSV upload
@ DIGI-6188
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Shishir Pareek/Nitin Kumar      27/Aug/2021     DIGI- 6188 : Created class for processing bulk CSV upload
 * 2.       Ajith Kumar         22/Sep/2021     DIGI-10971 : created methods for Bulk Site Upload save into Orchestration Technical Object
 * 3.       Omkar Jante         07/Oct/2021     DIGI-28081 : Updated logic for soft delete
 * 4.       Nitin Kumar         08/Nov/2021     DIGI-28079 : added logger and final variables
 */
public without sharing class BulkUploadSiteDataController {

    private static final string className='SearchAddressBatch';
    public static final Set<String> setOfColumns = new Set<String>{'SiteName','AdborID','SiteAddress'}; 
    
    /**
     *  Method Name :- parseCSVandUpload
     *  Author : Shishir
     *  Description:- This method will take uploaded document Id and parse it for siteDataTable Component
     *                 to show and review csv rows
     */
    @AuraEnabled(Cacheable=false)
    public static Map<String,String> parseCSVandUpload(Id contentDocumentId, Id accountId) {
        //DIGI-28079
        
        
             
        try{  
            
            Map<String,String> mapOfPropertyToValue = new Map<String, String>();
            ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId, VersionData 
                                                        FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId
                                                        AND IsLatest =:true];
            String csvContents = EncodingUtil.base64Encode(contentVersionObj.VersionData);
            String csvLines = EncodingUtil.urlDecode(csvContents,'UTF-8');
            String csvBody = EncodingUtil.base64Decode(csvLines).toString();
            
            List<String> csvFileLines = csvBody.split('\n');
            Map<string,integer> headerInstanceMapping = new Map<String,Integer>();
            Integer index = 0;
            Boolean isCSVValid = true;
            if(!csvFileLines.isEmpty()) {
                for(String headerName: csvFileLines[0].split(',')){
                    if(setOfColumns.contains(headerName.replaceAll('\\s+', ''))) {
                        headerInstanceMapping.put(headerName.replaceAll('\\s+', ''),index);
                        index++;
                    } else {
                        isCSVValid = false;
                        break;
                    }
                }
            }

            if(isCSVValid && (setOfColumns.size() != headerInstanceMapping.keySet().size())) {
                isCSVValid = false;
                
            }
            if(isCSVValid) {
                // Capturing file uploading time
                Coms_BulkSiteUploadUtils.submittedTime = System.now(); 

                //DIGI-28079 inserting logs
                Coms_BulkSiteUploadUtils.insertedLogger = BulkUploadSiteDataHelper.insertLogger(Coms_BulkSiteUploadUtils.PROCESS_NAME,'File uploaded',accountId);
                mapOfPropertyToValue = BulkUploadSiteDataHelper.insertSiteData(isCSVValid,csvFileLines,headerInstanceMapping,accountId,contentDocumentId);
            }
            else{
                mapOfPropertyToValue.put('isCSVValid',String.valueOf(isCSVValid));
            }
            return mapOfPropertyToValue;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
        
    }

    

    /**
     *  Method Name :- deleteDocument
     *  Author : Nitin
     *  Description:- This method is called to delete the file attachments after the site created
     */
    @AuraEnabled
    public static void deleteDocument(Id contentDocumentId){
        BulkUploadSiteDataHelper.deleteDocument(contentDocumentId);
    }

    /**
     *  Method Name :- getProcessedRecords
     *  Author : Nitin
     *  Description:- This method is called when user clicks on Review or next button
     */
    @AuraEnabled
    public static Map<String, String> getProcessedRecords(Id accountId, Integer offset, Integer pageSize, Boolean firstTime){
        try{
            Map<String,String> mapOfPropertyToValue = new Map<String, String>();
            List<Orchestration_Technical__c> fetchedRecords;
            List<SiteDataWrapper> siteWrapperList = new List<SiteDataWrapper>();
            List<SiteDataWrapper.newAddresses> PicklistEntry = new List<SiteDataWrapper.newAddresses>();
            fetchedRecords= Coms_BulkSiteUploadUtils.getAllOrchestrationTechnicalRecords(accountId,new List<String>{Coms_BulkSiteUploadUtils.STATUS_FOUND,Coms_BulkSiteUploadUtils.STATUS_NOT_FOUND,Coms_BulkSiteUploadUtils.STATUS_FAILED },null,pageSize,offset);
            if((firstTime && fetchedRecords.size() >= pageSize) || (!firstTime && fetchedRecords.size() >= 0 )){
                for(Orchestration_Technical__c ot : fetchedRecords){ 
                    SiteDataWrapper wrapperObject = new SiteDataWrapper();
                    PicklistEntry = new List<SiteDataWrapper.newAddresses>();
                    if(String.isNotBlank(ot.Field_6__c) && ot.Field_6__c.equalsIgnoreCase('AdborId')){
                        List<AddressSummary> addsList;
                        if(ot.BackupJson__c!=null){
                            addsList = (List<AddressSummary>)JSON.deserialize(ot.BackupJson__c, List<AddressSummary>.class);
                        }
                        if(addsList!=null && !addsList.isEmpty()){
                            //Added addressList for fixing defect of showing address. Only added in label as we do not want to store the value
                            string addressList = (String.isBlank(addsList[0].addressId))?addsList[0].addressLine :(addsList[0].addressLine +'-'+ addsList[0].addressId);
                            wrapperObject.selectedAddress = String.isNotBlank(ot.Field_5__c)? addressList : '' ;
                            PicklistEntry.add(new SiteDataWrapper.newAddresses(addressList,addressList));
                        }
                    }
                    else{
                        if(String.isNotBlank(ot.Field_6__c) && ot.Field_6__c.equalsIgnoreCase('Address')){
                            AddressResponseDTO addsList ;
                            if(ot.BackupJson__c!=null && ot.BackupJson__c != ''){
                                wrapperObject.selectedAddress = String.isNotBlank(ot.Field_5__c)? ot.Field_5__c : '' ;
                                addsList = (AddressResponseDTO)JSON.deserialize(ot.BackupJson__c, AddressResponseDTO.class);
                            }
                            
                            if(!addsList.results.isEmpty())
                            for( AddressResponseDTO.results res : addsList.results){
                                PicklistEntry.add(new SiteDataWrapper.newAddresses(res.name,res.name));
                            }
                        }
                    }
                    
                    
                    wrapperObject.corelationId = ot.CorrelationId__c;
                    wrapperObject.siteName = ot.Field_1__c;
                    wrapperObject.adborId = ot.Field_4__c;
                    wrapperObject.address = ot.Field_2__c;
                    wrapperObject.status = ot.Field_3__c; 
                    wrapperObject.newAddresses = PicklistEntry;
                    siteWrapperList.add(wrapperObject);
                }
                mapOfPropertyToValue.put('SiteDataWrapper',JSON.serialize(siteWrapperList));
            }
            else{
                mapOfPropertyToValue.put('SiteDataWrapper',Coms_BulkSiteUploadUtils.STR_FALSE);
            }
            return mapOfPropertyToValue;  
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }        
         
    }

    

/**
     *  Method Name :- getSitesCount
     *  Author : Nitin
     *  Description:- This method is used to get the template,so that user can download it and prepare csv file for bulk site
     *  Modified : Ajith Kumar	
     *  Description:- Removed Cacheable equals true 	
     */	
    @AuraEnabled
    public static Map<String, Integer> getSitesCount(String accountId){
        List<Orchestration_Technical__c> templateRecordList = new List<Orchestration_Technical__c>();
       try {           
            Map<String, Integer> cachedData = New Map<String, Integer>();
            List<AggregateResult> listOfAggregateResult = new List<AggregateResult>();
            listOfAggregateResult = Coms_BulkSiteUploadUtils.getCountQueryResult(accountId,new List<String>{Coms_BulkSiteUploadUtils.STATUS_FOUND,Coms_BulkSiteUploadUtils.STATUS_NOT_FOUND,Coms_BulkSiteUploadUtils.STATUS_FAILED},null);//DIGI-28081 Removed the query string and moved to utils class
            if(listOfAggregateResult != null && !listOfAggregateResult.isEmpty()){
                cachedData.put('totalCount',(Integer)listOfAggregateResult[0].get('cnt'));
            }
            else{
                cachedData.put('totalCount',0);
            }
            return cachedData;

        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    }
    
    /**
     *  Method Name :- manualBatchCall
     *  Author : Ajith Kumar
     *  Description:- This method is called on Re-validate Address 
     */
    @AuraEnabled
    public static Map<String, String> manualBatchCall(Id accountId, String batchProcessId){
        
        List<Orchestration_Technical__c> otRecords = new List<Orchestration_Technical__c>();
        Map<String, String> successMap = new Map<String, String>();
        try {

            Boolean initiateBatch = true;   

            if(String.isNotBlank(batchProcessId)){
                List<AsyncApexJob> currentJobs = new List<AsyncApexJob>([SELECT Id, Status FROM AsyncApexJob WHERE Id =:batchProcessId AND (Status=:Coms_BulkSiteUploadUtils.STATUS_COMPLETED OR Status=:Coms_BulkSiteUploadUtils.STATUS_ABORTED) ORDER BY CreatedDate DESC ]);
                if (currentJobs !=null && !currentJobs.isEmpty()) {
                    otRecords = Coms_BulkSiteUploadUtils.getAllOrchestrationTechnicalRecords(accountId,new List<String>{Coms_BulkSiteUploadUtils.STATUS_NOT_FOUND,Coms_BulkSiteUploadUtils.STATUS_FAILED,Coms_BulkSiteUploadUtils.STATUS_NEW},null,0,0);
                    if(otRecords == null || otRecords.isEmpty()){
                        initiateBatch = false;
                    }                        
                }
                else{
                    initiateBatch = false;
                }
            }
            if(initiateBatch){
                for(Orchestration_Technical__c orchestrationTechObj : otRecords){
                    orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_NEW;
                }
                if(otRecords!= null && otRecords.isEmpty())
                    update otRecords;

                //DIGI-28079 inserting application log
                Coms_BulkSiteUploadUtils.submittedTime = System.now(); // added to get the file submission
                Coms_BulkSiteUploadUtils.insertedLogger = BulkUploadSiteDataHelper.insertLogger(Coms_BulkSiteUploadUtils.PROCESS_NAME,'Revalidation started',accountId);
                
                Id newBatchProcessId = Database.executebatch(new SearchAddressBatch(accountId,Coms_BulkSiteUploadUtils.insertedLogger,Coms_BulkSiteUploadUtils.submittedTime),Coms_BulkSiteUploadUtils.Batch_Size); //DIGI-28079 moving batch size in static variable
                if (String.isNotBlank(newBatchProcessId)) {
                    successMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_TRUE);
                    successMap.put('batchId',newBatchProcessId);
                }
            }
            else {
                successMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_FALSE);
                successMap.put('batchSubmitted',Coms_BulkSiteUploadUtils.STR_FALSE);
                successMap.put('batchId',batchProcessId);
            }            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    return successMap;
    }


    /**
     *  Method Name :- addSiteRecord
     *  Author : Ajith Kumar
     *  Description:- This method is to addSiteRecord to account 
     */
    @AuraEnabled
    public static Map<String,String> addSiteRecord(String corelationId, String accRecordId, String selectedAddress){
        try {
            Map<String,String> resultMap = new Map<String, String>();
            List<Orchestration_Technical__c> otRecords = Coms_BulkSiteUploadUtils.getAllOrchestrationTechnicalRecords(null,null,new List<String>{corelationId},0,0);
            if(otRecords[0] != null){
                String siteName;  
                if(String.IsNotBlank(otRecords[0].Field_6__c)  && otRecords[0].Field_6__c.equalsIgnoreCase('Address')){
                    siteName = String.IsNotBlank(otRecords[0].Field_1__c) ? otRecords[0].Field_1__c : selectedAddress;
                    String addressCreated = SearchAddressController.getAutoCompAddress(selectedAddress);
                    if(addressCreated != 'Fail' ){

                        CreateSiteController.saveNewSite(siteName, accRecordId , addressCreated );
                        resultMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_TRUE);
                    }
                    else{
                        resultMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_FALSE);
                    }
                }else if(String.IsNotBlank(otRecords[0].Field_6__c)  && otRecords[0].Field_6__c.equalsIgnoreCase('AdborId')){
                    siteName = String.IsNotBlank(otRecords[0].Field_1__c) ? otRecords[0].Field_1__c : otRecords[0].Field_5__c;
                    List<cscrm__Address__c> addresses;
                    if(otRecords[0].BackupJson__c!=null){
                        addresses = SearchAddressController.saveAddressApexList(otRecords[0].backupjson__c,otRecords[0].Field_4__c,'adboridaddresshandler', false);
                    }
                    if(addresses!= null && !addresses.isEmpty() ){
                        String result = CreateSiteController.saveNewSite(siteName, accRecordId , addresses[0].Id );
                        resultMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_TRUE);
                    }else{
                        resultMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_FALSE);
                    }                    
                }
                if(resultMap.get('isSuccess') == 'true'){
                    BulkUploadSiteDataHelper.updateOrchestrationTechnicals(otRecords[0].Id,selectedAddress);
                }
            } 
            else{
                resultMap.put('isSuccess',Coms_BulkSiteUploadUtils.STR_FALSE);
            } 
            return resultMap;          
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    }



    /**
     *  Method Name :- exportUnmatchedSites
     *  Author : Ajith Kumar
     *  Description:- This method is to export failed,not found, found, and new status records  
     */
    @AuraEnabled
    public static List<Orchestration_Technical__c> exportUnmatchedSites(string accountId,List<String> status){
       try {
            List<Orchestration_Technical__c> recordsToExport = Coms_BulkSiteUploadUtils.getAllOrchestrationTechnicalRecords(accountId,status,null,0,null);
            if(recordsToExport != null && !recordsToExport.isEmpty())
                return recordsToExport;
            else{
                return null;
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    }

    /**
     *  Method Name :- deleteSiteRecord
     *  Author : Ajith Kumar
     *  Description:- This method is to delete site record 
     */
    @AuraEnabled
    public static Map<String,String> deleteSiteRecord(String corelationId, Id accRecordId){
        try {
            Map<String,String> resultMap = new Map<String, String>();
            String  isSuccess = Coms_BulkSiteUploadUtils.deleteOrchestrationTechnicals(corelationId,accRecordId);
            resultMap.put('isSuccess',isSuccess);
            return resultMap;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getCountOfFailedRecord(String accountId, List<String> listOfStatus, String groupByField){
        try {
            List<AggregateResult> listOfAggregateResult =  Coms_BulkSiteUploadUtils.getCountQueryResult(accountId,listOfStatus,groupByField);//DIGI-28081 Removed the query string and moved to utils class
            return listOfAggregateResult;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void logException(String methodName,  String errorMessage, String businessDescription){
        try{
            GenericUtilityClass.logException('BulkUploadSiteDataController',methodName,'','',errorMessage,businessDescription,C2O_ExceptionHandler.Capability.ORD);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}