/**
   *  Description of the purpose of the classthe method.
   *  @name doLookupSearch
   *  @description               :This method used in Lookup config record to get the user records related to partner Account
   *  @param searchFields        :ProductBasket searchFields.
   *  @param productDefinitionId :Product Definition Id
   *  @return                    :User
   *  @Jira Story Ref            :EDGE-132318
   *  @createdBy                 :RaviTeja, Orlando
   * Spring 20 Changes - Changed Basketid -> basketId
**/
global with sharing class CS_PartnerUserfromBasket extends cscfga.ALookupSearch  {
    
    // Spring 20 Changes
    public override String getRequiredAttributes() {
        return '["basketId","OfferName"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit) {

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25; 
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 99;  
        Integer recordOffset = 0;

            try{        
                   if (SELECT_LIST_LOOKUP_PAGE_SIZE != null && SELECT_LIST_LOOKUP_PAGE_SIZE != 0 && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != null && SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT != 0)
                            recordOffset = SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT * SELECT_LIST_LOOKUP_PAGE_SIZE;

                        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.recordOffset = ' + recordOffset + 'searchFields ='+searchFields);
                        
                        //Fetching partner account based on Opportunity details
                        // Spring 20 Changes
                        String Accid = [
                            SELECT csbb__Account__c,cscfga__Opportunity__r.partneraccountid 
                            FROM cscfga__Product_Basket__c 
                            WHERE Id = :searchFields.get('basketId') 
                            LIMIT 1
                        ].cscfga__Opportunity__r.partneraccountid;
                        // Spring 20 Changes
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
                         string partnerrole='';           
                         string OfferName=searchFields.get('OfferName');
                         system.debug('OfferName'+OfferName);
						 
                //Mapping values for partner roles vs Offer
                Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.OfferVSPartnerRoleMapping, Map<String, String>.class);
                partnerrole=specAttributes.containskey(OfferName)?specAttributes.get(OfferName):'';
                               
                //Query to get the user records based on partner role and partner accountid
				if(partnerrole!=''){           
                        List<user> userlist= [
                            SELECT Id, Name 
                            FROM user
                            WHERE Accountid= :Accid and isActive=true and P_Number__c!=null AND Contact.Partner_Role__c includes (:partnerrole) AND (Name LIKE :result)
                            LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
                        ];

                        system.debug(LoggingLevel.INFO, 'CS_SitefromAcctBasket.userlist= ' + userlist);
                        system.debug(LoggingLevel.INFO, 'partnerrole= ' + partnerrole);

                        if (userlist!= null && !userlist.isEmpty())
                            return userlist;
                        else
                            return null;
                }
            }
        catch(Exception e){
            System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());
           }
             return null;
    }
    }