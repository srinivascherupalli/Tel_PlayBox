/*
 * Interface methods for this product; can be referenced from any of the modules
 */
console.log('[TMDM_IO] loaded');

const TMDM_IO = {};

TMDM_IO.solutionAfterConfigurationAdd = async function(component, configuration) {
	try {
		let currentBasketTMDM = await CS.SM.getActiveBasket();
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(component.name);
		var updateMap = {};
		var vendorname = "";
		let inputMap = {};
		inputMap["OfferId"] = offerName;
		await currentBasketTMDM.performRemoteAction("CSTenancyVendorlookup", inputMap).then(function(response) {
			if (response && response["vendor"] != undefined) {
				var vendorinfo = response["vendor"];
				vendorname = vendorinfo.Vendor__c;
			}
		});
		updateMap[configuration.guid] = [];
		updateMap[configuration.guid].push({
			name: "Vendor Name",
			value: vendorname
		});
		//EDGE-119833 Start
		let comp = currentSolution.getComponentByName("Platform");
		
		if (comp) {
			let configurations = comp.getConfigurations();
			
			if (configurations) {
				Object.values(configurations).forEach((config) => {
					let attributes = config.getAttributes();
					
					if (attributes) {
						Object.values(attributes).forEach((attribute) => {
							if (attribute.name == "ChangeType" && attribute.value == "New") {
								updateVendorName = true;
							}
							if (attribute.name == "Vendor Name" && attribute.value == "") {
								isVendorNull = true;
							}
						});
					}
					if (updateVendorName == true && isVendorNull == true) {
						if (updateMap && Object.keys(updateMap).length > 0) {
							keys = Object.keys(updateMap);
							
							for (let i = 0; i < keys.length; i++) {
								currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
							}
						}
						updateVendorName = false;
						isVendorNull = false;
					}
				});
			}
		}
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {	
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
		await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_TMDM);
	} catch (error) {
		console.log('[TMDM_IO] solutionAfterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

//Added by Monali - DPG - 2168
TMDM_IO.getExistingTenancySubscriptionsForBilling = async function(billingAccount) {
	try {
		let inputMap1 = {};
		let currentBasket = await CS.SM.getActiveBasket();
		var checkexistingsubs = false;
		inputMap1["getExistingTenancySubscriptionsForBilling"] = billingAccount;
		await currentBasket.performRemoteAction("SolutionActionHelper", inputMap1).then((result) => {
			var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptionsForBilling"]);
			
			if (existingsubscriptions != null && existingsubscriptions !== "") {
				var boo = window.confirm("There are existing MDM tenancies on the customer billing account. Existing Tenancy Id(s) :" + existingsubscriptions + ".Do you want to proceed adding new Tenancies?");
			}
		});
	} catch (error) {
		console.log('[TMDM_IO] getExistingTenancySubscriptionsForBilling() exception: ' + error);
	}
	return Promise.resolve(true);
};