/*
 * Utility methods for this product; can be referenced from any of the modules
 */
console.log('[SecureEdge_Utils] loaded');

const SES_Utils = {};

/*********************************
* Author	   : Sharmila Eltepu
* Method Name : afterRelatedProductAdd
* Invoked When: after related product is added
* Description : 1. Reads contract term value from the main component (i.e, SecureEdge)
* Parameters  : none
*********************************/
SES_Utils.afterRelatedProductAdd = async function(relatedProduct) {
	try {
		var Ext_contTerm;
		let currentSolution = await CS.SM.getActiveSolution();
		Object.values(currentSolution.schema.configurations).forEach((config) => {
			if (config.guid) {
				let attribs = Object.values(config.attributes);
				Ext_contTerm = attribs.filter((b) => {
					return b.name === "Contract Term";
				});
			}
		});
		var exContTerm = Ext_contTerm[0].value;
		
		if (relatedProduct.name === "External IP Address") {
			solution.updateConfigurationAttribute(relatedProduct.guid, [{
				name: "Contract Term",
				value: exContTerm
			}]);
		}
	} catch (error) {
		console.log('[SecureEdge_Utils] afterRelatedProductAdd() exception: ' + error);
	}
};


/*SES_Utils.beforeRelatedProductAdd = async function(configuration, relatedProduct){
        try{
			return Promise.resolve(true);
		} catch (error) {
		console.log('[SecureEdge_Utils] beforeRelatedProductAdd() exception: ' + error);
		}
    }; */

/*********************************
* Author	  : Sharmila Eltepu
* Method Name : afterAttributeUpdated
* Invoked When: after attribute is updated on SecureEdge Cloud and SecureEdge Cloud Remote
* Description : When the Quantity value is updated on an Attribute, the monthly charge value should be calculated and populate on UI
* Parameters  : none
*********************************/
SES_Utils.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
	try {
		if (attribute.name === "RemoteWorkerQuantity") {
			let recCharge = configuration.getAttribute('add-on recurring charge').value; //Assumes that the commercial product lookup is named "CommercialProduct"
			var regExp = /^\d+\.\d{0,10}$/;
			
			if (attribute.value <= 0 || attribute.value > 500 || regExp.test(attribute.value)) {
				CS.SM.displayMessage("Please enter Remote Worker Quantity between 1 - 500", "error");
				return Promise.resolve(false);
			} else {
				let remoteQuantity = attribute.value * recCharge;
				solution.updateConfigurationAttribute(configuration.guid, [{
					name: "AddOnRemoteWorkerMonthlyCharge",
					value: remoteQuantity
				}]);
			}
		}
		if (attribute.name === "ExternalIPAddressQuantity") {
			let recChargeExt = configuration.getAttribute('add-on recurring charge').value; //Assumes that the commercial product lookup is named "CommercialProduct"
			let extQuantity = attribute.value * recChargeExt;
			solution.updateConfigurationAttribute(configuration.guid, [{
				name: "Add-OnExternalIPAddressesMonthlyCharge",
				value: extQuantity
			}]);
		}
        
        if (window.basketStage === "Contract Accepted") {
			var configGUID = configuration.parentConfiguration; //Changed as per suggestion from Vimal           
			var schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
            
            if (component.name === 'Customer requested Dates') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            }  
            if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            }
        }
		
		//DIGI-10035 show and hide 'RemoveAdd on bandwidth' checkbox when change type on scureEdge cloud is change
            if(attribute.name === "ChangeType" && configuration.configurationName === SecureEdge_COMPONENTS.SecureEdgeCloud){
                debugger;
                if(attribute.value == "Modify"){
                    var bandwidth;
                    if (component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0) {
                        Object.values(component.schema.configurations).forEach((config) => {
                            if (config.guid) {
                                let attribs = Object.values(config.attributes);
                                bandwidth = attribs.filter((obj) => {
                                    return obj.name === "Add-On Bandwidth";
                                });
                            }
                        });
                    }
                    if(bandwidth[0].value == ''){
                        SES_UI.updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, false, false);
                    }else{
                        SES_UI.updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    }

                    SES_UI.updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    //update child change type as active
                    SES_UI.updateExtenalIPChangeType(configuration.getRelatedProducts(), false);
                    
                }else{
                    var updateMap = {};
                    updateMap[configuration.guid] = [];
                        updateMap[configuration.guid].push({
                            name: 'RemoveAdd-OnBandwidth',
                            value: false,
                    });

                    await component.updateConfigurationAttribute(configuration.guid,updateMap[configuration.guid],true);
                    SES_UI.updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, false, false);
                    SES_UI.updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, true, true, false);
                    
                    //update child change type as active
                    SES_UI.updateExtenalIPChangeType( configuration.getRelatedProducts(), true);
                   
                }
            }
			
			//DIGI-10035 update attribute visibility on External IP and show/hide Cancellation fields
            if(attribute.name === "ChangeType" && configuration.configurationName.includes(SecureEdge_COMPONENTS.ExternalIP)){

                //DIGI-26333
                if(["Cancel", "Active"].includes(attribute.value)){
                    SES_UI.updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, true, true, false);
                }else{
                    SES_UI.updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, true);
                }
            
                if(attribute.value == "Cancel"){
                    //Changes related to DIGI-14132/DIGI-14133 start
                    if(await SES_Utils.checkCancelAttributes(component.name,configuration)){
                        await SES_Utils.performSoftDelete(component,configuration);
                    }
                    //Changes related to DIGI-14132/DIGI-14133 end
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, true);
                }else{
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloud, 
                                             configuration.guid, false, false, false);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloud, "CancellationReason", true);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloud, "DisconnectionDate", true);
                }
            }
			
			//DIGI-11880
            if(attribute.name === "RemoveAdd-OnBandwidth" ){
                var updateMap = {};
                if(attribute.value){
                    updateMap[configuration.guid] = [];
                        updateMap[configuration.guid].push({
                            name: 'Add-On Bandwidth',
                            value: '',
                           displayValue: '',
                    });
                    await component.updateConfigurationAttribute(configuration.guid, updateMap[configuration.guid], true)
                    SES_UI.updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, true, true, false);
                }else{
                    //Changes relaeted to DIGI-14132/DIGI-14133 start
                    let attribs = Object.values(configuration.attributes);
					let addonBandwidthShadowId;
					console.log(attribs);
					addonBandwidthShadowId = attribs.filter((obj) => {
						return obj.name === "AddOnBandWidthShadow";
					});
                    
                    let inputMap = {};
                    inputMap['GetCommercialProductDetails'] = addonBandwidthShadowId[0].value;
                    let commercialProduct
                    await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                        commercialProduct = JSON.parse(result["GetCommercialProductDetails"]);
                        //secgu_ID = subs.sEgu_Id;
                        //cloudTenancyId = subs.TenancySecId;
                    });

                    if(commercialProduct != undefined && commercialProduct != null && commercialProduct!=''){

                        updateMap[configuration.guid] = [];
                        updateMap[configuration.guid].push({
                            name: 'Add-On Bandwidth',
                            value: addonBandwidthShadowId[0].value,
                            displayValue: commercialProduct.Bandwidth,
                        });
                        updateMap[configuration.guid].push({
                            name: 'SecureEdge Add-On Bandwidth Monthly Charge',
                            value: commercialProduct.RecurringCharge,
                            displayValue: commercialProduct.RecurringCharge,
                        });
                        updateMap[configuration.guid].push({
                            name: 'Bandwidth Value',
                            value: commercialProduct.Bandwidth,
                            displayValue: commercialProduct.Bandwidth,
                        });

                    
                        await component.updateConfigurationAttribute(configuration.guid, updateMap[configuration.guid], true);
                        //Changes relaeted to DIGI-14132/DIGI-14133 end
                    }

                    SES_UI.updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    SES_UI.updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                }
            }
			
			if(attribute.name === "ChangeType" && configuration.configurationName === SecureEdge_COMPONENTS.SecureEdgeCloudRemote){
                if(attribute.value == "Modify"){
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, false, true, false);
                }else{
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, true, true, false);
                }

                if(attribute.value == "Cancel"){
                    //Changes related to DIGI-14132/DIGI-14133 start
                    if(await SES_Utils.checkCancelAttributes(component.name,configuration)){
                        //await SES_Utils.performSoftDelete(component,configuration);
                    }
                    //Changes related to DIGI-14132/DIGI-14133 end
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, false, true, true);
                }else{
                    SES_UI.updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, false, false, false);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, "CancellationReason", true);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, "DisconnectionDate", true);
                }
            }
            //Changes related to DIGI-14132/DIGI-14133 start
            if(SecureEdge_COMPONENTS.MACDCancelSolutionFields.includes(attribute.name)){
                if(await SES_Utils.checkCancelAttributes(component.name,configuration)){
                   // await SES_Utils.performSoftDelete(component,configuration);
                }
            }
            //Changes related to DIGI-14132/DIGI-14133 end

            //Changes relaeted to DIGI-14132/DIGI-14133
            if(attribute.name === "Add-On Bandwidth"){

                let attribs = Object.values(configuration.attributes);
                let changeType;
                console.log(attribs);
                changeType = attribs.filter((obj) => {
                    return obj.name === "ChangeType";
                });
                

                if(changeType != undefined && changeType[0].value == 'New'){
                    var updateMap = {};
                    updateMap[configuration.guid] = [];
                        updateMap[configuration.guid].push({
                            name: 'AddOnBandWidthShadow',
                            value: attribute.value,
                    });

                    await component.updateConfigurationAttribute(configuration.guid,updateMap[configuration.guid],true)
                }
            }
            //Changes relaeted to DIGI-14132/DIGI-14133

            //Pricing Service changes DIGI-27353
            //PRE_Logic.afterAttributeUpdated(component.name, configuration, attribute, oldValueMap.value, attribute.value);
			
		return Promise.resolve(true);
	} catch (error) {
		console.log('[SecureEdge_Utils] afterAttributeUpdated() exception: ' + error);
	}
};

/* 	 
This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
SES_Utils.updateSolutionName_SecureEdge = async function() {
	try {
		var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
		attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,SecureEdge_COMPONENTS.SecureEdgeSol);
		let solution = await CS.SM.getActiveSolution();
		let component = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol);
		let guid;
		
		if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_SecureEdge) {
			let updateConfigMap = {};
			guid = attrValuesMap['GUID'];
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'Solution Name',
				value: DEFAULTSOLUTIONNAME_SecureEdge,
				displayValue: DEFAULTSOLUTIONNAME_SecureEdge
			});
			
			if (updateConfigMap) {
				if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					keys = Object.keys(updateConfigMap);
					
					for (let i = 0; i < keys.length; i++) {
						component.lock('Commercial',false);
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			}
		}
		return Promise.resolve(true);
	} catch (error) {
		console.log('[SecureEdge_Utils] updateSolutionName_SecureEdge() exception: ' + error);
	}
};


/**
 * Author	   : Suyash 
 * Description : Changes related to DIGI-14132/DIGI-14133
 **/
SES_Utils.checkCancelAttributes = async function(componentName, configuration){
	try{
    let activeSolution = await CS.SM.getActiveSolution();
    let component;
    let configs;
    let cancellationReason;
    let disconnectionDate;
    if(SecureEdge_COMPONENTS.SecureEdgeCloud == componentName){
        component = await activeSolution.getComponentByName(componentName);
        let conf = component.getConfigurations();
        Object.values(conf).forEach(function(confs){
            let relatedProducts = confs.getRelatedProducts();
            Object.values(relatedProducts).forEach(function(relatedProd){
                let attribs = Object.values(relatedProd.configuration.attributes);
                console.log(attribs);
                cancellationReason = attribs.filter((obj) => {
                    return obj.name === "CancellationReason";
                });
                disconnectionDate = attribs.filter((obj) => {
                    return obj.name === "DisconnectionDate";
                });
                //cancellationReason = relatedProd.configuration.attributes.cancellationreason;
                //disconnectionDate = relatedProd.configuration.attributes.disconnectiondate;

            });
        });
        if(cancellationReason == undefined || cancellationReason[0].value == '' || disconnectionDate == undefined || disconnectionDate[0].value == ''){
            return false;
        }else{
            return true;
        }
    }else{
        component = await activeSolution.getComponentByName(componentName);
        configs = component.getConfigurations();
           Object.values(configs).forEach((config) => {
            if (config.guid) {
                let attribs = Object.values(config.attributes);
                console.log(attribs);
                cancellationReason = attribs.filter((obj) => {
                    return obj.name === "CancellationReason";
                });
                disconnectionDate = attribs.filter((obj) => {
                    return obj.name === "DisconnectionDate";
                });
            }
        });
        if(cancellationReason == undefined || cancellationReason[0].value == '' || disconnectionDate == undefined || disconnectionDate[0].value == ''){
            return false;
        }else{
            return true;
        }
    }
	} catch(error){
		console.log('[SecureEdge_Utils] checkCancelAttributes() exception: ' + error);
	}
};

/**
 * Author	   : Suyash 
 * Description : Changes related to DIGI-14132/DIGI-14133
 **/
SES_Utils.performSoftDelete = async function(component,configuration){
	try{
    let irComp = await solution.getComponentByName(component.name);
    let irConfig = await irComp.getConfiguration(configuration.guid);
    let changeType;
    if (irConfig) {
        changeType = irConfig.getAttribute("ChangeType");
        if (changeType && changeType.value === 'Cancel') {
            let deletedConfiguration = irComp.softDeleteMACConfiguration(irConfig);
            console.log('deletedConfiguration', deletedConfiguration);
        }
    }
	} catch(error){
		console.log('[SecureEdge_Utils] performSoftDelete() exception: ' + error);
	}
};


