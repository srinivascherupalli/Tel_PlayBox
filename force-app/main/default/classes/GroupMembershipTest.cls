@Istest
public class GroupMembershipTest {
    @testSetup 
    Public static void testData() {
        //getting Role's Developer name from Custom:Label
        String rolesFromCustomLabel = System.Label.Covid_Hardship_Case_Role_Mapping;
        if(String.isBlank(rolesFromCustomLabel))
            return;
        List<String> parentRoleFromCustomLabel = rolesFromCustomLabel.split(',');
        if(parentRoleFromCustomLabel ==null || parentRoleFromCustomLabel.size()==0)
            return;
        //Creating parent roles based on the roles given in the custom label
        List<UserRole> parentRoleList = [Select Id from UserRole where DeveloperName in : parentRoleFromCustomLabel];        
        // creating Child roles with ParentRoleId as given in parentRoleList
        List<UserRole> childRoleList = new List<UserRole>();
        UserRole ur1= null;
        integer i=0;
        //creating multiple child roles, 1 for each parentRole in parentRoleList
        for(UserRole ur: parentRoleList){
            ur1= new UserRole();
            ur1.Name= 'Name1'+i;
            ur1.DeveloperName = 'role1'+i;
            ur1.ParentRoleId = ur.Id;
            childRoleList.add(ur1);
            i++;
        }
        i=0;
        insert childRoleList; 
        //getting Admin Profile to assign to user
        Profile pf= [Select Id from profile where Name='System Administrator'];
        //creating user
        List<User> usrList= new List<User>();
        User usr=null;
        integer j=0;
        //creating multiple users, 1 for each childRole in childRoleList
        for (userRole uRole : childRoleList){
            usr=new User(firstname = 'GroupMembershipTestName'+j, 
                         lastName = 'XYZ'+j, 
                         Username = 'Test'+j+'@xyx.Telstra.com',
                         email = 'Test1'+j+'@xyx.Telstra.com',
                         Alias = 'AYZ'+j, 
                         TimeZoneSidKey = 'America/Los_Angeles',
                         LanguageLocaleKey = 'en_US',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'ISO-8859-1',
                         ProfileId = pf.Id,
                         UserRoleId = uRole.id);
            usrList.add(usr);
            j++;
        }
        j=0;
        insert usrList;
    }
    private static testMethod void  filterCaseToPopulateHOBTest(){
        //Account creation
        Account acc = new Account ();
        acc.name = 'TestAccount';
        acc.Customer_Status__c = 'ACTIVE';
        acc.APTPS_Tier__c = 'Mid-market';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        insert acc;
        
        List<Case> caseLst= new List<Case>();
        Case caseVar= null;
        // Fetching user created above and creating a case of type COVID_19_Financial_Hardship from each user.
        For(User u :[SELECT id, name FROM user where firstname like '%GroupMembershipTestName%' Limit 2]){
            System.runAs(u){
                caseVar= new case();
                caseVar.salesup_Head_of_business__c = null;
                caseVar.accountId = acc.id;
                caseVar.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('COVID_19_Financial_Hardship').getRecordTypeId();
                caseVar.CreatedById = u.id;
                caseLst.add(caseVar);
                caseVar= new case();
            }
        }
        insert caseLst;
        List<Id> idList =new List<Id>();
        For(case c: caseLst){idList.add(c.id);}
        if(idList == null || idList.size()==0){return;}
        //Calling the getUserRole method in class GroupMembership and passing the list of cases
        String recId_Covid19 = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('COVID_19_Financial_Hardship').getRecordTypeId();
        String recId_CBS = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        List<String> validCaseRecordType = new List<String>{recId_Covid19,recId_CBS};
        GroupMembership.filterCaseToPopulateHOB(caseLst,validCaseRecordType);
        
        For(Case c : [Select Id, salesup_Head_of_business__c FROM Case WHERE Id IN :idList limit 1]){
            system.assert(c.id != null) ;
        }
    }
    
    private static testMethod void  InsertUser(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole R = [SELECT Id FROM UserRole WHERE DeveloperName = 'SF_D_Support_Consultant_Offshore'];
        UserRole R1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'TE_GM_Digital_Sales'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, UserRoleId = R.Id,
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        
        User usr1 = new User(Email='telstra1@test.com', 
                             EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_AU', ProfileId = p.Id, 
                             TimeZoneSidKey='Australia/Sydney',username='telsta1@test.com.Test',alias = 'Use1T1');
        
        insert usr1;
        
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        system.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId; 
            acc.Customer_Status__c='Active';
            acc.APTPS_Off_Shore_Restricted__c=True;      
            Insert acc;
            Account acc1 = new Account();
            acc1.name = 'TestClassEvent1';
            acc1.CIDN__c = 'ASDF12345';
            acc1.RecordTypeId = accRecordTypeId; 
            acc1.Customer_Status__c='Active';
            acc1.APTPS_Off_Shore_Restricted__c=False;      
            Insert acc1;
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.Name='TestOppCreateForEventCreate';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName='Develop';
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            opp.ownerid=usr1.Id;
            opp.createdbyid=usr1.Id;
            insert opp;
            
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId=opp.id;
            otm.OpportunityAccessLevel='Edit';
            otm.UserId=usr1.Id;
            insert otm;
            system.assertEquals(otm.OpportunityAccessLevel,'Edit');
            
            
        }
        Test.StopTest();
    }
    //TEAM SFO Sprint 21.12 DIGI-8926 Coverage for isOffshoreRestrictedUser in GroupMembership
    private static testMethod void  TestisOffshoreRestrictedUser(){
        User suser =[SELECT id FROM User LIMIT 1];
        System.runAs(suser){
            List<Id> usIds = new List<Id>();
            for(User usr :[SELECT id FROM User LIMIT 5] ){
                usIds.add(usr.id);
            }
            Map<id,Boolean> userBoolean = GroupMembership.isOffshoreRestrictedUser(usIds);
        }
    }
}