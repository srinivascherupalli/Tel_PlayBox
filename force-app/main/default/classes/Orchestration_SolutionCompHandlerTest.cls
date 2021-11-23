/**================================================================
 * Appirio, Inc
 * Name: Orchestration_SolutionCompletionHandlerTest
 * Class: Orchestration_SolutionCompletionHandler
 * Created Date: June 25, 2020
 * Created By: Ankit Birla
 ==================================================================*/

 
@isTest
public class Orchestration_SolutionCompHandlerTest {
    public static List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();
     //Orchestration Processes list
    public static List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();

    @Testsetup
    static void dataSetup() {
        //Record to create the Custom Settings with Custom Limits
     Governor_Limits__c governerLimit = new Governor_Limits__c();
     //List of Accounts for order
      List<account> accountList = new List<account>();
     //Process Templates for Processes
      List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
     //Order request on Order
      List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
     //List of Subscription
     List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
     //Service List
      List<csord__Service__c> servlist = new List<csord__Service__c>();
     // List of Orders
      List<csord__Order__c> orderList = new List<csord__Order__c>();
     //Product Configuration List
      list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
     //Solutions list
      list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
      List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();

      List<Price_Schedule_Line_Item__c> pSLIs = new List<Price_Schedule_Line_Item__c>();
      List<Tier_Line_Item__c> tLIS = new List<Tier_Line_Item__c>();
      List<Charge_Line_Item__c> cLIs = new List<Charge_Line_Item__c>();
      List<Discount_Line_Item__c> dSLIs = new List<Discount_Line_Item__c>();
      List<Number__c> numberLst = new List<Number__c>();

      String handlerName = 'PostSubscriptionHandler';
 
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();

        accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;

        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = accountList[0].Id;
        ba.Billing_Account_Number__c = '123123122234';
        ba.Status__c = 'Allocated';
        insert ba;

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 2);
        orderList[0].Billing_Account__c = ba.Id;
        orderList[1].Billing_Account__c = ba.Id;
        insert orderList;

        //orderList[0].csord__Primary_Order__c = orderList[0].Id;
        orderList[1].csord__Primary_Order__c = orderList[0].Id;
        update orderList;

        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 7);

        solutionList = Orchestration_TestUtility.buildSolution(false, 1);
        solutionList[0].Name = 'TestSubsforTest0';
        insert solutionList;

        marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 1);
        marketableList[0].Auto_Expired_Entity__c = true;
        insert marketableList;

        subscriptionList.addAll(Orchestration_TestUtility.buildSubscriptionWOReplace(false, 2, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id));

        subscriptionList[0].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
        subscriptionList[0].MarketableOffer__c = marketableList[0].id;
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        subscriptionList[0].Billing_Account__c = ba.Id;
        subscriptionList[0].csord__Status__c = 'Bill Readiness In Progress';
        subscriptionList[0].Name = 'TestSubsforTest0';
        subscriptionList[1].Name = 'TestSubsforTest0';
        subscriptionList[1].MarketableOffer__c = marketableList[0].id;
        subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        subscriptionList[1].Billing_Account__c = ba.Id;
        subscriptionList[1].csord__Status__c = 'Active';
        subscriptionList[0].csordtelcoa__Subscription_Number__c = '1';
        subscriptionList[1].csordtelcoa__Subscription_Number__c = '1';
        insert subscriptionList;

        servlist = Orchestration_TestUtility.buildServiceWOReplace(false, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        servlist[1].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        insert servlist;

        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 2, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 2, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 2, servlist));
        insert cLIs;

        dSLIs.addAll(Orchestration_TestUtility.buildDLIs(true, 3, cLIs));
        pSLIs.addAll(Orchestration_TestUtility.buildPSLIs(true, 3, cLIs));

        tLIS.addAll(Orchestration_TestUtility.buildTLIs(true, 3, pSLIs));

        numberLst = Orchestration_TestUtility.buildNumber(false, 7, productconfiglistList, servlist[0].id, subscriptionList[0].id);
        numberLst[0].Status__c = 'RESERVED';
        numberLst[1].Status__c = 'DISCONNECT PENDING';
        numberLst[2].Status__c = 'Disconnect In Progress';
        numberLst[3].Status__c = 'Provisioning In Progress';
        numberLst[4].Status__c = 'Provisioned';
        numberLst[5].Status__c = 'Disconnected';
        numberLst[6].Status__c = 'In Progress';
        insert numberLst;
    }


    // Callout limit raeched
    static testMethod void performCalloutsTest() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [
            SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c
            FROM csord__Subscription__c
            WHERE MarketableOffer__c != null
        ];
        System.debug('subList No : '+subList[0].csordtelcoa__Subscription_Number__c);
        System.debug('subList No : '+subList[1].csordtelcoa__Subscription_Number__c);
    list<csord__Solution__c> solutionList = [Select Id, Name from csord__Solution__c limit 1];
        subList[0].csord__Order__c = orderLists[0].id;
        subList[0].cssdm__solution_association__c = solutionList[0].id;
        update subList;
        List<Number__c> numList = [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[1].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[1].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[1].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[1].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;

        orchProcess = Orchestration_TestUtility.buildProcess(false, 2, processTemp.id, orderLists, subList, objAccount.id, services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        orchProcess[0].csordtelcoa__Subscription__c = subList[0].Id;        
        insert orchProcess;

        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1000';
        update governerLimit;

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));

        Test.startTest();

        stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :stepList
        ];

        String responseBody =
            '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": ' +
            '{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",' +
            '"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",' +
            '"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", ' +
            '"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", ' +
            '"state": "NSW", "country": "Australia" }}}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '202', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();

        List<SObject> result = orderClass.process((List<SObject>) stepList);

        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);
        result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        Test.stopTest();
    }

    // Callout limit raeched (DML reached)
    static testMethod void performCalloutsTestWithLimitedDML() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [
            SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c
            FROM csord__Subscription__c
            WHERE MarketableOffer__c != null
        ];
        subList[0].csord__Order__c = orderLists[0].id;
        update subList;
        List<Number__c> numList = [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        update orchProcess;

        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));

        Test.startTest();

        String responseBody =
            '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": ' +
            '{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",' +
            '"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",' +
            '"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", ' +
            '"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", ' +
            '"state": "NSW", "country": "Australia" }}}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '202', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        List<SObject> result = orderClass.process((List<SObject>) stepList);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];

        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '2';
        update governerLimit;

        orderClass = new Orchestration_SolutionCompletionHandler();
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);

        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;

        orderClass = new Orchestration_SolutionCompletionHandler();
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);

        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '4';
        update governerLimit;

        orderClass = new Orchestration_SolutionCompletionHandler();
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);

        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '5';
        update governerLimit;

        orderClass = new Orchestration_SolutionCompletionHandler();

        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        Test.stopTest();
    }

    //Mock setup for 404 Response
    static testMethod void performCalloutsTest404() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [
            SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c
            FROM csord__Subscription__c
            WHERE MarketableOffer__c != null
        ];
        subList[0].csord__Order__c = orderLists[0].id;
        update subList;
        List<Number__c> numList = [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        update orchProcess;

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        //Test Mocksetup
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', '404Response', new Map<String, String>()));

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '404', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        //orderClass.stepToRecordLogs.put(stepList[0].Id, new Map<String, Orchestration_CallOutResponse>{subList[0].Id => calloutResponse});

        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        List<SObject> result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];

        Test.stopTest();
    }

    //Mocksetup with 404 status code
    static testMethod void performCalloutsTest400() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        update orchProcess;

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', '', new Map<String, String>()));

        Test.startTest();
        //Test Mocksetup
        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        //orderClass.stepToRecordLogs.put(stepList[0].Id, new Map<String, Orchestration_CallOutResponse>{subList[0].Id => calloutResponse});

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];

        Test.stopTest();
    }

    //callout Exception
    static testMethod void performCalloutsException() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        orchProcess[0].csordtelcoa__Subscription__c = null;
        update orchProcess[0];

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', null, new Map<String, String>()));

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        //orderClass.stepToRecordLogs.put(stepList[0].Id, new Map<String, Orchestration_CallOutResponse>{subList[0].Id => calloutResponse});

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];
        //Assert to check result
        result = orderClass.process((List<SObject>) stepList);

        System.assert(result != null);
        
        Test.stopTest();
    }

    // Callout Auth Failed Exception
    static testMethod void performCalloutsAuthFailedException() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        //Mock setup
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', null, new Map<String, String>()));

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        orderClass.oAuthToken = null;

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];
        //Assert to check result
        result = orderClass.process((List<SObject>) stepList);

        System.assert(result != null);
        
        Test.stopTest();
    }

    // Different callout Exception
    static testMethod void performCalloutsException1() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 1, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        orchProcess[0].csordtelcoa__Subscription__c = null;
        update orchProcess[0];

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        appLog = Orchestration_TestUtility.buildApp(false, 1, StepList, orchProcess);
        appLog[0].Related_Record_Id__c = subList[0].id;
        appLog[0].Reference_Info__c = 'GenerateAppointmentHandler';
        appLog[0].Status_Code__c = '404';
        insert appLog;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(404, 'OK', '404Response', new Map<String, String>()));

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c) result[0];

        result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        
        Test.stopTest();
    }

        // Different callout Exception
    static testMethod void performCalloutsException2() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 2, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        orchProcess[0].csordtelcoa__Subscription__c = null;
        update orchProcess[0];

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 2, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        appLog = Orchestration_TestUtility.buildApp(false, 1, StepList, orchProcess);
        appLog[0].Related_Record_Id__c = subList[0].id;
        appLog[0].Reference_Info__c = 'PostSubscriptionHandler';
        appLog[0].Status_Code__c = '404';
        insert appLog;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        governerLimit.DML_limit__c = '0';
        governerLimit.Call_Out_limit__c = '0';
        update governerLimit;

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        
        Test.stopTest();
    }

    // Breaking callout Limit using SOQL
    static testMethod void breakingCallLimits1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
         // Query from datasetup
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;

        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> subs = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c FROM csord__Subscription__c WHERE MarketableOffer__c != null];

        orchProcess = Orchestration_TestUtility.buildProcess(true, 2, processTemp.id, orderLists, subList, objAccount.id, subs[0].id);
        orchProcess[0].csordtelcoa__Service__c = subs[0].Id;
        orchProcess[0].csordtelcoa__Subscription__c = null;
        update orchProcess[0];

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 2, orchProcess);
        stepList[0].JSON__c = null;
        insert stepList;

        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '0';
        governerLimit.DML_limit__c = '0';
        governerLimit.CPU_limit__c = '0';
        update governerLimit;
        //Mock setup
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(402, 'OK', '', new Map<String, String>()));

        Test.startTest();

        String responseBody = '{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", ' + '"message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '400', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();
        //orderClass.stepToRecordLogs.put(stepList[0].Id, new Map<String, Orchestration_CallOutResponse>{subList[0].Id => calloutResponse});

        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);
        List<SObject> result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        Test.stopTest();
    }
      
        // Breaking process with DML rows 
    static testMethod void breakProcess() {
         // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [
            SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c
            FROM csord__Subscription__c
            WHERE MarketableOffer__c != null
        ];
        subList[0].csord__Order__c = orderLists[0].id;
        update subList;
        List<Number__c> numList = [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;

        orchProcess = Orchestration_TestUtility.buildProcess(false, 2, processTemp.id, orderLists, subList, objAccount.id, services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        insert orchProcess;

        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '7';
        update governerLimit; // updation for further process
        // Mock setup  
        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));

        Test.startTest();

        stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :stepList
        ];

        String responseBody =
            '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": ' +
            '{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",' +
            '"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",' +
            '"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", ' +
            '"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", ' +
            '"state": "NSW", "country": "Australia" }}}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '202', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();

        List<SObject> result = orderClass.process((List<SObject>) stepList);

        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);
        result = orderClass.process((List<SObject>) stepList);
        //Assert to check result
        System.assert(result != null);
        
        Test.stopTest();
    }
    // Breaking callout Limit using DML rows
    static testMethod void breakProcess12() {
        // Query from datasetup
        CSPOFA__Orchestration_Process_Template__c processTemp = [SELECT id FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c FROM csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name, csord__Order_Request__c, csord__Identification__c FROM csord__Order__c];
        List<csord__Subscription__c> subList = [
            SELECT Id, Name, csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Identification__c, triggerBill_RTB__c, csord__Status__c, MarketableOffer__r.Auto_Expired_Entity__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csordtelcoa__Product_Configuration__r.ConfigurationType1__c
            FROM csord__Subscription__c
            WHERE MarketableOffer__c != null
        ];
        subList[0].csord__Order__c = orderLists[0].id;
        update subList;
        List<Number__c> numList = [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;

        orchProcess = Orchestration_TestUtility.buildProcess(false, 2, processTemp.id, orderLists, subList, objAccount.id, services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        insert orchProcess;

        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);

        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false, 1, orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '55';
        update governerLimit; // updation for further process

        Test.setMock(HttpCalloutMock.class, new Orchestration_MockBillingOrderResponse(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));

        Test.startTest();

        stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :stepList
        ];

        String responseBody =
            '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": ' +
            '{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",' +
            '"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",' +
            '"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", ' +
            '"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", ' +
            '"state": "NSW", "country": "Australia" }}}';
        Orchestration_CallOutResponse calloutResponse = new Orchestration_CallOutResponse(string.valueOf(subList[0].Id), '', responseBody, '202', '', '', '', string.valueOf(subList[0].Id), '', null, 'POST');

        calloutResponse.recordId = subList[0].Id;
        Orchestration_SolutionCompletionHandler orderClass = new Orchestration_SolutionCompletionHandler();

        List<SObject> result = orderClass.process((List<SObject>) stepList);

        //Orchestration_BillingOrderUtility.mapSubscriptionToCallout.put(String.valueof(subList[0].Id), calloutResponse);
        Boolean resultBoolean = orderClass.performCallouts((List<SObject>) stepList);

        result = orderClass.process((List<SObject>) stepList);
        result = orderClass.process((List<SObject>) stepList);
        // Assert to check result
        System.assert(result != null);
        
        Test.stopTest();
    }
}