@isTest
public class BroadsoftTenancyControllerTest {
	@testSetup 
    public static void setupdata(){
        List<Account> accountList =new List<Account>();
        Account acc = TestUtil.createAccount('Account BroadSoft');
        acc.Customer_Status__c = 'ACQUIRED';
        acc.cidn__c = '2804516970';
        acc.Parent_CIDN__c = '2804516971';
        acc.Ultimate_Parent_CIDN__c = '2804516972';
        accountList.add(acc);
        Account accParent = TestUtil.createAccount('Account BroadSoft Parent');
        accParent.Customer_Status__c = 'ACQUIRED';
        accParent.cidn__c = '2804516971'; 
        accParent.Ultimate_Parent_CIDN__c = '2804516972';
        accountList.add(accParent);
        Account accUltimate = TestUtil.createAccount('Account BroadSoft Ultimate');
        accUltimate.Customer_Status__c = 'ACQUIRED';
        accUltimate.cidn__c = '2804516972'; 
        accountList.add(accUltimate);
        insert accountList;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
    }
    @isTest
    public static void getLegacyServicesSuccessTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Account BroadSoft'];
    	Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceBroadsoftMock('success'));
        Test.startTest();
        BroadsoftTenancyController.LegacyDisplayWrapper legacyDetails = BroadsoftTenancyController.getLegacyServices(basket.id);
        Test.stopTest();
        System.assertEquals((legacyDetails.legacyDetails!=null && !legacyDetails.legacyDetails.isEmpty()),true,'Services retrieved');
    }
    @isTest
    public static void getLegacyServicesErrorTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Account BroadSoft'];
    	Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceBroadsoftMock('error'));
        Test.startTest();
        BroadsoftTenancyController.LegacyDisplayWrapper legacyDetails = BroadsoftTenancyController.getLegacyServices(basket.id);
        Test.stopTest();
        System.assertEquals((legacyDetails.message=='Error String'),true,'API error');
    }
    @isTest
    public static void getLegacyServicesnoServicesTest(){
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__r.name FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='Account BroadSoft'];
    	Test.setMock(HttpCalloutMock.class, new ReplicatorGetServiceBroadsoftMock('noServices'));
        Test.startTest();
        BroadsoftTenancyController.LegacyDisplayWrapper legacyDetails = BroadsoftTenancyController.getLegacyServices(basket.id);
        Test.stopTest();
        String returnMessage = Label.BW_LegacyServiceUnavailable +' '+ basket.csbb__Account__r.name;
        System.debug('returnMessage: '+returnMessage);
        System.debug('legacyDetails.message: '+legacyDetails.message);
         System.debug('legacyDetails: '+legacyDetails);
        System.assertEquals((legacyDetails.message==returnMessage),true,'No services returned');
    }
    
}