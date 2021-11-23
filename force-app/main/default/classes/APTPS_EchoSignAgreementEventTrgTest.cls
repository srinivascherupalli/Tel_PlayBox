/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 08/10/2021 
* @Type         : Test Class
* @Name         : APTPS_EchoSignAgreementEventTrgTest
* @Description  : Test class for APTPS_EchoSignAgreementEventTrgHandler
*
**/
@isTest
private class APTPS_EchoSignAgreementEventTrgTest { 

     private static testMethod void echoSignAgreementEvent_CreatedTest(){
         
         Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'APTPS_EchoSignAgreementEventTrigger';
        insert disabledTriggersProfile;
         
         Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct1.id);
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt1.Id,
        echosign_dev1__Recipient__c = con.Id
        );
        insert echoSignAgreement;
        
        Test.startTest();
        List<echosign_dev1__SIGN_Recipients__c> echoSignRecipientsList = new List<echosign_dev1__SIGN_Recipients__c>();
        echosign_dev1__SIGN_Recipients__c recipient1 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 1,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient1);
        
        echosign_dev1__SIGN_Recipients__c recipient2 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 2,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient2);
        
        echosign_dev1__SIGN_Recipients__c recipient3 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 3,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient3);
        
        insert echoSignRecipientsList;
        
        echosign_dev1__SIGN_AgreementEvent__c agmtEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        agmtEvent.echosign_dev1__Comment2__c = 'Test xyz';
        agmtEvent.echosign_dev1__Event_Type__c ='CREATED';
        agmtEvent.echosign_dev1__SIGN_Agreement__c = echoSignAgreement.Id;
        insert agmtEvent;
        Test.stopTest();
     }
    
    private static testMethod void echoSignAgreementEvent_CreatedTestWithParentAgreement(){
         
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct1.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct1.id, agmt.Id);
        
        String primaryAgmtAttachmentName = 'PrimaryAgreementAttachment - signed.pdf';
        String childAgmtAttachmentName = 'ChildAgreementAttachment - signed.pdf';
        
        Map<String, String> attachmentMap = new Map<String, String>();
        attachmentMap.put(primaryAgmtAttachmentName, agmt.Id);
        attachmentMap.put(childAgmtAttachmentName, agmt1.Id);
        
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt.Id,
        echosign_dev1__Recipient__c = con.Id,
        Apttus_EchoSign__Apttus_RSPCAttachments__c = JSON.serialize(attachmentMap)
        );
        insert echoSignAgreement;
        
        Test.startTest();
        List<echosign_dev1__SIGN_Recipients__c> echoSignRecipientsList = new List<echosign_dev1__SIGN_Recipients__c>();
        echosign_dev1__SIGN_Recipients__c recipient1 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 1,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient1);
        
        echosign_dev1__SIGN_Recipients__c recipient2 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 2,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient2);
        
        echosign_dev1__SIGN_Recipients__c recipient3 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 3,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient3);
        
        insert echoSignRecipientsList;
        
        echosign_dev1__SIGN_AgreementEvent__c agmtEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        agmtEvent.echosign_dev1__Comment2__c = 'Test xyz';
        agmtEvent.echosign_dev1__Event_Type__c ='CREATED';
        agmtEvent.echosign_dev1__SIGN_Agreement__c = echoSignAgreement.Id;
        insert agmtEvent;
        Test.stopTest();
     }
    
    private static testMethod void echoSignAgreementEvent_RejectedTestWithParentAgreement(){
         
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct1.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct1.id, agmt.Id);
        
        String primaryAgmtAttachmentName = 'PrimaryAgreementAttachment - signed.pdf';
        String childAgmtAttachmentName = 'ChildAgreementAttachment - signed.pdf';
        
        Map<String, String> attachmentMap = new Map<String, String>();
        attachmentMap.put(primaryAgmtAttachmentName, agmt.Id);
        attachmentMap.put(childAgmtAttachmentName, agmt1.Id);
        
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt.Id,
        echosign_dev1__Recipient__c = con.Id,
        Apttus_EchoSign__Apttus_RSPCAttachments__c = JSON.serialize(attachmentMap)
        );
        insert echoSignAgreement;
        
        Test.startTest();
        List<echosign_dev1__SIGN_Recipients__c> echoSignRecipientsList = new List<echosign_dev1__SIGN_Recipients__c>();
        echosign_dev1__SIGN_Recipients__c recipient1 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 1,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient1);
        
        echosign_dev1__SIGN_Recipients__c recipient2 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 2,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient2);
        
        echosign_dev1__SIGN_Recipients__c recipient3 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 3,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient3);
        
        insert echoSignRecipientsList;
        
        echosign_dev1__SIGN_AgreementEvent__c agmtEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        agmtEvent.echosign_dev1__Comment2__c = 'Test xyz';
        agmtEvent.echosign_dev1__Event_Type__c ='REJECTED';
        agmtEvent.echosign_dev1__SIGN_Agreement__c = echoSignAgreement.Id;
        insert agmtEvent;
        Test.stopTest();
     }
    
    private static testMethod void echoSignAgreementEvent_RecalledTestWithParentAgreement(){
         
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct1.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct1.id, agmt.Id);
        
        String primaryAgmtAttachmentName = 'PrimaryAgreementAttachment - signed.pdf';
        String childAgmtAttachmentName = 'ChildAgreementAttachment - signed.pdf';
        
        Map<String, String> attachmentMap = new Map<String, String>();
        attachmentMap.put(primaryAgmtAttachmentName, agmt.Id);
        attachmentMap.put(childAgmtAttachmentName, agmt1.Id);
        
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt.Id,
        echosign_dev1__Recipient__c = con.Id,
        Apttus_EchoSign__Apttus_RSPCAttachments__c = JSON.serialize(attachmentMap)
        );
        insert echoSignAgreement;
        
        Test.startTest();
        List<echosign_dev1__SIGN_Recipients__c> echoSignRecipientsList = new List<echosign_dev1__SIGN_Recipients__c>();
        echosign_dev1__SIGN_Recipients__c recipient1 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 1,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient1);
        
        echosign_dev1__SIGN_Recipients__c recipient2 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 2,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient2);
        
        echosign_dev1__SIGN_Recipients__c recipient3 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 3,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient3);
        
        insert echoSignRecipientsList;
        
        echosign_dev1__SIGN_AgreementEvent__c agmtEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        agmtEvent.echosign_dev1__Comment2__c = 'Test xyz';
        agmtEvent.echosign_dev1__Event_Type__c ='RECALLED';
        agmtEvent.echosign_dev1__SIGN_Agreement__c = echoSignAgreement.Id;
        insert agmtEvent;
        Test.stopTest();
     }
}