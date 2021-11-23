/**
 * @description       : Site Trigger handler class
 * @Description       : DIGI-15723 Added ProductchargeZone changes in site trigger
 * @last modified on  : 10-12-2021
 * @last modified by  : Ajith Kumar
 * 
 * Notes:
 *  * Included updateNBNLocationId() method in before insert trigger
**/

public with sharing class SiteTriggerHandler {
    
    private SiteTriggerHelper stHelper = null;
    
    public SiteTriggerHandler(){
        stHelper = new SiteTriggerHelper();
    }
    
    public void OnBeforeInsert(cscrm__Site__c[] newSites){
        stHelper.updateNBNLocationId(newSites);
    }

    public void OnAfterInsert(cscrm__Site__c[] newSites){
        SiteTriggerHelper.createProductchargeZoneInfo(Trigger.newMap.keyset());//DIGI-15723 created the helper method call
        SiteTriggerHelper.createSiteContactRoles(newSites);
        stHelper.publishCreateEvents(newSites,EventConstants.CREATE_OPERATION);
    }

    public void OnBeforeUpdate(cscrm__Site__c[] oldSites, cscrm__Site__c[] updatedSites, 
                               Map<ID, cscrm__Site__c> newSitesMap){
    }

    public void OnAfterUpdate(cscrm__Site__c[] oldSites, Map<ID, cscrm__Site__c> oldSitesMap, 
                                cscrm__Site__c[] updatedSites, Map<ID, cscrm__Site__c> updateSitesMap){
        SiteTriggerHelper.updateSiteContactRoles(oldSites,oldSitesMap,updatedSites,updateSitesMap);
        stHelper.publishCreateEvents(updatedSites,EventConstants.UPDATE_OPERATION);
   }

    public void OnAfterDelete(cscrm__Site__c[] deletedSites, Map<ID, cscrm__Site__c> sitesMap){

    }
}