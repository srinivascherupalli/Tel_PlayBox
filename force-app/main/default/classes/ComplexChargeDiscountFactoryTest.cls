/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : ComplexChargeDiscountFactory  
* @Jira : Edge-127073
* EDGE-143527 - Added New method and added User, Profile ,new data in existing methods by Aman Soni 
No.   Developer Name        Date            Story Description 
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated Solution Name from Telstra_Collaboration to Adaptive Collaboration
*/
@isTest
public class ComplexChargeDiscountFactoryTest {
        //Modified by Aman Soni as apart of EDGE-143527
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
        cspmb__Price_Item__c pINGUCVoice = PricingTestDataFactory.generateNGUCPriceItem_Voice('Next Generation Voice','DMCAT_RecurringCharge_000814');
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
        priceItemCLI1.status__c='New';
        priceItemCLI1.BusinessID__c='DMCAT_RecurringCharge_000654';
        priceItemCLI1.guid__c=configGuid;
        cliLst.add(priceItemCLI1);
        
        Charge_Line_Item__c addonCLI1 = PricingTestDataFactory.generateChargeLineItem('123456789',configGuid1,'AddOn');
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
  //    csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Telstra Collaboration Solution'); DIGI-5648  
        csord__Solution__c solutionV = PricingTestDataFactory.generateSolution('Adaptive Collaboration Solution');  
        solutionList.add(solutionV);        
        solutionList.add(solution);
        solutionList.add(solution1);
        solutionList.add(solution2);
        insert solutionList;    
        
        List<Attachment> attList =new List<Attachment>();
        
        Attachment att=PricingTestDataFactory.generateSolutionAttachment(solution.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item.ID,''));
        Attachment att1=PricingTestDataFactory.generateSolutionAttachment(solution1.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
        Attachment att2=PricingTestDataFactory.generateSolutionAttachment(solution2.id,SolutionAttachmentTestDataFactory.generateSolutionString(price_item_1.ID,addon.id));
        Attachment attV=PricingTestDataFactory.generateSolutionAttachment(solutionV.id,SolutionAttachmentTestDataFactory.generateNGUCVoiceSolutionString(pINGUCVoice.id));
        attList.add(att);
        attList.add(att1);
        attList.add(att2);
        attList.add(attV);
        insert attList;
    }
    
    //Modified by Aman Soni as apart of EDGE-143527
     @isTest
    public static void TestonLoadPositive(){
        Test.startTest();
            csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
            String corId = '123456789';
            GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
            Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
            System.runAs(sales){
            priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,corId); 
            List<String> guidList=new List<string>();
            guidList.add(configGuid);
            System.assert(!String.IsBlank(corId));
            List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c,basketId__c,guid__C  from Charge_Line_Item__c];
            System.assert(cliList.size()>0);  
            List<Discount_Line_Item__c> dliList=[select id,BusinessID__c from Discount_Line_Item__c];
            System.assert(dliList.size()>0);             
            ComplexChargeDisountFactory cdf=new ComplexChargeDisountFactory();        
            if(cliList.size()>0){
                cdf.updateChargeLineItem(cliList);
                cdf.getChargeLineItem(cliList[0]);
            }  
            if(dliList.size()>0){
                cdf.updateDiscountLineItem(dliList);
                cdf.getDiscountLineItem(cliList[0],dliList[0]);
            }
            System.assert(cliList[0].CorrelationId__c==corId);}
        Test.stopTest(); 
    }
    
    //Added New method by Aman Soni as a part of EDGE-143257
    @isTest
    public static void TestUpsertChargeDiscountLineItem(){
            csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
            account acc=[Select id from account limit 1];
            cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
            string configGuid='e37bc7a0-a8a1-1798-5d46-73154b3437bl';
            String corId = '123456789';
            String extID = 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5176';
            System.runAs(sales){                
            cspmb__Price_Item__c pi = [Select id,name,External_Id__c from cspmb__Price_Item__c where External_Id__c =:extID];           
            Charge_Line_Item__c cli = PricingTestDataFactory.generateChargeLineItem('123456789',configGuid,'Price Item');
            cli.status__c='New';
            cli.BusinessID__c='DMCAT_RecurringCharge_000654';
            cli.guid__c=configGuid;         
            cli.solutionId__c = sol.id;
            
            List<Discount_Line_Item__c> dliList = new List<Discount_Line_Item__c>();
            Discount_Line_Item__c dlia = PricingTestDataFactory.generateDiscountLineItems('Activation Credits Months Discount Dummy','100','Percent',cli);
            dliList.add(dlia);
            Discount_Line_Item__c dlib = PricingTestDataFactory.generateDiscountLineItems('MMC Discount Dummy','10','',cli);
            dliList.add(dlib);
            
            Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems = new Map<String, Map<String,Charge_Line_Item__c>>();
            Map<String,Charge_Line_Item__c> cliMap = new Map<String,Charge_Line_Item__c>();
            cliMap.put(pi.id,cli);
            finalChargeLineItems.put(configGuid,cliMap); 
            
            Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>(); 
            Map<String,List<Discount_Line_Item__c>> dlimap = new Map<String,List<Discount_Line_Item__c>>();
            dlimap.put(pi.id,dliList);
            DiscountLineItemsMap.put(configGuid,dlimap);
            
            ComplexChargeDisountFactory cdf=new ComplexChargeDisountFactory();
            cdf.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems); 
            
            Test.startTest();
            Charge_Line_Item__c cliNew = PricingTestDataFactory.generateChargeLineItem('123456789',configGuid,'Price Item');
            cliNew.status__c='New';
            cliNew.BusinessID__c='DMCAT_RecurringCharge_000654';
            cliNew.guid__c=configGuid;          
            cliNew.solutionId__c = sol.id;  
            
            List<Discount_Line_Item__c> dliListNew = new List<Discount_Line_Item__c>();
            Discount_Line_Item__c dliNew1 = PricingTestDataFactory.generateDiscountLineItems('Activation Credits Months Discount Dummy','100','Percent',cliNew);
            dliListNew.add(dliNew1);
            Discount_Line_Item__c dliNew2 = PricingTestDataFactory.generateDiscountLineItems('MMC Discount Dummy','10','',cliNew);
            dliListNew.add(dliNew2);
            
            Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItemsNew = new Map<String, Map<String,Charge_Line_Item__c>>();
            Map<String,Charge_Line_Item__c> cliMapNew = new Map<String,Charge_Line_Item__c>();
            cliMapNew.put(pi.id,cliNew);
            finalChargeLineItemsNew.put(configGuid,cliMapNew); 
            
            Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMapNew=new Map<String, Map<String,List<Discount_Line_Item__c>>>(); 
            Map<String,List<Discount_Line_Item__c>> dlimapNew = new Map<String,List<Discount_Line_Item__c>>();
            dlimapNew.put(pi.id,dliListNew);
            DiscountLineItemsMapNew.put(configGuid,dlimapNew);
            
            cdf.upsertChargeDiscountLineItem(DiscountLineItemsMapNew,finalChargeLineItemsNew);
            
            System.assert(cli.CorrelationId__c==corId);}
        Test.stopTest(); 
    }
    
    //Modified by Aman Soni as apart of EDGE-143527
     @isTest
    public static void TestonLoadNegative(){
        Test.startTest();
        csord__Solution__c sol=[select id from csord__Solution__c where name='Enterprise Mobility (1)' limit 1];
        account acc=[Select id from account limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        String corId = '123456789';
        GetPriceScheduleController priceSchedule=new GetPriceScheduleController();
        Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
        System.runAs(sales){
        priceSchedule.onLoadMethod(guidToAttMapofMap,testBasket.id,acc.id,sol.id,'true', '',testBasket.Basket_Number__c,corId);   
        List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c,basketId__c,guid__C  from Charge_Line_Item__c];
        System.assert(cliList.size()>0);}
        Test.stopTest();        
    }
    
    //Modified by Aman Soni as apart of EDGE-143527
    @isTest
    public static void TestonLoadNGUCVOICE(){
        Test.startTest();
      //  csord__Solution__c sol=[select id,name from csord__Solution__c where name='Telstra Collaboration Solution' limit 1];  DIGI-5648
        csord__Solution__c sol=[select id,name from csord__Solution__c where name='Adaptive Collaboration Solution' limit 1]; 
        account acc=[Select id from account limit 1];
        cscfga__product_basket__c testBasket=[Select id,Basket_Number__c from cscfga__product_basket__c limit 1];
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        string configGuid='2b07b38f-4176-f866-3006-643c269b8a39';
        String corId = '123456789';
        GetPriceScheduleControllerNGUCVoice priceSchedule=new GetPriceScheduleControllerNGUCVoice();
        Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap;
        System.runAs(sales){
        priceSchedule.onLoadMethod( guidToAttMapofMap,testBasket.id,'','','true', sol.name,testBasket.Basket_Number__c,corId);
        List<Charge_Line_Item__c> cliList=[select id,CorrelationId__c  from Charge_Line_Item__c];
        System.assert(cliList.size()>0); 
        List<Discount_Line_Item__c> dliList=[select id,BusinessID__c from Discount_Line_Item__c]; 
        System.assert(dliList.size()>0);             
        ComplexChargeDisountFactory cdf=new ComplexChargeDisountFactory();        
        if(cliList.size()>0){
            cdf.updateChargeLineItem(cliList);
            cdf.getChargeLineItem(cliList[0]);
        }  
        if(dliList.size()>0){
            cdf.updateDiscountLineItem(dliList);
        }
        System.assert(cliList[0].CorrelationId__c==corId);}
        Test.stopTest(); 
    }
}