/*
* This class is written for story EDGE-48933.
* It has logic to validate the Mobility product baskets.
* Author : Kiran      
*/
public with sharing class NumberEnrichmentValidationHelper
{
    public boolean validateMobilityProductsInBasket (string basketId)
    {
        boolean validMobilityBasket = true;
        try
        {
			//Changed as part of EDGE-75162
			//String queryProductConfig ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cscfga__Product_Configuration__c'))+' FROM cscfga__Product_Configuration__c WHERE csordtelcoa__Replaced_Product_Configuration__c = null AND cscfga__Product_Configuration__c.cscfga__Product_Definition__r.product_Specification__c = \'DMCAT_ProductSpecification_000420\' AND cscfga__Product_Basket__c = :basketId' ;
			String queryProductConfig ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cscfga__Product_Configuration__c'))+' FROM cscfga__Product_Configuration__c WHERE csordtelcoa__Replaced_Product_Configuration__c = null AND cscfga__Product_Configuration__c.cscfga__Product_Definition__r.product_Specification__c = \'' + System.Label.CWPMobilityProductOffering + '\' AND cscfga__Product_Basket__c = :basketId';
            
            List<cscfga__Product_Configuration__c> productConfig=Database.query(queryProductConfig);
            Map<ID,Integer> mapOfQuantity = new Map <ID,Integer>();
            Map<ID,Integer> mapOfNumbers = new Map <ID,Integer>();
            NumberNCSMobilityHelper ncHelper = new NumberNCSMobilityHelper();
            List<cscfga__Product_Configuration__c> prodConfigUpdateList = new List<cscfga__Product_Configuration__c>();
           
           for(cscfga__Product_Configuration__c pc : productConfig){
             mapOfQuantity.put(pc.ID,Integer.valueOf(pc.cscfga__Quantity__c));
             mapOfNumbers.put(pc.ID,ncHelper.getTotalCountOfNumbers(pc.ID));
             }
          
          /*Iterate over the map and check if for any configuration (count of numbers < quantity), then change the cscfga_Configuration_Status_c of that configuration to 'Incomplete'.*/
        
            for(Id key :mapOfNumbers.keySet())
            {
                System.debug(' loop Key = '+key + 'Number count '+Integer.valueOf(mapOfNumbers.get(key))+' Qunatity count'+ Integer.valueOf(mapOfQuantity.get(key)));
            if(Integer.valueOf(mapOfNumbers.get(key)) < Integer.valueOf(mapOfQuantity.get(key)))
                        {
                            if (!Schema.sObjectType.cscfga__Product_Configuration__c.fields.cscfga__Configuration_Status__c.isUpdateable()) {
                            return false;
                        }
                    
                        queryProductConfig = 'Select id from cscfga__Product_Configuration__c where ID = :key';
                        productConfig=Database.query(queryProductConfig);
                        
                         for(cscfga__Product_Configuration__c pc : productConfig){
                            pc.cscfga__Configuration_Status__c='Incomplete';
                            prodConfigUpdateList.add(pc);
                             System.debug(' Pc updated = '+pc);
                            break;
                            }
                           
                        validMobilityBasket = false;
                  
                }
            }
            if(prodConfigUpdateList!=null && !prodConfigUpdateList.isEmpty())
                update prodConfigUpdateList;
                   
        }
        catch(Exception e)
        {
           system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
            return false;
        }
        System.debug('validMobilityBasket = '+validMobilityBasket);
        return validMobilityBasket;
    }
}