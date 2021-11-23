public with sharing class ManageOrderService {
    
    public static Integer VERSION = 1;
    public static final String APPLICATION = 'CloudSense';
    public enum Action {CREATE, AMEND, CANCEL} 
    public enum SubAction {PR, CE, CH, NE} // PROVIDE, CEASE, CHANGE, NO EFFECT
    public static final String HANDLERNAME = 'ManageOrderSumbitHandler';
    public static Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();

    public static Map<Id, String> buildManageOrderPayload(List<Id> orderIds){
        Map<Id, String> orderPayloadMap = new Map<Id, String>();
        /*added for EDGE-71655*/
        Map<String,String> transientDTOJSON = ManageOrderServiceUtilityHelper.getTransientDTOJSON(orderIds);
        Map<String,Map<String,String>> guidToTransientAttributesMap = new Map<String,Map<String,String>>();
        for(String transientAttStr : transientDTOJSON.values()){guidToTransientAttributesMap = ManageOrderServiceUtilityHelper.getTransientAttributesMap(transientAttStr);
        }
        if(!orderIds.isEmpty()){
            // added for 65707 :: 19.4 :: 14/3/2019 :: 
        //Start
          Map<String, Contact> serviceDeliveryContactMap = ManageOrderServiceUtilityHelper.getDeliveryContactsForMobility(orderIds);
        //End
        	System.debug('serviceDeliveryContactMap:::'+serviceDeliveryContactMap);
            Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>();
            //Fetch parent and sub orders
            Map<Id, csord__Order__c> subOrderMap = ManageOrderServiceHelper.fetchAllOrders(orderIds);
            srvcMap = ManageOrderServiceHelper.getOderDetails(new List<Id>(subOrderMap.keySet()), orderToReplacedSubscriptionsMap);

            //decompose svcMap into individual component maps
            Map<Id, ManageOrderServiceUtility.AccountData> accountsMap = new Map<Id, ManageOrderServiceUtility.AccountData>();
            Map<Id, ManageOrderServiceUtility.OrderData> ordersMap = new Map<Id, ManageOrderServiceUtility.OrderData>();
            Map<Id, List<ManageOrderServicesDTO>> servicesMap = new Map<Id, List<ManageOrderServicesDTO>>();
            Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>> orderSitesMap = new Map<Id, Map<Id, List<ManageOrderDataObject.PlaceDataObject>>>();
            Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> cfsMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();

            accountsMap     = ManageOrderServiceUtility.getAccountData(subOrderMap);
            ordersMap       = ManageOrderServiceUtility.getOrderData(subOrderMap);
            servicesMap     = ManageOrderServiceUtility.getServiceData(srvcMap);
            /*Comment out old method usage*/
            //cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap, orderToReplacedSubscriptionsMap);
            /*Use new method signature*/
            cfsMap          = ManageOrderServiceHelper.getOrderSpecs(subOrderMap);
            orderSitesMap   = ManageOrderServiceUtility.getSitesData(srvcMap, servicesMap);
            System.debug('allcfsMap : ' + cfsMap);
             Map<String,String> serviceCancelDateMap = ManageOrderServiceUtilityHelper.getRequestedServiceCancellationDate(orderIds);
            //map CS & SFDC data into ManageOrder DTO
            for(ManageOrderServiceUtility.OrderData ord: ordersMap.values()){
                System.debug('Order Id:::'+ord.orderId);
                ManageOrderDataObject.ProductOrder orderDTO = new ManageOrderDataObject.ProductOrder();
                ManageOrderServiceUtility.putOrderData(ord.orderId, orderDTO, ordersMap);
                ManageOrderServiceUtility.putAccountData(ord.orderId, orderDTO, accountsMap);
                // Update for 65707 :: 19.4 :: 14/3/2019 :: by one extra Arg - serviceDeliveryContactMap
                //Start
                ManageOrderServiceUtility.putServiceData(serviceCancelDateMap,ord, orderDTO, servicesMap.get(ord.orderId), cfsMap.get(ord.orderId), orderSitesMap.get(ord.orderId), serviceDeliveryContactMap,guidToTransientAttributesMap);
                //End
                orderPayloadMap.put(ord.orderId, JSON.serialize(orderDTO, true).replace('number1', 'number').replace('\\"','\'').replace('numbers','Number').replace('\'Range\':null,\'Number\'','\'Number\'').replace('\'Number\':null,',''));
               }

        }
        return orderPayloadMap;
    }


    public static Map<Id, String> triggerFulfilment(Map<Id, String> orderpayloads, String event) {
        String status = 'Failed';
        Logger2 logger = Logger2.getLogger(event);
        Map<Id, HttpResponse> orderResponse = new Map<Id, HttpResponse>();
        Map<Id, String> orderStatuses = new Map<Id, String>();
        try {
            for(Id orderId: new List<Id>(orderpayloads.keySet())){
                String reqBody = orderpayloads.get(orderId);
				// Handling when Fulfilment in Not Required -  Manish Jha
				ManageOrderDataObject.ProductOrder orderDTO =  new ManageOrderDataObject.ProductOrder();
				if(String.isNotEmpty(reqBody))
				orderDTO = (ManageOrderDataObject.ProductOrder)JSON.deserialize(reqBody, ManageOrderDataObject.ProductOrder.class);
                if(orderDTO !=  null && !orderDTO.orderItem.isEmpty()){
                    String token = AuthenticationManager.getOauthToken(event);
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                    HttpResponse adResponse;
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, event);
                    orderResponse.put(orderId, adResponse);
                }else{
					HttpResponse adResponse = new HttpResponse();
					adResponse.setStatusCode(201);
					adResponse.setBody('There is no fulfilment required for orderItem in the order');
					orderResponse.put(orderId, adResponse);
				}
            }
            
            for(Id orderId: new List<Id>(orderResponse.keySet())){
                HttpResponse adResponse1 = orderResponse.get(orderId);
                if (adResponse1.getStatusCode() == 201) {
                    System.debug('json Response Test ' + adResponse1.getBody());
                     System.debug('Status Code ' + adResponse1.getStatusCode());
                    logger.logMessages(orderpayloads.get(orderId), adResponse1.getBody(), '', '', '', '', true, false, Integer.valueOf(adResponse1.getStatusCode()) , null, null, null);
                    status = 'Success';
                } 
                else {
                    status = logError(orderpayloads.get(orderId), adResponse1, logger);
                }
                orderStatuses.put(orderId, status);
            } 
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), true, false);
            logger.exitLogger();
        }
        logger.exitLogger();
        return orderStatuses;
    }
   
   //@future (callout =true)
   public static void sendOrder(List<String> orderIds){
        Map<Id, String> orderpayload = buildManageOrderPayload(orderIds);
        System.debug('OrderPayLoad:::::' + orderpayload);
        Map<Id, String> orderStatus = new Map<Id, String>();
        orderStatus = triggerFulfilment(orderpayload, HANDLERNAME);
     //EDGE-113552  // ManageOrderAcknowledgeHandler.processAcknowledgements(orderStatus);
    
   }  
   //EDGE-112498 -Refactor Order Fulfilment Orchestation
   public static void sendOrderSync(List<String> orderIds){
        Map<Id, String> orderpayload = buildManageOrderPayload(orderIds);
        System.debug('OrderPayLoad:::::' + orderpayload);
        Map<Id, String> orderStatus = new Map<Id, String>();
        orderStatus = triggerFulfilment(orderpayload, HANDLERNAME);
       // EDGE-113552 //ManageOrderAcknowledgeHandler.processAcknowledgements(orderStatus);
    
   }     


   public static void sendManageOrder(List<String> orderIds){
       try{
         
         // EDGE-72939 & EDGE-72933 notify the High Volume Micro Service about create & update event  
        String enableHV = EnvironmentVariable__c.getValues('EnableHV').Value__c;
        Logger2 log = Logger2.getLogger('HighVolumeEvent');
        List<HighVolumeReadyToSubmitOrder__e> highVolumeList = new List<HighVolumeReadyToSubmitOrder__e>();
        if(enableHV=='true'){
        
            if(orderIds != null){
                Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([SELECT id, csord__Order_Number__c FROM csord__Order__c WHERE id =:orderIds[0]]);
                HighVolumeReadyToSubmitOrder__e highVolEvent = new HighVolumeReadyToSubmitOrder__e ();
                highVolEvent.OrderID__c = orderMap.get(orderIds[0]).Id;
                highVolEvent.Order_Number__c= orderMap.get(orderIds[0]).csord__Order_Number__c; //changed from OrderNum 
                highVolEvent.CorrelationID__c = EDISSingleManager.getUID();
               // highVolumeList.add(highVolEvent);
               Database.SaveResult saveRes = EventBus.publish(highVolEvent);
               if(saveRes != null ){
                   System.debug('Events are published');
                log.logMessages(JSON.serialize(highVolEvent, true), '', '', '', '', '', false, false,200,'','','');
                log.exitLogger();
               }
                
                //EDGE-74596 Start

                list<csord__Service__c> serviceSubsList =  [SELECT Id, Name, csord__Status__c, recoveryMethod__c,
                                                            returnReasonType__c,devicecareCaseId__c,TNowCaseId__c,
                                                            Scenario_Type__c,csord__Order__c,csord__Subscription__c,
                                                            csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                            csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c ,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
                                                            csord__Subscription__r.toBeCancelled__c  FROM csord__Service__c 
                                                            WHERE (csord__Order__c IN: orderIds OR csord__Order__r.csord__Primary_Order__c IN: orderIds) AND csord__Status__c != 'Connected'];
                OrchestrationProcessCreator.createOchestrationProcess(serviceSubsList);
                //EDGE-74596 Stop
        }
        
    }else{IntegrationRecordHandlerUtil.createRequests(HANDLERNAME, orderIds);}
        }catch(Exception e){
        System.debug('Exception in sendManageOrder'+e);
    }
   }
   
   @testVisible
    private static String logError(String reqBody, HttpResponse adResponse, Logger2 logger){
        String status = 'Failed';
        if (adResponse.getStatusCode() == 401) {logger.logMessages(reqBody, adResponse.getBody(), '', '', 'SECURITY_TOKEN_VALIDATION_FAILURE', 'Security token could not be validated', true, false, Integer.valueOf(adResponse.getStatusCode()), null, null, null ); status = 'Failed';
        } 
        else if (adResponse.getStatusCode() == 400) {logger.logMessages(reqBody, adResponse.getBody(), '', '', 'VERSION_MISMATCH', 'Amend not allowed, Given version is incorrect.', true, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null); status = 'Failed';
        } 
        else if (adResponse.getStatusCode() == 404) { logger.logMessages(reqBody, adResponse.getBody(), '', '', 'ORDER_NOT_FOUND', 'Order with given ID was not found.', true, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);status = 'Failed';
        } 
        else if (adResponse.getStatusCode() == 409) { logger.logMessages(reqBody, adResponse.getBody(), '', '', 'DUPLICATE_ORDER_KEY', 'Product Order with given ID already exists', true, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null); status = 'Failed';
        } 
        else if (adResponse.getStatusCode() == 500) {logger.logMessages(reqBody, adResponse.getBody(), '', '', 'INTERNAL_SERVER_ERROR', 'Unexpected error.', true, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null); status = 'Failed';
        } 
        else {
            logger.logMessages(reqBody, adResponse.getBody(), '', '', String.valueOf(adResponse.getStatusCode()), adResponse.getStatus()+': '+adResponse.getStatusCode(), true, false, Integer.valueOf(adResponse.getStatusCode()), '', '', '');
            status = 'Failed';
        }
        return status;
    }

 }