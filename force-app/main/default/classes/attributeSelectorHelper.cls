/*************************************************************************************************
Name : attributeSelectorHelper
===============================================================================================================================
Sr.No.  Developer Name      Date            Story Description
1.      Ankit               22-nov-2020   
2.      Pooja               19-Feb-2020     EDGE-201199:Inflight Basket Chatter Notification framework          
3.      Gokul               24/02/2021      EDGE-195270 - Added Description in the attribute Query
===============================================================================================================================
***************************************************************************************************/

public with sharing class attributeSelectorHelper {
    public CS_AttributeSelector attrSelector;
    public set<String> basketIdSet{get;set;}
    public set<String> attributeIdSet{get;set;}
    
     public attributeSelectorHelper(){
        attrSelector = new CS_AttributeSelector();
    }
    public List<cscfga__Attribute__c> attributeCondition(String queryPattern){
        List<cscfga__Attribute__c> returnList = new list<cscfga__Attribute__c>();
        List<string>addQueryList =new List<string>();
        addQueryList.add('cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName');
        addQueryList.add('cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c');
        addQueryList.add('cscfga__Product_Configuration__r.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c');
        addQueryList.add('cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c');
        addQueryList.add('cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Description__c');//EDGE-195270

        attrSelector.addQueryList=addQueryList;
        if(queryPattern!=null){
            String attrConditionStr = '';
            String conditionStr ='';
            String queryStr = '';
            String orStr = '';
            String additionrConditionStr ='';
            switch on queryPattern 
            {
                when 'byAFD'{
                       if(this.attributeIdSet != null &&  this.basketIdSet!= null && !this.attributeIdSet.isEmpty() ){
                           queryStr='id IN';
                           attrConditionStr =  generateConditionForList(queryStr,this.attributeIdSet);  
                        }if(this.attributeIdSet != null  &&  this.basketIdSet!= null && !this.attributeIdSet.isEmpty() && !this.basketIdSet.isEmpty() ){
                           orStr='OR';
                        }
                        if(this.basketIdSet!= null && !this.basketIdSet.isEmpty() ) {
                            conditionStr = attrConditionStr + orStr+'((cscfga__Is_Line_Item__c = true) AND (NOT Name like \'%Price_Adjustment%\') AND cscfga__is_active__c = true AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN';
                            attrConditionStr = generateConditionForList(conditionStr,this.basketIdSet)+')';        
                        }                 
                }
                when 'redeemFund' { //START:EDGE-201199
                    if(this.basketIdSet!= null && !this.basketIdSet.isEmpty() ) {
                        conditionStr    =   'Name=\'RedeemFund\' '; 
                        conditionStr    +=  'AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN ';
                        attrConditionStr = generateConditionForList(conditionStr,this.basketIdSet);        
                    }
                }   //END:EDGE-201199
            }
            returnList = attrSelector.fetchAttributeByConditions(attrConditionStr);
        }
        return returnList;      
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