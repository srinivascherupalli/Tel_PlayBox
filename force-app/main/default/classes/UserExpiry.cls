/*
* Created by Ivan Aerlic
* Description: Schedules the system for deactivating and warning users of their deactivation.
* US: EDGE-50643, EDGE-72549, EDGE-107620
*/
public Without Sharing class UserExpiry implements Schedulable{
    
    /**************
     * INSTANCE CONSTANTS 
	***************/
    public static final ULMS_Setting__mdt METADATA_SETTING = [SELECT Initial_Wait__c, Interval_1__c, Interval_2__c, Interval_3__c, Email_Template__c, Admin_Email__c 
                                                   			  FROM ULMS_Setting__mdt LIMIT 1]; 
    public static final String ADMIN_EMAIL = METADATA_SETTING.Admin_Email__c;
    public static final String EMAIL_TEMPLATE = METADATA_SETTING.Email_Template__c;
    //Emails are sent in these intervals
    public static final Integer INTERVAL_1 = (Integer)METADATA_SETTING.Interval_1__c;
    public static final Integer INTERVAL_2 = (Integer)METADATA_SETTING.Interval_2__c;
    public static final Integer INTERVAL_3 = (Integer)METADATA_SETTING.Interval_3__c;
    //Days a user has to be inactive
    public static final Integer INITIAL_WAIT = (Integer)METADATA_SETTING.Initial_Wait__c;
    public static final Date INACTIVITY_DATE = DateTime.now().AddDays(-INITIAL_WAIT).date();//User who have not logged in since this date are alerted
    
    public static final Date CURRENT_DATE = DateTime.now().date();
    public static final String DO_NOT_REPLY = 'do-not-reply-phoenix@team.telstra.com';
    public static final String ROBOT_USER_IDENTIFIER = 'N';//Robotic users in Phoenix P2O have a Pnumber that starts with 'N'
    public static final String KEY = 'SFDC'; //User License Definition key
    public static final Integer BATCH_SIZE = 100;
    
    @testVisible private User [] inactiveUsers;
    @testVisible private User [] resetUsers;
    @testVisible private User [] firstTimeUsers;
    @testVisible private User [] usersToEmail;
    @testVisible private User [] deactivatedUsers;
    @testVisible private User [] usersToUpdate;
    
    /**************
    * EXECUTION
    ***************/
    public void execute(SchedulableContext SC){  
        //Start batch
        DeactivateUserRecords deactivateUserRecords = new DeactivateUserRecords(getUsers());
        Database.executeBatch(deactivateUserRecords, BATCH_SIZE);
    } 
    
    /*
    * Main flow
    */
    public void main(User [] users){  
        //Segregate the users into groups based on similair processes that need to be performed on them
        createCollections(users);
       
        //Update must be done before email send so that changes to FlaggedForDeactivation are commited to database
        //And all updates must be done at once to prevent multiple trigger transactions
        Database.update(usersToUpdate, false); 
        //If any users were deactivated then delete their packaged licenses
        //Database.delete([SELECT Id FROM UserPackageLicense WHERE UserId IN: [SELECT Id, Username FROM User WHERE isActive = false AND Id IN: deactivatedUsers]], false);
       
        //Send email
        if(!usersToEmail.isEmpty()) sendEmailtoUsers(usersToEmail);
    }
    /*
     * Segregates the users into lists, related by common actions
     */ 
    @testVisible private void createCollections(User [] users){   
        //Sets the flagged field to null for all users who have logged in since being flagged
        resetUsers = resetUsers(users);
        
        //Filter out Tranasaction Policy users and users from the suppression list. 
        User [] filteredUsers = filterExemptUsers(users);
        
        //Get users who haven't logged in since the inactivity date
        inactiveUsers = getInactiveUsers(filteredUsers);
        
        //Set the deactivation date of first time users
        firstTimeUsers = flagFirstTimeUser(inactiveUsers);
        
        //must be done after users are flagged
        usersToEmail = getUsersToEmail(inactiveUsers);
        
        //Check deactivation date and set fields
        deactivatedUsers = deactivateUsers(inactiveUsers);
        
        //List of user records that have been edited
        usersToUpdate = new List<User>();
        
        usersToUpdate.addAll(resetUsers);
        usersToUpdate.addAll(firstTimeUsers);
        usersToUpdate.addAll(deactivatedUsers);
    }   
    /*
	* Resets FlaggedForDeactivation date on users who have recently logged in
	*/
    private static User [] resetUsers(User [] users){
        List<User> resetUsers = new List<User>();
        for(User user: users) {
            if(user.FlaggedForDeactivation__c != null && (INACTIVITY_DATE <= user.LastLoginDate || INACTIVITY_DATE <= user.Activation_Date__c)){
                user.FlaggedForDeactivation__c = null;
                resetUsers.add(user);
            }
        }
        return resetUsers;
    }
	/*
    * Flags first time users for deactivation
    */
    private static User [] flagFirstTimeUser(User [] users){
        Date deactivationDate = CURRENT_DATE.addDays(INTERVAL_1); 
        List<User> firstTimeUser = new List<User>();
        for(User user: users) 
            if(user.FlaggedForDeactivation__c == null) {
                user.FlaggedForDeactivation__c = deactivationDate;
                firstTimeUser.add(user);
            }
        return firstTimeUser;
    }
    //Takes a list of people who have not logged in for the intitial wait period
    //flags them and returns them
    private static User [] getUsersToEmail(User [] users){    
            User [] usersToEmail = new List<User>();
            for(User user: users){
                //Alerts users at intervals 1, 2 and 3
                if(user.FlaggedForDeactivation__c == CURRENT_DATE.addDays(INTERVAL_1)
                  || user.FlaggedForDeactivation__c == CURRENT_DATE.addDays(INTERVAL_2)
                  || user.FlaggedForDeactivation__c == CURRENT_DATE.addDays(INTERVAL_3))
                    usersToEmail.add(user);
            }
            return usersToEmail;
    } 
    
    //Sends a mass email to users at intervals 1, 2 and 3
    public static void sendEmailtoUsers(User [] users){
        //Create message
        Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
        massEmail.setSaveAsActivity(false);
        
        //Set template
        EmailTemplate emailTemplate = [SELECT id, Subject, HtmlValue, Body FROM EmailTemplate 
                                       WHERE DeveloperName = :EMAIL_TEMPLATE LIMIT 1];
        massEmail.setTemplateID(emailTemplate.Id);
        
        //Set Address information
        massEmail.setReplyTo(DO_NOT_REPLY);
        massEmail.setSenderDisplayName(DO_NOT_REPLY);
        
        //Set TO addresses from method parameter
        Id [] ids = new List<Id>();
        for(User user: users) ids.add(user.id);
        massEmail.setTargetObjectIds(ids);
        
        //Send email
		if(!Test.isRunningTest()){
        Messaging.sendEmail(new Messaging.MassEmailMessage[] {massEmail});
		}
    } 
    /*
    * Deactivates users
    */
    private static User [] deactivateUsers(User [] users){
        List<User> usersToDeactivate = new List<User>();
        for(User user: users) {
            if(user.FlaggedForDeactivation__c < CURRENT_DATE) {
                System.debug('flagFirstTimeUser');
                user.isActive = false;
                user.IsPortalEnabled = false; //Portal users cannot be deactivated, set this to false
                usersToDeactivate.add(user);
            }
        }  
        return usersToDeactivate;
    }
    /*
	* Sends the list of deactivated users in an email
	*/
    public static void sendEmailLog(User [] deactivatedUsers){
        //Set template
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'User_Deactivation_AGS' LIMIT 1];
        /*This is a a hack. We must user the renderStoredEmail() 
		* method to properly render the template. This method must take a user Id, any user Id will do.*/
        String userId = (String)[SELECT Id FROM User WHERE isActive = false LIMIT 1].Id; 
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate((String)emailTemplate.Id, userId, userId); 
        
        //Options
        email.setSaveAsActivity(false);
        email.setTreatTargetObjectAsRecipient(false);
        
        //Create body from method parameter
        String unames = '<b>Number of Users Deactivated:</b> '+deactivatedUsers.size()+'<br><b>User Information:</b><br>';
        for(User user: deactivatedUsers){ 
            unames += '----------------------------------------------------------------------------------------<br>';
            unames += 'Username: '+user.Username+' | Flagged For Deactivation: '+user.FlaggedForDeactivation__c
                   +' | Last Login Date: '+user.LastLoginDate+' | Activation Date: '+user.Activation_Date__c+' | Created date: '+user.CreatedDate+'<br>'; 
        }
        
        //Set Body to email
        String htmlBody = email.getHtmlbody();
        htmlBody = htmlBody.replace('%usernames%', unames);
        email.setHtmlBody(htmlBody);
        String plainTextBody = email.getPlainTextBody();
        plainTextBody = plainTextBody.replace('%usernames%', unames);
        email.setPlainTextBody(htmlBody);
        
        //Set Address information
        email.setReplyTo(DO_NOT_REPLY);
        email.setSenderDisplayName(DO_NOT_REPLY);
        email.setToAddresses(new List<String>{ADMIN_EMAIL});
        if(!Test.isRunningTest()){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
    }
    /*
     * Returns the users who have not logged in since the inactivity date
     */
    private static User [] getInactiveUsers(User [] users){
        User [] inactiveUsers = new List<User>();
        for(User user: users){
            System.debug('user.LastLoginDate '+user.LastLoginDate);
            System.debug( 'user.Activation_Date__c '+user.Activation_Date__c);
            System.debug('user.CreatedDate '+user.CreatedDate);
            if(!(INACTIVITY_DATE <= user.LastLoginDate) && !(INACTIVITY_DATE <= user.Activation_Date__c) && !(INACTIVITY_DATE <= user.CreatedDate)){
                inactiveUsers.add(user);  
            }
        }
        return inactiveUsers;
    }  
        /*
    * Filter exempt users
    */
    @testVisible private User [] filterExemptUsers(User [] users){
        //this ensures that json records (who are not inserted into database) are not checked in custom setting
        if(Test.isRunningTest() && [SELECT Id FROM User WHERE Id IN :users].isEmpty())
            return users;
        //Retrieve a list of transaction policy users
        TransactionSecurityPolicy [] transactionSecurityPolicies = [SELECT ExecutionUserId FROM TransactionSecurityPolicy];
        //Create a set of transaction policy user ids
        Set<Id> transactionSecurityPolicyUserIds = new Set<Id>();
        for(TransactionSecurityPolicy policy: transactionSecurityPolicies) transactionSecurityPolicyUserIds.add(policy.ExecutionUserId);
        //Filter these users out of the list
        User [] filteredUsers = new List<User>();
        for(User user:users) {
            if(!transactionSecurityPolicyUserIds.contains(user.Id)
               && !ULMS_Hierarchy_Setting__c.getInstance(user.Id).suppressed__c
               && user.Profile.UserLicense.LicenseDefinitionKey == KEY
               && (user.p_number__c == null ||  user.p_number__c == '' || user.p_number__c.substring(0,1) != ROBOT_USER_IDENTIFIER)
               && user.email != DO_NOT_REPLY) {
                   filteredUsers.add(user);
               }
        }
        return filteredUsers;
    }
    public static User [] getUsers() {        
        if(Test.isRunningTest()){
            return [SELECT id, Username, isActive, FlaggedForDeactivation__c, Profile.UserLicense.LicenseDefinitionKey,ProfileId, LastLoginDate, CreatedDate, Activation_Date__c, p_number__c, Email
                FROM User WHERE isActive = true ORDER BY CreatedDate DESC LIMIT :BATCH_SIZE];
        }
        return [SELECT id, Username, isActive, FlaggedForDeactivation__c, Profile.UserLicense.LicenseDefinitionKey,ProfileId, LastLoginDate, CreatedDate, Activation_Date__c, p_number__c, Email
                FROM User WHERE isActive = true ORDER BY CreatedDate DESC];
    }
}