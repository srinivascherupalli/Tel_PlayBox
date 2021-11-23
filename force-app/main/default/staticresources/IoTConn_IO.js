/*
 * Interface methods for this product; can be referenced from any of the modules
 * 1. Vijay  DIGI-456  07/11/2021  Calling updateOEConsoleButtonVisibility_v2 method
 */
console.log('[IoTConn_IO] loaded');

const IOTCONN_IO = {};

IOTCONN_IO.solutionSetActive = async function(e) {
	try {
		//vijaya
		let loadedSolution = await CS.SM.getActiveSolution();
		window.addEventListener('message', IOTCONN_UI.IOT_handleIframeMessage);
		if (loadedSolution.componentType && loadedSolution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
			let basketId = e.detail.solution.basketId;
			let currentBasket = await CS.SM.loadBasket(basketId);           
			await CommonUtills.getBasketData(currentBasket);
			
			if (window.basketStage === "Contract Accepted") {
				loadedSolution.lock("Commercial", false);
			}
			CommonUtills.setBasketChange();
            let currentBasketIOT = await CS.SM.getActiveBasket();// Added by Vijay DIGI-456
            await Utils.updateOEConsoleButtonVisibility_v2(currentBasketIOT,'oeIOT');
            if(!window.isToggled){// Added by Vijay DIGI-456
				await IOTCONN_Utils.addDefaultIOTPlansConfigs();
            }else{
                CommonUtills.oeErrorOrderEnrichment();
            }
            // Added by Vijay DIGI-456 ||end
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
				var basket = JSON.parse(result["GetBasket"]);
				basketChangeType = basket.csordtelcoa__Change_Type__c;
				basketStage= basket.csordtelcoa__Basket_Stage__c;
				accountId = basket.csbb__Account__c;
				
				if (accountId != null) {
					CommonUtills.setAccountID(IOTCONNECTIVITY_COMPONENTS.solutionname, window.accountId);
				}
			});
            if (window.BasketChange === "Change Solution") {
                  IOTCONN_UI.UpdateMainSolutionChangeTypeVisibility(loadedSolution);
        }
			await IOTCONN_UI.updateAttributesForSharedDataPlan(loadedSolution);
			Utils.loadSMOptions();
			Utils.updateOEConsoleButtonVisibility();
			PRE_Logic.init(loadedSolution.name);
			PRE_Logic.afterSolutionLoaded();
			
			//vijaya start
			if (window.basketStage === "Contract Accepted") {
			await IOTCONN_UI.updateAttributeVisiblity(["IoT Plans"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, true, false, false);
			} //vijaya end
		}
	} catch (error) {
		console.log('[IoTConn_IO] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
}; 