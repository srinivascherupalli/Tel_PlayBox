/*****************************************************************************
@Author: Preeti Malik
@CreateDate: 12-June-2019
@ModifiedByandDate: Shreyansh Sharma on 23-3-2020 code fix for Story P2OB-3669. 
@Description: This class contains trigger handler logic for Service Support cases. 
@References
Story:EDGE-84328 Esclations Queue and Queue Changes by Service & Sales Support Team Managers
*******************************************************************************/
public without sharing class srvsup_ServiceCaseHandler {
    public static String recId_ServiceSupport = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
    public static String recId_MobileSupportRequest = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('mm_Mobile_Support_Request').getRecordTypeId();
    public static final String CASE_STATUS_ESCALATED = 'Escalated';
     /**
      * This method is used to assign service cases to Service Escalations Queue when the Status is Escalated.
      * @Author: Preeti Malik
      * @Date: 12-June-2019
      */
    public static void assignCaseToServiceEscalationsQueue(map<ID,Case> oldCaseMap,map<ID,Case> updatedCaseMap){
        if(updatedCaseMap != null && updatedCaseMap.size() > 0){
            Group serviceEscalations = [SELECT DeveloperName,Id,Name FROM Group Where Type = 'Queue' AND DeveloperName = 'srvsup_Service_Escalations' LIMIT 1];
            Group enterpriseMobileSupportPriority = [SELECT DeveloperName,Id,Name FROM Group Where Type = 'Queue' AND DeveloperName = 'mm_Enterprise_Mobile_Support_Priority' LIMIT 1];

            for(Case supportCase : updatedCaseMap.values()){
                if(supportCase.RecordTypeId == recId_ServiceSupport && (oldCaseMap.get(supportCase.id).Status != updatedCaseMap.get(supportCase.id).Status) && updatedCaseMap.get(supportCase.id).Status == CASE_STATUS_ESCALATED){
                    supportCase.OwnerId = serviceEscalations.Id; 
                }
                else if(supportCase.RecordTypeId == recId_MobileSupportRequest && (oldCaseMap.get(supportCase.id).Status != updatedCaseMap.get(supportCase.id).Status) && updatedCaseMap.get(supportCase.id).Status == CASE_STATUS_ESCALATED){
                    supportCase.OwnerId = enterpriseMobileSupportPriority.Id; 
                }
            }
        }
    }
}