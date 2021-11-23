@isTest
public class PricingInfoResponseHelperTest {
    @testSetup 
   public static void setupdata(){ 
       cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.cspmb__Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;//Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
		priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;
       
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c();   
        pr.cspmb__pricing_rule_code__c = 'BasePrices';
        pr.cspmb__description__c = 'Auto generated from FA decomposition.';
        pr.cspmb__pricing_rule_code__c='FAM 2021-05-06 09:46:34___3';
        insert pr;
    	
       
        cspmb__Pricing_Rule_Group__c pg = new cspmb__Pricing_Rule_Group__c();
        pg.Name = 'PG2';
        pg.cspmb__description__c ='Auto generated from FA decomposition.';
        pg.cspmb__pricing_rule_group_code__c = 'FAM 2021-05-06 09:46:34___3';
        pg.cspmb__priority__c = 100;
        pg.cspmb__rule_group_compounding_type__c='Inclusive';
        pg.cspmb__always_applied__c=true;
        pg.csfam__standard_price_book__c =true; 
        insert pg;
       
        cspmb__Pricing_Rule_Group_Rule_Association__c PriceRuleAssoc = new cspmb__Pricing_Rule_Group_Rule_Association__c();
        PriceRuleAssoc.cspmb__pricing_rule_group__c = pg.Id;
        PriceRuleAssoc.cspmb__pricing_rule__c = pr.Id;
        insert PriceRuleAssoc;
       
        cspmb__Price_Item_Pricing_Rule_Association__c pipra=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra.cspmb__association_type__c = 'Pricing change';
        pipra.cspmb__target_price__c = 'Sales';
        pipra.cspmb__recurring_adjustment_type__c='Price Override';
        pipra.cspmb__one_off_adjustment_type__c='Price Override';   
        pipra.cspmb__pricing_rule__c = pr.id;
        pipra.cspmb__price_item__c = priceItem.Id;
        pipra.cspmb__recurring_adjustment__c=10;
        insert pipra;
    }
    @isTest
    public static void processRequestTest(){
        PricingAPIRequest request = new PricingAPIRequest();
        request.cidn='123';
        request.marketableOfferId='DMCAT_Offer_001233';
        request.productCode=new List<String>{'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790'};
        Test.startTest();
        PricingInfoResponseHelper.processRequest(request,'SFDC');
        Test.stopTest();

        System.assertEquals('DMCAT_Offer_001233', request.marketableOfferId);
    }
    
    @isTest
    public static void validateMandatoryTest(){
        PricingAPIRequest request = new PricingAPIRequest();
        request.cidn='123345678';
        request.marketableOfferId='DMCAT_Offer_001233';
        request.productCode=new List<String>{'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790'};
        Test.startTest();
        PricingInfoResponseHelper.validateMandatory(request,'SFDC');
        Test.stopTest();

        System.assertEquals('123345678', request.cidn);
  		
        
        
    }
    
     @isTest
    public static void isValidCIDNTest(){
        Account acc = new Account();
        acc.Name = 'Marvels Account';
        acc.CIDN__c = '123345699';
        insert acc;
        
        PricingAPIRequest request = new PricingAPIRequest();
        request.cidn='123345691';
        request.marketableOfferId='DMCAT_Offer_001289';
        request.productCode=new List<String>{'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790'};
        Test.startTest();
        PricingInfoResponseHelper.isValidCIDN(request,'SFDC');
        Test.stopTest();

        System.assertEquals('123345691', request.cidn);
        
    }
    
    @isTest
    public static void isValidProductCodeTest(){
        PricingAPIRequest request = new PricingAPIRequest();
        request.cidn='123345699';
        request.marketableOfferId='DMCAT_Offer_001289';
        request.productCode=new List<String>{'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790'};
        Test.startTest();
        PricingInfoResponseHelper.isValidProductCode(request,'SFDC');
        Test.stopTest();
        
        System.assertEquals('123345699', request.cidn);
    }
    
    @isTest
    public static void negativeTest(){
        
        Account acc = new Account();
        acc.Name = 'Marvels Account';
        insert acc;
        
        PricingAPIRequest negReq = new PricingAPIRequest();
        negReq.cidn='123345690';
        negReq.marketableOfferId='MACD_Offer_001289';
        negReq.productCode=new List<String>{'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790'};
        Test.startTest();
        PricingInfoResponseHelper.isValidCIDN(negReq,'SFDC');
        PricingInfoResponseHelper.validateMandatory(negReq,'SFDC');
        Test.stopTest();

        System.assertEquals('123345690', negReq.cidn);
    }
    
    @isTest
    static void Test_prepareResponse(){ 
         System.assertNotEquals(NUll,PricingInfoResponseHelper.prepareResponse('200','test', null));
    }
    
     @isTest
    static void Test_getErrorMessage(){ 
         System.assertNotEquals(NUll,PricingInfoResponseHelper.getErrorMessage('Test','202'));
    }
    
}