/*
 * This controller class is invoked from CaseArticle lightning component.
 * This class collects all the articles attached to case. 
*/
public without sharing class CaseArticleController {
    
    @AuraEnabled
    public static List<KnowledgeArticleVersion> getCaseArticles(Id caseId){
        List<KnowledgeArticleVersion> caseArticleList = null;
        List<String> caseArticleIds = new List<String>();
        List<attachment> cdList = new List<attachment>();
        List<CaseArticle> knowArtList = [SELECT KnowledgeArticleId,ArticleVersionNumber , CaseId FROM CaseArticle WHERE CaseId = :caseId];
        system.debug('knowArtList'+knowArtList);
        system.debug('caseId'+caseId);
        system.debug('CaseArticleController.getCaseArticles() knowArtList.size(): '+knowArtList.size());
        if(knowArtList.size() > 0){
            for(CaseArticle article: knowArtList){
                    system.debug('article.KnowledgeArticleId'+article.KnowledgeArticleId);
                   system.debug('article.ArticleVersionNumber '+article.ArticleVersionNumber );

                caseArticleIds.add(article.KnowledgeArticleId);
            system.debug('CaseArticleController.getCaseArticles() caseArticleIds.size(): '+caseArticleIds.size());
            if(caseArticleIds.size() > 0){
                caseArticleList = [SELECT Title, Summary, UrlName FROM KnowledgeArticleVersion 
                                                             WHERE PublishStatus='Online' AND KnowledgeArticleId IN :caseArticleIds AND Language = 'en_US'];
                system.debug('CaseArticleController.getCaseArticles() caseArticleList.size(): '+caseArticleList.size());
                system.debug('articleID'+article.Id);
                                system.debug('url'+article.KnowledgeArticleId);

             }
         
        }
        
       }
    return caseArticleList;
   }
}