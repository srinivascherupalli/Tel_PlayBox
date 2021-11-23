/*===============================================================================================================================
Class : CoBABillHandlerTest
Developer Name : Akanksha
===============================================================================================================================
*/
@isTest
public class CoBABatchHandlerTest {
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
		
         case cobaCaseRec = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByName.get('Sales Support').RecordTypeId,testAccount.id,testOpp.id,'CoBA case'); 
         insert cobaCaseRec;
         
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Mobile device', cscfga__Description__c = 'Mobile device',product_Specification__c='DMCAT_ProductSpecification_000423');
		insert CW_PD;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
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
        testSub1.csord__Status__c = 'Active';
        testSub1.Billing_Account__c = billAccount.id; 
        insert testSub1;
        
        csord__Subscription__c testSub2 = new csord__Subscription__c();
        testSub2.Name = 'TestSub2';
        testSub2.csord__Account__c = testAccount.Id;
        testSub2.csord__Order__c = testOrder.Id;
        testSub2.csord__Identification__c = 'test2';
        testSub2.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSub2.csord__Status__c = 'Active';
        testSub2.Billing_Account__c = billAccount.id;
        insert testSub2;
         
        csord__Subscription__c testSub3 = new csord__Subscription__c();
        testSub3.Name = 'TestSub3';
        testSub3.csord__Account__c = testAccount.Id;
        testSub3.csord__Order__c = testOrder.Id;
        testSub3.csord__Identification__c = 'test3';
        testSub3.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSub3.csord__Status__c = 'Active';
        testSub3.Billing_Account__c = billAccount.id;
        insert testSub3; 
         
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='test service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'svc-1235645';
        serv.csord__Subscription__c = testSub1.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order__c =  testOrder.Id;
        serv.csordtelcoa__Product_Configuration__c = testConfig.id;
        servs.add(serv);
        
       csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = 'svc-1235677';
        serv1.csord__Subscription__c = testSub2.Id;
        serv1.csord__Status__c = 'Service Created';
         serv.csord__Order__c =  testOrder.Id;
        servs.add(serv1);
        
        insert servs;
         
         Subscriptions_to_Case_Association__c juncObj1 = new Subscriptions_to_Case_Association__c();
         juncObj1.csord_Subscription__c=testSub1.Id;
         juncObj1.case__c=cobaCaseRec.Id;
         juncObj1.Billing_Account__c = billAccount.Id;
         juncObj1.Status__c ='Pending';
         insert juncObj1;
         
         Subscriptions_to_Case_Association__c juncObj2 = new Subscriptions_to_Case_Association__c();
         juncObj2.csord_Subscription__c=testSub2.Id;
         juncObj2.case__c=cobaCaseRec.Id;
         juncObj2.Billing_Account__c = billAccount.Id;
         juncObj2.Status__c ='In Error';
         insert juncObj2;
         
         Subscriptions_to_Case_Association__c juncObj3 = new Subscriptions_to_Case_Association__c();
         juncObj3.csord_Subscription__c=testSub3.Id;
         juncObj3.case__c=cobaCaseRec.Id;
         juncObj3.Billing_Account__c = billAccount.Id;
         juncObj3.Status__c ='Completed';
         insert juncObj3;
         
         
         
         BDS_API_Settings__c cobaLimit = new BDS_API_Settings__c(Value__c='10',Name ='SubscriptionAPI Limit');
         insert cobaLimit;
     }
    
    public static testmethod void testBatch() 
    {
        case caseRec = [select Id from case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CoBAMockBillingResponseGenerator(404, 'OK', '404Response', new Map<String, String>()));
        Test.startTest();
        CoBABatchHandler myBatchObject = new CoBABatchHandler(caseRec.Id);
        Id batchId = Database.executeBatch(myBatchObject,Integer.valueOf(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c));
        CoBABillHandler.logException('testlogException','test','test','test','test');
        Test.stopTest();
        System.assertNotEquals(batchId, null);
    }
     public static testmethod void testBatch1() 
    {
        case caseRec = [select Id from case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CoBAMockBillingResponseGenerator(202, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();
        CoBABatchHandler myBatchObject = new CoBABatchHandler(caseRec.Id);
        Id batchId = Database.executeBatch(myBatchObject,Integer.valueOf(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c));
        Test.stopTest();
        System.assertNotEquals(batchId, null);
    }
}