/**================================================================
* Name: Orchestration_SetOrderStatusTest
* Main Class : Orchestration_SetOrderStatus
* Created Date: 05/03/2021
* Created By: Sayantan
==================================================================*/
@isTest(SeeAllData=false)

public class Orchestration_SetOrderStatusTest {
    //Test Data Setup
    @Testsetup static void dataSetup(){
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
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Attachment for the services
        list<Attachment> attachmentList= new list<Attachment>();
        //Custom setting
        EnvironmentVariable__c env = new EnvironmentVariable__c();

        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true , 3);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);
        
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true,3,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
        
        servlist= Orchestration_TestUtility.buildService(false,3,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[2].csordtelcoa__Replaced_Service__c = null;
        insert servlist;

        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[2].id;
        processList[2].Order__c = null;
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,3,processList);
        orchStepList[1].CSPOFA__Orchestration_Process__c = processList[1].Id;
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
         
        insert orchStepList;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(true,2,servlist,productconfiglistList[0].id); 
        env = Orchestration_TestUtility.buildENV(true,1);
        
    }
    
    //Main method Test : Where events are getting publish
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        list<Attachment> attachmentList= new list<Attachment>();
        List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
        csord__Service__c service = new csord__Service__c();
        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        JSON__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csordtelcoa__Replaced_Service__c,
                        CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, 
                        CSPOFA__Orchestration_Process__r.cspofa__account__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.Order__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        Test.startTest();
        Orchestration_SetOrderStatus setOrderStatus = new Orchestration_SetOrderStatus();
        orchStepList = setOrderStatus.process(orchStepList);   
        // step for which events are getting sucessfully publish
        System.assertEquals(orchStepList[0].CSPOFA__Message__c ,'Success: Records processed - Order Status Updated'); 
        Test.stopTest();
    }
    
        
   
   //Run class without any limits left
   static testMethod void breakingLimitsInStart(){
        
       List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
       Governor_Limits__c governerLimit = new Governor_Limits__c();
       // Update the Custom Limits to check no updation is done
       governerLimit = [SELECT Id, SOQL_limit__c
                        FROM Governor_Limits__c];
       governerLimit.SOQL_limit__c = '0';
       update governerLimit;
       Test.startTest();
       orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                       CSPOFA__Message__c
                       FROM CSPOFA__Orchestration_Step__c];
       Orchestration_SetOrderStatus setOrderStatus = new Orchestration_SetOrderStatus();
       orchStepList = setOrderStatus.process(orchStepList);
       boolean isNull = orchStepList == null ? true : false;
       //No Steps will be returned and nothing will be updated as Limits were reached
       System.assertEquals(isNull, true);
       Test.stopTest();
   }
   
   
   
   // When process doesnot have order to proceed
   static testMethod void stepProcessWithoutOrder(){
       List<EventBusSubscriber> highList = new List<EventBusSubscriber>();
       List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
       Governor_Limits__c governerLimit = new Governor_Limits__c();
       governerLimit = [SELECT Id, DML_Rows_limit__c
                        FROM Governor_Limits__c];
       governerLimit.DML_Rows_limit__c = '1';
       update governerLimit;
       Test.startTest();
       
       List<CSPOFA__Orchestration_Process__c> processList = [SELECT ID FROM CSPOFA__Orchestration_Process__c LIMIT 2];
       processList[0].Order__c = null;
       processList[1].Order__c = null;
       update processList;
       orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                       CSPOFA__Message__c
                       FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__c =:processList LIMIT 2]; 
       
       Orchestration_SetOrderStatus setOrderStatus = new Orchestration_SetOrderStatus();
       orchStepList = setOrderStatus.process(orchStepList);
       System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Error: Step do not have an order');
       System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'Error: Step do not have an order');
       Test.stopTest();
   }

}