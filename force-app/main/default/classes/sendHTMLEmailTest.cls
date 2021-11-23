@isTest
private class sendHTMLEmailTest {
    
    static testMethod void testUserEmail(){
         id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
           Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            Insert acc;
 
        Contact con = new Contact(
        AccountId = acc.id,
        LastName = 'Last Partner',
        FirstName = 'First',
        Contact_Role__c = 'Consultant',
        OTP_Mobile_Phone_Number__c = '+612345678',
        Email = 'test@tesadle2.com'   
        );
        Insert con;
              
        Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            opp.Name='TestOppCreateForEventCreate';            
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;      

  
        Emailtemplate temp= [select id,developername from Emailtemplate where DeveloperName='GES_A_Submit_to_Partner'];
        
        Test.startTest();
        
          // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
     
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('Target Object Id', con.id);
        inputParams.put('Email Template', temp.id);
        inputParams.put('Subject', 'TEST');
        inputParams.put('Emails (comma-separated)', 'test@test.com');
        inputParams.put('Record Id',opp.id);
        inputParams.put('Orgwide Email','do-not-reply-phoenix@team.telstra.com');
        
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
                system.assert(result!=null);

      Test.stopTest();
    }
    
    
   
    // Tests the describe method
    static testMethod void describeTest() {

        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Process.PluginDescribeResult result =  plugin.describe();   // Assert there are 10 inputs        
        System.AssertEquals(result.inputParameters.size(), 6);
        

    }
}