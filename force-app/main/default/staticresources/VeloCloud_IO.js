/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[VeloCloud_IO] loaded');

const VC_IO = {};

VC_IO.solutionSetActive = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
		window.addEventListener('message', VC_Utils.VC_handleIframeMessage);//Added By vijay

        if (solution.name.includes(VELOCLOUD_COMPONENTS.VeloCloudSol)) {
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
                    CommonUtills.setAccountID(VELOCLOUD_COMPONENTS.VeloCloudSol, accountId);
                    CommonUtills.getSiteDetails(currentBasket);
                }
            });
             //Vijay: DIGI-456 start...
			await Utils.updateOEConsoleButtonVisibility_v2(currentBasket, 'oeTenancySDWAN');
			//Vijay: DIGI-456 ...end
			if(!window.isToggled){//Added by vijay DIGI-456
           	 VC_Utils.addDefaultVeloOETenancyConfigs();
            }else{
                CommonUtills.oeErrorOrderEnrichment();
            }
            //Added by vijay DIGI-456
        }
	} catch (error) {
		console.log('[VeloCloud_IO] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
}; 