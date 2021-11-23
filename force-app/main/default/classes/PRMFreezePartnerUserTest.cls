@isTest
public with sharing class PRMFreezePartnerUserTest{
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
    
     @isTest 
    public  static void testfreezeActiveUser(){
    User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
        Account ac = new Account(name ='Telecom') ;
        insert ac; 
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'InActive');
        insert con; 
        con.Onboarding_Status__c = 'Active';
        update con;
        id p = [select id from profile where name='PRM Community User - Australia'].id;
        User u1 = new User(alias = 'PRMF', email='PRMFz676@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username='PRM676@noemail.com');
        
        insert u1;
        System.assertNotEquals(null,u1);

        
        
        test.starttest();
        PRMFreezePartnerUser.freezeUsers(new list<id>{con.id});
         PRMFreezePartnerUser.unfreezeUsers(new list<id>{con.id});
        
        test.stoptest();

}

}


}