/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */ 
console.log('[DMS_Delegate] loaded');

const DMS_Plugin = {};

DMS_Plugin.execute = function(productPlugin) {
	console.log('[DMS_Delegate] productPlugin ' +productPlugin );
	window.addEventListener('message', function(e) {
		console.log('[DMS_Delegate] addEventListener("message") start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.handleIframeMessageDMS(e);
			console.log('retVal'+retVal);
		} catch (error) {
			console.log('[DMS_Delegate] addEventListener("message") exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end addEventListener("message")');
		return Promise.resolve(true);
	});
	
	productPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[DMS_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.afterSave(result);
		} catch (error) {
			console.log('[DMS_Delegate] afterSave() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterSolutionDelete = function(solution) {
		console.log('[DMS_Delegate] afterSolutionDelete() start...');
		
		try {
			CommonUtills.updateBasketStageToDraft();
		} catch (error) {
			console.log('[DMS_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end afterSolutionDelete()');
		return Promise.resolve(true);
	};
	
	//######changes started by shashank DIGI-4637
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
		console.log('[DMS_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.orderEnrichmentTabLoaded(e);
		} catch (error) {
			console.log('[DMS_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
		console.log('[DMS_Delegate] afterOrderEnrichmentConfigurationDelete() start...');
		
		try {
			window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		} catch (error) {
			console.log('[DMS_Delegate] afterOrderEnrichmentConfigurationDelete() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end afterOrderEnrichmentConfigurationDelete()');
		return Promise.resolve(true);
	}; //###### */ changed ended here by shashank DIGI-4637
	
	window.document.addEventListener('SolutionSetActive', async function(e) {
		console.log('[DMS_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = DMS_Utils.solutionSetActive();
        } catch (error) {
            console.log('[DMS_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[DMS_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolutionDMS) {
		console.log('[DMS_Delegate] afterSolutionLoaded() start...');
		
		try {
			console.log('[DMS_Delegate] ...end afterSolutionLoaded()');
			return Promise.resolve(true);
		} catch (error) {
			console.log('[DMS_Delegate] afterSolutionLoaded() exception: ' + error);
		}
	};
	
	productPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
		console.log('[DMS_Delegate] afterConfigurationAddedToMacBasket() start...',componentName);
		console.log('guid-',guid);
		var retVal;
		
		try {
            //DIGI-5568-- Mahima
			retVal = DMS_UI.solutionAfterConfigurationAdd(componentName, guid);
            //Added By vijay DIGI-456
            CommonUtills.CloneOrderEnrichment(componentName, guid); 

		} catch (error) {
			console.log('[DMS_Delegate] solutionAfterConfigurationAdd() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end solutionAfterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		console.log('[DMS_Delegate] _solutionAfterConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.solutionAfterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[DMS_Delegate] _solutionAfterConfigurationAdd() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end _solutionAfterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		console.log('[DMS_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[DMS_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[DMS_Delegate] beforeSave() start...');
		var retVal = false;
		
		try {
			retVal = DMS_Utils.beforeSave();
		} catch (error) {
			console.log('[DMS_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[DMS_Delegate] ...end beforeSave()');
		return Promise.resolve(retVal);
	};
};
 