/*****************************************
1 .     22-09-2019 .      Venkat .       Added CommercialPDName in the map to filter Tenancy contact details for NgUC MTS - EDGE 114158
2 .     20-11-2019 .      Pawan Devaliya.Fixed : Delivery contacts not getting filtered based on input string - EDGE 119326
3.                        Sandip                 Sandip CS changes
4.      02-09-202  .      Purushottam    Added Partner Contacts in Delivery contacts and Site Contacts for only Partners in TPC - EDGE 16814
******************************************/

global with sharing class CS_ContactfromAcctBasket extends cscfga.ALookupSearch {
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

        String Accid = [
            SELECT csbb__Account__c 
            FROM cscfga__Product_Basket__c 
            WHERE Id = :searchFields.get('basketId') //Sandip CS changes
            LIMIT 1
        ].csbb__Account__c;
        // EDGE 16814: Added by Purushottam - Start
		Set<Id> accset = new Set<Id>();
        accset.add(Accid);
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        if(isPartner){
                User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
                accset.add(userRecord.accountid);
        }
        // EDGE 16814: Added by Purushottam - End
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.basketId = ' + searchFields.get('basketId'));//Sandip CS changes
       // system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.PDName = ' + searchFields.get('CommercialPDName'));
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.Accid = ' + Accid);
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.searchValue = ' + searchFields.get('searchValue'));
		/*
        List<AccountContactRelation > Accountcontact = [
            SELECT ContactId,Roles, Contact.Phone, Contact.MobilePhone, Contact.FirstName, Contact.LastName, Contact.Email 
            FROM AccountContactRelation
            //WHERE accountId = : Accid
            WHERE accountId IN : accset
        ];
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.Accountcontact = ' + Accountcontact);
        List<Id> accConId = new List<Id>();
        for (AccountContactRelation accCon : Accountcontact ) {
        if(searchFields.containsKey('CommercialPDName') && searchFields.get('CommercialPDName') != null && searchFields.get('CommercialPDName').contains('BroadsoftTenancy') && (accCon.Roles.contains('Legal Lessee') || accCon.Roles.contains('Full Authority'))){
                 accConId.add(accCon.ContactId);
        }else if (!searchFields.containsKey('CommercialPDName') || (searchFields.containsKey('CommercialPDName') && searchFields.get('CommercialPDName')!= null &&  !searchFields.get('CommercialPDName').contains('BroadsoftTenancy'))){
            accConId.add(accCon.ContactId);
        }
        }
        
        String result = '';
        if(searchFields.get('searchValue')!=null){
            result = '%' + searchFields.get('searchValue') + '%';
        }
        else{
            result = '%%'; //change for EDGE 119326
        }
        Set<Id> newset = new Set<Id>();
        newset.addall(accConId);
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.newset = ' + newset);
        //Edge 66645-added search parameters for email, phone, mobile phone
        //EDGE-EDGE-83863 phone  removed
        List<Contact> retconlist = [
            SELECT Id, Name, Phone, MobilePhone, FirstName, LastName, Email 
            FROM Contact 
            WHERE id IN :newset AND (  /*removed comment from 'WHERE' for EDGE 119326 */
            /*    Name LIKE :result OR 
                FirstName LIKE :result OR  
                LastName LIKE :result OR
                Email LIKE :result OR
                MobilePhone LIKE :result
            )
            LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
            //OFFSET :SELECT_LIST_LOOKUP_PAGE_SIZE
        ];

        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.retconlist = ' + retconlist);

        if (retconlist != null)
            return retconlist;
        else
            return null;*/
            return getContactsByAccountId(accset,searchFields,SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT);
    }
    public static List<Contact> getContactsByAccountId(Set<Id> accountIds,Map<String, String> searchFields,Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT){
        List<AccountContactRelation > Accountcontact = [
            SELECT ContactId,Roles, Contact.Phone, Contact.MobilePhone, Contact.FirstName, Contact.LastName, Contact.Email 
            FROM AccountContactRelation
            WHERE accountId IN : accountIds
        ];
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.Accountcontact = ' + Accountcontact);
        List<Id> accConId = new List<Id>();
        for (AccountContactRelation accCon : Accountcontact ) {
            if(searchFields.containsKey('CommercialPDName') && searchFields.get('CommercialPDName') != null && searchFields.get('CommercialPDName').contains('BroadsoftTenancy') && (accCon.Roles.contains('Legal Lessee') || accCon.Roles.contains('Full Authority'))){
                accConId.add(accCon.ContactId);
            }else if (!searchFields.containsKey('CommercialPDName') || (searchFields.containsKey('CommercialPDName') && searchFields.get('CommercialPDName')!= null &&  !searchFields.get('CommercialPDName').contains('BroadsoftTenancy'))){
                accConId.add(accCon.ContactId);
            }
        }
        
        String result = '';
        if(searchFields.get('searchValue')!=null){
            result = '%' + searchFields.get('searchValue') + '%';
        }
        else{
            result = '%%'; //change for EDGE 119326
        }
        Set<Id> newset = new Set<Id>();
        newset.addall(accConId);
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.newset = ' + newset);
        //Edge 66645-added search parameters for email, phone, mobile phone
        //EDGE-EDGE-83863 phone  removed
        List<Contact> retconlist = [
            SELECT Id, Name, Phone, MobilePhone, FirstName, LastName, Email 
            FROM Contact 
            WHERE id IN :newset AND (  /*removed comment from 'WHERE' for EDGE 119326 */
                Name LIKE :result OR 
                FirstName LIKE :result OR  
                LastName LIKE :result OR
                Email LIKE :result OR
                MobilePhone LIKE :result
            )
            LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
            //OFFSET :SELECT_LIST_LOOKUP_PAGE_SIZE
        ];
        
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.retconlist = ' + retconlist);
        
        if (retconlist != null)
            return retconlist;
        else
            return null;
    }
}