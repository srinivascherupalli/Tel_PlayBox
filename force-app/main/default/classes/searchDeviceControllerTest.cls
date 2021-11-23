/*----------------------------------------------------------------------
EDGE        -150172
Class       -searchDeviceControllerTest
Description -test Class for searchDeviceController
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
@IsTest
public with sharing class searchDeviceControllerTest {
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
        
        Asset oldAsset= TestDataFactory.generateAsset('Aapple iphone 7',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'test12345');
        oldAsset.csord__Service__c=Service.Id;
        oldAsset.status='Active';
        Insert oldAsset;
        
        Asset newAsset= TestDataFactory.generateAsset('apple iphone 7',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'test123456');
        newAsset.Status='Active';
        newAsset.csordtelcoa__Replaced_Asset__c=oldAsset.id;
        newAsset.parentId=oldAsset.id;
        Insert newAsset;
        
        Asset newAsset1= TestDataFactory.generateAsset('apple iphone 7',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'test123457');
        newAsset1.Status='Active';
        newAsset1.csordtelcoa__Replaced_Asset__c=newAsset.id;
        newAsset1.parentId=oldAsset.id;
        Insert newAsset1;
    }
    @IsTest public static void getSearchedDeviceTest(){
        Asset asst=[SELECT id,AssetID__c,Subscription__c,csordtelcoa__Replaced_Asset__c FROM asset WHERE AssetID__c =:'test123457' LIMIT 1];
        Test.startTest();
        List<searchDeviceController.assetWrapper> assetList= searchDeviceController.getSearchedDevice(asst.AssetID__c);
        system.assert(!assetList.isEmpty());
        Test.stopTest();
    }
    @IsTest public static void getSearchedDeviceTest2(){
        Asset asst=[SELECT id,AssetID__c,Subscription__c,csordtelcoa__Replaced_Asset__c FROM asset WHERE AssetID__c =:'test12345' LIMIT 1];
        Test.startTest();
        List<searchDeviceController.assetWrapper> assetList= searchDeviceController.getSearchedDevice(asst.AssetID__c);
        system.assert(!assetList.isEmpty());
        Test.stopTest();
    }  
    @IsTest public static void getSearchedDeviceNegativeTest(){
        Test.startTest();
        List<searchDeviceController.assetWrapper> assetList= searchDeviceController.getSearchedDevice('Unknown Asset');
        system.assert(assetList.isEmpty());
        Test.stopTest();
    }  
    @IsTest public static void checkForPartnerUserTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                          UserName='testpermissionsetuser@test.com');
        insert u;
        System.runAs(u)
        {
            Test.startTest();
            Boolean isPartnerUser= searchDeviceController.checkForPartnerUser();
            system.assertEquals(false, isPartnerUser);
            Test.stopTest();
        }
    }
}