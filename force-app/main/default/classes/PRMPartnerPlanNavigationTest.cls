/*01 July 2021 Vivian : Hawaii : release/21.08 branch bug fix for assertion*/
@isTest
public class PRMPartnerPlanNavigationTest {
    static Id partnerrectypeId;
    static Id contactRectypeId;
    @testSetup static void setup(){
        //Profile Map
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile]){
            profilesMap.put(profile.Name, profile);
        }
       
        //Role Map
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops']){
            rolesMap.put(role.DeveloperName, role);
        }
       
        //Create Admin User
        User[] adminUser = PRMTestUtility.createInternalUsers(1, new List<Profile>{profilesMap.get('System Administrator')}, rolesMap.get('Sales_Ops'));
        adminUser[0].UserPermissionsKnowledgeUser = true;
        insert adminUser;
        Test.startTest();
       
        system.runAs(adminUser[0]){
            Id rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
            partnerrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            //list<Profile> p = [Select Id, Name from Profile Where Name = 'PRM Community User - Australia'];
           
            List<Account> testAccts = PRMTestUtility.createPartnerAccounts(1, partnerrectypeId, 'Partner', 'New', null);
            testAccts[0].Data_Security_Accreditation__c = 'Platinum';
            testAccts[0].Mobility_Accreditation__c = 'Platinum';
            testAccts[0].Cloud_Accreditation__c = 'Platinum';
            testAccts[0].Collaboration_Accreditation__c = 'Platinum';
            testAccts[0].Overall_Accreditation__c = 'Platinum';
            testAccts[0].ACN__c = testAccts[0].ACN__c +'0';
            testAccts[0].ABN__c = testAccts[0].ABN__c +'0';
            testAccts[0].Partner_Code__c = testAccts[0].Partner_Code__c +'0';
            insert testAccts;

            Integer yr = date.today().addYears(1).year();
            Integer yrNxt = date.today().addYears(2).year();
            Integer yrNxt1 = date.today().addYears(3).year();
            List<Partner_Plan__c> partnerPlanList = PRMTestUtility.createPartnerPlan(1,testAccts,'FY'+string.valueof(yr).right(2),'P113240');
            partnerPlanList.addAll(PRMTestUtility.createPartnerPlan(1,testAccts,'FY'+string.valueof(yrNxt).right(2),'P113240'));
            partnerPlanList.addAll(PRMTestUtility.createPartnerPlan(1,testAccts,'FY'+string.valueof(yrNxt1).right(2),'P113240'));
            insert partnerPlanList;

            contactRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
            List<Contact> testContacts = PRMTestUtility.createContact(1, contactRectypeId, testAccts[0].Id);
            insert testContacts;

            testAccts[0].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[0].IsPartner = true;
            testAccts[0].Account_Status__c = 'Active';
            update testAccts;

            list<User> lstUser = PRMTestUtility.createPartnerUsers(1, new List<Profile>{profilesMap.get('PRM Community User - Australia')}, testContacts, false);
            insert lstUser;
        }
    }

    static testMethod void testAsUsers(){
        String fieldjson = '["Name","Financial_Year__c"]';
        String sobj = 'Partner_Plan__c';
        String partnerField = 'Partner_Account__c';
        list<Account> lstA = [Select Id
                                   , isPartner
                                   , Account_Status__c
                                   , Recordtype.Name 
                            From Account 
                            Where Name = 'TEST_Partner_ACCOUNT0' 
                            or ACN__c = '1230'];
        Id accId;
        if(!lstA.isEmpty()){
            PRMPartnerPlanNavigation.ResponseWraper inst = PRMPartnerPlanNavigation.getPlanId(lstA[0].Id);
            accId = lstA[0].Id;
        }

        list<Partner_Plan__c> lstP = [Select Id, Current_FY__c, Financial_Year__c, Partner_Account__c from Partner_Plan__c];
        Id curentFYPlanId;
        if(!lstP.isEmpty()){
            PRMPartnerPlanNavigation.ResponseWraper inst1 = PRMPartnerPlanNavigation.getPlanId(lstP[0].Id);
            PRMPartnerPlanNavigation.getFieldSet(sobj,'PartnerPlanFieldSet');
            PRMPartnerPlanNavigation.getRecords(sobj,partnerField,null,fieldjson,lstP[0].Id,lstP[0].Financial_Year__c);
            for(Partner_Plan__c objPlan : lstP){
                if(objPlan.Current_FY__c){
                    curentFYPlanId = objPlan.Id;
                }
            }
        }
        
        if(!lstA.isEmpty()){
            list<Contact> lstC = [Select Id from Contact where AccountId =: accId];
            if(!lstC.isEmpty()){
                list<User> lstU = [Select Id
                                        , ContactId 
                                  From User 
                                  where ContactId=: lstC[0].Id 
                                  limit 1];
                System.runAs(lstU[0]){
                    PRMPartnerPlanNavigation.isPartnerLoggedIn();
                    PRMPartnerPlanNavigation.ResponseWraper inst2 = PRMPartnerPlanNavigation.getPlanId(curentFYPlanId); //getPlanId(null) release/21.08 fix
                    PRMPartnerPlanNavigation.getFieldSet(sobj,'PartnerPlanFieldSet');
                    PRMPartnerPlanNavigation.getRecords(sobj,partnerField,null,fieldjson,null,lstP[0].Financial_Year__c);
                    system.assertEquals(inst2.strPlanId,curentFYPlanId);
                    if(!lstP.isEmpty()){
                        PRMPartnerPlanNavigation.ResponseWraper inst3 = PRMPartnerPlanNavigation.getPlanId(lstP[0].Id);
                        PRMPartnerPlanNavigation.getFieldSet(sobj,'PartnerPlanFieldSet');
                        PRMPartnerPlanNavigation.getRecords(sobj,partnerField,lstP[0].Partner_Account__c,fieldjson,lstP[0].Id,lstP[0].Financial_Year__c);
                    }
                }
            } // end of !lstC.isEmpty
        } // end of !lstA.isEmpty
    } // end of testAsUsers
} // end of PRMPartnerPlanNavigationTest