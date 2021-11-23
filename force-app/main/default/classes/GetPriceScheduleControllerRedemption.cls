/*
* @Author : Gnana
* @Date : 31 Apr 2020
* @Desc : GetPriceScheduleControllerRedemption
* @TestClass : GetPriceScheduleControllerRedemptionTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        Gnana               31/4/2020     Created : Edge-140968 Enabling POS Redemption
2.        Shubhi V          02-June-2020    EDGE-151069 taxtreatment in cli
3.        Shubhi V 			29-06-2020      Edge-149830 
4.		  Shubhi V          27/11/2020		EDGE-190170
===============================================================================================================================
*/
public with sharing class GetPriceScheduleControllerRedemption extends GetPriceSchedulevirtualClass{
    
    public string solutionID {get; set;}
    public String correlationId {get; set;}
    public String DiscountApplicableStatus {get; set;}
    public Set<String> ApplicableGuidList {get; set;}
    public static Map<String,String> guidToMap= new Map<String,String>();
    
    public void onLoadMethod(Map<String,Map<String,SolutionDTO.Attributes>> guidToAttMapofMap,String basketId,String accountId,String solID,String IsDiscountCheckNeeded,String solutionName,String basketNum,String correlId){
        DiscountApplicableStatus='Initial';
        solutionId=solID;
        correlationId=correlId;
        if(IsDiscountCheckNeeded=='true'){           
            if(String.isNotBlank(solutionID) && guidToAttMapofMap!=null && guidToAttMapofMap.size()>0){
                system.debug('@@@guidToAttMapofMap@@@'+guidToAttMapofMap);
                Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap = getCommercialProductCLIMap(guidToAttMapofMap,basketID,Solutionname);
                Set<String> priceItemSet=new Set<string>();
                set<string> guidset=commercialProductCLIMap.keyset();
                if(commercialProductCLIMap.size()>0){
                    Map<String, Map<String,List<Discount_Line_Item__c>>> DiscountLineItemsMap=getDiscountLineItems(guidset,guidToAttMapofMap);
                    Map<String, Map<String,Charge_Line_Item__c>> finalChargeLineItems=commercialProductCLIMap;
                    if(finalChargeLineItems.size()>0){
                        ComplexChargeDisountFactory chargeDiscountDML=new ComplexChargeDisountFactory();
                        chargeDiscountDML.upsertChargeDiscountLineItem(DiscountLineItemsMap,finalChargeLineItems);
                        GetPriceSchedulevirtualClass.publishEventRequest(correlationId,solutionName,basketNum,false);
                        DiscountApplicableStatus='Discount Applicable';
                    }
                }
            }           
        }
        system.debug('---DiscountApplicableStatus-->'+DiscountApplicableStatus);        
    }
    
    /*  
     * Method Name : getCommercialProductCLIMap
     * Input Parameter 1 : guidToAttMapofMap - attributes and corresponding values for CLI creation
     * Input Parameter 2 :  basketID - Prodcut Basket Id
     * Input Parameter 3 :  Solutionname - Name of the Solution Component
     * Return Parameter : Map<ConfigGuid,Map<ChargeIdentifier,ChareLineItem>>    
     * Description : Creates Charge Line Item instances for Upsert 
    */
    public override Map<String,Map<String,Charge_Line_Item__c>> getCommercialProductCLIMap(Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap ,String basketID,String Solutionname){
        ApplicableGuidList=new set<string>();
        Map<String,Map<String,Charge_Line_Item__c>> commercialProductCLIMap=new Map<String,Map<String,Charge_Line_Item__c>>();
        List<Discount_Constant__mdt> mdtDiscountConstant = [SELECT Label,DeveloperName ,CommercialProductIdentifier__c, UnitPrice_Identifier__c, 
                                                            ShadowTCVIdentifier__c, QuantityIdentifier__c, BusinessIdIdentifier__c,
                                                            Target_Charge_Product__c, Product_Charge_Identifier__c, Charge_Type__c ,TaxTreatmentIdentifier__c,Target_Charge_Product_Child__c,Product_Charge_Identifier_child__c
                                                            FROM Discount_Constant__mdt WHERE Label = :solutionName LIMIT 1]; //Edge-149830 added child identifiers
        if (mdtDiscountConstant != null && mdtDiscountConstant.size() > 0 && guidToAttMapofMap != null && guidToAttMapofMap.size()>0){
            
            String commercialProductIdentifier='';
            String unitPrice_Identifier='';
            String TCVIdentifier='';
            String quantityIdentifier='';
            String BusinessIdIdentifier='';
            String TaxTreatmentIdentifier='';//EDGE-151069 

            commercialProductIdentifier = mdtDiscountConstant[0].CommercialProductIdentifier__c;
            system.debug('commercialProductIdentifier-->'+commercialProductIdentifier);
            unitPrice_Identifier = mdtDiscountConstant[0].UnitPrice_Identifier__c;
            quantityIdentifier = mdtDiscountConstant[0].QuantityIdentifier__c;
            TCVIdentifier = mdtDiscountConstant[0].ShadowTCVIdentifier__c;
            BusinessIdIdentifier = mdtDiscountConstant[0].BusinessIdIdentifier__c;
            TaxTreatmentIdentifier=mdtDiscountConstant[0].TaxTreatmentIdentifier__c;//EDGE-151069 
            
            for(String configGuid:guidToAttMapofMap.keySet()){
                 String configGuidForMap='';
                Map<String,Charge_Line_Item__c> chargeIdentifierToCliMap=new Map<String,Charge_Line_Item__c>();
                Map<String,SolutionDTO.Attributes> attMap=guidToattMapofMap.get(configGuid);
                 system.debug('Check GUID::'+attMap);
                if(attMap!=null && attMap.containsKey('IsRedeemFundCheckNeeded') && !String.isBlank(attMap.get('IsRedeemFundCheckNeeded').value) && attMap.get('IsRedeemFundCheckNeeded').value=='true'){
                    Charge_Line_Item__c cliPI=new Charge_Line_Item__c();
                    cliPI.basketId__c=basketID;                      
                    cliPI.solutionId__c=solutionID;
                    cliPI.componentName__c=solutionName;
                         cliPI.guid__c=configGuid;  
                         configGuidForMap= configGuid;

                    if(solutionName == DiscountConstants.mobilitySolutionName){
                        //cliPI.guid__c=attMap.get('GUID').value;
                        //configGuidForMap=attMap.get('GUID').value;
                        guidToMap.put(configGuidForMap,configGuid);//EDGE-190170
                    }
                   
                    ApplicableGuidList.add(configGuid);  
                    cliPI.CorrelationId__c=correlationId;
					cliPI.chargeType__c = mdtDiscountConstant[0].Charge_Type__c;
                    if(attMap.containsKey(quantityIdentifier) && !String.isBlank(attMap.get(quantityIdentifier).value)){
                        cliPI.Quantity__c=Integer.valueof(attMap.get(quantityIdentifier).value);
                    }else {
                        cliPI.Quantity__c=1;
                    }
					if(attMap.containsKey(TCVIdentifier) && !String.isBlank(attMap.get(TCVIdentifier).value)){
                        cliPi.totalContractValue__c=Decimal.valueof(attMap.get(TCVIdentifier).value);
                    }
					if(attMap.containsKey(BusinessIdIdentifier) && !String.isBlank(attMap.get(BusinessIdIdentifier).value)){
                        cliPi.BusinessID__c=attMap.get(BusinessIdIdentifier).value;
                    }
                    else if(solutionName == DiscountConstants.mobilitySolutionName){
                        cliPI.BusinessID__c= DiscountConstants.MS_Charge_Id;
                    }
					if(attMap.containsKey(commercialProductIdentifier)&& !String.isBlank(attMap.get(commercialProductIdentifier).value)){
                        cliPI.commercialProductId__c=attMap.get(commercialProductIdentifier).value;
                        system.debug('cliPI.commercialProductId__c-->'+cliPI.commercialProductId__c);
                    }
                    if(attMap.containsKey(unitPrice_Identifier)&& !String.isBlank(attMap.get(unitPrice_Identifier).value)){
                        cliPI.unitPrice__c=Decimal.valueof(attMap.get(unitPrice_Identifier).value);
                    }
					 ////Edge-149830 added by shubhi start
					if(attMap.containsKey('ischildApplicable')&& !String.isBlank(attMap.get('ischildApplicable').value) && attMap.get('ischildApplicable').value=='true'){
                        cliPI.targetChargeProduct__c =mdtDiscountConstant[0].Target_Charge_Product_Child__c;
						cliPI.Product_Charge_Identifier__c=mdtDiscountConstant[0].Product_Charge_Identifier_child__c;
                    } ////Edge-149830 added by shubhi end
					else{
                        cliPI.targetChargeProduct__c =mdtDiscountConstant[0].Target_Charge_Product__c;
						cliPI.Product_Charge_Identifier__c=mdtDiscountConstant[0].Product_Charge_Identifier__c;
                    }
                    //EDGE-151069 added by shubhi start
                    if(attMap.containsKey(TaxTreatmentIdentifier) && !String.isBlank(attMap.get(TaxTreatmentIdentifier).value)){
                        cliPi.taxTreatment__c=attMap.get(TaxTreatmentIdentifier).value;
                    } //EDGE-151069 added by shubhi end                  
                    chargeIdentifierToCliMap.put(mdtDiscountConstant[0].Product_Charge_Identifier__c,cliPI);
                }
                if(chargeIdentifierToCliMap.size()>0)
                    commercialProductCLIMap.put(configGuidForMap,chargeIdentifierToCliMap);
                    
            }
        }
        return commercialProductCLIMap;
    }

    /*  
     * Method Name : getDiscountLineItems
     * Input Parameter 1 : guidset - Set of Config GUIDs
     * Input Parameter 2 : guidToAttMapofMap - attributes and corresponding values for CLI creation
     * Return Parameter : Map<ConfigGuid,Map<ChargeIdentifier,DiscountLineItem>>     
     * Description : Creates Discount Line Item instances for Upsert 
    */
    public static Map<String, Map<String,List<Discount_Line_Item__c>>> getDiscountLineItems(Set<String> guidset,Map<String,Map<String,SolutionDTO.Attributes>>guidToAttMapofMap){
        Map<String, Map<String,List<Discount_Line_Item__c>>> guidToEligibleDLIMap=new Map<String, Map<String,List<Discount_Line_Item__c>>>();
        if(guidset.size()>0){
            SetFieldsInMacScenario getFieldsOnDLIForBusID = new SetFieldsInMacScenario();
            Map<String,List<Discount_Line_Item__c>> cliguidToDLIMap=new Map<String,List<Discount_Line_Item__c>>();
            cliguidToDLIMap=getFieldsOnDLIForBusID.getExistingDiscountLevelList(guidSet);
            system.debug('cliguidToDLIMap-->'+cliguidToDLIMap);
            List<Discount_Line_Item__c> existingDLiList=new List<Discount_Line_Item__c>();      
            for(String guid:guidset){
                 Map<String,SolutionDTO.Attributes> attMap=new Map<String,SolutionDTO.Attributes>();
                 if(guidToMap.containskey(guid)){
                    attMap=guidToattMapofMap.get(guidToMap.get(guid));
                 }else{
                   attMap=guidToattMapofMap.get(guid);
                 }
                if(cliguidToDLIMap!=null && cliguidToDLIMap.containsKey(guid)){
                    existingDLiList=cliguidToDLIMap.get(guid);
                }
                Map<String,List<Discount_Line_Item__c>> priceitemToeligibleDLMap=new Map<String,List<Discount_Line_Item__c>>();             
                system.debug('attMap-->'+guidToattMapofMap.get(guid));
                List<Discount_Line_Item__c> dislevellist=new List<Discount_Line_Item__c>();
                if(attMap.containsKey('RedeemFund')){ // EDGE-190170
					Discount_Line_Item__c dli=new Discount_Line_Item__c();
					dli.description__c='Point Of Sale Redemption';
					dli.discountType__c='Redemption';
					dli.discountValue__c=attMap.get('RedeemFund').value;
					dli.name='Redemption Discount';
					dli.actionCode__c='New';
					dli.isUnlimited__c= false;                                
					dli.discountClass__c = 'Amount'; 
					dislevellist.add(dli);
				}
                
                if(dislevellist!=null && !dislevellist.isEmpty()){
                    priceitemToeligibleDLMap.put('Price Item',dislevellist);
                }
                if(!priceitemToeligibleDLMap.isEmpty()){                    
                    guidToEligibleDLIMap.put(guid,priceitemToeligibleDLMap);
                }
            }
        }       
        return guidToEligibleDLIMap;
    }

}