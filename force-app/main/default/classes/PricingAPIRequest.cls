/***********************************************************************************************************
Class Name : PricingAPIRequest
Description : Wrapper class to handle rest api request
Created By : Team Nirvana
User Story : DIGI-32339,DIGI-16483,DIGI-16567
************************************************************************************************************/
global class PricingAPIRequest{
    public String marketableOfferId {set;get;}
    public String cidn {set;get;}
    public String sourceSystem {set; get;}
    public List<String> productCode{set;get;}
   
}