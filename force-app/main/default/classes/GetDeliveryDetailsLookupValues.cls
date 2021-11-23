/*
1        Venkata Ramanan G     19-08-2019           Added new if else based on new options getaddress & getcontact to resolve bulk oe issues.
2        Purushottam           02-09-2020           Added Partner Contacts in Delivery contacts and Site Contacts for only Partners in TPC - EDGE 16814
*/
global with sharing class GetDeliveryDetailsLookupValues implements cssmgnt.RemoteActionDataProvider {
    global Map<String, Object> getData(Map<String, Object> inputMap) {


        Map<String, Object> returnMap = new Map<String, Object>();
        String basketId = (String) inputMap.get('basketId');
        String option = (String) inputMap.get('option');
        String searchString = (String) inputMap.get('searchString');
        String recid = (String) inputMap.get('id');
        String filter;
        List<Contact> retconlist;
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> retpriceaddonlist;
         List<cscrm__Address__c> addresses;


        if (searchString != null && searchString.length()>0) {
            filter = '%' + searchString + '%';
        }
        List<cscfga__Product_Basket__c> baskets = [
            SELECT csbb__Account__c
            FROM cscfga__Product_Basket__c
            WHERE Id = :basketId
            LIMIT 1
        ];

        if (option==null ||  option != null && option == 'addresses') {
           
            if (filter == null || filter.length()==0) {
                addresses = [
                        select id, Name, Address_ID__c, cscrm__Zip_Postal_Code__c, Street_calc__c, Address_Status__c
                        from cscrm__Address__c
                        WHERE Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED') AND Address_ID__c != NULL 
                        ORDER BY Name ASC
                        LIMIT 4999
                ];
            } else {

                addresses = [
                        select id, Name, Address_ID__c, cscrm__Zip_Postal_Code__c, Street_calc__c, Address_Status__c
                        from cscrm__Address__c
                        WHERE Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED') AND Address_ID__c != NULL AND
                        (Street_calc__c LIKE :filter OR
                        cscrm__Zip_Postal_Code__c LIKE :filter OR
                        cscrm__City__c LIKE :filter OR
                        Address_ID__c LIKE :filter OR
                        Name LIKE :filter OR
                        id  =: searchString)
                        ORDER BY Name ASC
                        LIMIT 4999
                ];
            }

            returnMap.put('addresses', addresses);
        }
        
        // EDGE 16814: Added by Purushottam - Start
        Set<Id> accset = new Set<Id>();
        accset.add(baskets[0].csbb__Account__c);
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        if(isPartner){
                User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
                accset.add(userRecord.accountid);
        }
        // EDGE 16814: Added by Purushottam - End

        //SELECT ContactId, Contact.Phone, Contact.MobilePhone, Contact.FirstName, Contact.LastName, Contact.Email
        if (option==null ||  option != null && option == 'contact') {
            List<AccountContactRelation > Accountcontact = [
                    SELECT ContactId
                    FROM AccountContactRelation
                    //WHERE accountId = :baskets[0].csbb__Account__c
                    WHERE accountId IN :accset
            ];

            List<Id> accConId = new List<Id>();
            for (AccountContactRelation accCon : Accountcontact) {
                accConId.add(accCon.ContactId);
            }


            Set<Id> newset = new Set<Id>();
            newset.addall(accConId);
            
            if (filter == null || filter.length()==0) {
                retconlist = [
                        SELECT Id, Name, Phone, MobilePhone, FirstName, LastName, Email
                        FROM Contact
                        WHERE id IN :newset
                        LIMIT 4999
                ];
            } else {
                retconlist = [
                        SELECT Id, Name, Phone, MobilePhone, FirstName, LastName, Email
                        FROM Contact
                        WHERE id IN :newset AND
                                (Name LIKE :filter OR
                                Phone LIKE :filter OR
                                MobilePhone LIKE :filter OR
                                FirstName LIKE :filter OR
                                LastName LIKE :filter OR
                                Email LIKE :filter OR
                                Name LIKE :filter OR
                                id  =: searchString)
                        ORDER BY Name ASC
                        LIMIT 4999
                ];
            }
            returnMap.put('contact', retconlist);
        }
        if (option != null && option == 'getcontact' && !string.isblank(recid)) {
         retconlist = [SELECT Id, Name, Phone, MobilePhone, FirstName, LastName, Email
                        FROM Contact
                        WHERE id = :recid];
        returnMap.put('getcontact', retconlist);
        }
        if (option != null && option == 'getaddresses' && !string.isblank(recid)) {
        addresses = [select id, Name, Address_ID__c, cscrm__Zip_Postal_Code__c, Street_calc__c
                        from cscrm__Address__c
                        WHERE id = :recid];
        returnMap.put('getaddresses', addresses);
        }

        if (option != null && option == 'getValueforIDD' && !string.isblank(recid)) {
    retpriceaddonlist = [SELECT Id, cspmb__add_on_price_item__r.ProdSpecId__c,AddOn_Name__c,cspmb__Add_On_Price_Item__r.external_id__c, cspmb__add_on_price_item__r.BillingSpecId__c,cspmb__Add_On_Price_Item__r.Message_Bank__c,name,cspmb__Add_On_Price_Item__r.name,cspmb__One_Off_Charge__c,cspmb__add_on_price_item__r.cspmb__one_off_charge__c,cspmb__Recurring_Charge__c,cspmb__add_on_price_item__r.cspmb__recurring_charge__c,cspmb__price_item__c,cspmb__add_on_price_item__c,cspmb__default_quantity__c,cspmb__group__c,cspmb__min__c,cspmb__max__c,cspmb__Overrides_Add_On_Charges__c
                   FROM cspmb__Price_Item_Add_On_Price_Item_Association__c
                   WHERE id = :recid];
   returnMap.put('getValueforIDD', retpriceaddonlist);
   }
        

        return returnMap;
    }
}