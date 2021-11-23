public class GenerateServiceSpecs {
    public string serviceId;
    public list<ServiceSpecificationsStructure> specifications;
    public class ServiceSpecificationsStructure{
        public String version; 
        public String status; 
        public String startDate; 
        public Map<string,string> attributes; 
        public String replacedSpecification;
        public String productConfigurationId; 
        public String name; 
        public String instanceId; 
        public String identifier; 
        public String guid; 
        public String endDate; 
        public String description;
        public String code; 
        public map<String,String> additionalAttributes; 
        public String subscriptionId;
        public String offerId;
    }
    

    // returns JSON array structure of attributes
    public static Map<string,string> getAttributes(list<CS_SpecificationDTO.SimpleAttributes> attributes){
        Map<string,string> attributeMap= new Map<string,string>();
        if(attributes != null){
            for(CS_SpecificationDTO.SimpleAttributes attr:attributes){
                attributeMap.put(attr.name, attr.value);
            }
            return attributeMap;
        }
        return null;
    }
    // EDGE-187502 returns JSON array structure of attributes
    public static Map<string,string> getadditionalAttributes(list<CS_SpecificationDTO.SimpleAttributes> attributes){
        Map<string,string> attributeMap= new Map<string,string>();
        if(attributes != null){
            for(CS_SpecificationDTO.SimpleAttributes attr:attributes){
                attributeMap.put(attr.name, attr.value);
            }
            return attributeMap;
        }
        return attributeMap;
    }
    
    public static string getGuid(){
        //generate GUID
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        return guid;
    }
}