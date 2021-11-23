public class AccountAddressRelationshipTriggerHelper {

	public static Boolean isExecutedByTrigger = false;

	/*
	*  Method to validate whether if there is already a primary address exists for the
	*  account and then inserts the record or else error.
	*/
	/*public static void validateCreatePrimaryRels(cscrm__Account_Address_Relationship__c[] newRels){

		Set<Id> acctIds = new Set<Id>();
		Map<Id,cscrm__Account_Address_Relationship__c> prmAccts = new Map<Id,cscrm__Account_Address_Relationship__c>();
		
		for(cscrm__Account_Address_Relationship__c sr : newRels){
			if(String.isNotBlank(sr.cscrm__Account__c ) && sr.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY){
				acctIds.add(sr.cscrm__Account__c);
				prmAccts.put(sr.cscrm__Account__c,sr);
			}
			
		}

		for(Account acct : [Select Number_of_Primary_Address_Record__c from Account where id IN:acctIds ]){
			System.debug('validateCreatePrimaryRels : '+ acct);
			if(prmAccts.containsKey(acct.id) && acct.Number_of_Primary_Address_Record__c>0){
				prmAccts.get(acct.id).addError(Label.Primary_Address_Error);
			}			
		}
	}*/

	/*
	*  Method to validate whether the relationship deleted is a primary address. If primary then throw error, else allow them to delete it.
	*/
	/*public static void validateDeletePrimaryRels(cscrm__Account_Address_Relationship__c[] oldRels, 
														Map<ID, cscrm__Account_Address_Relationship__c> oldRelsMap){

		if(!isExecutedByTrigger){
			Set<Id> acctIds = new Set<Id>();
			Map<Id,cscrm__Account_Address_Relationship__c> prmAccts = new Map<Id,cscrm__Account_Address_Relationship__c>();
			
			for(cscrm__Account_Address_Relationship__c sr : oldRels){
				if(String.isNotBlank(sr.cscrm__Account__c ) && sr.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY){
					acctIds.add(sr.cscrm__Account__c);
					prmAccts.put(sr.cscrm__Account__c,sr);
				}				
			}

			for(Account acct : [Select Number_of_Primary_Address_Record__c,Primary_Address__c from Account where id IN:acctIds ]){
				if(prmAccts.containsKey(acct.id)){
					prmAccts.get(acct.id).addError(Label.Delete_Primary_Address_Relationship);		
				}
			}			
		}
	}*/

	/*
	*  Method to validate whether the primary/secondary roles is being updated. If updated, only
	*  the contacts can be changed. If any other details changes throw error.
	*/
	/*public static void validateUpdatePrimaryRels(cscrm__Account_Address_Relationship__c[] oldRels, 
														   Map<ID, cscrm__Account_Address_Relationship__c> oldRelsMap, 
	  													   cscrm__Account_Address_Relationship__c[] updatedRels, 
	  													   Map<ID, cscrm__Account_Address_Relationship__c> updateRelsMap){

		Set<Id> acctIds = new Set<Id>();
		Map<Id,cscrm__Account_Address_Relationship__c> prmAccts = new Map<Id,cscrm__Account_Address_Relationship__c>();

		for(cscrm__Account_Address_Relationship__c sr : updatedRels){
			cscrm__Account_Address_Relationship__c oldRls  = oldRelsMap.get(sr.id);
			if((sr.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY || oldRls.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY) && 
				sr.cscrm__Address_Type__c != oldRls.cscrm__Address_Type__c )
			{
				sr.addError(Label.Update_Primary_Address_Error);
			}
			

			if(sr.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY && oldRls.cscrm__Address_Type__c == Constants.ADDRESS_TYPE_PRIMARY ){
				acctIds.add(sr.cscrm__Account__c);
				prmAccts.put(sr.cscrm__Account__c,sr);
			}
			
		}

		Map<Id,Account> acctsToUpdate = new Map<Id,Account>();

		for(Account acct : [Select Number_of_Primary_Address_Record__c,Primary_Address__c from Account where id IN:acctIds]){
			if(prmAccts.containsKey(acct.id)){
				cscrm__Account_Address_Relationship__c rl = prmAccts.get(acct.id);
				Account updatedAcct = acct;
				if(acctsToUpdate.get(acct.id)!=null){
					updatedAcct = acctsToUpdate.get(acct.id);
				}
				if(rl.cscrm__Address__c!=updatedAcct.Primary_Address__c){
					updatedAcct.Primary_Address__c = rl.cscrm__Address__c;
					acctsToUpdate.put(acct.id,updatedAcct);	
				}					
			}			
		}

		if(acctsToUpdate.size()>0){
			isExecutedByTrigger = true;
			update acctsToUpdate.values();
		}
	}*/
	public void publishCreateEvents(List<cscrm__Account_Address_Relationship__c> newList,String event){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_ACCOUNT,event);
        publishIntface.createEvent(); 
    }

}