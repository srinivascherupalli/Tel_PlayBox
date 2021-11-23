/**================================================================
* Appirio, Inc
* Name: Orchestration_OrderNextAvailStatusTest
* Main Class : Orchestration_OrderNextAvailableStatus
* Created Date: June 21, 2020
* Created By: Shweta Khandelwal
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_OrderNextAvailStatusTest {

     @Testsetup static void dataSetup(){
        //Declare different list to store data 
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        //Creating data for process
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,3);
        oppList =  Orchestration_TestUtility.buildOpp(false,3,accountList);
        insert oppList;  

        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 5);
        orderList[0].csordtelcoa__Opportunity__c = oppList[0].id;
        orderList[0].isAppointmentCompleted__c = false;
        orderList[1].isAppointmentCompleted__c = true; 
        orderList[1].csordtelcoa__Opportunity__c = oppList[1].id;
        orderList[2].csordtelcoa__Opportunity__c = oppList[2].id; 
        insert orderList;
         
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        prdList = Orchestration_TestUtility.buildProductDefination(true,1);
        insert offerList; 
         
        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c='Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;   
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;
         
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,3);
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id; 
        productconfiglistList[0].Type__c ='Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c =pcNewMdm.id; 
        productconfiglistList[1].ConfigurationType1__c = 'ProductComponent'; 
        insert productconfiglistList;  

        solutionList = Orchestration_TestUtility.buildSolution(true,1);

        subscriptionList = Orchestration_TestUtility.buildSubscription(false,6,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
        subscriptionList[1].csord__Status__c = 'Pending';
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].Name = 'Unified Communication Tenancy Solution';
        subscriptionList[2].csord__Status__c = 'Not Active'; 
        insert subscriptionList;
         
        servlist= Orchestration_TestUtility.buildService(false,5,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id; 
        servlist[3].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; 
        servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id; 
        servlist[1].csord__Subscription__c = subscriptionList[1].id; 
        servlist[2].csord__Subscription__c = subscriptionList[2].id; 
        servlist[0].Appointment_Required__c = 'true';
        servlist[0].csord__Order__c = orderList[1].id;
        servlist[1].Appointment_Required__c = 'true';
        servlist[2].Appointment_Required__c = 'false'; 
        insert servlist; 
        
        //Build Process Records through wich the Steps will be executed. 
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[1].id;
        processList[2].Order__c = null; 
        insert processList;
         
        orchStepList = Orchestration_TestUtility.buildOrchStep(true,3,processList);
 
     }

     // When order status updated to  Status = 'Ready for Submit' : case 1
    static testMethod void ProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];

  
        //First run of process creates the JSON step
        Orchestration_OrderNextAvailableStatus orderNextAvailableStatus = new Orchestration_OrderNextAvailableStatus();
        orchStepList = orderNextAvailableStatus.process(orchStepList);
          //Second run excludes the records processed in first run
        orderNextAvailableStatus = new Orchestration_OrderNextAvailableStatus();
        orchStepList = orderNextAvailableStatus.process(orchStepList);
        List<csord__Service__c> services = [SELECT ID,csord__Order__c,csord__Order__r.csord__Status2__c,
                                            csord__Order__r.RecordTypeId 
                                            FROM csord__Service__c
                                            WHERE csord__Order__r.isAppointmentCompleted__c = true
                                            AND Appointment_Required__c = 'true'AND modelChange__c = false];
        String recName = [SELECT Id, Name FROM RecordType WHERE Id =: services[0].csord__Order__r.RecordTypeId LIMIT 1].Name;
        // Assert to check service status
        System.assertEquals(OrchestratorConstants.OrderStatus.ReadyForSubmit, services[0].csord__Order__r.csord__Status2__c);
        System.assertEquals(recName, 'Ready for Submit With Appointment');
        
        List<csord__Service__c> serviceApp = [SELECT ID,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Order__r.RecordTypeId
                                              FROM csord__Service__c
                                              WHERE csord__Order__r.isAppointmentCompleted__c = false
                                              AND Appointment_Required__c = 'true'AND modelChange__c = false];
        String recNameApp = [SELECT Id, Name FROM RecordType WHERE Id =: serviceApp[0].csord__Order__r.RecordTypeId LIMIT 1].Name;
        // Assert to check service status
        System.assertEquals(OrchestratorConstants.OrderStatus.AppointmentRequired, serviceApp[0].csord__Order__r.csord__Status2__c);
        System.assertEquals(recNameApp, 'Appointment Required');
        Test.stopTest();
    }

     // When order status updated to  Status = 'Ready for Submit' : case 2 (isAppointmentRequired = false && isSubmitWithAppointment = false)
    static testMethod void ProcessTestElse() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Test.startTest();
        //Query from data setup
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Order__c, 
                        CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__r.isAppointmentCompleted__c
                        FROM CSPOFA__Orchestration_Step__c 
                        WHERE CSPOFA__Orchestration_Process__r.Order__r.isAppointmentCompleted__c = true 
                        LIMIT 1];

        
        csord__Service__c service = [SELECT ID, Appointment_Required__c,csord__Order__c,csord__Order__r.RecordTypeId
                                     FROM csord__Service__c 
                                     WHERE csord__Order__c =: orchStepList[0].CSPOFA__Orchestration_Process__r.Order__c];
        service.Appointment_Required__c = 'false';
        update service;
        
        Orchestration_OrderNextAvailableStatus orderNextAvailableStatus = new Orchestration_OrderNextAvailableStatus();
        orchStepList = orderNextAvailableStatus.process(orchStepList);
        List<csord__Service__c> services = [SELECT ID,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Order__r.RecordTypeId
                                            FROM csord__Service__c
                                            WHERE id =: service.id];
        String recNameApp = [SELECT Id, Name FROM RecordType WHERE Id =: services[0].csord__Order__r.RecordTypeId LIMIT 1].Name;
        // Assert to check service status
        System.assertEquals(OrchestratorConstants.OrderStatus.ReadyForSubmit, services[0].csord__Order__r.csord__Status2__c);
        System.assertEquals(recNameApp, 'Ready for Submit');
        Test.stopTest();
    }
    
   // Limit reached 
   static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // Query from data setup
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit; // Upadting limit for further process
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_OrderNextAvailableStatus orderNextAvailableStatus = new Orchestration_OrderNextAvailableStatus();
        orchStepList = orderNextAvailableStatus.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        // No step will return
        System.assertEquals(isNull, true);
        Test.stopTest();
    }
}