@isTest
public class FieldSetExtractorTest {

    //@testSetup
 public static testMethod void TestgetData()
    {
       Application__c b = new Application__c(Applicant_Name__c='Behind the Cloud',Litigation_Place_filed1__c='Placefield');
        //= new QuestionAndAnswerWrapper[];
       	insert b;
    	String fieldSetname='Application_Litigation_Investigation';
        Test.StartTest();
		
       // Retrieve the Application
       	b = [SELECT Applicant_Name__c,Litigation_Place_filed1__c FROM Application__c WHERE Id =:b.Id];
        String helpText = Application__c.Litigation_Place_filed1__c.getDescribe().getInlineHelpText();
        System.debug('Applicant_Name__c: ' + b.Applicant_Name__c);
        System.debug('Id: ' + b.Id);
        String RecId=b.Id;
		applicationRecordContr testappContr = new applicationRecordContr();
      	//String queAndAns1= 
      	String fieldName='Litigation_Place_filed1__c';
      	String QAAnswer=FieldSetExtractor.getHelpTextofField(fieldName);
        //List<String>=   testappContr.getData(fieldSetname,RecId);
        //Test that the trigger correctly updated the price
    	System.debug('jj'+QAAnswer+helpText);
        
               //System.assertEquals('Placefield', b.Litigation_Place_filed1__c);
        System.assertEquals(QAAnswer, helpText);
       
        //getApplication
        
   		Id ApplId=FieldSetExtractor.createNewApplication();
        System.Assert(ApplId != null);
       list<QuestionAndAnswerWrapper> QA= FieldSetExtractor.getQuestion(fieldSetname);
       System.debug('kk'+QA); 
       String QQAQuestion= QA[2].Question;
		System.debug('ll'+QQAQuestion+helpText);        
         System.assertEquals(QQAQuestion,helpText); 
        list<QuestionAndAnswerWrapper> QAnswer= FieldSetExtractor.getQuestionAndAnsWrap(fieldSetname,RecId);
        System.debug('ll2'+QAnswer[2].Answer+helpText);  
        System.assertEquals(QAnswer[2].Answer, 'Placefield');
        //Create Application record
        Test.stopTest(); 
    }
}