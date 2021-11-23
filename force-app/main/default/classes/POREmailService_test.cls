@isTest
public class POREmailService_test{
    @isTest
    public static void testPOREmailService(){
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
            insert acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            Partner_of_Record__c por = new Partner_of_Record__c();
            por.Customer__c = acc.id;
            por.Partner__c = ac.id;
            por.Customer_Signatories__c = acc.ownerid;
            //por.Partner_Signatories__c = por.ownerid;
            por.Status__c = 'Cancelled';
            insert por;
            
            List<string> porList = new List<string>();
            porList.add(por.id);
            
            POREmailService.processOrderRecord(porList);
            Partner_of_Record__c[] porRec = [Select id ,Status__c from Partner_of_Record__c where createdById =: u.Id];
            system.assertEquals(porRec.Size() > 0 ,true); 
            
            test.stoptest();
        }
    }
}