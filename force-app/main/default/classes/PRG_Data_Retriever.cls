global with sharing class PRG_Data_Retriever implements cssmgnt.RemoteActionDataProvider {

  @RemoteAction
  global static Map<String, Object> getData(Map<String, Object> inputMap) {
    List<cspmb__Pricing_Rule_Group_Rule_Association__c> prgras = [
            SELECT cspmb__pricing_rule_group__c, 
            cspmb__pricing_rule_group__r.Name, 
            cspmb__pricing_rule__c, 
            cspmb__pricing_rule__r.Name 
            FROM cspmb__Pricing_Rule_Group_Rule_Association__c
        ];

        Map<String, String> prToPrg = new Map<String, String>();
        for (cspmb__Pricing_Rule_Group_Rule_Association__c prgra : prgras) {
            prToPrg.put(
                prgra.cspmb__pricing_rule__r.Name,
                prgra.cspmb__pricing_rule_group__r.Name
            );
        }

    return prToPrg;
  }
}