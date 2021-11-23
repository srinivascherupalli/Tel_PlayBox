/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[SDWAN_IO] loaded');

const SDWAN_IO = {};

SDWAN_IO.solutionSetActive = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
		window.addEventListener('message', SDWAN_UI.SDWAN_handleIframeMessage); //added by vijay
		if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
			currentBasket = await CS.SM.getActiveBasket();
			const basketId = await CS.SM.getActiveBasketId();
            window.basketId = await CS.SM.getActiveBasketId();
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
				var basket = JSON.parse(result["GetBasket"]);
				basketChangeType = basket.csordtelcoa__Change_Type__c;
				basketStage = basket.csordtelcoa__Basket_Stage__c;
				accountId = basket.csbb__Account__c;
				opptyType = basket.Opportunity_Type__c; //DPG-5387
				modbasketChangeType = basketChangeType;
				window.oeSetBasketData(solution, basketStage, accountId);
				
				if (accountId != null) {
					CommonUtills.setAccountID(SDWAN_COMPONENTS.solution, accountId);
					CommonUtills.getSiteDetails(currentBasket);
				}
			});
             //Vijay: DIGI-456 start...
			await Utils.updateOEConsoleButtonVisibility_v2(currentBasket, 'oeSDWAN');
			//Vijay: DIGI-456 ...end
			if(!window.isToggled){//Added by vijay DIGI-456
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_SDWAN);
            }else{
				CommonUtills.oeErrorOrderEnrichment();
			}
			//update LTE Mode on Solution Load
			await SDWAN_UI.updateLTEModeValues();
			//Display message to check if carriage is active - DPG-5356
			await SDWAN_Validation.accessPointVerification();
			//DPG-5387/DPG-5649 Changes related to MAC Orders
			await SDWAN_UI.MACDTenancyDetails();
			//DIGI-926 Changes related to MACD Disconnection Orders
			if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
				await SDWAN_UI.MACDDisconnectionDetails();
			}
		}
	} catch (error) {
		console.log('[SDWAN_IO] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

/**
* Hook executed before we save the complex product to SF. We need to resolve the promise as a
* boolean. The save will continue only if the promise resolve with true.
* Updated by : Venkata Ramanan G
* To create case for the configuration in case the business criteria w.r.t to pricing has met
* @param {Object} complexProduct
*/
SDWAN_IO.afterSave = async function(result) {
	try {
		let solution = result.solution;
		
		if (solution == null || solution == undefined) {
			solution = await CS.SM.getActiveSolution();
		}
		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
			solution.lock("Commercial", false);
		}
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails();
		let inputMap = {};
		inputMap['getData'] = '';
		let commercialProductMap = {};
		let currentBasket = await CS.SM.getActiveBasket();
		let solutions = currentBasket.getSolutions()
		
		for (solutionId in solutions) {
			let solution = solutions[solutionId];
			
			if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
				let SDWANComp = solution.getComponentBySchemaName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
				let configurations = SDWANComp.getConfigurations();
				
				for (index in configurations) {
					let configuration = configurations[index];
					let CPID = configuration.getAttribute('plan name').value; //Assumes that the commercial product lookup is named "CommercialProduct"
					commercialProductMap[configuration.id] = CPID;
				}
			}
		}
		if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
			inputMap['CommercialProductMap'] = JSON.stringify(commercialProductMap);
			inputMap['basketId'] = currentBasket.basketId;
			let resultOEcreation;
			await currentBasket.performRemoteAction('MaterialEnrichmentDataCreator', inputMap).then(result => {});
		}
		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
			solution.lock("Commercial", true);
		}
		await SDWAN_UI.updateLTEModeValues();
		
		//DIGI-926
		if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
			await SDWAN_UI.MACDDisconnectionDetails();
		}
	} catch (error) {
		console.log('[SDWAN_IO] afterSave() exception: ' + error);
		return false;
	}
	return true;
};

SDWAN_IO.serviceTenancyHandler = async function(inputMap) {
	try {
		await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
			var subs = JSON.parse(result["GetTenancyDetailsforService"]);
			tenguId = subs.vCguId;
			tenId = subs.Tenancy_Id;
			secgu_ID = subs.sEgu_Id;
		});
	} catch (error) {
		console.log('[SDWAN_IO] serviceTenancyHandler() exception: ' + error);
		return false;
	}
	return true;
}; 