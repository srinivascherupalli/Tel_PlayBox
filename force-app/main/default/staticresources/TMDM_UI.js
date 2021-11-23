/*
 * Handles all UI-related logic
 */
console.log('[TMDM_UI] loaded');

const TMDM_UI = {};

/*********************************
* Author	  : Shresth Dixit
* Method Name : handleButtonVisibility
* Defect/US # : DPG-2084
* Invoked When: On Solution Load
* Description : For Setting Visibility
* Modified By : Payal : Modified as a part of EDGE-189788
*********************************/
TMDM_UI.handleButtonVisibility = function(solution) {
	try {
		//shresth DPG-2084
		var readOnly = false;
		
		if (solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				var offerid = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter((att) => {
					return att.name === "OfferId";
				});
				
				if(offerid[0].value == undefined || offerid[0].value == "") {
					readOnly = true;
				}				
				let component = solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
				
				if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0) {
					Object.values(component.schema.configurations).forEach((config)=> {
						let attnameToattMap ={};
						var guid = config.guid;
						attnameToattMap[guid] = [];
						attnameToattMap[guid].push({
							name: 'TMDMRateCard',
							readOnly: readOnly
						});
						
						if (attnameToattMap && Object.keys(attnameToattMap) && Object.keys(attnameToattMap).length > 0) {
							component.updateConfigurationAttribute(guid, attnameToattMap[guid], true);
						}
					});
				}
			}
		}
	} catch (error) {
		console.log('[TMDM_UI] handleButtonVisibility() exception: ' + error);
	}	
};

TMDM_UI.setOEtabsforPlatform = function(solution) {
	try {
		if (solution.componentType && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			let comp = solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
			
			if (comp) {
				if (Utils.isOrderEnrichmentAllowed()) {
					let configurations = comp.getConfigurations();
					
					if (configurations) {
						Object.values(configurations).forEach((config) => {
							CS.SM.setOEtabsToLoad(comp.name, config.guid, ["Tenancy Contact Details"]);
						});
					}
				}
			}
		}
	} catch (error) {
		console.log('[TMDM_UI] setOEtabsforPlatform() exception: ' + error);
	}
};