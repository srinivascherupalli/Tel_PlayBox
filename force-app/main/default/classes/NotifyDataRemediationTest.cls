/*=========================================================================================================================
EDGE       -171186
class      -NotifyDataRemediationTest 
Description-Test Class for NotifyDataRemediation Class.
Author     -Dheeraj Bhatt
===========================================================================================================================*/
@IsTest
public class NotifyDataRemediationTest {
  @testSetup static void setup() {
     account acc=TestDataFactory.generateAccount();
        
        Contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        insert productDefinition;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.name='Enterprise Mobility Managed Service';
        productConfig.Type__c='New';
        productConfig.ConfigurationType1__c = 'SolutionComponent';
        productConfig.Quantity_Product_Configuration__c = 111;
        productConfig.cscfga__Product_Definition__c=productDefinition.id;
        insert productConfig;
        
        csord__Order__c Order=TestDataFactory.generateOrder(acc.id,'Order Submitted','Order Submitted','Order','Order_456',system.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        insert Order;
        
        csord__Subscription__c subscription=TestDataFactory.generateSubscription();
        subscription.csord__Status__c='Active';
        subscription.csord__Order__c=Order.id;
        subscription.csord__Identification__c= Order.csord__Identification__c;
        subscription.csord__Account__c=acc.id;
        subscription.Billing_Account__c=billingAccount.id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.id;
        Update subscription;
        
        cspmb__Price_Item__c maincharge = new cspmb__Price_Item__c();
        maincharge.Name = 'Enterprise Mobility';
        maincharge.cspmb__Price_Item_Code__c = 'Enterprise Mobility';
        maincharge.cspmb__Product_Definition_Name__c = 'Enterprise Mobility';
        maincharge.cspmb__Is_Active__c = true;
        maincharge.Type__c = 'Mobile Broadband'; 
        insert maincharge;
        
        List<csord__Service__c> serviceList=new List<csord__Service__c>();
        csord__Service__c service=new csord__Service__c();
        service.csordtelcoa__Product_Configuration__c = productConfig.id;
        service.mainCharge__c = maincharge.id; 
        service.name ='Handheld';
        service.csord__Identification__c = productConfig.id;
        service.csord__Subscription__c=subscription.id;
        service.Billing_Account__c=billingAccount.id;
        service.csord__Status__c='connected';
        serviceList.add(service);
        
        csord__Service__c service2=new csord__Service__c();
        service2.name ='Adaptive Mobility';
        service2.csord__Status__c='In Progress';
        service2.csord__Subscription__c=subscription.id;
        service2.csord__Identification__c = productConfig.id;
        serviceList.add(service2);
        insert serviceList;   
    }
    @isTest static void notificationCreationTest() {
        Test.startTest();
        NotifyDataRemediation notify = new NotifyDataRemediation();
        Id batchId = Database.executeBatch(notify);
        Test.stopTest();
        System.assertEquals(2, [select count() from Notification_Preference__c]);
    }
    @isTest static void notificationCreationNegativeTest() {
        Test.startTest();
        csord__Service__c service =[Select Id,csord__Status__c FROM csord__Service__c  WHERE csord__Status__c='connected'];
        service.csord__Status__c='In Progress';
        update service;
        NotifyDataRemediation notify = new NotifyDataRemediation();
        Id batchId = Database.executeBatch(notify);
        Test.stopTest();
        System.assertEquals(0, [select count() from Notification_Preference__c]);
    }
}