/*----------------------------------------------------------------------------
EDGE        -88306
Class Name  -BillingAccountPaymentsService
Description -service Class for Billing account payments API callout.
Author      -Dheeraj Bhatt
Modified By - Kamlesh Kumar EDGE : 212792, service Class for transaction details
-------------------------------------------------------------------------------*/
public without sharing class BillingAccountPaymentsService {
    

    /*-----------------------------------------------------------------------------
EDGE        -88306
Method Name -paymentServiceRequest
Description -Creating the request for API callout to fetch the payments related to Billing Account Number. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    Public static HTTPResponse paymentServiceRequest(String handler, String ban,Date fromDate,Date toDate){
        HttpResponse response;
        Try{
            String urlOnceoff = OnceOffCreditBillingService.getEncodedURLOnceoff(handler);
            if(urlOnceoff == ''){
                return null;
            }else{ 
                String token= AuthenticationManager.getOauthToken(handler);
                String correlationId=IntegrationRecordHandlerUtil.getUUID();
                Map<String,String> pathMap = new Map<String, String>();
                pathMap.put('startDate',string.valueOf(fromDate));
                pathMap.put('endDate',string.valueOf(toDate));
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Source-System' => 'TConnect','accept' => 'application/json','Authorization' => 'Bearer '+token};
                response = OnceOffCreditBillingService.ApplyOnceOffCreditCallout(ban,null, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handler,correlationId,pathMap);
                system.debug('response=='+response);                
            }
        }
        Catch (Exception ex){
            system.debug('Exception Occured in BillingAccountPaymentsService class at Line Number '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
        return  response;
    }
    
    /*-----------------------------------------------------------------------------
    EDGE        -212792
    Method Name -transactionalPaymentServiceRequest
    Description -Creating the request for API callout to fetch the transaction details related to Billing Account Number. 
    Author      -Kamlesh Kumar
    Creadted Date - 11/05/2021
    -------------------------------------------------------------------------------*/
    Public static HTTPResponse transactionalPaymentServiceRequest(String handler, String ban,String transactionId){
        HttpResponse response;
        String urlOnceoff = OnceOffCreditBillingService.getEncodedURLOnceoff(handler);
        if(urlOnceoff == '') {
            return null;
        }
        else { 
            String token= AuthenticationManager.getOauthToken(handler);
            String correlationId=IntegrationRecordHandlerUtil.getUUID();
            Map<String,String> pathMap = new Map<String, String>();
            pathMap.put('transactionId',transactionId);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Source-System' => 'TConnect','accept' => 'application/json','Authorization' => 'Bearer '+token};
            response = OnceOffCreditBillingService.ApplyOnceOffCreditCallout(ban,null, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handler,correlationId,pathMap);
                               
        }
        return  response;
    }
    
}