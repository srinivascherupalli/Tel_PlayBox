/*************************************************************************************************
Name : FixedNumberRequestDTO
Description : Request DTO for Fixed Number Reservation
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
public class FixedNumberRequestDTO {

    public Data data {get;set;}

    public class Data {
        public String resourceState {get;set;}
        public List<Resources> resources {get;set;}
         // EDGE-131248-Dheeraj Bhatt-Use Age Out Parameter in MSISDN Reservation Call to HOLD number till certain period.
        @AuraEnabled
        public string ageOut;
    }

    public class Resources {
        public String resourceId {get;set;}
        public String startRange {get;set;}
        public String endRange {get;set;} 
    }

    
    public static FixedNumberRequestDTO parse(String json) {
        
        return (FixedNumberRequestDTO) System.JSON.deserialize(json, FixedNumberRequestDTO.class);
            
        
    }
}