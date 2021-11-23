@isTest
public class AddressRequestDTOTest {
    @isTest
    static void testGetEncodedURLParam(){
        AddressRequestDTO dto = new AddressRequestDTO();
		dto.data = new AddressRequestDTO.Data();
		dto.data.adborId = '265083570';    
        
        String param = dto.getEncodedURLParam();
        system.assertEquals('265083570?reqaddformatout=unstructuredAUPost,structured', param);
    }
    
    @isTest
     static void testGetEncodedURLParamFail(){
        AddressRequestDTO dto = new AddressRequestDTO();
		dto.data = new AddressRequestDTO.Data();
		//dto.data.adborId = '265083570';    
        
        String param = dto.getEncodedURLParam();
        system.assert(param == null);
    }
    
	@isTest
    static void testParse(){
        String json = '{'+
		' \"data\": {'+
		' \"adborId\": \"987654321\"'+
		' }'+
		'}';
        
        AddressRequestDTO dto = AddressRequestDTO.parse(json);
        
        system.assert(dto != null);
    }    
}