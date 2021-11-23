/*
AUTHOR : Ravi Teja Komatineni
DESCRIPTION : This is the test class for PRMSubmitToPartnerRules
EDGE-81336
EDGE-81324
Version     Author                         Last Modified Date      Description
v1.2        Vivian Charlie (Team Hawaii)   09 Dec 2019             P2OB-2448 : Updated test class
v1.3        Ravi Dodiya(Team Hawaii)       09 Jan 2020             P2OB-4275 : Updated test class
v1.4        Vivian Charlie (Team Hawaii)   31 Jan 2019             P2OB-2448 : Updated test class
v1.5        Vivian Charlie (Team Hawaii)   07 Apr 2020             Replacing UserRole insert with query to overcome SF exception
*/
@isTest
public class PRMSubmitToPartnerRulesTest {
    public static Account acc;
    public static User u1, u2, usrVC, usrVC1;
    public static Account partneracc, partneracc1, partneracc2;

    @testSetup static void setup() {

        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops' limit 1]; // v1.5

         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];

        User uSysAdmin = new User(alias = 'Con123', email = 'ContactTr8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Cont987657awqas@noemail.com', userroleid = r.id);

        insert uSysAdmin;
        system.debug('uSysAdmin***********'+uSysAdmin);

        System.runAs(uSysAdmin){

            id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
            id accRecordTypeIdpartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            Set < String > customerUserTypes = new Set < String > {
                'PRM Community User - Australia'
            };
        Profile p2 = [select Id,name from Profile where Name in :customerUserTypes limit 1];
        list<opportunity> opplst=new list<opportunity>();

            Contact contact = new Contact(
            LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
            
        //for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
        Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
        insert accdis2;
        System.assertEquals(accdis2.Name, 'Test Accountdit2');


            list < Account > lstA = new list < Account > ();
            acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            acc.BillingState = 'VIC';
            acc.Account_Status__c = 'Active';
            lstA.add(acc);

            partneracc = new Account();
        partneracc.RecordTypeId = accRecordTypeIdpartner ;
        partneracc.Name='Partner Acc';
            partneracc.Account_Status__c = 'Active';
        partneracc.Customer_Trading_Name__c = 'Test';
        partneracc.ABN__c='aaaa';
        partneracc.ACN__c='ccc';
        partneracc.State_Coverage__c = 'VIC';
        partneracc.Partner_Type__c='Partner';
            partneracc.Website = 'www.vsygqwoci.com';
        partneracc.Phone='0412354323';
        partneracc.Overall_Accreditation__c='Platinum';
        partneracc.Mobility_Accreditation__c='Platinum';
        partneracc.Cloud_Accreditation__c='Platinum';
        partneracc.Data_Security_Accreditation__c='Platinum';
        partneracc.Collaboration_Accreditation__c='Platinum';
            partneracc.PartnerPrincipalContact__c = Contact.id;
            lstA.add(partneracc);

            partneracc1 = new Account();
            partneracc1.RecordTypeId = accRecordTypeIdpartner;
            partneracc1.Name = 'Partner Acc 01';
            partneracc1.Account_Status__c = 'Active';
            partneracc1.Customer_Trading_Name__c = 'Test1';
            partneracc1.ABN__c = 'aaaab';
            partneracc1.ACN__c = 'cccb';
            partneracc1.State_Coverage__c = 'VIC';
            partneracc1.Partner_Type__c = 'Distributor'; //v1.2
            partneracc1.Website = 'www.vsygwwoci.com';
            partneracc1.Phone = '0412354324';
            partneracc1.Overall_Accreditation__c = 'Gold';
            partneracc1.Mobility_Accreditation__c = 'Gold';
            partneracc1.Cloud_Accreditation__c = 'Gold';
            partneracc1.Data_Security_Accreditation__c = 'Gold';
            partneracc1.Collaboration_Accreditation__c = 'Gold';
            partneracc1.PartnerPrincipalContact__c = Contact.id;
            lstA.add(partneracc1);

            partneracc2 = new Account();
            partneracc2.RecordTypeId = accRecordTypeIdpartner;
            partneracc2.Name = 'Partner Acc 01';
            partneracc2.Account_Status__c = 'InActive';
            partneracc2.Customer_Trading_Name__c = 'Test1';
            partneracc2.ABN__c = 'aaaac';
            partneracc2.ACN__c = 'cccd';
            partneracc2.State_Coverage__c = 'VIC';
            partneracc2.Partner_Type__c = 'Nominate'; // v1.2
            partneracc2.Website = 'www.vsygewoci.com';
            partneracc2.Phone = '0412354325';
            partneracc2.Overall_Accreditation__c = 'Silver';
            partneracc2.Mobility_Accreditation__c = 'Silver';
            partneracc2.Cloud_Accreditation__c = 'Silver';
            partneracc2.Data_Security_Accreditation__c = 'Silver';
            partneracc2.Collaboration_Accreditation__c = 'Silver';
            partneracc2.PartnerPrincipalContact__c = Contact.id;
            partneracc2.Primary_Distributor__c=accdis2.id;
            lstA.add(partneracc2);
            EnvironmentalSettings.isTriggerDisabled('AccountTrigger');

            Insert lstA;
            test.starttest();
            list < Contact > lstC = new list < Contact > ();
        Contact partnercontact = new Contact(
            AccountId = lstA[1].id, LastName = 'Last Partner', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tesadlee2.com');
            lstC.add(partnercontact);
            //Insert partnercontact;

            Contact partnercontact1 = new Contact(
            AccountId = lstA[2].id, LastName = 'Last Partner', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'testVC@tesadle2.com');
            //Insert partnercontact1;
            lstC.add(partnercontact1);

            Contact partnercontact2 = new Contact(
            AccountId = lstA[3].id, LastName = 'Last Partner', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'testVC2@tesadeele2.com');
            //Insert partnercontact2;
            lstC.add(partnercontact2);
            //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
            Contact conForOppConRole1 = new Contact(
                AccountId = lstA[0].id, LastName = 'Last Partner', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'tes13t@tesadlee2.com');
                lstC.add(conForOppConRole1);

            insert lstC;

            //lstA[0].IsPartner = true;
            lstA[1].IsPartner = true;
            lstA[2].IsPartner = true;
            lstA[3].Primary_Distributor__c = lstA[2].id;//v1.2
            lstA[3].IsPartner = true;
            update lstA;

            list < User > lstU = new list < User > ();
            u1 = new User(alias = 'Con1we23', email = 'ContactTqe2r8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p2.id, country = 'United States', IsActive = true, ContactId = partnercontact.Id, timezonesidkey = 'America/Los_Angeles', username = 'Cont92287657w9@noemail.com');
            lstU.add(u1);
            //insert u1;
            usrVC = new User(alias = 'Con1we24', email = 'ContactTqe2r8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p2.id, country = 'United States', IsActive = true, ContactId = partnercontact1.Id, timezonesidkey = 'America/Los_Angeles', username = 'Cont24392287657w9@noemail.com');
            lstU.add(usrVC);
            //insert usrVC;
            usrVC1 = new User(alias = 'Con1we25', email = 'ContactTqe2r8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p2.id, country = 'United States', IsActive = true, ContactId = partnercontact2.Id, timezonesidkey = 'America/Los_Angeles', username = 'Cont24292287657w9@noemail.com');
            lstU.add(usrVC1);

            //u2 = new User(alias = 'Con123', email = 'ContactTr8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p2.id, country = 'United States', IsActive = true, ContactId = contact.Id, timezonesidkey = 'America/Los_Angeles', username = 'Cont987657w9@noemail.com');
            //lstU.add(u2);

            insert lstU;

            

            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId ;
            opp.Name = 'Test Opp';
            opp.Proposal_Required_Date__c = System.today() + 2;
            opp.CloseDate = System.today() + 10;
            opp.StageName = 'Develop';
            opp.Description__c = 'Test';
            opp.Product_Domain__c = 'MOBILES';
            opp.Shared_Opportunity__c = True;
            opp.PartnerAccountId = lstA[1].id;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            opp.SubmittoPartnerStatus__c='Approved';

            //insert opp;
            opplst.add(opp);

            Opportunity opp1 = new Opportunity();
            opp1.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId ;
            opp1.Name = 'Test Opp 1';
            opp1.Proposal_Required_Date__c = System.today() + 2;
            opp1.CloseDate = System.today() + 40;
            opp1.StageName = 'Develop';
            opp1.Description__c = 'Test';
            opp1.Product_Domain__c = 'SECURITY';
            opp1.Shared_Opportunity__c=True;
            opp1.Override_Reason__c ='Incumbent Partner does not have appropriate coverage';
            opp1.SubmittoPartnerStatus__c='Submitted';

            //insert opp1;
            opplst.add(opp1);

            Opportunity opp2 = new Opportunity();
            opp2.AccountId = partneracc.Id;
            opp.recordTypeId=oppRecordTypeId ;
            opp2.Name = 'Test Opp 2';
            opp2.Proposal_Required_Date__c = System.today() + 2;
            opp2.CloseDate = System.today() + 10;
            opp2.StageName = 'Develop';
            opp2.Description__c = 'Test';
            opp2.Product_Domain__c = 'TELSTRA HEALTH';
            opp2.Shared_Opportunity__c = True;
            opp2.PartnerAccountId = lstA[1].id;
            opp2.Partner_Opportunity_Verification__c = 'Approved';
            opp2.SubmittoPartnerStatus__c='Approved';
            //insert opp2;
            opplst.add(opp2);
            EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger');

            insert opplst;
            //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
            Contact oppCon1 = [SELECT id FROM Contact WHERE AccountId =: opplst[0].AccountId LIMIT 1];
            list<OpportunityContactRole> lstCR = new list<OpportunityContactRole>();
            OpportunityContactRole contactrole = new OpportunityContactRole();
            contactrole.ContactId = oppCon1.id;
            contactrole.OpportunityId = opplst[0].id;
            contactrole.IsPrimary = true;
            contactrole.Role = 'Inside Sales Account Manager';
            lstCR.add(contactrole);
            OpportunityContactRole contactrole2 = new OpportunityContactRole();
            contactrole2.ContactId = oppCon1.id;
            //contactrole2.OpportunityId=opplst[2].id;
            contactrole2.OpportunityId = opplst[1].id;
            contactrole2.IsPrimary = true;
            contactrole2.Role = 'Inside Sales Account Manager';
            lstCR.add(contactrole2);
            insert lstCR;

            test.stoptest();
        }
    }@istest
    public  static void testrecommandations(){
   User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
       System.runAs(uSysAdmin){
    test.starttest();
    list<opportunity> opplist=[select id,name from opportunity where name='Test Opp'];
    list<opportunity> opplist1=[select id,name from opportunity where name='Test Opp 1'];
    //list<opportunity> opplist2=[select id,name from opportunity where name='Test Opp 2'];
            account acc = [select id from account where name = 'Partner Acc'
            limit 1];
    set<id> recset= new set<id>();
     set<id> incset= new set<id>();
     recset.add(acc.id);
      incset.add(acc.id);

            PRMSubmitToPartnerRules.WrapperPageData partnerlist=PRMSubmitToPartnerRules.init(opplist[0].id);
            list<PartnerResults> Recomendedpartnerlist=PRMSubmitToPartnerRules.findRecommedation(opplist[0].id);
            list<PartnerResults> Incumbentpartnerlist=PRMSubmitToPartnerRules.findIncumbentPartners(opplist1[0].id);
            //list<PartnerResults> Incumbentpartnerlist2=PRMSubmitToPartnerRules.findIncumbentPartners(opplist2[0].id);
            PRMSubmitToPartnerRules.sendChatterToIncumbentPartners(Incumbentpartnerlist,opplist1[0].id);

            test.stoptest();

            //positive case
            System.assert(Null != Recomendedpartnerlist, 'result');
            System.assert(Null != Incumbentpartnerlist, 'result');

            //Negative Case
            //System.assert(Incumbentpartnerlist2.size()==0,'result');

//Negative Case
  //System.assert(Incumbentpartnerlist2.size()==0,'result');

 }
    }

    public static testMethod void testIncumbency() {
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        list < opportunity > opplist = [select id, name from opportunity where name = 'Test Opp'];
        account acc = [select id from account where name = 'TestClassEvent' limit 1];
        list < Account > pAcc = [select id from account where name LIKE 'Partner Acc%'];
        list < Contact> pCon = [select id from Contact where FirstName LIKE 'First%' limit 1];
        list<User> usr = [Select Id, Username, AccountId from User where Username = 'Cont92287657w9@noemail.com' or Username = 'Cont24392287657w9@noemail.com'];
        //User usr1 = [Select Id, Username, AccountId from User where Username = 'Cont24392287657w9@noemail.com'];
        system.debug('*****usr*****' + usr);
        list < Opportunity > lstO = new list < Opportunity > ();
        Test.startTest();
        for (Integer i = 0; i <= 2; i++) {
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId;
            opp.Name = 'Test Opp';
            opp.Proposal_Required_Date__c = System.today() + 2;
            opp.CloseDate = System.today() + 10;
            opp.StageName = 'Closed Won';
            opp.Description__c = 'Test';
            opp.Product_Domain__c = 'MOBILES';
            opp.Shared_Opportunity__c = True;
            opp.PartnerAccountId = (i == 2) ? pAcc[0].id: null;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            opp.SubmittoPartnerStatus__c = 'Approved';
            lstO.add(opp);
        }

        System.runAs(usr[0]) {
            for (Integer i = 0; i <= 1; i++) {
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.OwnerId = usr[0].Id;
                opp.recordTypeId=oppRecordTypeId;
                opp.Name = 'Partner Opp ' + i;
                opp.Proposal_Required_Date__c = System.today() + 2;
                opp.CloseDate = System.today() + 10;
                opp.StageName = 'Closed Won';
                opp.Description__c = 'Test';
                opp.Product_Domain__c = 'MOBILES';
                opp.Shared_Opportunity__c = True;
                //opp.PartnerAccountId=partneracc.id;
                opp.Partner_Opportunity_Verification__c = 'Approved';
                opp.SubmittoPartnerStatus__c = 'Approved';
                lstO.add(opp);
            }
        }
        System.runAs(usr[1]) {
            for (Integer i = 0; i <= 1; i++) {
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.OwnerId = usr[1].Id;
                opp.recordTypeId=oppRecordTypeId;
                opp.Name = 'Partner Opp ' + i;
                opp.Proposal_Required_Date__c = System.today() + 2;
                opp.CloseDate = System.today() + 10;
                opp.StageName = 'Closed Won';
                opp.Description__c = 'Test';
                opp.Product_Domain__c = 'MOBILES';
                opp.Shared_Opportunity__c = True;
                //opp.PartnerAccountId=partneracc.id;
                opp.Partner_Opportunity_Verification__c = 'Approved';
                opp.SubmittoPartnerStatus__c = 'Approved';
                lstO.add(opp);
            }
        }
        EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger');
        insert lstO;
        system.debug('lstO*****' + lstO);
        list < Opportunity > lOp = [Select Id, Name, OwnerId, Owner.AccountId from Opportunity where Id IN: lstO];
        system.debug('lOp*****' + lOp);

        Product2 prod = new Product2();
        prod.Name = 'P 01';
        prod.isActive = true;
        insert prod;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.isActive = true;
        pbe.UnitPrice = 100;
        insert pbe;

        list < OpportunityLineItem > lstOLI = new list < OpportunityLineItem > ();
        for (Integer i = 0; i <= 1; i++) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = lstO[i].Id;
            oli.PricebookEntryId = pbe.Id;
            oli.Quantity = 1;
            oli.Description = 'de------------';
            oli.UnitPrice = 100;
            oli.Product_Status__c = 'Won';
            oli.Domain__c = 'MOBILES';
            if (i == 0) {
                oli.Tagged_Partner__c = pAcc[1].id;
            } else {
                oli.Tagged_Partner__c = pAcc[2].id;
            }
            lstOLI.add(oli);
        }
        insert lstOLI;
        PRMSubmitToPartnerRules.getHiearchySettings(); // v1.4
        PRMSubmitToPartnerRules.getDistributorModelSettings(); // v1.4
        PRMSubmitToPartnerRules.returnSelectedPartner(pAcc[1].id); // v1.4
        PRMSubmitToPartnerRules.returnPartnerUser(pCon[0].Id); // v1.4
        
        Test.stopTest();
        PRMSubmitToPartnerRules.WrapperPageData partnerlist=PRMSubmitToPartnerRules.init(opplist[0].id);
        list < PartnerResults > lstIncumbentPartner = PRMSubmitToPartnerRules.findIncumbentPartners(opplist[0].Id);
        System.assertEquals(3, lstIncumbentPartner.size(), '***Invalid count of Incumbent partners***');
        system.debug('***ASSERT SIZE*****' + lstIncumbentPartner.size());
}

    public static testMethod void testIncumbency1() {
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        list < opportunity > opplist = [select id, name from opportunity where name = 'Test Opp'];
        account acc = [select id from account where name = 'TestClassEvent' limit 1];
        list < Account > pAcc = [select id from account where name LIKE 'Partner Acc%'];
        list < Contact> pCon = [select id from Contact where FirstName LIKE 'First%' limit 1];
        list<User> usr = [Select Id, Username, AccountId from User where Username = 'Cont92287657w9@noemail.com' or Username = 'Cont24392287657w9@noemail.com'];
        //User usr1 = [Select Id, Username, AccountId from User where Username = 'Cont24392287657w9@noemail.com'];
        system.debug('*****usr*****' + usr);
        list < Opportunity > lstO = new list < Opportunity > ();
        Test.startTest();
        for (Integer i = 0; i <= 2; i++) {
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId;
            opp.Name = 'Test Opp';
            opp.Proposal_Required_Date__c = System.today() + 2;
            opp.CloseDate = System.today() + 10;
            opp.StageName = 'Closed Won';
            opp.Description__c = 'Test';
            opp.Product_Domain__c = 'FIXED TELEPHONY';
            opp.Shared_Opportunity__c = True;
            opp.PartnerAccountId = (i == 2) ? pAcc[0].id: null;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            opp.SubmittoPartnerStatus__c = 'Approved';
            lstO.add(opp);
        }

        System.runAs(usr[0]) {
            for (Integer i = 0; i <= 1; i++) {
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.OwnerId = usr[0].Id;
                opp.recordTypeId=oppRecordTypeId;
                opp.Name = 'Partner Opp ' + i;
                opp.Proposal_Required_Date__c = System.today() + 2;
                opp.CloseDate = System.today() + 10;
                opp.StageName = 'Closed Won';
                opp.Description__c = 'Test';
                opp.Product_Domain__c = 'CLOUD SERVICES';
                opp.Shared_Opportunity__c = True;
                //opp.PartnerAccountId=partneracc.id;
                opp.Partner_Opportunity_Verification__c = 'Approved';
                opp.SubmittoPartnerStatus__c = 'Approved';
                lstO.add(opp);
            }
        }
        System.runAs(usr[1]) {
            for (Integer i = 0; i <= 1; i++) {
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.OwnerId = usr[1].Id;
                opp.recordTypeId=oppRecordTypeId;
                opp.Name = 'Partner Opp ' + i;
                opp.Proposal_Required_Date__c = System.today() + 2;
                opp.CloseDate = System.today() + 10;
                opp.StageName = 'Closed Won';
                opp.Description__c = 'Test';
                opp.Product_Domain__c = 'DATA & IP';
                opp.Shared_Opportunity__c = True;
                //opp.PartnerAccountId=partneracc.id;
                opp.Partner_Opportunity_Verification__c = 'Approved';
                opp.SubmittoPartnerStatus__c = 'Approved';
                lstO.add(opp);
            }
        }
        EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger');
        insert lstO;
        system.debug('lstO*****' + lstO);
        list < Opportunity > lOp = [Select Id, Name, OwnerId, Owner.AccountId from Opportunity where Id IN: lstO];
        system.debug('lOp*****' + lOp);

        Product2 prod = new Product2();
        prod.Name = 'P 01';
        prod.isActive = true;
        insert prod;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.isActive = true;
        pbe.UnitPrice = 100;
        insert pbe;

        list < OpportunityLineItem > lstOLI = new list < OpportunityLineItem > ();
        for (Integer i = 0; i <= 1; i++) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = lstO[i].Id;
            oli.PricebookEntryId = pbe.Id;
            oli.Quantity = 1;
            oli.Description = 'de------------';
            oli.UnitPrice = 100;
            oli.Product_Status__c = 'Won';
            oli.Domain__c = 'INTEGRATED SERVICES';
            if (i == 0) {
                oli.Tagged_Partner__c = pAcc[1].id;
            } else {
                oli.Tagged_Partner__c = pAcc[2].id;
            }
            lstOLI.add(oli);
        }
        insert lstOLI;
        PRMSubmitToPartnerRules.getHiearchySettings(); // v1.4
        PRMSubmitToPartnerRules.getDistributorModelSettings(); // v1.4
        PRMSubmitToPartnerRules.returnSelectedPartner(pAcc[1].id); // v1.4
        PRMSubmitToPartnerRules.returnPartnerUser(pCon[0].Id); // v1.4
        
        Test.stopTest();
        list < PartnerResults > lstIncumbentPartner = PRMSubmitToPartnerRules.findIncumbentPartners(opplist[0].Id);
        System.assertEquals(2, lstIncumbentPartner.size(), '***Invalid count of Incumbent partners***');
        system.debug('***ASSERT SIZE*****' + lstIncumbentPartner.size());
}
    
    public static testMethod void testPOR() {
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
       System.runAs(uSysAdmin){         
                    Test.startTest();

            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='Smith',FirstName='Smith',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            
            
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
            
            insert customerContacts;
            for(Contact  customCon : customerContacts){
                customCon.FirstName='John';
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            update customerContacts;
            Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                                Partner__c=partnerAccount.Id,Partner_Signatories__c= con.Id,Status__c='Active'); 
            insert POR;
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount.get(0)); 
            opp.Product_type__c='Modular';
            insert opp;  
                  
        
    
        Test.stopTest();
        list < PartnerResults > lstPORPartner = PRMSubmitToPartnerRules.findPartnerOfRecords(opp.Id);
        System.assertEquals(1, lstPORPartner.size(), '***Invalid count of POR partners***');
        system.debug('***ASSERT SIZE*****' + lstPORPartner.size());
        PartnerResults porlst= new PartnerResults();
} 
    }

}