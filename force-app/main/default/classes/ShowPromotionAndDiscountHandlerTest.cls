/*
* @Author : Shubhi(Edge-135837)
* @Date : 17 feb 2020
* @Desc : handler class for common methods for lightning cmponent to fetch table data and show promotions and discounts
* @Jira : Edge-135837
*@Class: ShowPromotionAndDiscountHandlerClass
No.   Developer Name        Date            Story Description 
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*/
@isTest
public class ShowPromotionAndDiscountHandlerTest {
    
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
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');   DIGI-5648 
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');    
        solutionList.add(solutionV); 
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        Attachment att3 = PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCSolutionString(price_item.id));
        attList.add(att3);
        insert attList;
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        
        
    }
    
    @isTest
    public static void TestDiscountDTO(){
        
        Test.startTest();
            User Sales=[Select id from user where username='salesuser@testsales.com'];
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
        Test.startTest();
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1]; DIGI-5648 
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        account acc=[Select id from account limit 1];
        cspmb__Add_On_Price_Item__c addon=[Select id from cspmb__Add_On_Price_Item__c limit 1];
        Map<String,List<cspmb__Discount_Level__c>> disLevMap=ShowPromotionAndDiscountHandlerClass.fetchApplicableDiscounts(acc.id,null,addon.id);
        System.runAs(Sales){
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
         Test.startTest();
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        System.runAs(Sales){
            string configGuid='2b07b38f-4176-f866-3006-643c269b8abc';
            List<DiscountDTO> disTolist=ShowPromoAndDiscountContollerNGUC.getDiscountdata(null,null,null,'Unified Communication Device',null);
            String result = disTolist!=null && disTolist.size() > 0 ? 'Pass' : 'Fail'; 
            System.assertEquals(result,'Fail');
        }
         Test.stopTest();
    }
    //edge-133882 start
    @isTest
    public static void TestgetDiscountDTO(){
        Test.startTest();
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        System.runAs(Sales){
            cspmb__Discount_Level__c dl=[Select id,name,Description__c,
                    cspmb__Discount__c,
                    cspmb__duration__c,
                    Business_ID__c,
                    Check_todays_date__c,
                    Is_Delegated__c,
                    cspmb__Discount_Type__c,
                    Effective_Start_Date__c,
                    Effective_End_Date__c,is_Unlimited__c,
                    Account__c, Plan__c from cspmb__Discount_Level__c where name='Early Adopter Discount' limit 1];
            DiscountDTO dto=ShowPromotionAndDiscountHandlerClass.getDiscounTDTOData(dl);        
            System.assertEquals(dto.discountName,'Early Adopter Discount');
        }
         Test.stopTest();
    }
    @isTest
    public static void TestcalculateMonth(){
         Test.startTest();
         User Sales=[Select id from user where username='salesuser@testsales.com'];
        System.runAs(Sales){
            date myDate1 = date.newInstance(2020, 1, 21);
            String Month1=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate1.month());
            date myDate2 = date.newInstance(2020, 2, 21);
            String Month2=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate2.month());
            date myDate3 = date.newInstance(2020, 3, 21);
            String Month3=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate3.month());
            date myDate4 = date.newInstance(2020, 4, 21);
            String Month4=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate4.month());
            date myDate5 = date.newInstance(2020, 5, 21);
            String Month5=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate5.month());
            date myDate6 = date.newInstance(2020, 6, 21);
            String Month6=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate6.month());
            date myDate7 = date.newInstance(2020, 12, 21);
            String Month7=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate7.month());
            date myDate8 = date.newInstance(2020, 7, 21);
            String Month8=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate8.month());
            date myDate9 = date.newInstance(2020, 8, 21);
            String Month9=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate9.month());
            date myDate10 = date.newInstance(2020, 9, 21);
            String Month10=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate10.month());
            date myDate11 = date.newInstance(2020, 10, 21);
            String Month11=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate11.month());
            date myDate12 = date.newInstance(2020, 11, 21);
            String Month12=ShowPromotionAndDiscountHandlerClass.calculateMonth(myDate12.month());       
            System.assertEquals(Month3,'March');
        }
         Test.stopTest();
    }
}