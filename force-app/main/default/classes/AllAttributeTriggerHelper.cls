/*********************************************************************************************************************************
 *Class Name      :   SolutionActionHelper

Test Class : SolutionActionHelperTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Gnana					  17/07/2020	Modified as part of CS Spring'20 Upgrade
/*********************************************************************************************************************************
*/

public class AllAttributeTriggerHelper {
  public static final String AMC_STATUS = 'AMC Status';
  /*
   * Handles before delete event of attribute and prevents if there are synced products
  */
  public static void handleAttributeDeletion(List<cscfga__Attribute__c> oldAttributeList) {
    Set<Id> deleteAtrSet =  new Set<Id>();
    List<OpportunityLineItem> deleteOLIList = new List<OpportunityLineItem>();
    for (cscfga__Attribute__c att : oldAttributeList) {
      deleteAtrSet.add(att.id);
    }
    Map<Id, Id> oliAtrMap = new Map<Id, Id>();
    List<OpportunityLineItem> oppList =
      [Select id, cscfga__Attribute__c,
       cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c,
       cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c
       From OpportunityLineItem where cscfga__Attribute__c in : deleteAtrSet];
    for (OpportunityLineItem oli : oppList) {
      if (oli.cscfga__Attribute__r.cscfga__Product_Configuration__c != null &&
          oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c != Label.CommercialConfiguration &&
          oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c != Label.Modular) {
        oliAtrMap.put(oli.cscfga__Attribute__c, oli.Id);
      } else {
        deleteOLIList.add(oli);
      }
    }
    for (cscfga__Attribute__c att : oldAttributeList) {
      if (oliAtrMap != null && oliAtrMap.containsKey(att.id))
        att.addError('Cannot Delete Synced Products');
    }

    if (deleteOLIList.size() > 0) {
      try {
        delete deleteOLIList;
      } catch (Exception exc) {
        throw new myException('{"status":"error", "text":"' + exc.getMessage() + '"}');
      }
    }
  }
    
  /*
  * Updates synchronised flag on basket based on attribute definition desynchronises bundle flag - EDGE-14489
  * Added Product_Type Condition to make this logic works only for Standard Products
  */
    /* 
        * Gnana: CS Spring'20 Upgrade Start
        * Moved this logic to AfterSave hook in respective JS Plugins
    public static void updateProductBasketSyncFlag(List<cscfga__Attribute__c> desynchronisedAtrList, Map<id, cscfga__Attribute__c> attrOldMap) {
        Set<Id> atrSet =  new Set<Id>();
        Set<Id> prodBasketSet = new Set <Id>();
        for (cscfga__Attribute__c att : desynchronisedAtrList) {
            atrSet.add(att.id);
        }
        
        List<cscfga__Attribute__c> attrList = [Select id, cscfga__Product_Configuration__r.cscfga__Product_Basket__c, cscfga__Attribute_Definition__c, cscfga__value__c, cscfga__Line_Item_Description__c, cscfga__Attribute_Definition__r.cscfga__is_significant__c from cscfga__Attribute__c where cscfga__Attribute_Definition__r.cscfga__is_significant__c = true and id in: atrSet];
        for (cscfga__Attribute__c atr : attrList) {
            
            if (atr.cscfga__Value__c != attrOldMap.get(atr.id).cscfga__Value__c || atr.cscfga__Line_Item_Description__c != attrOldMap.get(atr.id).cscfga__Line_Item_Description__c) {
                prodBasketSet.add(atr.cscfga__Product_Configuration__r.cscfga__Product_Basket__c);
                
            }
            
        }
        
        List<cscfga__Product_Basket__c> prodBasktUpdateList = [Select id, cscfga__Opportunity__r.Product_Type__c , csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where id in:prodBasketSet and csbb__Synchronised_with_Opportunity__c = true AND cscfga__Opportunity__r.Product_Type__c = 'Standard']; // Modified as part of CS Spring'20 Upgrade
        for (cscfga__Product_Basket__c bas : prodBasktUpdateList) {
            
            bas.csbb__Synchronised_with_Opportunity__c = false;
        }
        
        if (prodBasktUpdateList != null && prodBasktUpdateList.size() > 0) {
            update prodBasktUpdateList;
        }
    }
	*/
  public class myException extends Exception{}

}