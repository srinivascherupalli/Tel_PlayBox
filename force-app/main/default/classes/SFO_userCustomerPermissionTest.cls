/*
    Class       : SFO_userCustomerPermissionTest
    Team        : Team SFO
    Author      : Pallavi B
    Objective   : This class Checks for the customer permissions enabled for user
    Main Class  : SFO_userCustomerPermission
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

*/

@isTest
public class SFO_userCustomerPermissionTest {
    
     /*
    MethodName  : testdata
    Team        : Team SFO
    Author      : Pallavi B
    Method Info : Test data creation
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */
    
    @testsetup static void testdata() {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
        Profile pfAccOwner = [select id from profile where name =:Label.Profile_AccountOwner]; 
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];
        
        List<user> userList = new List<user>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
        sales.username='salesuser@testsales.com';
        sales.email='salesuser@testsales.com';
        sales.phone='+121231231234';
        User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'adminUser','Testing2');
        admin.username='TestingAdmin@TestingAdmin.com';
        admin.email='adminuser@testadmin.com';
        admin.phone='+121231231234';
        
        userList.add(sales);
        userList.add(admin);
        insert userList;
        
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
            WHERE DeveloperName = 'Sales_and_Marketing_Permission'][0].Id
            );

            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = sales.id,
            PermissionSetId = ps.Id
            );
            insert psa;
    } 
    
    /*
    MethodName  : testdata
    Team        : Team SFO
    Author      : Pallavi B
    Method Info : Checks for custom permission on user
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */
    
     @isTest static void checkForUserCustomPermissionsTest() {
        //User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
         User sales = [select id from User where username ='salesuser@testsales.com'];
         system.runas(sales){
         test.startTest();
            List<SFO_userCustomerPermission.flowInputs> fInpsClses = new List<SFO_userCustomerPermission.flowInputs>();
             SFO_userCustomerPermission.flowInputs fInpsCls = new SFO_userCustomerPermission.flowInputs();
            fInpsCls.SalesAndMarketingPermission ='Sales_and_Marketing_Permission';
             fInpsClses.add(fInpsCls);
            List<SFO_userCustomerPermission.FlowOutputs> flops=  SFO_userCustomerPermission.checkForUserCustomPermissions(fInpsClses);
              system.assertEquals(True, flops[0].userHasPermission);
            test.stopTest();    
         
     }
  }
    /*
    MethodName  : testdata
    Team        : Team SFO
    Author      : Pallavi B
    Method Info : Checks for custom permission on user
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)

   */
    
     @isTest static void checkForUserCustomPermissionsNegativeTest() {

         User admin = [select id from User where username ='TestingAdmin@TestingAdmin.com'];
         system.runas(admin){
         test.startTest();
            List<SFO_userCustomerPermission.flowInputs> fInpsClses = new List<SFO_userCustomerPermission.flowInputs>();
             SFO_userCustomerPermission.flowInputs fInpsCls = new SFO_userCustomerPermission.flowInputs();
            fInpsCls.SalesAndMarketingPermission ='Sales_and_Marketing_Permission';
             fInpsClses.add(fInpsCls);
            List<SFO_userCustomerPermission.FlowOutputs> flops=  SFO_userCustomerPermission.checkForUserCustomPermissions(fInpsClses);
              system.assertEquals(false, flops[0].userHasPermission);
            test.stopTest();    
         
     }
  }
}