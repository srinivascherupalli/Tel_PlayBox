/********************************************************************************
 EDGE       -140733
Class       -SubscriptionLockUnlockController
Description -Test Class for SubscriptionLockUnlockController class
Author      -Dheeraj Bhatt
 ********************************************************************************/
@IsTest
public with sharing class SubscriptionLockUnlockControllerTest {
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
        product2 product=TestDataFactory.generateProduct('(NBN) SLA PREMIUM BUSINESS PLUS BUSINESS IP BROADBAND ON THE NBN',true, 'NBNP12');
        Insert Product;
        
        Contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
        csord__Order__c Order=TestDataFactory.generateOrder(acc.id,'Order Submitted','Order Submitted','Order','Order_456',system.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        insert Order;
        
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Next Generation Voice';
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000871';
        prodDef.cscfga__Description__c='Next Generation Voice';
        Insert prodDef;
        
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cscfga__Product_Definition__c=prodDef.id;
        update pc;
        
        csord__Subscription__c subscription=new csord__Subscription__c();
        subscription.csord__Status__c='Active';
        subscription.Name='Next Generation Voice';
        subscription.csord__Identification__c=subscription.Id;
        subscription.csord__Order__c=Order.id;
        subscription.csord__Identification__c= Order.csord__Identification__c;
        subscription.csord__Account__c=acc.id;
        subscription.Billing_Account__c=billingAccount.id;
        subscription.csordtelcoa__Product_Configuration__c=pc.id;
        insert subscription;
        
        csord__Subscription__c subscription1=TestDataFactory.generateSubscription();
        subscription1.Name='Next Generation Voice';
        subscription1.csord__Identification__c=subscription1.Id;
        subscription1.csord__Status__c='Pending Port Out';
        subscription1.csord__Order__c=Order.id;
        subscription1.csord__Identification__c= Order.csord__Identification__c;
        subscription1.csord__Account__c=acc.id;
        subscription1.Billing_Account__c=billingAccount.id;
        subscription1.csordtelcoa__Product_Configuration__c=pc.id;
        update subscription1;
        system.debug('subscription=='+subscription);

    }
/**********************************************************************************************************
EDGE       -140733
Method     -Test method for getSubscriptions method for SubscriptionLockUnlockController class.
Description-Test class for  
Author     -Dheeraj Bhatt
************************************************************************************************************/
    @IsTest public static void getSubscriptionsForActiveSubscriptionTest(){
        Test.startTest();
        Account acc=[SELECT id FROM Account Limit 1];
        csord__Subscription__c subscription=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE csord__Status__c =:'Active' LIMIT 1];
        List<csord__Subscription__c> subscriptionlist=SubscriptionLockUnlockController.getSubscriptions(acc.id, 'Active');
        Test.stopTest();
        system.assertEquals(subscription.csord__Status__c, subscriptionlist[0].csord__Status__c);
    }
/**********************************************************************************************************
EDGE       -140733
Method     -Test method for getSubscriptions method for SubscriptionLockUnlockController class.
Description-Test class for  
Author     -Dheeraj Bhatt
************************************************************************************************************/
    @IsTest public static void getSubscriptionsForPendingPortOutSubscriptionTest(){
        Test.startTest();
        Account acc=[SELECT id FROM Account Limit 1];
        csord__Subscription__c subscription=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE csord__Status__c='Pending Port Out' LIMIT 1];
        List<csord__Subscription__c> subscriptionlist=SubscriptionLockUnlockController.getSubscriptions(acc.id, 'Pending Port Out');
        Test.stopTest();
        system.assertEquals(subscription.csord__Status__c, subscriptionlist[0].csord__Status__c);
    }
/**********************************************************************************************************
EDGE       -140733
Method     -Test method for submitSubscriptions method for SubscriptionLockUnlockController class.
Description-Test class for  
Author     -Dheeraj Bhatt
************************************************************************************************************/
    @IsTest public static void submitSubscriptionsLockTest(){
        Test.startTest();
        Account acc=[SELECT id FROM Account Limit 1];
        List<csord__Subscription__c> subscriptionList=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE csord__Status__c='Pending Port Out' LIMIT 1];
        SubscriptionLockUnlockController.submitSubscriptions(subscriptionList, 'Pending Port Out');
        Test.stopTest();
        csord__Subscription__c subscription=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE id =:subscriptionList[0].id ];
        system.assertEquals(subscription.csord__Status__c, subscriptionlist[0].csord__Status__c);
    }
/**********************************************************************************************************
EDGE       -140733
Method     -Test method for submitSubscriptions method for SubscriptionLockUnlockController class.
Description-Test class for  
Author     -Dheeraj Bhatt
************************************************************************************************************/
     @IsTest public static void submitSubscriptionsUnlockTest(){
        Test.startTest();
        Account acc=[SELECT id FROM Account Limit 1];
        List<csord__Subscription__c> subscriptionList=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE csord__Status__c='Active' LIMIT 1];
        SubscriptionLockUnlockController.submitSubscriptions(subscriptionList, 'Active');
        Test.stopTest();
        csord__Subscription__c subscription=[SELECT id,csord__Status__c FROM csord__Subscription__c WHERE id =:subscriptionList[0].id ];
        system.assertEquals(subscription.csord__Status__c, subscriptionlist[0].csord__Status__c);
    }
}