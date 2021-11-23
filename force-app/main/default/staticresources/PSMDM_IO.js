/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[PSMDM_IO] loaded');

const PSMDM_IO = {};

PSMDM_IO.solutionSetActive = async function(e) {
	try {
		let currentBasket = await CS.SM.getActiveBasket();
		let loadedSolution = await CS.SM.getActiveSolution();
		
		if (loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
			window.currentSolutionName = loadedSolution.name; //Added by Venkat to Hide OOTB OE Console Button
			//EDGE-198536 Start: existing code moved inside active solution check
			document.addEventListener('click', function (e) {
				e = e || window.event;
				var target = e.target || e.srcElement;
				var text = target.textContent || target.innerText;
				//EDGE-135267 Aakil
				if (text && (text.toLowerCase() === 'overview' || text.toLowerCase().includes('stage'))) {
					Utils.hideSubmitSolutionFromOverviewTab();
				}
			}, false); //EDGE-198536 End: existing code moved inside active solution check
			
			if (loadedSolution.componentType && loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
				basketId = currentBasket.basketId;
				solution = loadedSolution;
				let inputMap = {};
				inputMap['GetBasket'] = basketId;
				currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
					var basket = JSON.parse(result["GetBasket"]);
					basketChangeType = basket.csordtelcoa__Change_Type__c;
					basketStage = basket.csordtelcoa__Basket_Stage__c;
					accountId = basket.csbb__Account__c;
					window.oeSetBasketData(basketId, basketStage, accountId);
					
					if (basketStage === 'Contract Accepted') {
						loadedSolution.lock('Commercial', false);
					}
					//Added by Aman Soni as a part of EDGE -148455 || Start
					if (accountId != null && basketStage !== 'Contract Accepted') {
						CommonUtills.setAccountID(PSMDM_COMPONENT_NAMES.solution, accountId);
					} //Added by Aman Soni as a part of EDGE -148455 || End
					PSMDM_Utils.addDefaultPSMDMOEConfigs();
					
					if (basketStage === 'Contract Accepted') {
						loadedSolution.lock('Commercial', true);
					}
				});
			}
			CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
			
			//DPG-3036 START
			if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
				for (const basketSol of Object.values(currentBasket.solutions)) {
					if (basketSol && basketSol.name.includes(EMS_COMPONENT_NAMES.solution)) {
						let cmpConfig = await basketSol.getConfigurations();
						
						if (cmpConfig && Object.values(cmpConfig).length > 0) {
							for (const config of Object.values(cmpConfig)) {
								tenancyIds = config.getAttribute("TenancyId");
								t1 = tenancyIds.value;
								MSUtils.setTenancyIdForProffesionalService(t1);
							}
						}
					}
				}
			} //DPG-3036 END
		}
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		console.log('[CurrProdCat_IO] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};