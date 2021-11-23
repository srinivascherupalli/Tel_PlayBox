/*****************************************************************************
@Name: CampaignMemberTriggerTest
@Author: Team SFO (Prathyusha , Sravanthi)
@CreateDate: 29/07/2019
@Description: EDGE-98344:Testclass for CampaignMemberTriggerHandler and CampaignMemberTrigger
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*******************************************************************************/
@isTest
public class CampaignMemberTriggerTest {
    @testSetup
    static void setup()
    {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', 
                              profileid = pf.id, 
                              timezonesidkey='Australia/Sydney', 
                              username='salesuser@testsales.com',Phone='+911231231234');    
        insert sales;
         PermissionSet ps = [SELECT Id,Label,Name FROM PermissionSet WHERE Name = 'DCH_Inside_Sales_Specialist' LIMIT 1];
          PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = sales.id,
            PermissionSetId = ps.Id
            );
            insert psa;
        
    }
    @isTest
    static void testCampaignMemberHistoryInsert(){
        Test.startTest();
        User uSE = [SELECT id from User WHERE email = 'salesuser@testsales.com' LIMIT 1];
        //Creates Account 
        Account testAccount = TestUtil.createAccount('TestAccount');
        testAccount.OwnerId=uSE.id;
        insert testAccount;
        
        System.runAs(uSE){
            //Creates Contact 
            Contact testContact = TestUtil.createContact(testAccount.Id,'TestContactF','TestLast');
            testContact.Pref_Comm_Method__c = 'eMail'; 
            testContact.Email = 'none@navinet.net'; 
            testContact.lastVerifiedDate__c =Date.today();
            testContact.Contact_Status__c = 'Active';
            testContact.OwnerId=uSE.id;
            insert testContact;
        //Creates Campaign 
        Campaign testCampaign = new Campaign(Name = 'TestCampaign1');
        testCampaign.OwnerId = uSE.id;
        insert testCampaign;
        
        //Creates a new campaign memeber
        CampaignMember newMember = new campaignMember(Status = 'Nominated');
        newMember.CampaignId=testCampaign.id;
        newMember.ContactId =testContact.id;
        insert newMember;      
        }
        Campaign testCampaign = [SELECT id from Campaign WHERE Name = 'TestCampaign1' LIMIT 1];
        List<Campaign_Member_History__c> cmhList = [Select id from Campaign_Member_History__c where Campaign__c = :testCampaign.Id];
        System.assertequals(cmhList.size(),1);
        Test.stopTest();
        
    }
    @isTest
    static void testCampaignMemberHistoryUpdate(){
        Test.startTest();
        User uSE = [SELECT id from User WHERE email = 'salesuser@testsales.com' LIMIT 1];
        //Creates Account 
        Account testAccount = TestUtil.createAccount('TestAccount');
        testAccount.OwnerId=uSE.id;
        insert testAccount;
        
        System.runAs(uSE){
            //Creates Contact 
            Contact testContact = TestUtil.createContact(testAccount.Id,'TesttestAccountIdContactF','TestLast');
            testContact.Pref_Comm_Method__c = 'eMail';
            testContact.Email = 'none@navinet.net' ;
            testContact.lastVerifiedDate__c =Date.today();
            testContact.Authority__c='Non-Authorised';
            testContact.Contact_Status__c = 'Active';
            testContact.OwnerId=uSE.id;
            insert testContact;
        
        //Creates Campaign 
        Campaign testCampaign = new Campaign(Name = 'TestCampaign1');
        testCampaign.OwnerId = uSE.id;
        insert testCampaign;
        
        //Creates a new campaign memeber
        CampaignMember newMember = new campaignMember(Status = 'Nominated');
        newMember.CampaignId= testCampaign.id;
        newMember.ContactId = testContact.id;
        insert newMember;
        newMember.Status='Nomination Withdrawn';
        update newMember;
        
        }
        Campaign testCampaign = [SELECT id from Campaign WHERE Name = 'TestCampaign1' LIMIT 1];
        List<Campaign_Member_History__c> cmh = [Select id from Campaign_Member_History__c where Campaign__c = :testCampaign.Id];
        System.assertequals(cmh.size(),2);
        Test.stopTest();
        
    }
    @isTest
    static void testCampaignMemberHistoryDelete(){
        Test.startTest();
        User uSE = [SELECT id from User WHERE email = 'salesuser@testsales.com' LIMIT 1];
        
        //Creates Account 
        Account testAccount = TestUtil.createAccount('TestAccount');
        testAccount.OwnerId=uSE.id;
        insert testAccount;
        System.runAs(uSE){
            //Creates Contact 
            Contact testContact =  TestUtil.createContact(testAccount.Id,'TesttestAccountIdContactF','TestLast');
            testContact.Pref_Comm_Method__c = 'eMail' ;
            testContact.Email = 'none@navinet.net' ;
            testContact.Authority__c='Non-Authorised';
            testContact.lastVerifiedDate__c =Date.today();
            testContact.Contact_Status__c = 'Active';
            testContact.OwnerId=uSE.id;
        insert testContact;
        
        //Creates Campaign 
        Campaign testCampaign = new Campaign(Name = 'TestCampaign1');
        testCampaign.OwnerId = uSE.id;
        insert testCampaign;
        
        //Creates a new campaign memeber
        CampaignMember newMember = new campaignMember(Status = 'Nominated');
        newMember.CampaignId=testCampaign.id;
        newMember.ContactId = testContact.id;
        insert newMember;
        newMember.Status='Nomination Withdrawn';
        update newMember;
        Delete newMember;
        }
        Campaign testCampaign = [SELECT id from Campaign WHERE Name = 'TestCampaign1' LIMIT 1];
        List<Campaign_Member_History__c> cmh = [Select id from Campaign_Member_History__c where Campaign__c = :testCampaign.Id];
        System.assertequals(cmh.size(),3);
        Test.stopTest();
        
    }
       
}