/*******************************************************************************************************
Name          : GetChargeZoneAPIDTO 
Created By    : Aman Soni
Created Date  : Nov 25 2019
Description   : This is DTO class for ChargeZoneController
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL     
-------     ------          -----           ---------
1.1         Aman Soni       25-11-2019      Class created as part of EDGE-98299
1.2         Ajith Kumar     12/Oct/2021     DIGI-15723 : Updated logic products and added annotations to access the class variables
1.3         Ajith Kumar     19/Oct/2021     DIGI-15723 changed the rental data type from Integer to string
1.4         Ajith Kumar     15/Nov/2021     DIGI-15723 Added the status code variable to store the response status
*******************************************************************************************************/
global with sharing class GetChargeZoneAPIDTO {
    
    public Integer esaId;
    public Integer czpId;
    public String contractStartDate;
    @AuraEnabled
    public Zone zone;
    @AuraEnabled
    public List<Maintenance> maintenance;
    @AuraEnabled
    public Datetime lastVerificationDate;//DIGI-15723 Added last to store LastVerificationDate from site Object
    @AuraEnabled
    public Integer statusCode;//DIGI-15723 Added to store the status from the response

    public class Zone {   
        @AuraEnabled     
        public String rental;//DIGI-15723 changed the rental data type from Integer to string
        @AuraEnabled
        public String sla;
        @AuraEnabled
        public String mdn;
        @AuraEnabled
        public List<Products> products;        
    }
    public class Products {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String availability;
    }
    public class Maintenance {
        @AuraEnabled
        public String vendor;
        @AuraEnabled
        public String availability;
    }
  
    public static GetChargeZoneAPIDTO parse(String json) {
        return (GetChargeZoneAPIDTO) System.JSON.deserialize(json, GetChargeZoneAPIDTO.class);
    }
}