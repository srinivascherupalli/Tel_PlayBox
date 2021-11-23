/*===============================================================================================================================
Class : ReplicatorGetServiceDataObject_V2
Developer Name : Shubhi
Test Class : ReplicatorGetServiceDataObject_V2Test
description: Get Service interface's JSON formatted response is deserialize to an instance of ReplicatorGetServiceDataObject_V2 
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  21/5/2019     Edge-US-0027073 added eligibility status on productListDTO
===============================================================================================================================
*/
public with sharing class  ReplicatorGetServiceDataObject_V2 {
    public ReplicatorGetServiceDataObject_V2(){
        site = new List<SiteDTO_V2>();
    }
    @AuraEnabled
    public Integer serviceCount{ get { if(serviceCount== null ) serviceCount=0; return serviceCount;} set;}
    @AuraEnabled
    public String Source_System_Id {get; set;} 
    @AuraEnabled
    public String sendAddOnsConfig {get; set;} // Added by Anurag for DIGI-1684
    @AuraEnabled
    public String CIDN {get; set;}
    @AuraEnabled
    public String Mode {get; set;}
    @AuraEnabled
    public String Correlation_Id {get; set;}
    @AuraEnabled
    public String Error_Code {get; set;}
    @AuraEnabled
    public String Error_Description {get; set;}
    @AuraEnabled
    public List<SiteDTO_V2> site {get { if(site== null ) site=new List<SiteDTO_V2>(); return site;} set;}
    
    
    
    public class SiteDTO_V2{
        @AuraEnabled
        public String ADBOR_Id {get; set;}
        @AuraEnabled
        public String siteName {get;set;}
        @AuraEnabled
        public String Error_Code {get; set;}
        @AuraEnabled
        public String Error_Description {get; set;}
        @AuraEnabled
        public List<productListDTO> productList {get; set;}
    }
    public class productListDTO{
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;} Set;}
        @AuraEnabled
        public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String Product_Type {get; set;}
        @AuraEnabled
        public List<serviceListDTO> serviceList {get; set;}  
        @AuraEnabled
        public String eligibilityStatus {get; set;} //sr1
        @AuraEnabled
        public String eligibilityReason {get; set;} //sr1
    }
    public class serviceListDTO{
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;  } Set;}        
        @AuraEnabled
        public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String Service_Type {get; set;}
        @AuraEnabled
        public String transitionId{get; set;}//created by Rahul to store transitionid
        @AuraEnabled
        public Boolean checkReserved{get { if(checkReserved == null ) checkReserved=false; return checkReserved;  } Set;}   
        @auraEnabled
        public List<ServiceDTO_V2> service {get; set;}
        @AuraEnabled
        public List<ServiceAssociationsDTO_V2> serviceAssociations {get; set;}  //EDGE-98925
        
    }
    public class ServiceDTO_V2 { 
        @AuraEnabled
        public String User_Type {get; set;} 
        @AuraEnabled
        public String Directory_Option {get; set;}  
        @AuraEnabled
        public String Association_Type{get;Set;}
        @AuraEnabled
        public String Association_Role{get;Set;}    
        @AuraEnabled
        public String Service_Id {get; set;}
        @AuraEnabled
        public String Service_Type {get; set;}
        @AuraEnabled
        public Boolean IsInflight{get;Set;}
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;} Set;}
        @AuraEnabled
        public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String In_Flight_Flag {get;Set;}
        @AuraEnabled
        public String In_Flight_Legacy_System {get;Set;}
        @AuraEnabled
        public String In_Flight_Order_Id {get;Set;} 
        @AuraEnabled
        public String eligibilityStatus {get; set;} 
        @AuraEnabled
        public String eligibilityReason {get; set;} 
        @AuraEnabled
        public String Reserve_status {get; set;} 
        @AuraEnabled
        public String Reason {get; set;}        
        @AuraEnabled
        public List<ServiceExtensionDTO_V2> serviceExtension {get; set;}
        
    }      
    public class ServiceExtensionDTO_V2 { 
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;} Set;}
        @AuraEnabled
        public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String Services_From {get; set;} 
        @AuraEnabled
        public String Services_To {get; set;} 
        @AuraEnabled
        public String eligibilityStatus {get; set;} 
        @AuraEnabled
        public String eligibilityReason {get; set;} 
        @AuraEnabled
        public String Reserve_status {get; set;} 
        @AuraEnabled
        public String Reason {get; set;}
        @AuraEnabled
        public Boolean checkReserved{get { if(checkReserved == null ) checkReserved=false; return checkReserved;  } Set;}   
        
    }   
  //EDGE-98925  
    public class ServiceAssociationsDTO_V2 { 
        @AuraEnabled
        public String LinkedServiceId {get; set;}
        @AuraEnabled
        public String LinkedServiceRole {get; set;}
    }   
    public static ReplicatorGetServiceDataObject_V2 parse(String json) {
        return (ReplicatorGetServiceDataObject_V2) System.JSON.deserialize(json, ReplicatorGetServiceDataObject_V2.class);
    }          
}