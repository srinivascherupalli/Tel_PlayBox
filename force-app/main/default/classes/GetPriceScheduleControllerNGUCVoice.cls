/*
* @Author : Gnana
* @Date : 25 Feb 2019
* @Desc : GetPriceScheduleControllerNGUCVoice
* @Jira : Edge-133963 && edge-121376 new component
* 1           shubhi              30/3/2020   EDGE-140157
2.            Shubhi            7/4/2020 EDGE-143957
* @TestClass : GetPriceScheduleControllerNGUCVoiceTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.          shubhi          14/4/2020       Edge-143527 new approach for solutionjson
2.         shubhi          20/4/2020 		EDGE-145152  Tech debt
3. 		Shubhi 				23/04/2020      Edge-120919
4. 		Shubhi				22/5/2020		EDGE-146184
===============================================================================================================================
*/
public with sharing class GetPriceScheduleControllerNGUCVoice extends GetPriceSchedulevirtualClass{
    // upadetd for 
    public set<String> CLIbusinessIdSet {get; set;} //edge-121376
    public String DiscountApplicableStatus {get; set;}
    public Set<String> notApplicableGuidList {get; set;}
    public string solutionID {get; set;}
    public String correlationId {get; set;}
    public void onLoadMethod(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basketId,String accountId,String solID,String IsDiscountCheckNeeded,String solutionName,String basketNum,String correlId){ ////Edge-143527 added method params for remote call
        //IsDiscountCheckNeeded=IsDiscountCheckNeededparam;
        system.debug('Inside Onload IsDiscountCheckNeeded--->'+IsDiscountCheckNeeded);   
        solutionId=solID;
        DiscountApplicableStatus='Initial';
        if(IsDiscountCheckNeeded=='true'){   
            List<SolutionDTO> solutionDTO;
            if(String.isNotBlank(solutionID)){                
                //Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap = GetPriceSchedulevirtualClass.getguidToAttMapofMap(solutionId,solutionName);
                system.debug('@@@guidToAttMapofMap@@@'+guidToAttMapofMap);
                correlationId=correlId; 
                if(guidToAttMapofMap!=null && !guidToAttMapofMap.isEmpty()&& !String.isBlank(basketID) && !String.isBlank(solutionName)){//Edge-143527
                    Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap = getCommercialProductCLIMap(guidToAttMapofMap,basketID,solutionName);
                    set<string> guidset=commercialProductCLIMap.keyset();
                    Set<String> chargeIDSet=new Set<string>();
                    if(commercialProductCLIMap.size()>0){
                        chargeIDSet=GetPriceSchedulevirtualClass.getChargeIds(commercialProductCLIMap);
                        List<cspmb__Discount_Level__c> discountLevelList=getApplicableDiscounts(DiscountConstants.VoicePromoBUSINESSIDset);
                        System.debug('discountLevelList...'+discountLevelList);
                        if(discountLevelList != null && discountLevelList.size()>0){
                            Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap=getDiscountLineItems(discountLevelList,guidset,chargeIDSet);
                            System.debug('DiscountLineItemsMap...'+DiscountLineItemsMap.values());
                            Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems=commercialProductCLIMap;
                            System.debug('finalChargeLineItems...'+finalChargeLineItems.values());
                            if(finalChargeLineItems.size()>0){
                                ComplexChargeDisountFactory chargeDiscountDML=new ComplexChargeDisountFactory();
                                chargeDiscountDML.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems);
                                GetPriceSchedulevirtualClass.publishEventRequest(correlationId,solutionName,basketNum,true);
                                DiscountApplicableStatus='Discount Applicable';
                            }
                        }else{
                            DiscountApplicableStatus='No discount applicable';//EDGE-143957 added to handle no applicable discount 
                            notApplicableGuidList=commercialProductCLIMap.keySet();//EDGE-143957 added to handle no applicable discount 
                        }
                    }
                }
            }
        }
        else{
            DiscountApplicableStatus='Already triggered';
            system.debug('Inside else isDiscountCheckNeeded'+isDiscountCheckNeeded);
        } 
        system.debug('---DiscountApplicableStatus-->'+DiscountApplicableStatus); 
    }
        
    /*method to fetch mobile subscription priceitem salesforce id Edge-133963*/
    /*Gnana*/
    public override Map<String,Map<String,Charge_Line_Item__c>> getCommercialProductCLIMap(Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap ,String basketID,String Solutionname){
        Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap=new Map<String,Map<String,Charge_Line_Item__c>>();
        //Map <String,String> DiscountConstantsMap = DiscountConstants.GetDiscountConstBasedonSolName(solutionName);
        String commercialProductIdentifier='';
        String contractTermIdentifier='';
        String CliBusinessIdIdentifier='';
        String unitPrice_Identifier='';
        String shadowTCVIdentifier='';
        String quantityIdentifier='';
		CLIbusinessIdSet=new Set<String>();
        //Map<String,Charge_Line_Item__c> comProdIdToCliMap=new Map<String,Charge_Line_Item__c>();
        if(guidToAttMapofMap!=null && guidToAttMapofMap.size()>0){
            for(String configGuid:guidToAttMapofMap.keySet()){
                Map<String,Charge_Line_Item__c> comProdIdToCliMap=new Map<String,Charge_Line_Item__c>();
                Map<String,SolutionDTO.Attributes> attMap=guidToattMapofMap.get(configGuid);
                //Map<String,String> chargeIdToQuantityAttributeMap=DiscountConstants.getChargeIdentifier();               
                if(attMap.containsKey('IsDiscountCheckNeeded') && attMap.get('IsDiscountCheckNeeded').value=='true'){
                    //if(chargeIdToQuantityAttributeMap.size()>0){
                        for(String chargeIdentifier : DiscountConstants.getChargeIdentifier()){
                            system.debug('chargeIdentifier--->'+chargeIdentifier);
                            Map<String,String> DiscountConstantsMap = DiscountConstants.getDiscountConstForNGUCVoice(chargeIdentifier);
                            if(DiscountConstantsMap.containsKey('commercialProductIdentifier')) {
                                commercialProductIdentifier = DiscountConstantsMap.get('commercialProductIdentifier');
                            }
                            if(DiscountConstantsMap.containsKey('contractTermIdentifier')) {
                                contractTermIdentifier = DiscountConstantsMap.get('contractTermIdentifier');
                            }
                            /*if(DiscountConstantsMap.containsKey('CliBusinessIdIdentifier')) {
                                CliBusinessIdIdentifier = DiscountConstantsMap.get('CliBusinessIdIdentifier');
                            }*/
                            if(DiscountConstantsMap.containsKey('unitPrice_Identifier')) {
                                unitPrice_Identifier = DiscountConstantsMap.get('unitPrice_Identifier');
                            }
                            if(DiscountConstantsMap.containsKey('shadowTCVIdentifier')){
                                shadowTCVIdentifier = DiscountConstantsMap.get('shadowTCVIdentifier');
                            }if(DiscountConstantsMap.containsKey('shadowTCVIdentifier')){
                                quantityIdentifier = DiscountConstantsMap.get('quantityIdentifier');
                            }
                            System.debug('CliBusinessIdIdentifier...'+CliBusinessIdIdentifier);
                            if(attMap.containsKey('callingPlans')&&attMap.containsKey('ModeString')&& String.isNotBlank(attMap.get('callingPlans').displayValue ) && String.isNotBlank(attMap.get('ModeString').value)){ // Edge-120919                            
                                Charge_Line_Item__c cliPI=new Charge_Line_Item__c();
                                //cliPI.name = 'CLI for '+commercialProductIdentifier;
                                cliPI.basketId__c=basketID;                      
                                cliPI.solutionId__c=solutionID;
                                cliPI.componentName__c=solutionName;
                                cliPI.guid__c=configGuid;   
                                cliPI.CorrelationId__c=correlationId;
                                cliPI.Product_Charge_Identifier__c='Price Item';
                                cliPI.targetChargeProduct__c ='Feature';
                                cliPI.BusinessID__c=chargeIdentifier;
                                CLIbusinessIdSet.add(chargeIdentifier);
                                //cliPI.commercialProductId__c=attMap.get(commercialProductIdentifier).value; 
                                if(attMap.containsKey(unitPrice_Identifier)&& !String.isBlank(attMap.get(unitPrice_Identifier).value)){
                                    cliPI.unitPrice__c=Decimal.valueof(attMap.get(unitPrice_Identifier).value);
                                }else {
                                    cliPI.unitPrice__c=0;
                                }
                                if(attMap.containsKey(contractTermIdentifier) && !String.isBlank(attMap.get(contractTermIdentifier).value)){
                                    cliPI.contractTerm__c=Integer.valueof(attMap.get(contractTermIdentifier).value);
                                }else{
                                    cliPI.contractTerm__c=12;
                                }
                                if(attMap.containsKey(quantityIdentifier) && !String.isBlank(attMap.get(quantityIdentifier).value)){
                                    cliPI.Quantity__c=Integer.valueof(attMap.get(quantityIdentifier).value);
                                }else {
                                    cliPI.Quantity__c=0;
                                }
                                //edge-121376 for rate crd population
                                if(chargeIdentifier=='DMCAT_RecurringCharge_000814'){
                                        cliPI.rateGroupIdentifier__c=attMap.get('callingPlans').displayValue+attMap.get('ModeString').value; // added modestring Edge-120919 
                                }
                                cliPI.chargeType__c = DiscountConstants.CLI_CHARGETYPE;
                                comProdIdToCliMap.put(chargeIdentifier,cliPI);
                                System.debug('CLI for '+chargeIdentifier +' is.... '+cliPI);
                            }
                        }
                    //}
                }

                system.debug('CLIbusinessIdSet--->'+CLIbusinessIdSet);
                if(comProdIdToCliMap!=null && comProdIdToCliMap.size()>0 && CLIbusinessIdSet!=null && CLIbusinessIdSet.size()>0){
                    if(comProdIdToCliMap!=null){
                        commercialProductCLIMap.put(configGuid,comProdIdToCliMap);
                    }
                }
            }
            //EDGE-145152 start
			if(CLIbusinessIdSet!=null && !CLIbusinessIdSet.isEmpty() && commercialProductCLIMap!=null &&!commercialProductCLIMap.isEmpty()){				
				Map<String,cspmb__Rate_Card__c> rateCardMap=GetPriceScheduleControllerNGUCVoice.fetchRateCards(CLIbusinessIdSet);
				for(string guid:commercialProductCLIMap.keySet()){
					Map<String,Charge_Line_Item__c> comProdIdToCliMap_new=new Map<String,Charge_Line_Item__c>();
					for(string chargeId:commercialProductCLIMap.get(guid).keySet()){
                        Charge_Line_Item__c cli=commercialProductCLIMap.get(guid).get(chargeId);
                        if(rateCardMap!=null && rateCardMap.size()>0 && rateCardMap.containsKey(chargeId)){
                            cli.Rate_Card__c=rateCardMap.get(chargeId).id;
                        }
                        comProdIdToCliMap_new.put(chargeId,cli);
                    }
					if(comProdIdToCliMap_new!=null && comProdIdToCliMap_new.size()>0){
                        commercialProductCLIMap.put(guid,comProdIdToCliMap_new);
                    }
				}
			}//EDGE-145152 end
		}
        
        System.debug('commercialProductCLIMap map values...'+commercialProductCLIMap.values());
        
        return commercialProductCLIMap;
    }
    
    /*method to fetch to get applicable discounts Edge-127073*/
    public static List<cspmb__Discount_Level__c> getApplicableDiscounts(Set<String> businessIdSet){
        if(!businessIdSet.isEmpty()){
            return [SELECT Id,cspmb__Discount__c,cspmb__duration__c,Check_todays_date__c,Is_Delegated__c,cspmb__Discount_Type__c,
                Business_ID__c,Description__c, name,is_Unlimited__c,discountClass__c,Effective_End_Date__c FROM cspmb__Discount_Level__c WHERE Business_ID__c IN :businessIdSet AND Check_todays_date__c = true AND Is_Delegated__c=false]; //EAP is promotion Disc ass is not needed just design time DL is needed for voice /*Effective_End_Date__c added by Aman Soni as it is failing the ComplexChargeDiscountFactoryTest class as part of EDGE-138169*/
        }else{
            return null;
        }
    }
    
    /* method to get eligible discounts to mapped list corresponding to guid Edge-127073*/ /*Shubhi*/
    public static Map<String, Map<String,List<Discount_Line_Item__c>>> getDiscountLineItems(List<cspmb__Discount_Level__c> listOfDiscountLevel,Set<String> guidset,Set<string> chargeIDSet){
        Map<String, Map<String,List<Discount_Line_Item__c>>> guidToEligibleDLIMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>();
        if(guidset.size()>0 && chargeIDSet.size()>0 && listOfDiscountLevel.size()>0){
            SetFieldsInMacScenario getFieldsOnDLIForBusID = new SetFieldsInMacScenario();
            Map<String,List<Discount_Line_Item__c>> cliguidToDLIMap=new Map<String,List<Discount_Line_Item__c>>();
            cliguidToDLIMap=getFieldsOnDLIForBusID.getExistingDiscountLevelList(guidSet);
            system.debug('cliguidToDLIMap-->'+cliguidToDLIMap);
            List<Discount_Line_Item__c> existingDLiList=new List<Discount_Line_Item__c>();      
            for(String guid:guidset){
                if(cliguidToDLIMap!=null && cliguidToDLIMap.containsKey(guid)){
                    existingDLiList=cliguidToDLIMap.get(guid);
                }
                Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();             
                for(String chargeId:chargeIDSet){
                    List<Discount_Line_Item__c> dislevellist=new List<Discount_Line_Item__c>();
                    for(cspmb__Discount_Level__c dl:listOfDiscountLevel){                         
                        Discount_Line_Item__c dli=new Discount_Line_Item__c();
                        dli.BusinessID__c=dl.Business_ID__c;
                        dli.description__c=dl.Description__c;
                        dli.discountType__c=dl.cspmb__Discount_Type__c;
                        dli.discountValue__c=String.valueOf(dl.cspmb__Discount__c);
                        dli.duration__c=String.valueOf(dl.cspmb__duration__c);
                        dli.durationUoM__c='Months';
                        dli.Priority__c=1;
                        dli.name=dl.name;
                        dli.actionCode__c='New';
                        //dli.appliedDate__c; // removed as it should not stamp today's date EDGE-140157
                        dli.isUnlimited__c=dl.is_Unlimited__c;                                
                        dli.discountClass__c = dl.discountClass__c; 
                        dli.discountEndDate__c=dl.Effective_End_Date__c; //Added by Laxmi for EDGE-135885                     
                        if(priceitemToeligibleDLMap.containsKey(chargeId)){
                            dislevellist.addall(priceitemToeligibleDLMap.get(chargeId));
                        }
                        system.debug('DiscountLevel'+dl);   
                        dislevellist.add(dli);                      
                    }
                    
                    if(dislevellist!=null && !dislevellist.isEmpty()){
                        List<Discount_Line_Item__c> finalLst=new List<Discount_Line_Item__c>();
                        if(existingDLiList!=null && existingDLiList.size()>0){
                            finalLst=getFieldsOnDLIForBusID.SetActionCodeOnDLIs(dislevellist,existingDLiList);
                            //Added by Aditya as a part of EDGE-121389 || End
                            system.debug('finalLst--->'+finalLst);
                            if(finalLst !=null && finalLst.size()>0){
                               priceitemToeligibleDLMap.put(chargeId,finalLst); 
                            }
                        }else{
                            priceitemToeligibleDLMap.put(chargeId,dislevellist);
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
    
    /*
    method to get fetchRateCard edge-edge-121376
    */
    public static Map<String,cspmb__Rate_Card__c> fetchRateCards(Set<String> businessIdSet){
        Map<String,cspmb__Rate_Card__c> rateCardMap=new Map<String,cspmb__Rate_Card__c>();
        if(businessIdSet!=null && businessIdSet.size()>0){
            for(cspmb__Rate_Card__c rc:[Select id,cspmb__Rate_Card_Code__c,Check_todays_date__c from cspmb__Rate_Card__c where cspmb__Rate_Card_Code__c IN:businessIdSet AND Check_todays_date__c=true]){ //EDGE-146184 added todays date check
                rateCardMap.put(rc.cspmb__Rate_Card_Code__c,rc);
            }
        }
        return rateCardMap;
    }
}