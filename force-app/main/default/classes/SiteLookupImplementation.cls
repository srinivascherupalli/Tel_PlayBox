global with sharing class SiteLookupImplementation extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    {return '[]';}
    
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, 
                                   Integer pageOffset, Integer pageLimit) {
                                       
    	String searchQuery;
        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL 
            && searchFields.get('searchValue') != '') {
                
            searchValue = '%' + searchFields.get(searchValue) + '%';
        }
		List<cscrm__Site__c> accountSites = new  List<cscrm__Site__c>();
		String accountId = searchFields.get('AccountId') != null ? searchFields.get('AccountId') : '';
        //String accountId = [SELECT Id, Account_Id__c FROM cscfga__Product_Basket__c WHERE Id =: basketId].Account_Id__c;
        String adborId = searchFields.get('adborId') != null ? searchFields.get('adborId') : '';
        String singleQuotes = '\'';
       	String queryString = 'SELECT Id,Name,Installation_Address__c, AdborID__c,Address_Status__c, NBN_Location_ID__c FROM cscrm__Site__c WHERE cscrm__Account__c = \'' + accountId + '\'';                                   
        if (String.isEmpty(adborId)) {
            System.debug(queryString);
        	accountSites =  Database.query(queryString);                                  
        } else {
            queryString = queryString + ' AND AdborID__c = \'' + adborId + '\'';
            System.debug(queryString);
            accountSites =  Database.query(queryString);
        }
        accountSites = Database.query(queryString);
        System.debug('>>>>' + accountSites);
		return accountSites;	                                
    }
}