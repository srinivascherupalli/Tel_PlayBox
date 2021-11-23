/********************************************************************************
* Class Name  : CreatedByPartnerUser
* Description : This class is used for PRM Master for Partner Opportunity process builder logic
* Created By  : Gaurav Chopra 
* Change Log  : Created
********************************************************************************/
public class PRMCreatedByPartnerUser {
    
    private static String Partner_Community_User = 'Partner_Community_User';
    private static String Users_not_to_Assign_Chatter_Capability = 'Users_not_to_Assign_Chatter_Capability';
    private static String ACCOUNT_MANAGER = 'Account Manager';
    private static String EDIT = 'Edit';
    
    // This method is to add Permission Sets to the respoective Opportunities
    public static void addPermissionSetToAO(Set<Id> oppIdSet){
        System.enqueueJob(new PRMaddPermissionSetToAOJob(oppIdSet)); 
    }
    
    //Add opportunity team members to the Partener Opportunity
    public static void addOppTeamToPartnerOpp(Set<Id> oppIdSet){
        System.enqueueJob(new AddOppTeamToPartnerOppJob(oppIdSet)); 
    }
    
    /***************************************************************************************
    * Method Name - PRMaddPermissionSetToAOJob
    * Description - This method is used to add Permission Sets to the Account Owners.
    ****************************************************************************************/
    public class PRMaddPermissionSetToAOJob implements Queueable{
        public Id permissionSetId;
        public Id groupId;
        public List<Opportunity> oppRecList;
        public PRMaddPermissionSetToAOJob(Set<Id> oppIdSet){
            this.permissionSetId = [Select Id FROM PermissionSet WHERE Name =: Partner_Community_User].Id; 
            this.groupId = [Select Id FROM Group WHERE DeveloperName =: Users_not_to_Assign_Chatter_Capability].Id;
            this.oppRecList = C2O_OpportunityTriggerHelper.getOppRecInfo(oppIdSet);
        }
        
        public void execute(QueueableContext context) {
            set<Id> oppAccOwnerSet = new set<Id>();
            set<Id> userorGroupIdSet = new set<Id>();
            set<Id> assignPStoUsers = new set<Id>();
            for(Opportunity opp : oppRecList){
                oppAccOwnerSet.add(opp.Account.OwnerId);
            }
            
            for(GroupMember grpMem : [Select Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN: oppAccOwnerSet AND GroupId =:groupId ]){
                userorGroupIdSet.add(grpMem.UserOrGroupId);
            }
            
            for(Opportunity opp: oppRecList){
                if(!userorGroupIdSet.contains(opp.Account.OwnerId)){
                    assignPStoUsers.add(opp.Account.OwnerId); 
                }
            }
            
            if(!assignPStoUsers.isEmpty()){
                for(PermissionSetAssignment psa : [Select Id, AssigneeId, PermissionSetId 
                                                   FROM PermissionSetAssignment 
                                                   WHERE PermissionSetId=:permissionSetId 
                                                   AND AssigneeId IN: assignPStoUsers]){
                                                       if(assignPStoUsers.contains(psa.AssigneeId)){
                                                           assignPStoUsers.remove(psa.AssigneeId);
                                                       }
                                                   }
                
                if(!assignPStoUsers.isEmpty()){
                    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                    for(Id psToUsr : assignPStoUsers){
                        PermissionSetAssignment psa = new PermissionSetAssignment();
                        psa.AssigneeId = psToUsr;
                        psa.PermissionSetId = permissionSetId;
                        psaList.add(psa);
                    }
                    
                    try{
                        insert psaList;
                    }catch(Exception ex){
                        PRMUtilityClass.createException(ex);
                    }
                } 
            }
        }
    }
    
    /***************************************************************************************
    * Method Name - AddOppTeamToPartnerOppJob
    * Description - This method is used to add Opportunity Team members to the Partner Opportunity
    *               based on the associated Account Team members .
    ****************************************************************************************/
    public class AddOppTeamToPartnerOppJob implements Queueable{
        public List<Opportunity> oppRecList;
        
        public AddOppTeamToPartnerOppJob(Set<Id> oppIdSet){
            this.oppRecList = C2O_OpportunityTriggerHelper.getOppRecInfo(oppIdSet);
        }
        
        public void execute(QueueableContext context) {
            set<Id> accIdSet = new set<Id>();
            for(Opportunity opp : oppRecList){
                if(opp.AccountId != null){
                    accIdSet.add(opp.AccountId);    
                }
            }
            
            if(!accIdSet.isEmpty()){
                Map<Id, List<AccountTeamMember>> accIdAndTeamMemberMap = new Map<Id, List<AccountTeamMember>>();
                for(AccountTeamMember atm : [Select Id, AccountId, UserId, TeamMemberRole, OpportunityAccessLevel
                                              FROM AccountTeamMember
                                             WHERE AccountId IN: accIdSet]){
                                                 if(accIdAndTeamMemberMap.containsKey(atm.AccountId)){
                                                     accIdAndTeamMemberMap.get(atm.AccountId).add(atm); 
                                                 }else{
                                                     accIdAndTeamMemberMap.put(atm.AccountId, new List<AccountTeamMember>{atm});
                                                 } 
                                             }
                List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
                for(Opportunity opp: oppRecList){
                    if(accIdAndTeamMemberMap.containsKey(opp.AccountId)){
                        for(AccountTeamMember atm : accIdAndTeamMemberMap.get(opp.AccountId)){
                            OpportunityTeamMember otm = new OpportunityTeamMember();
                            otm.UserId = atm.UserId;
                            otm.TeamMemberRole = atm.TeamMemberRole;
                            otm.OpportunityAccessLevel = atm.OpportunityAccessLevel;
                            otm.OpportunityId = opp.Id;
                            otmList.add(otm);
                        } 
                    }
                    
                    if(opp.Account.Owner.IsActive){
                        OpportunityTeamMember otm = new OpportunityTeamMember();
                        otm.UserId = opp.Account.OwnerId;
                        otm.TeamMemberRole = ACCOUNT_MANAGER;
                        otm.OpportunityAccessLevel = EDIT;
                        otm.OpportunityId = opp.Id;
                        otmList.add(otm); 
                    }
                }
                if(!otmList.isEmpty()){
                    try{
                        insert otmList;
                    }catch(Exception ex){
                        PRMUtilityClass.createException(ex);
                    }
                } 
            }
        }    
    }    
}