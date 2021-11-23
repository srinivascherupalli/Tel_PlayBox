/*
  =====================================================================================================================================================
Sr.No.    Developer Name      Date                 Story                     Description
1.        Sandeep Soni/       1 April 2020        P2OB-5710                 changes for firing assignment rule for Telstra.com site users
          Shreyansh Sharma
2.        Shubhi            31/05/2020/17/06/2021            EDGE-216407              If QLIs are not processed by Case Inv MS for the Billing Enquiry case and user tries to progress the stage, then restrict that progression 
                    
3.          Shreyansh Sharma        5/20/2021(Jaipur)      P2OB-14430                       As a system map the products value found from Einstein Data set against a 
                                                                                                 service number to the product picklist for Enterprise billing (Internal Billing Tile)- Configuration  
4.        Shubhi            31/05/2020/17/06/2021           DIGI-13373             If QLIs are not processed by Case Inv MS for the Billing Enquiry case and user tries to progress the stage, then restrict that progression 

=====================================================================================================================================================
*/

public with sharing class CaseTriggerHelper {
    
    public static String recId_ChannelCareWorkOrder = workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_Bulk_Request').getRecordTypeId();
    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public static void runAssignmentRule(list<case> cases){
        
        //Modified SOQL to exclude cases of Record Type "Order Request"
        //Reason : SOC Project
        //Modified By : Noor Ali
        //Modified Date : 18-Jul-2018
        //Modified Date: 24/10/2018 : Refactored code to use minimal SOQL queries
        //For Record Type Label CHange
        
        //Modified By: Sandeep Soni
        //Modified Date: 10 Feb 2020
        //Reason: Added Mobile MAC support record type so assignment rule will not run for this recordtype(Ref: Story: P2OB-3672).

        //Modified By: Nilima Borse
        //Modified Date: 22 April 2020
        //Reason: Added COVID-19 Financial Hardship record type so assignment rule will not run for this recordtype(Ref: Story: P2OB-5936).
       /* set<string> recordTypeDevNames = new set<String>{'Fulfillment','cusdl_Custom_Deal','Order_request','soc_Support_Request', 'IR_Issue_Register','soc_SFD_Product', 
'srvsup_Service_Management', 'srvsup_Service_Support','salesup_Sales_Child_Support','salesup_Sales_Support','mm_Mobile_Support_Request','CPE_Requests','COVID_19_Financial_Hardship'}; */ 

       
        //Modified By: Team Alexandria
        //Added Insolvency_Management record type so assignment rule will not run for this recordtype
        //Added Record type names in custom metadata Case_Record_Types__mdt to avoid hardcoding
        list<Case_Record_Types__mdt> custMeta =  [Select id, recordTypeDevNames__c from Case_Record_Types__mdt];
        system.debug('@@@@@'+custMeta);
        list<string> recordTypeDevNames = new list<string>();
        for(Case_Record_Types__mdt c :custMeta){
            recordTypeDevNames.add(c.recordTypeDevNames__c);
        }               
                
        list<case> updateList=[select id from case where id IN:cases and RecordType.DeveloperName NOT IN : recordTypeDevNames];                       
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        dmo.EmailHeader.triggerUserEmail = true;
        system.debug('#####'+updateList);
        database.update(updateList,dmo);
        
    }

        /*
    Jaipur :: Chandrakant
    Sprint & US: 21.08 & P2OB-13762
    Description: 21.08 & P2OB-13762 : Map Additional Skill set to NEW case based on related account Offshore restricted flag
    */    
    public static void setAdditionalSkillSetNewRecord(List<Case> newCases){        
        if(newCases != null && newCases.size() > 0){
             for(Case cs : newCases){
                 // checking record type and related account offshore flag
                 if(cs.RecordTypeid == recId_salesSupportChild){                    
                     if(cs.Account.APTPS_Off_Shore_Restricted__c == true){                        
                         cs.cpe_CPE_Skills_Set__c = 'Billing Non-Consenting';
                     }
                     else{
                         cs.cpe_CPE_Skills_Set__c = 'Billing Consenting';
                     }
                 }        
             }
         }   
     }
 
     /*
     Jaipur :: Chandrakant
     Sprint & US: 21.08 & P2OB-13762
     Description: 21.08 & P2OB-13762 : Map Additional Skill set to EXISTING case based on Offshore restricted flag
     */    
     public static void setAdditionalSkillSetExistingRecord(List<Case> newCases, Map<ID,Case> oldCaseMap){
         
         if(newCases != null && newCases.size() > 0){
             List<Id> caseOwnerIds = new List<Id>();
             for(Case cs : newCases){
                 caseOwnerIds.add(cs.ownerId);
             }
             //Query on Group object to get queue developername for comparison
             List<Group> QueueNames = [select id,developername from group where id IN :caseOwnerIds];           
 
             //Map with caseOwnerId and caseOwner queue developer name pairs
             Map<Id,String> newCaseOwnerMap = new Map<Id, String>();
             for(Group gr: QueueNames){
                 newCaseOwnerMap.put(gr.id, gr.developername);
             }
 
             for(Case cs : newCases){
                 // checking case owner is Queue and owner/offshore flag modified
                 if(!oldCaseMap.isEmpty() && String.valueOf(cs.OwnerId).startsWith('00G') 
                 && Label.EBQueues.contains(newCaseOwnerMap.get(cs.OwnerId))
                 && ((cs.OwnerId !=  oldCaseMap.get(cs.Id).OwnerId)
                 || (cs.soc_SFD_Offshore_Restricted__c != oldCaseMap.get(cs.Id).soc_SFD_Offshore_Restricted__c))){ 
                     if(cs.soc_SFD_Offshore_Restricted__c == true){
                         cs.cpe_CPE_Skills_Set__c = 'Billing Non-Consenting';
                     }
                     else{
                         cs.cpe_CPE_Skills_Set__c = 'Billing Consenting';
                     }
                 }
             }
         }
     }
     
    /*
    Jaipur :: Chandrakant
    Sprint & US: 21.08 & P2OB-13762
    Description: 21.08 & P2OB-13762 : Set case owner based on offshore flag for enterprise billing cases 
    */    
    public static void handleDefaultCaseSkill(List<Case> newCases, Map<ID,Case> oldCaseMap){

        if(newCases != null && newCases.size() > 0){
            try{
                Map<String,Id> queueMap = new Map<String,id>();
                
                //retrieving the queue api name from custom metadata
               String cpeOrderingHardwareQueue = Case_Default_Skill_Matrix__mdt.getInstance('S001').Routing_Queue__c;
                String enterpriseMobileSupport = Case_Default_Skill_Matrix__mdt.getInstance('S002').Routing_Queue__c;
        String enterpriseMobileSupportPriority = Case_Default_Skill_Matrix__mdt.getInstance('S003').Routing_Queue__c;
        String consetingQueueName = Case_Default_Skill_Matrix__mdt.getInstance('S004').Routing_Queue__c;
                String nonConsetingQueueName = Case_Default_Skill_Matrix__mdt.getInstance('S005').Routing_Queue__c;
                String enterpriseBillingQueue = Case_Default_Skill_Matrix__mdt.getInstance('S004').Queue__c;
                String cpeOrderingHardware = Case_Default_Skill_Matrix__mdt.getInstance('S001').Queue__c;
                String enterpriseMobileSupportQueue = Case_Default_Skill_Matrix__mdt.getInstance('S002').Queue__c;
                String enterpriseMobileSupportPriorityQueue = Case_Default_Skill_Matrix__mdt.getInstance('S003').Queue__c;
                
                
        Id cpeRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CPE_Requests').getRecordTypeId();
               Id mobileSupportRecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('mm_Mobile_Support_Request').getRecordTypeId();
   
                List<String> queueNames = new List<String>{enterpriseBillingQueue,cpeOrderingHardware,enterpriseMobileSupportQueue,
                            enterpriseMobileSupportPriorityQueue,consetingQueueName,nonConsetingQueueName,
                             cpeOrderingHardwareQueue,enterpriseMobileSupport,enterpriseMobileSupportPriority};
                
                List<Group> queueList = [select Id,name,developerName from Group where Type = 'Queue' AND developerName IN :queueNames];
                
                if(queueList.size()>0){
                    for(Group grup:queueList){                    
                        queueMap.put(grup.developerName,grup.id);
                    }
                }
                if(newCases.size()>0)
                {
                    for(Case cs : newCases)
                    {
                        //P2OB-13762 set case owner based on offshore flag for enterprise billing cases                    
                        if(!oldCaseMap.isEmpty() && cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId 
                        && cs.OwnerId == queueMap.get(enterpriseBillingQueue) && String.isBlank(cs.ss_billing_Product__c)){
                            system.debug('ecase ss_billing_Product >' +cs.ss_billing_Product__c);
                            if(cs.soc_SFD_Offshore_Restricted__c == true){
                                cs.OwnerId = queueMap.get(consetingQueueName);
                            }
                            else{
                                cs.OwnerId = queueMap.get(nonConsetingQueueName);
                            }
                        }
                            //P2OB-14367, Shreyansh Sharma
                            //fix for Cases routing randomly when no user is logged in with the required skill - Customization
                        else if(cs.RecordTypeId != cpeRecordTypeId && cs.Origin !='Email' && !oldCaseMap.isEmpty() && cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId &&
                                cs.OwnerId == queueMap.get(cpeOrderingHardware) && ((cs.salesup_Support_Type__c != 'CPE Hardware And Services') || 
                                                                                         ((cs.salesup_Support_Type__c == 'CPE Hardware And Services') &&
                                                                                          (cs.salesup_Work_Required__c == NULL || cs.salesup_Work_Required__c==''))) ||
                                cs.RecordTypeId == cpeRecordTypeId && cs.Origin !='Email' && !oldCaseMap.isEmpty() && cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId &&
                                cs.OwnerId == queueMap.get(cpeOrderingHardware) && ((cs.salesup_Support_Type__c != 'CPE Hardware And Services') || 
                                                                                         ((cs.salesup_Support_Type__c == 'CPE Hardware And Services') &&
                                                                                          (cs.salesup_Work_Required__c == NULL || cs.salesup_Work_Required__c=='')))){
                                                                                             
                                   cs.OwnerId = queueMap.get(cpeOrderingHardwareQueue);
                              }
                        else if(cs.RecordTypeId != mobileSupportRecordTypeId && !oldCaseMap.isEmpty() && cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId &&
                                (cs.OwnerId == queueMap.get(enterpriseMobileSupportQueue) || cs.OwnerId == queueMap.get(enterpriseMobileSupportPriorityQueue)) && 
                                ((cs.salesup_Support_Type__c != 'Mobile Support Requests') || ((cs.salesup_Support_Type__c == 'Mobile Support Requests') &&
                                                                                          (cs.salesup_Work_Required__c == NULL || cs.salesup_Work_Required__c==''))) ||
                                cs.RecordTypeId == mobileSupportRecordTypeId && !oldCaseMap.isEmpty() && cs.OwnerId != oldCaseMap.get(cs.Id).OwnerId &&
                                (cs.OwnerId == queueMap.get(enterpriseMobileSupportQueue) || cs.OwnerId == queueMap.get(enterpriseMobileSupportPriorityQueue)) && 
                                ((cs.salesup_Support_Type__c != 'Mobile Support Requests') || ((cs.salesup_Support_Type__c == 'Mobile Support Requests') &&
                                                                                          (cs.salesup_Work_Required__c == NULL || cs.salesup_Work_Required__c=='')))){
                                                                                             
                                   cs.OwnerId = queueMap.get(enterpriseMobileSupport);
                              }
                            
                    }
               }
            }
            catch(Exception e){
                System.debug('ExceptionMessage '+e.getMessage());
            }
        }
    }

    /*
Melbourne :: Chandrakant
Sprint & US: 20.11 & P2OB-5217
Description: 20.11 & P2OB-5217 :   Throws error if Bulk case is approved without selecting Bulk Case Type.
Description: 20.17 & P2OB-9583 :   Modified Bulk Case Criteria.
*/    
    public static void checkBulkCaseTypeSelected(List<Case> newCases, Map<ID,Case> oldCaseMap){
        
        String errorMsg = Label.BulkCaseTypeRequiredError;
        if(newCases != null && newCases.size() > 0){
            for(Case cs : newCases){
                // checking bulk approved field modified or not
                if(cs.RecordTypeid == recId_salesSupportChild && cs.salesup_isBulkApproved__c != oldCaseMap.get(cs.Id).salesup_isBulkApproved__c){
                    if(cs.salesup_No_of_sites_or_services__c > 30 && string.isBlank(cs.salesup_Bulk_Case_Type__c)){
                        cs.addError(errorMsg);
                    }
                }       
            }
        }    
    }
    /*
Melbourne :: Sanjay Thakur
Sprint & US: 20.11 & P2OB-8345
Description: 20.11 & P2OB-8345 : If any Work order is not closed and ((case status is set to close, withdraw or rejected) or (Case Stage is moved to next Stage) or (Bulk Case Type is modified)) throw error
*/    
    public static void checkWorkOrderStatus(List<Case> newCases, Map<ID,Case> oldCaseMap){
        String varCloseStatus = 'Closed';
        String varWithdrawnStatus = 'Withdrawn';
        String varRejectedStatus = 'Rejected';
        String errorMsg = Label.OpenWorkOrderError;
        Case oldChannelCareCase = new Case();
        List<WorkOrder> WODetails = new List<WorkOrder>();
        Map<String, Case> mapCaseToId = new Map<String,Case>();
        if(newCases != null && newCases.size() > 0){
            for(Case cse : newCases) {
                oldChannelCareCase = oldCaseMap.get(cse.id);
                // Checking Case Status, Stage and Bulk Request Type
                if(cse.RecordTypeid == recId_salesSupportChild && ((cse.Status == varCloseStatus || cse.Status == varWithdrawnStatus || cse.Status == varRejectedStatus) || (oldChannelCareCase.Stage__c != cse.Stage__c) || (oldChannelCareCase.salesup_Bulk_Case_Type__c != cse.salesup_Bulk_Case_Type__c))){
                    mapCaseToId.put(cse.Id, cse);
                }
            }
        }
        //Fetch Open Work Order details 
        WODetails = [SELECT wo.id,wo.CaseId,wo.Status FROM WorkOrder wo WHERE wo.RecordTypeId =: recId_ChannelCareWorkOrder AND wo.CaseId IN:mapCaseToId.keySet() AND wo.Status NOT IN ('Closed','Withdrawn','Rejected')];
        if(WODetails != null && WODetails.size() >0){
            for(WorkOrder wo : WODetails){
                Case csewo = mapCaseToId.get(wo.CaseId);
                csewo.addError(errorMsg);
                
            }
            }
        }


       /*
    Melbourne :: Chandrakant
    Sprint & US: 20.15 & P2OB-10425
    Description: 20.15 & P2OB-10425 :   Update CaseMilestone completion date if case is closed
    */    
    public static void updateCaseSlaMilestone(List<Case> newCases){

        String varCloseStatus = 'Closed';
        String varWithdrawnStatus = 'Withdrawn';
        String varRejectedStatus = 'Rejected';
        list<Case> closedCaseList = new List<Case>();
        Map<String, Case> mapCloseCaseToId = new Map<String,Case>();

        if(newCases != null && newCases.size() > 0){
            for(Case cse : newCases) {
                // Checking Case Status, Stage and Bulk Request Type
                if(cse.RecordTypeid == recId_salesSupportChild && (cse.Status == varCloseStatus || cse.Status == varWithdrawnStatus || cse.Status == varRejectedStatus)){
                   mapCloseCaseToId.put(cse.id, cse);
            }
    }
    
        //Fetch CaseMilestone details
        List<CaseMilestone> cmList = [Select id,caseid, IsCompleted,CompletionDate from casemilestone where caseid IN:mapCloseCaseToId.keySet()];
 
        if(cmList !=null && cmList.size() > 0){
            for(CaseMilestone csMilestone : cmList) {
                csMilestone.CompletionDate = system.now();
            }
            update cmList;
        }   
    }
  } 
    
    /**
EDGE        -198374 
Method Name -notifyCaseOwnerOnCaseClose
Description -Notify Case Owners on case close.  
Author      -Nikhil Kumar
    **/    
    public static void notifyCaseOwnerOnCaseClose(List<case> newCases,Map<id,case> oldCaseMap){
       
        String recordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;
        
        List<FeedItem> feedItemsList = new List<FeedItem>();
        
         try{
            for(Case cs: newCases){
                
                Case oldCaseRec = oldCaseMap == null ? null : oldCaseMap.get(cs.Id);
                
                if(cs.status != oldCaseRec.status && cs.status.equalsIgnoreCase('Closed') && cs.Recordtypeid == recordtypeid){
                    FeedItem post = new FeedItem();
                    post.ParentId = cs.createdbyid;
                    string caseNumber = cs.caseNumber;
                    post.Body = system.label.Feedback_chatter_response1 +' '+ caseNumber +' '+system.label.Feedback_chatter_response;
                    feedItemsList.add(post); 
                }
            }
        
       
            if(!feedItemsList.isEmpty()){
                insert feedItemsList;
            }
        }
        catch(Exception ex){
            system.debug('Exception occured in CaseTriggerHelper Class at line number '+ex.getLineNumber()+' due to '+ex.getMessage());
      }        
    }

/*
    Jaipur :: Pravin
    Sprint & US: 21.06 & P2OB-14113
    Description: Add Requester to Case Team as happening in existing Request Support case creation
    */   
    public static void addRequestorAsCaseTeamMember(Map<Id,Case> newCaseMap){
        
        String recId_ChannelCare = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        String recId_ServiceSupport = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
        
        if(newCaseMap == null || newCaseMap.size() == 0)
      return;            
        
        // get only channel care and Service Support new UI/UX cases only
        Map<Id,Case> mapChannelServiceCase = new Map<Id,Case>([Select Id,ss_Type__c,ss_Category__c,ss_Work_Required__c,OwnerId,Owner.Type,Owner.ProfileId,Owner.Profile.Name,Origin,RecordTypeId From Case Where Id IN :newCaseMap.keySet() AND (RecordTypeId = :recId_ChannelCare OR RecordTypeId = :recId_ServiceSupport) 
                                                      AND ss_Type__c != '' AND ss_Category__c != '' AND ss_Work_Required__c != '']);
        
        if(mapChannelServiceCase.size() == 0)
          return;
        
        // created set of case Owners when Owner.Type = user only
    Set<Id> setCaseOwner = new Set<Id>();
        if(mapChannelServiceCase != null && mapChannelServiceCase.size() > 0){
            for(Case newCase : mapChannelServiceCase.values()){
                if(newCase.OwnerId != null && String.valueOf(newCase.OwnerId).startsWith('005')){
                  setCaseOwner.add(newCase.OwnerId);    
                }
            }
        }
        
        if(setCaseOwner.size() == 0)
            return;
        
        // get all the users which should be standard users and not belong to Integration profile and for given set of case Owners only
        Map<Id,User> mapstandardUser = new Map<Id,User>([Select Id,UserType,Profile.Name From User Where UserType = 'Standard' AND Profile.Name != 'Integration - TConnect' AND Id IN :setCaseOwner]); 
              
        Id roleId = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1].Id;
        
        List<CaseTeamMember> lstCaseTeamMembersToInsert = new List<CaseTeamMember>();
       
        // Check cases are not from Telstra.com and from Email2Case and Owner should be user only
        if(mapChannelServiceCase != null && mapChannelServiceCase.size() > 0){
            for(Case newCase : mapChannelServiceCase.values()){
                if(String.valueOf(newCase.OwnerId).startsWith('005') && newCase.Origin != 'Telstra.com' && newCase.Origin != 'Email'
                   && mapstandardUser!= null && mapstandardUser.containsKey(newCase.OwnerId)){
                       CaseTeamMember newMember=new CaseTeamMember(ParentId = newCase.Id, MemberId = newCase.OwnerId, TeamRoleId = roleId);
                       lstCaseTeamMembersToInsert.add(newMember);    
                   }
            }
        }
            
        
       // insert case Team member with read access
        if(lstCaseTeamMembersToInsert.size() > 0)
            upsert lstCaseTeamMembersToInsert;
      
    }    

    
    /**
    EDGE        -216407
    Method Name -validateQLIProcessed
    Description -If QLIs are not processed by Case Inv MS for the Billing Enquiry case 
                    and user tries to progress the stage, then restrict that progression 
    Author      -Shubhi Vijayvergia
    team:       Colombo
    **/ 
    public static void validateQLIProcessed(List<case> newCases,Map<id,case> oldCaseMap){
        Map<string,SharedDisplayMessage__c>errorDisplaySet=SharedDisplayMessage__c.getAll();
        String recIdBillingEnquiry = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId(); 
        String billingenquiryRecordtype='';
        List<String> caseStatusList=new List<String>{'Obtaining Internal Approval','Closed','Escalated','Resolved'};  // DIGI-13373 
        Map<String,Boolean> caseIdToQliNotProeesedmap=new Map<String,Boolean>();

        if(newCases != null && !newCases.isEmpty() && oldCaseMap!=null && !oldCaseMap.isEmpty()){
            caseIdToQliNotProeesedmap=CaseTriggerHelper.isAllQLIprocessedbyMS(oldCaseMap.keySet());
            for(Case cs : newCases){
                if(cs.recordtypeId==recIdBillingEnquiry && oldCaseMap.containskey(cs.id) && oldCaseMap.get(cs.id).status !=cs.status && caseStatusList.contains(cs.status)){
                    if(caseIdToQliNotProeesedmap!=null && caseIdToQliNotProeesedmap.containskey(cs.id) && caseIdToQliNotProeesedmap.get(cs.id)){
                        if(errorDisplaySet!=null && !errorDisplaySet.isEmpty() && errorDisplaySet.containskey('case ms validation')){
                            cs.addError(errorDisplaySet.get('case ms validation').value__c); 
                        }
                    }
                }
            }
        }

    }
    /**
    EDGE        -216407
    Method Name -isAllQLIprocessedbyMS
    Description -checking qli that are not processed by MS
    Author      -Shubhi Vijayvergia
    team:       Colombo
    **/ 
    private static Map<String,Boolean> isAllQLIprocessedbyMS(Set<Id> caseIdSet){
        Map<String,Boolean> caseIdToQliNotProeesedmap=new Map<String,Boolean>();
        if(caseIdSet!=null && !caseIdSet.isEmpty()){
            for(Queried_Line_Item__c qli:Model_QueriedLineItems.getQLINotProcessedByMs(caseIdSet)){
                caseIdToQliNotProeesedmap.put(qli.Case__c,true);
            }
        }
        return caseIdToQliNotProeesedmap;
    }
}