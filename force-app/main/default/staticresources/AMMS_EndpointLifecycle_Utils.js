/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[AMMS_EndpointLifecycle_Utils] loaded');

const AMMS_EndpointLifecycle_Utils = {};

AMMS_EndpointLifecycle_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		//Added for Cancel Story DIGI-5568
		if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
			AMMS_EndpointLifecycle_UI.updateCancellationAttributes(component.name, configuration.guid, attribute.value);
		}
		if (basketChangeType === 'Change Solution' && component.name === EndpointLifecycle_COMPONENTS.solution && attribute.name === 'DisconnectionDate') {
			AMMS_EndpointLifecycle_Validation.validateDisconnectionDate(component.name, configuration.guid, attribute.value);
		}
		
		//DPG-2084 Start
		if(component.name === EndpointLifecycle_COMPONENTS.solution && attribute.name === 'OfferId') {
			await AMMS_EndpointLifecycle_UI.updateAttributeVisiblity('LifecycleRateCard', EndpointLifecycle_COMPONENTS.solution, configuration.guid, false, attribute.value, false);    
		} //DPG-2084 End
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		//For  EDGE-212397 shubhi start
		if (component.name === EndpointLifecycle_COMPONENTS.solution && attribute.name === "BillingAccountLookup") {
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(EndpointLifecycle_COMPONENTS.solution);
				
				if (parentBillingAccountATT){
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', EndpointLifecycle_COMPONENTS.LifecycleManagement, oldValueMap.value);
				}
			}
		}
		if (component.name === EndpointLifecycle_COMPONENTS.solution && attribute.name === "Marketable Offer") {
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
		} //For EDGE-212397 shubhi end
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

AMMS_EndpointLifecycle_Utils.afterConfigurationAdd = async function(component, configuration) {
	try {
		//For EDGE-212397 by Shubhi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {			
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(EndpointLifecycle_COMPONENTS.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		} //For EDGE-212397 by shubhi ends
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] afterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

AMMS_EndpointLifecycle_Utils.afterSave = async function(result) {
	try {
		let solution = result.solution;
		//Added for Cancel Story DPG-1914
		
		if (basketChangeType === 'Change Solution') {
			AMMS_EndpointLifecycle_UI.updateMainSolutionChangeTypeVisibility(solution);
		}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		await Utils.updateActiveSolutionTotals(); //Added as part of EDGE-154489
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		Utils.hideSubmitSolutionFromOverviewTab();
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] afterSave() exception: ' + error);
		return false;
	}
	return true;
};

AMMS_EndpointLifecycle_Utils.solutionSetActive = async function(e) {
	try {
		let loadedSolution = await CS.SM.getActiveSolution();
		
		if (loadedSolution.name === EndpointLifecycle_COMPONENTS.solution) {
			window.addEventListener("message", AMMS_EndpointLifecycle_Utils.AMMSLCPlugin_handleIframeMessage); // DIGI-27816
            setInterval(AMMS_EndpointLifecycle_Utils.AMMSLCPlugin_processMessagesFromIFrame, 500);// DIGI-27816
			let basketId = e.detail.solution.basketId;
			let currentBasket = await CS.SM.loadBasket(basketId);
			await CommonUtills.getBasketData(currentBasket);
			
			if (window.basketStage === "Contract Accepted") {
				loadedSolution.lock("Commercial", false);
			}
			inputMapAMMS['AccountId'] = window.accountId;
			
			// Added for DPG-1784
			if (window.accountId != null) {
				await CommonUtills.setAccountID(EndpointLifecycle_COMPONENTS.solution, window.accountId);
			}
			window.currentSolutionName = loadedSolution.name;
			
			// Added for making BillingAccount ReadOnly in MACD Journey(DPG-1914) 
			if (loadedSolution.name.includes(EndpointLifecycle_COMPONENTS.solution)) {
				if (basketChangeType === "Change Solution" && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
					let componentMap = new Map();
					let componentMapattr = {};
					let billingAccLook = Object.values(loadedSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
					componentMapattr["BillingAccountLookup"] = [];
					componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
					componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
					await CommonUtills.attrVisiblityControl(EndpointLifecycle_COMPONENTS.solution, componentMap);
					
					if (billingAccLook.value === null || billingAccLook.value === "") {
						//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
						CommonUtills.setSubBillingAccountNumberOnCLI(EndpointLifecycle_COMPONENTS.solution, "BillingAccountLookup", true);
					}
				}
			}
			//---MACD
			if (basketChangeType === 'Change Solution') {
				await CommonUtills.updateSolutionNameOnOLoad(EndpointLifecycle_COMPONENTS.solution); // added by Vamsi for EDGE-207354
				await AMMS_EndpointLifecycle_Utils.checkConfigurationSubscriptionsForNGAC('afterSolutionLoaded');
				await AMMS_EndpointLifecycle_UI.updateMainSolutionChangeTypeVisibility(loadedSolution);
			} //END DPG-1914
			//Added by Shresth Start DPG-2395
			if (EndpointLifecycle_COMPONENTS.solution === loadedSolution.name) {
				await AMMS_EndpointLifecycle_UI.handleAttributeVisibility(loadedSolution);
			} //Added by Shresth End DPG-2395
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
		}
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] solutionSetActive() exception: ' + error);
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
AMMS_EndpointLifecycle_Utils.checkConfigurationSubscriptionsForNGAC = async function(hookname) { //krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var solutionComponent = false;
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.componentType && solution.name.includes(EndpointLifecycle_COMPONENTS.solution)) {
			if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
				solutionComponent = true;
				AMMS_EndpointLifecycle_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(solution, solutionComponent, hookname);
			}

			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = false;
					AMMS_EndpointLifecycle_Utils.checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname);
				});
			}
		}	
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] solutionSetActive() exception: ' + error);
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
 AMMS_EndpointLifecycle_Utils.checkConfigurationSubscriptionsForNGACForEachComponent = async function(comp, solutionComponent, hookname, solution) { //Krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var ComName = comp.name;
		var optionValues = {};
		
		if (comp.name == EndpointLifecycle_COMPONENTS.solution ){
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
		console.log('[AMMS_EndpointLifecycle_Utils] checkConfigurationSubscriptionsForNGACForEachComponent() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Mahima Gandhe
* Method Name : validateChangeType
* Defect/US # : 
* Invoked When: Validate and Save
* Description : Validate Change type on Save
*********************************/
AMMS_EndpointLifecycle_Utils.validateChangeType=async function(solution){
    
    let comp = solution.getComponentByName(EndpointLifecycle_COMPONENTS.LifecycleManagement);
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

AMMS_EndpointLifecycle_Utils.AMMSLCPlugin_processMessagesFromIFrame = async function() { // DIGI-27816
	let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489

	if (basketStage === "Contract Accepted") {
	currentSolution.lock("Commercial", false);
	}
	var data = sessionStorage.getItem("payload");
	var close = sessionStorage.getItem("close");
	var message = {};
	if (data) {
		message["data"] = JSON.parse(data);
		AMMSLCPlugin_handleIframeMessage(message);
	}
	if (close) {
		message["data"] = close;
		AMMSLCPlugin_handleIframeMessage(message);
	}
	if (basketStage === "Contract Accepted") {
		currentSolution.lock("Commercial", true);
	} //RF for lock issue
}

 AMMS_EndpointLifecycle_Utils.AMMSLCPlugin_handleIframeMessage = async function(e) { // DIGI-27816
	if (
		!e.data ||
		!e.data["command"] ||
		e.data["command"] !== "ADDRESS" ||
		(e.data["caller"] && e.data["caller"] === EndpointLifecycle_COMPONENTS.LifecycleManagement)
	) {
		sessionStorage.removeItem("close");
		sessionStorage.removeItem("payload");
	}
	if (e.data && e.data["command"] && e.data["command"] === "RateCard" && e.data["caller"]) {
		CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],e.data["caller"]); 
	}

	var message = {};
	message = e["data"];
	messgae = message["data"];
	
    //if (message.caller && message.caller !== "Managed Services") {
    //    return;
    //}
		
	//Uncommented by Purushottam as a part of EDGE -145320 || Start
	if (e.data === "close") {
		try {
			var d = document.getElementsByClassName("mat-dialog-container");
			if (d) {
				for (var i = 0; i < d.length; i++) {
					d[i].parentElement.removeChild(d[i]);
				}
			}
			var el = document.getElementsByClassName("cdk-global-overlay-wrapper");
			if (el) {
				for (var i = 0; i < el.length; i++) {
					el[i].parentNode.removeChild(el[i]);
				}
			}
		} catch (err) { }
	}
	//Uncommented by Purushottam as a part of EDGE -145320 || End
}
//Check Added for Expected SIOs
AMMS_EndpointLifecycle_Utils.beforeSave = async function() {
	try {
		CommonUtills.unlockSolution();
		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		
		if (!ExpectedSIO) {
			return false;
		}
		CommonUtills.lockSolution();
	} catch (error) {
		console.log('[AMMS_EndpointLifecycle_Utils] beforeSave() exception: ' + error);
		return false;
	}
	return true;
};

