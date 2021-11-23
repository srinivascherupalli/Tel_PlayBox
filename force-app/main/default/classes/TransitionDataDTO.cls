/**
* @Author   :   Maqsood Alam
* @Date     :   06 June 2019
* @Desc     :   DTO class for new transition response for mobile & ngUc
* @US       :   EDGE-89542
* @Status   :   Developemnt
1. EDGE-152495   Ankit   Added Attributes in Wrapper

**/

public with sharing class TransitionDataDTO {
    public TransitionDataDTO(){ 
        productList = new List<productListDTO>(); 
    }
    
    @AuraEnabled
    public Integer serviceCount{ get { if(serviceCount== null ) serviceCount=0; return serviceCount;} set;}
    @AuraEnabled
    public String Source_System_Id {get; set;}    
    @AuraEnabled
    public String CIDN {get; set;}
    @AuraEnabled
    public string sendAddOnsConfig {get; set;} //Added by Anurag for DIGI-1684
    @AuraEnabled                   // EDGE-198374
    public String FNN {get; set;} // EDGE-198374
    @AuraEnabled
    public String Correlation_Id {get; set;}
    @AuraEnabled
    public String Error_Code {get; set;}
    @AuraEnabled
    public String Error_Description {get; set;}
    @AuraEnabled
    public String LegacyTenancyID {get; set;} // EDGE-152495 - Added By ankit
    
    @AuraEnabled
    public List<productListDTO> productList {get { if(productList == null ) productList=new List<productListDTO>(); return productList;} set;}
    
    public class productListDTO{
        @AuraEnabled
        public String Product_Type {get;set;}
        @AuraEnabled
        public boolean checkValue {get;set;}
        @AuraEnabled
        public String eligibilityStatus {get;set;}
        @AuraEnabled
        public String eligibilityReason {get;set;}
        @AuraEnabled
        public String disableCheck {get;set;}
        @AuraEnabled
        public List<SiteDTOMobile> site {get; set;}
    }
    
    public class SiteDTOMobile{
        @AuraEnabled
        public String siteName {get;set;}
        @AuraEnabled
        public String Error_Description {get;set;}
        @AuraEnabled
        public String Error_Code {get;set;}
        @AuraEnabled
        public String ADBOR_Id {get;set;}
        @AuraEnabled
        public String linkedSiteId {get;set;}    
        @AuraEnabled
        public List<serviceListDTOMobile> serviceList {get; set;}
    }
        
    public class serviceListDTOMobile{
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;  } Set;}
        @AuraEnabled
        public Boolean checkReserved{get { if(checkReserved == null ) checkReserved=false; return checkReserved;  } Set;}         
        @AuraEnabled
        public Boolean disableCheck{get;Set;}
        @AuraEnabled
        public String Service_Type {get;set;} 
        @AuraEnabled
        public String EligibilityStatus {get;set;} 
        @AuraEnabled
        public String EligibilityReason {get;set;}       
        @AuraEnabled
        public List<groupDTOMobile> groupType {get; set;}
        
    }
   
    public class groupDTOMobile{
        @AuraEnabled
        public String groupId {get;set;}
        @AuraEnabled
        public List<serviceDTOMobile> service {get; set;}        
        @AuraEnabled
        public String transitionId{get;set;}//Add new Attribute related to EDGE-85154
        @AuraEnabled
        public Boolean checkValue{get { if(checkValue == null ) checkValue=false; return checkValue;  } Set;}
        @AuraEnabled
        public String disableCheck {get;set;}
        @AuraEnabled
        public List<serviceAssociationsDTO> serviceAssociations {get; set;}
        // EDGE-152495 - Added By ankit ||start
        @AuraEnabled
        public String EligibilityStatus {get;set;}
        @AuraEnabled
        public String EligibilityReason {get;set;}
        // EDGE-152495 - Added By ankit || End
        @AuraEnabled
        public String tramasErrorCode {get; set;}
        
    }
    
    public class serviceDTOMobile{
        //Added for EDGE-198197 by Abhishek(Osaka)
        @AuraEnabled
        public String cidnValue {get; set;}
        @AuraEnabled
        public String tramasErrorCode {get; set;} //EDGE-202851 Kalashree Borgaonkar. Attribute added to identify fault response
        @AuraEnabled
        public String plan_type {get; set;}//Added as per EDGE-145906 Changes
        @AuraEnabled
        public String Service_Id {get; set;}
        @AuraEnabled
        public String TON_Barring_Status{get; set;} // Added by anurag
        @AuraEnabled
        public String Reserve_status{get; set;}
        @AuraEnabled
        public String Reason{get; set;}
        @AuraEnabled
        public String eligibilityStatus {get; set;} 
        @AuraEnabled
        public String eligibilityReason {get; set;}
        @AuraEnabled
        public String Eligibility_status{get; set;}
        @AuraEnabled
        public String service_status {get; set;}
        @AuraEnabled
        public String service_type_code {get; set;}
        @AuraEnabled
        public String service_association_role {get; set;}
        @AuraEnabled
        public String association_type {get; set;}//Added for EDGE-120156
        @AuraEnabled
        public String service_type {get; set;}
        @AuraEnabled
        public String directory_listing {get; set;}
        @AuraEnabled
        public String imsi_number {get; set;}
        @AuraEnabled
        public String sim_serial_number {get; set;}
        @AuraEnabled
        public String calling_line_identifier {get; set;}
        @AuraEnabled
        public String plan_name {get; set;}
        @AuraEnabled
        public String contract_term {get; set;}
        @AuraEnabled
        public String international_roaming {get; set;}
        @AuraEnabled
        public String message_bank {get; set;}
        @AuraEnabled
        public String idd {get; set;}
        @AuraEnabled
        public String tenancy_name {get; set;}//Added for EDGE-120171
        @AuraEnabled
        public String replicatorUpdateDateTime {get; set;}
        @AuraEnabled
        public accountDTO accountDetails {get; set;}
        @AuraEnabled
        public String Reserved_ranges {get; set;}//Added for EDGE-120156
        @AuraEnabled
        public String Redirection_product {get; set;}//Added for EDGE-120156
        @AuraEnabled
        public String silent_line {get; set;}//Added for EDGE-120156
        @AuraEnabled
        public String is_enterprise_trunk {get; set;}//Added for EDGE-101001
        @AuraEnabled
        public String trunk_capacity {get; set;}//Added for EDGE-101001
        @AuraEnabled
        public String tipt_count {get; set;}//Added for EDGE-101001
        @AuraEnabled
        public String sipc_count {get; set;}//Added for EDGE-101001
        @AuraEnabled
        public List<devicesDTO> devices {get; set;}
        @AuraEnabled
            public List<serviceExtensionDTO> serviceExtensions {get; set;}
        @AuraEnabled
        public List<repaymentsDTO> repayments {get; set;} //EDGE-177640 By Abhishek from Osaka Team
        @AuraEnabled
        public List<addOnsDTO> addOns {get; set;}
        //EDGE-179394 changes by Abhishek from Osaka Team----START----
        @AuraEnabled
        public String aro_indicator {get; set;}
        @AuraEnabled
        public String device_lease_contract_indicator {get; set;}
        @AuraEnabled
        public String telstra_one_number_indicator {get; set;}
        @AuraEnabled
        public String mro_with_no_imei {get; set;}
         //EDGE-179394 changes by Abhishek from Osaka Team----END----
        //Added for EDGE-173831 by Abhishek from Osaka Team
        @AuraEnabled
        public String contract_remaining_term {get; set;}
        //Added for EDGE-185055 by Abhishek from Osaka Team
        @AuraEnabled
        public String etc_flag {get; set;}
        //Added for EDGE-205938 by Abhishek(Osaka)
        @AuraEnabled
        public String user_name {get; set;}
        
    }
    //EDGE-177640 By Abhishek from Osaka Team---- START------
    public class repaymentsDTO {
        @AuraEnabled
        public String productID {get; set;}
        @AuraEnabled
        public String Service_Id {get; set;}
        @AuraEnabled
        public String deviceID {get; set;}
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
    //EDGE-177640 By Abhishek from Osaka Team---- END------
    
    public class addonsDTO {
        @AuraEnabled
        public String addOnName {get; set;}
        @AuraEnabled
        public String productCode  {get; set;}
    }
    public class accountDTO {
        @AuraEnabled
        public String accountNumber{get; set;}
        @AuraEnabled
        public String complexBillingIndicator {get; set;}
        @AuraEnabled
        public String creditManagementFlag {get; set;}
        @AuraEnabled
        public String serviceWithEtcFlag {get; set;} 
        @AuraEnabled
        public String dealerCode {get; set;} //Added as per EDGE-145906 Changes
        @AuraEnabled
        public String businessnumber {get; set;}//Added as per EDGE-195976 changes by Pradeep Mudenur(Osaka)
        @AuraEnabled
        public String sourceCIDN {get; set;} //Added as per EDGE-195976 changes by Pradeep Mudenur(Osaka)
    }

    public class devicesDTO {
        @AuraEnabled
        public String deviceType {get; set;}
        @AuraEnabled
        public String physicalId {get; set;}
        @AuraEnabled
        public String networkId {get; set;}
    }
    
        public class serviceExtensionDTO {
        @AuraEnabled
        public String tramasErrorCode {get; set;} //EDGE-202851 Kalashree Borgaonkar. Attribute added to identify fault response
        @AuraEnabled
        public String serviceExtensionFrom {get; set;}
        @AuraEnabled
        public String serviceExtensionTo {get; set;}
        @AuraEnabled
        public String Reserve_status{get; set;}
        @AuraEnabled
        public String Reason{get; set;}
        @AuraEnabled
        public String eligibilityStatus {get; set;} 
        @AuraEnabled
        public String eligibilityReason {get; set;}
        @AuraEnabled
        public Boolean checkReserved{get { if(checkReserved == null ) checkReserved=false; return checkReserved;  } Set;} 
    }
    
    public class serviceAssociationsDTO {
        @AuraEnabled
        public String linkedServiceId {get; set;}
        @AuraEnabled
        public String linkedServiceRole {get; set;}
         
    }
    public static TransitionDataDTO parse(String json) {
        return (TransitionDataDTO) System.JSON.deserialize(json, TransitionDataDTO.class);
    } 
}