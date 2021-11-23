/*********************************************************************************************************************************
*Class Name        :   UpdateModuleChangeforOppty
*Story             :   INC000094596954
*Developer         :   Mohammed Zeeshan

Test Class : UpdateModuleChangeforOpptyTest
*****************************************************************************************************************************/
global with sharing class UpdateModuleChangeforOppty implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap){
        system.debug('Inside getData');
        list<cscfga__Product_Basket__c> opptyBasket = new list<cscfga__Product_Basket__c>();
        set<ID> basketIdSet = new set<ID>();
        list<String> s1 = new List<String>();
        s1.add('test1');        
        s1.add('test2');
        s1.add('test3');
        Set<String> inputKey = inputMap.keySet();
        for (String k : inputKey){
            if (k == 'GetBasket'){
                String basketId = (String)inputMap.get('GetBasket');
                System.debug('GetBasket for basketId:  ' + basketId);
                
                basketIdSet.add(basketId);
                
            }  
        }
        List<cscfga__Product_Basket__c> basketList=  [select id,cscfga__Opportunity__c from cscfga__Product_Basket__c where id =:basketIdSet];
        set<Id> oppIds = new set<Id>();
        list<opportunity> updateOpptyList = new list<opportunity>();
        for(cscfga__Product_Basket__c basket: basketList){
            oppIds.add(basket.cscfga__Opportunity__c);
            
        }
        for(opportunity  opp: [select id,Model_Change__c from opportunity where id=: oppIds]){
            opp.Model_Change__c= true;
            updateOpptyList.add(opp);
        }
        update updateOpptyList; 
        
        return null;
        
        
        
    }
}