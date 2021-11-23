/*Story number: EDGE-865
Description: GetServSpecHandler handles the request validation and error handling for GetProductAPI.
===============================================================================================================================
Change.No. Developer Name        	Date   		Story        Description
1.		   Pawan Singh				12/05/2021      EDGE-214615 added Error logging framework
**********************************************************
*/
global with sharing class GetServSpecHandler {

    
    private static final String CONST_INTERFACENAME = 'GetServSpecHandler';
    
    global static String validateRequest(String correlationID){
        
        
            if(correlationID!= null){
                String specList = ''; 
                List <csord__Service__c> serviceList;
                try{
                    String servNum= correlationID.substringBefore(':');
               		String guid= correlationID.substringAfter(':');
                
                	system.debug(servNum + ' ' +'guid=====>' + guid);
               		// List<csord__order__c> ord = [select id from csord__order__c where csord__Order_Number__c=:OrdNum and csord__Primary_Order__c = null]; 
                
               
                 	serviceList = [select id,name,csord__Subscription__c,csordtelcoa__Service_Number__c from csord__service__c where csordtelcoa__Service_Number__c=:servNum];
                	system.debug('serviceList====>'+serviceList);
                	ServiceSpecDetailsResponseDTO.Attributes attr;
                
                	for(csord__Service__c serv : serviceList)
                	{ 
                    	List<CS_SpecificationDTO.ServiceSpecification> srvAssuranceSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'ASSURANCE');
                    	List<CS_SpecificationDTO.ServiceSpecification> srvTechnicalSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'SOMOpenAir'); //EDGE-116372                    
                    	List<CS_SpecificationDTO.ServiceSpecification> srvspecList= CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
                    	if(srvAssuranceSpecList!=null && srvAssuranceSpecList.size()>0 && srvspecList!= null){
                        	srvspecList.addAll(srvAssuranceSpecList);    
                    	}
                    	if(srvTechnicalSpecList !=null && !srvTechnicalSpecList.isEmpty() && srvSpecList!= null){
                        	srvSpecList.addAll(srvTechnicalSpecList);    
                    	}                    
                    
                    	for (CS_SpecificationDTO.ServiceSpecification specs: srvspecList){
                        
                        	if(specs.guid.equals(guid))
                        	{
                            	specList = specs.guid;
                        	}
                    	}
               		 }
            	}
            	catch(Exception e){
            		logException('validateRequest', '', '', e.getMessage(), 'Exception occured while validating requests from GetProductAPI');//EDGE-214615
        		}
                
            	if(!serviceList.isEmpty() && String.isNotBlank(specList)){
                	 return 'Valid';
            	}else{
                    return 'Invalid';
            	}
            }else{
                return 'Invalid';
           	}
    }
    
    global static RestResponse generateResponse(RestResponse res,String correlationID){
        
        ServiceSpecDetailsResponseDTO dto;
        List<ServiceSpecDetailsResponseDTO.error> error = new List<ServiceSpecDetailsResponseDTO.error>();
        ServiceSpecDetailsResponseDTO.error err = new ServiceSpecDetailsResponseDTO.error();
        ServiceSpecDetailsResponseDTO.DataDTO datadto = new ServiceSpecDetailsResponseDTO.DataDTO();
        
        try{
            
            if(validateRequest(correlationID) == 'Valid'){
                 dto = GetServSpecHelper.ServiceSpecDetails(correlationID);
                 String responseBody = (JSON.serialize(dto,true)).replace('_Fulfilment','').replace('_Assurance','').replace('_New Value','');
                 String resBody = responseBody.replace('FULFILMENT','ASSURANCE');
                  resBody = responseBody.replace('SOMOpenAir','ASSURANCE'); //EDGE-116372
                  res.statusCode = 200;
                  res.responseBody = Blob.valueOf(resBody);
                  res.addHeader('Content-Type','application/json');
            }else{
                res.statusCode = 400;
                dto = GetServSpecHelper.BadRequestdto(correlationID);
                res.responseBody = Blob.valueOf(JSON.serialize(dto,true));
                res.addHeader('Content-Type','application/json');
                
            }
            
        }catch(Exception e){
            logException('generateResponse', '', '', e.getMessage(), 'Exception occured while generating  Rest Response'); //EDGE-214615
           	if(Test.isRunningTest()){
                  res = new RestResponse();
            }
            res.statusCode = 502;
            dto = GetServSpecHelper.InternalErrordto(correlationID);
            res.responseBody = Blob.valueOf(JSON.serialize(dto,true));
            res.addHeader('Content-Type','application/json');
         }
        return res;
    }

    /*===============Error Logging Framework=============== */
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME); 
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber); 
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage); 
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}