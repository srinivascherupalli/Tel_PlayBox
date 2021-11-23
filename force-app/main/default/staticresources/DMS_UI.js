/*
 * Handles all UI-related logic
 */
console.log('[DMS_UI] loaded');

const DMS_UI = {}; 
 
DMS_UI.solutionAfterConfigurationAdd = async function(componentName, guid) {
	try {
		//console.log('dmslogs solutionAfterConfigurationAdd -componentName',componentName);
		if (componentName === DMS_COMPONENT_NAMES.tenancy) {
			var changetypeMACsolution = 'Cancel';
			let updateMap = {};
			updateMap[guid] = [];
			updateMap[guid].push({
				name: "ChangeType",
				value: "Active",
				label: "ChangeType",
				showInUi: true
			}, { 
				name: "BillingAccountLookup",
				showInUi: false
			}); 
			
			let activeSolution = await CS.SM.getActiveSolution();
			//console.log('activeSolution-'+activeSolution);
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
		console.log('[DMS_UI] solutionAfterConfigurationAdd() exception: ' + error);
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
DMS_UI.updateCancellationAttributes = async function(componentName, guid, changeTypeValue) {
	try {
		if (changeTypeValue === 'Cancel' ) {
			DMS_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, true, true);
			DMS_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, true, true);
			DMS_UI.updateAttributeVisiblity('Space1', componentName, guid, false, false, false);
			DMS_UI.updateAttributeVisiblity('Space2', componentName, guid, false, false, false);
		}
		if (changeTypeValue != 'Cancel') {
			DMS_UI.updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
			DMS_UI.updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
			DMS_UI.updateAttributeVisiblity('Space1', componentName, guid, false, true, false);
			DMS_UI.updateAttributeVisiblity('Space2', componentName, guid, false, true, false);
		}
	} catch (error) {
		console.log('[DMS_UI] updateCancellationAttributes() exception: ' + error);
	}
};

/*********************************
* Author	  : shashank
* Method Name : updateAttributeVisiblity
* Defect/US # :DIGI-22593
* Invoked When: On Attribute Update
* Description : For Setting Visibility 
*********************************/
DMS_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
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
		console.log('[DMS_UI] updateAttributeVisiblity() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : shashank
* Method Name : updateMainSolutionChangeTypeVisibility
* Defect/US # : DIGI-22593
* Invoked When: On Solution Load
* Description : For Setting Visibility 
*********************************/
DMS_UI.updateMainSolutionChangeTypeVisibility = async function(solution) {
	try {
		if (basketChangeType !== 'Change Solution') {
			return;
		}
		//Added for Cancel Story -- START
		var chtype; 
		var replacedConfig; 
		let compDMS = solution.getComponentBySchemaName(DMS_COMPONENT_NAMES.tenancy);
		
		if (solution && compDMS && compDMS.name.includes(DMS_COMPONENT_NAMES.tenancy)) {
			
			if (compDMS.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				for (const config of Object.values(compDMS.schema.configurations)) {
					
					chtype = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					}); 
					replacedConfig = config.replacedConfigId;
					console.log('replacedConfig'+replacedConfig);
				}
			}
		}
		
		if (replacedConfig === null && replacedConfig === undefined && replacedConfig === "") {
			let updateMap = {};
			updateMap[Object.values(compDMS.schema.configurations)[0].guid] = [{
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
			await DMS_UI.updateAttributeVisiblity('ChangeType',DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, true, true);
			await DMS_UI.updateAttributeVisiblity('CancellationReason', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, false, false);
			await DMS_UI.updateAttributeVisiblity('DisconnectionDate', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if ((chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New') && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")) {
			let updateMap = {};
			updateMap[Object.values(compDMS.schema.configurations)[0].guid] = [{
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
			await DMS_UI.updateAttributeVisiblity('ChangeType',DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, true, true);
			await DMS_UI.updateAttributeVisiblity('CancellationReason', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, false, false);
			await DMS_UI.updateAttributeVisiblity('DisconnectionDate', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, false, false);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		if (chtype[0].value === 'Cancel') {
			let updateMap = {};
			updateMap[Object.values(compDMS.schema.configurations)[0].guid] = [{
				name: 'ChangeType',
				showInUi: true
			}, {
				name: 'CancellationReason',
				showInUi: true
			}, {
				name: 'DisconnectionDate',
				showInUi: true
			}
			
			];
			await DMS_UI.updateAttributeVisiblity('ChangeType',DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, true, true);
			await DMS_UI.updateAttributeVisiblity('CancellationReason', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, true, true);
			await DMS_UI.updateAttributeVisiblity('DisconnectionDate', DMS_COMPONENT_NAMES.tenancy, Object.values(compDMS.schema.configurations)[0].guid, false, true, true);
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
			
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				
				for (let i = 0; i < keys.length; i++) {
					const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		} //Added for Cancel Story  -- END
	} catch (error) {
		console.log('[DMS_UI] updateMainSolutionChangeTypeVisibility() exception: ' , error);
	}
};

/*********************************
* Author	  : shashank
* Method Name : handleAttributeVisibility
* Defect/US # : DIGI-22593
* Invoked When: aftersolutionloaded,onsave
* Description : Control visibility of rate card on the basis of offer id
********************************/
DMS_UI.handleAttributeVisibility = async function(solution){ //Krunal
	try {
		var offerid = '';
		if (solution.componentType && solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
			Object.values(solution.schema.configurations).forEach((config) => {
				if (config.attributes && Object.values(config.attributes).length > 0) {
					offerid = Object.values(config.attributes).filter(attr => {
						return attr.name === 'OfferId';
					});
				}
			});
		}
		await DMS_UI.updateAttributeVisiblity('LifecycleRateCard', DMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, offerid[0].value, false);
	} catch (error) {
		console.log('[DMS] handleAttributeVisibility() exception: ' + error);
	}
	return Promise.resolve(true);
};
