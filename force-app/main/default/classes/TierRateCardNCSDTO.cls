/********************************************************
Class Name      :   TierRateCardNCSDTO
Test Class : TierRateCardNCSHelperTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Venkata Ramanan G     11/10/2019      EDGE-112869  Created for Rate Card population Framework
2.       Kiran          03/12/2019    EDGE-123778  Added externalid
3.       Varun/Monali   12/12/2019    EDGE-123778  Uncommented externalId attribute in class "Configuration"
4.       Shhubhi        12-05-2020    Edge-137067  NCS rate card updates
********************************************************************/

public class TierRateCardNCSDTO {
  public List <Configuration> configurations {get;set;}
    public Schema schema {get;set;}
    public class Attribute{
      public String startDate {get;set;}    
        public Boolean shownInUI {get;set;}
        public Boolean required {get;set;}
        public String name {get;set;}
    }
    public class Schema {
        public String name {get;set;}
        public String id {get;set;}
    public List<Attribute> attributes {get;set;}        
    }
    public class Configuration{
        public String rangeFrom {get;set;}
        public String rangeTo {get;set;}
        public Decimal price {get;set;}
        public String externalId {get;set;} //EDGE-123778
        public string guid {get; set;} //Edge-137067
    }

    public static TierRateCardNCSDTO parse(String jsonString) {
    return (TierRateCardNCSDTO) System.JSON.deserialize(jsonString, TierRateCardNCSDTO.class);
  }
}