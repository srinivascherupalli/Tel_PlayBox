/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[SecureEdge_IO] loaded');

const SES_IO = {};

SES_IO.solutionSetActive = async function(e) {

	try {
		let solution = await CS.SM.getActiveSolution();
		window.addEventListener('message', SES_UI.secureEdge_handleIframeMessage);//Added By vijay
	
		if (solution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
			currentBasket = await CS.SM.getActiveBasket();
			const basketId = await CS.SM.getActiveBasketId();
            window.basketId = await CS.SM.getActiveBasketId();
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
				var basket = JSON.parse(result["GetBasket"]);
				basketChangeType = basket.csordtelcoa__Change_Type__c;
				basketStage= basket.csordtelcoa__Basket_Stage__c;
				accountId = basket.csbb__Account__c;
				window.oeSetBasketData(solution, basketStage, accountId);
				
				if (accountId != null) {
					CommonUtills.setAccountID(SecureEdge_COMPONENTS.SecureEdgeSol,accountId);
					CommonUtills.getSiteDetails(currentBasket);
				}
			});
			//SES_Utils.addDefaultSecureEdgeOETenancyConfigs();
			await Utils.updateOEConsoleButtonVisibility_v2(currentBasket, 'oeSecureEdge');
            if(!window.isToggled){//Added by vijay DIGI-456
			await SES_UI.addDefaultSecureEdgeOETenancyConfigs();
            }else{
				CommonUtills.oeErrorOrderEnrichment();
			}
            //Added by vijay DIGI-456
			await SES_UI.MACDTenancyDetails();
			
			//DPG-5646 - Sharmila - Event to hide/remove Import button
			document.addEventListener("click", function(e) {
				e = e || window.event;
				// Import button is hidden via css : refer OEStyle.css
				Utils.updateImportConfigButtonVisibility();
			}, false);
			
			//DIGI-10035 related to MACD Disconnection Orders 
            if (modbasketChangeType === 'Change Solution' && 
				opptyType.toLowerCase() === (SecureEdge_COMPONENTS.opportunityType).toLowerCase() &&
                Object.values(solution.schema.configurations)[0].replacedConfigId &&
				Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                
                await SES_UI.MACDDisconnectionDetails();

            }
		}

		//Pricing Service changes DIGI-27353
		//PRE_Logic.init(solution);
		//PRE_Logic.afterSolutionLoaded();
  
		return Promise.resolve(true);
	} catch (error) {
		console.log('[SecureEdge_IO] solutionSetActive() exception: ' + error);
	}
};


/**
* Hook executed before we save the complex product to SF. We need to resolve the promise as a
* boolean. The save will continue only if the promise resolve with true.
* Updated by : lalit
* To create case for the configuration in case the business criteria w.r.t to pricing has met
* @param {Object} complexProduct
**/
SES_IO.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {

	try {

		let solution = result.solution;
		
		if (solution == null || solution == undefined) {
			solution = await CS.SM.getActiveSolution();
		}

		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched"|| window.basketStage === "Submitted") {
			solution.lock("Commercial", false);
		}

		SES_Utils.updateSolutionName_SecureEdge(); 
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); 
		Utils.hideSubmitSolutionFromOverviewTab();
		
		if (modbasketChangeType === 'Change Solution'){
            SES_UI.UpdateSecureEdgeMACDDisConnectionDetails(solution);
            //added for DIGI-14132
            let secureEdgeCloudComp = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloud);
            SES_UI.UpdateChildMACDDisconnectionDetails(secureEdgeCloudComp.getConfigurations());
        }

		//Pricing Service changes DIGI-27353
        //PRE_Logic.afterSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);

		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched"|| window.basketStage === "Submitted") {
			solution.lock("Commercial", true);
		}
	} catch (error) {
		console.log('[SecureEdge_IO] ?() exception: ' + error);
	}
};
 