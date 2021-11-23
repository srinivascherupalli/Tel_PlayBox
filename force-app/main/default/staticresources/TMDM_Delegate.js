/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[TMDM_Delegate] loaded');

const TMDM_Plugin = {};

TMDM_Plugin.execute = function(productPlugin) {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		console.log('[TMDM_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = TMDM_Utils.solutionSetActive();
        } catch (error) {
            console.log('[TMDM_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[TMDM_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[TMDM_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = TMDM_Utils.afterSave(result);
		} catch (error) {
			console.log('[TMDM_Delegate] afterSave() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterSolutionDelete = function(solution) {
		console.log('[TMDM_Delegate] afterSolutionDelete() start...');
		
		try {
			//Aditya: Spring Update for changing basket stage to Draft
			CommonUtills.updateBasketStageToDraft();
		} catch (error) {
			console.log('[TMDM_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end afterSolutionDelete()');
		return Promise.resolve(true);
	};
	
	productPlugin.afterSolutionLoaded = async function(previousSolution, loadedSolutionTMDM) {
		console.log('[TMDM_Delegate] afterSolutionLoaded() start...');
		
		try {
			return Promise.resolve(true);
		} catch (error) {
			console.log('[TMDM_Delegate] afterSolutionLoaded() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end afterSolutionLoaded()');
	};
	
	productPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		console.log('[TMDM_Delegate] afterConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = TMDM_IO.solutionAfterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[TMDM_Delegate] afterConfigurationAdd() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end afterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[TMDM_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = TMDM_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[TMDM_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[TMDM_Delegate] beforeSave() start...');
		var retVal = false;
		
		try {
			retVal = TMDM_Utils.beforeSave();
		} catch (error) {
			console.log('[TMDM_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[TMDM_Delegate] ...end beforeSave()');
		return Promise.resolve(retVal);
	};
};