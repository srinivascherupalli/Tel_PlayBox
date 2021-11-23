/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[PSMDM_Delegate] loaded');

const PSMDM_Plugin = {};

PSMDM_Plugin.execute = function(productPlugin) {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		console.log('[PSMDM_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = PSMDM_IO.solutionSetActive(e);
        } catch (error) {
            console.log('[PSMDM_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[PSMDM_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		console.log('[PSMDM_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		
		try {
			//Purushottam Added
			let loadedSolution = await CS.SM.getActiveSolution();
			
			if (loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
		} catch (error) {
			console.log('[PSMDM_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
		return Promise.resolve(true);
	});
	
	productPlugin.afterOrderEnrichmentConfigurationAdd = function(componentName, configuration, orderEnrichmentConfiguration) {
		console.log('[PSMDM_Delegate] afterOrderEnrichmentConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = PSMDM_Utils.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
		} catch (error) {
			console.log('[PSMDM_Delegate] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end afterOrderEnrichmentConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[PSMDM_Delegate] beforeSave() start...');
		
		try {
			CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		} catch (error) {
			console.log('[PSMDM_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end beforeSave()');
        return Promise.resolve(true);	
    };
	
	productPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[PSMDM_Delegate] afterSave() start...');
		var retVal = true;
		
		try {
			retVal = PSMDM_UI.afterSave(result);
		} catch (error) {
			console.log('[PSMDM_Delegate] afterSave() exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterSolutionDelete = function (solution) {
		console.log('[PSMDM_Delegate] afterSolutionDelete() start...');
		
		try {
			//Aditya: Spring Update for changing basket stage to Draft
			CommonUtills.updateBasketStageToDraft();
		} catch (error) {
			console.log('[PSMDM_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end afterSolutionDelete()');
		return true;
	};
	
	productPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {
		console.log('[PSMDM_Delegate] solutionAfterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = PSMDM_Utils.solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[PSMDM_Delegate] solutionAfterAttributeUpdated() exception: ' + error);
		}
		console.log('[PSMDM_Delegate] ...end solutionAfterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
};