/*********************************************************************************************************************************
Class Name : NumberGroupTriggerHandler
Test Class : NumberGroupTriggerHandlerTest
Created By : Sonalisa Verma
Created On : 19 Feb 2020
User Story : EDGE - 138136 created trigger to assign coorelation id
===============================================================================================================================*/

public with sharing class NumberGroupTriggerHandler {
    
/**************************************************************************************
****** Desc         : Method to filter records for before update
****** Story        : EDGE-138136
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static void handleBeforeUpdate(List<Number_Group__c> newList, Map<Id, Number_Group__c> oldMap){
        List<Number_Group__c> filteredNumberList = new List<Number_Group__c>();
        for(Number_Group__c ng : newList) {
            // check if Subscription_number__c is changed
            if(ng.Subscription_number__c != null && oldMap.get(ng.Id).Subscription_number__c != ng.Subscription_number__c){
                filteredNumberList.add(ng);
            }
        }
        if(filteredNumberList.size()>0){
            updateServiceInstanceId(filteredNumberList);
        }
    }

/**************************************************************************************
****** Desc         : Method to filter records for before insert
****** Story        : EDGE-138136
****** Developer    : Sonalisa Verma
***************************************************************************************/
    public static void handleBeforeInsert(List<Number_Group__c> newList){
        List<Number_Group__c> filteredNumberList = new List<Number_Group__c>();
        for(Number_Group__c ng : newList) {
            // check if Subscription_number__c is not null
            if(ng.Subscription_number__c != null ){
                filteredNumberList.add(ng);
            }
        }
        if(filteredNumberList.size()>0){
            updateServiceInstanceId(filteredNumberList);
        }
    }

/**************************************************************************************
****** Desc         : Method to assign correlation id to Service_Instance_Id__c
****** Story        : EDGE-138136
****** Developer    : Sonalisa Verma
***************************************************************************************/
    private static void updateServiceInstanceId(List<Number_Group__c> newList) {
        set<string> setSubscriptionNumbers = new set<string>();
        set<Id> setServiceIds = new set<Id>();
        Map<string, string> mapSubscriptionServiceIds = new Map<string, string>();

        for(Number_Group__c ng : newList) {
            setSubscriptionNumbers.add(ng.Subscription_number__c);
        }

        if(setSubscriptionNumbers.size()>0) {
            // get services from subscription number
            List<csord__Service__c> lstService = [Select Id, csord__Subscription__r.csordtelcoa__Subscription_Number__c 
                                                    from csord__Service__c where csord__Subscription__r.csordtelcoa__Subscription_Number__c in : setSubscriptionNumbers
                                                    WITH SECURITY_ENFORCED];
            if(lstService.size()>0) {
                // create map of subscription number to service Id
                for(csord__Service__c ser : lstService){
                    if(!mapSubscriptionServiceIds.containsKey(ser.csord__Subscription__r.csordtelcoa__Subscription_Number__c)){
                        mapSubscriptionServiceIds.put(ser.csord__Subscription__r.csordtelcoa__Subscription_Number__c, ser.Id);
                        setServiceIds.add(ser.Id);
                    }
                }
            }
        }
        if(setServiceIds.size()>0) {
            // fetch service specifications for fulfilment from ServiceSpecification.json based on service Id
            Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = ServiceSpecificationUtils.getServiceSpecFulfilmentMap(setServiceIds);
            if(srvSpecMap.size()>0) {
                for(Number_Group__c ng : newList) {
                    List<CS_SpecificationDTO.ServiceSpecification> spec = srvSpecMap.get(mapSubscriptionServiceIds.get(ng.Subscription_number__c));
                    if(spec.size()>0) {
                        //set coorelation guid to service_Instance_Id__c
                        ng.Service_Instance_Id__c = spec[0].guid;
                    }
                }
            }
        }
    }
	
/**************************************************************************************
****** Desc         : Method to assign End date
****** Story        : DIGI-32827
****** Developer    : Moumita Som
***************************************************************************************/
	
	public static void handleAfterUpdate(Map<Id, Number_Group__c> newMap, Map<Id, Number_Group__c> oldMap){	
        Set<Id> orderIdSet = new Set<Id>();	
        List<csord__Order__c> orderUpdateList = new List<csord__Order__c>();	
        for( Number_Group__c grpObj : newMap.values()){	
            if((oldMap.get(grpObj.Id).Status__c != grpObj.Status__c) && ((grpObj.Status__c == 'Active')||(grpObj.Status__c == 'Inactive'))){	
                orderIdSet.add(grpObj.OrderId__c);	
            }	
        }	
        if(!orderIdSet.isEmpty()){	
            for(csord__Order__c orderObj : [select Id,csord__End_Date__c,telstra_ord_End_DateTime__c	
                                            from csord__Order__c where Id =: orderIdSet	
                                            and Scenario_Type__c = 'Manage Fixed Numbers']){	
                                                orderObj.csord__End_Date__c = Date.today();	
                                                orderObj.telstra_ord_End_DateTime__c = System.now();
                                                orderObj.csord__Status2__c = 'Completed';
                                                orderUpdateList.add(orderObj);	
                                            }	
        }	
        if(!orderUpdateList.isEmpty()){	
            update orderUpdateList;
		}
	}
}