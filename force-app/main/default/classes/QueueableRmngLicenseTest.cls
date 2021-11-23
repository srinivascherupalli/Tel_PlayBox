/*
 * 1. 07-09-2020 : P2OB-7962 : Team Hawaii : Setup method corrected to query on role instead of inserting role.
 * */
@isTest
public class QueueableRmngLicenseTest {

@testSetup static void setup() {

         UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops'];
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;
        }

    @isTest
    static void testAccountRmnglicense(){
    User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
    Account acc1 = TestUtil.createAccount('Test Account 1');
    insert acc1;
          
        
   set<id> sAccountID = new set<id>();
   sAccountID.add(acc1.id);
        
        id p = [select id from profile where name='PRM Community User - Australia'].id;
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc1.Id, Onboarding_Status__c = 'Active', email = 'pims@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con;
        
 
        User u1 = new User(alias = 'test123', email='test123@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
       
        insert u1;
            List<AccountShare> lstShare= new list<AccountShare>();
            AccountShare share = new AccountShare();
                    share.AccountId=acc1.id;
                    share.UserOrGroupId=u1.Id;
                    share.AccountAccessLevel='Edit';
                    share.OpportunityAccessLevel='Read';
                    share.CaseAccessLevel='Read';
                    lstShare.add(share);  
        
map<string,string> conmap=new map<string,string>();
        conmap.put(con.id,'Access Frozen');
         System.enqueueJob(new QueueableRmngLicenseonAccount(sAccountID,lstShare,conmap));
        system.assertEquals(acc1.name,'Test Account 1');
}
}
}