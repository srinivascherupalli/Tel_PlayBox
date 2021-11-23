/*****************************************************************
@Name: APTPS_TaskTriggerHelper
@Author: Ruchika Patil 
@CreateDate: 25/04/2016 
@Description: This is the helper class for trigger APTPS_TaskTrigger to perform update activites of Task record.
@UsedBy: Task 
******************************************************************/
public with sharing class APTPS_TaskTriggerHelper{
    /******************************************************************
    @Description:This method updates all the associated obligation with the closest due date from the Tasks.
    *******************************************************************/  
    public static void updateObligationDueDate(List<Apttus_SRM__SRMObligation__c> obligationList){    
        update ObligationList;  
    }  
    /******************************************************************
    @Description:This method updates all the associated Agreements to change the Status and Status Category
    *******************************************************************/  
    public static void updateAgreementStatus(List<Apttus__APTS_Agreement__c> updatedAgmtList){    
        update updatedAgmtList;  
    }   
}