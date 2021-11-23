@isTest
global class MockAddressResponseGenerator implements HTTPCalloutMock{
	public static String SEARCH_ADBORID_SUCCESS_CHILD = 'testSearchAddressByAdborIdSuccessForChild';
    public static String SEARCH_ADBORID_SUCCESS_PARENT = 'testSearchAddressByAdborIdSuccessForParent';
    public static String SEARCH_ADBORID_SUCCESS_FAILURE = 'testSearchAddressByAdborIdFailure';
	
	private String testName;
    public MockAddressResponseGenerator(String testCaseName){
        testName = testCaseName;
    }
	public MockAddressResponseGenerator(){
    }
	
	global HttpResponse respond(HttpRequest req) {
    	HttpResponse res = new HttpResponse();
    	res.setHeader('Content-Type', 'application/json');
    	String endPoint = req.getEndpoint();

    	if(endPoint.contains('/address-search/addresses?')) {
            String js = respAddresses();
    		res.setBody(js);
    	} else if (endPoint.contains('token')) {
    		res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
    	} else if(testName == SEARCH_ADBORID_SUCCESS_PARENT){
            res.setBody(getSearchbyAdborIdResponseForParent());
        } else if(testName == SEARCH_ADBORID_SUCCESS_CHILD){
            res.setBody(getSearchByAdborIdResponseForChild());
        } else if(testName == SEARCH_ADBORID_SUCCESS_FAILURE){
            res.setStatusCode(5013);
            res.setBody(getSearchByAdborIdFailureResponse());
            return res;
        }
    	res.setStatusCode(200);
    	return res;
    }
    
    
    public String responseEASTAddresses(){
    	String json = '{'
        +   '\"data\": [{\"greaterLocality\": \"\",\"serviceLocation\": {\"connectivityServiceAreaId\": \"\",\"locationId\": \"\",\"exchangeServiceAreaId\": \"HARB\",\"facsRealm\": \"20\"},'
		+   '\"numberOfSubAddresses\": \"50\",\"localityAbbreviation\": \"\",\"state\": \"NSW\",\"long\": \"\",\"id\": \"470318296\",\"name\": \"SEACHANGE ON PAVILION\",\"ruralMailType\": \"\",\"numberTo\": \"67\",\"planNumber\": \"\",'
        +   '\"subAddress\": {\"subAddressComponents\": {\"subAddressComponents\": [{\"subAddressComponents\": {\"id\": \"266095637\",\"parentAddressId\": \"264007897\",\"subAddressType\": \"RM\",\"number\": \"LIFTPHO\"},\"id\": \"264007897\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"G\",\"streetName\": \"\",\"streetType\": \"\"}, {'
        +              '\"subAddressComponents\": [{\"id\": \"416869685\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"1\",\"subAddressComponents\": [{\"id\": \"418703277\",\"parentAddressId\": \"416869685\",\"subAddressType\": \"CONF\",\"number\": \"80\"}]}, {\"id\": \"619652759\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"10\"}, {\"id\": \"417559113\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"11\"}, {'
        +                  '\"id\": \"416765222\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"12\"}, {\"id\": \"417859108\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"13\"'
        +              '}, {\"id\": \"417959108\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"14\"}, {\"id\": \"417659112\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"15\"}, {'
        +                  '\"id\": \"416582076\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"16\"}, {\"id\": \"416181624\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"17\"}, {\"id\": \"416295442\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"19\"}, {\"id\": \"417659113\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"2\"}, {'
        +                  '\"id\": \"416286844\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"20\"}, {\"id\": \"417454174\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"21\"'
        +              '}, {\"id\": \"417959111\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"22\"}, {\"id\": \"417659115\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"23\"}, {\"id\": \"416758953\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"24\"}, {\"id\": \"417659116\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"25\"}, {\"id\": \"416272212\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"26\"}, {\"id\": \"416372190\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"27\"'
        +              '}, {\"id\": \"417859114\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"28\"}, {\"id\": \"418059112\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"29\"}, {\"id\": \"417116539\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"3\"}, {\"id\": \"416350062\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"30\"}, {\"id\": \"416882564\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"31\"}, {\"id\": \"417759121\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"32\"}, {\"id\": \"417898637\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"33\"}, {'
        +                  '\"id\": \"417148603\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"34\"'
        +              '}, {\"id\": \"417065180\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"35\"}, {\"id\": \"417759123\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"36\"}, {\"id\": \"417092282\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"4\"}, {\"id\": \"418059116\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"5\"}, {\"id\": \"417456157\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"6\"}, {\"id\": \"417475426\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"7\"}, {\"id\": \"417759124\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"8\"}, {'
        +                  '\"id\": \"416184907\",\"parentAddressId\": \"264007861\",\"subAddressType\": \"U\",\"number\": \"35\"}],'
        +               '\"id\": \"264007861\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"1\",\"streetType\": \"\"}, {\"id\": \"264007860\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"2\",\"streetType\": \"\"}, {\"id\": \"264007859\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"3\",\"streetType\": \"\"'
        +           '}, {\"subAddressComponents\": {\"id\": \"417959109\",\"parentAddressId\": \"264007857\",\"subAddressType\": \"U\",\"number\": \"18\"},\"id\": \"264007857\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"4\",\"streetType\": \"\"'
        +           '}, {\"subAddressComponents\": [{\"id\": \"266095661\",\"parentAddressId\": \"264007856\",\"subAddressType\": \"U\",\"number\": \"41\"}, {\"id\": \"427300828\",\"parentAddressId\": \"264007856\",\"subAddressType\": \"U\",\"number\": \"42\"}, {\"id\": \"427400828\",\"parentAddressId\": \"264007856\",\"subAddressType\": \"U\",\"number\": \"43\"}],\"id\": \"264007856\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"5\",\"streetType\": \"\"'
        +           '}, {\"subAddressComponents\": {\"id\": \"427500828\",\"parentAddressId\": \"419439234\",\"subAddressType\": \"U\",\"number\": \"44\"},\"id\": \"419439234\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"6\",\"streetType\": \"\"'
        +           '}, {\"id\": \"427600828\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"264007855\",\"subAddressType\": \"L\",\"streetName\": \"\",\"number\": \"7\",\"streetType\": \"\"}],'
        +           '\"id\": \"264007855\",\"streetTypeSuffix\": \"\",\"parentAddressId\": \"470318296\",\"subAddressType\": \"BG\",\"streetName\": \"\",\"number\": \"\",\"streetType\": \"\"}},'
        +    '\"streetType\": \"ST\",\"numberSuffix\": \"\",\"lat\": \"\",\"numberToPrefix\": \"\",\"numberPrefix\": \"\",\"status\": \"CONFIRMED\",\"locationDescription\": \"\",\"number\": \"63\",\"streetName\": \"PAVILION\",\"addressType\": \"Property With Number\",\"postcode\": \"2096\",\"rangeIncrement\": \"\",\"streetTypeSuffix\": \"\",\"postalDeliveryType\": \"\",\"locality\": \"QUEENSCLIFF\",\"numberToSuffix\": \"\",\"searchConfidence\": \"\"}]'
		+    '}';
    	
    	return json;
    
    }
    
    
    public String respAddresses(){
    	
		String json = '{'+
		'    \"data\": ['+
		'        {'+
		'            \"greaterLocality\": \"MELBOURNE CBD\",'+
		'            \"serviceLocation\": {'+
		'                \"connectivityServiceAreaId\": \"\",'+
		'                \"locationId\": \"\",'+
		'                \"exchangeServiceAreaId\": \"LONS\",'+
		'                \"facsRealm\": \"21\"'+
		'            },'+
		'            \"numberOfSubAddresses\": \"0\",'+
		'            \"localityAbbreviation\": \"MELB\",'+
		'            \"state\": \"VIC\",'+
		'            \"long\": \"144\",'+
		'            \"id\": \"418956988\",'+
		'            \"name\": \"LONSDALE EXCH\",'+
		'            \"ruralMailType\": \"\",'+
		'            \"numberTo\": \"456\",'+
		'            \"planNumber\": \"\",'+
		'            \"subAddress\": \"\",'+
		'            \"streetType\": \"ST\",'+
		'            \"numberSuffix\": \"\",'+
		'            \"lat\": \"12\",'+
		'            \"numberToPrefix\": \"\",'+
		'            \"numberPrefix\": \"\",'+
		'            \"status\": \"CONFIRMED\",'+
		'            \"locationDescription\": \"\",'+
		'            \"number\": \"447\",'+
		'            \"streetName\": \"LONSDALE\",'+
		'            \"addressType\": \"Property With Number\",'+
		'            \"postcode\": \"3000\",'+
		'            \"rangeIncrement\": \"2\",'+
		'            \"streetTypeSuffix\": \"\",'+
		'            \"postalDeliveryType\": \"\",'+
		'            \"locality\": \"MELBOURNE\",'+
		'            \"numberToSuffix\": \"\",'+
		'            \"searchConfidence\": \"\"'+
		'        },'+
		'        {'+
		'            \"greaterLocality\": \"MELBOURNE CBD\",'+
		'            \"serviceLocation\": {'+
		'                \"connectivityServiceAreaId\": \"\",'+
		'                \"locationId\": \"\",'+
		'                \"exchangeServiceAreaId\": \"LONS\",'+
		'                \"facsRealm\": \"21\"'+
		'            },'+
		'            \"numberOfSubAddresses\": \"26\",'+
		'            \"localityAbbreviation\": \"MELB\",'+
		'            \"state\": \"VIC\",'+
		'            \"long\": \"144\",'+
		'            \"id\": \"418956987\",'+
		'            \"name\": \"LONSDALE EXCH\",'+
		'            \"ruralMailType\": \"\",'+
		'            \"numberTo\": \"453\",'+
		'            \"planNumber\": \"\",'+
		'            \"subAddress\": {'+
		'                \"subAddressComponents\": ['+
		'                    {'+
		'                        \"subAddressComponents\": ['+
		'                            {'+
		'                                \"id\": \"414413932\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"414213931\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"10\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"subAddressComponents\": {'+
		'                                    \"id\": \"419352089\",'+
		'                                    \"parentAddressId\": \"415713931\",'+
		'                                    \"subAddressType\": \"RM\",'+
		'                                    \"number\": \"1\"'+
		'                                },'+
		'                                \"id\": \"415713931\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"414213931\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"9\",'+
		'                                \"streetType\": \"\"'+
		'                            }'+
		'                        ],'+
		'                        \"id\": \"414213931\",'+
		'                        \"streetTypeSuffix\": \"\",'+
		'                        \"parentAddressId\": \"418956987\",'+
		'                        \"subAddressType\": \"BG\",'+
		'                        \"streetName\": \"\",'+
		'                        \"number\": \"\",'+
		'                        \"streetType\": \"\"'+
		'                    },'+
		'                    {'+
		'                        \"subAddressComponents\": ['+
		'                            {'+
		'                                \"subAddressComponents\": ['+
		'                                    {'+
		'                                        \"id\": \"265639888\",'+
		'                                        \"parentAddressId\": \"264390199\",'+
		'                                        \"subAddressType\": \"RM\",'+
		'                                        \"number\": \"LIFTPHO\"'+
		'                                    },'+
		'                                    {'+
		'                                        \"id\": \"264390200\",'+
		'                                        \"parentAddressId\": \"264390199\",'+
		'                                        \"subAddressType\": \"SE\",'+
		'                                        \"number\": \"4D\"'+
		'                                    }'+
		'                                ],'+
		'                                \"id\": \"264390199\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"G\",'+
		'                                \"streetName\": \"\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390198\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"1\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390189\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"10\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390188\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"11\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"subAddressComponents\": {'+
		'                                    \"id\": \"419591805\",'+
		'                                    \"parentAddressId\": \"264390187\",'+
		'                                    \"subAddressType\": \"RM\",'+
		'                                    \"number\": \"COMMS\"'+
		'                                },'+
		'                                \"id\": \"264390187\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"12\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390186\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"13\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390185\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"14\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"419876224\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"15\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390197\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"2\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390196\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"3\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390195\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"4\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390194\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"5\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390193\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"6\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390192\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"7\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390191\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"8\",'+
		'                                \"streetType\": \"\"'+
		'                            },'+
		'                            {'+
		'                                \"id\": \"264390190\",'+
		'                                \"streetTypeSuffix\": \"\",'+
		'                                \"parentAddressId\": \"264390184\",'+
		'                                \"subAddressType\": \"L\",'+
		'                                \"streetName\": \"\",'+
		'                                \"number\": \"9\",'+
		'                                \"streetType\": \"\"'+
		'                            }'+
		'                        ],'+
		'                        \"id\": \"264390184\",'+
		'                        \"streetTypeSuffix\": \"\",'+
		'                        \"parentAddressId\": \"418956987\",'+
		'                        \"subAddressType\": \"BG\",'+
		'                        \"streetName\": \"\",'+
		'                        \"number\": \"1\",'+
		'                        \"streetType\": \"\"'+
		'                    },'+
		'                    {'+
		'                        \"subAddressComponents\": {'+
		'                            \"id\": \"418771983\",'+
		'                            \"streetTypeSuffix\": \"\",'+
		'                            \"parentAddressId\": \"418671992\",'+
		'                            \"subAddressType\": \"RM\",'+
		'                            \"streetName\": \"\",'+
		'                            \"number\": \"1\",'+
		'                            \"streetType\": \"\"'+
		'                        },'+
		'                        \"id\": \"418671992\",'+
		'                        \"streetTypeSuffix\": \"\",'+
		'                        \"parentAddressId\": \"418956987\",'+
		'                        \"subAddressType\": \"G\",'+
		'                        \"streetName\": \"\",'+
		'                        \"number\": \"\",'+
		'                        \"streetType\": \"\"'+
		'                    }'+
		'                ]'+
		'            },'+
		'            \"streetType\": \"ST\",'+
		'            \"numberSuffix\": \"\",'+
		'            \"lat\": \"12\",'+
		'            \"numberToPrefix\": \"\",'+
		'            \"numberPrefix\": \"\",'+
		'            \"status\": \"CONFIRMED\",'+
		'            \"locationDescription\": \"\",'+
		'            \"number\": \"447\",'+
		'            \"streetName\": \"LONSDALE\",'+
		'            \"addressType\": \"Property With Number\",'+
		'            \"postcode\": \"3000\",'+
		'            \"rangeIncrement\": \"2\",'+
		'            \"streetTypeSuffix\": \"\",'+
		'            \"postalDeliveryType\": \"\",'+
		'            \"locality\": \"MELBOURNE\",'+
		'            \"numberToSuffix\": \"\",'+
		'            \"searchConfidence\": \"\"'+
		'        }'+
		'    ]'+
		'}';
		
        return json;
    }
	private String getSearchbyAdborIdResponseforParent(){
        String json = '{'+
        '   \"code\": 200,'+
        '   \"time\": \"2016-08-16T10:53:09+10:00\",'+
        '   \"data\": {'+
        '       \"transactionStatus\": \"success\",'+
        '       \"structured\": {'+
        '           \"addresses\": {'+
        '               \"addressSummaryType\": \"PropertyAddressSummary\",'+
        '               \"addressId\": 180057100,'+
        '               \"addressType\": \"Property With Number\",'+
        '               \"confirmed\": true,'+
        '               \"subAddressType\": \"\",'+
        '               \"planNumber\": \"DP1135205\",'+
        '               \"parceltype1\": \"F\",'+
        '               \"parceldescriptiontype1\": \"L\",'+
        '               \"parcelDescriptor1 \": 1,'+
        '               \"parceltype2\": \"\",'+
        '               \"parceldescriptiontype2\": \"\",'+
        '               \"parcelDescriptor2\": \"\",'+
        '               \"name\": \"\",'+
        '               \"ruralmailNumber\": \"\",'+
        '               \"ruralmailType\": \"\",'+
        '               \"fsam\": \"\",'+
        '               \"condorCode\": \"WLNGNG\",'+
        '               \"reqaddformatout\": \"structured\",'+
        '               \"postcode\": 2500,'+
        '               \"state\": \"NSW\",'+
        '               \"localityName\": \"WOLLONGONG\",'+
        '               \"streetName\": \"CROWN\",'+
        '               \"streetType\": \"STREET\",'+
        '               \"streetSuffix\": \"\",'+
        '               \"numSubaddresses\": 7,'+
        '               \"subaddresses\": {'+
        '                   \"SubAddresses\": {'+
        '                       \"Level1\": [{'+
        '                           \"SubAddressType\": \"BUILDING\",'+
        '                           \"parentID\": 180057100,'+
        '                           \"ID\": 426860877,'+
        '                           \"BUname\": \"EUREKA TOWER\",'+
        '                           \"AddressType\": \"abc\",'+
        '                           \"from\": 1,'+
        '                           \"Level2\": [{'+
        '                                   \"SubAddressType\": \"Ground Floor\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419594516,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"Level3\": [{'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426978197,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 1,'+
        '                                           \"Confirmed\": true'+
        '                                       },'+
        '                                       {'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426878193,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 2,'+
        '                                           \"Confirmed\": true'+
        '                                       },'+
        '                                       {'+
        '                                           \"SubAddressType\": \"Unit\",'+
        '                                           \"parentID\": 419594516,'+
        '                                           \"ID\": 426978198,'+
        '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
        '                                           \"from\": 3,'+
        '                                           \"Confirmed\": true'+
        '                                       }'+
        '                                   ],'+
        '                                   \"Confirmed\": true'+
        '                               },'+
        '                               {'+
        '                                   \"SubAddressType\": \"Level\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419794487,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"from\": 1,'+
        '                                   \"Confirmed\": true'+
        '                               },'+
        '                               {'+
        '                                   \"SubAddressType\": \"Level\",'+
        '                                   \"parentID\": 426860877,'+
        '                                   \"ID\": 419787211,'+
        '                                   \"AddressType\": \"Complex - Floor/Level\",'+
        '                                   \"from\": 2,'+
        '                                   \"Confirmed\": true'+
        '                               }'+
        '                           ],'+
        '                           \"Confirmed\": true'+
        '                       }]'+
        '                   }'+
        '               },'+
        '               \"propertyName\": \"\",'+
        '               \"propertyNumberFrom\": 121,'+
        '               \"propertyNumberTo\": 0,'+
        '               \"propertyNumberSuffixFrom\": \"\",'+
        '               \"propertyNumberSuffixTo\": \"\"'+
        '           },'+
        '           \"serviceLocation\": {'+
        '               \"readyForServiceDate\": \"\",'+
        '               \"locationId\": \"\",'+
        '               \"facsRealm\": 74,'+
        '               \"exchangeServiceArea\": \"WLGG\",'+
        '               \"customerServiceAreaId\": \"\",'+
        '               \"latitude\": \"-34:25:33.4\",'+
        '               \"longitude\": \"150:53:46.9\"'+
        '           }'+
        '       },'+
        '       \"unstructuredAUPost\": {'+
        '           \"addresses\": {'+
        '               \"addressSummaryType\": \"FormattedAddressSummary\",'+
        '               \"addressId\": 180057100,'+
        '               \"addressType\": \"Property Address With Number\",'+
        '               \"confirmed\": true,'+
        '               \"parcelDescriptor2\": \"\",'+
        '               \"parcelDescriptor1 \": 1,'+
        '               \"planNumber\": \"DP1135205\",'+
        '               \"ruralmailNumber\": \"\",'+
        '               \"subAddressType\": \"\",'+
        '               \"parceltype2\": \"\",'+
        '               \"parceltype1\": \"F\",'+
        '               \"parceldescriptiontype1\": \"L\",'+
        '               \"parceldescriptiontype2\": \"\",'+
        '               \"propertyName\": \"\",'+
        '               \"fsam\": \"\",'+
        '               \"condorCode\": \"WLNGNG\",'+
        '               \"reqaddformatout\": \"unstructuredAUPost\",'+
        '               \"postcode\": 2500,'+
        '               \"state\": \"NSW\",'+
        '               \"localityName\": \"WOLLONGONG\",'+
        '               \"addressline1\": \"121 CROWN ST,\",'+
        '               \"addressline2\": \"\",'+
        '               \"addressline3\": \"\"'+
        '           },'+
        '           \"serviceLocation\": {'+
        '               \"readyForServiceDate\": \"\",'+
        '               \"locationId\": \"\",'+
        '               \"facsRealm\": 74,'+
        '               \"exchangeServiceArea\": \"WLGG\",'+
        '               \"customerServiceAreaId\": \"\",'+
        '               \"latitude\": \"-34:25:33.4\",'+
        '               \"longitude\": \"150:53:46.9\"'+
        '           }'+
        '       }'+
        '   }'+
        '}';
        return json;
    }
	private String getSearchByAdborIdResponseForChild(){
        String json = '{'+
        '    \"code\": 200,'+
        '    \"status\": 200,'+
        '    \"time\": \"2017-09-25T16:27:21+10:00\",'+
        '    \"data\": {'+
        '        \"transactionStatus\": \"Success\",'+
        '        \"matchingresultscount\": 1,'+
        '        \"structured\": {'+
        '            \"addresses\": {'+
        '                \"addressSummaryType\": \"SubAddressSummary\",'+
        '                \"addressId\": \"418853815\",'+
        '                \"addressType\": \"Complex - Flat/Unit\",'+
        '                \"confirmed\": true,'+
        '                \"reqaddformatout\": \"structured\",'+
        '                \"subAddressNumberFrom\": \"3411\",'+
        '                \"parcelDescriptor1\": \"3411\",'+
        '                \"condorCode\": \"STHBNK\",'+
        '                \"fsam\": \"3SYR-02\",'+
        '                \"subAddressType\": \"UNIT\",'+
        '                \"numSubaddresses\": 0,'+
        '                \"subAddressCodeset\": \"UNIT\",'+
        '                \"parent\": {'+
        '                    \"addressSummaryType\": \"SubAddressSummary\",'+
        '                    \"addressId\": \"265083283\",'+
        '                    \"addressType\": \"Complex - Floor/Level\",'+
        '                    \"confirmed\": true,'+
        '                    \"reqaddformatout\": \"structured\",'+
        '                    \"numSubaddresses\": 10,'+
        '                    \"subAddressCodeset\": \"LEVEL\",'+
        '                    \"subAddressNumberFrom\": \"34\",'+
        '                    \"parcelDescriptor1\": \"34\",'+
        '                    \"condorCode\": \"STHBNK\",'+
        '                    \"subAddressType\": \"LEVEL\",'+
        '                    \"serviceLocation\": {'+
        '                        \"latitude\": \"-37:49:18.2\",'+
        '                        \"longitude\": \"144:57:53.1\"'+
        '                    },'+
        '                    \"parent\": {'+
        '                        \"addressSummaryType\": \"SubAddressSummary\",'+
        '                        \"addressId\": \"265082901\",'+
        '                        \"addressType\": \"Complex - Building with Name\",'+
        '                        \"confirmed\": true,'+
        '                        \"reqaddformatout\": \"structured\",'+
        '                        \"numSubaddresses\": 679,'+
        '                        \"subAddressCodeset\": \"BUILDING\",'+
        '                        \"name\": \"EUREKA TOWER\",'+
        '                        \"condorCode\": \"STHBNK\",'+
        '                        \"subAddressType\": \"BUILDING\",'+
        '                        \"serviceLocation\": {'+
        '                            \"latitude\": \"-37:49:18.2\",'+
        '                            \"longitude\": \"144:57:53.1\"'+
        '                        },'+
        '                        \"parent\": {'+
        '                            \"addressSummaryType\": \"PropertyAddressSummary\",'+
        '                            \"addressId\": \"417085878\",'+
        '                            \"addressType\": \"Property with Number\",'+
        '                            \"confirmed\": true,'+
        '                            \"reqaddformatout\": \"structured\",'+
        '                            \"numSubaddresses\": 688,'+
        '                            \"streetType\": \"QUAY\",'+
        '                            \"propertyNumberFrom\": 7,'+
        '                            \"propertyNumberTo\": \"\",'+
        '                            \"postcode\": \"3006\",'+
        '                            \"state\": \"VIC\",'+
        '                            \"localityName\": \"SOUTHBANK\",'+
        '                            \"planNumber\": \"PS437659\",'+
        '                            \"parcelDescriptor1\": \"1R-8901\",'+
        '                            \"parcelDescriptionType1\": \"L\",'+
        '                            \"parcelType1\": \"F\",'+
        '                            \"condorCode\": \"STHBNK\",'+
        '                            \"serviceLocation\": {'+
        '                                \"exchangeServiceArea\": \"SMEL\",'+
        '                                \"facsRealm\": \"17\",'+
        '                                \"latitude\": \"-37:49:18.2\",'+
        '                                \"longitude\": \"144:57:53.1\"'+
        '                            }'+
        '                        }'+
        '                    }'+
        '                },'+
        '                \"primarySummary\": {'+
        '                    \"addressId\": \"417085878\",'+
        '                    \"addressType\": \"Property with Number\",'+
        '                    \"confirmed\": true,'+
        '                    \"reqaddformatout\": \"structured\",'+
        '                    \"localityName\": \"SOUTHBANK\",'+
        '                    \"state\": \"VIC\",'+
        '                    \"postcode\": \"3006\",'+
        '                    \"propertyNumberFrom\": 7,'+
        '                    \"propertyNumberTo\": \"\",'+
        '                    \"numSubaddresses\": 688,'+
        '                    \"streetType\": \"QUAY\",'+
        '                    \"streetName\": \"RIVERSIDE\",'+
        '                    \"planNumber\": \"PS437659\",'+
        '                    \"parcelDescriptor1\": \"1R-8901\",'+
        '                    \"parcelDescriptionType1\": \"L\",'+
        '                    \"parcelType1\": \"F\",'+
        '                    \"condorCode\": \"STHBNK\",'+
        '                    \"serviceLocation\": {'+
        '                        \"facsRealm\": \"17\",'+
        '                        \"exchangeServiceArea\": \"SMEL\",'+
        '                        \"latitude\": \"-37:49:18.2\",'+
        '                        \"longitude\": \"144:57:53.1\"'+
        '                    }'+
        '                }'+
        '            },'+
        '            \"serviceLocation\": {'+
        '                \"latitude\": \"-37:49:18.2\",'+
        '                \"longitude\": \"144:57:53.1\",'+
        '                \"locationId\": \"LOC000027969270\",'+
        '                \"customerServiceAreaId\": \"CSA300000001055\",'+
        '                \"readyForServiceDate\": \"2015-10-16\"'+
        '            }'+
        '        },'+
        '        \"unstructuredAUPost\": {'+
        '            \"addresses\": {'+
        '                \"addressSummaryType\": \"FormattedAddressSummary\",'+
        '                \"addressId\": \"418853815\",'+
        '                \"addressType\": \"Complex - Flat/Unit\",'+
        '                \"reqaddformatout\": \"unstructuredAUPost\",'+
        '                \"confirmed\": true,'+
        '                \"postcode\": \"3006\",'+
        '                \"state\": \"VIC\",'+
        '                \"localityName\": \"SOUTHBANK\",'+
        '                \"parcelDescriptor1\": \"3411\",'+
        '                \"condorCode\": \"STHBNK\",'+
        '                \"fsam\": \"3SYR-02\",'+
        '                \"subAddressType\": \"UNIT\",'+
        '                \"addressline1\": \"EUREKA TOWER, L 34, U 3411,\",'+
        '                \"addressline2\": \"7 RIVERSIDE QY,\"'+
        '            },'+
        '            \"serviceLocation\": {'+
        '                \"latitude\": \"-37:49:18.2\",'+
        '                \"longitude\": \"144:57:53.1\",'+
        '                \"locationId\": \"LOC000027969270\",'+
        '                \"customerServiceAreaId\": \"CSA300000001055\",'+
        '                \"readyForServiceDate\": \"2015-10-16\"'+
        '            }'+
        '        }'+
        '    },'+
        '    \"request\": {'+
        '        \"params\": {'+
        '            \"addressId\": \"418853815\",'+
        '            \"reqaddformatout\": \"unstructuredAUPost,structured\"'+
        '        },'+
        '        \"data\": {},'+
        '        \"path\": \"/addresses/:addressId\",'+
        '        \"method\": \"GET\",'+
        '        \"requestId\": \"da973b8f-5e08-46e0-b7a4-758c474fdde9\",'+
        '        \"correlationId\": \"79fb3257-2bc1-4312-bef8-d384a53813de\"'+
        '    },'+
        '    \"correlationId\": \"79fb3257-2bc1-4312-bef8-d384a53813de\"'+
        '}';
        return json;
    }
	 private String getSearchByAdborIdFailureResponse(){
        String json = '{'+
        '\"code\": 5013,'+
        '\"status\": 500,'+
        '\"time\": \"2017-03-15T02:01:12+11:00\",'+
        '\"message\": \"Unable to complete the service qualification due to core system errors\"'+
        '}';
        return json;
    }
    static testMethod void TestMethod1(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
    }
}