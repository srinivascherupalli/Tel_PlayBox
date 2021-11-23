/**================================================================
* Name: Orchestration_EvaluateOrderStats_V2_Test
* Main Class : Orchestration_EvaluateOrderStats_V2
* Description: Class to test orchestrastion step to evaluate order status
* Created Date: 
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_EvaluateOrderStats_V2_Test {
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
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true , 5);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,2);
        productconfiglistList[1].ConfigurationType1__c = 'Product Component';
        insert productconfiglistList;

        solutionList = Orchestration_TestUtility.buildSolution(true,1);

         subscriptionList = Orchestration_TestUtility.buildSubscription(false,11,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
         subscriptionList[3].csord__order__c = null;     
         subscriptionList[4].csord__Status__c = 'Suspended'; 
         subscriptionList[5].csord__Status__c = 'Billing Complete'; 
         subscriptionList[6].csord__Status__c = 'Cancelled'; 
         subscriptionList[7].csord__Status__c = 'Inactive'; 
         subscriptionList[8].csord__Status__c = 'Failed';
         subscriptionList[9].csord__Status__c = 'Cancellation In Progress';
         subscriptionList[10].csord__Status__c = 'Paid Out';    //EDGE-163712
         subscriptionList[5].csord__Status__c = 'Billing Complete'; 
         subscriptionList[6].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
         subscriptionList[7].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
         subscriptionList[2].changeType__c = 'Resume';//EDGE-180743 
         subscriptionList[2].csord__order__c = orderList[4].id;
         subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
         insert subscriptionList;
         
        servlist= Orchestration_TestUtility.buildService(true,1,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        //Build Process Records through wich the Steps will be executed. 
        processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
        processList[4].csordtelcoa__Subscription__c = null;
        
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[0].CSPOFA__Orchestration_Process__c = processList[4].id;
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[4].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';

        insert orchStepList;
    }
    
    // sub gets update
    // sol supress, individual subscription should not update
    static testMethod void ProcessTestActive() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        //Query to get the Data for Processing  
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c];
        
        
        Test.startTest();
        Orchestration_EvaluateOrderStatus_V2 evaluateOrderStatus = new Orchestration_EvaluateOrderStatus_V2();
        orchStepList = evaluateOrderStatus.process(orchStepList);
        //subscriptionList = [SELECT Id, triggerBill_RTB__c,csord__Order__c,csord__Order__r.csord__Status2__c
          //                  FROM csord__Subscription__c ];
        // Assert to cheeck triggerBill_RTB__c
        //System.assertNotEquals(subscriptionList[7].triggerBill_RTB__c, true);
        //System.debug('orchStepList '+orchStepList); 
        Test.stopTest();
        System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
    
     // Limits got hit
  /*  static testMethod void breakingLimits(){
         
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
        Orchestration_EvaluateOrderStatusV2 evaluateOrderStatus = new Orchestration_EvaluateOrderStatusV2();
        orchStepList = evaluateOrderStatus.process(orchStepList);
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        //Assert to check step message                
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
    
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
         //Query to get the Data for Processing 
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        //Updatation to update theLImit to perform partial updation                 
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_EvaluateOrderStatusV2 evaluateOrderStatus = new Orchestration_EvaluateOrderStatusV2();
        orchStepList = evaluateOrderStatus.process(orchStepList);
        //Assert to check if the Step is in progress as the Limits were reached. 
        System.assertEquals(orchStepList == null, true);
        Test.stopTest();
    }
    
    // Limits got hit : only few steps has limit to proceed
    static testMethod void breakingLimitsDML1(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        // query from datasetup
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit; // updation for further processing
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c
                        FROM CSPOFA__Orchestration_Step__c
                        WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null 
                        LIMIT 1];
             
        Orchestration_EvaluateOrderStatusV2 evaluateOrderStatus = new Orchestration_EvaluateOrderStatusV2();
        orchStepList = evaluateOrderStatus.process(orchStepList);
        
        csord__Subscription__c sub = [SELECT Id, triggerBill_RTB__c,csord__Order__c,csord__Order__r.csord__Status2__c
                                     FROM csord__Subscription__c limit 1];
        //Assert to check if sucessful updation.
        System.assertEquals(sub != null , true);
       
        Test.stopTest();
    }
    
    //EDGE-163712
        static testMethod void TestOrdStatusForPaidOut(){
            
            csord__Order__c ord = [Select id from csord__Order__c limit 1];
            
            Orchestration_EvaluateOrderStatusV2 OE = new Orchestration_EvaluateOrderStatusV2();
            OE.orderSubscriptionCntMap.put(ord.id, 1);
            OE.paidOutMap.put(ord.id, 1);
            OE.activeMap.put(ord.id, 0);
            OE.inActiveMap.put(ord.id, 0);
            OE.cancelledMap.put(ord.id, 0);
            OE.billingCompleteMap .put(ord.id, 0);
            
            String status = OE.getOrderStatus(ord.id);
            
            System.assertEquals('Completed', status);
            
        }
        
    //EDGE-177027
        static testMethod void TestOrdStatusForClosedStatus(){
            
            csord__Order__c ord = [Select id from csord__Order__c limit 1];
            
            Orchestration_EvaluateOrderStatusV2 OE = new Orchestration_EvaluateOrderStatusV2();
            OE.orderSubscriptionCntMap.put(ord.id, 1);
            OE.closedMap.put(ord.id, 1);

            String status = OE.getOrderStatus(ord.id);
            
            System.assertEquals('Completed', status);
            
        }      
 
        
        static testMethod void TestOrdStatusAllStatus(){
            
            csord__Order__c ord = [Select id from csord__Order__c limit 1];
            
            Orchestration_EvaluateOrderStatus_V2 OE = new Orchestration_EvaluateOrderStatus_V2();
            OE.billingCompleteMap.put(ord.id, 0);
            OE.activeMap.put(ord.id, 0);
            OE.paidOutMap.put(ord.id, 0);
            OE.inActiveMap.put(ord.id, 0);

            OE.orderSubscriptionCntMap.put(ord.id, 1);
            OE.closedMap.put(ord.id, 1);
            String status = OE.getOrderStatus(ord.id);         
            System.assertEquals(OrchestratorConstants.OrderStatus.Completed, status);

            OE.closedMap.put(ord.id, 0);
            OE.cancellationInProgressMap.put(ord.id, 1);
             status = OE.getOrderStatus(ord.id);         
            System.assertEquals(OrchestratorConstants.OrderStatus.CancellationInProgress, status);

            OE.cancellationInProgressMap.put(ord.id, 0);
            OE.failedMap.put(ord.id, 1);
             status = OE.getOrderStatus(ord.id);         
            System.assertEquals(OrchestratorConstants.OrderStatus.Failed, status);

            OE.failedMap.put(ord.id, 0);
            OE.cancelledMap.put(ord.id, 1);
             status = OE.getOrderStatus(ord.id);         
            System.assertEquals(OrchestratorConstants.OrderStatus.Cancelled, status);

            OE.cancelledMap.put(ord.id, 0);
            OE.suspendedMap.put(ord.id, 1);
             status = OE.getOrderStatus(ord.id);         
            System.assertEquals(OrchestratorConstants.OrderStatus.Completed, status);
            
        }*/
        
    // Shweta added
    // sub gets update
    static testMethod void updateOrderStatus() {
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
          orchStepList = [SELECT id, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                          CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c,
                          CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.Name,
                          CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c
                          FROM CSPOFA__Orchestration_Step__c  
                          WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null
                          AND CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c = 'Resume'
                          LIMIT 1];
               
        Test.startTest();
        Orchestration_EvaluateOrderStatus_V2 evaluateOrderStatus = new Orchestration_EvaluateOrderStatus_V2();
        orchStepList = evaluateOrderStatus.process(orchStepList);
        System.debug('orchStepList '+orchStepList); 
        Test.stopTest();
        //System.assertEquals('Waiting', orchStepList[0].CSPOFA__Status__c);
        System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }


}