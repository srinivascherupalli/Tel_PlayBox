/******************************************************************************************
 * Author	   : DPG Oxygen
 Change Version History
Version No	Author 			Date        Change Description 
1. 			Payel/Sharmila		 	14-Sept-21	Initial file  - DIGI-18412/DIGI-21432
 ********************/
var SDWANVPN_COMPONENTS = {

    InterConnectSol: 'VeloCloud SDWAN-VPN Interconnect solution',
    InterConnect: 'VeloCloud SDWAN-VPN Interconnect',
	opportunityType: 'MACs (Moves, Adds & Change)'
};

if (!CS || !CS.SM) {
    throw Error('Solution Console Api not loaded?');
}

if (CS.SM.registerPlugin) {
    console.log('Load Interconnect plugin');
    window.document.addEventListener('SolutionConsoleReady', async function() {
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('VeloCloud SDWAN-VPN Interconnect solution')
            .then(async InterconnectPlugin => {
                updateInterconnectPlugin(InterconnectPlugin);
            });
    });
}

function updateInterconnectPlugin(InterconnectPlugin) {
    console.log('inside interconnect hooks', InterconnectPlugin);
    window.document.addEventListener('SolutionSetActive', async function(e) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
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
				opptyType = basket.Opportunity_Type__c;
                console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId)
                window.oeSetBasketData(solution, basketStage, accountId);
                if (accountId != null) {
                    CommonUtills.setAccountID(SDWANVPN_COMPONENTS.InterConnectSol, accountId);
                }
            });
            await InterconnectPlugin.MACDTenancyIdDetails();
            //await InterconnectPlugin.PoPCheckAccount();
            if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  solution.lock("Commercial", true);
              }
        }
        return Promise.resolve(true);
    });

    //Event to handle load of OE tabs
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
        let solution = await CS.SM.getActiveSolution();
        if (solution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
            console.log('OrderEnrichmentTabLoaded', e);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });


    InterconnectPlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
              console.log("Inside beforeSave");
              let currentSolution = await CS.SM.getActiveSolution();
              if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  currentSolution.lock("Commercial", false);
              }
               await InterconnectPlugin.MACDTenancyIdDetails();
               await InterconnectPlugin.InterConnectVerification();
               let checkFlag1 = await InterconnectPlugin.InterConnectPopValidation();
               let checkFlag = await InterconnectPlugin.PoPCheckAccount();
               if (checkFlag == true || checkFlag1 == true)
               {
               	CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
               	 return Promise.resolve(false);
               }              
               else
               {
               return Promise.resolve(true);
               }
          }


    /**
     * Hook executed before we save the complex product to SF. We need to resolve the promise as a
     * boolean. The save will continue only if the promise resolve with true.
     * Updated by : 
     * To create case for the configuration in case the business criteria w.r.t to pricing has met
     * @param {Object} complexProduct
     */
    InterconnectPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
              let solution = result.solution;
              if (solution == null || solution == undefined) solution = await CS.SM.getActiveSolution();
              if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                  solution.lock("Commercial", true);
              }
			   await Utils.updateActiveSolutionTotals();
              CommonUtills.updateBasketDetails();
	}

    /**
     * Hook executed after the Order Enrichment configuration is added via the UI add configuration button
     *
     * @param {string} component - Component object where the configuration resides
     * @param {Object} configuration - Main configuration object for which OE configuration is  created
     * @param {Object} orderEnrichmentConfiguration - Order Enrichment Configuration which is inserted
     */
    InterconnectPlugin.afterOrderEnrichmentConfigurationAdd = async function(component, configuration, orderEnrichmentConfiguration) {
        initializeVeloOETenancyConfigs();
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    }

    /**
     * Hook executed after the Order Enrichment configuration is deleted via the UI delete configuration button
     *
     * @param {string} component - Component object where the configuration resides
     * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
     * @param {Object} orderEnrichmentConfiguration - Order Enrichment object which is deleted
     */
    InterconnectPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
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
    InterconnectPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
        let currentSolution = await CS.SM.getActiveSolution();
        console.log('Attribute Update - After', component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);       
        await InterconnectPlugin.InterConnectVPNattrUpdate();
        return Promise.resolve(true);
    }
    //Aditya: Spring Update for changing basket stage to Draft
    InterconnectPlugin.afterSolutionDelete = function(solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }


    InterconnectPlugin.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
              let solution = await CS.SM.getActiveSolution();
              let component = solution.getComponentByName(componentName);
              console.log('afterConfigurationAddedToMacBasket***', componentName, guid);
              //SDWANPlugin.updateChangeTypeAttribute();
              InterconnectPlugin.AfterAddtoMacChange();
              
              return Promise.resolve(true);
          }


    /***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectVerification
     * Invoked When: Before Save on clicking on Validate and Save
     * Description : To display simple message 	- DIGI-18412
     * Parameters  : None	
     ***********************************************************************************************************************************/
    InterconnectPlugin.InterConnectVerification = async () => {
        var VPN_ID;
        let currentSolution = await CS.SM.getActiveSolution();

        Object.values(currentSolution.schema.configurations).forEach((config) => {
            if (config.guid) {
                let attribs = Object.values(config.attributes);
                VPN_ID = attribs.filter((c) => {
                    return c.name === "VPN ID";
                });
            }
        });
        console.log('VPN ID ==>' + VPN_ID);
        if (VPN_ID[0].displayValue === null || VPN_ID[0].displayValue === "" || VPN_ID[0].displayValue === " ") {
            CS.SM.displayMessage("Please enter the IP-VPN ID of customer for which the interconnect is required", "error");
        }
            return Promise.resolve(true);
    }
    /***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectPopValidation
     * Invoked When: Before Save on clicking on Validate and Save
     * Description : To display simple Validation message 	- DIGI-18412
     ***********************************************************************************************************************************/
    InterconnectPlugin.InterConnectPopValidation = async () => {
        var iPop;
        var i;
        var iPop_arr = new Array();
        var checkFlag1 = false;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = currentComponent.getConfigurations();
        Object.values(currentComponent.schema.configurations).forEach((configs) => {
            if (configs.guid) {
                let attribs = Object.values(configs.attributes);
                iPop = attribs.filter((c) => {
                    return c.name === "PoP";
                });
            }
            iPop_arr.push(iPop[0].displayValue);
        });
        console.log('PoP ==>' + iPop);
        console.log('iPop_arr ==>' + iPop_arr);
        for (i = 0; i <= iPop_arr.length; i++) {
    for (j = 0; j <= iPop_arr.length; j++) {
		if(i !== j) {
			if (iPop_arr[i] === iPop_arr[j] && iPop_arr[i] !== undefined && iPop_arr[j] !== undefined ) {
			checkFlag1 = true;            
        }
		}
    } 
    }
    /*if (checkFlag1 = true)
    {
    	CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
    }
        //return Promise.resolve(true);*/
        return checkFlag1;
    }
    /***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectVPNattrUpdate
     * Invoked When: On Attribute update
     * Description : To Copy the value of VPN ID attribute 	- DIGI-18412
     * Parameters  : None	
     ***********************************************************************************************************************************/
    InterconnectPlugin.InterConnectVPNattrUpdate = async () => {
        let vpnId1;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnectSol);
        //let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        if (currentSolution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
            let configs = currentComponent.getConfigurations();
            Object.values(currentComponent.schema.configurations).forEach((configs) => {
                if (configs.guid) {
                    let attribs = Object.values(configs.attributes);
                    vpnId1 = attribs.filter((c) => {
                        return c.name === "VPN ID";
                    });
                }

            });
        }
        console.log('vpnId1 ==>' + vpnId1);
        let childComp = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = childComp.getConfigurations();
        var updateMapChild = {};
        Object.values(configs).forEach((config) => {
            if (config.attributes) {
                updateMapChild[config.guid] = [];
                updateMapChild[config.guid].push({
                    name: "VPN ID",
                    value: vpnId1[0].displayValue,
                    displayValue: vpnId1[0].displayValue
                });
            }
        });
        let keys = Object.keys(updateMapChild);
        currentComponent.lock('Commercial', false);
        for (let i = 0; i < keys.length; i++) {
            currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
        }
        return Promise.resolve(true);
    }
	
	
/***********************************************************************************************************************************
* Author	  : Payel
* Method Name : MACDTenancyIdDetails
* Invoked When: When Solution is loaded
* Description : Update the Tenancy Id,SDWANTenancyProductInstanceID for MACDsenario
* Parameters  : 
***********************************************************************************************************************************/
 InterconnectPlugin.MACDTenancyIdDetails = async () => {
              let currentSolution = await CS.SM.getActiveSolution();
              let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
              if (currentSolution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
                  let configs = currentComponent.getConfigurations();
                  var updateMapChild = {};
                  Object.values(configs).forEach((config) => {
                      if (config.attributes) {
                          updateMapChild[config.guid] = [];
                          updateMapChild[config.guid].push({
                              name: "OpptyType",
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
              if (opptyType.toLowerCase() === (SDWANVPN_COMPONENTS.opportunityType).toLowerCase()) {
                  let inputMap = {};
                  inputMap['GetTenancyDetailsforService'] = accountId;
                  await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                      console.log('GetTenancyDetailsforService finished with response: ', result);
                      var subs = JSON.parse(result["GetTenancyDetailsforService"]);
                      console.log('GetTenancyDetailsforService: ', subs);
                      tenguId = subs.vCguId;
                      tenId = subs.Tenancy_Id;
                  });
                  let currentSolution = await CS.SM.getActiveSolution();
                  var TenancyId;
                  let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
                  if (currentSolution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
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
                                      value: TenancyVal,
                                      displayValue: TenancyVal
                                  });
                                  updateMapChild[config.guid].push({
                                      name: "SDWANTenancyProductInstanceID",
                                      showInUi: false,
                                      readOnly: true,
                                      value: tenguId,
                                      displayValue: tenguId
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
              }
              return Promise.resolve(true);
          }  
/***********************************************************************************************************************************
* Author	  : Payel
* Method Name : PoPCheckAccount
* Invoked When: On Clicking on Validate and Save (Before Save)
* Description : Checks whether any Basket on the CIDN has an active subscription with the same POP
* Parameters  : 
***********************************************************************************************************************************/
 InterconnectPlugin.PoPCheckAccount = async () => {
              var iPop_arr = new Array();
              var i;
              var iPop;
              var checkFlag = false;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = currentComponent.getConfigurations();
        Object.values(currentComponent.schema.configurations).forEach((configs) => {
            if (configs.guid) {
                let attribs = Object.values(configs.attributes);
                iPop = attribs.filter((c) => {
                    return c.name === "PoP";
                });
            }
            //added as part of defect 32939
            if (configs.replacedConfigId == undefined || configs.replacedConfigId == null || configs.replacedConfigId == "")
            {
            iPop_arr.push(iPop[0].displayValue);
            }
            //iPop_arr.push(iPop[0].displayValue);
        });
        console.log('PoP ==>' + iPop);
        console.log('iPop_arr ==>' + iPop_arr);
		let inputMap = {};
                  inputMap['GetInterConDetails'] = accountId;
				  await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                      console.log('GetInterConDetails finished with response: ', result);
					  var PoPattr = JSON.parse(result["GetInterConDetails"]);
                      console.log('GetInterConDetails: ', PoPattr);
                       console.log('GetInterConDetails: ', PoPattr[0]);
                       Object.values(PoPattr).forEach((pOp) => {
                               console.log(pOp.PoP);
							  iPop_arr.push(pOp.PoP);
							  console.log(iPop_arr);
							  
		          });

         });
         for (i = 0; i <= iPop_arr.length; i++) {
    for (j = 0; j <= iPop_arr.length; j++) {
		if(i !== j) {
			if (iPop_arr[i] === iPop_arr[j] && iPop_arr[i] !== undefined && iPop_arr[j] !== undefined ) {
				checkFlag = true;            
        }
		}
    } 
    }
   /* if (checkFlag == true)
    {
    	CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
    }*/
    return checkFlag;
 }   

  /***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : AfterAddtoMacChange
     * Invoked When: On clicking on Add to Mac basket
     * Description : To display simple Validation message 	- DIGI-18412
     ***********************************************************************************************************************************/
    InterconnectPlugin.AfterAddtoMacChange = async () => {
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = currentComponent.getConfigurations();
        var updateMapChild = {};
        Object.values(currentComponent.schema.configurations).forEach((config) => {
            if (config.attributes) {
				updateMapChild[config.guid] = [];
                              updateMapChild[config.guid].push({
                                  name: "ChangeType",
                                  value: "Active",
                                  displayValue: "Active",
                                  showInUi: true,
                                 readOnly: true
                              });
			
			let keys = Object.keys(updateMapChild);
                              currentComponent.lock('Commercial', false);
                              for (let i = 0; i < keys.length; i++) {
                                  currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                              }
            }
        });

		
        return Promise.resolve(true);
    }
}
