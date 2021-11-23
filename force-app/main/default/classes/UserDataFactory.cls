/*
 * Created By Ivan Aerlic
 * Description: EDGE-115099.
 */ 
@isTest
public class UserDataFactory {
    //Create a specified number of test users
    public static User [] createUsers(Integer num){
        //User for testing email alerts
        User [] users = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Profile.UserLicense.LicenseDefinitionKey = :UserExpiry.KEY LIMIT 1].Id;
        for(Integer i = 0; i < num; i++){
            users.add(new User(
                ProfileId =  profileId,
                LastName = 'alert',
                Email = 'mrorday@hotmail.com',
                Username = UserInfo.getOrganizationId()+i+'@'+DateTime.now().getTime()+'.com',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                isActive = true,
                FlaggedForDeactivation__c = null));
        }
        return users;
    }
    //Reset the Activatoin Date after it has been set by the User trigger
    public static User [] reset(User [] users){
        for(User user: users){ user.Activation_Date__c = null;} 
		return users;
    }
    //Create a specified number of test users form JSON to get past read only field limitations
    public static User createUserFromJSON(Id id, Date lastLoginDate, Date activationDate, Date flaggedForDeactivation){
        //User for testing email alerts
        User [] users = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Profile.UserLicense.LicenseDefinitionKey = :UserExpiry.KEY LIMIT 1].Id;
        User user = (User)System.JSON.deSerialize('{"attributes":{"type":"User"}, '
                +'"Id":"'+id+'", '
                +'"ProfileId":"'+profileId+'", '
                +'"LastName":"alert","Email":"mrorday@hotmail.com", '
                +'"Username":"'+UserInfo.getOrganizationId()+'@'+DateTime.now().getTime()+'.com",'
                +'"CompanyName":"TEST", '
                +'"Title":"title", '
                +'"Alias":"alias", '
                +'"TimeZoneSidKey":"America/Los_Angeles", '
                +'"EmailEncodingKey":"UTF-8", '
                +'"LanguageLocaleKey":"en_US", '
                +'"AlLocaleSidKeyias":"en_US", '
                +'"isActive":true, '
                +'"Activation_Date__c":'+System.JSON.serialize(activationDate)+', '
                +'"FlaggedForDeactivation__c":'+(flaggedForDeactivation == null ? 'null': System.JSON.serialize(flaggedForDeactivation))+', '
                +'"LastLoginDate":'+System.JSON.serialize(lastLoginDate)+'}', User.class);
        return user;
    }
        public static User [] getUsers(User [] users){
        return [SELECT id, Username, FlaggedForDeactivation__c, Profile.UserLicense.LicenseDefinitionKey, Activation_Date__c, isActive, p_Number__c, email,
                         ProfileId, LastLoginDate, CreatedDate FROM User WHERE Id IN: users];
    }
}