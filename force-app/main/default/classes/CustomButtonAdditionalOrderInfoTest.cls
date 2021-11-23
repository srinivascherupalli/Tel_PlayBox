@isTest
private class CustomButtonAdditionalOrderInfoTest {

	@testSetup static void setupData() {
		createCustomSettingValues();
		cscfga__Product_Basket__c bsk = new cscfga__Product_Basket__c();
		insert bsk;

        EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6');
        EnvironmentVariable.put('okapi_client_id', '1234');
        EnvironmentVariable.put('okapi_client_secret', '1234');
        EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
}
	
	@isTest static void testConstructorMethod() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		Test.startTest();
		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();        
        System.assertEquals(bsk.id,ctrl.basketId);
   		Test.stopTest();
	}

	@isTest static void testRenderHotCutOVerAttribute() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		Test.startTest();
		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();        
        System.assertEquals(bsk.id,ctrl.basketId);
        ctrl.renderHotCutOverAttribute();
        System.assertEquals(true,ctrl.basket.Hot_Cutover_Comments__c==null);
        System.assertEquals(true,ctrl.basket.Service_Number__c==null);       

		Test.stopTest();
	}

	@isTest static void testPerformAction() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		Test.startTest();
		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();        
        System.assertEquals(bsk.id,ctrl.basketId);
        String retVal = ctrl.performAction(bsk.id);
        System.assertEquals(true,String.isNotBlank(retVal));
        ActionReturn ret = (ActionReturn)JSON.deserialize(retVal, ActionReturn.class);
        System.assertEquals('ok',ret.status);
        System.assertEquals('Launching Order Information UI.....',ret.text);
        System.assertEquals('/apex/c__additionalOrderInformation?basketId='+bsk.id,ret.redirectURL);

		Test.stopTest();
	}

	@isTest static void testSaveAction() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		Test.startTest();
		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();        
        System.assertEquals(bsk.id,ctrl.basketId);

        ctrl.basket.Maxim_Opportunity_ID__c = '12345';
		ctrl.basket.Customer_Request_Date__c = System.today();
		ctrl.basket.Order_Description__c = 'TestDesc';
		
        PageReference retVal = ctrl.save();
        System.assertEquals(true,retVal!=null);
        System.assertEquals('/apex/csbb__basketbuilderapp?Id='+bsk.id,retVal.getUrl());

        cscfga__Product_Basket__c bskSvd = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c where id =:bsk.id LIMIT 1];

        System.assertEquals('12345',bskSvd.Maxim_Opportunity_ID__c);
        System.assertEquals('TestDesc',bskSvd.Order_Description__c);


		Test.stopTest();
	}

    @isTest static void testSaveBillingAccValidateAction_willreturn_invalid_error() {

		cscfga__Product_Basket__c bsk = [SELECT Financial_CIDN__c,Invoice_Arrangement_ID__c FROM cscfga__Product_Basket__c LIMIT 1];

		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();   
        System.assertEquals(bsk.id,ctrl.basketId);

        ctrl.basket.Maxim_Opportunity_ID__c = '12345';
		ctrl.basket.Customer_Request_Date__c = System.today();
		ctrl.basket.Order_Description__c = 'TestDesc';
        ctrl.basket.Financial_CIDN__c = '0123456789123';
        ctrl.basket.Invoice_Arrangement_ID__c = '0123456789';
        
        
		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockBillAccValidateResponseGenerator());
        PageReference retVal = ctrl.save();
        Test.stopTest();
        System.assertEquals(true,retVal==null);
		System.assert(ApexPages.hasMessages());
        
        cscfga__Product_Basket__c bskSvd = [SELECT Financial_CIDN__c,Invoice_Arrangement_ID__c FROM cscfga__Product_Basket__c where id =:bsk.id LIMIT 1];

        System.assertNotEquals('0123456789123',bskSvd.Financial_CIDN__c);
        System.assertNotEquals('0123456789',bskSvd.Invoice_Arrangement_ID__c);


	}
    
    
    @isTest static void testSaveBillingAccValidateAction_willreturn_technical_error() {

		cscfga__Product_Basket__c bsk = [SELECT Financial_CIDN__c,Invoice_Arrangement_ID__c FROM cscfga__Product_Basket__c LIMIT 1];

		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();   
        System.assertEquals(bsk.id,ctrl.basketId);

        ctrl.basket.Maxim_Opportunity_ID__c = '12345';
		ctrl.basket.Customer_Request_Date__c = System.today();
		ctrl.basket.Order_Description__c = 'TestDesc';
        ctrl.basket.Financial_CIDN__c = '0123456789124';
        ctrl.basket.Invoice_Arrangement_ID__c = '0123456788';
        
        
		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockBillAccValidateResponseGenerator());
        PageReference retVal = ctrl.save();
        Test.stopTest();
        System.assertEquals(true,retVal==null);
		System.assert(ApexPages.hasMessages());
        
        cscfga__Product_Basket__c bskSvd = [SELECT Financial_CIDN__c,Invoice_Arrangement_ID__c FROM cscfga__Product_Basket__c where id =:bsk.id LIMIT 1];

        System.assertNotEquals('0123456789124',bskSvd.Financial_CIDN__c);
        System.assertNotEquals('0123456788',bskSvd.Invoice_Arrangement_ID__c);


	}
    
     @isTest static void testSaveBillingAccValidateAction_willreturn_success_url() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();   
        System.assertEquals(bsk.id,ctrl.basketId);

        ctrl.basket.Maxim_Opportunity_ID__c = '12345';
		ctrl.basket.Customer_Request_Date__c = System.today();
		ctrl.basket.Order_Description__c = 'TestDesc';
        ctrl.basket.Financial_CIDN__c = '0123456789125';
        ctrl.basket.Invoice_Arrangement_ID__c = '0123456789';
        
        
		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockBillAccValidateResponseGenerator());
        PageReference retVal = ctrl.save();
        Test.stopTest();
        System.assertEquals(true,retVal!=null);
        
        cscfga__Product_Basket__c bskSvd = [SELECT Financial_CIDN__c,Invoice_Arrangement_ID__c FROM cscfga__Product_Basket__c where id =:bsk.id LIMIT 1];

        System.assertEquals('0123456789125',bskSvd.Financial_CIDN__c);
        System.assertEquals('0123456789',bskSvd.Invoice_Arrangement_ID__c);


	}
    
	@isTest static void testCancelAction() {

		cscfga__Product_Basket__c bsk = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c LIMIT 1];

		Test.startTest();
		
		Test.setCurrentPage(Page.additionalOrderInformation);
		ApexPages.CurrentPage().getparameters().put('basketId', String.valueOf(bsk.Id));
        CustomButtonAdditionalOrderInformation ctrl = new CustomButtonAdditionalOrderInformation();        
        System.assertEquals(bsk.id,ctrl.basketId);

	    PageReference retVal = ctrl.cancel();
        System.assertEquals(true,retVal!=null);
        System.assertEquals('/apex/csbb__basketbuilderapp?Id='+bsk.id,retVal.getUrl());

        cscfga__Product_Basket__c bskSvd = [SELECT Maxim_Opportunity_ID__c,Customer_Request_Date__c,Order_Description__c,
										 Project_Manager__c FROM cscfga__Product_Basket__c where id =:bsk.id LIMIT 1];

        System.assertEquals(null,bskSvd.Maxim_Opportunity_ID__c);
        System.assertEquals(null,bskSvd.Order_Description__c);


		Test.stopTest();
	}
	
	static void createCustomSettingValues() {
 
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Service Detailing'); 
        customSetting.Name = 'ServiceDetailing';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;

        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Valid'); 
        customSetting1.Name = 'ClosedWon';
        customSetting1.External_Id__c = 'CCO_T_2';
        insert customSetting1;

        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        customSetting2.Name = 'CancelBasket';
        customSetting2.External_Id__c = 'CCO_T_3';
        insert customSetting2;
    }  

	private class ActionReturn{
		public String status {get;set;}
		public String text {get;set;}
		public String redirectURL {get;set;}
	}
	
}