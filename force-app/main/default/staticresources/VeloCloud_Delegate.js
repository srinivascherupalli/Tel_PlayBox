/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[VeloCloud_Delegate] loaded');

const VeloCloud_Plugin = {};

VeloCloud_Plugin.execute = function(productPlugin) {
	window.document.addEventListener('SolutionSetActive', async function(e) {
		console.log('[VeloCloud_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try  {
            retVal = VC_IO.solutionSetActive();
        } catch (error) {
            console.log('[VeloCloud_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[VeloCloud_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
		console.log('[VeloCloud_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		
		try {
			let solution = await CS.SM.getActiveSolution();
			
			if (solution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
			return Promise.resolve(true);
		} catch (error) {
			console.log('[VeloCloud_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
	});
	
	productPlugin.afterSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[VeloCloud_Delegate] afterSave() start...');
		
		try {
			VC_Utils.afterSave();
		} catch (error) {
			console.log('[VeloCloud_Delegate] afterSave() exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end afterSave()');
	};
	
	productPlugin.afterOrderEnrichmentConfigurationAdd = async function(component, configuration, orderEnrichmentConfiguration) {
		console.log('[VeloCloud_Delegate] afterOrderEnrichmentConfigurationAdd() start...');
		
		try {
			VC_Utils.initializeVeloOETenancyConfigs();
            console.log('Test OE for Velocloud....');
			window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
			return Promise.resolve(true);
		} catch (error) {
			console.log('[VeloCloud_Delegate] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end afterOrderEnrichmentConfigurationAdd()');
	};
	
	productPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
		console.log('[VeloCloud_Delegate] afterOrderEnrichmentConfigurationDelete() start...');
		
		try {
			window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
            return Promise.resolve(true);
		} catch (error) {
			console.log('[VeloCloud_Delegate] afterOrderEnrichmentConfigurationDelete() exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end afterOrderEnrichmentConfigurationDelete()');
	};
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[VeloCloud_Delegate] afterAttributeUpdated() start...');
		
		try {
			if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			return Promise.resolve(true);
		} catch (error) {
			console.log('[VeloCloud_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end afterAttributeUpdated()');
	};
	
	productPlugin.afterSolutionDelete = function (solution) {
		console.log('[VeloCloud_Delegate] afterSolutionDelete() start...');
		
		try {
			//Aditya: Spring Update for changing basket stage to Draft
			CommonUtills.updateBasketStageToDraft();
			return Promise.resolve(true);
		} catch (error) {
			console.log('[VeloCloud_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[VeloCloud_Delegate] ...end afterSolutionDelete()');
	};
};
