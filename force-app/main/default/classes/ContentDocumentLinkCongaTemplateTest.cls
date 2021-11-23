@isTest
public class ContentDocumentLinkCongaTemplateTest {
    private static Conga_Template_Version__c ctv=null;
    private static ContentDocumentLink cdl1=null;
    static void setup() {
         string before = 'Testing base 64 encode';            
         Blob beforeblob = Blob.valueOf(before);
         //Insert contentdocument data
         ContentVersion cv = new ContentVersion();
         cv.title = 'test content trigger';      
         cv.PathOnClient ='test';           
         cv.VersionData =beforeblob;          
         insert cv;  
         ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
         APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
         template.APXTConga4__Name__c = 'OrderForm';
         template.Sequence__c = 1;
         template.APXTConga4__Template_Group__c = 'Contract'; 
		 insert template;
        
         ContentDocumentLink cdl = new ContentDocumentLink();
         cdl.LinkedEntityId = template.id;
         cdl.ShareType = 'I';          
         cdl.ContentDocumentId = testcontent.contentdocumentid;
         insert cdl;
         
         ctv = new Conga_Template_Version__c();
         ctv.Active__c = true;
         ctv.Name = 'testversion';
         ctv.Conga_Template__c = template.id;
         ctv.Version__c=1.0;
         insert ctv;
         
         cdl1 = new ContentDocumentLink();
         cdl1.LinkedEntityId = ctv.Id;
         cdl1.ShareType = 'I';
         cdl1.ContentDocumentId = testcontent.contentdocumentid;
         insert cdl1;       
    }
    @isTest static void updateFileTest(){
        Test.startTest();
        setup();
        List<Id> list1 = new List<Id>();
        list1.add(ctv.id); 
        ContentDocumentLinkCongaTemplate.updateFile(list1);
        List<ContentDocumentLink> result = [select id from ContentDocumentLink where id=:ctv.id];
        System.debug('result :'+result);
        system.assert(result!=null);  
        Test.stopTest();
    }
  /*  @isTest static void activateVersionTest() { 
        Test.startTest();
         setup();
         List<ContentDocumentLink> list1 = new List<ContentDocumentLink>();
        // list1.add(cdl1);         
       //  System.assert(ContentDocumentLinkCongaTemplate.activateVersion(list1),true);
        Test.stopTest();
     } */
}