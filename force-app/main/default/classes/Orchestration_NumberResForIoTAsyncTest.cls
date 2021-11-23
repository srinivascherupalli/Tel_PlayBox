/**================================================================
* Infosys Ltd.
* Name: Orchestration_NumberResForIoTAsyncTest
* Main Class : Orchestration_NumberReservForIoTAsync
* Created Date: December 8, 2020
* Created By: Vitap Ramdevputra
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_NumberResForIoTAsyncTest {
    
    public static List<ApplicationLog__c> appLog  = new List<ApplicationLog__c>();

    @Testsetup static void dataSetup(){

        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
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

        productDefintions = Orchestration_TestUtility.buildProductDefination(false, 1);
        productDefintions[0].Name = System.Label.IoTSubscription;
        insert productDefintions;

        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='Enterprise Mobility Managed Service';
        pcNewMdm.Type__c='New';
        pcNewMdm.ConfigurationType1__c = 'SolutionComponent';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.cscfga__Product_Definition__c = productDefintions[0].Id;
        insert pcNewMdm;


        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = pcNewMdm.Id;
        insert  productconfiglistList;
       
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
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
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false,2,servlist,productconfiglistList[0].id); 
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
        String message = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMSPARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}'; 
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
        result = autoReserveObj.process(orchStepList);
        
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
    
     public static testmethod void processMethodCatch1(){

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
    List<Number__c> numList = new List<Number__c>();
        //orchStepList = [SELECT ID,CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
        //                FROM CSPOFA__Orchestration_Step__c];
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
        appLog[0].Related_Record_Id__c = '1';
        appLog[0].Reference_Info__c = 'SearchFnn';
        appLog[0].Status_Code__c = '404';
        appLog[0].message__c = '{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMSPARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        insert appLog;
        
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
        Orchestration_NumberReservForIoTAsync numResIOT = new Orchestration_NumberReservForIoTAsync();
        numResIOT.process(orchStepList);
       System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
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
    
    // Where opp is not associated with order
    static testMethod void ProcessTestOrderNull() {
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    List<Id> subscriptionIds = new List<Id>();
    // Query form datasetup
    List<CSPOFA__Orchestration_Process__c> oppProcessList = [SELECT id FROM CSPOFA__Orchestration_Process__c];
    Integer i = 0;
    for (CSPOFA__Orchestration_Process__c oppProcess : oppProcessList) {
      oppProcess.Order__c = null;
      i++;
      if (i == 1)
        break;
    }
    update oppProcessList; // updation for further process
    System.debug('ordList ' + oppProcessList);
    orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

    Test.startTest();
    Orchestration_NumberReservForIoTAsync numResv = new Orchestration_NumberReservForIoTAsync();
    orchStepList = numResv.process(orchStepList);
    // Assert to check message status
    System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Error: Steps do not have Orders');
    Test.stopTest();
  }

/*  
  // Where opp is not associated with order
    static testMethod void ProcessTestwithAlreadyProcessed() {
    List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    List<Id> subscriptionIds = new List<Id>();
    // Query form datasetup

    orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

    List<csord__Service__c> serviceList = [SELECT ID FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c];
    List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId IN :serviceList];
    System.debug('Attachment List' + attList);
    Governor_Limits__c governerLimit = new Governor_Limits__c();
    governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
    governerLimit.DML_Rows_limit__c = '3';
    update governerLimit;
    Orchestration_ProcessedRecords processRecords = new Orchestration_ProcessedRecords();
    processRecords.skipRecordsIds = new Set<String>();
    processRecords.attachmentIds = new Set<String>();
    for (Attachment att : attList) {
      //processRecords.skipRecordsIds.add(att.Id);
      processRecords.attachmentIds.add(att.Id);
      break;
    }
    for (CSPOFA__Orchestration_Step__c step : orchStepList) {
      step.json__c = JSON.serialize(processRecords);
    }
    update orchStepList;
    Test.startTest();
    System.debug('Inside ProcessTestwithAlreadyProcessed method ==> ');
    Orchestration_NumberReservForIoTAsync numResv = new Orchestration_NumberReservForIoTAsync();
    orchStepList = numResv.process(orchStepList);
    System.debug('orchStepList ==> ' + orchStepList);
    // Assert to check message status
    System.assert(orchStepList[0].CSPOFA__Message__c.contains('Waiting: Batch Job is in progress.'));
    Test.stopTest();
  }*/
  
}