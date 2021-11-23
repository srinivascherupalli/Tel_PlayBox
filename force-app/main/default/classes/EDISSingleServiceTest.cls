@isTest
public class EDISSingleServiceTest {
    
    @isTest
    static void searchlistingTest(){
    EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
    dto.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
    dto.path ='/application/edis-eai/v2/directory-listings';
    dto.method = 'POST';
    
    EDISSingleRequestDTO.CustomerContactAddress cca = new EDISSingleRequestDTO.CustomerContactAddress();
    cca.ccaIdentifier = '1234';
    cca.ccaOverseasAddressLine1 = 'test' ;
    cca.ccaOverseasAddressLine2 = 'test1';
    cca.ccaOverseasAddressLine3 = 't6est2';
    cca.ccaOverseasAddressCountryCode = '123456';
    
    EDISSingleRequestDTO.ServiceOrderDetails soa = new EDISSingleRequestDTO.ServiceOrderDetails();
    soa.listCode ='123';
    soa.orderType ='123';
    soa.orderStatus ='123';
    soa.serviceType ='123';
    soa.orderID ='123';
    soa.originatingSystem ='123';
    soa.portFlag ='123';
    soa.productName ='123';
    soa.telstraAddressId ='123';
    soa.soCreationTimestamp ='123';
    soa.telstraCommitmentDate ='123';
    soa.provisionCompletionDate ='123';
    soa.temporaryServiceIndicator ='123';
    soa.interimServiceIndicator ='123';
    soa.alternateAddressFlag ='123';
    soa.originalFNN ='123';
    soa.originalFamilyName ='123';
    soa.originalGivenNames ='123';
    soa.originalAddressIdentifier ='123';
    soa.lineItemStatus ='123';
    
    EDISSingleRequestDTO.ListingDetails ld = new EDISSingleRequestDTO.ListingDetails();
    ld.familyOrEntityName ='123';
    ld.organizationName ='123';
    ld.givenNames ='123';
    ld.listingFNN ='123';
    ld.actionCode ='123';
    ld.subactionCode ='123';
    ld.reasonCode ='123';
    
    EDISSingleRequestDTO.CustomerDetails cd = new EDISSingleRequestDTO.CustomerDetails();
    cd.customerID ='123';
    cd.customerType ='123';
    cd.familyName ='123';
    cd.givenNames ='123';
    cd.registeredCompanyName ='123';
    cd.customerTitle ='123';
    cd.customerContactGivenNames ='123';
    cd.customerContactFamilyName ='123';
    cd.contactPosition ='123';
    cd.contactFNN ='123.00';
    cd.contactEmail ='123';
    
    EDISSingleRequestDTO.EDISReqDTO reqDTO = new EDISSingleRequestDTO.EDISReqDTO();
    reqDTO.type ='123';
    reqDTO.customerDetails =cd;
    reqDTO.listingDetails =ld;
    reqDTO.serviceOrderDetails =soa;
    reqDTO.customerContactAddress =cca;
    
    dto.data = reqDTO;
        
    Test.startTest();
        Integration_Record__c insertRecord1 = insertRecordBefore(dto);
        Integration_Record__c itr1= new Integration_Record__c();
        itr1.handler__c = 'SingleFNNListingHandler';
        itr1.params__c = 'SingleFNNListingHandlerParams';
        insert itr1;
    EDISSingleService.searchlisting(dto,'SingleFNNListingHandler');
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c FROM Integration_Record__c WHERE handler__c = 'SingleFNNListingHandler'AND id =: insertRecord1.id];
        System.assertNotEquals(0, existingRequests.size());
         Test.stopTest(); 
        }
    
    public static Integration_Record__c insertRecordBefore(EDISSingleRequestDTO dto){
        Integration_Record__c insertRecord = new Integration_Record__c();
        blob b = Crypto.generateAesKey(128);
        String GUID = EncodingUtil.convertToHex(b);
        insertRecord.params__c =GUID;
        insertRecord.paramPayload__c = JSON.serialize(dto);
        insertRecord.handler__c = 'SingleFNNListingHandler';
        insertRecord.status__c = IntegrationQueueHandler.PENDING;
        insert insertRecord;
        return insertRecord;
    }
    
    @isTest
    static void callEDISSingleServiceTest(){
        EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
    dto.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
    dto.path ='/application/edis-eai/v2/directory-listings';
    dto.method = 'POST';
    
    EDISSingleRequestDTO.CustomerContactAddress cca = new EDISSingleRequestDTO.CustomerContactAddress();
    cca.ccaIdentifier = '1234';
    cca.ccaOverseasAddressLine1 = 'test' ;
    cca.ccaOverseasAddressLine2 = 'test1';
    cca.ccaOverseasAddressLine3 = 't6est2';
    cca.ccaOverseasAddressCountryCode = '123456';
    
    EDISSingleRequestDTO.ServiceOrderDetails soa = new EDISSingleRequestDTO.ServiceOrderDetails();
    soa.listCode ='123';
    soa.orderType ='123';
    soa.orderStatus ='123';
    soa.serviceType ='123';
    soa.orderID ='123';
    soa.originatingSystem ='123';
    soa.portFlag ='123';
    soa.productName ='123';
    soa.telstraAddressId ='123';
    soa.soCreationTimestamp ='123';
    soa.telstraCommitmentDate ='123';
    soa.provisionCompletionDate ='123';
    soa.temporaryServiceIndicator ='123';
    soa.interimServiceIndicator ='123';
    soa.alternateAddressFlag ='123';
    soa.originalFNN ='123';
    soa.originalFamilyName ='123';
    soa.originalGivenNames ='123';
    soa.originalAddressIdentifier ='123';
    soa.lineItemStatus ='123';
    
    EDISSingleRequestDTO.ListingDetails ld = new EDISSingleRequestDTO.ListingDetails();
    ld.familyOrEntityName ='123';
    ld.organizationName ='123';
    ld.givenNames ='123';
    ld.listingFNN ='123';
    ld.actionCode ='123';
    ld.subactionCode ='123';
    ld.reasonCode ='123';
    
    EDISSingleRequestDTO.CustomerDetails cd = new EDISSingleRequestDTO.CustomerDetails();
    cd.customerID ='123';
    cd.customerType ='123';
    cd.familyName ='123';
    cd.givenNames ='123';
    cd.registeredCompanyName ='123';
    cd.customerTitle ='123';
    cd.customerContactGivenNames ='123';
    cd.customerContactFamilyName ='123';
    cd.contactPosition ='123';
    cd.contactFNN ='123.00';
    cd.contactEmail ='123';
    
    EDISSingleRequestDTO.EDISReqDTO reqDTO = new EDISSingleRequestDTO.EDISReqDTO();
    reqDTO.type ='123';
    reqDTO.customerDetails =cd;
    reqDTO.listingDetails =ld;
    reqDTO.serviceOrderDetails =soa;
    reqDTO.customerContactAddress =cca;
    
    dto.data = reqDTO;
        
    Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'SingleFNNListingHandler';
        itr.params__c = 'SingleFNNListingHandlerParams';
        insert itr;
        
    Test.startTest();
        Cache.Org.put('SingleFNNListingHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new EDISMockResponseGenerator());
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c FROM Integration_Record__c WHERE handler__c = 'SingleFNNListingHandler' AND id = :insertRecord.id];
		EDISSingleService.callEDISSingleService(existingRequests.get(0).params__c,'SingleFNNListingHandler');
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"path": "","method": "POST","data": { "type": "","serviceOrderDetails": { "temporaryServiceIndicator": "N","telstraCommitmentDate": null,"telstraAddressId": "241031544","soCreationTimestamp": null, "serviceType": "","provisionCompletionDate": "","productName": "","portFlag": "", "originatingSystem": "", "originalGivenNames": "","originalFNN": "","originalFamilyOrEntityName": "", "originalAddressIdentifier": "","orderType": "", "orderStatus": "","orderID": null,"listCode": "No Entry Line","lineItemStatus": "","interimServiceIndicator": "N","alternateAddressFlag": "T"},"listingDetails": {"subactionCode": "", "reasonCode": "","organizationName": "","listingFNN": "","givenNames": "TestMunich","familyOrEntityName": "TestMunich","actionCode": "add"},"customerDetails": {"registeredCompanyName": "", "givenNames": "TestMunich","familyName": "TestMunich","customerType": "Company","customerTitle": null,"customerID": "9834556", "customerContactGivenNames": "","customerContactFamilyName": "","contactPosition": "","contactFNN": 0,"contactEmail": "praj@gmail.com"},"customerContactAddress": {"ccaOverseasAddressLine3": "","ccaOverseasAddressLine2": "","ccaOverseasAddressLine1": "","ccaOverseasAddressCountryCode": "","ccaIdentifier": "241031544"}},"correlationId": "798cd026-07e1-7af1-9e5d-1f20f9f7d9bd"}}');
		req.setMethod('POST');
		EDISMockResponseGenerator mockRes = new EDISMockResponseGenerator();
        response = mockRes.respond(req);
        EDISSingleResponseDTO Res = (EDISSingleResponseDTO) JSON.deserialize(response.getBody(), EDISSingleResponseDTO.class);
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        Test.stopTest();
        
    }
    
     @isTest
    static void singleFNNListingHanlderTest(){
        EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
    dto.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
    dto.path ='/application/edis-eai/v2/directory-listings';
    dto.method = 'POST';
    
    EDISSingleRequestDTO.CustomerContactAddress cca = new EDISSingleRequestDTO.CustomerContactAddress();
    cca.ccaIdentifier = '1234';
    cca.ccaOverseasAddressLine1 = 'test' ;
    cca.ccaOverseasAddressLine2 = 'test1';
    cca.ccaOverseasAddressLine3 = 't6est2';
    cca.ccaOverseasAddressCountryCode = '123456';
    
    EDISSingleRequestDTO.ServiceOrderDetails soa = new EDISSingleRequestDTO.ServiceOrderDetails();
    soa.listCode ='123';
    soa.orderType ='123';
    soa.orderStatus ='123';
    soa.serviceType ='123';
    soa.orderID ='123';
    soa.originatingSystem ='123';
    soa.portFlag ='123';
    soa.productName ='123';
    soa.telstraAddressId ='123';
    soa.soCreationTimestamp ='123';
    soa.telstraCommitmentDate ='123';
    soa.provisionCompletionDate ='123';
    soa.temporaryServiceIndicator ='123';
    soa.interimServiceIndicator ='123';
    soa.alternateAddressFlag ='123';
    soa.originalFNN ='123';
    soa.originalFamilyName ='123';
    soa.originalGivenNames ='123';
    soa.originalAddressIdentifier ='123';
    soa.lineItemStatus ='123';
    
    EDISSingleRequestDTO.ListingDetails ld = new EDISSingleRequestDTO.ListingDetails();
    ld.familyOrEntityName ='123';
    ld.organizationName ='123';
    ld.givenNames ='123';
    ld.listingFNN ='123';
    ld.actionCode ='123';
    ld.subactionCode ='123';
    ld.reasonCode ='123';
    
    EDISSingleRequestDTO.CustomerDetails cd = new EDISSingleRequestDTO.CustomerDetails();
    cd.customerID ='123';
    cd.customerType ='123';
    cd.familyName ='123';
    cd.givenNames ='123';
    cd.registeredCompanyName ='123';
    cd.customerTitle ='123';
    cd.customerContactGivenNames ='123';
    cd.customerContactFamilyName ='123';
    cd.contactPosition ='123';
    cd.contactFNN ='123.00';
    cd.contactEmail ='123';
    
    EDISSingleRequestDTO.EDISReqDTO reqDTO = new EDISSingleRequestDTO.EDISReqDTO();
    reqDTO.type ='123';
    reqDTO.customerDetails =cd;
    reqDTO.listingDetails =ld;
    reqDTO.serviceOrderDetails =soa;
    reqDTO.customerContactAddress =cca;
    
    dto.data = reqDTO;
        
    Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'SingleFNNListingHandler';
        itr.params__c = 'SingleFNNListingHandlerParams';
        insert itr;
        
    Test.startTest();
        Cache.Org.put('SingleFNNListingHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.setMock(HttpCalloutMock.class, new EDISMockResponseGenerator());
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c FROM Integration_Record__c WHERE handler__c = 'SingleFNNListingHandler' AND id = :insertRecord.id];
        //EDISSingleService.callEDISSingleService(existingRequests.get(0).params__c,'SingleFNNListingHandler');
        list<String> paramslist =  new list<String>();
        paramslist.add(existingRequests.get(0).params__c);
        SingleFNNListingHandler fnnhandler = new SingleFNNListingHandler();
        fnnhandler.executeWork(paramslist);
        System.assertEquals(1, existingRequests.size());
        Test.stopTest();
        
    }
}