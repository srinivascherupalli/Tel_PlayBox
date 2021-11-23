/*
===============================================================================================================================
Test Class : EDMRelationshipServiceTest
Developer Name : Pulkit Gupta
Date : 19/02/2018
Class : EDMRelationshipService
===============================================================================================================================
Sr.No.    Developer Name      Date      	Story Description
1.        Pulkit Gupta		  19/02/2018    EDGE-9945 : (Technical Story) Introduce Parent-Child and Associated to Relationships
between various specifications generated as a part of Order Decomposition so that
the payload sent to AMDOCS has the correct associations defined for fulfilment.
===============================================================================================================================
*/
@IsTest
public with sharing class EDMRelationshipServiceTest {
    
    @testsetup public static void dataSetup() {
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');
        insert usr;
        ManageOrderTestDataSetup.testdataSetup();
    }
    
    static testMethod void createRelationShipForSalesManagerEnterprise() {
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        System.runAs(usr) {
            Test.startTest();
            List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
            Map<id, csord__Order__c> ordersMap = new Map<ID,csord__Order__c>();
            List<Id> orderIds = new List<Id>();
            for(csord__Order__c ord: orders) {
                orderIds.add(ord.Id);
                ordersMap.put(ord.Id, ord);
            }
            System.assert(!orderIds.isEmpty());
            EDMRelationshipService.createRelationShip(orderIds);
            Test.stopTest();
            validateSpecsUpdated(ordersMap);
            
        }
    }
    
    static testmethod void createRelationShipForSalesEnterprise() {   
        Profile pf = [select Id,Name from profile where name ='Sales - Enterprise'];
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        usr.ProfileId = pf.Id;
        update usr;
        System.runAs(usr) {
            Test.startTest();
            List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
            List<Id> orderIds = new List<Id>();
            Map<id, csord__Order__c> ordersMap = new Map<ID,csord__Order__c>();
            for(csord__Order__c ord: orders){
                orderIds.add(ord.Id);
                ordersMap.put(ord.Id, ord);
            }
            System.assert(!orderIds.isEmpty());
            EDMRelationshipService.createRelationShip(orderIds);
            Test.stopTest();
            validateSpecsUpdated(ordersMap);
        }
    }
    
    private static void validateSpecsUpdated(Map<id, csord__Order__c> ordersMap) {
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> updatesSpecMap = EDMRelationshipService.getOrderSpecs(ordersMap);
        for(List<CS_SpecificationDTO.ServiceSpecification> updatedSpecs : updatesSpecMap.values()) {
            for(CS_SpecificationDTO.ServiceSpecification updatedSpec : updatedSpecs) {
                if(updatedSpec.guid == 'ef2af0e2-e668-a8e5-e889-ddc868fdbc11') {
                    System.assertEquals(1, updatedSpec.additionalAttributes.size());
                    // System.assertEquals('parentSpec', updatedSpec.additionalAttributes.get(0).name);
                    //System.assertEquals('da1c712f-8764-c7c3-acd4-c3121bdc446d', updatedSpec.additionalAttributes.get(0).value);
                }
            }
        }
    }
}