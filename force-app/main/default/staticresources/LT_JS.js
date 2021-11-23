console.log('Load LT_JS...');

	var COMPONENT_NAMES = {
		ipSite: 'IP Site',
		handsetAndAccessories: 'Handset and Accessories',
		huntGroup: 'Hunt Group',
		mobililty: 'Mobility',
		mobileDevice: 'Mobile Device',
		solution: 'Connected Workplace'
	};

	var COMPONENT_MAPPING = {};

	for (var mapping in COMPONENT_NAMES) {
		COMPONENT_MAPPING[COMPONENT_NAMES[mapping]] = mapping;
	}

	var descriptorCache = {};

	function readAttributeValue(configuration, attributeName, property) {
		var attribute = configuration._attributesByName[attributeName];
		if (!attribute) {
			return undefined;
		}

		property = property || 'value';

		return attribute[property];
	}

	function setAttributeValuesAsync(componentName, updateConfigMap, ignoreHooks) {
		return CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, true);
	}

	function buildComponentData(solution) {
		var decomposedComponents = {
			solution: solution,
			component: {},
			configurationsByGuid: {},
		};

		var allComponents = [solution].concat(solution.components);

		allComponents.forEach(
			function(component) {
				if (COMPONENT_MAPPING[component.name]) {
					var componentDescriptor = {
						origin: component,
						configurations: component.schema && component.schema.configurations || []
					};

					decomposedComponents.component[COMPONENT_MAPPING[component.name]] = componentDescriptor;

					componentDescriptor.configurations.forEach(
						function (config) {
							decomposedComponents.configurationsByGuid[config.guid] = config;

							config._attributesByName = config.attributes.reduce(
								function (attrsByName, attribute) {
									attrsByName[attribute.name] = attribute;
									return attrsByName;
								},
								{}
							);

							// we reset status every time
							config._status = true;
							config._statusMessage = '';
							// we track component name in config
							config._component = component.name;
						}
					);
				}
			}
		);

		return decomposedComponents;
	}

	// function buildComponentDescriptors(solution, ignoreCache) {
	// 	var descriptor = buildComponentData(solution);
	// 	console.log('Solution descriptor', descriptor);
	// 	return descriptor;
	// }

	function buildComponentCacheAsync() {
		//return CS.SM.getActiveSolution().then(buildComponentDescriptors);
		return CS.SM.getActiveSolution().then(buildComponentData);
	}

// LT, 16-04-19
/*
	function disableBandwidthClipOn(componentName, configGuid, selectedPlan, planId, planGuid) {
		var updateConfigMap = {};
		updateConfigMap[configGuid] = [
			{
				name: 'Selected Plan',
				value: selectedPlan || ''
			},
			{
				name: 'PlanId',
				value: planId || ''
			},
			{
				name: 'PlanGUID',
				value: planGuid || ''
			}
		];

		return setAttributeValuesAsync(componentName, updateConfigMap, true);
	}
*/	


// --- hooks ---
var solutionPlugin = CS.SM.createPlugin(COMPONENT_NAMES.solution);

solutionPlugin.afterSolutionLoaded = function _solutionLoaded(previousSolution, loadedSolution) {

	// var solComponents = buildComponentCacheAsync();
	// console.log('solComponents: ' + solComponents);
	
	console.log('Load LT_JS afterSolutionLoaded');

	let inputMap = {};
    let basketId = CS.SM.getCurrentBasketId().__zone_symbol__value;
    inputMap['basketId'] = basketId;



	CS.SM.WebService.performRemoteAction('SolutionGetBaskeData', inputMap).then(
        function(response) {
            console.log('Response', response);
            
            if (response && response.basket != undefined) {
	            console.log(response.basket.Id);
    	        console.log(response.basket.csordtelcoa__Basket_Stage__c);    	        

    	        if (response.basket.csordtelcoa__Basket_Stage__c != 'Commercial Configuration') {
    	        	// make attributes read only
    	        	console.log('make attributes read only');
    	        } else {
    	        	// make attribtues editable
    	        	console.log('make attribtues editable');
    	        }

            }
        })
	
}

solutionPlugin.afterConfigurationAdd = function _solutionAfterConfigurationAdd(componentName, configuration) {
	console.log('Config Added: ', componentName, configuration);

	if (componentName === 'IP Site') {
        setSiteData(componentName, configuration);      
		return autoAddUserConfigurations();
	}
	if (componentName === 'User') {
		return updateExistingTypesOnUserConfig(configuration);
	}
	if (componentName === 'Bandwidth Clip On') {
		return updateUserQtyOnBandwidthConfig(configuration);
	}

	if (componentName === 'Hunt Group') {
		console.log('componentName:' + componentName);

		// set default unit price of Hunt Group
		let inputMap = {};	    
	    inputMap['Hunt Group'] = 'cspmb__Recurring_Charge__c';
	    console.log('inputMap: ' + inputMap['Hunt Group']);

		CS.SM.WebService.performRemoteAction('SolutionGetBaskeData', inputMap).then(
        function(response) {
            console.log('Response', response);
            
            if (response && response["Hunt Group"] != undefined) {	                	        
				var updateConfigMap = {};
				updateConfigMap[configuration.guid] = [
					{
						name: 'HuntGroup',
						value: response["Hunt Group"].cspmb__Recurring_Charge__c
					}
				];
				setAttributeValuesAsync('Hunt Group', updateConfigMap, true);
            }
        })
	}

	return Promise.resolve(true);
};

solutionPlugin.afterAttributeUpdated = function _solutionAfterAttributeUpdated(componentName, guid, attributeName, oldValue, newValue) {
	console.log('Attribute Updated', componentName, guid, attributeName, oldValue, newValue);
	if (componentName === 'IP Site' && attributeName.name === 'TypeUser') {
		return updateUserAndIPSiteConfigurations(guid);
	}
	
	if (componentName === 'IP Site' && attributeName.name === 'Quantity') {
		return makeWFCodeAndIEDDeviceMandatory(guid);
	}
	
	// if (componentName === 'IP Site' && attributeName.name === 'HandsetandAccessoriesModel') {
	// 	return controlHandSetTypeAndModel(guid);
	// }

	// --- Mobility ---
	if (componentName === 'Mobility' && attributeName.name === 'Plan__c' && newValue === 'CWP Mobile Seat') {
		console.log('attributeName.value: ' + newValue);
		return addMobileDeviceConfigurations();
	}
	// ----------------
	 
	// --- Handset and Accessories ---
	if (componentName === 'IP Site' && attributeName.name === 'ContractType') {
		console.log('attributeName.value: ' + newValue);
		var updateConfigMap = {};
		if (newValue === 'Hardware Repayment') {
			updateConfigMap[guid] = [
				{
					name: 'ContractTerm',
					readOnly: false
				}
			];				
		} else {
			updateConfigMap[guid] = [
				{
					name: 'ContractTerm',
					readOnly: true
				}
			];
		}
		console.log('***' + updateConfigMap[guid]);

		//CS.SM.updateConfigurationAttribute('Internet', updateMap).then( component => console.log(component));
		CS.SM.updateConfigurationAttribute('Handset and Accessories', updateConfigMap, true);
		//setAttributeValuesAsync('Handset and Accessories', updateConfigMap, true);
	}
	// -------------------------------

	return Promise.resolve(true);
};


// --------------
