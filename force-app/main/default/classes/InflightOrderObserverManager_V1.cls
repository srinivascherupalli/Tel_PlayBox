/*
==========================================================================================================================
Class           : InflightOrderObserverManager
Developer Name  : Rohit
Test Class      : OrderObserverManagerTest
==========================================================================================================================
Sr.No.  Developer Name          Modify Date     Story Description
1.      Pawan Devaliya          22/12/2020      EDGE-170547  
2.    Akanksha Jain      22/03/2021    EDGE-200291 added basket type in query   
3.    Pawan Devaliya 	 	05/04/2021	EDGE-212832
 ==========================================================================================================================
*/
global with sharing class InflightOrderObserverManager_V1 implements  Database.Batchable<SObject>,Database.Stateful {
    global Set<Id> orderIds = new Set<Id>();
    global Set<Id> subsIds = new Set<Id>();
    global Map<Id,Id> orderToBasketMap = new Map<Id,Id>();
    global Set<Id> orderIdSet = new Set<Id>();
    global Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap = new Map<String, List<Basket_To_Order_Field_Map__c>>();
    global Map<Id,csord__Service__c> FinalserviceMap = new Map<Id,csord__Service__c>();
    global Map<String,String> objectToFieldsMap = new Map<String,String>();
    /***********************************************************************
    Name: OrderObserverManager
    Description: Constructor
    *******************************************************************/
 
    global InflightOrderObserverManager_V1(Set<Id> successSubId , Set<Id> successOrderId,List<Basket_To_Order_Field_Map__c> basketToOrderFieldList1){
        system.debug('successOrderId'+successOrderId);
         system.debug('basketToOrderFieldList1'+basketToOrderFieldList1);
        this.orderIds = successOrderId;
        this.subsIds = successSubId;
        List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = Basket_To_Order_Field_Map__c.getall().values();
        for(Basket_To_Order_Field_Map__c objBasket : basketToOrderFieldList){
            if(this.objBasketMap.containsKey(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c)){
                List<Basket_To_Order_Field_Map__c> BsktLst = objBasketMap.get(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c);
                BsktLst.add(objBasket);
                this.objBasketMap.put(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c,BsktLst);
            }else{
               this.objBasketMap.put(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c,new List<Basket_To_Order_Field_Map__c> {objBasket});
            }
            if(this.objectToFieldsMap.containsKey(objBasket.source_object_API_Name__c)){
                String fieldsValue =  objectToFieldsMap.get(objBasket.source_object_API_Name__c) +' ,'+ objBasket.Source_Field_Api_Name__c;
                this.objectToFieldsMap.put(objBasket.source_object_API_Name__c,fieldsValue);
            }else{
                this.objectToFieldsMap.put(objBasket.source_object_API_Name__c,objBasket.Source_Field_Api_Name__c);
            }
        }
    }
    /********************************************************************/
     //BATCHABLE METHODS IMPLEMENTATIONS
      public Database.QueryLocator start(Database.BatchableContext BC){
          system.debug('In start');

        String query = 'SELECT Id, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, ';

        query += 'csordtelcoa__Product_Configuration__r.ConfigurationType1__c, Action_Type__c,';
        query += 'csord__Order__r.csordtelcoa__Opportunity__c';     
        
        if(objectToFieldsMap.containsKey('csord__Subscription__c')){
            query += ' , ' + objectToFieldsMap.get('csord__Subscription__c');
        }
        query += ' FROM csord__Subscription__c WHERE Id IN: subsIds';
        system.debug('query*** ' + query);
        return Database.getQueryLocator(query);
      }
    
    global void execute(Database.BatchableContext BC, List<csord__Subscription__c> scope) {
        Set<Id> basketIds = new Set<Id>();   
        system.debug('objBasketMap '+objBasketMap);  
        Map<Id, csord__Subscription__c> subscriptionMap = new Map<Id, csord__Subscription__c>();
        for(csord__Subscription__c subInstance : scope){
            if(subInstance.csord__Order__r.csordtelcoa__Opportunity__c!=null){ 
                basketIds.add(subInstance.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
            }
            orderToBasketMap.put(subInstance.csord__order__c,subInstance.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);//Added Seperately for fetching Basket for all orders
            subscriptionMap.put(subInstance.Id,subInstance);
            orderIdSet.add(subInstance.csord__Order__c);
            system.debug('basketIds99'+basketIds);
        }
        if(!subscriptionMap.keyset().isEmpty()) {

            Set<Id> subIds = new Set<id>();
            subIds = subscriptionMap.keySet();

            string serviceQuery = 'SELECT Id, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, csord__Order__c, csord__Order__r.Fulfilment_Order_Version__c,';
            serviceQuery += 'csord__Order__r.csordtelcoa__Opportunity__c, csordtelcoa__Service_Number__c, toBeCancelled__c,';
            serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c,';
            serviceQuery += 'Version__c, csord__Subscription__c,';
            serviceQuery += 'csord__Service__c,';
            serviceQuery += 'changeType__c,';
            serviceQuery += 'Scenario_Type__c,';
            serviceQuery += 'csordtelcoa__Product_Configuration__r.ConfigurationType1__c,';
            serviceQuery += 'csordtelcoa__Replacement_Service__c,';
            serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,'; 
            serviceQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,';
            serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c,csord__Subscription__r.csord__Status__c';
            if(objectToFieldsMap.containsKey('csord__Service__c')){
                serviceQuery += ' , ' + objectToFieldsMap.get('csord__Service__c');
            }
            serviceQuery += ' FROM csord__Service__c WHERE csord__Subscription__r.Id IN: subIds ';
            
            System.debug('serviceQuery*** '+serviceQuery);
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(serviceQuery));
            
            Map<Id,String> pcWithServiceId = new Map<Id,String>();
            List<String> serviceNumLst = new List<String> ();
            List<Id> pcIdSet = new List<Id>();
            List<Id> opptyId = new List<Id>();
            for(csord__Service__c serRec : serviceMap.values()){
                 system.debug('serRec'+serRec);
                 system.debug('serRec.csord__Order__r.csordtelcoa__Opportunity__c'+serRec.csord__Order__r.csordtelcoa__Opportunity__c);
                 
                if(serRec.csord__Order__r.csordtelcoa__Opportunity__c!=null){ //added check as part of EDGE-181982
                    pcIdSet.add(serRec.csordtelcoa__Product_Configuration__c);
                    serviceNumLst.add(serRec.csordtelcoa__Service_Number__c);
                    pcWithServiceId.put(serRec.csordtelcoa__Product_Configuration__c,serRec.csordtelcoa__Service_Number__c);
                    opptyId.add(serRec.csord__Order__r.csordtelcoa__Opportunity__c);
                }
            }
            system.debug('pcIdSet'+pcIdSet);
            system.debug('serviceNumLst'+serviceNumLst);
            system.debug('pcWithServiceId'+pcWithServiceId);
            system.debug('opptyId'+opptyId);
            Map<Id,Number__c> numberMap = new Map<Id,Number__c>([SELECT Id,Name,Product_Configuration__c,Service_Id__c,Service_Number__c,Basket__c,
                                                                    Basket__r.csbb__Account__c,Type__c,IMSI__c,Sim_Serial_Number__c,Transition_Id__c,
                                                                     toBeCancelled__c,Status__c ,SimAvailabilityType__c  
                                                                     FROM Number__c 
                                                                     WHERE Product_Configuration__c in :pcIdSet or Service_id__c in: serviceNumLst]);
             system.debug('numberMap'+numberMap);
            
            Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap   =   new Map<Id, ContractJunction__c>();
            Map<Id, ContractJunction__c> contractJunctionMap    =   new Map<Id, ContractJunction__c>(
                                                                            [SELECT Id, Related_Basket__c,Contract_Start_Date__c, CreatedDate 
                                                                                FROM ContractJunction__c WHERE Related_Basket__c IN:basketIds 
                                                                                ORDER BY CreatedDate DESC]);
            system.debug('contractJunctionMap'+contractJunctionMap);   
            for(Id contractObjId: contractJunctionMap.keyset()){
                if(!basketIdToContractJunctionRecMap.containsKey(contractJunctionMap.get(contractObjId).Related_Basket__c)) {
                    basketIdToContractJunctionRecMap.put(contractJunctionMap.get(contractObjId).Related_Basket__c, contractJunctionMap.get(contractObjId));
                }
            }
            
            Map<Id,Orchestration_AttachmentWrapper> serviceAttachmentMap = new Map<Id,Orchestration_AttachmentWrapper>();
            for(Attachment att: [Select id,body,parentId,name from Attachment where parentId IN :serviceMap.keySet()]){
                Orchestration_AttachmentWrapper objWrap = new Orchestration_AttachmentWrapper(att.Id,att.name,att.body,att.parentId);
                /*objWrap.attchId = att.Id;
                objWrap.attchBody = att.body;
                objWrap.parentId = att.parentId;*/
                serviceAttachmentMap.put(att.parentId,objWrap);
            }
            System.debug('inside InFlightOrderObserverManager_V1...'+serviceMap.values());
            FinalserviceMap.putAll(InflightOrderObserverHelper_v1.performOrderOperationsInChucks(subscriptionMap, serviceMap, basketIdToContractJunctionRecMap,numberMap,opptyId,serviceAttachmentMap,objBasketMap, orderToBasketMap));        
        }   //End of if(!orderIdSet.isEmpty()) 
    } //End of executeOrders()
    
    public void finish(Database.BatchableContext BC){
        //Added IOTMSISDNRequired__c field in Order query as part of DPG-697
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>(

            [SELECT Id,csord__Account__c,csord__Account__r.cidn__c,csord__Order_Number__c,ModelChange__c, csord__Status2__c,
                Name,IOTMSISDNRequired__c,Scenario_Type__c,csord__Order_Request__c,csordtelcoa__Opportunity__c, isTransientComplete__c, Fulfilment_Order_Version__c 
                FROM csord__Order__c WHERE Id IN:orderIdSet]);

        List<Id> ordrIds = new List<Id>();
        ordrIds = orderToBasketMap.values();
        string basketQuery = 'SELECT NAME ';
        if(objectToFieldsMap.containsKey('cscfga__Product_Basket__c')){
           //basketQuery += ' , ' + '\'' + String.escapeSingleQuotes(objectToFieldsMap.get('cscfga__Product_Basket__c'))+ '\'';
            basketQuery += ' , ' + objectToFieldsMap.get('cscfga__Product_Basket__c');
        }
        basketQuery += ' FROM cscfga__Product_Basket__c WHERE Id IN: ordrIds';
        //Added Device_Care_Contact__c as part of EDGE-151354    
        Map<Id, cscfga__Product_Basket__c> basketMap = new Map<Id, cscfga__Product_Basket__c>((List<cscfga__Product_Basket__c>) Database.query(basketQuery)); 
        Map<String, Id> orderRecordTypeNameToIdMap  =   new Map<String, Id>();
        for(Schema.RecordTypeInfo oRecType : Schema.SObjectType.csord__Order__c.getRecordTypeInfosByDeveloperName().values()) {
            orderRecordTypeNameToIdMap.put(oRecType.getName(), oRecType.getRecordTypeId());  
        }
        InflightOrderObserverHelper_v1.performFinalOrderUpdates(orderMap,basketMap,orderToBasketMap,FinalserviceMap,orderRecordTypeNameToIdMap,objBasketMap);
    }
} //End of inflightOrderObserverManager_V1