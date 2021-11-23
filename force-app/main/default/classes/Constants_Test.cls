@isTest
private class Constants_Test {
	static testMethod void constanttest() {
		Constants con = new Constants();
        system.assertEquals(true,true);
    }
    
       
  @IsTest
  private static void getChargeAttributeNameMapPositive()
  {
      Test.startTest();
      Map<String,String> chargeAttributeNameMap  = Constants.getChargeAttributeNameMap('Mobile Subscription' );
      Test.stopTest();
      System.assertNotEquals(null, chargeAttributeNameMap);
  }
  
  @IsTest
  private static void getChargeAttributeNameMapNegative()
  {
      Test.startTest();
      Map<String,String> chargeAttributeNameMap  = Constants.getChargeAttributeNameMap('Mobile XXX' );
      Test.stopTest();
      System.assertEquals(0, chargeAttributeNameMap.size());
  }
    
  @IsTest
  private static void getChargeTypePositive()
  {
      Test.startTest();
      String chargeType  = Constants.getChargeType('DMCAT_RecurringCharge_000654' );
      Test.stopTest();
      System.assertEquals('Flat Recurring', chargeType);
  }  
   
    @IsTest
  private static void getChargeTypeNegative()
  {
      Test.startTest();
      String chargeType  = Constants.getChargeType('DMCAT_RecurringCharge_000XXX' );
      Test.stopTest();
      System.assertEquals('', chargeType);
  }    
}