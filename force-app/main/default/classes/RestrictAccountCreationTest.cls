/*****************************************************************************
@Name: RestrictAccountCreationTest
@Author: Sri
@CreateDate: 08/01/2019
@Description: P2OB-4278. This is a test class for RestrictAccountCreation.
@LastModified:
*******************************************************************************/
@isTest
public class RestrictAccountCreationTest {
    static testMethod void loggedInAsSysAdminTest(){
        boolean isAdmin ;
        id sysAdminPorfileID = [select id from profile where name='System Administrator'].id;
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert ur;
        User adminUser = new User(alias = 'admin', email='adminUser@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = sysAdminPorfileID, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='adminUser@noemail.com',userroleid=ur.id);
        insert adminUser;
        Test.startTest();
        system.runas(adminUser){
 	      isAdmin = RestrictAccountCreationController.loggedInAsSysAdmin();
 		}
        system.assertEquals(true,isAdmin);
        Test.stoptest();
    }
}