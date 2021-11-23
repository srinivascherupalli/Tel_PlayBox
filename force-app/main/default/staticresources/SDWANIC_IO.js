/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[SDWANIC_IO] loaded');

const SDWANIC_IO = {};

SDWANIC_IO.solutionSetActive = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
		
        if (solution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
            currentBasket = await CS.SM.getActiveBasket();
            const basketId = await CS.SM.getActiveBasketId();
            let inputMap = {};
            inputMap['GetBasket'] = basketId;
            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
				var basket = JSON.parse(result["GetBasket"]);
				basketChangeType = basket.csordtelcoa__Change_Type__c;
                //modbasketChangeType = basketChangeType;
                basketStage= basket.csordtelcoa__Basket_Stage__c;
                accountId = basket.csbb__Account__c;
				opptyType = basket.Opportunity_Type__c;
				console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId)
				window.oeSetBasketData(solution, basketStage, accountId);
				
				if (accountId != null) {
                    CommonUtills.setAccountID(SDWANVPN_COMPONENTS.InterConnectSol, accountId);
                }
            });
            SDWANIC_UI.InterConnectPOPattrUpdate(); //DIGI-26454
            SDWANIC_UI.MACDTenancyIdDetails();
            //SDWANIC_UI.AfterAddtoMacChange();
			if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  solution.lock("Commercial", true);
              }
        }
	} catch (error) {
		console.log('[SDWANIC_IO] solutionSetActive() exception: ' + error);
        return false;
	}
    return true;
};

//DN: consider moving to a different module (e.g.: Utility) as this is not doing performRemoteAction() call
SDWANIC_IO.afterSave = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
        console.log('SDWANIC_IO solution ===>' + solution);
        SDWANIC_UI.InterConnectPOPattrUpdate(); //DIGI-26454
        if (solution == null || solution == undefined) {
            solution = await CS.SM.getActiveSolution();
        } 
        if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
            solution.lock("Commercial", true);
        }
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		
	} catch (error) {
		console.log('[SDWANIC_IO] afterSave() exception: ' + error);
        return false;
	}
    return true;
};
