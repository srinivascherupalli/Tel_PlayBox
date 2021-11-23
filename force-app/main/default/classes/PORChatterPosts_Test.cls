/* EDGE-150894 : As a Partner Admin/Manager, AE/CE/ I want Partner Of Record Approval and Rejection Chatter Notifications
B2B-1443 :Team Alexandria 
*/
@isTest(SeeAllData=true)
public class PORChatterPosts_Test {
    @isTest
    public static void testChatterPost(){
        
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        //User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        u.Phone = '3433233223';
        userList.add(u);
        insert userList;
        
        System.runAs(u){
            Test.startTest();
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            //a.add(ac);
            insert ac;
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            insert con2;
            
            //Partner_of_Record__c por = new Partner_of_Record__c();
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            acc.APTPS_Off_Shore_Restricted__c=true;
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            Partner_of_Record__c por = new Partner_of_Record__c();
            por.Customer__c = acc.id;
            por.Partner__c = ac.id;
            por.Customer_Signatories__c = acc.ownerid;
            //por.Partner_Signatories__c = por.ownerid;
            por.Status__c = 'Active';
            insert por;
            por.Partner_Signatories__c = por.ownerid;
            update por;
            
            List<Partner_of_Record__c> porList = new List<Partner_of_Record__c>();
            porList.add(por);
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Modification in progress';
            por.Status__c = 'Pending Approval';
            update por;
            
            //por.Status__c = 'Pending Approval';
            //update por;
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            //por.Sub_Status__c = 'Pending Approval';
            //update por;
            
            por.Status__c = 'Declined';
            update por;
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Customer Review';
            update por;
            //  PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Partner Review';
            update por;
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Customer Declined';
            update por;
            // PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Partner Declined';
            update por;
               
            //PORChatterPosts.sendPORStatusChatter(porList);
            por.Status__c = 'Active';
            update por;
            
            //PORChatterPosts.sendPORStatusChatter(porList);
            por.Sub_Status__c ='Pending Approval';
            update por;
            //por.Status__c = '';
            //update por;
                       
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: u.Id];
            system.assertEquals(feed.Size() > 0 ,true);     
            Test.stopTest();
        }
    }
    @isTest
    public static void testChatterPost1(){
        Test.startTest();
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        //User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        u.Phone = '3433233223';
        userList.add(u);
        insert userList;
        
        System.runAs(u){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            //a.add(ac);
            insert ac;
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            insert con2;
            
            //Partner_of_Record__c por = new Partner_of_Record__c();
            Account acc = AccountTestFactory.buildAccount('TestAcc');
            acc.APTPS_DocuSign_Restricted__c=true;
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            Partner_of_Record__c por = new Partner_of_Record__c();
            por.Customer__c = acc.id;
            por.Partner__c = ac.id;
            por.Customer_Signatories__c = acc.ownerid;
            //por.Partner_Signatories__c = por.ownerid;
            por.Status__c = 'Active';
            por.Cancelled_User__c = por.ownerid;
            por.Partner_Signatories__c = por.ownerid;
            por.Cancelled_User__c = por.ownerid;
            insert por;
            List<Partner_of_Record__c> porList = new List<Partner_of_Record__c>();
            porList.add(por);
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Partner_Signatories__c = por.ownerid;
            update por;
            //PORChatterPosts.sendPORStatusChatter(porList);
            
            por.Status__c = 'Cancelled';
            update por;
            //PORChatterPosts.sendPORStatusChatter(porList);
            por.Status__c = 'Customer Review';
            update por;
            
            FeedItem[] feed = [Select id ,Body,ParentId from FeedItem where createdById =: u.Id];
            system.assertEquals(feed.Size() > 0 ,true);     
            Test.stopTest();
        }
    }
}