/******************************************************************************************
* Author	   : DPG Neon
Change Version History
Version No	Author 			        Date


1 			Aditeyn                 Dec 2019          Created File for IOT 
2           Suyash Chiplunkar       01-03-2020        Cancel Flow for IOT DPG-970
3           Suyash Chiplunkar       23-04-2020        Shared Data Plan for IOT DPG-1132
4           Aruna Aware             23-04-2020        Added functionality for EDMListToDecompose attribute DPG-1132
5           Aruna Aware             05-05-2020        Added for bulk enrichment DPG-1692 & DPG-1723
6           Suyash Chiplunkar       20-05-2020        Added logic for Modify MAC DPG-1779
7           Anand Shekhar           20-05-2020        Added logic for DPG-1784 and DPG-1787
8           Sukul Mongia            25-06-2020        Spring 20 Upgrade
9           Suyash Chiplunkar       01-07-2020        Added logic for DPG-1964 Rate Card Matrix
10			Aruna Aware				16-07-2020		  Added logic for DPG-2130 Consistent use of the word "IoT" in Sales screens
11			Aruna Aware				16-07-2020		  Added logic for DPG-2131 Solution Name Validation for IoT
12 			Gnana & Aditya			19-Jul-2020		  Spring'20 Upgrade
13          Gaurang Maheshwari      02-Oct-2020       Code Optimization

14          Sandip Deshmane         08-Oct-2020       Changed for PricingService
15          Aruna Aware				1-Dec-2020		  DPG-3385 - Errors in YVW basket subscription fields
16			Aruna Aware				2-Dec-2020		  INC000094520467 IoT - UX Individual subscription level reservation is not required for IoT and should not be visible to the user
17.         Antun Bartonicek        01/06/2021        EDGE-198536: Performance improvements
18.         Aditya Pareek           04/10/2021        Updating Option Values as per CS R34 Upgrade
*****************************************************************************************/
var IOTMobility_COMPONENTS = {
    solution: "IoT solutions",
    IOTSubscription: "IoT Subscription",
    solutionNonEditableAttributeListForCancel: ["OfferName", "OfferType"],
    subscriptionNonEditableAttributeListForCancel: ["SelectPlanType", "Select Plan"],
    hidesubscriptionHideFieldsForCancel: ["SIM Type", "OC"],
    showSubscriptionFieldsForCancel: ["EarlyTerminationCharge"],
    comittedDataSolutionEditableFields: ["SharedPlan"],

    //Removed the RC variable from below array as per the New Pricing Services Changes 
    comittedDataSolutionNonEditableFields: ["PlanAllowanceValue"],
	//Aruna Aware - DPG-3385 - Errors in YVW basket subscription fields
	//annualDataPlanSubscriptionFields: ["MaintenanceRC", "RC"]
};
var sharedDataPlan = "Shared Data";
//Aruna Aware - INC000094520467 IoT - UX Individual subscription level reservation is not required for IoT and should not be visible to the user
var selectedSolutionName = '';

if (CS.SM.registerPlugin) {
    window.document.addEventListener("SolutionConsoleReady", async () => {
        await CS.SM.registerPlugin(IOTMobility_COMPONENTS.solution).then(async (IOTPlugin) => {
            IOTPlugin_updatePlugin(IOTPlugin);
        });
    });
}


const IOTPlugin_updatePlugin = async (IOTPlugin) => {
    window.document.addEventListener("SolutionSetActive", async (e) => {
        let loadedSolution = await CS.SM.getActiveSolution();
        if (loadedSolution.componentType && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //EDGE-198536 Start: existing code moved inside active solution check
			document.addEventListener(
				"click",
				function(e) {
					e = e || window.event;
					let target = e.target;
					let text = target.textContent || target.innerText;
				    if (text && text.toLowerCase() === "iot subscription") {
						if (window.basketStage === "Contract Accepted") {
							Utils.updateComponentLevelButtonVisibility("Add IoT Subscription", false, true);
						}
						Utils.updateCustomButtonVisibilityForBasketStage();
					}
				    if (text && text.toLowerCase().includes("stage")) {
						Utils.updateCustomButtonVisibilityForBasketStage();
						if (window.basketStage === "Contract Accepted") {
							Utils.updateComponentLevelButtonVisibility("Add IoT Subscription", false, true);
						}
					}
					if (text) {
						Utils.updateOEConsoleButtonVisibility();
					}
					//if (currentSolutionName === "IoT solutions") {
					//Aruna Aware - INC000094520467 IoT - UX Individual subscription level reservation is not required for IoT and should not be visible to the user
					if (selectedSolutionName === "IoT solutions") {
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
								if (vbutton.innerText.toLowerCase() === "order enrichment") vbutton.style.display = "none";
								else vbutton.style.display = "compact";
							}
						}
					}
				},
				false
			);
			//EDGE-198536 End: existing code moved inside active solution check//Aruna Aware - INC000094520467 IoT - UX Individual subscription level reservation is not required for IoT and should not be visible to the user
        	selectedSolutionName = loadedSolution.name;
            let basketId = e.detail.solution.basketId;
            let currentBasket = await CS.SM.loadBasket(basketId);

            await CommonUtills.getBasketData(currentBasket);
            if (window.basketStage === "Contract Accepted") {
                loadedSolution.lock("Commercial", false);
            }
			CommonUtills.setBasketChange();
            await addDefaultIOTConfigs();
            if (window.accountId != null) {
                await CommonUtills.setAccountID(IOTMobility_COMPONENTS.solution, window.accountId);
            }
            Utils.loadSMOptions();
            Utils.updateOEConsoleButtonVisibility();
            //await checkConfigurationSubscriptionsForIOT();
            //await IOTPlugin_updateChangeTypeAttribute();

            if (window.BasketChange === "Change Solution") {
                await IOTPlugin.updateStatusAfterSolutionLoad();
                await IOTPlugin.UpdateMainSolutionChangeTypeVisibility(loadedSolution);
                //await IOTPlugin.UpdateAttributesForSubscription(loadedSolution);
            }

            await IOTPlugin.UpdateAttributesForSharedDataPlan(loadedSolution);
            let solutionComponent = false;
            let componentMap = new Map();
            let componentMapattr = {};

            if (loadedSolution.componentType && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
                let config = Object.values(loadedSolution.getConfigurations())[0];
                if (config && config.replacedConfigId) {
                    solutionComponent = true;


					let billingAccLook = Object.values(config.attributes).find((a) => a.name === "BillingAccountLookup");
                    if (billingAccLook.value === null || billingAccLook.value === "") {
                        CommonUtills.setSubBillingAccountNumberOnCLI(IOTMobility_COMPONENTS.solution, "BillingAccountLookup", solutionComponent);
                        CommonUtills.setSubBillingAccountNumberOnCLI(IOTMobility_COMPONENTS.IOTSubscription, "BillingAccountLookup", false);
                    }
                    componentMapattr["BillingAccountLookup"] = [];
                    componentMapattr["BillingAccountLookup"].push({
                        IsreadOnly: true,
                        isVisible: true,
                        isRequired: true
                    });


                    componentMap.set(config.guid, componentMapattr);
                    CommonUtills.attrVisiblityControl(IOTMobility_COMPONENTS.solution, componentMap);
                }
            }

            //Added for PricingService
            PRE_Logic.init(loadedSolution.name);
            PRE_Logic.afterSolutionLoaded();

            if (window.basketStage === "Contract Accepted") {
                loadedSolution.lock("Commercial", true);
            }
        }

        return Promise.resolve(true);
    });

    IOTPlugin.afterAttributeUpdated = async (component, configuration, attribute, oldValueMap) => {
        let loadedSolution = await CS.SM.getActiveSolution();
        if (window.basketStage === "Contract Accepted") {
            loadedSolution.lock("Commercial", false);
        }

        if (window.BasketChange === "Change Solution" && attribute.name === "ChangeType") {
            IOTPlugin.UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
        }

        if (component.name === IOTMobility_COMPONENTS.solution && attribute.name === "OfferType") {
            Utils.emptyValueOfAttribute(configuration.guid, component.name, "PlanAllowance", true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, "PlanAllowanceValue", true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, "RC", true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, "SharedPlan", true);


            if (attribute.displayValue) {
                await IOTPlugin.updateAttributeVisiblity(["IoTRateCardButton"], IOTMobility_COMPONENTS.solution, configuration.guid, false, true, false);
            } else {
                await IOTPlugin.updateAttributeVisiblity(["IoTRateCardButton"], IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
            }


            if (attribute.displayValue === sharedDataPlan) {
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, true, false);
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, true, true, false);
            } else {
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
            }
            let solnName = loadedSolution.solutionName;
			let originalSolutionName = solnName.indexOf("_") != -1 ? solnName.substring(0, solnName.indexOf("_")) : solnName;
			if (attribute.value) {
				CommonUtills.genericUpdateSolutionName(component, configuration, originalSolutionName + "_" + attribute.displayValue, originalSolutionName + "_" + attribute.displayValue);
            }
        } else if (component.name === IOTMobility_COMPONENTS.solution && attribute.name === "SharedPlan") {
            let product = await CS.SM.getActiveSolution();
            if (product.componentType && product.name === IOTMobility_COMPONENTS.solution) {
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
                                        datapackallowance = allowanceValue;
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
		} else if (attribute.name === "SelectPlanName") {
			if (attribute.value == "IoT Annual Data Plan") {
				IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.annualDataPlanSubscriptionFields, IOTMobility_COMPONENTS.IOTSubscription, configuration.guid, true, true, false);
			} else {
				Utils.emptyValueOfAttribute(configuration.guid, component.name, "SIM Type", true);
				Utils.emptyValueOfAttribute(configuration.guid, component.name, "OC", true);
				Utils.emptyValueOfAttribute(configuration.guid, component.name, "RC", true);
				Utils.emptyValueOfAttribute(configuration.guid, component.name, "MaintenanceRC", true);
                IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.annualDataPlanSubscriptionFields, IOTMobility_COMPONENTS.IOTSubscription, configuration.guid, true, false, false);
            }
        }


        //Added for PricingService
        PRE_Logic.afterAttributeUpdated(component, configuration, attribute, oldValueMap.value, attribute.value);
        if (window.basketStage === "Contract Accepted") {
            loadedSolution.lock("Commercial", true);
        }

        return Promise.resolve(true); // Need to discuss with cloudsense
    };
    //Added for PricingService
    IOTPlugin.beforeSave = function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
        return Promise.resolve(true);
    }
    IOTPlugin.afterSave = async (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) => {
        try {
        let solution = result.solution;
        if (window.basketStage === "Contract Accepted") {
            solution.lock("Commercial", false);
        }


        Utils.updateCustomButtonVisibilityForBasketStage();
        Utils.updateOEConsoleButtonVisibility();
		//if (currentSolutionName === "IoT solutions") {
		if (solution.name === "IoT solutions") {	
            let buttons = document.getElementsByClassName("slds-file-selector__dropzone");
            if (buttons) {
                for (let i = 0; i < buttons.length; i++) {
                    let button = buttons[i];
                    button.style.display = "none";
                }
            }
        }


        await checkConfigurationSubscriptionsForIOT();
        await IOTPlugin_updateChangeTypeAttribute();
        if (window.BasketChange === "Change Solution") {
            await IOTPlugin.UpdateMainSolutionChangeTypeVisibility(solution);
            await IOTPlugin.UpdateAttributesForMacdOnSolution(solution);
            await IOTPlugin.UpdateAttributesForSubscription(solution);
            await IOTPlugin.updateStatusAfterSolutionLoad();
        }

        await IOTPlugin.UpdateAttributesForSharedDataPlan(solution);
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails();
        if (window.basketStage === "Contract Accepted") {
            solution.lock("Commercial", true);
        }
        //Added for PricingService
        await updatePREDiscountAttribute();
        }catch(error){
        CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
        console.log(error);
    }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
        return Promise.resolve(true);
    };

    IOTPlugin.UpdateMainSolutionChangeTypeVisibility = async (solution) => {
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

        await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.solutionNonEditableAttributeListForCancel, IOTMobility_COMPONENTS.solution, configGuid, true, true, false);

        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(IOTMobility_COMPONENTS.solution);
        if (updateMap) {
            updateMap.forEach(async (v, k) => {
                await component.updateConfigurationAttribute(k, v, true);
            });
        }
    };


    IOTPlugin.UpdateAttributesForSharedDataPlan = async (solution) => {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            let configs = solution.getConfigurations();
            if (configs) {
                Object.values(configs).forEach(async (config) => {
                    let attr = config.getAttribute("OfferType");
                    if (attr && attr.displayValue === sharedDataPlan) {
                        await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, config.guid, false, true, false);
                        await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, config.guid, true, true, false);
                    }
                });
            }
        }
        return Promise.resolve(true);
    };


    IOTPlugin.UpdateAttributesForSubscription = async (solution) => {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
			if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				Object.values(comp.schema.configurations).forEach(async (config) => {
                        let attr = config.getAttribute("ChangeType");
                        if (attr && attr.value === "Cancel") {
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.hidesubscriptionHideFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, false, false);
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.showSubscriptionFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, true, true, true);
                        }
                        if (window.BasketChange == "Change Solution") {
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, true, true, false);
                        }
                    });
                }
            }
        return Promise.resolve(true);
    };


    IOTPlugin.UpdateAttributesForMacdOnSolution = async (solution) => {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            let configs = solution.getConfigurations();
            if (configs) {
                let attr = configs[0].getAttribute("ChangeType");
                if (attr && attr.displayValue === "Cancel") {
                    await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], IOTMobility_COMPONENTS.solution, Object.values(configs)[0].guid, false, true, true);
                } else {
                    await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], IOTMobility_COMPONENTS.solution, Object.values(configs)[0].guid, false, false, false);
                    Utils.emptyValueOfAttribute(Object.values(configs)[0].guid, IOTMobility_COMPONENTS.solution, "CancellationReason", false);
                }
            }


            let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
			if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				Object.values(comp.schema.configurations).forEach(async (config) => {
                        let attr = config.getAttribute("ChangeType");
                        if (attr && attr.value === "Cancel") {
                            await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, true, true);
                            await IOTPlugin.updateAttributeVisiblity(["DisconnectionDate"], IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, true, true);
                        }
                    });
                }
            }

        return Promise.resolve(true);
    };

    IOTPlugin.UpdateCancellationAttributes = async (componentName, guid, changeTypeValue) => {
        if (changeTypeValue === "Cancel") {
            await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, true, true);
            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.solutionNonEditableAttributeListForCancel, componentName, guid, true, true, false);
        } else if (changeTypeValue === "Cancel" && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, true, true);
        } else if (changeTypeValue === "Modify" && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, false, false);
            await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.subscriptionNonEditableAttributeListForCancel, componentName, guid, false, true, false);
        } else if (changeTypeValue !== "Cancel") {
            await IOTPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.solution, "CancellationReason", true);
        }/* Code will never go inside this condition 
        else if (changeTypeValue !== "Cancel" && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, false, false);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.IOTSubscription, "CancellationReason", true);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.IOTSubscription, "DisconnectionDate", true);
        } */
    };


    IOTPlugin.updateAttributeVisiblity = async (attributeName, componentName, guid, isReadOnly, isVisible, isRequired) => {
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
            if (complock) component.lock("Commercial", false);
            await component.updateConfigurationAttribute(guid, updateMap[guid], true);
            if (complock) component.lock("Commercial", true);
        }

    };

    window.document.addEventListener("OrderEnrichmentTabLoaded", async (e) => {
        let currentSolution = await CS.SM.getActiveSolution();
        if (currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            afterOrderEnrichmentTabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name);
        }
    });


    IOTPlugin.afterOrderEnrichmentConfigurationAdd = (componentName, configuration, orderEnrichmentConfiguration) => {
        window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

    IOTPlugin.afterSolutionDelete = (solution) => {
        CommonUtills.updateBasketStageToDraft();
        //Added for PricingService
        refreshPricingSummeryWidget();
        return Promise.resolve(true);
    };
    IOTPlugin.updateStatusAfterSolutionLoad = async () => {
        let solution = await CS.SM.getActiveSolution();

        if (solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
            let updateConfigMapsubs = new Map();
			if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				Object.values(comp.schema.configurations).forEach((config) => {
					let attr = config.getAttribute("CustomerFacingServiceId");
					if (attr && !attr.value) {
						updateConfigMapsubs.set(config.guid, [
							{
								name: "ConfigName",
								value: checkMSISDNPresent(config.configurationName, attr.value),
								displayValue: checkMSISDNPresent(config.configurationName, attr.value)
							}
						]);
					}
				});
			}
			if (updateConfigMapsubs) {
				updateConfigMapsubs.forEach(async (v, k) => {
					await comp.updateConfigurationAttribute(k, v, true);
                });
            }
        }
        return Promise.resolve(true);
    };

    //Added for PricingService
    IOTPlugin.afterConfigurationDelete = function (componentName, configuration) {

        PRE_Logic.afterConfigurationDelete(componentName,configuration);
        return Promise.resolve(true);
    }
    IOTPlugin.afterConfigurationAddedToMacBasket = async (componentName, guid) => {
                    
        // Arinjay Start - EDGE 221460
        try {
          	CommonUtills.UpdateRelatedConfigForChildMac(guid,componentName,null);
        } catch (error) {
            console.log(error);
        }
 		// Arinjay End - EDGE 221460
 		
                    
        let solution = await CS.SM.getActiveSolution();
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            IOTPlugin_updateChangeTypeAttribute();
            await checkConfigurationSubscriptionsForIOT();


            if (window.BasketChange === "Change Solution") {
                let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
                if (comp) {
                    await validateOERules.resetCRDDatesinOESchema_ALL(solution.name, comp.name);
                }
            }
        }
        return Promise.resolve(true);
    };
};


const afterOrderEnrichmentTabLoaded = async (configurationGuid, OETabName) => {
    let schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
    window.afterOETabLoaded(configurationGuid, OETabName, schemaName, "");
    return Promise.resolve(true);
};


/************************************************************************************
 * Author	: Aruna Aware
 * Method Name : addDefaultIOTConfigs
 * Defect/US # : DPG-1692 & DPG-1723
 * Invoked When: After Click on Solution
 * Description :Check for bulk enrichment values
 ***********************************************************************************/
const addDefaultIOTConfigs = async () => {
	if (window.basketStage !== "Contract Accepted") {
        return;
    }
    let oeMap = [];
    let currentSolution = await CS.SM.getActiveSolution();


    if (currentSolution.componentType && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
        let comp = await currentSolution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
		if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			Object.values(comp.schema.configurations).forEach((config) => {
                let cancelconfig = config.getAttribute("ChangeType");
                let isDeliveryEnrichmentNeededAtt = config.getAttribute("isDeliveryEnrichmentNeededAtt");
                let isCRDEnrichmentNeededAtt = config.getAttribute("isCRDEnrichmentNeededAtt");
                if (cancelconfig && isDeliveryEnrichmentNeededAtt && isCRDEnrichmentNeededAtt && cancelconfig.value !== "Cancel" && (isDeliveryEnrichmentNeededAtt.value == true || isDeliveryEnrichmentNeededAtt.value === "true" || isCRDEnrichmentNeededAtt.value === true || isCRDEnrichmentNeededAtt.value === "true")) {
                    Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                        if (!oeSchema.name.toLowerCase().includes("numbermanagementv1")) {
                            let found = false;
                            if (config.orderEnrichmentList) {
                                let oeConfig = config.orderEnrichmentList.filter((oe) => oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId);
                                if (oeConfig && oeConfig.length > 0) {
                                    found = true;
                                }
                            }
                            if (!found) {
                                let el = {};
                                el.componentName = comp.name;
                                el.configGuid = config.guid;
                                el.oeSchema = oeSchema;
                                oeMap.push(el);
                            }
                        }
                    });
                }
            });
        }
    }


    if (oeMap.length > 0) {
        let map = [];
        for (let i = 0; i < oeMap.length; i++) {
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration(map);
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        }
    }

    await initializeIOTConfigs();
    return Promise.resolve(true);
};

/**********************************************************************************************
 * Author	  : Aruna Aware
 * Method Name : initializeIOTConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 **********************************************************************************************/
const initializeIOTConfigs = async (oeguid) => {
    let currentSolution = await CS.SM.getActiveSolution();


    if (currentSolution) {
        if (currentSolution.componentType && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            let comps = currentSolution.getComponents();
            if (comps) {
                Object.values(comps).forEach((comp) => {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
                            let updateMap = new Map();
                            let oeList = config.getOrderEnrichments();
                            if (oeList) {
                                oeList.forEach((oe) => {
                                    if (oeguid && oeguid !== oe.guid) {
                                        return;
                                    }
                                    let basketAttribute = oe.getAttribute("basketid");
                                    if (basketAttribute) {
										updateMap.set(oe.guid, [
											{
												name: basketAttribute.name,
												value: basketId
											}
										]);
                                    }
                                });
                            }


                            if (updateMap) {
                                updateMap.forEach(async (v, k) => {
                                    await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, k, v, true);
                                });
                            }
                        });
                    }
                });
            }
        }
    }
    return Promise.resolve(true);
};


const checkConfigurationSubscriptionsForIOT = async () => {
    let componentMap = {};
    let updateMap = new Map();
    let solution = await CS.SM.getActiveSolution();
    let optionValues = [CommonUtills.createOptionItem("Modify"),CommonUtills.createOptionItem( "Cancel")];//R34UPGRADE


    if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
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


                    if (element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") {
                        const found = optionValues.find((element) => element === statusValue);
                        if (!found) {
                            optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34UPGRADE
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
};

const checkMSISDNPresent = (configName, msisdn) => {
    if (configName.includes("-")) {
        return configName;
    } else {
        return configName + "-" + msisdn;
    }
};
IOTPlugin_updateChangeTypeAttribute = async () => {
    let solution = await CS.SM.getActiveSolution();


    if (solution && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
		let comp = solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
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
