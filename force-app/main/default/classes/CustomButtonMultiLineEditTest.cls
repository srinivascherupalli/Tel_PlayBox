/*************************************************************************************************
Name : CustomButtonMultiLineEditTest 
Description : Test class for CustomButtonMultiLineEdit which is called from Add button on 
              productBasket screen.
              
**************************************************************************************************/
@isTest
public class CustomButtonMultiLineEditTest {
    
    @testsetup static void setupTestData() {
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
			insert pb;
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
			insert prod;
		
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		List<PricebookEntry> testpbeList = new List<PricebookEntry>{standardPBE, pbe};
		insert testpbeList;

        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';

		List<Account> accList = new List<Account>{acc};
		insert accList;

		Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
		opp.Product_Type__c = 'Modular';
		opp.Name = 'TestingOpp';

		List<Opportunity> oppList = new List<Opportunity>{opp};
		insert oppList;

		Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        INSERT c;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';

		List<OpportunityContactRole> testOCRList = new List<OpportunityContactRole>{ocr};
		INSERT testOCRList;

        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
		basket.csbb__Account__c = acc.Id;
		basket.Name = 'testBasketforCBQ';

		List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c>{basket};
		insert testBasketList;

		cscfga__Product_Definition__c defMobility = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');

		List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMobility};
		insert prodDefList;

		cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
		config.cscfga__Product_Definition__c = defMobility.Id;
		config.cscfga__Product_Basket__c = basket.Id;
		
		List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>{config};
		insert prodConfigList;

		cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config.id);
		
		List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>{attr0};
		
		cscfga__Screen_Flow__c testScreenFlow = new cscfga__Screen_Flow__c();
		testScreenFlow.Name = 'MLEScreen';
		testScreenFlow.cscfga__Template_Reference__c = 'cscfga__StandardOnlineTemplate';

		insert testScreenFlow;

		cscfga__Screen_Flow_Product_Association__c testSFPA = new cscfga__Screen_Flow_Product_Association__c();
		testSFPA.cscfga__Screen_Flow__c = testScreenFlow.Id;
		testSFPA.cscfga__Product_Definition__c = defMobility.Id;
		
		insert testSFPA;	
		} 
	/*
    @isTest
    private static void performAction_WillReturnTheCorrectUrl() {
        disableCSTrigger();
        
        //Create Test Account
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        
        //Create Test Basket
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        
        //Create Current Product Catalog Product Definition
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Current Product Catalog', null);
        insert prodDef;
        
        //Create ScreenFlow Named MLEScreen
        cscfga__Screen_Flow__c sf1 = ProductTestFactory.buildScreenFlow('MLEScreen');
        insert sf1;
        
        //Create ScreenFlowAssociation between Product Definition and ScreenFlow
        cscfga__Screen_Flow_Product_Association__c sfA1 = ProductTestFactory.buildSFAssociation(prodDef.id, sf1.id);
        insert sfA1;
        
        Test.startTest();
        CustomButtonMultiLineEdit mle = new CustomButtonMultiLineEdit();
        mle.performAction(String.valueOf(basket.Id), null);
        
        //Asserting to check the correct URL is formed containing product definition Id and screenflow Id
        System.assert(mle.performAction(String.valueOf(basket.Id), null).contains('&productDefinitionId='+prodDef.Id+'&screenFlowId='+sf1.id));
        Test.stopTest();
        
    }
 @isTest
    private static void performAction_WillReturnError() {
        disableCSTrigger();
        
        //Create Test Account
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        
        //Create Test Basket
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        
        //Create Current Product Catalog Product Definition
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Current Product Catalog', null);
        insert prodDef;
        
        //Create ScreenFlow Named MLEScreen
        cscfga__Screen_Flow__c sf1 = ProductTestFactory.buildScreenFlow('MLEScreen');
        insert sf1;
        
       
        //Calling the test method without associating screen flow called MLE Screen
        Test.startTest();
        CustomButtonMultiLineEdit mle = new CustomButtonMultiLineEdit();
        mle.performAction(String.valueOf(basket.Id), null);
        
        //Asserting to check the correct URL is formed containing product definition Id and screenflow Id
        System.assert(mle.performAction(String.valueOf(basket.Id), null).contains('Please check the Product Definition and ScreenFlow Association'));
        
        Test.stopTest();
        
    }*/
    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ; 
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        insert subsSettings ; 
    }
    
	@IsTest
	private static void testPerformAction(){
		cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];

		CustomButtonMultiLineEdit testInstance = new CustomButtonMultiLineEdit();
		Test.startTest();
		String res = testInstance.performAction(String.valueOf(basket.Id),null);
		Test.stopTest();

		System.assertEquals(true, res.contains('"ok"'), 'Positive test, should return ok');
	}

	@IsTest
	private static void testCheckProductDefiniton()
	{
		CustomButtonMultiLineEdit testInstance = new CustomButtonMultiLineEdit();
		Test.startTest();
		cscfga__Product_Definition__c res = testInstance.CheckProductDefiniton('IP Site');
		Test.stopTest();

		System.assertEquals(null, res, 'should not return a product');
	}

	@IsTest
	private static void testCheckScreenFlowAssociation()
	{
		cscfga__Product_Definition__c testPD = [SELECT id FROM cscfga__Product_Definition__c WHERE Name = 'Mobility'];
		
		CustomButtonMultiLineEdit testInstance = new CustomButtonMultiLineEdit();
		Test.startTest();
		cscfga__Screen_Flow_Product_Association__c res = testInstance.CheckScreenFlowAssociation('test', testPD.Id);
		Test.stopTest();

		System.assertEquals(null, res, 'should not return a screenflow');
	}

	@IsTest
	private static void testCheckProductsInBasket()
	{
		cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
		
		CustomButtonMultiLineEdit testInstance = new CustomButtonMultiLineEdit();
		Test.startTest();
		String res = testInstance.checkProductsInBasket(basket.Id, 'test');
		Test.stopTest();

		System.assertEquals(true, res.contains('error'), 'should not return a screenflow');
	}
}