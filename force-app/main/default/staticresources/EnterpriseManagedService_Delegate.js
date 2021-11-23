/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[EnterpriseManagedService_Delegate] loaded');

const EMS_Plugin = {};

EMS_Plugin.execute = function(productPlugin) {
	window.document.addEventListener("SolutionSetActive", async function(e) {
		console.log('[EnterpriseManagedService_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
        try {
            retVal = EMS_Utils.solutionSetActive();
        } catch (error) {
            console.log('[EnterpriseManagedService_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[EnterpriseManagedService_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
    });
	
	productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[EnterpriseManagedService_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = EMS_UI.afterSave(result);
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] afterSave() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[EnterpriseManagedService_Delegate] beforeSave() start...');
		var retVal = false;
		
		try {
			retVal = EMS_Validation.beforeSave(solution);
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end beforeSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[EnterpriseManagedService_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = EMS_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		console.log('[EnterpriseManagedService_Delegate] afterConfigurationAdd._solutionAfterConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = EMS_Utils.solutionAfterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] afterConfigurationAdd._solutionAfterConfigurationAdd() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end afterConfigurationAdd._solutionAfterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAddedToMacBasket(componentName, guid) {
		console.log('[EnterpriseManagedService_Delegate] _solutionAfterConfigurationAddedToMacBasket() start...');
		var retVal = false;
		
		try {
			retVal = EMS_UI.afterConfigurationAddedToMacBasket(componentName, guid);
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] _solutionAfterConfigurationAddedToMacBasket() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end _solutionAfterConfigurationAddedToMacBasket()');
		return Promise.resolve(retVal);
	};
	
    productPlugin.afterSolutionDelete = function(solution) {
		console.log('[EnterpriseManagedService_Delegate] afterSolutionDelete() start...');
		
		try {
			//Aditya: Spring Update for changing basket stage to Draft
			CommonUtills.updateBasketStageToDraft();
		} catch (error) {
			console.log('[EnterpriseManagedService_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[EnterpriseManagedService_Delegate] ...end afterSolutionDelete()');
		return Promise.resolve(true);
    };
};