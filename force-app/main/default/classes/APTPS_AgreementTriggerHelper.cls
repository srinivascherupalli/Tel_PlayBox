/*****************************************************************
@Name: APTPS_AgreementTriggerHelper
@Author: Ruchika Patil 
@CreateDate: 17/03/2016 
@Description: This is the helper class for trigger APTPS_AgreementTrigger to perform insert/delete activites of agreement record.
@UsedBy: Agreement 
******************************************************************/
public class APTPS_AgreementTriggerHelper{
    /******************************************************************
    @Description:This method deletes all the previous auto created obligations associated to the agreement record.
    *******************************************************************/  
    public static void deleteAutoObligation(List<Apttus_SRM__SRMObligation__c> autoObligationList){    
        delete autoObligationList;  
    }
    /******************************************************************
    @Description:This method inserts all the Obligations associated to the Agreement clause on the Agreement record.
    *******************************************************************/ 
    public static void insertObligation(List<Apttus_SRM__SRMObligation__c> obligationList){    
        insert obligationList; 
    }
    /******************************************************************
    @Description:This method updates all the associated obligations' status to Terminated when the Agreement record changes to Terminated or Expired.
    *******************************************************************/ 
    public static void updateObligation(List<Apttus_SRM__SRMObligation__c> obligationList){    
        update obligationList; 
    }
    /******************************************************************
    @Description:This method deletes all the associated tasks of terminated obligations.
    *******************************************************************/ 
    public static void deleteObTasks(List<Task> taskList){    
        delete taskList; 
    }
}