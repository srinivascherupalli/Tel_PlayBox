public  with sharing class FieldSetExtractor {

	public static application__c app;
    public static string getHelpTextofField(string field){
        Map<String, Schema.SObjectField> objectFields = Schema.SObjectType.Application__c.fields.getMap();
        Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
        System.debug(dr.getInlineHelpText());
        //return dr.getInlineHelpText();
           return dr.getInlineHelpText(); 
    }
    
    public static object getDataofField(string field){
        Map<String, Schema.SObjectField> objectFields = Schema.SObjectType.Application__c.fields.getMap();
        Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
        
        if(app!=null)
        	return app.get(field);
        
        return '';
	}
    
    public static list<QuestionAndAnswerWrapper> getQuestionAndAnsWrap(string fieldsetname,string recordId){
        Schema.FieldSet fs1 = Schema.SObjectType.application__c.fieldSets.getMap().get(fieldsetname);
        string query='Select ';
        for(Schema.FieldSetMember f : fs1.getFields()) {
        	 query += f.getFieldPath() + ', ';
		}
        query += 'Id, Name FROM application__c where id=\''+recordId+'\'';
        
        if(recordId!=null && recordId!='')
        	app=database.query(query);

        
        list<QuestionAndAnswerWrapper> questionAndAns=new list<QuestionAndAnswerWrapper>();
        for(Schema.FieldSetMember f : fs1.getFields()) {
        	questionAndAns.add(new QuestionAndAnswerWrapper(getHelpTextofField(f.getFieldPath()),getDataofField(f.getFieldPath())));	
        }
        if(!questionAndAns.isEmpty())
            return questionAndAns;
        
        return null;
    }
    
    @auraenabled
    public static ID createNewApplication(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Application__c;
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        
        Application__c newApp=new Application__c(recordtypeid=rtMapByName.get('TPA').getRecordTypeId(),ApplicationType__c='Third Party Application');
        insert newApp;
        app=newApp;
        return newApp.id;
    }
    
    public static application__c getApplication(){
        return app;
    }
    
    public static list<QuestionAndAnswerWrapper> getQuestion(string fieldsetname){
    	Schema.FieldSet fs1 = Schema.SObjectType.application__c.fieldSets.getMap().get(fieldsetname);
        list<QuestionAndAnswerWrapper> questionAndAns=new list<QuestionAndAnswerWrapper>();
        for(Schema.FieldSetMember f : fs1.getFields()) {
        	questionAndAns.add(new QuestionAndAnswerWrapper(getHelpTextofField(f.getFieldPath())));	
        }
        if(!questionAndAns.isEmpty())
            return questionAndAns;
        
        return null;
    }
}