/*
===============================================================================================================================
Class : OrderEmailServiceWrapperHelperTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
@isTest
public with sharing class OrderEmailServiceWrapperHelperTest {

    @isTest
    public static void ordersSeperationTest() {

        Test.startTest(); 
        List<csord__Order__c> orderList = BDSNotifyTestFactory.createTestDataSI5Order();
        List<Id> orderIds = new List<Id>(new Map<Id, csord__Order__c>(orderList).keySet());
        Map<String, List<csord__Subscription__c>> seperatedMap = OrderEmailServiceWrapperHelper.ordersSeperation(orderIds);
        Test.stopTest();
        System.assert(seperatedMap.size() > 0, 'Order seperated succesfully');
        
    }   

    @isTest
    public static void createPORMapTest() {

        Test.startTest();
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataCancelComplete();
        Map<String, Partner_of_Record__c> porMap = OrderEmailServiceWrapperHelper.createPORMap(subscriptionList);
        Test.stopTest();
        System.assert(porMap.size() > 0, 'POR Map Created');
        
    }   

    @isTest
    public static void createAttributeMapTest() {

        Test.startTest();
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataCancelComplete();
        Map<String, String> attributeMap = OrderEmailServiceWrapperHelper.createAttributeMap(subscriptionList);
        Test.stopTest();
        System.assert(attributeMap.size() > 0, 'Attribute Map Created');
        
    }   

    @isTest
    public static void fetchReplacedSubscriptionTest() {

        Test.startTest();
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataCancelComplete();
        List<Id> subscriptionIds = new List<Id>(new Map<Id, csord__Subscription__c>(subscriptionList).keySet());
        List<csord__Subscription__c> replacedSubscriptions = OrderEmailServiceWrapperHelper.fetchReplacedSubscription(subscriptionIds);
        Test.stopTest();
        System.assert(replacedSubscriptions.size() > 0, 'Fetch Replaced Subscription');
        
    }   

    @isTest
    public static void createServiceMapTest() {

        Test.startTest();
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataCancelComplete();
        Map<Id, csord__Service__c> serviceMap = OrderEmailServiceWrapperHelper.createServiceMap(subscriptionList);
        Test.stopTest();
        System.assert(serviceMap.size() > 0, 'Service Map Created');
        
    }  

    @isTest
    public static void fetchApplicableDiscountTest() {

        Test.startTest();
        BDSNotifyTestFactory.createBdsNotifySettings();
        BDSNotifyTestFactory.createDiscountLevel();
        cspmb__Discount_Level__c discountLevel = OrderEmailServiceWrapperHelper.fetchApplicableDiscount('DMCAT_Discount_001269');
        Test.stopTest();
        System.debug('Discount Duration :: ' + discountLevel.cspmb__duration__c);
        System.assert(discountLevel.cspmb__duration__c == 30, 'Discount Duration');
        
    }  

    @isTest
    public static void fetchSubscriptionsMOTest() {

        Test.startTest();
        BDSNotifyTestFactory.createTestDataTimeBound(-30); 
        List<csord__Subscription__c> subscriptions = OrderEmailServiceWrapperHelper.fetchSubscriptionsMO('DMCAT_Offer_000681');
        Test.stopTest();
        System.assert(subscriptions.size() > 0, 'POR Map Created');
        
    } 

    @isTest
    public static void fetchServicesPSTest() {

        Test.startTest();
        BDSNotifyTestFactory.createTestDataTimeBound(-30); 
        Map<String, List<csord__Service__c>> servicemap = OrderEmailServiceWrapperHelper.fetchServicesPS('DMCAT_ProductSpecification_001506');
        Test.stopTest();
        System.assert(servicemap.size() > 0, 'Service Map Created');
        
    }
    
}