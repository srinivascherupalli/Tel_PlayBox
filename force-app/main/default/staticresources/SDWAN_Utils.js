/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[SDWAN_Utils] loaded');

const SDWAN_Utils = {};

SDWAN_Utils.afterRelatedProductAdd = async function(component, configuration, relatedProduct) {
	try {
		let solution = await CS.SM.getActiveSolution();
		let attrCommercialConfig = configuration.getAttribute('plan name');
		let updateMap = {
			value: attrCommercialConfig.value,
			displayValue: attrCommercialConfig.displayValue
		};
		await SDWAN_UI.updateChildAttributedOnAdd(SDWAN_COMPONENTS.solution, configuration.guid, component, relatedProduct);
	} catch (error) {
		console.log('[SDWAN_Utils] afterRelatedProductAdd() exception: ' + error);
		return false;
	}
	return true;
};
