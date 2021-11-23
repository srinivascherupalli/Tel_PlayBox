/*
* @Author : Gnana
* @Date : 30 Apr 2020
* @Desc : GetPriceScheduleControllerRedemption Test class
* @Jira : Edge-140968
Shubhi V 			28-June-2020    Edge-149830 device care pricing
*/

@isTest
public class GetPriceScheduleControllerRedemptionTest {

    //Method for test data Setup
    @TestSetup static void CreateData(){
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;

        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;

        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>(); 
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobileDevicePriceItem('DMCAT_Offer_000783_DMCAT_ProductSpecification_000423_DMCAT_NonRecurringCharge_000511_2151');
        price_item_List.add(price_item_1);
        //Edge-149830
        cspmb__Price_Item__c price_item_2 = PricingTestDataFactory.generatePriceItem('NextGenEM');
        price_item_List.add(price_item_2);
        insert price_item_List;
       
        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Device Outright Purchase Solution');  
        solutionList.add(solutionV);
        //Edge-149830
        csord__Solution__c solutionV2 = PricingTestDataFactory.generateSolution('Next Generation Enterprise Mobility');  
        solutionList.add(solutionV2);
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateDOPSolutionString(price_item_1.ID));
        attList.add(att2);
        insert attList;
    }
    
    @isTest
    public static void TestonLoadApplicableDiscounts(){
        Test.startTest();
        User sales = [select id from user where username='salesuser@testsales.com' limit 1];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Device Outright Purchase Solution' limit 1];
        account acc=[Select id from account limit 1];
        GetPriceScheduleControllerRedemption priceSchedule=new GetPriceScheduleControllerRedemption();
        String solutionName='Mobile Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);}  
        Test.stopTest();
    }
	
	// added for Edge-149830 --- next gen enterprise
    @isTest
    public static void TestonLoadApplicableDiscountsNextGenEm(){
        Test.startTest();
        User sales = [select id from user where username='salesuser@testsales.com' limit 1];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Next Generation Enterprise Mobility' limit 1];
        account acc=[Select id from account limit 1];
        GetPriceScheduleControllerRedemption priceSchedule=new GetPriceScheduleControllerRedemption();
        String solutionName='Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
            String mapJsonString=PricingTestDataFactory.getNextGenEMSolutionJson();
          	Map<String,Map<String,SolutionDTO.Attributes>>  guidToAttmapOfMap = (Map<String,Map<String,SolutionDTO.Attributes>>)JSON.deserialize(String.valueOf(mapJsonString), Map<String,Map<String,SolutionDTO.Attributes>>.class);
        	priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        	System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);
        }  
        Test.stopTest();
    }
    
    @isTest
    public static void TestonLoadApplicableDiscountsNegative(){
        Test.startTest();
        User sales = [select id from user where username='salesuser@testsales.com' limit 1];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Device Outright Purchase Solution' limit 1];
        account acc=[Select id from account limit 1];
        GetPriceScheduleControllerRedemption priceSchedule=new GetPriceScheduleControllerRedemption();
        String solutionName='Mobile Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap= new Map<String,Map<String,SolutionDTO.Attributes>>();
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);}  
        Test.stopTest();
    }
    
}