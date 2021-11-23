/*------------------------------------------------
EDGE        -150891
Class       -GeneratePORAgreement
Description -Testclass for GeneratePORAgreement
Author      -Purushottam Sahu
--------------------------------------------------*/
@isTest
public class GeneratePORAgreementTest {
    @testSetup public static void setup() {
        
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
            profilesMap.put(profile.Name, profile);
        
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
            rolesMap.put(role.DeveloperName, role);
        
        User[] uSysAdmin = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        insert uSysAdmin;
        
        System.runAs(uSysAdmin[0]){  
            
            Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert acc; 
            acc[0].ispartner=true;
            update acc[0];
            
            Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
            insert con; 
            
            User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,new List<Contact>{con} ,false);
            insert partnerUser;
            
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
             insert customerContacts;
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
             update customerContacts;
            Account partnerAccount=[select id from Account where name='TEST_Partner_ACCOUNT0'];
            Contact partnerContact=[select id from Contact where name='testCon'];
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                                Partner__c=partnerAccount.Id,Partner_Signatories__c= partnerContact.Id); 
            insert POR;
            
            APXTConga4__Conga_Merge_Query__c cafquery = TestUtil.createCongaQuery('PORDetails', 'PORDetails');
            insert cafquery;
            
            APXTConga4__Conga_Template__c template = TestUtil.createCongaTemplate('POR Agreement Form','Document','Type');
            insert template;
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv; 
            
            //Get Content Version
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]; 
            //Get Content Documents
            List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record 
            List<ContentDocumentLink> clList = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = POR.id;
            cdl.ContentDocumentId = cdList[0].Id;
            cdl.shareType = 'V';
            clList.add(cdl);
            insert clList;
        }
        
    }
    @IsTest
    static void testupdatePORCongaURL(){ 
        Map<id,Partner_of_Record__c> porIdObjMap  = new Map<Id,Partner_of_Record__c>([select id,Conga_URL__c from Partner_of_Record__c]); 
        GeneratePORAgreement.updatePORCongaURL(new List<Id>(porIdObjMap.keySet()));
        Partner_of_Record__c POR = [select id,Conga_URL__c from Partner_of_Record__c where id=:porIdObjMap.values()[0].id];
        system.assertNotEquals(POR.Conga_URL__c, null);
    }
    
    @IsTest
    static void testNegativeupdatePORCongaURL(){ 
        Map<id,Partner_of_Record__c> porIdObjMap  = new Map<Id,Partner_of_Record__c>([select id,Conga_URL__c from Partner_of_Record__c]);
        GeneratePORAgreement.updatePORCongaURL(new List<Id>());
        system.assertEquals(porIdObjMap.values()[0].Conga_URL__c, null);
    }
    
    @IsTest
    static void testDocuSignRestrictedPORCongaURL(){ 
        Map<id,Partner_of_Record__c> porIdObjMap  = new Map<Id,Partner_of_Record__c>([select id,Conga_URL__c,customer__c from Partner_of_Record__c]);
        Account customerAccount = [select id from Account where id=:porIdObjMap.values()[0].customer__c];
        customerAccount.APTPS_DocuSign_Restricted__c=true;
        update customerAccount;  
        GeneratePORAgreement.updatePORCongaURL(new List<Id>(porIdObjMap.keySet()));
        Partner_of_Record__c POR = [select id,Conga_URL__c from Partner_of_Record__c where id=:porIdObjMap.values()[0].id];
        system.assertNotEquals(POR.Conga_URL__c, null);
        
    }
    
    @IsTest
    static void testOffshoreRestrictedPORCongaURL(){ 
        Map<id,Partner_of_Record__c> porIdObjMap  = new Map<Id,Partner_of_Record__c>([select id,Conga_URL__c,customer__c from Partner_of_Record__c]);
        Account customerAccount = [select id from Account where id=:porIdObjMap.values()[0].customer__c];
        customerAccount.APTPS_Off_Shore_Restricted__c=true;
        update customerAccount;  
        GeneratePORAgreement.updatePORCongaURL(new List<Id>(porIdObjMap.keySet()));
        Partner_of_Record__c POR = [select id,Conga_URL__c from Partner_of_Record__c where id=:porIdObjMap.values()[0].id];
        system.assertNotEquals(POR.Conga_URL__c, null);
    }
}