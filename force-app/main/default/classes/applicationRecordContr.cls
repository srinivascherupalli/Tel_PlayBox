public with sharing class  applicationRecordContr {
	
    @auraenabled
    public static list<QuestionAndAnswerWrapper> getData(string fieldSetname,string recordid){
        system.debug('fields set name'+fieldSetname);
        system.debug('fields set record id'+recordid);
        return FieldSetExtractor.getQuestionAndAnsWrap(fieldSetname,recordid);
    }
    
    @auraenabled
    public static application__c getApplication(string fieldSetname,Id recId){
    	 Schema.FieldSet fs1 = Schema.SObjectType.application__c.fieldSets.getMap().get(fieldsetname);
        string query='Select ';
        for(Schema.FieldSetMember f : fs1.getFields()) {
        	 query += f.getFieldPath() + ', ';
		}
        query += 'Id, Name FROM application__c where id=\''+recId+'\'';
        
        return database.query(query);
    }
    
    @auraenabled
    public static Id getApplicationRecord(){
        return FieldSetExtractor.createNewApplication();
    }
    
    @auraenabled
    public static list<QuestionAndAnswerWrapper> getQuestion(string fieldSetname){
        return FieldSetExtractor.getQuestion(fieldsetname);
    }
}