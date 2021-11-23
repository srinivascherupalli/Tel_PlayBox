/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[NextGenAC_Utils] loaded');

const NGMAC_Utils = {};

NGMAC_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		//Added for Cancel Story DPG-1914
		if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
			NGMAC_UI.updateCancellationAttributes(component.name, configuration.guid, attribute.value);
		}
		if (basketChangeType === 'Change Solution' && component.name === NextGenFC_COMPONENTS.solution && attribute.name === 'DisconnectionDate') {
			NGMAC_Validation.validateDisconnectionDate(component.name, configuration.guid, attribute.value);
		}
		//Added for DPG-2015
		if (component.name === NextGenFC_COMPONENTS.solution  && attribute.name === "BillingAccountShadowNextGenAC") {
			var billingAccount=attribute;
			NGMAC_Validation.validationBillingCheck(billingAccount,component.name,configuration.guid);
		} 
		//DPG-2084 Start
		if(component.name === NextGenFC_COMPONENTS.solution && attribute.name === 'OfferId') {
			await NGMAC_UI.updateAttributeVisiblity('ShowADPRateCard', NextGenFC_COMPONENTS.solution, configuration.guid, false, attribute.value, false);    
		} //DPG-2084 End
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		//For  EDGE-212397 shubhi start
		if (component.name === NextGenFC_COMPONENTS.solution && attribute.name === "BillingAccountLookup") {
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(NextGenFC_COMPONENTS.solution);
				
				if (parentBillingAccountATT){
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NextGenFC_COMPONENTS.AdaptiveCare, oldValueMap.value);
				}
			}
		}
		if (component.name === NextGenFC_COMPONENTS.solution && attribute.name === "Marketable Offer") {
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
		} //For EDGE-212397 shubhi end
	} catch (error) {
		console.log('[NextGenAC_Utils] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

NGMAC_Utils.afterConfigurationAdd = async function(component, configuration) {
	try {
		//For EDGE-212397 by Shubhi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {			
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(NextGenFC_COMPONENTS.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		} //For EDGE-212397 by shubhi ends
	} catch (error) {
		console.log('[NextGenAC_Utils] afterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

NGMAC_Utils.afterSave = async function(result) {
	try {
		let solution = result.solution;
		
		//Added for Cancel Story DPG-1914
		if (basketChangeType === 'Change Solution') {
			NGMAC_UI.updateMainSolutionChangeTypeVisibility(solution);
		}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue 
		await Utils.updateActiveSolutionTotals(); //Added as part of EDGE-154489
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		Utils.hideSubmitSolutionFromOverviewTab();
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
	} catch (error) {
		CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
		console.log('[NextGenAC_Utils] afterSave() exception: ' + error);
		return false;
	}
	CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
	return true;
};

NGMAC_Utils.solutionSetActive = async function(e) {
	try {
		let loadedSolution = await CS.SM.getActiveSolution();
		
		if (loadedSolution.name === NextGenFC_COMPONENTS.solution) {
			let basketId = e.detail.solution.basketId;
			let currentBasket = await CS.SM.loadBasket(basketId);
			await CommonUtills.getBasketData(currentBasket);
			
			if (window.basketStage === "Contract Accepted") {
				loadedSolution.lock("Commercial", false);
			}
			inputMap['AccountId'] = window.accountId;
			NGMAC_Validation.validationErrorBillingCheck();//DPG-2015
			
			// Added for DPG-1784
			if (window.accountId != null) {
				await CommonUtills.setAccountID(NextGenFC_COMPONENTS.solution, window.accountId);
			}
			window.currentSolutionName = loadedSolution.name;
			
			// Added for making BillingAccount ReadOnly in MACD Journey(DPG-1914) 
			if (loadedSolution.name.includes(NextGenFC_COMPONENTS.solution)) {
				if (basketChangeType === "Change Solution" && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
					let componentMap = new Map();
					let componentMapattr = {};
					let billingAccLook = Object.values(loadedSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
					componentMapattr["BillingAccountLookup"] = [];
					componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
					componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
					await CommonUtills.attrVisiblityControl(NextGenFC_COMPONENTS.solution, componentMap);
					
					if (billingAccLook.value === null || billingAccLook.value === "") {
						//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
						CommonUtills.setSubBillingAccountNumberOnCLI(NextGenFC_COMPONENTS.solution, "BillingAccountLookup", true);
					}
				}
			}
			//---MACD
			if (basketChangeType === 'Change Solution') {
				await CommonUtills.updateSolutionNameOnOLoad(NextGenFC_COMPONENTS.solution); // added by Vamsi for EDGE-207354
				await NGMAC_Utils.checkConfigurationSubscriptionsForNGAC('afterSolutionLoaded');
				await NGMAC_UI.updateMainSolutionChangeTypeVisibility(loadedSolution);
			} //END DPG-1914
			//Added by Shresth Start DPG-2395
			if (NextGenFC_COMPONENTS.solution === loadedSolution.name) {
				await NGMAC_UI.handleAttributeVisibility(loadedSolution);
			} //Added by Shresth End DPG-2395
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
		}
	} catch (error) {
		console.log('[NextGenAC_Utils] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

/*********************************
* Author	  : Romil Anand
* Method Name : checkConfigurationSubscriptionsForNGAC
* Defect/US # : DPG-1914
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of NGAC to Cancel
*********************************/
NGMAC_Utils.checkConfigurationSubscriptionsForNGAC = async function(hookname) { //krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var solutionComponent = false;
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.componentType && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
			if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
				solutionComponent = true;
				NGMAC_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(solution, solutionComponent, hookname);
			}

			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = false;
					NGMAC_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname);
				});
			}
		}	
	} catch (error) {
		console.log('[NextGenAC_Utils] solutionSetActive() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : checkConfigurationSubscriptionsForNGACForEachComponent
* Defect/US # : 
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of MS to Cancel
*********************************/
 NGMAC_Utils.checkConfigurationSubscriptionsForNGACForEachComponent = async function(comp, solutionComponent, hookname, solution) { //Krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var ComName = comp.name;
		var optionValues = {};
		
		if (comp.name == NextGenFC_COMPONENTS.solution ){
			optionValues = [{
				"value": "Cancel",
				"label": "Cancel"
			}];
		}
		if (solutionComponent) {
			var cta = '';
			if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				for (const config of Object.values(comp.schema.configurations)) {
					 cta = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
				}
			}
			componentMap[comp.name] = [];
			componentMap[comp.name].push({
				'id': Object.values(comp.schema.configurations)[0].replacedConfigId,
				'guid': Object.values(comp.schema.configurations)[0].guid,
				'ChangeTypeValue': cta[0].value
			});
		} else if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			Object.values(comp.schema.configurations).forEach((config) => {
				if (config.replacedConfigId || config.id) {
					var cta = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
					if (cta && cta.length > 0) {
						if (!componentMap[comp.name]) {
							componentMap[comp.name] = [];
						}
						if (config.replacedConfigId) {
							componentMap[comp.name].push({
								'id': config.replacedConfigId,
								'guid': config.guid,
								'ChangeTypeValue': cta[0].value
							});
						} else {
							componentMap[comp.name].push({
								'id': config.id,
								'guid': config.guid,
								'ChangeTypeValue': cta[0].value
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
			let currentBasket;
			currentBasket = await CS.SM.getActiveBasket();
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				if (values['GetSubscriptionForConfiguration']) {
					statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
				}
			});
			if (statuses) {
				Object.keys(componentMap).forEach( async (comp) => {
					componentMap[comp].forEach(element => {
						var statusValue = 'New';
						var CustomerFacingId = '';
						var CustomerFacingName = '';
						var status = statuses.filter(v => {
							return v.csordtelcoa__Product_Configuration__c === element.id
						});
						
						if (status && status.length > 0) {
							statusValue = status[0].csord__Status__c;
						}
						if (element.ChangeTypeValue !== 'Cancel' && element.ChangeTypeValue !== 'Modify' && (statusValue === 'Suspended' || statusValue === 'Active' || statusValue === 'Pending' )) {
							updateMap[element.guid] = [{
								name: 'ChangeType',
								options: optionValues,
								value: statusValue,
								displayValue: statusValue
							}];
						}
						if (element.ChangeTypeValue === 'Pending') {
							updateMap[element.guid] = [{
								name: 'ChangeType',
								readOnly: true
							}];
						}
					});
					if (updateMap && Object.values(updateMap).length > 0) {
						let component =  solution.getComponentByName(componentName);
						let keys = Object.keys(updateMap);
						
						for (let i = 0; i < keys.length; i++) {
							component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						return Promise.resolve(true);
					}
				});
			}
		}
	} catch (error) {
		console.log('[NextGenAC_Utils] checkConfigurationSubscriptionsForNGACForEachComponent() exception: ' + error);
	}
	return Promise.resolve(true);
};