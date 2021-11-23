/*****************************************************************************
@Name			: OpportunityTeamTriggerHelper
@Author			: SFO Team : Murali Nunna , Shaik Subani 
@CreateDate		: 09/08/2018
@Description	: This Class has logic for Sending the info to sharepoint when OpportunityTeamMember recoed is create/Edit/Remove via Event Object,based on 
              	  user permissions And To Check Oppo Team Member is in Offshore group for Offshore Accounts and restrict.
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified  : 
*******************************************************************************/

public without sharing class OpportunityTeamTriggerHelper {
	public static boolean isRecRemove=true;
    public static boolean isOffShoreRest=false;
    public void createSPEventOnOppTeamMemCreation(List<OpportunityTeamMember> newOppTeamMem){
        try{
            SharePointUtility spu=new SharePointUtility();
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppNewMember');//spu.checkUserHasCustomPermissionAccess('SharePointOppNewMember',UserInfo.getUserId());
            if(hasCustomPermissionSet==TRUE){
                //list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
                set<ID> oppTMIdSet = new set<ID>();
                if(!newOppTeamMem.isEmpty() && newOppTeamMem.size()>0){
                    for(OpportunityTeamMember oppTM: newOppTeamMem){
                        oppTMIdSet.add(oppTM.Id);
                    }
                }
                if(oppTMIdSet.size()>0){
                    List<OpportunityTeamMember> listOppsTM=[Select Id,Opportunity.Name,Opportunity.CIDN__c,Opportunity.Opportunity_Number__c,Opportunity.Archetype__c,Opportunity.LastModifiedDate,Opportunity.AccountId,Opportunity.Maxim_Sync_Indicator__c,Opportunity.Owner.Email,Opportunity.Account.LastModifiedDate,Opportunity.Owner.FederationIdentifier,Opportunity.Account.Owner.FederationIdentifier,Opportunity.Account.Owner.Email,Opportunity.Account.Name ,User.FederationIdentifier,User.Email,OpportunityAccessLevel,TeamMemberRole,LastModifiedDate,Opportunity.Account.Customer_ID__c From OpportunityTeamMember Where Id in : OppTMIdSet];
                    List<OpportunityTeamMember> listOppsTM1=new List<OpportunityTeamMember> ();
                    if(listOppsTM.size()>0){
                        for(OpportunityTeamMember oppTM : listOppsTM){
                            if(oppTM.Opportunity.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                                listOppsTM1.add(oppTM);
                            }                       
                        } 

                        if(listOppsTM1.size()>0){
                            List<SharePointEvent__c> spelist=new List<SharePointEvent__c>();
                            for(OpportunityTeamMember optm: listOppsTM1){
                                List<OpportunityTeamMember> optmList=new List<OpportunityTeamMember>();
                                optmList.add(optm);
                                SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunityTeamMemberCreation',spu.getNewOpportunityTeamMemPayload(optmList));
                                spelist.add(spe);
                            }
                            if(!spelist.isEmpty() && spelist.size()>0){
                                insert spelist;
                            }
                        }
                    }
                }
                
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemCreation Method'+ Ex.getMessage());
        }
    }
    public void createSPEventOnOppTeamMemUpdate(List<OpportunityTeamMember> newOppTeamMem,Map<Id,OpportunityTeamMember> OldOppTeamMem){
        try{
            SharePointUtility spu=new SharePointUtility();
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppUpdateMember');//spu.checkUserHasCustomPermissionAccess('SharePointOppUpdateMember',UserInfo.getUserId());
            if(hasCustomPermissionSet==TRUE){
                //list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
                set<ID> oppTMIdSet = new set<ID>();
                if(!newOppTeamMem.isEmpty() && newOppTeamMem.size()>0){
                    for(OpportunityTeamMember oppTM: newOppTeamMem){
                        oppTMIdSet.add(oppTM.Id);
                    }
                }
                if(oppTMIdSet.size()>0){
                    List<OpportunityTeamMember> listOppsTM=[Select Id,Opportunity.Name,Opportunity.CIDN__c,Opportunity.Opportunity_Number__c,Opportunity.Archetype__c,Opportunity.LastModifiedDate,Opportunity.AccountId,Opportunity.Maxim_Sync_Indicator__c,Opportunity.Owner.Email,Opportunity.Account.LastModifiedDate,Opportunity.Owner.FederationIdentifier,Opportunity.Account.Owner.FederationIdentifier,Opportunity.Account.Owner.Email,Opportunity.Account.Name ,User.FederationIdentifier,User.Email,OpportunityAccessLevel,TeamMemberRole,LastModifiedDate,Opportunity.Account.Customer_ID__c From OpportunityTeamMember Where Id in : OppTMIdSet];
                    List<OpportunityTeamMember> listOppsTM1=new List<OpportunityTeamMember> ();
                    if(listOppsTM.size()>0){
                        for(OpportunityTeamMember oppTM : listOppsTM){
                            if(oppTM.Opportunity.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                                listOppsTM1.add(oppTM);
                            }
                        } 
                    }

                    if(listOppsTM1.size()>0){
                        List<SharePointEvent__c> spelist=new List<SharePointEvent__c>();
                        for(OpportunityTeamMember optm: listOppsTM1){
                            List<OpportunityTeamMember> optmList=new List<OpportunityTeamMember>();
                            optmList.add(optm);
                            SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunityTeamMemberUpdate',spu.getUpdateOpportunityTeamMemPayload(optmList,OldOppTeamMem));
                            spelist.add(spe);
                        }
                        if(!spelist.isEmpty() && spelist.size()>0){
                            insert spelist;
                        }
                    }                    
                }                
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemUpdate Method'+ Ex.getMessage());
        }
    }
    public void createSPEventOnOppTeamMemRemove(Map<Id,OpportunityTeamMember> OldOppTeamMem){
        try{
            SharePointUtility spu=new SharePointUtility();
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppRemoveMember');//spu.checkUserHasCustomPermissionAccess('SharePointOppRemoveMember',UserInfo.getUserId());
            if(hasCustomPermissionSet==TRUE){
                if(isRecRemove==TRUE){
                    //list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
                    set<ID> oppTMIdSet = new set<ID>();
                    set<ID> oppIdSet = new set<ID>();
                    if(!OldOppTeamMem.isEmpty() && OldOppTeamMem.size()>0){
                        for(OpportunityTeamMember oppTM: OldOppTeamMem.values()){
                            oppTMIdSet.add(oppTM.Id);
                            oppIdSet.add(oppTM.OpportunityId);
                        }
                        if(oppIdSet.size()>0){
                            List<Opportunity> listOpps=[Select Id,Name,CIDN__c,Opportunity_Number__c,Archetype__c,LastModifiedDate,AccountId,Maxim_Sync_Indicator__c,Owner.Email,Account.LastModifiedDate,Account.Owner.FederationIdentifier,Account.Owner.Email,Account.Name,Account.Customer_ID__c,Owner.FederationIdentifier From Opportunity Where Id in : oppIdSet];
                            Map<Id,Opportunity> oppMap=new Map<Id,Opportunity>();
                            for(Opportunity opp: listOpps){
                                oppMap.put(opp.id, opp);
                            }
                            List<OpportunityTeamMember> listOppsTM1=new List<OpportunityTeamMember> ();
                            for(OpportunityTeamMember oppTM : OldOppTeamMem.values()){                
                                if(oppMap.get(oppTM.OpportunityId).Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                                    listOppsTM1.add(oppTM);
                                }
                            }
                            SharepointMainPayload sopl=new SharepointMainPayload();

                            if(listOppsTM1.size()>0){
                                List<SharePointEvent__c> spelist=new List<SharePointEvent__c>();
                                for(OpportunityTeamMember optm: listOppsTM1){
                                    List<OpportunityTeamMember> optmList=new List<OpportunityTeamMember>();
                                    optmList.add(optm);
                                    SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunityTeamMemberRemove',spu.getRemoveOpportunityTeamMemPayload(optmList,oppMap));
                                    spelist.add(spe);
                                }
                                if(!spelist.isEmpty() && spelist.size()>0){
                                    insert spelist;
                                }
                            }
                        }
                    }
                    isRecRemove=FALSE;
                }
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemRemove Method'+ Ex.getMessage());
        }
    }
    
    /*  Sprint 19.03 , EDGE-63675
     * Date : 28/02/2019
     * @Description: This Method is to check whether Oppteam Member User is a part of Enterprise OffShore Public group 
     */
    public void offShoreRestrictedRolAndAccountCheck(List<OpportunityTeamMember> newOppTeamMem){ 
        if(!isOffShoreRest){
            if(newOppTeamMem!=null && newOppTeamMem.size()>0){
                List<OpportunityTeamMember> oppTeamMemList=new List<OpportunityTeamMember>();
                for(OpportunityTeamMember otm: newOppTeamMem){
                    if(otm.addToTeamMemberCheck__c==FALSE){
                        oppTeamMemList.add(otm);
                    }
                }
                if(oppTeamMemList.size()>0){
                    GroupMembership gm=new GroupMembership();
                    gm.accountOffShoreCheckErrorMessage(null,oppTeamMemList);
                }
                isRecRemove=true;
            }
        }
    }   
}