/******************************************************************************************************************************
Class Name : PSLIPriceScheduleTest

Sr.No.  Developer       Date          Story Description        Sprint
1.      Aman Soni       28/04/2020    EDGE-123593(New Class)   20.05
******************************************************************************************************************************/
@isTest
public class PSLIPriceScheduleTest{
    //Method for test data Setup
    @TestSetup static void CreateData(){
        
        Account testAccount = TestDataFactory.generateAccount();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        update testAccount;
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;

        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        
        List<Charge_Line_Item__c> cliLst = new List<Charge_Line_Item__c>();
        Charge_Line_Item__c priceItemCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationid1',configGuid,'Price Item');
        priceItemCLI1.status__c='Active';
        cliLst.add(priceItemCLI1);
        
        Charge_Line_Item__c addonCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationid2',configGuid,'AddOn');
        addonCLI1.status__c='Active';
        cliLst.add(addonCLI1);
        
        Charge_Line_Item__c deviceCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationid3',configGuid,'Device');
        deviceCLI1.status__c='Active';
        cliLst.add(deviceCLI1);
        insert cliLst;
        
        List<Price_Schedule_Line_Item__c> psliLst = new List<Price_Schedule_Line_Item__c>();
        Price_Schedule_Line_Item__c pslip1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','3',0.00,priceItemCLI1);
        psliLst.add(pslip1);
        Price_Schedule_Line_Item__c pslip2 = PricingTestDataFactory.generatePriceScheduleLineItem('4','24',43.80,priceItemCLI1);
        psliLst.add(pslip2);
        Price_Schedule_Line_Item__c pslip3 = PricingTestDataFactory.generatePriceScheduleLineItem('25','99999',63.18,priceItemCLI1);
        psliLst.add(pslip3);
        Price_Schedule_Line_Item__c psliA1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','99999',10.90,addonCLI1);
        psliLst.add(psliA1);
        Price_Schedule_Line_Item__c psliD1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','99999',11.90,deviceCLI1);
        psliLst.add(psliD1);
        insert psliLst;
        
        List<Discount_Line_Item__c> dliLst = new List<Discount_Line_Item__c>();
        Discount_Line_Item__c dli1 = PricingTestDataFactory.generateDiscountLineItems('Activation Credits Months Discount Dummy','100','Percent',priceItemCLI1);
        dliLst.add(dli1);
        Discount_Line_Item__c dli2 = PricingTestDataFactory.generateDiscountLineItems('MMC Discount Dummy','10','',priceItemCLI1);
        dliLst.add(dli2);
        Discount_Line_Item__c dli3 = PricingTestDataFactory.generateDiscountLineItems('Postpaid MRO Plan Discount Dummy','19.1','',priceItemCLI1);
        dliLst.add(dli3);
        Discount_Line_Item__c dli4 = PricingTestDataFactory.generateDiscountLineItems('IDD Call Pack Discount Dummy','20','Percent',addonCLI1);
        dliLst.add(dli4);
        Discount_Line_Item__c dli5 = PricingTestDataFactory.generateDiscountLineItems('Device Discount Dummy','20','',deviceCLI1);
        dliLst.add(dli5);
        insert dliLst;
        
        List<Price_Schedule_Discount_Association__c> psdaLst = new List<Price_Schedule_Discount_Association__c>();
        Price_Schedule_Discount_Association__c psda1 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(pslip1,dli1);
        psdaLst.add(psda1);
        Price_Schedule_Discount_Association__c psda2 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(pslip2,dli2);
        psdaLst.add(psda2);
        Price_Schedule_Discount_Association__c psda3 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(pslip2,dli3);
        psdaLst.add(psda3);
        Price_Schedule_Discount_Association__c psda4 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(pslip3,dli2);
        psdaLst.add(psda4);
        Price_Schedule_Discount_Association__c psda5 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(psliA1,dli4);
        psdaLst.add(psda5);
        Price_Schedule_Discount_Association__c psda6 = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(psliD1,dli5);
        psdaLst.add(psda6);
        insert psdaLst;        
    }
    
    // Test method to cover Price Item Summary Response
    @isTest
    private static void fetchPlanModifyScheduleEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        System.runAs(sales){
        Map<String,Map<String,String>> response = customPriceScheduleController.fetchModifyScheduleEM(configGuid,true);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.PRICING_FILTER));}
        Test.stopTest();        
    }
    
    // Test method to cover AddOn Summary Response
    @isTest
    private static void fetchAddOnModifyScheduleEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        System.runAs(sales){
        Map<String,Map<String,String>> response = customPriceScheduleController.fetchModifyScheduleEM(configGuid,true);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.ADDON_FILTER));}
        Test.stopTest();       
    }
    
    // Test method to cover Device Summary Response
    @isTest
    private static void fetchDeviceModifyScheduleEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        System.runAs(sales){
        Map<String,Map<String,String>> response = customPriceScheduleController.fetchModifyScheduleEM(configGuid,true);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.DEVICE_FILTER));}
        Test.stopTest();       
    }
}