//DIGI-30045
public class FetchPayoutDetailsforChown {
    @future(callout=true)
    public static void fetchPayoutDetails(String reqStr, String correlationId){
        HttpResponse adResponse;
        String handlerName = 'FetchPayoutDetailsHandler';        
        Logger2 log = Logger2.getLogger(handlerName);
		try{ 			
            String oAuthToken = AuthenticationManager.getOauthToken(handlerName);
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + oAuthToken, 'Correlation-Id' => correlationId, 'Source-System' => 'SFDC' };
            headerMap.put('X-HTTP-Method-Override', 'PATCH');
            Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
            DateTime startTime = DateTime.now();
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqStr,IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);    
            DateTime endTime = DateTime.now();
            Long requestTime = log.getRequestTimeDifference(startTime, endTime);
            if(adResponse!=null){
                log.logMessages(reqStr, '', '', '', '', 
                                '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
            }
			String responseCode = String.valueOf(adResponse.getStatusCode());
			if (responseCode.startsWith('2')) {
				List<Orchestration_Technical__c> lstOrchTech = [SELECT Id,Field_29__c FROM Orchestration_Technical__c WHERE Field_30__c = :correlationId];
				for(Orchestration_Technical__c ot :lstOrchTech){
					ot.Field_29__c = 'Accepted';
				}
				update lstOrchTech;
			}
        }
        catch(Exception e){
			log.logMessages(reqStr, e.getMessage() + '-' + e.getStackTraceString(), '', '', '', 
                                '', '', correlationId, '','','Create','',null,'POST',false, false);
        }
		log.exitLogger();
	}
}