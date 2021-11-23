/*
Developer Name : Manish Dundelu
Team : Tokyo
Date : 30/9/2019 
Feature : Transaction Security policy for Salesforce CLI access.
*/
@isTest
public class SalesforceCLIBlockerEventConditionTest {
    @testSetup
    public static void setup()
    {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Salesforce_CLI_Permission'];
        
        //User cUser = [Select Username,ProfileId, id, Name from User where ProfileId =: pf.Id and IsActive = true limit 1];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User cUser=new User(firstname = 'ABC', 
                            lastName = 'XYZ', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
        insert cUser;
    }
    public static testMethod void authUserPermissionForSalesforceCLI() // test case for User without any permission set
    {
        setup();
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User cUser = [Select Username,email,ProfileId from User where firstname = 'ABC' limit 1 ];
        System.debug('cUser   --- '+cUser);
        APIEvent testEvent = new APIEvent();
        //testEvent.UserId = cUser.Id;
        //testEvent.UserAgent = 'SFDX Toolbelt';
        SalesforceCLIBlockerEventConditionHelper helper = new SalesforceCLIBlockerEventConditionHelper();
        helper.evaluate('SFDX Toolbelt', cUser);
        SalesforceCLIBlockerEventCondition sclib = new SalesforceCLIBlockerEventCondition();
        Boolean result = sclib.evaluate((sObject)testEvent);
        System.assertEquals(true, result,'Policy Blocked the User');
    }
    
    public static testMethod void authUserPermissionForSalesforceCLIblank() // test case for User without any permission set
    {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User cUser = [Select Username,email,ProfileId from User where firstname = 'ABC' limit 1 ];
        System.debug('cUser   --- '+cUser);
        APIEvent testEvent = new APIEvent();
        //testEvent.UserId = cUser.Id;
        //testEvent.UserAgent = 'SFDX Toolbelt';
        //SalesforceCLIBlockerEventConditionHelper helper = new SalesforceCLIBlockerEventConditionHelper();
        //helper.evaluate('SFDX Toolbelt', cUser);
        SalesforceCLIBlockerEventCondition sclib = new SalesforceCLIBlockerEventCondition();
        Boolean result = sclib.evaluate((sObject)testEvent);
        System.assertEquals(true, result,'Policy Blocked the User');
    }
    
    public static testMethod void authUserForSalesforceCLIWithPermission() // test case for user with the custom permission set
    {
        //setup();
        //Profile pf= [Select Id from profile where Name='System Administrator']; 
        //User cUser = [Select Username,ProfileId, id, Name from User where ProfileId =: pf.Id and IsActive = true limit 1];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User cUser = [Select Username,email,ProfileId,(select Id,PermissionSetId,PermissionSet.name from PermissionSetAssignments) from User where firstname = 'ABC' limit 1 ];        
        System.debug('cUser   --- '+cUser);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Salesforce_CLI_Permission'];
        System.debug('ps --- '+ps);
        PermissionSetAssignment permission = new PermissionSetAssignment(AssigneeId = cUser.id, PermissionSetId = ps.Id);
        insert permission;
        
        
        APIEvent testEvent = new APIEvent();
        //testEvent.UserId = cUser.Id;
        //testEvent.UserAgent = 'SFDX Toolbelt';
        SalesforceCLIBlockerEventConditionHelper helper = new SalesforceCLIBlockerEventConditionHelper();
        helper.evaluate('SFDX Toolbelt', cUser);
        SalesforceCLIBlockerEventCondition sclib = new SalesforceCLIBlockerEventCondition();
        Boolean result = sclib.evaluate((sObject)testEvent);
        System.assertEquals(true, result,'Policy did not Block the User');
        
    }
    public static testMethod void authUserForSalesforceCLIWithDifferentUserAgent()  // test case for different user agent other than salesforce cli
    {
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User cUser = [Select Username,email,ProfileId from User where firstname = 'ABC' limit 1 ];
        System.debug('cUser   --- '+cUser);
        APIEvent testEvent = new APIEvent();
        //testEvent.UserId = cUser.Id;
        //testEvent.UserAgent = 'Non SFDX Toolbelt';
        SalesforceCLIBlockerEventConditionHelper helper = new SalesforceCLIBlockerEventConditionHelper();
        helper.evaluate('Non SFDX Toolbelt', cUser);
        SalesforceCLIBlockerEventCondition sclib = new SalesforceCLIBlockerEventCondition();
        Boolean result = sclib.evaluate((sObject)testEvent);
        System.assertEquals(True, result,'Policy not Block the User');
        
    }
    
    public static testMethod void authUserForSalesforceCLIWithCatchCoverage() // for covering the catch block for exception.
    {
        
        APIEvent testEvent = null;
        SalesforceCLIBlockerEventCondition sclib = new SalesforceCLIBlockerEventCondition();
        Boolean result = sclib.evaluate(testEvent);
        System.assertEquals(false, result,'Policy Block the User');
        
    }
    
}