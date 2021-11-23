@isTest
private with sharing class APTPS_SendForSignatureControllerTest {
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SendForSignatureController class
    *******************************************************************/  
    static testMethod void testMethod1()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test6');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');

        //create contacts
        Contact con1 = APTPS_TestClassData.contactRecord(acct.id);
        Contact con2 = TestUtil.createContact('fname12','lname12');
		con2.AccountId = acct.id;
        insert con2;
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
        agmt1.APTPS_Contacts_Lookup2__c = con1.Id;
        agmt1.APTPS_Contacts_Lookup__c = con2.Id;
        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        FROM EmailTemplate where folder.developerName <> '' and  Name = 'Request for Signature' limit 1];//folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.addlRecipientsPlainText = 'test@test.com';
        sfsc.addlRecipientsHTML = 'test@test.com';
        sfsc.agreementListToBeDisplayed = null;
        
        sfsc.getAgreements();
        sfsc.getAttachments();
        sfsc.getTemplateFolders();
        sfsc.getTemplates();
        sfsc.updateTemplateFolderId();
        sfsc.getSelected();
        sfsc.selectAgreementAndAttachment();
        sfsc.populateTemplate();
        sfsc.getTemplates();
        sfsc.attachment = null;
        sfsc.send();
        Test.stopTest();
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SendForSignatureController class
    *******************************************************************/
    static testMethod void testMethod2()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test7');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        //create contacts
        Contact con1 = APTPS_TestClassData.contactRecord(acct.id);
        Contact con2 = TestUtil.createContact('fname12','lname12');
		con2.AccountId = acct.id;
        insert con2;
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
        agmt1.APTPS_Contacts_Lookup2__c = con1.Id;
        agmt1.APTPS_Contacts_Lookup__c = con2.Id;
        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        //EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        //FROM EmailTemplate where folder.developerName <> '' and folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        //ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.addlRecipientsPlainText = 'test@test.com';
        sfsc.addlRecipientsHTML = 'test@test.com';
        sfsc.agreementListToBeDisplayed = null;
        
        sfsc.getAgreements();
        sfsc.getAttachments();
        sfsc.getTemplateFolders();
        sfsc.getTemplates();
        sfsc.updateTemplateFolderId();
        sfsc.getSelected();
        sfsc.selectAgreementAndAttachment();
        sfsc.populateTemplate();
        sfsc.getTemplates();
        sfsc.attachment = null;
        sfsc.send();
        Test.stopTest();
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SendForSignatureController class
    *******************************************************************/
    static testMethod void testMethod3()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test8');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        //create contacts
        Contact con1 = APTPS_TestClassData.contactRecord(acct.id);
        Contact con2 = TestUtil.createContact('fname12','lname12');
		con2.AccountId = acct.id;
        insert con2;
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
        agmt1.APTPS_Contacts_Lookup2__c = con1.Id;
        agmt1.APTPS_Contacts_Lookup__c = con2.id;
        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        FROM EmailTemplate where folder.developerName <> '' and  Name = 'Request for Signature' limit 1];//folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.addlRecipientsPlainText = '';
        sfsc.addlRecipientsHTML = '';
        sfsc.agreementListToBeDisplayed = null;
        
        PageReference cancelPageRef = sfsc.cancel();
        system.assertEquals('/'+sfsc.parentAgreement.Id, cancelPageRef.getUrl());
        
        sfsc.getAgreements();
        sfsc.getAttachments();
        sfsc.getTemplateFolders();
        sfsc.getTemplates();
        sfsc.updateTemplateFolderId();
        sfsc.getSelected();
        sfsc.agreementListToBeDisplayed = null;
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.selectAgreementAndAttachment();
        sfsc.populateTemplate();
        sfsc.getTemplates();
        sfsc.attachment = null;
        sfsc.send();
        Test.stopTest();
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SendForSignatureController class
    *******************************************************************/
    static testMethod void testMethod4()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test8');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        //create contacts
        Contact con1 = APTPS_TestClassData.contactRecord(acct.id);
        Contact con2 = TestUtil.createContact('fname12','lname12');
		con2.AccountId = acct.id;
        insert con2;
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
        agmt1.APTPS_Contacts_Lookup2__c = con1.Id;
        agmt1.APTPS_Contacts_Lookup__c = con2.id;
        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        FROM EmailTemplate where folder.developerName <> '' and  Name = 'Request for Signature' limit 1];//folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.addlRecipientsPlainText = '';
        sfsc.addlRecipientsHTML = '';
        sfsc.agreementListToBeDisplayed = null;
        
        PageReference cancelPageRef = sfsc.cancel();
        system.assertEquals('/'+sfsc.parentAgreement.Id, cancelPageRef.getUrl());
        
        sfsc.getAgreements();
        sfsc.getAttachments();
        sfsc.getTemplateFolders();
        sfsc.getTemplates();
        sfsc.updateTemplateFolderId();
        for(APTPS_AgreementSelection agrmntSelection : sfsc.agreementListToBeDisplayed){
            if(agrmntSelection.relationship == 'Parent'){
                agrmntSelection.selected = false;
            }
            else{
                agrmntSelection.selected = true;
            }
        }
        try{
            sfsc.selectAgreementAndAttachment();
        }
        catch(Exception e)
        {
            //Boolean expectedExceptionThrown =  e.getMessage().contains('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
        for(APTPS_AttachmenttSelectionWrapper agrmntAttachment : sfsc.attachmentListToBeDisplayed){
            if(agrmntAttachment.relationship == 'Parent'){
                agrmntAttachment.selected = false;
            }
            else{
                agrmntAttachment.selected = true;
            }
        }
        try{
            sfsc.selectAgreementAndAttachment();
        }
        catch(Exception e)
        {
            //Boolean expectedExceptionThrown =  e.getMessage().contains('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
        for(APTPS_AgreementSelection agrmntSelection : sfsc.agreementListToBeDisplayed){
            agrmntSelection.selected = true;
        }
        try{
            sfsc.selectAgreementAndAttachment();
        }
        catch(Exception e)
        {
            //Boolean expectedExceptionThrown =  e.getMessage().contains('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
        sfsc.agreementListToBeDisplayed = null;
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.selectAgreementAndAttachment();
        sfsc.populateTemplate();
        sfsc.getTemplates();
        sfsc.attachment = null;
        sfsc.send();
        Test.stopTest();
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SendForSignatureController class
    *******************************************************************/
    static testMethod void testMethod5()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test6');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
    
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;

        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        FROM EmailTemplate where folder.developerName <> '' and  Name = 'Request for Signature' limit 1];//folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.attachmentListToBeDisplayed = null;
        sfsc.addlRecipientsPlainText = 'test@test.com';
        sfsc.addlRecipientsHTML = 'test@test.com';
        sfsc.agreementListToBeDisplayed = null;
        
        sfsc.getAgreements();
        sfsc.getAttachments();
        sfsc.getTemplateFolders();
        sfsc.getTemplates();
        sfsc.updateTemplateFolderId();
        sfsc.getSelected();
        sfsc.selectAgreementAndAttachment();
        sfsc.populateTemplate();
        sfsc.getTemplates();
        sfsc.attachment = null;
        sfsc.actionName = 'Send_For_Signature';
        sfsc.send();
        //sfsc.actionName = 'Send_For_Review';
        //sfsc.send();
        sfsc.selectedEmailTemplateId = null;
        sfsc.addlRecipientsPlainText = null;
        try{
            sfsc.send();
        }
        catch(Exception e)
        {
            //Boolean expectedExceptionThrown =  e.getMessage().contains('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    static testMethod void testMethod6(){
       //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test6');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
    
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;

        update agmt1;
        
        Attachment attachment1 = new Attachment();    
        attachment1.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment1.body = bodyBlob;
        attachment1.parentId = agmt1.id;
        insert attachment1;
        
        EmailTemplate emailtemplate1 = [SELECT Id, Subject,folder.Name,FolderId
        FROM EmailTemplate where folder.developerName <> '' and  Name = 'Request for Signature' limit 1];//folder.Name= 'Apttus Email Templates' limit 1];
        
        PageReference pageRef = Page.APTPS_Init_SendForSignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        ApexPages.currentPage().getParameters().put('folderId',UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateid', emailtemplate1.ID);
        
        //Test.startTest();
        
        APTPS_SendForSignatureController sfsc = new APTPS_SendForSignatureController(new ApexPages.StandardController(agmt1));
        sfsc.cancelSignatures();
    }
}