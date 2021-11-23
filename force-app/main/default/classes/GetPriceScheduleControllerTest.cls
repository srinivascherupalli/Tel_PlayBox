/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : GetPriceScheduleController  
* @Jira : Edge-127073
// modified by shubhi all the methods for Edge-143527 as the functin definition is changed in main class
* @Jira : EDGE-143527 Added by Aman Soni
*/
@isTest
public class GetPriceScheduleControllerTest {
    @TestSetup static void CreateData()
    {
        //Edge-143527 start
         Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        
        //Added by Aman Soni as a part of EDGE-143527 || Start   
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];//Added by Aman Soni as a part of EDGE-143527
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        //Added by Aman Soni as a part of EDGE-143527 || End
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        price_item_List.add(price_item);
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176');
        price_item_List.add(price_item_1);
        insert price_item_List;
          
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level_1 = PricingTestDataFactory.generateDiscountLevelPlan('Mobile Workspace Discount 1', 'DMCAT_Discount_000944', testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level_1);
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('IDD callpack','DMCAT_Discount_000961',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level2);    
        cspmb__Discount_Level__c discount_levelv = PricingTestDataFactory.generateDiscountLevelPlan('National BYO Discount', 'DMCAT_Discount_000899', testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_levelv);            
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(price_item,null,discount_level_1);
        cspmb__Discount_Association__c DisAssoc1 = PricingTestDataFactory.generateDiscountAssociation2(price_item_1,null,discount_levelv);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(null,addon,discount_level2);
        DAList.add(DisAssoc);
        DAList.add(DisAssoc1);
        DAList.add(DisAssoc2);
        insert DAList;
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        csord__Solution__c solution = PricingTestDataFactory.generateSolution('Enterprise Mobility (1)');  
        solutionList.add(solution); 
        csord__Solution__c solution1 = PricingTestDataFactory.generateSolution('Enterprise Mobility (2)');  
        solutionList.add(solution1);
        csord__Solution__c solution2 = PricingTestDataFactory.generateSolution('Enterprise Mobility (3)');  
        solutionList.add(solution2);
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item.ID,addon.id));
        attList.add(att2);
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.id,addon.id));
        attList.add(attV);
        Attachment att3 = PricingTestDataFactory.generateSolutionAttachment(solution2.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.id,addon.id));
        attList.add(att3);
        insert attList;
        
        //Edge-143527 end
           
    }
     @isTest
    public static void TestonLoadPositive(){ //Edge-143527 updated      
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        String solutionName='Mobile Subscription';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; //Added by Aman Soni as a part of EDGE-143527      
        System.runAs(sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
            System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }
      @isTest
    public static void TestonLoadNegative(){ //Edge-143527 updated
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];//Added by Aman Soni as a part of EDGE-143527      
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        System.runAs(sales){
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;//GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,'','','true', '',testBasket.Basket_Number__c,'123456789');
            System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }
    

}