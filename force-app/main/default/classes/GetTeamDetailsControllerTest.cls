/*******************************************************************
Created By          :   Sravanthi
Created Date        :   26-August-2021
Story               :   TEAM SFO Sprint 21.12 DIGI-8926
Desc                :   Used for teams functionality              
***********************************************************************/

@isTest
public class GetTeamDetailsControllerTest {
    
    @testsetup static void testsetUpData(){  
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select Name,DeveloperName, Id From UserRole])
            rolesMap.put(role.DeveloperName, role);
        User adminUser = TestUtil.createRoleId('admin@GeTeam.com','admin',profilesMap.get('System Administrator')?.Name,rolesMap.get('CEO')?.Name);
        insert adminUser;
        List<User> users= new List<User>();
        Test.startTest();
        System.runAs(adminUser){
            User internalUser = TestUtil.createRoleId('AO@GeTeam.com','AccOw',System.Label.Profile_AccountOwner,rolesMap.get('Sales_Ops')?.Name);
            internalUser.Phone='+121231231234';
            users.add(internalUser);
            User SeUser = TestUtil.createRoleId('SE@GeTeam.com','SEUs',System.Label.Profile_SalesEnterprise,rolesMap.get('Sales_Ops')?.Name);
            SeUser.Phone='+121231231234';
            users.add(SeUser);
            
            User SEB2BUser =TestUtil.createRoleId('SEB@GeTeam.com','SEBUs',System.Label.Profile_SalesEnterpriseB2B,rolesMap.get('Sales_Holding')?.Name);
            SEB2BUser.Phone='+121231231234';
            users.add(SEB2BUser);    
            insert users;
            List<Account> accList = new List<Account>();
            Account customerAccount = TestUtil.createAccount('Test Account Team Test');
            customerAccount.Customer_Status__c = 'Active';
            accList.add(customerAccount);
            Account customerAccountOffsh = TestUtil.createAccount('Test Account Team Test Offshore');
            customerAccountOffsh.Customer_Status__c = 'Active';
            customerAccountOffsh.APTPS_Off_Shore_Restricted__c = true;
            accList.add(customerAccountOffsh);
            insert accList;
            
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
            AccountTeamMember member1 = TestUtil.createAccountTeamMember(SeUser.id,'Edit','Sales Rep',customerAccount.id);
            AccountTeamMember member3 = TestUtil.createAccountTeamMember(SEB2BUser.id,'Edit','Sales Rep',customerAccount.id);
            AccountTeamMember member2 = TestUtil.createAccountTeamMember(SeUser.id,'Edit','Sales Rep',customerAccountOffsh.id);            
            AccountTeamMember member4 = TestUtil.createAccountTeamMember(SEB2BUser.id,'Edit','Sales Rep',customerAccountOffsh.id);  
            
            accTeamList.add(member1);
            accTeamList.add(member2);
            accTeamList.add(member3);
            accTeamList.add(member4);
            insert accTeamList;
        }
        Test.stopTest();
    }
    
    
    
    @isTest
    static void TestgetAccTeam(){
        User seUser = [SELECT id FROM User WHERE username ='SE@GeTeam.com' LIMIT 1];
        Test.startTest();
        System.runAs(seUser){
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test' LIMIT 1];
            Account offshoreacc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test Offshore' LIMIT 1];
            
            GetTeamDetailsController.TeamsListWrapper result;
            result= GetTeamDetailsController.getAccTeam(acc.id,UserInfo.getUserId());
            result= GetTeamDetailsController.getAccTeam(offshoreacc.id,UserInfo.getUserId());
            System.assertNotEquals(null,result.existingAccTeam) ;
            System.assertEquals(2,result.existingAccTeam.size()) ;
            Test.stopTest();
        }}
    @isTest
    static void TestgetAccTeam1(){
        User seUser = [SELECT id FROM User WHERE username ='SEB@GeTeam.com' LIMIT 1];
        Test.startTest();
        System.runAs(seUser){
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test' LIMIT 1];
            Account offshoreacc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test Offshore' LIMIT 1];
            
            GetTeamDetailsController.TeamsListWrapper result;
            result= GetTeamDetailsController.getAccTeam(acc.id,UserInfo.getUserId());
            result= GetTeamDetailsController.getAccTeam(offshoreacc.id,UserInfo.getUserId());
            System.assertEquals(null,result.existingAccTeam) ;
            Test.stopTest();
        }}
    @isTest
    static void TestgetAccTeamadmin(){
        User seUser = [SELECT id FROM User WHERE username ='admin@GeTeam.com' LIMIT 1];
        Test.startTest();
        System.runAs(seUser){
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test' LIMIT 1];
            
            GetTeamDetailsController.TeamsListWrapper result;
            result= GetTeamDetailsController.getAccTeam(acc.id,UserInfo.getUserId());
            System.assertEquals(2,result.existingAccTeam.size()) ;
            Test.stopTest();
        }}
    @isTest
    static void TestsaveAccTeam(){
        User seBUser = [SELECT id FROM User WHERE username ='SEB@GeTeam.com' LIMIT 1];
        system.runAs(seBUser){
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test' LIMIT 1];
            List<AccountTeamMember> acclist = [SELECT id,userId FROM AccountTeamMember WHERE AccountId = :acc.Id ];
            
            String result =GetTeamDetailsController.saveAccTeam(null, acclist, null, acc.Id);
        }
    }
    @isTest
    static void TestsaveOffshoreAccTeam(){
        User seBUser = [SELECT id FROM User WHERE username ='SEB@GeTeam.com' LIMIT 1];
        system.runAs(seBUser){
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test Offshore' LIMIT 1];
            List<AccountTeamMember> acclist = [SELECT id,userId FROM AccountTeamMember WHERE AccountId = :acc.Id ];
            
            String result =GetTeamDetailsController.saveAccTeam(null, acclist, null, acc.Id);
        }
        
    }
    @isTest
    static void TestsaveAccTeam1(){
        User seBUser = [SELECT id FROM User WHERE username ='SEB@GeTeam.com' LIMIT 1];
        system.runAs(seBUser){          
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test Offshore' LIMIT 1];
            List<AccountTeamMember> acclist = [SELECT id,userId,AccountAccessLevel FROM AccountTeamMember WHERE AccountId = :acc.Id ];
            if(acclist[0]!=null && acclist[1]!=null){
                acclist[0].AccountAccessLevel='Read';
                String result =GetTeamDetailsController.saveAccTeam(acclist, null, new List<Id>{acclist[0].userId,acclist[1].userId}, acc.Id);
            }
        }
        
    }
    @isTest
    static void TestsaveAccTeam2(){
        User seBUser = [SELECT id FROM User WHERE username ='admin@GeTeam.com' LIMIT 1];
        system.runAs(seBUser){          
            Account acc = [SELECT id FROM Account WHERE Name = 'Test Account Team Test' LIMIT 1];
            List<AccountTeamMember> acclist = [SELECT id,userId,AccountAccessLevel FROM AccountTeamMember WHERE AccountId = :acc.Id ];
            if(acclist[0]!=null && acclist[1]!=null){
                acclist[0].AccountAccessLevel='Read';
                String result =GetTeamDetailsController.saveAccTeam(new List<AccountTeamMember>{acclist[0]}, null, new List<Id>{acclist[0].userId}, acc.Id);
            }
        }
        
    }
}