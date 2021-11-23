@isTest
global class MockSQServiceSuccessResponseGenerator implements HttpCalloutMock{
	public static final String SUCCESSTEST_SQFORSITE = 'testSuccess_checkSQForSite';
    public static final String SUCCESSTEST_SQFORTRANSITION = 'testSuccess_checkSQForTransition';
    public static final String SUCCESSTEST_SQFORMOVE = 'testSuccess_checkSQForMove';
    public static final String SUCCESSTEST_SQFULLSERVICEABILITY = 'testSuccessCheckSQForFullServiceability';
    public static final String SUCCESSTEST_SQNUMBERPORTABILITY = 'testSuccessCheckSQForPortability';
    static final Integer HTTP200 = 200;

    protected String testName;

    public MockSQServiceSuccessResponseGenerator(String testName) {
        this.testName = testName;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        if(this.testName == SUCCESSTEST_SQFORSITE){
            res.setStatusCode(HTTP200);
            res.setBody(getSuccessResponseBodyForSiteSQ());
        }else if(this.testName == SUCCESSTEST_SQFORTRANSITION){
            res.setStatusCode(HTTP200);
            res.setBody(getSuccessResponseBodyForTransitionSQ());
        }else if(this.testName == SUCCESSTEST_SQFORMOVE){
            res.setStatusCode(HTTP200);
            res.setBody(getSuccessResponseBodyForMoveSQ());
        }else if(this.testName == SUCCESSTEST_SQFULLSERVICEABILITY){
            res.setStatusCode(HTTP200);
            res.setBody(getSuccessResponseBodyForFullServiceability());
        }else if(this.testName == SUCCESSTEST_SQNUMBERPORTABILITY){
            res.setStatusCode(HTTP200);
            res.setBody(getSuccessResponseBodyForNumberPortability());
        }else if (this.testName == 'testToken') {
    		res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
            res.setStatusCode(200);
    	} 
        return res;
    }

    static String getSuccessResponseBodyForSiteSQ(){
        return '{'+
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
		'		\"providerResources\": ['+
		'			{'+
		'				\"resourceType\": \"Copper Pair\",'+
		'				\"id\": \"CPI300000891117\",'+
		'				\"status\": \"Active\",'+
		'				\"serviceabilityClass\": \"12\"'+
		'			}'+
		'		]'+
		'      }'+
		'    ],'+
		'     \"orderableTC2Capacity\": {'+
        '          \"maxBackhaul\": \"\",'+
        '          \"maxSpareCopperPair\": \"\",'+
        '          \"maxTransitioningCopperPair\": \"\"},'+
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
    }  

    static String getSuccessResponseBodyForTransitionSQ(){
        return '{'+
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
		'  \"scheduledDates\": {'+
		'      \"orderStabilityPeriodDate\": \"20120528\",'+
		'      \"ceaseSaleDate\": \"20120528\"'+
		'   },'+
		'     \"orderableTC2Capacity\": {'+
        '          \"maxBackhaul\": \"\",'+
        '          \"maxSpareCopperPair\": \"\",'+
        '          \"maxTransitioningCopperPair\": \"\"},'+
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
    }

    static String getSuccessResponseBodyForMoveSQ(){
        return '{'+
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
    }
    
    static String getSuccessResponseBodyForFullServiceability(){
        return '{'+
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
		'     \"orderableTC2Capacity\": {'+
        '          \"maxBackhaul\": \"\",'+
        '          \"maxSpareCopperPair\": \"\",'+
        '          \"maxTransitioningCopperPair\": \"\"},'+
		
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
		'  \"scheduledDates\":{'+
		'  \"orderStabilityPeriodDate\": \"20120528\",'+
		'  \"ceaseSaleDate\": \"20120528\" },'+
		'  \"unconditionedLocalLoop\": [{'+
		'   \"nbnResourceId\": \"300000891117\",'+
		'   \"unconditionedLocalLoopID\": \"\",'+
		'   \"demandType\": \"Standard Install\",'+
		'   \"maxDownstreamSpeed\": \"\",'+
		'   \"maxUpstreamSpeed\": \"\",'+
		'   \"serviceProviderId\": \"\"'+
		'  }],'+
		'  \"productResourceIdentifierDetails\": [{'+
		'   \"productResourceIdentifierID\": \"PRI300000891117\",'+
		'   \"serviceProviderId\": \"\",'+
		'   \"refCopperPairID\": \"\",'+
		'   \"maxDownstreamSpeed\": \"\",'+
		'   \"maxUpstreamSpeed\": \"\",'+
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
    }
    
    static String getSuccessResponseBodyForNumberPortability(){
        return '{'+
		'    \"status\":200,'+
		'    \"data\": {'+
		'        \"numberDetails\": ['+
		'            {'+
		'                \"fullNationalNumber\":\"1300000086\",'+
		'                \"fnnPortabilityIndicator\":\"N\",'+
		'                \"reason\":\"The FNN cannot be ported into Telstra network as the given FNN status is ACTIVE\",'+
		'                \"code\":\"SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"131234\",'+
		'                \"fnnPortabilityIndicator\":\"Y\",'+
		'                \"reason\":\"The FNN can be ported into Telstra network\",'+
		'                \"code\":\"SUCCESS\"'+
		'            },{'+
		'                \"fullNationalNumber\":\"1800000011\",'+
		'                \"fnnServiceabilityIndicator\":\"N\",'+
		'                \"reason\":\"The FNN is managed by Telstra\",'+
		'				 \"portInType\": \"Donor Return\",'+
		'                \"code\":\"SUCCESS\"'+
		'            }'+
		' '+
		'        ]'+
		'    },'+
		'    \"errors\": {'+
		'        \"errorDetails\": ['+
		'            {'+
		'                \"fullNationalNumber\":\"0700000000\",'+
		'                \"message\":\"FNN not found\",'+
		'                \"code\":\"FNN_NOT_FOUND\"'+
		'            },'+
		'            {'+
		'                \"fullNationalNumber\":\"0300000000\",'+
		'                \"message\":\"FNN not found\",'+
		'                \"code\":\"FNN_NOT_FOUND\"'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
    }
    
    static testMethod void TestMethod1(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
    }
}