/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AbstractStepHandlerTest
 * Main Class : Orchestration_AbstractStepHandler
 * Created Date: June 12, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_AbstractStepHandlerTest {
    @Testsetup
    static void dataSetup() {
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        list<Attachment> attachments = new List<Attachment>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<ApplicationLog__c> appLogList = new List<ApplicationLog__c>();
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 5);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        prdList = Orchestration_TestUtility.buildProductDefination(true, 1);
        offerList = Orchestration_TestUtility.buildMarkertableOffer(true, 2);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 2);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 6, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        servlist = Orchestration_TestUtility.buildService(true, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        processList = Orchestration_TestUtility.buildProcess(true, 5, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 5, processList);
        orchStepList[0].CSPOFA__Orchestration_Process__c = processList[4].id;
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__C = '{"StepId" : "ABC","mapInsertedRecords" :{  "Service" : "a","Subscription" : "d","Attachment" : "f"  }}';
        }
        insert orchStepList;
        attachments = Orchestration_TestUtility.buildAttachment(false, 4, servlist, productconfiglistList[0].id);
        attachments[0].Name = OrchestratorConstants.DataOrchestrationNames.callOutResponse;
        attachments[0].ParentId = orchStepList[0].id;
        attachments[1].Name = OrchestratorConstants.DataOrchestrationNames.callOutResponse;
        attachments[1].ParentId = orchStepList[1].id;
        attachments[2].Name = OrchestratorConstants.DataOrchestrationNames.processedIds;
        attachments[2].ParentId = orchStepList[1].id;
        attachments[3].Name = OrchestratorConstants.DataOrchestrationNames.processedIds;
        attachments[3].ParentId = orchStepList[1].id;
        insert attachments;
        appLogList = Orchestration_TestUtility.buildApp(false, 3, orchStepList, processList);
        appLogList[2].step__c = orchStepList[0].Id;
        appLogList[0].Related_Record_Id__c = subscriptionList[0].id;
        appLogList[1].Related_Record_Id__c = subscriptionList[1].id;
        appLogList[2].Related_Record_Id__c = subscriptionList[2].id;
        appLogList[0].Reference_Info__c = 'GenerateAppointmentHandler';
        appLogList[1].Reference_Info__c = 'GenerateAppointmentHandler';
        appLogList[2].Reference_Info__c = 'GenerateAppointmentHandler';
        insert appLogList;
    }
    static testMethod void abstractMethod() {
        // Query from datasetup
        List<ApplicationLog__c> appLogList = new List<ApplicationLog__c>();
        appLogList = [
            SELECT Id, Reference_Info__c, Debug_Level__c, Request_Message__c, Message__c, Stack_Trace__c, Error_Category__c, correlationId__c, Error_Code__c, Timer__c, User__c, Error_Description__c, Status_Code__c, Http_Code__c, CAC__c, UUID__c, Error_Type__c, Event_Type__c, API_Request_Time__c, Request_Method__c, Step__c, Related_Record_Id__c
            FROM ApplicationLog__c
        ];
        Set<String> appIds = new Set<String>();
        for (ApplicationLog__c appLog : appLogList) {
            appIds.add(appLog.Id);
        }

        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Attachment> attachmentList = new List<Attachment>();
        orchStepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csordtelcoa__Replaced_Service__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                CSPOFA__Orchestration_Process__r.cspofa__account__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.Order__c
            FROM CSPOFA__Orchestration_Step__c
        ];
        Set<String> stepIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            stepIds.add(step.Id);
        }

        Test.startTest();
        innerTestClass classObj = new innerTestClass();
        classObj.getStepList(orchStepList);
        classObj.insertObj();
        classObj.getProcessedRecords(orchStepList[0]);
        classObj.processStepResults(orchStepList, classObj.updateObj(orchStepList));
        classObj.getAttachmentList(stepIds, appIds);
        classObj.updateObjects();
        classObj.getAttachmentList(stepIds);
        classObj.populateStepResults('Message', 'Status', orchStepList);
        classObj.performCallouts(orchStepList);
        classObj.getResponseAndProcessIdAttachments(stepIds, 'GenerateAppointmentHandler');
        classObj.getUniqueResponseAndProcessIdAttachments(stepIds, 'GenerateAppointmentHandler');
        classObj.getRelatedAccountIds(orchStepList);
        classObj.getRelatedOrderIds(orchStepList);
        classObj.getRelatedSubscriptionIds(orchStepList);
        classObj.getRelatedServiceIds(orchStepList);
        classObj.getcalloutResponse(appLogList[0]);
        classObj.publishObject(classObj.publishObj());
        classObj.getIntegrationHandlerSettings('GenerateAppointmentHandler');
        classObj.hasDMLRowsLimitExceeded();
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    public class innerTestClass extends Orchestration_AbstractStepHandler {
        public override List<SObject> process(List<SObject> steps) {
            return null;
        }
        public void insertObj() {
            Account acc = new Account();
            acc.Name = 'test Account ';
            acc.Customer_Status__c = 'Active';
            sObjectsToInsert.add(acc);
            stepResults.put(acc.id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete, 'Response'));
        }

        public List<Orchestration_CallOutResponse> publishObj() {
            csord__Order__c ord = [SELECT Id, csord__Order_Number__c FROM csord__Order__c LIMIT 1];
            List<Orchestration_CallOutResponse> respWrapper = new List<Orchestration_CallOutResponse>();
            HighVolumeReadyToSubmitOrder__e highVolEvent = new HighVolumeReadyToSubmitOrder__e();
            highVolEvent.OrderID__c = ord.Id;
            highVolEvent.Order_Number__c = ord.csord__Order_Number__c;
            highVolEvent.CorrelationID__c = Orchestration_Utility.getUID();
            String StatusCode = '200';
            Orchestration_CallOutResponse res = new Orchestration_CallOutResponse(null, JSON.serialize(highVolEvent, true), null, statusCode, 'HighVolumeEvent', 'Integration', null, null, statusCode, null, null);
            respWrapper.add(res);
            //Putting the event in the list
            eventsToPublish.add(highVolEvent);
            return respWrapper;
            //publishObject(respWrapper);
        }

        public Map<Id, stepResult> updateObj(List<CSPOFA__Orchestration_Step__c> orchStepList) {
            Account acc = new Account();
            acc.Name = 'test Account1 ';
            acc.Customer_Status__c = 'Active';
            insert acc;
            acc.name = 'test';
            sObjectsToUpdate.put(acc.Id, acc);

            Orchestration_ProcessedRecords controller = new Orchestration_ProcessedRecords();
            Integer i = 1;
            controller.orderIds = new Set<String>{ 'a', 'b', 'c' };
            while (i <= 260) {
                controller.orderIds.add('a' + i);
                i++;
            }

            controller.subsIds = new Set<String>{ 'd', 'e', 'f' };
            controller.serviceIds = new Set<String>{ '1', '2', '3' };
            controller.attachmentIds = new Set<String>{ 'a', 'b', 'c' };
            controller.numberIds = new Set<String>{ 'a', 'b', 'c' };
            controller.chargeLineItems = new Set<String>{ 'a', 'b', 'c' };
            controller.priceScheduleLineItems = new Set<String>{ 'a', 'b', 'c' };
            controller.tierLineItems = new Set<String>{ 'a', 'b', 'c' };
            controller.discountAssociations = new Set<String>{ 'a', 'b', 'c' };
            orchStepList = [
                SELECT
                    ID,
                    Name,
                    CSPOFA__Orchestration_Process__c,
                    CSPOFA__Status__c,
                    CSPOFA__Completed_Date__c,
                    JSON__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csordtelcoa__Replaced_Service__c,
                    CSPOFA__Message__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                    CSPOFA__Orchestration_Process__r.cspofa__account__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                    CSPOFA__Orchestration_Process__r.Order__c
                FROM CSPOFA__Orchestration_Step__c
            ];

            Orchestration_ProcessedRecords record = getProcessedRecords(orchStepList[0]);

            List<Orchestration_CallOutResponse> resList = new List<Orchestration_CallOutResponse>();
            Orchestration_CallOutResponse response = new Orchestration_CallOutResponse('recordId', 'reqBody', 'responseBody', 'statusCode', 'loggerName', 'debugLevel', 'errorCategory', 'correlationId', 'errorCode', 12220202, 'requestMethod');
            resList.add(response);
            stepResults.put(orchStepList[0].Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete, record));
            stepResults.put(orchStepList[1].Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete, resList));
            stepResults.put(orchStepList[2].Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete, 'stackTrace'));

            return stepResults;
        }
    }
}