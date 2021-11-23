/*
 * Test class for TransitionSQResponseDTO
 */
@IsTest
public class TransitionSQResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"correlationId\": \"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e\",'+
		' \"data\": {'+
		'  \"addressId\": \"\",'+
		'  \"migration\": true,'+
		'  \"reason\": \"\",'+
		'  \"serviceTypeQualifications\": ['+
		'   {'+
		'    \"serviceType\": \"Calling\",'+
		'    \"status\": \"Available\",'+
		'    \"serviceTransferIndicator\": \"\",'+
		'    \"statusReason\": \"NBN Calling is available at this Address\",'+
		'    \"technologyType\": \"Fibre To The Node\",'+
		'    \"readyForServiceDate\": \"2016-04-30\",'+
		'    \"serviceabilityClass\": \"12\",'+
		'    \"newDevelopmentChargesApply\": \"No\",'+
		'    \"locationId\": \"LOC000061425812\",'+
		'    \"csaId\": \"CSA400000010875\",'+
		'    \"nbnPriorityAssist\": \"\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'    \"demandType\": \"\",'+
		'    \"fullNationalNumber\": \"4324542423\",'+
		'    \"characteristics\": ['+
		'     {'+
		'      \"name\": \"Telephony Type\",'+
		'      \"value\": \"IP Telephony\"'+
		'     },'+
		'     {'+
		'      \"name\": \"Telephony Type\",'+
		'      \"value\": \"Standard\"'+
		'     }'+
		'    ]'+
		'   },'+
		'   {'+
		'    \"serviceType\": \"Internet\",'+
		'    \"status\": \"Available\",'+
		'    \"serviceTransferIndicator\": \"\",'+
		'    \"statusReason\": \"NBN Internet is available at this Address\",'+
		'    \"technologyType\": \"Fibre To The Node\",'+
		'    \"readyForServiceDate\": \"2016-04-30\",'+
		'    \"serviceabilityClass\": \"12\",'+
		'    \"newDevelopmentChargesApply\": \"No\",'+
		'    \"locationId\": \"LOC000061425812\",'+
		'    \"csaId\": \"CSA400000010875\",'+
		'    \"nbnPriorityAssist\": \"\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'    \"demandType\": \"\",'+
		'    \"characteristics\": ['+
		'     {'+
		'      \"name\": \"TC4 Downstream Upper Rate\",'+
		'      \"value\": \"100 Mbps\"'+
		'     },'+
		'     {'+
		'      \"name\": \"TC4 Downstream Lower Rate\",'+
		'      \"value\": \"62 Mbps\"'+
		'     },'+
		'     {'+
		'      \"name\": \"TC4 Upstream Upper Rate\",'+
		'      \"value\": \"40 Mbps\"'+
		'     },'+
		'     {'+
		'      \"name\": \"TC4 Upstream Lower Rate\",'+
		'      \"value\": \"21 Mbps\"'+
		'     }'+
		'    ]'+
		'   }'+
		'  ],'+
		'  \"orderableTC2Capacity\":{'+
		'       \"maxBackhaul\":\"TC2 Not Supported\",'+
		'       \"maxSpareCopperPair\":\"TC2 Not Supported\",'+
		'       \"maxTransitioningCopperPair\":\"TC2 Not Supported\"'+
		'  },'+
		'  \"scheduledDates\": {'+
		'      \"orderStabilityPeriodDate\": \"20120528\",'+
		'      \"ceaseSaleDate\": \"20120528\"'+
		'   },'+
		'  \"additionalTrafficClassAvailability\": ['+
		'   {'+
		'    \"name\": \"NWAS TC1 150Kbps Capacity\",'+
		'    \"value\": \"Yes\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NHAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'    \"value\": \"No\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NHAS TC1 5Mbps Capacity\",'+
		'    \"value\": \"Yes\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NHAS TC2 5Mbps Capacity\",'+
		'    \"value\": \"No\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NFAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'    \"value\": \"Yes\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NFAS TC4 High Speed Tiers (greater or equal to 250Mbps)\",'+
		'    \"value\": \"No\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NFAS TC2 5Mbps Capacity\",'+
		'    \"value\": \"Yes\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'    \"value\": \"No\"'+
		'   },'+
		'   {'+
		'    \"name\": \"NCAS TC2 5Mbps Capacity\",'+
		'    \"value\": \"No\"'+
		'   }'+
		'  ],'+
		'  \"providerResources\": ['+
		'   {'+
		'    \"resourceType\": \"Copper Pair\",'+
		'    \"id\": \"CPI300000891117\",'+
		'    \"status\": \"Active\",'+
		'    \"serviceabilityClass\": \"12\"'+
		'   }'+
		'  ],'+
		'  \"resourceDetails\": ['+
		'   {'+
		'    \"ntdId\": \"NTD300000891117\",'+
		'    \"ntdLoc\": \"\",'+
		'    \"ntdInstallDate\": \"\",'+
		'    \"ntdType\": \"\",'+
		'    \"ntdPowerType\": \"\",'+
		'    \"batteryPowerUnit\": \"\",'+
		'    \"powerSupplywithBatteryBackupInstallDate\": \"\",'+
		'    \"batteryPowerUnitMonitored\": \"\"'+
		'   }'+
		'  ],'+
		'  \"messages\": ['+
		'   {'+
		'    \"code\": \"\",'+
		'    \"message\": \"\"'+
		'   }'+
		'  ]'+
		' }'+
		'}';
		TransitionSQResponseDTO obj = TransitionSQResponseDTO.parse(json);
		System.assert(obj != null);
	}
}