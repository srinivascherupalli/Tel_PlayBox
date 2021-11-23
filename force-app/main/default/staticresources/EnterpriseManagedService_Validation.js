/*
 * Handles all validation logic
 */
console.log('[EnterpriseManagedService_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const EMS_Validation = {};

//--BEFORESAVE - added by krunal - DPG-2577 - START
EMS_Validation.beforeSave = async function(solution) {
	try {
		CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		EMS_Utils.updateChangeTypeAttribute(); //change type update before save
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		//-- p2o validation DPG-2577 -- Start -- Krunal //Telstra Mobile Device Management - VMware
		let currentActiveBasket = await CS.SM.getActiveBasket();
		let profServCheck = "Absent";
		let tmdmVMWareCheck = "Absent";
		let flag = "yes";
		let mobilityPlatformMgmtConfig = "Absent";
		let userSupportConfig = "Absent";
		var chtype;
		var replacedConfig; //DPG-4134

		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (currentActiveBasket.solutions && Object.values(currentActiveBasket.solutions).length > 0) {
				//EDGE-154489
				for (const basketSol of Object.values(currentActiveBasket.solutions)) {
					if (basketSol.name === "T-MDM Professional Services") {
						profServCheck = "PFPresent";
					} else if (basketSol.name === "Telstra Mobile Device Management - VMware") {
						tmdmVMWareCheck = "TMDMPresent";
					}
				}
			}

			if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {
				for (const config of Object.values(currentSolution.schema.configurations)) {
					chtype = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
					replacedConfig = config.replacedConfigId; //DPG-4134
				}
			}

			//commented/added for one to many changes - START
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				let MobilityValue; //For EDGE-207353 on 14APR2021 by Vamsi
				let SupportValue; //For EDGE-207353 on 14APR2021 by Vamsi
				let compPM = await currentSolution.getComponentByName(EMS_COMPONENT_NAMES.mobilityPlatformMgmt);

				if (compPM) {
					let cmpConfig = await compPM.getConfigurations();

					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						mobilityPlatformMgmtConfig = 'Present';
					}

					//For EDGE-207353 on 14APR2021 by Vamsi starts
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							MobilityValue = config.getAttribute("BillingAccountLookup").value;
						}
					} //For EDGE-207353 on 14APR2021 by Vamsi ends
				}
				let compUS = await currentSolution.getComponentByName(EMS_COMPONENT_NAMES.userSupport);

				if (compUS) {
					let cmpConfig = await compUS.getConfigurations();

					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						userSupportConfig = 'Present';
					}

					//For EDGE-207353 on 14APR2021 by Vamsi strats
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							SupportValue = config.getAttribute("BillingAccountLookup").value;
						}
					}
				}

				if (SupportValue !== MobilityValue) {
					CS.SM.displayMessage('Billing Account must be same for Platform Management and End User Support', 'error');
					cmpConfig.status = true;
					cmpConfig.statusMessage = "Billing Account must be same for Platform Management and End User Support";
				} //For EDGE-207353 on 14APR2021 by Vamsi ends
			}
			EMS_Validation.checkValidationForConfigurationMS(); //DPG-3036
			var isExpectedSIOPopulated = await CommonUtills.validateExpectedSIO(); //Added as a part of EDGE-178214

			if (!isExpectedSIOPopulated) { //EDGE-194599: Adding if condition for Expected SIO
				return false;
			}
		} //-- p2o validation DPG-2577 -- End -- Krunal - part of code from aftersave
		let Component = currentSolution.getComponentByName(EMS_COMPONENT_NAMES.solution); //EDGE-154489

		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			//changed currentSolution.type to currentSolution //EDGE-154489
			if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {
				//EDGE-154489
				for (const config of Object.values(currentSolution.schema.configurations)) {
					//EDGE-154489
					if (config.attributes && Object.values(config.attributes).length > 0) {
						//EDGE-154489
						for (const attr of Object.values(config.attributes)) {
							//EDGE-154489
							//commented/added for one to many changes - START
							if (mobilityPlatformMgmtConfig === "Absent" && userSupportConfig === "Absent") {
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage = "Please select either Endpoint Management - Platform Support or Endpoint Management - User Support or Both"; //DIGI-809 Name change
							}

							//commented/added for one to many changes - END
							if (attr.name === "TenancyID" && Object.values(attr.value).length > 0 && tmdmVMWareCheck === "Absent" && BasketChange != 'Change Solution') {
								EMS_Validation.validationActiveManagedServiceSubscriptionCheck(attr, Component, config.guid);
							}
							// Commented as a part of DPG-14770 by Akshay G
							/*if (attr.name === "TenancyID" && (attr.value === "" || attr.value === null || attr.value === undefined) && tmdmVMWareCheck === "Absent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)) {
								//Changes as part of EDGE-154489 start
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage = "Please select an existing tenancy or add a new tenancy"; //Changes as part of EDGE-154489 end
							}*/
							//to check if Existing Tenancy is selected and adding new Telstra Mobile Device Management - VMware //-- p2o validation DPG-2577 -- Start -- Krunal
							if (attr.name === "TenancyID" && Object.values(attr.value).length > 0 && tmdmVMWareCheck === "TMDMPresent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)) {
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage = "Basket cannot add new Telstra Mobile Device Management - VMware when existing Tenancy is selected";
							}
							//Commented as a part of DPG-14770 by Akshay G
							/* else if (((attr.name === "TenancyID" && Object.values(attr.value).length > 0) || tmdmVMWareCheck === "TMDMPresent") && profServCheck === "Absent" && BasketChange != 'Change Solution') {
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage = "Please add T-MDM Professional Services to the basket";
							} */
							//Start:DPG-3632 --> Validation Check for Change Type Value Active Added
							////DPG-4134
							else if (chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'Active' || (chtype[0].value === 'New' && BasketChange === "Change Solution" && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== ""))) {
								//EDGE-154489
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage = "Please Select Change Type";
							} else if ((attr.name === "TenancyID" && Object.values(attr.value).length > 0) || tmdmVMWareCheck === "TMDMPresent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)) {
								//EDGE-154489
								//Changes as part of EDGE-154489 start
								let confg = await Component.getConfiguration(config.guid);
								confg.status = true;
								confg.statusMessage = "";
								return true; //Changes as part of EDGE-154489 end
							} else if (chtype[0].value === 'Cancel') {
								//EDGE-154489
								let confg = await Component.getConfiguration(config.guid);
								confg.status = true;
								confg.statusMessage = "";

								//Start :DPG-3632- Validation for Cancel all solution
								let terminateSave = true;

								if (!EMS_Validation.validateCancelSolution(currentSolution)) {
									terminateSave = false;
									return false;
								}
								if (!terminateSave) {
									return false;
								}

								//Start :DPG-3632
								return true;
							} //-- p2o validation DPG-2577 -- End -- Krunal
						}
					}
				}
			}
		}
	} catch (error) {
		console.log('[EMS_Validation] beforeSave() exception: ' + error);
		return false;
	}
};

//DPG-3036 START
EMS_Validation.checkValidationForConfigurationMS = async function() {
	try {
		let currentBasket;
		let solution;
        var updateMap = {};
		var isMsPresent;
		var totalCount = 0;
		var tenancyID = "";
		var configurations = [];
		var component;
		var configGuid;
		currentBasket = await CS.SM.getActiveBasket();
		solution = currentBasket.solutions;
		
		if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
			for (const basketSol of Object.values(currentBasket.solutions)) {
				if (basketSol.name === EMS_COMPONENT_NAMES.solution) {
					component = basketSol.getComponentByName(EMS_COMPONENT_NAMES.solution);
					let cmpConfig = await basketSol.getConfigurations();
					
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							configGuid = config.guid;
							tenancyIds = config.getAttribute("TenancyId");
							t1 = tenancyIds.value;
							tenancyID = t1;
						}
					}
					if (basketSol.components && Object.values(basketSol.components).length > 0) {
						for (const comp of Object.values(basketSol.components)) {
							let cmpConfig = await comp.getConfigurations();
							
							if (cmpConfig && Object.values(cmpConfig).length > 0) {
								totalCount = totalCount + 1;
								
								for (const config of Object.values(cmpConfig)) {
									configurations.push(config.guid);
								}
							}
						}
						
						if (totalCount > 0) {
							for (const config of configurations) {
								updateMap[config] = [];
								updateMap[config].push({
									name: "TenancyID",
									value: tenancyID,
									displayValue: tenancyID
								});
								
								if (updateMap && Object.keys(updateMap).length > 0) {
									await component.updateConfigurationAttribute(config, updateMap[config], true);
								}
							}
						}
					}
				}
			}
		}
	} catch (error) {
		console.log('[EMS_Validation] checkValidationForConfigurationMS() exception: ' + error);
	}
}; //DPG-3036 END

/*********************************
* Author	: Krunal Taak
* Method Name : validation Active Managed Service Subscription Check
* Defect/US # : DPG-2577
* Invoked When: On attribute update
* Description :validation Active Managed Service Subscription Check
*********************************/
EMS_Validation.validationActiveManagedServiceSubscriptionCheck = async function(tenancyId, component, guid) { //Krunal
	try {
		let updateMap = new Map();
		let componentMapNew = new Map();
		var tenancyInfo = "";
		let inputMap = {};
		let config = await component.getConfiguration(guid);
		inputMap['tenancyId'] = tenancyId.value;
		let currentBasket = await CS.SM.getActiveBasket();
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			tenancyInfo = JSON.parse(result["tenancyId"]);
			return Promise.resolve(true);
		});
		
		if (tenancyInfo === true) {
			componentMapNew.set('CheckTenancyError', true);
			config.status = false;
			config.statusMessage = 'Please select a different tenancy or add a new tenancy';
		} else {
			componentMapNew.set('CheckTenancyError', false);
		}
		
		if (componentMapNew && componentMapNew.size > 0) {
			updateMap.set(guid, componentMapNew);
			CommonUtills.UpdateValueForSolution(component.name, updateMap);
		}
	} catch (error) {
		console.log('[EMS_Validation] validationActiveManagedServiceSubscriptionCheck() exception: ' + error);
	}
};

/*********************************
* Author      : Monali Mukherjee
* Method Name : validateCancelSolution DPG-3632
* Invoked When: before save when CHangeType is Cancel
* Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all subscriptions change type is set to cancel
* Parameters : solution
*********************************/
EMS_Validation.validateCancelSolution = function(solution) {
	try {
		let configs = Object.values(solution.schema.configurations);
		let changeTypeAttribute = Object.values(configs[0].attributes).filter(a => {
			return a.name === 'ChangeType' && a.value === 'Cancel'
		});
		
		if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
			return true;
		}
		
		let isValid = true;
		Object.values(solution.components).forEach((comp) => {
			if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt || EMS_COMPONENT_NAMES.userSupport) {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((mobilesubConfig) => {
						changeTypeAttribute = Object.values(mobilesubConfig.attributes).filter(a => {
							return a.name === 'ChangeType' && a.value !== 'Cancel'
						});
						
						if (changeTypeAttribute && changeTypeAttribute.length > 0) {
							isValid = false;
						}
					});
				}
			}
		});
		
		if (!isValid) {
			CS.SM.displayMessage('When canceling whole solution all Subscriptions must be canceled too!', 'error');
		}
		return isValid;
	} catch (error) {
		console.log('[EMS_Validation] validateCancelSolution() exception: ' + error);
	}
};

/*********************************
* Author	: Monali Mukherjee
* Method Name : EMSPlugin_validateDisconnectionDate
* Defect/US # : DPG-1914
* Invoked When: On Disconnection Date Update
* Description : For formatting of the Disconnection Date
*********************************/
EMS_Validation.validateDisconnectionDate = async function(componentName, guid, newValue) { //Krunal
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
		console.log('[EMS_Validation] validateDisconnectionDate() exception: ' + error);
	}
};