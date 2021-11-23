/*
Developer Name : Manish Dundelu
Team : Tokyo
Date : 30/9/2019 
Feature : Transaction Security policy for Salesforce CLI access.
*/
public Without Sharing class SalesforceCLIBlockerEventCondition implements TxnSecurity.EventCondition { 
    
    public boolean evaluate(SObject event) { // Event sObject is passed to the evaluate method from the policy when an event from Salesforce CLI is raised
        try
        {
            if (event instanceOf APIEvent){ // checking if an event is of the type APIEvent. 
                return handleAPIEvent((APIEvent)event); // call to the handler, and type casting the sobject event to API event for processing.
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception - '+ex.getMessage()+'  - Stack Trace - '+ex.getStackTraceString());
            return true; // returns true ie the policy is invoked and access has been blocked
        }
        return false; // returns false ie the policy is not invoked and the user has the access.       
    }
    
    public boolean handleAPIEvent(APIEvent event){
        System.debug('event --- '+ event);
        String userID = (String)event.get('UserId'); // getting the User's Id from the Event.
        String userAgent = (String) event.get('UserAgent'); // getting the UserAgent for identifying the source of the API Event.
        Set<Id> permissionSetIds = new Set<Id>();
        Set<Id> customPermissionIds = new Set<Id>();
        //Set<String> setPermissionSetName = new Set<String>();
        User contextUser;
        if(Test.isRunningTest())
            contextUser = [select id, Email, Name,profileId,Profile.name,(select PermissionSet.Name from PermissionSetAssignments) from user LIMIT 1]; 
        else
            contextUser = [select id, Email, Name,profileId,Profile.name,(select PermissionSet.Name from PermissionSetAssignments) from user where id =:userID LIMIT 1];
        //if ( connectedAppId.contains('0H40o000000ZrVH') && 'System Administrator'.equalsIgnoreCase(u.profile.name) )
        SalesforceCLIBlockerEventConditionHelper helper = new SalesforceCLIBlockerEventConditionHelper();
        return helper.evaluate(userAgent, contextUser);
        
        
    }
}