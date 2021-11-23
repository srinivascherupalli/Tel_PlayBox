/*******************************************************************
@Class Name: mhScorecardCriteriaControllerTest
@Sprint : 20.15  & P2OB-7883
@Author:SFO Team (Pallavi B)
@ModifiedDate: 11/11/2020
@Main Class  : mhScorecardCriteriaController
*********************************************************************/
// Provide test coverage to mhScorecardCriteriaController APEX Class
// Controller used Lightning component for Bluesheet scorecard update 

@istest
public class mhScorecardCriteriaControllerTest {
        /****************************************************************************
    @Method Name:getCriteriaTest
    @Modified: Pallavi (TEAM SFO)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description: When no Bluesheet record is there on opportunity creates.
    ******************************************************************************/
   
   @isTest 
       static void getCriteriaTest(){
           
        //Added as part of P2OB-7883
        Account accRec = TestUtil.createAccount('Account for Blue Sheet');
        insert accRec;
        //Added as part of P2OB-7883
        Opportunity oppRec = TestUtil.createOpportunity(accRec.Id);
        insert oppRec;
           
        Opportunity oppRecord = [Select Id, Opportunity_Number__c from Opportunity where Id = :oppRec.Id LIMIT 1];
        
        mh_Blue_Sheet__c blueSheet = new mh_Blue_Sheet__c();
        bluesheet.Opportunity__c = oppRecord.Id;
        bluesheet.Name = oppRecord.Opportunity_Number__c +'- Blue Sheet';
        insert blueSheet;
        String blueSheetId = blueSheet.id;
        
        system.assertEquals(bluesheet.Opportunity__c,oppRecord.Id);
           
        mh_BlueSheet_Scorecard_Criteria__c[] scCriteria = new List<mh_BlueSheet_Scorecard_Criteria__c>();
        for(Integer i=0;i<3;i++) {
            mh_BlueSheet_Scorecard_Criteria__c criteria = new mh_BlueSheet_Scorecard_Criteria__c(Name='Criteria -' + i, Blue_Sheet__c=blueSheetId);
            scCriteria.add(criteria);
        }
           
        Test.StartTest();
        //Added as part of P2OB-7883. code starts here.
        mhScorecardCriteriaController.bsRecordCheck(oppRec.Id);
        mhScorecardCriteriaController.getCriteria(bluesheet.Opportunity__c); //MOdified as part of P2OB-7883.. code ends here..
        
        Test.StopTest();
    }

    /****************************************************************************
    @Method Name:getCriteriaNoOpportunityRecTest
    @Author: Pallavi (TEAM SFO)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description: When no Bluesheet record is there on opportunity creates.
    ******************************************************************************/
    @isTest static void getCriteriaNoOpportunityRecTest(){
        Account accRec = TestUtil.createAccount('Account for Blue Sheet');
        insert accRec;
        Opportunity oppRec = TestUtil.createOpportunity(accRec.Id);
        insert oppRec;
        
        Opportunity oppRec1 = TestUtil.createOpportunity(accRec.Id);
        insert oppRec1;
        
        Opportunity oppRecord = [Select Id, Opportunity_Number__c from Opportunity where Id = :oppRec.Id LIMIT 1];
        
        mh_Blue_Sheet__c blueSheet = new mh_Blue_Sheet__c();
        bluesheet.Opportunity__c = oppRecord.Id;
        bluesheet.Name = oppRecord.Opportunity_Number__c +'- Blue Sheet';
        insert blueSheet;
        String blueSheetId = blueSheet.id;
        system.assert(blueSheet.Id <> Null);
        mh_BlueSheet_Scorecard_Criteria__c[] scCriteria = new List<mh_BlueSheet_Scorecard_Criteria__c>();
        for(Integer i=0;i<3;i++) {
        mh_BlueSheet_Scorecard_Criteria__c criteria = new mh_BlueSheet_Scorecard_Criteria__c(Name='Criteria -' + i, Blue_Sheet__c=blueSheetId);
        scCriteria.add(criteria);
        }
        Test.StartTest();
        mhScorecardCriteriaController.bsRecordCheck(oppRec.Id);
        mhScorecardCriteriaController.getCriteria(oppRec1.Id);
        Test.StopTest();
    }
  
   /****************************************************************************
    @Method Name:saveCriteriaNegativeTest
    @modified: Pallavi (TEAM SFO)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description: existing method Added Assert Statment.
    *******************************************************************************/
    @isTest static void saveCriteriaTest(){
        //Create test data
        mh_Blue_Sheet__c blueSheet = new mh_Blue_Sheet__c(Name='Test BlueSheet');
        insert blueSheet;
        String blueSheetId = blueSheet.id;
        
        mh_BlueSheet_Scorecard_Criteria__c criteria = new mh_BlueSheet_Scorecard_Criteria__c(Name='Criteria 1', Blue_Sheet__c= blueSheetId);
        insert criteria;
        String cId = criteria.id;
        system.assert(criteria.id <> Null);
        List<String> selectedResponses = new List<String>{cId+':Yes'};
        //Test saving bluesheet criteria record
        Test.StartTest();
        mhScorecardCriteriaController.saveCriteria(selectedResponses); 
        Test.StopTest();
    }
       /****************************************************************************
    @Method Name:saveCriteriaNegativeTest
    @modified: Pallavi (TEAM SFO)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description: existing method just Added Assert Statment.
    ******************************************************************************/
    @isTest static void saveCriteriaNegativeTest(){ 
        
        List<String> selectedResponses = new List<String>{''};
            system.assertEquals(selectedResponses.size(),1);
        //Test negative scenario saving bluesheet criteria record with empty string
        Test.StartTest();
        mhScorecardCriteriaController.saveCriteria(selectedResponses);
        Test.StopTest();
    }


}