@isTest(seeAllData=false)
private class APTPS_AgreementTriggerTest{

    @testSetup static void setup() {
        Id profile = [select id from profile where name='System Administrator'].id;
        User userRecord = new User(alias = 'conf3', email='test@noemail.com',
                emailencodingkey='UTF-8', lastname='conf3', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profile, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='test@calms.com');
        insert userRecord;
    }

    
    /*public static List<Apttus__APTS_Agreement__c> agreementList;
    public static List<Apttus_SRM__SRMObligation__c> obligationList;
    public static List<Apttus__Agreement_Clause__c> agreementClauseList;
    public static List<Apttus__APTS_Template__c> templateList;
    public static List<APTPS_Template_Obligations__c> templateObligationsList;
    
    
    static testMethod void testDataCreation(){ 
        Apttus__APTS_Template__c templateClause = new Apttus__APTS_Template__c(Name = 'Test clause', Apttus__Type__c = 'Clause', Apttus__Agreement_Types__c = 'BSA', Apttus__Mergefields2__c = 'Apttus__APTS_Agreement__c (Name);');
        insert templateClause;
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment(ParentId = templateClause.ID, Name = 'Test Attachment for Template clause', Body = b);
        insert attachment;
        APTPS_Template_Obligations__c templateObligation = new APTPS_Template_Obligations__c(APTPS_Template__c = templateClause.ID, Name = 'Test template obligation', APTPS_SRM_Active__c = true);
        insert templateObligation;
        Account account = new Account(name = 'Test Account');
        insert account;
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(name = 'BSA agreement', Apttus__Agreement_Category__c = 'Single Customer', APTPS_Telstra_Legal_Entity__c = 'Melbourne', Apttus__Account__c = account.id);
        insert agreement;
        
    }  */

    /******************************************************************
     @Author: Lokesh D
    @Description:This testMethod is for checking user using calms integration profile under US EDGE-81538
    *******************************************************************/
    static testMethod void testCALMSIntegrationUser(){

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CALMS Integration User' LIMIT 1];

        User usr = new User(LastName = 'LIVESTON',
                FirstName='JASON',
                Alias = 'jliv',
                Email = 'test.calms@gmail.com',
                Username = 'test.calmsprofile@gmail.com',
                ProfileId = profileId.id,
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US'
        );

        insert usr;

        Account acc= new Account();
        acc.name='testacc';
        insert acc;

        Apttus__APTS_Agreement__c agmt1=new Apttus__APTS_Agreement__c();
        agmt1.Name='test';
        agmt1.Apttus__Account__c=acc.id;
        agmt1.Apttus__Agreement_Category__c='Business Services';
        agmt1.APTPS_Agreement_Subcategory__c='Single Customer';
        agmt1.APTPS_Telstra_Legal_Entity__c='Victoria';
        insert agmt1;

        System.runAs(usr){

            Test.startTest();

            List<Apttus__APTS_Agreement__c> agreementList1 = new List<Apttus__APTS_Agreement__c>();


            list<Apttus__APTS_Agreement__c> updatedAgmt1 = [Select Id, Aged_Debt__c from Apttus__APTS_Agreement__c where id = :agmt1.id Limit 1];

            for(Apttus__APTS_Agreement__c agm: updatedAgmt1)
            {
                agm.Aged_Debt__c=true;
                agreementList1.add(agm);
            }

            update agreementList1;

            system.assertEquals(true ,agreementList1[0].Aged_Debt__c);
            Test.stopTest();
        }
    }
    /******************************************************************
    @Description:This testMethod is for copyObligationFromTemplateObligation method.
    *******************************************************************/
    static testMethod void copyObligationFromTemplateObligation(){

        Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Template', 'Clause');
        APTPS_Template_Obligations__c templateObligation = APTPS_TestClassData.templateObligationRecord('Test name', templateClause.id);

        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778908');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);

        Apttus_SRM__SRMObligation__c obligation = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        obligation.APTPS_Auto_Obligation__c = true;
        update obligation;

        Apttus__Agreement_Clause__c agmtClause = APTPS_TestClassData.agreementClauseRecord(agmt.id, templateClause.id);

        agmt.Apttus__Status_Category__c = 'In Signatures';
        agmt.Apttus__Status__c = 'Ready for Signatures';
        update agmt;
        System.assertEquals('Ready for Signatures',agmt.Apttus__Status__c);

        Test.startTest();
        agmt.Apttus__Status__c = 'Fully Signed';
        update agmt;
        System.assertEquals('Fully Signed',agmt.Apttus__Status__c);
        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for terminateObligation method.
    *******************************************************************/
    static testMethod void terminateObligation(){
        Savepoint sp = Database.setSavepoint();
        try{
            Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237708898');
            Apttus__APTS_Agreement__c agmtTerminated = APTPS_TestClassData.agreementRecord(acct.id);
            Apttus__APTS_Agreement__c agmtExpired = APTPS_TestClassData.agreementRecord(acct.id);
            Apttus_SRM__SRMObligation__c obligationTerm;
            Apttus_SRM__SRMObligation__c obligationExp;
            try{
                obligationTerm = APTPS_TestClassData.obligationRecord(agmtTerminated.id, acct.id);
                obligationExp = APTPS_TestClassData.obligationRecord(agmtExpired.id, acct.id);

                obligationExp.APTPS_Category__c = 'Post Termination Activity';
                obligationExp.APTPS_Status__c ='Terminated';
                update obligationExp;
                obligationTerm.APTPS_Status__c ='Terminated';
                update obligationTerm;
            }
            catch(Exception ex){
                Database.rollback(sp);
            }
            system.debug('cddsscds=='+obligationExp);
            Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test15');

            Task taskRecordTerminated = APTPS_TestClassData.taskRecord(userSA.id, obligationTerm.id, 'In Progress');
            Task taskRecordExpired = APTPS_TestClassData.taskRecord(userSA.id, obligationExp.id, 'In Progress');

            Test.startTest();

            agmtTerminated.Apttus__Status_Category__c = 'Terminated';
            agmtTerminated.Apttus__Status__c = 'Terminated';
            update agmtTerminated;

            agmtExpired.Apttus__Status_Category__c = 'Expired';
            agmtExpired.Apttus__Status__c = 'Expired';
            update agmtExpired;

            List<Apttus_SRM__SRMObligation__c> obligationList = [Select Id, Name, APTPS_Status__c FROM Apttus_SRM__SRMObligation__c
            WHERE (Id =:obligationExp.id Or id =: obligationTerm.id) And APTPS_Status__c = 'Terminated'];
            // system.assertEquals(1, obligationList.size());

            List<Task> taskList = [Select id, status, WhatId FROM Task WHERE Id=:taskRecordTerminated.id Or id=:taskRecordExpired.id];
            system.assertEquals(1, taskList.size());

            Test.stopTest();
        }
        catch(Exception ex){
            Database.rollback(sp);
        }
    }
    
    static testMethod void testAgreement(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237178898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
		List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt1  = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
		agmt1.Apttus__Status_Category__c = APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS;
		agmt1.Apttus__Status__c=APTPS_Constants.REQUEST_STATUS_CATEGORY_AND_STATUS;
		agmt1.Apttus__Version_Number__c =1;
        agmt1.APTPS_Is_Custom_Update__c = TRUE;
		//agmt1.APTPS_Obligations_Copied_After_Variation__c=FALSE;
		agreementList.add(agmt1);
		update agreementList;
		
		Test.startTest();
		agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS;
        agmt1.APTPS_Is_Custom_Update__c = FALSE;
		update agmt1;
        system.assertEquals(1, agreementList.size());
		Test.stopTest();
}
   
    static testMethod void accountChangeForAgreement(){
        Test.startTest();
        List<User> userRecordList = [select id from User where username='test@calms.com'];
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1457778898');
        Account acct1 = APTPS_TestClassData.accountRecord('Test Account', '9876543210');
        if(!userRecordList.isEmpty()){
            acct1.APTPS_Commercial_Manager__c = userRecordList[0].Id;
            acct1.APTPS_Contract_Manager__c = userRecordList[0].Id;
            update acct1;
        }
        Contact contact1 = APTPS_TestClassData.contactRecord(acct1.id);
        Contact contactCompanySignedBy = APTPS_TestClassData.contactRecord('George','Washington',acct1.id);
        Contact contactOtherPartySigned = APTPS_TestClassData.contactRecord('Robert','Downey',acct1.id);
        Test.stopTest();
        Contact contactCompanySignedBy1 = APTPS_TestClassData.contactRecord('Tom','Cruise',acct1.id);
        Contact contactOtherPartySigned1 = APTPS_TestClassData.contactRecord('Dwayne','Johnson',acct1.id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.Apttus__Company_Signed_By__c = contactCompanySignedBy.Id;
        agmt.Apttus__Other_Party_Signed_By__c = contactOtherPartySigned.Id;
        agmt.Apttus__Account__c = acct1.id;
        agmt.Apttus__Status_Category__c = 'In Authoring';
        agmt.Apttus__Status__c = 'Author Contract';
        update agmt;
        if(!userRecordList.isEmpty()){
            agmt.APTPS_Sales_Account_Executive__c = userRecordList[0].Id;
        }
        agmt.Apttus__Company_Signed_By__c = contactCompanySignedBy1.Id;
        agmt.Apttus__Other_Party_Signed_By__c = contactOtherPartySigned1.Id;
        update agmt;
        System.assert(agmt.Apttus__Account__c==acct1.id, true);
    }

    static testMethod void agreementWithOpportunity(){
        List<User> userRecordList = [select id from User where username='test@calms.com'];
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1540984321');
        if(!userRecordList.isEmpty()){
            acct.APTPS_Commercial_Manager__c = userRecordList[0].Id;
            acct.APTPS_Contract_Manager__c = userRecordList[0].Id;
            update acct;
        }
        Contact contact = APTPS_TestClassData.contactRecord(acct.id);
        Contact contactPrimaryContact = APTPS_TestClassData.contactRecord('George','Washington',acct.id);
        Test.startTest();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acct);
        insert opp;
        agmt.Apttus__Related_Opportunity__c = opp.Id;
        agmt.Apttus__Status_Category__c = 'In Authoring';
        agmt.Apttus__Status__c = 'Author Contract';
        update agmt;
        if(!userRecordList.isEmpty()){
            opp.OwnerId = userRecordList[0].Id;
            update opp;
        }
        agmt.APTPS_Customer_Primary_Contact__c = contactPrimaryContact.Id;
        update agmt;
        List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSign = [select Id, Apttus_DocuApi__FirstName__c, Apttus_DocuApi__LastName__c,
                Apttus_DocuApi__Email__c, Apttus_DocuApi__EmailTemplateUniqueName__c, Apttus_DocuApi__RoleName__c,
                RecordTypeId, Apttus_DocuApi__RecipientType__c, Apttus_DocuApi__SigningOrder__c,
                Apttus_CMDSign__AgreementId__c from Apttus_DocuApi__DocuSignDefaultRecipient2__c
        where Apttus_CMDSign__AgreementId__c = : agmt.Id and Apttus_CMDSign__AgreementId__c = :APTPS_Constants.DOCUSIGN_SIGNER_1];
        if(!docuSign.isEmpty() && !userRecordList.isEmpty()){
            System.assert(docuSign[0].Apttus_DocuApi__Email__c == userRecordList[0].email, true);
        }
        Test.stopTest();
    }

    /******************************************************************
    @Description:This testMethod is for activateLegacyAgreement method.
    *******************************************************************/
    static testMethod void activateLegacyAgreement(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1457778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');

        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1Conformed-Agreement', childAgmt1.id);
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Conformed-Agreement', childAgmt2.id);

        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Filing';
        agmt.APTPS_Legacy_Agreement__c = childAgmt1.APTPS_Legacy_Agreement__c = childAgmt2.APTPS_Legacy_Agreement__c = true;
        update agmt;
        update childAgmt1;
        update childAgmt2;

        /*List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);*/

        Test.startTest();

        //APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        //handler.activateLegacyAgreement(agreementList);

        agmtAttachment1.Name = 'acct-agmt_Original_signed.pdf';
        update agmtAttachment1;

        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);
        //handler.activateLegacyAgreement(agreementList);

        update agreementList;
        System.assertEquals(3,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);
        Test.stopTest();
    }
    static testMethod void createMinimumSpendEntries(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237178898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
		List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt1  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c agmt2  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c agmt3  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        agmt1.Apttus__Term_Months__c = agmt2.Apttus__Term_Months__c = agmt3.Apttus__Term_Months__c = 36;
        agmt1.Apttus__Parent_Agreement__c = agmt2.Apttus__Parent_Agreement__c = agmt3.Apttus__Parent_Agreement__c = agmt.id;
        agmt1.Apttus__Contract_Start_Date__c = agmt2.Apttus__Contract_Start_Date__c = agmt3.Apttus__Contract_Start_Date__c = Date.newInstance(2015, 7, 10);
		agreementList.add(agmt1);
		agreementList.add(agmt2);
		agreementList.add(agmt3);
        update agreementList;

		List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c agreementLineItem1 = APTPS_TestClassData.agreementLineItemRecord(agmt1.Id, null);
        Apttus__AgreementLineItem__c agreementLineItem2 = APTPS_TestClassData.agreementLineItemRecord(agmt2.Id, null);
        Apttus__AgreementLineItem__c agreementLineItem3 = APTPS_TestClassData.agreementLineItemRecord(agmt3.Id, null);
        agreementLineItem1.APTPS_Product_Minimum_Spend__c = agreementLineItem2.APTPS_Product_Minimum_Spend__c = agreementLineItem3.APTPS_Product_Minimum_Spend__c = 10;
        agreementLineItem1.APTPS_frequency__c = 'Quarter';
        agreementLineItem2.APTPS_frequency__c = 'Month';
        agreementLineItem3.APTPS_frequency__c = 'Annual';
		agreementLineItemList.add(agreementLineItem1);
		agreementLineItemList.add(agreementLineItem2);
		agreementLineItemList.add(agreementLineItem3);
        update agreementLineItemList;

        Test.startTest();

        agmt1.Apttus__Status_Category__c = agmt2.Apttus__Status_Category__c = agmt3.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY;
        agmt1.Apttus__Status__c = agmt2.Apttus__Status__c = agmt3.Apttus__Status__c = APTPS_Constants.IN_EFFECT_STATUS;
        update agreementList;
        Map<ID, Apttus__AgreementLineItem__c> mapAgmtLI = new Map<ID, Apttus__AgreementLineItem__c>([select id from Apttus__AgreementLineItem__c]);
        System.assertEquals(3,mapAgmtLI.size());
        System.assertEquals(true,mapAgmtLI.containsKey(agreementLineItem1.id));
        System.assertEquals(4,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);
        Test.stopTest();

    }
    static testMethod void agreementDocusignRecipientsNDA(){
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
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);

        Test.startTest();

        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient1 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 1', 1);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient2 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 2', 2);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient3 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 3', 3);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient4 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 4', 4);

        //agmt.APTPS_Sales_Account_Executive__c = telstraContact.id;
        agmt.Apttus__Status_Category__c = 'In Authoring';
        agmt.Apttus__Status__c = 'Author Contract';
        agmt.APTPS_Customer_Primary_Contact__c = con3.id;

        update agmt;

        agmt.APTPS_SecAcnt_Primary_Contact__c = con4.id;
        update agmt;

        agmt.Apttus__Agreement_Category__c = 'Mutual';
        update agmt;
        System.assertEquals(1,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);
        Test.stopTest();
    }
    static testMethod void agreementDocusignRecipientsSupporting(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);

        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementSupporting(acct.id, con.id, 'MOU');

        Test.startTest();

        agmt.Apttus__Agreement_Category__c = 'Release';
        update agmt;
        Map<ID, Apttus__APTS_Agreement__c> mapAgmt = new Map<ID, Apttus__APTS_Agreement__c>([select id from Apttus__APTS_Agreement__c]);
        System.assertEquals(1,mapAgmt.size());
        System.assertEquals(true,mapAgmt.containsKey(agmt.id));
        Test.stopTest();
    }
    /*
    updateDocuSignAccountSalesExecutive
        docuSignRecipientsAccountExecutive
        salesAccountExecutiveMap

    updateDocuSignAccountContacts
        docuSignRecipientsPrimaryContact
        agreementPrimaryContactMap

    updateDocuSignAccountContacts
        docuSignRecipientsSecondaryContact
        agreementSecondaryContactMap

    createDocuSignRecipients/reCreateDocuSignRecipients
        agreementListForDocuSignRecipients
        salesAccountExecutiveIds
        agreementPrimaryContactIds
        agreementSecondaryContactIds

    populatePricingSpecialistForPricingUser
        agreementListForPricingSpecialists
        agreementCreatedByUsers

    not used anywhere
        agreementListToReCreateDocuSignRecipients
        salesAccountExecutiveIdsToReCreateDocuSignRecipients
        agreementPrimaryContactIdsToReCreateDocuSignRecipients
        agreementSecondaryContactIdsToReCreateDocuSignRecipients
    */
    /*static testMethod void updateChildOwners(){
        Profile contractManager = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User userCM = new User(Alias = 'TestCM', Email='testUserCM@testorg.com',
                EmailEncodingKey='UTF-8', LastName='UserCM', LanguageLocaleKey='en_US',
                LocaleSidKey='en_AU', ProfileId = contractManager.Id, CommunityNickname = 'TUCM',
                TimeZoneSidKey='Australia/Sydney', UserName='testUserContractMgr18@testorg.com.japan');

        insert userCM;

        Group[] ccoCentral = [Select Id from Group where Type = 'Queue' AND Name =: APTPS_Constants.CCO_CENTRAL_QUEUE];
        System.debug('cco::'+ccoCentral);
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1211008898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);

        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.OwnerId = ccoCentral[0].id;
        update agmt;

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
        update childAgmt2;

        Test.startTest();

        agmt.OwnerId = userCM.id;
        update agmt;
        Map<ID, Apttus__APTS_Agreement__c> mapAgmt = new Map<ID, Apttus__APTS_Agreement__c>();
        mapAgmt.put(agmt.Id,agmt);
        mapAgmt.put(childAgmt1.Id,childAgmt1);
        mapAgmt.put(childAgmt2.Id,childAgmt2);
        System.assertEquals(3,mapAgmt.size());
        Test.stopTest();
    }*/
    /******************************************************************
    @Description:This testMethod is for populateEndDates method.
    *******************************************************************/
    static testMethod void populateEndDates(){

        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);

        //Map<id, Apttus__APTS_Agreement__c> mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        //mapOldAgreement.put(agmt.id, agmt);

        //List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        //agreementList.add(agmt);

        Test.startTest();

        //Scenario 1
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 10, 11);
        agmt.Apttus__Term_Months__c = 4;
        update agmt;

        //APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        //handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);

        Apttus__APTS_Agreement__c updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c
        where Id =:agmt.id Limit 1];
        //system.assertEquals(updatedAgmt.Apttus__Company_Signed_Date__c, updatedAgmt.Apttus__Contract_Start_Date__c);
        //system.assertEquals(Date.newInstance(2017, 2, 11), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);

        //Scenario 2

        //mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        //mapOldAgreement.put(agmt.id, agmt);

        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 1);
        agmt.Apttus__Term_Months__c = 2;
        update agmt;
        //agreementList = new List<Apttus__APTS_Agreement__c>();
        //agreementList.add(agmt);

        //handler = new APTPS_AgreementTriggerHandler();
        //handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);

        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c
        where Id =:agmt.id Limit 1];
        //system.assertEquals(updatedAgmt.Apttus__Company_Signed_Date__c, updatedAgmt.Apttus__Contract_Start_Date__c);
        //system.assertEquals(Date.newInstance(2016, 3, 1), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);

        //Scenario 3

        //mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        //mapOldAgreement.put(agmt.id, agmt);

        agmt.Apttus__Term_Months__c = 1;
        update agmt;
        //agreementList = new List<Apttus__APTS_Agreement__c>();
        //agreementList.add(agmt);

        //handler = new APTPS_AgreementTriggerHandler();
        //handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);

        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c
        where Id =:agmt.id Limit 1];
        //system.assertEquals(Date.newInstance(2016, 2, 1), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);

        //Scenario 4

        //mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        //mapOldAgreement.put(agmt.id, agmt);

        agmt.Apttus__Company_Signed_Date__c = null;
        update agmt;
        //agreementList = new List<Apttus__APTS_Agreement__c>();
        //agreementList.add(agmt);

        //handler = new APTPS_AgreementTriggerHandler();
        //handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);

        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c
        where Id =:agmt.id Limit 1];
        system.assertEquals(null, updatedAgmt.Apttus__Contract_Start_Date__c);
        //system.assertEquals(null, updatedAgmt.Apttus__Contract_End_Date__c);
        //system.assertEquals(null, updatedAgmt.APTPS_Effective_End_Date__c);

        //Scenario 5

        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 1);
        agmt.Apttus__Term_Months__c = null;
        agmt.Apttus__Contract_End_Date__c = Date.newInstance(2017, 1, 1);
        update agmt;

        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c
        where Id =:agmt.id Limit 1];
        //system.assertEquals(updatedAgmt.Apttus__Contract_End_Date__c, updatedAgmt.APTPS_Effective_End_Date__c);
        //system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);

        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for showing the not ediatble validation for specific scenarios for functionalities.
    *******************************************************************/
    static testMethod void notEditableValidation(){

        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
		Account acct2 = APTPS_TestClassData.accountRecord('Secondary Account', '1237898898');
		List<Contact> contactList = new List<Contact>();
		Contact con = TestUtil.createContact(acct.id,'George','Washington');
        Contact con2 = TestUtil.createContact(acct2.id,'Robert','Downey');
		contactList.add(con);
		contactList.add(con2);
		insert contactList;
		List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementSupporting(acct.id,con.id,'MOU');
        Apttus__APTS_Agreement__c agmtNDA = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);
        agmt.Apttus__Status_Category__c = agmtNDA.Apttus__Status_Category__c = '    In Signatures';
        agmt.Apttus__Status__c = agmtNDA.Apttus__Status__c =  'Fully Signed';
		agreementList.add(agmt);
		agreementList.add(agmtNDA);
        update agreementList;

        Test.startTest();

        try{
            //Scenario 1 - when status is Fully Signed and Record type is Supporting Agreement.
            agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 10, 11);
            agmt.Apttus__Term_Months__c = 4;
			agmtNDA.Reason_for_Rolling_Other__c = 'test';
            agmtNDA.Apttus__Term_Months__c = 4;
            update agreementList;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            if(!expectedExceptionThrown){
                expectedExceptionThrown =  e.getMessage().contains('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.') ? true : false;
            }
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }

    /*static testMethod void terminateChildAgreements(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementRecord(acct.id);

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');

        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'Request';
        agmt2.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Request';
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt2.Apttus__Parent_Agreement__c = agmt2.id;
        childAgmt1.APTPS_Is_Custom_Update__c = childAgmt2.APTPS_Is_Custom_Update__c = true;
        update agmt;
        update agmt2;
        update childAgmt1;
        update childAgmt2;

        Test.startTest();

        agmt.Apttus__Status_Category__c = 'Terminated';
        agmt.Apttus__Status__c = 'Terminated';

        update agmt;

        agmt2.Apttus__Status_Category__c = 'Expired';
        agmt2.Apttus__Status__c = 'Expired';

        update agmt2;
        Map<ID, Apttus__APTS_Agreement__c> mapAgmt = new Map<ID, Apttus__APTS_Agreement__c>();
        mapAgmt.put(agmt.Id,agmt);
        mapAgmt.put(agmt2.Id,agmt2);
        mapAgmt.put(childAgmt1.Id,childAgmt1);
        mapAgmt.put(childAgmt2.Id,childAgmt2);
        System.assertEquals(4,mapAgmt.size());
        System.assertEquals(true,mapAgmt.containsKey(agmt.ID));
        System.assertEquals(true,mapAgmt.containsKey(agmt2.ID));

        Test.stopTest();
    }*/

    static testMethod void fundDataAgreements(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Fund__c fund= APTPS_TestClassData.fundRecord(agmt.Id, 'Growth');

        agmt.Apttus__Contract_Start_Date__c=system.today();
        agmt.Apttus__Contract_End_Date__c = system.today().addYears(1);

        agmt.Apttus__Status_Category__c = 'In Effect';
        agmt.Apttus__Status__c = 'Activated';

        update agmt;

        Test.startTest();

        agmt.Apttus__Status_Category__c = 'Request';
        agmt.Apttus__Status__c = 'Request';
        update agmt;
        list<Apttus__APTS_Agreement__c> agreement = [select id,Apttus__Status_Category__c,Apttus__Status__c from Apttus__APTS_Agreement__c];
        System.assertEquals(1,agreement.size());
        System.assertEquals('Request',agreement[0].Apttus__Status_Category__c);
        System.assertEquals('Request',agreement[0].Apttus__Status__c);
        Test.stopTest();
    }
    /*static testMethod void deleteAgreements(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementRecord(acct.id);

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');

        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'Request';
        agmt2.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Request';
        childAgmt1.Apttus__Version_Number__c =  childAgmt2.Apttus__Version_Number__c = 1;
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt2.Apttus__Parent_Agreement__c = agmt2.id;
        agmt.Apttus__Parent_Agreement__c = childAgmt1.id;
        agmt2.Apttus__Parent_Agreement__c = childAgmt2.id;
        childAgmt1.APTPS_Is_Custom_Update__c = childAgmt2.APTPS_Is_Custom_Update__c = true;
        update agmt;
        update agmt2;
        update childAgmt1;
        update childAgmt2;
        Map<ID, Apttus__APTS_Agreement__c> mapAgmt = new Map<ID, Apttus__APTS_Agreement__c>();
        mapAgmt.put(agmt.Id,agmt);
        mapAgmt.put(agmt2.Id,agmt2);
        mapAgmt.put(childAgmt1.Id,childAgmt1);
        mapAgmt.put(childAgmt2.Id,childAgmt2);
        System.assertEquals(4,mapAgmt.size());
        System.assertEquals(true,mapAgmt.containsKey(childAgmt1.ID));
        Test.startTest();

        delete childAgmt1;
        delete childAgmt2;
        Map<ID, Apttus__APTS_Agreement__c> mapAgmtDel = new Map<ID, Apttus__APTS_Agreement__c>();
        mapAgmtDel.put(childAgmt1.Id,childAgmt1);
        mapAgmtDel.put(childAgmt2.Id,childAgmt2);
        System.assertEquals(2,mapAgmtDel.size());
        Test.stopTest();
    }*/

    /*static testMethod void  testhandleBeforeInsertEvents(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1457778898');
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account1', '1457778899');

        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        Contact con1 = TestUtil.createContact(acct.id,'Roger','Fedrer');
        insert con1;

       // acct1.APTPS_Contract_Manager__c=con1.id;
      //  acct1.APTPS_Sales_Account_Executive__c=con1.Id;
        update acct1;

        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c AgreementRecord = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = acct.id);
        AgreementRecord.Apttus__Parent_Agreement__c= agmt.id;
        AgreementRecord.Apttus__Company_Signed_By__c=con.id;
        Test.startTest();
        insert AgreementRecord;
        AgreementRecord.Apttus__Company_Signed_By__c=con1.id;
        AgreementRecord.Apttus__Other_Party_Signed_By__c=con.id;
        update AgreementRecord;
        agmt.Apttus__Account__c= acct1.id;
        agmt.APTPS_Validation_on_Fully_Signed__c=true;
        agmt.Apttus__Version_Number__c = 1;
        agmt.Apttus__Status__c = 'Fully Signed';

     //   agmt.APTPS_Sales_Account_Executive__c=telstraContact.Id;
     //   agmt.APTPS_Contract_Manager__c=con1.id;
    //    agmt.APTPS_Sales_Account_Executive__c=con1.Id;
        update agmt;
        list<Apttus__APTS_Agreement__c> agreement = [select id,Apttus__Parent_Agreement__c,Apttus__Status__c from Apttus__APTS_Agreement__c order by createddate ASC];
        System.assertEquals(2,agreement.size());
        System.assertEquals(agreement[0].id,agreement[1].Apttus__Parent_Agreement__c);
        System.assertEquals('Fully Signed',agreement[0].Apttus__Status__c);
        Test.stopTest();

    }*/


    /*static testMethod void  testUpdateOnSchedules(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementRecord(acct.id);

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');

        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Effect';
        agmt2.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Rolling';
        agmt.Apttus__Contract_End_Date__c = system.today();
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt2.Apttus__Parent_Agreement__c = agmt2.id;
        childAgmt1.Apttus__Contract_End_Date__c = system.today();
        childAgmt2.Apttus__Contract_End_Date__c = system.today();
        childAgmt1.APTPS_Effective_End_Date_For_Min_Spend__c= system.today().addDays(-30);
        childAgmt1.APTPS_Effective_End_Date__c = system.today().addDays(-20);


        update agmt;
        update agmt2;
        update childAgmt1;
        update childAgmt2;

        Test.startTest();

        agmt.APTPS_Effective_End_Date__c = system.today();

        update childAgmt1;
        List<ID> parentAgmtID = New list<ID>();
        parentAgmtID.add(agmt.id);
        parentAgmtID.add(agmt2.id);
        System.assertEquals(2,parentAgmtID.size());
        Test.stopTest();
    }*/

    static testMethod void agreementsWithSalesAcExecChange(){
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

        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);

        Test.startTest();

        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient1 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 1', 1);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient2 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 2', 2);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient3 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 3', 3);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient4 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 4', 4);
        Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        //agmt.APTPS_Sales_Account_Executive__c = telstraContact.id;
        agmt.Apttus__Status_Category__c = 'In Authoring';
        agmt.Apttus__Status__c = 'Author Contract';
        agmt.APTPS_Customer_Primary_Contact__c = con3.id;
        agmt.RecordTypeId= saRecordTypeId;
        update agmt;


        Test.stopTest();
    }

    static testMethod void agreementsWithndaRecordTypeId(){
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

        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);

        Test.startTest();

        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient1 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 1', 1);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient2 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 2', 2);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient3 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 3', 3);
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient4 = APTPS_TestClassData.docuSignRecipientRecord(agmt.id, 'Signer 4', 4);
        Id ndaRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
        //agmt.APTPS_Sales_Account_Executive__c = telstraContact.id;
        agmt.Apttus__Status_Category__c = 'In Authoring';
        agmt.Apttus__Status__c = 'Author Contract';
        agmt.APTPS_Customer_Primary_Contact__c = con3.id;

        update agmt;

        Test.stopTest();
    }

   /* static testMethod void  testOnSchedules(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '4337778898');
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
		List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Effect';
        agmt2.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Rolling';
        childAgmt1.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt2.Apttus__Parent_Agreement__c = agmt2.id;
        childAgmt1.Apttus__Contract_End_Date__c = system.today();
        childAgmt2.Apttus__Contract_End_Date__c = system.today();
        childAgmt1.APTPS_Schedule_Number_Text__c = '1.a';
        agmt.Apttus__Contract_End_Date__c = system.today();
		agreementList.add(agmt);
		agreementList.add(agmt2);
		agreementList.add(childAgmt1);
		agreementList.add(childAgmt2);
        update agreementList;
        Test.startTest();
        childAgmt1.APTPS_Schedule_Number_Text__c = '1.b';
        update childAgmt1;
        List<ID> parentAgmtID = New list<ID>();
        parentAgmtID.add(agmt.id);
        parentAgmtID.add(agmt2.id);
        System.assertEquals(2,[SELECT COUNT() FROM Apttus__APTS_Agreement__c WHERE Apttus__Parent_Agreement__c IN: parentAgmtID]);
        Test.stopTest();
    } */
    /************Mahendra********** */
  /*  static testMethod void activateLegacyAgreementch(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1457778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');



        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1Conformed-Agreement', childAgmt1.id);
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Conformed-Agreement', childAgmt2.id);

        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Filing';
        agmt.APTPS_Legacy_Agreement__c = childAgmt1.APTPS_Legacy_Agreement__c = childAgmt2.APTPS_Legacy_Agreement__c = true;
        childAgmt1.Apttus__Term_Months__c =10.0;
        update agmt;
        update childAgmt1;
        update childAgmt2;
        Map<id,Apttus__APTS_Agreement__c > maptest = new  Map<id,Apttus__APTS_Agreement__c >();
        Map<Id, Date> datemap = new Map<Id, Date>();
        List<Apttus__APTS_Agreement__c> lstchildagmt11 = New List<Apttus__APTS_Agreement__c>();
        lstchildagmt11.add(childAgmt1);
        lstchildagmt11.add(childAgmt2);
        maptest.put(childAgmt1.id,childAgmt1);
        datemap.put(childAgmt1.id,system.Today());
        Apttus__APTS_Agreement__c childagmt111  = new Apttus__APTS_Agreement__c();
        childagmt111.Name = 'Testagreement';
        childagmt111.Apttus__Term_Months__c =10.0;
        //childagmt111.RecordTypeId = 'supportingAgreementRecordTypeId';
        childagmt111.Apttus__Agreement_Category__c ='Multi-Party';
        //childagmt11.Id = childAgmt1.id;
        insert childagmt111;

        /*agmt.RecordTypeId = 'saRecordTypeId';

    childAgmt1.APTPS_ED_Filter_Checklist_Required__c = true;
    childAgmt1.Apttus__Total_Contract_Value__c = 10000001;
    childAgmt1.Apttus__Agreement_Category__c = 'Global Services' ; */


        /*List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);*/

        /*Test.startTest();

        //APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        //handler.activateLegacyAgreement(agreementList);

        agmtAttachment1.Name = 'acct-agmt_Original_signed.pdf';
        update agmtAttachment1;

        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);
        update agreementList;
        Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
        Product2 prod2 = APTPS_TestClassData.productRecord('Wireless ');
        Product2 prod3 = APTPS_TestClassData.productRecord('Wireless M2M ');
        Product2 prod4 = APTPS_TestClassData.productRecord('Wireless M2M Control ');
        Apttus__AgreementLineItem__c lineitem = new Apttus__AgreementLineItem__c();
        lineitem.Apttus__AgreementId__c = childagmt111.id;
        lineitem.Apttus__ProductId__c= prod1.id;
        insert lineitem;
        Apttus__AgreementLineItem__c lineitem1 = new Apttus__AgreementLineItem__c();
        lineitem1.Apttus__AgreementId__c = childagmt111.id;
        lineitem.Apttus__ProductId__c= prod2.id;
        insert lineitem1;
        Apttus__AgreementLineItem__c lineitem2 = new Apttus__AgreementLineItem__c();
        lineitem2.Apttus__AgreementId__c = childAgmt1.id;
        lineitem.Apttus__ProductId__c= prod3.id;
        insert lineitem2;
        Apttus__AgreementLineItem__c lineitem3 = new Apttus__AgreementLineItem__c();
        lineitem3.Apttus__AgreementId__c = childAgmt2.id;
        lineitem.Apttus__ProductId__c= prod4.id;
        insert lineitem3;

        APTPS_AgreementTriggerService APTPS_AgreementTriggerService1 = new APTPS_AgreementTriggerService();
        APTPS_AgreementTriggerService1.updateEffectiveEndDatesandMinimumSpend(agreementList);
        APTPS_AgreementMSEService agreementService = new APTPS_AgreementMSEService();
        agreementService.createMinimumSpendEntriesAtRollover(maptest, datemap);
        update agreementList;
        System.assertNotEquals(0,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);
        // Apttus__APTS_Agreement__c updatedAgmt2 = [Select Id, RecordTypeId, APTPS_ED_Filter_Checklist_Required__c,Apttus__Total_Contract_Value__c from Apttus__APTS_Agreement__c where id = :agmt1.id Limit 1];
        //system.assertEquals(true,childAgmt1.APTPS_ED_Filter_Checklist_Required__c);
        Test.stopTest();
    }
*/
    /************Mahendra********** */
 /*   static testMethod void copyObligationFromParentAgreement1(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1457778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();

        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');



        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1Conformed-Agreement', childAgmt1.id);
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Conformed-Agreement', childAgmt2.id);

        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Filing';
        agmt.APTPS_Legacy_Agreement__c = childAgmt1.APTPS_Legacy_Agreement__c = childAgmt2.APTPS_Legacy_Agreement__c = true;
        childAgmt1.Apttus__Term_Months__c =10.0;
        update agmt;
        update childAgmt1;
        update childAgmt2;
        Map<id,Apttus__APTS_Agreement__c > maptest = new  Map<id,Apttus__APTS_Agreement__c >();
        Map<Id, Date> datemap = new Map<Id, Date>();
        List<Apttus__APTS_Agreement__c> lstchildagmt11 = New List<Apttus__APTS_Agreement__c>();
        lstchildagmt11.add(childAgmt1);
        lstchildagmt11.add(childAgmt2);
        maptest.put(childAgmt1.id,childAgmt1);
        datemap.put(childAgmt1.id,system.Today());
        Apttus__APTS_Agreement__c childagmt111  = new Apttus__APTS_Agreement__c();
        childagmt111.Name = 'Testagreement';
        childagmt111.Apttus__Term_Months__c =10.0;

        childagmt111.Apttus__Agreement_Category__c ='Multi-Party';
        insert childagmt111;
        Test.startTest();
        agmtAttachment1.Name = 'acct-agmt_Original_signed.pdf';
        update agmtAttachment1;

        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);
        update agreementList;
        Product2 prod1 = APTPS_TestClassData.productRecord('Business IP');
        Product2 prod2 = APTPS_TestClassData.productRecord('Wireless ');
        Product2 prod3 = APTPS_TestClassData.productRecord('Wireless M2M ');
        Product2 prod4 = APTPS_TestClassData.productRecord('Wireless M2M Control ');
        Apttus__AgreementLineItem__c lineitem = APTPS_TestClassData.agreementLineItemRecord(childagmt111.id,prod1.id);
        Apttus__AgreementLineItem__c lineitem1 = APTPS_TestClassData.agreementLineItemRecord(childagmt111.id,prod1.id);
        Apttus__AgreementLineItem__c lineitem2 = APTPS_TestClassData.agreementLineItemRecord(childAgmt1.id,prod1.id);
        Apttus__AgreementLineItem__c lineitem3 =APTPS_TestClassData.agreementLineItemRecord(childAgmt2.id,prod1.id);
        Set<Id> resultIds = (new Map<Id,SObject>(agreementList)).keySet();
        APTPS_AgreementTriggerService APTPS_AgreementTriggerService1 = new APTPS_AgreementTriggerService();
        APTPS_AgreementTriggerService1.updateEffectiveEndDatesandMinimumSpend(agreementList);
        APTPS_AgreementMSEService agreementService = new APTPS_AgreementMSEService();
        agreementService.createMinimumSpendEntriesAtRollover(maptest, datemap);
        update agreementList;
        Apttus__APTS_Admin__c varad1=new Apttus__APTS_Admin__c(Name='APTS_VariationConfig',Apttus__Value__c = 'XML',Apttus__Code__c = '<VariationsConfig><ReparentedObjects><ChildObject><Name>APTPS_Related_Companies__c</Name><RelationField>APTPS_Agreement__c</RelationField></ChildObject><ChildObject><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__Agreement__c</RelationField></ChildObject><ChildObject><Name>Fund__c</Name><RelationField>Agreement__c</RelationField></ChildObject></ReparentedObjects><ClonedObjects><ChildObject><Name>Apttus__AgreementLineItem__c</Name><RelationField>Apttus__AgreementId__c</RelationField><GrandChildReparented><Name>APTPS_Minimum_Spend_Entry__c</Name><RelationField>APTPS_Agreement_Line_Item__c</RelationField><ChildRelationship>Minimum_Spend__r</ChildRelationship></GrandChildReparented><GrandChildCloned><Name>APTPS_Component__c</Name><RelationField>Agreement_Line_Item__c</RelationField><ChildRelationship>Components__r</ChildRelationship></GrandChildCloned></ChildObject><ChildObject><Name>Apttus_SRM__SRMObligation__c</Name><RelationField>Apttus_SRM__AgreementId__c</RelationField><GrandChildReparented><Name>Apttus_SRM__Issue__c</Name><RelationField>Apttus_SRM__ObligationId__c</RelationField><ChildRelationship>Apttus_SRM__Issues__r</ChildRelationship></GrandChildReparented><GrandChildReparented><Name>Task</Name><RelationField>Whatid</RelationField><ChildRelationship>Tasks</ChildRelationship></GrandChildReparented></ChildObject></ClonedObjects><ClearFields><ClearField><Name>Apttus_Approval__Term_Exception_Approval_Status__c</Name></ClearField><ClearField><Name>APTPS_Pricing_Approval_Needed__c</Name></ClearField><ClearField><Name>Apttus_Approval__Approval_Status__c</Name></ClearField><ClearField><Name>Apttus__Contract_Start_Date__c</Name></ClearField><ClearField><Name>Apttus__Contract_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Term_Months__c</Name></ClearField><ClearField><Name>APTPS_Effective_End_Date__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Other_Party_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_By__c</Name></ClearField><ClearField><Name>Apttus__Company_Signed_Date__c</Name></ClearField><ClearField><Name>Apttus__Activated_By__c</Name></ClearField><ClearField><Name>Apttus__Activated_Date__c</Name></ClearField><ClearField><Name>Apttus__Special_Terms__c</Name></ClearField></ClearFields></VariationsConfig>');insert varad1;
        APTPS_AgreementTriggerService1.reparentObjectsForAmendment(resultIds);

        Apttus_SRM__SRMObligation__c obligationRecord1 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        Apttus_SRM__SRMObligation__c obligationRecord2 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        APTPS_AgreementTriggerService1.copyObligationFromParentAgreement(resultIds);
        System.assertEquals(4,[SELECT COUNT() FROM Product2]);
        Test.stopTest();
    }*/

    static testMethod void createMinimumSpendEntriesAtRoll(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237178898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
		List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt1  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c agmt2  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c agmt3  = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        agmt1.Apttus__Term_Months__c = agmt2.Apttus__Term_Months__c = agmt3.Apttus__Term_Months__c = 36;
        agmt1.Apttus__Parent_Agreement__c = agmt2.Apttus__Parent_Agreement__c = agmt3.Apttus__Parent_Agreement__c = agmt.id;
        agmt1.Apttus__Contract_Start_Date__c = agmt2.Apttus__Contract_Start_Date__c = agmt3.Apttus__Contract_Start_Date__c = Date.newInstance(2015, 7, 10);
		agreementList.add(agmt1);
		agreementList.add(agmt2);
		agreementList.add(agmt3);
        update agreementList;

		List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c agreementLineItem1 = APTPS_TestClassData.agreementLineItemRecord(agmt1.Id, null);
        Apttus__AgreementLineItem__c agreementLineItem2 = APTPS_TestClassData.agreementLineItemRecord(agmt2.Id, null);
        Apttus__AgreementLineItem__c agreementLineItem3 = APTPS_TestClassData.agreementLineItemRecord(agmt3.Id, null);
        agreementLineItem1.APTPS_Product_Minimum_Spend__c = agreementLineItem2.APTPS_Product_Minimum_Spend__c = agreementLineItem3.APTPS_Product_Minimum_Spend__c = 10;
        agreementLineItem1.APTPS_frequency__c = 'Quarter';
        agreementLineItem2.APTPS_frequency__c = 'Month';
        agreementLineItem3.APTPS_frequency__c = 'Annual';
		agreementLineItemList.add(agreementLineItem1);
		agreementLineItemList.add(agreementLineItem2);
		agreementLineItemList.add(agreementLineItem3);
        update agreementLineItemList;

        Test.startTest();

        agmt1.Apttus__Status_Category__c = agmt2.Apttus__Status_Category__c = agmt3.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = agmt2.Apttus__Status__c = agmt3.Apttus__Status__c = 'Rolling';
		update agreementList;
        Map<id,Apttus__APTS_Agreement__c > maptest = new  Map<id,Apttus__APTS_Agreement__c >();
        Map<Id, Date> datemap = new Map<Id, Date>();
        maptest.put(agmt1.id,agmt1);
        maptest.put(agmt2.id,agmt2);
        maptest.put(agmt3.id,agmt3);
        datemap.put(agmt1.id,system.Today());
        datemap.put(agmt2.id,system.Today());
        datemap.put(agmt3.id,system.Today());
        //APTPS_AgreementTriggerService APTPS_AgreementTriggerService1 = new APTPS_AgreementTriggerService();
        //APTPS_AgreementTriggerService1.createMinimumSpendEntriesAtRollover(maptest, datemap);
        System.assertNotEquals(0,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);
        Test.stopTest();

    }
    /******************************************************************
@Description:This testMethod is for ED Derivated checklist
*******************************************************************/
    static testMethod void embeddedDerivaties(){

        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct1.id);
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        agmt1.RecordTypeId = saRecordTypeId ;
        //agmt1.APTPS_ED_Filter_Checklist_Required__c = true;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;
        agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c ='Activated';
        agmt1.APTPS_Obligations_Copied_After_Variation__c = null;
        agmt1.Apttus__Status__c = 'Fully Signed';
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Status__c = 'FULLY_SIGNED_STATUS';
        agmt1.APTPS_Obligations_Copied_After_Variation__c = null;


        List<Apttus__APTS_Agreement__c> agreementList1 = new List<Apttus__APTS_Agreement__c>();
        agreementList1.add(agmt1);

        Test.startTest();

        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();

        Apttus__APTS_Agreement__c updatedAgmt1 = [Select Id, RecordTypeId, APTPS_Validation_on_Fully_Signed__c,APTPS_ED_Filter_Checklist_Required__c,Apttus__Total_Contract_Value__c,APTPS_Obligations_Copied_After_Variation__C,Apttus__Termination_Date__c,
                APTPS_Title__c from Apttus__APTS_Agreement__c where id = :agmt1.id Limit 1];

        system.assertEquals(false, updatedAgmt1.APTPS_ED_Filter_Checklist_Required__c);
        system.assertEquals(false,  updatedAgmt1.APTPS_Obligations_Copied_After_Variation__C);
        system.assertEquals(false,  updatedAgmt1.APTPS_Validation_on_Fully_Signed__c);
        system.assertEquals(updatedAgmt1.APTPS_Title__c, updatedAgmt1.APTPS_Title__c);


        Test.stopTest();
    }
    /******************************************************************
    @Description:EDGE-76047,19.05  APTPS_ED_Filter_Checklist_Required__c flag to true
 *******************************************************************/
    static testMethod void embeddedDerivatiesForNonStdCSA(){

        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct1.id);
        agmt1.Apttus__Agreement_Number__c = '2323';
        agmt1.Apttus__Company_Signed_Date__c = Date.today();
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        agmt1.RecordTypeId = saRecordTypeId ;
        agmt1.Apttus__Total_Contract_Value__c = 300000001;
        agmt1.Apttus__Agreement_Category__c = 'Corporate Services Agreement' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c ='Activated';
        agmt1.Apttus__Status__c = 'Fully Signed';
        Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Template', 'Clause');
        Apttus__Agreement_Clause__c agmtClause = new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause', Apttus__Agreement__c = agmt1.id,
                Approval_Status__c='Approval Required',Apttus__Active__c = true, Apttus__Category__c = 'default',
                Apttus__Subcategory__c = 'Default', APTPS_Non_Standard_Legal_Language__c= true ,Apttus__Action__c = 'Inserted', Apttus__Text__c = 'test',Apttus__Template__c = templateClause.id);
        insert agmtClause;
        update agmt1;

        List<Apttus__APTS_Agreement__c> agreementList1 = new List<Apttus__APTS_Agreement__c>();
        agreementList1.add(agmt1);
        Test.startTest();
        APTPS_AgreementTriggerService APTPS_AgreementTriggerService1 = new APTPS_AgreementTriggerService();
        List<Id> agreementIdEDs = new List<Id>();
        agreementIdEDs.add(agmt1.Id);
        APTPS_AgreementTriggerService1.updateEDFilterchecklistFlag(agreementList1,agreementIdEDs);
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();

        Apttus__APTS_Agreement__c updatedAgmt1 = [Select Id, RecordTypeId, APTPS_Validation_on_Fully_Signed__c,APTPS_ED_Filter_Checklist_Required__c,Apttus__Total_Contract_Value__c,APTPS_Obligations_Copied_After_Variation__C,Apttus__Termination_Date__c,
                APTPS_Title__c from Apttus__APTS_Agreement__c where id = :agmt1.id Limit 1];

        system.assertEquals(false, updatedAgmt1.APTPS_ED_Filter_Checklist_Required__c);
        system.assertEquals(false,  updatedAgmt1.APTPS_Obligations_Copied_After_Variation__C);
        system.assertEquals(300000001,  updatedAgmt1.Apttus__Total_Contract_Value__c);

        Test.stopTest();
    }  



}