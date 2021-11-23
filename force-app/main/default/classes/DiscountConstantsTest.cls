/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : DiscountConstantsTest  
* @Jira : //Edge-135837
// modified by shubhi Edge-143527
// modified by shubhi Edge-120919
// Modified by Ila DPG-1513
*/
@isTest
public class DiscountConstantsTest {
    
    @IsTest
    public static void GetDiscountConstBasedonSolNameTestPositive()
    {
      Test.startTest();
        Map<String,String> discountConstBasedonSolName= DiscountConstants.GetDiscountConstBasedonSolName('Mobile Subscription');
        System.assertEquals('Select Plan', discountConstBasedonSolName.get('commercialProductIdentifier'));
        discountConstBasedonSolName= DiscountConstants.GetDiscountConstBasedonSolName('Unified Communication Device');
        System.assertEquals('ContractType', discountConstBasedonSolName.get('commercialProductIdentifier'));
      Test.stopTest();
    }
    @IsTest
    public static void GetDiscountConstBasedonSolNameTestNegative()
    {
      Test.startTest();
      Map<String,String> discountConstBasedonSolName  = DiscountConstants.GetDiscountConstBasedonSolName('Mobile XXX' );
      Test.stopTest();
      System.assertEquals(0, discountConstBasedonSolName.size());
    }
    @IsTest
    public static void getChargeAttributeNameMapPositive()
    {
        Test.startTest();
        Map<String,String> chargeAttributeNameMap  = DiscountConstants.getChargeAttributeNameMap('Mobile Subscription' );
        Test.stopTest();
        System.assertEquals('PlanShadowTCV', chargeAttributeNameMap.get('DMCAT_RecurringCharge_000654'));   
        chargeAttributeNameMap  = DiscountConstants.getChargeAttributeNameMap('Unified Communication Device' ); 
        System.assertEquals('deviceShadowRCTCV', chargeAttributeNameMap.get('DMCAT_RecurringCharge_000857'));
    }
    @IsTest
    public static void getChargeAttributeNameMapForNGUCVoice()
    {
        Test.startTest();
        Map<String,String> chargeAttributeNameMap  = DiscountConstants.getChargeAttributeNameMap('Business Calling'); // modified by shubhi Edge-120919
        Test.stopTest();
        System.assertEquals('PhoneNumberShadowRCTCV', chargeAttributeNameMap.get('DMCAT_RecurringCharge_000808'));   
    }
    
    // Ila - Added as part of story : DPG-1513 
     @IsTest
    public static void getChargeAttributeNameMapPositiveCWP()
    {
        Test.startTest();
        Map<String,String> chargeAttributeNameMap  = DiscountConstants.getChargeAttributeNameMap('CWP Mobile Subscription' );
        Test.stopTest();
        System.assertEquals('PlanShadowTCV', chargeAttributeNameMap.get('DMCAT_RecurringCharge_000654'));
    }
    @IsTest
    public static void getChargeAttributeNameMapNegative()
    {
      Test.startTest();
      Map<String,String> chargeAttributeNameMap  = DiscountConstants.getChargeAttributeNameMap('Mobile XXX' );
      Test.stopTest();
      System.assertEquals(0, chargeAttributeNameMap.size());          
    }
  
  @IsTest
  public static void getChargeTypePositive()
  {
      Test.startTest();
      String chargeType  = DiscountConstants.getChargeType('DMCAT_RecurringCharge_000654' );
      String chargeType1  = DiscountConstants.getChargeType('DMCAT_RecurringCharge_000669' );
      String chargeType2  = DiscountConstants.getChargeType('DMCAT_RecurringCharge_000857' );
      String chargeType3  = DiscountConstants.getChargeType('DMCAT_RecurringCharge_000497' );
      Test.stopTest();
      System.assertEquals('Flat Recurring', chargeType);
  }  
   
    @IsTest
  public static void getChargeTypeNegative()
  {
      Test.startTest();
      String chargeType  = DiscountConstants.getChargeType('DMCAT_RecurringCharge_000XXX' );
      Test.stopTest();
      System.assertEquals('', chargeType);
  }  

 @IsTest
  public static void getChargeIdentifierTest()
  {
      Test.startTest();
      List<String> getChargeIdentifierMap  = DiscountConstants.getChargeIdentifier();
      System.assertEquals(True, getChargeIdentifierMap.contains('DMCAT_RecurringCharge_000808'));
       Test.stopTest();
  } 
  
  @IsTest
  public static void getDiscountConstForNGUCVoiceTest()
  {
      Test.startTest();
      Map<String,String> commercialProductIdentifierMap  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000808');
      Map<String,String> commercialProductIdentifierMap1  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000811');
      Map<String,String> commercialProductIdentifierMap2  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000816');
      Map<String,String> commercialProductIdentifierMap3  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000814');
      Map<String,String> commercialProductIdentifierMap4  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000813');
      Map<String,String> commercialProductIdentifierMap5  = DiscountConstants.getDiscountConstForNGUCVoice('DMCAT_RecurringCharge_000810');
      
      System.assertEquals(true, commercialProductIdentifierMap.containsKey('commercialProductIdentifier'));
      Test.stopTest();
  } 
  //Edge-133882 added by Shubhi start  
    @IsTest
  public static void getRateCardNameMapTest()
  {
      Test.startTest();
      Map<String,String> RateCardNameMap  = DiscountConstants.getRateCardNameMap();    
      System.assertEquals(true, RateCardNameMap.containsKey('DMCAT_RecurringCharge_000808'));
      Test.stopTest();
  }
    //Edge-133882 added by Shubhi end
     //// added by shubhi for Edge-143527 start
     @isTest
     public static void getsolutionnameTest()
     {
      Test.startTest();
         String mobilitySolutionName=DiscountConstants.mobilitySolutionName;
        String deviceSolutionName=DiscountConstants.deviceSolutionName;
        String voiceSolutionName=DiscountConstants.voiceSolutionName;
    //// added by shubhi for Edge-143527 end
    System.assertEquals(true, deviceSolutionName=='Unified Communication Device');
    Test.stopTest();
  }
}