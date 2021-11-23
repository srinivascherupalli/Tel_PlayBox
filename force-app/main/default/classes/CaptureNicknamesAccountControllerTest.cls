/********************************************************************************************************************************
Main Class : CaptureNicknamesAccountController
Test Class : CaptureNicknamesAccountControllerTest
=================================================================================================================================
Sr.No.    Developer Name                Date            Story          Sprint               Description
1.        Adityen Krishnan           24/09/2021      DIGI-8027    21.04(New Class)     To cover CaptureNicknamesAccountController functionality
********************************************************************************************************************************/

@isTest(SeeAllData=FALSE)
public with sharing class CaptureNicknamesAccountControllerTest {
    @TestSetup
    static void setup(){
        

        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = pf.id,timezonesidkey='Australia/Sydney',
                username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;

        List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.name = 'Test Basket';
        basketLst.add(basket);
        insert basketLst;


        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c prodDefMS = new cscfga__Product_Definition__c();
        prodDefMS.product_Specification__c ='DMCAT_ProductSpecification_000420';
        prodDefMS.cscfga__Description__c ='Mobile Subscription';
        prodDefList.add(prodDefMS);
        insert prodDefList;

        List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c configMS = new cscfga__Product_Configuration__c();
        configMS.name = 'Test Config';
        configMS.cscfga__Product_Basket__c = basket.Id;
        configMS.cscfga__Product_Definition__c = prodDefMS.Id;
        configLst.add(configMS);
        insert configLst;

        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c order = new csord__Order__c();
        order.Name = 'Test Order';
        order.csord__Account__c = acc.Id;
        order.csord__Identification__c = 'Order_0';
        order.Product_Basket__c = basket.Id;
        orderList.add(order);
        insert orderList;

        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        csord__Subscription__c subMS = new csord__Subscription__c();
        subMS.name = 'Mobile-Subscription';
        subMS.csord__Identification__c = 'Subscription_0';
        subMS.csord__Account__c = acc.Id;
        subMS.csord__Status__c = 'Active';
        subMS.serviceMSISDN__c = '123456789123';
        subMS.Nickname__c = '';
        subMS.csord__Order__c = order.id;
        subMS.csordtelcoa__Product_Configuration__c = configMS.id;
        subList.add(subMS);
        
        
        insert subList;
    }
    //Positive Scenario
    @isTest static void getSubscriptionsRecordsTest(){
        Test.startTest();

            List<csord__Subscription__c> subsFinalList = new List<csord__Subscription__c>();
            Account acc = [select id,name from Account limit 1];
            subsFinalList = CaptureNicknamesAccountController.getSubscriptionsRecords(acc.Id);
            System.assertEquals(subsFinalList.isEmpty(), false, 'Subscription fetched successfully');
        Test.stopTest();
    }

    //Negative Scenario
    @isTest static void getSubscriptionsRecordsTestNegative(){
        Test.startTest();
        csord__Subscription__c sub = [Select Id,Name,csord__Account__c,csord__Status__c,serviceMSISDN__c,Nickname__c FROM csord__Subscription__c Where Name = 'Mobile-Subscription' LIMIT 1];
        sub.csord__Status__c = 'Pending';
        update sub;
        List<csord__Subscription__c> subsFinalList = new List<csord__Subscription__c>();
        Account acc = [select id,name from Account limit 1];
        subsFinalList = CaptureNicknamesAccountController.getSubscriptionsRecords(acc.Id);
        System.assertEquals(subsFinalList.isEmpty(), true, 'No Subscription records with Active/Provisioned status Found');
        Test.stopTest();
    }

    @isTest
    public static void updateNickNameTest(){
        List<String> subList = new List<String>();
        
        List <csord__Subscription__c> subRecTest = new List <csord__Subscription__c>();
        subRecTest  = [Select id,csordtelcoa__Subscription_Number__c,Nickname__c from csord__Subscription__c LIMIT 1 ];
        
        for(csord__Subscription__c sub : subRecTest){
            subList.add(sub.csordtelcoa__Subscription_Number__c);
        }
        
        System.debug('Sub Rec::'+subRecTest);
        System.debug('Sub List::'+subList);
        String metaDataRecName = 'SubscriptionNicknameOrder';
        String csvData = 'Subscription Name,Subscription Number,Solution Name,Service ID,Billing Account,Nickname\r\nHandheld-Epic_1,'+ subList[0]+',Adaptive Mobility,61474714986,700000730297,demo\r\n';
        String base64Data = JSON.serialize(csvData);
        String result = '';
        result = CaptureNicknamesAccountController.uploadFile(base64Data,metaDataRecName);
        test.startTest();
        System.assertEquals(result,Label.UploadFileSuccessMessage);
        test.stopTest();
        
    }
    
    @isTest
    public static void updateNickNameTestNegative(){
        
        String metaDataRecName = 'SubscriptionNicknameOrder';
        String csvData = 'Subscription Name,Subscription Number,Service ID,Billing Account\r\nHandheld-Epic_1,SN-000235372,61474714986,700000730296\r\nHandheld-Epic_1,SN-000235373,61474714986,700000730297\r\n';
        String base64Data = JSON.serialize(csvData);
        String result = '';
        result = CaptureNicknamesAccountController.uploadFile(base64Data,metaDataRecName);
        test.startTest();
        System.assertEquals(result,Label.UploadFileFailedMessage);
        test.stopTest();
        
    }
}