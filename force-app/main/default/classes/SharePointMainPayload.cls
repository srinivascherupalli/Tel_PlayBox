/*****************************************************************************
@Name: SharePointMainPayload
@Author: Murali Nunna
@CreateDate: 09/08/2018
@Description: This Class has (Account,Opportunity,OpportunityTeamMember) specific required payload structure and wrapper classes 
			  are SharepointPayLoad,SharepointAccountPayLoad,SharepointOpportunityPayLoad,SharepointOpportunityTeamMemberPayLoad,
			  SharepointOpportunityTeamMemberPayLoadList
*******************************************************************************/
public without sharing class SharePointMainPayload {
    public static boolean isRecOppTeamRemove=TRUE;
    public Class SharepointPayLoad{        
        public SharepointAccountPayLoad AccountInfo{get;set;}         
    }    
    public SharepointPayLoad getAccountPayload(Account acc){
        SharepointAccountPayLoad sapl=new SharepointAccountPayLoad();
        SharepointPayLoad sap=new SharepointPayLoad();
        sapl.CustomerID=acc.Id;
        sapl.CustomerName=acc.Name;
        sapl.CustomerOwnerEmail=acc.Owner.Email;
        sapl.CustomerOwnerID=acc.Owner.FederationIdentifier;
        sapl.CIDN=acc.CIDN__c;
        sapl.CAC=acc.Customer_ID__c;
        sapl.CustomerUpdatedDateTime=acc.LastModifiedDate; 
        sap.AccountInfo=sapl;
        return sap;
    }
    
    public SharepointPayLoad getOpportunityPayload(Opportunity opp){
        SharepointAccountPayLoad sapl=new SharepointAccountPayLoad();
        SharepointPayLoad sap=new SharepointPayLoad();
        SharepointOpportunityPayLoad sptop=new SharepointOpportunityPayLoad();
        sapl.CustomerID=opp.AccountId;
        sapl.CustomerName=opp.Account.Name;
        sapl.CustomerOwnerEmail=opp.Account.Owner.Email;
        sapl.CustomerOwnerID=opp.Account.Owner.FederationIdentifier;
        sapl.CIDN=opp.CIDN__c;
        sapl.CAC=opp.Account.Customer_ID__c;
        sapl.CustomerUpdatedDateTime=opp.Account.LastModifiedDate;             
        sapl.OpportunityInfo=sptop.getOpportunityPayload(opp);
        sap.AccountInfo=sapl;
        return sap;
    }
    public SharepointPayLoad getOpportunityTeamMemberPayloadCreate(List<OpportunityTeamMember> oppTeamMemList,Map<Id,OpportunityTeamMember> OldOppTeamMem){
        
        SharepointPayLoad sap=new SharepointPayLoad();
        for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
            SharepointAccountPayLoad sapl=new SharepointAccountPayLoad();
            sapl.CustomerID=oppTeamMem.Opportunity.AccountId;
            sapl.CustomerName=oppTeamMem.Opportunity.Account.Name;
            sapl.CustomerOwnerEmail=oppTeamMem.Opportunity.Account.Owner.Email;
            sapl.CustomerOwnerID=oppTeamMem.Opportunity.Account.Owner.FederationIdentifier;
            sapl.CustomerUpdatedDateTime=oppTeamMem.Opportunity.Account.LastModifiedDate;
            sapl.CIDN=oppTeamMem.Opportunity.CIDN__c;
            sapl.CAC=oppTeamMem.Opportunity.Account.Customer_ID__c;
            SharepointOpportunityPayLoad spopppl=new SharepointOpportunityPayLoad();
            sapl.OpportunityInfo=spopppl.getOpportunityPayload(oppTeamMem);
            SharepointOpportunityTeamMemberPayLoadList sotp=new SharepointOpportunityTeamMemberPayLoadList();
            sapl.OpportunityInfo.OpportunityMembers=sotp.getOpportunityTeamMemberPayloadCreate(oppTeamMemList,OldOppTeamMem);
            sap.AccountInfo=sapl;
            /* sapl.CustomerUpdatedDateTime=oppTeamMem.Opportunity.Account.LastModifiedDate;
            sotmpl.OpportunityInfo=new SharepointOpportunityP().getOpportunityPayload(opp);;
            sotmpl.OppMemberRecordID =oppTeamMem.Id;
            sotmpl.OpportunityMemberEmail =oppTeamMem.User.Email;
            sotmpl.OpportunityMemberID=oppTeamMem.User.FederationIdentifier;
            sotmpl.OpportunityMemberCurrentAccessLevel =oppTeamMem.OpportunityAccessLevel;
            sotmpl.OpportunityMemberUpdatedDateTime =oppTeamMem.LastModifiedDate;
			*/
        }
        return sap;
    }
    public SharepointPayLoad getOpportunityTeamMemberPayloadUpdate(List<OpportunityTeamMember> oppTeamMemList,Map<Id,OpportunityTeamMember> OldOppTeamMem){
        SharepointPayLoad sap=new SharepointPayLoad();
        List<SharepointOpportunityTeamMemberPayLoad> shoppTeamMemList=new List<SharepointOpportunityTeamMemberPayLoad>();
        for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
            SharepointAccountPayLoad sapl=new SharepointAccountPayLoad(); 
            sapl.CustomerID=oppTeamMem.Opportunity.AccountId;
            sapl.CustomerName=oppTeamMem.Opportunity.Account.Name;
            sapl.CustomerOwnerEmail=oppTeamMem.Opportunity.Account.Owner.Email;
            sapl.CustomerOwnerID=oppTeamMem.Opportunity.Account.Owner.FederationIdentifier;
            sapl.CustomerUpdatedDateTime=oppTeamMem.Opportunity.Account.LastModifiedDate;
            sapl.CIDN=oppTeamMem.Opportunity.CIDN__c;
            sapl.CAC=oppTeamMem.Opportunity.Account.Customer_ID__c;
            SharepointOpportunityPayLoad spopppl=new SharepointOpportunityPayLoad();
            sapl.OpportunityInfo=spopppl.getOpportunityPayload(oppTeamMem);
            SharepointOpportunityTeamMemberPayLoadList sotp=new SharepointOpportunityTeamMemberPayLoadList();
            sapl.OpportunityInfo.OpportunityMembers=sotp.getOpportunityTeamMemberPayloadCreate(oppTeamMemList,OldOppTeamMem);
            sap.AccountInfo=sapl;            
        }
        return sap;
    }
    
    public SharepointPayLoad getOpportunityTeamMemberPayloadRemove(List<OpportunityTeamMember> oppTeamMemList,Map<Id,Opportunity> oppMap){
        SharepointPayLoad sap=new SharepointPayLoad();
        set<ID> userIdSet = new set<ID>();
        for(OpportunityTeamMember oppTM : oppTeamMemList){                
            userIdSet.add(oppTM.UserId);
        }
        //List<User> usrList=[Select id,Name,FederationIdentifier,Email from User where Id IN:userIdSet];
        Map<Id,User> userMap=new Map<Id,User>();
        if(isRecOppTeamRemove==TRUE){
        	userMap=getUserFedarationInfo(userIdSet);
            isRecOppTeamRemove=FALSE;
        }
       /* for(User u : usrList){
            userMap.put(u.Id,u);
        }*/
        List<SharepointOpportunityTeamMemberPayLoad> shoppTeamMemList=new List<SharepointOpportunityTeamMemberPayLoad>();
        for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
            SharepointAccountPayLoad sapl=new SharepointAccountPayLoad(); 
            sapl.CustomerID=oppMap.get(oppTeamMem.OpportunityId).AccountId;
            sapl.CustomerName=oppMap.get(oppTeamMem.OpportunityId).Account.Name;
            sapl.CustomerOwnerEmail=oppMap.get(oppTeamMem.OpportunityId).Account.Owner.Email;
            sapl.CustomerOwnerID=oppMap.get(oppTeamMem.OpportunityId).Account.Owner.FederationIdentifier;
            sapl.CustomerUpdatedDateTime=oppMap.get(oppTeamMem.OpportunityId).Account.LastModifiedDate;
            sapl.CIDN=oppMap.get(oppTeamMem.OpportunityId).CIDN__c;
            sapl.CAC=oppMap.get(oppTeamMem.OpportunityId).Account.Customer_ID__c;
            SharepointOpportunityPayLoad spopppl=new SharepointOpportunityPayLoad();
            sapl.OpportunityInfo=spopppl.getOpportunityPayload(oppMap.get(oppTeamMem.OpportunityId));
            SharepointOpportunityTeamMemberPayLoadList sotp=new SharepointOpportunityTeamMemberPayLoadList();
            sapl.OpportunityInfo.OpportunityMembers=sotp.getOpportunityTeamMemberRemoved(oppTeamMemList,oppMap,usermap);
            sap.AccountInfo=sapl;            
        }
        return sap;
    }
    public Class SharepointAccountPayLoad{        
        public String CustomerID{get;set;}
        private String CustomerName{get;set;}
        private String CustomerOwnerEmail{get;set;}
        private String CustomerOwnerID{get;set;}
        private String CIDN{get;set;}
        private String CAC {get;set;}
        private DateTime CustomerUpdatedDateTime{get;set;}
        // **************************************** Added By Amar ******************************//
        public List<SharepointAccountAccessRequestPayload> AccountMembers{get;set;}
        public SharepointOpportunityPayLoad OpportunityInfo {get;set;} 
        
        /* public SharepointAccountPayLoad getAccountPayLoad(Account acc){
            SharepointAccountPayLoad spap=new SharepointAccountPayLoad();            
            spap.CustomerID=acc.Id;
            spap.CustomerName=acc.Name;
            spap.CustomerOwnerEmail=acc.Owner.Email;
            spap.CustomerOwnerID=acc.OwnerID;
            spap.CIDN=acc.CIDN__c;
            spap.CustomerUpdatedDateTime=acc.LastModifiedDate; 
            return spap;
        }
		*/
        
        
    } 
    
    public Class SharepointOpportunityPayLoad{
        public String OpportunityID {get;set;}
        private String OpportunityOwnerEmail {get;set;}
        private String OpportunityOwnerID {get;set;}
        private String OpportunityName {get;set;}
        private String OpportunityNum {get;set;}
        private String OpportunityArchetype {get;set;}
        private DateTime OpportunityUpdatedDateTime {get;set;}
        /*****************************  Added By Amar ******************************/
        //public list<SharepointOppAccessRequestPayload> OpportunityMember{get;set;}
        private List<SharepointOpportunityTeamMemberPayLoadList> OpportunityMembers {get;set;}
        
        public SharepointOpportunityPayLoad getOpportunityPayload(Opportunity opp){
            SharepointOpportunityPayLoad sopl=new SharepointOpportunityPayLoad();
            sopl.OpportunityID=opp.Id;
            sopl.OpportunityOwnerEmail=opp.Owner.Email;
            sopl.OpportunityOwnerID=opp.Owner.FederationIdentifier;
            sopl.OpportunityName=opp.Name;
            sopl.OpportunityNum=opp.Opportunity_Number__c;
            sopl.OpportunityArchetype=opp.Archetype__c.substringBefore('-');
            sopl.OpportunityUpdatedDateTime=opp.LastModifiedDate;            
            return sopl;
        }
        
        public SharepointOpportunityPayLoad getOpportunityPayload(OpportunityTeamMember oppTeamMem){
            SharepointOpportunityPayLoad sopl=new SharepointOpportunityPayLoad();
            sopl.OpportunityID=oppTeamMem.Opportunity.Id;
            sopl.OpportunityOwnerEmail=oppTeamMem.Opportunity.Owner.Email;
            sopl.OpportunityOwnerID=oppTeamMem.Opportunity.Owner.FederationIdentifier;
            sopl.OpportunityName=oppTeamMem.Opportunity.Name;
            sopl.OpportunityNum=oppTeamMem.Opportunity.Opportunity_Number__c;
            sopl.OpportunityArchetype=oppTeamMem.Opportunity.Archetype__c.substringBefore('-');
            sopl.OpportunityUpdatedDateTime=oppTeamMem.Opportunity.LastModifiedDate;            
            return sopl;
        }
    }
    
    public Class SharepointOpportunityTeamMemberPayLoadList{
        
        private SharepointOpportunityTeamMemberPayLoad OpportunityMemberInfo {get;set;}
        
        public List<SharepointOpportunityTeamMemberPayLoadList> getOpportunityTeamMemberPayloadCreate(List<OpportunityTeamMember> oppTeamMemList,Map<Id,OpportunityTeamMember> OldOppTeamMem){
            List<SharepointOpportunityTeamMemberPayLoadList> shoppTeamMemList=new List<SharepointOpportunityTeamMemberPayLoadList>();
            for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
                SharepointOpportunityTeamMemberPayLoadList sotmpl=new SharepointOpportunityTeamMemberPayLoadList(); 
                SharepointOpportunityTeamMemberPayLoad OMemberInfo=new SharepointOpportunityTeamMemberPayLoad();
                OMemberInfo.OppMemberRecordID =oppTeamMem.Id;
                OMemberInfo.OpportunityMemberEmail =oppTeamMem.User.Email;
               	OMemberInfo.OpportunityMemberID=oppTeamMem.User.FederationIdentifier;                
                if(OldOppTeamMem!=null){
                OMemberInfo.OpportunityMemberOldAccessLevel =OldOppTeamMem.get(oppTeamMem.id).OpportunityAccessLevel;
                }
                OMemberInfo.OpportunityMemberRole=oppTeamMem.TeamMemberRole;
                OMemberInfo.OpportunityMemberCurrentAccessLevel =oppTeamMem.OpportunityAccessLevel;
                OMemberInfo.OpportunityMemberUpdatedDateTime =oppTeamMem.LastModifiedDate;
                sotmpl.OpportunityMemberInfo=OMemberInfo;
                shoppTeamMemList.add(sotmpl);
            }
            return shoppTeamMemList;
        }
        
        public List<SharepointOpportunityTeamMemberPayLoadList> getOpportunityTeamMemberRemoved(List<OpportunityTeamMember> oppTeamMemList,Map<Id,Opportunity> oppMap,Map<Id,User> usermap){
            List<SharepointOpportunityTeamMemberPayLoadList> shoppTeamMemList=new List<SharepointOpportunityTeamMemberPayLoadList>();
            for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
                system.debug('*****************'+oppTeamMem.Id);
                if(oppTeamMem.OpportunityId==oppMap.get(oppTeamMem.OpportunityId).id){
                SharepointOpportunityTeamMemberPayLoadList sotmpl=new SharepointOpportunityTeamMemberPayLoadList(); 
                SharepointOpportunityTeamMemberPayLoad OMemberInfo=new SharepointOpportunityTeamMemberPayLoad();
                OMemberInfo.OppMemberRecordID =oppTeamMem.Id;
                OMemberInfo.OpportunityMemberEmail =usermap.get(oppTeamMem.UserId).Email;//oppTeamMem.User.Email;
               	OMemberInfo.OpportunityMemberID=usermap.get(oppTeamMem.UserId).FederationIdentifier;//oppTeamMem.User.FederationIdentifier;                
                //if(OldOppTeamMem!=null){
                //OMemberInfo.OpportunityMemberOldAccessLevel =OldOppTeamMem.get(oppTeamMem.id).OpportunityAccessLevel;
                //}
                OMemberInfo.OpportunityMemberRole=oppTeamMem.TeamMemberRole;
                OMemberInfo.OpportunityMemberCurrentAccessLevel =oppTeamMem.OpportunityAccessLevel;
                OMemberInfo.OpportunityMemberUpdatedDateTime =DateTime.now();//oppTeamMem.LastModifiedDate;
                sotmpl.OpportunityMemberInfo=OMemberInfo;
                shoppTeamMemList.add(sotmpl);
                }
            }
            return shoppTeamMemList;
        }
        
    }
    
    public Class SharepointOpportunityTeamMemberPayLoad{
        private String OppMemberRecordID {get;set;}
        private String OpportunityMemberEmail {get;set;}
        private String OpportunityMemberID {get;set;}
        private String OpportunityMemberRole {get;set;}
        private String OpportunityMemberCurrentAccessLevel {get;set;}
        private String OpportunityMemberOldAccessLevel {get;set;}
        private DateTime OpportunityMemberUpdatedDateTime {get;set;}
        
        public list<SharepointOpportunityTeamMemberPayLoadList> getOppRequestAccessPayload(User usr){
	        list<SharepointOpportunityTeamMemberPayLoadList> listOppMembers = new list<SharepointOpportunityTeamMemberPayLoadList>();
	        SharepointOpportunityTeamMemberPayLoadList apopptememList=new SharepointOpportunityTeamMemberPayLoadList();
            SharepointOpportunityTeamMemberPayLoad sprpl = new SharepointOpportunityTeamMemberPayLoad();
	        sprpl.OpportunityMemberEmail = usr.email;
	        sprpl.OpportunityMemberID = usr.FederationIdentifier;
	        sprpl.OpportunityMemberCurrentAccessLevel = 'Edit';
	        //listOppMembers.add(sprpl);
            apopptememList.OpportunityMemberInfo=sprpl;
            listOppMembers.add(apopptememList);
	        return listOppMembers;
	            
	    }
      /*  public List<SharepointOpportunityTeamMemberPayLoad> getOpportunityTeamMemberPayloadCreate(List<OpportunityTeamMember> oppTeamMemList,Map<Id,OpportunityTeamMember> OldOppTeamMem){
            List<SharepointOpportunityTeamMemberPayLoad> shoppTeamMemList=new List<SharepointOpportunityTeamMemberPayLoad>();
            for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
                SharepointOpportunityTeamMemberPayLoad sotmpl=new SharepointOpportunityTeamMemberPayLoad(); 
                sotmpl.OppMemberRecordID =oppTeamMem.Id;
                sotmpl.OpportunityMemberEmail =oppTeamMem.User.Email;
                sotmpl.OpportunityMemberID=oppTeamMem.User.FederationIdentifier;
                sotmpl.OpportunityMemberOldAccessLevel =OldOppTeamMem.get(oppTeamMem.id).OpportunityAccessLevel;
                sotmpl.OpportunityMemberCurrentAccessLevel =oppTeamMem.OpportunityAccessLevel;
                sotmpl.OpportunityMemberUpdatedDateTime =oppTeamMem.LastModifiedDate;
                shoppTeamMemList.add(sotmpl);
            }
            return shoppTeamMemList;
        }

*/
        /* public List<SharepointOpportunityTeamMemberP> getOpportunityTeamMemberPayloadUpdate(List<OpportunityTeamMember> oppTeamMemList,Map<Id,OpportunityTeamMember> OldOppTeamMem){
        List<SharepointOpportunityTeamMemberP> shoppTeamMemList=new List<SharepointOpportunityTeamMemberP>();
        for(OpportunityTeamMember oppTeamMem : oppTeamMemList){
        SharepointOpportunityTeamMemberP sotmpl=new SharepointOpportunityTeamMemberP(); 
        sotmpl.OppMemberRecordID =oppTeamMem.Id;
        sotmpl.OpportunityMemberEmail =oppTeamMem.User.Email;
        sotmpl.OpportunityMemberID=oppTeamMem.User.FederationIdentifier;
        sotmpl.OpportunityMemberOldAccessLevel =OldOppTeamMem.get(oppTeamMem.Id).OpportunityAccessLevel;
        sotmpl.OpportunityMemberCurrentAccessLevel =oppTeamMem.OpportunityAccessLevel;
        sotmpl.OpportunityMemberUpdatedDateTime =oppTeamMem.LastModifiedDate;
        shoppTeamMemList.add(sotmpl);
        }
        return shoppTeamMemList;
        }
        */
    }
    
    	/************* Added by Amar *********************/
	
	
	public SharepointPayLoad getAccRequestAccessPayload(Account accUser,User userInfo){
	          
        SharepointAccountAccessRequestPayload saarp = new SharepointAccountAccessRequestPayload();
        SharepointPayLoad sap=getAccountPayload(accUser);
        sap.AccountInfo.AccountMembers=saarp.getAccRequestAccessPayload(userInfo);
        return sap;
        
	}
	public Class SharepointAccountAccessRequestPayload{
		private String AccountRecordID{get;set;}
		private String AccountMemberEmail{get;set;}
		private String AccountMemberID{get;set;}
		private String AccountMemberRole{get;set;}
		private String AccountMemberCurrentAccessLevel{get;set;}
		private String AccountMemberOldAccessLevel{get;set;}
		private String AccountMemberUpdatedDateTime{get;set;}
		
		public List<SharepointAccountAccessRequestPayload> getAccRequestAccessPayload(User ur){
            List<SharepointAccountAccessRequestPayload> listaccMemers=new List<SharepointAccountAccessRequestPayload>();
		    SharepointAccountAccessRequestPayload sarpl = new SharepointAccountAccessRequestPayload();
		    sarpl.AccountMemberEmail = ur.email;
		    sarpl.AccountMemberID = ur.FederationIdentifier;
		    sarpl.AccountMemberCurrentAccessLevel = 'Edit';
            listaccMemers.add(sarpl);
		    return listaccMemers;  
		}
	}
	
	public SharepointPayLoad getOppRequestAccessPayload(Opportunity oppUser, user userInfo){
	    SharepointOpportunityTeamMemberPayLoad sparp = new SharepointOpportunityTeamMemberPayLoad();
	    SharepointAccountPayLoad sapl=new SharepointAccountPayLoad();
        SharepointPayLoad sap = getOpportunityPayload(oppUser);
        sap.AccountInfo.OpportunityInfo.OpportunityMembers = sparp.getOppRequestAccessPayload(userInfo);
	    return sap;
	}
    
    public Map<Id,User> getUserFedarationInfo(set<ID> userIdSet){
        List<User> usrList=[Select id,Name,FederationIdentifier,Email from User where Id IN:userIdSet];
        Map<Id,User> userMap=new Map<Id,User>();
        for(User u : usrList){
            userMap.put(u.Id,u);
        }
        return userMap;
    }

}