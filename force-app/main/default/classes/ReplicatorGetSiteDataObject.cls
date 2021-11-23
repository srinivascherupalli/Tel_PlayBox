/*
*    Get Site interface's JSON formatted response is deserialize to an instance of ReplicatorGetSiteDataObject 
*/
public with sharing class ReplicatorGetSiteDataObject {
    public String Correlation_Id{get;set;}
    @AuraEnabled
    public String CIDN {get; set;}
    @AuraEnabled
    public String Enterprise_Id {get; set;}
    @AuraEnabled
    public String Error_Code {get; set;}
    @AuraEnabled
    public String Error_Description {get; set;}     
    @AuraEnabled
    public List<SiteDTO> Site {get; set;}
    
    public class SiteDTO {
        @AuraEnabled
        public String concatenatedAddress {get;set;}
        @AuraEnabled
        public String Media_Type {get; set;} //Replicator Derived
        @AuraEnabled
        public String Site_Nick_Name {get; set;}
        @AuraEnabled
        public String ADBoR_ID {get; set;}
        @AuraEnabled
        public String Address_No_From {get; set;}
        @AuraEnabled
        public String Address_No_To {get; set;}
        @AuraEnabled
        public String Suffix_From {get; set;}
        @AuraEnabled
        public String Suffix_To {get; set;}
        @AuraEnabled
        public String Street_Name {get; set;}
        @AuraEnabled
        public String Street_Type {get; set;}
        @AuraEnabled
        public String Loc_Name {get; set;}
        @AuraEnabled
        public String ADBoR_Postcode {get; set;}        
        @AuraEnabled
        public String State {get; set;}
        @AuraEnabled
        public String Name {get; set;}      
        @AuraEnabled
        public String Address1 {get; set;}
        @AuraEnabled
        public String Address2 {get; set;}      
        @AuraEnabled
        public String Disconnection_Date {get; set;}
        @AuraEnabled
        public String LastReplicator_UpdateDate {get; set;}
        @AuraEnabled
        public String In_Flight_Order {get; set;} //Replicator Derived
        @AuraEnabled
    	public String RFS_Site {get; set;} //Replicator Derived
        @AuraEnabled
        public String RFS_Date {get; set;}
        @AuraEnabled
        public String NBN_Location_Id {get; set;}
        @AuraEnabled
        public String Serviceability {get; set;}
        @AuraEnabled
        public String NBN_Access_Type {get; set;}
        @AuraEnabled
        public String Disconnect_Wave {get; set;}
        @AuraEnabled
        public String Site_Address_Status{get; set;}
        @AuraEnabled
        public String Site_Composition {get; set;} //Replicator Derived        
        @AuraEnabled
        public String Complex_Site_Flag {get; set;}
        @AuraEnabled
        public String Site_Migration_Flag  {get; set;}
        @AuraEnabled
        public String Order_Stability_Date {get; set;}
        @AuraEnabled
        public String Service_Class {get; set;}
        
        @AuraEnabled
        public String Sub1_CodeSet_Abbrev {get; set;}        
        @AuraEnabled
        public String Sub1_Descriptor_1 {get; set;}
        @AuraEnabled
        public String Sub1_Descriptor_2 {get; set;}
        @AuraEnabled
        public String Sub2_CodeSet_Abbrev {get; set;}        
        @AuraEnabled
        public String Sub2_Descriptor_1 {get; set;}
        @AuraEnabled
        public String Sub2_Descriptor_2 {get; set;}               
        @AuraEnabled
        public String Sub3_CodeSet_Abbrev {get; set;}        
        @AuraEnabled
        public String Sub3_Descriptor_1 {get; set;}
        @AuraEnabled
        public String Sub3_Descriptor_2 {get; set;}
        @AuraEnabled
        public String Sub4_CodeSet_Abbrev {get; set;}        
        @AuraEnabled
        public String Sub4_Descriptor_1 {get; set;}
        @AuraEnabled
        public String Sub4_Descriptor_2 {get; set;}
        @AuraEnabled
        public String Error_Description {get; set;} //Replicator Derived
        @AuraEnabled
        public String Error_Code {get; set;} //Replicator Derived        
        @AuraEnabled
        public List<SiteContactDTO> Contact {get; set;}
    
    }
    
    public class SiteContactDTO {
        @AuraEnabled
        public String Site_Contact_First_Name {get; set;}
        @AuraEnabled
        public String Site_Contact_Last_Name {get; set;}
        @AuraEnabled
        public String Site_Contact_Telephone {get; set;}
        @AuraEnabled
        public String Site_Contact_Mobile {get; set;}
        @AuraEnabled
        public String Site_Contact_Fax {get; set;}
        @AuraEnabled
        public String Site_Contact_Email {get; set;} 
    }
    
    public static ReplicatorGetSiteDataObject parse(String json) {
        return (ReplicatorGetSiteDataObject) System.JSON.deserialize(json, ReplicatorGetSiteDataObject.class);
    }
}