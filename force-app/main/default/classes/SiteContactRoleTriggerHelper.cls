public with sharing class SiteContactRoleTriggerHelper {

	public static Boolean isExecutedByTrigger = false;
	
	@testVisible
	private static final String ROLE_PRIMARY = 'Primary';
  	@testVisible
	private static final String ROLE_SECONDARY = 'Secondary';


	/*
	*  Method to validate whether they is already a primary/secondary roles exists for the
	*  sites related to the roles inserted.
	*/
	public static void validateCreatePrimarySecondaryRoles(Site_Contact_Role__c[] newSiteRoles){

		Set<Id> siteIds = new Set<Id>();
		Map<Id,Site_Contact_Role__c> prmSites = new Map<Id,Site_Contact_Role__c>();
		Map<Id,Site_Contact_Role__c> secSites = new Map<Id,Site_Contact_Role__c>();

		for(Site_Contact_Role__c sr : newSiteRoles){
			if(String.isNotBlank(sr.Contact_Type__c ) && sr.Contact_Type__c == ROLE_PRIMARY){
				siteIds.add(sr.Site__c);
				prmSites.put(sr.Site__c,sr);
			}
			if(String.isNotBlank(sr.Contact_Type__c ) && sr.Contact_Type__c == ROLE_SECONDARY){
				siteIds.add(sr.Site__c);
				secSites.put(sr.Site__c,sr);
			}
		}

		for(cscrm__Site__c st : [Select Number_of_Primary_Records__c, Number_of_Secondary_Records__c 
								 from cscrm__Site__c where id IN:siteIds ]){
			System.debug('validateCreatePrimarySecondaryRoles : '+ st);
			if(prmSites.containsKey(st.id) && st.Number_of_Primary_Records__c>0){
				prmSites.get(st.id).addError(Label.Primary_Contact_Role_Error);
			}
			if(secSites.containsKey(st.id) && st.Number_of_Secondary_Records__c>0){
				secSites.get(st.id).addError(Label.Secondary_Contact_Role_Error);
			}
		}
	}

	/*
	*  Method to validate whether the role deleted is a primary/secondary roles. If primary checked
	*  whether the site status is valid, then throw error, else allow them to delete it.
	*/
	public static void validateDeletePrimarySecondaryRoles(Site_Contact_Role__c[] oldSiteRoles, 
														Map<ID, Site_Contact_Role__c> oldSiteRolesMap){

		if(!isExecutedByTrigger){
			Set<Id> siteIds = new Set<Id>();
			Map<Id,Site_Contact_Role__c> prmSites = new Map<Id,Site_Contact_Role__c>();
			Map<Id,Site_Contact_Role__c> secSites = new Map<Id,Site_Contact_Role__c>();

			Map<Id,cscrm__Site__c> sitesToUpdate = new Map<Id,cscrm__Site__c>();

			for(Site_Contact_Role__c sr : oldSiteRoles){
				if(String.isNotBlank(sr.Contact_Type__c ) && sr.Contact_Type__c == ROLE_PRIMARY){
					siteIds.add(sr.Site__c);
					prmSites.put(sr.Site__c,sr);
				}
				if(String.isNotBlank(sr.Contact_Type__c ) && sr.Contact_Type__c == ROLE_SECONDARY){
					siteIds.add(sr.Site__c);
					secSites.put(sr.Site__c,sr);
				}
			}

			for(cscrm__Site__c st : [Select Number_of_Primary_Records__c, Number_of_Secondary_Records__c,Status__c,
									  Primary_Contact__c,Secondary_Contact__c, Cscrm__Account__c
									 from cscrm__Site__c where id IN:siteIds ]){
				 String status='Valid';
				if(prmSites.containsKey(st.id) && String.isNotBlank(st.Status__c) && status.equals(st.Status__c)){
					prmSites.get(st.id).addError(Label.Delete_Primary_Site_Contact_Role);
				}else if(prmSites.containsKey(st.id) && (String.isBlank(st.Status__c) || !status.equals(st.Status__c))){
					cscrm__Site__c updatedSite = st;
					if(sitesToUpdate.get(st.id)!=null){
						updatedSite = sitesToUpdate.get(st.id);
					}
					updatedSite.Primary_Contact__c = null;
					sitesToUpdate.put(st.id,updatedSite);	
				}
				if(secSites.containsKey(st.id)){
					cscrm__Site__c updatedSite = st;
					if(sitesToUpdate.get(st.id)!=null){
						updatedSite = sitesToUpdate.get(st.id);
					}
					updatedSite.Secondary_Contact__c = null;
					sitesToUpdate.put(st.id,updatedSite);				
				}
			}

			if(sitesToUpdate.size()>0){
				isExecutedByTrigger = true;
				System.debug('sitesToUpdate.values() : ' + sitesToUpdate.values());
				update sitesToUpdate.values();
			}
		}
	}

	/*
	*  Method to validate whether the primary/secondary roles is being updated. If updated, only
	*  the contacts can be changed. If any other details changes throw error.
	*/
	public static void validateUpdatePrimarySecondaryRoles(Site_Contact_Role__c[] oldSiteRoles, 
														   Map<ID, Site_Contact_Role__c> oldSiteRolesMap, 
	  													   Site_Contact_Role__c[] updatedSiteRoles, 
	  													   Map<ID, Site_Contact_Role__c> updateSiteRolesMap){

		Set<Id> siteIds = new Set<Id>();
		Map<Id,Site_Contact_Role__c> prmSites = new Map<Id,Site_Contact_Role__c>();
		Map<Id,Site_Contact_Role__c> secSites = new Map<Id,Site_Contact_Role__c>();

		/*
		*  Identify records where roles are updated to Primary/Secondary contact role types and also
		*  roles are moved from primary/secondary contact role types
		*/
		for(Site_Contact_Role__c sr : updatedSiteRoles){
			Site_Contact_Role__c oldRole  = oldSiteRolesMap.get(sr.id);
			if((sr.Contact_Type__c == ROLE_PRIMARY || oldRole.Contact_Type__c == ROLE_PRIMARY) && 
				sr.Contact_Type__c != oldRole.Contact_Type__c )
			{
				sr.addError(Label.Primary_Secondary_Contact_Role_Error);
			}
			if((oldRole.Contact_Type__c == ROLE_SECONDARY ||sr.Contact_Type__c == ROLE_SECONDARY) && 
				sr.Contact_Type__c != oldRole.Contact_Type__c)
			{
				sr.addError(Label.Primary_Secondary_Contact_Role_Error);
			}

			if(sr.Contact_Type__c == ROLE_PRIMARY && oldRole.Contact_Type__c == ROLE_PRIMARY ){
				siteIds.add(sr.Site__c);
				prmSites.put(sr.Site__c,sr);
			}
			if(sr.Contact_Type__c == ROLE_SECONDARY && oldRole.Contact_Type__c == ROLE_SECONDARY ){
				siteIds.add(sr.Site__c);
				secSites.put(sr.Site__c,sr);
			}
		}

		Map<Id,cscrm__Site__c> sitesToUpdate = new Map<Id,cscrm__Site__c>();

		/*
		*  Identify roles contacts for both primary and secondary are not the same. If it's different
		*  update the site record with the information.
		*/

		for(cscrm__Site__c st : [Select Primary_Contact__c, Secondary_Contact__c, Number_of_Primary_Records__c, 
								 Number_of_Secondary_Records__c 
								 from cscrm__Site__c where id IN:siteIds ]){
			if(prmSites.containsKey(st.id)){
				Site_Contact_Role__c rl = prmSites.get(st.id);
				cscrm__Site__c updatedSite = st;
				if(sitesToUpdate.get(st.id)!=null){
					updatedSite = sitesToUpdate.get(st.id);
				}
				if(rl.Contact__c!=updatedSite.Secondary_Contact__c){
					updatedSite.Primary_Contact__c = rl.Contact__c;
					sitesToUpdate.put(st.id,updatedSite);	
				}else{
					rl.addError(Label.Same_Primary_Secondary_Error);
				}
					
			}
			if(secSites.containsKey(st.id)){
				Site_Contact_Role__c rl = secSites.get(st.id);
				cscrm__Site__c updatedSite = st;
				if(sitesToUpdate.get(st.id)!=null){
					updatedSite = sitesToUpdate.get(st.id);
				}
				if(rl.Contact__c!=updatedSite.Primary_Contact__c){
					updatedSite.Secondary_Contact__c = rl.Contact__c;
					sitesToUpdate.put(st.id,updatedSite);
				}else{
					rl.addError(Label.Same_Primary_Secondary_Error);
				}	
			}
		}

		if(sitesToUpdate.size()>0){
			isExecutedByTrigger = true;
			update sitesToUpdate.values();
		}
	}

}