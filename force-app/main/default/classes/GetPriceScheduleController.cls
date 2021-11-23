/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : GetPriceScheduleController  
* @Jira : Edge-127073
* @TestClass : GetPriceScheduleContollerTest
* @EDGE#: Sr no 1 - EDGE-127421 - Added Method to Populate MRO Bonus Discount!!
* @EDGE#: Sr no 2 - EDGE-135885 - Added logic to populate few fields on MSResposne, CLI and DLI
* @EDGE#: Sr no 3 - EDGE-123594 - Added logic to discount eligible by ankit
* @EDGE#: Sr no 4 - EDGE-135278 - Added by Aman Soni To update Billing Account Number on CLI
* @EDGE#: Sr no 5 - EDGE-131531 - Added by Laxmi Checks for Active And cancel
* @EDGE#: Sr no 6 - Edge-133963 - updated method name from insert to upsert
* @edge#: Sr no 7 - EDGE-141476 - updated null check non deal offers
* @EDGE#: Sr no 8 - EDGE-138169 - Added by Aman Soni To update Original Activation Date on CLI
* @EDGE#: Sr no 9 - EDGE-143527 - Added by Shubhi/Aman - POC solution json change
* @EDGE#: Sr no 10- EDGE-143527 - Observation Fixed issue of Total Plan Bonus field blank 
* @EDGE#: Sr no 11- EDGE-143527 - Added for CLI fix || Single CLI Fix is getting created for multiple MRO Configs || Aman Soni 
*/
global with Sharing class GetPriceScheduleController{
    public String commercialProductIdentifier='Select Plan';
    public String AddOnIdentifier='IDD ChargeLookup';
    public String businessIDMRO ='DMCAT_Discount_000850';
    public string solutionName {get; set;}
    public Map<String, Map<String,List<String>>> GuidToPI_AddonMap {get; set;}
    public List<PriceScheduleEvent__e> eventList=new List<PriceScheduleEvent__e>();
    public Map<String,SolutionDTO> solutionToGuidMap {get; set;}
    public Map<String,Map<String,Charge_Line_Item__c>> GuidToPriceitemToCliMap {get; set;}
    public Set<String> DL_businessIDList {get; set;}
    public string solutionID {get; set;}
    public String correlationId {get; set;}
    public String DiscountApplicableStatus {get; set;}
    public Set<String> notApplicableGuidList {get; set;}
    public Set<String> selectPlanBlankList {get; set;}
    public Set<String> AllGuidList {get; set;}
    public Set<String> ApplicableGuidList {get; set;}
    public Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems {get; set;}
    public Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap  {get; set;}  
    Set<String> guidSet = new Set<String>();//Added by Aman Soni as a part of EDGE-138169
    Set<String> planAddonIDSet = new Set<String>();//Added by Aman Soni as a part of EDGE-138169
    String basketID {get;set;}
    
    /*method to be executed on load Edge-127073*/ 
    public void onLoadMethod(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basktId,String accountId,String solID,    String IsDiscountCheckNeeded,String solName,String basketNum,String correlId){ // updated onload Edge-143527
        DiscountApplicableStatus='Initial';
        solutionName=solName;
        basketID=basktId;
        solutionID=solID;
        DL_businessIDList=new Set<String>();
        if(IsDiscountCheckNeeded=='true'){           
            List<SolutionDTO> solutionDTO;
        if(String.isNotBlank(solutionID)){
            ApplicableGuidList=new set<string>();
            notApplicableGuidList=new set<string>();
            AllGuidList=new set<string>();
            selectPlanBlankList=new set<string>();
            //solutionDTO=getSolutionDto(solutionID);
            Set<String> commercialProductList=new Set<String>();
            Set<String> addonList=new Set<String>();
            system.debug('@@@guidToAttMapofMap@@@'+guidToAttMapofMap);
            correlationId=correlId; 
            if(guidToAttMapofMap!=null && !guidToAttMapofMap.isEmpty()&& !String.isBlank(basketID) && !String.isBlank(solutionName)){
                Map<String,List<String>> PI_AddonListMap=getCommercialProductList(guidToAttMapofMap,basketID);
                if(GuidToPI_AddonMap != null && !GuidToPI_AddonMap.isEmpty()){
                    List<String> priceItemAddonId=new List<String>();
                    for(String guid:GuidToPI_AddonMap.keySet()){
                        guidSet.add(guid);//Added by Aman Soni as a part of EDGE-138169
                        if(GuidToPI_AddonMap.get(guid).containsKey('PriceItem')){
                            priceItemAddonId.addAll(GuidToPI_AddonMap.get(guid).get('PriceItem'));
                        }
                        if(GuidToPI_AddonMap.get(guid).containsKey('Addon')){
                            priceItemAddonId.addAll(GuidToPI_AddonMap.get(guid).get('Addon'));
                        }
                        planAddonIDSet.addAll(priceItemAddonId);//Added by Aman Soni as a part of EDGE-138169
                        System.debug('planAddonIDSet-->'+planAddonIDSet);
                    }
                }

                if(!PI_AddonListMap.isEmpty() && PI_AddonListMap.containsKey('PriceItem')){
                    commercialProductList=new Set<String>(PI_AddonListMap.get('PriceItem'));
                }
                if(!PI_AddonListMap.isEmpty() && PI_AddonListMap.containsKey('Addon')){
                    addonList=new Set<String>(PI_AddonListMap.get('Addon'));
                }
                if(commercialProductList.size()>0){
                    DiscountLineItemsMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>(); 
                    Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap=new Map<String,List<cspmb__Discount_Level__c>>();
                    DiscountLevelMap=GetPriceSchedulevirtualClass.getApplicableDiscounts(commercialProductList,accountId,addonList);////updated for Edge-143527
                    Map<String,Promotion_Metadata__mdt> promotionMetadataMap=new Map<String,Promotion_Metadata__mdt>();
                    if(DiscountLevelMap!=null && DiscountLevelMap.size()>0){
                        for(String piId:discountLevelMap.keyset()){
                            for(cspmb__Discount_Level__c dl:discountLevelMap.get(piId)){
                                DL_businessIDList.add(dl.Business_ID__c); //// updated for Edge-143527
                            }
                        }
                        //DL_businessIDList.addAll( DiscountLevelMap.keyset()); 
                        system.debug('DL_businessIDList--->'+DL_businessIDList);
                        DL_businessIDList.add(businessIDMRO);// Added for MRO
                        if(DL_businessIDList!=null && !DL_businessIDList.isEmpty()){
                            promotionMetadataMap=GetPriceSchedulevirtualClass.fetchPromotionMetadata(DL_businessIDList);////updated for Edge-143527 
                        }
                        if(promotionMetadataMap.size()>0){
                            Map<String,List<String>> attributesTobeMappedMap=new Map<String,List<String>>();
                            //Laxmi - The check is applicable only for Deal Discounts hence below code is moved in Discount Level check                            
                            attributesTobeMappedMap=getattributesTobeMappedMap(promotionMetadataMap,DiscountLevelMap);
                            Map<String, Map<String,String>> attValueforAttributeTobeMaped=new Map<String, Map<String,String>>();
                            if(attributesTobeMappedMap.size()>0){
                                attValueforAttributeTobeMaped=getAttValueforAttributeTobeMaped(attributesTobeMappedMap,guidToAttMapofMap);
                            } //DiscountLevelMapcheck END
                            DiscountLineItemsMap=getDiscountLineItems(attValueforAttributeTobeMaped,promotionMetadataMap,DiscountLevelMap);
                            if(DiscountLineItemsMap!=null && DiscountLineItemsMap.size()>0){                                    
                                finalChargeLineItems=getChargeLineItems(GuidToPriceitemToCliMap,GuidToPI_AddonMap,DiscountLevelMap,attValueforAttributeTobeMaped);
                            } // Changes END--
                            //EDGE-127421 - Call MRO Method to process these two maps and get the final Maps
                        }
                    }
                    system.debug('DiscountLineItemsMap before MRO--->'+DiscountLineItemsMap+''+'finalChargeLineItems before MRO--->'+finalChargeLineItems);  
                    processMRO(guidToAttMapofMap,DiscountLineItemsMap,finalChargeLineItems);
                    system.debug('DiscountLineItemsMap after MRO--->'+DiscountLineItemsMap+''+'finalChargeLineItems after MRO--->'+finalChargeLineItems);                       
                     //Added by Aman Soni as a part of EDGE-138169 || Start
                     SetFieldsInMacScenario getFieldsOnDLIForBusID = new SetFieldsInMacScenario();
                     Map<String,List<Discount_Line_Item__c>> cliguidToDLIMap=getFieldsOnDLIForBusID.getExistingDiscountLevelList(guidSet);
                     system.debug('cliguidToDLIMap inside-->'+cliguidToDLIMap);
                     List<Discount_Line_Item__c> finalLst = new List<Discount_Line_Item__c>();
                     system.debug('guidSet-->'+guidSet);
                     if(cliguidToDLIMap!=null && !cliguidToDLIMap.isEmpty()){
                        for(String guid : guidSet){
                            for(String chargeId:planAddonIDSet){
                                if(DiscountLineItemsMap.containsKey(guid) && DiscountLineItemsMap.get(guid).containsKey(chargeId)){
                                    finalLst=getFieldsOnDLIForBusID.SetActionCodeOnDLIs(DiscountLineItemsMap.get(guid).get(chargeId),cliguidToDLIMap.get(guid));
                                    system.debug('finalLst after DLI update in case of Modify -->'+finalLst);
                                    DiscountLineItemsMap.get(guid).put(chargeId,finalLst); 
                                }                                         
                            }
                        }
                        system.debug('DiscountLineItemsMap after DLI update in case of Modify -->'+DiscountLineItemsMap);
                     }
                     //Added by Aman Soni as a part of EDGE-138169 || Start                      
                    if(finalChargeLineItems!=null && finalChargeLineItems.size()>0 && DiscountLineItemsMap!=null && !DiscountLineItemsMap.isEmpty()){
                        ComplexChargeDisountFactory chargeDiscountDML=new ComplexChargeDisountFactory();
                        chargeDiscountDML.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems);// updated by shubhi as the method got renamed Edge-133963
                        DiscountApplicableStatus='Discount Applicable';
                        ApplicableGuidList.addAll(finalChargeLineItems.keySet());
                        notApplicableGuidList.addAll(fetchNotapplicableDiscounts(AllGuidList,ApplicableGuidList,selectPlanBlankList));//Added by Shubhi as a part of EDGE-142527
                        GetPriceSchedulevirtualClass.publishEventRequest(correlationId,solutionName,basketNum,false);////updated for Edge-143527 
                    }else{
                        notApplicableGuidList.addAll(fetchNotapplicableDiscounts(AllGuidList,ApplicableGuidList,selectPlanBlankList));//Added by Shubhi as a part of EDGE-142527
                        DiscountApplicableStatus='No discount applicable';
                    }        
                }else{
                    notApplicableGuidList.addAll(fetchNotapplicableDiscounts(AllGuidList,ApplicableGuidList,selectPlanBlankList));//Added by Shubhi as a part of EDGE-142527
                    system.debug('notApplicableGuidList---->'+notApplicableGuidList);   
                    DiscountApplicableStatus='No discount applicable';
                }      
            }else{
                 notApplicableGuidList.addAll(fetchNotapplicableDiscounts(AllGuidList,ApplicableGuidList,selectPlanBlankList));//Added by Shubhi as a part of EDGE-142527

                DiscountApplicableStatus='No discount applicable';
            }   
                                    
        }else{
            DiscountApplicableStatus='Initial';
        }
    }
    else{
        DiscountApplicableStatus='Already triggered';
    }     
    system.debug('---DiscountApplicableStatus-->'+DiscountApplicableStatus);        
   }
        /*method to fetch mobile subscription priceitem salesforce id Edge-127073*/
        /*Shubhi*/
       public Map<String,List<String>> getCommercialProductList(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basketID){//updated for Edge-143527
            Map<String,List<String>> PI_AddonListMap=new Map<String,List<String>>();
            List<String> commercialProductList=new List<String>();
            List<Charge_Line_Item__c> existingIDDChargeItemList=new List<Charge_Line_Item__c>();// Added as Part of EDGE-123594
            List<String> AddonList=new List<String>();
            GuidToPI_AddonMap=new Map<String, Map<String,List<String>>>();
            GuidToPriceitemToCliMap=new Map<String,Map<String,Charge_Line_Item__c>>();
            SolutionDTO.Configurations selectedConfig=new SolutionDTO.Configurations();
            solutionToGuidMap=new Map<String,SolutionDTO>();
            selectPlanBlankList=new Set<String>();
             //Added as part of EDGE-123594 by ankit ||start 
            Map<String,Charge_Line_Item__c> existingChargeLineItemMap=new  Map<String,Charge_Line_Item__c>();
            Set<String> addonGuidNew=new Set<String>();
            if(!guidToAttMapofMap.isEmpty()){
                addonGuidNew.addAll(guidToAttMapofMap.keySet());
                if(!addonGuidNew.isEmpty() && basketID != null && String.isNotBlank(basketID)){
                    ChargeDiscountQueryUtility DisCharge=new ChargeDiscountQueryUtility ();
                    existingChargeLineItemMap=DisCharge.fetchChargeLineItemForStatus(addonGuidNew,basketID);
                }
                //Added as part of EDGE-123594 by ankit ||End 
                for(String guid:guidToAttMapofMap.keySet()){
                    AllGuidList.add(guid);
                    Map<String,SolutionDTO.Attributes> AttMap=guidToAttMapofMap.get(guid);
                    system.debug('Attribute map'+Attmap);
                    if(AttMap.size()>0){
                        Map<String,Charge_Line_Item__c>  PriceItemToCliMap=new Map<String,Charge_Line_Item__c>(); 
                        Map<String,List<String>> PI_AddonMap=new Map<String,List<String>>();    //priceitem/addonmap 
                        //for(SolutionDTO.Attributes att: config.attributes.key){
                        integer discountedPrice = 0;                            
                            if(AttMap.containsKey('IsDiscountCheckNeeded') && AttMap.get('IsDiscountCheckNeeded').value=='true' 
                               && (AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value!='Active' && AttMap.get('ChangeType').value!='Cancel')) // Added for EDGE-131531 CLIs should not be generated when status is active or Cancel
                             {
                                Charge_Line_Item__c cliAddon=new Charge_Line_Item__c();
                                Charge_Line_Item__c cliPI=new Charge_Line_Item__c();
                                cliPI.basketId__c=basketID;                      
                                cliPI.solutionId__c=solutionID;
                                cliPI.componentName__c=SolutionName;
                                cliPI.guid__c=guid;   
                                cliPI.CorrelationId__c=correlationId;
                                cliPI.Quantity__c=1;
                                cliPI.status__c = 'New';//Added by Aman Soni as a part of EDGE-135278
                                cliAddon.basketId__c=basketID;                      
                                cliAddon.solutionId__c=solutionID;
                                cliAddon.componentName__c=SolutionName;
                                cliAddon.guid__c=guid;   
                                cliAddon.CorrelationId__c=correlationId;
                                cliAddon.Quantity__c=1;
                                cliAddon.status__c = 'New';//Added by Aman Soni as a part of EDGE-135278
                                
                                //Added by Aman Soni as a part of EDGE-135278 || Start
                                if(AttMap.containsKey('BillingAccountNumber') && !String.isBlank(AttMap.get('BillingAccountNumber').value) && AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value=='Modify'){
                                    cliPI.billingAccountNumber__c=AttMap.get('BillingAccountNumber').value;
                                    cliAddon.billingAccountNumber__c=AttMap.get('BillingAccountNumber').value;
                                }
                                //Added by Aman Soni as a part of EDGE-135278 || End
                                
                                //Added As part of EDGE-123594 by ankit || Modified by Aman Soni as a part of EDGE-138169 || Start
                                    if(AttMap.containsKey('initialActivationDate')&& !String.isBlank(AttMap.get('initialActivationDate').value)){
                                        cliPI.originalActivationDate__c=Date.valueof(AttMap.get('initialActivationDate').value);
                                        cliAddon.originalActivationDate__c=Date.valueof(AttMap.get('initialActivationDate').value);
                                        system.debug('initialActivationDate on plan CLI-->'+ cliPI.originalActivationDate__c+''+'initialActivationDate on addon CLI-->'+cliAddon.originalActivationDate__c);
                                    }
                                //Added As part of EDGE-123594 || Modified by Aman Soni as a part of EDGE-138169 || End
                                
                                if(AttMap.containsKey(commercialProductIdentifier)){  
                                    if(!String.isBlank(AttMap.get(commercialProductIdentifier).value)){
                                        //solutionToGuidMap.put(guid,sol);
                                        List<String> PI_AddonList=new List<String>();
                                        if(PI_AddonMap.containsKey('PriceItem')){
                                            PI_AddonList.addAll(PI_AddonMap.get('PriceItem'));
                                        }
                                        PI_AddonList.add(AttMap.get(commercialProductIdentifier).value);
                                        PI_AddonMap.put('PriceItem',PI_AddonList);
                                        commercialProductList.add(AttMap.get(commercialProductIdentifier).value);
                                        cliPI.commercialProductId__c=AttMap.get(commercialProductIdentifier).value;
                                        cliPI.Product_Charge_Identifier__c='Price Item';
                                        // Laxmi - Added for EDGE-132685 
                                        cliPI.targetChargeProduct__c = 'Plan';
                                        PriceItemToCliMap.put(AttMap.get(commercialProductIdentifier).value,cliPI);
                                    }else{
                                        selectPlanBlankList.add(guid);
                                        break;
                                    }
                                   //Added As part of EDGE-123594 by ankit || Start
                                    if(existingChargeLineItemMap.containsKey(guid)){
                                        if(AttMap.containsKey('IDD Charge') && (String.isBlank(AttMap.get('IDD Charge').value) || AttMap.get('IDD Charge').value =='0')){
                                            existingChargeLineItemMap.get(guid).status__c ='Cancelled';
                                        }
                                        existingIDDChargeItemList.add(existingChargeLineItemMap.get(guid));
                                    }
                                     //Added As part of EDGE-123594 || End
                                    if(AttMap.containsKey('IDD Charge') && !String.isBlank(AttMap.get('IDD Charge').value) && AttMap.get('IDD Charge').value!='0' && AttMap.containsKey(AddOnIdentifier) &&  !String.isBlank(AttMap.get(AddOnIdentifier).value)){
                                        cliAddon.unitPrice__c=Decimal.valueof(AttMap.get('IDD Charge').value);
                                        //cliAddon.status__c=''; //Added As part of EDGE-123594
                                        List<String> PI_AddonList=new List<String>();
                                        if(PI_AddonMap.containsKey('Addon')){
                                            PI_AddonList.addAll(PI_AddonMap.get('Addon'));
                                        }
                                        PI_AddonList.add(AttMap.get(AddOnIdentifier).value);
                                        PI_AddonMap.put('Addon',PI_AddonList);
                                        AddonList.add(AttMap.get(AddOnIdentifier).value);
                                        cliAddon.commercialProductId__c=AttMap.get(AddOnIdentifier).value;
                                        cliAddon.Product_Charge_Identifier__c='AddOn';
                                        //Laxmi Added for EDGE-132685 
                                        cliAddon.targetChargeProduct__c = 'AddOn';                                   
                                        PriceItemToCliMap.put(AttMap.get(AddOnIdentifier).value,cliAddon);
                                        if(AttMap.containsKey('BussinessId_Addon')&&  !String.isBlank(AttMap.get('BussinessId_Addon').value)){
                                            cliAddon.BusinessID__c=AttMap.get('BussinessId_Addon').value;
                                            //Laxmi - Added for EDGE-132685 getting the charge type One Off, Recurring, Tiered Base
                                            cliAddon.chargeType__c = Constants.getChargeType(cliAddon.BusinessID__c);
                                        }
                                    }
                                    if(AttMap.containsKey('RC')&& !String.isBlank(AttMap.get('RC').value)){
                                        cliPI.unitPrice__c=Decimal.valueof(AttMap.get('RC').value);
                                    }
                                     
                                    if(AttMap.containsKey('BussinessId_PI')&&  !String.isBlank(AttMap.get('BussinessId_PI').value)){
                                        cliPI.BusinessID__c=AttMap.get('BussinessId_PI').value;
                                        //Laxmi - Added for EDGE-132685 getting the charge type One Off, Recurring, Tiered Base
                                        cliPI.chargeType__c = Constants.getChargeType(cliPI.BusinessID__c);
                                    }
                                    if(AttMap.containsKey('RemainingTerm') && !String.isBlank(AttMap.get('RemainingTerm').value) && AttMap.get('RemainingTerm').value!='0'){
                                        cliAddon.contractTerm__c=Integer.valueof(AttMap.get('RemainingTerm').value);
                                        cliPI.contractTerm__c=Integer.valueof(AttMap.get('RemainingTerm').value);
                                    }else{
                                        cliAddon.contractTerm__c=24;
                                        cliPI.contractTerm__c=24;
                                    }
                                }
                            }else{ 
                                if((AttMap.containsKey('IDDShadowTCV') && !String.isBlank(AttMap.get('IDDShadowTCV').value)) || (AttMap.containsKey('PlanShadowTCV') && !String.isBlank(AttMap.get('PlanShadowTCV').value))){
                                    ApplicableGuidList.add(guid);
                                }       
                            }
                        if(!PI_AddonMap.isEmpty())
                        GuidToPI_AddonMap.put(guid,PI_AddonMap);
                        system.debug('GuidToPI_AddonMap'+GuidToPI_AddonMap);
                        if(!PriceItemToCliMap.isEmpty())
                        GuidToPriceitemToCliMap.put(guid,PriceItemToCliMap);
                    }
                }
            }
            //Added As part of EDGE-123594 by ankit || Start
            if(!existingIDDChargeItemList.isEmpty()){
                ComplexChargeDisountFactory cdf=new ComplexChargeDisountFactory();
                cdf.updateChargeLineItem(existingIDDChargeItemList);
            }
            //Added As part of EDGE-123594 by ankit || End
            if(!commercialProductList.isEmpty()){
                PI_AddonListMap.put('PriceItem',commercialProductList);
            }
            if(!AddonList.isEmpty()){
                PI_AddonListMap.put('Addon',AddonList);
            }
            return PI_AddonListMap;
        }
      
        /* method to get attribute to mapped list corresponding to guid Edge-   127073*/ /*Shubhi*/
        public Map<String,List<String>> getattributesTobeMappedMap(Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap){
            Map<String,List<String>> attributesTobeMappedMap=new Map<String,List<String>>();
            if(GuidToPI_AddonMap.size()>0){
                for(String guid:GuidToPI_AddonMap.keyset()){
                    List<string> priceItemList=new List<String>();
                    if(GuidToPI_AddonMap.get(guid).containskey('PriceItem')){
                        priceItemList.addAll(GuidToPI_AddonMap.get(guid).get('PriceItem'));
                    }
                    if(GuidToPI_AddonMap.get(guid).containskey('Addon')){
                        priceItemList.addAll(GuidToPI_AddonMap.get(guid).get('Addon'));
                    }
                    List<String> attributeList=new List<String>();
                    for(String PriceitemId:priceItemList){
                        List<cspmb__Discount_Level__c> discountLevelList=new List<cspmb__Discount_Level__c>();
                        if(DiscountLevelMap.containskey(PriceitemId)){
                            discountLevelList.addAll(DiscountLevelMap.get(PriceitemId));
                            for(cspmb__Discount_Level__c dl:discountLevelList){
                                if(promotionMetadataMap.containskey(dl.Business_ID__c)){
                                    Promotion_Metadata__mdt pm=promotionMetadataMap.get(dl.Business_ID__c);
                                    if(pm.ReferenceObject__c!=null || pm.ReferenceAttribute__c!=null ){
                                     //Added As part of EDGE-123594 by ankit || Start
                                    system.debug('@@ReferenceAttribute__c@@--->'+pm.ReferenceAttribute__c);
                                    list<String> RefrenceAttribute=pm.ReferenceAttribute__c.split(',');
                                     for(String FrAttr:RefrenceAttribute){
                                     //Added As part of EDGE-123594 by ankit || end
                                        attributeList.add(FrAttr);
                                       }
                                    }
                                }
                            }
                        }
                    }
                    if(!attributeList.isEmpty()){
                        attributesTobeMappedMap.put(guid,attributeList);
                    }
                }
            }
            return attributesTobeMappedMap;
        }
        /* method to get attribute value to mapped list corresponding to att to guid Edge-127073*/ /*Shubhi*/
        public Map<String, Map<String,String>> getAttValueforAttributeTobeMaped(Map<String,List<String>> attributesTobeMappedMap,Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap){//updated for Edge-143527 added guidToAttMapofMap
            Map<String, Map<String,String>> attValueforAttributeTobeMaped =new Map<String, Map<String,String>>();
            if(GuidToPI_AddonMap.size()>0){
                for(String guid:attributesTobeMappedMap.keyset()){
                    if(guidToAttMapofMap!=null && guidToAttMapofMap.size()>0){
                        Map<String,String> attTovalueMap=new Map<String,String>();
                            if(guidToAttMapofMap.containskey(guid)){
                                if(!guidToAttMapofMap.get(guid).values().isEmpty()){                              
                                    for(SolutionDTO.Attributes att:guidToAttMapofMap.get(guid).values()){
                                        if(attributesTobeMappedMap.get(guid).contains(att.name) && String.isNotBlank(att.value)){
                                            attTovalueMap.put(att.name,att.value);
                                        }
                                    }
                                }
                            }
                        if(!attTovalueMap.isempty()){
                            attValueforAttributeTobeMaped.put(guid,attTovalueMap);
                        }
                    }
                }
            }
            return attValueforAttributeTobeMaped;
        }
        /* method to get eligible discounts to mapped list corresponding to guid Edge-127073*/ /*Shubhi*/
        public Map<String, Map<String,List<Discount_Line_Item__c>>> getDiscountLineItems(Map<String, Map<String,String>> attValueforAttributeTobeMaped,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap){
            //Added by Laxmi for EDGE-135885
            //Get the Feature toggle value for Populate Discount Class - if thats true then assign the hardcoded values for this field
            //When Napier team is ready with these changes this value will be false and the values to be assigned will come from Napier Team
           Feature_Flag__mdt featureFlag_Mdt= FeatureFlagUtility.getFeatureTogglingByName('Populate_Discount');
            
           boolean featureFlag = false;
           if (featureFlag_Mdt!= null)
           {
               //system.debug ('@@@@@@@@@featureFlag'+ featureFlag);
               featureFlag = featureFlag_Mdt.IsActive__c;
           }
            //Changes End      
            Map<String, Map<String,List<Discount_Line_Item__c>>> guidToEligibleDLIMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>();
      
           if(GuidToPI_AddonMap!=null && GuidToPI_AddonMap.size()>0){
                for(String guid:GuidToPI_AddonMap.keyset()){
                    List<string> priceItemList=new List<String>();//list of priceitem and addon
                    Map<String,String> attributeToValueMap=new Map<String,String>();
                    if(attValueforAttributeTobeMaped.size()>0 && attValueforAttributeTobeMaped.containsKey(guid)){
                        attributeToValueMap=attValueforAttributeTobeMaped.get(guid);
                    }
                    system.debug('attributeToValueMap---->'+attributeToValueMap);
                    if(GuidToPI_AddonMap.get(guid).containskey('PriceItem')){
                        priceItemList.addAll(GuidToPI_AddonMap.get(guid).get('PriceItem'));
                    }
                    if(GuidToPI_AddonMap.get(guid).containskey('Addon')){
                        priceItemList.addAll(GuidToPI_AddonMap.get(guid).get('Addon'));
                    }
                    Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();
                    for(String PriceitemId:priceItemList){
                        List<cspmb__Discount_Level__c> discountLevelList=new List<cspmb__Discount_Level__c>();
                        if(DiscountLevelMap.containskey(PriceitemId)){
                            discountLevelList.addAll(DiscountLevelMap.get(PriceitemId));
                            system.debug('discountLevelList--->'+discountLevelList);
                            //added As part of EDGE-123594
                            GetDiscountEligiblityClass EllClass= new GetDiscountEligiblityClass();
                            List<cspmb__Discount_Level__c>EligiblediscountLevelList=EllClass.EligibleDiscountList(discountLevelList,promotionMetadataMap,attributeToValueMap);                        
                            system.debug('EligiblediscountLevelList--->'+EligiblediscountLevelList); //Added by Aman Soni as a part of EDGE-135278                       
                            List<Discount_Line_Item__c> dislevellist=new List<Discount_Line_Item__c>();
                            for(cspmb__Discount_Level__c dl:EligiblediscountLevelList){                         
                                if(promotionMetadataMap.containskey(dl.Business_ID__c)){
                                    Discount_Line_Item__c dli=new Discount_Line_Item__c();
                                    dli.BusinessID__c=dl.Business_ID__c;
                                    dli.description__c=dl.Description__c;
                                    dli.discountType__c=dl.cspmb__Discount_Type__c;
                                    dli.discountValue__c=String.valueOf(dl.cspmb__Discount__c);
                                    dli.duration__c=String.valueOf(dl.cspmb__duration__c);
                                    dli.durationUoM__c='Months';
                                    dli.Priority__c=1;
                                    dli.name=dl.name;
                                    dli.actionCode__c='New';//Added by Aman Soni as a part of EDGE-135278 || EDGE-138169                                    
                                    dli.isUnlimited__c=dl.is_Unlimited__c;//Added by Laxmi for EDGE-132685                                    
                                    dli.discountEndDate__c=dl.Effective_End_Date__c;//Added by Laxmi for EDGE-135885                                    
                                    if (featureFlag) ////featureFlag = false if data come from Napier else featureFlag = true to create own data
                                    // the DLI will have static values
                                    {
                                        if ((dl.Business_ID__c == 'DMCAT_Discount_000951') || (dl.Business_ID__c == 'DMCAT_Discount_000953') )
                                        {
                                            dli.discountClass__c = 'Percent';
                                            dli.discountValue__c ='100';
                                        }
                                        else {
                                            dli.discountClass__c = dl.cspmb__Discount_Type__c;
                                        }
                                            
                                    }else
                                    {
                                        dli.discountClass__c = dl.discountClass__c;
                                    }   
                                     
                                    //Changes End by Laxmi for EDGE-135885                  
                                    
                                    Promotion_Metadata__mdt pm=promotionMetadataMap.get(dl.Business_ID__c);
                                    if(priceitemToeligibleDLMap.containsKey(PriceitemId)){
                                        dislevellist.addall(priceitemToeligibleDLMap.get(PriceitemId));
                                    }
                                     dislevellist.add(dli);
                                    
                                }   
                            }
                             system.debug('dislevellist--->'+dislevellist);
                            if(dislevellist!=null && dislevellist.size()>0){ //added check for prod incident EDGE-141476
                              priceitemToeligibleDLMap.put(PriceitemId,dislevellist); 
                              }
                            }
                        }
                        if(!priceitemToeligibleDLMap.isEmpty()){                    
                        guidToEligibleDLIMap.put(guid,priceitemToeligibleDLMap);
                        }
                    }
                }
              
            return guidToEligibleDLIMap;
       }
                
        /* method to get eligible chargeLine items */
        public Map<String, Map<String,Charge_Line_Item__c>> getChargeLineItems(Map<String,Map<String,Charge_Line_Item__c>> GuidToPriceitemToCliMap,Map<String, Map<String,List<String>>> GuidToPI_AddonMap,Map<String,List<cspmb__Discount_Level__c>> DiscountLevelMap,Map<String, Map<String,String>> attValueforAttributeTobeMaped){
            Map<String, Map<String,Charge_Line_Item__c>> getEligibleChargeLineItem=new Map<String, Map<String,Charge_Line_Item__c>>();
            if(GuidToPI_AddonMap.size()>0){
                for(String guid:GuidToPI_AddonMap.keyset()){
                    List<string> priceItemList=new List<String>();
        
                    Map<String,Charge_Line_Item__c> pITOCLiMap=new Map<String,Charge_Line_Item__c>();
                    if(GuidToPriceitemToCliMap.containsKey(guid)){
                        for(String piId:GuidToPriceitemToCliMap.get(guid).keyset()){
            if(DiscountLineItemsMap!=null && DiscountLineItemsMap.size()>0 && DiscountLineItemsMap.containskey(guid) && DiscountLineItemsMap.get(guid)!=null && DiscountLineItemsMap.get(guid).containskey(piId))//Added by Shubhi as a part of EDGE-143527                            {
                        {       
                              system.debug('inside cli');
                            Charge_Line_Item__c cli=GuidToPriceitemToCliMap.get(guid).get(piId);
                                pITOCLiMap.put(piId,cli);
                            }
                        }
                    }
                    if(!pITOCLiMap.isEmpty()){
                        getEligibleChargeLineItem.put(guid,pITOCLiMap);
                    }
                }
            }
            return getEligibleChargeLineItem;
        }       
        /*method for remote action call*/
       /// added by shubhi  method to fetch Not applicable Discounts//
        public Set<String> fetchNotapplicableDiscounts(Set<String> Allguids, Set<String> Allapplicableguids, Set<string> blankSelectPlanGuids){
            system.debug('Allguids-->'+Allguids+''+'Allapplicableguids-->'+''+Allapplicableguids+'blankSelectPlanGuids-->'+''+blankSelectPlanGuids);
            Set<String> notapplicableGuidList=new Set<String>();
            Set<String> guidsTobeRemoved=new Set<String>();
            guidsTobeRemoved.addAll(Allapplicableguids);
            guidsTobeRemoved.addAll(blankSelectPlanGuids);
            if(Allguids!=null && Allapplicableguids!=null && Allapplicableguids.size()==Allguids.size()){
                return notapplicableGuidList;
            }
            for(String guid:Allguids){
                if(guidsTobeRemoved.size()>0 && !guidsTobeRemoved.contains(guid)){
                    notapplicableGuidList.add(guid);
                }               
            }
            if(guidsTobeRemoved.isEmpty()){
                return Allguids;
            }
            return Allguids;
        }
        
     /******************************************************************************
     * Author : Laxmi Rahate: EDGE-127421
     * Date : 12/Nov/2020
     * Description : This method gets the CLI and DLI for MRO based on teh condition that TotalBonus for the config is 
     * greater than Zero and Customer doesnt have OneFund Option. 
     * Then this Method compares the final Maps and if CLI is already then it doesnt create the CLI just creates the DLI.
     * DLI will be in any case created provided the Total Bonus and One Fund Criteria is satisfied
     * Parameter : Solution DTO and Final Maps
     * *******************************************************************************/
            public void processMRO( Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,Map<String, Map<String,List<Discount_Line_Item__c>>> discountEligibleMap, Map<String, Map<String,Charge_Line_Item__c>> nonMROChargeline){
                //updated for Edge-143527 added guidToAttMapofMap
            Map<String,Charge_Line_Item__c> pITOCLiMap;
            List<Discount_Line_Item__c> disLineItemListChk;
            List<Discount_Line_Item__c> disLineItemList;
            Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();
            Charge_Line_Item__c cliPI;
            Discount_Line_Item__c  dliPI;
            String isPaymentTypeOneFund = 'false'; // Added for FDR FIX setting to false by default

            //Taken out from For Loop by Aman Soni as a part of EDGE-143527 || Start
            String PatternValue=''; 
            Set<String> businessIDList = new Set<String>();
                Map<String,Promotion_Metadata__mdt> promoMetadataMap=new Map<String,Promotion_Metadata__mdt>();
                businessIDList.add (businessIDMRO);
                if(businessIDList.size() > 0)
                    promoMetadataMap=GetPriceSchedulevirtualClass.fetchPromotionMetadata(businessIDList);
                if(promoMetadataMap.containsKey(businessIDMRO)){
                    PatternValue=promoMetadataMap.get(businessIDMRO).Eligibility_Pattern__c;
                }
            //Taken out from For Loop by Aman Soni as a part of EDGE-143527 || End
            system.debug('guidToAttMapofMap.keyset()-->'+guidToAttMapofMap.keyset());
            if(!guidToAttMapofMap.isEmpty()){
                for(String guid:guidToAttMapofMap.keyset()){
                    disLineItemList =new List<Discount_Line_Item__c>();
                    Map<String,SolutionDTO.Attributes> AttMap=guidToAttMapofMap.get(guid);
                    system.debug('IsDiscountCheckNeeded::'+AttMap.get('IsDiscountCheckNeeded')+' && '+'TotalPlanBonus::'+AttMap.get('TotalPlanBonus')+' && '+'isPaymentTypeOneFund::'+AttMap.get('isPaymentTypeOneFund'));                
                    if(AttMap!= null && AttMap.size()>0){
                        
                        // Laxmi - SR no 10 - Fixed issue - An observation
                            if (AttMap.containsKey('isPaymentTypeOneFund') && String.isNotBlank (AttMap.get('isPaymentTypeOneFund').value ) ){
                           isPaymentTypeOneFund =  AttMap.get('isPaymentTypeOneFund').value ;
                        }
                     // FIX END
                        /*****Check if the  isPaymentTypeOneFund is false and TotalPlanBonus > 0***/
                        if ((AttMap.containsKey('IsDiscountCheckNeeded') && AttMap.get('IsDiscountCheckNeeded').value=='true') 
                             && isPaymentTypeOneFund =='false' && (AttMap.containsKey('TotalPlanBonus') && AttMap.get('TotalPlanBonus').value!='' && Decimal.valueOf(AttMap.get('TotalPlanBonus').value)>0 && promoMetadataMap.containskey(businessIDMRO) && PatternValue=='Pattern F') && (AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value!='Active' && AttMap.get('ChangeType').value!='Cancel')   
                           )// Laxmi Added for EDGE-131531 not to create cli when Action is cancel and Active
                           {
                               System.debug ('Meets the Criteria');
                               cliPI=new Charge_Line_Item__c();
                               dliPI = new Discount_Line_Item__c ();                            
                               cliPI.solutionId__c=solutionID;
                               cliPI.componentName__c=solutionName;
                               cliPI.guid__c=guid;   
                               cliPI.CorrelationId__c=correlationId; 
                               cliPI.Quantity__c=1;
                               cliPI.basketId__c=basketID;  
                               cliPI.status__c='New';//Added by Aman Soni as a part of EDGE-138169
                               //commercialProductIdentifier - has Value as 'Select Plan' - 
                               //below condition gets the value of Select Plan - salesforce ID of the CommercialProduct
                               if(AttMap.containsKey(commercialProductIdentifier)){ 
                                   if(!String.isBlank(AttMap.get(commercialProductIdentifier).value)){
                                       cliPI.commercialProductId__c=AttMap.get(commercialProductIdentifier).value;
                                       cliPI.Product_Charge_Identifier__c='Price Item';
                                       cliPI.targetChargeProduct__c = 'Plan';
                                       if(AttMap.containsKey('RC')&& !String.isBlank(AttMap.get('RC').value)){
                                           cliPI.unitPrice__c=Decimal.valueof(AttMap.get('RC').value);
                                     }
                                       if(AttMap.containsKey('BussinessId_PI')&&  !String.isBlank(AttMap.get('BussinessId_PI').value)){
                                           cliPI.BusinessID__c=AttMap.get('BussinessId_PI').value;
                                           cliPI.chargeType__c = Constants.getChargeType(cliPI.BusinessID__c);
                                       }
                                       if(AttMap.containsKey('RemainingTerm') && !String.isBlank(AttMap.get('RemainingTerm').value) && AttMap.get('RemainingTerm').value!='0'){
                                           cliPI.contractTerm__c=Integer.valueof(AttMap.get('RemainingTerm').value);
                                       }else{
                                           cliPI.contractTerm__c=24;
                                       }
                                   }
                                   //Add code here to check if the CLI is already there in the NON MRO CLI MAP 
                                   if(AttMap.containsKey('deviceTypeBusinessID')&&  !String.isBlank(AttMap.get('deviceTypeBusinessID').value)){
                                       dliPI.BusinessID__c=AttMap.get('deviceTypeBusinessID').value;
                                   }
                                   
                                     //Added by Aman Soni as a part of EDGE-135278 || Start
                                    if(AttMap.containsKey('BillingAccountNumber') && !String.isBlank(AttMap.get('BillingAccountNumber').value) && AttMap.containsKey('ChangeType') && AttMap.get('ChangeType').value=='Modify'){
                                        cliPI.billingAccountNumber__c=AttMap.get('BillingAccountNumber').value;
                                    }
                                    if(AttMap.containsKey('initialActivationDate')&& !String.isBlank(AttMap.get('initialActivationDate').value)){
                                    cliPI.originalActivationDate__c=Date.valueof(AttMap.get('initialActivationDate').value);
                                    }
                                    //Added by Aman Soni as a part of EDGE-138169 || End
                                
                                   dliPI.description__c=Constants.MRO_DISCOUNT_DESC;
                                   dliPI.name = Constants.MRO_DISCOUNT_NAME;
                                   dliPI.discountType__c= Constants.DISCOUNT_TYPE;
                                   dliPI.discountValue__c=String.valueOf(AttMap.get('TotalPlanBonus').value);
                                   dliPI.duration__c=Constants.DURATION;
                                   dliPI.durationUoM__c=Constants.DURATION_Months;
                                   dliPI.Priority__c=1;
                                   dliPI.actionCode__c= 'New';
                                   dliPI.discountClass__c = 'Amount';//Added by Aman Soni as a part of EDGE-138169
                                   disLineItemList.add(dliPI);
                                   // Add COde here to check if the Price Item Record is there 
                                   // NON MRO DIscount Map, if its there insert the DLI in that List
                               if (discountEligibleMap != null && discountEligibleMap.size ()>0) {
                                   priceitemToeligibleDLMap = discountEligibleMap.get(guid);
                                   system.debug('priceitemToeligibleDLMap111'+priceitemToeligibleDLMap);
                               }
                               if (priceitemToeligibleDLMap!=null && priceitemToeligibleDLMap.size ()>0)
                                   {
                                       if (priceitemToeligibleDLMap!=null && priceitemToeligibleDLMap.containsKey(cliPI.commercialProductId__c))
                                       {
                                           disLineItemListChk = priceitemToeligibleDLMap.get(cliPI.commercialProductId__c);
                                           disLineItemListChk.add (dliPI);
                                           priceitemToeligibleDLMap.put(cliPI.commercialProductId__c,disLineItemListChk);
                                            system.debug('priceitemToeligibleDLMap222'+priceitemToeligibleDLMap);
                                       }
                                   } //Else create add the disLineItemList in the Map aagainst the commercial Product ID 
                                   else
                                   {
                                       system.debug('priceitemToeligibleDLMap333'+priceitemToeligibleDLMap);
                                       priceitemToeligibleDLMap = new Map<String,List<Discount_Line_Item__c>>();
                                       priceitemToeligibleDLMap.put(cliPI.commercialProductId__c,disLineItemList);
                                       system.debug('priceitemToeligibleDLMap444'+priceitemToeligibleDLMap);
                                   }
                                   if (priceitemToeligibleDLMap!=null){
                                       DiscountLineItemsMap.put(guid,priceitemToeligibleDLMap);
                                   }
                                   if (nonMROChargeline!= null && nonMROChargeline.size()>0){
                                       pITOCLiMap = nonMROChargeline.get(guid);
                                       //Check if the final CHarge LIne Item conatains the CLI which is being processed in the current config
                                       //IF exists dont add it in list else add
                                       if ( pITOCLiMap!=null && pITOCLiMap.containsKey (cliPI.commercialProductId__c))  {
                                           //System.debug ('@@@ Cli already exists in the Final Charge Line Item no processinf Needed');
                                       }else
                                       {
                                           System.debug ('@@@ Cli exists But not for the selected plan hence creating new CLI!!!');
                                           pITOCLiMap = new Map<String,Charge_Line_Item__c> ();
                                           pITOCLiMap.put (cliPI.commercialProductId__c,cliPI);  
                                           finalChargeLineItems.put(guid,pITOCLiMap); 
                                       }
                                       
                                   }
                                   else
                                   {
                                        System.debug('@@@ NON MRO Charge Line Map was Null hence creating new CLi!!'+finalChargeLineItems);
                                        if(finalChargeLineItems == null){//Added for CLI fix || Single CLI Fix is getting created for multiple MRO Configs || Aman Soni
                                            finalChargeLineItems = new Map<String, Map<String,Charge_Line_Item__c>>();
                                        }
                                        pITOCLiMap = new Map<String,Charge_Line_Item__c>();
                                        pITOCLiMap.put(cliPI.commercialProductId__c,cliPI);                                         
                                        if(pITOCLiMap != null && pITOCLiMap.size()>0 && !String.isBlank(guid)){
                                        finalChargeLineItems.put(guid,pITOCLiMap);
                                        System.debug('finalChargeLineItems in MRO Only'+finalChargeLineItems);  
                                       }
                                   }
                               } //if attMap containsKey end
                           }// end Attmap check
                    }
                }           
            }
        } //Method END ProcessMRO                
}