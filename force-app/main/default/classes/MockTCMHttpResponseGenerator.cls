@istest
global class MockTCMHttpResponseGenerator implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String endPoint = req.getEndpoint();

        if(endPoint.contains('10000142602')) {
            if(!endpoint.contains('include=contacts')) {
                res.setBody(get10000142602_excludeContacts());    
            }
            if(endpoint.contains('include=contacts')) {
                res.setBody(get10000142602_includeContacts());    
            }
        }       
        
        if(endPoint.contains('tcm/customer-accounts?') && endPoint.contains('multi')) {
            res.setBody(getMultiTCMCustomers());
        }
        else if (endPoint.contains('?include=contacts')) {
            res.setBody(getTCMCustomerContacts());
        } else if (endPoint.contains('tcm/customer-accounts')) {
            res.setBody(getSingleTCMCustomer());
        } else if (endPoint.contains('include=customer-accounts')) {
            if(endPoint.toLowerCase().contains('void')){
                res.setBody('{}');
            } else {
                res.setBody(getTCMContactCustomers());    
            }
        } else if (endPoint.contains('tcm/contacts?')) {
            res.setBody(getTCMMultiContacts());
        } else if (endPoint.contains('token') || endPoint.contains('mocksandbox')) {
            res.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}');
        } else if (endPoint.contains('test401')) {
            res.setStatusCode(401);
            res.setBody('{"status": "401", "code": "errorCode", "message":"errorMessage"}');
        } else if (endPoint.contains('NotifyCustomer')) {
            res.setStatusCode(201);
            res.setBody('{"statusCode":200,"status":"Success","message":"Customer created","errorCode":null,"data":"001p000000CBTuvAAH"}');
        } else if (endPoint.contains('address') && endPoint.contains('richmond')) {
            res.setBody('{"data":[{"greaterLocality":"","serviceLocation":{"connectivityServiceAreaId":"","locationId":"","exchangeServiceAreaId":"BLAC","facsRealm":"26"},"numberOfSubAddresses":"0","localityAbbreviation":"","state":"NSW","long":"","id":"240088459","name":"","ruralMailType":"","numberTo":"0","planNumber":"","subAddress":"","streetType":"RD","numberSuffix":"","lat":"","numberToPrefix":"","numberPrefix":"","status":"CONFIRMED","locationDescription":"","number":"95","streetName":"RICHMOND","addressType":"Property With Number","postcode":"2148","rangeIncrement":"","streetTypeSuffix":"","postalDeliveryType":"","locality":"BLACKTOWN","numberToSuffix":"","searchConfidence":""}]}');   
            res.setStatusCode(200);
        } else if (endPoint.contains('address') && endPoint.contains('noresults')) {
            res.setBody('{"data":[{}]}');   
            res.setStatusCode(200);
        } else if (endPoint.contains('address') && endPoint.contains('exception')) {
            res.setBody('{"data":""}');   
            res.setStatusCode(500);
        }
        if(endPoint.contains('2830329059'))	res.setBody(getCustomerResponse_2830329059());
        if(endPoint.contains('10000157010')) res.setBody(getCustomerContactResponse_10000157010());
		
        if(endPoint.contains('3804852047'))	res.setBody(getCustomerResponseImproperAddress_3804852047());
        
        if(endPoint.contains('7100000837'))	res.setBody(getCustomerResponse_7100000837());
        if(endPoint.contains('10000155677')) res.setBody(getCustomerContactResponse_10000155677());
		if(endPoint.contains('10000155688')) res.setBody(getCustomerContactResponse_10000155688());
        if(endPoint.contains('4840371999')) res.setBody(getCustomerContactResponse_4840371999());
        if(endPoint.contains('4840371988')) res.setBody(getCustomerContactResponse_4840371988());
		 if(endPoint.contains('4840371888')) res.setBody(getSingleTCMCustomer_4840371888());

        if(endPoint.contains('9816838468'))	res.setBody(getCustomerResponse_9816838468());
        if(endPoint.contains('10000156212')) res.setBody(getCustomerContactResponse_10000156212());
		if (endPoint.contains('test401ContactMerge')) {
            res.setStatusCode(401);
            res.setBody('{"status": "401", "code": "errorCode", "message":"errorMessage"}');
        }
        if (endPoint.contains('testExceptionContactMerge')) {
            throw new DMLException('My DML EXCEPTION'); 
        }        
        if(res.getStatusCode() == null || res.getStatusCode() == 0) {
            res.setStatusCode(200);
            res.setStatus('OK');
        }

        if(endPoint.contains('6856802068'))res = null;
        if(endPoint.contains('1501975555')){
            res.setBody(getCustomerResponse_1501975555()); 
            res.setStatusCode(400);
        }       
        
        if(endPoint.contains('1856891061')){
            res.setBody(getCustomerResponse_1856891061()); 
            res.setStatusCode(200);
        }
        
        if(endPoint.contains('4840371929')){
            throw new System.CalloutException();
        }
        
        System.debug('!@#$% Returning mock response : ' + res.getBody());
        return res;
        
    }
    
    private String getCustomerResponse_1856891061(){
        String responseBody = '{\"message\":\"No record found for supplied search criteria\",\"status\":200,\"code\":\"WS0002\"}';
        return responseBody;
    }
    
    private String getCustomerResponse_9816838468(){
        String responseBody = '{\"data\":{\"customers\":[{\"location\":\"10211/02/1988MARY\",\"servicingOrgUnit\":\"BUSSTD\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"White Mail\",\"lastName\":\"KLUG\",\"acn\":\"\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"SFDC Integration\",\"abn\":\"10000000000\",\"driverLicenceState\":\"\",\"title\":\"MS\",\"faxNumber\":\"\",\"phoneNumber\":\"\",\"birthDate\":\"1988-11-02\",\"accountUuid\":\"8C5D6F29-60AC-46bc-A013-0BDD09E17CE6\",\"firstName\":\"MARY\"},\"accountTrading\":[{\"isPrimary\":\"\",\"tradingName\":\"\"}],\"cac\":\"2021914262\",\"marketSegment\":\"Business Unsegmented\",\"customerManagedFlag\":\"N\",\"accountStatus\":\"ACTIVE\",\"createdDate\":\"2017-10-11T00:00:00+11:00\",\"geographicalLocationCode\":\"1V\",\"customerType\":\"Sole Trader\",\"customerSince\":\"2017-10-11\",\"accountPortfolio\":[{\"portfolioName\":\"TB NEW CUSTOMERS VIC\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"TB MASS NEW CUSTOMER\",\"portfolioCode\":\"SVU01\",\"accountExecutivePhoneNumber\":\"13200000 0000\",\"accountExecutiveFirstName\":\"VIC\"}],\"lastUpdated\":\"2017-10-11T00:00:00+11:00\",\"cidn\":\"9816838468\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"CMV\",\"businessUnit\":\"Business\",\"category\":{\"online\":\"N\"},\"revenueOrganisationUnit\":\"BBV1V0\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"VIC\",\"streetTypeCode\":\"\",\"addressId\":\"T25397493\",\"statusCode\":\"\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"3000\",\"registeredPlan\":\"\",\"streetNumberStart\":\"16\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"9\",\"buildingName\":\"\",\"addressLines\":[\"_\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"SILICON VALLEY\",\"addressType\":\"\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"BUILDING\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"25\",\"deliveryPointId\":\"\",\"streetNumberEndSuffix\":\"\",\"locality\":\"MELBOURNE\"}],\"masterID\":\"10000156212\",\"premiumService\":\"N\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
    }
    
	private String getCustomerContactResponse_10000156212(){
        String responseBody = '{\"message\":\"No record found for supplied search criteria\",\"status\":200,\"code\":\"WS0002\"}';
        return responseBody;
    }
    
	private String getCustomerResponse_1501975555(){
        String responseBody = '{\"status\":\"500\",\"message\":\"An internal error occurred when processing the request\"}';
        return responseBody;
    }
    
    private String getCustomerContactResponse_4840371999(){
        String responseBody = '{\"status\":\"\",\"message\":\"An internal error occurred when processing the request\", \"code\":\"WS0001\"}';
        return responseBody;
    }
    
    private String getCustomerContactResponse_4840371988(){
        String responseBody = '{\"status\":\"\",\"message\":\"An internal error occurred when processing the request\", \"code\":\"BTC0016\"}';
        return responseBody;
    }
    
    private String getCustomerResponse_2830329059(){
        String responseBody = '{\"data\":{\"customers\":[{\"location\":\"10206/21/1991JOHN\",\"servicingOrgUnit\":\"BUSSTD\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"White Mail\",\"lastName\":\"WALLACE\",\"acn\":\"\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"\",\"abn\":\"10000000000\",\"driverLicenceState\":\"\",\"title\":\"MR\",\"faxNumber\":\"\",\"phoneNumber\":\"+610404429479\",\"birthDate\":\"1991-06-21\",\"accountUuid\":\"37128732-3AA6-4d1c-A108-ED682D88721A\",\"firstName\":\"JOHN\"},\"accountTrading\":[{\"isPrimary\":\"\",\"tradingName\":\"\"}],\"cac\":\"2021915901\",\"marketSegment\":\"Business Unsegmented\",\"customerManagedFlag\":\"N\",\"accountStatus\":\"ACTIVE\",\"createdDate\":\"2017-10-19T00:00:00+11:00\",\"geographicalLocationCode\":\"1V\",\"customerType\":\"Sole Trader\",\"customerSince\":\"2017-10-19\",\"accountPortfolio\":[{\"portfolioName\":\"TB NEW CUSTOMERS VIC\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"TB MASS NEW CUSTOMER\",\"portfolioCode\":\"SVU01\",\"accountExecutivePhoneNumber\":\"13200000 0000\",\"accountExecutiveFirstName\":\"VIC\"}],\"lastUpdated\":\"2017-10-19T00:00:00+11:00\",\"cidn\":\"2830329059\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"CMV\",\"businessUnit\":\"Business\",\"category\":{\"online\":\"N\"},\"revenueOrganisationUnit\":\"BBV1V0\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"VIC\",\"streetTypeCode\":\"\",\"addressId\":\"T25623605\",\"statusCode\":\"\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"3000\",\"registeredPlan\":\"\",\"streetNumberStart\":\"17\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"12\",\"buildingName\":\"\",\"addressLines\":[\"_\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"LONSDALE\",\"addressType\":\"Billing Address\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"FLAT\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"24\",\"deliveryPointId\":\"\",\"streetNumberEndSuffix\":\"\",\"locality\":\"MELBOURNE\"}],\"masterID\":\"10000157010\",\"premiumService\":\"N\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
    }
    
    private String getCustomerContactResponse_10000157010(){
        String responseBody = '{\"data\":{\"id\":10000157010,\"lastName\":\"WALLACE\",\"acn\":\"\",\"accountStatus\":\"ACTIVE\",\"birthDate\":\"1991-06-21\",\"firstName\":\"JOHN\",\"abn\":10000000000,\"contacts\":[{\"preferredMethod\":\"None\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Residential\",\"contactType\":\"Limited Authority\",\"endDate\":\"2018-11-11\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"C461849A-01A7-46ee-BD11-7DEE305356F1\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"1990-05-11\",\"firstName\":\"MALCOLM\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"WALLACE\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"None\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Residential\",\"contactType\":\"Legal Lessee\",\"endDate\":\"2018-11-11\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"79E43074-6622-4087-A255-FDF7B417EB13\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"1991-06-21\",\"firstName\":\"JOHN\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"WALLACE\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"}]}}';
        return responseBody;
    }
    
    private String getCustomerResponseImproperAddress_3804852047(){
        String responseBody = '{\"data\":{\"customers\":[{\"location\":\"10463004410833\",\"servicingOrgUnit\":\"959VAR\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"White Mail\",\"lastName\":\"ARRIUM LIMITED\",\"acn\":\"004410833\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"SFDC Integration\",\"abn\":\"63004410833\",\"driverLicenceState\":\"\",\"title\":\"\",\"faxNumber\":\"\",\"phoneNumber\":\"\",\"birthDate\":\"\",\"accountUuid\":\"A627A075-5FC3-42af-8505-37DF705CB3D0\",\"firstName\":\"\"},\"accountTrading\":[{\"isPrimary\":\"\",\"tradingName\":\"\"}],\"cac\":\"2035633134\",\"marketSegment\":\"Onesteel\",\"customerManagedFlag\":\"Y\",\"accountStatus\":\"SUSPECT\",\"createdDate\":\"1970-01-01T00:00:00+11:00\",\"geographicalLocationCode\":\"1N\",\"customerType\":\"Company\",\"customerSince\":\"1970-01-01\",\"accountPortfolio\":[{\"portfolioName\":\"\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"\",\"portfolioCode\":\"SPN15\",\"accountExecutivePhoneNumber\":\"\",\"accountExecutiveFirstName\":\"\"}],\"lastUpdated\":\"2015-05-27T00:00:00+11:00\",\"cidn\":\"3804852047\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"K3N\",\"businessUnit\":\"Enterprise\",\"category\":{\"online\":\"Y\"},\"revenueOrganisationUnit\":\"EEK3N1\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"NSW\",\"streetTypeCode\":\"STREET\",\"addressId\":\"419550607\",\"statusCode\":\"CONFIRMED\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"2000\",\"registeredPlan\":\"\",\"streetNumberStart\":\"1\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"\",\"buildingName\":\"\",\"addressLines\":[\"1 YORK ST,\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"ST\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"CO\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"YORK\",\"addressType\":\"CO\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"\",\"deliveryPointId\":\"98004043\",\"streetNumberEndSuffix\":\"\",\"locality\":\"SYDNEY\"}],\"masterID\":\"10000112741\",\"premiumService\":\"N\"},{\"state\":\"NSW\",\"streetTypeCode\":\"STREET\",\"addressId\":\"419550607\",\"statusCode\":\"CONFIRMED\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"2000\",\"registeredPlan\":\"\",\"streetNumberStart\":\"1\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"\",\"buildingName\":\"\",\"addressLines\":[\"1 YORK ST,\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"ST\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"CO\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"YORK\",\"addressType\":\"CO\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"\",\"deliveryPointId\":\"98004043\",\"streetNumberEndSuffix\":\"\",\"locality\":\"SYDNEY\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
    }
    
    private String getCustomerResponse_7100000837(){
		//masterID = 10000155677
        String responseBody = '{\"data\":{\"customers\":[{\"location\":\"106\",\"servicingOrgUnit\":\"959949\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"White Mail\",\"lastName\":\"NTG NORTHERN TERRITORY GOVERNMENT\",\"acn\":\"\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"\",\"abn\":\"84085734992\",\"driverLicenceState\":\"\",\"title\":\"\",\"faxNumber\":\"\",\"phoneNumber\":\"\",\"birthDate\":\"\",\"accountUuid\":\"1FC96FD6-B11E-485e-A259-AC20FB27971E\",\"firstName\":\"\"},\"accountTrading\":[{\"isPrimary\":\"Y\",\"tradingName\":\"NTG - NORTHERN TERRITORY GOVERNMENT\"}],\"cac\":\"\",\"marketSegment\":\"AJ LUCAS GROUP\",\"customerManagedFlag\":\"Y\",\"accountStatus\":\"ACTIVE\",\"createdDate\":\"1970-01-01T00:00:00+11:00\",\"geographicalLocationCode\":\"3C\",\"customerType\":\"Organisation\",\"customerSince\":\"1970-01-01\",\"accountPortfolio\":[{\"portfolioName\":\"\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"\",\"portfolioCode\":\"SS107\",\"accountExecutivePhoneNumber\":\"\",\"accountExecutiveFirstName\":\"\"}],\"lastUpdated\":\"2017-09-27T00:00:00+11:00\",\"cidn\":\"7100000837\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"KKA\",\"businessUnit\":\"Enterprise\",\"category\":{\"online\":\"Y\"},\"revenueOrganisationUnit\":\"EEKKA1\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"NT\",\"streetTypeCode\":\"STREET\",\"addressId\":\"UIEDKQ9\",\"statusCode\":\"\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"0800\",\"registeredPlan\":\"\",\"streetNumberStart\":\"38\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"\",\"buildingName\":\"\",\"addressLines\":[\"_\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"ST\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"CAVENAGH\",\"addressType\":\"\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"\",\"deliveryPointId\":\"\",\"streetNumberEndSuffix\":\"\",\"locality\":\"DARWIN CITY\"}],\"masterID\":\"10000155677\",\"premiumService\":\"N\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
    }
    
	private String getCustomerContactResponse_10000155677(){
        String responseBody = '{\"data\":{\"id\":10000155677,\"lastName\":\"NTG NORTHERN TERRITORY GOVERNMENT\",\"acn\":\"\",\"accountStatus\":\"ACTIVE\",\"firstName\":\"\",\"abn\":84085734992,\"contacts\":[{\"preferredMethod\":\"Fax\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Advocate\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"+610889548076\",\"phoneNumber\":\"+610889546146\",\"emailAddress\":\"\",\"mobileNumber\":\"+610449274845\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"BEE8826B-5453-49f3-92F7-E9AA62A350A7\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"1901-01-01\",\"firstName\":\"JEREMY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"GAYNOR\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Fax\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Advocate\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"+610889548076\",\"phoneNumber\":\"+610889546146\",\"emailAddress\":\"\",\"mobileNumber\":\"+610449274845\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"BEE8826B-5453-49f3-92F7-E9AA62A350A7\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"1901-01-01\",\"firstName\":\"JEREMY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"GAYNOR\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"}]}}';
        return responseBody;
    }
    
	private String getCustomerContactResponse_10000155688(){
        String responseBody = '{\"data\":{\"id\":10000155677,\"lastName\":\"NTG NORTHERN TERRITORY GOVERNMENT\",\"acn\":\"\",\"accountStatus\":\"ACTIVE\",\"firstName\":\"\",\"abn\":84085734992,\"contacts\":[{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Advocate\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"+610889548076\",\"phoneNumber\":\"+610889546146\",\"emailAddress\":\"\",\"mobileNumber\":\"+610449274845\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"BEE8826B-5453-49f3-92F7-E9AA62A350A7\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"JEREMY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"GAYNOR\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Full Authority\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610200000000\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"5FDD5562-660C-4a73-B8BA-2B9A0E5CE1F7\",\"title\":\"MS\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"REBECCA\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"LITTEN\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Full Authority\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610884334173\",\"emailAddress\":\"\",\"mobileNumber\":\"+610457528722\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"7E2297CA-F7B5-4849-B3CE-3BAE2CABC026\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"SHAHIN\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"MOHAMADIAN\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"\",\"contactType\":\"\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610884334173\",\"emailAddress\":\"\",\"mobileNumber\":\"+610457528722\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"A5B4EE40-5B47-4284-8920-6AC532083CAE\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"SHAHIN\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"MOHAMADIAN\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"Business\",\"contactType\":\"Advocate\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610889996561\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"E6BE6DC0-E8FE-4670-8238-2F198EF73B02\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"GAREY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"NEENAN\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"\",\"contactType\":\"\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610889243879\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"F30BC45B-0181-43f8-956E-B21EA6078B52\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"RODNEY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"SHEPHERD\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"},{\"preferredMethod\":\"Phone\",\"onlineFlag\":\"\",\"customerAccounts\":{\"lastName\":\"\",\"phoneOptIn\":\"Y\",\"faceToFaceOptIn\":\"Y\",\"dataSovereignty\":\"\",\"smsOptIn\":\"Y\",\"id\":\"\",\"mmsOptIn\":\"Y\",\"businessUnit\":\"\",\"emailOptIn\":\"Y\",\"contactRelationship\":{\"isPrimary\":\"\",\"contactUsage\":\"\",\"contactType\":\"\",\"endDate\":\"\"},\"directMailOptIn\":\"Y\",\"customerCode\":\"\",\"accountUuid\":\"\"},\"workContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"+610889243879\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"languagePreference\":\"\",\"timeZone\":\"\",\"eventAction\":\"\",\"jobDescription\":\"\",\"id\":\"E316BBE5-66AE-43ff-8483-540A87254BB3\",\"title\":\"MR\",\"externalSystemId\":\"\",\"birthDate\":\"\",\"firstName\":\"RODNEY\",\"homeContact\":{\"faxNumber\":\"\",\"phoneNumber\":\"\",\"emailAddress\":\"\",\"mobileNumber\":\"\"},\"jobTitle\":\"\",\"middleName\":\"\",\"lastName\":\"SHEPHERD\",\"numberInHousehold\":\"\",\"occupation\":\"\",\"reviewedFlag\":\"\",\"status\":\"\",\"lastVerifiedDate\":\"\",\"sendDateTime\":\"\",\"lastUpdated\":\"\",\"contactId\":\"\",\"notes\":\"\"}]}}';
        return responseBody;
    }
	
    /*private String getCustomerContactResponseHasNoContact_10000156213(){
        String responseBody = '{\"data\":{\"id\":10000156213,\"lastName\":\"ROLSTON M\",\"acn\":119100819,\"accountStatus\":\"ACTIVE\",\"firstName\":\"\",\"abn\":10000000000}}';
        return responseBody;
    }*/
    private String getSingleTCMCustomer() {
		String responseBody = '{\"data\":{\"customers\":[{\"location\":\"106\",\"servicingOrgUnit\":\"959949\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"White Mail\",\"lastName\":\"NTG NORTHERN TERRITORY GOVERNMENT\",\"acn\":\"\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"123456\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"\",\"abn\":\"84085734992\",\"driverLicenceState\":\"MH\",\"title\":\"\",\"faxNumber\":\"\",\"phoneNumber\":\"\",\"birthDate\":\"\",\"accountUuid\":\"1FC96FD6-B11E-485e-A259-AC20FB27971E\",\"firstName\":\"\"},\"accountTrading\":[{\"isPrimary\":\"Y\",\"tradingName\":\"NTG - NORTHERN TERRITORY GOVERNMENT\"}],\"cac\":\"\",\"marketSegment\":\"AJ LUCAS GROUP\",\"customerManagedFlag\":\"Y\",\"accountStatus\":\"ACTIVE\",\"createdDate\":\"1970-01-01T00:00:00+11:00\",\"geographicalLocationCode\":\"3C\",\"customerType\":\"Organisation\",\"customerSince\":\"1970-01-01\",\"accountPortfolio\":[{\"portfolioName\":\"\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"\",\"portfolioCode\":\"SS107\",\"accountExecutivePhoneNumber\":\"\",\"accountExecutiveFirstName\":\"\"}],\"lastUpdated\":\"2017-09-27T00:00:00+11:00\",\"cidn\":\"7100000837\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"KKA\",\"businessUnit\":\"Enterprise\",\"category\":{\"online\":\"Y\"},\"revenueOrganisationUnit\":\"EEKKA1\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"NT\",\"streetTypeCode\":\"STREET\",\"addressId\":\"UIEDKQ9\",\"statusCode\":\"\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"0800\",\"registeredPlan\":\"\",\"streetNumberStart\":\"38\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"\",\"buildingName\":\"\",\"addressLines\":[\"_\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"ST\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"CAVENAGH\",\"addressType\":\"\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"\",\"deliveryPointId\":\"\",\"streetNumberEndSuffix\":\"\",\"locality\":\"DARWIN CITY\"}],\"masterID\":\"10000155677\",\"premiumService\":\"N\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
	}
	private String getSingleTCMCustomer_4840371888() {
		String responseBody = '{\"data\":{\"customers\":[{\"location\":\"106\",\"servicingOrgUnit\":\"959949\",\"languagePreference\":\"English\",\"parentCidn\":\"\",\"customerAccount\":{\"preferredMethod\":\"\",\"lastName\":\"NTG NORTHERN TERRITORY GOVERNMENT\",\"acn\":\"\",\"fraudFlag\":\"N\",\"driverLicenceNumber\":\"123456\",\"effectiveRetiredDate\":\"\",\"webAddress\":\"\",\"emailAddress\":\"\",\"dataSovereignty\":\"\",\"abn\":\"84085734992\",\"driverLicenceState\":\"MH\",\"title\":\"\",\"faxNumber\":\"\",\"phoneNumber\":\"\",\"birthDate\":\"\",\"accountUuid\":\"1FC96FD6-B11E-485e-A259-AC20FB27971E\",\"firstName\":\"\"},\"accountTrading\":[{\"isPrimary\":\"Y\",\"tradingName\":\"NTG - NORTHERN TERRITORY GOVERNMENT\"}],\"cac\":\"\",\"marketSegment\":\"AJ LUCAS GROUP\",\"customerManagedFlag\":\"Y\",\"accountStatus\":\"ACTIVE\",\"createdDate\":\"1970-01-01T00:00:00+11:00\",\"geographicalLocationCode\":\"3C\",\"customerType\":\"Organisation\",\"customerSince\":\"1970-01-01\",\"accountPortfolio\":[{\"portfolioName\":\"\",\"isPrimary\":\"Y\",\"accountExecutiveLastName\":\"\",\"portfolioCode\":\"SS107\",\"accountExecutivePhoneNumber\":\"\",\"accountExecutiveFirstName\":\"\"}],\"lastUpdated\":\"2017-09-27T00:00:00+11:00\",\"cidn\":\"7100000837\",\"ultimateParentCidn\":\"\",\"ownershipCode\":\"KKA\",\"businessUnit\":\"Enterprise\",\"category\":{\"online\":\"Y\"},\"revenueOrganisationUnit\":\"EEKKA1\",\"priorityAssist\":\"N\",\"address\":[{\"state\":\"NT\",\"streetTypeCode\":\"STREET\",\"addressId\":\"UIEDKQ9\",\"statusCode\":\"\",\"streetTypeSuffixCode\":\"\",\"postalCode\":\"0800\",\"registeredPlan\":\"\",\"streetNumberStart\":\"38\",\"subAddress\":{\"propertyName\":\"\",\"privateStreetType\":\"\",\"privateStreetName\":\"\",\"details\":[{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"},{\"detailType\":\"\",\"value\":\"\",\"detailTypeCode\":\"\"}],\"numberStart\":\"\",\"buildingName\":\"\",\"addressLines\":[\"_\",\"\",\"\"],\"numberEnd\":\"\",\"privateStreetTypeCode\":\"\"},\"streetType\":\"ST\",\"internationalState\":\"\",\"isPrimary\":\"Y\",\"status\":\"\",\"streetNumberStartSuffix\":\"\",\"streetName\":\"CAVENAGH\",\"addressType\":\"\",\"additionalInfo\":\"\",\"country\":\"AUSTRALIA\",\"internationalPostcode\":\"\",\"addressTypeCode\":\"\",\"streetTypeSuffix\":\"\",\"streetNumberEnd\":\"\",\"deliveryPointId\":\"\",\"streetNumberEndSuffix\":\"\",\"locality\":\"DARWIN CITY\"}],\"masterID\":\"10000155688\",\"premiumService\":\"N\"}],\"paging\":{\"limit\":\"50\",\"lastPage\":\"Y\",\"resultBlockSize\":\"1\",\"offset\":\"0\"}}}';
        return responseBody;
	}
	
    private String getSingleTCMCustomer1() {
        String jsonString = '{' + 
        '  \"data\": {' + 
        '    \"lastName\": \"AARATHY SD\",' + 
        '    \"acn\": \"\",' + 
        '    \"customerType\": \"Organisation\",' + 
        '    \"cidn\": \"7521133\",' + 
        '    \"priorityAssistFlag\": \"N\",' + 
        '    \"emailAddress\": \"\",' + 
        '    \"abn\": \"10000000000\",' + 
        '    \"cac\": \"2016008318\",' + 
        '    \"id\": \"10000002126\",' + 
        '    \"title\": \"\",' + 
        '    \"businessUnit\": \"Business\",' + 
        '    \"faxNumber\": \"\",' + 
        '    \"phoneNumber\": \"\",' + 
        '    \"customerManagedFlag\": \"N\",' + 
        '    \"marketSegment\": \"Business Unsegmented\",' + 
        '    \"address\": [' + 
        '      {' + 
        '        \"status\": \"CO\",' + 
        '        \"state\": \"VIC\",' + 
        '        \"postCode\": \"3000\",' + 
        '        \"locality\": \"MELBOURNE\",' + 
        '        \"streetName\": \"ELIZABETH8\",' + 
        '        \"addressType\": \"CO\",' + 
        '        \"subAddress\": {' + 
        '          \"buildingName\": \"\"' + 
        '        },' + 
        '        \"additionalInfo\": \"\",' + 
        '        \"addressId\": \"414960537\",' + 
        '        \"country\": \"AUSTRALIA\"' + 
        '      },' + 
        '      {' + 
        '        \"status\": \"\",' + 
        '        \"state\": \"PR\",' + 
        '        \"postCode\": \"00612\",' + 
        '        \"locality\": \"ARECIBO\",' + 
        '        \"streetName\": \"\",' + 
        '        \"addressType\": \"\",' + 
        '        \"subAddress\": {' + 
        '          \"buildingName\": \"\"' + 
        '        },' + 
        '        \"additionalInfo\": \"Hello\",' + 
        '        \"addressId\": \"160063445\",' + 
        '        \"country\": \"AUSTRALIA\"' + 
        '      },' + 
        '      {' + 
        '        \"status\": \"CO\",' + 
        '        \"state\": \"NSW\",' + 
        '        \"postCode\": \"2452\",' + 
        '        \"locality\": \"SAWTELL\",' + 
        '        \"streetName\": \"DARWIN\",' + 
        '        \"addressType\": \"CO\",' + 
        '        \"subAddress\": {' + 
        '          \"buildingName\": \"\"' + 
        '        },' + 
        '        \"additionalInfo\": \"\",' + 
        '        \"addressId\": \"ABCD1237K\",' + 
        '        \"country\": \"AUSTRALIA\"' + 
        '      },' + 
        '      {' + 
        '        \"status\": \"CO\",' + 
        '        \"state\": \"NSW\",' + 
        '        \"postCode\": \"2525\",' + 
        '        \"locality\": \"FIGTREE\",' + 
        '        \"streetName\": \"BRENTWOOD\",' + 
        '        \"addressType\": \"CO\",' + 
        '        \"subAddress\": {' + 
        '          \"buildingName\": \"\"' + 
        '        },' + 
        '        \"additionalInfo\": \"PROPERTYLOCDESC\",' + 
        '        \"addressId\": \"418315472\",' + 
        '        \"country\": \"AUSTRALIA\"' + 
        '      },' + 
        '      {' + 
        '        \"status\": \"CO\",' + 
        '        \"state\": \"TAS\",' + 
        '        \"postCode\": \"7140\",' + 
        '        \"locality\": \"NEW NORFOLK\",' + 
        '        \"streetName\": \"GLENORA\",' + 
        '        \"addressType\": \"CO\",' + 
        '        \"subAddress\": {' + 
        '          \"buildingName\": \"\"' + 
        '        },' + 
        '        \"additionalInfo\": \"12540\",' + 
        '        \"addressId\": \"50857647\",' + 
        '        \"country\": \"AUSTRALIA\"' + 
        '      }' + 
        '    ],' + 
        '    \"accountStatus\": \"ACQUIRED\",' + 
        '    \"birthDate\": \"\",' + 
        '    \"accountUuid\": \"72891852-47BA-4d69-9741-F939FE022017\",' + 
        '    \"firstName\": \"\",' + 
        '    \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000002126\"' + 
        '  }' + 
        '}';
        
        return jsonString;
    }
    
    private String getMultiTCMCustomers() {
        String jsonString = '{' + 
        '  \"data\": [' + 
        '    {' + 
        '      \"lastName\": \"AARATHY SD\",' + 
        '      \"acn\": \"\",' + 
        '      \"customerType\": \"Organisation\",' + 
        '      \"cidn\": \"7521133\",' + 
        '      \"priorityAssistFlag\": \"N\",' + 
        '      \"emailAddress\": \"\",' + 
        '      \"abn\": \"10000000000\",' + 
        '      \"cac\": \"2016008318\",' + 
        '      \"id\": \"10000002126\",' + 
        '      \"title\": \"\",' + 
        '      \"businessUnit\": \"Business\",' + 
        '      \"faxNumber\": \"\",' + 
        '      \"phoneNumber\": \"\",' + 
        '      \"customerManagedFlag\": \"N\",' + 
        '      \"marketSegment\": \"Business Unsegmented\",' + 
        '      \"address\": [' + 
        '        {' + 
        '          \"status\": \"CO\",' + 
        '          \"state\": \"VIC\",' + 
        '          \"postCode\": \"3000\",' + 
        '          \"locality\": \"MELBOURNE\",' + 
        '          \"streetName\": \"ELIZABETH8\",' + 
        '          \"addressType\": \"CO\",' + 
        '          \"subAddress\": {' + 
        '            \"buildingName\": \"\"' + 
        '          },' + 
        '          \"additionalInfo\": \"\",' + 
        '          \"addressId\": \"414960537\",' + 
        '          \"country\": \"AUSTRALIA\"' + 
        '        },' + 
        '        {' + 
        '          \"status\": \"\",' + 
        '          \"state\": \"PR\",' + 
        '          \"postCode\": \"00612\",' + 
        '          \"locality\": \"ARECIBO\",' + 
        '          \"streetName\": \"\",' + 
        '          \"addressType\": \"\",' + 
        '          \"subAddress\": {' + 
        '            \"buildingName\": \"\"' + 
        '          },' + 
        '          \"additionalInfo\": \"Hello\",' + 
        '          \"addressId\": \"160063445\",' + 
        '          \"country\": \"AUSTRALIA\"' + 
        '        },' + 
        '        {' + 
        '          \"status\": \"CO\",' + 
        '          \"state\": \"NSW\",' + 
        '          \"postCode\": \"2452\",' + 
        '          \"locality\": \"SAWTELL\",' + 
        '          \"streetName\": \"DARWIN\",' + 
        '          \"addressType\": \"CO\",' + 
        '          \"subAddress\": {' + 
        '            \"buildingName\": \"\"' + 
        '          },' + 
        '          \"additionalInfo\": \"\",' + 
        '          \"addressId\": \"ABCD1237K\",' + 
        '          \"country\": \"AUSTRALIA\"' + 
        '        },' + 
        '        {' + 
        '          \"status\": \"CO\",' + 
        '          \"state\": \"NSW\",' + 
        '          \"postCode\": \"2525\",' + 
        '          \"locality\": \"FIGTREE\",' + 
        '          \"streetName\": \"BRENTWOOD\",' + 
        '          \"addressType\": \"CO\",' + 
        '          \"subAddress\": {' + 
        '            \"buildingName\": \"\"' + 
        '          },' + 
        '          \"additionalInfo\": \"PROPERTYLOCDESC\",' + 
        '          \"addressId\": \"418315472\",' + 
        '          \"country\": \"AUSTRALIA\"' + 
        '        },' + 
        '        {' + 
        '          \"status\": \"CO\",' + 
        '          \"state\": \"TAS\",' + 
        '          \"postCode\": \"7140\",' + 
        '          \"locality\": \"NEW NORFOLK\",' + 
        '          \"streetName\": \"GLENORA\",' + 
        '          \"addressType\": \"CO\",' + 
        '          \"subAddress\": {' + 
        '            \"buildingName\": \"\"' + 
        '          },' + 
        '          \"additionalInfo\": \"12540\",' + 
        '          \"addressId\": \"50857647\",' + 
        '          \"country\": \"AUSTRALIA\"' + 
        '        }' + 
        '      ],' + 
        '      \"accountStatus\": \"ACQUIRED\",' + 
        '      \"birthDate\": \"\",' + 
        '      \"accountUuid\": \"72891852-47BA-4d69-9741-F939FE022017\",' + 
        '      \"firstName\": \"\",' + 
        '      \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000002126\"' + 
        '    }' + 
        '  ]' + 
        '}';
        
        return jsonString;
    }
    
    private String getTCMCustomerContacts() {
        System.debug('!@#$% Method getTCMCustomerContacts');
        return '{"data":{"id":10000142607,"lastName":"TEGOUTOFSCOPE","acn":"","accountStatus":"ACTIVE","firstName":"","abn":10000000000,"contacts":[{"preferredMethod":"Phone","onlineFlag":"","customerAccounts":{"lastName":"","phoneOptIn":"Y","faceToFaceOptIn":"Y","dataSovereignty":"","smsOptIn":"Y","id":"","mmsOptIn":"Y","businessUnit":"","emailOptIn":"Y","contactRelationship":{"isPrimary":"","contactUsage":"Business","contactType":"Full Authority","endDate":""},"directMailOptIn":"Y","customerCode":"","accountUuid":""},"workContact":{"faxNumber":"","phoneNumber":"+610349403943","emailAddress":"","mobileNumber":""},"languagePreference":"","timeZone":"","eventAction":"","jobDescription":"","id":"B6023C14-6ABF-431f-9BBE-5544B8D1C6DA","title":"MR","externalSystemId":"","birthDate":"1987-12-12","firstName":"TEGOUTOFSCOPE","homeContact":{"faxNumber":"","phoneNumber":"","emailAddress":"","mobileNumber":""},"jobTitle":"","middleName":"","lastName":"TEGOUTOFSCOPE","numberInHousehold":"","occupation":"","reviewedFlag":"","status":"","lastVerifiedDate":"","sendDateTime":"","lastUpdated":"","contactId":"","notes":""}]}}';
            
    }
    
    private String getTCMMultiContacts() {
        String jsonString = '{' + 
        '  \"data\": [' + 
        '    {' + 
        '      \"middleName\": \"VVVVVV\",' + 
        '      \"preferredMethod\": \"eMail\",' + 
        '      \"lastName\": \"ARUN\",' + 
        '      \"onlineFlag\": \"N\",' + 
        '      \"customerAccounts\": [' + 
        '        {' + 
        '          \"id\": \"10000002126\",' + 
        '          \"lastName\": \"AARATHY SD\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"\",' + 
        '          \"accountUuid\": \"72891852-47BA-4d69-9741-F939FE022017\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000002126\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-4626502\",' + 
        '          \"lastName\": \"ARUNTESTING\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Legal Lessee\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"E6776958-0659-4798-8E71-1F153A517B62\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-4626502\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000073\",' + 
        '          \"lastName\": \"CHOWN\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Full Authority\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"006AA385-C5F5-4ccf-9542-68EB72C0FD6F\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000073\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000072\",' + 
        '          \"lastName\": \"CHRISTINA\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Full Authority\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"10C05486-651F-45b7-BDEB-94725F1DFE32\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000072\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000001143\",' + 
        '          \"lastName\": \"DEFECTRETESTING\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Asset User\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Res/Bus\",' + 
        '          \"accountUuid\": \"DD2C0C0C-AA21-438a-A57A-51044CBF147D\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000001143\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-16400746\",' + 
        '          \"lastName\": \"FUNCTIONAL\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Asset User\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"C775EB9D-7EDA-40ff-B4CA-56B9924F4C69\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16400746\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-938826\",' + 
        '          \"lastName\": \"GALARIASDEE\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Legal Lessee\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"1-K4EI\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-938826\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-2567502\",' + 
        '          \"lastName\": \"NAGARAJAN_SS_S_S_S_V\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Asset User\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Residential\",' + 
        '          \"accountUuid\": \"C93C54A1-F6FE-402c-842F-90F098F2D4DB\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-2567502\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-16169822\",' + 
        '          \"lastName\": \"POSITIVE UPDATE\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Advocate\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"7755A6A9-2E6A-440f-98EB-9EC2F3A290DD\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16169822\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000741\",' + 
        '          \"lastName\": \"S\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Full Authority\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"5F100674-4859-46d6-A299-38AD569EAAA8\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000741\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000672\",' + 
        '          \"lastName\": \"SUNEETHA TEST\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Advocate\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"9F59196D-C858-48b7-A418-44C174C78AB6\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000672\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000254\",' + 
        '          \"lastName\": \"TCMTELSTRA\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Advocate\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Residential\",' + 
        '          \"accountUuid\": \"C9307A66-1347-4719-B9BE-9064CF3A786A\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000254\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000555\",' + 
        '          \"lastName\": \"TESTINGSINDHU\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Asset User\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Res/Bus\",' + 
        '          \"accountUuid\": \"FCFF06D9-3410-4407-AC2B-7DAFBAEB14DD\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000555\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"10000000050\",' + 
        '          \"lastName\": \"TESTTIMEZONE\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Legal Lessee\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"1-AOWOF\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000050\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-987152\",' + 
        '          \"lastName\": \"Test Record One\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Full Authority\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Business\",' + 
        '          \"accountUuid\": \"3E33D40D-4C19-4ea4-8B7F-61B56366A62A\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-987152\"' + 
        '        },' + 
        '        {' + 
        '          \"id\": \"1-16240534\",' + 
        '          \"lastName\": \"YAHOO GROUPS\",' + 
        '          \"contactRelationship\": {' + 
        '            \"contactType\": \"Legal Lessee\",' + 
        '            \"endDate\": \"\"' + 
        '          },' + 
        '          \"contactUsage\": \"Residential\",' + 
        '          \"accountUuid\": \"AA78869C-3189-4177-A534-3BF0AAE6D06C\",' + 
        '          \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16240534\"' + 
        '        }' + 
        '      ],' + 
        '      \"status\": \"Active\",' + 
        '      \"workContact\": {' + 
        '        \"faxNumber\": \"\",' + 
        '        \"phoneNumber\": \"\",' + 
        '        \"emailAddress\": \"\",' + 
        '        \"mobileNumber\": \"\"' + 
        '      },' + 
        '      \"id\": \"520A4E0E-0F82-4122-AE88-7E57130F7511\",' + 
        '      \"title\": \"MR\",' + 
        '      \"identification\": {' + 
        '        \"driverLicense\": {' + 
        '          \"state\": \"\",' + 
        '          \"number\": \"\"' + 
        '        }' + 
        '      },' + 
        '      \"birthDate\": \"1982-08-18\",' + 
        '      \"firstName\": \"VENKATESH\",' + 
        '      \"homeContact\": {' + 
        '        \"faxNumber\": \"\",' + 
        '        \"phoneNumber\": \"\",' + 
        '        \"emailAddress\": \"Raj.Moturi@team.Telstra.Com\",' + 
        '        \"mobileNumber\": \"\"' + 
        '      },' + 
        '      \"href\": \"/v1/customer-self-management /tcm/contacts/520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts\"' + 
        '    }' + 
        '  ]' + 
        '}';
        
        return jsonString;
    }
    
    private String getTCMContactCustomers() {
        String jsonString = '{' + 
        '  \"data\": {' + 
        '    \"middleName\": \"VVVVVV\",' + 
        '    \"preferredMethod\": \"eMail\",' + 
        '    \"lastName\": \"ARUN\",' + 
        '    \"onlineFlag\": \"N\",' + 
        '    \"customerAccounts\": [' + 
        '      {' + 
        '        \"id\": \"10000002126\",' + 
        '        \"lastName\": \"AARATHY SD\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"\",' + 
        '        \"accountUuid\": \"72891852-47BA-4d69-9741-F939FE022017\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000002126\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-4626502\",' + 
        '        \"lastName\": \"ARUNTESTING\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Legal Lessee\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"E6776958-0659-4798-8E71-1F153A517B62\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-4626502\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000073\",' + 
        '        \"lastName\": \"CHOWN\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Full Authority\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"006AA385-C5F5-4ccf-9542-68EB72C0FD6F\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000073\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000072\",' + 
        '        \"lastName\": \"CHRISTINA\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Full Authority\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"10C05486-651F-45b7-BDEB-94725F1DFE32\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000072\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000001143\",' + 
        '        \"lastName\": \"DEFECTRETESTING\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Asset User\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Res/Bus\",' + 
        '        \"accountUuid\": \"DD2C0C0C-AA21-438a-A57A-51044CBF147D\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000001143\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-16400746\",' + 
        '        \"lastName\": \"FUNCTIONAL\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Asset User\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"C775EB9D-7EDA-40ff-B4CA-56B9924F4C69\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16400746\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-938826\",' + 
        '        \"lastName\": \"GALARIASDEE\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Legal Lessee\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"1-K4EI\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-938826\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-2567502\",' + 
        '        \"lastName\": \"NAGARAJAN_SS_S_S_S_V\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Asset User\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Residential\",' + 
        '        \"accountUuid\": \"C93C54A1-F6FE-402c-842F-90F098F2D4DB\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-2567502\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-16169822\",' + 
        '        \"lastName\": \"POSITIVE UPDATE\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Advocate\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"7755A6A9-2E6A-440f-98EB-9EC2F3A290DD\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16169822\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000741\",' + 
        '        \"lastName\": \"S\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Full Authority\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"5F100674-4859-46d6-A299-38AD569EAAA8\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000741\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000672\",' + 
        '        \"lastName\": \"SUNEETHA TEST\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Advocate\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"9F59196D-C858-48b7-A418-44C174C78AB6\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000672\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000254\",' + 
        '        \"lastName\": \"TCMTELSTRA\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Advocate\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Residential\",' + 
        '        \"accountUuid\": \"C9307A66-1347-4719-B9BE-9064CF3A786A\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000254\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000555\",' + 
        '        \"lastName\": \"TESTINGSINDHU\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Asset User\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Res/Bus\",' + 
        '        \"accountUuid\": \"FCFF06D9-3410-4407-AC2B-7DAFBAEB14DD\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000555\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"10000000050\",' + 
        '        \"lastName\": \"TESTTIMEZONE\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Legal Lessee\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"1-AOWOF\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/10000000050\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-987152\",' + 
        '        \"lastName\": \"Test Record One\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Full Authority\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Business\",' + 
        '        \"accountUuid\": \"3E33D40D-4C19-4ea4-8B7F-61B56366A62A\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-987152\"' + 
        '      },' + 
        '      {' + 
        '        \"id\": \"1-16240534\",' + 
        '        \"lastName\": \"YAHOO GROUPS\",' + 
        '        \"contactRelationship\": {' + 
        '          \"contactType\": \"Legal Lessee\",' + 
        '          \"endDate\": \"\"' + 
        '        },' + 
        '        \"contactUsage\": \"Residential\",' + 
        '        \"accountUuid\": \"AA78869C-3189-4177-A534-3BF0AAE6D06C\",' + 
        '        \"href\": \"/v1/customer-self-management/tcm/customer-accounts/1-16240534\"' + 
        '      }' + 
        '    ],' + 
        '    \"status\": \"Active\",' + 
        '    \"workContact\": {' + 
        '      \"faxNumber\": \"\",' + 
        '      \"phoneNumber\": \"\",' + 
        '      \"emailAddress\": \"\",' + 
        '      \"mobileNumber\": \"\"' + 
        '    },' + 
        '    \"id\": \"520A4E0E-0F82-4122-AE88-7E57130F7511\",' + 
        '    \"title\": \"MR\",' + 
        '    \"identification\": {' + 
        '      \"driverLicense\": {' + 
        '        \"state\": \"\",' + 
        '        \"number\": \"\"' + 
        '      }' + 
        '    },' + 
        '    \"birthDate\": \"1982-08-18\",' + 
        '    \"firstName\": \"VENKATESH\",' + 
        '    \"homeContact\": {' + 
        '      \"faxNumber\": \"\",' + 
        '      \"phoneNumber\": \"\",' + 
        '      \"emailAddress\": \"Raj.Moturi@team.Telstra.Com\",' + 
        '      \"mobileNumber\": \"\"' + 
        '    },' + 
        '    \"href\": \"/v1/customer-self-management /tcm/contacts/520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts\"' + 
        '  }' + 
        '}';
        
        return jsonString;
    }

    private String get10000142602_excludeContacts() {
        return '{"data":{"customers":[{"location":"10410000000000","servicingOrgUnit":"BUSSTD","languagePreference":"English","parentCidn":"","customerAccount":{"preferredMethod":"White Mail","lastName":"TEGSFDCINTEG","acn":"","fraudFlag":"N","driverLicenceNumber":"","effectiveRetiredDate":"","webAddress":"","emailAddress":"","dataSovereignty":"SFDC Integration","abn":"10000000000","driverLicenceState":"","title":"","faxNumber":"","phoneNumber":"","birthDate":"","accountUuid":"C3DE634F-6ED9-4240-9427-FA428F582BD4","firstName":""},"accountTrading":[{"isPrimary":"","tradingName":""}],"cac":"2021851050","marketSegment":"Fed Government Key","customerManagedFlag":"Y","accountStatus":"ACTIVE","createdDate":"2016-09-09T00:00:00+11:00","geographicalLocationCode":"1V","customerType":"Company","customerSince":"2016-09-09","accountPortfolio":[{"portfolioName":"TB NEW CUSTOMERS VICS","isPrimary":"Y","accountExecutiveLastName":"TB MASS NEW CUSTOMER","portfolioCode":"SVU01","accountExecutivePhoneNumber":"132000\n00 0000","accountExecutiveFirstName":"VIC"}],"lastUpdated":"2016-09-09T00:00:00+11:00","cidn":"4856204628","ultimateParentCidn":"","ownershipCode":"KAA","businessUnit":"Enterprise","category":{"online":"N"},"revenueOrganisationUnit":"EEKAA1","priorityAssist":"N","address":[{"state":"VIC","streetTypeCode":"STREET","addressId":"T12054518","statusCode":"","streetTypeSuffixCode":"","postalCode":"3000","registeredPlan":"","streetNumberStart":"12","subAddress":{"propertyName":"","privateStreetType":"","privateStreetName":"","details":[{"detailType":"","value":"","detailTypeCode":""},{"detailType":"","value":"","detailTypeCode":""}],"numberStart":"8","buildingName":"","addressLines":["_","",""],"numberEnd":"","privateStreetTypeCode":""},"streetType":"ST","internationalState":"","isPrimary":"Y","status":"","streetNumberStartSuffix":"","streetName":"LONSDALE","addressType":"","additionalInfo":"","country":"AUSTRALIA","internationalPostcode":"","addressTypeCode":"APARTMENT","streetTypeSuffix":"","streetNumberEnd":"","deliveryPointId":"","streetNumberEndSuffix":"","locality":"MELBOURNE"}],"masterID":"10000142602","premiumService":"N"}],"paging":{"limit":"50","lastPage":"Y","resultBlockSize":"1","offset":"0"}}}';
    }
    
    private String get10000142602_includeContacts() {
        return '{"data":{"id":10000002124,"lastName":"ALI","acn":"","accountStatus":"ACQUIRED","birthDate":"1977-01-03","firstName":"ALI","abn":""}}';
    }
}