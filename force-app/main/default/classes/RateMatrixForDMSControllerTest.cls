/*
* @Author : Nikhil Sharma   
* @Date   : 08 Aug 2021
* @Desc   : RateMatrixForDMSController Rate Card for DMS
* @Jira   : DIGI-603  
* @testclass : RateMatrixForDMSControllerTest
*/
@IsTest
public class RateMatrixForDMSControllerTest {
    @TestSetup static void testdata(){
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        upsert testBasket;
        
        cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
            Name = 'MPC Critical VM (1 to 99999)',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'DMS Product Data',
            cspmb__Product_Definition_Name__c = 'DMS Product',
            Commercial_Product_Code__c = 'DMS Product Data',
            External_Id__c = 'dmcat_112',
            Charge_Id__c='DMCAT_RecurringCharge_001545',
            Package_Name__c = 'DMS Product Data',
            BillingSpecId__c = 'BSOTC005_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_001540',
            Plan__c = '1 to 99999',
            cspmb__Role__c='Master',
            cspmb__Type__c='Package'

        );
        
        insert price_item_shared_data;
        
        List<cspmb__Rate_Card__c> lstRateCards = new List<cspmb__Rate_Card__c>();
        
        cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
        rateCard_shared_data.Name = 'MPC Critical VM';
        rateCard_shared_data.RateCard_Bill_Description__c = 'MPC Non Critical SQL PaaS';
        rateCard_shared_data.Offer_Id__c ='DMCAT_Offer_001540';
        rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_001545';  
        rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data);
        
        cspmb__Rate_Card__c rateCard_shared_data1 = new cspmb__Rate_Card__c();
        rateCard_shared_data1.Name = 'MPC Non Critical VM';
        rateCard_shared_data1.RateCard_Bill_Description__c = 'MPC Non Critical SQL PaaS';
        rateCard_shared_data1.Offer_Id__c ='DMCAT_Offer_001540';
        rateCard_shared_data1.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_001545';  
        rateCard_shared_data1.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data1.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data1.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data1);
        
        cspmb__Rate_Card__c rateCard_shared_data2 = new cspmb__Rate_Card__c();
        rateCard_shared_data2.Name = 'MPC Critical SQL PaaS';
        rateCard_shared_data2.RateCard_Bill_Description__c = 'MPC Non Critical SQL PaaS';
        rateCard_shared_data2.Offer_Id__c ='DMCAT_Offer_001540';
        rateCard_shared_data2.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_001545';  
        rateCard_shared_data2.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data2.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data2.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data2);
        
        cspmb__Rate_Card__c rateCard_shared_data3 = new cspmb__Rate_Card__c();
        rateCard_shared_data3.Name = 'MPC Non Critical SQL PaaS';
        rateCard_shared_data3.RateCard_Bill_Description__c = 'MPC Non Critical SQL PaaS';
        rateCard_shared_data3.Offer_Id__c ='DMCAT_Offer_001540';
        rateCard_shared_data3.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_001545';  
        rateCard_shared_data3.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data3.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data3.cspmb__Is_Active__c = true;
        lstRateCards.add(rateCard_shared_data3);
        insert  lstRateCards;
        
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        
        cspmb__Rate_Card_Line__c rcl1 = new cspmb__Rate_Card_Line__c();
        rcl1.toUnit__c = 99999;
        rcl1.fromUnit__c = 1;  
        rcl1.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl1.cspmb__rate_value__c = 4.90;
        rateCardLineList.add(rcl1);
        
        
        cspmb__Rate_Card_Line__c rcl2 = new cspmb__Rate_Card_Line__c();
        rcl2.toUnit__c = 99999;
        rcl2.fromUnit__c = 1;  
        rcl2.cspmb__Rate_Card__c= rateCard_shared_data1.id;
        rcl2.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl2.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl2.cspmb__rate_value__c = 3.90;
        rateCardLineList.add(rcl2);
        
        cspmb__Rate_Card_Line__c rcl3 = new cspmb__Rate_Card_Line__c();
        rcl3.toUnit__c = 99999;
        rcl3.fromUnit__c = 1;  
        rcl3.cspmb__Rate_Card__c= rateCard_shared_data2.id;
        rcl3.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl3.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl3.cspmb__rate_value__c = 7.60;
        rateCardLineList.add(rcl3);
        
        cspmb__Rate_Card_Line__c rcl_Shared1 = new cspmb__Rate_Card_Line__c();
        rcl_Shared1.toUnit__c = 99999;
        rcl_Shared1.fromUnit__c = 1;  
        rcl_Shared1.cspmb__Rate_Card__c= rateCard_shared_data3.id;
        rcl_Shared1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl_Shared1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl_Shared1.cspmb__rate_value__c = 6.70;
        rateCardLineList.add(rcl_Shared1);

        RateMatrixForDMSController.ChargeRateCardDTODMS charObj = new RateMatrixForDMSController.ChargeRateCardDTODMS();
        charObj.rateGroupIdentifier = 'test rate card ';
        charObj.rateValueInclGST   = 3;
        
        List<cspmb__Price_Item_Rate_Card_Association__c> lstPriceItemRateCardAss = new List<cspmb__Price_Item_Rate_Card_Association__c>();
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
        lstPriceItemRateCardAss.add(sharedDataassociation);
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation1 = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation1.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation1.cspmb__Rate_Card__c = rateCard_shared_data1.id;
        lstPriceItemRateCardAss.add(sharedDataassociation1); 
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation2 = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation2.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation2.cspmb__Rate_Card__c = rateCard_shared_data2.id;
        lstPriceItemRateCardAss.add(sharedDataassociation2); 
        insert lstPriceItemRateCardAss;
        Insert rateCardLineList;
        
        
    }
    @IsTest
    public static void rateCardDataTest(){
        Test.startTest(); 
        // RateCardSIOWrapper.wrapSIO
        List<RateCardSIOWrapper.wrapSIO> listwrapSIO = new List<RateCardSIOWrapper.wrapSIO>();
        RateCardSIOWrapper.wrapSIO wrapObj = new RateCardSIOWrapper.wrapSIO(); 
        wrapObj.name = 'test name' ;
        wrapObj.expectedSIO = 4 ;
        wrapObj.currentRate = 3 ;
        wrapObj.previousRate = 2 ;
        wrapObj.actualSIO = 4 ;
        wrapObj.rateCardId = 'test Id' ;
        wrapObj.rateCardName = '' ;
        //wrapObj.rateGroupIdentifier = '' ;
        wrapObj.chargeFrequency = 'daily' ;
        listwrapSIO.add(wrapObj);
        String str = JSON.serialize(listwrapSIO); 

        RateMatrixForDMSController.RateCardDTODMS result = RateMatrixForIoTController.retrieveConsumptionRateCards('DMCAT_Offer_001540',str);
        System.assert(result!=null);
        System.assert(result.RateCardMap.get('MPC Non Critical SQL PaaS').get(0).recurringCharge!=null);
        System.assertequals(0,result.RateCardMap.get('MPC Non Critical SQL PaaS').get(0).expectedSIO);
        Test.stopTest();
    }
    
    @IsTest
    public static void testSolutionType(){
        Test.startTest();
        String solutionType  = RateMatrixForIoTController.getSolutionType('DMCAT_Offer_001540');
        System.assert(String.isNotBlank(solutionType));
        RateMatrixForDMSController.logException('getRateCardData','','123', 'Error', 'DMS failed.','RateMatrixForDMSController');
        List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
        System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list' );
        Test.stopTest();
    }
}