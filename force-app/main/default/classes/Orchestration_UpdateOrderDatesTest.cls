/**================================================================
* Appirio, Inc
* Name: Orchestration_UpdateOrderDatesTest
* Class: Orchestration_UpdateOrderDates
* Created Date: June 04, 2020
* Created By: Shweta Khandelwal
==================================================================
 Change.No.    Developer Name          Date          Story Description
 1.            Milos Djordjevic	      08-06-2021	  EDGE-222326 : Modified assert to check for empty list instead of null
 */

@isTest
public class Orchestration_UpdateOrderDatesTest {
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
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1); 

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'Primary Order';
        ord.csord__Account__c = accountList[0].id;
        ord.csord__Status2__c = 'Complete';
        ord.csord__Order_Request__c = orderReqList[0].id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';
        ord.isTransientComplete__c = false;
        ord.csord__Start_Date__c = Date.newInstance(2016, 12, 9);
        insert ord;

        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 4);
        orderList[0].csord__Primary_Order__c = ord.id;
        orderList[1].csord__Primary_Order__c = ord.id;
        insert orderList;
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true,4,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
         
        servlist= Orchestration_TestUtility.buildService(true,2,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        attachmentList = Orchestration_TestUtility.buildAttachment(true,2,servlist,productconfiglistList[0].id);
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
   //Build Process Records through wich the Steps will be executed.
        processList[1].Order__c = null; // Process where order is null
        processList[0].Order__c = ord.id;

        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,4,processList);
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        insert orchStepList;

    }
    
    // Date updated sucessfully
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Test.startTest();
        Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
        orchStepList = updateOrderDates.process(orchStepList);
        orderList = [SELECT ID,csord__Start_Date__c FROM csord__Order__c];
        System.assertEquals(orderList[0].csord__Start_Date__c, Date.today());
  
    }
    
    // Limits got hit
    static testMethod void breakingLimits(){
         //Query to get the Data for Processing 
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //Updatation to update theLImit to perform partial updation
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
       Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
       orchStepList = updateOrderDates.process(orchStepList);
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(orchStepList.isEmpty(), true);  // Modified as part of EDGE-222326
        Test.stopTest();
    }
    // Limits got hit
    static testMethod void breakingLimitsDML1(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
       Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
       orchStepList = updateOrderDates.process(orchStepList);
       orderList = [SELECT Id, Name, csord__Start_Date__c 
                    FROM csord__Order__c];

        System.debug('date '+orderList[0].csord__Start_Date__c);
       System.assertEquals(orderList[0].csord__Start_Date__c, Date.today());
        
       
        Test.stopTest();
    }
    // Limits got hit
    static testMethod void breakingLimitsDML0(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
       Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
       orchStepList = updateOrderDates.process(orchStepList);
       // Limit got hit and nothing update on step , so it will show same message 
       System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
       
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
        Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
        orchStepList = updateOrderDates.process(orchStepList);
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true); // Modified as part of EDGE-222326
        Test.stopTest();
    }
    
    static testMethod void breakingLimitsSOQL2(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
         // Update the Custom Limits to check no updation is done
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '2';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
        orchStepList = updateOrderDates.process(orchStepList);
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true); // Modified as part of EDGE-222326
        Test.stopTest();
    }
    
    // To cover inner catch : Provinding Invalid JSON : Error Condition
       static testMethod void breakingLimitsInnerCatch(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
        for(CSPOFA__Orchestration_Step__c step : orchStepList){
           step.JSON__C = OrchestratorConstants.SystemConstant.AttachmentMsg;
        }
        update orchStepList;              
      Orchestration_UpdateOrderDates updateOrderDates = new Orchestration_UpdateOrderDates();
        orchStepList = updateOrderDates.process(orchStepList);
       
        System.assertEquals(orchStepList[0].CSPOFA__Status__c ,OrchestratorConstants.OrchestratorStep.Error);
       
        Test.stopTest();
    }
    
   

}