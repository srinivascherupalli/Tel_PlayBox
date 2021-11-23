/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[SDWAN_Delegate] loaded');

const SDWAN_Plugin = {};

SDWAN_Plugin.execute = function(productPlugin)	{
	window.document.addEventListener('SolutionSetActive', async function(e) {
		console.log('[SDWAN_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = SDWAN_IO.solutionSetActive();
        } catch (error) {
            console.log('[SDWAN_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
		console.log('[SDWAN_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		
		try {
            let solution = await CS.SM.getActiveSolution();
			
			if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
		} catch (error) {
			console.log('[SDWAN_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
		return Promise.resolve(true);
	});
	
	productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[SDWAN_Delegate] afterSave() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_IO.afterSave(result);
		} catch (error) {
			console.log('[SDWAN_Delegate] afterSave() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterSave()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[SDWAN_Delegate] beforeSave() start...');
		
		try {
			let currentSolution = await CS.SM.getActiveSolution();
			
			if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
				currentSolution.lock("Commercial", false);
			}
		} catch (error) {
			console.log('[SDWAN_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end beforeSave()');
		return Promise.resolve(true);
    };
	
	productPlugin.afterSolutionDelete = function(solution) {
		console.log('[SDWAN_Delegate] afterSolutionDelete() start...');
		
		try {
			CommonUtills.updateBasketStageToDraft();
		} catch (error) {
			console.log('[SDWAN_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterSolutionDelete()');
		return Promise.resolve(true);
	};
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[SDWAN_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_UI.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[SDWAN_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeRelatedProductDelete = async function(component, configuration, relatedProduct) {
		console.log('[SDWAN_Delegate] beforeRelatedProductDelete() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_Validation.beforeRelatedProductDelete(configuration, relatedProduct);
		} catch (error) {
			console.log('[SDWAN_Delegate] beforeRelatedProductDelete() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end beforeRelatedProductDelete()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.beforeRelatedProductAdd = async function(component, configuration, relatedProduct) {
		console.log('[SDWAN_Delegate] beforeRelatedProductAdd() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_Validation.beforeRelatedProductAdd(configuration, relatedProduct);
		} catch (error) {
			console.log('[SDWAN_Delegate] beforeRelatedProductAdd() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end beforeRelatedProductAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
		console.log('[SDWAN_Delegate] afterOrderEnrichmentConfigurationDelete() start...');
		
		try {
			window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		} catch (error) {
			console.log('[SDWAN_Delegate] afterOrderEnrichmentConfigurationDelete() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterOrderEnrichmentConfigurationDelete()');
		return Promise.resolve(true);
	};
	
	productPlugin.afterRelatedProductAdd = async function(component, configuration, relatedProduct) {
		console.log('[SDWAN_Delegate] afterRelatedProductAdd() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_Utils.afterRelatedProductAdd(component, configuration, relatedProduct);
		} catch (error) {
			console.log('[SDWAN_Delegate] afterRelatedProductAdd() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterRelatedProductAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
		console.log('[SDWAN_Delegate] afterConfigurationAddedToMacBasket() start...');
		var retVal = false;
		
		try {
			retVal = SDWAN_UI.afterConfigurationAddedToMacBasket(componentName);
		} catch (error) {
			console.log('[SDWAN_Delegate] afterConfigurationAddedToMacBasket() exception: ' + error);
		}
		console.log('[SDWAN_Delegate] ...end afterConfigurationAddedToMacBasket()');
		return Promise.resolve(retVal);
	};
};