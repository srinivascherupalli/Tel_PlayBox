/*
* @Author  : Vivek
* @Date   : 03rd Jan 2021
* @Desc  : Test Class For RetrieveRateCard class
* @Jira : EDGE-189344 
*/
@isTest
public with sharing class Model_RateCardLineItemTest {
        @TestSetup static void testdata(){
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        upsert testBasket;
        List <cspmb__Price_Item__c> cpToInsertList = new List<cspmb__Price_Item__c>();

        cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
            Name = 'Telstra Colabration',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'Telstra Colabration Data',
            cspmb__Product_Definition_Name__c = 'Telstra Colabration Solutions',
            Commercial_Product_Code__c = 'Telstra Colabration Shared Data',
            External_Id__c = 'dmcat_112',
            Charge_Id__c='DMCAT_RecurringCharge_000814',
            Package_Name__c = 'IoT Solution',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_000618',
            Plan__c = 'Premium',
            mode__c = 'Individual Line'
        );
        cpToInsertList.add(price_item_shared_data);
        //insert price_item_shared_data;
        
        cspmb__Price_Item__c price_item_right_plan = new cspmb__Price_Item__c(
            Name = 'IoT Right Plan 50KB',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'IoT Right Plan',
            Commercial_Product_Code__c = 'IoT Right Plan',
            cspmb__Product_Definition_Name__c = 'IoT Solutions',
            External_Id__c = 'dmcat_115',
            Charge_Id__c='DMCAT_RecurringCharge_000815',
            Package_Name__c = 'IoT Solution',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_000964',
            Plan__c = '50 KB'
        );
        cpToInsertList.add(price_item_right_plan);

        insert cpToInsertList;
        //insert price_item_right_plan;
        
        List<cspmb__Rate_Card__c> rateCardList = new List<cspmb__Rate_Card__c>();

        cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
        rateCard_shared_data.Name = 'IoT Shared Data 50KB';
        rateCard_shared_data.Offer_Id__c ='DMCAT_Offer_000964';
        rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';  
        rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data.cspmb__Is_Active__c = true;
        rateCardList.add(rateCard_shared_data);
       // insert  rateCard_shared_data;
        
        cspmb__Rate_Card__c rateCard_Right_data = new cspmb__Rate_Card__c();
        rateCard_Right_data.Name = 'IoT Right Plan 50KB';
        rateCard_Right_data.Offer_Id__c ='DMCAT_Offer_000964';
        rateCard_Right_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000815';  
        rateCard_Right_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_Right_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_Right_data.cspmb__Is_Active__c = true;
        rateCardList.add(rateCard_Right_data);
       // insert  rateCard_Right_data;
        insert rateCardList;
        
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
        
        cspmb__Rate_Card_Line__c rcl4 = new cspmb__Rate_Card_Line__c();
        rcl4.toUnit__c = 499;
        rcl4.fromUnit__c = 1;  
        rcl4.cspmb__Rate_Card__c= rateCard_Right_data.id;
        rcl4.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl4.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl4.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl4);
        
        cspmb__Rate_Card_Line__c rcl5 = new cspmb__Rate_Card_Line__c();
        rcl5.toUnit__c = 999;
        rcl5.fromUnit__c = 500;  
        rcl5.cspmb__Rate_Card__c= rateCard_Right_data.id;
        rcl5.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl5.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl5.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl5);
        
        cspmb__Rate_Card_Line__c rcl6 = new cspmb__Rate_Card_Line__c();
        rcl6.toUnit__c = 2499;
        rcl6.fromUnit__c = 1000;  
        rcl6.cspmb__Rate_Card__c= rateCard_Right_data.id;
        rcl6.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl6.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl6.cspmb__rate_value__c = 3.5;
        rateCardLineList.add(rcl6);
        
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
        insert sharedDataassociation;
        
        cspmb__Price_Item_Rate_Card_Association__c rightPlanassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        rightPlanassociation.cspmb__Price_Item__c = price_item_right_plan.id;
        rightPlanassociation.cspmb__Rate_Card__c = rateCard_Right_data.id;
        insert rightPlanassociation;
        
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
            Offer_Id__c = 'DMCAT_Offer_000854'
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
    public static void test_getLineItemsQuery(){
       String qury =  Model_RateCardLineItem.getRelatedLines( new Set<String>() , new List<String>());
       System.assertEquals( false, String.isBlank(qury) , 'Query should have been formed correctly' );
    }

     @IsTest
    public static void test_getLineItemsQuery_1(){
       List<cspmb__Rate_Card__c> rateCardList = [SELECT Id , cspmb__Rate_Card_Code__c from cspmb__Rate_Card__c limit 5 ];
       Set<String> rateCardIds = new Set<String>();
       for(cspmb__Rate_Card__c st : rateCardList ) {
           rateCardIds.add(st.Id);
       }
       String qury =  Model_RateCardLineItem.getRelatedLines(  rateCardIds , new List<String>());
       System.assertEquals( false, String.isBlank(qury) , 'Query should have been formed correctly' );
    }


    @IsTest
    public static void test_getLineItemsQuery_2(){
       List<cspmb__Rate_Card__c> rateCardList = [SELECT Id , cspmb__Rate_Card_Code__c from cspmb__Rate_Card__c limit 5 ];
        List<String> rateCardIdscode = new List<String>();
       for(cspmb__Rate_Card__c st : rateCardList ) {
           rateCardIdscode.add(st.cspmb__Rate_Card_Code__c);
       }
       String qury =  Model_RateCardLineItem.getRelatedLines( new Set<String>() ,rateCardIdscode );
       System.assertEquals( false, String.isBlank(qury) , 'Query should have been formed correctly' );
    }


     @IsTest
    public static void test_getLineItemsQuery_Negative(){
       List<cspmb__Rate_Card__c> rateCardList = [SELECT Id , cspmb__Rate_Card_Code__c from cspmb__Rate_Card__c limit 5 ];
        List<String> rateCardIdscode = new List<String>();
       for(cspmb__Rate_Card__c st : rateCardList ) {
           rateCardIdscode.add(st.cspmb__Rate_Card_Code__c);
       }
       String qury =  Model_RateCardLineItem.getRelatedLines( new Set<String>() , new List<String>() );
       System.assertNotEquals( true, String.isBlank(qury) , 'With No attribute being passed, Standard query will be returned' );
    }
}