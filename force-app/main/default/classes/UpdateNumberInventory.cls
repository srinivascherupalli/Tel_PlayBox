@RestResource(urlMapping='/v1/number-inventory') 
global with sharing class UpdateNumberInventory{
    @HttpPost
    global static void handleUCDMNumberRequest() {
        
        Logger2 logger = Logger2.getLogger('NumberInventoryPost');
        NumberInventoryResponse  response = new NumberInventoryResponse ();
        NumberInventoryRequest request = new NumberInventoryRequest();
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        
        RestResponse res = RestContext.response;
        RestRequest restReq = RestContext.request;
        try{
            string requestBody = restReq.requestBody.toString();
            if(!String.isBlank(requestBody)){
                request = (NumberInventoryRequest)JSON.deserialize(requestBody, NumberInventoryRequest.Class);
                if(request.actionType.equalsIgnoreCase('Activate') || request.actionType.equalsIgnoreCase('Cancel')){
                    response = validatePayload(request);
                    system.debug('heap'+limits.getHeapSize());
                }
                //Added as part of DIGI-13056
                else{
                    errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.INVALID_REQUEST));    
                    response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                           NumberInventory_Constants.BAD_REQUEST,
                                                                           NumberInventory_Constants.INVALID_REQUEST,
                                                                           errorList);
                }
                
            }
            else{
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.INVALID_REQUEST));    
                response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                       NumberInventory_Constants.BAD_REQUEST,
                                                                       NumberInventory_Constants.INVALID_REQUEST,
                                                                       errorList);
            }
        }
        catch(Exception e){//Changed DMLException to Exception as part of DIGI-12695
            //EDGE-2331
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(NumberInventory_Constants.C2O_TECH_ERROR_EXCEP));    
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.BAD_REQUEST
                                                                   ,NumberInventory_Constants.INVALID_REQUEST,
                                                                   errorList);
            logger.logMessages(JSON.serialize(request),e.getMessage(),'', '','','', false, false, Integer.valueof(response.Code),null,null,null);
        } 
        finally {
            if(request != null && response != null && response.code != null ){
                logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', '', false, false, Integer.valueof(response.Code),null,null,null);
            }
            logger.exitLogger();
        }
        res = UpdateNumberInventoryHelper.getRestResponse(response,restReq.headers.get('correlationId'));
        
    }
    public static NumberInventoryResponse validatePayload(NumberInventoryRequest request){
        RestRequest r = RestContext.request;
        NumberInventoryResponse  response = new NumberInventoryResponse ();
        set<string>subIdSet=new set<string>();
        List<String> NumbersList = new List<String>();
        Map<String , List<String>> numbersWithErrorMap  = new Map<String , List<String>>();
        list<csord__Subscription__c>sublist=new list<csord__Subscription__c>();
        list<Number__c>numberList=new list<Number__c>();
        List<String> numbersInputList = UpdateNumberInventoryHelper.validateNumbers(request.numbers);
        if (!numbersInputList.isEmpty()) {
            List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numbersInputList, NumberInventory_Constants.INVALID_NUM));
            return UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                               NumberInventory_Constants.BAD_REQUEST,
                                                               NumberInventory_Constants.INVALID_NUM,
                                                               errorList); 
        }
        if(String.isBlank(request.networkServiceId) && request.actionType.equalsIgnoreCase('Activate')){
            List<NumberInventoryResponse.errors> errorList = UpdateNumberInventoryHelper.getErrorList(NumberInventory_Constants.NETWORK_SERVICE_ID,NumberInventory_Constants.NETWORK_SERVICE_ID_ACTIVATE,NumberInventory_Constants.NETWORK_SERVICE_ID_MISSING);
            return UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                               NumberInventory_Constants.BAD_REQUEST,
                                                               NumberInventory_Constants.INVALID_REQUEST,
                                                               errorList);
        }
        //check of subscription if networkServiceId is there added as part of DIGI-12092
        else if(String.isNotBlank(request.networkServiceId)){
            subIdSet = UpdateNumberInventoryHelper.scQueryCreator(request.networkServiceId);
            if(subIdSet.isEmpty()){
                List<NumberInventoryResponse.errors> errorList = UpdateNumberInventoryHelper.getErrorList(NumberInventory_Constants.NETWORK_SERVICE_ID,NumberInventory_Constants.SUBS_WITH_NETWORK_SERVICEID,'['+request.networkServiceId+']');
                return UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.BAD_REQUEST,
                                                                   NumberInventory_Constants.NO_SUBSCRIPTION,
                                                                   errorList);
            }
            
        }
        
        if (request.numbers != null){
            NumbersList=UpdateNumberInventoryHelper.getNumbersList(request);
        }
        response = numberQueryCreator(subIdSet,NumbersList,request.actionType,sublist,r.headers.get('Source-System'));
        
        
        return response;
    }
    
    public static list<csord__Subscription__c> scQueryCreator(string networkId){
        List<string> statusList =  new List<String>{'Inactive','Cancelled','Replaced','Closed Replaced'}; 
            string querystring='select id,NetworkServiceId__c,csordtelcoa__Subscription_Number__c,csord__Order__c,csord__Status__c, (select Id, csordtelcoa__Service_Number__c from csord__Services__r) from csord__Subscription__c where NetworkServiceId__c = \'' +String.escapeSingleQuotes(networkId) + '\' and csord__Status__c NOT IN : statusList';
        list<csord__Subscription__c> subList=database.query(querystring);
        return subList;
    }
    public static NumberInventoryResponse numberQueryCreator(set<string> subIdSet,list<string> NumbersList,string actionType,List<csord__Subscription__c> subList,String sourceSystem){
        NumberInventoryResponse  response = new NumberInventoryResponse ();
        List<Number__c> foundNumberList = new List<Number__c>();
        List<string> numberNotFoundList = new List<String>();
        Map<String, Number__c> numbersMap = new Map<String, Number__c>();
        Map<String , List<Number__c>> statusToNumberListMap  = new Map<String , List<Number__c>>();
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        if(actionType == 'Activate' ){
            set<string>activeSet = new Set<String>();
            statusToNumberListMap = UpdateNumberInventoryHelper.processAllNumbers(subIdSet,NumbersList,activeSet,'Fixed');
            if(statusToNumberListMap.containsKey('active') && statusToNumberListMap.get('active') != null){
                return UpdateNumberInventoryHelper.collectActiveNumbers(statusToNumberListMap.get('active'));
            }
            else{
                response = UpdateNumberInventoryHelper.handleNumberInsertOrUpdateForActivate(statusToNumberListMap,NumbersList);
            }
        }else if(actionType == 'Cancel' ){
            //set<string>cancelSet =  new Set<String>{'Locked','Reserved','IN TRANSITION'}; 
            set<string>cancelSet =  new Set<String>{}; 
                statusToNumberListMap = UpdateNumberInventoryHelper.processAllNumbers(subIdSet,NumbersList,cancelSet,'Fixed');
            //Added as part of DIGI-13056
            
            for(List<Number__c> lst : statusToNumberListMap.values()){
                foundNumberList.addAll(lst);
            }
            
            for(Number__c num : foundNumberList){
                numbersMap.put(num.Service_Number__c, num);
            }

            numberNotFoundList = UpdateNumberInventoryHelper.getNumbersNotFound(numbersMap, NumbersList);
            
            if(!numberNotFoundList.isEmpty()){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numberNotFoundList, NumberInventory_Constants.NUM_DO_NOT_EXIST)); 
                response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                       NumberInventory_Constants.UNABLE_TO + actionType,
                                                                       NumberInventory_Constants.UNABLE_TO + actionType + NumberInventory_Constants.NUMS,
                                                                       errorList);  
            }
            else{
                response = UpdateNumberInventoryHelper.updateNumbers(statusToNumberListMap,sourceSystem);
            }
            
        }
        return response;
        
    } 
    
}