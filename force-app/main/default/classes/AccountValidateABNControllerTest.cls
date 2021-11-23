@isTest
public class AccountValidateABNControllerTest {
	
    @isTest static void testCallout(){
        
        Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
        acc.ABN__c = '83914571673';
        update acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AccountValidateABNController abnClass = new AccountValidateABNController(sc);
        createCustomSettingValues();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        abnClass.callout();
		Test.stopTest();
    }
    
    static void createCustomSettingValues() {
 
        EnvironmentVariable__c customSetting = new EnvironmentVariable__c(Value__c = 'http://abr.business.gov.au/abrxmlsearch/AbrXmlSearch.asmx/ABRSearchByABN'); 
        customSetting.Name = 'abn_validator_endpoint';
        insert customSetting;

        EnvironmentVariable__c customSetting1 = new EnvironmentVariable__c(Value__c = 'efffade1-8320-45b5-a0e8-c2a38a5aa1bd'); 
        customSetting1.Name = 'abn_validator_key';
        insert customSetting1;
    }
}