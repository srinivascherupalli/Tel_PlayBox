/**
 * Test Class for ValidateAddressExtTest controller and other related classes
 */
@isTest
private class ValidateAddressExtensionTest {

    /**
     * Setup the test data required
     */
    @testSetup static void setup() {

        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6');
        EnvironmentVariable.put('okapi_client_id', '1234');
        EnvironmentVariable.put('okapi_client_secret', '1234');
        EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('okapi_east_url', '/v2/address-search/addresses?');
        EnvironmentVariable.put('okapi_east_address_limit', '25');
        EnvironmentVariable.put('east_result_ui_address_name_text_size', '68');
        EnvironmentVariable.put('okapi_east_address_status', 'CONFIRMED');
        EnvironmentVariable.put('okapi_east_result_pagination_size', '10');
        EnvironmentVariable.put('okapi_east_result_list_warning_limit', '25');
        EnvironmentVariable.put('PlatformCache_Expiry_Time', '3599');

        ValidateAddressExtensionTest.createCustomSettingValues();

    }

    /**
     * get Token from APIUtils Test
     */
    @isTest static void testToken() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        String token = AuthenticationManager.getOauthToken(AddressValidateManager.SYSTEM_NAME);
        Test.stopTest();
        System.assertEquals('tElsAddR32156teSt', token);

    }


    /**
     * Search Address test method
     */
    @isTest static void searchAddressTest() {



        //cscrm__Address__c address = [SELECT Id FROM cscrm__Address__c WHERE cscrm__Zip_Postal_Code__c='2148' LIMIT 1];
        cscrm__Address__c address = new cscrm__Address__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(address);
        ValidateAddressExtension validateAddress = new ValidateAddressExtension(sc);
        validateAddress.addressText = '447-453 LONSDALE ST MELBOURNE VIC 3000';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        validateAddress.searchAddress();
        Test.stopTest();

        System.assert(validateAddress.addressList.size() > 0);

    }

    /**
     * Saves an address test.
     */
   /* @isTest static void saveAddressTest() {


        cscrm__Address__c address = new cscrm__Address__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(address);
        ValidateAddressExtension validateAddress = new ValidateAddressExtension(sc);
        validateAddress.addressText = '447-453 LONSDALE ST MELBOURNE VIC 3000 OR it can be come really big text for testing splited address';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        validateAddress.searchAddress();
        validateAddress.selectedId = '414413932';
        validateAddress.save();
        Test.stopTest();

        System.assertEquals('414413932', validateAddress.addr.Address_ID__c);

    }*/

    /**
     * Tests redirect method
     */
    @isTest static void redirectPageTest() {


        cscrm__Address__c address = new cscrm__Address__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(address);
        ValidateAddressExtension validateAddress = new ValidateAddressExtension(sc);
        validateAddress.addressText = '447-453 LONSDALE ST MELBOURNE VIC 3000 MELBOURNE';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        validateAddress.searchAddress();
        validateAddress.selectedId = '414413932';
        PageReference ref = validateAddress.redirect();
        Test.stopTest();

        System.assertEquals(new PageReference('/apex/ValidateAddressWithEAST').getUrl(), ref.getUrl());

    }

    /**
     * Tests goBack method
     */
    @isTest static void goBackPageTest() {


        cscrm__Address__c address = new cscrm__Address__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(address);
        ValidateAddressExtension validateAddress = new ValidateAddressExtension(sc);
        validateAddress.addressText = '';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        validateAddress.searchAddress();
        validateAddress.selectedId = '414413932';
        PageReference ref = validateAddress.goBack();
        Test.stopTest();

        System.assertEquals(new PageReference('/apex/CreateAddress').getUrl(), ref.getUrl());

    }


    /**
     * Test paginaton functionality
     */
    @isTest static void addressPaginationTest() {

        cscrm__Address__c address = new cscrm__Address__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(address);
        ValidateAddressExtension validateAddress = new ValidateAddressExtension(sc);
        validateAddress.addressText = '447-453 LONSDALE ST MELBOURNE VIC 3000';
        List<AddressSummary> addressList = new List<AddressSummary>();

        for (Integer i = 0; i < 35; i++) {
            AddressSummary addSum = new AddressSummary();
            addSum.addressId = 'Test ID ' + i;
            addressList.add(addSum);
        }
        validateAddress.addressList = addressList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator());
        validateAddress.searchAddress();
        validateAddress.addressList = addressList;
        System.debug(validateAddress.paginationSize);
        System.debug(validateAddress.adddressNameSize);

        validateAddress.Next();
        validateAddress.First();
        validateAddress.Last();
        validateAddress.Previous();

        validateAddress.getHasPrevious();
        validateAddress.getHasNext();
        validateAddress.getPageNumber();
        validateAddress.getTotalPages();

        System.assertEquals(validateAddress.getPageNumber(), 3);
        System.assertEquals(validateAddress.getTotalPages(), 4);
        Test.stopTest();
    }


    /**
     * Creates custom setting values.
     */
    static void createCustomSettingValues() {

        insert new east_integration_configuration__c
            (SetupOwnerId = UserInfo.getOrganizationId(), 
            client_id__c = 'TEST_CLIENTID', 
            client_secret__c = 'TEST_CLIENT_SECRET',
            enable_mocks__c = false, 
            endpoint__c = 'https://cb.test.dev.telstra.com/org006/qa/v1/oauth/token', 
            grant_type__c = 'client_credentials',
            method__c = 'POST',
            scope__c = 'ADDRESSSEARCH');

    }

}