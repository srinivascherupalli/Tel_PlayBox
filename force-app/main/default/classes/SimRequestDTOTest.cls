@IsTest
public class SimRequestDTOTest {

    static testMethod void testParse() {
		String json = '{'+
		'  \"simSerialNumbers\": ['+
		'    \"89610182000501374304\",'+
		'    \"89610182000501374402\"'+
		'  ],'+
		'  \"imsiRequired\": false,'+
		'  \"attributes\": {'+
		'    \"allRequired\": false,'+
		'    \"names\": ['+
		'      \"SIM Type\",'+
		'      \"SIM Category\",'+
		'      \"Order ID\"'+
		'    ]'+
		'  }'+
		'}';
		SimRequestDTO obj = SimRequestDTO.parse(json);
		System.assert(obj != null);
	}
}