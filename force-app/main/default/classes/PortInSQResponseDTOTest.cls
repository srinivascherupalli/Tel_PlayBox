@IsTest
public class PortInSQResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"status\":200,'+
		'    \"data\": {'+
		'        \"numberDetails\": ['+
		'            {'+
		'                \"fullNationalNumber\":\"fnn1\",'+
		'                \"fnnPortabilityIndicator\":\"N\",'+
		'                \"reason\":\"The FNN cannot be ported into Telstra network as the given FNN status is ACTIVE\",'+
		'                \"code\":\"SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"fnn2\",'+
		'                \"fnnPortabilityIndicator\":\"Y\",'+
		'                \"reason\":\"The FNN can be ported into Telstra network\",'+
		'                \"code\":\"SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"fnn3\",'+
		'                \"fnnServiceabilityIndicator\":\"N\",'+
		'                \"reason\":\"The FNN is managed by Telstra\",'+
        '   		     \"portInType\": \"Donor Return\",'+
		'                \"code\":\"SUCCESS\"'+
		'            }'+
		' '+
		'        ]'+
		'    },'+
		'    \"errors\": {'+
		'        \"errorDetails\": ['+
		'            {'+
		'                \"fullNationalNumber\":\"fnn1\",'+
		'                \"message\":\"FNN not found\",'+
		'                \"code\":\"FNN_NOT_FOUND\"'+
		'            },'+
		'            {'+
		'                \"fullNationalNumber\":\"fnn1\",'+
		'                \"message\":\"FNN not found\",'+
		'                \"code\":\"FNN_NOT_FOUND\"'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
		PortInSQResponseDTO obj = PortInSQResponseDTO.parse(json);
		System.assert(obj != null);
	}
}