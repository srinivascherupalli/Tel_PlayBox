/**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   DTO class to for response type from replicator based on new response JSON (Flat JSON structure)
* @US       :   EDGE-75696, EDGE-85840, EDGE-84055
* */

public with sharing class ReplicatorGetServiceDTO {
    @AuraEnabled
    public String correlationId {get; set;}
    @AuraEnabled
    public String code {get; set;} //EDGE-216668. Capture API error
    @AuraEnabled
    public String message {get; set;} //EDGE-216668. Capture API error
    @AuraEnabled
    public List<servicesDTO> servicesList {get; set;}
    @AuraEnabled
    public String sendAddOnsConfig {get; set;} //Added by Anurag for DIGI-1684
    
    public class servicesDTO {
        @AuraEnabled    
        public String cidn {get; set;}
        @AuraEnabled
        public String productFamily {get; set;}
        @AuraEnabled
        public String fnn {get; set;}
        @AuraEnabled
        public siteDTO site {get; set;}
        @AuraEnabled
        public String replicatorUpdateDateTime {get; set;}
        @AuraEnabled
        public accountDTO account {get; set;}
        @AuraEnabled
        public List<serviceCharacteristicDTO> serviceCharacteristics {get; set;}
        @AuraEnabled
        public List<serviceAssociationDTO> serviceAssociations {get; set;}
        @AuraEnabled
        public List<devicesDTO> devices {get; set;}
        @AuraEnabled
        public List<serviceExtensionsDTO> serviceExtensions {get; set;}
        //B2B-1495:EDGE-177640 and EDGE-192009 -- Added by Abhishek from Osaka Team
        @AuraEnabled
        public List<repaymentsDTO> repayments {get; set;}
        //@AuraEnabled
        //public addonsDTO addOns {get;set;}
        @AuraEnabled
        public List<addOnsDTO> addOns {get; set;} // Added by Anurag for DIGI-1684
        
    }
    //--------START------------B2B-1495:EDGE-177640 and EDGE-192009 -- Added by Abhishek from Osaka Team
    public class repaymentsDTO {
        @AuraEnabled
        public String productId {get; set;}
        @AuraEnabled
        public String deviceId {get; set;}
        @AuraEnabled
        public String deviceType {get; set;}
        @AuraEnabled
        public String billLiteral {get; set;}
        @AuraEnabled
        public String contractType {get; set;}
        @AuraEnabled
        public Decimal monthlyAmount {get; set;}
        @AuraEnabled
        public Integer remainingTerm {get; set;}
        @AuraEnabled
        public Decimal remainingAmount {get; set;}
        @AuraEnabled
        public Date productEndDate{get; set;}
    }
    //--------END------------B2B-1495:EDGE-177640 and EDGE-192009 -- Added by Abhishek from Osaka Team
    
    public class serviceCharacteristicDTO {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }
    
    public class serviceAssociationDTO {
        @AuraEnabled
        public String linkedServiceId {get; set;}
        @AuraEnabled
        public String linkedServiceRole {get; set;}
        //EDGE-222176 : Added by Abhishek(Osaka) to introduce linkedServiceCidn for services association with CIDN.
        @AuraEnabled
        public String linkedServiceCidn {get; set;}
    }
    
    public class devicesDTO {
        @AuraEnabled
        public String deviceType {get; set;}
        @AuraEnabled
        public String physicalId {get; set;}
        @AuraEnabled
        public String networkId {get; set;}
    }
    
    public class siteDTO {
        @AuraEnabled
        public String siteType{get; set;}
        @AuraEnabled
        public String siteId {get; set;}
        @AuraEnabled
        public String linkedSiteType{get; set;}
        @AuraEnabled
        public String linkedSiteId {get; set;}
    } 
    
    public class accountDTO {
        @AuraEnabled
        public String accountNumber{get; set;}//BAN
        @AuraEnabled
        public String complexBillingIndicator {get; set;}
        @AuraEnabled
        public String creditManagementFlag {get; set;}
        @AuraEnabled
        public String serviceWithEtcFlag {get; set;} 
        @AuraEnabled
        public String dealerCode{get; set;}//Added as per EDGE-145906 Changes
        
    }  
    
    public class serviceExtensionsDTO {
        @AuraEnabled
        public String serviceExtensionFrom{get; set;}
        @AuraEnabled
        public String serviceExtensionTo {get; set;}
    }  
    public class addonsDTO {
        @AuraEnabled
        public String addonName{get; set;}
        @AuraEnabled
        public String productCode{get; set;}  
    }
    
    
   public static ReplicatorGetServiceDTO parse(String json) {
        return (ReplicatorGetServiceDTO) System.JSON.deserialize(json, ReplicatorGetServiceDTO.class);
    }  
        
    
}