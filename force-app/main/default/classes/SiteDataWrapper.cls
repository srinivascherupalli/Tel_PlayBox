/*
@ DEVELOPER : Nitin Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : This is a wrapper class to show and review uploaded sites on account
@ DIGI-6187
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Nitin Kumar      27/Aug/2021     DIGI- 6187 : Created class to show bulk CSV 
 * 2.       Omkar Jante      07/Oct/2021     DIGI-28081 : Updated logic for soft delete
*/
Public with sharing class SiteDataWrapper {

    @AuraEnabled public string corelationId {get;set;}
    @AuraEnabled public string accountId {get;set;}
    @AuraEnabled public string siteName {get;set;}
    @AuraEnabled public string address {get;set;}
    @AuraEnabled public string adborId {get;set;}
    @AuraEnabled public string status {get;set;}
    @AuraEnabled public string isDelete {get;set;}
    @AuraEnabled public string selectedAddress {get;set;}
    @AuraEnabled public List<newAddresses> newAddresses {get;set;}
    

    public class newAddresses{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        public newAddresses(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
}