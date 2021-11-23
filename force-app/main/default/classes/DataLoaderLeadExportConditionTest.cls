/*******************************************************************
@Class Name:DataLoaderLeadExportConditionTest

@Comments:Test class for DataLoaderLeadExportCondition

@Last Modified By: Pallavi B              
@Last Modified Date: 16/03/2021 S21.04 :: P2OB-12075             
@Last Modified Comments: As part of Tech Debt (Removed References for the Label of Enterprise Record Type)             

*********************************************************************/
@isTest
public class DataLoaderLeadExportConditionTest {
    @testSetup
    static void setup()
    {    
        id p1 = [select id from profile where name='System Administrator'].id;
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        User uSysAdmin = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p1, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwr@noemail.com',userroleid=r.id);
        insert uSysAdmin;   
         // Query your permission set name 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Allow_All_Lead_Type_Selection'];
       
        // Assigning the Permission Set to the above user as part of P2OB-6310 to allow acess to 'cal me now' and ' MQL Threshold' values.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = uSysAdmin.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        }
    
    public static testMethod void DLeadExportConditionTest() {
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Test.startTest();
         Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();        
        campaign cmp=new Campaign(Name='Test Campaign',Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
        insert cmp;        
        lead leadTest=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                               phone='031245678',Lead_Type__c='Call Me Now',CIDN__c='123445');
        //leadTest.Campaign__c=cmp.id;        
        insert leadTest;

        Map<String, String> eventData = new Map<String, String>();
        eventData.put('NumberOfRecords', '2345');
        eventData.put('ExecutionTime', '1111');
        eventData.put('EntityName', 'Lead');
        
        TxnSecurity.Event e = new TxnSecurity.Event(UserInfo.getOrganizationId(), UserInfo.getUserId(),'Lead','Insert','DataExport', leadTest.id, Datetime.now(),eventData);
        
        /* data - Map with info about this event. */
            /* The only info in the map is the login history, and
the only info in the login history is the Platform. */
            /* We are unit testing a PolicyCondition that triggers
when a login is from Android OS version 5 or older. */
        
        
            DataLoaderLeadExportCondition condition =
            new DataLoaderLeadExportCondition();
        condition.evaluate(e);
        /* Assert that the condition is triggered by evaluating
the event e. The Transaction Security PolicyCondition
interface returns True if the policy is triggered. */
        System.assertEquals(true, condition.evaluate(e));
                        Test.stopTest();
        }
    }
    public static testMethod void DLeadExportConditionTestFalse() {
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Test.startTest();
         Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Default').getRecordTypeId();        
        campaign cmp=new Campaign(Name='Test Campaign',Status='Planned',Type='Advertisement',RecordTypeId=campRecordTypeId);
        insert cmp;        
        lead leadTest=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                               phone='031245678',Lead_Type__c='Call Me Now',CIDN__c='123445');
        //leadTest.Campaign__c=cmp.id;        
        insert leadTest;
          Map<String, String> eventData = new Map<String, String>();
        eventData.put('NumberOfRecords', '200');
        eventData.put('ExecutionTime', '111');
        eventData.put('EntityName', 'Lead');
        
        TxnSecurity.Event e = new TxnSecurity.Event(UserInfo.getOrganizationId(), UserInfo.getUserId(),'Lead','Insert','DataExport', leadTest.id, Datetime.now(),eventData);
        DataLoaderLeadExportCondition condition =
            new DataLoaderLeadExportCondition();
        condition.evaluate(e);
        /* Assert that the condition is triggered by evaluating
the event e. The Transaction Security PolicyCondition
interface returns True if the policy is triggered. */
        System.assertEquals(false, condition.evaluate(e));
            Test.stopTest();
        }
    }
}