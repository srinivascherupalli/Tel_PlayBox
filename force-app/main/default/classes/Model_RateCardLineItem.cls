/****************************************************************************************************************************************************
   Main Class : Model_RateCardLineItem
   Test Class : Model_RateCardLineItemTest
=============================================================================================================================================
   Sr.No.    Developer Name      Date            Story          Sprint               Description
   1.        Vivek Makkar        18/01/2021      EDGE-189344    21.01(New Class)     To collate all the queries related to Price Line Item Object
=========================================================================================================================================
 ******************************************************************************************************************************************************/
public with sharing class Model_RateCardLineItem {

    // Method to form the SOQL Query on Price Lines based on offerId , rateCardIdSet & rateCardCodeList.
    public static String getRelatedLines( Set<String> rateCardIdSet , List<String> rateCardCodeList ) {
       
        String searchQuery = '';
            searchQuery = 'Select id,name,Check_todays_date__c,toUnit__c,fromUnit__c,cspmb__Rate_Card__c, '
                                        + ' rateLineGroupIdentifier__c,cspmb__rate_value__c,cspmb__Rate_Card_Line_Unit__c,cspmb__Rate_Card__r.Name, '
                                        +  ' cspmb__Rate_Card__r.Offer_Id__c,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.RateCard_Bill_Description__c,cspmb__Rate_Card__r.Charge_ID__c, '
                                        +  ' cspmb__Rate_Card__r.Check_todays_date__c,External_Id__c '
                                        +  ' FROM  cspmb__Rate_Card_Line__c '
                                        +  ' WHERE Check_todays_date__c = TRUE ';
                                        
            if ( rateCardIdSet != null && rateCardIdSet.size() > 0 ) {
                searchQuery += ' AND cspmb__Rate_Card__c IN ' + inClausify(rateCardIdSet) +' ';
            }
            if ( rateCardCodeList != null &&  rateCardCodeList.size() > 0  ) {
                searchQuery += ' AND cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c IN ' + inClausifyString(rateCardCodeList) + ' ' ;
            }   
        return searchQuery;
    }

    // Method to convert set of Id in concateneted string to use in dynamic soql IN Clause
    public static String inClausify(Set<String> ids) {
        String inClause = String.format( '(\'\'{0}\'\')', 
                         new List<String> { String.join( new List<String>(ids) , '\',\'') });
        return inClause;
    }

    // Method to convert List of Id in concateneted string to use in dynamic soql IN Clause
    public static String inClausifyString(List<String> ids) {
        String inClause = String.format( '(\'\'{0}\'\')', 
                         new List<String> { String.join( new List<String>(ids) , '\',\'') });
        return inClause;
    }

    
}