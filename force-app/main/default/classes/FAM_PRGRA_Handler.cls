/*****************************************************************************************
* Name : FAM_PRGRA_Handler
* Description : 
* ModifiedBy        ModifiedDate    Edge Number   Description
* Shashank Jadhav   10/05/2021      EDGE-219476   Pricing Rule per product family     
* Shashank Jadhav   28/07/2021      EDGE-229566	  Pricing rule code is blank for newly created Pricing Rules.
* Shubham Tiwari   22/09/2021      DIGI-24015  FA Custom price rule creation logic optimization 
************************************************************************************************************************************************/
public with sharing class FAM_PRGRA_Handler {
    
    public String preparePricingGroupsPerProductFamily(Id faId){
        Boolean isErrorForUpsertingPR,isErrorForUpsertingPRGRA,isErrorForUpsertingPIPRA;
        try{
           // Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c> mapOfPRGRA=new Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c>([SELECT cspmb__pricing_rule_group__c,cspmb__pricing_rule__c,Id,Name FROM cspmb__Pricing_Rule_Group_Rule_Association__c WHERE cspmb__pricing_rule_group__c IN (SELECT Id FROM cspmb__Pricing_Rule_Group__c WHERE csconta__frame_agreement__c =: faId)]);
                        //DIGI-24015 Start
			//1) Check if FA has more than 1 PRG record
			List <cspmb__Pricing_Rule_Group__c> listOfPRG=new List<cspmb__Pricing_Rule_Group__c>([SELECT Id FROM cspmb__Pricing_Rule_Group__c WHERE csconta__frame_agreement__c =: faId]);
			if(listOfPRG != null && !listOfPRG.isEmpty() && listOfPRG.size() == 1){	
				//2) For product Get DPR Records First
				Map<String,DPR_Offer__c> mapOfProductFamilyWithDPROffer=new Map<String,DPR_Offer__c>();
				for(DPR_Offer__c dprOffer:[SELECT ContractEndDate__c,ContractStartDate__c,Id,Name FROM DPR_Offer__c WHERE Delegated_Pricing_Request__c IN (SELECT Delegated_Pricing_Request__c FROM csconta__Frame_Agreement__c WHERE Id =: faId)]){
					mapOfProductFamilyWithDPROffer.put(dprOffer.Name,dprOffer);
				}
				System.debug('####mapOfProductFamilyWithDPROffer='+mapOfProductFamilyWithDPROffer);
				System.debug('####mapOfProductFamilyWithDPROffer##='+mapOfProductFamilyWithDPROffer.Size());
				Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c> mapOfPRGRA=new Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c>([SELECT cspmb__pricing_rule_group__c,cspmb__pricing_rule__c,Id,Name FROM cspmb__Pricing_Rule_Group_Rule_Association__c WHERE cspmb__pricing_rule_group__c IN (SELECT Id FROM cspmb__Pricing_Rule_Group__c WHERE csconta__frame_agreement__c =: faId)]);
               //DIGI-24015 End
			   //if(mapOfPRGRA != null && !mapOfPRGRA.isEmpty()){
				Set<Id> setOfPricingRules=new Set<Id>();
				//Step 1:Get the Pricing Rule 
				for(cspmb__Pricing_Rule_Group_Rule_Association__c record:mapOfPRGRA.values()){
						setOfPricingRules.add(record.cspmb__pricing_rule__c);
				}
				 
				//DIGI-24015 - Start
				if(mapOfProductFamilyWithDPROffer != null && !mapOfProductFamilyWithDPROffer.isEmpty() && mapOfProductFamilyWithDPROffer.size() == 1){
					//Get the Pricing Rule and update the Product Family
					System.debug('Only one product iupdate Product family');
					String dprProductFamily;
                    DPR_Offer__c dprOfferRecord;
                    cspmb__Pricing_Rule__c updateSinglePRRecord;
					for(String productFamily:mapOfProductFamilyWithDPROffer.KeySet()){
						dprProductFamily = productFamily;
                        dprOfferRecord=mapOfProductFamilyWithDPROffer.get(productFamily);
                    }
					for(cspmb__Pricing_Rule__c pricingRuleRecord:[SELECT cspmb__effective_end_date__c,cspmb__effective_start_date__c,Id,Product_Family__c FROM cspmb__Pricing_Rule__c WHERE Id =: setOfPricingRules]){
                    /*    if(dprOfferRecord != null && dprOfferRecord.ContractStartDate__c != null && dprOfferRecord.ContractEndDate__c != null){
                            updateSinglePRRecord = new cspmb__Pricing_Rule__c();
                            updateSinglePRRecord.id= pricingRuleRecord.id;
                            updateSinglePRRecord.Product_Family__c = dprProductFamily;
                            updateSinglePRRecord.cspmb__effective_start_date__c = dprOfferRecord.ContractStartDate__c;
                            updateSinglePRRecord.cspmb__effective_end_date__c = dprOfferRecord.ContractEndDate__c;
                        }else{
                            return 'Please check DPR Start and End Dates are populated.'; 
                        }*/
						if (pricingRuleRecord != null)
						{
							pricingRuleRecord.Product_Family__c = dprProductFamily;
							updateSinglePRRecord=pricingRuleRecord;
						}
					}
                    if(updateSinglePRRecord != null){
                        update updateSinglePRRecord;
                    }
					
                }
				else if (mapOfProductFamilyWithDPROffer != null && !mapOfProductFamilyWithDPROffer.isEmpty()) {
				//DIGI-24015 End
					Map<String,List<cspmb__Price_Item_Pricing_Rule_Association__c>> mapOfOfferIdWithPIPRA=new Map<String,List<cspmb__Price_Item_Pricing_Rule_Association__c>>();
            
					Integer currentPRRuleCodeNumber=0; //EDGE-229566 : Will store currentPRRuleCode
					String currentPRRuleCode=''; //EDGE-229566 : Will store currentPRRuleCode
					if(setOfPricingRules != null && !setOfPricingRules.isEmpty()){
					//Step 2:Get the PIPRA with product family
						for(cspmb__Price_Item_Pricing_Rule_Association__c pipraRecord:[SELECT Id,Name,cspmb__price_item_add_on_association__c,cspmb__pricing_rule__c,cspmb__price_item_add_on_association__r.cspmb__Price_Item__r.Offer_Id__c,cspmb__price_item__r.Offer_Id__c,cspmb__price_item_add_on_association__r.cspmb__Price_Item__r.Offer_Name__c,cspmb__price_item__r.Offer_Name__c
						FROM cspmb__Price_Item_Pricing_Rule_Association__c WHERE cspmb__pricing_rule__c IN: setOfPricingRules]){
							String OfferId = (pipraRecord.cspmb__price_item__r.Offer_Id__c != null)?pipraRecord.cspmb__price_item__r.Offer_Id__c:pipraRecord.cspmb__price_item_add_on_association__r.cspmb__Price_Item__r.Offer_Id__c;
							if(mapOfOfferIdWithPIPRA.containsKey(OfferId))
								mapOfOfferIdWithPIPRA.get(OfferId).add(pipraRecord);
							else
								mapOfOfferIdWithPIPRA.put(OfferId, new List<cspmb__Price_Item_Pricing_Rule_Association__c>{ pipraRecord });
						}
						//System.debug('####mapOfOfferIdWithPIPRA='+mapOfOfferIdWithPIPRA);
						//System.debug('####mapOfOfferIdWithPIPRA Query='+[SELECT Id,Product_Family__c,Offer_ID__c FROM Marketable_Offer__c WHERE Offer_ID__c IN : mapOfOfferIdWithPIPRA.keySet()]);
						Map<String,List<cspmb__Price_Item_Pricing_Rule_Association__c>> mapOfProductFamilyWithPIPRA=new Map<String,List<cspmb__Price_Item_Pricing_Rule_Association__c>>();
						if(mapOfOfferIdWithPIPRA != null && !mapOfOfferIdWithPIPRA.isEmpty()){
							for(Marketable_Offer__c mo:[SELECT Id,Product_Family__c,Offer_ID__c FROM Marketable_Offer__c WHERE Offer_ID__c IN : mapOfOfferIdWithPIPRA.keySet()]){
							System.debug('####mo='+mo);
						   //DIGI-24015  Commented code
							/*  if(!mapOfProductFamilyWithPIPRA.containsKey(mo.Product_Family__c) && mapOfOfferIdWithPIPRA.containsKey(mo.Offer_ID__c)){
								List<cspmb__Price_Item_Pricing_Rule_Association__c> listOfPipraRecords=mapOfOfferIdWithPIPRA.get(mo.Offer_ID__c);
								mapOfProductFamilyWithPIPRA.put(mo.Product_Family__c, listOfPipraRecords);
						}*/
							//DIGI-24015 Start 				
								if(!mapOfProductFamilyWithPIPRA.containsKey(mo.Product_Family__c))
								{
								//Instantiates the MAP for given product family.
									mapOfProductFamilyWithPIPRA.put(mo.Product_Family__c, new List<cspmb__Price_Item_Pricing_Rule_Association__c>());
								}
								if(mapOfOfferIdWithPIPRA.containsKey(mo.Offer_ID__c))
								{
									//Segregates the CPPRA as per product family
									List<cspmb__Price_Item_Pricing_Rule_Association__c> listOfProdFamilyPipraRecords = mapOfProductFamilyWithPIPRA.get(mo.Product_Family__c);
									List<cspmb__Price_Item_Pricing_Rule_Association__c> listOfPipraRecords=mapOfOfferIdWithPIPRA.get(mo.Offer_ID__c);
									listOfProdFamilyPipraRecords.addall(listOfPipraRecords);
									mapOfProductFamilyWithPIPRA.put(mo.Product_Family__c, listOfProdFamilyPipraRecords);
								}
							}
						}
						//DIGI-24015 end 
					
						//DIGI-24015 Code commenting start 
						//Step 3: Prepare the mapOfProductFamilyWithPricingRule            
						/*Map<String,Id> mapOfProductFamilyWithPricingRule=new Map<String,Id>();
						for(String key:mapOfProductFamilyWithPIPRA.keySet()){
							for(cspmb__Price_Item_Pricing_Rule_Association__c pipraRecord:mapOfProductFamilyWithPIPRA.get(key)){
								//Add PricingRule to mapOfProductFamilyWithPIPRA
								if(!mapOfProductFamilyWithPricingRule.containsKey(key))
									mapOfProductFamilyWithPricingRule.put(key,pipraRecord.cspmb__pricing_rule__c);
							}
						}
						System.debug('####mapOfProductFamilyWithPricingRule='+mapOfProductFamilyWithPricingRule);
						*/
						//DIGI-24015 Code commenting start
						//Map<Id,cspmb__pricing_rule__c> mapOfExistingPricingRules=new Map<Id,cspmb__pricing_rule__c>([SELECT cspmb__description__c,cspmb__effective_end_date__c,cspmb__effective_start_date__c,cspmb__pricing_rule_code__c,Id,Name,Product_Family__c FROM cspmb__Pricing_Rule__c where Id IN: setOfPricingRules]);
				
						/*FAM_PRGRA_Handler_Utility utility=new FAM_PRGRA_Handler_Utility();
						Map<Id,cspmb__pricing_rule__c> mapOfExistingPricingRules=new Map<Id,cspmb__pricing_rule__c>();
						if(setOfPricingRules != null && !setOfPricingRules.isEmpty()){
						mapOfExistingPricingRules=utility.getExistingPricingRules(setOfPricingRules);
						}
						System.debug('####mapOfExistingPricingRules='+mapOfExistingPricingRules);*/
						//DIGI-24015 Code commenting End
						//Step 3.a Get the DPR Offers for Start and End Date
						//DIGI-24015 code commented
						/*
						Map<String,DPR_Offer__c> mapOfProductFamilyWithDPROffer=new Map<String,DPR_Offer__c>();
						for(DPR_Offer__c dprOffer:[SELECT ContractEndDate__c,ContractStartDate__c,Id,Name FROM DPR_Offer__c WHERE Delegated_Pricing_Request__c IN (SELECT Delegated_Pricing_Request__c FROM csconta__Frame_Agreement__c WHERE Id =: faId)]){
							mapOfProductFamilyWithDPROffer.put(dprOffer.Name,dprOffer);
						}
						*/

						//DIGI-24015 Start
						//Step 3: Prepare the mapOfProductFamilyWithPricingRule
						//Step 3.1: Indentify productfamily that should be stamped against existing price rule created out of box.
						String productFamilyForExistingRule = null;
						DPR_Offer__c dprOfferRecordForExistingRule=new DPR_Offer__c();
						Integer MaxPIPRASize = 0;
						for(String productFamilyKey:mapOfProductFamilyWithDPROffer.keySet()){
							if (mapOfProductFamilyWithPIPRA != null && !mapOfProductFamilyWithPIPRA.isEmpty())
							{
								if (mapOfProductFamilyWithPIPRA.containsKey(productFamilyKey))
								{
									Integer pfPIPRASize = mapOfProductFamilyWithPIPRA.get(productFamilyKey).size();
									if (pfPIPRASize > MaxPIPRASize)
									{
										MaxPIPRASize = pfPIPRASize;
										productFamilyForexistingRule = productFamilyKey;
										dprOfferRecordForExistingRule = 	mapOfProductFamilyWithDPROffer.get(productFamilyKey);
									}
								}else if (productFamilyForexistingRule == null)
								{
									productFamilyForexistingRule = productFamilyKey;
									dprOfferRecordForExistingRule = 	mapOfProductFamilyWithDPROffer.get(productFamilyKey);
								}
							}
							else 
							{
								productFamilyForexistingRule = productFamilyKey;
								dprOfferRecordForExistingRule = 	mapOfProductFamilyWithDPROffer.get(productFamilyKey);
							}
						}
                      	System.debug('####dprOfferRecordForExistingRule='+dprOfferRecordForExistingRule);
						//Step 4.2 update existing price rule record product family
						Map<String,cspmb__Pricing_Rule__c> mapOfProductFamilyWithPricingRule=new Map<String,cspmb__Pricing_Rule__c>();
                                   List<cspmb__Pricing_Rule__c> existingpricingRuleRecord = [SELECT cspmb__effective_end_date__c,cspmb__effective_start_date__c,Id,Product_Family__c,cspmb__pricing_rule_code__c,Name FROM cspmb__Pricing_Rule__c WHERE Id in:setOfPricingRules];
						String existingPriceRuleCode;
						
						if (productFamilyForexistingRule != null)
						{
							
							existingPriceRuleCode = existingpricingRuleRecord[0].cspmb__pricing_rule_code__c;
                          
							existingpricingRuleRecord[0].Product_Family__c = dprOfferRecordForExistingRule.Name;	
                            if(dprOfferRecordForExistingRule.ContractStartDate__c != null)
                            {
							existingpricingRuleRecord[0].cspmb__effective_start_date__c = dprOfferRecordForExistingRule.ContractStartDate__c;
                            }
                            if(dprOfferRecordForExistingRule.ContractEndDate__c != null)
                            {
                               existingpricingRuleRecord[0].cspmb__effective_end_date__c = dprOfferRecordForExistingRule.ContractEndDate__c;
                            }
                            
							mapOfProductFamilyWithPricingRule.put(productFamilyForexistingRule, existingpricingRuleRecord[0]);
						}
						
						//Step 4.3 create price rule for remaining product family
						for(String productFamilyKey:mapOfProductFamilyWithDPROffer.keySet()){
							
							if (!mapOfProductFamilyWithPricingRule.containsKey(productFamilyKey)) 
							{
								currentPRRuleCodeNumber = currentPRRuleCodeNumber +1;
								DPR_Offer__c dprOfferRecord = mapOfProductFamilyWithDPROffer.get(productFamilyKey);
                                System.debug('####dprOfferRecord='+dprOfferRecord);
                                System.debug('####mapOfProductFamilyWithDPROffer='+mapOfProductFamilyWithDPROffer.get(productFamilyKey));
								cspmb__pricing_rule__c newPricingRuleRecord=new cspmb__pricing_rule__c();
								newPricingRuleRecord.cspmb__description__c='Created based on product family';
								newPricingRuleRecord.cspmb__pricing_rule_code__c = existingPriceRuleCode + '_' + currentPRRuleCodeNumber;
								newPricingRuleRecord.Product_Family__c = dprOfferRecord.Name;
                                if(dprOfferRecord.ContractStartDate__c!= null )
                                {
                 			newPricingRuleRecord.cspmb__effective_start_date__c = dprOfferRecord.ContractStartDate__c;
                   
                                }
                                if (dprOfferRecord.ContractEndDate__c!= null )
                                {
                                  newPricingRuleRecord.cspmb__effective_end_date__c = dprOfferRecord.ContractEndDate__c;
                                }
                            
                               
								mapOfProductFamilyWithPricingRule.put(productFamilyKey, newPricingRuleRecord);
							}
							
						}
						
						System.debug('####mapOfProductFamilyWithPricingRule='+mapOfProductFamilyWithPricingRule);
						List<cspmb__pricing_rule__c> listOfPRToUpsert=new List<cspmb__pricing_rule__c>();
						for(String pFamilyStr:mapOfProductFamilyWithPricingRule.keySet())
						{
							listOfPRToUpsert.add(mapOfProductFamilyWithPricingRule.get(pFamilyStr));
                            
						}
					
						System.debug('####listOfPRToUpsert='+listOfPRToUpsert);
                
						//DIGI-24015 End
						//Step 6:  Upsert the Pricing Rules
						FAM_PRGRA_Handler_Utility utility=new FAM_PRGRA_Handler_Utility();
						isErrorForUpsertingPR=utility.upsertListOfPricingRules(listOfPRToUpsert);
						if(!isErrorForUpsertingPR){
							//Step 7: Prepare the upserted Pricing Rules Map
							Map<Id,cspmb__pricing_rule__c> mapOfUpsertedPR=new Map<Id,cspmb__pricing_rule__c>();
							Map<String,cspmb__pricing_rule__c> mapOfPFWithPR=new Map<String,cspmb__pricing_rule__c>();//This map will be used for PF with Pricing Rule records
							for(cspmb__pricing_rule__c prRecord2:listOfPRToUpsert){
								if(!mapOfUpsertedPR.containsKey(prRecord2.Id)){
									mapOfUpsertedPR.put(prRecord2.Id, prRecord2);
									mapOfPFWithPR.put(prRecord2.Product_Family__c,prRecord2);
								}       
							}
							
							//Step 8: Create Pricing Rule Group - Rule Association
							List<cspmb__Pricing_Rule_Group_Rule_Association__c> listOfPRGRARecords=new List<cspmb__Pricing_Rule_Group_Rule_Association__c>(); 
							 //DIGI-24015 Code commented 
							/*  cspmb__Pricing_Rule_Group_Rule_Association__c exitingPRGRARecordForPricingGroup=new cspmb__Pricing_Rule_Group_Rule_Association__c();
								for(cspmb__Pricing_Rule_Group_Rule_Association__c prgraRecord:mapOfPRGRA.values()){
									exitingPRGRARecordForPricingGroup=prgraRecord;
								}*/
							for(cspmb__pricing_rule__c prRecord3:mapOfPFWithPR.values()){
								//DIGI-24015 Code commented 
								/* for(cspmb__Pricing_Rule_Group_Rule_Association__c existingPRGRARecord:mapOfPRGRA.values()){
									if(prRecord3.Id != existingPRGRARecord.cspmb__pricing_rule__c){*/
								if(!setOfPricingRules.contains(prRecord3.Id)){
									cspmb__Pricing_Rule_Group_Rule_Association__c tempPRGARecord=new cspmb__Pricing_Rule_Group_Rule_Association__c(
									//  cspmb__pricing_rule_group__c =exitingPRGRARecordForPricingGroup.cspmb__pricing_rule_group__c,
									cspmb__pricing_rule_group__c =listOfPRG.get(0).Id, //DIGI-24015
									cspmb__pricing_rule__c = prRecord3.Id
									);
									listOfPRGRARecords.add(tempPRGARecord);
								}
							}
							
							isErrorForUpsertingPRGRA=utility.upsertListOfPricingRulesGroupRuleAsssociation(listOfPRGRARecords);
							if(!isErrorForUpsertingPRGRA){
								//Step 9 : Update the PIPRA
								List<cspmb__Price_Item_Pricing_Rule_Association__c> listOfPIPRAForUpdate=new List<cspmb__Price_Item_Pricing_Rule_Association__c>();
								for(String pFamily:mapOfProductFamilyWithPIPRA.keySet()){
									if (pFamily != productFamilyForexistingRule)  //DIGI-24015
									{
										for(cspmb__Price_Item_Pricing_Rule_Association__c pipraRecord:mapOfProductFamilyWithPIPRA.get(pFamily)){
										// String productFamilyStr = (pipraRecord.cspmb__price_item__r.Offer_Name__c != null)?pipraRecord.cspmb__price_item__r.Offer_Name__c:pipraRecord.cspmb__price_item_add_on_association__r.cspmb__Price_Item__r.Offer_Name__c;
											if(mapOfPFWithPR.containsKey(pFamily)){
												cspmb__pricing_rule__c pricingRuleRecord=mapOfPFWithPR.get(pFamily);
												//    if(pricingRuleRecord.Id != pipraRecord.cspmb__pricing_rule__c){     //DIGI-24015
												pipraRecord.cspmb__pricing_rule__c = pricingRuleRecord.Id;//Update the pricing rule
												listOfPIPRAForUpdate.add(pipraRecord);
											}
										}
									}
								}
								//Update the List of PIPRA records 
								isErrorForUpsertingPIPRA = utility.upsertListOfPricingRulesGroupRuleAsssociation(listOfPIPRAForUpdate);
							}//End of isErrorForUpsertingPRGRA If 
						}//End Of isErrorForUpsertingPR IF
                
					}//End of setOfPricingRules If 
					if(isErrorForUpsertingPR == true || isErrorForUpsertingPRGRA == true || isErrorForUpsertingPIPRA == true){
						return 'Please contact support team. Error in Pricing Rule creation per product family.';
					}
				//DIGI-24015 Start
				}// End of Else if for mapOfProductFamilyWithDPROffer
			} else{
					return 'Frame Agreement should have only one PRG record for activation';
			}
           //DIGI-24015 End
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','preparePricingGroupsPerProductFamily', '', faId, ex.getStackTraceString(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End
        return 'Success';
    }
    
}