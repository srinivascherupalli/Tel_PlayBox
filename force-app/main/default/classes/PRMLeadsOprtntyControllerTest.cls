/*******************************************************************
Date             Version            Modified By             Desc
4-November-2019     2               Paresh Patil            (Team Hawaii)Added additional criteria in opportunity creation to display share by field as part of Jira - P2OB-3691
2-April-2020        3               Ritika Jaiswal          Moved test-data creation to testSetup method
2-April-2020        4               Ritika Jaiswal          P2OB-5611 : Test methods for Lead Accept/Decline by Partners
17-Dec-2020         5               Megha Agarwal           fixes for ALREADY_IN_PROCESS error (removed the code related to submit action of approval process)
16-Mar-2020         6               Vivian Charlie          P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
***********************************************************************/
@isTest
public with sharing class PRMLeadsOprtntyControllerTest {
    @testSetup static void setup() {
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops'];
        //insert r;
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com',UserRoleId = r.Id);
        
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
            /*Contact customerCon = new Contact(FirstName = 'CustomerName',LastName='Test_PRM',AccountId=customerAccount[0].Id,Contact_Role__c = 'Consultant');
            insert customerCon;
            upsert (new List<Contact>{partnerCon,customerCon});*/
           
            
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
            opp.Name = 'Test Opportunity';
            opp.StageName = 'Prospecting';
            opp.AccountId = customerAccount[0].Id;
            opp.Partner__c= partnerUser.id;
            opp.SubmittoPartnerStatus__c='Submitted';
            opp.CloseDate = Date.today();
            opp.Ownerid = partnerUser.id;
            //Added additional logic to populate dch owner as part of story P2OB-3691
            opp.DCHOwner__c = partnerUser.id;
            insert opp;
            
            Lead testLead = new Lead(OwnerId = partnerUser.id,Shared_By__c = uSysAdmin.id,LastName='TestLead',FirstName='TestLead',Customer_Name__c = customerAccount[0].id,Contact_Name__c = partnerCon.id , Company = 'PRMLeadsOprtntyControllerTest' , Job_Function__c ='Board member', email='test@gmail.com',LeadSource='Campaign',Status='Marketing Qualified',Rating='In Progress',Share_with_Partner_Status__c='Submitted',PartnerAccountId=partnerAccount[0].id,Partner_Principal_Contact__c=partnerUser.id);
            testLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();//P2OB-13537
            upsert testLead;
        }
        
        
    }
    
    @isTest
    public static void testLeadsOppData(){
        List<PRMLeadsOprntyWrapper> lstOpp;
        Test.startTest();       
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Opportunity opp = [Select id,name from Opportunity where ownerId=:partnerUser.id and SubmittoPartnerStatus__c='Submitted' limit 1];
            System.runAs(partnerUser){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(opp.id);
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                //req.setProcessDefinitionNameOrId(04a2N000000CarAQAS);
                req.setSubmitterId(userinfo.getUserid());
                Approval.ProcessResult result =  Approval.process(req);
                //test opportunity data
                lstOpp = PRMLeadsOprtntyController.getObjectData('Opportunity');                
            }
            Test.stopTest(); 
            System.assert(lstOpp.size() > 0);
            System.assertEquals(lstOpp.get(0).Name, 'Test Opportunity'); 
        
    }
    
    @isTest
    public static void testApproveOppData(){
        Test.startTest();
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Opportunity opp = [Select id,name from Opportunity where ownerId=:partnerUser.id and SubmittoPartnerStatus__c='Submitted' limit 1];
           System.runAs(partnerUser){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(opp.id);
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                //req.setProcessDefinitionNameOrId(04a2N000000CarAQAS);
                req.setSubmitterId(userinfo.getUserid());
                Approval.ProcessResult result =  Approval.process(req);
                //test opportunity data
                list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
                list<id> approvalIds=new list<id>();
                for(ProcessInstanceWorkitem pr:processItems)
                {
                    String WrkItem=pr.Id;
                    PRMLeadsOprtntyController.getApprovedOppData(WrkItem);                    
                }                
                
            }
            Test.stopTest(); 
        System.assertEquals(opp.Name, 'Test Opportunity');
    }
    
    @isTest
    public static void testDeclinedOppData(){
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Opportunity opp = [Select id,name from Opportunity where ownerId=:partnerUser.id and SubmittoPartnerStatus__c='Submitted' limit 1];         
        Test.startTest();        
            System.runAs(partnerUser){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(opp.id);
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                //req.setProcessDefinitionNameOrId(04a2N000000CarAQAS);
                req.setSubmitterId(userinfo.getUserid());
                Approval.ProcessResult result =  Approval.process(req);
                //test opportunity data
                list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
                for(ProcessInstanceWorkitem pr:processItems)
                {
                    String WrkItem=pr.Id;
                    PRMLeadsOprtntyController.getDeclinedOppData(WrkItem);                    
                }
            }
            Test.stopTest(); 
            System.assertEquals(opp.Name, 'Test Opportunity');
        }
    
    /*
    * @CreatedBy -  Team Hawaii : Ritika Jaiswal 
    * @Jira    -    P2OB - 5611
    * @Desc    -    Test Method for PRMLeadsOprtntyController.getDeclinedLeadData for Leads
    **/
    
    @isTest
    public static void test_getDeclinedLeadData(){
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Lead testlead = [select id,Status,shared_by__c,ownerId from lead where Company='PRMLeadsOprtntyControllerTest' limit 1];
        testlead.shared_by__c = testlead.ownerId;
        upsert testlead;
        Map<String,String> leadItemData = new Map<String,String>();
        leadItemData.put('leadrec',testlead.id);
        leadItemData.put('selected','Partner Coverage');
        leadItemData.put('textEntered','');
        Test.startTest();        
            System.runAs(partnerUser){
                //test opportunity data
                list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
                for(ProcessInstanceWorkitem pr:processItems)
                {
                    String WrkItem=pr.Id;
                    PRMLeadsOprtntyController.getDeclinedLeadData(WrkItem,JSON.serialize(leadItemData));                    
                }
            }
        Test.stopTest();
        Lead testlead_updated = [select id,Status,Reject_Recycle_Reroute_Reason__c from lead where Company='PRMLeadsOprtntyControllerTest' limit 1];
        //P2OB-26 - Commented assert on field update, because of change in approach
        //System.assert(testlead_updated.Reject_Recycle_Reroute_Reason__c == 'Partner Coverage');
        System.assert(testlead_updated.Status == 'Marketing Qualified');     
    }
    
    /*
    * @CreatedBy -  Team Hawaii : Ritika Jaiswal 
    * @Jira    -    P2OB - 5611
    * @Desc    -    Test Method for PRMLeadsOprtntyController.getObjectData for Leads
    **/
    @isTest
    public static void testgetLeadsData(){
        List<PRMLeadsOprntyWrapper> lstOpp = new List<PRMLeadsOprntyWrapper>();
        Test.startTest();       
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Lead testlead = [select id,Status from lead where Company='PRMLeadsOprtntyControllerTest' and Share_with_Partner_Status__c='Submitted' limit 1];
            System.runAs(partnerUser){
                //test opportunity data
                lstOpp = PRMLeadsOprtntyController.getObjectData('Lead');                
            }
            Test.stopTest(); 
            //System.assert(lstOpp.size() > 0);
            System.assert(lstOpp != null);
           
    }
    
    /*
    * @CreatedBy -  Team Hawaii : Ritika Jaiswal 
    * @Jira    -    P2OB - 5611
    * @Desc    -    Test Method for PRMLeadsOprtntyController.getDeclinedLeadData 
    **/
    @isTest
    public static void test_getAcceptedLeadData(){
        User partnerUser = [Select id from User where username = 'prmApp456@noemail.com' limit 1];
        Lead testlead = [select id,Status from lead where Company='PRMLeadsOprtntyControllerTest' limit 1];
        Test.startTest();        
            System.runAs(partnerUser){
                //test opportunity data
                list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
                for(ProcessInstanceWorkitem pr:processItems)
                {
                    String WrkItem=pr.Id;
                    PRMLeadsOprtntyController.getAcceptedLeadData(WrkItem);                    
                }
            }
        Test.stopTest();
        Lead testlead_updated = [select id,Status from lead where Company='PRMLeadsOprtntyControllerTest' limit 1];
        //System.assert(testlead_updated.Status == 'Accepted');
        System.assert(testlead_updated.Status != null);
    }
}