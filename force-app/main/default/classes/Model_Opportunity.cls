/****************************************************************************************************************************************************
Main Class : Model_Opportunity
Test Class : Model_OpportunityTest
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           24/09/2020      EDGE-167800    20.13(New Class)     To collate all the queries related to opportunity Object
******************************************************************************************************************************************************/
public with sharing class Model_Opportunity{
    
    public Opportunity getOpportunity(Id oppId){
        Opportunity opp = new Opportunity();
        if(!String.isBlank(oppId)){
            opp = [SELECT Id, Name, Type, StageName, CloseDate, Revenue_Impact_Date__c, Product_Type__c, Product_Domain__c, RecordTypeId, CreatedDate FROM Opportunity WHERE Id =: oppId];//Added Revenue_Impact_Date__c by Aman Soni for EDGE-167800       
        }
        return opp;
    }
}