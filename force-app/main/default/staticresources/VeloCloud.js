/******************************************************************************************
 * Author	   : DPG Oxygen
 Change Version History
Version No	Author 			Date        Change Description 
1 			Suyash Chiplunkar		 	18-Sept-20	Initial file  - DPG-2432
 ********************/
var communitySiteIdVelo;
var VELOCLOUD_COMPONENTS = {

	VeloCloudSol: 'VeloCloud Tenancy', 
	VeloCloudTenancy: 'VeloCloud Tenancy',
};
var executeSaveVeloCloud = false;
var saveVeloCloud = false;
var DEFAULTSOLUTIONNAME_VELO = 'VeloCloud Tenancy';  
var DEFAULTOFFERNAME_VELO = 'VeloCloud Tenancy'; 
var saveVeloTenancy = false; 

if(!CS || !CS.SM){
    throw Error('Solution Console Api not loaded?');
}

if (CS.SM.registerPlugin) { 
    console.log('Loaded Telstra Collaboration Tenancy Plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () { 
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('VeloCloud Tenancy') 
            .then(async VeloCloudPlugin => { 
                updateVeloCloudPlugin(VeloCloudPlugin); 
            }); 
    }); 
}

function updateVeloCloudPlugin(VeloCloudPlugin) {
    console.log('inside hooks',VeloCloudPlugin);
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        if(solution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)){
            console.log('SolutionSetActive',e);
            currentBasket = await CS.SM.getActiveBasket();
            const basketId = await CS.SM.getActiveBasketId();
            let inputMap = {};
            inputMap['GetBasket'] = basketId;
            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                console.log('GetBasket finished with response: ', result);
                var basket = JSON.parse(result["GetBasket"]);
                console.log('GetBasket: ', basket);
                basketChangeType = basket.csordtelcoa__Change_Type__c;
                basketStage= basket.csordtelcoa__Basket_Stage__c;
                accountId = basket.csbb__Account__c;
                console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId)
                window.oeSetBasketData(solution, basketStage, accountId);
                if(accountId!=null){
                    CommonUtills.setAccountID(VELOCLOUD_COMPONENTS.VeloCloudSol,accountId);
                }
            });
            addDefaultVeloOETenancyConfigs();
        }
        return Promise.resolve(true);
    });

     //Event to handle load of OE tabs
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        if(solution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)){
            console.log('OrderEnrichmentTabLoaded', e);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });


    /**
        * Hook executed before we save the complex product to SF. We need to resolve the promise as a
        * boolean. The save will continue only if the promise resolve with true.
        * Updated by : Venkata Ramanan G
        * To create case for the configuration in case the business criteria w.r.t to pricing has met
        * @param {Object} complexProduct
        */
       VeloCloudPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
            updateSolutionName_Velo(); 
            await Utils.updateActiveSolutionTotals();
            CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
            Utils.hideSubmitSolutionFromOverviewTab();
                
       }
    
    /**
        * Hook executed after the Order Enrichment configuration is added via the UI add configuration button
        *
        * @param {string} component - Component object where the configuration resides
        * @param {Object} configuration - Main configuration object for which OE configuration is  created
        * @param {Object} orderEnrichmentConfiguration - Order Enrichment Configuration which is inserted
        */
       VeloCloudPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) { 
           initializeVeloOETenancyConfigs();
            window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
            return Promise.resolve(true);
    }
    
    /**
        * Hook executed after the Order Enrichment configuration is deleted via the UI delete configuration button
        *
        * @param {string} component - Component object where the configuration resides
        * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
        * @param {Object} orderEnrichmentConfiguration - Order Enrichment object which is deleted
        */
       VeloCloudPlugin.afterOrderEnrichmentConfigurationDelete = async function (component, configuration, orderEnrichmentConfiguration) {
            window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
            return Promise.resolve(true);
        };

    /**
        * Provides the user with an opportunity to do something once the attribute is updated.
        *
        * @param {string} component - Component object where the configuration resides
        * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
        * @param {object} attribute - The attribute which is being updated.
        * @param {string} oldValueMap - Before change value.
        */
       VeloCloudPlugin.afterAttributeUpdated = async function(component,configuration,attribute,oldValueMap){
            console.log('Attribute Update - After', component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            }
            return Promise.resolve(true);
       }
                
       //Aditya: Spring Update for changing basket stage to Draft
       VeloCloudPlugin.afterSolutionDelete = function (solution) {
       		CommonUtills.updateBasketStageToDraft();
       		return Promise.resolve(true);
       }
}
/**********************************************************************************************************************************************
 * Author	   : Suyash
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if there is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
async function addDefaultVeloOETenancyConfigs(){
    if (basketStage !== 'Contract Accepted')
        return;
    console.log('addDefaultOEConfigs');
    var oeMap = [];
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultOEConfigs ',  currentSolution.name,  VELOCLOUD_COMPONENTS.VeloCloudSol);
    if (currentSolution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        let configs = currentSolution.getConfigurations();
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            Object.values(currentSolution.components).forEach((comp) => {
                Object.values(comp.schema.configurations).forEach((config) => {
                    Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                        if (oeSchema) {
                            var found = false;
                            if (config.orderEnrichmentList) {
                                var oeConfig = config.orderEnrichmentList.filter(oe => {return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId )});
                                if (oeConfig && oeConfig.length > 0)
                                    found = true;
                            }
                            if (!found) {
                                var el = {};
                                el.componentName = comp.name;
                                el.configGuid = config.guid;
                                el.oeSchema = oeSchema;
                                oeMap.push(el);
                                console.log('Adding default oe config for:',comp.name,config.name, oeSchema.name );
                            }
                        }
                    });
                });
            });
        }
    }
    if (oeMap.length> 0) {
        console.log('Adding default oe config map:',oeMap);
        for (var i=0; i< oeMap.length;i++) {
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            component.addOrderEnrichmentConfiguration( oeMap[i].configGuid , orderEnrichmentConfiguration, false);
        }
    }
    await initializeVeloOETenancyConfigs();
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Suyash
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
async function initializeVeloOETenancyConfigs(){
    console.log('initializeOEConfigs');
    let currentSolution = await CS.SM.getActiveSolution();
    let configurationGuid = '';
    if (currentSolution) {
        console.log('initializeVeloOEConfigs - updating');
        if (currentSolution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                for(const comp of Object.values(currentSolution.components)){
                    for(const config of Object.values(comp.schema.configurations)){
                        configurationGuid = config.guid;
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for(const oe of config.orderEnrichmentList){
                                var basketAttribute = Object.values(oe.attributes).filter(a => {
                                    return a.name.toLowerCase() === 'basketid'
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    if (!updateMap[oe.guid])
                                        updateMap[oe.guid] = [];
                                    updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                console.log('initializeOEConfigs updateMap:', updateMap);
                                for(var i=0; i< updateMap.length;i++){
                                    comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid,keys[i],updateMap[keys[i]],true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}

/* 	 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_Velo() {
	var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
    attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,VELOCLOUD_COMPONENTS.VeloCloudSol);
    let solution = await CS.SM.getActiveSolution();
    let component = solution.getComponentByName(VELOCLOUD_COMPONENTS.VeloCloudSol)
    let guid ;
	console.log('attrValuesMap...'+attrValuesMap);
	if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_VELO){
		let updateConfigMap = {};
        guid = attrValuesMap['GUID'];
        updateConfigMap[guid] = [];
        updateConfigMap[guid].push({
            name: 'Solution Name',
            value: DEFAULTOFFERNAME_VELO,
			displayValue: DEFAULTOFFERNAME_VELO
        });
        if(updateConfigMap){	
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
				keys = Object.keys(updateConfigMap);
				for (let i = 0; i < keys.length; i++) {
                    //await solution.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    component.lock('Commercial',false);
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
			}
		}
    }
    return Promise.resolve(true);		
}