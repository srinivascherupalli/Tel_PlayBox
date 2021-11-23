//DIGI-25050
public with sharing class FetchPayoutDetailsSync {
    public static map<string,string> fetchPayoutDetails(String baNum, String subNum){
        map<string,string> resMap = new map<string,string>();
        if(String.isNotBlank(baNum) && String.isNotBlank(subNum)){
            HttpResponse adResponse;
            String handlerName = 'FetchPayoutDetailsHandlerSync';        
            Logger2 log = Logger2.getLogger(handlerName);
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            string reqStr = 'billingaccount/'+baNum+'/subscriptionid/'+subNum;            
            try{            
                String oAuthToken = AuthenticationManager.getOauthToken(handlerName);
                Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + oAuthToken, 'Correlation-Id' => correlationId, 'Source-System' => 'SFDC' };
				//Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
                //headerMap.put('Source-System', handleSettingRecord.Scope__c);
                DateTime startTime = DateTime.now();
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqStr,IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName);    
                DateTime endTime = DateTime.now();
                Long requestTime = log.getRequestTimeDifference(startTime, endTime);
                if(adResponse!=null){
                    log.logMessages(reqStr, adResponse.getBody(), '', '', '', 
                                    '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'GET',false, false);
                }
                String responseCode = String.valueOf(adResponse.getStatusCode());
                if (responseCode.startsWith('2')) {
					resMap.put('result','success');
                    FetchPayoutDetailsSyncRespDto resDto = (FetchPayoutDetailsSyncRespDto) System.JSON.deserialize(adResponse.getBody(), FetchPayoutDetailsSyncRespDto.class);
                    //system.debug('resDto::::'+resDto);
                    resMap.put('subscriptionId',resDto.subscriptionId);
                    resMap.put('durationUnit',resDto.chargesDetails[0].durationUnit);
                    resMap.put('durationRemaining',string.valueOf(resDto.chargesDetails[0].durationRemaining));
                    resMap.put('chargeRemaining',string.valueOf(resDto.chargesDetails[0].chargeRemaining));
                    resMap.put('units',string.valueOf(resDto.chargesDetails[0].units));
                }
                else{
                    resMap.put('result','fail');
                }
            }
            catch(Exception e){
                resMap.put('result','fail');
                log.logMessages(reqStr, e.getMessage() + '-' + e.getStackTraceString(), '', '', '', 
                                    '', '', correlationId, '','','Create','',null,'GET',false, false);
            }
            log.exitLogger();            
    	}
        return resMap;
    }
}