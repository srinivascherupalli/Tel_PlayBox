/*
* @Author : Ravi -Team Hawaii
* @Date :   13 Jan 2020
* @Desc :   This test class covers the logic for validation rule created as part of Requirement P2OB - 4275(Insertion of nominate account is possible only when primary distributor is present). 
* @Jira :   P2OB - 4275
*/

@isTest
public class PRMMultiTierModelTest {
    
    //This method creates test data  
    @testSetup static void setup() {            
        Map<String,id> profileMap = new Map<String,id>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        
        UserRole userRole = [Select id,Name from UserRole where Name = 'CEO']; 
        List<User> adminUserList = new List<User>();
        
        //Create Admin User
        User systemAdminUser = new User(alias = 'PART', email='test@noemail1234.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = partnerProfile[0].Id, country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='test1@noemail.com1',UserRoleId=userRole.Id);
            adminUserList.add(systemAdminUser);
        
        Insert adminUserList;      
    }
    
    // Desc :   This test method test the logic to allow insert of nominate account when Primary Distributor is present 
    public static testMethod void testInsertNominateDistributorAccount(){
        
        //Fetch Partner record type id of account
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        User uSysAdmin =  [select id,name from User where username='test1@noemail.com1'];
        System.runAs(uSysAdmin){
            List<Account> accList = new List<Account>();
            for(Integer i=0 ; i<=10 ; i++){
                Account distriAccount = new Account(Name = 'Test Distri Account'+ i,Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
                accList.add(distriAccount);
            }
            //Create Distributor Account
            Insert accList;
            List<Account> accNomiList = new List<Account>();
            for(Integer i=0 ; i<=10 ; i++){
                Account nomiAccount = new Account(Name = 'Test Nomi Account'+ i,Partner_Type__c='Nominate',customer_status__c = 'ACTIVE',Telstra_Online_Service_Agreement__c = True,recordtypeid=partnerAccRecTypeId,Primary_Distributor__c=accList[0].id);
                accNomiList.add(nomiAccount);
            }
            //Create Nominate Account
            Insert accNomiList;
            system.assertEquals(11, accNomiList.size());
        }
        
    }
    
    // Desc :   This test method test the logic to show validation error on nominate account insertion when Primary Distributor is not present  
    public static testMethod void testshowErrorOnNominateAccountInsert(){
        
        //Fetch Partner record type id of account
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        User uSysAdmin =  [select id,name from User where username='test1@noemail.com1'];
        System.runAs(uSysAdmin){
            List<Account> accNomiList = new List<Account>();
            for(Integer i=0 ; i<=10 ; i++){
                Account nomiAccount = new Account(Name = 'Test Nomi Account'+ i,Partner_Type__c='Nominate',customer_status__c = 'ACTIVE',Telstra_Online_Service_Agreement__c = True,recordtypeid=partnerAccRecTypeId);
                accNomiList.add(nomiAccount);
            }
            try{
                //Create Nominate Account
                Insert accNomiList;
            }catch(exception e){
                System.assertEquals(true, e.getMessage().contains('The Primary Distributor field can\'t be left blank'));        
            }
        }
    }
    
    // Desc :   This test method test the logic to bypass validation error on nominate account insertion when no validation checkbox is true in Environment Configurations custom setting.  
    public static testMethod void testNominateAccInsertOnCustomSettingVarTrue(){
        
        //Fetch Partner record type id of account
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        User uSysAdmin =  [select id,name from User where username='test1@noemail.com1'];
        // Insert Custom seting Record
        Environment_Configurations__c envCon = new Environment_Configurations__c();
            envCon.No_Validations__c = True;
        Insert envCon;
        
        System.runAs(uSysAdmin){
            List<Account> accNomiList = new List<Account>();
            for(Integer i=0 ; i<=10 ; i++){
                Account nomiAccount = new Account(Name = 'Test Nomi Account'+ i,Partner_Type__c='Nominate',customer_status__c = 'ACTIVE',Telstra_Online_Service_Agreement__c = True,recordtypeid=partnerAccRecTypeId);
                accNomiList.add(nomiAccount);
            }
            //Create Nominate Account
            Insert accNomiList;
            system.assertEquals(11, accNomiList.size());
        }
    }
}