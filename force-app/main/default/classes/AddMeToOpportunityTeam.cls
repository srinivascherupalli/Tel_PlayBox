/********************************************************************************************
@Class Name                 :   AddMeToOpportunityTeam
@Description                :   Sprint-19.03,EDGE-63675
@Date                       :   27th Feb, 2019
@Author                     :   Team SFO(Amar Chakka,Shaik Subhani)
@Version                    :   1.0
@Comments                   :   User Role Check and Opportunity Team Member insertion, Invoked from “AddToTeamMember” Flow

@Last Modified By           :   Amar Chakka
@Last Modified Date         :   26-Dec-2019.
@Last Modified Comments     :   Sprint 19.17, P2OB-4310, To Fix Cyclomatic Complexity Issues, Srikanth (Team SFO) P2OB-13741 Sprint 21.09.

*********************************************************************************************/

public without sharing class AddMeToOpportunityTeam {
    
    @InvocableMethod(label = 'Invoke Apex')
    public static list<flowOutputs> invokeFromAddToTeamMember(list<flowInputs> flowinput){
        
        list<flowOutputs> flowotps = new list<flowOutputs>();
        try{
            if(flowinput!=null){
                for(flowInputs str : flowinput){
                    if(str.methodExecution == Label.AddMeToOppTeamFlow_Create){
                        flowotps.add(invokeLocalMethodTeamMemberCreate(str));
                    }
                    if(str.methodExecution == Label.AddMeToOppTeamFlow_UserRoleCheck){
                        flowotps.add(invokeLocalMethodUserRoleCheck(str));
                    }
                    if(str.methodExecution == Label.AddMeToOppTeamFlow_Removal){
                        flowotps.add(invokeLocalMethodTeamMemberDelete(str));
                    }
                }
            }
        }catch(Exception Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeFromAddToTeamMember Method'+ Ex.getMessage());
        }
        return flowotps;
    }
    
    /********************* Method For Opportunity Team Member Insertion  ******************/
    public static flowOutputs invokeLocalMethodTeamMemberCreate(flowInputs req){
        
        flowOutputs flops = new flowOutputs();
        try{
            List<OpportunityTeamMember> oppTeamMem = new List<OpportunityTeamMember>();
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId = req.oppId;
            if(req.oppAccessLevel){ 	//req.oppAccessLevel is HasEditAccess Field From UserRecordAccess 
                otm.OpportunityAccessLevel = Label.OpportunityAccessLevel_Edit;
            }
            Else{
                otm.OpportunityAccessLevel = Label.OpportunityAccessLevel_Read;
            }
            otm.TeamMemberRole = req.teamMemberRole;
            otm.UserId = req.userId;
            otm.addToTeamMemberCheck__c=TRUE;
            oppTeamMem.add(otm);
            Database.SaveResult[] srList = Database.insert(oppTeamMem, false);   
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    flops.oppTeamMemberIsertionstatus = True;
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        flops.oppTeamMemberIsertionstatus = False;
                    }
                }
            }
        }catch(Exception Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeLocalMethodTeamMemberCreate Method'+ Ex.getMessage());
        }
        
        return flops;
    }
    
    /********************* SFO Sprint 19.06 --- EDGE-72924 Method For Opportunity Team Member Deletion ******************/
     
    
    public static flowOutputs invokeLocalMethodTeamMemberDelete(flowInputs req){   // Getting Inputs From Flow through wrapper class defined below. 
        
        flowOutputs flops = new flowOutputs();
        try{
            List<OpportunityTeamMember> oppTeamMem = new List<OpportunityTeamMember>(); 
			if(req.oppTeamMemberID != null && req.oppTeamMemberID != ''){
				OpportunityTeamMember opptm = [select Id from OpportunityTeamMember where Id =:req.oppTeamMemberID ];
				oppTeamMem.add(opptm);
			}else if(req.userId != null && req.userId != '' && req.oppId != null && req.oppId != ''){
				OpportunityTeamMember opptm = [select Id from OpportunityTeamMember where OpportunityId =:req.oppId and userId =:req.userId];
				oppTeamMem.add(opptm);
			} 
                
            /*Deletion of Opportunity Team Member Result Check. Invoking oppTeamMemberDelete method to reduct cylomatic complexity*/
            flops = oppTeamMemberDelete(req,flops,oppTeamMem);
            /************* Deletion Of Account Team Member as well as based user's Choice. Invoking accTeamMemberDelete to reduce cyclomatic complexity.***************/
	        flops = accTeamMemberDelete(req,flops);
        }catch(DMLException Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeLocalMethodTeamMemberDelete Method'+ Ex.getMessage());
        }catch(QueryException Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeLocalMethodTeamMemberDeleteQuery Method'+ Ex.getMessage());
        }catch(NullPointerException Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeLocalMethodTeamMemberDeleteQuery Method'+ Ex.getMessage());
        }
        return flops;
    } 
		/*Deletion of Opportunity Team Member Result Check. Invoked in invokeLocalMethodTeamMemberDelete Method. 
			Sprint 19.17 P2OB-4310 Seperated to reduce cyclomatic complexity
			Input Param: flowInputs req (flow variables wrapper class)
						 flowOutputs flops (variables set to flow using wrapper class)
						 List<OpportunityTeamMember> oppTeamMem (OppTeam member details)
			Output Return: flowOutputs (wrapper class variable)
			*/
    public static flowOutputs oppTeamMemberDelete(flowInputs req, flowOutputs flops, List<OpportunityTeamMember> oppTeamMem){
		if(!oppTeamMem.isEmpty() && oppTeamMem != null){
			Database.DeleteResult[] srList = Database.Delete(oppTeamMem, false);  //Removing the user (who ever clicks on Remove Opportunity Button)from Opportunity Team Member
			for(Database.DeleteResult sr : srList){
				if(sr.isSuccess()){
				flops.OppTeamMemberDeletionStatus = True;
				}
				else{
					for(Database.Error err : sr.getErrors()){
						flops.OppTeamMemberDeletionStatus = False;
					}
				}
			}
		}
		return flops;
	}
				
    /* Deletion Of Account Team Member delete invoked in invokeLocalMethodTeamMemberDelete Method. 
		Sprint 19.17 P2OB-4310 Seperated to reduce cyclomatic complexity **************
		Input Param: flowInputs req (flow variables wrapper class)
					 flowOutputs flops(variables set to flow using wrapper class)
		Output Result:  flowOutputs(wrapper class variable)
	*/
	public static flowOutputs accTeamMemberDelete(flowInputs req,flowOutputs flops){
		if(req.accTeamMemberToDeleteYes == Label.accTeamMemberToDeleteYes && req.accTeamMemberID != null && req.accTeamMemberID != ''){
				List<AccountTeamMember> accTeamMem = new List<AccountTeamMember>();  
					AccountTeamMember acctm = [select Id from AccountTeamMember where Id =:req.accTeamMemberID ];
					accTeamMem.add(acctm);
					if(!accTeamMem.isEmpty() && accTeamMem != null){
						Database.DeleteResult[] accsrList = Database.Delete(accTeamMem, false);  //Removing the user (who ever clicks on Remove Opportunity Button and selects to remove from account team as well)from Account Team Member
                        flops  = accTeamMemberDeleteResultCheck(req,flops,accsrList);
					}
			}
		return flops ;	
	}
    /* Checking Account Team Member  Delete Status ivoked in accTeamMemberDelete Method. 
		Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
		Input Param: flowInputs req (flow variables wrapper class)
					 flowOutputs flops (variables set to flow using wrapper class)
					 Database.DeleteResult[] accsrList ()
		Output Param: flowOutputs (wrapper class variable)
		*/
    public static flowOutputs accTeamMemberDeleteResultCheck(flowInputs req,flowOutputs flops, Database.DeleteResult[] accsrList){
		for(Database.DeleteResult sr : accsrList){
			if(sr.isSuccess()){
				flops.accTeamMemberDeletestatus = True;
			}
			else{
				for(Database.Error err : sr.getErrors()){
					flops.accTeamMemberDeletestatus = False;
				}
			}
		}
		return flops;
    }
	
    /************ Checking User Role ***********************/
    
    public  static flowOutputs invokeLocalMethodUserRoleCheck(flowInputs req){
        flowOutputs flops = new flowOutputs();
        Set<Id> roleids = new set<id>();
        try{
            roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
            if(roleids!=null && roleids.size()>0){
                if(roleids.contains(req.UserRole)||(GroupMembership.groupUserId!=null && GroupMembership.groupUserId.contains(req.userId))){
                    flops.UserRoleCheck = True;
                }
                else{
                    flops.UserRoleCheck = False;
                }
            }
        }catch(Exception Ex){
            system.debug('Exception:::: AddMeToOpportunityTeam :::: invokeLocalMethodUserRoleCheck Method'+ Ex.getMessage());
        }   
        return flops;
    }
    public class flowInputs{
        // oppAccessLevel is HasEditAccess Field From UserRecordAccess 
        @InvocableVariable
        public boolean oppAccessLevel;
        @InvocableVariable
        public string userId;
        @InvocableVariable
        public string oppId;
        @InvocableVariable
        public string teamMemberRole;
        @InvocableVariable
        public boolean oppTeamMemberCreate;
        @InvocableVariable
        public string userRole;
        @InvocableVariable
        public string offshoreRestrictedGrpId;
        @InvocableVariable
        public string offshoreRestrictedGroupName;
        @InvocableVariable
        public string methodExecution;
        @InvocableVariable
        public string accTeamMemberID;
        @InvocableVariable
        public string accTeamMemberToDeleteYes;
        @InvocableVariable
        public string oppTeamMemberID;
        
    }
    public class flowOutputs{
        @InvocableVariable
        public boolean oppTeamMemberIsertionstatus;
        @InvocableVariable
        public boolean UserRoleCheck;
        @InvocableVariable
        public boolean accTeamMemberDeletestatus;
        @InvocableVariable
        public boolean OppTeamMemberDeletionStatus;
    }
    
}