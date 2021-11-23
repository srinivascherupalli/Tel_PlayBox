/**
 * Class for address check manager.
 */
public with sharing class AddressValidateManager {

    public static final String SYSTEM_NAME = 'EAST';
	
	/*private AddressValidateManager(){
        
    }*/
    
    /* US41754 */
    /*public static List<AddressSummary> searchUnstructuredAddress(Map<String, Object> params) {
        	return AddressValidateService.searchUnstructuredAddress(params, SYSTEM_NAME);
    }*/
    /* EDGE - 57162
     */
    public static List<AddressSummary> searchAddressSQ(Map<String, Object> params, String handler,String adborid) {
        	return AddressValidateService.searchAddressSQ(params,handler,adborid);
    }
    
    /**
    * Will Search address details for specified addressID in salesforce
    * @params list of account ids
    */
    public static List<AddressSummary> searchAddress(String addressText) {
        	return AddressValidateService.searchAddress(addressText, SYSTEM_NAME);
    }
	public static void searchAddressByAdborIdAsync(AddressRequestDTO addressRequestDTOObj) {
        	AddressValidateService.searchAddressByAdborIdAsync(addressRequestDTOObj);
    }
	public static AddressResponseDTO searchAddressByAdborId(AddressRequestDTO addressRequestDTOObj) {
        AddressResponseDTO addressResponseobj;
        addressResponseobj = AddressValidateService.searchAddressByAdborId(addressRequestDTOObj);
        return addressResponseobj;
    }
    
	/**
     * US41754 */
    public static List<SelectOptionz> getPostCodeByState(String stateCode) {
        	return AddressValidateService.getPostCodeByState(stateCode);
    }
    
    /*US41754  */
     
    public static List<SelectOptionz> getLocalityByPostCode(String postCode) {
        	return AddressValidateService.getLocalityByPostCode(postCode);
    }
}