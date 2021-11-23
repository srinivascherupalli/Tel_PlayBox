/*
@ DEVELOPER : Vamshi
@ TEAM: Napier
@ DESCRIPTION : This class has logics implemented for invocations from NapierTeamCreditAndAdjsutmentTriggerHandler
@ EDGE-135560
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Pooja Bhat          20/Jul/2021     EDGE-228125: Added new populateLatestCreditDateOnCase(), to rollup Lastest Credit Date Given to the Customer on Parent Case.
 * 2.       Shishir Pareek      03/Aug/2021     DIGI- 2781 : Refactored code according to new Trigger Framework and added two new methods updateRelatedCaseRecord and updateCreditAndAdjustmentAndCallApprovalProcess
 * 3.       Nitin Kumar         20/Oct/2021     DIGI- 21110 : adding chatter message for PRM users
 */

public with sharing class CreditsAndAdjustmentsTriggerHelper {  
    public FINAL static Id creditRecTypeId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByDeveloperName().get('Retrospective_Redemption_CA').getRecordTypeId();
    public FINAL static Id caseBillingEnquiryRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId();
    private FINAL static String className     =   'CreditsAndAdjustmentsTriggerHelper'; //EDGE-228125:Added
    private FINAL static String correlationId =   GuidUtil.NewGuid(); //EDGE-228125:Added
    private static Map<Id, Case> mapOfCaseToUpdate = new Map<Id, Case>();
    /*
    @ DEVELOPER : Vamshi
    @ Team : Napier
    @ Method to make comments mandatory before rejecting the record..
    @ Changelog : Shishir - Moved code related to filter the records to Handler class
    */     
    public static void makeCommentsMandatoryAtRejection(List<Credits_and_Adjustments__c> listOfRecordsToProcess){
        Map<Id, Credits_and_Adjustments__c> rejected;
        if(listOfRecordsToProcess != null && !listOfRecordsToProcess.isEmpty()) {
            rejected = new Map<Id,Credits_and_Adjustments__c>(listOfRecordsToProcess);
        }
        if (rejected!= null && !rejected.isEmpty()) {
            List<Id> processInstanceIds = new List<Id>{};
            for (Credits_and_Adjustments__c ca : [SELECT Id, (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1)
                                                 FROM Credits_and_Adjustments__c
                                                 WHERE ID IN :rejected.keySet()]){
                if(ca.ProcessInstances.size() > 0) {
                    processInstanceIds.add(ca.ProcessInstances[0].Id);
                }
                
            }   
            
            for (ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps
                                       ORDER BY CreatedDate DESC LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]){
                 
                if ((pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0) &&  pi.Steps[0].StepStatus == 'Rejected' ){
                    rejected.get(pi.TargetObjectId).addError(system.Label.MandatoryCommentsOnRejection);
                } else{
                    rejected.get(pi.TargetObjectId).Comments__c = pi.Steps[0].Comments;
                }
            }     
        }
    }

    /*
    @ DEVELOPER     :   Pooja 
    @ Team          :   Istanbul
    @ Jira Story    :   EDGE-228125
    @ Description   :   Method is used to update the Latest Date Value on Case field Latest_Date_When_Credit_Was_Given__c 
                        from child Credits_and_Adjustments__c records field Date_when_credit_was_given_to_customer__c 
    @ Changelog     :   DIGI-2781 - Shishir - Moved code of filtering the record to Handler class 
    */ 
    public static void populateLatestCreditDateOnCase(List<Credits_and_Adjustments__c> listOfCreditAdjustment) { //pass the old list
        if(listOfCreditAdjustment!=null && !listOfCreditAdjustment.isEmpty()) {
            try {
                for(Credits_and_Adjustments__c oCredit : listOfCreditAdjustment) {
                    Case oCase  =  new Case(Id = oCredit.Case_Number__c, Latest_Date_When_Credit_Was_Given__c = null); //If CreditAndAdjustment Record Count=0, then to clear the Date Value
                    mapOfCaseToUpdate.put(oCredit.Case_Number__c,oCase);
                }
                if(!mapOfCaseToUpdate.isEmpty()) {
                    AggregateResult[] resultCA  = [SELECT Case_Number__c,Case_Number__r.Latest_Date_When_Credit_Was_Given__c,
                                                    MAX(Date_when_credit_was_given_to_customer__c) maxCreditDate
                                                    FROM Credits_and_Adjustments__c
                                                    WHERE Case_Number__c IN:mapOfCaseToUpdate.keySet() AND Determination_Status__c = 'Approved'
                                                    GROUP BY Case_Number__c,Case_Number__r.Latest_Date_When_Credit_Was_Given__c];
                    for(AggregateResult ar : resultCA)  {
                        String caseId = (String)ar.get('Case_Number__c');
                        if(mapOfCaseToUpdate.containsKey(caseId)) {
                            if(ar.get('maxCreditDate') != ar.get('Latest_Date_When_Credit_Was_Given__c')) { //If there is change in Credit Date, only then to update the parent case record
                                mapOfCaseToUpdate.get(caseId).Latest_Date_When_Credit_Was_Given__c = (Date)ar.get('maxCreditDate');
                            } else {
                                mapOfCaseToUpdate.remove(caseId);
                            }
                        }      
                    }
                }   //End of if(setCaseIds != null && setCaseIds.size() > 0 )
            } catch (Exception e) {
                GenericUtilityClass.logException(className,'populateLatestCreditDateOnCase','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during update of Case field Latest_Date_When_Credit_Was_Given__c',C2O_ExceptionHandler.Capability.SYS_TRG);
            }
        }   //End of if(mapCreditAdjustment!=null && !mapCreditAdjustment.isEmpty())
    } //End of populateLatestCreditDateOnCase()

    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI - 2781
    @ Description   :   Method is used to update the credit and adjustment Determination Status field 
                        based on Total Determination or call the Approval Process
    */
    public static void updateCreditAndAdjustmentAndCallApprovalProcess(List<Credits_and_Adjustments__c> listOfCreditAdjustment, Set<Id> setOfCaseIds) {
        Map<Id, Case> mapOfCases;
        if(listOfCreditAdjustment != null && !listOfCreditAdjustment.isEmpty()) {
            try {
                if(!setOfCaseIds.isEmpty()) {
                    mapOfCases = new Map<Id, Case>([SELECT Id, Status FROM Case WHERE ID IN :setOfCaseIds]);
                }
                for(Credits_and_Adjustments__c ca :  listOfCreditAdjustment) {
                    if((Trigger.isInsert && Trigger.isBefore) && (ca.Total_Determination__c != null && ca.Total_Determination__c > 0 && ca.Total_Determination__c <= 1000)
                        && mapOfCases != null && mapOfCases.containsKey(ca.Case_Number__c) && mapOfCases.get(ca.Case_Number__c).Status == 'Obtaining Internal Approval') {
                    
                        ca.Determination_Status__c = 'Approved';
                    } else if((Trigger.isInsert && Trigger.isAfter) && (ca.Total_Determination__c > 1000 && ca.Total_Determination__c <= 40000000)
                        && mapOfCases != null && mapOfCases.containsKey(ca.Case_Number__c) && mapOfCases.get(ca.Case_Number__c).Status == 'Obtaining Internal Approval') {
                        
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(ca.Id);
                        req1.setProcessDefinitionNameOrId('Billing_Enquiry_Process');
                        Approval.ProcessResult result = Approval.process(req1);
                    }
                } 
            } catch(Exception e) {
                GenericUtilityClass.logException(className,'updateCreditAndAdjustmentAndCallApprovalProcess','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during update of Case field Latest_Date_When_Credit_Was_Given__c',C2O_ExceptionHandler.Capability.SYS_TRG);
            }    
        }
    }

    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI - 2781
    @ Description   :   Method is used to update case records based on conditions 
    */
    public static void updateRelatedCaseRecord(List<Credits_and_Adjustments__c> listOfCreditAdjustment, Set<Id> setofCaseIds) {
        Map<Id, Case> mapOfCases;
        String chatterMessage = '';
        // DIGI-21110 :- variables to hold ownerIds and Map of ownerId to Network Id
        Map<Id,Id> ownerToNetworkId;
        
        if(listOfCreditAdjustment != null && !listOfCreditAdjustment.isEmpty()) {
            try{
                if(!setOfCaseIds.isEmpty()) {
                    mapOfCases = new Map<Id, Case>([SELECT Id, RecordTypeId, OwnerId, Owner.ProfileId, Owner.Profile.Name, CaseNumber FROM Case WHERE ID IN :setOfCaseIds]);
                }
                
                if(!mapOfCases.isEmpty()){
                    // fetching Member to NetworkId Map
                    ownerToNetworkId = prepareMemberToNetworkIdMap(mapOfCases);
                }

                String networkId = null;
                for(Credits_and_Adjustments__c ca : listOfCreditAdjustment) {   
                    if(!ownerToNetworkId.isEmpty() && mapOfCases.get(ca.Case_Number__c)!= null && ownerToNetworkId.containsKey(mapOfCases.get(ca.Case_Number__c).OwnerId)){
                        // getting network id if caseowner is PRM user else it will be null
                        networkId = ownerToNetworkId.get(mapOfCases.get(ca.Case_Number__c).OwnerId);
                    }
                    Case tempCase = new Case();
                    tempCase.Id = ca.Case_Number__c;
                    if(ca.Determination_Status__c == 'Not Approved' 
                        && mapOfCases.get(ca.Case_Number__c) != null && mapOfCases.get(ca.Case_Number__c).RecordTypeId == caseBillingEnquiryRecTypeId)  {
                        
                        tempCase.Status = 'In Progress';
                    }
                    
                    if(ca.Redemption_Status__c == 'Not Approved' && ca.RecordTypeId == creditRecTypeId) {
                        // forming chatter message as per DIGI-21110
                        chatterMessage = String.format(SYS_UtilityClass.retrieveDisplayMessage('Retro_Redemption_req_Approved_Rejected'), 
                                                        new List<Object> {mapOfCases.get(ca.Case_Number__c).CaseNumber, 'Rejected'});    //'Retrospective Redemption request has been Rejected by Sales Manager';
                        tempCase.Status = 'Closed';
                        if(!Test.isRunningTest()) {
                            ConnectApiHelper.postFeedItemWithMentions(networkId,mapOfCases.get(ca.Case_Number__c).OwnerId,chatterMessage);
                        }
                    } else if(ca.Redemption_Status__c == 'Pending' && ca.RecordTypeId == creditRecTypeId) {
                        // forming chatter message as per DIGI-21110
                        chatterMessage = String.format(SYS_UtilityClass.retrieveDisplayMessage('Retro_Redemption_req_Pending'), 
                                                        new List<Object> {mapOfCases.get(ca.Case_Number__c).CaseNumber});
                        if(!Test.isRunningTest()){      
                            ConnectApiHelper.postFeedItemWithMentions(networkId,ca.Case_Number__c,chatterMessage);
                        }
                    } else if(ca.Redemption_Status__c == 'Approved' && ca.RecordTypeId == creditRecTypeId) {
                        // forming chatter message as per DIGI-21110
                        chatterMessage = String.format(SYS_UtilityClass.retrieveDisplayMessage('Retro_Redemption_req_Approved_Rejected'), 
                                                        new List<Object> {mapOfCases.get(ca.Case_Number__c).CaseNumber, 'Approved'});
                        if(!Test.isRunningTest()) {
                            ConnectApiHelper.postFeedItemWithMentions(networkId,mapOfCases.get(ca.Case_Number__c).OwnerId ,chatterMessage);
                        }
                        
                        Map<String, Object> params = new Map<String, Object>();
                        params.put('CurrentCreditsandAdjustmentsRecord', ca.Id);
                        params.put('CurrentCaseId', ca.Case_Number__c);
                        Flow.Interview.OneFundRedemptionCredittoARIA oneFund = new Flow.Interview.OneFundRedemptionCredittoARIA(params);
                        oneFund.start();
                    }
                    if(mapOfCaseToUpdate.containsKey(tempCase.Id) && !String.isEmpty(tempCase.Status)) {
                        mapOfCaseToUpdate.get(tempCase.Id).Status = tempCase.Status; 
                    } else if(!String.isEmpty(tempCase.Status)) {
                        mapOfCaseToUpdate.put(tempCase.Id, tempCase);
                    }       
                }
            } catch (Exception e) {
                GenericUtilityClass.logException(className,'updateRelatedCaseRecord','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during update of Case field Latest_Date_When_Credit_Was_Given__c',C2O_ExceptionHandler.Capability.SYS_TRG);
            }
        }
    }
    
    /*
    @ DEVELOPER     :   Shishir Pareek 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI - 2781
    @ Description   :   Method is used to update case records based on conditions 
    */    
    public static void updateRelatedCases() {
        if(!mapOfCaseToUpdate.isEmpty()) {
            update mapOfCaseToUpdate.values();
        }
    }

    /*
    @ DEVELOPER     :   Nitin Kumar 
    @ Team          :   Istanbul
    @ Jira Story    :   DIGI - 21110
    @ Description   :   Method is used to prepare the Member to Network Id Map
    */ 
    public static Map<Id,Id> prepareMemberToNetworkIdMap(Map<Id,Case> mapOfCases){
        Map<Id,Id> ownerToNetworkId = new Map<Id,Id>();
        Set<Id> ownersId = new Set<Id>();
        for(Case currCase : mapOfCases.values()){
            // DIGI-21110 :- adding all ownerid where profile is not blank excluding queue as a owner
            if(currCase.Owner.ProfileId != null && system.label.PRMProf.contains(currCase.Owner.Profile.Name))    ownersId.add(currCase.OwnerId);
        }
        List<NetworkMember> members = new List<NetworkMember>([SELECT  MemberId, NetworkId FROM NetworkMember WHERE MemberId IN :ownersId]);
        
        for(NetworkMember member : members){
            // map is formed which will hold MemberId and Network Id for case owner
            // it will be used to publish notification on PRM user account when Internal user will approve/reject CA
            ownerToNetworkId.put(member.MemberId,member.NetworkId);
        }
        return ownerToNetworkId;
    }

}   //End of Class CreditsAndAdjustmentsTriggerHelper