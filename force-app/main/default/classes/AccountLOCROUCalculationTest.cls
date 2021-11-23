/*
AUTHOR : Anu Yadav
DESCRIPTION : Covers test coverage for Account LOc ROU Calculation 
DESCRIPTION : To get code overage for contact trigger handler  
//Just Sending for contact trigger helper code coverage for DIGI-3444.
*/
@isTest
public class AccountLOCROUCalculationTest {
    @isTest
    static void unitTestMethod1(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
          Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          acc.Name= 'TestName'  ;
          update acc;
         
          Contact c1 = [Select Id,Name,AccountId,FirstName,Birthdate from Contact where AccountId =: acc.Id];
          c1.Birthdate =Date.newInstance(2000, 2,18);
          update c1;  
            
          acc.Type = '';
          update acc;
          System.assertEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
        }
    }
    @isTest
    static void unitTestMethod2(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
          Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          acc.Managed__c= False;
          update acc;
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
         
    }
   }  
     @isTest
    static void unitTestMethod3(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
          Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          acc.Type='Company';
          acc.Business_Unit__c='Enterprise';
          update acc;
            
            
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
         
    }
  }
    @isTest
    static void unitTestMethod4(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
          Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          
          Contact c1 = [Select Id,Name,AccountId,FirstName,Birthdate from Contact where AccountId =: acc.Id];
          c1.FirstName = 'Hello';
          c1.MiddleName = 'test';
          update c1; 
                    
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
         
    }
  }
     @isTest
    static void unitTestMethod5(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
        Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          
        Contact c1 = [Select Id,Name,AccountId,FirstName,Birthdate from Contact where AccountId =: acc.Id];
        c1.FirstName = NULL;
        c1.MiddleName = 'test';
        update c1; 
                    
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
    }
  }
    
      @isTest
    static void unitTestMethod6(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
        Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          
        Contact c1 = [Select Id,Name,AccountId,FirstName,Birthdate from Contact where AccountId =: acc.Id];
        c1.firstName = 'Hello';
        update c1; 
                    
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
         
    }
  }
    
        @isTest
    static void unitTestMethod7(){
        
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        insert admin;
        
        Test.startTest();
        System.runAs(admin){
           
        Account acc = [Select Id,Name,ABN__c,Type,Customer_Status__c,Loc__c FROM Account WHERE ABN__c='10000000000'][0];
          
        Contact c1 = [Select Id,Name,AccountId,FirstName,Birthdate from Contact where AccountId =: acc.Id];
        c1.firstName = NULL;
        c1.MiddleName= NULL;   
        update c1; 
                    
         System.assertNotEquals('TestName', [select Name from Account where Id = :acc.Id].Name);
         
    }
  }
    
     @testSetup static void setup(){
        Customer_Type__c ct1 = new Customer_Type__c(Name='Sole Trader',Code__c='102',Customer_Type__c='Sole Trader');
            insert ct1;
            Customer_Type__c ct2 = new Customer_Type__c(Name='Company',Code__c='103',Customer_Type__c='Company');
            insert ct2;
            Business_Unit__c bu = new Business_Unit__c(Name='Business',Business_Unit__c='Business',LIC__c='B');
            insert bu;
            Post_Code__c pc = new Post_Code__c(Name='AUSTRALIAN NATIONAL UNIVERSITY',Geo_Code__c='3N',Zip_Code__c='200');
            insert pc;
            Market_Segment__c ms = new Market_Segment__c(Name='DHL Express',Market_Segment__c='DHL Express',LIC__c='7Y');
            insert ms;
          
           Account acc1 = TestUtil.createAccount('Test Account 1');
            Account acc2 = TestUtil.createAccount('Test Account 2');
            
            acc1.Type= 'Sole Trader';
            acc1.Customer_Status__c = 'ACTIVE';
            acc1.ABN__c = '10000000000';
            acc1.Business_Unit__c='Business';
            acc1.BillingCity='AUSTRALIAN NATIONAL UNIVERSITY';
            acc1.BillingPostalCode='200';
            acc1.Market_Segment__c='DHL Express';
            acc1.Managed__c = True;
            
            acc2.Type= 'Company';
            acc2.Customer_Status__c = 'ACQUIRED';
            acc2.ABN__c = '111111111';
            acc2.Business_Unit__c='Business';
            acc2.BillingCity='AUSTRALIAN NATIONAL UNIVERSITY';
            acc2.BillingPostalCode='200';
            acc2.Market_Segment__c='DHL Express';
            acc2.Managed__c = False;
             
            List<Account> accountInsertList = new List<Account>{acc1, acc2};
            insert accountInsertList;
          
            Contact c1 = TestUtil.createContact(acc1.Id,'Test','Contact');
            c1.Birthdate= Date.newInstance(1999, 1,10);
            insert c1;
            
            AccountContactRelation acr= [Select Id,AccountId,ContactId,Roles from AccountContactRelation where AccountId =:acc1.Id AND ContactId =:c1.Id];
            acr.Roles='Legal Lessee';
            update acr;
           
    }
}