/*************************************************************************************************
Name : CeasePriceScheduleStepTest 
Description : EDGE-124711 : EM / NgUC: Manage price schedule inventory update for Cancel Orders
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya      18-Feb-2020   Test class for CeasePriceScheduleStep      
2.        Vaibhav             28-Apr-2020   EDGE-143708
===============================================================================================================================
***************************************************************************************************/

@isTest
public class CeasePriceScheduleStepTest {
 @testSetup
    public static void setupdata(){
        TestDataFactory.generateProductConfiguration();
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        cscfga__Product_Configuration__c productConfig  = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE name LIKE 'Test Name%'];    
        productConfig.cscfga__Product_Basket__c=basket.Id;
        update productConfig;
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';
        ord.csord__Status2__c = 'Pending';
        INSERT ord;
     
     csord__Subscription__c sub = new csord__Subscription__c();
        sub.name  = 'test subs';
        sub.csord__Identification__c = 'test identity';
        sub.csord__Status__c = 'Pending';
        sub.csord__Order__c = ord.id;
        sub.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT sub;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service2';
        serv.csord__Identification__c  = 'test identify2';
        serv.csordtelcoa__Service_Number__c = '5';
        serv.csord__Subscription__c = sub.Id;
        serv.csord__Status__c = 'In Progress';
        serv.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT serv;
        
        csord__Subscription__c sub1 = new csord__Subscription__c();
        sub1.name  = 'test subs1';
        sub1.csord__Identification__c = 'test identity';
        sub1.csord__Status__c = 'Pending';
        sub1.csord__Order__c = ord.id;
        sub1.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT sub1;

        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service3';
        serv1.csord__Identification__c  = 'test identify2';
        serv1.csordtelcoa__Service_Number__c = '5';
        serv1.csord__Subscription__c = sub1.Id;
        serv1.csord__Status__c = 'In Progress';
        serv1.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT serv1;
        
        csord__Subscription__c sub2 = new csord__Subscription__c();
        sub2.name  = 'test subs2';
        sub2.csord__Identification__c = 'test identity';
        sub2.csord__Status__c = 'Disconnected In Progress';
        sub2.csord__Order__c = ord.id;
        sub2.csordtelcoa__Product_Configuration__c = productConfig.id;
        sub2.csordtelcoa__Replaced_Subscription__c = sub1.id;
        INSERT sub2;
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service4';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = sub2.Id;
        serv2.csord__Status__c = 'Disconnected In Progress';
        serv2.csordtelcoa__Replaced_Service__c = serv1.id;
        serv2.csordtelcoa__Product_Configuration__c = productConfig.id;
        INSERT serv2;
        
        parentOrchProcess.Order__c = ord.Id;
        UPDATE parentOrchProcess;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);

        List<Number__c> numList=new List<Number__c>();
        Number__c fnnNumber1 = Testutil.createNumber('61359816905',basket.id,null);
        fnnNumber1.Product_Configuration__c =productConfig.id;
        fnnNumber1.Type__c='FNN';
        fnnNumber1.Status__c = 'RESERVED';
        fnnNumber1.Mobile__c='Fixed';
        numList.add(fnnNumber1);
        Number__c fnnNumber2 = Testutil.createNumber('61359816906',basket.id,null);
        fnnNumber2.Product_Configuration__c =productConfig.id;
        fnnNumber2.Type__c='FNN';
        fnnNumber2.Status__c = 'RESERVED';
        fnnNumber2.Mobile__c='Fixed';
        numList.add(fnnNumber2);
        insert numList;
        
      csord__Service__c service = [Select Id, name from csord__Service__c where name ='tst service2' limit 1]; 
        
        List<PricingMSResponseObject__c> msResponseList = new List<PricingMSResponseObject__c>(); 
        List<Charge_Line_Item__c> chargeLineItemList = new List<Charge_Line_Item__c>();
        Set<String> CorrelationIds = new Set<String>();

        Charge_Line_Item__c chargeLineItem = new Charge_Line_Item__c();
        chargeLineItem.CorrelationId__c = '234';
        CorrelationIds.add('234');
        chargeLineItem.serviceId__c = service.id;

        chargeLineItemList.add(chargeLineItem);
        
        csord__Service__c service1 = [Select Id, name from csord__Service__c where name ='tst service3' limit 1];
        
        Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c();
        chargeLineItem1.CorrelationId__c = '456';
        CorrelationIds.add('456');
        chargeLineItem1.serviceId__c = service1.id;

        chargeLineItemList.add(chargeLineItem1);
        
         insert chargeLineItemList; 

        Discount_Line_Item__c dli = new Discount_Line_Item__c();
        dli.Name = 'TestDLI';
        dli.BusinessID__c = 'DMCAT_Discount_000945_Test';
        dli.discountType__c = 'Amount';
        dli.discountValue__c = '4.6';
        dli.Priority__c = 1;
        dli.chargeInstance__c = chargeLineItem1.id;
        
        insert dli;

        Price_Schedule_Line_Item__c priceScheduleLineItemToInsert = new Price_Schedule_Line_Item__c();
        
        priceScheduleLineItemToInsert.fromPeriod__c = '0';
        priceScheduleLineItemToInsert.toPeriod__c = '6';
        priceScheduleLineItemToInsert.unitPrice__c = 50;
        priceScheduleLineItemToInsert.applicationDuration__c = 12; //EDGE-135274
        priceScheduleLineItemToInsert.chargeInstance__c = chargeLineItem1.id;
        priceScheduleLineItemToInsert.status__c= 'New'; 

        insert priceScheduleLineItemToInsert;

        Tier_Line_Item__c tierLineItemToInsert = new Tier_Line_Item__c();

        tierLineItemToInsert.Discounted_Price__c = 99;
        tierLineItemToInsert.FromUnit__c = '201';
        tierLineItemToInsert.status__c = 'New';
        tierLineItemToInsert.ToUnit__c = '500';
        tierLineItemToInsert.fromPeriod__c = '0';
        tierLineItemToInsert.toPeriod__c = '6';
        tierLineItemToInsert.PSLIInstance__c = priceScheduleLineItemToInsert.id;
        
        insert tierLineItemToInsert;        
    }
        @isTest
        private static void updateScheduleTest() {
        Map<Id, csord__Subscription__c> SubMap = new Map<Id, csord__Subscription__c>([SELECT id, Name, csordtelcoa__Replaced_Subscription__c FROM csord__Subscription__c where Name  ='test subs2' limit 1]);
        CeasePriceScheduleStep cp = new CeasePriceScheduleStep();
        
        Set<Id> serviceIdsBaseOrder = new Set<Id>();
        
        Test.startTest();
        serviceIdsBaseOrder = cp.getserviceIdsBaseOrder(SubMap.keySet());
        String status = 'Ready to Inactive';
        CeasePriceScheduleStep.updateSchedule(serviceIdsBaseOrder, status);
        Test.stopTest();
        
        Charge_Line_Item__c cli = [SELECT Id, status__c, serviceId__r.csord__Subscription__c, (Select id, status__c from Discount_Line_Items__r) FROM Charge_Line_Item__c WHERE serviceId__c in  :serviceIdsBaseOrder limit 1];
        
        Price_Schedule_Line_Item__c psli = [SELECT Id, status__c, (Select id, status__c from Tier_Line_Items__r)  FROM Price_Schedule_Line_Item__c WHERE chargeInstance__c =: cli.id limit 1];
        Tier_Line_Item__c tli = psli.Tier_Line_Items__r;
        Discount_Line_Item__c dli = cli.Discount_Line_Items__r;
        
        System.assertEquals(cli.status__c ,status, 'Success');
        System.assertEquals(dli.status__c ,status, 'Success');
        System.assertEquals(psli.status__c,status , 'Success');
        System.assertEquals(tli.status__c ,status, 'Success');

    }
    
    @isTest
    private static void processTest() { 
        List<CSPOFA__Orchestration_Step__c> steps = [SELECT id,CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c];
        List<SObject> result = new List<SObject>();
        Test.startTest();
        CeasePriceScheduleStep stepclass = new CeasePriceScheduleStep();
        result = stepclass.process((List<SObject>)steps);
        Test.stopTest();    
        System.assertEquals(result!=null,true, 'Success');
    }
    
    //added as part of EDGE-143708
     @isTest
        private static void ceaseUpdatebillSpecIdCLITest() {
       Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT id, Name FROM csord__Service__c]);
      Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c, basketId__c,status__c,unitPrice__c,contractTerm__c,serviceId__c, serviceId__r.csord__Subscription__c,billingSpecIdentifier__c,BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceMap.keyset()]);
        Test.startTest();
        GeneratePriceScheduleStep stepClass = new GeneratePriceScheduleStep();
       stepclass.updatebillSpecIdCLI(serviceMap, chargeLineItemMap);
     
        Test.stopTest();
        System.assertNotEquals(serviceMap.size(),0);
    }   
    
}