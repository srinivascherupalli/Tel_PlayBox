public abstract class IntegrationQueueHandler implements Queueable {
    public static final String PENDING = 'Pending';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String PROCESSED = 'Processed';
    
    private String handlerName;
    private Integer maxNoOfRows;
    private Integer maxNoOfParallels;

    public static Boolean SCHEDUL_RUNNING_IN_CONTEXT= false;
    private static Integer DEFAULT_MAX_PARALLELS = 1;
    
    public IntegrationQueueHandler(String hName) {                      
        setProperties(hName, null, null);

        system.debug('handlerName: ' + handlerName);
        system.debug('maxNoOfRows: ' + maxNoOfRows);
        system.debug('maxNoOfParallels: ' + maxNoOfParallels);
    }
    
    public IntegrationQueueHandler(String hName, Integer maxRows) {               
        setProperties(hName, maxRows, null);

        system.debug('handlerName: ' + handlerName);
        system.debug('maxNoOfRows: ' + maxNoOfRows);
        system.debug('maxNoOfParallels: ' + maxNoOfParallels);
    }
    
    public IntegrationQueueHandler(String hName, Integer maxRows, Integer maxParallels) {     
        setProperties(hName, maxRows, maxParallels);
        
        system.debug('handlerName: ' + handlerName);
        system.debug('maxNoOfRows: ' + maxNoOfRows);
        system.debug('maxNoOfParallels: ' + maxNoOfParallels);        
    }    
    
    /*
    *	Abstract method each handler extending this class need to extend and provide its own
    *	logic 
    *	Request Integration handlers - It will be for building payload and making a callout 
    *	Response Integration handlers - Traversing a passed in payload and storing the extracted values within Salesforce   
    */
    public abstract void executeWork(List<String> params);
    
    public void execute(QueueableContext context) {       
        List<String> workParamsList = new List<String>();        
        List<String> paramsList;        
        Map<Integer, List<String>> paramsMap = new Map<Integer, List<String>>();        

        Integer parallelNo = 1;     
        Integer rowCnt = 1;
        Integer paramsCnt = 0;
        
        try {
            // JobId is the AsyncApexJob Id
            Id existingJobId = context.getJobId();
            system.debug('existingJobId: ' + existingJobId);
            
            paramsList = getRequestParams(); 
            
            system.debug('paramsList size: ' + paramsList.size());

            if (!paramsList.isEmpty()) {                                
                // Build map of params lists        
                for (String param : paramsList) {
                    paramsCnt++;                    
                    
                    system.debug('parallelNo: ' + parallelNo);
                    system.debug('paramsCnt: ' + paramsCnt);
                    system.debug('param: ' + param);        
                    
                    if (rowCnt < maxNoOfRows && paramsCnt != paramsList.size() && String.isNotEmpty(param)) {
                        // Add parm to list
                        workParamsList.add(param);
                        rowCnt++;                   
                    } else {
                        // Add parm to list - final parm for this list
                        if(String.isNotEmpty(param)){
                            workParamsList.add(param);
                        }                                               
                        
                        if (!workParamsList.isEmpty()) {
                            paramsMap.put(parallelNo, workParamsList);
                        }
                        
                        workParamsList = new List<String>();                        
                        parallelNo++;       
                        rowCnt = 1;             
                    }
                }
                
                system.debug('paramsMap size: ' + paramsMap.size());
            
                // For each parallel - fire off executework
                for (Integer parallelNum = 1; parallelNum <= paramsMap.size(); parallelNum++) {
                    system.debug('processing parallelNum: ' + parallelNum + ' of ' + paramsMap.size() + ' (' + 'Max Parallels:' + maxNoOfParallels + ')');
                                                            
                    System.debug('ParamsMap Value: ' + paramsMap.get(parallelNum));
                    // Get params list for parallel run
                    if (paramsMap.get(parallelNum) != null) {
                        executeWork(paramsMap.get(parallelNum));
                    }
                }
                
                SCHEDUL_RUNNING_IN_CONTEXT = false;
                system.debug('SCHEDUL_RUNNING_IN_CONTEXT: ' + SCHEDUL_RUNNING_IN_CONTEXT);
                
                run(existingJobId);
            }
        } catch (Exception e) {
            throw e;
        }
    }

    @TestVisible 
    private List<String> getRequestParams() {       
        List<Integration_Record__c> intRecList;
        List<String> paramsList = new List<String>();
        Integer noOfParamsQueryLimit;
            
        noOfParamsQueryLimit = maxNoOfParallels * maxNoOfRows;                       
        
        system.debug('NoOfParamsQueryLimit: ' + noOfParamsQueryLimit);

        if (noOfParamsQueryLimit != null && noOfParamsQueryLimit > 0) {
        	intRecList = [SELECT Params__c 
                          FROM Integration_Record__c 
                          WHERE Handler__c = :handlerName AND Status__c = :PENDING
                          ORDER BY Priority__c LIMIT :noOfParamsQueryLimit];

        	system.debug('IntRecList: ' + intRecList.size());

            if (!intRecList.isEmpty()) {
            	paramsList = new List<String>();

                for (Integration_Record__c intRec: intRecList) {
                    paramsList.add(intRec.Params__c );
                    intRec.Status__c = IN_PROGRESS;
                }

                system.debug('paramsList size: ' + paramsList.size());
                update intRecList;
            }
        }                     
                
        return paramsList;
    }

    @TestVisible 
    private void setProperties(String hName, Integer maxRows, Integer maxParallels) {
        try {
            handlerName = hName;
            maxNoOfRows = IntegrationRecordHandlerUtil.getMaxNoOfRows(hName, maxRows);
            maxNoOfParallels = IntegrationRecordHandlerUtil.getMaxNoOfParallels(hName, maxParallels);          
        } catch (Exception e) {
            throw e;
        }                          
    }
        
    public void run(Id existingJobId) {
        system.debug('existingJobId: ' + existingJobId);            
        system.debug('SCHEDUL_RUNNING_IN_CONTEXT: ' + SCHEDUL_RUNNING_IN_CONTEXT);
        
        if (!SCHEDUL_RUNNING_IN_CONTEXT) {
            if (IntegrationQueuableUtils.isAnythingPendingToRun(handlerName)) {
                if (IntegrationQueuableUtils.queueHandlerJob(handlerName, existingJobId)) {
                    SCHEDUL_RUNNING_IN_CONTEXT = true;
                    
                    system.debug(handlerName + ' is started');
                }
                else {
                    system.debug(handlerName + ' is already running');
                }
            }
        }                                    
    }  
}