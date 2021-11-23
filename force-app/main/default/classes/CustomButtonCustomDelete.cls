/*************************************************************************************************
Name : CustomButtonCustomDelete
EDGE-> 64874
Description : Used to Delete PCR records from Basket For Modify and Cancel Orders of Modular Product.
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Rohit Tripathi     25/03/2019  	Used to Delete PCR records from Basket For Modify and Cancel Orders of Modular Product
===============================================================================================================================
***************************************************************************************************/

global with sharing class CustomButtonCustomDelete extends csbb.CustomButtonExt {

 public String performAction(String basketID, String pcrIds) {
  try {
  string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
  system.debug('BAsket ID ---->' + basketId);
  system.debug('PCR ID ---->' + pcrIDs);
  String regex = '\\[|\\]|\\"';
  pcrIds = pcrIds.replaceAll(regex, '');
  system.debug(' After PCR ID ---->' + pcrIDs);
  Integer selectedIPSiteCount = 0; // Variable to Store Count of Selected IP Site PCR ID's to be deleted from Basket
  Integer selectedCancelIPSiteCount = 0; // Variable to Store Count of Selected IP Site(Chnage Type - Cancel) PCR ID's to be deleted from Basket
  Integer selectedMobilityCount = 0; // Variable to Store Count of Selected Mobility PCR ID's to be deleted from Basket
  Integer selectedIPNetworkCount = 0; // Variable to Store Count of Selected IP N/w PCR ID to be deleted from Basket
  Integer selectedUCECount = 0; // Variable to Store Count of Selected UCE PCR ID to be deleted from Basket
  Integer totalIPSitePCRCount = 0; // Variable to Store Count of Total IP Site PCR ID's Present in Basket
  Integer totalIPSiteCancelPCRCount = 0; // Variable to Store Count of Total IP Site (Cancel ) PCR ID's Present in Basket
  Integer totalIPSiteSubscriptionCount = 0; // Variable to Store Count of Total IP Site Subscriptions Present on Account
  Integer diffBetweenTotalSubsandTotalPCRIPSite = 0; // Variable to Store diff B/w TotaL IP Site subs from Ac and Total IP Site PCR from Basket
  Integer ipSitesubscriptionToRemainOnAccount = 0; // Variable to Store Count of IP Site Subs to remain on account after deletion

  PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketID);
  ref.setRedirect(true);
  Set < ID > ipSitePCIDsToDelete = new Set < ID > (); // Set to Store IP Site PC Id's To Be Deleted
  Set < ID > ipSitesubsToBeReplaced = new Set < ID > (); // Set to Store IP Site Subs MACD Association Id's To Be Deleted
  Set < ID > mobilityPCIDsToDelete = new Set < ID > (); // Set to Store Mobility PC Id's To Be Deleted
  Set < ID > mobilitysubsToBeReplaced = new Set < ID > (); // Set to Store Mobility Subs MACD Association Id's To Be Deleted
  set < ID > otherPCIDsToDelete = new Set < ID > (); // Set to Store Other  PC Id's To Be Deleted
  set < ID > othersubsToBeReplaced = new Set < ID > (); // Set to Store Other Products Subs MACD Association Id's To Be Deleted
  Set < ID > ipNetworkPCIDsToDelete = new Set < ID > (); // Set to Store IP N/W PC Id's To Be Deleted
  Set < ID > ucePCIDsToDelete = new Set < ID > (); // Set to Store UCE PC Id's To Be Deleted
  ID ipNetworkPCIDsToUpdate;
  Id ipNetworksubsToBeReplaced;
  ID ucePCIDsToUpdate;
  Id ucesubsToBeReplaced;
  //List of IP Site , Mobility and Other PCR Id's To Be deleted 
  List < csbb__Product_Configuration_Request__c > ipSitePCRIDsToDelete = new List < csbb__Product_Configuration_Request__c > ();
  List < csbb__Product_Configuration_Request__c > mobilityPCRIDsToDelete = new List < csbb__Product_Configuration_Request__c > ();
  List < csbb__Product_Configuration_Request__c > otherPCRIDsToDelete = new List < csbb__Product_Configuration_Request__c > ();
  List < csbb__Product_Configuration_Request__c > ipNetworkPCRIDsToUpdate = new List < csbb__Product_Configuration_Request__c > ();
  List < csbb__Product_Configuration_Request__c > ucePCRIDsToUpdate = new List < csbb__Product_Configuration_Request__c >();



  if (basketID != null && pcrIDs != null && pcrIDs != '') {

   cscfga__Product_Basket__c basket = [Select id, csbb__Account__r.id from cscfga__Product_Basket__c
    where Id =: basketId
   ];
   //Fetching  All Active Subscriptions from Account
   List < csord__Subscription__c > accAllSubIds = new List < csord__Subscription__c >
    ([select id, csordtelcoa__Subscription_Number__c, csord__Status__c, csord__Account__c, Name
     from csord__Subscription__c where csord__Account__c =: basket.csbb__Account__r.Id
     and csord__Status__c =: System.Label.Active
    ]);
   for (csord__Subscription__c allSubs: accAllSubIds) {
    if (allSubs.name.contains(System.Label.IP_Site))
     totalIPSiteSubscriptionCount++;
   }
   //Fetching All PCR Id's From Basket
   List < csbb__Product_Configuration_Request__c > allPCRIDs = new List < csbb__Product_Configuration_Request__c >
    ([Select id, csbb__Product_Basket__c, csbb__Product_Category__c, Type__c,
     Product_Configuration_Name__c, csbb__Product_Configuration__r.Id,
     csbb__Product_Configuration__r.Name from csbb__Product_Configuration_Request__c
     where csbb__Product_Basket__r.Id =: basketID
    ]);

   for (csbb__Product_Configuration_Request__c allPCR: allPCRIDs) {
    if (allPCR.Product_Configuration_Name__c == System.Label.IP_Site)
     totalIPSitePCRCount++;
    if (allPCR.Product_Configuration_Name__c == System.Label.IP_Site && allPCR.Type__c == System.Label.Cancel)
     totalIPSiteCancelPCRCount++;
    if (allPCR.Product_Configuration_Name__c == System.Label.IP_Network) {
     ipNetworkPCIDsToDelete.add(allPCR.csbb__Product_Configuration__r.Id);
     ipNetworkPCIDsToUpdate = allPCR.csbb__Product_Configuration__c;
     ipNetworkPCRIDsToUpdate.add(allPCR);
    }
    if (allPCR.Product_Configuration_Name__c == System.Label.UC_Config_Name) {
     ucePCIDsToDelete.add(allPCR.csbb__Product_Configuration__r.Id);
     ucePCIDsToUpdate = allPCR.csbb__Product_Configuration__c;
     ucePCRIDsToUpdate.add(allPCR);
    }

   }

   List < String > selectedPCRIDs = pcrIDs.split(',');
   //Storing the Selected PCR Id's to be deleted from Basket
   List < csbb__Product_Configuration_Request__c > selectedPCRIdsToDelete = new List < csbb__Product_Configuration_Request__c >
    ([Select id, csbb__Product_Basket__c, csbb__Product_Category__c,
     Type__c, Product_Configuration_Name__c, csbb__Product_Configuration__c,
     csbb__Product_Configuration__r.Id,csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c from csbb__Product_Configuration_Request__c
     where Id in: selectedPCRIDs
    ]);
   List < ID > selectedPCRRecoedIDs = new List < ID > ();
   for (csbb__Product_Configuration_Request__c selPCR: selectedPCRIdsToDelete) {
    if (selPCR.Product_Configuration_Name__c == System.Label.IP_Site && selPCR.Type__c == System.Label.Cancel)
     selectedCancelIPSiteCount++ ;
    if (selPCR.Product_Configuration_Name__c == System.Label.IP_Site) {
     selectedIPSiteCount++;
     ipSitePCIDsToDelete.add(selPCR.csbb__Product_Configuration__r.Id);
     ipSitePCRIDsToDelete.add(selPCR);
     ipSitesubsToBeReplaced.add(selPCR.csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c);
    } else if (selPCR.Product_Configuration_Name__c.contains(System.Label.Mobile)) {
     selectedMobilityCount++;
     mobilityPCIDsToDelete.add(selPCR.csbb__Product_Configuration__r.Id);
     mobilityPCRIDsToDelete.add(selPCR);
     mobilitysubsToBeReplaced.add(selPCR.csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c);
    } else if (selPCR.Product_Configuration_Name__c == System.Label.IP_Network) {
     selectedIPNetworkCount++;
     ipNetworkPCIDsToDelete.add(selPCR.csbb__Product_Configuration__r.Id);
     ipNetworksubsToBeReplaced = selPCR.csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c;
     ipNetworkPCIDsToUpdate = selPCR.csbb__Product_Configuration__c;
     //ipNetworkPCRIDsToUpdate.add(selPCR);
    } else if (selPCR.Product_Configuration_Name__c == System.Label.UC_Config_Name) {
     selectedUCECount++;
     ucePCIDsToDelete.add(selPCR.csbb__Product_Configuration__r.Id);
     ucesubsToBeReplaced = selPCR.csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c;
     ucePCIDsToUpdate = selPCR.csbb__Product_Configuration__c;
     //ucePCRIDsToUpdate.add(selPCR);
    } else {
     otherPCIDsToDelete.add(selPCR.csbb__Product_Configuration__r.Id);
     othersubsToBeReplaced.add(selPCR.csbb__Product_Configuration__r.csordtelcoa__Replaced_Subscription__c);
     otherPCRIDsToDelete.add(selPCR);
    }
   }
   diffBetweenTotalSubsandTotalPCRIPSite = totalIPSiteSubscriptionCount - totalIPSiteCancelPCRCount;
   ipSitesubscriptionToRemainOnAccount = diffBetweenTotalSubsandTotalPCRIPSite + selectedCancelIPSiteCount;
   /* when subscription to remain on account is greter than 1 and Mobility is selected or Not 
   and not all CWP sites selected to delete then Remove IP Site PCR and Change IP NW and UCE to Modify*/
   if (ipSitesubscriptionToRemainOnAccount > 1 && selectedIPSiteCount != 0 && totalIPSitePCRCount > selectedIPSiteCount && (selectedIPNetworkCount == 0 && selectedUCECount == 0)) {
    deleteIPSite(ipSitePCIDsToDelete, ipSitePCRIDsToDelete, ipSitesubsToBeReplaced);
    deleteMobility(mobilityPCIDsToDelete, mobilityPCRIDsToDelete, mobilitysubsToBeReplaced);
    deleteOtherProducts(otherPCIDsToDelete, otherPCRIDsToDelete, othersubsToBeReplaced);
    if (ipNetworkPCIDsToUpdate != null) {

     cscfga__Product_Configuration__c ipNWUpdate = [Select Id from cscfga__Product_Configuration__c
      where Id =: ipNetworkPCIDsToUpdate
     ];

     ipNWUpdate.Type__c = System.Label.Modify;
     update ipNWUpdate;
    }
    if (ucePCIDsToUpdate != null) {
     cscfga__Product_Configuration__c uceUpdate = [Select Id from cscfga__Product_Configuration__c
      where Id =: ucePCIDsToUpdate
     ];
     uceUpdate.Type__c = System.Label.Modify;
     update uceUpdate;
    }
    return '{"status":"ok","text":"Success", "redirectURL":"' + ref.getUrl() + '"}';
    /* when subscription to remain on account is greter than 1 and Mobility is selected or Not 
     and not all CWP sites selected to delete But IP n/w and UCE is also selected then throw error*/
   } else if (ipSitesubscriptionToRemainOnAccount > 1 && totalIPSitePCRCount > selectedIPSiteCount && (selectedIPNetworkCount != 0 || selectedUCECount != 0))
    return '{"status":"error","text":"' + Label.Invalid_IPNW_UCE + '"}';
   // when subscription to remain on account is greater  than 1 and Mobility is  selected   then delete mobility
   if (ipSitesubscriptionToRemainOnAccount > 1 && selectedIPSiteCount == 0 && selectedMobilityCount != 0) {
    deleteMobility(mobilityPCIDsToDelete, mobilityPCRIDsToDelete, mobilitysubsToBeReplaced);
    deleteOtherProducts(otherPCIDsToDelete, otherPCRIDsToDelete, othersubsToBeReplaced);
    return '{"status":"ok","text":"Success", "redirectURL":"' + ref.getUrl() + '"}';
   }
   // when user is deleting all IP Site from Basket then Delete IP N/w And UCE also
   if (ipSitesubscriptionToRemainOnAccount > 1 && totalIPSitePCRCount == selectedIPSiteCount) {
    deleteIPSite(ipSitePCIDsToDelete, ipSitePCRIDsToDelete, ipSitesubsToBeReplaced);
    deleteMobility(mobilityPCIDsToDelete, mobilityPCRIDsToDelete, mobilitysubsToBeReplaced);
    deleteOtherProducts(otherPCIDsToDelete, otherPCRIDsToDelete, othersubsToBeReplaced);
    if (ipNetworkPCIDsToDelete != null && !ipNetworkPCIDsToDelete.isEmpty())
     cscfga.ProductConfigurationBulkActions.deleteProductConfigsAsync(ipNetworkPCIDsToDelete);
	 system.debug ('IPNetwork ID ------>'+ipNetworkPCRIDsToUpdate);
    if (ipNetworkPCRIDsToUpdate != null && !ipNetworkPCRIDsToUpdate.isEmpty() )
     delete ipNetworkPCRIDsToUpdate;
    if (ipNetworksubsToBeReplaced != null && ipNetworksubsToBeReplaced != '') {
     List <csordtelcoa__Subscr_MACDProductBasket_Association__c> sub =  new List <csordtelcoa__Subscr_MACDProductBasket_Association__c>([select id from csordtelcoa__Subscr_MACDProductBasket_Association__c
      where csordtelcoa__Subscription__c =: ipNetworksubsToBeReplaced]);
     delete sub;
    }
    if (ucePCIDsToDelete != null && !ucePCIDsToDelete.isEmpty())
     cscfga.ProductConfigurationBulkActions.deleteProductConfigsAsync(ucePCIDsToDelete);
    if (ucePCRIDsToUpdate != null && !ucePCRIDsToUpdate.isEmpty())
     delete ucePCRIDsToUpdate;
	 system.debug ('UCE  ID ------>'+ipNetworkPCRIDsToUpdate);
    if (ucesubsToBeReplaced != null) {
     List <csordtelcoa__Subscr_MACDProductBasket_Association__c> sub = new List <csordtelcoa__Subscr_MACDProductBasket_Association__c>([select id from csordtelcoa__Subscr_MACDProductBasket_Association__c
      where csordtelcoa__Subscription__c =: ucesubsToBeReplaced
     ]);
     delete sub;
    }
    return '{"status":"ok","text":"Success"}';
   }
   // When Only IP N/w and UCE is selected to delete then throw error
   if (selectedIPSiteCount == 0 && selectedMobilityCount == 0 && (selectedIPNetworkCount != 0 || selectedUCECount != 0))
    return '{"status":"error","text":"' + Label.Invalid_IPNW_UCE + '"}';
   // when IP Site to remain on account is less than 2 and Mobility is seleted for deletion then throw error
   if ((selectedMobilityCount > 0 && ipSitesubscriptionToRemainOnAccount < 2))
    return '{"status":"error","text":"' + Label.Invalid_Selection_CWP + '"}';
   // when subscription to remain on account is less than 2  then throw error
   else if ((ipSitesubscriptionToRemainOnAccount < 2))
    return '{"status":"error","text":"' + Label.Invalid_Selection_Del + '"}';
   else
    deleteOtherProducts(otherPCIDsToDelete, otherPCRIDsToDelete, othersubsToBeReplaced);
   System.debug('Point 1');
      return '{"status":"Error","text":"' + Label.Error_PCR_Select + '"}';
  } else{
      System.debug('Point 2');
      return '{"status":"Error","text":"' + Label.Error_PCR_Select + '"}';
  }

 }
 catch (Exception e){
	 System.debug('An exception occurred in CustomButtonCustomDelete Class: ' + e.getMessage());
	 }
     System.debug('Point 3');
	 return '{"status":"Error","text":"Error Occured During Cancellation Process"}';
 }
    // Method to Delete IP Site PCR , PC and MACD Subscriptions
 public void deleteIPSite(Set < ID > ipSitePCIDsToDelete, List < csbb__Product_Configuration_Request__c > ipSitePCRIDsToDelete, Set < ID > ipSitesubsToBeReplaced) {
  List < csordtelcoa__Subscr_MACDProductBasket_Association__c > substoDelete = new List < csordtelcoa__Subscr_MACDProductBasket_Association__c > ();
  if (ipSitePCIDsToDelete != null && !ipSitePCIDsToDelete.isEmpty()) {

   cscfga.ProductConfigurationBulkActions.deleteProductConfigsAsync(ipSitePCIDsToDelete);
  }
  if (ipSitePCRIDsToDelete != null && !ipSitePCRIDsToDelete.isEmpty())
   delete ipSitePCRIDsToDelete;
  if (ipSitesubsToBeReplaced != null && !ipSitesubsToBeReplaced.isEmpty()) {

   for (csordtelcoa__Subscr_MACDProductBasket_Association__c subs: [Select Id from csordtelcoa__Subscr_MACDProductBasket_Association__c where csordtelcoa__Subscription__c in: ipSitesubsToBeReplaced])
    substoDelete.add(subs);
  }
  if (substoDelete != null && !substoDelete.isEmpty())
   delete substoDelete;
 }
// Method to Delete Mobility PCR , PC and MACD Subscriptions
 Public Void deleteMobility(Set < ID > mobilityPCIDsToDelete, List < csbb__Product_Configuration_Request__c > mobilityPCRIDsToDelete, Set < ID > mobilitysubsToBeReplaced) {
  List < csordtelcoa__Subscr_MACDProductBasket_Association__c > substoDelete = new List < csordtelcoa__Subscr_MACDProductBasket_Association__c > ();
  if (mobilityPCIDsToDelete != null && !mobilityPCIDsToDelete.isEmpty())
   cscfga.ProductConfigurationBulkActions.deleteProductConfigsAsync(mobilityPCIDsToDelete);

  if (mobilityPCRIDsToDelete != null && !mobilityPCRIDsToDelete.isEmpty())
   delete mobilityPCRIDsToDelete;
  if (mobilitysubsToBeReplaced != null && !mobilitysubsToBeReplaced.isEmpty()) {
   for (csordtelcoa__Subscr_MACDProductBasket_Association__c subs: [Select Id from csordtelcoa__Subscr_MACDProductBasket_Association__c where csordtelcoa__Subscription__c in: mobilitysubsToBeReplaced])
    substoDelete.add(subs);
  }
  if (substoDelete != null && !substoDelete.isEmpty())
   delete substoDelete;

 }


// Method to Delete Remaining Products PCR , PC and MACD Subscriptions
 Public Void deleteOtherProducts(Set < ID > otherPCIDsToDelete, List < csbb__Product_Configuration_Request__c > otherPCRIDsToDelete, Set < ID > othersubsToBeReplaced) {
  List < csordtelcoa__Subscr_MACDProductBasket_Association__c > substoDelete = new List < csordtelcoa__Subscr_MACDProductBasket_Association__c > ();
  if (otherPCIDsToDelete != null && !otherPCIDsToDelete.isEmpty())
   cscfga.ProductConfigurationBulkActions.deleteProductConfigsAsync(otherPCIDsToDelete);
  if (otherPCRIDsToDelete != null && !otherPCRIDsToDelete.isEmpty())
   delete otherPCRIDsToDelete;
  if (othersubsToBeReplaced != null && !othersubsToBeReplaced.isEmpty()) {

   for (csordtelcoa__Subscr_MACDProductBasket_Association__c subs: [Select Id from csordtelcoa__Subscr_MACDProductBasket_Association__c where csordtelcoa__Subscription__c in: othersubsToBeReplaced])
    substoDelete.add(subs);
  }
  if (substoDelete != null && !substoDelete.isEmpty())
   delete substoDelete;

 }

}