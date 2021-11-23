/*
 * DEVELOPERS : Vamshi
 * TEAM: Napier
 * DESCRIPTION : Test Class for CreditAndAdjustmentTriggerHandler
 * EDGE-135560
 * ******************************************************** CHANGE LOG ********************************************************
 * SL.No    Name                Date            Description
 * 1.       Pooja Bhat         21/Jul/2021      EDGE-228125: Test Coverage for functionality - rollup Lastest Credit Date Given to the Customer on Parent Case.
*/

@istest
public class CreditAndAdjustmentTriggerHandlerTest {
    
    public final static Id creditRecTypeId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByDeveloperName().get('Retrospective_Redemption_CA').getRecordTypeId();
  
    //START:EDGE-228125
    @testSetup
    static void testdata() {
        List<Case> caseList = new List<Case>();
        String caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId();  
        Case oCase1 = TestDataFactory.generateCase(null,null,'Email','Medium','New',null,'Billing enquiry Case1','test case 1');
        Case oCase2 = TestDataFactory.generateCase(null,null,'Email','Medium','New',null,'Billing enquiry Case2','test case 2');
        oCase1.RecordTypeId         =   caseRecTypId;
        oCase2.RecordTypeId         =   caseRecTypId;
        caseList.add(oCase1);
        caseList.add(oCase2);
        insert caseList;
        
        List<Credits_and_Adjustments__c> lstCreditAdjInsert = new List<Credits_and_Adjustments__c>();
        Credits_and_Adjustments__c creditAdj1 = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()-10,100.00,oCase1.Id);
        creditAdj1.Determination_Status__c = 'Approved';
        Credits_and_Adjustments__c creditAdj2 = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()-1,110.00,oCase2.Id);
        creditAdj2.Determination_Status__c = 'Approved';
        Credits_and_Adjustments__c creditAdj3 = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()+5,100.00,oCase1.Id);
        Credits_and_Adjustments__c creditAdj4 = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()+15,110.00,oCase2.Id);
        lstCreditAdjInsert.add(creditAdj1);
        lstCreditAdjInsert.add(creditAdj2);
        lstCreditAdjInsert.add(creditAdj3);
        lstCreditAdjInsert.add(creditAdj4);
        insert lstCreditAdjInsert;
    }

    public static testmethod void creditDateRollupUpsert() {
        //Test Method for code coverage of CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase() After Insert and After Update Events for bulk records.
        //Rollup of Latest Credit Date on Case record on Insert and Update of Credit and Adjustments records
        List<Credits_and_Adjustments__c> credAdjList        =   [SELECT Id,Case_Number__c,Date_when_credit_was_given_to_customer__c FROM Credits_and_Adjustments__c];
        List<Credits_and_Adjustments__c> credAdjUpsertList  =   new List<Credits_and_Adjustments__c>();
        Set<String> setCaseIds                              =   new Set<String>();
        Test.startTest();
            for(Credits_and_Adjustments__c oCredit : credAdjList) {
                if(oCredit.Case_Number__c!=null) {
                    setCaseIds.add(oCredit.Case_Number__c);
                    //Creating 4 new Credit and Adjustment Records
                    Credits_and_Adjustments__c creditAdjNew = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()+10,250.00,oCredit.Case_Number__c);
                    credAdjUpsertList.add(creditAdjNew);
                }
                //Updaing Credit Date of existing Credit and Adjustment Records to set the new Last Credit Date given to the customer
                oCredit.Date_when_credit_was_given_to_customer__c = System.today()+50;
                credAdjUpsertList.add(oCredit);
            }
            if(!credAdjUpsertList.isEmpty()) {
                upsert credAdjList; //Will cover trigger insert and update logic code lines
            }
            List<Case> caseList = [SELECT Id,Latest_Date_When_Credit_Was_Given__c FROM Case WHERE Id IN:setCaseIds];
            for(Case oCase : caseList) {
                System.assertEquals(System.today()+50, oCase.Latest_Date_When_Credit_Was_Given__c);
            }
        Test.stopTest();
    }   //End of populateLatestDateOnCaseTest1()

    public static testmethod void creditDateRollupDelUndel() {
        //Test Method for code coverage CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase() After Delete and After Undelete Events for bulk records
        // Rollup of Latest Credit Date on Case record on Deletion and Undelete of Credit and Adjustments records
        List<Credits_and_Adjustments__c> credAdjList        =   [SELECT Id,Case_Number__c,Date_when_credit_was_given_to_customer__c FROM Credits_and_Adjustments__c];
        List<Credits_and_Adjustments__c> credAdjUpsertList  =   new List<Credits_and_Adjustments__c>();
        Set<String> setCaseIds                              =   new Set<String>();
        Test.startTest();
            for(Credits_and_Adjustments__c oCredit : credAdjList) {
                if(oCredit.Case_Number__c!=null) {
                    setCaseIds.add(oCredit.Case_Number__c);
                    //Creating new Credit and Adjustment Records
                    Credits_and_Adjustments__c creditAdjNew = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()+30,250.00,oCredit.Case_Number__c);
                    credAdjUpsertList.add(creditAdjNew);
                }
            }
            if(!credAdjList.isEmpty()) {
                delete credAdjList; //To execute and cover code lines, for after delete logic
            }
            List<Case> caseList = [SELECT Id,Latest_Date_When_Credit_Was_Given__c,(SELECT Id FROM Credits__r) FROM Case WHERE Id IN:setCaseIds];
            for(Case oCase : caseList) {
                System.assertEquals(null, oCase.Latest_Date_When_Credit_Was_Given__c);
                System.assertEquals(0, oCase.Credits__r.size());
            }
            if(!credAdjUpsertList.isEmpty()) {
                insert credAdjUpsertList; //To execute and cover code lines, for after insert logic
            }
            List<Credits_and_Adjustments__c> credAdjListUndelete    =   [SELECT Id,Case_Number__c,Date_when_credit_was_given_to_customer__c FROM Credits_and_Adjustments__c WHERE isDeleted=true ALL ROWS];
            if(!credAdjListUndelete.isEmpty()) {
                undelete credAdjListUndelete; //To execute and cover code lines, for after undelete logic
            }
            List<Case> caseList1 = [SELECT Id,Latest_Date_When_Credit_Was_Given__c,(SELECT Id FROM Credits__r) FROM Case WHERE Id IN:setCaseIds];
            for(Case oCase : caseList1) {
                System.assertNotEquals(null, oCase.Latest_Date_When_Credit_Was_Given__c);
                System.assertNotEquals(0, oCase.Credits__r.size());
            }
        Test.stopTest();
    }   //End of populateLatestDateOnCaseTest2()

    public static testmethod void creditDateRollupInsert() {
        //Test Method for code coverage CreditsAndAdjustmentsTriggerHelper.populateLatestCreditDateOnCase() After Insert and After Update Event for Edge Scenarios
        //a. New CreditAdjustment Record with Status = Approved and same Max Credit Date is set as on Parent Case
        //b. To recalculate Latest Date if only Status field is modified on the CreditAdjustment record
        List<Case> caselst = [SELECT Id FROM Case WHERE Subject = 'Billing enquiry Case1' LIMIT 1];
        Test.startTest();
        if(!caselst.isEmpty()) {
            Credits_and_Adjustments__c creditAdj1 = TestDataFactory.generateCreditsAndAdjustments(null,null,System.today()-10,100.00,caselst[0].Id);
            creditAdj1.Determination_Status__c = 'Approved';
            insert creditAdj1;
            List<Case> caseList1 = [SELECT Id,Latest_Date_When_Credit_Was_Given__c,(SELECT Id FROM Credits__r) FROM Case WHERE Id=:caselst[0].Id];
            System.assertEquals(System.today()-10, caseList1[0].Latest_Date_When_Credit_Was_Given__c);
            System.assertEquals(3, caseList1[0].Credits__r.size());
            creditAdj1.Determination_Status__c = '';
            update creditAdj1;
            List<Case> caseList2 = [SELECT Id,Latest_Date_When_Credit_Was_Given__c,(SELECT Id FROM Credits__r) FROM Case WHERE Id=:caselst[0].Id];
            System.assertNotEquals(null, caseList2[0].Latest_Date_When_Credit_Was_Given__c);
        }
        Test.stopTest();
    }   //End of populateLatestDateOnCaseTest3()
    //END:EDGE-228125

    //Method to test rejection with comments and without comments.
    public static testmethod void testRejectionWithoutComment(){
        Credits_and_Adjustments__c creditRec1=new Credits_and_Adjustments__c(RecordTypeId=creditRecTypeId);
        insert creditRec1;
        Credits_and_Adjustments__c creditRec2=new Credits_and_Adjustments__c(RecordTypeId=creditRecTypeId);
        insert creditRec2;
        List<Id> idList = new List<Id>{};
        idList.add(creditRec1.Id);
        idList.add(creditRec2.Id);
        
        Approval.ProcessSubmitRequest testReq1 = new Approval.ProcessSubmitRequest();
        testReq1.setObjectId(creditRec1.Id);
        testReq1.setProcessDefinitionNameOrId('Retrospective_Redemption_Process');
        testReq1.setSkipEntryCriteria(true);
        
        Approval.ProcessSubmitRequest testReq2 = new Approval.ProcessSubmitRequest();
        testReq2.setObjectId(creditRec2.Id);
        testReq2.setProcessDefinitionNameOrId('Retrospective_Redemption_Process');
        testReq2.setSkipEntryCriteria(true);
        
        Approval.ProcessResult reqResult1 = Approval.process(testReq1);
        Approval.ProcessResult reqResult2 = Approval.process(testReq2);
        
        // Reject the submitted request, with providing a comment.
        Approval.ProcessWorkitemRequest testRej1 = new Approval.ProcessWorkitemRequest();
        testRej1.setComments('Rejecting request with a comment.');
        testRej1.setAction('Reject');
        testRej1.setWorkitemId(reqResult1.getNewWorkitemIds()[0]);
        
        // Reject the submitted request, without providing a comment.
        Approval.ProcessWorkitemRequest testRej2 = new Approval.ProcessWorkitemRequest();
        testRej2.setAction('Reject');
        testRej2.setWorkitemId(reqResult2.getNewWorkitemIds()[0]);
        
    
        Test.startTest();        
        // Attempt to process the rejection
        try{
          Approval.ProcessResult testRejResult1 =  Approval.process(testRej1);
          Approval.ProcessResult testRejResult2 =  Approval.process(testRej2);
          List<Credits_and_Adjustments__c> testList = [select Id,Name,Redemption_Status__c,Comments__c 
                                                       from Credits_and_Adjustments__c where Id IN:idList Order by Name];
          //System.assertEquals('Not Approved',testList[0].Redemption_Status__c);
          //System.assertEquals('Pending',testList[1].Redemption_Status__c);
        }
         catch (DMLException e) {
            system.assertEquals(system.Label.MandatoryCommentsOnRejection,e.getDmlMessage(0));
        }  
        Test.stopTest();
    }
    
    /*
        Put many objects through the approval process, some rejected, some approved,
        some with comments, some without. Only rejctions without comments should be
        prevented from being saved.
    */
    
    public static testmethod void testBatchRejctions(){
 
        List<Credits_and_Adjustments__c> testBatchIS = new List<Credits_and_Adjustments__c>{};
        List<Id> idBatchList = new List<Id>{};
        for (Integer i = 0; i < 20; i++){
            Credits_and_Adjustments__c batchRec = new Credits_and_Adjustments__c(RecordTypeId=creditRecTypeId);
            testBatchIS.add(batchRec);
            idBatchList.add(batchRec.Id);
        }   
           
        insert testBatchIS;
        
        List<Approval.ProcessSubmitRequest> testReqs = new List<Approval.ProcessSubmitRequest>{}; 
        for(Credits_and_Adjustments__c testinv : testBatchIS){
            Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
            testReq.setObjectId(testinv.Id);
            testReq.setProcessDefinitionNameOrId('Retrospective_Redemption_Process');
        	testReq.setSkipEntryCriteria(true);
            testReqs.add(testReq);
        }
        
        List<Approval.ProcessResult> reqResults = Approval.process(testReqs);
 
        List<Approval.ProcessWorkitemRequest> testAppRejs = new List<Approval.ProcessWorkitemRequest>{};
        
        for (Integer i = 0; i < 5 ; i++){
            Approval.ProcessWorkitemRequest testRejWithComment = new Approval.ProcessWorkitemRequest();
            testRejWithComment.setComments('Rejecting request with a comment.');
            testRejWithComment.setAction('Reject');
            testRejWithComment.setWorkitemId(reqResults[i*4].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testRejWithComment);
            
            Approval.ProcessWorkitemRequest testRejWithoutComment = new Approval.ProcessWorkitemRequest();
            testRejWithoutComment.setAction('Reject');
            testRejWithoutComment.setWorkitemId(reqResults[(i*4)+1].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testRejWithoutComment);
            
            Approval.ProcessWorkitemRequest testAppWithComment = new Approval.ProcessWorkitemRequest();
            testAppWithComment.setComments('Approving request with a comment.');
            testAppWithComment.setAction('Approve');
            testAppWithComment.setWorkitemId(reqResults[(i*4)+2].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithComment);
            
            Approval.ProcessWorkitemRequest testAppWithoutComment = new Approval.ProcessWorkitemRequest();
            testAppWithoutComment.setAction('Approve');
            testAppWithoutComment.setWorkitemId(reqResults[(i*4)+3].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithoutComment);            
        }
            
        Test.startTest();        
            // Process the approvals and rejections
            try
            {
                List<Approval.ProcessResult> testAppRejResults =  Approval.process(testAppRejs);
                system.assert(false, 'Any rejections without comments should cause an exception');
                List<Credits_and_Adjustments__c> testBatchList = [select Id,Name,Redemption_Status__c,Comments__c 
                                                       from Credits_and_Adjustments__c where Id IN:idBatchList Order by Name];
          		//System.assertEquals('Not Approved',testBatchList[0].Redemption_Status__c);
          		//System.assertEquals('Pending',testBatchList[1].Redemption_Status__c);
                //System.assertEquals('Approved',testBatchList[2].Redemption_Status__c);
          		//System.assertNotEquals('Pending',testBatchList[3].Redemption_Status__c);
            }
            catch(DMLException e)
            {
                //system.assertEquals(5, e.getNumDml());
                
                for(Integer i = 0; i < 5 ; i++)
                {
                    system.assertEquals((i*4) + 1, e.getDmlIndex(i));
                    system.assertEquals(system.Label.MandatoryCommentsOnRejection,e.getDmlMessage(i));
                }
            }    
        Test.stopTest();
    }
    
}