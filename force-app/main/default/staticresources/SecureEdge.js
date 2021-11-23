/*****************************************************************************************
 * Author	   : DPG Oxygen
 * 
 * Change Version History
 	
    Version No	Author 							Date            Change Description 

	1 			Sharmila, Lalit Motiray		 	24-Nov-20		Initial file  - DPG-2432
    2           Lalit                           24-Aug-2021     DIGI-10035                           
    3           Suyash                          24-Aug-2021     DIGI-11880  
    4           Suyash/Lalit                    22-Sep-2021     DIGI-14132/DIGI-14133        
    5           Lalit                           23-sep-2021     DIGI-26333/DIGI-26336 (bugfix)              
*****************************************************************************************/
console.log('Secure Edge Plugin loaded'); 

var SecureEdge_COMPONENTS = {
	SecureEdgeSol: 'SecureEdge',  
    SecureEdgeCloud : 'SecureEdge Cloud',
    SecureEdgeTenancy :'SecureEdge Cloud Tenancy',
    SecureEdgeCloudRemote : 'SecureEdge Cloud Remote',
    ExternalIP : 'External IP Address', // DIGI-10035
    opportunityType: 'MACs (Moves, Adds & Change)', //DIGI-10035
    relatedProduct : 'External IP Address',
    MACDSolutionNonEditableFields: ['BillingAccountLookup', 'Contract Term'], //DIGI-10035 
    MACDCancelSolutionFields: ['CancellationReason', 'DisconnectionDate'], //DIGI-10035
    SecureEdgeCloudRemoteMACDSolutionNonEditableFields : ['RemoteWorkerQuantity']
};


var executeSaveSecureEdge = false;
var saveSecureEdge = false;
var DEFAULTSOLUTIONNAME_SecureEdge = 'SecureEdge';  
var DEFAULTOFFERNAME_SecureEdge = 'SecureEdge Security'; 
var saveSecureEdgeCloud = false; 
// let modbasketChangeType;

if(!CS || !CS.SM){ 
    throw Error('Solution Console Api not loaded?');
}


if (CS.SM.registerPlugin) { 
    console.log('Secure edge Tenancy Plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () { 
        console.log('SecureEdge SolutionConsoleReady');
        await CS.SM.registerPlugin('SecureEdge Security') 
            .then(async SecureEdgePlugin => { 
                updateSecureEdgePlugin(SecureEdgePlugin); 
            }); 
    }); 
}

async function updateSecureEdgePlugin(SecureEdgePlugin){   
    
    console.log('inside hooks',SecureEdgePlugin);
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        console.log('solution==>', solution.name);
        if(solution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)){
            console.log('SecureEdge SolutionSetActive',e);
            currentBasket = await CS.SM.getActiveBasket();
            const basketId = await CS.SM.getActiveBasketId();
            let inputMap = {};
            inputMap['GetBasket'] = basketId;

            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                console.log('GetBasket finished with response: ', result);
                var basket = JSON.parse(result["GetBasket"]);
                basketChangeType = basket.csordtelcoa__Change_Type__c;
                modbasketChangeType = basketChangeType;
                basketStage= basket.csordtelcoa__Basket_Stage__c;
                opptyType = basket.Opportunity_Type__c; //DIGI-10035
                accountId = basket.csbb__Account__c;
                console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId)
                window.oeSetBasketData(solution, basketStage, accountId);
                if(accountId!=null){
                    CommonUtills.setAccountID(SecureEdge_COMPONENTS.SecureEdgeSol,accountId);
                }
            });

            addDefaultSecureEdgeOETenancyConfigs();

            await SecureEdgePlugin.MACDTenancyDetails();
            
            //DPG-5646 - Sharmila - Event to hide/remove Import button
            document.addEventListener("click", function(e) {
                e = e || window.event;
                // Import button is hidden via css : refer OEStyle.css
                Utils.updateImportConfigButtonVisibility();
            }, false);

            //DIGI-10035 related to MACD Disconnection Orders
            if (modbasketChangeType === 'Change Solution' && opptyType.toLowerCase() === (SecureEdge_COMPONENTS.opportunityType).toLowerCase() &&
                Object.values(solution.schema.configurations)[0].replacedConfigId && Object.values(solution.schema.configurations)[0].replacedConfigId !== null) {
                
                MACDDisconnectionDetails();

            }
        }
        return Promise.resolve(true); 


    });
	
    //Event to handle load of OE tabs
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        console.log('OrderEnrichmentTabLoaded==>'); 
        let solution = await CS.SM.getActiveSolution();
        if(solution.name.includes(SecureEdge_COMPONENTS.SecureEdgeSol)){
            console.log('OrderEnrichmentTabLoaded', e);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });


    /**
    * Hook executed before we save the complex product to SF. We need to resolve the promise as a
    * boolean. The save will continue only if the promise resolve with true.
    * Updated by : lalit
    * To create case for the configuration in case the business criteria w.r.t to pricing has met
    * @param {Object} complexProduct
    */
    SecureEdgePlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        let solution = result.solution ; 
        if (solution == null || solution == undefined) solution = await CS.SM.getActiveSolution();
            if(window.basketStage === "Contract Accepted" || window.basketStage === "Enriched"|| window.basketStage === "Submitted"){
                solution.lock("Commercial", false);
            } 
            updateSolutionName_SecureEdge(); 
            await Utils.updateActiveSolutionTotals();
            CommonUtills.updateBasketDetails(); 
            Utils.hideSubmitSolutionFromOverviewTab();
            if (modbasketChangeType === 'Change Solution'){
                UpdateSecureEdgeMACDDisConnectionDetails(solution);
                //added for DIGI-14132
                let secureEdgeCloudComp = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloud);
                UpdateChildMACDDisconnectionDetails(secureEdgeCloudComp.getConfigurations());
            }

           if(window.basketStage === "Contract Accepted" || window.basketStage === "Enriched"|| window.basketStage === "Submitted"){
                solution.lock("Commercial", true);
            } 
 
       }
        SecureEdgePlugin.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
            console.log("Inside beforeSave");
            let currentSolution = await CS.SM.getActiveSolution();

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

            
            
            //solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeCloudRemote).getConfiguration('3094b857-3f3a-a3ff-5400-cdb9306bc618').softDeleted

            if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
                currentSolution.lock("Commercial", false);
            }
            return Promise.resolve(true);
        }

        SecureEdgePlugin.MACDTenancyDetails = async () => {
            var cloudTenancyId;
            if (modbasketChangeType === 'Change Solution') {
                let inputMap = {};
                inputMap['GetTenancyDetailsforService'] = accountId;
                await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                    console.log('Tenancy ID finished with response: ', result);
                    var subs = JSON.parse(result["GetTenancyDetailsforService"]);
                    console.log('Tenancy ID: ', subs);
                    //secgu_ID = subs.sEgu_Id;
                    cloudTenancyId = subs.TenancySecId;
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
                    if ((TenancyVal) == "" || TenancyVal == null) {
                        console.log(TenancyVal);
                        TenancyVal = cloudTenancyId;
                        var updateMapChild = {};
                        Object.values(configs).forEach((config) => {
                            if (config.attributes) {
                                updateMapChild[config.guid] = [];
                                updateMapChild[config.guid].push({
                                    name: "Tenancy ID",
                                    showInUi: true,
                                    readOnly: true,
                                    label: "Secure Edge Cloud Tenancy ID",
                                    value: TenancyVal,
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
            return Promise.resolve(true);
        }
                
/**********************************************************************************************************************************
 * Author	   : Sharmila Eltepu
 * Method Name : afterRelatedProductAdd
 * Invoked When: after related product is added
 * Description : 1. Reads contract term value from the main component (i.e, SecureEdge)
 * Parameters  : none
 ***********************************************************************************************************************************/
        
    SecureEdgePlugin.afterRelatedProductAdd = async function(component, configuration, relatedProduct){
       
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
        console.log('Contract Term:=> ' + exContTerm);
        
        if (relatedProduct.name === "External IP Address") {

            //DIGI-10035 set chnage type default to active
            /*if(modbasketChangeType === 'Change Solution'){

                solution.updateConfigurationAttribute(relatedProduct.guid, [{                     
                    name: "ChangeType",
                    value: "Active",
                    displayValue: "Active" 
                }]);
                //update the change type attribute visibility on External IP
                updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloud, relatedProduct.guid, false, true, false);
            }*/

            solution.updateConfigurationAttribute(relatedProduct.guid, [{
                name: "Contract Term",
                value: exContTerm 
            }]);
        }
    }

    SecureEdgePlugin.beforeRelatedProductAdd = async function(component, configuration, relatedProduct){
        return Promise.resolve(true);
    }

    SecureEdgePlugin.beforeRelatedProductDelete = async function(component, configuration, relatedProduct){
        if(relatedProduct.configuration.replacedConfigId){
            CS.SM.displayMessage("Cannot delete External IP address as it is already configured", "info");
            return Promise.resolve(false);
        }
        
        return Promise.resolve(true);
    }

    
    


/*******************************************************************************************************************************************
 * Author	   : Sharmila Eltepu
 * Method Name : afterConfigurationAdd
 * Invoked When: after Configuration is added on SecureEdge Cloud Remote
 * Description : 1. Reads contract term value from the main component (i.e, SecureEdge)
 * Parameters  : none
 ********************************************************************************************************************************************/

    SecureEdgePlugin.afterConfigurationAdd = async function(component, configuration) {
        console.log("Inside afterConfigurationAdd");
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
        console.log('SE_billingAcc ==>' + SE_billingAcc);
        
        var billAccVal = SE_billingAcc[0].value;
        console.log('BillingAccountLookup:=> ' + billAccVal);
        
        var contTermVal = SE_contTerm[0].value;
        console.log('Contract Term:=> ' + contTermVal);  
        
        if(component.name === "SecureEdge Cloud Remote"){

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

        return Promise.resolve(true);
    }  
    
    		

    
    /**
    * Hook executed after the Order Enrichment configuration is added via the UI add configuration button
    * @param {string} component - Component object where the configuration resides
    * @param {Object} configuration - Main configuration object for which OE configuration is  created
    * @param {Object} orderEnrichmentConfiguration - Order Enrichment Configuration which is inserted
    */
    SecureEdgePlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) { 
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
    SecureEdgePlugin.afterOrderEnrichmentConfigurationDelete = async function (component, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

/*******************************************************************************************************************************************
 * Author	   : Sharmila Eltepu
 * Method Name : afterAttributeUpdated
 * Invoked When: after attribute is updated on SecureEdge Cloud and SecureEdge Cloud Remote
 * Description : When the Quantity value is updated on an Attribute, the monthly charge value should be calculated and populate on UI
 * Parameters  : none
 ********************************************************************************************************************************************/
   
       SecureEdgePlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap){
                            
            if(attribute.name === "RemoteWorkerQuantity"){
                let recCharge = configuration.getAttribute('add-on recurring charge').value; // Assumes that the commercial product lookup is named "CommercialProduct"
                console.log('recCharge ===>' + recCharge);
                
                var regExp = /^\d+\.\d{0,10}$/;
                if(attribute.value <= 0 || attribute.value > 500 || regExp.test(attribute.value)){
            		CS.SM.displayMessage("Please enter Remote Worker Quantity between 1 - 500", "error");
				 return Promise.resolve(false);
            	}
                else {
            	let remoteQuantity = attribute.value * recCharge;
            	console.log('remoteQuantity =>' + remoteQuantity);
            	solution.updateConfigurationAttribute(configuration.guid, [{
					name: "AddOnRemoteWorkerMonthlyCharge",
					value: remoteQuantity
				}]);
        		} 
            }
			
			if (attribute.name === "ExternalIPAddressQuantity") {
                
                let recChargeExt = configuration.getAttribute('add-on recurring charge').value; // Assumes that the commercial product lookup is named "CommercialProduct"
                console.log('recChargeExt ===>' + recChargeExt);
                
				let extQuantity = attribute.value * recChargeExt;
				console.log('extQuantity =>' + extQuantity);
				solution.updateConfigurationAttribute(configuration.guid, [{
					name: "Add-OnExternalIPAddressesMonthlyCharge",
					value: extQuantity
				}]);
			}
			
            if (component.name === 'Customer requested Dates') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
            }  
            if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
                window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
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
                        updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, false, false);
                    }else{
                        updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    }

                    updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    //update child change type as active
                    updateExtenalIPChangeType(configuration.getRelatedProducts(), false);
                    
                }else{
                    var updateMap = {};
                    updateMap[configuration.guid] = [];
                        updateMap[configuration.guid].push({
                            name: 'RemoveAdd-OnBandwidth',
                            value: false,
                    });

                    await component.updateConfigurationAttribute(configuration.guid,updateMap[configuration.guid],true);
                    updateAttributeVisiblity(['RemoveAdd-OnBandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, false, false);
                    updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, true, true, false);
                    
                    //update child change type as active
                    updateExtenalIPChangeType( configuration.getRelatedProducts(), true);
                   
                }
            }

            //DIGI-10035 update attribute visibility on External IP and show/hide Cancellation fields
            if(attribute.name === "ChangeType" && configuration.configurationName.includes(SecureEdge_COMPONENTS.ExternalIP)){

                //DIGI-26333
                if(["Cancel", "Active"].includes(attribute.value)){
                    updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, 
                                             configuration.guid, true, true, false);
                }else{
                    updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, 
                    configuration.guid, false, true, true);
                }
            
                if(attribute.value == "Cancel"){
                    //Changes related to DIGI-14132/DIGI-14133 start
                    if(await checkCancelAttributes(component.name,configuration)){
                        await performSoftDelete(component,configuration);
                    }
                    //Changes related to DIGI-14132/DIGI-14133 end
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloud, 
                                             configuration.guid, false, true, true);
                }else{
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloud, 
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
                    updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, true, true, false);
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

                    updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                    updateAttributeVisiblity(['Add-On Bandwidth'], SecureEdge_COMPONENTS.SecureEdgeCloud, configuration.guid, false, true, false);
                }
            }

            if(attribute.name === "ChangeType" && configuration.configurationName === SecureEdge_COMPONENTS.SecureEdgeCloudRemote){
                if(attribute.value == "Modify"){
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, false, true, false);
                }else{
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.SecureEdgeCloudRemoteMACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, configuration.guid, true, true, false);
                }

                if(attribute.value == "Cancel"){
                    //Changes related to DIGI-14132/DIGI-14133 start
                    if(await checkCancelAttributes(component.name,configuration)){
                        await performSoftDelete(component,configuration);
                    }
                    //Changes related to DIGI-14132/DIGI-14133 end
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, 
                                             configuration.guid, false, true, true);
                }else{
                    updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDCancelSolutionFields, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, 
                                             configuration.guid, false, false, false);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, "CancellationReason", true);
                    Utils.emptyValueOfAttribute(configuration.guid, SecureEdge_COMPONENTS.SecureEdgeCloudRemote, "DisconnectionDate", true);
                }
            }
            //Changes related to DIGI-14132/DIGI-14133 start
            if(SecureEdge_COMPONENTS.MACDCancelSolutionFields.includes(attribute.name)){
                if(await checkCancelAttributes(component.name,configuration)){
                    await performSoftDelete(component,configuration);
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


            return Promise.resolve(true);
        }
                
       //Update for changing basket stage to Draft
       SecureEdgePlugin.afterSolutionDelete = function (solution) {
       		CommonUtills.updateBasketStageToDraft();
       		return Promise.resolve(true);
       }

    //DIGI-10035 related to MACD Disconnection
    SecureEdgePlugin.afterConfigurationAddedToMacBasket = async function (componentName, guid) {
        let solution = await CS.SM.getActiveSolution();
        let component = solution.getComponentByName(componentName);
        console.log('afterConfigurationAddedToMacBasket***', componentName, guid);
        MACDDisconnectionDetails();
        SecureEdgePlugin.MACDTenancyDetails();
        return Promise.resolve(true);
    }
}
                
/*******************************************************************************************************************************************
 * Author	   : Lalit Motiray
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each component config if there is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
async function addDefaultSecureEdgeOETenancyConfigs(){
	
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
    await initializeSecureEdgeTenancyConfigs(); 
    return Promise.resolve(true);
}
   
/********************************************************************************************************************************************
 * Author	   : Lalit
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
********************************************************************************************************************************************/
async function initializeSecureEdgeTenancyConfigs(){
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
    
    return Promise.resolve(true);
}

/*****************************************************************************************************************************
 * Author	   : lalit
 * Method Name : MACDDisconnectionDetails
 * Invoked When: When Solution is loaded
 * Description : DIGI-10035 : Make attributes read only for MAC Disconnection
 * Parameters  : 
 *******************************************************************************************************************************/
async function MACDDisconnectionDetails(){

    let currentSolution = await CS.SM.getActiveSolution();

    //update visibility on secureEdge
    UpdateSecureEdgeMACDDisConnectionDetails(currentSolution);

    //update visibility on secureEdgeRemote
    UpdateSecureEdgeCloudRemoteMACDDisConnectionDetails(currentSolution);

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
                updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloud, config.guid, false, true, true);

            }
                
        });       
        //update visibility on secureEdge child component
        if (Object.values(currentSolution.schema.configurations)[0].macLock === false) {
            UpdateChildMACDDisconnectionDetails(configs);
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
                
                updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloudRemote, config.guid, false, true, true);

            }
                
        });       
    }

    return Promise.resolve(true);
}

/***********************************************************************************************************************************
 * Author	   : Lalit Motiray
 * Method Name : update MACDDisconnectionDetails on SecureEdge
 * Invoked When: When Solution is loaded for SecureEdge
 * Description : DIGI-10035 : Make attributes visible only for MAC Disconnection
 * Parameters  : 
 ***********************************************************************************************************************************/
async function UpdateSecureEdgeMACDDisConnectionDetails(currentSolution){
    
    if(currentSolution){

        let secureEdgeComp = currentSolution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol);
        let configs = secureEdgeComp.getConfigurations();
       
        if(Object.values(configs).length){
            //update visibility on secureEdge
            updateAttributeVisiblity(SecureEdge_COMPONENTS.MACDSolutionNonEditableFields, SecureEdge_COMPONENTS.SecureEdgeSol, configs[0].guid, true, true, true);
        }
        
    }

}

async function UpdateSecureEdgeCloudRemoteMACDDisConnectionDetails(currentSolution){
    
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

}

/***********************************************************************************************************************************
 * Author	   : Lalit Motiray
 * Invoked When: When Solution is loaded for SecureEdge
 * Description : DIGI-10035 : Make Child attributes visible only for MAC Disconnection
 * Parameters  : 
 ***********************************************************************************************************************************/
async function UpdateChildMACDDisconnectionDetails (secureEdgeCloudConfigs) {

    if(secureEdgeCloudConfigs){
        Object.values(secureEdgeCloudConfigs).forEach(function(config){
            let relatedProducts = config.getRelatedProducts();
            updateExtenalIPChangeType(relatedProducts, 
                                      config.getAttribute('ChangeType').value == 'Active');
        });

    }  

    return Promise.resolve(true);
}

/**
 * Author	   : Lalit 
 * Description : DIGI-10035 : Dynamically show/hide the fields(attribute) on the solution 
 * 
 **/
async function updateExtenalIPChangeType(externalIpProducts, disableChangetype){
    debugger;
    
    Object.values(externalIpProducts).forEach(function(externalIpProd){

        if (externalIpProd.guid) {

            updateAttributeVisiblity(['ChangeType'], SecureEdge_COMPONENTS.SecureEdgeCloud, externalIpProd.guid, disableChangetype, true, false);

            //if Change type is not equals to active
            if(disableChangetype){
                //DIGI-26336 bug fix for active value
                solution.updateConfigurationAttribute(externalIpProd.guid, [{                     
                    name: "ChangeType",
                    value: "Active",
                    displayValue: "Active" 
                }]);
                updateAttributeVisiblity(['ExternalIPAddressQuantity'], SecureEdge_COMPONENTS.SecureEdgeCloud, externalIpProd.guid, true, true, false);
            }
        }
    });
}

/**
 * Author	   : Lalit 
 * Description : DIGI-10035 : Dynamically show/hide the fields(attribute) on the solution 
 * Parameters  : 1)attributeName  2)componentName  3)guid 4)isReadOnly (boolean) 
 *               5)isVisible(boolean) 6)isRequired(boolean)
 **/
async function updateAttributeVisiblity (attributeName, componentName, guid, isReadOnly, isVisible, isRequired){

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

/**
 * Author	   : Suyash 
 * Description : Changes related to DIGI-14132/DIGI-14133
 **/
 async function checkCancelAttributes (componentName, configuration){
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
};

/**
 * Author	   : Suyash 
 * Description : Changes related to DIGI-14132/DIGI-14133
 **/
 async function performSoftDelete (component,configuration){

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
};



/* 	 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_SecureEdge() {
	var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
    attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,SecureEdge_COMPONENTS.SecureEdgeSol);
    let solution = await CS.SM.getActiveSolution();
    let component = solution.getComponentByName(SecureEdge_COMPONENTS.SecureEdgeSol)
    let guid ;
	console.log('attrValuesMap...'+attrValuesMap);
	if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_SecureEdge){
		let updateConfigMap = {};
        guid = attrValuesMap['GUID'];
        updateConfigMap[guid] = [];
        updateConfigMap[guid].push({
            name: 'Solution Name',
            value: DEFAULTSOLUTIONNAME_SecureEdge,
			displayValue: DEFAULTSOLUTIONNAME_SecureEdge
        });
        if(updateConfigMap){	
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
				keys = Object.keys(updateConfigMap);
				for (let i = 0; i < keys.length; i++) {
                    //await solution.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    component.lock('Commercial',false);
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
			}
		}
    }
    return Promise.resolve(true);		
}
                