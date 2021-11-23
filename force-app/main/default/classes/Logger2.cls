/*
 *  Created By: Unknown
 *  Description: Class to capture information on requests sent between salesforce and integrated systems. 
 *  Modified by Ivan Aerlic & Alistair Wilks, 2019.
 *  Modified by Ajith Kumar , DIGI-28081 Created a method to return the log list
 */
public without sharing class Logger2 {
    //Cannot extend existing Logger class - not interface or abstract
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_extending.htm
    String loggerName ; 
    List<ApplicationLog__c> logList = new List<ApplicationLog__c>();
    
    /**********************************************************************************************
    @description: This is the private constructor of the logger. The logger must be initialised 
    via getLogger static method
    @param loggerName The name of the logger that is stored against the log entry. 
    **********************************************************************************************/  
    public Logger2(String loggerName) {
        this.loggerName = loggerName; 
    }
    /**********************************************************************************************
    @description: This is the factory method of the logger.
    @param typeName The type of the logger that is stored against the log entry. 
    **********************************************************************************************/  
    public static Logger2 getLogger(Type typeName){
        return new Logger2(typeName.getName());
    }
    
    public static Logger2 getLogger(String typeName){
        return new Logger2(typeName);
    }
    //After class maintanence on 11/2/2019 these overloaded methods were updated to call from one seperate method logMessageInterface
    //This was done to increase modularity because of code duplication. Due to dependancies in other classes we had to keep all method signatures.
    public void logMessages(String request, String response, String stacktrace, String category, String errorCode, String errorDesc, Boolean isImmediate, Boolean throwException){
        logMessageInterface(request, response, stacktrace, category, errorCode, errorDesc, '', '', '', '', '','',0,'', isImmediate, throwException);
    }
    //@Story: EDGE-2331 @Author: Shambo Ray @Description:Method OverLoading Used For The Below Method to Capture Error Log With new Fields
    public void logMessages(String request, String response, String stacktrace, String category, String errorCode, String errorDesc, Boolean isImmediate, Boolean throwException,Integer statuscode,string cac,string uuid,String errorType){
        logMessageInterface(request, response, stacktrace, category, errorCode, errorDesc, String.valueOf(statuscode), '', cac, uuid, errorType, '',0,'', isImmediate, throwException);
    }
    //Complete and current method signature
    public void logMessages(String request, String response, String stacktrace, String category, String errorCode, 
                            String errorDesc, String statuscode, String correlationId, String cac,String uuid,String errorType, String eventType, Long requestTime, String requestMethod, 
                            Boolean isImmediate, Boolean throwException){
                                logMessageInterface(request, response, stacktrace, category, errorCode, errorDesc, 
                                                    statuscode, correlationId, cac,
                                                    uuid, errorType, eventType, requestTime, requestMethod, isImmediate, throwException); 
                            }
    /*****
     * DON'T USE
     * Description: This message should never be used by an outside class. It should always be flexible in that its parameters should always have the ability to change without first changing an outside class. 
     ****/
    private void logMessageInterface(String request, String response, String stacktrace, String category, String errorCode, 
                                     String errorDesc, String statuscode, String correlationId, String cac,String uuid,String errorType, String eventType, Long requestTime, String requestMethod, 
                                     Boolean isImmediate, Boolean throwException){
        if (EnvironmentalSettings.isLoggingEnabled() && response != null && request != null){
            statusCode = (statusCode == '0' ? '' : statusCode);
            String debugLevel = '';
            String truncatedResponse = response;
            String truncatedRequest = request;
            String truncatedstacktrace = stacktrace;
            system.debug('response inbound'+response);
            if(response.length() > 131070){
                truncatedResponse = truncatedResponse.substring(0, 131070); 
            }
            if(request.length() > 131070){
                truncatedRequest = truncatedRequest.substring(0, 131070); 
            } 
            if(stacktrace.length() > 32760){
                truncatedstacktrace = stacktrace.substring(0, 32760);
            }
            if((request.length() > 0 || response.length() > 0)){ 
                debugLevel = 'Integration';
            } else if(stacktrace.length() > 0){
                debugLevel = 'Exception';
            } else if(errorCode.length() > 0 || errorDesc.length() > 0){ 
                debugLevel = 'Debug';
            }
            ApplicationLog__c logRec = new ApplicationLog__c(Reference_Info__c = loggerName, 
                                                             Debug_Level__c = debugLevel,  
                                                             Request_Message__c = truncatedRequest, 
                                                             Message__c = truncatedResponse, 
                                                             Stack_Trace__c = truncatedStackTrace,
                                                             Error_Category__c = category, 
                                                             correlationId__c = correlationId, 
                                                             Error_Code__c = errorCode,
                                                             Timer__c = System.now(),
                                                             User__c=UserInfo.getUserId(),
                                                             Error_Description__c =errorDesc, 
                                                             Status_Code__c = statusCode, 
                                                             Http_Code__c = statusCode,
                                                             CAC__c = cac, 
                                                             UUID__c = uuid, 
                                                             Error_Type__c = errorType,
                                                             Event_Type__c = eventType,
                                                             API_Request_Time__c = requestTime,
                                                             Request_Method__c = requestMethod);   
			System.debug('isAsyncProcess '+isAsyncProcess());
            insertLog(logRec, isImmediate,isAsyncProcess(), response, request);
            
            if(throwException){
                CustomException cEx = new CustomException();
                cEx.setMessage(category+': '+ errorCode + ': '+errorDesc);
                throw cEx;
            }
        }
    }
    //DIGI-28081 This method returns the success and failure log List
    public ApplicationLog__c logMessage(String request,String response, Boolean throwException,String statuscode,String correlationId,String loggerName){
        ApplicationLog__c logRec;
        if (EnvironmentalSettings.isLoggingEnabled() && response != null && request != null){
            statusCode = (statusCode == '0' ? '' : statusCode);
            String debugLevel = '';
            String truncatedResponse = response;
            String truncatedRequest = request;
            if(response.length() > 131070){
                truncatedResponse = truncatedResponse.substring(0, 131070); 
            }
            if(request.length() > 131070){
                truncatedRequest = truncatedRequest.substring(0, 131070); 
            }
            if((request.length() > 0 || response.length() > 0)){ 
                debugLevel = 'Integration';
            } 
            logRec = new ApplicationLog__c(Reference_Info__c = loggerName,
                                        Debug_Level__c = debugLevel,  
                                        Request_Message__c = truncatedRequest, 
                                        Message__c = truncatedResponse,
                                        correlationId__c = correlationId,                                                      
                                        Timer__c = System.now(),
                                        User__c=UserInfo.getUserId(),                                                             
                                        Status_Code__c = statusCode, 
                                        Http_Code__c = statusCode);			
			         
            if(throwException){
                CustomException cEx = new CustomException();
                cEx.setMessage(truncatedResponse);
                throw cEx;
            }
        }
        return logRec;
    }
     
    private Boolean isAsyncProcess() {
        return (Test.isRunningTest() && loggerName ==  'Asynchronous Test') || (system.isFuture() || system.isBatch() || system.isScheduled());
    }
    
    public void exitLogger() {
        system.debug('loglist'+logList);
        if(!logList.IsEmpty()) {
            commitTransaction(logList);
        }
        logList.clear();
    }
    
    private void commitTransaction(List<ApplicationLog__c> appLogList){
        String jsonLoggerMsg=JSON.serialize(appLogList);      
        System.debug('MMMM' + jsonLoggerMsg );        
        insertAppLogList(jsonLoggerMsg);
    }
    
    private void insertLog(ApplicationLog__c logRec,Boolean isImmediate, Boolean isAsync,string mainResponse, String mainRequest){
        System.debug('YYYY'+isImmediate );
        system.debug('logrec'+logRec);  
        if(isImmediate){
            System.debug('XXXXX'+isImmediate );
            try{
                insert logRec;
            }
            catch(Exception e){ //catch exceptions and continue: a logger DML failure should not interfere with main transactions
                System.debug('Logger2: insertLog: '+ e.getMessage());
            }
            if(mainResponse != null || mainRequest!= null ){
                try{
                    insert createAttachment(mainResponse,mainRequest,logRec.Id);
                }
              catch (Exception e){ //catch exceptions and continue: a logger DML failure should not interfere with main transactions
                  System.debug('Logger2: insertLog: '+ e.getMessage()); // or whatever is appropriate
                }
            }
            system.debug('appLog'+logRec);
            system.debug('id value '+logRec.id);
            //return appLog.Id;
        }else if(isAsync){
            System.debug('MMMM'+ isAsync + 'MMM'+isImmediate );
            logList.add(logRec);
            for(ApplicationLog__c lg : logList){
                System.debug('Log: ' + lg);
            }
            if( Limits.getLimitDmlStatements()>0 && ((Decimal.valueOf(Limits.getDmlStatements())/Limits.getLimitDmlStatements()) < 0.8) && !logList.isEmpty() ) {
                Database.SaveResult[] srList = Database.insert(logList,true);
        List<Attachment> attachments = new List<Attachment>(); // stores all attachments to insert in a single transaction, rather than inside of loop
                Id logId;
                for (Database.SaveResult sr : srList)
                {
                    logId = sr.getId();
                    attachments.addAll(createAttachment(mainResponse,mainRequest,logId));
                }
        try{
          insert attachments;
        }
        catch(Exception ex){//catch exceptions and continue: a logger DML failure should not interfere with main transactions
          System.debug('Logger2: insertLog: Exception:' + ex.getMessage());
        }
        logList = new List<ApplicationLog__c>();
            }
        }else{
            logList.add(logRec);
        }
        system.debug('appLog'+logRec);
        system.debug('id value '+logRec.id);
    }

    @future(callout=true)
    private static void insertAppLogList(String appList){
        List<ApplicationLog__c> logMessageList = (List<ApplicationLog__c>)System.JSON.deserialize(appList, List<ApplicationLog__c>.class);
        if(!logMessageList.isEmpty()){
            System.debug('EEEE' + logMessageList);
            try{
              insert logMessageList;
            }
            catch (Exception e){
                System.debug('Logger2: insertAppLogList: Exception:' + e.getMessage());// something like this
            }
        }
    }
    
  private static List<Attachment> createAttachment(String mainResponse, String mainRequest, Id logId){
    // Create a list of attachments, so that both response and request can have attachments associated with the parentID
    List<Attachment> attachments = new List<Attachment>();
    if(!String.isBlank(mainResponse)){// checks for '' and null
            attachments.add( new Attachment(Body = Blob.valueOf(mainResponse), Name = 'ResponseBody.txt', ParentID = logId));
        }
        if(!String.isBlank(mainRequest)){
            attachments.add( new Attachment(Body = Blob.valueOf(mainRequest), Name = 'RequestBody.txt', ParentID = logId));
        }
        return attachments;
    }
    // This method will expect start time and end time and return the difference time in millisecond format
    public Long  getRequestTimeDifference(DateTime startTime, DateTime endTime){
        Long dt1Long = startTime.getTime();
        Long dt2Long = endTime.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;
        
        return milliseconds;//hours+':'+minutes+':'+seconds;
    }
}