/*************************************************************************************************
Name : OpportunityTriggerHawaiiTest
Description : Test class for Opportunity triggernew on Opportunity
Vivian Charlie : Hawaii : 05 Aug 2021 
***************************************************************************************************/
@isTest
public class OpportunityTriggerHawaiiTest{

    @isTest
    public static void TestChatterPost(){
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('TestAccount') ;
        acc.Customer_Status__c='Acquired';
        insert acc;
        
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Closed Won';
        insert opp;
        
        Case cs = new Case();
        cs.OpportunityId__c = opp.Id;
        insert cs;
        
        update opp;
        Test.stoptest();
    }
    
    @isTest
    public static void testOppContactRoleValidation(){   
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
            rolesMap.put(role.DeveloperName, role);
            
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid =profilesMap.get('System Administrator').id, country='United States',IsActive =true,                
                                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=rolesMap.get('CEO').id);
        //User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
            insert accdis2;
            System.assertEquals(accdis2.Name, 'Test Accountdit2');
            
            Set<String> customerUserTypes = new Set<String> {'PRM Community User - Australia'};
            Profile p2 = [select Id,name from Profile where Name in :customerUserTypes limit 1];
            id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
            
            Account testAcc2 = new Account(Name='testAcc', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=rtypeId2,Primary_Distributor__c=accdis2.id);
            Insert testAcc2;
            
            Contact con1 = new Contact();
            con1.AccountId = testAcc2.Id;
            con1.LastName = 'TestLastName';
            con1.Email = 'test@test345345345345.com';
            con1.Phone = '+911234567891'; 
            con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
            con1.Onboarding_Status__c='Active';
            insert con1;
            Test.startTest();
          
            
            
            User u2 = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid =p2.id, country='United States',IsActive =true,
                               ContactId = con1.Id,
                               timezonesidkey='America/Los_Angeles', username='Cont987657w9@noemail.com');
            
            insert u2;
            
            testAcc2.recordtypeid=rtypeId2;
            testAcc2.IsPartner=TRUE;
            testAcc2.Account_Status__c='Active';
            testAcc2.Customer_Trading_Name__c = 'Test';
            testAcc2.ABN__c='aaaa';
            testAcc2.ACN__c='ccc';
            testAcc2.PartnerPrincipalContact__c=con1.id;
            testAcc2.State_Coverage__c = 'SA';
            testAcc2.Partner_Type__c='Partner';
            testAcc2.Website='www.vsygwoci.com';
            testAcc2.Phone='0412354323';
            testAcc2.Overall_Accreditation__c='Platinum';
            testAcc2.Mobility_Accreditation__c='Platinum';
            testAcc2.Cloud_Accreditation__c='Platinum';
            testAcc2.Data_Security_Accreditation__c='Platinum';
            testAcc2.Collaboration_Accreditation__c='Platinum';
            
            update testAcc2;
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('TestAccount') ;
            acc.Customer_Status__c='Acquired';
            insert acc;
            
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            insert opp;
            
            try {
                //CREATE OPPORTUNITY
                opp.Partner_Account__c=testAcc2.id;
                update opp;
                Test.stoptest();
                System.assertNotEquals(null,opp);
            }
            catch (DmlException e) {
                String message = e.getMessage();
                System.assert(message.contains('Add a customer contact via the Contact Roles section, before submitting to a Partner'), 'message=' + message);
            }
        }
    }
}