/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AccountStatusUpdateTest
 * Class: Orchestration_AccountStatusUpdate
 * Created Date: May 21, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/
@isTest
public class Orchestration_AccountStatusUpdateTest {
    //Test Data Setup
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
        list<cscfga__Product_Configuration__c> productconfigList = new List<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();

        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();

        //Governor Limit Creation
        governerLimit = Orchestration_TestUtility.buildLimits();

        //Build Accounts to Store the Orders
        accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;

        //Build Data to Perform Actions on
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 4);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfigList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfigList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
        insert subscriptionList;
               
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, null);
        processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
        processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(true, 4, processList);
    }

    //Method to test the main Functionality of Account getting Acquired when the Status is Active
    @isTest
    static void ProcessTest() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c];
        System.Test.startTest();
        Orchestration_AccountStatusUpdate accountStatusUpdate = new Orchestration_AccountStatusUpdate();

        orchStepList = accountStatusUpdate.process(orchStepList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            }
        }
        System.Test.stopTest();

        //Query Updated Data for Assertion
        List<csord__Subscription__c> subscriptionList = [SELECT Id, csord__Account__c, csord__Account__r.Customer_Status__c FROM csord__Subscription__c WHERE ID IN :subscriptionIds];

        //Assert if the Account was updated and the Steps were updated with proper Messages
        System.assertEquals('ACQUIRED', subscriptionList[0].csord__Account__r.Customer_Status__c);
        System.assertEquals('Success: Account Customer Status updated to Acquired.', orchStepList[0].CSPOFA__Message__c);
        System.assertEquals(OrchestratorConstants.OrchestratorStep.Complete, orchStepList[0].CSPOFA__Status__c);
        System.assertEquals('Success: No Updation required.', orchStepList[1].CSPOFA__Message__c);
    }

    //Method to test id the limits got Hit while processing
    @isTest
    static void breakingLimits() {
        //Query to get the Data for Processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        //Updatation to update theLImit to perform partial updation
        governerLimit.SOQL_limit__c = '1';
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        System.Test.startTest();
        //First run of process creates the JSON step
        Orchestration_AccountStatusUpdate accountStatusUpdate = new Orchestration_AccountStatusUpdate();
        update accountStatusUpdate.process(orchStepList);
        System.Test.stopTest();
        System.debug(orchStepList + '===>orchStepList');
        //Assert to check if the Step is in progress as the Limits were reached.
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
    }

    //Run class without any limits left
    @isTest
    static void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        // Update the Vustom Limits to check no updation is done
        update governerLimit;
        System.Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_AccountStatusUpdate accountStatusUpdate = new Orchestration_AccountStatusUpdate();
        orchStepList = accountStatusUpdate.process(orchStepList);
        System.Test.stopTest();

        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assert(orchStepList == null);
    }

    //Method to cover the Catch Code
    @isTest
    static void serviceProcessExceptionTest() {
        Orchestration_UpdateSrvcSpecToInProgress orderClass = new Orchestration_UpdateSrvcSpecToInProgress();
        Test.startTest();
        try {
            //Pass null to check if the Exception is caught.
            orderClass.process(null);
        } catch (Exception ex) {
            System.assert(String.isNotBlank(ex.getMessage()));
        }
        Test.stopTest();
    }
}