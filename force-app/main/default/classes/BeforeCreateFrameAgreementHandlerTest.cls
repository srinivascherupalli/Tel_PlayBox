@isTest
public class BeforeCreateFrameAgreementHandlerTest {
    //EDGE-188476 
    static testMethod void testPositiveCase() {
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
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c = insertDPR.Id;
        insert fam;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = orpportunityDetailsRecord.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        Test.startTest();
        string wrappOCRole=BeforeCreateFrameAgreementHandler.validationOnBeforeCreateFA(orpportunityDetailsRecord.Id);
        BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA wrapp= (BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA)JSON.deserialize(wrappOCRole, BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA.class);
        Test.stopTest();
        System.assertEquals('Verification Required',orpportunityDetailsRecord.Partner_Opportunity_Verification__c);
        System.assertEquals(true,wrapp.isOppContactRole);//EDGE-199307
        //EDGE-203284  As a Sales/Partner user, when there is an existing Active Frame agreement on a customer account, then I should NOT be able to add "New Frame Agreement" on a Deal Opportunity
        System.assertEquals(true,wrapp.isFAactive);


    }
    //EDGE-188476 
    static testMethod void testClosedWonOppAndNegativeCases() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity oppObj = new Opportunity();
        oppObj.Product_Domain__c = 'FIXED TELEPHONY';
        oppObj.RetiedAccOpp__c = True;
        oppObj.Name = 'FIXED TELEPHONY';
        oppObj.Partner_Opportunity_Verification__c   = 'Approved';
        oppObj.Description__c = 'FIXED TELEPHONY';
        oppObj.Pricing_Method__c = 'Delegated Pricing';
        oppObj.Product_Type__c = 'Modular';
        oppObj.CloseDate = system.today();
        oppObj.StageName = 'Closed Won';
        oppObj.AccountId = a.Id;
        insert oppObj;
        
        Test.startTest();
        string wrappOCRole=BeforeCreateFrameAgreementHandler.validationOnBeforeCreateFA(oppObj.Id);
        BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA wrapp= (BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA)JSON.deserialize(wrappOCRole, BeforeCreateFrameAgreementHandler.WrappOnBeforeCreateFA.class);
        Test.stopTest();
        System.assertEquals('Closed Won',oppObj.StageName);//EDGE-203941
        System.assertEquals(false,wrapp.isOppContactRole);//EDGE-199307
        System.assertEquals(false,wrapp.isFAactive);//EDGE-203284
        System.assertEquals('',wrapp.activeFAMessage);//EDGE-203284
    }
}