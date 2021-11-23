/*
* @Author  : Mukta Wadhwani
* @Date    : 30-03-2021
* @Desc    : This class is a controller for RemoveNumberNGUC web component.

* @Jira    : EDGE-208205
@ Jira      :DIGI-35918
************************************************************************
1.Pawan Devaliya       08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
***************************************************************************************************
*/
public with sharing class RemoveNumberNGUCController {
    //This method returns the number wrapper in case of onscreen retrival.
    private static final String CONST_INTERFACENAME = 'RemoveNumberNGUCController';
    private static String correlationId = GuidUtil.NewGuid();
    
    @AuraEnabled
    public static List<NumberWrapper> fetchNumbers(string searchKey,List<String> subscriptionIdList) {
        List<NumberWrapper> wrapList = new List<NumberWrapper>();
        List<Number__c> numberList = new List<Number__c>();  
        List<Number__c> rangeNumberList = new List<Number__c>();
        List<String> subNumberList = new List<String>();
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
        for(Number__c numberObj : [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Number_Range__c,Mobile__c,Pattern_Type__c from Number__c where Service_Number__c =: numberNameList and Subscription_number__c=:subNumberMap.keySet() and Status__c='Active' ORDER BY Service_Number__c ASC]){
            NumberWrapper wrapObj = new NumberWrapper();
            wrapObj.numberId = numberObj.Id;
            wrapObj.phoneNumber = numberObj.Service_Number__c;
            wrapObj.status = numberObj.status__c;
            wrapObj.eligibilityStatus = 'Eligible';
            wrapObj.isPreHash75FeatureAvailable = false;
            wrapObj.numberRange = numberObj.Number_Range__c;
            wrapObj.numberType = (numberObj.Mobile__c=='Mobile' && numberObj.Pattern_Type__c=='Number')?'Number':'Number Group';
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
        List<Number__c> rangeNumberList = new List<Number__c>();
        List<String> invalidNumberList = new List<String>();
        Map<String,csord__Subscription__c> subNumberMap = new Map<String,csord__Subscription__c>();
        Map<String,Set<Number__c>> validateNumberMap = new Map<String,Set<Number__c>>();
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
        
        for(Number__c numberObj : [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Number_Range__c from Number__c where Service_Number__c =: phoneNumberList  and Subscription_number__c=:subNumberMap.keySet() and Status__c='Active' ORDER BY Service_Number__c ASC]){
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
        return wrapList;
    }
    //Method Ends
    //This method creates Order, Number Group records and associate numbers to new number group,DIGI-35918
    @AuraEnabled
    public static String createOrderAndRemoveNumbers(String selectedNumberString,String accountId,List<String> subscriptionIdList,String contactId){
        
        List<Number__c> numberUpdateList = new List<Number__c>();
        csord__Order__c orderObj = new csord__Order__c();
        Map<String,List<String>> subscriptionNumberMap = new Map<String,List<String>>();
        Map<String,String> subscriptionNumberGroupMap = new Map<String,String>();
        List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
        List<String> phoneNumberList = new List<String>();
        List<String> subIDList = new List<String>();
        String orderNumber = '';
        try{
            if(String.isBlank(selectedNumberString)){
               return system.label.MACD_Add_order_error_msg;
                
            }

            orderObj = createOrderForSelectedNumbers(selectedNumberString,accountId,contactId);
            User userObj = [select id,Name,ContactId,Profile.Name,Contact.AccountId,Contact.Account.CWP_Eligible_Partner__c from User where id =: userInfo.getUserId()];   
            if(Label.PRM_Community_User_Profile.contains(userObj.Profile.Name)){
                return PRMBaseURLUtility.getBaseURLForCommunityUser()+'/'+orderObj.Id;
            }
            return System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id;  
        }   
        catch(Exception e){
            NumberReservationHelper.logException('createOrderAndRemoveNumbers','',correlationId, e.getMessage(), 'Create order number group and update numbers.',CONST_INTERFACENAME);
            return system.label.MACD_Add_order_error_msg;
        }
    }
    //Method Ends.
    //This method is creating order and number group records for selected numbers, added DIGI-35918
    
    public static csord__Order__c createOrderForSelectedNumbers(String selectedNumberString,String accountId,String contactId){
        List<Number__c> numberUpdateList = new List<Number__c>();
        csord__Order__c orderObj = new csord__Order__c();
        Map<String,List<String>> subscriptionNumberMap = new Map<String,List<String>>();
        List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
        Set<String> iotSubs=new Set<String>();
        NumberWrapper[] numberWrapperList = (NumberWrapper[])JSON.deserialize(selectedNumberString, List<NumberWrapper>.class);
        orderObj.Name  = numberWrapperList[0].parentOrderNumber+'_MACD_Order';
        orderObj.csord__Status2__c  = 'Order Submitted';
        orderObj.csord__Account__c = accountId;
        orderObj.Scenario_Type__c = numberWrapperList[0].numberType == 'Number'?null:'Manage Fixed Numbers';
        orderObj.csord__Identification__c = numberWrapperList[0].parentOrderNumber+'_MACD_Order';
        orderObj.Order_Requester__c = contactId;
        insert orderObj;
        for(NumberWrapper wrapObj : numberWrapperList){
            
            if(subscriptionNumberMap != null && !subscriptionNumberMap.containsKey(wrapObj.subscriptionNumber)){
                subscriptionNumberMap.put(wrapObj.subscriptionNumber,new List<String>());
            }
            subscriptionNumberMap.get(wrapObj.subscriptionNumber).add(wrapObj.numberId);
            if(wrapObj.numberType == 'Number'){
                iotSubs.add(wrapObj.subscriptionNumber);
            }
        }
        if(subscriptionNumberMap != null && !subscriptionNumberMap.keySet().isEmpty()){
           
            for(String nameObj : subscriptionNumberMap.keySet()){
                Number_Group__c numberGroupObj = new Number_Group__c(); 
                numberGroupObj.OrderId__c = orderObj.Id;
                numberGroupObj.Scenario_Type__c = 'Remove';
                if(iotSubs.contains(nameObj)){
                    numberGroupObj.Pattern_Type__c = 'Number';
                    numberGroupObj.Total_Numbers_Reserved__c = subscriptionNumberMap.get(nameObj).size();
                }else{
                    numberGroupObj.Pattern_Type__c = 'Number Group';
                }
                numberGroupObj.RequestedCompletionDate__c =  Datetime.now();
                numberGroupObj.Subscription_Number__c = nameObj;
                numberGroupList.add(numberGroupObj);
            }
            insert numberGroupList;
            for(Number_Group__c groupObj : numberGroupList){
                if(subscriptionNumberMap.containsKey(groupObj.Subscription_Number__c) && subscriptionNumberMap.get(groupObj.Subscription_Number__c) != null){
                    for(String numberIdObj : subscriptionNumberMap.get(groupObj.Subscription_Number__c)){
                        Number__c numberObj = new Number__c();
                        numberObj.Number_Group__c = groupObj.Id;
                        numberObj.Id = numberIdObj.contains('-') ? numberIdObj.split('-')[0] : numberIdObj;
                        numberUpdateList.add(numberObj);
                    }
                }                
                
            }
            
            if(!numberUpdateList.isEmpty()){
                update numberUpdateList;
            }
        }
        return orderObj;
    }
    //Method Ends
    

    //This Method change the status of order to submitted and number group and number to Disconnect Pending and publish the event.
    @AuraEnabled
    public static void submitOrder(String orderRecordId){
        Set<Number_Group__c> groupUpdateSet = new Set<Number_Group__c>();
        List<Number_Group__c> groupUpdateList = new List<Number_Group__c>();
        List<Number__c> numberUpdateList = new List<Number__c>();
        Set<String> iotSubs = new Set<String>();
        try{
            if(String.isBlank(orderRecordId)){
                return;
            }
            //DIGI-18183
            csord__Order__c orderRecord = [select id,csord__Account__r.CIDN__c,csord__Status__c,csord__Order_Number__c, Fulfilment_Order_Version__c from csord__Order__c where Id=:orderRecordId];
			//DIGI-32827 Changes
			orderRecord.csord__Start_Date__c = Date.today();
			orderRecord.telstra_ord_Start_DateTime__c = System.now();
            orderRecord.csord__Status__c = 'Submitted'; 
            update orderRecord;
            for(Number__c numberObj : [select id,Name,Status__c,Number_Group__r.Scenario_Type__c,Number_Group__r.Status__c,Number_Group__c,Subscription_Number__c,Mobile__c,Pattern_Type__c from Number__c where Number_Group__r.OrderId__c=:orderRecordId]){
                Number_Group__c groupObj = new Number_Group__c(Id = numberObj.Number_Group__c);
                /*Commenting this logic for future considerations.
                groupObj.Status__c = !FeatureEligibilityChecker.determineFeatureEligiblity('O2ANotificationProcessing','O2ANotifications') ? 'Active' : 'Disconnect Pending' ;*/
                groupObj.Status__c = 'Disconnect Pending';
                groupUpdateSet.add(groupObj);
                /*Commenting this logic for future considerations.
                if(FeatureEligibilityChecker.determineFeatureEligiblity('O2ANotificationProcessing','O2ANotifications')){
                    numberObj.Status__c = 'Disconnect Pending' ;
                    numberUpdateList.add(numberObj);
                }*/
                numberObj.Status__c = 'Disconnect Pending' ;
                numberUpdateList.add(numberObj);
                if(numberObj.Mobile__c=='Mobile' && numberObj.Pattern_Type__c=='Number'){
                    iotSubs.add(numberObj.Subscription_Number__c);
                }

            }
            if(iotSubs.size()>0){
                List<csord__Service__c> servsToReparent = new List<csord__Service__c>();
                List<csord__Subscription__c> subsToReparent =[SELECT id,csord__Order__c,(SELECT id,csord__Order__c FROM csord__Services__r) FROM csord__Subscription__c where csordtelcoa__Subscription_Number__c IN :iotSubs];
                for(csord__Subscription__c sub:subsToReparent){
                    for(csord__Service__c serv:sub.csord__Services__r){
                        serv.csord__Order__c=orderRecordId;
                        servsToReparent.add(serv);
                    }
                    sub.csord__Order__c=orderRecordId;
                }
            update subsToReparent;
            update servsToReparent;
            }
            if(!groupUpdateSet.isEmpty()){
                groupUpdateList.addAll(groupUpdateSet);
                
                update groupUpdateList;
            }
            if(!numberUpdateList.isEmpty()){
                update numberUpdateList;
            }
            //DIGI-18183
            NumberReservationHelper.publishPlatformEvents(orderRecord.Id,orderRecord.csord__Order_Number__c,orderRecord.csord__Account__r.CIDN__c, orderRecord.Fulfilment_Order_Version__c);
        }
        catch(Exception e){
            NumberReservationHelper.logException('submitOrder','',correlationId, e.getMessage(), 'Submit order and fire platform events.',CONST_INTERFACENAME);
            
            
        }
        
    }
    //This method is to check for eligibility before hash75 feature enabled
    @AuraEnabled
    public static List<NumberWrapper> featureTogglingCheckEligibility(List<Number__c> rangeNumberList,List<NumberWrapper> wrapList){
        List<String> invalidNumberList = new List<String>();
        if(FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement','PreHash75')){
            Map<String,List<Number__c>> numbersWithErrorMap = UpdateNumberInventoryHelper.validateNumbersPartOfRange(rangeNumberList);
        
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
    @AuraEnabled
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
        @AuraEnabled public String numberType;
    }
    
    
    
}