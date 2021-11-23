@IsTest
public class PortInSQRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"data\": {'+
		' \"FNN\": \"1300000036\"'+
		' }'+
		'}';
		PortInSQRequestDTO obj = PortInSQRequestDTO.parse(json);
		System.assert(obj != null);
	}
    
    static testMethod void testGetgetEncodedURL(){
        PortInSQRequestDTO request = new PortInSQRequestDTO();
        request.data = new PortInSQRequestDTO.Data();
        request.data.fnns = new List<String>{'123456'};
        String encodedURL = request.getEncodedURL();
        System.assert(encodedURL != null);
    }
    
    static testMethod void testGetgetEncodedURLFailure(){
        PortInSQRequestDTO request = new PortInSQRequestDTO();
        request.data = new PortInSQRequestDTO.Data();
        //request.data.fnns = new List<String>{'123456'};
        String encodedURL = request.getEncodedURL();
        System.assert(encodedURL == null);
    }
}