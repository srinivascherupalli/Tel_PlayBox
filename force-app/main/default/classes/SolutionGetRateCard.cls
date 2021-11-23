/* ****************************************************************************
 * Author : Venkata Ramanan G(CloudSense)
 * Date :    21 Sept 2019
 * Description : Classes to get Ratecard for NgUC MTS Build - EDGE 107435
 * *****************************************************************************/
global with sharing class SolutionGetRateCard implements cssmgnt.RemoteActionDataProvider {

	@RemoteAction
	global static Map<String,Object> getData(Map<String,Object> inputMap) {
		Map<String, Object> returnMap = new Map<String, Object>();
		// Set<String> inputKey = inputMap.keySet();
		String offerid = (inputMap.containsKey('Offer_Id__c') && inputMap.get('Offer_Id__c') != '')? (String)inputMap.get('Offer_Id__c'):'';
		String plan = (inputMap.containsKey('Plan__c') && inputMap.get('Plan__c') != '')? (String)inputMap.get('Plan__c'):'';
		//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		String priceitemcode = (inputMap.containsKey('Commercial_Product_Code__c') && inputMap.get('Commercial_Product_Code__c') != '')? (String)inputMap.get('Commercial_Product_Code__c'):'';

		list<cspmb__Price_Item__c> priceItem = [SELECT id, rangeFrom__c,rangeTo__C,cspmb__Recurring_Charge__c,Billing_Description__c
		                                        FROM cspmb__Price_Item__c
		                                        WHERE Commercial_Product_Code__c = :priceitemcode
		                                            AND Offer_Id__c = :offerid
		                                            AND Plan__c =:plan
		                                            AND cspmb__Effective_End_Date__c >= TODAY
		                                            AND cspmb__Effective_Start_Date__c <= TODAY
		                                            ORDER BY rangeTo__c ASC];

		if (priceItem != null) {
			returnMap.put('UCRateCard', priceItem);
		}

		return returnMap;
	}

}