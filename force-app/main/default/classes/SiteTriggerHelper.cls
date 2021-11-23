/**
 * @description       : Site trigger helper class
 * @Description       : DIGI-15723 Added ProductchargeZone changes in site trigger
 * @last modified on  : 10-12-2021
 * @last modified by  : Ajith Kumar
 * Notes:
 * * updateNBNLocationId method added
**/


public with sharing class SiteTriggerHelper {

  @testVisible
    private static final String ROLE_PRIMARY = 'Primary';
  @testVisible
    private static final String ROLE_SECONDARY = 'Secondary';

  /*
   * Method to create site roles for primary and secondary contacts
  */
    public static void createSiteContactRoles(cscrm__Site__c[] newSites){
        List<Site_Contact_Role__c> roles = new List<Site_Contact_Role__c>();

        for(cscrm__Site__c st : newSites){
            if(st.Primary_Contact__c!=null){
                roles.add(createSCR(st.Primary_Contact__c,st.id,ROLE_PRIMARY));
            }
            if(st.Secondary_Contact__c!=null){
                roles.add(createSCR(st.Secondary_Contact__c,st.id,ROLE_SECONDARY));
            }
        }

        if(roles.size()>0){
            insert roles;
        }
        
    }

  /*
   * Method to create site roles for primary and secondary contacts
  */
    public static void updateSiteContactRoles(cscrm__Site__c[] oldSites, Map<ID, cscrm__Site__c> oldSitesMap, 
                                              cscrm__Site__c[] updatedSites, Map<ID, cscrm__Site__c> updateSitesMap){
      if(!SiteContactRoleTriggerHelper.isExecutedByTrigger){
        List<Site_Contact_Role__c> roles = new List<Site_Contact_Role__c>();

        //SET TO STORE THE SITES PRIMARY CONTACT WHERE VALUES HAVE CHANGED.
        Set<ID> deletePrimaryCtForSites = new Set<ID>();

        //SET TO STORE THE SITES SECONDARY CONTACT WHERE VALUES HAVE CHANGED.
        Set<ID> deleteSecondaryCtForSites = new Set<ID>();

        for(cscrm__Site__c oldSt : oldSitesMap.values()){
          cscrm__Site__c newSt = updateSitesMap.get(oldSt.id);

          if(oldSt.Primary_Contact__c!=newSt.Primary_Contact__c){
            deletePrimaryCtForSites.add(newSt.id);
            if(newSt.Primary_Contact__c!=null)
              roles.add(createSCR(newSt.Primary_Contact__c,newSt.id,ROLE_PRIMARY));
          }
          if(oldSt.Secondary_Contact__c!=newSt.Secondary_Contact__c){
            deleteSecondaryCtForSites.add(newSt.id);
            if(newSt.Secondary_Contact__c!=null)
              roles.add(createSCR(newSt.Secondary_Contact__c,newSt.id,ROLE_SECONDARY));
          }
        }

        Map<Id,Site_Contact_Role__c> deleteRoles = new Map<Id,Site_Contact_Role__c>();
        
        if(deletePrimaryCtForSites.size()>0){
          Map<Id,Site_Contact_Role__c> primaryRoles = new Map<ID, Site_Contact_Role__c>([SELECT Contact_Type__c,Contact__c,Id,Site__c FROM Site_Contact_Role__c where Site__c 
                      IN :deletePrimaryCtForSites AND Contact_Type__c =:ROLE_PRIMARY]);
          deleteRoles.putall(primaryRoles);
        }

        if(deleteSecondaryCtForSites.size()>0){
          Map<Id,Site_Contact_Role__c> secRoles = new Map<ID, Site_Contact_Role__c>([SELECT Contact_Type__c,Contact__c,Id,Site__c FROM Site_Contact_Role__c where Site__c 
                      IN :deleteSecondaryCtForSites AND Contact_Type__c =:ROLE_SECONDARY]);
          deleteRoles.putall(secRoles);
        }

        //DELETE THE PREVIOUS ROLES..
        if(deleteRoles.size()>0){
          SiteContactRoleTriggerHelper.isExecutedByTrigger = true;
          delete deleteRoles.values();
        }

        //INSERT THE NEW ROLES..
        if(roles.size()>0){
          insert roles;
        }
      }         
        
    }

  /*
  * Method to initialise Site contact role
  */
    private static Site_Contact_Role__c createSCR(ID contactId,ID stId,String roleType){
        Site_Contact_Role__c scr = new Site_Contact_Role__c();
        scr.Contact_Type__c = roleType;
        scr.Site__c = stId;
        scr.Contact__c = contactId;
        return scr;
    }
    
    public void publishCreateEvents(List<cscrm__Site__c> newSites, String event){
       //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newSites,EventConstants.BUSINESS_ENTITY_SITE,event);
        publishIntface.createEvent();
    }  
    // DIGI-26327  - Update NBN Location Id from Address to Site
    public void updateNBNLocationId(List<cscrm__Site__c> newSites){
        Set<Id> addressIdSet = new Set<Id>();
        for (cscrm__Site__c objSite : newSites) {
            if(String.isBlank(objSite.NBN_Location_ID__c) && String.isNotBlank(objSite.cscrm__Installation_Address__c))
                addressIdSet.add(objSite.cscrm__Installation_Address__c);
        }
        if(!addressIdSet.isEmpty()){
            map<id,cscrm__Address__c> addressIdAddressMap = new map<id,cscrm__Address__c>([SELECT Id, NBN_Location_Id__c 
                                                                                            FROM cscrm__Address__c 
                                                                                            WHERE Id IN: addressIdSet]);
            for (cscrm__Site__c objSite : newSites) {
                if(String.isBlank(objSite.NBN_Location_ID__c) && addressIdAddressMap.containsKey(objSite.cscrm__Installation_Address__c)
                    && String.isNotBlank(addressIdAddressMap.get(objSite.cscrm__Installation_Address__c).NBN_Location_Id__c))
                    objSite.NBN_Location_ID__c = addressIdAddressMap.get(objSite.cscrm__Installation_Address__c).NBN_Location_Id__c;
            }
        }
    }
  /*
Story Number: DIGI-15723 
Created By: Ajith Kumar
Description: Method to call the future method to store the Product zone details 
@Param: 
  */
    public static void createProductchargeZoneInfo(Set<Id> siteRecordIds){ 
      Set<Id> splitSiteRecords = new Set<Id>();
      integer sizeOfRecords = siteRecordIds.size();
      integer chunkSize = ((sizeOfRecords<50)? (sizeOfRecords-1) : 49); //DIGI-15723 to split future callout in chunk of 50 record
      List<Id> listSiteRecordIds = new List<Id>();
      listSiteRecordIds.addAll(siteRecordIds);
      for(integer i=0; i<siteRecordIds.size();i++){
          splitSiteRecords.add(listSiteRecordIds[i]);
          if(i==chunkSize){
            //DIGI-15723 call future method
            ChargeProductZoneHandler.storeProductChargeZoneInfo(splitSiteRecords);
            splitSiteRecords.clear();
            //DIGI-15723 Increasing chunkSize to make it similar with iterator
            chunkSize = chunkSize + ((sizeOfRecords - chunkSize > 50)? 50: (sizeOfRecords - chunkSize));
          }
      }
    }
}