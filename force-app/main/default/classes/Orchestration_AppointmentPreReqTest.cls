/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AppointmentPreReqTest
 * Class: Orchestration_AppointmentPreReq
 * Created Date: June 29, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/
@isTest
public class Orchestration_AppointmentPreReqTest {
    public static Governor_Limits__c governerLimit = new Governor_Limits__c();
    public static List<account> accountList = new List<account>();
    public static List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    public static List<csord__Service__c> servlist = new List<csord__Service__c>();
    public static List<csord__Order__c> orderList = new List<csord__Order__c>();
    public static list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
    public static list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
    public static List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();
    public static List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
    public static List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();
    public static List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    public static List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    public static list<Attachment> attachmentList = new List<Attachment>();
    public static List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();

    @Testsetup
    static void dataSetup() {
        governerLimit = Orchestration_TestUtility.buildLimits();

        accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 4);
        orderList[0].isAppointmentRequired__c = 'false';
        insert orderList;
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 3);
        productconfiglistList[1].Type__c = 'cancel';
        productconfiglistList[2].Type__c = null;
        insert productconfiglistList;

        solutionList = Orchestration_TestUtility.buildSolution(false, 1);
        solutionList[0].Name = 'Testing';
        insert solutionList;

        marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 1);
        marketableList[0].Auto_Expired_Entity__c = true;
        insert marketableList;

        siteList = Orchestration_TestUtility.buildsite(false, 1, accountList);
        insert siteList;

        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[0].csord__Account__c = accountList[1].id;
        subscriptionList[0].MarketableOffer__c = marketableList[0].id;
        subscriptionList[0].Site__c = siteList[0].id;
        subscriptionList[1].csordtelcoa__Replacement_Subscription__c = null;
        subscriptionList[1].Site__c = siteList[0].id;
        subscriptionList[2].Site__c = siteList[0].id;
        subscriptionList[3].Site__c = siteList[0].id;
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].Id;
        subscriptionList[3].csordtelcoa__Product_Configuration__c = productconfiglistList[2].Id;
        subscriptionList[1].csord__Order__c = orderList[1].Id;
        subscriptionList[2].csord__Order__c = orderList[2].Id;
        subscriptionList[3].csord__Order__c = orderList[3].Id;
        insert subscriptionList;

        servlist = Orchestration_TestUtility.buildService(false, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        servlist[0].Name = 'User - Fixed Seat -  2';
        servlist[1].Name = 'User - Fixed Seat -  2';
        servlist[2].Name = 'User - Fixed Seat -  2';
        servlist[3].Name = 'User - Fixed Seat -  2';
        servlist[0].Zone__c = '3';
        servlist[1].Zone__c = '3';
        servlist[2].Zone__c = '1';
        servlist[3].Zone__c = '2';
        servlist[0].SiteId__c = siteList[0].id;
        servlist[1].SiteId__c = siteList[0].id;
        servlist[2].SiteId__c = siteList[0].id;
        servlist[3].SiteId__c = siteList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        servlist[2].csord__Subscription__c = subscriptionList[2].id;
        servlist[3].csord__Subscription__c = subscriptionList[3].id;
        servlist[2].Cust_Req_Disconn_Date__c = Date.today();
        servlist[0].Cust_Req_Disconn_Date__c = Date.today();
        servlist[1].Cust_Req_Disconn_Date__c = Date.today();
        servlist[3].Cust_Req_Disconn_Date__c = Date.today();
        servlist[0].Not_Before_CRD__c = Date.today();
        servlist[1].Not_Before_CRD__c = Date.today();
        servlist[2].Not_Before_CRD__c = Date.today();
        servlist[3].Not_Before_CRD__c = Date.today();
        insert servlist;

        attachmentList = Orchestration_TestUtility.buildAttachment(false, 2, servlist, productconfiglistList[0].id);
        for (Attachment att : attachmentList) {
            att.body = Blob.valueOf(
                '{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"' +
                servlist[0].Id +
                '","legacyAttributes":[]}'
            );
        }
        insert attachmentList;

        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[1].Order__c = orderList[0].id;
        processList[2].Order__c = null;
        insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__C = '{"subids":["' + subscriptionList[0].id + '"]}';
        }
        orchStepList[3].JSON__C = null;
        orchStepList[1].cspofa__message__c = null;
        insert orchStepList;

        appLog = Orchestration_TestUtility.buildApp(false, 4, orchStepList, processList);
        appLog[0].Related_Record_Id__c = subscriptionList[0].id;
        appLog[1].Related_Record_Id__c = subscriptionList[1].id;
        appLog[2].Related_Record_Id__c = subscriptionList[2].id;
        appLog[3].Related_Record_Id__c = subscriptionList[3].id;
        appLog[0].Reference_Info__c = 'GenerateAppointmentHandler';
        appLog[1].Reference_Info__c = 'GenerateAppointmentHandler';
        appLog[2].Reference_Info__c = 'GenerateAppointmentHandler';
        appLog[3].Reference_Info__c = 'GenerateAppointmentHandler';
        appLog[0].Status_Code__c = '200';
        appLog[1].Status_Code__c = '404';
        appLog[2].Status_Code__c = '404';
        String message = '{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"NBN","appointmentType":"STANDARD INSTALL","appointmentSubType":"STANDARD","suggestedStartDate":"2019-06-03T00:05:00","minimumStartDate":"2019-02-04T00:05:00","baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000027","productInstanceID":"463949fd-e9b7-f459-b34f-4bcdb7d5b8d2"}]},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-06-14T00:05:00","minimumStartDate":"2019-02-04T00:05:00","dependencies":[{"dependentArrayItemNumber":1,"leadTimeDaysApplied":3}],"baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000073","productInstanceID":"397949fd-e6a7-f459-b34f-4bcdb7d5b5c1"}]}]}}';

        appLog[0].Message__c = message;
        appLog[1].Message__c = message;
        appLog[2].Message__c = message;
        appLog[3].Message__c = message;
        insert appLog;
    }

    @isTest
    static void performCalloutsAppReq0Test() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        // List<csord__Subscription__c> sub = [SELECT id, Site__c, toBeCancelled__c, csord__Order__c, csordtelcoa__Replacement_Subscription__c, csordtelcoa__Product_Configuration__r.Type__c, site__r.cscrm__Installation_Address_Details__c, site__r.Address__c, csord__Order__r.csord__Order_Number__c FROM csord__Subscription__c];
        // string subid = sub[0].id;
        csord__Order__c order = [SELECT id FROM csord__Order__c WHERE name = 'order10' LIMIT 1];

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new Orchestration_AppointmentPreReqMock('success_GenerateAppReq0'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void performCalloutsTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<csord__Subscription__c> sub = [SELECT id, Site__c, toBeCancelled__c, csord__Order__c, csordtelcoa__Replacement_Subscription__c, csordtelcoa__Product_Configuration__r.Type__c, site__r.cscrm__Installation_Address_Details__c, site__r.Address__c, csord__Order__r.csord__Order_Number__c FROM csord__Subscription__c];
        string subid = sub[0].id;
        csord__Order__c order = [SELECT id FROM csord__Order__c WHERE name = 'order10' LIMIT 1];

        List<csord__Service__c> servList = [SELECT Id, Name FROM csord__Service__c];
        //System.assertEquals(servList[0].Name, 'User - Fixed Seat - ');

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void performCalloutsErrorTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<csord__Subscription__c> sub = [SELECT id, Site__c, toBeCancelled__c, csord__Order__c, csordtelcoa__Replacement_Subscription__c, csordtelcoa__Product_Configuration__r.Type__c, site__r.cscrm__Installation_Address_Details__c, site__r.Address__c, csord__Order__r.csord__Order_Number__c FROM csord__Subscription__c];
        string subid = sub[0].id;
        csord__Order__c order = [SELECT id FROM csord__Order__c WHERE name = 'order10' LIMIT 1];

        List<csord__Service__c> servList = [SELECT Id, Name FROM csord__Service__c];
        //System.assertEquals(servList[0].Name, 'User - Fixed Seat - ');

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('Error'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        // System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void processedIdNull() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, JSON__C, CSPOFA__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE cspofa__message__c = null LIMIT 1];

        orchStepList[0].JSON__C = null;
        update orchStepList;
        ApplicationLog__c appLog = [SELECT id, Status_Code__c FROM ApplicationLog__c WHERE Step__c = :orchStepList[0].id LIMIT 1];
        appLog.Status_Code__c = '202';
        update appLog;
        List<csord__Subscription__c> sub = [SELECT id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.Type__c FROM csord__Subscription__c WHERE csord__Order__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c LIMIT 1];

        cscfga__Product_Configuration__c prd = [SELECT Id, Type__c FROM cscfga__Product_Configuration__c WHERE id = :sub[0].csordtelcoa__Product_Configuration__c];

        prd.Type__c = 'cancel';
        update prd;

        csord__Service__c service = [SELECT id, csord__Subscription__c, Zone__c FROM csord__Service__c WHERE csord__Subscription__c = :sub[0].id];

        service.zone__c = '3';
        update service;

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void tobeCanceltrue() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE cspofa__message__c = null LIMIT 1];

        List<csord__Subscription__c> sub = [SELECT id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.Type__c FROM csord__Subscription__c WHERE csord__Order__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c LIMIT 1];

        cscfga__Product_Configuration__c prd = [SELECT Id, Type__c FROM cscfga__Product_Configuration__c WHERE id = :sub[0].csordtelcoa__Product_Configuration__c];

        prd.Type__c = 'cancel';
        update prd;

        csord__Service__c service = [SELECT id, csord__Subscription__c, Zone__c FROM csord__Service__c WHERE csord__Subscription__c = :sub[0].id];

        service.zone__c = '3';
        update service;

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void tobeCanceltrueRepSubNull() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE cspofa__message__c = null LIMIT 1];

        List<csord__Subscription__c> sub = [SELECT id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replacement_Subscription__c, csordtelcoa__Product_Configuration__r.Type__c FROM csord__Subscription__c WHERE csord__Order__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c LIMIT 1];
        sub[0].csordtelcoa__Replacement_Subscription__c = null;
        update sub;

        cscfga__Product_Configuration__c prd = [SELECT Id, Type__c FROM cscfga__Product_Configuration__c WHERE id = :sub[0].csordtelcoa__Product_Configuration__c];

        prd.Type__c = 'cancel';
        update prd;

        csord__Service__c service = [SELECT id, csord__Subscription__c, Zone__c FROM csord__Service__c WHERE csord__Subscription__c = :sub[0].id];

        service.zone__c = '1';
        update service;

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        Test.stopTest();
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    static testMethod void serviceProcessExceptionTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();

        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        //Test.startTest();
        try {
            submitOrder.performCallouts((List<SObject>) orchStepList);
            submitOrder.process(null);
        } catch (Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        Test.stopTest();
    }

    static testMethod void performCallNullTest() {
        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();

        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        //Test.startTest();
        try {
            submitOrder.performCallouts(null);
            submitOrder.process(null);
        } catch (Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        Test.stopTest();
    }

    // Where dml hit
    @isTest
    static void performCalloutsTestdmlHit() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '4';
        update governerLimit;

        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('success_GenerateAppo');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, mockresponse);

        Test.startTest();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
        Test.stopTest();
        // System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(true, result);
    }

    @isTest
    static void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean callout = submitOrder.performCallouts(orchStepList);
        submitOrder.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        System.assertEquals(isNull, false);
        Test.stopTest();
    }

    // App response message != null
    static testMethod void exceptionStepAppResponse() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        orchStepList[0].CSPOFA__Message__c = null;
        update orchStepList;
        ApplicationLog__c appLog = [SELECT id, Status_Code__c, Message__c FROM ApplicationLog__c WHERE Step__c = :orchStepList[0].id LIMIT 1];
        appLog.Message__c = OrchestratorConstants.SystemConstant.AttachmentMsg;
        appLog.Status_Code__c = '200';
        update appLog;
        Boolean callout = submitOrder.performCallouts(orchStepList);
        orchStepList = submitOrder.process(orchStepList);
        System.assertEquals(true, callout);
        Test.stopTest();
    }

    //Partial case
    static testMethod void breakingPartialCase() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));

        //Test.startTest();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean callout = submitOrder.performCallouts(orchStepList);
        submitOrder.process(orchStepList);
        Test.stopTest();
        System.assertEquals(true, callout);
    }

    static testMethod void breakingCallLimits() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '6';
        update governerLimit;

        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('success_GenerateAppo');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, mockresponse);

        Test.startTest();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
        Test.stopTest();
        // System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(false, result);
    }

    static testMethod void breakingCallLimits1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;

        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('success_GenerateAppo');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, mockresponse);

        Test.startTest();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
        Test.stopTest();
        // System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(false, result);
    }

    static testMethod void breakingCallLimits5() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '5';
        update governerLimit;

        Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
        String handler = 'GenerateAppointmentHandler';
        Cache.Org.put(handler, 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('success_GenerateAppo');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, mockresponse);

        Test.startTest();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        Orchestration_AppointmentPreReq submitOrder = new Orchestration_AppointmentPreReq();
        Boolean result = submitOrder.performCallouts((List<SObject>) orchStepList);
        List<SObject> result1 = submitOrder.process((List<SObject>) orchStepList);

        //String jobId = System.enqueueJob(new AppointmentServiceCalloutQ(subList,ord.id));
        Test.stopTest();
        // System.assertEquals(result1, submitOrder.process((List<SObject>) orchStepList));
        System.assertEquals(false, result);
    }
}