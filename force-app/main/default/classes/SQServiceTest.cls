/**
	    * Start :  Test Class for SQServiceTest class and other related classes
 */
@isTest
public class SQServiceTest {
  	 /**
     * Method to fetch the SQ result for Site
     */
    @isTest 
    static void testSuccessCheckSQForSite() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        siteSQRequestDTO.data.adborId = '125';
        siteSQRequestDTO.data.customerAuthorityDate = '12-April-2017';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORSITE));
        SiteSQResponseDTO siteSQResponseDTO=SQService.checkSQForSite(siteSQRequestDTO);
        Test.stopTest();

        System.assert(siteSQResponseDTO != null);
        System.assert(siteSQResponseDTO.correlationId == '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
        System.assert(siteSQResponseDTO.data.serviceTypeQualifications[0].serviceType == 'Calling');
        
        System.assert(siteSQResponseDTO.data.orderableTC2Capacity!=null);
        
    }
    
    @isTest 
    static void testMandatoryParamCheckSQForSite() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        //siteSQRequestDTO.data.adborId = '1253';
        siteSQRequestDTO.data.customerAuthorityDate = '12-April-2017';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORSITE));
        SiteSQResponseDTO siteSQResponseDTO=SQService.checkSQForSite(siteSQRequestDTO);
        Test.stopTest();

        System.assert(siteSQResponseDTO == null);
    }
   
    @isTest 
    static void testURLParamsCheckSQForSite() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        //siteSQRequestDTO.data.adborId = '1258';
        siteSQRequestDTO.data.customerAuthorityDate = '12-April-2017';
        
        Test.startTest();
        SiteSQResponseDTO siteSQResponseDTO=SQService.checkSQForSite(siteSQRequestDTO);
        Test.stopTest();

        System.assert(siteSQResponseDTO == null);
    }
     
    @isTest 
    static void testError503CheckSQForSite() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        siteSQRequestDTO.data.adborId = '12349';
        siteSQRequestDTO.data.customerAuthorityDate = '12-July-2017';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceFailureResponseGenerator(MockSQServiceFailureResponseGenerator.SITESQ_RESPONSE503));
        SiteSQResponseDTO siteSQResponseDTO=SQService.checkSQForSite(siteSQRequestDTO);
        Test.stopTest();
       
        System.assert(siteSQResponseDTO.errors[0].message == 'A technical error occurred during the processing of this request by downstream system.');
    }
    
 
    /**
     * Method to fetch the SQ result for Transition
     */
    @isTest 
    static void testSuccessCheckSQForTransition() {
        TransitionSQRequestDTO transitionSQRequestDTO = new TransitionSQRequestDTO();
        transitionSQRequestDTO.data  = new TransitionSQRequestDTO.Data();
        transitionSQRequestDTO.data.addressId = '12334';
        transitionSQRequestDTO.data.FNN = '1300000012';

        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORTRANSITION));
        TransitionSQResponseDTO transitionSQResponseDTO=SQService.checkSQForTransition(transitionSQRequestDTO);
        Test.stopTest();

        System.assert(transitionSQResponseDTO != null);
        System.assert(transitionSQResponseDTO.correlationId == '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
        System.assert(transitionSQResponseDTO.data.serviceTypeQualifications[0].technologyType == 'Fibre To The Node');
    }
    
    @isTest 
    static void testMandatoryParamCheckSQForTransition() {
        TransitionSQRequestDTO transitionSQRequestDTO = new TransitionSQRequestDTO();
        transitionSQRequestDTO.data  = new TransitionSQRequestDTO.Data();
        //transitionSQRequestDTO.data.addressId = '12364';
        transitionSQRequestDTO.data.FNN = '1300000012';

        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORTRANSITION));
        TransitionSQResponseDTO transitionSQResponseDTO=SQService.checkSQForTransition(transitionSQRequestDTO);
        Test.stopTest();

        System.assert(transitionSQResponseDTO == null);
    }
    
    @isTest 
    static void testURLParamsSQForTransition() {
        TransitionSQRequestDTO transitionSQRequestDTO = new TransitionSQRequestDTO();
        transitionSQRequestDTO.data  = new TransitionSQRequestDTO.Data();
        transitionSQRequestDTO.data.addressId = '12344';
        //transitionSQRequestDTO.data.FNN = '1300000012';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORTRANSITION));
        TransitionSQResponseDTO transitionSQResponseDTO=SQService.checkSQForTransition(transitionSQRequestDTO);
        Test.stopTest();

        System.assert(transitionSQResponseDTO == null);
    }

    /**
     * Method to fetch the SQ result for Move
     */
    @isTest 
    static void testSuccessCheckSQForMove() {
        MoveSQRequestDTO moveSQRequestDTO = new MoveSQRequestDTO();
        moveSQRequestDTO.data  = new MoveSQRequestDTO.Data();
        moveSQRequestDTO.data.addressId = '12334';
        moveSQRequestDTO.data.fnns = new List<String>{'658','8745','123644'};
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORMOVE));
        MoveSQResponseDTO moveSQResponseDTO=SQService.checkSQForMove(moveSQRequestDTO);
        Test.stopTest();

        System.assert(moveSQResponseDTO!=null);
        System.assert(moveSQResponseDTO.status == 200);
        System.assert(moveSQResponseDTO.data.numberDetails[0].reason == 'ESA of New Address is within the same SZU of FNN');
        System.assert(moveSQResponseDTO.errors.errorDetails[0].code == 'FNN_NOT_FOUND');
    }    

    @isTest 
    static void testURLParamsCheckSQForMove() {
        MoveSQRequestDTO moveSQRequestDTO = new MoveSQRequestDTO();
        moveSQRequestDTO.data  = new MoveSQRequestDTO.Data();
        //moveSQRequestDTO.data.addressId = '125434';
        moveSQRequestDTO.data.fnns = new List<String>{'658','8745','123644'};
            
        Test.startTest();
        MoveSQResponseDTO moveSQResponseDTO=SQService.checkSQForMove(moveSQRequestDTO);
        Test.stopTest();

        System.assert(moveSQResponseDTO==null);
    }  

    @isTest 
    static void testSuccessCheckSQForFullServiceability() {
        System.debug('FULL SERVICE');
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'Internet';
        
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
         fullServiceabilitySQRequestDTO.data.addressId = '181028856';
		fullServiceabilitySQRequestDTO.data.fnn= '0262334031';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'Business';
     //   fullServiceabilitySQRequestDTO.data.batteryBackup = true;
      //  fullServiceabilitySQRequestDTO.data.customerConsent = 'Yes';
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
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQService.checkSQForFullServiceability(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        System.assert(fullServiceabilitySQResponseDTO != null);
        System.assertEquals(fullServiceabilitySQResponseDTO.data.serviceTypeQualifications[0].serviceType, 'Calling');
        
        System.assert(fullServiceabilitySQResponseDTO.data.scheduledDates!=null);
        System.assert(fullServiceabilitySQResponseDTO.data.orderableTC2Capacity!=null);
    }   
    
    @isTest 
    static void testMandatoryParamCheckSQForFullServiceability() {
        System.debug('FULL SERVICE');
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'xyez';
        
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        //fullServiceabilitySQRequestDTO.data.addressId = '125434';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'xyrz';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        fullServiceabilitySQRequestDTO.data.customerConsent = 'abc';
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFULLSERVICEABILITY));
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQService.checkSQForFullServiceability(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        System.assert(fullServiceabilitySQResponseDTO == null);
    }  
    
    @isTest 
    static void testFailureFullServiceabilityWithoutMandatoryParam() {
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'xyz';
        
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        fullServiceabilitySQRequestDTO.data.addressId = '123544';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'xydz';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFULLSERVICEABILITY));
        FullServiceabilitySQResponseDTO fullServiceabilitySQResponseDTO = SQService.checkSQForFullServiceability(fullServiceabilitySQRequestDTO);
        Test.stopTest();
        
        System.assert(fullServiceabilitySQResponseDTO == null);
    }    
    
    @isTest 
    static void testSuccessCheckSQForPortability() {
        PortInSQRequestDTO portInSQRequestDTO = new PortInSQRequestDTO();
        portInSQRequestDTO.Data = new PortInSQRequestDTO.Data();
        portInSQRequestDTO.Data.fnns = new List<String>{'123345','453678'};
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQNUMBERPORTABILITY));
        PortInSQResponseDTO portInSQResponseDTO = SQService.checkSQForPortability(portInSQRequestDTO);
        Test.stopTest();

        System.assert(portInSQResponseDTO != null);
        system.assertEquals(portInSQResponseDTO.data.numberDetails[2].portInType, 'Donor Return');
        System.assertEquals(portInSQResponseDTO.data.numberDetails[0].reason, 'The FNN cannot be ported into Telstra network as the given FNN status is ACTIVE');
    }  
    
    @isTest 
    static void testURLParamsCheckSQForPortability() {
        PortInSQRequestDTO portInSQRequestDTO = new PortInSQRequestDTO();
        portInSQRequestDTO.Data = new PortInSQRequestDTO.Data();
        //portInSQRequestDTO.Data.fnns = new List<String>{'123435','456278'};
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQNUMBERPORTABILITY));
        PortInSQResponseDTO portInSQResponseDTO = SQService.checkSQForPortability(portInSQRequestDTO);
        Test.stopTest();

        System.assert(portInSQResponseDTO == null);
    }  
    
    /**
     * Method to fetch results from Service Qualification Domain Manager
     */
    @isTest 
    static void fetchResultsTest() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        siteSQRequestDTO.data.adborId = '1245';
        siteSQRequestDTO.data.customerAuthorityDate = '12-April-2017';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQFORSITE));
        String siteSQResponse = SQService.fetchSQResults(siteSQRequestDTO.getEncodedURL(), SQService.SITE_SQ_EVENT);
        Test.stopTest();

        System.assert(siteSQResponse != null);
    }
    
    /*rainy day */
    
     @isTest 
    static void fetchResultsErrorTest() {
        SiteSQRequestDTO siteSQRequestDTO = new SiteSQRequestDTO();
        siteSQRequestDTO.data  = new SiteSQRequestDTO.Data();
        siteSQRequestDTO.data.adborId = '1275';
        siteSQRequestDTO.data.customerAuthorityDate = '12-April-2017';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceFailureResponseGenerator.SITESQ_RESPONSE503));
        String siteSQResponse = SQService.fetchSQResults(siteSQRequestDTO.getEncodedURL(), SQService.SITE_SQ_EVENT);
        Test.stopTest();

        System.assert(siteSQResponse != null);
    }
    
    /**
     * Creates custom setting values.
     
    static void createCustomSettingValues() {

        insert new sq_integration_configuration__c
            (SetupOwnerId = UserInfo.getOrganizationId(), 
            client_id__c = 'TEST_CLIENTID', 
            client_secret__c = 'TEST_CLIENT_SECRET',
            enable_mocks__c = false, 
            endpoint__c = 'https://cb.test.dev.telstra.com/org006/qa/v1/oauth/token', 
            grant_type__c = 'client_credentials',
            method__c = 'POST',
            scope__c = 'SITESQ');
    }*/
    
    @isTest 
    static void testSQHeader() {
    	Map<String,String> headerMap = SQService.constructHeaderMap('SQSiteCheck','');
  		System.assert(headerMap.containsKey('Authorization'),true);
		System.assert(headerMap.get('Accept')=='application/json');
		System.assert(headerMap.get('Content-Type')=='application/json');
		
		headerMap = SQService.constructHeaderMap('TransitionSQCheck','');
  		System.assert(headerMap.containsKey('Authorization'),true);
		System.assert(headerMap.get('Content-Type')=='application/json');
		System.assert(headerMap.get('Accept')=='application/json');
		
	    headerMap = SQService.constructHeaderMap('FullSQCheck','');
  		System.assert(headerMap.containsKey('Authorization'),true);
		System.assert(headerMap.get('Content-Type')=='application/json');
	
     	headerMap = SQService.constructHeaderMap('MoveSQCheck','');
  		System.assert(headerMap.containsKey('Authorization'),true);
		System.assert(headerMap.get('Content-Type')=='application/json');
	
	    headerMap = SQService.constructHeaderMap('PortInSQCheck','');
  		System.assert(headerMap.containsKey('Authorization'),true);
		System.assert(headerMap.get('Content-Type')=='application/json');
		   
    	    
    }
}