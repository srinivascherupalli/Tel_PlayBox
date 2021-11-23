/********************************************************************************************************************************************
Sr.No. Author 		 Date			Sprint   	  Story number 	Description
1.	   Aman Soni	 3-June-2020	20.08(New JS) EDGE-148729	Next Generation Mobility Helper JS
2.	   Laxmi Rahate	 5-June-2020	20.09		  EDGE-150795	Enabling Order Enrichment
3.     Shubhi		 8-June-2020	20.08		  EDGE-148662	Enabling one fund and POS
4.     Aman Soni	23-June-2020	20.09		  EDGE-148667	Added EmptyRelProdAttLst,inValidateDeviceCareConfigOnEligibility,UpdateChildFromParentAtt
5.	   Ankit		26-june-2020	20.09		  EDGE-148733	Enabling Device Id on MACD
6.     Laxmi Rahate	30-Jun-2020		20.09		  EDGE-154021 	Handling OE for MAC and Cancel
7. 	   Aditya Pareek 15-July-20 	20.09		  EDGE-148738	Change Type is not updating for Main Solution on MAC
8.     Aman Soni	 20-July-2020	20.10		  EDGE-154026 	Added Code for Next Gen Plan
9.     Aman Soni	 20-July-2020	20.10		  EDGE-154028 	Added Code for Next Gen Plan
10.    Aman Soni	 20-July-2020	20.10		  EDGE-154029 	Added Code for Next Gen Plan
11.    Aman Soni	 20-July-2020	20.10		  EDGE-154238 	Added Code for Next Gen Plan
12.	   Laxmi Rahate	 27-July-2020	20.10 		  EDGE-154663   Added generic method for gettign attribute Value
13     Laxmi Rahate  30-July-2020   20.10		  EDGE-154680	MAC for Mobility Features
14.    Arinjay       20-Jul-2020   20.10          EDGE-164211   Spring 20 Upgrade
15     Ankit/Shubhi/aditya/aman  25/08/2020   20.11     post upgrade js upliftment
16     Shubhi /samish             28-july-2020    20.12          //EDGE-165013
17.    Shubhi/Hitesh 28.July.2020   20.12       EDGE-157919,EDGE-157747,EDGE-157745
18.    Shubhi        28.July.2020   20.12       EDGE-157797(Ir Month Pass)
19.    Gnana         31-Aug-2020    20.12       EDGE-154688 NGEM Plan Cancel
20.    Aman Soni     31-Aug-2020    20.12       EDGE-157745 	DefaultMsgBank
21.    Aman Soni     31-Aug-2020    20.12       EDGE-157745 	DefaultBDD
22.    Aman Soni     31-Aug-2020    20.12       EDGE-160039 	RoundingOffAttribute
23.    Laxmi 		 04-Sep-2020	20.12		EDGE-154696     Applecare Cancellation
24.    Aarathi/Manish    04 Sept 2020   20.12           EDGE- 164351    AppleCare Cancellation
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/
console.log(':::::: Next Generation Mobility Helper resource ::::::');
var showMsg = true;
var NextGenMobHelper = {

/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : getBasketData
 * Invoked When: multiple occurrences
 * Parameters  : basketId, componentName
 ***********************************************************************************/
//Arinjay : JSUpdgrade
getBasketData: async function (basketId, componentName) {
	let currentBasket =  await CS.SM.getActiveBasket(); 
	let inputMap = {};
	inputMap['GetBasket'] = currentBasket.basketId;
	inputMap['GetSiteId'] = '';
	await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
		var basket = JSON.parse(result["GetBasket"]);
		basketChangeType = basket.csordtelcoa__Change_Type__c;
		basketStage = basket.csordtelcoa__Basket_Stage__c;
		accountId__NEXTGENMOB = basket.csbb__Account__c; // added by shubhi EDGE-148662
		accountId = basket.csbb__Account__c;
		communitySiteId_NGEM = result["GetSiteId"]; // added by shubhi EDGE-148662
		basketNum_NEXTGENMOB = basket.Name; // added by shubhi EDGE-148662
		window.oeSetBasketData(basketId, basketStage, accountId);
		if (accountId !== null && accountId !== '') {
			CommonUtills.setAccountID(componentName, accountId);
		}
            CommonUtills.setBasketChange();
	});
},

/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : MandateCompBasedOnOfferName
 * Invoked When: Offer Name is updated
 * Sprint	   : 20.10 (EDGE-154026)
 * Parameters  : Blank
 ************************************************************************************/

MandateCompBasedOnOfferName: async function() {
		var offerName;
		var offerId;
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			if(solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
				Object.values(solution.schema.configurations).forEach((solConfig) => {
					if(solConfig.guid){
						if(solConfig.attributes && Object.values(solConfig.attributes).length > 0){
								let attribs = Object.values(solConfig.attributes);
							    offerName = attribs.filter(obj => {
								return obj.name === 'Marketable Offer'
								});
								offerId = attribs.filter(obj => {
								return obj.name === 'OfferId'
								});
						}
					}
				});
			}
			if(solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach((comp) => {
					if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
						if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId){
							if(solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan))
								solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenPlan, 1, 9999);
							if(solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice))
								solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenDevice, 0, 9999);
						}
					}
					if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenDevice){
						if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId){
							if(solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice))
								solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenDevice, 1, 9999);
							if(solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan))
								solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenPlan, 0, 9999);
						}
					}
				});
			} 
		}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : InValidateNGEMPlan
 * Invoked When: Before Configuration Add
 * Sprint	   : 20.10 (EDGE-154026)
 * Parameters  : guid
 ************************************************************************************/
InValidateNGEMPlan: async function(guid) {
		var offerName;
		var offerId;
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			if(solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
				Object.values(solution.schema.configurations).forEach((solConfig) => {
					if(solConfig.guid){
						if(solConfig.attributes && Object.values(solConfig.attributes).length > 0){
								let attribs = Object.values(solConfig.attributes);
							    offerName = attribs.filter(obj => {
								return obj.name === 'Marketable Offer'
								});
								offerId = attribs.filter(obj => {
								return obj.name === 'OfferId'
								});
						}
					}
				});
			}
			if(solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach(async (comp) => {
					if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
						if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId){
							if(comp.schema && comp.schema.configurations && (Object.values(comp.schema.configurations).length > 0)){
								Object.values(comp.schema.configurations).forEach(async (config) => {
									let cnfg =  await comp.getConfiguration(config.guid); 
									cnfg.status = false;
									cnfg.statusMessage = 'You have selected a Device Only offer. Device only offers cannot contain Mobile Subscriptions';									
								});
																
							}
						}						
					}				
				});
			} 
		}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : InValidateNGEMPlanOnOfferChange
 * Invoked When: Before Configuration Add
 * Sprint	   : 20.10 (EDGE-154026)
 * Parameters  : guid
 ************************************************************************************/
InValidateNGEMPlanOnOfferChange: async function(guid){
		var offerName;
		var offerId;
		var solConfigId;
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			if(solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
				Object.values(solution.schema.configurations).forEach((solConfig) => {
					if(solConfig.guid){
						if(solConfig.attributes && Object.values(solConfig.attributes).length > 0){
							    offerName = Object.values(solConfig.attributes).filter(obj => {
								return obj.name === 'Marketable Offer'
								});
								offerId = Object.values(solConfig.attributes).filter(obj => {
								return obj.name === 'OfferId'
								});
						}
					}
					if(solConfig.guid === guid)
						solConfigId = solConfig.guid;
				});
			}
			if(solConfigId && solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach((comp) => {
					if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
						if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId){
							if(comp.schema && comp.schema.configurations && (Object.values(comp.schema.configurations).length > 0)){
								Object.values(comp.schema.configurations).forEach(async (config) => {
									let cnfg = await comp.getConfiguration(config.guid); 
									cnfg.status = false;
									cnfg.statusMessage = 'You have selected a Device Only offer. Device only offers cannot contain Mobile Subscriptions';
									
								}); 
							}
						}else if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId){
							if(comp.schema && comp.schema.configurations && (Object.values(comp.schema.configurations).length > 0)){
								Object.values(comp.schema.configurations).forEach(async (config) => {
									let cnfg1 = await comp.getConfiguration(config.guid); 
									cnfg1.status = true;
									cnfg1.statusMessage = '';
								}); 
							}
						}						
					}				
				});
			} 
		}
},
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : EmptyRelProdAttLst - To Empty Related Product Attributes on parent component attribute changes
 * Invoked When: related product is added
 * Sprint	  : 20.09 (EDGE-148667)
 * Parameters  : mainCompName, componentName, relatedCompName, attrList
 ***********************************************************************************/
// Arinjay JSUpgrade
EmptyRelProdAttLst: async function (guid, mainCompName, componentName, relatedCompName, attrList) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		var RelatedProdGuid;
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid) {
								if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
									Object.values(config.relatedProductList).forEach((relatedConfig) => {
										if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid === guid) {
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.guid) {
												RelatedProdGuid = relatedConfig.configuration.guid;
												NextGenMobHelper.EmptyAttributeLst(RelatedProdGuid, componentName, attrList);
											}
										}
									});
								}
							}
						});
					}
				}
			});
		}
	}
},
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : EmptyAttributeLst
 * Invoked When: multiple occurrences
 * Parameters  : guid, componentName, attributeList
 ***********************************************************************************/
// Arinjay JSUpgrade
EmptyAttributeLst: async function (guid, componentName, attributeList) {
	var attLst = attributeList;
	var attName;
	for (attName of attLst) {
            Utils.emptyValueOfAttribute(guid, componentName, attName, false);
	}
},
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : HideShowAttributeLstOnSaveNOnLoad
 * Invoked When: multiple occurrences
 * Parameters  : mainCompName, componentName, attributeList
 ***********************************************************************************/
// Arinjay JSUpgrade
HideShowAttributeLstOnSaveNOnLoad: async function (mainCompName, componentName, attributeList) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		//Block used to do manipulations/calling methods for Main Solution Component - 'Next Generation Enterprise Mobility' || Start
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			Object.values(solution.schema.configurations).forEach((solConfig) => {
				if (solConfig.guid && solConfig.replacedConfigId) {
					NextGenMobHelper.HideShowAttributeLst(true, false, solConfig.guid, mainCompName, componentName,'', attributeList[9], false, true, false);
					NextGenMobHelper.ReadOnlyMarketableOffer(mainCompName, solConfig.guid);
				}
			});
		}
		//Block used to do manipulations/calling methods for Main Solution Component - 'Next Generation Enterprise Mobility' || End
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMap = {};
			Object.values(solution.components).forEach((comp) => {
				//Block used to do manipulations/calling methods for Parent Component - 'Device' || Start
                    if (comp.name === NXTGENCON_COMPONENT_NAMES.nextGenDevice) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid) {
								var payTypeLookup;
								if (config.attributes && Object.values(config.attributes).length > 0) {
									let attribs = Object.values(config.attributes);
									payTypeLookup = attribs.filter(obj => {
										return obj.name === 'PaymentTypeString'
									});
									var manufacturer = attribs.filter(obj => {
										return obj.name === 'MobileHandsetManufacturer'
									});
									var model = attribs.filter(obj => {
										return obj.name === 'MobileHandsetModel'
									});
									var color = attribs.filter(obj => {
										return obj.name === 'MobileHandsetColour'
									});
									var devType = attribs.filter(obj => {
										return obj.name === 'Device Type'
									});
									var inContractDevEnrElig = attribs.filter(obj => {
										return obj.name === 'InContractDeviceEnrollEligibility'
									});
									var ChangeTypeAtr = attribs.filter(obj => {
										return obj.name === 'ChangeType'
									});
									var RemainingTermVal = attribs.filter(a => {
										return a.name === 'RemainingTerm';

                                        });
                                        if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Hardware Repayment') {
											if (!config.replacedConfigId){
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[0], false, false, false);	
											}                                           
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[1], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[4], false, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[2], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[5], false, true, true);
                                        }
                                        if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Purchase') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[1], true, false, false);
											if (!config.replacedConfigId){
												NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[0], false, true, false);
											}                                            
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[2], false, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[3], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'',attributeList[5], false, false, false);
                                        }
                                        if ((manufacturer && manufacturer[0] && manufacturer[0].value === '') || (model && model[0] && model[0].value === '') || (color && color[0] && color[0].value === '') || (devType && devType[0] && devType[0].value === '') || (payTypeLookup && payTypeLookup[0]&& payTypeLookup[0].value === '')) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[7], false, false, false);
                                        }
                                        if (!config.replacedConfigId) {
                                            if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].value !== '' && payTypeLookup[0].value !== null && payTypeLookup[0].value !== undefined) {
                                                if (inContractDevEnrElig[0].value !== '' && inContractDevEnrElig[0].value !== null) {
                                                    if (inContractDevEnrElig[0].value === 'Eligible') {
													NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], false, true, false);
                                                    } else {
                                                        NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], true, true, false);
                                                    }
                                                } else {
                                                    NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], true, false, false);
                                                }
                                            }
                                        }
                                        if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Hardware Repayment' && config.replacedConfigId) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[13], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
                                        }
                                        if (config.replacedConfigId && payTypeLookup && payTypeLookup[0]  && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Purchase') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[15], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false); //Added by ankit as part of EDGE-148733 
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
                                        }
                                        if (config.replacedConfigId && payTypeLookup && payTypeLookup[0]  && payTypeLookup[0].displayValue === 'Hardware Repayment' && ChangeTypeAtr[0].displayValue === 'Cancel') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[16], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[17], false, true, false);

                                        }
                                        if (config.replacedConfigId && ChangeTypeAtr[0].displayValue === 'Active' && RemainingTermVal[0].displayValue === null) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false);
                                        }
                                        if (config.replacedConfigId) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[10], false, true, false);
                                        }
                                        if (config.replacedConfigId && ChangeTypeAtr[0].displayValue === 'PaidOut') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[10], true, true, false);
                                        }

                                        //Block used to do manipulations/calling methods for Parent Component - 'Device' || End

                                        //Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
                                        if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                                            Object.values(config.relatedProductList).forEach((relatedConfig) => {
                                                if (relatedConfig.guid && relatedConfig.configuration.replacedConfigId !== '' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                                                    NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
                                                }
                                            });
                                        }
                                    }
                                    //Block used to do manipulations for Related Component - 'Mobile Device Care' || End
                                }
                            });
                        }
                    }
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
                        if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
                            if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
                                Object.values(comp.schema.configurations).forEach((planConfig) => {
                                    if(planConfig.guid && planConfig.attributes){
                                        var planTypeLookUp;
                                        let attribs = Object.values(planConfig.attributes);
                                        planTypeLookUp = attribs.filter(obj => {
                                            return obj.name === 'SelectPlanType'
                                        });
                                        var ChangeTypeAtr = attribs.filter(obj => {
                                            return obj.name === 'ChangeType'
                                        });
                                        if(planTypeLookUp[0].displayValue===NGEMPLans.Enterprise_Wireless && ChangeTypeAtr[0].displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[19], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[24], true, false, false);
                                        }else if(ChangeTypeAtr[0].displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[19], true, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[24], false, true, false);
                                        }
                                        if(planConfig.guid && planConfig.replacedConfigId !== '' && planConfig.replacedConfigId !== undefined && planConfig.replacedConfigId !== null && ChangeTypeAtr[0].displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[18], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[10], false, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[23], true, false, false);
                                        }
										// Added below block as part of EDGE-154688 - Start
                                        if(planConfig.replacedConfigId && ChangeTypeAtr[0].displayValue === 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[20], false, true, true);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[21], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[22], true, true, false);
                                        }
                                        // Added block as part of EDGE-154688 - End
                                        if(planTypeLookUp[0].displayValue===NGEMPLans.Enterprise_Wireless && planConfig.replacedConfigId){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[25], true, true, false);
                                        }
                                        if (planConfig.relatedProductList && Object.values(planConfig.relatedProductList).length > 0) {
                                            Object.values(planConfig.relatedProductList).forEach((relatedConfig) => {
                                                if(relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.dataFeatures) && relatedConfig.guid){
                                                    if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
                                                        if(planTypeLookUp[0].displayValue === NGEMPLans.Enterprise_Wireless){
                                                            NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[27], true, false, false);
															NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[26], false, true, false);
															NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[29], true, true, false);
															NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[28], true, false, false);
                                                        }
                                                    if(planTypeLookUp[0].displayValue === NGEMPLans.Handheld || planTypeLookUp[0].displayValue === NGEMPLans.Mobile_Broadband){
                                                    NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[26], true, false, false);
													NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[27], false, true, false);
													NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[28], true, true, false);
													NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[29], true, false, false);
                                                }
                                            }
                                        }
                                            });
                                        }

                                    }

                                    
                                });
                            }
                        }
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End
                });
            }
        }
    },

/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : HideShowAttributeLst
 * Invoked When: multiple occurrences
 * Parameters  : guid, mainCompName, componentName, attributeList, IsreadOnly, isVisible, isRequired
 ***********************************************************************************/
//Arinjay JSUpgrade
HideShowAttributeLst: async function (IsMain, IsRelated, guid, mainCompName, componentName,relatedproductName, attributeList, IsreadOnly, isVisible, isRequired) 
{
	let product = await CS.SM.getActiveSolution();
	var componentMapNextGen = new Map();
	var componentMapattrNextGen = {};
	//Block used to do manipulations for Main Solution Component - 'Next Generation Enterprise Mobility' || Start
	if (IsMain && !IsRelated && product.name === mainCompName) {
		if (product.schema && product.schema.configurations && Object.values(product.schema.configurations).length > 0) {
			Object.values(product.schema.configurations).forEach((solConfig) => {
				if (solConfig.guid === guid) {
					for (var i = 0; i < attributeList.length; i++) {
						componentMapattrNextGen[attributeList[i]] = [];
						componentMapattrNextGen[attributeList[i]].push({
							'IsreadOnly': IsreadOnly,
							'isVisible': isVisible,
							'isRequired': isRequired
						});
					}
					componentMapNextGen.set(guid, componentMapattrNextGen);
				}
			});
		}
		CommonUtills.attrVisiblityControl(mainCompName, componentMapNextGen);
	}
	//Block used to do manipulations for Main Solution Component - 'Next Generation Enterprise Mobility' || End

	//Block used to do manipulations for Parent Component - 'Device' || Start
	if (!IsMain && !IsRelated && product.name === mainCompName) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if (comp.name === componentName) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid === guid) {
								for (var i = 0; i < attributeList.length; i++) {
									componentMapattrNextGen[attributeList[i]] = [];
									componentMapattrNextGen[attributeList[i]].push({
										'IsreadOnly': IsreadOnly,
										'isVisible': isVisible,
										'isRequired': isRequired
									});
								}
								componentMapNextGen.set(guid, componentMapattrNextGen);
							}
						});
					}
					CommonUtills.attrVisiblityControl(componentName, componentMapNextGen);
				}
			});
		}
	}
	//Block used to do manipulations for Parent Component - 'Device' || End	

	//Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
	if (!IsMain && IsRelated && product.name === mainCompName) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if (comp.name === componentName) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid === guid) {
								if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
									Object.values(config.relatedProductList).forEach((relatedConfig) => {
										if (relatedConfig.name.includes(relatedproductName) && relatedConfig.guid) {
											for (var i = 0; i < attributeList.length; i++) {
												componentMapattrNextGen[attributeList[i]] = [];
												componentMapattrNextGen[attributeList[i]].push({
													'IsreadOnly': IsreadOnly,
													'isVisible': isVisible,
													'isRequired': isRequired
												});
											}
											componentMapNextGen.set(relatedConfig.guid, componentMapattrNextGen);
										}
									});
								}
							}
						});
					}
					CommonUtills.attrVisiblityControl(componentName, componentMapNextGen);
				}
			});
		}
	}
	//Block used to do manipulations for Related Component - 'Mobile Device Care' || End
},
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : UpdateOneAttFromAnotherAtt
 * Invoked When: multiple occurrences
 * Parameters  : guid, mainCompName, componentName, UpdatingAttribute, TobeUpdatedAttribute
 ***********************************************************************************/
// Arinjay JSUpgrade
UpdateOneAttFromAnotherAtt: async function (guid, mainCompName, componentName, UpdatingAttribute, TobeUpdatedAttribute) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMap = {};
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === componentName) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							if (config.guid == guid) {
								if (config.attributes && Object.values(config.attributes).length > 0) {
									var updatingAtt = Object.values(config.attributes).filter(obj => {
										return obj.name === UpdatingAttribute
									});
									var updatedAtt = Object.values(config.attributes).filter(obj => {
										return obj.name === TobeUpdatedAttribute
									});

                                        if (updatingAtt && updatingAtt.length > 0) {
                                            if (updatingAtt[0].value !== null && updatingAtt[0].value !== '') {
                                                updatedAtt[0].value = updatingAtt[0].value;
                                                updatedAtt[0].displayValue = updatingAtt[0].displayValue;
                                            }
                                        }
                                        updateMap[config.guid] = [];
                                        updateMap[config.guid].push({
                                            name: TobeUpdatedAttribute,
                                            value: updatedAtt[0].value,
                                            displayValue: updatedAtt[0].displayValue
                                        });
                                    }
                                }
                                
                                var complock = comp.commercialLock;
                                if(complock) component.lock('Commercial', false);
                                let keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
                                }
                                if (complock) comp.lock('Commercial', true);
                            });
                        }
                    }
                });
            }
        }
    },
    /************************************************************************************
     * Author	   : Aman Soni
     * Method Name : NGDDeviceEnrolmentOnAttUpdate
     * Invoked When: multiple occurrences
     * Parameters  : guid, mainCompName, componentName
     ***********************************************************************************/
    // Arinjay JSUpgrade
    NGDDeviceEnrolmentOnAttUpdate: async function (guid, mainCompName, componentName) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(mainCompName)) {
            var updateMapNGD = {};
            if (solution.components && Object.values(solution.components).length > 0) {
                Object.values(solution.components).forEach((comp) => {
                    if (comp.name === componentName) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach((config) => {
                                if ((config.guid === guid) && !config.replacedConfigId) {
                                    if (config.attributes && Object.values(config.attributes).length > 0) {
                                        Object.values(config.attributes).forEach(async (configAttr) => {
                                            if (configAttr.name === 'InContractDeviceEnrollEligibility') {
                                                if (configAttr.value !== '' && configAttr.value !== null) {
                                                    if (configAttr.value === 'Eligible') {
                                                        updateMapNGD[config.guid] = [{
                                                            name: 'DeviceEnrollment',
                                                            value: "DO NOT ENROL",
                                                            displayValue: "DO NOT ENROL",
                                                            required: true,
                                                            showInUI: true,
                                                            readOnly: false,
                                                            options: ["ENROL",
                                                                "DO NOT ENROL"
                                                            ]
                                                        }];
                                                    } else {
                                                        updateMapNGD[config.guid] = [{
                                                            name: 'DeviceEnrollment',
                                                            value: "NOT ELIGIBLE",
                                                            displayValue: "NOT ELIGIBLE",
                                                            showInUi: true,
                                                            readOnly: true,
                                                            options: ["NOT ELIGIBLE"]
                                                        }];
                                                    }
                                                } else {
                                                    updateMapNGD[config.guid] = [{
                                                        name: 'DeviceEnrollment',
                                                        value: "",
                                                        displayValue: "",
                                                        showInUi: false,
                                                        readOnly: true,
                                                        options: [""]
                                                    }];
                                                }
                                                
                                                var complock = comp.commercialLock;
                                                if(complock) comp.lock('Commercial', false);
                                                let keys = Object.keys(updateMapNGD);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await comp.updateConfigurationAttribute(keys[i], updateMapNGD[keys[i]], true); 
                                                }
                                                if(complock) comp.lock('Commercial', true);
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                });
            }
        }
        return Promise.resolve(true);
    },
    /************************************************************************************
     * Author	  : Aman Soni
     * Method Name : NGDDeviceEnrolmentOnLoadNSave
     * Invoked When: On Load and after Save
     * Parameters  : mainCompName, componentName
     ***********************************************************************************/
    // Arinjay JSUpgrade
    NGDDeviceEnrolmentOnLoadNSave: async function (mainCompName, componentName) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(mainCompName)) {
            var updateMapNGD = {};
            if (solution.components && Object.values(solution.components).length > 0) {
                Object.values(solution.components).forEach(async (comp) => {
                    if (comp.name === componentName) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach((config) => {
                                if (config.guid && !config.replacedConfigId) {
                                    if (config.attributes && Object.values(config.attributes).length > 0) {
                                        Object.values(config.attributes).forEach((configAttr) => {
                                            if (configAttr.name === 'InContractDeviceEnrollEligibility') {
                                                if (configAttr.value === 'Eligible') {
                                                    updateMapNGD[config.guid] = [{
                                                        name: 'DeviceEnrollment',
                                                        required: true,
                                                        showInUI: true,
                                                        readOnly: false,
                                                        options: ["ENROL",
                                                            "DO NOT ENROL"
                                                        ]
                                                    }];
                                                } else {
                                                    updateMapNGD[config.guid] = [{
                                                        name: 'DeviceEnrollment',
                                                        value: "NOT ELIGIBLE",
                                                        displayValue: "NOT ELIGIBLE",
                                                        showInUi: true,
                                                        readOnly: true,
                                                        options: ["NOT ELIGIBLE"]
                                                    }];
                                                }
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                });
                let component = await solution.getComponentByName(componentName); 
                
                var complock = component.commercialLock;
                if(complock) component.lock('Commercial', false);
                let keys = Object.keys(updateMapNGD);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateMapNGD[keys[i]], true); 
                }
                if(complock) component.lock('Commercial', true);
            }
        }
        return Promise.resolve(true);
    },
    /************************************************************************************
     * Author	  	: Aman Soni
     * Method Name  : CalculationforDeviceCompAtts
     * Invoked When : multiple occurences
     * Sprint	    : 20.09 (EDGE-148667)
     * Parameters   : mainCompName, componentName
     ***********************************************************************************/
    // Arinjay JSUpgrade
    CalculationforDeviceCompAtts: async function (mainCompName, componentName) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(mainCompName)) {
            if (solution.components && Object.values(solution.components).length > 0) {
                var updateMap = {};
                Object.values(solution.components).forEach((comp) => {
                    if (comp.name.includes(componentName)) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach(async (config) => {
                                if (config.guid) {
                                    let attribs = Object.values(config.attributes);
                                    if (config.attributes && attribs.length > 0) {
                                        var OCExGST = attribs.filter(obj => {
                                            return obj.name === 'OC'
                                        });
                                        var RCExGST = attribs.filter(obj => {
                                            return obj.name === 'RC'
                                        });
                                        var OCIncGST = attribs.filter(obj => {
                                            return obj.name === 'OneOffChargeGST'
                                        });
                                        var RCIncGST = attribs.filter(obj => {
                                            return obj.name === 'InstalmentChargeIncGST'
                                        });
                                        var conTerm = attribs.filter(obj => {
                                            return obj.name === 'ContractTerm'
                                        });
                                        var payTypeString = attribs.filter(obj => {
                                            return obj.name === 'PaymentTypeString'
                                        });
                                        var conTermString = attribs.filter(obj => {
                                            return obj.name === 'ContractTermString'
                                        });
                                        var OCExGSTRounded = parseFloat(OCExGST[0].value).toFixed(2);
                                        var ContTermStrValue = conTermString[0].value;
                                        var RCExGSTRounded;
                                        var RCIncGSTRounded;
                                        var OCIncGSTRounded;
                                        var RCExGSTFinal;
                                        var RCIncGSTFinal;
                                        var OCIncGSTFinal;

									if (payTypeString && payTypeString[0].value === 'Hardware Repayment' && conTerm && conTerm[0].value !== null && conTerm[0].value !== '' && conTerm[0].value !== undefined) {
										if (OCExGSTRounded !== null && OCExGSTRounded !== '' && ContTermStrValue !== null && ContTermStrValue !== '') {
											RCExGSTRounded = (OCExGSTRounded / ContTermStrValue);
											RCExGSTFinal = parseFloat(RCExGSTRounded).toFixed(2);
											if (RCExGSTFinal !== null && RCExGSTFinal !== '') {
												RCIncGSTRounded = (RCExGSTFinal * 1.1);
												RCIncGSTFinal = parseFloat(RCIncGSTRounded).toFixed(2);
											}
										}
									}
									if (payTypeString && payTypeString[0].value === 'Hardware Repayment' && (conTerm[0].value === null || conTerm[0].value === '' || conTerm[0].value === undefined)) {
										RCExGSTFinal = 0.0;
										RCIncGSTFinal = 0.0;
									}
									if (payTypeString && payTypeString[0].value === 'Purchase') {
										RCExGSTFinal = 0.0;
										RCIncGSTFinal = 0.0;
										OCIncGSTRounded = (OCExGSTRounded * 1.1);
										OCIncGSTFinal = parseFloat(OCIncGSTRounded).toFixed(2);
									}
									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: 'RC',
											value: RCExGSTFinal,
											displayValue: RCExGSTFinal
									});
									updateMap[config.guid].push({
										name: 'OC',
											value: OCExGSTRounded,
											displayValue: OCExGSTRounded
									});
									updateMap[config.guid].push({
										name: 'InstalmentChargeIncGST',
											value: RCIncGSTFinal,
											displayValue: RCIncGSTFinal
									});
									updateMap[config.guid].push({
										name: 'OneOffChargeGST',
											value: OCIncGSTFinal,
											displayValue: OCIncGSTFinal
									});
								}
							}
							let keys = Object.keys(updateMap);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
							}
						});
					}
				}
			});
		}
	}
},
/************************************************************************************
 * Author	  	: Aman Soni
 * Method Name 	: CalcForDeviceCareCompAtts
 * Invoked When	: multiple occurences
 * Sprint	  	: 20.09 (EDGE-148667)
 * Parameters  	: guid, mainCompName, componentName
 ***********************************************************************************/
// Arinjay JSUpgrade
CalcForDeviceCareCompAtts: async function (guid, mainCompName, componentName) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMap = {};
			Object.values(solution.components).forEach((comp) => {
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid) {
								if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
									Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
										if (relatedConfig.guid === guid) {
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
												let attribs = Object.values(relatedConfig.configuration.attributes);
												var paymentType = attribs.filter(obj => {
													return obj.name === 'DeviceCarePaymentTypeLookup'
												});
												var planType = attribs.filter(obj => {
													return obj.name === 'DeviceCarePlanLookup'
												});
												var oc = attribs.filter(obj => {
													return obj.name === 'OC'
												});
												var ocGST = attribs.filter(obj => {
													return obj.name === 'OneOffChargeGST'
												});
												if (oc && oc[0].value !== null && oc[0].value !== '') {
													var OCRounded = parseFloat(oc[0].value).toFixed(2);
												}

												var ocGSTRounded;
												if (paymentType && paymentType[0].displayValue === 'Purchase') {
													if (OCRounded !== null && OCRounded !== '') {
														ocGST = (OCRounded * 1.1);
														ocGSTRounded = parseFloat(ocGST).toFixed(2);
													}
												}
												if (paymentType && (paymentType[0].displayValue === '' || paymentType[0].displayValue === null || paymentType[0].displayValue === undefined)) {
													OCRounded = 0.0;
													ocGSTRounded = 0.0;
												}
												if (planType && (planType[0].displayValue === '' || planType[0].displayValue === null || planType[0].displayValue === undefined)) {
													OCRounded = 0.0;
													ocGSTRounded = 0.0;
												}
												updateMap[relatedConfig.guid] = [];
												updateMap[relatedConfig.guid].push({
													name: 'OC',
														value: OCRounded,
														displayValue: OCRounded													
												});
												updateMap[relatedConfig.guid].push({
													name: 'OneOffChargeGST',
														value: ocGSTRounded,
														displayValue: ocGSTRounded
												});
											}
										}
										let keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
										}
									});
								}
							}
						});
					}
				}
			});
		}
	}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : CalcforNGEMPlanCompAtts
 * Invoked When: multiple occurences
 * Sprint	   : 20.10 (EDGE-148667)
 * Parameters  : mainCompName, componentName
 ***********************************************************************************/
CalcforNGEMPlanCompAtts: async function(mainCompName, componentName) {
	let solution = await CS.SM.getActiveSolution();
	if(solution.name.includes(mainCompName)){
		if(solution.components && Object.values(solution.components).length > 0){
			var updateMap = {};
			Object.values(solution.components).forEach((comp) => {
				 if(comp.name.includes(componentName)){
					 if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
						 Object.values(comp.schema.configurations).forEach(async (config) =>{
							 if(config.guid){
								 let attribs = Object.values(config.attributes);
								 if(config.attributes && attribs.length > 0){									
									var planName = attribs.filter(obj => {
                                        return obj.name === 'Select Plan'
                                    });
									var planType = attribs.filter(obj => {
                                        return obj.name === 'SelectPlanType'
                                    });									
									var RCExGST = attribs.filter(obj => {
                                        return obj.name === 'RC'
                                    });
									var RCIncGST = attribs.filter(obj => {
                                        return obj.name === 'RC Inc GST'
                                    });
									var RCExGSTRounded = parseFloat(RCExGST[0].value).toFixed(2);
									var RCIncGSTRounded;

									if(RCExGSTRounded !== null && RCExGSTRounded !== ''){
										   RCIncGST = (RCExGSTRounded * 1.1);
										   RCIncGSTRounded = parseFloat(RCIncGST).toFixed(2);								   
									}
								
									if((planName && planName[0].value === '') || (planType && planType[0].value === '')){
										RCExGSTRounded = 0.0;
										RCIncGSTRounded = 0.0;
									}									
									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: 'RC',
											value: RCExGSTRounded,
											displayValue: RCExGSTRounded
									});
									updateMap[config.guid].push({
										name: 'RC Inc GST',
											value: RCIncGSTRounded,
											displayValue: RCIncGSTRounded
									});									
								 }
							 }
							 let keys = Object.keys(updateMap);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
							}
						 });
					 }
				 }
			});
		}
	}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : inValidateDeviceCareConfigOnEligibilityLoad
 * Invoked When: related product is added
 * Sprint	   : 20.09 (EDGE-148667)
 * Parameters  : mainCompName, componentName, relatedConfigGuid
 ***********************************************************************************/
// Arinjay JSUpgrade
inValidateDeviceCareConfigOnEligibilityLoad: async function (mainCompName, componentName) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							if (config.guid) {
								var DeviceReplaceConfigId = config.replacedConfigId;
								if (config.attributes && Object.values(config.attributes).length > 0) {
									var devCareEligibility = Object.values(config.attributes).filter(obj => {
										return obj.name === 'DeviceCareEligibility'
									});
									var deviceColor = Object.values(config.attributes).filter(obj => {
										return obj.name === 'MobileHandsetColour'
									});
									if ((deviceColor[0].value !== '' && deviceColor[0].value !== null && deviceColor[0].value !== undefined) && devCareEligibility[0].value !== 'Eligible' && config.relatedProductList && (Object.values(config.relatedProductList).length > 0 || Object.values(config.relatedProductList).length === 1)) {
										if (config.guid) {
											config.relatedProductList.forEach(async (relatedConfig) => {
												if (relatedConfig.guid) {
													let cnfg = await comp.getConfiguration(config.guid); 
													cnfg.status = false;
													cnfg.statusMessage = 'Device Care is not applicable for the selected Device.';
													
													let cnfg1 = await comp.getConfiguration(relatedConfig.guid); 
													cnfg1.status = false;
													cnfg1.statusMessage = 'Device Care is not applicable for the selected Device.';
												}
											});
										}
									}
									if (devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length > 1) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if (relatedConfig.guid) {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Only 1 Device Care can be configured for the selected Device.';
											}
										});
									} else if (devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length === 1) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if(relatedConfig.guid){
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = true;
												cnfg.statusMessage = '';
											}
										});
									}
									if ((devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length > 0)) {
										let cnfg = await comp.getConfiguration(config.guid); 
										cnfg.status = true;
										cnfg.statusMessage = '';
									}

									if (devCareEligibility[0].value !== 'Eligible' && Object.values(config.relatedProductList).length === 0) {
										let cnfg = await comp.getConfiguration(config.guid); 
										cnfg.status = true;
										cnfg.statusMessage = '';
									}
									if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if (DeviceReplaceConfigId && DeviceReplaceConfigId !== '' && DeviceReplaceConfigId !== undefined && DeviceReplaceConfigId !== null && relatedConfig.guid && (relatedConfig.configuration.replacedConfigId === '' || relatedConfig.configuration.replacedConfigId === null || relatedConfig.configuration.replacedConfigId === undefined)) {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Device Care can only be added as part of New Order.';
											}
										});
									}
								}
							}
						});
					}
				}
			});
		}
	}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : inValidateDeviceCareConfigOnEligibility
 * Invoked When: related product is added
 * Sprint	   : 20.09 (EDGE-148667)
 * Parameters  : mainCompName, componentName, relatedConfigGuid
 ***********************************************************************************/
// Arinjay JSUpgrade
inValidateDeviceCareConfigOnEligibility: async function (DeviceConfigGuid, relatedguid, mainCompName, componentName) {
	var offerId;
	var offerName;
	var deviceCount;
	var planCount;
	var deviceConfig;
	var planConfig;
	var planReplaceConfig;
	var devReplaceConfig;
	let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(mainCompName)){
				if(solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
					Object.values(solution.schema.configurations).forEach((solConfig) => {
						if(solConfig.guid){
							if(solConfig.attributes && Object.values(solConfig.attributes).length > 0){
									offerName = Object.values(solConfig.attributes).filter(obj => {
									return obj.name === 'Marketable Offer'
									});
									offerId = Object.values(solConfig.attributes).filter(obj => {
									return obj.name === 'OfferId'
									});
							}
						}
					});
				}			
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
					if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
						deviceCount = 0;
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((devConfig) => {
							deviceConfig = devConfig.guid;
							devReplaceConfig = devConfig.replacedConfigId;
							if(deviceConfig && (devReplaceConfig === undefined || devReplaceConfig === null || devReplaceConfig === '')){
								deviceCount = deviceCount + 1;
							}							
							});
						}
					}
					if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
						planCount = 0;
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((plnConfig) => {
							planConfig = plnConfig.guid;
							planReplaceConfig = plnConfig.replacedConfigId;
							if(planConfig && (planReplaceConfig === undefined || planReplaceConfig === null || planReplaceConfig === '')){
								planCount = planCount + 1;
							}								
							});
						}
					}
			if((offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && deviceCount <= planCount) || (offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId)){
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							if (config.guid) {
								var DeviceReplaceConfigId = config.replacedConfigId;
								if (config.attributes && Object.values(config.attributes).length > 0) {
									var devCareEligibility = Object.values(config.attributes).filter(obj => {
										return obj.name === 'DeviceCareEligibility'
									});
									var deviceColor = Object.values(config.attributes).filter(obj => {
										return obj.name === 'MobileHandsetColour'
									});
									if ((deviceColor[0].value !== '' && deviceColor[0].value !== null && deviceColor[0].value !== undefined) && devCareEligibility[0].value !== 'Eligible' && config.relatedProductList && (Object.values(config.relatedProductList).length > 0 || Object.values(config.relatedProductList).length === 1)) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											let cnfg = await comp.getConfiguration(config.guid); 
											cnfg.status = false;
											cnfg.statusMessage = 'Device Care is not applicable for the selected Device.';
											
											let cnfg1 = await comp.getConfiguration(relatedConfig.guid); 
											cnfg1.status = false;
											cnfg1.statusMessage = 'Device Care is not applicable for the selected Device.';
										});
									}
									if (devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length > 1) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if (relatedConfig.guid === relatedguid) {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Only 1 Device Care can be configured for the selected Device.';
											}
										});
									} else if (devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length === 1) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if (relatedConfig.guid === relatedguid) {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = true;
												cnfg.statusMessage = '';
											}
										});
									}
									if ((deviceColor[0].value !== '' && deviceColor[0].value !== null && deviceColor[0].value !== undefined) && devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length === 1) {
										if (config.guid === DeviceConfigGuid) {
											Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Please reselect the Device Care Plan.';
												
												let cnfg1 = await comp.getConfiguration(config.guid); 
												cnfg1.status = false;
												cnfg1.statusMessage = 'Please reselect the Device Care Plan.';

											});
										}
									}
									else {
										if ((devCareEligibility[0].value === 'Eligible' && config.relatedProductList && Object.values(config.relatedProductList).length > 0)) {
											let cnfg = await comp.getConfiguration(config.guid); 
											cnfg.status = true;
											cnfg.statusMessage = '';
										}
									}

									if (devCareEligibility[0].value !== 'Eligible' && Object.values(config.relatedProductList).length === 0) {
										let cnfg = await comp.getConfiguration(config.guid); 
										cnfg.status = true;
										cnfg.statusMessage = '';
									}
									if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if (DeviceReplaceConfigId && DeviceReplaceConfigId !== '' && DeviceReplaceConfigId !== undefined && DeviceReplaceConfigId !== null && relatedConfig.guid && (relatedConfig.configuration.replacedConfigId === '' || relatedConfig.configuration.replacedConfigId === null || relatedConfig.configuration.replacedConfigId === undefined)) {
												let cnfg = await comp.getConfiguration(relatedConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Device Care can only be added as part of New Order.';
											}
										});
									}
								}
							}
						});
					}
				}
			  }
			});
		}
	}
},

/************************************************************************************
 * Author	  	: Aman Soni
 * Method Name 	: validateDeviceConfig
 * Invoked When	: multiple occurences
 * Sprint	  	: 20.09 (EDGE-148667)
 * Parameters  	: guid, mainCompName, componentName
 ***********************************************************************************/
// Arinjay JSUpgrade
validateDeviceConfig: async function (guid, mainCompName, componentName) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMap = {};
			Object.values(solution.components).forEach((comp) => {
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							if(config.guid){
								if(config.relatedProductList && (Object.values(config.relatedProductList).length == 1)) {
									Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
										if (relatedConfig.guid === guid){
											let cnfg = await comp.getConfiguration(config.guid); 
											cnfg.status = true;
											cnfg.statusMessage = '';
											
											let cnfgR = await comp.getConfiguration(relatedConfig.guid); 
											cnfgR.status = true;
											cnfgR.statusMessage = '';
										}
									});
								}
							}
						});
					}
				}
			});
		}
	}
},
/************************************************************************************
 * Author	   : Aman Soni
 * Method Name : UpdateChildFromParentAtt - To update Parent comp att to Child att
 * Invoked When: related product is added
 * Sprint	   : 20.09 (EDGE-148667)
 * Parameters  : mainCompName, componentName, relatedCompName
 ************************************************************************************/
// Arinjay JSUpgrade 
UpdateChildFromParentAtt: async function (mainCompName, componentName, relatedCompName) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMapDeviceCare = {};
			Object.values(solution.components).forEach((comp) => {
				if (comp.name.includes(componentName)) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
                                if (config.guid){
                                    if (config.attributes && Object.values(config.attributes).length > 0) {
                                        var parentSKU = Object.values(config.attributes).filter(obj => {
                                            return obj.name === 'DeviceSKU'
                                        });
                                        if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                                            Object.values(config.relatedProductList).forEach((relatedConfig) => {
                                                if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid) {
                                                    if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                                        var childSKU = Object.values(relatedConfig.configuration.attributes).filter(obj => {
                                                            return obj.name === 'DeviceSKU'
                                                        });
                                                        updateMapDeviceCare[relatedConfig.guid] = [];
                                                        updateMapDeviceCare[relatedConfig.guid].push({
                                                            name: childSKU[0].name,
                                                                showInUi: false,
                                                                readOnly: true,
                                                                value: parentSKU[0].value,
                                                                displayValue: parentSKU[0].value
                                                        });
                                                    }
                                                }
                                            });
                                        }
                                    }
                                }
                                let keys = Object.keys(updateMapDeviceCare);
                                var complock = comp.commercialLock;
                                if(complock) comp.lock('Commercial', false);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], updateMapDeviceCare[keys[i]], true); 
                                }
                                if(complock) comp.lock('Commercial', true);
                            });
                        }
                    }
                });
            }
        }
    },
    /************************************************************************************
     * Author	   : Aman Soni
     * Method Name : DeviceAndPlanCount
     * Invoked When: Device Configuration is added
     * Sprint	   : 20.10 (EDGE-154028)
     * Parameters  : Blank
     ***********************************************************************************/
    DeviceAndPlanCount: async function() {
            let solution = await CS.SM.getActiveSolution();
            var deviceCount;
            var planCount;
            var deviceConfig;
            var planConfig;
            var planReplaceConfig;
            var devReplaceConfig;
            var offerName;
            var offerId;
            if(solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname) {
                if(solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
                    Object.values(solution.schema.configurations).forEach((solConfig) => {
                        if(solConfig.guid){
                            if(solConfig.attributes && Object.values(solConfig.attributes).length > 0){
                                    offerName = Object.values(solConfig.attributes).filter(obj => {
                                    return obj.name === 'Marketable Offer'
                                    });
                                    offerId = Object.values(solConfig.attributes).filter(obj => {
                                    return obj.name === 'OfferId'
                                    });
                            }
                        }
                    });
                }
                if(solution.components && Object.values(solution.components).length > 0){
                    Object.values(solution.components).forEach((comp) => {
                        if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
                            deviceCount = 0;
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                Object.values(comp.schema.configurations).forEach((devConfig) => {
                                deviceConfig = devConfig.guid;
                                devReplaceConfig = devConfig.replacedConfigId;
                                if(deviceConfig && (devReplaceConfig === undefined || devReplaceConfig === null || devReplaceConfig === '')){
                                    deviceCount = deviceCount + 1;
                                }							
                                });
                            }
                        }
                        if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
                            planCount = 0;
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                Object.values(comp.schema.configurations).forEach((plnConfig) => {
                                planConfig = plnConfig.guid;
                                planReplaceConfig = plnConfig.replacedConfigId;
                                if(planConfig && (planReplaceConfig === undefined || planReplaceConfig === null || planReplaceConfig === '')){
                                    planCount = planCount + 1;
                                }								
                                });
                            }
                        }
                            if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
                                if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && (deviceCount > planCount)){
                                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                        Object.values(comp.schema.configurations).forEach(async (devConfigToUpdate) => {
                                        deviceConfigToUpd = devConfigToUpdate.guid;
                                        devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
                                        if(deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === '')){
                                            let cnfg = await comp.getConfiguration(deviceConfigToUpd); 
                                            cnfg.status = false;
                                            cnfg.statusMessage = 'Device quantity cannot exceed number of new plans ' + planCount + ' configured';
                                        }							
                                        });
                                    }
                        
                                }
                                else if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && (deviceCount <= planCount)){
                                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
                                        Object.values(comp.schema.configurations).forEach(async (devConfigToUpdate) => {
                                        deviceConfigToUpd = devConfigToUpdate.guid;
                                        devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
                                        if(deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === '')){
                                            let cnfg = await comp.getConfiguration(deviceConfigToUpd); 
                                            cnfg.status = true;
                                            cnfg.statusMessage = '';								
                                        }							
                                        });
                                    }
                                }
                                else if(offerId[0].displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && (deviceCount > planCount)){
                                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
                                        Object.values(comp.schema.configurations).forEach(async (devConfigToUpdate) => {
                                        deviceConfigToUpd = devConfigToUpdate.guid;
                                        devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
                                        if(deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === '')){
                                            let cnfg = await comp.getConfiguration(deviceConfigToUpd); 
                                            cnfg.status = true;
                                            cnfg.statusMessage = '';								
                                        }							
                                        });
                                    }
                                }
                            }					 
                    });
                }
            }
    },
    /************************************************************************************
     * Author	   : Aman Soni
     * Method Name : UpdatePlanAllowance
     * Invoked When: multiple occurences
     * Sprint	   : 20.10 (EDGE-154028)
     * Parameters  : Blank
     ***********************************************************************************/
    UpdatePlanAllowance: async function(guid, planValue){ 
            let solution = await CS.SM.getActiveSolution();
            let currentBasket =  await CS.SM.getActiveBasket(); 
            if(solution.name === NXTGENCON_COMPONENT_NAMES.nxtGenMainSol){
                var inputMap = {};
                var selectedPlan = planValue;
                var allowanceRecId = '';
                var allowanceValue = '';
                if(solution.components && Object.values(solution.components).length > 0){
                    Object.values(solution.components).forEach(async (comp) => {
                        if(comp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
                            if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
                                Object.values(comp.schema.configurations).forEach(async (config) =>{
                                    if(config.guid === guid && selectedPlan != ''){
                                        inputMap['priceItemId'] = selectedPlan;									
                                        await currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(async response => {
                                                if (response && response['allowances'] != undefined) {
                                                response['allowances'].forEach((a) =>{
                                                    if (a.Id != null){
                                                        allowanceRecId = a.cspmb__allowance__r.Id;
                                                        allowanceValue = a.cspmb__allowance__r.Name;
                                                    }
                                                });
                                                    if(allowanceRecId != ''){
                                                        let updateConfigMap = {};
                                                        updateConfigMap[config.guid] = [{
                                                            name: 'PlanAllowance',
                                                            value: allowanceRecId,
                                                            displayValue: allowanceValue
                                                        }];													
                                                        let keys = Object.keys(updateConfigMap);
                                                        let componentObj = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
                                                        for(let i = 0; i < keys.length; i++){
                                                            await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false); 
                                                        }
                                                    }
                                                }   
                                                else{
                                                    console.log('no response');
                                                }
                                            });
                                    }
                                });										
                            }
                        }
                    });
                }
            }
            return Promise.resolve(true);
    },
    /**********************************************************************************************************************************************
     * Author	   : Aman Soni
     * Method Name : updateConfigNameNGEMPlan
     * Invoked When: after attribute updated
     * Dynamic name: Payment Type + Plan Name
     * Sprint	   : 20.10 (EDGE-154026)
     * Parameters  : componentName, guid
    *******************************************************************************************************************************************/
    updateConfigNameNGEMPlan: async function(componentName, guid) {
        let product = await CS.SM.getActiveSolution();
            if (product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach(async (comp) => {
                    if (comp.name === componentName) {
                        let updateMap = {};
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            for (var config of Object.values(comp.schema.configurations)) {
                                if (guid === config.guid) {
                                    var configName='';
                                    var planType = Object.values(config.attributes).filter(att => {
                                        return att.name === 'PlanTypeString'
                                    });
                                    var planName = Object.values(config.attributes).filter(att => {
                                        return att.name === 'SelectPlanName'
                                    });
                                    if(planType[0].displayValue != '' && planName[0].displayValue == ''){
                                        configName = planType[0].displayValue;
                                    }
                                    if(planType[0].displayValue != '' && planName[0].displayValue != ''){
                                        configName = planType[0].displayValue + '-' + planName[0].displayValue;
                                    }
                                    if(planType[0].displayValue == '' && planName[0].displayValue == ''){
                                        configName = 'Enterprise Mobility';
                                    }									
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid]=[{
                                        name: "ConfigName",
                                            value: configName,
                                            displayValue: configName
                                    }];
                                    config.configurationName=configName;
                                }
                            }
                            let keys = Object.keys(updateMap);
                            let component = await product.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
                            for (let i = 0; i < keys.length; i++) {
                                //let conf=await component.await comp.getConfiguration(keys[i]); 
                                //conf.
                                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
                            }
                        }					
                    }
                });
            }		
            return Promise.resolve(true);
    },
	/************************************************************************************
	* Author	  	: Aman Soni
	* Method Name 	: DefaultMsgBank
	* Invoked When	: On 'DefaultMsgBankSelection' Change
	* Sprint	  	: 20.12 (EDGE-157745)
	* Parameters  	: None
	***********************************************************************************/
	DefaultMsgBank: async function(){
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			var updateMapMsgbank = {};
			if (solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach((comp) =>{
					if(comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
						if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
							Object.values(comp.schema.configurations).forEach((config) =>{
								if(config.guid && !config.replacedConfigId){
									let attribs = Object.values(config.attributes);
									var defaultMsgBankSelection = attribs.filter(obj =>{
									return obj.name === 'DefaultMsgBankSelection'
									});
									var defaultMsgBankSelectionValue = attribs.filter(obj =>{
									return obj.name === 'DefaultMsgBankSelectionValue'
									});
									if(config.relatedProductList && Object.values(config.relatedProductList).length > 0){
										Object.values(config.relatedProductList).forEach(async (relatedConfig) =>{
											if(relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.messageBank) && relatedConfig.guid){
												if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
													let relAttribs = Object.values(relatedConfig.configuration.attributes);
													var msgBank = relAttribs.filter(obj =>{
													return obj.name === 'MessageBankAddonAssoc'
													});
													updateMapMsgbank[relatedConfig.guid] = [];
													if(defaultMsgBankSelection[0].value != '' && defaultMsgBankSelectionValue[0].value != ''){
														updateMapMsgbank[relatedConfig.guid].push({
														name: 'MessageBankAddonAssoc',
														value: defaultMsgBankSelection[0].value,
														displayValue:defaultMsgBankSelectionValue[0].value
														});
														updateMapMsgbank[relatedConfig.guid].push({
														name: 'MessageBank RC',
														value: 0.0,
														displayValue:0.0
														});
														updateMapMsgbank[relatedConfig.guid].push({
														name: 'MessageBank RC (Inc. GST)',
														value: 0.0,
														displayValue:0.0
														});
													}
													
												}
												let keys = Object.keys(updateMapMsgbank);
												for(let i = 0; i < keys.length; i++){
													await comp.updateConfigurationAttribute(keys[i], updateMapMsgbank[keys[i]], true); 
												}
											}
											
										});
									}
								}
							});
						}
					}
				});
			}
		}
	},
	/************************************************************************************
	* Author	  	: Aman Soni
	* Method Name 	: DefaultBDD
	* Invoked When	: On 'DefaultBDDSelection' Change
	* Sprint	  	: 20.12 (EDGE-157745)
	* Parameters  	: None
	***********************************************************************************/
	DefaultBDD: async function(){
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			var updateMapDataFeat = {};
			if (solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach((comp) =>{
					if(comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
						if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
							Object.values(comp.schema.configurations).forEach((config) =>{
								if(config.guid && !config.replacedConfigId){
									let attribs = Object.values(config.attributes);
									var defaultBDDSelection = attribs.filter(obj =>{
									return obj.name === 'DefaultBDDSelection'
									});
									var defaultBDDSelectionValue = attribs.filter(obj =>{
									return obj.name === 'DefaultBDDSelectionValue'
									});
									if(config.relatedProductList && Object.values(config.relatedProductList).length > 0){
										Object.values(config.relatedProductList).forEach(async (relatedConfig) =>{
											if(relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.dataFeatures) && relatedConfig.guid){
												if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
													let relAttribs = Object.values(relatedConfig.configuration.attributes);				
													var businessDemandData = relAttribs.filter(obj =>{
													return obj.name === 'BusinessDemandData'
													});
													updateMapDataFeat[relatedConfig.guid] = [];
													if(defaultBDDSelection[0].value != '' && defaultBDDSelectionValue[0].value != ''){
														updateMapDataFeat[relatedConfig.guid].push({
															name: 'BusinessDemandData',
															value: defaultBDDSelection[0].value,
															displayValue:defaultBDDSelectionValue[0].value
														});
														updateMapDataFeat[relatedConfig.guid].push({
															name: 'BDDChargeRC',
															value: 0.0,
															displayValue:0.0
														});
														updateMapDataFeat[relatedConfig.guid].push({
															name: 'BDD Charge GST',
															value: 0.0,
															displayValue:0.0
														});
													}
												}
												let keys = Object.keys(updateMapDataFeat);
												for(let i = 0; i < keys.length; i++){
													await comp.updateConfigurationAttribute(keys[i], updateMapDataFeat[keys[i]], true); 
												}
											}											
										});
									}
								}
							});
						}
					}
				});
			}
		}
	},
	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : RoundingOffAttribute
	* Invoked When: multiple occurrences
	* Sprint	  : 20.12(EDGE-160039)
	* Parameters  : guid, mainCompName, componentName,relatedCompName, attribute
	***********************************************************************************/
	RoundingOffAttribute: async function(guid, mainCompName, componentName,relatedCompName, attribute){
	let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(mainCompName)){
			if(solution.components && Object.values(solution.components).length > 0){
			var updateMap = {};
				Object.values(solution.components).forEach((comp) =>{
					if (comp.name.includes(componentName)){
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
							Object.values(comp.schema.configurations).forEach((config) => {
								if(config.guid){
									if(config.relatedProductList && Object.values(config.relatedProductList).length > 0){
										Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
											if(relatedConfig.name.includes(relatedCompName) && relatedConfig.guid) {
												if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.guid){
													let attribs = Object.values(relatedConfig.configuration.attributes);
													var attToBeRound = attribs.filter(obj => {
														return obj.name === attribute
													});
													var attRounded = parseFloat(attToBeRound[0].value).toFixed(2);
													updateMap[relatedConfig.guid] = [];
													if(relatedConfig.guid === guid){
														updateMap[relatedConfig.guid].push({
															name: attribute,
															value: attRounded,
															displayValue: attRounded													
														});
													}
												}
											}
											let keys = Object.keys(updateMap);
											for (let i = 0; i < keys.length; i++){
												await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
											}
										});
									}
								}
							});
						}
					}
				});
			}
		}
	},
    /************************************************************************************
     * Author      : Aditya Pareek
     * Method Name : updateSolutionNameNGD
     * Invoked When: multiple occurrences
     * Parameters  : solutionname,DEFAULTSOLUTIONNAME
     ***********************************************************************************/
    // Arinjay JSUpgrade
    updateSolutionNameNGD: async function (solutionname, DEFAULTSOLUTIONNAME) {
        var listOfAttributes = ['Solution Name', 'GUID'],
            attrValuesMap = {};
        var listOfAttrToGetDispValues = ['Offer Name'],
            attrValuesMap2 = {};
        attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, solutionname);
        attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, solutionname);
        if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME) {
            let updateConfigMap = {};
            updateConfigMap[attrValuesMap['GUID']] = [{
                name: 'Solution Name',
                    value: attrValuesMap2['Offer Name'],
                    displayValue: attrValuesMap2['Offer Name']
            }];
            if (updateConfigMap) {
                let solution = await CS.SM.getActiveSolution();
                let component = await solution.getComponentByName(solutionname); 
                var complock = component.commercialLock;
                if(complock) component.lock('Commercial', false);
                let keys = Object.keys(updateConfigMap)
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
                }
                if(complock) component.lock('Commercial', true);
            }
        }
    },
    /****************************************************************************************************
     * Author	: 	 Aditya Pareek
     * Method Name : checkConfigurationSubscriptionStatusNGEM
     * Defect/US # : EDGE-148731
     * Invoked When: Raised MACD on Suspended Subscription
     * Description :Update the Change Type to Active based on Subscription Status
     ************************************************************************************************/
    // Arinjay JSUpgrade 
    checkConfigurationSubscriptionStatusNGEM: async function (mainCompName, componentName, hookname, configuration) {
        console.log('checkConfigurationSubscriptionStatusNGEM');
        var solutionComponent = false;
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(mainCompName)) {
            if (Object.values(solution.schema.configurations)[0].replacedConfigId){
                solutionComponent = true;
                NextGenMobHelper.checkConfigurationSubscriptionsForNGEM(solution, solutionComponent,NEXTGENMOB_COMPONENT_NAMES.solutionname, hookname);
            }
            if (solution.components && Object.values(solution.components).length > 0) {
                Object.values(solution.components).forEach((comp) => {
                    solutionComponent = false;
					NextGenMobHelper.checkConfigurationSubscriptionsForNGEM(comp, solutionComponent, comp.name, hookname);
                });
            }
        }
        return Promise.resolve(true);
    },
    /****************************************************************************************************
     * Author	: 	 Aditya Pareek
     * Method Name : checkConfigSubsStatusonaddtoMac
     * Defect/US # : EDGE-148731
     * Invoked When: Raised MACD on Suspended Subscription
     * Description :Update the Change Type to Active based on Subscription Status
     ************************************************************************************************/
    // Arinjay JSUpgrade
    checkConfigSubsStatusonaddtoMac: async function (mainCompName, componentName, hookname, configid) {
        console.log('checkConfigSubsStatusonaddtoMac');
        var solutionComponent = false;
        var remainingTermValue = 0;
        var componentMap = {};
		var compToBeUpdated = '';
        var remainingTermValue = 0;
        var optionValues = [];
        if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice)
		optionValues = ["Cancel"];
		else
		optionValues = ["Cancel","Modify"];
        let currentSolution = await CS.SM.getActiveSolution();
        if (currentSolution.name.includes(mainCompName)){
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                Object.values(currentSolution.components).forEach((comp) => {
					if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
                    Object.values(comp.schema.configurations).forEach((config) => {
                        if (config.guid === configid) {
							compToBeUpdated = comp.name;
                            //if(config.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){ // Added as part of EDGE-154688 
							let attribs = Object.values(config.attributes);
							if (config.replacedConfigId || config.id) {
								var cta = attribs.filter(a => {
									return a.name === 'ChangeType'
								});
								var payTypeLookup = attribs.filter(obj => {
									return obj.name === 'PaymentTypeString'
								});
								var contractTermval = attribs.filter(obj => {
									return obj.name === 'ContractTerm'
								});
								if ((payTypeLookup[0].displayValue  === 'Hardware Repayment' && config.replacedConfigId)) {
									CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval[0].displayValue, config.id, comp.name, hookname);
								}
								if (cta && cta.length > 0) {    
									if(!componentMap[componentName]){
										componentMap[componentName] = [];
									}                                            
									if(config.replacedConfigId && (config.id == null || config.id == '')){
										componentMap[componentName].push({
											'id': config.replacedConfigId,
											'guid': config.guid,
											'ChangeTypeValue': cta[0].value,
											'needUpdate': 'Yes',
											'paymenttypelookup': payTypeLookup[0].displayValue,
											'RemainingTerm': remainingTermValue
										});
									}                                            
									else if (config.replacedConfigId && (config.id != null || config.id != '')){
										componentMap[componentName].push({
											'id': config.replacedConfigId,
											'guid': config.guid,
											'ChangeTypeValue': cta[0].value,
											'needUpdate': 'No',
											'paymenttypelookup': payTypeLookup[0].displayValue,
											'RemainingTerm': remainingTermValue
										});
									}                                            
									else{
										componentMap[componentName].push({
											'id': config.id,
											'guid': config.guid,
											'ChangeTypeValue': cta[0].value,
											'needUpdate': 'No',
											'paymenttypelookup': payTypeLookup[0].displayValue,
											'RemainingTerm': remainingTermValue

										});
									}
										
								}
							}
						}
                    });
				}
				if(comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.guid === configid){
								compToBeUpdated = comp.name;
								//if(config.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){ // Added as part of EDGE-154688 
								let attribs = Object.values(config.attributes);
								if (config.replacedConfigId || config.id) {
									var cta = attribs.filter(a => {
										return a.name === 'ChangeType'
									});
									if(cta && cta.length > 0) {    
										if (!componentMap[componentName]){
											componentMap[componentName] = [];
										}                                            
										if (config.replacedConfigId && (config.id == null || config.id == '')){
											componentMap[componentName].push({
												'id': config.replacedConfigId,
												'guid': config.guid,
												'ChangeTypeValue': cta[0].value,
												'needUpdate': 'Yes'
											});
										}                                            
										else if (config.replacedConfigId && (config.id != null || config.id != '')){
											componentMap[componentName].push({
												'id': config.replacedConfigId,
												'guid': config.guid,
												'ChangeTypeValue': cta[0].value,
												'needUpdate': 'No'
											});
										}                                            
										else{
											componentMap[componentName].push({
												'id': config.id,
												'guid': config.guid,
												'ChangeTypeValue': cta[0].value,
												'needUpdate': 'No'

											});
										}
											
									}
								}
							}
						});               
					}
				});
			}
        if(Object.keys(componentMap).length > 0){
		var parameter = '';
		Object.keys(componentMap).forEach(key => {
			if (parameter) {
				parameter = parameter + ',';
			}
			parameter = parameter + componentMap[key].map(e => e.id).join();
		});

		let inputMap = {};
		inputMap['GetSubscriptionForConfiguration'] = parameter;
		var statuses;
		let currentBasket =  await CS.SM.getActiveBasket(); 
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values =>{
			if (values['GetSubscriptionForConfiguration'])
			statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
		});

		if (statuses){
			var updateMap = [];
			Object.keys(componentMap).forEach(async comp => {
				componentMap[comp].forEach(element => {
					updateMap[element.guid] = [];
					var statusValue = 'New';
					var CustomerFacingId = '';
					var status = statuses.filter(v => {
						return v.csordtelcoa__Product_Configuration__c === element.id
					});
					if (status && status.length > 0) {
						statusValue = status[0].csord__Status__c;
						CustomerFacingId = status[0].serviceMSISDN__c;
						const found = optionValues.find(element => element === statusValue);
						if(found === undefined){
							optionValues.push(statusValue);
						}
					} 
					if (((element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') ||
						((element.ChangeTypeValue == 'Modify' || element.ChangeTypeValue == 'Cancel') && element.needUpdate == 'Yes')) && ((element.paymenttypelookup !== 'Purchase' && element.paymenttypelookup !== 'Hardware Repayment'))) {
						updateMap[element.guid].push({
							name: 'ChangeType',
								value: statusValue,
								displayValue: statusValue,
								options: optionValues,
                           		 showInUi:true								
						});
					}
					if (((element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') ||
						((element.ChangeTypeValue == 'Modify' || element.ChangeTypeValue == 'Cancel') && element.needUpdate == 'Yes'))) {
						updateMap[element.guid].push({
							name: 'ChangeType',
								value: statusValue,
								displayValue: statusValue,
								options: optionValues,
								showInUi:true
								
						});
					}
					if ((element.paymenttypelookup === 'Purchase' && statusValue != 'New')) {
						updateMap[element.guid] = [{
							name: 'ChangeType',
								value: "PaidOut",
								displayValue: "PaidOut",
								readOnly: true,
                             	showInUi:true
						}];
					}
					if ((element.paymenttypelookup === 'Hardware Repayment' && statusValue != 'New')) {
						NextGenMobHelper.CheckRemainingTerm(element.guid, hookname, statusValue);
					}
				});

				let component = await currentSolution.getComponentByName(comp); 
				var complock = component.commercialLock;
				if(complock) component.lock('Commercial', false);
				let keys = Object.keys(updateMap);
				if(component.name === compToBeUpdated){
					for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
				}
				if(complock) component.lock('Commercial', true);
			});
		}
	  }
	}
    return Promise.resolve(true);
    },
    ////////////////////////////////////////////////////////////////////////////////////////////
    // Arinjay JSUpgrade
    CheckRemainingTerm: async function (guid, hookname, statusValue) {
        var remainingtermvalstring = '';
        let currentSolution = await CS.SM.getActiveSolution();
        if (currentSolution.name.includes(mainCompName)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                Object.values(currentSolution.components).forEach((comp) => {
                    Object.values(comp.schema.configurations).forEach((config) => {
                        if (config.guid === guid) {
                            var cta = Object.values(config.attributes).filter(a => {
                                return a.name === 'ChangeType'
                            });
                            payTypeLookup = Object.values(config.attributes).filter(obj => {
                                return obj.name === 'PaymentTypeString'
                            });
                            var contractTermval = Object.values(config.attributes).filter(obj => {
                                return obj.name === 'ContractTerm'
                            });
                        }
                    });
                });
            }
        }
        NextGenMobHelper.UpdateChangeTypeHRO(guid, hookname, statusValue)
        return Promise.resolve(true);
    },
    ///////////////////////////////////////////
    // Arinjay JSUpgrade
    UpdateChangeTypeHRO: async function (guid, hookname, statusValue) {
        var remainingtermvalstring = '';
        var optionValues = [];
		//EDGE-168275
				optionValues = [
                 "Cancel"
                ];
        let currentSolution = await CS.SM.getActiveSolution();
        if (currentSolution.name.includes(mainCompName)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                Object.values(currentSolution.components).forEach((comp) => {
                    Object.values(comp.schema.configurations).forEach(async (config) => {
                        if (config.guid === guid) {
                            var NGEMdev = [];
                            var cta = Object.values(config.attributes).filter(a => {
                                return a.name === 'ChangeType'
                            });
                            payTypeLookup = Object.values(config.attributes).filter(obj => {
                                return obj.name === 'PaymentTypeString'
                            });
                            var contractTermval = Object.values(config.attributes).filter(obj => {
                                return obj.name === 'ContractTerm'
                            });
							var remainingtermval;
                            if ((payTypeLookup[0].displayValue === 'Hardware Repayment' && cta[0].value != 'New')) {
                                remainingtermval = Object.values(config.attributes).filter(a => {
                                    return a.name === 'RemainingTerm';

                                });
								
                            } if (remainingtermval) {
                                if (parseInt(remainingtermval[0].value) <= 0) {
                                    NGEMdev[guid] = [];
                                    NGEMdev[guid] = [{
                                        name: 'ChangeType',
                                            value: "PaidOut",
                                            displayValue: "PaidOut",
                                            readOnly: true
                                    }];
                                    let keys = Object.keys(NGEMdev);
                                    for (let i = 0; i < keys.length; i++) {
                                        await comp.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
                                    }
                                }
                            }
                            else {
                                NGEMdev[guid] = [];
                                const found = optionValues.find(element => element === statusValue);
                                if(found === undefined){
                                optionValues.push(statusValue);}
                                NGEMdev[guid].push[{
                                    name: 'ChangeType',
                                        value: statusValue,
                                        displayValue: statusValue,
                                        options: optionValues
                                        
                                }];
                                let keys = Object.keys(NGEMdev);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
                                }
                            }

					}
				});
			});
		}
	}
	return Promise.resolve(true);
},
/***********************************************************************************************
 * Author	   : Aditya Pareek
 * Method Name : checkConfigurationSubscriptionsForNGEM
 * Invoked When: Solution is Loaded
 * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
 * Revision History : Function Signature and code changed to fix EDGE-131227
 ***********************************************************************************************/
// Arinjay JSUpgrade
checkConfigurationSubscriptionsForNGEM: async function (comp, solutionComponent, componentName, hookname) {
	console.log('checkConfigurationSubscriptionsForNGEM');
	var componentMap = {};
	var payTypeLookup;
	var remainingTermValue = 0;
    var optionValues = [];
    if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice)
		optionValues = ["Cancel"];
	else
		optionValues = ["Cancel","Modify"];
	if (solutionComponent){
		let config = Object.values(comp.schema.configurations)[0];
		var cta = Object.values(config.attributes).filter(a => {
			return a.name === 'ChangeType'
		});
		componentMap[comp.name] = [];
		componentMap[comp.name].push({
			'id': config.replacedConfigId,
			'guid': config.guid,
			'ChangeTypeValue': cta[0].value,
			'needUpdate': 'No'
		});
	} else if((componentName === NXTGENCON_COMPONENT_NAMES.nextGenDevice) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			Object.values(comp.schema.configurations).forEach((config) => {
			if (config.replacedConfigId || config.id){
				var cta = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				payTypeLookup = Object.values(config.attributes).filter(obj => {
					return obj.name === 'PaymentTypeString'
				});
				var contractTermval = Object.values(config.attributes).filter(obj => {
					return obj.name === 'ContractTerm'
				});
				var payTypeLookupVal = "";
				var payTypeDisplayValue = "";
				// Added below to fix issue of undefined
				if(payTypeLookup.length >0 && payTypeLookup[0].value && payTypeLookup[0].value != null){									
					 payTypeLookupVal = payTypeLookup[0].value;
					 payTypeDisplayValue = payTypeLookup[0].displayValue;
				}
				//changes ENd				
				if ((payTypeDisplayValue === 'Hardware Repayment' && config.replacedConfigId)) {
					CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval[0].displayValue, config.id, comp.name, hookname);
                }
				if (cta && cta.length > 0) {
					if (!componentMap[comp.name])
						componentMap[comp.name] = [];
                    if(payTypeDisplayValue === 'Purchase' && config.replacedConfigId){
                       componentMap[comp.name].push({
							'id': config.id,
							'guid': config.guid,
							'ChangeTypeValue': 'PaidOut',
							'needUpdate': 'No',
							'paymenttypelookup': payTypeDisplayValue,
							'RemainingTerm': remainingTermValue
						}); 
                	}
					else if (config.replacedConfigId && (config.id == null || config.id == ''))
						componentMap[comp.name].push({
							'id': config.replacedConfigId,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'Yes',
							'paymenttypelookup':payTypeDisplayValue,
							'RemainingTerm': remainingTermValue
						});
					else if (config.replacedConfigId && (config.id != null || config.id != ''))
						componentMap[comp.name].push({
							'id': config.replacedConfigId,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'No',
							'paymenttypelookup': payTypeDisplayValue,
							'RemainingTerm': remainingTermValue
						});
					else
						componentMap[comp.name].push({
							'id': config.id,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'No',
							'paymenttypelookup': payTypeDisplayValue,
							'RemainingTerm': remainingTermValue
						});
				}
			}
		});
	}else if((componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
			Object.values(comp.schema.configurations).forEach((config) => {
			if(config.replacedConfigId || config.id){
				var cta = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				if (cta && cta.length > 0){
					if(!componentMap[comp.name]){
						componentMap[comp.name] = [];
					}
					
					if(config.replacedConfigId && (config.id == null || config.id == '')){
						componentMap[comp.name].push({
							'id': config.replacedConfigId,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'Yes'
						});
					}
					else if(config.replacedConfigId && (config.id != null || config.id != '')){
						componentMap[comp.name].push({
							'id': config.replacedConfigId,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'No'
						});
					}
					else{
						componentMap[comp.name].push({
							'id': config.id,
							'guid': config.guid,
							'ChangeTypeValue': cta[0].value,
							'needUpdate': 'No'
						});
					}
				}
			}
		});
	}
	if (Object.keys(componentMap).length > 0) {
		var parameter = '';
		Object.keys(componentMap).forEach(key => {
			if (parameter) {
				parameter = parameter + ',';
			}
			parameter = parameter + componentMap[key].map(e => e.id).join();
		});


		let inputMap = {};
		inputMap['GetSubscriptionForConfiguration'] = parameter;
		var statuses;
		let currentBasket =  await CS.SM.getActiveBasket(); 
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
			if (values['GetSubscriptionForConfiguration'])
				statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
		});

		if (statuses) {
			var updateMap = [];
			Object.keys(componentMap).forEach(async comp => {
				componentMap[comp].forEach(element => {
					updateMap[element.guid] = [];
					var statusValue = 'New';
					var CustomerFacingId = '';
					var status = statuses.filter(v => {
						return v.csordtelcoa__Product_Configuration__c === element.id
					});
					if (status && status.length > 0) {
						statusValue = status[0].csord__Status__c;
						CustomerFacingId = status[0].serviceMSISDN__c;
                        const found = optionValues.find(element => element === statusValue);
						if(found === undefined){
							optionValues.push(statusValue);
						}
					} 
            		

					// Updated as a part of EDGE-148738
					if (NEXTGENMOB_COMPONENT_NAMES.nextGenDevice && ((element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') ||
						((element.ChangeTypeValue == 'Modify' || element.ChangeTypeValue == 'Cancel') && element.needUpdate == 'Yes')) && (((element.paymenttypelookup === undefined || element.paymenttypelookup === 'Purchase') && element.paymenttypelookup !== 'Hardware Repayment' && element.ChangeTypeValue !== 'PaidOut'))) {
                        
                        updateMap[element.guid].push({
							name: 'ChangeType',
								value: statusValue,
								displayValue: statusValue,
								options: optionValues
						});
					}
					//Added by Aman Soni for EDGE-154238 || Start
					else if (!NEXTGENMOB_COMPONENT_NAMES.nextGenDevice && (element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') || ((element.ChangeTypeValue == 'Modify' || element.ChangeTypeValue == 'Cancel') && element.needUpdate == 'Yes')){
						if(!solutionComponent){
                        
							updateMap[element.guid].push({
							name: 'CustomerFacingServiceId',
								value: CustomerFacingId,
								displayValue: CustomerFacingId
							},{
							name: 'ChangeType',
								value: statusValue,
								displayValue: statusValue,
                                options: optionValues
								
							});
						}
					}else{
						if(!solutionComponent){
							updateMap[element.guid].push({
							name: 'CustomerFacingServiceId',
								value: CustomerFacingId,
								displayValue: CustomerFacingId
							});
						}						
					}
					//Added by Aman Soni for EDGE-154238 || End
					if ((element.paymenttypelookup === 'Hardware Repayment' && statusValue != 'New')) {
						NextGenMobHelper.CheckRemainingTerm(element.guid, hookname, statusValue);						
					}
				});
				let solution = await CS.SM.getActiveSolution();
				/*let Solcomp = await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.solutionname);
				let Plancomp = await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
				let Devicecomp = await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);*/
				var comp1=await solution.getComponentByName(componentName);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					//if(componentName === NEXTGENMOB_COMPONENT_NAMES.solutionname)
					//await Solcomp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					//if(componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)
					//await Plancomp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					//if(componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice)
					await comp1.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				} 
			});
		}
	}
	return Promise.resolve(true);
},
//Arinjay JSUpgrade
CalculateTotalETCValue: async function (guid, mainCompName) {
	if (basketChangeType !== 'Change Solution') {
		return;
	}
	let product = await CS.SM.getActiveSolution();
	let contractTerm;
	let disconnectionDate;
	let prodConfigID;
	let componentName;
	if (product.name.includes(mainCompName)) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						if (config.guid === guid) {
							componentName = comp.name;
							prodConfigID = config.replacedConfigId;
							let dd = Object.values(config.attributes).filter(a => {
								return a.name === 'DisconnectionDate' && a.value
							});
							if (dd && dd.length > 0)
								disconnectionDate = new Date(dd[0].value);

							let ct = Object.values(config.attributes).filter(a => {
								return a.name === 'ContractTerm' && a.value
							});
							if (ct && ct.length > 0)
								contractTerm = ct[0].displayValue;
						}
					});
				}
			});
			if (disconnectionDate && contractTerm) {
				var inputMap = {};
				var updateMap = [];
				inputMap["getETCChargesForNGUC"] = '';
				inputMap["DisconnectionDate"] = disconnectionDate;
				inputMap["etc_Term"] = contractTerm;
				inputMap["ProdConfigId"] = prodConfigID;

				let currentBasket =  await CS.SM.getActiveBasket(); 
				currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async values => {
					var charges = values["getETCChargesForNGUC"];
					var chargesGst = parseFloat(charges * 1.1).toFixed(2);
					updateMap[guid] = [{
						name: 'EarlyTerminationCharge',
							value: charges,
							displayValue: charges
					}, {
						name: 'EarlyTerminationChargeIncGST',
							label: 'Balance Due on Device(Inc. GST)',
							value: chargesGst,
							displayValue: chargesGst
					}];
					let component = await product.getComponentByName(componentName); 
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
				});
			}
		}
	}
},
// Arinjay JSUpgrade
ReadOnlyMarketableOffer: async function (mainCompName, guid) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.schema.configurations).forEach(async (config) => {
				if (config.attributes && Object.values(config.attributes).length > 0) {
					var updateConfigMap = {};
					updateConfigMap[guid] = [];
					updateConfigMap[guid].push({
						name: "Marketable Offer",
							readOnly: true
					});
					let component = await solution.getComponentByName(mainCompName); 
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
					}
				}
			});
		}
	}
},
/**********************************************************************************************************************************************
 * Author	   : Laxmi Rahate
 * Method Name : resetPreferredCRD
 * Invoked When: after attribute updated
 * Parameters  : none
******************************************************************************************************************************************/
// Arinjay JSUpgrade
resetPreferredCRD: async function (notBeforeCRD, preferredCRD) {
	var hasErrors = false;
	var changeTypeAttributeVal = '';
	var updateMapNewConfig = {}; // Added to fix issue of CRD not getting Populated on PC - eixt
	let product = await CS.SM.getActiveSolution();
	if (product.name === NEXTGENMOB_COMPONENT_NAMES.solutionname) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if (comp.name === 'Device') {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							updateMapNewConfig = {};

							var changeTypeAttribute = Object.values(config.attributes).filter(obj => {
								return obj.name === 'ChangeType'
							});

							if (changeTypeAttribute.length > 0 && changeTypeAttribute[0].value && changeTypeAttribute[0].value != null) {
								changeTypeAttributeVal = changeTypeAttribute[0].value;
							}

							if (!updateMapNewConfig[config.guid])
								updateMapNewConfig[config.guid] = [];

							if (changeTypeAttributeVal !== 'Cancel' && changeTypeAttributeVal !== 'PaidOut') {
								var updateMapNew = {};

								if (config.orderEnrichmentList) {
									for (var k = 0; k < config.orderEnrichmentList.length; k++) {
										var oeAtt = config.orderEnrichmentList[k];
										var preferredCRDAttVal = '';
										var notBeforeCRDAttVal = '';
										var oeNameVal = '';										
										var oeName = oeAtt.attributes.filter(att => {
											return att.name === 'OENAME'
										});
										if (oeName.length > 0 && oeName[0].value && oeName[0].value != null) {
											oeNameVal = oeName[0].value;
										}
									if (oeNameVal === 'CRD' ){ // Only perform below logic for CRD - this logic copies value from CNOt Before CRD to preferred CRD if preferred CRD is blank
										var preferredCRDAtt = Object.values(oeAtt.attributes).filter(att => {
											return att.name === 'Preferred CRD'
										});
										var notBeforeCRDAtt = Object.values(oeAtt.attributes).filter(att => {
											return att.name === 'Not Before CRD'
										});
										if (preferredCRDAtt.length > 0 && preferredCRDAtt[0].value && preferredCRDAtt[0].value != null) {
											preferredCRDAttVal = preferredCRDAtt[0].value;
										}
										if (notBeforeCRDAtt.length > 0 && notBeforeCRDAtt[0].value && notBeforeCRDAtt[0].value != null) {
											notBeforeCRDAttVal = notBeforeCRDAtt[0].value;
										}

										if (preferredCRDAttVal.length > 0 || notBeforeCRDAttVal.length > 0) {
											if (!updateMapNew[oeAtt.guid])
												updateMapNew[oeAtt.guid] = [];

											if (preferredCRDAttVal === '' || preferredCRDAttVal < notBeforeCRDAttVal || preferredCRDAttVal === '0' || preferredCRDAttVal === 0 || preferredCRDAttVal === NaN) {
												preferredCRDAttVal = notBeforeCRDAttVal;
												updateMapNew[oeAtt.guid].push({
													name: 'Preferred CRD',
													showInUi: true,
													displayValue: notBeforeCRDAttVal,
													value: notBeforeCRDAttVal
												});
											}
											updateMapNew[oeAtt.guid].push({
												name: 'Not Before CRD',
												showInUi: true,
												displayValue: notBeforeCRDAttVal,
												value: notBeforeCRDAttVal
											});

											var notBeforeCRDValidation = new Date();
											notBeforeCRDValidation.setHours(0, 0, 0, 0);
											notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);;
											if (notBeforeCRDAttVal < notBeforeCRDValidation) {
												let cnfg = await comp.getConfiguration(config.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'Not Before CRD date should be greater than today!!!';
												hasErrors = true;
											} else {
												let cnfg = await comp.getConfiguration(config.guid); 
												cnfg.status = true;
												cnfg.statusMessage = '';
												Utils.unmarkOEConfigurationInvalid(oeAtt.guid, '')
											}
										}
									}// End IF OE Name Check
									}
								}
								if (updateMapNew) {
									//CS.SM.updateOEConfigurationAttribute('Device', config.guid, updateMapNew, true);
									let keys = Object.keys(updateMapNew);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateMapNew[keys[i]], true); 
									}
								}
							}

						});
					}
				}
			});
		}
	}
	if (hasErrors && showMsg) {
		showMsg = false;
		//CS.SM.displayMessage('Not Before CRD date should be greater than today');
		hasErrors = false;
	}
},
/*******************************************************************************************************************************************
 * Author	   : Shubhi Vijay
 * Method Name : updateConfigName_Device
 * Invoked When: after attribute updated
 * Device Type + Model +Colour + Payment Type --> dynamic name
 * Parameters  : componentName , guid
 ******************************************************************************************************************************************/
// Arinjay JSUpgrade
updateConfigName_DeviceperConfig: async function (componentName, guid) {
	let updateMap = {};
	let product = await CS.SM.getActiveSolution();
	if (product.components && Object.values(product.components).length > 0) {
		Object.values(product.components).forEach((comp) => {
			if (comp.name === componentName) {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (var config of Object.values(comp.schema.configurations)) {
						if (guid === config.guid) {
							let attribs = Object.values(config.attributes);
							var configName = 'NextGenMobileDevice ';
							var type = attribs.filter(att => {
								return att.name === 'deviceTypeString'
							});
							var model = attribs.filter(att => {
								return att.name === 'ModelString'
							});
							var colour = attribs.filter(att => {
								return att.name === 'ColourString'
							});
							var paymentType = attribs.filter(att => {
								return att.name === 'PaymentTypeString'
							});;
							if (type && type[0] && model && model[0] && colour && colour[0] && paymentType && paymentType[0]) {
								configName = type[0].displayValue + ' ' + model[0].displayValue + ' ' + colour[0].displayValue + ' ' + paymentType[0].displayValue;
							}
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: "ConfigName",
									value: configName,
									displayValue: configName
							});
							config.configurationName=configName;
							break;
						}
					}
				}
			}
		});
	}
	if (updateMap){
		let component = await product.getComponentByName(componentName); 
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
		}
	}
	return Promise.resolve(true);
},
/******************************************************************************************************************************************
 * Author	   : Shubhi Vijay
 * Method Name : updateConfigName_Device
 * Invoked When: attribute update paymentType
 * Device Type + Model +Colour + Payment Type --> dynamic name
 * Parameters  : componentName , guid
******************************************************************************************************************************************/
// Arinjay JSUpgrade
updateConfigName_DeviceAllConfig: async function (componentName) {
	let updateMap = {};
	let component;
	let product = await CS.SM.getActiveSolution();
	if (product.components && Object.values(product.components).length > 0) {
		Object.values(product.components).forEach((comp) => {
			if (comp.name === componentName) {
				component = comp;
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (var config of Object.values(comp.schema.configurations)) {
						var configName = 'NextGenMobileDevice ';
						var type = Object.values(config.attributes).filter(att => {
							return att.name === 'deviceTypeString'
						});
						var model = Object.values(config.attributes).filter(att => {
							return att.name === 'ModelString'
						});
						var colour = Object.values(config.attributes).filter(att => {
							return att.name === 'ColourString'
						});
						var paymentType = Object.values(config.attributes).filter(att => {
							return att.name === 'PaymentTypeString'
						});
						if (type && type[0] && model && model[0] && colour && colour[0] && paymentType && paymentType[0]) {
							configName = type[0].displayValue + ' ' + model[0].displayValue + ' ' + colour[0].displayValue + ' ' + paymentType[0].displayValue;

						}
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: "ConfigName",
								value: configName,
								displayValue: configName
						});
						config.configurationName=configName;
					}
				}
			}
		});
	}
	if (updateMap){
		let keys = Object.keys(updateMap);
		let componentUpd = await product.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice); 
		for (let i = 0; i < keys.length; i++) {
			component.lock('Commercial', false);
			await componentUpd.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
		}
	}
	return Promise.resolve(true);
},
/*******************************************************************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : updateDeviceIdOnConfig
 * Invoked When: On Load and On Save
 * Parameters  : componentName
 * EDGE Number : EDGE-148733
 ******************************************************************************************************************************************/
// Arinjay JSUpgrade
updateDeviceIdOnConfig: async function (componentName) {
	let componentMap = {};
	let product = await CS.SM.getActiveSolution();
	if (product.components && Object.values(product.components).length > 0) {
		Object.values(product.components).forEach((comp) => {
			if (comp.name === componentName) {
				componentMap[comp.name] = [];
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						var DeviceIDValue = Object.values(config.attributes).filter(att => {
							return att.name === 'DeviceID'
						});
						if (config.replacedConfigId && DeviceIDValue && DeviceIDValue[0].value === '') {
							componentMap[comp.name].push({
								'id': config.replacedConfigId,
								'guid': config.guid,
							});
						}
					});
					if (componentMap)
						NextGenMobHelper.RemoteActionCall(componentMap, 'DeviceID', componentName)
				}
			}
		});
	}
},
/*******************************************************************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : RemoteActionCall
 * Invoked When: On Load and On Save
 * Parameters  : componentName
 * EDGE Number	: EDGE-148733
******************************************************************************************************************************************/
// Arinjay JSUpgrade
RemoteActionCall: async function (componentMap, Attname, componentName) {
	let updateMap = {};
	if (Object.keys(componentMap).length > 0) {
		var parameter = '';
		Object.keys(componentMap).forEach(key => {
			if (parameter) {
				parameter = parameter + ',';
			}
			parameter = parameter + componentMap[key].map(e => e.id).join();
		});
		let inputMap = {};
		inputMap['GetAssetForConfiguration'] = parameter;

		var statuses;
		let currentBasket =  await CS.SM.getActiveBasket(); 
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
			if (values['GetAssetForConfiguration'])
				statuses = JSON.parse(values['GetAssetForConfiguration']);
		});

		if (statuses) {
			Object.keys(componentMap).forEach(async comp => {
				componentMap[comp].forEach(element => {
					var DeviceID = '';
					var status = statuses.filter(v => {
						return v.csord__Service__r.csordtelcoa__Product_Configuration__c === element.id
					});
					if (status && status.length > 0) {
						DeviceID = status[0].AssetID__c;
					}
					if (Attname === 'DeviceID' && DeviceID != '' && DeviceID != null) {
						updateMap[element.guid] = [{
							name: Attname,
								value: DeviceID,
								displayValue: DeviceID,
								showInUi: true
						}];
					}
				});
				if(updateMap) {
					let solution = await CS.SM.getActiveSolution();
					let component = await solution.getComponentByName(componentName); 
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
				}
			});
		}

	}
},
/**********************************************************************************************
 * Author	  : Laxmi Rahate
 * Method Name : setNextGenEMTabsVisibility
 * Invoked When: after solution is loaded
 * Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
 * Parameters  : configuration guid or nothing
 *********************************************************************************************/
// Arinjay JSUpgrade
setNextGenEMTabsVisibility: async function (solutionName, component) {
	var changeTypeAttributeVal = '';
	let solution = await CS.SM.getActiveSolution();
	let updateConfigMapOE = {};
	
	if (solution.name.includes(solutionName)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
					if (comp.name === component || comp.name === 'Enterprise Mobility'  || comp.name === 'Device') { // Laxmi - Added Device 
					let oeToShow = [];
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
						if (!oeSchema.name.toLowerCase().includes('number')) {
							oeToShow.push(oeSchema.name);
						}
					});
						//EDGE-154680 MAC STory changes
						let oeToShowMac = [];
						Object.values(comp.orderEnrichments).forEach((oeSchema) => {
							if (!oeSchema.name.toLowerCase().includes('number') && !oeSchema.name.toLowerCase().includes('feature') && !oeSchema.name.toLowerCase().includes('delivery') ) {
								oeToShowMac.push(oeSchema.name);
							}
						});	
						// Changes End						
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							if (config.attributes) {
								var changeTypeAttribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
							}
								changeTypeAttributeVal = '';
								// get the AppleCare ChangeType Value -
									if (comp.name === 'Device' ){
									appleCareChangeType = await OE.getRelatedConfigAttrValue (config.guid,'','ChangeType','Device');
									}else
										appleCareChangeType = 'NotDevice';
									

																	
								
								if (changeTypeAttribute.length > 0 && changeTypeAttribute[0].value && changeTypeAttribute[0].value != null) {
									changeTypeAttributeVal = changeTypeAttribute[0].value;
									console.log ( ' Change Type Value -------------', changeTypeAttributeVal )
								}
								

									console.log ('appleCareChangeType***************',appleCareChangeType  + ' ---changeTypeAttributeVal -----' + changeTypeAttributeVal);
									if (changeTypeAttributeVal === 'Modify' ||  ( ( changeTypeAttributeVal === 'Active' || changeTypeAttributeVal === 'PaidOut' ) && appleCareChangeType === 'Cancel' ) ){  // EDGE- 154696 //EDGE-154680 MAC STory changes
										console.log ( 'adding MAC OE !!!' ); 

										CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShowMac);										
									} else if (changeTypeAttributeVal ==='Cancel' ||  changeTypeAttributeVal === 'Paid Out'  || changeTypeAttributeVal === 'PaidOut'  || (changeTypeAttributeVal === 'Active' &&  appleCareChangeType  === 'NotDevice') ) //Laxmi - Removed Active from this 
									{
										CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
									console.log ( 'adding blank OE!!!' ); 
									} else//EDGE-154680 MAC STory changes end
									{
												console.log ( 'adding NEW OE !!!' ); 
								
										CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
									}
											

									let updateConfigMap = {};
									updateConfigMap[config.guid] = [{
									name: 'appleCare',
									//value: {
										value: appleCareChangeType,
										displayValue: appleCareChangeType
									//}														
									}];											
									//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true); // Modified as part of EDGE-155181
									keys = Object.keys(updateConfigMap);
									for (let i = 0; i < keys.length; i++) {
										//comp.lock('Commercial', false); // Added by laxmi to address lock issue
										//await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
									}								
									

								
									// Code to default CRD Dates in case the APple Care is cancelled and Device Status is Active
									updateConfigMapOE = {}; 

									if (config.orderEnrichmentList) {
									
									
									//Object.values(config.orderEnrichmentList).forEach((oe) => {
									for (var m = 0; m < Object.values(config.orderEnrichmentList).length; m++) {
										var oeAtt = Object.values(config.orderEnrichmentList)[m];

										var oeNameVal = '';
										var oeName = Object.values(oeAtt.attributes).filter(att => {
											return att.name === 'OENAME'
										});
										if (oeName.length > 0 && oeName[0].value && oeName[0].value != null) {
											oeNameVal = oeName[0].value;
										}
										if (oeNameVal === 'CRD' ){
										//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
										//if (!updateConfigMapOE[oeAtt.guid])
											updateConfigMapOE[oeAtt.guid] = [];
											if (appleCareChangeType === 'Cancel')	{
												
												console.log( 'made attrubutes read only for ', oeAtt.guid );
												//updateConfigMapOE[oeAtt.guid].push({name: 'Not Before CRD',  displayValue:Utils.formatDate((new Date()).setHours(0,0,0,0)),
												//value:Utils.formatDate((new Date()).setHours(0,0,0,0)), readOnly: true});
												updateConfigMapOE[oeAtt.guid].push({
												name: 'Preferred CRD',
												showInUi: true,
												displayValue: Utils.formatDate((new Date()).setHours(0,0,0,0)),
												value: Utils.formatDate((new Date()).setHours(0,0,0,0)),
												readOnly :true
												
												});	
												
												updateConfigMapOE[oeAtt.guid].push({
												name: 'Not Before CRD',
												showInUi: true,
												displayValue: Utils.formatDate((new Date()).setHours(0,0,0,0)),
												value: Utils.formatDate((new Date()).setHours(0,0,0,0)),
												readOnly :true
												});	
												
												updateConfigMapOE[oeAtt.guid].push({
												name: 'Notes',
												showInUi: true,
												readOnly :true
												});													
											
												
											}
											
											
										}
									}	
									//);

								}
									
									//Date Default Code END
									
																				if(updateConfigMapOE)
												{
													comp.lock('Commercial', false);
													
													let keys = Object.keys(updateConfigMapOE);
													for(let h=0; h< keys.length;h++){
														await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateConfigMapOE[keys[h]],true);
														console.log ('Updated map sucessfully!!!!!!!!!!!!!!!!!');

													}
												}	
									
								
								
								
							//}
						});//for each config
					}
				}
			});
		}
	}
},
getOEAttributeValues_New: async function(name,schemaName,OEGuId){
    let oeData = getAllOrderEnrichment_New(schemaName,OEGuId);
    let schemaConfig = oeData.filter(function(item){
        return item.guid == guid;
    });
    if(schemaConfig.length){
        let attribute = schemaConfig[0].attributes.filter(function(item){
            return item.name == name;
        });
        // check if attribute is already in payload, if yes get that value
        let cachedValue = null;
        if(window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]){
            let cachedAttribute = window.rulesUpdateMap[guid].filter(function(item){ return item.name === name; });
            if(cachedAttribute && cachedAttribute[0] && typeof cachedAttribute[0].value !== 'undefined'){
                cachedValue = cachedAttribute[0].value;
            }
        }
        if(attribute.length){
            var returnValue = null,
                value = cachedValue ? cachedValue : attribute[0].value;
            switch(attribute[0].type){
                case 'Date':
                    if(value == null || value == ''){
                        returnValue = 0;
                    }else{
                        returnValue =value; //(new Date(value)).setHours(0,0,0,0); INC000093063735 Date Fix issue by ankit
                    }
                    break;
                default:
                    returnValue = value;
                    break;
            }
            return returnValue;
        }
    }
    return [];
},

getAllOrderEnrichment_New: async function(schemaName,OEGuId){
	let oeData = CS.SM.getOrderEnrichmentList(schemaName, OEGuId);
	if(oeData.__zone_symbol__state){
		return oeData.__zone_symbol__value;
	}
},

/**********************************************************************************************
 * Author	   : Laxmi Rahate
 * Method Name : getAttributeValue
 * Invoked When: on need
 * returns teh value of the attribute
 * EDGE-154663
 *********************************************************************************************/ 
 getAttributeValue: async function(attributeName,schemaName,configGUID) {	 
	var returnAttrVal;
	let currentSolution = await CS.SM.getActiveSolution();
            if (currentSolution){
                if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                    for (var i=0; i<  Object.values(currentSolution.components).length; i++) {
                        var comp = Object.values(currentSolution.components)[i];
						if (comp.name === schemaName ){ 
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            for (var j=0; j< Object.values(comp.schema.configurations).length; j++) {
							//EDGE-154680 MAC STory changes added below section to get value of any attribute in parameter
							var config = Object.values(comp.schema.configurations)[j];	
								if (config.guid === configGUID){
									var attributeVal = Object.values(config.attributes).filter(att => {
											return att.name === attributeName
										});
									if(attributeVal.length >0 &&attributeVal[0].value &&attributeVal[0].value != null){			
										 returnAttrVal = attributeVal[0].value;
									}											
								}		
							if (returnAttrVal) 
								break;								
                            } //end For
                        }						
					}
					if (returnAttrVal)
						break;
                    }
                }
            }
        return returnAttrVal;		
   },
   HideShowAttributeLstOnSaveNOnMac: async function (componentName, attributeList,guid) {
	let solution = await CS.SM.getActiveSolution();
	var comp = solution.getComponentByName(componentName);
	let config = await comp.getConfiguration(guid);
	config.status = true;
	config.statusMessage = '';
	if(config){
		if(componentName===NXTGENCON_COMPONENT_NAMES.nextGenDevice){
			var payTypeLookup;
			let attribs = Object.values(config.attributes);
			payTypeLookup = attribs.filter(obj => {
				return obj.name === 'PaymentTypeString'
			});
			var manufacturer = attribs.filter(obj => {
				return obj.name === 'MobileHandsetManufacturer'
			});
			var model = attribs.filter(obj => {
				return obj.name === 'MobileHandsetModel'
			});
			var color = attribs.filter(obj => {
				return obj.name === 'MobileHandsetColour'
			});
			var devType = attribs.filter(obj => {
				return obj.name === 'Device Type'
			});
			var inContractDevEnrElig = attribs.filter(obj => {
				return obj.name === 'InContractDeviceEnrollEligibility'
			});
			var ChangeTypeAtr = attribs.filter(obj => {
				return obj.name === 'ChangeType'
			});
			var RemainingTermVal = attribs.filter(a => {
				return a.name === 'RemainingTerm';

			});
			if (payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Hardware Repayment' && config.replacedConfigId) {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[13], true, true, false);
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
			}
			if (config.replacedConfigId && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Purchase') {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[15], true, false, false);
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false); //Added by ankit as part of EDGE-148733 
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
			}
			if (config.replacedConfigId && payTypeLookup[0].displayValue === 'Hardware Repayment' && ChangeTypeAtr[0].displayValue === 'Cancel') {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[16], true, true, false);
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[17], false, true, false);

			}
			if (config.replacedConfigId && ChangeTypeAtr[0].displayValue === 'Active' && RemainingTermVal[0].displayValue === null) {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false);
			}
			if (config.replacedConfigId) {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[10], false, true, false);
			}
			if (config.replacedConfigId && ChangeTypeAtr[0].displayValue === 'PaidOut') {
				NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[10], true, true, false);
			}
			//Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
			if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
				Object.values(config.relatedProductList).forEach((relatedConfig) => {
					if (relatedConfig.guid) {
						NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
					}
				});
			}
		}
		//Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
		if(componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
            let attribs = Object.values(config.attributes);
									var PlanTypeAtr = attribs.filter(obj =>{
									return obj.name === 'SelectPlanType'
									});
			if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
				Object.values(comp.schema.configurations).forEach((planConfig) => {
					if(planConfig.guid && planConfig.replacedConfigId !== '' && planConfig.replacedConfigId !== undefined && planConfig.replacedConfigId !== null){
						NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[18], true, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[10], false, true, false);		
					}
				});
            }            
		}
		//Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End	
	}
},
/***********************************************************************************************
 * Author	   : Shubhi Vijayvergia/Aman Soni
 * EDGE number : EDGE-134880
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

    ***********************************************************************************************/
    UpdateRelatedConfigForChild : async function() {
        if(!window.basketChange || window.basketChange==='')
            return;
        let loadedSolution = await CS.SM.getActiveSolution();
        if (loadedSolution.componentType) {
                let currentBasket =  await CS.SM.getActiveBasket(); 
                window.currentSolutionName = loadedSolution.name;
                if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
                    Object.values(loadedSolution.components).forEach((comp) => {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                                if (subsConfig.replacedConfigId && subsConfig.disabled=== false && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                                        subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                                            let inputMap = {};
                                            inputMap['GetConfigurationId'] = relatedConfig.guid;
                                            inputMap['basketId'] = basketId;
                                            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                                                var replaceId = result["replacedConfigid"];
                                                var configGuid = result["childGuid"];
                                                var relatedConfigId = result["childId"];
                                                if(configGuid===relatedConfig.guid)
                                                relatedConfig.configuration.replacedConfigId=replaceId;
                                                relatedConfig.configuration.id=relatedConfigId;
                                            });
                                            
                                        });
                                }
                            });
                        }
                    });
                }
            return Promise.resolve(true);
        }	
    },
    /***********************************************************************************************
     * Author	   : Shubhi Vijayvergia/Aman soni
     * EDGE number : EDGE-134880
     * Method Name : EMPlugin_ChangeOptionValue()
     * Invoked When: After attribute changes
     * Description : Update Replace ConfigId

 ***********************************************************************************************/
ChangeOptionValueNGEMPlan: async function (guid) {	
	var updateMap = {};
	 var optionValues = [];
		optionValues = [
            "Modify", "Cancel"
        ];
	let loadedSolution = await CS.SM.getActiveSolution();
	if (loadedSolution.componentType) {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		window.currentSolutionName = loadedSolution.name;
		if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
			Object.values(loadedSolution.components).forEach((comp) => {
				if(comp.name==='Enterprise Mobility'){
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
							if(subsConfig.guid===guid){
								updateMap[subsConfig.guid]=[{
									name: 'ChangeType',
									options: optionValues
								}];
							}	
						});
					}
					let keys = Object.keys(updateMap);
					var complock = comp.commercialLock;
					if(complock) comp.lock('Commercial', false);
					for (let i = 0; i < keys.length; i++) {
						comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
				}
			});
		}
		
		return Promise.resolve(true);
	}
},

 ChangeOptionValueNGEMDevice: async function(guid){	
	var updateMap = {};
	 var optionValues = [];
		optionValues = [
            "Modify", "Cancel"
        ];
	let loadedSolution = await CS.SM.getActiveSolution();
	if (loadedSolution.componentType) {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		window.currentSolutionName = loadedSolution.name;
		if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
			Object.values(loadedSolution.components).forEach((comp) => {
				if(comp.name==='Device'){
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
							if(subsConfig.guid===guid){
								updateMap[subsConfig.guid]=[{
									name: 'ChangeType',
									options: optionValues
								}];
							}	
						});
					}
					let keys = Object.keys(updateMap);
					var complock = comp.commercialLock;
					if(complock) comp.lock('Commercial', false);
					for (let i = 0; i < keys.length; i++) {
						comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
				}
			});
		}
		
		return Promise.resolve(true);
	}
},
/***********************************************************************************************
 * Author	   : Shubhi Vijayvergia
 * EDGE number : EDGE-169973
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

    ***********************************************************************************************/
    UpdateRelatedConfigForChildMac: async function(guid,componentName) {
        let loadedSolution = await CS.SM.getActiveSolution();
        if (loadedSolution.componentType && loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
                let currentBasket =  await CS.SM.getActiveBasket(); 
                window.currentSolutionName = loadedSolution.name;
                if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
                    Object.values(loadedSolution.components).forEach((comp) => {
                        if (comp.name === componentName) {
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                                    if (subsConfig.disabled===false && guid===subsConfig.guid && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                                            subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                                                let inputMap = {};
                                                inputMap['GetConfigurationId'] = relatedConfig.guid;
                                                inputMap['basketId'] = basketId;
                                                await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                                                    var replaceId = result["replacedConfigid"];
                                                    var configGuid = result["childGuid"];
                                                    var relatedConfigId = result["childId"];
                                                    if(configGuid===relatedConfig.guid)
                                                    relatedConfig.configuration.replacedConfigId=replaceId;
                                                    relatedConfig.configuration.id=relatedConfigId;
                                                });
                                                
                                            });
                                    }
                                });
                            }
                        }
                    });
                }
                return Promise.resolve(true);
        }	
    },
    /***********************************************************************************************
     * Author	   : Shubhi Vijayvergia
     * EDGE number : EDGE-169973
     * Method Name : handleReloadinMacd()
     * Invoked When: On solution load and add to macd 
     * Description : on reload
     ***********************************************************************************************/
	handleReloadinMacd : async function (){
		let product=  await CS.SM.getActiveSolution();
		let comp=await product.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
		var updateConfigMap={};
		if(comp && comp.schema.configurations ){
			for(var config of Object.values(comp.schema.configurations)){
				var cta = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				payTypeLookup = Object.values(config.attributes).filter(obj => {
					return obj.name === 'PaymentTypeString'
				});
				var contractTermval = Object.values(config.attributes).filter(obj => {
					return obj.name === 'ContractTerm'
				});
				var contractTermval = Object.values(config.attributes).filter(obj => {
					return obj.name === 'ContractTerm'
				});
				var RemainingTermValue = Object.values(config.attributes).filter(a => {
					return a.name === 'RemainingTerm'
				});
				var payTypeLookupVal = "";
				var payTypeDisplayValue = "";
				// Added below to fix issue of undefined
				if(payTypeLookup.length >0 && payTypeLookup[0].value && payTypeLookup[0].value != null){									
					payTypeLookupVal = payTypeLookup[0].value;
					payTypeDisplayValue = payTypeLookup[0].displayValue;
				}
				
				if(payTypeDisplayValue === 'Purchase' && config.replacedConfigId && !config.disabled){
					updateConfigMap[config.guid] = [];
						updateConfigMap[config.guid] = [
							{ 
								name: 'TotalFundAvailable', 
								value: currentFundBalance, 
								displayValue: currentFundBalance,
								showInUi: true,
								readOnly: true						
							},
							{ 
								name: 'RedeemFund', 
								value: 0, 
								displayValue: 0,
								showInUi: true,
								readOnly: true
							},
							{
								name: 'ChangeType', 
								value: 'PaidOut', 
								displayValue: 'PaidOut', 
								showInUi: true,
								readOnly: true
							}
						];
						if (config.relatedProductList.length >= 0) {
							for (var ReletedConfig of config.relatedProductList) {
								if (ReletedConfig.guid && ReletedConfig.ReletedConfig) {
									updateConfigMap[ReletedConfig.guid] = [
										{ 
											name: 'TotalFundAvailable', 
											value: currentFundBalance, 
											displayValue: currentFundBalance,
											showInUi: true,
											readOnly: true						
										},
										{ 
											name: 'RedeemFund', 
											value: 0, 
											displayValue: 0,
											showInUi: true,
											readOnly: true
										}
									];
								}
							}
						}
					
				}
				if(payTypeDisplayValue === 'Hardware Repayment' && config.replacedConfigId && !config.disabled){
					if(RemainingTermValue && RemainingTermValue[0] && RemainingTermValue[0].value<=0){
						updateConfigMap[config.guid] = [];
						updateConfigMap[config.guid] = [
							{ 
								name: 'TotalFundAvailable', 
								value: currentFundBalance, 
								displayValue: currentFundBalance,
								showInUi: false,
								readOnly: true						
							},
							{ 
								name: 'RedeemFund', 
								value: 0, 
								displayValue: 0,
								showInUi: false,
								readOnly: true
							},
							{
								name: 'ChangeType', 
								value: 'PaidOut', 
								displayValue: 'PaidOut', 
								showInUi: true,
								readOnly: true
							}
						];
					
					
					}else if(cta && cta[0] && cta[0].value==='Cancel'){
						updateConfigMap[config.guid] = [];
						updateConfigMap[config.guid] = [{ 
							name: 'TotalFundAvailable', 
							value: currentFundBalance, 
							displayValue: currentFundBalance,
							showInUi: true,
							readOnly: true						
						},{ 
							name: 'RedeemFund', 
							value: 0, 
							displayValue: 0,
							showInUi: true,
							readOnly: false
						}];
					}
				}
			}
		}
		var complock = comp.commercialLock;//added by shubhi for EDGE-169593
		//if(complock) comp.lock('Commercial', false);
		let keys = Object.keys(updateConfigMap);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
		}
		//if(complock) comp.lock('Commercial', true);//added by shubhi for EDGE-169593
		
		return Promise.resolve(true);
	},
    /***********************************************************************************************
     * Author	   : Shubhi Vijayvergia
     * EDGE number : EDGE-169973
     * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
     * Invoked When: On related product add to update attributes from parent to child or to default any value
     ***********************************************************************************************/

    UpdateChildAttributedonAdd : async function(mainCompName,configGuid,component,relatedProduct) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(mainCompName)) {
            if (solution.components && Object.values(solution.components).length > 0) {
                var solutionOfferId = '';
                for(var solConfig of Object.values(solution.schema.configurations)){
                    if(solConfig.guid && solConfig.attributes){
                        let attribs = Object.values(solConfig.attributes);
                        let  offerId = attribs.filter(obj => {
                        return obj.name === 'OfferId'
                        });
                        if (offerId && offerId[0] && offerId[0].value){
                            solutionOfferId= offerId[0].value;
                        }
                        break;
                    }
                };
                var comp=await solution.getComponentByName(component.name);
                var config= await comp.getConfiguration(configGuid);
                var selectPlanParent='';
                if(config.guid && config.attributes){
                        let attribs = Object.values(config.attributes);
                        var planAtt = attribs.filter(obj => {
                            return obj.name === 'Select Plan'
                        });
                        if (planAtt && planAtt[0] && planAtt[0].value){
                            selectPlanParent= planAtt[0].value;
                        }
                }
                var updateMapChild={};

                if (relatedProduct.configuration.attributes) {
                    updateMapChild[relatedProduct.guid] = [];
                    updateMapChild[relatedProduct.guid].push({
                        name: 'OfferId',
                        showInUi: false,
                        readOnly: true,
                        value: solutionOfferId,
                        displayValue: solutionOfferId
                    }
                    ,{
                        name: 'Select Plan',
                        showInUi: false,
                        readOnly: true,
                        value: selectPlanParent,
                        displayValue: selectPlanParent
                    });
                }
                            
                let keys = Object.keys(updateMapChild);
                var complock = comp.commercialLock;
                //if(complock) comp.lock('Commercial', false);
                for (let i = 0; i < keys.length; i++) {
                   comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true); 
                }
                //if(complock) comp.lock('Commercial', true);
                
            }
        }
        return Promise.resolve(true);
    },
    /***********************************************************************************************
     * Author	   : Shubhi Vijayvergia
     * EDGE number : EDGE-169973
     * Method Name : updatechildAttfromParent(attTobeUpdated,value,guid,compname)
     * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
     * Invoked When: On after parent attribute update  to update attributes from parent to child 
     ***********************************************************************************************/
    updatechildAttfromParent: async function(attTobeUpdated,value,readOnly,showInUi,guid,compname){
        var solution= await CS.SM.getActiveSolution();
        var comp=await solution.getComponentByName(compname);
        var config=await comp.getConfiguration(guid);
        var updateMapChild={};
        if (config.relatedProductList.length >= 0) {
            for (var ReletedConfig of config.relatedProductList) {
                if (ReletedConfig.guid) {
                    updateMapChild[ReletedConfig.guid] = [
                    { 
                        name: attTobeUpdated, 
                        value: value, 
                        displayValue: value,
                        showInUi: showInUi,
                        readOnly: readOnly						
                    }];
                }
            }
            let keys = Object.keys(updateMapChild);
            var complock = comp.commercialLock;
            //if(complock) comp.lock('Commercial', false);
            for (let i = 0; i < keys.length; i++) {
                comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true); 
            }
            //if(complock) comp.lock('Commercial', true);
        }
        return Promise.resolve(true);
    },
     /***********************************************************************************************
     * Author	   : Shubhi Vijayvergia
     * EDGE number : EDGE-169973
     * Method Name : emptyChildAttfromParent(attTobeUpdated,value,guid,compname)
     * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
     * Invoked When: On after parent attribute update  to update attributes from parent to child 
     ***********************************************************************************************/
    emptyChildAttfromParent: async function(attTobeUpdatedList,guid,compname,relatedProductName){
        var solution= await CS.SM.getActiveSolution();
        var comp=await solution.getComponentByName(compname);
        var config=await comp.getConfiguration(guid);
        var updateMapChild={};
        if (!config.replacedConfigId && config.relatedProductList.length >= 0) {
            for (var ReletedConfig of config.relatedProductList) {
                if (ReletedConfig.guid && ReletedConfig.name===relatedProductName) {
                    updateMapChild[ReletedConfig.guid] = [];
                    for(var i=0; i<attTobeUpdatedList.length; i++){ 
                        updateMapChild[ReletedConfig.guid].push(
                            {
                                name: attTobeUpdatedList[0], 
                                value: '', 
                                displayValue: ''
                            }
                        );						
                    };
                }
            }
            let keys = Object.keys(updateMapChild);
            var complock = comp.commercialLock;
            //if(complock) comp.lock('Commercial', false);
            for (let i = 0; i < keys.length; i++) {
                comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true); 
            }
           // if(complock) comp.lock('Commercial', true);
        }
        return Promise.resolve(true);

    },
	/************************************************************************************
         * Author	: shubhi Vijayvergia 
         * edge     :166327
         * Method Name : autoDeleterelatedProductonPlanChange,
         * Invoked When: on parent config uis added
         * Description :  on parent config uis added
         * Parameters :value,guid,component
     ***********************************************************************************/
	autoDeleterelatedProductonPlanChange: async function(planValue,guid,component){
		//if(planValue && planValue!=NGEMPLans.Handheld){
			var config= await component.getConfiguration(guid);
			if (!config.replacedConfigId && config.relatedProductList.length >= 0 && relatedprodtobeautodeleted) {
				for (var ReletedConfig of config.relatedProductList) {
					for(var relProdname of relatedprodtobeautodeleted){
						if (ReletedConfig.guid && ReletedConfig.name===relProdname) {
							await component.deleteRelatedProduct( guid, ReletedConfig.guid, true ); 
						}
					}
				}
			}
		//}
		return Promise.resolve(true);
    },  
	/************************************************************************************
         * Author	: shubhi Vijayvergia 
         * edge     :EDGE-160037
         * Method Name : autoDeleterelatedProductonPlanChange,
         * Invoked When: on parent config uis added
         * Description :  on parent config uis added
         * Parameters :value,guid,component
     ***********************************************************************************/
	autoUpdateAddonAfterPlanChangeinMac: async function(planValue,guid,component,relatedProductName,attributename,chargeId){
		let updateMapChild={};
		let currentBasket =  await CS.SM.getActiveBasket(); 
		var config= await component.getConfiguration(guid);
		if (config.replacedConfigId && config.relatedProductList.length >= 0 && planValue!='') {
			for (var ReletedConfig of config.relatedProductList) {
				if(relatedProductName===ReletedConfig.name){
                    var addonName='' ; var offer=''; 
                    var relConfig= await component.getConfiguration(ReletedConfig.guid);
					const IDD_ChargeLookup = relConfig.getAttribute( attributename );	
					const offerid=relConfig.getAttribute( 'OfferId' );
					addonName=IDD_ChargeLookup.displayValue;
					//chargeId=IDD_ChargeLookup.lookup.Charge_Id__c;
					offer=offerid.value;
					let inputMap = {};
					inputMap['offerid'] = offer;
					inputMap['getAddonPriceItemAssociation'] = '';
					inputMap['chargeid'] = chargeId;
					inputMap['plan'] = planValue;
					inputMap['addonName'] = addonName;
					var AddonAssoc={};
					if(addonName!=''){
						await currentBasket.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(response => {
							if (response && response['getAddonPriceItemAssociation'] != undefined) {
								AddonAssoc = response['getAddonPriceItemAssociation'];
								if(AddonAssoc){
									updateMapChild[ReletedConfig.guid] = [];
									updateMapChild[ReletedConfig.guid].push({
										name: attributename,
										value: AddonAssoc.Id,
										displayValue: AddonAssoc.AddOn_Name__c,
										lookup:AddonAssoc
									});
								}else{
									ReletedConfig.status=false;
									ReletedConfig.message='Existing configured BoltOn is not applicable for the selected Plan';
								}
							}else{
								ReletedConfig.status=false;
								ReletedConfig.message='Existing configured BoltOn is not applicable for the selected Plan';
							}
							
						});
					}

					
				}

			}
			let keys = Object.keys(updateMapChild);
            //var complock = component.commercialLock;
            //if(complock) comp.lock('Commercial', false);
            for (let i = 0; i < keys.length; i++) {
                component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false); 
            }
		}

		return Promise.resolve(true);
	},
/********************************************************************************
	* Author	: shubhi Vijayvergia 
	* edge     :160037
	* Method Name : autoDeleterelatedProductonPlanChange,
	* Invoked When: on parent config uis added
	* Description :  on parent config uis added
	* Parameters :value,guid,component
***********************************************************************************/
autoUpdatedatafeaturesonPlanChangeinMac: async function(planValue,guid,component,relatedProductName){
	let updateMapChild={};
	let currentBasket =  await CS.SM.getActiveBasket(); 
	var config= await component.getConfiguration(guid);
	if (config.replacedConfigId && config.relatedProductList.length >= 0 ) {
		for (var ReletedConfig of config.relatedProductList) {
			if(relatedProductName===ReletedConfig.name){
                updateMapChild[ReletedConfig.guid] = [];
                var addonNameList='';
                //var chargeIdList='DMCAT_NonRecurringCharge_001273';
                
                var chargeIdList='DMCAT_NonRecurringCharge_001273,DMCAT_NonRecurringCharge_001274,DMCAT_RecurringCharge_001277';
                var offer=''; 
                var planId=planValue;
                var relConfig=await component.getConfiguration(ReletedConfig.guid)
                const AutoDataTopup = relConfig.getAttribute( 'AutoDataTopup' );
                if(AutoDataTopup && AutoDataTopup.displayvalue!=undefined && AutoDataTopup.displayvalue!='')
                    addonNameList+=AutoDataTopup.displayvalue+',';	
                const UnshapeUserChargeLookup = relConfig.getAttribute( 'UnshapeUserChargeLookup' );
                if(UnshapeUserChargeLookup && UnshapeUserChargeLookup.displayvalue!=undefined && UnshapeUserChargeLookup.displayValue!='')
							//addonNameList.push(UnshapeUserChargeLookup.displayValue);
                addonNameList+=UnshapeUserChargeLookup.displayvalue+',';	
                const BusinessDemandData = relConfig.getAttribute( 'BusinessDemandData' );
                addonNameList+=BusinessDemandData.displayValue;
                //addonNameList.push(BusinessDemandData.displayValue);	
				const offerid=relConfig.getAttribute( 'OfferId' );
				offer=offerid.value;
				let inputMap = {};
				inputMap['offerid'] = offerid.value;
				inputMap['getAddonPriceItemAssociationBulk'] = '';
				inputMap['chargeidList'] = chargeIdList;
				inputMap['plan'] = planId;
				inputMap['addonNameList'] = addonNameList;
				var AddonAssocMap={};
				await currentBasket.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(response => {
					if (response && response['setAddonPriceItemAssociation'] != undefined) {
						AddonAssocMap = response['setAddonPriceItemAssociation'];
						if(AddonAssocMap){
                            Object.keys(AddonAssocMap).forEach(chargeid =>{
                                var addonAss=AddonAssocMap[chargeid];
                                if(AutoDataTopup && AutoDataTopup.displayvalue!=undefined && AutoDataTopup.displayvalue!=''
                                    &&  chargeid==='DMCAT_NonRecurringCharge_001273' 
                                    && addonAss.cspmb__add_on_price_item__r.addOn_Name__c===AutoDataTopup.displayvalue)
                                {
                                    updateMapChild[ReletedConfig.guid].push({
                                        name: 'AutoDataTopup',
                                        value: addonAss.Id,
                                        displayValue: addonAss.AddOn_Name__c,
                                        lookup:addonAss
                                    });
                                }
                                else if(UnshapeUserChargeLookup && UnshapeUserChargeLookup.displayvalue!=undefined && UnshapeUserChargeLookup.displayvalue!=''
                                     && chargeid==='DMCAT_NonRecurringCharge_001274'
                                     && addonAss.cspmb__add_on_price_item__r.addOn_Name__c===UnshapeUserChargeLookup.displayvalue)
                                {
                                    updateMapChild[ReletedConfig.guid].push({
                                        name: 'UnshapeUserChargeLookup',
                                        value: addonAss.Id,
                                        displayValue: addonAss.AddOn_Name__c,
                                        lookup:addonAss
                                    });
                                }else if(chargeid==='DMCAT_NonRecurringCharge_001277' && addonAss.cspmb__add_on_price_item__r.addOn_Name__c===BusinessDemandData.displayvalue){
                                    updateMapChild[ReletedConfig.guid].push({
                                        name: 'BusinessDemandData',
                                        value: addonAss.Id,
                                        displayValue: addonAss.AddOn_Name__c,
                                        lookup:addonAss
                                    });
                                }
                            });
							
						}
					}
					
				});

				}

			}
			let keys = Object.keys(updateMapChild);
			//var complock = component.commercialLock;
			//if(complock) comp.lock('Commercial', false);
			for (let i = 0; i < keys.length; i++) {
			component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false); 
			}

		
		}
			return Promise.resolve(true);	
	},
    /************************************************************************************
	* Author	  	: Aditya Pareek
	* Method Name 	: Update_UnshapeUser_OnDataFeat
	* Invoked When	: On 'SelectPlanType' Change
	* Sprint	  	: 20.12 (EDGE-157745)
	* Parameters  	: guid
	***********************************************************************************/
	Update_UnshapeUser_OnDataFeat: async function(guid){
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			var updateMapUnshpUsr = {};
			if (solution.components && Object.values(solution.components).length > 0){
				Object.values(solution.components).forEach((comp) =>{
					if(comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
						if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
							Object.values(comp.schema.configurations).forEach((config) =>{
								if(config.guid === guid){
									let attribs = Object.values(config.attributes);
									var selectPlanTypeUpd = attribs.filter(obj =>{
									return obj.name === 'SelectPlanType'
									});									
									if(config.relatedProductList && Object.values(config.relatedProductList).length > 0){
										Object.values(config.relatedProductList).forEach(async (relatedConfig) =>{
											if(relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.dataFeatures) && relatedConfig.guid){
												if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
													let relAttribs = Object.values(relatedConfig.configuration.attributes);				
													var unshapeUser = relAttribs.filter(obj =>{
													return obj.name === 'UnshapeUser'
													});
													updateMapUnshpUsr[relatedConfig.guid] = [];
													if(selectPlanTypeUpd[0].displayValue != '' && (selectPlanTypeUpd[0].displayValue === NGEMPLans.Enterprise_Wireless)){
														updateMapUnshpUsr[relatedConfig.guid].push({
															name: 'UnshapeUser',
															value: false,
															displayValue:false
														});
													}
												}
												let keys = Object.keys(updateMapUnshpUsr);
												for(let i = 0; i < keys.length; i++){
													await comp.updateConfigurationAttribute(keys[i], updateMapUnshpUsr[keys[i]], false);
												}
											}											
										});
									}
								}
							});
						}
					}
				});
			}
		}
    },
    /********************************************************************************
	* Author	: shubhi Vijayvergia 
	* edge     :160037
	* Method Name : defaultAddonsonPlanChange,
	* Parameters :value,guid,component
***********************************************************************************/
defaultAddonsonPlanChange: async function(planValue,guid,component,configuration){
    let updateMapChild={};
    var AddonAssocMap={};
	let currentBasket =  await CS.SM.getActiveBasket(); 
	var config= await component.getConfiguration(guid);
    var addonNameList='';
    var chargeIdList='DMCAT_RecurringCharge_001240,DMCAT_RecurringCharge_001277';
    var offer=''; 
    var planId=planValue;
    let inputMap = {};
    inputMap['offerid'] ='DMCAT_Offer_001233' ;
    inputMap['getAddonPriceItemAssociationBulk'] = '';
    inputMap['chargeidList'] = chargeIdList;
    inputMap['plan'] = planId;
    await currentBasket.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(response => {
        if (response && response['setAddonPriceItemAssociation'] != undefined) {
            AddonAssocMap = response['setAddonPriceItemAssociation'];
        }
    });
    if (!configuration.replacedConfigId && config.relatedProductList.length >= 0 && AddonAssocMap) {
		for (var ReletedConfig of config.relatedProductList) {
            updateMapChild[ReletedConfig.guid] = [];
            //Object.keys(AddonAssocMap).forEach(chargeid =>{
                //var addonAss=AddonAssocMap[chargeid];
                if(NXTGENCON_COMPONENT_NAMES.messageBank===ReletedConfig.name){

                    if(AddonAssocMap['DMCAT_RecurringCharge_001240'] && AddonAssocMap['DMCAT_RecurringCharge_001240'].isDefault__c===true){
                        updateMapChild[ReletedConfig.guid].push({
                            name: 'MessageBankAddonAssoc',
                            value: AddonAssocMap['DMCAT_RecurringCharge_001240'].Id,
                            displayValue: AddonAssocMap['DMCAT_RecurringCharge_001240'].AddOn_Name__c,
                            lookup:AddonAssocMap['DMCAT_RecurringCharge_001240']
                        });
                    }
                }else if(NXTGENCON_COMPONENT_NAMES.dataFeatures===ReletedConfig.name){
                    if(AddonAssocMap['DMCAT_RecurringCharge_001277'] && AddonAssocMap['DMCAT_RecurringCharge_001277'].isDefault__c===true){
                            updateMapChild[ReletedConfig.guid].push({
                            name: 'BusinessDemandData',
                            value: AddonAssocMap['DMCAT_RecurringCharge_001277'].Id,
                            displayValue: AddonAssocMap['DMCAT_RecurringCharge_001277'].AddOn_Name__c,
                            lookup:AddonAssocMap['DMCAT_RecurringCharge_001277']
                        });
                    }
                }
           // });

        }

        let keys = Object.keys(updateMapChild);
        //var complock = component.commercialLock;
        //if(complock) comp.lock('Commercial', false);
        for (let i = 0; i < keys.length; i++) {
            component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false); 
        }
    }		
	return Promise.resolve(true);	
},
/************************************************************************************
EDGE-168275, EDGE-164351
Method: updateISPOSReversalRequired
Description: update basket field Is_OF_POS_Reversal_Required__c on the basis of RedeemFundCopy attribute
Inputs: inputMap
History
<03-09-2020> <Manish Berad/Aarathi>
************************************************************************************/
	updateISPOSReversalRequired:async function(){
			let loadedSolution = await CS.SM.getActiveSolution();
			let currentBasket =  await CS.SM.getActiveBasket(); 
			let cmpName=loadedSolution.getComponentByName('Device');
			if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
				if(cmpName.schema && cmpName.schema.configurations && Object.values(cmpName.schema.configurations).length > 0) {
					Object.values(cmpName.schema.configurations).forEach(async (config) => {
						let configguid=config.guid;
						let confiiIId=config.id;
						let repConfigId=config.replacedConfigId; 
						if(repConfigId && configguid){
							let RedeemFundCopy;
							let freeCancellationPeriod;
							let relatedProductChType;
							let relProdguid;
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									relProdguid=relatedConfig.guid;
									let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
									RedeemFundCopy= relatedProductAttr.filter(obj => {
										return obj.name === 'RedeemFundCopy'
										});
										relatedProductChType= relatedProductAttr.filter(obj => {
										return obj.name === 'ChangeType'
											});
										freeCancellationPeriod= relatedProductAttr.filter(obj => {
										return obj.name === 'Free Cancellation Period'
											});	
								});
							}	
							
							let ChanngeTypeAtr;
							if (config.attributes && Object.values(config.attributes).length > 0) {
								let attribs = Object.values(config.attributes);
								 ChanngeTypeAtr = attribs.filter(obj => {
									return obj.name === 'ChangeType'
										});
							}
							
							let inputMap = {};
								inputMap['getChildServicesForDeviceCare'] =repConfigId;
								currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
								let diviceCareServices = result["getChildServicesForDeviceCare"];
								let initialActivationDate=diviceCareServices.Initial_Activation_Date__c;
								let csordStatus=diviceCareServices.csord__Status__c;
								if (initialActivationDate && csordStatus==='Connected'){
									let serviceStartDate =new Date(initialActivationDate);
									let freeCancelPeriod=freeCancellationPeriod[0].displayValue;
									serviceStartDate.setDate(serviceStartDate.getDate()+parseInt(freeCancelPeriod));
									let todaysDate=(new Date()).setHours(0,0,0,0);
									if(todaysDate<serviceStartDate){
										isFreeCancellationPossible=true;
									}else{
										isFreeCancellationPossible=false;
									}
									if(isFreeCancellationPossible){
										if(parseInt(RedeemFundCopy[0].displayValue)>0){
											let inputMap = {};
											inputMap['updateISPOSReversalRequired'] =currentBasket.basketId;;
											currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
								
								
										   });
										}										
									}else{
										//EDGE-164350 start
										var  updateMap = [];
										updateMap[relProdguid] = [];
										updateMap[relProdguid] = [{
											name: 'ChangeType',
												value: "PaidOut",
													displayValue: "PaidOut",
													showInUi:true,
														readOnly: true
															}];
										
										let keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
										}
										//EDGE-164350 end
										
									}
								}
							});
						}
						
                 });
			}
				
		}
	}
}