/*********************************************************************************************************************************
 *Class Name      :   ProductBasketTriggerHelper
 *Story             :   
 *Developer         :   Ranjit Tiwari 

Test Class : ProductBasketTriggerHelperTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description             
1.        Ankit Goswami        26/12/2019        EDGE-127666 create getUpdatedQuoteStatus method
 *********************************************************************************************************************************
*/

public with sharing class ProductBasketTriggerHelper {
     /*
      *  Method to update the attribute informations.
     */
    public static void updateAttributeInfo(cscfga__Product_Basket__c[] oldBskts, Map<ID, cscfga__Product_Basket__c> oldBsktsMap, 
                                              cscfga__Product_Basket__c[] updatedBskts, Map<ID, cscfga__Product_Basket__c> updateBsktsMap){

        String [] attNameLst = new String[]{'Customer Requested Date','Aggregator', 'Financial CIDN' , 'Invoice Arrangement ID', 'Purchase Order Number','Basket Status', 'ProductType'};
        String [] confgNameLst = null;
        String serviceDetailStatus;
        Boolean isEnrichment = false;

        CustomConfigurationOptions__c config = CustomConfigurationOptions__c.getValues('MarketableOfferList');
        System.debug('------ config ' + config);
        CustomConfigurationOptions__c serviceDetailing = CustomConfigurationOptions__c.getValues('ServiceDetailing');

        if(config!=null && String.isNotBlank(config.MarketableOfferList__c)){
            confgNameLst = config.MarketableOfferList__c.split(',');
        }
        
        if(serviceDetailing != null && String.isNotBlank(serviceDetailing.Enrichment_Basket_Stage__c)) {
            serviceDetailStatus = serviceDetailing.Enrichment_Basket_Stage__c;                                      
        }
      
        //String [] confgNameLst = new String[]{'IPVPN','Business IP'};

        if(confgNameLst!=null){


            Map<Id,cscfga__Attribute__c> updatedAttributes = new Map<Id,cscfga__Attribute__c>();

            for(cscfga__Attribute__c att : [SELECT cscfga__Product_Configuration__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
                                        cscfga__Display_Value__c,cscfga__is_active__c,cscfga__Value__c,Id,Name 
                                        FROM cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Product_Basket__c 
                                        IN :updateBsktsMap.keyset() AND cscfga__Product_Configuration__c != null
                                        AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c !=null AND NAME IN :attNameLst] ){
                cscfga__Product_Basket__c newBskt = updateBsktsMap.get(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__c);
                cscfga__Product_Basket__c oldBskt = oldBsktsMap.get(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__c);

                System.debug('Attribute : ' + att.Name + ' : ' + att.cscfga__Value__c);
                System.debug('Attribute Value is bsk: ' + oldBskt.Customer_Request_Date__c);

                if(att.Name.equalsIgnoreCase('Customer Requested Date') && ((String.isBlank(att.cscfga__Value__c) && oldBskt.Customer_Request_Date__c==null )
                    || (oldBskt.Customer_Request_Date__c!=null && String.valueOf(oldBskt.Customer_Request_Date__c).equalsIgnoreCase(att.cscfga__Value__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, String.valueOf(newBskt.Customer_Request_Date__c), (newBskt.Customer_Request_Date__c!=null?newBskt.Customer_Request_Date__c.format():null)));
                }

                if(att.Name.equalsIgnoreCase('Aggregator') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Aggregator__c) )
                    || (String.isNotBlank(oldBskt.Aggregator__c) && oldBskt.Aggregator__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Aggregator__c, newBskt.Aggregator__c));
                }

                if(att.Name.equalsIgnoreCase('Invoice Arrangement ID') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Invoice_Arrangement_ID__c) )
                    || (String.isNotBlank(oldBskt.Invoice_Arrangement_ID__c) && oldBskt.Invoice_Arrangement_ID__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Invoice_Arrangement_ID__c, newBskt.Invoice_Arrangement_ID__c));
                }

                if(att.Name.equalsIgnoreCase('Financial CIDN') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Financial_CIDN__c) )
                    || (String.isNotBlank(oldBskt.Financial_CIDN__c) && oldBskt.Financial_CIDN__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Financial_CIDN__c, newBskt.Financial_CIDN__c));
                }

                if(att.Name.equalsIgnoreCase('Purchase Order Number') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Purchase_Order_Number__c) )
                    || (String.isNotBlank(oldBskt.Purchase_Order_Number__c) && oldBskt.Purchase_Order_Number__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Purchase_Order_Number__c, newBskt.Purchase_Order_Number__c));
                }

                if(att.Name.equalsIgnoreCase('Basket Status') && (
                       (String.isNotBlank(oldBskt.csordtelcoa__basket_stage__c) && !oldBskt.csordtelcoa__basket_stage__c.equalsIgnoreCase(newBskt.csordtelcoa__basket_stage__c))
                    || (String.isNotBlank(newBskt.csordtelcoa__basket_stage__c) && !newBskt.csordtelcoa__basket_stage__c.equalsIgnoreCase(oldBskt.csordtelcoa__basket_stage__c)))){
                    updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.csordtelcoa__basket_stage__c, newBskt.csordtelcoa__basket_stage__c));
                }

                if(att.Name.equalsIgnoreCase('ProductType')) {
                    if(newBskt.csordtelcoa__basket_stage__c == serviceDetailStatus) {
                        isEnrichment = true;
                    }
                    cscfga__Attribute__c modAtt;
                    if(isEnrichment) { 
                        modAtt = getUpdatedAttribute(att, 'None', 'None');
                        
                    } else {  
                        modAtt = getUpdatedAttribute(att, 'Inline', 'Inline');
                    }
                    updatedAttributes.put(modAtt.id, modAtt);
                }
                                                        
            }

            //WE ARE ASSUMMING THE NUMBER OF ATTRIBUTES MODIFIED IS LESS THAN 10000 RECORDS.

            if(updatedAttributes.size()>0){
                update updatedAttributes.values();
            }

        }
        
    }
    
    private static cscfga__Attribute__c getUpdatedAttribute(cscfga__Attribute__c att, String value, String displayValue) {
        cscfga__Attribute__c updatedAtt = att;
        updatedAtt.cscfga__Value__c = value;
        updatedAtt.cscfga__Display_Value__c = displayValue;
        return updatedAtt;
    }
    /* JIRA - EDGE-25504 - MAQ - START*/
   public static String updateOldQuotesToVoid(cscfga__Product_Basket__c[] oldBskts, Map < ID, cscfga__Product_Basket__c > oldBsktsMap,cscfga__Product_Basket__c[] updatedBskts, Map < ID, cscfga__Product_Basket__c > updateBsktsMap) {
         try {
             system.debug('Enter updateOldQuotesToVoid ');
              boolean statusChanged = false;     
            list < Quote > updateQuote = new list < Quote > ();
            map <id,cscfga__Product_Basket__c> updateQuoteMap = new map <id,cscfga__Product_Basket__c> ();// EDGE-127666
            for (cscfga__Product_Basket__c basketRec: updatedBskts) {
              cscfga__Product_Basket__c oldBasket = oldBsktsMap.get(basketRec.Id);
                system.debug('changed status'+oldBasket.csordtelcoa__Basket_Stage__c+basketRec.csordtelcoa__Basket_Stage__c);
                if(oldBasket.csordtelcoa__Basket_Stage__c != basketRec.csordtelcoa__Basket_Stage__c){
                    
                   statusChanged = true;
                } 
                // EDGE-127666  start
                if (basketRec.csordtelcoa__Basket_Stage__c == 'Contract Initiated' && basketRec.cscfga__Opportunity__c != NULL && statusChanged == true) {
                    updateQuoteMap.put(basketRec.cscfga__Opportunity__c,basketRec);   
                }
                // EDGE-127666 end
            } 
                if(updateQuoteMap != null){ 
                    updateQuote=getUpdatedQuoteStatus(updateQuoteMap);
                }
           
             if(updateQuote.size() > 0){
                 UPDATE updateQuote;
             }
        } 
         catch (Exception e) {
          System.debug('The following exception occurred: ' + e.getMessage());
         }
         return null;
        }
        /* JIRA - EDGE-25504 - MAQ - END*/
        
        //start EDGE-127666
        public static List< Quote >  getUpdatedQuoteStatus(map <id,cscfga__Product_Basket__c> updateQuoteMap){  
             list < Quote > updateQuote = new list < Quote > ();
            list < Quote > AllQuotes = [SELECT ID, Product_Basket__c, Status,OpportunityId  FROM Quote WHERE OpportunityId != NULL AND OpportunityId IN : updateQuoteMap.keyset() ORDER BY createddate DESC];
            
            if (AllQuotes.size() > 0) {
                for (Quote quoteRecords: AllQuotes) {
                    if(updateQuoteMap.containskey(quoteRecords.OpportunityId) && quoteRecords.Product_Basket__c == updateQuoteMap.get(quoteRecords.OpportunityId).id){
                        Quote updateQ = new Quote();
                        updateQ.ID = quoteRecords.ID;
                        updateQ.Status = 'Customer Validated';
                        updateQuote.add(updateQ);
                    }
                    else{
                        Quote updateQ = new Quote();
                        updateQ.ID = quoteRecords.ID;
                        updateQ.Status = 'Void';
                        updateQuote.add(updateQ);     
                    }
                }
            }
        return updateQuote;
            
    }
    //end EDGE-127666
}