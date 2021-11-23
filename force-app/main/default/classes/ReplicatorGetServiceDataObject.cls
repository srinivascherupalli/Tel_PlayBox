/*
*    Get Service interface's JSON formatted response is deserialize to an instance of ReplicatorGetServiceDataObject 
*/
public with sharing class ReplicatorGetServiceDataObject {
    @AuraEnabled
    public String Source_System_Id {get; set;}    
    @AuraEnabled
	public String CIDN {get; set;}
	@AuraEnabled
    public String Correlation_Id {get; set;}
    @AuraEnabled
    public String Error_Code {get; set;}
    @AuraEnabled
    public String Error_Description {get; set;}
    @AuraEnabled
	public List<SiteDTO> site {get; set;}
	public class SiteDTO {
		@AuraEnabled
		public String ADBOR_Id {get; set;}
		@AuraEnabled
        public String siteName {get;set;}
		@AuraEnabled
		public String Error_Code {get; set;}
		@AuraEnabled
		public String Error_Description {get; set;}
		@AuraEnabled
		public List<ProductDTO> productList {get; set;}
	}
		
    public class ProductDTO {
        @AuraEnabled
        public Boolean checkValue{get;Set;}
        @AuraEnabled
		public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String Product_Type {get;Set;}
        @AuraEnabled
        public String Product_Identifier {get;Set;}
        @AuraEnabled
        public String Association_Type {get;Set;}
        @AuraEnabled
        public String Association_Role {get;Set;}
        @AuraEnabled
        public String Association_Link_Id {get;Set;}
        @AuraEnabled
        public String Business_Owner {get;Set;}
        @AuraEnabled
        public String Bundle_Indicator {get;Set;}
        @AuraEnabled
        public String Purchase_Order {get;Set;}
        @AuraEnabled
        public String Invoice_Arrangement_Id {get;Set;}
        @AuraEnabled
        public String Invoice_Arrangement_Id_MICA {get;Set;}
        @AuraEnabled
        public String In_Flight_Flag {get;Set;}
        @AuraEnabled
        public String In_Flight_Legacy_System {get;Set;}
        @AuraEnabled
        public String In_Flight_Order_Id {get;Set;}
        @AuraEnabled
        public String Nominated_FNN {get;Set;}
        @AuraEnabled
        public String DOT_GenType {get;Set;}
        @AuraEnabled
        public String Enterprise_Id {get;Set;}
        @AuraEnabled
        public String Error_Code {get;Set;}
        @AuraEnabled
        public String Error_Description {get;Set;}
        
        @AuraEnabled
        public List<DiscountDTO> discount {get; set;}
        @AuraEnabled
        public List<ServiceDTO> service {get; set;}     
    }

    public class ServiceDTO {
        @AuraEnabled
        public String Service_Id {get; set;} 
        @AuraEnabled
        public String Technical_Association_Role {get; set;} 
        @AuraEnabled
        public String Service_Type {get; set;} 
        @AuraEnabled
        public String Bundle_Role {get; set;} 
        @AuraEnabled
        public String Last_Replicator_Update_Date {get; set;} 
        @AuraEnabled
        public String Error_Code {get; set;} 
        @AuraEnabled
        public String Error_Description {get; set;} 
        @AuraEnabled
        public List<ServiceCharacteristicDTO> serviceCharacteristic {get; set;} 
        @AuraEnabled
        public List<PlanCharacteristicDTO> planCharacteristic {get; set;} 
        @AuraEnabled
        public List<ServiceRelationshipDTO> serviceRelationship {get; set;} 
    }

    public class ServiceCharacteristicDTO {
        @AuraEnabled
        public String name {get; set;} 
        @AuraEnabled
        public String value {get; set;} 
    }
    
    public class PlanCharacteristicDTO {
        @AuraEnabled
        public String Plan_Deal_Type {get; set;} 
        @AuraEnabled
        public String Plan_Name {get; set;} 
        @AuraEnabled
        public String Plan_Term {get; set;} 
        @AuraEnabled
        public String Plan_Commercial_Type {get; set;} 
        @AuraEnabled
        public String Plan_Monthly_Amount {get; set;} 
        @AuraEnabled
        public String Plan_Start_Date {get; set;} 
        @AuraEnabled
        public String Instalments_Billed {get; set;} 
        @AuraEnabled
        public String Instalments_Remaining {get; set;} 
        @AuraEnabled
        public String Legacy_String {get; set;} 
        @AuraEnabled
        public DiscountDTO discount {get; set;} 
    }   
    
    public class ServiceRelationshipDTO {
        @AuraEnabled
        public String relationshipType {get; set;} 
        @AuraEnabled
        public DeviceDTO device {get; set;} 
        @AuraEnabled
        public ServiceDTO service {get; set;}       
        @AuraEnabled
        public List<ServiceExtensionDTO> serviceExtension {get; set;} 
    }
    
    public class DeviceDTO {
        @AuraEnabled
        public String Device_Type {get; set;} 
        @AuraEnabled
        public String Device_Ownership {get; set;} 
        @AuraEnabled
        public String Device_Model {get; set;} 
        @AuraEnabled
        public String Device_Name {get; set;} 
        @AuraEnabled
        public String SKU {get; set;} 
        @AuraEnabled
        public String Device_Payment_Type {get; set;} 
        @AuraEnabled
        public String Device_Monthly_Amount {get; set;} 
        @AuraEnabled
        public String Device_Plan_Start_Date {get; set;} 
        @AuraEnabled
        public String Device_Plan_Term {get; set;} 
        @AuraEnabled
        public String Device_Billing_System {get; set;} 
        @AuraEnabled
        public String Device_Billing_System_Id {get; set;} 
        @AuraEnabled
        public String Legacy_Link {get; set;} 
        @AuraEnabled
        public String DECT_BaseStation {get; set;} 
        @AuraEnabled
        public String DECT_Handset {get; set;} 
        @AuraEnabled
        public String Quantity {get; set;} 
        @AuraEnabled
        public String Error_Code {get; set;} 
        @AuraEnabled
        public String Error_Description {get; set;} 
        @AuraEnabled
        public List<DiscountDTO> discount {get; set;} 
    }   
    
    public class ServiceExtensionDTO {
        @AuraEnabled
        public String Services_From {get; set;} 
        @AuraEnabled
        public String Services_To {get; set;} 
    }   

    public class DiscountDTO {
        @AuraEnabled
        public String Discount_Name {get; set;}
        @AuraEnabled
        public String Discount_Start_Date {get; set;}
        @AuraEnabled
        public String Discount_Monthly_Amount {get; set;}
		@AuraEnabled
		public String Discount_Percent_Amount {get; set;}
        @AuraEnabled
        public String Discount_Term {get; set;}
    }
    
    public static ReplicatorGetServiceDataObject parse(String json) {
        return (ReplicatorGetServiceDataObject) System.JSON.deserialize(json, ReplicatorGetServiceDataObject.class);
    }
    
            
    public static ServiceDTO cloneService(ServiceDTO sDTO) {
        String str = JSON.serialize(sDTO);
        System.debug('Clone Service String: ' + str);
        ServiceDTO cDTO = (ServiceDTO)JSON.deserialize(str, ServiceDTO.class);
        System.debug('Cloned DTO: ' + cDTO.toString());
        
        return cDTO;
    }
}