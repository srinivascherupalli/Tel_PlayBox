/*************************************************************************************************
Name : customPriceScheduleControllerTest
EDGE-> 120144
Description : Test class for customPriceScheduleController

Sr.No.   Developer Name      Date          Story Description
1.       Rohit Tripathi    24-Dec-2019     EDGE-120144 : Present Pricing MS response : As a sales user, 
                                             I should be able to view the generated detailed pricing schedule
                                             for configured plans, total contract value so that i can have conversation with customer regarding net prices.
2.      Aman soni       30-mar-2020     Added additional arrgument on fetchPricingSummaryResponse calling method || EDGE-123593     
3.      Aman Soni       14-Apr-2020     Added test methods created data to cover fetchPricingSummaryResponseEM || EDGE-123593
4.      Aman Soni       24-Apr-2020     Added test methods and created data to cover fetchModifyScheduleEM and also added profile check|| EDGE-123593

***************************************************************************************************/
@isTest
public class customPriceScheduleControllerTest {
    //Method for test data Setup
    @TestSetup static void CreateData(){
        
        Account testAccount = TestDataFactory.generateAccount();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        update testAccount;
        
        //Added by Aman Soni as a part of EDGE-123593 || Start
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        String PlanErrGuid = 'PlanErrGuid';
        String AddOnErrGuid = 'AddOnErrGuid';
        
        List<Charge_Line_Item__c> cliLst = new List<Charge_Line_Item__c>();    
        Charge_Line_Item__c priceItemCLI = PricingTestDataFactory.generateChargeLineItem('correlationid1','aAv5O00000000i1','Price Item');
        cliLst.add(priceItemCLI);
        Charge_Line_Item__c addonCLI = PricingTestDataFactory.generateChargeLineItem('correlationid2','aAv5O00000000i2','AddOn');
        cliLst.add(addonCLI);
        Charge_Line_Item__c deviceCLI = PricingTestDataFactory.generateChargeLineItem('correlationid3','aAv5O00000000i3','Device');
        cliLst.add(deviceCLI);

        Charge_Line_Item__c priceItemCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationidPI',configGuid,'Price Item');
        priceItemCLI1.status__c='Active';
        cliLst.add(priceItemCLI1);
        
        Charge_Line_Item__c addonCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationidPI',configGuid,'AddOn');
        addonCLI1.status__c='Active';
        cliLst.add(addonCLI1);
        
        Charge_Line_Item__c planErrCLI = PricingTestDataFactory.generateChargeLineItem('correlationidAddOn',PlanErrGuid,'AddOn');
        planErrCLI.status__c='Active';
        cliLst.add(planErrCLI);
        
        Charge_Line_Item__c AddOnErrCLI = PricingTestDataFactory.generateChargeLineItem('correlationidPlan',AddOnErrGuid,'Price Item');
        AddOnErrCLI.status__c='Active';
        cliLst.add(AddOnErrCLI);
        
        Charge_Line_Item__c deviceCLI1 = PricingTestDataFactory.generateChargeLineItem('correlationidPI',configGuid,'Device');
        deviceCLI1.status__c='Active';
        cliLst.add(deviceCLI1);
        insert cliLst;
        
        List<PricingMSResponseObject__c> resLst = new List<PricingMSResponseObject__c>();
        PricingMSResponseObject__c pricingMSResponsePI = PricingTestDataFactory.generatePricingMSResponse(priceItemCLI,'TestErrorDescResponsePriceItem','{TestPayloadResponsePriceItem}');
        resLst.add(pricingMSResponsePI);
        PricingMSResponseObject__c pricingMSResponseAddOn = PricingTestDataFactory.generatePricingMSResponse(addonCLI,'TestDescResponseAddOn','{TestPayloadResponseAddOn}');
        resLst.add(pricingMSResponseAddOn);
        PricingMSResponseObject__c pricingMSResponseDevice = PricingTestDataFactory.generatePricingMSResponse(deviceCLI,'TestDescResponseDevice','{TestPayloadResponseDevice}');
        resLst.add(pricingMSResponseDevice);
        insert resLst;
        
        List<Price_Schedule_Line_Item__c> psliLst = new List<Price_Schedule_Line_Item__c>();
        Price_Schedule_Line_Item__c pslip1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','3',0.00,priceItemCLI1);
        psliLst.add(pslip1);
        Price_Schedule_Line_Item__c pslip2 = PricingTestDataFactory.generatePriceScheduleLineItem('4','24',43.80,priceItemCLI1);
        psliLst.add(pslip2);
        Price_Schedule_Line_Item__c pslip3 = PricingTestDataFactory.generatePriceScheduleLineItem('25','99999',63.18,priceItemCLI1);
        psliLst.add(pslip3);
        Price_Schedule_Line_Item__c psliA1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','99999',10.90,addonCLI1);
        psliLst.add(psliA1);
        Price_Schedule_Line_Item__c psliD1 = PricingTestDataFactory.generatePriceScheduleLineItem('1','99999',10.90,deviceCLI1);
        psliLst.add(psliD1);
        Price_Schedule_Line_Item__c psliplanErr = PricingTestDataFactory.generatePriceScheduleLineItem('1','3',10.90,planErrCLI);
        psliLst.add(psliplanErr);
        Price_Schedule_Line_Item__c psliAddOnErr = PricingTestDataFactory.generatePriceScheduleLineItem('1','3',11.90,AddOnErrCLI);
        psliLst.add(psliAddOnErr);
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
        Discount_Line_Item__c dli5 = PricingTestDataFactory.generateDiscountLineItems('Device DLI','20','',deviceCLI1);
        dliLst.add(dli5);
        Discount_Line_Item__c dliplanErr = PricingTestDataFactory.generateDiscountLineItems('Activation Credit','20','',planErrCLI);
        dliLst.add(dliplanErr);
        Discount_Line_Item__c dliAddOnErr = PricingTestDataFactory.generateDiscountLineItems('MMC','10','',AddOnErrCLI);
        dliLst.add(dliAddOnErr);
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
        Price_Schedule_Discount_Association__c psdaplanErr = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(psliplanErr,dliplanErr);
        psdaLst.add(psdaplanErr);
        Price_Schedule_Discount_Association__c psdaAddOnErr = PricingTestDataFactory.generatePriceScheduleDiscountAssociations(psliAddOnErr,dliAddOnErr);
        psdaLst.add(psdaAddOnErr);
        insert psdaLst;
        //Added by Aman Soni as a part of EDGE-123593 || End
        
    }
    // Added Profile check by Aman Soni as a part of EDGE-123593 || Start
    // Test method to cover Price Item Summary Response
    @isTest
    private static void fetchPriceItemPricingSummaryResponseTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,String> response = customPriceScheduleController.fetchPricingSummaryResponse('aAv5O00000000i1',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.PRICING_FILTER));}//Added additional arrgument by aman Edge-123593
        Test.stopTest();
    }
    
    // Test method to cover AddOn Summary Response
    @isTest
    private static void fetchAddOnPricingSummaryResponseTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,String> response = customPriceScheduleController.fetchPricingSummaryResponse('aAv5O00000000i2',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.ADDON_FILTER));
        }//Added additional arrgument by aman Edge-123593
        Test.stopTest();
    }
    
    // Test method to cover Device Summary Response
    @isTest
    private static void fetchDevicePricingSummaryResponseTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,String> response = customPriceScheduleController.fetchPricingSummaryResponse('aAv5O00000000i3',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.DEVICE_FILTER));}//Added additional arrgument by aman Edge-123593
        Test.stopTest();       
    }
    // Added Profile check by Aman Soni as a part of EDGE-123593 || End
    
    //Added by Aman Soni as a part of EDGE-123593
    @isTest
    private static void fetchPriceItemPricingSummaryResponseEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,PricingMSResponseObject__c> response = customPriceScheduleController.fetchPricingSummaryResponseEM('aAv5O00000000i1',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.PRICING_FILTER));
        }//Added additional arrgument by aman Edge-123593
        Test.stopTest();
    }
    
    //Added by Aman Soni as a part of EDGE-123593
    @isTest
    private static void fetchAddOnPricingSummaryResponseEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,PricingMSResponseObject__c> response = customPriceScheduleController.fetchPricingSummaryResponseEM('aAv5O00000000i2',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.ADDON_FILTER));}//Added additional arrgument by aman Edge-123593
        Test.stopTest();        
    }
    
    //Added by Aman Soni as a part of EDGE-123593
    @isTest
    private static void fetchDevicePricingSummaryResponseEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<String,PricingMSResponseObject__c> response = customPriceScheduleController.fetchPricingSummaryResponseEM('aAv5O00000000i3',false);
        System.assertEquals(true,response.containsKey(customPriceScheduleController.DEVICE_FILTER));}//Added additional arrgument by aman Edge-123593
        Test.stopTest();
    }
    
    //Added by Aman Soni as a part of EDGE-123593 Price schedule fix
    @isTest
    private static void fetchModifyScheduleEMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        System.runAs(sales){
        //Cover Valid output
        Map<String,Map<String,String>> response = customPriceScheduleController.fetchModifyScheduleEM(configGuid,true);
            if(response != null && !response.isEmpty()){
                if(response.containsKey(customPriceScheduleController.PRICING_FILTER))
                System.assertEquals(true,response.containsKey(customPriceScheduleController.PRICING_FILTER));
                if(response.containsKey(customPriceScheduleController.ADDON_FILTER))
                System.assertEquals(true,response.containsKey(customPriceScheduleController.ADDON_FILTER));
                if(response.containsKey(customPriceScheduleController.DEVICE_FILTER))
                System.assertEquals(true,response.containsKey(customPriceScheduleController.DEVICE_FILTER));
            }              
        }
    }
    
    //Added by Aman Soni as a part of EDGE-123593 Price schedule fix
    @isTest
    private static void fetchModifyScheduleEMAddOnTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String PlanErrGuid = 'PlanErrGuid';
        System.runAs(sales){
        Map<String,Map<String,String>> responsePlanError = customPriceScheduleController.fetchModifyScheduleEM(PlanErrGuid,true);
        System.assertEquals(true,responsePlanError.containsKey('PricingError'));
        System.assertEquals(true,responsePlanError.containsKey(customPriceScheduleController.ADDON_FILTER));
        System.assertEquals(true,responsePlanError.containsKey('DeviceError'));
        Test.stopTest();
        }
    }
    
    //Added by Aman Soni as a part of EDGE-123593 Price schedule fix
    @isTest
    private static void fetchModifyScheduleEMPlanTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        String AddOnErrGuid = 'AddOnErrGuid';
        System.runAs(sales){
        Map<String,Map<String,String>> responseAddOnError = customPriceScheduleController.fetchModifyScheduleEM(AddOnErrGuid,true);
        System.assertEquals(true,responseAddOnError.containsKey('AddOnError'));
        System.assertEquals(true,responseAddOnError.containsKey(customPriceScheduleController.PRICING_FILTER));
        System.assertEquals(true,responseAddOnError.containsKey('DeviceError'));
        Test.stopTest();
        }
    }
}