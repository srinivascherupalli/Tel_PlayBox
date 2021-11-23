//EDGE-211 SigmatoJSON 

public class sigmaToJSON{
    public cls_package package_x;
    public class cls_package {
        private String name; //Marketable offer Name
        private String externalId;   //Sigma GUID as External ID (do we still need this?)
        private String specId;   //Sigma unique spec ID. Should be unique for all envs (mapped to CS PD if required)
        private cls_products_package[] products;
        private cls_charge_package[] charge;
    }
    public class cls_products_package {
        private String name; //product name
        private String type; //Product/Group
        private String isProvisionable; //"true/false"
        private String specId; //Sigma Spec ID (mapped to CS PD if required)
        private String startDate; //Product Marketable Start Date in CS
        private String endDate;//Product Marketable End Date in CS
        private cls_attributes_products[] attributes;
        //public cls_productSpecs[] productSpecs;
        private cls_charge_products[] charge;
        private cls_products_products[] products;
    }
    
    public class cls_attributes_products{
        private String name; //Name of the attribute
        private String type; //User Input/System Defined/uiLOV/sdLOV. This need to discuss with Sigma more
        private String values; //"[]"
        private String default_x; //Default Value
    }
    
    public class cls_charge_products{
        private String type; //OC/RC
        private String currency_x; //AUD
        private String frequency; //Monthly/Weekly/Yearly
        private list<cls_price_charge> price; 
        
        
    }
    
    public class cls_price_charge {
        private cls_attributes_price[] attributes;
        private String startDate; //"Price Start Date in CS"
        private String endDate; //"Price End Date in CS"
        private String term; //[]
        private String externalId; //"Sigma GUID as External ID. This will be use as price external ID for CS pricing model"
        private String billingId; //"Sigma unique spec ID for billing. Should be unique for all envs. Not for Sprint Challenge 1"
        private String rateExcludeGST; //price(amount)
        
    }
    
    public class cls_attributes_price {
        private String name; //Attribute Name (this will be the custom field label?)
        private String value;    //Attribute value
    }
    

    public class cls_products_products {
        private String name; // "Product Name"
        private String template; //"Product/Group"
        private String isProvisionable; //"True/False",
        private String specId; //"Sigma Spec ID (mapped to CS PD if required)"
        private String startDate; //"Product Marketable Start Date in CS"
        private String endDate; //"Product Marketable End Date in CS"
        private cls_attributes_products[] attributes;
        private cls_price_charge[] charge;
        private cls_products_empty[] products;
        
        
    }
    
    
    public class cls_products_empty {
        private cls_products_package[] products;
    }
    
    
    public class cls_charge_package {
        
    }
    

    public static sigmaToJSON parse(String json){
        String jsonstring = json.replace('"default":', '"default__x":');
        jsonstring = json.replace('"currency":', '"currency__x":');
        jsonstring = json.replace('"package":', '"package__x":');
        system.debug('vanita check jsonstring'+jsonstring);
        return (sigmaToJSON) System.JSON.deserialize(jsonstring, sigmaToJSON.class);
    }

}