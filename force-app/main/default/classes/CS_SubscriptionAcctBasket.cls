/**
   *  Description of the purpose of the classthe method.
   *  @name doLookupSearch
   *  @description               :This method used in Lookup config record to get the Subscription records related to Account
   *  @param searchFields        :ProductBasket searchFields.
   *  @param productDefinitionId :Product Definition Id
   *  @return 				 	 :csord__Subscription__c
   *  @Jira Story Ref            :EDGE-128934
   *  @createdBy  				 :Purushottama Sahu, Orlando
**/
global with sharing class CS_SubscriptionAcctBasket extends cscfga.ALookupSearch {
    public override String getRequiredAttributes() {
        return '["basketId","NetworkServiceOffer"]'; // BasketId changed to basketId - CloudSense changes
    }
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit) {
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25; 
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 99;  
        Integer recordOffset = 0;
        if (SELECT_LIST_LOOKUP_PAGE_SIZE != null && SELECT_LIST_LOOKUP_PAGE_SIZE != 0 && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != null && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != 0)
            recordOffset = SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT * SELECT_LIST_LOOKUP_PAGE_SIZE;
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.recordOffset = ' + recordOffset + 'searchFields ='+searchFields);
        String Accid = [
            SELECT csbb__Account__c 
            FROM cscfga__Product_Basket__c 
            WHERE Id = :searchFields.get('basketId') 
            LIMIT 1
        ].csbb__Account__c;
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.NetworkServiceOffer = ' + searchFields.get('NetworkServiceOffer'));
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.basketId = ' + searchFields.get('basketId'));
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.Accid = ' + Accid);
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.searchValue = ' + searchFields.get('searchValue'));
        String result = '';
        if(searchFields.get('searchValue')!=null){
            result = '%' + searchFields.get('searchValue') + '%';
        }
        else{
            result = '%%'; 
        }
        List<String> tenancyTypeProdIdList = new List<String>();
                     if (searchFields.get('NetworkServiceOffer')!=null){
                          tenancyTypeProdIdList= searchFields.get('NetworkServiceOffer').split(',');
                     }
        List<csord__Subscription__c> subsList = [select Id , Name ,  csordtelcoa__Subscription_Number__c ,	TenancyID__c ,NetworkServiceId__c,csord__Status__c
                                             FROM csord__Subscription__c 
                                             WHERE csord__Account__c =:Accid AND 
                                             	   csord__Status__c = :System.label.Active AND
                                                   /*ID NOT IN (select SubscriptionID__c from Functional_Contact_Role__c) AND */
                                             	   ConfigSpecID__c IN:tenancyTypeProdIdList AND (Name LIKE :result OR 
                                                                                                 TenancyID__c LIKE :result OR
                                                                                                 NetworkServiceId__c LIKE :result OR
                                                                                                 csordtelcoa__Subscription_Number__c LIKE :result)
                                            LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
                                            ];
        system.debug(LoggingLevel.INFO, 'CS_NetworkSubscriptionAcctBasket.subsList = ' + subsList);
        if (subsList != null && !subsList.isEmpty())
            return subsList;
        else
            return null;
    }
}