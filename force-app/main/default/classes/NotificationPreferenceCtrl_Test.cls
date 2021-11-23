@isTest
public with sharing class NotificationPreferenceCtrl_Test {
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-171180,EDGE-172362
Descripton : data setup
-------------------------------------------------------------------------------------*/ 
    @testSetup 
    public static void setupdata(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.MobilePhone = '0445678006';
        c.Pref_Comm_Method__c='eMail';
        c.Email ='abc@gmail.com';
        c.Email_status__c = false;
        insert c;
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        TestUtil.addContactToAccount(acc.Id, c.Id);
        list<Notification_Preference__c> listPref = new list<Notification_Preference__c>();
        Notification_Preference__c pref = new Notification_Preference__c();
        pref.Account_Id__c = acc.id;
        pref.Contact_Id__c = c.id;
        pref.Name = 'Test pref';

        pref.Communication_Method__c='Email';

        listPref.add(pref);
        
        Notification_Preference__c pref1 = new Notification_Preference__c();
        pref1.Account_Id__c = acc.id;
        pref1.Contact_Id__c = c.id;
        pref1.Name = 'Test pref2';

        pref1.Communication_Method__c='EMAIL';

        listPref.add(pref1);
        insert listPref;
    }
    static testMethod void  getPreferences_test() {
	Account ac = TestUtil.createAccount('Test');
        insert ac;
		Account ac1 = TestUtil.createAccount('Test1');
        insert ac1;
		Account ac2 = TestUtil.createAccount('Test2');
        insert ac2;
		
        //Contact con2 = new Contact(LastName ='testCon2',FirstName = 'testConFirst',AccountId = ac.Id);
        //insert con2;
        Contact con2 = TestUtil.createContact(ac.Id,'ConFirst','ConLast');
        insert con2;
        
        csord__Order__c ord = new csord__Order__c();
        ord.Name = 'TestOrder';
        ord.csord__Account__c = ac.Id;
        ord.csord__Identification__c = 'test Indentification';
        insert ord;
        
        list<Notification_Preference__c> listPref = new list<Notification_Preference__c>();
        Notification_Preference__c pref = new Notification_Preference__c();
        pref.Account_Id__c = ac.id;
        pref.Contact_Id__c = con2.id;
        pref.Name = 'Test pref';

        insert pref;
        

        Notification_Preference__c pref1 = new Notification_Preference__c();
        pref1.Account_Id__c = ac.id;
        pref1.Contact_Id__c = con2.id;
        pref1.Name = 'Test pref2';

       insert pref1;
        insert listPref;
        NotificationPreferenceCtrl.getPreferences(ac.id,con2.id,ord.id,'IR Welcome','');
        List <Notification_Preference__c> preference =  [select id from Notification_Preference__c where 
                                                         Account_Id__c=:ac.id];
         System.assertEquals(preference.size()>0,true);

    }
    
    static testMethod void  getServiceNumbers_test() {

        csord__Subscription__c sub = new csord__Subscription__c();
        sub.csord__Identification__c = 'Indetification';
        sub.Name = 'test sub';
        insert sub;

        csord__Service__c csord = new csord__Service__c();
        csord.csord__Subscription__c = sub.id;
        csord.serviceMSISDN__c = 'SVC-1234';
        csord.csord__Identification__c = 'test';
        csord.Name = 'test';
        insert csord;

        Notification_Preference__c notity = new Notification_Preference__c();
       // notity.serviceMSISDN__c  = 'SVC-001234'
        notity.Service_Id__c = csord.id;
        notity.Name = 'Test pref1';
        insert notity;

        Notification_Preference__c notity1 = new Notification_Preference__c();
        //notity1.service_MSISDN__c  = 'SVC-001235';
        notity.Service_Id__c = csord.id;
        notity1.Name = 'Test pref2';
        insert notity1;

        list<sobject> obj = NotificationPreferenceCtrl.getServiceNumbers('SVC-');
        System.assertEquals(obj.size()>0,true);

    }
    /*----------------------------------------------------------------
Method : inlineUpdateNotifications
Author: Kalashree Borgaonkar
Story: EDGE-184109,EDGE-171180
Descripton : update notification preferences in inline datatable
-------------------------------------------------------------------------------------*/
    @isTest
    public static void inlineUpdateNotificationsTest(){
        List<Notification_Preference__c> notificationRecs = [SELECT  id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c
                                                             FROM Notification_Preference__c LIMIT 1]; 
        String inlineEditRec = '[{"id":"'+notificationRecs[0].id+'","Notification_Type__c":"Usage","IsActive__c":true,"Communication_Method__c":"SMS","service_MSISDN__c":"61474703047"}]';
        Test.startTest();
        String result = NotificationPreferenceCtrl.inlineUpdateNotifications(inlineEditRec);
        Test.stopTest();
        System.assertEquals([SELECT  count() FROM Notification_Preference__c WHERE Communication_Method__c='SMS']>0, true,'Record updated');
    }
    /*----------------------------------------------------------------
Method : inlineUpdateNotifications
Author: Kalashree Borgaonkar
Story: EDGE-184109,EDGE-171180
Descripton : update notification preferences in inline datatable
-------------------------------------------------------------------------------------*/
    @isTest
    public static void inlineUpdateNotificationsExceptionTest(){
        String inlineEditRec = '[{"id":"","Notification_Type__c":"Usage","IsActive__c":true,"Communication_Method__c":]';
        Test.startTest();
        String result = NotificationPreferenceCtrl.inlineUpdateNotifications(inlineEditRec);
        Test.stopTest();
        System.assertEquals(result!='Success', true,'Exception');
    }
    @isTest
    public static void updateBulkNotificationsTest(){
        List<Notification_Preference__c> notificationRecs = [SELECT  id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c
                                                             FROM Notification_Preference__c ]; 
        String selectedNotifications = JSON.serialize(notificationRecs);
        Contact c = [SELECT id FROM contact WHERE email='abc@gmail.com'];
        String updateDeatils='{"optin":true,"ComMethod":"Email"}';
        Test.startTest();
        String result = NotificationPreferenceCtrl.updateBulkNotifications(selectedNotifications,updateDeatils);
        Test.stopTest();
        System.assertEquals([SELECT  count() FROM Notification_Preference__c WHERE Communication_Method__c='Email']>0, true,'Record updated');
    }


     /*----------------------------------------------------------------
Method : inlineUpdateNotificationsValidationTest
Author: Aishwarya
Story: EDGE-170965
Descripton : Validation on Contact's email
-------------------------------------------------------------------------------------*/
     @isTest
    public static void inlineUpdateNotificationsValidationTest(){
        
        List<Notification_Preference__c> notificationRecs = [SELECT  id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c
                                                             FROM Notification_Preference__c WHERE Contact_Id__r.Name='Joe Bloggs' LIMIT 1]; 
        List<Contact> conList = [SELECT id,Email,Email_status__c FROM contact WHERE id =:notificationRecs[0].Contact_Id__c];
        conList[0].Email_status__c=true;
        update conList;
        String inlineEditRec = '[{"id":"'+notificationRecs[0].id+'","Contact_Id__c":"'+conList[0].id+'","Notification_Type__c":"Usage","IsActive__c":true,"Communication_Method__c":"EMAIL","service_MSISDN__c":"61474703047"}]';
        Test.startTest();
        String result = NotificationPreferenceCtrl.inlineUpdateNotifications(inlineEditRec);
        Test.stopTest();
        System.assertEquals(result=='Please choose a contact that has valid email address', true,'Record not updated');
    }
         /*----------------------------------------------------------------
Method : updateBulkNotificationsValidationTest
Author: Aishwarya
Story: EDGE-170965
Descripton : bulk update Validation on Contact's email
-------------------------------------------------------------------------------------*/
    @isTest
   public static void updateBulkNotificationsValidationTest(){
        List<Notification_Preference__c> notificationRecs = [SELECT  id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c,
                                                             Contact_Id__r.Email,Contact_Id__r.Email_status__c
                                                             FROM Notification_Preference__c ];
        String selectedNotifications = JSON.serialize(notificationRecs);
       
       	NotificationPreferenceCtrl.UpdateDetails details=new NotificationPreferenceCtrl.UpdateDetails();
       	details.contactId=notificationRecs[0].Contact_Id__c;
       	details.optin=true;
       	details.ComMethod='Email'; 
        String updateDetails = JSON.serialize(details);
        List<Contact> conList = [SELECT id,Email,Email_status__c FROM contact WHERE id =:notificationRecs[0].Contact_Id__c];
        conList[0].Email_status__c=true;
        update conList;
        Test.startTest();
        String result = NotificationPreferenceCtrl.updateBulkNotifications(selectedNotifications,updateDetails);
        Test.stopTest();
        System.assertEquals(result=='Please choose a contact that has valid email address', true,'Record not updated');
    }
  /*----------------------------------------------------------------
Method : updateBulkNotificationsValidationTest
Author: Aishwarya
Story: EDGE-170965
Descripton : bulk update Validation on Contact's email
---------------------------------------------------------------------------*/
     @isTest
  	 public static void updateBulkNotificationEmailValidationTest(){
        List<Notification_Preference__c> notificationRecs = [SELECT  id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c,
                                                             Contact_Id__r.Email,Contact_Id__r.Email_status__c
                                                             FROM Notification_Preference__c ];
        String selectedNotifications = JSON.serialize(notificationRecs);
         Map<id,String> mapContactIdtoComType= new Map<id,String>();
         for(Notification_Preference__c rec : notificationRecs){
         mapContactIdtoComType.put(rec.id,'Email');
         }
        List<Contact> conList = [SELECT id,Email,Email_status__c FROM contact WHERE id =:notificationRecs[0].Contact_Id__c];
        conList[0].Email_status__c=true;
        update conList;
        String updateDetails='{"optin":true,"ComMethod":"Email"}';
        Test.startTest();
        String result = NotificationPreferenceCtrl.updateBulkNotifications(selectedNotifications,updateDetails);
        Test.stopTest();
        System.assertEquals(result=='Please choose a contact that has valid email address', true,'Record not updated');
    }
}