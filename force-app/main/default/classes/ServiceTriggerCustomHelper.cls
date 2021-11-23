/* 
Author : Abinash Barik 
Company : Telstra
Description : EDGE-126425 Reverse Logistics
History : Initail Version 09/25/2019

===============================================
ChagneSet No    Name            Date                    Description
*/
public with sharing class ServiceTriggerCustomHelper {
    @Future // Removing comment
    public Static void updaterelatedrecords(Set<Id> setOrderIds){
        List<Sobject> lstrecordsTobeUpdated = new List<Sobject>();  
       
        Map<Id,List<csord__Service__c>> mapOrderService = new Map<Id,List<csord__Service__c>>();
        if(!setOrderIds.isEmpty()){
            for(csord__Service__c service : [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                            csord__Subscription__c FROM csord__Service__c WHERE csord__Order__c IN: setOrderIds
                                            AND csord__Order__r.Scenario_Type__c =: Label.Device_Replacement]){
                                           
            if(mapOrderService.containsKey(service.csord__Order__c)){
              mapOrderService.get(service.csord__Order__c).add(Service);
            }else{
              mapOrderService.put(service.csord__Order__c, new List<csord__Service__c> {Service});
            }         
            }
            
            if(!mapOrderService.isEmpty()){
                for(Id orderId: mapOrderService.keySet()){                    
                    List<csord__Service__c> tempService =mapOrderService.get(orderId);
                    List<csord__Service__c> serviceTobeUpdated = new List<csord__Service__c>();
                    List<csord__Subscription__c> SubsTobeUpdated = new List<csord__Subscription__c>();
                    Set<Id> setSubsIds = new Set<Id>();
                    boolean isAllServiceConnected = true;
                    for(csord__Service__c serRec : tempService){
                        if(serRec.csord__status__c != 'Connected'){
                            isAllServiceConnected = false;
                        }
                        if(serRec.Scenario_Type__c == Label.Device_Replacement){
                            if(!setSubsIds.contains(serRec.csord__Subscription__c)){
                                SubsTobeUpdated.add(new csord__Subscription__c(Id = serRec.csord__Subscription__c, csord__Status__c=Label.Replaced_Active));
                              setSubsIds.add(serRec.csord__Subscription__c);
                            }        
                        }else{
                            serRec.csord__status__c = 'Replaced Closed';
                            serviceTobeUpdated.add(serRec);
                            if(!setSubsIds.contains(serRec.csord__Subscription__c)){
                                SubsTobeUpdated.add(new csord__Subscription__c(Id = serRec.csord__Subscription__c, csord__Status__c='Active'));
                                setSubsIds.add(serRec.csord__Subscription__c);
                            }
                            
                        }
                    }
                    if(isAllServiceConnected){
                        lstrecordsTobeUpdated.AddAll(serviceTobeUpdated);
                        lstrecordsTobeUpdated.AddAll(SubsTobeUpdated);
                        lstrecordsTobeUpdated.add(new csord__Order__c(Id = orderId, csord__Status2__c='Completed'));
                    }
                }
                if(!lstrecordsTobeUpdated.isEmpty()){
                    update lstrecordsTobeUpdated;
                }
            }
        }
    }      
}