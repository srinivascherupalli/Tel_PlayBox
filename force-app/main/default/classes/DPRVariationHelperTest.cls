@isTest
private class DPRVariationHelperTest {
    static testMethod void validateUpdateDPRVariation() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Product_Domain__c = 'FIXED TELEPHONY';
        opportunityRecord.RetiedAccOpp__c = True;
        opportunityRecord.Name = 'FIXED TELEPHONY';
        opportunityRecord.Description__c = 'FIXED TELEPHONY';
        opportunityRecord.Pricing_Method__c = 'Delegated Pricing';
        opportunityRecord.Product_Type__c = 'Modular';
        opportunityRecord.CloseDate = system.today();
        opportunityRecord.StageName = 'Open';
        opportunityRecord.AccountId = a.Id;
        insert opportunityRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = opportunityRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insert insertDelegatedPricingRequest;
        
        csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=opportunityRecord.id;
        fam1.csconta__Status__c = 'Draft';
        fam1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        insert fam1;
        
        csconta__Frame_Agreement__c fam2=new csconta__Frame_Agreement__c();
        fam2.Opportunity__c= opportunityRecord.id;
        fam2.csconta__replaced_frame_agreement__c = fam1.Id;
        fam2.csconta__Status__c = 'Draft';
        insert fam2;
        
        Test.startTest();
        
        
        FAMActionHelper famh1=new FAMActionHelper();
        
        famh1.refreshDelegatedPricing(fam2.Id);
        
        
        Test.stopTest();
        csconta__Frame_Agreement__c fam = [SELECT Id,Delegated_Pricing_Request__c,Delegated_Pricing_Request__r.Replaced_DPR__c,Delegated_Pricing_Request__r.Mark_as_Variation__c, csconta__Status__c  FROM csconta__Frame_Agreement__c where id =: fam2.Id];
        System.assertEquals(insertDelegatedPricingRequest.Id, fam.Delegated_Pricing_Request__r.Replaced_DPR__c,'DPR records are different');
        System.assertEquals(True, fam.Delegated_Pricing_Request__r.Mark_as_Variation__c,'Mark as variation is false');
        
        Delegated_Pricing_Request__c prevDpr = [select id,Name,ReplacedBy_DPR__c from Delegated_Pricing_Request__c where id =: insertDelegatedPricingRequest.Id];
        System.assertEquals(fam.Delegated_Pricing_Request__c, prevDpr.ReplacedBy_DPR__c,'Unexpected Replaced DPR');
        
    }
}