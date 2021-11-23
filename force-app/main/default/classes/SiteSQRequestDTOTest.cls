/*
 * Test class for SiteSQRequestDTO 
 */
@IsTest
public class SiteSQRequestDTOTest {
	
    /*
     * Test Parse method of SiteSQRequestDTO
     */
	static testMethod void testParse() {
		String json = '{'+
		' \"data\": {'+
		' \"adborId\": \"987654321\",'+
		' \"nbnCustomerAuthorityDate\": \"12-Mar-2012\"'+
		' }'+
		'}';
		SiteSQRequestDTO obj = SiteSQRequestDTO.parse(json);
		System.assert(obj != null);
	}
    
    /*
     * Test getEncodedURL method of SiteSQRequestDTO
     */
    static testMethod void testGetEncodedURL(){
        SiteSQRequestDTO request = new SiteSQRequestDTO();
        request.data = new SiteSQRequestDTO.Data();
        request.data.adborId = '12';
        request.data.customerAuthorityDate = '12-Mar-2001';
        request.data.tc2Required = 'true';
        String encodedURL = request.getEncodedURL();
        System.assert(encodedURL != null);
    }
    
    static testMethod void testGetEncodedURLWithoutManParam(){
        SiteSQRequestDTO request = new SiteSQRequestDTO();
        request.data = new SiteSQRequestDTO.Data();
        //request.data.adborId = '12';
        request.data.customerAuthorityDate = '12-Mar-2001';
        String encodedURL = request.getEncodedURL();
        System.assert(encodedURL == null);
    }
}