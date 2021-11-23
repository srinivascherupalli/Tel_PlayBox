@isTest
public class FNNServiceTest
{
    @isTest 
    static void testSearchFNN() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.geoParam = '1234';
		fdo.geoParamValue =  '1234';
		fdo.addressId = '123456789';
		fdo.quantity = 1;
		fdo.pattern = 'horz';
		fdo.searchType = 'Random';
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
		fnnSer.searchFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('Search_Success::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-SUCCESS');

    }
    
    @isTest
    static void testSearchFNNFailed() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.geoParam = '1234';
		fdo.geoParamValue =  '1234';
		fdo.addressId = '123456789';
		fdo.quantity = 1;
		fdo.pattern = 'horz';
		fdo.searchType = 'Random';
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(404));
		fnnSer.searchFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(404);
        response = mockRes.respond(req);
        System.debug('SearchFNN_Response' + response);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('Search_Failure::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-RESOURCE_NOT_FOUND');

    }
    
    @isTest
    static void testReserveFNN() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.serviceIds = new List<String>{'123456','45678'};
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('reserveFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
		fnnSer.reserveFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('Reserve_Success::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-SUCCESS');
    }
    
    @isTest static void testReserveFNNFailed() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.serviceIds = new List<String>{'123456','45678'};
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('ReserveFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(404));
		fnnSer.reserveFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(404);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('Reserve_Fail::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-RESOURCE_NOT_FOUND');
    }
    
    
    @isTest 
    static void testSearchReserveMSISDN() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
		FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
		cto.value = 'Regular';
		ctoList.add(cto);
		fdo.poolName = 'prepaid';
		fdo.activityName =  'Direct Hold';
		fdo.addressId = '123456789';
		fdo.categoryType = ctoList;
		fdo.searchStatus = 'Available';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('SearchReserveMSISDNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
		fnnSer.searchReserveMSISDN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        System.debug('MSISDN_response::' + response);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('MSISDN_Success::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-SUCCESS');
    }
    
    @isTest 
    static void testSearchReserveMSISDNFailed() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
		FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
		cto.value = 'Regular';
		ctoList.add(cto);
		fdo.poolName = 'prepaid';
		fdo.activityName =  'Direct Hold';
		fdo.addressId = '123456789';
		fdo.categoryType = ctoList;
		fdo.searchStatus = 'Available';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('SearchReserveMSISDNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(404));
		fnnSer.searchReserveMSISDN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(404);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('MSISDN_Failure::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-RESOURCE_NOT_FOUND');
    }
	
	
	@isTest
    static void testUnReserveFNN() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.serviceIds = new List<String>{'123456','45678'};
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('UnReserveFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
		fnnSer.unReserveFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('unReserve_Success::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-SUCCESS');
    }
    
    @isTest static void testUnReserveFNNFailed() {
		FNNDTO dto = new FNNDTO();
		FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
		fdo.serviceIds = new List<String>{'123456','45678'};
		fdo.systemId = 'SFDC';
		dto.data = fdo;
		FNNService fnnSer = new FNNService();
		Test.startTest();
        Cache.Org.put('UnReserveFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(404));
		fnnSer.unReserveFNN(dto);
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
		FNNServiceMockResponse mockRes = new FNNServiceMockResponse(404);
        response = mockRes.respond(req);
        FNNResponseDTO fnnRes = (FNNResponseDTO) JSON.deserialize(response.getBody(), FNNResponseDTO.class);
        System.debug('unReserve_Fail::' + fnnRes);
		Test.stopTest();
        System.assertEquals(fnnRes.responseCode,'LRM-RESOURCE_NOT_FOUND');
    }
}