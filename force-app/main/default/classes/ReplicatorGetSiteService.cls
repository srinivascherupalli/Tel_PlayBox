/*
*   Will contain the methods 
*   - Needed to interact with the Replicator's customer site retrieving interface
*   - Needed to convert the response to build ReplicatorGetSiteDataObject instance
*/
public with sharing class ReplicatorGetSiteService {    
    /*
    *   Will retrieve the legacy site/address details and any DOT OOT NBN site/address details associated with the customer's Financial CIDN
    *   This is a synchronous call
    */
    public static final String GETSITE_EVENT = 'ReplicatorGetSiteService';
    private ReplicatorGetSiteService(){}
    
    public static ReplicatorGetSiteDataObject getCustomerSites(String finCIDN) {        
        String token = AuthenticationManager.getOauthToken(GETSITE_EVENT);
        String correId = 'SFDC_REP_GETSITE'+IntegrationRecordHandlerUtil.getCorrelationId();
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer ' + token,
                                                               'Correlation_Id'=> correId};        
        String payload = 'CIDN=' + finCIDN;
        ReplicatorGetSiteDataObject getSiteDTO;    
        Long requestTime = null;
        Logger2 logger2 = Logger2.getLogger(ReplicatorGetSiteService.class.getName());
        try {
            DateTime startTime = DateTime.now();
            HttpResponse res = IntegrationRecordHandlerUtil.callout(payload, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorGetSiteService.class.getName(), null, correId);           
            DateTime endTime = DateTime.now();
		    requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            System.debug('GetSiteResponse: ' + res.getBody());
            getSiteDTO = ReplicatorGetSiteDataObject.parse(res.getBody());
            System.debug('GetSiteDTO: ' + getSiteDTO);
            if(getSiteDTO.Site != null){
                for(ReplicatorGetSiteDataObject.SiteDTO site: getSiteDTO.Site){
                System.debug('Site Details ------------->'+site);
                    /**
                    *   @Description - If site name is start with '0' or 'null' or BLANK values then ignore value.
                    *   @Jira Story Ref - EDGE-77460
                    *   @ModifiedBy - Ramesh Somalagari,OSAKA
                    **/
                    String siteNumberStart = site.Address_No_From, siteNumberEnd = site.Address_No_To;
                    if(siteNumberStart == null || siteNumberStart == '' || siteNumberStart.equals('0') || siteNumberStart.equals('null'))
                        siteNumberStart = '';
                    if(siteNumberEnd == null || siteNumberEnd == '' || siteNumberEnd.equals('0') || siteNumberEnd.equals('null'))
                        siteNumberEnd = '';
                   
                    site.concatenatedAddress = site.Sub1_CodeSet_Abbrev+' '+site.Sub1_Descriptor_1+site.Sub1_Descriptor_2+' '
                                        +site.Sub2_CodeSet_Abbrev+' '+site.Sub2_Descriptor_1+' '+site.Sub2_Descriptor_2+' '
                                        +site.Sub3_CodeSet_Abbrev+' '+site.Sub3_Descriptor_1+' '+site.Sub3_Descriptor_2+' '
                                        +site.Sub4_CodeSet_Abbrev+' '+site.Sub4_Descriptor_1+' '+site.Sub4_Descriptor_2+' '
                                        +site.Street_Name+' '+siteNumberStart+site.Suffix_From+'-'+siteNumberEnd+' '+site.Suffix_To+' '           
                                        +site.Name+' '+site.Street_Type+' '+site.Loc_Name+' '+site.State;
                    if(site.concatenatedAddress != null){
                        site.concatenatedAddress = site.concatenatedAddress.replace('  ',' ');
                        site.concatenatedAddress = site.concatenatedAddress.replace('- ','');
                        site.concatenatedAddress = site.concatenatedAddress.trim();
                    }
                }
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
              logger2.logMessages(payload,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);  
             logger2.exitLogger();               
            }else{
             logger2.logMessages(payload,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);  
             logger2.exitLogger();  
            }
        } catch (Exception e) {

            logger2.logMessages('ReplicatorGetSiteService:getCustomerSites',e.getMessage() , '', '', '', '', false, false, null , null, null, null); 
            logger2.exitLogger();
            return null;
        }        
        System.debug('Final GetSiteDTO: ' + getSiteDTO);
        return getSiteDTO;
    }    
}