/********************************************************
Class Name      :   TierRateCardNCSHelperTest
Main Class : TierRateCardNCSHelper
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Venkata Ramanan G     11/10/2019      EDGE-112869  Created for Rate Card population Framework
2.          Shubhi Vijayvergia      30/4/2020       Edge-137067 NGUC consumption based model
********************************************************************/

@isTest
public class TierRateCardNCSHelperTest{
    @testSetup
    public static void dataSetup() {

        cscfga__Product_Definition__c  pdcwp = new cscfga__Product_Definition__c(name='Connected Workplace Solution',cscfga__Active__c = true, cscfga__Description__c ='test desc', product_Specification__c='DMCAT_ProductSpecification_000871');
        insert pdcwp;

        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        upsert basket;
               
        List<csord__Solution__c> solList=new List<csord__Solution__c>();
        csord__Solution__c sol = new csord__Solution__c(Name = 'test Sol',csord__Identification__c='Solution Management');
        solList.add(sol);
        csord__Solution__c sol1 = new csord__Solution__c(Name = 'test Sol1',csord__Identification__c='Solution Management');
        solList.add(sol1);
        insert solList;
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.Name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        config.cscfga__Configuration_Status__c = 'Valid';
        config.cscfga__Product_Family__c = 'Hardware';
        config.Quantity_Product_Configuration__c = 2;
        config.cscfga__Product_Definition__c = pdcwp.id;
        config.cssdm__solution_association__c = sol.id;
        pcList.add(config); 
        
         //create Product Configuration
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.Name = 'Test Config';
        config1.cscfga__Description__c = 'test Description ';
        config1.cscfga__Contract_Term__c = 36;
        config1.Type__c = 'New';
        config1.cscfga__Configuration_Status__c = 'Valid';
        config1.cscfga__Product_Family__c = 'Hardware';
        config1.Quantity_Product_Configuration__c = 2;
        config1.cscfga__Product_Definition__c = pdcwp.id;
        config1.cssdm__solution_association__c = sol1.id;
        pcList.add(config1);
		
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basket.id;
        config2.Name = 'Test Config2';
        config2.cscfga__Description__c = 'test Description ';
        config2.cscfga__Contract_Term__c = 36;
        config2.Type__c = 'Modify';
        config2.cscfga__Configuration_Status__c = 'Valid';
        config2.cscfga__Product_Family__c = 'Hardware';
        config2.Quantity_Product_Configuration__c = 2;
        config2.cscfga__Product_Definition__c = pdcwp.id;
        config2.cssdm__solution_association__c = sol1.id;
        pcList.add(config2);
        
        upsert pcList;
		
		config2.csordtelcoa__Replaced_Product_Configuration__c=config1.id; // added replaced id for modify
		update config2;
        
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('CallingPlanName', 'Premium', config.id);//Edge-137067
        attList.add(attr0);
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('ModeString', 'Shared Lines', config.id);//Edge-137067
        attList.add(attr1);
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('CallingPlanName', 'Premium', config1.id);//Edge-137067
        attList.add(attr2);
        cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('ModeString', 'Shared Lines', config1.id);//Edge-137067
        attList.add(attr3);
		cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('CallingPlanName', 'Standard', config2.id);//Edge-137067
        attList.add(attr4);
        cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ModeString', 'Shared Lines', config2.id);//Edge-137067
        attList.add(attr5);
        insert attList;     
                
		/*CustomRateCard__mdt metadata1 = new CustomRateCard__mdt(label = 'test', OfferId__c = 'DMCAT_Offer_000618', Commercial_Product_Code__c  = 'Next Gen Voice',ProductSpecId__c = 'testSpec', NCSName__c = 'Fixed Voice UC Plan Monthly Charge',);
        insert metadata1;*/
     
        //Insert NCS 
		List<csoe__Non_Commercial_Schema__c> ncsList=new List<csoe__Non_Commercial_Schema__c>();
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'Hunt Group Monthly Charge';
        cnse.csoe__Description__c = 'Hunt Group';
		ncsList.add(cnse);
		csoe__Non_Commercial_Schema__c cnse1 = new csoe__Non_Commercial_Schema__c();
        cnse1.name = 'Fixed Voice UC Plan Monthly Charge';
        cnse1.csoe__Description__c = 'Plan';
		ncsList.add(cnse1);
		
        insert ncsList;
        
        list<cspmb__Price_Item__c> comProdList=new list<cspmb__Price_Item__c>();
        cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Plan',324,564.23,'User','Commercial');
        commercialPrd.Offer_Id__c = 'DMCAT_Offer_000618';
        commercialPrd.Plan__c ='Premium';
        commercialPrd.Mode__c='Shared Lines';//Edge-137067
        commercialPrd.Charge_Id__c='DMCAT_RecurringCharge_000814';//Edge-137067
        commercialPrd.cspmb__Price_Item_Code__c ='Next Generation Voice';
        commercialPrd.cspmb__Effective_End_Date__c  = system.today()+30;
        commercialPrd.cspmb__Effective_Start_Date__c  = system.today();
        commercialPrd.ProdSpecId__c ='DMCAT_ProductSpecification_000871';
        commercialPrd.Billing_Description__c = 'Hunt Group';
        commercialPrd.Unit_Of_Measure__c = 'per Hunt Group';
        commercialPrd.rangeFrom__c = '1';
        commercialPrd.rangeTo__c = '10';
		comProdList.add(commercialPrd);
		cspmb__Price_Item__c commercialPrd1 = ProductTestFactory.buildPriceItem('New Plan1',324,564.23,'User','Commercial');
        commercialPrd1.Offer_Id__c = 'DMCAT_Offer_000618';
        commercialPrd1.Plan__c ='Standard';
        commercialPrd1.Mode__c='Shared Lines';//Edge-137067
        commercialPrd1.Charge_Id__c='DMCAT_RecurringCharge_000814';//Edge-137067
        commercialPrd1.cspmb__Price_Item_Code__c ='Next Generation Voice';
        commercialPrd1.cspmb__Effective_End_Date__c  = system.today()+30;
        commercialPrd1.cspmb__Effective_Start_Date__c  = system.today();
        commercialPrd1.ProdSpecId__c ='DMCAT_ProductSpecification_000871';
        commercialPrd1.Billing_Description__c = 'Hunt Group';
        commercialPrd1.Unit_Of_Measure__c = 'per Hunt Group';
        commercialPrd1.rangeFrom__c = '1';
        commercialPrd1.rangeTo__c = '10';
		comProdList.add(commercialPrd1);
		cspmb__Price_Item__c cmmercialPrd2= ProductTestFactory.buildPriceItem('New Plan2',324,564.23,'User','Commercial'); //edge-137067
        cmmercialPrd2.Offer_Id__c = 'DMCAT_Offer_000618';
        cmmercialPrd2.Plan__c ='Standard';
        cmmercialPrd2.Mode__c='Shared Lines';//Edge-137067
        cmmercialPrd2.Charge_Id__c='DMCAT_RecurringCharge_000811';//Edge-137067
        cmmercialPrd2.cspmb__Price_Item_Code__c ='Next Generation Voice';
        cmmercialPrd2.cspmb__Effective_End_Date__c  = system.today()+30;
        cmmercialPrd2.cspmb__Effective_Start_Date__c  = system.today();
        cmmercialPrd2.ProdSpecId__c ='DMCAT_ProductSpecification_000871';
        cmmercialPrd2.Billing_Description__c = 'Hunt Group';
        cmmercialPrd2.Unit_Of_Measure__c = 'per Hunt Group';
        cmmercialPrd2.rangeFrom__c = '1';
        cmmercialPrd2.rangeTo__c = '10';
		comProdList.add(cmmercialPrd2);
        insert comProdList;

        csoe__Non_Commercial_Product_Association__c assoc = new csoe__Non_Commercial_Product_Association__c(Name ='test NCS',csoe__Commercial_Product_Definition__c = pdcwp.id, csoe__Non_Commercial_Schema__c = cnse.id);
        insert assoc;
        
		List<Attachment>  attachmentList=new List<Attachment>();
        Attachment no1 = new Attachment();
		String text = '{"configurations":[{"guid":"de7f04d5-9698-1461-00ea-e2c341841b9f","price":5.00,"rangeTo":"1000","rangeFrom":"1"},{"guid":"10e4836e-c4d8-1173-02b2-83be9197e173","price":4.50,"rangeTo":"2000","rangeFrom":"1001"},{"guid":"af626621-e207-b0cb-e691-acf79dbbe496","price":4.00,"rangeTo":"3000","rangeFrom":"2001"},{"guid":"60e8afca-20e9-9d2c-73d6-055344eb5e16","price":3.50,"rangeTo":"4000","rangeFrom":"3001"},{"guid":"875f2260-787c-c4ac-0b83-471bfa65c2ce","price":3.00,"rangeTo":"5000","rangeFrom":"4001"},{"guid":"a729a7c0-4c04-d0fe-14f4-58d8ef65bc43","price":3.00,"rangeTo":"99999","rangeFrom":"5001"}],"schema":{"name":"MDMTenancy","id":"a795O00000000MqQAI","attributes":[{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"price"}]}}';
        no1.ParentId = config1.Id;
        no1.Name = 'Hunt Group Monthly Charges_schema';
        no1.Body = Blob.valueOf(text);
        attachmentList.add(no1);
        
        Attachment no2 = new Attachment(); //edge-137067
		String body='{"schema":{"attributes":[{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"price"},{"type":"String","showInUI":false,"required":false,"name":"externalId"}],"id":"a6j5O0000000BGQQA2","name":"Fixed Voice UC Plan Monthly Charge"},"configurations":[{"rangeFrom":"1","rangeTo":"10","price":20.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6959","guid":"6363e755-db49-ffb5-70db-954758c7babf"},{"rangeFrom":"21","rangeTo":"50","price":20.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6961","guid":"7d6e1a7d-e303-9f58-5057-8d8b4f302092"},{"rangeFrom":"11","rangeTo":"20","price":20.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6960","guid":"836c4920-62cf-a078-de97-1bdb852c374a"},{"rangeFrom":"51","rangeTo":"200","price":18.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6962","guid":"7e7f1a5b-cf7a-b3a4-56c4-41545272900e"},{"rangeFrom":"201","rangeTo":"500","price":18.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6963","guid":"d56b8227-7053-f5fe-85dd-6d40d2f421cd"},{"rangeFrom":"501","rangeTo":"99999","price":17.00,"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6964","guid":"8eb4d936-d134-ddc9-2199-75df99ff112b"},{"guid":"ed0d79b4-18f7-8501-492a-e668a6acf099","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6965","price":55.00,"rangeTo":"10","rangeFrom":"1"},{"guid":"b103e6b2-0489-00e4-68a1-e255080d7b46","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6967","price":55.00,"rangeTo":"50","rangeFrom":"21"},{"guid":"63691cff-d2ef-28fc-a810-b956ca80ccae","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6966","price":55.00,"rangeTo":"20","rangeFrom":"11"},{"guid":"87efe767-4c55-a1ba-2c98-2715b2ad50ec","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6968","price":49.50,"rangeTo":"200","rangeFrom":"51"},{"guid":"c5edd3b4-709e-5407-8fec-e809714bafdd","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6969","price":49.50,"rangeTo":"500","rangeFrom":"201"},{"guid":"a3bd1155-2f44-ed43-70f0-fa7345291bae","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6970","price":46.75,"rangeTo":"99999","rangeFrom":"501"}]}';
        no2.ParentId = config2.Id;
        no2.Name = 'Fixed Voice UC Plan Monthly Charge_schema';
        no2.Body = Blob.valueOf(body);
		attachmentList.add(no2);
        
		insert attachmentList;
        //edge-137067
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        insert sales;
}

    @isTest
    public static void getdata(){
        Test.startTest();
        List<cscfga__Product_Basket__c> basket = [select id from cscfga__Product_Basket__c limit 1];
        List<csord__Solution__c> sol = [select id from csord__Solution__c];
        cspmb__Price_Item__c commercialProd= [Select id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name='New Plan'];  
        Map<String,String> searchFields = new Map<String,String>();
        searchFields.put('Offer_Id__c',commercialProd.Offer_Id__c);
        searchFields.put('basketid',basket[0].id);
        searchFields.put('SolutionId',sol[0].id);
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        System.runAs(sales){
            TierRateCardNCSHelper helper = new TierRateCardNCSHelper();         
            TierRateCardNCSDTO.Attribute tierratecardwrapper = new TierRateCardNCSDTO.Attribute();
            tierratecardwrapper.startDate  = String.valueOf(system.today());
            tierratecardwrapper.shownInUI = true;
            tierratecardwrapper.required = true;
            tierratecardwrapper.name = 'test';
            List<TierRateCardNCSDTO.Attribute> attrlst = new List<TierRateCardNCSDTO.Attribute>();
            attrlst.add(tierratecardwrapper);
            TierRateCardNCSDTO.Schema tierratecardwrapper1 = new TierRateCardNCSDTO.Schema();
            tierratecardwrapper1.name  = 'test';
            tierratecardwrapper1.id = 'test';
            tierratecardwrapper1.attributes = attrlst;
            //tierratecardwrapper.name = 'test';
            
            try{
                TierRateCardNCSDTO.parse('test');
                Map<String,Object> lookupResult = TierRateCardNCSHelper.getData(searchFields);
                System.assertEquals(true,TierRateCardNCSHelper.offerId=='DMCAT_Offer_000618');            
            }catch(Exception e){
                system.debug('exception');
            }
            
        }
        Test.stopTest();
    }
   
	//Edge-137067-----start	
	 @isTest
    public static void getdata_modify(){
        Test.startTest();
        List<cscfga__Product_Basket__c> basket = [select id from cscfga__Product_Basket__c limit 1];
        List<csord__Solution__c> sol = [select id from csord__Solution__c];
        cspmb__Price_Item__c commercialProd= [Select id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name='New Plan'];       
        Map<String,String> searchFields = new Map<String,String>();
        searchFields.put('Offer_Id__c',commercialProd.Offer_Id__c);
        searchFields.put('basketid',basket[0].id);
        searchFields.put('SolutionId',sol[1].id);
        User Sales=[Select id from user where username='salesuser@testsales.com'];
        System.runAs(sales){
            TierRateCardNCSHelper helper = new TierRateCardNCSHelper();
            Map<String,Object> lookupResult = TierRateCardNCSHelper.getData(searchFields);
            system.assertEquals(true,TierRateCardNCSHelper.offerId=='DMCAT_Offer_000618');    
			cscfga__Product_Configuration__c pc=[select id,type__c from cscfga__Product_Configuration__c where name='Test Config' limit 1];
			update pc;
			TierRateCardNCSHelper helper1 = new TierRateCardNCSHelper();
            Map<String,Object> lookupResult1 = TierRateCardNCSHelper.getData(searchFields);
			// reruning to test modify
			TierRateCardNCSHelper helper2 = new TierRateCardNCSHelper();
            Map<String,Object> lookupResult2 = TierRateCardNCSHelper.getData(searchFields);
			System.assertEquals(true,TierRateCardNCSHelper.offerId=='DMCAT_Offer_000618');  
        }
        Test.stopTest();
    }
		//Edge-137067-----end	
            
}