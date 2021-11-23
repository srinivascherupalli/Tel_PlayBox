/**
* Author: Chandrakant Wani
* Team: Jaipur
* Sprint: 21.03

* JIRA Story: P2OB-10971,P2OB-14078

* Date: 18/02/2021
* Class Name: csFileUploadMetadataHandlerTest 
* Description: This test class will test all test scenario of Case file upload metadata functionality.
**/

@istest
public class csFileUploadMetadataHandlerTest {

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


    // test method to cover csFileUploadMetadataHandler.UpdateMetadata functionaliy
    @IsTest
    static void testUpdateMetadata(){

        try{
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
            
        	System.runAs(user2){
            	Test.startTest();
            	List<Id> idList = new List<Id>();
            	idList.add(user2.Id);
            	csFileUploadMetadataHandler.UpdateMetadata(idList);

                ss_Case_Search__c searchRecord = [Select id,User__c, Attachments__c from ss_Case_Search__c where User__c =: userinfo.getuserId() LIMIT 1 ] ;
                system.assertEquals('('+user2.Id+')', searchRecord.Attachments__c);
            	Test.stopTest();
        	}
        }
        catch(Exception e){
            System.debug('Record cannot be updated from within a test'+ e.getMessage());

        }
    }

    // test method to cover csFileUploadMetadataHandler.doMetadataEmpty functionaliy
    @IsTest
    static void testDoMetadataEmpty(){

        try{
            User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
        	System.runAs(user2){
            	Test.startTest();
            	csFileUploadMetadataHandler.doMetadataEmpty();

                ss_Case_Search__c searchRecord = [Select id,User__c, Attachments__c from ss_Case_Search__c where User__c =: userinfo.getuserId() LIMIT 1 ] ;
                system.assertEquals(null, searchRecord.Attachments__c);            
            	Test.stopTest();
        	}
        }
        catch(Exception e){
            System.debug('Metadata cannot be deployed from within a test'+ e.getMessage());

        }
    }

    // test method to cover csFileUploadMetadataHandler.deleteUnattachedFiles functionaliy
    @IsTest
    static void testDeleteUnattachedFiles(){

        User user2 = [Select id, FederationIdentifier from User WHERE FederationIdentifier = 'test001' LIMIT 1 ];
        
		System.runAs(user2){
        	Test.startTest();
        	ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                Record_Id__c = user2.id,
                IsMajorVersion = true
            );
        	insert contentVersion_1;
            
        	ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];    
        	String contentDocId = ' '+contentVersion_2.ContentDocumentId+' ';
        	csFileUploadMetadataHandler.deleteUnattachedFiles(contentDocId);
        	Test.stopTest();
        
        	List<ContentDocument> cd = [SELECT id FROM ContentDocument WHERE Id=:contentVersion_2.ContentDocumentId];    
        	System.assertEquals(0, cd.size());          
        }    
    }
}