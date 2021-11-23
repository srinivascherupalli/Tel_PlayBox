/*******************************************************************
   @Author : Venkata Ramanan G (CloudSense)
   @Description : Test Class for Lookup Custom class to fetch the Calling Plan in Telstra Colloboration Solution- MTS Version
   @Release : Sprint 19.13 - EDGE - 108257
   @Created Date :   23-Sept-2019
   @modified : Shubhi EDge-120919 21-4-2020 updated query added mode__c
*******************************************************************/

@isTest
public class CS_UC_CallingPlanLookupCustomTest {
	@testSetup
	static void testData(){
		cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
		insert pd;
		System.assertNotEquals(null,pd);
		List<cspmb__Price_Item__c> comProdList=new List<cspmb__Price_Item__c>();
		cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Plan',324,564.23,'User','Commercial');
		commercialPrd.Offer_Id__c = 'Offer1';
		commercialPrd.Mode__C='Shared Lines';//EDge-120919
		commercialPrd.Plan__c ='Standard';
		commercialPrd.Model__c ='CISCO Modem';
		commercialPrd.cspmb__Price_Item_Code__c='NET01';
		commercialPrd.Commercial_Product_Code__c='NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		commercialPrd.cspmb__Effective_Start_Date__c=Date.newInstance(2008, 1, 30);
		commercialPrd.cspmb__Effective_End_Date__c=Date.newInstance(2008, 1, 30);
		comProdList.add(commercialPrd);
		cspmb__Price_Item__c commercialPrd1 = ProductTestFactory.buildPriceItem('New Plan 1',324,564.23,'User','Commercial');
		commercialPrd1.Offer_Id__c = 'Offer1';
		commercialPrd.Mode__C='Shared Lines';//EDge-120919
		commercialPrd1.Plan__c ='Premium';
		commercialPrd1.Model__c ='CISCO Modem';
		commercialPrd1.cspmb__Price_Item_Code__c='NET01';
		commercialPrd1.Commercial_Product_Code__c='NET01'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		commercialPrd1.cspmb__Effective_Start_Date__c=Date.today();
		commercialPrd1.cspmb__Effective_End_Date__c=Date.today()+4;
		comProdList.add(commercialPrd1);
		insert comProdList;
		//added profile and user for edge-120919
		Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
		User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
		                      lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
		                      profileid = pf.id,
		                      timezonesidkey='Australia/Sydney',
		                      username='salesuser@testsales.com',phone='+121231231234');
		insert sales;
	}

	@isTest
	static void lookupSearchforPlan(){
		Test.startTest();
		User Sales=[Select id from user where username='salesuser@testsales.com'];
		System.runAs(Sales){
			cspmb__Price_Item__c commercialProd= [SELECT id,Name,Mode__c,Plan__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
			                                      FROM cspmb__Price_Item__c
			                                      WHERE Name='New Plan 1'];//added mode 120919
			Map<String,String> searchFields = new Map<String,String>();
			searchFields.put('OfferId',commercialProd.Offer_Id__c);
			searchFields.put('ModeString',commercialProd.Mode__c);
			searchFields.put('searchValue','');
			cscfga__Product_Definition__c pd =[Select Id, Name From cscfga__Product_Definition__c where Name='Network Product'];
			List<Id> excludeIds = new List<Id>();

			CS_UC_CallingPlanLookupCustom UCPlanLookup = new CS_UC_CallingPlanLookupCustom();
			UCPlanLookup.getRequiredAttributes();
			Object[] lookupResult = UCPlanLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
			List<cspmb__Price_Item__c> resultList=(List<cspmb__Price_Item__c>)lookupResult;
			System.assertEquals(true,lookupResult!=null);
			System.assertEquals(true,resultList[0].Plan__c=='Premium');
		}
		Test.stopTest();
	}
	@isTest
	static void lookupSearchforPlanNegative(){
		Test.startTest();
		User Sales=[Select id from user where username='salesuser@testsales.com'];
		System.runAs(Sales){
			cspmb__Price_Item__c commercialProd= [SELECT id,Name,Mode__c, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
			                                      FROM cspmb__Price_Item__c
			                                      WHERE Name='New Plan'];

			system.debug('commercialProd-->'+commercialProd);
			Map<String,String> searchFields = new Map<String,String>();
			searchFields.put('OfferId',commercialProd.Offer_Id__c);
			searchFields.put('ModeString',commercialProd.Mode__c);
			searchFields.put('searchValue','Standard');
			cscfga__Product_Definition__c pd =[Select Id, Name From cscfga__Product_Definition__c where Name='Network Product'];
			List<Id> excludeIds = new List<Id>();
			CS_UC_CallingPlanLookupCustom UCPlanLookup = new CS_UC_CallingPlanLookupCustom();
			UCPlanLookup.getRequiredAttributes();
			Object[] lookupResult = UCPlanLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);

			System.assertEquals(0,lookupResult.size());
		}
		Test.stopTest();
	}
	//Edge- 120919 start//
	@isTest
	static void lookupSearchforMode(){
		Test.startTest();
		User Sales=[Select id from user where username='salesuser@testsales.com'];
		System.runAs(Sales){
			cspmb__Price_Item__c commercialProd= [SELECT id,Name,Mode__c,Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
			                                      FROM cspmb__Price_Item__c
			                                      WHERE Name='New Plan 1'];

			Map<String,String> searchFields = new Map<String,String>();
			searchFields.put('OfferId',commercialProd.Offer_Id__c);
			searchFields.put('searchValue','');
			cscfga__Product_Definition__c pd =[SELECT Id, Name FROM cscfga__Product_Definition__c WHERE Name='Network Product'];
			List<Id> excludeIds = new List<Id>();

			CS_UC_CallingPlanLookupCustom UCPlanLookup = new CS_UC_CallingPlanLookupCustom();
			UCPlanLookup.getRequiredAttributes();
			Object[] lookupResult = UCPlanLookup.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);
			List<cspmb__Price_Item__c> resultList=(List<cspmb__Price_Item__c>)lookupResult;
			System.assertEquals(false,resultList[0].Mode__c=='Shared Lines');
		}
		Test.stopTest();
	}
	//Edge- 120919 start//
}