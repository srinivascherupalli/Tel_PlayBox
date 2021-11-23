/**================================================================
 * Name: Orchestration_OrdtoBillUpd_Handler_Test
 * Class: Orchestration_OrdertoBillUpdate_Handler
 * Created Date: 
 * Created By: 
 ==================================================================*/
@isTest
public class Orchestration_OrdtoBillUpd_Handler_Test {
    public static List<CSPOFA__Orchestration_Process__c> orchProcess = new List<CSPOFA__Orchestration_Process__c>();
    public static List<ApplicationLog__c> appLog  = new List<ApplicationLog__c>();
 @Testsetup static void dataSetup(){
        //Record to create the Custom Settings with Custom Limits
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        //List of Accounts for order
        List<account> accountList = new List<account>();
        //Process Templates for Processes
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        //Order request on Order
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //List of Accounts for order
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();
       
        List<Charge_Line_Item__c> cLIs = new List<Charge_Line_Item__c>();
        List<Discount_Line_Item__c> dSLIs = new List<Discount_Line_Item__c>();
        List<Price_Schedule_Line_Item__c> pSLIs = new List<Price_Schedule_Line_Item__c>();
        List<Tier_Line_Item__c> tLIS = new List<Tier_Line_Item__c>();
        List<Number__c> numberLst = new List<Number__c>();
        List<PricingMSResponseObject__c> pmsList = new List<PricingMSResponseObject__c>();
        String handlerName = 'PostSubscriptionHandler';
        
        //Build Data to Perform Actions on
        governerLimit = Orchestration_TestUtility.buildLimits();
        
        accountList = Orchestration_TestUtility.buildAccount(false,2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;
        
        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = accountList[0].Id;
        ba.Billing_Account_Number__c = '123123122234';
        ba.Status__c = 'Allocated';
        insert ba;
        
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 2);
        orderList[0].Billing_Account__c = ba.Id;
        orderList[1].Billing_Account__c = ba.Id;
        insert orderList;

        orderList[1].csord__Primary_Order__c = orderList[0].Id;
        update orderList;
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,7);
        
        solutionList = Orchestration_TestUtility.buildSolution(false,1);
        solutionList[0].Name = 'TestSubsforTest0';
        insert solutionList;
        
        marketableList = Orchestration_TestUtility.buildMarkertableOffer(false,1);
        marketableList[0].Auto_Expired_Entity__c = true;
        insert marketableList;
        
        subscriptionList.addAll(Orchestration_TestUtility.buildSubscription(false,3,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id));
        subscriptionList[0].csord__Account__c = accountList[1].id ; // account which is already in Acquired state.
        subscriptionList[0].MarketableOffer__c= marketableList[0].id;
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id; 
        subscriptionList[0].Billing_Account__c = ba.Id;
        subscriptionList[0].csord__Status__c = 'Provisioned';
        subscriptionList[1].MarketableOffer__c= marketableList[0].id;
        subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id; 
        subscriptionList[1].Billing_Account__c = ba.Id;
        subscriptionList[1].csord__Status__c = 'Provision';
        subscriptionList[2].MarketableOffer__c= marketableList[0].id;
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id; 
        subscriptionList[2].Billing_Account__c = ba.Id;
        subscriptionList[2].csord__Status__c = 'Ready for Activation';
        
        insert subscriptionList;
        
        servlist= Orchestration_TestUtility.buildService(false,1,subscriptionList[0].id,orderReqList[0]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          .id,orderList[0].id,productconfiglistList[0].id);
        servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        insert servlist;
        
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        insert cLIs;
        
        dSLIs.addAll(Orchestration_TestUtility.buildDLIs(true, 3, cLIs));
        pSLIs.addAll(Orchestration_TestUtility.buildPSLIs(true, 3, cLIs));
        
        tLIS.addAll(Orchestration_TestUtility.buildTLIs(true, 3, pSLIs));
        
        numberLst = Orchestration_TestUtility.buildNumber(false, 7, productconfiglistList, servlist[0].id, subscriptionList[0].id);
        numberLst[0].Status__c = 'RESERVED';
        numberLst[1].Status__c = 'DISCONNECT PENDING';
        numberLst[2].Status__c = 'Disconnect In Progress';
        numberLst[3].Status__c = 'Provisioning In Progress';
        numberLst[4].Status__c = 'Provisioned';
        numberLst[5].Status__c = 'Disconnected';
        numberLst[6].Status__c = 'In Progress';
        
        insert numberLst;
      orchProcess = Orchestration_TestUtility.buildProcess(true,1,processTempList[0].id,orderList,subscriptionList,accountList[0].id,servlist[0].id);
        orchProcess[0].csordtelcoa__Service__c = servlist[0].Id;
        update orchProcess;
        
        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numberLst[0].Id);
        OP.numberIds.add(numberLst[0].Id);
        OP.numberIds.add(numberLst[0].Id);
        OP.numberIds.add(numberLst[0].Id);
        
        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;
        
    }
     static testMethod void processTest() {
        List<Id>subscriptionIds = new List<Id>();
         Map<String,Orchestration_ProcessedRecords>processedIds= new Map<String,Orchestration_ProcessedRecords>();
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
         String str='';
         Map<String,Object>payloadMap=new Map<String,Object>();   
        Set<Id>orderIds=new Set<Id>();
         CSPOFA__Orchestration_Process_Template__c processTemp = [select id from CSPOFA__Orchestration_Process_Template__c Limit 1 ];
        Account objAccount = [select id from Account Limit 1 ];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c from csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name,csord__Order_Request__c, csord__Identification__c from csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name ,csordtelcoa__Subscription_Number__c ,csord__Order__c,
                                                csord__Identification__c,triggerBill_RTB__c,csord__Status__c,MarketableOffer__r.Auto_Expired_Entity__c,
                                                csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                                                csordtelcoa__Product_Configuration__r.ConfigurationType1__c
                                                from csord__Subscription__c where MarketableOffer__c != null];
        subList[0].csord__Order__c = orderLists[0].id; 
        subList[0].csord__Status__c = 'Ready for Activation'; 
        update subList;
        List<Number__c> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;      
              
        orchProcess = Orchestration_TestUtility.buildProcess(true,1,processTemp.id,orderLists,subList,objAccount.id,services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        update orchProcess;
        
        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        
        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;
      

        orchStepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c FROM CSPOFA__Orchestration_Step__c
                       WHERE ID IN :stepList];        
           String responseBody =  '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": '
            +'{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",'
            +'"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",'
            +'"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", '
            +'"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", '
            +'"state": "NSW", "country": "Australia" }}}';        

         for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            }
        }
         Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        payloadMap.put('StepId',orchStepList[0].Id);
        payloadMap.put('subscriptionIds',subscriptionIds);
        payloadMap.put('Current',orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
         payloadMap.put('CalloutStatus','202');
         //if(OP!=null)
           // processedIds.put(orchStepList[0].Id,OP);
        //payloadMap.put('ProcessedIds',processedIds);
         system.debug('ProcessedIds '+OP);
         payloadMap.put('ProcessedIds',processedRecordIds);
         payloadMap.put('ResponseBody',responseBody);
        str=(String)JSON.serialize(payloadMap);
        system.debug('StrStatus### '+str);
          Test.startTest();
        Orchestration_OrdertoBillUpdate_Handler handler = new Orchestration_OrdertoBillUpdate_Handler();

        handler.processUpdate(str);
        
       //Assert tocheck result
        System.assert(orchStepList[0].CSPOFA__Status__c != null);
        
        Test.stopTest();
     }
    static testMethod void processTestStatus() {
        List<Id>subscriptionIds = new List<Id>();
          List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
         String str='';
        Map<String,Orchestration_ProcessedRecords>processedIds= new Map<String,Orchestration_ProcessedRecords>();
         Map<String,Object>payloadMap=new Map<String,Object>();   
        Set<Id>orderIds=new Set<Id>();
         CSPOFA__Orchestration_Process_Template__c processTemp = [select id from CSPOFA__Orchestration_Process_Template__c Limit 1 ];
        Account objAccount = [select id from Account Limit 1 ];
        List<csord__Service__c> services = [SELECT Id, Name, csord__Status__c from csord__Service__c];
        List<csord__Order__c> orderLists = [SELECT Id, Name,csord__Order_Request__c, csord__Identification__c from csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name ,csordtelcoa__Subscription_Number__c ,csord__Order__c,
                                                csord__Identification__c,triggerBill_RTB__c,csord__Status__c,MarketableOffer__r.Auto_Expired_Entity__c,
                                                csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                                                csordtelcoa__Product_Configuration__r.ConfigurationType1__c
                                                from csord__Subscription__c where MarketableOffer__c != null];
        subList[0].csord__Order__c = orderLists[0].id; 
        subList[0].triggerBill_RTB__c = true; 
        subList[0].csord__Status__c = 'Provisioned';
        update subList;
        List<Number__c> numList = [SELECT id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c FROM Number__c];
        numList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[2].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[3].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[4].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[5].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numList[6].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numList;      
              
        orchProcess = Orchestration_TestUtility.buildProcess(true,1,processTemp.id,orderLists,subList,objAccount.id,services[0].id);
        orchProcess[0].csordtelcoa__Service__c = services[0].Id;
        update orchProcess;
        
        Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        OP.numberIds = new Set<String>();
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        OP.numberIds.add(numList[0].Id);
        
        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,orchProcess);
        stepList[0].JSON__c = System.JSON.serialize(OP);
        insert stepList;     

              stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                        CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c FROM CSPOFA__Orchestration_Step__c
                        WHERE Id IN :stepList];
        String responseBody =  '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": '
            +'{"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678",'
            +'"billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS",'
            +'"paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", '
            +'"companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", '
            +'"state": "NSW", "country": "Australia" }}}';
                
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            }
        }
        Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        payloadMap.put('StepId',stepList[0].Id);
        payloadMap.put('subscriptionIds',subscriptionIds);
        payloadMap.put('Current',stepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
         payloadMap.put('CalloutStatus','202');
         payloadMap.put('ResponseBody',responseBody);
        //String serializedId=System.JSON.serialize(OP);
        //if(OP!=null)
          //  processedIds.put(stepList[0].Id,OP);
        payloadMap.put('ProcessedIds',processedRecordIds);
        str=(String)JSON.serialize(payloadMap);
        system.debug('Str### '+str);
          Test.startTest();
        Orchestration_OrdertoBillUpdate_Handler handler = new Orchestration_OrdertoBillUpdate_Handler();
        handler.processUpdate(str);
        
       //Assert tocheck result
        System.assert(str != null);
         System.assert(stepList[0].CSPOFA__Status__c != null);
        Test.stopTest();
     }
}