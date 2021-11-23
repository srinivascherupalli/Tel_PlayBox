/* ****************************************************************************
* Class Name    : Script_AttributeSpecsMSDIN 
* Author        : Vitap Ramdevputra : DPG-2396
* Date          : 14 Aug 2020
* Description   : Update Mobile number from additional attribute.
* TestClass     : Script_AttributeSpecsMSDINTest
* *****************************************************************************/
public with sharing class Script_AttributeSpecsMSDIN {
  public class Specification {
        public List<ServiceScriptSpecification> specifications;
        public String serviceId;
    }
  public class ServiceScriptSpecification {
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
        public attributes attributes;
        public additionalAttributes additionalAttributes;
    }
     public class attributes{
          public String IMSI;
          public String SERVICEPROFILE;
           public String CustomerFacingServiceId;
     }
      public class additionalAttributes{
           public String CustomerFacingServiceId;
     }
  public static List<ServiceScriptSpecification > parseSpec(String jsonStr) {
   system.debug('jsonStr:::'+jsonStr);
        List<ServiceScriptSpecification > selectedServiceSpecifications = new List<ServiceScriptSpecification >();
        Specification serviceSpecs = (Specification) System.JSON.deserialize(jsonStr, Specification.class);
        if(serviceSpecs != null) {
          system.debug('selectedServiceSpecifications:::'+serviceSpecs );
            selectedServiceSpecifications.addAll(serviceSpecs.specifications);
            for(ServiceScriptSpecification  spec: selectedServiceSpecifications){
                spec.serviceId = serviceSpecs.serviceId;
            }
        }
        return selectedServiceSpecifications;
    }
}