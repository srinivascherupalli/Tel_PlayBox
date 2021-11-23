/*
    Apttus Echosign Integration
    ApttusAdobeESignAttachmentTriggerTest
     
    @2016 Apttus Inc. All rights reserved.
*/
@isTest
private class ApttusAdobeESignAttachmentTriggerTest {
    
    private static User user;
    private Apttus__APTS_Agreement__c primaryAgmt;
    private Apttus__APTS_Agreement__c childAgmt;
    private echosign_dev1__SIGN_Agreement__c esAgreement;
    private List<Attachment> attachList;
    
    static testmethod void testSignedDocument() {
        ApttusAdobeESignAttachmentTriggerTest instance = new ApttusAdobeESignAttachmentTriggerTest();
        instance.testSignedDocumentAttachmentTrigger();
    }
    
    static testmethod void testAuditDocument() {
        ApttusAdobeESignAttachmentTriggerTest instance = new ApttusAdobeESignAttachmentTriggerTest();
        instance.testAuditDocumentAttachmentTrigger();
    }
    
    static testmethod void testChildAgreementDocument() {
        ApttusAdobeESignAttachmentTriggerTest instance = new ApttusAdobeESignAttachmentTriggerTest();
        instance.testChildAgreementDocumentAttachmentTrigger();
    }
    
    private void testSignedDocumentAttachmentTrigger() {
        createTestData();
        
        test.startTest();
        // add attachment
        Attachment att = new Attachment(Name = 'PrimaryAgreementAttachment - signed.pdf'
            , ParentId = esAgreement.Id
            , Body = Blob.valueOf('Test Data for Primary Agreement'));
        
        insert att;
        System.assert(att.Id != null);
        
        attachList = [select Id, Name from Attachment where parentId = :primaryAgmt.Id];
        System.assert(attachList.size() == 1);
        
        test.stopTest();

    }
    
    private void testAuditDocumentAttachmentTrigger() {
        createTestData();
        
        test.startTest();
        // add attachment
        Attachment att = new Attachment(Name = 'PrimaryAgreementAttachment - audit.pdf'
            , ParentId = esAgreement.Id
            , Body = Blob.valueOf('Test Data for Primary Agreement'));
        
        insert att;
        System.assert(att.Id != null);
        
        attachList = [select Id, Name from Attachment where parentId = :primaryAgmt.Id];
        System.assert(attachList.size() == 1);
        
        test.stopTest();

    }
    
    private void testChildAgreementDocumentAttachmentTrigger() {
        createTestData();
        createChildAgreement();
        
        String primaryAgmtAttachmentName = 'PrimaryAgreementAttachment - signed.pdf';
        String childAgmtAttachmentName = 'ChildAgreementAttachment - signed.pdf';
        
        Map<String, Id> attachmentMap = new Map<String, Id>();
        attachmentMap.put(primaryAgmtAttachmentName, primaryAgmt.Id);
        attachmentMap.put(childAgmtAttachmentName, childAgmt.Id);
        esAgreement = [select Id from echosign_dev1__SIGN_Agreement__c where Id = :esAgreement.Id];
        esAgreement.Apttus_EchoSign__Apttus_RSPCAttachments__c = JSON.serialize(attachmentMap);
        update esAgreement;
        
        List<Attachment> attachmentList = new List<Attachment>();
        
        // add primary agmts attachment to the list
        Attachment att1 = new Attachment(Name = primaryAgmtAttachmentName
            , ParentId = esAgreement.Id
            , Body = Blob.valueOf('Test Data for Primary Agreement'));
        attachmentList.add(att1);
        
        // add primary agmts attachment to the list
        Attachment att2 = new Attachment(Name = childAgmtAttachmentName
            , ParentId = esAgreement.Id
            , Body = Blob.valueOf('Test Data for Child Agreement'));
        attachmentList.add(att2);
        
        test.startTest();
        insert attachmentList;
        test.stopTest();
        attachList = [select Id, Name from Attachment where parentId IN : attachmentMap.values()];
        System.assert(attachList.size() == 2);
    }
    
    // create test data to be used by the test methods
    private void createTestData() {
        Id pId = [Select Id From Profile where Name = 'System Administrator'].Id;
        user = [Select Id, Name From User where IsActive = true and ProfileId = :pId limit 1];
        
        // create  primary agreement
        primaryAgmt = new Apttus__APTS_Agreement__c(Name='Primary Agreement'
            , OwnerId = user.Id
            , Apttus__Status_Category__c = 'Request'
            , Apttus__Status__c = 'Request');
        insert primaryAgmt;
        System.assert(primaryAgmt.Id != null);
        
        esAgreement = new echosign_dev1__SIGN_Agreement__c();
        esAgreement.Apttus_EchoSign__Apttus_Agreement__c = primaryAgmt.Id;
        esAgreement.Apttus_EchoSign__Is_Transient__c = true;
        esAgreement.Name = primaryAgmt.Name;
        insert esAgreement;
        System.assert(esAgreement.Id != null);
        
        // Set the custom setting values
        Apttus_EchoSign__ApttusAdobeESignatureProperties__c  objectApttusAdobeESignatureProperties = createSystemProperties('System Properties');
        objectApttusAdobeESignatureProperties.Apttus_EchoSign__UpdateRelatedAgreements__c = true;
        objectApttusAdobeESignatureProperties.Apttus_EchoSign__DoNotCopySignedDocuments__c = true;
        update objectApttusAdobeESignatureProperties;
        
    } 
    
    // create child agreement
    private void createChildAgreement() {
        // create  primary agreement
        childAgmt = new Apttus__APTS_Agreement__c(Name='Child Agreement'
            , OwnerId = user.Id
            , Apttus__Parent_Agreement__c = primaryAgmt.Id
            , Apttus__Status_Category__c = 'Request'
            , Apttus__Status__c = 'Request');
        insert childAgmt;
        System.assert(childAgmt.Id != null);
    }
    
    /**
     * Creates a system properties object
     * @param datasetName the property dataset name
     * @return the system properties object
     */
    private Apttus_EchoSign__ApttusAdobeESignatureProperties__c createSystemProperties(String datasetName) {
        
        // get the system properties dataset
        Apttus_EchoSign__ApttusAdobeESignatureProperties__c prop = Apttus_EchoSign__ApttusAdobeESignatureProperties__c.getInstance(datasetName);
        
        // if the dataset does not exist, create 
        if (prop == null) {
            // create the property
            prop = new Apttus_EchoSign__ApttusAdobeESignatureProperties__c(Name = datasetName);
            // insert property
            insert prop;
        
        }
        
        System.assert(prop.ID != null, 'Failed to create the system properties ' + datasetName);
        return prop;
        
    }
}