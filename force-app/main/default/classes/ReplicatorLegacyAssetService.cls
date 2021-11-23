/*
*   Will contain the methods 
*   - Needed to interact with the Replicator's Get Service interface
*   - Needed to convert the response from Replicator into useful form
*/
public with sharing class ReplicatorLegacyAssetService {
    public static final String GETSERVICE_EVENT = 'ReplicatorLegacyAssetService';
    private ReplicatorLegacyAssetService(){}
	/*
    *   Will retrieve all legacy copper services and NBN services associated with the customer's Financial CIDN and AdBoR Id
    *   This is a synchronous call
    */
    public static ReplicatorGetServiceDataObject getCustomerServices(String finCIDN, List<String> adborId) {
        ReplicatorGetServiceDataObject getServiceDTO;
        
        String token = AuthenticationManager.getOauthToken(GETSERVICE_EVENT);
        String correId = 'SFDC_REP_GETSERVICE'+IntegrationRecordHandlerUtil.getCorrelationId();
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> correId};  
        Long requestTime= null;       
            //String payload = 'cidn=' + finCIDN + '&adboreid=' + adborId;
			//Edge-339 START
        String payload = 'cidn=' + finCIDN + '&adboreid=';
            for (String item : adborId){
             payload=payload + item +',';
             }
        payload=payload.substring(0, payload.length()-1);
        System.debug('Payload: ' + payload);
		//Tech debt clf logger
		Logger2 logger2 = Logger2.getLogger(ReplicatorGetSiteService.class);
        //Edge-339 STOP
        	try {       
            DateTime startTime = DateTime.now(); 
            HttpResponse res = IntegrationRecordHandlerUtil.callout(payload, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorLegacyAssetService.class.getName(), null, correId);
            DateTime endTime = DateTime.now();
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
                
            System.debug('GetServiceResponse: ' + res.getBody());
            getServiceDTO = ReplicatorGetServiceDataObject.parse(res.getBody());
            System.debug('GetServiceDTO: ' + getServiceDTO);
            
            if (res.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;
                system.debug('Checking Length -->'+getServiceDTO.Site);
			  for (ReplicatorGetServiceDataObject.SiteDTO sitedata : getServiceDTO.Site ){
                if(String.isBlank(sitedata.Error_Code) && String.isBlank(sitedata.Error_Description)) {
                    
                    if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                        sitedata.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                    }
                    else if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                        sitedata.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;                      
                    }
                    else if(res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                        sitedata.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;                      
                    }
                    else {
                        internalErrorDesc = Label.Replicator_Technical_Error_Message;
                    }
                    
                    sitedata.Error_Code = String.valueOf(res.getStatusCode());
                    sitedata.Error_Description = internalErrorDesc;                    
                }
				
				logger2.logMessages(payload,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);
                
			  }
            }
            else {
				logger2.logMessages(payload,res.getBody(),'','','','',String.ValueOf(res.getStatusCode()),correId,'','','','',requestTime,'',false,false);
                //ReplicatorLegacyAssetService.processGetServiceDTO(getServiceDTO);
            }
        } catch (Exception e) {
			System.debug('Exception: ' + e);
			logger2.logMessages('ReplicatorLegacyAssetService:getCustomerServices',e.getMessage() , '', '', '', '', false, false, null , null, null, null); 
            return null;
        }finally{
			logger2.exitLogger();
		}
        
        System.debug('Final GetServiceDTO: ' + getServiceDTO);
        return getServiceDTO;    
    }
    
    // Additional manipulation that need to happen on the getSiteDTO will be performed within this method
    /*private static void processGetServiceDTO(ReplicatorGetServiceDataObject getServiceDTO) {
        //If there is a serviceExtension tag need to create relavent Services
		for (ReplicatorGetServiceDataObject.SiteDTO siteData : getServiceDTO.Site){
        List<ReplicatorGetServiceDataObject.ProductDTO> prodList = new List<ReplicatorGetServiceDataObject.ProductDTO>(siteData.productList);
        System.debug('ProdList: ' + prodList);
        
        for(ReplicatorGetServiceDataObject.ProductDTO prod : prodList) {
            List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new List<ReplicatorGetServiceDataObject.ServiceDTO>(prod.service);
            List<ReplicatorGetServiceDataObject.ServiceDTO> serviceExtList = new List<ReplicatorGetServiceDataObject.ServiceDTO>();
            System.debug('ServiceList: ' + serviceList);
            for(ReplicatorGetServiceDataObject.ServiceDTO srv : serviceList) {
                String srvID = srv.Service_Id;
                if(String.isBlank(srvID)) {
                    continue;
                }
                
                List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO> srvRelationshipList = new List<ReplicatorGetServiceDataObject.ServiceRelationshipDTO>(srv.serviceRelationship);
                System.debug('SrvRelationshipList: ' + srvRelationshipList);
                for(ReplicatorGetServiceDataObject.ServiceRelationshipDTO srvRelationship : srvRelationshipList) {
                    List<ReplicatorGetServiceDataObject.ServiceExtensionDTO> srvExtList = new List<ReplicatorGetServiceDataObject.ServiceExtensionDTO>(srvRelationship.serviceExtension); 
                    System.debug('SrvExtList: ' + srvExtList);
                    
                    if(!srvExtList.isEmpty()) {
                        Set<Integer> exts = new Set<Integer>();
                        for(ReplicatorGetServiceDataObject.ServiceExtensionDTO srvExt : srvExtList) {
                            System.debug('Show srvExt'+srvExt.Services_From.trim());
                            if(srvExt.Services_From!=null && srvExt.Services_From!=''){
                            System.debug('Show inside if srvExt'+srvExt.Services_From.trim());
                            Integer srvFrom = Integer.valueof(srvExt.Services_From.trim());
                            exts.add(srvFrom);
                            
                            if(String.isNotBlank(srvExt.Services_To)) {
                                Integer srvTo = Integer.valueof(srvExt.Services_To.trim());
                                
                                for(Integer i = srvFrom; i <= srvTo; i++) {
                                    exts.add(i);
                                }
                            }
                            
                            System.debug('ExtList: ' + exts);
                            for(Integer ext : exts) {
                                String extSrvID = srvID.substring(0,srvID.length()-4) + ext;
                                System.debug('ExtSrvID: ' + extSrvID); 
                                ReplicatorGetServiceDataObject.ServiceDTO srvExtDTO = ReplicatorGetServiceDataObject.cloneService(srv);
                                srvExtDTO.Service_Id = extSrvID;
                                srvExtDTO.serviceRelationship = null;
                                serviceExtList.add(srvExtDTO);
                            }
                        }
                        }
                    }
                }       
            }
            if(!serviceExtList.isEmpty()) {
                System.debug('ServiceExtList: ' + serviceExtList);
                prod.service.addAll(serviceExtList);
            }
        }
		}
	}*/
}