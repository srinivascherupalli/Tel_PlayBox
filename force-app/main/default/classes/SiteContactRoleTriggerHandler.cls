public with sharing class SiteContactRoleTriggerHandler {
	
	public void OnBeforeInsert(Site_Contact_Role__c[] newSiteRoles){
  		System.debug('OnBeforeInsert : ' + newSiteRoles);
	    
	}

	public void OnAfterInsert(Site_Contact_Role__c[] newSiteRoles){
	 	System.debug('OnAfterInsert : ' + newSiteRoles);
	 	SiteContactRoleTriggerHelper.validateCreatePrimarySecondaryRoles(newSiteRoles);
	}

	public void OnBeforeUpdate(Site_Contact_Role__c[] oldSiteRoles, Site_Contact_Role__c[] updatedSiteRoles, 
							   Map<ID, Site_Contact_Role__c> newSiteRolesMap){
	    System.debug('OnBeforeUpdate old: ' + oldSiteRoles);
	    System.debug('OnBeforeUpdate new : ' + updatedSiteRoles);
	}

	public void OnAfterUpdate(Site_Contact_Role__c[] oldSiteRoles, Map<ID, Site_Contact_Role__c> oldSiteRolesMap, 
	  							Site_Contact_Role__c[] updatedSiteRoles, Map<ID, Site_Contact_Role__c> updateSiteRolesMap){
		System.debug('OnAfterUpdate old: ' + oldSiteRoles);
	    System.debug('OnAfterUpdate new : ' + updatedSiteRoles);
	    SiteContactRoleTriggerHelper.validateUpdatePrimarySecondaryRoles(oldSiteRoles,oldSiteRolesMap,updatedSiteRoles,updateSiteRolesMap);
	}

	public void OnAfterDelete(Site_Contact_Role__c[] deletedSiteRoles, Map<ID, Site_Contact_Role__c> siteRolesMap){
	  	System.debug('OnAfterDelete old: ' + deletedSiteRoles);	  	
	}

	public void OnBeforeDelete(Site_Contact_Role__c[] deletedSiteRoles, Map<ID, Site_Contact_Role__c> siteRolesMap){
	  	System.debug('OnBeforeDelete old: ' + deletedSiteRoles);
	  	SiteContactRoleTriggerHelper.validateDeletePrimarySecondaryRoles(deletedSiteRoles,siteRolesMap);
	}
}