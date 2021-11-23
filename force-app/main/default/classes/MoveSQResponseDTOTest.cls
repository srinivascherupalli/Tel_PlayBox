/*
 * Test class for MoveSQResponseDTO
 */
@IsTest
public class MoveSQResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"status\":200,'+
		'    \"data\": {'+
		'        \"numberDetails\": ['+
		'            {'+
		'                \"fullNationalNumber\":\"fnn1\",'+
		'                \"fnnServiceabilityIndicator\":\"Y\",'+
		'                \"reason\":\"ESA of New Address is within the same SZU of FNN\",'+
		'                \"code\":\"SZU_MATCH_SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"fnn1\",'+
		'                \"fnnServiceabilityIndicator\":\"Y\",'+
		'                \"reason\":\"ESA of New Address is within the same SZU of FNN\",'+
		'                \"code\":\"SZU_MATCH_SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"fnn2\",'+
		'                \"fnnServiceabilityIndicator\":\"N\",'+
		'                \"reason\":\"SZU of New Address does not match with SZU of FNN\",'+
		'                \"code\":\"ESA_SZU_MISMATCH\"'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"errors\": {'+
		'        \"errorDetails\":['+
		'            {'+
		'                \"fullNationalNumber\":\"fnn3\",'+
		'                \"message\":\"FNN not found\",'+
		'                \"code\":\"FNN_NOT_FOUND\"'+
		'            },'+
		'            {'+
		'                \"fullNationalNumber\":\"fnn4\",'+
		'                \"message\":\"Service unavailable\",'+
		'                \"code\":\"SERVICE_UNAVAILABLE\"'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
		MoveSQResponseDTO obj = MoveSQResponseDTO.parse(json);
		System.assert(obj != null);
	}
}