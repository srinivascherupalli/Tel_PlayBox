/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: SQ Check for Mobile/MSISDN Lightning Response DTO.
*/

public class SQCheckMobileResponseDTO {
    
    public Integer status;
    public Data data;
    public Error errors;
    public List<Error> errors_z;
    public String correlationId;
    public String message;
    public String responseTime;
    
    
    public class NumberDetails {
        public String mobileNumber;
        public String mobileNumberPortabilityIndicator;
        public String reason;
        public String code;
    }
    
    public class Data {
        public List<NumberDetails> numberDetails;
    }
    
    public class Error{
        public List<ErrorDetails> errorDetails;
    }
    
    public class ErrorDetails{
        public String message;
        public String code;
    }
    
    public class errors_z{
        public String message;
        public String code;
        //public List<ErrorDetails> errorDetails;
    }
    
    public static SQCheckMobileResponseDTO parse(String json) {
       
        String jsonString = json.replace('time', 'responseTime');
        
         if(json.contains('\"code\":429,')){
             System.debug('In if');
            jsonString = jsonString.replace('errors', 'errors_z');
        }
        return (SQCheckMobileResponseDTO) System.JSON.deserialize(jsonString, SQCheckMobileResponseDTO.class);
    }
    
}