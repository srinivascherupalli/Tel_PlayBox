//Deletes licenses and purges users from teams (account, case, opportunity)
public class CleanUserRecords implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible private String query;
    //Constructor that takes days since last login and isActive status
    public CleanUserRecords(String query){
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
            return  Database.getQueryLocator(query);
    }
    //Deletes licenses and relationships
    public void execute(Database.BatchableContext bc, List<User> scope){
        Database.delete([SELECT Id FROM UserPackageLicense WHERE UserId IN: scope], false);
        /*Database.delete([SELECT Id FROM OpportunityTeamMember WHERE UserId IN: scope], false);
        Database.delete([SELECT Id FROM AccountTeamMember WHERE UserId IN: scope], false);
        Database.delete([SELECT Id FROM CaseTeamMember WHERE MemberId IN: scope], false);*/
    }
    public void finish(Database.BatchableContext bc){}
}