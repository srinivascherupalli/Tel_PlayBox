/**================================================================
* Name: Orchestration_EvalOrderStat_Handler_Test
* Main Class : Orchestration_EvaluateOrderStats_Handler
* Description: Class to test orchestrastion step to evaluate order status
* Created Date: 
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_EvalOrderStat_Handler_Test {
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
        //List Marketable Offer
        List<Marketable_Offer__c>marketableOffer = new List<Marketable_Offer__c>();
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
        marketableOffer = Orchestration_TestUtility.buildMarkertableOffer(true,1); 
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,2);
        productconfiglistList[1].ConfigurationType1__c = 'Product Component';
        insert productconfiglistList;
        
        solutionList = Orchestration_TestUtility.buildSolution(true,1);
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false,11,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
       // subscriptionList[3].csord__order__c = null;     
        subscriptionList[1].csord__Status__c = 'Suspended'; 
        subscriptionList[2].csord__Status__c = 'Billing Complete'; 
        subscriptionList[6].csord__Status__c = 'Cancelled'; 
        subscriptionList[7].csord__Status__c = 'Inactive'; 
        subscriptionList[8].csord__Status__c = 'Failed';
        subscriptionList[9].csord__Status__c = 'Cancellation In Progress';
        subscriptionList[10].csord__Status__c = 'Paid Out';    //EDGE-163712
        subscriptionList[5].csord__Status__c = 'Billing Complete'; 
        subscriptionList[6].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[7].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].changeType__c = 'Resume';//EDGE-180743 
        subscriptionList[5].csord__order__c = orderList[4].id;
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        for(integer i = 0; i<=10; i++){
           subscriptionList[i].MarketableOffer__c = marketableoffer[0].id;
        }
        insert subscriptionList;
       
        servlist= Orchestration_TestUtility.buildService(true,1,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        //Build Process Records through wich the Steps will be executed. 
        processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id);
       // processList[4].csordtelcoa__Subscription__c = null;
        
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
       // orchStepList[4].JSON__c = System.JSON.serialize(OP);
        orchStepList[0].CSPOFA__Orchestration_Process__c = processList[4].id;
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[4].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        
        insert orchStepList;
    }
    
    
    static testMethod void ProcessTestActive() {
        String str='';
        List<Id> subscriptionIds = new List<Id>();
        Set<Id>orderIds=new Set<Id>();
        Map<String,Object> payloadMap=new Map<String,Object>();   
        
        Orchestration_ProcessedRecords processedRecords= new Orchestration_ProcessedRecords();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
         Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.subsIds = new Set<String>();
        
        
        //Query to get the Data for Processing  
        stepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                    CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                    cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                    FROM CSPOFA__Orchestration_Step__c];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            }
        }
       // system.debug('orderIds '+orderIds);
        for(Id ord:orderIds){
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord,false);
        }
        System.Test.startTest();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            payloadMap.put('StepId',step.Id);
            payloadMap.put('subscriptionIds',subscriptionIds);
            payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            payloadMap.put('ProcessedRecords',processedRecords);
            str=(String)JSON.serialize(payloadMap);
            //system.debug('Str### '+str);
            
            Orchestration_EvaluateOrderStats_Handler evaluateOrderStatus = new Orchestration_EvaluateOrderStats_Handler();
            evaluateOrderStatus.processUpdate(str);
            //subscriptionList = [SELECT Id, triggerBill_RTB__c,csord__Order__c,csord__Order__r.csord__Status2__c
            //                  FROM csord__Subscription__c ];
            // Assert to cheeck triggerBill_RTB__c
            //System.assertNotEquals(subscriptionList[7].triggerBill_RTB__c, true);
            //System.debug('orchStepList '+orchStepList); 
            
            System.assert(step.CSPOFA__Status__c!=null);
        }
        Test.stopTest();
    }
    /* static testMethod void TestOrdStatusForPaidOut(){

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

Orchestration_EvaluateOrderStatusV2 OE = new Orchestration_EvaluateOrderStatusV2();
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
    static testMethod void ProcessTestReplacement() {
        String str='';
        List<Id> subscriptionIds = new List<Id>();
        Set<Id>orderIds=new Set<Id>();
       List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        Map<String,Object> payloadMap=new Map<String,Object>();   
         CSPOFA__Orchestration_Process_Template__c processTemp = [select id from CSPOFA__Orchestration_Process_Template__c Limit 1 ];
        Account objAccount = [select id from Account Limit 1 ];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c from csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name,csord__Order_Request__c, csord__Identification__c from csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name ,csordtelcoa__Subscription_Number__c ,csord__Order__c,
                                                csord__Identification__c,triggerBill_RTB__c,csord__Status__c,MarketableOffer__r.Auto_Expired_Entity__c,
                                                csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                                                csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csordtelcoa__Replacement_Subscription__c
                                                from csord__Subscription__c LIMIT 2];
        subList[0].csordtelcoa__Replacement_Subscription__c=subList[1].id;
        
        //List<Number__c> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c];
        //numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        
        //update numList;      
              
        processList = Orchestration_TestUtility.buildProcess(true,1,processTemp.id,orderLists,subList,objAccount.id,services[0].id);
        processList[0].csordtelcoa__Service__c = services[0].Id;
        update processList;
        
        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
       OP.subsIds = new Set<String>();
        OP.subsIds.add(subList[0].id);
        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,processList);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;   
        Orchestration_ProcessedRecords processedRecords= new Orchestration_ProcessedRecords();
        //List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
         //Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        
        
        
        //Query to get the Data for Processing  
        stepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                    CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                    cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                    FROM CSPOFA__Orchestration_Step__c];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            }
        }
       // system.debug('orderIds '+orderIds);
        for(Id ord:orderIds){
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ord,false);
        }
        System.Test.startTest();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            payloadMap.put('StepId',step.Id);
            payloadMap.put('subscriptionIds',subscriptionIds);
            payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            payloadMap.put('ProcessedRecords',processedRecords);
            str=(String)JSON.serialize(payloadMap);
            //system.debug('Str### '+str);
            
            Orchestration_EvaluateOrderStats_Handler evaluateOrderStatus = new Orchestration_EvaluateOrderStats_Handler();
            evaluateOrderStatus.processUpdate(str);
            //subscriptionList = [SELECT Id, triggerBill_RTB__c,csord__Order__c,csord__Order__r.csord__Status2__c
            //                  FROM csord__Subscription__c ];
            // Assert to cheeck triggerBill_RTB__c
            //System.assertNotEquals(subscriptionList[7].triggerBill_RTB__c, true);
            //System.debug('orchStepList '+orchStepList); 
            
            System.assert(step.CSPOFA__Status__c!=null);
        }
        Test.stopTest();
    }
}