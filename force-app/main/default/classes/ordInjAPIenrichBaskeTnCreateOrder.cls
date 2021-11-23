/*********************************************************************************************************************************
Class Name: ordInjAPIenrichBaskeTnCreateOrder
Test Class: ordInjAPIenrichBaskeTnCreateOrderTest
Description:TON: EnrichBaske and CreateOrder api
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Arun V                 27-Sep-2021        DIGI-19570- TON: EnrichBasket and CreateOrder
2.        Arun V                 02-oct-2021        DIGI-9361- TON: EnrichBasket and CreateOrder
**********************************************************************************************************************************/
public class ordInjAPIenrichBaskeTnCreateOrder {
    public static final String HANDLER = 'basketEnrichment';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    public static RestResponse enrichBaskeTnCreateOrder(RestRequest request){
        Map<String,String> resultMap = new Map<String,String>();
        string correlationId;
        RestResponse finalRes;
        try{
            correlationId = ordInjAPICreateOrder.getCorrelationId(request);
            Map<String, object> cachedData = OC_SessionPayloadValidation.getSessionData(correlationId, 'basketEnrichment');
            String tbasket = ((String)cachedData.get('targetBasketId'));
            system.debug('cachedData+++'+ cachedData+tbasket);          
            Map<string, string> validationRes = validationController.validateRequest(correlationId, 'skipContract');
            if (validationRes.get('code') == '200'){
                /*cscfga__Product_Basket__c basket = [ SELECT id, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where id =: tbasket limit 1];
                if (basket != null){
                    basket.csordtelcoa__Basket_Stage__c = 'Enriched';
                }
                update basket;*/              
                createOrder(tbasket);
                resultMap.put('code','200');
                resultMap.put('status','Success');
                resultMap.put('correlationId',CorrelationId);
                resultMap.put('description','basket enrichment request successfully submitted. We will notify you once it is complete');
                
            }
            else {
                return OrderInjectionUtility.generateResponse(RestContext.response,validationRes , null);
            }
            
        }
        catch(exception ex){
            resultMap.put('code','500');
            resultMap.put('status','Failed');  
            resultMap.put('correlationId', CorrelationId);
            resultMap.put('description','Internal Server Error');
            system.debug('Exception occured in basketEnrichment:' + ex.getMessage() + 'Line' + ex.getLineNumber());
            logger.logMessages('basketEnrichment exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
            logger.exitLogger();
        }
        return OrderInjectionUtility.generateResponse(RestContext.response,resultMap , null);
    }
    @future
    public static void createOrder(Id tbasket){
        List<String> baskt = new list<String> {tbasket};
        if(!Test.isRunningTest())
        csordtelcoa.API_V1.generateOrdersFromBaskets(baskt, false);
    }
    //DIGI-9361
    public static void order_PlatformEvent(List<csord__Order__c> orderUpdatedList, set<Id> ordid){
        String correlationId;
        Map<Id, csord__Subscription__c> mapOrderSub = new Map<Id, csord__Subscription__c>();
        List<csord__Subscription__c> lstSubscription = [SELECT Id, csord__Order__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.correlation_id__c FROM csord__Subscription__c where csord__Order__c in : ordid and csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'];
        for(csord__Subscription__c sub : lstSubscription){
            mapOrderSub.put(sub.csord__Order__c, sub);
        }
        Map<String,String> jsonData = new Map<String,String>();
        List<Online_Ord_Journey__e> listOfPlatformEvent = new List<Online_Ord_Journey__e>(); 
        Online_Ord_Journey__e onlineOrd = new Online_Ord_Journey__e();	 
        for(csord__Order__c orderObj : orderUpdatedList) {
            if(mapOrderSub.containskey(orderObj.Id)){
                system.debug('inside order event');
                csord__Subscription__c orderSub = mapOrderSub.get(orderObj.Id);
                if(orderSub.csordtelcoa__Product_Configuration__c != null && orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null && orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c == 'TED-81 onlineAPI'){
                    correlationId = orderSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.correlation_id__c;
                    onlineOrd.API_name__c = 'basketEnrichment';
                    onlineOrd.CorrelationId__c = correlationId;
                    onlineOrd.API_Req_status__c = 'Completed';                    
		    	    jsonData.put('CorrelationId__c', correlationId);
                    jsonData.put('csord__Order_Number__c', orderObj.csord__Order_Number__c);
                    if(orderObj.csord__Status2__c.equalsIgnoreCase('Ready for Submit')){			 
                        jsonData.put('code','200');	
                        jsonData.put('status','Success');
                        jsonData.put('Order_Rec_Id', orderObj.Id);
                        jsonData.put('description','Order created successfully');
                        onlineOrd.API_Resp__c = JSON.serialize(jsonData);
                        OC_SessionPayloadValidation.addSessionData(correlationId, 'basketEnrichment', jsonData); 
            		    OC_SessionPayloadValidation.stepResult(correlationId, 'basketEnrichment' , true);
                    }else{
                        jsonData.put('code','500');
                        jsonData.put('status','Failed');
                        jsonData.put('Order_Rec_Id', '');
                        jsonData.put('description','Order Decomposition Failed');
                        onlineOrd.API_Resp__c = JSON.serialize(jsonData);
                    }
                    listOfPlatformEvent.add(onlineOrd);
                }
            }    
        }
        EventBus.publish(listOfPlatformEvent);
    }
}