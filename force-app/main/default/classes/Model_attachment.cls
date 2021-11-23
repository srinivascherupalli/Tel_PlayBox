/*********************************************************************************************************************************
*Class Name      :  Model_service
Test Class : Model_serviceTest
author:  Shubhi V
EDGE-EDGE-185011
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.              Shubhi V            15-12-2020          Edge-185856     
================================================================================================================================
*/
public with sharing class Model_attachment {
    
    public static List<Attachment> getServiceSpecs (List<String> subsNumlist){
        List<Attachment> serviceSpecslist=new List<Attachment>();
        if(subsNumlist!=null && !subsNumlist.isEmpty()){
            serviceSpecslist=[select id, body, name,parentid,
                TYPEOF Parent WHEN csord__service__c 
                THEN csord__Subscription__r.csordtelcoa__subscription_number__c END 
                from attachment 
                where  
                parentId IN (SELECT id from csord__Service__c where csord__Subscription__r.csordtelcoa__subscription_number__c IN:subsNumlist AND csord__Subscription__r.csord__Status__c='Inactive')];
            
        }
        return serviceSpecslist;
    }

}