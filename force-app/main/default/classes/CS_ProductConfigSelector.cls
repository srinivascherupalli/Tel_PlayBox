/*************************************************************************************************
Name : CS_ProductConfigSelector
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework
===============================================================================================================================
***************************************************************************************************/
public with sharing class CS_ProductConfigSelector extends fflib_SObjectSelector{
    public List<String> basketIdList;
    public List<String> queryFieldList;

    public schema.SObjectType getSObjectType(){
        return cscfga__Product_Configuration__c.sObjectType;
    }
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            cscfga__Product_Configuration__c.Id,
            cscfga__Product_Configuration__c.Name, 
            cscfga__Product_Configuration__c.Type__c,
            cscfga__Product_Configuration__c.OfferName__c,
            cscfga__Product_Configuration__c.cscfga__Quantity__c, 
            cscfga__Product_Configuration__c.cscfga__Contract_Term__c,
            cscfga__Product_Configuration__c.cscfga__Product_Family__c, 
            cscfga__Product_Configuration__c.cscfga__Product_Basket__c,
            cscfga__Product_Configuration__c.cscfga__Total_Contract_Value__c, 
            cscfga__Product_Configuration__c.Quantity_Product_Configuration__c,
            cscfga__Product_Configuration__c.subType__c,
            cscfga__Product_Configuration__c.csordtelcoa__Replaced_Product_Configuration__c
            
        };
    }
    
    public List<cscfga__Product_Configuration__c> selectById(Set<Id> recordIds){
       return (List<cscfga__Product_Configuration__c>) selectSObjectsById(recordIds);
  }
    
  public void setFieldsToQuery(List<String> fieldList){
    this.queryFieldList = fieldList;
  }
 }