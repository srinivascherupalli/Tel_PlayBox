public class AccountAddressRelationshipTriggerHandler {
	AccountAddressRelationshipTriggerHelper accAddHelper=new AccountAddressRelationshipTriggerHelper();
	/*public void OnBeforeInsert(cscrm__Account_Address_Relationship__c[] newRels){
  		System.debug('OnBeforeInsert : ' + newRels);
	    
	}*/

	public void OnAfterInsert(cscrm__Account_Address_Relationship__c[] newRels){
	 	System.debug('OnAfterInsert : ' + newRels);
		accAddHelper.publishCreateEvents(newRels,EventConstants.UPDATE_OPERATION);
	 	//AccountAddressRelationshipTriggerHelper.validateCreatePrimaryRels(newRels);
		
	}

	/*public void OnBeforeUpdate(cscrm__Account_Address_Relationship__c[] oldRels, cscrm__Account_Address_Relationship__c[] updatedRels, 
							   Map<ID, cscrm__Account_Address_Relationship__c> newRelsMap){
	    System.debug('OnBeforeUpdate old: ' + oldRels);
	    System.debug('OnBeforeUpdate new : ' + updatedRels);
	}
	*/
	public void OnAfterUpdate(cscrm__Account_Address_Relationship__c[] updatedRels){
		accAddHelper.publishCreateEvents(updatedRels,EventConstants.UPDATE_OPERATION);
	    //AccountAddressRelationshipTriggerHelper.validateUpdatePrimaryRels(oldRels,oldRelsMap,updatedRels,updateRelsMap);
	}

	/*public void OnAfterDelete(cscrm__Account_Address_Relationship__c[] deletedRels, Map<ID, cscrm__Account_Address_Relationship__c> relsMap){
	  	System.debug('OnAfterDelete old: ' + deletedRels);	  	
	}*/

	/*public void OnBeforeDelete(cscrm__Account_Address_Relationship__c[] deletedRels, Map<ID, cscrm__Account_Address_Relationship__c> relsMap){
	  	System.debug('OnBeforeDelete old: ' + deletedRels);
	  	//AccountAddressRelationshipTriggerHelper.validateDeletePrimaryRels(deletedRels,relsMap);
	}*/
}