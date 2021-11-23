public class EDMMACServiceUtilsV2 {
    
    public class serviceSpecDelta{
        //public List<String> removed;// {get; set;}
        public String oldServiceId;// {get; set;}
        public String newServiceId;// {get; set;}
        public List<deltaDTO> changed;// {get; set;}
        //public List<String> added;// {get; set;}
    }
    
    public class deltaDTO{
		public String status {get; set;}
		public String name {get; set;}
		public String instanceId {get; set;}
        public String description {get; set;}
        public String guid {get; set;}
        public List<NonCommercialAttr> changedNonCommercialAttributes {get; set;}
        public List<Attribute> changedAttributes {get; set;}
        public List<Attribute> changedAdditionalAttributes {get; set;}
    }
    public class Attribute{
		public String name {get; set;}
		public String newValue {get; set;}
		public String originalValue {get; set;}
		
	}
    public class NonCommercialAttr{
        public List<Attribute> removedAttributes {get; set;}
        public String name {get; set;}
        public List<Attribute> changedAttributes {get; set;}
        public List<Attribute> addedAttributes {get; set;}

    }
    
    public class ProductConfigurations{
        String replacedProductConfigurationId{get; set;}
        String productConfigurationId{get; set;}
        List<String> changedAttributes{get; set;}
    }
    
    public static serviceSpecDelta parse(String json){
        System.debug('serviceSpecDelta json====>'+json);
        serviceSpecDelta srvDelta = new serviceSpecDelta();
        srvDelta = (serviceSpecDelta) System.JSON.deserialize(json, serviceSpecDelta.class);
        
        return srvDelta;
    }
}