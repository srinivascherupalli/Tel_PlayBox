/*
===============================================================================================================================

Test Class : EDGE-116138 - RateMatrixMSControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        Laxmi  14/10/2019     Edge-116138 conroller for Lightining Page to show Rate Card
===============================================================================================================================
*/
@IsTest

 

private class RateMatrixMSControllerTest {

@TestSetup
  private static void testSetup()
  {
          
    cspmb__Price_Item__c testRateMatrix = new cspmb__Price_Item__c();
    testRateMatrix.offer_id__C = 'DMCAT_Offer_000854';
    testRateMatrix.rangeTo__C = '1000';
    testRateMatrix.rangeFrom__c = '1'; 
    testRateMatrix.cspmb__Recurring_Charge__c = 10;
    testRateMatrix.External_Id__c = 'Charge_000851';
    testRateMatrix.Feature_Level__c = 'Advanced';
    testRateMatrix.Technical_Support__c = '24x7';
    testRateMatrix.Type__c = 'TMDM';

      
    insert testRateMatrix;
      
              
    cspmb__Price_Item__c testRateMatrix2 = new cspmb__Price_Item__c();
    testRateMatrix2.offer_id__C = 'DMCAT_Offer_000854';
    testRateMatrix2.rangeTo__C = '1000';
    testRateMatrix2.rangeFrom__c = '1'; 
    testRateMatrix2.cspmb__Recurring_Charge__c = 10;
    testRateMatrix2.External_Id__c = 'Charge_0008511';
    testRateMatrix2.Feature_Level__c = 'Standard';
    testRateMatrix2.Technical_Support__c = '24x7';
    testRateMatrix2.Type__c = 'TMDM';

      
    insert testRateMatrix2;  
      
      
    cspmb__Price_Item__c testRateMatrix1 = new cspmb__Price_Item__c();
    testRateMatrix1.offer_id__C = 'DMCAT_Offer_000854';
    testRateMatrix1.rangeTo__C = '1000';
    testRateMatrix1.rangeFrom__c = '1'; 
    testRateMatrix1.cspmb__Recurring_Charge__c = 10;
    testRateMatrix1.External_Id__c = 'Charge_000852';
    testRateMatrix1.Feature_Level__c = 'Standard';
    testRateMatrix1.Technical_Support__c = 'Bus Hrs';
    testRateMatrix1.Type__c = 'EU';

      
    insert testRateMatrix1;      
      
    
      
  }
  @IsTest
  private static void testGetData()
  {
      
      //Map<String,Object> numberMap = new Map<String,Object>();
      //numberMap.put('externalId', '000851');
      String externalId = '000851';
      //RateMatrixForManagedServicesController rateMatrixForManagedServicesController = new RateMatrixForManagedServicesController();
      Test.startTest();
      List<RateMatrixForManagedServicesController.ChargeRateCardDTO>  chargeRateCardDTOList= RateMatrixForManagedServicesController.getRateCard(externalId,'','');
      
      Test.stopTest();
      System.assertNotEquals(null, chargeRateCardDTOList );

  }
    
    
    
  @isTest static void testSubWrapper(){
    RateMatrixForManagedServicesController.ChargeRateCardDTO chargeRateCardDTO = new RateMatrixForManagedServicesController.ChargeRateCardDTO();
    chargeRateCardDTO.featureLevel = 'Advanced';
    chargeRateCardDTO.techSupport = '24x7';
    chargeRateCardDTO.rangeSTDBUSCharge = 8;
    chargeRateCardDTO.rangeSTD24X7Charge = 9;
    chargeRateCardDTO.rangeADVBUSCharge= 10;
    chargeRateCardDTO.rangeADV24X7Charge= 11;
    chargeRateCardDTO.type= 'End User';
    chargeRateCardDTO.rangeFrom = '1';
    chargeRateCardDTO.rangeTo='1000';
    chargeRateCardDTO.recurringCharge=10;
    chargeRateCardDTO.externalId = 'DMCAT_ProductSpecification_000851';
    system.assertNotEquals(chargeRateCardDTO, null);
  }
}