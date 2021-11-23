/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[VeloCloud_Utils] loaded');

const VC_Utils = {};

VC_Utils.afterSave = async function() {
	try {
		VC_Utils.updateSolutionName_Velo();
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		Utils.hideSubmitSolutionFromOverviewTab();
	} catch (error) {
		console.log('[VeloCloud_Utils] afterSave() exception: ' + error);
	}
};

/* 	 
This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
VC_Utils.updateSolutionName_Velo = async function() {
	try {
		var listOfAttributes = ['Solution Name', 'GUID'], attrValuesMap = {};
		attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,VELOCLOUD_COMPONENTS.VeloCloudSol);
		let solution = await CS.SM.getActiveSolution();
		let component = solution.getComponentByName(VELOCLOUD_COMPONENTS.VeloCloudSol)
		let guid;
		
		if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_VELO) {
			let updateConfigMap = {};
			guid = attrValuesMap['GUID'];
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'Solution Name',
				value: DEFAULTOFFERNAME_VELO,
				displayValue: DEFAULTOFFERNAME_VELO
			});
			
			if (updateConfigMap) {
				if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					keys = Object.keys(updateConfigMap);
					
					for (let i = 0; i < keys.length; i++) {
						component.lock('Commercial', false);
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			}
		}
	} catch (error) {
		console.log('[VeloCloud_Utils] updateSolutionName_Velo() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Suyash
* Method Name : initializeOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. sets basket id to oe configs so it is available immediately after opening oe
* Parameters  : none
*********************************/
VC_Utils.initializeVeloOETenancyConfigs = async function() {
	console.log('Inside initializeVeloOETenancyConfigs');
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		console.log('currentSolution of initializeVeloOETenancyConfigs ==> ' + currentSolution );
		let configurationGuid = '';
		
		if (currentSolution) {
			console.log('Inside initializeVeloOETenancyConfigs if condition');
			if (currentSolution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
				if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
					for (const comp of Object.values(currentSolution.components)) {
						for(const config of Object.values(comp.schema.configurations)) {
							configurationGuid = config.guid;
							var updateMap = {};
							
							if (config.orderEnrichmentList) {
								for (const oe of config.orderEnrichmentList) {
									var basketAttribute = Object.values(oe.attributes).filter(a => {
										return a.name.toLowerCase() === 'basketid'
									});
									
									if (basketAttribute && basketAttribute.length > 0) {
										if (!updateMap[oe.guid]) {
											updateMap[oe.guid] = [];
										}
										updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
									}
								}
							}
							if (updateMap && Object.keys(updateMap).length > 0) {
								if (updateMap && Object.keys(updateMap).length > 0) {
									keys = Object.keys(updateMap);
									console.log('initializeOEConfigs updateMap:', updateMap);
									
									for (var i = 0; i < updateMap.length; i++){
										comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid,keys[i], updateMap[keys[i]], true);
									}
								}
							}
						}
					}
				}
			}
		}
	} catch (error) {
		console.log('[VeloCloud_Utils] initializeVeloOETenancyConfigs() exception: ' + error);
		return false;
	}
	return true;
};

/*********************************
 * Author	   : Suyash
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if there is none (NumberManagementv1 is excluded)
 * Parameters  : none
 *********************************/
VC_Utils.addDefaultVeloOETenancyConfigs = async function() {
	try {
		if (basketStage !== 'Contract Accepted') {
			return;
		}
		var oeMap = [];
		let currentSolution = await CS.SM.getActiveSolution();
		
		if (currentSolution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
			let configs = currentSolution.getConfigurations();
			
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				Object.values(currentSolution.components).forEach((comp) => {
					Object.values(comp.schema.configurations).forEach((config) => {
						Object.values(comp.orderEnrichments).forEach((oeSchema) => {
							if (oeSchema) {
								var found = false;
								
								if (config.orderEnrichmentList) {
									var oeConfig = config.orderEnrichmentList.filter(oe => {return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId )});
									
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
							}
						});
					});
				});
			}
		}
		if (oeMap.length > 0) {
			for (var i = 0; i < oeMap.length; i++) {
				let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
				component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
			}
		}
		await VC_Utils.initializeVeloOETenancyConfigs();
	} catch (error) {
		console.log('[VeloCloud_Utils] addDefaultVeloOETenancyConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};
/***********************************
* Author	  : Vijay
* Method Name : SDWAN_handleIframeMessage
* Invoked When: order enrichment close button 
* Description : use for close order enrichment
* Parameters  : 
***********************************/
VC_Utils.VC_handleIframeMessage = async function(e) {
        //Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
				await pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
		            
 }; 