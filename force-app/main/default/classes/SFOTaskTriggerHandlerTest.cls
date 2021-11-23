/****************************************************************************
@Name: SFOTaskTriggerHandlerTest.
@Author: SFO/Vamshi
@CreateDate: 07/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Class is for test coverage SFOTaskTriggerHandler - P2OB-5475
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               			as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
                        01/11/2021 21.15 by pallavi B,Team SFO
                        as part of DIGI-34437
*****************************************************************************/
@isTest
public class SFOTaskTriggerHandlerTest {
    
     @testSetup
    public static void createData(){
            UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
            User uSysAdmin = TestUtil.createUser('b2btestewwr@noemail.com','SA User',Label.Profile_SystemAdmin);
        
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
            Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];  
            List<user> userList = new List<user>();
            
            User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'salesuser','Testing');
            admin.username='adminuser@testsales.com';
            admin.email='adminuser@testsales.com';
            admin.phone='+121221231234';
            
            User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
            sales.username='salesuser@testsales.com';
            sales.email='salesuser@testsales.com';
            sales.phone='+121231231234';
            userlist.add(uSysAdmin);
            userList.add(sales);
            userList.add(admin);
        
            insert userList;

        System.runAs(uSysAdmin){
            List<Account> newAccList = new List<Account>();
            Account MigrtionLeadacc = TestUtil.createAccount('Test Migrtion Lead Account');
            newAccList.add(MigrtionLeadacc);
            
            insert newAccList;
			id leadRecordId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId();
            List<Lead> newLeadList = new List<Lead>();
            Lead migrationLead = TestUtil.createLead(MigrtionLeadacc.id, 'lead' , 'MigrationError', leadRecordId ,'migrationleademail@gmail.com');
            Lead migrationLead1 = TestUtil.createLead(MigrtionLeadacc.id, 'lead' , 'MigrationError', leadRecordId ,'migrationleademail1@gmail.com');
            Lead migrationLead2 = TestUtil.createLead(MigrtionLeadacc.id, 'lead' , 'MigrationError', leadRecordId ,'migrationleademail2@gmail.com');
            
            newLeadList.add(migrationLead);
            newLeadList.add(migrationLead1);
            newLeadList.add(migrationLead2);
            
            insert newLeadList;
            
            List<Task> newTaskList = new List<Task>();
            Task DeleteMigrationLeadTask = TestUtil.createTask(migrationLead.Id, System.Label.Task_Status_Completed,Label.TaskSubjectFirstBill);
            Task UpdateMigrationLeadTask = TestUtil.createTask(migrationLead1.Id, System.Label.Task_Status_Completed,Label.TaskSubjectFirstBill);
            Task MigrationLeadTask = TestUtil.createTask(migrationLead1.Id, System.Label.Task_Status_Completed, 'First check Bill' );
            Task MigrationLeadTaskUpdate = TestUtil.createTask(migrationLead1.Id, 'Not Started' , Label.TaskSubjectFirstBill );
            
            newTaskList.add(DeleteMigrationLeadTask);
            newTaskList.add(UpdateMigrationLeadTask);
            newTaskList.add(MigrationLeadTask);
            newTaskList.add(MigrationLeadTaskUpdate);
            
            insert newTaskList;
        }
    }
    
       
    /****************************************************************************
    @Method Name: sfoTaskTriggerHandlerUnitTest
    @Author: SFO/Vamshi
    @Sprint : 20.05[P2OB-5475]
    @CreateDate: 07/04/2020
    @Description: This Method is test coverage SFOTaskTriggerHandler.handleBeforeInsert method
    ******************************************************************************/      
    public static testMethod void sfoTaskTriggerHandlerUnitTest(){        
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Task> taskList = new List<Task>();
        
        for(integer i=0; i<20 ; i++){
            Account accRecord = TestUtil.createAccount('Test Account' + i);
            accList.add(accRecord);
        }
        insert accList;
        
        for(Integer y=0; y<20; y++){
            Contact conRecord = TestUtil.createContact(accList[y].id ,'test', 'contacts');
            conList.add(conRecord);
        }
        insert conList;
        
        for(Integer z=0; z<20; z++){
            Task taskRecord = new Task();
            taskRecord.contact__c = conList[z].Id;
        	taskRecord.whatId = accList[z].Id;
            taskList.add(taskRecord);
        }
        insert taskList;
        
        system.assertEquals(taskList[0].whatId, accList[0].Id);
        Test.stopTest();
    } 
    
    /****************************************************************************
    @Method Name: TestFirstBillTaskOnDelete
    @Author: SFO/Pallavi B
    @Sprint : 21.15(DIGI-34437)
    @CreateDate: 01/11/2021
    ******************************************************************************/ 
    @istest
    public static void TestFirstBillTaskOnDelete(){
        User adminuser = [select id,username from User where username =:'b2btestewwr@noemail.com' limit 1];
        Lead MigrationLead = [select id from Lead where Email ='migrationleademail@gmail.com' limit 1 ];
        Task FirstBillTask = [Select id,Subject from Task where WhoId =:MigrationLead.Id and Subject like: Label.TaskSubjectFirstBillPercentile and Status = :System.Label.Task_Status_Completed];
        system.runAs(adminuser){
            Test.startTest();
            delete FirstBillTask;
            Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c from lead where Email ='migrationleademail@gmail.com' limit 1];
        system.assertequals(lstLeads.FirstBillTaskOnLead__c , false);  
   }
    
    /****************************************************************************
    @Method Name: TestFirstBillTaskOnUpdate
    @Author: SFO/Pallavi B
    @Sprint : 21.15(DIGI-34437)
    @CreateDate: 01/11/2021
    ******************************************************************************/ 
    @istest
    public static void TestFirstBillTaskOnUpdate(){
        User adminuser = [select id,username from User where username =:'b2btestewwr@noemail.com' limit 1];
        Lead MigrationLead = [select id from Lead where Email ='migrationleademail1@gmail.com' limit 1 ];
        Task FirstBillTask = [Select id,Subject from Task where WhoId =:MigrationLead.Id and Subject like: Label.TaskSubjectFirstBillPercentile and Status = :System.Label.Task_Status_Completed];
        system.runAs(adminuser){
            Test.startTest();
            FirstBillTask.Subject = 'Test Update';
            Update FirstBillTask;
            Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c from lead where Email ='migrationleademail1@gmail.com' limit 1];
        system.assertequals(lstLeads.FirstBillTaskOnLead__c , false);  
   }
    /****************************************************************************
    @Method Name: TestFirstBillTaskOnUpdate1
    @Author: SFO/Pallavi B
    @Sprint : 21.15(DIGI-34437)
    @CreateDate: 01/11/2021
    ******************************************************************************/ 
    @istest
    public static void TestFirstBillTaskOnUpdate1(){
        User adminuser = [select id,username from User where username =:'b2btestewwr@noemail.com' limit 1];
        Lead MigrationLead = [select id from Lead where Email ='migrationleademail1@gmail.com' limit 1 ];
        Task FirstBillTask = [Select id,Subject from Task where WhoId =:MigrationLead.Id and (NOT(Subject like: Label.TaskSubjectFirstBillPercentile)) and Status = :System.Label.Task_Status_Completed];
        system.runAs(adminuser){
            Test.startTest();
            FirstBillTask.Subject = 'Test First Bill';
            Update FirstBillTask;
            Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c from lead where Email ='migrationleademail1@gmail.com' limit 1];
        system.assertequals(lstLeads.FirstBillTaskOnLead__c , True);  
   }
     /****************************************************************************
    @Method Name: TestFirstBillTaskOnUpdate2
    @Author: SFO/Pallavi B
    @Sprint : 21.15(DIGI-34437)
    @CreateDate: 01/11/2021
    ******************************************************************************/ 
    @istest
    public static void TestFirstBillTaskOnUpdate2(){
        User adminuser = [select id,username from User where username =:'b2btestewwr@noemail.com' limit 1];
        Lead MigrationLead = [select id from Lead where Email ='migrationleademail1@gmail.com' limit 1 ];
        Task FirstBillTask = [Select id,Subject from Task where WhoId =:MigrationLead.Id and Subject like: Label.TaskSubjectFirstBillPercentile and Status = 'Not Started'];
        system.runAs(adminuser){
            Test.startTest();
            FirstBillTask.Status = System.Label.Task_Status_Completed;
            Update FirstBillTask;
            Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c from lead where Email ='migrationleademail1@gmail.com' limit 1];
        system.assertequals(lstLeads.FirstBillTaskOnLead__c , True);  
   }
}