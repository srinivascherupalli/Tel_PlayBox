/****************************************************************************
@Name: serviceTermAttachmentPRM.
@Author: Abinas Panda.
@CreateDate: 08/08/2019.
@Description: This is a helper class for ContentDocumentLink object trigger for Updating the file location of service Terms
EDGE-88882

* 11th Oct 2021 : Vivian : DIGI-29138 : Fixing mobilephone format as per SFO's DIGI-4056
********************************************************************************/

@isTest
public class serviceTermAttachmentPRMTest {
    @isTest
    static void testserviceTerm(){
      
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'Contract - Service Terms(MDM)';
        template.Type__c = 'Service Terms';
        template.APXTConga4__Template_Group__c ='Contract' ;
        insert template;
        
        Account acc = new Account() ;
        acc.name = 'Test Account';
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Account_Status__c = 'Active';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;  
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+61123456789',
            Email = 'test@tele2.com'   
        );
        Insert contact;
        Contact contact2 = new Contact(
            AccountId = acc.id,
            LastName = 'Last1',
            FirstName = 'First1',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+61123456789',
            Email = 'test0@tele2.com'   
        );
        Insert contact2;
        //CREATE OPPORTUNITY
        Opportunity opp  = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
        opp.StageName = 'Committed';
        opp.CloseDate = System.today();
        opp.Description = 'test';
        opp.Description__c = 'abc';
        opp.amount = 4600;
        insert opp;
        
        //Test.stopTest();
        
        Test.startTest();
        ContractJunction__c cntrjunObj = new ContractJunction__c(Name='TEST_CONTRACT',Related_Opportunity__c = opp.Id);
        insert cntrjunObj;
        //  Test.startTest();
        Service_Term__c st =new Service_Term__c();
        st.Related_Contract__c = cntrjunObj.Id;
        st.Name = 'MDM ServiceTerm';
        st.ServiceTermTemplateName__c = 'Contract - Service Terms(MDM)';
        st.Account__c = acc.Id;
        st.Related_Opportunity__c = opp.Id;
        st.Contract_Activated_Date__c = System.today();
        st.Contract_Term_Months__c = 32;
        st.ParentContract__c = cntrjunObj.id;
        insert st;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Contract - Service Terms(MDM) - a7Wss',
            PathOnClient = 'Contract - Service Terms(MDM) - a7Wss.docx',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.assertNotEquals(0, documents.size());//EDGE-141830 - Negative Assert 
        //create ContentDocumentLink  record 
        List<ContentDocumentLink> clList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cntrjunObj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        clList.add(cdl);
        insert clList;
        //EDGE-119211 - update service term document name & check assert
        List<ContentDocument> lstcd = new List<ContentDocument>();
        for(ContentDocumentLink cd1:clList)
        {
            ContentDocument cd = new ContentDocument();
            cd.id = cd1.ContentDocumentId;
            cd.Title = 'Service Term Test';
            lstcd.add(cd);
        }
        update(lstcd);        
        serviceTermAttachmentPRM.attchSTAssign(clList);
        //EDGE-119211 - Check assert for file name updates
        system.assertEquals('Service Term Test',lstcd[0].Title);
        //INC000092543961 fix
        ContentDocumentLink[] cd = [Select Id,contentDocument.Title,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:cntrjunObj.Id AND contentDocument.Title LIKE 'Service Term -%'];
        system.assertEquals(cd.size()==0,true);//EDGE-141830 - Assert to check all files deleted from parent contract.
        test.stopTest();
    }
}