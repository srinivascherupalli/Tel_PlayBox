/*
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        Pooja                   20-07-2020    CS Spring'20 Upgrade Change
=======================================================================================================================================
*/
@isTest
private class ProductConfigurationCustomTriggerTest  {
	@TestSetup static void dataSetup()
    {
		Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'New To Market';
        testOpp.Billing_Solution__c = 'Non Standard';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;

		cscfga__Screen_Flow__c testflow = new cscfga__Screen_Flow__c();
		testflow.Name = 'test';
		testflow.cscfga__Template_Reference__c = 'test';
		insert testflow;       

		cscfga__Product_Definition__c testDefn = new cscfga__Product_Definition__c();
		testDefn.Name = 'testDefn';
		testDefn.cscfga__Description__c = 'test';
		insert testDefn;

        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
		testConfig.Unit_of_measurement__c = 'setupConf';
		testConfig.cscfga__Product_Definition__c = testDefn.Id;
        insert testConfig;
	}

	@isTest
	static void testBeforeInsert()
	{
		cscfga__Product_Basket__c testBasket = [SELECT Id FROM cscfga__Product_Basket__c LIMIT 1];
		cscfga__Screen_Flow__c testFlow = [SELECT Id FROM cscfga__Screen_Flow__c LIMIT 1];
		cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Test Config';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
		testConfig.cscfga__Screen_Flow__c = testflow.Id;
		testConfig.Unit_of_measurement__c = 'insertedConfig';

		//Test.startTest();
        insert testConfig;
		//Test.stopTest();

        cscfga__Product_Configuration__c afterTest = [SELECT cscfga__Screen_Flow__c FROM cscfga__Product_Configuration__c WHERE Unit_of_measurement__c = 'insertedConfig' LIMIT 1];
        
        //Pooja: CS Spring'20 Upgrade Change
        System.assertEquals (testFlow.Id, afterTest.cscfga__Screen_Flow__c, 'Screenflow should be present');
    }

	@isTest
	static void testBeforeUpdate()
	{
		cscfga__Product_Configuration__c testConf = [SELECT Id, cscfga__Screen_Flow__c, Unit_of_measurement__c FROM cscfga__Product_Configuration__c LIMIT 1];
		cscfga__Screen_Flow__c testFlow = [SELECT Id FROM cscfga__Screen_Flow__c LIMIT 1];
		testConf.cscfga__Screen_Flow__c = testFlow.Id;

		Test.startTest();		
		update testConf;
		Test.stopTest();

        cscfga__Product_Configuration__c afterTest = [SELECT cscfga__Screen_Flow__c FROM cscfga__Product_Configuration__c WHERE Unit_of_measurement__c = 'setupConf' LIMIT 1];
        
        //Pooja: CS Spring'20 Upgrade Change
        System.assertEquals(testFlow.Id, afterTest.cscfga__Screen_Flow__c, 'Screenflow should be present');
    }
        
}