/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : Handler class to process lookup data
 * Last modified Date: 13/10/2021
 *********************************/
public with sharing class OrderEnrichmentLookUpHandler {
    
    public static Object[] doLookupContactFromAcctBasket(Map<String,String> searchFields, Integer lookupPageSizeLimit) {
        
        String Accid = [
            SELECT csbb__Account__c 
            FROM cscfga__Product_Basket__c 
            WHERE Id = :searchFields.get('basketId')
            LIMIT 1
        ].csbb__Account__c;
		Set<Id> accset = new Set<Id>();
        accset.add(Accid);
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        if(isPartner){
                User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
                accset.add(userRecord.accountid);
        }
        return getContactsByAccountId(accset,searchFields,lookupPageSizeLimit);
    }

    public static List<Contact> getContactsByAccountId(Set<Id> accountIds,Map<String, String> searchFields,Integer lookupPageSizeLimit){
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
            result = '%%';
        }
        Set<Id> newset = new Set<Id>();
        newset.addall(accConId);
        system.debug(LoggingLevel.INFO, 'CS_ContactfromAcctBasket.newset = ' + newset);
        
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
            LIMIT :lookupPageSizeLimit
        ];
                
        if (retconlist != null)
            return retconlist;
        else
            return null;
    }
    public static Object[] doLookupConfirmedAddress(Map<String,String> searchFields, Integer lookupPageSizeLimit) {
       
        String srcString;
        if (searchFields.get('searchValue') != null)
            srcString = '%' + searchFields.get('searchValue') + '%';

        List<cscrm__Address__c> returnList;
        if (srcString != null) {
            returnList = [
                SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c
                WHERE
                    Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED')
                    AND Address_ID__c != NULL // EDGE-177028 changes
                    AND (Street_calc__c LIKE :srcString
                    OR cscrm__Zip_Postal_Code__c LIKE :srcString
                    OR cscrm__City__c LIKE :srcString
                    OR Address_ID__c LIKE :srcString
                    OR name LIKE :srcString)
                ORDER BY Name ASC
                LIMIT :lookupPageSizeLimit
            ];
        } else {
            returnList = [
                SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c
                WHERE /*Address_Status__c = 'CONFIRMED'*/ Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED') AND Address_ID__c != NULL // EDGE-177028 chnages
                ORDER BY Name ASC
                LIMIT :lookupPageSizeLimit
            ];
        }

        system.debug(LoggingLevel.INFO, 'CS_ConfirmedAddresses.returnList = ' + returnList.size());
        system.debug(LoggingLevel.INFO, 'CS_ConfirmedAddresses.returnList = ' + returnList);

        if (returnList != null)
            return returnList;
        else
            return null;
    }
}