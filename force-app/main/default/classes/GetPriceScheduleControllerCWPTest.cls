/*
* @Author : Ila
* @Date : 08 Apr 2020
* @Desc : GetPriceScheduleControllerCWP 
* @Jira : DPG-1513 
*/

@isTest
public class GetPriceScheduleControllerCWPTest {
     @TestSetup static void CreateData()
    {
        
         Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;
        // Create test Opportunity
        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;
        // Create test Basket
        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000303_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_6707');
        price_item_List.add(price_item);
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000303_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_6708');
        price_item_List.add(price_item_1);
        insert price_item_List;
          
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
    
       List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        csord__Solution__c solution = PricingTestDataFactory.generateSolution('Connected Workplace Solution');  
        solutionList.add(solution); 
        csord__Solution__c solution1 = PricingTestDataFactory.generateSolution('Connected Workplace Solution');  
        solutionList.add(solution1); 
        insert solutionList;   
        
	List<Attachment> attList =new List<Attachment>();
        Attachment att1=PricingTestDataFactory.generateSolutionAttachment(solution.id,SolutionAttachmentTestDataFactory.generateSolutionStringCWP(price_item.ID,addon.id));
        attList.add(att1);
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionStringCWP(price_item_1.ID,addon.id));
        attList.add(att2);
        insert attList;
        
    }
	@isTest
    public static void TestonLoadPositive(){   
        csord__Solution__c sol=[select id from csord__Solution__c where name='Connected Workplace Solution' limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        String solutionName='CWP Mobile Subscription';
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;       
        System.runAs(sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            Test.startTest();
            GetPriceScheduleControllerCWP priceSchedule=new GetPriceScheduleControllerCWP();
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
            System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }
      @isTest
    public static void TestonLoadNegative(){ 
         Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        System.runAs(sales){
            Test.startTest();
            GetPriceScheduleControllerCWP priceSchedule=new GetPriceScheduleControllerCWP();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;//GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,'','','true', '',testBasket.Basket_Number__c,'123456789');
            System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }

	@isTest
    public static void TestonLoadNegativeDiscountCheck(){
        csord__Solution__c sol=[select id from csord__Solution__c where name='Connected Workplace Solution' limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        String solutionName='CWP Mobile Subscription';
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;       
        System.runAs(sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            Test.startTest();
            GetPriceScheduleControllerCWP priceSchedule=new GetPriceScheduleControllerCWP();
			 Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'false', solutionName,testBasket.Basket_Number__c,'123456789');        
            System.assertEquals('Already triggered',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }
	@isTest
    public static void TestonLoadNegativeAttMapOfMap(){ 
        csord__Solution__c sol=[select id from csord__Solution__c where name='Connected Workplace Solution' limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        Account acc=[Select id from Account limit 1];
        String solutionName='CWP Mobile Subscription';
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;       
        System.runAs(sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            Test.startTest();
            GetPriceScheduleControllerCWP priceSchedule=new GetPriceScheduleControllerCWP();
            Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap;
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
            System.assertEquals('No discount applicable',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
    }

}