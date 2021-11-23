/*
===============================================================================================================================
Class : CS_ServiceSpecificationV2
Developer Name : Shubhi
Test Class : CS_ServiceSpecificationV2Test
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  3/9/2019     Edge-107843 CS should maintain the association of account to 
                                            subscription / service to device identifiers during 
                                            NEW / MAC scenarios so that reverse logistics solution can be supported
2.        shubhi Vijayvergia  24/9/2019     <Forward Logistics> Device Modelling : Mobile Device and Broadsoft Device Product 
                                            Module change to rename the device identifier
                                            attribute name and introduce device identifier type
3.        Ankit Goswami       08/12/2020        EDGE-193752: Device Id and Device status update
4.       Suyash Chiplunkar   10/08/2021     DIGI-4289 - DPG | SD-WAN | CloudSense to create assets for SD-WAN related subscriptions
===============================================================================================================================
*/
public class CS_ServiceSpecificationV2 {

    public List<LegacyAttributes> legacyAttributes {get;set;} 
    public String serviceId {get;set;} 
    public List<ServiceSpecifications> specifications {get;set;}

    public class DeviceAttributes{//DIGI-4289
        public String sku;
    }
    public class Device {//DIGI-4289
    public DeviceAttributes attributes;
  }
    public class Attributes {
        public String targetSystem {get;set;} // in json: __targetSystem
        public String SERVICEPROFILE {get;set;} 
        public String IPWirelessProductInstanceID {get;set;} 
        public String BillofMaterialID {get;set;} 
        public String AccessRole {get;set;} 
        public String CONTEXT {get;set;} 
        public String parentSpec {get;set;} 
        public String SKU {get;set;} 
        public String SuspensionContext {get;set;} 
        public String CustomerFacingServiceId {get;set;} 
        public String ShippingRequired {get;set;} 
        public String IMSI {get;set;} 
        public String deviceUUID {get;set;}
        public String DeviceID {get;set;} //Edge-112340 //Added as part of EDGE-193752
        public String DeviceIDType {get;set;} //Edge-112340 //Added as part of EDGE-193752
        public String MESSAGEBANK {get;set;}
        public Integer quantity {get;set;}
        public Integer deviceQuantity {get;set;}
        public List<Device> Device {get;set;} //DIGI-4289

    }
    
    
    public class ServiceSpecifications {    
        public Attributes attributes {get;set;}
        public AdditionalAttributes additionalAttribute {get;set;}
        public List<LegacyAttributes> metadatas {get;set;}
        public String version;
        public String status;
        public String startDate;
        public String specification;
        public String productConfigurationId;
        public String name;
        public String instanceId;
        public String identifier;
        public String guid;
        public String endDate;
        public String description;
        public String code;
        public String subscriptionId;
        public String serviceId;
        public String quantity;
        public string deviceQuantity;
    }   
    
    public class AdditionalAttributes {
        public String CustomerFacingServiceId {get;set;} 

    }
    public class LegacyAttributes {
    }
    
    public static List<ServiceSpecifications> parseSpec(String jsonStr,String targetSystem) {
        List<ServiceSpecifications> selectedServiceSpecifications = new List<ServiceSpecifications>();
        system.debug('Json string'+jsonStr);
        CS_ServiceSpecificationV2 serviceSpecsList = (CS_ServiceSpecificationV2) System.JSON.deserialize(jsonStr, CS_ServiceSpecificationV2.class);
        //CS_ServiceSpecificationV2 serviceSpecsList = (CS_ServiceSpecificationV2) JSON.deserialize(jsonStr, Type.forName('CS_ServiceSpecificationV2'));
        system.debug('deserializedList-->'+serviceSpecsList);
        if(serviceSpecsList != null) {
            selectedServiceSpecifications.addAll(gettargetSpec(serviceSpecsList, targetSystem));
        }
        return selectedServiceSpecifications;
    }
    @TestVisible
    private static List<ServiceSpecifications> gettargetSpec(CS_ServiceSpecificationV2 srvSpec, String targetSystem){
        List<ServiceSpecifications> selectedServiceSpecifications = new List<ServiceSpecifications>();
        for(ServiceSpecifications spec : srvSpec.specifications) {
            if(spec.code.contains(targetSystem)) {
                selectedServiceSpecifications.add(spec);
           }
        }
        return selectedServiceSpecifications;
    }

}