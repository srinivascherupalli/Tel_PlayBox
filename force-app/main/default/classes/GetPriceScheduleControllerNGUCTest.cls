/*
* @Author : Shubhi
* @Date : 20 Feb 2020
* @Desc : GetPriceScheduleControllerNGUC Test class
* @Jira : //Edge-135837
// modified by shubhi all the methods for Edge-143527 as the functin definition is changed in main class
// Added Profile, User and System.RunAs() method in all the test methods by Aman Soni as a part of EDGE-143527
No.   Developer Name        Date            Story Description 
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*/
@isTest
public class GetPriceScheduleControllerNGUCTest {
    
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
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c pINGUCDevice =PricingTestDataFactory.generateNGUCPriceItem_discount('Next Generation device','Purchase','DMCAT_RecurringCharge_000814');
        price_item_List.add(pINGUCDevice);
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        price_item_List.add(price_item_1);
        cspmb__Price_Item__c price_item2 =PricingTestDataFactory.generateNGUCPriceItem_discount('Unified Communication Device','Rental','DMCAT_RecurringCharge_000858');
        price_item_List.add(price_item2);
        insert price_item_List;
          
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level_1 = PricingTestDataFactory.generateDiscountLevelPlan('DummyForTestClass', 'Dummy', testAccount,pINGUCDevice.id,'');
        dlList.add(discount_level_1);
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('IDD callpack','DMCAT_Discount_000957',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level2);    
        cspmb__Discount_Level__c discount_levelv = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', testAccount,price_item2.id,'');
        dlList.add(discount_levelv);            
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(pINGUCDevice,null,discount_level_1);
        cspmb__Discount_Association__c DisAssoc1 = PricingTestDataFactory.generateDiscountAssociation2(pINGUCDevice,null,discount_levelv);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(null,addon,discount_level2);
        DAList.add(DisAssoc);
        DAList.add(DisAssoc1);
        DAList.add(DisAssoc2);
        insert DAList;
        
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');   DIGI-5648
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV); 
        csord__Solution__c solution1 = PricingTestDataFactory.generateSolution('Enterprise Mobility (2)');  
        solutionList.add(solution1);
        // csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution2');   DIGI-5648
        csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution2');  

        solutionList.add(solution2);
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
        attList.add(att2);
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(pINGUCDevice.id));
        attList.add(attV);
        Attachment att3 = PricingTestDataFactory.generateSolutionAttachment(solution2.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(price_item2.id));
        attList.add(att3);
        insert attList;
    }
    
    @isTest //Edge-143527
    public static void TestonLoadApplicableDiscounts(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        account acc=[Select id from account limit 1];
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        String solutionName='Unified Communication Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);}  
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
     
    @isTest //Edge-143527
    public static void TestonLoadAlreadyTriggered(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        String solutionName='Unified Communication Device';
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        System.runAs(sales){
         Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,acc.id,sol.id,'false', solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('Already triggered',priceSchedule.DiscountApplicableStatus);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End        
    }
    @isTest
    public static void TestonLoadNoApplicableDiscounts(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution2' limit 1]; DIGI-5648
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution2' limit 1];
        Account acc=[Select id from account limit 1];
        String solutionName='Unified Communication Device';
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true',solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('No discount applicable',priceSchedule.DiscountApplicableStatus);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End 
    }
    
    
    @isTest //Edge-143527
    public static void TestonLoadNegative(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        //csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1];
        //account acc=[Select id from account limit 1];
        String solutionName='Unified Communication Device';
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        //Account acc[Select id from Account where name='test' limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;//GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,'','','true', solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);}
        //System.assert();
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
        
    } 
}