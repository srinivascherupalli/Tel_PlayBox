public class BillingOrderDTO {
  public String billingAccountNumber{get;set;}
  public String correlationId {get;set;}
  public Integer preferredBillCycleId {get;set;}
  public static BillingOrderDTO parse(String json) {
    return (BillingOrderDTO) System.JSON.deserialize(json, BillingOrderDTO.class);
  }
}