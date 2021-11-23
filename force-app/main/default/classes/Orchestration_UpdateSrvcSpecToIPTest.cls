/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateSrvcSpecToIPTest
 * Main Class : Orchestration_UpdateSrvcSpecToInProgress
 * Created Date: June 21, 2020
 * Created By: Shweta Khandelwal
 
  Prajakta   10/11/2020   EDGE-174930
 ==================================================================*/
@isTest
public class Orchestration_UpdateSrvcSpecToIPTest {
   
    @TestSetup
    static void dataSetup() {
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<account> accountList = new List<account>();
        //Process Templates for Processes
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        //Orchestration Processes list
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        //List of Orchestration Steps which needs to be executed
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();   
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();       
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, true , 2); 
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 6, null, orderList, null, null);
        subscriptionList[0].name = 'test subs';
        subscriptionList[0].csord__Identification__c = 'test identity';
        subscriptionList[0].csord__Status__c = 'Pending';
        insert subscriptionList;
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        servlist = Orchestration_TestUtility.buildService(false, 2, null, null, null, null);
        servlist[0].name = 'tst service1';
        servlist[0].csord__Identification__c = 'test identify1';
        servlist[0].csordtelcoa__Service_Number__c = '3';
        servlist[0].csord__Subscription__c = subscriptionList[0].Id;
        servlist[0].csord__Status__c = 'Pending';

        servlist[1].name = 'tst service2';
        servlist[1].csord__Identification__c = 'test identify2';
        servlist[1].csordtelcoa__Service_Number__c = '3';
        servlist[1].csord__Subscription__c = subscriptionList[0].Id;
        servlist[1].csord__Status__c = 'Pending';

        insert servlist;


        List<Attachment> attachmentList = new List<Attachment>(); 
        attachmentList = Orchestration_TestUtility.buildAttachment(false, 1, servlist, null);
        attachmentList[0].Body = Blob.valueOf(
            '{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"' +
            servlist[1].Id +
            '","legacyAttributes":[]}'
        );
        attachmentList[0].Name = 'ServiceSpecifications.json';
        //attachmentList[0].ParentId = servlist[1].Id;
        insert attachmentList;

        governerLimit = Orchestration_TestUtility.buildLimits();
       //Build Process Records through wich the Steps will be executed. 
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, null, servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[1].id;
        processList[2].csordtelcoa__Service__c = servlist[0].id;
        processList[3].csordtelcoa__Service__c = servlist[1].id;
        insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__C = '{"' + OrchestratorConstants.OrchestrationObjectType.subscription + '":["' + subscriptionList[0].id + '"]}';
        }
        insert orchStepList;
    }
    static testMethod void serviceProcessTest() {
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
         // QUery to get data from datasetup
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = [SELECT Id,csordtelcoa__Service__c FROM CSPOFA__Orchestration_Process__c];
        for (csord__Service__c ser : [SELECT Id, Name, csord__Status__c FROM csord__Service__c]) {
            if (ser.name.equals('tst service1')) {
            processList[0].csordtelcoa__Service__c = ser.Id;
            processList[3].csordtelcoa__Service__c = ser.Id;
            } else {
                processList[2].csordtelcoa__Service__c = ser.Id;
            }
        }


        update processList;

        List<CSPOFA__Orchestration_Step__c> steps  = [SELECT Id, CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c 
                                                            WHERE CSPOFA__Orchestration_Process__c IN :processList]; 

        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '2';
        update governerLimit; // updation for further procedure 

        Test.startTest();
        Orchestration_UpdateSrvcSpecToInProgress orderClass = new Orchestration_UpdateSrvcSpecToInProgress();
        List<SObject> result = orderClass.process((List<SObject>) steps);
        // Assert to check result size
        System.assert(result.size() > 0);

        Test.stopTest();
    }

    // No steps present for process
    static testMethod void serviceProcessExceptionTest() {
        Orchestration_UpdateSrvcSpecToInProgress orderClass = new Orchestration_UpdateSrvcSpecToInProgress();
        Test.startTest();
        try {
            orderClass.process(null);
        } catch (Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        Test.stopTest();
    }

    // When limits reached
    static testMethod void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // QUery to get data from datasetup
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        // updation for further procedure
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateSrvcSpecToInProgress orderClass = new Orchestration_UpdateSrvcSpecToInProgress();
        orchStepList = orderClass.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
    
    
     // When limits reached
    static testMethod void processhasNullRec() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        // QUery to get data from datasetup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        CSPOFA__Orchestration_Process__c proc = new CSPOFA__Orchestration_Process__c(Id = orchStepList[0].CSPOFA__Orchestration_Process__c, csordtelcoa__Service__c = null);
        update proc;
       Test.startTest();
        Orchestration_UpdateSrvcSpecToInProgress orderClass = new Orchestration_UpdateSrvcSpecToInProgress();
        orchStepList = orderClass.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(isNull, false);
        Test.stopTest();
    }
}