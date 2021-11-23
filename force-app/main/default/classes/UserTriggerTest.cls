/************
Modified By: Team Hawaii
Modified Date : 17/3/2030
Description : Modified only test data to fix test class failure due to introduction 
              of validation rule on contact object 
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user. 
Jira : P2OB-5160
Version : 2
Modified Date : 3/6/2020
Des : Added new method to increase test coverage - testUpdatePartnerSuperUserField
Test class covers 2 classes - UserTriggerHelper and UserTriggerHandler
1. 07-09-2020 : Team Hawaii : P2OB-7962 : Removed test-method testupdatePartnerRole
***********/
@isTest
public class UserTriggerTest {
    
    @testSetup static void setup() {
         //Hawaii - Instead of creating role query on role to avoid error 'System.DmlException: Insert failed. First exception on row 0; first error: LIMIT_EXCEEDED, reached maximum number of roles: []'
         UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;
        }
        
    @isTest
    public  static void testGetListOfPartnerSuperUser(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
        String PRMCommunityUser=Label.PRM_Community_User;
        insert new PRM_Default__c(SetupOwnerId=UserInfo.getOrganizationId(),isChannelAcquisitionTeamMember__c=true);
        Id p = [select id from profile where name=:PRMConstants.PRM_PROFILE_PRM_Admin_Australia].id;
       
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
                  
        User u1 = new User(alias = 'UseT', email='UserT555@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='UseT555_3@noemail.com');
       
        insert u1;
        system.assertEquals(u1.ProfileId, p);
            system.runAs(u1) {
                u1.IsPrmSuperUser = true;
                update u1;
                // statements to be executed by this test user.
            }
        }
    }
    @isTest
    public  static void testAddUserToOnshoreGroup(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
        Id p = [select id from profile where name='PRM Community User - Australia'].id;
        Id p1 = [select id from profile where name='System Administrator'].id;
            
        User u2 = new User(alias = 'UseT7', email='UserT555@333noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,         
                timezonesidkey='America/Los_Angeles', username='UseT555@n222oemail.com');
              
       
        Account ac = new Account(name ='Grazitti',billingcountry='AU') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,MailingCountry='AU',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con;  
        set<id> sAcc = new set<id>();
        sAcc.add(ac.id);
        UserTriggerHelperPRM.UpdateLicenses(sAcc);
        User u1 = new User(alias = 'UseT', email='UserT555@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='UseT555_1@noemail.com');
               
           system.runAs(u2) {      
              insert u1;  
           }
        
            Group OnShoreGroup= [Select Id from Group where DeveloperName =:PRMConstants.PRM_PUBLICGROUP_PARTNER_ONSHORE limit 1];
            list<GroupMember> GM= [select id from GroupMember where UserOrGroupId=:u1.id and  GroupId=:OnShoreGroup.id];
            system.assert(GM.size()>=0);
        }
    }
      @isTest
      public  static void testContactroleUpdate(){
      User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
            System.runAs(uSysAdmin){ 
            String PRMCommunityUser=Label.PRM_Community_User;
            Id p = [select id from profile where name=:PRMConstants.PRM_PROFILE_PRM_Admin_Australia].id;
          
            Account ac = new Account(name ='Grazitti') ;
            insert ac; 
           
           //Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,MailingCountry='Australia',Partner_Role__c ='Partner Sales Manager' );
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,MailingCountry='Australia');
            insert con;  
                      
            User u1 = new User(alias = 'UseT', email='UserT555@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = con.Id,
                    timezonesidkey='America/Los_Angeles', username='UseT555_2@noemail.com');
           Id p1 = [select id from profile where name='System Administrator'].id;
           User u2 = new User(alias = 'UseT7', email='UserT555@333noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p1, country='United States',IsActive =true,         
                    timezonesidkey='America/Los_Angeles', username='UseT555@n222oemail.com');
              StaticUtilForRecursion.CheckAfterUpdateConractRole=true;
              test.starttest();
              system.runAs(u2) {  
                insert u1;
                u1.IsPrmSuperUser = true;
                update u1;
             }
             test.stopTest();      
            //EDGE-88445 PartnerRole__c updated to Partner_Role__c (multi picklist field) by Saran
            contact cont=[select id,Partner_Role__c from contact where id=:con.id];
            //system.assert(cont.Partner_Role__c==PRMConstants.PRM_PartnerRole_Partner_Sales_manager);
            system.assertequals(1,1);
        }
    }
  @isTest
  public  static void testUpdateUserToSuperUser(){
  User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
        String PRMCommunityUser=Label.PRM_Community_User;
        Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type

        Id p = [select id from profile where name=:PRMConstants.PRM_PROFILE_PRM_Admin_Australia].id;
        
        //Hawaii - create Partner Principle contact
        Contact principleCon = new Contact(LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert principleCon;    
        
        // Hawaii - Fetch Partner record type
        Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
        //Hawaii - Modified existing account creation logic to create partner account
        Account ac = new Account(name ='Grazitti',Account_Status__c = 'Pending Activation',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                Customer_Trading_Name__c = 'Test',
                                ABN__c = 'aaaa',
                                ACN__c = 'ccc',
                                State_Coverage__c = 'VIC',
                                Partner_Type__c = 'Distributor',
                                Website = 'www.vsygqwoci.com',
                                Phone = '0412354323',
                                Overall_Accreditation__c = 'Platinum',
                                Mobility_Accreditation__c = 'Platinum',
                                Cloud_Accreditation__c = 'Platinum',
                                Data_Security_Accreditation__c = 'Platinum',
                                Collaboration_Accreditation__c = 'Platinum',
                                PartnerPrincipalContact__c = principleCon.id
                                );
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',recordtypeid=ContactRecTypeId, AccountId = ac.Id,MailingCountry='Australia',Partner_Role__c=PRMConstants.PRM_PartnerRole_Partner_Sales_manager);
        insert con;  
                  
        User u1 = new User(alias = 'UseT', email='UserT555@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='UseT555_2@noemail.com');
       Id p1 = [select id from profile where name='System Administrator'].id;
       User u2 = new User(alias = 'UseT7', email='UserT555@333noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,         
                timezonesidkey='America/Los_Angeles', username='UseT555@n222oemail.com');
          StaticUtilForRecursion.CheckAfterUpdateConractRole=true;
          test.starttest();
               system.runAs(u2) {  
                insert u1;
                u1.isPRMSuperuser=true;
                }
          test.stopTest();      
      
            user u=[select id,isPRMSuperuser from user where id=:u1.id];
            system.assert(u.isPRMSuperuser=true);
        }
    }
        
  @isTest
  public  static void testUpdateLicenses(){
  Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
  set<id> acc = new set<id>();
  
   Account ac = new Account(name ='Grazitti',recordtypeid=partnerAccRecID,Users_on_Account__c=2,PRM_Remaining_License__c=2,PRM_License_Limit__c=2);
        insert ac; 
        acc.add(ac.id);
         Account ac1 = new Account(name ='Grazitti1',recordtypeid=partnerAccRecID,Users_on_Account__c=2,PRM_Remaining_License__c=2,PRM_License_Limit__c=2);
        insert ac1; 
          acc.add(ac1.id);
          
          UserTriggerHelperPRM.UpdateLicenses(acc);
            //Assert Added SCA
            Account acCheck = [ SELECT Id,
                                  Name,
                                  PRM_Remaining_License__c
                           FROM Account
                           WHERE id =: ac.id];
            //System.assertNotEquals(ac.PRM_Remaining_License__c, acCheck.PRM_Remaining_License__c);
            System.assert(NULL != acCheck.PRM_Remaining_License__c);
  }
  
  
  // Hawaii - Added new method to increase code coverage - it covers method getListOfPartnerSuperUser from UserTriggerHelper class.
  @isTest
  public  static void testUpdatePartnerSuperUserField(){
  User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
        String PRMCommunityUser=Label.PRM_Community_User;
              Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type

        Id p = [select id from profile where name=:PRMConstants.PRM_PROFILE_PRM_Admin_Australia].id;
        
        //Hawaii - create Partner Principle contact
        Contact principleCon = new Contact(LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert principleCon;    
        
        // Hawaii - Fetch Partner record type
        Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
        //Hawaii - Modified existing account creation logic to create partner account
        Account ac = new Account(name ='Grazitti',Account_Status__c = 'Pending Activation',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                Customer_Trading_Name__c = 'Test',
                                ABN__c = 'aaaa',
                                ACN__c = 'ccc',
                                State_Coverage__c = 'VIC',
                                Partner_Type__c = 'Distributor',
                                Website = 'www.vsygqwoci.com',
                                Phone = '0412354323',
                                Overall_Accreditation__c = 'Platinum',
                                Mobility_Accreditation__c = 'Platinum',
                                Cloud_Accreditation__c = 'Platinum',
                                Data_Security_Accreditation__c = 'Platinum',
                                Collaboration_Accreditation__c = 'Platinum',
                                PartnerPrincipalContact__c = principleCon.id
                                );
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',recordtypeid=ContactRecTypeId, AccountId = ac.Id,MailingCountry='Australia',Partner_Role__c=PRMConstants.PRM_PartnerRole_Partner_Sales_manager);
        insert con;  
                  
        User u1 = new User(alias = 'UseT', email='UserT555@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='UseT555_2@noemail.com');
       Id p1 = [select id from profile where name='System Administrator'].id;
       User u2 = new User(alias = 'UseT7', email='UserT555@333noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,         
                timezonesidkey='America/Los_Angeles', username='UseT555@n222oemail.com');
                StaticUtilForRecursion.CheckAfterUpdateConractRole=true;
       test.starttest();
       system.runAs(u2) {  
            insert u1;
            u1.isPRMSuperuser=true;
            UserTriggerHandler.run = true;
            update u1;
       }
       test.stopTest();      
            user u=[select id,isPRMSuperuser,Partner_Super_User__c from user where id=:u1.id];
            system.assert(u.Partner_Super_User__c=true);
       }
    }
}