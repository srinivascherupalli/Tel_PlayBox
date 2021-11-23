/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Class to initiate web callout to getsite replicator v2 : CIDN as request parameter
 * Revision :
 * 
 * *****************************************************************************/

public with sharing class ReplicatorGetSiteServiceV2 {    
    
    public static final String GETSITE_EVENT = 'ReplicatorGetSiteServiceV2';
    private ReplicatorGetSiteServiceV2(){}
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Method to invoke Getsite Replicator V2 API & Error Handling Mechanism
 * Parameter : String CIDN
 * 
 * *****************************************************************************/
    public static ReplicatorGetSiteDataObject_V2 getCustomerSites(String finCIDN) {        
        String token = AuthenticationManager.getOauthToken(GETSITE_EVENT);
      
        String correId = 'SFDC_REP_GETSITE'+IntegrationRecordHandlerUtil.getCorrelationId();
        
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json',
                                                               'cidn' => finCIDN,           
                                                               'Authorization'=> 'Bearer ' + token,
                                                               'correlationId'=> correId};        
       
        ReplicatorGetSiteDataObject_V2 getSiteDTO;     
        Long requestTime = null;
        Logger2 logger2 = Logger2.getLogger(ReplicatorGetSiteServiceV2.class.getName());
        try {
          
           	DateTime startTime = DateTime.now();
            HttpResponse res = IntegrationRecordHandlerUtil.callout(null, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorGetSiteServiceV2.class.getName(), null, correId);           
            DateTime endTime = DateTime.now();
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            System.debug('GetSiteResponseStatus: '+res.getStatusCode()  + ' GetSiteResponse: ' + res.getBody() );
           
            getSiteDTO = ReplicatorGetSiteDataObject_V2.parse(res.getBody());
            
         if(res.getStatusCode()==200){
                //logger.logMessages(finCIDN, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null); 
             logger2.logMessages(finCIDN,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);  
             logger2.exitLogger();
            }
           
          
            if (res.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;                 
                if(String.isBlank(getSiteDTO.Error_Code) && String.isBlank(getSiteDTO.Error_Description)) {                   
                    if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                    }
                    else if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;                      
                    }
                    else if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;                      
                    }
                    else {
                        internalErrorDesc = Label.Replicator_Technical_Error_Message;
                    }                    
                    getSiteDTO.Error_Code = String.valueOf(res.getStatusCode());
                    getSiteDTO.Error_Description = internalErrorDesc;                    
                }                
               logger2.logMessages(finCIDN,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);  
              logger2.exitLogger();                
            }
        } catch (Exception e) {
           
            logger2.logMessages('ReplicatorGetSiteServiceV2:getCustomerSites',e.getMessage() , '', '', '', '', false, false, null , null, null, null); 
            logger2.exitLogger();
            return null;
        }        
        System.debug('Final GetSiteDTO: ' + getSiteDTO);
        return getSiteDTO;
    }    
}