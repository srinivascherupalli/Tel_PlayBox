/*
 * Handles all validation logic
 */
console.log('[DMS_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const DMS_Validation = {};

/********************************* 
* Author	  : shashank
* Method Name : validateDisconnectionDate
* Defect/US # : DIGI-22593
* Invoked When: On Disconnection Date Update
* Description : For formatting of the Disconnection Date
********************************/
DMS_Validation.validateDisconnectionDate = async function(componentName, guid, newValue) {
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
		console.log('[DMS_Validation] validateDisconnectionDate() exception: ' + error);
	}
};
