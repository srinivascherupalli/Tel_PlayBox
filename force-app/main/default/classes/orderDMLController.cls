/******************************************************************************************************
*Class Name     : orderDMLController
*Test Class     : orderDMLControllerTest

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________

1.       Shweta Khandelwal        04.06.2021   EDGE-209292
2.       Pooja Gupta              28.04.2021   EDGE-209294
3.       Pooja Gupta              15.04.2021   EDGE-214317
4.       Shweta Khandelwal        15.04.2021   EDGE-214316
5.       Gokul P                  03-Sep-2021   DIGI-18174 -
6.       Gokul P                   15-Sep-2021 DIGI-19702 & DIGI-21858 (Together)
7.       Ritika                   06-08-2021   DIGI-371  TON: Skip Contract API Processing logic
8.       Nikhil                   24-08-2021   DIGI-11618- TON: herokuMACDSolution API Processing logic
9.       Rajiv                     24-08-2021   DIGI-369  TON: Number Management
10.      Gokul P                  17-09-2021   DIGI-16926- TON: Create MACD Basket with Solution in single API call
11.      Gokul P                  03-10-2021   DIGI-475 Method to call submitOrder future method as part of TON
12.      Gokul P                  30-10-2021   DIGI-34844 <TED-81> TON Product Configuration look-up from Secondary MSISDN Number Record
******************************************************************************************************/
public with sharing class orderDMLController {
    public static final String HANDLER = 'orderDMLControllerHandler';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    private static final String REPLACE_SIM = 'Replace SIM';
    private static final String SIMPLEX = 'Simplex';
    private static final String RecordTypeName = 'Ready for Submit'; 
    private static final String DMCAT_1196_FULFILL='DMCAT_ProductSpecification_001196_Fulfilment';
    private static final String orderProcessName = 'Order Fulfilment Process';//EDGE-209294
    private static final String RecTypeForOrdAppoint = 'Order Submitted with Appointment';//EDGE-209294
    private static final String RecTypeForOrdSub = 'Order Submitted';//EDGE-209294

/*********************************************************************************************************************************
Method Name: createOrderRecord
Description: Method to create order and order request record.
Author: Shweta Khandelwal
EDGE-207627             
Date: 04.06.2021 
**********************************************************************************************************************************/   
    public static Map<String,String> createOrderRecord(Map<String,String> orderDetails){
        String accountId = orderDetails.get('AccountId');
        String tNowCaseRef = orderDetails.get('ReferenceNumber');
        String SelectReplacereason = orderDetails.get('Reason');
        String OwnerId = orderDetails.get('OwnerId');
        String CorrelationId = orderDetails.get('correlationId');
        String actionType = orderDetails.get('ActionType'); //EDGE-207627
        System.debug('orderDetails '+orderDetails);
        String ordName = ('0' + String.valueOf(Date.today().day())).right(2) +
                         ('0' + String.valueOf(Date.today().month())).right(2) +Date.today().year() +'_' +
                         String.valueOf(System.now().time()).left(8);  
        Map<String,String> resultMap = new Map<String,String>();
        string result = '';
        Id recordTypeId = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        try {
            //Order request
            csord__Order_Request__c orderRequest = new csord__Order_Request__c();
            orderRequest.csord__Process_Status__c = 'Requested';
            orderRequest.csord__Request_DateTime__c = Datetime.now();
            orderRequest.csord__Module_Name__c = 'CS Order Implementation Module Telco A'; 
            orderRequest.csord__Module_Version__c = '1.0';
            insert orderRequest;
            //Primary order
            csord__Order__c primaryOrder = new csord__Order__c();
            primaryOrder.csord__Account__c = accountId;
            primaryOrder.recordTypeId = recordTypeId;
            primaryOrder.csord__Status2__c = RecordTypeName;
            primaryOrder.csord__Order_Type__c = 'Order';
            primaryOrder.csord__Start_Date__c = Date.today();
            primaryOrder.telstra_ord_Start_DateTime__c = System.now(); 

            if(actionType.equalsIgnoreCase('SIM Replacement')){
                primaryOrder.csord__Identification__c = 'Order_123';
                primaryOrder.Replacement_Reason__c = SelectReplacereason; 
            }
            else if(actionType.equalsIgnoreCase('Suspend') || actionType.equalsIgnoreCase('Resume')){//EDGE-214316 EDGE-214317 Starts
                primaryOrder.csord__Identification__c = 'Order_456';
                primaryOrder.csord__Product_Type__c = Label.Mobility;
                //Replacement_Reason__c will be null in case of Suspend
            }
            //EDGE-214316,214317 End
            primaryOrder.Name = actionType +'_' + ordName;
            primaryOrder.csord__Order_Request__c = orderRequest.id;
            primaryOrder.OwnerId = OwnerId;
            primaryOrder.Project_Complexity__c = SIMPLEX;
            primaryOrder.PM_Required__c = false;
            
            if (tNowCaseRef != '' && tNowCaseRef != null && tNowCaseRef != 'undefined') {
                primaryOrder.referencenumber__c = tNowCaseRef.toUpperCase(); 
            }
            insert primaryOrder;
            
            csord__Order__c orderInserted = [Select id,csord__Order_Number__c,csord__Order_Request__c 
                                             From csord__Order__c WHERE id =:primaryOrder.id ];
            System.debug('orderInserted '+orderInserted);
            resultMap.put('code','200');
            resultMap.put('status','Success');
            resultMap.put('correlationId',CorrelationId);
            resultMap.put('description','Order successfully created');
            resultMap.put('orderNumber',orderInserted.csord__Order_Number__c);
            resultMap.put('orderRequest',orderInserted.csord__Order_Request__c);
            resultMap.put('id',orderInserted.id); 
            
            
            
        } catch (Exception e) {
            resultMap.put('code','500');
            resultMap.put('status','Failed');  
            resultMap.put('description','Internal Server Error');
            system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
            logger.logMessages('create order exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
            logger.exitLogger(); 
        }
        return resultMap;
    }
    
/*********************************************************************************************************************************
Method Name: updateServicesData
Description: Update service,subscription and attachments
Author: Shweta Khandelwal
EDGE-207627             
Date: 04.06.2021 
**********************************************************************************************************************************/   
public static Map<String,String> updateServicesData(Map<String,String> serviceDetails){
    Map<String,String> resultMap = new Map<String,String>();
    try{
        string result='';
        string orderId = serviceDetails.get('orderId');
        string orderRequestId = serviceDetails.get('orderRequest');
        String CorrelationId = serviceDetails.get('correlationId');
        String orderNumber = serviceDetails.get('orderNumber');
        String suspensionReason = serviceDetails.get('Reason');//EDGE-207627
        String actionType = serviceDetails.get('ActionType'); //EDGE-207627
        System.debug('service '+serviceDetails.get('services'));
        List<Object> serviceData = new List<Object>();
        if(serviceDetails.containsKey('services')){
            serviceData = (List<Object>)JSON.deserializeUntyped(serviceDetails.get('services'));
        } 
        system.debug('orderId' + orderId +'orderRequestId' + orderRequestId+'orderNumber' +orderNumber + 'serviceData'+serviceData);
        Map<String,Map<String,Object>> subMap = new Map<String,Map<String,Object>>(); 
        for(Object service : serviceData){
            Map<String,Object> serviceMap = (Map<String,Object>)service;
            if(serviceMap.containsKey('Subscription_Number__c')){
                String key = (String)serviceMap.get('Subscription_Number__c');
                subMap.put(key,serviceMap);
            }               
        }
        System.debug('subMap '+subMap);  
            Map<String,Subwrapper> subWrapperToIdMap= new Map<String,Subwrapper>();
            List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
            List<csord__Service__c> serviceList = new List<csord__Service__c>();
            for(csord__Subscription__c sub:[
                                            SELECT id, name, csord__Status__c, csord__Order__c,Suspension_reason__c,
                                            csord__Order__r.csord__Order_Number__c,Suspension_reason_summary__c,
                                            csordtelcoa__Product_Configuration__r.id,csordtelcoa__Subscription_Number__c,
                                                (SELECT id, name,csord__Status__c,csord__Order__c, Delivery_Address__c,
                                                Site_Delivery_Contact__c, 
                                                Sim_Serial_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,
                                                Scenario_Type__c,csord__Service__c, csord__Subscription__r.Suspension_reason_summary__c
                                                FROM csord__Services__r)
                                            FROM csord__Subscription__c
                                            WHERE csordtelcoa__Subscription_Number__c IN :subMap.keySet()])
                {
                List<csord__Service__c> newListServices = new List<csord__Service__c>();//DIGI-18174
                SubWrapper wrapper = new SubWrapper();
                if(subMap.containsKey(sub.csordtelcoa__Subscription_Number__c)){
                    wrapper.SimSerialNumber = (String)subMap.get(sub.csordtelcoa__Subscription_Number__c).get('Sim_Serial_Number__c');
                    wrapper.RequestedSIMType =(String)subMap.get(sub.csordtelcoa__Subscription_Number__c).get('Requested_SIM_Type__c');
                    wrapper.DeliveryAddressID = (String)subMap.get(sub.csordtelcoa__Subscription_Number__c).get('Delivery_Address__c');
                    wrapper.DeliveryContactID = (String)subMap.get(sub.csordtelcoa__Subscription_Number__c).get('Site_Delivery_Contact__c');
                }
                System.debug('ServicesfromQuery-'+sub.csord__Services__r);//DIGI-18174 -Gokul P
                newListServices = sub.csord__Services__r;//ServiceList for each Subscription-will get reset for each Sub || DIGI-18174
                wrapper.SimAvailabilityType = '';
                subWrapperToIdMap.put(sub.id,wrapper);
                serviceList.addAll(newListServices); //DIGI-18174 -Gokul P
                subscriptionList.add(sub);

                
            System.debug('updatedObjectServices '+newListServices);
            System.debug('updatedObjectServicesSize '+newListServices.size());//DIGI-18174
            }
            System.debug('subWrapperToIdMap '+subWrapperToIdMap);
            System.debug('serviceList '+serviceList);//Final List
            System.debug('serviceList '+serviceList.size());//DIGI-18174

            
            try {
                    Map<id,csord__Service__c> serviceMap=new Map<id,csord__Service__c>();
                    Map<Id,csord__Subscription__c> subUpdateMap = new Map<Id,csord__Subscription__c>();
                    //update services
                    for(csord__Service__c serv:serviceList){
                        csord__Subscription__c subs ;//DIGI-19702 removed new initialisation
                        //clear service details
                        serv.Telstra_Committed_Date__c = null; 
                        serv.Forecasted_Delivery_Date__c = null;
                        serv.Delivery_Address__c=null;
                        serv.Site_Delivery_Contact__c=null;
                        //clear service details end
                        serv.csord__Order__c = orderId;                   
                        serv.csord__Status__c = 'Pending';                  
                        //parent service                   
                        system.debug('ActionType:'+actionType);
                        system.debug('ServiceGuy:'+serv);
                        if(serv.csord__Service__c == null ){  
                            if(actionType != null && actionType.equalsIgnoreCase('SIM Replacement')){ 
                                serv.Scenario_Type__c = REPLACE_SIM;
                                serv.changeType__c = REPLACE_SIM;
                                //DIGI-19702 added null condition below
                                if(serv.csord__Subscription__c != null) {
                                subs = new csord__Subscription__c(Id=serv.csord__Subscription__c, changeType__c = REPLACE_SIM, csord__Order__c = orderId,     
                                csord__Status__c = 'Pending');
                                subUpdateMap.put(subs.id,subs);
                                }
                            }
                            //subUpdateMap.put(subs.id,subs);
                        }
                            //EDGE-214317,EDGE-214316 Start
                            system.debug('ActionTypebeforeResume'+actionType);
                        if(actionType != null && (actionType.equalsIgnoreCase('Suspend')||actionType.equalsIgnoreCase('Resume'))){ 
                                String reason = null; //digi-18174
                                String reasonSummary = ''; //DIGI-19702
                                System.debug('reasonSummary '+reasonSummary);
                                serv.changeType__c = actionType;
                                serv.Scenario_Type__c = null;
                                //System.debug('checkkkk '+reasonSummary.contains(reason));
                            if(actionType.equalsIgnoreCase('Suspend')){ //digi-18174
                                reason =subMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('Reason__c').toString();
                                reasonSummary = serv.csord__Subscription__r.Suspension_reason_summary__c;//DIGI-19702
                                if(reasonSummary != null && !reasonSummary.contains(reason)){
                                    reasonSummary = reasonSummary + '-' + reason;
                                    System.debug('reasonSummary in IF '+reasonSummary);
                                }else if(reasonSummary == null){
                                    reasonSummary = reason;
                                    System.debug('reasonSummary in elseIF '+reasonSummary);
                                }
                            }
                                System.debug('reason '+reason);//DIGI-19702 added null condition
                                if(serv.csord__Subscription__c != null){
                                    subs = new csord__Subscription__c(Id=serv.csord__Subscription__c, changeType__c = actionType, csord__Order__c = orderId,     
                                                                  csord__Status__c = 'Pending',Suspension_reason__c = reason,Suspension_reason_summary__c = reasonSummary);//DIGI-19702 - Changing to loop
                                subUpdateMap.put(subs.id,subs);
                                }
                            }//EDGE-214317,EDGE-214316 End
                            //subUpdateMap.put(subs.id,subs);
                            System.debug('Again subUpdateMap  '+subUpdateMap);
                            serv.csord__Order_Request__c = orderRequestId;
                            serv.Sim_Serial_Number__c =(String)subMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('Sim_Serial_Number__c');
                        
                        if(serv.Sim_Serial_Number__c==null || serv.Sim_Serial_Number__c==''){
                            serv.Delivery_Address__c=(String)subMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('Delivery_Address__c');
                            serv.Site_Delivery_Contact__c=(String)subMap.get(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c).get('Site_Delivery_Contact__c');
                        }
                        serviceMap.put(serv.id,serv);
                    }
                    
                    for(csord__Subscription__c subs:subscriptionList){
                        if(!subUpdateMap.containsKey(subs.Id)){
                            subs.csord__Order__c = orderId;     
                            subs.csord__Status__c = 'Pending';
                            subUpdateMap.put(subs.id,subs);
                        }
                    }
                    System.debug('serviceMap '+serviceMap);
                    System.debug('Final subUpdateMap '+subUpdateMap);
                    if(!subUpdateMap.values().isEmpty()){
                        update subUpdateMap.values();
                    }
                    if(!serviceList.isEmpty()){
                        update serviceList; 
                    }
                    
                    SimReplaceServiceSpecUtils.updateServiceSpecAttachment(Label.DMCAT_ProductSpecification_000263,serviceMap,subWrapperToIdMap);
                    //Added another method call to resolve the shipping required flag goign true for Mobile Device and device
                    SimReplaceServiceSpecUtils.updateServiceSpecAttachment(Label.DMCAT_ProductSpecification_000423_Fulfilment,serviceMap,subWrapperToIdMap);
                    SimReplaceServiceSpecUtils.updateServiceSpecAttachment(DMCAT_1196_FULFILL,serviceMap,subWrapperToIdMap);
                //}            
                
                resultMap.put('code','200');
                resultMap.put('status','Success');
                resultMap.put('correlationId',CorrelationId);
                resultMap.put('description','Services successfully updated');
                resultMap.put('orderNumber',orderNumber);
                
            } catch (Exception e) {
                resultMap = catchDetails(e);
            }
    }catch (Exception e) {
        resultMap = catchDetails(e);
    }
    return resultMap; 
}
/*********************************************************************************************************************************
Method Name: catchDetails
Description: Method to get catch block details.
Author: Shweta Khandelwal             
Date: 07-May-2021 
**********************************************************************************************************************************/
 public static Map<String,String> catchDetails(Exception e){
    Map<String,String> resultMap = new Map<String,String>();
    resultMap.put('code','500');
    resultMap.put('status','Failed');  
    resultMap.put('description','Internal Server Error');
    system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
    logger.logMessages('update services exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);              
    logger.exitLogger(); 
    return resultMap; 
 }
    
/*********************************************************************************************************************************
Method Name: submitOrder
Description: Method to submit the order to O2A.
Author: Pooja Gupta             
Date: 27-April-2021 
**********************************************************************************************************************************/
    @future
    public static void submitOrder(string orderId){
        try{
            system.debug('orderidrecived'+orderId);
            List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
            CSPOFA__Orchestration_Process_Template__c processTemplate = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name like  :orderProcessName  LIMIT 1];
            system.debug('OrderIds..'+orderId+'    '+'processTemplate...'+processTemplate);
            if(orderId != null && processTemplate.Id != null){
                CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
                newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
                newProcess.Order__c = orderId;
                newProcess.CSPOFA__State__c = 'Active';
                newProcesses.add(newProcess);
            }
            
            if(!newProcesses.isEmpty()){
                insert newProcesses;
            }
            
            List<Id> serviceIds = new List<Id>();
            Id recordTypeOrdSubmitId = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(RecTypeForOrdSub).getRecordTypeId();
            Id recTypeForOrdAppointId = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(RecTypeForOrdAppoint).getRecordTypeId();
            csord__Order__c primaryOrder = [select id, name, csordtelcoa__Opportunity__c,telstra_ord_Start_DateTime__c ,Scenario_Type__c, Action_Type__c FROM csord__Order__c WHERE id =:orderId];
            if(primaryOrder != null)
            {
                List<csord__Service__c> serviceList = [SELECT id,Name,Appointment_Required__c,csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c where csord__Order__c =:primaryOrder.Id];                  
                for(csord__Service__c services : serviceList){
                    serviceIds.add(services.Id);
                }
                if(serviceIds.size()>0 && primaryOrder.Scenario_Type__c!=System.label.ReplaceSIM){ 
                    primaryOrder.RecordTypeId = recTypeForOrdAppointId;
                } 
                else{
                    primaryOrder.RecordTypeId = recordTypeOrdSubmitId;
                }
                primaryOrder.telstra_ord_Start_DateTime__c = System.Now();
                primaryOrder.csord__Status2__c = Label.OrderStatus;
                update primaryOrder;
            }
            FunctionalContactRoleOperation.upsertFunctionalContactRole(serviceIds);  
        }
        
        catch(exception ex){
            system.debug('Exception occured in submit order' + ex.getMessage() + 'at Line' + ex.getLineNumber() + 'caused by' + ex.getCause());
            logger.logMessages('submit order exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
            logger.exitLogger();  
        }
    }
    
/*********************************************************************************************************************************
Method Name: submitOrder
Description: Method to call submitOrder future method as part of TON
Author: Gokul P
Date: 27-April-2021 
JIRA: DIGI-475
**********************************************************************************************************************************/
    public static Map<String,String> submitOrderMain(Map<String,String> cachedDataMap){
        Map<String,String> resultMap = new Map<String,String>();
        
        try{
            String CorrelationId = cachedDataMap.get('correlationId');
            String OrderId = cachedDataMap.get('Order_Rec_Id');
            system.debug('orderidrecieved'+OrderId);
            if(OrderId != null){
                submitOrder(OrderId);
                system.debug('order submitted main');
                resultMap.put('code','200');
                resultMap.put('status','Success');
                resultMap.put('correlationId', CorrelationId);
                resultMap.put('description','Order request successfully submitted and will take some time to complete. Please check again in some time');
                OC_SessionPayloadValidation.clearSession(correlationId, 'submitOrder');
                }
            }
        catch(Exception e) {
            resultMap.put('code','500');
            resultMap.put('status','Failed');  
            resultMap.put('description','Internal Server Error');
            system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
            logger.logMessages('Skip Contract exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
            logger.exitLogger(); 
    }
        return resultMap;
    }
    
/*********************************************************************************************************************************
Method Name: skipContractForBasket
Description: DIGI-371 Method to Skip Contract
Author: Ritika Gupta          
Date: 06-Aug-2021 
**********************************************************************************************************************************/
public static Map<String,String> skipContractForBasket(Map<String,String> serviceDetails){
    system.debug('serviceDetails:'+serviceDetails);
    Map<String,String> resultMap = new Map<String,String>();
    String orderform = Label.Order_Form;
    
    try{
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
        Set<String> attNameFilterSet=new Set<String>{'BillingAccountLookup'};
            
        String basketId;
        String correlationId;
        String oldSolutionId;
        String TonGUID;//DIGI-34844
        
        if(serviceDetails.containsKey('TargetBasketId')){
            basketId = serviceDetails.get('TargetBasketId');
        }
        if(serviceDetails.containsKey('correlationId')){
            correlationId = serviceDetails.get('correlationId');
        }
        if(serviceDetails.containsKey('OldSolutionId')){
            oldSolutionId = serviceDetails.get('OldSolutionId');
        }
        if(serviceDetails.containsKey('TonGUID')){//DIGI-34844
            TonGUID = serviceDetails.get('TonGUID');
        }
       
        if(basketId == null || correlationId == null || oldSolutionId == null){
            resultMap.put('code','500');
            resultMap.put('status','Failed');  
            resultMap.put('description','BasektId or SolutionId missing');
            return resultMap;
        }

        if(basketId != null && basketId !=''){
            Map<String,cscfga__Product_Configuration__c> pcMap=Model_ProductConfiguration.getConfigMap(basketId,attNameFilterSet);
            if(pcMap!=null && !pcMap.isEmpty())
                configList=pcMap.values();

            String queryString = 'SELECT Id, csordtelcoa__Basket_Stage__c, Name, cscfga__Basket_Status__c, BasketType__c, cscfga__Opportunity__c, '+
                                'csbb__Synchronised_with_Opportunity__c, cscfga__Opportunity__r.Model_Change__c, csbb__Account__c, cscfga__Opportunity__r.Type, '+
                                 'cscfga__Opportunity__r.AccountId, Express_Flow__c, recordType.Name  FROM cscfga__Product_Basket__c WHERE ';
            queryString += 'Id =: basketId';
            system.debug('QueryString-->'+queryString);
            
            cscfga__Product_Basket__c productBasket = Database.query(queryString);
                
            String resp = performValidation(productBasket, configList);
            system.debug('resp:'+ resp);
            Map<String,String> responseMap = (Map<String,String>) JSON.deserialize(resp, Map<String,String>.class);
            if(resp.contains('error')){
                resultMap.put('code','500');
                resultMap.put('status','Failed');  
                resultMap.put('description', responseMap.get('text'));
                return resultMap;
            }


            //String recordTypeID = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get(orderForm).getRecordTypeId();
            csord__Solution__c oldSol = [SELECT cssdm__product_basket__c, cssdm__product_basket__r.cscfga__Opportunity__c FROM csord__Solution__c where Id =: oldSolutionId]; 
                
            if(productBasket!=null){
                //update Product basket
                productBasket.csordtelcoa__Basket_Stage__c = 'Enriched'; 
                update productBasket;

                createContract con = new createContract();
                ContractJunction__c contract =  con.createContractJunction(productBasket, oldSol);

                cscfga__Product_Configuration__c pdconfig1 = [select id,configGUID__c  from cscfga__Product_Configuration__c where configGUID__c =:TonGUID limit 1];
                system.debug ('pdconfigdata'+pdconfig1);
                if(serviceDetails.containskey('secondayMSDIDN') && serviceDetails.containskey('serviceMSISDN')&& pdconfig1 != null){
                    Number__c numRecExisting = [SELECT Id FROM Number__c WHERE Service_number__c =: serviceDetails.get('serviceMSISDN') LIMIT 1];
                    Number__c numberRecord  = new Number__c();
                    numberRecord.Primary_Number__c = numRecExisting.Id;
                    numberRecord.Service_Number__c = serviceDetails.get('secondayMSDIDN');
                    numberRecord.Status__c = 'Reserved';//DIGI-34844
                    numberRecord.Product_Configuration__c = pdconfig1.id;//DIGI-34844
                    numberRecord.Name = numRecExisting.Id;
                    insert numberRecord;
                    system.debug('number rec Id '+numberRecord.Id);
                }
                
                system.debug('contract:'+contract.Id);
                resultMap.put('code','200');
                resultMap.put('status','Success');
                resultMap.put('correlationId',correlationId);
                resultMap.put('description','Skip Contract Request successfully processed');
            }
        }

    }
    catch(Exception e) {
        resultMap.put('code','500');
        resultMap.put('status','Failed');  
        resultMap.put('description','Internal Server Error');
        system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
        logger.logMessages('Skip Contract exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
        logger.exitLogger(); 
    }
    
    return resultMap;
}
/*********************************************************************************************************************************
Method Name: createHerokuMACDSolution
Description: DIGI-11618 Processing logic to Create MACD solution in Heroku
Author: Nikhil Kumar          
Date: 17-Sep-2021 
**********************************************************************************************************************************/ 
public static Map<String,String> createHerokuMACDSolution(Map<String,String> serviceDetails){

    
    Map<String,String> resultMap = new Map<String,String>();

    try{     
            String response ='';
            String CorrelationId = serviceDetails.get('correlationId');
            String BasketId = serviceDetails.get('TargetBasketId');
            String targetSolutionId =  serviceDetails.get('TargetSolutionId');
            //String targetMainConfig =  serviceDetails.get('TargetMainConfigurationId');
            String oldSolutionId =  serviceDetails.get('OldSolutionId'); 
            
            List<cscfga__Product_Configuration__c> pc = [Select Id from cscfga__Product_Configuration__c where cssdm__solution_association__c =: targetSolutionId and ConfigurationType1__c = 'SolutionComponent' limit 1];
            String targetMainConfig = '';
            if(pc != null && !pc.isEmpty()){
                targetMainConfig = pc[0].Id;
            }
            
            Map<String, String> requestMap = new Map<String, String>{
                'replacedSolutionId' => oldSolutionId,
                'targetSolutionId' => targetSolutionId,
                'targetBasketId' => BasketId,
                'targetMainConfigurationId' => targetMainConfig,
                'changeType' => 'Change Request'
            };  
        if ( oldSolutionId != null && oldSolutionId != '' && basketId != null && basketId != '' && targetSolutionId != null && targetSolutionId != '') 
        {
            system.debug('RequestMap:'+requestMap);
            cssmgnt.SolutionMACDController.createHerokuMACDSolution(requestMap);
            resultMap.put('code','200');
            resultMap.put('status','Success');
            resultMap.put('correlationId', CorrelationId);
            resultMap.put('description','heroku MACD Data Successfully Submitted');
        }
    }
    catch (Exception e) {
        resultMap.put('code','500');
        resultMap.put('status','Failed');  
        resultMap.put('description','Internal Server Error');
        system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
        logger.logMessages('create basket exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
        logger.exitLogger(); 
    }
    return resultMap;
}
/*********************************************************************************************************************************
Method Name: getConfigurationSolution
Description: DIGI-9360 getConfig API to call and understand the outcome of HerokuMACDSolution async process
Author: Nikhil Kumar          
Date: 17-Sep-2021 
**********************************************************************************************************************************/ 
public static Map<String,String> getConfigurationSolution(Map<String,String> serviceDetails){

    
    Map<String,String> resultMap = new Map<String,String>();
    
    try{     
            String response ='';
            String configGUID ='';
            String mainComponentConfigGUID ='';
            String CorrelationId = serviceDetails.get('correlationId');
            String targetSolutionId =  serviceDetails.get('TargetSolutionId');
            String serviceMSISDN =  serviceDetails.get('serviceMSISDN');
            cssmgnt.API_1 sm = new cssmgnt.API_1();
            List<String> guid = new List<String>();
            

            List<csord__Solution__c> listSol =[select cssdm__main_product__c from csord__Solution__c where Id=:targetSolutionId];
            if(listSol!=null && !listSol.isEmpty())
            {
                mainComponentConfigGUID=listSol[0].cssdm__main_product__c;
                guid.add(listSol[0].cssdm__main_product__c);
                response = sm.getConfigurations(targetSolutionId,guid);
                System.debug('response ' + response);
                csord__Service__c oldService = [SELECT Id, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.configGUID__c FROM csord__Service__c where serviceMSISDN__c =: serviceMSISDN order by CreatedDate Desc limit 1];
                if(oldService!=null && oldService.csordtelcoa__Product_Configuration__c!=null){

                    configGUID = oldService.csordtelcoa__Product_Configuration__r.configGUID__c;
                }
                
                System.debug('configGUID ' + configGUID);
                
            }
           Map<String,String> serviceMSDNandGUIDMap = new Map<String,String>();
           Map<String,Object> solutionMap = new Map<String,Object>();
           if(response.contains(listSol[0].cssdm__main_product__c)){
                resultMap.put('code','200');
                resultMap.put('status','Success');
                resultMap.put('correlationId', CorrelationId);
                serviceMSDNandGUIDMap.put('serviceMSISDN__c',serviceMSISDN);
                serviceMSDNandGUIDMap.put('GUID',configGUID);
                List<Object> serviceGUIDList = new List<Object>();
                serviceGUIDList.add(serviceMSDNandGUIDMap);
                solutionMap.put('solutionId',targetSolutionId);
                solutionMap.put('mainComponentConfigGUID',mainComponentConfigGUID);
                solutionMap.put('configMap', serviceGUIDList);
                List<Object> solutionList = new List<Object>();
                solutionList.add(solutionMap);
                resultMap.put('solutions', JSON.serialize(solutionList));
                resultMap.put('description','get configuration resp reveals Successfully heroku MACD processes completion');
                }
    }
    catch (Exception e) {
        resultMap.put('code','500');
        resultMap.put('status','Failed');  
        resultMap.put('description','Internal Server Error');
        system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
        logger.logMessages('create basket exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
        logger.exitLogger(); 
    }
    return resultMap;
}


/*********************************************************************************************************************************
Method Name: createMACDSolution
Description: DIGI-16926 
Author: Gokul P          
Date: 17-09-2021
**********************************************************************************************************************************/

        @AuraEnabled()
        public static Map<String,String> createMACDSolution(Map<String,String> cachedDataMap){
            Map<String,String> resultMap = new Map<String,String>();
            String CorrelationId = cachedDataMap.get('correlationId');
            String ServiceMISDN1 = cachedDataMap.get('serviceMSISDN');
            
            try {
                                    
                List <csord__Service__c> subList = [select id,serviceMSISDN__c, csord__Subscription__r.cssdm__solution_association__c,csordtelcoa__Replacement_Service__c from csord__Service__c where serviceMSISDN__c =:ServiceMISDN1 and csordtelcoa__Replacement_Service__c = null Limit 1];
                string oldsolutionId = subList[0].csord__Subscription__r.cssdm__solution_association__c;
                
                Map<String,String> responseMap = new Map<String,String>();
                String response ='';
                response = cssmgnt.API_1.createMacBasketForSolution(oldsolutionId); 
                system.debug('responseMACD'+response);
                responseMap = (Map<String,String>) JSON.deserialize(response, Map<String,String>.class); 
                String replacedSolutionId = responseMap.get('replacedSolutionId');
                String targetBasketId = responseMap.get('targetBasketId'); 
                String replacedMainConfigurationId = responseMap.get('replacedMainConfigurationId'); 
                String changeType = responseMap.get('changeType'); 
                String targetMainConfigurationId = responseMap.get('targetMainConfigurationId');
                String targetSolutionId = responseMap.get('targetSolutionId');
                
                OC_SessionPayloadValidation.addSessionData(correlationId, 'createMACDSolution', 'targetSolutionId',targetSolutionId );
                OC_SessionPayloadValidation.addSessionData(correlationId, 'createMACDSolution', 'targetBasketId',targetBasketId );
                OC_SessionPayloadValidation.addSessionData(correlationId, 'createMACDSolution', 'oldsolutionId',replacedSolutionId );
                OC_SessionPayloadValidation.addSessionData(correlationId, 'createMACDSolution','createBasket', 'Success');
                if ( !(String.isBlank(replacedSolutionId))) { 
                                        
                    cscfga__product_basket__c bask = new cscfga__product_basket__c();
                    bask.id = Id.valueOf(targetBasketId);
                    bask.channelFrom__c= 'TED-81 onlineAPI';
                    bask.correlation_id__c = CorrelationId;
                    update bask;
                    
                    resultMap.put('code','200');
                    resultMap.put('status','Success');  
                    resultMap.put('correlationId', CorrelationId);//Chnage Gokul
                    resultMap.put('description','Create solution request successfully submitted');
                    resultMap.put('basketid',targetBasketId); 
                    resultMap.put('solutionid',targetSolutionId);
                }

            } catch (Exception e) {
                        resultMap.put('code','500');
                        resultMap.put('status','Failed');  
                        resultMap.put('correlationId', CorrelationId);
                        resultMap.put('description','Internal Server Error');
                        resultMap.put('basketid',''); //GOkul
                        resultMap.put('solutionid','');//Gokul
                        system.debug('Exception occured:' + e.getMessage() + 'Line' + e.getLineNumber());
                        logger.logMessages('createMACDSolution exception', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
                        logger.exitLogger(); 
                    }
            return resultMap;
        }
/*********************************************************************************************************************************
Method Name: Pl_Event_records_CRU
Description: DIGI-11609
Author: Rajiv           
Date: 27-09-2021
**********************************************************************************************************************************/        
        //     Rajiv Singh -DIGI-11609 - Start
        public static void Pl_Event_records_CRU(string mainConfigId,String solutionId,String basketId,String correlationId,Boolean recCount){
            Map<String,String> jsonData = new Map<String,String>();
            Online_Ord_Journey__e onlineOrd = new Online_Ord_Journey__e();
            if(recCount){
           onlineOrd.API_Req_status__c = 'Completed';
           onlineOrd.API_name__c = 'createBasket';
           onlineOrd.CorrelationId__c =correlationId;
           jsonData.put('code','200');
           jsonData.put('status','Success');
           jsonData.put('CorrelationId__c',correlationId);
           jsonData.put('description','Create solution request successfully submitted');
           jsonData.put('Basket_Id__c',basketId);
           jsonData.put('Solution_Id__c',solutionId);
           jsonData.put('mainConfigId',mainConfigId);
           onlineOrd.API_Resp__c = JSON.serialize(jsonData);
                system.debug('API_Resp__c data'+onlineOrd.API_Resp__c);
           }else{
           onlineOrd.API_Req_status__c = 'Failed';
           onlineOrd.API_name__c = 'createBasket';
           onlineOrd.CorrelationId__c =correlationId;
           jsonData.put('code','400');
           jsonData.put('status','Failed');
           jsonData.put('CorrelationId__c','');
           jsonData.put('description','Create solution request failed');
           jsonData.put('Basket_Id__c','');
           jsonData.put('Solution_Id__c','');
           jsonData.put('mainConfigId','');
           onlineOrd.API_Resp__c = JSON.serialize(jsonData);
            }
            Database.SaveResult sr = EventBus.publish(onlineOrd); 
            if (sr.isSuccess() == true) {
        System.debug('Successfully enqueued event for publishing.');
          // Get the UUID that uniquely identifies this event publish
        System.debug('UUID=' + EventBus.getOperationId(sr));
      } else {
         for(Database.Error err : sr.getErrors()) {
             //System.debug('Error returned: ' +err.getStatusCode() + ' - ' +err.getMessage());
           }
          }       
        }
    //     Rajiv Singh -DIGI-11609 - End


/*********************************************************************************************************************************
Method Name: createContract
Description: Contract creation method to run in without sahring mode.
Author: Ritika Gupta          
Date: 13-Oct-2021 
**********************************************************************************************************************************/
    private without sharing class createContract{
   
        public ContractJunction__c createContractJunction(cscfga__Product_Basket__c productBasket, csord__Solution__c oldSol){
            Map<String,String> resultMap = new Map<String,String>();
            String orderform = Label.Order_Form;
            String recordTypeID = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get(orderForm).getRecordTypeId();

            //create Contract Junction record
            ContractJunction__c contract = new ContractJunction__c();
            contract.Account__c = productBasket.csbb__Account__c;
            contract.BSA_Generated__c = true;

            if(productBasket.cscfga__Opportunity__c != null){
                contract.Related_Opportunity__c = productBasket.cscfga__Opportunity__c;
            }else if(oldSol != null && oldSol.cssdm__product_basket__c != null){
                contract.Related_Opportunity__c = oldSol.cssdm__product_basket__r.cscfga__Opportunity__c;
            }
            contract.Related_Basket__c = productBasket.id;
            contract.Status__c = 'In Effect';
            contract.Contract_Activated_Date__c = Date.Today();
            contract.CongaStatus__c = 'Success';
            contract.Contract_Expiry_Date__c = Date.Today().addDays(30);
            contract.Name = 'CN' + productBasket.Name.substring(2);
            contract.recordTypeId = recordTypeId;
            insert contract;

            system.debug('contract:'+contract.Id);

            return contract;
        }
    }


    public static string performValidation(cscfga__Product_Basket__c productBasket, List<cscfga__Product_Configuration__c> configList){
        Map<String, Sync_Control_and_Constants__c> syncConstMap = Sync_Control_and_Constants__c.getAll();
        
        //1. If basket status = Invalid --> return error and error message
        if((productBasket == null || productBasket.cscfga__Basket_Status__c == null || !productBasket.cscfga__Basket_Status__c.equalsIgnoreCase('valid')) && syncConstMap.get('Basket_Not_Valid_For_Skip_Contract') != null){
            return '{"status":"error", "text":"' + syncConstMap.get('Basket_Not_Valid_For_Skip_Contract').value__c +'"}';
        }
        
        //2. if basket does not have any valid pc --> return error and error message
        if(configList.size() == 0){
            return '{"status":"error", "text":"Please add atleast one valid product to progress basket ahead"}';
        }
        
        return '{"status":"Ok","text":"Validation Successful"}';
    }

}