/*
 * Handles all validation logic
 */
console.log('[SecureEdge_Validation] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const SES_Validation = {};

SES_Validation.beforeSave = async function (solution) {

	console.log("Inside beforeSave");
	try{

		let solution = await CS.SM.getActiveSolution();

		let secureEdgeRemoteComponent = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote);
		let remotConfigs = secureEdgeRemoteComponent.getConfigurations();
		let remoteChangeType;
		let remoteSoftDeleted;

		if(Object.values(remotConfigs).length > 0){

			// if(await checkCancelAttributes(secureEdgeRemoteComponent.name,'')){
			//     await performSoftDelete(component,configuration);
			// }

			Object.values(remotConfigs).forEach((config) => {
				if (config.guid) {
					let attribs = Object.values(config.attributes);
					console.log(attribs);
					remoteChangeType = attribs.filter((obj) => {
						return obj.name === "ChangeType";
					});
					remoteSoftDeleted = config.softDeleted;
				}
			});
			if(remoteChangeType != undefined && remoteChangeType[0].value == 'Cancel' && remoteSoftDeleted == false){
				CS.SM.displayMessage("Please reselect cancellation reason/ disconnection date", "info");
				return Promise.resolve(false);
			}
		}
			
		let secureEdgeCloudComponent = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloud)
		let cloudConfigs = secureEdgeCloudComponent.getConfigurations();
		let externalIpSoftDeleted;
		let externalIPChangeType;
		let addOnBandwidthshadow;
		//let conf = component.getConfigurations();
		if(Object.values(cloudConfigs).length > 0){
			// if(await checkCancelAttributes(secureEdgeExternalIPComponent.name,'')){
			// 	console.log('Test');
			// }
			Object.values(cloudConfigs).forEach(function(confs){
				let cloudAttrb = Object.values(confs.attributes);
				addOnBandwidthshadow = cloudAttrb.filter((obj) => {
					return obj.name === "Add-On Bandwidth";
				});
				let relatedProducts = confs.getRelatedProducts();
				Object.values(relatedProducts).forEach(function(relatedProd){
					let attribs = Object.values(relatedProd.configuration.attributes);
					console.log(attribs);
					externalIPChangeType = attribs.filter((obj) => {
						return obj.name === "ChangeType";
					});

					externalIpSoftDeleted = relatedProd.configuration.softDeleted

				});
			});
			if(externalIPChangeType != undefined && externalIPChangeType[0].value == 'Cancel' && externalIpSoftDeleted == false){
				CS.SM.displayMessage("Please reselect cancellation reason/ disconnection date", "info");
				return Promise.resolve(false);
			}

			if (window.basketStage === "Contract Accepted" && modbasketChangeType == 'Change Solution'){
				if(addOnBandwidthshadow != undefined && addOnBandwidthshadow[0].value != ''){
					var updateMap = {};
					Object.values(cloudConfigs).forEach(function(confs){
					
						updateMap[confs.guid] = [];
							updateMap[confs.guid].push({
								name: 'AddOnBandWidthShadow',
								value: addOnBandwidthshadow[0].value,
						});
						secureEdgeCloudComponent.updateConfigurationAttribute(confs.guid,updateMap[confs.guid],true);
					});  
				}
			}
		}
			
		//Pricing Service changes DIGI-27353
		//PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);

		//solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote).getConfiguration('3094b857-3f3a-a3ff-5400-cdb9306bc618').softDeleted
		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
			solution.lock("Commercial", false);
		}
		
		return Promise.resolve(true);

	} catch(error){
		console.log('[SecureEdge_Validation] beforeSave() exception: ' + error);
	}
	
};


SES_Validation.beforeRelatedProductDelete = async function(configuration, relatedProduct) {
	try {
		if(relatedProduct.configuration.replacedConfigId){
            CS.SM.displayMessage("Cannot delete External IP address as it is already configured", "info");
            return Promise.resolve(false);
        }
	} catch(error){
		console.log('[SecureEdge_Validation] beforeRelatedProductDelete() exception: ' + error);
	}
};