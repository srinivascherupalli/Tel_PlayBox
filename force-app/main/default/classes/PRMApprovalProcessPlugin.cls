/**
* Description : Apex Action to be invoked from flows. This apex class will recall the approval process.                   
* Jira        : P2OB - 7948
* Author      : Team Hawaii 
* Date        : 27-August-2020 
**/

public without sharing class PRMApprovalProcessPlugin {
    
    /* Invoke recall approval process*/
    @InvocableMethod
    public static List<FlowOutputParameter> recallApprovalProcess(List<FlowInputParameter> flowInputs){
        List<FlowOutputParameter> flowOutputs = new List<FlowOutputParameter>();
        Logger2 logger = Logger2.getLogger('PRMApprovalProcessPlugin');                  
        
        try{
             List<Approval.ProcessWorkitemRequest> lstProcessItems = new List<Approval.ProcessWorkitemRequest>();
             if(!flowInputs.isEmpty()){
                 // checking pending Approval process
                 for(ProcessInstanceWorkitem processItems : [ SELECT Id, ActorId, ProcessInstance.id,
                                              ProcessInstance.TargetObjectId,
                                              ProcessInstance.SubmittedById
                                              FROM ProcessInstanceWorkitem
                                              WHERE ProcessInstance.TargetObjectId IN : flowInputs[0].sobjectIds
                                              AND ProcessInstance.Status = 'Pending' AND ProcessInstance.ProcessDefinition.DeveloperName = :flowInputs[0].approvalProcessName]){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(System.Label.PRM_Closure_Recall_Comment);
                    req2.setAction(PRMConstants.PRM_Recall_Action); 
                    req2.setWorkitemId(processItems.Id);
                    // adding to list of approval items to process
                    lstProcessItems.add(req2); 
                 }
                 // Set Success Output Flow Parameters
                 FlowOutputParameter flowOutput  = new FlowOutputParameter(); 
                 // process all approval items together
                 if(!lstProcessItems.isEmpty()){
                     Approval.process(lstProcessItems, false); 
                     flowOutput.isResultSuccess = true;
                 }
                  flowOutputs.add(flowOutput);
             }
             
             
        }
        catch(Exception e){
            FlowOutputParameter flowOutput  = new FlowOutputParameter(); 
            flowOutput.errorMessage = e.getMessage();
            flowOutput.isResultSuccess = false;
            flowOutputs.add(flowOutput);
        }
        finally{
            logger.exitLogger();            
        }        
        return flowOutputs;
    }
    
    /**    
* Description : Wrapper class to hold input parameters received from flow 
* Jira : P2OB - 7948
*/
    public Class FlowInputParameter{
        @InvocableVariable
        public List<String> sobjectIds;
        @InvocableVariable
        public String approvalProcessName;
    }
    
    /**    
* Description : Wrapper class to hold output parameters sent to flow 
* Jira : P2OB - 7948
*/
    public Class FlowOutputParameter{
        @InvocableVariable
        public String errorMessage = '';
        @InvocableVariable
        public Boolean isResultSuccess ; 
    }
}