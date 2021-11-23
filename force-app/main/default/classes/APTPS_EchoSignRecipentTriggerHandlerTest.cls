/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 21/09/2021 
* @Type         : Test Class
* @Name         : APTPS_EchoSignRecipentTriggerHandlerTest
* @Description  : Test class for APTPS_EchoSignRecipentTriggerHandler
*
**/
@isTest
private class APTPS_EchoSignRecipentTriggerHandlerTest {

    private static testMethod void echoSignRecipientUpdate_SignedTest(){ 
        
        
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
        
        recipient3.echosign_dev1__Status__c = 'Signed';
        update recipient3;
        Test.stopTest();
        
    }
    
    private static testMethod void echoSignRecipientUpdate_ApprovedTest(){
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
        
        recipient2.echosign_dev1__Status__c = 'Approved';
        update recipient2;
        Test.stopTest();
        
    }
    
    private static testMethod void echoSignRecipientUpdate_MultipartyTest1(){
        
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        Account acct2 = APTPS_TestClassData.accountRecord('Secondary Account', '1237898898');
        List<Contact> contactList = new List<Contact>();
        Contact con = TestUtil.createContact(acct.id,'federer','Rodger');
        Contact con3 = TestUtil.createContact(acct.id,'Morphy','Richards');
        Contact con2 = TestUtil.createContact(acct2.id,'Hindustan','Lever');
        Contact con4 = TestUtil.createContact(acct2.id,'Nadal','Rafale');
        contactList.add(con);
        contactList.add(con3);
        contactList.add(con2);
        contactList.add(con4);
        insert contactList;
        APTPS_Sales_Contact__c telstraContact = new APTPS_Sales_Contact__c(Name = 'Test name', APTPS_First_Name__c = 'Test',APTPS_Last_Name__c = 'Name', APTPS_Email__c = 'test@test.com', APTPS_Employee_Number__c = '2499');
		insert telstraContact;
        system.assertNotEquals(null, telstraContact.Id);        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt1.Id,
        echosign_dev1__Recipient__c = con.Id
        );
        insert echoSignAgreement;
        
        Test.stopTest();
        
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
        
        recipient3.echosign_dev1__Status__c = 'Approved';
        update recipient3;
        
    }
    
    private static testMethod void echoSignRecipientUpdate_MultipartyTest2(){
        
        Test.startTest();
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        Account acct2 = APTPS_TestClassData.accountRecord('Secondary Account', '1237898898');
        List<Contact> contactList = new List<Contact>();
        Contact con = TestUtil.createContact(acct.id,'federer','Rodger');
        Contact con3 = TestUtil.createContact(acct.id,'Morphy','Richards');
        Contact con2 = TestUtil.createContact(acct2.id,'Hindustan','Lever');
        Contact con4 = TestUtil.createContact(acct2.id,'Nadal','Rafale');
        contactList.add(con);
        contactList.add(con3);
        contactList.add(con2);
        contactList.add(con4);
        insert contactList;
        APTPS_Sales_Contact__c telstraContact = new APTPS_Sales_Contact__c(Name = 'Test name', APTPS_First_Name__c = 'Test',APTPS_Last_Name__c = 'Name', APTPS_Email__c = 'test@test.com', APTPS_Employee_Number__c = '2499');
		insert telstraContact;
        system.assertNotEquals(null, telstraContact.Id);        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt1.Id,
        echosign_dev1__Recipient__c = con.Id
        );
        insert echoSignAgreement;
        
        Test.stopTest();
        
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
        
        echosign_dev1__SIGN_Recipients__c recipient4 = new echosign_dev1__SIGN_Recipients__c (
        echosign_dev1__Agreement__c = echoSignAgreement.Id,
        echosign_dev1__Contact__c = con.Id,
        echosign_dev1__Order_Number__c = 4,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'Contact',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient4);
        
        insert echoSignRecipientsList;
        
        recipient4.echosign_dev1__Status__c = 'Approved';
        update recipient4;
        
    }
    
    private static testMethod void echoSignRecipientUpdate_UserTest(){
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct1.id);
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt1.Id,
        echosign_dev1__Recipient_User__c  = UserInfo.getUserId()
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
        echosign_dev1__User__c = UserInfo.getUserId(),
        echosign_dev1__Order_Number__c = 3,
        echosign_dev1__Status__c = 'Shared',
        echosign_dev1__Recipient_Type__c = 'User',
        echosign_dev1__Signer_Verification_Method__c = 'Email'    
        );
        echoSignRecipientsList.add(recipient3);
        
        insert echoSignRecipientsList;
        
        recipient3.echosign_dev1__Status__c = 'Signed';
        update recipient3;
        Test.stopTest();
        
    }
    
    private static testMethod void echoSignRecipientDisableTrigger_Test(){
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'APTPS_EchoSignRecipientTrigger';
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
        
        recipient3.echosign_dev1__Status__c = 'Signed';
        update recipient3;
        Test.stopTest();
    }
    
    private static testMethod void echoSignRecipientChildAgreementUpdate_Test(){
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'APTPS_EchoSignRecipientTrigger';
        insert disabledTriggersProfile;
        
        Test.startTest();
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct1.Id);
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct1.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = new Apttus__APTS_Agreement__c();
        agmt1.Name = 'Sch Test Agreement';
        agmt1.Apttus__Account__c = acct1.Id;
        agmt1.Apttus__Parent_Agreement__c = agmt.Id;
        agmt1.recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Signatures';
        agmt1.Apttus__Status__c = 'Other Party Signatures'; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Auto_Created_by_Basket__c = false;
        insert agmt1;
        
        echosign_dev1__SIGN_Agreement__c echoSignAgreement = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__Account__c = acct1.Id,
        Apttus_Echosign__Apttus_Agreement__c = agmt.Id,
        echosign_dev1__Recipient__c = con.Id
        );
        insert echoSignAgreement;
        
        Test.stopTest();
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
        
        List<echosign_dev1__SIGN_Recipients__c> echoSignUpdateList = new List<echosign_dev1__SIGN_Recipients__c>();
        recipient2.echosign_dev1__Status__c = 'Signed';
        recipient3.echosign_dev1__Status__c = 'Signed';
        echoSignUpdateList.add(recipient2);
        echoSignUpdateList.add(recipient3);
        update echoSignUpdateList;
        
    }
    
}