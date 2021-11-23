/*-----------------------------------------------------------------------------------------
EDGE        -80869
Class       -DeviceReplacementControllerTest
Description -Test Class for DeviceReplacementController class.
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------------------*/
@IsTest
public class DeviceReplacementControllerTest { 
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
        product2 product=TestDataFactory.generateProduct('(NBN) SLA PREMIUM BUSINESS PLUS BUSINESS IP BROADBAND ON THE NBN',true, 'NBNP12');
        Insert Product;
        Contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        //Start of EDGE-141567
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        //productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000423';
        insert productDefinition;
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        //Added productConfig.cscfga__Product_Definition__c. 
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        productConfig.Name='Device';
        pcList.add(productConfig);
        insert pcList;
        
        
        //End of :EDGE-141567 
        csord__Order__c Order=TestDataFactory.generateOrder(acc.id,'Order Submitted','Order Submitted','Order','Order_456',system.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        Order.telstra_ord_Start_DateTime__c=System.now(); //EDGE-182667
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
        //Start of :EDGE-141567
        subscription.csordtelcoa__Product_Configuration__c = productConfig.id;
        //End of :EDGE-141567
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
        //Start of :EDGE-141567
        service.csordtelcoa__Product_Configuration__c=productConfig.id;
        //End of :EDGE-141567
        update service;
        //Added by vamsi for EDGE-178892 on 25Mar2021 starts 
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='batchSizeAssetUpdate';
        env_var.value__c='20';
        insert env_var; 
        //Added by vamsi for EDGE-178892 on 25Mar2021 ends 
        Asset asst= TestDataFactory.generateAsset('EDGE-80869',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'apple iphone 7');
        asst.csord__Service__c=Service.Id;
        asst.status='Active';
        Insert asst;
        Asset replacedAsset= TestDataFactory.generateAsset('EDGE-120942',subscription.id,Product.id,system.today(),system.today(), 1.0,acc.id,'SAmsung Galaxy 8');
        replacedAsset.csord__Service__c=Service.Id;
        replacedAsset.status='InActive';
        replacedAsset.csordtelcoa__Replaced_Asset__c=asst.id;
        Insert replacedAsset;
        cscrm__Address__c address= TestDataFactory.generateAddress('12345678','AUSTRALIA','VIC','3000','Lonsdale','ST','150','Lonsdale St');
        insert address;
        CSPOFA__Orchestration_Process_Template__c processTemplate =TestUtil.createOPTemplate('Order Fulfilment Process');
        insert processTemplate;
         /*** 
          * EDGE-122982 
            Adding new 'DeviceType' to Attachment
          * EDGE-132532 
            Adding 'NextGenerationVoiceProductInstanceID' and its value to Attachment
         ***/
        String attachbody='{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","productConfigurationId":"a3T2N0000003jSxUAI","name":"423_RC_510","metadata":{},"instanceId":"","includeBilling":false,"guid":"1118795f-ade2-1dd5-39d0-4fe3ec3f931b","endDate":"","description":"Mobile Device_Billing_RecurringCharge_000510","code":"DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000423_DMCAT_RecurringCharge_000510_7366","otcDescription":"Apple iPhone 11 Pro 512GB Midnight Green 4GX","creditDescription":"Apple iPhone 11 Pro 512GB Midnight Green 4GX","ContractType":"Hardware Repayment","ContractTerm":"24","billDescription":"Apple iPhone 11 Pro 512GB Midnight Green 4GX repayment","rateExcludeGST":"88.97","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"false","billInAdvance":"true","billingSpecId":"BSRO001_CB","frequency":"Monthly","currency":"AUD","type":"RC","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423DMCAT_Offer_000646_","productConfigurationId":"a3T2N0000003jSxUAI","name":"Mobile Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"677e2515-4c19-a4ce-7f3a-d2cea2017312","endDate":"","description":"Mobile Device_Fulfilment","code":"DMCAT_ProductSpecification_000423_Fulfilment","attributes":{"DeviceType":"Mobile Handset","SKU":"100159714","MobileHandsetColour":"MIDNIGHT GREEN","MobileHandsetModel":"APPLE IPHONE 11 PRO 512GB 4GX","MobileHandsetManufacturer":"APPLE","Quantity":1,"parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","ShippingRequired":"TRUE","DeviceIDType":"","DeviceID":"","__targetSystem":"FULFILMENT","MobileHandsetVendor":""},"additionalAttributes":{}}],"serviceId":"a4e2N0000001IGxQAM","legacyAttributes":[]}';
            Attachment attach=TestDataFactory.generateAttachment('ServiceSpecifications.json',attachbody , service.id);
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -searchDeviceTest
Description -Test Method to cover  searchDevice method DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void searchDeviceTest(){
        Account acc=[select id from account LIMIT 1];
        Asset asst=[SELeCT id,AssetID__c,Subscription__c from asset LIMIT 1];
        Test.startTest();
        List<csord__Subscription__c> subscription=   DeviceReplacementController.searchDevice(acc.Id, asst.AssetID__c);
        Test.stopTest();
        system.assertEquals(asst.Subscription__c, subscription[0].id);
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -searchDeviceNegativeTest
Description -Test Method to cover negative scenerio searchDevice method of DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void searchDeviceNegativeTest(){
        Account acc=[select id from account LIMIT 1];
        Asset asst=[SELECT id,AssetID__c,Subscription__c from asset LIMIT 1];
        Test.startTest();
        List<csord__Subscription__c> subscription=DeviceReplacementController.searchDevice(acc.Id,'EDGE-80869_Test');
        DeviceReplacementController.searchDevice(acc.id,'Edge-80869_test');
        Test.stopTest();
        system.assertEquals(0, subscription.size());
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -getOptionvalueTest
Description -Test Method to cover getOptionvalue method of DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void getOptionvalueTest(){
    //Start of :EDGE-141567
    Test.startTest();
    List<DeviceReplacementController.OptionValueWrapperClass> wrapper= DeviceReplacementController.getOptionvalue('Reverse_Logistic_Return_Reason__mdt');
    Test.stopTest();
   List<String> results= new List<String>();
   for (DeviceReplacementController.OptionValueWrapperClass result:wrapper)
     {
         results.add(result.option);
     }
    system.assertEquals(true,results.contains('warranty'));
     //End of :EDGE-141567
    }
        /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -getOptionvalueNegativeTest
Description -Negative Test Method to cover getOptionvalue method of DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void getOptionvalueNegativeTest(){
   //Start of :EDGE-141567
   Test.startTest(); 
   List<DeviceReplacementController.OptionValueWrapperClass> wrapper= DeviceReplacementController.getOptionvalue('ReverseLogistic__mdt');
   Test.stopTest();
   system.assertEquals(0,wrapper.size());
    //End of :EDGE-141567
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -createOrderTest
Description -Test Method to cover negative scenerio in createOrder method of DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void createOrderTest(){
         Asset asst=[SELeCT id,AssetID__c,accountId,name,Subscription__c from asset WHERE name=:'EDGE-80869' LIMIT 1];
        Contact con=[select id from contact LIMIT 1];
        cscrm__Address__c address=[SELECT id FROM cscrm__Address__c LIMIT 1];
        csord__Subscription__c subscription=[Select id, Site__c,csord__Order__c,Billing_Account__c, csordtelcoa__Subscription_Number__c,CreatedDate,
                                             csord__Status__c,CreatedById,
                                             csord__Account__c, Name, MarketableOffer__c,serviceMSISDN__c FROM csord__Subscription__c  LIMIT 1];
        String shellProductDetails='{"replacedDeviceID":"apple iphone 7","replacementDeviceSKU":"6789","replacementDeviceManufacturer":"Apple","replacementDeviceModel":"Iphone 11","deviceCareCaseID":"DCMMCtest","telstraNowCaseID":"TNC","recoveryMethod":"Satchel","returnReason":"warranty"}';
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        csord__Order__c order=  DeviceReplacementController.createOrder(asst.accountId, subscription,shellProductDetails,con.id,address.id,tNowCaseRef);
        Test.stopTest();
         system.assertNotEquals(null,order.csord__Order_Number__c);
    }
/*----------------------------------------------------------------------------------------------------
EDGE        -100994
Method      -assetOfferIdTest
Description -Test Method to cover  assetOfferId method for DeviceReplacementController Class
Author      -Mohammed Zeeshan
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void assetOfferIdTest(){
        Account acct=[select id from account LIMIT 1];
        Contact cont=[select id from contact LIMIT 1];
        cscrm__Address__c address1=[SELECT id FROM cscrm__Address__c LIMIT 1];
        csord__Order__c order1=[select id from csord__Order__c LIMIT 1];
        Asset assts=[SELECT id,AssetID__c,Subscription__c FROM asset LIMIT 1];//80869
        assts.OfferID__c = 'DMCAT_Offer_000618';//80869
        update assts; // 80869 
         Test.startTest();
        Boolean varBoolean = DeviceReplacementController.assetOfferId(assts.AssetID__c);
        Boolean deviceSKUCheck = DeviceReplacementController.currentDeviceSKUCheck(assts.AssetID__c);
        
        Test.stopTest();
        System.assertEquals(varBoolean,true);
        } 
    /*----------------------------------------------------------------------------------------------------
EDGE        -Edge-100986
Method      -createOfferOrderTest
Description -Test Method to cover generateServiceSpec method of DeviceReplacementController Class
Author      -Mohammed Zeeshan
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void createOfferOrderTest(){
        Account acc=[select id from account LIMIT 1];
        Contact con=[select id from contact LIMIT 1];
        cscrm__Address__c address=[SELECT id FROM cscrm__Address__c LIMIT 1];
        Asset asst=[SELECT id,AssetID__c,Subscription__c FROM asset LIMIT 1];//80869
       asst.OfferID__c = 'DMCAT_Offer_000618';//80869
       update asst; // 80869
        csord__Subscription__c subscription=[Select id, Site__c,csord__Order__c,Billing_Account__c, csordtelcoa__Subscription_Number__c,CreatedDate,
                                             csord__Status__c,CreatedById,
                                             csord__Account__c, Name, MarketableOffer__c, serviceMSISDN__c FROM csord__Subscription__c  LIMIT 1];
        String shellProductDetails='{"replacedDeviceID":"apple iphone 7","replacementDeviceSKU":"6789","replacementDeviceManufacturer":"Apple","replacementDeviceModel":"Iphone 11","deviceCareCaseID":"DCMMCtest","telstraNowCaseID":"TNC","recoveryMethod":"Satchel","returnReason":"warranty"}';
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        csord__Order__c order=  DeviceReplacementController.createOrder(acc.id, subscription,shellProductDetails,con.id,address.id,tNowCaseRef);
        Test.stopTest();
        
        //Start of :EDGE-141567
        system.assertNotEquals(null,order.csord__Order_Number__c);
        //End of :EDGE-141567
    }
           /*----------------------------------------------------------------------------------------------------
EDGE        -Edge-100986
Method      -ngucOffer
Description -Test Method to cover generateServiceSpec method of DeviceReplacementController Class
Author      -Mohammed Zeeshan
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void ngucOfferTest(){
        Account acc=[select id from account LIMIT 1];
        Contact con=[select id from contact LIMIT 1];
        Asset asst=[SELECT id,AssetID__c,Subscription__c,accountId,OfferID__c FROM asset LIMIT 1];
        asst.OfferID__c = 'DMCAT_Offer_000618';//80869
        asst.accountId=acc.id;
        update asst;
        Test.startTest();
        String ngucoffer = DeviceReplacementController.ngucOffer(asst.AssetID__c);
        Test.stopTest();
        //Start of :EDGE-141567
        System.assertEquals('DMCAT_Offer_000618',ngucoffer);
        //End of :EDGE-141567
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -createOrderNegativeTest
Description -Test Method to cover createOrder method negative scenerio DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void createOrderNegativeTest(){
        Account acc=[select id from account LIMIT 1];
        Contact con=[select id from contact LIMIT 1];
        cscrm__Address__c address=[SELECT id FROM cscrm__Address__c LIMIT 1];
        csord__Subscription__c subscription=[Select id, Site__c,csord__Order__c,Billing_Account__c, csordtelcoa__Subscription_Number__c,CreatedDate,
                                             csord__Status__c,CreatedById,
                                             csord__Account__c, Name, serviceMSISDN__c FROM csord__Subscription__c  LIMIT 1];
        String shellProductDetails='{"replacedDeviceID":"apple iphone 7","replacementDeviceSKU":Test1234,"replacementDeviceManufacturer":"Apple","replacementDeviceModel":"Iphone 11","deviceCareCaseID":"DCMMCtest","telstraNowCaseID":"TNC","recoveryMethod":"Satchel","returnReason":"warranty"}';
        Test.startTest();
        String tNowCaseRef='TCN123456789';
       csord__Order__c order= DeviceReplacementController.createOrder(acc.id, subscription,shellProductDetails,con.id,address.id,tNowCaseRef);
        Test.stopTest();
        system.assertEquals(null,order);
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -showAddReplaceButtonTest
Description -Test Method to cover showAddReplaceButton method of DeviceReplacementController Class
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @IsTest public static void showAddReplaceButtonTest(){
        Asset replacedAsset=[SELECT id,AssetID__c,status,accountId,OfferID__c FROM asset WHERE name=:'EDGE-120942' LIMIT 1];
        Asset asst=[SELeCT id,AssetID__c,accountId,Subscription__c from asset Where name=:'EDGE-80869' LIMIT 1];
        Test.startTest();
        String Status= DeviceReplacementController.showAddReplaceButton(asst.accountId, asst.AssetID__c);
        Test.stopTest();
        system.assertEquals(replacedAsset.status, Status);
    }
}