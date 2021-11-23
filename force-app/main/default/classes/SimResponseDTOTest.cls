@IsTest
public class SimResponseDTOTest {
    
    static testMethod void testParse() {
		String json = '{'+
		'  \"status\": 200,'+
		'  \"code\": 200,'+
		'  \"time\": \"2020-08-14T11:18:56.670+0000\",'+
		'  \"correlationId\": \"80658d1e-5102-496f-980f-b23f4e040b2f\",'+
		'  \"path\": \"/v2/logical-resources/sim/resources/fetch\",'+
		'  \"method\": \"POST\",'+
		'  \"responseCode\": \"LRM-PARTIAL-SUCCESS\",'+
		'  \"message\": \"Requested SIM[s] details partially found. Please refer to errors for further assistance\",'+
		'  \"requestId\": \"9b0f7605-3744-4f38-a303-1bc1aab5628c\",'+
		'  \"errors\": ['+
		'    {'+
		'      \"simNumber\":\"89610182000501374392\",'+
		'      \"message\":\"SIM details not found\",'+
		'      \"code\":\"LRM-RESOURCE_NOT_FOUND\"'+
		'    },'+
		'    {'+
		'      \"simNumber\":\"82000501374402\",'+
		'      \"message\":\"Invalid SIM number\",'+
		'      \"code\":\"LRM-LRM-INVALID_DATA\"'+
		'    }'+
		'  ],'+
		'  \"data\": {'+
		'    \"resources\": ['+
		'      {'+
		'        \"resourceId\": \"89610182000501374304\",'+
		'        \"resourceType\": \"ICCID\",'+
		'        \"resourceState\": \"AVAILABLE\",'+
		'        \"characteristics\": ['+
		'          {'+
		'            \"name\": \"SIM Type\",'+
		'            \"value\": \"3GUniversal\"'+
		'          },'+
		'          {'+
		'            \"name\": \"SIM Category\",'+
		'            \"value\": \"3G Standard SIM\"'+
		'          },'+
		'          {'+
		'            \"name\": \"Order ID\",'+
		'            \"value\": \"0300898383\"'+
		'          }'+
		'        ]'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		SimResponseDTO obj = SimResponseDTO.parse(json);
		System.assert(obj != null);
	}

}