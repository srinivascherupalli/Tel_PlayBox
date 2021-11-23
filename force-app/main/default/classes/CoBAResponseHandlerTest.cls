/********************************************************
Class Name : CoBAResponseHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Pawan Singh             28/04/2021    test class of CoBAResponseHandler
===============================================================================================================================

**********************************************************
*/
@isTest
public class CoBAResponseHandlerTest {
   
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
        insert testSub1;
        
        csord__Subscription__c testSub2 = new csord__Subscription__c();
        testSub2.Name = 'TestSub2';
        testSub2.csord__Account__c = testAccount.Id;
        testSub2.csord__Order__c = testOrder.Id;
        testSub2.csord__Identification__c = 'test2';
        testSub2.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSub2.csord__Status__c = 'Active';
        insert testSub2;
          
    }
    @isTest
    public static void testUpdateEventId(){
        csord__Order__c ord =[Select Id,name,csord__Order_Number__c,csord__Account__c from csord__Order__c where name='testCOBA'];
        string eventId = '42f742c4-7b26-4783-914a-677168be7ac5';
        
        Test.startTest();
        List<csord__Subscription__c> subs = [Select Id,name from csord__Subscription__c where csord__Order__r.Id =:ord.Id];
        List<Id> subIds = new List<Id>();
        for(csord__Subscription__c sub: subs)
        {
            subIds.add(sub.Id);
        }
        CoBAResponseHandler.updateEventId(subIds, eventId);
        
        Test.stopTest();
        csord__Subscription__c subscription = [select eventId__c from csord__Subscription__c where Id IN :subIds limit 1][0];
        system.assertEquals(eventId, subscription.eventId__c);
    }
}