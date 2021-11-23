/**
* Account ROU Calculation.
*/

public without sharing class AccountROUDAO {

    private static Boolean calculateROUValueOnce = true;
    
    public void updateAccountROU(Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){
        if(calculateROUValueOnce && AccountTriggerHelper.isLOCROUCalculationRequired()){
            updateROU(oldAccountsMap, newAccountsMap);
            calculateROUValueOnce = false;
            

        }
    }

    private void updateROU(Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){
        Map<String, Business_Unit__c> businessUnitMap = getBusinessUnitMap(newAccountsMap.values());
        Map<String, Post_Code__c> postCodeMap = getPostCodeMap(newAccountsMap.values());
        Map<String, Market_Segment__c> marketSegmentMap = getMarketSegmentMap(newAccountsMap.values());
        for(Account customerRecord : newAccountsMap.values()){
        	Account oldCustomerRecord = oldAccountsMap.get(customerRecord.Id);
            if(oldCustomerRecord != null && isCustomerStatusActiveOrAcquired(customerRecord)){
                String businessUnitLic = (String.isNotBlank(customerRecord.Business_Unit__c) && businessUnitMap.containsKey(customerRecord.Business_Unit__c) && businessUnitMap.get(customerRecord.Business_Unit__c).LIC__c!=NULL) ? businessUnitMap.get(customerRecord.Business_Unit__c).LIC__c : ''; 
                String marketSegment = (String.isNotBlank(customerRecord.Market_Segment__c) && marketSegmentMap.containsKey(customerRecord.Market_Segment__c) &&  marketSegmentMap.get(customerRecord.Market_Segment__c).LIC__c != NULL) ? marketSegmentMap.get(customerRecord.Market_Segment__c).LIC__c :'';
                if(isBusinessUnitConsumerOrBusiness(customerRecord) && hasFieldsChanged(oldCustomerRecord, customerRecord)){
                    String postKey = (String.isNotBlank(customerRecord.BillingPostalCode) && String.isNotBlank(customerRecord.BillingState))?customerRecord.BillingPostalCode+customerRecord.BillingState : '';
                    String postcode=(String.isNotBlank(postKey) && postCodeMap.containsKey(postKey) && postCodeMap.get(postKey).Geo_Code__c!=NULL)?postCodeMap.get(postKey).Geo_Code__c:''; 
                    String trimMarketSegment = (marketSegment.length()>2)?marketSegment.substring(0, 2):marketSegment;
                    String isManaged = (customerRecord.Managed__c)? '1':'0';
                    customerRecord.Legacy_ROU__c = businessUnitLic + trimMarketSegment + postcode + isManaged;
                } else if(isBusinessUnitEnterpriseOrTelstra(customerRecord) && hasBusinessUnitOrMarketSegementOrManagedFieldsChanged(oldCustomerRecord, customerRecord)){
                    customerRecord.Managed__c = True;
                    customerRecord.Legacy_ROU__c = businessUnitLic + marketSegment + '1';
                }
            }
        }
        
    }
    
    private Map<String, Business_Unit__c> getBusinessUnitMap(List<Account> custmerRecordList){
        Map<String, Business_Unit__c> mapBusinessUnit = new Map<String, Business_Unit__c>();
        List<String> businessUnits = new List<String>();
        for(Account customerRecord : custmerRecordList){
            businessUnits.add(customerRecord.Business_Unit__c);
        }
        for(Business_Unit__c bu : [Select Id,Name,Business_Unit__c,LIC__c From Business_Unit__c where Business_Unit__c IN:businessUnits]){
            mapBusinessUnit.put(bu.Business_Unit__c,bu);
        }
        
        

        return mapBusinessUnit;
    }
    
	private Map<String, Post_Code__c> getPostCodeMap(List<Account> custmerRecordList){
        Map<String, Post_Code__c> mapPostCode = new Map<String, Post_Code__c>();
		List<String> postCodes = new List<String>();
        List<String> stateCodes = new List<String>();
        for(Account customerRecord : custmerRecordList){
			postCodes.add(customerRecord.BillingPostalCode);
            stateCodes.add(customerRecord.BillingState);
        }
        for(Post_Code__c pc : [Select Id,Name,Geo_Code__c,Zip_Code__c,State__c From Post_Code__c where Zip_Code__c IN:postCodes AND State__c IN:stateCodes LIMIT 1]){
            String key = pc.Zip_Code__c + pc.State__c ;
            mapPostCode.put(key,pc);
        }
        
   
        return mapPostCode;
        
    }
    
    private Map<String, Market_Segment__c> getMarketSegmentMap(List<Account> custmerRecordList){
        Map<String, Market_Segment__c> mapMarketSegment = new Map<String, Market_Segment__c>();
        List<String> marketSegments = new List<String>();
        for(Account customerRecord : custmerRecordList){
            marketSegments.add(customerRecord.Market_Segment__c);
        }
        for(Market_Segment__c ms : [Select Id,Name,Market_Segment__c,LIC__c From Market_Segment__c Where Market_Segment__c IN:marketSegments]){
            mapMarketSegment.put(ms.Market_Segment__c,ms);
        }
       
   
        return mapMarketSegment;
    }
    //EDGE-68099 Removed Hard Coding
    private Boolean isBusinessUnitEnterpriseOrTelstra(Account customer){
        return (Label.Account_RecordType_Enterprise.equals(customer.Business_Unit__c) || Label.Acc_Business_Unit_Telstra.equals(customer.Business_Unit__c)) ? true : false;
    }
    //EDGE-68099 Removed Hard Coding
    private Boolean isBusinessUnitConsumerOrBusiness(Account customer){
        return (Label.Acc_BusinessUnit.equals(customer.Business_Unit__c) || Label.Acc_BusinessUnit_Business.equals(customer.Business_Unit__c)) ? true : false;
    }
    //EDGE-68099 Removed Hard Coding
    private Boolean isCustomerStatusActiveOrAcquired(Account customer){
        return (Label.Acc_Customer_Status.equals(customer.Customer_Status__c) || Label.Acc_Customer_Status_Acquired.equals(customer.Customer_Status__c)) ? true : false;
    }

    private Boolean hasFieldsChanged(Account oldRecord, Account newRecord){
        return (oldRecord.BillingPostalCode != newRecord.BillingPostalCode ||
                hasBusinessUnitOrMarketSegementOrManagedFieldsChanged(oldRecord, newRecord)) ? true : false;
    }
    
	private Boolean hasBusinessUnitOrMarketSegementOrManagedFieldsChanged(Account oldRecord, Account newRecord){
        return (oldRecord.Business_Unit__c != newRecord.Business_Unit__c || 
                oldRecord.Market_Segment__c != newRecord.Market_Segment__c ||
                oldRecord.Managed__c != newRecord.Managed__c) ? true : false;
    }
    
}