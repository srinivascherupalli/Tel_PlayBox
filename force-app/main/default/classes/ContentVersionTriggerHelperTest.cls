/*****************************************************************************
@Name : ContentVersionTriggerHelperTest
@Description : This Class is test class  for ContentVersionTrigger Helper 
@Created by : Chandrakant Wani as part of  P2OB-12607.
@Description : Test class to test Logic to attach file upload by integartion user to record.
*******************************************************************************/
@isTest
public class ContentVersionTriggerHelperTest {

  private static testMethod void attachFileToRecordTest() {
      
    try{
        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Integration - TConnect' limit 1];
        User usr1 = new User(Email='telsta1@test.com',
                                 EmailEncodingKey='UTF-8', FirstName='Tconnect', LastName='MicroService', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_AU', ProfileId = p.Id, 
                                 TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1@test.com.Test',alias = 'Use1T1');
            
        insert usr1;

        System.runas(usr1){
            Case caseObj = new Case();
            caseObj.Status = 'New';    
            caseObj.Subject = 'Test case';
            insert caseObj;
    
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                Record_Id__c = caseObj.id,
                IsMajorVersion = true
            );
            insert contentVersion_1;

            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            List<ContentDocumentLink> cdl = [SELECT ContentDocument.Id, ContentDocument.Title
                FROM ContentDocumentLink where ContentDocumentId =: contentVersion_2.ContentDocumentId];
            
            System.assertEquals(cdl[0].ContentDocumentId, contentVersion_2.ContentDocumentId);   
        
            Test.stopTest();
        }

    }
    catch(Exception e){
        system.debug('Exception -->'+e.getMessage());
    }
}
    
}