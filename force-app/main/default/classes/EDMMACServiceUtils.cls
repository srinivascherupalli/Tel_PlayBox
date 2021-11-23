public class EDMMACServiceUtils {
    
    public class serviceSpecDelta{
        public List<String> removed;// {get; set;}
        public String oldServiceId;// {get; set;}
        public String newServiceId;// {get; set;}
        public List<deltaDTO> changed;// {get; set;}
        public List<String> added;// {get; set;}
    }
    
    public class deltaDTO{
        public String instanceId {get; set;}
        public String guid {get; set;}
        public List<NonCommercialAttr> changedNonCommercialAttributes {get; set;}
        public List<String> changedAttributes {get; set;}
        public List<String> changedAdditionalAttributes {get; set;}
    }
    
    public class NonCommercialAttr{
        public List<String> removedNonCommercialProductConfigurations {get; set;}
        public String name {get; set;}
        public List<ProductConfigurations> changedNonCommercialProductConfigurations {get; set;}
        public List<String> addedNonCommercialProductConfigurations {get; set;}

    }
    
    public class ProductConfigurations{
       	public String replacedProductConfigurationId{get; set;}
        public String productConfigurationId{get; set;}
        public List<String> changedAttributes{get; set;}
    }
    
    public static serviceSpecDelta parse(String json){
        System.debug('json vani====>'+json);
        serviceSpecDelta srvDelta = new serviceSpecDelta();
        srvDelta = (serviceSpecDelta) System.JSON.deserialize(json, serviceSpecDelta.class);
        return srvDelta;
    }
}