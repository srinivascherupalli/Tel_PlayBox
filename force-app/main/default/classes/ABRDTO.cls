public class ABRDTO {
    public String status {get; set;}
    public String typeCode {get; set;}
    public String typeDescription {get; set;}
    public String registeredName {get; set;}
    public String tradingName {get; set;}
    public String errorDescription {get; set;}
    public Date lastValidatedDate {get; set;}
    public String postcode {get; set;}
    public String state {get; set;}
    public String abn {get; set;}
    public List<OtherEntity> otherEntities {get; set;}

    public class OtherEntity {
        public String name {get; set;}
        public String type {get; set;}
        public String fromDate {get; set;}
    }
}