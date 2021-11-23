/*Story number: EDGE-865
Description: ServiceSpecDetailsResponseDTO is DTO class for GetProductApi; 
*/

global with sharing class ServiceSpecDetailsResponseDTO

{
    
    public DataDTO data {get;set;}
    
    global with sharing class DataDTO{
       
        public String subscriptionId {get;set;}
        public String subscriptionNumber {get;set;}
        public String correlationID {get;set;}
        public String transactionID {get;set;}
        public String transactionTime {get;set;}
        public String serviceNumber {get;set;}
        public Specification specification{get;set;}
        public List<error> error{get;set;}
        
    }
    global with sharing class Specification{
        
        public String version{get;set;}
        public String specExternalID;
        public String status{get;set;}
        public String startDate{get;set;}
        public String serviceId{get;set;}
        public String productConfigurationId{get;set;}
        public String name{get;set;}
        public String modelChange{get;set;}
        public String guid{get;set;}
        public String endDate{get;set;}
        public String description{get;set;}
        public String code{get;set;}
        public List<Attributes> attributes{get;set;}
        
    }
    
    global with sharing class Attributes {
        public Object value{get;set;}
        public String name{get;set;}
    }
    global with sharing class error {
        public String status{get;set;}
        public Integer code{get;set;}
        public String message{get;set;}
        public String correlationID {get;set;}
        
    }
}