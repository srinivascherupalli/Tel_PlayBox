/***************************************************************************************************
Name          : CommercialProductLookup
Created By    : Ramcharan Patidar
Created Date  : Dec 20 2020
Description   : This class is the Commercial Product Search through Doamin and Product Family filter in Solution Console
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ramcharan Patidar        20-12-2020          Created


1.2         Ramcharan Patidar        02-Feb-2021         P2OB-12514 <CloudSense> Standard Solution Console Product Name label corrections
1.3         Ramcharan Patidar        08-Feb-2021         P2OB-12512 <CloudSense> Standard Solution | CI & QA2 org | Search option on Primary basket fields not working

1.4         Ramcharan Patidar        12-Feb-2021         P2OB-12626 <CloudSense> Standard Solution | CI & QA2 org | Search option on Product field should work for product code and product category
1.5         Ramcharan Patidar        17-Feb-2021         P2OB-12637 <Cloudsense><Solution Console> Domain and Product dropdown values should appear in alphabetical order
1.6         Srujana Durvasula        18-Feb-2021         P2OB-12595 <Cloudsense><Solution Console> Remove the Product Family dropdown in Solution Console
1.7         Ramcharan Patidar        15-Mar-2021         P2OB-13485 <Cloudsense><Solution Console> Only active products should be visible in Product lookup list
1.8         Ramcharan Patidar        29-Apr-2021         P2OB-13549  <Cloudsense><Solution Console> Selection of Product without selecting the Product Domain in Solution Console for Standard Products

***************************************************************************************************/
global with sharing class CommercialProductLookup extends cscfga.ALookupSearch {
public override String getRequiredAttributes()
{return '["domainString","familyString"]';}

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

    //String familyString = searchFields.get('familyString') != null ? searchFields.get('familyString') : '';
    //P2OB-12512 Start

    String searchByProductName = '';        // added P2OB-12626
    String searchByProductCode = '';        // added P2OB-12626
    String searchByProductCategory = '';    // added P2OB-12626
    String orConjunction = '';              // added P2OB-12626

    String orderByProductName= ' ORDER BY Maxim_Product_Name__c ASC NULLS LAST'; // added P2OB-12637

    /*Start changes related P2OB-13485*/
    String seatsString = 'Seats';
    String singleQuoates = '\'';
    String orderByName= ' ORDER BY domain__c ASC NULLS LAST'; //P2OB-12637
    String activeProductFilter = ' AND cspmb__Is_Active__c = true AND Check_todays_date__c = true ';
    String isProductCodeNotEqualsSeats = 'AND cspmb__Price_Item_Code__c != ';   
    /*End changes related P2OB-13485*/
        system.debug('searchValue~~~~~~'+searchValue);
        if (!String.isEmpty(searchValue) ) {
           searchByProductName = 'Maxim_Product_Name__c like ' + '\'' + searchValue + '%\'';  // added P2OB-12626
           searchByProductCode = 'Product_Code__c like ' + '\'' + searchValue + '%\'';        // added P2OB-12626
           searchByProductCategory = 'Product_Category__c like ' + '\'' + searchValue + '%\''; // added P2OB-12626
           orConjunction = ' OR ';  // added P2OB-12626
        }
        system.debug('searchByProductName~~~~~~'+searchByProductName);
        system.debug('domainString~~~~~~'+domainString);
        searchQuery = 'SELECT Id,name,Maxim_Product_Name__c,cspmb__Price_Item_Description__c,Product_Group__c,Product_Code__c,Domain__c,SRM__c,Product_Category__c FROM cspmb__Price_Item__c'; //WHERE SRM_List__c =: srvList and Domain__c =: domainString';
        String whereClause = '';
        if (String.isEmpty(domainString)){   // added P2OB-13549
            if (String.isEmpty(searchByProductName) || String.isEmpty(searchByProductCode) || String.isEmpty(searchByProductCategory)) {
                system.debug('inside_domainStringEmpty_If');
                whereClause = String.escapeSingleQuotes(' WHERE SRM_List__c = ') + singleQuoates + srvList + singleQuoates + activeProductFilter + isProductCodeNotEqualsSeats + singleQuoates + seatsString + '\' AND Maxim_Product_Name__c != null' + orderByProductName; // Removed Product_Family__c  P2OB-12595 && Added activeProductFilter - P2OB-13485
            } else {
                system.debug('inside_domainStringEmpty_else');
                whereClause = String.escapeSingleQuotes(' WHERE SRM_List__c = ') + singleQuoates + srvList + '\' AND (' + searchByProductName + orConjunction + searchByProductCode + orConjunction + searchByProductCategory + ')'  +  activeProductFilter + isProductCodeNotEqualsSeats + singleQuoates + seatsString + '\' AND Maxim_Product_Name__c != null' + orderByProductName; // Removed Product_Family__c  P2OB-12595 && Added activeProductFilter - P2OB-13485
            }   
        } else{
            if (String.isEmpty(searchByProductName) || String.isEmpty(searchByProductCode) || String.isEmpty(searchByProductCategory)) {
                whereClause = ' WHERE SRM_List__c = ' + singleQuoates + srvList + '\' AND domain__c= \'' + domainString +singleQuoates  + activeProductFilter + isProductCodeNotEqualsSeats + singleQuoates + seatsString + '\' AND Maxim_Product_Name__c != null' + orderByProductName; // Removed Product_Family__c  P2OB-12595 && Added activeProductFilter - P2OB-13485
                system.debug('inside_domainString_If');
            } else {
                whereClause = ' WHERE SRM_List__c = ' + singleQuoates + srvList  + '\' AND domain__c= \'' + domainString + '\' AND (' + searchByProductName + orConjunction + searchByProductCode + orConjunction + searchByProductCategory + ')'  +  activeProductFilter + isProductCodeNotEqualsSeats + singleQuoates + seatsString + '\' AND Maxim_Product_Name__c != null' + orderByProductName; // Removed Product_Family__c  P2OB-12595 && Added activeProductFilter - P2OB-13485
                system.debug('inside_domainString_else');
            }  
        }
        //P2OB-12512 End
        system.debug('whereClause>>>>>>>~~~'+ whereClause);
        if(String.isNotBlank(searchQuery))
        CommercialProductsList =Database.query(searchQuery + whereClause);  //P2OB-12512  added + whereClause
        
        system.debug('searchQuery>>>>>>>~~~'+ searchQuery + whereClause); 
        List<cspmb__Price_Item__c> distinctPrdGrpList = getUniqueListByField(CommercialProductsList,'name');
        return distinctPrdGrpList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'name' && !itemMap.containsKey(item.name)) {
                itemMap.put(item.name, item);
            }
        }
        System.debug('-----------> unique ProductNames>> ' + itemMap.values());
        return itemMap.values();
    }
}