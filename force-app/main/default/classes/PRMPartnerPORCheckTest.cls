/*************************************************************************************************
Name : PRMPartnerPORCheckTest
Description : Test class for PRMPartnerPORCheck EDGE-151597
***************************************************************************************************/
@isTest
public class PRMPartnerPORCheckTest
{
    @testSetup public static void setup(){
  
	UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
	insert r;
	profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
	User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com', userroleid = r.id);
	insert uSysAdmin;
	User  partneruser;
	System.runAs(uSysAdmin){
		id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
		Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
		insert ac;  
		Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
		insert con; 
		partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
								   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
								   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
								   timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
		insert partneruser;        

			Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
			for(Account customACC : customerAccount){
				customACC.Customer_Status__c = 'Active';
			}
			insert customerAccount;
			
			List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
			for(Contact  customCon : customerContacts){
				customCon.Authority__c = 'Full Authority';
				customCon.Contact_Status__c = 'Active';
				customCon.MobilePhone = '+61123456789';
			}
			insert customerContacts;
			
			Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id,
																Partner__c=ac.Id,Status__c='Active'); 
			insert POR;
			Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount.get(0));     
			insert opp; 		
		}
	}
	
    @isTest
    public static void testActivePOR(){//EDGE-151597 Active POR scenario
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;	
		User partneruser = [select id from user where username='b2btestewwrpdua@noemail.com'];
		System.runAs(partneruser){
			Boolean b = PRMPartnerPORCheck.checkActivePOR(accId);
			System.assertEquals(true,b);			
		}
    }
    
    @isTest
    public static void testNegativeScenario(){
		User partneruser = [select id from user where username='b2btestewwrpdua@noemail.com'];
		System.runAs(partneruser){
			Boolean b = PRMPartnerPORCheck.checkActivePOR('0012O000007RF0pQAG');
			System.assertEquals(false,b);		
		}
    }   
    @isTest
    public static void testExceptionScenario(){
        Boolean b=null;
		User partneruser = [select id from user where username='b2btestewwrpdua@noemail.com'];
		System.runAs(partneruser){
            try{
				b = PRMPartnerPORCheck.checkActivePOR(null);
            }
            catch(Exception e){}
			System.assertEquals(false,b);		
		}
    }     
}