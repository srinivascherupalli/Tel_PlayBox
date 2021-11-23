/*
===============================================================================================================================
Class           : OrderObserverManager
Developer Name  : Rohit
Test Class      : OrderObserverManagerTest
===============================================================================================================================
    Sr.No.              Developer Name          Modify Date     Story Description
1.  EDGE-> 88658        Rohit Tripathi          27/5/2019       Sites are not associated with subscriptions and Appointment not created for Orders in QA2
2.  Edge-98904          shubhi Vijayvergia      24/7/2019       Solution Console Integrity for Contract & COM
3.  EDGE-107845         Rohit T                 25/09/2019      During order creation, CS should create fulfilment, charge, assurance and allowance specifications based on chosen product configurations
4.  EDGE-105060         Aman Soni               6/11/2019       Introduce Cancel for Internet Site || Cancellation_Reason__c added as a part of TID cancellation journey
5.  EDGE-136968 
    & EDGE-136271       Pawan Devaliya          04/28/2020      Maintain relationship b/w NGVoice subs and BT subs. & Update NetworkServiceId on subscription.
6.  EDGE-148009         Rohit Tripathi          12/05/2020      NGUC_Modify_Subscriptions not triggered to newly added device as the Billing account is empty
7.  EDGE-142085         Shubhi/Aman             20/05/2020      Added Billing_Account__c field on Service object 
8.  EDGE-136968 
    & EDGE-136271       Pawan Devaliya          11/June/2020    Moved code to util class.
9.  EDGE-151354         Gnana                   30/06/2020      Updated Basket SOQL Query to add  Device_Care_Contact__c
10. EDGE-172953         Pooja /Payal            31/08/2020      Custom Code Refactoring - Order Observer apex class refactoing to handle large basket processing
11. EDGE-174924         Gnana                   14/10/2020      Added changeType__c,Action_Type__c,csordtelcoa__Replacement_Service__c in Services SOQL
12  EDGE-170949         Dheeraj                 22/10/2020      Added mainCharge__r.Type__c,Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c in Service SOQL
     &170948
13. EDGE-181982         Vaibhav Deshpande       29/10/2020      added changes for non commercial order
14. EDGE-186885         Dheeraj Bhatt           16/12/2020      added Product_Configuration__r.subType__c in numberMap query
15. EDGE-174925         Swapna                  17/12/2020      updated Service and Subscription SOQL
16  INC000095020812     Payal                   12/02/2020      Add PartnerAccount in Subscription SOQL
14. EDGE-207018         Dheeraj Bhatt           03/03/2021      added csord__Order__r.csordtelcoa__Opportunity__r.Type in service query
15. EDGE-200291         Akanksha Jain           09/03/2021      added ConfigurationType1__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c in service query
16. EDGE-201613         Vamsi Krishna Vaddipalli 15MAR2021      Added 2 fields in SOQL query International_Direct_Dial__c,addOnCharge__r.addOn_Name__c
17. EDGE-206835         Pooja Bhat              10/03/2021      <Incident# INC000095105856> In MACD Add New Order BAN is missing in solution subscription RTB hence RTB failed
18. EDGE-199912        Aman Soni                25/03/2021      Added Nickname__c field in query
19  EDGE-216816         Prajakta patil          30/06/2021      added query for asset
20  DIGI-6778           Dharmik Shah            08/02/2021      Added csordtelcoa__Product_Configuration__r.Type__c field for check Order for Cancel
21.EDGE-216816 -revert  prajakta patil          25/08/2021      removal of aset query
22. DIGI-38789/DIGI-39435   Ritika Gupta            16/11/2021      Excluding Ted-81 Orders from Oppty check
====================================================================================================================================================================
*/ 
global with sharing class OrderObserverManager_V2 implements  Database.Batchable<SObject>,Database.Stateful {
    global Set<Id> orderIds = new Set<Id>();
    global Map<Id,Id> orderToBasketMap = new Map<Id,Id>();
    global Set<Id> orderIdSet = new Set<Id>();
    global Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap = new Map<String, List<Basket_To_Order_Field_Map__c>>();
    global Map<Id,csord__Service__c> finalserviceMap = new Map<Id,csord__Service__c>();
    global Map<String,String> objectToFieldsMap = new Map<String,String>();
    global Integer pfSequence = 0;
    global String cacheHandler = '';
    /***********************************************************************
    Name: OrderObserverManager
    Description: Constructor
    *******************************************************************/
  
    global OrderObserverManager_v2(Set<Id> successOrderId,List<Basket_To_Order_Field_Map__c> basketToOrderFieldList1){
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('##########' + hexDigest );
        this.cacheHandler = 'OOM'+hexDigest;
        this.orderIds = successOrderId;
        List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = Basket_To_Order_Field_Map__c.getall().values();
        for(Basket_To_Order_Field_Map__c objBasket : basketToOrderFieldList){
            if(this.objBasketMap.containsKey(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c)){
                List<Basket_To_Order_Field_Map__c> bsktLst = objBasketMap.get(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c);
                bsktLst.add(objBasket);
                this.objBasketMap.put(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c,bsktLst);
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
      public Database.QueryLocator start(Database.BatchableContext bc){
        /* string subscriptionFields = '';
        //Query to fetch the fields to be updated from which object
        List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = Basket_To_Order_Field_Map__c.getall().values();
        for(Basket_To_Order_Field_Map__c objBasket : basketToOrderFieldList){
            if(objBasket.source_object_API_Name__c != null && objBasket.source_object_API_Name__c.equals('csord__Subscription__c')){
                subscriptionFields = String.isNotBlank(subscriptionFields)? subscriptionFields +' , '+ objBasket.Source_Field_Api_Name__c :objBasket.Source_Field_Api_Name__c;
            }
        }*/
        
        //system.debug('subscriptionFields*** ' + subscriptionFields);
        //Added Nickname__c field in query for EDGE-199912 || Aman Soni
        String query = 'SELECT Id,ModelChange__c, Name, csord__Order__c,csord__Order__r.Billing_Account__c,'; 
        query += ' csordtelcoa__Replaced_Subscription__r.Billing_Account__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,';
        query += ' csordtelcoa__Product_Configuration__r.cscfga__originating_offer__c,Nickname__c,csordtelcoa__Replaced_Subscription__r.Nickname__c,';
        query += ' Product_Model_Version__c, serviceMSISDN__c, TON_Barring_Status__c,';//EDGE-218849 - Added TON_Barring_Status__c 
        query += ' csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.OwnerId, MarketableOffer__c,';
        query += ' isAggregationPoint__c,cssdm__solution_association__c, csordtelcoa__Replaced_Subscription__c,csordtelcoa__Replaced_Subscription__r.Parent_Subscription__c,'; 
        query += ' csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Billing_Account__c,';
        query += ' csordtelcoa__Replaced_Subscription__r.csord__Status__c,'; //EDGE-174925
        query += ' csordtelcoa__Replaced_Subscription__r.Initial_Activation_DateTime__c,csordtelcoa__Replaced_Subscription__r.initialActivationDate__c,'; //EDGE-174925
        query += ' csord__Order__r.csord__Primary_Order__c,csord__Order__r.csord__Primary_Order__r.Billing_Account__c,csordtelcoa__Product_Configuration__c,';//edge-98904
        query += ' initialActivationDate__c,Initial_Activation_DateTime__c, csord__Status__c,'; //EDGE-174925 - Added initialActivationDate__c,Initial_Activation_DateTime__c in SOQL
        query += ' partnerAccount__c,csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccountId, csordtelcoa__Replaced_Subscription__r.partnerAccount__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csord__Order__r.csordtelcoa__Opportunity__c'; //EDGE-148371   //EDGE-181982 - added csord__Order__r.csordtelcoa__Opportunity__c in soql
        if(objectToFieldsMap.containsKey('csord__Subscription__c')){
            query += ' , ' + objectToFieldsMap.get('csord__Subscription__c');
        }
        query += ' FROM csord__Subscription__c WHERE csord__Order__r.Id IN: orderIds';
        system.debug('query*** ' + query);
        return Database.getQueryLocator(query);
      }
    
      global void execute(Database.BatchableContext bc, List<csord__Subscription__c> scope) {
        System.debug('---OrderObserverManager_V2---'+scope);
        Set<Id> basketIds = new Set<Id>();   
        Map<Id, csord__Subscription__c> subscriptionMap = new Map<Id, csord__Subscription__c>();
        //EDGE-206835:Added try catch block to handle any query exception or any other exception
        try {   
            for(csord__Subscription__c subInstance : scope){
                if(subInstance.csord__Order__r.csordtelcoa__Opportunity__c!=null){ //added check as part of EDGE-181982
                    basketIds.add(subInstance.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
                }
                orderToBasketMap.put(subInstance.csord__order__c,subInstance.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);//Added Seperately for fetching Basket for all orders
                subscriptionMap.put(subInstance.Id,subInstance);
                orderIdSet.add(subInstance.csord__Order__c);
            }
            if(!subscriptionMap.keyset().isEmpty()) {
                //Query to fetch the fields to be updated from which object
            /* List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = Basket_To_Order_Field_Map__c.getall().values();
                for(Basket_To_Order_Field_Map__c objBasket : basketToOrderFieldList){
                    if(objBasketMap.containsKey(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c)){
                        List<Basket_To_Order_Field_Map__c> BsktLst = objBasketMap.get(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c);
                        BsktLst.add(objBasket);
                        objBasketMap.put(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c,BsktLst);
                    }else{
                    objBasketMap.put(objBasket.source_object_API_Name__c +''+objBasket.target_object_API_Name__c,new List<Basket_To_Order_Field_Map__c> {objBasket});
                    }
                    if(objectToFieldsMap.containsKey(objBasket.source_object_API_Name__c)){
                    String fieldsValue =  objectToFieldsMap.get(objBasket.source_object_API_Name__c) +' ,'+ objBasket.Source_Field_Api_Name__c;
                    objectToFieldsMap.put(objBasket.source_object_API_Name__c,fieldsValue);
                    }else{
                        objectToFieldsMap.put(objBasket.source_object_API_Name__c,objBasket.Source_Field_Api_Name__c);
                    }
                }*/
                Set<Id> subIds = new Set<id>();
                subIds = subscriptionMap.keySet();
                //edge-98904//EDGE-107845 || Added Cancellation_Reason__c | EDGE-105060(Added by Aman Soni) || added basket.Name field in query as part of DPG-697 || Added Billing_Account__c by Shubhi/Aman EDGE-142085
                //Added changeType__c,Action_Type__c,csordtelcoa__Replacement_Service__c as part of EDGE-174924
                //Added Initial_Activation_DateTime__c,Initial_Activation_Date__c,csord__Activation_Date__c as part of EDGE-174925
                //Added  mainCharge__r.Type__c,Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c as a part of EDGE-170949/170948
                string serviceQuery = 'SELECT Id, Name, ModelChange__c, csord__Service__c, Scenario_Type__c,';
                serviceQuery += 'csordtelcoa__Service_Number__c, Service_FNN__c, Cust_Req_Disconn_Date__c , ';
                serviceQuery += 'csord__Subscription__c, Contract_Term__c, ';
                serviceQuery += 'Appointment_Required__c, csord__Order_Request__c, ';
                serviceQuery += 'csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c, ';
                serviceQuery +='csord__Order__r.csordtelcoa__Opportunity__r.Type,';//EDGE-207018
                serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c,';
                serviceQuery += 'Product_Model_Version__c, csord__Order__r.isAppointmentCompleted__c,csordtelcoa__Product_Configuration__c,';
                serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Quantity__c,';
                serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, ';
                serviceQuery += 'International_Direct_Dial__c, ';//Added by Vamsi for EDGE-201613 on 15MAR2021
                serviceQuery += 'addOnCharge__r.addOn_Name__c, ';//Added by Vamsi for EDGE-201613 on 15MAR2021
                serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name, ';
                serviceQuery += 'csoe__Quantity_Decomposition_JSON__c, csordtelcoa__Product_Basket__r.OwnerId, ';
                serviceQuery += 'csordtelcoa__Product_Configuration__r.Marketable_Offer__c, ';
                serviceQuery += 'toBeCancelled__c,Transition_Id__c, ';
                serviceQuery += 'mainCharge__r.Type__c,';
                serviceQuery += 'csord__Subscription__r.csord__Account__c,';
                serviceQuery += 'Billing_Account__r.Billing_Account_Owner__c,';
                serviceQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csord__Order__c, ';
                serviceQuery += 'Initial_Activation_DateTime__c, Initial_Activation_Date__c, csord__Activation_Date__c, ';
                serviceQuery += 'csordtelcoa__Replaced_Service__r.csord__Status__c, ';//EDGE-174925
                serviceQuery += 'csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c, csordtelcoa__Replaced_Service__r.csord__Activation_Date__c,';//EDGE-174925
                serviceQuery += 'changeType__c, csordtelcoa__Replacement_Service__c,csord__Status__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csord__Subscription__r.csord__Status__c,csordtelcoa__Replaced_Service__r.serviceMSISDN__c, '; //added csord__Status__c in soql // EDGE-195797 - removed action_type__c as it is added in Custom Setting (BasketToOrder)
          serviceQuery += 'csordtelcoa__Product_Configuration__r.Type__c,'; //DIGI-6778
				serviceQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c, '; //DIGI-38789,DIGI-39435
                serviceQuery += 'RunTimePCGUID__c,RunTimeParent__c';//JJ: Orchestration changes as per new design

                if(objectToFieldsMap.containsKey('csord__Service__c')){
                    //serviceQuery += ' , ' + '\'' + String.escapeSingleQuotes(objectToFieldsMap.get('csord__Service__c'))+ '\'';
                    serviceQuery += ' , ' + objectToFieldsMap.get('csord__Service__c');
                }
                serviceQuery += ' FROM csord__Service__c WHERE csord__Subscription__r.Id IN: subIds ';
                System.debug('serviceQuery*** '+serviceQuery);
                Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(serviceQuery));
                /*Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>(
                                                            [SELECT Id, Name, ModelChange__c, csord__Service__c, NetworkServiceId__c, Scenario_Type__c, 
                                                            csordtelcoa__Service_Number__c, Service_FNN__c, Cust_Req_Disconn_Date__c , 
                                                            SiteId__c, csord__Subscription__c, Serviceability_Location__c, Contract_Term__c, 
                                                            Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, 
                                                            csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c,
                                                            Product_Model_Version__c, csord__Order__r.isAppointmentCompleted__c,csordtelcoa__Product_Configuration__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Quantity__c,serviceMSISDN__c, Not_Before_CRD__c, 
                                                            Preferred_CRD__c, International_Calling__c, Call_Control__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                                                            csoe__Quantity_Decomposition_JSON__c, csordtelcoa__Product_Basket__r.OwnerId,
                                                            csordtelcoa__Product_Configuration__r.Marketable_Offer__c,isAggregationPoint__c,Cancellation_Reason__c,
                                                            Billing_Account__c,autoExpiry__c,toBeCancelled__c,Transition_Id__c,
                                                            csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csord__Order__c
                                                            FROM csord__Service__c WHERE csord__Subscription__r.Id IN: subscriptionMap.keySet()]);
                */
                Map<Id,String> pcWithServiceId = new Map<Id,String>();
                List<String> serviceNumLst = new List<String> ();
                List<Id> pcIdSet = new List<Id>();
                List<Id> opptyId = new List<Id>();
                List<String> pcGUID = new List<String>();//JJ: Orchestration changes as per new design
                for(csord__Service__c serRec : serviceMap.values()){
					String channelFrom = '';
                    if(serRec.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null){
                        channelFrom = serRec.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c;
                    }//added for Ted-81/DIGI-38789
                    if(serRec.csord__Order__r.csordtelcoa__Opportunity__c!=null || channelFrom == 'TED-81 onlineAPI'){ //added check as part of EDGE-181982 //added channelfrom check for Ted-81/DIGI-38789,DIGI-39435
                        pcIdSet.add(serRec.csordtelcoa__Product_Configuration__c);
                        serviceNumLst.add(serRec.csordtelcoa__Service_Number__c);
                        pcWithServiceId.put(serRec.csordtelcoa__Product_Configuration__c,serRec.csordtelcoa__Service_Number__c);
                        if(serRec.csord__Order__r.csordtelcoa__Opportunity__c != null){
                            opptyId.add(serRec.csord__Order__r.csordtelcoa__Opportunity__c);
                        }
                        //JJ-Start: Orchestration changes as per new design
                        if(serRec.RunTimePCGUID__c != ''){
                            pcGUID.add(serRec.RunTimePCGUID__c);
                        }
                        //JJ-Start: Orchestration changes as per new design
                    }
                }
                Map<Id,Number__c> numberMap = new Map<Id,Number__c>([SELECT Id,Name,Product_Configuration__c,Product_Configuration__r.subType__c,Service_Id__c,Service_Number__c,Basket__c,
                                                                        Basket__r.csbb__Account__c,Type__c,IMSI__c,Sim_Serial_Number__c,Transition_Id__c,
                                                                        toBeCancelled__c,Status__c ,SimAvailabilityType__c  
                                                                        FROM Number__c 
                                                                        WHERE Product_Configuration__c in :pcIdSet or Service_id__c in: serviceNumLst]);
                //EDGE-174220 : added SimAvailabilityType__c  
                Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap   =   new Map<Id, ContractJunction__c>();
                Map<Id, ContractJunction__c> contractJunctionMap    =   new Map<Id, ContractJunction__c>(
                                                                                [SELECT Id, Related_Basket__c,Contract_Start_Date__c, CreatedDate 
                                                                                    FROM ContractJunction__c WHERE Related_Basket__c IN:basketIds 
                                                                                    ORDER BY CreatedDate DESC]);
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

                //JJ-Start: Orchestration changes as per new design
                //Used feature toggling to populate RunTimeParent field based on RunTimePCGUID field
                //To populate this field signature of methods have been updated in both helper and utility classes
                if(FeatureEligibilityChecker.determineFeatureEligiblity('Orchestration','batchProcess')){
                    Map<String, String> pcGUIDServiceMap = new Map<String, String>();
                    for(csord__Service__c ser: [Select Id, RunTimePCGUID__c From csord__Service__c Where csordtelcoa__Product_Configuration__r.configGUID__c In :pcGUID and csordtelcoa__Replacement_Service__c = Null]){
                        pcGUIDServiceMap.put(ser.RunTimePCGUID__c,ser.Id);
                    }
                    FinalserviceMap.putAll(OrderObserverHelper_V2.performOrderOperationsInChucks(subscriptionMap, serviceMap, basketIdToContractJunctionRecMap,numberMap,opptyId,serviceAttachmentMap,objBasketMap,basketIds,scope,pcGUIDServiceMap));
                    //OrderObserverHelper_V2.createRelationShip(serviceMap);
                    pfSequence = UpdateParentSpecAttEvent.updateParentSpecAttr(subscriptionMap.keySet(), orderIdSet, pfSequence, cacheHandler);//JJ: Orchestration changes
                }else{
                    FinalserviceMap.putAll(OrderObserverHelper_V2.performOrderOperationsInChucks(subscriptionMap, serviceMap, basketIdToContractJunctionRecMap,numberMap,opptyId,serviceAttachmentMap,objBasketMap,basketIds,scope,null));
                }
                //JJ-End: Orchestration changes as per new design

                //START: Modified for EDGE-207179
                //finalserviceMap.putAll(OrderObserverHelper_V2.performOrderOperationsInChucks(subscriptionMap, serviceMap, basketIdToContractJunctionRecMap,numberMap,opptyId,serviceAttachmentMap,objBasketMap,basketIds,scope)); 
                //END: EDGE-207179    
            }   //End of if(!orderIdSet.isEmpty()) 
            //if(test.isRunningTest()) { throw (new IllegalArgumentException()); }

           

        } catch (Exception e) {
            Map<Id,csord__Order__c> updatedOrders = new Map<Id,csord__Order__c>();
            for(csord__Subscription__c objSub: subscriptionMap.values()){
                csord__Order__c objOrders = new csord__Order__c(Id = objSub.csord__Order__c,csord__Status2__c = 'Order Decomposition Failed',Observer_Message__c = e.getMessage().left(255));
                updatedOrders.put(objSub.csord__Order__c,objOrders);
            }
            OrderObserverUtil_V2.updateOperation(updatedOrders,null,null,null);
        }
    } //End of executeOrders()
    
    public void finish(Database.BatchableContext bc){
        //Added IOTMSISDNRequired__c field in Order query as part of DPG-697
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>(
            [SELECT Id,csord__Account__c,csord__Order_Type__c,Product_Basket__c,csord__Account__r.cidn__c,csord__Order_Number__c,ModelChange__c,
                Name,IOTMSISDNRequired__c,Scenario_Type__c,csordtelcoa__Opportunity__r.type,csord__Order_Request__c,csordtelcoa__Opportunity__c,csord__Status2__c 
                FROM csord__Order__c WHERE Id IN:orderIdSet]); //EDGE-206835: Added field csord__Status2__c in query

        List<Id> ordrIds = new List<Id>();
        ordrIds = orderToBasketMap.values();
        string basketQuery = 'SELECT NAME, BasketType__c, channelFrom__c ';
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
        OrderObserverHelper_V2.performFinalOrderUpdates(orderMap,basketMap,orderToBasketMap,finalserviceMap,orderRecordTypeNameToIdMap,objBasketMap);
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
        OrdFinalTransactionlogs(orderMap.values());
        }
    }
    public static void OrdFinalTransactionlogs(List<csord__Order__c> orderList){
        //determine featureEligibility for logged in user. Params - metadataname, flowName
      //if(!FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
       // List<csord__Order__c> Ordrlst = new List<csord__Order__c>();
       for(csord__Order__c Ordrlst: orderList){
        String OrderName = Ordrlst.csord__Order_Number__c;
        String orderType = Ordrlst.csordtelcoa__Opportunity__r.type;
        String event = 'Order generation completed';
        String basketId = Ordrlst.Product_Basket__c!= null && String.ValueOf(Ordrlst.Product_Basket__c).length()>= 15?
        String.ValueOf(Ordrlst.Product_Basket__c).subString(0,15) : '';
        String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + Ordrlst.Id;
      if(String.isNotBlank(basketId)){
        cscfga__Product_Basket__c pb=Model_ProductBasket.getProductBasketonLoadSolution(basketId);
        if(pb!=null){
            Map<String,Object> loggerdetailsMap=new Map<String,Object>();
            string correlationId=pb.cscfga__Opportunity__c+'-'+basketId;
            loggerdetailsMap.put('event',event);
            loggerdetailsMap.put('OrderType',OrderType);
            loggerdetailsMap.put('OrderName',OrderName);
            loggerdetailsMap.put('URL',URL);
            
            //loggerdetailsMap.put('Quantity',quantity);
            system.debug('OrderTLogs'+ loggerdetailsMap);
            TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'OrderObserverManager_V2');
            }
        }
    }
    //}
    }
} //End of OrderObserverManager_RfctrngV1