/******************************************************************************************************************************
Class Name : PriceScheduleDTO
Test Class : PriceScheduleDTOTest

Sr.No.  Developer       Date          Story Description         Sprint
1.      Aman Soni       20/04/2020    EDGE-123593(New Class)    20.05
******************************************************************************************************************************/
public class PriceScheduleDTO {
    
        public class ChargeLineItems {
        public String id;
        public Double unitPrice;
        public Integer contractTerm;
        public String businessID;
        public String productChargeIdentifier;
        public String targetChargeProduct;
        public Double unitTotalContractValue;
        public List<PriceScheduleLineItem> priceScheduleLineItem;
    }

    public ChargeLineItems chargeLineItems;
    
    public class PriceScheduleLineItem {
        public String id;
        public Integer fromPeriod;
        public Integer toPeriod;
        public Double unitPrice;
        public List<ApplicableDiscounts> applicableDiscounts;
        public Integer applicationDuration;
        public String cliId;
    }

    public class ApplicableDiscounts {
        public String psliId;
        public String id;
        public String description;
        public String discountAmount;
        public String appliedDiscountValue;
    }

    public static PriceScheduleDTO parse(String json){
        return (PriceScheduleDTO) System.JSON.deserialize(json, PriceScheduleDTO.class);
    }
}