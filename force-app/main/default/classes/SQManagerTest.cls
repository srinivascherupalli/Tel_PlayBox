@isTest
private class SQManagerTest {
    @isTest 
    static void testSuccess_checkFetchSiteSQResult() {
        SiteSQRequestDTO reqObj = new SiteSQRequestDTO();
        reqObj.data  = new SiteSQRequestDTO.Data();
        reqObj.data.adborId = '1423';
        reqObj.data.customerAuthorityDate = '12-July-2017';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORSITE));
        SiteSQResponseDTO sQResponseDTO=SQManager.fetchSiteSQResult(reqObj);
        Test.stopTest();
        
        System.assert(sQResponseDTO!=null);
         System.assert(sQResponseDTO.data.orderableTC2Capacity!=null);
    }
    
    @isTest 
    static void testError503_checkFetchSiteSQResult() {
        SiteSQRequestDTO reqObj = new SiteSQRequestDTO();
        reqObj.data  = new SiteSQRequestDTO.Data();
        reqObj.data.adborId = '12374';
        reqObj.data.customerAuthorityDate = '12-July-2017';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceFailureResponseGenerator(MockSQServiceFailureResponseGenerator.SITESQ_RESPONSE503));
        SiteSQResponseDTO siteSQResponseDTO=SQManager.fetchSiteSQResult(reqObj);
        Test.stopTest();
        
        System.assert(siteSQResponseDTO.errors[0].message == 'A technical error occurred during the processing of this request by downstream system.');
    }
    
    @isTest 
    static void checkFetchTransitionSQResult() {
        TransitionSQRequestDTO reqObj = new TransitionSQRequestDTO();
        reqObj.data  = new TransitionSQRequestDTO.Data();
        reqObj.data.addressId = '12234';
        reqObj.data.FNN = '1300000012';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator('testSuccess_checkSQForTransition'));
        TransitionSQResponseDTO sQResponseDTO=SQManager.fetchTransitionSQResult(reqObj);
        Test.stopTest();
        System.assert(sQResponseDTO!=null);
    }
    
    @isTest 
    static void checkFetchMoveSQResult() {
        MoveSQRequestDTO reqObj = new MoveSQRequestDTO();
        reqObj.data  = new MoveSQRequestDTO.Data();
        reqObj.data.addressId = '1243334';
        reqObj.data.fnns = new List<String>{'658','8745','123644'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator('testSuccess_checkSQForMove'));
        MoveSQResponseDTO sQResponseDTO=SQManager.fetchMoveSQResult(reqObj);
        Test.stopTest();
        System.assert(sQResponseDTO!=null);
    }
    
   @isTest 
    static void testSuccessCheckSQForFullServiceability() {
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'Internet';
        
        
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
          fullServiceabilitySQRequestDTO.data.addressId = '181028856';
		fullServiceabilitySQRequestDTO.data.fnn= '0262334031';
         fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'Business';
        //fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        //fullServiceabilitySQRequestDTO.data.customerConsent = 'Yes';
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        System.assertEquals('Standard', fullServiceabilitySQRequestDTO.data.priority);
        System.assertEquals(false, fullServiceabilitySQRequestDTO.data.batteryBackup);
        System.assertEquals('No',fullServiceabilitySQRequestDTO.data.customerConsent );
        
        for(FullServiceabilitySQRequestDTO.ServiceTypes s:FullServiceabilitySQRequestDTO.data.ServiceTypes)
        {
        	System.assertEquals(false, s.internetAccessLevel);
        	System.assertEquals('0', s.sessionAdmissionControl);
        }
         System.debug('Default is set is request for opt params');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFULLSERVICEABILITY));
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQManager.fetchFullServicibilitySQResult(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        System.assert(fullServiceabilitySQResponseDTO != null);
        System.assertEquals(fullServiceabilitySQResponseDTO.data.serviceTypeQualifications[0].serviceType, 'Calling');
        
        System.assert(fullServiceabilitySQResponseDTO.data.scheduledDates!=null);
        System.assert(fullServiceabilitySQResponseDTO.data.orderableTC2Capacity!=null);
    }    
    
    
    @isTest 
    static void testSuccessCheckSQForPortability() {
        PortInSQRequestDTO portInSQRequestDTO = new PortInSQRequestDTO();
        portInSQRequestDTO.Data = new PortInSQRequestDTO.Data();
        portInSQRequestDTO.Data.fnns = new List<String>{'1234345','45678'};
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQNUMBERPORTABILITY));
        PortInSQResponseDTO portInSQResponseDTO = SQManager.checkSQForPortability(portInSQRequestDTO);
        Test.stopTest();

        System.assert(portInSQResponseDTO != null);
        System.assertEquals(portInSQResponseDTO.data.numberDetails[0].reason, 'The FNN cannot be ported into Telstra network as the given FNN status is ACTIVE');
    }  
}