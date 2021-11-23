/*
 * @Author : Suyash Chiplunkar
 * @Date : 21 July 2020
 * @Desc : Populate RateRow in Shared data RTB
 * @Jira : DPG-1964
 * @testclass : PopulateRateCardRowsforBillingTest
   ===============================================================================================================================
   Sr.No.    Developer Name          Date            Story Description
   1       Suyash Chiplunkar       21-07-2020      Populate RateRow in Shared data RTB
   ===============================================================================================================================
 */
@IsTest public with sharing class PopulateRateCardRowsforBillingTest {
	@TestSetup static void testdata(){
		Account testAccount = PricingTestDataFactory.generateAccount();
		insert testAccount;
		// Create test Opportunity
		Opportunity testOppty = PricingTestDataFactory.generateOpportunityForAccount(testAccount);

		cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
			Name = 'IoT Shared Data 50KB',
			cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
			cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
			cspmb__Is_Active__c = true,
			cspmb__Price_Item_Code__c = 'IoT Shared Data',
			Commercial_Product_Code__c = 'IoT Shared Data', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
			cspmb__Product_Definition_Name__c = 'IoT Solutions',
			External_Id__c = 'dmcat_112',
			Charge_Id__c = 'DMCAT_RecurringCharge_000814',
			Package_Name__c = 'IoT Solution',
			BillingSpecId__c = 'BSOTC001_CB',
			Billing_Description__c = 'Plan',
			Offer_Id__c = 'DMCAT_Offer_000964',
			Plan__c = '50 KB'
			);
		insert price_item_shared_data;

		cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
		rateCard_shared_data.Name = 'IoT Shared Data 50KB';
		rateCard_shared_data.Offer_Id__c = 'DMCAT_Offer_000964';
		rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';
		rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
		rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
		rateCard_shared_data.cspmb__Is_Active__c = true;
		insert rateCard_shared_data;

		List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();

		cspmb__Rate_Card_Line__c rcl1 = new cspmb__Rate_Card_Line__c();
		rcl1.toUnit__c = 499;
		rcl1.fromUnit__c = 1;
		rcl1.cspmb__Rate_Card__c = rateCard_shared_data.id;
		rcl1.cspmb__Effective_Start_Date__c = Date.today()-1;
		rcl1.cspmb__Effective_End_Date__c = Date.today()+1;
		rcl1.cspmb__rate_value__c = 1.5;
		rateCardLineList.add(rcl1);

		cspmb__Rate_Card_Line__c rcl2 = new cspmb__Rate_Card_Line__c();
		rcl2.toUnit__c = 999;
		rcl2.fromUnit__c = 500;
		rcl2.cspmb__Rate_Card__c = rateCard_shared_data.id;
		rcl2.cspmb__Effective_Start_Date__c = Date.today()-1;
		rcl2.cspmb__Effective_End_Date__c = Date.today()+1;
		rcl2.cspmb__rate_value__c = 2.5;
		rateCardLineList.add(rcl2);

		cspmb__Rate_Card_Line__c rcl3 = new cspmb__Rate_Card_Line__c();
		rcl3.toUnit__c = 2499;
		rcl3.fromUnit__c = 1000;
		rcl3.cspmb__Rate_Card__c = rateCard_shared_data.id;
		rcl3.cspmb__Effective_Start_Date__c = Date.today()-1;
		rcl3.cspmb__Effective_End_Date__c = Date.today()+1;
		rcl3.cspmb__rate_value__c = 3.5;
		rateCardLineList.add(rcl3);
		insert rateCardLineList;

		cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
		sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
		sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
		insert sharedDataassociation;

		Account acc = new Account();
		acc.Name = 'testacc';
		acc.CIDN__c = '1234567891';
		acc.ABN__c = '1235';
		acc.Customer_Status__c = 'ACTIVE';
		insert acc;

		Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
		insert contact;

		Opportunity testOpp = ProductTestFactory.getOpportunityBasic(acc);
		testOpp.StageName = 'Define';
		testOpp.CloseDate = System.Date.today();
		insert testOpp;

		Marketable_Offer__c mOffer = new Marketable_Offer__c();
		mOffer.Offer_ID__c = 'DMCAT_Offer_000964';
		mOffer.Invoice_Definition__c = 'Invoice_Def_2';
		mOffer.Auto_Expired_Entity__c = true;
		insert mOffer;

		cscrm__Address__c address = new cscrm__Address__c();
		address.Name = 'Unit 1 1234 Lostmy Way';
		address.Address_Line_1__c = 'Unit 4 Mahatma';
		address.Locality__c = 'Sydney';
		address.cscrm__Zip_Postal_Code__c = '2000';
		address.cscrm__State_Province__c = 'NSW';
		address.cscrm__Country__c = 'Australia';
		address.cscrm__Street_Name__c = 'Melbourne';
		insert address;

		cscrm__Site__c site = AccountTestFactory.buildSite(address.Id, acc.Id);
		site.Primary_Contact__c = contact.Id;
		site.cscrm__Installation_Address__r = address;
		insert site;

		Billing_Account__c billingAccount = new Billing_Account__c();
		billingAccount.Billing_Account_Number__c = '123456789322';
		billingAccount.Billing_Address__c = address.id;
		billingAccount.Billing_Account_Owner__c = contact.Id;
		billingAccount.Account__c = acc.Id;
		insert billingAccount;

		cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
		productDefinition.Name = 'IoT Solution';
		productDefinition.cscfga__Description__c = 'Test Product Definition Description';
		productDefinition.product_Specification__c = 'DMCAT_Offer_000964';
		insert productDefinition;

		cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name = 'Test Originating offer',offer_spec_id__c = 'DMCAT_Offer_000964');
		insert OriginatingOffer;

		cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
		productConfig.Offer_Reference__c = OriginatingOffer.id;
		productConfig.cscfga__Product_Definition__c = productDefinition.Id;
		productConfig.ConfigurationType1__c = 'SolutionComponent';
		productConfig.Remaining_Term__c  = 24;
		insert productConfig;

		csord__Order__c ord = new csord__Order__c();
		ord.csord__Identification__c = 'test identification';
		ord.csord__Account__c = acc.id;
		ord.csord__Order_Type__c = 'test order';
		ord.Billing_Account__c = billingAccount.id;
		insert ord;

		csord__Order__c secOrd = new csord__Order__c();
		secOrd.csord__Identification__c = 'test identification';
		secOrd.csord__Account__c = acc.id;
		secOrd.csord__Order_Type__c = 'test order';
		secOrd.Billing_Account__c = billingAccount.id;
		secOrd.csord__Primary_Order__c = ord.id;
		secOrd.csordtelcoa__Opportunity__c = testOpp.id;
		insert secOrd;

		List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
		csord__Subscription__c subsL = new csord__Subscription__c();
		subsL.name  = 'IOT Subs 1';
		subsL.csord__Identification__c = 'test identityL';
		subsL.Site__c = site.Id;
		subsL.csord__Status__c = 'Subscription Created';
		subsL.csordtelcoa__Subscription_Number__c = 'SN-000003199';
		subsL.csord__Order__c = secOrd.id;
		subsL.csordtelcoa__Product_Configuration__c = productConfig.id;
		subsL.Billing_Account__c = billingAccount.id;
		subsL.Offer__c = OriginatingOffer.Id;
		subsList.add(subsL);

		csord__Subscription__c subsK = new csord__Subscription__c();
		subsK.name  = 'IOT Subs 2';
		subsK.csord__Identification__c = 'test identityK';
		subsK.Site__c = site.Id;
		subsK.csord__Status__c = 'Subscription Created';
		subsK.csordtelcoa__Subscription_Number__c = 'SN-000003199';
		subsK.csord__Order__c = secOrd.id;
		subsK.csordtelcoa__Product_Configuration__c = productConfig.id;
		subsK.Billing_Account__c = billingAccount.id;
		subsK.Offer__c = OriginatingOffer.Id;
		subsK.csordtelcoa__Replaced_Subscription__c = subsL.Id;
		subsK.MarketableOffer__c = mOffer.id;
		subsList.add(subsK);
		insert subsList;

		csord__Service__c servK = new csord__Service__c();
		servK.name = 'tst serviceK';
		servK.csord__Identification__c  = 'test identify';
		servK.csord__Subscription__c  = subsK.id;
		servK.csord__Order__c = ord.id;
		servK.csordtelcoa__Service_Number__c = 'SVC-200000';
		servK.Scenario_Type__c = 'Change of Mobile Number';
		insert servK;

		Attachment attK = new Attachment();
		attK.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000964_DMCAT_Allowance_001078","productConfigurationId":"a3T5P00000024MrUAI","name":"964_AW_1078","metadata":{},"instanceId":"","includeBilling":false,"guid":"8f32323c-cd5b-4036-4edd-f9563f9b078a","endDate":"","description":"IoT solutions_Billing_DMCAT_Allowance_0001078","code":"DMCAT_ProductSpecification_000964_Billing_Allowance_001078","attributes":{"sharedPlanId":"'+price_item_shared_data.id+'","billDescription":"IOT Shared Data Plan 50KB","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_USAGE","type":"Shared Data","unitofMeasure":"KB","value":"50","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+ servK.id +'","legacyAttributes":[]}');
		attK.Name = 'ServiceSpecifications.json';
		attK.ParentId = servK.Id;
		insert attK;

	}

	@isTest
	static void testpopulateBillingSpecificationsIOT(){
		Test.startTest();
		csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'IOT Subs 2'];
		cspmb__Price_Item__c price_item_shared_data = [Select Name From cspmb__Price_Item__c where Name = 'IoT Shared Data 50KB'];
		BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
		Map<String,List<CS_SpecificationDTO.ServiceSpecification> > servSpecList = BillingOrderServiceUtil.getAllServSpecs(sub.id);
		String specode = '"DMCAT_ProductSpecification_000964"';
		String servId = 'SVC-200000';
		BillingSpecDTOV2.BillingSpecifications billingspecification = new BillingSpecDTOV2.BillingSpecifications();
		Map<Id, List<BillingSpecDTOV2.CustomRate> >  RateCardMap = PopulateRateCardRowsforBilling.getRateCardItems('DMCAT_Offer_000964');
		List<BillingSpecDTOV2.CustomRate> card = PopulateRateCardRowsforBilling.addRateCardRowsToBillingSpecs(billingspecification, servSpecList.values()[0][0], 'DMCAT_Offer_000964', RateCardMap);
		Test.stopTest();
		//Positive
		System.assertEquals(RateCardMap.get(price_item_shared_data.id), card);
		System.assertEquals(card[0].toUnit, '499');
		//Negative
		System.assertNotEquals(card[0].unitPrice, '2');
	}
}