/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateFnnDetailsTest
 * Main Class : Orchestration_UpdateFnnDetails
 * Created Date: June 21, 2020
 * Created By: Shweta Khandelwal
 ==================================================================
 Change.No.    Developer Name          Date          Story Description
 1.            Milos Djordjevic         08-06-2021   EDGE-222326 : Modified assert to check for empty list instead of null
 */
@isTest(SeeAllData=false)
public class Orchestration_UpdateFnnDetailsTest {
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
        List<csord__Service__c> servlist4 = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Record to create the product defination
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        //Record to create the opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        //Record to create the number
        List<Number__c> numList = new List<Number__c>();
        //Record to create the number group
        List<Number_Group__c> numGroupList = new List<Number_Group__c>();

        //Governor Limit Creation
        governerLimit = Orchestration_TestUtility.buildLimits();

        //Build Accounts to Store the Orders
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        oppList = Orchestration_TestUtility.buildOpp(false, 1, accountList);
        insert oppList;
       
        //Build Data to Perform Actions on
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 5);
        //insert orderList;

        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        prdList = Orchestration_TestUtility.buildProductDefination(true, 1);

        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name = 'Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c = 'Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 3);
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[0].Type__c = 'Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c = pcNewMdm.id;
        productconfiglistList[1].ConfigurationType1__c = 'ProductComponent';
        insert productconfiglistList;

        solutionList = Orchestration_TestUtility.buildSolution(true, 1);

        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 6, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Status__c = 'Pending';
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].Name = 'Unified Communication Tenancy Solution';
        subscriptionList[2].csord__Status__c = 'Not Active';
        insert subscriptionList;
       
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        servlist0 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist1 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[0].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist2 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[2].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist3 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[0].id, orderReqList[0].id, orderList[3].id, productconfiglistList[1].id);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
        servlist4 = Orchestration_TestUtility.buildService(false, 5, subscriptionList[0].id, orderReqList[0].id, orderList[4].id, productconfiglistList[1].id);
		servlist.addAll(servlist0);
        servlist.addAll(servlist1);
        servlist.addAll(servlist2);
        servlist.addAll(servlist3);
        servlist.addAll(servlist4);
        insert servlist;
        //servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        //servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        //servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        //servlist[1].csord__Subscription__c = subscriptionList[1].id;
        //servlist[2].csord__Subscription__c = subscriptionList[2].id;
        //insert servlist;
        numGroupList.add(new Number_Group__c(Product_Configuration__c = productconfiglistList[0].Id));
        insert numGroupList;
        numList = Orchestration_TestUtility.buildNumber(false, 1, productconfiglistList, 'serviceId1', 'subId1');
        numList[0].Number_Group__c = numGroupList[0].Id;
        insert numList;
       
       
        //Build Process Records through wich the Steps will be executed.
        Orchestration_TestUtility.processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = Orchestration_TestUtility.buildProcess(true, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist0[0].id);
        Orchestration_TestUtility.processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = Orchestration_TestUtility.buildProcess(true, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist1[0].id);
        Orchestration_TestUtility.processList = new List<CSPOFA__Orchestration_Process__c>();
        processList = Orchestration_TestUtility.buildProcess(true, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist2[0].id);

       // processList[1].csordtelcoa__Service__c = servlist1[1].id;
        //processList[2].csordtelcoa__Service__c = servlist2[2].id;
        //insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 3, processList);
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__C = '{"subsIds":["' + subscriptionList[0].id + '"]}';
        }
        insert orchStepList;
    }

    //when number got updated
    @isTest
    static void ProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        // Query form data setup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        numList = [SELECT ID, Product_Configuration__c, Product_ID__c FROM Number__c];
        cscfga__Product_Configuration__c prd = [SELECT Id,Marketable_Offer__r.Name,
                                                cscfga__Product_Definition__r.product_Specification__c
                                                FROM cscfga__Product_Configuration__c
                                                WHERE id =: numList[0].Product_Configuration__c];
        Test.startTest();
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);
        Test.stopTest();
        // Query for updated numberList after processing
        numList = [SELECT ID, Product_Configuration__c, Product_ID__c,Offer__c FROM Number__c];
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
        System.assertEquals(orchStepList[2].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
        System.assertEquals(numList[0].Product_ID__c, prd.cscfga__Product_Definition__r.product_Specification__c);
        System.assertEquals(numList[0].Offer__c, prd.Marketable_Offer__r.Name);

    }

    //When no related record found for processing
    @isTest
    static void ProcessTestWhenNoData() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number__c> numList = new List<Number__c>();
        // Query form data setup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        numList = [SELECT ID, Product_Configuration__c FROM Number__c];
        numList[0].Product_Configuration__c = NULL; // No product congfiguration for number
        update numList;
        Test.startTest();
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList); // Main method call
        Test.stopTest();
        // When no records present for processing message should be :
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: No record related to the product configuration for processing');
    }

    //Limits reached
    @isTest
    static void breakingLimits() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        // Query form data setup
        Governor_Limits__c governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        update updateFnnDetails.process(orchStepList);
        //Second run will update Number Group Records 
        updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c,'Success: Partial records processed');
        Test.stopTest();
    }

    //When limits are already reached
    @isTest
    static void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        // Query form data setup
        Governor_Limits__c governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Test.startTest();
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);
        // when limit reached Step will be in : In Progress step
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }

    //When DML rows are not available
    @isTest
    static void breakingLimitsDML0() {
        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        // Query form data setup
        Governor_Limits__c governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '0';
        update governerLimit;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        Test.startTest();
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);
        // when limit reached Step will be in : In Progress step
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
   
    //Run class without any limits left DML limit
    static testMethod void breakingLimitsInStartDML(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c,DML_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_limit__c = '0';
        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);        
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true, 'No Steps returned as Limit Reached.'); // Modified as part of EDGE-222326
        Test.stopTest();
    }
     //when number got updated
    @isTest
    static void numberGroupProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Number_Group__c> numGroupList = new List<Number_Group__c>();
        // Query form data setup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        numGroupList = [SELECT ID, Product_Configuration__c FROM Number_Group__c];
        cscfga__Product_Configuration__c prd = [SELECT Id,Marketable_Offer__r.Name,
                                                cscfga__Product_Definition__r.product_Specification__c
                                                FROM cscfga__Product_Configuration__c
                                                WHERE id =: numGroupList[0].Product_Configuration__c];
        Test.startTest(); 
        Orchestration_UpdateFnnDetails updateNumberGroupDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateNumberGroupDetails.process(orchStepList);
        Test.stopTest();
        // Query for updated numberList after processing
        numGroupList  = [SELECT ID, Product_Configuration__c FROM Number_Group__c];
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');
        System.assertEquals(orchStepList[1].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
        System.assertEquals(orchStepList[2].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
        
    }
   
    //Partial records processed
    /*static testMethod void breakingLimitsInCPULimit(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        Orchestration_ProcessedRecords processedRecords;
        // Update the Vustom Limits to check no updation is done
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c,DML_limit__c,CPU_limit__c,DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.CPU_limit__c = '130';
   
        update governerLimit;

        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,JSON__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateFnnDetails updateFnnDetails = new Orchestration_UpdateFnnDetails();
        orchStepList = updateFnnDetails.process(orchStepList);      
       
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Partial records processed');
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, 'In Progress');
        if (orchStepList[0].JSON__c != null) {
            //Store deserialized Json
            processedRecords = (Orchestration_ProcessedRecords) JSON.deserialize(orchStepList[0].JSON__c, Orchestration_ProcessedRecords.class);
        }
        System.assertEquals(processedRecords.numberIds != null , true);
        Test.stopTest();
    }*/
}