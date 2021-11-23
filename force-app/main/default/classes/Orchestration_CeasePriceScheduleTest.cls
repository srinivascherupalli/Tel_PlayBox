/**================================================================
 * Appirio, Inc
 * Name: Orchestration_CeasePriceScheduleTest
 * Main Class : Orchestration_CeasePriceScheduleStep
 * Created Date: May 27, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/
@isTest
public class Orchestration_CeasePriceScheduleTest {
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
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        List<csord__Service__c> servlist2 = new List<csord__Service__c>();
        List<csord__Service__c> servlist3 = new List<csord__Service__c>();
        List<csord__Service__c> allServs = new List<csord__Service__c>();
        List<csord__Service__c> replacedService = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0 = new List<Attachment>();
        list<Attachment> attachmentList1 = new List<Attachment>();
        list<Attachment> attachmentList2 = new List<Attachment>();
        list<Attachment> attachmentList3 = new List<Attachment>();
        list<Attachment> allAtts = new List<Attachment>();

        // records for chargeLine Item
        List<Charge_Line_Item__c> cliList0 = new List<Charge_Line_Item__c>();
        List<Charge_Line_Item__c> cliList1 = new List<Charge_Line_Item__c>();
        List<Charge_Line_Item__c> cliList2 = new List<Charge_Line_Item__c>();
        List<Charge_Line_Item__c> cliList3 = new List<Charge_Line_Item__c>();
        List<Charge_Line_Item__c> replaceCliList = new List<Charge_Line_Item__c>();

        List<Discount_Line_Item__c> dSLIs3 = new List<Discount_Line_Item__c>();

        List<Price_Schedule_Line_Item__c> pSLIs3 = new List<Price_Schedule_Line_Item__c>();
        // PricingMSResponseObject__c list
        List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);

        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 4);

        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);

        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);

        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        replacedService = Orchestration_TestUtility.buildService(true, 1, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0 = Orchestration_TestUtility.buildService(false, 6, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        allServs.addAll(servlist0);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist1 = Orchestration_TestUtility.buildService(false, 6, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[0].id);
        allServs.addAll(servlist1);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist2 = Orchestration_TestUtility.buildService(false, 6, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
        allServs.addAll(servlist2);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist3 = Orchestration_TestUtility.buildService(false, 6, subscriptionList[3].id, orderReqList[0].id, orderList[3].id, productconfiglistList[0].id);
        allServs.addAll(servlist3);
        for (csord__Service__c service : allServs) {
            service.csord__Status__c = 'Disconnect';
            service.csordtelcoa__Replaced_Service__c = replacedService[0].Id;
        }
        insert allServs;

        cliList0 = Orchestration_TestUtility.buildCLIs(true, 6, servlist0);
        cliList1 = Orchestration_TestUtility.buildCLIs(true, 6, servlist1);
        cliList2 = Orchestration_TestUtility.buildCLIs(true, 6, servlist2);
        cliList3 = Orchestration_TestUtility.buildCLIs(true, 6, servlist3);
        replaceCliList = Orchestration_TestUtility.buildCLIs(true, 1, replacedService);

        dSLIs3 = Orchestration_TestUtility.buildDLIs(true, 1, replaceCliList);

        pSLIs3 = Orchestration_TestUtility.buildPSLIs(true, 1, replaceCliList);
        List<Tier_Line_Item__c> tLIs = new List<Tier_Line_Item__c>();
        tLIs = Orchestration_TestUtility.buildTLIs(true, 1, pSLIs3);

        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(false, 5, servlist0, productconfiglistList[0].id);
        allAtts.addAll(attachmentList0);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList1 = Orchestration_TestUtility.buildAttachment(false, 5, servlist1, productconfiglistList[0].id);
        allAtts.addAll(attachmentList1);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList2 = Orchestration_TestUtility.buildAttachment(false, 5, servlist2, productconfiglistList[0].id);
        allAtts.addAll(attachmentList2);
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList3 = Orchestration_TestUtility.buildAttachment(false, 5, servlist3, productconfiglistList[0].id);
        allAtts.addAll(attachmentList3);
        for (Attachment att : allAtts) {
            att.body = Blob.valueOf(
                '{"legacyAttributes":[],"serviceId":"","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_MIA_DATPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","billDescription":"Mobile Interim Access Allowance","SERVICEID":"61429751286","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"Attach0GUID","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Disconnect Pending","version":"1"}]}'
            );
        }
        insert allAtts;
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist0[0].id);
        processList[0].csordtelcoa__Subscription__c = null;
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__c = '{""orderIds"":["' + orderList[0].id + '"]}';
        }
        insert orchStepList;
    }

    // Insertion of Tier_Line_Item__c and Price_Schedule_Line_Item__c
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Test.startTest();
        Orchestration_CeasePriceScheduleStep ceasePriceScheduleStep = new Orchestration_CeasePriceScheduleStep();
        orchStepList = ceasePriceScheduleStep.process(orchStepList);

        Charge_Line_Item__c CLI = [SELECT Id, serviceId__c, status__c, billingSpecIdentifier__c, serviceId__r.csordtelcoa__Replaced_Service__c FROM Charge_Line_Item__c WHERE serviceId__r.csord__Subscription__c = :orchStepList[1].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c LIMIT 1];

        Charge_Line_Item__c replaceCLI = [SELECT Id, serviceId__c, status__c, serviceId__r.csordtelcoa__Replaced_Service__c, (SELECT id, status__c FROM Discount_Line_Items__r), (SELECT Id, status__c FROM Price_Schedule_Line__r) FROM Charge_Line_Item__c WHERE serviceId__c = :CLI.serviceId__r.csordtelcoa__Replaced_Service__c LIMIT 1];
        Tier_Line_Item__c tli = [SELECT Id, status__c FROM Tier_Line_Item__c WHERE PSLIInstance__c = :replaceCLI.Price_Schedule_Line__r[0].Id];
        System.assertEquals(tli.status__c, Label.ReadyToInactive);
        System.assertEquals(replaceCLI.status__c, Label.ReadyToInactive);
        System.assertEquals(replaceCLI.Discount_Line_Items__r[0].status__c, Label.ReadyToInactive);
        System.assertEquals(replaceCLI.Price_Schedule_Line__r[0].status__c, Label.ReadyToInactive);
        System.assertEquals(CLI.status__c, 'Event Published');
        System.assertEquals(CLI.billingSpecIdentifier__c, 'Attach0GUID');
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Success: Records processed');
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
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
        Orchestration_CeasePriceScheduleStep ceasePriceScheduleStep = new Orchestration_CeasePriceScheduleStep();
        orchStepList = ceasePriceScheduleStep.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Error: Step do not have an associated subscription');
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
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
        Orchestration_CeasePriceScheduleStep ceasePriceScheduleStep = new Orchestration_CeasePriceScheduleStep();
        orchStepList = ceasePriceScheduleStep.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Error: Step do not have an associated subscription');
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
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
        Orchestration_CeasePriceScheduleStep ceasePriceScheduleStep = new Orchestration_CeasePriceScheduleStep();
        orchStepList = ceasePriceScheduleStep.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached.
        System.assertEquals(isNull, true);
        Test.stopTest();
    }

    //Partial records processed
/*    static testMethod void breakingLimitsInCPULimit() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c, DML_limit__c, CPU_limit__c, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.CPU_limit__c = '80';

        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, JSON__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_CeasePriceScheduleStep ceasePriceScheduleStep = new Orchestration_CeasePriceScheduleStep();
        orchStepList = ceasePriceScheduleStep.process(orchStepList);

        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Success: Partial records processed');
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.InProgress);

        Test.stopTest();
    }*/
}