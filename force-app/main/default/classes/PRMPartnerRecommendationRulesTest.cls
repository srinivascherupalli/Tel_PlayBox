/*
* Version     Author                         Last Modified Date      Description
* v1.0        Vivian Charlie (Team Hawaii)   06 Oct 2020             P2OB-5498 : Find Lead Partner Recommendations based on accreditation and state coverage
* v1.1        Vivian Charlie (Team Hawaii)   16 Mar 2021             P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
*/
@isTest
public class PRMPartnerRecommendationRulesTest{
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
            
            List<Account> testAccts = PRMTestUtility.createAccounts(1, rectypeId);
            testAccts.addAll(PRMTestUtility.createPartnerAccounts(2, partnerrectypeId, 'Partner', 'New', null));
            testAccts.addAll(PRMTestUtility.createPartnerAccounts(2, partnerrectypeId, 'Partner', 'New', null));
            testAccts.addAll(PRMTestUtility.createPartnerAccounts(2, partnerrectypeId, 'Partner', 'New', null));
            
            testAccts[3].Data_Security_Accreditation__c = 'Platinum';
            testAccts[3].Mobility_Accreditation__c = 'Platinum';
            testAccts[3].Cloud_Accreditation__c = 'Platinum';
            testAccts[3].Collaboration_Accreditation__c = 'Platinum';
            testAccts[3].Overall_Accreditation__c = 'Platinum';
            testAccts[3].ACN__c = testAccts[3].ACN__c +'3';
            testAccts[3].ABN__c = testAccts[3].ABN__c +'3';
            testAccts[3].Partner_Code__c = testAccts[3].Partner_Code__c +'3';
            
            testAccts[4].Data_Security_Accreditation__c = 'Approved';
            testAccts[4].Mobility_Accreditation__c = 'Approved';
            testAccts[4].Cloud_Accreditation__c = 'Approved';
            testAccts[4].Collaboration_Accreditation__c = 'Approved';
            testAccts[4].Overall_Accreditation__c = 'Approved';
            testAccts[4].ACN__c = testAccts[4].ACN__c +'4';
            testAccts[4].ABN__c = testAccts[4].ABN__c +'4';
            testAccts[4].Partner_Code__c = testAccts[4].Partner_Code__c +'4';
            
            testAccts[5].Data_Security_Accreditation__c = 'Silver';
            testAccts[5].Mobility_Accreditation__c = 'Silver';
            testAccts[5].Cloud_Accreditation__c = 'Silver';
            testAccts[5].Collaboration_Accreditation__c = 'Silver';
            testAccts[5].Overall_Accreditation__c = 'Silver';
            testAccts[5].ACN__c = testAccts[5].ACN__c +'5';
            testAccts[5].ABN__c = testAccts[5].ABN__c +'5';
            testAccts[5].Partner_Code__c = testAccts[5].Partner_Code__c +'5';
            
            testAccts[6].Mobility_Accreditation__c = 'Platinum';
            testAccts[6].Cloud_Accreditation__c = 'Platinum';
            testAccts[6].Collaboration_Accreditation__c = 'Platinum';
            testAccts[6].Overall_Accreditation__c = 'Platinum';
            testAccts[6].ACN__c = testAccts[6].ACN__c +'6';
            testAccts[6].ABN__c = testAccts[6].ABN__c +'6';
            testAccts[6].Partner_Code__c = testAccts[6].Partner_Code__c +'6';
            insert testAccts;
            
            contactRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
            List<Contact> testContacts = PRMTestUtility.createContact(1, contactRectypeId, testAccts[1].Id);
            testContacts.addAll(PRMTestUtility.createContact(1, contactRectypeId, testAccts[2].Id));
            insert testContacts;
            
            testAccts[1].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[1].IsPartner = true;
            testAccts[1].Account_Status__c = 'Active';
            
            testAccts[2].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[2].IsPartner = true;
            testAccts[2].Account_Status__c = 'Active';
            testAccts[2].Data_Security_Accreditation__c = 'Platinum';
            testAccts[2].Mobility_Accreditation__c = 'Platinum';
            testAccts[2].Cloud_Accreditation__c = 'Platinum';
            testAccts[2].Collaboration_Accreditation__c = 'Platinum';
            testAccts[2].Overall_Accreditation__c = 'Platinum';
            
            testAccts[3].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[3].IsPartner = true;
            testAccts[3].Account_Status__c = 'Active';
            
            testAccts[4].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[4].IsPartner = true;
            testAccts[4].Account_Status__c = 'Active';
            
            testAccts[5].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[5].IsPartner = true;
            testAccts[5].Account_Status__c = 'Active';
            
            testAccts[6].PartnerPrincipalContact__c = testContacts[0].Id;
            testAccts[6].IsPartner = true;
            testAccts[6].Account_Status__c = 'Active';
            testAccts[6].Data_Security_Accreditation__c = 'Platinum';
            
            update testAccts;
            
            list<User> lstUser = PRMTestUtility.createPartnerUsers(2, new List<Profile>{profilesMap.get('PRM Community User - Australia')}, testContacts, false);
            insert lstUser;
        }
        
        Test.stopTest();
    }
    
    static testMethod void testRecommendedPartner(){
        Id leadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();// v1.1
        
        list<Account> lstA = [Select Id, isPartner, Account_Status__c, Recordtype.Name from Account where Name = 'TEST_ACCOUNT0' or ACN__c = '1230'];
        Id businessAccountId;
        Id partnerAccountId;
        
        for(Account objA : lstA){
            if(objA.isPartner){
                partnerAccountId = objA.Id;
            }else{
                businessAccountId = objA.Id;
            }
        }
        
        list<Contact> lstC = [Select Id, FirstName, LastName, AccountId from Contact limit 1];
        
        list<Lead> testLeads = PRMTestUtility.createLeads(1, leadRectypeId, businessAccountId, partnerAccountId, lstC[0].Id, 'FIXED TELEPHONY');
        testLeads.addAll(PRMTestUtility.createLeads(1, leadRectypeId, businessAccountId, null, lstC[0].Id, 'MOBILES'));
        testLeads.addAll(PRMTestUtility.createLeads(1, leadRectypeId, businessAccountId, partnerAccountId, lstC[0].Id, 'DATA & IP'));
        testLeads.addAll(PRMTestUtility.createLeads(1, leadRectypeId, businessAccountId, partnerAccountId, lstC[0].Id, 'CLOUD SERVICES'));
        insert testLeads;
        
        list<PartnerResults> lstRecommendedPartners = PRMPartnerRecommendationRules.findRecommendation(testLeads[0].Id);
        list<PartnerResults> lstRecommendedPartners1 = PRMPartnerRecommendationRules.findRecommendation(testLeads[1].Id);
        list<PartnerResults> lstRecommendedPartners2 = PRMPartnerRecommendationRules.findRecommendation(testLeads[2].Id);
        list<PartnerResults> lstRecommendedPartners3 = PRMPartnerRecommendationRules.findRecommendation(testLeads[3].Id);
        system.debug('lstRecommendedPartners.size()*****'+lstRecommendedPartners.size());
        system.debug('lstRecommendedPartners1.size()*****'+lstRecommendedPartners1.size());
        system.debug('lstRecommendedPartners2.size()*****'+lstRecommendedPartners2.size());
        system.debug('lstRecommendedPartners3.size()*****'+lstRecommendedPartners3.size());
        System.assertEquals(5,lstRecommendedPartners.size());
        System.assertEquals(5,lstRecommendedPartners1.size());
        System.assertEquals(5,lstRecommendedPartners2.size());
        System.assertEquals(5,lstRecommendedPartners3.size());
    }
}