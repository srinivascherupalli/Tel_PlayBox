/*******************************************************************
   @Author : Venkata Ramanan G (CloudSense)
   @Description : Lookup Custom class/Remote action class to fetch the Vendor values in tenancy model
   @Release : Sprint 19.14 - EDGE - 117274

* 1       04-11-2019      EDGE- 117274    Created for Tenancy Offer to fetch Vendor
*******************************************************************/

@isTest
public class CSTenancyVendorlookupTest {
	@testSetup
	static void testData(){
		cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
		insert pd;
		System.assertNotEquals(null,pd);

		cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Device',324,564.23,'User','Commercial');
		commercialPrd.Offer_Id__c = 'Offer1';
		commercialPrd.Type__c = 'Modem';
		commercialPrd.Model__c = 'CISCO Modem';
		commercialPrd.cspmb__Price_Item_Code__c = 'NET01';
		commercialPrd.Commercial_Product_Code__c = 'NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		commercialPrd.Vendor__c = 'VmWare';
		insert commercialPrd;
		System.assertNotEquals(null,commercialPrd);

	}

	@isTest
	static void lookupSearchforVendor(){
		cspmb__Price_Item__c commercialProd = [SELECT id,Name, Vendor__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
		                                       FROM cspmb__Price_Item__c
		                                       WHERE Name = 'New Device'];

		Map<String,String> searchFields = new Map<String,String>();
		searchFields.put('OfferId',commercialProd.Offer_Id__c);

		cscfga__Product_Definition__c pd = [SELECT Id, Name FROM cscfga__Product_Definition__c WHERE Name = 'Network Product'];
		List<Id> excludeIds = new List<Id>();

		CSTenancyVendorlookup TenancyLookup = new CSTenancyVendorlookup();
		TenancyLookup.getRequiredAttributes();
		Object[] lookupResult = TenancyLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
		CSTenancyVendorlookup.getData(searchFields);
		System.assertEquals(true,lookupResult != null);

	}
	@isTest
	static void lookupsearchnegativecheck(){
		cspmb__Price_Item__c commercialProd = [SELECT id,Name, Vendor__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
		                                       FROM cspmb__Price_Item__c
		                                       WHERE Name = 'New Device'];

		Map<String,String> searchFields = new Map<String,String>();
		//searchFields.put('OfferId',commercialProd.Offer_Id__c);

		cscfga__Product_Definition__c pd = [SELECT Id, Name FROM cscfga__Product_Definition__c WHERE Name = 'Network Product'];
		List<Id> excludeIds = new List<Id>();

		CSTenancyVendorlookup TenancyLookup = new CSTenancyVendorlookup();
		TenancyLookup.getRequiredAttributes();
		Object[] lookupResult = TenancyLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
		CSTenancyVendorlookup.getData(searchFields);
		System.assertEquals(true,lookupResult == null);

	}
}