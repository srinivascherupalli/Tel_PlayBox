global with sharing class DynamicUserPCLookup extends cscfga.ALookupSearch {

  global override Object[] doDynamicLookupSearch(Map<String, String> searchFields,  String productDefinitionID){          

    //String testingID = '0012O000002n998QAA';
    FINAL String userPDSpec = 'DMCAT_ProductSpecification_000074';
    System.debug('searchFields ::'+searchFields);
    Id basktId = searchFields.get('BasketId');
    Id accountId = searchFields.get('AccountId');
    Integer userQty = 0;
    //Query User Configuration
    //Do we need PD reference Id, custom settings etc?
    //Users from current basket
    List<cscfga__Product_Configuration__c> bsktConfigs = [SELECT Id, Name, cscfga__Product_Basket__r.csbb__Account__c, Quantity_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__c 
                                FROM cscfga__Product_Configuration__c
                                WHERE cscfga__product_definition__r.product_Specification__c = :userPDSpec
                                AND cscfga__Product_Basket__c = :basktId
                                AND Quantity_Product_Configuration__c != null];

    //PCs which are replaced by the PCs in current basket should not be reconsidered
    List<Id> pcListToExclude = new List<Id>();
    for(cscfga__Product_Configuration__c pc: bsktConfigs){
      pcListToExclude.add(pc.csordtelcoa__Replaced_Product_Configuration__c);
      userQty += Integer.valueOf(pc.Quantity_Product_Configuration__c);
    }

    //Users from Customer's active subscriptions
    //Users from other baskets should not be considered as the final stage of those basket cannot be ascertained

    List<csord__service__c> prodConfigs = [Select Id, Name, csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c 
                                FROM csord__service__c 
                                where csordtelcoa__Product_Configuration__r.cscfga__product_definition__r.product_Specification__c = :userPDSpec
                                AND csordtelcoa__Replaced_Service__c = null
                                AND csord__Subscription__r.csord__Account__c =: accountId
                                AND csord__Status__c NOT IN ('Cancelled','Disconnected') 
                                                         AND csordtelcoa__Product_Configuration__c NOT IN :pcListToExclude
                                AND csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != null];

    System.debug('prodConfig : ' + prodConfigs);

    //sum the quantity at the 
    for (csord__service__c prodConfig : prodConfigs) {
       System.debug(prodConfig.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
       userQty += Integer.valueOf(prodConfig.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
    }

    cscfga__Product_Configuration__c retRec = new cscfga__Product_Configuration__c();
    retRec.Quantity_Product_Configuration__c = userQty;

    return new List<cscfga__Product_Configuration__c>{retRec} ;
  }
  
  global override String getRequiredAttributes(){         
    return '["AccountId","BasketId"]';
  }
}