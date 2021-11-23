/**
* @Story            : EDGE-207626
* @Author           : Arinjay Singh
* @Description      : Validate API before Order Injection.
* @Date             : 13-April-2021
*/
public class OrdInjAPIDataValidator {
    private static final String VALIDATE_DATA = 'validateData';
    public RestResponse validateData(RestRequest request){
        Map<String, Object> dataMap = null;
        List<Map<String, Object>> servicesList = new List<Map<String, Object>>();
        try
        {
            String jsonString = request.requestBody.toString().replaceAll('^\\p{IsWhite_Space}+|\\p{IsWhite_Space}+$','');
            System.debug('jsonString '+jsonString);
            jsonString = jsonString.normalizeSpace();
            dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            for (String key : dataMap.keySet())
            {
                if(key.equalsIgnoreCase('services')){
                    List<Map<String, Object>> data = new List<Map<String, Object>>();
                    for (Object instance : (List<Object>)dataMap.get(key))
                    {
                        servicesList.add((Map<String, Object>)instance);
                    }
                }
            }
        
            // Populating Map for calling validation method
            Map<String,String> inputMap = new Map<String,String>();
            inputMap.put('CorrelationId__c',(String)dataMap.get('CorrelationId__c'));
            inputMap.put('AccountId__c',(String)dataMap.get('AccountId__c')); 
            inputMap.put('ActionType__c',(String)dataMap.get('ActionType__c'));
            inputMap.put('Reason__c',(String)dataMap.get('Reason__c'));
            inputMap.put('ReferenceNumber__c',(String)dataMap.get('ReferenceNumber__c'));
            inputMap.put('OwnerId__c',(String)dataMap.get('OwnerId__c'));
            inputMap.put('services',JSON.serialize(servicesList));
            // call to validation method : validateMasterData
           // DIGI-8102 BY Rajiv
            List<ConstantMetadataUtility__mdt> actionTypeList = new List<ConstantMetadataUtility__mdt>([select Value__c,MasterLabel from ConstantMetadataUtility__mdt WHERE MasterLabel IN ('Action Type 1','Action Type 2')]);
            Map<String,String> actionTypeMap = new Map<String,String>();
            for(ConstantMetadataUtility__mdt actionType :actionTypeList){
                actionTypeMap.put(actionType.MasterLabel,actionType.Value__c);
            }
            // DIGI-8102 BY Rajiv
            system.debug('actionTypeMap '+actionTypeMap);
            system.debug('inputMap '+inputMap);
            if(inputMap.get('ActionType__c') == actionTypeMap.get('Action Type 1') || inputMap.get('ActionType__c') == actionTypeMap.get('Action Type 2')){
                validationController validationControllerObj = new validationController();
                System.debug('inputMap '+inputMap);
                Map<String,String> resultMap = validationControllerObj.validateTONData(inputMap);
                return OrderInjectionUtility.generateResponse(RestContext.response, resultMap, null); 
            }else{
                validationController validationControllerObj = new validationController();
                System.debug('inputMap '+inputMap);
                Map<String,String> resultMap = validationControllerObj.validateMasterData(inputMap);
                System.debug('resultMap '+resultMap);
                switch on resultMap.get('code') {
                    when '200' {
                        Map<String,String> inputServicesMap = new Map<String,String>();
                        inputServicesMap.put('serviceMSISDN__c',JSON.serialize(servicesList));
                        // service validation
                        Map<String,String> resultMap1 = validationControllerObj.validateServicesData(inputServicesMap);
                        System.debug('resultMap1 '+resultMap1);
                        switch on resultMap1.get('code') {
                            when '200' {
                                String CIDN_No =  (String)dataMap.get('AccountId__c');
                                List<Account> accList = [SELECT Id,CIDN__c,cscfga__Active__c FROM Account WHERE (Customer_Status__c ='ACTIVE' OR Customer_Status__c ='ACQUIRED') AND CIDN__c=:CIDN_No LIMIT 1];
                                String accountId = '';
                                if(accList.size() == 1){
                                    accountId = accList.get(0).Id;
                                }
                                system.debug('accountId'+ accountId);
                                String fedId = (String)dataMap.get('OwnerId__c');
                                String ownerId = '';
                                if(String.isEmpty(fedId)){
                                    ownerId = UserInfo.getUserId();
                                }
                                else{
                                    List<User> userList = [SELECT id, name, FederationIdentifier, P_Number__c FROM User WHERE FederationIdentifier =:fedId LIMIT 1];
                                    if(userList.size() == 1){
                                        ownerId = userList.get(0).Id;
                                    }
                                }
                                
                                String correlationId = (String)dataMap.get('CorrelationId__c');
                                resultMap1.put('correlationId',correlationId);
                                Map<String,String> sessionMap = inputMap.clone();
                                sessionMap.put('AccountId__c',accountId);
                                sessionMap.put('OwnerId__c',ownerId);
                                sessionMap.put('validateData','Success');
                                sessionMap.put('services',JSON.serialize(servicesList));
                                system.debug('sessionMap'+ sessionMap);
                                OC_SessionPayloadValidation.createSession(correlationId, 'validateData', this);
                                OC_SessionPayloadValidation.addSessionData(correlationId, 'validateData', sessionMap);
                                OC_SessionPayloadValidation.stepResult(correlationId, VALIDATE_DATA, true);
                                return OrderInjectionUtility.generateResponse(RestContext.response, resultMap1, null); 
                            }when '400' , '422' {
                                return OrderInjectionUtility.generateResponse(RestContext.response, resultMap1, null); 
                            }
                        }
                    }when '400' , '422' {
                        return OrderInjectionUtility.generateResponse(RestContext.response, resultMap, null); 
                    }
                }
            }
        }
        catch(Exception e)
        {
            Logger2 logger = Logger2.getlogger('OrderInjectionApiController');
            logger.logMessages('', '', '', 'Technical', 'Exception','Check' + e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
        }
        return null;
    }
}