/***********************************************************************************************************
Class Name : GetPriceDetailsTest
Created By : Ayush, Irfan
Created On : 1st Nov 2021
************************************************************************************************************/
@isTest
public class GetPriceDetailsTest {
    
    
    
    
    @isTest
    public static void doPostNegativeProdTest(){
        Account acc = new Account();
        acc.Name = 'Marvels Account';
        acc.CIDN__c = '9850775277';
        insert acc;
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
        priceItem.ChargeType__c='RC';// EDGE-177929
		priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;

        String reqString = '{"MarketableOfferId":"DMCAT_Offer_001233","Source-System":"T-Now/T-Connect","CIDN": "9850775277","ProductCode":["MYCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_1"]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assert(res.responseBody.toString().contains(Pricing_API_Constants.ERROR_PRODCODE));
        System.assert(res.responseBody.toString().contains('400'));
    }
    
    @isTest
    public static void doPostValidateMandatoryTest(){
        String reqString = '{"MarketableOfferId":"DMCAT_Offer_001233","Source-System":"T-Now/T-Connect","CIDN": "8888705970","ProductCode":["DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_1","DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_2"]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        PricingAPIResponse resp = new PricingAPIResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assert(res.responseBody.toString().contains(Pricing_API_Constants.INVALID_OFFER_NAME));
        System.assert(res.responseBody.toString().contains('400'));
    }

    @isTest
    public static void doPostNegativeCIDNTest(){
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.cspmb__Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
		priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;

        String reqString = '{"MarketableOfferId":"DMCAT_Offer_001233","Source-System":"T-Now/T-Connect","CIDN": "8888705970","ProductCode":["DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_1","DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_2"]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        PricingAPIResponse resp = new PricingAPIResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assert(res.responseBody.toString().contains(Pricing_API_Constants.ERROR_CIDN));
        System.assert(res.responseBody.toString().contains('400'));
    }
    
    @isTest
    public static void doPostNegativeOfferTest(){
		String reqString = '{"MarketableOfferId":"Ganu_Offer_001233","Source-System":"T-Now/T-Connect","CIDN": "3827489448","ProductCode":["DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_1","DMCAT_Offer_000303_DMCAT_ProductSpecification_000078_DMCAT_RecurringCharge_000035_2"]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        PricingAPIResponse resp = new PricingAPIResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();        
        System.assert(res.responseBody.toString().contains(Pricing_API_Constants.INVALID_OFFER_NAME));
        System.assert(res.responseBody.toString().contains('400'));
    }
     @isTest
    static void Test_httpPost_NoRequest(){ 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assertEquals(400, res.statusCode); 
    }

    @isTest
    public static void doPostExceptionTest(){
     
        Account acc = new Account();
        acc.Name = 'Marvels Account';
        acc.CIDN__c = '9850775277';
        insert acc;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.cspmb__Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
		priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;

        String reqString = '{"MarketableOfferId":"DMCAT_Offer_001233","Source-System":"T-Now/T-Connect","CIDN": "9850775277","ProductCode":["DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790"]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assertEquals(null, res.statusCode);
        
    }
    @isTest
    public static void doPostPositiveTest(){
        Account acc2 = new Account();
        acc2.Name = 'Nirvana Account';
        acc2.CIDN__c = '9850775289';
        insert acc2;

        cspmb__Price_Item__c priceItem2 = new cspmb__Price_Item__c();
        priceItem2.name = 'Enterprise Mobility';
        priceItem2.cspmb__Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem2.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem2.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem2.BillingSpecId__c = 'BSRC001_CB';
        priceItem2.Offer_Id__c = 'DMCAT_Offer_001234';
        priceItem2.Plan__c = 'Plan__c';
        priceItem2.cspmb__Recurring_Charge__c = 45.45;
        priceItem2.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem2.ChargeType__c='RC';//EDGE-177929
		priceItem2.Offer_Name__c='Adaptive Mobility';
        priceItem2.cspmb__Is_Active__c = True;
        Insert priceItem2;
        String reqString = '{"MarketableOfferId":"DMCAT_Offer_001234","Source-System":"T-Now/T-Connect","CIDN": "9850775289","ProductCode":["DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790"]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/pricing/fetch-pricing-detail/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqString);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        GetPriceDetails.doPost(); 
        Test.stopTest();
        System.assertEquals(200, res.statusCode);
    }
}