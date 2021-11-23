/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[DMS_IO] loaded');

const DMS_IO = {};

/***********************************
* Invoked When: On Solution Load
* Description : For TMDM Fix
***********************************/
DMS_IO.updateModuleChangeforOpptyDMS = async function(solution) {
	try {
		let inputMap = {};
		let currentBasket = await CS.SM.getActiveBasket();
		let comp = await solution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
		let configs = await comp.getConfigurations();
		
		for (let config of Object.values(configs)) {
			var ChangeType = await config.getAttribute('ChangeType');
			
			if (ChangeType && ChangeType.value === 'transition') {
				inputMap["GetBasket"] = currentBasket.basketId;
				await currentBasket.performRemoteAction("UpdateModuleChangeforOpptyDMS", inputMap).then((result) => {});
			}
		}
	} catch (error) {
		console.log('[DMS_IO] updateModuleChangeforOpptyDMS() exception: ' + error);
	}
};