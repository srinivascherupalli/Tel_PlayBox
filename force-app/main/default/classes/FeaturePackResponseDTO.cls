/**************************************************************************
EDGE-207368
Description -DTO for feature pack charge for billing enquiry 
Author      - Akanksha 
Team        -Munich
*********************************************************************************/
public with sharing class  FeaturePackResponseDTO {
       
  @AuraEnabled
    public List<FeaturePackDetails> featurePackDetails{get; set;}
    @AuraEnabled	
 public List<InvoiceLineAttributes> invoiceLineAttributes{get; set;}
  
    public class FeaturePackDetails {    
      @AuraEnabled
      public String orderNumber  {get; set;}
      
      @AuraEnabled
      public String uniqueId  {get; set;}
        
      @AuraEnabled
      public String quantity  {get; set;}
      
      @AuraEnabled
      public double unitRate{get; set;}

      @AuraEnabled
      public double excludingGSTcostFmtd  {get; set;}
      
      @AuraEnabled
      public double includingGSTcostFmtd {get; set;}   
       @AuraEnabled
      public long chargeIdentifier{get; set;} 
         @AuraEnabled
  public list<InvoiceLineAttributes> invoiceLineAttributes{get; set;}
         @AuraEnabled
  public Integer invoiceTransactionId{get; set;}
  }
  
  public class InvoiceLineAttributes {
      @AuraEnabled
  public Integer invoiceTransactionId{get; set;}
}
  
  public static FeaturePackResponseDTO parse(String json) {
      json = json.replace('subscriptionIdentifier', 'uniqueId');
      json = json.replace('amountExGST', 'excludingGSTcostFmtd');
      json = json.replace('amountIncGST', 'includingGSTcostFmtd');
      //system.debug('JSON'+JSON);
      //system.debug('response from DTO'+System.JSON.deserialize(json,FeaturePackResponseDTO.class));
      return (FeaturePackResponseDTO) System.JSON.deserialize(json, FeaturePackResponseDTO.class);
  
   }

}