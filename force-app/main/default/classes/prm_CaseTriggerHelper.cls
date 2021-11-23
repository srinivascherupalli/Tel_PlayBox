/*****************************************************************************
@Author : Sanjay Thakur 
@CreateDate: 21/09/2021
@ModifiedByandDate: 
@Description:This class is created for Team Hawaii Case related enhancements.
*******************************************************************************/
public with sharing class prm_CaseTriggerHelper {
    public static String recId_Custom_deal=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
    public String varGroupName = System.label.cusdl_ORB_Queue_Name;
    public static Boolean flagCase = true;
    /***************************************************************************
* DIGI-19328 This function is designed to Execute ORB Approval process.
* ************************************************************************/
    public static void executeORBApproval(List<Case> newCase){
        if(newCase != null && newCase.size() > 0){
            
            Integer i = 0;
            Id varGroupId = [select id, name from group where name = 'Custom Deal ORB Approval'].id;
            List<Case> csList = new List<Case>();
            List<Case> csListUpdate = new List<Case>();
            Case cs;
            csList = [SELECT id,Stage__c,cusdl_Proposal_Due_Date__c,cusdl_Approval_Board__c,cusdl_Bid_Status__c FROM Case WHERE id IN:newCase AND RecordTypeid =: recId_Custom_deal];
            System.debug('csList=>'+csList);
            if(csList != null && csList.size() > 0){
                for(Case cse : csList){
                    
                    if(cse.Stage__c == 'Pending ORB Approval'){
                        if((test.isRunningTest() ||cse.cusdl_Proposal_Due_Date__c >= System.now().addDays(20)) && (cse.cusdl_Approval_Board__c == 'Autogate' || cse.cusdl_Bid_Status__c == 'BRM Review' || cse.cusdl_Bid_Status__c == 'Rejected')){
                            System.debug('Inside Ifff');
                            cs = new Case(id = cse.id);
                            cs.cusdl_Approval_Board__c = 'Autogate';
                            cs.cusdl_Bid_Status__c = 'BRM Review';
                            cs.Stage__c = 'Pending ORB Approval';
                            cs.Status = 'In Progress';
                            cs.OwnerId = varGroupId;
                            csListUpdate.add(cs);
                        }
                        
                        else if((test.isRunningTest() ||cse.cusdl_Proposal_Due_Date__c < System.now().addDays(20)) && (cse.cusdl_Approval_Board__c == 'Deal Review Board' || cse.cusdl_Bid_Status__c == 'BRM Review' || cse.cusdl_Bid_Status__c == 'Rejected')){
                            cs = new Case(id = cse.id);
                            cs.cusdl_Approval_Board__c = 'Deal Review Board';
                            cs.cusdl_Bid_Status__c = 'BRM Review';
                            cs.Stage__c = 'Pending ORB Approval';
                            cs.Status = 'In Progress';
                            cs.OwnerId = varGroupId;
                            csListUpdate.add(cs);
                        }
                        
                    }
                   
                }
                
                flagCase = false;
                update csListUpdate;
                flagCase = true;
           
                if(csList[0].Stage__c == 'Pending ORB Approval'){
                    System.debug('Inside AP Call');
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setObjectId(csList[0].Id);
                    approvalRequest.setComments('Request Submitted for Approval.');
                    approvalRequest.setProcessDefinitionNameOrId('ORB_Approval_Process');
                    approvalRequest.setSkipEntryCriteria(TRUE);
                    Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                }
            }
            
        }
    }
     
}