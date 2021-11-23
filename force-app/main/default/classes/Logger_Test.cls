/***************************************************************************
Class Name:  Logger_Test
Description: This class is Test Class for Logger Class.
Author:      Anuja Parashar Pandey
Version:     Created             Modified
             3/11/2016
Status: Development in Progress
****************************************************************************/

@IsTest
public class Logger_Test {

    static testMethod void DebuggingTestPositive() {
        Type t = Type.forName('Logger');
		Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c= true);
        insert ec;
        Exception enull = null;
       
        Logger.getlogger(t);//Calling Logger Constructor
		Logger log= Logger.getlogger('Test Logger');//Calling Logger Constructor
 		//Calling Logger Method 
         Logger.exitLogger();
      	 log.debug('Debug Message');
       	 log.debug('Debug Message',true);
		 log.logforAsync('LOG','DEBUG' , 'Debug Message',null,true);//calling logforAsync method
		 Logger.logUserMessage('Logger','LOG', 'DEBUG' , 'Debug Message',null,true,true);//calling logUserMessage method
		 Logger.logUserMessage('Logger','LOG', 'DEBUG' , 'Debug Message',null,true);//calling logUserMessage method
         log.logRequest('Request Message');
         log.logRequest('Request Message',true);
         log.logResponse('Json Response');
       	 log.logResponse('Json Response',true);
        try{
         log.debug(enull);
        }
        catch(exception e){
           log.debug(e); 
        }
        System.assert(log != null); 
}
 
    static testMethod void DebuggingTestNegative() {
        Type t = Type.forName('Logger');
		Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c= true);
        insert ec;
        Exception enull = null;
     	Logger.getlogger(t);//Calling Logger Constructor
        Logger log= Logger.getlogger('LoggerTest');//Calling Logger Constructor
     //Calling Logger Method 
        Logger.exitLogger();
      	 log.debug('Debug Message');
       	 log.debug('Debug Message',False);
		 log.logforAsync('LOG','DEBUG' , 'Debug Message',null,false);
		 Logger.logUserMessage('Logger','LOG', 'DEBUG' , 'Debug Message',null,false,true);
		 Logger.logUserMessage('Logger','LOG', 'DEBUG' , 'Debug Message',null,false);
         log.logRequest('Request Message');
         log.logRequest('Request Message',False);
         log.logResponse('Json Response');
       	 log.logResponse('Json Response',False);
        try{
         log.debug(enull);
        }
        catch(exception e){
           log.debug(e); 
        }
        System.assert(log != null); 
   }
    
//This method needs to be modified for correct assertion.
      private static testmethod void LoggerDebug()
    {
       
        List<ApplicationLog__c> appLOgList= new List<ApplicationLog__c>();
            
        	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        	User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         					   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         					   LocaleSidKey='en_US', ProfileId = p.Id, 
         					   TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorgtelstra.com');

      System.runAs(u1) 
      {
       appLogList=[select Id, Name,Reference_Info__c,Debug_Level__c,Message__c,Stack_Trace__c,User__c,Timer__c from 
                       ApplicationLog__c where Reference_Info__c IN ('Test Logger','LoggerTest')];
          
            
            if(!appLogList.isEmpty())
            {
                for(ApplicationLog__c applog:appLogList )
                {
                    if(appLog.Reference_Info__c=='Test Logger')
                    {
                        System.assertEquals('DEBUG', appLog.Debug_Level__c);
                        System.assertNotEquals(null, appLog.Type__c);
                        System.assert(appLog.Type__c==null);
                        System.assert(appLog.CreatedById==u1.id);
                    }
                    
                    if(appLog.Reference_Info__c=='LoggerTest')
                    {
                        System.assertEquals('DEBUG', appLog.Debug_Level__c);
                    }
                }
        }
      }
      //calling commitTransaction method which in turn calls @future method insertAppLogList
	  Test.starttest();
		Logger.commitTransaction(appLogList);
	  Test.stoptest();
}
    
    static testmethod void TestLoggerMessage(){
        LoggerMessage lgm = new LoggerMessage();
        
        lgm.source ='';
        lgm.sourceFunction ='';
        lgm.referenceId ='';
        lgm.referenceInfo ='';
        lgm.logMessage ='';
        lgm.payLoad ='';
        lgm.stackTrace ='';
        lgm.debugLevel ='';
        lgm.logCode ='';
        lgm.timer ='';
        lgm.logType ='';
        System.assert(lgm != null);
    }
}