/*
 * Handles all UI-related logic
 */
console.log('[PSMDM_UI] loaded');

const PSMDM_UI = {};

PSMDM_UI.afterSave = async function(result) {
	try {
		CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
		let solution = result.solution;
		
		if (window.basketStage === 'Contract Accepted') {
			solution.lock('Commercial', false);
		}
		PSMDM_Utils.updateSolutionName_TMDM_PS(); //Added as part of EDGE-149887
		Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		
		if (window.basketStage === 'Contract Accepted') {
			solution.lock('Commercial', true);
		}
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
		console.log('[PSMDM_UI] afterSave() exception: ' + error);
		return false;
	}
	CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
	return true;
};