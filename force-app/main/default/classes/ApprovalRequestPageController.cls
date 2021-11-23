/*******************************************************************
@Class Name     :   ApprovalRequestPageController
@Sprint         :   20.12 (P2OB-9282)
@Author         :   Sri (Team SFO)
@CreateDate     :   08/27/2020
@Description    :   Get the parentId/targetId for the current approval request/processinstanceworkitem
@References     :   EditRelatedRecordFromApprovalRequestPage Aura Component
@TestCoverage   :   ApprovalRequestPageControllerTest
*********************************************************************/
public class ApprovalRequestPageController {
    private static String OBJECT_CASE = 'Case';
    private static String OBJECT_PROCESSINSTANCEWORKITEM = 'ProcessInstanceWorkitem';

/****************************************************************************
@Method Name:	getRelatedRecord
@Sprint 	:	20.12  & P2OB-9282
@CreateDate	: 	08/27/2020
@Description: 	To Fetch the related record Id
@References : 	EditRelatedRecordFromApprovalRequestPage Aura Component
Output		: 	related record Id
******************************************************************************/
    @AuraEnabled
    public static case getRelatedRecord(Id recId){
        case targetObjectId;
        try {
            if(recId == null){
                return null;
            }
            if(recId.getSObjectType().getDescribe().getName() == OBJECT_PROCESSINSTANCEWORKITEM){
                targetObjectId = getCaseIdfromProcessInstanceWorkitem(recId);
            }else {
                targetObjectId = null;
            }
            return targetObjectId;
        } catch (Exception ex) {
            System.debug('ApprovalRequestPageController getRelatedRecord method ::: '+ ex.getMessage());
            return null;
        }
    }

/****************************************************************************
@Method Name:	getCaseIdfromProcessInstanceWorkitem
@Sprint 	:	20.12  & P2OB-9282
@CreateDate	: 	08/27/2020
@Description: 	To Fetch caseId if the case's work required is Portfolio Management
@References : 	getRelatedRecord
Output		: 	caseId or Null
******************************************************************************/
    private static case getCaseIdfromProcessInstanceWorkitem(Id approvalReqRecordId){
            try {
                Id relatedObjectId;
                Case caseRecord;
                ProcessInstanceWorkitem proInstWorkitem = [Select Id, ProcessInstanceId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where Id = :approvalReqRecordId];
                if(proInstWorkitem <> null){
                    relatedObjectId = proInstWorkitem.ProcessInstance.TargetObjectId;
                }
                if(relatedObjectId <> null && relatedObjectId.getSObjectType().getDescribe().getName() == OBJECT_CASE){
                    caseRecord = [Select Id, AccountId,salesup_Work_Required__c from Case where Id = :relatedObjectId];
                    if(!String.valueOf(caseRecord.salesup_Work_Required__c).equals(Label.WorkRequired_PortfolioManagement)){
                        //if the approval request is not for the Portfolio Management case, then set the return value as null
                        //if it is Portfolio Management case then return the TargetObjectId(CaseId)
                        caseRecord = null;
                    }
                }else {
                    //if the approval request is not for the case, then set the return value as null
                    caseRecord = null;
                }
                return caseRecord;                
            } catch (Exception ex) {
                System.debug('ApprovalRequestPageController getCaseIdfromProcessInstanceWorkitem method ::: '+ ex.getMessage());
                return null;
            }
    }

}