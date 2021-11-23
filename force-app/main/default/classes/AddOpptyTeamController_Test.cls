/* @Author        - Team Hawaii
* @Desc           - Test class to cover class 'AddOpptyTeamController'
* @CreatedDate   - 26/02/2020
* @Modifications - (1)26/02/2020 : Ritika Jaiswal : TestMethods to cover class AddOpptyTeamController  
* @Modifications - 04/02/2021 : Sravanthi(Team SFO): TestMethods to cover class AddOpptyTeamController P2OB-11748 ,P2OB-11378
* @Modifications - 04/02/2021 : Sravanthi(Team SFO): TestMethods to cover class AddOpptyTeamController P2OB-11748 ,P2OB-11378
*/
@isTest
public class AddOpptyTeamController_Test {
    @testsetup static void testsetUpData(){     
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole])
            rolesMap.put(role.DeveloperName, role);
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        insert adminUser;
        List<User> users= new List<User>();
        List<Contact> contactList = new List<Contact>();User[] partnerUser=new List<User>();
        Account[] customerAccount;
        Test.startTest();
        System.runAs(adminUser[0]){
        User[] internalUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('Account Owner')} , rolesMap.get('CEO'));
		internalUser[0].phone='+121231231234';
            users.addAll(internalUser);
            User[] ICMUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('Indirect Channel Manager')} , rolesMap.get('Sales_Ops'));
            ICMUser[0].phone='+121231231234';
			users.addAll(ICMUser);
            User[] AMUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('Account Manager')} , rolesMap.get('Sales_Ops'));
            AMUser[0].phone='+121231231234';
			users.addAll(AMUser);
			
			User[] SEB2BUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('Sales Enterprise B2B')} , rolesMap.get('Sales_Ops'));
			SEB2BUser[0].phone='+121231231234';
			users.addAll(SEB2BUser); 
            //users.addAll(PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('Sales Enterprise B2B')} , rolesMap.get('Sales_Ops')));            
            users.addAll(PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator - CALMS New')} , rolesMap.get(System.label.UserRole)));                        
            
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            System.debug('PRMOpportunityTeamTest:customerAccount'+partnerAccount);            
            insert partnerAccount;   
            Contact contact = new Contact();
            contact.FirstName = 'Test Account1';
            contact.LastName='Last Name1';
            contact.AccountId=partnerAccount[0].Id; //Contact assigned in partner-account
            contactList.add(contact);
            Contact contact2 = new Contact();
            contact2.FirstName = 'Test Account2';
            contact2.LastName='Last Name2';
            contact2.AccountId=partnerAccount[0].Id; //Contact assigned in partner-account
            contactList.add(contact2);
            insert contactList; 
            partnerAccount[0].isPartner = True;
            partnerAccount[0].PartnerPrincipalContact__c = contact.id;
            partnerAccount[0].CWP_Eligible_Partner__c = false;
            partnerAccount[0].Account_Status__c = 'Active';
            update partnerAccount[0];
            partnerUser = PRMTestUtility.createPartnerUsers(2,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,contactList ,false);
            users.addAll(partnerUser);
            insert users;
        }
        Test.stopTest();
        Opportunity opp;
        System.runAs(partnerUser[0]){         
            customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account acc : customerAccount){
                acc.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            AccountTeamMember member1 = new AccountTeamMember(UserId=UserInfo.getUserId(),AccountId=customerAccount[0].id,teammemberrole='Sales Rep');  
            insert member1;
            //Opportunity creation
            opp = new Opportunity(RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId(),
                                              AccountId = customerAccount[0].Id,
                                              Product_Domain__c = 'MOBILES',
                                              Name = 'Test Opportunity withoutBasket',
                                              CloseDate = System.today()+30,
                                              StageName = 'Develop',
                                              Description__c = 'TestOpp',
                                              Contract_Type__c = 'BSA',
                                              Pricing_Method__c = 'PET'
                                             );
            insert opp;        
        }
        System.runAs(adminUser[0]){
            List<OpportunityTeamMember> otm_List = new List<OpportunityTeamMember>();
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = users[1].id,TeamMemberRole = 'Sales Rep',OpportunityAccessLevel='Edit');
            otm_List.add(otm);
            OpportunityTeamMember otm2 = new OpportunityTeamMember (OpportunityId = opp.id,UserId = adminUser[0].id,TeamMemberRole = 'Sales Rep',OpportunityAccessLevel='Edit');
            otm_List.add(otm2);
            insert otm_List;
        }
        
    }
    
    //Test Method for getselectOptions
    public static testMethod void test_displayTeam(){
        List<OpportunityTeamMember> listMembers = new list<OpportunityTeamMember>();
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opportunity withoutBasket' limit 1];       
        Test.startTest(); 
        if(opp!=null)
        listMembers = AddOpptyTeamController.displayTeam(opp.id);
        Test.stopTest();
        System.assert(listMembers.size()>0);
    }
    
    public static testMethod void test_checkCondition_error(){
        String response_error;         
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opportunity withoutBasket'];

        User user = [SELECT Id,Profile.name from user where Profile.name IN ('Account Manager') and email = 'test@noemail1234.com0' limit 1];       

        Test.startTest();
        if(opp!=null)
            response_error = AddOpptyTeamController.checkCondition(opp.id, user.id );            
        Test.stopTest();
        System.debug('response:'+response_error);
        System.assert(String.isNotBlank(response_error));
    }
    /**
     * P2OB-11748 ,P2OB-11378 TEAM SFO Modified as error is only for non opp owners for internal users
     */
    public static testMethod void test_checkCondition_success(){
        String response_success;         
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opportunity withoutBasket'];

        User user = [SELECT Id,Profile.name from user where Profile.name IN ('Indirect Channel Manager') and email = 'test@noemail1234.com0' limit 1]; 
		User user1 = [SELECT Id,Profile.name from user where Profile.name IN ('Account Manager') and email = 'test@noemail1234.com0' limit 1]; 
        Test.startTest();
        if(opp!=null){
            opp.OwnerId = user.id;
            upsert opp;        
            response_success = AddOpptyTeamController.checkCondition(opp.id, user1.id );  
        }          
        Test.stopTest();
        System.debug('response:'+response_success);
        System.assert(String.isNotBlank(response_success));
    }
    
    public static testMethod void test_checkCondition_PRMerror(){
        String response_success;         
        Opportunity opp = [Select id,ownerId from Opportunity where Name = 'Test Opportunity withoutBasket' limit 1];

        User user = [SELECT Id,Profile.name from user where Profile.name IN ('PRM Community User - Australia') and email = 'test@noemail45345555.com1' and id !=:opp.OwnerId limit 1];       
        Test.startTest();
        if(opp!=null)   
            response_success = AddOpptyTeamController.checkCondition(opp.id, user.id );            
        Test.stopTest();
        System.debug('response:'+response_success);
        System.assert(String.isNotBlank(response_success));
    }
    
    public static testMethod void test_checkUserValidation_error(){
        Boolean result;
        Opportunity opp = [Select id,accountId from Opportunity where Name = 'Test Opportunity withoutBasket' limit 1];
        Account acc = [select id,APTPS_Off_Shore_Restricted__c from Account where id =: opp.accountId];
        acc.APTPS_Off_Shore_Restricted__c = true;
        upsert acc;

        User user = [SELECT Id,Profile.name from user where Profile.name IN ('Account Manager') and email = 'test@noemail1234.com0' limit 1];

        Test.startTest(); 
        if(opp!= null && user!=null)
        result = AddOpptyTeamController.checkUserValidation(opp.id,user.id);
        Test.stopTest();

        System.assert(result != Null );

    }
    
    public static testMethod void test_checkUserValidation_success(){
        Boolean result;
        Opportunity opp = [Select id,accountId from Opportunity where Name = 'Test Opportunity withoutBasket' limit 1];
        Account acc = [select id,APTPS_Off_Shore_Restricted__c from Account where id =: opp.accountId];
        acc.APTPS_Off_Shore_Restricted__c = true;
        upsert acc;

        User userSysAdmin = [SELECT Id,UserRole.DeveloperName from user where (Profile.Name ='System Administrator'  and email = 'test@noemail1234.com0') limit 1];
        Group gp = new Group(Name = 'Test role');
        insert gp;
        User user = [SELECT Id,UserRole.DeveloperName from user where (UserRole.DeveloperName IN (: System.label.UserRole) and email = 'test@noemail1234.com0') limit 1];

        Test.startTest(); 
        if(opp!= null && user!=null)
        result = AddOpptyTeamController.checkUserValidation(opp.id,user.id);
        Test.stopTest();

        System.assert(result != Null );

    }
    
    public static testMethod void test_deleteMember(){
        List<OpportunityTeamMember> listMembers= new List<OpportunityTeamMember>();
        Opportunity opp = [Select id,accountId,(select id from OpportunityTeamMembers limit 1) from Opportunity where Name = 'Test Opportunity withoutBasket'];
        Test.startTest();
        if(opp!=null)
        listMembers = AddOpptyTeamController.deleteTeamMember(opp.OpportunityTeamMembers[0].id,opp.id);
        Test.stopTest();
        System.debug('listMembers:'+listMembers);
        System.assert(listMembers.size()>0);
    }
    
    public static testMethod void test_saveTeamMember(){
        Opportunity opp = [Select id,accountId,(select id from OpportunityTeamMembers) from Opportunity where Name = 'Test Opportunity withoutBasket'];
        Integer sizeBefore = opp.opportunityTeamMembers.size();

        User[] users = [Select id from user where profile.name ='Sales Enterprise B2B' and email = 'test@noemail1234.com0' limit 1];

        Test.startTest(); 
        if(opp!=null){
        List<OpportunityTeamMember> otm_List = new List<OpportunityTeamMember>();
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = users[0].Id ,TeamMemberRole = 'Sales Rep',OpportunityAccessLevel='Edit');
        otm_List.add(otm);
        AddOpptyTeamController.saveTeamMember(otm_List,opp.opportunityTeamMembers);
        }
        Test.stopTest();
        Opportunity opp_Latest = [Select id,accountId,(select id from OpportunityTeamMembers) from Opportunity where id =: opp.id];
        Integer sizeAfter = opp_Latest.opportunityTeamMembers.size();
        System.assert(sizeAfter>sizeBefore);
    }
    
    public static testMethod void test_getselectOptions(){
        Test.startTest(); 
        List<String> list_result = AddOpptyTeamController.getselectOptions(Schema.getGlobalDescribe().get('OpportunityTeamMember').newSObject(), 'OpportunityAccessLevel');
        Test.stopTest();
        System.assert(list_result.size()>0);
    }
    /**
     * P2OB-11748 ,P2OB-11378 TEAM SFO 
     */
    public static testMethod void test_getUserType(){
        User user = [SELECT Id,Profile.name from user where Profile.name IN ('Account Manager') limit 1];       
        Opportunity opp = [Select id,accountId from Opportunity where Name = 'Test Opportunity withoutBasket' LIMIT 1];

        Test.startTest(); 
        AddOpptyTeamController.TeamList response= AddOpptyTeamController.getAccDataUserType(user.Id,opp.accountId,opp.id);
        Test.stopTest();
        System.assertEquals(response.userType,'Standard');
    }
    /**
     * P2OB-11748 ,P2OB-11378 TEAM SFO 
     */
    public static testMethod void test_getUserDefaultTeam(){
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opportunity withoutBasket' LIMIT 1];
        
        User user = [SELECT Id,Profile.name from user where Profile.name IN ('Indirect Channel Manager') and email = 'test@noemail1234.com0' limit 1]; 
        
        Test.startTest(); 
        AddOpptyTeamController.TeamList response = AddOpptyTeamController.getUserDefaultTeam(user.Id,opp.Id);
        Test.stopTest();
        System.assertnotEquals(response.oppTeamMemberList.size(),null);
    }
    /**
     * P2OB-11748 ,P2OB-11378 TEAM SFO 
     */
    public static testMethod void test_deleteAllTeamMember(){
        List<Id> oppTeamList = new List<Id>();
        for(OpportunityTeamMember oppTeam : [Select id from OpportunityTeamMember where Opportunity.Name = 'Test Opportunity withoutBasket']){
            oppTeamList.add(oppTeam.id);
        }
        
        Test.startTest(); 
        AddOpptyTeamController.deleteAllTeamMember(oppTeamList);
        Test.stopTest();
        System.assertEquals(0, [Select id from OpportunityTeamMember where Opportunity.Name = 'Test Opportunity withoutBasket'].size());
    }
  
    /**
     * P2OB-13741 TEAM SFO 
     */
    public static testMethod void test_removeMeFromOppTeam(){
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamOrgList = [SELECT id,OpportunityId FROM OpportunityTeamMember WHERE Opportunity.Name = 'Test Opportunity withoutBasket'];
        for(OpportunityTeamMember oppTeam :oppTeamOrgList){
            oppTeamList.add(oppTeam);
        }
        Test.startTest(); 
        AddOpptyTeamController.removeMeFromOppTeam(oppTeamList[0].OpportunityId,null);
        Test.stopTest();
        System.assertEquals(3, [Select id from OpportunityTeamMember where Opportunity.Name = 'Test Opportunity withoutBasket'].size());
    }
    
    /**
     * P2OB-13741 TEAM SFO 
     */
    public static testMethod void test_updateOppTeam(){
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamOrgList = [SELECT id,OpportunityId FROM OpportunityTeamMember WHERE Opportunity.Name = 'Test Opportunity withoutBasket'];
        for(OpportunityTeamMember oppTeam :oppTeamOrgList){
            oppTeamList.add(oppTeam);
        }
        Test.startTest(); 
        Id OppId =oppTeamList[0].OpportunityId;
        AddOpptyTeamController.updateOppTeam(OppId,'Sales Rep');
        Test.stopTest();
        System.assertEquals(4, [Select id from OpportunityTeamMember where OpportunityId =: OppId].size());
    }
    
}