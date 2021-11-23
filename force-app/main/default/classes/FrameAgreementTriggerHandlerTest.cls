@isTest
public class FrameAgreementTriggerHandlerTest {
    static testMethod void testRejectFACase() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        //Then create a primary contact
        Contact c = new Contact();
        c.FirstName = 'Paul';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        c.MailingStreet = '298 S. Ringo Street';
        c.MailingCity = 'Little Rock';
        c.MailingState = 'AR';
        c.MailingPostalCode = '72201'; 
        insert c;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Partner_Opportunity_Verification__c   = 'Verification Required';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        orpportunityDetailsRecord.Partner_Account__c = a.Id;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDPR = new Delegated_Pricing_Request__c();
        insertDPR.Description__c = 'Test';
        insertDPR.Opportunity__c = orpportunityDetailsRecord.id;
        insertDPR.isPrimary__c = False;
        insertDPR.Mark_as_Variation__c = False;
        insertDPR.Parent_DPR__c = 'Test';
        insert insertDPR;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.csconta__Account__c=a.Id;
        fam.csconta__Status__c = 'Approved';
        fam.Delegated_Pricing_Request__c = insertDPR.Id;
        fam.isPrimary__c = true;
        insert fam;
        
        Test.startTest();
        fam.csconta__Status__c = 'Rejected';
        update fam;
        Test.stopTest();
        //List<FeedItem> feeds = [select id,title,body from FeedItem where ParentId=:fam.id];
        System.assertEquals('Rejected',fam.csconta__Status__c);
    }
}