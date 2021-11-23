/*
* @Desc : NGUC Test Class
* @Jira : DIGI-518
*/
@isTest
public class NGUCTest {
    @isTest static void getCalculateRemainingTermngUCSuccess(){
        // ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
        String BillingAccountJson = '{"code":200,"status":200,"message":"Success","billingAccount":{"billingAccountNumber":700000506340,"status":"Active","startDate":"2019-12-18T00:00:00Z","billCycleDay":1,"paymentTerms":30,"rouCode":"test22","currencyCode":"AUD","language":"English","companyName":"Eureka_18/12/2019_ZVX","billingAddress":{"address":"40 BOND ST, abc dd","locality":"KINGS MEADOWS","postcode":"7249","state":"TAS","country":"Australia"}}}';
        String BillingAccountJson1 = '{"code":200,"status":200,"message":"Success","billingAccount":{"billingAccountNumber":700000506340,"status":"Active","startDate":"2019-12-18T00:00:00Z","billCycleDay":31,"paymentTerms":30,"rouCode":"test22","currencyCode":"AUD","language":"English","companyName":"Eureka_18/12/2019_ZVX","billingAddress":{"address":"40 BOND ST, abc dd","locality":"KINGS MEADOWS","postcode":"7249","state":"TAS","country":"Australia"}}}';
        BillingAccountDetailsDTO BillingAccDTO = BillingAccountDetailsDTO.parse(BillingAccountJson);
        BillingAccountDetailsDTO BillingAccDTO1 = BillingAccountDetailsDTO.parse(BillingAccountJson1);
        //  testclass.setup();
        Test.startTest();
        Date iniActDat = Date.valueOf('2018-12-30 00:00:00');
        Date disDate = Date.valueOf('2019-12-30 00:00:00');
        Date disDate1 = Date.valueOf('2018-10-30 00:00:00');
        Integer conTerm = 24;
        Integer rowsTerms = NGUC_Utilities.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO);
        Integer rowsTerms1 = NGUC_Utilities.calculateRemainingTermngUC(iniActDat,disDate,conTerm,BillingAccDTO1);
        Integer rowsTerms2 = NGUC_Utilities.calculateRemainingTermngUC(iniActDat,disDate1,conTerm,BillingAccDTO);
        Test.stopTest();
        System.assert(rowsTerms!=null);
        System.assert(rowsTerms1!=null);
        System.assert(rowsTerms2!=null);
    } 
}