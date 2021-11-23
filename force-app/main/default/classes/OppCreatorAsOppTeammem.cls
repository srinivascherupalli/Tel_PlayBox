/********************************************************************************************
@Class Name                 :   OppCreatorAsOppTeammem
@Description                :   Batch Class to change Opportunity Owner and Opp Team Role from delegated Owner to Sales Rep.
@Date                       :   
@Author                     :   
@Version                    :   1.0
@Comments                   :   Batch Class to change Opportunity Owner and Opp Team Role from delegated Owner to Sales Rep.

@Last Modified By           :   Amar Chakka
@Last Modified Date         :   27-Dec-2019.
@Last Modified Comments     :   Sprint 19.17, P2OB-4310, To Fix Cyclomatic Complexity Issues.
@Last Modified      		: 	07/01/2020 21.01 by Sri, Team SFO
					  		  	as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      		: 

*********************************************************************************************/
global with sharing class OppCreatorAsOppTeammem implements Database.Batchable<SObject> {
    public static List<Opportunity> oppsToUpdate = new List<Opportunity>();
    global OppCreatorAsOppTeammem() {
        
    }
    
    /**
* @description gets invoked when the batch job starts
* @param context contains the job ID
* @returns the record set as a QueryLocator object that will be batched for execution
*/ 
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, Name, OwnerId,CreatedById FROM Opportunity WHERE IsClosed = FALSE');
    }
    
    /**
* @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
* @param context contains the job ID
* @param scope contains the batch of records to process.
*/ 
    
    global void execute(Database.BatchableContext context, List<Opportunity> scope) {
        system.debug('-----1>'+scope.size());
        List<User> userList = [SELECT Id ,Name,Email,ProfileId FROM User];
        //EDGE-30781:Replaced profiles hardcoding with Custompermission. Start
        Profile p = [SELECT Id , Name FROM Profile WHERE Name=:Label.Profile_Integration_Datahub];
        // EDGE-30781 : End
        
        /* User Story: P2OB-4310 19.17 Sprint. updateOppTeamRole method invoked to reduce cylomatic Complexity ******************************/
        if(p!= null){
            updateOppInfo(userList, scope, p);
        }
        if(oppsToUpdate.size()>0){
            update oppsToUpdate;
        }
        Set<Id> oppIds=new Set<Id>();
        for(Opportunity opp : scope){
            oppIds.add(opp.Id);
        }
        Map<Id,List<OpportunityTeamMember>> oppTeamMemMap=new  Map<Id,List<OpportunityTeamMember>>();
        if(!oppIds.isEmpty() && oppIds.size() > 0){
            List<OpportunityTeamMember> oppTeamList=[select Id,UserId,OpportunityId,TeamMemberRole from OpportunityTeamMember where OpportunityId IN:oppIds];
            oppTeamMemDetails(oppTeamList,oppTeamMemMap);            
        }
        
        /* User Story: P2OB-4310 19.17 Sprint. updateOppTeamRole method invoked to reduce cylomatic Complexity ******************************/
        List<OpportunityTeamMember> updateoppTeamMemList=new List<OpportunityTeamMember>();
        if(!oppTeamMemMap.isEmpty() && oppTeamMemMap.size() >0){
            updateoppTeamMemList = updateOppTeamRole(oppTeamMemMap, scope);  
            
            if(updateoppTeamMemList.size()>0){
                update updateoppTeamMemList;
            }
        }
    }
    
    /**
* @description gets invoked when the batch job finishes. Place any clean up code in this method.
* @param context contains the job ID
*/ 
    global void finish(Database.BatchableContext context) {
        
    }
    
    
    /* P2OB-4310, Sprint 19.17. This Method is invoked in excute method to reduce cyclomatic complexity
Input Param: List<User> userList (list of users),
List<Opportunity> scope (Opportunities), 
Profile p (Porfile Info) 
Output Param: Invoking updateOppOwner (to check there profile and to update opportunity owner with created by user) */
    
    public  void updateOppInfo(List<User> userList,List<Opportunity> scope, Profile p){
        //List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<Id,User> userMap=new  Map<Id,User>();
        if(userList.size()>0 && userList!=null){
            for(User u : userList){
                if(u.Id!=null && u!=null){
                    userMap.put(u.Id, u);
                }
            }
        }
        for(Opportunity o : scope){ 
            User uDetails=userMap.get(o.CreatedById);
            if(uDetails.ProfileId!=p.Id){
                /* User Story: P2OB-4310 19.17 Sprint. updateOppOwner method invoked to reduce cylomatic Complexity ******************************/
                updateOppOwner(o);
                
            }
        }	
    }
    
    /* P2OB-4310, Sprint 19.17. This Method is invoked in excute method to reduce cyclomatic complexity
Input Param: Map<Id,List<OpportunityTeamMember>> oppTeamMemMap (opportunity Teammember list)
list<opportunity> scope (Opportunity details)
Output Result: list of opportunity team member whose role should get updated*/
    
    public list<OpportunityTeamMember> updateOppTeamRole(Map<Id,List<OpportunityTeamMember>> oppTeamMemMap, list<opportunity> scope){
        List<OpportunityTeamMember> updateoppTeamMemList=new List<OpportunityTeamMember>();
        for(Opportunity o : scope){ 
            List<OpportunityTeamMember> oppTeamMemList=new  List<OpportunityTeamMember>();
            List<OpportunityTeamMember> oppTeamMemList1=new  List<OpportunityTeamMember>();
            oppTeamMemList=oppTeamMemMap.get(o.id);
            if(oppTeamMemList!=null && oppTeamMemList.size()>0){
                for(OpportunityTeamMember oTem: oppTeamMemList){
                    if(oTem!=null){
                        if(oTem.TeamMemberRole=='Delegated Owner'){
                            oTem.TeamMemberRole='Sales Rep';
                            oppTeamMemList1.add(oTem);
                        }
                    }
                }
                updateoppTeamMemList.addAll(oppTeamMemList1);
            }
        }
        return updateoppTeamMemList;
    }
    /* P2OB-4310, Sprint 19.17. This Method is invoked in excute ->updateOppInfo method to reduce cyclomatic complexity
InputParam: opportunity o(Opportunity to change the owner id) 
Output Result: oppsToUpdate, list of opportunity which has to get updated.*/	
    
    public void updateOppOwner(opportunity o){
        if(o.OwnerId!=o.CreatedById){
            o.OwnerId=o.CreatedById;
            oppsToUpdate.add(o);
        }
    }
    
    public void oppTeamMemDetails(List<OpportunityTeamMember> oppTeamList, Map<Id,List<OpportunityTeamMember>> oppTeamMemMap){
        List<OpportunityTeamMember> listOppTems = new list<OpportunityTeamMember>();
        if(oppTeamList.size()>0){
            for(OpportunityTeamMember otm : oppTeamList){
                if(otm!=null){
                    listOppTems=oppTeamMemMap.get(otm.OpportunityId);
                    if(null==listOppTems){
                        listOppTems=new List<OpportunityTeamMember>();
                        if(otm.OpportunityId!=null){
                            oppTeamMemMap.put(otm.OpportunityId, listOppTems);
                        }
                    }
                    listOppTems.add(otm);
                }
            }
        }
    }
}