/**
 * Test Class for EDGE-191824 In-Flight: PONR Check before initiating Contract/Skip Contract/Quote
 * Pooja Gupta             12-01-2021      Created a test class for PONRUtilityClass class
 */
@isTest //Added seeAllData=true as sync api is called which needs pricebook data to be queried
public class PONRUtilityClassTest {
@Testsetup
    static void dataSetup(){
    Account acc = ProductTestService.getNewAccount('Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Account__c = acc.id;
        billingAccount.Status__c = 'final';
        insert billingAccount;
        
        Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq2.id);
        primaryOrd.csord__Order_Request__c = ordReq2.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp.Id;
        insert primaryOrd;    
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = primaryOrd.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        subs.Suspension_reason__c='Requested by Customer';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.Point_of_No_Return_Reached__c = true;
        subs.cancel_Point_of_No_Return_Reached__c = true;
        insert subs;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq2.Id;
        serv1.csord__Order__c = primaryOrd.Id;
        insert serv1;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'IoT Basket';
        basket.Device_Care_Contact__c = cont.Id;
        basket.cscfga__Basket_Status__c = 'valid';
        basket.Order_Requester__c =cont.Id;
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        basket.csbb__Synchronised_with_Opportunity__c =false;
        insert basket;

    }
    @istest static void validatePONRforBasketTest(){
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,csbb__Synchronised_with_Opportunity__c,Order_Requester__c from cscfga__Product_Basket__c limit 1];
        Id recordtypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        basket.RecordTypeId = recordtypeId;
        update basket;
        System.test.starttest();
        boolean response = PONRUtilityClass.validatePONRforBasket(basket);
        system.debug('responsevalid--'+response);
        System.test.stoptest();
        system.assertEquals(true,response);
    }
    @istest static void validatePONRforOrderTest(){
		csord__Order__c order = [SELECT id,csord__Order_Number__c FROM csord__Order__c limit 1];
        System.test.starttest();
        boolean response1 = PONRUtilityClass.validatePONRforOrder(Order.csord__Order_Number__c);
        system.debug('responsevalid--'+response1);
        System.test.stoptest();
        system.assertEquals(true,response1);
	}
   }