/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 04/03/2018
@ModifiedByandDate: 
@Description: This class is for CycleCaseAcceptance Report
*******************************************************************************/ 
public class soc_CaseCycleAcceptanceReport { 
    
    public static String  STAGE_REQUESTREVIEW = 'Request Review';
    public static String  STAGE_VALIDATEANDASSIGN = 'Validate And Assign Order';
    public static String  CASEOWNERTYPE_REQUESTER = 'Requester';
    public static String  CASEOWNERTYPE_CONCIERGE = 'Concierge';
    public static String  CASEOWNERTYPE_CONCIERGEQUEUE = 'Concierge Queue';
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
  
    /*
* Method Name: getBusinessTimeUnit
* Input Parameter:  String SLAExceededType, Decimal SLAExceedTotalTime
* Output Parameter: Decimal
* Description: This method will take exceeded Type like Acceptance, Assignment and will return the time unit(hh/mm/ss), 
* Exceeded Time(8/3).
* Created By:   Sandeep Soni
* Create Date:  06 March 2019
*/
    
    public static Decimal getBusinessTimeUnit(String SLAExceededType){
        Map<String, soc_SFD_Case_Business_Time__c> caseBusinessTimeMap = soc_SFD_Case_Business_Time__c.getAll();
        Decimal sfdTime = 0;
        If(caseBusinessTimeMap!=null && caseBusinessTimeMap.containsKey(SLAExceededType)){ 
            soc_SFD_Case_Business_Time__c sfdCaseBusinessTime =  caseBusinessTimeMap.get(SLAExceededType); 
            if(sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time__c!=null){
                if(sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time_Type__c=='hh'){
                    sfdTime = (sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time__c * (60*60));
                }else if(sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time_Type__c=='mm'){
                    sfdTime = (sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time__c * 60);
                }else if(sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time_Type__c=='ss'){
                    sfdTime = (sfdCaseBusinessTime.soc_SFD_Case_Acceptance_Time__c);
                }        
            }
            
        }
        return sfdTime;
    }
    /*
* Method Name: sfdCaseAcceptanceTimeReport
* Input Parameter:  Case cs, Map<Id, Case> oldCaseMap, DateTime currentDate
* Output Parameter: void
* Description: For SFD Case Acceptance Time Report: This method will update all case fields(Process_Start_Time__c,Process_End_Time__c,
* Concierge_First_Allocation__c,OnHold_Start_Time__c, OnHold_End_Time__c,Acceptance_OnHold_Total_Time__c,
* SFD_Case_Acceptance_Time__c,SLA_Exceeded__c) whenever user moves from one step to another.
* Created By:   Sandeep Soni
* Create Date:  04 March 2019
*/
    public static void sfdCaseAcceptanceTimeReport(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap, DateTime currentDate,  Map<Id, User> caseOwnerProfileIdMap, Map<String,Id> businessHRSMap){
        Id businessHrsId = null; 
        System.debug('businessHRSMap>>' + businessHRSMap);
        Decimal onHoldSeconds = 0;     
        for(Case cs : newCaseMap.values()){
            if(cs.recordTypeId==recId_OrderRequest){
                //Updating onHoldStartTime of parent case
                if(oldCaseMap.get(cs.id).soc_Case_Owner_Type__c == CASEOWNERTYPE_CONCIERGE && cs.soc_Case_Owner_Type__c == CASEOWNERTYPE_REQUESTER){ 
                    cs.soc_OnHold_Start_Time__c = currentDate;
                    System.debug('old case::'+oldCaseMap.get(cs.id));
                    System.debug('caseOwnerProfileIdMap::'+caseOwnerProfileIdMap+'~~oldcaseownerId::'+oldCaseMap.get(cs.id).ownerId+' new caseownerId:'+cs.ownerId);
                    if(businessHRSMap!=null && caseOwnerProfileIdMap!=null && caseOwnerProfileIdMap.containsKey(oldCaseMap.get(cs.id).ownerId)){
                        String userTimeZone = caseOwnerProfileIdMap.get(oldCaseMap.get(cs.id).ownerId).TimeZoneSidKey;
                        System.debug('*userTimeZone**'+ userTimeZone);
                        if(businessHRSMap!=null && userTimeZone!=null){
                        	cs.BusinessHoursId = businessHRSMap.get(userTimeZone);
                        }
                        System.debug('cs.BusinessHoursId::'+cs.BusinessHoursId);
                        }
                	}
                If(oldCaseMap.get(cs.id).soc_Case_Owner_Type__c == CASEOWNERTYPE_REQUESTER && cs.soc_Case_Owner_Type__c == CASEOWNERTYPE_CONCIERGEQUEUE && 
                   !cs.soc_Concierge_First_Allocation__c){  
                       cs.soc_OnHold_End_Time__c = currentDate;
                       System.debug('cs.BusinessHoursId::'+cs.BusinessHoursId);
                       businessHrsId = cs.BusinessHoursId;
                       if(businessHrsId!=null){
                           onHoldSeconds = getBusinessHours(cs.soc_OnHold_Start_Time__c, cs.soc_OnHold_End_Time__c,businessHrsId);//Integer.valueOf((cs.soc_OnHold_End_Time__c.getTime() - cs.soc_OnHold_Start_Time__c.getTime())/(1000*60)); 
                       }
                       System.debug('cs.soc_Acceptance_OnHold_Total_Time__c::'+cs.soc_Acceptance_OnHold_Total_Time__c);
                       System.debug('onHoldSeconds::'+onHoldSeconds);
                       cs.soc_Acceptance_OnHold_Total_Time__c = (((cs.soc_Acceptance_OnHold_Total_Time__c*60) + onHoldSeconds)/60.0).setScale(2);
                       System.debug('cs.soc_Acceptance_OnHold_Total_Time__c::'+cs.soc_Acceptance_OnHold_Total_Time__c);
                   }
                if(oldCaseMap.get(cs.id).soc_Case_Owner_Type__c == CASEOWNERTYPE_REQUESTER && cs.soc_Case_Owner_Type__c == CASEOWNERTYPE_CONCIERGEQUEUE 
                   && cs.soc_Concierge_First_Allocation__c){
                       System.debug('oldownerid::'+oldCaseMap.get(cs.id).ownerId);
                       cs.soc_SFD_Case_Submission_Date__c = System.now(); //Added by Kritika Bhati| EDGE-83899| 20May
                       cs.soc_Process_Start_Time__c = currentDate;
                       cs.soc_Concierge_First_Allocation__c = False; 
                   }
                System.debug('cs.Requester_Department__c::'+cs.soc_Requester_Department__c);
                
                If(oldCaseMap.get(cs.id).Stage__c == STAGE_REQUESTREVIEW && cs.Stage__c == STAGE_VALIDATEANDASSIGN){ 
                    cs.soc_Process_End_Time__c = currentDate;
                    //long processMinutes = 0;
                     if(caseOwnerProfileIdMap!=null && caseOwnerProfileIdMap.containsKey(cs.ownerId)){
                        String userTimeZone = caseOwnerProfileIdMap.get(cs.ownerId).TimeZoneSidKey;
                        System.debug('*userTimeZone**'+ userTimeZone);
                        cs.BusinessHoursId = businessHRSMap.get(userTimeZone);
                        System.debug('cs.BusinessHoursId::'+cs.BusinessHoursId);
                        }
                    businessHrsId = cs.BusinessHoursId;
                    if(cs.soc_Process_End_Time__c!=null && cs.soc_Process_Start_Time__c!=null){
                        //processMinutes = (cs.soc_Process_End_Time__c.getTime() - cs.soc_Process_Start_Time__c.getTime())/(1000*60);
                        if(businessHrsId!=null){
                            /*Here Business Hours retuning time in seconds*/
                            cs.soc_SFD_Case_Acceptance_Time__c = getBusinessHours(cs.soc_Process_Start_Time__c, cs.soc_Process_End_Time__c, businessHrsId);//processMinutes - cs.Acceptance_OnHold_Total_Time__c;
                        }
                        cs.soc_SFD_Case_Acceptance_Time__c = ((cs.soc_SFD_Case_Acceptance_Time__c - (cs.soc_Acceptance_OnHold_Total_Time__c*60))/60.0).setScale(2);
                    }
                    Decimal businessTime = 0;
                    //Here BusinessTime is getting in seconds
                    businessTime = getBusinessTimeUnit('Case Acceptance');//, cs.soc_SFD_Case_Acceptance_Time__c
                    System.debug('Find business from custom setting based on timeunit hh/mm/ss::'+businessTime);
                    //validating if SFDCaseAcceptanceTime is greater than business hours(8 hrs) then soc_SLA_Exceeded__c will be acceptance. 
                    if((cs.soc_SFD_Case_Acceptance_Time__c*60) > businessTime){
                        cs.soc_SLA_Exceeded__c = 'Acceptance';
                    }
                    cs.soc_Process_Start_Time__c = System.now();
                }
            }
        }
        
    }
    /*
* Method Name: getBusinessHours
* Input Parameter:  DateTime ProcessStartDate, DateTime processEndDate
* Output Parameter: SFDCaseAcceptanceTime in hours
* Description: This method will use for finding business hours, it will take two input parameter that are process
* startdateTime, processEndDatetime and calcualte the business hours.
* Created By:   Sandeep Soni
* Create Date:  01 March 2019
*/
    public static Decimal getBusinessHours(DateTime processStartDate, DateTime processEndDate, Id businessHoursId){
        Decimal Seconds = 0;
        if(businessHoursId!=null && processStartDate!=null && processEndDate!=null){
            Seconds = BusinessHours.diff(businessHoursId,processStartDate,processEndDate)/(1000.0).setScale(2);
        }
        return Seconds;
    }
    /*
*	Method Access Type	:	Public
Description			:	This method is used for updating caseOwnerType, Requester Department whenever a case has been assigned
from omni channel. This method will be call from soc_ParentCaseOwnerService.cls 
Input Parameter		:	List<Case> This method will take the list of case that has been assigned using omnichannel.
Output Parameter	:	List<Case> This method will update case fields and return the case list.
*/
    public static List<Case> updateCaseOwnerType(List<Case> lstCase){
        System.debug('soc_ParentCaseOwnerService class'+lstCase);
        String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
        String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        Set<String> requestorProfileIdSet = new Set<String>{'Sales Enterprise B2B','Account Manager','Account Owner',
            'Sales - Enterprise','Sales Enterprise B2B','Sales Manager - Enterprise'};
                Map<Id, GroupMember> userGRPMap = new Map<Id, GroupMember>();
        DateTime currentDate = System.now();
        Map<Id, User> caseOwnerProfileIdMap = new Map<Id, User>();
        Set<Id> ownerIdSet = new Set<Id>();
        Map<String,BusinessHours> businessHRSMap = new Map<String, BusinessHours>();
        Map<Id,Profile> requestorProfileMap = new Map<Id, Profile>([SELECT ID, Name FROM Profile WHERE Name IN :requestorProfileIdSet]);
        Set<String> conciergeQueueSet = new Set<String>{'SOC_Queue','soc_SFD_Concierge_Offshore'};
            Set<String> detailerQueueSet = new Set<String>{'soc_SIMPLEX_Level_1_Detail_Ordering', 'soc_SIMPLEX_Offshore_Level_1_Detail'};
                Set<String> specialistQueueSet = new Set<String>{'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi'};
                    Set<String> ctsQueueSet = new Set<String>{'soc_Complex_Level_3_Detail_Queue'};
                        Map<Id,Group> grpMap = new Map<Id,Group>([select Id,Name, DeveloperName from Group 
                                                                  where Type = 'Queue' AND (DeveloperName IN :conciergeQueueSet OR 
                                                                                            DeveloperName IN :detailerQueueSet OR 
                                                                                            DeveloperName IN :specialistQueueSet OR 
                                                                                            DeveloperName IN :ctsQueueSet)]);
        Map<Id, GroupMember> grpMemberMap = new Map<Id, GroupMember>([SELECT ID, UserOrGroupId, GroupId FROM GroupMember WHERE 
                                                                      GroupId IN : grpMap.keySet()]);
        for(GroupMember gm : grpMemberMap.values()){
            userGRPMap.put(gm.UserOrGroupId, gm);
        }
        System.debug('userGRPMap Id::'+userGRPMap.keySet());
        for(Case cs : lstCase){
            if(cs.recordTypeId==recId_OrderRequest || cs.recordTypeId==recId_SFD_ProductType){
                ownerIdSet.add(cs.OwnerId);
            }
        }
        for(User us : [SELECT ID, ProfileId, Department,TimeZoneSidKey FROM User WHERE id IN : ownerIdSet]){
            caseOwnerProfileIdMap.put(us.id, us);
        }
        List<BusinessHours> lstBusinessHours = [select Id, TimeZoneSidKey from BusinessHours];
        for(BusinessHours bussHours : lstBusinessHours){
            businessHRSMap.put(bussHours.TimeZoneSidKey,bussHours);
        }
        for(Case cs: lstCase){
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
            }   
        }
        return lstCase;
    }
}