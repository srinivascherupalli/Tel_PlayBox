/**================================================================
 * Appirio, Inc
 * Name: Orchestration_GeneratePriceSchV2Test
 * Class: Orchestration_GeneratePriceScheduleV2
 * Created Date: June 04, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/

@isTest
public class Orchestration_GeneratePriceSchV2Test {
    @Testsetup
    static void dataSetup() {
        //Orchestration Processes list
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        //Process Templates for Processes
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        //List of Orchestration Steps which needs to be executed
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List of Accounts for order
        List<account> accountList = new List<account>();
        //Order request on Order
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        // List of Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList = new List<Attachment>();
        // records for chargeLine Item
        List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
        // PricingMSResponseObject__c list
        List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'Primary Order';
        ord.csord__Account__c = accountList[0].id;
        ord.csord__Status2__c = 'Complete';
        ord.csord__Order_Request__c = orderReqList[0].id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';
        ord.isTransientComplete__c = false;
        insert ord;

        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 6);
        orderList[0].csord__Primary_Order__c = ord.id;
        orderList[1].csord__Primary_Order__c = ord.id;
        insert orderList;

        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);

        csord__Subscription__c testSubscriptionReplacement = new csord__Subscription__c();
        testSubscriptionReplacement.Name = 'testSubscriptionReplaced';
        testSubscriptionReplacement.csord__Order__c = orderList[0].id;
        testSubscriptionReplacement.csord__Identification__c = 'IDE1322';
        testSubscriptionReplacement.triggerBill_RTB__c = false;
        insert testSubscriptionReplacement;

        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 6, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[1].csordtelcoa__Replaced_Subscription__c = testSubscriptionReplacement.id;
        insert subscriptionList;

        servlist = Orchestration_TestUtility.buildService(false, 6, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[2].csord__Subscription__c = subscriptionList[1].id; //serviceIdsToFetchModify
        servlist[2].Scenario_Type__c = 'Change in keypad';
        servlist[3].csord__Subscription__c = subscriptionList[1].id; //serviceIdsToFetchModify
        insert servlist;

        cliList = Orchestration_TestUtility.buildCLIs(false, 6, servlist);
        cliList[1].serviceId__c = servlist[0].Id; //mapchargeLineItemToInsert , CLI2 will be in chargeLineItemMapModifyData
        cliList[3].serviceId__c = servlist[3].Id; //isCompleteModifyOrchestration = false
        cliList[3].status__c = Label.Pricing_Records_Created;
        cliList[4].serviceId__c = servlist[1].Id; //mapchargeLineItemToInsert
        insert cliList;

        pmsList = Orchestration_TestUtility.buildPMSs(false, 6, cliList);
        pmsList[1].CLI_Instance_ID__c = String.valueOf(CLIList[0].Id);
        pmsList[2].CLI_Instance_ID__c = String.valueOf(CLIList[1].Id);
        pmsList[3].CLI_Instance_ID__c = String.valueOf(CLIList[2].Id);
        pmsList[4].CLI_Instance_ID__c = String.valueOf(CLIList[3].Id);
        pmsList[5].CLI_Instance_ID__c = String.valueOf(CLIList[4].Id);
        insert pmsList;

        attachmentList = Orchestration_TestUtility.buildAttachment(false, 5, servlist, productconfiglistList[0].id);
        attachmentList[0].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[0].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[1].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[1].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[2].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[2].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[3].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[3].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        attachmentList[4].body = Blob.valueOf(
            '{"legacyAttributes":[],"serviceId":"' +
            servlist[4].Id +
            '","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
        );
        insert attachmentList;
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[3].csordtelcoa__Subscription__c = null;
        //processList[0].Order__c = ord.id;
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[3].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        insert orchStepList;
    }

    // Insertion of Tier_Line_Item__c and Price_Schedule_Line_Item__c
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Test.startTest();
        Orchestration_GeneratePriceScheduleV2 generatePriceScheduleStep = new Orchestration_GeneratePriceScheduleV2();
        orchStepList = generatePriceScheduleStep.process(orchStepList);

        Attachment attach = new Attachment();
        Charge_Line_Item__c CLI = new Charge_Line_Item__c();
        CLI = [SELECT ID, billingSpecIdentifier__c, serviceId__c, serviceId__r.name FROM Charge_Line_Item__c WHERE billingSpecIdentifier__c != null LIMIT 1];

        System.assertEquals(CLI.billingSpecIdentifier__c, 'Attach0GUID');

        // Assert to check Tier_Line_Item__c and Price_Schedule_Line_Item__c size
        List<Price_Schedule_Line_Item__c> psls = [SELECT ID FROM Price_Schedule_Line_Item__c];
        System.assertEquals(psls.size() > 0, true);

        List<Tier_Line_Item__c> tlI = [SELECT ID FROM Tier_Line_Item__c];
        System.assertEquals(tlI.size() > 0, true);
    }

    // Limits got hit
    static testMethod void breakingLimits() {
        //Query to get the Data for Processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_GeneratePriceScheduleV2 generatePriceScheduleStep = new Orchestration_GeneratePriceScheduleV2();
        orchStepList = generatePriceScheduleStep.process(orchStepList);

        Charge_Line_Item__c CLI = new Charge_Line_Item__c();
        CLI = [SELECT ID, billingSpecIdentifier__c, serviceId__c FROM Charge_Line_Item__c LIMIT 1];
        System.assertEquals(CLI.billingSpecIdentifier__c, null); // As limit breakes and no updation will occur.
        Test.stopTest();
    }

    // Limits got hit
    static testMethod void breakingLimitsDML0() {
        //Query to get the Data for Processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_GeneratePriceScheduleV2 generatePriceScheduleStep = new Orchestration_GeneratePriceScheduleV2();
        orchStepList = generatePriceScheduleStep.process(orchStepList);

        Charge_Line_Item__c CLI = new Charge_Line_Item__c();
        CLI = [SELECT ID, billingSpecIdentifier__c, serviceId__c FROM Charge_Line_Item__c LIMIT 1];
        System.assertEquals(CLI.billingSpecIdentifier__c, null); // As limit breakes and no updation will occur.

        Test.stopTest();
    }

    static testMethod void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Query to get the Data for Processing
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        //Updatation to update theLImit to perform partial updation
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_GeneratePriceScheduleV2 generatePriceScheduleStep = new Orchestration_GeneratePriceScheduleV2();
        orchStepList = generatePriceScheduleStep.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached.
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
}