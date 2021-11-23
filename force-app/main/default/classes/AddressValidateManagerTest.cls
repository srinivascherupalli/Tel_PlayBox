@isTest
public class AddressValidateManagerTest {
	@isTest
    static void testSarchAddressByAdborIdSuccessforParent(){
        AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        addressRequestDTO.data = new AddressRequestDTO.Data();
        addressRequestDTO.data.adborId = '1234';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT));
       	AddressResponseDTO addressResponseObj = AddressValidateManager.searchAddressByAdborId(addressRequestDTO);
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
       	AddressResponseDTO addressResponseObj = AddressValidateManager.searchAddressByAdborId(addressRequestDTO);
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
       	AddressResponseDTO addressResponseObj = AddressValidateManager.searchAddressByAdborId(addressRequestDTO);
        Test.stopTest();
        
        System.assert(addressResponseObj != null);
        System.assertEquals(5013, addressResponseObj.code);
        System.assertEquals(500, addressResponseObj.status);
    }
    
    @isTest
    static void searchAddressByAdborIdAsyncFailure(){
        try{
            AddressRequestDTO addressRequestDTO = new AddressRequestDTO();        
        	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_FAILURE ));
       		AddressValidateManager.searchAddressByAdborIdAsync(addressRequestDTO);
        	Test.stopTest(); 
        }catch(Exception e){
            System.assert(e!= null);
        }               
    }
    
    @isTest
    static void searchAddressByAdborIdAsyncSuccess(){
        try{
            AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
        	addressRequestDTO.data = new AddressRequestDTO.Data();
        	addressRequestDTO.data.adborId = '1234';
        
        	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockAddressResponseGenerator(MockAddressResponseGenerator.SEARCH_ADBORID_SUCCESS_PARENT ));
       		AddressValidateManager.searchAddressByAdborIdAsync(addressRequestDTO);
        	Test.stopTest(); 
        }catch(Exception e){
            System.assert(e== null);
        }               
    }
}