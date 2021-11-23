/*------------------------------------------------------------ 
Company: Telstra 
Description: Controller for the Address search 
Test Class: AddressSearchTest 
History :
<18-04-2019> <Kalashree Borgaonakar> <EDGE-76217 Updated the class for mapping> 
------------------------------------------------------------*/
public class AddressResponseDTO {
    public Integer code;
    @AuraEnabled
    public Integer status;
    public String responseTime;
    @AuraEnabled
    public Data data;
    public String correlationId;
    public Request request;
    public List<Error> errors;
    public String message;
    public String ErrorCode;
    public String ErrorDescription;
    public DataZ dataZ;
    public List<results> results ; //EDGE-76217
    
    public class Data {
        public String transactionStatus;
        @AuraEnabled
        public Structured structured;
        @AuraEnabled
        public UnstructuredAUPost unstructuredAUPost;
        public Integer matchingresultscount;
        
    }
    //EDGE-76217 : Added this to parse unstructured/Structured response
    public class DataZ{
        public Integer resultCount;
        public List<Structured> structured;
        public List<UnstructuredAUPost> unstructuredAUPost;  
        public String transactionStatus ;
    }   
    
  //EDGE-76217 : Added this to parse auto-complete search response
    public class results{
        public String source ;
        public Integer position ;
        public String raw ;
        public String name ;
    }
   
    public class UnstructuredAUPost {
        @AuraEnabled
        public Addresses addresses;
        public ServiceLocation serviceLocation;
    //EDGE-76217 start
    public String addressSummaryType ;
        public String addressId ;
        public String addressType ;
        public String reqaddformatout ;
        public Boolean confirmed ;
        public String postcode ;
        public String state ;
        public String localityName ;
        public String condorCode ;
        public String addressline1 ;
        public String addressline2 ;
        public String addressline3 ;
        public String planNumber ;
        public String parcelNumber ;
        public String parcelType ;
        public String parcelDescriptor1Prefix ;
        public String fsam ;
        public String subAddressType ;
    //EDGE-76217 end
    }
    
    public class Structured {
        @AuraEnabled
        
        public Addresses addresses;
        public Integer numSubaddresses;
       
        public String streetSuffix ; 
        public ServiceLocation serviceLocation;
        public String addressSummaryType;
        public String addressId;
        public String addressType;
        public Boolean confirmed;
        public String reqaddformatout;
        //public Integer numSubaddresses;
        public String planNumber;
        public String parcelNumber;
        public String parcelType;
        public String parcelDescriptor1Prefix;
        public String postcode;
        public String state;
        public String localityName;
        public String streetName;
        public String streetType;
        public String postalDeliveryType;
        public String postalDeliveryNumber;
        public Integer propertyNumberFrom;
        public String propertyNumberTo; 
        public Subaddresses subaddresses;
        public String parcelDescriptionType1 ; 
        public String parcelDescriptionType2 ; 
        public String parceltype1;
        public String parcelDescriptor1;
        public String parceltype2;
        public String parcelDescriptor2;
        public String name;
        public Parent parent ;
        //EDGE-76217 start
    public String condorCode;
        public String fsam;
    public String subAddressType ;
        public String ruralmailType ;
        public String ruralmailNumber ;
    public Structured primarySummary ;
        public String subAddressNumberFrom ; 
        public String subAddressCodeset ;
    //EDGE-76217 end
    }
    
    public class Addresses {
        public String addressSummaryType;
        @AuraEnabled
        public String addressId;
        @AuraEnabled
        public String addressType;
        @AuraEnabled
        public Boolean confirmed;
        public String subAddressType;
        public String planNumber;
        public String parceltype1;
        public String parceldescriptiontype1;
        public String parcelDescriptor1;
        public String parceltype2;
        public String parceldescriptiontype2;
        public String parcelDescriptor2;
        public String name;
        public String ruralmailNumber;
        public String ruralmailType;
        public String fsam;
        public String condorCode;
        public String reqaddformatout;
        @AuraEnabled
        public String postcode;
        @AuraEnabled
        public String state ; 
        @AuraEnabled
        public String localityName ;
        public String propertyName ; 
        public String propertyNumberFrom ; 
        public String propertyNumberTo ;
        @AuraEnabled
        public String streetName ;
        @AuraEnabled
        public String streetType ; 
        public String streetSuffix ; 
        public Integer numSubaddresses ; 
        public String propertyNumberSuffixFrom ; 
        public String propertyNumberSuffixTo ; 
        public String addressline1 ; 
        public String addressline2 ; 
        public String addressline3 ; 
        public String subAddressNumberFrom ; 
        public String subAddressCodeset ; 
        public Subaddresses subaddresses ; 
        public PrimarySummary primarySummary ; 
        public String postalDeliveryNumber;
        public String postalDeliveryType ;
        public Parent parent ; 
    }
    
    public class Parent {
        public String addressSummaryType ; 
        public String addressId ; 
        public String addressType ; 
        public Boolean confirmed ; 
        public String reqaddformatout ; 
        public Integer numSubaddresses ; 
        public String subAddressCodeset ; 
        public String subAddressNumberFrom ; 
        public String parcelDescriptor1 ; 
        public String parcelDescriptionType1 ; 
        public String name ; 
        public String condorCode ; 
        public String subAddressType ; 
        public String streetType ; 
        public String propertyNumberFrom ; 
        public String propertyNumberTo ; 
        public String postcode ; 
        public String state ; 
        public String localityName ; 
        public String planNumber ; 
        public String parcelType1 ; 
        public ServiceLocation serviceLocation ; 
        public Parent parent ; 
    }
    
    public class PrimarySummary {
        public String addressId ; 
        public String addressType ; 
        public Boolean confirmed ; 
        public String reqaddformatout ; 
        public String localityName ; 
        public String state ; 
        public String postcode ; 
        public String propertyName;
        public String propertyNumberFrom ; 
        public String propertyNumberTo ; 
        public Integer numSubaddresses ; 
        public String streetType ; 
        public String streetName ; 
        public String planNumber ; 
        public String parcelDescriptor1 ; 
        public String parcelDescriptionType1 ; 
        public String parcelType1 ; 
        public String condorCode ; 
        public ServiceLocation serviceLocation ; 
    }
    
    public class ServiceLocation {
        public String readyForServiceDate ; 
        public String locationId ; 
        public String facsRealm ; 
        public String exchangeServiceArea ; 
        public String customerServiceAreaId ; 
        public String latitude ; 
        public String longitude ; 
    }
    
    public class Subaddresses {
        public SubAddresses SubAddresses ; 
        public List<Level1> Level1 ;
    }
    
    public class Level1 {
        public String SubAddressType ; 
        public Integer parentID ; 
        public Integer ID ; 
        public String AddressType ; 
        public String levelFrom ; 
        public Boolean Confirmed ; 
        public String BUname ; 
        public List<Level2> Level2 ;
    }
    
    public class Level2 {
        public String AddressType ;
        public String SubAddressType ; 
        public Integer ID ;  
        public Integer parentID ; 
        public Boolean Confirmed ; 
        public String levelFrom ; 
        public String BUname ; 
        public List<Level3> Level3 ; 
    }
    
    public class Level3 {
        public String SubAddressType ; 
        public Integer parentID ; 
        public Integer ID ; 
        public String AddressType ; 
        public String levelFrom ; 
        public Boolean Confirmed ; 
        public String BUname ; 
    }
    
    public class Request {
        public Params params ;
        public AddressRequest.Data data;
        public String path ;
        public String method ; 
        public String requestId ; 
        public String correlationId ; 
    }
    
    public class Error {
        public String code;
        public String message;
    }
    
    public class Params {
        public String addressId ; 
        public String reqaddformatout ; 
        public String correlationId ;
    }
    
    public static AddressResponseDTO parse(String json) {
        String jsonString = json.replace('"time"', '"responseTime"');
        jsonString = jsonString.replace('"from"', '"levelFrom"');
        return (AddressResponseDTO) System.JSON.deserialize(jsonString, AddressResponseDTO.class);
    }
    
  /*------------------------------------------------------------ 
    Method: parseStructure 
    Description: Parse addressSQ response for strucured/unstructured search
    Inputs: response json
    Returns:  AddressResponseDTO
    History 
    <18-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
  public static AddressResponseDTO parseStructure(String json) {
        String jsonString = json.replace('"time"', '"responseTime"');
        jsonString = jsonString.replace('"from"', '"levelFrom"');
        jsonString = jsonString.replace('"data"', '"dataZ"');
        return (AddressResponseDTO) System.JSON.deserialize(jsonString, AddressResponseDTO.class);
    }
    /*------------------------------------------------------------ 
    Method: parse_unstruct 
    Description: Parse addressSQ response for auto-complete search
    Inputs: response json
    Returns:  AddressResponseDTO
    History 
    <18-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
  public static AddressResponseDTO parse_unstruct (String json) {
      return (AddressResponseDTO) System.JSON.deserialize(json.replace('number','number_x'),AddressResponseDTO.class);
   }
}