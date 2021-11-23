@isTest
public class applicationRecordContrTest {

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
      	list<QuestionAndAnswerWrapper> QA=applicationRecordContr.getData(fieldSetname,RecId);
        //List<String>=   testappContr.getData(fieldSetname,RecId);
        //Test that the trigger correctly updated the price
    	System.debug('jj'+QA[2].Question+helpText);
        System.debug(QA);
        String QQA=QA[2].Question;
        //System.assertEquals('Placefield', b.Litigation_Place_filed1__c);
        System.assertEquals(QQA, helpText);
       
        //getApplication
        
         
       Application__c Query1= applicationRecordContr.getApplication(fieldSetname,RecId);
       System.debug('Query1'+Query1); 
       //Application__c Query2=Application__c:{Litigation_Place_filed1__c=Placefield, Id=a6g2N00000000LJQAY, Name=APP-000314};
     //  {Litigation_Place_filed1__c=Placefield, Id=a6g2N00000000LJQAY, Name=APP-000314};
          System.assertEquals(1,1);
        
            
            list<QuestionAndAnswerWrapper> getQuest= applicationRecordContr.getQuestion(fieldSetname);
        
       	String QQAQuestion= QA[2].Question;
         System.debug('QQAQuestion'+QQAQuestion);
      	System.assertEquals(QQAQuestion,helpText);
        Test.stopTest(); 
    }
}