/*
* @Author  : Kanhaiya Pasoria
* @Date    : 12-05-2021
* @Desc    : This class is a controller for LockNumberNGUC web component.

* @Jira    : EDGE-205907
*/
public with sharing class locknumberNGUCController {
    //This method returns the number wrapper in case of onscreen retrival.
    private static final String CONST_INTERFACENAME = 'lockNumberNGUCController';
    private static String correlationId = GuidUtil.NewGuid();

    @AuraEnabled(cacheable=true)
    public static List<NumberWrapper> fetchNumbers(string searchKey,List<String> subscriptionIdList) {
        system.debug('subscriptionIdList'+subscriptionIdList);
        List<NumberWrapper> wrapList = new List<NumberWrapper>();
        List<Number__c> numberList = new List<Number__c>();  
        List<String> subNumberList = new List<String>();
        List<Number__c> rangeNumberList = new List<Number__c>();
        Map<String,csord__Subscription__c> subNumberMap = new Map<String,csord__Subscription__c>();
        Map<String,Set<String>> validateNumberMap = new Map<String,Set<String>>();
        List<String> invalidNumberList = new List<String>();

        
        if(String.isBlank(searchKey) || subscriptionIdList == null){
            return wrapList;
        }  
        
        for(csord__Subscription__c subObj : [select csordtelcoa__Subscription_Number__c,customerFacingServiceId__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where Id=:subscriptionIdList and csord__Status__c='Active' ]){
            subNumberMap.put(subObj.csordtelcoa__Subscription_Number__c,subObj);
        }
        if(subNumberMap.isEmpty()){
            return wrapList;
        }
        List<String> numberNameList = searchKey.split(','); 
        for(Number__c numberObj : [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Number_Range__c from Number__c where Service_Number__c =: numberNameList and Subscription_number__c=:subNumberMap.keySet() and Status__c='Active']){
            NumberWrapper wrapObj = new NumberWrapper();
            wrapObj.numberId = numberObj.Id;
            wrapObj.phoneNumber = numberObj.Service_Number__c;
            wrapObj.status = numberObj.status__c;
            wrapObj.eligibilityStatus = 'Eligible';
            wrapObj.isPreHash75FeatureAvailable = false;
            wrapObj.numberRange = numberObj.Number_Range__c;
            wrapObj.cfsId = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).customerFacingServiceId__c : '';
            wrapObj.parentOrderNumber = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).csord__Order__r.csord__Order_Number__c : '';
            wrapObj.subscriptionNumber = numberObj.Subscription_number__c;
            if(numberObj.Number_Range__c != '-'){
                rangeNumberList.add(numberObj);
            }   
            wrapObj.cfsId = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).customerFacingServiceId__c : '';
            wrapObj.parentOrderNumber = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).csord__Order__r.csord__Order_Number__c : '';
            wrapObj.subscriptionNumber = numberObj.Subscription_number__c;
            wrapList.add(wrapObj);   
        }
        wrapList = featureTogglingCheckEligibility(rangeNumberList,wrapList);       

        return wrapList;
        
        
        
    }
    //Mehtod ends.

    //This method return numbers fron CSV upload.
    @AuraEnabled
    
    public static List<NumberWrapper> fetchNumberFromCSV(List<String> subscriptionIdList,String csvJson){
        List<NumberWrapper> wrapList = new List<NumberWrapper>();
        List<String> phoneNumberList = new List<String>();
        List<String> subNumberList = new List<String>();
        List<String> invalidNumberList = new List<String>();
        List<Number__c> rangeNumberList = new List<Number__c>();
        Map<String,csord__Subscription__c> subNumberMap = new Map<String,csord__Subscription__c>();
        Map<String,Set<String>> validateNumberMap = new Map<String,Set<String>>();
        String data = JSON.deserializeUntyped(csvJson).toString();
        String[] csvFileLines = data.split('\n'); 
        for(Integer i = 1 ; i < csvFileLines.size() ; i++){
            String[] rowData = csvFileLines[i].split(',');
            String numberValue = rowData[0].trim();
            phoneNumberList.add(numberValue.replaceAll('"', ''));
        }
        
        for(csord__Subscription__c subObj : [select csordtelcoa__Subscription_Number__c,customerFacingServiceId__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where Id=:subscriptionIdList and csord__Status__c='Active']){
            
            subNumberMap.put(subObj.csordtelcoa__Subscription_Number__c,subObj);
        }
        if(subNumberMap.isEmpty()){
            return wrapList;
        }
        list<Number__c> numberListFromCSV = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Number_Range__c from Number__c where Service_Number__c =: phoneNumberList  and Subscription_number__c=:subNumberMap.keySet() and Status__c='Active' ];
        system.debug('numberListFromCSV---'+numberListFromCSV);
        for(Number__c numberObj : [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Number_Range__c from Number__c where Service_Number__c =: phoneNumberList  and Subscription_number__c=:subNumberMap.keySet() and Status__c='Active' ]){
            NumberWrapper wrapObj = new NumberWrapper();
            
            wrapObj.numberId = numberObj.Id;
            wrapObj.phoneNumber = numberObj.Service_Number__c;
            wrapObj.status = numberObj.status__c;
            wrapObj.eligibilityStatus = 'Eligible';
            wrapObj.isPreHash75FeatureAvailable = false;
            wrapObj.numberRange = numberObj.Number_Range__c;
            if(numberObj.Number_Range__c != '-'){
                rangeNumberList.add(numberObj);
            }
            wrapObj.cfsId = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).customerFacingServiceId__c : '';
            wrapObj.parentOrderNumber = subNumberMap.containsKey(numberObj.Subscription_number__c) ? subNumberMap.get(numberObj.Subscription_number__c).csord__Order__r.csord__Order_Number__c : '';
            wrapObj.subscriptionNumber = numberObj.Subscription_number__c;
            wrapList.add(wrapObj);   
        }

        wrapList = featureTogglingCheckEligibility(rangeNumberList,wrapList);

        system.debug('wrapList'+wrapList);
        return wrapList;
    }
    //Method Ends
    //This is controller method for locking All Numbers / Selected Numbers
    @AuraEnabled
    public static String lockNumbers(String selectedNumberString,String accountId,List<String> subscriptionIdList,String csvJson){
        
        List<Number__c> numberUpdateList = new List<Number__c>();
        csord__Order__c orderObj = new csord__Order__c();
        Map<String,List<String>> subscriptionNumberMap = new Map<String,List<String>>();
        Map<String,String> subscriptionNumberGroupMap = new Map<String,String>();
        List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
        List<String> phoneNumberList = new List<String>();
        List<String> subIDList = new List<String>();
        String orderNumber = '';
        try{
            
            //Create order for all numbers from CSV Import
            if(String.isBlank(selectedNumberString)){
                return system.label.MACD_Lock_number_error_msg;
                
            }
            //create order for selected numbers from Search Retrival
            else{
                lockSelectedNumbers(selectedNumberString,accountId);
            }
            return system.label.MACD_Lock_confirm_msg; 
        }   
        catch(Exception e){
            NumberReservationHelper.logException('lockNumbers','',correlationId, e.getMessage(), 'number not locked successfully.',CONST_INTERFACENAME);
            return system.label.MACD_Lock_number_error_msg;
        }
    }
    //Method Ends.

    //This method is for locking selected numbers
    public static void lockSelectedNumbers(String selectedNumberString,String accountId){
        system.debug(accountId+'  accountId');
        List<Number__c> numberUpdateList = new List<Number__c>();
        csord__Order__c orderObj = new csord__Order__c();
        Map<String,List<String>> subscriptionNumberMap = new Map<String,List<String>>();
        List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
        List<String> phoneNumberlist = new list<String>();
        List<Number__c> locknumberlist = new list<Number__c>();
        NumberWrapper[] numberWrapperList = (NumberWrapper[])JSON.deserialize(selectedNumberString, List<NumberWrapper>.class);
        
        for(NumberWrapper wrapObj : numberWrapperList){
            phoneNumberlist.add(wrapObj.phoneNumber);
        }
        for(Number__c numberObj : [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Locked_By__c,
        Number_Range__c from Number__c where Service_Number__c =: phoneNumberList ]){

            numberObj.status__c = 'Locked';
            numberObj.Locked_By__c='Phoenix UI';
            locknumberlist.add(numberObj);
        
        }
        if(!locknumberlist.isEmpty()){
            update locknumberlist;
        }
    }
    //Method Ends

    //Feature Eligibility Checker
    @AuraEnabled
    public static List<NumberWrapper> featureTogglingCheckEligibility(List<Number__c> rangeNumberList,List<NumberWrapper> wrapList){
        system.debug('wrapList'+wrapList);
        List<String> invalidNumberList = new List<String>();
        if(FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement','PreHash75')){
            system.debug('inside feature toggeling');
            Map<String,List<Number__c>> numbersWithErrorMap = validateNumbersPartOfRange(rangeNumberList);
        
        for(Number__c numberObj : numbersWithErrorMap.get('invalid')){
            invalidNumberList.add(numberObj.Service_Number__c);
        }

        for(NumberWrapper wrapObj : wrapList){
            wrapObj.isPreHash75FeatureAvailable = true;
            if(invalidNumberList.contains(wrapObj.phoneNumber)){
                wrapObj.eligibilityStatus = 'Ineligible';
            }
        }
    }
    return wrapList;
    }
    /**************************************************************************************
    ****** Desc         : Method to validate all the numbers of the range are present in lock request
    ****** Story        : EDGE-214743. Duplicate Method
                          since 1636 is yet to be deployed and dependencies cannot be resolved.
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

    //Method Ends

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

    public class NumberWrapper {
        
        
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String numberId;
        @AuraEnabled public String cfsId;
        @AuraEnabled public String parentOrderNumber;
        @AuraEnabled public String subscriptionNumber;
        @AuraEnabled public String eligibilityStatus;
        @AuraEnabled public String numberRange;
        @AuraEnabled public Boolean isPreHash75FeatureAvailable;
    }
}