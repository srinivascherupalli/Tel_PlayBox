/*************************************************************************************************
Name : MockPublishPricingMSResponseHandlerTest
EDGE-128910 : Building mock logic to mimic MS response in absence of stub/actual MS
Description : Test class for MockPublishPricingMSResponseHandle
===============================================================================================================================
Sr.No.    Developer Name      Date           Story Description
1.        Pawan Devaliya      23-Dec-2019     Created
===============================================================================================================================
***************************************************************************************************/

@isTest
private class MockPublishPricingMSResponseHandlerTest{

 @testSetup
 public static void testdatasetup(){
        
    List<Charge_Line_Item__c> chargeLineItemList = new List<Charge_Line_Item__c>();
            
            Charge_Line_Item__c chargeLineItem = new Charge_Line_Item__c();
            chargeLineItem.CorrelationId__c = '234';
            
            chargeLineItemList.add(chargeLineItem);

            Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c();
            chargeLineItem1.CorrelationId__c = '234';
            
            chargeLineItemList.add(chargeLineItem1);

            Charge_Line_Item__c chargeLineItem2 = new Charge_Line_Item__c();
            chargeLineItem2.CorrelationId__c = '567';
            
            chargeLineItemList.add(chargeLineItem2);

            Charge_Line_Item__c chargeLineItem3 = new Charge_Line_Item__c();
            chargeLineItem3.CorrelationId__c = '567';
            
            chargeLineItemList.add(chargeLineItem3);
            
            Charge_Line_Item__c chargeLineItem4 = new Charge_Line_Item__c();
            chargeLineItem4.CorrelationId__c = '789';
            
            chargeLineItemList.add(chargeLineItem4);
            
            insert(chargeLineItemList);
            
    }

@isTest
private static void handleAllInsertTest(){
    
    Set<String> corelationIdSet = new Set<String>();
    Map<String, List<String>> chargeLineItemIdCLiIdMap = new Map<String, List<String>>();
    corelationIdSet.add('234');
    
    Test.startTest();
    MockPublishPricingMSResponseHandler.handleAllInsert(corelationIdSet);
    chargeLineItemIdCLiIdMap = MockPublishPricingMSResponseHandler.getChargeLineItemIdCLiIdMap(corelationIdSet);
    Test.stopTest();
    System.debug('Pawan size '+chargeLineItemIdCLiIdMap.size());
    System.assertEquals(2, chargeLineItemIdCLiIdMap.get('234').size(), 'Size of Map returned');
}
    
@isTest
private static void mockResponseTest(){
    
    Set<String> corelationIdSet = new Set<String>();
    Map<String, List<String>> chargeLineItemIdCLiIdMap = new Map<String, List<String>>();
    corelationIdSet.add('234');
    
    Test.startTest();
    MockPublishPricingMSResponseHandler.mockResponse(corelationIdSet);
    chargeLineItemIdCLiIdMap = MockPublishPricingMSResponseHandler.getChargeLineItemIdCLiIdMap(corelationIdSet);
    Test.stopTest();
    System.debug('Pawan size '+chargeLineItemIdCLiIdMap.size());
    System.assertEquals(2, chargeLineItemIdCLiIdMap.get('234').size(), 'Size of Map returned');
}

@isTest
private static void generatePricingMSResponseTest(){

    PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
    Set<String> corelationIdSet = new Set<String>();
    corelationIdSet.add('567');
    Charge_Line_Item__c chargeLineItem = [Select id, CorrelationId__c from Charge_Line_Item__c where CorrelationId__c in: corelationIdSet limit 1];
    
    pricingMSResponse = MockPublishPricingMSResponseHandler.generatePricingMSResponse(chargeLineItem.id, '567');
    
    System.assertNotEquals(null, pricingMSResponse, 'pricingMSResponse should contain response object to insert');
}   

@isTest
private static void getChargeLineItemIdCLiIdMapTest(){

    PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
    Set<String> corelationIdSet = new Set<String>();
    corelationIdSet.add('234');
    corelationIdSet.add('567');
    corelationIdSet.add('789');
        
    Map<String, List<String>> chargeLineItemIdCLiIdMap = MockPublishPricingMSResponseHandler.getChargeLineItemIdCLiIdMap(corelationIdSet);
    
    System.assertEquals(3, chargeLineItemIdCLiIdMap.size(), 'chargeLineItemIdCLiIdMap is returned by method');
}

@isTest
private static void generatePricingMSResponseNullTest(){

    PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
   
    pricingMSResponse = MockPublishPricingMSResponseHandler.generatePricingMSResponse(null, null);
    
    System.assertEquals(null, pricingMSResponse, 'pricingMSResponse should be null');
} 


}