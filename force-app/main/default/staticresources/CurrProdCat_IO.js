/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[CurrProdCat_IO] loaded');

const AN_IO = {};

AN_IO.solutionSetActive = async function() {
	try {
		let loadedSolution = await CS.SM.getActiveSolution();
		//Start CPC Changes 
		let currentBasket = await CS.SM.getActiveBasket();
		basketId = currentBasket.basketId;
		let inputMap = {};
		inputMap["GetBasket"] = basketId;
		await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
			var basket = JSON.parse(result["GetBasket"]);
			accountId = basket.csbb__Account__c;
			opportunityId = basket.cscfga__Opportunity__c;
		});
		inputMap["GetOppty"] = opportunityId;
		await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
			var oppty = JSON.parse(result["GetOppty"]);
			SRVList = oppty.Price_List__c;
			opportunityStage = oppty.StageName;
			OptyType = oppty.Type; //P2OB-11769
			createdByUser = oppty.CreatedBy.Name; //P2OB-13516
			accountId = oppty.Account.Id;
			partnerAccount = oppty.PartnerAccount; //P2OB-12186
			
			if (partnerAccount != null && partnerAccount != '' && partnerAccount != undefined) {
				partnerAccountName = partnerAccount.Name; //P2OB-12186
				partnerAccountId = partnerAccount.Id;
			}
			if (opportunityStage != null && opportunityStage != '' && opportunityStage != undefined && (opportunityStage === 'Closed Lost' || opportunityStage === 'Closed Won')) {
				let stdProdComp = loadedSolution.getComponentBySchemaName(AN_COMPONENTS.solution);
				stdProdComp.lock('Commercial', true);
				let addProdComp = loadedSolution.getComponentBySchemaName(AN_COMPONENTS.StandardProduct);
				addProdComp.lock('Commercial', true);
			}
		}); //End CPC Changes
	} catch (error) {
		console.log('[CurrProdCat_IO] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

AN_IO.afterSave = async function(inputMap) {
	try {
		currentBasket.performRemoteAction("SolutionActionHelper", inputMap);
	} catch (error) {
		console.log('[CurrProdCat_IO] afterSave() exception: ' + error);
	}
}