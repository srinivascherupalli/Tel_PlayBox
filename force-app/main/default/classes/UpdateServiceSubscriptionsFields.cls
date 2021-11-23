/*
 * Class : UpdateServiceSubscriptionsFields
 * Description : to update fields of Service and Subscription before creation.
 * 1. It updates the Replaced Service field of Service for MAC services with correct value as the New MAC flow is not populating this field
 * 2. It updates the Replaced Subscription field of Subscription for MAC services with correct value as the New MAC flow is not populating this field
*/
public with sharing class UpdateServiceSubscriptionsFields {
    public static void updateServiceFields(List<Id> serviceIdList){
        try{
            //Populate list of all services whose product configuration record does not have
            List<csord__Service__c> allServices = [SELECT Id, Name, csord__Order__c, csordtelcoa__Replaced_Service__c, csord__Status__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c from csord__Service__c WHERE id IN: serviceIdList AND csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null];
            System.debug('allServices:::'+allServices);
            
            List<Id> replacedConfigIDs = new List<Id>();
            // get IDs for all replaced configurations from available services
            for (csord__Service__c tempService : allServices) {
                replacedConfigIDs.add(tempService.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);
            }
            // get replaced services
            List<csord__Service__c> replacedServices = [SELECT Id, csordtelcoa__Product_Configuration__c FROM csord__Service__c WHERE csordtelcoa__Product_Configuration__c IN :replacedConfigIDs];
            
            // create map of replaced configuration and replaced service
            Map<Id, Id> replacedConfigReplacedServiceMap = new Map<Id, Id>();
            for (csord__Service__c tmpService : replacedServices) {
                replacedConfigReplacedServiceMap.put(tmpService.csordtelcoa__Product_Configuration__c, tmpService.Id);
            }
            List<csord__Service__c> toUpdateServiceList = new List<csord__Service__c>();
            // iterate through all services and map them to replaced service if empty
            for (csord__Service__c tempService : allServices) {
                if (tempService.csordtelcoa__Replaced_Service__c == null && tempService.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && 
                replacedConfigReplacedServiceMap.get(tempService.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) != null) {
                    tempService.csordtelcoa__Replaced_Service__c = replacedConfigReplacedServiceMap.get(tempService.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);
                    toUpdateServiceList.add(tempService);
                }
            }
            if(toUpdateServiceList.size()>0){
                update toUpdateServiceList;
            }
        }catch(Exception e){
            system.debug('Error in updateServiceFields ' + e);
        }
    }
    
    public static void updateSubscriptionFields(List<Id> subscriptionIdList){
        try{
            //Populate list of all subscriptions whose product configuration record is a MAC
            List<csord__Subscription__c> allSubscriptions = [SELECT Id, Name, csordtelcoa__Replaced_Subscription__c, csord__Status__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c from csord__Subscription__c WHERE id IN: subscriptionIdList AND csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null];
            System.debug('allMACSubscriptions:::'+allSubscriptions);
            
            List<Id> replacedConfigIDs = new List<Id>();
            // get IDs for all replaced configurations from available subscriptions
            for (csord__Subscription__c tempSub : allSubscriptions) {
                replacedConfigIDs.add(tempSub.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);
            }
            // get replaced subscription from the replaced pcs
            List<csord__Subscription__c> replacedSubscriptions = [SELECT Id, csordtelcoa__Product_Configuration__c FROM csord__Subscription__c WHERE csordtelcoa__Product_Configuration__c IN :replacedConfigIDs];
            
            // create map of replaced configuration and replaced subscription ID
            Map<Id, Id> replacedConfigReplacedSubscriptionMap = new Map<Id, Id>();
            for (csord__Subscription__c tempSub : replacedSubscriptions) {
                replacedConfigReplacedSubscriptionMap.put(tempSub.csordtelcoa__Product_Configuration__c, tempSub.Id);
            }
            List<csord__Subscription__c> toUpdateSubscriptionList = new List<csord__Subscription__c>();
            // iterate through all services and map them to replaced service if empty
            for (csord__Subscription__c tempSub : allSubscriptions) {
                if (tempSub.csordtelcoa__Replaced_Subscription__c == null && tempSub.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && 
                replacedConfigReplacedSubscriptionMap.get(tempSub.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c) != null) {
                    tempSub.csordtelcoa__Replaced_Subscription__c = replacedConfigReplacedSubscriptionMap.get(tempSub.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);
                    toUpdateSubscriptionList.add(tempSub);
                }
            }
            if(toUpdateSubscriptionList.size()>0){
                update toUpdateSubscriptionList;
            }
        }catch(Exception e){
            system.debug('Error in updateSubscriptionFields ' + e);
        }
    }
}