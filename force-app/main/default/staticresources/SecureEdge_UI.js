/*
 * Handles all UI-related logic
 */
console.log('[SecureEdge_UI] loaded');

const SES_UI = {};

/*********************************
 * Author	   : Sharmila Eltepu
 * Method Name : afterConfigurationAdd
 * Invoked When: after Configuration is added on SecureEdge Cloud Remote
 * Description : 1. Reads contract term value from the main component (i.e, SecureEdge)
 * Parameters  : none
 *********************************/
SES_UI.afterConfigurationAdd = async function(component, configuration) {
	 console.log("Inside afterConfigurationAdd");
	try {

		var SE_billingAcc, SE_contTerm;
		let currentSolution = await CS.SM.getActiveSolution();

		Object.values(currentSolution.schema.configurations).forEach((config) => {
			if (config.guid) {
				let attribs = Object.values(config.attributes);
				SE_billingAcc = attribs.filter((a) => {
					return a.name === "BillingAccountShadow";
				});
				SE_contTerm = attribs.filter((b) => {
					return b.name === "Contract Term";
				});
			}
		});

		var billAccVal = SE_billingAcc[0].value;
		var contTermVal = SE_contTerm[0].value;
		
		if (component.name === "SecureEdge Cloud Remote") {
			solution.updateConfigurationAttribute(configuration.guid, [{
				name: "BillingAccountLookup",
				value: billAccVal,
				displayValue: billAccVal,
				readOnly: true
			}]);
			solution.updateConfigurationAttribute(configuration.guid, [{
				name: "Contract Term",
				value: contTermVal,
				displayValue: contTermVal,
				readOnly: true
			}]);
		}
        
		//Pricing Service changes DIGI-27353
        //PRE_Logic.afterConfigurationAdd(component.name,configuration);

		return Promise.resolve(true);

	} catch (error) {
		console.log('[SecureEdge_UI] afterConfigurationAdd() exception: ' + error);
	}
};

SES_UI.afterConfigurationAddedToMacBasket = async function(componentName, guid) {
	try{
		let solution = await CS.SM.getActiveSolution();
        let component = solution.getComponentByName(componentName);
        console.log('afterConfigurationAddedToMacBasket***', componentName, guid);
        await SES_UI.MACDDisconnectionDetails();
        await SES_UI.MACDTenancyDetails();
        CommonUtills.CloneOrderEnrichment(componentName, guid); // Added By vijay DIGI-456
        return Promise.resolve(true);
	} catch(error){
		console.log('[SecureEdge_UI] afterConfigurationAddedToMacBasket() exception: ' + error);
	}
};


/*****************************************************************************************************************************
 * Author	   : lalit
 * Method Name : MACDDisconnectionDetails
 * Invoked When: When Solution is loaded
 * Description : DIGI-10035 : Make attributes read only for MAC Disconnection
 * Parameters  : 
 *******************************************************************************************************************************/
 
 SES_UI.MACDDisconnectionDetails = async function() {
	try {
    let currentSolution = await CS.SM.getActiveSolution();

    //update visibility on secureEdge
    SES_UI.UpdateSecureEdgeMACDDisConnectionDetails(currentSolution);

    //update visibility on secureEdgeRemote
    SES_UI.UpdateSecureEdgeCloudRemoteMACDDisConnectionDetails(currentSolution);

    //update visibility on secureEdgeCloud
    let secureEdgeCloudComp = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloud);
    let secureEdgeCloudRemoteComp = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote);

    if (secureEdgeCloudComp.name.includes(SecureEdge_COMPONENTS.SecureEdgeCloud)) {

        let configs = secureEdgeCloudComp.getConfigurations();
        var updateMapChild = {};
        
        Object.values(configs).forEach((config) => {

            if (config.attributes) {  
                
                if(config.attributes.changetype.value == 'New' ){

                    updateMapChild[config.guid] = [];

                    updateMapChild[config.guid].push({
                        name: "ChangeType",
                        value: "Active",
                        displayValue: "Active"
                    });

                    let keys = Object.keys(updateMapChild);
                    secureEdgeCloudComp.lock('Commercial', false);

                    for (let i = 0; i < keys.length; i++) {
                        secureEdgeCloudComp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                    }
                }
                SES_UI.updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloud, config.guid, false, true, true);

            }
                
        });       
        //update visibility on secureEdge child component
        if (Object.values(currentSolution.schema.configurations)[0].macLock === false) {
            await SES_UI.UpdateChildMACDDisconnectionDetails(configs);
        }
    }


    if (secureEdgeCloudRemoteComp.name.includes(SecureEdge_COMPONENTS.SecureEdgeCloudRemote)) {

        let configs = secureEdgeCloudRemoteComp.getConfigurations();
        var updateMapChild = {};
        
        Object.values(configs).forEach((config) => {

            if (config.attributes && config.replacedConfigId != undefined) {            
                if(config.attributes.changetype.value == 'New' ){
                    updateMapChild[config.guid] = [];

                    updateMapChild[config.guid].push({
                        name: "ChangeType",
                        value: "Active",
                        displayValue: "Active"
                    });

                    let keys = Object.keys(updateMapChild);
                    secureEdgeCloudRemoteComp.lock('Commercial', false);

                    for (let i = 0; i < keys.length; i++) {
                        secureEdgeCloudRemoteComp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
                    }
                }
                
                SES_UI.updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloudRemote, config.guid, false, true, true);

            }
                
        });       
    }
	} catch (error) {
		console.log('[SES_UI] MACDDisconnectionDetails() exception: ' + error);
	}
    return Promise.resolve(true);
};


SES_UI.MACDTenancyDetails = async function() {
            try {
			var cloudTenancyId,cloudTenancyId2;
			currentBasket = await CS.SM.getActiveBasket();
			const basketId = await CS.SM.getActiveBasketId();
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			var basket = JSON.parse(result["GetBasket"]);
            basketChangeType = basket.csordtelcoa__Change_Type__c;
            modbasketChangeType = basketChangeType;
            opptyType = basket.Opportunity_Type__c;
			});
			
            if (modbasketChangeType === 'Change Solution') {
                let inputMap = {};
                inputMap['GetTenancyDetailsforService'] = accountId;
                await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                    console.log('Tenancy ID finished with response: ', result);
                    var subs = JSON.parse(result["GetTenancyDetailsforService"]);
                    console.log('Tenancy ID: ', subs);
                    //secgu_ID = subs.sEgu_Id;
                    cloudTenancyId = subs.TenancySecId;
                    cloudTenancyId2 = subs.TenancySecIdCloud;
                });
                let currentSolution = await CS.SM.getActiveSolution();
                var TenancyId;
                let currentComponent = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol);
                if (currentSolution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
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
                    var TenancyVal2 = TenancyId[0].value;
                    if ((TenancyVal) == "" || TenancyVal == null) {
                        console.log(TenancyVal);
                        TenancyVal = cloudTenancyId;
                        TenancyVal2 = cloudTenancyId2;
                        var updateMapChild = {};
                        Object.values(configs).forEach((config) => {
                            if (config.attributes) {
                                updateMapChild[config.guid] = [];
                                updateMapChild[config.guid].push({
                                    name: "Tenancy ID",
                                    showInUi: true,
                                    readOnly: true,
                                    label: "Secure Edge Cloud Tenancy ID",
                                    value: TenancyVal2,
                                    displayValue: TenancyVal
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
            }
            let tenId;
		if (opptyType === 'MACs (Moves, Adds & Change)') {
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol);
        //let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        if (currentSolution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
            let configs = currentComponent.getConfigurations();
            Object.values(currentComponent.schema.configurations).forEach((configs) => {
                if (configs.guid) {
                    let attribs = Object.values(configs.attributes);
                    tenId = attribs.filter((c) => {
                        return c.name === "Tenancy ID";
                    });
                }

            });
        }
        console.log('tenId1 ==>' + tenId);
        let childComp = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloud);
        let configs = childComp.getConfigurations();
        var updateMapChild = {};
        Object.values(configs).forEach((config) => {
            if (config.attributes) {
                updateMapChild[config.guid] = [];
                updateMapChild[config.guid].push({
                    name: "Tenancy ID",
                    value: tenId[0].value,
                    //showInUi: true,
                    displayValue: tenId[0].displayValue
                });
            }
        });
        let keys = Object.keys(updateMapChild);
        currentComponent.lock('Commercial', false);
        for (let i = 0; i < keys.length; i++) {
            currentComponent.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
        }
        let childComp1 = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote);
        let configs1 = childComp.getConfigurations();
        var updateMapChild1 = {};
        Object.values(configs1).forEach((config1) => {
            if (config1.attributes) {
                updateMapChild1[config1.guid] = [];
                updateMapChild1[config1.guid].push({
                    name: "Tenancy ID",
                    value: tenId[0].value,
                    //showInUi: true,
                    displayValue: tenId[0].displayValue
                });
            }
        });
        let keys1 = Object.keys(updateMapChild1);
        currentComponent.lock('Commercial', false);
        for (let i = 0; i < keys1.length; i++) {
            currentComponent.updateConfigurationAttribute(keys1[i], updateMapChild1[keys1[i]], true);
        }
            }
			} catch(error) {
				console.log('[SES_UI] MACDTenancyDetails() exception: ' + error);
			}
            return Promise.resolve(true);
};


SES_UI.addDefaultSecureEdgeOETenancyConfigs = async function() { 
	try {
		if (basketStage !== 'Contract Accepted'){
			return;              
		}
  
    console.log('addDefaultOEConfigs');
                
    var oeMap = [];
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultOEConfigs ',  currentSolution.name,  SecureEdge_COMPONENTS.SecureEdgeSol);
    if (currentSolution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        let configs = currentSolution.getConfigurations();
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            Object.values(currentSolution.components).forEach((comp) => {
                Object.values(comp.schema.configurations).forEach((config) => {
                    Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                        if (oeSchema) {
                            var found = false;
                            if (config.orderEnrichmentList) {
                                var oeConfig = config.orderEnrichmentList.filter(oe => {return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId )});
                                if (oeConfig && oeConfig.length > 0)
                                    found = true;
                            }
                            if (!found) {
                                var el = {};
                                el.componentName = comp.name;
                                el.configGuid = config.guid;
                                el.oeSchema = oeSchema;
                                oeMap.push(el);
                                console.log('Adding default oe config for:',comp.name,config.name, oeSchema.name );
                            }
                        }
                    });
                });
            });
        }
    }
    if (oeMap.length> 0) {
        console.log('Adding default oe config map:',oeMap);
        for (var i=0; i< oeMap.length;i++) {
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            component.addOrderEnrichmentConfiguration( oeMap[i].configGuid , orderEnrichmentConfiguration, false);
        }
    }
    await SES_UI.initializeSecureEdgeTenancyConfigs(); 
		
	}catch(error){
		console.log('[SES_UI] addDefaultSecureEdgeOETenancyConfigs() exception: ' + error);
	}
	return Promise.resolve(true);
};

/********************************************************************************************************************************************
 * Author	   : Lalit
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
********************************************************************************************************************************************/
SES_UI.initializeSecureEdgeTenancyConfigs = async function(){
	try{
		console.log('initializeOEConfigs');
    let currentSolution = await CS.SM.getActiveSolution();
    let configurationGuid = '';
    if (currentSolution) {
        console.log('initializeVeloOEConfigs - updating');
        if (currentSolution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                for(const comp of Object.values(currentSolution.components)){
                    for(const config of Object.values(comp.schema.configurations)){
                        configurationGuid = config.guid;
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for(const oe of config.orderEnrichmentList){
                                var basketAttribute = Object.values(oe.attributes).filter(a => {
                                    return a.name.toLowerCase() === 'basketid'
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    if (!updateMap[oe.guid])
                                        updateMap[oe.guid] = [];
                                    updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                console.log('initializeOEConfigs updateMap:', updateMap);
                                for(var i=0; i< updateMap.length;i++){
                                    comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid,keys[i],updateMap[keys[i]],true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    } catch(error) {
		console.log('[SES_UI] initializeSecureEdgeTenancyConfigs() exception: ' + error);
	}
    return Promise.resolve(true);
};


/***********************************************************************************************************************************
 * Author	   : Lalit Motiray
 * Method Name : update MACDDisconnectionDetails on SecureEdge
 * Invoked When: When Solution is loaded for SecureEdge
 * Description : DIGI-10035 : Make attributes visible only for MAC Disconnection
 * Parameters  : 
 ***********************************************************************************************************************************/
SES_UI.UpdateSecureEdgeMACDDisConnectionDetails = async function(currentSolution){
    try{
	let currentSolution = await CS.SM.getActiveSolution();
    if(currentSolution){
        let secureEdgeComp = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol);
        let configs = secureEdgeComp.getConfigurations();
       
        if(Object.values(configs).length){
            //update visibility on secureEdge
            updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeSol, configs[0].guid, true, true, true);
        } 
    }
	} catch(error){
		console.log('[SES_UI] UpdateSecureEdgeMACDDisConnectionDetails() exception: ' + error);
	}
};

SES_UI.UpdateSecureEdgeCloudRemoteMACDDisConnectionDetails = async function(currentSolution){
    try{
		let currentSolution = await CS.SM.getActiveSolution();
		if(currentSolution){

        let secureEdgeComp = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote);
        let configs = secureEdgeComp.getConfigurations();
       
        // if(Object.values(configs).length){
        //     //update visibility on secureEdge
        //     updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeSol, configs[0].guid, true, true, true);
        // }
        Object.values(configs).forEach(function(config){
            if (config.replacedConfigId != undefined) {
                updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeSol, config.guid, true, true, true);
            }
        });
    }
	} catch(error){
		console.log('[SES_UI] UpdateSecureEdgeCloudRemoteMACDDisConnectionDetails() exception: ' + error);
	}

};

/***********************************************************************************************************************************
 * Author	   : Lalit Motiray
 * Invoked When: When Solution is loaded for SecureEdge
 * Description : DIGI-10035 : Make Child attributes visible only for MAC Disconnection
 * Parameters  : 
 ***********************************************************************************************************************************/
SES_UI.UpdateChildMACDDisconnectionDetails = async function(secureEdgeCloudConfigs) {
	try{
    if(secureEdgeCloudConfigs){
        Object.values(secureEdgeCloudConfigs).forEach(function(config){
            let relatedProducts = config.getRelatedProducts();
            SES_UI.updateExtenalIPChangeType(relatedProducts, 
                                      config.getAttribute('ChangeType').value == 'Active');
        });

    } 
	} catch(error){
		console.log('[SES_UI] UpdateChildMACDDisconnectionDetails() exception: ' + error);
	}	

    return Promise.resolve(true);
};


/**
 * Author	   : Lalit 
 * Description : DIGI-10035 : Dynamically show/hide the fields(attribute) on the solution 
 * 
 **/
SES_UI.updateExtenalIPChangeType = async function(externalIpProducts, disableChangetype){
    try{
	//debugger;
    
    Object.values(externalIpProducts).forEach(function(externalIpProd){

        if (externalIpProd.guid && externalIpProd.isFromMacBasket) {

            SES_UI.updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloud, externalIpProd.guid, disableChangetype, true, false);

            //if Change type is not equals to active
            if(disableChangetype){
                //DIGI-26336 bug fix for active value
                solution.updateConfigurationAttribute(externalIpProd.guid, [{                     
                    name: "ChangeType",
                    value: "Active",
                    displayValue: "Active" 
                }]);
                SES_UI.updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, externalIpProd.guid, true, true, false);
            }
        }});
	} catch(error) {
		console.log('[SES_UI] UpdateChildMACDDisconnectionDetails() exception: ' + error);
	}
};

/**
 * Author	   : Lalit 
 * Description : DIGI-10035 : Dynamically show/hide the fields(attribute) on the solution 
 * Parameters  : 1)attributeName  2)componentName  3)guid 4)isReadOnly (boolean) 
 *               5)isVisible(boolean) 6)isRequired(boolean)
 **/
SES_UI.updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired){
	try{
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
		console.log('[SES_UI] updateAttributeVisiblity() exception: ' + error);
	}
};
/***********************************
* Author	  : Vijay
* Method Name : SDWAN_handleIframeMessage
* Invoked When: order enrichment close button 
* Description : use for close order enrichment
* Parameters  : 
***********************************/
SES_UI.secureEdge_handleIframeMessage = async function(e) {
        //Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
				await pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
		            
 }; 