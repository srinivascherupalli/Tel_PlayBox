/* 
 * Created By : Team Hawaii
 * Created Date : 4/3/2020
 * Jira : P2OB-5510 & P2OB - 5637
 * Des : Test class to cover logic chatter by Partner user to Internal User
 * Covered Class : PRMChatterToInternalUser
 * DUPLICATE_USERNAME Fixes - Hawaii - 02-09-2020
  * 1.0        19 Mar 2021           Vivian Charlie [Hawaii]   P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
12 Nov 2021 : removing account lookup assignment from Contact for 21.15 FDR fix
*/

@isTest
public class PRMChatterToInternalUserTest {
  
    // Test Data creation
    @testSetup static void setup() {
        
        Test.startTest();
      Map<String,Profile> profileMap = new Map<String,Profile>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof);
        }
        
        UserRole userRole = [Select id,Name from UserRole where Name = 'CEO']; 
        // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
        List<User> adminUserList = PRMTestUtility.createInternalUsers(2, new List<Profile>{profileMap.get('System Administrator')}, userRole) ;
        insert adminUserList;
        /*User systemAdminUser = new User(alias = 'PART', email='test@noemail1234.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileMap.get('System Administrator'), country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='test@noemail.com1',UserRoleId=userRole.Id);
            adminUserList.add(systemAdminUser);
        User systemAdminUser1 = new User(alias = 'PART', email='test@noemail1234.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileMap.get('System Administrator'), country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='test1@noemail.com1',UserRoleId=userRole.Id);
            adminUserList.add(systemAdminUser1);*/
        
         
        
        system.runas(adminUserList[0]){ 
        
            List<Account> accList = new List<Account>();
            Id EntAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
            Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
            Account acc = new Account();
                acc.Name = 'Test Accountdit';
                acc.recordTypeId=EntAccRecTypeId ;
                acc.Partner_Type__c='Channel';
                acc.Customer_Status__c='ACTIVE';
                acc.Migrated_Customer__c=true;
                acc.OwnerId = adminUserList[0].Id;
                acc.UCIDN__c = 'VI28909';
                accList.add(acc);
            insert accList;
        
            List<Contact> conList = new List<Contact>();
                Contact con = new Contact();
                    con.FirstName = 'Test Account';
                    con.LastName='Last Name';
                    con.AccountId=accList[0].Id;
                conList.add(con);
              Contact partCon = new Contact();
                    partCon.FirstName = 'Test Account1';
                    partCon.LastName='Last Name1';
                    //partCon.AccountId=accList[0].Id; // 21.15 FDR fix
              conList.add(partCon);
            insert conList;
            
            Account partneracc = new Account();
            partneracc.RecordTypeId = partnerAccRecTypeId;
            partneracc.Name = 'Test Accountdit2';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c = 'aaaa';
            partneracc.ACN__c = 'ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c = 'Distributor';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone = '0412354323';
            partneracc.Overall_Accreditation__c = 'Platinum';
            partneracc.Mobility_Accreditation__c = 'Platinum';
            partneracc.Cloud_Accreditation__c = 'Platinum';
            partneracc.Data_Security_Accreditation__c = 'Platinum';
            partneracc.Collaboration_Accreditation__c = 'Platinum';
            partneracc.PartnerPrincipalContact__c = conList[0].id;
            partneracc.UCIDN__c = 'VI28909';
                
            insert partnerAcc;
            accList.add(partnerAcc);
            accList[1].isPartner = True;
            accList[1].PartnerPrincipalContact__c = conList[1].Id;
            update accList[1];
            conList.get(1).AccountId = accList[1].Id;
            update conList;
            
            // DUPLICATE_USERNAME - Hawaii - 02-09-2020
            List<User> userList = PRMTestUtility.createPartnerUsers(1, new List<Profile>{profileMap.get('PRM Community User - Australia')}, new List<Contact>{conList[1]},true);
            insert userList;
             Test.stopTest();
        }
  }
    
    //Test Method to post chatter tp internal User when share with partner status is Approved
    public static testMethod void testChatterFeedOnApproved(){
        Test.startTest();
         Account[] acc = [Select id,Name from Account where Name IN ('Test Accountdit','Test Accountdit2')];
        Contact con = [Select id,AccountId from Contact where AccountId =:acc[0].Id limit 1];
        Map<String,User> userMap = new Map<String,User>(); 
        // Hawaii - test class fixes - 02-09-2020
        User[] usList = [Select id,UserName,ProfileId,Profile.Name from User Where  Email IN ('test@noemail1234.com0','test@noemail45345555.com0')];
        for(User us : usList){
            userMap.put(us.Profile.Name,us);
        }
        system.runAs(userMap.get('System Administrator')){
            Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); // 1.0
      List<Lead> leadList = new List<Lead>();
      Lead le = new Lead();
        le.FirstName = 'Test Lead';
        le.RecordTypeId = LeadRecTypeId;
        le.Status = 'Marketing Qualified';
        le.Company = 'Test Company';
        le.Job_Function__c = 'Board member';
        le.LastName = 'Last Name'+1;
        le.Email = 'test@gmail.com';
        le.LeadSource = 'Customer Care';
        le.Customer_Name__c = acc[0].Id;
        le.Contact_Name__c = con.Id;
              le.OwnerId = userMap.get('System Administrator').Id;
              le.PartnerAccountId = acc[1].Id;
              le.Partner_Principal_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Share_with_Partner_Status__c='Approved';
              le.Shared_By__c = userMap.get('System Administrator').Id;
        leadList.add(le);
      insert leadList;
            List<Id> idList = new List<Id>();
            for(Lead lead : leadList){
                idList.add(lead.id);
            }
            PRMChatterToInternalUser.addChatter(idList);
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: userMap.get('System Administrator').Id];
            system.assertEquals(feed.Size() > 0 ,true);
        }
        Test.stopTest();
    }
    
    //Test Method to post chatter tp internal User when share with partner status is Rejected
    public static testMethod void testChatterFeedOnRejected(){
        Test.startTest();
         Account[] acc = [Select id,Name from Account where Name IN ('Test Accountdit','Test Accountdit2')];
        Contact con = [Select id,AccountId from Contact where AccountId =:acc[0].Id limit 1];
        Map<String,User> userMap = new Map<String,User>(); 
        // Hawaii - test class fixes - 02-09-2020
        User[] usList = [Select id,UserName,ProfileId,Profile.Name from User Where  Email IN ('test@noemail1234.com0','test@noemail45345555.com0')];
        for(User us : usList){
            userMap.put(us.Profile.Name,us);
        }
        system.runAs(userMap.get('System Administrator')){
            Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); // 1.0
      List<Lead> leadList = new List<Lead>();
      Lead le = new Lead();
        le.FirstName = 'Test Lead';
        le.RecordTypeId = LeadRecTypeId;
        le.Status = 'Marketing Qualified';
        le.Company = 'Test Company';
        le.Job_Function__c = 'Board member';
        le.LastName = 'Last Name'+1;
        le.Email = 'test@gmail.com';
        le.LeadSource = 'Customer Care';
        le.Customer_Name__c = acc[0].Id;
        le.Contact_Name__c = con.Id;
              le.OwnerId = userMap.get('System Administrator').Id;
              le.PartnerAccountId = acc[1].Id;
              le.Partner_Principal_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Share_with_Partner_Status__c='Rejected';
              le.Declined_Reason__c = 'Other';
              le.Declined_Comments__c = 'Test Reason';
              le.Shared_By__c = userMap.get('System Administrator').Id;
        leadList.add(le);
      insert leadList;
            List<Id> idList = new List<Id>();
            for(Lead lead : leadList){
                idList.add(lead.id);
            }
            PRMChatterToInternalUser.addChatter(idList);
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: userMap.get('System Administrator').Id];
            system.assertEquals(feed.Size() > 0 ,true);
        }
        Test.stopTest();
    }
    
    //Test Method to post chatter tp internal User when status is Recycled
    public static testMethod void testChatterFeedOnRecycledStatus(){
        Test.startTest();
         Account[] acc = [Select id,Name from Account where Name IN ('Test Accountdit','Test Accountdit2')];
        Contact con = [Select id,AccountId from Contact where AccountId =:acc[0].Id limit 1];
        Map<String,User> userMap = new Map<String,User>(); 
        // Hawaii - test class fixes - 02-09-2020
        User[] usList = [Select id,UserName,ProfileId,Profile.Name from User Where  Email IN ('test@noemail1234.com0','test@noemail45345555.com0')];
        for(User us : usList){
            userMap.put(us.Profile.Name,us);
        }
        system.runAs(userMap.get('System Administrator')){
            Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); // 1.0
      List<Lead> leadList = new List<Lead>();
      Lead le = new Lead();
        le.FirstName = 'Test Lead';
        le.RecordTypeId = LeadRecTypeId;
        le.Status = 'Recycled';
        le.Company = 'Test Company';
        le.Job_Function__c = 'Board member';
        le.LastName = 'Last Name'+1;
        le.Email = 'test@gmail.com';
        le.LeadSource = 'Customer Care';
        le.Customer_Name__c = acc[0].Id;
        le.Contact_Name__c = con.Id;
              le.OwnerId = userMap.get('System Administrator').Id;
              le.PartnerAccountId = acc[1].Id;
              le.Partner_Principal_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Distributor_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Share_with_Partner_Status__c='Approved';
              le.Shared_By__c = userMap.get('System Administrator').Id;
              le.Rating = 'In Progress';
              le.PRM_Reject_Recycle_Reason__c = 'Other, Please specify';
              le.Please_Specify__c = 'Test';
        leadList.add(le);
      insert leadList;
            system.debug('Lead List valueis' +leadList);
            List<Id> idList = new List<Id>();
            for(Lead lead : leadList){
                idList.add(lead.id);
            }
            PRMChatterToInternalUser.addChatter(idList);
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: userMap.get('System Administrator').Id];
            system.assertEquals(feed.Size() > 0 ,true);
        }
        Test.stopTest();
    }
    
    //Test Method to post chatter tp internal User when status is Rejected
    public static testMethod void testChatterFeedOnRejectedStatus(){
        Test.startTest();
         Account[] acc = [Select id,Name from Account where Name IN ('Test Accountdit','Test Accountdit2')];
        Contact con = [Select id,AccountId from Contact where AccountId =:acc[0].Id limit 1];
        Map<String,User> userMap = new Map<String,User>(); 
        // Hawaii - test class fixes - 02-09-2020
        User[] usList = [Select id,UserName,ProfileId,Profile.Name from User Where  Email IN ('test@noemail1234.com0','test@noemail45345555.com0')];
        for(User us : usList){
            userMap.put(us.Profile.Name,us);
        }
        system.runAs(userMap.get('System Administrator')){
            Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); // 1.0
      List<Lead> leadList = new List<Lead>();
      Lead le = new Lead();
        le.FirstName = 'Test Lead';
        le.RecordTypeId = LeadRecTypeId;
        le.Status = 'Rejected';
        le.Company = 'Test Company';
        le.Job_Function__c = 'Board member';
        le.LastName = 'Last Name'+1;
        le.Email = 'test@gmail.com';
        le.LeadSource = 'Customer Care';
        le.Customer_Name__c = acc[0].Id;
        le.Contact_Name__c = con.Id;
              le.OwnerId = userMap.get('System Administrator').Id;
              le.PartnerAccountId = acc[1].Id;
              le.Partner_Principal_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Distributor_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Share_with_Partner_Status__c='Approved';
              le.Shared_By__c = userMap.get('System Administrator').Id;
              le.Rating = 'In Progress';
              le.PRM_Reject_Recycle_Reason__c = 'Other, Please specify';
              le.Please_Specify__c = 'Test';
        leadList.add(le);
      insert leadList;
            List<Id> idList = new List<Id>();
            for(Lead lead : leadList){
                idList.add(lead.id);
            }
            PRMChatterToInternalUser.addChatter(idList);
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: userMap.get('System Administrator').Id];
            system.assertEquals(feed.Size() > 0 ,true);
        }
        Test.stopTest();
    }
    
    //Test Method to post chatter tp internal User when share with partner status is Submitted and Distributor Contact is not null
    public static testMethod void testChatterFeedOnRecalled(){
        Test.startTest();
         Account[] acc = [Select id,Name from Account where Name IN ('Test Accountdit','Test Accountdit2')];
        Contact con = [Select id,AccountId from Contact where AccountId =:acc[0].Id limit 1];
        Map<String,User> userMap = new Map<String,User>(); 
        // Hawaii - test class fixes - 02-09-2020
        User[] usList = [Select id,UserName,ProfileId,Profile.Name from User Where  Email IN ('test@noemail1234.com0','test@noemail45345555.com0')];
        for(User us : usList){
            userMap.put(us.Profile.Name,us);
        }
        system.runAs(userMap.get('System Administrator')){
            Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); // 1.0
      List<Lead> leadList = new List<Lead>();
      Lead le = new Lead();
        le.FirstName = 'Test Lead';
        le.RecordTypeId = LeadRecTypeId;
        le.Status = 'Marketing Qualified';
        le.Company = 'Test Company';
        le.Job_Function__c = 'Board member';
        le.LastName = 'Last Name'+1;
        le.Email = 'test@gmail.com';
        le.LeadSource = 'Customer Care';
        le.Customer_Name__c = acc[0].Id;
        le.Contact_Name__c = con.Id;
              le.OwnerId = userMap.get('System Administrator').Id;
              le.PartnerAccountId = acc[1].Id;
              le.Partner_Principal_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Distributor_Contact__c = userMap.get('PRM Community User - Australia').Id;
              le.Share_with_Partner_Status__c='Submitted';
              le.Shared_By__c = userMap.get('System Administrator').Id;
        leadList.add(le);
      insert leadList;
            List<Id> idList = new List<Id>();
            for(Lead lead : leadList){
                idList.add(lead.id);
            }
            PRMChatterToInternalUser.addChatter(idList);
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: userMap.get('System Administrator').Id];
            system.assertEquals(feed.Size() > 0 ,true);
        }
        Test.stopTest();
    }
}