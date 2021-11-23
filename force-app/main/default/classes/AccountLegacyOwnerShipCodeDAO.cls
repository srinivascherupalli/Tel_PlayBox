/**
 * Update AccountLegacyOwnership Code.
 */
public without sharing class AccountLegacyOwnerShipCodeDAO {

    private static Boolean calculateLOCValueOnce = true;
    
    public void updateLegacyOwnerShipCode(Account[] newAccounts){
        if(calculateLOCValueOnce && AccountTriggerHelper.isLOCROUCalculationRequired()){
            updateLOC(newAccounts);
            calculateLOCValueOnce = false;
        }
    }
    
    private void updateLOC(Account[] newAccounts){
        Map<String,Legacy_ROUAccount__c> mapLegacyROU= getLegacyROUAccount(newAccounts);
        for(Account customer : newAccounts){
            Legacy_ROUAccount__c rouAccount = mapLegacyROU.get(customer.Legacy_ROU__c);
            customer.Legacy_Ownership_Code__c = (String.isNotBlank(customer.Legacy_ROU__c) && rouAccount !=null && 
                                              	rouAccount.CDBOR_OWN_CD__c != NULL) ? rouAccount.CDBOR_OWN_CD__c : NULL; 
        }
    }
    
    private Map<String,Legacy_ROUAccount__c> getLegacyROUAccount(Account[] newAccounts){
		List<String> legacyROUList = new List<String>();
        Map<String,Legacy_ROUAccount__c> legacyROUMap = new Map<String,Legacy_ROUAccount__c>();
        for(Account customer: newAccounts){
            legacyROUList.add(customer.Legacy_ROU__c);
        }
        for(Legacy_ROUAccount__c lrou : [Select Name,CDBOR_OWN_CD__c,SIEBEL_ROU__c from Legacy_ROUAccount__c where SIEBEL_ROU__c IN: legacyROUList]){
            legacyROUMap.put(lrou.SIEBEL_ROU__c,lrou);
        }
        return legacyROUMap;
    }
    
}