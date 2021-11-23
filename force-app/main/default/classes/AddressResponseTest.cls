@isTest
public class AddressResponseTest
{
   @isTest
    public static void test_parseSuccess() {
    	//String json = '{"correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6","data":{"resultCount":16,"structured":[{"addressSummaryType":"PropertyAddressSummary","addressId":"240427074","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":17,"condorCode":"AUBN","postcode":"2144","state":"NSW","localityName":"AUBURN","propertyNumberFrom":14,"propertyNumberTo":15,"streetName":"STATION","fsam":"AUSBNT","ruralmailType":"EMAIL","ruralmailNumber":"R001","postalDeliveryType":"POST","postalDeliveryNumberPrefix":"AU","postalDeliveryNumber":"0067","postalDeliveryNumberSuffix":"MEL","planNumber":"008","parcelType":"AUMELPARCEL","parcelNumber":"0039","parcelDescriptor1Prefix":"AUS","parcelDescriptor2":"MELB","parcelDescriptionType2":"AUSMEL","parcelDescriptor2Prefix":"AUSMELB","streetType":"ROAD","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4","facsRealm":"27","locationId":"9880016","customerServiceAreaId":"151","readyForServiceDate":"01/01/2020","exchangeServiceArea":"LIDC"},"subaddresses":{}}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"240427074","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"2144","state":"NSW","localityName":"AUBURN","addressline1":"14 STATION RD,","condorCode":"AUBN","fsam":"AUSBNT","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4"}}]},"code":200,"status":200,"time":"2018-01-09T17:02:22+11:00","request":{"params":{},"data":{"searchOptions":{"sortType":"Default","addressesToSkip":0,"addressesToReturn":16,"fuzzyOptions":{"enabled":false},"addressType":"serviceAddress"},"searchData":{"buildingName":"Regent","streetNumber":"14","streetName":"station","streetType":"road","suburb":"auburn","state":"nSw","postcode":"2144"}},"path":"/structured","method":"POST","requestId":"36574e24-af3d-4413-b0cd-ad9d37f036a8","correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6"}}';
        String json ='{"correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6","data":{"structured":[{"addressSummaryType":"PropertyAddressSummary","addressId":"240427074","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","condorCode":"AUBN","numSubaddresses":17,"postcode":"2144","state":"NSW","localityName":"AUBURN","streetName":"STATION","streetType":"ROAD","subAddressNumberFrom":"159","subAddressType":"Rural","number_x":"1963","numberTo":"196","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4","facsRealm":"27","exchangeServiceArea":"LIDC","locationId":"9880016","customerServiceAreaId":"151","readyForServiceDate":"01/01/2020"},"propertyNumberFrom":14,"propertyNumberTo":15,"subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","SubAddressType":"BUILDING","ID":265087139,"parentID":240427074,"Confirmed":true,"from":1,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"FLOOR","ID":265087142,"parentID":265087139,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265087143,"parentID":265087139,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":400308880,"parentID":265087143,"Confirmed":true,"from":6},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":400308751,"parentID":265087143,"Confirmed":true,"from":7}]}]}]},"fsam":"AUSBNT","ruralmailType":"EMAIL","ruralmailNumber":"R001","postalDeliveryType":"POST","postalDeliveryNumberPrefix":"AU","postalDeliveryNumber":"0067","postalDeliveryNumberSuffix":"MEL","planNumber":"008","parcelType":"AUMELPARCEL","parcelNumber":"0039","parcelDescriptor1Prefix":"AUS","parcelDescriptor2":"MELB","parcelDescriptionType2":"AUSMEL","parcelDescriptor2Prefix":"AUSMELB"}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"240427074","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"2144","state":"NSW","localityName":"AUBURN","condorCode":"AUBN","addressline1":"14 STATION RD,","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4"},"fsam":"AUSBNT"}],"resultCount":16},"code":200,"status":200,"time":"2018-01-09T17:02:22+11:00","request":{"params":{},"data":{"searchOptions":{"addressesToSkip":0,"addressesToReturn":16,"fuzzyOptions":{"enabled":false},"addressType":"serviceAddress","sortType":"Default"},"searchData":{"suburb":"auburn","state":"nSw","postcode":"2144","buildingName":"Regent","streetNumber":"14","streetName":"station","streetType":"road"}},"path":"/structured","method":"POST","requestId":"36574e24-af3d-4413-b0cd-ad9d37f036a8","correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6"}}';
        Test.startTest();
    	AddressResponse addRes = AddressResponse.parse(json);
        System.debug('test_parseSuccess::' + addRes);
    	Test.stopTest(); 
        
        System.assert(addRes.correlationId == '72ebbb18-5ef8-4237-b22b-b6f7116ad6b6');
        System.assert(addRes.code == 200);
        System.assert(addRes.status == 200);
        System.assert(addRes.res_time == '2018-01-09T17:02:22+11:00');        
        System.assert(addRes.data.resultCount == 16);
        System.assert(addRes.data.structured[0].addressSummaryType == 'PropertyAddressSummary');
        System.assert(addRes.data.structured[0].addressId == '240427074');
        System.assert(addRes.data.structured[0].addressType == 'Property with Number');
        System.assert(addRes.data.structured[0].confirmed == True);
        System.assert(addRes.data.structured[0].reqaddformatout == 'structured');
        System.assert(addRes.data.structured[0].numSubaddresses == 17);
        System.assert(addRes.data.structured[0].condorCode == 'AUBN');
        System.assert(addRes.data.structured[0].postcode == '2144');
        System.assert(addRes.data.structured[0].state == 'NSW');
        System.assert(addRes.data.structured[0].localityName == 'AUBURN');
        System.assert(addRes.data.structured[0].propertyNumberFrom == 14);
        System.assert(addRes.data.structured[0].propertyNumberTo == '15');
        System.assert(addRes.data.structured[0].streetName == 'STATION');
        System.assert(addRes.data.structured[0].streetType == 'ROAD');
        System.assert(addRes.data.structured[0].localityName == 'AUBURN');
        System.assert(addRes.data.structured[0].fsam == 'AUSBNT');
                
        System.assert(addRes.data.structured[0].ruralmailType == 'EMAIL');
        System.assert(addRes.data.structured[0].ruralmailNumber == 'R001');        System.assert(addRes.data.structured[0].postalDeliveryType == 'POST');
        System.assert(addRes.data.structured[0].postalDeliveryNumberPrefix == 'AU');
        System.assert(addRes.data.structured[0].postalDeliveryNumber == '0067');
        System.assert(addRes.data.structured[0].postalDeliveryNumberSuffix == 'MEL');
        System.assert(addRes.data.structured[0].planNumber == '008');
        System.assert(addRes.data.structured[0].parcelType == 'AUMELPARCEL');
        System.assert(addRes.data.structured[0].parcelNumber == '0039');
        System.assert(addRes.data.structured[0].parcelDescriptor1Prefix == 'AUS');
        System.assert(addRes.data.structured[0].parcelDescriptor2 == 'MELB');
        System.assert(addRes.data.structured[0].parcelDescriptionType2 == 'AUSMEL');
        System.assert(addRes.data.structured[0].parcelDescriptor2Prefix == 'AUSMELB');
        
        System.assert(addRes.data.structured[0].subAddressNumberFrom == '159');
		System.assert(addRes.data.structured[0].subAddressType == 'Rural');
		System.assert(addRes.data.structured[0].number_x == 1963);
		System.assert(addRes.data.structured[0].numberTo == 196);
        
        System.assert(addRes.data.structured[0].serviceLocation.latitude == '-33:50:54.7');
        System.assert(addRes.data.structured[0].serviceLocation.longitude == '151:02:05.4');
        System.assert(addRes.data.structured[0].serviceLocation.facsRealm == '27');
        System.assert(addRes.data.structured[0].serviceLocation.exchangeServiceArea == 'LIDC');
        System.assert(addRes.data.structured[0].serviceLocation.locationId == '9880016');
        System.assert(addRes.data.structured[0].serviceLocation.customerServiceAreaId == '151');
        System.assert(addRes.data.structured[0].serviceLocation.readyForServiceDate == '01/01/2020');
        System.assert(addRes.request.path == '/structured');
        System.assert(addRes.request.method == 'POST');
        System.assert(addRes.request.requestId == '36574e24-af3d-4413-b0cd-ad9d37f036a8');
        System.assert(addRes.request.correlationId == '72ebbb18-5ef8-4237-b22b-b6f7116ad6b6');
    }
    
    @isTest
    public static void test_parseUnstructureSucess() {
       // String json='{"code":200,"status":200,"time":"2018-12-13T20:47:04+10:00","data":{"resultCount":1,"structured":[{"addressSummaryType":"ParcelAddressSummary","addressId":"267034724","addressType":"Parcel no plan","confirmed":true,"reqaddformatout":"structured","numSubaddresses":0,"parcelNumber":"3815","parcelType":"Lot","parcelDescriptor1Prefix":"F","condorCode":"KEYSBRO","postcode":"3173","state":"VIC","localityName":"KEYSBOROUGH","streetName":"ABERCROMBIE","streetType":"AVENUE","serviceLocation":{"latitude":"-38:00:38.7","longitude":"145:09:45.6","facsRealm":"15","exchangeServiceArea":"KEYS"}}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"267034724","addressType":"Parcel no plan","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3173","state":"VIC","localityName":"KEYSBOROUGH","addressline1":"L 3815,","addressline2":"ABERCROMBIE AVE,","parcelNumber":"3815","parcelType":"Lot","parcelDescriptor1Prefix":"F","condorCode":"KEYSBRO","serviceLocation":{"latitude":"-38:00:38.7","longitude":"145:09:45.6"}}]},"request":{"params":{"correlationId":"a05a5e62-773b-4546-70a4-e72096aec687"},"data":{"searchOptions":{"addressesToSkip":0,"addressesToReturn":25,"fuzzyOptions":{"enabled":true},"addressType":"All","responseFormats":["unstructuredAUPost","structured"]},"searchData":{"addressLine1":"L 3815","suburb":"Keysborough","state":"VIC","postcode":"3173"}},"path":"/unstructured","method":"POST","requestId":"93f662e7-64ca-4dce-8a93-c9c6e8462e89","correlationId":"a05a5e62-773b-4546-70a4-e72096aec687"},"correlationId":"a05a5e62-773b-4546-70a4-e72096aec687"}';
        String json ='{"correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6","data":{"structured":[{"addressSummaryType":"PropertyAddressSummary","addressId":"240427074","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","condorCode":"AUBN","numSubaddresses":17,"postcode":"2144","state":"NSW","localityName":"AUBURN","streetName":"STATION","streetType":"ROAD","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4","facsRealm":"27","exchangeServiceArea":"LIDC"},"propertyNumberFrom":14,"propertyNumberTo":"","subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","SubAddressType":"BUILDING","ID":265087139,"parentID":240427074,"Confirmed":true,"from":1,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"FLOOR","ID":265087142,"parentID":265087139,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265087143,"parentID":265087139,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":400308880,"parentID":265087143,"Confirmed":true,"from":6},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":400308751,"parentID":265087143,"Confirmed":true,"from":7}]}]}]}}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"240427074","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"2144","state":"NSW","localityName":"AUBURN","condorCode":"AUBN","addressline1":"14 STATION RD,","serviceLocation":{"latitude":"-33:50:54.7","longitude":"151:02:05.4"},"addressline2":"14 STATION","planNumber":"159","parcelNumber":"963258","parcelType":"MAIL","parcelDescriptor1Prefix":"AU","fsam":"FSAM","subAddressType":"Rural"}],"resultCount":16},"code":200,"status":200,"time":"2018-01-09T17:02:22+11:00","request":{"params":{},"data":{"searchOptions":{"addressesToSkip":0,"addressesToReturn":16,"fuzzyOptions":{"enabled":false},"addressType":"serviceAddress","sortType":"Default"},"searchData":{"suburb":"auburn","state":"nSw","postcode":"2144","buildingName":"Regent","streetNumber":"14","streetName":"station","streetType":"road"}},"path":"/structured","method":"POST","requestId":"36574e24-af3d-4413-b0cd-ad9d37f036a8","correlationId":"72ebbb18-5ef8-4237-b22b-b6f7116ad6b6"}}';
        Test.startTest();
    	AddressResponse addRes = AddressResponse.parse(json);
        System.debug('test_parseSuccess::' + addRes);
    	Test.stopTest();
        System.assert(addRes.code == 200);
        System.assert(addRes.status == 200);  
        System.assert(addRes.data.resultCount == 16);
        System.assert(addRes.data.unstructuredAUPost[0].addressSummaryType == 'FormattedAddressSummary');
        System.assert(addRes.data.unstructuredAUPost[0].addressId == '240427074');
        System.assert(addRes.data.unstructuredAUPost[0].addressType == 'Property with Number');
        System.assert(addRes.data.unstructuredAUPost[0].reqaddformatout == 'unstructuredAUPost');
        System.assert(addRes.data.unstructuredAUPost[0].confirmed == True);
        System.assert(addRes.data.unstructuredAUPost[0].postcode == '2144');
        System.assert(addRes.data.unstructuredAUPost[0].state == 'NSW');
        System.assert(addRes.data.unstructuredAUPost[0].localityName == 'AUBURN');
        System.assert(addRes.data.unstructuredAUPost[0].condorCode == 'AUBN');
        
        System.assert(addRes.data.unstructuredAUPost[0].addressline1 == '14 STATION RD,');
		System.assert(addRes.data.unstructuredAUPost[0].addressline2 == '14 STATION');
		System.assert(addRes.data.unstructuredAUPost[0].planNumber == '159');
		System.assert(addRes.data.unstructuredAUPost[0].parcelNumber == '963258');
		System.assert(addRes.data.unstructuredAUPost[0].parcelType == 'MAIL');
		System.assert(addRes.data.unstructuredAUPost[0].parcelDescriptor1Prefix == 'AU');
		System.assert(addRes.data.unstructuredAUPost[0].fsam == 'FSAM');
		System.assert(addRes.data.unstructuredAUPost[0].subAddressType == 'Rural');
        
        System.assert(addRes.data.unstructuredAUPost[0].serviceLocation.latitude == '-33:50:54.7');
        System.assert(addRes.data.unstructuredAUPost[0].serviceLocation.longitude == '151:02:05.4');
        System.assert(addRes.request.path == '/structured');
        System.assert(addRes.request.method == 'POST');
        System.assert(addRes.request.requestId == '36574e24-af3d-4413-b0cd-ad9d37f036a8');
        System.assert(addRes.request.correlationId == '72ebbb18-5ef8-4237-b22b-b6f7116ad6b6');
       
        System.assert(addRes.data.structured[0].subaddresses.level1[0].AddressType == 'Complex - Building with Number');
		System.assert(addRes.data.structured[0].subaddresses.level1[0].SubAddressType == 'BUILDING');
		System.assert(addRes.data.structured[0].subaddresses.level1[0].ID == 265087139);
		System.assert(addRes.data.structured[0].subaddresses.level1[0].parentID == 240427074);
		System.assert(addRes.data.structured[0].subaddresses.level1[0].Confirmed == True);
		System.assert(addRes.data.structured[0].subaddresses.level1[0].res_from == '1');
        
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].AddressType == 'Complex - Floor/Level');
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].SubAddressType == 'FLOOR');
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].ID == 265087142);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].parentID == 265087139);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].Confirmed == true);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[0].res_from == '1');
        
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].AddressType == 'Complex - Flat/Unit');
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].SubAddressType == 'UNIT');
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].ID == 400308880);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].parentID == 265087143);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].Confirmed == true);
        System.assert(addRes.data.structured[0].subaddresses.level1[0].Level2[1].Level3[0].res_from == '6');
    }
    
    @isTest
    public static void test_parseError() {
        String json = '{"correlationId":"b4c8bb9f-8874-48db-88d3-d033221c306d","code":3007,"status":400,"time":"2017-12-01T20:51:50+11:00","request":{"params":{},"data":{"searchOptions":{"sortType":"Default","addressesToSkip":5,"addressesToReturn":5,"fuzzyOptions":{"enabled":true},"addressType":"serviceAddress","navigators":"disabled","responseFormats":["structured","unstructuredAUPost"]},"searchData":{"streetNumber":"2","streetName":"scotsman","streetType":"street","suburb":"forest lodge","state":"VIC1","postcode":"3000","unitNumber":"209","addressType":"Unit","floorNumber":"29","buildingNumber":"2","streetSuffix":"west"}},"path":"/structured","method":"POST","requestId":"ae977821-6b99-4c80-9b60-681727f36104","correlationId":"b4c8bb9f-8874-48db-88d3-d033221c306d"},"message":"Unable to process the address Request"}';
    	Test.startTest();
    	AddressResponse addRes = AddressResponse.parse(json);
        System.debug('test_parseError::' + addRes);
    	Test.stopTest();
        System.assert(addRes.correlationId == 'b4c8bb9f-8874-48db-88d3-d033221c306d');
        System.assert(addRes.code == 3007);
        System.assert(addRes.status == 400);
        System.assert(addRes.res_time == '2017-12-01T20:51:50+11:00'); 
        System.assert(addRes.message == 'Unable to process the address Request'); 
    }
    
	
	@isTest
    public static void test_parseAutocomp() {
        String json = '{"correlationId":"515f3ae5-fad5-4786-9515-db7f825546fc","requestId":"9ecce65d-04a7-4819-b596-a2f959a78884","results":[{"source":"experian","position":0,"raw":"AUE&#124;0bf29ee6-79bb-4084-8cbd-32bf642d6c5a&#124;0MOAUEGwjiBwAAAAAIAwEAAAAA4A5kEAAhAA4AAAAAAAAAAAD..2QAAAAA.....wAAAAAAAAAAAAAAAAA0MDAgR2VvcmdlIFN0cmVldCBTeWRuZXkA$24","name":"400 George Street, SYDNEY  NSW  2000"}]}';
    	Test.startTest();
    	AddressResponse addRes = AddressResponse.parse_unstruct(json);
        System.debug('test_parseSucc::' + addRes);
    	Test.stopTest();
        System.assert(addRes.correlationId == '515f3ae5-fad5-4786-9515-db7f825546fc');
        System.assert(addRes.requestId == '9ecce65d-04a7-4819-b596-a2f959a78884');
        System.assert(addRes.results[0].source== 'experian');
        System.assert(addRes.results[0].position == 0); 
        System.assert(addRes.results[0].raw == 'AUE&#124;0bf29ee6-79bb-4084-8cbd-32bf642d6c5a&#124;0MOAUEGwjiBwAAAAAIAwEAAAAA4A5kEAAhAA4AAAAAAAAAAAD..2QAAAAA.....wAAAAAAAAAAAAAAAAA0MDAgR2VvcmdlIFN0cmVldCBTeWRuZXkA$24'); 
		System.assert(addRes.results[0].name=='400 George Street, SYDNEY  NSW  2000');
    }
	
    @isTest
    public static void test_parseAdborId() {
        String json = '{"code": 200,"status": 200,"time": "2018-12-18T19:53:00+10:00", "data": { "transactionStatus": "Success","matchingresultscount": 1, "structured": { "addresses": {  "addressSummaryType": "PropertyAddressSummary", "addressId": "161152457","addressType": "Property with Number", "confirmed": true,"reqaddformatout": "structured","condorCode": "WERBEE S", "fsam": "3PCO-07", "numSubaddresses": 0,"postcode": "3030",  "state": "VIC","localityName": "WERRIBEE SOUTH", "propertyNumberFrom": 1, "propertyNumberTo": "","streetName": "FINCH", "streetType": "ROAD"  },  "serviceLocation": { "latitude": "-37:58:16.5","longitude": "144:41:16.0", "locationId": "LOC000005203996",         "customerServiceAreaId": "CSA300000010923","readyForServiceDate": "2019-04-01","exchangeServiceArea": "WBES", "facsRealm": "14"} }, "unstructuredAUPost": { "addresses": {  "addressSummaryType": "FormattedAddressSummary","addressId": "161152457",         "addressType": "Property with Number","reqaddformatout": "unstructuredAUPost","confirmed": true, "postcode": "3030", "state": "VIC", "localityName": "WERRIBEE SOUTH","condorCode": "WERBEE S","fsam": "3PCO-07","addressline1": "1 FINCH RD,"},  "serviceLocation": { "latitude": "-37:58:16.5", "longitude": "144:41:16.0","locationId": "LOC000005203996", "customerServiceAreaId": "CSA300000010923","readyForServiceDate": "2019-04-01" } } }, "request": {"params": {"addressId": "161152457", "reqaddformatout": "unstructuredAUPost,structured" },     "data": {},"path": "/addresses/:addressId", "method": "GET", "requestId": "4cc98b1e-85e4-4827-8ae0-4eca4c47e389",  "correlationId": "593a8033-19f0-4084-a4f5-3182931601b8" },"correlationId": "593a8033-19f0-4084-a4f5-3182931601b8" }';
       //tring json = '{"data":{"structured":{"addresses":{"addressSummaryType":"PropertyAddressSummary","addressId":"161152457","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","condorCode":"WERBEE S","fsam":"3PCO-07","numSubaddresses":0,"postcode":"3030","state":"VIC","localityName":"WERRIBEE SOUTH","propertyNumberFrom":1,"propertyNumberTo":9,"streetName":"FINCH","streetType":"ROAD"},"serviceLocation":{"latitude":"-37:58:16.5","longitude":"144:41:16.0","locationId":"LOC000005203996","customerServiceAreaId":"CSA300000010923","readyForServiceDate":"2019-04-01","exchangeServiceArea":"WBES","facsRealm":"14"}},"unstructuredAUPost":{"addresses":{"addressSummaryType":"FormattedAddressSummary","addressId":"161152457","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3030","state":"VIC","localityName":"WERRIBEE SOUTH","condorCode":"WERBEE S","fsam":"3PCO-07","addressline1":"1 FINCH RD,"},"serviceLocation":{"latitude":"-37:58:16.5","longitude":"144:41:16.0","locationId":"LOC000005203996","customerServiceAreaId":"CSA300000010923","readyForServiceDate":"2019-04-01"}},"transactionStatus":"Success","matchingresultscount":1},"code":200,"status":200,"time":"2018-12-14T19:37:12+10:00","request":{"params":{"addressId":"161152457","reqaddformatout":"unstructuredAUPost,structured"},"data":{},"path":"/addresses/:addressId","method":"GET","requestId":"57e3c487-bed2-49ab-9d3b-8c0f60ed5f93","correlationId":"a124a68b-b3ca-4e78-adab-774659d1277f"},"correlationId":"a124a68b-b3ca-4e78-adab-774659d1277f"}';
        //String json = '{"code": 200,"status": 200,"time": "2017-11-28T19:30:51+11:00","data": { "result": {"status": 0,"addresses": { "confirmed": true, "addressSummaryType": "PropertyAddressSummary","addressId": "161152457", "addressType": "PRNUM", "postcode": "3030", "state": "VIC", "locality": "WERRIBEE SOUTH",  "number": 1,"numberTo": 0,  "streetName": "FINCH",  "streetType": "ROAD" }, "serviceLocation": { "exchangeServiceArea": "WBES", "facsRealm": "39", "latitude": "-37:58:16.5",   "longitude": "144:41:16.0",  "readyForServiceDate": "2009-10-11", "locationId": "LOC160829045445", "customerServiceAreaId": "CSA200000000199" }, "matchingresultscount": 1 } }, "request": {  "params": {}, "data": { "requestParams": { "adborId": "161152457" } }, "path": "/address-detail", "method": "POST", "requestId": "80a5fc6b-e4f5-4a41-9826-42afcf57d669", "correlationId": "be66fb03-c34e-4e4d-a859-8f1345d25db9" }, "correlationId": "be66fb03-c34e-4e4d-a859-8f1345d25db9" } ' ;
    	Test.startTest();
    	AddressResponse addRes = AddressResponse.parse_adbor(json);
        System.debug('test_parseAdborId::' + addRes);
    	Test.stopTest();
        System.assert(addRes.request.method == 'GET');
		System.assert(addRes.request.correlationId == '593a8033-19f0-4084-a4f5-3182931601b8');
        System.assert(addRes.request.requestId == '4cc98b1e-85e4-4827-8ae0-4eca4c47e389');
        System.assert(addRes.request.path == '/addresses/:addressId');
        System.assert(addRes.code == 200);
        System.assert(addRes.status == 200);
		System.assert(addRes.res_time == '2018-12-18T19:53:00+10:00');
        System.assert(addRes.data.matchingresultscount == 1);
        System.assert(addRes.data.structured_adbor.addresses.confirmed == true);
        System.assert(addRes.data.structured_adbor.addresses.addressSummaryType == 'PropertyAddressSummary');
        System.assert(addRes.data.structured_adbor.addresses.addressId == '161152457');
        System.assert(addRes.data.structured_adbor.addresses.addressType == 'Property with Number');
		//System.assert(addRes.data.structured_adbor.addresses.reqaddformatout == 'structured');
		System.assert(addRes.data.structured_adbor.addresses.condorCode == 'WERBEE S');
		System.assert(addRes.data.structured_adbor.addresses.fsam == '3PCO-07');
		System.assert(addRes.data.structured_adbor.addresses.numSubaddresses == 0);
		System.assert(addRes.data.structured_adbor.addresses.propertyNumberFrom == 1);
        System.assert(addRes.data.structured_adbor.addresses.postcode == '3030');
        System.assert(addRes.data.structured_adbor.addresses.state == 'VIC');
        System.assert(addRes.data.structured_adbor.addresses.localityName == 'WERRIBEE SOUTH');
        System.assert(addRes.data.structured_adbor.addresses.propertyNumberTo == '');
        System.assert(addRes.data.structured_adbor.addresses.streetName == 'FINCH');
        System.assert(addRes.data.structured_adbor.addresses.streetType == 'ROAD');
        System.assert(addRes.data.structured_adbor.serviceLocation.latitude == '-37:58:16.5');
        System.assert(addRes.data.structured_adbor.serviceLocation.longitude == '144:41:16.0');
        System.assert(addRes.data.structured_adbor.serviceLocation.exchangeServiceArea == 'WBES');
        System.assert(addRes.data.structured_adbor.serviceLocation.facsRealm == '14');
        System.assert(addRes.data.structured_adbor.serviceLocation.readyForServiceDate == '2019-04-01');
        System.assert(addRes.data.structured_adbor.serviceLocation.customerServiceAreaId == 'CSA300000010923');
        System.assert(addRes.data.structured_adbor.serviceLocation.locationId == 'LOC000005203996');
		System.assert(addRes.request.params.addressId == '161152457');
		//System.assert(addRes.request.params.reqaddformatout == 'unstructuredAUPost,structured');
		System.assert(addRes.request.path == '/addresses/:addressId');
        System.assert(addRes.request.method == 'GET');
    }

}