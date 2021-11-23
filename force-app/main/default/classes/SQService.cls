/**
 * Description : This class exposes service qualification related operations to SQ Manager class
 */
public with sharing class SQService  {

    public static final String SITE_SQ_EVENT = 'SQSiteCheck';
    public static final String SITE_SQ_TRANSITION_EVENT = 'TransitionSQCheck';
    public static final String SITE_SQ_MOVE_EVENT = 'MoveSQCheck';
    public static final String SITE_SQ_FULLSERVICEABILITY_EVENT = 'FullSQCheck';
    public static final String SITE_SQ_NUMBER_PORTABILITY_EVENT = 'PortInSQCheck';
	
	private SQService(){
	}
	
    /**
     * Method to fetch the SQ result for Site
     *
     * @params  SiteSQRequestDTO - DTO Class for Site SQ Request   
     * @return  SiteSQResponseDTO Class - DTO Class for SQ response
     * @return  null - if mandatory parameters are missing
     */
    public static SiteSQResponseDTO checkSQForSite(SiteSQRequestDTO request) {
        SiteSQRequestDTO siteSQRequestDTO = request;
        String urlParams = siteSQRequestDTO.getEncodedURL();
        if(urlParams == null || urlParams == ''){
            return null;
        }else{
			String httpResponseBody = fetchSQResults( urlParams, SITE_SQ_EVENT);
            System.debug('Site SQ Response :'+httpResponseBody);
            return SiteSQResponseDTO.parse(httpResponseBody);
        }
    }

    /**
     * Method to fetch the SQ result for Transition
     *
     * @params  TransitionSQRequestDTO - DTO Class for Transition SQ Request   
     * @return  TransitionSQResponseDTO Class - DTO Class for Transition SQ Response
     * @return  null - if mandatory parameters are missing
     */
    public static TransitionSQResponseDTO checkSQForTransition(TransitionSQRequestDTO request) {
       TransitionSQRequestDTO transitionSQRequestDTO = request;
        if(request.checkMandatoryParams()){
            String urlParams = transitionSQRequestDTO.getEncodedURL();
            String httpResponseBody = fetchSQResults( urlParams, SITE_SQ_TRANSITION_EVENT);
            return TransitionSQResponseDTO.parse(httpResponseBody);
        }else{
            return null;
        }
    }
    
    /**
     * Method to fetch the SQ result for Move
     *
     * @params  MoveSQRequestDTO - DTO class for Move SQ Request
     * @return  MoveSQResponseDTO - DTO Class for Move SQ Response
     * @return  null - if mandatory parameters are missing
     */
    public static MoveSQResponseDTO checkSQForMove(MoveSQRequestDTO request) {
        MoveSQRequestDTO moveSQRequestDTO = request;
        String urlParams = moveSQRequestDTO.getEncodedURL();
        if(urlParams == null || urlParams == ''){
            return null;
        }else{
			String httpResponseBody = fetchSQResults( urlParams, SITE_SQ_MOVE_EVENT);
            System.debug('Move SQ Response :'+httpResponseBody);
            return MoveSQResponseDTO.parse(httpResponseBody);
        }
    }
    
     /**
     * Method to fetch the SQ result for Full Service
     *
     * @params  FullServiceabilitySQRequestDTO - DTO Class for FullServiceability SQ Request
     * @return  FullServiceabilitySQResponseDTO Class - DTO Class for FullServiceability SQ Response
     * @return  null - if mandatory parameters are missing
     */
    public static FullServiceabilitySQResponseDTO checkSQForFullServiceability(FullServiceabilitySQRequestDTO request){
        String urlParams = System.JSON.serialize(request);
        if(request.checkMandatoryParams()){
            String httpResponseBody = fetchSQResults(urlParams, SITE_SQ_FULLSERVICEABILITY_EVENT);
            return FullServiceabilitySQResponseDTO.parse(httpResponseBody);
        }else{
            return null;
        }
    }
    
    /**
     * Method to fetch the SQ result for Full Service
     *
     * @params  PortInSQRequestDTO - DTO Class for FullServiceability SQ Request
     * @return  PortInSQResponseDTO Class - DTO Class for Number Portability SQ Response
     * @return  null - if mandatory parameters are missing
     */
    public static PortInSQResponseDTO checkSQForPortability(PortInSQRequestDTO request){
        String urlParams = request.getEncodedURL();
        if(urlParams == null || urlParams == ''){
            return null;
        }else{
			String httpResponseBody = fetchSQResults(urlParams, SITE_SQ_NUMBER_PORTABILITY_EVENT);
            System.debug('httpResponseBody here:'+httpResponseBody);
            return PortInSQResponseDTO.parse(httpResponseBody);
        }
    }


   
    /**
     * Method to fetches results from Service Qualification Domain Manager
     *
     * @param      reqBody - SQ request msg body
     * @param      event   - Type of SQ event
     * @return     HTTP response body
     */
     public static String fetchSQResults(String reqBody, String event) {

        String responseBody;
        String urlParams;
        String httpMethodType;
        try {
            //urlParams = getURLParams(reqBody,event);
            urlParams = reqBody;
            System.debug('URL params:'+urlParams);
            httpMethodType = getHTTPMethodType(event);
            String token = AuthenticationManager.getOauthToken(event);
          	Map<String,String> headerMap = constructHeaderMap(event,token);          
            HttpResponse sqResponse = IntegrationRecordHandlerUtil.calloutSync(urlParams, httpMethodType, headerMap, event);
            responseBody = sqResponse.getBody();
            if (sqResponse.getStatusCode() != 200) {
                Logger.getLogger(SQService.class).debug('Callout not success ' + sqResponse.getStatusCode());
                Logger.exitLogger();
            }
        } catch (Exception e) {

            Logger.getLogger(SQService.class).debug(e);
            Logger.exitLogger();
        }
        return responseBody;
    }

    /**
     * Method to fetches HTTP Method Type as pe SQ Type
     *
     * @param      event
     * @return     HTTP Method Type (GET || POST)
     */
    private static String getHTTPMethodType(String event){
        if(event == SITE_SQ_FULLSERVICEABILITY_EVENT){
            return 'POST';
        }else{
            return 'GET';
        }
    }
    
    public static Map<String,String> constructHeaderMap(String event,String token)
    {
         	 Map<String,String> headerMap = new Map<String, String>{'Authorization'=> 'Bearer ' + token};
            if(event==SITE_SQ_EVENT || event==SITE_SQ_TRANSITION_EVENT)
            {
                headerMap.put('Accept','application/json');
                headerMap.put('Content-Type','application/json');
            }
            else
            	 headerMap.put('Content-Type','application/json');	
            
            return headerMap;
    }
    
}