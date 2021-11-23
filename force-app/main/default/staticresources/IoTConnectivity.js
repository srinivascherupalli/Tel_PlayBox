/******************************************************************************************
Sr.No.		Author 			    Date			Sprint   		Story Number	Description
1.			Aruna Aware		    20-May-2021	   	21.07			DPG-5306 		Configure product basket for shared data plans
2.			ArunaAware			17-Aug-2021		21.11			DIGI-9740       MAC - Add new services to a shared data plan
3.          Rozi Firdaus		19-Aug-2021		21.11			DIGI-2576		Validate Quantity based on SIM Type in Product Basket
4.          Arun		        31-Aug-2021		21.12			DIGI-9672		Added to update Allowance Id 
5.			Aruna Aware			5-Sept-2021		21.12			DIGI-13087      Cloudsense - Offer type alignment (Change name)
6.          Jamil   R34Upgrade
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/

var IOTCONNECTIVITY_COMPONENTS = {
    solutionname: "IoT connectivity",
    iotPlans: "IoT Plans",
    comittedDataSolutionEditableFields: ["SharedPlan"],
    solutionNonEditableAttributeListForCancel: ["OfferName","Solution Name","BillingAccountLookup"],
    subscriptionNonEditableAttributeListForCancel: ["SelectPlanType", "Select Plan", "OfferType", "SIM Type", "SharedPlan"],
    };
	//DIGI-13087  Cloudsense - Offer type alignment (Change name)
    var sharedDataPlan = "Shared Data Plan";
    
    if(!CS || !CS.SM){
    throw Error('Solution Console Api not loaded?');
    }
    
    if (CS.SM.registerPlugin) { 
    window.document.addEventListener("SolutionConsoleReady", async function () {
        await CS.SM.registerPlugin(IOTCONNECTIVITY_COMPONENTS.solutionname).then(async (IOTConnectivityPlugin) => {
                IOTConnectivityPlugin_updatePlugin(IOTConnectivityPlugin); 
            }); 
    }); 
    
    } 
        
    IOTConnectivityPlugin_updatePlugin = async (IOTConnectivityPlugin) => {
        document.addEventListener(
            "click",
            function(e) {
                e = e || window.event;
                let target = e.target;
                let text = target.textContent || target.innerText;
    
    
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
                            if (vbutton.innerText.toLowerCase() === "order enrichment") vbutton.style.display = "none";
                            else vbutton.style.display = "compact";
                        }
                    }
                }
            },
            false
        );
    window.document.addEventListener("SolutionSetActive", async function (e) {
        try {
            //vijaya
            /*if (window.basketStage === "Contract Accepted") {
                        Utils.updateComponentLevelButtonVisibility("Add IoT Plans", false, true);
                    }
                    Utils.updateCustomButtonVisibilityForBasketStage();*/
            //vijaya
            let loadedSolution = await CS.SM.getActiveSolution();
            if (loadedSolution.componentType && loadedSolution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                let basketId = e.detail.solution.basketId;
                let currentBasket = await CS.SM.loadBasket(basketId);
                
                await CommonUtills.getBasketData(currentBasket);
                if (window.basketStage === "Contract Accepted") {
                    loadedSolution.lock("Commercial", false);
                }
                
                CommonUtills.setBasketChange();
                await addDefaultIOTPlansConfigs();
                let inputMap = {};
                inputMap['GetBasket'] = basketId;
                await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                    console.log('GetBasket finished with response: ', result);
                    var basket = JSON.parse(result["GetBasket"]);
                    console.log('GetBasket: ', basket);
                    basketChangeType = basket.csordtelcoa__Change_Type__c;
                    basketStage= basket.csordtelcoa__Basket_Stage__c;
                    accountId = basket.csbb__Account__c;
                    console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId)
                    //window.oeSetBasketData(solution, basketStage, accountId);
                    if(accountId!=null){
                        CommonUtills.setAccountID(IOTCONNECTIVITY_COMPONENTS.solutionname, window.accountId);
                    }
                });
            
                Utils.loadSMOptions();
                Utils.updateOEConsoleButtonVisibility();
                if (window.BasketChange === "Change Solution") {
                    IOTConnectivityPlugin.UpdateMainSolutionChangeTypeVisibility(loadedSolution);
                }
                 await IOTConnectivityPlugin.UpdateAttributesForSharedDataPlan(loadedSolution);
                
                PRE_Logic.init(loadedSolution.name);
                PRE_Logic.afterSolutionLoaded();
                //vijaya start
                
                if (window.basketStage === "Contract Accepted") {
                    await IOTConnectivityPlugin.updateAttributeVisiblity(["IoT Plans"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, true, false, false);
                }
                //vijaya end
                 if (window.basketStage === "Contract Accepted") {
                    loadedSolution.lock("Commercial", true);
                }
            }
            return Promise.resolve(true);
        } catch (error) {
            console.log("ERROR ", error);
        }
        return Promise.resolve(true);
    });
    
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
            let solution = await CS.SM.getActiveSolution();
            if(solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname) ||  
                                        solution.name.includes(IOTCONNECTIVITY_COMPONENTS.iotPlans)){
                var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
                window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
            }
            return Promise.resolve(true);
        });
    
    IOTConnectivityPlugin.afterAttributeUpdated = async (component, configuration, attribute, oldValueMap) => {
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
             if (window.BasketChange === "Change Solution" && attribute.name === "ChangeType") {
                IOTConnectivityPlugin.UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
            }
            
            if (component.name === IOTCONNECTIVITY_COMPONENTS.iotPlans && attribute.name === "OfferType") {
                if (attribute.displayValue) {
                        await IOTConnectivityPlugin.updateAttributeVisiblity(["IoTPlansRateCardButton"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, true, false);
                    } else {
                        await IOTConnectivityPlugin.updateAttributeVisiblity(["IoTPlansRateCardButton"], IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, false, false);
                    }
            
                if (attribute.displayValue === sharedDataPlan) {
                    await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, true, false);
                } else {
                    await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, configuration.guid, false, false, false);
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
        
        await IOTConnectivityPlugin.checkQuantityForNBiotSimType(loadedSolution);
        
        if (window.basketStage === "Contract Accepted") {
                loadedSolution.lock("Commercial", true);
            }
        
        return Promise.resolve(true); // Need to discuss with cloudsense
    };
        
    //Added for PricingService
    IOTConnectivityPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids,attribute) {	
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
    
    IOTConnectivityPlugin.afterSave = async (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) => {
         let solution = result.solution;
            if (window.basketStage === "Contract Accepted") {
                solution.lock("Commercial", false);
            }
        Utils.updateCustomButtonVisibilityForBasketStage();
        await checkConfigurationSubscriptionsForIOTPlans(solution);
        await IOTConnectivityPlugin_updateChangeTypeAttribute(solution);
           if (window.BasketChange === "Change Solution") {
                await IOTConnectivityPlugin.UpdateMainSolutionChangeTypeVisibility(solution);
                await IOTConnectivityPlugin.UpdateAttributesForMacdOnSolution(solution);
                await IOTConnectivityPlugin.UpdateAttributesForSubscription(solution);
            }
        await IOTConnectivityPlugin.UpdateAttributesForSharedDataPlan(solution);
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails();
             
        //Added for PricingService
        await updatePREDiscountAttribute();
        return Promise.resolve(true);
    };
        
    /******************************************************************************************
        * Author : Rozi Firdaus
        * Story Number : DIGI-2576
        * Description : Validate Quantity based on SIM Type in Product Basket
        * Method Name : checkQuantityForNBiotSimType
        * Invoked When: after attribute update
                    
    ********************************************************************************************/
      IOTConnectivityPlugin.checkQuantityForNBiotSimType = async (currentSolution) => {
        if (currentSolution.componentType && currentSolution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
          let comp = await currentSolution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
          if (comp &&comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
            Object.values(comp.schema.configurations).forEach(config => {
              if (config && Object.values(config).length > 0) {
                let SimTypeconfig = config.getAttribute("SIM Type");
                let quantityconfig = config.getAttribute("Quantity");
                let quantity = quantityconfig.value;
                var regEx =/^[0-9]*$/;
                if (SimTypeconfig.displayValue === "NB IoT SIM Chip Standard" || SimTypeconfig.displayValue === "NB IoT SIM CHIP M2M Type 4") {
                  
                  if (quantity > 0 && quantity < 500) {
                    config.status = false;
                    config.statusMessage ="Select the minimum order quantity as 500";
                  } else if (quantity > 500) {
                    var regExp = /^[0-9]*(0|5)(0{2})$/;
                    if (!regExp.test(quantity)) {
                        config.status = false;
                        config.statusMessage ="Select order quantity in multiples of 500";
                    }
                    else{
                        config.status = true;
                        config.statusMessage = "";
                    }
                  } else {
                      config.status = true;
                      config.statusMessage = "";
                  }
                }else{
                    if(quantity > 0){
                        config.status = true;
                        config.statusMessage = "";
                    }
                }
                if(quantity <= 0 || !regEx.test(quantity)){
                    config.status = false;
                    config.statusMessage = "Select the minimum order quantity as 1 and in digit";
                }
              }
            });
          }
        }
      };    
       
    IOTConnectivityPlugin.updateAttributeVisiblity = async (attributeName, componentName, guid, isReadOnly, isVisible, isRequired) => {
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
    
    IOTConnectivityPlugin.afterOrderEnrichmentConfigurationAdd = (componentName, configuration, orderEnrichmentConfiguration) => {
            window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
            return Promise.resolve(true);
        };
            
    IOTConnectivityPlugin.afterSolutionDelete = (solution) => {
            CommonUtills.updateBasketStageToDraft();
            //Added for PricingService
            refreshPricingSummeryWidget();
            return Promise.resolve(true);
        };
    
    //Added for PricingService
    IOTConnectivityPlugin.afterConfigurationDelete = function (componentName, configuration) {
        PRE_Logic.afterConfigurationDelete(componentName,configuration);
        return Promise.resolve(true);
    };
    
        IOTConnectivityPlugin.afterConfigurationAddedToMacBasket = async (componentName, guid) => {
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
                await checkConfigurationSubscriptionsForIOTPlans(solution);
    
    
                if (window.BasketChange === "Change Solution") {
                    await IOTConnectivityPlugin.UpdateSubscriptionChangeTypeVisibility(solution);
                    let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                    if (comp) {
                        await validateOERules.resetCRDDatesinOESchema_ALL(solution.name, comp.name);
                    }
                }
            }
            return Promise.resolve(true);
        };
        
    IOTConnectivityPlugin.UpdateAttributesForSharedDataPlan = async (solution) => {
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.iotPlans)) {
                let configs = solution.getConfigurations();
                if (configs) {
                    Object.values(configs).forEach(async (config) => {
                        let attr = config.getAttribute("OfferType");
                        if (attr && attr.displayValue === sharedDataPlan) {
                            await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.comittedDataSolutionEditableFields, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, false);
                        }
                    });
                }
            }
            return Promise.resolve(true);
    };
    
        IOTConnectivityPlugin.UpdateMainSolutionChangeTypeVisibility = async (solution) => {
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
    
            await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.solutionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.solutionname, configGuid, true, true, false);
    
            let activeSolution = await CS.SM.getActiveSolution();
            let component = await activeSolution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.solutionname);
            if (updateMap) {
                updateMap.forEach(async (v, k) => {
                    await component.updateConfigurationAttribute(k, v, true);
                });
            }
        };
        IOTConnectivityPlugin.UpdateSubscriptionChangeTypeVisibility = async (solution) => {
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
    
            await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, configGuid, true, true, false);
            if (updateMap) {
                updateMap.forEach(async (v, k) => {
                    await component.updateConfigurationAttribute(k, v, true);
                });
            }
        };
     IOTConnectivityPlugin.UpdateAttributesForMacdOnSolution = async (solution) => {
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                let configs = solution.getConfigurations();
                if (configs) {
                    let attr = configs[0].getAttribute("ChangeType");
                    if (attr && attr.displayValue === "Cancel") {
                        await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.solutionname, Object.values(configs)[0].guid, false, true, true);
                    } else {
                        await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.solutionname, Object.values(configs)[0].guid, false, false, false);
                        Utils.emptyValueOfAttribute(Object.values(configs)[0].guid, IOTCONNECTIVITY_COMPONENTS.solutionname, "CancellationReason", false);
                    }
                }
    
    
                let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    Object.values(comp.schema.configurations).forEach(async (config) => {
                            let attr = config.getAttribute("ChangeType");
                            if (attr && attr.value === "Cancel") {
                                await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, true);
                                await IOTConnectivityPlugin.updateAttributeVisiblity(["DisconnectionDate"], IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, false, true, true);
                            }
                        });
                    }
                }
            return Promise.resolve(true);
        };
    
         IOTConnectivityPlugin.UpdateAttributesForSubscription = async (solution) => {
            if (solution.componentType && solution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
                let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
                if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    Object.values(comp.schema.configurations).forEach(async (config) => {
                            let attr = config.getAttribute("ChangeType");
                            if (attr && attr.value === "Cancel") {
                                await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.showSubscriptionFieldsForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, true, true, true);
                            }
                            if (window.BasketChange == "Change Solution") {
                                await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTCONNECTIVITY_COMPONENTS.iotPlans, config.guid, true, true, false);
                            }
                        });
                    }
                }
            return Promise.resolve(true);
        };
                    
      IOTConnectivityPlugin.UpdateCancellationAttributes = async (componentName, guid, changeTypeValue) => {
            if (changeTypeValue === "Cancel") {
                await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, true, true);
                await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.solutionNonEditableAttributeListForCancel, componentName, guid, true, true, false);
            } else if (changeTypeValue === "Cancel" && componentName === IOTCONNECTIVITY_COMPONENTS.iotPlans) {
                await IOTConnectivityPlugin.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, true, true);
            } else if ((changeTypeValue === "Modify" || changeTypeValue === "New") && componentName === IOTCONNECTIVITY_COMPONENTS.iotPlans) {
                await IOTConnectivityPlugin.updateAttributeVisiblity(["DisconnectionDate"], componentName, guid, false, false, false);
                await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
                await IOTConnectivityPlugin.updateAttributeVisiblity(IOTCONNECTIVITY_COMPONENTS.subscriptionNonEditableAttributeListForCancel, componentName, guid, false, true, false);
            } else if (changeTypeValue !== "Cancel") {
                await IOTConnectivityPlugin.updateAttributeVisiblity(["CancellationReason"], componentName, guid, false, false, false);
                Utils.emptyValueOfAttribute(guid, IOTCONNECTIVITY_COMPONENTS.solutionname, "CancellationReason", true);
            }
        }
    };
    /************************************************************************************
     * Author	: Aruna Aware
     * Method Name : addDefaultIOTConfigs
     * Defect/US # : DPG-1692 & DPG-1723
     * Invoked When: After Click on Solution
     * Description :Check for bulk enrichment values
     ***********************************************************************************/
    const addDefaultIOTPlansConfigs = async () => {
        if (window.basketStage !== "Contract Accepted") {
            return;
        }
        let oeMap = [];
        let currentSolution = await CS.SM.getActiveSolution();
    
    
        if (currentSolution.componentType && currentSolution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
            let comp = await currentSolution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
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
    
        await initializeIOTPlansConfigs();
        return Promise.resolve(true);
    };
    
    /**********************************************************************************************
     * Author	  : Aruna Aware
     * Method Name : initializeIOTConfigs
     * Invoked When: after solution is loaded, after configuration is added
     * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
     * Parameters  : none
     **********************************************************************************************/
    const initializeIOTPlansConfigs = async (oeguid) => {
        console.log('Inside initializeIOTPlansConfigs');
        let currentSolution = await CS.SM.getActiveSolution();
    
    
        if (currentSolution) {
            if (currentSolution.componentType && currentSolution.name.includes(IOTCONNECTIVITY_COMPONENTS.solutionname)) {
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
    const checkConfigurationSubscriptionsForIOTPlans = async (solution) => {
                                        
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
    
    
                        if (element.ChangeTypeValue !== "New" &&  element.ChangeTypeValue !== "Cancel" && statusValue != "New") {
                            const found = optionValues.find((element) => element === statusValue);
                            if (!found) {
                                optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34 Upgrade
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