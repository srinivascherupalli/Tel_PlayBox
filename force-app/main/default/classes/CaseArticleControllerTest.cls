@isTest(SeeAllData=true)
public class CaseArticleControllerTest {

    public static testMethod void TestRunOnCaseArticle()
    {
        test.startTest();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Sales Support').getRecordTypeId();
        Case caseObj = new Case(Status='New',Origin ='Email',recordtypeid=devRecordTypeId,type='CSA');
        
        insert caseObj;
        //case ca=[select ownerid from case where id=:c.id];
        
        CaseArticle caseArticle = new CaseArticle(KnowledgeArticleId='kA02O00000003yH', ArticleVersionNumber=1, CaseId=caseObj.id);       
        insert caseArticle;  
        CaseArticleController.getCaseArticles(caseObj.id);
        System.assertEquals(caseArticle.KnowledgeArticleId,'kA02O00000003yH');
        test.stopTest();
    }

}