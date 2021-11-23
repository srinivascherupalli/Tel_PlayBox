/*

* @Author : Shubhi
* @Date : 13 Feb 2020
* @Desc : GetPriceScheduleAbstractClass  
* @Jira : EDGE-135837
* @TestClass : GetPriceScheduleAbstractClassTest
* @EDGE# : Sr no 2 -EDGE-135885 - Added Fields to the SOQL Queries
1. shubhi EDGE-133963 added method for charge id set 
2.  added for Edge-143527 not to return if same
*/
public with sharing virtual  class GetPriceSchedulevirtualClass{
    //lsit of discount level business Ids to fetch promotion metadata
    //public static List<String> DL_businessIDList{get;set;}
    
    //abstract method to override onloadmethod that gets call on laod of Vf page
   //public abstract void onLoadMethod();
    
    // fetch guid to solutionmap based on solution that is calling it
    public static Map<String,Map<String,SolutionDTO.Attributes>> getguidToAttMapofMap(String solutionID,String SolutionName){
        Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap=new Map<String,Map<String,SolutionDTO.Attributes>>();
        Attachment currentSolutionJSON=new Attachment();
        if(!String.isBlank(solutionID)){
            currentSolutionJSON=[Select id,body,parentid from attachment where parentID=:solutionID];
        }
        String solutionJson=currentSolutionJSON.body.toString();  
        system.debug('@@@currentSolutionJSON@@@'+solutionJson);
        List<SolutionDTO> solutionDTO = SolutionDTO.parse(solutionJson);
        for(SolutionDTO sol:solutionDTO){
            if(sol.name==SolutionName){
                Map<String,SolutionDTO.Configurations> congToAttMap=new Map<String,SolutionDTO.Configurations>();
                congToAttMap=sol.Configurations;
                system.debug('congToAttMap---->'+congToAttMap);
                if(!congToAttMap.isEmpty()){
                    for(SolutionDTO.Configurations config:sol.Configurations.values()){
                        Map<String,SolutionDTO.Attributes> AttMap=config.attributes;
                        system.debug('Attribute map'+Attmap);
                        if(!AttMap.isEmpty()){
                            guidToAttMapofMap.put(config.guid,AttMap); // attributemapToGuidmaping 
                        }
                    }
                }
            }
        }
        
        return guidToAttMapofMap;
    }
    
    // abstract method to fetch commercialproduct cli and addon cli details and map of guid to map of priceitemid and cli map added by shubhi
    public virtual  Map<String,Map<String,Charge_Line_Item__c>> getCommercialProductCLIMap(Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap ,String basketID,String Solutionname){
        Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap=new Map<String,Map<String,Charge_Line_Item__c>>();
        return commercialProductCLIMap;
    }
        
    /* method to generate corelation id/*Shubhi*/
    public static String getCorrelationIdForMS () {
    system.debug('inside get correlation id');
        String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        String regExp = '[-:\\s]';
        String replacement = '';
        String uniqueString = hashString.replaceAll(regExp, replacement);        
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(uniqueString));
        String hexDigest = EncodingUtil.convertToHex(hash).subString(0, 18);
        System.debug('Generated Unique Key--->: ' + hexDigest);
        return hexDigest;
    }
    
    /*method to fetch discount associations to get applicable discounts Edge-127073*/
    public static Map<String,List<cspmb__Discount_Level__c>> getApplicableDiscounts(Set<string> ComProdIds, String accountID, Set<String> AddonIds){
     Map<String,List<cspmb__Discount_Level__c>> applicableDiscountMap=new Map<String,List<cspmb__Discount_Level__c>>();
    for(cspmb__Discount_Association__c da:[SELECT id,cspmb__Discount_Level__c,cspmb__Discount_Level__r.name,
                                        cspmb__Price_Item__c,cspmb__Discount_Level__r.Description__c,
                                      cspmb__Discount_Level__r.cspmb__Discount__c,
                                      cspmb__Discount_Level__r.cspmb__duration__c,
                                      cspmb__Discount_Level__r.Business_ID__c,
                                      cspmb__Discount_Level__r.Check_todays_date__c,
                                      cspmb__Discount_Level__r.Is_Delegated__c,
                                      cspmb__Discount_Level__r.cspmb__Discount_Type__c,
                                      cspmb__Discount_Level__r.Account__c ,cspmb__Discount_Level__r.Data_Pack_Plan__c,
                                      cspmb__Discount_Level__r.Plan__c,
                                      // Below Field added by Laxmi - EDGE-132685    
                                      cspmb__Discount_Level__r.is_Unlimited__c,
                                       // Below Field added by Laxmi - EDGE-135885    
                                      cspmb__Discount_Level__r.Effective_End_Date__c,
                                      cspmb__Discount_Level__r.discountClass__c    
                                      //Laxmi Changes End
                                                                                
                                      FROM cspmb__Discount_Association__c 
                                      WHERE cspmb__Price_Item__c IN:ComProdIds  
                                      AND cspmb__Discount_Level__r.Check_todays_date__c=true 
                                      AND ((cspmb__Discount_Level__r.Account__c =: accountId AND cspmb__Discount_Level__r.Is_Delegated__c=true) 
                                      OR (cspmb__Discount_Level__r.Account__c=null AND cspmb__Discount_Level__r.Is_Delegated__c=false))]){
      List<cspmb__Discount_Level__c> dislevelList=new List<cspmb__Discount_Level__c>();      
      if(da.cspmb__Price_Item__c!=null){
           if(applicableDiscountMap.containsKey(da.cspmb__Price_Item__c)){
                dislevelList.addAll(applicableDiscountMap.get(da.cspmb__Price_Item__c));
          }
          cspmb__Discount_Level__c dl=new cspmb__Discount_Level__c();
          dl.id=da.cspmb__Discount_Level__c;
          dl.name=da.cspmb__Discount_Level__r.name;
          dl.Description__c=da.cspmb__Discount_Level__r.Description__c;
          dl.cspmb__Discount__c=da.cspmb__Discount_Level__r.cspmb__Discount__c;
          dl.cspmb__duration__c=da.cspmb__Discount_Level__r.cspmb__duration__c;
          dl.Business_ID__c=da.cspmb__Discount_Level__r.Business_ID__c;
          dl.cspmb__Discount_Type__c=da.cspmb__Discount_Level__r.cspmb__Discount_Type__c;
          dl.Data_Pack_Plan__c=da.cspmb__Discount_Level__r.Data_Pack_Plan__c;
          dl.Plan__c=da.cspmb__Discount_Level__r.Plan__c;
          //Added by Laxmi for EDGE-132685
          dl.is_Unlimited__c=da.cspmb__Discount_Level__r.is_Unlimited__c;
          //Added by Laxmi for EDGE-135885
          dl.Effective_End_Date__c=da.cspmb__Discount_Level__r.Effective_End_Date__c;
          dl.discountClass__c=da.cspmb__Discount_Level__r.discountClass__c;
          //Laxmi Changes End       
          dislevelList.add(dl);
          //DL_businessIDList.add(da.cspmb__Discount_Level__r.Business_ID__c);
          applicableDiscountMap.put(da.cspmb__Price_Item__c,dislevelList);
      }
    }
    if(!AddonIds.isEmpty()){
        for(cspmb__Discount_Association__c da:[SELECT id,cspmb__Discount_Level__c,cspmb__Discount_Level__r.name,
                                            cspmb__Add_On_Price_Item__c,cspmb__Discount_Level__r.Description__c,
                                          cspmb__Discount_Level__r.cspmb__Discount__c,
                                          cspmb__Discount_Level__r.cspmb__duration__c,
                                          cspmb__Discount_Level__r.Business_ID__c,
                                          cspmb__Discount_Level__r.Check_todays_date__c,
                                          cspmb__Discount_Level__r.Is_Delegated__c,
                                          cspmb__Discount_Level__r.cspmb__Discount_Type__c,
                                          cspmb__Discount_Level__r.Account__c ,
                                          cspmb__Discount_Level__r.Data_Pack_Plan__c,
                                          cspmb__Discount_Level__r.Plan__c, 
                                          // Below Field added by Laxmi - EDGE-132685    
                                          cspmb__Discount_Level__r.is_Unlimited__c,      
                                          // Below Field added by Laxmi - EDGE-135885    
                                          cspmb__Discount_Level__r.Effective_End_Date__c,
                                          cspmb__Discount_Level__r.discountClass__c
                                          
                                          //Laxmi Changes End
                                          FROM cspmb__Discount_Association__c 
                                          WHERE cspmb__Add_On_Price_Item__c IN:AddonIds  
                                          AND cspmb__Discount_Level__r.Check_todays_date__c=true 
                                          AND ((cspmb__Discount_Level__r.Account__c =: accountId AND cspmb__Discount_Level__r.Is_Delegated__c=true) 
                                          OR (cspmb__Discount_Level__r.Account__c=null AND cspmb__Discount_Level__r.Is_Delegated__c=false))]){
            List<cspmb__Discount_Level__c> dislevelList=new List<cspmb__Discount_Level__c>();      
            if(da.cspmb__Add_On_Price_Item__c!=null){
             if(applicableDiscountMap.containsKey(da.cspmb__Add_On_Price_Item__c )){
                dislevelList.addAll(applicableDiscountMap.get(da.cspmb__Add_On_Price_Item__c ));
             }
          cspmb__Discount_Level__c dl=new cspmb__Discount_Level__c();
          dl.id=da.cspmb__Discount_Level__c;
          dl.name=da.cspmb__Discount_Level__r.name;
          dl.Description__c=da.cspmb__Discount_Level__r.Description__c;
          dl.cspmb__Discount__c=da.cspmb__Discount_Level__r.cspmb__Discount__c;
          dl.cspmb__duration__c=da.cspmb__Discount_Level__r.cspmb__duration__c;
          dl.Business_ID__c=da.cspmb__Discount_Level__r.Business_ID__c;
          dl.cspmb__Discount_Type__c=da.cspmb__Discount_Level__r.cspmb__Discount_Type__c;
          dl.Data_Pack_Plan__c=da.cspmb__Discount_Level__r.Data_Pack_Plan__c;
          dl.Plan__c=da.cspmb__Discount_Level__r.Plan__c;
          //Added by Laxmi for EDGE-132685
          dl.is_Unlimited__c=da.cspmb__Discount_Level__r.is_Unlimited__c;
          //Added by Laxmi for EDGE-135885
          dl.Effective_End_Date__c=da.cspmb__Discount_Level__r.Effective_End_Date__c;
          dl.discountClass__c=da.cspmb__Discount_Level__r.discountClass__c;
          //Laxmi Changes End
                
          dislevelList.add(dl);
          //DL_businessIDList.add(da.cspmb__Discount_Level__r.Business_ID__c);
          applicableDiscountMap.put(da.cspmb__Add_On_Price_Item__c,dislevelList);
          }
        }
    }
    return applicableDiscountMap;
    }   
    
    /*method to fetch promotion metadata  /*Shubhi*/
    public static Map<String,Promotion_Metadata__mdt> fetchPromotionMetadata(Set<String> businessIdList){
        Map<String,Promotion_Metadata__mdt> promotionalMetadataMap=new Map<String,Promotion_Metadata__mdt>();
        for(Promotion_Metadata__mdt pm:[SELECT id,DeveloperName,BusinessID__c,
                                        Category__c,IsDelegated__c,Eligibility_Pattern__c,
                                        ReferenceAttribute__c,ReferenceField__c,ReferenceObject__c,isActive__c
                                        FROM Promotion_Metadata__mdt where BusinessID__c IN:businessIdList and isActive__c=true]){  //updated query for  Added as part of EDGE 123594                                         
            promotionalMetadataMap.put(pm.BusinessID__c,pm);                              
         }
        return promotionalMetadataMap;
    }
    
    /*method to get priceitem list from priceitemmap */
    public static Set<string> getPriceItemIds(Map<String,Map<String,Charge_Line_Item__c>> priceItemmap){
        Set<String> priceitemSet=new Set<string>();
        if(priceItemmap.size()>0){
            for(String guid:priceItemmap.keyset()){
                if(priceItemmap.get(guid).containsKey('Price Item')){
                    priceItemSet.add(priceItemmap.get(guid).get('Price Item').commercialProductId__c);
                }
            }
        }
        return priceitemSet;
    }
    /*method to get charge Ids from priceitemmap */ //EDGE-133963 added for voice /device
    public static Set<string> getChargeIds(Map<String,Map<String,Charge_Line_Item__c>> priceItemmap){
        Set<String> chargeIDSet=new Set<string>();
        if(priceItemmap.size()>0){
            for(String guid:priceItemmap.keyset()){
                if(priceItemmap.get(guid).size()>0){
                    chargeIDSet.addAll(priceItemmap.get(guid).keySet());
                }
            }
        }
        return chargeIDSet;
    }
     
     /*methos to get addon list from addonmap */
    public static set<string> getAddonIds(Map<String,Map<String,Charge_Line_Item__c>> addonMap){
        Set<String> addonSet=new Set<string>();
        if(addonMap.size()>0){
            for(String guid: addonMap.keyset()){
                if(addonMap.get(guid).containsKey('AddOn')){
                    addonSet.add(addonMap.get(guid).get('AddOn').commercialProductId__c);
                }
            }
        }
        return addonSet;
    }
    
    /* method to get attribute to mapped list corresponding to guid Edge-127073*/ /*Shubhi*/
    public static Map<String,List<String>> getattributesTobeMappedMap(Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Set<String> guidset,Set<string> priceItemSet, Set<string> addonset){
        Map<String,List<String>> attributesTobeMappedMap=new Map<String,List<String>>();
        //Set<String> guidSet=new Set<String>();
        Set<String> priceitem_addonSet=new Set<string>();
        if(priceItemSet.size()>0){
            priceitem_addonSet.addAll(priceItemSet);
        }
        if(addonset.size()>0){
            priceitem_addonSet.addAll(addonset);
        }       
        for(String guid:guidSet){
            List<String> attributeList=new List<String>();
            for(String PriceitemId:priceitem_addonSet){
                List<cspmb__Discount_Level__c> discountLevelList=new List<cspmb__Discount_Level__c>();
                if(DiscountLevelMap.containskey(PriceitemId)){
                    discountLevelList.addAll(DiscountLevelMap.get(PriceitemId));
                    for(cspmb__Discount_Level__c dl:discountLevelList){
                        if(promotionMetadataMap.containskey(dl.Business_ID__c)){
                            Promotion_Metadata__mdt pm=promotionMetadataMap.get(dl.Business_ID__c);
                            if(pm.ReferenceObject__c!=null){
                                attributeList.add(pm.ReferenceAttribute__c);
                            }
                        }
                    }
                }
            }
            if(!attributeList.isEmpty()){
                attributesTobeMappedMap.put(guid,attributeList);
            }
        }
        return attributesTobeMappedMap;
    }
    
    /* method to get attribute value to mapped list corresponding to att to guid Edge-127073*/ /*Shubhi*/
    public static Map<String, Map<String,String>> getAttValueforAttributeTobeMaped(Map<String,List<String>> attributesTobeMappedMap,Set<String> guidSet,Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap){
        Map<String, Map<String,String>> attValueforAttributeTobeMaped =new Map<String, Map<String,String>>();
        for(String guid:guidSet){
            if(guidToAttMapofMap.size()>0 && guidToAttMapofMap.containskey(guid)){
                Map<String,String> attTovalueMap=new Map<String,String>();
                for(SolutionDTO.Attributes att: guidToAttMapofMap.get(guid).values()){
                    if(attributesTobeMappedMap.size()>0 && attributesTobeMappedMap.containskey(guid) &&attributesTobeMappedMap.get(guid).contains(att.name) && String.isNotBlank(att.value)){
                        attTovalueMap.put(att.name,att.value);
                    }
                }
                if(!attTovalueMap.isempty()){
                    attValueforAttributeTobeMaped.put(guid,attTovalueMap);
                }
            }   
        }
        return attValueforAttributeTobeMaped;
    }
    
    /*method to get discountlineItems after checking applicable and eligible criteria*/
    /*applicable criteria is to be present in discountlevlMap and promtionalmetadata*/
    /*Eligible criteria is reference object of promtional metadata is not blankk other applicable is eligble*/
    public virtual Map<String, Map<String,List<Discount_Line_Item__c>>> getDiscountLineItems(Map<String, Map<String,String>> attValueforAttributeTobeMaped,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Set<String> guidset,Set<string> priceItemSet, Set<string> addonset){
        Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItems=new Map<String, Map<String,List<Discount_Line_Item__c>>>();
        return DiscountLineItems;
    }
    
    /*method to getcharge lineitems needs to be overriden */
    public virtual Map<String, Map<String,Charge_Line_Item__c>> getChargeLineItems(Map<String,Map<String,Charge_Line_Item__c>> piToClimap,Set<String> guidSet,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Map<String, Map<String,String>> attValueforAttributeTobeMaped){
        Map<String, Map<String,Charge_Line_Item__c>> chargeLineItems=new Map<String, Map<String,Charge_Line_Item__c>>();
        return chargeLineItems;
    }
        
    /*method to publish event  /*Shubhi*/
    public static void publishEventRequest(String correlationId,String SolutionName, String basketName, Boolean isTieredRecurring){
        PriceScheduleEvent__e event = new PriceScheduleEvent__e(eventType__c='Request',CorrelationId__c=correlationId,initiatedBy__c=UserInfo.getUserId(),basketNumber__c=basketName,solutionName__c=SolutionName,containsTieredCharges__c=isTieredRecurring);
        Database.SaveResult result = EventBus.publish(event);
        if (result.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('inserted: ' + result.getId());
            //responseRecordId.add(sr.getId());
        }else {
            for (Database.Error error : result.getErrors()) 
            {
                System.debug('Error returned: ' +
                             error.getStatusCode() +' - '+
                             error.getMessage());
            }
        }
    }
    
    /*/// added by shubhi  method to fetch Not applicable Discounts//*/
    public static Set<String> fetchNotapplicableDiscounts(Set<string> allComProdGuids, Set<String> allEligibleGuids){
        system.debug('Allguids-->'+allComProdGuids);
        system.debug('Allapplicableguids-->'+allEligibleGuids);
        Set<String> notapplicableGuidList=new Set<String>();
        if(allComProdGuids!=null && allEligibleGuids!=null && allComProdGuids.size() == allEligibleGuids.size() ){
            return notapplicableGuidList; // added for Edge-143527 not to return if same
        }
        for(String guid:allComProdGuids){
            if(allEligibleGuids.size()>0 && !allEligibleGuids.contains(guid)){
                system.debug('inside no eligible');
                notapplicableGuidList.add(guid);
            }   
        }
        if(notapplicableGuidList.isEmpty()){
            return allComProdGuids;
        }
        return notapplicableGuidList;
    } 
    
    ///////////////////methods for TCV claculation //////////////////////////////
        //Added by Aman Soni as a part of EDGE-123575 || Start
    public static Map<String,Map<String,String>> fetchTCV(List<String> configIdList,String CorrelationId){  
        System.debug('configIdList inside TCV method'+configIdList);
        System.debug('CorrelationId inside TCV method'+CorrelationId);
        Map<String,Map<String,String>> TCVMap =new Map<String,Map<String,String>>();
        Map<String,Charge_Line_Item__c> CLIMap =new Map<String,Charge_Line_Item__c>();               
        for(Charge_Line_Item__c cli:[Select id,componentName__c,CorrelationId__c,BusinessID__c,guid__c from Charge_Line_Item__c where guid__c IN :configIdList]){
        CLIMap.put(cli.id,cli);
        System.debug('CLIMap inside TCV'+CLIMap);       
        }
        Map<String,PricingMSResponseObject__c> priceMsMap=new Map<String,PricingMSResponseObject__c>();
        // EDGE-135885 Laxmi - Added RemainingTerm__c in the below Query 
        Map<String,decimal> cliIDRemainingTerm = new Map<String,decimal>();  

        for(PricingMSResponseObject__c priceMs:[Select id,CorrelationId__c,TCV_Value__c,CLI_Instance_ID__c,RemainingTerm__c 
                        from PricingMSResponseObject__c where CorrelationId__c = :CorrelationId]){
            priceMsMap.put(priceMs.CLI_Instance_ID__c,priceMs);
            System.debug('CLIMap inside TCV'+priceMsMap);           
        } 
        // EDGE-135885 Laxmi Changes End
        //Laxmi -EDGE-132685  Created Map to store the CLI id and the TCV for the same
        Map<String,decimal> cliIDTCVMap = new Map<String,decimal>();  
        
    
        //integer tcvVal = 0;
        String tcvSTR = '';
        Set<String> cliIDs = new Set<String>();
        if(CLIMap.size() > 0 && priceMsMap.size() > 0){         
            for(String key : CLIMap.KeySet()){
                system.debug('@@@key@@@'+key);
                System.debug('CLIMap.get(key).componentName__c'+CLIMap.get(key).componentName__c); 
                Map<String,String> chargeAttributeNameMap = DiscountConstants.getChargeAttributeNameMap(String.ValueOf(CLIMap.get(key).componentName__c));
                System.debug('chargeAttributeNameMap'+chargeAttributeNameMap); 
                System.debug('CLIMap.get(key).BusinessID__c)'+CLIMap.get(key).BusinessID__c); 
                System.debug('CLIMap inside TCV ' + CLIMap.get(key) + 'priceMsMap inside TCV' + priceMsMap.get(key) + 'chargeAttributeNameMap inside TCV' + chargeAttributeNameMap.get(CLIMap.get(key).BusinessID__c));
                if(CLIMap.get(key) != null && priceMsMap.get(key)!=null && chargeAttributeNameMap.get(CLIMap.get(key).BusinessID__c)!=null){
                Map<String,String> busTCVMap = null;
                //String configGUID = CLIMap.get(key).guid__c; 
                String configGUID = '"' + CLIMap.get(key).guid__c + '"';
                    if(TCVMap.get(configGUID) != null){
                        busTCVMap = TCVMap.get(configGUID);
                    }
                    else{
                        busTCVMap = new Map<String,String>();
                    }
                    if(priceMsMap.get(key).TCV_Value__c!=null){
                        Decimal tcvVal = 0.00;
                        Decimal remainingTerm = 0;
                        busTCVMap.put(chargeAttributeNameMap.get(CLIMap.get(key).BusinessID__c),String.valueOf(priceMsMap.get(key).TCV_Value__c)); // key = attributeName
                        //Laxmi -EDGE-132685 - store value of TCV from the Attribute Map, do basic checks for integer Check
                        tcvSTR = String.valueOf(priceMsMap.get(key).TCV_Value__c);
                        remainingTerm = priceMsMap.get(key).RemainingTerm__c;
                        if (remainingTerm==null)
                        {
                            remainingTerm = 0;
                        }
                        //if (tcvSTR.isNumeric()){
                            tcvVal = Decimal.ValueOf(tcvSTR.trim());
                        //}
                         system.debug ('*********key and Value pair -- Key - '+key + ' ---Value --' + tcvVal);
                        cliIDTCVMap.put (key,tcvVal);
                        cliIDs.add (key); // Key set for CLI IDs
                        cliIDRemainingTerm.put (key,remainingTerm);// EDGE-135885 - Map to be updated fro Remaining Term
                        //Laxmi -EDGE-132685 - Changes End
                    }else{
                        busTCVMap.put(chargeAttributeNameMap.get(CLIMap.get(key).BusinessID__c),'0');
                    }
                    TCVMap.put(configGUID,busTCVMap);  

                }
            }
            // Pass CLIID and TCV map & CLIDS set to update TCV
            updateTCVForCLIId(cliIDTCVMap,cliIDs,cliIDRemainingTerm);       
            
        }
        system.debug('TCVMap--->'+TCVMap);
        return TCVMap;
    }
    //Added by Aman Soni as a part of EDGE-123575 || End
    //Added by Laxmi as a part of EDGE-132685 || Method to update the TCV against the CLI id 
    public static void updateTCVForCLIId(Map<String,decimal> cliIdTCVMap, Set<String> setCliIDs, Map<String,decimal> cliIdRemainingTerm)
    {
        List<Charge_Line_Item__c> clisForUpdate = new List<Charge_Line_Item__c>();
        System.debug ( '********setCliIDs*****************- ' + setCliIDs);
        //added by shubhi:
        if (!setCliIDs.isEmpty())
        {
            ChargeDiscountQueryUtility cdq=new ChargeDiscountQueryUtility();
            List<Charge_Line_Item__c> clilist=cdq.fetchChargeLineItem(setCliIDs);
            for ( Charge_Line_Item__c cli:clilist)
            {   
                cli.totalContractValue__c = cliIdTCVMap.get(cli.id);
                cli.RemainingTerm__c = cliIdRemainingTerm.get (cli.id);
                clisForUpdate.add (cli);
            } 
            try 
            {
                if(clisForUpdate.size()>0){
                    //update  clisForUpdate;
                    ComplexChargeDisountFactory cdf=new ComplexChargeDisountFactory();
                    cdf.updateChargeLineItem(clisForUpdate);
                } 
            }
            catch (Exception e){
                System.debug('An exception occurred while Updating TCV on CLI ' + e.getMessage());
            }        
        }
    }
    
}