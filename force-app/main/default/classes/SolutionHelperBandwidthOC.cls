/* ****************************************************************************
Class Name      : SolutionHelperBandwidthOC
* Author        : Aman Soni/Laxmi Rahate : EDGE-113848
* Date          : 09 Oct 2019
* Description   : Class for fetching the Downgrade
* *****************************************************************************/
global with sharing class SolutionHelperBandwidthOC implements cssmgnt.RemoteActionDataProvider {
public static String offerId =  System.Label.TID_OfferID;
public static String prodSpecId =  System.Label.TID_ProdSpecId;
public static String externalId =  System.Label.TID_ExternalId;
// --- main method that needs to be implemented ---
/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
    global Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();      
        cspmb__Price_Item__c bandwidthOCData = getBandwidthDownGradeOC();        
        if (bandwidthOCData != null ){
            returnMap.put('bandwidthDowngradeOC', bandwidthOCData);
        }
       return returnMap;
    }
    
/******************************************************************************************************
* Method Name : getBandwidthDownGradeOC
* Description : Used to fetch bandwidth downgrade charge
* Parameters  : NA
* Return      : NA                      
******************************************************************************************************/
    public static cspmb__Price_Item__c getBandwidthDownGradeOC(){
        cspmb__Price_Item__c commercialProduct =  new cspmb__Price_Item__c ();
        if(String.isNotBlank(offerId) && String.isNotBlank(prodSpecId) && String.isNotBlank(externalId)){
        commercialProduct = [select id, name, cspmb__Product_Definition_Name__c,Zone__c,Type__c, cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,
        Offer_Id__c,ProdSpecId__c,External_Id__c,Check_todays_date__c from cspmb__Price_Item__c where Check_todays_date__c = true and Offer_Id__c =: offerId  and ProdSpecId__c=:prodSpecId and External_Id__c =:externalId];
        }
        return commercialProduct;
    }   
}