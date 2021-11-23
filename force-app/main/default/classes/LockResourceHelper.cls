/***********************************************************************************************************
Class Name : LockResourceHelper
Test Class : LockResourceHelperTest
Created By : Sonalisa Verma, Puneeth Kamath
Created On : 27 April 2021
User Story : EDGE-214743
************************************************************************************************************/

global with sharing class LockResourceHelper {
    
    /**************************************************************************************
****** Desc         : Method to validate and lock/unlock number from the request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/    
    public static NumberInventoryResponse processRequest(NumberInventoryRequest request, string sourceSystem){  
        NumberInventoryResponse response = new NumberInventoryResponse();
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        List<String> inputNumbersList = new List<String>();
        List<Number__c> numbersList = new List<Number__c>();
        Map<String, Number__c> numbersMap = new Map<String, Number__c>();
        Map<String , List<Number__c>> validNumberMap = new Map<String , List<Number__c>>();
        Set<String> subIdSet = new Set<String>();

        // Get Number list from request body
        inputNumbersList = UpdateNumberInventoryHelper.getNumbersList(request);

        if(inputNumbersList.isEmpty()){
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType,
                                                                   NumberInventory_Constants.NO_NUM_PRESENT + request.actionType,
                                                                   errorList);
            return response;
        }
        /**Commenting out below section has already being checked at first level */
        /*// Check if numbers are in valid format (11 digits starting with 61)
        Map<String, List<String>> validNumberListMap = UpdateNumberInventoryHelper.validateFormatOfNumbers(inputNumbersList);
        List<String> invalidNumbersList = validNumberListMap.get('invalid');
        List<String> validNumberList = validNumberListMap.get('valid');
        if(!invalidNumbersList.isEmpty()){
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(invalidNumbersList, NumberInventory_Constants.INVALID_NUM));
        }
        if(validNumberList.isEmpty())  { // return error message as no valid numbers present to proceed further
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType + NumberInventory_Constants.NUMS,
                                                                   errorList);  
            return response;

        }  */
         //check for networkserviceId added as part of DIGI-12092
         if(String.isNotBlank(request.networkServiceId)){
            subIdSet = UpdateNumberInventoryHelper.scQueryCreator(request.networkServiceId);
            if(subIdSet.isEmpty()){
                errorList = UpdateNumberInventoryHelper.getErrorList(NumberInventory_Constants.NETWORK_SERVICE_ID,NumberInventory_Constants.SUBS_WITH_NETWORK_SERVICEID,'['+request.networkServiceId+']');
                return UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.BAD_REQUEST,
                                                                   NumberInventory_Constants.NO_SUBSCRIPTION,
                                                                   errorList);
            }
            
        }
        validNumberMap = UpdateNumberInventoryHelper.processAllNumbers(subIdSet, inputNumbersList, null, 'Fixed');

        if(validNumberMap.isEmpty()){ // return error message : numbers doesn't exist
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(inputNumbersList, NumberInventory_Constants.NUM_DO_NOT_EXIST)); 
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType + NumberInventory_Constants.NUMS,
                                                                   errorList);  
            return response;
        }

        for(List<Number__c> lst : validNumberMap.values()){
            numbersList.addAll(lst);
            
        }
        for(Number__c num : numbersList){
            numbersMap.put(num.Service_Number__c, num);
        }
        if(numbersList.isEmpty()){ // return error message : numbers doesn't exist
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(inputNumbersList, NumberInventory_Constants.NUM_DO_NOT_EXIST)); 
            response = UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType + NumberInventory_Constants.NUMS,
                                                                   errorList);  
            return response;
        }

        //check if any request number is not in Number__c
        List<string> numberNotFoundList = UpdateNumberInventoryHelper.getNumbersNotFound(numbersMap, inputNumbersList);
        if(!numberNotFoundList.isEmpty()){
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numberNotFoundList, NumberInventory_Constants.NUM_DO_NOT_EXIST)); 
        }

        switch on request.actionType.toLowerCase() {
            when 'lock' { //if action = lock then check if numbers are inactive
                List<NumberInventoryResponse.errors> lockRequestErrorList = validateLockRequest(validNumberMap, numbersList);
                if(!lockRequestErrorList.isEmpty()){
                    errorList.addAll(lockRequestErrorList);
                }
            }
            when 'unlock' { //if action = Unlock then check if numbers locked by is same as request source system
                List<NumberInventoryResponse.errors> unlockRequestErrorList = validateUnLockRequest(validNumberMap, sourceSystem);
                if(!unlockRequestErrorList.isEmpty()){
                    errorList.addAll(unlockRequestErrorList);
                }
            }
        }
        //if numbers has validation error, return error response else lock/unlock numbers 
        response = errorList.isEmpty() ? UpdateNumberInventoryHelper.lockUnlockNumbers(numbersList, request.actionType, sourceSystem, request.reason)
                    : UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType,
                                                                   NumberInventory_Constants.UNABLE_TO + request.actionType + NumberInventory_Constants.NUMS,
                                                                   errorList);

        return response;
    }
/**************************************************************************************
****** Desc         : Method to validate lock request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/  
    private static List<NumberInventoryResponse.errors> validateLockRequest(Map<String , List<Number__c>> validNumberMap, List<Number__c> numbersList){
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();

        Map<String, List<Number__c>> statusToNumberListMap = UpdateNumberInventoryHelper.getActiveInactiveNumbers(validNumberMap);
        List<Number__c> inactiveNumbersList = statusToNumberListMap.get('inactive');
        if(inactiveNumbersList!=null && !inactiveNumbersList.isEmpty()){
            List<String> numbersListToIneligibleStatus = UpdateNumberInventoryHelper.getIneligibleNumbersForLock(validNumberMap);
            if(!numbersListToIneligibleStatus.isEmpty()){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(numbersListToIneligibleStatus, NumberInventory_Constants.INELIGIBLE_STATUS));
            }
        }

        //validation for numbers are part of number range
        if(FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement','Hash75')){
            Map<String, List<Number__c>> rangeNumberMap = UpdateNumberInventoryHelper.validateNumbersPartOfRange(numbersList);
            List<Number__c> invalidRangeNumbersList = rangeNumberMap.get('invalid');
            if(invalidRangeNumbersList!=null && !invalidRangeNumbersList.isEmpty()){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(invalidRangeNumbersList, NumberInventory_Constants.NUM_PART_OF_RANGE));
            }
        }
        return errorList;
    }
/**************************************************************************************
****** Desc         : Method to validate unlock request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/  
    private static List<NumberInventoryResponse.errors> validateUnLockRequest(Map<String , List<Number__c>> validNumberMap, string sourceSystem){
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        List<String> invalidStatusList = UpdateNumberInventoryHelper.getIneligibleNumbersForUnlock(validNumberMap);
        // check if numbers requested for unlock are in eligible status - locked
        if(invalidStatusList!=null && !invalidStatusList.isEmpty()){
            errorList.add(UpdateNumberInventoryHelper.getErrorMessage(invalidStatusList, NumberInventory_Constants.INELIGIBLE_STATUS));
        }

        // check if source system is same as the locked by
        List<Number__c> eligibleNumberList = (validNumberMap!=null && validNumberMap.containsKey('locked')) ? validNumberMap.get('locked') : null;
        if(eligibleNumberList!=null && !eligibleNumberList.isEmpty()){
            Map<String, List<Number__c>> statusToNumberListMap = UpdateNumberInventoryHelper.validateNumberLockedBy(eligibleNumberList, sourceSystem);
            List<Number__c> invalidSourceSystemList = statusToNumberListMap.get('invalidSourceSystem');
            
            if(invalidSourceSystemList!=null && !invalidSourceSystemList.isEmpty()){
                errorList.add(UpdateNumberInventoryHelper.getErrorMessage(invalidSourceSystemList, NumberInventory_Constants.LOCKED_BY_DIFF_CONSUMER));
            }
        }
        return errorList;
    }
}