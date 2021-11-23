/*===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.        Aditya/Shubhi	    22-Feb-2021		Edge-152456/EDGE-152457(new)
2.        shubhi V	    12/03/2021		EDGE-204313 chown ux incoming bakset
3.        Shubhi V		22/03/2021		EDGE-210354
4.		  Riya Sunny	2/11/2021		R34Upgrade
===============================================================================================================================*/
console.log('Load InflightBasketUtils');

let parentBillingAccount='';
let parentBillingAccountATT;
let isbillingAccountUpdateRequired=false;
var COMPONENT_NAMES = {
    ParentOEList: ['Not Before CRD', 'Preferred CRD','SiteDeliveryAddress','SiteDeliveryContact','INTROAM'],
	ChildOEList: ['Data Barring','Call Restriction','Message Restriction','MMS Eligibility']
}
var updateallowedAttList=[];

var CHOWNUtils = {
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-152457		
	 * Method Name : handleUpdateBillingAccount(solutionName,componentName, attributeName)
	 * Invoked When: On solution load
	***********************************************************************************************/
	getParentBillingAccount : async function(solutionName){
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(solutionName)) {
			let solutionConfigs = solution.getConfigurations();
			if (solutionConfigs) {
				Object.values(solutionConfigs).forEach((solConfig) => {
					parentBillingAccountATT=solConfig.getAttribute('BillingAccountLookup');
					parentBillingAccount = parentBillingAccountATT.value; //EDGE-210354
				});
			}
	    }
    },
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-152457		
	 * Method Name : handleUpdateBillingAccount(solutionName,componentName, attributeName)
	 * Invoked When: On solution load
	***********************************************************************************************/
	billingAccountUpdateRequired : async function(solutionName,componentName){
		//let isbillingAccountUpdateRequired=false;
		await CHOWNUtils.getParentBillingAccount(solutionName);
		if(parentBillingAccount){
			let solution = await CS.SM.getActiveSolution();
			let comp=await solution.getComponentByName(componentName);
			let configs =await comp.getConfigurations();
			let updateMap={};
			if(configs){
				for(var config of Object.values(configs)){
					if(!config.disabled){
						var processBillAccForceUpdate=CommonUtills.getAttribute(config,'processBillAccForceUpdate');
						if(processBillAccForceUpdate && (processBillAccForceUpdate.value===true || processBillAccForceUpdate.value==='true')){
							isbillingAccountUpdateRequired=true;
						}
					}
				}
			}
		}
		return isbillingAccountUpdateRequired;
    },
    /***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-152457		
	 * Method Name : handleUpdateBillingAccount(solutionName,componentName, attributeName)
	 * Invoked When: On solution load
	 ***********************************************************************************************/
    handleUpdateBillingAccount : async function(solutionName,componentName, attributeName){
		//await CHOWNUtils.getParentBillingAccount(solutionName,attributeName);
		if(parentBillingAccount && isbillingAccountUpdateRequired){
			let solutionAM = await CS.SM.getActiveSolution();
			let comp=await solutionAM.getComponentByName(componentName);
			let configs =await comp.getConfigurations();
			let updateMap={};
			if(configs){
				for(var config of Object.values(configs)){
					if(!config.disabled){
						
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name:  		attributeName,
							value: 		parentBillingAccount,
							displayValue:parentBillingAccountATT.displayValue
						});
						updateMap[config.guid].push({
							name:  'processBillAccForceUpdate',
							value: false
						});
					}
				}
				
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		return Promise.resolve(true);
	},
	//
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-204313		
	 * Method Name : handleUpdateAttributesOnLoad(solutionName,componentName, attributeName)
	 * Invoked When: On solution load
	 ***********************************************************************************************/
    handleUpdateAttributesOnLoad : async function(solutionName,componentName){
			let solutionAM = await CS.SM.getActiveSolution();
			let comp=await solutionAM.getComponentByName(componentName);
			let configs =await comp.getConfigurations();
			let updateMap={};
			if(configs){
				for(var config of Object.values(configs)){
					if(config.guid && !config.disabled){
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name:  'isPortOutReversal',
							value: false,
							readOnly: true
						});
						updateMap[config.guid].push({
							name:  'SubScenario',
							value: ''
						});
						var changeTypeval=config.getAttribute('ChangeType').value;
						updateMap[config.guid].push({
							name:  'ChangeType',
							showInUi: true,
							readOnly: true,
							options: [CommonUtills.createOptionItem(changeTypeval)] //R34UPGRADE
						});	
					}
					
				}
				
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		return Promise.resolve(true);
	},
	//

     /////////////////////////////////////////////////////////
	/************************************************************************************
	 * Author	  : Aditya Pareek
	 * Method Name : EmptyOEAttLst - To Empty Product Attributes on OE
	 * Invoked When: related product is added
	 * Parameters  : solutionname, componentName, relatedCompName, attrList
	 ***********************************************************************************/
	EmptyOEAttLst: async function (solutionname, componentName,relatedCompName, attrList, relattlist) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(solutionname)) {
			let comp = solution.getComponentByName(componentName);
            if(solution.components && Object.values(solution.components).length > 0){
                Object.values(solution.components).forEach((comp) => {
                    if(comp.name == componentName){
                            let configs = comp.getConfigurations();
                            Object.values(configs).forEach((config) => {
                                if (config.guid && !config.disabled) {
                                                    CHOWNUtils.emptyValueOfAttribute(config.guid, componentName, attrList,true);
                                                    if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                                                        Object.values(config.relatedProductList).forEach((relatedConfig) => {
                                                            if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid) {
                                                                CHOWNUtils.emptyValueOfAttribute(relatedConfig.configuration.guid, componentName, relattlist,true);
                                                   // }
                                                 }
                                            });
                                    }
                                    
                                }
                            });
                        
                    }

                });
            }
			
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
	 * Author	  : Aditya Pareek
	 * Method Name : EmptyAttributeLstOE
	 * Invoked When: multiple occurrences
	 * Parameters  : guid, componentName, attributeList
	 ***********************************************************************************/
	emptyValueOfAttribute: async function (guid, componentName, attributeList, skipHooks) {
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentName);
		let updateAttEmptyMap = {};
		if (guid != null && attributeList) {
			updateAttEmptyMap[guid]=[];
			for (var attributeName of attributeList) {
				updateAttEmptyMap[guid].push({
					name:  attributeName,
					value: ''
				});
			}
			if (component && updateAttEmptyMap && updateAttEmptyMap[guid]) {
				await component.updateConfigurationAttribute(guid, updateAttEmptyMap[guid], skipHooks);
			}
		}
		return Promise.resolve(true);
	},
    
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-152457		
	 * Method Name : isOperationAllowedInCHOWN(compName,configuration,hook,message)
	 * Invoked When: On all hooks
	 ***********************************************************************************************/
	isOperationAllowedInCHOWN: async function (compName,configuration,hook,message) {
        let operationAllowed=true;		 
		if(message==''){
			if(window.basketType==='Incoming'){
				message='Plan / Add-on modifications are not allowed and should be performed through subsequent MACD Order'
			}else if(window.basketType==='Outcoming'){
				message='CHOWN transaction does not allow this operation in outgoing customer account'
			}
		}
		switch (hook) {
			case 'beforeConfigurationAdd':
				operationAllowed=false;
				break;
			case 'beforeRelatedProductAdd':
				operationAllowed=false;
				break;
			case 'beforeConfigurationClone':
				operationAllowed=false;
				break;
			case 'beforeRelatedProductDelete':
				operationAllowed=false;
					break;
			case 'beforeConfigurationDelete':
				operationAllowed=false;
				break;
		}
		if(!operationAllowed)
			CS.SM.displayMessage(message, 'error');
		
		return operationAllowed;
    },
	
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-170016	
	 * Method Name : handleReloadVisibilityinInflight()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleVisibilityinCHOWN: async function () {
		let product = await CS.SM.getActiveSolution();
		let components = await product.getComponents();
        components=components.components;
        var updateConfigMap = {};
        var componentMapNextGen = new Map();
        var componentMapattrNextGen = {};
		if (components) {
			for(var comp of Object.values(components)){
                componentMapNextGen = new Map();
				let configs = await comp.getConfigurations();
				if (configs) {
					for (var config of Object.values(configs)) {
						if(config.guid && !config.disabled){
                            componentMapattrNextGen = {};
							var attributes=await config.getAttributes();
							for (var attribute of Object.values(attributes)) {
									if(!updateallowedAttList.includes(attribute.name) && !attribute.readOnly && attribute.showInUi){
									componentMapattrNextGen[attribute.name] = [];
									componentMapattrNextGen[attribute.name].push({
										IsreadOnly: true,
										isVisible: attribute.showInUi,
										isRequired: false
									});
								}
								componentMapNextGen.set(config.guid, componentMapattrNextGen);
								//CommonUtills.attrVisiblityControl(comp.name, componentMapNextGen);
							}
							if (config.relatedProductList.length >= 0) {
								for (var ReletedConfig of Object.values(config.relatedProductList)) {
									if (ReletedConfig.guid) {
                                        componentMapattrNextGen = {};
										var attributes=await ReletedConfig.configuration.getAttributes();
							            for (var attribute of Object.values(attributes)) {
										    if(!attribute.readOnly && attribute.showInUi){
												componentMapattrNextGen[attribute.name] = [];
												componentMapattrNextGen[attribute.name].push({
												IsreadOnly: true,
												isVisible: attribute.showInUi,
												isRequired: false
												});
                                            }
										    componentMapNextGen.set(ReletedConfig.guid, componentMapattrNextGen);
									    }
								    }
							    }
							
						    }
						}
					}
					console.log('componentMapNextGen.....'+ componentMapNextGen);
					if(componentMapNextGen)
						CommonUtills.attrVisiblityControl(comp.name, componentMapNextGen,product);
				}
			}
		}
		return Promise.resolve(true);
	}
	
}