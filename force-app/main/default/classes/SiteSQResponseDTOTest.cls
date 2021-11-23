/*
 * Test class for SiteSQResponseDTO
 */

@IsTest
public class SiteSQResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"correlationId\": \"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e\",'+
		'  \"data\": {'+
		'    \"addressId\": \"\",'+
		'    \"serviceTypeQualifications\": ['+
		'      {'+
		'        \"serviceType\": \"Calling\",'+
		'        \"status\": \"Available\",'+
		'        \"serviceTransferIndicator\": \"\",'+
		'        \"statusReason\": \"NBN Calling is available at this Address\",'+
		'        \"technologyType\": \"Fibre To The Node\",'+
		'        \"readyForServiceDate\": \"2016-04-30\",'+
		'        \"serviceabilityClass\": \"12\",'+
		'        \"newDevelopmentChargesApply\": \"No\",'+
		'        \"locationId\": \"LOC000061425812\",'+
		'        \"csaId\": \"CSA400000010875\",'+
		'        \"priorityAssistApplicable\": \"\",'+
		'        \"appointmentRequired\": \"Yes\",'+
		'        \"demandType\": \"\",'+
		'        \"tc2EnabledCsa\": \"\",'+
		'        \"characteristics\": ['+
		'          {'+
		'            \"name\": \"Telephony Type\",'+
		'            \"value\": \"IP Telephony\"'+
		'          },'+
		'          {'+
		'            \"name\": \"Telephony Type\",'+
		'            \"value\": \"Standard\"'+
		'          }'+
		'        ],'+
		'        \"providerResources\": ['+
		'          {'+
		'            \"resourceType\": \"Copper Pair\",'+
		'            \"id\": \"CPI300000891117\",'+
		'            \"status\": \"Active\",'+
		'            \"serviceabilityClass\": \"12\"'+
		'          }'+
		'        ]'+
		'      },'+
		'      {'+
		'        \"serviceType\": \"Internet\",'+
		'        \"status\": \"Available\",'+
		'        \"serviceTransferIndicator\": \"\",'+
		'        \"statusReason\": \"NBN Internet is available at this Address\",'+
		'        \"technologyType\": \"Fibre To The Node\",'+
		'        \"readyForServiceDate\": \"2016-04-30\",'+
		'        \"serviceabilityClass\": \"12\",'+
		'        \"newDevelopmentChargesApply\": \"No\",'+
		'        \"locationId\": \"LOC000061425812\",'+
		'        \"csaId\": \"CSA400000010875\",'+
		'  '+
		'        \"appointmentRequired\": \"Yes\",'+
		'        \"demandType\": \"\",'+
		'  '+
		'        \"characteristics\": ['+
		'          {'+
		'            \"name\": \"maxUpstreamSpeed\",'+
		'            \"value\": \"40 Mbps\"'+
		'          },'+
		'          {'+
		'            \"name\": \"maxDownstreamSpeed\",'+
		'            \"value\": \"100 Mbps\"'+
		'          },'+
		'          {'+
		'            \"name\": \"TC4 Downstream Upper Rate\",'+
		'            \"value\": \"100 Mbps\"'+
		'          },'+
		'          {'+
		'            \"name\": \"TC4 Downstream Lower Rate\",'+
		'            \"value\": \"62 Mbps\"'+
		'          },'+
		'          {'+
		'            \"name\": \"TC4 Upstream Upper Rate\",'+
		'            \"value\": \"40 Mbps\"'+
		'          },'+
		'          {'+
		'            \"name\": \"TC4 Upstream Lower Rate\",'+
		'            \"value\": \"21 Mbps\"'+
		'          }'+
		'        ],'+
		'        \"providerResources\": ['+
		'          {'+
		'            \"resourceType\": \"Copper Pair\",'+
		'            \"id\": \"CPI300000891117\",'+
		'            \"status\": \"Active\",'+
		'            \"serviceabilityClass\": \"12\"'+
		'          }'+
		'        ]'+
		'      }'+
		'    ],'+
	    '	\"orderableTC2Capacity\": {'+
        '	\"maxBackhaul": \"\",'+
        '   \"maxSpareCopperPair": \"\",'+
        '	\"maxTransitioningCopperPair\": \"\"},'+
		'    \"additionalTrafficClassAvailability\": ['+
		'      {'+
		'        \"name\": \"NWAS TC1 150Kbps Capacity\",'+
		'        \"value\": \"Yes\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NHAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'        \"value\": \"No\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NHAS TC1 5Mbps Capacity\",'+
		'        \"value\": \"Yes\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NHAS TC2 5Mbps Capacity\",'+
		'        \"value\": \"No\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NFAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'        \"value\": \"Yes\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NFAS TC4 High Speed Tiers (greater or equal to 250Mbps)\",'+
		'        \"value\": \"No\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NFAS TC2 5Mbps Capacity\",'+
		'        \"value\": \"Yes\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)\",'+
		'        \"value\": \"No\"'+
		'      },'+
		'      {'+
		'        \"name\": \"NCAS TC2 5Mbps Capacity\",'+
		'        \"value\": \"No\"'+
		'      }'+
		'    ],'+
		'    \"scheduledDates\": {'+
		'      \"orderStabilityPeriodDate\": \"20120528\",'+
		'      \"ceaseSaleDate\": \"20120528\"'+
		'    },'+
		'    \"unconditionedLocalLop\": ['+
		'      {'+
		'        \"nbnResourceId\": \"300000891117\",'+
		'        \"unconditionedLocalLoopId\": \"\",'+
		'        \"demandType\": \"\",'+
		'        \"maxDownstreamSpeed\": \"\",'+
		'        \"maxUpstreamSpeed\": \"\",'+
		'        \"appointmentRequired\": \"Yes\",'+
		'        \"serviceProviderId\": \"\"'+
		'      }'+
		'    ],'+
		'    \"productResourceIdentifierDetails\": ['+
		'      {'+
		'        \"productResourceIdentifierID\": \"PRI300000891117\",'+
		'        \"serviceProviderId\": \"\",'+
		'        \"refCopperPairID\": \"\",'+
		'        \"maxDownstreamSpeed\": \"\",'+
		'        \"maxUpstreamSpeed\": \"\",'+
		'        \"nbnPriorityAssist\": \"\",'+
		'        \"appointmentRequired\": \"Yes\",'+
		'        \"portLinkage\": \"\",'+
		'        \"portDetails\": ['+
		'          {'+
		'            \"uniPortType\": \"UNI-V\",'+
		'            \"portId\": \"1-UNI-V1\"'+
		'          },'+
		'          {'+
		'            \"uniPortType\": \"UNI-D\",'+
		'            \"portId\": \"1-UNI-D1\"'+
		'          }'+
		'        ],'+
		'        \"refNTD\": \"\",'+
		'        \"batteryPowerStatus\": \"\",'+
		'        \"batteryInstallDate\": \"\",'+
		'        \"batteryMonitoringStatus\": \"\",'+
		'        \"ntdLoc\": \"INDOOR\",'+
		'        \"ntdInstallDate\": \"2013-10-01T12:00:00Z\",'+
		'        \"ntdType\": \"INTERNAL\",'+
		'        \"ntdPowerType\": \"AC\"'+
		'      }'+
		'    ],'+
		'    \"resourceDetails\": ['+
		'      {'+
		'        \"ntdId\": \"NTD300000891117\",'+
		'        \"ntdLoc\": \"\",'+
		'        \"ntdInstallDate\": \"\",'+
		'        \"ntdType\": \"\",'+
		'        \"ntdPowerType\": \"\",'+
		'        \"portDetails\": ['+
		'          {'+
		'            \"uniPortType\": \"\",'+
		'            \"portId\": \"\",'+
		'            \"portStatus\": \"\"'+
		'          }'+
		'        ],'+
		'        \"batteryPowerUnit\": \"\",'+
		'        \"powerSupplywithBatteryBackupInstallDate\": \"\",'+
		'        \"batteryPowerUnitMonitored\": \"\"'+
		'      }'+
		'    ],'+
		'    \"messages\": ['+
		'      {'+
		'        \"code\": \"\",'+
		'        \"message\": \"\"'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		SiteSQResponseDTO obj = SiteSQResponseDTO.parse(json);
		System.assert(obj != null);
	}
	static testMethod void testcheckOrderableTC2Present()
	{
		SiteSQRequestDTO reqObj = new SiteSQRequestDTO();
        reqObj.data  = new SiteSQRequestDTO.Data();
        reqObj.data.adborId = '1423';
        reqObj.data.customerAuthorityDate = '12-July-2017';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORSITE));
        SiteSQResponseDTO sQResponseDTO=SQManager.fetchSiteSQResult(reqObj);
        Test.stopTest();
        
        System.assert(sQResponseDTO.data.orderableTC2Capacity!=null);
        
	}
}