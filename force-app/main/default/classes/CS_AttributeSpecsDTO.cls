public with sharing class CS_AttributeSpecsDTO {

	public class Specification {
        public List<ServiceSpecification> specifications;
        public String serviceId;
    }
	
	public class ServiceSpecification {
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
    }

    public static List<ServiceSpecification> parseSpec(String jsonStr,String targetSystem) {
        List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
        Specification serviceSpecsList = (Specification) System.JSON.deserialize(jsonStr, Specification.class);
        if(serviceSpecsList != null) {
            selectedServiceSpecifications.addAll(gettargetSpec(serviceSpecsList, targetSystem));
        }
        return selectedServiceSpecifications;
    }
	
	public static List<ServiceSpecification> parseSpec(String jsonStr) {
        List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
        Specification serviceSpecsList = (Specification) System.JSON.deserialize(jsonStr, Specification.class);
        if(serviceSpecsList != null) {
            selectedServiceSpecifications.addAll(serviceSpecsList.specifications);
            for(ServiceSpecification spec: selectedServiceSpecifications){
                spec.serviceId = serviceSpecsList.serviceId;
            }
        }
        return selectedServiceSpecifications;
    }

    @TestVisible
    private static List<ServiceSpecification> gettargetSpec(Specification srvSpec, String targetSystem){
        List<ServiceSpecification> selectedServiceSpecifications = new List<ServiceSpecification>();
        for(ServiceSpecification spec : srvSpec.specifications) {
            if(spec.code.contains(targetSystem)) {
                selectedServiceSpecifications.add(spec);
           }
        }
        return selectedServiceSpecifications;
    }
}