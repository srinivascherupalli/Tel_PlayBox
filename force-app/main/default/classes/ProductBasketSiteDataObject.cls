/*
===============================================================================================================================
Class : ProductBasketSiteDataObject
Developer Name : Rohit
Test Class : ProductBasketSiteDataObjectTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
public with sharing class ProductBasketSiteDataObject {
   @AuraEnabled
   public String pcrId {get; set;}
   @AuraEnabled
   public String pcrName {get; set;}
   @AuraEnabled
   public String siteName {get; set;}
   @AuraEnabled
   public String siteAddress {get; set;}
   @AuraEnabled
   public String adBorId {get; set;}
   @AuraEnabled
   public String orderType {get; set;}
   @AuraEnabled
   public String oldConfigId {get; set;}
   @AuraEnabled
   public List<ProductConfiguration> lstProdConfig {get; set;}
   @AuraEnabled
  	public String locality {get; set;}
   @AuraEnabled
    public String state {get; set;}
   @AuraEnabled
   public Boolean pcIsEligible{get; set;} //added for EDGE-73521
   public class ProductConfiguration{
       @AuraEnabled
       public String description {get; set;}
       @AuraEnabled
       public Decimal quantity {get; set;}
   }  
}