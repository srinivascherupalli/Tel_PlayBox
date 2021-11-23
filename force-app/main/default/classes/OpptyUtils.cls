/********************************************************************************
* Class Name  : Opportunity Trigger Utils
* Description : Opportunity Trigger Utils- reusable code
* Created By  : 
* Change Log  : Created
********************************************************************************/

public class OpptyUtils {

    /***************************************************************************************
    * Author - Gaurav 
    * Method Name - createOpportunityTeamMember
    * Description - This method is used to create Opportunity Team member records.  
    ****************************************************************************************/
    /*public static void addOpportunityTeamMember(List<Opportunity> oppList){
        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();
        
        for(Opportunity opp : oppList){ 
            OpportunityTeamMember member = new OpportunityTeamMember();  
            member.OpportunityId = opp.Id;  
            member.UserId = opp.CreatedById;  
            member.TeamMemberRole = opptyConstants.SALES_REP; 
            member.OpportunityAccessLevel = opptyConstants.EDIT; 
            oppMemberList.add(member);
        }
        
        try{
            if(oppMemberList.size()>0){
                insert oppMemberList;   
            }
        }catch(Exception ex){
            PRMUtilityClass.createException(ex);
        }
    }*/
    
    /***************************************************************************************
    * Author - Sumit
    * Method Name - createOpportunityTeamMember
    * Description - This method is used to create Opportunity Team member records.  
    ****************************************************************************************/
    @future
    public static void addOpportunityTeamMember(List<String> opptyIds){
        
        //LOCAL VARIABLES
        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();
        List<Opportunity> oppList = New List<Opportunity>();
        
        oppList =  [SELECT Id, Name, CreatedById FROM Opportunity WHERE Id IN :opptyIds For UPDATE];
        
        for(Opportunity opp : oppList){ 
            OpportunityTeamMember member = new OpportunityTeamMember();  
            member.OpportunityId = opp.Id;  
            member.UserId = opp.CreatedById;  
            member.TeamMemberRole = opptyConstants.SALES_REP; 
            member.OpportunityAccessLevel = opptyConstants.EDIT; 
            oppMemberList.add(member);
        }
        
        try{
            if(oppMemberList.size()>0){
                insert oppMemberList;   
            }
        }catch(Exception ex){
            PRMUtilityClass.createException(ex);
        }
    }
    
     /***************************************************************************************
    * Author - Sumit
    * Method Name - createOpportunityTeamMember
    * Description - This method is used to create Opportunity Team member records.  
    ****************************************************************************************/
    //@future
    public static void addOpportunityTeamMember(Map<String,String> opptyId_UserId){
        
        //LOCAL VARIABLES
        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();
        
        for(String opp : opptyId_UserId.keyset()){ 
            OpportunityTeamMember member = new OpportunityTeamMember();  
            member.OpportunityId = opp;  
            member.UserId = opptyId_UserId.get(opp);  
            member.TeamMemberRole = opptyConstants.SALES_REP; 
            member.OpportunityAccessLevel = opptyConstants.EDIT; 
            oppMemberList.add(member);
        }
        
        try{
            if(oppMemberList.size()>0){
                insert oppMemberList;   
            }
        }catch(Exception ex){
            PRMUtilityClass.createException(ex);
        }
    }
    
    /********************************************************************************
    * Author - Gaurav 
    * Method Name - removeOpportunityTeamMember
    * Description - This method is used to remove Opportunity Team member records.
    ********************************************************************************/
    @future    
    public static void removeOpportunityTeamMember(Map<Id, Id> oppPartnerMap){
        List<OpportunityTeamMember> OppTeamMemberToDelete = new List<OpportunityTeamMember>();
        for(OpportunityTeamMember oppTeamMem : [Select Id, Name, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN: oppPartnerMap.keySet()]){
            if(oppTeamMem.UserId == oppPartnerMap.get(oppTeamMem.OpportunityId)){
                OppTeamMemberToDelete.add(oppTeamMem); 
            }
        }
        if(OppTeamMemberToDelete.size() > 0){
            try{
                delete OppTeamMemberToDelete;
            }catch(Exception ex){
                PRMUtilityClass.createException(ex);
            }
        }
    }
    
    
    Public static Account getPartnerAccount(String userId){ 
        
        
        User[] usr = [SELECT id, Accountid FROM User Where Id = :userId ];
        
        if ( !usr.isEmpty() ){
            
            List<Account> accs = New List<Account> ();
            accs = [SELECT id,Partner_Type__c  FROM Account Where id = :usr[0].Accountid ];
        
            if ( accs.isEmpty() ){
                return null ; 
            } else {
                return accs[0]; 
            }
            
        } else {
        
            return null ; 
        }
    }
    
    
    
    Public static Account getAccountType(String accId){ 
        
        if ( accId <> NULL ){
            
            List<Account> accs = New List<Account> ();
            accs = [SELECT id,Partner_Type__c  FROM Account Where id = :accId ];
        
            if ( accs.isEmpty() ){
                return null ; 
            } else {
                return accs[0]; 
            }
            
        } else {
        
            return null ; 
        }
    }
    
    
}