/**================================================================
 * Name: Coms_SubParallelismUtil_Test
 * Class: Coms_SubscriptionParallelismUtil
 * Created Date: 
 * Created By: 
 ==================================================================*/
@isTest
public class Coms_SubParallelismUtil_Test {
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
        //List of Marketable Offer
        List<Marketable_Offer__c> marketableOffer = new List<Marketable_Offer__c>();
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
        
        //Build Marketbale Offer
        marketableOffer = Orchestration_TestUtility.buildMarkertableOffer(true,1);
        //insert marketableOffer;

        //Build Data to Perform Actions on
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 4);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfigList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 2, accountList[0].id, orderList, productconfigList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
        subscriptionList[0].MarketableOffer__c = marketableOffer[0].Id;
        insert subscriptionList;
               
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 2, processTempList[0].id, orderList, subscriptionList, accountList[0].id, null);
        processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;        
        insert processList;
        orchStepList = Orchestration_TestUtility.buildOrchStep(true, 2, processList);
         OrchestrationStepDetails__c cs = new OrchestrationStepDetails__c();
        cs.Name='Sub_Provision-4';
        cs.OrchClassname__c='Orchestration_GeneratePriceSch_Handler';        
     insert cs;
        OrchestrationStepDetails__c cs1 = new OrchestrationStepDetails__c();
        cs1.Name='Sub_Activation-2';
        cs1.OrchClassname__c='Orchestration_GeneratePriceSch_Handler';        
     insert cs1;
    }
    @isTest
    static void ProcessTest() {
        String str='';
        Map<String,Object>payloadMap=new Map<String,Object>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Order__c FROM CSPOFA__Orchestration_Step__c];
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);                 
            }
        }
        Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        payloadMap.put('StepId',orchStepList[0].Id);
        payloadMap.put('subscriptionIds',subscriptionIds);
        payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
        str=(String)JSON.serialize(payloadMap);
        system.debug('Str### '+str);
        System.Test.startTest();        
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Provision',4); 
       /* Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Provision',5);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Provision',7);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Provision',9);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Provision',13);*/
        System.Test.stopTest();

        
       // System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
    @isTest
    static void ProcessSubscriptionActivationTest() {
        String str='';
        Map<String,Object>payloadMap=new Map<String,Object>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Order__c FROM CSPOFA__Orchestration_Step__c];
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);                 
            }
        }
        Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        payloadMap.put('StepId',orchStepList[0].Id);
        payloadMap.put('subscriptionIds',subscriptionIds);
        payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c);
        str=(String)JSON.serialize(payloadMap);
        system.debug('Str### '+str);
        System.Test.startTest();        
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',2); 
        /*Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',4);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',12);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',14);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',19);
        Coms_SubscriptionParallelismUtil.process(str,'Subscription Fulfilment Process_Activation',20);*/
        System.Test.stopTest();

        
       // System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
}