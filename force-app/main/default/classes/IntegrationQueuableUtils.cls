/*
*    This Util class captures all the common methods that are needed to expose the functioanlity of the Integration
*    framework to its consumers.  The consumers could be backend code such as a Queueable job or a Frontend UI through which a
*    actual user want to process a Integration Record  
*/
public with sharing class IntegrationQueuableUtils {
    public static final String PENDING = 'Pending';
    public static final String QUEUED = 'Queued';
    public static final String PROCESSING = 'Processing';
    public static final String PREPARING = 'Preparing';
    public static final String ERROR = 'Error';
    public static final Integer NUM_MINUTES = -60;
    
    public static void updateOnSucess(String handlerName, List<String> params) {
    	system.debug('Retry params: ' + params);
    	List<Integration_Record__c> integrationRecList = getIntegrationRecordList(handlerName, params);
    	List<Integration_Record__c> integrationRecListForUpdate = new List<Integration_Record__c>();
    	for(Integration_Record__c intRec : integrationRecList) {
    		intRec.Status__c = IntegrationQueueHandler.PROCESSED;
            integrationRecListForUpdate.add(intRec);
            
    	}
    	new IntegrationRecordsManipulationQueueble(integrationRecListForUpdate,false).executeIntegrationRecords();
    	//update integrationRecList;
    }
    
    public static void retry(String handlerName, List<String> params, String errorMessage) {                
        try {
            system.debug('Retry params: ' + params);
            List<Integration_Record__c> integrationRecList = getIntegrationRecordList(handlerName, params);
                
            if (!integrationRecList.isEmpty()) {           
                for (Integration_Record__c iRec : integrationRecList) {
                    system.debug('Number_Of_Retries__c: ' + iRec.Number_Of_Retries__c);
                    system.debug('Status__c: ' + iRec.Status__c);
                    
                    if (String.isNotEmpty(errorMessage)) {
                        iRec.Error_Message__c = errorMessage;   
                    }
                    
                    if (iRec.Number_Of_Retries__c < IntegrationRecordHandlerUtil.getMaxNoOfRetries(handlerName)) {
                        iRec.Status__c = PENDING;
                        iRec.Number_Of_Retries__c++;
                    } else {
                        iRec.Status__c = ERROR;
                    }
                }
                
                update integrationRecList;                
                queueHandlerJob(handlerName, null); 
            }
        }
        catch (Exception e) {
        	Logger.getLogger(handlerName).debug(e);
            throw e;
        }         
    }
    
    public static Boolean queueHandlerJob(String handlerName, Id existingJobId) {     
        Boolean requestQueued = false;

        try {   
            system.debug('existingJobId: ' + existingJobId);                        
            system.debug('handlerName: '+ handlerName);     
            system.debug('Queued Already:' + Limits.getQueueableJobs());
            system.debug('Allowed to Queue:'+Limits.getLimitQueueableJobs());
            if (!isAlreadyRunning(handlerName, existingJobId) && (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())) {
                // All handlers  
                Type handlerType = Type.forName(handlerName);
                
                if(handlerType != null) {
                    Id jobId = System.enqueueJob((IntegrationQueueHandler)handlerType.newInstance());
                    if (jobId != null) {
                        requestQueued = true;
                    }
                }
            }                       
        } catch (Exception e) {
            //Logger.Exception
            throw e;
        }
     
        return requestQueued;
    }

    public static Boolean isAnythingPendingToRun(String handlerName) {                  
        List<Integration_Record__c> integrationReqList;
        Boolean anythingPendingToRun = false;

        try {
            system.debug('handlerName: '+ handlerName);
    
            integrationReqList = [SELECT Id 
                                  FROM Integration_Record__c 
                                  WHERE Handler__c =: handlerName 
                                  AND Status__c = : PENDING LIMIT 1];
                        
            if (!integrationReqList.isEmpty()) { 
                anythingPendingToRun = true;
            }                       
        } catch (Exception e) {
            //Logger.Exception
            throw e;
        }       
      
        return anythingPendingToRun;           
    }  
    
    private static Boolean isAlreadyRunning(String handlerName, Id existingJobId) {        
        Set<String> activeApexJobStatesSet;
        List<AsyncApexJob> activeApexJobsList;

        Boolean isAlreadyRunning = false;
        
        try {                           
            system.debug('existingJobId: ' + existingJobId);                                        
            system.debug('handlerName: '+ handlerName);
       
            activeApexJobStatesSet = new Set<String>{QUEUED, PROCESSING, PREPARING};
            
            activeApexJobsList = [SELECT Id, 
                                         ApexClass.Name
                                  FROM   AsyncApexJob
                                  WHERE  ApexClass.Name =: handlerName 
                                  AND    Status in :CollectionUtil.removeNull(activeApexJobStatesSet)
                                  AND    Id <> :existingJobId];                                
                                             
            if (!activeApexJobsList.isEmpty()) {                        
                isAlreadyRunning = true;
            }                               
        } catch (Exception e) {
            //Logger.Exception
            throw e;
        }       
                
        return isAlreadyRunning;
    }
    
    private static List<Integration_Record__c> getIntegrationRecordList(String hName, List<String> paramList) {
    	List<Integration_Record__c> integrationRecList;
        
        integrationRecList = new List<Integration_Record__c>([SELECT Id, Status__c, Number_Of_Retries__c,Params__c,Handler__c,paramPayload__c
                              								  FROM Integration_Record__c 
								                              WHERE Handler__c =: hName 
								                              AND Status__c = :IntegrationQueueHandler.IN_PROGRESS
								                              AND SystemModstamp > :Datetime.now().addMinutes(NUM_MINUTES)
								                              AND Params__c  IN :CollectionUtil.removeNull(paramList)
								                              ORDER BY CreatedDate ASC                      
								                              LIMIT  1000]);
								                              
    	return integrationRecList;
    }
}