/******************************************************************************************
Sr.No.  Author 			    Date			Sprint      Story Number	Description
1.      Arun Selvan		    28-Dec-2020					
2.      Pooja Bhat		    11-Oct-2021     S21.14      DIGI-8814       Show/Hide Site details 
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/

var ADAPTIVENETWORKS_COMPONENT_NAMES = {
	solutionname: "Adaptive Networks",
	TID_Adapt: "TID Adapt",
	AdaptiveAccess: "Access",
    BIP_Adapt: "BIP Adapt",
    SiteShowHideFieldDetails: ["Site Address", "Adbor ID", "SiteDetails", "Telstra Fibre SQ", "NBN Fibre SQ", "NBN Ethernet SQ"]
};

if (CS.SM.registerPlugin) { 
	window.document.addEventListener("SolutionConsoleReady", async function () {
		await CS.SM.registerPlugin("Adaptive Networks").then((AdaptiveNetworkPlugin) => {
                console.log("Plugin registered for Adaptive Networks"); 
                AdaptiveNetworkPlugin_updatePlugin(AdaptiveNetworkPlugin); 
            }); 
    }); 

} 
AdaptiveNetworkPlugin_updatePlugin = async function AdaptiveNetworkPlugin_updatePlugin(AdaptiveNetworkPlugin) {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		try {
			console.log("Inside ConnectivitySolution SolutionSetActive--->");
			let loadedSolution = await CS.SM.getActiveSolution();
			if (loadedSolution.componentType && loadedSolution.name.includes(ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname)) {
                let currentBasket = await CS.SM.getActiveBasket();
                await CommonUtills.getBasketData(currentBasket);
				if (window.accountId !== null && window.accountId !== "") {
					console.log(ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname);
                    CommonUtills.setAccountID(ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname, window.accountId);
					
                }    
                PRE_Logic.init(loadedSolution.name);
				PRE_Logic.afterSolutionLoaded();
            }
		} catch (error) {
			console.log("ERROR ", error);
        }
        return Promise.resolve(true);
    });
    
    AdaptiveNetworkPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
        console.log("AdaptiveNetworkPlugin Inside afterAttributeUpdated" + component.name + "  attribute.name=" + attribute.name + " attribute.value=" + attribute.value + " configuration.guid=" + configuration.guid);
        //Start:DIGI-8814
        if (component.solutionName === ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname) {
            if (attribute.name === "Site") {
                if(attribute.value) {
                    await updateAttributeVisiblity(ADAPTIVENETWORKS_COMPONENT_NAMES.SiteShowHideFieldDetails, ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname, configuration.guid, false, true, false);
                } else {
                    await updateAttributeVisiblity(ADAPTIVENETWORKS_COMPONENT_NAMES.SiteShowHideFieldDetails, ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname, configuration.guid, false, false, false);
                }
            }
        }
        //temporary function untill access type on Access is finalized  
        if(component.name === ADAPTIVENETWORKS_COMPONENT_NAMES.AdaptiveAccess && attribute.name === 'Access Type' && attribute.value !== '') {
            await createRelatedProduct(configuration);
        }
        //End:DIGI-8814 
        // Calling the Pricing Service on after attribute update
		PRE_Logic.afterAttributeUpdated(component, configuration, attribute, oldValueMap.value, attribute.value);
		return Promise.resolve(true);
	};

    AdaptiveNetworkPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log("AdaptiveNetworkPlugin Inside beforeSave");
		let currentSolution = await CS.SM.getActiveSolution();
		// Calling the Pricing Service on before save
		PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
        let res = await validationOnSave();
        if(!res) {
            return Promise.resolve(false);
        }
        return Promise.resolve(true);
	};
    
    AdaptiveNetworkPlugin.afterConfigurationAdd = async function (component, configuration) {
		console.log("AdaptiveNetworkPlugin Inside afterConfigurationAdd--->", component.name, configuration);
        PRE_Logic.afterConfigurationAdd(component.name,configuration);
        if(component.name === ADAPTIVENETWORKS_COMPONENT_NAMES.AdaptiveAccess) {
           // await createRelatedProduct(configuration);
        }
        return Promise.resolve(true);
	};

	AdaptiveNetworkPlugin.afterSave = function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		return Promise.resolve(true).then(
			//() => afterSaveValidation() //to be called at last 
		);
	};
            
    AdaptiveNetworkPlugin.afterRelatedProductAdd = async function (component, configuration, relatedProduct) {
        if(component.name === ADAPTIVENETWORKS_COMPONENT_NAMES.AdaptiveAccess){
            await slaConfigAdd(component, configuration, relatedProduct);
        }
        return Promise.resolve(true);
    };
}

async function validationOnSave() {
	let mainSolution = await CS.SM.getActiveSolution();
	let bidAdaptcount = 0;
	let tidAdaptcount = 0;
	let accessCount = 0;
	let attrReqCount = 0;
	let errorFlag = false
	if(mainSolution && mainSolution.name.includes(ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname)) {
		Object.values(mainSolution.components).forEach(function (comp) {
			Object.values(comp.getAllConfigurations()).forEach((config) => {
				if(comp.name === 'Access') {
					accessCount = accessCount+1;				
					Object.values(config.attributes).forEach((attr) => {
						if(attr.required === true && attr.value === '') {
							attrReqCount = attrReqCount+1;
						}
					});
				} else if(comp.name === 'TID Adapt') {
					tidAdaptcount = tidAdaptcount+1;
				} else if(comp.name === 'BID Adapt') {
					bidAdaptcount = bidAdaptcount+1;
				}
			});
		});
		if(accessCount === 0 || attrReqCount > 0) {
			CS.SM.displayMessage('Please Configure Access before Validate and Save','error');
			errorFlag = true;
		} else if(accessCount > 0 && tidAdaptcount === 0 && bidAdaptcount === 0) {
			CS.SM.displayMessage('Please add at least 1 TID Adapt or 1 BIP Adapt service','error');
			errorFlag = true;
		}
	}
	if(errorFlag) {
		return Promise.resolve(false);
	} else {
		return Promise.resolve(true);
	}

}

//Start:DIGI-8814 - Use this function to Show/Hide Attributes
async function updateAttributeVisiblity(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
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
    return Promise.resolve(true);
}
//End:DIGI-8814

async function createRelatedProduct(config) {
    let solution = await CS.SM.getActiveSolution();
    let accessComp = await solution.getComponentByName(ADAPTIVENETWORKS_COMPONENT_NAMES.AdaptiveAccess);
    let accessType = Object.values(config.attributes).filter(obj =>{return obj.name === 'Access Type'});
    if(Object.values(config.relatedProducts).length === 0) {       
        CommonUtills.addRelatedProductonConfigurationAdd(accessComp, config, accessComp.name,'Service Management', false, 1);
    }  else {
        Object.values(config.relatedProducts).forEach((relPro) => {
            accessComp.updateConfigurationAttribute(relPro.guid,[{name:'Access Type',value:accessType[0].displayValue}],true);         
        });
    }
    return Promise.resolve(true);
}

async function slaConfigAdd(component, config, relatedProduct) {
    let solution = CS.SM.getActiveSolution();
    let accessType = Object.values(config.attributes).filter(obj =>{return obj.name === 'Access Type'});
    let redunType  = Object.values(config.attributes).filter(obj =>{return obj.name === 'Redundancy Type'});
    Object.values(relatedProduct.configuration).forEach((cfg)=>{
        component.updateConfigurationAttribute(relatedProduct.guid,[{name:'Access Type',value:accessType[0].value}],true);
    	if(relatedProduct.name === 'Additional Port') {
       		component.updateConfigurationAttribute(relatedProduct.guid,[{name:'Redundancy Type',value:redunType[0].displayValue}],true); 
    	}
    });   
}