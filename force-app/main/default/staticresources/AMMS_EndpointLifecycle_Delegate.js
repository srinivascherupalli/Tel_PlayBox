/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[AMMS_EndpointLifecycle_Delegate] loaded');

const EndpointLifecycle_Plugin = {};

EndpointLifecycle_Plugin.execute = function(productPlugin) {
    debugger;
	window.document.addEventListener("SolutionSetActive", async function (e) {
		console.log('[AMMS_EndpointLifecycle_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;		
		try {
            retVal = AMMS_EndpointLifecycle_Utils.solutionSetActive(e);
			
        } catch (error) {
            console.log('[AMMS_EndpointLifecycle_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[AMMS_EndpointLifecycle_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = AMMS_EndpointLifecycle_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[AMMS_EndpointLifecycle_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
		console.log('[AMMS_EndpointLifecycle_Delegate] solutionAfterConfigurationAdd() start...');
		var retVal;
		
		try {
            //DIGI-5568-- Mahima
			retVal = AMMS_EndpointLifecycle_UI.solutionAfterConfigurationAdd(componentName, guid);
		} catch (error) {
			console.log('[AMMS_EndpointLifecycle_Delegate] solutionAfterConfigurationAdd() exception: ' + error);
		}
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end solutionAfterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAdd = async function(component, configuration) {
		console.log('[AMMS_EndpointLifecycle_Delegate] afterConfigurationAdd() start...');
		var retVal = false;
		
		try {
			retVal = AMMS_EndpointLifecycle_Utils.afterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[AMMS_EndpointLifecycle_Delegate] afterConfigurationAdd() exception: ' + error);
		}
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end afterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		
		try {
			//Check added for Excepted SIOs
			
			console.log('[AMMS_EndpointLifecycle_Delegate] beforeSave() start...');
		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		if(!ExpectedSIO) {
            return Promise.resolve(false);
        }
		//Shresth DPG-2395 start
			await AMMS_EndpointLifecycle_UI.updateAttributeVisiblity('LifecycleRateCard', EndpointLifecycle_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false); //Shresth DPG-2395 end
			//DIGI-5568- Mahima
            await AMMS_EndpointLifecycle_Utils.validateChangeType(solution);
        } catch (error) {
			console.log('[AMMS_EndpointLifecycle_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end beforeSave()');
		CommonUtills.lockSolution();
		return Promise.resolve(true);
	};
	
	productPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[AMMS_EndpointLifecycle_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = AMMS_EndpointLifecycle_Utils.afterSave(result);
		} catch (error) {
			console.log('[AMMS_EndpointLifecycle_Delegate] afterSave() exception: ' + error);
		}
		console.log('[AMMS_EndpointLifecycle_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
};
