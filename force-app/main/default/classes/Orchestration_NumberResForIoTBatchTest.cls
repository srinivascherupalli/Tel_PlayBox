/**================================================================
* Infosys Ltd.
* Name: Orchestration_NumberResForIoTBatchTest
* Main Class : Orchestration_NumberReservForIoTBatch
* Created Date: December 8, 2020
* Created By: Vitap Ramdevputra
* =======================================================================================================================
  ChangeSet       No      Name                Date            Description  
  DIGI - 1003	  1		  Dharmik			  29-07-2021     Number Reservation for Shared Data Plans
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_NumberResForIoTBatchTest {
    
    public static List<ApplicationLog__c> appLog  = new List<ApplicationLog__c>();

    @Testsetup static void dataSetup(){

        ConstantMetadataUtility__mdt cSubs = new ConstantMetadataUtility__mdt();
        cSubs.MasterLabel = 'IoTSubscription';
        cSubs.DeveloperName = 'IoTSubscription';
        cSubs.value__c = 'IoT Subscription';
        
        ConstantMetadataUtility__mdt cPlan = new ConstantMetadataUtility__mdt();
        cPlan.MasterLabel = 'IoTPlans';
        cPlan.DeveloperName = 'IoTPlans';
        cPlan.value__c = 'IoT Plans';
        
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        list<csord__Solution__c> solutionListPlans= new list<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        list<Attachment> attachmentList= new list<Attachment>();
        //Record to create the number
        List<Number__c> numList = new List<Number__c>();
        List<cscfga__Product_Definition__c> productDefintions = new List<cscfga__Product_Definition__c>();
        List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 3);
        orderList[1].csord__Status2__c = OrchestratorConstants.OrderStatus.ReadyForSubmit;
        insert orderList;
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);

        productDefintions = Orchestration_TestUtility.buildProductDefination(false, 2);
        productDefintions[0].Name = cSubs.Value__c;
        productDefintions[1].Name = cPlan.Value__c;
        insert productDefintions;

        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='IOT Configuration';
        pcNewMdm.Type__c='New';
        pcNewMdm.ConfigurationType1__c = 'SolutionComponent';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.cscfga__Product_Definition__c = productDefintions[0].Id;
        insert pcNewMdm;

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = pcNewMdm.Id;
        insert  productconfiglistList;
       

        solutionList = Orchestration_TestUtility.buildSolution(true,2);        

        subscriptionList = Orchestration_TestUtility.buildSubscription(true,3,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
                
        servlist= Orchestration_TestUtility.buildService(true,3,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,pcNewMdm.id);
        //servlist[2].csordtelcoa__Replaced_Service__c = null;
        //insert servlist;

        numList = Orchestration_TestUtility.buildNumber(true, 3, productconfiglistList, 'serviceId1', 'subId1');
    
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[2].id;
    
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,3,processList);
        orchStepList[0].JSON__c = null;
        orchStepList[1].JSON__c = null;
        orchStepList[2].JSON__c = null;
        /* orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        */ 
        insert orchStepList;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false,3,servlist,productconfiglistList[0].id); 
        for(Attachment att : attachmentList){
            att.body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].Id+'","specifications":[{"attributes":{"__targetSystem":"FULFILMENT","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000966","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}');
        
        }
        insert attachmentList;
        appLog = Orchestration_TestUtility.buildApp(false, 3, orchStepList, processList);
        appLog[0].Related_Record_Id__c = subscriptionList[0].id;
        appLog[1].Related_Record_Id__c = subscriptionList[1].id;
        appLog[2].Related_Record_Id__c = subscriptionList[2].id;
        appLog[0].Reference_Info__c = 'SearchFNN';
        appLog[1].Reference_Info__c = 'SearchFNN';
        appLog[2].Reference_Info__c = 'SearchFNN';
        appLog[0].Status_Code__c = '200';
        appLog[1].Status_Code__c = '404';
        appLog[2].Status_Code__c = '404';
        String message = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMS-PARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}'; 
        appLog[0].Message__c = message;
        appLog[1].Message__c = message;
        appLog[2].Message__c = message;
        insert appLog;       
        
    }

    public static testmethod void processMethodTestSuccess(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        //Complete Success scenario
       
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Unreserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        //result=autoReserveObj.process(orchStepList);
        Boolean result1=autoReserveObj.performCallouts(orchStepList);
        result=autoReserveObj.process(orchStepList);
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    public static testmethod void processMethodTestSuccess2(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        //Complete Success scenario
       
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_Reserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        //result=autoReserveObj.process(orchStepList);
        Boolean result1=autoReserveObj.performCallouts(orchStepList);
        result=autoReserveObj.process(orchStepList);
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    // Added DIGI - 1003
    public static testmethod void processMethodTestSuccess2Plans(){

        ConstantMetadataUtility__mdt cPlan = new ConstantMetadataUtility__mdt();
        cPlan.MasterLabel = 'IoTPlans';
        cPlan.DeveloperName = 'IoTPlans';
        cPlan.value__c = 'IoT Plans';
        
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        list<csord__Solution__c> solutionListPlans= new list<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        list<Attachment> attachmentList= new list<Attachment>();
        //Record to create the number
        List<Number__c> numList = new List<Number__c>();
        List<cscfga__Product_Definition__c> productDefintions = new List<cscfga__Product_Definition__c>();
        List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();
        // governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 3);
        orderList[1].csord__Status2__c = OrchestratorConstants.OrderStatus.ReadyForSubmit;
        insert orderList;
        
        processTempList = [Select Id From CSPOFA__Orchestration_Process_Template__c Limit 1];

        productDefintions = Orchestration_TestUtility.buildProductDefination(false, 2);
        productDefintions[0].Name = cPlan.Value__c;
        productDefintions[1].Name = cPlan.Value__c;
        insert productDefintions;

        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='IOT Configuration';
        pcNewMdm.Type__c='New';
        pcNewMdm.ConfigurationType1__c = 'SolutionComponent';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.cscfga__Product_Definition__c = productDefintions[0].Id;
        insert pcNewMdm;

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = pcNewMdm.Id;        
        insert  productconfiglistList;
       

        solutionList = Orchestration_TestUtility.buildSolution(true,2);        

        subscriptionList = Orchestration_TestUtility.buildSubscription(true,3,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
                
        servlist= Orchestration_TestUtility.buildService(true,3,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,pcNewMdm.id);
        //servlist[2].csordtelcoa__Replaced_Service__c = null;
        //insert servlist;

        numList = Orchestration_TestUtility.buildNumber(true, 3, productconfiglistList, 'serviceId1', 'subId1');
    
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[2].id;
    
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,3,processList);
        orchStepList[0].JSON__c = null;
        orchStepList[1].JSON__c = null;
        orchStepList[2].JSON__c = null;
        /* orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        */ 
        insert orchStepList;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false,3,servlist,productconfiglistList[0].id); 
        for(Attachment att : attachmentList){
            att.body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].Id+'","specifications":[{"attributes":{"__targetSystem":"FULFILMENT","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000966","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}');
        
        }
        insert attachmentList;
        appLog = Orchestration_TestUtility.buildApp(false, 3, orchStepList, processList);
        appLog[0].Related_Record_Id__c = subscriptionList[0].id;
        appLog[1].Related_Record_Id__c = subscriptionList[1].id;
        appLog[2].Related_Record_Id__c = subscriptionList[2].id;
        appLog[0].Reference_Info__c = 'SearchFNN';
        appLog[1].Reference_Info__c = 'SearchFNN';
        appLog[2].Reference_Info__c = 'SearchFNN';
        appLog[0].Status_Code__c = '200';
        appLog[1].Status_Code__c = '404';
        appLog[2].Status_Code__c = '404';
        String message = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMS-PARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}'; 
        appLog[0].Message__c = message;
        appLog[1].Message__c = message;
        appLog[2].Message__c = message;
        insert appLog;

        List<CSPOFA__Orchestration_Step__c> orchStepList1 = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList1 = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        //Complete Success scenario
       
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_Reserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        //result=autoReserveObj.process(orchStepList1);
        Boolean result1=autoReserveObj.performCallouts(orchStepList1);
        result=autoReserveObj.process(orchStepList1);
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    public static testmethod void processMethodTestSuccess3(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        //Complete Success scenario
       
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Reserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        //result=autoReserveObj.process(orchStepList);
        Boolean result1=autoReserveObj.performCallouts(orchStepList);
        result=autoReserveObj.process(orchStepList);
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    

    public static testmethod void performCallouts204(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
      
        List<sObject> result = new List<sObject>();
        
        //Complete Success scenario
        
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Unreserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    }
     //Error scenario 422
     @isTest
    public static void performCalloutsTestError(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
      
        List<sObject> result = new List<sObject>();
        
        Test.startTest();
        
        String handler = 'SearchFNN';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Error422'));
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    
    }
    
    public static testmethod void performCalloutsTestPartialNonLog(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<Number__c> numList = new List<Number__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        servlist = [SELECT Id,csordtelcoa__Service_Number__c FROM csord__Service__c];
        numList = [SELECT Id, Service_Id__c FROM Number__c];
        for(Number__c num : numList){
            num.Service_Id__c = servlist[0].csordtelcoa__Service_Number__c;
        }
        update numList;
        List<sObject> result = new List<sObject>();
        
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Unreserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
        
    }
    //Partial success
    @isTest
    public static void performCalloutsTestPartialSuccess(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<Number__c> numList = new List<Number__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        servlist = [SELECT Id,csordtelcoa__Service_Number__c FROM csord__Service__c];
        numList = [SELECT Id, Service_Id__c FROM Number__c];

        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];

        appLog = Orchestration_TestUtility.buildApp(false, 1, orchStepList, processList);
        appLog[0].Related_Record_Id__c = '1-1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '404';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMS-PARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
        for(Number__c num : numList){
            num.Service_Id__c = servlist[0].csordtelcoa__Service_Number__c;
        }
        update numList;
        List<sObject> result = new List<sObject>();
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Reserve'));
        Test.startTest();
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    //Partial success
    @isTest
    public static void performCalloutsTestPartialSuccess2(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<Number__c> numList = new List<Number__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        servlist = [SELECT Id,csordtelcoa__Service_Number__c FROM csord__Service__c];
        numList = [SELECT Id, Service_Id__c FROM Number__c];

        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];

        appLog = Orchestration_TestUtility.buildApp(false, 1, orchStepList, processList);
        appLog[0].Related_Record_Id__c = '1-1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '200';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":2,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
        for(Number__c num : numList){
            num.Service_Id__c = servlist[0].csordtelcoa__Service_Number__c;
        }
        update numList;
        List<sObject> result = new List<sObject>();
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_ReserveUNMS'));
        Test.startTest();
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    //Partial success
    @isTest
    public static void performCalloutsTestPartialSuccess3(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<Number__c> numList = new List<Number__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        servlist = [SELECT Id,csordtelcoa__Service_Number__c FROM csord__Service__c];
        numList = [SELECT Id, Service_Id__c FROM Number__c];

        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];

        appLog = Orchestration_TestUtility.buildApp(false, 1, orchStepList, processList);
        appLog[0].Related_Record_Id__c = '1-1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '200';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMS-PARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":2,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
        for(Number__c num : numList){
            num.Service_Id__c = servlist[0].csordtelcoa__Service_Number__c;
        }
        update numList;
        List<sObject> result = new List<sObject>();
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_ReserveUNMS'));
        Test.startTest();
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    }

    
    //Attachment is false
    @isTest
    public static void attachmentFalseTest(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<Number__c> numList = new List<Number__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        servlist = [SELECT Id,csordtelcoa__Service_Number__c FROM csord__Service__c];
        numList = [SELECT Id, Service_Id__c FROM Number__c];

        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];
        List<cscfga__Product_Configuration__c > productconfiglistList = [select id, name from cscfga__Product_Configuration__c];
		
        appLog = Orchestration_TestUtility.buildApp(false, 1, orchStepList, processList);
        appLog[0].Related_Record_Id__c = '1-1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '200';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":2,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
       List<attachment> attachmentList = Orchestration_TestUtility.buildAttachment(false,3,servlist,productconfiglistList[0].id); 
        for(Attachment att : attachmentList){
            att.body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].Id+'","spy":[{"attributes":{"__targetSystem":"FULFILMENT","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000966","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}');
        
        }
        insert attachmentList;
        
        for(Number__c num : numList){
            num.Service_Id__c = servlist[0].csordtelcoa__Service_Number__c;
        }
        update numList;
        List<sObject> result = new List<sObject>();
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Partial200'));
        Test.startTest();
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        
        result=autoReserveObj.process(orchStepList);
        
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    //PENDING from here for ASYNC methods.
     // Limits got hit
    static testMethod void breakingLimits(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        List<SObject> result = autoReserveObj.process(orchStepList);
        
       System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
    
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        List<SObject>  result=autoReserveObj.process(orchStepList);
        System.assert(result != null);
        Test.stopTest();
    }
    
    static testMethod void breakingLimitsDML1(){
        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_ReserveUNMS'));
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        List<SObject>  result=autoReserveObj.process(orchStepList);
        System.assert(result != null);
        Test.stopTest();
    }
    static testMethod void nonOrderPerformCallout(){

        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;

        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];
        
        for(CSPOFA__Orchestration_Process__c process : processList) {

            process.Order__c = null;
        }

        update processList;

        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
         Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        List<CSPOFA__Orchestration_Step__c>  result=autoReserveObj.process(orchStepList);
        System.assertEquals(result[0].CSPOFA__Message__c, 'Error: Steps do not have Orders');
        Test.stopTest();
    }

    static testMethod void breakingLimitsDMLAppLog(){
        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id FROM CSPOFA__Orchestration_Process__c];

        appLog = Orchestration_TestUtility.buildApp(false, 1, orchStepList, processList);
        appLog[0].Related_Record_Id__c = '1-1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '404';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMS-PARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_ReserveUNMS'));
        Test.startTest();
        Orchestration_NumberReservForIoTAsync numResIOT = new Orchestration_NumberReservForIoTAsync();
        List<SObject> result = numResIOT.process(orchStepList);
        System.assert(result != null);
        Test.stopTest();
    }


    static testMethod void breakingLimit204(){
        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('success_Search'));
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        Orchestration_NumberReservForIoTAsync numResIOT = new Orchestration_NumberReservForIoTAsync();
        List<SObject> result = numResIOT.process(orchStepList);
        System.assert(result != null);
        
        Test.stopTest();
    }

    static testMethod void breakingLimit400(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Error'));
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        Orchestration_NumberReservForIoTAsync numResIOT = new Orchestration_NumberReservForIoTAsync();
        List<SObject> result = numResIOT.process(orchStepList);
        System.assert(result != null);
          
        Test.stopTest();
    }
    
   // log.Message__c = OrchestratorConstants.SystemConstant.AttachmentMsg;
    public static testmethod void performCalloutsAttachment(){
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<ApplicationLog__c> appLog  = new List<ApplicationLog__c>();
        orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        appLog = [SELECT Message__c FROM ApplicationLog__c];
        for(ApplicationLog__c  log : appLog){
            log.Message__c = OrchestratorConstants.SystemConstant.AttachmentMsg;
        }
        update appLog;
        List<sObject> result = new List<sObject>();       
        //Complete Success scenario       
        Test.startTest();
        String handler = 'SearchFNN';
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockNumberReserveForIoT('Unreserve'));
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        
        Orchestration_NumberReservForIoTAsync autoReserveObj = new Orchestration_NumberReservForIoTAsync();
        result = autoReserveObj.process(orchStepList);
        System.assert(result != null); 
        
        Test.stopTest();        
        
    }
  
}