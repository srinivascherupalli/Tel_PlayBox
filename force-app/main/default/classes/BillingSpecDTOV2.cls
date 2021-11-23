/********************************************************
 Class Name      :   BillingSpecDTOV2
 Test Class : BillingSpecDTOV2Test
 ===============================================================================================================================
 Change.No.    Developer Name          Date          Story Description
 1.            Prajakta Patil        15/10/19        EDGE-115840
 2.            Prajakta Patil        22/11/19        EDGE-99622
 3.            Vaibhav Deshpande     20/01/2020      EDGE-120128
 4.            Vaibhav Deshpande     29/01/2020      EDGE-132475
 5.            Pawan                 30/06/2020      EDGE-156163
 6.            Vaibhav Deshpande     17/07/2020      EDGE-148819
 7.            Vaibhav Deshpande     21/07/2020      EDGE-153454
 8.            Pawan Devaliya        31/08/2020      EDGE-164355
 9.            Shresth Dixit         21/09/2020     DPG-2765/2649
 10            Prajakta Patil        15/10/2020     EDGE-174931
 11.           Vaibhav Deshpande     16/12/2020     EDGE-187676
 12.           Dharmik Shah          09/08/2021     DIGI-2569
 **********************************************************
 */

public class BillingSpecDTOV2 {
    
    public Long billingAccountNumber{get;set;}
    public Long fromBillingAccountNumber{get;set;} //EDGE-152475
    public ProductOffering productOffering{get;set;}
    public List<AdditionalBillInfo> additionalBillInfo{get;set;}
    public String productActionType{get;set;}
    public DateTime  effectiveDate{get;set;}
    public List<OrderItems> orderItems{get;set;}
    public String orderReference{get;set;}
    public String requestType{get;set;} //EDGE-187676
    
    /*public class Services{
        public String serviceId;
        public String actionCode;
        public String serviceType;
        public String imsi;
        public String oldServiceId;
        public List<Characteristic> characteristic;
    }*/
    public class ProductCharacteristics{
        public String serviceId;
        public String actionCode;
        public String serviceType;
        public String imsi;
        public String oldServiceId;
        public List<Characteristics> characteristics;
    }
    
    public class Characteristics {
        //EDGE-81130
        //public String serviceId;
        public String actionCode;
        //public String serviceType;
        //public String imsi;
        //public String oldServiceId;
         
        public String name;
        public String value;
        //End
    }
    
    public class OrderItems {
        public String description;
        public DateTime effectiveDate;
        public String serviceInstanceId;
        public String productId;
        public String productActionType;
        //public List<Services> services;
        public List<ProductCharacteristics> productCharacteristics;
        public List<BillingSpecifications> billingSpecifications;
        //EDGE-81566
        public String scenarioType;
        //DIGI-2569
        public String ocsProductId;
        public String serviceType;
    }
    
    public class ProductOffering {
        public String invoiceDefinition;
        public String productInstanceId;
        public String description;
        //Introducing offerId as part of EDGE-75162
        public String offerId;
        //Introducing offerId as part of EDGE-87688
        public String offerInstanceId;
       //EDGE-112016
        public String isAggregationPoint;
       //EDGE-115840
       public String isSharedQuantity;
       public Boolean autoExpiry; //EDGE-148819
       public Integer expireDurationValue; //EDGE-148819
       public String expireDurationUnit; //EDGE-148819
       public String fromOfferInstanceId;//EDGE-152475
    }
    
    public class AdditionalBillInfo {
        public String name;
        public String value;
    }
    
    //EDGE-81130 inner class for Custom tier pricing
    
    public class CustomRate{
        public String fromUnit{get;set;}
        public String toUnit{get;set;}
        public String unitPrice{get;set;}
        public String externalRateId{get;set;} //EDGE-153454
    }
    //DPG-2649 start 
    public class RateGroup{
        public String rateGroupId{get;set;}
        public List<CustomRate> customRate{get;set;}
    }
    //DPG-2649 end
    
    //End EDGE-81130
    
    public class BillingSpecifications { 
        public String instanceId;
        public String actionCode;
        public String description;
        public String billingSpecId;
        public String featureId;
        public String frequency;
        public String currencyCode;
        public String ocsProductId;
        public String billInAdvance;
        public String prorateType;
        //EDGE - 123083
        public Double units;
        public Double unitPrice;
        public String billingSubtype;
        public String purchaseOrderNumber;
        
        //EDGE-164355
        public String refundFlag;

        //Changed durationValue from String to Integer as part of EDGE-75162. BDS is expecting durationValue to be a Number
        public Integer durationValue;

        public String durationUnit;
        //Introducing taxTreatment as part of EDGE-75162
        public String taxTreatment;
        //EDGE-88677:Introducing Price Alteration list for MRO bonus
        public List<priceAlterations> priceAlteration;
        
        //EDGE-81130
        public List<CustomRate> customRate;
        //End

        //DPG-2649
        public List<RateGroup> rateGroups;
        
        //EDGE-99622
        public String otcDescription;
        public String creditDescription;
        
       //EDGE-144163
       public String isRedeemable;
       
       //EDGE-156163 : Pawan
       public String contractType;
       public String chargeId; //EDGE-153454
       public String externalRateId; //EDGE-153454 
       
       
        public Double monthlyPrice; // EDGE-174931
        
        public Integer originalDuration; // DIGI-19347 by Osaka
    }
    
        //START: EDGE-88677:This attributes comes as a list under billingSpecifaction 
        public class priceAlterations {
        //EDGE-88677:Introducing Price Alteration list for MRO bonus
        public Double unitPrice;
        public Integer applicationDuration;
        public String description;
        //START: EDGE-91410
        //public String priority; //EDGE-91410: priority is removed
        //END: EDGE-91410
        public String recurringChargePeriod;
        public String actionCode;//EDGE-120128 - added actionCode
        public String instanceId;//EDGE-120128 - added instanceId
        public List<CustomRate> customRate;
          
    }
        //END: EDGE-88677
    
    public static BillingSpecDTOV2 parse(String json) {
        return (BillingSpecDTOV2) System.JSON.deserialize(json, BillingSpecDTOV2.class);
    }
}