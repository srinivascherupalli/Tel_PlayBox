/*
* Created by Ivan Aerlic
* Description: Calls the main flow of UesrExpiry in batches. 
* Initially US EDGE-50643, EDGE-72549, EDGE-107620
*/
public Without Sharing class DeactivateUserRecords implements Database.Batchable<sObject>, Database.Stateful {
    //List of inactive users
    private User [] users;
    //The class that holds the main flow of execution
    private UserExpiry expiry = new UserExpiry();
    
    public DeactivateUserRecords(User [] users){
        this.users = users;
    }  
    public User [] start(Database.BatchableContext bc) {
        return users;
    } 
    /* 
    * Runs batches on inactive users
    */
    public void execute(Database.BatchableContext bc, List<User> scope){
        expiry.main(scope);
    }
    /*
    * Sends an email containing all successfully deactivated users, to an address in a custom label
    */
    public void finish(Database.BatchableContext bc){    
        //Makes sure only successfully deactivated users are included in this list
        User [] deactivatedUsers = [SELECT Id, Username, FlaggedForDeactivation__c, LastLoginDate, CreatedDate, Activation_Date__c FROM User WHERE isActive = false AND Id IN: users];
        
        if(!deactivatedUsers.isEmpty()){
            //Send an email of deactivated users
            UserExpiry.sendEmailLog(deactivatedUsers);
        }
    }
}