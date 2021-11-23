/*****************************************************************************
@Author: Kritika Bhati 
@CreateDate: 15 Jan 2018
@ModifiedByandDate:  Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
@Description: This class contains logic to change owner of parent case to 
the last child case(that is getting assigned to Detailer/Specialist/CTS) . 
@References
Epic :EDGE- 57480: Parent Case Ownership
Story:EDGE-40183

*******************************************************************************/
public without sharing class soc_ParentCaseOwnerService {
    
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    @InvocableMethod
    public static void handleRequest(List<Id> workItemIds) {
        System.debug('Enter in soc_ParentCaseOwnerService');
        system.debug(workItemIds);
        if(workItemIds != null && workItemIds.size() > 0){
            if(String.valueOf(workItemIds[0].getSobjectType())=='Case'){
                updateParentOwner(workItemIds);
            }
        }
    }
  
    public static void updateParentOwner(List<Id> caseIdList){
           
        Map<Id,Case> parentCaseChilOwnerMap = new Map<Id, Case>();
        List<Case> lstCase = new List<Case>();
        for(Case cs: [Select Id, ParentId, RecordType.DeveloperName, soc_isParentOwner__c, soc_Case_Owner_Type__c, 
                           ownerId, RecordTypeId, soc_Process_Start_Time__c
                      FROM Case 
                      WHERE Id IN:caseIdList]){
            if(cs.RecordTypeId == recId_SFD_ProductType){
                parentCaseChilOwnerMap.put(cs.ParentId, cs);
                //For story EDGE-68486 by Preeti Malik
                if(cs.soc_Case_Owner_Type__c == 'Simplex Queue' || cs.soc_Case_Owner_Type__c == 'Complex Queue'){
                        cs.soc_Process_Start_Time__c = System.now();
                    }
            }
            lstCase.add(cs);
        }
        /*for cycle report update caseownertype field*/
        if(lstCase!=null){
            lstCase = soc_CaseCycleAcceptanceReport.updateCaseOwnerType(lstCase);
            update lstCase;
        }
        if(parentCaseChilOwnerMap.size() > 0){
           
            updateParentCaseOwner(parentCaseChilOwnerMap);
            System.debug('**HELLOAgent**');
        }
    }
    public static void updateChildCountOnParent(List<Id> parCaseId){
        System.debug('<<<<Inside updateChildCountOnParent>>>>>>>>');
        List<Case> updateParentCase = new List<Case>();
        for(Case parCase: [Select Id, Child_Case_Count__c, (Select Id, OwnerId from Cases) from Case where Id IN: parCaseId]){
            parCase.Child_Case_Count__c = parCase.Cases.size();
            updateParentCase.add(parCase);
        }
        if(updateParentCase.size()  > 0){
            update updateParentCase;
        }
    }
    //Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
    public static void updateParentCaseOwner(Map<Id, Case> parentCaseChilOwnerMap){
        System.debug('**hello1Service**'); 
         
         Map<Id, User> caseOwnerProfileIdMap = new Map<Id, User>();
        List<Case> parentCaseToUpdate = new List<Case>(); // Update Parent case Owner
        List<Case> childCaseToUpdate = new List<Case>(); // Update the field isParentowner on last child case
        for(Case parCase: [Select Id, OwnerId, Stage__c, Child_Case_Count__c, soc_Process_End_Time__c, soc_Process_Start_Time__c,
                           soc_SFD_Case_Assignment_Time__c, soc_Assignment_OnHold_Total_Time__c, soc_SLA_Exceeded__c, BusinessHoursId
                           FROM Case 
                           WHERE Id IN:parentCaseChilOwnerMap.keySet()]){
                               System.debug('**hello1Service**');
                               if(parCase.Child_Case_Count__c == 1){ //last child case getting assigned to D/S/CTS
                                   parCase.OwnerId = parentCaseChilOwnerMap.get(parCase.Id).OwnerId;
                                   parCase.Stage__c = 'Detail Order';
                                   parCase.Child_Case_Count__c = 0;
                                   parCase.soc_Process_End_Time__c = System.now();
                                   if(parCase.BusinessHoursId != null)
                                   parCase.soc_SFD_Case_Assignment_Time__c = soc_CaseCycleAcceptanceReport.getBusinessHours(parCase.soc_Process_Start_Time__c, parCase.soc_Process_End_Time__c, parCase.BusinessHoursId);//processMinutes - cs.Acceptance_OnHold_Total_Time__c;
                                   if(parCase.soc_SFD_Case_Assignment_Time__c==null){
                                       parCase.soc_SFD_Case_Assignment_Time__c = 0;
                                   }
                                   if(parCase.soc_Assignment_OnHold_Total_Time__c==null){
                                       parCase.soc_Assignment_OnHold_Total_Time__c = 0;
                                   }
                                   parCase.soc_SFD_Case_Assignment_Time__c = ((parCase.soc_SFD_Case_Assignment_Time__c - (parCase.soc_Assignment_OnHold_Total_Time__c*60))/60.0).setScale(2);
                                    
                                   Decimal businessTime = 0;
                                   businessTime = soc_CaseCycleAcceptanceReport.getBusinessTimeUnit('Case Assignment');
                                   if((parCase.soc_SFD_Case_Assignment_Time__c*60) > businessTime){
                                       if(parCase.soc_SLA_Exceeded__c=='Acceptance'){
                                            parCase.soc_SLA_Exceeded__c = parCase.soc_SLA_Exceeded__c+';'+'Assignment';
                                       }else{
                                            parCase.soc_SLA_Exceeded__c = 'Assignment';
                                       }
                                       System.debug('parCase.soc_SLA_Exceeded__c'+parCase.soc_SLA_Exceeded__c);
                                            parCase.soc_Process_Start_Time__c = System.now();
                                        }
                                   parentCaseToUpdate.add(parCase);
                                   childCaseToUpdate.add(parentCaseChilOwnerMap.get(parCase.Id));
                                   
                               }
                               else if(parCase.Child_Case_Count__c == 0){
                                   if(parentCaseChilOwnerMap.get(parCase.Id).soc_isParentOwner__c){
                                       parCase.OwnerId = parentCaseChilOwnerMap.get(parCase.Id).OwnerId;
                                       parentCaseToUpdate.add(parCase);
                                   }
                               }
                               else {
                                   if(parCase.Child_Case_Count__c==null){
                                       parCase.Child_Case_Count__c = 0;
                                   }
                                   parCase.Child_Case_Count__c = parCase.Child_Case_Count__c - 1;
                                   parentCaseToUpdate.add(parCase);
                               }     
                           }
        if(parentCaseToUpdate.size() > 0){
            update parentCaseToUpdate;
        }
        if(childCaseToUpdate.size() > 0){
            for(Case cs: childCaseToUpdate){
                cs.soc_isParentOwner__c = true;
            }
            update childCaseToUpdate;
        }
        
        
    }
    public static void updateParentCaseOwnerDir(Map<Id, Case> parentCaseChilOwnerMap){
        List<Case> parCaseToUpdate = new List<Case>();
        for(Case parCase: [Select Id, OwnerId from Case
                           WHERE Id IN:parentCaseChilOwnerMap.keyset()]){
                               parCase.OwnerId = parentCaseChilOwnerMap.get(parCase.Id).OwnerId;
                               parCaseToUpdate.add(parCase);
                           }
        if(parCaseToUpdate.size() > 0){
            update parCaseToUpdate; 
        }
    }
     //Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
    public static void updateParentOwnerAndCount(Map<Id, Case> parentCaseChilOwnerMap){
           
        List<Case> parentCaseToUpdate = new List<Case>();
        List<Case> childCaseToUpdate = new List<Case>();
        for(Case parCase: [Select Id, OwnerId, Child_Case_Count__c, soc_Process_End_Time__c, soc_Process_Start_Time__c,
                           soc_SFD_Case_Assignment_Time__c, soc_Assignment_OnHold_Total_Time__c, soc_SLA_Exceeded__c,
						   BusinessHoursId                           
                           from Case
                           WHERE Id IN:parentCaseChilOwnerMap.keyset()]){
                               if(parCase.Child_Case_Count__c == 1){ //last child case getting assigned to D/S/CTS
                                   parCase.OwnerId = parentCaseChilOwnerMap.get(parCase.Id).OwnerId;
                                   parCase.Stage__c = 'Detail Order';
                                   parCase.Child_Case_Count__c = 0;
                                   parCase.soc_Process_End_Time__c = System.now();
                                   if(parCase.BusinessHoursId != null)
                                   parCase.soc_SFD_Case_Assignment_Time__c = soc_CaseCycleAcceptanceReport.getBusinessHours(parCase.soc_Process_Start_Time__c, parCase.soc_Process_End_Time__c, parCase.BusinessHoursId);//processMinutes - cs.Acceptance_OnHold_Total_Time__c;
            					   parCase.soc_SFD_Case_Assignment_Time__c = ((parCase.soc_SFD_Case_Assignment_Time__c - (parCase.soc_Assignment_OnHold_Total_Time__c*60))/60.0).setScale(2);
                                   Decimal businessTime = 0;
                                   businessTime = soc_CaseCycleAcceptanceReport.getBusinessTimeUnit('Case Assignment');
                                   if((parCase.soc_SFD_Case_Assignment_Time__c*60) > businessTime){
                                            //parCase.soc_SLA_Exceeded__c = 'Assignment';
                                            if(parCase.soc_SLA_Exceeded__c=='Acceptance'){
                                                parCase.soc_SLA_Exceeded__c = parCase.soc_SLA_Exceeded__c+';'+'Assignment';
                                            }else{
                                                parCase.soc_SLA_Exceeded__c = 'Assignment';
                                            }
                                       System.debug('parCase.soc_SLA_Exceeded__c::'+parCase.soc_SLA_Exceeded__c);
                                       		parCase.soc_Process_Start_Time__c = System.now();
                                        }
                     
                                   parentCaseToUpdate.add(parCase);
                                   childCaseToUpdate.add(parentCaseChilOwnerMap.get(parCase.Id));
                               }
                               else{
                                   if(parCase.Child_Case_Count__c != 0 && parCase.Child_Case_Count__c!=null){
                                       parCase.Child_Case_Count__c = parCase.Child_Case_Count__c - 1;
                                       parentCaseToUpdate.add(parCase);
                                   }
                               }
                           }
        if(parentCaseToUpdate.size() > 0){
            update parentCaseToUpdate;
        }
        if(childCaseToUpdate.size() > 0){
            for(Case cs: childCaseToUpdate){
                cs.soc_isParentOwner__c = true;
            }
        }
    }
    
    
    public static void changeParentOwnerOnChildClose(List<Id> parentIds){
        List<Case> parCaseList = new List<Case>();
        List<Case> chiCaseList = new List<Case>();
        for(Case parCase : [Select Id, OwnerId, soc_isParentOwner__c, (Select Id, OwnerId, soc_isParentOwner__c from Cases where Status != 'Closed') from Case where Id IN: parentIds]){
            if(parCase.Cases.size() > 0){
                if(parCase.Cases.size() >0 ){
                    parCase.OwnerId = parCase.Cases[0].ownerId;
                    parCaseList.add(parCase);
                    chiCaseList.add(parCase.Cases[0]);
                }
            }
        }
        if(parCaseList.size() > 0){
            update parCaseList;
        }
        
        if(chiCaseList.size() > 0){
            for(Case chiCases: chiCaseList){
                chiCases.soc_isParentOwner__c = true;
            }
            update chiCaseList;
        }
    }
    
    
   
}