/**================================================================
* Appirio, Inc
* Name: Orchestration_UpdateSubOrderStatusTest
* Created Date: May 22, 2020
* Created By: Shweta Khandelwal
 * 1.  Gnana	       08-06-2021		EDGE-222326 : Modified assert to check for empty list instead of null
==================================================================*/

@isTest
public class Orchestration_UpdateSubOrderStatusTest {
    
    //Test Data Setup
    @Testsetup static void dataSetup(){
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
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
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'In Error', orderReqList[0].id, false , 5);
        orderList[1].csord__Status2__c = 'Active';
        orderList[2].csord__Status2__c = 'In Progress';
        orderList[3].csord__Status2__c = 'Completed';
        insert orderList;
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);

        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false,5,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Order__c = orderList[1].id;
        subscriptionList[3].csord__Order__c = orderList[2].id;
        subscriptionList[2].csord__Order__c = orderList[3].id;
        subscriptionList[0].csord__Status__c = 'Not Block';
        subscriptionList[1].csord__Status__c = 'Active';
        subscriptionList[2].csord__Status__c = 'Suspended';
        subscriptionList[3].csord__Status__c = 'Block';
        insert subscriptionList;
        
        servlist= Orchestration_TestUtility.buildService(true,2,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        attachmentList = Orchestration_TestUtility.buildAttachment(true,2,servlist,productconfiglistList[0].id);

        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[4].Order__c = null; // A process whose order is null
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[4].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
       
        insert orchStepList;
        
    }
    
    //Method where last processed OrderId does not have same status
    static testMethod void ProcessTestNotSameStatus() {
        List<String> subscriptionStatusesList = new List<String>{ OrchestratorConstants.SubscriptionStatus.Active, OrchestratorConstants.SubscriptionStatus.Suspended };
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptions = new List<csord__Subscription__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, cspofa__Orchestration_Process__r.Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c,
                        CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
                        FROM CSPOFA__Orchestration_Step__c];
        subscriptions = [SELECT id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Status__c 
                         FROM csord__Subscription__c 
                         ];
        System.debug('sub all '+subscriptions);
        Test.startTest();
        Orchestration_UpdateSubOrderStatus updateSubOrderStatus = new Orchestration_UpdateSubOrderStatus();
        orchStepList = updateSubOrderStatus.process(orchStepList);
        subscriptions = [SELECT id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Status__c 
                         FROM csord__Subscription__c 
                         WHERE csord__Status__c NOT IN :subscriptionStatusesList]; 
         // order whose status is in subscriptionStatusesList marked as in error
        System.assertEquals(subscriptions[0].csord__Order__r.csord__Status2__c,  OrchestratorConstants.OrderStatus.InError);
      
        subscriptions = [SELECT id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Status__c 
                         FROM csord__Subscription__c 
                         WHERE csord__Status__c  IN :subscriptionStatusesList];
        // ord which has multiple sub , one have null status and another have Active, so marked In error
        System.assertEquals(subscriptions[0].csord__Order__r.csord__Status2__c,  OrchestratorConstants.OrderStatus.InError);
        // order whose status is in subscriptionStatusesList marked as completed
        System.assertEquals(subscriptions[1].csord__Order__r.csord__Status2__c,  OrchestratorConstants.OrderStatus.Completed);
        Test.stopTest();
        
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
        Orchestration_UpdateSubOrderStatus updateSubOrderStatus = new Orchestration_UpdateSubOrderStatus();
        orchStepList = updateSubOrderStatus.process(orchStepList);
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        //Assert to check if the Step is in progress as the Limits were reached.                
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
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
        Orchestration_UpdateSubOrderStatus updateSubOrderStatus = new Orchestration_UpdateSubOrderStatus();
        orchStepList = updateSubOrderStatus.process(orchStepList);
        //boolean isNull = orchStepList == null ? true : false;
        //No Steps will be returned and nothing will be updated as Limits were reached
        System.assertEquals(orchStepList.isEmpty(), true);
        Test.stopTest();
    }
        // When only few steps have limits
        static testMethod void breakingLimitsDML1(){
        List<csord__Order__c> orderList = new List<csord__Order__c>();    
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        Test.startTest();
        governerLimit = [SELECT Id, DML_Rows_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        orderList = [SELECT Id,csord__Status2__c FROM csord__Order__c];
            for(csord__Order__c ord: orderList){
                ord.csord__Status2__c = 'Active';
            } 
           update orderList; 
       
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 2];
        Orchestration_UpdateSubOrderStatus updateSubOrderStatus = new Orchestration_UpdateSubOrderStatus();
        orchStepList = updateSubOrderStatus.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'In Progress');
       
        Test.stopTest();
    }
     
}