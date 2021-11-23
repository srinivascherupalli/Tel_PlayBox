/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[TMDM_Utils] loaded');

const TMDM_Utils = {};

TMDM_Utils.afterSave = async function(result) {
	try {
		let solution = result.solution;
		CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
		TMDM_UI.setOEtabsforPlatform(solution);
		//EDGE-135267
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		TMDM_Utils.updateModuleChangeforOppty(solution); //Zeeshan : TMDM issue fix to set Modelchange flag to true when clicked on validate and save button- INC000094596954
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
		console.log('[TMDM_Utils] afterSave() exception: ' + error);
		return false;
	}
	CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
	return true;
};

TMDM_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
		let oldValue = oldValueMap.value; //For EDGE-207353 on 14APR2021 by Vamsi
		let loadedSolutionTMDM = await CS.SM.getActiveSolution();
		
		if (attribute["Solution Name"] === DEFAULTSOLUTIONNAME_TMDM && attribute.name == "Marketable Offer") {
			CommonUtils.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue);
		}
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionTMDM.lock("Commercial", false);
		}
		if (component.name === "Tenancy Contact Details" && attribute.name === "TenancyPrimaryContact") {
			TMDM_Utils.updateTenancyContactDetails(configuration.parentConfiguration, attribute.value);
		}
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "Marketable Offer" && attribute.value !== "") {
			TMDM_Utils.updatevendordetails(configuration.guid);
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
		}
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup") {
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', TENANCY_COMPONENT_NAMES.tenancy,oldValue);
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
		//Shresth DPG-2084 Start
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "OfferId") {
			TMDM_UI.handleButtonVisibility(loadedSolutionTMDM); // Added by Payal as a part of EDGE-189788
		} //Shresth DPG-2084 End
		//DPG-2168
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "BillingAccountShadowTMDM") {
			//BillingAccountShadowTMDM
			billingAccount = attribute.value;
			TMDM_IO.getExistingTenancySubscriptionsForBilling(billingAccount);
		}
		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionTMDM.lock("Commercial", true);
		}
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		console.log('[TMDM_Utils] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

TMDM_Utils.solutionSetActive = async function() {
	try {
		let currentBasketTMDM = await CS.SM.getActiveBasket();
		let loadedSolutionTMDM = await CS.SM.getActiveSolution();
		
		if (loadedSolutionTMDM.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			window.currentSolutionName = loadedSolutionTMDM.name; //Added by Venkat to Hide OOTB OE Console Button

			if (loadedSolutionTMDM.componentType && loadedSolutionTMDM.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
				//EDGE-198536 Start: existing code moved inside active solution check
				window.addEventListener("message", TMDM_Utils.handleIframeMessage);
				Utils.updateImportConfigButtonVisibility(); //EDGE-198536 End: existing code moved inside active solution check
				c = 0;
				basketId = currentBasketTMDM.basketId;
				solution = loadedSolutionTMDM;
				let inputMap = {};
				inputMap["GetSiteId"] = "";
				inputMap["GetBasket"] = basketId;
				
				if (basketStage === "Contract Accepted") {
					loadedSolutionTMDM.lock("Commercial", false);
				}
				await CommonUtills.getBasketData(currentBasketTMDM);
				await CommonUtills.getSiteDetails(currentBasketTMDM);
				TMDM_UI.handleButtonVisibility(loadedSolutionTMDM); //Shresth DPG-2084
				CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
				
				if (accountId != null) {
					await CommonUtills.setAccountID(TENANCY_COMPONENT_NAMES.solution, accountId);
				}
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_TMDM);
				TMDM_UI.setOEtabsforPlatform(solution);
				
				if (basketStage === "Contract Accepted") {
					loadedSolutionTMDM.lock("Commercial", true);
				}
				CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
			}
		}
	} catch (error) {
		console.log('[TMDM_Utils] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

/*********************************
* Author	   : Mohammed Zeeshan
* Method Name  : 
* Defect/US #  : INC000094596954
* Invoked When : On Solution Load
* Description  : For TMDM Fix
*********************************/
TMDM_Utils.updateModuleChangeforOppty = async function(solution) {
	try {
		let inputMap = {};
		let currentBasket = await CS.SM.getActiveBasket();
		let comp = await solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
		let configs = await comp.getConfigurations();
		
		for (let config of Object.values(configs)) {
			var ChangeType = await config.getAttribute('ChangeType');
			
			if (ChangeType && ChangeType.value === 'transition') {
				inputMap["GetBasket"] = currentBasket.basketId;
				await currentBasket.performRemoteAction("UpdateModuleChangeforOppty", inputMap).then((result) => {});
			}
		}
	} catch (error) {
		console.log('[TMDM_Utils] updateModuleChangeforOppty() exception: ' + error);
	}
};

TMDM_Utils.updateTenancyContactDetails = async function(guid, newValue) {
	try {
		if (basketStage !== "Contract Accepted") {
			return Promise.resolve(true);
		}
		let currentSolution = await CS.SM.getActiveSolution();
		
		if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			let currentComponent = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
			
			if (currentComponent) {
				let config = currentComponent.getConfiguration(guid);
				
				if (config) {
					var updateConfigMap = {};
					updateConfigMap[config.guid] = [];
					updateConfigMap[config.guid].push({
						name: "TenancyPrimaryContact",
						value: newValue
					});
					
					if (basketStage === "Contract Accepted") {
						currentSolution.lock("Commercial", false);
					}
					if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
						await currentComponent.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
					}
					if (basketStage === "Contract Accepted") {
						currentSolution.lock("Commercial", true);
					}
				}
			}
		}
	} catch (error) {
		console.log('[TMDM_Utils] updateTenancyContactDetails() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*
User Story : EDGE-119832
Developer Name : Maq
Desc : Changes made for MDM Tenancy
*/
TMDM_Utils.handleIframeMessage = async function(e) {
	try {
		if (e.data && e.data["command"] && e.data["command"] === "AddLegacyTenancy" && e.data["caller"] && e.data["caller"] === "MDMTenancy") {
			await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution); //EDGE-224663
			var TenancyList = new Array();
			let currentSolution = await CS.SM.getActiveSolution();
			
			if (tenancyAPIdone == false) {
				let payloadResponse = JSON.parse(e.data["data"]);
				var updateMap = [];
				
				for (var i = 0; i < payloadResponse.length; i++) {
					var tenancyRecord = payloadResponse[i];
					TenancyList.push(tenancyRecord.id);
					//Fix to update the map with each value
					updateMap.push({
						name: "Tenancy Id",
						value: {value: tenancyRecord.id,
						displayValue: tenancyRecord.id}
					});
					updateMap.push({
						name: "Vendor Name",
						value: {value: tenancyRecord.name,
						displayValue: tenancyRecord.name}
					});
					updateMap.push({
						name: "ChangeType",
						value: {value: "transition",
						displayValue: "transition"}
					});
					
					//EDGE-224663 start------
					if (accountId) {
						updateMap.push({
							name: "AccountId",
							value: {value: accountId,
							displayValue: accountId}
						});
					}
					if (parentBillingAccountATT) {
						updateMap.push({
							name: "BillingAccountLookup",
							value: {value: parentBillingAccountATT.value,
							displayValue: parentBillingAccountATT.displayValue}
						});
					} //EDGE-224663 end -----
				}
				//Fix to traverse the Config instead of method
				let comp = currentSolution.getComponentByName("Platform");
				
				if (comp) {
					Object.values(comp.schema.configurations).forEach((config) => {
						let attribute = config.getAttribute("Tenancy Id");
						
						if (attribute) {
							if (attribute.name === "Tenancy Id" && attribute.value) {
								if (TenancyList.includes(attribute.value)) {
									tenancyAPIdone = true;
								}
							}
						}
					});
				}
				if (tenancyAPIdone === false && TenancyList.length > 0) {
					let comp = currentSolution.getComponentByName("Platform");
					
					if (comp) {
						tenancyAPIdone = true;
						//Fix to add the new Config
						const newConfig = comp.createConfiguration(updateMap);
						comp.addConfiguration(newConfig, true);
					}
					//Fix to show only the Success Message.
					CS.SM.displayMessage("Legacy Tenancy Services added successfully", "success");
				} else {
					if (TenancyList.length == 0) {
						CS.SM.displayMessage("No Legacy Tenancy Services Available", "error");
					} else {
						CS.SM.displayMessage("Legacy Tenancy Services already added", "error");
					}
				}
			} else {
				CS.SM.displayMessage("Legacy Tenancy Services already added", "error");
			}
		}
		//Added as a part of EDGE-189788
		else if (e.data && e.data["command"] && e.data["command"] === "RateCard" && e.data["caller"] && e.data["caller"] === TENANCY_COMPONENT_NAMES.tenancy) { //EDGE-228932: Modified Value "TMDM" to "Platform"
			await CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],TENANCY_COMPONENT_NAMES.tenancy); //Added as a part of EDGE-189788 //EDGE-228932: Removed param callerNameNGUC
		}
		//Added as part of EDGE-228932: To handle close event in order to close the modal
		else if(e.data && e.data === 'close') {
			pricingUtils.closeModalPopup();
		}
	} catch (error) {
		console.log('[TMDM_Utils] handleIframeMessage() exception: ' + error);
	}
	return Promise.resolve(true);
};

TMDM_Utils.updatevendordetails = async function(guid) {
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		let currentBasketTMDM = await CS.SM.getActiveBasket();
		let component = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.solution);
		let solutionconfig = component.getConfigurations();
		let updateConfigMap = {};
		let inputMap = {};
		
		if (solutionconfig) {
			inputMap["OfferId"] = "DMCAT_Offer_000681";
			await currentBasketTMDM.performRemoteAction("CSTenancyVendorlookup", inputMap).then(function (response) {
				if (response && response["vendor"] != undefined) {
					var vendorinfo = response["vendor"];
					var vendorname = vendorinfo.Vendor__c;
					var vendorid = vendorinfo.Id;
					updateConfigMap[guid] = [];
					updateConfigMap[guid].push({
						name: "Vendor Name",
						value: vendorname
					},
					{
						name: "Vendor",
						value: vendorid
					});
				}
			});
		}
		if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
			keys = Object.keys(updateConfigMap);
			
			for (let i = 0; i < keys.length; i++) {
				component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
		}
	} catch (error) {
		console.log('[TMDM_Utils] updatevendordetails() exception: ' + error);
	}
	return Promise.resolve(true);
};

TMDM_Utils.beforeSave = async function() {
	try {
		//DO NOT PUT IN beforeSave ANY ADDITIONAL CODE, ESPECIALLY CODE FOR UPDATING VALUES OR ANY ASYNC CODE !!!!!
		CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		CommonUtills.unlockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
		//Added below criteria as per EDGE-189788
		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		
		if (!ExpectedSIO) {
			return false;
		}
		CommonUtills.lockSolution(); //For EDGE-207353 on 14APR2021 by Vamsi
	} catch (error) {
		console.log('[TMDM_Utils] beforeSave() exception: ' + error);
		return false;
	}
	return true;
};