/********************************************************************************
* Class Name  : C2O_OpportunityTeamMemberTriggerHelper
* Description : C2O_OpportunityTeamMemberTriggerHelper runs logic on OpportunityTeamMember records which are filtered
based on certain filter conditions which are defined in handler
* Created By  : Uday Dunna    
* Change Log  : Created
********************************************************************************/
public without sharing class C2O_OpportunityTeamMemberTriggerHelper {
    public static boolean isRecRemove=true;
    public static boolean isOffShoreRest=false;
    
    public static void createSPEventOnOppTeamMemCreation(List<OpportunityTeamMember> listOppsTM1){
        try{
            SharePointUtility spu=new SharePointUtility();  
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
        } catch(Exception Ex){
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemCreation Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        } 
    }
    
    public static void createSPEventOnOppTeamMemUpdate(List<OpportunityTeamMember> listOppsTM1,Map<Id,OpportunityTeamMember> OldOppTeamMem){
        try{
            SharePointUtility spu=new SharePointUtility(); 
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
        } catch(Exception Ex){ 
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemUpdate Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }
    }
    
    /*  Sprint 19.03 , EDGE-63675
* Date : 28/02/2019
* @Description: This Method is to check whether Oppteam Member User is a part of Enterprise OffShore Public group 
*/
    public static void offShoreRestrictedRolAndAccountCheck(List<OpportunityTeamMember> newOppTeamMem){ 
        try{
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
        } catch(Exception Ex){ 
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemUpdate Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }        
    } 
    
    public static void createSPEventOnOppTeamMemRemove(List<OpportunityTeamMember> listOppsTM1,Map<Id,Opportunity> oppMap){
        try{
            SharePointUtility spu=new SharePointUtility(); 
            if(isRecRemove==TRUE){
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
            isRecRemove=FALSE;
        } catch(Exception Ex){
            system.debug('Exception:--->OpprtunityTeamTrigger Handler Class,createSPEventOnOppTeamMemRemove Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage()); 
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        } 
    }
    
    public static void createPostForNewOpportunityTeamMember(List<OpportunityTeamMember> newOppTeamMemRecords){
        try{
            Set<Id> oppIdSet = new Set<Id>();
            Map<Id,String> oppIdVsAccNameMap = new Map<Id,String>();
            for(OpportunityTeamMember otm : newOppTeamMemRecords){
                //Fetch the Opportunity Ids 
                oppIdSet.add(otm.OpportunityId);
            }
            
            for(Opportunity opp : [SELECT Id,Account.Name FROM Opportunity WHERE Id IN :oppIdSet]){
                oppIdVsAccNameMap.put(opp.Id, opp.Account.Name);
            }
            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();  
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();  
            
            
            for(OpportunityTeamMember otm : newOppTeamMemRecords){ 
                //Create Chatter post      
                mentionSegmentInput.id = otm.UserId;
                messageBodyInput.messageSegments.clear();
                messageBodyInput.messageSegments.add(mentionSegmentInput); 
                if(textSegmentInput.text == null){
                    textSegmentInput.text = ' You’ve been added to the Opportunity team for the ' + oppIdVsAccNameMap.get(otm.OpportunityId) + 'account.';
                }                
                messageBodyInput.messageSegments.add(textSegmentInput);                 
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = otm.OpportunityId;                 
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            } 
        }catch(Exception Ex){
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage()); 
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }    
    }
    
    public static void addCaseTeamMemberFromOppTeam(List<OpportunityTeamMember> newOppTeamMemRecords){
        List<Case> caseList = new List<Case>();
        String caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Presales_Solution').RecordTypeId;
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Map<String,String> cseOppMap = new Map<String,String>();
        Map<String,String> oppTeamMemUserIdMap = new Map<String,String>();
        Map<String,String> oppTeamMemUserRoleMap = new Map<String,String>();
        Map<Id,Set<Id>> caseTeamMemberMap = new Map<Id,Set<Id>>();
        List<Case> caseTeamInsertRequiredCaseList = new List<Case>();
        List<CaseTeamMember> cseTeamMemtoInsert = new List<CaseTeamMember>();
        for(OpportunityTeamMember otm : newOppTeamMemRecords){
            oppIdSet.add(otm.OpportunityId);
            userIdSet.add(otm.UserId);
            oppTeamMemUserIdMap.put(otm.OpportunityId,otm.UserId);
            oppTeamMemUserRoleMap.put(otm.OpportunityId,otm.TeamMemberRole);
        }
        
        for(Case cse : [Select Id,OpportunityId__c From Case WHERE OpportunityId__c IN :oppIdSet AND recordTypeId = :caseRecordTypeId]){
            caseList.add(cse);  
            cseOppMap.put(cse.Id,cse.OpportunityId__c);
        }
        
        Map<String,String> cseTeamMemmap = new Map<String,String>();
        List<caseTeamMember> caseTeamMemberList = [Select Id,MemberId,TeamRoleId,ParentId from CaseTeamMember where ParentId IN : caseList AND memberId in : userIdSet];
        if(caseTeamMemberList != null && caseTeamMemberList.size() > 0){    
            for(caseTeamMember caseTeam : caseTeamMemberList){
                cseTeamMemmap.put(caseTeam.ParentId,caseTeam.TeamRoleId);
                //check map already contains key for case
                if(caseTeamMemberMap.containsKey(caseTeam.ParentId)){
                    caseTeamMemberMap.get(caseTeam.ParentId).add(caseTeam.MemberId);
                    //create new key value pair
                }else{
                    caseTeamMemberMap.put(caseTeam.ParentId,new Set<Id>{caseTeam.MemberId});
                }
            }
        }
        
        for(Case cse : caseList){
            //get case id fro case instance
            Id caseId = (Id)cse.get('Id');
            if(caseTeamMemberMap != null && (caseTeamMemberMap.containsKey(caseId) && !caseTeamMemberMap.get(caseId).contains(oppTeamMemUserIdMap.get(cseOppMap.get(caseId)))) || !caseTeamMemberMap.containsKey(caseId)){
                caseTeamInsertRequiredCaseList.add(cse); 
            }            
        }
        
        Map<String,String> caseTeamRoleMap = new Map<String,String>();
        for(CaseTeamRole ctm : [Select Id,Name From CaseTeamRole WHERE Name IN :oppTeamMemUserRoleMap.values()]){
            caseTeamRoleMap.put(ctm.Name,ctm.Id);
        }
        
        for(Case cse : caseTeamInsertRequiredCaseList){
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.MemberId = oppTeamMemUserIdMap.get(cse.OpportunityId__c);
            ctm.TeamRoleId = caseTeamRoleMap.get(oppTeamMemUserRoleMap.get(cse.OpportunityId__c));            
            ctm.ParentId = cse.Id;
            cseTeamMemtoInsert.add(ctm);
        }
        
        if(!cseTeamMemtoInsert.isEmpty()){
            insert cseTeamMemtoInsert;
        }
    }
    
    public static void prmAddPermissionSetToAccountOwner(List<OpportunityTeamMember> newOppTeamMemRecs){
        List<PermissionSet> partnerCommunityUserPSId = [Select Id From PermissionSet WHERE Name = 'Partner_Community_User'];
        Group gp = [Select Id From Group Where DeveloperName = 'Users_not_to_Assign_Chatter_Capability']; 
        Set<Id> userIdSet = new Set<Id>();
        List<GroupMember> grpMemList = new List<GroupMember>(); 
        Map<String,String> AccountOwnerIdMap = new Map<String,String>();
        Map<String,String> DCHOwnerIdMap = new Map<String,String>();
        
        for(OpportunityTeamMember otm : newOppTeamMemRecs){
            AccountOwnerIdMap.put(otm.Id,otm.UserId);
            DCHOwnerIdMap.put(otm.Id,otm.UserId);
            userIdSet.add(otm.UserId);
        }
        
        grpMemList = [Select Id,GroupId,UserOrGroupId 
                      From GroupMember 
                      Where GroupId = :gp.Id AND UserOrGroupId IN :userIdSet]; //Exception User List
        
        List<PermissionSetAssignment> userPermissionList = [Select Id From PermissionSetAssignment
                                                            WHERE AssigneeId IN :userIdSet 
                                                            AND PermissionSetId = :partnerCommunityUserPSId];//User Permission List
        
        List<PermissionSetAssignment> psaToInsert = new List<PermissionSetAssignment>();
        if(userPermissionList.isEmpty()){
            for(OpportunityTeamMember oppTeamMem : newOppTeamMemRecs){
                if(AccountOwnerIdMap.get(oppTeamMem.Id) == DCHOwnerIdMap.get(oppTeamMem.Id)){
                    PermissionSetAssignment pa = new PermissionSetAssignment();
                    pa.AssigneeId = oppTeamMem.UserId;
                    pa.PermissionSetId = partnerCommunityUserPSId[0].Id;
                    psaToInsert.add(pa);
                }                 
            }
        }
        
        if(!psaToInsert.isEmpty()){
            insert psaToInsert;
        }
    }
    
}