/*
* @Author : Aman
* @Date : 04 Feb 2019
* @Desc : GetPriceScheduleControllerNGUC
* @Jira : Edge-133963
* @TestClass : GetPriceScheduleContollerTest
1. shubhi for Edge-133963 qa2 bug fix
2. Edge-143527 changed on load method
*/
global with Sharing class GetPriceScheduleControllerNGUC extends GetPriceSchedulevirtualClass{
    /*public String commercialProductIdentifier='Contract Type';
    public String AddOnIdentifier='IDD ChargeLookup';
    public String basketId = System.currentPageReference().getParameters().get('basketId');
    public String solutionId = System.currentPageReference().getParameters().get('SolutionId');
    public String accountId = System.currentPageReference().getParameters().get('accountId');
    public String discountStatus= System.currentPageReference().getParameters().get('discountStatus');
    public String callerName= System.currentPageReference().getParameters().get('callerName'); // name of Js
    public String IsDiscountCheckNeededparam = System.currentPageReference().getParameters().get('IsDiscountCheckNeeded');
    public String IsDiscountCheckNeeded {get;set;}   
    public String correlation_Id= System.currentPageReference().getParameters().get('correlationId');
    public String correlationId {get; set;}
    public String DiscountApplicableStatus {get; set;}
    public Set<String> notApplicableGuidList {get; set;}
    //Laxmi - EDGE-135885 - Added this field to store the Solution NameDTO
    public String solutionName = System.currentPageReference().getParameters().get('solutionName');
    public String basketNum= System.currentPageReference().getParameters().get('basketNum');*/
    public set<String> CLIbusinessIdSet {get; set;} //edge-121376
    public String DiscountApplicableStatus {get; set;}
    public Set<String> notApplicableGuidList {get; set;}
    public string solutionID {get; set;}
    public String correlationId {get; set;}
    public void onLoadMethod(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basketId,String accountId,String solID,String IsDiscountCheckNeeded,String solutionName,String basketNum,String correlId){ //Edge-143527 added method params for remote call
        /*method to be executed on load Edge-127073*/ 
        //IsDiscountCheckNeeded=IsDiscountCheckNeededparam;
        //GetPriceScheduleAbstractClass GetPriceScheduleAbstractClass=new GetPriceScheduleAbstractClass();
        system.debug('Inside Onload IsDiscountCheckNeeded--->'+IsDiscountCheckNeeded); 
           system.debug('Inside Onload basketId--->'+basketId); 
        DiscountApplicableStatus='Initial';
        solutionId=solID;
        DiscountApplicableStatus='Initial';
        correlationId=correlId;
        if(IsDiscountCheckNeeded=='true'){           
            if(String.isNotBlank(solutionID) && guidToAttMapofMap!=null && guidToAttMapofMap.size()>0){  ////Edge-143527
                notApplicableGuidList=new Set<String>();
                system.debug('@@@guidToAttMapofMap@@@'+guidToAttMapofMap);
                system.debug('correlationId--->'+correlationId);
                Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap = getCommercialProductCLIMap(guidToAttMapofMap,basketID,Solutionname);
                system.debug('@@@commercialProductCLIMap@@@'+commercialProductCLIMap);
                Set<String> priceItemSet=new Set<string>();
                Set<String> AddOnSet=new Set<string>();
                Set<String> BusIdSet=new Set<String>();
                if(commercialProductCLIMap.size()>0){
                    priceItemSet=GetPriceSchedulevirtualClass.getPriceItemIds(commercialProductCLIMap);
                    system.debug('@@priceItemSet@@'+priceItemSet);
                    // bug Edge-133963 start
                    Map<String,String> guidToPIiMap=new Map<String,String>();
                    for(String guid:commercialProductCLIMap.keyset()){
                        if(commercialProductCLIMap.get(guid).containsKey('Price Item')){
                            guidToPIiMap.put(guid,commercialProductCLIMap.get(guid).get('Price Item').commercialProductId__c);
                        }
                    }
                    //bug Edge-133963 end
                    Map<String,List<cspmb__Discount_Level__c>> discountLevelMap=GetPriceSchedulevirtualClass.getApplicableDiscounts(priceItemSet,accountId,AddOnSet);                  
                    system.debug('@@DiscountLevelMap@@'+discountLevelMap);
                    if(!discountLevelMap.isempty() && priceItemSet.size()>0 ){
                        for(String piId:discountLevelMap.keyset()){
                            for(cspmb__Discount_Level__c dl:discountLevelMap.get(piId)){
                                BusIdSet.add(dl.Business_ID__c);
                            }
                        }
                        system.debug('@@BusIdSet@@'+BusIdSet);
                        Map<String,Promotion_Metadata__mdt> promotionMetadataMap=GetPriceSchedulevirtualClass.fetchPromotionMetadata(BusIdSet);
                        if(promotionMetadataMap.size()>0){
                            Map<String,List<String>> attributesTobeMappedMap=GetPriceSchedulevirtualClass.getattributesTobeMappedMap(promotionMetadataMap,discountLevelMap,commercialProductCLIMap.keySet(),priceItemSet ,AddOnSet);
                            system.debug('attributesTobeMappedMap--->'+attributesTobeMappedMap);
                            Map<String, Map<String,String>> attValueforAttributeTobeMaped=new Map<String, Map<String,String>>();
                            if(attributesTobeMappedMap.size()>0){
                                 attValueforAttributeTobeMaped=GetPriceSchedulevirtualClass.getAttValueforAttributeTobeMaped(attributesTobeMappedMap,commercialProductCLIMap.keySet(),guidToAttMapofMap);
                                system.debug('attValueforAttributeTobeMaped--->'+attValueforAttributeTobeMaped);
                            }
                            set<string> guidset=commercialProductCLIMap.keyset();
                            Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap=getDiscountLineItems(attValueforAttributeTobeMaped,promotionMetadataMap,DiscountLevelMap,guidset,guidToPIiMap,addonset);
                            if(DiscountLevelMap.size()>0){
                                Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems=getChargeLineItems(commercialProductCLIMap,DiscountLineItemsMap.keyset(),DiscountLevelMap,attValueforAttributeTobeMaped);
                                if(finalChargeLineItems.size()>0){
                                    ComplexChargeDisountFactory chargeDiscountDML=new ComplexChargeDisountFactory();
                                    chargeDiscountDML.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems);//Edge-133963  - updated method name from insert to upsert
                                    GetPriceSchedulevirtualClass.publishEventRequest(correlationId,solutionName,basketNum,false);
                                    DiscountApplicableStatus='Discount Applicable';
                                    //ApplicableGuidList.addAll(finalChargeLineItems.keySet());
                                    notApplicableGuidList.addAll(GetPriceSchedulevirtualClass.fetchNotapplicableDiscounts(commercialProductCLIMap.keySet(),finalChargeLineItems.keySet()));
                                }
                            }else{
                                DiscountApplicableStatus='No discount applicable';
                                notApplicableGuidList=commercialProductCLIMap.keySet();
                            }
                        }else{
                            DiscountApplicableStatus='No discount applicable';
                            notApplicableGuidList=commercialProductCLIMap.keySet();
                        }
                    }else{
                        DiscountApplicableStatus='No discount applicable';
                        notApplicableGuidList=commercialProductCLIMap.keySet();
                    }
                    
                }
                
            }           
        }
        else{
            //correlationId=correlation_Id;
            DiscountApplicableStatus='Already triggered';
            system.debug('Inside else isDiscountCheckNeeded'+isDiscountCheckNeeded);
        } 
        system.debug('---DiscountApplicableStatus-->'+DiscountApplicableStatus);        
    }
   
    /*method to fetch mobile subscription priceitem salesforce id Edge-127073*/
    /*Shubhi*/
    public override Map<String,Map<String,Charge_Line_Item__c>> getCommercialProductCLIMap(Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap ,String basketID,String Solutionname){
        Map<String,Map<String,Charge_Line_Item__c>> ommercialProductCLIMap=new Map<String,Map<String,Charge_Line_Item__c>>();
        Map <String,String> DiscountConstantsMap = DiscountConstants.GetDiscountConstBasedonSolName(solutionName);
        if (DiscountConstantsMap.size() > 0 && guidToAttMapofMap.size()>0){
            String commercialProductIdentifier='';
            String contractTermIdentifier='';
            String CliBusinessIdIdentifier='';
            String unitPrice_Identifier='';
            String quantityIdentifier='';
            if(DiscountConstantsMap.containsKey('commercialProductIdentifier')) {
                commercialProductIdentifier = DiscountConstantsMap.get('commercialProductIdentifier');
            }
            if(DiscountConstantsMap.containsKey('contractTermIdentifier')) {
                contractTermIdentifier = DiscountConstantsMap.get('contractTermIdentifier');
            }
            if(DiscountConstantsMap.containsKey('CliBusinessIdIdentifier')) {
                CliBusinessIdIdentifier = DiscountConstantsMap.get('CliBusinessIdIdentifier');
            }
            if(DiscountConstantsMap.containsKey('unitPrice_Identifier')) {
                unitPrice_Identifier = DiscountConstantsMap.get('unitPrice_Identifier');
            }            
            if(DiscountConstantsMap.containsKey('quantityIdentifier')){
                quantityIdentifier = DiscountConstantsMap.get('quantityIdentifier');
            }
            //Map<String,Charge_Line_Item__c> comProdIdToCliMap=new Map<String,Charge_Line_Item__c>();
            for(String configGuid:guidToAttMapofMap.keySet()){
                Map<String,Charge_Line_Item__c> comProdIdToCliMap=new Map<String,Charge_Line_Item__c>();
                Map<String,SolutionDTO.Attributes> attMap=guidToattMapofMap.get(configGuid);
                if(attMap.containsKey('IsDiscountCheckNeeded') && attMap.get('IsDiscountCheckNeeded').value=='true'){
                    if(attMap.containsKey(commercialProductIdentifier) && !String.isBlank(attMap.get(commercialProductIdentifier).value)){
                        Charge_Line_Item__c cliPI=new Charge_Line_Item__c();
                        cliPI.basketId__c=basketID;                      
                        cliPI.solutionId__c=solutionID;
                        cliPI.componentName__c=solutionName;
                        cliPI.guid__c=configGuid;   
                        cliPI.CorrelationId__c=correlationId;
                        cliPI.Product_Charge_Identifier__c='Device';
                        cliPI.targetChargeProduct__c ='Device';
                        cliPI.commercialProductId__c=attMap.get(commercialProductIdentifier).value; 
                        if(attMap.containsKey(unitPrice_Identifier)&& !String.isBlank(attMap.get(unitPrice_Identifier).value)){
                            cliPI.unitPrice__c=Decimal.valueof(attMap.get(unitPrice_Identifier).value);
                        }
                        if(attMap.containsKey(CliBusinessIdIdentifier)&&  !String.isBlank(attMap.get(CliBusinessIdIdentifier).value)){
                            cliPI.BusinessID__c=attMap.get(CliBusinessIdIdentifier).value;
                            cliPI.chargeType__c = DiscountConstants.getChargeType(cliPI.BusinessID__c);
                        }
                        if(attMap.containsKey(contractTermIdentifier) && !String.isBlank(attMap.get(contractTermIdentifier).value)){
                            cliPI.contractTerm__c=Integer.valueof(attMap.get(contractTermIdentifier).value);
                        }else if(attMap.containsKey(contractTermIdentifier) && String.isBlank(attMap.get(contractTermIdentifier).value)){
                            cliPI.contractTerm__c=24;
                        }
                        if(attMap.containsKey(quantityIdentifier) && !String.isBlank(attMap.get(quantityIdentifier).value)){
                            cliPI.Quantity__c=Integer.valueof(attMap.get(quantityIdentifier).value);
                        }
                        //cliPI.chargeType__c = Constants.getChargeType(cliPI.BusinessID__c);
                        comProdIdToCliMap.put('Price Item',cliPI);
                    }  
                }
                if(comProdIdToCliMap.size()>0)
                    ommercialProductCLIMap.put(configGuid,comProdIdToCliMap);
            }
        }
        return ommercialProductCLIMap;
    }
  /*method to fetch discount associations to get applicable discounts Edge-127073*/
 
   /* method to get eligible discounts to mapped list corresponding to guid Edge-127073*/ /*Shubhi*/
    public  Map<String, Map<String,List<Discount_Line_Item__c>>> getDiscountLineItems(Map<String, Map<String,String>> attValueforAttributeTobeMaped,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Set<String> guidset,Map<String,String> guidToPIidMap, Set<string> addonse){
        Map<String, Map<String,List<Discount_Line_Item__c>>> guidToEligibleDLIMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>();
         //Added by Laxmi for EDGE-135885
        //Get the Feature toggle value for Populate Discount Class - if thats true then assign the hardcoded values for this field
        //When Napier team is ready with these changes this value will be false and the values to be assigned will come from Napier Team
        Feature_Flag__mdt featureFlag_Mdt= FeatureFlagUtility.getFeatureTogglingByName('Populate_Discount');    
        boolean featureFlag = false;
        if (featureFlag_Mdt!= null)
        {
           system.debug ('@@@@@@@@@featureFlag'+ featureFlag);
           featureFlag = featureFlag_Mdt.IsActive__c;
        }
        //Changes End   
        if(guidset.size()>0){
            for(String guid:guidset){
                Set<string> priceItemAddonSet=new Set<string>();//list of priceitem and addon 
                String priceItemId='';
                // bug Edge-133963
                if(guidToPIidMap!=null && guidToPIidMap.containskey(guid)){
                    priceItemId=guidToPIidMap.get(guid);
                } ///end
                //addonset.addAll(priceItemSet);
                Map<String,String> attributeToValueMap=new Map<String,String>();
                if(attValueforAttributeTobeMaped.containskey(guid)){
                    attributeToValueMap=attValueforAttributeTobeMaped.get(guid);//added for EDGE-123594
                }
                List<Discount_Line_Item__c> dislevellist=new List<Discount_Line_Item__c>();
                Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();
                //for(String PriceitemId:priceItemAddonSet){                  
                    List<cspmb__Discount_Level__c> discountLevelList=new List<cspmb__Discount_Level__c>();
                    if(DiscountLevelMap.containskey(PriceitemId)){
                        discountLevelList.addAll(DiscountLevelMap.get(PriceitemId));
                        GetDiscountEligiblityClass EllClass= new GetDiscountEligiblityClass();
                        List<cspmb__Discount_Level__c>EligiblediscountLevelList=EllClass.EligibleDiscountList(discountLevelList,promotionMetadataMap,attributeToValueMap);
                        system.debug('EligiblediscountLevelList--->'+EligiblediscountLevelList);
                        for(cspmb__Discount_Level__c dl:EligiblediscountLevelList){  
                            if(promotionMetadataMap.containskey(dl.Business_ID__c)){
                                Discount_Line_Item__c dli=new Discount_Line_Item__c();
                                dli.BusinessID__c=dl.Business_ID__c;
                                dli.description__c=dl.Description__c;
                                dli.discountType__c=dl.cspmb__Discount_Type__c;
                                if (featureFlag) ////featureFlag = false if data come from Napier else featureFlag = true to create own data// the DLI will have static values//Added by Laxmi for EDGE-135885 start 
                                {
                                    if(dl.cspmb__Discount_Type__c=='Percentage'){
                                        dli.discountType__c='Percent';
                                        dli.discountClass__c='Percent';
                                    }else{
                                        dli.discountClass__c = dl.cspmb__Discount_Type__c; 
                                    }
                                }else
                                {
                                    dli.discountClass__c = dl.discountClass__c;
                                }//Added by Laxmi for EDGE-135885 end 
                                dli.discountValue__c=String.valueOf(dl.cspmb__Discount__c);
                                dli.duration__c=String.valueOf(dl.cspmb__duration__c);
                                dli.durationUoM__c='Months';
                                dli.Priority__c=1;
                                dli.name=dl.name;

                                dli.isUnlimited__c=dl.is_Unlimited__c;                                
                                //dli.chargeInstance__c=null;
                                dli.discountEndDate__c=dl.Effective_End_Date__c; //Added by Laxmi for EDGE-135885                     
                                Promotion_Metadata__mdt pm=promotionMetadataMap.get(dl.Business_ID__c);
                                if(priceitemToeligibleDLMap.containsKey(PriceitemId)){
                                    dislevellist.addall(priceitemToeligibleDLMap.get(PriceitemId));
                                }
                                system.debug('DiscountLevel'+dl);
                                dislevellist.add(dli); //added for EDGE-123594
                                  //Commented As part of EDGE-123594 by ankit || Start
                                /*if(pm.ReferenceObject__c!=null){
                                    system.debug('dl.Business_ID__c'+dl.Business_ID__c);
                                    system.debug('ref field'+promotionMetadataMap.get(dl.Business_ID__c).ReferenceField__c);
                                    system.debug('dl.ReferenceField__c'+dl.get(promotionMetadataMap.get(dl.Business_ID__c).ReferenceField__c));
                                    system.debug('ref att map'+ attValueforAttributeTobeMaped);
                                    if(attValueforAttributeTobeMaped.size()>0 && attValueforAttributeTobeMaped.containskey(promotionMetadataMap.get(dl.Business_ID__c).ReferenceAttribute__c) &&
                                            (dl.get(promotionMetadataMap.get(dl.Business_ID__c).ReferenceField__c)==attValueforAttributeTobeMaped.get(promotionMetadataMap.get(dl.Business_ID__c).ReferenceAttribute__c))){               
                                        dislevellist.add(dli);
                                    }
                                }else{
                                    dislevellist.add(dli);
                                }*/
                                 //Commented As part of EDGE-123594 by ankit || End
                            }   
                        }
                        if(!dislevellist.isEmpty()){
                            system.debug('dislevellist--->'+dislevellist);
                           priceitemToeligibleDLMap.put(PriceitemId,dislevellist);
                        }
                    }
                //}
                system.debug('priceitemToeligibleDLMap--->'+priceitemToeligibleDLMap);
                if(!priceitemToeligibleDLMap.isEmpty()){
                    guidToEligibleDLIMap.put(guid,priceitemToeligibleDLMap);
                }
            }
        }  
        system.debug('guidToEligibleDLIMap--->'+guidToEligibleDLIMap);
        return guidToEligibleDLIMap;
    }
    /*  method to get eligible chargeLine items */
    public override Map<String, Map<String,Charge_Line_Item__c>> getChargeLineItems(Map<String,Map<String,Charge_Line_Item__c>> GuidpiToClimap,Set<String> guidSet,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Map<String, Map<String,String>> attValueforAttributeTobeMaped){
    
        Map<String, Map<String,Charge_Line_Item__c>> getEligibleChargeLineItem=new Map<String, Map<String,Charge_Line_Item__c>>();
        for(String guid:guidSet){
            Map<String,String> attributeToValueMap=new Map<String,String>();
            if(attValueforAttributeTobeMaped.size()>0 && attValueforAttributeTobeMaped.containsKey(guid)){
                attributeToValueMap=attValueforAttributeTobeMaped.get(guid);
            }
            Map<String,Charge_Line_Item__c> pITOCLiMap=new Map<String,Charge_Line_Item__c>();
            if(GuidpiToClimap.containsKey(guid) && GuidpiToClimap.get(guid).containskey('Price Item')){
                Charge_Line_Item__c cli=GuidpiToClimap.get(guid).get('Price Item');
                pITOCLiMap.put(cli.commercialProductId__c,cli);
            }
            //system.debug();
            if(!pITOCLiMap.isEmpty()){
                getEligibleChargeLineItem.put(guid,pITOCLiMap);
            }
            
        }
        return getEligibleChargeLineItem;
    }   
}