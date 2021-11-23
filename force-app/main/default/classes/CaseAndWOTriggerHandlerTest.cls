/***********************************************************************************************************
 *  DIGI-18800      : Post a chatter msg and close the cases and Work Order once Opportunity is closed. 
 *  Feature Team    : Hawaii (21.15)
 ***********************************************************************************************************/

@IsTest
public class CaseAndWOTriggerHandlerTest {
    
    private static testMethod void  spEventPublishOnOppCreationTest(){
        Test.StartTest();
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        customerAccount[0].Customer_Status__c = 'Active';
        insert customerAccount;
        
        //Opportunity creation
        Opportunity opp = new Opportunity(RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId(),
                                          AccountId = customerAccount[0].Id,
                                          Product_Domain__c = 'MOBILES',
                                          Name = 'Test Opportunity withoutBasket',
                                          CloseDate = System.today()+30,
                                          StageName = 'Develop',
                                          Description__c = 'TestOpp',
                                          Contract_Type__c = 'BSA',
                                          Pricing_Method__c = 'PET'
                                         );
        insert opp; 
        
        Id presalesrectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        list<Case> lC = PRMTestUtility.createCases(1,presalesrectypeId);
        lC[0].OpportunityId__c = opp.Id;
        lC[0].AccountId = customerAccount[0].Id;
        lC[0].Stage__c = 'Queued';
        lC[0].Technology_Specialisation__c = 'Digital';
        insert lC;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId = lC[0].Id;
        wo.Status = 'New';
        wo.Subject = 'New WO';
        wo.AccountId = customerAccount[0].Id;
        wo.cusdl_work_order_type__c = 'Commercial';
        insert wo;

        /*            
        List<Case_and_Work_Order_Data__e> eventList = new List<Case_and_Work_Order_Data__e>();
        Case_and_Work_Order_Data__e events = new Case_and_Work_Order_Data__e();
        events.Object_Name__c = 'Case';
        events.Record_Id__c = lC[0].Id;
        eventList.add(events);
        List<Database.SaveResult> results = EventBus.publish(eventList);
        */

        String yourFilesContent = 'TheBlogReaders File upload content';
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'testing.txt';
        conVer.Title = 'Testing Files';
        conVer.VersionData = EncodingUtil.base64Decode(yourFilesContent);
        insert conVer;

        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = opp.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        opp.StageName = 'Closed Won';
        update opp;

        Test.StopTest();
    }
}