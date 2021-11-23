/***********************************************************************************************************
Class Name : PricingAPIResponse
Description : Wrapper class to handle rest api request
Created By : Team Nirvana
User Story : DIGI-32339,DIGI-16483,DIGI-16567
************************************************************************************************************/

 

global class PricingAPIResponse{
    
    public String code {set;get;}
    public String status {set;get;}
    public String message {set;get;}
    public String marketableOfferId {set;get;}
    public String sourceSystem {set; get;}
    public String cidn {set;get;}
    public List<priceDetails> priceDetails{set;get;}
    public List<errors> errors{set;get;}
    
    global class priceDetails{
        public String ProductCode {set;get;}
        public String StandardPrice {set;get;}
        public String DiscountedPrice {set;get;}
        public String isGSTIncluded {set;get;}
        public String ChargeType {set;get;}
    }
    
    global class errors{
        public String failure {set;get;}
        public String value {set;get;}
        public String errorCode {set;get;}
        public String message {set;get;}
    }
}