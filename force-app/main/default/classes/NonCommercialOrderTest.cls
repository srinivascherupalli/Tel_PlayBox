/*************************************************************************************************
Name : NonCommercialOrderTest
Test Class For : NonCommercialOrder
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             30-Oct-2020   EDGE-182452(new)
2. 		   Gnana			  30-Oct-2020	EDGE-182454 - Added test methods
===============================================================================================================================
***************************************************************************************************/
@isTest
public class NonCommercialOrderTest {
    
    @testSetup public static void setup(){
          
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        //EDGE-182452(new) start ----
        List<User> userTobeInserted=new List<User>();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        
        userTobeInserted.add(sales);
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com', userroleid = r.id);
       	userTobeInserted.add(uSysAdmin);
        //EDGE-182452 end ---
        insert userTobeInserted;
        User partneruser;
        System.runAs(uSysAdmin){
            id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
            List<Account> accList=new List<Account>();
            Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
            accList.add(ac);
            //added by shubhi
            Account testAccount = AccountTestFactory.buildAccount('testAccount');
        	testAccount.ownerid=sales.id;
            accList.add(testAccount);
        	insert accList;//added by shubhi end 
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
    
    // Added as part of EDGE-182454
    @isTest
    public static void testCheckEligibleUserPositive(){
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;	
		User partneruser = [select id from user where username='b2btestewwrpdua@noemail.com'];
		System.runAs(partneruser){
			Boolean b = NonCommercialOrder.checkEligibleUser(accId);
			System.assertEquals(true,b);			
		}
    }
	
    // Added as part of EDGE-182454
    @isTest
    public static void testCheckEligibleUserNegative(){
		User partneruser = [select id from user where username='b2btestewwrpdua@noemail.com'];
        account acc=[select id from Account where name='testAccount' limit 1];
		System.runAs(partneruser){
			Boolean b = NonCommercialOrder.checkEligibleUser(acc.id);
			System.assertEquals(false,b);		
		}
    }  
    
    // Added as part of EDGE-182454
    @isTest
    public static void testCheckEligibleUserCRMUser(){  
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;	
		User crmuser = [select id from user where username='Testadmin00097@noemail.com'];
		System.runAs(crmuser){
			Boolean b = NonCommercialOrder.checkEligibleUser(accId);
			System.assertEquals(true,b);			
		}
    }
    //EDGE-182452(new) start  added by shubhi----
    @isTest
    public static void testCreateNonCommercialBasket(){  
		Test.startTest();
        User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
        Account custAccount=[select id,ownerid from Account where name='testAccount' limit 1];
        Id accId = custAccount.Id;
		System.runAs(crmuser){
			String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
            cscfga__Product_Basket__c basket=[select id,BasketType__c from cscfga__Product_Basket__c limit 1];
			System.assertEquals(Label.Non_Commercial,basket.BasketType__c);			
		}
        Test.stopTest();
    }
    @isTest 
    public static void testCreateNonCommercialBasketNegative(){  
        Test.startTest();
            Id accId ;	
            User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
            System.runAs(crmuser){
                String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
                System.assertEquals('',basketId);			
            }
        Test.stopTest();
    }
    @isTest
    public static void testinsertSobjectCatch(){
        Test.startTest();
        User crmuser = [select id from user where email='salesuser@testsales.com' limit 1];
        Account custAccount=[select id,ownerid from Account where name='TEST_ACCOUNT0' limit 1];
        Id accId = custAccount.Id;
   		System.runAs(crmuser){
            try{
                String basketId = NonCommercialOrder.CreateNonCommercialBasket(accId);
         	 	cscfga__Product_Basket__c basket=[select id,BasketType__c from cscfga__Product_Basket__c limit 1];
          		System.assertEquals(Label.Non_Commercial,basket.BasketType__c); 
            }catch(exception e){
                System.debug('exception'+e);
            }
                
        }
        Test.stopTest();
    }

    //EDGE-182452(new) end ----
}