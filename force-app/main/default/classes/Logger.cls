global with sharing class Logger {

 String loggerName ; 
 //public static List<LoggerMessage> loggerMsgList =new List<LoggerMessage>();
 public static List<ApplicationLog__c> logList=new List<ApplicationLog__c>();
/**********************************************************************************************
    @description: This is the private constructor of the logger. The logger must be initialised 
    via getLogger static method
    @param loggerName The name of the logger that is stored against the log entry. 
    **********************************************************************************************/  
  private Logger(String loggerName) {
        this.loggerName = loggerName ; 
    }
    
 /**********************************************************************************************
    @description: This is the factory method of the logger.
    @param typeName The type of the logger that is stored against the log entry. 
    **********************************************************************************************/  
  public static Logger getLogger(Type typeName)
  {
        return new Logger(typeName.getName());
  }
  
  public static Logger getLogger(String typeName)
  {
        return new Logger(typeName);
  }
  
  /**********************************************************************************************
    @description: This method will log an event against user as a future call
    @param message the message
    **********************************************************************************************/        
    public void debug(String message)
    {
     	   debug(message,false);
           
    }
    
    /**********************************************************************************************
    @description: This method will log an event against user , Please be carefull in using this method as it is not bulkified
    @param message the message
    **********************************************************************************************/        
    public void debug(String message,Boolean isImmediate)
    {
        if(isAsyncProcess())
      		{
      			
      			 logforAsync('LOG','DEBUG' , message , null,false) ;
      		}
      		else
      		{
        			log('LOG','DEBUG' , message , null,isImmediate);
      		}
    }
    
    
    
    
    
     /**********************************************************************************************
    @param Exception the message
    **********************************************************************************************/        
    public void debug(Exception e) 
    {
        
              debug(e,false);
    }
  
   /**********************************************************************************************
    @param Exception the message
    **********************************************************************************************/        
    public void debug(Exception e,Boolean isImmediate) 
    {
      		if(isAsyncProcess())
      		{
      			 logforAsync('Exception' ,'', e.getMessage() , e.getStackTraceString(),false) ;
      		}
      		else{
            	 log('Exception' , '',e.getMessage() , e.getStackTraceString(),isImmediate) ; 
      		}
    }
  
  
	 //logRequest  
   /**********************************************************************************************
    @description: This method will log an integration request against user as a future call
    @param message the message
    **********************************************************************************************/        
    public void logRequest(String message)
    {
     	   logRequest(message,false);
           
    }
    
    /**********************************************************************************************
    @description: This method will log an integration request against user , Please be carefull in using this method as it is not bulkified
    and insert the log as single record.
    @param message the message
    **********************************************************************************************/        
    public void logRequest(String message,Boolean isImmediate)
    {
        if(isAsyncProcess())
      		{
      			
      			 logforAsync('Integration','Request' , message , null,isImmediate) ;
      		}
      		else
      		{
        			log('Integration','Request' , message , null,isImmediate);
      		}
    }
    
    //logRequest
    
    //logResponse
    
    
   /**********************************************************************************************
    @description: This method will log an integration request against user as a future call
    @param message the message
    **********************************************************************************************/        
    public void logResponse(String message)
    {
     	   logResponse(message,false);
           
    }
    
    /**********************************************************************************************
    @description: This method will log an integration request against user , Please be carefull in using this method as it is not bulkified
    and insert the log as single record.
    @param message the message
    **********************************************************************************************/        
    public void logResponse(String message,Boolean isImmediate)
    {
       string truncatedmsg = '';
        if(message.length() > 31999){
         truncatedmsg =  message.substring(1,32000);
        }
        
        if(isAsyncProcess())
      		{
      			
      			 logforAsync('Integration','Response' , truncatedmsg , null,isImmediate) ;
      		}
      		else
      		{
        			log('Integration','Response' , truncatedmsg , null,isImmediate);
                	 
      		}
       
    }
    
    
    //End log response
    
  private  void  log(String level,String logtype, String message , String stacktrace,Boolean isImmediate) 
  {
        if (EnvironmentalSettings.isLoggingEnabled()) 
        {           
            if (!test.isRunningTest() )
            {
               logUserMessage(loggerName,level,logtype,message,stacktrace,isImmediate); 

            } 
            //While running test classes
            else 
            {
                //LOGGER(CURRENT_SETTINGS.LogLimits__c, String.valueof(new wrapLimits()), message , stacktrace,  level , loggerName ,  System.now() , UserInfo.getUserId()) ; 
            }
        }
   }
    
   @Testvisible private void logforAsync(String level,String logtype, String message , String stacktrace,Boolean isImmediate)
   {
   		 if (EnvironmentalSettings.isLoggingEnabled()) 
        {     
        	System.debug('AAAAKKKK' );      
            if (!test.isRunningTest() )
            {
               
            		logUserMessage(loggerName,level,logtype,message,stacktrace,isImmediate,true); 
                
                
            } 
            
        }
   }
    
    
   private Boolean isAsyncProcess() {
        return !Test.isRunningTest() && (system.isFuture() || system.isBatch() || system.isScheduled());
    }
    
     
    public static void exitLogger() {
        if(!logList.IsEmpty())
           commitTransaction(logList);
        logList.clear();
    }
    
    @Testvisible private static void logUserMessage(String loggerName,String debugLevel,string logtype,string message, string stacktrace,Boolean isImmediate,Boolean isAsync)
    {
    	System.debug('IIII' + isImmediate);
        LoggerMessage logMessage=new LoggerMessage();        
        logMessage.referenceInfo=loggerName;
        logMessage.stacktrace=stacktrace;
        logMessage.logMessage=message;
        logMessage.debugLevel=debugLevel;
        logMessage.logType=logType;
      
       /* if(!isImmediate)
        {
        loggerMsgList.add(logMessage);
        }
        else{
        	commitTransaction(logMessage);
        }*/
        
       insertLog(logMessage,isImmediate,isAsync);
        
    }
    
    @Testvisible private static void logUserMessage(String loggerName,String debugLevel, string logtype,string message, string stacktrace,Boolean isImmediate)
    {
    	logUserMessage(loggerName,debugLevel,logtype,message,stacktrace,isImmediate,false);
    }
   
   
  
    
    @Testvisible private static void commitTransaction(List<ApplicationLog__c> appLogList)
    {
        String jsonLoggerMsg=JSON.serialize(appLogList);      
        System.debug('MMMM' + jsonLoggerMsg );        
        insertAppLogList(jsonLoggerMsg);
    }
    
    
    private static id insertLog(LoggerMessage logRec,Boolean isImmediate,Boolean isAsync)
    {
        System.debug('YYYY'+isImmediate );
    	ApplicationLog__c appLog=new ApplicationLog__c();
    	
    	//LoggerMessage msg=(LoggerMessage)System.JSON.deserialize(logRec, LoggerMessage.class);
    			appLog.Debug_Level__c = logRec.debugLevel;
				appLog.Message__c = logRec.logMessage;
				appLog.Reference_Info__c = logRec.referenceInfo;
				appLog.Stack_Trace__c = logRec.stackTrace;
				appLog.Timer__c = System.now();
				appLog.User__c=UserInfo.getUserId();
				appLog.Type__c=logRec.logType;
				if(isImmediate){
                    System.debug('XXXXX'+isImmediate );
					insert appLog;
					return appLog.Id;
				}
				else if(isAsync)
				{
					System.debug('MMMM'+ isAsync + 'MMM'+isImmediate );
					logList.add(appLog);
					for(ApplicationLog__c lg : logList) {
						System.debug('Log: ' + lg);						
					}
                    
					if( Limits.getLimitDmlStatements()>0 && (Decimal.valueOf(Limits.getDmlStatements()) / Limits.getLimitDmlStatements()) < 0.8) {
                	if(!logList.isEmpty()){
                		Database.insert(logList,true);
                		logList = new List<ApplicationLog__c>();
                	}
                	
            }
            		return null;
				}
				else {
					logList.add(appLog);					 
					return null;
				}
			
				
    }
    
    @future(callout=true)
    private static void insertAppLogList(String appList)
    {
    	 List<ApplicationLog__c> logMessageList = (List<ApplicationLog__c>)System.JSON.deserialize(appList, List<ApplicationLog__c>.class);
    	 if(!logMessageList.isEmpty()){
    	 	System.debug('EEEE' + logMessageList);
    	 	insert logMessageList;
    	 }
    	 
	 
    }
    
	
    
    
    
    
}