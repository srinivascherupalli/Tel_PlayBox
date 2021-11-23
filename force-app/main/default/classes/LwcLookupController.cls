/*-------------------------------------------------
*  ** Change Log **
*  Sl. No.  Developer Name      Date            Story           Description
*  1.       Ajith               24/06/2021      EDGE-226038    	SonarQube fix
--------------------------------------------------*/
//EDGE-181457  reusabele lookup controler LWC
public with sharing class LwcLookupController {
    //Fetching records dynamically bypassing parameters
  @AuraEnabled(cacheable = false)

  public static List < sobject > findRecords(String searchKey, String objectName, String filterString,String searchFields) {

      List < SObject > returnrec = new List < SObject > ();
      //string searchText = '';
     /* if (objectName == 'Account') {
          if (String.isEmpty(filterval) && String.isEmpty(selectedOrder)) {
              System.debug(filterval + 'Testingfilterval6');
              searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
              query = 'SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + ' LIMIT 5';
              returnrec = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + ' LIMIT 5');
          } else {
              searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
              csord__Order__c orderId = [select id, csord__Account__c from csord__Order__c where id =: selectedOrder];
              string ordId = orderId.csord__Account__c;
              System.debug(ordId+'ordId');
              returnrec = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE id =: ordId LIMIT 5');
              system.debug(returnrec + 'Returened Order');
          }
      } else
      if (objectName == 'Contact' && !string.isEmpty(filterval)) {
          System.debug(filterval + 'Testingfilterval');
          searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
          query = 'SELECT Id, Name FROM ' + objectName + ' WHERE accountId =: filterval and Name LIKE ' + searchText + ' LIMIT 5';
          system.debug(query + 'query#######3');
          returnrec = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE accountId =: filterval and Name LIKE ' + searchText + ' LIMIT 5');
      } else
      if (objectName == 'csord__Order__c') {
          if (!String.isEmpty(filterval)) {
              searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
              query = 'SELECT Id, Name FROM ' + objectName + ' WHERE csord__Account__c =:filterval and Name LIKE ' + searchText + ' LIMIT 5';
              system.debug(query + 'query#######3');
              returnrec = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE csord__Account__c =:filterval and Name LIKE ' + searchText + ' LIMIT 5');
          } else {
              System.debug(filterval + 'Testingfilterval6');
              searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
              query = 'SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + ' LIMIT 20';
              returnrec = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + ' LIMIT 5');
          }
      }*/
      String searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
      List<String> searchFieldList = new List<String>();
      if(searchFields ==null){searchFields='';
                             }else 
                             {searchFields= searchFields+',';
                              searchFieldList=searchFields.split(',');
                             }
      String queryStr='SELECT '+String.escapeSingleQuotes(searchFields)+'Id, Name FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE (Name LIKE ' + searchText ;
      for(String searchField: searchFieldList){
          queryStr +=  ' OR '+String.escapeSingleQuotes(searchField)+' LIKE '+searchText;
      }
      //EDGE-226038 SonarQube fix
      queryStr+= ') AND ';      
      List<String> filterStringList = new List<String>();
	  
      if(filterString !='undefined' && filterString!=null){ 
	    //EDGE-226038 SonarQube fix	
          filterStringList=filterString.split('\'');
              for(String filterStr:filterStringList){                  
    				queryStr+=String.escapeSingleQuotes(filterStr)+'\'';
}
                }
      
      queryStr += ' LIMIT 5';

      System.debug('Query : '+ queryStr);

      returnrec = Database.query(queryStr);
      return returnrec;
  }
}