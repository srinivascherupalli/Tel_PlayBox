/*************************************************************************************************
EDGE -104930
Name: BanAdjustmentCmpHandler
Description: Service class for Controller BanAdjustmentCmpHandler 
Author:Mahima 
***************************************************************************************************/
public class BanAdjustmentPaymentService {
    
    /**********************************
    EDGE-104930 
    Description: Method to call Adjustment API for given start and end date and billing Account Number from Controller
    Author: Mahima
    ************************************/
    public static AdjustmentsResponseDTO getCreditAdjustListService(String startDate, String endDate, String BAN)
    {
        AdjustmentsResponseDTO arDTO= new AdjustmentsResponseDTO();
        string handlerName= 'BillingAccountCreditAdjustmentHandler'; 
        HttpResponse response;
        
        String correlationId=IntegrationRecordHandlerUtil.getUUID();
        String token= AuthenticationManager.getOauthToken(handlerName);
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Authorization'=> 'Bearer ' + token,'Source-System'=>'SFDC'};
        Logger2 logger = Logger2.getLogger(handlerName +':'+correlationId);
       
        Map<String,String> pathMap = new Map<String, String>();
        pathMap.put('startDate',startDate);
        pathMap.put('endDate',endDate);
        response= OnceOffCreditBillingService.ApplyOnceOffCreditCallout(Ban,null, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName,correlationId,pathMap);

         system.debug('response=='+response);
        if(response!= null)
        {
            arDTO=  (AdjustmentsResponseDTO)JSON.deserialize(response.getBody(), AdjustmentsResponseDTO.class);
        }else
        {            
            system.debug('Server Error :read timeout');
        }        
        system.debug('arDTO=='+arDTO);
        return arDTO;        
        
    }
}