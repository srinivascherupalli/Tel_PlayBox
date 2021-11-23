/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 09/04/2018 
@ModifiedByandDate: 
@Description: This test class for soc_SLAUpdateCaseMilestoneBatch, soc_SLAUpdateCaseMilestoneSchedule
*******************************************************************************/
@isTest(seeAllData=false)
public class soc_SLAUpdateCaseMilestoneBatchTest {  
    
     /*
    * Method Name: slaUpdateCaseMilestoneTest
    * Input Parameter:  void
    * Output Parameter: Void
    * Description: For creating test data and call to batch class
    * Created By:   Sandeep Soni
    * Create Date:  09 April 2019
    */
    static testMethod void slaUpdateCaseMilestoneTest() 
    {
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem(); 
        
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        insert caseObj; 
        test.startTest();
        caseObj.Stage__c='Validate And Assign Order';
        update caseObj;
        
        soc_SLAUpdateCaseMilestoneBatch obj = new soc_SLAUpdateCaseMilestoneBatch();
        id jobid = DataBase.executeBatch(obj); 
        /*validate job batch has been executed*/
        System.assert(jobid!=null);
        Test.stopTest();
    }
}