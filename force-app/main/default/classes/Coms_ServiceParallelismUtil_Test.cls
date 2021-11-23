/**================================================================
* Name: Coms_ServiceParallelismUtil_Test
* Main Class : Coms_ServiceParallelismUtil
* Created Date:  
* Created By: 
==================================================================*/
@isTest(SeeAllData=false)
public class Coms_ServiceParallelismUtil_Test {
@Testsetup
    static void dataSetup() {
     // List declartion for various objects to create data
     
      List<account> accountList = new List<account>();
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        list<Attachment> attachmentList = new List<Attachment>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
      List<csord__Service__c> servlist = new List<csord__Service__c>();
     
      List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
      List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
      List<Opportunity> oppList = new List<Opportunity>();
     
      List<Contact> conList = new List<Contact>();
      List<Number__c> numList  = new List<Number__c>();

        //Build Data to Perform Actions on
     
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        oppList =  Orchestration_TestUtility.buildOpp(false,1,accountList);
        insert oppList;  

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 4);
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

        subscriptionList = Orchestration_TestUtility.buildSubscription(false,4,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
        subscriptionList[1].legacy_subscription__c = leagcySub.Id;
        subscriptionList[0].legacy_subscription__c = leagcySub.Id;
        subscriptionList[0].MarketableOffer__c = offerList[0].Id;
        subscriptionList[1].MarketableOffer__c = offerList[0].Id;        
      //  subscriptionList[0].Suspension_reason__c = 'Requested by';        
         subscriptionList[0].changeType__c='Resume';
        
        for(csord__Subscription__c sub : subscriptionList) {
          sub.csord__Status__c = 'Provisioned';
        }
       
        insert subscriptionList;
         
        servlist= Orchestration_TestUtility.buildService(false,4,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;       
        servlist[1].csord__Subscription__c = subscriptionList[1].id; // with the same sub as service 2
      //  servlist[2].csord__Subscription__c = subscriptionList[1].id; // with the same sub as service 1
        
        servlist[0].csord__Status__c = 'In Progress';
        servlist[1].csord__Status__c = 'Cancellation In Progress';
        servlist[2].csord__Status__c = 'Failed';
        servlist[3].csord__Status__c = 'Disconnected'; 
           
        insert servlist; 
        
        numList =  Orchestration_TestUtility.buildNumber(true,1,productconfiglistList,'serviceId1','subId1');
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
       /* for(integer i = 0; i<=3; i++){
           processList[i].csordtelcoa__Service__c = servlist[i].id;
        }*/
        // processList[3].csordtelcoa__Service__c = null;
        insert processList;
         
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,3,processList);
        for(CSPOFA__Orchestration_Step__c step :orchStepList){
             step.JSON__C = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        }
        insert orchStepList;
           
     }
    @isTest
    static void ProcessTest() {
        //get data for processing
        String str='';
        Map<String,Object>payloadMap=new Map<String,Object>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> serviceIds = new List<Id>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Order__c FROM CSPOFA__Orchestration_Step__c];
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c != null) {
                serviceIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);                 
            }
        }
        
       /* List<csord__Subscription__c>subList=[SELECT ID,csord__Order__c,csord__Account__r.Customer_Status__c FROM csord__Subscription__c LIMIT 2];
        for(csord__Subscription__c subId: subList){
            subscriptionIds.add(subId.Id);
             Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(subId.csord__Order__c, false);
            system.debug('SubscriptionIds### '+subId.csord__Account__r.Customer_Status__c);
        }*/
       // serviceIds.add(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);
       Coms_PlatformCacheUtil.insertServicesToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c);
        Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Order__c);
        payloadMap.put('StepId',orchStepList[0].Id);
        payloadMap.put('serviceIds',serviceIds);
        payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
        str=(String)JSON.serialize(payloadMap);
        system.debug('Str### '+str);
        System.Test.startTest();        
        Coms_ServiceParallelismUtil.process(str,'Service Fulfilment Process_New',3);        
        System.Test.stopTest();

        
       // System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
}