/*******************************************************************
@Author : Gnana
@Description : Test Class for GetPriceScheduleControllerNGUCVoice
@Release : Sprint 20.03 - EDGE - 133963
@Created Date :   06-Feb-2020
// modified by shubhi all the methods for Edge-143527 as the functin definition is changed in main class
// Added Profile, User and System.RunAs() method in all the test methods by Aman Soni as a part of EDGE-143527
// 3.       Shubhi              23/04/2020      Edge-120919
No.   Developer Name        Date            Story Description 
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*******************************************************************/
@isTest
public class GetPriceScheduleControllerNGUCVoiceTest {
    
    //Method for test data Setup
    @TestSetup static void CreateData(){
        
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        //POrice item
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c price_item_V = PricingTestDataFactory.generateNGUCPriceItem_Voice('Next Generation Voice','DMCAT_RecurringCharge_000814');
        price_item_List.add(price_item_V);
        insert price_item_List;
        
        // Create test Discount Level
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', null,'rental','');
        discount_level2.Is_Delegated__c=false;
        dlList.add(discount_level2);    
        insert dlList;
        
        // Create test Solution
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');  DIGI-5648 
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV);        
        insert solutionList;    
                
        // Create json solution attachment
        List<Attachment> attList =new List<Attachment>();
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCVoiceSolutionString(price_item_V.id));
        attList.add(attV);
        insert attList;
        
        //added for edge-121376
        ///RateCard
         List<cspmb__Rate_Card__c> rateCardList=new List<cspmb__Rate_Card__c>();
        cspmb__Rate_Card__c rc=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000814');
        rateCardList.add(rc);
        cspmb__Rate_Card__c rc1=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000810');
        rateCardList.add(rc1);
        cspmb__Rate_Card__c rc2=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000811');
        rateCardList.add(rc2);
        cspmb__Rate_Card__c rc3=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000813');
        rateCardList.add(rc3);
        cspmb__Rate_Card__c rc4=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000816');
        rateCardList.add(rc4);
        cspmb__Rate_Card__c rc5=PricingTestDataFactory.generateRateCard('DMCAT_Offer_000618','DMCAT_RecurringCharge_000808');
        rateCardList.add(rc5);
        insert rateCardList;
        //rateCardLine
        List<cspmb__Rate_Card_Line__c> rateCardLineList=new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl=PricingTestDataFactory.generateRateCardLine(1,10,rc.id,'Standard');
        rateCardLineList.add(rcl);
        cspmb__Rate_Card_Line__c rcl1=PricingTestDataFactory.generateRateCardLine(11,20,rc.id,'Standard');
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2=PricingTestDataFactory.generateRateCardLine(1,10,rc2.id,'Standard');
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3=PricingTestDataFactory.generateRateCardLine(1,10,rc3.id,'Standard');
        rateCardLineList.add(rcl3);
        cspmb__Rate_Card_Line__c rcl4=PricingTestDataFactory.generateRateCardLine(1,10,rc4.id,'Standard');
        rateCardLineList.add(rcl4);
        cspmb__Rate_Card_Line__c rcl5=PricingTestDataFactory.generateRateCardLine(1,10,rc5.id,'Standard');
        rateCardLineList.add(rcl5);
        insert rateCardLineList;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;       
       // edge-121376 end
  
    }
    
    // Test method to load new pricing
    @isTest
    public static void TestonLoadNewPricing(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        GetPriceScheduleControllerNGUCVoice priceSchedule=new GetPriceScheduleControllerNGUCVoice();
        String solutionName=System.Label.BusinessCalling;//Edge-120919
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End  
    }
    
    // Test method to load already triggered pricing 
    @isTest
    public static void TestonLoadAlreadyTriggeredPricing(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        GetPriceScheduleControllerNGUCVoice priceSchedule=new GetPriceScheduleControllerNGUCVoice();
        String solutionName=System.Label.BusinessCalling;////Edge-120919
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,acc.id,sol.id,'false', solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('Already triggered',priceSchedule.DiscountApplicableStatus);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End    
    }
    
    //Test method for negative scenario
    @isTest
    public static void TestonLoadNegative(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        //csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1];
        GetPriceScheduleControllerNGUCVoice priceSchedule=new GetPriceScheduleControllerNGUCVoice();
        String solutionName=System.Label.BusinessCalling;//Edge-120919
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        //Account acc[Select id from Account where name='test' limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;//GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,'','','true', solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
    
 
}