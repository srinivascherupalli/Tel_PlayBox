/*************************************************************************************************
Name : ProductUtil 
Description : Product Utility CLass
Sr.No.    Developer Name      Date          Story Description
1.        Laxmi Rahate      20/03/2019      EDGE-73848 Added String.escape to prevent SOQL tainting. 
2.        Shubhi Vijay      21/08/2019      EDGE-81113 MDM migration order
3.        Antun Bartonicek  11/11/2019      EDGE-117966 (Parallel MACD) field csordtelcoa__Change_Type__c added to SOQL
4.       Shubhi V                 01/07/2020    EDGE-151354 EDGE-147513    BillingAcc check
5.       Shubhi V            17/07/2020     EDGE-147513
6.      Gnana        11/11/2020    EDGE-184043 - Added method to do pattern matching check for Reference Number
6.     Pooja G        05/01/2021      EDGE-191824 - PONR Check before initiating Contract/Skip Contract/Quote
7.    Gokul          23/02/21  EDGE-195270 - Added Opportunity_Type__c in basket Query
**************************************************************************************************/
public with sharing class ProductUtil {

    public static Map<Id, Map<String, String>> getFulfillmentAttributesByServices(Map<Id,csord__Service__c> serviceIdMap){

        Map<Id, Map<String, String>> retVal = new Map<Id, Map<String, String>>();

        Map<Id,Id> configIdToServiceId = new Map<Id,Id>();

        for(csord__Service__c serv : serviceIdMap.values()){
            configIdToServiceId.put(serv.csordtelcoa__Product_Configuration__c,serv.id);
        }

        List<cscfga__Attribute__c> attLst = [Select Name, id, cscfga__Value__c,cscfga__Attribute_Definition__r.cscfga__Label__c, cscfga__Product_Configuration__c
         from cscfga__Attribute__c where cscfga__Product_Configuration__c 
         in (Select csordtelcoa__Product_Configuration__c from csord__Service__c where csordtelcoa__Product_Configuration__c!=null 
            and id in:serviceIdMap.keySet()) and cscfga__Attribute_Definition__r.FulFillmentRequired_Count__c>0];

        System.debug('attLst ' + attLst);

        for(cscfga__Attribute__c att: attLst){

            String currentServiceId = configIdToServiceId.get(att.cscfga__Product_Configuration__c);
            
            Map<String, String> currentServMap = retVal.get(currentServiceId)!=null?retVal.get(currentServiceId): new Map<String, String>();
            currentServMap.put(att.cscfga__Attribute_Definition__r.cscfga__Label__c,att.cscfga__Value__c);
            retVal.put(currentServiceId,currentServMap);
        }

        return retVal;
    }
     public static cscfga__Product_Basket__c getBasket(String basketId){
     //Total Contract Value field added in query. EDGE-11104
     //cscfga__Opportunity__r.Owner.Email added in query EDGE - 115457, EDGE-117966: Parallel MACD added csordtelcoa__Change_Type__c
     //EDGE-195270 - Added Opportunity_Type__c in basket Query
     String queryString = 'select cscfga__Opportunity__c,id,Opportunity_Type__c, Name,csbb__Account__c, cscfga__Opportunity__r.Owner.Email,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.OwnerId,Maxim_Opportunity_ID__c,Customer_Request_Date__c,cscfga__Basket_Status__c,csbb__Account__r.OwnerId,csbb__Account__r.Name,csbb__Account__r.Owner.Name,csbb__Account__r.Owner.Email,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c' +',cscfga__total_contract_value__c'+
                            ',cscfga__Opportunity__r.Model_Change__c,Express_Flow__c,csordtelcoa__Change_Type__c,cscfga__pricing_status__c, recordType.Name, BasketType__c, csordtelcoa__Previous_Product_Basket__c'   +  ' from cscfga__Product_Basket__c where id = \'' + String.escapeSingleQuotes(basketId) + '\''; // Sr. No 1 ////updated query for edge 81113  // updated query for EDGE-147513 //added recordTypeName field in query for EDGE-191824
   //EDGE-191759 added two fields in the query
        cscfga__Product_Basket__c productBasket = Database.query(queryString);
        System.debug('productBasket<><>'+productBasket);

        return productBasket;
    }
    
    // Added as part of EDGE-184043 to do pattern check
    public static String refNumPatternCheck(String refNumber){
        Pattern refPattern = Pattern.compile('[T|t]{1}[N|n]{1}[C|c]{1}[0-9]{9}');
        Matcher refMatcher = refPattern.matcher(refNumber);
        if(refMatcher.matches())
        {
            return 'Ok';
        }
        else{
            return EnrichBasketConstants.ERROR_STATUS1 + System.Label.NCO_BasketValidation_ReferenceInvalidErrorMsg + EnrichBasketConstants.CLOSE_BRACKET;
        }
    }

}