/******************************************************************************************
Sr.No.		Author 			    Date			Sprint   		Story Number	Description
1.			Payel Ganguly		    01-Jan-2021					
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/

var IOTACCOUNTSUPPORT_COMPONENTS = {
	solutionname: "IoT Account Support",
	accountConnectivitySupport: "Account Connectivity Support",
	
};

if(!CS || !CS.SM){
    throw Error('Solution Console Api not loaded?');
}

if (CS.SM.registerPlugin) { 
	window.document.addEventListener("SolutionConsoleReady", async function () {
		await CS.SM.registerPlugin(IOTACCOUNTSUPPORT_COMPONENTS.solutionname).then(async (IOTAccountPlugin) => {
                console.log("Plugin registered for IoT Account Support"); 
                IOTAccountPlugin_updatePlugin(IOTAccountPlugin); 
            }); 
    }); 

} 
IOTAccountPlugin_updatePlugin = async (IOTAccountPlugin) => {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		try {
			console.log("Inside IOTAccountPlugin SolutionSetActive--->");
			let loadedSolution = await CS.SM.getActiveSolution();
			if (loadedSolution.componentType && loadedSolution.name.includes(IOTACCOUNTSUPPORT_COMPONENTS.solutionname)) {
				let basketId = e.detail.solution.basketId;
				let currentBasket = await CS.SM.loadBasket(basketId);

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
						CommonUtills.setAccountID(IOTACCOUNTSUPPORT_COMPONENTS.solutionname, window.accountId);
					}
				});

			Utils.loadSMOptions();		
			PRE_Logic.init(loadedSolution.name);
			PRE_Logic.afterSolutionLoaded();
		}
		return Promise.resolve(true);

		} catch (error) {
			console.log("ERROR ", error);
        }
        return Promise.resolve(true);
    });

IOTAccountPlugin.afterAttributeUpdated = async (component, configuration, attribute, oldValueMap) => {
	let loadedSolution = await CS.SM.getActiveSolution();
	let solnName = loadedSolution.solutionName;
	/*let originalSolutionName = solnName.indexOf("_") != -1 ? solnName.substring(0, solnName.indexOf("_")) : solnName;
	if (attribute.value) {
			CommonUtills.genericUpdateSolutionName(component, configuration, originalSolutionName + "_" + attribute.displayValue, originalSolutionName + "_" + attribute.displayValue);
		}*/
	//Added for PricingService
	PRE_Logic.afterAttributeUpdated(component, configuration, attribute, oldValueMap.value, attribute.value);
	
	return Promise.resolve(true); // Need to discuss with cloudsense
};

//Added for PricingService
IOTAccountPlugin.beforeSave = function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {

	PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
	return Promise.resolve(true);
};

IOTAccountPlugin.afterSave = async (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) => {
	Utils.updateCustomButtonVisibilityForBasketStage();
	await Utils.updateActiveSolutionTotals();
    CommonUtills.updateBasketDetails();
	//Added for PricingService
    await updatePREDiscountAttribute();
    return Promise.resolve(true);
};

IOTAccountPlugin.updateAttributeVisiblity = async (attributeName, componentName, guid, isReadOnly, isVisible, isRequired) => {
        let updateMap = {};
        updateMap[guid] = [];
        attributeName.forEach((attribute) => {
            updateMap[guid].push({
                name: attribute,
                readOnly: isReadOnly,
                showInUi: isVisible,
                required: isRequired
            });
        });

        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(componentName);

        if (component) {
            let complock = component.commercialLock;
            if (complock) component.lock("Commercial", false);
            await component.updateConfigurationAttribute(guid, updateMap[guid], true);
            if (complock) component.lock("Commercial", true);
        }

    };

IOTAccountPlugin.afterSolutionDelete = (solution) => {
        CommonUtills.updateBasketStageToDraft();
        //Added for PricingService
        refreshPricingSummeryWidget();
        return Promise.resolve(true);
    };

//Added for PricingService
    IOTAccountPlugin.afterConfigurationDelete = function (componentName, configuration) {

        PRE_Logic.afterConfigurationDelete(componentName,configuration);
        return Promise.resolve(true);
    };

};

