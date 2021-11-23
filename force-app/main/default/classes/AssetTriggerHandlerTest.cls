/*-----------------------------------------------------------------------------------------
EDGE        -87057
Class       -AssetTriggerHandlerTest
Description -Test class forTrigger Handler Class of asset Trigger
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------------------*/

@Istest
public class AssetTriggerHandlerTest {
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
        
        csord__Subscription__c subscription=TestDataFactory.generateSubscription();
        subscription.csord__Status__c='Active';
        subscription.csord__Order__c=Order.id;
        subscription.csord__Identification__c= Order.csord__Identification__c;
        subscription.csord__Account__c=acc.id;
        subscription.Billing_Account__c=billingAccount.id;
        subscription.recoveryMethod__c='eParcel';
        subscription.returnReasonType__c='warrenty';
        subscription.devicecareCaseId__c='DCMMCtest';
        subscription.TNowCaseId__c='TNCtest';
        Update subscription;
        
        csord__Service__c service=TestDataFactory.generateService();
        service.csord__Order__c=Order.id;
        service.csord__Status__c='Pending';
        service.Scenario_Type__c = 'Device_replace';
        service.csord__Identification__c=Order.csord__Identification__c;
        service.csord__Subscription__c=Subscription.id;
        service.recoveryMethod__c='eParcel';
        service.returnReasonType__c='warrenty';
        service.devicecareCaseId__c='DCMMCtest';
        service.TNowCaseId__c='TNCtest';
        update service;
        
        Asset oldAsset= TestDataFactory.generateAsset('Old_EDGE-80869',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'apple iphone 7');
        oldAsset.csord__Service__c=Service.Id;
        oldAsset.status='Active';
        Insert oldAsset;
        
        Asset newAsset= TestDataFactory.generateAsset('New_EDGE-80869',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'apple iphone 7');
        newAsset.Status='Inactive';
        newAsset.csordtelcoa__Replaced_Asset__c=oldAsset.id;
        Insert newAsset;
    }
  /*-----------------------------------------------------------------------------------------
EDGE        -87057
Method      -afterUpdateTest
Description -Test Method for afterUpdate Method in AssetTriggerHandler Class
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------------------*/
    @IsTest public static void afterUpdateTest(){
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='batchSizeAssetUpdate';
        env_var.value__c='20';
        insert env_var; 
        Asset asst=[SELECT id,AssetID__c,Subscription__c,csordtelcoa__Replaced_Asset__c FROM asset WHERE name =:'New_EDGE-80869' LIMIT 1];
        asst.Status='Active';
        Asset replacedAssetBeforeUpdate=[SELECT id,Status,AssetID__c,Subscription__c,csordtelcoa__Replaced_Asset__c FROM asset WHERE id =:asst.csordtelcoa__Replaced_Asset__c];
        Test.startTest();
        update asst;
        Test.stopTest();
        Asset replacedAsset=[SELECT id,Status,AssetID__c,Subscription__c,csordtelcoa__Replaced_Asset__c FROM asset WHERE id =:asst.csordtelcoa__Replaced_Asset__c];
        system.assertNotEquals(replacedAssetBeforeUpdate.Status, replacedAsset.Status);
    }
}