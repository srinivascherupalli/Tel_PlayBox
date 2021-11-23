/***************************************************************************************************************************
 * Author	   : DPG Oxygen
 
   Change Version History 
   
   Version No	 Author 			    Date                 Change Description 
      1 	     Lalit Motiray		 	24-Sept-2020	     Initial file    						    DPG-2600
	  2 	     Suyash Chiplunkar		08-Jan-2021	     	 Small and Meduim Plan Configuration        DPG-3514
	  3			 Suyash Chiplunkar		08-Jan-2021		 	 Update Validate Error messages             DPG-3906
	  4			 Payel Ganguly          30-Mar-2021			 Extra Small Plan Configuration			    DPG-4692
      5			 Lalit Motiray          31-May-2021			 Change Hot satndby mode value to Standby   DPG-5565
	  6			 Payel Ganguly			02-Jun-2021			 Change related to MACD Order 				DPG-5387/DPG-5649
	  7			 Radhika/Payel			16-July-2021		 Change related to MACD Disconnection       DIGI-926
 **************************************************************************************************************************/
      console.log('SDWAN Plugin loaded');

      var SDWAN_COMPONENTS = {
          solution: 'SD-WAN Adapt S1 Solution',
          SDWAN_ADAPT_S1: 'SD-WAN Adapt S1',
          childComponent: 'SD-WAN Adapt S1',
          planeNames: ['SD-WAN Adapt S1 – Extra Small', 'SD-WAN Adapt S1 – Small', 'SD-WAN Adapt S1 – Medium'], //DPG-3514//DPG-4692
          lteModeSmallMedium: ['Active', 'Standby', 'Backup'], // DPG-3514 //DPG-5565
          lteModeLargeExtraLarge: ['NA'],
          relatedProduct: 'Enterprise Wireless', //DPG-3514
          lteModeconditionalXSM: ['Standby', 'Backup'], //DPG-4692 //DPG-5565
          lteModeAttributeName: 'LTE Mode',
          opportunityType: 'MACs (Moves, Adds & Change)', //DPG-5387/DPG-5649
          MACDSolutionEditableFields: ['CancellationReason', 'DisconnectionDate'], //DIGI-926
          MACDSolutionNonEditableFields: ['Site', 'BillingAccountLookup'], //DIGI-926 
          MACDSolutionChildNonEditableFields: ['Plan Name', 'Contract Term', 'LTE Mode'] //DIGI-926 
      
      };
      
      var executeSaveSDWAN = false;
      var allowSaveSDWAN = false;
      var currentSDWANSolution;
      var DEFAULTSOLUTIONNAME_SDWAN = 'SD-WAN Adapt S1 Solution';
      let modbasketChangeType;
      
      /*var basketStage = null;
      var communitySiteId;
      var DEFAULTSOLUTIONNAME_SDWAN = 'SDWAN ADAPT S1';*/
      
      // Register Plugin
      var currentSolution;
      if (CS.SM.registerPlugin) {
          console.log('Load SDWAN plugin');
          window.document.addEventListener('SolutionConsoleReady', async function() {
              console.log('SDWAN SolutionConsoleReady');
              await CS.SM.registerPlugin('SD-WAN Adapt S1 Solution')
                  .then(async SDWANPlugin => {
      
                      // For Hooks
                      SDWANPlugin_updatePlugin(SDWANPlugin);
                  });
          });
      }
      
      
      async function SDWANPlugin_updatePlugin(SDWANPlugin) {
      
          console.log('inside hooks', SDWANPlugin);
          window.document.addEventListener('SolutionSetActive', async function(e) {
              let solution = await CS.SM.getActiveSolution();
              if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
                  console.log('SolutionSetActive', e);
                  currentBasket = await CS.SM.getActiveBasket();
                  const basketId = await CS.SM.getActiveBasketId();
                  let inputMap = {};
                  inputMap['GetBasket'] = basketId;
                  await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                      console.log('GetBasket finished with response: ', result);
                      var basket = JSON.parse(result["GetBasket"]);
                      console.log('GetBasket: ', basket);
                      basketChangeType = basket.csordtelcoa__Change_Type__c;
                      basketStage = basket.csordtelcoa__Basket_Stage__c;
                      accountId = basket.csbb__Account__c;
                      opptyType = basket.Opportunity_Type__c; //DPG-5387
                      modbasketChangeType = basketChangeType;
                      console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId)
                      window.oeSetBasketData(solution, basketStage, accountId);
                      if (accountId != null) {
                          CommonUtills.setAccountID(SDWAN_COMPONENTS.solution, accountId);
                      }
                  });
                  //addDefaultSDWAN_OETenancyConfigs();
                  await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_SDWAN);
                  //update LTE Mode on Solution Load
                  await SDWANPlugin.updateLTEModeValues();
                  //Display message to check if carriage is active - DPG-5356
                  await SDWANPlugin.AccessPointVerification();
                  console.log('basketChangeType: ', modbasketChangeType);
                  //DPG-5387/DPG-5649 Changes related to MAC Orders
                  await SDWANPlugin.MACDTenancyDetails();
                  //DIGI-926 Changes related to MACD Disconnection Orders
                  if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                      await SDWANPlugin.MACDDisconnectionDetails();
                  }
              }
      
              return Promise.resolve(true);
          });
      
      
          //Event to handle load of OE tabs
          window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
              let solution = await CS.SM.getActiveSolution();
              if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
                  console.log('OrderEnrichmentTabLoaded', e);
                  var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
                  window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
                  //addDefaultSDWAN_OETenancyConfigs();
              }
              return Promise.resolve(true);
          });
      
      
          /**
           * Hook executed before we save the complex product to SF. We need to resolve the promise as a
           * boolean. The save will continue only if the promise resolve with true.
           * Updated by : Venkata Ramanan G
           * To create case for the configuration in case the business criteria w.r.t to pricing has met
           * @param {Object} complexProduct
           */
          SDWANPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
              let solution = result.solution;
              if (solution == null || solution == undefined) solution = await CS.SM.getActiveSolution();
              if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  solution.lock("Commercial", false);
              }
      
              //updateSolutionName_SDWAN(); 
              await Utils.updateActiveSolutionTotals();
              CommonUtills.updateBasketDetails();
              //Utils.hideSubmitSolutionFromOverviewTab();
              //
              let inputMap = {};
              inputMap['getData'] = '';
      
              let commercialProductMap = {};
      
              let currentBasket = await CS.SM.getActiveBasket();
              let solutions = currentBasket.getSolutions()
              for (solutionId in solutions) {
                  let solution = solutions[solutionId];
                  if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
                      let SDWANComp = solution.getComponentBySchemaName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
                      let configurations = SDWANComp.getConfigurations();
                      for (index in configurations) {
                          let configuration = configurations[index];
                          console.log(configuration);
                          let CPID = configuration.getAttribute('plan name').value; // Assumes that the commercial product lookup is named "CommercialProduct"
                          commercialProductMap[configuration.id] = CPID;
                      }
                  }
              }
              if (solution.name.includes(SDWAN_COMPONENTS.solution)) {
                  inputMap['CommercialProductMap'] = JSON.stringify(commercialProductMap);
                  inputMap['basketId'] = currentBasket.basketId;
                  console.log('After save hook....2222', currentBasket.basketId, inputMap);
                  let resultOEcreation;
                  await currentBasket.performRemoteAction('MaterialEnrichmentDataCreator', inputMap).then(result => {
                      //resultOEcreation = JSON.parse(result["createOE"]);
                  });
              }
      
              if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  solution.lock("Commercial", true);
              }
      
              //await SDWANPlugin.UpdateLTEModeOptions(result.solution);
              await SDWANPlugin.updateLTEModeValues();
              //DIGI-926
              if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                  await SDWANPlugin.MACDDisconnectionDetails();
              }
              return Promise.resolve(true);
          }
      
          SDWANPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
              console.log("Inside beforeSave");
              let currentSolution = await CS.SM.getActiveSolution();
              if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  currentSolution.lock("Commercial", false);
              }
              return Promise.resolve(true);
          }
      
          SDWANPlugin.afterSolutionDelete = (solution) => {
              CommonUtills.updateBasketStageToDraft();
              return Promise.resolve(true);
          };
      
          /**
           * Provides the user with an opportunity to do something once the attribute is updated.
           *
           * @param {string} component - Component object where the configuration resides
           * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
           * @param {object} attribute - The attribute which is being updated.
           * @param {string} oldValueMap - Before change value.
           */
          SDWANPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
              if (attribute.name === 'Plan Name') {
                  if (attribute.displayValue) {
                      await SDWANPlugin.updateAttributeVisiblity(["SDWANRateCardButton"], component.name, configuration.guid, false, true, false);
                  } else {
                      await SDWANPlugin.updateAttributeVisiblity(["SDWANRateCardButton"], component.name, configuration.guid, false, false, false);
                  }
                  //Enterprise Wireless  DPG-3514
                  if (SDWAN_COMPONENTS.planeNames.includes(attribute.displayValue)) {
                      console.log('Small Medium');
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
                      console.log('Large Extra Large');
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
                  var configGUID = configuration.parentConfiguration; // Changed as per suggestion from Vimal           
                  var schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
                  //window.updateOE_CRD (solution,schemaName,configuration.guid);
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
                          SDWANPlugin.UpdateChildAttributedonAdd(SDWAN_COMPONENTS.solution, configuration.guid, component, rp);
                      }
      
                  });
      
              }
              //For updating Attribute Auto Data Top Up based on LTE Mode DPG-4692
              if (attribute.name === SDWAN_COMPONENTS.lteModeAttributeName) {
                  if (SDWAN_COMPONENTS.lteModeconditionalXSM.includes(attribute.value)) {
                      console.log('Active LTE Mode Small Medium');
                      var updateMap = {};
                      var updateMapChild = {};
                      let activeSolution = await CS.SM.getActiveSolution();
                      let comp = await activeSolution.getComponentByName(component.name);
                      var listOfRelatedProducts = configuration.getRelatedProducts();
                      updateMap[configuration.guid] = [];
                      Object.values(listOfRelatedProducts).forEach((rp) => {
                          if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
                              console.log('Active LTE Mode Small Medium check');
                              updateMapChild[rp.configuration.guid] = [];
                              updateMapChild[rp.configuration.guid].push({
                                  name: 'Auto Data Top Up',
                                  showInUi: false,
                              });
                          }
                          console.log('check1');
      
      
                      });
      
                      let keys = Object.keys(updateMapChild);
                      for (let i = 0; i < keys.length; i++) {
                          comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                          console.log('check2');
                      }
      
                  } else {
                      console.log('Backup/HotStandby To Active Check');
                      var updateMap = {};
                      var updateMapChild = {};
                      let activeSolution = await CS.SM.getActiveSolution();
                      let comp = await activeSolution.getComponentByName(component.name);
                      var listOfRelatedProducts = configuration.getRelatedProducts();
                      updateMap[configuration.guid] = [];
                      Object.values(listOfRelatedProducts).forEach((rp) => {
                          if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
                              console.log('Active LTE Mode Small Medium check2');
                              updateMapChild[rp.configuration.guid] = [];
                              updateMapChild[rp.configuration.guid].push({
                                  name: 'Auto Data Top Up',
                                  showInUi: true,
                              });
                              Utils.emptyValueOfAttribute(rp.configuration.guid, component.name, "Auto Data Top Up", true); //Added related to defect DPG-5420
                          }
      
                      });
                      let keys = Object.keys(updateMapChild);
                      for (let i = 0; i < keys.length; i++) {
                          comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                          console.log('check21');
                      }
                  }
              } //End of changes related to Attribute Auto Data Top Up based on LTE Mode DPG-4692
              //DIGI-926 Changes related to MACD Disconnection Orders
              if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SDWAN_COMPONENTS.opportunityType).toLowerCase() && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                  await SDWANPlugin.MACDDisconnectionDetails();
              }
              return Promise.resolve(true);
          }
          SDWANPlugin.beforeRelatedProductDelete = async function(component, configuration, relatedProduct) {
      
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
              console.log('planName' + planName);
      
              var listOfRelatedProducts = configuration.getRelatedProducts();
              var countRelatedProducts = 0;
              Object.values(listOfRelatedProducts).forEach((rp) => {
                  if (SDWAN_COMPONENTS.relatedProduct === rp.name) {
                      countRelatedProducts++;
                  }
              });
              //DPG-3906 - Validation Error Messages
              if (SDWAN_COMPONENTS.planeNames.includes(planName[0].displayValue) && countRelatedProducts == 1 && relatedProduct.name === SDWAN_COMPONENTS.relatedProduct) {
                  //CS.SM.displayMessage("Change the plan " + planName[0].displayValue+ " to remove "+SDWAN_COMPONENTS.relatedProduct+" from the basket", "error");
                  CS.SM.displayMessage("Mobile access is required for " + planName[0].displayValue + ". Please select SD-WAN Adapt S1 - Large or Extra Large if mobile access is not required.", "error");
                  return Promise.resolve(false);
              }
              return Promise.resolve(true);
          }
      
          SDWANPlugin.beforeRelatedProductAdd = async function(component, configuration, relatedProduct) {
      
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
              console.log('planName' + planName);
              //DPG-3906/DPG-4692 - Validation Error Messages
              if (!SDWAN_COMPONENTS.planeNames.includes(planName[0].displayValue)) {
                  //CS.SM.displayMessage("Please select appropriate plan name to add "+ SDWAN_COMPONENTS.relatedProduct, "error");
                  CS.SM.displayMessage("Mobile access is not required for " + planName[0].displayValue + ". Please select SD-WAN Adapt S1 - Extra Small or Small or Medium if mobile access is required.", "error");
                  return Promise.resolve(false);
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
                  //CS.SM.displayMessage("Only one "+ SDWAN_COMPONENTS.relatedProduct +"  can be configured per plan", "error");
                  CS.SM.displayMessage("Only one Enterprise Wireless can be configured for " + planName[0].displayValue, "error");
      
                  return Promise.resolve(false);
              }
      
              return Promise.resolve(true);
          }
      
      
          /**
           * Hook executed after the Order Enrichment configuration is deleted via the UI delete configuration button
           *
           * @param {string} component - Component object where the configuration resides
           * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
           * @param {Object} orderEnrichmentConfiguration - Order Enrichment object which is deleted
           */
          SDWANPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
              window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
              return Promise.resolve(true);
          };
      
          SDWANPlugin.updateAttributeVisiblity = async (attributeName, componentName, guid, isReadOnly, isVisible, isRequired) => {
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
          };
      
          SDWANPlugin.afterRelatedProductAdd = async function(component, configuration, relatedProduct) {
              //console.log('afterConfigurationAdd', component, configuration, relatedProduct);
              console.log('Inside afterRelatedProductAdd');
              let solution = await CS.SM.getActiveSolution();
              let attrCommercialConfig = configuration.getAttribute('plan name');
              console.log('attr :', attrCommercialConfig);
              let updateMap = {
                  value: attrCommercialConfig.value,
                  displayValue: attrCommercialConfig.displayValue
              };
              console.log(relatedProduct.guid);
              console.log('map', updateMap);
              let config = solution.getConfiguration(relatedProduct.guid);
              if (config) {
                  console.log('inside if statement');
                  //config.updateAttribute('commercialproduct', updateMap, true);
              }
      
              await SDWANPlugin.UpdateChildAttributedonAdd(SDWAN_COMPONENTS.solution, configuration.guid, component, relatedProduct);
      
              //await SDWANPlugin.UpdateChildAttributedForActiveAllowance(SDWAN_COMPONENTS.solution,configuration.guid,component,relatedProduct);
      
              return Promise.resolve(true);
          }
      
          /***********************************************************************************************************************************
           * Author	   : Suyash
           * Method Name : UpdateChildAttributedonAdd
           * Invoked When: afterRelatedProductAdd
           * Description : Update Commercial Product on Related Product - DPG-3514
           * Parameters  : 
           ***********************************************************************************************************************************/
          SDWANPlugin.UpdateChildAttributedonAdd = async (mainCompName, configGuid, component, relatedProduct) => {
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
              return Promise.resolve(true);
          }
      
          /***********************************************************************************************************************************	
           * Author	   : Payel/Suyash/Sharmila 
           * Method Name : AccessPointVerification
           * Invoked When: When Solution is loaded and if the Change Type is not 'Cancel'
           * Description : To display simple message 	- DPG-5356 / DIGI-6777
           * Parameters  : None	
           ***********************************************************************************************************************************/
          SDWANPlugin.AccessPointVerification = async () => {
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
                      console.log('Change_Type ==>' + Change_Type);
      
                      var changeTypeVal = Change_Type[0].value;
                      console.log('Change Typeeee===> ' + changeTypeVal);
                      
              if (modbasketChangeType === 'Change Solution' && changeTypeVal !== "Cancel") {
                  CS.SM.displayMessage("Ensure carriage is active at the customer site where required", "error");
              }
              return Promise.resolve(true);
          }
      
          /***********************************************************************************************************************************
           * Author	   : Payel
           * Method Name : MACDTenancyDetails
           * Invoked When: When Solution is loaded
           * Description : Update the Tenancy Id,secureEdgeCloudProductInstanceID,SDWAN Tenancy Product Instance ID for MACD flow-DPG-5387/DPG-5649
           * Parameters  : 
           ***********************************************************************************************************************************/
      
          SDWANPlugin.MACDTenancyDetails = async () => {
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
                          console.log("Result", updateMapChild);
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
                  await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                      console.log('GetTenancyDetailsforService finished with response: ', result);
                      var subs = JSON.parse(result["GetTenancyDetailsforService"]);
                      console.log('GetTenancyDetailsforService: ', subs);
                      tenguId = subs.vCguId;
                      tenId = subs.Tenancy_Id;
                      secgu_ID = subs.sEgu_Id;
                      //tenSecId = subs.TenancySecId;
                  });
                  let currentSolution = await CS.SM.getActiveSolution();
                  var TenancyId;
                  let currentComponent = currentSolution.getComponentByName(SDWAN_COMPONENTS.SDWAN_ADAPT_S1);
                  if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
                      let configs = currentComponent.getConfigurations();
                      Object.values(configs).forEach((config) => {
                          if (config.guid) {
                              let attribs = Object.values(config.attributes);
                              console.log(attribs);
                              TenancyId = attribs.filter((obj) => {
                                  return obj.name === "Tenancy ID";
                              });
                          }
                      });
                      console.log('TenancyId', TenancyId);
                      var TenancyVal = TenancyId[0].displayValue;
                      if ((TenancyVal) == "" || TenancyVal == null) {
                          console.log(TenancyVal);
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
                                  /*DIGI-926 related to MACD Disconnection
                                  if (modbasketChangeType === 'Change Solution' && Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                                      updateMapChild[config.guid].push({
                                          name: "SecureEdge Tenancy ID",
                                          showInUi: true,
                                          readOnly: true,
                                          value: tenSecId,
                                          displayValue: tenSecId
                                      });
                                  }DIGI-926*/
                                  console.log("Result", updateMapChild);
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
              return Promise.resolve(true);
          }
          /***********************************************************************************************************************************
           * Author	   : Payel/Radhika
           * Method Name : MACDDisconnectionDetails
           * Invoked When: When Solution is loaded
           * Description : DIGI-926 : Make attributes visible only for MAC Disconnection
           * Parameters  : 
           ***********************************************************************************************************************************/
      
          SDWANPlugin.MACDDisconnectionDetails = async () => {
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
                          SDWANPlugin.updateAttributeVisiblity(['ChangeType'], SDWAN_COMPONENTS.solution, config.guid, false, true, false);
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
      
                              SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, true, true);
                              SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, true);
                          } else if (changeType[0].displayValue !== 'Cancel') {
      
                              Utils.emptyValueOfAttribute(config.guid, SDWAN_COMPONENTS.solution, "CancellationReason", true);
                              Utils.emptyValueOfAttribute(config.guid, SDWAN_COMPONENTS.solution, "DisconnectionDate", true);
                              SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, false, false);
                              SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
                          }
      
                      }
                  });
                  if (Object.values(currentSolution.schema.configurations)[0].macLock === false) {
                      await SDWANPlugin.UpdateChildMACDDisconnectionDetails();
                  }
      
              }
      
              return Promise.resolve(true);
          }
          /***********************************************************************************************************************************
           * Author	   : Payel/Radhika
           * Method Name : UpdateChildMACDDisconnectionDetails
           * Invoked When: When Solution is loaded for SD-WAN Adapt S1
           * Description : DIGI-926 : Make attributes visible only for MAC Disconnection
           * Parameters  : 
           ***********************************************************************************************************************************/
          SDWANPlugin.UpdateChildMACDDisconnectionDetails = async () => {
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
              //let currentSolution = await CS.SM.getActiveSolution();
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
      
                      }
                      SDWANPlugin.updateAttributeVisiblity(['ChangeType'], SDWAN_COMPONENTS.solution, config.guid, true, true, false);
                      SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionChildNonEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
                      //SDWANPlugin.updateAttributeVisiblity(['SecureEdge Tenancy ID'], SDWAN_COMPONENTS.solution, config.guid, true, true, false);
                      var listOfRelatedProducts = config.getRelatedProducts();
                      Object.values(listOfRelatedProducts).forEach((rp) => {
                          if (SDWAN_COMPONENTS.relatedProduct === rp.name && rp.configuration.attributes) {
                              SDWANPlugin.updateAttributeVisiblity(['Auto Data Top Up'], SDWAN_COMPONENTS.solution, rp.guid, true, true, false);
                          }
                      });
                      if (changeType[0].displayValue === 'Cancel') {
                          SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, true, true, false);
                      } else if (changeType[0].displayValue !== 'Cancel') {
                          SDWANPlugin.updateAttributeVisiblity(SDWAN_COMPONENTS.MACDSolutionEditableFields, SDWAN_COMPONENTS.solution, config.guid, false, false, false);
                      }
                  }
              });
      
              return Promise.resolve(true);
          }
          //DIGI-962 related to MACD Disconnection
          SDWANPlugin.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
              let solution = await CS.SM.getActiveSolution();
              let component = solution.getComponentByName(componentName);
              console.log('afterConfigurationAddedToMacBasket***', componentName, guid);
              //SDWANPlugin.updateChangeTypeAttribute();
              await SDWANPlugin.UpdateChildMACDDisconnectionDetails();
              await SDWANPlugin.MACDTenancyDetails();
              return Promise.resolve(true);
          }
          /***********************************************************************************************************************************
           * Author	   : Suyash
           * Method Name : UpdateChildAttributedonAdd
           * Invoked When: window.document.addEventListener, afterSave 
           * Description : Update LTE Mode Values based on Plan Selection
           * Parameters  : 
           ***********************************************************************************************************************************/
          SDWANPlugin.updateLTEModeValues = async () => {
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
              return Promise.resolve(true);
          }
      }
      
      
      /* 	 
          This method updates the Solution Name based on Offer Name if User didnt provide any input
      */
      async function updateSolutionName_SDWAN() {
          var listOfAttributes = ['Solution Name', 'GUID'],
              attrValuesMap = {};
          attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, SDWAN_COMPONENTS.solution);
          let solution = await CS.SM.getActiveSolution();
          let component = solution.getComponentByName(SDWAN_COMPONENTS.solution)
          let guid;
          console.log('attrValuesMap...' + attrValuesMap);
          if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_SDWAN) {
              let updateConfigMap = {};
              guid = attrValuesMap['GUID'];
              updateConfigMap[guid] = [];
              updateConfigMap[guid].push({
                  name: 'Solution Name',
                  value: DEFAULTSOLUTIONNAME_SDWAN,
                  displayValue: DEFAULTSOLUTIONNAME_SDWAN
              });
              if (updateConfigMap) {
                  if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                      keys = Object.keys(updateConfigMap);
                      for (let i = 0; i < keys.length; i++) {
                          //await solution.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                          component.lock('Commercial', false);
                          await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                      }
                  }
              }
          }
      
          return Promise.resolve(true);
      }
      
      async function addDefaultSDWAN_OETenancyConfigs() {
      
          console.log('addDefaultOEConfigs');
      
          if (basketStage !== 'Contract Accepted') {
              return;
          }
      
          var oeMap = [];
          let currentSolution = await CS.SM.getActiveSolution();
          console.log('currentSolution==>', currentSolution);
      
          if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
              console.log('addDefaultOEConfigs - looking components', currentSolution);
              let configs = currentSolution.getConfigurations();
              if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                  Object.values(currentSolution.components).forEach((comp) => {
                      Object.values(comp.schema.configurations).forEach((config) => {
                          Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                              if (oeSchema) {
                                  var found = false;
                                  if (config.orderEnrichmentList) {
                                      var oeConfig = config.orderEnrichmentList.filter(oe => {
                                          return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId)
                                      });
                                      if (oeConfig && oeConfig.length > 0)
                                          found = true;
                                  }
                                  if (!found) {
                                      var el = {};
                                      el.componentName = comp.name;
                                      el.configGuid = config.guid;
                                      el.oeSchema = oeSchema;
                                      oeMap.push(el);
                                      console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
                                  }
                              }
                          });
                      });
                  });
              }
          }
      
          if (oeMap.length > 0) {
              console.log('Adding default oe config map:', oeMap);
              for (var i = 0; i < oeMap.length; i++) {
                  let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
                  let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
                  component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
              }
          }
      
          await initializeSDWAN_OEConfigs();
          return Promise.resolve(true);
      }
      
      /***********************************************************************************************************************************
       * Author	   : Lalit
       * Method Name : initializeSDWAN_OEConfigs
       * Invoked When: after solution is loaded, after configuration is added
       * Description : 
       * Parameters  : none
       ***********************************************************************************************************************************/
      async function initializeSDWAN_OEConfigs() {
      
          console.log('initializeSDWAN_OEConfigs');
          let currentSolution = await CS.SM.getActiveSolution();
          let configurationGuid = '';
      
          if (currentSolution) {
              console.log('initializeSDWAN_OEConfigs - updating');
              if (currentSolution.name.includes(SDWAN_COMPONENTS.solution)) {
                  if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                      for (const comp of Object.values(currentSolution.components)) {
                          for (const config of Object.values(comp.schema.configurations)) {
                              configurationGuid = config.guid;
                              var updateMap = {};
                              if (config.orderEnrichmentList) {
                                  for (const oe of config.orderEnrichmentList) {
                                      var basketAttribute = Object.values(oe.attributes).filter(a => {
                                          return a.name.toLowerCase() === 'basketid'
                                      });
                                      if (basketAttribute && basketAttribute.length > 0) {
                                          if (!updateMap[oe.guid])
                                              updateMap[oe.guid] = [];
                                          updateMap[oe.guid].push({
                                              name: basketAttribute[0].name,
                                              value: basketId
                                          });
                                      }
                                  }
                              }
                              if (updateMap && Object.keys(updateMap).length > 0) {
                                  if (updateMap && Object.keys(updateMap).length > 0) {
                                      keys = Object.keys(updateMap);
                                      console.log('initializeOEConfigs updateMap:', updateMap);
                                      for (var i = 0; i < updateMap.length; i++) {
                                          comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid, keys[i], updateMap[keys[i]], true);
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      
          return Promise.resolve(true);
      }
      