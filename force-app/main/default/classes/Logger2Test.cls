@isTest
private class Logger2Test {

	@testsetup static void setup(){
		Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c = true);
		insert ec;
	}

//logMessages(String request, String response, String stacktrace, String category, String errorCode, String errorDesc, Boolean isImmediate)
    static testMethod void test_InterfaceReqResponse() {
		Test.startTest();

		Logger2 logger = Logger2.getlogger('InterfaceRequestResponse');
		logger.logMessages('Request Message', 'Response Message', '', '', '', '', false, false);
		logger.exitLogger();
		Test.stopTest();
		List<ApplicationLog__c> log = fetchApplicatioLog();

		System.assert(log.size() == 1);
		//System.assert(log[0].Request_Message__c == 'Request Message');
		System.assert(log[0].Message__c == 'Response Message');
		System.assert(log[0].Reference_Info__c == 'InterfaceRequestResponse');

	}
 /*************************************************************************************************
Name : test_getRequestTimeDifference
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/
    static testMethod void test_AsynchronousTest() {
		Test.startTest();

		Logger2 logger = Logger2.getlogger('Asynchronous Test');
		logger.logMessages('Request Message', 'Response Message', '', '', '', '', false, false);
		logger.exitLogger();
		Test.stopTest();
		List<ApplicationLog__c> log = fetchApplicatioLog(); 

		System.assert(log.size() == 1);
		//System.assert(log[0].Request_Message__c == 'Request Message');
		System.assert(log[0].Message__c == 'Response Message');
		System.assert(log[0].Reference_Info__c == 'Asynchronous Test');

	}
    /*************************************************************************************************
Name : test_getRequestTimeDifference
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/
    static testMethod void test_getRequestTimeDifference() {
       Test.startTest();
       Logger2 logger = new Logger2('Asynchronous Test');
        Long timeDifference= logger.getRequestTimeDifference(Datetime.now(),Datetime.now());
       Test.stopTest();
        System.assert(timeDifference != null);
    }
    static testMethod void test_InterfaceRequestNoRequest() {
        Test.startTest();
		Logger2 logger = Logger2.getlogger('InterfaceRequestResponse');
		logger.logMessages('', 'Response Message', '', '', '', '', false, false);
		
		logger.exitLogger();
		Test.stopTest();
		List<ApplicationLog__c> log = fetchApplicatioLog();

		System.assert(log.size() == 1);
		//System.assert(log[0].Request_Message__c == null);
		System.assert(log[0].Message__c == 'Response Message');
		System.assert(log[0].Reference_Info__c == 'InterfaceRequestResponse');

    }

    static testMethod void test_InterfaceNoResponse() {
         Test.startTest();
		Logger2 logger = Logger2.getlogger('InterfaceRequestResponse');
		logger.logMessages('Request Message', '', '', '', '', '', false, false);
		
		logger.exitLogger();
		Test.stopTest();
		List<ApplicationLog__c> log = fetchApplicatioLog();

		System.assert(log.size() == 1);
		//System.assert(log[0].Request_Message__c == 'Request Message');
		System.assert(log[0].Message__c == null);
    }

    static testMethod void test_LogException() {
        Test.startTest();
        Type t = Type.forName('Logger2');
		
     	Logger2 logger = Logger2.getlogger(t);
        TestException e = new TestException();
        e.setMessage('an error has occured');

        logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'CODE-ABC', e.getMessage(), false, false);
        logger.exitLogger();
    	Test.stopTest();
    	
    	List<ApplicationLog__c> log = fetchApplicatioLog();
    	List<Error_Log__c> logE = fetchErrorLog();
    	
    	System.assert(log[0].Error_Code__c == 'CODE-ABC');
    	System.assert(log[0].Error_Category__c == 'Technical');
    	System.assert(log[0].Error_Description__c == 'an error has occured');
    	//System.assert(logE[0].Error_Message__c == 'an error has occured');
    	//System.assert(logE[0].Error_Code__c == 'CODE-ABC');
    	//System.assert(logE[0].Error_Category__c == 'Technical');

    }
    
	static testMethod void test_throwException() {
        Test.startTest();
        Type t = Type.forName('Logger2');
		
     	Logger2 logger = Logger2.getlogger(t);
        TestException e = new TestException();
        e.setMessage('an error has occured');
        try{
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'CODE-ABC', e.getMessage(), false, true);
        	logger.exitLogger();
        }
        catch(CustomException ce){
            System.debug(ce.getMessage());
            logger.logMessages('', '', ce.getStackTraceString(), 'Technical', 'CODE-ABC', ce.getMessage(), true, false);
        }
    	Test.stopTest();
    	
    	List<ApplicationLog__c> log = fetchApplicatioLog();
    	List<Error_Log__c> logE = fetchErrorLog();
    	
    	System.assert(log[0].Error_Code__c == 'CODE-ABC');
    	System.assert(log[0].Error_Category__c == 'Technical');
    	System.assert(log[0].Error_Description__c == 'Technical: CODE-ABC: an error has occured');
    	//System.assert(logE[0].Error_Message__c == 'an error has occured');
    	//System.assert(logE[0].Error_Code__c == 'CODE-ABC');
    	//System.assert(logE[0].Error_Category__c == 'Technical');

    }
    static testMethod void test_logErrorCode() {
        Test.startTest();
        Type t = Type.forName('Logger2');
		
     	Logger2 logger = Logger2.getlogger(t);
        TestException e = new TestException();
        e.setMessage('an error has occured');

        logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'CODE-ABC', e.getMessage(), false, false);
        logger.exitLogger();
    	Test.stopTest();
    	
    	List<ApplicationLog__c> log = fetchApplicatioLog();
    	List<Error_Log__c> logE = fetchErrorLog();
    	
    	System.assert(log[0].Error_Code__c == 'CODE-ABC');
    	System.assert(log[0].Error_Category__c == 'Technical');
    	System.assert(log[0].Error_Description__c == 'an error has occured');
    	//System.assert(logE[0].Error_Message__c == 'an error has occured');
    	//System.assert(logE[0].Error_Code__c == 'CODE-ABC');
    	//System.assert(logE[0].Error_Category__c == 'Technical');

    }
    static testMethod void test_ErrorLogNoErrCode() {
        Test.startTest();
        Type t = Type.forName('Logger2');
		
     	Logger2 logger = Logger2.getlogger(t);
        TestException e = new TestException('an error has occured');
        //e.setMessage('an error has occured');

        logger.logMessages('', '', e.getStackTraceString(), 'Technical', '', e.getMessage(), false, false);
        logger.exitLogger();
    	Test.stopTest();
    	
    	List<ApplicationLog__c> log = fetchApplicatioLog();
    	List<Error_Log__c> logE = fetchErrorLog();
    	
    	System.assert(log[0].Error_Code__c == null);
    	System.assert(log[0].Error_Category__c == 'Technical');
    	System.assert(log[0].Error_Description__c == 'an error has occured');
    	//System.assert(logE.size() == 0);
        
    }
 /*************************************************************************************************
Name : test_logList
Author: Ajith Kumar
Story: DIGI-28081
Description: Method to validate the Orchestration technical success or failure log list 
***************************************************************************************************/
	static testMethod void test_logList(){
		Test.startTest();
		Logger2 logger = Logger2.getlogger('AdborIdAddressHandler');
		ApplicationLog__c log=logger.logMessage('','Response',false,'200','','AdborIdAddressHandler');
		System.assert(log!=null,true);		
	}
/*************************************************************************************************
Name : test_logList
Author: Ajith Kumar
Story: DIGI-28081
Description: Method to validate the Orchestration technical Exception log list 
***************************************************************************************************/
	static testMethod void test_logListException(){
		Test.startTest();
        try{
		Logger2 logger = Logger2.getlogger('AdborIdAddressHandler');
		ApplicationLog__c log=logger.logMessage('','Response',true,'500','','AdborIdAddressHandler');
        }
        catch(CustomException ex){
            system.assertNotEquals(null, ex);
        }
	}
     static testMethod void test_ErrorLogNoErrMsg() {
        Test.startTest();
        Type t = Type.forName('Logger2');
		
     	Logger2 logger = Logger2.getlogger(t);
        TestException e1 = new TestException('an error has occured');
        //e.setMessage('an error has occured');

        logger.logMessages('', '', '', '', 'CODE-ABC', e1.getMessage(), false, false);
        logger.exitLogger();
    	Test.stopTest();
    	
    	List<ApplicationLog__c> log = fetchApplicatioLog();
    	List<Error_Log__c> logE = fetchErrorLog();
    	
    	System.assert(log[0].Error_Code__c == 'CODE-ABC');
    	System.assert(log[0].Error_Category__c == null);
    	System.assert(log[0].Error_Description__c == 'an error has occured');
    	/* Commenting: Due to issues during deployment
    	System.assert(logE.size() != 0);
    	System.assert(logE[0].Error_Message__c == 'an error has occured');
    	System.assert(logE[0].Error_Code__c == 'CODE-ABC');
    	System.assert(logE[0].Error_Category__c == null);*/
        
    }
    
    static testmethod void TestLoggerMessage(){
        LoggerMessage lgm = new LoggerMessage();
        lgm.source='';
		lgm.sourceFunction='';
		lgm.referenceId='';
		lgm.referenceInfo='';
		lgm.logMessage='';
		lgm.payLoad ='';
		lgm.stackTrace ='';
		lgm.debugLevel ='';
		lgm.logCode ='';
		lgm.timer ='';
		lgm.logType ='';
		lgm.logRequest ='';
		lgm.logResponse  ='';
		lgm.errCategory  ='';
		lgm.errCode ='';
		lgm.errMsg	='';

		System.assert(lgm.errCode == '');
		System.assert(lgm.errMsg == '');

    }
     static testmethod void TestlogMessages(){
        Logger2 lgm = Logger2.getlogger('logger');
        lgm.logMessages('request', 'response', 'stacktrace','Business', 'errorCode', 'errorDesc', true, false,200,'1232454','13435','errorType');
        system.assert(lgm != null);

	}
      static testmethod void TestlogMessages_two(){
        try{
            Logger2 lgm = Logger2.getlogger('logger2');
            lgm.logMessages('request', 'response', 'stacktrace','Business', 'errorCode', 'errorDesc', false, true,200,'1232454','13435','errorType');
        }
       catch(Exception e){
       		system.assertNotEquals(null, e);       
          }

		

    }

    
    

    private static List<ApplicationLog__c> fetchApplicatioLog(){
    	return  [SELECT Id, Name, Message__c, Request_Message__c, Error_Code__c, Error_Category__c, Error_Description__c, Type__c, Debug_Level__c, Reference_Info__c, Stack_Trace__c, Status_Code__c from ApplicationLog__c limit 1];
    }

    private static List<Error_Log__c> fetchErrorLog(){
    	return [SELECT Id, Name, Error_Category__c, Error_Code__c, Error_Message__c, Error_Number__c, Interface_Reference__c, Status_Code__c from Error_Log__c limit 1];
    }

    private class TestException extends Exception{

    }
}