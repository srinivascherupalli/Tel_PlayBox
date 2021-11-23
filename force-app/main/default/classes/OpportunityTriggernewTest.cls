/*************************************************************************************************
Name : OpportunityTriggernewTest
Description : Test class for Opportunity triggernew on Opportunity
Last Updated on 9-01-2020 , for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
14 July 2021 : Vivian : Changing location of startTest and stopTest
14 July 2021 : Bhargava : Adding permissioin set to Partner user
05 Aug 2021 : Vivian : Commenting testOppContactRoleValidation method 
***************************************************************************************************/
@isTest
public class OpportunityTriggernewTest
{
    @testSetup public static void setup(){
    
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
            rolesMap.put(role.DeveloperName, role);
                    
      //UserRole r = [SElect id from UserRole where Name=: 'CEO'];
      //profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
      User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =profilesMap.get('System Administrator').id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=rolesMap.get('CEO').id);
                insert uSysAdmin;
                
        System.runAs(uSysAdmin){  //EDGE-151595
            
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,new List<Contact>{con} ,false);
            partnerUser[0].alias='PART0820';
            insert partnerUser;
             User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        List<PermissionSet> myPermissionSetId=[SELECT Id from PermissionSet WHERE Name='Active_PRM_Community_User_Australia' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = myPermissionSetId[0].Id, AssigneeId = u.Id);
        insert psa;   
            
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
            insert customerContacts;
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            Update customerContacts;
            Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
            Contact partnerContact=[select id from Contact where name='testCon'];
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                                Partner__c=partnerAccount.Id,Partner_Signatories__c= partnerContact.Id,Status__c='Active'); 
            insert POR;
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount.get(0));     
            insert opp;            
        }               
    }
    
    /*
    @isTest
    public static void testOppContactRoleValidation()
    {   
        
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
        insert accdis2;
        System.assertEquals(accdis2.Name, 'Test Accountdit2');
        
        System.runAs(uSysAdmin){
            Set<String> customerUserTypes = new Set<String> {'PRM Community User - Australia'};
                Profile p2 = [select Id,name from Profile where Name in :customerUserTypes limit 1];
            id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
            
            Account testAcc2 = new Account(Name='testAcc', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=rtypeId2,Primary_Distributor__c=accdis2.id);
            Insert testAcc2;
            
            Contact con1 = new Contact();
            con1.AccountId = testAcc2.Id;
            con1.LastName = 'TestLastName';
            con1.Email = 'test@test345345345345.com';
            con1.Phone = '+911234567891'; 
            con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
            con1.Onboarding_Status__c='Active';
            insert con1;  
            Test.startTest();
            
            User u2 = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid =p2.id, country='United States',IsActive =true,
                               ContactId = con1.Id,
                               timezonesidkey='America/Los_Angeles', username='Cont987657w9@noemail.com');
            
            insert u2;
            
            testAcc2.recordtypeid=rtypeId2;
            testAcc2.IsPartner=TRUE;
            testAcc2.Account_Status__c='Active';
            testAcc2.Customer_Trading_Name__c = 'Test';
            testAcc2.ABN__c='aaaa';
            testAcc2.ACN__c='ccc';
            testAcc2.PartnerPrincipalContact__c=con1.id;
            testAcc2.State_Coverage__c = 'SA';
            testAcc2.Partner_Type__c='Partner';
            testAcc2.Website='www.vsygwoci.com';
            testAcc2.Phone='0412354323';
            testAcc2.Overall_Accreditation__c='Platinum';
            testAcc2.Mobility_Accreditation__c='Platinum';
            testAcc2.Cloud_Accreditation__c='Platinum';
            testAcc2.Data_Security_Accreditation__c='Platinum';
            testAcc2.Collaboration_Accreditation__c='Platinum';
            
            update testAcc2;
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('TestAccount') ;
            acc.Customer_Status__c='Acquired';
            insert acc;
            
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            insert opp;
            
            try {
                //CREATE OPPORTUNITY
                opp.Partner_Account__c=testAcc2.id;
                update opp;
                Test.stoptest();
                System.assertNotEquals(null,opp);
            }
            catch (DmlException e) {
                String message = e.getMessage();
                System.assert(message.contains('Add a customer contact via the Contact Roles section, before submitting to a Partner'), 'message=' + message);
            }
            
            
        }
    }*/
    
    @isTest
    public static void testActivePOR(){//EDGE-151595 Active POR scenario
        Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;
        Opportunity opp = [select id from Opportunity where AccountId= :accId];
        opp.PartnerAccountId = partnerAccount.Id;
        opp.Product_Type__c = 'Modular';
        update opp;
        Opportunity opp2 = [select id,isPOROpportunity__c from Opportunity where AccountId= :accId];
        System.assertEquals(true,opp2.isPOROpportunity__c );
    }
    
    @isTest
    public static void testInactivePOR(){//EDGE-151595 Non POR scenario
        OpportunityTriggernewHelper oppHlpr = new OpportunityTriggernewHelper();
        oppHlpr.validateContactrole(null,null,null);
        oppHlpr.updatePORStatus(null,null);
        Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;
        Opportunity opp = [select id from Opportunity where AccountId= :accId];
        opp.Product_Type__c = 'Non Modular';
        try{update opp;}
        catch(Exception e){}
        Opportunity opp2 = [select id,isPOROpportunity__c from Opportunity where AccountId= :accId];
        System.assertEquals(false,opp2.isPOROpportunity__c );
    }  
    
    @isTest
    public static void testNewPOROpp(){//EDGE-151595 New Opp scenario
        User u = [SELECT Id FROM User WHERE alias = 'PART0820' LIMIT 1];
        Account custAccount=[select id from Account where name='TEST_ACCOUNT0'];
        Id accId = custAccount.Id;      
        AccountShare AccShare = new AccountShare(AccountId = accId, 
        AccountAccessLevel = 'Edit', 
        OpportunityAccessLevel = 'Read',
        CaseAccessLevel = 'Read', 
        UserOrGroupId = u.Id);
        Insert AccShare;        
        Test.startTest();
            System.runAs(u){
                Opportunity opp  = new Opportunity();
                opp.Name = 'TestOpp1122';
                opp.AccountID = accId;
                opp.Product_Type__c = 'Modular';
                opp.StageName = 'Committed';
                opp.CloseDate = System.today();
                insert opp;
            }
        Test.stopTest();        
            Opportunity opp3 = [select id,isPOROpportunity__c from Opportunity where Name = 'TestOpp1122'];        
        System.assertEquals(true,opp3.isPOROpportunity__c );        
    }
}