/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[EnterpriseManagedService_Utils] loaded');

const EMS_Utils = {};

EMS_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		let oldValue = oldValueMap.value; //For EDGE-207353 on 14APR2021 by Vamsi
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "Marketable Offer") { //DIGI 32648 attribute.name === "Marketable Offer"
			CommonUtills.updateSolutionfromOffer(configuration.guid); //For EDGE-207353 on 14APR2021 by Vamsi
			//await CommonUtills.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue); //RF++ //Commented in DIGI-32648
		}
		//DIGI-23856 -- Hide TenancyButton button on selection of Intune Offer
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "Marketable Offer" && attribute.displayValue === "Adaptive Mobility Managed Services Modular - Endpoint Management Intune") {
            EMS_UI.updateAttributeVisiblity('TenancyButton', component.name, configuration.guid, false, false, false);
            EMS_UI.updateAttributeVisiblity('TenancyID', component.name, configuration.guid, false, true, true);
        }else{
            if(component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "Marketable Offer" && attribute.displayValue !== "Adaptive Mobility Managed Services Modular - Endpoint Management Intune"){
            EMS_UI.updateAttributeVisiblity('TenancyButton', component.name, configuration.guid, false, true, false);
                EMS_UI.updateAttributeVisiblity('TenancyID', component.name, configuration.guid, false, false, false);
        	}
    	}
        
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === 'ChangeType' && oldValueMap.value !== attribute.value && (attribute.value === 'Modify' || attribute.value === 'Cancel')) { //EDGE-154489
			changetypeMACsolution = attribute.value;
		}
		
		//Added for Cancel Story DPG-2648
		if (BasketChange === "Change Solution" && attribute.name === "ChangeType") {
			EMS_UI.updateCancellationAttributes(component.name, configuration.guid, attribute.value);
		}
		
		if (BasketChange === "Change Solution" && component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "DisconnectionDate") {
			EMS_Validation.validateDisconnectionDate(component.name, configuration.guid, attribute.value);
		}
		
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup" && attribute.value !== "") {
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(EMS_COMPONENT_NAMES.solutionname);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', EMS_COMPONENT_NAMES.tenancy, oldValue);
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
	} catch (error) {
		console.log('[EMS_Utils] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

//EDGE-154489
EMS_Utils.solutionAfterConfigurationAdd = async function (component, configuration) {
	try {
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId, configuration.guid);
				await CHOWNUtils.getParentBillingAccount(EMS_COMPONENT_NAMES.solution);
				
				if (parentBillingAccountATT) {
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		} //For EDGE-207353 on 14APR2021 by Vamsi ends
	} catch (error) {
		console.log('[EMS_Utils] solutionAfterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

EMS_Utils.solutionSetActive = async function() {
	try {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		
		if (currentSolution.name === EMS_COMPONENT_NAMES.solution) {
			//EDGE-198536 Start: existing code moved inside active solution check
            //EDGE-154489
			Utils.updateCustomButtonVisibilityForBasketStage();
			window.addEventListener("message", EMS_Utils.handleIframeMessage); //EDGE-198536 End: existing code moved inside active solution check
			//Changes as part of EDGE-154489 end here
			EMS_Utils.validationErrorActiveManagedServiceSubscriptionCheck(); //Krunal DPG-2577
			let currentBasket = await CS.SM.getActiveBasket();
			let loadedSolution = await CS.SM.getActiveSolution();
			basketId = currentBasket.basketId;
			window.currentSolutionName = loadedSolution.name;
			await CommonUtills.getSiteDetails(currentBasket); //RF++
			await CommonUtills.getBasketData(currentBasket); //RF++
			
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", false);
			} //RF for lock issue
			let product = await CS.SM.getActiveSolution();
			
			if (product) {
				let component = await product.getComponentByName(product.name);
				
				if (component) {
					let cmpConfig = await component.getConfigurations();
					
					if (product && Object.values(cmpConfig)[0].replacedConfigId) {
						window.BasketChange = "Change Solution";
					}
				}
			}
			if (accountId != null) {
				CommonUtills.setAccountID(EMS_COMPONENT_NAMES.solution, accountId);
			}
			//Added for making BillingAccount ReadOnly in MACD Journey DPG-2648 and DPG-4134
			if (loadedSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
				if (basketChangeType === "Change Solution" && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
					let componentMap = new Map();
					let componentMapattr = {};
					let billingAccLook = Object.values(loadedSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
					componentMapattr["BillingAccountLookup"] = [];
					componentMapattr["BillingAccountLookup"].push({
						IsreadOnly: true,
						isVisible: true,
						isRequired: false
					});
					componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
					await CommonUtills.attrVisiblityControl(EMS_COMPONENT_NAMES.solution, componentMap);
					
					if (billingAccLook.value === null || billingAccLook.value === "") {
						//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
						CommonUtills.setSubBillingAccountNumberOnCLI(EMS_COMPONENT_NAMES.solution, "BillingAccountLookup", true);
					}
				}
			}
			//Added for making BillingAccount ReadOnly in MACD Journey(DPG-2648) AND DPG-4134
			if (window.BasketChange === "Change Solution") {
				await CommonUtills.updateSolutionNameOnOLoad(EMS_COMPONENT_NAMES.solution); //For EDGE-207354 on 21APR2021 by Vamsi
				EMS_Utils.checkConfigurationSubscriptionsForMS('afterSolutionLoaded');
				await EMSPlugin_UpdateMainSolutionChangeTypeVisibility(loadedSolution);
            } //END DPG-2648
			//Aditya: Edge:142084 Enable New Solution in MAC Basket
			//Added by Aman Soni as a part of EDGE -148455 || End
			EMS_Utils.updateChangeTypeAttribute();
            EMS_Utils.populateRateCardinAttachmentEMS();
			Utils.loadSMOptions();
			EMS_UI.setChangeTypeVisibility(loadedSolution);
			
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
		}
	} catch (error) {
		console.log('[EMS_Utils] solutionSetActive() exception: ' + error);
		return false;
	}
	return true;
};

EMS_Utils.handleIframeMessage = function(e) {
	try {
		if (!e.data || !e.data["command"] || e.data["command"] !== "ADDRESS" || (e.data["caller"] && e.data["caller"] === EMS_COMPONENT_NAMES.solution)) {
			sessionStorage.removeItem("close");
			sessionStorage.removeItem("payload");
		} //Added as a part of EDGE-189788
		if (e.data && e.data["command"] && e.data["command"] === "RateCard" && e.data["caller"]) {
			CommonUtills.updateAttributeExpectedSIO(e.data['data'], e.data['guid'], e.data["caller"]); //Added as a part of EDGE-178214
		}
		var message = {};
		message = e["data"];
		message = message["data"];
		
		if (message.command && message.command === "TenancyIds") {
			if (message.caller && message.caller !== "Managed Services") {
				return;
			}
			if (message) {
				EMS_Utils.updateSelectedTenancyList(message["data"]);
			}
		}
		
		//Uncommented by Purushottam as a part of EDGE -145320 || Start
		if (e.data === "close") {
			try {
				var d = document.getElementsByClassName("mat-dialog-container");
				
				if (d) {
					for (var i = 0; i < d.length; i++) {
						d[i].parentElement.removeChild(d[i]);
					}
				}
				var el = document.getElementsByClassName("cdk-global-overlay-wrapper");
				
				if (el) {
					for (var i = 0; i < el.length; i++) {
						el[i].parentNode.removeChild(el[i]);
					}
				}
			} catch (err) {}
		}
	} catch (error) {
		console.log('[EMS_Utils] handleIframeMessage() exception: ' + error);
	}
};

/* function to update tenancyid attribute on solution level */
EMS_Utils.updateSelectedTenancyList = async function(data) {
	try {
		//--DPG-2647 -- start
		var t1 = "";
		var t2 = "";
		var configGuid = "";
		var tenancyIdss = ""; //--DPG-2647 -- end
		var tenancyIds = "";
		let updateMap = {}; //EDGE-154489
		let solution = await CS.SM.getActiveSolution(); //EDGE-154489
		let component = solution.getComponentByName(EMS_COMPONENT_NAMES.solution); //EDGE-154489
		var tenancyID = ""; //DPG-3036

		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			//changed solution.type to solution -EDGE-154489
			let cmpConfig = await solution.getConfigurations(); //RF++

			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				for (const config of Object.values(cmpConfig)) {
					tenancyIds = config.getAttribute("TenancyId"); //RF++
					t1 = tenancyIds.value;
					tenancyID = data.toString(); //DPG-3036
					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "TenancyId",
						value: data.toString(),
						displayValue: data.toString(),
						showInUi: false,
						readOnly: false
					});

					if (updateMap && Object.keys(updateMap).length > 0) {
						await component.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
					} //Changes as part of EDGE-154489 end
				}

				//--DPG-2647 -- Start
				if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
					for (const config of Object.values(solution.schema.configurations)) { //EDGE-154489
						configGuid = config.guid;
						tenancyIdss = Object.values(config.attributes).filter(a => { //EDGE-154489
							return a.name === 'TenancyID';
						});
						t2 = tenancyIdss[0].value;
					}
					let currentActiveBasket = await CS.SM.getActiveBasket();
					let profServCheck = 'Absent';
					let tmdmVMWareCheck = 'Absent';

					if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
						if (currentActiveBasket.solutions && Object.values(currentActiveBasket.solutions).length > 0) {
							for (const basketSol of Object.values(currentActiveBasket.solutions)) {
								if (basketSol.name === 'T-MDM Professional Services') {
									profServCheck = 'PFPresent';
								} else if (basketSol.name === 'Telstra Mobile Device Management - VMware') {
									tmdmVMWareCheck = 'TMDMPresent';
								}
							}
						}
					}
					if ((t2 === '' || t2 === null) && BasketChange != 'Change Solution') {
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
					} else if (tenancyIdss[0].name === 'TenancyID' && (t2 != '' || t2 != null) && tmdmVMWareCheck === 'Absent' && BasketChange != 'Change Solution') {
						EMS_Validation.validationActiveManagedServiceSubscriptionCheck(tenancyIdss[0], component, configGuid);
					}
					if ((t1 === '' || t1 === null || t2 === '' || t2 === null) && BasketChange === 'Change Solution') {
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
					}
					//Commented as a part of DPG-14770 by Akshay G
					/* else if (((t1 != null || t1 != '') || (t2 != null || t2 != '')) && (t1 != t2) && BasketChange === 'Change Solution' && profServCheck === 'Absent') {
						let confg = await component.getConfiguration(configGuid);
						confg.status = false;
						confg.statusMessage = 'Please add T-MDM Professional Services to the basket';
					} */
					else {
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
					}
				} //--DPG-2647 -- End
			}
			if (solution.components && Object.values(solution.components).length > 0) {
				//EDGE-154489
				for (const comp of Object.values(solution.components)) {
					//EDGE-154489
					if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
						let cmpConfig = await comp.getConfigurations(); //RF++

						if (cmpConfig && Object.values(cmpConfig).length > 0) {
							//RF++
							for (const config of Object.values(cmpConfig)) {
								let confgAttr = config.getAttributes(); //RF++

								if (confgAttr && Object.values(confgAttr).length > 0) {
									tenancyIds = config.getAttribute("TenancyId"); //RF++
									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: "TenancyId",
										value: data.toString(),
										displayValue: data.toString(),
										showInUi: false,
										readOnly: false
									});

									if (updateMap && Object.keys(updateMap).length > 0) {
										await component.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
									} //Changes as part of EDGE-154489 end
								}
							}
						}
					}
					if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
						let cmpConfig = await comp.getConfigurations(); //RF++

						if (cmpConfig && Object.values(cmpConfig).length > 0) {
							//RF++
							for (const config of Object.values(cmpConfig)) {
								let confgAttr = config.getAttributes(); //RF++

								if (confgAttr && Object.values(confgAttr).length > 0) {
									//RF++
									tenancyIds = config.getAttribute("TenancyId"); //RF++
									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: "TenancyId",
										value: data.toString(),
										displayValue: data.toString(),
										showInUi: false,
										readOnly: false
									});

									if (updateMap && Object.keys(updateMap).length > 0) {
										await component.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
									} //Changes as part of EDGE-154489 end
								}
							}
						}
					}
				}
			}
			MSUtils.setTenancyIdForProffesionalService(tenancyID); //DPG-3036
		}
	} catch (error) {
		console.log('[EMS_Utils] updateSelectedTenancyList() exception: ' + error);
	}
};

/*********************************
* Author	: Krunal Taak
* Method Name : validation Active Managed Service Subscription Check - On Load
* Defect/US # : DPG-2577
* Invoked When: Onload and Aftersave
* Description :validation Active Managed Service Subscription Check
*********************************/
EMS_Utils.validationErrorActiveManagedServiceSubscriptionCheck = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.schema.configurations).forEach((subsConfig) => {
					var checkTenancy = Object.values(subsConfig.attributes).filter(att => {
						return att.name === 'CheckTenancyError';
					});
					
					if (checkTenancy[0].value === true) {
						subsConfig.status = false;
						subsConfig.statusMessage = 'Please select a different tenancy or add a new tenancy';
					} else {
						subsConfig.status = true;
						subsConfig.statusMessage = '';
					}
				});
			}
		}
	} catch (error) {
		console.log('[EMS_Utils] validationErrorActiveManagedServiceSubscriptionCheck() exception: ' + error);
	}
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : checkConfigurationSubscriptionsForMS
* Defect/US # : DPG-1914
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of MS to Cancel
*********************************/
EMS_Utils.checkConfigurationSubscriptionsForMS = async function(hookname) {
	try {
		var solutionComponent = false;
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.componentType && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
				solutionComponent = true;
				EMS_Utils.checkConfigurationSubscriptionsForMSForEachComponent(solution, solutionComponent, hookname, solution);
			}
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = false;
					EMS_Utils.checkConfigurationSubscriptionsForMSForEachComponent(comp, solutionComponent, hookname, solution);
				});
			}
		}
	} catch (error) {
		console.log('[EMS_Utils] checkConfigurationSubscriptionsForMS() exception: ' + error);
	}
	return Promise.resolve(true);
};

/*********************************
* Author	  : Monali Mukherjee
* Method Name : checkConfigurationSubscriptionsForMSForEachComponent
* Defect/US # : DPG-2648
* Invoked When: Raised MACD on Active Subscription
* Description : Update the Change Type of MS to Cancel
*********************************/
EMS_Utils.checkConfigurationSubscriptionsForMSForEachComponent = async function(comp, solutionComponent, hookname, solution) { //Krunal
	try {
		var componentMap = {};
		var updateMap = {};
		var ComName = comp.name;
		var optionValues = {};
		
		if (comp.name == EMS_COMPONENT_NAMES.solution) {
			optionValues = [{
				"value": "Cancel",
				"label": "Cancel"
			}, {
				"value": "Modify",
				"label": "Modify"
			}];
		}
		if (solutionComponent) {
			var cta = '';
			
			if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				for (const config of Object.values(comp.schema.configurations)) {
					cta = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType';
					});
				}
			}
			componentMap[comp.name] = [];
			componentMap[comp.name].push({
				'id': Object.values(comp.schema.configurations)[0].replacedConfigId,
				'guid': Object.values(comp.schema.configurations)[0].guid,
				'ChangeTypeValue': cta[0].value
			});
		} else if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			Object.values(comp.schema.configurations).forEach((config) => {
				if (config.replacedConfigId || config.id) {
					var cta = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
					
					if (cta && cta.length > 0) {
						if (!componentMap[comp.name]) {
							componentMap[comp.name] = [];
						}
						if (config.replacedConfigId) {
							componentMap[comp.name].push({
								'id': config.replacedConfigId,
								'guid': config.guid,
								'ChangeTypeValue': cta[0].value
							});
						} else {
							componentMap[comp.name].push({
								'id': config.id,
								'guid': config.guid,
								'ChangeTypeValue': cta[0].value
							});
						}
					}
				}
			});
		}
		if (Object.keys(componentMap).length > 0) {
			var parameter = '';
			Object.keys(componentMap).forEach(key => {
				if (parameter) {
					parameter = parameter + ',';
				}
				parameter = parameter + componentMap[key].map(e => e.id).join();
			});
			
			let inputMap = {};
			inputMap['GetSubscriptionForConfiguration'] = parameter;
			var statuses;
			let currentBasket = await CS.SM.getActiveBasket();
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				if (values['GetSubscriptionForConfiguration']) {
					statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
				}
			});
			
			if (statuses) {
				Object.keys(componentMap).forEach(comp => {
					componentMap[comp].forEach(element => {
						var statusValue = 'New';
						var CustomerFacingId = '';
						var CustomerFacingName = '';
						var status = statuses.filter(v => {
							return v.csordtelcoa__Product_Configuration__c === element.id;
						});
						
						if (status && status.length > 0) {
							statusValue = status[0].csord__Status__c;
						}
						if (element.ChangeTypeValue !== 'Cancel' && element.ChangeTypeValue !== 'Modify' && (statusValue === 'Suspended' || statusValue === 'Active' || statusValue === 'Pending')) {
							updateMap[element.guid] = [{
								name: 'ChangeType',
								options: optionValues,
								value: statusValue,
								displayValue: statusValue
							}];
						}
						if (element.ChangeTypeValue === 'Pending') {
							updateMap[element.guid] = [{
								name: 'ChangeType',
								readOnly: true
							}];
						}
					});
					
					if (updateMap && Object.values(updateMap).length > 0) {
						let component = solution.getComponentByName(comp);
						let keys = Object.keys(updateMap);
						
						for (let i = 0; i < keys.length; i++) {
							component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						return Promise.resolve(true);
					}
				});
			}
		}
	} catch (error) {
		console.log('[EMS_Utils] checkConfigurationSubscriptionsForMSForEachComponent() exception: ' + error);
	}
	return Promise.resolve(true);
};

EMS_Utils.updateChangeTypeAttribute = async function(fromAddToMacBasket = false) {
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach(async (comp) => {
					var updateMap = [];
					var doUpdate = false;
					
					if ((comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0) {
								Object.values(config.attributes).forEach((attribute) => {
									if (attribute.name === 'ChangeType') {
										doUpdate = true;
										var changeTypeValue = attribute.value;
										
										if (!updateMap[config.guid]) {
											updateMap[config.guid] = [];
										}
										if (!window.BasketChange === 'Change Solution' || (config.replacedConfigId === '' || config.replacedConfigId === undefined || config.replacedConfigId === null)) {
											if (!changeTypeValue) {
												changeTypeValue = 'New';
											}
											updateMap[config.guid].push({
												name: attribute.name,
												value: changeTypeValue,
												displayValue: changeTypeValue,
												showInUi: false,
												readOnly: true});
										} else {
											//Start: DPG-3632 - Added handling for the MACD Basket
											var readonly = true;
                                            var showInUI = true;
                                            updateMap[config.guid].push({
												name: attribute.name,
												showInUi: showInUI,
												readOnly: readonly});
										} //End: DPG-3632
									}
								});
							}
						});
					}
					if ((comp.name === EMS_COMPONENT_NAMES.userSupport) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0) {
								Object.values(config.attributes).forEach((attribute) => {
									if (attribute.name === 'ChangeType') {
										doUpdate = true;
										var changeTypeValue = attribute.value;
										
										if (!updateMap[config.guid]) {
											updateMap[config.guid] = [];
										}
										if (!window.BasketChange === 'Change Solution' || (config.replacedConfigId === '' || config.replacedConfigId === undefined || config.replacedConfigId === null)) {
											if (!changeTypeValue) {
												changeTypeValue = 'New';
											}
											updateMap[config.guid].push({
												name: attribute.name,
												value: changeTypeValue,
												displayValue: changeTypeValue,
												showInUi: false,
												readOnly: true});
										} else {
											//Start: DPG-3632 - Added for the MACD basket
											var readonly = true;
											var showInUI = true;updateMap[config.guid].push({
												name: attribute.name,
												showInUi: showInUI,
												readOnly: readonly});
										} //End: DPG-3632
									}
								});
							}
						});
					}
					if (doUpdate) {
						let keys = Object.keys(updateMap);
						var complock = comp.commercialLock;
						
						if (complock) {
							comp.lock('Commercial', false);
						}
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						if (complock) {
							comp.lock('Commercial', true);
						}
					}
				});
			}
		}
	} catch (error) {
		console.log('[EMS_Utils] updateChangeTypeAttribute() exception: ' + error);
	}
};

/*********************************
* Author	  : Venkata Ramanan G
* Method Name : populateRateCardinAttachmentEMS
* Invoked When: after solution is loaded
*********************************/
EMS_Utils.populateRateCardinAttachmentEMS = async function() {
	try {
		if (basketStage !== "Contract Accepted") {
			return;
		}
		let currentSolution = await CS.SM.getActiveSolution(); //RF--
		
		//Changes as part of EDGE-154489
		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution) && currentSolution.components && Object.values(currentSolution.components).length > 0) {
			//changed from currentSolution.type to currentSolution //EDGE-154489
			let comp = await currentSolution.getComponentByName(EMS_COMPONENT_NAMES.mobilityPlatformMgmt);
			
			if (comp) {
				let cmpConfig = await comp.getConfigurations(); //RF++
				
				if (cmpConfig && Object.values(cmpConfig).length > 0) {
					//RF++
					let inputMap = {};
					inputMap["basketid"] = basketId;
					inputMap["Offer_Id__c"] = "DMCAT_Offer_000854";
					inputMap["SolutionId"] = currentSolution.id;
				} //RF++
			} //RF++
		}
	} catch (error) {
		console.log('[EMS_Utils] populateRateCardinAttachmentEMS() exception: ' + error);
	}
};

//DPG-3036 START
var MSUtils = {
	setTenancyIdForProffesionalService: async function(tenancyID) {
		var updateMap = {};
		var isMsPresent;
		let currentBasket = await CS.SM.getActiveBasket();
		let solution = currentBasket.solutions;
		
		if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
			for (const basketSol of Object.values(currentBasket.solutions)) {
				if (basketSol.name === PSMDM_COMPONENT_NAMES.solution) {
					let component = basketSol.getComponentByName(PSMDM_COMPONENT_NAMES.solution);
					let cmpConfig = await basketSol.getConfigurations();
					
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							let confgAttr = config.getAttributes();
							
							if (confgAttr && Object.values(confgAttr).length > 0) {
								updateMap[config.guid] = [];
								updateMap[config.guid].push({
									name: "TenancyID",
									value: tenancyID,
									displayValue: tenancyID
								});
								
								if (updateMap && Object.keys(updateMap).length > 0) {
									await component.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
								}
							}
						}
					}
					if (basketSol.components && Object.values(basketSol.components).length > 0) {
						for (const comp of Object.values(basketSol.components)) {
							if (comp.name === PSMDM_COMPONENT_NAMES.UC) {
								let cmpConfig = await comp.getConfigurations();
								
								if (cmpConfig && Object.values(cmpConfig).length > 0) {
									for (const config of Object.values(cmpConfig)) {
										let confgAttr = config.getAttributes();
										
										if (confgAttr && Object.values(confgAttr).length > 0) {
											updateMap[config.guid] = [];
											updateMap[config.guid].push({
												name: "TenancyID",
												value: tenancyID,
												displayValue: tenancyID
											});
											
											if (updateMap && Object.keys(updateMap).length > 0) {
												await component.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};