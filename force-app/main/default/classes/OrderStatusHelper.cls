public with sharing class OrderStatusHelper
{  
    public static void OrderFieldUpdateExecute(Map<Id, csord__Service__c> serviceMap, Map<Id, csord__Order__c> orderMap, Map<String, Id> orderRecordTypeNameToIdMap, boolean msisdnCheck){
        //Comment out Secondary orders as with new O&S package secondary orders will not be created
        //Map<Id, csord__Order__c> secondaryOrderMap = new Map<Id, csord__Order__c>();
        Map<Id, csord__Order__c> allPrimaryOrderOppIdToOrderMap = new Map<Id, csord__Order__c>();
        Map<Id, csord__Order__c> primaryOrderForMsisdnReserveMap = new Map<Id, csord__Order__c>();
        Map<Id, csord__Order__c> primaryOrderForAppointmentMap = new Map<Id, csord__Order__c>();
        Map<Id, csord__Order__c> primaryOrderForSubmitMap = new Map<Id, csord__Order__c>();
        Map<Id, csord__Order__c> primaryOrderForSubmitWithAppointmentMap = new Map<Id, csord__Order__c>();
        Set<String> msisdnReqdOrderIds = new Set<String>();
        for(csord__Order__c orderInstance : orderMap.values()){
            //if(orderInstance.csord__Primary_Order__c != null){
            //    secondaryOrderMap.put(orderInstance.Id, orderInstance);
            //}else{
                allPrimaryOrderOppIdToOrderMap.put(orderInstance.csordtelcoa__Opportunity__c, orderInstance);
            //}
        }
        system.debug('allPrimaryOrderOppIdToOrderMap >>'+ allPrimaryOrderOppIdToOrderMap);
        for(csord__Service__c serviceInstance : serviceMap.values()){
            if(msisdnCheck == true && serviceInstance.csord__service__c == null){
                system.debug('serviceInstance.Appointment_Required__c  -----'+ serviceInstance.Appointment_Required__c);
                system.debug('serviceInstance.modelChange__c  -----'+ serviceInstance.modelChange__c);
                if(serviceInstance.TechnologyType__c == 'Mobile Access' && serviceInstance.csordtelcoa__Replaced_Service__c == null && !serviceInstance.modelChange__c){
                    system.debug('Mobile Access');
                    system.debug('serviceInstance.csord__Order__r'+serviceInstance.csord__Order__c);
                    system.debug('serviceInstance.csord__Order__r'+serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c);
                    if(allPrimaryOrderOppIdToOrderMap.containsKey(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c)){
                        primaryOrderForMsisdnReserveMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                        msisdnReqdOrderIds.add(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id);
                    }
                }else if(serviceInstance.Appointment_Required__c == 'true' && !serviceInstance.modelChange__c){
                    system.debug('Appoint Access');
                    primaryOrderForAppointmentMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                     
                }else{
                    system.debug('Appoint Access no'+allPrimaryOrderOppIdToOrderMap+'---------'+serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c);
                    primaryOrderForSubmitMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                     
                }
            }else if(serviceInstance.csord__service__c == null){
                if(serviceInstance.csord__Order__r.isAppointmentCompleted__c == false && serviceInstance.Appointment_Required__c == 'true' && !serviceInstance.modelChange__c){
                    primaryOrderForAppointmentMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                }else if(serviceInstance.csord__Order__r.isAppointmentCompleted__c == true && serviceInstance.Appointment_Required__c == 'true' && !serviceInstance.modelChange__c){
                    primaryOrderForSubmitWithAppointmentMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                }else{
                    if(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c != null && allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c) !=null){
                        primaryOrderForSubmitMap.put(allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c).Id, allPrimaryOrderOppIdToOrderMap.get(serviceInstance.csord__Order__r.csordtelcoa__Opportunity__c));
                        //primaryOrderForSubmitMap.keySet().removeAll(primaryOrderForAppointmentMap.keyset());
                    }
                }
            }
        }
        system.debug('111111111'+primaryOrderForMsisdnReserveMap.keyset()+'======'+primaryOrderForAppointmentMap.keyset()+'===='+primaryOrderForSubmitMap.keyset());
        primaryOrderForAppointmentMap.keySet().removeAll(primaryOrderForMsisdnReserveMap.keyset());
        primaryOrderForSubmitMap.keySet().removeAll(primaryOrderForAppointmentMap.keyset());
        primaryOrderForSubmitMap.keySet().removeAll(primaryOrderForMsisdnReserveMap.keyset());
        system.debug('0000000000'+primaryOrderForMsisdnReserveMap.keyset()+'======'+primaryOrderForAppointmentMap.keyset()+'===='+primaryOrderForSubmitMap.keyset());
 
        //OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(secondaryOrderMap.values(), '', orderRecordTypeNameToIdMap.get('Secondary Order'));
        OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(primaryOrderForMsisdnReserveMap.values(), 'MSISDN Required', orderRecordTypeNameToIdMap.get('MSISDN Required'));
        OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(primaryOrderForAppointmentMap.values(), 'Appointment Required', orderRecordTypeNameToIdMap.get('Appointment Required'));
        OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(primaryOrderForSubmitMap.values(), 'Ready for Submit', orderRecordTypeNameToIdMap.get('Ready for Submit'));
        OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(primaryOrderForSubmitWithAppointmentMap.values(), 'Ready for Submit', orderRecordTypeNameToIdMap.get('Ready for Submit With Appointment'));

        if(msisdnReqdOrderIds != null){
            List<String> msisdnReqdOrderIdsList = (List<String>)JSON.deserialize(JSON.serialize(msisdnReqdOrderIds), List<String>.class);
            ManageMSISDNOrchestrationHandler.createMSISDNOrchestrationProcess(msisdnReqdOrderIdsList);
        }else{
              OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(primaryOrderForMsisdnReserveMap.values(),'Appointment Required', orderRecordTypeNameToIdMap.get('Appointment Required'));
        }
    }
}