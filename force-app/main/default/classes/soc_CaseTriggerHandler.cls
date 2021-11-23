/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 09/08/2018 
@ModifiedByandDate: 
@Description: This Class is SOC Helper for Case Trigger 
*******************************************************************************/

public without sharing class soc_CaseTriggerHandler {
    
    //Case Status
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String CASE_STATUS_ON_HOLD = 'On Hold';
    public static final String CASE_STAGE_VALIDATE_ASSIGN_ORDER = 'Validate And Assign Order';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    
    // Pravin Sonawane : EDGE-45688 :: 12-OCT-2018
    public static final String soc_STAGE_NEW = 'New'; 
    public static final String soc_STR_MATCH='match';
    public static final String soc_STR_NO_MATCH='fail';
    public static final String soc_STR_NO_MATCH_OTHER='fail_other';
    public static final String soc_STR_SUBJECT='Parent SFD Request - ';
    public static final String soc_STR_STATUS_NEW='New';
    //Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
    public static final String soc_STR_WEB='Web';
    public static final String soc_STR_ERROR_MSG='SFD Request cannot be created as there are NO SFD Supported Products';
    public static final String soc_STR_ERROR_MSG_OTHER='SFD request cannot be created for Products Type marked as "Others".Please verify if your product is supported by creating a SFD Support Request first';
    /*public static String recId_OrderRequest=[Select id from RecordType where sObjectType = 'Case' 
and Name =: Label.soc_CaseRecordType ].id;
public static String recId_SupportRequest=[Select id from RecordType where sObjectType = 'Case' and Name =: Label.soc_CaseSuportRecordType ].id;
public static String recId_SupportRequestWO=[Select id from RecordType where sObjectType = 'Case' and Name ='Support Request without SOC' ].id;*/
    
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SupportRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request').getRecordTypeId();
    public static String recId_SupportRequestWO=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    
    
    
    //by nitesh not used in code
    // public static CaseTeamRole role = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1];
    /*
public static String conciergeQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'SOC_Queue'].Id;
public static String simplexQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_SIMPLEX_Level_1_Detail_Ordering'].Id;
public static String mediumComplexQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi'].Id;
public static String complexQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_Complex_Level_3_Detail_Queue'].Id;

public static String conciergeSupportQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_Concierge_Support_requests'].Id;
public static String smeSupportQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_SME_Support_requests'].Id;
public static String simplexSupportQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_Simplex_Support_Request'].Id;
public static String mediumSupportComplexQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_Medium_Complex_Support_Requests'].Id;
public static String complexSupportQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Complex_Support_Requests'].Id;
*/
    
    
    /***
* Put all initialization logic for SFD case and SFD support case here.
* This method is invoked whenever a SFD or support SFD is created.
* This gets called fro before insert block from caseTrigger.apxt
*/
    
    public  static void initializeSFDCases(list<Case> newList){
        System.debug('initializeSFDCases>>>>');
        //List<Case> updateSFDMap=new List<Case>();
        List<Id> accIds=new List<Id>();
        for(case cs : newList){
            if(cs.RecordTypeid == recId_OrderRequest || cs.RecordTypeid == recId_SupportRequest ||cs.RecordTypeid == recId_SupportRequestWO){
                accIds.add(cs.AccountId);
            }
        }
        
        Map<ID, Account> accountValuesMap = new Map<ID, Account>([SELECT Id,Name,APTPS_Off_Shore_Restricted__c FROM Account where id in :accIds]);
        System.debug('initializeSFDCases>>>>accountmap');
        System.debug(accountValuesMap);
        
        for(case cs : newList){
            if(cs.RecordTypeid == recId_OrderRequest || cs.RecordTypeid == recId_SupportRequest ||cs.RecordTypeid == recId_SupportRequestWO){
                if(accountValuesMap.get(cs.AccountId)!=null){
                    Account relatedAcc=accountValuesMap.get(cs.AccountId);
                    Boolean offshoreCheck=relatedAcc.APTPS_Off_Shore_Restricted__c;
                    cs.soc_SFD_Offshore_Restricted__c=offshoreCheck;
                    //updateSFDMap.add(new Case(Id = cs.id));
                }
            }
        }
        //System.debug('initializeSFDCases>>>>upsertMap');
        //System.debug(updateSFDMap);
        
        /*if(updateSFDMap.size()>0){
upsert updateSFDMap;
}*/   
        
    }
    
    
    /***
* Validate SOC creation based on Products and Initialize Predefined Case Team.
* 
*/
    
    /*public  static void initializeProductsOnCaseCreation(list<Case> newList){
System.debug('1. initializeProductsOnCaseCreation>>>>>IN');        
List<Case> sfdProductInserts=new List<Case>();
List<Case> socRequests=new List<Case>();
Map<Id,Id> caseOppIdMap=new Map<Id,Id>();
Map<Id,Id> OppIdAccIdMap=new Map<Id,Id>();

try{
for(case cs : newList){
if(cs.RecordTypeid == recId_OrderRequest){
socRequests.add(cs); 
caseOppIdMap.put(cs.OpportunityId__c,cs.Id);
}
}//End for
List<OpportunityLineItem> items=[select id,opportunityId,Domain__c,Product2Id,Product2.Name,Product_Name__c,Opportunity.AccountId from 
OpportunityLineItem where opportunityId in :caseOppIdMap.keyset()];

for(OpportunityLineItem oli:items){
Case sfdProductCaseType=new Case();
sfdProductCaseType.RecordTypeId=recId_SFD_ProductType;
sfdProductCaseType.soc_Parent_SFD_Reference__c=caseOppIdMap.get(oli.OpportunityId);
sfdProductCaseType.soc_Product__c=oli.Product_Name__c;
sfdProductCaseType.soc_Domain__c=oli.Domain__c;
sfdProductCaseType.soc_SFD_product_Text_ID__c=oli.Product2Id;
sfdProductCaseType.AccountId=oli.Opportunity.AccountId;
sfdProductCaseType.soc_SFD_Product_Status__c='New';



sfdProductInserts.add(sfdProductCaseType);                
}

insert sfdProductInserts;



}   
catch(Exception e){
System.debug('Exception >>>>>>>>'+e);
System.debug('Exception >>>>>>>>'+e.getLineNumber());
}
}*/
    
    
    
    public  static void resolveAccessesOnCaseUpdation(map<ID,Case> oldCaseMap,map<ID,Case> updatedCaseMap){
        System.debug('1. resolveAccessesOnCaseUpdation>>>>>IN');        
        List<OpportunityShare> oppShrUpserts  = new List<OpportunityShare>();
        Map<Id,Id> caseOppIdMap=new Map<Id,Id>();
        Map<Id, Id>OppOldId=new Map<Id, Id>();
        Map<Id,Id>opptyIdMap=new Map<Id, Id>();//Nitesh/Prajakat
        //Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
        Set<String> sfdRequestIds = new Set<String>();
        
        Set<Id> ownerIdSet = new Set<Id>();
        try{
            
            for(Case c: updatedCaseMap.values()){
                if(!String.isEmpty(c.OpportunityId__c) && c.RecordTypeId==recId_OrderRequest){
                    caseOppIdMap.put(c.Id,c.OpportunityId__c);
                    ownerIdSet.add(oldCaseMap.get(c.id).OwnerId);
                    //Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
                    sfdRequestIds.add(c.id);
                }
                
                if(c.RecordTypeId == recId_SupportRequest || c.RecordTypeId == recId_SupportRequestWO){
                    ownerIdSet.add(oldCaseMap.get(c.Id).OwnerId);
                }
            }
            //Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
            //Map<String,List<Case>> mapSFDParentChildList = prepareSFDProductParentChildMap(sfdRequestIds);
            
            //Sandeep Soni :: EDGE-57850 :: 16-Jan-2019
            //Map<String,List<Case>> mapSFDParentChildList = prepareSFDProductParentChildMapByParentId(sfdRequestIds);
            //System.debug('mapSFDParentChildList::'+mapSFDParentChildList);
            Map<Id,List<Id>> queueIdListPerOwnerIdMap = new Map<Id,List<Id>>();
            
            queueIdListPerOwnerIdMap = getQueueIdsForOwner(ownerIdSet);
            
            List<Id> caseIdList = new List<Id>();
            List<Task> taskList = new List<Task>();
            for( Case cs : updatedCaseMap.values() ){
                Task tsk = null;
                if(cs.RecordTypeId==recId_OrderRequest && 
                   oldCaseMap.get(cs.id).ownerId != updatedCaseMap.get(cs.id).ownerId &&
                   string.valueOf(oldCaseMap.get(cs.id).ownerId).startsWith('005') &&
                   string.valueOf(updatedCaseMap.get(cs.id).ownerId).startsWith('005')){
                       System.debug('Calling Agent to Agent  Assignment logic....');
                       caseIdList.add(cs.Id);
                       //SOC_AgentWorkTriggerHandler.resolveAccesses(cs.Id);                      
                   }
                else if(cs.RecordTypeId==recId_OrderRequest && 
                        oldCaseMap.get(cs.id).ownerId != updatedCaseMap.get(cs.id).ownerId && 
                        string.valueOf(updatedCaseMap.get(cs.id).ownerId).startsWith('00G')){
                            
                            opptyIdMap.put(cs.id,cs.OpportunityId__c);
                            //Shamikh Hassan :: EDGE-52630 :: Removed SOCAssignmentMatrixValidation from here :: 09-OCT-2018 
                            
                            
                        }                
                
                else if((cs.RecordTypeId==recId_SupportRequest  || cs.RecordTypeId==recId_SupportRequestWO) && 
                        oldCaseMap.get(cs.id).ownerId != updatedCaseMap.get(cs.id).ownerId && 
                        string.valueOf(updatedCaseMap.get(cs.id).ownerId).startsWith('00G')){
                            
                            //Shamikh Hassan :: EDGE-52630 :: Removed SOCAssignmentMatrixValidation from here :: 09-OCT-2018 
                        }
                
            }
            
            if(caseIdList.size() > 0){
                system.debug('>>> caseIdList... '+caseIdList);
                SOC_AgentWorkTriggerHandler.resolveAccesses(caseIdList);
            }
            
            if(opptyIdMap.size()>0){                
                System.debug('4. resolveAccessesOnCaseUpdation>>>>>IN'); 
                System.debug(opptyIdMap);
                deleteOpptyOldOwner(opptyIdMap,oldCaseMap); //Nitesh/Prajakat
            }
            
        }   
        catch(Exception e){
            System.debug('Exception >>>>>>>>'+e);
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
    
    
    /**
* As a SFD Team Member I want to close an SFD Case once all there are no further
* outstanding actions from SFD team for all Products so that a Case is not 
* accidentally closed with outstanding actions
* Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018 
*/ 
    /*public  static Map<String,List<Case>> prepareSFDProductParentChildMap(Set<String> parentIds){       
List<Case> lstSFDProductChild = [select id,soc_Parent_SFD_Reference__c,soc_SFD_Product_Status__c from Case where soc_Parent_SFD_Reference__c in :parentIds ];
Map<String,List<Case>> mapSFDParentChildList = new Map<String,List<Case>>();
for(Case c : lstSFDProductChild){
if(mapSFDParentChildList.containsKey(c.soc_Parent_SFD_Reference__c)){
List<Case> lstCase = mapSFDParentChildList.get(c.soc_Parent_SFD_Reference__c);
lstCase.add(c);
}
else{
List<Case> lstCase = new List<Case>();
lstCase.add(c);
mapSFDParentChildList.put(c.soc_Parent_SFD_Reference__c,lstCase);
}
}
System.debug('prepareSFDProductParentChildMap');
System.debug(mapSFDParentChildList);
return mapSFDParentChildList;

}*/
    
    
    /**
* As a SFD Team Member I want to close an SFD Case once all there are no further
* outstanding actions from SFD team for all Products so that a Case is not 
* accidentally closed with outstanding actions
* Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
*/
    /*public  static Boolean checkChildCasesForNonCompleteStatus(List<Case> childCases){
Set<String> incompleteStatusesSet=new Set<String>{'New','In Progress','Waiting Internal Response','Waiting User Response',' On Hold','Escalated','Pending Billing', 
'Pending Commercial', 'Pending Security', 'Pending Sales','Pending Service Delivery','Pending Project Delivery', 'Pending CTL',
'Pending Operations', 'Closed Un-Resolved', 'Cancelled','Re-directed'};
Boolean productEntryStatus=true;
for(Case ce:childCases){
if(incompleteStatusesSet.contains(ce.status)){ //ce.soc_SFD_Product_Status__c 
productEntryStatus=false;
return productEntryStatus;
}
}
System.debug('checkChildCasesForNonCompleteStatus');
System.debug(productEntryStatus);
return productEntryStatus;

}*/
    
    
    public static Map<Id,List<Id>> getQueueIdsForOwner(Set<Id> ownerIdList){
        system.debug('>>> ownerIdList... '+ownerIdList);
        Map<Id,List<Id>> queueIdListPerOwnerIdMap = new Map<Id,List<Id>>();
        for(GroupMember gpMem : [Select GroupId,UserOrGroupId from GroupMember where UserOrGroupId IN : ownerIdList and Group.Type = 'Queue']){
            if(queueIdListPerOwnerIdMap.containsKey(gpMem.UserOrGroupId)){
                queueIdListPerOwnerIdMap.get(gpMem.UserOrGroupId).add(gpMem.GroupId);
            }else{
                queueIdListPerOwnerIdMap.put(gpMem.UserOrGroupId, new List<Id>{gpMem.GroupId});
            }
        }
        system.debug('>>> queueIdListPerOwnerIdMap... '+queueIdListPerOwnerIdMap);
        
        return queueIdListPerOwnerIdMap;
    }
    
    public  static Set<String> getQueueIdsForOwner(String ownerId){
        system.debug('ownerid'+ownerId);
        Set<String> queueSet=new Set<String>();
        List<GroupMember> groups=[Select GroupId from GroupMember where UserOrGroupId = :ownerId and Group.Type = 'Queue' ];
        for(GroupMember mem:groups){
            queueSet.add(String.valueOf(mem.GroupId));
        }
        return queueSet;
        
    }
    
    //Prajakat/Nitesh Method for deletion
    Public static void deleteOpptyOldOwner(Map<id,id>opptyshreMap, map<ID,Case> oldCaseMap){
        List<Case>caseLists=[select id, ownerId,OpportunityId__c,RecordTypeId from case where OpportunityId__c=:opptyshreMap.values()];
        set<id> caseDelete = new set<id> ();
        set<id> optyids = new set<id> ();
        system.debug('in nitesh code oldCaseMap ' + oldCaseMap.size());
        for(case csObj: oldCaseMap.values()){
            for(case newcaseObj:caseLists){
                if(csObj.ownerId==newcaseObj.ownerId && csObj.OpportunityId__c==newcaseObj.OpportunityId__c && csObj.id != newcaseObj.id && csObj.RecordTypeId == newcaseObj.RecordTypeId){
                    caseDelete.add(csObj.id);
                }
            }                           
            optyids.add(csObj.OpportunityId__c);       
        }
        system.debug('in nitesh code caseDelete' + caseDelete.size());
        system.debug('in nitesh code optyids' + optyids.size());
        if(optyids.size() > 0){
            List<OpportunityShare>OpptyShrListDelete = new List<OpportunityShare> ();
            List<OpportunityShare>OpptyShrList=[select id,OpportunityId,UserOrGroupId,OpportunityAccessLevel 
                                                from OpportunityShare where  OpportunityId=:optyids];           
            system.debug('in nitesh code row ' + OpptyShrList.size());
            for(case csObj: oldCaseMap.values()){
                if(!caseDelete.contains(csObj.id)){
                    for(OpportunityShare oppshrs : OpptyShrList){
                        if(oppshrs.OpportunityId == csObj.OpportunityId__c && oppshrs.UserOrGroupId == csObj.ownerId && oppshrs.OpportunityAccessLevel == 'Read') {       
                            OpptyShrListDelete.add(oppshrs);                                
                        } 
                    }
                }
            }  
            system.debug('in nitesh code row delete ' + OpptyShrListDelete.size());
            if(OpptyShrListDelete.size()>0){
                delete OpptyShrListDelete;
            }   
        }      
    }
    
    
    
    public  static String getQueueIdForOwner(String ownerId){
        system.debug('ownerid'+ownerId);
        String queueId=[Select GroupId from GroupMember where UserOrGroupId = :ownerId and Group.Type = 'Queue' LIMIT 1].GroupId;
        
        return queueId;
        
    }
    
    
    /***
* Validate SOC creation based on Products and Initialize Predefined Case Team.
* 
*/
    
    public  static void updateValidateOnCaseCreation(list<Case> newList){
        System.debug('1. updateValidateOnCaseCreation>>>>>IN');        
        List<Case> caseInserts=new List<Case>();
        
        try{
            //#1.check for SOC products in Opp primary domain and products list
            Map<Id,String> validationResults=checkOpportunityAndProductDomains(newList);
            
            for(Case c:newList){
                if(validationResults.get(c.id)==soc_STR_NO_MATCH){
                    c.addError(soc_STR_ERROR_MSG);
                }
                if(validationResults.get(c.id)==soc_STR_NO_MATCH_OTHER){
                    c.addError(soc_STR_ERROR_MSG_OTHER);
                }
            }
            
        }   
        catch(Exception e){
            System.debug('Exception >>>>>>>>'+e);
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
    
    
    
    
    
    public  static Map<Id,String> checkOpportunityAndProductDomains(list<Case> newList){
        List<Case> caseUpserts=new List<Case>();
        List<CaseTeamMember> caseMembersUpserts=new List<CaseTeamMember>();
        
        Map<Id,String> results=new Map<Id,String>();
        Map<Id, Case> caseMap = new Map<Id, Case>([select id FROM Case where id IN :newList]);
        Map<Id,Id> caseOppIdMap=new Map<Id,Id>();
        Map<Id,Opportunity> caseOppMap=new Map<Id,Opportunity>();
        Set<Id> casesIdSet = new Set<id>();
        Set<Id> casesOwnerIdSet = new Set<id>();
        List<Case> supportCases=new List<Case>();
        
        for(Case c: newList){
            if( !String.isEmpty(c.OpportunityId__c) && c.RecordTypeId==recId_OrderRequest){
                caseOppIdMap.put(c.OpportunityId__c,c.Id);
            }
            else if(c.RecordTypeId==recId_SupportRequestWO || c.RecordTypeId==recId_SupportRequest){
                System.debug('CASE INSERT SUPOORT BLOCK');
                System.debug(c);                
                supportCases.add(c);
            }
            casesIdSet.add(c.Id);
            casesOwnerIdSet.add(c.ownerId);
            
        }
        
        List<Opportunity> opplist=[select id,Name,Product_Domain__c ,CIDN__c,Owner.Name,
                                   Customer_Accepted__c, //Account.Offshore_Data_Hosting_Restricted__c, //Dependency with EDGE-47352
                                   Account.id,Account.Name,Account.CIDN__c,Account.Parent_CIDN__c,
                                   AccountId, OwnerId, Account.Ultimate_Parent_CIDN__c,
                                   (SELECT Id, Domain__c FROM OpportunityLineItems)
                                   from Opportunity where id in :caseOppIdMap.keyset()];       
        
        for(Opportunity opp: opplist){
            caseOppMap.put(caseOppIdMap.get(opp.id),opp);
        }
        
        for(Opportunity o:caseOppMap.values()){
            if(o.Product_Domain__c=='DATA & IP'||o.Product_Domain__c=='MDN'||
               o.Product_Domain__c=='SECURITY'|| o.Product_Domain__c=='UNIFIED COMMUNICATIONS'){
                caseUpserts.add(enrichData(caseMap.get(caseOppIdMap.get(o.id)),o));
            }
            else if(o.Product_Domain__c=='OTHER'){
                results.put(caseOppIdMap.get(o.id),soc_STR_NO_MATCH_OTHER);                
            }
            else if(checkOppLineItemsHasSOC(o.OpportunityLineItems)){    
                caseUpserts.add(enrichData(caseMap.get(caseOppIdMap.get(o.id)),o));                
            }
            else{                
                results.put(caseOppIdMap.get(o.id),soc_STR_NO_MATCH);                
                
            }
        }
        
        //Modified by Nilima against jira story 6436
        Map<Id, Set<Id>> caseTeamMemberMap = new Map<Id, Set<Id>>();
        for(CaseTeamMember teamMember : [select Id ,ParentId, MemberId from CaseTeamMember 
                                        where ParentId IN : casesIdSet And MemberId IN : casesOwnerIdSet ]){
            if(caseTeamMemberMap.ContainsKey(teamMember.ParentId)){
                caseTeamMemberMap.get(teamMember.ParentId).add(teamMember.MemberId);
            }else{
                caseTeamMemberMap.put(teamMember.ParentId, new Set<Id>{teamMember.MemberId});
            }
        }
        if(supportCases.size()>0){ 
            CaseTeamMember member=checkExistingCaseMember(supportCases,caseTeamMemberMap);
            if(member!=null){                   
                caseMembersUpserts.add(member);
            }
        }    
        System.debug('CASE INSERT SUPOORT BLOCK 222222'+(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable()));
        System.debug(caseMembersUpserts);
        if(caseUpserts.size()>0){ 
            if(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable()){           
                upsert caseUpserts; 
            }else{
                Trigger.new[0].addError(String.format(Label.Soc_Access_Error_Msg,new List<String>{'Case'} ));
            }            
            CaseTeamMember member=checkExistingCaseMember(caseUpserts,caseTeamMemberMap);
            if(member!=null){                   
                caseMembersUpserts.add(member);
            }
        }
        
        System.debug('CASE INSERT TRIGGER');
        System.debug(caseMembersUpserts);
        if(Schema.sObjectType.CaseTeamMember.isCreateable() && Schema.sObjectType.CaseTeamMember.isUpdateable()){
            upsert caseMembersUpserts; 
        }else{
            Trigger.new[0].addError(String.format(Label.Soc_Access_Error_Msg,new List<String>{'CaseTeamMember'} ));
        }
            
        
        return results;
    }
    
    /*  * Method Name ::  checkExistingCaseMember
        * PGOB-6436   ::  Security Vulnerabilities
        * Developer Name::  Nilima Borse
        * Description: Method to check existing CaseTeamMember record for respective case.
    */
    public static CaseTeamMember checkExistingCaseMember(List<Case> caseList , Map<Id, Set<Id>> CaseTeamMemberMap){
        CaseTeamMember member = new CaseTeamMember();
        for(Case c:caseList){
            System.debug('CASE INSERT SUPOORT BLOCK 11111');            
            if(!CaseTeamMemberMap.ContainsKey(c.id)){
                member = soc_Utility.addCaseMember(c.id,c.ownerId);
            }
            else if(CaseTeamMemberMap.ContainsKey(c.id) && (CaseTeamMemberMap.get(c.id)).isEmpty()){
                member = soc_Utility.addCaseMember(c.id,c.ownerId);
            }else if(CaseTeamMemberMap.ContainsKey(c.id) && !(CaseTeamMemberMap.get(c.id).isEmpty()) && 
                                            !(CaseTeamMemberMap.get(c.id).contains(c.ownerId)) ){
                member = soc_Utility.addCaseMember(c.id,c.ownerId);
            }           
        }
        return member;
    }
    
    
    
    
    /***
* To check if OpportunityLineItems has any SOC Product
* 
*/
    public  static Boolean checkOppLineItemsHasSOC(list<OpportunityLineItem> lineItems){
        Boolean isSOCAvailable=false;
        
        for(OpportunityLineItem olm:lineItems){
            if(olm.Domain__c=='DATA & IP'|| olm.Domain__c=='MDN'||
               olm.Domain__c=='SECURITY'|| olm.Domain__c=='UNIFIED COMMUNICATIONS'){
                   isSOCAvailable=true;
                   return isSOCAvailable;
               }
        }                      
        return isSOCAvailable;
        
    }
    
    /***
* Enrich Case with Opportunity Data
* 
*/
    public  static Case enrichData(Case currentCase,Opportunity opp){               
        case c = currentCase;
        c.Subject = soc_STR_SUBJECT+opp.Name;                
        c.Status = soc_STR_STATUS_NEW;
        c.RecordTypeId = recId_OrderRequest;
        c.Stage__c = soc_STAGE_NEW;                
        c.Primary_Domain__c = opp.Product_Domain__c;
        //c.OwnerId = opp.OwnerId;
        c.OwnerId = userinfo.getUserId();
        c.soc_CIDN__c = opp.Account.CIDN__c;
        c.soc_Parent_CIDN__c= opp.Account.Parent_CIDN__c;
        c.soc_Ultimate_Parent_CIDN__c= opp.Account.Ultimate_Parent_CIDN__c;
        //c.Requestor__c = opp.OwnerId;
        c.Requestor__c = userinfo.getUserId();
        c.AccountId = opp.AccountId;
        c.OpportunityId__c = opp.id;
        //c.soc_Offshore_Data_Hosting_Restricted__c = opp.Account.Offshore_Data_Hosting_Restricted__c; //Dependency with EDGE-47352
        //c.Customer_Acceptance_Evidence__c = opp.Customer_Accepted__c;                 
        return c;               
    }
    
    public static void updateTimestampforSOCCalculations(map<ID,Case> oldCaseMap,map<ID,Case> updatedCaseMap){
        System.debug('=====Inside updateTimestampforSOCCalculations()=====' + recId_OrderRequest);        
        
        try{
            for(Case c : updatedCaseMap.values()) {
                if(c.RecordTypeId == recId_OrderRequest) {
                    if(c.RecordTypeId == recId_OrderRequest) {
                        if(oldCaseMap.get(c.id).Status.equals(CASE_STATUS_NEW) && 
                           c.Status.equals(CASE_STATUS_IN_PROGRESS)) {
                               c.SLA_Start_Time__c = System.now();
                           } 
                        /*
else if(oldCaseMap.get(c.id).Status.equals(CASE_STATUS_IN_PROGRESS) && 
c.Status.equals(CASE_STATUS_ON_HOLD)) {
c.SLA_Onhold_Time__c = System.now();
} else if(oldCaseMap.get(c.id).Status.equals(CASE_STATUS_ON_HOLD) && 
c.Status.equals(CASE_STATUS_IN_PROGRESS)) {
c.SLA_Resume_Time__c = System.now();
} */
                        else if(oldCaseMap.get(c.id).Status.equals(CASE_STATUS_IN_PROGRESS) && 
                                c.Status.equals(CASE_STATUS_CLOSED)) {
                                    c.SLA_Completion_Time__c = System.now();
                                }
                    }
                    
                    System.debug('=====c.SLA_Start_Time__c=====' + c.SLA_Start_Time__c); 
                    System.debug('=====c.SLA_Onhold_Time__c=====' + c.SLA_Onhold_Time__c); 
                    System.debug('=====c.SLA_Resume_Time__=====' + c.SLA_Resume_Time__c); 
                    System.debug('=====c.SLA_Completion_Time__c=====' + c.SLA_Completion_Time__c);
                }    
            }
        } 
        catch(Exception e) {
            System.debug('Exception >>>>>>>>'+e);
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
     
    /*
     * EDGE-64344::  Cycle Time Report For SFD Cases
     * Method Name: cycleReportForSFDCase
     * Input Parameter: Map<ID,Case> oldCaseMap, Map<ID,Case> newCaseMap
     * Output Parameter: void
     * Description: For Updating CaseOwnerType, Requester Department Field of parent case.
     * Created By:  Sandeep Soni
     * Create Date: 01 March 2019
    */
    public static void cycleReportForSFDCase(Map<ID,Case> oldCaseMap, Map<ID,Case> newCaseMap){
        System.debug('Enter in Method::cycleReportForSFDCase');
        //Commented by Kritika |EDGE-83899|22 May'19
        /*Set<String> requestorProfileIdSet = new Set<String>{'Sales Enterprise B2B','Account Manager','Account Owner',
            'Sales - Enterprise','Sales Enterprise B2B','Sales Manager - Enterprise'};*/
        //START Added Kritika |EDGE-83899|22 May'19   
        Map<String, soc_Requestor_Profiles__c> reqProfiles = soc_Requestor_Profiles__c.getAll();
        Set<String> requestorProfileIdSet = new Set<String>();
        requestorProfileIdSet = reqProfiles.keySet();
        System.debug('>>>KB>'+ requestorProfileIdSet);
        //END EDGE-83899        
        Set<String> conciergeQueueSet = new Set<String>{'SOC_Queue','soc_SFD_Concierge_Offshore'};
        Set<String> detailerQueueSet = new Set<String>{'soc_SIMPLEX_Level_1_Detail_Ordering', 'soc_SIMPLEX_Offshore_Level_1_Detail'};
        Set<String> specialistQueueSet = new Set<String>{'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi'};
        Set<String> ctsQueueSet = new Set<String>{'soc_Complex_Level_3_Detail_Queue'};
        Map<Id, GroupMember> userGRPMap = new Map<Id, GroupMember>();
        DateTime currentDate = System.now();
        List<Case> lstCase = new List<Case>();
        Map<Id, User> caseOwnerProfileIdMap = new Map<Id, User>();
        Set<Id> ownerIdSet = new Set<Id>();
        Map<String,Id> businessHRSMap = new Map<String, Id>();
        Set<Id> filterOwnerIdSet = new Set<Id>();
        Map<Id,Group> grpMap = new Map<Id,Group>();

        //Modified this for code optimization to execute this method only if the owner Id is changed 
        for(Case childCase: newCaseMap.values() ){
            if(childCase.OwnerId != oldCaseMap.get(childCase.Id).OwnerId){
                filterOwnerIdSet.add(childCase.Id);
            }
        }

        if(!filterOwnerIdSet.isEmpty() && filterOwnerIdSet.size() > 0 ){
            Map<Id,Profile> requestorProfileMap = new Map<Id, Profile>([SELECT ID, Name FROM Profile WHERE Name IN :requestorProfileIdSet]);
            
            Map<Id, GroupMember> grpMemberMap = new Map<Id, GroupMember>([SELECT ID, UserOrGroupId, GroupId, Group.DeveloperName, Group.Type FROM GroupMember WHERE 
                                                                        GroupId IN (select Id from Group 
                                                                    where Type = 'Queue' AND (DeveloperName IN :conciergeQueueSet OR 
                                                                                                DeveloperName IN :detailerQueueSet OR 
                                                                                                DeveloperName IN :specialistQueueSet OR 
                                                                                                DeveloperName IN :ctsQueueSet))]);
            
            System.debug('grpMap Id::'+grpMap.keySet());
            for(GroupMember gm : grpMemberMap.values()){
                userGRPMap.put(gm.UserOrGroupId, gm);
                grpMap.put(gm.groupId,gm.Group);
            }
            System.debug('userGRPMap Id::'+userGRPMap.keySet());
            System.debug('grpMap::'+grpMap);
            for(Case cs : newCaseMap.values()){ 
                if(cs.recordTypeId==recId_OrderRequest || cs.recordTypeId==recId_SFD_ProductType){
                    ownerIdSet.add(cs.OwnerId);
                    if(String.valueOf(oldCaseMap.get(cs.id).ownerId).startsWith('005')){
                        ownerIdSet.add(oldCaseMap.get(cs.id).OwnerId);
                    }
                }
            }
            
            for(User us : [SELECT ID, ProfileId, Department,TimeZoneSidKey FROM User WHERE id IN : ownerIdSet]){
                caseOwnerProfileIdMap.put(us.id, us);
            }
            List<BusinessHours> lstBusinessHours = [select Id, Name, TimeZoneSidKey from BusinessHours WHERE isActive = true AND Name like 'SOC%'LIMIT 50000];
            for(BusinessHours bussHours : lstBusinessHours){
                businessHRSMap.put(bussHours.TimeZoneSidKey,bussHours.id);
            }
            System.debug('businessHRSMap::'+businessHRSMap);
            System.debug('caseOwnerProfileIdMap::'+caseOwnerProfileIdMap);
            for(Case cs : newCaseMap.values()){
                    System.debug('oldCaseMap.case::'+oldCaseMap.get(cs.id));
                    System.debug('newCaseMap.case::'+newCaseMap.get(cs.id));
                    /*validating case owner is user or not*/
                    if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startsWith('005')){
                        if(requestorProfileMap!=null && caseOwnerProfileIdMap.ContainsKey(cs.OwnerId) && requestorProfileMap.containsKey(caseOwnerProfileIdMap.get(cs.OwnerId).ProfileId)){
                            cs.soc_Case_Owner_Type__c = 'Requester';
                            cs.soc_Requester_Department__c = caseOwnerProfileIdMap.get(cs.OwnerId).Department;
                        }
                        else if(userGRPMap!=null && userGRPMap.containsKey(cs.OwnerId)){
                            String grpId = userGRPMap.get(cs.OwnerId).groupId; 
                            String developerName = grpMap.get(grpId).DeveloperName;
                            System.debug('grpId::'+grpId);
                            System.debug('developerName::'+developerName);
                            if(conciergeQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Concierge';
                            }
                            else if(detailerQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Detailer';
                            }
                            else if(specialistQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Specialist';
                            }
                            else if(ctsQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'CTS';
                            }
                        }
                    }else if(String.valueOf(cs.OwnerId).startsWith('00G')){//validating case owner is queue or not
                        if(grpMap!=null && grpMap.containsKey(cs.OwnerId)){
                            String developerName = grpMap.get(cs.OwnerId).DeveloperName;
                            System.debug('developerName::'+developerName);
                            if(detailerQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Simplex Queue';
                            }
                            else if(conciergeQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Concierge Queue';
                            }
                            else if(specialistQueueSet.contains(developerName) ||
                            ctsQueueSet.contains(developerName)){
                                cs.soc_Case_Owner_Type__c = 'Complex Queue';
                            }
                        }
                        
                    }
                
            }
            soc_CaseCycleAcceptanceReport.sfdCaseAcceptanceTimeReport(newCaseMap, oldCaseMap, currentDate, caseOwnerProfileIdMap, businessHRSMap);  
            soc_CycleTimeReportForSFDCases.SFDCaseDetailingTimeReport(newCaseMap, oldCaseMap, caseOwnerProfileIdMap, businessHRSMap);
            //Sandeep Soni :: EDGE-71131 :: 08-April-2018
            //Description: This method will start/stop SLA milestone on current Case
            soc_SLABusinessHourService.manageSLAMilestone(newCaseMap, oldCaseMap);  
        }        
    }
   
    
     //Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
    public static void sfdCaseAssignmentTimeReport(Map<ID,Case> oldCaseMap, Map<ID,Case> newCaseMap){
               
        for(Case cs: newCaseMap.values()){
            if(cs.RecordTypeId == recId_OrderRequest || cs.RecordTypeId ==recId_SFD_ProductType){
            if(cs.Stage__c == CASE_STAGE_VALIDATE_ASSIGN_ORDER && oldCaseMap.get(cs.Id).Status == CASE_STATUS_IN_PROGRESS 
               && cs.Status == CASE_STATUS_ON_HOLD){
                   cs.soc_OnHold_Start_Time__c = System.now();
               }
            else if(cs.Stage__c == CASE_STAGE_VALIDATE_ASSIGN_ORDER && oldCaseMap.get(cs.Id).Status == CASE_STATUS_ON_HOLD 
               && cs.Status == CASE_STATUS_IN_PROGRESS){
                   cs.soc_OnHold_End_Time__c = System.now();
                   Decimal onHoldSeconds = 0;
                    if(cs.BusinessHoursId != null)
                   onHoldSeconds = soc_CaseCycleAcceptanceReport.getBusinessHours(cs.soc_OnHold_Start_Time__c, cs.soc_OnHold_End_Time__c, cs.BusinessHoursId);
                   cs.soc_Assignment_OnHold_Total_Time__c = (((cs.soc_Assignment_OnHold_Total_Time__c*60) + onHoldSeconds)/60.0).setScale(2);
               }
            }
        }
    }
    //END EDGE-68484
}