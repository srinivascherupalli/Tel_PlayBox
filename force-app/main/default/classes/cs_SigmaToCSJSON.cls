/*Story number: EDGE-48915
Description: Sigma to CS mapping
ChagneSet No    Name            Date                    Description
CH-1            Abinash         12/13/2018			SIGMA to CS Adapter Changes to receive the offer, 
													subscription, product module version numbers and 
													store it in cloudsense against required entities.	
Story number:EDGE-206
  Description: JSON parser class for sigma to CS mapping
*/ 

public class cs_SigmaToCSJSON {
    public cls_productOffering productOffering;
    public class cls_productOffering {
        public String specId; //OF_000021
        public String name; //Connected Workplace
        public String externalId; //85776ed4-e9eb-49d3-8af5-4fbdda0df6e9
        public String version; //CH-1
        public cls_products[] products;
    }
   public class cls_products {
        public String specId; //PS_000053
        public String endDate; //2099-12-30T13:00:00.000Z
        public String associationEndDate; //2099-12-30T13:00:00.000Z
        public String name; //Managed Radius
        public String externalId; //19ec8043-0de6-453d-b847-7f210a0e9fca
        public String type_x; //Default_Product_Specification
        public String startDate; //2017-10-25T13:00:00.000Z
        public String associationStartDate; //2099-12-30T13:00:00.000Z
        public String version; //CH-1
        public cls_attributes[] attributes;
        public cls_products[] products;
        public cls_charges[] charges;
        public cls_allowances[] allowances;
        public String action;
        public cls_productStaticCharacteristics[] productStaticCharacteristics;
    public cls_mappingRules[] mappingRules;
    }
    public class cls_attributes {
        public String default_x; //
        public String interfaceName; //Customer Facing Service Id
        public String type_x; //ui
        public List < String > values;
        public String isProvisionable;
        public cls_staticCharacteristics[] staticCharacteristics;
    }
    public class cls_charges {
        public String specId;
        public String type_x; //
        public String currency_x; //Customer Facing Service Id
        public String frequency_x; //ui
        public String billingSpecId; //billing spec id
        public String billInAdvance; // billing in advance boolean condition
        public string taxTreatment; // //added for edge 33964 for GST calculation
        public String prorate; //prorate boolean value
        public string unitofMeasure; //// Edge-38256
        public cls_prices[] prices;
		public string billingSubType;
    }
    public class cls_prices {
        public String startdate; //
        public String enddate; //Customer Facing Service Id
        public String term; //ui
        public String externalId; //
        public String billingId; //Customer Facing Service Id
        public String rateExcludeGST;
        public String billDescription; // billing description 
        public cls_prices_attribute[] attributes;
    }
    public class cls_prices_attribute {
        public String name; //Customer Facing Service Id
        public String value;
    }
    public class cls_allowances {
        public String name; 
        public String specId; 
        public String startDate; 
        public String endDate; 
        public String associationStartDate; 
        public string associationEndDate;
        public String billingSpecId; 
        public string ocsProdID; 
        public cls_allowanceDetails[] allowanceDetails;
    }
    public class cls_allowanceDetails {
        public String externalId; 
        public String startdate; 
        public String enddate; 
        public String type_x; 
        public String unitofMeasure; 
        public String value;
    }
    
    public class cls_productStaticCharacteristics{
        public String name;
        public String value;
    }   
    public class cls_staticCharacteristics{
        public String name;
        public String value;
    }
  
  public class cls_mappingRules
  {
    public String type;
    public String dependencyRule;
    public String name;
    public cls_prodId_instanceId source;
    public cls_prodId_instanceId target;
  }
  public class cls_prodId_instanceId
  {
    public String productId;
    public String characteristicId;
  }

    public static cs_SigmaToCSJSON parse(String json) {
        String jsonstring = json.replace('"default"', '"default_x"');
        jsonstring = jsonstring.replace('"currency"', '"currency_x"');
        jsonstring = jsonstring.replace('"type"', '"type_x"');
        jsonstring = jsonstring.replace('"frequency"', '"frequency_x"');
        system.debug('vanita check jsonstring' + jsonstring);
        return (cs_SigmaToCSJSON) System.JSON.deserialize(jsonstring, cs_SigmaToCSJSON.class);
    }

}