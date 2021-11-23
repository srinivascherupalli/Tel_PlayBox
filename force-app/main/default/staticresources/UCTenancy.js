/******************************************************************************************
 * Author	   : CloudSense Team
 Change Version History
Version No	Author 			Date        Change Description 
1 			Venkat		 	18-Sept-19	Initial file  - EDGE 108257,EDGE 114158, EDGE 107435
2 			Aman Soni		19-May-2020		EDGE-148455 - To capture Billing Account
3           Gnana           10-Jun-2020     EDGE-149887 - Solution Name Update Logic 
4           Sandip          19-Jun-2020 	Modified as per SM Summer20 version
5 			Gnana & Aditya  19-Jul-2020		Spring'20 Upgrade
 ********************/
var communitySiteIdUC;
var NEXTGENUCTENANCY_COMPONENTS = {

	UCTenancySol: 'Telstra Collaboration Tenancy', //'Unified Communication Tenancy'//Telstra Collaboration Tenancy',
	UCTenancy: 'Tenancy_BroadsoftTenancy',
};
var executeSaveNgUCtenancy = false;
var saveNgUCtenancy = false;
var DEFAULTSOLUTIONNAME_UCT = 'Telstra Collaboration Tenancy';  // Added as part of EDGE-149887
var DEFAULTOFFERNAME_UCT = 'Unified Communication Tenancy'; //Added as part of EDGE-149887
var saveUCtenancy = false; //Added as part of EDGE-149887

if(!CS || !CS.SM){
    throw Error('Solution Console Api not loaded?');
}

if (CS.SM.registerPlugin) { 
    console.log('Loaded Telstra Collaboration Tenancy Plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () { 
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('Telstra Collaboration Tenancy') 
            .then(async UCTenancyPlugin => { 
                updateUCTenancyPlugin(UCTenancyPlugin); 
            }); 
    }); 
}

function updateUCTenancyPlugin(UCTenancyPlugin) {
    console.log('inside hooks',UCTenancyPlugin);
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        if(solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)){
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
                //Added by Aman Soni as a part of EDGE -148455 || Start
                if(accountId!=null && basketStage !== 'Contract Accepted'){
                    CommonUtills.setAccountID(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol,accountId);
                }
                //Added by Aman Soni as a part of EDGE -148455 || End
            });
            addDefaultUCOETenancyConfigs();
        }
        return Promise.resolve(true);
    });

     //Event to handle load of OE tabs
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        if(solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)){
            console.log('OrderEnrichmentTabLoaded', e);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });
    /*Added by Aman Soni
    UCTenancyPlugin.beforeSave =  function (solution, configurationsProcessed, saveOnlyAttachment) {
        updateSolutionName(); // Added as part of EDGE-149887
        if(saveUCtenancy){
            saveUCtenancy = false;
        console.log('beforeSave - exiting true');
        return Promise.resolve(true);
        }
        return Promise.resolve(false);
    }*/

    /**
        * Hook executed before we save the complex product to SF. We need to resolve the promise as a
        * boolean. The save will continue only if the promise resolve with true.
        * Updated by : Venkata Ramanan G
        * To create case for the configuration in case the business criteria w.r.t to pricing has met
        * @param {Object} complexProduct
        */
       UCTenancyPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
            updateSolutionName_UCT(); // Added as part of EDGE-149887
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
       UCTenancyPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) { 
            initializeUCOETenancyConfigs();
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
       UCTenancyPlugin.afterOrderEnrichmentConfigurationDelete = async function (component, configuration, orderEnrichmentConfiguration) {
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
       UCTenancyPlugin.afterAttributeUpdated = async function(component,configuration,attribute,oldValueMap){
            console.log('Attribute Update - After', component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            }
            return Promise.resolve(true);
       }
                
       //Aditya: Spring Update for changing basket stage to Draft
       UCTenancyPlugin.afterSolutionDelete = function (solution) {
       		CommonUtills.updateBasketStageToDraft();
       		return Promise.resolve(true);
       }

}
/*
if (CS.SM.createPlugin) {
	console.log('Load UCTenancy plugin');

	UCTenancyPlugin = CS.SM.createPlugin('Telstra Collaboration Tenancy');//Unified Communication Tenancy
	
    setInterval(saveSolutionNgUCTenancy,500);
} 
async function saveSolutionNgUCTenancy(){
        //All before save validations will be done here
            return Promise.resolve(true);
}*/
/*
//EDGE-135267
UCTenancyPlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
		Utils.hideSubmitSolutionFromOverviewTab();
}
//

UCTenancyPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {
        window.currentSolutionName = loadedSolution.name;
    await CS.SM.getCurrentCart().then(cart => {
        console.log('Basket: ', cart);
        basketId = cart.id;
    });
    let inputMap = {};
    inputMap['GetBasket'] = basketId;
    await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
        console.log('GetBasket finished with response: ', result);
        var basket = JSON.parse(result["GetBasket"]);
        console.log('GetBasket: ', basket);
        basketChangeType = basket.csordtelcoa__Change_Type__c;
        basketStage= basket.csordtelcoa__Basket_Stage__c;
        accountId = basket.csbb__Account__c;
        console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId)
        window.oeSetBasketData(basketId, basketStage, accountId);
	});
	/*let map = {};
    map['GetSiteId'] = '';
    CS.SM.WebService.performRemoteAction('SolutionActionHelper', map).then(result => {
        console.log('GetSiteId finished with response: ', result);
        communitySiteIdUC = result["GetSiteId"]
        console.log('communitySiteId: ', communitySiteIdUC);
    });

addDefaultUCOETenancyConfigs();
    return Promise.resolve(true);
}*/
/*
UCTenancyPlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
    console.log('afterOETabLoaded: ', configurationGuid, OETabName);
    var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
    window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
    return Promise.resolve(true);
}
UCTenancyPlugin.afterOrderEnrichmentConfigurationAdd = function(componentName, configuration, orderEnrichmentConfiguration){
    console.log('UCE afterOrderEnrichmentConfigurationAdd', componentName, configuration, orderEnrichmentConfiguration)
    initializeUCOETenancyConfigs();
    window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
    return Promise.resolve(true);
};
UCTenancyPlugin.afterOrderEnrichmentConfigurationDelete = function(componentName, configuration, orderEnrichmentConfiguration){
    window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
    return Promise.resolve(true);
};
UCTenancyPlugin.afterRelatedProductAdd = function _solutionafterRelatedProductAdd(componentName, configuration, relatedProduct) {
};
UCTenancyPlugin.beforeRelatedProductAdd = function _solutionafterRelatedProductAdd(componentName, configuration, relatedProduct) {
    var resolver =true;
    //Calling function disableaddingmultipleUser to restrict users from adding second User to a Broadsoft Product Enterprise.
    return Promise.resolve(resolver);
};
UCTenancyPlugin.buttonClickHandler = async function (buttonSettings) {
    console.log('buttonClickHandler: id=', buttonSettings.id, buttonSettings);
       return Promise.resolve(true);
}
UCTenancyPlugin.afterAttributeUpdated = function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {
    console.log('Attribute Update - After', componentName, guid, attribute, oldValue, newValue);
	if (componentName === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
	window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
    }
    /*
    if (componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD') {
		updateNotBeforeCRDOnUC(guid, newValue);
	}
    if (componentName === 'Customer requested Dates' && attribute.name === 'Preferred CRD') {
		updatePreferredCRDOnUC(guid, newValue);
	}
    window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
    
    return Promise.resolve(true);
}*/
/**********************************************************************************************************************************************
 * Author	   : Venkat
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if tehere is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
async function addDefaultUCOETenancyConfigs(){
    if (basketStage !== 'Contract Accepted')
        return;
    console.log('addDefaultOEConfigs');
    var oeMap = [];
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultOEConfigs ',  currentSolution.name,  NEXTGENUCTENANCY_COMPONENTS.UCTenancySol);
    if (currentSolution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
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
    await initializeUCOETenancyConfigs();
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Vebkat
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
async function initializeUCOETenancyConfigs(){
    console.log('initializeOEConfigs');
    let currentSolution = await CS.SM.getActiveSolution();
    let configurationGuid = '';
    if (currentSolution) {
        console.log('initializeUCOEConfigs - updating');
        if (currentSolution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
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
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_UCT() {
	var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
    attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,NEXTGENUCTENANCY_COMPONENTS.UCTenancySol);
    let solution = await CS.SM.getActiveSolution();
    let component = solution.getComponentByName(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)
    let guid ;
	console.log('attrValuesMap...'+attrValuesMap);
	if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_UCT){
		let updateConfigMap = {};
		/*updateConfigMap[attrValuesMap['GUID']] = [{
			name: 'Solution Name',
			value: {
				value: DEFAULTOFFERNAME_UCT,
				displayValue: DEFAULTOFFERNAME_UCT
			}													
			
        }];*/
        guid = attrValuesMap['GUID'];
        updateConfigMap[guid] = [];
        updateConfigMap[guid].push({
            name: 'Solution Name',
            value: DEFAULTOFFERNAME_UCT,
			displayValue: DEFAULTOFFERNAME_UCT
        });
        if(updateConfigMap){
            //CS.SM.updateConfigurationAttribute(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol, updateConfigMap, true);	
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
				keys = Object.keys(updateConfigMap);
                var complock = component.commercialLock;
                if (complock)
                            component.lock('Commercial', false);

				for (let i = 0; i < keys.length; i++) {
                    //await solution.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    component.lock('Commercial',false);
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
                        if (complock) {
                            component.lock('Commercial', true);
                        }
			}
		}
    }
    return Promise.resolve(true);		
}