@isTest
public class CaseCommentTriggerHandlerTest {
    static testMethod void restrictEditTest(){
        Account customerAccount=new Account(Name='acc',Customer_Status__c='ACTIVE');
        customerAccount.Pref_Comm_Method__c = 'B2B';
        insert customerAccount;
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.AccountId =  customerAccount.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;
        caseObj.Subject = 'Parent case';
        insert caseObj;
        Case caseChildObj = new Case();
        caseChildObj.Status = 'New';
        caseChildObj.AccountId =  customerAccount.id;
        caseChildObj.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;
        caseChildObj.ParentId = caseObj.id;
        caseChildObj.Subject = 'This is child case'; 
        insert caseChildObj; 
        System.assertEquals(caseObj!=null, true,'Create');
        CaseComment comment = new caseComment();
        comment.ParentId = caseObj.id;
        comment.CommentBody='Test';
        insert comment;
        System.assertEquals([Select count() from Casecomment where parentid=:caseChildObj.id], 1,'Casecomment inserted for child');
    }
}