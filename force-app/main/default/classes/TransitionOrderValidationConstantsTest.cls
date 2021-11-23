@isTest
public with sharing class TransitionOrderValidationConstantsTest {
  @isTest static void test_getRecordType(){
    String result = TransitionOrderValidationConstants.getRecordType('router');
    System.assert(result == 'Device');
  }

  @isTest static void test_getUserType(){
    String result = TransitionOrderValidationConstants.getUserType('b2b');
    System.assert(result == 'B2B Alarm');
  }

  @isTest static void test_getPlan(){
    String result = TransitionOrderValidationConstants.getPlan('DOT TBV');
    System.assert(result == 'DOT');
  }

  @isTest static void test_getPriceList(){
    cspmb__Price_Item__c priceItem = TestDataFactory.generatePriceItem();
    String result = TransitionOrderValidationConstants.getPriceList('Price Test');
    System.assert(result == priceItem.Id);
  }
}