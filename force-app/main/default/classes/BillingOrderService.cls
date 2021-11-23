/**
* Class  Billing Account Service.
*/
/********************************************************
Class Name      :   BillingOrderService
Test Class : BillingOrderServiceTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil        22/10/19         EDGE-112016,EDGE-81140 & EDGE-115840
2.            Pratyush Mishra       11/11/19         EDGE-113536 Header Map changes, added Correlation-Id as order Number
3.            Vanita Mude           30/12/2019       EDGE-127368- CLF changes done under the tech debt story
4.            Vaibhav Deshpande     21/01/2020       EDGE-120128 - priceAlteration block for EM new order
5.            Prajakta Patil        27/02/2020       EDGE-138056 
6.            Pawan/Vaibhav         18/03/2020       EDGE-124711/EDGE-124029 : Update CLI,DLI,TLI,PSLI on RTB Submission
7.            Vaibhav Deshpande     18/06/2020       EDGE-156196
8.            Prajakta Patil        15/07/2020       EDGE-161643 
**********************************************************
*/
public with sharing class BillingOrderService {
    
    @TestVisible
    private static BillingOrderService singleton = new BillingOrderService( );
    @TestVisible
    private static final String CHANGE_OF_MOBILE_NUMBER = 'Change of Mobile Number'; //INC000092113887
    @TestVisible
    private static final String PORT_OUT = 'Port Out'; //INC000092113887
    @TestVisible
    private static final String Replace_SIM = 'Replace SIM';
    
    /* A private Constructor prevents any other
* class from instantiating.
*/
    private BillingOrderService() { }
    
    /* Static 'instance' method */
    public static BillingOrderService getInstance( ) {
        return singleton;
    }
    
    // This Method retrives response from BDS created under Edge-20344
    public static BillingAccountDetailsDTO requestBillingAccountDetails(String ban){
        
        String handlerName = 'BillingAccountRetrieve';
        Logger2 logger = Logger2.getLogger(handlerName);
        String URI= ban;
        HttpResponse adResponse = null;
        Long requestTime;
        DateTime startTime;
        DateTime endTime;
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        try{
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h';
            Map<String,String> headerMap=new Map<String,String>{'Content-Type'=>'application/json','Authorization'=>'Bearer '+token,'Correlation-Id'=>correlationId,'Source-System'=>'SFDC'};
                //Map<String,String> headerMap=new Map<String,String>{'Content-Type'=>'application/json','Authorization'=>'Bearer ','Source-System'=>'SFDC'};   
                Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
            System.debug('Setting rec '+handleSettingRecord );
            // String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            // CLF changes startTime,endTime
            if(handleSettingRecord != null) { if(handleSettingRecord.Enable_Mock_Integration__c) { 
                    startTime = DateTime.now();adResponse = IntegrationRecordHandlerUtil.calloutSync('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName);
                    endTime = DateTime.now(); requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                }
                else{
                    startTime = DateTime.now();adResponse = IntegrationRecordHandlerUtil.calloutSync(URI, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName);
                    endTime = DateTime.now();requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                }
            }
           
            if(adResponse!=null && adResponse.getStatusCode()!= null){ if (adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 200) { BillingAccountDetailsDTO billingordernumber = BillingAccountDetailsDTO.parse(adResponse.getBody());
                System.debug('Response Body '+adResponse.getBody());
                //logger.logMessages(URI, adResponse.getBody(), '', '', '', '', true, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(URI, adResponse.getBody(), '', '', '', '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'GET',true, false);
                //CLF End - EDGE-127368
                return billingordernumber;
            }else if (adResponse.getStatusCode() == 404 || adResponse.getStatusCode() == 500) { BillingAccountDetailsDTO billingordernumber = BillingAccountDetailsDTO.parse(adResponse.getBody());
                // logger.logMessages(URI, adResponse.getBody(), '', '', '', '', true, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(URI, adResponse.getBody(), '', '', '', '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'GET',true, false);
                //CLF end  EDGE-127368
                return billingordernumber;
                
            } else {
                BillingAccountDetailsDTO billingError = BillingAccountDetailsDTO.parse(adResponse.getBody());
                //logger.logMessages(URI, adResponse.getBody(),'','', String.valueOf(billingError.code), billingError.errors[0].message, true, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(URI, adResponse.getBody(), '', '',  String.valueOf(billingError.code),billingError.errors[0].message, String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'GET',true, false);
                //CLF end - EDGE-127368
            return billingError;}} logger.exitLogger();
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            
            logger.exitLogger();
        }
        return NULL;
    }
    
    
    public static String requestBillingAccountAllocation(){
        system.debug('fetchBillingAccountNumber');
        Billing_Account__c billingAccount =  new Billing_Account__c();
        String handlerName = 'BillingAccountNumberAllocationHandler';
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        //EDGE-10926
        String reqBody='{"correlationId": "' + correlationId+ '", "sourceSystem": "SFDC"}';
        //String reqBody='{"correlationId": "' + + '", "sourceSystem": "C"}';
        Logger2 logger = Logger2.getLogger(handlerName);
        HttpResponse adResponse;Long requestTime;
        try {
            //String token = APIUtils.getToken(EnvironmentVariable.get('okapi_token_url'), handlerName);
            //  String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            String token = AuthenticationManager.getOauthToken(handlerName);Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                //Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer '};
                System.debug('headerMap2:: '+headerMap); 
            DateTime startTime = DateTime.now();
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            DateTime endTime = DateTime.now();
            requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            if(adResponse!= null && adResponse.getStatusCode()!=null){
            if (adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 200) {
                BillingOrderDTO billingordernumber = BillingOrderDTO.parse(adResponse.getBody());   
                billingAccount = BillingOrderUtil.createBillingAccountRecord(billingordernumber.billingAccountNumber);                    
                // logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
                //CLF end- EDGE-127368
            }else if (adResponse.getStatusCode() == 404) {
                // logger.logMessages(reqBody, adResponse.getBody(),'','', String.valueOf(adResponse.getStatusCode()), adResponse.getBody(), false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
                //CLF End - EDGE-127368
            } else {
                BillingAccountErrorDTO billingError = BillingAccountErrorDTO.parse(adResponse.getBody());                    
                
                // logger.logMessages(reqBody, adResponse.getBody(),'','', billingError.code, billingError.errors[0].message, false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);                    
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '',  String.valueOf(billingError.code), 
                                   billingError.errors[0].message, String.valueOf(adResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
                //CLF end - EDGE-127368
            }
            }
            logger.exitLogger();
        } catch (Exception e) {logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);           logger.exitLogger();
        }
        //return billingAccount;
        if(adResponse !=  null)
            return adResponse.getBody();
        else
            return null;
    }
    
    public static string requestBillingAccountCreate(BillingAccountDTO billingAccountDTO1){
        String handlerName = 'BillingAccountCreationHandler';
        String reqBody = JSON.serialize(billingAccountDTO1,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        String result = 'Created';
        HttpResponse adResponse;
        Long requestTime;
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>correlationId,'Source-System'=>'SFDC'};
                DateTime startTime = DateTime.now();
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            DateTime endTime = DateTime.now();
            requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            
            if(adResponse!= null && adResponse.getStatusCode()!=null){
            if (adResponse.getStatusCode() == 202 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 200) {
                BillingAccountCreateResponseDTO billingSuccess = BillingAccountCreateResponseDTO.parse(adResponse.getBody());result = 'Created';
                //logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '','', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
                //CLF End - EDGE-127368
            } else if (adResponse.getStatusCode() == 404) {
                result = 'Error';
                //logger.logMessages(reqBody, adResponse.getBody(),'','', String.valueOf(adResponse.getStatusCode()), adResponse.getBody(), false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
                //CLF end - EDGE-127368
            }
            else {
                result = 'Error';BillingAccountErrorDTO billingError = BillingAccountErrorDTO.parse(adResponse.getBody());
                
                //logger.logMessages(reqBody, adResponse.getBody(),'','', billingError.code, billingError.errors[0].message, false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger.logMessages(reqBody, adResponse.getBody(), '', '',  String.valueOf(billingError.code), 
                                   billingError.errors[0].message, String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
                //CLF end - EDGE-127368
            }
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            system.debug('Excepetion in billing creation'+e.getStackTraceString());
           
            logger.exitLogger();
        }
        return result;
    }
    public static void sendBillingOrder(List<Id> subIds,boolean isIncludeSolution,boolean isProductActionExpire){
        Map<Id, String> sendBillingOrderPayload = BillingOrderServiceUtil.buildPostSubscriptionPayload(subIds,isIncludeSolution,isProductActionExpire);
        //Map<Id, csord__Subscription__c> replacedSubScripMap = new Map<Id, csord__Subscription__c>([SELECT id,eventId__c,csord__Status__c,response_Status_Code__c,csordtelcoa__Subscription_Number__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c, csordtelcoa__Replaced_Subscription__c,csord__Order__c from csord__Subscription__c where Id IN: subIds]);
       //INC000092113887  Manish Jha
        Map<Id,Boolean> subscriptionScenarioTypeMap = new Map<Id,Boolean>();
        Map<Id, csord__Subscription__c> replacedSubScripMap = new Map<Id, csord__Subscription__c>([SELECT id,eventId__c,csord__Status__c,response_Status_Code__c,csordtelcoa__Subscription_Number__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c, csordtelcoa__Replaced_Subscription__c,csord__Order__c,csord__Order__r.csord__Order_Number__c,(Select id,Scenario_Type__c from csord__Services__r where Scenario_Type__c = :CHANGE_OF_MOBILE_NUMBER OR Scenario_Type__c = :PORT_OUT OR Scenario_Type__c = :REPLACE_SIM) from csord__Subscription__c where Id IN: subIds]);
        //String orderId = replacedSubScripMap.get(subIds[0]).csord__Order__c;
        // csord__Subscription__c solutionSub = [Select id,csord__Status__c,csord__Order__c from csord__Subscription__c where csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent' and csord__Order__c = :orderId LIMIT 1];
        //INC000092113887  Manish Jha
        for(csord__Subscription__c subscriptions: replacedSubScripMap.values()){
            if(subscriptions.csord__Services__r != null && !subscriptions.csord__Services__r.isEmpty()){subscriptionScenarioTypeMap.put(subscriptions.id,true);
            }
            
        }
        
        Map<String,String> pathMap = new Map<String,String>();
        String status = 'Failed'; String handlerName = 'PostSubscriptionHandler';
        Logger2 logger = Logger2.getLogger(handlerName); Map<Id, HttpResponse> billingOrderResponse = new Map<Id, HttpResponse>();
        csord__Subscription__c subscription = new csord__Subscription__c();
        Billing_Account__c billingAccount = new Billing_Account__c();
        String servSpecStatus = '';
        Long requestTime;
        String correlationId = '';
    String UniqueCorelationId = ''; //EDGE-161643 
        String orderNumber = '';
        Map<Id,Long> requestTimeMap=new Map<Id,Long>();
        Map<Id,String> orderNumberMap=new Map<Id,String>();
        try{
            for(Id subId: new List<Id>(sendBillingOrderPayload.keySet())){
                String reqBody = sendBillingOrderPayload.get(subId);
                BillingSpecDTO billDTO = BillingSpecDTO.parse(reqBody);
                pathMap.put(String.ValueOf(billDTO.billingAccountNumber),'subscriptions');
                //String correlationId =  replacedSubScripMap.get(subId).csord__Order__r.csord__Order_Number__c;
                if(String.isNotEmpty(reqBody)){
                    String token = AuthenticationManager.getOauthToken(handlerName);
                    
                    
                    //String token='hfgjkuibin5f68745gdb';
                    //update for US-113536
                    orderNumber = replacedSubScripMap.get(subId).csord__Order__r.csord__Order_Number__c;
                    orderNumberMap.put(subId,orderNumber);
                    //String orderNumber = replacedSubScripMap.get(subIds[0]).csord__Order__c;
                    //Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>IntegrationRecordHandlerUtil.getUUID(),'Source-System'=>'SFDC'};
          
          //EDGE-161643 start
          UniqueCorelationId = IntegrationRecordHandlerUtil.getCorrelationId();//Length 18 char
                    correlationId = UniqueCorelationId + OrderNumber; //correlationId max length is 36 char
          
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>correlationId,'Source-System'=>'SFDC'}; 
           //EDGE-161643 end
                        system.debug('headerMap2:::'+headerMap);  
                    if((replacedSubScripMap.get(subId).response_Status_Code__c > 300 && replacedSubScripMap.get(subId).csord__Status__c == 'Billing Pending') || isProductActionExpire == true) {headerMap.put('eventId',replacedSubScripMap.get(subId).eventId__c);
                    if(isProductActionExpire ){headerMap.put('X-HTTP-Method-Override', 'PATCH') ; String newvalue = 'subscriptions'+ '/' +String.ValueOf(replacedSubScripMap.get(subId).csordtelcoa__Subscription_Number__c );pathMap.put(String.ValueOf(billDTO.billingAccountNumber),newvalue);
                    }
                    
                    }// EDGE-81140 aptch request
                    
                     if((replacedSubScripMap.get(subId).csordtelcoa__Replaced_Subscription__c !=null && replacedSubScripMap.get(subId).csordtelcoa__Replaced_Subscription__r.csord__Order__c != null) || (subscriptionScenarioTypeMap != null && subscriptionScenarioTypeMap.get(subId) == true)){
                        system.debug('test');
                        headerMap.put('X-HTTP-Method-Override', 'PATCH') ; String newvalue = 'subscriptions'+ '/' +String.ValueOf(replacedSubScripMap.get(subId).csordtelcoa__Subscription_Number__c );pathMap.put(String.ValueOf(billDTO.billingAccountNumber),newvalue);
                        
                    }  
                    system.debug('test'+headerMap);
                    HttpResponse adResponse;
                    DateTime startTime = DateTime.now();
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);
                    DateTime endTime = DateTime.now();
                    requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                    requestTimeMap.put(subId,requestTime);
                    if(adResponse!= null && adResponse.getStatusCode()!= null){
                    billingOrderResponse.put(subId,adResponse);}
                }
            }
            // HttpResponse response;
            map<ID,csord__Subscription__c> subsMap = new map<ID,csord__Subscription__c>([Select id,csord__Status__c,csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Status__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Id, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Status__c, csord__Order__r.Billing_Account__r.Id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,triggerBill_RTB__c,toBeCancelled__c,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where id IN: billingOrderResponse.keySet()]);
            Map<Id, csord__Service__c> serviceIdsToFetchNew = new Map<Id, csord__Service__c>();//added as part of EDGE-124711/EDGE-124029 
            //Map<Id, csord__Service__c> serviceIdsToFetchModify = new Map<Id, csord__Service__c>();
            set<Id> baseOrderServiceID=new set<Id>(); //added as part of EDGE-124711/EDGE-124029
            Map<Id, csord__Service__c> serviceMapPricing =  new Map<Id, csord__Service__c>([SELECT Id,  Name, csord__Subscription__c, Scenario_Type__c,toBeCancelled__c,csordtelcoa__Replaced_Service__c FROM csord__Service__c where csord__Subscription__c IN : subsMap.keySet()]);
            //Code commented as part of EDGE-124711/EDGE-124029
            //EDGE-120128 - start
           /* Map<Id,List<Price_Schedule_Line_Item__c>> mapSubsPSLI=new Map<Id,List<Price_Schedule_Line_Item__c>>();
            Id subsId;
            List<Price_Schedule_Line_Item__c> PSLIList=new List<Price_Schedule_Line_Item__c>();
            for(Price_Schedule_Line_Item__c psli : [select id,chargeInstance__c,fromPeriod__c,priority__c,status__c,toPeriod__c,unitPrice__c,chargeInstance__r.serviceId__r.csord__Subscription__c,chargeInstance__r.serviceId__r.csord__Subscription__r.Id from Price_Schedule_Line_Item__c where chargeInstance__r.serviceId__r.csord__Subscription__r.Id IN :subsMap.keyset()]) {
               
                if(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id!=null){
                if(mapSubsPSLI.containsKey(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id))
                {
                    List<Price_Schedule_Line_Item__c> lstPSLI = mapSubsPSLI.get(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id);
                    lstPSLI.add(psli);mapSubsPSLI.put(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id, lstPSLI);
                }
                else{
                    mapSubsPSLI.put(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id, new List<Price_Schedule_Line_Item__c>{psli});
                }
               }
            }*/
            //EDGE-120128 - end
            
           // List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
            Map<Id,csord__Subscription__c> subscriptionMapNew=new Map<Id,csord__Subscription__c>();
            map<ID,Billing_Account__c> billingAccountMap = new map<ID,Billing_Account__c>();
            for(Id subId : new List<Id>(subsMap.keySet())){
                if(subsMap.get(subId).csord__Order__r.Billing_Account__c != null)
                    billingAccountMap.put(subsMap.get(subId).csord__Order__r.Billing_Account__r.Id,subsMap.get(subId).csord__Order__r.Billing_Account__r);
                else billingAccountMap.put(subsMap.get(subId).csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Id,subsMap.get(subId).csord__Order__r.csord__Primary_Order__r.Billing_Account__r);
            }
            List<Billing_Account__c> billingAccountList = new List<Billing_Account__c>();
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            List<csord__Subscription__c> allSubList = new List<csord__Subscription__c> ();
             List<csord__Subscription__c> updateSubList = new List<csord__Subscription__c> ();
             Boolean isSolution = false;
             Id orderId;
             
            for(Id subId: new List<Id>(billingOrderResponse.keySet())){
                
                subscription = subsMap.get(subId);
                billingAccount = billingAccountMap.get(subsMap.get(subId).csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Id);
                if(subsMap.get(subId).csord__Order__r.Billing_Account__c != null)
                    billingAccount = billingAccountMap.get(subsMap.get(subId).csord__Order__r.Billing_Account__r.Id);
                
                HttpResponse response = billingOrderResponse.get(subId);
                system.debug('response::'+response);
                if (response.getStatusCode() == 202) {
                    //Code added as part of EDGE-124711/EDGE-124029
                     for(Id serviceKey : serviceMapPricing.keyset()){
                      if(serviceMapPricing.get(serviceKey).csord__Subscription__c==subId){
                      if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c == null){
                               serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));
                       }
                       else if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c != null && serviceMapPricing.get(serviceKey).toBeCancelled__c.equalsIgnoreCase('false')){
                        serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));
                        baseOrderServiceID.add(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c);
                   
                       }
                  }
                     }
                    BillingPostSubscriptionResponseDTO billingPostSubscriptionResponseJson = BillingPostSubscriptionResponseDTO.parse(response.getBody());
                    system.debug('billingPostSubscriptionResponseJson:::'+billingPostSubscriptionResponseJson); 
                    
                    //logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , subsMap.get(subId).csord__Order__r.Billing_Account__c, null, null);
                    
                    //CLF start - EDGE-127368 
                    logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(), '', '', '','', String.valueOf(response.getStatusCode()), orderNumberMap.get(subId), '','','Read','',requestTimeMap.get(subId) ,'POST',false, false);
                    //CLF end - EDGE-127368
                    status = 'Success';servSpecStatus = 'In Progress'; 
                    system.debug('subscription'+subscription);
                    subscription.csord__Status__c = 'Bill Readiness In Progress';
                     system.debug('subscription.csord__Status__c '+subscription.csord__Status__c);
                    if(subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != null){  if (subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){ isSolution = true;
                           //subscription.triggerBill_RTB__c = true;//added as part of EDGE-156196
                        if(subscription.csord__Order__c != null){orderId = subscription.csord__Order__c;}
                    }
                    }
                    
                    subscription.eventId__c = billingPostSubscriptionResponseJson.eventId; subscription.response_Status_Code__c = response.getStatusCode();
                    if(billingAccount!=null){billingAccount.Status__c = 'Provisioned';}
                    NumberUtil.UpdateNumberStatus(subscription.csordtelcoa__Subscription_Number__c,'Bill Readiness In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                  //Code commented as part of EDGE-124711/EDGE-124029
                    /*  if(!mapSubsPSLI.isEmpty()){
                    for(Price_Schedule_Line_Item__c ps:mapSubsPSLI.get(subscription.id)) //EDGE-120128 - if current subscrption is in mapSubsPSLI map then updating PSLI status related to that subscrption 
                    {
                        ps.status__c='Ready to Active'; PSLIList.add(ps); //EDGE-120128 - added PSLI in List
                    }}*/
                   
                }
                else if (response.getStatusCode() == 404) {
                    status = 'Failed';
                    //logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(),'','', String.valueOf(response.getStatusCode()), response.getBody(), false, false,Integer.valueof(response.getStatusCode()) , subsMap.get(subId).csord__Order__r.Billing_Account__c, null, null);
                    //CLF Start - EDGE-127368
                    logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(), '', '', '', 
                                       '', String.valueOf(response.getStatusCode()), orderNumberMap.get(subId), '', subsMap.get(subId).csord__Order__r.Billing_Account__c,'Read','',requestTimeMap.get(subId) ,'POST',false, false);
                    //CLF end - EDGE-127368
                    subscription.csord__Status__c = 'Billing Pending';subscription.response_Status_Code__c = response.getStatusCode();servSpecStatus = 'Failed';
                    if(billingAccount!=null){billingAccount.Status__c = 'Error';}
                } 
                else {
                    status = 'Failed';
                    BillingAccountErrorDTO billingError = BillingAccountErrorDTO.parse(response.getBody());                    
                    //logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(),'','', billingError.code, billingError.errors[0].message, false, false,Integer.valueof(response.getStatusCode()) , subsMap.get(subId).csord__Order__r.Billing_Account__c, null, null);
                    //CLF Start - EDGE-127368
                    logger.logMessages(sendBillingOrderPayload.get(subId), response.getBody(), '', '',  String.valueOf(billingError.code),billingError.errors[0].message, String.valueOf(response.getStatusCode()), orderNumberMap.get(subId), '','','Read','',requestTimeMap.get(subId) ,'POST',false, false);
                    //CLF end - EDGE-127368
                    subscription.csord__Status__c = 'Billing Pending'; subscription.response_Status_Code__c = response.getStatusCode();servSpecStatus = 'Failed';
                    if(billingAccount!=null){ billingAccount.Status__c = 'Error'; } //checking for null values              
                }
                System.debug('subId==>'+subId);
                
                //subscriptionList.add(subscription); //added as part of EDGE-156196
                subscriptionMapNew.put(subscription.id,subscription);
                system.debug('subscriptionMapNew::::'+subscriptionMapNew);
            }
            
              //EDGE -120128 removed soql from for loop
              //EDGE-138056
            if(isSolution == true){ 
                //allSubList = [Select id,csord__Status__c,csord__Order__c,triggerBill_RTB__c from csord__Subscription__c where csord__Order__c =:orderId ];
                for(csord__Subscription__c tempsub :[Select id,csord__Status__c,csord__Order__c,triggerBill_RTB__c from csord__Subscription__c where csord__Order__c =:orderId ])
                {  if(subscriptionMapNew.containsKey(tempsub.id)){
                        csord__Subscription__c subNew = subscriptionMapNew.get(tempsub.id);
                        subNew.triggerBill_RTB__c = true;
                        subscriptionMapNew.put(tempsub.id,subNew);
                   }else {
                        tempsub.triggerBill_RTB__c = true;subscriptionMapNew.put(tempsub.id,tempsub);
                    }
                    
                }
                /*for(csord__Subscription__c tempsub :allSubList){tempsub.triggerBill_RTB__c = true;
                         updateSubList.add(tempsub);
                        }   */          
            }
            //Code commented as part of EDGE-124711/EDGE-124029
           /* if(!PSLIList.isEmpty())
            { update PSLIList;  //EDGE-120128 -updating PSLI outside loop
            }*/
            
            //Code added as part of EDGE-124711/EDGE-124029
            if(serviceIdsToFetchNew!=null)
            {
                CeasePriceScheduleStep.updateSchedule(serviceIdsToFetchNew.keySet(), 'Ready to Active');//added code to change status of CLI,DLI,PSLI and TLI in case of new order
            }
            if(baseOrderServiceID!=null)
            {
                CeasePriceScheduleStep.updateSchedule(baseOrderServiceID, 'Ready to Replaced');//added code to change status of CLI,DLI,PSLI and TLI in case of modify order
            }
            //Tactical fixes for Sub Orch -Code refactroing still in progress
            Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>();
            List<csord__Service__c> serviceList = [SELECT Id, Name, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Service__c WHERE csord__Subscription__c =: subIds[0] AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c !='SolutionComponent'];
            Set<Id> serviceIdSet =  new Set<Id>();
            for(csord__Service__c serv : serviceList){
                //serviceMap.put(serv.Id, serv);
                serviceIdSet.add(serv.Id);
            }
            //Create a map of service and its attachment
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: serviceIdSet and name = 'ServiceSpecifications.json']);
            Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
            Map<String,String> guidToServiceMap = new Map<String,String>();
            
            Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
            if(attmAP!= null){
                
                for(Attachment tempAttachment: attmAP.values()){ serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
                    System.debug('serviceIdToSpecAttachMap====>'+serviceIdToSpecAttachMap);
                }
            }
            for(Id serId : serviceIdSet){ 
                guidToServiceMap = new Map<String,String>();
                //fetch the attachment for this servie
                String serviceattachmentstr = '';
                Attachment attch = serviceIdToSpecAttachMap.get(serId);
                serviceattachmentstr = attch.body.toString();
                System.debug('serviceattachmentstr===>'+serviceattachmentstr);
                //update the service spec status values
                if(guidToServiceMap!=null && guidToServiceMap.size()>0){
                    
                    // if(guidListToBeDisconnected!=null && guidListToBeDisconnected.size()>0){
                    for(String guid : guidToServiceMap.keySet()){String attchBody = serviceIdToSpecAttachMap.get(serId).body.toString();
                        String updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(attchBody), guid, 'status',servSpecStatus);
                        Attachment toUpdateAtt = serviceIdToSpecAttachMap.get(serId);toUpdateAtt.body = Blob.valueof(updatedServiceattachmentstr);serviceIdToSpecAttachMap.put(toUpdateAtt.parentId,toUpdateAtt);updatedAttSet.put(toUpdateAtt.id,toUpdateAtt);
                        System.debug('updatedAttSet===>'+updatedAttSet);
                    }
                }
            }
            
            //update the attachments
            if(!updatedAttSet.isEmpty()){   update updatedAttSet.values(); }
            /* String subSpec = csedm.API_1.getSubscriptionSpecificationsById(subId);
System.debug('subSpec::: ' + subSpec);
srvSpecList = CS_SpecificationDTO.parseSubscriptionSpec(subSpec, 'BILLING');
System.debug('srvSpecList::: ' + srvSpecList);
for(CS_SpecificationDTO.ServiceSpecification servSpec : srvSpecList){
csedm.API_1.updateServiceSpecificationPropertyById(servSpec.serviceId, servSpec.guid, 'status', servSpecStatus);
}*/
            /*subscriptionList.add(subscription);
            system.debug('subscriptionList::::'+subscriptionList);*/
            if(billingAccount!=null){ billingAccountList.add(billingAccount);}
            
            if(!subscriptionMapNew.isEmpty()){
                update subscriptionMapNew.values(); }
                
            /*if(!subscriptionList.isEmpty()){
            update subscriptionList;}*/
            
            /*if(!updateSubList.isEmpty()){ update updateSubList; //commented as part of EDGE-156196
            }*/
            BillingHandler.run=false;
            if(!billingAccountList.isEmpty()){update billingAccountList;}//checking for null values
        }
        catch (Exception e) {
            System.debug('Errors::'+  e.getStackTraceString() + '  '+e.getMessage() + '   ' + e.getLineNumber() );
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        logger.exitLogger();
    } 
}