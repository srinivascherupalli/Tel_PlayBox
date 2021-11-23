@RestResource(urlMapping='/sqCheck/*')
global with sharing class SQAvailabilityCheck {	
    
	@HttpGet    
    global static void sqCheck () {
        system.debug('*****inside webservice call');
        Logger log = Logger.getLogger('SQAvailabilityCheck');
        RestRequest req = RestContext.request;
        System.debug('req::::'+req);
        String adborId ='';
        String url = req.requestURI;
        System.debug('*****URL :'+url);
       // System.debug('URL : '+ url + '<><><>adborid :'+ url.substring(url.lastIndexOf('=')));
        //System.debug('<><>request'+req);
        if(req!=null){
            Map <String, String> parameters = req.params;
            adborId= parameters.get('adborId');
        }
        System.debug('******ADBORID*******'+adborId);
        SiteSQResponseDTO siteSQResponseDTO = new SiteSQResponseDTO();
        SiteSQResponseDTO.Request request= new SiteSQResponseDTO.Request();
        SiteSQResponseDTO.Params params = new SiteSQResponseDTO.Params();
        params.adborId = adborId;
       // params.adborId = url.substring(url.lastIndexOf('=')+1);
      	//params.adborId = req.requestURI;
        request.params=params;
        siteSQResponseDTO.request=request;
            
        SiteSQResponseDTO.ServiceTypeQualifications serviceTypeQualification = new SiteSQResponseDTO.ServiceTypeQualifications();
        serviceTypeQualification.technologyType = '';
        SiteSQResponseDTO.Data data = new SiteSQResponseDTO.Data();
        List<SiteSQResponseDTO.ServiceTypeQualifications> serviceTypeQualifications = new List <SiteSQResponseDTO.ServiceTypeQualifications>();
        serviceTypeQualifications.add(serviceTypeQualification);
        data.serviceTypeQualifications=serviceTypeQualifications;
        siteSQResponseDTO.data = data;
        siteSQResponseDTO.code = '200';
        System.debug('*******siteSQResponseDTO*****'+siteSQResponseDTO);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(siteSQResponseDTO));
    }
    
   /*webservice static String sqCheck (String siteName,String siteAddress) {
        System.debug('Site Id value is : ' + siteAddress);
        System.debug('Site Id value is : ' + siteName);
        TODO 
        
        NEED TO CHANGE THE BELOW STRING ASSIGNMENT WITH A CALLOUT..

        
        Map<String, String> retMap = new Map<String, String>();
        retMap.put(SQConstants.SITE_NAME,siteName);
        retMap.put(SQConstants.SITE_ADDRESS,siteAddress);
        retMap.put(SQConstants.ACCESS_TYPE, 'NBN');
        retMap.put(SQConstants.TECH_TYPE, 'FTTN');
        retMap.put(SQConstants.MAX_DOWN_SPEED, SQConstants.SPEED_SCALE);
        retMap.put(SQConstants.MAX_UP_SPEED, SQConstants.SPEED_SCALE);

        System.debug('Map value is :   ' + retMap);
        
        String sqResults = JSON.serialize(retMap);
        return sqResults;
    }*/
    
    
    
}