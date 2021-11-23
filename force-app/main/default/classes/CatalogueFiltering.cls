/**
*Class for Product catalogue filtering implemented for CWP and IP offer sell.

#1   12/12/2019 .  Venkata Ramanan G           Commented out the codes related to Modular Opportunity as Modular opportunity no longer use Sales Console.
*/


global with sharing class CatalogueFiltering extends csbb.PluginManager.BasePlugin {
    
    id basketId;
    
    global override Object invoke (Object input) {
        /* Id bktId = (Id)basketID;
return this.getApprovedIds(bktId);  */
        
        Map<String, String> inputMap = (Map<String, String>) input;
        basketId = inputMap.get('basketId');
        //  selectionContext = inputMap.get('selectionContext').split(',');
        return this.getApprovedIds();
    }
    
    /**
* performAction method overriden to provide create Order implementation
* @param      bktId  The basket identifier
* @return     List<Id> List of Offer's Id's
*/
    
    
    public List<Id> getApprovedIds(/*Id bktId*/) {
        
        Id bktId = basketId;
        EnvironmentVariable__c objEnv = EnvironmentVariable__c.getValues('EnableB2B4');
        Map<String,cscfga__Product_Category__c> nameCategoryMap = new Map<String,cscfga__Product_Category__c>();
        Map<String,List<String>> catOffNameCatOffListMap = new Map<String,List<String>>();
        Map<String,cscfga__Configuration_Offer__c> OfferNameOfferobjMap = new Map<String,cscfga__Configuration_Offer__c>();
        List<Id> returnList = new List<Id>();
        String baskid = string.Valueof(bktId);
        cscfga__Product_Basket__c basketObj= ProductUtil.getBasket(baskid);
        ID AccId = basketObj.csbb__Account__c;
        //ID OppId = basketObj.cscfga__Opportunity__c;
        List<csord__Subscription__c> IPVPNSubFromAccount = new List<csord__Subscription__c>();
        List<csord__Subscription__c> UCESubFromAccount = new List<csord__Subscription__c>();
        List<csord__Subscription__c> IPSiteSubFromAccount = new List<csord__Subscription__c>();
        
        List<cscfga__Product_Configuration__c> IPVPNPcFromBasket = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Product_Configuration__c> UCEPcFromBasket = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Product_Configuration__c> IPSiteFromBasket = new List<cscfga__Product_Configuration__c>();
        
        
        System.debug('******Inside Catalogue Filtering*******');        
        ID IPVPNSubId;
        ID UCEntSubId;
        ID IPSiteSubId;
        String Ucfilter='%'+System.Label.UC_Config_Name+'%';
        /*Commenting this part as well as these lists are not used in Non-Modular Opportunity flow.
         if(AccId !=null){
            /*IPVPNSubFromAccount = [SELECT id,Name FROM csord__Subscription__c WHERE Name =: System.Label.IP_Network and csord__Account__c =:AccId LIMIT 1];
            UCESubFromAccount = [SELECT id FROM csord__Subscription__c WHERE Name LIKE: Ucfilter and csord__Account__c =:AccId LIMIT 1];   
            IPSiteSubFromAccount = [SELECT id FROM csord__Subscription__c WHERE Name = 'Connected Workplace' and csord__Account__c =:AccId ]; ////////     
            for(csord__Subscription__c subscription :[SELECT id,Name FROM csord__Subscription__c 
                                                      WHERE csord__Account__c =:AccId]){
                                   // Object a = (subscription.Name== System.Label.IP_Network) ? IPVPNSubFromAccount.add(subscription) : (subscription.Name.contains(System.Label.UC_Config_Name)) ? UCESubFromAccount.add(subscription) : (subscription.Name== System.Label.Connected_Workplace) ? IPSiteSubFromAccount.add(subscription) : null;   
                                  
                                                          if(subscription.Name== System.Label.IP_Network){
                                                              IPVPNSubFromAccount.add(subscription);                        
                                                          }
                                                          else if(subscription.Name.contains(System.Label.UC_Config_Name)){
                                                              UCESubFromAccount.add(subscription);                        
                                                          }
                                                          else if(subscription.Name== System.Label.Connected_Workplace){
                                                              IPSiteSubFromAccount.add(subscription);                        
                                                          }
                                                          
                                                      }
            
            System.debug('******IP Site for Account *******'+IPSiteSubFromAccount); 
        }*/
        
        for(cscfga__Product_Category__c cat : [Select id, name from cscfga__Product_Category__c LIMIT 1000]){
            nameCategoryMap.put(cat.name, cat);
        }
        
        for(CatalogueFiltering__mdt cf: [Select Non_Package_Offer__c, Package_Offer__c from  CatalogueFiltering__mdt LIMIT 1000]){
            List<String> offerCatList = cf.Non_Package_Offer__c.split(',');
            catOffNameCatOffListMap.put(cf.Package_Offer__c, offerCatList );
        }
        
        for(cscfga__Configuration_Offer__c offer:[Select id, Name from cscfga__Configuration_Offer__c LIMIT 2000]){
            OfferNameOfferobjMap.put(offer.Name, offer);
        }

       /* Commented the Modular Opportunity flow as it no longer uses Sales Console 
        if(basketObj.cscfga__Opportunity__r.Product_Type__c == System.Label.Modular){
            
            if(catOffNameCatOffListMap.containsKey(System.Label.Modular_Products )){
                system.debug('System.Label.Modular_Products>>>>' + System.Label.Modular_Products);
                if(nameCategoryMap.get(System.Label.Modular_Products ) != null){
                    returnList.add(nameCategoryMap.get(System.Label.Modular_Products).id);
                }
                if(objEnv!=null && boolean.valueOf(objEnv.value__c) && nameCategoryMap.get(System.Label.Site_Specific) != null){
                    returnList.add(nameCategoryMap.get(System.Label.Site_Specific).id);
                }
                //Mladen changes for EDGE-81080 - PPHH offers are independant of other offers
                if(objEnv!=null && boolean.valueOf(objEnv.value__c) && nameCategoryMap.get(System.Label.Site_Agnostic) != null){
                    returnList.add(nameCategoryMap.get(System.Label.Site_Agnostic).id);
                }               
            }
            
            system.debug('returnList>>>>' + returnList);
            system.debug('nameCategoryMap>>>>' + nameCategoryMap);
            
            /*List<cscfga__Product_Configuration__c> IPVPNPcFromBasket = [Select id, Name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:bktId and cscfga__Product_Definition__r.name =:  System.Label.IP_Network];

List<cscfga__Product_Configuration__c> UCEPcFromBasket = [Select id, Name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:bktId and cscfga__Product_Definition__r.name lIKE: Ucfilter];

List<cscfga__Product_Configuration__c> IPSiteFromBasket = [Select id, Name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id =:bktId and cscfga__Product_Definition__r.name = 'Connected Workplace'];/////////////////
            
            for(cscfga__Product_Configuration__c pConfig :[Select id, cscfga__Product_Definition__r.name,Name 
                                                           FROM cscfga__Product_Configuration__c 
                                                           WHERE cscfga__Product_Basket__r.id =:bktId]){
                                                               
                                                               if(pConfig.cscfga__Product_Definition__r.name== System.Label.IP_Network){
                                                                   IPVPNPcFromBasket.add(pConfig);                        
                                                               }
                                                               if(pConfig.cscfga__Product_Definition__r.name.contains(System.Label.UC_Config_Name)){
                                                                   UCEPcFromBasket.add(pConfig);                        
                                                               }
                                                               if(pConfig.cscfga__Product_Definition__r.name== System.Label.Connected_Workplace){
                                                                   IPSiteFromBasket.add(pConfig);                        
                                                               }
                                                           }
            
            
                //Mladen changes for EDGE-81080 - PPHH offers are independant of other offers
        
        List<String> offerCatListPPHH = catOffNameCatOffListMap.get('CWP Mobility');
        if(basketObj.cscfga__Opportunity__r.Product_Type__c == System.Label.Modular 
            && catOffNameCatOffListMap.containsKey(System.Label.Modular_Products )
            && (objEnv!=null && boolean.valueOf(objEnv.value__c) && nameCategoryMap.get(System.Label.Site_Agnostic) != null)){
            
            if ((IPSiteSubFromAccount.size() <= 1) && (IPSIteFromBasket.size() <= 1))
            {
                OfferNameOfferobjMap.remove('CWP Mobility');
            }
            System.debug ('Catalogue filtering OfferNameOfferobjMap: ' + OfferNameOfferobjMap);                     
        }

            System.debug('******IP Site from Basket *******'+IPSiteFromBasket); 
            if((!IPVPNPcFromBasket.isEmpty() || !IPVPNSubFromAccount.isEmpty()) && (!UCEPcFromBasket.isEmpty() || !UCESubFromAccount.isEmpty())){
                if(catOffNameCatOffListMap.containsKey(System.Label.Connected_Workplace_Package) && OfferNameOfferobjMap.containsKey(System.Label.Connected_Workplace_Package)){
                    
                    List<String> offerCatList = catOffNameCatOffListMap.get('Connected Workplace');
                    System.debug('******Connected Workplace *******'+offerCatList); 
                    System.debug('******beforce OfferNameOfferobjMap *******'+OfferNameOfferobjMap); 
                    if(offerCatList.size() > 0){
                        for (String key : offerCAtList){
                            System.debug('******key*******'+key); 
                            OfferNameOfferobjMap.remove(key);
                        }
                        System.debug('OfferNameOfferobjMap>>>>>' + OfferNameOfferobjMap);
                        //OfferNameOfferobjMap.remove(System.Label.Connected_Workplace_Package);
                        if(OfferNameOfferobjMap.values().size() > 0){
                            Map<ID,cscfga__Configuration_Offer__c> offerMap = new Map<ID,cscfga__Configuration_Offer__c>(OfferNameOfferobjMap.values());
                            returnList.addAll(offerMap.keySet());
                        } 
                        
                        System.debug('******Connected Workplace returnList*******'+returnList); 
                    }
                }
            }
            else if((IPVPNPcFromBasket.isEmpty() && IPVPNSubFromAccount.isEmpty()) && (!UCEPcFromBasket.isEmpty() || !UCESubFromAccount.isEmpty())){
                List<String> offerCatList = catOffNameCatOffListMap.get('IP Network');
                System.debug('******IP Network*******'+offerCatList); 
                if(offerCatList.size() > 0){
                    for (String key : offerCAtList){
                        OfferNameOfferobjMap.remove(key);
                    }
                    if(OfferNameOfferobjMap.values().size() > 0){
                        Map<ID,cscfga__Configuration_Offer__c> offerMap = new Map<ID,cscfga__Configuration_Offer__c>(OfferNameOfferobjMap.values());
                        returnList.addAll(offerMap.keySet());
                    } 
                    System.debug('******IP Network returnList*******'+returnList);
                }
                
                
            }else if((!IPVPNPcFromBasket.isEmpty() || !IPVPNSubFromAccount.isEmpty()) && (UCEPcFromBasket.isEmpty() && UCESubFromAccount.isEmpty())){
                List<String> offerCatList = catOffNameCatOffListMap.get('Unified Communication Enterprise');
                System.debug('******Unified Communication Enterprise*******'+offerCatList);
                if(offerCatList.size() > 0){
                    for (String key : offerCAtList){
                        OfferNameOfferobjMap.remove(key);
                    }
                    if(OfferNameOfferobjMap.values().size() > 0){
                        Map<ID,cscfga__Configuration_Offer__c> offerMap = new Map<ID,cscfga__Configuration_Offer__c>(OfferNameOfferobjMap.values());
                        returnList.addAll(offerMap.keySet());
                    } 
                    System.debug('******Unified Communication Enterprise returnList*******'+returnList);
                }
                
                
            }
            else{
                List<String> offerCatList = catOffNameCatOffListMap.get(System.Label.Connected_Workplace_Package);
                System.debug('******Connected_Workplace_Package*******'+offerCatList);
                if(offerCatList.size() > 0){
                    for (String key : offerCAtList){
                        OfferNameOfferobjMap.remove(key);
                    }
                    System.debug('******OfferNameOfferobjMap*******'+OfferNameOfferobjMap);
                    if(OfferNameOfferobjMap.values().size() > 0){
                        Map<ID,cscfga__Configuration_Offer__c> offerMap = new Map<ID,cscfga__Configuration_Offer__c>(OfferNameOfferobjMap.values());
                        returnList.addAll(offerMap.keySet());
                    }
                    System.debug('******Connected_Workplace_Package returnList*******'+returnList);
                }
                
            }
            if ((IPSiteSubFromAccount.size() > 1) || (IPSIteFromBasket.size() > 1)) {
                String ProdCatName;
                if(objEnv!=null && boolean.valueOf(objEnv.value__c)){
                    ProdCatName =System.Label.Site_Agnostic; 
                }else{
                    ProdCatName = System.Label.Mobility;
                }
                
                cscfga__Product_Category__c prodCategory = [Select id, name from cscfga__Product_Category__c where Name =:ProdCatName];
                returnList.add(prodCategory.Id);  
            }
        
            system.debug('enter returnList==//'+returnList);
            
            
        return returnList;
        } 
        else{ */
            if(basketObj.cscfga__Opportunity__r.Product_Type__c != System.Label.Modular && catOffNameCatOffListMap.containsKey(System.Label.Modular_Products)){               
                List<String> offerCatList = catOffNameCatOffListMap.get(System.Label.Modular_Products);
                System.debug('******Modular_Products offerCatList*******'+offerCatList);
                for(String key : offerCatList){
                    if(nameCategoryMap.get(key) != null){
                        returnList.add(nameCategoryMap.get(key).id);
                        
                    }
                    Map<ID,cscfga__Configuration_Offer__c> offerMap = new Map<ID,cscfga__Configuration_Offer__c>(OfferNameOfferobjMap.values());
                    returnList.addAll(offerMap.keySet());
                }
                System.debug('******Modular_Products returnList *******'+returnList);
            }
            system.debug('enter returnList==//'+returnList);
            return returnList;
       //}
    }
}