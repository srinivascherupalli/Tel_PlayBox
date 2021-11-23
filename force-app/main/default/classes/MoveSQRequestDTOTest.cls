/*
 * Test class for MoveSQRequestDTO
 */
@IsTest
public class MoveSQRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"data\": {'+
		' \"addressId\": \"987654321\",'+
		' \"fnns\": ['+
		'                              123456,'+
		'                              456987,'+
		'                              823659]'+
		'             }'+
		'}';
		MoveSQRequestDTO obj = MoveSQRequestDTO.parse(json);
		System.assert(obj != null);
	}
    
    /*
     * Test method for getEncodedURL of MoveSQRequestDTO
     * 
     * @return    encodedURl
     */
    static testMethod void testGetEncodedURL(){
        MoveSQRequestDTO request = new MoveSQRequestDTO();
        request.data = new MoveSQRequestDTO.Data();
        request.data.addressId = '123456987';
        request.data.fnns = new List<String>{'658','8745','123644'};
        System.assert(request.getEncodedURL() != null);
    }
}