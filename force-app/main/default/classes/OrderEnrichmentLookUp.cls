/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : Class to return Lookup Object based on user search Value
 * Last modified Date: 13/10/2021
 *********************************/

public with sharing class OrderEnrichmentLookUp {
    private static final Integer LOOKUP_DELIVERY_SELECT_LIMIT = 25; 
    private static final Integer LOOKUP_CONTACT_SELECT_LIMIT = 99; 
    
    @AuraEnabled
    public static List<Contact> doLookupContactDetails(String basketId, String searchValue, String CommercialPDName){
        Map<String,String> searchFields = new Map<String,String>();
        try {
            if(basketId != null && basketId != ''){
                searchFields.put('basketId',basketId);
                searchFields.put('searchValue',searchValue);
                searchFields.put('CommercialPDName',CommercialPDName);
                List<Contact> conLst = (List<Contact>)OrderEnrichmentLookUpHandler.doLookupContactFromAcctBasket(searchFields,LOOKUP_CONTACT_SELECT_LIMIT);
                return conLst;
            }
            else{
                return null;
            }
        } catch (Exception e) {System.debug('Exception at OrderEnrichmentLookUp.doLookupContactDetails '+e.getMessage());return null;}
    }
    @AuraEnabled
    public static List<cscrm__Address__c> doLookupDeliveryAddress(String basketId, String searchValue){
        Map<String,String> searchFields = new Map<String,String>();
        try {
            searchFields.put('basketId',basketId);
            searchFields.put('searchValue',searchValue);
            List<cscrm__Address__c> deliveryAddress = (List<cscrm__Address__c>)OrderEnrichmentLookUpHandler.doLookupConfirmedAddress(searchFields,LOOKUP_DELIVERY_SELECT_LIMIT);
            return deliveryAddress;
        } catch (Exception e) {System.debug('Exception at OrderEnrichmentLookUp.doLookupContactDetails '+ e.getMessage()); return null;}
    }


}