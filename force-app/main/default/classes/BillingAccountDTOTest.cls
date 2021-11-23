@isTest
public class BillingAccountDTOTest
{
    @istest static void test_parse() {

        String jsonstr = '{"correlationId":"328fdbb9-a4e5-4c4c-b72f-0be6b9422917","billingAccount":{"billingAccountNumber":123456789,"billCycleDay":1,"paymentTerms":14,"accountType":"Predebt","status":"Provisioned","writeOff":false,"rouCode":"CCP5V0","currencyCode":"AUD","language":"English","billingAccountOwner":{"firstName":"Joe","lastName":"Bloggs","abn":"0051824753","companyName":"Company Ltd."},"billingAddress":{"address":"Unit 1 1234 Lostmy Way","locality":"Sydney","postcode":"2000","state":"NSW","country":"Australia"}}}';

        Test.startTest();
        BillingAccountDTO billingDTO = BillingAccountDTO.parse(jsonstr);
        Test.stopTest();
        System.assertEquals(123456789, billingDTO.billingAccount.billingAccountNumber);
        System.assertEquals(1, billingDTO.billingAccount.billCycleDay);
        System.assertEquals(14, billingDTO.billingAccount.paymentTerms);
        System.assertEquals('English', billingDTO.billingAccount.language);
        System.assertEquals('AUD', billingDTO.billingAccount.currencyCode);
        System.assertEquals('CCP5V0', billingDTO.billingAccount.rouCode);
        System.assertEquals('Sydney', billingDTO.billingAccount.billingAddress.locality);
        System.assertEquals('2000', billingDTO.billingAccount.billingAddress.postcode);
        System.assertEquals('NSW', billingDTO.billingAccount.billingAddress.state);
        System.assertEquals('Unit 1 1234 Lostmy Way', billingDTO.billingAccount.billingAddress.address);
        System.assertEquals('Australia', billingDTO.billingAccount.billingAddress.country);
        System.assertEquals('Joe', billingDTO.billingAccount.billingAccountOwner.firstName);
        System.assertEquals('Bloggs', billingDTO.billingAccount.billingAccountOwner.lastName);
        System.assertEquals('0051824753', billingDTO.billingAccount.billingAccountOwner.abn);
        System.assertEquals('Company Ltd.', billingDTO.billingAccount.billingAccountOwner.companyName);

        System.assertEquals('Predebt', billingDTO.billingAccount.accountType);

        System.assertEquals('Provisioned', billingDTO.billingAccount.status);
        System.assertEquals(false, billingDTO.billingAccount.writeOff);
    }
}