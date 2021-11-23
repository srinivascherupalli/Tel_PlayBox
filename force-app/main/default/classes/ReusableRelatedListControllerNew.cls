/********************************************************************/
// Class Name:  ReusableRelatedListControllerNew
// Description: For EDGE-150237
// Author:  Ravi Shankar V
// Date Created:    10-Jun-2020
// Revision History:
/*********************************************************************/
public with sharing class ReusableRelatedListControllerNew {
    @AuraEnabled( cacheable=true ) 
    public static RelatedListWrapper fetchRecords( String listValues )  { 
        RelatedListWrapper objWrap = new RelatedListWrapper();
        List < String > paramLst;
        List < SObject > parentRecLst;
        try{
            //system.debug( 'values are ' + listValues ); 
            List < String > strList = listValues.split( '-' );
            string paramIndex = '1';
            if ( strList.size() == 6 ) {           //reading all input parameters  
                String recordId = strList.get( 0 );
                String objectName = strList.get( 1 ); 
                String parentObjectName = strList.get( 2 ); 
                String filterStr = strList.get( 3 ); 
                String paramsList = strList.get( 4 ); 
                String fieldsList = strList.get( 5 );
                
                if(paramsList != null && paramsList != ''){
                    paramLst = paramsList.split( ',' );
                    String strParamsSOQL =  'SELECT Id';
                    strParamsSOQL += ', ' + paramsList;
                    strParamsSOQL += ' FROM ' + parentObjectName + ' WHERE Id' + ' = \'' + recordId +'\'';
                    parentRecLst = Database.query( strParamsSOQL );//query runs only when parent object field values are needed for actual query
                }
                
                String strSOQL = 'SELECT Id'; //preparing the actual query search string
                strSOQL += ', ' + fieldsList;
                String filter = ' FROM ' + objectName + ' WHERE '; 
                if(filterStr !='undefined'){                
                    filter += filterStr; 
                }
                if(paramsList != null && paramsList != ''){
                    for(String s :paramLst){
                        if(s.contains('.')){
                            filter = filter.replace('param'+paramIndex, '\''+(string)parentRecLst[0].getSObject(s.substringBefore('.')).get(s.substringAfter('.'))+'\'');
                        }
                        else{
                            filter = filter.replace('param'+paramIndex, '\''+(string)parentRecLst[0].get(s)+'\'');
                        }
                        paramIndex = String.valueOf(Integer.valueOf(paramIndex)+1);
                    }
                }
                strSOQL += filter + ' ORDER BY LastModifiedDate DESC LIMIT 200';
                objWrap.listRecords = Database.query( strSOQL ); //final query
                objWrap.recordCount = objWrap.listRecords.size();
            }  
        } 
        catch(exception e){
            system.debug('Error occurred::'+e.getmessage()+':::'+e.getLineNumber());
        }
        system.debug('objWrap::'+objWrap);
        return objWrap; 
         
    } 
      public class RelatedListWrapper {

        @AuraEnabled
        public List < SObject > listRecords;
        @AuraEnabled
        public Integer recordCount;

    }
}