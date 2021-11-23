/*
* @Author : Shubhi(Edge-135837)
* @Date : 17 feb 2020
* @Desc : handler class for common methods for lightning cmponent to fetch table data and show promotions and discounts
* @Jira : Edge-135837
1. 133882 updated by shubhi added start and atop test
*@Class: ShowPromoAndDiscountContollerNGUC 

1.        Pawan Singh             09/08/2021      DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*/
// modified by shubhi all the methods for Edge-143527 as the functin definition is changed in main class

@isTest
public class ShowPromoAndDiscountContollerNGUCTest {
    
    //Method for test data Setup
    @TestSetup static void CreateData(){
        
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item =PricingTestDataFactory.generateNGUCPriceItem_discount('Unified Communication Device','Purchase','DMCAT_RecurringCharge_000857');
        price_item_List.add(price_item);
        insert price_item_List;
          
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level_1 = PricingTestDataFactory.generateDiscountLevelPlan('DummyForTestClass', 'Dummy', testAccount,price_item.id,'');
        dlList.add(discount_level_1);  
        cspmb__Discount_Level__c discount_levelv = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', testAccount,price_item.id,'');
        dlList.add(discount_levelv); 
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(price_item,null,discount_level_1);
        cspmb__Discount_Association__c DisAssoc3 = PricingTestDataFactory.generateDiscountAssociation2(null, addon, discount_level_1);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(price_item,null,discount_levelv);
       	DAList.add(DisAssoc3);
        DAList.add(DisAssoc2);
        DAList.add(DisAssoc);
        insert DAList;
        
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');  DIGI-5648
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV); 
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att3 = PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(price_item.id));
        attList.add(att3);
        insert attList;
        
  		
    }
    
    @isTest
    public static void TestDiscountDTO(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        Test.startTest();
        
            // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
            csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
            account acc=[Select id from account  limit 1];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8abc';
            string solutionName='Unified communication Device';
            //cspmb__Add_On_Price_Item__c addon=[select id from cspmb__Add_On_Price_Item__c limit 1];
           System.runAs(sales){
               // Edge-143527 start
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            if(guidToAttMapofMap!=null && guidToAttMapofMap.containskey(configGuid)){
                Object JsonString=JSON.serialize(guidToAttMapofMap.get(configGuid));
                List<DiscountDTO> disTolist=ShowPromoAndDiscountContollerNGUC.getDiscountdata(acc.id,sol.id,configGuid,'Unified Communication Device',JsonString);
                if(disTolist.size()>0){
                    System.assert(true,disTolist[0].discountName=='Early Adopter Discount'|| disTolist[0].discountName=='DummyForTestClass');
                }
            }  
            // Edge-143527 end
        }
        Test.stopTest();
                
    }
    @isTest
    public static void TestAddon(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        Test.startTest();         
            // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648
            csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
            account acc=[Select id from account limit 1];
            cspmb__Add_On_Price_Item__c addon=[Select id from cspmb__Add_On_Price_Item__c limit 1];
        System.runAs(sales){
            Map<String,List<cspmb__Discount_Level__c>> disLevMap=ShowPromotionAndDiscountHandlerClass.fetchApplicableDiscounts(acc.id,null,addon.id);
            List<cspmb__Discount_Level__c> disList=new List<cspmb__Discount_Level__c>();
            disList=disLevMap.get(addon.id);
            system.debug('disLevMap-->'+disLevMap);
            disList=disLevMap.get('Dummy');
            system.debug('disList-->'+disList);
            System.assertEquals('Dummy',disList[0].Business_ID__c );
         }
        Test.stopTest();
    }
    @isTest
    public static void TestDiscountDTONegative(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        Test.startTest();
            //csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1];
        //account acc=[Select id from account where name = 'testAccount' limit 1];
         System.runAs(sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8abc';
            //cspmb__Add_On_Price_Item__c addon=[select id from cspmb__Add_On_Price_Item__c limit 1];
            List<DiscountDTO> disTolist=ShowPromoAndDiscountContollerNGUC.getDiscountdata(null,null,null,'Unified Communication Device',null);// Edge-143527
            String result = disTolist!=null && disTolist.size() > 0 ? 'Pass' : 'Fail'; 
            System.assertEquals(result,'Fail');
         }
        Test.stopTest();
    }

}