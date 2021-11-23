
/******************************************************************************************
 * Author	   : Telstra
 * Utility methods for this product; can be referenced from any of the modules
 Change Version History
 Version      No	Author 			                Date                 Change Description  
  1. Murugula Srinivasarao 29-10-2021	  DIGI-32173 - Enable Sales incentives for DMS.
  2.  Pawan Singh	   15-11-2021	  DIGI-40041 , DIGI-39393
  3. Vijay   DIGI-456   07/11/2021    Calling updateOEConsoleButtonVisibility_v2 method
******************************************************************************************/

console.log('[DMS_Utils] loaded');

const DMS_Utils = {};

DMS_Utils.handleIframeMessageDMS = async function(e) {
	try {
		//Added by Nikhil as part of DIGI-603
		//Added by Srinivas as part of DIGI-32173 : DMS - C2O Sales Incentive
		//Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
				await pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
		if(e.data && e.data['command'] === 'RateCard' && e.data['caller'] ==='DMS Product')
		{	
			console.log('Inside if condition');
            await CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],e.data['caller']);
		}
		else if (e.data === 'close') {   // DIGI-39393 , DIGI-40041
			console.log('Inside Elseif condition and data is close');
			pricingUtils.closeModalPopup();
		}
	} catch (error) {
		console.log('[DMS_Utils] handleIframeMessageDMS() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.afterSave = async function(result) {
	try {
		
		let solution = result.solution;
		
		//Added for Cancel Story DIGI-22593
		if (basketChangeType === 'Change Solution') {
			
			DMS_UI.updateMainSolutionChangeTypeVisibility(solution);
		}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		CommonUtills.unlockSolution();
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails();
		DMS_IO.updateModuleChangeforOpptyDMS(solution);
		CommonUtills.lockSolution();
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
	} catch (error) {
		console.log('[DMS_Utils] afterSave() exception: ' + error);
		return false;
	}
	return true;
};

//Event to handle load of OE tabs
DMS_Utils.orderEnrichmentTabLoaded = async function(e) {
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
		}
	} catch (error) {
		console.log('[DMS_Utils] orderEnrichmentTabLoaded() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.solutionSetActive = async function() {
	try {
		let currentBasketDMS = await CS.SM.getActiveBasket();
		let loadedSolutionDMS = await CS.SM.getActiveSolution();

		if (loadedSolutionDMS.name.includes(DMS_COMPONENT_NAMES.solution)) {
			window.currentSolutionName = loadedSolutionDMS.name;
			Utils.updateOEConsoleButtonVisibility();
			
			if (loadedSolutionDMS.componentType && loadedSolutionDMS.name.includes(DMS_COMPONENT_NAMES.solution)) {
				c = 0;
				basketId = currentBasketDMS.basketId;
				solution = loadedSolutionDMS;
				let inputMap = {};
				inputMap["GetSiteId"] = "";
				inputMap["GetBasket"] = basketId;
				
				if (basketStage === "Contract Accepted") {
					loadedSolutionDMS.lock("Commercial", false);
				}
				await CommonUtills.getBasketData(currentBasketDMS);
				await CommonUtills.getSiteDetails(currentBasketDMS);
				CommonUtills.unlockSolution();
				
				if (accountId != null) {
					await CommonUtills.setAccountID(DMS_COMPONENT_NAMES.solution, accountId);
				}
				await Utils.updateOEConsoleButtonVisibility_v2(currentBasketDMS,'oeDMS');// Added by Vijay DIGI-456
                if(!window.isToggled){//Added by vijay DIGI-456
						Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DMS);
					}else{
						CommonUtills.oeErrorOrderEnrichment();
					}
		
				
				if (basketStage === "Contract Accepted") {
					loadedSolutionDMS.lock("Commercial", true);
				}
				CommonUtills.lockSolution();
			}
			
			//---MACD  DIGI-22593
			if (basketChangeType === 'Change Solution') {
				await CommonUtills.updateSolutionNameOnOLoad(DMS_COMPONENT_NAMES.tenancy); // added by Vamsi for EDGE-207354
				await DMS_Utils.checkConfigurationSubscriptionsForNGAC('afterSolutionLoaded');
				await DMS_UI.updateMainSolutionChangeTypeVisibility(loadedSolutionDMS);
			}
			//Added by DIGI-22593
			if (DMS_COMPONENT_NAMES.tenancy === loadedSolutionDMS.name) {
				await DMS_UI.handleAttributeVisibility(loadedSolutionDMS);
			} //Added by Shresth End DIGI-22593
			if (basketStage === "Contract Accepted") {
				loadedSolutionDMS.lock("Commercial", true);
			} //RF for lock issue			
		}
	} catch (error) {
		console.log('[DMS_Utils] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.solutionAfterConfigurationAdd = async function(component, configuration) {
	try {
		let currentBasketDMS = await CS.SM.getActiveBasket();
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(component.name);
		var updateMap = {};
		var vendorname = "";
		let inputMap = {};
		inputMap["OfferId"] = offerName;
		let comp = currentSolution.getComponentByName("DMS Product");
		
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(DMS_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			} 
		}
		await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DMS);
	} catch (error) {
		console.log('[DMS_Utils] solutionAfterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		CommonUtills.unlockSolution();
		let oldValue = oldValueMap.value;
		let loadedSolutionDMS = await CS.SM.getActiveSolution();
		
		if (attribute["Solution Name"] === DEFAULTSOLUTIONNAME_DMS && attribute.name == "Marketable Offer") {
			CommonUtils.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue);
		}
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionDMS.lock("Commercial", false);
			
			if (component.name === 'Customer requested Dates') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
		}
		//Added for Cancel Story DIGI-22593
		if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
			
			// when our product is changetype is cancel , need to cancel the change type of solution as well
			if (attribute.value == 'Cancel') {
				// console.log('<== change type = cancel  ==> ');
				// let solChangeType={};
				if(loadedSolutionDMS.schema.configurations){ 
					// let configSol = await loadedSolutionDMS.getConfiguration((loadedSolutionDMS.schema.configurations)[0].guid);
					// solChangeType = await configSol.getAttribute("ChangeType");
 
					let solChangeType;
					if (loadedSolutionDMS && loadedSolutionDMS.name.includes(DMS_COMPONENT_NAMES.solution)) {
					
						if (loadedSolutionDMS.schema.configurations && Object.values(loadedSolutionDMS.schema.configurations).length > 0) {
							for (const config of Object.values(loadedSolutionDMS.schema.configurations)) {
								
								solChangeType = Object.values(config.attributes).filter(a => {
									return a.name === 'ChangeType'
								}); 
								
							}
						}
					}
					// console.log('<== solChangeType==> ',solChangeType);
					if (solChangeType &&  solChangeType[0].value !== 'Active' ) {
						// console.log('<==  changing sol change type :solChangeType==> ',solChangeType);
						let updateSolMap = {};
						updateSolMap[Object.values(loadedSolutionDMS.schema.configurations)[0].guid] = [];
						updateSolMap[Object.values(loadedSolutionDMS.schema.configurations)[0].guid].push({
							name: 'ChangeType',
							value: 'Active',
							showInUi: false,
						});
						await loadedSolutionDMS.updateConfigurationAttribute(Object.values(loadedSolutionDMS.schema.configurations)[0].guid, updateSolMap[Object.values(loadedSolutionDMS.schema.configurations)[0].guid], true);

					}
				//
				}
			}

			// end : when our product is changetype is cancel , need to cancel the change type of solution as well

			DMS_UI.updateCancellationAttributes(component.name, configuration.guid, attribute.value);
		}
		if (basketChangeType === 'Change Solution' && component.name === DMS_COMPONENT_NAMES.tenancy && attribute.name === 'DisconnectionDate') {
			DMS_Validation.validateDisconnectionDate(component.name, configuration.guid, attribute.value);
		}
		//-----DIGI-22593 END------
		
		if (component.name === "Tenancy Admin Contact Details" && attribute.name === "TenancyPrimaryContact") {
			DMS_Utils.updateTenancyContactDetailsDMS(configuration.parentConfiguration, attribute.value);
		} //changes ended by shashank DIGI-4637
		if (component.name === DMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup") {
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(DMS_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', DMS_COMPONENT_NAMES.tenancy,oldValue);
				}
			}
		}
		if (component.name === DMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountShadow") {
			billingAccount = attribute.value;
		}
		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionDMS.lock("Commercial", true);
		}
		CommonUtills.lockSolution();
	} catch (error) {
		console.log('[DMS_Utils] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.beforeSave = async function() {
	try {
		CommonUtills.unlockSolution();
		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		
		if (!ExpectedSIO) {
			return false;
		}
		CommonUtills.lockSolution();
	} catch (error) {
		console.log('[DMS_Utils] beforeSave() exception: ' + error);
		return false;
	}
	return true;
};

DMS_Utils.updateTenancyContactDetailsDMS = async function(guid, newValue) {
	try {
		if (basketStage !== "Contract Accepted") {
			return Promise.resolve(true);
		}
		let currentSolution = await CS.SM.getActiveSolution();

		if (currentSolution.componentType && currentSolution.name.includes(DMS_COMPONENT_NAMES.solution)) {
			let currentComponent = currentSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
			
			if (currentComponent) {
				let config = currentComponent.getConfiguration(guid);
				
				if (config) {
					if (basketStage === "Contract Accepted") {
						currentSolution.lock("Commercial", false);
					}
					var updateConfigMap = {};
					updateConfigMap[config.guid] = [];
					updateConfigMap[config.guid].push({
						name: "TenancyPrimaryContact",
						value: newValue
					});
					
					if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
						await currentComponent.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
					}
					if (basketStage === "Contract Accepted") {
						currentSolution.lock("Commercial", true);
					}
				}
			}
		}
	} catch (error) {
		console.log('[DMS_Utils] updateTenancyContactDetailsDMS() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Romil Anand
* Method Name : checkConfigurationSubscriptionsForNGAC
* Defect/US # : DPG-1914
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of NGAC to Cancel
 DIGI-22593
*********************************/
DMS_Utils.checkConfigurationSubscriptionsForNGAC = async function(hookname) { //krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var solutionComponent = false;
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.componentType && solution.name.includes(DMS_COMPONENT_NAMES.tenancy)) {
			if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = true;
					DMS_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname,solution);
				});
			}

			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = false;
					DMS_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname,solution);
				});
			}
		}	
	} catch (error) {
		console.log('[DMS_Utils] solutionSetActive() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : checkConfigurationSubscriptionsForNGACForEachComponent
* Defect/US # : 
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of MS to Cancel
 DIGI-22593
*********************************/
 DMS_Utils.checkConfigurationSubscriptionsForNGACForEachComponent = async function(comp, solutionComponent, hookname, solution) { //Krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var ComName = comp.name;
		var optionValues = {};
		if (comp.name == DMS_COMPONENT_NAMES.tenancy ){
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
						let component =  solution.getComponentByName(ComName);
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
		console.log('[DMS_Utils] checkConfigurationSubscriptionsForNGACForEachComponent() exception: ' + error);
	}
	return Promise.resolve(true);
};


/*********************************
* Author	  : Mahima Gandhe
* Method Name : validateChangeType
* Defect/US # : 
* Invoked When: Validate and Save
* Description : Validate Change type on Save
DIGI-22593
*********************************/
DMS_Utils.validateChangeType=async function(solution){
    
    let comp = solution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
    if(comp){
		let compConfigs = comp.getConfigurations();   
        Object.values(compConfigs).forEach((config) => {
            let replacedConfig = config.getAttribute("ReplacedConfig");
            let changeTypeAttr = config.getAttribute("ChangeType");
            if(replacedConfig!=null && changeTypeAttr=='Cancel'){
           		return Promise.resolve(true);                
            }else{
                return Promise.resolve(false);               
            }
    }  );
}};