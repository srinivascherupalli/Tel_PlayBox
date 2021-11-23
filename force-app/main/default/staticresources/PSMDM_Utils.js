/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[PSMDM_Utils] loaded');

const PSMDM_Utils = {};

PSMDM_Utils.afterOrderEnrichmentConfigurationAdd = async function(componentName, configuration, orderEnrichmentConfiguration) {
	try {
		//EDGE-120711 : Start - added by Purushottam to Enable oe-product checkbox-wrapper
		if (configuration["guid"]) {
			window.afterOETabLoaded(configuration["guid"], componentName, configuration["name"], '');
		} //EDGE-120711 : End
		PSMDM_Utils.initializePMDMOEConfigs();
		window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
	} catch (error) {
		console.log('[PSMDM_Utils] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

PSMDM_Utils.solutionAfterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) { // Added 'async' by Aman Soni as a part of EDGE-148455
	try {
		CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(component.name);
		
		//Added part of EDGE-186075 to avoid lock errors
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		if (component.name === 'Technical Details' || component.name === 'Tenancy') { //EDGE-137491 Component name changed
			if (attribute.name === 'Technical Contact' || attribute.name === 'PurchaseOrder' || attribute.name === 'TenancyID') {
				PSMDM_Utils.updateOrderTechinicalContactOnPS(configuration.guid, attribute.value, attribute.name,currentSolution);
			}
		}
		//EDGE-132318
		if (component.name === 'Operations User' && attribute.name === 'Operational User') {
			PSMDM_Utils.updateOrderTechinicalContactOnPS(configuration.guid, attribute.value, attribute.name,currentSolution);
		}
		var updateMap = [];
		
		if (component.name === PSMDM_COMPONENT_NAMES.UC && attribute.name === 'Quantity') {
			quantVal = attribute.value;
			
			if (quantVal.indexOf(".") > -1) {
				q = quantVal.split(".");
				
				if (q[1].length > 2) {
					updateMap[configuration.guid] = [];
					updateMap[configuration.guid].push({
						name: "Quantity",
						value: '',
						displayValue: '',
						readOnly: false,
						required: true
					});
					
					if (updateMap && Object.keys(updateMap).length > 0) {
						keys = Object.keys(updateMap);
						
						for (let i = 0; i < keys.length; i++) {
							currentComponent.updateConfigurationAttribute(keys[i],updateMap[keys[i]],true).then(currentComponent => console.log('Qualnity Attribute update', currentComponent));
						}
					}
					// Below code has to be checked
					let config = await component.getConfiguration(configuration.guid);
				}
			}
		}
		window.afterAttributeUpdatedOE(component.name, configuration.guid, oldValueMap['value'], attribute.value);
		// Added part of EDGE-186075 to avoid lock errors
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (component.name === PSMDM_COMPONENT_NAMES.solution && attribute.name === 'BillingAccountLookup') {
			if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
				if (window.accountId !== null && window.accountId !== "") {
					let solution = await CS.SM.getActiveSolution();
					let component = await solution.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
					let configs = component.getConfigurations();
					let childGuid = '';
					Object.values(configs).forEach(async (config) => {
						childGuid = config.guid;
						CommonUtills.setConfigAccountId(PSMDM_COMPONENT_NAMES.UC, window.accountId,childGuid);
					});
					CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
					await CHOWNUtils.getParentBillingAccount(PSMDM_COMPONENT_NAMES.solution);
					
					if (parentBillingAccountATT) {
						CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', PSMDM_COMPONENT_NAMES.UC, oldValueMap['value']);
					}
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		console.log('[PSMDM_Utils] solutionAfterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

PSMDM_Utils.addDefaultPSMDMOEConfigs = async function () {
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		
		if (basketStage !== 'Contract Accepted') {
			return;
		}
		var oeMap = [];
		
		if (currentSolution.componentType && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				Object.values(currentSolution.components).forEach((comp) => {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (comp.orderEnrichments && Object.values(comp.orderEnrichments).length > 0) {
								Object.values(comp.orderEnrichments).forEach((oeSchema) => {
									var found = false;
									
									if (config.orderEnrichmentList) {
										var oeConfig = config.orderEnrichmentList.filter(oe => {
											return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId);
										});
										if (oeConfig && oeConfig.length > 0) {
											found = true;
										}
									}
									if (!found) {
										var el = {};
										el.componentName = comp.name;
										el.configGuid = config.guid;
										el.oeSchema = oeSchema;
										oeMap.push(el);
									}
								});
							}
						});
					}
				});
			}
		}
		if (oeMap.length > 0) {
			let map = [];
			
			for (var i = 0; i < oeMap.length; i++) {
				let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
				await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
			}
		}
		//Sukul
		await PSMDM_Utils.initializePMDMOEConfigs();
		
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(PSMDM_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
	} catch (error) {
		console.log('[PSMDM_Utils] addDefaultPSMDMOEConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};

PSMDM_Utils.initializePMDMOEConfigs = async function() {
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
		
		if (currentSolution) {
			if (currentSolution.componentType && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
				if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
					for (var i = 0; i < Object.values(currentSolution.components).length; i++) {
						var comp = Object.values(currentSolution.components)[i];
						
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {
								var config = Object.values(comp.schema.configurations)[j];
								var updateMap = {};
								
								if (config.orderEnrichmentList) {
									for (var k = 0; k < config.orderEnrichmentList.length; k++) {
										var oe = config.orderEnrichmentList[k];
										var basketAttribute = Object.values(oe.attributes).filter(a => {
											return a.name.toLowerCase() === 'basketid';
										});
										
										if (basketAttribute && basketAttribute.length > 0) {
											if (!updateMap[oe.guid]) {
												updateMap[oe.guid] = [];
											}
											updateMap[oe.guid].push({
												name: basketAttribute[0].name,
												value: basketId
											});
										}
										updateMap[oe.guid].push({
											name: 'OfferName',
											value: PSMDM_COMPONENT_NAMES.OfferName
										});
									}
								}
								if (updateMap && Object.keys(updateMap).length > 0) {
									let keys = Object.keys(updateMap);
									
									for (var h = 0; h < Object.values(updateMap).length; h++) {
										currentComponent.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false);
									}
								}
							}
						}
					}
				}
			}
		}
	} catch (error) {
		console.log('[PSMDM_Utils] initializePMDMOEConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*
Added as part of EDGE-149887
This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
PSMDM_Utils.updateSolutionName_TMDM_PS = async function() {
	try {
		var listOfAttributes = ['Solution Name', 'GUID'], attrValuesMap = {};
		attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,PSMDM_COMPONENT_NAMES.solution);
		let solution = await CS.SM.getActiveSolution();
		let component = solution.getComponentByName(PSMDM_COMPONENT_NAMES.solution);
		let guid;
		
		if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_TMDM_PS) {
			let updateConfigMap = {};
			guid = attrValuesMap['GUID'];
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'Solution Name',
				value: DEFUALTOFFERNAME_TMDM_PS,
				displayValue: DEFUALTOFFERNAME_TMDM_PS
			});
			
			if (updateConfigMap) {
				if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					keys = Object.keys(updateConfigMap);
					
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			}
		}
	} catch (error) {
		console.log('[PSMDM_Utils] updateSolutionName_TMDM_PS() exception: ' + error);
	}
};

/*********************************
* Author	  : Raviteja
* Method Name : updateOrderTechinicalContactOnPS
* Invoked When: Order Techinical Contact on OE is updated
* Description : 1. Updates the Order Techinical Contact Id on its parent(UC)
* Parameters  : 1. String : configuration guid of Order Techinical Details tab
*               2. String : new value of the Order Techinical Contact attribute
*********************************/
PSMDM_Utils.updateOrderTechinicalContactOnPS = function(guid, attrValue, attributeType, loadedSolution) {
	try {
		product = loadedSolution;
		let currentComponent = product.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
		
		if (product.componentType && product.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if (comp.name === PSMDM_COMPONENT_NAMES.UC) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							var psConfigGUID;
							Object.values(comp.schema.configurations).forEach((psConfig) => {
								if (psConfig.orderEnrichmentList && psConfig.orderEnrichmentList.length > 0) {
									var opeConfig = psConfig.orderEnrichmentList.filter(config => {
										return config.guid === guid;
									});
									
									if (opeConfig && opeConfig[0]) {
										psConfigGUID = psConfig.guid;
									}
								}
							});
							
							if (psConfigGUID) {
								var updateMap = [];
								updateMap[psConfigGUID] = [];
								updateMap[psConfigGUID].push({
									name: attributeType,
									value: attrValue,
									displayValue: attrValue,
									readOnly: true,
									required: false
								});
								
								if (updateMap && Object.keys(updateMap).length > 0) {
									keys = Object.keys(updateMap);
									
									//DPG-3391 Start
									if (basketStage === 'Contract Accepted') {
										loadedSolution.lock('Commercial', false);
									} //DPG-3391 End
									
									for (let i = 0; i < keys.length; i++) {
										currentComponent.updateConfigurationAttribute(keys[i],updateMap[keys[i]], true);
									}
									
									//DPG-3391 Start
									if (basketStage === 'Contract Accepted') {
										loadedSolution.lock('Commercial', true);
									} //DPG-3391 End
								}
							}
						}
					}
				});
			}
		}
	} catch (error) {
		console.log('[PSMDM_Utils] updateOrderTechinicalContactOnPS() exception: ' + error);
	}
};