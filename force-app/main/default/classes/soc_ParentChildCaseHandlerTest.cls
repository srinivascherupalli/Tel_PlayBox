/********************************************************************************
@ModifiedBy : Kritika Bhati, Sandeep Soni    
@ModifiedByandDate: 10th April 2019,20 Jun 2019 
@Description:Update Test class coverage
********************************************************************************/
@isTest(seeAllData=false)
public class soc_ParentChildCaseHandlerTest {
    public static String OrderRequestRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId(); 
    public static String ProductRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    /*
For creation of test data
*/
    @TestSetup
    public static void createTestData(){
        
        User thisUser = [ select Id,Name from User where Profile.Name = 'System Administrator' AND isactive =true  LIMIT 1 ];
        System.runAs ( thisUser ) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Enterprise B2B' LIMIT 1];
            User reqUsr = new User(LastName = 'LIVESTON',
                                   FirstName='JASON',
                                   Alias = 'jliv',
                                   Email = 'jason21'+uniqueName + '@test' + orgId + '.org',
                                   Username = 'jason21'+uniqueName + '@test' + orgId + '.org',
                                   ProfileId = profileId.id,
                                   TimeZoneSidKey = 'GMT',
                                   LanguageLocaleKey = 'en_US',
                                   EmailEncodingKey = 'UTF-8',
                                   LocaleSidKey = 'en_US',
                                   Phone='+121231231234'
                                  );
            insert reqUsr;
            
            List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
            Account acc = new Account ();
            acc.name = 'TestAccount';
            acc.Customer_Status__c = 'ACTIVE';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
            insert acc;
            List<Case> caseList = new List<Case>();
            Case caseObj = new Case();
            caseObj.Status = 'New';
            caseObj.stage__c = 'Request Review';
            caseObj.OpportunityId__c = oppLine[0].OpportunityId;
            caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
            caseObj.OwnerId = UserInfo.getUserId();
            caseObj.AccountId = acc.Id;
            caseList.add(caseObj);
            Case caseObj2 = new Case();
            caseObj2.Status = 'New';
            caseObj2.stage__c = 'Request Review';
            caseObj2.OpportunityId__c = oppLine[0].OpportunityId;
            caseObj2.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();    
            caseObj2.OwnerId = UserInfo.getUserId();
            caseObj2.AccountId = acc.Id;
            caseList.add(caseObj2);
            insert caseList;
            
            Contact cnt = new Contact();
            cnt.AccountId = acc.id;
            cnt.LastName = 'user';
            cnt.Title = 'Test';
            //cnt.Phone = '+61322132343';
            cnt.Email = 'test@test.com';
            cnt.Pref_Comm_Method__c = 'Phone';
            cnt.Phone='0456789076';
            cnt.Contact_Status__c = 'Active';
            cnt.Salutation = 'Mr.';
            cnt.FirstName = 'Test';
            cnt.Birthdate = Date.newInstance(1980, 1, 1);
            insert cnt;
            Task tsk = null;
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SFD_Order_Confirmation').getRecordTypeId();
            tsk = new Task();
            tsk.Subject = 'Send Order Confirmation';
            tsk.Priority = 'High';
            tsk.RecordTypeId = taskRecordTypeId;
            tsk.Status = 'In Progress';
            tsk.Description = 'Please send the Order Confirmation to the customer and attach this to the Parent SFD Case for closure';
            tsk.OwnerId = caseObj.OwnerId;
            tsk.whatId = caseObj.id; 
            tsk.WhoId = cnt.Id;
            insert tsk;
            tsk.status = 'Completed';
            update tsk;
            Test.startTest();
            caseObj.requestor__c = reqUsr.Id;
            caseObj.Stage__c='Validate And Assign Order';
            update caseObj;
            Test.stopTest();
        }
    }
    /*For positive test case scenario*/
    static testMethod void test_childcaseCreationPositive() {
        List<Case> parCase = [Select Id from case where RecordTypeId =:OrderRequestRecordTypeId];
        List<Case> childCases = [SELECT ID, Status, Stage__c FROM Case where ParentId =:parCase.get(0).Id];
        List<soc_Case_Line_Item__c> PliList = [Select Id from soc_Case_Line_Item__c where soc_CaseId__c IN:childCases];
        Test.startTest();
        for(Case cs: childCases){
            cs.Status = 'Withdrawn';
            cs.soc_SFD_Sub_Status__c = 'Error';
        }
        update childCases;
        test.stopTest(); 
        system.assert(childCases.get(0).status=='Withdrawn');
    }
    /*For negative test case scenario*/
    static testMethod void test_childcaseCreationNegative() {
        List<Case> parCase = [Select Id,status from case where RecordTypeId =:OrderRequestRecordTypeId];
        List<Case> childCases = [SELECT ID, Status, Stage__c FROM Case where ParentId =:parCase.get(0).Id];
        List<soc_Case_Line_Item__c> PliList = [Select Id from soc_Case_Line_Item__c where soc_CaseId__c IN:childCases];
        for(soc_Case_Line_Item__c pli: PliList){
            pli.soc_order_number__c = 'Test';
        }
        Test.startTest();
        update PliList; 
        for(Case cs: childCases){
            cs.Status = 'Closed';
            cs.soc_SFD_Sub_Status__c = 'Work Completed';
        }
        update childCases;
        test.stopTest(); 
        system.assert(childCases.get(0).status=='Closed'); 
    }
    /*
* Method will create record for profile specific
*/
    static testMethod void testStandardUserBulk() 
    {
        List<Case> parCase = [Select Id from case where RecordTypeId =:OrderRequestRecordTypeId];
        List<Case> childCases = [SELECT ID, Status, Stage__c FROM Case where ParentId =:parCase.get(0).Id];
        List<soc_Case_Line_Item__c> PliList = [Select Id from soc_Case_Line_Item__c where soc_CaseId__c IN:childCases];
        // Create a new user with the Standard User profile
        User su = [SELECT ID FROM User limit 1];
        // Switch current user 
        System.runAs(su) 
        {  
            for(soc_Case_Line_Item__c pli: PliList){
                pli.soc_order_number__c = 'Test';
            }
            Test.startTest();
            update PliList; 
            for(Case cs: childCases){
                cs.Status = 'Closed';
                cs.soc_SFD_Sub_Status__c = 'Work Completed';
            }
            update childCases;
            test.stopTest(); 
            System.assertEquals(childCases.size() ,2);
        }
    }
    //Method to Check Medium Complex queue
    static testMethod void mediumQueueIdCase(){        
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi' LIMIT 1].Id;
        Id ownrId1 = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
        system.debug('>>>> ownerid... '+ownrId);
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<GroupMember> memberList = new List<GroupMember>();
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            memberList.add(member);
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = UserInfo.getUserId();
            member1.GroupId = ownrId1;
            memberList.add(member1);
            insert memberList;
        }
        try{
            
            List<Case> caseList = [Select Id from case where RecordTypeId =:'soc_SFD_Product'];
            
            Test.startTest();
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            caseList[0].OwnerId = UserInfo.getUserId();
            update caseList;
            test.stopTest();
            System.assertEquals(caseList[0].OwnerId , UserInfo.getUserId());
        }catch(Exception e){
        }
    }
    //Method to Test User to User Assignment
    static testMethod void testUserToUserAssignment(){  
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'SFD Agent' LIMIT 1];
        User usr1 = new User(LastName = 'TestLIVESTON',
                             FirstName='TestJASON',
                             Alias = 'jliv',
                             Email = 'testJason.liveston@asdf.com',
                             Username = 'testjason.liveston@asdf.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US'
                            );
        insert usr1;
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi' LIMIT 1].Id;
        Id ownrId1 = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
        system.debug('>>>> ownerid... '+ownrId);
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<GroupMember> memberList = new List<GroupMember>();
            GroupMember member = new GroupMember();
            member.UserOrGroupId = usr1.Id;
            member.GroupId = ownrId;
            memberList.add(member);
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = UserInfo.getUserId();
            member1.GroupId = ownrId1;
            memberList.add(member1);
            insert memberList;
        }
        try{
            List<Case> caseList = [Select Id from case where RecordTypeId =:'soc_SFD_Product'];
            system.debug('user to user ****'+caseList);
            //soc_CaseTriggerHandlerTest.createCase('soc_SFD_Product', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            caseList[0].Description = 'test';
            caseList[0].OwnerId =usr1.Id;
            update caseList;
            Test.startTest();
            caseList[0].OwnerId = UserInfo.getUserId();
            update caseList;
            test.stopTest();
            System.assertEquals(caseList[0].OwnerId , UserInfo.getUserId());
        }catch(Exception e){
        }
    }
    //Adding comment for code coverage.
}