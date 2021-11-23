/*------------------------------------------------
EDGE        -150891
Class       -PORDataHandler
Description -This class is called from the Flow and it will update the CONGA URL in POR Record.
Author      -Purushottam Sahu
--------------------------------------------------*/
global class PORDataHandler {

    public List<Map<String,Object> > getPORCategories(String porId, Map<String,String> subfilters){
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Integer ExId = 1;
        System.debug('porId:'+porId);
        set<String> porDomainList = new set<String>();
        try{
             for(Partner_of_Record_Domain__c porDomain : [SELECT Id,Domain_Name__c,Partner_of_Record__c,Partner_of_Record__r.Is_Duration_Changed__c,Status__c,Sub_Status__c FROM Partner_of_Record_Domain__c 
                                                         WHERE Partner_of_Record__c=:porId AND (Status__c='Customer Review' OR Status__c='Active' OR Sub_Status__c='Customer Review')]){
                                                             porDomainList.add(porDomain.Domain_Name__c);
                                                         }
            AggregateResult[] groupedResults=[SELECT Product_Category__r.Product_Family_Level_1__c FROM Marketable_Offer__c where Product_Category__r.POR_Disabled__c = false and  Product_Category__c != null group by Product_Category__r.Product_Family_Level_1__c]; 
            for (AggregateResult ar : groupedResults)  {
            Map<String,Object> newRow = new Map<String,Object>();
             newRow.put('Type',ar.get('Product_Family_Level_1__c'));
             newRow.put('isCancel',porDomainList.contains(String.valueOf(ar.get('Product_Family_Level_1__c'))));
             newRow.put('ExternalId',ExId++ );      
             rows.add(newRow);
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getPORCategories:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getPORCategories: found:'+rows);
        return rows; 
    }
}