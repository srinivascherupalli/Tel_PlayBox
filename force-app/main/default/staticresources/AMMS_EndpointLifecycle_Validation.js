/*
 * Handles all validation logic
 */
console.log('[AMMS_EndpointLifecycle_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const AMMS_EndpointLifecycle_Validation = {};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : NGMACPlugin_validateDisconnectionDate
* Defect/US # : DPG-1914
* Invoked When: On Disconnection Date Update
* Description : For formatting of the Disconnection Date
********************************/
AMMS_EndpointLifecycle_Validation.validateDisconnectionDate = async function(componentName, guid, newValue) {
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
		console.log('[AMMS_EndpointLifecycle_Validation] validateDisconnectionDate() exception: ' + error);
	}
};
