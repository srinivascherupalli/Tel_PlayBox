@isTest
public class ABRTestUtils {
    
    public static ABRDTO getABRDTO(String status, String errorDesc) {
        ABRDTO dto = new ABRDTO();
        dto.lastValidatedDate = Date.today();
        dto.postcode = '3000';
        dto.registeredName = 'Registered Name';
        dto.state = 'VIC';
        dto.status = status;
        dto.typeCode = 'Type';
        dto.typeDescription = 'Type Description';
        dto.tradingName = 'Trading Name';
        dto.errorDescription = errorDesc;
        return dto;
    }
    
    public static String getStaticResourceBody(String name) {
        StaticResource resource = [	SELECT id, name, body 
                                   	FROM StaticResource
                                    WHERE name = :name];
        if(resource != null) {
            return resource.body.toString();
        }
        return null;
    }

}