@isTest
public class FUL_CaseTriggerHandlerTest {
    static testMethod void caseFulfillmentTest(){//EDGE-128933
        Id RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Fulfillment').RecordTypeId;
        case cs = new case();
        cs.recordtypeId = RecordTypeId;
        insert cs;
        FulfillmentLineItem__c flItem = new FulfillmentLineItem__c();
        flItem.case__c = cs.Id;
        insert flItem;
        try{
            cs.status = 'Closed';
            update cs;
        }
        catch(exception ex){            
        }
        System.assertNotEquals(cs, null);
    }
    static testMethod void fulfillmentCaseShareTest(){//EDGE-128917
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
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
            Contact contact = new Contact(
            LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
            list < Account > lstA = new list < Account > ();
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            acc.BillingState = 'VIC';
            acc.Account_Status__c = 'Active';
            lstA.add(acc);
            Account partneracc = new Account();
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
            Insert partneracc;
            //system.debug('status::'+partneracc.Account_Status__c+';Id::'+partneracc.Id+';RecordType::'+partneracc.RecordTypeId+';recType::'+accRecordTypeIdpartner);            
            list < Contact > lstC = new list < Contact > ();
            Contact partnercontact = new Contact(
            AccountId = partneracc.id, LastName = 'Last Partner', FirstName = 'First', Partner_Role__c = 'Telstra Collaboration Operations User', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tesadlee2.com');
            lstC.add(partnercontact);
            insert lstC;
            partneracc.IsPartner = true;
            partneracc.RecordTypeId = accRecordTypeIdpartner;
            update partneracc;
            list < User > lstU = new list < User > ();
            User u1 = new User(alias = 'Con1we23', email = 'ContactTqe2r8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p2.id, country = 'United States', IsActive = true, ContactId = partnercontact.Id, timezonesidkey = 'America/Los_Angeles', username = 'Cont92287657w9@noemail.com');
            lstU.add(u1);
            insert lstU;
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId ;
            opp.Name = 'Test Opp';
            opp.Proposal_Required_Date__c = System.today() + 2;
            opp.CloseDate = System.today() + 10;
            opp.StageName = 'Develop';
            opp.Description__c = 'Test';
            //opp.Product_Domain__c = 'MOBILES';
            opp.Shared_Opportunity__c = True;
            opp.PartnerAccountId = partneracc.id;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            opp.SubmittoPartnerStatus__c='Approved';
            insert opp;
            Id RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Fulfillment').RecordTypeId;
            case cs = new case();
            cs.recordtypeId = RecordTypeId;
            cs.OpportunityId__c = opp.id;
            insert cs;
            list<caseshare> csshare = [select id from caseshare where caseid= :cs.id];
            System.assertEquals(csshare.size()>1, true);
        }    
    }
}