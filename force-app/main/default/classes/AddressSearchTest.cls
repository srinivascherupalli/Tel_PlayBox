@isTest
public class AddressSearchTest {
//Structured and Unstructured Address Test
    @isTest
    public static void Test_searchUnStructuredAddress_Success(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'UnStructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_SuccessRural(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Rural'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'UnStructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_SuccessParcel(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Parcel'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'UnStructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
     @isTest
    public static void Test_searchUnStructuredAddress_SuccessAll(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('All'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'UnStructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_SuccessPostal(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Postal'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'UnStructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_Error(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Error'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'StructuredAddressHandler','7959871' );
        Test.stopTest();
        System.assertEquals(addrList, NULL);
    }
  
    @isTest
    public static void Test_searchUnStructuredAddress_Adbor(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'AdborIdAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_AutoComp(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('autoComplete'));
        Test.startTest();
          AddressResponseDTO addrRes= AddressSearch.searchUnstructredAdd('George','UnStructuredAutocompleteHandler' );
          system.debug('addrRes++' +addrRes);
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
    @isTest
    public static void Test_searchUnStructuredAddress_UnstructAuto(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        Test.startTest();
        AddressSearch.searchAutoAdd(addrDTO,'UnStructuredAutocompleteHandler' );
        Test.stopTest();
        System.assertNotEquals(addrDTO, NULL);
    }
    
    
    
    @isTest
    public static void Test_searchUnStructuredAddress_Structure(){
        AddressRequest addrDTO = new AddressRequest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Success'));
        Test.startTest();
        List<AddressSummary> addrList = AddressSearch.searchUnStructuredAddress(addrDTO,'StructuredAddressHandler','2459871' );
        Test.stopTest();
        System.assertNotEquals(addrList, NULL);
    }

    /*------------------------------------------------------------ 
EDGE-76217
Method: searchAdborIdAddress 
Description: Callout to Address SQ interface, changed return type to AddressResponseDTO
Inputs: adborId , Handler name
Returns: 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @isTest
    public static void Test_searchAdborIdAddress_Success(){
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Adbor'));
        Test.startTest();
        AddressResponseDTO addrRes = AddressSearch.searchAdborIdAddress('2459872','AdborIdAddressHandler');
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    @isTest
    public static void Test_searchAdborIdAddress_Error(){
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Error'));
        Test.startTest();
        AddressResponseDTO addrRes = AddressSearch.searchAdborIdAddress('2459872','AdborIdAddressHandler');
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
//searchAddress Test
    @isTest
    public static void searchAddress_Test(){
        AddressRequest addr = new AddressRequest(); 
        Test.startTest();
        AddressResponseDTO addrRes = AddressSearch.searchAddress(addr,'StructuredAddressHandler');
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
    @isTest
    public static void searchAddressAuto_Test(){
        AddressRequest addr = new AddressRequest(); 
        Test.startTest();
        AddressResponseDTO addrRes = AddressSearch.searchAddress(addr,'searchUnstructredAdd');
        Test.stopTest();
        System.assertNotEquals(addrRes, NULL);
    }
    
    @isTest
    public static void getEncodedURLParam_Test(){
        String url = AddressSearch.getEncodedURLParam('2459873');
        System.assertNotEquals(url, NULL);
    }
    
    @isTest
    public static void getEncodedURLParamAuto_Test(){
        String url = AddressSearch.getEncodedURLUnstruct('Smith');
        System.assertNotEquals(url, NULL);
    }
     /*------------------------------------------------------------ 
 //EDGE -76217
Method: testFetchAdd 
Description: fetch address names from address SQ 
Inputs: Search string
Returns:  List of address names
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/ 
     @isTest 
    public static void testFetchAdd(){
        String searchString ='2 Maitland Bay Drive';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('AutoResponse_success'));
        List<String> addressList = AddressSearch.searchAutocomplete('UnStructuredAutocompleteHandler',searchString);
        Test.stopTest();
        System.assertEquals(addressList!=null,true,'Name');
    }
     
}