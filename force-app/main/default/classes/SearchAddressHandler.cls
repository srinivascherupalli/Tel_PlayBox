/*
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : This class deals with batch insertion of site upload records into Orchestration Technical
@ DIGI-28081
@ Test class : SearchAddressBatchTest
*/
/*
@ Modified : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : Added null check
@ DIGI-13813
@ DIGI-28079 : added final variables
@ Test class : SearchAddressBatchTest
*/


public class SearchAddressHandler {

    public static final string status_AddressNotAvailable='Address is not available';
    List<Orchestration_Technical__c> siteDataList=new List<Orchestration_Technical__c>();  
    List<Orchestration_Technical__c> addressNotFoundList=new List<Orchestration_Technical__c>();
    List<Orchestration_Technical__c> fullAddressList=new List<Orchestration_Technical__c>();
    static List<ApplicationLog__c> logList=new List<ApplicationLog__c>();

    //Method will process the batch records and make Adborid API Call and update the records with response
    public void searchAddressByAdborId(List<Orchestration_Technical__c> adborIdList){
        AddressResponseDTO adResponse ;
        try{
            for(Orchestration_Technical__c orchestrationTechObj:adborIdList){
                if(String.isNotBlank(orchestrationTechObj.Field_4__c)){
                    adResponse=searchAddress(orchestrationTechObj.Field_4__c,'AdborIdAddressHandler');                    
                    List<AddressSummary> addressListByAdborid=AddressSearch.returnNBNAddresses(adResponse,true,'AdborIdAddressHandler');
                    if(addressListByAdborid!=null && !addressListByAdborid.isEmpty()){
                        for(AddressSummary add:addressListByAdborid){
                            if(add.responseStatus==200 && String.isBlank(add.addNotFound)){
                                orchestrationTechObj.BackupJson__c=JSON.serialize(addressListByAdborid);
                                orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_FOUND;
                                orchestrationTechObj.Field_6__c = 'AdborId';
                                orchestrationTechObj.Field_5__c = add.addressLine;
                                siteDataList.add(orchestrationTechObj);
                            }
                            else if(add.addNotFound.equalsIgnoreCase(status_AddressNotAvailable)){
                                addressNotFoundList.add(orchestrationTechObj);                                
                            }
                            else{
                                orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_FAILED;
                                siteDataList.add(orchestrationTechObj);
                            }                            
                        }
                    }                    
                }
                else{
                    addressNotFoundList.add(orchestrationTechObj);                    
                }                
            }
            if(!addressNotFoundList.isEmpty() && addressNotFoundList!=null){
                unStructuredAddress(addressNotFoundList);
            }
            if(!fullAddressList.isEmpty() && fullAddressList!=null){
                siteDataList.addAll(fullAddressList);
            }
            if(!logList.isEmpty() && logList!=null){
                insert logList;
            }            
            Coms_BulkSiteUploadUtils.updateOrchestrationTechnicals(siteDataList);            
        }
        catch(Exception ex){
            siteDataList.clear();
            for(Orchestration_Technical__c records:adborIdList){
                records.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_FAILED;
				siteDataList.add(records);                
            }
            Coms_BulkSiteUploadUtils.updateOrchestrationTechnicals(siteDataList);
            GenericUtilityClass.logException('SearchAddressHandler','searchAddressByAdborId','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during the batch',C2O_ExceptionHandler.Capability.ORD);
        }
    }
    //Method will process the batch records and make Full Address API Call and update the records with response
    public List<Orchestration_Technical__c> unStructuredAddress(List<Orchestration_Technical__c> fullAddress){	     
        for(Orchestration_Technical__c orchestrationTechObj:fullAddress){
            AddressResponseDTO fullAddressResp = searchAddress(orchestrationTechObj.Field_2__c,'UnStructuredAutocompleteHandler');
                if(fullAddressResp!=null && fullAddressResp.results!=null && !fullAddressResp.results.isEmpty() && fullAddressResp.correlationId!=null && String.isBlank(fullAddressResp.results[0].Name)){
                    orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_NOT_FOUND;
                }
                else if(fullAddressResp!=null && fullAddressResp.correlationId!=null && fullAddressResp.results!=null && !fullAddressResp.results.isEmpty()){
                    orchestrationTechObj.BackupJson__c=JSON.serialize(fullAddressResp);
                    orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_FOUND;
                    orchestrationTechObj.Field_6__c = 'Address';
                    if(fullAddressResp.results.size()==1){
                        orchestrationTechObj.Field_5__c =fullAddressResp.results[0].Name;
                    }
                }
                else
                {
                    orchestrationTechObj.Field_3__c=Coms_BulkSiteUploadUtils.STATUS_FAILED;
                }
                fullAddressList.add(orchestrationTechObj);
            }
        return fullAddressList;                       
    }

    //This method makes API call for Adborid and full Address search and returns the response
    public static AddressResponseDTO searchAddress(String searchStr,String handler){
        String correlationid = EDISSingleManager.getUID();
        ApplicationLog__c logresponse=new ApplicationLog__c();
        Logger2 logger = Logger2.getLogger(handler);        
        AddressResponseDTO res = new AddressResponseDTO();
        String urlEncodedParam;
        HttpResponse response;
        try{
            if(handler.equalsIgnoreCase('AdborIdAddressHandler')){
                urlEncodedParam = AddressSearch.getEncodedURLParam(searchStr);
            }
            else if(handler.equalsIgnoreCase('UnStructuredAutocompleteHandler')){
                urlEncodedParam = AddressSearch.getEncodedURLUnstruct(searchStr);
            }
            if(urlEncodedParam == null ){
                return null;
            }
            else{           
                    
                String token= AuthenticationManager.getOauthToken(handler);
                if(handler.equalsIgnoreCase('AdborIdAddressHandler')){            
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','accept'=>'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                    response =AddressSearch.calloutAdborUnstruct(urlEncodedParam,IntegrationRecordHandlerUtil.HTTP_METHOD_GET,headerMap,handler,null,null);
                    if(response!=null && response.getStatusCode()!=null){
                        String responseCode = String.valueOf(response.getStatusCode());
                       
                        if (responseCode.startsWith('2')) {
                            res=AddressResponseDTO.parse(response.getBody());
                            logresponse=logger.logMessage(urlEncodedParam, response.getBody(), false,responseCode, correlationid,handler);
                            logList.add(logresponse);
                            
                        }
                        else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                            res=AddressResponseDTO.parse(response.getBody());
                            logresponse=logger.logMessage(urlEncodedParam, response.getBody(), false,responseCode, correlationid,handler);
                            logList.add(logresponse);
                        }
                    }
                }
                else if(handler.equalsIgnoreCase('UnStructuredAutocompleteHandler')){
                    Map<String,String> headerMap = new Map<String, String>{'Authorization'=> 'Bearer ' + token};                
                    response = AddressSearch.calloutAdborUnstruct(urlEncodedParam,IntegrationRecordHandlerUtil.HTTP_METHOD_GET,headerMap,handler,null,null);
                    if(response!=null && response.getStatusCode()!=null){
                        String responseCode = String.valueOf(response.getStatusCode());  
                        
                        if (responseCode.startsWith('2')) {
                            res=AddressResponseDTO.parse_unstruct(response.getBody());
                            logresponse=logger.logMessage(urlEncodedParam, response.getBody(), false,responseCode, correlationid,handler);
                            logList.add(logresponse);//DIGI-13813 Added logs to loglist 
                        }
                        else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                            //DIGI-13813 commented the parse
                            //res=AddressResponseDTO.parse_unstruct(response.getBody());
                            logresponse=logger.logMessage(urlEncodedParam, response.getBody(), false,responseCode, correlationid,handler);
                            logList.add(logresponse);//DIGI-13813 Added logs to loglist 
                        }
                    }
                }             
                return res;
            }            
        }
        catch (Exception ex) {
            throw ex;
        }     
    }
}