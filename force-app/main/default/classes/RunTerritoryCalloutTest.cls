@isTest
public class RunTerritoryCalloutTest {
    
    @isTest static void singleAccountTerritoryRuleCalloutTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RunTerritoryRulesMock());
        
        // Call method to test.    
        RunTerritoryRules job = new RunTerritoryRules() ;                
        job.accntIds = new Set<String>();      
        
        Account account=TestUtil.createAccount('TestAccount1234');
        account.Portfolio_Code__c='ABC10';
        insert account;
        
        account.Portfolio_Code__c='ABC10';
        update account;
        System.debug('Updated Account id:'+account.Id);
        
        job.accntIds.add(account.Id);					  		
        System.debug('Job is going to be added in enqueue');
        if(job!=null && !job.accntIds.isEmpty()){
            System.enqueueJob(job);  
            System.debug('Job has been added to enqueue');
        }
        Test.stopTest();
        System.debug('Test Stopped');      
        System.assertEquals('Territory Rules have been triggered',RunTerritoryRules.responseVal);   
        
        
    }
    
    /**@isTest static void bulkAccountTerritoryRuleCalloutTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RunTerritoryRulesMock());
        
        // Call method to test.    
        RunTerritoryRules job = new RunTerritoryRules() ;                
        job.accntIds = new Set<String>();      
        
        List<Account> accts=TestUtil.createBulkAccountWithPortfolio(200, 'TestAccount', 'ABC10');
        insert accts;
        
        List<Account> acctsUpdate = new List<Account>();
        for(Account acc : accts)
        {
            acc.Portfolio_Code__c='ABC10';
            acctsUpdate.add(acc);
            job.accntIds.add(acc.Id);
        }
        update acctsUpdate;     
        
        
        System.debug('Job is going to be added in enqueue');
        if(job!=null && !job.accntIds.isEmpty()){
            System.enqueueJob(job);  
            System.debug('Job has been added to enqueue');
        }
        Test.stopTest();
        System.debug('Test Stopped');      
        System.assertEquals('Territory Rules have been triggered',RunTerritoryRules.responseVal);   
        
        
    }**/
    
    @testsetup
    static void setup(){  
        // Setup the territories. The account and opportunity cannot be created in the same context as it throws
        // a Mixed DML exception
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC100','ABC103'});
        insert territories;
        
    }
    
    
}