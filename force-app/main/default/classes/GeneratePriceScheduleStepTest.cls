/*************************************************************************************************
Name : GeneratePriceScheduleStepTest 
Description : EDGE-123581 : Test Class for GeneratePriceScheduleStep
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya /    19-Jan-2020   Created
          Prajakta Patil
2.        Pawan               27-Feb-2020   EDGE-124716     Pricing Modify for EM and NGUC    
3.        Vaibhav             28-Apr-2020   EDGE-143708
===============================================================================================================================
***************************************************************************************************/

@isTest
public class GeneratePriceScheduleStepTest {

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
        sub2.csord__Status__c = 'Pending';
        sub2.csord__Order__c = ord.id;
        sub2.csordtelcoa__Product_Configuration__c = productConfig.id;
        sub2.csordtelcoa__Replaced_Subscription__c = sub1.id;
        INSERT sub2;
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service4';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = sub2.Id;
        serv2.csord__Status__c = 'In Progress';
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
        chargeLineItem.billingSpecIdentifier__c='';
        CorrelationIds.add('234');
        chargeLineItem.serviceId__c = service.id;

        chargeLineItemList.add(chargeLineItem);
        
        csord__Service__c service1 = [Select Id, name from csord__Service__c where name ='tst service4' limit 1];
        
        Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c();
        chargeLineItem1.CorrelationId__c = '456';
        chargeLineItem1.billingSpecIdentifier__c='';
        CorrelationIds.add('456');
        chargeLineItem1.serviceId__c = service1.id;

        chargeLineItemList.add(chargeLineItem1);
        
         insert chargeLineItemList;     
           
        Charge_Line_Item__c cli1 = [Select Id, CorrelationId__c from Charge_Line_Item__c where CorrelationId__c = '456' limit 1];
         
        String responsePayload1 = '{ "chargeLineItems": { "unitPrice__c": 80, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000444", "unitTotalContractValue__c": "1110", "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 0, "toPeriod__c": 6, "applicationDuration__c":6, "unitPrice__c": 10, "applicableDiscounts": [ { "id": "aBB2N00000000BEWAY", "description": "EAP Promotion", "discountAmount": "50%", "appliedDiscountValue__c":40 }, { "id": "aBB2N00000000BOWAY", "description": "MMC Discount", "discountAmount": "10", "appliedDiscountValue__c":10 }, { "id": "aBB2N00000000BPWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] }, { "id": "PSLI2", "fromPeriod__c": 7, "toPeriod__c": 9, "applicationDuration__c":9, "unitPrice__c": 50, "applicableDiscounts": [ { "id": "aBB2N00000000BPWAY", "description": "MMC Discount", "discountAmount": "10", "appliedDiscountValue__c":10 }, { "id": "aBB2N00000000BOWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] }, { "id": "PSLI3", "fromPeriod__c": 10, "toPeriod__c": 24, "unitPrice__c": 60, "applicableDiscounts": [ { "id": "aBB2N00000000BEWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] } ] } }';
        PricingMSResponseObject__c pricingMSResponse1 = new PricingMSResponseObject__c();
        pricingMSResponse1.CLI_Instance_ID__c= cli1.Id;
        pricingMSResponse1.ErrorDescription__c='';
        pricingMSResponse1.Status__c='success';
        pricingMSResponse1.TCV_Value__c= Integer.valueof((Math.random() * 100));
        pricingMSResponse1.CorrelationId__c = '456';
        pricingMSResponse1.ResponsePayload__c = ResponsePayload1;

        msResponseList.add(pricingMSResponse1);
        
        insert msResponseList;
        
    }

        @isTest
        private static void processTest() {
    
        Charge_Line_Item__c cli = [Select Id, CorrelationId__c, serviceId__c from Charge_Line_Item__c where CorrelationId__c = '234' limit 1];  
         
        String responsePayload = '{ "chargeLineItems": { "unitPrice__c": 80, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000444", "unitTotalContractValue__c": "1110", "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 0, "toPeriod__c": 6, "applicationDuration__c":6, "unitPrice__c": 10, "applicableDiscounts": [ { "id": "aBB2N00000000BEWAY", "description": "EAP Promotion", "discountAmount": "50%", "appliedDiscountValue__c":40 }, { "id": "aBB2N00000000BOWAY", "description": "MMC Discount", "discountAmount": "10", "appliedDiscountValue__c":10 }, { "id": "aBB2N00000000BPWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] }, { "id": "PSLI2", "fromPeriod__c": 7, "toPeriod__c": 9, "applicationDuration__c":9, "unitPrice__c": 50, "applicableDiscounts": [ { "id": "aBB2N00000000BPWAY", "description": "MMC Discount", "discountAmount": "10", "appliedDiscountValue__c":10 }, { "id": "aBB2N00000000BOWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] }, { "id": "PSLI3", "fromPeriod__c": 10, "toPeriod__c": 24, "unitPrice__c": 60, "applicableDiscounts": [ { "id": "aBB2N00000000BEWAY", "description": "MRO Bonus", "discountAmount": "20", "appliedDiscountValue__c":20 } ] } ] } }';
        PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
        pricingMSResponse.CLI_Instance_ID__c= cli.Id;
        pricingMSResponse.ErrorDescription__c='';
        pricingMSResponse.Status__c='success';
        pricingMSResponse.TCV_Value__c= Integer.valueof((Math.random() * 100));
        pricingMSResponse.CorrelationId__c = '234';
        pricingMSResponse.ResponsePayload__c = ResponsePayload;

        insert pricingMSResponse;

        List<CSPOFA__Orchestration_Step__c> steps = [SELECT id,CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c];
        List<SObject> result = new List<SObject>();
        Test.startTest();
        GeneratePriceScheduleStep stepclass = new GeneratePriceScheduleStep();
        result = stepclass.process((List<SObject>)steps);
        Test.stopTest();
        System.assertEquals(result!=null,true, 'Success');
    }
            
        @isTest
        private static void processEmptyCLITest() {
       List<CSPOFA__Orchestration_Step__c> steps = [SELECT id,CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c];
        List<SObject> result = new List<SObject>();
        Test.startTest();
        GeneratePriceScheduleStep stepclass = new GeneratePriceScheduleStep();
        result = stepclass.process((List<SObject>)steps);
        Test.stopTest();
        System.assertEquals(result!=null,true, 'Success');
    }

        @isTest
        private static void executeGeneratePriceTest() {
       List<CSPOFA__Orchestration_Step__c> stepList = [SELECT id,CSPOFA__Orchestration_Process__c FROM CSPOFA__Orchestration_Step__c];
       Map<Id, csord__Subscription__c> SubMap = new Map<Id, csord__Subscription__c>([SELECT id, Name, csordtelcoa__Replaced_Subscription__c FROM csord__Subscription__c]);
       
        List<SObject> result = new List<SObject>();
        Test.startTest();
        GeneratePriceScheduleStep stepClass = new GeneratePriceScheduleStep();
        System.debug('SubMap    '+SubMap);
        result = stepclass.process((List<SObject>)stepList);
        stepList = stepClass.executeGeneratePrice(stepList, SubMap);
     
        Test.stopTest();
        System.assertEquals(result !=null,true, 'Success');
    }   
    
    //added as part of EDGE-143708
     @isTest
        private static void updatebillSpecIdCLITest() {
       Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT id, Name FROM csord__Service__c]);
      Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c, basketId__c,status__c,unitPrice__c,contractTerm__c,serviceId__c, serviceId__r.csord__Subscription__c,billingSpecIdentifier__c,BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceMap.keyset()]);
        Test.startTest();
        GeneratePriceScheduleStep stepClass = new GeneratePriceScheduleStep();
       stepclass.updatebillSpecIdCLI(serviceMap, chargeLineItemMap);
     
        Test.stopTest();
        System.assertNotEquals(serviceMap.size(),0);
    }   
}