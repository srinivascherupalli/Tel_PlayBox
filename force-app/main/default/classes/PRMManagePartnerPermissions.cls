public  without sharing class PRMManagePartnerPermissions { 
/*****************************************************************
    @Name: PRMManagePartnerPermissions
    @Description: This is for filtering partner user who can be assigned with PRM Community user permission set
******************************************************************/ 
    
    @InvocableVariable
	public list<string> param;
    
    @InvocableMethod
    public static list<flowOutputs> getpartneruserList(List<String> param){
	flowOutputs lflowotp = new flowOutputs();
    list<flowOutputs> lflowotps = new list<flowOutputs>();
	List<String> exclusionList= new List<String>();
		try{
           	set<string> Exclusionids= new set<string>();
            set<string> opTeam= new set<string>();           

            for(Opportunityteammember opmember:[Select id,UserId,OpportunityId from Opportunityteammember where OpportunityId in :param]){
           		opTeam.add(opmember.UserId);
            }
            
            for(PermissionSetAssignment passign:[Select id,AssigneeId,PermissionSet.Name from PermissionSetAssignment Where PermissionSet.Name=:PRMConstants.PARTNER_COMMUNITY_USER_PERMISSION_NAME and AssigneeId in :opTeam]){
                Exclusionids.add(passign.AssigneeId);
            }
            
           for(GroupMember gm:[Select id,Group.DeveloperName,UserOrGroupId,GroupId from GroupMember Where Group.DeveloperName=:PRMConstants.PUBLIC_GROUP_NO_CHATTER_CAPABILITY and UserOrGroupId in :opTeam]){
                Exclusionids.add(gm.UserOrGroupId);
            }
            //Exclude userds from Opportunity Team who alredy have PRM Community User permission Assigned and part of No Chatter Capability group
            if(Exclusionids.size()>0){
                opTeam.removeAll(Exclusionids);
              }
            
            lflowotp.opteamids=  new List<String>(opTeam);
            lflowotps.add(lflowotp);
	      	 return lflowotps;
           }
		   catch(Exception e){     
        		system.debug('exception'+e.getMessage()+ e.getStackTraceString());
               return null;
          }
    }

	/***************** Wrapper Class To Set Flow Variables ******************/
	public class flowOutputs{
		@InvocableVariable
		public list<string> opteamids;		
	}

}