/*
 * Handles all UI-related logic
 */
console.log('[IoTConn_UI] loaded');

const IOTCONN_UI = {};

IOTCONN_UI.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		let loadedSolution = await CS.SM.getActiveSolution();
		
		if (window.basketStage === "Contract Accepted") {
			loadedSolution.lock("Commercial", false);
			
			if (component.name === 'Customer requested Dates') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			if (component.name === 'Delivery details' && attribute.name === 'DeliveryContact') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			if (component.name === 'Delivery details' && attribute.name === 'DeliveryAddress') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
		}
		if (component.name === IOTCONNECTIVITY_COMPONENTS.iotPlans && attribute.name === "OfferType") {
			if (attribute.displayValue) {
				await IOTCONN_UI.updateAttributeVisiblity(["IoTPlansRateCardButton"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, true, false);
			} else {
				await IOTCONN_UI.updateAttributeVisiblity(["IoTPlansRateCardButton"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, false, false);
			}
			
			if (attribute.displayValue === sharedDataPlan) {
				await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, true, false);
			} else {
				await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, false, false);
			}
			 if (window.BasketChange === "Change Solution" && attribute.name === "ChangeType") {
                IOTCONN_UI.UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
            }
			let solnName = loadedSolution.solutionName;
			let originalSolutionName = solnName.indexOf("_") != -1 ? solnName.substring(0, solnName.indexOf("_")) : solnName;
			
			if (attribute.value) {
				CommonUtills.genericUpdateSolutionName(component, configuration, originalSolutionName + "_" + attribute.displayValue, originalSolutionName + "_" + attribute.displayValue);
			}
		}
		       ///DIGI-9672
        if (component.name === IOTCONNECTIVITY_COMPONENTS.iotPlans && attribute.name === "SharedPlan") {
                let product = component;
                if (product.componentType && product.name === IOTCONNECTIVITY_COMPONENTS.iotPlans) {
                    let configs = product.getConfigurations();
                    Object.values(configs).forEach(async (config) => {
                        let priceItem = config.getAttribute("SharedPlan");
                        let priceItemid = null;
                        if (priceItem) {
                            priceItemid = priceItem.value;
                        }
    
                        if (config.guid == configuration.guid) {
                            let inputMap = {};
    
                            if (priceItemid !== "") {
                                inputMap["priceItemId"] = priceItemid;
                            }
                            let allowanceRecId = null;
                            let allowanceValue = null;
    
                            let currentBasket = await CS.SM.getActiveBasket();
    
                            await currentBasket.performRemoteAction("SolutionGetAllowanceData", inputMap).then((response) => {
                                if (response && response["allowances"] != undefined) {
                                    response["allowances"].forEach(async (a) => {
                                        allowanceRecId = a.cspmb__allowance__c;
                                        allowanceRecName = a.cspmb__allowance__r.Name;
                                        allowanceValue = a.cspmb__allowance__r.Value__c + " " + a.cspmb__allowance__r.Unit_Of_Measure__c;
                                        allowanceExternalId = a.cspmb__allowance__r.External_Id__c;
                                        allowanceEndDate = a.cspmb__allowance__r.endDate__c;
    
    
                                        let updateConfigMap = new Map();
                                        let planAttribute = config.getAttribute("PlanAllowance");
                                        let planAttributeVal = config.getAttribute("PlanAllowanceValue");
                                        if (planAttribute && allowanceRecId != "") {
                                            updateConfigMap.set(config.guid, [
                                                {
                                                    name: "PlanAllowance",
                                                    value: allowanceRecId,
                                                    displayValue: allowanceRecId
                                                }
                                            ]);
                                        } else if (planAttributeVal && allowanceValue != "") {
                                            updateConfigMap.set(config.guid, [
                                                {
                                                    name: "PlanAllowanceValue",
                                                    value: allowanceValue,
                                                    displayValue: allowanceValue
                                                }
                                            ]);
                                           // datapackallowance = allowanceValue;
                                        }
                                        updateConfigMap.forEach(async (v, k) => {
                                            await product.updateConfigurationAttribute(k, v, true);
                                        });
                                    });
                                }
                            });
                        }
                    });
                }
            }
		//Added for PricingService
		PRE_Logic.afterAttributeUpdated(component, configuration, attribute, oldValueMap.value, attribute.value);
		
		        await IOTCONN_Utils.checkQuantityForNBiotSimType(loadedSolution);

	} catch (error) {
		console.log('[IoTConn_UI] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

IOTCONN_UI.afterSave = async function(result) {
	try {
		let solution = result.solution;
		
		if (window.basketStage === "Contract Accepted") {
			solution.lock("Commercial", false);
		}
		Utils.updateCustomButtonVisibilityForBasketStage();
		await IOTCONN_UI.checkConfigurationSubscriptionsForIOTPlans(solution);
		await IOTConnectivityPlugin_updateChangeTypeAttribute(solution);

		if (window.BasketChange === "Change Solution") {
                await IOTCONN_UI.UpdateMainSolutionChangeTypeVisibility(solution);
                await IOTCONN_UI.UpdateAttributesForMacdOnSolution(solution);
                await IOTCONN_UI.UpdateAttributesForSubscription(solution);
            }
		await IOTCONN_UI.updateAttributesForSharedDataPlan(solution);
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails();
		//Added for PricingService
		await updatePREDiscountAttribute();
	} catch (error) {
		console.log('[IoTConn_UI] afterSave() exception: ' + error);
		return false;
	}
	return true;
};
     //Added for PricingService
    IOTCONN_UI.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids,attribute) {	
    let component = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
        let configs ='';
        if(component){
            configs = component.getConfigurations();
            if(configs[0].status == false){
                return Promise.resolve(false);
                }
            }
            
        PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
    
        return Promise.resolve(true);
    };

IOTCONN_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
	try {
		let updateMap = {};
		updateMap[guid] = [];
		attributeName.forEach((attribute) => {
			updateMap[guid].push({
				name: attribute,
				readOnly: isReadOnly,
				showInUi: isVisible,
				required: isRequired
			});
		});
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName);
		
		if (component) {
			let complock = component.commercialLock;
			
			if (complock) {
				component.lock("Commercial", false);
			}
			await component.updateConfigurationAttribute(guid, updateMap[guid], true);
			
			if (complock) {
				component.lock("Commercial", true);
			}
		}

	} catch (error) {
		console.log('[IoTConn_UI] updateAttributeVisiblity() exception: ' + error);
	}
};

IOTCONN_UI.updateAttributesForSharedDataPlan = async function(solution) {
	try {
		if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.iotPlans)) {
			let configs = solution.getConfigurations();
			
			if (configs) {
				Object.values(configs).forEach(async (config) => {
					let attr = config.getAttribute("OfferType");
					
					if (attr && attr.displayValue === sharedDataPlan) {
						await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, false);
					}
				});
			}
		}
	} catch (error) {
		console.log('[IoTConn_UI] updateAttributesForSharedDataPlan() exception: ' + error);
	}
	return Promise.resolve(true);
};
   IOTConnectivityPlugin_updateChangeTypeAttribute = async (solution) => {
        if (solution && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
            let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
            if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                let updateMap = new Map();
                let doUpdate = false;
    
                Object.values(comp.schema.configurations).forEach((config) => {
                            let attribute = config.getAttribute("ChangeType");
                            if (attribute) {
                                doUpdate = true;
                                let changeTypeValue = attribute.value;
    
    
                                if (!window.BasketChange || !config.replacedConfigId) {
                                    if (!changeTypeValue) {
                                        changeTypeValue = "New";
                                    }
                            updateMap.set(config.guid, [
                                {
                                        name: attribute.name,
                                        value: changeTypeValue,
                                        displayValue: changeTypeValue,
                                        showInUi: false,
                                        readOnly: true
                                }
                            ]);
                        } else {
                            updateMap.set(config.guid, [
                                {
                                    name: attribute.name,
                                    showInUi: true,
                                    readOnly: false
                                }
                            ]);
                        }
                    }
                });
    
    
                    if (doUpdate && updateMap) {
                        updateMap.forEach(async (v, k) => {
                            await comp.updateConfigurationAttribute(k, v, true);
                        });
                    }
                }
            }
    
    
        return Promise.resolve(true);
    };                                     
       IOTCONN_UI.afterConfigurationAddedToMacBasket = async (componentName, guid) => {
            // Arinjay Start - EDGE 221460
            try {
                  CommonUtills.UpdateRelatedConfigForChildMac(guid,componentName,null);
            } catch (error) {
                console.log(error);
            }
             // Arinjay End - EDGE 221460                       
         
            let solution = await CS.SM.getActiveSolution();
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                IOTConnectivityPlugin_updateChangeTypeAttribute(solution);
                await IOTCONN_UI.checkConfigurationSubscriptionsForIOTPlans(solution);
    			CommonUtills.CloneOrderEnrichment(componentName, guid); // Added By vijay DIGI-456

    		 if (window.BasketChange === "Change Solution") {
                    await IOTCONN_UI.UpdateSubscriptionChangeTypeVisibility(solution);
                    let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                    if (comp) {
                        await validateOERules.resetCRDDatesinOESchema_ALL(solution.name, comp.name);
                    }
                } 
            }
            return Promise.resolve(true);
        };
                           		
		IOTCONN_UI.UpdateMainSolutionChangeTypeVisibility = async (solution) => {
            if (window.BasketChange !== "Change Solution") {
                return;
            }
    
            let updateMap = new Map();
            let configs = solution.getConfigurations();
            let configGuid = configs[0].guid;
    
            updateMap.set(configGuid, [
                {
                    name: "ChangeType",
                    showInUi: true
                }
            ]);
    
            await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.solutionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.solutionname, configGuid, true, true, false);
    
            let activeSolution = await CS.SM.getActiveSolution();
            let component = await activeSolution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.solutionname);
            if (updateMap) {
                updateMap.forEach(async (v, k) => {
                    await component.updateConfigurationAttribute(k, v, true);
                });
            }
        };
                    
         IOTCONN_UI.checkConfigurationSubscriptionsForIOTPlans = async function(solution) {
        let componentMap = {};
        let updateMap = new Map();
       // let solution = await CS.SM.getActiveSolution();
        let optionValues = ["New", "Modify", "Cancel"];
    
    
        if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
            let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
            if (comp) {
                let configs = comp.getConfigurations();
                if (configs) {
                    Object.values(configs).forEach((config) => {
                        if (config.replacedConfigId || config.id) {
                            let cta = config.getAttribute("ChangeType");
                            if (cta) {
                                if (config.replacedConfigId && (config.id == null || config.id == "")) {
                                    componentMap[comp.name] = [
                                        {
                                        id: config.replacedConfigId,
                                        guid: config.guid,
                                        needUpdate: "Yes",
                                        ChangeTypeValue: cta.value
                                        }
                                    ];
                                } else if (config.replacedConfigId) {
                                    componentMap[comp.name] = [
                                        {
                                        id: config.replacedConfigId,
                                        guid: config.guid,
                                        needUpdate: "No",
                                        ChangeTypeValue: cta.value
                                        }
                                    ];
                                } else {
                                    componentMap[comp.name] = [
                                        {
                                        id: config.id,
                                        guid: config.guid,
                                        needUpdate: "No",
                                        ChangeTypeValue: cta.value
                                        }
                                    ];
                                }
                            }
                        }
                    });
                }
            }
        }
    
    
        if (Object.keys(componentMap).length > 0) {
            let parameter = "";
            Object.keys(componentMap).forEach((key) => {
                if (parameter) {
                    parameter = parameter + ",";
                }
                parameter = parameter + componentMap[key].map((e) => e.id).join();
            });
    
            let inputMap = {};
            inputMap["GetSubscriptionForConfiguration"] = parameter;
            let stats;
    
            let currentBasket = await CS.SM.getActiveBasket();
            await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
                if (values["GetSubscriptionForConfiguration"]) {
                    stats = JSON.parse(values["GetSubscriptionForConfiguration"]);
                }
            });
    
    
            if (stats) {
                Object.keys(componentMap).forEach(async (comp) => {
                    componentMap[comp].forEach((element) => {
                        let statusValue = "New";
                        let CustomerFacingId = "";
                        let status = stats.find((v) => v.csordtelcoa__Product_Configuration__c === element.id);
                        if (status) {
                            statusValue = status.csord__Status__c;
                            CustomerFacingId = status.serviceMSISDN__c;
                        }
    
    
                        if (element.ChangeTypeValue !== "New" && element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") {
                            const found = optionValues.find((element) => element === statusValue);
                            if (!found) {
                                optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34 upgrade
                            }
                            updateMap.set(element.guid, [
                                {
                                    name: "ChangeType",
                                    options: optionValues,
                                    showInUi: true,
                                    value: statusValue,
                                    displayValue: statusValue
                                },
                                {
                                    name: "CustomerFacingServiceId",
                                    value: CustomerFacingId,
                                    displayValue: CustomerFacingId
                                }
                            ]);
                        } else {
                            updateMap.set(element.guid, [
                                {
                                    name: "CustomerFacingServiceId",
                                    value: CustomerFacingId,
                                    displayValue: CustomerFacingId
                                }
                            ]);
                        }
                    });
    
    
                    if (updateMap) {
                        let component = solution.getComponentByName(comp);
                        updateMap.forEach(async (v, k) => {
                            await component.updateConfigurationAttribute(k, v, true);
                        });
    
    
                        return Promise.resolve(true);
                    }
                });
            }
        }
    
        return Promise.resolve(true);
    }
        IOTCONN_UI.afterOrderEnrichmentConfigurationAdd = (componentName, configuration, orderEnrichmentConfiguration) => {
            window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
            return Promise.resolve(true);
        };
                    
        IOTCONN_UI.afterSolutionDelete = (solution) => {
            CommonUtills.updateBasketStageToDraft();
            //Added for PricingService
            refreshPricingSummeryWidget();
            return Promise.resolve(true);
        };
                    
         //Added for PricingService
    IOTCONN_UI.afterConfigurationDelete = function (componentName, configuration) {
        PRE_Logic.afterConfigurationDelete(componentName,configuration);
        return Promise.resolve(true);
    };
		    IOTCONN_UI.UpdateAttributesForMacdOnSolution = async (solution) => {
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                let configs = solution.getConfigurations();
                if (configs) {
                    let attr = configs[0].getAttribute("ChangeType");
                    if (attr && attr.displayValue === "Cancel") {
                        await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.solutionname, Object.values(configs)[0].guid, false, true, true);
                    } else {
                        await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.solutionname, Object.values(configs)[0].guid, false, false, false);
                        Utils.emptyValueOfAttribute(Object.values(configs)[0].guid, IOTCONNECTIVITY_COMPONENTS.solutionname, "CancellationReason", false);
                    }
                }
    
    
                let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    Object.values(comp.schema.configurations).forEach(async (config) => {
                            let attr = config.getAttribute("ChangeType");
                            if (attr && attr.value === "Cancel") {
                                await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, true);
                                await IOTCONN_UI.updateAttributeVisiblity(["DisconnectionDate"], IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, true);
                            }
                        });
                    }
                }
            return Promise.resolve(true);
        };
    
         IOTCONN_UI.UpdateAttributesForSubscription = async (solution) => {
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    Object.values(comp.schema.configurations).forEach(async (config) => {
                            let attr = config.getAttribute("ChangeType");
                            if (attr && attr.value === "Cancel") {
                                await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.showSubscriptionFieldsForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, true, true, true);
                            }
                            if (window.BasketChange == "Change Solution") {
                                await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, true, true, false);
                            }
                        });
                    }
                }
            return Promise.resolve(true);
        };
                  IOTCONN_UI.UpdateSubscriptionChangeTypeVisibility = async (solution) => {
            if (window.BasketChange !== "Change Solution") {
                return;
            }
            let configGuid = '';
            let updateMap = new Map();
            let component = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                    if(component){
                    let configs = component.getConfigurations();
                    configGuid = configs[0].guid;
                }
                 
            updateMap.set(configGuid, [
                {
                    name: "ChangeType",
                    showInUi: true
                },
                {
                    name: "Quantity",
                    value: ""
                   }
            ]);
    
            await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, configGuid, true, true, false);
            if (updateMap) {
                updateMap.forEach(async (v, k) => {
                    await component.updateConfigurationAttribute(k, v, true);
                });
            }
        };
		     IOTCONN_UI.UpdateCancellationAttributes = async (componentName, guid, changeTypeValue) => {
            if (changeTypeValue === "Cancel") {
                await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, true, true);
                await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.solutionNonEditableAttributeListForCancel, componentName, guid, true, true, false);
            } else if (changeTypeValue === "Cancel" && componentName === IOTCONNECTIVITY_COMPONENTS.iotPlans) {
                await IOTCONN_UI.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, true, true);
            } else if ((changeTypeValue === "Modify" || changeTypeValue === "New") && componentName === IOTCONNECTIVITY_COMPONENTS.iotPlans) {
                await IOTCONN_UI.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, false, false);
                await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
                await IOTCONN_UI.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, componentName, guid, false, true, false);
            } else if (changeTypeValue !== "Cancel") {
                await IOTCONN_UI.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
                Utils.emptyValueOfAttribute(guid, IOTCONNECTIVITY_COMPONENTS.solutionname, "CancellationReason", true);
            }
        };

IOTCONN_UI.addEventListenerClick = async function(e) {
	try {
		e = e || window.event;
		let target = e.target;
		let text = target.textContent || target.innerText;
		let loadedSolution = await CS.SM.getActiveSolution(); // DIGI-35953                   
		
		if (text && text.toLowerCase() === "iot plans") {          
			if (window.basketStage === "Contract Accepted") {
				Utils.updateComponentLevelButtonVisibility("Add IoT Plans", false, true);
			}
			Utils.updateCustomButtonVisibilityForBasketStage();
		}
		if (text && text.toLowerCase().includes("stage")) {
			Utils.updateCustomButtonVisibilityForBasketStage();
			
			if (window.basketStage === "Contract Accepted") {            
				Utils.updateComponentLevelButtonVisibility("Add IoT Plans", false, true);    
             }
		}
		if (text) {
			Utils.updateOEConsoleButtonVisibility();
		} 
        	
		//Aruna Aware - INC000094520467 IoT - UX Individual subscription level reservation is not required for IoT and should not be visible to the user
		if (selectedSolutionName === "IoT Plans") {
			let buttons = document.getElementsByClassName("slds-file-selector__dropzone");
			let vertDropDownButton = document.getElementsByClassName("cs-btn");
			
			if (buttons) {
				for (let i = 0; i < buttons.length; i++) {
					let button = buttons[i];
					button.style.display = "none";
				}
			}
			if (vertDropDownButton) {
				for (let i = 0; i < vertDropDownButton.length; i++) {
					let vbutton = vertDropDownButton[i];
					
					if (vbutton.innerText.toLowerCase() === "order enrichment") {
						vbutton.style.display = "none";
					} else {
						vbutton.style.display = "compact";
					}
				}
			}
		}

        //Pawan Singh - DIGI-35953 to lock the basket after order enrichment pop up closed     
        if (window.basketStage === "Contract Accepted") {
			  loadedSolution.lock("Commercial", true);
        }
	} catch (error) {
		console.log('[IoTConn_UI] addEventListenerClick() exception: ' + error);
	}
}; 