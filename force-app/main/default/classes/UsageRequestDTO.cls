/*************************************************************************************************
Name : UsageRequestDTO
Description : Requeste DTO for UsageSummary details Callout
Author: Sasidhar Devarapalli
Story: EDGE-108332
***************************************************************************************************/
public with sharing class UsageRequestDTO {
    
  public String usageTypeCode;
  public String statementNumber;
  public String invoiceNumber;
  public String accountNumber;
  public String invoicePeriod;
  public Integer chargeId;
  public List<Integer> planInstanceDetailsList;
  public Integer taxInclusive;
  public Decimal taxRate;

  public static UsageRequestDTO parse(String json) {
    return (UsageRequestDTO) System.JSON.deserialize(json, UsageRequestDTO.class);
  }
}