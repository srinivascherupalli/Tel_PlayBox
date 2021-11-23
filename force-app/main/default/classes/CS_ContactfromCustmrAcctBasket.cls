/*****************************************
1.      02-09-202  .      Purushottam    Separtaed Customer and Partner Contacts logic from CS_ContactfromAcctBasket - EDGE 16814
******************************************/
global with sharing class CS_ContactfromCustmrAcctBasket extends cscfga.ALookupSearch {
    public override String getRequiredAttributes() {
        return '["Basketid","CommercialPDName"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit) {

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25; 
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 99;  

        Integer recordOffset = 0;
        if (SELECT_LIST_LOOKUP_PAGE_SIZE != null && SELECT_LIST_LOOKUP_PAGE_SIZE != 0 && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != null && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != 0)
            recordOffset = SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT * SELECT_LIST_LOOKUP_PAGE_SIZE;

        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.recordOffset = ' + recordOffset + 'searchFields ='+searchFields);

        String Accid = [SELECT csbb__Account__c  FROM cscfga__Product_Basket__c 
             									 WHERE Id = :searchFields.get('basketId')
            									 LIMIT 1
        			   ].csbb__Account__c;
		Set<Id> accset = new Set<Id>();
        accset.add(Accid);
       return CS_ContactfromAcctBasket.getContactsByAccountId(accset,searchFields,SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT);
    }
}