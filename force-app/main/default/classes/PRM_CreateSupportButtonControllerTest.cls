/***
* Updated Hawaii - updated fixes of QA1 - 14/04/2020
*/

@isTest
public class PRM_CreateSupportButtonControllerTest {


    // Test Data creation
    @testSetup static void setup() {
        List<Account> accList = new List<Account>(); 
        List<Contact> conList = new List<Contact>();
        List<User> userList = new List<User>();
        Id EntAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Id PartnerRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordTypeId();
        
        Test.startTest();
        Map<String,Profile> profileMap = new Map<String,Profile>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof);
        }
        
        List<UserRole> userRoles = [Select id,Name from UserRole where Name = 'Indirect Channels']; 
        List<User> adminUserList = new List<User>();
        // create System Admin user
        User systemAdmin;
        if(profileMap.containsKey('System Administrator') && !userRoles.isEmpty()){
            adminUserList = PRMTestUtility.createInternalUsers(2, new List<Profile>{profileMap.get('System Administrator')}, UserRoles.get(0));
            insert adminUserList;
            systemAdmin = adminUserList[0];
 
        }else{
            systemAdmin = new User(id = UserInfo.getUserId());
        }
        System.runAs(systemAdmin){
            // customer account 
            Account acc = new Account(); 
            acc.Name = 'Test Accountdit';
            acc.Partner_Type__c='Channel';
            acc.Customer_Status__c='ACTIVE';
            acc.Migrated_Customer__c=true;
            acc.CWP_Eligible_Partner__c =false;
            acc.recordTypeId = EntAccRecTypeId;
            accList.add(acc);
            //partner account 
            Account partneracc = new Account();
            partneracc.RecordTypeId = partnerAccRecTypeId;
            partneracc.Name = 'Test Partner Account Create Case';
            partneracc.Account_Status__c = 'New';
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
            accList.add(partneracc);
            insert accList;
        
            Contact con = new Contact();
                con.FirstName = 'Test Account';
                con.LastName='Last Name';
                con.AccountId=accList[0].Id;
            conList.add(con);
            insert conList;
        }
        System.runAs(systemAdmin){
            User partUser;
            partUser = new User(alias = 'PART', email='testcreatecase@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileMap.get('PRM Community User - Australia').id, country='United States',IsActive =true,
            ContactId = conList[0].Id,isPRMSuperUser=True,
            timezonesidkey='America/Los_Angeles', username=Math.round((Math.random() * (900000) + 100000))+'@noemail.com');
            userList.add(partUser);
            insert userList;
        }
   }

    public static testMethod void testGetUserDetails(){
        List<User> partnerUsers = [select id, Name from User where email = 'testcreatecase@noemail.com' AND Profile.Name = 'PRM Community User - Australia'];
        if(!partnerUsers.isEmpty()){
            System.runAs(partnerUsers.get(0)){
               Test.startTest();
                String userDetails = PRM_CreateSupportButtonController.getUserDetails();
                //Call this method to cover logic for base url generation of opportunity
                String returnUrl = PRM_CreateSupportButtonController.globalActionNavigateUrl();
                //Call this method to cover logic for base url generation of Case
                String caseURL = PRM_CreateSupportButtonController.getCaseUrl();
                System.assert(userDetails != null);
                system.assert(returnUrl != null);
                system.assertEquals(caseURL.contains(Label.PRM_Partner_Case_URL), true);
                Test.stopTest();
            }
        }
       
    }
    //EDGE-164004
    public static testMethod void testCSMPortalUrl(){
        TNOW_CSM_URL__c settings = TNOW_CSM_URL__c.getOrgDefaults();
        settings.PortalUrl__c = 'dummy';
        settings.KAUrl__c = 'dummy';
        upsert settings TNOW_CSM_URL__c.Id;        
        String s = PRM_CreateSupportButtonController.getCSMPortalDetails();
        system.assert(s != null);
    }
}