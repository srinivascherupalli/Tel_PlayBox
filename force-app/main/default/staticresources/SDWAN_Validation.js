/*
 * Handles all validation logic
 */
console.log('[SDWAN_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const SDWAN_Validation = {};

SDWAN_Validation.beforeRelatedProductDelete = async function(configuration, relatedProduct) {
	try {
		let solution = await CS.SM.getActiveSolution();
		var planName;
		
		if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name.includes(SDWAN_COMPONENTS.childComponent)) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((config) => {
								if (config.guid) {
									let attribs = Object.values(config.attributes);
									planName = attribs.filter((obj) => {
										return obj.name === "Plan Name";
									});
								}
							});
						}
					}
				});
			}
		}
		var listOfRelatedProducts = configuration.getRelatedProducts();
		var countRelatedProducts = 0;
		Object.values(listOfRelatedProducts).forEach((rp) => {
			if (SDWAN_COMPONENTS.relatedProduct === rp.name) {
				countRelatedProducts++;
			}
		});
		//DPG-3906 - Validation Error Messages
		if (SDWAN_COMPONENTS.planeNames.includes(planName[0].displayValue) && countRelatedProducts == 1 && relatedProduct.name === SDWAN_COMPONENTS.relatedProduct) {
			CS.SM.displayMessage("Mobile access is required for " + planName[0].displayValue + ". Please select SD-WAN Adapt S1 - Large or Extra Large if mobile access is not required.", "error");
			return false;
		}
	} catch (error) {
		console.log('[SDWAN_Validation] beforeRelatedProductDelete() exception: ' + error);
		return false;
	}
	return true;
};

SDWAN_Validation.beforeRelatedProductAdd = async function(configuration, relatedProduct) {
	try {
		let solution = await CS.SM.getActiveSolution();
		var planName;
		
		if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name.includes(SDWAN_COMPONENTS.childComponent)) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((config) => {
								if (config.guid) {
									let attribs = Object.values(config.attributes);
									planName = attribs.filter((obj) => {
										return obj.name === "Plan Name";
									});
								}
							});
						}
					}
				});
			}
		}
		//DPG-3906/DPG-4692 - Validation Error Messages
		if (!SDWAN_COMPONENTS.planeNames.includes(planName[0].displayValue)) {
			CS.SM.displayMessage("Mobile access is not required for " + planName[0].displayValue + ". Please select SD-WAN Adapt S1 - Extra Small or Small or Medium if mobile access is required.", "error");
			return false;
		}
		var listOfRelatedProducts = configuration.getRelatedProducts();
		var countRelatedProducts = 0;
		Object.values(listOfRelatedProducts).forEach((rp) => {
			if (SDWAN_COMPONENTS.relatedProduct === rp.name) {
				countRelatedProducts++;
			}
		});
		//DPG-3906 - Validation Error Messages
		if (countRelatedProducts == 1 && relatedProduct.name === SDWAN_COMPONENTS.relatedProduct) {
			CS.SM.displayMessage("Only one Enterprise Wireless can be configured for " + planName[0].displayValue, "error");
			return false;
		}
	} catch (error) {
		console.log('[SDWAN_Validation] beforeRelatedProductAdd() exception: ' + error);
		return false;
	}
	return true;
};

/***********************************	
* Author	  : Payel/Suyash/Sharmila 
* Method Name : AccessPointVerification
* Invoked When: When Solution is loaded and if the Change Type is not 'Cancel'
* Description : To display simple message 	- DPG-5356 / DIGI-6777
* Parameters  : None	
***********************************/
SDWAN_Validation.accessPointVerification = async function() {
	try {
		var Change_Type;
		let currentSolution = await CS.SM.getActiveSolution();
		Object.values(currentSolution.schema.configurations).forEach((config) => {
			if (config.guid) {
				let attribs = Object.values(config.attributes);
				Change_Type = attribs.filter((c) => {
					return c.name === "ChangeType";
				});
			}
		});
		var changeTypeVal = Change_Type[0].value;
		
		if (modbasketChangeType === 'Change Solution' && changeTypeVal !== "Cancel") {
			CS.SM.displayMessage("Ensure carriage is active at the customer site where required", "error");
		}
	} catch (error) {
		console.log('[SDWAN_Validation] accessPointVerification() exception: ' + error);
	}
	return Promise.resolve(true);
};