/************************************************************************************************************************************************************************
Name : PriceItemMDContactTermLookup 
Test Class  : PriceItemMDContactTermLookupTest
======================================================================================================================================
Sr.No. Date            Developer Name  Story        Description
1.     11/07/2019      Laxmi Rahate    EDGE-98685   BUG - Duplicate values in Contract Term
2.     30/8/2019       Ankit Goswami   EDGE-112367  PPHH -Added DeviceEnrollment__c in Query
3.     15/10/2019      Aman Soni       EDGE-112367  correction in Device_Enrolment__c field
4.     30/04/2020      Gnana           EDGE-140968  Added Charge id in SOQL query
5.     23/06/2020      Aman Soni       EDGE-148667  Added Device_Care__c field in SOQL Query and updated version setting to 48.0
*************************************************************************************************************************************************************************/

global with sharing class PriceItemMDContactTermLookup  extends cscfga.ALookupSearch {

    public override String getRequiredAttributes()
    {   
        return '["ManufacturerString","ModelString","ColourString","PaymentTypeString","OfferId"]';           
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        String manufacturerString;
        String modelString;
        String colourString;
        String paymentTypeString;
        String offerId;
        
        if(searchFields != null){
             manufacturerString = searchFields.get('ManufacturerString');
             modelString = searchFields.get('ModelString');
             colourString = searchFields.get('ColourString');
             paymentTypeString = searchFields.get('PaymentTypeString');
             offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        }
        system.debug(LoggingLevel.INFO, 'offerId = ' + offerId);
         // Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || DeviceEnrollment__c added as part of EDGE-112367,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Ch-01 - Added check in below query - to check todays' date || Added Device_Care__c field by Aman Soni(EDGE-148667)
        String searchQuery;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getContractTerm(offerId, manufacturerString, modelString, paymentTypeString, colourString);
        //Added by Aman Soni as a part of EDGE-148667 || End 
        System.debug('PriceItemMDPaymentTypeLookup searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = new  List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery))
             CommercialProductsList =Database.query(searchQuery);
         System.debug('PriceItemMDPaymentTypeLookup CommercialProductsList : ' + CommercialProductsList );
        return CommercialProductsList;
    }
}