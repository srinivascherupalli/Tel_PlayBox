/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[SecureEdge_Delegate] loaded');

const SES_Plugin = {};

SES_Plugin.execute = function(productPlugin) {
	window.document.addEventListener('SolutionSetActive', async function (e) {
		console.log('[SecureEdge_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
        
		try {
            retVal = SES_IO.solutionSetActive(e);
        } catch (error) {
            console.log('[SecureEdge_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[SecureEdge_Delegate] ...end addEventListener("SolutionSetActive")');
        return Promise.resolve(retVal);
	});
	
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		console.log('[SecureEdge_Delegate] addEventListener("OrderEnrichmentTabLoaded") start...');
		
		try {
			//Event to handle load of OE tabs
			let solution = await CS.SM.getActiveSolution();
			
			if (solution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
		} catch (error) {
            console.log('[SecureEdge_Delegate] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
        }
		console.log('[SecureEdge_Delegate] ...end addEventListener("OrderEnrichmentTabLoaded")');
			return Promise.resolve(true);
    });
	
	productPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[SecureEdge_Delegate] afterSave() start...');
        var retVal = false;
		
		try {
			retVal = SES_IO.afterSave(result);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterSave() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterSave()');
        return Promise.resolve(retVal);
	};
	
	productPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[SecureEdge_Delegate] beforeSave() start...');
		
		try {
			SES_Validation.beforeSave(solution);
            return Promise.resolve(true);
		} catch (error) {
			console.log('[SecureEdge_Delegate] beforeSave() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end beforeSave()');
	};
    
    productPlugin.afterSolutionDelete = function (solution) {
		console.log('[SecureEdge_Delegate] afterSolutionDelete() start...');
		
		try {
			//Update for changing basket stage to Draft
			CommonUtills.updateBasketStageToDraft();
			//Pricing Service changes DIGI-27353
			//refreshPricingSummeryWidget();
			return Promise.resolve(true);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterSolutionDelete() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterSolutionDelete()');
   };
    
   productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[SecureEdge_Delegate] afterAttributeUpdated() start...');
		
		try {
			SES_Utils.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterAttributeUpdated()');
	};
    
    productPlugin.beforeRelatedProductDelete = async function(component, configuration, relatedProduct) {
		console.log('[SecureEdge_Delegate] beforeRelatedProductDelete() start...');
		
		try {
			SES_Validation.beforeRelatedProductDelete(configuration, relatedProduct);
			return Promise.resolve(true);
		} catch (error) {
			console.log('[SecureEdge_Delegate] beforeRelatedProductDelete() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end beforeRelatedProductDelete()');
	};
    
   /* productPlugin.beforeRelatedProductAdd = async function(component, configuration, relatedProduct) {
		console.log('[SecureEdge_Delegate] beforeRelatedProductAdd() start...');
				
		try {
			SES_Utils.beforeRelatedProductAdd(component, configuration, relatedProduct);
		} catch (error) {
			console.log('[SecureEdge_Delegate] beforeRelatedProductAdd() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end beforeRelatedProductAdd()');
		
	}; */
    
    productPlugin.afterOrderEnrichmentConfigurationDelete = async function (component, configuration, orderEnrichmentConfiguration) {
		console.log('[SecureEdge_Delegate] afterOrderEnrichmentConfigurationDelete() start...');
		
		try {
			window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
			return Promise.resolve(true);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterOrderEnrichmentConfigurationDelete() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterOrderEnrichmentConfigurationDelete()');
	};
   
	
	productPlugin.afterRelatedProductAdd = async function(component, configuration, relatedProduct) {
		console.log('[SecureEdge_Delegate] afterRelatedProductAdd() start...');
		
		try {
			SES_Utils.afterRelatedProductAdd(relatedProduct);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterRelatedProductAdd() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterRelatedProductAdd()');
	};
	
	productPlugin.addDefaultSecureEdgeOETenancyConfigs = async function(componentName, guid) {
		console.log('[SecureEdge_Delegate] addDefaultSecureEdgeOETenancyConfigs() start...');
		
		try {
			SES_UI.addDefaultSecureEdgeOETenancyConfigs(componentName);
		} catch (error) {
			console.log('[SecureEdge_Delegate] addDefaultSecureEdgeOETenancyConfigs() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end addDefaultSecureEdgeOETenancyConfigs()');
	};
	
	productPlugin.afterConfigurationAdd = async function(component, configuration) {
		console.log('[SecureEdge_Delegate] afterConfigurationAdd() start...');
		
		try {
			SES_UI.afterConfigurationAdd(component, configuration);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterConfigurationAdd() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterConfigurationAdd()');
	};
	
	productPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) {
		console.log('[SecureEdge_Delegate] afterOrderEnrichmentConfigurationAdd() start...');
		
		try {
			//initializeVeloOETenancyConfigs();	//DN: WHERE IS THIS CONFIGURED?
			window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
			return Promise.resolve(true);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterOrderEnrichmentConfigurationAdd()');
	};
    
   productPlugin.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
		console.log('[SecureEdge_Delegate] afterConfigurationAddedToMacBasket() start...');
		
		try {
			SES_UI.afterConfigurationAddedToMacBasket(componentName);
		} catch (error) {
			console.log('[SecureEdge_Delegate] afterConfigurationAddedToMacBasket() exception: ' + error);
		}
		console.log('[SecureEdge_Delegate] ...end afterConfigurationAddedToMacBasket()');
	};
};