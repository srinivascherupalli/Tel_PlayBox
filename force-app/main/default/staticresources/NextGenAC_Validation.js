/*
 * Handles all validation logic
 */
console.log('[NextGenAC_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const NGMAC_Validation = {};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : NGMACPlugin_validateDisconnectionDate
* Defect/US # : DPG-1914
* Invoked When: On Disconnection Date Update
* Description : For formatting of the Disconnection Date
********************************/
NGMAC_Validation.validateDisconnectionDate = async function(componentName, guid, newValue) {
	try {
		let today = new Date();
		let attDate = new Date(newValue);
		today.setHours(0, 0, 0, 0);
		attDate.setHours(0, 0, 0, 0);
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentName); //PD
		let config = await component.getConfiguration(guid); //PD
		
		if (attDate <= today) {
			CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
			config.status = false;
			config.statusMessage = 'Disconnection date should be greater than today!';
		} else {
			config.status = true;
			config.statusMessage = '';
		}
	} catch (error) {
		console.log('[NextGenAC_Validation] validateDisconnectionDate() exception: ' + error);
	}
};

/*********************************
* Author	  : Romil Anand
* Method Name : validationBillingCheck
* Defect/US # : DPG-2015
* Invoked When: On attribute update
* Description : Billing Account Validation
*********************************/
NGMAC_Validation.validationBillingCheck = async function(billingAccount,componentName,guid) { //Krunal
	try {
		let updateMap = new Map();
		let componentMapNew = new Map();
		var billingInfo = "";
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentName); //PD
		let config = await component.getConfiguration(guid);//PD 
		inputMap['billingDetails'] = billingAccount.displayValue;
		inputMap['guid'] = guid;
		let currentBasket = await CS.SM.getActiveBasket();
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			billingInfo = JSON.parse(result["billingDetails"]);
			return Promise.resolve(true);
		});
		
		if (billingInfo === true) {
			componentMapNew.set('CheckBillingError', true);
			config.status = false;
			config.statusMessage = 'This Billing Account is already associated with one of the Solution.';
		} else {
			componentMapNew.set('CheckBillingError', false);
			config.status = true;
			config.statusMessage = '';
		}
		
		if (componentMapNew && componentMapNew.size > 0) {
			updateMap.set(guid,componentMapNew);
			CommonUtills.UpdateValueForSolution(componentName,updateMap);
		}
	} catch (error) {
		console.log('[NextGenAC_Validation] validationBillingCheck() exception: ' + error);
	}
};

/*********************************
* Author	  : Romil Anand
* Method Name : validationErrorBillingCheck
* Defect/US # : DPG-2015
* Invoked When: Onload and Aftersave
* Description : Billing Account Validation
*********************************/
NGMAC_Validation.validationErrorBillingCheck = async function() { //Krunal
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.schema.configurations).forEach((subsConfig) => {
					var checkbilling = Object.values(subsConfig.attributes).filter(att => {
						return att.name === 'CheckBillingError'
					});
					
					if (checkbilling[0].value === true) {
						subsConfig.status = false;
						subsConfig.statusMessage = 'This Billing Account is already associated with one of the Solution.';
					} else {
						subsConfig.status = true;
						subsConfig.statusMessage = '';
					}
				});
			}
		}
	} catch (error) {
		console.log('[NextGenAC_Validation] validationErrorBillingCheck() exception: ' + error);
	}
};