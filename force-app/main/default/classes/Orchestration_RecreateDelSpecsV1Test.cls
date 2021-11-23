@isTest
public class Orchestration_RecreateDelSpecsV1Test {
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
        //Product Configuration Lis
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist0 = new List<csord__Service__c>();
        List<csord__Service__c> servlist1 = new List<csord__Service__c>();
        List<csord__Service__c> servlist2 = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList0 = new List<Attachment>();
        list<Attachment> attachmentList1 = new List<Attachment>();
        list<Attachment> attachmentList2 = new List<Attachment>();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 3);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 3, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist0 = Orchestration_TestUtility.buildService(true, 3, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist2 = Orchestration_TestUtility.buildService(false, 3, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
        servlist2[0].csordtelcoa__Replaced_Service__c = null;
        insert servlist2;

        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist0[0].id);
        processList[1].csordtelcoa__Service__c = servlist2[0].id;
        processList[2].Order__c = null;
        insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 3, processList);
        orchStepList[1].CSPOFA__Orchestration_Process__c = processList[1].Id;
        orchStepList[0].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"orderIds":["' + orderList[0].id + '"]}';

        insert orchStepList;

        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList0 = Orchestration_TestUtility.buildAttachment(true, 2, servlist0, productconfiglistList[0].id);

        Orchestration_TestUtility.attachmentList = new List<Attachment>();
        attachmentList2 = Orchestration_TestUtility.buildAttachment(true, 2, servlist2, productconfiglistList[0].id);
    }

    static testMethod void ProcessTest() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        list<Attachment> attachmentList = new List<Attachment>();
        csord__Service__c service = new csord__Service__c();
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

        attachmentList = [SELECT ID, body FROM Attachment];
        service = [
            SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate
            FROM csord__Service__c
            WHERE csordtelcoa__Replaced_Service__c != null
            LIMIT 1
        ];
        Attachment attReplacedServiceold = [SELECT ID, name, body, parentId FROM Attachment WHERE parentId = :service.ID];
        String serviceattachmentstrold = attReplacedServiceold.body.toString();
        Map<String, Object> resultsold = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstrold);
        List<Object> lstSpecificationsold = (List<Object>) resultsold.get('specifications');

        Test.startTest();
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        //Query Updated Data for Assertion
        Attachment attReplacedService = [SELECT ID, name, body, parentId FROM Attachment WHERE parentId = :service.ID];
        String serviceattachmentstr = attReplacedService.body.toString();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
        List<Object> lstSpecifications = (List<Object>) results.get('specifications');
        //Assert To check specification is added sucessfully or not
        System.assertEquals(lstSpecifications.size(), lstSpecificationsold.size());

        string productConfigurationId = '';
        string status = '';
        Map<String, Object> specificationAttributes = (Map<String, Object>) lstSpecifications[8];
        status = (String) specificationAttributes.get('status');
        productConfigurationId = (String) specificationAttributes.get('productConfigurationId');
        // Assert To check the status
        System.assertEquals(status, 'Disconnect In Progress');
        // Assert To check the configId
        //System.assertEquals(productConfigurationId, service.csordtelcoa__Product_Configuration__c);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Waiting: Called Order Publisher');
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Waiting: Called Order Publisher');
        System.assertEquals(orchStepList[2].CSPOFA__Message__c, 'Waiting: Called Order Publisher');
        Test.stopTest();
    }

    // when No requried attachment found related to the servie
    /*static testMethod void attachmentMapNull() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        list<Attachment> attachmentList = new List<Attachment>();
        list<Attachment> attachmentListNew = new List<Attachment>();
        csord__Service__c service = new csord__Service__c();
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

        attachmentList = [SELECT ID, body FROM Attachment];
        for (Attachment att : attachmentList) {
            att.name = 'attachment1';
            attachmentListNew.add(att);
        }
        update attachmentListNew;
        Test.startTest();
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        // Assert to check step message when no attachment found
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success - There are No Attachments');

        Test.stopTest();
    }

    // Where service Map and orderIdMap is Null
    static testMethod void processWithNoServiceMapData() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
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
            WHERE CSPOFA__Orchestration_Process__r.Order__c = null
        ];

        Test.startTest();
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        //Assert to check step message when no related service found for updation

        System.assertEquals(orchStepList[0].cspofa__message__c, 'Success - No Updation as no services found.');
        Test.stopTest();
    }*/

    //Method to test id the limits got Hit while processing
    static testMethod void breakingLimits() {
        //Query to get the Data for Processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, JSON__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        //Assert to check if the Step is in progress as the Limits were reached.
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }

    //Run class without any limits left
    static testMethod void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList, null, 'No Steps returned as Limit Reached.');
        Test.stopTest();
    }

    //Run class without any limits left DML limite
    static testMethod void breakingLimitsInStartDML() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c, DML_limit__c FROM Governor_Limits__c];
        governerLimit.DML_limit__c = '0';
        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_RecreateDeletedSpecsV1 recreateDeletedSpecs = new Orchestration_RecreateDeletedSpecsV1();
        orchStepList = recreateDeletedSpecs.process(orchStepList);
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList, null, 'No Steps returned as Limit Reached.');
        Test.stopTest();
    }
}