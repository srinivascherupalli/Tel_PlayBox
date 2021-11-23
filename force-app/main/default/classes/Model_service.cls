/*********************************************************************************************************************************
*Class Name      :  Model_service
Test Class : Model_serviceTest
author:  Shubhi V
EDGE-EDGE-185011
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.              Shubhi V            15-12-2020          Edge-185856   
3.			  Shubhi V				12/03/2021			INC000095032613 
4.             Shubhi v             22/04/2021          EDGE-207352 
================================================================================================================================
*/
public with sharing class Model_service {
    // method to filter service based of solutions coresponding for mainsolution subscription number
    // EDGE-207352  added billing acc fields in query
    public static List<csord__Service__c> getDisconnectedServicesFromSolution(String subscriptionNumber,String offerId ,String prodspecid,Integer days){
    List<csord__Service__c> serviceList=new List<csord__Service__c>();
        Date lastNdate = Date.today().addDays(-Integer.valueOf(days));
        if(String.isNotBlank(SubscriptionNumber) && String.isNotBlank(OfferId) && String.isNotBlank(prodspecid) ){
            serviceList=[SELECT id,serviceMSISDN__c,
                        csord__Subscription__c,
                        csord__Subscription__r.name,csord__Status__c,
                        csord__Subscription__r.csordtelcoa__subscription_number__c,  
                        csord__Deactivation_Date__c,Cancellation_Reason__c,cssdm__solution_association__c,
                        Billing_Account__c,Billing_Account__r.Billing_Account_Number__c //EDGE-207352
                        FROM
                        csord__Service__c 
                        WHERE 
                        csord__Deactivation_Date__c >= : lastNdate AND 
                        Scenario_Type__c !='Port Out' AND
                        csord__Status__c='Disconnected' AND
                        csord__Subscription__r.MarketableOffer__r.Offer_ID__c=:OfferId AND
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c=:prodspecid
                        AND cssdm__solution_association__c IN (Select cssdm__solution_association__c from csord__Subscription__c where csordtelcoa__Subscription_Number__c=:SubscriptionNumber)];
        }
        return serviceList;
    }
    //Start for DIGI-16925: CMP transfer to AM
    public static List<csord__Service__c> getDisconnectedServicesFromSolution(String offerId ,Integer days){
        List<csord__Service__c> serviceList=new List<csord__Service__c>();
        Date lastNdate = Date.today().addDays(-Integer.valueOf(days));
        serviceList=[SELECT id,serviceMSISDN__c,
                    csord__Subscription__c,
                    csord__Subscription__r.name,csord__Status__c,
                    csord__Subscription__r.csordtelcoa__subscription_number__c,
                    csord__Deactivation_Date__c,Cancellation_Reason__c,cssdm__solution_association__c,
                    Billing_Account__c,Billing_Account__r.Billing_Account_Number__c
                    FROM
                    csord__Service__c
                    WHERE
                    csord__Deactivation_Date__c >= : lastNdate AND
                    Scenario_Type__c !='Port Out' AND
                    csord__Status__c='Disconnected'AND
                    csord__Subscription__r.MarketableOffer__r.Name ='Corporate Mobile Plus'];
        System.debug('---serviceList---55'+serviceList);
        return serviceList;
    }
    //End DIGI-16925
    // INC000095032613 start-------------
    // method to filter service based  MSIDN number
    public static List<csord__Service__c> getActiveMisDNService(Set<String> msidnNumerSet){

        List<csord__Service__c> serviceList=new List<csord__Service__c>();
        if(msidnNumerSet!=null && !msidnNumerSet.isEmpty()){
           serviceList=[SELECT id,serviceMSISDN__c,csord__Status__c FROM csord__Service__c WHERE csord__Status__c='Connected'AND serviceMSISDN__c IN:msidnNumerSet];
        }
        return serviceList;
    }
    // INC000095032613 end-------------
}