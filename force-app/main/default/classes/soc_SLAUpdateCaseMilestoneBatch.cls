/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 08/04/2018
@ModifiedByandDate: 
@Description: This batch class will update the SLAMilestone of Cases  
*******************************************************************************/ 
global class soc_SLAUpdateCaseMilestoneBatch implements Database.Batchable<sObject>{
    
    String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    String STAGE_VALIDATEANDASSIGN = 'Validate And Assign Order';
    String STAGE_DETAILORDER = 'Detail Order';
    String STATUS_CLOSED = 'Closed';
    String STATUS_WITHDRAWN = 'Withdrawn';
    String STATUS_REJECTED = 'Rejected';
    String STATUS_ONHOLD = 'On Hold';
    
    /*
    * Method Name: start
    * Input Parameter:  Database.BatchableContext BC
    * Output Parameter: Database.QueryLocator
    * Description: For Fetching all cases that have sla false. 
    * Created By:   Sandeep Soni 
    * Create Date:  08 April 2019
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String query = 'SELECT Id, CaseNumber,soc_SLA_Paused_Due_To_Holiday__c, IsStopped, businesshoursid, RecordTypeId'+ 
            ' FROM CASE WHERE RecordTypeId = :recId_SFD_ProductType AND (Stage__c = : STAGE_VALIDATEANDASSIGN OR Stage__c = :STAGE_DETAILORDER) '+
            ' AND Status !=: STATUS_ONHOLD  AND STATUS != :STATUS_CLOSED AND STATUS != :STATUS_WITHDRAWN AND STATUS != :STATUS_REJECTED';
        return Database.getQueryLocator(query);  
    }
    /*
* Method Name: execute
* Input Parameter:  Database.BatchableContext BC, List<Case> lstCase
* Output Parameter: void
* Description: For updating all cases that have sla false. 
* Created By:   Sandeep Soni
* Create Date:  08 April 2019
*/
    global void execute(Database.BatchableContext BC,  List<Case> lstCase)
    {
        Map<Id, Case> caseMap = new Map<Id,Case>(); 
         
        try{
            for(Case cs : lstCase){ 
                caseMap.put(cs.id, cs);
            }
            caseMap = soc_SLABusinessHoursHoliday.processHoliday(caseMap);
            if(caseMap!=null && caseMap.size()>0){
                update caseMap.values(); 
            }
            
        }
        catch(Exception ex){
            System.debug('Exception on Line Number::'+ex.getLineNumber()+' :: '+ex.getMessage());
        }
        
    }  
    /*
* Method Name: finish
* Input Parameter:  Database.BatchableContext BC
* Output Parameter: void
* Description: For finishing batch. 
* Created By:   Sandeep Soni
* Create Date:  08 April 2019
*/
    global void finish(Database.BatchableContext BC)
    {
        
    }
}