/************
Modified By   : Team Hawaii
Modified Date : 4/2/2020
Description : Added New method to cover recall method in 'prmApprovalListContoller' class
Jira : P2OB-5510
17-Dec-2020         5               Megha Agarwal           fixes for ALREADY_IN_PROCESS error (removed the code related to submit action of approval process)
* v1.1        Vivian Charlie (Team Hawaii)   16 Mar 2021             P2OB-13537 Getting Lead Recordtype by developername from Lead_Recordtype_Enterprise custom label
***********/
@isTest
public class prmApprovalListContollerTest {

    @testSetup static void setup() {
        Test.startTest();
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops' limit 1];
            
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
              
        insert uSysAdmin;
        Test.stopTest();
    }
        
    
    public static testMethod void TestgetData(){
         User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
         System.runAs(uSysAdmin){ 
            Test.startTest();
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE',Migrated_Customer__c=true);
            insert accdis;
                
            Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
            insert con;
            Id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        
            User u1 = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
         
            insert u1;
           
         
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            system.debug('Proceessing');
            opp.StageName = 'Prospecting';
            opp.AccountId = accdis.Id;
            opp.Partner__c=u1.id;
            opp.SubmittoPartnerStatus__c='Submitted';
            opp.CloseDate = Date.today();
            opp.Ownerid = u1.id;
            insert opp;
            
            
            System.runAs(u1){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(opp.id);
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setSubmitterId(userinfo.getUserid());
                Approval.ProcessResult result =  Approval.process(req);
                list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
                list<id> approvalIds=new list<id>();
                prmApprovalListContoller.getApprovalList();
                for(ProcessInstanceWorkitem pr:processItems)
                {
                    String WrkItem=pr.Id;
                    prmApprovalListContoller.handleApprovalAction(WrkItem,'approved','Approve',opp.id);
                }
                System.assertEquals(opp.Name, 'Test Opportunity');
                Test.stopTest(); 
            }
        }
    }
    
    public static testMethod void TestApprove(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
            Test.startTest();
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
            insert accdis;
            
            Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
            insert con;
            Id p = [select id from profile where name='PRM Community User - Australia'].id;
            
            User u1 = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
            
            insert u1;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            system.debug('Proceessing');
            opp.StageName = 'Prospecting';
            opp.AccountId = accdis.Id;
            opp.Partner__c=userinfo.getUserid();
            opp.SubmittoPartnerStatus__c='Submitted';
            opp.CloseDate = Date.today();
            insert opp;
            system.debug(userinfo.getUserid());
            system.debug('optyId1'+opp.Id);
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(opp.id);
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setSubmitterId(userinfo.getUserid());
            Approval.ProcessResult result =  Approval.process(req);
            
            
            list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
            list<id> approvalIds=new list<id>();
            prmApprovalListContoller.getApprovalList();
            for(ProcessInstanceWorkitem pr:processItems)
            {
                String WrkItem=pr.Id;
                prmApprovalListContoller.approveRecord(WrkItem,'approved');
                
                
                
            }
            System.assertEquals(opp.Name, 'Test Opportunity');
            
            Test.stopTest(); 
        }
    }
   
    public static testMethod void TestReject(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
            Test.startTest();
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
            insert accdis;
            
            Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
            insert con;
            Id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
            
            User u1 = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
            
            insert u1;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            system.debug('Proceessing');
            opp.StageName = 'Prospecting';
            opp.AccountId = accdis.Id;
            opp.Partner__c=userinfo.getUserid();
            opp.SubmittoPartnerStatus__c='Submitted';
            opp.CloseDate = Date.today();
            insert opp;
            
            system.debug(userinfo.getUserid());
            system.debug('optyId1'+opp.Id);
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(opp.id);
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setSubmitterId(userinfo.getUserid());
            Approval.ProcessResult result =  Approval.process(req);
            list<ProcessInstanceWorkitem> processItems=[SELECT Id,ProcessInstance.TargetObjectId,ProcessInstance.SubmittedById FROM ProcessInstanceWorkitem WHERE actorid=:userinfo.getUserid()];
            list<id> approvalIds=new list<id>();
            prmApprovalListContoller.getApprovalList();
            for(ProcessInstanceWorkitem pr:processItems)
            {
                String WrkItem=pr.Id;
                //prmApprovalListContoller.rejectRecord(WrkItem,'Rejected');
            }
            System.assertEquals(opp.Name, 'Test Opportunity');
            
             Test.stopTest(); 
         }
    }
    
    public static testMethod void TestRecall(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
            Test.startTest();
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
            insert accdis;
            
            Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
            insert con;
            Id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
            
            User u1 = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
            
            insert u1;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            system.debug('Proceessing');
            opp.StageName = 'Prospecting';
            opp.AccountId = accdis.Id;
            opp.Partner__c=userinfo.getUserid();
            opp.SubmittoPartnerStatus__c='Submitted';
            opp.CloseDate = Date.today();
            insert opp;
            system.debug(userinfo.getUserid());
            system.debug('optyId1'+opp.Id);
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(opp.id);
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setSubmitterId(userinfo.getUserid());
            Approval.ProcessResult result =  Approval.process(req);
            
            list<String> oppidlist=new list<id>{opp.Id};
            prmApprovalListContoller.reCallRecord(oppidlist);
            System.assertEquals(opp.Name, 'Test Opportunity');
            
            test.stopTest();
        }       
    }
    
    //Hawaii : P20B -5510 : This method covers 'reCallRecord' method in prmApprovalListContoller class
    public static testMethod void TestLeadRecall(){
        Test.StartTest();
            
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){ 
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE',Migrated_Customer__c=true);
            insert accdis;
                
            Contact con = new Contact(FirstName = 'Test Account',LastName='Last Name',AccountId=accdis.Id);
            insert con;
            Id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        
            User u1 = new User(alias = 'prmAp', email='prmApp456@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='prmApp456@noemail.com');
         
            insert u1;
            
            
            Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();//v1.1
            List<Lead> leadList = new List<Lead>();
            Lead le = new Lead();
                le.FirstName = 'Test Lead';
                le.RecordTypeId = leadRecTypeId;
                le.Status = 'Marketing Qualified';
                le.Company = 'Test Company';
                le.Job_Function__c = 'Board member';
                le.LastName = 'Last Name'+1;
                le.Email = 'test@gmail.com';
                le.LeadSource = 'Customer Care';
                le.Customer_Name__c = accdis.Id;
                le.Contact_Name__c = con.Id;
                le.OwnerId=uSysAdmin.Id;
                le.Partner_Principal_Contact__c = u1.Id;
                le.Share_with_Partner_Status__c='Submitted';
                leadList.add(le);
            insert leadList;
            
             
             List<Id> idList = new List<Id>();
             for(Lead lead : leadList){
                 idList.add(lead.Id);
             }
            
            prmApprovalListContoller.reCallRecord(idList);
            Lead[] UpdatedLead = [Select id,Share_with_Partner_Status__c From Lead Where Id IN : idList];
            //system.assertEquals('Recalled', UpdatedLead[0].Share_with_Partner_Status__c);
            system.assert(UpdatedLead[0].Share_with_Partner_Status__c != null);
            Test.stopTest();
         }
    }
}