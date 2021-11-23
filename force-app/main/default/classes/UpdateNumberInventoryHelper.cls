/*
Class Name          :     UpdateNumberInventoryHelper
Author              :    Team Apple
Date                :    26th April 2021
--------------------------------------------------------------------------------------------------*/
global with sharing class UpdateNumberInventoryHelper {
    
    private static String correlationId                           =       GuidUtil.NewGuid();
    private static NumberInventoryResponse  response              =       new NumberInventoryResponse ();
    private static list<csord__Subscription__c> sublist            =       new list<csord__Subscription__c>();
    private static string numberStatusLocked = 'Locked';
    private static string numberStatusActive = 'Active';
    private static string defaultReasonForLockUnlock = 'Unlocked via API'; 
    private static String[] validStatusForLock = new string[] {'active', 'disconnect pending'};
    private static String[] validStatusForUnlock = new string[] {'locked'};
    
    global static List<String> getNumbersList (NumberInventoryRequest numberRequest){
        List<String> singleNumbersList                  =       new List<String>();
        List<String> rangeNumbersList                   =       new List<String>();
        List<String> numberList                         =       new List<String>();
        singleNumbersList                               =       getSingleNumbersList(numberRequest , singleNumbersList );
        rangeNumbersList                                =       getRangeNumbersList(numberRequest , rangeNumbersList );
        numberList.addAll (singleNumbersList );
        numberList.addAll (rangeNumbersList );
        return numberList;
    }  
    
    // Method to extract single Numbers from request body
    public static list<String> getSingleNumbersList( NumberInventoryRequest cancelledRequest , list<String> singleNumbersList){
        // Get Single numbers from request
        for ( NumberInventoryRequest.numbers inventoryNumbers : cancelledRequest.numbers ) {
            if(inventoryNumbers.singleNumbers != null){
                for ( String cNumber : inventoryNumbers.singleNumbers) {
                    if ( !String.isEmpty( cNumber )) {
                        singleNumbersList.add( cNumber );
                    }
                }
            }
            
        }
        return singleNumbersList;
    }  
    
    // Method to extract range Numbers from request body
    public static list<String> getRangeNumbersList ( NumberInventoryRequest cancelledRequest , list<String> rangeNumbersList ) {
        // Get Range numbers from request    
        for ( NumberInventoryRequest.numbers inventoryNumbers : cancelledRequest.numbers ) {
            if(inventoryNumbers.ranges != null){
                for ( NumberInventoryRequest.ranges rangedNumbers : inventoryNumbers.ranges) {
                    Decimal startRange        = Decimal.valueOf( rangedNumbers.startNumber );
                    Decimal endRange          = Decimal.valueOf( rangedNumbers.endNumber );
                    rangeNumbersList.addAll( fetchValidRangeNumbers(startRange, endRange));
                }
            }
        }
        return rangeNumbersList;
    }
    
    // Method to get valid numbers between start and end range.
    public static list<String> fetchValidRangeNumbers ( Decimal startRange , Decimal endRange ) {
        //  Get Numbers b/w given Range
        List<String> rangedNumbers    =   new List<String>();
        for ( Decimal i = startRange; i<= endRange; i++) {
            rangedNumbers.add( String.valueOf( i ) );

        }
        return rangedNumbers;
    }
    
    // Method to query all number records as per status 
    public static Map<String , List<Number__c>> processAllNumbers(set<string> subIdSet, list<String> numberList,set<string> statusSet, string mobileType) {
        // Number Logic goes here

        
        Map<String , List<Number__c>> statusToNumberListMap  = new Map<String , List<Number__c>>();
        //String status = 'Fixed';
        String queryNumber = 'SELECT ID,Status__c,Number_Group__c,Service_Number__c,Product_Configuration__c,Number_Range__c, Start_Range__c, End_range__c, Locked_By__c, ReasonForLockUnlock__c FROM Number__c WHERE Service_Number__c IN :numberList ';
        if(statusSet!=null && !statusSet.isEmpty()) {
            queryNumber = queryNumber + ' AND Status__c IN: statusSet';
        }
        if(String.isNotBlank(mobileType)) {
            queryNumber = queryNumber + ' AND Mobile__c =: mobileType';
        }
        if(!subIdSet.isEmpty()){
            queryNumber = queryNumber + ' AND Subscription_number__c IN :subIdSet';
        }
        
        queryNumber = queryNumber + ' order by Service_Number__c,CreatedDate DESC LIMIT 10000';
        
        List<Number__c> numberListToProcess = Database.query( queryNumber );
        
        for( Number__c numbers : numberListToProcess ) {
            if(!statusToNumberListMap.containsKey(numbers.Status__c.toLowerCase())) {
                statusToNumberListMap.put(numbers.Status__c.toLowerCase() , new List<Number__c>());
            }
            statusToNumberListMap.get(numbers.Status__c.toLowerCase()).add(numbers);
        }
        return statusToNumberListMap;
    }
    
    // Method to perform DML on numbers collected from processing conditions.
    public static NumberInventoryResponse  updateNumbers ( Map<String,List<Number__c>> numbersToProcess, String sourceSystem ){
        set<string>cancelSet =  new Set<String>{'LOCKED','RESERVED','IN TRANSITION'};
        List<Number__c> numbersListToProcess                  =       new List<Number__c>();
        List<String> numbersListToIneligibleStatus            =       new List<String>();
        
        for( String statusValue : numbersToProcess.keySet()){
            String key = statusValue.toUpperCase();
            if( !cancelSet.contains(key) ){
                for( Number__c otherNumber : numbersToProcess.get(statusValue)){
                    numbersListToIneligibleStatus.add(otherNumber.Service_Number__c + ' : ' + statusValue );
                }
            }
            else if(statusValue.equalsIgnoreCase('locked')){
                numbersListToProcess.addAll(numbersToProcess.get(statusValue));
            }
        }
        
        if(!numbersListToIneligibleStatus.isEmpty()){
            List<NumberInventoryResponse.errors> errorList = getErrorList(NumberInventory_Constants.NUMBERS,NumberInventory_Constants.INELIGIBLE_STATUS,'['+String.join(numbersListToIneligibleStatus, ',')+']');
            return prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                   NumberInventory_Constants.UNABLE_CANCEL,
                                   NumberInventory_Constants.INELIGIBLE_STATUS,
                                   errorList);
        }
        Map<string, List<Number__c>> validateNumber  =       validateNumberLockedBy( numbersListToProcess , sourceSystem);

        if( validateNumber != null && validateNumber.containsKey('invalidSourceSystem') && validateNumber.get('invalidSourceSystem').size() != 0 ){
            List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
            errorList.add(getErrorMessage(validateNumber.get('invalidSourceSystem'), NumberInventory_Constants.LOCKED_BY_DIFF_CONSUMER));
            return prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                   NumberInventory_Constants.UNABLE_CANCEL,
                                   NumberInventory_Constants.LOCKED_BY_DIFF_CONSUMER,
                                   errorList);
            //return prepareResponse(false, 'Source system is different', errorList);
        }
        
        List< Number__c > updateNumberList           =       new List<Number__c>();
        List< Number__c > deleteNumberList           =       new List<Number__c>();

        if ( numbersToProcess.containsKey('locked')){
            for( Number__c lockedNumber : numbersToProcess.get('locked') ){
                lockedNumber.Status__c    =   'Disconnected';
                updateNumberList.add( lockedNumber );
            }
        } 
        
        if ( numbersToProcess.containsKey('reserved')){
            deleteNumberList.addAll( numbersToProcess.get('reserved') );
        }
        if ( numbersToProcess.containsKey('in transition')){
            deleteNumberList.addAll( numbersToProcess.get('in transition') );
        }
        if ( deleteNumberList.size() > 0) {
            try{
                delete deleteNumberList;
                response = prepareResponse(NumberInventory_Constants.SUCCESS_CODE_200,
                                           NumberInventory_Constants.OK_MSG,
                                           NumberInventory_Constants.SUCCESS_MSG,
                                           null);
            } catch (Exception ex) {
                logException('updateNumbers', '', correlationId, ex.getMessage(), 'Removal of Numbers failed.');
                response = prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                           NumberInventory_Constants.REMOVAL_FAILURE,
                                           ex.getMessage(),
                                           null);
            }
        }
        
        if ( updateNumberList.size() > 0 ){
            try {
                update updateNumberList;
                response = prepareResponse(NumberInventory_Constants.SUCCESS_CODE_200,
                                           NumberInventory_Constants.OK_MSG,
                                           NumberInventory_Constants.SUCCESS_MSG,
                                           null);
            } catch (Exception ex) {
                logException('updateNumbers', '', correlationId, ex.getMessage(), 'Update Number failed during Disconnection.');
                response = prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                           NumberInventory_Constants.UPADATE_FAIL_DISCONNECTION,
                                           ex.getMessage(),
                                           null);
            }
        }
        
        return response;
    }
    /**************************************************************************************
****** Desc         : This method is to collect active numbers and return error response
****** Story        : EDGE-204049
****** Developer    : Mukta Wadhwani
***************************************************************************************/   
    public static NumberInventoryResponse  collectActiveNumbers(List<Number__c> activeNumberList){
        String activeNumberString = '';
        for(Number__c numberObj : activeNumberList){
            activeNumberString += numberObj.Service_Number__c+',';
        }
        List<NumberInventoryResponse.errors> errorList = getErrorList(NumberInventory_Constants.NUMBERS,NumberInventory_Constants.ALREADY_ACTIVE,'['+activeNumberString.removeEnd(',')+']');
        return UpdateNumberInventoryHelper.prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                                           NumberInventory_Constants.UNABLE_ACTIVATE,
                                                           NumberInventory_Constants.UNABLE_ACTIVATE_NUM,
                                                           errorList);
        
    }
    /**************************************************************************************
****** Desc         : This method is to handle number insert of update logic when we get Activate request from UCDM
****** Story        : EDGE-204049
****** Developer    : Mukta Wadhwani
***************************************************************************************/   
    public static NumberInventoryResponse handleNumberInsertOrUpdateForActivate(Map<String,List<Number__c>> existingNumebrsMap,List<String> totalNumberList){
        List<Number__c> existingNumberList = new List<Number__c>();
        List<Number__c> numberUpdateList = new List<Number__c>();
        List<String> numberGroupIdList = new List<String>();
        List<Number_Group__c> numberGroupInsertList = new List<Number_Group__c>();
        List<String> inEligibleNumbersValueList = new List<String>();
        try{
            //If numbers are existing then update the numbers and remove them from totalNumberList
            if(existingNumebrsMap != null){
                for(String status : existingNumebrsMap.keySet()){
                    existingNumberList.addAll(existingNumebrsMap.get(status));
                }
                
                for(Number__c numberObj : existingNumberList){
                    Integer index = totalNumberList.indexOf(numberObj.Service_Number__c);
                    totalNumberList.remove(index);
                    if(numberObj.Status__c == 'Reserved' || numberObj.Status__c == 'In Transition'){
                        numberObj.status__c = 'Provisioned';
                        numberGroupIdList.add(numberObj.Number_Group__c);
                        numberUpdateList.add(numberObj);
                    }
                    else{
                        inEligibleNumbersValueList.add(numberObj.Service_Number__c+ ':' +numberObj.Status__c);
                    }
                }
            }
            //Return error response if number status is not eligible for activation 
            if(!inEligibleNumbersValueList.isEmpty()){
                List<NumberInventoryResponse.errors> errorList = getErrorList(NumberInventory_Constants.NUMBERS,NumberInventory_Constants.INELIGIBLE_STATUS,'['+String.join(inEligibleNumbersValueList, ',')+']');
                return prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                       NumberInventory_Constants.UNABLE_ACTIVATE,
                                       NumberInventory_Constants.INELIGIBLE_STATUS,
                                       errorList);
            }
            if(!numberUpdateList.isEmpty()){
                update numberUpdateList;
                updateNumberGroup(numberGroupIdList);
            }
            
            //Create numbers and number group records for non existing numbers.
            if(!totalNumberList.isEmpty()){
                insertNewNumbersandNumberGroup(totalNumberList);
            }
            return prepareResponse(NumberInventory_Constants.SUCCESS_CODE_200,
                                   NumberInventory_Constants.OK_MSG,
                                   NumberInventory_Constants.SUCCESS_MSG,
                                   null);
        }
        catch (Exception ex) {
            logException('handleNumberInsertOrUpdateForActivate', '', correlationId, ex.getMessage(), 'Update or insert Number failed during Active.');
            return prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                   NumberInventory_Constants.ERROR_MSG,
                                   ex.getMessage(),
                                   null);
        }
        
        
        
    }
    /**************************************************************************************
****** Desc         : This method is to update number group status to provisioned  if all its numbers are provisioned
****** Story        : EDGE-204049
****** Developer    : Mukta Wadhwani
***************************************************************************************/   
    public static void updateNumberGroup(List<String> numberGroupIdList){
        List<Number_Group__c> numberGroupUpdateList = new List<Number_Group__c>();
        boolean isAllProvisioned = true;
        for(Number_Group__c groupObj : [select Id,Status__c, (select status__c,IsDisconnected__c from Numbers__r) from Number_Group__c where Id=:numberGroupIdList and Status__c != 'Provisioned']){
            for(Number__c numberObj : groupObj.Numbers__r){
                if(numberObj.Status__c != 'Provisioned' && (numberObj.Status__c != 'Bill Readiness In Progress' && !numberObj.IsDisconnected__c)
                   && numberObj.Status__c != 'Active'){
                       isAllProvisioned = false;
                       break;
                   }
            }
            if(isAllProvisioned){
                groupObj.status__c = 'Provisioned';
                numberGroupUpdateList.add(groupObj);
                
            }
        }
        update numberGroupUpdateList;
        
    }
    /**************************************************************************************
****** Desc         : This method is to Insert new number group and numbers records when 
****** Story        : EDGE-204049
****** Developer    : Mukta Wadhwani
***************************************************************************************/   
    public static void insertNewNumbersandNumberGroup(List<String> newNumbersList){
        Number_Group__c numberGroupObj = new Number_Group__c();
        List<Number__c> numberInsertList = new List<Number__c>();
        numberGroupObj.OrderId__c = subList[0].csord__Order__c;
        numberGroupObj.Scenario_Type__c = 'Add';
        numberGroupObj.status__c = 'Provisioned';
        numberGroupObj.RequestedCompletionDate__c =  Datetime.now();
        numberGroupObj.Subscription_Number__c = subList[0].csordtelcoa__Subscription_Number__c;
        csord__Service__c servObj = subList[0].csord__Services__r.isEmpty() ? null : subList[0].csord__Services__r[0]; //DIGI-13386
        insert numberGroupObj;
        for(String phoneNumber : newNumbersList){
            Number__c numberObj = new Number__c();
            numberObj.status__c = 'Provisioned';
            numberObj.mobile__c = 'Fixed';
            numberObj.Type__c = 'New';
            numberObj.Invoke_BDS_Notification__c = true;
            numberObj.Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
            numberObj.Number_Group__c = numberGroupObj.Id;
            numberObj.Service_Number__c = phoneNumber;
            numberObj.Service_Id__c = servObj?.csordtelcoa__Service_Number__c; //DIGI-13386
            numberInsertList.add(numberObj);
            
        }
        insert numberInsertList;
    }
    /**************************************************************************************
****** Desc         : This method is to prepare errorList
****** Story        : EDGE-204049
****** Developer    : Mukta Wadhwani
***************************************************************************************/   
    public static List<NumberInventoryResponse.errors> getErrorList(String failure,String message,String value){
        List<NumberInventoryResponse.errors> errorList = new List<NumberInventoryResponse.errors>();
        NumberInventoryResponse.errors errorObj = new NumberInventoryResponse.errors();
        errorObj.failure = failure;
        errorObj.message = message;
        errorObj.value = value;
        errorList.add(errorObj);
        return errorList;
    }
    
    /**
* @description Exception Handling Framework 
*/
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', 'B2B-1636');
        eLogMap.put('interfaceName', '');
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    /**************************************************************************************
****** Desc         : Method to get NumberInventoryResponse based on input parameters
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/    
    public static NumberInventoryResponse prepareResponse(string errorCode, string status, String errorMessage, List<NumberInventoryResponse.errors> errorList) {
        NumberInventoryResponse resp = new NumberInventoryResponse();
        resp.code = errorCode;
        resp.Status = status;
        resp.errors = errorList;
        resp.message = errorMessage;
        return resp;        
    }   
    
    /**************************************************************************************
****** Desc         : Method to validate if numbers are in valid format (11 digits starting with 61)
****** Story        : EDGE-214743
****** Developer    : Puneeth Kamath
***************************************************************************************/
    public static Map<String, List<String>> validateFormatOfNumbers (list<String> numberList) {
        Map<String , List<String>> numbersWithErrorMap  = new Map<String , List<String>>();
        List<String> validNumberList = new List<String>();
        List<String> invalidNumberList = new List<String>();
        
        for(String num : numberList) {
            if(num.length() == 11 && num.startsWith('61') && num.isNumeric()) {
                validNumberList.add(num);
            }
            else {
                invalidNumberList.add(num);
            }
        }
        numbersWithErrorMap.put('valid', validNumberList);
        numbersWithErrorMap.put('invalid', invalidNumberList);
        
        return numbersWithErrorMap;
    }
    
    /**************************************************************************************
****** Desc         : Method to separate active numbers and other than active state numbers
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
public static Map<String, List<Number__c>> getActiveInactiveNumbers(Map<String , List<Number__c>> statusToNumberListMap) {
    Map<String , List<Number__c>> numberMap = new Map<String , List<Number__c>>();
    List<Number__c> inactiveNumberList = new List<Number__c>();
    List<Number__c> activeNumberList = new List<Number__c>();
    //club all the numbers as active having status - active,Disconnect Pending
    //club all the numbers as inactive having status other than active,Disconnect Pending
    for(string status : statusToNumberListMap.keySet()){
        List<Number__c> lst = statusToNumberListMap.get(status);
        if(validStatusForLock.contains(status.toLowerCase())) {
            activeNumberList.addAll(lst);
        } else {
            inactiveNumberList.addAll(lst);
        }
    }
    numberMap.put('active', activeNumberList);
    numberMap.put('inactive', inactiveNumberList);
    return numberMap;
}
    /**************************************************************************************
****** Desc         : Method to get numbers with ineligible status for lock
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static List<String> getIneligibleNumbersForLock(Map<String , List<Number__c>> validNumberMap){
        return getIneligibleNumbers(validNumberMap, validStatusForLock);
    }

    /**************************************************************************************
****** Desc         : Method to get numbers with ineligible status for unlock
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static List<String> getIneligibleNumbersForUnlock(Map<String , List<Number__c>> validNumberMap){
        return getIneligibleNumbers(validNumberMap, validStatusForUnlock);
    }

    /**************************************************************************************
****** Desc         : Method to get numbers with ineligible status
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static List<String> getIneligibleNumbers(Map<String , List<Number__c>> validNumberMap, string[] validStatus){
        List<String> numbersListToIneligibleStatus = new List<String>();
        for(String statusValue : validNumberMap.keySet()){
            if(!validStatus.contains(statusValue.toLowerCase())){
                for(Number__c num : validNumberMap.get(statusValue)){
                    numbersListToIneligibleStatus.add(num.Service_Number__c + ' : ' + statusValue );
                }
            }
        }
        return numbersListToIneligibleStatus;
    }
    
    /**************************************************************************************
****** Desc         : Method to validate all the numbers of the range are present in lock request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static Map<string, List<Number__c>> validateNumbersPartOfRange(List<Number__c> numberList){
        Map<string, List<Number__c>> numberRangeActualMap = new Map<string, List<Number__c>>();
        Map<string, List<Number__c>> numbersWithErrorMap = new Map<string, List<Number__c>>();
        List<Number__c> invalidNumbersList = new List<Number__c>();
        List<Number__c> validNumbersList = new List<Number__c>();
        
        for(Number__c num : numberList) {
            if(num.Number_Range__c!='-'){
                if(!numberRangeActualMap.containsKey(num.Number_Range__c)) {
                    numberRangeActualMap.put(num.Number_Range__c, new List<Number__c>());
                }
                numberRangeActualMap.get(num.Number_Range__c).add(num);
            }
        }
        
        if(numberRangeActualMap!=null && !numberRangeActualMap.isEmpty()){
            Map<string, integer> numbersCountFromRange = getNumbersCountFromRange(numberRangeActualMap.keySet());
            for(string numberRange : numberRangeActualMap.keySet()){
                if(numbersCountFromRange.get(numberRange) != numberRangeActualMap.get(numberRange).size()){
                    invalidNumbersList.addAll(numberRangeActualMap.get(numberRange));
                } else {
                    validNumbersList.addAll(numberRangeActualMap.get(numberRange));
                }
            }
        }
        
        numbersWithErrorMap.put('valid', validNumbersList);
        numbersWithErrorMap.put('invalid', invalidNumbersList);
        
        return numbersWithErrorMap;
    }
    
    /**************************************************************************************
****** Desc         : Method to number count based oon number range
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    private static Map<string, integer> getNumbersCountFromRange(Set<string> rangeSet){
        Map<string, integer> numbersCountFromRange = new Map<string, integer>();
        for(string numberRange : rangeSet) {
            String[] range = numberRange.split('-');
            Decimal startRange = Decimal.valueOf(range[0].trim());
            Decimal endRange = Decimal.valueOf(range[1].trim());
            numbersCountFromRange.put(numberRange, Integer.valueOf(endRange - startRange) + 1);
        }
        return numbersCountFromRange;
    }
    
    /**************************************************************************************
****** Desc         : Method to validate number if Locked_By__c and sourceSystem is same
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static Map<string, List<Number__c>> validateNumberLockedBy(List<Number__c> numberList, string sourceSystem) {
        Map<String , List<Number__c>> numbersWithErrorMap  = new Map<String , List<Number__c>>();
        List<Number__c> validNumberList = new List<Number__c>();
        List<Number__c> invalidSourceSystemList = new List<Number__c>();
        
        for(Number__c num : numberList) {
            if(String.isNotBlank(num.Locked_By__c) && num.Locked_By__c.equalsIgnoreCase(sourceSystem)) {
                validNumberList.add(num);
            }
            else if ((String.isBlank(num.Locked_By__c) || !num.Locked_By__c.equalsIgnoreCase(sourceSystem))){
                invalidSourceSystemList.add(num);
            }
        }
        numbersWithErrorMap.put('valid', validNumberList);
        numbersWithErrorMap.put('invalidSourceSystem', invalidSourceSystemList);
        
        return numbersWithErrorMap;
    }
    
    /**************************************************************************************
****** Desc         : Method to get error for faulty number list
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static NumberInventoryResponse.errors getErrorMessage(List<String> numberList, string errorMessage){
        NumberInventoryResponse.errors err = new NumberInventoryResponse.errors();
        err.failure = 'numbers';
        err.value = String.join(numberList, ',');
        err.message = errorMessage;
        return err;
    }
    /**************************************************************************************
****** Desc         : Method to get error for faulty number list
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static NumberInventoryResponse.errors getErrorMessage(List<Number__c> numberList, string errorMessage){
        NumberInventoryResponse.errors err = new NumberInventoryResponse.errors();
        List<String> lst = new List<String>();
        for(Number__c num : numberList){
            lst.add(num.Service_Number__c);
        }
        err.failure = 'numbers';
        err.value = String.join(lst, ',');
        err.message = errorMessage;
        return err;
    }
    
    /**************************************************************************************
****** Desc         : Method to get list of numbers which not present in Number__c
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static List<String> getNumbersNotFound(Map<String, Number__c> numberList, List<string> requestedNumberList){
        List<String> numberNotFoundList = new List<String>();
        
        for(string reqNum : requestedNumberList){   
            boolean isPresent = false;
            if(String.isNotBlank(reqNum) && numberList.containsKey(reqNum)){
                isPresent = true;
            }
            if(!isPresent){
                numberNotFoundList.add(reqNum);
                
            }
        } 
        return numberNotFoundList;
    }
    /**************************************************************************************
****** Desc         : Method to lock/unlock numbers
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static NumberInventoryResponse lockUnlockNumbers(List<Number__c> numbersToProcess, string actionType, String lockedBy, string reason){
        List<Number__c> updateNumberList =  new List<Number__c>();
        
        switch on actionType.toLowerCase() {
            when 'lock' { //Lock Numbers
                for(Number__c lockedNumber : numbersToProcess){
                    lockedNumber.Status__c = numberStatusLocked;
                    lockedNumber.Locked_By__c = lockedBy;
                    lockedNumber.ReasonForLockUnlock__c = reason;
                    updateNumberList.add(lockedNumber);
                }
            }
            when 'unlock' { //Unlock Numbers
                for(Number__c unlockLockedNumber : numbersToProcess){
                    unlockLockedNumber.Status__c = numberStatusActive;
                    unlockLockedNumber.ReasonForLockUnlock__c = String.isNotBlank(reason) ? reason : defaultReasonForLockUnlock;
                    unlockLockedNumber.Locked_By__c = null;
                    updateNumberList.add(unlockLockedNumber);
                }
            }
        }
        
        if(updateNumberList.size()>0){
            try {
                update updateNumberList;
                response = prepareResponse(NumberInventory_Constants.SUCCESS_CODE_200,
                                           NumberInventory_Constants.OK_MSG,
                                           NumberInventory_Constants.NUMS_ARE+actionType+NumberInventory_Constants.ED,
                                           null);
            } catch (Exception ex) {
                logException('UpdateNumberInventoryHelper.lockUnlockNumbers', '', null, ex.getMessage(), actionType + NumberInventory_Constants.NUM_FAILED_EXCEP);
                response = prepareResponse(NumberInventory_Constants.ERROR_CODE_400,
                                           NumberInventory_Constants.UNABLE_TO+actionType,
                                           ex.getMessage(),
                                           null);
            }
        }
        return response;
    } 
    
    /**************************************************************************************
****** Desc         : Method to validate lock/unlock request
****** Story        : EDGE-214743
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static boolean validateLockUnlockRequest(NumberInventoryRequest request, string sourceSystem){
        String[] actionTypes = new string[] {'lock', 'unlock'};
            
            if(String.isBlank(request.actionType) || request.numbers.isEmpty() || String.isBlank(sourceSystem)) {
                return false;
            }
        
        if(!actionTypes.contains(request.actionType.toLowerCase())) {
            return false;
        }
        
        if(request.actionType.equalsIgnoreCase('lock') && String.isBlank(request.reason)) {
            return false;
        }
        //Added null check as part of DIGI-13056
        for(NumberInventoryRequest.numbers num : request.numbers) {
            if((num.singleNumbers != null && num.singleNumbers.isEmpty() && num.ranges != null && num.ranges.isEmpty()) ||
              (num.singleNumbers == null && num.ranges == null)) {
                return false;
            }
            if(num.ranges != null && !num.ranges.isEmpty()){
                for(NumberInventoryRequest.ranges rng : num.ranges){
                    if(String.isBlank(rng.startNumber) || String.isBlank(rng.endNumber)){
                        return false;
                    }
                }
            }
        }
        
        return true;
    }
    
    /**************************************************************************************
****** Desc         : Method to validate numbers in request
****** Story        : EDGE-214743
****** Developer    : Puneeth Kamath
***************************************************************************************/
    public static list<String> validateNumbers(List<NumberInventoryRequest.numbers> numbers){
        
        List<String> numbersList = new List<String>();
        for(NumberInventoryRequest.numbers num : numbers) {
            if(num.singleNumbers!=null && (!num.singleNumbers.isEmpty())){
                for(string n : num.singleNumbers) {
                    if(n.length() != 11 || (!n.startsWith('61')) || (!n.isNumeric())) {
                        numbersList.add(n);
                    } 
                }
            }
            if(num.ranges!=null && !num.ranges.isEmpty()){
                for(NumberInventoryRequest.ranges rng : num.ranges){
                    if(rng.startNumber.length() != 11 || (!rng.startNumber.startsWith('61')) || (!rng.startNumber.isNumeric())) {
                        numbersList.add(rng.startNumber);
                    }
                    if(rng.endNumber.length() != 11 || (!rng.endNumber.startsWith('61')) || (!rng.endNumber.isNumeric())) {
                        numbersList.add(rng.endNumber);
                    } 
                    if(rng.startNumber>rng.endNumber){
                        numbersList.add(rng.startNumber);
                        numbersList.add(rng.endNumber);
                    }
                }
            }
        }
        
        return numbersList;
    }
    /**************************************************************************************
****** Desc : Method to prepare rest response from NumberInventoryResponse data
****** Developer : Sonalisa Verma
***************************************************************************************/
    public static RestResponse getRestResponse(NumberInventoryResponse response, string correlationId){
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf(JSON.serialize(response,true));
        res.statusCode = Integer.valueOf(response.code);
        res.addHeader('Code', response.code);
        res.addHeader('Status', response.status);
        res.addHeader('correlationId', correlationId);
        res.addHeader('Content-Type', 'application/json');
        return res;
        
    }
    //Added as part of DIGI-14875
    public static NumberInventoryResponse.errors getErrorMessage(string errorMessage){
        NumberInventoryResponse.errors err = new NumberInventoryResponse.errors();
        err.message = errorMessage;
        return err;
    }
    //Added as part of DIGI-20192 to check subscription if networkserviceId is there.
    public static set<string> scQueryCreator(string networkId){
        set<string> subIdSet = new set<string>();
        List<string> statusList =  new List<String>{'Inactive','Cancelled','Replaced','Closed Replaced','CHOWN Replaced'}; 
        string querystring='select id,NetworkServiceId__c,csordtelcoa__Subscription_Number__c,csord__Order__c,csord__Status__c, (select Id, csordtelcoa__Service_Number__c from csord__Services__r) from csord__Subscription__c where NetworkServiceId__c = \'' +String.escapeSingleQuotes(networkId) + '\' and csord__Status__c NOT IN : statusList';
        subList = database.query(querystring);
        for(csord__Subscription__c sub : subList){
            subIdSet.add(sub.csordtelcoa__Subscription_Number__c);
            if (Test.isRunningTest()){
                subIdSet.add('012_34_567');
            }
            
        }
        return subIdSet;
        
    }
    
}