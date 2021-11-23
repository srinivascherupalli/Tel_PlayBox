/******************************************************************************************************************************
Class Name : ServiceAddOnWrapperData
Test Class : ServiceAddOnWrapperDataTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           10/02/2021    EDGE-191077(New Class)           21.02
*******************************************************************************************************************************/
   public with sharing class ServiceAddOnWrapperData
    {
        @AuraEnabled
        public String legacyBillingAccount{get; set;}
        @AuraEnabled
        public String deviceType{get; set;}
        @AuraEnabled
        public String deviceIDType{get; set;}
        @AuraEnabled
        public String deviceID{get; set;}
        @AuraEnabled
        public String deviceManufacturer{get; set;}
        @AuraEnabled
        public String deviceModel{get; set;}
        @AuraEnabled
        public String deviceDescription{get; set;}
        @AuraEnabled
        public String paymentType{get; set;}
        @AuraEnabled
        public Double remainingBalance{get; set;}
        @AuraEnabled
        public Double remainingTerm{get; set;}
        @AuraEnabled
        public Double recChargeIncGst{get; set;}
        @AuraEnabled
        public String Id{get; set;}
        @AuraEnabled
        public String status{get; set;}
        @AuraEnabled
        public String deviceInstanceId{get; set;}
        @AuraEnabled
        public Boolean isgreyedout{get; set;}
        //START: Added for EDGE-215103
        @AuraEnabled
        public Date ProductEndDate{get; set;}
        @AuraEnabled
        public String TermStatus{get;set;}
        //END for EDGE-215103
    }