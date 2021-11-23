/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 8-Jan-2019
@ModifiedByandDate: Preeti Malik 5-May-2020 for P2OB-6411
@Description: This class contains   trigger handler logic for child case and Case Line Items. 
@References
Epic :EDGE-40183 P2O: Sales Order Parent Child Division of SFD Cases 
Story:EDGE-57334 Automated Child Case Creation, Submission and Acceptance by SFD concierge 
*******************************************************************************/


public without sharing class soc_ParentChildCaseHandler {   
    
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_WITHDRAWN = 'Withdrawn'; 
    public static final String CASE_STATUS_REJECTED = 'Rejected'; 
    public static final String CASE_VALIDATE_AND_ASSIGN = 'Validate And Assign Order';
    public static final String CASE_DETAIL_ORDER = 'Detail Order'; 
    //Sandeep Soni: EDGE-57850  ::  16-JAN-2019
    public static final String soc_STR_TASK_OPEN_PARENTCASE_CLOSE = 'Kindly complete the task that is created in the Parent SFD case before closing the SFD case';
    public static final String soc_STR_UNCLOSED_PRODUCTS = 'There are linked child cases open, kindly click "Related" tab to check the status of child cases and have them closed before closing the parent SFD Case';//'The Case cannot be closed as there are still Products that require action. Please check the Products tab and complete the required action before closing the Case';
    public static final String soc_RESTRICT_PARENTCASE_STATUS = 'All the child cases have been rejected or withdrawn, which would mean order on the whole has not been accepted by the SFD team. Hence, please set the parent case status to withdrawn or rejected with the right sub-status only';
    
    public  static void initiateChildCreation(map<ID,Case> oldCaseMap,map<ID,Case> updatedCaseMap){
        //list<case> caselist = new list<case>();
        for( Case cs : updatedCaseMap.values() ){
            
            if(oldCaseMap.get(cs.id).Stage__c !=updatedCaseMap.get(cs.id).Stage__c && updatedCaseMap.get(cs.id).Stage__c=='Validate And Assign Order'){
                soc_ParentChildService.createChildCasesPerUniqueDomain(updatedCaseMap.values()); 
                //caselist.add(cs);             
            }       
        }
        /*if(caselist.size() > 0){
soc_ParentChildService.createChildCasesPerUniqueDomain(caselist);
}*/
    }
    
    //START Added by Kritika for EDGE-57480
    
    public static void checkOwnerOfChildCase(map<ID,Case> oldCaseMap,List<Case> newList){
        DateTime completionDate = System.now(); 
        List<Case> updateCases = new List<Case>(); 
        Map<Id, Case> caseMap = new Map<Id, Case>();
        
        Set<String> mileStoneSet = new Set<String>();
        Map<Id, Group> mapDetailerSpecialistCTSQueues = new Map<Id, Group>();
        Map<Id,Group> mapConciergeQueues = new Map<Id,Group>();
        Set<Id> ownerIdSet = new Set<Id>();
         //Modified this for code optimization to execute this method only if the owner Id is changed 
        for(Case childCase: newList){
            if(childCase.OwnerId != oldCaseMap.get(childCase.Id).OwnerId){
                ownerIdSet.add(childCase.Id);
            }
        }
        if(!ownerIdSet.isEmpty() && ownerIdSet.size() > 0 ){
            Map<Id,Group> grpMap = new Map<Id,Group>([select Id, DeveloperNAME from Group where Type = 'Queue' limit 50000]);
            
            for(Group gp : grpMap.values()){
                if(gp.DeveloperNAME != 'soc_SFD_Concierge_Offshore' && gp.DeveloperNAME != 'SOC_Queue' && gp.DeveloperNAME != 'soc_Concierge_Support_requests'){
                    mapDetailerSpecialistCTSQueues.put(gp.id, gp); 
                }
                if(gp.DeveloperNAME == 'soc_SFD_Concierge_Offshore' || gp.DeveloperNAME == 'SOC_Queue' || gp.DeveloperNAME == 'soc_Concierge_Support_requests'){
                    mapConciergeQueues.put(gp.id, gp);
                }
            }
            Map<Id,GroupMember> groupMemberMap = new Map<Id, GroupMember>([Select GroupId,UserOrGroupId From GroupMember Where GroupId IN :mapDetailerSpecialistCTSQueues.KeySet() OR GroupId IN :mapConciergeQueues.keySet()]);
            Set<Id> DetailerSpecCTSGroupMember = new Set<Id>();
            
            if(groupMemberMap != null && groupMemberMap.size() > 0){
                for(GroupMember gm : groupMemberMap.values()){
                    if(mapDetailerSpecialistCTSQueues!=null && mapDetailerSpecialistCTSQueues.containsKey(gm.GroupId))
                        DetailerSpecCTSGroupMember.add(gm.UserOrGroupId);
                }            
            }
            
            // Map<Id,Group> mapConciergeQueues = new Map<Id,Group>([select Id from Group where Type = 'Queue' AND (DeveloperNAME = 'soc_SFD_Concierge_Offshore' OR DeveloperNAME = 'SOC_Queue' OR DeveloperNAME = 'soc_Concierge_Support_requests')]);
            //List<GroupMember> grpMembersConcierge = [Select GroupId,UserOrGroupId From GroupMember Where GroupId IN :mapConciergeQueues.KeySet()];
            Set<Id> conciergeGroupMember = new Set<Id>();
            
            if(groupMemberMap != null && groupMemberMap.size() > 0){
                for(GroupMember gm : groupMemberMap.values()){
                    if(mapConciergeQueues!=null && mapConciergeQueues.containsKey(gm.GroupId))
                        conciergeGroupMember.add(gm.UserOrGroupId);
                }            
            }
            
            Map<Id,Case> parentCaseChilOwnerMap = new Map<Id, Case>();//child cases assigned from concierge to Detailer/spec/CTS
            Map<Id,Case> parentCaseChilOwnerMapDir = new Map<Id, Case>(); //child cases reassigned later 
            
            for(Case childCase: newList){
                if(childCase.RecordTypeId == recId_SFD_ProductType && childCase.OwnerId != oldCaseMap.get(childCase.Id).OwnerId && string.valueOf(childCase.OwnerId).startsWith('005')){
                    if(conciergeGroupMember.contains(oldCaseMap.get(childCase.Id).OwnerId) && DetailerSpecCTSGroupMember.contains(childCase.OwnerId)){
                        parentCaseChilOwnerMap.put(childCase.parentId, childCase);
                        caseMap.put(childCase.Id, childCase);
                        if(childCase.Stage__c=='Validate And Assign Order'){
                            mileStoneSet.add('Concierge Milestone');
                        }
                        childCase.Stage__c = Label.soc_Stage_Detail_Order;
                    }
                    else{ 
                        if(childCase.soc_isParentOwner__c && (childCase.status != CASE_STATUS_WITHDRAWN
                                                            && childCase.status != CASE_STATUS_REJECTED
                                                            &&  childCase.status != CASE_STATUS_CLOSED))
                            parentCaseChilOwnerMapDir.put(childCase.parentId, childCase);
                    }
                } 
                else if(childCase.RecordTypeId == recId_SFD_ProductType && 
                        childCase.OwnerId != oldCaseMap.get(childCase.Id).OwnerId && mapDetailerSpecialistCTSQueues != null &&
                        mapDetailerSpecialistCTSQueues.containsKey(childCase.OwnerId)){
                            caseMap.put(childCase.Id, childCase);
                            if(childCase.Stage__c=='Validate And Assign Order'){
                                mileStoneSet.add('Concierge Milestone');
                            }
                        }
            }
            if(caseMap != null && caseMap.size()>0 && mileStoneSet != null && mileStoneSet.size()>0){
                soc_MilestoneUtils.completeMilestone(caseMap, mileStoneSet, completionDate); 
            }
            if(parentCaseChilOwnerMapDir.size() > 0){
                soc_ParentCaseOwnerService.updateParentCaseOwnerDir(parentCaseChilOwnerMapDir);
            }
            if(parentCaseChilOwnerMap.size() > 0){
                soc_ParentCaseOwnerService.updateParentOwnerAndCount(parentCaseChilOwnerMap);
            }
        }
    }
    
    public static void changeParentOwnerOnChildCaseClose(map<ID,Case> oldCaseMap,List<Case> newList){
        List<Id> parentIdList = new List<Id>();
        for(Case childCase : newList){
            if(childCase.RecordTypeId == recId_SFD_ProductType && childCase.Status != oldCaseMap.get(childCase.Id).Status &&
               childCase.Status == 'Closed' && childCase.soc_isParentOwner__c){
                   parentIdList.add(childCase.ParentId);
               }
        }
        if(parentIdList.size() > 0){
            soc_ParentCaseOwnerService.changeParentOwnerOnChildClose(parentIdList);
        }
    }
    //END EDGE-57480
    
    
    
    /* Sandeep Soni :: EDGE-57850 :: 16-JAN-2019
*/
    
    public static void validateParentChildCloseCase(map<ID,Case> oldCaseMap,map<ID,Case> updatedCaseMap){ 
        System.debug('validateParentChildCloseCase::'+updatedCaseMap);
        try{
            Set<String> sfdRequestIds = new Set<String>(); 
            Map<Id,Id> caseOppIdMap=new Map<Id,Id>();
            Set<Id> ownerIdSet = new Set<Id>();
            Map<String,List<Case>> mapSFDParentChildList = new Map<String,List<Case>>();
            Map<Id,Case> childParentCaseMap = soc_ParentChildBusinessRules.getParentByChildCase(updatedCaseMap); 
            Map<String,List<Case>> mapSFDParentChildListByChild = new Map<String,List<Case>>();
            Set<String> sfdParentIds = new Set<String>(); 
            
            for(Case c : updatedCaseMap.values()){
                if(!String.isEmpty(c.OpportunityId__c) && c.RecordTypeId==recId_OrderRequest){
                    caseOppIdMap.put(c.Id,c.OpportunityId__c);
                    ownerIdSet.add(oldCaseMap.get(c.id).OwnerId);
                    //Shamikh Hassan :: EDGE-44926 :: 09-OCT-2018
                    sfdRequestIds.add(c.id);
                }
                if(c.RecordTypeId == recId_SFD_ProductType){
                    sfdParentIds.add(c.ParentId);
                }
                
            }
            System.debug('<<<<<<<<SOQL Count 1>>>>>>>>>>' + Limits.getQueries());
            System.debug('sfdParentIds::' + sfdParentIds);
            if(sfdRequestIds!=null && sfdRequestIds.size()>0){
                mapSFDParentChildList = soc_ParentChildBusinessRules.prepareSFDProductParentChildMapByParentId(sfdRequestIds);
            }
            if(sfdParentIds!=null && sfdParentIds.size()>0){
                mapSFDParentChildListByChild = soc_ParentChildBusinessRules.prepareSFDProductParentChildMapByParentId(sfdParentIds);
            }
            
            System.debug('mapSFDParentChildListByChild::'+mapSFDParentChildListByChild);
            Map<Id,Task> tskMap = new Map<Id,Task>();
            for(Case cs : updatedCaseMap.values() ){  
                Task tsk = null; 
                System.debug('cs.RecordTypeId::'+cs.RecordTypeId);
                System.debug('oldcasestatus::'+oldCaseMap.get(cs.id).status);
                System.debug('updatedCaseMap::'+updatedCaseMap.get(cs.id).status);
                System.debug('cs.ParentId::'+cs.ParentId);
                System.debug('mapSFDParentChildListByChild::'+mapSFDParentChildListByChild);
                Map<Id, Case> childCaseMap = new Map<Id, Case>();
                if(mapSFDParentChildListByChild!=null && mapSFDParentChildListByChild.containskey(cs.ParentId)){
                    List<Case> allChildCase = mapSFDParentChildListByChild.get(cs.ParentId);
                    System.debug('allChildCase::'+allChildCase);
                    for(Case cas : allChildCase){ 
                        if(cas.status != CASE_STATUS_CLOSED){
                            childCaseMap.put(cas.id, cas);	
                        }
                    }
                    if(cs.RecordTypeId==recId_SFD_ProductType && childCaseMap!=null && 
                       childCaseMap.containsKey(cs.id) && oldCaseMap.get(cs.id).status != updatedCaseMap.get(cs.id).status &&
                   updatedCaseMap.get(cs.id).status == CASE_STATUS_CLOSED && childCaseMap.size()>0){
                           childCaseMap.remove(cs.id);
                       }
                    System.debug('final childCaseMap::'+childCaseMap);
                    
                }
                if(cs.RecordTypeId==recId_SFD_ProductType && 
                   oldCaseMap.get(cs.id).status != updatedCaseMap.get(cs.id).status &&
                   updatedCaseMap.get(cs.id).status == CASE_STATUS_CLOSED){
                       if(childCaseMap!=null && childCaseMap.size()==0){
                           //EDGE-57850   ::  Parent SFD Closure with Task Open
                           System.debug('childCaseMap.size()::'+childCaseMap.size());
                           Case parentCase = null;
                           if(childParentCaseMap!=null && childParentCaseMap.containsKey(cs.id)){
                               parentCase = childParentCaseMap.get(cs.id);
                           }
                           System.debug('parentCase::'+parentCase);
                           System.debug('parent Status::'+parentCase.status);
                           if(cs.status == CASE_STATUS_CLOSED && parentCase!=null){
                               tsk = soc_ParentChildBusinessRules.createTaskOnParentCase(parentCase);  
                           }
                           if(tskMap!=null && tsk!=null){ 
                               tskMap.put(tsk.whatId, tsk); 
                           }    
                           
                       }
                       
                   }//When SFD Team member tries to close child case then we will check all remaining child case are already closed
                //if closed then we will create a task on parent case. Ref: EDGE-57850
            }
            if(tskMap!=null && tskMap.size()>0){
                insert tskMap.values();
            }
        }
        catch(Exception e){
            System.debug('Exception >>>>>>>>'+e);
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
    
    /*  Method Name ::  updateMilestone
*  EDGE-57886   ::  SLA For SFD Cases
* Developer Name::  Sandeep Soni
* Description: Method for fetching all cases that have stage as 'Validate And Assign Order/Detail Order'
*
*/
    public static void updateMilestone(Map<ID,Case> oldCaseMap, Map<ID,Case> newCaseMap){
        String profileId = userinfo.getProfileId();
        
        DateTime completionDate = System.now(); 
        List<Case> updateCases = new List<Case>(); 
        Map<Id, Case> caseMap = new Map<Id, Case>();
        String mileStoneName = '';
        Set<String> mileStoneSet = new Set<String>();
        if(newCaseMap!=null && newCaseMap.size()>0){
            for(Case cs : newCaseMap.values())
            { if(cs.recordTypeId == recId_SFD_ProductType){
                if((cs.Status == 'Closed' || cs.Status == 'Rejected' || cs.Status == 'Withdrawn' || cs.Status == 'Re-directed') && (cs.SlaStartDate <= completionDate && cs.SlaExitDate == null)){
                    caseMap.put(cs.id, cs);
                    
                }
                
                
                if(cs.Stage__c=='Validate And Assign Order'){
                    mileStoneSet.add('Concierge Milestone');
                }else if(cs.Stage__c=='Detail Order'){
                    mileStoneSet.add('Post Concierge Milestone');
                }
            }
             
            }
            if (caseMap!=null && caseMap.size()>0){ 
                soc_MilestoneUtils.completeMilestone(caseMap, mileStoneSet, completionDate); 
            }    
        }
        
    }
    
    /*  Method Name ::  updateChildCaseStatus
*   EDGE-75358   ::  No Task to be created for Withdrawn, Rejected Status and Status Rules Changes
*   Developer Name::  Sandeep Soni
*   Description: Assign all child to requestor if parent is assigned to requestor and statu is withdrawn/closed/rejected
*
*/
    public static void updateChildCaseStatus(Map<ID,Case> oldCaseMap, Map<ID,Case> newCaseMap){ 
        
        Map<Id, Case> requestorCaseMap = new Map<Id, Case>();
        Set<String> sfdRequestIds = new Set<String>();
        Map<String,List<Case>> mapSFDParentChildList = new Map<String,List<Case>>();
        Map<Id, List<Task>> openTaskMap = soc_ParentChildBusinessRules.getAllOpenTaskByCase(newCaseMap);
        if(newCaseMap!=null && newCaseMap.size()>0){
            
            for(Case cs : newCaseMap.values())
            {
                if(cs.recordTypeId == recId_OrderRequest && (cs.stage__c == CASE_VALIDATE_AND_ASSIGN 
                                                             || cs.stage__c == CASE_DETAIL_ORDER) 
                   && oldCaseMap.get(cs.id).status != newCaseMap.get(cs.id).status){
                                                                                           requestorCaseMap.put(cs.id, cs);
                                                                                           sfdRequestIds.add(cs.id);    
                                                                                       }
            }
            
            if(sfdRequestIds!=null && sfdRequestIds.size()>0){
                mapSFDParentChildList = soc_ParentChildBusinessRules.prepareSFDProductParentChildMapByParentId(sfdRequestIds);
            }
            
            System.debug('requestorCaseMap::'+requestorCaseMap);
            
            if(requestorCaseMap != null && checkAllChildCaseBeforeUpdate(oldCaseMap,newCaseMap, mapSFDParentChildList, openTaskMap )){
                Map<Id, Case> childCaseMap = new Map<Id, Case>([SELECT Id, Status, OwnerId, soc_SFD_Sub_Status__c, ParentId From Case WHERE RecordTypeId = :recId_SFD_ProductType AND ParentId IN : requestorCaseMap.keySet()]);
                for(Case cs : childCaseMap.values()){
                    if(requestorCaseMap!=null && requestorCaseMap.containsKey(cs.ParentId)  && (requestorCaseMap.get(cs.ParentId).status == CASE_STATUS_WITHDRAWN
                                                                                       || requestorCaseMap.get(cs.ParentId).status == CASE_STATUS_REJECTED
                                                                                       ||  requestorCaseMap.get(cs.ParentId).status == CASE_STATUS_CLOSED)){
                            cs.Status = requestorCaseMap.get(cs.ParentId).status;  
                            cs.soc_SFD_Sub_Status__c = requestorCaseMap.get(cs.ParentId).soc_SFD_Sub_Status__c;
                            //cs.OwnerId = requestorCaseMap.get(cs.ParentId).Requestor__c; //Removed for P2OB-6411
                    }
                }
                System.debug('childCaseMap::'+childCaseMap);
                try{
                    if(childCaseMap!=null && childCaseMap.size()>0){
                        update childCaseMap.values();
                    }
                }
                catch(Exception e){
                    System.debug('Exception >>>>>>>>'+e);
                    System.debug('Exception >>>>>>>>'+e.getLineNumber());
                }
            } 
            
            
            
        }
        
    } 
    /*  Method Name ::  checkAllChildCaseBeforeUpdate
*   EDGE-75358   ::  No Task to be created for Withdrawn, Rejected Status and Status Rules Changes
*   Developer Name::  Sandeep Soni
*   Description: validate all child case before closing parent case.
*
*/
    public static Boolean checkAllChildCaseBeforeUpdate(Map<ID,Case> oldCaseMap, Map<ID,Case> updatedCaseMap,  Map<String,List<Case>> mapSFDParentChildList,  Map<Id, List<Task>> openTaskMap){
        
        Boolean isValidChildCases = true;
        
        for(Case cs : updatedCaseMap.values()){
            if(cs.RecordTypeId==recId_OrderRequest && 
               oldCaseMap.get(cs.id).status != updatedCaseMap.get(cs.id).status && 
               (updatedCaseMap.get(cs.id).stage__c ==  CASE_VALIDATE_AND_ASSIGN || updatedCaseMap.get(cs.id).stage__c == CASE_DETAIL_ORDER) 
              ){                
                  List<Case> childCase = new List<Case>();
                  if(mapSFDParentChildList!=null && mapSFDParentChildList.containsKey(cs.id)){
                      childCase = mapSFDParentChildList.get(cs.id); 
                  }
                  if((updatedCaseMap.get(cs.id).status != CASE_STATUS_WITHDRAWN && 
                      updatedCaseMap.get(cs.id).status != CASE_STATUS_REJECTED) && soc_ParentChildBusinessRules.checkAllChildCaseWithdrawnOrRejected(childCase)){
                          //if all child is withdrawn/rejected then parent should be withdrawn/rejected
                          updatedCaseMap.get(cs.id).addError(soc_RESTRICT_PARENTCASE_STATUS);
                          isValidChildCases =  false;
                      } 
                  else if(updatedCaseMap.get(cs.id).status==CASE_STATUS_CLOSED){
                      if(childCase!=null && childCase.size()>0 && !soc_ParentChildBusinessRules.checkChildCasesForParentClose(childCase)){
                          updatedCaseMap.get(cs.id).addError(soc_STR_UNCLOSED_PRODUCTS);
                          isValidChildCases =  false;
                      }
                      else if(openTaskMap!=null && openTaskMap.containsKey(cs.id)
                              && openTaskMap.get(cs.id)!=null && openTaskMap.get(cs.id).size()>0){
                                  //EDGE-57850 :: Task Creation and Closure
                                  updatedCaseMap.get(cs.id).addError(soc_STR_TASK_OPEN_PARENTCASE_CLOSE);
                                  isValidChildCases =  false;
                              }      
                  }
              }
        }
        return isValidChildCases;
    }
    
}