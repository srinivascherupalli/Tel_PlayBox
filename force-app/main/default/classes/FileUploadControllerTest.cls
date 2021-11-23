/**
* Author: Chandrakant Wani
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-P2OB-10677
* Date: 18/02/2021
* Class Name: FileUploadControllerTest 
* Description: This test class will cover functionalities related to get files 
                from database based on input Id's or user record metadata.
**/

@istest
public class FileUploadControllerTest {
   

    //For creating test data
    @TestSetup
    static void makeData(){

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000)); 
        User usr1 = new User(Email='newcsux@test.com',
                                 EmailEncodingKey='UTF-8', LastName='FileTestUser'+randomInt, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_AU', ProfileId = p.Id, 
                                 TimeZoneSidKey='Australia/Sydney',FederationIdentifier='test001',username='newcsux'+randomInt+'@test.com.Test',alias = 'uxUser');
        insert usr1;


        ContentVersion contentVersion_1 = new ContentVersion(
                    Title = 'Penguins',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    Record_Id__c = usr1.id,
                    IsMajorVersion = true
                );
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

        ss_Case_Search__c newSearchRecord = new ss_Case_Search__c(
            Attachments__c = '('+contentVersion_2.ContentDocumentId+')',
            User__c = usr1.id
        );
        insert newSearchRecord;

    }

    // test method to cover FileUploadController.getFilesFromMetadata functionality
    @IsTest
    static void testGetFilesFromMetadata(){

        User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        System.runAs(user2){
            Test.startTest();
            List<FileUploadController.File> files = new List<FileUploadController.File>();
            files = FileUploadController.getFilesFromMetadata();
            
            Test.stopTest();

            System.assertEquals(1, files.size());
        }   
    }

    /*

    // test method to cover FileUploadController.getRelatedFiles functionality
    @IsTest
    static void testGetRelatedFiles(){

        User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        	System.runAs(user2){
            	Test.startTest();


            
        	    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            	List<Id> idList = new List<Id>();
            	idList.add(contentVersion_2.ContentDocumentId);

                List<FileUploadController.File> files = new List<FileUploadController.File>();
                files = FileUploadController.getRelatedFiles(idList);
            	
            	Test.stopTest();
                System.assertEquals(1, files.size());
        	}
    }

    */

}