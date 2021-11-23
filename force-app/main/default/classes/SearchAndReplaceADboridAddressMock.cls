global class SearchAndReplaceADboridAddressMock implements HttpCalloutMock{    
	global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(getResponse());
    return res;
  }
    
    global String getResponse(){
        return '{'+
		'	\"code\": 200,'+
		'	\"time\": \"2016-08-16T10:53:09+10:00\",'+
		'	\"data\": {'+
		'		\"transactionStatus\": \"success\",'+
		'		\"structured\": {'+
		'			\"addresses\": {'+
		'				\"addressSummaryType\": \"PropertyAddressSummary\",'+
		'				\"addressId\": 180057100,'+
		'				\"addressType\": \"Property With Number\",'+
		'				\"confirmed\": true,'+
		'				\"subAddressType\": \"\",'+
		'				\"planNumber\": \"DP1135205\",'+
		'				\"parceltype1\": \"F\",'+
		'				\"parceldescriptiontype1\": \"L\",'+
		'				\"parcelDescriptor1 \": 1,'+
		'				\"parceltype2\": \"\",'+
		'				\"parceldescriptiontype2\": \"\",'+
		'				\"parcelDescriptor2\": \"\",'+
		'				\"name\": \"\",'+
		'				\"ruralmailNumber\": \"\",'+
		'				\"ruralmailType\": \"\",'+
		'				\"fsam\": \"\",'+
		'				\"condorCode\": \"WLNGNG\",'+
		'				\"reqaddformatout\": \"structured\",'+
		'				\"postcode\": 2500,'+
		'				\"state\": \"NSW\",'+
		'				\"localityName\": \"WOLLONGONG\",'+
		'				\"streetName\": \"CROWN\",'+
		'				\"streetType\": \"STREET\",'+
		'				\"streetSuffix\": \"\",'+
		'				\"numSubaddresses\": 7,'+
		'				\"subaddresses\": {'+
		'					\"SubAddresses\": {'+
		'						\"Level1\": [{'+
		'							\"SubAddressType\": \"BUILDING\",'+
		'							\"parentID\": 180057100,'+
		'							\"ID\": 426860877,'+
        '						    \"BUname\": \"EUREKA TOWER\",'+
		'							\"AddressType\": \"abc\",'+
		'							\"from\": 1,'+
		'							\"Level2\": [{'+
		'									\"SubAddressType\": \"Ground Floor\",'+
		'									\"parentID\": 426860877,'+
		'									\"ID\": 419594516,'+
		'									\"AddressType\": \"Complex - Floor/Level\",'+
		'									\"Level3\": [{'+
		'											\"SubAddressType\": \"Unit\",'+
		'											\"parentID\": 419594516,'+
		'											\"ID\": 426978197,'+
		'											\"AddressType\": \" Complex - Flat/Unit\",'+
		'											\"from\": 1,'+
		'											\"Confirmed\": true'+
		'										},'+
		'										{'+
		'											\"SubAddressType\": \"Unit\",'+
		'											\"parentID\": 419594516,'+
		'											\"ID\": 426878193,'+
		'											\"AddressType\": \" Complex - Flat/Unit\",'+
		'											\"from\": 2,'+
		'											\"Confirmed\": true'+
		'										},'+
		'										{'+
		'											\"SubAddressType\": \"Unit\",'+
		'											\"parentID\": 419594516,'+
		'											\"ID\": 426978198,'+
		'											\"AddressType\": \" Complex - Flat/Unit\",'+
		'											\"from\": 3,'+
		'											\"Confirmed\": true'+
		'										}'+
		'									],'+
		'									\"Confirmed\": true'+
		'								},'+
		'								{'+
		'									\"SubAddressType\": \"Level\",'+
		'									\"parentID\": 426860877,'+
		'									\"ID\": 419794487,'+
		'									\"AddressType\": \"Complex - Floor/Level\",'+
		'									\"from\": 1,'+
		'									\"Confirmed\": true'+
		'								},'+
		'								{'+
		'									\"SubAddressType\": \"Level\",'+
		'									\"parentID\": 426860877,'+
		'									\"ID\": 419787211,'+
		'									\"AddressType\": \"Complex - Floor/Level\",'+
		'									\"from\": 2,'+
		'									\"Confirmed\": true'+
		'								}'+
		'							],'+
		'							\"Confirmed\": true'+
		'						}]'+
		'					}'+
		'				},'+
		'				\"propertyName\": \"\",'+
		'				\"propertyNumberFrom\": 121,'+
		'				\"propertyNumberTo\": 0,'+
		'				\"propertyNumberSuffixFrom\": \"\",'+
		'				\"propertyNumberSuffixTo\": \"\"'+
		'			},'+
		'			\"serviceLocation\": {'+
		'				\"readyForServiceDate\": \"\",'+
		'				\"locationId\": \"\",'+
		'				\"facsRealm\": 74,'+
		'				\"exchangeServiceArea\": \"WLGG\",'+
		'				\"customerServiceAreaId\": \"\",'+
		'				\"latitude\": \"-34:25:33.4\",'+
		'				\"longitude\": \"150:53:46.9\"'+
		'			}'+
		'		},'+
		'		\"unstructuredAUPost\": {'+
		'			\"addresses\": {'+
		'				\"addressSummaryType\": \"FormattedAddressSummary\",'+
		'				\"addressId\": 180057100,'+
		'				\"addressType\": \"Property Address With Number\",'+
		'				\"confirmed\": true,'+
		'				\"parcelDescriptor2\": \"\",'+
		'				\"parcelDescriptor1 \": 1,'+
		'				\"planNumber\": \"DP1135205\",'+
		'				\"ruralmailNumber\": \"\",'+
		'				\"subAddressType\": \"\",'+
		'				\"parceltype2\": \"\",'+
		'				\"parceltype1\": \"F\",'+
		'				\"parceldescriptiontype1\": \"L\",'+
		'				\"parceldescriptiontype2\": \"\",'+
		'				\"propertyName\": \"\",'+
		'				\"fsam\": \"\",'+
		'				\"condorCode\": \"WLNGNG\",'+
		'				\"reqaddformatout\": \"unstructuredAUPost\",'+
		'				\"postcode\": 2500,'+
		'				\"state\": \"NSW\",'+
		'				\"localityName\": \"WOLLONGONG\",'+
		'				\"addressline1\": \"121 CROWN ST,\",'+
		'				\"addressline2\": \"\",'+
		'				\"addressline3\": \"\"'+
		'			},'+
		'			\"serviceLocation\": {'+
		'				\"readyForServiceDate\": \"\",'+
		'				\"locationId\": \"\",'+
		'				\"facsRealm\": 74,'+
		'				\"exchangeServiceArea\": \"WLGG\",'+
		'				\"customerServiceAreaId\": \"\",'+
		'				\"latitude\": \"-34:25:33.4\",'+
		'				\"longitude\": \"150:53:46.9\"'+
		'			}'+
		'		}'+
		'	}'+
		'}';
    }
}