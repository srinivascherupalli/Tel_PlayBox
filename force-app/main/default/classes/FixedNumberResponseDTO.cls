/*************************************************************************************************
Name : FixedNumberResponseDTO
Description : Response DTO for Fixed Number Reservation
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
public class FixedNumberResponseDTO {

    public class Data_Z {
        public String resourceState {get;set;} 
        public List<Resources> resources {get;set;} 

    }

    public Integer status {get;set;} 
    public Integer code {get;set;} 
    public String time_x {get;set;} 
    public String correlationId {get;set;} 
    public String path {get;set;} 
    public String method {get;set;} 
    public String responseCode {get;set;} 
    public String message {get;set;} 
    public Data data {get;set;} 
    public List<Errors> errors {get;set;} 
    public Request request {get;set;} 

    public class Request {
        public Params params_x {get;set;} 
        public Data params {get;set;} 
        public String method {get;set;} 
        public String path {get;set;} 
        public Data_Z data {get;set;} 
    }

    public class Params {
    }

    public class Data {
        public List<Resources> resources {get;set;} 
    }
    
        
    public class Resources {
        public String resourceId {get;set;} 
        public String startRange {get;set;}
        public String endRange {get;set;}
        public String countryCode {get;set;} 
        public String countryName {get;set;} 
        public String nationalDestinationCode {get;set;} 
        public String providedToKey {get;set;} 
        public String activityStatus {get;set;} 
        public String resourceState {get;set;} 
        public String ageOut {get;set;} 
        public String ageOutDate {get;set;} 
    }

    
     public class Errors {
        public String resourceId {get;set;}
        public String startRange {get;set;}
        public String endRange {get;set;}
        public String system_Z {get;set;} 
        public String code {get;set;} 
        public String message {get;set;}
    }
    
    
    public static FixedNumberResponseDTO parse(String json) {
        return (FixedNumberResponseDTO) System.JSON.deserialize(json.replace('time', 'time_x').replace('system','system_Z').replace('Data','Data_Z').replace('params','params_x'), FixedNumberResponseDTO.class);
    }
}