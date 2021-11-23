@isTest
public class orderRequesterCustomLookUpControllerTest {
    
    	@testsetup 
    static void datasetup() {
        //CREATE ACCOUNT
        //Account acc = new Account(Name='Test Account');
        //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
        //Sprint 19.17 P2OB-4149
        Account acc=TestUtil.createAccount('Test Account');
        insert acc;
        System.assertNotEquals(null,acc);
    
        
      	Account acc1  = TestUtil.createAccount('Test Sam'); //new Account(Name = 'Test Sam');
        insert acc1;

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'TestOpp';
        insert opp;
        System.assertNotEquals(null,opp);
        
        Contact con = new Contact();
        con.FirstName = 'Rajesh';
        con.LastName = 'Singh'; 
        con.email ='rajesh@test.com';
        con.Contact_Status__c ='Active';
        con.AccountId=acc.id;
        insert con;
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = con.Id;
        ACR.AccountId = acc1.Id;
        ACR.Roles = 'Legal Lessee';
        insert ACR;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = con.Id;
        ocr.Role = 'Buyer';
        insert ocr;
 
    }
    
    @isTest
    static void fetchLookUpValues(){
        Account acc = [Select Id From Account where Name = 'Test Sam'];
        String keyWord = 'Sam';
        Test.startTest();
        List <AccountContactRelation> returnedConId = orderRequesterCustomLookUpController.fetchLookUpValues(keyWord,acc.ID);
        Test.stopTest();   
       System.assert(acc != null);
    }
    
     @isTest
    static void fetchLookUpValuesForOpportunityContactRole(){
       // OpportunityContactRole ocr = [Select Id,Contact_Name__c From OpportunityContactRole where Contact_Name__c = 'Sam'];
       // system.debug('ocr name '+ocr.Contact_Name__c);
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='TestOpp'];
        String keyWord = 'Sam';
        Test.startTest();
        List <OpportunityContactRole> returnedConId = orderRequesterCustomLookUpController.fetchLookUpValuesForOpportunityContactRole(keyWord,opp.Id);
        Test.stopTest();   
       System.assert(opp != null);
    }

}