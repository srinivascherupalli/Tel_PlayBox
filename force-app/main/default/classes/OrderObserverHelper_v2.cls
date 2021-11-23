/*********************************************************************************************************************************
 *Class Name      :   OrderObserverHelper_v2

Test Class : OrderObserverManager_Test_v2
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Rohit  Tripathi       18/7/2019       EDGE-88787->Enhancements to Conditional Decomposition of EDM(Removing Tactical Fix)
2.            Pawan Devaliya        11-June-2020    EDGE-136966 & EDGE-136271 : Added Method call
3.            Payal Popat           03-Sept-2020    EDGE-172953->Refactored the classes
4.            Vaibhav Deshpande     02-Nov-2020     EDGE-181982 added changes for non commercial order
5.            Pooja Bhat            10-Mar-2021     EDGE-206835 <Incident# INC000095105856> In MACD Add New Order BAN is missing in solution subscription RTB hence RTB failed
6.            Akanksha  jain        23/02/2021      EDGE-200291 added changes for CHOWN order
7.            Prajakta patil        30/06/2021      EDGE-216816 : added of populateAssetFields method and updated updateoperation method with assetMap parameter
8.            Pooja Gupta           3/06/2021       EDGE-222687: Incident# INC000096079513- order submission date is not populated on blank SIM order
9.            Prajakta Patil        25/08/2021      EDGE-216816 : revert from here and added to chwon pre-requisite orch
10.           Arun V                19/10/2021      DIGI-9361 : EnrichBaske and CreateOrder api
**********************************************************************************************************************************/
//JJ-Start: Orchestration changes as per new design
//Updated signature with a new map
public with sharing class OrderObserverHelper_v2 {
    //START: Modified for EDGE-207179       
    public static Map<Id,csord__Service__c> performOrderOperationsInChucks(Map<Id, csord__Subscription__c> subscriptionMap, Map<Id, csord__Service__c> serviceMap, Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap,
                                                        Map<Id,Number__c> numberMap,List<Id> opptyId,Map<id,Orchestration_AttachmentWrapper> serviceAttachmentMap,Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap, Set<Id> basketIds,List<csord__Subscription__c> scope,Map<String, String> pcGUIDServiceMap){       
    //END: EDGE-207179       
        
        try{
            //Calling Methods to do populate appropriate fields in order
            //Methods called are in order, DO NOT Update the sequence of calling the method: Start
            numberMap = OrderObserverUtil_V2.populateNumberFields(serviceMap,numberMap);
            
            serviceMap = OrderObserverUtil_V2.populateServiceFields(numberMap,serviceMap,serviceAttachmentMap,opptyId,pcGUIDServiceMap);//JJ: Orchestration changes as per new design, update signature
            subscriptionMap = OrderObserverUtil_V2.populateSubscriptionFields(subscriptionMap,serviceMap,basketIdToContractJunctionRecMap,objBasketMap,basketIds,scope);
            //Methods called are in order, DO NOT Update the sequence of calling the method: End
           
            //Below Method is the final method which performs DML on required object
      
     
      
           OrderObserverUtil_V2.updateOperation(null,numberMap,serviceMap,subscriptionMap);
        }
        catch(Exception e){
           
            
            Map<Id,csord__Order__c> updatedOrders = new Map<Id,csord__Order__c>();
            for(csord__Subscription__c objSub: subscriptionMap.values()){
                csord__Order__c objOrders = new csord__Order__c(Id = objSub.csord__Order__c,csord__Status2__c = 'Order Decomposition Failed',Observer_Message__c = e.getMessage().left(255));
                  updatedOrders.put(objSub.csord__Order__c,objOrders);
            }
            OrderObserverUtil_V2.updateOperation(updatedOrders,null,null,null);
        }
        
        return serviceMap;
    } 
    public static void performFinalOrderUpdates(Map<Id, csord__Order__c> orderMap, Map<Id, cscfga__Product_Basket__c> basketMap, Map<Id, Id> orderIdTobasketIdMap, Map<Id, csord__Service__c> serviceMap,
    Map<String, Id> orderRecordTypeNameToIdMap,Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap){
     
       try{
           //Add Existing code piece, after refactoring
            String str_TRUE                         =   'true';
            String str_APP_VERSION                  =   '2';
            String enableOrderPrerequisite          =   EnvironmentVariable__c.getValues('enableOrderPrerequiste').Value__c;
            String enableMSISDN                     =   EnvironmentVariable__c.getValues('enableMSISDN').Value__c;
            String apptVersion                      =   EnvironmentVariable__c.getValues('AppointmentVersion').Value__c;
            Map<Id,csord__Order__c> successOrderMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> OrdPreReqMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> orderChownMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> OrdFulfilmentMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> CommercialOrderMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> NonCommercialOrderMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> AllOrderMap =   new Map<Id,csord__Order__c>();
            for(csord__Order__c ord : orderMap.values()){ //added as part of EDGE-181982
                //EDGE-206835:Added condition not to proceed with Order Update and Orchestration process, if any failure with Subscription, Service, Number update.
                if(ord.csord__Status2__c != 'Order Decomposition Failed') { 
                    if(ord.csordtelcoa__Opportunity__c!=null || (orderIdTobasketIdMap.containskey(ord.id) && basketMap.containskey(orderIdTobasketIdMap.get(ord.id)) && basketMap.get(orderIdTobasketIdMap.get(ord.id)).channelFrom__c =='TED-81 onlineAPI')){ //added condition for DIGI-9361
                        CommercialOrderMap.put(ord.id,ord);
                    } else {
                        ord.csord__Status2__c ='Submitting';
                        ord.RecordTypeId = orderRecordTypeNameToIdMap.get('Order Submitted');
                        ord.telstra_ord_Start_DateTime__c = System.Now();//EDGE-222687
                        /*cscfga__Product_Basket__c pb = basketMap.get(orderIdTobasketIdMap.get(ord.id));
                        if(!String.isBalnk(pb.description__c)){
                        ord.Name = pb.description__c;  
                        }else{*/
                        ord.Name = 'Non-Commercial_'+ ('0' + String.valueOf(Date.today().day())).right(2) + ( '0' + String.valueOf(Date.today().month())).right(2) + Date.today().year() +'_'+ String.valueOf(System.now().time()).left(8) ;
                        //}
                        if(orderIdTobasketIdMap.containsKey(ord.id)){
                            ord.Product_Basket__c = orderIdTobasketIdMap.get(ord.id);
                        }
                        //Order name change remaining - check linked basket.Description__c !='', then keep the order name as description field
                        //link product basket on order
                        NonCommercialOrderMap.put(ord.id,ord);
                    }
                //EDGE-206835:Added condition to remove OrderId from orderIdTobasketIdMap to avoid Null Pointer exception while processing order.
                } else if(orderIdTobasketIdMap.containsKey(ord.id)) { 
                    orderIdTobasketIdMap.remove(ord.id);
                }
            }
                if(enableOrderPrerequisite.equalsIgnoreCase(str_TRUE)) {
                    CommercialOrderMap = OrderObserverUtil_V2.executeOrderPrerequisiteMsisdn(CommercialOrderMap,serviceMap,orderRecordTypeNameToIdMap,true,false);
                    } else if(enableMSISDN.equalsIgnoreCase(str_TRUE)) {
                    CommercialOrderMap = OrderObserverUtil_V2.executeOrderPrerequisiteMsisdn(CommercialOrderMap,serviceMap,orderRecordTypeNameToIdMap,false,true);
                    } else if(apptVersion.equalsIgnoreCase(str_APP_VERSION)) {
                    CommercialOrderMap = OrderObserverUtil_V2.executeOrderPrerequisiteMsisdn(CommercialOrderMap,serviceMap,orderRecordTypeNameToIdMap,false,false);
                    }
            AllorderMap.putAll(CommercialOrderMap); 
            AllorderMap.putAll(NonCommercialOrderMap);  
         
            AllorderMap = OrderObserverUtil_V2.outputMapBasketFieldsToOrderFields(AllorderMap, basketMap, orderIdTobasketIdMap,objBasketMap);
            successOrderMap.putAll(OrderObserverUtil_V2.updateOperation(AllorderMap,null,null,null));
            OrderObserverUtil_V2.publishEventforNewOrders(JSON.serialize(successOrderMap));
          
            for(csord__Order__c ord : successOrderMap.values())  //added as part of EDGE-181982
            {
             //    system.debug('type:'+ord.Product_Basket__c);
            //    system.debug('type:'+ord.Product_Basket__r.BasketType__c);
                //if(orderChownMap.isEmpty() && !orderChownMap.containsKey(ord.id) ){
               
               
                if(orderIdTobasketIdMap.containskey(ord.id) && basketMap.containskey(orderIdTobasketIdMap.get(ord.id))  && basketMap.get(orderIdTobasketIdMap.get(ord.id)).BasketType__c =='Incoming'){
                    orderChownMap.put(ord.id,ord);
                }else if(orderIdTobasketIdMap.containskey(ord.id) && basketMap.containskey(orderIdTobasketIdMap.get(ord.id))  && basketMap.get(orderIdTobasketIdMap.get(ord.id)).BasketType__c!='Outgoing') // EDGE-200291 added CHOWN OUT condition
                {
                    system.debug('inside if');
                     if(ord.csordtelcoa__Opportunity__c!=null || (orderIdTobasketIdMap.containskey(ord.id) && basketMap.containskey(orderIdTobasketIdMap.get(ord.id)) && basketMap.get(orderIdTobasketIdMap.get(ord.id)).channelFrom__c =='TED-81 onlineAPI'))
                    {
                        OrdPreReqMap.put(ord.id,ord);
                        system.debug('OrdPreReqMap:'+OrdPreReqMap);
                        
                    }
                    else{
                        OrdFulfilmentMap.put(ord.id,ord);
                    }
                }
                //}
                
               
            }
            
            if(!orderChownMap.isEmpty()){
                ManageOrdPrereqisteOrchestrationHandler.createChownOrchestrationProcess(orderChownMap);
            }else if(enableOrderPrerequisite.equalsIgnoreCase(str_TRUE) && !OrdPreReqMap.isEmpty() /*&& !FeatureEligibilityChecker.determineFeatureEligiblity('Orchestration','batchProcess')*/) {
                ManageOrdPrereqisteOrchestrationHandler.createOrchestrationProcess(new List<Id>(OrdPreReqMap.keySet()));
            }
            
            if(!OrdFulfilmentMap.isEmpty()) //added as part of EDGE-181982
            {
                SubmitOrderOrchestration.createOrderOrchestrationProcessBulk(OrdFulfilmentMap);
            }
            //Note: orderMap need to be saved to DB - Database.update(orderMap,false);
            if(test.isRunningTest()) { throw (new IllegalArgumentException()); }
        } catch(Exception e) {
            Map<Id,csord__Order__c> updatedOrders = new Map<Id,csord__Order__c>();
            for(csord__Order__c objOrdr: orderMap.values()){
                csord__Order__c objOrders = new csord__Order__c(Id = objOrdr.Id,csord__Status2__c = 'Order Decomposition Failed',Observer_Message__c = e.getMessage().left(255));
                updatedOrders.put(objOrdr.Id,objOrders);
            }
            OrderObserverUtil_V2.updateOperation(updatedOrders,null,null,null);
        }
       
    }   
}