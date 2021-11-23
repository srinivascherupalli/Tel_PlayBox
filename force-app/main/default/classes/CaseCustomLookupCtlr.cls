/*********************************************************************************************************************************
 *Class Name      :   CaseCustomLookupCtlr

Test Class : CaseCustomLookupCtlrTest
Ch.No.    Developer Name          Date          Story Description

1.        Manish Berad           15/09/2020     EDGE-172345 As a Sales Enterprise user, I want to provide Sales support case 
												# while creating a MAC Order, so that I can skip Customer Pre-Authorisation flow.
 *********************************************************************************************************************************
*/
public with sharing class CaseCustomLookupCtlr{
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value,String AccountId){
        String caseRecordTypeName='Sales Support';
        String accId=String.escapeSingleQuotes(AccountId.trim());
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField) + ' FROM '+String.escapeSingleQuotes(objectName);
            if(objectName=='Case'){
                if(String.isNotBlank(value)) {
                    query += ' WHERE Id = \''+ String.escapeSingleQuotes(value) + '\' AND RecordType.Name=:caseRecordTypeName AND AccountId=:accId LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                        ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' AND RecordType.Name=:caseRecordTypeName AND AccountId=:accId LIMIT 49999';
                }
            }
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
}