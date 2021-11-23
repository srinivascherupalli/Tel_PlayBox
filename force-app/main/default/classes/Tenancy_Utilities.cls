/*
* @Desc : Tenancy Utility class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class Tenancy_Utilities {
    // EDGE-101077 - Quote and Order form updates for Mobility Managed Service
    public List<Map<String,Object>> getTenancyDetails(String basketId, Map<String,String> subfilters){    
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer externalId = 1;
        String ProductDefnition = subfilters.get('Product_Module_Name');
        try{
            list<cscfga__Attribute__c> atributelist=[Select cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c,Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__c=:basketId and cscfga__Product_Configuration__r.cscfga__Product_Definition__r.Name=:ProductDefnition];
           //// List<cscfga__Attribute__c> atributelist = [Select Id, Name, cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__c=:basketId and cscfga__Product_Configuration__r.cscfga__Product_Definition__r.Name=:ProductDefnition];
            if(atributelist != null && atributelist.size()>0){				//// added this check
            for(cscfga__Attribute__c attr:atributelist){        
                if(attr.Name=='TenancyID'){
                    Map<String,Object> newRow = new Map<String,Object>();  
                    newRow.put('ExternalId', externalID++);
                    newRow.put('TenancyId',attr.cscfga__Value__c); 
                    rows.add(newRow);
                }
            }
        }
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);				//// added exception
        }
        return rows;
    }
}