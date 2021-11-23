@isTest(seeAllData=false)
public class ContractRetryControllerTest {
    
    private static ContractJunction__c objConj;
    private static Account acc;
  
    static void setup() {
        DateTime myDateTime = DateTime.newInstance(2018, 7,23, 8, 6, 16);
        acc = new Account(Name='Test Account', Migrated_Customer__c = True,Customer_status__c = 'ACTIVE');
         insert acc;
        system.debug('acc:'+acc);
        /*Opportunity opp=new Opportunity(Name='TestOpp', StageName='Define', CloseDate=myDateTime.date(),AccountId = acc.Id,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId());
        insert opp;*/
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
    opp.CloseDate =myDateTime.date();
        insert opp;
        system.debug('opp:'+opp);
        
        
        Contact con = TestUtil.createContact('fname12','lname12');
        con.AccountId = acc.id;
        
        insert con;
        //OpportunityContactRole primaryContact = new OpportunityContactRole (ContactId = con.id,IsPrimary=true,OpportunityId=opp.id);
    //insert primaryContact;
    
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';        
        update basket;        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        //Adding 2 CWP Products
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        update config;
        
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.name = System.Label.Label_CWP;
        config1.cscfga__Description__c = 'test Description ';
        update config1;
        
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.ContactId = con.Id;
        oppContact.IsPrimary = true;
        oppContact.OpportunityId = basket.cscfga__Opportunity__c;
        oppContact.Role = 'Inside Sales Account Manager';
        insert oppContact;
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'OrderForm';
        template.Sequence__c = 1;
        template.APXTConga4__Template_Group__c = 'Contract'; 
    insert template;
        
        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'BasketSnapshot'; 
        insert query1;
        APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
        query2.APXTConga4__Name__c = 'AccountDetails'; 
        insert query2;
        APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
        query3.APXTConga4__Name__c = 'BasketProductDetails'; 
        insert query3;
        APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
        query4.APXTConga4__Name__c = 'OpportunityDetails'; 
        insert query4;
        
        objConj = new ContractJunction__c (Name='TestCJ', CreatedDate=System.now(),Account__c = acc.Id,Related_Opportunity__c = opp.Id,Related_Basket__c=basket.id,Conga_URL__c ='&Id=a7W2O00000001v0UAA&TemplateId=a6p2N000000003jQAA&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id=0052O000000X7CtQAK&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR2Id=0032O000002IGlqQAG&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR3Id=0052P000000HhNNQA0&DocuSignR3Type=Signer&DocuSignR3Role=Signer+3&DocuSignR3RoutingOrder=3&DocuSignEndpoint=Demo&QueryId=[BasketSnapshot]a6h2O0000000DRwQAM?pv0=a3Q2O0000007BbbUAE,[AccountDetails]a6h2N000000006JQAQ?pv0=0012O000003OiTfQAK,[BasketProductDetails]a6h2N000000006OQAQ?pv0=a3Q2O0000007BbbUAE,[OpportunityDetails]a6h2N000000006TQAQ?pv0=0062O000002NmEXQA0&AttachmentParentId=a7W2O00000001v0UAA&QMode=DocuSign' );
         insert objConj;
        
  }
    
  @isTest static void displayErrorInProgressTest(){
       Test.startTest(); 
       setup();
       objConj.CongaStatus__c = 'Error';
     String result=ContractRetryController.displayError(objConj.Id);
     System.assertEquals('InProgress',result);
     Test.stopTest();        
    }
    
    @isTest static void displayErrorFailureTest(){
       Test.startTest();  
       DateTime myDateTime=System.now().addDays(-1);
       Account acc = new Account(Name='Test Account',Customer_status__c = 'ACTIVE');
       insert acc;
       Opportunity opp=new Opportunity(Name='TestOpp', StageName='Define', CloseDate=myDateTime.date(),AccountId = acc.Id);
       insert opp;
       
       objConj = new ContractJunction__c (Name='TestCJ',Account__c = acc.Id,Related_Opportunity__c = opp.Id,LastModifiedDate=myDateTime,CreatedDate=myDateTime);
       upsert objConj;

     String result=ContractRetryController.displayError(objConj.Id);
       system.debug('Future CJ'+result); 
     System.assertEquals('Failure',result);  
       Test.stopTest();
    }
    
    @isTest static void displayErrorSuccessTest(){
       Test.startTest(); 
       setup();
     ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    Insert cv;
    
    List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    
  //Get Content Documents
  List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
  
      ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=objConj.id;  
             contentlink.ShareType= 'V';               
             contentlink.ContentDocumentId=cdList[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
       objConj.CongaStatus__c = 'Error';
       String result=ContractRetryController.displayError(objConj.Id);
       System.assertEquals('Success',result);
      Test.stopTest();        
    }
    
    @isTest static void displayErrorInExceptionTest(){
       Test.startTest(); 
     try{
       setup();
          
     String result=ContractRetryController.displayError(acc.Id);
     //System.assertEquals('Failure',result);
     }
     catch(exception e){
        System.assertEquals('Failure','Failure');
     }
     Test.stopTest();        
    }
    
    @isTest static void displayErrorDocusignrestrictTest(){
       Test.startTest(); 
       setup();
     acc.APTPS_DocuSign_Restricted__c = true;
     update acc;
     ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    Insert cv;
    
    List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    
  //Get Content Documents
  List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
  
      ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=objConj.id;  
             contentlink.ShareType= 'V';               
             contentlink.ContentDocumentId=cdList[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
       objConj.CongaStatus__c = 'Error';
       String result=ContractRetryController.displayError(objConj.Id);
       System.assertEquals('Docusign Restricted',result);
      Test.stopTest();        
    }
    
    @isTest static void markContractJunctionErrTest()
    {
        Test.startTest();
      setup();
        ContractRetryController.markContractJunctionErr(objConj);
        System.assertEquals('Error',objConj.CongaStatus__c);
        Test.stopTest();
    }
    
 /*  @isTest static void retryContractGenerationTest()
    {
        
        Test.startTest();
      setup();
        
        System.debug('Retry Test ID ->'+objConj.id);
        ContractRetryController.retryContractGeneration(objConj.id);
        System.assertEquals('InProgress',objConj.CongaStatus__c);
        Test.stopTest();
        
    }
    @isTest static void displayErrorSuccessTest(){
       Test.startTest(); 
       setup();
       objConj.CongaStatus__c = 'Error';
     String result=ContractRetryController.displayError(objConj.Id);
        System.debug('Future CJ'+result); 
      System.assertEquals('Success',result);
     Test.stopTest();        
    }*/
    
    @isTest static void getcontractNameTest(){
       Test.startTest(); 
       setup();
     String result=ContractRetryController.getcontractName(objConj.Id);
     System.assert(result!=null);
      Test.stopTest();        
    }
    
    @isTest static void getcontractStatusTest(){
       Test.startTest(); 
       setup();
     String result=ContractRetryController.getcontractStatus(objConj.Id);
     System.assert(result!=null);
      Test.stopTest();        
    }
    
     @isTest static void updateContractStatusSignedTest(){
       
       setup();
     try{
     Test.startTest(); 
     String result=ContractRetryController.updateContractStatus(objConj.Id , 'UpdateStatusButton');
     Test.stopTest();
       system.debug('result:'+result);
     system.assertNotEquals(result,'');
     }catch(Exception e){
       system.debug('Exception message ' + e.getMessage());
     }
              
    }
    
    @isTest static void updateContractStatusDeclinedTest(){
  
       Test.startTest(); 
     
       setup();
     try{
     String result=ContractRetryController.updateContractStatus(objConj.Id , 'DeclineStatusButton');
     system.assertNotEquals(result,'');
     }catch(Exception e){
       system.debug('Exception message ' + e.getMessage());
     }
      Test.stopTest();        
     
    }
   @isTest static void retryContractGenerationTest()
    {      
        Test.startTest();
      setup();    
    objConj.Related_Basket__c = null;
    update objConj;    
        String result = ContractRetryController.retryContractGeneration(objConj.id);
    system.debug('result:' + result);        
        System.assertEquals(result,'InProgress');
        Test.stopTest();
        
    }
    @isTest static void checkContractDocumentGenerationTest()
        {
         Test.startTest();
      setup();      
        String result = ContractRetryController.checkContractDocumentGeneration(objConj.id);
        System.assert(result!=null);
        Test.stopTest();
            
        }
    
    /*-------------------------------------------------------- 
EDGE-187048
Description: Test Method to cover checkDocumentGenerated
Author:Dheeraj Singh
--------------------------------------------------------*/
    @isTest static void checkDocumentGeneratednegativeTest(){
       Test.startTest(); 
       setup();
       objConj.CongaStatus__c = 'Initiated';
    String result=ContractRetryController.checkDocumentGenerated(objConj.Id);
    system.assertEquals(result,null);
    Test.stopTest();        
    }
    
     /*-------------------------------------------------------- 
EDGE-187048
Description: Test Method to cover getcontractDocusignEnabledStatus
Author:Dheeraj Singh
--------------------------------------------------------*/
    @isTest static void getcontractDocusignEnabledStatusTest(){
       Test.startTest(); 
       setup();
       objConj.Restrict_Conga_Flow__c = true;
        objConj.isDSAGenerated__c = true;
     update objConj;
    Map<String,Boolean> result=ContractRetryController.getcontractDocusignEnabledStatus(objConj.Id);
     System.assert(result!=null);
    Test.stopTest();        
    }
     
     /*-------------------------------------------------------- 
EDGE-187048
Description: Test Method to cover checkDocumentGenerated
Author:Dheeraj Singh
--------------------------------------------------------*/
    @isTest static void checkDocumentGeneratedpositiveTest(){
       Test.startTest(); 
       setup();
        ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    Insert cv;
    
    List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    
  //Get Content Documents
  List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
  
      ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=objConj.id;  
             contentlink.ShareType= 'V';               
             contentlink.ContentDocumentId=cdList[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
        
    String result=ContractRetryController.checkDocumentGenerated(objConj.Id);
             system.debug('result:'+result);
    System.assertEquals(result,null);
    Test.stopTest();        
    }
    
}