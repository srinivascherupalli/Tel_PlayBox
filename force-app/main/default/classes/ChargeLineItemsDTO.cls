/*************************************************************************************************
Name : ChargeLineItemsDTO 
Description : EDGE-123581 : DTO Class for ChargeLineItemsDTO used in class GeneratePriceSchedule
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya      19-Jan-2020   Created 
2.        Pawan Devaliya      11-Feb-2020   Change according to new Json structure
3.        Pawan Devaliya      13-Feb-2020   EDGE-136115 : Defect Fix : Change in datatype of UnitPrice  
4.        Pawan Devaliya      25-Feb-2020   EDGE-124716     Pricing Modify for EM and NGUC   
5.        Pawan               27-Feb-2020   EDGE-135274     Changes for new fields DiscountAmount and applicationDuration
6.        Pawan               20-March-2020 EDGE-132626     Changed code to have single JSON structure for EM, NGUC device and Voice
===============================================================================================================================
***************************************************************************************************/

public class ChargeLineItemsDTO {

    public class TierLineItems {
        public String fromUnit;
        public String toUnit;
        public Double discounted_Price;
        public Double appliedDiscountAmount;
        public String rateCardLineIdentifier;
    }

    public class PriceScheduleLineItem {
        public String id;
        public Integer fromPeriod;
        public Integer toPeriod;
        public Double unitPrice;
        public Double applicationDuration;
        public List<ApplicableDiscounts> applicableDiscounts;
        public List<TierLineItems> tierLineItems;
    }

    public ChargeLineItems chargeLineItems;

    public class ApplicableDiscounts {
        public String id;
        public String description;
        public String discountAmount;
        public Double appliedDiscountAmount;
    }

    public class ChargeLineItems {
        public Double unitPrice;
        public Integer contractTerm;
        public String businessID;
        public Double unitTotalContractValue;
        public List<PriceScheduleLineItem> priceScheduleLineItem;
    }

    
    public static ChargeLineItemsDTO parse(String json) {
        
        Json = Json.replace('businessID__c', 'businessID');
        Json = Json.replace('fromPeriod__c', 'fromPeriod');
        Json = Json.replace('toPeriod__c', 'toPeriod');
        Json = Json.replace('unitPrice__c', 'unitPrice');
        Json = Json.replace('contractTerm__c', 'contractTerm');
        Json = Json.replace('unitTotalContractValue__c', 'unitTotalContractValue'); 
        Json = Json.replace('applicationDuration__c', 'applicationDuration'); 
        Json = Json.replace('appliedDiscountAmount__c', 'appliedDiscountAmount');
        Json = Json.replace('discounted_Price__c', 'discounted_Price'); 
        Json = Json.replace('fromUnit__c', 'fromUnit');
        Json = Json.replace('toUnit__c', 'toUnit');
        Json = Json.replace('rateCardLineIdentifier__c', 'rateCardLineIdentifier');     
        
        return (ChargeLineItemsDTO) System.JSON.deserialize(json, ChargeLineItemsDTO.class);
    }
}