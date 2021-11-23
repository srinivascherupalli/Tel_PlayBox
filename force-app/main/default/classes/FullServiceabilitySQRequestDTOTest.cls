@IsTest
public class FullServiceabilitySQRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"data\": {'+
		'        \"addressId\": \"\",'+
		'        \"fnn\": \"\",'+
		'        \"priority\": \"\",'+
		'        \"nbnCustomerAuthorityDate\": \"\",'+
		'        \"lineOfBusiness\": \"\",'+
		'        \"customerConsent\": \"\",'+
		'        \"batteryBackup\": true,'+
		'        \"accessProfiles\": [{'+
		'            \"trafficClass\": \"TC4\",'+
		'            \"downloadSpeedMbps\": 25,'+
		'            \"uploadSpeedMbps\": 5'+
		'        }],'+
		'        \"serviceTypes\": [{'+
		'            \"service\": \"Internet\",'+
		'            \"internetAccessLevel\": true,'+
		'            \"sessionAdmissionControl\": \"4\",'+
		'            \"specialServiceIndicator\": \"TC2\"'+
		'        }]'+
		'    }'+
		'}';
    
        FullServiceabilitySQRequestDTO obj = FullServiceabilitySQRequestDTO.parse(json);
        System.assert(obj != null);
    }
    
     static testMethod void testcheckMandatoryParams(){
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        fullServiceabilitySQRequestDTO.data.addressId = '1234';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'xyz';
        
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'xyz';
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        boolean flag = fullServiceabilitySQRequestDTO.checkMandatoryParams();
        System.assertEquals(true, flag);
    }
    
    
    
    static testMethod void testcheckMandatoryParamsConditional(){
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        fullServiceabilitySQRequestDTO.data.addressId = '1234';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'xyz';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        //fullServiceabilitySQRequestDTO.data.customerConsent = 'abc';
        
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'xyz';
        
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        boolean flag = fullServiceabilitySQRequestDTO.checkMandatoryParams();
        System.assertEquals(false, flag);
    }
    
    static testMethod void testcheckMandatoryParamsFailure(){
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        //fullServiceabilitySQRequestDTO.data.addressId = '1234';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'xyz';
        fullServiceabilitySQRequestDTO.data.batteryBackup = true;
        //fullServiceabilitySQRequestDTO.data.customerConsent = 'abc';
        
        FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'xyz';
        
        fullServiceabilitySQRequestDTO.data.ServiceTypes = new List<FullServiceabilitySQRequestDTO.ServiceTypes>();
        fullServiceabilitySQRequestDTO.data.ServiceTypes.add(serviceTypes);
        
        boolean flag = fullServiceabilitySQRequestDTO.checkMandatoryParams();
        System.assertEquals(false, flag);
    }
    
    
    static testMethod void testcheckOptionalParamsDefault(){
    	FullServiceabilitySQRequestDTO.ServiceTypes serviceTypes = new FullServiceabilitySQRequestDTO.ServiceTypes();
        serviceTypes.service = 'Internet';
        
        FullServiceabilitySQRequestDTO fullServiceabilitySQRequestDTO = new FullServiceabilitySQRequestDTO();
        fullServiceabilitySQRequestDTO.data  = new FullServiceabilitySQRequestDTO.Data();
        fullServiceabilitySQRequestDTO.data.addressId = '181028856';
		fullServiceabilitySQRequestDTO.data.fnn= '0262334031';
		fullServiceabilitySQRequestDTO.data.nbnCustomerAuthorityDate='';
        fullServiceabilitySQRequestDTO.data.lineOfBusiness = 'Business';
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
        
        System.debug('Test Successful');
    }
}