/*----------------------------------------------------------------------------
EDGE        -88306
Name        -BillingAccountPaymentsResponseDTO
Description -DTO Class for Billing account payments API response
Author      -Dheeraj Bhatt
Modified By -Kamlesh Kumar EDGE:212792 Added extra payment transaction variables 
Modified By -Pooja Bhat EDGE-215989 B2B-1179 :- Additional BCC fields to be made available
-------------------------------------------------------------------------------*/
public class BillingAccountPaymentsResponseDTO {
    @AuraEnabled public string Correlation_Id;
    @AuraEnabled Public Integer code;
    @AuraEnabled Public String status;
    @AuraEnabled Public String message;
    @AuraEnabled Public Decimal  billingAccountNumber ;
    @AuraEnabled Public List<payments> payments;
    @AuraEnabled  Public List<errors> errors;
    /* class for representing the customer's payments*/
    Public class Payments{
        @AuraEnabled  public Integer transactionId;
        @AuraEnabled  Public String paymentDate;
        @AuraEnabled  Public String paymentType;
        @AuraEnabled  Public Decimal paymentAmount;
        @AuraEnabled  Public Decimal paymentAppliedAmount;
        @AuraEnabled  Public Decimal paymentUnappliedAmount;
        @AuraEnabled  Public String paymentAmountIndicator;
        //EDGE-212792
        @AuraEnabled  Public String isReversed;
        @AuraEnabled  Public String reversalDate;
        @AuraEnabled  Public String reversalReason;
        @AuraEnabled  Public Long fromBillingAccount;
        @AuraEnabled  Public Long toBillingAccount;
        @AuraEnabled  Public String paymentCode;
        @AuraEnabled  Public String caseNumber;
        //End EDGE-212792
        @AuraEnabled  public String comments;    //Added:EDGE-215989
        @AuraEnabled  public String reason;     //Added:EDGE-215989
        @AuraEnabled  Public List<paymentApplicationDetails> paymentApplicationDetails;
    }
    /* class for representing the invoices on which the payment has been applied */
    public class PaymentApplicationDetails{
        @AuraEnabled  public string invoiceNumber;
        @AuraEnabled  public string  invoiceDate;
        @AuraEnabled  public Decimal amountApplied;//EDGE:212792 Changed data type from integer to decimal
        @AuraEnabled  public Decimal amountTotalPaid;//EDGE:212792 Changed data type from integer to decimal
        @AuraEnabled  public Decimal balanceDue;
    }
    /* Class for representing error in API Callout*/
    Public Class Errors{
        @AuraEnabled public Integer code;
        @AuraEnabled Public string  field;
        @AuraEnabled Public string  message;
    }
}