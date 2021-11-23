/*
===============================================================================================================================
Class : AutoRefreshConfiguratorCache
Developer Name : Shubhi
Test Class : AutoRefreshConfiguratorCacheTest
===============================================================================================================================

*/

@isTest
public class AutoRefreshConfiguratorCacheTest { 
    
    @testSetup public static void setup() {
        csutil__JSON_Data__c jsondata=new csutil__JSON_Data__c();
        jsondata.name='AutoRefreshConfiguratorCache';
        jsondata.csutil__value__c='12345,123456';
        insert jsondata;
        
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();

    }
        @istest
    public static void  testschedule() {
        Test.StartTest();
        
        Test.setMock(HttpCalloutMock.class, new autoRefreshMockTest());
        AutoRefreshConfiguratorCache sh1 = new AutoRefreshConfiguratorCache ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        System.assertEquals('0 0 23 * * ?',sch);
        
        
        
        Test.stopTest();
    }

}