public with sharing class IOTDealQuoteDataHandler {
	
      public List<Map<String,Object>> getIOTPlanRateCard(String dprId, Map<String,String> subfilters){
        Map<String,List<DPR_Rate_Card__c>> wrapRow = new Map<String,List<DPR_Rate_Card__c>>();
        Map<String,String> allConst = new Map<String,String>();    
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
		String planVariant = '';	
			String planType = subfilters.get('Query_Type');
			System.debug('***Telstra:Query_Type'+planType);
			if(planType.contains(DataHandlerConstants.IOt_LTE)){
			planVariant = DataHandlerConstants.IOt_LTE;
			} else if (planType.contains(DataHandlerConstants.IOt_LPWAN)){
				planVariant = DataHandlerConstants.IOt_LPWAN;
			} else if (planType.contains(DataHandlerConstants.IOT_Utilities)){
				planVariant = DataHandlerConstants.IOT_Utilities;
			}
			string planTypeFilter = '%' + planVariant + '%';
			Integer ExId = 1;
			System.debug('***Telstra:planVariant'+planVariant); 
			System.debug('***Telstra:planTypeFilter'+planTypeFilter);
			try{
				allConst = getConstant();
				for(DPR_Rate_Card__c arc : [Select ID, DPR_Rate_Card_Name__c, Parent_DPR_OLI_id__r.Id,Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c, DPR_RC_Rate_Value__c, DPR_RC_Negotiated_Value__c , Negotiated_Discount__c,Parent_DPR_Rate_Card_ID__c,Delegated_Pricing_Request__c    FROM DPR_Rate_Card__c where Delegated_Pricing_Request__c    =: dprId AND Parent_DPR_OLI_id__r.DPR_Offer__r.Marketable_Offer__r.Offer_ID__c =: DataHandlerConstants.IOT_Offer_Id AND DPR_Rate_Card_Name__c like : planTypeFilter ]){
					if(arc.Parent_DPR_Rate_Card_ID__c != null){
						if(!wrapRow.containsKey(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c)){
							wrapRow.put(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,new List<DPR_Rate_Card__c>());
						}
						wrapRow.get(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c).add(arc); 
					}
				}
				for(String plan: wrapRow.keySet()){
					Map<String,Object> dprRow= new Map<String,Object>();
					String name = null;
					System.debug('***Telstra:plan'+plan);
					if(plan.contains(DataHandlerConstants.IOt_LPWAN)){
						System.debug('***Telstra:inLPWAN');
						dprRow.put(allConst.get('ProductModuleName'),plan);
						for(DPR_Rate_Card__c rateCard : wrapRow.get(plan)){
							name = rateCard.DPR_Rate_Card_Name__c;
							System.debug('***Telstra:name'+name);
							if(name.contains(DataHandlerConstants.LPWAN_VolumeTier1)){
								System.debug('***Telstra:LPWAN_VolumeTier1');
								dprRow.put(allConst.get('VolumeTier1'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}   else if(name.contains(DataHandlerConstants.LPWAN_VolumeTier2)){
								dprRow.put(allConst.get('VolumeTier2'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LPWAN_VolumeTier3)){
                                System.debug('***Telstra:LPWAN_VolumeTier3'+rateCard.DPR_RC_Negotiated_Value__c);
								dprRow.put(allConst.get('VolumeTier3'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LPWAN_VolumeTier4)){
								dprRow.put(allConst.get('VolumeTier4'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LPWAN_VolumeTier5)){
								dprRow.put(allConst.get('VolumeTier5'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}            
						}
					}else if(plan.contains(DataHandlerConstants.IOt_LTE)){
						System.debug('***Telstra:inLTE');
						dprRow.put(allConst.get('ProductModuleName'),plan);
						for(DPR_Rate_Card__c rateCard : wrapRow.get(plan)){
							name = rateCard.DPR_Rate_Card_Name__c;
							
							if(name.contains(DataHandlerConstants.LTE_VolumeTier1)){
								System.debug('***Telstra:LTE_VolumeTier1');
								dprRow.put(allConst.get('VolumeTier1'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}   else if(name.contains(DataHandlerConstants.LTE_VolumeTier2)){
								dprRow.put(allConst.get('VolumeTier2'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LTE_VolumeTier3)){
								dprRow.put(allConst.get('VolumeTier3'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LTE_VolumeTier4)){
								dprRow.put(allConst.get('VolumeTier4'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.LTE_VolumeTier5)){
								dprRow.put(allConst.get('VolumeTier5'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}             
						}
					} else if(plan.contains(DataHandlerConstants.IOT_Utilities)) {
						System.debug('***Telstra:Utilities');
						dprRow.put(allConst.get('ProductModuleName'),plan);
						for(DPR_Rate_Card__c rateCard : wrapRow.get(plan)){
							name = rateCard.DPR_Rate_Card_Name__c;
							
							if(name.contains(DataHandlerConstants.Utilities_VolumeTier1)){
								System.debug('***Telstra:Utilities_VolumeTier1');
								dprRow.put(allConst.get('VolumeTier1'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}   else if(name.contains(DataHandlerConstants.Utilities_VolumeTier2)){
								dprRow.put(allConst.get('VolumeTier2'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.Utilities_VolumeTier3)){
								dprRow.put(allConst.get('VolumeTier3'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.Utilities_VolumeTier4)){
								dprRow.put(allConst.get('VolumeTier4'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							} else if(name.contains(DataHandlerConstants.Utilities_VolumeTier5)){
								dprRow.put(allConst.get('VolumeTier5'), rateCard.DPR_RC_Negotiated_Value__c);
								continue;
							}             
						}
					}
					dprRow.put(allConst.get('ExternalId'),ExId++ );
					dprRow.put(allConst.get('is_IOT'),true);
					rows.add(dprRow); 
				}
				system.debug('***Telstra:TCDealQuoteDataHandler:getTCPlanRateCard:rows'+rows);
			}
			catch(Exception e){   
				System.debug('***Telstra:TCDealQuoteDataHandler:getTCPlanRateCard:exception:'+e.getLineNumber()+' '+e.getMessage()); 
				throw new CongaTemplateException(e.getMessage(),' TCDealQuoteDataHandler :: getTCPlanRateCard','Q');
			}   
			return rows; 
		}
		public Map<String,String> getConstant(){
			Map<String,String> allConst = new Map<String,String>(); 
			try{
				AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
				list<String> productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ApexConstant'));
				system.debug(productSpecCodes); 
				allConst = new Map<String,String>(); 
				List<String> constKeyValueList = null; 
				for(String v:productSpecCodes){
					constKeyValueList = v.split(':'); 
					allConst.put(constKeyValueList[0],constKeyValueList[1]);
				}
				system.debug('***Telstra:TCDealQuoteDataHandler:getConstant:allConst'+allConst); 
				return allConst; 
			}
			
			catch(Exception e){   
				System.debug('***Telstra:TCDealQuoteDataHandler:getConstant:exception:'+e.getLineNumber()+' '+e.getMessage()); 
				throw new CongaTemplateException(e.getMessage(),' TCDealQuoteDataHandler :: getConstant','Q');
			} 
			
		}
		public Decimal getQuantity(Decimal quantity, Decimal reQuantity ){
			Decimal qty = 0; 
			
			if((quantity != null && quantity >0 ) && (reQuantity != null && reQuantity >0 )){
				qty = quantity + reQuantity ;
				return qty;
			}
			else if (quantity != null && quantity >0 ){
				return quantity ;
			}
			else if(reQuantity != null && reQuantity >0 ){
				return reQuantity ;
			}  else {
				return qty ; 
			}
		}
	}