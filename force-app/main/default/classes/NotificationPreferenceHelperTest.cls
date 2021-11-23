@IsTest
public class NotificationPreferenceHelperTest {
    @Testsetup   Public static void dataSetup(){
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
        insert service;
        
        csord__Service__c service2=TestDataFactory.generateService();
        service2.name ='Adaptive Mobility';
        service2.csord__Subscription__c=subscription.id;
        service2.csord__Identification__c = productConfig.id;
        serviceList.add(service2);
        update serviceList;
    }
    /*=========================================================================================================================
EDGE       -EDGE-170949/170948
Method     -notificationPreferenceTest 
Description-Test method for createNotificationPreference Method in Orchestration_CreateLegacyService Class for positive scenerio
Author     -Dheeraj Bhatt
===========================================================================================================================*/
    public static testmethod void notificationPreferenceTest(){
        Test.startTest();
        csord__Service__c serRecs = [SELECT id,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csord__Subscription__c,Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,csordtelcoa__Service_Number__c,mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.name ,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.csord__Order__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__c, csord__Order__c
                                     FROM csord__Service__c WHERE name =: 'Handheld' Limit 1 ];
        Map<string,List<Plan__mdt>> mapOfProductAndPlan=NotificationPreferenceHelper.getProductandPlanMetadata();
        List<Notification_Preference__c> notificationPreferenceList=NotificationPreferenceHelper.createNotificationPreference(serRecs, mapOfProductAndPlan);
        system.assertEquals(2,notificationPreferenceList.size());
        Test.stopTest();             
    }
    /*=========================================================================================================================
EDGE       -EDGE-170949/170948
Method     -notificationPreferenceTest 
Description-Test method for createNotificationPreference Method in Orchestration_CreateLegacyService Class for negative scenerio
Author     -Dheeraj Bhatt
===========================================================================================================================*/
    public static testmethod void notificationPreferenceNegativeTest(){
        Test.startTest();
        csord__Service__c serRecs = [SELECT id,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csord__Subscription__c,Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,csordtelcoa__Service_Number__c,mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.name ,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.csord__Order__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__c, csord__Order__c
                                     FROM csord__Service__c  WHERE name ='Adaptive Mobility' Limit 1 ];
        Map<string,List<Plan__mdt>> mapOfProductAndPlan=NotificationPreferenceHelper.getProductandPlanMetadata();
        List<Notification_Preference__c> notificationPreferenceList=NotificationPreferenceHelper.createNotificationPreference(serRecs, mapOfProductAndPlan);
        system.assertEquals(0,notificationPreferenceList.size());
        Test.stopTest();             
    } 
}