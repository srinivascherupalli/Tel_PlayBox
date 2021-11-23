/*
Class Name    : ReactivateMSISDN
Desription    : Enhance mobile number reservation to process number state transition from held order to reserved before Sales Order submission to Service Order Manager
Test Class    : ReactivateMSISDNTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil        05/12/19         EDGE-118965              
===========================================================================================*/
public with sharing class ReactivateMSISDN {
 @InvocableMethod
     public static void calloutToMSISDN(List<String> param){
         Logger2 logger = Logger2.getLogger('HeldToReserveMSISDNHandler');
      try{
          
          MSISDNReserveServiceHandler ms = new  MSISDNReserveServiceHandler();
          List<String> mobileList = new List<String>();
          List<csord__Service__c> serviceList = [select id,csord__Order__c,serviceMSISDN__c from csord__Service__c where csord__Order__c IN:param AND serviceMSISDN__c!=null ];
          if(serviceList!=null){
          for(csord__Service__c ser : serviceList){
             //system.debug('mobileNumber::'+ser.serviceMSISDN__c);
              mobileList.add(ser.serviceMSISDN__c);}        
            }
          
             processMSISDNListing(mobileList);
           }catch(Exception e){     logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
      
      }
          
          
          
         @future
        public static void processMSISDNListing(List<String> mobileList)
        {
           ReactivateMSISDNService MSISDNJob =null;
           MSISDNJob = new ReactivateMSISDNService(mobileList);
          if(Limits.getQueueableJobs() == 1){
                System.schedule('ScheduledJob ' + String.valueOf(Math.random()), String.valueOf(String.valueOf(Datetime.now().second() + 5) + ' ' + String.valueOf(Datetime.now().minute()) + ' ' + String.valueOf(Datetime.now().hour()) + ' * * ?'), new CreateMSISDNSchedulable(MSISDNJob));
            }else{
                System.enqueueJob(MSISDNJob);
            }
            system.debug('Limit::'+Limits.getLimitQueueableJobs());
          
        }
      
         
}