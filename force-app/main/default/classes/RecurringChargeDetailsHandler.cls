/**************************************************************************
    EDGE        -207242
    component   -RecurringChargesCmp
    Description -Controller to fecth recurring charges for billing enquiry
    Author      -Akanksha Jain
    Team        -Munich
    TestClass-  RecurringChargeDetailsHandlerTest
	
	EDGE-207239    prajakta    18/06/2021
    *********************************************************************************/
    public class RecurringChargeDetailsHandler {
        @AuraEnabled
        public static String getRecurringChargeDetails( Long chargeId,String statementNumber,String accountNumber, String handlerName)
        {
            RecurringChargeTypeResponseDTO res = new RecurringChargeTypeResponseDTO();         
            InvoiceChargeTypeRequestDTO requestDTO = new InvoiceChargeTypeRequestDTO();
            requestDTO.accountNumber = accountNumber;
            requestDTO.chargeId = chargeId;
            requestDTO.statementNumber = statementNumber;
            String request = JSON.serialize(requestDTO,true);
                String responseStr;
     
            HttpResponse recurringResponse;
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
             
             recurringResponse=IntegrationRecordHandlerUtil.calloutSync(request, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
			 if(recurringResponse!= null){
            Logger2 log = Logger2.getLogger(handlerName);
                 DateTime startTime = DateTime.now();
                    DateTime endTime = DateTime.now();
                Long requestTime = log.getRequestTimeDifference(startTime, endTime);
              log.logMessages(request, recurringResponse.getBody(), '', '', '', 
                                    '', String.valueOf(recurringResponse.getStatusCode()), correlationId, '','','Create','',requestTime,'POST',false, false);
                    
             logger.exitLogger();
             System.debug('response:'+recurringResponse);
               List<RecurringChargeTypeResponseDTO.RecurringDetails> recList = new  List<RecurringChargeTypeResponseDTO.RecurringDetails>();
               List<RecurringChargeTypeResponseDTO.RecurringDetails> finalList = new  List<RecurringChargeTypeResponseDTO.RecurringDetails>();
              
                if(recurringResponse.getStatusCode() == 200 ||recurringResponse.getStatusCode() == 201 || recurringResponse.getStatusCode() == 202) 
                {
                    if(recurringResponse.getBody()!= null){
                        res = RecurringChargeTypeResponseDTO.parse(recurringResponse.getBody());
						system.debug('res:'+res);
                    	recList = res.recurringDetails;
                         for(RecurringChargeTypeResponseDTO.recurringDetails recDetails: recList)
                        {
                            for(RecurringChargeTypeResponseDTO.invoiceLineAttributes invoiceAttrib: recDetails.invoiceLineAttributes)
                            {
                                recDetails.invoiceTransactionId =invoiceAttrib.invoiceTransactionId;
                            }
                            finalList.add(recDetails);
                        }
					//system.debug('recList:'+recList);
					
                    responseStr = (String)JSON.serialize(finalList,true);
                      
                    }        
				}   
                 system.debug('responseStr:'+responseStr);   
             }
			}catch (Exception e) {logException('getRecurringChargeDetails', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Request to BDS failed');
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