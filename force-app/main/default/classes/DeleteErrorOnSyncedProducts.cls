/*************************************************************************************************
Name : DeleteErrorOnSyncedProducts
Description : Class to throw error when already synced basket products are deleted

***************************************************************************************************/
public class DeleteErrorOnSyncedProducts {

  public static void deleteError(List<csbb__Product_Configuration_Request__c> prodConfigReqList) {
    Set<Id> prodConfigSet = new Set<Id>();
    for (csbb__Product_Configuration_Request__c  pcr : prodConfigReqList) {
      prodConfigSet.add(pcr.csbb__Product_Configuration__c);
    }
    System.debug(LoggingLevel.INFO, 'DeleteErrorOnSyncedProducts.prodConfigSet = ' + prodConfigSet);
    //get the opportunity line items corresponding to product configurations if any
    List<OpportunityLineItem> oppList =
      [
        SELECT id, cscfga__Attribute__c, cscfga__Attribute__r.cscfga__Product_Configuration__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.StageName
        FROM OpportunityLineItem
        WHERE cscfga__Attribute__r.cscfga__Product_Configuration__c IN :prodConfigSet
      ];
    Map<Id, OpportunityLineItem> oppMap = new Map<Id, OpportunityLineItem>();
    if(oppList != null && oppList.size() > 0){
      Set<String> modularStatus = new Set<String> {Label.CommercialConfiguration, Label.Draft, Label.Quote};
      Set<String> nonModularStatus = new Set<String> {Label.Define, Label.Qualify, Label.Develop, Label.Price};
      for(OpportunityLineItem oli : oppList){
        // MG if condition added to avoid empty line item deletation failure
        /*if (oli.cscfga__Attribute__r.cscfga__Product_Configuration__c != null &&
            oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c != Label.CommercialConfiguration &&
            oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c != Label.Modular) {
            oppMap.put(oli.cscfga__Attribute__r.cscfga__Product_Configuration__c,oli);
        }*/

        if(oli.cscfga__Attribute__r.cscfga__Product_Configuration__c != null &&
            (
              (
                oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c == Label.Modular &&
                !modularStatus.contains( oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c )
              ) ||
              (
                oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c != Label.Modular &&
                !nonModularStatus.contains( oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.StageName )
              )
            )
           ) {
          oppMap.put(oli.cscfga__Attribute__r.cscfga__Product_Configuration__c, oli);
        }
      }
    }
    System.debug(LoggingLevel.INFO, 'DeleteErrorOnSyncedProducts.oppMap = ' + oppMap);
    if (oppMap != null && oppMap.size() > 0) {
      for (csbb__Product_Configuration_Request__c  pcr : prodConfigReqList) {
        if (oppMap.containsKey(pcr.csbb__Product_Configuration__c)) {
          System.debug(LoggingLevel.INFO,  'Cannot delete synced products');
          pcr.addError('Cannot delete synced products');
        }
      }
    }
  }
}