/*************************************************************************************************
Name : CS_AttributeFieldSelector
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework
2.       Shubhi            2.2.2021       EDGE-193068
===============================================================================================================================
***************************************************************************************************/
public with sharing class CS_AttributeFieldSelector extends fflib_SObjectSelector{
    private List<String> queryFieldList;
    public schema.SObjectType getSObjectType(){
        return cscfga__Attribute_Field__c.sObjectType;
    }
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            cscfga__Attribute_Field__c.Id,
            cscfga__Attribute_Field__c.Name,
            cscfga__Attribute_Field__c.cscfga__Attribute__c,
            cscfga__Attribute_Field__c.cscfga__Value__c
        };
    }
    
    public List<cscfga__Attribute_Field__c> selectById(Set<Id> recordIds){
       return (List<cscfga__Attribute_Field__c>) selectSObjectsById(recordIds);
  }
    
  public void setFieldsToQuery(List<String> fieldList){
    this.queryFieldList = fieldList;
  }
    
    public List<cscfga__Attribute_Field__c> fetchAttributeByConditions(String conditionStr,Boolean includeAllFields,Boolean queryParent){ // added new param //EDGE-193068   
        fflib_QueryFactory query  =newQueryFactory(includeAllFields);
        if(queryParent){ ////EDGE-193068 start
            CS_AttributeSelector attFactory=new CS_AttributeSelector();
          attFactory.configureQueryFactoryFields(query,'cscfga__Attribute__r');
            CS_productConfigSelector prodConfig=new CS_productConfigSelector();
            prodConfig.configureQueryFactoryFields(query,'cscfga__Attribute__c.cscfga__Product_Configuration__r');// Edge-202203 
        }////EDGE-193068  end
        List<cscfga__Attribute_Field__c> attributeFieldList = new List<cscfga__Attribute_Field__c>();
        String queryStr ='';
        if(includeAllFields){
                queryStr = query.setCondition(conditionStr).toSOQL();
                system.debug('comment this query  : ' + queryStr);
        }else{
                queryStr =query.selectFields(this.queryFieldList).setCondition(conditionStr).toSOQL();
                system.debug('comment this query : ' + queryStr);
        }
    /*
     
    */        
        attributeFieldList = Database.query(queryStr);
        return attributeFieldList;
    }
 
}