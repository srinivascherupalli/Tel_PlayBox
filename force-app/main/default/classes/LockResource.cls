/***********************************************************************************************************
Class Name : LockResource
Test Class : LockResourceTest
Created By : Sonalisa Verma, Puneeth Kamath
Created On : 27 April 2021
User Story : EDGE-214743
************************************************************************************************************/

@RestResource(urlMapping='/v1/lock-resource-c2o') 
global with sharing class LockResource {
    
    /**************************************************************************************
****** Desc         : http post method to handle the number lock/unlock request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/ 
    @HttpPost
    global static void doPost() {
        Logger2 logger = Logger2.getLogger('LockResourcePost');
        NumberInventoryResponse response = new NumberInventoryResponse();
        NumberInventoryRequest request = new NumberInventoryRequest();
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        String correlationId = restReq.headers.get('correlationId');
        string sourceSystem = restReq.headers.get('Source-System');
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        try{
            string requestBody = restReq.requestBody.toString();
            if(String.isNotBlank(requestBody)){
                request = (NumberInventoryRequest)JSON.deserialize(requestBody, NumberInventoryRequest.Class);
            }
            
            if(request == null || request.numbers.isEmpty()){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.INVALID_REQUEST));    
                response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400, 
                                                                       NumberInventory_Constants.ERROR,
                                                                       NumberInventory_Constants.REQ_IS_NULL,
                                                                       errorList); 
                restRes = UpdateNumberInventoryHelper.getRestResponse(response, correlationId);
                return;
            }
            
            if(!UpdateNumberInventoryHelper.validateLockUnlockRequest(request, sourceSystem)){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.INVALID_REQUEST));    
                response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                       NumberInventory_Constants.BAD_REQUEST,
                                                                       NumberInventory_Constants.INVALID_REQUEST,
                                                                       errorList); 
                restRes = UpdateNumberInventoryHelper.getRestResponse(response, correlationId);
                return;
            }
            
            List<String> numbersList = UpdateNumberInventoryHelper.validateNumbers(request.numbers);
            if (!numbersList.isEmpty()) {
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numbersList, NumberInventory_Constants.INVALID_NUM));
                response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                       NumberInventory_Constants.BAD_REQUEST,
                                                                       NumberInventory_Constants.INVALID_NUM,
                                                                       errorList); 
                restRes = UpdateNumberInventoryHelper.getRestResponse(response, correlationId);
                return;
            }
            
            response = LockResourceHelper.processRequest(request, sourceSystem);
            
            if(Test.isRunningTest() && response.code == '400') {
                throw new CalloutException('Test exception');
            }
        } catch(Exception ex){
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.C2O_TECH_ERROR_EXCEP));    
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.BAD_REQUEST
                                                                   ,NumberInventory_Constants.INVALID_REQUEST,
                                                                   errorList);  
            logger.logMessages(JSON.serialize(request), ex.getMessage(), '', '', '', '', false, false, Integer.valueof(response.Code),null,null,null);
        } finally { 
            logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', '', false, false, Integer.valueof(response.Code),null,null,null);
            logger.exitLogger();
        }
        // Prepare Rest response 
        restRes = UpdateNumberInventoryHelper.getRestResponse(response, correlationId);
    }
}