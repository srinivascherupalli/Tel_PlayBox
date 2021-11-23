/***********************************************************************************************************
Class Name : GetPriceDetails
Test Class : GetPriceDetailsTest
Created By : Purushottam, Irfan
Created On : 25 October 2021
User Story : DIGI-16567
************************************************************************************************************/

@RestResource(urlMapping='/v1/pricing/fetch-pricing-detail/') 
global with sharing class GetPriceDetails {
    
    /**************************************************************************************
****** Desc         : http post method to get the  standard price and delegated /negotiated price (if any) of a customer for Adaptive Mobility plans. 
****** Story        : DIGI-16567
****** Developer    : Purushottam, Irfan
***************************************************************************************/ 
    @HttpPost
    global static void doPost() {
        
        Logger2 logger = Logger2.getLogger('GetPriceDetailsPost');
        PricingAPIResponse response = new PricingAPIResponse();
        PricingAPIRequest request = new PricingAPIRequest();
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        String correlationId = restReq.headers.get('correlationId');
        string sourceSystem = restReq.headers.get('Source-System');
        List<PricingAPIResponse.errors> errorList = new List<PricingAPIResponse.errors>();
        DateTime startTime = DateTime.now();
        try{
            
            string requestBody = restReq.requestBody.toString();
            if(String.isNotBlank(requestBody)){
                //Set the request
                request = (PricingAPIRequest)JSON.deserialize(requestBody, PricingAPIRequest.Class);
            }
            
            
            
            //All validations should be added here
            
            //Check id request/any request paramatere value is Null/blank
            if(request == null || String.isBlank(request.marketableOfferId) || String.isBlank(request.cidn)){
                errorList.add(PricingInfoResponseHelper.getErrorMessage(Pricing_API_Constants.MISSING_REQ_ATTRIBUTES,
                                                                        Pricing_API_Constants.INVALID_ID_FIELD));    
                response = PricingInfoResponseHelper.prepareResponse(Pricing_API_Constants.ERROR_CODE_400,
                                                                     null,
                                                                     errorList); 
                restRes = PricingInfoResponseHelper.getRestResponse(response, correlationId);
                return;
            }
            
            
            //validate offer name
            if(!PricingInfoResponseHelper.validateMandatory(request, sourceSystem)){
                errorList.add(PricingInfoResponseHelper.getErrorMessage(Pricing_API_Constants.INVALID_OFFER_NAME,
                                                                        Pricing_API_Constants.INVALID_ID_FIELD));
                response = PricingInfoResponseHelper.prepareResponse( Pricing_API_Constants.ERROR_CODE_400,
                                                                      //Pricing_API_Constants.INVALID_OFFER_NAME,
                                                                      //Pricing_API_Constants.INVALID_REQUEST_FORMAT_415,
                                                                      null,
                                                                      errorList);   
                restRes = PricingInfoResponseHelper.getRestResponse(response, correlationId);
                return;
            }
        
            
            
            //validate cidn
            if(!PricingInfoResponseHelper.isValidCIDN(request, sourceSystem)){
                errorList.add(PricingInfoResponseHelper.getErrorMessage(Pricing_API_Constants.ERROR_CIDN,
                                                                        Pricing_API_Constants.INVALID_ID_FIELD));    
                response = PricingInfoResponseHelper.prepareResponse( Pricing_API_Constants.ERROR_CODE_400,
                                                                      //Pricing_API_Constants.ERROR_CIDN,
                                                                      null,
                                                                      errorList);
                restRes = PricingInfoResponseHelper.getRestResponse(response, correlationId);
                return;
            }

            //validate productcode
            if(request.productCode != null && !PricingInfoResponseHelper.isValidProductCode(request, sourceSystem)){
                errorList.add(PricingInfoResponseHelper.getErrorMessage(Pricing_API_Constants.ERROR_PRODCODE,
                                                                        Pricing_API_Constants.INVALID_ID_FIELD));    
                response = PricingInfoResponseHelper.prepareResponse( Pricing_API_Constants.ERROR_CODE_400,
                                                                      //Pricing_API_Constants.PRODUCT_CODE_NOTFOUND,
                                                                      null,
                                                                      errorList);
                restRes = PricingInfoResponseHelper.getRestResponse(response, correlationId);
                return;
            }
            //set response
            response = PricingInfoResponseHelper.processRequest(request, sourceSystem);
            
            restRes = PricingInfoResponseHelper.getRestResponse(response, correlationId);
            return;         
            
        }catch(Exception ex){
            
            errorList.add(PricingInfoResponseHelper.getErrorMessage(Pricing_API_Constants.ERROR_CODE_400,
                                                                    Pricing_API_Constants.INVALID_ID_FIELD));    
            response = PricingInfoResponseHelper.prepareResponse( Pricing_API_Constants.INVALID_REQUEST_500,
                                                                 //Pricing_API_Constants.ERROR_CODE_404,
                                                                 Pricing_API_Constants.INVALID_REQUEST_FORMAT_415,
                                                                 errorList);  
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
             logger.logMessages(JSON.serialize(request), ex.getMessage(), '', '', '', 
                                '', String.valueOf(response.code), correlationId, '','','Read','',requestTime ,'POST',false, false);
            
        }
        finally{
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', 
                                '', String.valueOf(response.code), correlationId, '','','Read','',requestTime ,'POST',false, false);
            logger.exitLogger();
        }
        
    }
    
}