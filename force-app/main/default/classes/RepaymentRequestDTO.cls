/*************************************************************************************************
Name : RepaymentRequestDTO
Description : Request DTO for Repayment details Callout
Author: Jawahar M
Story: EDGE-108333
***************************************************************************************************/
public with sharing class RepaymentRequestDTO {
    
 
  public String statementNumber;
  public Integer chargeId;
 

  public static RepaymentRequestDTO parse(String json) {
    return (RepaymentRequestDTO) System.JSON.deserialize(json, RepaymentRequestDTO.class);
  }
}