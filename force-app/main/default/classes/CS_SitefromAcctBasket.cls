/**
   *  Description of the purpose of the classthe method.
   *  @name doLookupSearch
   *  @description               :This method used in Lookup config record to get the site records related to Account
   *  @param searchFields        :ProductBasket searchFields.
   *  @param productDefinitionId :Product Definition Id
   *  @return 				 	 :cscrm__Site__c
   *  @Jira Story Ref            :EDGE-120711
   *  @createdBy                 :Purushottama Sahu, Orlando
   *************************************** CHANGE LOG ***************************************
   SL NO.   DeveloperName   Date            Description
   1.       Pooja Bhat      12-OCT-2021     DIGI-11869: Site lookup search based on AdborId.
**/
global with sharing class CS_SitefromAcctBasket extends cscfga.ALookupSearch  {
    // Spring 20 Upgrade
    public override String getRequiredAttributes() {
        return '["basketId"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit) {

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25; 
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 99;  

        final String OFFERID_ADAPTIVE_NETWORKS  =   System.Label.Adaptive_Networks;

        System.debug('searchFields***'+searchFields.size());
        for(String strkey : searchFields.keyset()) {
            System.debug('key=' + strkey + ' value=' + searchFields.get(strkey));
        }
        Integer recordOffset = 0;
        if (SELECT_LIST_LOOKUP_PAGE_SIZE != null && SELECT_LIST_LOOKUP_PAGE_SIZE != 0 && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != null && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != 0)
            recordOffset = SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT * SELECT_LIST_LOOKUP_PAGE_SIZE;

        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.recordOffset = ' + recordOffset + 'searchFields ='+searchFields);
		// Spring 20 Upgrade
        String Accid = [
            SELECT csbb__Account__c 
            FROM cscfga__Product_Basket__c 
            WHERE Id = :searchFields.get('basketId') 
            LIMIT 1
        ].csbb__Account__c;
        // Spring 20 Upgrade
        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.basketId = ' + searchFields.get('basketId'));
        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.Accid = ' + Accid);
        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.searchValue = ' + searchFields.get('searchValue'));
        
        String result = '';
        if(searchFields.get('searchValue')!=null){
            result = '%' + searchFields.get('searchValue') + '%';
        }
        else{
            result = '%%'; 
        }
        String queryStr     =   'SELECT';
        String fields       =   ' Id, Name, cscrm__Installation_Address__r.cscrm__Address_Details__c, cscrm__Installation_Address__r.Name';
        String objectname   =   ' FROM cscrm__Site__c';
        String filterCndtn  =   ' WHERE cscrm__Account__c = \'' + String.escapeSingleQuotes(Accid) + '\''; 
        String limitStr     =   ' LIMIT ' + SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT;
        if(searchFields.containsKey('OfferId') && searchFields.get('OfferId').equalsIgnoreCase(OFFERID_ADAPTIVE_NETWORKS)) {
            fields          +=  ' , AdborID__c, T_Fibre_Serviceability_Status__c, NBN_Serviceability_Status__c, NBN_EE_Serviceability_Status__c, Address__c';
            filterCndtn     +=  ' AND (Name LIKE \'' + String.escapeSingleQuotes(result) + '\'' + 
                                ' OR Address__c LIKE  \'' + String.escapeSingleQuotes(result)  + '\'' +
                                ' OR cscrm__Installation_Address__r.cscrm__Address_Details__c LIKE \'' + String.escapeSingleQuotes(result) + '\'' +
                                ' OR AdborID__c LIKE \'' + String.escapeSingleQuotes(result) + '\')';
        } else {
            filterCndtn     +=  ' AND (Name LIKE \'' + String.escapeSingleQuotes(result) + '\'' +
                                ' OR cscrm__Installation_Address__r.Name LIKE \'' + String.escapeSingleQuotes(result) + '\'' +
                                ' OR cscrm__Installation_Address__r.cscrm__Address_Details__c LIKE \'' + String.escapeSingleQuotes(result)  + '\')';
        }
        queryStr    +=   fields + objectname + filterCndtn + limitStr;
        System.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.queryStr = ' + queryStr);
        List<cscrm__Site__c> sitelist = Database.query(queryStr);

        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.sitelist = ' + sitelist);

        if (sitelist != null && !sitelist.isEmpty())
            return sitelist;
        else
            return null;
    }

}