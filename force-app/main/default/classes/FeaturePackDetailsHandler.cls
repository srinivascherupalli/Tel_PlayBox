/**************************************************************************
EDGE        -215749
Description -Controller to fecth feature charges for billing enquiry
Author      -Akanksha Jain
Team        -Munich
*********************************************************************************/
public class FeaturePackDetailsHandler {
    @AuraEnabled
       public static String getFeaturePackDetails(Long chargeId,String statementNumber,String accountNumber, String handlerName)
       {
           FeaturePackResponseDTO res = new FeaturePackResponseDTO();         
           InvoiceChargeTypeRequestDTO requestDTO = new InvoiceChargeTypeRequestDTO();
           requestDTO.accountNumber = accountNumber;
           requestDTO.chargeId = chargeId;
           requestDTO.statementNumber = statementNumber;
           String request = JSON.serialize(requestDTO,true);
           String responseStr;
           HttpResponse featurePackRes;
             try{ 
                String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
                String token = ''; 
                Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
                if(handleSettingRecord!=null) {
                    if(handleSettingRecord.Enable_Mock_Integration__c) {
                        token=System.Label.QLI_Token; 
                    }
                    else {
                        token = AuthenticationManager.getOauthToken(handlerName);
                    }
                }
                Map < String, String > headerMap = new Map < String, String > {
                    'Content-Type' => 'application/json',
                        'Authorization' => 'Bearer ' + token,
                        'correlationId' => correlationId,
                        'caller-app' =>'Salesforce' // check from BDS
                        };
                
                featurePackRes=IntegrationRecordHandlerUtil.calloutSync(request, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
                if(featurePackRes!= null){
                /*Logger2 log = Logger2.getLogger(handlerName);
                DateTime startTime = DateTime.now();
                DateTime endTime = DateTime.now();
                Long requestTime = log.getRequestTimeDifference(startTime, endTime);
                log.logMessages(request, featurePackRes.getBody(), '', '', '', 
                                       '', String.valueOf(featurePackRes.getStatusCode()), correlationId, '','','Create','',requestTime,'POST',false, false);
                       
                logger.exitLogger();*/
                
                  List<FeaturePackResponseDTO.featurePackDetails> resList = new  List<FeaturePackResponseDTO.featurePackDetails>();
                    List<FeaturePackResponseDTO.featurePackDetails> finalList = new  List<FeaturePackResponseDTO.featurePackDetails>();
                  String responseCode = String.valueOf(featurePackRes.getStatusCode());
                   if(responseCode.startsWith('2')) 
                   {
                       if(featurePackRes.getBody()!= null){
                           res = FeaturePackResponseDTO.parse(featurePackRes.getBody());
                           system.debug('res:'+res);
                           resList = res.featurePackDetails;
                           for(FeaturePackResponseDTO.featurePackDetails fpDetails: resList)
                           {
                               for(FeaturePackResponseDTO.invoiceLineAttributes invoiceAttrib: fpDetails.invoiceLineAttributes)
                               {
                                   fpDetails.invoiceTransactionId =invoiceAttrib.invoiceTransactionId;
                               }
                               finalList.add(fpDetails);
                           }
                           responseStr = (String)JSON.serialize(finalList,true); 
                       }        
                   }   
                 system.debug('responseStr:'+responseStr);   
                }
               }catch (Exception e) {logException('getFeaturePackDetails', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Request to BDS failed');
                   throw e;
               }
               return responseStr;
          
       }
       public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
         Map<String, Object> eLogMap = new Map<String, Object>();
         eLogMap.put('interfaceName', 'Billing Enquiry');
         eLogMap.put('elementName', methodName);
         eLogMap.put('referenceNumber', referenceNumber);
         eLogMap.put('correlationId', correlationId);
         eLogMap.put('errorDescription', errorMessage);
         eLogMap.put('businessDescription', businessDescription);
         C2O_Utilities.logException(eLogMap, false);
     }
   }