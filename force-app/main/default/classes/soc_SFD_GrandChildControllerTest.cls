/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 12 feb 2019
@ModifiedByandDate: 
@Description: Test class for soc_SFD_GrandChildController. 
@References
Epic :EDGE-65104: Case Line Item View on Parent Case

*******************************************************************************/
@isTest
private class soc_SFD_GrandChildControllerTest
{
    @isTest
    static void TestForgotPassword()
    {
        /*List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.stage__c = 'Request Review';
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        test.startTest();
        insert caseObj;
        
        caseObj.Stage__c='Validate And Assign Order';
        upsert caseObj;
        List<Case> csList = soc_SFD_GrandChildController.getChildHierarchy(caseObj.Id);
        System.assert(csList != null);*/
        
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.stage__c = 'Request Review';
        caseObj.subject = 'request';
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        test.startTest();
        system.debug('<<<<LIMIT>>>>'+Limits.getQueries());
        insert caseObj;
        List<Case> csList = soc_SFD_GrandChildController.getChildHierarchy(caseObj.Id);
        system.debug('<<<<LIMIT>>>>'+Limits.getQueries());
        test.stopTest();
        system.assert(csList!=null);
    }

}