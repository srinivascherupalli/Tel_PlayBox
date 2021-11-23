/*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -LineItemAdjustmentsService
Description -Service class for api callout for Sending Line Item Adjustments 
             request to BDS and receive response from BDS
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/  
public Without sharing class LineItemAdjustmentsService {
/*----------------------------------------------------------------------------
EDGE        -88294
Method Name -LineItemAdjustmentsRequest
Description -API Callout to BDS. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    public static HttpResponse lineItemAdjustmentsRequest(String reqParam, String handler, String ban){
        HttpResponse response;
        Try{
            String urlOnceoff = OnceOffCreditBillingService.getEncodedURLOnceoff(handler);
            if(urlOnceoff == null){
                return null;
            }
            else{ 
                String token= AuthenticationManager.getOauthToken(handler);
                
                String correlationId=IntegrationRecordHandlerUtil.getUUID();
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Authorization'=> 'Bearer ' + token,'Source-System'=>'SFDC'};
                    response = OnceOffCreditBillingService.ApplyOnceOffCreditCallout(ban,reqParam, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handler,correlationId,null);            //system.debug('CreditResponse::' + response.getBody());
            }
        }
        Catch(Exception ex){
          Logger2 log = Logger2.getLogger('lineItemAdjustmentsRequest');
          log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return response;
    }
}