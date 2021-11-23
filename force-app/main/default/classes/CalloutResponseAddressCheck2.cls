global with sharing class CalloutResponseAddressCheck2 extends csbb.CalloutResponseManagerExt {
    global CalloutResponseAddressCheck2 (Map<String, csbb.CalloutResponse> mapCR, csbb.ProductCategory productCategory, csbb.CalloutProduct.ProductResponse productResponse) {
        this.setData(mapCR, productCategory, productResponse);
    }
    
    public CalloutResponseAddressCheck2() {}

    global void setData(Map<String, csbb.CalloutResponse> mapCR, csbb.ProductCategory productCategory, csbb.CalloutProduct.ProductResponse productResponse) {
        return;
    }
    /*Method to process the response from external AddressCheck callout
    */
    global Map<String, Object> processResponseRaw (Map<String, Object> inputMap) {
        System.debug('CalloutResponseAddressCheck2 <><><>'+inputMap);
        //Manoj Kumar : EDGE-75180 : Toggle on DTO Class
        String Enable_GetSiteReplicatorV2 = EnvironmentVariable__c.getValues('Enable_GetSiteReplicatorV2').Value__c;
        
        ReplicatorGetSiteDataObject getSiteDTO = new ReplicatorGetSiteDataObject();
        ReplicatorGetSiteDataObject_V2 getSiteDTO_V2 = new ReplicatorGetSiteDataObject_V2();
        
        List<Map<String, Object>> siteRecordList2 = new List<Map<String, Object>>();
        Set<cscrm__Site__c> siteSet;
        Boolean checkFlag = false;
        //CHECK IF THE RESPONSE HAS SOME VALUE
        for(String key : inputMap.keyset()){
           
            if(key == 'addressResponseRaw'){
                
                checkFlag=true;
            }
        }
        if(checkFlag){
            try{
                JSONParser parser = JSON.createParser(inputMap.get('addressResponseRaw').toString());
                system.debug('Parser'+ parser);
                while (parser.nextToken() != null) {
                    system.debug('nextToken'+ parser.nextToken());
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'response')) {
                        parser.nextToken();
                        //PARSE THE RESPONSE TO REPLICATOR GET SITE DTO
                        //Manoj Kumar : EDGE-75180 : Toggle on DTO Class
                        if(Enable_GetSiteReplicatorV2.equalsIgnoreCase('True'))
                         getSiteDTO_V2 = (ReplicatorGetSiteDataObject_V2)parser.readValueAs(ReplicatorGetSiteDataObject_V2.class);
                        else
                        getSiteDTO = (ReplicatorGetSiteDataObject)parser.readValueAs(ReplicatorGetSiteDataObject.class);
                        
                        system.debug('CalloutResponseAddressCheck2 getSiteDTO ' + getSiteDTO_V2);
                        break;
                    }
                }
            }
            catch(Exception e){
                system.debug('Exception in parsing GetSiteDTO ' + e);
            }
        }
        system.debug('CalloutResponseAddressCheck2 BASKETID ' + this.basketId);
        //Manoj Kumar : EDGE-75180 : Toggle on DTO Class
        if(Enable_GetSiteReplicatorV2.equalsIgnoreCase('True')){
            system.debug('line59'+getSiteDTO_V2.CIDN);
            //if(getSiteDTO_V2.CIDN!=null){
          siteRecordList2 = getSiteFromReplicatorResponseV2(getSiteDTO_V2,this.basketId);
            //}
        }
        else{
             if(getSiteDTO.CIDN!=null){
            //GET THE RESPONSE PROCESSED AND FORMATTED INTO A LIST OF MAP TO BE RETURNED
            siteRecordList2 = getSiteFromReplicatorResponse(getSiteDTO,this.basketId);
        }
        }
        
       
        //GET ALL SITES FROM ACCOUNT THAT DO NOT HAVE SUBSCRIPTIONS CREATED
        siteSet = getSiteMinusSubs(this.basketId);
        //GET ALL UNIQUE REPLICATOR SITES BY REMOVING ACCOUNT SITES
        List<Map<String, Object>> uniqueReplicatorSiteList = markDuplicateReplicatorSites(''+this.basketId,siteRecordList2);
        //GET UNIQUE LIST OF SITES FROM ALL SITES AND REPLICATOR RECEIVED SITES
        List<Map<String, Object>> responseSiteRecordList = getUniqueSiteResponse(siteSet,uniqueReplicatorSiteList);
        system.debug('CalloutResponseAddressCheck2 responseSiteRecordList ' + responseSiteRecordList);
        //SERIALIZE THE LIST OF MAP OF SITES
        String str2 = JSON.serialize(responseSiteRecordList);
        system.debug('CalloutResponseAddressCheck2 Serialized response : ' + str2);
        Map<String, Object> siteMap2 = new Map<String, Object>();
        siteMap2.put('addressResponseProcessed',str2);
        siteMap2.put('addressResponseStatus','success');
        system.debug('siteMap2'+siteMap2);
        return siteMap2;
       
       // return null;
        //BELOW CODE IS ONLY TO BE USED IN DIRE SITUATION WHEN ADDRESS CHECK CALLOUTS ARE FAILING AND WANT TO PROCEED WITH DUMMY SITES
        /*ALSO ENSURE TO COMMENT ABOVE RETURN STATEMENT IF UNCOMMENTING BELOW CODE
        List<Map<String, Object>> siteRecordList = new List<Map<String, Object>>();
        Map<String, string> siteMap = new Map<String, string>();
        siteMap.put('name','Site Name1');
        siteMap.put('cscrm__installation_address_details__c','Site Address1');
        siteMap2.put('id','abc');
        
        siteRecordList.add(siteMap);
        Map<String, string> siteMap3 = new Map<String, string>();
        siteMap3.put('name','Site Name2');
        siteMap3.put('cscrm__installation_address_details__c','Site Address2');
        siteMap3.put('id','xyx');
        
        siteRecordList.add(siteMap3);
        String str= JSON.serialize(siteRecordList);
        Map<String, Object> siteMapDummyReturn = new Map<String, Object>();
        siteMapDummyReturn.put('addressResponseProcessed',str);
        siteMapDummyReturn.put('addressResponseStatus','success');
        return siteMapDummyReturn;        
        */
        
    }

    global Map<String, Object> getDynamicRequestParameters (Map<String, Object> inputMap) {
        String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        String regExp = '[-:\\s]';
        String replacement = '';
        String uniqueString = hashString.replaceAll(regExp, replacement);
        
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(uniqueString));
        String hexDigest = EncodingUtil.convertToHex(hash).subString(0, 18);
        System.debug('Generated Unique Key: ' + hexDigest);
        inputmap.put('CORRELATIONID',hexDigest);
      //  inputmap.put('DUMMY',''); //AB setting dummy param just to be able to use GET callout with no params in order to use original endpoint
        return inputMap;
    }

    global void runBusinessRules (String categoryIndicator) {
        return;
    }
    
    global csbb.Result canOffer (Map<String, String> attMap, Map<String, String> responseFields, csbb.CalloutProduct.ProductResponse productResponse) {
        csbb.Result canOfferResult = new csbb.Result();
        canOfferResult.status = 'OK';
        return canOfferResult;
    }
    
    global Set<cscrm__Site__c> getSiteMinusSubs(String basketId){
        try{
            //Set<cscrm__Site__c> set1 = new Set<cscrm__Site__c>();
            Set<cscrm__Site__c> setList1 = new Set<cscrm__Site__c>();
            Set<cscrm__Site__c> setList2 = new Set<cscrm__Site__c>();
            List<String> adborIDList = new List<String>();
            String json= '';
            String connectedWorkLabel = System.Label.Label_CWP;
            Map<Id, cscrm__Site__c> siteMap2= new Map<Id, cscrm__Site__c>();
            
            List<csbb__Product_Configuration_Request__c> pcrList = [SELECT id, Name, csbb__Optionals__c FROM csbb__Product_Configuration_Request__c Where csbb__Product_Basket__c =:basketId AND Product_Configuration_Name__c =: connectedWorkLabel];
            for(csbb__Product_Configuration_Request__c pcr: pcrList){
                if(pcr.csbb__Optionals__c != null){
                    if(json == ''){json = pcr.csbb__Optionals__c ;}
                    else{json = json + ',' +pcr.csbb__Optionals__c ;}
                }
            }
            json = '['+json+']';
            //PARSE THE OPTIONALS FROM PCR AND FETCH ADBORID
            List<Optionals> optionalLs = (List<Optionals>)System.JSON.deserialize(json, List<Optionals>.class);
            for(Optionals op: optionalLs){
                if(op.hiddenParam1 != null){
                    adborIDList.add(op.hiddenParam1);
                }
            }
            System.debug('CalloutResponseAddressCheck2 - adborIDList<><>'+adborIDList);
            
            String accid ='';
            List<cscfga__Product_Basket__c> basketList = [select id,name,Account_Id__c from cscfga__Product_Basket__c where id =:basketId];
            if(basketList!=null && basketList[0].Account_Id__c != null){
                  accid =  basketList[0].Account_Id__c;    
            }
            //QUERY TO FETCH ALL SITES FOR THE ACCOUNT EXCEPT THE ONES ALREADY ADDED IN THE CURRENT BASKET
            String queryallsites = 'select Id, Name, cscrm__Installation_Address_Details__c,Legacy__c,display_name__c,cscrm__Account__c,cscrm__Floor__c,Primary_Contact_Name__c,Status__c,cscrm__Installation_Address__c,cscrm__Account__r.CIDN__c ,Site_Nick_Name__c,cscrm__Installation_Address__r.cscrm__State_Province__c,AdborID__c,cscrm__Installation_Address__r.Locality__c ,cscrm__Installation_Address__r.cscrm__Street_Name__c,cscrm__Installation_Address__r.Sub_Address_4_Number__c ,cscrm__Installation_Address__r.Sub_Address_3_Type__c ,cscrm__Installation_Address__r.Sub_Address_3_Number__c ,cscrm__Installation_Address__r.Sub_Address1_Type__c,cscrm__Installation_Address__r.Sub_Address1_Number__c ,cscrm__Installation_Address__r.Sub_Address2_Type__c ,cscrm__Installation_Address__r.Sub_Address2_Number__c ,cscrm__Installation_Address__r.streetNumberEndSuffix__c ,cscrm__Installation_Address__r.streetNumberStartSuffix__c ,cscrm__Installation_Address__r.cscrm__Street_Type__c ,cscrm__Installation_Address__r.Street_Number_From_calc__c ,Composite_Key__c ,Site_Migration_Flag__c ,Service_Class__c ,Order_Stability_Date__c ,Site_Composition__c ,Disconnect_wave__c ,Servicability__c ,In_Flight_Order__c ,Disconnection_Date__c ,cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c ,cscrm__Installation_Address__r.Sub_Address_4_Type__c ,cscrm__Installation_Address__r.Street_Number_To__c from cscrm__Site__c where cscrm__Account__c = \'' + accid +'\'' +'AND cscrm__Installation_Address__r.Address_ID__c NOT IN';
            queryallsites+=':adborIDList';
            List<cscrm__Site__c> allsites = Database.query(queryallsites);
            
            for(cscrm__Site__c site:allsites){
                system.debug('CalloutResponseAddressCheck2 - Account Sites ' +site.name);
                siteMap2.put(site.id,site);
            }
            //FETCH ALL SITES THAT ARE ALREADY HAVING SUBSCRIPTIONS FOT THE ACCOUNT
            List<cscrm__Site__c>  siteWithSubList2 = new List<cscrm__Site__c>();
            for(csord__Subscription__c sub:[SELECT id, Site__c FROM csord__Subscription__c WHERE Name=: connectedWorkLabel AND Site__c IN:allsites]){
                if(sub.Site__c != null){
                    siteWithSubList2.add(siteMap2.get(sub.Site__c));
                }
            }
            //REMOVE THE SITES ALREADY HAVING SUBSCRIPTIONS 
            setList1 = new Set<cscrm__Site__c>(allsites);
            setList2 = new Set<cscrm__Site__c>(siteWithSubList2);
            for(cscrm__Site__c siteEle : setList2)
            {
                if(setList1.contains(siteEle)){
                    setList1.remove(siteEle);
                }
            }
            return setList1;
        }catch(Exception e){
            return null;
        }
    }
    
    //METHOD TO TRANSFORM THE REPLICATOR DTO TO A LIST OF MAP OF SITES THAT IS THE DESIRED RETURN TYPE
    public List<Map<String, Object>> getSiteFromReplicatorResponse(ReplicatorGetSiteDataObject getSiteDTO, String basketId){
        try{
            List<Map<String, Object>> siteRecordList = new List<Map<String, Object>>();
            //BELOW CODE OF FETCHING SITE NAME FROM NICKNAME HAS BEEN USED FROM ADDRESSANDSITEUTILITYOBJECT CLASS
            List<ReplicatorGetSiteDataObject.SiteDTO> siteList = getSiteDTO.Site;
            List<cscfga__Product_Basket__c> basketList = [select id,name,Account_Id__c from cscfga__Product_Basket__c where id =:basketId];
            for(ReplicatorGetSiteDataObject.SiteDTO site : siteList){
                Map<String, Object> siteMap = new Map<String, Object>();
                if(site.Site_Nick_Name==null || site.Site_Nick_Name==''){
                    if((site.Street_Name.length() + site.Street_Type.length() + site.State.length())<80){
                        site.Site_Nick_Name=site.Street_Name + ' ' +site.Street_Type + ' ' + site.State;
                    }else{
                        site.Site_Nick_Name=(site.Street_Name +' ' + site.Street_Type +' ' + site.State).subString(0,80);
                    }
              }
                siteMap.put('name',site.Site_Nick_Name); 
                String installationAddressDetails = site.Street_Name + ' ' + site.State + ' ' + site.Loc_Name + ' ' + site.ADBoR_Postcode;
                siteMap.put('cscrm__installation_address_details__c',installationAddressDetails);
                siteMap.put('display_name__c',installationAddressDetails);
                if(basketList!=null && basketList[0].Account_Id__c != null){
                  sitemap.put('cscrm__account__c', basketlist[0].account_id__c);    
                }
                sitemap.put('cscrm__installation_address__c',installationaddressdetails); 
                sitemap.put('display_name__c',installationaddressdetails); 
                //this key 'id' in the map is important to identify each record as unique in the ui by cloudsense managed package 
                sitemap.put('id',site.adbor_id);
                sitemap.put('legacysite','Yes');
                sitemap.put('adborid__c',site.adbor_id);
                sitemap.put('legacy__c','true');
                sitemap.put('address_id__c',site.adbor_id); 
                sitemap.put('cscrm__floor__c',installationaddressdetails);
                sitemap.put('status__c',site.site_address_status);
                /////added for edge 30013 stsrt
                sitemap.put('disconnection_date__c', site.disconnection_date);
                sitemap.put('in_flight_order__c', site.in_flight_order);
                sitemap.put('servicability__c', site.serviceability);
                sitemap.put('disconnect_wave__c', site.disconnect_wave);
                sitemap.put('site_composition__c', site.site_composition);
                sitemap.put('order_stability_date__c', site.order_stability_date);
                sitemap.put('service_class__c', site.service_class);
                sitemap.put('site_migration_flag__c',site.site_migration_flag);
                sitemap.put('composite_key__c',getsitedto.cidn+site.adbor_id);
                sitemap.put('street_number_to__c',site.address_no_to);
                sitemap.put('street_number_to__c',site.address_no_to); 
                sitemap.put('street_number_from_calc__c',site.address_no_from); 
                sitemap.put('cscrm__street_type__c',site.street_type); 
                sitemap.put('streetnumberstartsuffix__c',site.suffix_from); 
                sitemap.put('streetnumberendsuffix__c',site.suffix_to); 
                sitemap.put('sub_address2_number__c',site.sub2_descriptor_1); 
                sitemap.put('sub_address2_type__c',site.sub2_codeset_abbrev); 
                sitemap.put('sub_address1_number__c',site.sub1_descriptor_1); 
                sitemap.put('sub_address1_type__c',site.sub1_codeset_abbrev); 
                sitemap.put('sub_address_3_number__c',site.sub3_descriptor_1); 
                sitemap.put('sub_address_3_type__c',site.sub3_codeset_abbrev); 
                sitemap.put('sub_address_4_number__c',site.sub4_descriptor_1); 
                sitemap.put('sub_address_4_type__c',site.sub4_codeset_abbrev); 
                sitemap.put('cscrm__street_name__c', site.street_name); 
                sitemap.put('locality__c', site.loc_name); 
                sitemap.put('cscrm__state_province__c', site.state); 
                sitemap.put('cscrm__zip_postal_code__c', site.adbor_postcode);
                //////////////end
                siteMap.put('isDuplicate','false');
                siteRecordList.add(siteMap);
            }
            return siteRecordList;
        }catch(Exception e){
            return null;
        }
    }
    
    //EDGE-75180 : METHOD TO CONVERT SITE-JSON INTO A SITE-MAP - for v2-API of Replicator
    public List<Map<String, String>> buildSiteMap(ReplicatorGetSiteDataObject_V2 getSiteDTO_V2){
        List<Map<String, String>> listOfSites = new List<Map<String, String>>();
        for(ReplicatorGetSiteDataObject_V2.addressListDTO address:getSiteDTO_V2.addressList){
            Map<String,String> addressFromReplicator = new Map<String,String>();
            addressFromReplicator.put('addressType',address.addressType);
            addressFromReplicator.put('addressValue',address.addressValue);
            addressFromReplicator.put('replicatorUpdateDateTime',address.replicatorUpdateDateTime);
            for(ReplicatorGetSiteDataObject_V2.addressCharacteristicsDTO characteristic:address.addressCharacteristics){
                addressFromReplicator.put(characteristic.name,characteristic.value);
            }
            listOfSites.add(addressFromReplicator);
        }
        system.debug('***Telstra:CalloutResponseAddressCheck2:getSiteFromReplicatorResponseV2:listOfSites'+listOfSites);
        return listOfSites;
    }
    
     //EDGE-75180 : METHOD TO TRANSFORM THE REPLICATOR DTO TO A LIST OF MAP OF SITES - for v2-API of Replicator
    public List<Map<String, Object>> getSiteFromReplicatorResponseV2(ReplicatorGetSiteDataObject_V2 getSiteDTO_V2, String basketId){
        try{
            List<Map<String, Object>> siteRecordList = new List<Map<String, Object>>();            
            //BELOW CODE OF FETCHING SITE NAME FROM NICKNAME HAS BEEN USED FROM ADDRESSANDSITEUTILITYOBJECT CLASS
            List<Map<String,String>> siteList = buildSiteMap(getSiteDTO_V2);            
            List<cscfga__Product_Basket__c> basketList = [select id,name,Account_Id__c from cscfga__Product_Basket__c where id =:basketId];
            for(Map<String, Object> site : siteList ){               
                String nickname='';
                Map<String, Object> siteMap = new Map<String, Object>();
                if(site.get('Site_Nick_Name')==null || site.get('Site_Nick_Name')==''){                    
                   // if((site.get('Street_Name').length() + site.get('Street_Type').length() + site.get('State').length())<80){
                       nickname = site.get('Street_Name') + ' ' +site.get('Street_Type') + ' ' + site.get('State');
                    /*}else{
                        site.Site_Nick_Name=(site.get('Street_Name') +' ' + site.Street_Type +' ' + site.State).subString(0,80);
                    }*/
              }                
                siteMap.put('name',nickname ); 
                String installationAddressDetails = site.get('Street_Name') + ' ' + site.get('State') + ' ' + site.get('Locality_Name') + ' ' + site.get('Postcode');
                siteMap.put('cscrm__installation_address_details__c',installationAddressDetails);
                siteMap.put('display_name__c',installationAddressDetails);
                if(basketList!=null && basketList[0].Account_Id__c != null){
                  sitemap.put('cscrm__account__c', basketlist[0].account_id__c);    
                }                
                sitemap.put('cscrm__installation_address__c',installationaddressdetails); 
                sitemap.put('display_name__c',installationaddressdetails); 
                //this key 'id' in the map is important to identify each record as unique in the ui by cloudsense managed package 
                sitemap.put('id',site.get('addressValue'));
                sitemap.put('legacysite','Yes');
                sitemap.put('adborid__c',site.get('addressValue'));
                sitemap.put('legacy__c','true');
                sitemap.put('address_id__c',site.get('addressValue')); 
                sitemap.put('cscrm__floor__c',installationaddressdetails);
                //sitemap.put('status__c',site.site_address_status);
                /////added for edge 30013 stsrt
                sitemap.put('disconnection_date__c', site.get('disconnection_date'));        
                sitemap.put('in_flight_order__c', site.get('in_flight_order'));
                sitemap.put('servicability__c', site.get('serviceability'));
                sitemap.put('disconnect_wave__c', site.get('disconnect_wave'));
                sitemap.put('site_composition__c', site.get('site_composition'));
                sitemap.put('order_stability_date__c', site.get('order_stability_date'));                
                sitemap.put('service_class__c', site.get('service_class'));
                sitemap.put('site_migration_flag__c',site.get('site_migration_flag'));
                sitemap.put('composite_key__c',getSiteDTO_V2.cidn+site.get('addressValue'));
                sitemap.put('street_number_to__c',site.get('Address_No_To'));
                //sitemap.put('street_number_to__c',site.address_no_to); 
                sitemap.put('street_number_from_calc__c',site.get('Address_No_From')); 
                sitemap.put('cscrm__street_type__c',site.get('Street_Type')); 
                sitemap.put('streetnumberstartsuffix__c',site.get('Suffix_From')); 
                sitemap.put('streetnumberendsuffix__c',site.get('Suffix_To')); 
                /*Below statements are commented as we are not getting below information from replicator-v2 
                sitemap.put('sub_address2_number__c',site.sub2_descriptor_1); 
                sitemap.put('sub_address2_type__c',site.sub2_codeset_abbrev); 
                sitemap.put('sub_address1_number__c',site.sub1_descriptor_1); 
                sitemap.put('sub_address1_type__c',site.sub1_codeset_abbrev); 
                sitemap.put('sub_address_3_number__c',site.sub3_descriptor_1); 
                sitemap.put('sub_address_3_type__c',site.sub3_codeset_abbrev); 
                sitemap.put('sub_address_4_number__c',site.sub4_descriptor_1); 
                sitemap.put('sub_address_4_type__c',site.sub4_codeset_abbrev);  */               
                sitemap.put('cscrm__street_name__c', site.get('Street_Name')); 
                sitemap.put('locality__c', site.get('Locality_Name')); 
                sitemap.put('cscrm__state_province__c', site.get('State')); 
                sitemap.put('cscrm__zip_postal_code__c', site.get('Postcode'));
                //////////////end
                siteMap.put('isDuplicate','false');
                siteRecordList.add(siteMap);
            } 
            system.debug('***Telstra:CalloutResponseAddressCheck2:getSiteFromReplicatorResponseV2:siteRecordList-'+siteRecordList);
            return siteRecordList;
        }catch(Exception e){
            system.debug('Exception'+e.getLineNumber()+e.getMessage());
            return null;
        }
    }
   
    /* EDGE - 8185 
     * To mark duplicate Sites from Replicator Response by comparing the Sites associated with the account
    */
    public List<Map<String, Object>> markDuplicateReplicatorSites (String basketId, List<Map<String, Object>> siteRecordList){
        try{
            String accId = '';
            List<cscfga__Product_Basket__c> basketList = [select id,name,Account_Id__c from cscfga__Product_Basket__c where id =:basketId];
            if(basketList!= null && basketList.size()==1){
                accId =basketList[0].Account_Id__c;             
            }
            if(accId!=null){
                List<cscrm__Site__c> siteList = [select id,AdborID__c,cscrm__Account__c from cscrm__Site__c where cscrm__Account__c =:accId];
                for(cscrm__Site__c site: siteList){
                    for(Map<String, Object> siteMap : siteRecordList){
                        for(String key : siteMap.keySet()){
                            if (key == 'adborid__c' && siteMap.get(key) != null){
                                if(site.AdborID__c == siteMap.get(key)){
                                    siteMap.put('isDuplicate','true');    
                                }
                            }
                        }
                    }    
                }    
            }
            return siteRecordList;
        }
        catch(Exception e){
            return null;
        }
    }
    
    //METHOD TO CHECK IF REPLICATOR SITE IS ALREADY PRESENT IN SALESFORCE THEN IGNORE THAT REPLICATOR SITE IN THE RESPONSE
    public List<Map<String, Object>> getUniqueSiteResponse (Set<cscrm__Site__c> siteSet,List<Map<String, Object>> siteRecordList){
        try{
            List<Map<String, Object>> returnMapList = new List<Map<String, Object>>();
            List<String> adBorIdList = new List<String>();
            //ITERATE OVER SALESFORCE SITES AND CHECK IF ADBORID OF SALESFORCE SITE MATCHES WITH THAT OF REPLICATOR SITE
            for(cscrm__Site__c site : siteSet){
                Boolean siteAdded = false;
                for(Map<String, Object> siteMap : siteRecordList){
                    for(String key : siteMap.keySet()){
                        //IF THE ADBORID MATCHES THEN ADD THE VALUE OF THAT SITE RECORD IN THE RETURN LIST
                        //INSTEAD OF REPLICATOR SITE RECORD AS WE TREAT CONSIDER THAT SALESFORCE DATA IS TRUTH OF SOURCE
                        //AND MARK THE VALUE OF LEGACY AS TRUE
                        if(key=='adborid__c' && siteMap.get(key) != null){
                            Map<String, Object> returnMap = new Map<String, Object>();
                            system.debug('siteMap'+siteMap);
                            if(site.AdborID__c == siteMap.get(key)){
                                system.debug('CalloutResponseAddressCheck2 - setLegacytrue');
                                siteAdded = true;
                                returnmap.put('name',site.name);
                                returnmap.put('site_nick_name__c',site.site_nick_name__c);
                                returnmap.put('cscrm__installation_address_details__c',site.cscrm__installation_address_details__c);
                                returnmap.put('cscrm__account__c', site.cscrm__account__c);    
                                returnmap.put('cscrm__installation_address__c',site.cscrm__installation_address__c); 
                                returnmap.put('adborid__c',site.adborid__c);
                                returnmap.put('id',site.adborid__c);
                                returnmap.put('legacy__c','true');
                                returnmap.put('legacysite','Yes');
                                returnmap.put('address_id__c',site.adborid__c); 
                                returnmap.put('cscrm__floor__c',site.cscrm__floor__c);
                                returnmap.put('primary_contact_name__c',site.primary_contact_name__c); 
                                returnmap.put('status__c',site.status__c);
                                returnmap.put('display_name__c',site.display_name__c);  
                                returnmap.put('disconnection_date__c', site.disconnection_date__c);
                                returnmap.put('in_flight_order__c', site.in_flight_order__c);
                                returnmap.put('servicability__c', site.servicability__c);
                                returnmap.put('disconnect_wave__c', site.disconnect_wave__c);
                                returnmap.put('site_composition__c', site.site_composition__c);
                                returnmap.put('order_stability_date__c', site.order_stability_date__c);
                                returnmap.put('service_class__c', site.service_class__c);
                                returnmap.put('site_migration_flag__c',site.site_migration_flag__c);
                                returnmap.put('composite_key__c',site.cscrm__account__r.cidn__c+site.adborid__c);
                                returnmap.put('street_number_to__c',site.cscrm__installation_address__r.street_number_to__c);
                                returnmap.put('street_number_from_calc__c',site.cscrm__installation_address__r.street_number_from_calc__c); 
                                returnmap.put('cscrm__street_type__c',site.cscrm__installation_address__r.cscrm__street_type__c); 
                                returnmap.put('streetnumberstartsuffix__c',site.cscrm__installation_address__r.streetnumberstartsuffix__c); 
                                returnmap.put('streetnumberendsuffix__c',site.cscrm__installation_address__r.streetnumberendsuffix__c); 
                                returnmap.put('sub_address2_number__c',site.cscrm__installation_address__r.sub_address2_number__c); 
                                returnmap.put('sub_address2_type__c',site.cscrm__installation_address__r.sub_address2_type__c); 
                                returnmap.put('sub_address1_number__c',site.cscrm__installation_address__r.sub_address1_number__c); 
                                returnmap.put('sub_address1_type__c',site.cscrm__installation_address__r.sub_address1_type__c); 
                                returnmap.put('sub_address_3_number__c',site.cscrm__installation_address__r.sub_address_3_number__c); 
                                returnmap.put('sub_address_3_type__c',site.cscrm__installation_address__r.sub_address_3_type__c); 
                                returnmap.put('sub_address_4_number__c',site.cscrm__installation_address__r.sub_address_4_number__c); 
                                returnmap.put('sub_address_4_type__c',site.cscrm__installation_address__r.sub_address_4_type__c); 
                                returnmap.put('cscrm__street_name__c', site.cscrm__installation_address__r.cscrm__street_name__c); 
                                returnmap.put('locality__c', site.cscrm__installation_address__r.locality__c); 
                                returnmap.put('cscrm__state_province__c', site.cscrm__installation_address__r.cscrm__state_province__c); 
                                returnmap.put('cscrm__zip_postal_code__c', site.cscrm__installation_address__r.cscrm__zip_postal_code__c);
                                returnMapList.add(returnMap);
                                siteMap.put('isDuplicate','true');
                                break;
                            }
                        }
                    }
                }
                //IF THE SALESFORCE SITE ADBORID DOES NOT EQUAL TO THE REPLICATOR SITE ADBORID, 
                //THEN ADD THAT SITE DETAIL IN THE RETURN LIST WITH LEGACY VALUE AS THAT IN ACTUAL VALUE
                if(!siteAdded){
                    system.debug('CalloutResponseAddressCheck2 - Flag siteAdded false');
                    Map<String, Object> returnMap = new Map<String, Object>();
                    returnmap.put('cscrm__installation_address_details__c',site.cscrm__installation_address_details__c);
                    returnmap.put('cscrm__account__c', site.cscrm__account__c);    
                    returnmap.put('cscrm__installation_address__c',site.cscrm__installation_address__c); 
                    returnmap.put('adborid__c',site.adborid__c);
                    returnmap.put('id',site.adborid__c);
                    if(site.legacy__c == true){
                    returnmap.put('legacysite','Yes');
                    }else{
                    returnmap.put('legacysite','No');
                    }
                    returnmap.put('legacy__c',''+site.legacy__c);
                    returnmap.put('address_id__c',site.adborid__c); 
                    returnmap.put('cscrm__floor__c',site.cscrm__floor__c);
                    returnmap.put('primary_contact_name__c',site.primary_contact_name__c); 
                    returnmap.put('status__c',site.status__c);
                    returnmap.put('name',site.name);
                    returnmap.put('site_nick_name__c',site.site_nick_name__c);
                    returnmap.put('display_name__c',site.display_name__c);
                    returnmap.put('disconnection_date__c', site.disconnection_date__c);
                    returnmap.put('in_flight_order__c', site.in_flight_order__c);
                    returnmap.put('servicability__c', site.servicability__c);
                    returnmap.put('disconnect_wave__c', site.disconnect_wave__c);
                    returnmap.put('site_composition__c', site.site_composition__c);
                    returnmap.put('order_stability_date__c', site.order_stability_date__c);
                    returnmap.put('service_class__c', site.service_class__c);
                    returnmap.put('site_migration_flag__c',site.site_migration_flag__c);
                    returnmap.put('composite_key__c',site.cscrm__account__r.cidn__c+site.adborid__c);
                    returnmap.put('street_number_to__c',site.cscrm__installation_address__r.street_number_to__c); 
                    returnmap.put('street_number_from_calc__c',site.cscrm__installation_address__r.street_number_from_calc__c); 
                    returnmap.put('cscrm__street_type__c',site.cscrm__installation_address__r.cscrm__street_type__c); 
                    returnmap.put('streetnumberstartsuffix__c',site.cscrm__installation_address__r.streetnumberstartsuffix__c); 
                    returnmap.put('streetnumberendsuffix__c',site.cscrm__installation_address__r.streetnumberendsuffix__c); 
                    returnmap.put('sub_address2_number__c',site.cscrm__installation_address__r.sub_address2_number__c); 
                    returnmap.put('sub_address2_type__c',site.cscrm__installation_address__r.sub_address2_type__c); 
                    returnmap.put('sub_address1_number__c',site.cscrm__installation_address__r.sub_address1_number__c); 
                    returnmap.put('sub_address1_type__c',site.cscrm__installation_address__r.sub_address1_type__c); 
                    returnmap.put('sub_address_3_number__c',site.cscrm__installation_address__r.sub_address_3_number__c); 
                    returnmap.put('sub_address_3_type__c',site.cscrm__installation_address__r.sub_address_3_type__c); 
                    returnmap.put('sub_address_4_number__c',site.cscrm__installation_address__r.sub_address_4_number__c); 
                    returnmap.put('sub_address_4_type__c',site.cscrm__installation_address__r.sub_address_4_type__c); 
                    returnmap.put('cscrm__street_name__c', site.cscrm__installation_address__r.cscrm__street_name__c); 
                    returnmap.put('locality__c', site.cscrm__installation_address__r.locality__c); 
                    returnmap.put('cscrm__state_province__c', site.cscrm__installation_address__r.cscrm__state_province__c); 
                    returnmap.put('cscrm__zip_postal_code__c', site.cscrm__installation_address__r.cscrm__zip_postal_code__c); 
                    returnMapList.add(returnMap);
                }
            }
            //ADD ALL THE REPLICATOR RECORDS IN THE RETURN LIST THAT ARE NOT DUPLICATE
            for(Map<String, Object> siteMap : siteRecordList){
                for(String key : siteMap.keySet()){
                    if(key == 'isDuplicate' && siteMap.get(key) != null && siteMap.get(key) == 'false'){
                        returnMapList.add(siteMap);
                    }
                }
            }
 // EDGE-85156 - Removing Duplicates from the return list
            Set<Map<String, Object>> returnMapSet = new Set<Map<String, Object>>();
            List<Map<String, Object>> returnMapListwoDuplicates = new List<Map<String, Object>>();
            for(Map<String, Object> m: returnMapList){
                if(returnMapSet.add(m)){
                    returnMapListwoDuplicates.add(m);
                }
            }
            system.debug('**return Map**'+returnMapListwoDuplicates);
            return returnMapListwoDuplicates;
        }catch(Exception e){
            return null;
        }
    }
    
    public class Optionals{
        public String selectedAddressDisplay;
        public String hiddenParam1;
    }
}