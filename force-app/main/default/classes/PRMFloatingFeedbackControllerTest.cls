/*
Version     Author                         Last Modified Date      Description
v1.0        Vivian Charlie (Team Hawaii)     02 Dec 2020           Initial Draft
*/
@isTest
public class PRMFloatingFeedbackControllerTest {
    private static testMethod void insertFileTest(){
        Test.startTest();
        Id recordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_for_Partners').getRecordTypeId();    
        list<Case> lstC = PRMTestUtility.createCases(1,recordTypeId);
        insert lstC;

        ContentVersion cv = PRMFloatingFeedbackController.uploadFile(lstC[0].Id, 'Test File', 'Test File Value');
        Test.stopTest();
        List<ContentVersion> uploadedFiles = [SELECT Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId =: lstC[0].Id];
        System.assertNotEquals(null, cv.Id, 'Checking that content version is created');
        System.assertEquals(uploadedFiles[0].Id, cv.Id, 'Checking that content version is attached to case');
    }
}