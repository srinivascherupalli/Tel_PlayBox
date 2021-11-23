/*************************************************************************************************
Name : CS_AttributeSelector
Test Class:CS_AttributeSelectorTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework
===============================================================================================================================
***************************************************************************************************/
public with sharing class CS_AttributeSelector extends fflib_SObjectSelector{
    public List<String> basketIdList;
    private List<String> queryFieldList;
    public list<string>addQueryList;

    public schema.SObjectType getSObjectType(){
        return cscfga__Attribute__c.sObjectType;
    }
    public List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            cscfga__Attribute__c.Id,
            cscfga__Attribute__c.Name,
            cscfga__Attribute__c.cscfga__is_active__c,
            cscfga__Attribute__c.cscfga__Value__c,
            cscfga__Attribute__c.cscfga__Is_Line_Item__c,
            cscfga__Attribute__c.cscfga__Line_Item_Description__c,
            cscfga__Attribute__c.cscfga__Line_Item_Sequence__c,
            cscfga__Attribute__c.cscfga__Price__c,
            cscfga__Attribute__c.cscfga__List_Price__c,
            cscfga__Attribute__c.cscfga__Recurring__c,
            cscfga__Attribute__c.cscfga__Product_Configuration__c 
        };
    }
    
    public List<cscfga__Attribute__c> selectById(Set<Id> recordIds){
       return (List<cscfga__Attribute__c>) selectSObjectsById(recordIds);
  }
    
  public void setFieldsToQuery(List<String> fieldList){
    this.queryFieldList = fieldList;
  }
   public List<cscfga__Attribute__c> fetchAttributeByConditions(String conditionStr){
        List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>();
        fflib_QueryFactory query  =newQueryFactory();
        CS_productConfigSelector prodConfig=new CS_productConfigSelector();
        prodConfig.configureQueryFactoryFields(query, 'cscfga__Product_Configuration__r');
        CS_AttributeFieldSelector afdFactory=new CS_AttributeFieldSelector();
        afdFactory.addQueryFactorySubselect(query,'cscfga__Attribute_Fields__r');
        query.selectFields(addQueryList);
        String queryStr ='';
         
         if(!String.isBlank(conditionStr))queryStr = query.setCondition(conditionStr).toSOQL();
         system.debug('comment this query  : ' + queryStr);
        attributeList = Database.query(queryStr);
        return attributeList;
    }
    public List<cscfga__Attribute__c> fetchAttributeByConditions(String conditionStr,Boolean includeAllFields){
        List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>();
            String queryStr ='';
        if(includeAllFields){
                queryStr = newQueryFactory(includeAllFields).setCondition(conditionStr).toSOQL();
                system.debug('comment this query  : ' + queryStr);
        }else{
                queryStr = newQueryFactory(includeAllFields).selectFields(this.queryFieldList).setCondition(conditionStr).toSOQL();
                system.debug('comment this query : ' + queryStr);
        }
        attributeList = Database.query(queryStr);
        return attributeList;
    }
   
}