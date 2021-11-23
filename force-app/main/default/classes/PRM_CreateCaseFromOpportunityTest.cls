/***
* Updated Hawaii - updated fixes of QA1 - 14/04/2020
*/

@isTest
public class PRM_CreateCaseFromOpportunityTest {


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
        
        System.runAs(systemAdmin){
            Opportunity[] oppList = New List<Opportunity>();
            Opportunity opp = new Opportunity();
                opp.RecordTypeId = PartnerRecTypeId;
                opp.AccountId = accList[0].Id;
                opp.Product_Domain__c = 'MOBILES';
                opp.Name = 'Test Opportunity Create Case';
                opp.CloseDate = Date.newInstance(2022, 12, 9);
                opp.StageName = 'Develop';
                opp.Description__c = 'Test';
                opp.Contract_Type__c = 'Order Under Existing Contract';
                opp.Pricing_Method__c = 'PET'; 
                opp.AgreetoTerms__c  = true;
                opp.Last_Basket_Sync__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
                opp.Opportunity_Source__c = 'Partner';
                opp.Partner_Opportunity_Verification__c = 'Approved';
                oppList.add(opp);
                insert oppList;
                
                List<OpportunityShare> oppShareList = new List<OpportunityShare>();
                OpportunityShare oppShare = new OpportunityShare();
                oppShare.OpportunityId = oppList[0].Id;
                oppShare.OpportunityAccessLevel = 'Edit';
                oppShare.RowCause = 'Manual';
                oppShare.UserOrGroupId = userList[0].Id;
                oppShareList.add(oppShare);
                insert oppShareList;    
                insert new PRM_Default__c(SetupOwnerId=profileMap.get('PRM Community User - Australia').id,PartnerProfileId__c=profileMap.get('PRM Community User - Australia').id,Valid_Opportunity_Basket_Verification__c='Valid1,Valid2,Approved');
         
        }
   }

    public static testMethod void testGetValidOpportunity(){
        List<User> partnerUsers = [select id, Name from User where email = 'testcreatecase@noemail.com' AND Profile.Name = 'PRM Community User - Australia'];
        if(!partnerUsers.isEmpty()){
            System.runAs(partnerUsers.get(0)){
                List<Opportunity> oppList = [select id, Name from Opportunity where Name = 'Test Opportunity Create Case' limit 1];
                Test.startTest();
                // Test method
                Map<String,String> responseMap = PRM_CreateCaseFromOpportunityController.getValidOpportunity(oppList.get(0).Id);
                System.assert(responseMap.containsKey('isPilotUser'));
                Test.stopTest();
            }
        }
       
    }
}