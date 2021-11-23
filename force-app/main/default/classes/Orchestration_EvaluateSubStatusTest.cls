/**================================================================
* Appirio, Inc
* Name: Orchestration_EvaluateSubStatusTest
* Main Class : Orchestration_EvaluateSubscriptionStatus
* Created Date: June 21, 2020
* Created By: Shweta Khandelwal
1.      Pawan Devaliya              14/09/2020    EDGE-164355
2.      Pooja                       25-11-2020    EDGE-180743
3.		Gnana	    			    08-06-2021	  EDGE-222326 : Modified assert to check for empty list instead of null
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_EvaluateSubStatusTest {
    @Testsetup
    static void dataSetup() {
     // List declartion for various objects to create data
      List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
      List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
      List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
      List<account> accountList = new List<account>();
        list<Attachment> attachmentList = new List<Attachment>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
      List<csord__Service__c> servlist = new List<csord__Service__c>();
      Governor_Limits__c governerLimit = new Governor_Limits__c();
      List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
      List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
      List<Opportunity> oppList = new List<Opportunity>();
      FCR_Settings__c fcr = new FCR_Settings__c();
      List<Contact> conList = new List<Contact>();
      List<Number__c> numList  = new List<Number__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        oppList =  Orchestration_TestUtility.buildOpp(false,1,accountList);
        insert oppList;  

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 14);
        insert orderList;
         
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        prdList = Orchestration_TestUtility.buildProductDefination(true,1);
         
        offerList = Orchestration_TestUtility.buildMarkertableOffer(false,1); 
        offerList[0].Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true,"isConsumptionBasedCharge":true}';  
        insert offerList;
         
        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c='Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;   
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;
         
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id; 
        productconfiglistList[0].Type__c ='Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c =pcNewMdm.id; 
        productconfiglistList[1].ConfigurationType1__c = 'ProductComponent'; 
        insert productconfiglistList;  

        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        
        csord__Subscription__c leagcySub = new csord__Subscription__c();
        leagcySub.Name = 'legacySubscription';
        leagcySub.csord__Order__c = orderList[1].id; 
        leagcySub.csord__Identification__c = 'IDE1322';
        leagcySub.triggerBill_RTB__c = false;
        insert leagcySub; 

        csord__Subscription__c leagcySub1 = new csord__Subscription__c();
        leagcySub1.Name = 'legacySubscription1';
        leagcySub1.csord__Order__c = orderList[1].id; 
        leagcySub1.csord__Identification__c = 'IDE13222';
        insert leagcySub1; 

        subscriptionList = Orchestration_TestUtility.buildSubscription(false,14,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
        subscriptionList[1].legacy_subscription__c = leagcySub.Id;
        subscriptionList[0].legacy_subscription__c = leagcySub.Id;
        subscriptionList[0].MarketableOffer__c = offerList[0].Id;
        subscriptionList[1].MarketableOffer__c = offerList[0].Id;
        subscriptionList[2].MarketableOffer__c = offerList[0].Id;
        subscriptionList[0].Suspension_reason__c = 'Requested by';
        subscriptionList[2].Suspension_reason__c = 'Requested by';
        subscriptionList[3].changeType__c = 'Resume';//EDGE-180743 
        subscriptionList[3].legacy_subscription__c = leagcySub1.Id;
        subscriptionList[3].MarketableOffer__c = offerList[0].Id;
        subscriptionList[3].Suspension_reason__c = 'Requested by';
        subscriptionList[10].MarketableOffer__c = offerList[0].Id; 
         
        for(csord__Subscription__c sub : subscriptionList) {
          sub.csord__Status__c = 'Provisioned';
        }
        subscriptionList[9].csord__Status__c = null;
        insert subscriptionList;
         
        servlist= Orchestration_TestUtility.buildService(false,14,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; 
        servlist[1].csord__Subscription__c = subscriptionList[2].id; // with the same sub as service 2
        servlist[2].csord__Subscription__c = subscriptionList[2].id; // with the same sub as service 1
         for(integer i=3; i<10; i++){ 
           servlist[i].csord__Subscription__c = subscriptionList[i].id; 
         }
        servlist[0].csord__Status__c = 'In Progress';
        servlist[1].csord__Status__c = 'Cancellation In Progress';
        servlist[2].csord__Status__c = 'Cancellation In Progress';
        servlist[3].csord__Status__c = 'Failed';
        servlist[4].csord__Status__c = 'Connected'; 
        servlist[5].csord__Status__c = 'Disconnected'; 
        servlist[6].csord__Status__c = 'Cancelled'; 
        servlist[7].csord__Status__c = 'Cancelled'; 
        servlist[8].csord__Status__c = 'Disconnected'; 
        servlist[9].csord__Status__c = 'Failed';
        servlist[10].csord__Status__c = 'Disconnected';
        servlist[11].csord__Status__c = 'Connected';
        servlist[12].csord__Status__c = 'Cancelled';
        servlist[10].csord__Subscription__c = subscriptionList[10].id;
        servlist[11].csord__Subscription__c = subscriptionList[10].id;
        servlist[12].csord__Subscription__c = subscriptionList[10].id;   
        insert servlist; 
        
        numList =  Orchestration_TestUtility.buildNumber(true,1,productconfiglistList,'serviceId1','subId1');
        
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 14, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        for(integer i = 0; i<13; i++){
           processList[i].csordtelcoa__Service__c = servlist[i].id;
        }
         processList[13].csordtelcoa__Service__c = null;
        insert processList;
         
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,13,processList);
        for(CSPOFA__Orchestration_Step__c step :orchStepList){
             step.JSON__C = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        }
        insert orchStepList;
     }
     // Subscription status updation
    static testMethod void ProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        // Query data from datasetup 
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
            
        Orchestration_EvaluateSubscriptionStatus evaluateSubscriptionStatus = new Orchestration_EvaluateSubscriptionStatus();
        orchStepList = evaluateSubscriptionStatus.process(orchStepList);
        
        // Query after process call
        List<csord__Subscription__c> subList = [SELECT Id, csord__Status__c, Sub_Status__c FROM csord__Subscription__c WHERE Suspension_reason__c != null AND Suspension_reason__c = 'Requested by'];
        
       // Assert to check subscription status
        System.assertEquals('Success: Records processed', orchStepList[0].CSPOFA__Message__c);
        System.assertEquals(subList[0].csord__Status__c, 'Suspended');
        System.assertEquals(subList[0].Sub_Status__c, 'Suspended');
        
        Test.stopTest();
    }
    // Where process service is Null
    static testMethod void ProcessTestServiceNull() {
       // Query data from datasetup 
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        CSPOFA__Orchestration_Process__c process = [SELECT id, csordtelcoa__Service__c FROM CSPOFA__Orchestration_Process__c WHERE id = :orchStepList[0].CSPOFA__Orchestration_Process__c];
        process.csordtelcoa__Service__c = null;
        
        update process; // updation for further process
        Test.startTest();

        Orchestration_EvaluateSubscriptionStatus evaluateSubscriptionStatus = new Orchestration_EvaluateSubscriptionStatus();
        orchStepList = evaluateSubscriptionStatus.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
      // Where process SubUpdate status is Provisioned
    static testMethod void ProcessTestProvisioned() {
      // Query data from datasetup 
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];

        List<csord__Subscription__c> subList = [SELECT Id, csord__Status__c, Sub_Status__c, Suspension_reason__c, Is_Bill_Stopped__c FROM csord__Subscription__c];
        for(csord__Subscription__c sub : subList){
            sub.Suspension_reason__c = null;
            sub.Is_Bill_Stopped__c = false;
            sub.legacy_subscription__c = null;
            sub.csord__Status__c = 'Inactive';
        }
        update subList;
        
        List<csord__Service__c> servList = [SELECT id, csord__Status__c FROM csord__Service__c];
        for(csord__Service__c ser : servList){
            ser.csord__Status__c = 'Disconnected';
        }
        update servList; // updation for further process
        Test.startTest();
        Orchestration_EvaluateSubscriptionStatus evaluateSubscriptionStatus = new Orchestration_EvaluateSubscriptionStatus();
        orchStepList = evaluateSubscriptionStatus.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
  static testMethod void breakingLimitsInStart(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Query data from datasetup
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit; // updation for further process
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_EvaluateSubscriptionStatus evaluateSubscriptionStatus = new Orchestration_EvaluateSubscriptionStatus();
        orchStepList = evaluateSubscriptionStatus.process(orchStepList);
      	
        //boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(orchStepList.isEmpty(), true); // EDGE-222326 : Modified assert to check for empty list instead of null 
        Test.stopTest();
    }
    
  static testMethod void getSubscriptionStatusTest(){
      
      Map<String,String> statusMap = new Map<String,String>();
      
      Orchestration_EvaluateSubscriptionStatus oE = new Orchestration_EvaluateSubscriptionStatus();
      
      csord__Service__c service = [SELECT Id, csord__Subscription__r.csord__Status__c, csord__Status__c, csordtelcoa__Service_Number__c,Action_Type__c, Name, csord__Order__c,csord__Order__r.name  from csord__Service__c  limit 1];
      
      service.csord__Status__c = 'Cancellation In Progress'; 
      update service;
      
      List<csord__Service__c> services = new List<csord__Service__c>();
      services.add(service);
      
      oE.getSubscriptionStatus(services, 'false', false, false);
      
      service.csord__Status__c = 'Failed'; 
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'false', false, false);
      
      service.csord__Status__c = 'Connected'; 
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'false', false, true);  

      service.csord__Status__c = 'Connected'; 
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'false', false, false);

      service.csord__Status__c = 'Cancelled'; 
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'false', false, false);      
      
      
      service.csord__Status__c = 'Disconnected'; 
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'true', false, false); 
      
      service.csord__Status__c = 'Disconnected';
      service.Action_Type__c = 'PayOut';      
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'true', false, false);

      service.csord__Status__c = 'Disconnected';
      service.Action_Type__c = 'PayOut';      
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      statusMap = oE.getSubscriptionStatus(services, 'true', true, false);
      
      System.assertNotEquals(statusMap.get('status'),null);

      service.csord__Status__c = 'Connected';
      service.Action_Type__c = 'PayOut';      
      update service; 
      services = new List<csord__Service__c>();
      services.add(service);      
      oE.getSubscriptionStatus(services, 'false', false, false);    
  
  }   
  //EDGE-164355
      static testMethod void setTriggeRTSOnSubsTest(){
          Orchestration_EvaluateSubscriptionStatus OE = new Orchestration_EvaluateSubscriptionStatus();
          List<csord__Service__c> services = [select id, name,csord__Service__c,toBeCancelled__c,csord__Subscription__r.Trigger_RTS__c, csord__Status__c, csord__Subscription__c, csord__Order__r.name, csord__Order__c,Action_Type__c From csord__Service__c Where toBeCancelled__c ='true' limit 1];
          
          csord__Subscription__c sub = [SELECT Id, csord__Status__c,Trigger_RTS__c,toBeCancelled__c FROM csord__Subscription__c  WHERE id =: services[0].csord__Subscription__c LIMIT 1];
          sub.csord__Status__c = 'Provisioning In Progress';
          sub.Trigger_RTS__c = false;
          update sub;
          
          services[0].Action_Type__c = 'PayOut';
          services[0].csord__Service__c = null;
          update services;
          boolean isTriggerRTSTrue = false;
          
          isTriggerRTSTrue = OE.setTriggeRTSOnSubs(services);
    

          System.assertEquals(isTriggerRTSTrue, true);
          
      }
      
  //EDGE-177027
      static testMethod void svcSubsClosedStatusTest(){
          Orchestration_EvaluateSubscriptionStatus oE = new Orchestration_EvaluateSubscriptionStatus();
          List<csord__Service__c> servicesUpdated = new List<csord__Service__c>(); 
          csord__Subscription__c sub = [SELECT Id, csord__Status__c,Trigger_RTS__c,toBeCancelled__c FROM csord__Subscription__c LIMIT 1];
          
          List<csord__Service__c> services = [select id, name,csord__Service__c,toBeCancelled__c,csord__Subscription__r.Trigger_RTS__c, csord__Status__c, csord__Subscription__c, csord__Order__r.name, csord__Order__c,Action_Type__c From csord__Service__c Where csord__Subscription__c =: sub.Id];
          
          for(csord__Service__c svc : services){
              svc.csord__Status__c = 'Closed';
              servicesUpdated.add(svc);
          }        
          update servicesUpdated;
          Map<String,String> statusMap = oE.getSubscriptionStatus(servicesUpdated, 'false', false, false);  
            System.assertNotEquals(statusMap.get('status'), null);

  //EDGE-177027
    }
      

}