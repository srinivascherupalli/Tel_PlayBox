/*
* @Author : Shubhi
* @Date : 20 Feb 2020
* @Desc : GetPriceSchedulevirtualClassTest class
* @Jira : //Edge-135837
// modified by shubhi all the methods for Edge-143527 as the functin definition is changed in main class
// Added Profile, User and System.RunAs() method in all the test methods by Aman Soni as a part of EDGE-143527
No.   Developer Name        Date            Story Description 
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*/
@isTest
public class GetPriceSchedulevirtualClassTest {
    
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
        // csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');  DIGI-5648 
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
    
    @isTest
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
        // csord__Solution__c sol=[select id from csord__Solution__c where name='Telstra Collaboration Solution' limit 1];
        csord__Solution__c sol=[select id from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1];
        account acc=[Select id from account limit 1];
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        String solutionName='Unified Communication Device';
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales)
        {
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=GetPriceSchedulevirtualClass.getguidToAttMapofMap(sol.id,solutionName);
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', solutionName,testBasket.Basket_Number__c,'123456789');        
        System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus);
        }  
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End        
    }
     
    @isTest
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
        System.assertEquals('Already triggered',priceSchedule.DiscountApplicableStatus);
        }
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
        System.assertEquals('No discount applicable',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
    
    @isTest
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
        String solutionName='Unified Communication Device';
        GetPriceScheduleControllerNGUC priceSchedule=new GetPriceScheduleControllerNGUC();
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        System.runAs(sales){
         Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,'','','true', solutionName,testBasket.Basket_Number__c,'123456789');
        System.assertEquals('Initial',priceSchedule.DiscountApplicableStatus);
        }
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
    
    @isTest
    public static void TestAddon(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (2)' limit 1];
        account acc=[Select id from account limit 1];
        cspmb__Add_On_Price_Item__c addon=[Select id from cspmb__Add_On_Price_Item__c limit 1];
        Set<String> AddonIds=new Set<String>();
        AddonIds.add(addon.id);
        Set<string> ComProdIds=new Set<String>();
        System.runAs(sales){
        Map<String,List<cspmb__Discount_Level__c>> disLevMap=GetPriceSchedulevirtualClass.getApplicableDiscounts(ComProdIds,acc.id, AddonIds);
        List<cspmb__Discount_Level__c> disList=new List<cspmb__Discount_Level__c>();
        disList=disLevMap.get(addon.id);
        System.assertEquals('DMCAT_Discount_000957',disList[0].Business_ID__c );}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End        
    }
     @isTest
    public static void TestFetchTCV(){
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
        String correlationId=GetPriceSchedulevirtualClass.getCorrelationIdForMS ();

        String corId = priceSchedule.correlationId ;
        string configGuid='c20a039b-80fe-8876-5328-4006a5143cce';
        string configGuid2='2b07b38f-4176-f866-3006-643c269b8abc';
        List<String> guidList=new List<string>();
        guidList.add(configGuid);
        guidList.add(configGuid2);
        PricingMSResponseObject__c msResponse = new PricingMSResponseObject__c();
        msResponse.CorrelationId__c = corId;
        msResponse.TCV_Value__c =100;
        msResponse.RemainingTerm__c =10;
        insert msResponse;
        GetPriceSchedulevirtualClass.fetchTCV(guidList,corId);      
        System.assertEquals('Discount Applicable',priceSchedule.DiscountApplicableStatus); }
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End    
    }
     @isTest
    public static void TestgetChargeIds(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        Charge_Line_Item__c CLattr= new Charge_Line_Item__c();
        CLattr.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr.CorrelationId__c='123455666666';
        CLattr.BusinessID__c='DMAT_Discount_000450';
        CLattr.contractTerm__c=20.0;
        CLattr.status__c='Active';
        CLattr.componentName__c='Test';
        CLattr.totalContractValue__c=20.0;
        insert CLattr;
        Map<String,Map<String,Charge_Line_Item__c>> priceItemmap=new Map<String,Map<String,Charge_Line_Item__c>>();
        Map<String,Charge_Line_Item__c> pI_busIdMap=new Map<String,Charge_Line_Item__c>();
        pI_busIdMap.put(CLattr.BusinessID__c,CLattr);
        priceItemmap.put(CLattr.guid__c,pI_busIdMap);
        System.runAs(sales){
        Set<String> chargeItemSet=GetPriceSchedulevirtualClass.getChargeIds(priceItemmap);
        System.assertEquals(chargeItemSet.contains('DMAT_Discount_000450'),true);}
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
        
     @isTest
    public static void TestupdateTCVForCLIId(){
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || Start
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
        Map<String,Charge_Line_Item__c>CliMap1=new Map<String,Charge_Line_Item__c>();
        Map<String,Map<String,Charge_Line_Item__c>> CliMapNew=new Map<String,Map<String,Charge_Line_Item__c>> ();
        Charge_Line_Item__c CLattr= new Charge_Line_Item__c();
        Map<String,decimal> CLIMap=new Map<String,decimal>();
        Map<String,decimal> RemainMap= new Map<String,decimal>();
        Set<String> CliIdSet=new Set<String> ();
        Map<String, Map<String,String>> attValueforAttributeTobeMaped=new Map<String, Map<String,String>> (); 
       Map<String,Promotion_Metadata__mdt> promotionMetadataMap=new Map<String,Promotion_Metadata__mdt>();
       Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap=new    Map<String,List<cspmb__Discount_Level__c>>();
       Set<String> guidset=new Set<String>();
       Set<string> priceItemSet=new Set<String>();
       Set<string> addonset=new Set<String>();
        CLattr.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr.CorrelationId__c='123455666666';
        CLattr.commercialProductId__c='DMAT_Discount_000450';
        CLattr.BusinessID__c='DMAT_Discount_000450';
        CLattr.contractTerm__c=20.0;
        CLattr.status__c='Active';
        CLattr.componentName__c='Test';
        CLattr.totalContractValue__c=20.0;
        insert CLattr;
        CliMap1.put('AddOn',CLattr);
        CliMapNew.put('AddOn',CliMap1);
        CliIdSet.add(CLattr.id);
        CLIMap.put(CLattr.id,22.0);
        RemainMap.put(CLattr.id,22);
        System.runAs(sales){
            GetPriceSchedulevirtualClass GetSC=new GetPriceSchedulevirtualClass();                                    
            GetPriceSchedulevirtualClass.updateTCVForCLIId(CLIMap,CliIdSet,RemainMap);  
            set<string>AddonSet1= GetPriceSchedulevirtualClass.getAddonIds(CliMapNew); 
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap=new Map<String,Map<String,SolutionDTO.Attributes>>();
            String basketID='test';
            String Solutionname='testev';
            GetSC.getCommercialProductCLIMap(guidToAttMapofMap,basketID,Solutionname);
            GetSC.getDiscountLineItems(attValueforAttributeTobeMaped,promotionMetadataMap,DiscountLevelMap,guidset,priceItemSet,addonset);
            GetSC.getChargeLineItems(CliMapNew,guidset,DiscountLevelMap,attValueforAttributeTobeMaped);
            System.assert(AddonSet1.contains('DMAT_Discount_000450'));
        }
        Test.stopTest();
        //Added Profile, User and System.RunAs() method by Aman Soni as a part of EDGE-143527 || End
    }
}