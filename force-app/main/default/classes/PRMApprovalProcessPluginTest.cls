/**
* Description : Apex Action to be invoked from flows. This apex class will recall the approval process.                   
* Jira        : P2OB - 7948
* Author      : Team Hawaii 
* Date        : 27-August-2020 
**/
@isTest
public  class PRMApprovalProcessPluginTest {
    
    @testSetup 
    static void setup() {
        User[] partnerUsers;
        Account[] customerAccount;
        Account[] partnerAccount;
        Opportunity[] opportunities;
        Contact[] customerContact;
        Contact[] partnerContact;
        
        Test.startTest();
        // get User Role
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops' limit 1];
          
        // get Profile
        profile[] pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
       
        User[] systemAdminUser = PRMTestUtility.createInternalUsers(1, pSysAdmin, r) ;
        insert systemAdminUser;
        
        
        System.runAs(systemAdminUser[0]) {
             // insert Accounts 
             customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
             for(Account acc : customerAccount){
                acc.Customer_Status__c = 'Active';
                acc.CIDN__c ='32142345';
             }
             partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
             List<Account> accountList = new List<Account>();
             accountList.addAll(customerAccount);
             accountList.addAll(partnerAccount);
             insert accountList;
             
             // insert Contact
             Id customerConRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(); 
             Id partnerRecord = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId();
             
             customerContact = PRMTestUtility.createContact(1,customerConRecId,customerAccount[0].Id);
             customerContact[0].email = 'testConrole@gmail.com';
             customerContact[0].Contact_Status__c ='Active';
             
             partnerContact = PRMTestUtility.createContact(1,partnerRecord,partnerAccount[0].Id);
             List<Contact> contacts = new List<Contact>();
             contacts.addAll(customerContact);
             contacts.addAll(partnerContact);
             insert contacts;
             
             // get Partner Profile
             Profile[] partnerProfile = [Select id,Name from Profile where Name='PRM Community User - Australia' LIMIT 1];
             partnerUsers = PRMTestUtility.createPartnerUsers(1, partnerProfile, partnerContact,false);
             insert partnerUsers;
             opportunities = new List<Opportunity>();
             for(integer i=0;i<5;i++){
                Opportunity opp = new Opportunity();
                opp.Name = 'Test Recall Opportunity' + i;
                opp.StageName = 'Proposed';
                opp.AccountId = customerAccount[0].Id;
                opp.OwnerId = partnerUsers[0].id;
                opp.Customer_Contact_Email__c = customerContact[0].email;
                opp.CloseDate = Date.today().addDays(20);
                opp.Closure_Approver__c = UserInfo.getUserId();
                opportunities.add(opp);
             }
             insert opportunities;
        }
        
        System.runAs(partnerUsers[0]) {
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            for (Opportunity opp: opportunities) {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval ');
                    req1.setObjectId(opp.Id);
                    requests.add(req1);
            }
            Approval.ProcessResult[] processResults = Approval.process(requests, true);
        }
        Test.stopTest();
  }
  /* test approval process recall action */
  public static testMethod void testRecall(){
      test.StartTest();
         // get Opportunities
         Map<String,Opportunity> testOpportunities = new Map<String, Opportunity>([select id from Opportunity where Name like 'Test Recall Opportunity%' limit 5]);
         List<String> oppIds = new List<String>();
         oppIds.addAll(testOpportunities.keySet());
         // prepare Flow Input
         List<PRMApprovalProcessPlugin.FlowInputParameter> flowInputs = new List<PRMApprovalProcessPlugin.FlowInputParameter>();
         PRMApprovalProcessPlugin.FlowInputParameter input = new PRMApprovalProcessPlugin.FlowInputParameter();
         input.sobjectIds = oppIds;
         input.approvalProcessName = System.Label.Opportunity_Close_Won_Approval_Name;
         flowInputs.add(input);
         // call recall action
         List<PRMApprovalProcessPlugin.FlowOutputParameter> flowOutputs = PRMApprovalProcessPlugin.recallApprovalProcess(flowInputs);
         System.assert(!flowOutputs.isEmpty());
      test.StopTest();
      
  }
  
  /* test approval process recall action Exception if Ids are null*/
  public static testMethod void testRecallException(){
      test.StartTest();
         // prepare Flow Input
         List<PRMApprovalProcessPlugin.FlowInputParameter> flowInputs = new List<PRMApprovalProcessPlugin.FlowInputParameter>();
         PRMApprovalProcessPlugin.FlowInputParameter input = new PRMApprovalProcessPlugin.FlowInputParameter();
         input.approvalProcessName = System.Label.Opportunity_Close_Won_Approval_Name;
         flowInputs.add(input);
         // call recall action
         List<PRMApprovalProcessPlugin.FlowOutputParameter> flowOutputs = PRMApprovalProcessPlugin.recallApprovalProcess(flowInputs);
         System.assert(!flowOutputs.isEmpty());
         System.assert(flowOutputs[0].errorMessage != null);
      test.StopTest();
      
  }
  
        
}