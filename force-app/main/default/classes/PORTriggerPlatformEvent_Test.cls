@isTest
public class PORTriggerPlatformEvent_Test {
    @isTest
    public static void testPlatformEvent(){
     Test.startTest();
       /* List<User> userList = new List<User>();
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        admin.Phone = '3433233223';// P2OB-6753 - added Phone
        userList.add(admin);
        insert userList;

        System.runAs(admin){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            a.add(ac);
            insert a;
    */
    
    //Partner_of_Record__c por = new Partner_of_Record__c();
    Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;
    Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
        insert con;
    
    Partner_of_Record__c por = new Partner_of_Record__c();
    por.Customer__c = acc.id;
    //por.Partner__c
    por.Customer_Signatories__c = acc.ownerid;
    //por.Partner_Signatories__c
    por.Status__c = 'Active';
    insert por;
        /* 
     Partner_of_Record__c por = [SELECT id, Name, por_status__c, OwnerId, 
                            Account_Executive__c, CreatedDate, Customer__c 
                            from Partner_of_Record__c WHERE Id = 'aBo2N000000005f']; 
    */   //get the partner of record details
    
    
    List<Partner_of_Record__c> porList = new List<Partner_of_Record__c>();
    porList.add(por); 

            Test.stopTest();
        }
   // }
}