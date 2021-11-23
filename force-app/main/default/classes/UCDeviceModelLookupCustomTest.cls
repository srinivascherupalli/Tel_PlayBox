/*******************************************************************
   @Author : Venkata Ramanan G (CloudSense)
   @Description : Lookup Custom class to fetch the Device/Accessory Type & Model in Telstra Colloboration Solution
   @Release : Sprint 19.12 - EDGE - 93255

   S.No.  Date         User Story     Description
   1      23-09-2019   EDGE-108257    Added few fields in SOQL for NgUC MTS Build
   2      04-02-2020   EDGE-133963    Charge_Id__c added in SOQL query by Aman Soni for NGUC pricing
   3      05-02-2020   EDGE-139224     check todays date condition  in query
*******************************************************************/
@isTest
public class UCDeviceModelLookupCustomTest {
	@testSetup
	static void testData(){
		cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
		insert pd;
		System.assertNotEquals(null,pd);
		List<cspmb__Price_Item__c> comProdList = new List<cspmb__Price_Item__c>();
		cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Device',324,564.23,'User','Commercial');
		commercialPrd.Offer_Id__c = 'Offer1';
		commercialPrd.Type__c = 'Modem';
		commercialPrd.Model__c = 'CISCO Modem';
		commercialPrd.cspmb__Price_Item_Code__c = 'NET01';
		commercialPrd.Commercial_Product_Code__c = 'NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		commercialPrd.cspmb__Effective_Start_Date__c = Date.today();
		commercialPrd.cspmb__Effective_End_Date__c = Date.today()+4;
		comProdList.add(commercialPrd);
		cspmb__Price_Item__c commercialPrd1 = ProductTestFactory.buildPriceItem('New Device1',324,564.23,'User','Commercial');
		commercialPrd1.Offer_Id__c = 'Offer1';
		commercialPrd1.Type__c = 'Modem1';
		commercialPrd1.Model__c = 'CISCO Modem';
		commercialPrd1.cspmb__Price_Item_Code__c = 'NET01';
		commercialPrd1.Commercial_Product_Code__c = 'NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		commercialPrd1.cspmb__Effective_Start_Date__c = Date.newInstance(2008, 1, 30);
		commercialPrd1.cspmb__Effective_End_Date__c = Date.newInstance(2099, 1, 30);
		comProdList.add(commercialPrd1);
		insert comProdList;
	}

	@isTest
	static void lookupSearchforType(){
		cspmb__Price_Item__c commercialProd = [Select id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

		Map<String,String> searchFields = new Map<String,String>();
		searchFields.put('OfferId',commercialProd.Offer_Id__c);
		searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		searchFields.put('searchValue','Modem');

		cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
		List<Id> excludeIds = new List<Id>();

		UCDeviceModelLookupCustom UCDeviceModelLookup = new UCDeviceModelLookupCustom();
		UCDeviceModelLookup.getRequiredAttributes();
		Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
		List<cspmb__Price_Item__c> resultList = (List<cspmb__Price_Item__c>)lookupResult;
		System.assertEquals(true,lookupResult != null);
		//System.assertEquals(true,resultList[0].Check_todays_date__c == true);
	}
	@isTest
	static void lookupSearchforModel(){
		cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];

		Map<String,String> searchFields = new Map<String,String>();
		searchFields.put('OfferId',commercialProd.Offer_Id__c);
		searchFields.put('ItemCode',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		searchFields.put('TypeName',commercialProd.Type__c);
		searchFields.put('searchValue','Modem');

		cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
		List<Id> excludeIds = new List<Id>();

		UCDeviceModelLookupCustom UCDeviceModelLookup = new UCDeviceModelLookupCustom();
		Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
		List<cspmb__Price_Item__c> resultList = (List<cspmb__Price_Item__c>)lookupResult;
		System.assertEquals(true,lookupResult != null);
		//System.assertEquals(true,resultList[0].Check_todays_date__c == true);
	}
	@isTest
	static void lookupSearchNegativeScenario(){
		cspmb__Price_Item__c commercialProd = [Select id,Name, Type__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name = 'New Device'];
		commercialProd.cspmb__Effective_Start_Date__c = Date.newInstance(2008, 1, 30);
		commercialProd.cspmb__Effective_End_Date__c = Date.newInstance(2008, 1, 30);
		update commercialProd;
		Map<String,String> searchFields = new Map<String,String>();
		searchFields.put('OfferId','negative');
		searchFields.put('ItemCode','negative');
		searchFields.put('TypeName','negative');
		searchFields.put('searchValue','negative');

		cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
		List<Id> excludeIds = new List<Id>();

		UCDeviceModelLookupCustom UCDeviceModelLookup = new UCDeviceModelLookupCustom();
		Object[] lookupResult = UCDeviceModelLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
		System.assertEquals(0,lookupResult.size());
	}

}