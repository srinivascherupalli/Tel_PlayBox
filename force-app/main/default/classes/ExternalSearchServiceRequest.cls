/**
 *  @description Handles all the External Search Service Request queries
 *  @author      Olivier Rachon
 *  @date        2017-10-18
 */
public with sharing class ExternalSearchServiceRequest {

    @TestVisible private static List<WC_CSSA_ServicesFunction_VW__x> mockedRequests = new List<WC_CSSA_ServicesFunction_VW__x>();

    public static List<WC_CSSA_ServicesFunction_VW__x> findByServiceDescription(String searchTerm) {
        
       List<WC_CSSA_ServicesFunction_VW__x> requests = (!mockedRequests.isEmpty()) ? mockedRequests : [
             SELECT ID, Billing_Account_Info__c , SingleBilled__c , Silent__c, Plan1__c, Svc_Type__c, Address__c, CIDN__c, DataPlan__c, VisibleSvcDescription__c
             from WC_CSSA_ServicesFunction_VW__x
             WHERE VisibleSvcDescription__c = :searchTerm LIMIT 1];

        return (requests.size() > 0) ? requests : null;
    }
}