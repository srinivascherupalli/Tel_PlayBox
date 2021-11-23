@isTest
public class PORuplodecontrollerTest {
    @testsetup static void testsetUpData(){
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
             acc.APTPS_DocuSign_Restricted__c=true;
            update acc;
            Contact con = AccountTestFactory.buildContact(acc,'Technical Contact');
            insert con;
            
            Partner_of_Record__c por = new Partner_of_Record__c();
            por.Customer__c = acc.id;
            por.Partner__c = ac.id;
            por.Customer_Signatories__c = acc.ownerid;
            //por.Partner_Signatories__c = por.ownerid;
            por.Status__c = 'Active';
            por.Agreement_Duration__c= '12';
            insert por;
            Partner_of_Record_Domain__c pord = new Partner_of_Record_Domain__c();
            pord.Partner_of_Record__c = por.Id;
            pord.Status__c='Customer Review';
           	pord.Domain_Name__c='Mobile';
            insert pord;
            Partner_of_Record__c porresult =PORCustomerdeclineController.checkvalue(por.Id);
            system.assertEquals(porresult.Status__c, 'Active');
            
                 }
    }
        @isTest static void updatePORStatus(){
         
       
             User u = [SELECT Id FROM User WHERE Email='testuser@test.com.sample'];
            
              System.runAs(u){
                   Test.startTest();
                   Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
                   PORuplodecontroller.checkvalue(por.Id);
                   system.assertEquals(por.Status__c, 'Active'); 
                   Test.stopTest();
              }

        }
            @isTest  
    		Public static void customeractiveTest(){
         
       
             User u = [SELECT Id FROM User WHERE Email='testuser@test.com.sample'];
            
              System.runAs(u){
                   Test.startTest();
                   Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
                   PORuplodecontroller.changestatus(por.Id);
                       
                   Partner_of_Record__c porupdated=[SELECT Id,Status__c from Partner_of_Record__c];
                   system.assertEquals(porupdated.Status__c, 'Active'); 
                   Test.stopTest();
              }

        }
     @isTest static void updatePORStatusNegative(){
         
         try{
             User u = [SELECT Id FROM User WHERE Email='testuser@test.com.sample'];
            
              System.runAs(u){
                   Test.startTest();
                   Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
                   PORuplodecontroller.checkvalue('null');
                   system.assertEquals(por.Status__c, 'Active'); 
                   Test.stopTest();
              }
             
         }
         catch(Exception e)
        {
            system.debug(' '+e.getMessage());
        }
     }
    
    @isTest  
    		Public static void customerPordactiveTest(){
         
       
             User u = [SELECT Id FROM User WHERE Email='testuser@test.com.sample'];
            
              System.runAs(u){
                   Test.startTest();
                   Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
                   PORuplodecontroller.changestatus(por.Id);
                       
                   Partner_of_Record_Domain__c pordupdated=[SELECT Id,Status__c from Partner_of_Record_Domain__c];
                   system.assertEquals(pordupdated.Status__c, 'Active'); 
                   Test.stopTest();
              }
            }
            @isTest  
            Public static void startdateTest(){
       
     
           User u = [SELECT Id FROM User WHERE Email='testuser@test.com.sample'];
          
            System.runAs(u){
                 Test.startTest();
                 Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
                 PORuplodecontroller.changestatus(por.Id);
                     
                 Partner_of_Record__c porupdated=[SELECT Id,Status__c,Start_Date__c from Partner_of_Record__c];
                 system.assertEquals(porupdated.Start_Date__c, system.today()); 
                 Test.stopTest();
            }
          }
}