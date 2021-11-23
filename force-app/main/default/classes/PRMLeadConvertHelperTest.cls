/*
 * Author : Team Hawaii: Ritika Jaiswal
 * Description : Test class for PRMLeadConvertHelper
 * Jira : P2OB - 26 
 * Created Date : 8-April-2020
 * Updates : 
 * 1. 1-May-2020    Team Hawaii     P2OB-6059 : Transfer Campaign History from Lead record over to Opportunity record upon conversion
 * 1.0        16 Mar 2021           Vivian Charlie [Hawaii]   P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
*/

@isTest
public class PRMLeadConvertHelperTest {
@testSetup static void setup() {
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops'];
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com',UserRoleId = r.Id);
        
        insert uSysAdmin;
        User partnerUser;
        Lead testLead;
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
            //insert partnerCon;
            Contact customerCon = new Contact(FirstName = 'CustomerName',LastName='Test_PRM',AccountId=customerAccount[0].Id,Contact_Role__c = 'Consultant');
            
            upsert (new List<Contact>{partnerCon,customerCon});
           
            
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
                      
            testLead = new Lead(OwnerId = partnerUser.id,
                                     LastName='TestLead',
                                     FirstName='TestLead',Customer_Name__c = customerAccount[0].id,
                                     Contact_Name__c = customerCon.id , 
                                     Company = 'PRMLeadsOprtntyControllerTest' , 
                                     Job_Function__c ='Board member', 
                                     email='test@gmail.com',
                                     LeadSource='Campaign',
                                     Rating='In Progress',Share_with_Partner_Status__c='Approved',
                                     PartnerAccountId=partnerAccount[0].id,Partner_Principal_Contact__c=partnerUser.id,
                                     Shared_By__c = uSysAdmin.id,
                                     Status = 'Accepted',
                                     RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId()  
                                 );
            upsert testLead;
         }
         System.runAs(uSysAdmin) {
         if(testLead != null){
            List<campaign> campaignList = new List<campaign>();
            Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            for(Integer i=0;i<5;i++)
            { 
                campaign cmp=new Campaign(Name='Test Campaign'+i,Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
                campaignList.add(cmp);            
            }
            insert campaignList;
            
            List<CampaignMember> campaignMemberlist = new List<CampaignMember>();
            for(Integer i=0;i<campaignList.size();i++){
                CampaignMember mem = new CampaignMember (campaignid=campaignList.get(i).id, leadid=testLead.id);
                campaignMemberlist.add(mem);
            }
            insert campaignMemberlist;
            
            }
            
        }
        
   
    }

/* Description : Test method for PRMLeadConvertHelper.convertLeadFromFlow
 * Jira : P2OB - 26 : Test method for covering success scenario
* Updated : P2OB-6059 : Added assert for checking campaign-influence on opportunity 
*/
        public static testMethod void test_convertLeadFromFlow(){
        List<PRMLeadConvertHelper.FlowOutputParameter> outputList;
        Lead testlead = [Select id,Customer_Name__c,Contact_Name__c,ownerId from Lead where Company ='PRMLeadsOprtntyControllerTest' limit 1];
        User partner = [select id from User where username = 'prmApp456@noemail.com' limit 1];
        System.runAs(partner){
            Test.startTest();
            PRMLeadConvertHelper.FlowInputParameter inputList = new PRMLeadConvertHelper.FlowInputParameter();
            inputList.leadId = testlead.id;
            inputList.accountId = testlead.Customer_Name__c;
            inputList.contactId = testlead.Contact_Name__c;
            inputList.opportunityName = 'TestLeadConvert';
            inputList.convertedStatus = 'Converted';
            inputList.ownerId = testlead.OwnerId;
            inputList.isSendNotificationToOwner = True;
            inputList.loggedInUser = UserInfo.getUserId();
            outputList = PRMLeadConvertHelper.convertLeadFromFlow(new List<PRMLeadConvertHelper.FlowInputParameter>{inputList});
            Test.stopTest();
            System.debug('Lead convert result:'+outputList);
            System.assert(outputList.size()>0 && !(String.isBlank(outputList[0].convertedOpportunityId)));
        }
            if(outputList != null){
                CampaignInfluence[] campInfluenceList = [SELECT id FROM CampaignInfluence WHERE OpportunityId=:outputList[0].convertedOpportunityId];                     
                //System.assert(campInfluenceList != null && campInfluenceList.size() > 0 , 'Error while transferring campaign history to opportunity');
            }
    }
    
    
/* Description : Test method for PRMLeadConvertHelper.convertLeadFromFlow
 * Jira : P2OB - 26 : Test method for covering error/exception scenario
*/
        public static testMethod void test_convertLeadFromFlowException(){
            Lead testlead = [Select id,Customer_Name__c,Contact_Name__c,ownerId from Lead where Company ='PRMLeadsOprtntyControllerTest' limit 1];
            User partner = [select id from User where username = 'prmApp456@noemail.com' limit 1];
            System.runAs(partner){
                Test.startTest();
                PRMLeadConvertHelper.FlowInputParameter inputList = new PRMLeadConvertHelper.FlowInputParameter();
                inputList.leadId = testlead.id;
                inputList.accountId = testlead.Contact_Name__c; // P2OB-26 : Sending incorrect id of account
                inputList.contactId = testlead.Contact_Name__c;
                inputList.opportunityName = 'TestLeadConvert';
                inputList.convertedStatus = 'Converted';
                inputList.ownerId = testlead.OwnerId;
                inputList.isSendNotificationToOwner = True;
                inputList.loggedInUser = UserInfo.getUserId();
                List<PRMLeadConvertHelper.FlowOutputParameter> outputList = PRMLeadConvertHelper.convertLeadFromFlow(new List<PRMLeadConvertHelper.FlowInputParameter>{inputList});
                Test.stopTest();
                System.debug('Lead convert result:'+outputList);
                System.assert(outputList.size()>0 && (String.isBlank(outputList[0].convertedOpportunityId)));
            }
        }
        


}