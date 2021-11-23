/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[IoTConn_Utils] loaded');

const IOTCONN_Utils = {};

/*********************************
* Author	  : Aruna Aware
* Method Name : addDefaultIOTConfigs
* Defect/US # : DPG-1692 & DPG-1723
* Invoked When: After Click on Solution
* Description : Check for bulk enrichment values
*********************************/
IOTCONN_Utils.addDefaultIOTPlansConfigs = async function() {
	try {
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
		await IOTCONN_Utils.initializeIOTPlansConfigs();
	} catch (error) {
		console.log('[IoTConn_Utils] addDefaultIOTPlansConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};

    /******************************************************************************************
        * Author : Rozi Firdaus
        * Story Number : DIGI-2576
        * Description : Validate Quantity based on SIM Type in Product Basket
        * Method Name : checkQuantityForNBiotSimType
        * Invoked When: after attribute update
                    
    ********************************************************************************************/
      IOTCONN_Utils.checkQuantityForNBiotSimType = async function(currentSolution) {
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
	  
		

	 

/*********************************
* Author	  : Aruna Aware
* Method Name : initializeIOTConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. sets basket id to oe configs so it is available immediately after opening oe
* Parameters  : none
*********************************/
IOTCONN_Utils.initializeIOTPlansConfigs = async function(oeguid) {
	try {
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
											updateMap.set(oe.guid, [{
												name: basketAttribute.name,
												value: basketId
											}]);
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
	} catch (error) {
		console.log('[IoTConn_Utils] initializeIOTPlansConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};
