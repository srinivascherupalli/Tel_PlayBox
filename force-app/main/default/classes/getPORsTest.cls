/*
Bhargava:14/07/2020
EDGE-151592 This is test class for getPORs
*/
@isTest
public class getPORsTest {
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
            
            Contact con = new Contact(LastName ='testCon', FirstName='testCon', AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Engineering User');
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
         
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                                Partner__c=acc[0].Id,Partner_Signatories__c= con.Id,Status__c='Active'); 
            insert POR;
            List<Partner_of_Record_Domain__c> domainList = new List<Partner_of_Record_Domain__c>();
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = POR.Id,Status__c='Active',Domain_Name__c='Mobile'));
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = POR.Id,Status__c='Cancelled',Sub_Status__c='Cancelled',Domain_Name__c='Data and IP'));
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = POR.Id,Status__c='Active',Sub_Status__c='Partner Review',Domain_Name__c='NAS'));
            Database.insert(domainList);
        }
        
    }
     @IsTest
    static void testisPOR(){
        Partner_of_Record__c POR=[select id,Customer__c,Partner__c from Partner_of_Record__c limit 1];
        Boolean isPOR=getPORs.isPOR(POR.Partner__c,POR.Customer__c,'Active');
        System.assertEquals(isPOR, true);
    }

     @IsTest
    static void testisPORADC(){
        Partner_of_Record__c POR=[select id,Customer__c,Partner__c from Partner_of_Record__c limit 1];
        Boolean isPOR=getPORs.isPORADC(POR.Customer__c,'Active');
        System.assertEquals(isPOR, true);
    }
    
    //Added for EDGE-176104
    @IsTest
    static void testporforContact(){
        Partner_of_Record__c POR=[select id,Customer__c,Partner__c from Partner_of_Record__c limit 1];
       
        Boolean isPOR=getPORs.getporofcontact(POR.Customer__c);
        System.assertEquals(isPOR, false);
    }

   // 
    @IsTest
    static void testporforContactrunaspartner(){
        Partner_of_Record__c POR=[select id,Customer__c,Partner__c,Partner_Signatories__c,Customer_Signatories__c from Partner_of_Record__c limit 1];
        system.debug('POR'+POR);
        system.debug('POR.Partner__c'+POR.Partner_Signatories__c);
           User sales = [SELECT id,name FROM User Where ContactId=:POR.Partner_Signatories__c];
        Boolean isPOR;
        System.runAs(sales){
         isPOR=getPORs.getporofcontact(POR.Customer_Signatories__c);
         }
        System.assertEquals(isPOR, false);
       
    }

    //Added for DIGI-11308
    @IsTest
    static void testNonPartnergetPORDomainsList(){
        Partner_of_Record__c POR=[select id,Customer__c,Partner__c from Partner_of_Record__c limit 1];
      	system.assertNotEquals(getPORs.getPORDomainsList(POR.Customer__c),null);
    }
   	@IsTest
    static void testPartnergetPORDomainsList(){
        Partner_of_Record__c POR=[select Customer__c,Partner_Signatories__c from Partner_of_Record__c limit 1];
        User partnerUser = [SELECT id,name FROM User Where ContactId=:POR.Partner_Signatories__c];
        System.runAs(partnerUser){
      	system.assertNotEquals(getPORs.getPORDomainsList(POR.Customer__c),null);
        }
    }
   
     
}