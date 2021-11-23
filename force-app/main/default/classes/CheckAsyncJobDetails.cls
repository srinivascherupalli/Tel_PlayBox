/**
* @Author       : Kamlesh Kumar
* @Date         : 15 Dec 2020
* @Bug Fixes    : EDGE-213033, Reported by SonarQube report to remove null from return type method
* @Defect Fixes : EDGE-216600 Getting error on clicking 'Submit Basket' button using PRM.
* 4/6/21        : EDGE : 199074 Removed log exception and handle in handleException method
* Enhancement   : DIGI-24328 auto refresh opportunity page once basket is synced adding methof fetchPrimaryBasketDetails
* */
public with sharing class CheckAsyncJobDetails {
    
    //EDGE-213033
    static String correlationId = GuidUtil.NewGuid();
    static final string className = 'CheckAsyncJobDetails';
    /**
*@Created By : Kamlesh Kumar
*@Breif : Method created to get job status from async job
*/
    @AuraEnabled
    public static Map <String,AsyncApexJob> toCheckSyncJobCompletion(List<String> jobId) {
        //EDGE-205509 : Calls the genric class to fetch the apex job details
        Map <String,AsyncApexJob> asyncApexJobMap = new Map <String,AsyncApexJob>();
        try {
            asyncApexJobMap = GenericUtilityClass.ayncJobDetails(jobId);
        }
        catch (Exception e) {
            //EDGE-213033
            throw new AuraHandledException('Exception occured during fetching async job details : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );   
        }
        return asyncApexJobMap;
    }
    
    /*Created By : Kamlesh Kumar
*Created Date : 26-2-2020
*Breif : EDGE-199074, method created to fetch job id for inflight suubmit basket and use in LWC side
*/
    @AuraEnabled
    public static Map <String,AsyncJobIdWrapper> getJobId(String name, String basketId) {
        
        Map <String,AsyncJobIdWrapper> jobIdMap = new Map <String,AsyncJobIdWrapper>();
        try {
            cscfga__Product_Basket__c basket = [Select id, sync_job_Id__c from cscfga__Product_Basket__c where Id = :basketId];
            if((name == 'syncJobId' || name == 'fundJobId' || name == 'submitJobId') && String.isNotBlank(basket.sync_job_Id__c) && basket.sync_job_Id__c.contains(name)) {
                AsyncJobIdWrapper jobWrap = new AsyncJobIdWrapper();
                List<AsyncJobIdWrapper> obj = jobWrap.parse(basket.sync_job_Id__c);
                for (AsyncJobIdWrapper wp: obj) {
                    jobIdMap.put(wp.name,wp);
                }
            }
            else {
                AsyncJobIdWrapper jobWrap = new AsyncJobIdWrapper();
                jobWrap.name = 'noInFlightBatch';
                jobWrap.id = basket.sync_job_Id__c;
                jobIdMap.put('noInFlightBatch',jobWrap);
            }
        }
        catch(Exception e) {
            //EDGE-213033
            throw new AuraHandledException('Exception occured during fetching async job id : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );
        }
        return jobIdMap;
    }
    
    /*
*@Created By : Kamlesh Kumar
*@Created Date : 9/3/2021
*@Breif : The method used to check status of last async job 
*/
    @AuraEnabled
    public static Boolean checkLastRunningApexJobStatus(String syncJobId,String jobName) {
        Id jobId;
        Map<String,String> batchJobDetails = new Map<String,String>();
        try{
            if(String.isBlank(syncJobId)){
                return false;
            }//EDGE:216600 - Adding check for only running during batch execution
            else if(String.isNotBlank(jobName) && (jobName == 'syncJobId' || jobName == 'fundJobId' || jobName == 'submitJobId') && syncJobId.contains(jobName)) {
                AsyncJobIdWrapper asyncwrap = new AsyncJobIdWrapper();
                List<AsyncJobIdWrapper> obj = asyncwrap.parse(syncJobId);
                for(AsyncJobIdWrapper wp : obj ) {
                    batchJobDetails.put(wp.name,wp.id);
                }
                
                if(batchJobDetails.containskey(jobName)) {
                    jobId = batchJobDetails.get(jobName);
                }
                if(String.isNotBlank(jobId)) {
                    Map<String,AsyncApexJob> asyncApexJobMap = toCheckSyncJobCompletion(new List<String>{jobId});
                    //EDGE:216600
                    if(!asyncApexJobMap.isEmpty() && asyncApexJobMap.get(jobId).Status == 'Completed') {
                        return true;
                    }
                }
            }
            
            
        }catch(Exception e) {
            //EDGE-213033
            throw new AuraHandledException('Exception occured during checking last async job status : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );
        }
        return false;
    }
    
    /*Created By : Kamlesh Kumar
*Created Date : 26-2-2020
*Breif : EDGE-199074, method created to fetch basket details and use in LWC side. We are not using Model_ProductBasket.getProductBasket method as this method is not bulkify
*/
    @AuraEnabled
    public static Map <String,cscfga__Product_Basket__c> fetchBasketDetails(List<String> basketId) {
        
        Map <String,cscfga__Product_Basket__c> basketDetailsMap = new Map <String,cscfga__Product_Basket__c>();
        try {
            Set <String> baskId = new Set <String>();
            baskId.addAll(basketId);
            for (cscfga__Product_Basket__c basket: [SELECT id, csbb__Synchronised_With_Opportunity__c, cscfga__Opportunity__r.Id, cscfga__Opportunity__r.StageName, OF_Reversal_Inserted__c, csordtelcoa__Basket_Stage__c, cscfga__Basket_Status__c FROM cscfga__Product_Basket__c WHERE Id IN: baskId]) {
                basketDetailsMap.put(basket.id, basket);
            }
        }
        catch(Exception e) {
            //EDGE-213033
            throw new AuraHandledException('Exception occured fetching basket details : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );
        }
        return basketDetailsMap;
    }

    /*Created By : Nitin Kumar
    *Created Date: 29/10/2021
    *Breif       : DIGI-24328 method created to fetch primary basket details and use in LWC autoRefreshOpportunityPostSync.
    */
    @AuraEnabled
    public static cscfga__Product_Basket__c fetchPrimaryBasketDetails(Id opptyId){
        // getting primary basket
        cscfga__Product_Basket__c primaryBasket;
        try{
            List<cscfga__Product_Basket__c> listPrimaryBasket = new List<cscfga__Product_Basket__c>();
            listPrimaryBasket = [SELECT Id, RecordType.Name, Primary_Basket__c,csbb__Synchronised_With_Opportunity__c,sync_job_Id__c 
                                FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c =:opptyId and Primary_Basket__c = true limit 1];

            if(!listPrimaryBasket.isEmpty())    
                primaryBasket  = listPrimaryBasket[0];
           
        }
        catch(Exception e) {
            throw new AuraHandledException('Exception occured fetching basket details : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );
        }
        return primaryBasket;   
    }
    
    /*Created By : Kamlesh Kumar
*Created Date : 26-2-2020
*Breif : EDGE-199074, Fetch the validation, error message and can be used in vf, aura, lwc UI.
*/
    @AuraEnabled
    public static Map <String,Sync_Control_and_Constants__c> fetchSyncControlMessage() {
        Map <String,Sync_Control_and_Constants__c> messageMap = new Map <String,Sync_Control_and_Constants__c>();
        try{
            messageMap = Sync_Control_and_Constants__c.getAll();
        }
        catch(Exception e) {
            //EDGE-213033
            throw new AuraHandledException('Exception occured fetching custom settings details : ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString() );
        }
        return messageMap;
        
    }
    
    /*
*@Created By : Kamlesh Kumar
*@Created Date : 3/06/2021
*@Breif : This is a auraenabled method, due to not able to log exception and throwing aura exception at same time from catch block
* the method has been created. Which will get call from client side catch block to log exception
*/
    @AuraEnabled
    public static string handleException(String methodName,String exceptiongetMessage,String codeMessage) {
        try {
            GenericUtilityClass.logException(className,methodName,'',correlationId,exceptiongetMessage,codeMessage,C2O_ExceptionHandler.Capability.BSK);
        }
        catch(Exception e) {
            return 'failure';
        }
        return 'success';
        
    }

    
    /*Created By : Kamlesh Kumar
*Created Date : 26-2-2020
*Breif : EDGE-199074, Wrapper class created to store the batch name and async job id.
*/
    public class AsyncJobIdWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String id;
        @AuraEnabled public Boolean isCompleted;
        @AuraEnabled public Boolean error;
        public List < AsyncJobIdWrapper > parse(String json) {
            return (List<AsyncJobIdWrapper> ) System.JSON.deserialize(json, List<AsyncJobIdWrapper>.class);
        }
        
    }
}