/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[IoTConn_Delegate] loaded');

const IOTCONN_Plugin = {};

IOTCONN_Plugin.execute = function(productPlugin) {
	document.addEventListener('click', function (e) {
		console.log('[IoTConn_Delegate] addEventListener("click") start...');
		
		try {
            IOTCONN_UI.addEventListenerClick(e);
        } catch (error) {
            console.log('[IoTConn_Delegate] addEventListener("click") exception: ' + error);
        }
		console.log('[IoTConn_Delegate] ...end addEventListener("click")');
	}, false);
	
	window.document.addEventListener('SolutionSetActive', async function(e) {
		console.log('[IoTConn_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = IOTCONN_IO.solutionSetActive(e);
        } catch (error) {
            console.log('[IoTConn_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[IoTConn_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		console.log('[IoTConn_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		
		try {
			let solution = await CS.SM.getActiveSolution();
			
			if (solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname) || solution.name.includes(IOTCONNECTIVITY_COMPONENTS.iotPlans)) {
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
		} catch (error) {
			console.log('[IoTConn_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
		return Promise.resolve(true);
	});
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[IoTConn_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = IOTCONN_UI.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[IoTConn_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[IoTConn_Delegate] beforeSave() start...');
		
		try {
			//Added for PricingService
			PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
		} catch (error) {
			console.log('[IoTConn_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end beforeSave()');
		return Promise.resolve(true);
	};
	
	productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[IoTConn_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = IOTCONN_UI.afterSave(result);
		} catch (error) {
			console.log('[IoTConn_Delegate] afterSave() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterOrderEnrichmentConfigurationAdd = function(componentName, configuration, orderEnrichmentConfiguration) {
		console.log('[IoTConn_Delegate] afterOrderEnrichmentConfigurationAdd() start...');
		
		try {
			window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
		} catch (error) {
			console.log('[IoTConn_Delegate] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end afterOrderEnrichmentConfigurationAdd()');
		return Promise.resolve(true);
    };
	
	productPlugin.afterSolutionDelete = function(solution) {
		console.log('[IoTConn_Delegate] afterSolutionDelete() start...');
		
		try {
			CommonUtills.updateBasketStageToDraft();
			//Added for PricingService
			refreshPricingSummeryWidget();
		} catch (error) {
			console.log('[IoTConn_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end afterSolutionDelete()');
		return Promise.resolve(true);
    };
	// DIGI-31275 - Change type is not displayed for IoT Plans in MACD basket, also all the field are editable.
    productPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAddedToMacBasket(componentName, guid) {
		console.log('[IoTConn_Delegate] _solutionAfterConfigurationAddedToMacBasket() start...');
		var retVal = false;
		
		try {
			retVal = IOTCONN_UI.afterConfigurationAddedToMacBasket(componentName, guid);
		} catch (error) {
			console.log('[IoTConn_Delegate] _solutionAfterConfigurationAddedToMacBasket() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end _solutionAfterConfigurationAddedToMacBasket()');
		return Promise.resolve(retVal);
	};
    
	productPlugin.afterConfigurationDelete = function (componentName, configuration) {
		console.log('[IoTConn_Delegate] afterConfigurationDelete() start...');
		
		try {
			//Added for PricingService
			PRE_Logic.afterConfigurationDelete(componentName,configuration);
		} catch (error) {
			console.log('[IoTConn_Delegate] afterConfigurationDelete() exception: ' + error);
		}
		console.log('[IoTConn_Delegate] ...end afterConfigurationDelete()');
		return Promise.resolve(true);
	};
}; 