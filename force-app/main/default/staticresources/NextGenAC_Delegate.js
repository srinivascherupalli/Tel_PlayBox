/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[NextGenAC_Delegate] loaded');

const NGMAC_Plugin = {};

NGMAC_Plugin.execute = function(productPlugin) {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		console.log('[NextGenAC_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = NGMAC_Utils.solutionSetActive(e);
        } catch (error) {
            console.log('[NextGenAC_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[NextGenAC_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[NextGenAC_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = NGMAC_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[NextGenAC_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[NextGenAC_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
		console.log('[NextGenAC_Delegate] solutionAfterConfigurationAdd() start...');
		var retVal;
		
		try {
			retVal = NGMAC_UI.solutionAfterConfigurationAdd(componentName, guid);
		} catch (error) {
			console.log('[NextGenAC_Delegate] solutionAfterConfigurationAdd() exception: ' + error);
		}
		console.log('[NextGenAC_Delegate] ...end solutionAfterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAdd = async function(component, configuration) {
		console.log('[NextGenAC_Delegate] afterConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = NGMAC_Utils.afterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[NextGenAC_Delegate] afterConfigurationAdd() exception: ' + error);
		}
		console.log('[NextGenAC_Delegate] ...end afterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function (solution) {
		console.log('[NextGenAC_Delegate] beforeSave() start...');
		
		try {
			//Shresth DPG-2395 start
			CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
			await NGMAC_UI.updateAttributeVisiblity('ShowADPRateCard', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false); //Shresth DPG-2395 end
		} catch (error) {
			console.log('[NextGenAC_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[NextGenAC_Delegate] ...end beforeSave()');
		return Promise.resolve(true);
	};
	
	productPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[NextGenAC_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = NGMAC_Utils.afterSave(result);
		} catch (error) {
			console.log('[NextGenAC_Delegate] afterSave() exception: ' + error);
		}
		console.log('[NextGenAC_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
};