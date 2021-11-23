/*
Created By : Team Hawaii
Jira No : P2OB-11683
Description : Get case team member associated with the case
*/
public class CaseTeamMemberPlugin {
    
    //Method to get all case team members associated with case
    @InvocableMethod
    public static List<FlowOutputParameter> getCaseIdNoCaseTeamMember(List<FlowInputParameter> flowInputs){
        List<FlowOutputParameter> flowOutputList = new List<FlowOutputParameter>();
        Set<Id> userIds = new Set<Id>();
        List<Sobject> sobjectList = new List<Sobject>();
        //check flowinput is not empty
        if(!flowInputs.isEmpty()){
            Set<Id> idSet = new Set<Id>();
            for(FlowInputParameter input : flowInputs){
                sobjectList.addAll(input.sobjectList);
                userIds.add(input.userId);
                
            }
            
            //map of case id ad key and its team members as value
            Map<Id,Set<Id>> caseTeamMemberMap = new Map<Id,Set<Id>>();
            if(!sobjectList.isEmpty()){
                List<caseTeamMember> caseTeamMemberList = [Select Id,MemberId,TeamRoleId,ParentId from CaseTeamMember where ParentId IN : sobjectList AND memberId in : userIds];
                System.debug('::caseTeamMemberList '+caseTeamMemberList);
                if(caseTeamMemberList != null && caseTeamMemberList.size() > 0){    
                    for(caseTeamMember caseTeam : caseTeamMemberList){
                        //check map already contains key for case
                        if(caseTeamMemberMap.containsKey(caseTeam.ParentId)){
                            caseTeamMemberMap.get(caseTeam.ParentId).add(caseTeam.MemberId);
                        //create new key value pair
                        }else{
                            caseTeamMemberMap.put(caseTeam.ParentId,new Set<Id>{caseTeam.MemberId});
                        }
                    }
                }
            }
            System.debug('::caseTeamMemberMap'+caseTeamMemberMap);
            //Iterate on Flow inputs
            for(FlowInputParameter input : flowInputs){
                List<Sobject> inputSobjectList = input.sobjectList;
               //create instance of flow output
                FlowOutputParameter flowOutput  = new FlowOutputParameter();
                flowOutput.caseTeamInsertRequiredCaseList = new List<Sobject>();
                for(Sobject sobj : inputSobjectList){
                    //get case id fro case instance
                    Id caseId = (Id)sobj.get('Id');
                    System.debug('::input.userId'+input.userId);
                    System.debug('::caseId '+caseId);
                    System.debug('::caseTeamMemberMap'+caseTeamMemberMap.containsKey(caseId));
                    if(caseTeamMemberMap != Null && (caseTeamMemberMap.containsKey(caseId) && !caseTeamMemberMap.get(caseId).contains(input.userId)) || !caseTeamMemberMap.containsKey(caseId)){
                        
                        flowOutput.caseTeamInsertRequiredCaseList.add(sobj);
                    }
                }
                
                //create list of flow outputs to return data into flow
                flowOutputList.add(flowOutput);
            }
        }
        return flowOutputList;
    }
    
    //Flow Input Inner Class
    public Class FlowInputParameter{
        @InvocableVariable
        public List<Sobject> sobjectList;
        @InvocableVariable
        public Id userId;
    }
    
    //Flow output Inner Class
    public Class FlowOutputParameter{
        @InvocableVariable
        public List<Sobject> caseTeamInsertRequiredCaseList;
    }
}