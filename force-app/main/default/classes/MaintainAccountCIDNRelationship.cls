/**
 * @Story : EDGE-102.
 * @Description : Mapping hyperlink for Ultimate CIDN.
 * @Date : 11/April/2018
 */
public with sharing class MaintainAccountCIDNRelationship {

	/*For every Account record, this Method associates the parent Account if the Parent CIDn field is populated and if Parent CIDN
	exists in Salesforce */
	public static void createCIDNRelationships(List<Account> lstAccounts){
		Map<Id, Account> mapNewAccountsMapToProcess = new Map<Id, Account>();
		Map<String, Account> mapCIDNToAccount = new Map<String, Account>();
		Map<String, Account> mapParentCIDNToAccount = new Map<String, Account>();
		List<Account> lstAccsToUpdFromBatch = new List<Account>();
		
		System.debug('createCIDNRelationships Invoked');
		//Create a MAP of Parent CIDN and Account record that is updated
		for(Account A : lstAccounts){
			mapNewAccountsMapToProcess.put(A.Id, A);
			if(isNotNullAndBlank(A.Parent_CIDN__c)){
				mapParentCIDNToAccount.put(A.Parent_CIDN__c, A);
			}
            if(isNotNullAndBlank(A.Ultimate_Parent_CIDN__c)){
                mapParentCIDNToAccount.put(A.Ultimate_Parent_CIDN__c, A);
            }
		}
        //Create a MAP of Parent CIDN and the Account record to which the CIDN belongs.
		if(!mapParentCIDNToAccount.isEmpty()){
			for(Account A : [select Id, Parent_CIDN__c, Ultimate_Parent_CIDN__c, CIDN__c from Account where CIDN__c IN:mapParentCIDNToAccount.keySet()]){
				mapCIDNToAccount.put(A.CIDN__c, A);
			}
		}
        //Associate the Parent Account ID with the Account Record by matching Account.ParentCIDN = ParentAccount.CIDN
		if(!mapCIDNToAccount.isEmpty()){
			for(Account A : lstAccounts){
                Boolean isAddedToAccount = false;
                if(validateParentCIDNForMapping(A.Parent_CIDN__c, mapParentCIDNToAccount, mapCIDNToAccount)){
                    A.ParentId = mapCIDNToAccount.get(A.Parent_CIDN__c).Id;
                    if(!Trigger.isExecuting){
                        isAddedToAccount = true;
                        lstAccsToUpdFromBatch.add(A);
                    }
                }
                if(validateParentCIDNForMapping(A.Ultimate_Parent_CIDN__c, mapParentCIDNToAccount, mapCIDNToAccount)){
                    A.Ultimate_Parent_Account__c = mapCIDNToAccount.get(A.Ultimate_Parent_CIDN__c).Id;
                    if(!Trigger.isExecuting && !isAddedToAccount){
                        lstAccsToUpdFromBatch.add(A);
                    }
                }
			}
		}
		if(!Trigger.isExecuting && System.isBatch() && !lstAccsToUpdFromBatch.isEmpty()){
			update lstAccounts;
		}
	}

    private static Boolean validateParentCIDNForMapping(String CIDN, Map<String, Account> mapParentCIDNToAccount, Map<String, Account> mapCIDNToAccount){
        return (isNotNullAndBlank(CIDN) && mapParentCIDNToAccount.containsKey(CIDN) && mapCIDNToAccount.containsKey(CIDN)) ? true : false;
    }
    
	public static void createCIDNRelationshipsWrapper(List<Account> lstOldAccounts, Map<Id, Account> mapNewAccountsMap){
		Map<Id, Account> mapNewAccountsMapToProcess = new Map<Id, Account>();
		List<Account> lstAccounts = new List<Account>();
        List<Id> listParentNull = new List<Id>();
        List<Id> listUltimateParentNull = new List<Id>();
		for(Account A : lstOldAccounts){
            Boolean isAddedToList = false;
            if(!isNotNullAndBlank(mapNewAccountsMap.get(A.Id).Parent_CIDN__c)){
                mapNewAccountsMap.get(A.Id).ParentId = null;
            } else if(A.Parent_CIDN__c != mapNewAccountsMap.get(A.Id).Parent_CIDN__c){
				mapNewAccountsMapToProcess.put(A.Id, mapNewAccountsMap.get(A.Id));
				lstAccounts.add(mapNewAccountsMap.get(A.Id));
                isAddedToList = true;
            }
            if(!isNotNullAndBlank(mapNewAccountsMap.get(A.Id).Ultimate_Parent_CIDN__c)){
                mapNewAccountsMap.get(A.Id).Ultimate_Parent_Account__c = null;
            } else if(A.Ultimate_Parent_CIDN__c != mapNewAccountsMap.get(A.Id).Ultimate_Parent_CIDN__c) {
				mapNewAccountsMapToProcess.put(A.Id, mapNewAccountsMap.get(A.Id));
                if(!isAddedToList) {
                    lstAccounts.add(mapNewAccountsMap.get(A.Id));                
                }
            }
		}
		if(!mapNewAccountsMapToProcess.isEmpty()){
			createCIDNRelationships(lstAccounts);
		}
	}
       
    private static Boolean isNotNullAndBlank(String value){
        return (value != null && String.isNotBlank(value)) ? true : false;
    }
    
}