/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ChargeDiscountQueryUtility  
* @Jira : Edge-127073

1. Ankit Goswami    26-02-2020     EDGE-123594 Call fetchChargeLineItemForStatus method
2. Aman Soni        29-04-2020     EDHE-143527 Modified the class as per new structure by Aman Soni
3. Pawan Singh         06/08/2021     DIGI-5648   Commented the dummy data as it is not in use and since offer name is changed from Telstra_Collaboration to Adaptive Collaboration
*/

//Modified By Aman Soni as a part of EDGE-143527 || Start
@isTest
public class ChargeDiscountQueryUtilityTest {
     @TestSetup static void CreateData()
    {
        Account testAccount = PricingTestDataFactory.generateAccount();
        insert testAccount;

        Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);
        insert testOppty;

        cscfga__product_basket__c testBasket = PricingTestDataFactory.generateProductBasket(testAccount,testOppty);
        insert testBasket;
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
        List<cspmb__Price_Item__c> price_item_List =new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c price_item = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176');
        cspmb__Price_Item__c price_item_1 = PricingTestDataFactory.createMobilePriceItem('DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5177');
        cspmb__Price_Item__c pINGUCVoice = new cspmb__Price_Item__c();
        pINGUCVoice=PricingTestDataFactory.generateNGUCPriceItem_Voice('Next Generation Voice','DMCAT_RecurringCharge_000814');
        price_item_List.add(price_item);
        price_item_List.add(price_item_1);
        price_item_List.add(pINGUCVoice);
        insert price_item_List;
        
        cspmb__Add_On_Price_Item__c addon =PricingTestDataFactory.generateAddOnPriceItem();
        insert addon;
        
        String configGuid = 'e37bc7a0-a8a1-1798-5d46-73154b3437bb';
        String configGuid1= 'c20a039b-80fe-8876-5328-4006a5143cce';
        String configGuid2= '2b07b38f-4176-f866-3006-643c269b8a39';
        
        List<Charge_Line_Item__c> cliLst = new List<Charge_Line_Item__c>();
        Charge_Line_Item__c priceItemCLI1 = PricingTestDataFactory.generateChargeLineItem('123456789',configGuid,'Price Item');
        cliLst.add(priceItemCLI1);
        
        Charge_Line_Item__c addonCLI1 = PricingTestDataFactory.generateChargeLineItem('123456789',configGuid,'AddOn');
        cliLst.add(addonCLI1);
        
        Charge_Line_Item__c addonCLI2 = PricingTestDataFactory.generateChargeLineItem('123456788',configGuid2,'AddOn');
        addonCLI2.basketId__c=testBasket.id;
        cliLst.add(addonCLI2);
        
        Charge_Line_Item__c priceItemCLI2 = PricingTestDataFactory.generateChargeLineItem('123455666666',configGuid1,'Price Item');         
        priceItemCLI2.status__c='Active';
        priceItemCLI2.BusinessID__c='DMAT_Discount_000450';
        priceItemCLI2.componentName__c='Test';
        priceItemCLI2.basketId__c='1234566';
        priceItemCLI2.solutionId__c='542272547474';
        cliLst.add(priceItemCLI2);
        
        Charge_Line_Item__c priceItemCLI3 = PricingTestDataFactory.generateChargeLineItem('123455666666',configGuid1,'Price Item');         
        priceItemCLI3.status__c='';
        priceItemCLI3.BusinessID__c='DMAT_Discount_000450';
        priceItemCLI3.componentName__c='Test';
        priceItemCLI3.basketId__c='1234566';
        priceItemCLI3.solutionId__c='542272547474';
        cliLst.add(priceItemCLI3);
        insert cliLst;
        
        List<Discount_Line_Item__c> dliLst = new List<Discount_Line_Item__c>();
        Discount_Line_Item__c dli1 = PricingTestDataFactory.generateDiscountLineItems('Activation Credits Months Discount Dummy','100','Percent',priceItemCLI1);
        dliLst.add(dli1);
        Discount_Line_Item__c dli2 = PricingTestDataFactory.generateDiscountLineItems('MMC Discount Dummy','10','',priceItemCLI1);
        dliLst.add(dli2);
        Discount_Line_Item__c dli3 = PricingTestDataFactory.generateDiscountLineItems('Postpaid MRO Plan Discount Dummy','19.1','',priceItemCLI1);
        dliLst.add(dli3);
        Discount_Line_Item__c dli4 = PricingTestDataFactory.generateDiscountLineItems('IDD Call Pack Discount Dummy','20','Percent',addonCLI1);
        dliLst.add(dli4);
        Discount_Line_Item__c dli5 = PricingTestDataFactory.generateDiscountLineItems('IDD Call Pack Discount Dummy','20','Percent',addonCLI2);
        dli5.description__c = 'IDD Call Pack Discount Dummy';
        dliLst.add(dli5);
        Discount_Line_Item__c dli6 = PricingTestDataFactory.generateDiscountLineItems('IDD Call Pack Discount Dummy','20','Percent',priceItemCLI2);
        dliLst.add(dli6);
        Discount_Line_Item__c dli7 = PricingTestDataFactory.generateDiscountLineItems('IDD Call Pack Discount Dummy','20','Percent',priceItemCLI3);
        dliLst.add(dli7);
        insert dliLst;
        
        List<cspmb__Discount_Level__c> dlList=new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c discount_level = PricingTestDataFactory.generateDiscountLevelPlan('Mobile Workspace Discount 1','DMCAT_Discount_000944',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level);
        cspmb__Discount_Level__c discount_level_1 = PricingTestDataFactory.generateDiscountLevelPlan('National BYO Discount','DMCAT_Discount_000956',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level_1);
        cspmb__Discount_Level__c discount_level2 = PricingTestDataFactory.generateDiscountLevelPlan('IDD callpack','DMCAT_Discount_000957',testAccount,'Data SIM $5','3 GB');
        dlList.add(discount_level2);    
        cspmb__Discount_Level__c discount_levelv = PricingTestDataFactory.generateDiscountLevelPlan('Early Adopter Discount', 'DMCAT_Discount_000899', testAccount,'rental','');
        discount_levelV.Is_Delegated__c = false;
        dlList.add(discount_levelv);            
        insert dlList;
        
        List<cspmb__Discount_Association__c> DAList=new List<cspmb__Discount_Association__c>();
        cspmb__Discount_Association__c DisAssoc = PricingTestDataFactory.generateDiscountAssociation2(price_item,null,discount_level);
        cspmb__Discount_Association__c DisAssoc1 = PricingTestDataFactory.generateDiscountAssociation2(price_item_1,null,discount_level_1);
        cspmb__Discount_Association__c DisAssoc2 = PricingTestDataFactory.generateDiscountAssociation2(null,addon,discount_level2);
        DAList.add(DisAssoc);
        DAList.add(DisAssoc1);
        DAList.add(DisAssoc2);
        insert DAList;

        List<csord__Solution__c> solutionList=new List<csord__Solution__c>();
        csord__Solution__c solution  = PricingTestDataFactory.generateSolution('Enterprise Mobility (1)');
        csord__Solution__c solution1  = PricingTestDataFactory.generateSolution('Enterprise Mobility (1)');
        csord__Solution__c solution2  = PricingTestDataFactory.generateSolution('Enterprise Mobility (1)');
 //     csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution');  DIGI-5648  sample data not in use
 //     solutionList.add(solutionV);        
        solutionList.add(solution);
        solutionList.add(solution1);
        solutionList.add(solution2);
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        
        Attachment att=PricingTestDataFactory.generateSolutionAttachment(solution.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item.ID,''));
        Attachment att1=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution2.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
//        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCVoiceSolutionString(pINGUCVoice.id)); DIGI-5648
        attList.add(att);
        attList.add(att1);
        attList.add(att2);
 //       attList.add(attV);
        insert attList;    
    }
     @isTest
    public static void TestfetchChargeLineItem(){
        Test.startTest();
            csord__Solution__c sol=[select id,cssdm__product_basket__c from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            String corId = '123456789';
            Set<String> cliIdSet=new Set<String>();
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
            System.runAs(sales){
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,corId);      
            System.assert(!String.IsBlank(corId));
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c,basketId__c,guid__C  from Charge_Line_Item__c];       
            System.assert(cliList.size()>0);  
            List<Discount_Line_Item__c> dliList=[select id from Discount_Line_Item__c];
            System.assert(dliList.size()>0);                   
            if(cliList.size()>0){           
                for(Charge_Line_Item__c cli:cliList){
                    cliIdSet.add(cli.id);
                }
            }
            ChargeDiscountQueryUtility dq=new ChargeDiscountQueryUtility();
            List<Charge_Line_Item__c> result = dq.fetchChargeLineItem(cliIdSet);
            system.assert(result[0].CorrelationId__c==corId);}
        Test.stopTest();   
    }
     @isTest
    public static void TestfetchChargeLineItemForStatus(){
        Test.startTest();
            csord__Solution__c sol=[select id,cssdm__product_basket__c from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            String corId = '123456789'; 
            Set<String> cliIdSet=new Set<String>();
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
            System.runAs(sales){        
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,corId); 
            List<String> guidList=new List<string>();
            Set<String> guidSet=new Set<String>();
            guidList.add(configGuid);
            guidSet.add(configGuid);
            System.assert(!String.IsBlank(corId));
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c,basketId__c,guid__C from Charge_Line_Item__c];       
            System.assert(cliList.size()>0);  
            List<Discount_Line_Item__c> dliList=[select id from Discount_Line_Item__c];
            System.assert(dliList.size()>0);                    
            if(cliList.size()>0){        
                for(Charge_Line_Item__c cli:cliList){
                    cliIdSet.add(cli.id);
                }
            }  
            ChargeDiscountQueryUtility dq=new ChargeDiscountQueryUtility();
            Map<String,Charge_Line_Item__c> result = dq.fetchChargeLineItemForStatus(guidSet,testBasket.id);//EDGE-123594 Call fetchChargeLineItemForStatus method
            System.assertEquals(true,result.containsKey(configGuid));
            system.assert(cliList[0].CorrelationId__c==corId);}
        Test.stopTest();   
    }
    @isTest
    public static void TestfetchAssociatedDiscountLineItem(){
        Test.startTest();
            csord__Solution__c sol=[select id,cssdm__product_basket__c from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            String corId = '123456789'; 
            Set<String> cliIdSet=new Set<String>();
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
            System.runAs(sales){
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,corId);
            List<String> guidList=new List<string>();
            Set<String> guidSet=new Set<String>();
            guidList.add(configGuid);
            guidSet.add(configGuid);
            System.assert(!String.IsBlank(corId));
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c from Charge_Line_Item__c];       
            System.assert(cliList.size()>0);  
            List<Discount_Line_Item__c> dliList=[select id from Discount_Line_Item__c];
            System.assert(dliList.size()>0);             
            if(cliList.size()>0){
                for(Charge_Line_Item__c cli:cliList){
                    cliIdSet.add(cli.id);
                }
            }  
            ChargeDiscountQueryUtility dq=new ChargeDiscountQueryUtility();
            Map<String,List<Discount_Line_Item__c>> guidToDLIMap= dq.fetchAssociatedDiscountLineItem(guidSet);
            system.assert(cliList[0].CorrelationId__c==corId);}
        Test.stopTest();   
    }
    @isTest
    public static void TestfetchAssociatedDiscountLineItemCli(){
        Test.startTest();
            csord__Solution__c sol=[select id,cssdm__product_basket__c from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            String corId = '123456788';
            Set<String> cliIdSet=new Set<String>();
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
            System.runAs(sales){
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,'123456789');   
            System.assert(!String.IsBlank(corId));
            //to cover else part 
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c from Charge_Line_Item__c where guid__C =:configGuid];       
            System.assert(cliList.size()>0);  
            List<Discount_Line_Item__c> dliList=[select id,Name,description__c from Discount_Line_Item__c];
            System.assert(dliList.size()>0);                    
            if(cliList.size()>0){        
                for(Charge_Line_Item__c cli:cliList){
                    cliIdSet.add(cli.id);
                }
            }  
            ChargeDiscountQueryUtility dq=new ChargeDiscountQueryUtility();
            List<Discount_Line_Item__c> result= dq.fetchAssociatedDiscountLineItemFromCliID(cliIdSet);
            system.assert(result[0].description__c == 'IDD Call Pack Discount Dummy');
            }
        Test.stopTest();   
    }
    @isTest
    public static void TestonLoadNegative(){
        Test.startTest();
            csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a45';
            String corId = '123456789';
            System.runAs(sales){
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c from Charge_Line_Item__c];
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;           
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,'123456789');
            system.assert(cliList[0].CorrelationId__c==corId);} 
        Test.stopTest();
        
    }
    /******************************************************************************************************
    * Method Name : fetchChargeLineItemForSolutionTest
    * EDGE        : Edge-134880
    * Parameters  : NA
    * Return      : NA                      
    ******************************  ************************************************************************/
    @isTest static void fetchChargeLineItemForSolutionTest(){
        Test.startTest();
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            Map<String, list<Charge_Line_Item__c>> returnMap = new Map<String, list<Charge_Line_Item__c>>();
            set<string>guidSet= new set<string>();
            guidSet.add('c20a039b-80fe-8876-5328-4006a5143cce');
            string baskId='1234566';
            string solutinId='542272547474';
            System.runAs(sales){
            ChargeDiscountQueryUtility charDis = new ChargeDiscountQueryUtility();
            returnMap = charDis.fetchChargeLineItemForSolution(guidSet,baskId,solutinId);//EDGE-134880 Call fetchChargeLineItemForSolution method
            charDis.fetchPreviousChargeLineItemForSolution(guidSet);//EDGE-134880 Call fetchPreviousChargeLineItemForSolution method
            System.assertEquals(true, returnMap.containsKey('c20a039b-80fe-8876-5328-4006a5143cce'));}
        Test.stopTest();     
    }
  
    //Added new method by Aman Soni as a part of EDGE-143527
    @isTest static void fetchExistingChargeLineItemTest(){
        Test.startTest();
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            Map<String, Charge_Line_Item__c> returnMap = new Map<String, Charge_Line_Item__c>();
            set<string>guidSet= new set<string>();
            guidSet.add('c20a039b-80fe-8876-5328-4006a5143cce');
            string baskId='1234566';
            string solutinId='542272547474';
            System.runAs(sales){
            ChargeDiscountQueryUtility charDis = new ChargeDiscountQueryUtility();
            returnMap = charDis.fetchExistingChargeLineItem(guidSet);
            System.assertEquals(true, returnMap.containsKey('c20a039b-80fe-8876-5328-4006a5143cce_542272547474_DMAT_Discount_000450'));}
        Test.stopTest();     
    }
    //Modified By Aman Soni as a part of EDGE-143527 || End
}