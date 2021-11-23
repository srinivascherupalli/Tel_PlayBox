/*
* @Author : Suyash Chiplunkar
* @Date : 1 July 2020
* @Desc : RateMatrixForIoTController for display rate   
* @Jira : DPG-1964
* @testclass : RateMatrixForIoTControllerTest
===============================================================================================================================
Sr.No.    Developer Name     Date            Story Description 
1      Shresth Dixit                        DPG - 2395
2      Shresth Dixit                            DPG - 2745
3      Shresth Dixit                               DPG - 2319
4      Aruna Aware      16/07/2021      DIGI-1597 - Configure plans/ allowances for shared data plan variants (DPG-5395)
5	   Aruna Aware      13/10/2021	    DIGI-31600 - Not finding the pricing values in rate card for the plans of all the three plan variants.
===============================================================================================================================
*/
@IsTest public class RateMatrixForIoTControllerTest {
    @TestSetup static void testdata(){
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        upsert testBasket;
        
        cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
            Name = 'IoT Shared Data 50KB',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'IoT Shared Data',
            cspmb__Product_Definition_Name__c = 'IoT Solutions',
            Commercial_Product_Code__c = 'IoT Shared Data',
            External_Id__c = 'dmcat_112',
            Charge_Id__c='DMCAT_RecurringCharge_000814',
            Package_Name__c = 'IoT Solution',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_000964',
            Plan__c = '50 KB',
            cspmb__Type__c  = 'Commercial Product',
            cspmb__Role__c = 'Basic'
        );
        
        insert price_item_shared_data;
        
        cspmb__Price_Item__c price_item_shared_data1 = new cspmb__Price_Item__c(
            Name = 'IoT Shared Data 500KB_V2',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'IoT Shared Data',
            cspmb__Product_Definition_Name__c = 'IOT Mobility',
            Commercial_Product_Code__c = 'IoT Shared Data',
            External_Id__c = 'dmcat_1124',
            Charge_Id__c='DMCAT_RecurringCharge_000814',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_001522',
            Plan__c = '500KB',
            Offer_Type__c='Shared Data',
            Plan_Type__c='LTE',           
            cspmb__Type__c  = 'Commercial Product',
            cspmb__Role__c = 'Basic'
        );
        
        insert price_item_shared_data1;
        
        List<cspmb__Rate_Card__c> lstRateCards = new List<cspmb__Rate_Card__c>();
        
        cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
        rateCard_shared_data.Name = 'IoT Shared Data 50KB';
        rateCard_shared_data.Offer_Id__c ='DMCAT_Offer_000964';
        rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';  
        rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data);
        
        cspmb__Rate_Card__c rateCard_shared_data1 = new cspmb__Rate_Card__c();
        rateCard_shared_data1.Name = 'IoT Shared Data 500KB_V2';
        rateCard_shared_data1.Offer_Id__c ='DMCAT_Offer_001522';
        rateCard_shared_data1.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';  
        rateCard_shared_data1.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data1.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data1.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data1);
        
        cspmb__Rate_Card__c rateCard_shared_data2 = new cspmb__Rate_Card__c();
        rateCard_shared_data2.Name = 'IoT Shared Data 500KB_ExcessCharge';
        rateCard_shared_data2.Offer_Id__c ='DMCAT_Offer_001522';
        rateCard_shared_data2.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000815';  
        rateCard_shared_data2.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data2.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data2.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data2);
        insert  lstRateCards;
        
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        
        cspmb__Rate_Card_Line__c rcl1 = new cspmb__Rate_Card_Line__c();
        rcl1.toUnit__c = 499;
        rcl1.fromUnit__c = 1;  
        rcl1.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl1);
        
        cspmb__Rate_Card_Line__c rcl2 = new cspmb__Rate_Card_Line__c();
        rcl2.toUnit__c = 999;
        rcl2.fromUnit__c = 500;  
        rcl2.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl2.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl2.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl2);
        
        cspmb__Rate_Card_Line__c rcl3 = new cspmb__Rate_Card_Line__c();
        rcl3.toUnit__c = 2499;
        rcl3.fromUnit__c = 1000;  
        rcl3.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl3.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl3.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl3.cspmb__rate_value__c = 3.5;
        rateCardLineList.add(rcl3);
        
        cspmb__Rate_Card_Line__c rcl_Shared1 = new cspmb__Rate_Card_Line__c();
        rcl_Shared1.toUnit__c = 499;
        rcl_Shared1.fromUnit__c = 1;  
        rcl_Shared1.cspmb__Rate_Card__c= rateCard_shared_data1.id;
        rcl_Shared1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl_Shared1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl_Shared1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl_Shared1);
        
        cspmb__Rate_Card_Line__c rcl_Shared2 = new cspmb__Rate_Card_Line__c();
        rcl_Shared2.toUnit__c = 999;
        rcl_Shared2.fromUnit__c = 500;  
        rcl_Shared2.cspmb__Rate_Card__c= rateCard_shared_data1.id;
        rcl_Shared2.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl_Shared2.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl_Shared2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl_Shared2);
        
        cspmb__Rate_Card_Line__c rcl_Shared3 = new cspmb__Rate_Card_Line__c();
        rcl_Shared3.toUnit__c = 2499;
        rcl_Shared3.fromUnit__c = 1000;  
        rcl_Shared3.cspmb__Rate_Card__c= rateCard_shared_data1.id;
        rcl_Shared3.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl_Shared3.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl_Shared3.cspmb__rate_value__c = 3.5;
        rateCardLineList.add(rcl_Shared3);
        
        cspmb__Rate_Card_Line__c rcl_Shared_Data = new cspmb__Rate_Card_Line__c(); 
        rcl_Shared_Data.cspmb__Rate_Card__c= rateCard_shared_data2.id;
        rcl_Shared_Data.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl_Shared_Data.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl_Shared_Data.cspmb__Cap__c = 1.5;
        rateCardLineList.add(rcl_Shared_Data);
        
        List<cspmb__Price_Item_Rate_Card_Association__c> lstPriceItemRateCardAss = new List<cspmb__Price_Item_Rate_Card_Association__c>();
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
        lstPriceItemRateCardAss.add(sharedDataassociation);
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation1 = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation1.cspmb__Price_Item__c = price_item_shared_data1.id;
        sharedDataassociation1.cspmb__Rate_Card__c = rateCard_shared_data1.id;
		lstPriceItemRateCardAss.add(sharedDataassociation1); 
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation2 = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation2.cspmb__Price_Item__c = price_item_shared_data1.id;
        sharedDataassociation2.cspmb__Rate_Card__c = rateCard_shared_data2.id;
        lstPriceItemRateCardAss.add(sharedDataassociation2); 
        insert lstPriceItemRateCardAss;
        
        //Shresth(DPG - 2395,DPG - 2745) Creating data for adaptive care/Platform - Start 
        List<cspmb__Rate_Card__c> rateCardTestList = new List<cspmb__Rate_Card__c>();
        cspmb__Rate_Card__c rateCardAdaptiveCareNet = new cspmb__Rate_Card__c(
            Name = 'Adaptive Care Rate Card',
            Offer_Id__c ='DMCAT_Offer_001251',
            cspmb__Rate_Card_Code__c = 'DMCAT_Offer_001251',  
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        rateCardTestList.add(rateCardAdaptiveCareNet);
        
        cspmb__Rate_Card__c rateCardPlatformNet = new cspmb__Rate_Card__c(
            Name = 'Platform Rate Card',
            Offer_Id__c ='DMCAT_Offer_000681',
            cspmb__Rate_Card_Code__c = 'DMCAT_Offer_000681',  
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        rateCardTestList.add(rateCardPlatformNet);
        
        Insert rateCardTestList;
        
        cspmb__Rate_Card_Line__c rcl7 = new cspmb__Rate_Card_Line__c(
            name = 'Plan1',
            toUnit__c = 2000,
            fromUnit__c = 1001,  
            cspmb__Rate_Card__c= rateCardAdaptiveCareNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl7);
        
        cspmb__Rate_Card_Line__c rcl8 = new cspmb__Rate_Card_Line__c(
            name = 'Plan1',
            toUnit__c = 1,
            fromUnit__c = 1000,  
            cspmb__Rate_Card__c= rateCardAdaptiveCareNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl8);
        
        
        cspmb__Rate_Card_Line__c rcl9 = new cspmb__Rate_Card_Line__c(
            name = 'Plan2',
            toUnit__c = 1,
            fromUnit__c = 1000,  
            cspmb__Rate_Card__c= rateCardAdaptiveCareNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl9);
        
        cspmb__Rate_Card_Line__c rcl10 = new cspmb__Rate_Card_Line__c(
            name = 'Plan2',
            toUnit__c = 2000,
            fromUnit__c = 1001,  
            cspmb__Rate_Card__c= rateCardAdaptiveCareNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl10);
        
        cspmb__Rate_Card_Line__c rcl11 = new cspmb__Rate_Card_Line__c(
            name = 'Plan1',
            toUnit__c = 2000,
            fromUnit__c = 1001,  
            cspmb__Rate_Card__c= rateCardPlatformNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl11);
        
        cspmb__Rate_Card_Line__c rcl12 = new cspmb__Rate_Card_Line__c(
            name = 'Plan1',
            toUnit__c = 1000,
            fromUnit__c = 1,  
            cspmb__Rate_Card__c= rateCardPlatformNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl12);
        
        cspmb__Rate_Card_Line__c rcl13 = new cspmb__Rate_Card_Line__c(
            name = 'Plan2',
            toUnit__c = 1000,
            fromUnit__c = 1,  
            cspmb__Rate_Card__c= rateCardPlatformNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl13);
        
        cspmb__Rate_Card_Line__c rcl14 = new cspmb__Rate_Card_Line__c(
            name = 'Plan2',
            toUnit__c = 1001,
            fromUnit__c = 2000,  
            cspmb__Rate_Card__c= rateCardPlatformNet.id,
            cspmb__Effective_Start_Date__c=Date.today()-1,
            cspmb__Effective_End_Date__c=Date.today()+1,
            cspmb__rate_value__c = 1.5);
        rateCardLineList.add(rcl14);
        
        //Shresth(DPG - 2395) Creating data for adaptive care/Platform - End
        
        //Shresth(DPG-2319) Creating data for MS - start
        cspmb__Price_Item__c  userSupportCommercial = new cspmb__Price_Item__c(
            Name = 'User Support',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'User Support',
            cspmb__Product_Definition_Name__c = 'User Support',
            External_Id__c = 'DMCAT_Offer_000854_DMCAT_ProductSpecification_000940_DMCAT_RecurringCharge_000852_6411',
            Charge_Id__c='DMCAT_RecurringCharge_000852',
            BillingSpecId__c = 'BSUSG003_CB',
            Billing_Description__c = 'User support - Standard - business hours',
            Offer_Id__c = 'DMCAT_Offer_000854',
            cspmb__Type__c  = 'Commercial Product',
            cspmb__Role__c = 'Basic'
        );
        
        Insert userSupportCommercial;
        
        cspmb__Rate_Card__c rateCard_user_data = new cspmb__Rate_Card__c(
            Name = 'User Support - Standard - Bus Hrs',
            Offer_Id__c ='DMCAT_Offer_000854',
            cspmb__Rate_Card_Code__c = '7900',  
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        Insert rateCard_user_data;
        
        
        cspmb__Price_Item_Rate_Card_Association__c userDataAssociation = new cspmb__Price_Item_Rate_Card_Association__c();
        userDataAssociation.cspmb__Price_Item__c = userSupportCommercial.id;
        userDataAssociation.cspmb__Rate_Card__c = rateCard_user_data.id;
        Insert userDataAssociation;
        
        cspmb__Rate_Card_Line__c rcl15 =PricingTestDataFactory.generateRateCardLine(1,499,rateCard_user_data.id,'1');
        rcl15.cspmb__rate_value__c = 1.5;
        rcl15.name = 'plan1';
        rateCardLineList.add(rcl15);
        
        cspmb__Rate_Card_Line__c rcl16 =PricingTestDataFactory.generateRateCardLine(999,500,rateCard_user_data.id,'1');
        rcl16.cspmb__rate_value__c = 2.5;
        rcl16.name = 'plan1';
        rateCardLineList.add(rcl16);
        
        cspmb__Rate_Card_Line__c rcl17 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCard_user_data.id,'1');
        rcl17.cspmb__rate_value__c = 3.5;
        rcl17.name = 'plan1';
        rateCardLineList.add(rcl17);
        
        cspmb__Rate_Card_Line__c rcl18 =PricingTestDataFactory.generateRateCardLine(499,1,rateCard_user_data.id,'10');
        rcl18.cspmb__rate_value__c = 1.5;
        rcl18.name = 'plan2';
        rateCardLineList.add(rcl18);
        
        cspmb__Rate_Card_Line__c rcl19 =PricingTestDataFactory.generateRateCardLine(999,500,rateCard_user_data.id,'10');
        rcl19.cspmb__rate_value__c = 2.5;
        rcl19.name = 'plan2';
        rateCardLineList.add(rcl19);
        
        cspmb__Rate_Card_Line__c rcl20 =PricingTestDataFactory.generateRateCardLine(2499,1000,rateCard_user_data.id,'10');
        rcl20.cspmb__rate_value__c = 3.5;
        rcl20.name = 'plan2';
        rateCardLineList.add(rcl20);
        //Shresth(DPG-2319) Creating data for MS - END
        
        Insert rateCardLineList;
        
        
    }
    @IsTest
    public static void rateCardSharedDataTest(){
        Test.startTest();
        string jsonsios = '[ { \"name\": \"non-Telstra mobiles\", \"expectedSIO\": 0, \"currentRate\": 0, \"previousRate\": 0, \"actualSIO\": 0 } ]';
        try{
            RateMatrixForIoTController.RateCardDTOIOT result = RateMatrixForIoTController.getRateCardData('Shared Data','DMCAT_Offer_000964','',jsonsios,'');
            system.debug('result ' + result);
            System.debug('result.RateCardMap.get(50KB)--->'+result.RateCardMap);
            Test.stopTest();
            System.assert(result!=null);        
            System.assert(result.RateCardMap==null);
        }catch(exception e){

        }       
}
    /*--------------------------------------------------------------------------------------------------
# Test case for adaptive care
# DPG-2395
# Author: Shresth dixit
--------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void rateCardAdaptiveCareTest(){
        Test.startTest();
         string jsonsios = '[ { \"name\": \"non-Telstra mobiles\", \"expectedSIO\": 3, \"currentRate\": 4.45, \"previousRate\": 6, \"actualSIO\": 4,\"rateCardId\":\"Test\",\"rateCardName\":\"non-Telstra mobiles\" } ]';
       try{
        RateMatrixForIoTController.RateCardDTOIOT result = RateMatrixForIoTController.getRateCardData(NULL,'DMCAT_Offer_001251','',jsonsios,'');
        System.assert(result!=null);
        System.assert(result.RateCardMap.get('Plan1').get(0).recurringCharge!=null);
        System.assert(result.RateCardMap.get('Plan1').get(1).recurringCharge!=null);
        System.assert(result.RateCardMap.get('Plan2').get(0).recurringCharge!=null);
        System.assert(result.RateCardMap.get('Plan2').get(1).recurringCharge!=null);
    }catch(exception e){

       }       
        Test.stopTest();        
    }

    /*--------------------------------------------------------------------------------------------------
# Test case for Platform
# DPG-2745
# Author: Shresth dixit
--------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void rateCardPlatformTest(){
        Test.startTest();
         string jsonsios = '[ { \"name\": \"non-Telstra mobiles\", \"expectedSIO\": 0, \"currentRate\": 0, \"previousRate\": 0, \"actualSIO\": 0 } ]';
        try{
            RateMatrixForIoTController.RateCardDTOIOT result = RateMatrixForIoTController.getRateCardData(NULL,'DMCAT_Offer_000681','',jsonsios,'');
            System.assert(result!=null);
            System.assert(result.RateCardMap.get('Plan1').get(0).recurringCharge!=null);
            System.assert(result.RateCardMap.get('Plan1').get(1).recurringCharge!=null);
            System.assert(result.RateCardMap.get('Plan2').get(0).recurringCharge!=null);
            System.assert(result.RateCardMap.get('Plan2').get(1).recurringCharge!=null);
        }catch(exception e){

        }         
        Test.stopTest();      
    }
    /*--------------------------------------------------------------------------------------------------
# Test case for MS
# DPG-2319
# Author: Shresth dixit
--------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void rateCardMSTest(){
        RateCardSIOWrapper.wrapSIO json = new RateCardSIOWrapper.wrapSIO();
        json.name='non-telstra';
        json.expectedSIO= 3;
        json.currentRate= 3.0;
        json.previousRate = 3.0;
        json.rateCardId ='Test';
        json.rateCardName = 'test';
        json.actualSIO= 4;
        string jsonsios = '[ { \"name\": \"non-Telstra mobiles\", \"expectedSIO\": 0, \"currentRate\": 0, \"previousRate\": 0, \"actualSIO\": 0 } ]';
        Id userSupportCMPId = [SELECT id from cspmb__Price_Item__c WHERE Name = 'User Support' LIMIT 1].get(0).Id;
        Test.startTest();
        try{
            RateMatrixForIoTController.RateCardDTOIOT result = RateMatrixForIoTController.getRateCardData(NULL,'DMCAT_Offer_000854',userSupportCMPId,jsonsios,'');
            System.assert(result!=null);
            System.assert(result.RateCardMap.get('plan1').get(0).recurringCharge!=null);
            System.assert(result.RateCardMap.get('plan1').get(1).recurringCharge!=null);
            System.assert(result.RateCardMap.get('plan2').get(0).recurringCharge!=null);
            System.assert(result.RateCardMap.get('plan2').get(1).recurringCharge!=null);
        }catch(exception e){

        }        
        Test.stopTest();
    
    }


    @IsTest
    public static void getRateCard_DiscountsIoTTest(){
        csord__Solution__c solution = PricingTestDataFactory.generateSolution('IoT Connectivity');  
        insert solution;
        Test.startTest();
        string jsonsios = '[ { \"name\": \"non-Telstra mobiles\", \"expectedSIO\": 0, \"currentRate\": 0, \"previousRate\": 0, \"actualSIO\": 0 } ]';
        RateMatrixForIoTController.RateCardDTOIOTDiscounted result=new RateMatrixForIoTController.RateCardDTOIOTDiscounted();
        result.discountDTOList = new List<DiscountDTO>();
        result = RateMatrixForIoTController.getRateCard_DiscountsIoT('Shared Data','DMCAT_Offer_000964',solution.Id,'',jsonsios,'LTE','');
        system.debug('result ' + result);
        System.debug('result.RateCardMap--->'+result.RateCardMap);
        Test.stopTest();
        System.assert(result!=null);        
    }

    // // changes  by shashank - DIGI-37779
    @isTest
    public static void dmsDormancytest(){
        boolean isActive = RateMatrixForIoTController.dmsRatematrixActive();
    }
}