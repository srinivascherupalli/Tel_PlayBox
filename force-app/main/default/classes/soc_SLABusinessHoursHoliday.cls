/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 08/04/2018
@ModifiedByandDate: 
@Description: This class is for soc_SLABusinessHoursHoliday Report 
*******************************************************************************/ 
public class soc_SLABusinessHoursHoliday {
    
      
    /*
    * Method Name: processHoliday
    * Input Parameter:  Map<Id, Case> caseMap
    * Output Parameter: Void
    * Description: For validating that current time/today is holiday or not base on case.BusinessHoursId. 
    * Created By:   Sandeep Soni
    * Create Date:  08 April 2019
    */
    public static Map<Id,Case> processHoliday(Map<Id, Case> caseMap){
        for(Case cs : caseMap.values()){
            if(BusinessHours.isWithin(cs.BusinessHoursid, System.Now())){
                 resetSLA_paused_due_to_holiday(cs); 
            }else{
                 setSLA_paused_due_to_holiday(cs);
            }
        }
        return caseMap;  
    }
    /*
    * Method Name: setSLA_paused_due_to_holiday 
    * Input Parameter:  Case cs
    * Output Parameter: Void
    * Description: For restarting current milestone on respective case. 
    * Created By:   Sandeep Soni
    * Create Date:  08 April 2019
    */
    public static void setSLA_paused_due_to_holiday(Case cs){
        cs.IsStopped = true;
        cs.soc_SLA_Paused_Due_To_Holiday__c = true;
    }
    
    /*
    * Method Name: setSLA_paused_due_to_holiday
    * Input Parameter:  Case cs
    * Output Parameter: Void
    * Description: For stopping current milestone on respective case. 
    * Created By:   Sandeep Soni
    * Create Date:  08 April 2019
    */
    public static void resetSLA_paused_due_to_holiday(Case cs){
        cs.IsStopped = false;
        cs.soc_SLA_Paused_Due_To_Holiday__c = false;
    }
    
}