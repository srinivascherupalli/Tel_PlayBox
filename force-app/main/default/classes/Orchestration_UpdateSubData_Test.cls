/**================================================================
* Name: Orchestration_UpdateSubData_Test
* Main Class : Orchestration_UpdateSubscriptionData
* Description: Class to test orchestrastion step to update subscription data
* Created Date: 
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_UpdateSubData_Test {
@Testsetup static void dataSetup(){
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
        List<Charge_Line_Item__c> cLIs = new List<Charge_Line_Item__c>();
        List<Discount_Line_Item__c> dSLIs = new List<Discount_Line_Item__c>();
        List<Price_Schedule_Line_Item__c> pSLIs = new List<Price_Schedule_Line_Item__c>();
        List<Tier_Line_Item__c> tLIS = new List<Tier_Line_Item__c>();
        List<Number__c> numberLst = new List<Number__c>();
    List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();

        //Governor Limit Creation
        governerLimit = Orchestration_TestUtility.buildLimits();

        //Build Accounts to Store the Orders
        accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;
    
        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = accountList[0].Id;
        ba.Billing_Account_Number__c = '123123122234';
        ba.Status__c = 'Allocated';
    //ba.isCacheUpdated__c=true;
        insert ba;
        //Build Marketbale Offer
        marketableOffer = Orchestration_TestUtility.buildMarkertableOffer(true,1);
        //insert marketableOffer;

        //Build Data to Perform Actions on
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 4);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(false, 1);
    processTempList[0].Name='Subscription Fulfilment Process_Provision';
            processTempList[0].CSPOFA__Process_Type__c = 'New Provide';
            processTempList[0].CSPOFA__Processing_Mode__c = 'Foreground';
    insert processTempList;
        productconfigList = Orchestration_TestUtility.buildProductConfiguration(true, 7);
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscriptionWOReplace(false, 4, accountList[0].id, orderList, productconfigList[0].id, solutionList[0].id);
        subscriptionList[1].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
        subscriptionList[0].MarketableOffer__c = marketableOffer[0].Id;
    subscriptionList[0].Billing_Account__c = ba.Id;
   // subscriptionList[0].csordtelcoa__Subscription_Number__c='SN-001234';
    //subscriptionList[0].isCacheUpdated__c=true;
        insert subscriptionList;
          servlist= Orchestration_TestUtility.buildServiceWOReplace(false,1,subscriptionList[0].id,orderReqList[0].id,orderList[0].id, productconfigList[0].id);
    servlist[0].csordtelcoa__Product_Configuration__c = productconfigList[0].id;
        insert servlist;
        
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        //cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
       // cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
    cLIs[0].CorrelationId__c='';
        insert cLIs;
        
        dSLIs.addAll(Orchestration_TestUtility.buildDLIs(true, 1, cLIs));
        pSLIs.addAll(Orchestration_TestUtility.buildPSLIs(true, 1, cLIs));
        
        tLIS.addAll(Orchestration_TestUtility.buildTLIs(true, 1, pSLIs));
        
        numberLst = Orchestration_TestUtility.buildNumber(false, 4, productconfigList, servlist[0].id, subscriptionList[0].id);
       // numberLst[0].Status__c = 'RESERVED';
        //numberLst[1].Status__c = 'DISCONNECT PENDING';
        //numberLst[2].Status__c = 'Disconnect In Progress';
        //numberLst[3].Status__c = 'Provisioning In Progress';
       // numberLst[4].Status__c = 'Provisioned';
        //numberLst[5].Status__c = 'Disconnected';
        //numberLst[6].Status__c = 'In Progress';
       // numberLst[0].isCacheUpdated__c=true;
     //  numberLst[0].Product_Configuration__c = productconfigList[0].Id;
        //    numberLst[0].Subscription_number__c = subscriptionList[0].id;
         //   numberLst[0].Service_Id__c = servlist[0].id;
    numberLst[0].Subscription_number__c=subscriptionList[0].csordtelcoa__Subscription_Number__c;
        insert numberLst; 
    
Price_Schedule_Discount_Association__c psda=new Price_Schedule_Discount_Association__c();
    psda.Name='test psda';
    psda.priceScheduleInstance__c=pSLIs[0].id;
    insert psda;
    
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, null);
        processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
        processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null
        insert processList;
    Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numberLst[1].Id);
      /*  OP.numberIds.add(numberLst[0].Id);
        OP.numberIds.add(numberLst[0].Id);
        OP.numberIds.add(numberLst[0].Id);*/
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
    orchStepList[0].JSON__c = System.JSON.serialize(OP);
    insert orchStepList;
    }
    static testMethod void ProcessTestActive() {
        List<Id> subscriptionIds = new List<Id>();        
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
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        /*for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);               
            }
        }*/
        
        //Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        
        System.Test.startTest();
        Orchestration_UpdateSubscriptionData updSubData = new Orchestration_UpdateSubscriptionData();
        orchStepList = updSubData.process(orchStepList);
        
        Test.stopTest();
        System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
    static testMethod void ProcessHandlerTest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();       
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        
      //   Map<String,Orchestration_ProcessedRecords>processedIds= new Map<String,Orchestration_ProcessedRecords>();
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
         
         Map<String,Object>payloadMap=new Map<String,Object>();   
        Set<Id>orderIds=new Set<Id>();
      //   CSPOFA__Orchestration_Process_Template__c processTemp = [select id from CSPOFA__Orchestration_Process_Template__c Limit 1 ];
       // Account objAccount = [select id from Account Limit 1 ];
       // List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c from csord__Service__c];
      //  List<csord__Order__c> orderLists = [SELECT Id, Name,csord__Order_Request__c, csord__Identification__c from csord__Order__c];
      /*  List<csord__Subscription__c> subList = [SELECT Id, Name ,csordtelcoa__Subscription_Number__c ,csord__Order__c,
                                                csord__Identification__c,triggerBill_RTB__c,csord__Status__c,MarketableOffer__r.Auto_Expired_Entity__c,
                                                csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                                                csordtelcoa__Product_Configuration__r.ConfigurationType1__c
                                                from csord__Subscription__c where MarketableOffer__c != null];
        subList[0].csord__Order__c = orderLists[0].id; 
        subList[0].csord__Status__c = 'Ready for Activation'; 
        //subList[0].isCacheUpdated__c=true;
        update subList;*/
      //  List<Number__c> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c];
      //  numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
       // numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
       // numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
       // numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
      //  numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
     //   numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
     //   numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
      //  numList[0].isCacheUpdated__c=true;
      //  update numList;      
              
      //  processList = Orchestration_TestUtility.buildProcess(true,1,processTemp.id,orderLists,subList,objAccount.id,services[0].id);
     //   processList[0].csordtelcoa__Service__c = services[0].Id;
     //   update processList;
        
       /* Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);*/
        
        Orchestration_ProcessedRecords processedIds = new Orchestration_ProcessedRecords();
        
       /* List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,processList);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;*/
        //Query to get the Data for Processing  
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        /*for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);               
            }
        }*/
        
       
        //Coms_PlatformCacheUtil.insertChargeLineItemsToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
       // Coms_PlatformCacheUtil.insertDiscountLineItemToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        //Coms_PlatformCacheUtil.insertPriceScheduleLineItemToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        System.Test.startTest();
         Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName','Subscription Fulfilment Process_Provision');
      //  if(OP!=null)
       //     processedIds.put(orchStepList[0].Id,OP);
        payloadMap.put('ProcessedIds',processedIds);
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        
        Test.stopTest();
        System.assert(orchStepList[0].CSPOFA__Status__c!=null);
    }
  static testMethod void ProcessCreateOrchProcessTest() {
        Test.startTest();
        List<csord__Subscription__c> subscriptionList = [SELECT Id, Name, csord__Status__c from csord__Subscription__c LIMIT 1]; 
        CSPOFA__Orchestration_Process_Template__c processTemp = [select id,name from CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        CSPOFA__Orchestration_Process__c processRec =Orchestration_UpdSubsData_Handler.createOrchestrationProcess(processTemp.id,subscriptionList[0].Id);
        Test.stopTest();
        System.assert(processRec!=null);       
    }
     static testMethod void ProcessCLITest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        Test.startTest();
        Coms_PlatformCacheUtil.insertChargeLineItemsToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessPSLITest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        Test.startTest();
        Coms_PlatformCacheUtil.insertPriceScheduleLineItemToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessDLITest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        Test.startTest();
        Coms_PlatformCacheUtil.insertDiscountLineItemToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessTLITest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        Test.startTest();
        Coms_PlatformCacheUtil.insertTierLineItemToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessPSDATest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        Test.startTest();
        Coms_PlatformCacheUtil.insertPriceScheduleDiscountAssociationToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessNumberTest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        system.debug('subnumber '+orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c);
        List<Number__c> numberLst = new List<Number__c>();
        numberLst = [SELECT ID,Subscription_number__c From Number__c];
        for(Number__c num: numberLst){
            num.Subscription_number__c = orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c;
        }
    update numberLst;
        Test.startTest();
        //Coms_PlatformCacheUtil.insertSubscriptionToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
        Coms_PlatformCacheUtil.insertNumberToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
    static testMethod void ProcessCLINegativeTest() {
        List<Id> subscriptionIds = new List<Id>(); 
        String payloadStr='';
        Map<String,Object>payloadMap=new Map<String,Object>();  
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //List<sObject> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c LIMIT 1];
        
         orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                        cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Test.startTest();
        Coms_PlatformCacheUtil.insertChargeLineItemsToCache(orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);        
        payloadMap.put('StepId',orchStepList[0].Id);        
        payloadMap.put('subscriptionId',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
        payloadMap.put('OrchName',orchStepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
        
        payloadStr=(String)JSON.serialize(payloadMap);
        charge_line_item__c chrg = [SELECT Id, LastModifiedDate,status__c, serviceId__r.csord__Subscription__c, chargeType__c, BusinessID__c, CorrelationId__c, serviceId__r.Scenario_Type__c, billingSpecIdentifier__c, serviceId__r.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, serviceId__c 
                                    FROM Charge_Line_Item__c WHERE serviceId__r.csord__Subscription__c =:orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c LIMIT 1];
        chrg.chargeType__c='';
        update chrg;
        system.debug('LastModifiedDate '+chrg.LastModifiedDate);
        Orchestration_UpdSubsData_Handler handler = new Orchestration_UpdSubsData_Handler();
        handler.processUpdate(payloadStr);
        Test.stopTest();
    }
}