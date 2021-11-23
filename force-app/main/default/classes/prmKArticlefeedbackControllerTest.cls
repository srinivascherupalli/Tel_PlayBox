/**
     Description :  P2OB-7583 Test class for prmKArticlefeedbackController
     Author      :  Ritika Jaiswal, Team Hawaii 
     Created Date:  10 August 2020 
     Jira        :  P2OB-7583
 **/
@isTest
public class prmKArticlefeedbackControllerTest {
	static testMethod void getCustomMdt_Test(){
        //Profile Map
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        //Role Map
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops'])
            rolesMap.put(role.DeveloperName, role);
        //Create Admin User
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        adminUser[0].UserPermissionsKnowledgeUser = true;
        insert adminUser;
        System.runAs(adminUser[0]){
        Id kav_recordId  = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByDeveloperName().get('Enterprise_Partner_Knowledge_Content').getRecordTypeId();
        knowledge__kav newArticle = new knowledge__kav(Title='prm-Article-Test',summary='xyz',urlname='prm-Article-Test',recordtypeid=kav_recordId);
        insert newArticle;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        }
        String urlName = 'prm-Article-Test';
        PRM_KArticle_Feedback__mdt result ;
        Test.startTest();
        result = prmKArticlefeedbackController.getCustomMdt(urlName);
        Test.stopTest();
        System.assert(result!=null);
    }
}