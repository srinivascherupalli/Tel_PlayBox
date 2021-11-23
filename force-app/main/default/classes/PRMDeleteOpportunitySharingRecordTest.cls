/*
 * History of updates - 
 * 1. 14-April-2020		Ritika Jaiswal		Team Hawaii : Test class fixes for missing role in deployment-user
 * */

@isTest
public class PRMDeleteOpportunitySharingRecordTest {
    @testSetup static void setup() {
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops'];
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        
        User uSysAdmin = new User(alias = 'Con123', email='uSysAdminTest@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,
                                  timezonesidkey='America/Los_Angeles', username='uSysAdminTest987657@noemail.com',UserRoleId = r.Id);
        
        insert uSysAdmin;
        User partnerUser;
        System.runAs(uSysAdmin) {
            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account acc : customerAccount){
                acc.Customer_Status__c = 'Active';
                acc.CIDN__c ='32142345';
            }
            insert customerAccount;
            
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            id rtypeId2 = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
            
            Contact partnerCon = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=partnerAccount[0].Id,Contact_Role__c = 'Consultant',recordtypeid=rtypeId2);
            insert partnerCon;
           
            Set<String> customerUserTypes = new Set<String> {'PRM Community User - Australia'};
            Profile p2 = [select Id,name from Profile where Name in :customerUserTypes limit 1];
            partnerUser = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', profileid = p2.id, country='United States',IsActive =true,
                                   ContactId = partnerCon.Id,
                                   timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
            
            insert partnerUser;
            
            partnerAccount[0].PartnerPrincipalContact__c = partnerCon.id;
            partnerAccount[0].Account_Status__c = 'Active';
            upsert partnerAccount[0];
            
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordTypeId();
            opp.AccountId = customerAccount[0].Id;
            opp.Product_Domain__c = 'MOBILES';
            opp.Name = 'PRMDeleteOpportunitySharingRecordTest';
            opp.CloseDate = Date.newInstance(2022, 12, 9);
            opp.StageName = 'Develop';
            opp.Description__c = 'PRMDeleteOpportunitySharingRecordTest';
            opp.Contract_Type__c = 'Order Under Existing Contract';
            opp.Pricing_Method__c = 'PET';
            opp.Billing_Solution__c = 'In Contract';
            opp.Contract_Complexity__c = 'In Contract';
            opp.Last_Basket_Sync__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
            insert opp;
            
            
        }
    }
    public static testMethod void testDeleteOpportunityShare(){
        Test.startTest();
        List<Opportunity> oppListTest = [select id from Opportunity where name = 'PRMDeleteOpportunitySharingRecordTest' limit 1 ];
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        User partnerUser = [select id from User where username = 'prmApp456@noemail.com' limit 1];
        User adminUser = [select id from User where username = 'uSysAdminTest987657@noemail.com' limit 1];            
        System.runAs(adminUser){
            if(!oppListTest.isEmpty()){           
                OpportunityShare oppShare = new OpportunityShare();
                oppShare.OpportunityId = oppListTest[0].Id;
                oppShare.OpportunityAccessLevel = 'Read';
                oppShare.RowCause = 'Manual';
                oppShare.UserOrGroupId = partnerUser.Id;
                oppShareList.add(oppShare);
            }        
            INSERT oppShareList;
        }
        Test.stopTest();
        List<Id> idList = new List<Id>();
        if(oppListTest.size() > 0){
            for(Opportunity oppo : oppListTest){
                idList.add(oppo.Id);
            }
            PRMDeleteOpportunitySharingRecord.deleteExistingSharingRecordWithPartner(idList);
            
            OpportunityShare[] opShare = [Select id from OpportunityShare where OpportunityId =: oppListTest[0].Id AND UserOrGroupId =: partnerUser.Id];
            system.assertEquals(0, opShare.Size());
        }
    }
}