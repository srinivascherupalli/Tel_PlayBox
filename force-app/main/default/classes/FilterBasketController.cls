/*************************************************************************************************
Name : FilterBasketController
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Vaibhav          20-Nov-2020      EDGE-185069 - Created

===============================================================================================================================
***************************************************************************************************/
public with sharing class FilterBasketController {
    @AuraEnabled(cacheable=true)
    public static list<cscfga__Product_Basket__c> getRelatedList(String accountId)
    {
        List<cscfga__Product_Basket__c> bskList = new  List<cscfga__Product_Basket__c>();
        system.debug('accountId' +accountId);
        if(NonCommercialOrder.checkEligibleUser(accountId)){
             bskList = [Select Id, Name,Description__c,Created_By__c,csordtelcoa__Basket_Stage__c,LastModifiedDate,BasketType__c,csbb__Account__c FROM cscfga__Product_Basket__c where BasketType__c=:'Non Commercial'  AND csbb__Account__c =: accountId  LIMIT 200];
        }
        
        system.debug('Basket List' +bskList);
        return bskList;
    }
    
     @AuraEnabled(cacheable=true)
      public static ListView getListViews(String sobjectTypeName , String listviewDeveloperName) {
        ListView accListview ;
        try{
            accListview = [SELECT Id, Name FROM ListView WHERE SobjectType = :sobjectTypeName  and DeveloperName = :listviewDeveloperName LIMIT 1];
        }
        catch(Exception e){
            System.debug('FilterContactsController Class --- getListViews Method --- Exception' + e);
        }
        return accListview;
    }
    

}