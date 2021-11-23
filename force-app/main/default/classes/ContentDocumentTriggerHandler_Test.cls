@isTest
public class ContentDocumentTriggerHandler_Test {

  private static testMethod void testCreate() {
      
        try{
       Test.startTest();
    ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion_1;
    
    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      ContentDocumentTriggerHandler.GetContentDocumentLink(documents);
    System.assertEquals(documents.size(), 1);
      
    System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
    System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
    System.assertEquals(documents[0].Title, contentVersion_2.Title);
       Test.stopTest();
        }
        catch(Exception e){
             system.debug('Exception -->'+e.getMessage());
        }
  }
    
  private static testMethod void testCreate2() {
      
        try{
       Test.startTest();
    ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion_1;
    
    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
      ContentDocumentTriggerHandler.ContentDocumentLinkContractInvoke(documents);
      System.assertEquals(documents.size(), 1);
      
    System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
    System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
    System.assertEquals(documents[0].Title, contentVersion_2.Title);
       Test.stopTest();
        }
        catch(Exception e){
             system.debug('Exception -->'+e.getMessage());
        }
  }
  
  private static testMethod void testDeleteDocument() {
      
        try{
       Test.startTest();
    ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion_1;
    
    ContentDocument  cd = [SELECT LatestPublishedVersionId,IsDeleted FROM ContentDocument where LatestPublishedVersionId =: contentVersion_1.id];
    delete cd;
    System.assertEquals(cd.IsDeleted, false);
       Test.stopTest();
        }
        catch(Exception e){
             system.debug('Exception -->'+e.getMessage());
        }
  }
}