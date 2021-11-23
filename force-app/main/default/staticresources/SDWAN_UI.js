/*
 * Handles all UI-related logic
 */
console.log('[SDWAN_UI] loaded');

const SDWAN_UI = {};

/**
* Provides the user with an opportunity to do something once the attribute is updated.
*
* @param {string} component - Component object where the configuration resides
* @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
* @param {object} attribute - The attribute which is being updated.
* @param {string} oldValueMap - Before change value.
*/
SDWAN_UI.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		if (attribute.name === 'Plan Name') {
			if (attribute.displayValue) {
				await SDWAN_UI.updateAttributeVisiblity(["SDWANRateCardButton"], component.name, configuration.guid, false, true, false);
			} else {
				await SDWAN_UI.updateAttributeVisiblity(["SDWANRateCardButton"], component.name, configuration.guid, false, false, false);
			}
			//Enterprise Wireless  DPG-3514
			if (SDWAN_COMPONENTS.planeNames.includes(attribute.displayValue)) {
				var updateMap = {};
				updateMap[configuration.guid] = [];
				updateMap[configuration.guid].push({
					name: SDWAN_COMPONENTS.lteModeAttributeName,
					options: SDWAN_COMPONENTS.lteModeSmallMedium,
					value: 'Active',
					displayValue: 'Active',
					showInUi: true,
					readOnly: false
				});
				let activeSolution = await CS.SM.getActiveSolution();
				let comp = await activeSolution.getComponentByName(component.name);
				await comp.updateConfigurationAttribute(configuration.guid, updateMap[configuration.guid], true);
				Utils.updateComponentLevelButtonVisibility("Add new", false, false);
				Utils.updateComponentLevelButtonVisibility("Delete", false, false);
				await CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, SDWAN_COMPONENTS.relatedProduct, false, 1);
			} else {
				var updateMap = {};
				updateMap[configuration.guid] = [];
				updateMap[configuration.guid].push({
					name: SDWAN_COMPONENTS.lteModeAttributeName,
					options: SDWAN_COMPONENTS.lteModeLargeExtraLarge,
					value: 'NA',
					displayValue: 'NA',
					showInUi: true,
					readOnly: true
				});
				let activeSolution = await CS.SM.getActiveSolution();
				let comp = await activeSolution.getComponentByName(component.name);
				await comp.updateConfigurationAttribute(configuration.guid, updateMap[configuration.guid], true);
				var config = await component.getConfiguration(configuration.guid);
				
				if (config.relatedProductList.length >= 0) {
					for (var ReletedConfig of config.relatedProductList) {
						if (ReletedConfig.guid && ReletedConfig.name === SDWAN_COMPONENTS.relatedProduct) {
							await component.deleteRelatedProduct(configuration.guid, ReletedConfig.guid, true);
						}
					}
				}
			}
		}
		if (window.basketStage === "Contract Accepted") {
			var configGUID = configuration.parentConfiguration; //Changed as per suggestion from Vimal           
			var schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
			
			if (component.name === 'Customer requested Dates') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			if (component.name === 'Delivery details' && attribute.name === 'DeliveryContact') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			if (component.name === 'Delivery details' && attribute.name === 'DeliveryAddress') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
			//for Site Contacts DPG-3741
			if (component.name === 'Site details' && attribute.name === 'SDWANSiteContact') {
				window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
			}
		}
		//DPG-3514
		if (attribute.name === 'WirelessPlanChargeId') {
			var listOfRelatedProducts = configuration.getRelatedProducts();
			Object.values(listOfRelatedProducts).forEach((rp) => {
				if (SDWAN_COMPONENTS.relatedProduct === rp.name) {
					SDWAN_UI.updateChildAttributedOnAdd(SDWAN_COMPONENTS.solution, configuration.guid, component, rp);
				}
			});
		}
		//For updating Attribute Auto Data Top Up based on LTE Mode DPG-4692
		if (attribute.name === SDWAN_COMPONENTS.lteModeAttributeName) {
			if (SDWAN_COMPONENTS.lteModeconditionalXSM.includes(attribute.value)) {
				var updateMap = {};
				var updateMapChild = {};
				let activeSolution = await CS.SM.getActiveSolution();
				let comp = await activeSolution.getComponentByName(component.name);
				var listOfRelatedProducts = configuration.getRelatedProducts();
				updateMap[configuration.guid] = [];
				Object.values(listOfRelatedProducts).forEach((rp) => {
					if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
						updateMapChild[rp.configuration.guid] = [];
						updateMapChild[rp.configuration.guid].push({
							name: 'Auto Data Top Up',
							showInUi: false
						});
					}
				});
				let keys = Object.keys(updateMapChild);
				for (let i = 0; i < keys.length; i++) {
					comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
				}
			} else {
				var updateMap = {};
				var updateMapChild = {};
				let activeSolution = await CS.SM.getActiveSolution();
				let comp = await activeSolution.getComponentByName(component.name);
				var listOfRelatedProducts = configuration.getRelatedProducts();
				updateMap[configuration.guid] = [];
				Object.values(listOfRelatedProducts).forEach((rp) => {
					if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
						updateMapChild[rp.configuration.guid] = [];
						updateMapChild[rp.configuration.guid].push({
							name: 'Auto Data Top Up',
							showInUi: true
						});
						Utils.emptyValueOfAttribute(rp.configuration.guid, component.name, "Auto Data Top Up", true); //Added related to defect DPG-5420
					}
				});
				let keys = Object.keys(updateMapChild);
				
				for (let i = 0; i < keys.length; i++) {
					comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
				}
			}
		} //End of changes related to Attribute Auto Data Top Up based on LTE Mode DPG-4692
		//DIGI-926 Changes related to MACD Disconnection Orders
		if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
			await SDWAN_UI.MACDDisconnectionDetails();
		}
	} catch (error) {
		console.log('[SDWAN_UI] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

SDWAN_UI.afterConfigurationAddedToMacBasket = async function(componentName,guid) {
	try {
		//DIGI-962 related to MACD Disconnection
		await SDWAN_UI.updateChildMACDDisconnectionDetails();
		await SDWAN_UI.MACDTenancyDetails();
        await CommonUtills.CloneOrderEnrichment(componentName, guid); // Added By vijay DIGI-456

	} catch (error) {
		console.log('[SDWAN_Delegate] afterConfigurationAddedToMacBasket() exception: ' + error);
		return false;
	}
	console.log('[SDWAN_UI] ...end afterConfigurationAddedToMacBasket()');
	return true;
};

SDWAN_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
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
		await component.updateConfigurationAttribute(guid, updateMap[guid], true);
	} catch (error) {
		console.log('[SDWAN_UI] updateAttributeVisiblity() exception: ' + error);
	}
};

/***********************************
* Author	  : Suyash
* Method Name : UpdateChildAttributedonAdd
* Invoked When: afterRelatedProductAdd
* Description : Update Commercial Product on Related Product - DPG-3514
* Parameters  : 
***********************************/
SDWAN_UI.updateChildAttributedOnAdd = async function(mainCompName, configGuid, component, relatedProduct) {
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.name.includes(mainCompName)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				var comp = await solution.getComponentByName(component.name);
				var config = await comp.getConfiguration(configGuid);
				var wirelessPlanChargeId = "";
				
				if (config.guid) {
					var planAtt = config.getAttribute("WirelessPlanChargeId");
					
					if (planAtt && planAtt.value) {
						wirelessPlanChargeId = planAtt.value;
					}
				}
				var updateMapChild = {};
				
				if (relatedProduct.configuration.attributes) {
					updateMapChild[relatedProduct.guid] = [];
					updateMapChild[relatedProduct.guid].push({
						name: "WirelessPlanChargeId",
						showInUi: false,
						readOnly: true,
						value: wirelessPlanChargeId,
						displayValue: wirelessPlanChargeId
					});
				}
				let keys = Object.keys(updateMapChild);
				
				for (let i = 0; i < keys.length; i++) {
					comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
				}
			}
		}
	} catch (error) {
		console.log('[SDWAN_UI] updateChildAttributedOnAdd() exception: ' + error);
	}
	return Promise.resolve(true);
};

/***********************************
* Author	  : Payel
* Method Name : MACDTenancyDetails
* Invoked When: When Solution is loaded
* Description : Update the Tenancy Id,secureEdgeCloudProductInstanceID,SDWAN Tenancy Product Instance ID for MACD flow-DPG-5387/DPG-5649
* Parameters  : 
***********************************/
SDWAN_UI.MACDTenancyDetails = async function() {
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
		
		if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
			let configs = currentComponent.getConfigurations();
			var updateMapChild = {};
			Object.values(configs).forEach((config) => {
				if (config.attributes) {
					updateMapChild[config.guid] = [];
					updateMapChild[config.guid].push({
						name: "SDWANOpptyType",
						showInUi: false,
						readOnly: false,
						value: opptyType,
						displayValue: opptyType
					});
				}
			});
			let keys = Object.keys(updateMapChild);
			currentComponent.lock('Commercial', false);
			
			for (let i = 0; i < keys.length; i++) {
				currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
			}
		}
		if (opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase()) {
			let inputMap = {};
			inputMap['GetTenancyDetailsforService'] = accountId;
			
			//DN: moved logic to SDWAN_IO module as part of modularisation activity
			var ss= await SDWAN_IO.serviceTenancyHandler(inputMap);
			if (!ss){
				return Promise.resolve(false);
			}
			
			let currentSolution = await CS.SM.getActiveSolution();
			var TenancyId;
			let currentComponent = currentSolution.getComponentByName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
			
			if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
				let configs = currentComponent.getConfigurations();
				Object.values(configs).forEach((config) => {
					if (config.guid) {
						let attribs = Object.values(config.attributes);
						TenancyId = attribs.filter((obj) => {
							return obj.name === "Tenancy ID";
						});
					}
				});
				var TenancyVal = TenancyId[0].displayValue;
				
				if ((TenancyVal) == "" || TenancyVal == null) {
					TenancyVal = tenId;
					var updateMapChild = {};
					Object.values(configs).forEach((config) => {
						if (config.attributes) {
							updateMapChild[config.guid] = [];
							updateMapChild[config.guid].push({
								name: "Tenancy ID",
								showInUi: true,
								readOnly: true,
								label: "VeloCloud Tenancy ID",
								value: TenancyVal,
								displayValue: TenancyVal
							});
							updateMapChild[config.guid].push({
								name: "SDWAN Tenancy Product Instance ID",
								showInUi: false,
								readOnly: true,
								value: tenguId,
								displayValue: tenguId
							});
							updateMapChild[config.guid].push({
								name: "secureEdgeCloudProductInstanceID",
								showInUi: false,
								readOnly: true,
								value: secgu_ID,
								displayValue: secgu_ID
							});
						}
					});
					let keys = Object.keys(updateMapChild);
					currentComponent.lock('Commercial', false);
					
					for (let i = 0; i < keys.length; i++) {
						currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
					}
				}
			}
		}
	} catch (error) {
		console.log('[SDWAN_UI] MACDTenancyDetails() exception: ' + error);
	}
	return Promise.resolve(true);
};

/***********************************
* Author	  : Payel/Radhika
* Method Name : MACDDisconnectionDetails
* Invoked When: When Solution is loaded
* Description : DIGI-926 : Make attributes visible only for MAC Disconnection
* Parameters  : 
***********************************/
SDWAN_UI.MACDDisconnectionDetails = async function() {
	try {
		let changeType;
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(SDWAN_COMPONENTS.solution);
		
		if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
			let configs = currentComponent.getConfigurations();
			var updateMapChild = {};
			Object.values(configs).forEach((config) => {
				if (config.guid) {
					let attribs = Object.values(config.attributes);
					changeType = attribs.filter((obj) => {
						return obj.name === "ChangeType";
					});
				}
				if (config.attributes) {
					SDWAN_UI.updateAttributeVisiblity(['ChangeType'], SDWAN_COMPONENTS.solution, config.guid, false, true, false);
					
					if (changeType[0].displayValue === 'New') {
						updateMapChild[config.guid] = [];
						updateMapChild[config.guid].push({
							name: "ChangeType",
							value: "Active",
							displayValue: "Active"
						});
						let keys = Object.keys(updateMapChild);
						currentComponent.lock('Commercial', false);
						
						for (let i = 0; i < keys.length; i++) {
							currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
						}
					}
					if (changeType[0].displayValue === 'Cancel') {
						SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, true, true);
						SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, true);
					} else if (changeType[0].displayValue !== 'Cancel') {
						Utils.emptyValueOfAttribute(config.guid, SDWAN_COMPONENTS.solution, "CancellationReason", true);
						Utils.emptyValueOfAttribute(config.guid, SDWAN_COMPONENTS.solution, "DisconnectionDate", true);
						SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, false, false);
						SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
					}
				}
			});
			if (Object.values(currentSolution.schema.configurations)[0].macLock === false) {
				await SDWAN_UI.updateChildMACDDisconnectionDetails();
			}
		}
	} catch (error) {
		console.log('[SDWAN_UI] MACDDisconnectionDetails() exception: ' + error);
	}
	return Promise.resolve(true);
};

/***********************************
* Author	  : Payel/Radhika
* Method Name : UpdateChildMACDDisconnectionDetails
* Invoked When: When Solution is loaded for SD-WAN Adapt S1
* Description : DIGI-926 : Make attributes visible only for MAC Disconnection
* Parameters  : 
***********************************/
SDWAN_UI.updateChildMACDDisconnectionDetails = async function() {
	try {
        let changeType1,changeDisCon1,changeCanR1;
		let currentSolution = await CS.SM.getActiveSolution();
              let currentComponent = currentSolution.getComponentByName(SDWAN_COMPONENTS.solution);
              if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
                  let configs = currentComponent.getConfigurations();
                  var updateMapChild = {};
                  Object.values(configs).forEach((config) => {
                      if (config.guid) {
                          let attribs = Object.values(config.attributes);
                          changeType1 = attribs.filter((obj) => {
                              return obj.name === "ChangeType";
                          });
                          changeCanR1 = attribs.filter((obj) => {
                              return obj.name === "CancellationReason";
                          });
                          changeDisCon1 = attribs.filter((obj) => {
                              return obj.name === "DisconnectionDate";
                          });
                      }
				  });
}
		let childComp = currentSolution.getComponentByName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
		let configs = childComp.getConfigurations();
		Object.values(configs).forEach((config) => {
			if (config.guid) {
				let attribs = Object.values(config.attributes);
				changeType = attribs.filter((obj) => {
					return obj.name === "ChangeType";
				});
				changeCanR = attribs.filter((obj) => {
                              return obj.name === "CancellationReason";
                          });
				 changeDisCon = attribs.filter((obj) => {
                              return obj.name === "DisconnectionDate";
                          });
			}
			if (config.attributes) {
                if (changeType[0].displayValue === 'New') {
                              updateMapChild[config.guid] = [];
                              updateMapChild[config.guid].push({
                                  name: "ChangeType",
                                  value: changeType1[0].displayValue,
                                  displayValue: changeType1[0].displayValue
                              });
                              
                              updateMapChild[config.guid].push({
                                  name: "CancellationReason",
                                  value: changeCanR1[0].displayValue,
                                  displayValue: changeCanR1[0].displayValue
                              });

                              updateMapChild[config.guid].push({
                                  name: "DisconnectionDate",
                                  value: changeDisCon1[0].displayValue,
                                  displayValue: changeDisCon1[0].displayValue
                              });
                              
                              let keys = Object.keys(updateMapChild);
                              currentComponent.lock('Commercial', false);
                              for (let i = 0; i < keys.length; i++) {
                                  currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                              }
                          }    
				SDWAN_UI.updateAttributeVisiblity(['ChangeType'], SDWAN_COMPONENTS.solution, config.guid, true, true, false);
				SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionChildNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
				var listOfRelatedProducts = config.getRelatedProducts();
				Object.values(listOfRelatedProducts).forEach((rp) => {
					if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
						SDWAN_UI.updateAttributeVisiblity(['Auto Data Top Up'], SDWAN_COMPONENTS.solution, rp.guid, true, true, false);
					}
				});
				if (changeType[0].displayValue === 'Cancel') {
					SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
				} else if (changeType[0].displayValue !== 'Cancel') {
					SDWAN_UI.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, false, false);
				}
			}
		});
	} catch (error) {
		console.log('[SDWAN_UI] updateChildMACDDisconnectionDetails() exception: ' + error);
	}
	return Promise.resolve(true);
};

/***********************************
* Author	  : Suyash
* Method Name : UpdateChildAttributedonAdd
* Invoked When: window.document.addEventListener, afterSave 
* Description : Update LTE Mode Values based on Plan Selection
* Parameters  : 
***********************************/
SDWAN_UI.updateLTEModeValues = async function() {
	try {
		let solution = await CS.SM.getActiveSolution();
		
		if (solution.componentType && solution.name.includes(SDWAN_COMPONENTS.solution) && !solution.commercialLock) {
			let comp = solution.getComponentByName(SDWAN_COMPONENTS.childComponent);
			if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				Object.values(comp.schema.configurations).forEach(async (config) => {
					let attr = config.getAttribute(SDWAN_COMPONENTS.lteModeAttributeName);

					if (attr && SDWAN_COMPONENTS.lteModeSmallMedium.includes(attr.value)) {
						var updateMap = {};
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: SDWAN_COMPONENTS.lteModeAttributeName,
							options: SDWAN_COMPONENTS.lteModeSmallMedium,
							value: attr.value,
							displayValue: attr.value,
							showInUi: true,
							readOnly: false
						});
						await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
					}
					if (attr && SDWAN_COMPONENTS.lteModeLargeExtraLarge.includes(attr.value)) {
						var updateMap = {};
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: SDWAN_COMPONENTS.lteModeAttributeName,
							options: SDWAN_COMPONENTS.lteModeLargeExtraLarge,
							value: attr.value,
							displayValue: attr.value,
							showInUi: true,
							readOnly: true
						});
						await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
					}
				});
			}
		}
	} catch (error) {
		console.log('[SDWAN_UI] updateLTEModeValues() exception: ' + error);
	}
	return Promise.resolve(true);
};
/***********************************
* Author	  : Vijay
* Method Name : SDWAN_handleIframeMessage
* Invoked When: order enrichment close button 
* Description : use for close order enrichment
* Parameters  : 
***********************************/
SDWAN_UI.SDWAN_handleIframeMessage = async function(e) {
        //Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
				await pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
		            
 }; 