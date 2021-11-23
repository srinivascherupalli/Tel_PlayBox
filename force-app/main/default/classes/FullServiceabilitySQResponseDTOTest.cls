@IsTest
public class FullServiceabilitySQResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"correlationId\": \"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e\",'+
		' \"data\": {'+
		'  \"addressId\": \"\",'+
		'  \"serviceTypeQualifications\": [{'+
		'    \"serviceType\": \"Calling\",'+
		'    \"status\": \"Available\",'+
		'    \"serviceTransferIndicator\": \"\",'+
		'    \"statusReason\": \"NBN Calling is available at this Address\",'+
		'    \"infrastructurePlannedDate\": \"\",'+
		'    \"technologyType\": \"Fibre To The Node\",'+
		'    \"readyForServiceDate\": \"2016-04-30\",'+
		'    \"serviceabilityClass\": \"12\",'+
		'    \"newDevelopmentChargesApply\": \"No\",'+
		'    \"locationId\": \"LOC000061425812\",'+
		'    \"csaId\": \"CSA400000010875\",'+
		'    \"tc2EnabledCsa\": \"5000\",'+
		'    \"priorityAssistApplicable\": \"\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'    \"demandType\": \"\",'+
		'    \"providerResources\": [{'+
		'     \"resourceType\": \"Copper Pair\",'+
		'     \"id\": \"CPI300000891117\",'+
		'     \"status\": \"Active\",'+
		'     \"serviceabilityClass\": \"12\"'+
		'    }],'+
		'    \"characteristics\": [{'+
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
		'    \"infrastructurePlannedDate\": \"\",'+
		'    \"technologyType\": \"Fibre To The Node\",'+
		'    \"readyForServiceDate\": \"2016-04-30\",'+
		'    \"serviceabilityClass\": \"12\",'+
		'    \"newDevelopmentChargesApply\": \"No\",'+
		'    \"locationId\": \"LOC000061425812\",'+
		'    \"csaId\": \"CSA400000010875\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'    \"demandType\": \"\",'+
		'    \"providerResources\": [{'+
		'     \"resourceType\": \"Copper Pair\",'+
		'     \"id\": \"CPI300000891117\",'+
		'     \"status\": \"Active\",'+
		'     \"serviceabilityClass\": \"12\"'+
		'    }],'+
		'    \"characteristics\": [{'+
		'      \"name\": \"maxUpstreamSpeed\",'+
		'      \"value\": \"40 Mbps\"'+
		'     },'+
		'     {'+
		'      \"name\": \"maxDownstreamSpeed\",'+
		'      \"value\": \"100 Mbps\"'+
		'     },'+
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
		'	\"orderableTC2Capacity\": {'+
        '	\"maxBackhaul": \"\",'+
        '   \"maxSpareCopperPair": \"\",'+
        '	\"maxTransitioningCopperPair\": \"\"},'+
		'  \"additionalTrafficClassAvailability\": [{'+
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
		'    \"scheduledDates\": {'+
		'    	\"orderStabilityPeriodDate\": \"20120528\",'+
		'    	\"ceaseSaleDate\": \"20120528\"'+
		'    },'+
		'  \"unconditionedLocalLoop\": [{'+
		'   \"nbnResourceId\": \"300000891117\",'+
		'   \"unconditionedLocalLoopId\": \"\",'+
		'   \"demandType\": \"Standard Install\",'+
		'   \"maxDownstreamSpeed\": \"\",'+
		'   \"maxUpstreamSpeed\": \"\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'   \"serviceProviderId\": \"\"'+
		'  }],'+
		'  \"productResourceIdentifierDetails\": [{'+
		'   \"productResourceIdentifierID\": \"PRI300000891117\",'+
		'   \"serviceProviderId\": \"\",'+
		'   \"refCopperPairID\": \"\",'+
		'   \"maxDownstreamSpeed\": \"\",'+
		'   \"maxUpstreamSpeed\": \"\",'+
		'    \"appointmentRequired\": \"Yes\",'+
		'   \"nbnPriorityAssist\": \"\",'+
		'   \"portLinkage\": \"\",'+
		'   \"portDetails\": [{'+
		'     \"uniPortType\": \"UNI-V\",'+
		'     \"portId\": \"1-UNI-V1\"'+
		'    },'+
		'    {'+
		'     \"uniPortType\": \"UNI-D\",'+
		'     \"portId\": \"1-UNI-D1\"'+
		'    }'+
		'   ],'+
		'   \"refNTD\": \"\",'+
		'   \"batteryPowerStatus\": \"\",'+
		'   \"batteryInstallDate\": \"\",'+
		'   \"batteryMonitoringStatus\": \"\"'+
		'  }],'+
		'  \"resourceDetails\": [{'+
		'   \"preferredNTD\": \"Yes\",'+
		'   \"ntdId\": \"NTD300000891117\",'+
		'   \"ntdLoc\": \"\",'+
		'   \"ntdInstallDate\": \"\",'+
		'   \"ntdType\": \"\",'+
		'   \"ntdPowerType\": \"\",'+
		'   \"portDetails\": [{'+
		'    \"uniPortType\": \"UNI-D\",'+
		'    \"portId\": \"1-UNI-D1\",'+
		'    \"portStatus\": \"Free\"'+
		'   }],'+
		'   \"batteryPowerUnit\": \"\",'+
		'   \"powerSupplywithBatteryBackupInstallDate\": \"\",'+
		'   \"batteryPowerUnitMonitored\": \"\"'+
		'  }, {'+
		'   \"ntdId\": \"NTD300000891118\",'+
		'   \"ntdLoc\": \"\",'+
		'   \"ntdInstallDate\": \"\",'+
		'   \"ntdType\": \"\",'+
		'   \"ntdPowerType\": \"\",'+
		'   \"portDetails\": [{'+
		'    \"uniPortType\": \"UNI-D\",'+
		'    \"portId\": \"2-UNI-D1\",'+
		'    \"portStatus\": \"Used\"'+
		'   }],'+
		'   \"batteryPowerUnit\": \"\",'+
		'   \"powerSupplywithBatteryBackupInstallDate\": \"\",'+
		'   \"batteryPowerUnitMonitored\": \"\"'+
		'  }],'+
		'  \"messages\": [{'+
		'   \"code\": \"\",'+
		'   \"message\": \"\"'+
		'  }]'+
		' },'+
		' \"errors\": ['+
		' {'+
		'  \"code\": \"\",'+
		'  \"message\": \"\"'+
		' }'+
		'  ]'+
		'}';
		FullServiceabilitySQResponseDTO obj = FullServiceabilitySQResponseDTO.parse(json);
		System.assert(obj != null);
	}
	
	static testMethod void testcheckScheduledDatesPresent()
	{
		FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'Internet';
        serviceTypes.sessionAdmissionControl='4';
		
		
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
          fullServiceabilitySQRequestDTO.data.addressId = '181028856';
		fullServiceabilitySQRequestDTO.data.fnn= '0262334031';
		fullServiceabilitySQRequestDTO.data.nbnCustomerAuthorityDate='';
         fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'Business';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        fullServiceabilitySQRequestDTO.data.customerConsent = 'Yes';
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFULLSERVICEABILITY));
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQManager.fetchFullServicibilitySQResult(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        System.assert(fullServiceabilitySQResponseDTO.data.scheduledDates!=null);
	}
	
	static testMethod void testcheckOrderableTC2Present()
	{
		FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'Internet';
        serviceTypes.sessionAdmissionControl='4';
		
		
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
          fullServiceabilitySQRequestDTO.data.addressId = '181028856';
		fullServiceabilitySQRequestDTO.data.fnn= '0262334031';
		fullServiceabilitySQRequestDTO.data.nbnCustomerAuthorityDate='';
         fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'Business';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        fullServiceabilitySQRequestDTO.data.customerConsent = 'Yes';
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFULLSERVICEABILITY));
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQManager.fetchFullServicibilitySQResult(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        
        System.assert(fullServiceabilitySQResponseDTO.data.orderableTC2Capacity!=null);
        
	}
}