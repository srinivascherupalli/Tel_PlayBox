public class InlineLookUpController {
    @AuraEnabled 
    public static List<sobject> findRecords(String searchKey, String objectName,String filter) {  
        System.debug('filter: '+filter);
        //string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+'\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        if(String.isNotBlank(filter) ){
            query +=   filter; 
        }
        query +=' LIMIT 5';
        System.debug('query: '+query);
        return Database.query(query);  
    } 
    
    /*@AuraEnabled 
public static List<sobject> findRecords(String searchKey, String objectName) {  
string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';  
return Database.query(query);  

}  */    
    @AuraEnabled public static sObject findRecordOnLoad(String objectName,string recordId){
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Id = \''+recordId+'\' LIMIT 1' ;
        //Kalashree Borgaonkar. fix for SOQL injection
        //string searchText = '\'' + String.escapeSingleQuotes(recordId) + '\'';  
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Id = '+'\'' + String.escapeSingleQuotes(recordId) + '\'' ;
        system.debug('query=='+ query);
        List<SObject> lst = Database.query(query);
        return (!lst.isEmpty())? lst[0]:null;

    }
}