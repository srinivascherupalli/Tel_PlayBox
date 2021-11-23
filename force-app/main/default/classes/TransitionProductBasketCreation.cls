public with sharing class TransitionProductBasketCreation {

  //static map
  public static Map<String, String> nameValueMap = new Map<String, String>();

  //accepts Service DTO and returns set of eligible offers
  public static List<String> getEligibleOffersForTransition(ReplicatorGetServiceDataObject serviceDTO) {
    String offerName = '';
    String CIDN = serviceDTO.CIDN;
    Set<String> offerNameSet = new Set<String>();
    Account acc = [Select id from Account where CIDN__c = : CIDN];
    List<csord__Subscription__c> IPVPNSubFromAccount = new List<csord__Subscription__c>();

    if (acc.Id != null) {
      IPVPNSubFromAccount = [
                              SELECT id
                              FROM
                              csord__Subscription__c
                              WHERE
                              Name = : System.Label.IP_Network and
                                     csord__Account__c = :acc.Id
                                         LIMIT 1
                            ];
    }

    CatalogueFiltering__mdt cfilter = [
                                        Select Non_Package_Offer__c, Package_Offer__c
                                        from
                                        CatalogueFiltering__mdt
                                        WHERE
                                        Package_Offer__c = 'Connected Workplace Package'
                                            LIMIT 1
                                      ];
    List<String> offerCatList = new List<String>();
    if (IPVPNSubFromAccount.size() != 0) {
      //offerName = cfilter.Non_Package_Offer__c;
      offerCatList = cfilter.Non_Package_Offer__c.split(',');
    } else
      offerName = cfilter.Package_Offer__c;

    List<ReplicatorGetServiceDataObject.SiteDTO> siteDTO = serviceDTO.Site;
    List<ReplicatorGetServiceDataObject.ProductDTO> productDTO = new List<ReplicatorGetServiceDataObject.ProductDTO>();
    List<String> offerList = new List<String>();
    for (ReplicatorGetServiceDataObject.SiteDTO site : siteDTO) {
      for (ReplicatorGetServiceDataObject.ProductDTO pd : site.productList) {
        if (pd.Product_Type == 'ISDN-BRA') {
          System.debug('<><>');
          if (offerName != '') {
            offerNameSet.add(offerName);
          } else if (!offerCatList.isEmpty()) {
            offerNameSet.add(offerCatList[0]);
          }
        }
      }
    }
    system.debug('offerNameSet<><>' + offerNameSet);
    offerList.addAll(offerNameSet);
    system.debug('offerList<><>' + offerList);
    return offerList;
  }

  // consumes service DTO object and list of offers selected
  public static PageReference createTransitionBasket(ReplicatorGetServiceDataObject getServiceDTO, List <String> offerList, String opportunityID) {
    nameValueMap = TransitionLegacySubscriptionCreation.createLegacySubscriptionAndServices(getServiceDTO);
    List<ReplicatorGetServiceDataObject.SiteDTO> getSiteDTO = getServiceDTO.Site;
    List<ReplicatorGetServiceDataObject.ProductDTO> getProductDTO = new List<ReplicatorGetServiceDataObject.ProductDTO>();
    List<ReplicatorGetServiceDataObject.ServiceDTO> serviceList = new  List<ReplicatorGetServiceDataObject.ServiceDTO>();
    Map<String, String> serviceCharZoneMap = new  Map<String, String>();
    Map<String, List<ReplicatorGetServiceDataObject.ServiceDTO>> serviceSiteMap = new Map<String, List<ReplicatorGetServiceDataObject.ServiceDTO>>();
    Set<String> adborSet = new Set<String>();
    for (ReplicatorGetServiceDataObject.SiteDTO site : getSiteDTO) {
      adborSet.add(site.ADBOR_Id);
      for (ReplicatorGetServiceDataObject.ProductDTO pd : site.productList) {
        List<ReplicatorGetServiceDataObject.ServiceDTO> serTempList = new List<ReplicatorGetServiceDataObject.ServiceDTO>();
        serTempList.addAll(pd.service);
        if (serviceSiteMap != null && serviceSiteMap.get(site.ADBOR_ID) != null) {
          serTempList.addAll(serviceSiteMap.get(site.ADBOR_Id));

        }
        serviceSiteMap.put(site.ADBOR_Id, serTempList);
        serviceList.addAll(pd.service);
      }
    }

    for (ReplicatorGetServiceDataObject.ServiceDTO ser : serviceList) {
      for (ReplicatorGetServiceDataObject.ServiceCharacteristicDTO serChar : ser.serviceCharacteristic) {
        if (serChar.Name == 'Zone')
          serviceCharZoneMap.put(ser.Service_Id + '-Zone', serChar.value);
        else if (serChar.Name == 'Type')
          serviceCharZoneMap.put(ser.Service_Id + '-Type', serChar.value);
      }
    }
    String CIDN = getServiceDTO.CIDN;
    Map<Id, Integer> serviceUnderSiteCountMap = new Map <Id, Integer>();
    Map<String, String> siteIdZoneTypeMap = new Map <String, String>();
    System.debug('***adborSet' + adborSet);
    List<cscrm__Site__c> siteList = new List<cscrm__Site__c>(
      [
        SELECT Id, Name, display_name__c,
        cscrm__Installation_Address__r.cscrm__Address_Details__c,
        address_id__c,
        cscrm__Account__c, cscrm__Installation_Address__r.Name
        FROM cscrm__Site__c
        WHERE cscrm__Account__r.CIDN__C = :CIDN AND address_id__c IN :adborSet
      ]);

    Map<Id, cscrm__Site__c> siteAddressMap = new Map<Id, cscrm__Site__c>();
    Opportunity opp = [Select id from Opportunity where Id = :Id.ValueOF(opportunityID) limit 1];
    Account acc = [Select id from Account where CIDN__c = :CIDN];
    System.debug('***opportunity' + opp.id);
    System.debug('***acc' + acc.id);
    if (siteList != null && siteList.size() > 0) {
      for (cscrm__Site__c site : siteList) {
        Integer count = 0;
        if (serviceSiteMap != null && serviceSiteMap.containsKey(site.address_id__c)) {
          count = serviceSiteMap.get(site.address_id__c).size();
          for (ReplicatorGetServiceDataObject.serviceDTO ser : serviceSiteMap.get(site.address_id__c)) {
            if (serviceCharZoneMap != null && serviceCharZoneMap.containsKey(ser.Service_Id + '-Zone')) {
              siteIdZoneTypeMap.put(site.id + '-Zone', serviceCharZoneMap.get(ser.Service_Id + '-Zone'));

            }
            if (serviceCharZoneMap != null && serviceCharZoneMap.containsKey(ser.Service_Id + '-Type')) {
              siteIdZoneTypeMap.put(site.id + '-Type', serviceCharZoneMap.get(ser.Service_Id + '-Type'));

            }
          }
        }
        serviceUnderSiteCountMap.put(site.id, count);
        siteAddressMap.put(site.id, site);
      }
      cscfga__Product_Basket__c basketReturned = createCWPProducts(siteAddressMap, serviceUnderSiteCountMap, siteIdZoneTypeMap, opp.Id, offerList);
      return new PageReference('/' + basketReturned.Id);
    }

    return null;
  }

  public static cscfga__Product_Basket__c createCWPProducts(Map<Id, cscrm__Site__c> siteAddressMap, Map<Id, Integer> siteServiceCountMap, Map<String, String> siteIdZoneTypeMap, Id oppId, List<String> offerList) {
    String offerName = '';
    if (offerList != null && offerList.size() > 0) {
      offerName = offerList[0];
    }
    cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c ();
    basket.cscfga__Opportunity__c = oppId;
    insert basket;

    if (offerName == '') {
      offerName = 'Connected Workplace Package';
    }

    String queryString = 'Select ' + String.escapeSingleQuotes(getSobjectFields('cscfga__Product_Configuration__c')) + ' , (Select ' + String.escapeSingleQuotes(getSobjectFields('cscfga__Attribute__c')) + ' from cscfga__Attributes__r) from cscfga__Product_Configuration__c  where cscfga__Product_Basket__c =null AND cscfga__configuration_offer__r.Name =: offerName'; // added String.escapeSingleQuotes to remove vulnerabilities
    List<cscfga__Product_Configuration__c>  offerConfigList = Database.query(queryString);

    cscfga__Product_Category__c pCategory = [
        Select id
        from cscfga__Product_Category__c
        where Name = 'Modular Products'
                                            ];
    List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
    List<csbb__Product_Configuration_Request__c> pcrList = new List<csbb__Product_Configuration_Request__c>();
    List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
    Map<String, String> pcToBeCloneIdMap = new Map<String, String>();

    //Query the Voice Numbers Product Definition - EDGE-3369
    List<cscfga__Product_Definition__c> prodDefList = [
          Select id
          from
          cscfga__Product_Definition__c
          where
          Name = 'Voice FNN Details'
        ];
    List<cspmb__Price_Item__c> defaultZoneList = [
          Select id, name, zone__c, type__c
          from
          cspmb__Price_Item__c
          where
          Type__c = 'Fixed Seat' AND
                    zone__c = '1' AND
                              check_todays_date__c = true
        ];
    cscfga__Product_Definition__c prodDef;
    cspmb__Price_Item__c defaultZone;
    Map<Id, Id> siteSubMap = new Map<Id, Id>();
    List<cscfga__Attribute_Definition__c> voiceAttrDefList = new List<cscfga__Attribute_Definition__c>();
    if (!prodDefList.isEmpty()) {
      prodDef = prodDefList[0];
      voiceAttrDefList = [
                           Select id, Name
                           from cscfga__Attribute_Definition__c
                           where cscfga__Product_Definition__c = :prodDef.Id
                         ];
    }
    if (!defaultZoneList.isEmpty()) {
      defaultZone = defaultZoneList[0];
    }
    //query legacy subscription created
    List<csord__Subscription__c> subList = [
        Select id, Site__c
        from csord__Subscription__c
        where name Like 'Legacy%' and
        Site__c in: siteAddressMap.keySet()
        ORDER BY CREATEDDATE ASC
                                           ];
    for (csord__Subscription__c sub : subList) {
      siteSubMap.put(sub.site__c, sub.id);
    }
    //Query Legacy services
    List<csord__Service__c> serList = [
                                        Select id, Primary_FNN__c,
                                        csord__subscription__c,
                                        csord__subscription__r.site__c
                                        from
                                        csord__Service__c
                                        where
                                        name Like 'Legacy%' AND
                                        csord__Subscription__c in:siteSubMap.Values()
                                      ];
    Map<csord__Service__c, Id> serviceSiteMap =  new Map<csord__Service__c, Id>();
    if (serList != null) {
      for (csord__Service__c sr : serList) {
        serviceSiteMap.put(sr, sr.csord__subscription__r.site__c);
      }
    }
    if (siteAddressMap != null && siteAddressMap.values().size() > 0) {
      for (cscrm__Site__c site : siteAddressMap.values()) {
        for (cscfga__Product_Configuration__c pc : offerConfigList) {
          cscfga__Product_Configuration__c pcClone = pc.clone(false, true, false, false);
          pcClone.cscfga__Product_Basket__c = basket.id;
          pcClone.cscfga__originating_offer__c = pc.cscfga__configuration_offer__c;
          pcClone.Offer_Reference__c = pc.cscfga__configuration_offer__c;
          pcClone.cscfga__configuration_offer__c = null;
          pcClone.cscfga__Key__c = '';
          pcClone.cscfga__package_slot__c = null;
          pcClone.cscfga__Parent_Configuration__c = null;
          pcClone.cscfga__Root_Configuration__c = null;
          pcClone.OwnerId = UserInfo.getUserId();
          pcClone.type__c = 'Transition';
          if (pc.Name.contains('-')) {
            String name = pc.Name.split('-')[0];
            pcClone.cscfga__Description__c = name + '-' + site.Id;

          } else {
            pcClone.cscfga__Description__c = pc.Name + '-' + site.Id;
          }

          pcList.add(pcClone);
          pcToBeCloneIdMap.put(pc.Id + '-' + site.Id, pcClone.cscfga__Description__c);
        }
      }
      system.debug('*****nameValueMap' + nameValueMap);
      //create voice number related product - EDGE-3369
      if (serList != null && serList.size() > 0 && prodDef != null) {
        if (!nameValueMap.isEmpty()) {
          for (csord__Service__c ser : serList) {
            for (integer i = 0; i < nameValueMap.size(); i++) {
              if (nameValueMap.containsKey(ser.Primary_FNN__c + '-' + i)) {
                cscfga__Product_Configuration__c pcVoiceNumber = new cscfga__Product_Configuration__c();
                pcVoiceNumber.name = 'Voice FNN Details';
                pcVoiceNumber.cscfga__Product_Basket__c = basket.id;
                pcVoiceNumber.cscfga__Description__c = ser.Primary_FNN__c + '-' + i + '@' + ser.csord__subscription__r.site__c;
                pcVoiceNumber.cscfga__Configuration_Status__c = 'Valid';
                pcVoiceNumber.cscfga__Product_Definition__c = prodDef.Id;
                pcVoiceNumber.OwnerId = UserInfo.getUserId();
                pcVoiceNumber.type__c = 'Transition';
                pcList.add(pcVoiceNumber);
              }
            }
          }
        }
      }
      insert pcList;

      List<cscfga__Product_Configuration__c> configList = [
            Select id,
            cscfga__Description__c,
            name,
            cscfga__package_slot__c,
            cscfga__Parent_Configuration__c,
            cscfga__root_Configuration__c, csoe__Commercial_Configuration__c
            from cscfga__Product_Configuration__c
            where id in: pcList
          ];

      List<cscfga__Product_Configuration__c> pcUpdateList = new List<cscfga__Product_Configuration__c>();
      Map<String, Id> pcCloneIdMap = new Map<String, Id>();

      for (cscfga__Product_Configuration__c pconfigClone : configList) {
        pcCloneIdMap.put(pconfigClone.cscfga__Description__c, pconfigClone.Id);
      }
      for (cscrm__Site__c site : siteAddressMap.values()) {
        for (cscfga__Product_Configuration__c pconfigClone : offerConfigList) {
          String siteId = site.Id;
          for (cscfga__Attribute__c attr : pconfigClone.cscfga__Attributes__r) {
            cscfga__Attribute__c attClone = attr.clone(false, true, false, false);
            attClone.cscfga__Product_Configuration__c = pcCloneIdMap.get(pcToBeCloneIdMap.get(pconfigClone.Id + '-' + siteId));
            attClone.cscfga__Key__c = '';
            if (attClone.Name == 'User') {
              attClone.cscfga__Value__c = pcCloneIdMap.get('User ' + '-' + siteId);
            }
            if (attClone.Name == 'Managed Device') {
              attClone.cscfga__Value__c = pcCloneIdMap.get('Managed Router' + '-' + siteId);
              System.debug(attClone.cscfga__Value__c);
            }
            if (attClone.Name == 'Quantity' && pConfigClone.Name.contains('User') && siteServiceCountMap != null && siteServiceCountMap.containsKey(Id.ValueOf(siteId))) {
              attClone.cscfga__Value__c = '' + siteServiceCountMap.get(Id.valueOf(siteId));
            } else if (attClone.Name == 'ZoneSelected' && pConfigClone.Name.contains('User') && siteIdZoneTypeMap != null && siteIdZoneTypeMap.containsKey(siteId + '-Zone')) {
              attClone.cscfga__Value__c = siteIdZoneTypeMap.get(siteId + '-Zone');
            } else if (attClone.Name == 'TypeSelectedUser' && pConfigClone.Name.contains('User') && siteIdZoneTypeMap != null && siteIdZoneTypeMap.containsKey(siteId + '-Type')) {
              attClone.cscfga__Value__c = siteIdZoneTypeMap.get(siteId + '-Type');
            } else if (attClone.Name.contains('SiteId')) {
              attClone.cscfga__Value__c = siteId;
            } else if (attClone.Name.contains('Site ID')) {
              attClone.cscfga__Value__c = siteId;
            } else if (attClone.Name.contains('Site Name')) {
              attClone.cscfga__Value__c = site.Name;
            } else if (attClone.Name.contains('Site Address')) {
              attClone.cscfga__Value__c = site.cscrm__Installation_Address__r.Name;
            }

            else if (attClone.Name.contains('AdborID')) {
              attClone.cscfga__Value__c = site.address_id__c;
            } else if (attClone.Name.contains('AccountId')) {
              attClone.cscfga__Value__c = site.cscrm__Account__c;
            } else if (attClone.Name.contains('IP Site')) {
              attClone.cscfga__Value__c = pcCloneIdMap.get('IP Site' + '-' + siteId);
            } else if (attClone.Name.contains('TOC') || attClone.Name.contains('TRC')) {
              if (Decimal.valueOf(attClone.cscfga__Value__c) > 0) {
                attClone.cscfga__Is_Line_Item__c = true;
              }
              if (attClone.cscfga__Line_Item_Description__c == null) {
                attClone.cscfga__Line_Item_Description__c = attClone.cscfga__Product_Configuration__c;
              }
            }
            if (attClone.Name == 'Zone' && attClone.cscfga__Value__c == null && defaultZone != null) {
              attClone.cscfga__Value__c = defaultZone.Id ;
            }
            if (attClone.Name == 'ZoneSelected' && attClone.cscfga__Value__c == null && defaultZone != null && defaultZone.Zone__c != null) {
              attClone.cscfga__Value__c = defaultZone.Zone__c ;
            }
            if (attClone.Name == 'TypeSelectedUser' && attClone.cscfga__Value__c == null && defaultZone != null && defaultZone.Zone__c != null) {
              attClone.cscfga__Value__c = defaultZone.type__c ;
            }
            if (attClone.Name == 'TypeUser' && attClone.cscfga__Value__c == null && defaultZone != null) {
              attClone.cscfga__Value__c = defaultZone.Id ;
            }
            //EDGE-3369
            if (attClone.Name == 'LegacySubscriptionID' && siteSubMap != null && siteSubMap.size() > 0 && siteSubMap.containsKey(siteId)) {
              attClone.cscfga__Value__c = siteSubMap.get(siteId);
            }
            attrList.add(attClone);

          }
          if (pConfigClone != null && pConfigClone.name != null && !pConfigClone.name.contains('Managed Router') && !pConfigClone.name.contains('User') && !pConfigClone.name.contains('Voice Number Details')) {
            csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
            pcr.csbb__Product_Basket__c = basket.id;
            pcr.csbb__Offer__c = pConfigClone.cscfga__configuration_offer__c;
            pcr.csbb__Product_Configuration__c = pcCloneIdMap.get(pcToBeCloneIdMap.get(pconfigClone.Id + '-' + siteId));
            pcr.csbb__total_OC__c = 0.00;
            pcr.csbb__total_MRC__c = 0.00;
            pcr.csbb__Product_Category__c = pCategory.Id;
            pcr.csbb__Status__c = 'finalized';
            pcr.OwnerId = UserInfo.getUserId();
            pcr.csbb__Optionals__c = '{"selectedAddressDisplay":" ' + siteAddressMap.get(Id.valueOf(siteId)).cscrm__Installation_Address__r.Name + '","hiddenParam1":"' + siteAddressMap.get(Id.valueOf(siteId)).address_Id__c + '"}';
            pcrList.add(pcr);
          }
        }
      }
      insert pcrList;
      insert attrList;

      Map<Id, Id> pcAttrslotLinkMap = new Map <Id, Id>();
      List<cscfga__Attribute__c> slotAttrList = [Select id, cscfga__Product_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__c in :configList and cscfga__Product_Configuration__r.Name = 'Connected Workplace' and Name = 'IP Site'];
      for (cscfga__Attribute__c attr : slotAttrList) {
        pcAttrslotLinkMap.put(attr.cscfga__Product_Configuration__c, attr.id);
      }
      for (cscfga__Product_Configuration__c pconfigClone : configList) {

        if (pconfigClone.Name.contains('User') || pconfigClone.Name.contains('Managed Router')) {
          pconfigClone.cscfga__Parent_Configuration__c = pcCloneIdMap.get('IP Site' + '-' + pconfigClone.cscfga__Description__c.split('-')[1]);
          pconfigClone.cscfga__root_Configuration__c = pcCloneIdMap.get('IP Site' + '-' + pconfigClone.cscfga__Description__c.split('-')[1]);
          pcUpdateList.add(pconfigClone);
        }

        else if (pconfigClone.Name.contains('IP Site')) {
          if (pcAttrslotLinkMap != null && pcAttrslotLinkMap.containsKey(pcCloneIdMap.get('Connected Workplace' + '-' + pconfigClone.cscfga__Description__c.split('-')[1])))
            pconfigClone.cscfga__package_slot__c = pcAttrslotLinkMap.get(pcCloneIdMap.get('Connected Workplace' + '-' + pconfigClone.cscfga__Description__c.split('-')[1]));
          pcUpdateList.add(pconfigClone);
        }
        //Link Voice Number config to parent Site - EDGE-3369
        else if (pconfigClone.Name.contains('Voice FNN Details') && prodDef != null) {
          pconfigClone.csoe__Commercial_Configuration__c = pcCloneIdMap.get('IP Site' + '-' + pconfigClone.cscfga__Description__c.split('@')[1]);
          pcUpdateList.add(pconfigClone);
          System.debug(LoggingLevel.INFO, 'TransitionProductBasketCreation.pconfigClone = ' + pconfigClone);
          System.debug(LoggingLevel.INFO, 'TransitionProductBasketCreation.voiceAttrDefList = ' + voiceAttrDefList);
          System.debug(LoggingLevel.INFO, 'TransitionProductBasketCreation.nameValueMap = ' + nameValueMap);
          System.debug(LoggingLevel.INFO, 'TransitionProductBasketCreation.pconfigClone.csoe__Commercial_Configuration__c = ' + pconfigClone.csoe__Commercial_Configuration__c);
          createVoiceNumberAttributes(pconfigClone, voiceAttrDefList, nameValueMap, pconfigClone.csoe__Commercial_Configuration__c);
        }
      }

      update pcUpdateList;

      List<cscfga__Product_Configuration__c> IPVPNPcFromBasket = [Select id, Name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id = :basket.Id and cscfga__Product_Definition__r.name = : Label.IP_Network];
      if (IPVPNPcFromBasket.size() >= 2) {
        IPVPNPcFromBasket.remove(0);
        delete IPVPNPcFromBasket;
      }

      List<cscfga__Product_Configuration__c> UPCFromBasket = [Select id, Name from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.id = :basket.Id and cscfga__Product_Definition__r.name = : System.Label.UC_Enterprise];
      if (UPCFromBasket.size() >= 2) {
        UPCFromBasket.remove(0);
        delete UPCFromBasket;
      }
    }
    return basket;
  }

  public static String getSobjectFields(String so) {
    String fieldString;
    SObjectType sot = Schema.getGlobalDescribe().get(so);
    List <Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();
    fieldString = fields[0].getDescribe().LocalName;
    for (Integer i = 1; i < fields.size(); i++) {
      fieldString += ',' + fields[i].getDescribe().LocalName;
    }
    return fieldString;
  }

  private static void createVoiceNumberAttributes(cscfga__Product_Configuration__c config, List<cscfga__Attribute_Definition__c> voiceAttrDefList, Map<String, String> nameValueMap, Id configurationId) {
    List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
    system.debug('nameValueMap' + nameValueMap);

    for (cscfga__Attribute_Definition__c attrDef : voiceAttrDefList) {
      cscfga__Attribute__c attr = new cscfga__Attribute__c();
      attr.cscfga__Attribute_Definition__c = attrDef.id;
      attr.Name = attrDef.Name;
      attr.cscfga__Product_Configuration__c = config.id;
      attr.cscfga__is_active__c = true;
      if (attr.Name == 'Migrated') {
        attr.cscfga__Value__c = 'Yes';
      }
      if (attr.Name == 'Legacy Offer Name') {
        attr.cscfga__Value__c = 'ISDN-BRA';
      }
      if (attr.Name == 'Configuration Id') {
        attr.cscfga__Value__c = configurationId;
      }

      
      if (!nameValueMap.isEmpty()) {
        if (nameValueMap.containsKey((config.cscfga__Description__c.split('@'))[0])) {
          if (attr.name == 'FromFNN') {
            attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[0];
          } else if (attr.name == 'ToFNN') {
            attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[1];
          } else if (attr.Name == 'Product Specification') {
            attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[1].split('-')[1];
          }
        }
      }
      attrList.add(attr);
    }

    insert attrList;
  }
}