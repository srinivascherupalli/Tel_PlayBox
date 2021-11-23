/*****************************************************************
@Name: APTPS_TestClassData 
@Author: Ruchika Patil 
@CreateDate: 30/05/2016 
@Description: This class creates all the data for Test classes.
@UsedBy: All Test Classes
@LastModified:	Modified by Sri, team SFO on 16/01/2020 
				P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  
******************************************************************/ 
@isTest
public class APTPS_TestClassData {
    /******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    public static Account accountRecord(String accName, string cidn){
		//Modified by Sri, team SFO on 16/01/2020
		//P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
        Account acc = new Account(Name = accName,Imported__c = true, Type = 'Customer', ABN__c = '1234', CIDN__c = cidn,Pref_Comm_Method__c='Phone', Phone='0400000000',Customer_Status__c='ACTIVE');
        insert acc;
        system.assertNotEquals(null, acc.Id);
        return acc;
    }

    public static Account accountParent(String accName, string cidn, Id parentAcc){
        Account acc = new Account(Name = accName,Type = 'Customer', ABN__c = '12345', CIDN__c = cidn, Parentid = parentAcc,Pref_Comm_Method__c='Phone', Phone='0400000001',Customer_Status__c='ACTIVE');
        
        insert acc;
        system.assertNotEquals(null, acc.Id);
        return acc;
    }
    /******************************************************************
    @Description:This method creates a single Contact record.
    *******************************************************************/ 
    public static Contact contactRecord(Id AccId){
        String EmailString = 'testing_'+generateRandomString(8)+'@testing.com';
        Contact contactRec = new Contact(FirstName = 'Test'+ generateRandomString(8), LastName = 'Contact'+generateRandomString(8), AccountId = AccId, Email = EmailString);
        contactRec.Birthdate=Date.newInstance(2000, 2,18);
        contactRec.Salutation='Mr.';
        contactRec.APTPS_Role__c = 'Primary Contact';
        insert contactRec;
        system.assertNotEquals(null, contactRec.Id);
        return contactRec;
    }
        /******************************************************************
    @Description:This method creates a single Contact record.
    *******************************************************************/ 
    public static Contact contactRecord(String firstName, String lastName, Id AccId){
        String EmailString = firstName+lastName+'_'+generateRandomString(8)+'@testing.com';
        Contact contactRec = new Contact(FirstName = firstName, LastName = lastName, AccountId = AccId, Email = EmailString);
        contactRec.Birthdate=Date.newInstance(2000, 2,18);
        contactRec.Salutation='Mr.';
        contactRec.APTPS_Role__c = 'Primary Contact';
        insert contactRec;
        system.assertNotEquals(null, contactRec.Id);
        return contactRec;
    }
    /******************************************************************
    @Description:This method creates a single Agreement record.
    *******************************************************************/ 
    public static Apttus__APTS_Agreement__c agreementRecord(Id AccountId){
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId);
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    } 
    public static Apttus__APTS_Agreement__c agreementParent(Id AccountId, Id ParentAgreementId){
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, Apttus__Parent_Agreement__c = ParentAgreementId);
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    }
    /******************************************************************
    @Description:This method creates a single Agreement record with record type.
    *******************************************************************/ 
    public static Apttus__APTS_Agreement__c agreementWRecordType(Id AccountId,String recordTypeName){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID);
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    }
    
    /******************************************************************
    @Description:This method creates a single Agreement record with record type.
    *******************************************************************/ 
    public static List<Apttus__APTS_Agreement__c> createNumberOfAgreement(Id AccountId,String recordTypeName, Integer numberOfAgreement){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        for(Integer i=0;i<numberOfAgreement;i++){
            Apttus__APTS_Agreement__c agreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID);
            agreementList.add(agreementRecord);
        }
        insert agreementList;
        for(Integer i=0;i<numberOfAgreement;i++){
        	Apttus__AgreementLineItem__c agreementLineItem = new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = agreementList[i].Id, Apttus__ProductId__c = null);
            agreementLineItemList.add(agreementLineItem);
        }
        
        insert agreementLineItemList;
        System.assertEquals(false, agreementList.isEmpty());
        System.assertEquals(false, agreementLineItemList.isEmpty());
        return agreementList;
    }
    
    public static Apttus__APTS_Agreement__c agreementWContact(Id AccountId,String recordTypeName, id contactId){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID, APTPS_Customer_Primary_Contact__c = contactId,APTPS_Telstra_Legal_Entity__c = 'Victoria');
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    }
    
    public static Apttus__APTS_Agreement__c agreementNDAWContact(Id AccountId, id contactId, id secAccountId, id secContactId){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID, APTPS_Customer_Primary_Contact__c = contactId,APTPS_Telstra_Legal_Entity__c = 'Victoria',
                                                                                    APTPS_Secondary_Account__c = secAccountId, APTPS_SecAcnt_Primary_Contact__c = secContactId, APTPS_Jurisdiction__c = 'NSW', Apttus__Agreement_Category__c = 'Multi-Party');
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    }
    
    public static Apttus__APTS_Agreement__c agreementSupporting(Id AccountId, id contactId, string categoryName){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Supporting Agreement').getRecordTypeId();
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID, APTPS_Customer_Primary_Contact__c = contactId,APTPS_Telstra_Legal_Entity__c = 'Victoria',
                                                                                     Apttus__Agreement_Category__c = categoryName);
        insert AgreementRecord;
        system.assertNotEquals(null, AgreementRecord.Id);
        return AgreementRecord;
    }
    
    public static Apttus__APTS_Agreement__c agreementWRecordTypeAndSubtype(Id AccountId, String recordTypeName, 
                                                                           string category, string subCategory, string subtype){
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Apttus__APTS_Agreement__c agreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = AccountId, RecordTypeId =recordtypeID);
        agreementRecord.Apttus__Agreement_Category__c = category;
        agreementRecord.APTPS_Agreement_Subcategory__c = subCategory;
        agreementRecord.Apttus__Subtype__c = subtype;
        insert AgreementRecord;
        system.assertNotEquals(null, agreementRecord.Id);
        return AgreementRecord;
    }
    
    public static Apttus__AgreementLineItem__c agreementLineItemRecord(Id scheduleId, Id productId)
    {
        Apttus__AgreementLineItem__c agreementLineItem = new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = scheduleId, Apttus__ProductId__c = productId);
       
        insert agreementLineItem;
        system.assertNotEquals(null, agreementLineItem.Id);
        return agreementLineItem;
    }
    
    /******************************************************************
    @Description:This method creates a single Product record.
    *******************************************************************/ 
    public static Product2 productRecord(string prodName)
    {
        Product2 productRecord = new Product2(Name = prodName, Description = 'test', Family = 'test');
       
        insert productRecord;
        system.assertNotEquals(null, productRecord.Id);
        return productRecord;
    }
    /******************************************************************
    @Description:This method creates a single Related Companies record.
    *******************************************************************/ 
    public static APTPS_Related_Companies__c relatedCompaniesRecord(Id accountId, Id agreementId){
        APTPS_Related_Companies__c rcRecord = new APTPS_Related_Companies__c(APTPS_Account__c = accountId, APTPS_Agreement__c = agreementId);
        insert rcRecord;
        system.assertNotEquals(null, rcRecord.Id);
        return rcRecord;
    }
    /******************************************************************
    @Description:This method created a single User record.
    *******************************************************************/ 
    public static User userRecord(Id profileId, string usName){
        
        User objUser = new User(Alias = 'TestUSA', Email='testUserSA@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='UserSA', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_AU', ProfileId = profileId, CommunityNickname = 'TUSA',
                                TimeZoneSidKey='Australia/Sydney', UserName= usName+'test@testorg.com.japan');
        insert objUser ;
        system.assertNotEquals(null, objUser.Id);
        return objUser ;
    }
    /******************************************************************
    @Description:This method creates a single Related Companies Wrapper record.
    *******************************************************************/ 
    public static APTPS_RelatedCompaniesWrapper wrapperRecord(Boolean selected, Account acc){
        APTPS_RelatedCompaniesWrapper wrapper = new APTPS_RelatedCompaniesWrapper(acc);
        wrapper.isSelected = selected;
        system.assertNotEquals(null, acc.id);
        return wrapper;
    }
    /******************************************************************
    @Description:This method creates a single Task record.
    *******************************************************************/ 
    public static Task taskRecord(Id userId, Id objectId, string taskStatus){
        Task taskRec = new Task(OwnerId = userId, Subject = 'Task created for Test Class', WhatId = objectId, 
                                Status = taskStatus, Priority = 'Normal');
        insert taskRec;
        system.assertNotEquals(null, taskRec.Id);
        return taskRec;
    }
    /******************************************************************
    @Description:This method creates a single Template record.
    *******************************************************************/ 
    public static Apttus__APTS_Template__c templateRecord(String name, String type){
        Apttus__APTS_Template__c templateRec = new Apttus__APTS_Template__c(Name = name, Apttus__Type__c = type, Apttus__Agreement_Types__c = 'SA',
                                                                        Apttus__Category__c = 'Default', Apttus__Subcategory__c = 'Default', Apttus__IsActive__c = true,
                                                                        Apttus__Language__c  = 'English', Apttus__Locale__c = 'English (United Kingdom)',                                                                           
                                                                        Apttus__Mergefields2__c = 'Apttus__APTS_Agreement__c (Name);');
        insert templateRec;
        system.assertNotEquals(null, templateRec.Id);
        return templateRec;
    }
    /******************************************************************
    @Description:This method creates a single Template Obligation record.
    *******************************************************************/ 
    public static APTPS_Template_Obligations__c templateObligationRecord(String name, Id templateId){
        APTPS_Template_Obligations__c templateObligation = new APTPS_Template_Obligations__c(Name = name, APTPS_SRM_Active__c = true, APTPS_Template__c = templateId,
                                                                                APTPS_Obligation_Type__c = 'Primary', APTPS_Obligation_Frequency__c = 'Monthly',
                                                                                APTPS_Sub_Category__c = 'Required Consents', APTPS_Category__c = 'Contract Details',
                                                                                APTPS_Guidance__c = 'test Guidance', APTPS_Comments__c = 'test',
                                                                                APTPS_Accountable1__c = 'Contract Manager', APTPS_Consulted__c = 'Legal');
        insert templateObligation;
        system.assertNotEquals(null, templateObligation.Id);
        return templateObligation;
    }
    /******************************************************************
    @Description:This method creates a single Agreement Clause record.
    *******************************************************************/ 
    public static Apttus__Agreement_Clause__c agreementClauseRecord(Id agmtId, Id templateId){
        Apttus__Agreement_Clause__c agmtClause = new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause', Apttus__Agreement__c = agmtId,
                                                                        Apttus__Template__c = templateId, Apttus__Active__c = true, Apttus__Category__c = 'default',
                                                                        Apttus__Subcategory__c = 'Default', Apttus__Action__c = 'Inserted', Apttus__Text__c = 'test');
        insert agmtClause;
        system.assertNotEquals(null, agmtClause.Id);
        return agmtClause;
    }
    /******************************************************************
    @Description:This creates a single Template Obligation record.
    *******************************************************************/ 
    public static Apttus_SRM__SRMObligation__c obligationRecord(Id agmtId, Id accountId){
        Apttus_SRM__SRMObligation__c obligationRecord = new Apttus_SRM__SRMObligation__c(Apttus_SRM__AgreementId__c = agmtId, APTPS_Customer__c = accountId,
                                                                        APTPS_Auto_Obligation__c = true, Apttus_SRM__Responsible__c = 'test', APTPS_Status__c = 'Pending',
                                                                        APTPS_Category__c = 'Audit',APTPS_Sub_Category__c='Inspection and Audit of Records',APTPS_Responsible__c='Customer',APTPS_Obligation_Frequency__c='Once-off',APTPS_Approval_Required__c='No Approval Required',
                                                                        APTPS_Due_Date__c = date.today(),APTPS_Clause_Name__c='test', Apttus_SRM__Accountable__c = 'test', Apttus_SRM__Active__c = true);
        insert obligationRecord;
        system.assertNotEquals(null, obligationRecord.Id);
        return obligationRecord;
    }
    /******************************************************************
    @Description:This method creates a single Attachment record.
    *******************************************************************/ 
    public static Attachment attachmentRecord(string attachName, Id parentId){
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        Attachment attachmentDoc = new Attachment(Name = attachName, body = bodyBlob,
                                                    parentId = parentId);
        insert attachmentDoc;
        system.assertNotEquals(null, attachmentDoc.Id);
        return attachmentDoc;
    }
    /******************************************************************
    @Description:This method creates a single File record.
    *******************************************************************/ 
    //Added by Romil Modified for EDGE-85856 
    public static ContentDocumentLink FileRecord(string attachName, Id parentId){
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentver = new ContentVersion(Title = attachName, VersionData = bodyBlob, PathOnClient= 'test');
        insert contentver;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentver.Id].ContentDocumentId;
        ContentDocumentLink contentdoclink= new ContentDocumentLink(ContentDocumentId=conDoc, LinkedEntityId=parentId , ShareType='I' );
        insert contentdoclink;
        system.assertNotEquals(null, contentdoclink.Id);
        return contentdoclink;
    }

    
     /******************************************************************
    @Description:This creates a single Issue record.
    *******************************************************************/ 
    public static Apttus_SRM__Issue__c issueRecord(Id agmtId, Id accountId, string recordTypeName,string actionStatus){
        Id recordtypeID = Schema.SObjectType.Apttus_SRM__Issue__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Apttus_SRM__Issue__c issueRecord = new Apttus_SRM__Issue__c(Apttus_SRM__Agreement__c = agmtId, APTPS_Customer_Name__c = accountId,
                                                                        Apttus_SRM__Status__c= 'New', RecordTypeId = recordtypeID,APTPS_Action_Status__c =actionStatus);
        insert issueRecord;
        system.assertNotEquals(null, issueRecord.Id);
        return issueRecord;
    }
     /******************************************************************
    @Description:This creates a single Fund Product record.
    *******************************************************************/ 
    public static Fund_Product__c fundProductRecord(Id fundId, Id prodId){
        Fund_Product__c fundProductRecord = new Fund_Product__c(Fund__c = fundId, Product__c = prodId);
        insert fundProductRecord;
        system.assertNotEquals(null, fundProductRecord.Id);
        return fundProductRecord;
    }
    /******************************************************************
    @Description:This creates a single Fund record.
    *******************************************************************/ 
    public static Fund__c fundRecord(Id agmtId, string recordTypeName){
        Id recordtypeID = Schema.SObjectType.Fund__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Fund__c fundRecord = new Fund__c(Agreement__c = agmtId, RecordTypeId = recordtypeID);
        insert fundRecord;
        system.assertNotEquals(null, fundRecord.Id);
        return fundRecord;
    }
    /******************************************************************
    @Description:This creates a single Docusign Envelope record.
    *******************************************************************/ 
    public static Apttus_DocuApi__DocuSignEnvelope__c docuSignEnvelopeRecord(Id agmtId,  string envName){
        Apttus_DocuApi__DocuSignEnvelope__c envRec = new Apttus_DocuApi__DocuSignEnvelope__c(Name = envName, Apttus_CMDSign__Agreement__c = agmtId,
                                                                        Apttus_DocuApi__Status__c= 'completed' );
        insert envRec;
        system.assertNotEquals(null, envRec.Id);
        return envRec;
    }
    
    /******************************************************************
    @Description:This creates a single Docusign Envelope Recepient Status record.
    *******************************************************************/ 
    public static Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuSignEnvRcptStatusRecord(Id envId, string signerNumber){
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c statusRec = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c(Apttus_DocuApi__DocuSignEnvelopeId__c = envId,
                                                                        Apttus_DocuApi__Email__c =  'test@test.com', Apttus_DocuApi__SignedDateTime__c = Date.newInstance(2016, 10, 11),
                                                                        Apttus_DocuApi__Status__c = 'completed', Apttus_DocuApi__RecipientName__c = 'Test Name', Apttus_DocuApi__RoutingOrder__c = signerNumber);
        insert statusRec;
        system.assertNotEquals(null, statusRec.Id);
        return statusRec;
    }
    
    /******************************************************************
    @Description:This creates a single DocuSign Recipient record.
    *******************************************************************/ 
    public static Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipientRecord(Id agmtId, string roleName, Integer routingNo){
        Apttus_DocuApi__DocuSignDefaultRecipient2__c recipientRec = new Apttus_DocuApi__DocuSignDefaultRecipient2__c(Apttus_CMDSign__AgreementId__c = agmtId,
                                                                        Apttus_DocuApi__Email__c =  'test@test.com', Apttus_DocuApi__RoleName__c = roleName,
                                                                        Apttus_DocuApi__FirstName__c = 'Test First', Apttus_DocuApi__LastName__c = 'Test Last', Apttus_DocuApi__SigningOrder__c = routingNo);
        insert recipientRec;
        system.assertNotEquals(null, recipientRec.Id);
        return recipientRec;
    }
    
    public static void createQueryTemplateData()
    {
        Apttus__QueryTemplate__c queryTemplate = new Apttus__QueryTemplate__c();
        queryTemplate.Apttus__Sequence__c =1;
        queryTemplate.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate.Apttus__Description__c = 'Test Template';
        queryTemplate.Apttus__Active__c = true;
        queryTemplate.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate;
        
        Apttus__QueryTemplateQualifier__c qualifier = new Apttus__QueryTemplateQualifier__c();
        qualifier.Apttus__QueryTemplate__c = queryTemplate.Id;
        qualifier.Apttus__Sequence__c=1;
        qualifier.Apttus__SObjectLabel__c='Agreement';
        qualifier.Apttus__Field__c='RecordType.Name';
        qualifier.Apttus__CompOper__c='equal to';
        qualifier.Apttus__Value__c='Schedule';
        qualifier.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier;
        
        Apttus__QueryTemplateFilter__c filter1 = new Apttus__QueryTemplateFilter__c();
        filter1.Apttus__QueryTemplate__c = queryTemplate.Id;
        filter1.Apttus__Sequence__c = 1;
        filter1.Apttus__Field__c='Apttus__Guidance__c';
        filter1.Apttus__CompOper__c='equal to';
        filter1.Apttus__Value__c='1';

        insert filter1;
        
        
        Apttus__QueryTemplate__c queryTemplate2 = new Apttus__QueryTemplate__c();
        queryTemplate2.Apttus__Sequence__c =1;
        queryTemplate2.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate2.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate2.Apttus__Description__c = 'Test Template';
        queryTemplate2.Apttus__Active__c = true;
        queryTemplate2.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate2;
        
        Apttus__QueryTemplateQualifier__c qualifier2 = new Apttus__QueryTemplateQualifier__c();
        qualifier2.Apttus__QueryTemplate__c = queryTemplate2.Id;
        qualifier2.Apttus__Sequence__c=1;
        qualifier2.Apttus__SObjectLabel__c='Agreement';
        qualifier2.Apttus__Field__c='RecordType.Name';
        qualifier2.Apttus__CompOper__c='equal to';
        qualifier2.Apttus__Value__c='Schedule';
        qualifier2.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier2;
         
         Apttus__QueryTemplateFilter__c filter2 = new Apttus__QueryTemplateFilter__c();
        filter2.Apttus__QueryTemplate__c = queryTemplate2.Id;
        filter2.Apttus__Sequence__c = 2;
        filter2.Apttus__Field__c='Apttus__Guidance__c';
        filter2.Apttus__CompOper__c='not equal to';
        filter2.Apttus__Value__c='2';

        insert filter2;
        
        Apttus__QueryTemplate__c queryTemplate3 = new Apttus__QueryTemplate__c();
        queryTemplate3.Apttus__Sequence__c =1;
        queryTemplate3.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate3.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate3.Apttus__Description__c = 'Test Template';
        queryTemplate3.Apttus__Active__c = true;
        queryTemplate3.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate3;
        
        Apttus__QueryTemplateQualifier__c qualifier3 = new Apttus__QueryTemplateQualifier__c();
        qualifier3.Apttus__QueryTemplate__c = queryTemplate3.Id;
        qualifier3.Apttus__Sequence__c=1;
        qualifier3.Apttus__SObjectLabel__c='Agreement';
        qualifier3.Apttus__Field__c='RecordType.Name';
        qualifier3.Apttus__CompOper__c='equal to';
        qualifier3.Apttus__Value__c='Schedule';
        qualifier3.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier3;
         
        Apttus__QueryTemplateFilter__c filter3 = new Apttus__QueryTemplateFilter__c();
        filter3.Apttus__QueryTemplate__c = queryTemplate3.Id;
        filter3.Apttus__Sequence__c = 3;
        filter3.Apttus__Field__c='Apttus__Guidance__c';
        filter3.Apttus__CompOper__c='less than';
        filter3.Apttus__Value__c='3';

        insert filter3;
       
        
        Apttus__QueryTemplate__c queryTemplate4 = new Apttus__QueryTemplate__c();
        queryTemplate4.Apttus__Sequence__c =1;
        queryTemplate4.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate4.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate4.Apttus__Description__c = 'Test Template';
        queryTemplate4.Apttus__Active__c = true;
        queryTemplate4.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate4;
        
        Apttus__QueryTemplateQualifier__c qualifier4 = new Apttus__QueryTemplateQualifier__c();
        qualifier4.Apttus__QueryTemplate__c = queryTemplate4.Id;
        qualifier4.Apttus__Sequence__c=1;
        qualifier4.Apttus__SObjectLabel__c='Agreement';
        qualifier4.Apttus__Field__c='RecordType.Name';
        qualifier4.Apttus__CompOper__c='equal to';
        qualifier4.Apttus__Value__c='Schedule';
        qualifier4.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier4;
        
        Apttus__QueryTemplateFilter__c filter4 = new Apttus__QueryTemplateFilter__c();
        filter4.Apttus__QueryTemplate__c = queryTemplate4.Id;
        filter4.Apttus__Sequence__c = 4;
        filter4.Apttus__Field__c='Apttus__Guidance__c';
        filter4.Apttus__CompOper__c='less than or equal to';
        filter4.Apttus__Value__c='4';

        insert filter4;
        
        Apttus__QueryTemplate__c queryTemplate5 = new Apttus__QueryTemplate__c();
        queryTemplate5.Apttus__Sequence__c =1;
        queryTemplate5.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate5.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate5.Apttus__Description__c = 'Test Template';
        queryTemplate5.Apttus__Active__c = true;
        queryTemplate5.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate5;
        
        Apttus__QueryTemplateQualifier__c qualifier5 = new Apttus__QueryTemplateQualifier__c();
        qualifier5.Apttus__QueryTemplate__c = queryTemplate5.Id;
        qualifier5.Apttus__Sequence__c=1;
        qualifier5.Apttus__SObjectLabel__c='Agreement';
        qualifier5.Apttus__Field__c='RecordType.Name';
        qualifier5.Apttus__CompOper__c='equal to';
        qualifier5.Apttus__Value__c='Schedule';
        qualifier5.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier5;
         
        Apttus__QueryTemplateFilter__c filter5 = new Apttus__QueryTemplateFilter__c();
        filter5.Apttus__QueryTemplate__c = queryTemplate5.Id;
        filter5.Apttus__Sequence__c = 5;
        filter5.Apttus__Field__c='Apttus__Guidance__c';
        filter5.Apttus__CompOper__c='greater than';
        filter5.Apttus__Value__c='5';

        insert filter5;
        
        Apttus__QueryTemplate__c queryTemplate6 = new Apttus__QueryTemplate__c();
        queryTemplate6.Apttus__Sequence__c =1;
        queryTemplate6.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate6.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate6.Apttus__Description__c = 'Test Template';
        queryTemplate6.Apttus__Active__c = true;
        queryTemplate6.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate6;
        
        Apttus__QueryTemplateQualifier__c qualifier6 = new Apttus__QueryTemplateQualifier__c();
        qualifier6.Apttus__QueryTemplate__c = queryTemplate6.Id;
        qualifier6.Apttus__Sequence__c=1;
        qualifier6.Apttus__SObjectLabel__c='Agreement';
        qualifier6.Apttus__Field__c='RecordType.Name';
        qualifier6.Apttus__CompOper__c='equal to';
        qualifier6.Apttus__Value__c='Schedule';
        qualifier6.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier6;
         
        Apttus__QueryTemplateFilter__c filter6 = new Apttus__QueryTemplateFilter__c();
        filter6.Apttus__QueryTemplate__c = queryTemplate6.Id;
        filter6.Apttus__Sequence__c = 6;
        filter6.Apttus__Field__c='Apttus__Guidance__c';
        filter6.Apttus__CompOper__c='greater than or equal to';
        filter6.Apttus__Value__c='6';
        
        insert filter6;
        
        Apttus__QueryTemplate__c queryTemplate7 = new Apttus__QueryTemplate__c();
        queryTemplate7.Apttus__Sequence__c =1;
        queryTemplate7.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate7.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate7.Apttus__Description__c = 'Test Template';
        queryTemplate7.Apttus__Active__c = true;
        queryTemplate7.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate7;
        
        Apttus__QueryTemplateQualifier__c qualifier7 = new Apttus__QueryTemplateQualifier__c();
        qualifier7.Apttus__QueryTemplate__c = queryTemplate7.Id;
        qualifier7.Apttus__Sequence__c=1;
        qualifier7.Apttus__SObjectLabel__c='Agreement';
        qualifier7.Apttus__Field__c='RecordType.Name';
        qualifier7.Apttus__CompOper__c='equal to';
        qualifier7.Apttus__Value__c='Schedule';
        qualifier7.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier7;
         
        Apttus__QueryTemplateFilter__c filter7 = new Apttus__QueryTemplateFilter__c();
        filter7.Apttus__QueryTemplate__c = queryTemplate7.Id;
        filter7.Apttus__Sequence__c = 7;
        filter7.Apttus__Field__c='Apttus__Guidance__c';
        filter7.Apttus__CompOper__c='in';
        filter7.Apttus__Value__c='7';

        insert filter7;
        
        Apttus__QueryTemplate__c queryTemplate8 = new Apttus__QueryTemplate__c();
        queryTemplate8.Apttus__Sequence__c =1;
        queryTemplate8.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate8.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate8.Apttus__Description__c = 'Test Template';
        queryTemplate8.Apttus__Active__c = true;
        queryTemplate8.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate8;
        
        Apttus__QueryTemplateQualifier__c qualifier8 = new Apttus__QueryTemplateQualifier__c();
        qualifier8.Apttus__QueryTemplate__c = queryTemplate8.Id;
        qualifier8.Apttus__Sequence__c=1;
        qualifier8.Apttus__SObjectLabel__c='Agreement';
        qualifier8.Apttus__Field__c='RecordType.Name';
        qualifier8.Apttus__CompOper__c='equal to';
        qualifier8.Apttus__Value__c='Schedule';
        qualifier8.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier8;
        
        Apttus__QueryTemplateFilter__c filter8 = new Apttus__QueryTemplateFilter__c();
        filter8.Apttus__QueryTemplate__c = queryTemplate8.Id;
        filter8.Apttus__Sequence__c = 8;
        filter8.Apttus__Field__c='Apttus__Guidance__c';
        filter8.Apttus__CompOper__c='not in';
        filter8.Apttus__Value__c='8';

        insert filter8;
        
        
        Apttus__QueryTemplate__c queryTemplate9 = new Apttus__QueryTemplate__c();
        queryTemplate9.Apttus__Sequence__c =1;
        queryTemplate9.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate9.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate9.Apttus__Description__c = 'Test Template';
        queryTemplate9.Apttus__Active__c = true;
        queryTemplate9.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate9;
        
        Apttus__QueryTemplateQualifier__c qualifier9 = new Apttus__QueryTemplateQualifier__c();
        qualifier9.Apttus__QueryTemplate__c = queryTemplate9.Id;
        qualifier9.Apttus__Sequence__c=1;
        qualifier9.Apttus__SObjectLabel__c='Agreement';
        qualifier9.Apttus__Field__c='RecordType.Name';
        qualifier9.Apttus__CompOper__c='equal to';
        qualifier9.Apttus__Value__c='Schedule';
        qualifier9.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier9;
        
        Apttus__QueryTemplateFilter__c filter9 = new Apttus__QueryTemplateFilter__c();
        filter9.Apttus__QueryTemplate__c = queryTemplate9.Id;
        filter9.Apttus__Sequence__c = 9;
        filter9.Apttus__Field__c='Apttus__Guidance__c';
        filter9.Apttus__CompOper__c='like';
        filter9.Apttus__Value__c='9';

        insert filter9;
        
        Apttus__QueryTemplate__c queryTemplate10 = new Apttus__QueryTemplate__c();
        queryTemplate10.Apttus__Sequence__c =1;
        queryTemplate10.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate10.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate10.Apttus__Description__c = 'Test Template';
        queryTemplate10.Apttus__Active__c = true;
        queryTemplate10.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate10;
        
        Apttus__QueryTemplateQualifier__c qualifier10 = new Apttus__QueryTemplateQualifier__c();
        qualifier10.Apttus__QueryTemplate__c = queryTemplate10.Id;
        qualifier10.Apttus__Sequence__c=1;
        qualifier10.Apttus__SObjectLabel__c='Agreement';
        qualifier10.Apttus__Field__c='RecordType.Name';
        qualifier10.Apttus__CompOper__c='equal to';
        qualifier10.Apttus__Value__c='Schedule';
        qualifier10.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier10;
        
        Apttus__QueryTemplateFilter__c filter10 = new Apttus__QueryTemplateFilter__c();
        filter10.Apttus__QueryTemplate__c = queryTemplate10.Id;
        filter10.Apttus__Sequence__c    = 10;
        filter10.Apttus__Field__c='Apttus__Guidance__c';
        filter10.Apttus__CompOper__c='not like';
        filter10.Apttus__Value__c='10';

        insert filter10;
        
        Apttus__QueryTemplate__c queryTemplate11 = new Apttus__QueryTemplate__c();
        queryTemplate11.Apttus__Sequence__c =1;
        queryTemplate11.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate11.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate11.Apttus__Description__c = 'Test Template';
        queryTemplate11.Apttus__Active__c = true;
        queryTemplate11.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate11;
        
        Apttus__QueryTemplateQualifier__c qualifier11 = new Apttus__QueryTemplateQualifier__c();
        qualifier11.Apttus__QueryTemplate__c = queryTemplate11.Id;
        qualifier11.Apttus__Sequence__c=1;
        qualifier11.Apttus__SObjectLabel__c='Agreement';
        qualifier11.Apttus__Field__c='RecordType.Name';
        qualifier11.Apttus__CompOper__c='equal to';
        qualifier11.Apttus__Value__c='Schedule';
        qualifier11.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier11;
        
        Apttus__QueryTemplateFilter__c filter11 = new Apttus__QueryTemplateFilter__c();
        filter11.Apttus__QueryTemplate__c = queryTemplate11.Id;
        filter11.Apttus__Sequence__c    = 11;
        filter11.Apttus__Field__c='Apttus__Guidance__c';
        filter11.Apttus__CompOper__c='includes';
        filter11.Apttus__Value__c='11';

        insert filter11;
        
        
        Apttus__QueryTemplate__c queryTemplate12 = new Apttus__QueryTemplate__c();
        queryTemplate12.Apttus__Sequence__c =1;
        queryTemplate12.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate12.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate12.Apttus__Description__c = 'Test Template';
        queryTemplate12.Apttus__Active__c = true;
        queryTemplate12.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate12;
        
        Apttus__QueryTemplateQualifier__c qualifier12 = new Apttus__QueryTemplateQualifier__c();
        qualifier12.Apttus__QueryTemplate__c = queryTemplate12.Id;
        qualifier12.Apttus__Sequence__c=1;
        qualifier12.Apttus__SObjectLabel__c='Agreement';
        qualifier12.Apttus__Field__c='RecordType.Name';
        qualifier12.Apttus__CompOper__c='equal to';
        qualifier12.Apttus__Value__c='Schedule';
        qualifier12.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier12;
        
        Apttus__QueryTemplateFilter__c filter12 = new Apttus__QueryTemplateFilter__c();
        filter12.Apttus__QueryTemplate__c = queryTemplate12.Id;
        filter12.Apttus__Sequence__c    = 12;
        filter12.Apttus__Field__c='Apttus__Guidance__c';
        filter12.Apttus__CompOper__c='excludes';
        filter12.Apttus__Value__c='12';

        insert filter12;
        
        Apttus__QueryTemplate__c queryTemplate13 = new Apttus__QueryTemplate__c();
        queryTemplate13.Apttus__Sequence__c =1;
        queryTemplate13.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate13.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate13.Apttus__Description__c = 'Test Template';
        queryTemplate13.Apttus__Active__c = true;
        queryTemplate13.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate13;
        
        Apttus__QueryTemplateQualifier__c qualifier13 = new Apttus__QueryTemplateQualifier__c();
        qualifier13.Apttus__QueryTemplate__c = queryTemplate13.Id;
        qualifier13.Apttus__Sequence__c=1;
        qualifier13.Apttus__SObjectLabel__c='Agreement';
        qualifier13.Apttus__Field__c='RecordType.Name';
        qualifier13.Apttus__CompOper__c='equal to';
        qualifier13.Apttus__Value__c='Schedule';
        qualifier13.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier13;
        
        
        
        Apttus__QueryTemplateFilter__c filter13 = new Apttus__QueryTemplateFilter__c();
        filter13.Apttus__QueryTemplate__c = queryTemplate13.Id;
        filter13.Apttus__Sequence__c    = 13;
        filter13.Apttus__Field__c='Apttus__Guidance__c';
        filter13.Apttus__CompOper__c='starts with';
        filter13.Apttus__Value__c='13';

        insert filter13;
        
        Apttus__QueryTemplate__c queryTemplate14 = new Apttus__QueryTemplate__c();
        queryTemplate14.Apttus__Sequence__c =1;
        queryTemplate14.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate14.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate14.Apttus__Description__c = 'Test Template';
        queryTemplate14.Apttus__Active__c = true;
        queryTemplate14.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate14;
        
        Apttus__QueryTemplateQualifier__c qualifier14 = new Apttus__QueryTemplateQualifier__c();
        qualifier14.Apttus__QueryTemplate__c = queryTemplate14.Id;
        qualifier14.Apttus__Sequence__c=1;
        qualifier14.Apttus__SObjectLabel__c='Agreement';
        qualifier14.Apttus__Field__c='RecordType.Name';
        qualifier14.Apttus__CompOper__c='equal to';
        qualifier14.Apttus__Value__c='Schedule';
        qualifier14.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier14;
        
        Apttus__QueryTemplateFilter__c filter14 = new Apttus__QueryTemplateFilter__c();
        filter14.Apttus__QueryTemplate__c = queryTemplate14.Id;
        filter14.Apttus__Sequence__c    = 14;
        filter14.Apttus__Field__c='Apttus__Guidance__c';
        filter14.Apttus__CompOper__c='contains';
        filter14.Apttus__Value__c='14';

        insert filter14;
        
        Apttus__QueryTemplate__c queryTemplate15 = new Apttus__QueryTemplate__c();
        queryTemplate15.Apttus__Sequence__c =1;
        queryTemplate15.Apttus__Type__c= 'Agreement Template Filter';
        queryTemplate15.Apttus__SObjectLabel__c = 'Agreement Template';
        queryTemplate15.Apttus__Description__c = 'Test Template';
        queryTemplate15.Apttus__Active__c = true;
        queryTemplate15.Apttus__SObjectType__c = 'Apttus__APTS_Template__c';
        
        insert queryTemplate15;
        
        Apttus__QueryTemplateQualifier__c qualifier15 = new Apttus__QueryTemplateQualifier__c();
        qualifier15.Apttus__QueryTemplate__c = queryTemplate15.Id;
        qualifier15.Apttus__Sequence__c=1;
        qualifier15.Apttus__SObjectLabel__c='Agreement';
        qualifier15.Apttus__Field__c='RecordType.Name';
        qualifier15.Apttus__CompOper__c='equal to';
        qualifier15.Apttus__Value__c='Schedule';
        qualifier15.Apttus__SObjectType__c= 'Apttus__APTS_Agreement__c';
        
         insert qualifier15;
        
        Apttus__QueryTemplateFilter__c filter15 = new Apttus__QueryTemplateFilter__c();
        filter15.Apttus__QueryTemplate__c = queryTemplate15.Id;
        filter15.Apttus__Sequence__c    = 15;
        filter15.Apttus__Field__c='Apttus__Guidance__c';
        filter15.Apttus__CompOper__c='does not contain';
        filter15.Apttus__Value__c='15';

        insert filter15;
        /*
        
        */
        
    }
	
	public static testMethod void testMethod1()
 
    {
 
        Account testAccount = new Account();
 
        testAccount.Name='Test Account' ;
 
        insert testAccount;
 
System.assertEquals(testAccount.name, 'Test Account');
 
}

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}