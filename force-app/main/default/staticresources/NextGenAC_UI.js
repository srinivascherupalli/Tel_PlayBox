/*
 * Handles all UI-related logic
 */
console.log('[NextGenAC_UI] loaded');

const NGMAC_UI = {};

NGMAC_UI.solutionAfterConfigurationAdd = async function(componentName, guid) {
	try {
		if (componentName === NextGenFC_COMPONENTS.AdaptiveCare) {
			var changetypeMACsolution = 'Cancel';
			let updateMap = {};
			updateMap[guid] = [];
			updateMap[guid].push({
				name: "ChangeType",
				value: changetypeMACsolution,
				label: "ChangeType",
				showInUi: true
			}, { //EDGE-207352 Start
				name: "BillingAccountLookup",
				showInUi: false
			}); //EDGE-207352 End
			
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
		}
	} catch (error) {
		console.log('[NextGenAC_UI] solutionAfterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : UpdateCancellationAttributes
* Defect/US # : DPG-1914
* Invoked When: On Attribute Update
* Description : For Setting Visibility 
*********************************/
NGMAC_UI.updateCancellationAttributes = async function(componentName, guid, changeTypeValue) {
	try {
		if (changeTypeValue === 'Cancel' ) {
			NGMAC_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, true, true);
			NGMAC_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, true, false);
			NGMAC_UI.updateAttributeVisiblity('Space1', componentName, guid, false, false, false);
			NGMAC_UI.updateAttributeVisiblity('Space2', componentName, guid, false, false, false);
		}
		if (changeTypeValue != 'Cancel') {
			NGMAC_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
			NGMAC_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
			NGMAC_UI.updateAttributeVisiblity('Space1', componentName, guid, false, true, false);
			NGMAC_UI.updateAttributeVisiblity('Space2', componentName, guid, false, true, false);
		}
	} catch (error) {
		console.log('[NextGenAC_UI] updateCancellationAttributes() exception: ' + error);
	}
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : NGMACPlugin_updateAttributeVisiblity
* Defect/US # : DPG-1914
* Invoked When: On Attribute Update
* Description : For Setting Visibility 
*********************************/
NGMAC_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
	try {
		let updateMap = {};
		updateMap[guid] = [];
		updateMap[guid].push({
			name: attributeName,
			readOnly: isReadOnly,
			showInUi: isVisible,
			required: isRequired
		});
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName);
		var complock = component.commercialLock;
		
		if(complock) {
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
		console.log('[NextGenAC_UI] updateAttributeVisiblity() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : NGMACPlugin_UpdateMainSolutionChangeTypeVisibility
* Defect/US # : DPG-1914
* Invoked When: On Solution Load
* Description : For Setting Visibility 
*********************************/
NGMAC_UI.updateMainSolutionChangeTypeVisibility = async function(solution) {
	try {
		if (basketChangeType !== 'Change Solution') {
			return;
		}
		//Added for Cancel Story -- START
		var chtype; 
		var replacedConfig; 
		
		if (solution && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
			if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				for (const config of Object.values(solution.schema.configurations)) {
					chtype = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
					replacedConfig = config.replacedConfigId;
				}
			}
		}
		if (replacedConfig === null && replacedConfig === undefined && replacedConfig === "") {
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
				showInUi: false
			}, {
				name: 'Space2',
				showInUi: false
			}, {
				name: 'Space3',
				showInUi: false
			}];
			await NGMAC_UI.updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMAC_UI.updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await NGMAC_UI.updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
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
				showInUi: true
			}, {
				name: 'Space3',
				showInUi: false
			}];
			await NGMAC_UI.updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMAC_UI.updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await NGMAC_UI.updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			
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
			}, {
				name: 'Space3',
				showInUi: false
			}];
			await NGMAC_UI.updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMAC_UI.updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMAC_UI.updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		} //Added for Cancel Story  -- END
	} catch (error) {
		console.log('[NextGenAC_UI] updateMainSolutionChangeTypeVisibility() exception: ' + error);
	}
};

/*********************************
* Author	  : Shresth Dixit
* Method Name : handleAttributeVisibility
* Defect/US # : DPG-2395
* Invoked When: aftersolutionloaded,onsave
* Description : Control visibility of rate card on the basis of offer id
********************************/
NGMAC_UI.handleAttributeVisibility = async function(solution){ //Krunal
	try {
		var offerid = '';
		
		if (solution.componentType && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
			Object.values(solution.schema.configurations).forEach((config) => {
				if (config.attributes && Object.values(config.attributes).length > 0) {
					offerid = Object.values(config.attributes).filter(attr => {
						return attr.name === 'OfferId';
					});
				}
			});
		}
		await NGMACPlugin_updateAttributeVisiblity('ShowADPRateCard', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, offerid[0].value, false);
	} catch (error) {
		console.log('[NextGenAC_Validation] handleAttributeVisibility() exception: ' + error);
	}
	return Promise.resolve(true);
};