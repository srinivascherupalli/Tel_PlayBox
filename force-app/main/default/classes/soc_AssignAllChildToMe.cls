public without sharing class soc_AssignAllChildToMe {

    //This method gets called from doint of assignToParentOwner component 
    @AuraEnabled
    public static Map<String,Object> initialize(String caseId){       
        Map<String,Object> results=new Map<String,Object>();
        String showAssignAllToMe = '';
        List<Case> caseList= [SELECT id,subject,Stage__c,
                              Status,OwnerId,requestor__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,soc_SFD_Offshore_Restricted__c,
                              (Select Id,ParentId,OwnerId From Cases)
                              FROM case where id =:caseId limit 1];
		String name=[select Name from profile where id = :userinfo.getProfileId()].Name;
        for(Case parentCase : caseList){
            for(Case childCase : parentCase.Cases){
                if(childCase.OwnerId == parentCase.OwnerId)
                	showAssignAllToMe = 'true';
                else
                    showAssignAllToMe = 'false';
            }   
        }
        String DSCUser = 'false';
        
        Set<String> setDSCQueues = new Set<String>{'soc_SIMPLEX_Level_1_Detail_Ordering','soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi','soc_SIMPLEX_Offshore_Level_1_Detail'};
        Set<String> setConciergeQueues = new Set<String>{'soc_Concierge_Support_requests','soc_SFD_Concierge_Offshore','SOC_Queue','soc_Concierge_Offshore_Support_request'};
        
        Map<Id,Group> mapConciergeQueues = new Map<Id,Group>();
        Map<Id,Group> mapDetailerSpecialistCTSQueues = new Map<Id,Group>();
        Set<String> setConciergeAndDSCQueues = new Set<String>{'soc_SIMPLEX_Level_1_Detail_Ordering','soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi',
                                                'soc_SIMPLEX_Offshore_Level_1_Detail', 'soc_Concierge_Support_requests','soc_SFD_Concierge_Offshore',
                                                'SOC_Queue','soc_Concierge_Offshore_Support_request'};
        Map<Id,Group> mapConciergeAndDSCQueues = new Map<Id,Group>([select Id,Name,DeveloperName from Group where Type = 'Queue' AND 
                                                DeveloperName IN :setConciergeAndDSCQueues]);
        for(Group groupRec : mapConciergeAndDSCQueues.values()){
            if(setDSCQueues.contains(groupRec.DeveloperName))
                mapDetailerSpecialistCTSQueues.put(groupRec.Id,groupRec);
            else if(setConciergeQueues.contains(groupRec.DeveloperName))   
                mapConciergeQueues.put(groupRec.Id,groupRec);
        }
        
        List<GroupMember> grpMembersDetailerSpecCTS = [Select GroupId,UserOrGroupId From GroupMember Where GroupId IN :mapDetailerSpecialistCTSQueues.KeySet()];
        Set<Id> setGroupMemberIds = new Set<Id>();
        Set<Id> setConciergeUserIds = new Set<Id>();
        
        if(grpMembersDetailerSpecCTS != null && grpMembersDetailerSpecCTS.size() > 0){
            for(GroupMember gm : grpMembersDetailerSpecCTS){
                system.debug('set='+gm.UserOrGroupId);
                setGroupMemberIds.add(gm.UserOrGroupId);
                if(mapConciergeQueues.keySet().contains(gm.GroupId)){
                	setConciergeUserIds.add(gm.UserOrGroupId); 
                }            
            }
        }
        
        if(setGroupMemberIds.contains(UserInfo.getUserId()) && (setGroupMemberIds.contains(caseList[0].OwnerId) || mapDetailerSpecialistCTSQueues.containsKey(caseList[0].OwnerId))){
        	DSCUser = 'true';    
        }
        results.put('case',caseList[0]);
        results.put('DSCUser',DSCUser);
        results.put('showAssignAllToMe',showAssignAllToMe);
        results.put('profileName',name);
        return results;                
    }
    
    //This method gets called from Assign All Child Cases to me button of assignToParentOwner component 
    @AuraEnabled
    public static Map<String,Object> assignAllChildToParentOwner(String caseId){
        
        Map<String,Object> result = new Map<String,Object>();
        List<Case> parentCaseList= [SELECT id,subject,Stage__c,
                              Status,OwnerId,requestor__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,
                              soc_SFD_Offshore_Restricted__c, Child_Case_Count__c, soc_Process_End_Time__c, soc_SFD_Case_Assignment_Time__c,
                              soc_Process_Start_Time__c, soc_Assignment_OnHold_Total_Time__c, soc_SLA_Exceeded__c, BusinessHoursId, 
                              (Select Id,ParentId,OwnerId, Stage__c, soc_isparentowner__c From Cases)
                              FROM case where id =:caseId limit 1];
       List<Case>  lstUpdateChildCasesOwners = new List<Case>();
        for(Case parentCase : parentCaseList){
            parentCase.Child_Case_Count__c = 0;
            //Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
            parentCase.soc_Process_End_Time__c = System.now();
           if(parentCase.BusinessHoursId != null)
          	 parentCase.soc_SFD_Case_Assignment_Time__c = soc_CaseCycleAcceptanceReport.getBusinessHours(parentCase.soc_Process_Start_Time__c, parentCase.soc_Process_End_Time__c, parentCase.BusinessHoursId);//processMinutes - cs.Acceptance_OnHold_Total_Time__c;
             parentCase.soc_SFD_Case_Assignment_Time__c = ((parentCase.soc_SFD_Case_Assignment_Time__c - (parentCase.soc_Assignment_OnHold_Total_Time__c*60))/60.0).setScale(2);
           Decimal businessTime = 0;
           businessTime = soc_CaseCycleAcceptanceReport.getBusinessTimeUnit('Case Assignment');
            	if((parentCase.soc_SFD_Case_Assignment_Time__c*60) > businessTime){
                	//parentCase.soc_SLA_Exceeded__c = 'Assignment';
                    if(parentCase.soc_SLA_Exceeded__c=='Acceptance'){
                        parentCase.soc_SLA_Exceeded__c = parentCase.soc_SLA_Exceeded__c+';'+'Assignment';
                    }else{
                        parentCase.soc_SLA_Exceeded__c = 'Assignment';
                    }
                    System.debug('parentCase.soc_SLA_Exceeded__c::'+parentCase.soc_SLA_Exceeded__c);                      
                    parentCase.soc_Process_Start_Time__c = System.now();
                                        }
             //END EDGE-68484
            for(Case childCase : parentCase.Cases){
                childCase.OwnerId = parentCase.OwnerId;
                childCase.Stage__c = 'Detail Order';
                 childCase.soc_isparentowner__c = true;
                lstUpdateChildCasesOwners.add(childCase);
            }
        }
        try{
            if(lstUpdateChildCasesOwners.size() > 0){
                update lstUpdateChildCasesOwners;
                result.put('status','pass');
            	result.put('response',lstUpdateChildCasesOwners);
            }
            if(parentCaseList!=null && parentCaseList.size()>0){
                update parentCaseList;
            }
        }
        catch(Exception ex){
            result.put('status','fail');
            result.put('response',ex.getMessage()); 
        }
        
        return result;
        
    } 
}