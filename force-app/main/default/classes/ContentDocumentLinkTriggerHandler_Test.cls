/****************************************************************************
@Name: ContentDocumentLinkTriggerHandler.
@Author: Shaik Mahaboob Subani.
@CreateDate: 15/11/2017.
@Description: This is Test Class for ContentDocumentLinkTriggerHandler
@Modified by : Vamshi (Napier Team) as part of EDGE-135560..
* Ankush Rana      25/06/2021  EDGE-220767 Added this Comment to pick this test class for Bamboo deployment
********************************************************************************/

@isTest
public class ContentDocumentLinkTriggerHandler_Test {
    
    @istest
    Private static  void updateTest(){
        Test.startTest();
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        // creating Account Record
        Account acc = new Account(
            name='Test',
            Customer_status__c = 'ACTIVE',
            RecordTypeId=devRecordTypeId1
        );
        insert acc;
        // Creating Opportunity Reocrd
        Opportunity sobj = new Opportunity(
            AccountId=acc.Id,
            name = 'testing', 
            Amount=2000.0, 
            Product_Domain__c='MOBILES',    
            Confidence_Level__c='Low probability', 
            ForecastCategoryName='Omitted',                                       
            Billing_Solution__c='Standard', 
            Pricing_Method__c='Off the Shelf', 
            CloseDate = system.today()+1,                       
            StageName = 'Prospecting', 
            Requires_Bid_Management__c='Yes',                                 
            Probability = 10,
            Proposal_Required_Date__c=System.today(),
            Description = 'testSuccess',
            RecordTypeId=devRecordTypeId);
        insert sobj;
        
        case caseDetails=OneFundRetrospectiveRedemptionTest.inserttestcase();
        
        // Creating contentVersion Record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion; 
        
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = sobj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl; 
        system.assertEquals( 'Penguins',contentVersion.Title);
        list<ContentDocumentLink> contenttdocumentlinklist = new list<ContentDocumentLink>();
        contenttdocumentlinklist.add(cdl);
        ContentDocumentLinkTriggerHandler.modifiedDateUpdate(contenttdocumentlinklist,'Attachcountdelete');
        
        Test.stopTest();  
        
    }
    @istest
    //To cover the catch block
    Private static  void updateTestExceptioncover(){
        try{
            
            list<ContentDocumentLink> contentList =null;
            ContentDocumentLinkTriggerHandler.modifiedDateUpdate(contentList,'AttachDate');
            ContentDocumentLinkTriggerHandler.modifiedDateUpdate(contentList,'Attachcountdelete');
            ContentDocumentLinkTriggerHandler.modifiedDateUpdate(contentList,'Attachcountinsert');
            System.assertEquals(contentList, null); 
        }
        catch(Exception e){
            system.debug('Exception -->'+e.getMessage());
        }
        
    }
    
    @istest
    Private static  void OwnerUpdateTest(){     
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(thisUser){
        Test.startTest();
        
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId(); 
        Account acc = new Account();
        acc.name = 'TestClassEvent';
        acc.CIDN__c = 'ASDF1234';
        acc.RecordTypeId = accRecordTypeId;
        acc.Migrated_Customer__c = true;
        acc.Customer_status__c = 'ACTIVE'; 
        insert acc;
        
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
        opp.recordTypeId=oppRecordTypeId;
        opp.Name='TestOppCreateForEventCreate';
        opp.CloseDate=System.today()+10;
        opp.Proposal_Required_Date__c= system.today()+2;
        opp.StageName='Qualify';
        insert opp; 
        System.assertEquals(opp.Name, 'TestOppCreateForEventCreate'); 
        
        
        User bidUser = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        bidUser.phone='+121231231234';
            insert bidUser;
        
        id bidRecordTypeId = Schema.SObjectType.Bid__c.getRecordTypeInfosByName().get('SBC – GE').getRecordTypeId();
        Bid__c bidRec = new Bid__c();
        bidRec.Opportunity__c  = opp.id;
        bidRec.Current_ORB_Generated_User__c  = bidUser.id;        
        bidRec.recordTypeId = bidRecordTypeId;
        insert bidRec;
        system.debug('bidRec ID' +bidRec);
        
        Id CALMSProfileID= [select Id from Profile where Name  ='CALMS Integration User'].Id;
        User u12 = new User(alias = 'CALMST', email='conf3@noemail.com',
                            emailencodingkey='UTF-8', lastname='CALMSTest', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = CALMSProfileID, country='United States',IsActive =true,
                            
                            timezonesidkey='America/Los_Angeles', username='CALMSTest@noemail.com');
        insert u12;
        
        Phoenix_Configurations__c pc = new Phoenix_Configurations__c();
        pc.Bid_ID__c  =  string.valueOf(bidRec.id).substring(0,3); 
        pc.CALMS_Int_User_ID__c = u12.Id; 
        insert pc;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Opportunity_Review_Brief_',
            PathOnClient = 'Opportunity_Review_Brief_.doc',
            VersionData = Blob.valueOf('Test Content'),            
            IsMajorVersion = true);
        insert contentVersion; 
        System.assertEquals(contentVersion.Title, 'Opportunity_Review_Brief_'); 
        
        contentVersion.OwnerId = u12.Id;
        update contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];                
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = bidRec.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;         
        
        
        list<ContentDocumentLink> contenttdocumentlinklist = new list<ContentDocumentLink>();
        contenttdocumentlinklist.add(cdl);
        
        ContentDocumentLinkTriggerHandler.ownerUpdate(contenttdocumentlinklist);
        ContentDocumentLinkTriggerHandler.attachmentCountUpdate(contenttdocumentlinklist, 'Attachcountinsert');    
        ContentDocumentLinkTriggerHandler.attachmentCountUpdate(contenttdocumentlinklist, 'Attachcountdelete');   
        
      }        
        Test.stopTest();  
    }
    
/*
* @Method Name : attachmentCountTest
* @Parameters  : list<ContentDocumentLink> newList , UpdOrDelOrIns
* @Description : When new file/Files are added to Case,count the attachments on a given case.
* @Developer : Vamshi (Napier Team) Added as part of EDGE-135560.
*/    
        
    @istest
    Private static  void attachmentCountTest(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(thisUser){
            Test.startTest();
            case caseDetails=OneFundRetrospectiveRedemptionTest.inserttestcase();
            
            ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Opportunity_Review_Brief_.doc',
            VersionData = Blob.valueOf('Test Content'),            
            IsMajorVersion = true);
            insert contentVersion; 
            System.assertEquals(contentVersion.Title, 'Test'); 
        
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];                
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = caseDetails.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;         
            
            list<ContentDocumentLink> contenttdocumentlinklist = new list<ContentDocumentLink>();
            contenttdocumentlinklist.add(cdl);
            
            ContentDocumentLinkTriggerHandler.attachmentCountUpdate(contenttdocumentlinklist, 'Attachcountinsert');    
            ContentDocumentLinkTriggerHandler.attachmentCountUpdate(contenttdocumentlinklist, 'Attachcountdelete'); 
            
        
        Test.stopTest();  
            Case caseRec=[select id,Attachment_Count__c from Case where Id =: caseDetails.id];
            system.assertEquals(caseRec.Attachment_Count__c, 0);
            system.assertNotEquals(caseRec.Attachment_Count__c, null);
        }
       
    }
    /*----------------------------------------------------------------
Method : modifyCAVisibilityTest
Author: Kalashree Borgaonkar
Story: EDGE-140813 
-------------------------------------------------------------------------------------*/
    @istest
    Private static  void modifyCAVisibilityTest(){      
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        insert custAuthForm;
        Customer_Authority_Form__c custId = [SELECT id FROM Customer_Authority_Form__c WHERE opportunity__c = :opp.id];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = custId.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'I';
        insert cdl; 
        System.assertEquals(cdl!=null, true, 'Link created');
    }
 /**********************************************************************************************
Method : SkipDocuSign
Author: Manuga Kale
Story:  EDGE-169277 

 **********************************************************************************************/

   @istest
    Private static  void SkipDocuSign(){  
    
    list<id> conList = new List<id>();
    Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
    Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
     
     Account acc = new Account(
            name='Test',
            Customer_status__c = 'ACTIVE',
            RecordTypeId=devRecordTypeId1
        );
        insert acc;
        
        // Creating Opportunity Reocrd
        Opportunity sobj = new Opportunity(
            AccountId=acc.Id,
            name = 'ContractJunction__c', 
            Amount=2000.0, 
            Product_Domain__c='MOBILES',    
            Confidence_Level__c='Low probability', 
            ForecastCategoryName='Omitted',                                       
            Billing_Solution__c='Standard', 
            Pricing_Method__c='Off the Shelf', 
            CloseDate = system.today()+1,                       
            StageName = 'Prospecting', 
            Requires_Bid_Management__c='Yes',                                 
            Probability = 10,
            Proposal_Required_Date__c=System.today(),
            Description = 'testSuccess',
            RecordTypeId=devRecordTypeId);
        insert sobj;
        
        List<ContentDocumentLink> ConDocLink = new List<ContentDocumentLink>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = sobj.id;
        basket.Name = 'basket1';
        insert basket;
        
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        insert oldContract;
                              
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Order Form',
        PathOnClient = 'Order Form.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
        insert contentVersion;
        
         List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];    
        ContentDocumentLink cJ = new ContentDocumentLink();
        cJ.LinkedEntityId = oldContract.Id;        
        cJ.ContentDocumentId = documents1[0].Id;
        cJ.shareType = 'V';
        insert cJ; 
            
        ConDocLink.add(cJ);
        Map<id,set<id>> ConMap = new Map<id,set<id>>();        
        String cd = String.valueOf(cJ.LinkedEntityId);
        Id link = cJ.LinkedEntityId;
             
        set<id> ids = new set<id>();
        ids.add(cJ.ContentDocumentId);
       
        ConMap.put(cJ.LinkedEntityId,ids);     
        conList.add(cJ.LinkedEntityId);
  
        Schema.SObjectType sobjectType = link.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
       
       ContractJunction__c cObject = [select Id,name,isOrderFormGenerated__c from ContractJunction__c where Id =: oldContract.id];
       System.assertEquals(cObject.isOrderFormGenerated__c, true );

      
        }
    

}