/*************************************************************************************************************************************************
Developer: Pawan Devaliya
Description: Dec 22,2020
changes for EDGE-170547
=====================================================================================================================================================
No      Name            Date            Description
1.      Gnana           10/02/2021      EDGE-195797 - Added logic to update Service Version based on Action Type
2.      Akanksha        19/02/2021      EDGE-207474 - Added logic to generate transient JSON for Inflight order
3.      Pawan           29/04/2021      EDGE-217129 : Keeping base basket contract for non-com inflight changes
*************************************************************************************************************************/

public with sharing class InFlightOrderObserverUtil_V1 {
    
    /*Method Name: outputMapBasketFieldsToOrderFields
    * Purpose : populates Basket fields from Basket and Subscription Object
    * params : orderMap, BasketMap,SubscriptionMap
    * Return Type : void
    * Called from : OrderObserverHelper
    */
    public static Map<Id, csord__Order__c> outputMapBasketFieldsToOrderFields(Map<Id, csord__Order__c> orderMap, Map<Id, cscfga__Product_Basket__c> basketMap, Map<Id, Id> orderIdToBasketIdMap,Map<String,List<Basket_To_Order_Field_Map__c>> objBasketMap){
        System.debug('orderMap1:: '+orderMap);
        System.debug('basketMap1:: '+basketMap);
        System.debug('orderIdToBasketIdMap1:: '+orderIdToBasketIdMap);
        System.debug('objBasketMap1:: '+objBasketMap);
        Map<Id,csord__Order__c> ordersToUpdateList= new Map<Id,csord__Order__c>();
        /*if(!(fieldsToUpdateSize > 0)){
            return orderMap;
        }*/
        for(Id orderId: orderIdToBasketIdMap.keyset()){
            csord__Order__c orderInstance= new csord__Order__c();
            orderInstance = orderMap.get(orderId) ;
            Id basketId = orderIdToBasketIdMap.get(orderId);
            if(objBasketMap.containsKey('cscfga__Product_Basket__c'+'csord__Order__c')){
                List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('cscfga__Product_Basket__c'+'csord__Order__c');
                
                for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                    //orderInstance.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,basketMap.get(basketId).get(basketToOrderFieldList[i].Source_Field_Api_Name__c));
                    Object fieldVal = OrderObserverUtil_V2.getFieldValue((Sobject) basketMap.get(basketId),basketToOrderFieldList[i].Source_Field_Api_Name__c);
                    if(fieldVal != null){
                    orderInstance.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                    }
                }                
            }
            orderInstance.Fulfilment_Order_Version__c += 1;
            orderInstance.isTransientComplete__c = false;// EDGE-207474  to genreate transient json for Inflight
            
            ordersToUpdateList.put(orderInstance.Id,orderInstance);
        }
        
        return ordersToUpdateList;  
    }
    

    /*Method Name: populateServiceFields
    * Purpose : populates Service fields from Number Object/SelfLookup field
    * params : ServiceMap, NumberMap, serviceAttachmentMap
    * Return Type : Map<Id,csord__Service__c> 
    * Called from : OrderObserverHelper
    * Disclamer :
    */
    public static Map<Id,csord__Service__c> populateServiceFields(Map<Id, Number__c> numberMap,Map<Id,csord__Service__c> serviceMap, Map<Id,Orchestration_AttachmentWrapper> serviceAttachmentMap,List<Id> oppId){

        Map<Id,csord__Service__c> serviceListToUpdate = new Map<Id,csord__Service__c>();   
        for (csord__Service__c servObj : serviceMap.values()){
            system.debug('servObj'+servObj);
            servObj.Product_Model_Version__c = servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c;
            
            //Logic to update svc version start
            if(String.isBlank(servObj.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) ||
            servObj.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'){
            if(String.isNotBlank(servObj.Action_Type__c) && servObj.Action_Type__c.contains('Rollback')){ // Logic to check Rollback Amend/Cancel - EDGE-195797
                servObj.Version__c -= 1      ;
            }
            else if(servObj.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && 
               servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c==servObj.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c){
                servObj.Version__c += 1;             
            }
            else{
                 servObj.Version__c = 1;     
            }
        }
            //logic to update svc version end
                
            //logic to update change type on service start
             if(String.isBlank(servObj.changeType__c)){
                if(String.isNotBlank(servObj.Scenario_Type__c)){
                    servObj.changeType__c = servObj.Scenario_Type__c == 'Transition with Inactive Sim' ? 'Transition' : servObj.Scenario_Type__c;
                }
                else if(servObj.Action_Type__c != null && servObj.Action_Type__c == 'PayOut'){
                    servObj.changeType__c = 'PayOut';
                }
                else if(servObj.toBeCancelled__c == 'true'){
                    servObj.changeType__c = 'Cancel';
                }
                else if(String.isNotBlank(servObj.csordtelcoa__Replacement_Service__c)){
                    servObj.changeType__c = 'Modify';
                }
                else if(String.isBlank(servObj.csordtelcoa__Replacement_Service__c)){
                    servObj.changeType__c = 'New';
                }
                System.debug('servObj.changeType__c...'+servObj.changeType__c);
            }
            //logic to update change type on service end

            serviceListToUpdate.put(servObj.Id,servObj);
            }
        

        system.debug('serviceListToUpdate '+serviceListToUpdate);
        return serviceListToUpdate;
    }


    /*Method Name: populateSubscriptionFields
    * Purpose : populates Subscription fields from Service Object/ Subscription Object/Number Object/ContractJunction Object
    * params : ServiceMap, NumberMap,ContractJunction Map, Subscription Map
    * Return Type : updated SubscriptionMap
    * Called from : OrderObserverHelper
    * Disclamer : This Method should always be called after updating Services subscriptions are updated based on services
    */
    public static Map<Id,csord__Subscription__c> populateSubscriptionFields(Map<Id,csord__Subscription__c> subListToUpdate, Map<Id,csord__Service__c> serviceMap,Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap,Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap, Map<Id,Id> orderToBasketMap){

        for (csord__Service__c servObj : serviceMap.values()){
            if(servObj.csord__Service__c==null){
                csord__Subscription__c updSub = subListToUpdate.get(servObj.csord__Subscription__c)!=null ? subListToUpdate.get(servObj.csord__Subscription__c) 
                                                    : new csord__Subscription__c(ID = servObj.csord__Subscription__c);
                system.debug('objBasketMap '+objBasketMap);
                //if(servObj.csord__Order__r.csordtelcoa__Opportunity__c!=null){
                if(objBasketMap.containsKey('csord__Service__c'+'csord__Subscription__c')){
                    List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('csord__Service__c'+'csord__Subscription__c');
                    for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                    if(servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) !== '' || servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) != null){
                        Object fieldVal = OrderObserverUtil_V2.getFieldValue((Sobject) servObj,basketToOrderFieldList[i].Source_Field_Api_Name__c);
                        if(fieldVal != null){
                            updSub.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                        }
                    }
                    }
                }
                if(objBasketMap.containsKey('csord__Subscription__c'+'csord__Subscription__c')){
                    List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('csord__Subscription__c'+'csord__Subscription__c');
                    for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                        system.debug('updSub=='+updSub);
                        system.debug('testupdSub=='+basketToOrderFieldList[i].Source_Field_Api_Name__c);

                        Object fieldVal = OrderObserverUtil_V2.getFieldValue((Sobject)updSub,basketToOrderFieldList[i].Source_Field_Api_Name__c);
                        if(fieldVal != null){
                            updSub.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                        }
                 
                    }
                }
                
                // Update changeType__c of parent service on subscription
                if(String.isNotBlank(servObj.changeType__c)){
                    updSub.changeType__c = servObj.changeType__c;
                }
        
                //Update Contract related details on subscription start
                //EDGE-217129 : As there is no new contract for Inflight so keeping exiting only if new basket have no new contract
                if(basketIdToContractJunctionRecMap != null && basketIdToContractJunctionRecMap.get(updSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c)!=null){
                updSub.ContractJunction__c =  basketIdToContractJunctionRecMap.get(updSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c).Id;
                updSub.Contract_Start_Date__c = basketIdToContractJunctionRecMap.get(updSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c).Contract_Start_Date__c; 
                    
                }
                
                
                //Update contract related details on subscription end
                
                //Update order version on subscription 
                // Added Rollback logic as part of EDGE-195797
               // System.debug('Subs Action Type...'+updSub.Action_Type__c);
               //Added null check for updSub.Action_Type__c : EDGE-212832
                if((updSub != null && updSub.Action_Type__c != null && String.isNotBlank(updSub.Action_Type__c) && !updSub.Action_Type__c.contains('Rollback')) && orderToBasketMap.get(servObj.csord__Order__c) == updSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c && (String.isBlank(updSub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) ||
                updSub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent')){
                    System.debug('inside increment version...'+servObj.csord__Order__r.Fulfilment_Order_Version__c);
                    updSub.orderversion__c = servObj.csord__Order__r.Fulfilment_Order_Version__c +1;
                }
            
                subListToUpdate.put(servObj.csord__Subscription__c, updSub);                
            }
        }
        System.debug('subListToUpdate...'+subListToUpdate);
        return subListToUpdate;
    }  
    
    
  }