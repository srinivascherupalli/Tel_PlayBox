/*
 * Handles all UI-related logic
 */
console.log('[EnterpriseManagedService_UI] loaded');

const EMS_UI = {};

//EDGE-198536: message listener and Utils.updateImportConfigButtonVisibility moved to window.document.addEventListener('SolutionSetActive' block
//Changes as part of EDGE-154489 start
EMS_UI.afterSave = async function(result) {
	try {
		Utils.updateOEConsoleButtonVisibility();
		Utils.updateCustomButtonVisibilityForBasketStage();
		
		//Added for Cancel Story DPG-2648
		if (BasketChange === "Change Solution") {
			EMS_UI.updateMainSolutionChangeTypeVisibility(result.solution);
		}
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue 
		EMS_UI.setChangeTypeVisibility(result.solution);
		EMS_Utils.updateChangeTypeAttribute();
        Utils.hideSubmitSolutionFromOverviewTab(); //EDGE-135267
		await Utils.updateActiveSolutionTotals(); //Added as part of EDGE-154489
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
	} catch (error) {
		CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
		console.log('[EnterpriseManagedService_UI] afterSave() exception: ' + error);
		return false;
	}
	CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
	return true;
};

/*********************************
* Krunal / Monali
* Cancel and Modify Journey DPG-2647 || DPG-2648
* Introduced logics for MAC journey
*********************************/
EMS_UI.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
	try {
		if (componentName === EMS_COMPONENT_NAMES.userSupport || componentName === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
			let updateMap = {};
			updateMap[guid] = [];
			
			if (changetypeMACsolution === 'Cancel') {
				updateMap[guid].push({
					name: "ChangeType",
					value: changetypeMACsolution,
					label: "ChangeType",
					showInUi: true,
					readOnly: true});
			} else if (changetypeMACsolution === 'Modify') {
				updateMap[guid].push({
					name: "ChangeType",
					value: changetypeMACsolution,
					label: "ChangeType",
					showInUi: true,
					readOnly: false});
			}
			
			////Added for Cancel Story DPG-2648 - START
			if (changetypeMACsolution === 'Cancel') {
				updateMap[guid].push({
					name: "FeatureLevel",
					readOnly: true
				}, {
					name: "TechnicalSupport",
					readOnly: true});
			} //Added for Cancel Story DPG-2648 - END
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(componentName);
			var complock = component.commercialLock;
			
			if (complock) {
				component.lock('Commercial', false);
			}
            let keys = Object.keys(updateMap);
			
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
			
			if (complock) {
				component.lock('Commercial', true);
			}
			EMS_Utils.checkConfigurationSubscriptionsForMS('afterConfigurationAddedToMacBasket');
        } //--DPG-2647 -- Krunal Taak -- End
	} catch (error) {
		console.log('[EMS_UI] afterConfigurationAddedToMacBasket() exception: ' + error);
		return false;
	}
	return true;
};

EMS_UI.setChangeTypeVisibility = async function(product) {
	try {
		var updateSolnMap = {};
		//Changes as part of EDGE-154489 start
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(EMS_COMPONENT_NAMES.solution); //Changes as part of EDGE-154489 end
		//ADDED FOR DPG-4134
		var replacedConfig; //DPG-4134
		
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			for (const config of Object.values(solution.schema.configurations)) {
				chtype = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				replacedConfig = config.replacedConfigId; //DPG-4134
			}
		} //End DPG-4134
		
		//Aditya: Edge:142084, Enable New Solution in MAC Basket
		if (window.BasketChange === 'Change Solution' && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")) {
			if (product.schema.configurations) {
				Object.values(product.schema.configurations).forEach(config => {
					updateSolnMap[config.guid] = [];
					updateSolnMap[config.guid].push({
						name: "ChangeType",
						showInUi: true});
				});
			}
			
			//Changes as part of EDGE-154489 start
			if (updateSolnMap && Object.keys(updateSolnMap).length > 0) {
				keys = Object.keys(updateSolnMap);
				
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateSolnMap[keys[i]], true);
				}
			} //Changes as part of EDGE-154489 end here
			return Promise.resolve(true);
		} else {
			return Promise.resolve(true);
		}
	} catch (error) {
		console.log('[EMS_UI] setChangeTypeVisibility() exception: ' + error);
	}
};

/*********************************
* Author	: Monali Mukherjee
* Method Name : EMSPlugin_UpdateMainSolutionChangeTypeVisibility
* Defect/US # : DPG-1914
* Invoked When: On Solution Load
* Description : For Setting Visibility
*********************************/
EMS_UI.updateMainSolutionChangeTypeVisibility = async function(solution) {
	try {
		if (BasketChange !== 'Change Solution') {
			return;
		}
		
		//Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- START
		var chtype;
		var replacedConfig; //DPG-4134
		
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			for (const config of Object.values(solution.schema.configurations)) {
				chtype = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				replacedConfig = config.replacedConfigId; //DPG-4134
			}
		}
		
		//DPG-4134
		if (replacedConfig === null || replacedConfig === undefined || replacedConfig === "") {
			let updateMap = {};
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [{
				name: 'ChangeType',
				showInUi: false
			}, {
				name: 'CancellationReason',
				showInUi: false
			}, {
				name: 'DisconnectionDate',
				showInUi: false
			}, {
				name: 'Space1',
				showInUi: true
			}, {
				name: 'Space2',
				showInUi: true
			}];
			await EMS_UI.updateAttributeVisiblity('ChangeType', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		//DPG-4134
		if ((chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New') && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")) {
			let updateMap = {};
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [{
				name: 'ChangeType',
				showInUi: true
			}, {
				name: 'CancellationReason',
				showInUi: false
			}, {
				name: 'DisconnectionDate',
				showInUi: false
			}, {
				name: 'Space1',
				showInUi: true
			}, {
				name: 'Space2',
				showInUi: false
			}];
			await EMS_UI.updateAttributeVisiblity('ChangeType', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if (chtype[0].value === 'Cancel') {
			let updateMap = {};
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [{
				name: 'ChangeType',
				showInUi: true
			}, {
				name: 'CancellationReason',
				showInUi: true
			}, {
				name: 'DisconnectionDate',
				showInUi: true
			}, {
				name: 'Space1',
				showInUi: false
			}, {
				name: 'Space2',
				showInUi: false
			}];
			await EMS_UI.updateAttributeVisiblity('ChangeType', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMS_UI.updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMS_UI.updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, false);
			await EMS_UI.updateAttributeVisiblity('TenancyButton', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if (chtype[0].value === 'Modify') {
			let updateMap = {};
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [{
				name: 'ChangeType',
				showInUi: true
			}, {
				name: 'CancellationReason',
				showInUi: false
			}, {
				name: 'DisconnectionDate',
				showInUi: false
			}, {
				name: 'Space1',
				showInUi: true
			}, {
				name: 'Space2',
				showInUi: false
			}];
			await EMS_UI.updateAttributeVisiblity('ChangeType', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		} //Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- END
	} catch (error) {
		console.log('[EMS_UI] updateMainSolutionChangeTypeVisibility() exception: ' + error);
	}
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : EMSPlugin_updateAttributeVisiblity
* Defect/US # : DPG-1914
* Invoked When: On Attribute Update
* Description : For Setting Visibility
*********************************/
EMS_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
	try {
		let updateMap = {};
		updateMap[guid] = [];
		updateMap[guid].push({
			name: attributeName,
			readOnly: isReadOnly,
			showInUi: isVisible,
			required: isRequired});
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName);
		var complock = component.commercialLock;
		
		if (complock) {
			component.lock('Commercial', false);
		}
		let keys = Object.keys(updateMap);
		
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
		}
		if (complock) {
			component.lock('Commercial', true);
		}
	} catch (error) {
		console.log('[EMS_UI] updateAttributeVisiblity() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : EMSPlugin_UpdateCancellationAttributes
* Defect/US # : DPG-1914
* Invoked When: On Attribute Update
* Description : For Setting Visibility 
*********************************/
EMS_UI.updateCancellationAttributes = function(componentName, guid, changeTypeValue) {
	try {
		if (changeTypeValue === 'Cancel') {
			EMS_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, true, true);
			EMS_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, true, false);
			EMS_UI.updateAttributeVisiblity('TenancyButton', componentName, guid, false, false, false);
			EMS_UI.updateAttributeVisiblity('Space1', componentName, guid, true, false, false);
			EMS_UI.updateAttributeVisiblity('Space2', componentName, guid, true, false, false);
		}
		
		//--DPG-2647 -- Reused for Modify - START
		if (changeTypeValue === 'Modify') {
			EMS_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);
			EMS_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
			EMS_UI.updateAttributeVisiblity('TenancyButton', componentName, guid, false, true, false);
			EMS_UI.updateAttributeVisiblity('Space1', componentName, guid, true, true, false);
			EMS_UI.updateAttributeVisiblity('Space2', componentName, guid, true, false, false);
		}
		if (changeTypeValue === '') {
			EMS_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);
			EMS_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
			EMS_UI.updateAttributeVisiblity('TenancyButton', componentName, guid, true, true, false);
			EMS_UI.updateAttributeVisiblity('Space1', componentName, guid, true, true, false);
			EMS_UI.updateAttributeVisiblity('Space2', componentName, guid, true, false, false);
		} //--DPG-2647 -- Reused for Modify - END
	} catch (error) {
		console.log('[EMS_Utils] updateCancellationAttributes() exception: ' + error);
	}
};