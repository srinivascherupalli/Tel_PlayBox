public with sharing class TransitionProductBasketUpdate {
    
    //static map
    public static Map<String,String> nameValueMap = new Map<String,String>();
    // consumes service DTO object and list of offers selected 
    public static PageReference createTransitionBasket(ReplicatorGetServiceDataObject getServiceDTO, String basketID) {
        nameValueMap = TransitionLegacySubscriptionCreation.createLegacySubscriptionAndServices(getServiceDTO);
        List<ReplicatorGetServiceDataObject.SiteDTO> getSiteDTO = getServiceDTO.Site;
        Set<String> adborSet = new Set<String>();
        for(ReplicatorGetServiceDataObject.SiteDTO site: getSiteDTO)   
        {
            adborSet.add(site.ADBOR_Id);
        }
        String CIDN = getServiceDTO.CIDN;
        List<cscrm__Site__c> siteList = new List<cscrm__Site__c>([SELECT Id, Name,display_name__c,cscrm__Installation_Address__r.cscrm__Address_Details__c,address_id__c,cscrm__Account__c,cscrm__Installation_Address__r.Name 
                                                                  FROM cscrm__Site__c 
                                                                  WHERE cscrm__Account__r.CIDN__C=:CIDN and address_id__c in: adborSet]);
        Map<Id,String> siteAddressMap = new Map<Id,String>();
        Map<String,Id> adborSiteMap = new Map <String,Id>();
        if(siteList!=null && siteList.size()>0)
        {
            for(cscrm__Site__c site: siteList)
            {
                siteAddressMap.put(site.id,site.address_id__c);
                adborSiteMap.put(site.address_id__c,site.id);
            }
        }
        createVoiceFNNDetails(siteAddressMap,basketID, adborSiteMap);
        return new PageReference('/'+Id.valueOf(basketId));                   
    }
    public static PageReference createTransitionBasket_V2(ReplicatorGetServiceDataObject_V2 getServiceDTO, String basketID) {
        nameValueMap = TransitionLegacySubscriptionCreation.createLegacySubscriptionAndServices_V2(getServiceDTO);
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> getSiteDTO = getServiceDTO.Site;
        Set<String> adborSet = new Set<String>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site: getSiteDTO)   
        {
            adborSet.add(site.ADBOR_Id);
        }
        String CIDN = getServiceDTO.CIDN;
        List<cscrm__Site__c> siteList = new List<cscrm__Site__c>([SELECT Id, Name,display_name__c,cscrm__Installation_Address__r.cscrm__Address_Details__c,address_id__c,cscrm__Account__c,cscrm__Installation_Address__r.Name 
                                                                  FROM cscrm__Site__c 
                                                                  WHERE cscrm__Account__r.CIDN__C=:CIDN and address_id__c in: adborSet]);
        Map<Id,String> siteAddressMap = new Map<Id,String>();
        Map<String,Id> adborSiteMap = new Map <String,Id>();
        if(siteList!=null && siteList.size()>0)
        {
            for(cscrm__Site__c site: siteList)
            {
                siteAddressMap.put(site.id,site.address_id__c);
                adborSiteMap.put(site.address_id__c,site.id);
            }
        }
        createVoiceFNNDetails(siteAddressMap,basketID, adborSiteMap);
        return new PageReference('/'+Id.valueOf(basketId));                   
    }
    public static void createVoiceFNNDetails(Map<Id,String> siteAddressMap, String basketID, Map<String,Id> adborSiteMap)
    {
        //query legacy subscription created
        List<csord__Subscription__c> subList = [Select id,Site__c from csord__Subscription__c where name Like 'Legacy%' and Site__c in: siteAddressMap.keySet() ORDER BY CREATEDDATE ASC];
        Map<Id,Id> siteSubMap = new Map<Id,Id>();
        for(csord__Subscription__c sub:subList)
        {
            siteSubMap.put(sub.site__c,sub.id);
        }
        //Query Legacy services
        List<csord__Service__c> serList = [Select id,Primary_FNN__c,csord__subscription__c,csord__subscription__r.site__c from csord__Service__c where name Like 'Legacy%' AND csord__Subscription__c in:siteSubMap.Values()];   
        List<cscfga__Product_Definition__c> prodDefList = [Select id from cscfga__Product_Definition__c where Name = 'Voice FNN Details'];
        List<cscfga__Attribute_Definition__c> voiceAttrDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Product_Definition__c prodDef;
        if(!prodDefList.isEmpty())
        {
            prodDef = prodDefList[0];
            voiceAttrDefList = [Select id,Name from cscfga__Attribute_Definition__c where cscfga__Product_Definition__c=:prodDef.Id];
            
        }
        
        Set<String> attName = new Set<String>{'AdborID','LegacySubscriptionID'};
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();  
        List<cscfga__Product_Configuration__c> configList = [Select id,cscfga__Description__c,csoe__Commercial_Configuration__c , (Select id, name,cscfga__Value__c from cscfga__Attributes__r where name in: attName ORDER BY NAME ASC)from cscfga__Product_Configuration__c where name = 'IP Site' and cscfga__product_basket__c=:basketID];
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        Map<String,Id> pcAddressMap = new Map<String,Id>();
        for(cscfga__Product_Configuration__c pconfigClone: configList)
        {
           String adborId = '';
           if(!pconfigClone.cscfga__Attributes__r.isEmpty())
           {
            for(cscfga__Attribute__c att: pconfigClone.cscfga__Attributes__r)
               {
                 system.debug('****attName'+att.Name);
                 if(att.Name == 'AdborID' && att.cscfga__Value__c!=null)
                   {
                     pcAddressMap.put(att.cscfga__Value__c,pconfigClone.Id);
                     adborId = att.cscfga__Value__c;
                   }  
                 if(att.Name == 'LegacySubscriptionID'&& !siteSubMap.isEmpty() && !adborSiteMap.isEmpty() && adborSiteMap.containsKey(adborId) && siteSubMap.containsKey(adborSiteMap.get(adborId)))
                   {
                        att.cscfga__Value__c = siteSubMap.get(adborSiteMap.get(adborId));
                        attrList.add(att);
                   }
                    
               }  
            }                  
        }
        update attrList;
        if(serList !=null && serList.size()>0 && prodDef !=null)
        {
            if(!nameValueMap.isEmpty())
            {
                for(csord__Service__c ser: serList)
                {
                    for(integer i=0;i<nameValueMap.size();i++)
                    {
                        if(nameValueMap.containsKey(ser.Primary_FNN__c+'-'+i))
                        {
                            cscfga__Product_Configuration__c pcVoiceNumber = new cscfga__Product_Configuration__c();
                            pcVoiceNumber.name = 'Voice FNN Details';
                            pcVoiceNumber.cscfga__Product_Basket__c = basketID;
                            pcVoiceNumber.cscfga__Description__c = ser.Primary_FNN__c+'-'+i+'@'+ser.csord__subscription__r.site__c;
                            pcVoiceNumber.cscfga__Configuration_Status__c = 'Valid';
                            pcVoiceNumber.cscfga__Product_Definition__c = prodDef.Id;
                            pcVoiceNumber.OwnerId = UserInfo.getUserId();
                            pcVoiceNumber.type__c = 'Transition';
                            if(!pcAddressMap.isEmpty() && pcAddressMap.containsKey(siteAddressMap.get(ser.csord__subscription__r.site__c)))
                            {
                             pcVoiceNumber.csoe__Commercial_Configuration__c = pcAddressMap.get(siteAddressMap.get(ser.csord__subscription__r.site__c));
                            }
                            pcList.add(pcVoiceNumber);
                        }
                    }
                }
            }
        }
        insert pcList;
        for(cscfga__Product_Configuration__c con:pcList)
        {
          createVoiceNumberAttributes(con,voiceAttrDefList,nameValueMap,con.csoe__Commercial_Configuration__c );
        }
        
    }
    private static void createVoiceNumberAttributes(cscfga__Product_Configuration__c config, List<cscfga__Attribute_Definition__c> voiceAttrDefList, Map<String,String> nameValueMap, Id configurationId)
    {
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        system.debug('nameValueMap'+nameValueMap);
        
        for(cscfga__Attribute_Definition__c attrDef : voiceAttrDefList)
        {
            cscfga__Attribute__c attr = new cscfga__Attribute__c();
            attr.cscfga__Attribute_Definition__c = attrDef.id;
            attr.Name = attrDef.Name;    
            attr.cscfga__Product_Configuration__c = config.id;
            attr.cscfga__is_active__c =true;
            if (attr.Name == 'Migrated')
            {
                attr.cscfga__Value__c = 'Yes';
            }
            if (attr.Name == 'Legacy Offer Name')
            {
                attr.cscfga__Value__c = 'ISDN-BRA';
            }
            if (attr.Name == 'Configuration Id')
            {
                attr.cscfga__Value__c = configurationId;
            }
            if(!nameValueMap.isEmpty())
            {    
                if(nameValueMap.containsKey((config.cscfga__Description__c.split('@'))[0]))
                {
                    if(attr.name == 'FromFNN')
                    {
                        attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[0];
                    }
                    else if(attr.name == 'ToFNN')
                    {
                        attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[1];
                    }
                    else if (attr.Name == 'Product Specification')
                    {
                        attr.cscfga__Value__c = nameValueMap.get((config.cscfga__Description__c.split('@'))[0]).split('-')[1].split('-')[1];
                    }                           
                }
            } 
            attrList.add(attr);
        } 
        insert attrList; 
    } 
}