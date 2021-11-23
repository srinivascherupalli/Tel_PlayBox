/*		Class Name	::	soc_MilestoneUtils
*   Developer Name::	Kritika Bhati
*   Description: This class for Milestone logic
*
*/
public without sharing class soc_MilestoneUtils {
    
    /* 
    * EDGE-57886	::	SLA For SFD Cases
    * Developer Name::	Sandeep Soni
    * Method Name: completeMilestone
    * Description:	This method will fetch all CaseMilestone and update completion date based on case and milestone name.
    */
    public static void completeMilestone(Map<Id, Case> caseMap, Set<String> mileStoneSet, DateTime complDate) 
    { 
        List<CaseMilestone> lstCMSToUpdate = [select Id, completionDate from CaseMilestone cm where caseId IN :caseMap.keySet() AND 
                                              cm.MilestoneType.Name IN :mileStoneSet AND completionDate = NULL limit 1]; 
        
        if(lstCMSToUpdate!=null && lstCMSToUpdate.size()>0){
            for(CaseMilestone cms : lstCMSToUpdate){
                cms.completionDate = complDate;
            }
            
            update lstCMSToUpdate;
        }
        
    }
        
}