/***************************************************************************************************
Name          : DomainLookup
Created By    : Ramcharan Patidar
Created Date  : Dec 20 2020
Description   : This class is the Product Domain Search through SRV List filter in Solution Console
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ramcharan Patidar        20-12-2020          Created

1.2         Ramcharan Patidar        08-Feb-2021         P2OB-12512 <CloudSense> Standard Solution | CI & QA2 org | Search option on Primary basket fields not working
1.3         Ramcharan Patidar        17-Feb-2021         P2OB-12637 <Cloudsense><Solution Console> Domain and Product dropdown values should appear in alphabetical order
1.4         Ramcharan Patidar        15-Mar-2021         P2OB-13485 <Cloudsense><Solution Console> Only active products should be visible in Product lookup list

1.5         Ramcharan Patidar        29-Apr-2021         P2OB-13549 <Cloudsense><Solution Console> Selection of Product without selecting the Product Domain in Solution Console for Standard Products
1.6         Ramcharan Patidar        31-May-2021         P2OB-15112 <Cloudsense><Solution Console> SonarQube fixes for CI org
***************************************************************************************************/
global with sharing class DomainLookup extends cscfga.ALookupSearch {
public override String getRequiredAttributes()
    {return '[]';}
    
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {       
        String searchQuery;


        List<cspmb__Price_Item__c> CommercialProductsList = new  List<cspmb__Price_Item__c>();
        // P2OB-12512 Start
        String searchValue = String.escapeSingleQuotes('');
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + String.escapeSingleQuotes(searchFields.get('searchValue')) + '%';
        }
        String srvList = searchFields.get('srvListString') != null ? searchFields.get('srvListString') : '';
        String productString = searchFields.get('productString') != null ? searchFields.get('productString') : '';  // added P2OB-13549
        //String searchValue = searchFields.get('Domain_SC');
     
        String searchMatch = String.escapeSingleQuotes('');

        String seatsString = String.escapeSingleQuotes('Seats');
        String singleQuoates = '\'';
        String orderByName= ' ORDER BY domain__c ASC NULLS LAST'; //P2OB-12637
        String activeProductFilter = String.escapeSingleQuotes(' AND cspmb__Is_Active__c = true AND Check_todays_date__c = true ');
        String isProductCodeNotEqualsSeats = String.escapeSingleQuotes('AND cspmb__Price_Item_Code__c != ');       

        String isDomainNotEqualsNull = String.escapeSingleQuotes('AND domain__c != null ');  // added P2OB-13549      

        if (!String.isEmpty(searchValue) ) {
          searchMatch = 'domain__c like ' + '\'' + searchValue + '%\'';
        }
        searchQuery = String.escapeSingleQuotes('SELECT Id,name,domain__c FROM cspmb__Price_Item__c');
        System.debug('DomainType searchQuery: ' + searchQuery);
        String whereClause = String.escapeSingleQuotes('');
        if(String.isEmpty(productString)){
        if (String.isEmpty(searchMatch)) {

              whereClause = ' WHERE SRM_List__c = \'' + String.escapeSingleQuotes(srvList) + '\' AND name != null' + activeProductFilter + isDomainNotEqualsNull + isProductCodeNotEqualsSeats + singleQuoates + seatsString + singleQuoates + orderByName; // Added + orderByName related to P2OB-12637
            } else {
              whereClause = ' WHERE SRM_List__c = \'' + String.escapeSingleQuotes(srvList) + '\' AND ' + searchMatch + activeProductFilter + isDomainNotEqualsNull + isProductCodeNotEqualsSeats + singleQuoates + seatsString + singleQuoates + orderByName; // Added + orderByName related to P2OB-12637

        }
        }else{  // added related to P2OB-13549
            if (String.isEmpty(searchMatch)) {
              whereClause = ' WHERE SRM_List__c = \'' + srvList + '\' AND name = \'' + productString+singleQuoates + activeProductFilter + isDomainNotEqualsNull + isProductCodeNotEqualsSeats + singleQuoates + seatsString + singleQuoates + orderByName; // Added + orderByName related to P2OB-12637
            } else {
              whereClause = ' WHERE SRM_List__c = \'' + srvList + '\' AND name = \'' + productString+singleQuoates + searchMatch + activeProductFilter + isDomainNotEqualsNull + isProductCodeNotEqualsSeats + singleQuoates + seatsString + singleQuoates + orderByName; // Added + orderByName related to P2OB-12637
            }
        }
        
        // P2OB-12512 End 
        system.debug('orderBySerach>>>>>>>>>>>>>'+ searchQuery + whereClause );
        if(String.isNotBlank(searchQuery))
             CommercialProductsList =Database.query(searchQuery + whereClause);   // P2OB-12512 Added + whereClause


        System.debug('CommercialProductsList: ' + CommercialProductsList);
         
        List<cspmb__Price_Item__c> distinctDomainList = getUniqueListByField(CommercialProductsList,'Domain__c');
        


        return distinctDomainList;
    }
   @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Domain__c' && !itemMap.containsKey(item.Domain__c)) {
                itemMap.put(item.Domain__c, item);
            }
        }
        System.debug('-----------> unique domain values 1   ' + itemMap.values());
        return itemMap.values();
    }
}