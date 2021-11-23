global with sharing class CustomButtonSynchronizeWithOpportunity extends csbb.CustomButtonExt {
  public String performAction (String basketId) {
    //Error condition
    //'{"status":"error","title":"Error","text":"Synchronize to opportunity failed"}'

    //Success & redirect
    //'{"status":"ok","redirectURL":"http://www.google.com","target":"1"}';

    // Success and remain in page
    //return '{"status":"ok","title":"Success","text":"Synchronize to opportunity successful"}';
    String newUrl = CustomButtonSynchronizeWithOpportunity.syncWithOpportunity(basketId);
    return '{"status":"ok","redirectURL":"' + newUrl + '"}';
  }

  public static String syncWithOpportunity(String basketId) {
//    List <cscfga__Product_Configuration__c> orphanProdConfs =
//      [
//        SELECT c.id
//        FROM cscfga__Product_Configuration__c c
//        WHERE cscfga__product_basket__c = :basketId AND cscfga__root_configuration__c = null AND csoe__Commercial_Configuration__c = null AND
//                                          id NOT IN
//                                          (
//                                            SELECT csbb__product_configuration__c
//                                            FROM csbb__Product_Configuration_Request__c
//                                            WHERE csbb__product_basket__c = :basketId AND csbb__product_configuration__c != null
//                                          )
//      ];
//02/05/2019
//TODO
//This line needed to be removed for sync to work correctly.
//It has the effect of removing all root-level product configs without a PCR.
//This removes all the sites from the basket when created using Solutions Console (no PCR for IP Site)
//
//Unsure what the original purpose of this function was.
//
//Additional testing required to ensure that its removal won't cause side effects
//    if (orphanProdConfs.size() > 0)
//      delete orphanProdConfs;

    String queryString = 'SELECT ';
    queryString += 'id, ';
    queryString += 'cscfga__opportunity__c, ';
    queryString += 'csbb__Synchronised_with_Opportunity__c, ';
    queryString += 'cscfga__Basket_Status__c ';
    queryString += 'FROM ';
    queryString += 'cscfga__Product_Basket__c ';
    queryString += 'WHERE ';
    queryString += 'id = :basketId ';

    cscfga__Product_Basket__c pb = Database.query(queryString);

    if (pb.cscfga__Basket_Status__c != 'Valid')
      return 'Synchronise with opportunity failed: product basket has to be valid.';

    //unsync first
    /* if (pb.csbb__Synchronised_with_Opportunity__c){
         StaticUtilForRecursion.autoSyncRunFlag = false;
       pb.csbb__Synchronised_with_Opportunity__c = false;
       update pb;
     }*/

    //then sync
    pb.csbb__Synchronised_with_Opportunity__c = true;
    pb.csordtelcoa__Synchronised_with_Opportunity__c = true;
    update pb;

    Opportunity oppToGoBackTo =
      [
        SELECT id
        FROM Opportunity
        WHERE id = :pb.cscfga__Opportunity__c
      ];

    PageReference oppPage = new ApexPages.StandardController(oppToGoBackTo).view();
    return oppPage.getUrl();
  }
}