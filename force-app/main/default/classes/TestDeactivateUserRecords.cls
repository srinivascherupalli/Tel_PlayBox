/*
 * Created by Ivan Aerlic
 * Description: US EDGE-50643, EDGE-72549, EDGE-107620
 */
@isTest(SeeAllData=false)
public class TestDeactivateUserRecords {
    
    @testSetup
    public static void setup(){
        delete [SELECT Id FROM ULMS_Hierarchy_Setting__c WHERE suppressed__c = true];
    }
    //Put users through batch and make sure users get deactivated
    @isTest public static void deactivation() {  
        //Create a list to be deactivated and a control group
        User [] users = UserDataFactory.createUsers(1);
        
        insert users;
        
        for(User user: users){
            Test.setCreatedDate(user.Id, UserExpiry.INACTIVITY_DATE.addDays(-1));
            user.FlaggedForDeactivation__c = System.today().addDays(-1);
        }
        
        update UserDataFactory.reset(users);
		
        //Start batch
        test.startTest();
        //Strange behaviour when inserting list that didn't originate from database
        DeactivateUserRecords deactivateUserRecords = new DeactivateUserRecords(UserDataFactory.getUsers(users));
        Id batchId = Database.executeBatch(deactivateUserRecords, UserExpiry.BATCH_SIZE); 
        Test.stopTest();
        
        //After the testing stops, assert users were updated properly
        System.assertEquals(users.size(), [SELECT id FROM User WHERE isActive = false AND Id IN: users].size());
    }
}