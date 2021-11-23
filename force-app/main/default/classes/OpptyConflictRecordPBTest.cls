@isTest
public class OpptyConflictRecordPBTest {

@testSetup static void setup() {

  UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;
        }
        
    
    static testMethod void testMethod1() {
    
    User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
        Test.startTest();
        Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
        insert accdis2;
        System.assertEquals(accdis2.Name, 'Test Accountdit2');
        
        Account acc2 = new Account(Name = 'Test Account2',Partner_Type__c='Nominate',Primary_Distributor__c=accdis2.id,customer_status__c = 'ACTIVE');
        insert acc2;
        
        list<opportunity> lstOpp = new list<opportunity>();
         
        Opportunity Opp1 = new Opportunity();
        Opp1.Name =  'test';
        Opp1.StageName = 'Propose';
        Opp1.CloseDate = system.today()+4;
        Opp1.Product_Domain__c ='MOBILES';
        Opp1.AccountId = acc2.id;
        //insert Opp1;
        lstOpp.add(Opp1);
       
        
         Opportunity opp2 = new Opportunity();
            opp2.Name = 'Test Opportunity';
            system.debug('Proceessing');
            opp2.Product_Domain__c='MOBILES';
            opp2.StageName = 'Prospose';
            opp2.CloseDate = system.today()+7;
            opp2.AccountId = acc2.Id;
            //insert opp2;
            lstOpp.add(opp2);
        insert lstOpp;
        
        list<Id> lstId = new list<Id>();
        for(Opportunity Opp: lstOpp)
        {
             lstId.add(Opp.Id);
         }
        System.assertEquals(Opp1.Name, 'test');
        Id p = [select id from profile where name='PRM Community User - Australia'].id;
        Id p2 = [select id from profile where name = 'PRM Community User - Australia'].id;
        
        PRM_Default__c Prmdfault = PRM_Default__c.getInstance(p);
        Prmdfault.Enable_Partner_Opp_Conflict_Checking__c = true;
        Prmdfault.Partner_Opp_Conflict_Number_of_Days__c=10;
        insert Prmdfault; 
        
        Contact con2 = new Contact(FirstName = 'uuu11',LastName='ppp11',AccountId=accdis2.Id);
        insert con2;
        System.assertEquals(con2.FirstName, 'uuu11');
        
        User u12 = new User(alias = 'conf3', email='conf3@noemail.com',
                            emailencodingkey='UTF-8', lastname='conf3', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = p2, country='United States',IsActive =true,
                            ContactId = con2.Id,
                            timezonesidkey='America/Los_Angeles', username='conf3@noemail.com');
        insert u12;     
       
        system.runAs(u12) { 
            u12.IsPortalEnabled = true; 
            update u12;
            OpptyConflictRecordPB.CreateConflictRecPB(lstId); 
            // statements to be executed by this test user.
        }
        System.assertEquals(u12.email, 'conf3@noemail.com');    
                            
        Test.stopTest();
    }
    }
}