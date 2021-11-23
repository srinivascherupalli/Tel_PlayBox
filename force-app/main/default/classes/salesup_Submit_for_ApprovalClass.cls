/*
* Created By: Sanjay Thakur
* Purpose: Provides case status value to Lightnig component
* Story: P2OB-5940   
*/

public with sharing class salesup_Submit_for_ApprovalClass{
    
    @AuraEnabled
    //P2OB-5994 - Method fetches Case status for current record.
    public static String getCaseValue(String caseId){
        String caseValue = [select id,status from Case where id =: caseId].status;
        return caseValue;
    }

}