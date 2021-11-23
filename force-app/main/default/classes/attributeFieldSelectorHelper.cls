/*************************************************************************************************
Name : attributeFieldSelectorHelper
TestClass:attributeFieldSelectorHelperTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit          22-nov-2020   
2.          Gokul               15/12/2020  EDGE-178211,187998,181998,188858,187313 - Create OLIS for RatecardLineItems - TC,MS,MDM
3.			 shubhi              2.2.2021       EDGE-193068
===============================================================================================================================
***************************************************************************************************/

public with sharing class attributeFieldSelectorHelper {
    public CS_AttributeFieldSelector attrFieldSelector;
    public set<String> basketIdset{get;set;}
    
     public attributeFieldSelectorHelper(){
        attrFieldSelector = new CS_AttributeFieldSelector();
    }
    public Map<string,cscfga__Attribute_Field__c> attributeCondition(String queryPattern){
        Map<string,cscfga__Attribute_Field__c> returnMap = new  Map<string,cscfga__Attribute_Field__c>();
        if(queryPattern!=null){
            String attrConditionStr = '';
            String conditionStr ='';
            switch on queryPattern 
            {
                when 'byFieldNameList'{
                   if(!this.basketIdset.isEmpty()){
                        conditionStr = 'Name IN (\'isRateCardLineItem\',\'LineItem\') AND cscfga__Value__c=\'True\' AND cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN';//EDGE-178211,187998,181998,188858,187313
                        attrConditionStr =  generateConditionForList(conditionStr,this.basketIdset);   
                       	for(cscfga__Attribute_Field__c attrField : attrFieldSelector.fetchAttributeByConditions(attrConditionStr,true,false)){
                          returnMap.put((string)attrField.cscfga__Attribute__c,attrField);
                    }                 
                }
            }
                //EDGE-193068 start
                when 'byRedeemFundAction'{
                   if(!this.basketIdset.isEmpty()){
                        conditionStr = 'Name = \'OneFundAction\' AND cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN';//EDGE-178211,187998,181998,188858,187313
                        attrConditionStr =  generateConditionForList(conditionStr,this.basketIdset);
                       	for(cscfga__Attribute_Field__c attrField : attrFieldSelector.fetchAttributeByConditions(attrConditionStr,true,true)){
              returnMap.put((string)attrField.cscfga__Attribute__c,attrField);
            }
        }
                }
                //EDGE-193068 end-------------
            }
            
        }
        return returnMap;      
    }
    public static String generateConditionForList(String conditionStr,set<String>idSet){
                        String str = '';
                        Integer Count= 0;
                        Integer lastIndexOfSet=idSet.size();
                        for(String basId : idSet){
                            Count++;
                            system.debug('Count::::'+Count+'::::'+lastIndexOfSet);
                            if(lastIndexOfSet==Count){
                                 str += '\''+basId+'\'';}
                            else{
                              str += '\''+basId+'\',';}
                        }    
                        conditionStr +='('+str+')';
                     return conditionStr;        
        
    }


}