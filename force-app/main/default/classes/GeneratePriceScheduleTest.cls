/*************************************************************************************************
Name : GeneratePriceScheduleTest 
Description : EDGE-123581 : Test Class for GeneratePriceSchedule
===============================================================================================================================
Sr.No.    Developer Name      Date          Story        Description
1.        Pawan Devaliya      19-Jan-2020   Created
2.        Vaibhav Deshpande   29-Jan-2020   EDGE-132626  added test data and method
3.        Pawan               27-Feb-2020   EDGE-124716     Pricing Modify for EM and NGUC
6.        Pawan               20-March-2020 EDGE-132626     Changed code to have single JSON structure for EM, NGUC device and Voice
===============================================================================================================================
***************************************************************************************************/

@isTest
private class GeneratePriceScheduleTest{
    
    @testSetup
    public static void testdatasetup(){
        
        
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
            chargeLineItem.status__c = 'New';
            CorrelationIds.add('234');
            
            chargeLineItemList.add(chargeLineItem);

            Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c();
            chargeLineItem1.CorrelationId__c = '567';
            chargeLineItem1.status__c = 'New';
            CorrelationIds.add('567');
            
            chargeLineItemList.add(chargeLineItem1);
            
            Charge_Line_Item__c chargeLineItem2 = new Charge_Line_Item__c();
            chargeLineItem2.CorrelationId__c = '789';
            chargeLineItem2.status__c = 'New';
            chargeLineItem2.chargeType__c = 'Tiered Recurring';
            CorrelationIds.add('789');
            
            chargeLineItemList.add(chargeLineItem2);
            
            Charge_Line_Item__c chargeLineItem3 = new Charge_Line_Item__c();
            chargeLineItem3.CorrelationId__c = '1112';
            chargeLineItem3.status__c = 'New';
            chargeLineItem3.serviceId__c = service.id;
            CorrelationIds.add('1112');
            
            chargeLineItemList.add(chargeLineItem3);
            
            Charge_Line_Item__c chargeLineItem4 = new Charge_Line_Item__c();
            chargeLineItem4.CorrelationId__c = '1213';
            chargeLineItem4.status__c = 'New';
            //CorrelationIds.add('1213');
            
            chargeLineItemList.add(chargeLineItem4);
            
            
            Charge_Line_Item__c chargeLineItem5 = new Charge_Line_Item__c();
            chargeLineItem5.CorrelationId__c = '1112';
            chargeLineItem5.status__c = 'New';
            chargeLineItem5.serviceId__c = service.id;
            CorrelationIds.add('1112');
            
            chargeLineItemList.add(chargeLineItem5);
            
            insert(chargeLineItemList);
                        
            List<Price_Schedule_Line_Item__c> psliList=new  List<Price_Schedule_Line_Item__c>();
            Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
            psli.Name='TestPSLI';
            psli.chargeInstance__c=chargeLineItem.id;
            psliList.add(psli);
            Price_Schedule_Line_Item__c psli1=new Price_Schedule_Line_Item__c();
            psli1.Name='TestPSLI1';
            psli1.chargeInstance__c=chargeLineItem.id;
            psliList.add(psli1);
            
            insert psliList;
            
            List<Discount_Line_Item__c> dliList=new List<Discount_Line_Item__c>();
            Discount_Line_Item__c dli=new Discount_Line_Item__c();
            dli.Name='TestDLI';
            dli.chargeInstance__c=chargeLineItem.Id;
            dliList.add(dli);
            Discount_Line_Item__c dli1=new Discount_Line_Item__c();
            dli1.Name='TestDLI1';
            dli1.chargeInstance__c=chargeLineItem.Id;
            dliList.add(dli1);
            
            insert dliList;
            
            Map<Id, Charge_Line_Item__c> cliMap =new Map<Id, Charge_Line_Item__c>([Select Id, CorrelationId__c, chargeType__c from Charge_Line_Item__c where CorrelationId__c in : CorrelationIds ]);
            

            Map<Id, String> cliCorealtionIdsMap = new Map<Id, String>();
            
            for(Id key : cliMap.keyset()){
                cliCorealtionIdsMap.put(key, cliMap.get(key).CorrelationId__c); 
                PricingMSResponseObject__c pricingMSResponse = createMSResponseData(key,cliMap.get(key).CorrelationId__c, cliMap.get(key).chargeType__c);
                msResponseList.add(pricingMSResponse);
                    
            }   
           // PricingMSResponseObject__c pricingMSResponse1 = createMSResponseData(key,cliMap.get(key).CorrelationId__c);            
            insert msResponseList;           
    }

    @isTest
    private static void createPSLIListToInsertTest(){

    Set<String> CorrelationIds = new Set<String>();
    List<Id> pricingMSResponseObjectIdListforPSLI = new List<Id>();
    CorrelationIds.add('789');
    CorrelationIds.add('567');
    CorrelationIds.add('234');
    Map<Id, Charge_Line_Item__c> cliMap =new Map<Id, Charge_Line_Item__c>([Select Id, CorrelationId__c, chargeType__c from Charge_Line_Item__c where CorrelationId__c in : CorrelationIds ]);
    Map<Id, String> cliCorealtionIdsMap = new Map<Id, String>();
    Map<Id, String> cliCorealtionIdsMapEM = new Map<Id, String>();
    Map<Id, String> cliCorealtionIdsMapNGUC = new Map<Id, String>();
    Set<String> CLIsInserted = new Set<String>();
    
    for(Id key : cliMap.keyset()){
    CLIsInserted.add(String.valueOf(key));  
    cliCorealtionIdsMap.put(key, cliMap.get(key).CorrelationId__c);
    if(cliMap.get(key).chargeType__c != null && cliMap.get(key).chargeType__c.equalsIgnoreCase('Tiered Recurring')){
        cliCorealtionIdsMapNGUC.put(key, cliMap.get(key).CorrelationId__c);
    }
    else{
        cliCorealtionIdsMapEM.put(key, cliMap.get(key).CorrelationId__c);
    }
        
    }

    
    
    Test.StartTest();
     Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLIEM = GeneratePriceSchedule.createPSLIListToInsert(cliCorealtionIdsMapEM);
     List<Price_Schedule_Line_Item__c> priceScheduleLineItemListEM = GeneratePriceSchedule.generatePSLI_TLI(pricingMSResponseObjectMapforPSLIEM.values());
          Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLIEMNGUC = GeneratePriceSchedule.createPSLIListToInsert(cliCorealtionIdsMapNGUC);
     SObject[] PSLI_TLI_ToInsertNGUC = GeneratePriceSchedule.generatePSLI_TLI(pricingMSResponseObjectMapforPSLIEMNGUC.values());
  
     GeneratePriceSchedule.updateCLIs(CLIsInserted, 'New');

    Test.StopTest();
    
    System.assertEquals(6, PSLI_TLI_ToInsertNGUC.size());    //Checking PSLI creation for EM
    System.assertEquals(6, priceScheduleLineItemListEM.size());  //Checking PSLI & TLI creation for NGUC
    List<PricingMSResponseObject__c> pricingMSResponseObjectList = (List<PricingMSResponseObject__c>)PSLI_TLI_ToInsertNGUC;
    System.assertNotEquals(0, pricingMSResponseObjectList.size());
}


private static PricingMSResponseObject__c createMSResponseData(String cliID, String coRelationId, String chargeType){
    
    String responsePayload = '';
    
    List<Discount_Line_Item__c> dliList =  [Select id from Discount_Line_Item__c];
    String id1=dliList[0].id;
    String id2=dliList[1].id;   
    
    
    if(chargeType != null && chargeType.equalsIgnoreCase('Tiered Recurring')){
    responsePayload ='{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id":"'+ id1+'", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "'+ id2+'", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';    
        
    }
    else{   //Payload for EM
    responsePayload = '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "'+ id1+'", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "'+ id2+'", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [] } ] } }';
        
    }
     
    PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
    pricingMSResponse.CLI_Instance_ID__c= cliID;
    pricingMSResponse.ErrorDescription__c='';
    pricingMSResponse.Status__c='success';
    pricingMSResponse.TCV_Value__c= Integer.valueof((Math.random() * 100));
    pricingMSResponse.CorrelationId__c = coRelationId;
    pricingMSResponse.ResponsePayload__c = responsePayload;

    return pricingMSResponse; 

} 
     
 
     
   @isTest
   private static void generatePriceScheduleModifyTest(){
         Set<String> cliId=new Set<String>();
         Map<String,String> corelationIdSubId = new Map<String,String>();
         Set<String> corelationIdList = new Set<String>();
         String correlationId = '1112';
         corelationIdList.add(correlationId);
         corelationIdSubId.put(correlationId, null);
         list<Charge_Line_Item__c> cliList =[select id from Charge_Line_Item__c];

         Test.startTest();
         GeneratePriceSchedule.generatePriceScheduleModify(corelationIdList, corelationIdSubId);
         Test.stopTest();
         
        System.assertnotEquals(0, cliList.size());
 }
  


   @isTest
   private static void generatePriceScheduleModifyEmptyTest(){
         Set<String> cliId=new Set<String>();
         Set<String> corelationIdList = new Set<String>();
         Map<String,String> corelationIdSubId = new Map<String,String>();
         String correlationId = '1213';
         corelationIdList.add(correlationId);
         corelationIdSubId.put(correlationId, null);
         list<Charge_Line_Item__c> cliList =[select id from Charge_Line_Item__c];

         Test.startTest();
         GeneratePriceSchedule.generatePriceScheduleModify(corelationIdList, corelationIdSubId);
         Test.stopTest();
         
        System.assertnotEquals(0, cliList.size());
 }
 
   @isTest
   private static void createPriceScheduleModifyTest(){
         
         Map<Id, Charge_Line_Item__c> chargeLineItemMapModifyData = new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c,status__c,unitPrice__c,contractTerm__c,serviceId__c,serviceId__r.csord__Subscription__c from Charge_Line_Item__c where CorrelationId__c = '1112']);

         Test.startTest();
         GeneratePriceSchedule.createPriceScheduleModify(chargeLineItemMapModifyData);
         Test.stopTest();
         
        System.assertnotEquals(0, chargeLineItemMapModifyData.values().size());
 }
    

}