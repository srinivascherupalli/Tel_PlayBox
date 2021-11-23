/*************************************************************************************************
Name : MockPublishPricingMSResponseHandler
EDGE-128910 : Building mock logic to mimic MS response in absence of stub/actual MS 
Description : Handler class for Trigger MockPublishPricingMSResponseTrigger
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya    16-Dec-2019     Created
===============================================================================================================================
***************************************************************************************************/

public with sharing class MockPublishPricingMSResponseHandler {
            
    public static void handleAllInsert(Set<String> corelationIdSet){
    mockResponse(corelationIdSet);
    }
    
    public static void handleAllUpdate(){
    //To handle all update scenarios
    }
        
    public static void mockResponse(Set<String> corelationIdSet){
        
    List<PriceScheduleEvent__e> priceScheduleEventListResponse = new List<PriceScheduleEvent__e>();        
    List<PricingMSResponseObject__c > pricingMSResponseObjectList = new List<PricingMSResponseObject__c >();
    boolean isInsertSuccessful = false;
        
    Map<String, List<String>> chargeLineItemIdCLiIdMap = new Map<String, List<String>>();
    chargeLineItemIdCLiIdMap = getChargeLineItemIdCLiIdMap(corelationIdSet);
        
    System.debug('chargeLineItemIdCLiIdMap after method call  '+chargeLineItemIdCLiIdMap);

    for(String cliCorelationId : chargeLineItemIdCLiIdMap.keySet()){
        List<String> chargeLineItemList =  chargeLineItemIdCLiIdMap.get(cliCorelationId);
        for(String cliId : chargeLineItemList){
            PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
            pricingMSResponse = generatePricingMSResponse(cliId, cliCorelationId);
            pricingMSResponseObjectList.add(pricingMSResponse);     
        }
    }
        String message ='';
    if(pricingMSResponseObjectList !=null && !pricingMSResponseObjectList.isEmpty()){
        Database.SaveResult[] resList =  Database.insert(PricingMSResponseObjectList, false);
            message = 'PricingMSResponseObjectList';
            isInsertSuccessful = checkRecordInsert(resList, message);
        
        
        if(isInsertSuccessful && chargeLineItemIdCLiIdMap.keySet() != null){
            
                for(String res : chargeLineItemIdCLiIdMap.keySet()){
                
                 PriceScheduleEvent__e eventResponse = new PriceScheduleEvent__e();
                 eventResponse.eventType__c = 'response';
                 eventResponse.CorrelationId__c = res;
                 
                 priceScheduleEventListResponse.add(eventResponse);
            }       
            
            Database.SaveResult[] eventResList =  EventBus.publish(priceScheduleEventListResponse);
            message = 'priceScheduleEventListResponse';
            isInsertSuccessful = checkRecordInsert(eventResList, message);          
        }       
    }        
 }
    
    public static PricingMSResponseObject__c generatePricingMSResponse(String cliId, String cliCorelationId){
        
                PricingMSResponseObject__c pricingMSResponse = null;
            if(!String.isBlank(cliId) && !String.isBlank(cliCorelationId)){
                String responsePayload = '{ "chargeLineItems": [ { "unitPrice__c": "80", "contractTerm__c": "24", "businessID__c": "123456", "unitTotalContractValue__c": "10", "priceScheduleLineItem": [ { "id": "PS1", "fromPeriod__c": "0", "toPeriod__c": "6", "unitPrice__c": "10", "applicableDiscounts": [ { "id": "disc001" }, { "id": "disc002" } ] } ] } ] }';
                pricingMSResponse = new PricingMSResponseObject__c();
                pricingMSResponse.CLI_Instance_ID__c= cliId;
                pricingMSResponse.ErrorDescription__c='';
                pricingMSResponse.Status__c='success';
                pricingMSResponse.TCV_Value__c= Integer.valueof((Math.random() * 100));
                pricingMSResponse.CorrelationId__c = cliCorelationId;
                pricingMSResponse.ResponsePayload__c = ResponsePayload;     
            }
                return pricingMSResponse;   
    }

    public static Map<String, List<String>> getChargeLineItemIdCLiIdMap(Set<String> corelationIdSet){
                
                Map<String, List<String>> chargeLineItemIdCLiIdMap = new Map<String, List<String>>();   
                System.debug('corelationIdSet inside method '+corelationIdSet);
                for(Charge_Line_Item__c chargeLineItem : [Select id, CorrelationId__c from Charge_Line_Item__c where CorrelationId__c in: corelationIdSet]){
                    System.debug('Inside getChargeLineItemIdCLiIdMap chargeLineItem '+chargeLineItem);
                    List<String> cliIdList =  new List<String>();
                    
                    if(!chargeLineItemIdCLiIdMap.containsKey(chargeLineItem.CorrelationId__c))
                        chargeLineItemIdCLiIdMap.put(chargeLineItem.CorrelationId__c, cliIdList);
                    cliIdList = chargeLineItemIdCLiIdMap.get(chargeLineItem.CorrelationId__c);
                    cliIdList.add(chargeLineItem.Id);
                    chargeLineItemIdCLiIdMap.put(chargeLineItem.CorrelationId__c, cliIdList);
                }
                    
                System.debug('chargeLineItemIdCLiIdMap Inside method   '+chargeLineItemIdCLiIdMap);     
                
                return chargeLineItemIdCLiIdMap;
                }
                
    private static boolean checkRecordInsert(Database.SaveResult[] resList, String message){
            
            List<boolean> isInsertSuccessful = new List<boolean>();
        
            for (Database.SaveResult sr : resList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug(message + 'inserted: ' + sr.getId());
                    //responseRecordId.add(sr.getId());
                    isInsertSuccessful.add(true);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred. in '+ message+' '+err.getStatusCode() + ': ' + err.getMessage()+'  '+'Response fields that affected this error: ' + err.getFields());                    
                    }
                isInsertSuccessful.add(false);
                }
            }   
        if(isInsertSuccessful == null || isInsertSuccessful.isEmpty() || isInsertSuccessful.contains(false)){
            return false;
        }
        else{
            return true;    
        }       
    }           
}