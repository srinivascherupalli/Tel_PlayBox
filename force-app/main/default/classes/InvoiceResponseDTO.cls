/***************************************************************************************************************************************************************
Name : InvoiceResponseDTO
Description : Parse response for Invoice Callout
Author: Kalashree Borgaonkar
Story: EDGE-88307
Modified by : EDGE-115138, Added newly created attributes PlanCharges,OnceOffChargesAndCredits,UsageSummaryCharges, renamed Dispute Attributes to InvoiceLineAttributes
*****************************************************************************************************************************************************************/
public with sharing class InvoiceResponseDTO {
    public String errorKey;
    public String errorMessage;
    
    public class InvoiceDetails {
        public String accountNumber;
        public String invoiceNumber{ get; set; }
        public String invoiceIssueDate;
        public String invoicePeriod;
        public String ariaInvoiceNumber;
    }
    
    public class ListOfProducts {
        public String physicalLocationName;
        public Double siteExcludingGstCost;
        public Double siteIncludingGstCost;
        public ListOfChargesAndCredits listOfChargesAndCredits;
    }
    
    public class AccountLevelChargesAndCredits {
        public Double adjustmentsExcludingGstCost;
        public Double adjustmentsIncludingGstCost;
        public Double grossTotalBill;
        public Double amountOfGstIncludedInGrossTotalBill;
        public Double totalNewChargesInThisBill;
        public Double gstFreeItemsIncludedInNewCharges;
        public Double gstIncludedInNewCharges;
        public Double adjustmentsTotal;
        public Double gstIncludedInAdjustments;
    }
    
    public CustomerAddress customerAddress;
    public InvoiceDetails invoiceDetails{ get; set; }
    public PaymentSummary paymentSummary;
    public ServiceSummary serviceSummary;
    public AdjustmentSummary adjustmentSummary;
    
    public class Adjustments {
        public String adjustmentDescription;
        public String adjustmentDate;
        public Double adjustmentsCost;
        public Double gstIncludedInAdjustments;
        public Boolean isQueryable;
        public Boolean isDisputable;
        public Integer chargeIdentifier;
        public String chargeType;
        //EDGE-120657 start
        public List<InvoiceLineAttributes> invoiceLineAttributes;
        //EDGE-120657 End
        
    }
    
    public class DrillDownInputAttribute {
        public String usageTypeCode;
        public String statementNumber;
        public Integer chargeId;
        public Integer taxInclusive;
        public Decimal taxRate;
        public List<Long> planInstanceDetailsList;
    }
    
    public class ListOfChargesAndCredits {
        public List<PlanCharges> planCharges;
        public List<UsageSummaryCharges> usageSummaryCharges;
        public List<OnceOffChargesAndCredits> onceOffChargesAndCredits;
    }
    
    public class AdjustmentSummary {
        public Double totalAdjustmentsCost;
        public Double totalGSTIncludedInAdjustments;
        public List<Adjustments> adjustments;
    }
    
    public class ListOfOffers {
        public String offerName;
        public Double offerTotalExcludingGstCost;
        public Double offerTotalIncludingGstCost;
        public Integer invoiceDef;
        public List<ListOfProducts> listOfProducts;
        public ListOfChargesAndCredits listOfChargesAndCredits;
    }
    
    public class PaymentSummary {
        public Double balanceCarriedForward;
        public Double totalDue;
        public Double paymentsAndAdjustments;
        public String dueDate;
        public Double newCharges;
    }
    
    public class OnceOffChargesAndCredits {
        public String serviceType;
        //Start of EDGE-130452
        //public Integer quantity;
         public String quantityWithUnit;
        //End of EDGE-130452
        public Double excludingGstCost;
        public Double includingGstCost;
        public String sigmaSpecId;
        public Boolean isAggregated;
        public Boolean isTaxable;
        public Boolean isQueryable;
        public Boolean isDisputable;
        public Integer chargeIdentifier;
        public String chargeType;
        //20.13:Osaka: START of EDGE-181508:fixing QA2 defect 
        public String drillDownEndpoint; 
        public DrillDownInputAttribute drillDownInputAttribute;
        //END of EDGE-181508
        public List<InvoiceLineAttributes> invoiceLineAttributes;
        //Start of :EDGE-164871
        public List<Discounts> discounts;
        //End of :EDGE-164871
    }
    
    public class InvoiceLineAttributes {
        public Integer invoiceLineNumber;
        public Integer invoiceTransactionId;
        public Double chargeExcludingGST;
        public Double chargeIncludingGST;
        public String quantity;
         
    }
    
    public class ServiceSummary {
        public List<ListOfOffers> listOfOffers;
        public AccountLevelChargesAndCredits accountLevelChargesAndCredits;
    }
    
    public class PlanCharges {
        public String serviceType;
        //Start of EDGE-130452
        //public Integer quantity;
        public String quantityWithUnit;
        //End of EDGE-130452
        public Double excludingGstCost;
        public Double includingGstCost;
        public String sigmaSpecId;
        public String startDate;
        public String endDate;
        public Boolean isAggregated;
        public Boolean isTaxable;
        public Boolean isQueryable;
        public Boolean isDisputable;
        public Integer chargeIdentifier;
        public String chargeType;
        public List<InvoiceLineAttributes> invoiceLineAttributes;
        public DrillDownInputAttribute drillDownInputAttribute;
        public String drillDownEndpoint;
        //Start of :EDGE-164871
        public List<Discounts> discounts;
        //End of :EDGE-164871
    }
    
    public class CustomerAddress {
        public String companyName;
        public String addressLine1;
        public String addressCity;
        public String stateAndPostalCode;
    }
    //Start of EDGE:115138 
    public class UsageSummaryCharges {
        public Double excludingGstCost;
        public Double includingGstCost;
        public Boolean isAggregated;
        public Boolean isTaxable;
        public DrillDownInputAttribute drillDownInputAttribute;
        public Boolean isQueryable;
        public String units;
        public String usageTypeName;
        public Boolean isDisputable;
        public Integer chargeIdentifier;
        public String chargeType;
        public List<InvoiceLineAttributes> invoiceLineAttributes;
        //EDGE-120657 start  
        public String drillDownEndpoint;
        //EDGE-120657 End
        //End of EDGE:115138
        //Start of :EDGE-164871
        public List<Discounts> discounts;
        //End of :EDGE-164871
    }
    //Start of :EDGE-164871
    public class Discounts{
        public Boolean isDrillable;
    }
    //End of :EDGE-164871
    public static InvoiceResponseDTO parse(String json) {
        system.debug('=========>'+json);
        return (InvoiceResponseDTO) System.JSON.deserialize(json, InvoiceResponseDTO.class);
    }
}