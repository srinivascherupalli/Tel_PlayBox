/***************************************************************************************************
Name          : FamilyLookup
Created By    : Ramcharan Patidar
Created Date  : Dec 20 2020
Description   : This class is the Product Family Search through Doamin and Srv List filter in Solution Console
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ramcharan Patidar        20-12-2020          Created

1.2         Ramcharan Patidar        08-Feb-2021         P2OB-12512 <CloudSense> Standard Solution | CI & QA2 org | Search option on Primary basket fields not working
1.3         Ramcharan Patidar        17-Feb-2021         P2OB-12637 <Cloudsense><Solution Console> Domain and Product dropdown values should appear in alphabetical order


***************************************************************************************************/

global with sharing class FamilyLookup extends cscfga.ALookupSearch {
    
public override String getRequiredAttributes()
    {return '["domainString"]';}
    
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {    
        String searchQuery;
        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
           searchValue = '%' + searchFields.get('searchValue') + '%';
        }


        List<cspmb__Price_Item__c> CommercialProductsList = new  List<cspmb__Price_Item__c>();
       String srvList = searchFields.get('srvListString') != null ? searchFields.get('srvListString') : '';
       String domainString = searchFields.get('domainString') != null ? searchFields.get('domainString') : '';
       //Start- P2OB-12512
       String searchMatch = '';

       String orderByFamily= ' ORDER BY Product_Family__c ASC NULLS LAST'; // Added + orderByFamily P2OB-12637

        if (!String.isEmpty(searchValue) ) {
          searchMatch = 'Product_Family__c like ' + '\'' + searchValue + '%\'';
        }
        searchQuery = 'SELECT Id,name,Product_Family__c FROM cspmb__Price_Item__c'; 
        String whereClause = '';
        if (String.isEmpty(searchMatch)) {

          whereClause = ' WHERE SRM_List__c = \'' + srvList + '\' AND domain__c= \'' + domainString + '\' AND name != null' + orderByFamily; // Added + orderByFamily P2OB-12637
        } else {
          whereClause = ' WHERE SRM_List__c = \'' + srvList + '\' AND  domain__c= \'' + domainString + '\' AND ' + searchMatch + orderByFamily; // Added + orderByFamily P2OB-12637

        }     
      //End- P2OB-12512
      
       if(String.isNotBlank(searchQuery))
           CommercialProductsList =Database.query(searchQuery + whereClause);   //P2OB-12512- added + whereClause
         
        List<cspmb__Price_Item__c> distinctPrdGrpList = getUniqueListByField(CommercialProductsList,'Product_Family__c');
        



        return distinctPrdGrpList;
    }

  @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Product_Family__c' && !itemMap.containsKey(item.Product_Family__c)) {
                itemMap.put(item.Product_Family__c, item);
            }
        }
        System.debug('-----------> unique product Family values 1   ' + itemMap.values());
        return itemMap.values();
    }
}