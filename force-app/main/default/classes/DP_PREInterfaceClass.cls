/**
* Class  PRE Interface.
*/
/********************************************************
Class Name      :   DP_PREInterfaceClass
Test Class : DP_PREInterfaceClass_Test
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Megha Bhardwaj        16/11/19        EDGE-114438
2. 			  Shivaprasad Patil	    02/07/21		Logic to add multiple DPR Offers to be updated
**********************************************************
*/
public with sharing class DP_PREInterfaceClass{
 
    @AuraEnabled 
    public static List<String> calloutToPREToGetDealScore(String DPRId, String corrId)
    {
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        String token = '';
        Map<string,Integration_Handler__mdt> credentialsMap = new Map<string,Integration_Handler__mdt>();
        string className  = DP_PREInterfaceClass.class.getName();
        Logger2 logger = Logger2.getLogger(className);
        Delegated_Pricing_Request__c dpr;
        String correlationId = '';
        String message = '';
        List<String> correlationAndMessageList = new List<String>();
        
        
        try{
            
            string classNameLIKE = className  + '%';
            List<Integration_Handler__mdt> credentialslist = [select DeveloperName, Client_Id__c, Client_Secret__c, End_Point__c, Grant_Type__c, Scope__c
                                                             from Integration_Handler__mdt where DeveloperName LIKE : classNameLIKE ];
                                                             
            if(null != credentialslist && credentialslist.size() >0){
            
                for(Integration_Handler__mdt cred : credentialslist){
                    credentialsMap.put(cred.DeveloperName,cred); 
                }
            } 
            if(null != credentialsMap){
                
                Integration_Handler__mdt credentials = new Integration_Handler__mdt();
                HttpRequest tokenRequest = new HttpRequest();
                
                if(credentialsMap.containsKey(className +'_AccessToken')){
                
                    credentials = credentialsMap.get(className +'_AccessToken');
                    tokenRequest.setEndpoint(credentials.End_Point__c);
                    tokenRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    tokenRequest.setBody('client_id=' + EncodingUtil.urlEncode(credentials.Client_Id__c, 'UTF-8') +
                                '&client_secret=' + EncodingUtil.urlEncode(credentials.Client_Secret__c, 'UTF-8') +
                                '&grant_type=' + EncodingUtil.urlEncode(credentials.Grant_Type__c, 'UTF-8') +
                                '&scope=' + EncodingUtil.urlEncode(credentials.Scope__c, 'UTF-8'));
                    
                    tokenRequest.setClientCertificateName(EnvironmentVariable.get('massl_certificate_name'));
                    tokenRequest.setMethod('POST');
                    response = http.send(tokenRequest);
                    //System.debug('Token response :'+response);
                    Map<String, String> result = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
                    token = result.get('access_token');
                    //System.debug('MASSL token :'+token);
                   
                }
                if(String.isNotBlank(token) && credentialsMap.containsKey(className)){
                 
                    correlationId = corrId;
                   
                    dpr = [Select Id, Name, Deal_Status__c, CorrelationId__c, Opportunity__r.Opportunity_Number__c  from Delegated_Pricing_Request__c where Id = : dprId ];
                    String requestBody = 'OpportunityNumber=' + EncodingUtil.urlEncode(dpr.Opportunity__r.Opportunity_Number__c,'UTF-8') +
                                '&DNumber=' + EncodingUtil.urlEncode('123456','UTF-8') +
                                '&DPRName=' + EncodingUtil.urlEncode(dpr.Name,'UTF-8'); //Dnumber will be removed 
                                         
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer ' + token,'correlationId' => correlationId};
                    HttpResponse adResponse = IntegrationRecordHandlerUtil.calloutSync(requestBody, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, className) ;
                    system.debug('Please remove this debugger  ###'+adResponse);

                    ResponseDetail responseDetails =  (ResponseDetail) JSON.deserialize(adResponse.getBody(), ResponseDetail.class);
                    
                    if(responseDetails.code == '200 OK'){
                        message = CorrelationId; 
                        correlationAndMessageList.add(responseDetails.transactionId);
                        correlationAndMessageList.add(responseDetails.message); 
                    }else{ 
                    
                         logger.logMessages('', '', responseDetails.message, 'Technical', 'Exception', responseDetails.message, false, false);
                         correlationAndMessageList.add('');
                         correlationAndMessageList.add(responseDetails.moreInfo);
                    }
                }
            }
        }catch(Exception ex){ 
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            correlationAndMessageList.add('');
            correlationAndMessageList.add('Something went wrong...Please Contact your System Administrator!');
        }
        
        finally{
            logger.exitLogger();
            if(dpr != null && string.isNotBlank(correlationId)){
                dpr.CorrelationId__c = correlationId;
                dpr.Deal_Status__c = 'Pending';
                update dpr;
            }
        }
        return correlationAndMessageList;  
    }
    @AuraEnabled
    public static String mapJSONToObjects(String DPRRecord, String DPROffer, String DPROfferLineItem, String DPRDelegationOutcome, String DPRGBBReportDetail){
    
        
        String returnMessage = '';  
        
        if(string.isNotBlank(DPRRecord) && string.isNotBlank(DPROffer) && string.isNotBlank(DPROfferLineItem) && 
        
            string.isNotBlank(DPRDelegationOutcome) && string.isNotBlank(DPRGBBReportDetail)){
            try{
                
                returnMessage  = deserializeSerializeJSON(DPROffer,DPR_Offer__c.class);
                returnMessage  = deserializeSerializeJSON(DPRDelegationOutcome,DPR_Delegation_Outcome__c.class);
                returnMessage  = deserializeSerializeJSON(DPROfferLineItem,DPR_Offer_Line_Item__c.class);
                returnMessage  = deserializeSerializeJSON(DPRGBBReportDetail,DPR_GBB_Report_Detail__c.class);
                returnMessage =  deserializeSerializeJSON(DPRRecord,Delegated_Pricing_Request__c.class);
               
            }catch(Exception ex){
                system.debug('exception occurred ###'+ex);
                returnMessage = 'Something went wrong...Please Contact your System Administrator!';  
            }
         }
         system.debug('returnMessage ###'+returnMessage);
         return returnMessage;
    }
    @AuraEnabled
    public static String deserializeSerializeJSON(string JSONToBeSerialized, System.Type sObjectName){
          
        String returnMessage = '';
        system.debug('JSONToBeSerialized ###'+JSONToBeSerialized);  
        String objectName = sObjectName.getName();
        
        if(objectName == 'DPR_Offer_Line_Item__c' || objectName == 'DPR_Delegation_Outcome__c' || objectName == 'DPR_GBB_Report_Detail__c' || objectName == 'DPR_Offer__c'){
            
            List<SObject> customObjectList = new List<SObject>();
            
            if(objectName == 'DPR_Offer_Line_Item__c'){
                
                customObjectList = (List<SObject>)JSON.deserialize(JSONToBeSerialized,List<DPR_Offer_Line_Item__c>.class);
            }else if(objectName == 'DPR_Delegation_Outcome__c'){
                
                customObjectList = (List<SObject>)JSON.deserialize(JSONToBeSerialized,List<DPR_Delegation_Outcome__c>.class);
            }else if(objectName == 'DPR_GBB_Report_Detail__c'){
                
                customObjectList = (List<SObject>)JSON.deserialize(JSONToBeSerialized,List<DPR_GBB_Report_Detail__c>.class);
            }else if(objectName == 'DPR_Offer__c'){
                
                customObjectList = (List<SObject>)JSON.deserialize(JSONToBeSerialized,List<DPR_Offer__c>.class);
            }
            
            //System.debug('custom object list ### '+customObjectList);
            if(customObjectList.size()>0){
                upsert customObjectList;  
            }   
            
        }else{
            
            Map<String, Object> cObjMapDeserialised = (Map<String, Object>) JSON.deserializeUntyped(JSONToBeSerialized);
            //System.debug('cObjMapDeserialised ### '+cObjMapDeserialised);
            
            String cObjJsonSerialised = JSON.serialize(cObjMapDeserialised);
            //system.debug('cObjJsonSerialised ###'+cObjJsonSerialised);
            
            SObject customObject = (SObject)JSON.deserialize(cObjJsonSerialised, sObjectName);
            //System.debug('custom object ### '+customObject);
            update customObject;
        } 
        return 'SUCCESS';  
        
    }
    
    public class ResponseDetail{
    
        @AuraEnabled public string code;
        @AuraEnabled public string statusCode;
        @AuraEnabled public string message;
        @AuraEnabled public string moreInfo;
        @AuraEnabled public string transactionId;
        
        public responseDetail(){
        
            code = '';
            statusCode = '';
            message = '';
            moreInfo = '';
            transactionId = '';
        }
    }
}