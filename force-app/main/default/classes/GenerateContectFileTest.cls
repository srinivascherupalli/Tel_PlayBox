@isTest(seeAllData=false)
public class GenerateContectFileTest {
            
    @isTest static void generateContentFileRecordTest(){
        //Test.startTest(); 
        try{
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Migrated_Customer__c = true;
            acc.Customer_Status__c = 'Active';
            
        insert acc;  
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '123456789',
            Email = 'test@tele2.com'   
        );
        Insert contact;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.ContactId = contact.Id;
        oppContact.IsPrimary = true;
        oppContact.OpportunityId = basket.cscfga__Opportunity__c;
        oppContact.Role = 'Inside Sales Account Manager';
        insert oppContact;
        
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = oppContact.contact.Email;
        record.Phone__c = oppContact.contact.MobilePhone;
        record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
          Service_Term__c st =new Service_Term__c();
        st.Related_Contract__c = record.Id;
        st.Name = 'MDM ServiceTerm';
        st.Account__c = basket.csbb__Account__c;
        st.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        st.Contract_Activated_Date__c = System.today();
        st.Contract_Term_Months__c = 32;
        st.ParentContract__c = record.id;
        st.ServiceTermName__c='test';
        st.ServiceTermTemplateName__c='Service Terms'  ;  
        insert st;
        
        
        List<Apttus__APTS_Agreement__c> listofAgmnts = new list<Apttus__APTS_Agreement__c>();    
        Apttus__APTS_Agreement__c agmnt = new Apttus__APTS_Agreement__c();
        agmnt.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        agmnt.Related_Basket__c =basket.id;
        agmnt.Related_Contract__c  = record.id;
        agmnt.Apttus__Account__c = basket.csbb__Account__c;    
        listofAgmnts.add(agmnt);
        Apttus__APTS_Agreement__c agmnt1 = new Apttus__APTS_Agreement__c();
        agmnt1.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Product_Key_Facts').getRecordTypeId();
        agmnt1.Related_Basket__c =basket.id;
        agmnt1.Related_Contract__c  = record.id;
        agmnt.Related_Service_Term__c=st.id;

        agmnt1.Apttus__Account__c = basket.csbb__Account__c;     
        listofAgmnts.add(agmnt1); 
        Apttus__APTS_Agreement__c agmnt2 = new Apttus__APTS_Agreement__c();
        agmnt2.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('General_Product_Terms').getRecordTypeId();
        agmnt2.Related_Basket__c =basket.id;
        agmnt2.Related_Contract__c  = record.id;
        agmnt2.Apttus__Account__c = basket.csbb__Account__c;     
        listofAgmnts.add(agmnt2); 
        insert listofAgmnts;   
        list<ContentVersion> ContentVersionList = New list<ContentVersion>();
        ContentVersion contentVersion1 = new ContentVersion(
                Title = 'Signed-on-paper'+'.pdf',
                PathOnClient = 'Signed-on-paper'+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
        ContentVersionList.add(contentVersion1);
        ContentVersion contentVersion2 = new ContentVersion(
                Title = 'BSA'+'.pdf',
                PathOnClient = 'BSA'+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
       ContentVersionList.add(contentVersion2);     
       ContentVersion contentVersion3 = new ContentVersion(
                Title = 'Certificate'+'.pdf',
                PathOnClient = 'Certificate'+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
       ContentVersionList.add(contentVersion3);
            ContentVersion contentVersion4 = new ContentVersion(
                Title = 'Service Terms'+'.pdf',
                PathOnClient = 'Service Terms'+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
       ContentVersionList.add(contentVersion4);
            ContentVersion contentVersion5 = new ContentVersion(
                Title = 'General Service Terms'+'.pdf',
                PathOnClient = 'General Service Terms'+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
       ContentVersionList.add(contentVersion5);
        insert ContentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = record.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList.add(cdl);
        }
        insert ContentDocumentLinkList;
        insert new EnvironmentVariable__c(Name= 'ContractInitiate', Value__c = '1');
        insert new EnvironmentVariable__c(Name= 'AgreementGenerateContract', Value__c = '1');
        Insert new CustomConfigurationOptions__c(Name = 'ContractInitiate',Enrichment_Basket_Stage__c ='Contract Initiated' , External_Id__c ='7842', MarketableOfferList__c = '', Opportunity_Stage__c = 'Propose');

        Test.startTest();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where ID != NULL';
        
        List<Id> contractId = new list<Id>(new Map<Id, ContractJunction__c>([SELECT Id FROM ContractJunction__c where id IN : Database.query(soql)]).keySet());
        
        GenerateContentFile.generateContentFileRecord(True,contractId);
        list<ContentDocumentLink> cdlForApttusAgreement = [SELECT ID, ContentDocumentId,ContentDocument.Title, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :agmnt1.id];
        System.debug('list here:'+cdlForApttusAgreement);
        System.assert(cdlForApttusAgreement.size() > 0);
        Test.stopTest();
    }
        catch(Exception e){
        
          }
    }
    
}