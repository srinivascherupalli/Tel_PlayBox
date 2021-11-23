/*
* Created By: Sanjay Thakur
* Created Date: 16/09/2020.
* Description : This class covers the Milestone SLA functionality.Returns time for Channel Care Dependent SLA and In Progress SLA.
* Story: P2OB-8669   
*/
public class salesup_CalculateCaseSLA implements Support.MilestoneTriggerTimeCalculator{
    
    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public Integer calculateMilestoneTriggerTime(String caseId,String milestoneTypeId){
        //Fetching Case details from ID passed by Entitlement Process.
        Case cse = [SELECT id,srvsup_Categories__c,salesup_Work_Required__c,status,soc_SFD_Sub_Status__c FROM Case WHERE Id=:caseId AND RecordTypeId =:recId_salesSupportChild];
        //Fetching SLA values from Metadata type.
        Case_SLA_Matrix__mdt[] SLAMatrix = [SELECT id, MasterLabel, Category__c, SLA_In_Minutes__c, Work_Required__c from Case_SLA_Matrix__mdt WHERE Category__c =: cse.srvsup_Categories__c AND Work_Required__c =: cse.salesup_Work_Required__c];
        
        if(cse != null){
            
            return integer.valueOf(SLAMatrix[0].SLA_In_Minutes__c);
        }
        return 0;
        
    }
}