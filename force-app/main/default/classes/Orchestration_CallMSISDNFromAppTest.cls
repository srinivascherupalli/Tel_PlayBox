/**================================================================
* Appirio, Inc
* Name: Orchestration_CallMSISDNFromAppTest
* Class: Orchestration_CallMSISDNFromAppointment
* Created Date: June 04, 2020
* Created By: Shweta Khandelwal
==================================================================*/

@isTest
public class Orchestration_CallMSISDNFromAppTest {
    

     @Testsetup static void dataSetup(){
         // List declartion for various objects to store data
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionListNew = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
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
        
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 2, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[0].Order__c = ord.id;
        processList[1].Order__c = null; 

        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,2,processList);
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        insert orchStepList;

    }
    
    // When No temp attached with process
    static testMethod void ProcessNOTemp() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        // Query form datasetup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Test.startTest();
        Orchestration_CallMSISDNFromAppointment appointment = new Orchestration_CallMSISDNFromAppointment();
        orchStepList = appointment.process(orchStepList);
        // Assert to check template missing message
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'MSISDN Template is missing in the org');

  
    }
    
    // Process when process have templates
     static testMethod void ProcessWithTemp() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
         // Query form datasetup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        List<CSPOFA__Orchestration_Process_Template__c> TempList = [SELECT ID, Name 
                                                                   FROM CSPOFA__Orchestration_Process_Template__c]; 
         for(CSPOFA__Orchestration_Process_Template__c Temp : TempList){
             Temp.Name = OrchestratorConstants.OrchesTemplateName.msisdnReserveTemplate;
         } 
         update TempList; // Name updation
         
        Test.startTest();
        Orchestration_CallMSISDNFromAppointment appointment = new Orchestration_CallMSISDNFromAppointment();
        orchStepList = appointment.process(orchStepList);
        List<CSPOFA__Orchestration_Process__c> process = [SELECT ID FROM CSPOFA__Orchestration_Process__c];
        // Assert to check process size 
        SYSTEM.assertEquals(process.size(), 3) ;

  
    }
    
    // Limits got hit
    static testMethod void breakingLimits(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
         // Query form datasetup
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit; // updation for further process
        Test.startTest();
                List<CSPOFA__Orchestration_Process_Template__c> TempList = [SELECT ID, Name 
                                                                   FROM CSPOFA__Orchestration_Process_Template__c]; 
         for(CSPOFA__Orchestration_Process_Template__c Temp : TempList){
             Temp.Name = OrchestratorConstants.OrchesTemplateName.msisdnReserveTemplate;
         } 
         update TempList;// Name updation
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_CallMSISDNFromAppointment appointment = new Orchestration_CallMSISDNFromAppointment();
        orchStepList = appointment.process(orchStepList);
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(orchStepList == null ? true :false, true);
        Test.stopTest();
    }
   
    // Limits got hit
    static testMethod void breakingLimitsDML0(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
         // Query form datasetup
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '0';
        update governerLimit;
        Test.startTest();
                List<CSPOFA__Orchestration_Process_Template__c> TempList = [SELECT ID, Name 
                                                                   FROM CSPOFA__Orchestration_Process_Template__c]; 
         for(CSPOFA__Orchestration_Process_Template__c Temp : TempList){
             Temp.Name = OrchestratorConstants.OrchesTemplateName.msisdnReserveTemplate;
         } 
         update TempList; // Name updation
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_CallMSISDNFromAppointment appointment = new Orchestration_CallMSISDNFromAppointment();
        orchStepList = appointment.process(orchStepList);
       // Limit got hit and nothing update on step , so it will show same message 
       System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
       
        Test.stopTest();
    }
    
    // Limits got hit
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Query form datasetup
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit; // Updation for further  process
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_CallMSISDNFromAppointment appointment = new Orchestration_CallMSISDNFromAppointment();
        orchStepList = appointment.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
    
  
    
   

}