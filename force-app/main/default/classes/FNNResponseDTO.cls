public class FNNResponseDTO {
       
    @AuraEnabled
    public Integer status {get;set;}
    @AuraEnabled
    public Integer code {get;set;}
    @AuraEnabled
    public String res_time {get;set;}
    @AuraEnabled
    public String correlationId {get;set;}
    @AuraEnabled
    public String path {get;set;}
    @AuraEnabled
    public String method {get;set;}
    @AuraEnabled
    public String responseCode {get;set;}
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public FNNResponseDataObject data {get;set;}
    @AuraEnabled
    public FNNRequestDataObject request {get;set;}
    @AuraEnabled
    public List<ErrorsDataObject> errors {get;set;}
        
        
    public class FNNResponseDataObject {
        @AuraEnabled
        public List<String> fnns {get;set;}
        @AuraEnabled
        public List<ResourcesDataObject> resources {get;set;}
        @AuraEnabled
        public List<ResultDataObject> result {get;set;}
    }
    
    public class ResourcesDataObject {
        @AuraEnabled
        public String resourceId {get;set;}
        @AuraEnabled
        public String resourceType {get;set;}
        @AuraEnabled
        public String resourceState {get;set;}
        @AuraEnabled
        public Integer poolId {get;set;}
        @AuraEnabled
        public List<CharacteristicsDataObject> characteristics {get;set;}
        @AuraEnabled
        public List<CategoryDataObject> category {get;set;}
        @AuraEnabled
        public List<RelatedResourcesDataObject> relatedResources {get;set;}
    }
    
    public class CharacteristicsDataObject {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    public class CategoryDataObject {
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    public class RelatedResourcesDataObject {
        @AuraEnabled
        public String relationshipType {get;set;}
        @AuraEnabled
        public String resourceId {get;set;}
        @AuraEnabled
        public String resourceType {get;set;}
        @AuraEnabled
        public String resourceState {get;set;}
    }
    
    public class ResultDataObject {
        @AuraEnabled
        public String fnn {get;set;}
        @AuraEnabled
        public String status {get;set;}
    }
    
    public class  FNNRequestDataObject{
        /*@AuraEnabled
        public String params {get;set;}
        @AuraEnabled
        public String method {get;set;}
        @AuraEnabled
        public String path {get;set;}*/
        @AuraEnabled
        public FNNDTO.FNNDataObject data {get;set;}
    }
    
    public class ErrorsDataObject {
        @AuraEnabled
        public String res_system {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String fnn {get;set;}
        @AuraEnabled
        public String activityStatus {get;set;}
    }
    
    //public ENUM RelationshipType  {ASSOCIATION}
    //public ENUM ResourceType      {MSISDN}
    //public ENUM Status            {SUCCESS}
    
    public static FNNResponseDTO parse(String json) {
        System.debug('JSON::' + json);
        return (FNNResponseDTO) System.JSON.deserialize(json.replace('system','res_system').replace('time','res_time'),FNNResponseDTO.class);
    }
    
    public string getErrorMessages() {
        String message = '';

        if (errors != null) {
            for(ErrorsDataObject err : errors) {
                if (message.length() > 0)
                    message = message + ', ';
                message = message  + 'code: ' + err.code + ', ' + err.message;
            }
        }
        return message;
    }
}