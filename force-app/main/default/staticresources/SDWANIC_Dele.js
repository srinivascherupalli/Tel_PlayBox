/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[SDWANIC_Dele] loaded');

const Interconnect_Plugin = {};

Interconnect_Plugin.execute = function(productPlugin) {
   window.document.addEventListener('SolutionSetActive', async function(e) {
        console.log('[SDWANIC_Dele] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
        try {
            retVal = SDWANIC_IO.solutionSetActive();
        } catch (error) {
            console.log('[SDWANIC_Dele] addEventListener("SolutionSetActive") exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
    });
    
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
        console.log('[SDWANIC_Dele] addEventListener("OrderEnrichmentTabLoaded") start...');

        try {
            let solution = await CS.SM.getActiveSolution();

            if (solution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
                var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
                window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
            }
        } catch (error) {
            console.log('[SDWANIC_Dele] addEventListener("OrderEnrichmentTabLoaded") exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end addEventListener("OrderEnrichmentTabLoaded")');
		return Promise.resolve(true);
    });
	
    productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        console.log('[SDWANIC_Dele] afterSave() start...');
		var retVal = false;
        
        try {
            retVal = SDWANIC_IO.afterSave();
        } catch (error) {
            console.log('[SDWANIC_Dele] afterSave() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterSave()');
		return Promise.resolve(true);
    };
    
     productPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        console.log('[SDWANIC_Dele] beforeSave() start...');
		var retVal = false;
		
        try {
            retVal = SDWANIC_Val.beforeSave();
			SDWANIC_UI.beforeSave();
        } catch (error) {
            console.log('[SDWANIC_Dele] beforeSave() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end beforeSave()');
        return Promise.resolve(retVal);
    };
    
     productPlugin.afterOrderEnrichmentConfigurationAdd = async function(component, configuration, orderEnrichmentConfiguration) {
        console.log('[SDWANIC_Dele] afterOrderEnrichmentConfigurationAdd() start...');

        try {
            //VC_Utils.initializeVeloOETenancyConfigs();
            console.log('Test OE for Velocloud....');
            window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        } catch (error) {
            console.log('[SDWANIC_Dele] afterOrderEnrichmentConfigurationAdd() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterOrderEnrichmentConfigurationAdd()');
		return Promise.resolve(true);
    };
    
    productPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
        console.log('[SDWANIC_Dele] afterOrderEnrichmentConfigurationDelete() start...');

        try {
            window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        } catch (error) {
            console.log('[SDWANIC_Dele] afterOrderEnrichmentConfigurationDelete() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterOrderEnrichmentConfigurationDelete()');
		return Promise.resolve(true);
    };
    
    productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
        console.log('[SDWANIC_Dele] afterAttributeUpdated() start...');
		var retVal = false;
		
        try {
            retVal = SDWANIC_UI.afterAttributeUpdated(component, configuration, attribute, oldValueMap);
        } catch (error) {
            console.log('[SDWANIC_Dele] afterAttributeUpdated() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
    }; 
    
     productPlugin.afterSolutionDelete = function(solution) {
        console.log('[SDWANIC_Dele] afterSolutionDelete() start...');

        try {
            //Aditya: Spring Update for changing basket stage to Draft
            CommonUtills.updateBasketStageToDraft();
        } catch (error) {
            console.log('[SDWANIC_Dele] afterSolutionDelete() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterSolutionDelete()');
		return Promise.resolve(true);
    };
    productPlugin.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
        console.log('[SDWANIC_Dele] afterConfigurationAddedToMacBasket() start...');
        var retVal = false;
		
        try {
            retVal = SDWANIC_UI.afterConfigurationAddedToMacBasket(componentName);
        } catch (error) {
            console.log('[SDWANIC_Dele] afterConfigurationAddedToMacBasket() exception: ' + error);
        }
        console.log('[SDWANIC_Dele] ...end afterConfigurationAddedToMacBasket()');
        return Promise.resolve(retVal);
    };
};
