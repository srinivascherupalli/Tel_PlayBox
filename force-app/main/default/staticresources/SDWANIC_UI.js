/*
 * Handles all UI-related logic
 */
console.log('[SDWANIC_UI] loaded');

const SDWANIC_UI = {};

/**
* Provides the user with an opportunity to do something once the attribute is updated.
*
* @param {string} component - Component object where the configuration resides
* @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
* @param {object} attribute - The attribute which is being updated.
* @param {string} oldValueMap - Before change value.
*/

SDWANIC_UI.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
	try {
			let currentSolution = await CS.SM.getActiveSolution();
			await SDWANIC_UI.MACDTenancyIdDetails();
			return Promise.resolve(true);
	} catch (error) {
		console.log('[SDWANIC_UI] beforeSave() exception: ' + error);
		return false;
	}
	return true;
};


SDWANIC_UI.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
			let currentSolution = await CS.SM.getActiveSolution();
			await SDWANIC_UI.InterConnectVPNattrUpdate();
			await SDWANIC_UI.InterConnectPOPattrUpdate(); //DIGI-26454
	} catch (error) {
		console.log('[SDWANIC_UI] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

SDWANIC_UI.afterConfigurationAddedToMacBasket = async function(componentName) {
	try {
		await SDWANIC_UI.AfterAddtoMacChange();
        await SDWANIC_UI.MACDTenancyIdDetails();
	} catch (error) {
		console.log('[SDWANIC_Delegate] afterConfigurationAddedToMacBasket() exception: ' + error);
		return false;
	}
	console.log('[SDWANIC_UI] ...end afterConfigurationAddedToMacBasket()');
	return true;
};

/***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectVPNattrUpdate
     * Invoked When: On Attribute update
     * Description : To Copy the value of VPN ID attribute 	- DIGI-18412
     * Parameters  : None	
     ***********************************************************************************************************************************/
SDWANIC_UI.InterConnectVPNattrUpdate = async function() {
	try {
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
       // return Promise.resolve(true);
	} catch (error) {
		console.log('[SDWANIC_UI] InterConnectVPNattrUpdate() exception: ' + error);
	}
	return Promise.resolve(true);
};

/***********************************************************************************************************************************	
     * Author	   	 :Radhika
     * Method Name : InterConnectPOPattrUpdate
     * Invoked When: On Attribute update,Aftersave,onLoad
     * Description : To update the PC name according to pop-DIGI-26454
     * Parameters  : None	
     ***********************************************************************************************************************************/
SDWANIC_UI.InterConnectPOPattrUpdate = async function() {
    try {
        let pop1;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        if (currentSolution.name.includes(SDWANVPN_COMPONENTS.InterConnectSol)) {
            ///let configs = currentComponent.getConfigurations();
            var updateMapChild = {};
            Object.values(currentComponent.schema.configurations).forEach((configs) => {
                updateMapChild[configs.guid] = [];
                if (configs.guid) {
                let attribs = Object.values(configs.attributes);
                pop1 = attribs.filter((c) => {
                return c.name === "PoP";
            });
                var configName;
                if(pop1[0].value !='') {
                configName = 'VeloCloud SDWAN-VPN Interconnect - '+ pop1[0].value;
            }
                else
                {
                configName = 'VeloCloud SDWAN-VPN Interconnect';
            }
                updateMapChild[configs.guid].push({
                name: "ConfigName",
                value: configName,
                displayValue: configName
            });
        }
        configs.configurationName = configName;
        
    });
}
let keys = Object.keys(updateMapChild);
currentComponent.lock('Commercial', false);
for (let i = 0; i < keys.length; i++) {
    currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
}
// return Promise.resolve(true);
} catch (error) {
    console.log('[SDWANIC_UI] InterConnectVPNattrUpdate() exception: ' + error);
}
return Promise.resolve(true);
};

 /***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : AfterAddtoMacChange
     * Invoked When: On clicking on Add to Mac basket
     * Description : To display simple Validation message 	- DIGI-18412
     ***********************************************************************************************************************************/
SDWANIC_UI.AfterAddtoMacChange = async function() {
	try {
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

		
        //return Promise.resolve(true);
    	} catch (error) {
		console.log('[SDWANIC_UI] AfterAddtoMacChange() exception: ' + error);
	}
	return Promise.resolve(true);
};
/***********************************************************************************************************************************
* Author	  : Payel
* Method Name : MACDTenancyIdDetails
* Invoked When: When Solution is loaded
* Description : Update the Tenancy Id,SDWANTenancyProductInstanceID for MACDsenario
* Parameters  : 
***********************************************************************************************************************************/
 SDWANIC_UI.MACDTenancyIdDetails = async () => {
	 try {
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
	 
              //return Promise.resolve(true);
	 }catch (error) {
		console.log('[SDWANIC_UI] MACDTenancyIdDetails() exception: ' + error);
	}
	return Promise.resolve(true);	 
          };
          