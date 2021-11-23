/**
  * Author: Sandeep Soni
  * Team: Jaipur
  * Sprint: 20.06: 
  * JIRA Story: P2OB-6036 
  * Date: 22 April 2020
*/

/* 
Description: This Batch class will add caseteam member in opportunity team member, if user manually adds a member in caseteammember then this batch class
will run every 3 hrs and check if caseteammember is offshorerestricted then it will delete that user from caseteammeber else it will upsert the new caseteammember
in opportunityteammember with same role and accesslevel. Using this batch job. 

Modified By : Team Hawaii : P2OB-11249: 17/12/2020 : Add Opportunity team member from case team member for PreSalesSolution record Type
If role does not match with case team role add user with Other Specialist role


Implement database.stateful interface to store oppRecIdSet,finalMapString,opptyTeamRoles variable value 


*/

global without sharing class cusdl_AddOppTeamMemBatch implements Database.Batchable<sObject>,Database.Stateful {  
    



    public static final String CASE_OBJECT = 'Case'; // Hawaii 
    public static final String OPPORTUNITY_OBJECT = 'Opportunity'; // Hawaii 
    public static final String  CUSTOM_DEAL_CASE_RT = 'cusdl_Custom_Deal'; //Hawaii
    public static final String OTHER_SPECIALIST = 'Other Specialist';//Hawaii



    //static variable to store caseRecordTypeIds
    static Set<String> caseRecIdSet;
    //variable to store oppRecordTypeIds
    Set<String> oppRecIdSet;
    //map of case record Type as key and related opportunity list as value
    Map<string,List<String>> finalMapString;
    //varible to store available picklist values in Opportunity team member role


    List<String> opptyTeamRoles;

    
    

    global Database.QueryLocator start(Database.BatchableContext bc){
		
        //store list of case record type developer name
        List<String> caseRecList = new List<String>();
        //store list of opportunity record type developer name
        List<String> oppRecList= new List<String>();
		
		string caseOppObject = Label.Record_Type_Name_List;
        
        //deserialize json object
        Map<String, Object> caseOppRecordType = (Map<String,Object>)json.deserializeUntyped(caseOppObject);
        
        //store key as case record Type and opportunity record type as value
        finalMapString = new Map<string,List<String>>();
        
        if(caseOppRecordType != null && caseOppRecordType.size() > 0){
            for(String key : caseOppRecordType.keySet()){
                caseRecList.add(key);
                String str = (String)caseOppRecordType.get(key);
                oppRecList.addAll(str.split(','));
                finalMapString.put(key,str.split(','));
            }
        }
        



        //Hawaii - P2OB-11249 - get case record Type Ids
        caseRecIdSet = getRecordTypeIds(CASE_OBJECT, caseRecList);
        
        //Hawaii - P2OB-11249 - get Opportunity record Type Ids
        oppRecIdSet = getRecordTypeIds(OPPORTUNITY_OBJECT, oppRecList);
        


        

		List<AsyncApexJob> lstApexJobs = [SELECT ApexClassId, CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems FROM AsyncApexJob Where ApexClassId In: ([ SELECT Id FROM ApexClass WHERE Name = 'cusdl_AddOppTeamMemBatch' ]) AND JobType= 'BatchApex' AND Status = 'Completed' Order By CreatedDate DESC ];
        //validate if apex job was run first time or not
        if(lstApexJobs!=null && lstApexJobs.isEmpty()){
            //Apex job is running first time so it will fetch all records.
            return Database.getQueryLocator([SELECT Id,MemberId, Member.UserRoleId,Parent.RecordTypeId,Parent.OpportunityId__r.RecordTypeId,Parentid,Parent.OpportunityId__r.Account.APTPS_Off_Shore_Restricted__c,Parent.OpportunityId__c, TeamRole.AccessLevel,TeamRole.Name,TeamRoleId,Parent.OpportunityId__r.RecordType.DeveloperName,Parent.RecordType.DeveloperName FROM CaseTeamMember WHERE Parent.RecordTypeid IN : caseRecIdSet AND Parent.OpportunityId__r.RecordTypeid IN :oppRecIdSet]);
        }
        else{
            //Apex job was run before so it will fetch all record from last job create time.
            return Database.getQueryLocator([SELECT Id,MemberId, Member.UserRoleId,Parent.RecordTypeId,Parent.OpportunityId__r.RecordTypeId,Parentid,Parent.OpportunityId__r.Account.APTPS_Off_Shore_Restricted__c,Parent.OpportunityId__c, TeamRole.AccessLevel,TeamRole.Name,TeamRoleId,Parent.OpportunityId__r.RecordType.DeveloperName,Parent.RecordType.DeveloperName FROM CaseTeamMember WHERE Parent.RecordTypeid IN : caseRecIdSet AND Parent.OpportunityId__r.RecordTypeid IN :oppRecIdSet AND LASTMODIFIEDDATE >= : lstApexJobs[0].CreatedDate]);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<CaseTeamMember> lstCaseTeamMembers){
        /*Fetching Record typeID for Custom RecordType*/
        //Store all opportunity team member records that are already exist in opportunity team member
        Map<String,OpportunityTeamMember> mapUserIdWithOppTeamMember = new Map<String,OpportunityTeamMember>();
        //For storing application logs in a list.
        List<ApplicationLog__c> lstApplicationLog = new List<ApplicationLog__c>(); 
        //list of opportunityid from caseteammember
        set<Id> setOppIds = new Set<Id>();
        //store role ids associated with Enterprise_Offshore public group
        Set<Id> roleIds = new Set<Id>();
        List<CaseTeamMember> lstCTMDelete = new List<CaseTeamMember>();
        List<OpportunityTeamMember> lstOTM = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppTeamMember = null;


        if(opptyTeamRoles == null){
            opptyTeamRoles = getOpportunityTeamRoles();
        }


        for(CaseTeamMember ctm : lstCaseTeamMembers){
            //validate ParentId on caseteammember should not be null
            if(ctm.ParentId!=null){
                //store opportunityid from caseteammember
                 setOppIds.add(ctm.Parent.OpportunityId__c);
            }
        }
        
        //Fetch Role from public group
        if(System.Label.GroupMembershipOffshoreGroupName!=null){
            //Fetching all role ids from public group that's name is mentioned in this custom label(System.Label.GroupMembershipOffshoreGroupName).
            roleIds = GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
        }
        
        if(oppRecIdSet != null && setOppIds != null){
            //Fetch all opportunity team member that are already added.
            for(OpportunityTeamMember otms : [select id, name, opportunityid, OpportunityAccessLevel,TeamMemberRole,UserId,opportunity.RecordTypeId from opportunityteammember where opportunity.RecordTypeId=:oppRecIdSet AND opportunityid IN :setOppIds]){
                //Here the key combination has opportunityid of opportunityteammember+opportunityteammemberid.
                String otmKey = otms.opportunityid+'#'+otms.UserId;
                mapUserIdWithOppTeamMember.put(otmKey, otms);
            }
        }
        
        if(lstCaseTeamMembers!= null && !lstCaseTeamMembers.IsEmpty()){
            //Iterating all caseteamMember
            for(CaseTeamMember ctm : lstCaseTeamMembers){
                //check if case record type is Custom deal then opportunity consider should be of Custom record type
                //check if case record type is presales solution then opportunity conside should be of standard record type
                if( finalMapString.size() > 0 && ctm.Parent.RecordTypeId != Null && ctm.Parent.OpportunityId__c != Null && ctm.Parent.OpportunityId__r.RecordTypeId != Null && finalMapString.containsKey(ctm.Parent.RecordType.DeveloperName) && finalMapString.get(ctm.Parent.RecordType.DeveloperName).contains(ctm.Parent.OpportunityId__r.RecordType.DeveloperName)){
                    //validate caseteamMember is offshore restricted and role type is exist in public group
					if((ctm.ParentID!=null && ctm.Parent.OpportunityId__c!=null && ctm.Parent.OpportunityId__r.Account!=null && ctm.Parent.OpportunityId__r.Account.APTPS_Off_Shore_Restricted__c) && ((roleIds!=null && roleIds.contains(ctm.Member.UserRoleId)) || (GroupMembership.groupUserId!=null && GroupMembership.groupUserId.contains(ctm.MemberId)))){
						//store all caseteammember that will delete from caseteammember. 
						lstCTMDelete.add(ctm);
					}
					else if(ctm.ParentId != null && ctm.Parent.OpportunityId__c!=null) {
						String ctmKey = ctm.Parent.OpportunityId__c+'#'+ctm.MemberId;
						oppTeamMember = new OpportunityTeamMember();
						//If caseteammember is already exist in opportunity team member
						if(mapUserIdWithOppTeamMember!=null && mapUserIdWithOppTeamMember.containskey(ctmKey)){
							//fetch existing opportunityteammember
							oppTeamMember = mapUserIdWithOppTeamMember.get(ctmKey);
							//validate either opportunityaccesslevel or role is changed.
							if((oppTeamMember.OpportunityAccessLevel != ctm.TeamRole.AccessLevel) || (oppTeamMember.TeamMemberRole != ctm.TeamRole.Name)){
								oppTeamMember.OpportunityAccessLevel = ctm.TeamRole.AccessLevel;


                                oppTeamMember.TeamMemberRole = ctm.Parent.RecordType.DeveloperName == CUSTOM_DEAL_CASE_RT ? ctm.TeamRole.Name : (opptyTeamRoles.contains(ctm.TeamRole.Name) ? ctm.TeamRole.Name : OTHER_SPECIALIST);


							}
						}
						else
						{
							oppTeamMember.OpportunityId = ctm.Parent.OpportunityId__c;
							oppTeamMember.OpportunityAccessLevel = ctm.TeamRole.AccessLevel;


                            oppTeamMember.TeamMemberRole = ctm.Parent.RecordType.DeveloperName == CUSTOM_DEAL_CASE_RT ? ctm.TeamRole.Name : (opptyTeamRoles.contains(ctm.TeamRole.Name) ? ctm.TeamRole.Name : 'OTHER_SPECIALIST');


							oppTeamMember.UserId = ctm.MemberId;
                            oppTeamMember.isRecordCreatedThroughBatchClass__c = True;
						}//if case team member is not exist in opportunityteammember
						//store all opportunityteammeber for upserting.
						lstOTM.add(oppTeamMember);
					}
				}
			}
            //Upsert OpportunityTeamMembers
            //validate list of opportunity teammember is not null and not empty.
            if(lstOTM != null && !lstOTM.IsEmpty()){
                //Hawaii - Remove duplicate from the list to avoid dml failure 'Before Insert or Upsert list must not have two identically equal elements'
                Set<OpportunityTeamMember> setOppTeamList = new Set<OpportunityTeamMember>();
                setOppTeamList.addAll(lstOTM);
                //Hawaii - Create list of unique team member records for upsert
                List<OpportunityTeamMember> uniqueMemberList = new List<OpportunityTeamMember>();
                uniqueMemberList.addAll(setOppTeamList);
                Database.UpsertResult[] urList = Database.Upsert(uniqueMemberList,false);
                // Iterate through each returned result
                for (Database.UpsertResult sr : urList) {
                    //if records are not upserting successfully.
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors 
                        for(Database.Error err : sr.getErrors()) {
                            lstApplicationLog.add(new ApplicationLog__c(
                                Reference_Info__c = 'Jaipur-CaseTeamMemberBatch_P2OB-6036',
                                Debug_Level__c = 'Exception',
                                Error_Category__c= 'Technical',
                                Error_Description__c= 'Error logged for CaseTeamMember ID' + uniqueMemberList.get(0).Id + ' with error '+err.getStatusCode()+' :'+ err.getMessage())); 
                        }
                    }
                }
            }
            //validate listofApplicationlog should not be null and empty.
            if(lstApplicationLog!=null && !lstApplicationLog.isEmpty()){
                //insert applicationlog records.
                insert lstApplicationLog;
            }
           
            //Delete CaseTeamMembers
            //validate lstCTMDelete is not null and empty.
            if(lstCTMDelete!=null && !lstCTMDelete.IsEmpty()){
                //delete all caseteammember that's offshorerestricted.
                Database.Delete(lstCTMDelete,false);
            }    
        }        
    }
    



    /* get Opportunity Team Role */
    private List<String> getOpportunityTeamRoles(){
        List<String> teamRoleList = new List<String>();
        //get picklist values of TeamMemberRole field of opportunity team member object
        Schema.DescribeFieldResult fieldResult = OpportunityTeamMember.TeamMemberRole.getDescribe();    
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            //add each value into list
            teamRoleList.add(String.valueOf(pickListVal.getValue()));
        }
        return teamRoleList;
    }
    
    /* get Record Type Id from Name */
    private Set<String> getRecordTypeIds(String objectName, List<String> recordTypeNames){
        Set<String> recordTypeIds = new Set<String>();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();
        for(String rtName : recordTypeNames){ 
            if(rtMapByName.containsKey(rtName)){
                recordTypeIds.add(rtMapByName.get(rtName).getRecordTypeId());
            }
        }
        return recordTypeIds;
    }
    



    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}