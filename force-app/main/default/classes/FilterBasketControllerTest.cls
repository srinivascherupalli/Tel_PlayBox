/*************************************************************************************************
Name : FilterBasketControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Vaibhav          20-Nov-2020      EDGE-185069 - Created

===============================================================================================================================
***************************************************************************************************/

@isTest
public class FilterBasketControllerTest {

      @testSetup
    static void setup()
    {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; 
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        List<user> userList = new List<user>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com');
        User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',userroleid=r.id,
                              username='TestingAdmin@TestingAdmin.com');
        userList.add(sales);
        userList.add(admin);
        insert userList;
        System.runAs(admin){
            //Sprint 20.07 :P2OB-6382
            list<Account> acclist =new list<Account>();
            for(integer a=0;a<2;a++){
                Account customerAccount=TestUtil.createAccount('Testacc'+a);
                customerAccount.OwnerId=sales.id;
                acclist.add(customerAccount);
       }
            insert acclist;
            
            list<Contact> conlist =new list<Contact>();
            for(integer i=0;i<10;i++){
                Contact con1 = TestUtil.createContact(acclist[0].id,'First'+i,'Last'+i);
                con1.OwnerId=sales.id;
                conlist.add(con1);
       }
            insert conlist;
         //Sprint 20.07 :P2OB-6382, creating acr to view secondary contacts in account related list    
             list<AccountContactRelation> ACRlist =new list<AccountContactRelation>();
             for(Contact currentContact : conlist){
               AccountContactRelation ACR=new AccountContactRelation(Accountid=acclist[1].id,Contactid=currentContact.id, roles = System.Label.Contact_Limited_Authority_Value);
                ACRlist.add(ACR);
            }
            insert ACRlist;
            
            //EDGE-51592
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            Profile prmProfile = [select id from profile where name ='PRM Community User - Australia'];
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{prmProfile} ,new List<Contact>{con} ,false);
            insert partnerUser;
            
            Account[] enterpriseAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : enterpriseAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert enterpriseAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),enterpriseAccount.get(0).Id);
             insert customerContacts;
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            update customerContacts;
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=enterpriseAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                                Partner__c=acc[0].Id,Partner_Signatories__c= con.Id,Status__c='Active'); 
            insert POR;
        }
    }
    
     @isTest
    static void filterContactsControllerGetListViwe(){
       Test.startTest();
        User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
        System.runAs(sales){
            ListView accListview = FilterBasketController.getListViews('Account',System.Label.AccountListViewRelatedContacts);
            system.assertEquals([SELECT Id, Name FROM ListView WHERE SobjectType = 'Account'  and DeveloperName = :System.Label.AccountListViewRelatedContacts LIMIT 1], accListview);
        }
       Test.stopTest();
    }
    
      @isTest
    static void fgetRelatedListtest(){
       Test.startTest();
        Account acc = [Select id,name from Account  Limit 1 ];
        
            list<cscfga__Product_Basket__c> accListview = FilterBasketController.getRelatedList(acc.id) ;
            system.assertNotEquals(accListview.isEmpty(), false);
       
       Test.stopTest();
    }
}