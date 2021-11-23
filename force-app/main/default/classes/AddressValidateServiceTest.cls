@isTest
public class AddressValidateServiceTest {
	public static final String NBN_EAST = 'AddressValidateServiceByAdborId';
	@isTest
    static void testSarchAddressByAdborIdSuccessforParent(){
        AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        addressRequestDTO.data = new AddressRequestDTO.Data();
        addressRequestDTO.data.adborId = '1234';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
       	AddressResponseDTO addressResponseObj = AddressValidateService.searchAddressByAdborId(addressRequestDTO);
        Test.stopTest();
        
        System.assert(addressResponseObj != null);
        System.assertEquals('2016-08-16T10:53:09+10:00', addressResponseObj.responseTime);
        System.assertEquals('BUILDING', addressResponseObj.data.structured.addresses.subaddresses.SubAddresses.Level1[0].SubAddressType);
    }
    
    @isTest
    static void testSarchAddressByAdborIdSuccessforChild(){
        AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        addressRequestDTO.data = new AddressRequestDTO.Data();
        addressRequestDTO.data.adborId = '1234';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_CHILD));
       	AddressResponseDTO addressResponseObj = AddressValidateService.searchAddressByAdborId(addressRequestDTO);
        Test.stopTest();
        
        System.assert(addressResponseObj != null);
        System.assertEquals('2017-09-25T16:27:21+10:00', addressResponseObj.responseTime);
        System.assertEquals('PropertyAddressSummary', addressResponseObj.data.structured.addresses.parent.parent.parent.addressSummaryType);
    }
    
    @isTest
    static void testSarchAddressByAdborIdFailure(){
        AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        addressRequestDTO.data = new AddressRequestDTO.Data();
        addressRequestDTO.data.adborId = '1234';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_FAILURE ));
       	AddressResponseDTO addressResponseObj = AddressValidateService.searchAddressByAdborId(addressRequestDTO);
        Test.stopTest();
        
        System.assert(addressResponseObj != null);
        System.assertEquals(5013, addressResponseObj.code);
        System.assertEquals(500, addressResponseObj.status);
    }
    
    @isTest
    static void testSarchAddressByAdborIdWithoutManParam(){
        AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        addressRequestDTO.data = new AddressRequestDTO.Data();
        addressRequestDTO.data.adborId = '';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_FAILURE ));
       	AddressResponseDTO addressResponseObj = AddressValidateService.searchAddressByAdborId(addressRequestDTO);
        Test.stopTest();
        
        System.assert(addressResponseObj == null);
    }
    
    @isTest
    static void searchAddressByAdborIdAsyncSuccessCase1(){
        try{
           AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
           addressRequestDTO.data = new AddressRequestDTO.Data();
           addressRequestDTO.data.adborId = '123456';
        
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT ));
       	   AddressValidateService.searchAddressByAdborIdAsync(addressRequestDTO);
           Test.stopTest(); 
        }catch(Exception e){
           System.assert(e == null);
        }
    }
    
     @isTest
    static void searchAddressByAdborIdAsyncFailureCase1(){
        try{
           AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT ));
       	   AddressValidateService.searchAddressByAdborIdAsync(addressRequestDTO);
           Test.stopTest(); 
        }catch(Exception e){
           System.assert(e != null);
        }
    }
    
    @isTest
    static void runSearchByAdborIdAsyncSuccessCase1(){
        try{
           AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
           addressRequestDTO.data = new AddressRequestDTO.Data();
           addressRequestDTO.data.adborId = '123456';
		   String urlParam = addressRequestDTO.getEncodedURLParam();        
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_FAILURE ));
       	   AddressValidateService.runSearchByAdborIdAsync(urlParam,NBN_EAST);
           Test.stopTest(); 
        }catch(Exception e){
           System.assert(e == null);
        }
    }
    
    @isTest
    static void runSearchByAdborIdAsyncSuccessCase2(){
        try{
           AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
           addressRequestDTO.data = new AddressRequestDTO.Data();
           addressRequestDTO.data.adborId = '123456';
		   String urlParam = addressRequestDTO.getEncodedURLParam();        
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
       	   AddressValidateService.runSearchByAdborIdAsync(urlParam,NBN_EAST);
           Test.stopTest(); 
        }catch(Exception e){
           System.assert(e == null);
        }
    }   
}