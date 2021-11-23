/*
 * Test class for TransitionSQRequestDTO
 */
@IsTest
public class TransitionSQRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"data\": {'+
		' \"addressId\": \"123456789\",'+
		' \"FNN\": \"1300000036\"'+
		' }'+
		'}';
		TransitionSQRequestDTO obj = TransitionSQRequestDTO.parse(json);
		System.assert(obj != null);
	}
    
    static testMethod void testCheckMandatoryParams(){
        TransitionSQRequestDTO request = new TransitionSQRequestDTO();
        request.data = new TransitionSQRequestDTO.Data();
        request.data.addressId = '12';
        request.data.FNN = '589654';
        boolean encodedURL = request.checkMandatoryParams();
        System.assert(encodedURL == true);
    }
    
    static testMethod void testGetEncodedURL(){
       TransitionSQRequestDTO request = new TransitionSQRequestDTO();
        request.data = new TransitionSQRequestDTO.Data();
        request.data.addressId = '12';
        request.data.FNN = '589654';
        request.data.tc2Required = 'true';
        String encodedURL = request.getEncodedURL();
        System.assert(encodedURL != null);
    }
}