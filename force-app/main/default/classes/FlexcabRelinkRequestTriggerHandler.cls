public with sharing class FlexcabRelinkRequestTriggerHandler {

  /*
  Scenario 1. IF CIDN does not exist
    a) Create CIDN by invoking getCustomer
    b) Create BA using the created customer
    c) Re-associate services to the BA and CIDN created above
  Scenario 2. IF CIDN exists but BA does not exist
    a) Create BA for the same CIDN
    b) Re-associate services to the BA and CIDN created above
  Scenario 3. IF CIDN exists and BA exists but BA not associated to CIDN
    a) Update BA to associate with correct CIDN
    b) Re-associate services to the BA and CIDN created above
  Scenario 4. IF CIDN exists and BA exists and BA is associated to CIDN
    a) Update services to point to correct CIDN and BA

  After All the above use cases, check if the subscription for the service has other services. 
  If yes, re-associate them with the correct BA and CIDN in the BA object.

  */
  /* 
  @future(callout=true)
  //Method to drive the re-link process.
  private static void ProcessRecordsAsync(Set<Id> relinkIds){
    TCMCustomerSearchController T = new TCMCustomerSearchController();
    List<Account> lstAccts = new List<Account>(); 
    Map<Id, Billing_Account__c> mapBillingAcct;
    Map<Id, Billing_Account__c> mapBillingAcct2;
    Map<Id, Account> mapExistAccounts;
    Map<Decimal, Account> mapCIDNAccount = new Map<Decimal, Account>();
    Map<Decimal, Flexcab_Relink_Request__c> mapCIDNRelinkReq = new Map<Decimal, Flexcab_Relink_Request__c>();
    List<Decimal> lstInsertedCIDN = new List<Decimal>(); //List of CIDNs to fetch from an external system 
    List<Decimal> lstInsertedServNums = new List<Decimal>(); //List of Serv Numbers 
    Map<Decimal, Decimal> lstOnlyFIARelinkNums = new Map<Decimal, Decimal>(); 
    List<String> lstStrInsertedCIDN = new List<String>();
    List<Decimal> lstInsertedFIA = new List<Decimal>(); //List of CIDNs present in Edge
    Map<Decimal, Id> mapCIDNtoAcctId = new Map<Decimal, Id>();
    map<Id, Flexcab_Relink_Request__c> relinkReqMap = new map<Id, Flexcab_Relink_Request__c>([select Id, Name, Status__c, CIDN__c, 
                                Flexcab_IA__c,FNN__c
                                from Flexcab_Relink_Request__c 
                                where Id IN :relinkIds AND Status__c = 'PENDING']);
    
    try{
      if(!relinkReqMap.isEmpty()){
        for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
          lstInsertedCIDN.add(Decimal.valueOf(F.CIDN__c));
          lstInsertedFIA.add(Decimal.valueOf(F.Flexcab_IA__c));
          if(F.FNN__c != null)
            lstInsertedServNums.add(Decimal.valueOf(F.FNN__c));
          else
            lstOnlyFIARelinkNums.put(Decimal.valueOf(F.Flexcab_IA__c), Decimal.valueOf(F.CIDN__c));
          lstStrInsertedCIDN.add(F.CIDN__c);
          mapCIDNRelinkReq.put(Decimal.valueOf(F.CIDN__c), F);
        }
        
        mapExistAccounts = new Map<Id, Account>([select Id, CIDN__c from Account where CIDN__c IN :lstStrInsertedCIDN]);
        if(!mapExistAccounts.isEmpty()){
          for(Account a : mapExistAccounts.values()){
            mapCIDNAccount.put(Decimal.valueOf(a.CIDN__c), a);
          }
          for(Decimal CIDN : mapCIDNRelinkReq.keySet()){
            if(!mapCIDNAccount.containsKey(CIDN)){
                            ImportTCMCustomerByCIDN importTest = new ImportTCMCustomerByCIDN();
              importTest.importCustomerAndContactbyCIDN(String.valueOf(CIDN),ImportTCMCustomerByCIDN.SourceFrom.SEEDING);

              //List<Account> lstAccts = new List<Account>();
              //T.startAdvancedSearch(); //TCM search works only for 1 CIDN at the moment: 4899416738. This has to be changed later when the interface is ready
              //Assume for now that all the accounts will be created for these CIDNs and returned with every method call
              //Account a = new Account();
              //a.Name = 'Test Account for ' + cidn;
              //a.CIDN__c = String.valueOf(cidn);
              //insert a;
              //lstAccts.add(a);
            }

          }
          //if(!lstAccts.isEmpty())
              //upsert lstAccts;
          for(Account a : [select Id, CIDN__c from Account where CIDN__c IN :lstStrInsertedCIDN])
            mapCIDNtoAcctId.put(Decimal.valueOf(a.CIDN__c), a.Id);

          List<Billing_Account__c> lstNewBAs = CreateBillingAccount(relinkReqMap, lstInsertedServNums, lstOnlyFIARelinkNums, mapCIDNtoAcctId);
          if(!lstNewBAs.isEmpty()){
            insert lstNewBAs;
            LinkFIAToSubscription(lstNewBAs);
          }
          RemoveOldFIAAndServNumAssociationwithCIDN(relinkReqMap);
          //SetRelinkStatusToProcessed(lstInsertedCIDN);
          ReassociationOtherServicesInSubscription(lstInsertedServNums);

        }
        else{
          
          for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
            ImportTCMCustomerByCIDN importTest = new ImportTCMCustomerByCIDN();
            importTest.importCustomerAndContactbyCIDN(String.valueOf(F.CIDN__c),ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
                        //T.startAdvancedSearch(); //TCM search works only for 1 CIDN at the moment: 4899416738. This has to be changed later when the interface is ready
            //Assume for now that all the accounts will be created for these CIDNs and returned with every method call
            //Account a = new Account(); 
            //a.Name = 'Test Account for ' + F.CIDN__c;
            //a.CIDN__c = String.valueOf(F.CIDN__c);
            //insert a;
            //lstAccts.add(a);

          }  
          //if(!lstAccts.isEmpty())
              //upsert lstAccts;
          for(Account a : [select Id, CIDN__c from Account where CIDN__c IN :lstStrInsertedCIDN])
            mapCIDNtoAcctId.put(Decimal.valueOf(a.CIDN__c), a.Id);

          List<Billing_Account__c> lstNewBAs = CreateBillingAccount(relinkReqMap, lstInsertedServNums, lstOnlyFIARelinkNums, mapCIDNtoAcctId);
          if(!lstNewBAs.isEmpty()){
            insert lstNewBAs;
            LinkFIAToSubscription(lstNewBAs);
          }
          RemoveOldFIAAndServNumAssociationwithCIDN(relinkReqMap);
          ReassociationOtherServicesInSubscription(lstInsertedServNums);
        }
        SetRelinkStatusToProcessed(lstInsertedCIDN, lstInsertedServNums);
      }
    }
    catch(Exception e){
      Logger log = Logger.getLogger('Flexcab Relink Request Error');
            log.logResponse(e.getMessage(),true);
    }
  }
    
  */

/*
  public static void ProcessRecords(map<Id, Flexcab_Relink_Request__c> relinkReqMap){
    ProcessRecordsAsync(relinkReqMap.keySet());

  }

  public static void ProcessRecordsBeforeInsert(List<Flexcab_Relink_Request__c> lstRelinkReqs){
    Map<String, String> mapCIDNtoFIA = new Map<String, String>();
    Map<String, String> mapCIDNToServNum = new Map<String, String>();
    //Map<Id, Decimal> mapRelinkReqtoServNum = new Map<Id, Decimal>();

    List<String> lstCIDNs = new List<String>();
    List<String> lstFIAs = new List<String>();
    List<String> lstServNumss = new List<String>();

    for(Flexcab_Relink_Request__c F : lstRelinkReqs){
      lstCIDNs.add(F.CIDN__c);
      lstFIAs.add(F.Flexcab_IA__c);
      lstServNumss.add(F.FNN__c);
    }
    
    map<Id, Flexcab_Relink_Request__c> relinkReqMap = new map<Id, Flexcab_Relink_Request__c>([select Id, Name, Status__c, CIDN__c, 
                              Flexcab_IA__c, FNN__c
                              from Flexcab_Relink_Request__c 
                              where CIDN__c IN:lstCIDNs AND Flexcab_IA__c IN :lstFIAs AND
                              FNN__c IN :lstServNumss AND Status__c = 'COMPLETE']);
    if(!relinkReqMap.isEmpty()){
      for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
        mapCIDNtoFIA.put(F.CIDN__c, F.Flexcab_IA__c);
        mapCIDNToServNum.put(F.CIDN__c, F.FNN__c);
      }

      for(Flexcab_Relink_Request__c F : lstRelinkReqs){
        if(mapCIDNtoFIA.containsKey(F.CIDN__c) && mapCIDNtoFIA.get(F.CIDN__c) == F.Flexcab_IA__c && 
          mapCIDNToServNum.get(F.CIDN__c) == F.FNN__c)

            F.Status__c = 'COMPLETE';
      }
    }

  }

  //Method to create a new Billing Account record with the values for FIA, CIDN and Service Number
  private static List<Billing_Account__c> CreateBillingAccount(Map<Id, Flexcab_Relink_Request__c> relinkReqMap, List<Decimal> lstInsertedServNums, Map<Decimal, Decimal> lstOnlyFIARelinkNums, Map<Decimal, Id> mapCIDNtoAcctId){
    List<Billing_Account__c> mapNewBillAccts = new List<Billing_Account__c>();
    List<Billing_Account__c> mapNewBillAccts2 = new List<Billing_Account__c>();
    Map<Decimal, Boolean> mapServNum = new Map<Decimal, Boolean>();
    Map<Decimal, Billing_Account__c> mapServUpdateOnly = new Map<Decimal, Billing_Account__c>();
    if(!lstInsertedServNums.isEmpty()){
      mapServNum = CheckServicesExist(lstInsertedServNums);
      mapServUpdateOnly = CheckIfOnlyServUpdate(relinkReqMap);
    }
    Billing_Account__c thisBillAcct;
    Billing_Account__c thisBillAcct2;
    Map<Decimal, Decimal> ServNumToFIA = new Map<Decimal, Decimal>();
    if(!mapServNum.isEmpty()){
      for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
        if(mapServNum.containsKey(Decimal.valueOf(F.FNN__c)) && 
              mapServNum.get(Decimal.valueOf(F.FNN__c)) == true){

            if(!mapServUpdateOnly.isEmpty() && mapServUpdateOnly.containsKey(Decimal.valueOf(F.CIDN__c))) {
              thisBillAcct2 = mapServUpdateOnly.get(Decimal.valueOf(F.CIDN__c));
              //thisBillAcct.Account__c = s;
              //thisBillAcct2.Financial_CIDN__c = F.CIDN__c;
              thisBillAcct2.Service_Number__c = Decimal.valueOf(F.FNN__c);
              //thisBillAcct2.Flexcab_IA__c = F.Flexcab_IA__c;
              mapNewBillAccts2.add(thisBillAcct2);
            }
            else{
            
              thisBillAcct = new Billing_Account__c();
              //thisBillAcct.Account__c = s;
              //thisBillAcct.Financial_CIDN__c = Decimal.valueOf(F.CIDN__c);
              //thisBillAcct.Service_Number__c = Decimal.valueOf(F.FNN__c);
              //thisBillAcct.Flexcab_IA__c = Decimal.valueOf(F.Flexcab_IA__c);
              if(mapCIDNtoAcctId.containsKey(Decimal.valueOf(F.CIDN__c)))
                thisBillAcct.Account__c = mapCIDNtoAcctId.get(Decimal.valueOf(F.CIDN__c));
              mapNewBillAccts.add(thisBillAcct);
              ServNumToFIA.put(Decimal.valueOf(F.FNN__c), Decimal.valueOf(F.Flexcab_IA__c));
          }
        }
      }
    }
        else{
            for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
                if(F.FNN__c == null){
                    thisBillAcct2 = new Billing_Account__c();
                    //thisBillAcct2.Financial_CIDN__c  = Decimal.valueOf(F.CIDN__c);
                    //thisBillAcct2.Flexcab_IA__c = Decimal.valueOf(F.Flexcab_IA__c);
                    thisBillAcct2.Account__c = mapCIDNtoAcctId.get(Decimal.valueOf(F.CIDN__c));
                    mapNewBillAccts2.add(thisBillAcct2);
                }
            }
        }*/
    /*if(!lstOnlyFIARelinkNums.isEmpty()){
      for(Decimal FIA : lstOnlyFIARelinkNums.keySet()){ 
        thisBillAcct = new Billing_Account__c();
        //thisBillAcct.Account__c = s;
        thisBillAcct.Financial_CIDN__c = lstOnlyFIARelinkNums.get(FIA);
        //thisBillAcct.Service_Number__c = F.FNN__c;
        thisBillAcct.Flexcab_IA__c = FIA;
        mapNewBillAccts.add(thisBillAcct);
      }
    }*/
    //}
    //if(!lstNewBillAccts.isEmpty())
      //upsert lstNewBillAccts;
/*    if(!mapNewBillAccts2.isEmpty())
      upsert mapNewBillAccts2;
    return mapNewBillAccts;
  }
*/
  //Method to remove the link between services and FIA/CIDN in the billing account table, when the service gets linked to a different
  //FIA and/or CIDN
  /*
  private static void RemoveOldFIAAndServNumAssociationwithCIDN(Map<Id, Flexcab_Relink_Request__c> relinkReqMap){
    Map<Id, Billing_Account__c> mapNewBillAccts;// = new Map<Id, Billing_Account__c>();
    Map<Id, Billing_Account__c> mapNewBillAccts2;// = new Map<Id, Billing_Account__c>();
    Map<Id, Billing_Account__c> mapNewBillAccts3;
    Map<Decimal, Decimal> mapFIACIDN = new Map<Decimal, Decimal>();
    List<Billing_Account__c> lstBillAccts = new List<Billing_Account__c>();
    List<Decimal> lstCIDNs = new List<Decimal>();
    List<Decimal> lstFIAs = new List<Decimal>();
    List<Decimal> lstServNumss = new List<Decimal>();
    for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
      lstCIDNs.add(Decimal.valueOf(F.CIDN__c));
      lstFIAs.add(Decimal.valueOf(F.Flexcab_IA__c));
      lstServNumss.add(Decimal.valueOf(F.FNN__c));
      mapFIACIDN.put(Decimal.valueOf(F.Flexcab_IA__c), Decimal.valueOf(F.CIDN__c));
    }
*/
    //mapNewBillAccts3 = new Map<Id, Billing_Account__c>([select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c where Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c NOT IN:lstCIDNs AND Service_Number__c NOT IN:lstServNumss]);//-- AND Service_Number__c != null]);
    

   /* mapNewBillAccts2 = new Map<Id, Billing_Account__c>([select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c
                              where (Financial_CIDN__c NOT IN:lstCIDNs OR Flexcab_IA__c NOT IN:lstFIAs) AND
                              Service_Number__c IN :lstServNumss]);
    for(Billing_Account__c BA : mapNewBillAccts2.values()){
      BA.Service_Number__c = null;
      lstBillAccts.add(BA);
    }

    if(!lstBillAccts.isEmpty())
      update (lstBillAccts);


    */
    
    //mapNewBillAccts.clear();

   /* mapNewBillAccts = new Map<Id, Billing_Account__c>([select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c
                              where (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c NOT IN:lstCIDNs)]); //OR (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c IN:lstCIDNs AND Service_Number__c IN :lstServNumss)
    

    if(!mapNewBillAccts.isEmpty()){
      

      delete (mapNewBillAccts.values());
    }

    if(!mapNewBillAccts3.isEmpty()){
      List<Billing_Account__c> lstBillAccts2 = new List<Billing_Account__c>();
      for(Billing_Account__c BA : mapNewBillAccts3.values()){
        Billing_Account__c B = new Billing_Account__c();
        B.Financial_CIDN__c = mapFIACIDN.get(BA.Flexcab_IA__c); //BA.Financial_CIDN__c;
        B.Flexcab_IA__c = BA.Flexcab_IA__c;
        B.Service_Number__c = BA.Service_Number__c;
        lstBillAccts2.add(B);

      }

      if(!lstBillAccts2.isEmpty()){
        insert lstBillAccts2;
        LinkFIAToSubscription(lstBillAccts2);
      }
    }

    
  }


  /*private static void RemoveOldFIAAndServNumAssociationwithCIDN2(Map<Id, Flexcab_Relink_Request__c> relinkReqMap){
    Map<Id, Billing_Account__c> mapNewBillAccts = new Map<Id, Billing_Account__c>();
    Map<Id, Billing_Account__c> mapNewBillAccts2 = new Map<Id, Billing_Account__c>();
    Map<Id, Billing_Account__c> mapNewBillAccts3 = new Map<Id, Billing_Account__c>();
    Map<Id, Billing_Account__c> mapNewBillAccts4 = new Map<Id, Billing_Account__c>();
    Map<Decimal, Decimal> mapFIACIDN = new Map<Decimal, Decimal>();
    List<Billing_Account__c> lstBillAccts = new List<Billing_Account__c>();
    Set<Decimal> lstCIDNs = new Set<Decimal>();
    Set<Decimal> lstFIAs = new Set<Decimal>();
    Set<String> lstServNumss = new Set<String>();
    for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
      lstCIDNs.add(F.CIDN__c);
      lstFIAs.add(F.Flexcab_IA__c);
      lstServNumss.add(F.FNN__c);
      mapFIACIDN.put(F.Flexcab_IA__c, F.CIDN__c);
    }


    mapNewBillAccts4 = new Map<Id, Billing_Account__c>([select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c
                              where (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c NOT IN:lstCIDNs AND Service_Number__c NOT IN:lstServNumss AND Service_Number__c != null) 
                              OR
                              ((Financial_CIDN__c NOT IN:lstCIDNs OR Flexcab_IA__c NOT IN:lstFIAs) AND Service_Number__c IN :lstServNumss) 
                              OR
                              (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c NOT IN:lstCIDNs)]);
    

    
    for(Billing_Account__c BA : mapNewBillAccts4.values()){
      if(lstFIAs.contains(BA.Flexcab_IA__c) && !lstCIDNs.contains(BA.Financial_CIDN__c) && !lstServNumss.contains(BA.Service_Number__c) && BA.Service_Number__c != null)
        mapNewBillAccts3.put(BA.Id, BA);
      else if((!lstCIDNs.contains(BA.Financial_CIDN__c) || !lstFIAs.contains(BA.Flexcab_IA__c)) && lstServNumss.contains(BA.Service_Number__c))
        mapNewBillAccts2.put(BA.Id, BA);
      else if(lstFIAs.contains(BA.Flexcab_IA__c) && !lstCIDNs.contains(BA.Financial_CIDN__c))
        mapNewBillAccts.put(BA.Id, BA);
    }

    for(Billing_Account__c BA : mapNewBillAccts2.values()){
      BA.Service_Number__c = null;
      lstBillAccts.add(BA);
    }

    if(!lstBillAccts.isEmpty())
      update (lstBillAccts);

    /*mapNewBillAccts = new Map<Id, Billing_Account__c>([select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c
                              where (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c NOT IN:lstCIDNs)]); //OR (Flexcab_IA__c IN :lstFIAs AND Financial_CIDN__c IN:lstCIDNs AND Service_Number__c IN :lstServNumss)

    */
    /*if(!mapNewBillAccts.isEmpty())
      delete (mapNewBillAccts.values());
    


    if(!mapNewBillAccts3.isEmpty()){
      List<Billing_Account__c> lstBillAccts2 = new List<Billing_Account__c>();
      for(Billing_Account__c BA : mapNewBillAccts3.values()){
        Billing_Account__c B = new Billing_Account__c();
        B.Financial_CIDN__c = mapFIACIDN.get(BA.Flexcab_IA__c); //BA.Financial_CIDN__c;
        B.Flexcab_IA__c = BA.Flexcab_IA__c;
        B.Service_Number__c = BA.Service_Number__c;
        lstBillAccts2.add(B);

      }

      if(!lstBillAccts2.isEmpty()){
        insert lstBillAccts2;
        LinkFIAToSubscription(lstBillAccts2);
      }
    }

    
  }*/
/*
  //Set the status of the Relink Requests records to 'COMPLETE' / 'IGNORED' based on the availability of Service Number
  private static void SetRelinkStatusToProcessed(List<Decimal> lstProcessedCIDNs, List<Decimal> lstInsertedServNums){
    if(!lstProcessedCIDNs.isEmpty()){
      List<String> lstProcessedCIDNSsString = new List <String>();
      for(Decimal cidn:lstProcessedCIDNs)
      {
         lstProcessedCIDNSsString.add(String.valueOf(cidn));
      }
      Map<Decimal, Boolean> mapServNum = CheckServicesExist(lstInsertedServNums);
      List<Flexcab_Relink_Request__c> lstRelinkReqToUpdate = [select Id, Status__c, CIDN__c,FNN__c 
                                  from Flexcab_Relink_Request__c
                                  where Status__c = 'PENDING' and
                                  CIDN__c IN :lstProcessedCIDNSsString];
      if(!lstRelinkReqToUpdate.isEmpty()){
        for(Flexcab_Relink_Request__c f : lstRelinkReqToUpdate){
          if( (mapServNum.containsKey(Decimal.valueOf(f.FNN__c)) && 
              mapServNum.get(Decimal.valueOf(f.FNN__c)) == true) || (f.FNN__c == null) ){
          
                f.Status__c = 'COMPLETE';
          }
          else{
            f.Status__c = 'IGNORED';
            f.Comments__c = 'Service Number Not Found';
          }
        }
      }

      update lstRelinkReqToUpdate;
    }

  }
    

  //Re-associate all services belonging to the same subscription with the correct billing account
  private static void ReassociationOtherServicesInSubscription(List<Decimal> lstServNumss){//, Map<Decimal, Decimal> mapCIDN){
    List<Id> subIds = new List<Id>();
    List<Decimal> ServNumsToReplace = new List<Decimal>();
    Map<Id, String> mapNewServSub = new Map<Id, String>();
    Map<Decimal, Id> mapOldServSub = new Map<Decimal, Id>();
    List<Billing_Account__c> billAcctsToUpdate = new List<Billing_Account__c>();
    List<Billing_Account__c> billAcctsToUpdate2 = new List<Billing_Account__c>();
    System.debug('Inside ReassociationOtherServicesInSubscription. lstServNumss == ' + lstServNumss);
    Map<String, Flexcab_Relink_Request__c> mapServNumRelinkReq = new Map<String, Flexcab_Relink_Request__c>();

    Map<Id, csord__service__c> lstServwithSubs = new Map<Id, csord__service__c>([select Id, csord__Subscription__c, Service_FNN__c from csord__service__c 
                            where Service_FNN__c IN:lstServNumss]);
    Map<Id, Flexcab_Relink_Request__c> relinkReqMap = new map<Id, Flexcab_Relink_Request__c>([select Id, Name, Status__c, CIDN__c, 
                                Flexcab_IA__c,FNN__c
                                from Flexcab_Relink_Request__c 
                                where Service_FNN__c IN :lstServNumss AND
                                Status__c = 'PENDING']);
    if(!relinkReqMap.isEmpty()){
      for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
        mapServNumRelinkReq.put(F.FNN__c, F);
      }
    }
    System.debug('mapServNumRelinkReq == ' + mapServNumRelinkReq);

    if(!lstServwithSubs.isEmpty()){
      for(csord__service__c Serv : lstServwithSubs.values()){
        subIds.add(Serv.csord__Subscription__c);
        mapNewServSub.put(Serv.csord__Subscription__c, String.valueOf(Serv.Service_FNN__c));
      }
    
      List<csord__service__c> lstOtherServs = [select Id, csord__Subscription__c, Service_FNN__c from csord__service__c 
                          where Service_FNN__c NOT IN:lstServNumss AND csord__Subscription__c IN :subIds];
      System.debug('lstOtherServs == ' + lstOtherServs);
      if(!lstOtherServs.isEmpty()){
        for(csord__service__c S : lstOtherServs){
          if(S.Service_FNN__c != null){                      
            ServNumsToReplace.add(S.Service_FNN__c);
            mapOldServSub.put(S.Service_FNN__c,S.csord__Subscription__c);
          }
        }
      }
      if(!mapOldServSub.isEmpty() && !mapNewServSub.isEmpty()){
        billAcctsToUpdate = [select Id, Financial_CIDN__c, Flexcab_IA__c, Service_Number__c from Billing_Account__c where 
                    Service_Number__c IN :ServNumsToReplace];
        System.debug('billAcctsToUpdate == ' + billAcctsToUpdate);
        if(!billAcctsToUpdate.isEmpty()){
          for(Billing_Account__c BA : billAcctsToUpdate){
            BA.Financial_CIDN__c = Decimal.valueOf(mapServNumRelinkReq.get(mapNewServSub.get(mapOldServSub.get(BA.Service_Number__c))).CIDN__c);
            BA.Flexcab_IA__c = Decimal.valueOf(mapServNumRelinkReq.get(mapNewServSub.get(mapOldServSub.get(BA.Service_Number__c))).Flexcab_IA__c);
            billAcctsToUpdate2.add(BA);
          }
        }
        if(!billAcctsToUpdate2.isEmpty())
          update billAcctsToUpdate2;
      }

    }
  }
  
  //Utility method to return a map of services with TRUE/FALSE if the service exists/doesn't exist
  private static Map<Decimal, Boolean> CheckServicesExist(List<Decimal> lstInsertedServNums){
    Map<Decimal, Boolean> mapServNum = new Map<Decimal, Boolean>();
    Map<Decimal, csord__service__c> mapServNumToService = new Map<Decimal, csord__service__c>();
    List<csord__service__c> lstServices = [select Id, Service_FNN__c from csord__service__c where Service_FNN__c IN :lstInsertedServNums];
    if(!lstServices.isEmpty()){
      for(csord__service__c S : lstServices){
        mapServNumToService.put(S.Service_FNN__c, S);
        mapServNum.put(S.Service_FNN__c, true);
      }
    
      if(mapServNum.size() != lstInsertedServNums.size()){
        for(Decimal S : lstInsertedServNums){
          if(!mapServNumToService.containsKey(S))
            mapServNum.put(S, false);
        }
      }
    }  
    else{
      for(Decimal S : lstInsertedServNums)
        mapServNum.put(S, false);
    }
    return mapServNum;
  }

  private static Map<Decimal, Billing_Account__c> CheckIfOnlyServUpdate(Map<Id, Flexcab_Relink_Request__c> relinkReqMap){
    Map<Decimal, Billing_Account__c> lstBillAccts = new Map<Decimal, Billing_Account__c>();
    Map<String, Decimal> mapServNumsCIDN = new Map<String, Decimal>();
    Map<String, Decimal> mapServNumFIA = new Map<String, Decimal>();
    Map<Decimal, Decimal> mapCIDNServNum = new Map<Decimal, Decimal>();
    //Map<Decimal, Decimal> mapServNums = new Map<Decimal, Decimal>();
    for(Flexcab_Relink_Request__c F : relinkReqMap.values()){
      mapServNumsCIDN.put(F.FNN__c, Decimal.valueOf(F.CIDN__c));
      mapServNumFIA.put(F.FNN__c, Decimal.valueOf(F.Flexcab_IA__c));
      mapCIDNServNum.put(Decimal.valueOf(F.CIDN__c), Decimal.valueOf(F.FNN__c));
      //lstFIAs.add(Decimal.valueOf(F.Flexcab_IA__c));
    }

    for(Billing_Account__c BA : [select Id, Flexcab_IA__c, Service_Number__c, Financial_CIDN__c from Billing_Account__c
                    where Flexcab_IA__c IN :mapServNumFIA.values() AND Financial_CIDN__c IN:mapServNumsCIDN.values()
                      AND Service_Number__c = null]){

      //if(BA.Flexcab_IA__c == mapServNumFIA.get(Decimal.valueOf(BA.Service_Number__c)) && BA.Financial_CIDN__c == mapServNumsCIDN.get(Decimal.valueOf(BA.Service_Number__c)))
        System.debug(' BA.Flexcab_IA__c == ' + BA.Flexcab_IA__c);
        //System.debug(' mapServNumFIA.get(Decimal.valueOf(BA.Service_Number__c)) == ' + mapServNumFIA.get(Decimal.valueOf(BA.Service_Number__c)));
        //System.debug(' BA.Financial_CIDN__c == ' + mapServNumsCIDN.get(Decimal.valueOf(BA.Service_Number__c)));
        //System.debug(' BA.Financial_CIDN__c == ' + BA.Financial_CIDN__c);
        lstBillAccts.put(BA.Financial_CIDN__c, BA);
      //}
      //else
        //mapServNum.put(Decimal.valueOf(BA.Service_Number__c), false);

    }

    return lstBillAccts;


  }

  //Method to link the Billing account with the subscription gor the given services
  private static void LinkFIAToSubscription(List<Billing_Account__c> lstBillAcctsToLink){
    //Map<Decimal, Id> mapServNumSubId = new Map<Decimal, Decimal>();
    Map<Decimal, Id> mapServNumBillAcctId = new Map<Decimal, Id>();
    Map<Decimal, Id> mapFIABillAcctId = new Map<Decimal, Id>();
    Map<Decimal, Id> mapServNumBillAcctId2 = new Map<Decimal, Id>();
    Map<Decimal, Decimal> mapServNumFIA = new Map<Decimal, Decimal>();
    List<csord__Subscription__c> lstSubsToUpdate = new List<csord__Subscription__c>();
    Set<csord__Subscription__c> lstSubsToUpdate2 = new Set<csord__Subscription__c>();
    List<Decimal> lstFIAs = new List<Decimal>();
    List<Decimal> lstServNums = new List<Decimal>();
    for(Billing_Account__c B : lstBillAcctsToLink){
      lstFIAs.add(B.Flexcab_IA__c);
      if(B.Service_Number__c != null)
      //stServNums.add(B.Service_Number__c);
        mapServNumBillAcctId.put(B.Service_Number__c, B.Id);
        mapFIABillAcctId.put(B.Flexcab_IA__c, B.Id);//mapFIABillAcctId

    }
    System.debug('mapServNumBillAcctId == ' + mapServNumBillAcctId);
    List<csord__service__c> lstServ = [select Id, Service_FNN__c, csord__Subscription__c, csord__Subscription__r.Billing_Account__c 
                      from csord__service__c 
                      where Service_FNN__c IN :mapServNumBillAcctId.keySet() AND Service_FNN__c != null];
    String subId = '';
    if(!lstServ.isEmpty()){                  
      for(csord__service__c Serv : lstServ){
        if(mapServNumBillAcctId.containsKey(Serv.Service_FNN__c)){
          Serv.csord__Subscription__r.Billing_Account__c = mapServNumBillAcctId.get(Serv.Service_FNN__c);
          if(!subId.contains(String.valueOf(Serv.csord__Subscription__c))){
            subId = subId + String.valueOf(Serv.csord__Subscription__c);
          
          //lstSubsToUpdate.add(Serv.csord__Subscription__r);
          //if(!lstSubsToUpdate2.contains(Serv.csord__Subscription__r))
            lstSubsToUpdate2.add(Serv.csord__Subscription__r);
          }

        }
      }
    }
    else{
      //lstFIAs
      lstServ.clear();
      //mapServNumBillAcctId.clear();
      List<Billing_Account__c> lstBillAccts = [select Id, Flexcab_IA__c, Service_Number__c from Billing_Account__c where Flexcab_IA__c IN :lstFIAs
              AND Service_Number__c != null];

      if(!lstBillAccts.isEmpty()){
        for(Billing_Account__c BA : lstBillAccts){
          mapServNumBillAcctId2.put(BA.Service_Number__c, Ba.Id);
          mapServNumFIA.put(BA.Service_Number__c, BA.Flexcab_IA__c);
        }
        lstServ = [select Id, Service_FNN__c, csord__Subscription__c, csord__Subscription__r.Billing_Account__c 
                      from csord__service__c 
                      where Service_FNN__c IN :mapServNumBillAcctId2.keySet() AND Service_FNN__c != null];
        if(!lstServ.isEmpty()){    
        subId = '';              
          for(csord__service__c Serv : lstServ){
            //if(mapServNumBillAcctId2.containsKey(Decimal.valueOf(Serv.Service_FNN__c))){
              Serv.csord__Subscription__r.Billing_Account__c = mapFIABillAcctId.get(mapServNumFIA.get(Serv.Service_FNN__c)) ;
              //lstSubsToUpdate.add(Serv.csord__Subscription__r);
              if(!subId.contains(String.valueOf(Serv.csord__Subscription__c))){
                subId = subId + String.valueOf(Serv.csord__Subscription__c);
                lstSubsToUpdate2.add(Serv.csord__Subscription__r);
              }
              //}

            //}
          }
        }


      }

    }


    System.debug('lstSubsToUpdate2 == ' + lstSubsToUpdate2 + ' Size == ' + lstSubsToUpdate2.size());
    if(!lstSubsToUpdate2.isEmpty()){
      //lstSubsToUpdate.addAll(lstSubsToUpdate2);
      lstSubsToUpdate.clear();
      for(csord__Subscription__c sub : lstSubsToUpdate2){
        System.debug('Final Update, sub  == ' + sub);
        lstSubsToUpdate.add(sub);
      }
      //lstSubsToUpdate = new List<csord__Subscription__c>()
      System.debug('lstSubsToUpdate == ' + lstSubsToUpdate);
      update lstSubsToUpdate;// lstSubsToUpdate2);
      
    }

  }
*/
  
}