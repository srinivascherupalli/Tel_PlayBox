/*****************************************************************************
@Name: SelectRolesControllerTest
@Author: SFO Team/Shaik Mahaboob Subani,Amar
@Sprint : 19.13 [P2OB-1659.]
@CreateDate: 30/09/2019
@Description: P2OB-1659. This Test class is for SelectRolesController Code Coverage
@LastModified:Subani and Sravanthi[P2OB-3297]
*******************************************************************************/
@isTest
public class SelectRolesControllerTest {
    
    /****************************************************************************
    @Name: roleNameRoleIdAssignment.
    @Author: SFO Team/Subani, Amar
    @Sprint : 19.13 [P2OB-1659]
    @CreateDate: 30/09/2019.
    @Description: TestMethod to cover getRoles Method of SelectRolesController Class
    ********************************************************************************/    
    @isTest
    public static void getRolesTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [select id from user where id =: userinfo.getUserId()];
        system.runas(thisUser){
            test.startTest();
			
        SelectRolesController.getRolesList();  // Running as System Admin
        UserRole selectRole = new UserRole(DeveloperName = 'SelectRoleTest', Name = 'Select Role Test');
		insert selectRole;
        UserRole usrRoleCheck = [SELECT Name from UserRole where id =: selectRole.id LIMIT 1 ];
        system.assertEquals(usrRoleCheck.Name, 'Select Role Test');
        }
        
        Profile prfBusinessAdmin = [SELECT Id FROM Profile WHERE Name = 'Business Admin'];
		User usr = new User(Email='testuser@test.com.sample', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_AU', ProfileId = prfBusinessAdmin.Id,
            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
        insert usr;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Reference_Data_Admin'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        system.runas(usr){
            SelectRolesController.getRolesList(); // Running as Business Admin
        }
        
        Profile prfSalesEnt = [SELECT Id FROM Profile WHERE Name = 'Sales - Enterprise'];
		User usrSalesEnt = [SELECT Id, ProfileId FROM User WHERE Id =: usr.id];
		usrSalesEnt.ProfileId = prfSalesEnt.Id;
		Update usrSalesEnt;
	    //insert new PermissionSetAssignment(AssigneeId = usrSalesEnt.id, PermissionSetId = ps.Id);
        system.runas(usrSalesEnt){
             SelectRolesController.getRolesList(); // Running as Sales Enterprise User
             Test.stopTest();
        }
    }
    
    /****************************************************************************
    @Name: saveSelectedRadioTest.
    @Author: SFO Team/Subani, Amar
    @Sprint : 19.13 [P2OB-1659]
    @CreateDate: 30/09/2019.
    @Description: TestMethod to cover saveSelectedRadio Method of SelectRolesController Class
    @LastModified:Subani and Sravanthi[P2OB-3297]  
    ********************************************************************************/    
	@isTest
	public static void saveSelectedRadioTest(){
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [select id from user where id =: userinfo.getUserId()];
        system.runas(thisUser){
			test.startTest();
			UserRole usrRole = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
			insert usrRole;
			Portfolio_Code__c portCode = new Portfolio_Code__c(name = 'TestPortfolioCode', Tier__c= 'TestTier' , State__c= 'TestState');
			insert portCode;
			Portfolio_Alignment__c portAlignment = new Portfolio_Alignment__c( Role_in_Territory__c = 'Owner', portfolio_code__c = portCode.id);
			insert portAlignment;
			NPSS_Role_Alignment__c npssRoleAlignment = new NPSS_Role_Alignment__c(Group1__c = 'CLOUD SERVICES', Group2__c = 'CISCO', Group3__c = 'TELSTRA');
			insert npssRoleAlignment;
			//test.stopTest();
			string userRoleRecord = json.serialize(usrRole);
			SelectRolesController.saveSelectedRadio(portAlignment.Id, userRoleRecord);
			SelectRolesController.saveSelectedRadio(npssRoleAlignment.Id, userRoleRecord);
			system.assertEquals(portCode.Name,'TestPortfolioCode');
			
        }
        
        // Testing with Business Admin User
                 	UserRole usrRole1 = new UserRole(DeveloperName = 'MyCustomParentRoleForTarget', Name = 'My Custom Parent Role For Target');
			insert usrRole1;
        			UserRole usrRole2 = new UserRole(DeveloperName = 'MyCustomRoleForTarget', Name = 'My Custom Role For Target',ParentRoleId =usrRole1.Id);
			insert usrRole2;
        Profile prfBusinessAdmin = [SELECT Id FROM Profile WHERE Name = 'Business Admin'];
		User usr = new User(Email='testuser@test.com.sample', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_AU', ProfileId = prfBusinessAdmin.Id,UserRoleId =usrRole2.id,
            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
        insert usr;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Reference_Data_Admin'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        system.runas(usr){
			//test.startTest();
			UserRole usrRole = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role1');
			insert usrRole;
			Portfolio_Code__c portCode = new Portfolio_Code__c(name = 'TestPortfolioCode1', Tier__c= 'TestTier1' , State__c= 'TestState1');
			insert portCode;
			Portfolio_Alignment__c portAlignment = new Portfolio_Alignment__c( Role_in_Territory__c = 'Owner', portfolio_code__c = portCode.id);
			insert portAlignment;
			NPSS_Role_Alignment__c npssRoleAlignment = new NPSS_Role_Alignment__c(Group1__c = 'DATA & IP', Group2__c = 'APPLICATIONS', Group3__c = 'MESSAGING');
			insert npssRoleAlignment;
			//test.stopTest();
			Targets__c target = new Targets__c(Username__c=usr.id,Role_Name__c='My Custom Role For Target');
            insert target;
            //Passing Role record to Wrapper
            SelectRolesController.RoleDetails rolewrp = new SelectRolesController.RoleDetails(usrRole2.Id,usrRole2.Name,null,null);
            string userRoleRecord = json.serialize(rolewrp);
			SelectRolesController.saveSelectedRadio(portAlignment.Id, userRoleRecord);
			SelectRolesController.saveSelectedRadio(npssRoleAlignment.Id, userRoleRecord);
            SelectRolesController.saveSelectedRadio(target.Id, userRoleRecord);
            system.assertEquals(usrRole2.Name, 'My Custom Role For Target');
			
        }
        
        // Testing with Sales Enterprise
        
        Profile prfSalesEnt = [SELECT Id FROM Profile WHERE Name = 'Sales - Enterprise'];
		User usrSalesEnt = [SELECT Id, ProfileId FROM User WHERE Id =: usr.id];
		usrSalesEnt.ProfileId = prfSalesEnt.Id;
		Update usrSalesEnt;
	    //insert new PermissionSetAssignment(AssigneeId = usrSalesEnt.id, PermissionSetId = ps.Id);
        system.runas(usrSalesEnt){
			//test.startTest();
			UserRole usrRole = new UserRole(DeveloperName = 'MyCustomRole2', Name = 'My Role2');
			insert usrRole;
			Portfolio_Code__c portCode = new Portfolio_Code__c(name = 'TestPortfolioCode2', Tier__c= 'TestTier2' , State__c= 'TestState');
			insert portCode;
			Portfolio_Alignment__c portAlignment = new Portfolio_Alignment__c( Role_in_Territory__c = 'Owner', portfolio_code__c = portCode.id);
			insert portAlignment;
			NPSS_Role_Alignment__c npssRoleAlignment = new NPSS_Role_Alignment__c(Group1__c = 'FIXED TELEPHONY', Group2__c = 'CONTACT SOLUTIONS', Group3__c = 'MBSP');
			insert npssRoleAlignment;
			test.stopTest();
			string userRoleRecord = json.serialize(usrRole);
			SelectRolesController.saveSelectedRadio(portAlignment.Id, userRoleRecord);
			SelectRolesController.saveSelectedRadio(npssRoleAlignment.Id, userRoleRecord);
			
        }
	}
}