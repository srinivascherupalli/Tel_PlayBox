/**
 * Created by tihomir.baljak on 6/24/2019.
 */
/*********************************************************************************************************************************
 *Class Name      :   CS_ConfirmedAddresses

Test Class : CS_ConfirmedAddressesTest
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        tihomir.baljak       18/09/2019     	EDGE-109718 								 there. Hence Contact is not add after selecting the Requestor)
2         Shweta Khandelwal    27/10/20         EDGE-177028 
 *********************************************************************************************************************************
*/

global with sharing class CS_ConfirmedAddresses extends cscfga.ALookupSearch {
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit) {
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25;
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 26;

        Integer recordOffset = 0;
        if (pageOffset != null && pageOffset != 0 && pageLimit != null && pageLimit != 0)
            recordOffset = pageOffset * SELECT_LIST_LOOKUP_PAGE_SIZE;

        system.debug(LoggingLevel.INFO, 'CS_ConfirmedAddresses.recordOffset = ' + recordOffset);
        system.debug(LoggingLevel.INFO, 'CS_ConfirmedAddresses.searchValue = ' + searchFields.get('searchValue'));
        String srcString;
        if (searchFields.get('searchValue') != null)
            srcString = '%' + searchFields.get('searchValue') + '%';

        List<cscrm__Address__c> returnList;
        if (srcString != null) {
            returnList = [
                SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c
                WHERE
                    /*Address_Status__c ='CONFIRMED'*/
                    Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED')
                    AND Address_ID__c != NULL // EDGE-177028 chnages
                    AND (Street_calc__c LIKE :srcString
                    OR cscrm__Zip_Postal_Code__c LIKE :srcString
                    OR cscrm__City__c LIKE :srcString
                    OR Address_ID__c LIKE :srcString
                    OR name LIKE :srcString)
                ORDER BY Name ASC
                LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
                // OFFSET :recordOffset
            ];
        } else {
            returnList = [
                SELECT Name, Id, Address_ID__c, Street_calc__c, cscrm__City__c, cscrm__Zip_Postal_Code__c, Address_Status__c
                FROM cscrm__Address__c
                WHERE /*Address_Status__c = 'CONFIRMED'*/ Address_Status__c IN ('CONFIRMED', 'UNCONFIRMED') AND Address_ID__c != NULL // EDGE-177028 chnages
                ORDER BY Name ASC
                LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
                // OFFSET :recordOffset
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