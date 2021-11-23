/*
     * Method Name: SFDCaseDetailingTimeReport
     * Description: EDGE-68486 : This class captures the time taken by Detailer to close, withdraw or reject the case starting from the time the
     *                           case was assigned and minus the time case was on hold.
     * Created By:  Preeti Malik
     * Create Date: 04 March 2019
*/ 
public without sharing  class soc_CycleTimeReportForSFDCases {
    
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    
    public static void SFDCaseDetailingTimeReport(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap, Map<Id, User> caseOwnerProfileIdMap, Map<String,Id> businessHRSMap){
        DateTime currentDate = System.now();
        Id businessHrsId = null;
        Decimal onHoldSeconds = 0;
        for(Case cs : newCaseMap.values()){
            //Only for child cases
            if(cs.RecordTypeId == recId_SFD_ProductType){
                //Checking for the final owner of the case who's gonna work on it and capturing the Process Start Time & Business Hours of the owner
                if(oldCaseMap.get(cs.id).OwnerId != cs.OwnerId && (cs.soc_Case_Owner_Type__c == 'Detailer' || cs.soc_Case_Owner_Type__c == 'Specialist'|| cs.soc_Case_Owner_Type__c == 'CTS')){
                    cs.soc_Process_Start_Time__c = currentDate;
                }
            }
            //Preeti Malik :: EDGE-68486 :: 25 March 2019
            if(cs.RecordTypeId == recId_SFD_ProductType || cs.RecordTypeId == recId_OrderRequest){
                if(caseOwnerProfileIdMap!=null && caseOwnerProfileIdMap.containsKey(cs.OwnerId)){
                    String userTimeZone = caseOwnerProfileIdMap.get(cs.ownerId).TimeZoneSidKey;
                    if(businessHRSMap!=null){
                        cs.BusinessHoursId = businessHRSMap.get(userTimeZone);
                    }
                }
                //Checking for any one of the conditions to set parameters for time taken to close the case and find the SLA Exceeded Status
                if(cs.Stage__c == 'Detail Order' && oldCaseMap.get(cs.id).Status == 'In Progress' && cs.Status == 'On Hold'){
                    cs.soc_OnHold_Start_Time__c = currentDate;
                }
                else if(cs.Stage__c == 'Detail Order' && oldCaseMap.get(cs.id).Status == 'On Hold' && cs.Status == 'In Progress'){
                    cs.soc_OnHold_End_Time__c = currentDate;
                    businessHrsId = cs.BusinessHoursId;
                    if(businessHrsId!=null){
                        onHoldSeconds = soc_CaseCycleAcceptanceReport.getBusinessHours(cs.soc_OnHold_Start_Time__c, cs.soc_OnHold_End_Time__c,businessHrsId);
                    }
                    cs.soc_Detailing_OnHold_Total_Time__c = (((cs.soc_Detailing_OnHold_Total_Time__c*60) + onHoldSeconds)/60.0).setScale(2);
                }
                else if(cs.Stage__c == 'Detail Order' && (oldCaseMap.get(cs.id).Status == 'In Progress' || oldCaseMap.get(cs.id).Status == 'On Hold') && (cs.Status == 'Closed' || cs.Status == 'Withdrawn' || cs.Status == 'Rejected')){
                    //Preeti Malik :: EDGE-68486 :: 25 March 2019
                    if(oldCaseMap.get(cs.id).Status == 'On Hold'){
                        cs.soc_OnHold_End_Time__c = currentDate;
                    	businessHrsId = cs.BusinessHoursId;
                    	if(businessHrsId!=null){
                        	onHoldSeconds = soc_CaseCycleAcceptanceReport.getBusinessHours(cs.soc_OnHold_Start_Time__c, cs.soc_OnHold_End_Time__c,businessHrsId);
                    	}
                    	cs.soc_Detailing_OnHold_Total_Time__c = (((cs.soc_Detailing_OnHold_Total_Time__c*60) + onHoldSeconds)/60.0).setScale(2);
                    }
                    cs.soc_Process_End_Time__c = currentDate;
                    businessHrsId = cs.BusinessHoursId;
                    system.debug('cs.BusinessHoursId'+cs.BusinessHoursId);
                    if(businessHrsId!=null){
                        system.debug('cs.BusinessHoursId'+cs.BusinessHoursId);
                    	cs.soc_SFD_Case_Detailing_Time__c = soc_CaseCycleAcceptanceReport.getBusinessHours(cs.soc_Process_Start_Time__c, cs.soc_Process_End_Time__c, businessHrsId);
                    }
                    cs.soc_SFD_Case_Detailing_Time__c = ((cs.soc_SFD_Case_Detailing_Time__c - (cs.soc_Detailing_OnHold_Total_Time__c*60))/60.0).setScale(2);
                    Decimal businessTime = 0;
                    businessTime = soc_CaseCycleAcceptanceReport.getBusinessTimeUnit('Case Detailing');
                    if((cs.soc_SFD_Case_Detailing_Time__c*60) > businessTime){
                        cs.soc_SLA_Exceeded__c = 'Detailing';
                    }
                }
            }
        }
    }
}