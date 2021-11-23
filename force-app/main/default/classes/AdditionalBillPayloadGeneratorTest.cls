/********************************************************
Class Name : AdditionalBillPayloadGeneratorTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta  Patil         29/04/2021   test class of CoBABillPayloadGenerator
===============================================================================================================================

**********************************************************/

@isTest
public class AdditionalBillPayloadGeneratorTest {
    
@TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
         Billing_Account__c billAccount = new Billing_Account__c(Status__c = 'Created', Include_related_Customer_Account_Contact__c=false, 
                                                                Account__c=testAccount.Id, Billing_Account_Number__c='992216148101',Balance_Amount__c=100.00);
                                                               
        insert billAccount;
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Develop';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Mobile device', cscfga__Description__c = 'Mobile device',product_Specification__c='DMCAT_ProductSpecification_000423');
        insert CW_PD;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        
        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = testAccount.Id;
        ba.Billing_Account_Number__c = '123123122234';
        insert ba;
        
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        insert testConfig;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c testOrder = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.csord__Status2__c='Ready for submit';
        testOrder.Name = 'testCOBA';
        insert testOrder;
        csord__Subscription__c testSub1 = new csord__Subscription__c();
        testSub1.Name = 'TestSub1';
        testSub1.csord__Account__c = testAccount.Id;
        testSub1.csord__Order__c = testOrder.Id;
        testSub1.csord__Identification__c = 'test1';
        testSub1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSub1.Billing_Account__c = ba.id;
        testSub1.csord__Status__c = 'Active';
        insert testSub1;
        
        csord__Subscription__c testSub2 = new csord__Subscription__c();
        testSub2.Name = 'TestSub2';
        testSub2.csord__Account__c = testAccount.Id;
        testSub2.csord__Order__c = testOrder.Id;
        testSub2.csord__Identification__c = 'test2';
        testSub2.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSub2.Billing_Account__c = ba.id;
        testSub2.csord__Status__c = 'Active';
        insert testSub2;
        
        csord__Service__c prdCharServ = new csord__Service__c();
prdCharServ.name ='TestProdChar';
prdCharServ.csord__Identification__c  = 'TestProdChar';
prdCharServ.csord__Subscription__c = testSub1.Id;
prdCharServ.csord__Status__c = 'Connected'; 
prdCharServ.csord__Order__c = testOrder.Id;
insert prdCharServ;

csord__Service__c prdCharFNN = new csord__Service__c();
prdCharFNN.name ='TestProdCharFNN';
prdCharFNN.csord__Identification__c  = 'TestProdCharFNN';
prdCharFNN.csord__Subscription__c = testSub2.Id;
prdCharFNN.csord__Status__c = 'Connected'; 
prdCharFNN.csord__Order__c = testOrder.Id;
insert prdCharFNN;
        
    }

static testmethod void testaddSpecificToBuildBillPayload(){

    List<Id> subscriptionIdList = new List<Id>();
    List<csord__Subscription__c> subList=[select id,name,csord__Identification__c,autoExpiry__c,Billing_Account__r.Billing_Account_Number__c from csord__Subscription__c LIMIT 3 ];
    for(csord__Subscription__c sub:subList){
        subscriptionIdList.add(sub.id);}
    test.startTest();

   BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse('{"productOffering":{"productInstanceId":"SN-000229909","offerInstanceId":"SN-000229908","offerId":"DMCAT_Offer_001233","invoiceDefinition":"Invoice_Def_2","expireDurationValue":12,"expireDurationUnit":"Months","description":"Mobile Handset APPLE IPHONE 11 128GB 4GX 2020 BLACK HRO_1","autoExpiry":true},"productActionType":"modify","orderReference":"CN000-025-324","orderItems":[{"serviceInstanceId":"SVC-000209510:DMCAT_ProductSpecification_001211","scenarioType":"COBA","productId":"DMCAT_ProductSpecification_001211","productActionType":"modify","effectiveDate":"2021-04-28T02:00:00.000Z","description":"Next Generation Mobile Device","billingSpecifications":[{"units":1.0,"unitPrice":980.9,"taxTreatment":"GST Applicable","instanceId":"82b665b7-3a08-418a-5279-27d612d3b99a","externalRateId":"DMCAT_Offer_001233_DMCAT_ProductSpecification_001211_DMCAT_NonRecurringCharge_000511_8094","durationValue":12,"durationUnit":"Months","description":"Apple iPhone 11 128GB 4GX 2020 Black","currencyCode":"AUD","contractType":"Hardware Repayment","chargeId":"DMCAT_NonRecurringCharge_000511","billingSpecId":"BSOTC001_CB","actionCode":"no change"}]}],"fromBillingAccountNumber":700000015177,"effectiveDate":"2021-04-28T02:00:00.000Z","billingAccountNumber":700000015169}');
    AdditionalBillPayloadGenerator CPG = new AdditionalBillPayloadGenerator(subscriptionIdList,true, false, 'PostSubscriptionHandler','700000015169');
    CPG.addSpecificToBuildBillPayload(subList[0],billSpecDTO,'SN-1234','COBA','700000015169'); 
    system.assertNotEquals(null, subscriptionIdList);


}

    
    static testmethod void testGenerateCOBABillingPayLoad(){

    List<Id> subscriptionIdList = new List<Id>();
    List<csord__Subscription__c> subList=[select id,name,csord__Identification__c,autoExpiry__c,Billing_Account__r.Billing_Account_Number__c from csord__Subscription__c LIMIT 3 ];
    for(csord__Subscription__c sub:subList){
        subscriptionIdList.add(sub.id);}
    test.startTest();
  AdditionalBillPayloadGenerator CPG = new AdditionalBillPayloadGenerator(subscriptionIdList,true, false, 'PostSubscriptionHandler','700000015169');
    CPG.generateCOBABillingPayLoad('700000015169'); 
    system.assertNotEquals(null, subscriptionIdList);


}






}