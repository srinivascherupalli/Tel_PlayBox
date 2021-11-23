public class AddressResponse {
    
    public Integer code {get;set;} 
    public Integer status {get;set;} 
    public String res_time {get;set;} 
    public String correlationId {get;set;} 
    public Data data {get;set;} 
    public Request request {get;set;} 
    public String message{get;set;}
    public String requestId {get;set;}
    public List<results> results {get;set;}
    
    public class Data {
        public Integer resultCount {get;set;} 
        public List<Structured> structured {get;set;} 
        public List<UnstructuredAUPost> unstructuredAUPost {get;set;} 
        public Structured structured_adbor {get;set;} 
        public UnstructuredAUPost unstructuredAUPost_adbor {get;set;}
        public String transactionStatus {get; set;}
        public Integer matchingresultscount {get; set;}
    }
    
    public class results{
        public String source {get;set;}
        public Integer position {get;set;}
        public String raw {get;set;}
        public String name {get;set;}
    }
  
    public class address {
        public String status {get;set;}
        public Integer matchingresultscount {get; set;}
    }

    public class Structured {
        public String addressSummaryType {get;set;} 
        public String addressId {get;set;} 
        public String addressType {get;set;} 
        public Boolean confirmed {get;set;} 
        public String reqaddformatout {get;set;} 
        public Integer numSubaddresses {get;set;} 
        public String condorCode {get;set;}
        public String fsam {get;set;} 
        public String postcode {get;set;} 
        public String state {get;set;} 
        public String localityName {get;set;} 
        public Integer propertyNumberFrom {get;set;}
        public String propertyNumberTo {get;set;}
        public String streetName {get;set;}
        public String streetType {get;set;}
        public String ruralmailType {get;set;}
        public String ruralmailNumber {get;set;}
        public String postalDeliveryType {get;set;}
        public String postalDeliveryNumberPrefix {get;set;}
        public String postalDeliveryNumber {get;set;}
        public String postalDeliveryNumberSuffix {get;set;}
        public String planNumber {get;set;}
        public String parcelType {get;set;}
        public String parcelNumber {get;set;}
        public String parcelDescriptor1Prefix {get;set;}
        public String parcelDescriptor2 {get;set;}
        public String parcelDescriptionType2 {get;set;}
        public String parcelDescriptor2Prefix {get;set;}
        public ServiceLocation serviceLocation {get;set;}
        public Level1 level1 {get; set;}
        public Subaddresses subaddresses {get; set;}
        public Structured parent {get;set;}
        public Structured primarySummary {get;set;}
        public Structured addresses {get; set;}
        public String subAddressNumberFrom {get; set;} 
        public String subAddressType {get; set;}
        public String subAddressCodeset {get; set;} 
        public Integer number_x {get; set;} //replace
        public Integer numberTo {get; set;}
    }
    
    public class UnstructuredAUPost {
        public String addressSummaryType {get;set;}
        public String addressId {get;set;}
        public String addressType {get;set;}
        public String reqaddformatout {get;set;}
        public Boolean confirmed {get;set;}
        public String postcode {get;set;}
        public String state {get;set;}
        public String localityName {get;set;}
        public String condorCode {get;set;}
        public String addressline1 {get;set;}
        public String addressline2 {get;set;}
        public String planNumber {get;set;}
        public String parcelNumber {get;set;}
        public String parcelType {get;set;}
        public String parcelDescriptor1Prefix {get;set;}
        public String fsam {get;set;}
        public String subAddressType {get;set;}
        public ServiceLocation serviceLocation {get;set;}
        public UnstructuredAUPost addresses {get; set;}
    }
    
    public class ServiceLocation {
        public String latitude {get;set;}
        public String longitude {get;set;}
        public String locationId {get;set;}
        public String customerServiceAreaId {get;set;}
        public String readyForServiceDate {get;set;}
        public String exchangeServiceArea {get;set;}
        public String facsRealm {get;set;}
    }
  
  public class Subaddresses {
        public List<Level1> level1 {get;set;} 
    }
    
    public class Level1{
        public String AddressType {get;set;}
        public String SubAddressType {get;set;}
        public Integer ID {get;set;}
        public Integer parentID {get;set;}
        public Boolean confirmed {get;set;}
        //public Integer res_from {get;set;}
        public String res_from {get;set;}
        public List<Level2> level2 {get;set;}
    }
    
    public class Level2 {
        public String AddressType {get;set;}
        public String SubAddressType {get;set;}
        public Integer ID {get;set;}
        public Integer parentID {get;set;}
        public Boolean confirmed {get;set;}
        public String res_from {get;set;} //dt changed to string
        public List<Level3> level3 {get;set;}
    }
    
    public class Level3 {
        public String AddressType {get;set;}
        public String SubAddressType {get;set;}
        public Integer ID {get;set;}
        public Integer parentID {get;set;}
        public Boolean confirmed {get;set;}
        public String res_from {get;set;} //dt changed to string
    }
 

    
    public class Request {
        public Params params {get;set;}
        public AddressRequest.Data data {get;set;}
        public String path {get;set;}
        public String method {get;set;}
        public String requestId {get;set;}
        public String correlationId {get;set;}
    }
    
    public class Params {
        public String correlationId {get;set;}
        public String addressId {get;set;}
        public String reqaddformatout {get; set;}
    }
  
    public static AddressResponse parse(String json) {
        return (AddressResponse) System.JSON.deserialize(json.replace('time','res_time').replace('from','res_from'), AddressResponse.class);
    }
    
    public static AddressResponse parse_adbor(String json) {
        return (AddressResponse) System.JSON.deserialize(json.replace('structured','structured_adbor').replace('unstructuredAUPost','unstructuredAUPost_adbor').replace('from','res_from').replace('time','res_time').replace('number','number_x'), AddressResponse.class);
  }
  
  public static AddressResponse parse_unstruct (String json) {
    return (AddressResponse) System.JSON.deserialize(json.replace('number','number_x'),AddressResponse.class);
  }
  
}