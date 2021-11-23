/*******************************************************************
@Class Name: mhScorecardCriteriaController
@Sprint :20.15  & P2OB-7883
@Author:SFO Team (Pallavi B)
@ModifiedDate: 11/11/2020
@References : Funnel Scorecard(Lightning Component)
@TestCoverage : mhScorecardCriteriaControllerTest
*********************************************************************/

public class mhScorecardCriteriaController {
    /****************************************************************************
    @Method Name:bsRecordCheck
    @Author: Pallavi /Amar (SFO Team)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description:  Check for existing Blue Sheet on Opportunity.
    @References : FunnelScorecard(Lightning Component)
    Input parameters: Opportunity ID to check for bluesheet record.
    Output: Boolean makin true if blue sheet record presents.
   
    ******************************************************************************/
   @AuraEnabled
  public static boolean bsRecordCheck(string oppId){
      boolean bsRecordNotExist = False;  //Boolean value to make true when there is a blue sheet record associated to opporunity
        List<mh_Blue_Sheet__c> existingBsRecordList = new List<mh_Blue_Sheet__c>();
        existingBsRecordList = [Select Id from mh_Blue_Sheet__c where Opportunity__c = :oppId order by lastmodifieddate desc LIMIT 1];
        if(existingBsRecordList.size() == 0){
            bsRecordNotExist = True;
        }
    return bsRecordNotExist;
  }
     /****************************************************************************
    @Method Name:getCriteria
    @MOdified By: Pallavi /Amar (SFO Team)
    @Sprint :20.15  & P2OB-7883
    @CreateDate: 11/11/2020
    @Description:  Creates Blue Sheet on Opportunity.
    @References : FunnelScorecard(Lightning Component)
    Input parameters: Opportunity ID to Create for bluesheet record.
    Output: creates blue sheet record and adds score card criteria to bluesheet record.
   
    ******************************************************************************/
   @AuraEnabled
    public static List<mh_BlueSheet_Scorecard_Criteria__c> getCriteria(string blueSheetId){
        //code changes starts as part of P2OB-7883 Sprint 20.15 
        try{
        if((Id.valueOf(blueSheetId)).getSObjectType().getDescribe().getName() == 'Opportunity'){
          Opportunity oppRecord = [Select Id, Opportunity_Number__c from Opportunity where Id = :blueSheetId LIMIT 1];
          List<mh_Blue_Sheet__c> bsRecordList = [Select Id from mh_Blue_Sheet__c where Opportunity__c = :blueSheetId order by lastmodifieddate desc LIMIT 1];
            mh_Blue_Sheet__c bsRecord;
            
            if(bsRecordList.size() == 0){
                bsRecord = new mh_Blue_Sheet__c();
                bsRecord.name = oppRecord.Opportunity_Number__c + ' - Blue Sheet';
                bsRecord.Opportunity__c = Id.valueOf(blueSheetId);
                insert bsRecord;
            }
            else{
                bsRecord = bsRecordList[0];
            }
            blueSheetId = bsRecord.id;              
        }
        }catch(Exception ex){
            System.debug('mhScorecardCriteriaController Exception ::: ' +ex.getMessage());
        }
        //Code Changes Ends  here as part of P2OB-7883
        return [SELECT
                Id, Name, Section__c , Point_Value__c, Criteria_Definition__c, Blue_Sheet__c, Answer__c  
                FROM mh_BlueSheet_Scorecard_Criteria__c WHERE Blue_Sheet__c =: blueSheetId Order by Name LIMIT 100];
        
    }
    
    @AuraEnabled
    public static boolean saveCriteria(List<String> selectedResponses){
        try{
            if(selectedResponses != null && !selectedResponses.isEmpty()){
                List<mh_BlueSheet_Scorecard_Criteria__c> scCriteriaRecords = new List<mh_BlueSheet_Scorecard_Criteria__c>();
                for(String res : selectedResponses){
                    mh_BlueSheet_Scorecard_Criteria__c scRec = new mh_BlueSheet_Scorecard_Criteria__c(); 
                    scRec.Id = Id.valueOf(res.split(':')[0]);
                    scRec.Answer__c = String.valueOf(res.split(':')[1]);
                    scCriteriaRecords.add(scRec);
                }
                
                if(scCriteriaRecords != null && !scCriteriaRecords.isEmpty()){
                    Database.update(scCriteriaRecords, false);
                }
            }
            
            return true;
        } catch(Exception e){
            return false;
        }
    }
}