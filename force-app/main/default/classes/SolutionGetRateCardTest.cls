/* ****************************************************************************
 * Author : Venkata Ramanan G(CloudSense)
 * Date :    21 Sept 2019
 * Description : Test Classes to get Ratecard for NgUC MTS Build - EDGE 107435
 * *****************************************************************************/

@isTest
public class SolutionGetRateCardTest {
	@testSetup
	static void testData(){
		cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
		insert pd;
		System.assertNotEquals(null,pd);

		cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Plan',324,564.23,'User','Commercial');
		commercialPrd.Offer_Id__c = 'DMCAT_Offer_000618';
		//commercialPrd.Plan__c ='Premium';
		commercialPrd.Model__c = 'CISCO Modem';
		commercialPrd.cspmb__Effective_End_Date__c  = system.today()+30;
		commercialPrd.cspmb__Effective_Start_Date__c  = system.today();
		commercialPrd.cspmb__Price_Item_Code__c = 'Broadsoft Product';
		commercialPrd.Commercial_Product_Code__c = 'Broadsoft Product'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		insert commercialPrd;
		System.assertNotEquals(null,commercialPrd);

	}

	@isTest
	static void getdata(){
		cspmb__Price_Item__c commercialProd = [SELECT id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c
		                                       FROM cspmb__Price_Item__c
		                                       WHERE Name = 'New Plan'];

		Map<String,String> searchFields = new Map<String,String>();
		searchFields.put('Offer_Id__c',commercialProd.Offer_Id__c);
		searchFields.put('Commercial_Product_Code__c',commercialProd.Commercial_Product_Code__c);     //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		searchFields.put('Plan__c','');
		//cscfga__Product_Definition__c pd =[Select Id, Name From cscfga__Product_Definition__c where Name='Network Product'];
		List<Id> excludeIds = new List<Id>();

		SolutionGetRateCard getdata = new SolutionGetRateCard();
		// getdata.getRequiredAttributes();
		Map<String,Object> lookupResult = SolutionGetRateCard.getData(searchFields);
		System.assertEquals(true,lookupResult != null);

	}
}