/******************************************************************************************
Sr.No.		Author 			    Date			Sprint   		Story Number	Description
1			shubhi			     7/01/2021		21.01   		EDGE-170016		Inflight journey
2			Radhika				25/02/2021		21.03			EDGE-199772		Soft Delete - Remediation 
3 	jamil 	02/11/2021 		R34Upgrade 
*******************/
console.log('Load InflightBasketUtils');
//Added by Radhika for EDGE-195101 for Accessory
var commercialChangesAllowedComponents=['Device','Accessory'];
var updateallowedAttList=['ChangeType'];

var InflightBasketUtils = {
    
    //change type based on amend/cancel allowed
    handleAddToInflight : async function(componentName, configuration){
    	let solutionAM = await CS.SM.getActiveSolution();
    	let comp=await solutionAM.getComponentByName(componentName);
		let config=await comp.getConfiguration(configuration);
    	let amendallowed=await config.getAttribute('InfAmndStatus');
		let cancelallowed=await config.getAttribute('InfCanStatus');
		let remrequired = await config.getAttribute('InfRmdStatus');
		let changeType=await config.getAttribute('ChangeType');
    	let options=[]
		let updateMap={};
		let changeTypeval='';
		if(window.basketType !== 'Remediate'){
			if(amendallowed && amendallowed.value && amendallowed.value!==''){
				options.push(CommonUtills.createOptionItem("Inflight Amend"));//R34 Upgrade
				changeTypeval=amendallowed.value;
			}
			if(cancelallowed && cancelallowed.value && cancelallowed.value!=='' &&  window.amendType !== 'Non-Commercial' && commercialChangesAllowedComponents.includes(componentName)){
				options.push(CommonUtills.createOptionItem("Inflight Cancel")); //R34 Upgrade
			}
			updateMap[configuration]=[];
			updateMap[configuration].push({
				name: 'ChangeType',
				value: 'Inflight Amend',
				displayValue: 'Inflight Amend',
				showInUi: true,
				readOnly: false,
				options: options
			});
		//EDGE-199772 --- START ----- 	
		}else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value && amendallowed.value==='Amend Rejected' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Inflight Cancel'){
			updateMap[configuration]=[];
			options.push(CommonUtills.createOptionItem("Rollback Cancel"));//R34 Upgrade
		    updateMap[configuration].push({
				name: 'ChangeType',
				value: 'Inflight Cancel',
				displayValue: 'Inflight Cancel',
				showInUi: true,
				readOnly: false,
				options: options
			});
		}
		else if ( window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Rejected'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Inflight Amend'){
			options.push(CommonUtills.createOptionItem("Rollback Amend"));//R34 Upgrade
			updateMap[configuration]=[];
		    updateMap[configuration].push({
				name: 'ChangeType',
				value: 'Inflight Amend',
				displayValue: 'Inflight Amend',
				showInUi: true,
				readOnly: false,
				options: options
			});
		}
		else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Inflight Cancel'){
			updateMap[configuration]=[];
		    updateMap[configuration].push({
				name: 'ChangeType',
				value: 'Inflight Cancel',
				displayValue: 'Inflight Cancel',
				showInUi: true,
				readOnly: false,
				options: [CommonUtills.createOptionItem("Inflight Cancel"),CommonUtills.createOptionItem("Rollback Cancel")]// R34 Upgrade
			});
			updateMap[configuration].push({
			name: 'SoftDelete',
			value: false
		});	
		}
		else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Inflight Amend'){
			updateMap[configuration]=[];
		    updateMap[configuration].push({
			name: 'ChangeType',
			value: 'Inflight Amend',
			displayValue: 'Inflight Amend',
			showInUi: true,
			readOnly: false,
			options: [CommonUtills.createOptionItem("Inflight Amend"),CommonUtills.createOptionItem("Rollback Amend")] // R34 Upgrade
		});
		
		}
		else if (window.basketType === 'Remediate' &&  amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'New'){
			updateMap[configuration]=[];
		    updateMap[configuration].push({
				name: 'ChangeType',
				value: 'New',
				displayValue: 'New',
				showInUi: true,
				readOnly: false,
				options: [CommonUtills.createOptionItem("New"),CommonUtills.createOptionItem("Rollback New")]// r34 upgrade
			});
			/*updateMap[configuration].push({
			name: 'SoftDelete',
			value: true
			});	*/
		}
		//EDGE-199772 --- END ----- 		
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
		}
		return Promise.resolve(true);
	},
	
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-170016	
	 * Method Name : handleReloadinInflight()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadinInflight: async function (compName,replaceconfigAtt) {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(compName);
		var updateMap = {};
		if (comp){
			let configs = comp.getConfigurations();
			if (configs) {
				for (var config of Object.values(configs)) {
					if(config && config.replacedConfigId  && !config.disabled){
						let amendallowed=await config.getAttribute('InfAmndStatus');
						let cancelallowed=await config.getAttribute('InfCanStatus');
						let remrequired = await config.getAttribute('InfRmdStatus');
						let changeType=await config.getAttribute('ChangeType');
						let changeTypeval='';
						let options=[]
						//let updateMap={};
						if(window.basketType !== 'Remediate'){
						if(amendallowed && amendallowed.value && amendallowed.value!==''){
							options.push(CommonUtills.createOptionItem("Inflight Amend"));
						}
						if(cancelallowed && cancelallowed.value && cancelallowed.value!=='' &&  window.amendType !== 'Non-Commercial' && commercialChangesAllowedComponents.includes(compName)){
							options.push(CommonUtills.createOptionItem("Inflight Cancel"));
						}
						if(changeType && changeType.value && (changeType.value==='Inflight Amend' || changeType.value==='Inflight Cancel')){
							changeTypeval=changeType.value;
						}else{
							changeTypeval='Inflight Amend';
						}
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: changeTypeval,
							displayValue: changeTypeval,
							showInUi: true,
							readOnly: false,
							options: options
						});
					}
					else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value && amendallowed.value==='Amend Rejected' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Rollback Cancel'){
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: 'Rollback Cancel',
							displayValue: 'Rollback Cancel',
							showInUi: true,
							readOnly: false,
							options: [CommonUtills.createOptionItem("Rollback Cancel")]// r34 upgrade
						});
					}
					else if ( window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Rejected'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Rollback Amend'){
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: 'Rollback Amend',
							displayValue: 'Rollback Amend',
							showInUi: true,
							readOnly: false,
							options: [CommonUtills.createOptionItem("Rollback Amend")]// r34 upgrade
						});
					}
					else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && (changeType.value === 'Inflight Cancel'|| changeType.value === 'Rollback Cancel')){
						changeTypeval=changeType.value;
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: changeTypeval,
							displayValue: changeTypeval,
							showInUi: true,
							readOnly: false,
							options: [CommonUtills.createOptionItem("Inflight Cancel"),CommonUtills.createOptionItem("Rollback Cancel")]// r34 upgrade
						});
						updateMap[config.guid].push({
						name: 'SoftDelete',
						value: false
					});	
					}
					else if (window.basketType === 'Remediate' && amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed'&& remrequired && remrequired.value && remrequired.value==='Remediation Required' && (changeType.value === 'Inflight Amend' || changeType.value === 'Rollback Amend')){
						changeTypeval=changeType.value;
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
						name: 'ChangeType',
						value: changeTypeval,
						displayValue: changeTypeval,
						showInUi: true,
						readOnly: false,
						options: [CommonUtills.createOptionItem("Inflight Amend"),CommonUtills.createOptionItem("Rollback Amend")]// r34 upgrade
					});
					
					}
					else if (window.basketType === 'Remediate' &&  amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'New'){
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: 'New',
							displayValue: 'New',
							showInUi: true,
							readOnly: false,
							options: [CommonUtills.createOptionItem("New"),CommonUtills.createOptionItem("Rollback New")]// r34 upgrade
						});
					}
					else if (window.basketType === 'Remediate' &&  amendallowed && amendallowed.value &&  amendallowed.value==='Amend Allowed' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && changeType.value === 'Rollback New'){
						updateMap[config.guid]=[];
						updateMap[config.guid].push({
							name: 'ChangeType',
							value: 'Rollback New',
							displayValue: 'Rollback New',
							showInUi: true,
							readOnly: true,
							options: [CommonUtills.createOptionItem("New"),CommonUtills.createOptionItem("Rollback New")]// r34 upgrade
						});
					}
						updateMap[config.guid].push({
						name: replaceconfigAtt,
						value: config.replacedConfigId
					});
					}
				}
				var complock = comp.commercialLock; 
				if (complock) comp.lock("Commercial", false);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
				if (complock) comp.lock("Commercial", true);
			}
		}
		return Promise.resolve(true);
    },
    /***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-170016	
	 * Method Name : handleReloadVisibilityinInflight()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadVisibilityinInflight: async function () {
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
						if(config.guid && config.replacedConfigId  && !config.disabled){
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
							if (Object.values(config.relatedProductList).length > 0 ) {
								for (var ReletedConfig of Object.values(config.relatedProductList)) {
									if (ReletedConfig.guid) {
                                        componentMapattrNextGen = {};
										var attributes=await ReletedConfig.configuration.getAttributes();
							            for (var attribute of Object.values(attributes)) {
										    if(!attribute.readOnly && attribute.showInUi){
												if(attribute.name==='ChangeType'){
													componentMapattrNextGen[attribute.name] = [];
										    		componentMapattrNextGen[attribute.name].push({
											   	 	IsreadOnly: true,
											    	isVisible: false,
											    	isRequired: false
													});
												}else{
                                                	componentMapattrNextGen[attribute.name] = [];
										    		componentMapattrNextGen[attribute.name].push({
											   	 	IsreadOnly: true,
											    	isVisible: attribute.showInUi,
											    	isRequired: false
													});
												}
                                            }
										    componentMapNextGen.set(ReletedConfig.guid, componentMapattrNextGen);
                                            //CommonUtills.attrVisiblityControl(comp.name, componentMapNextGen);
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
	},
	
	
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-170016	
	 * Method Name : displayErrormesage()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	 isOperationAllowedInInflightBasket: async function (compName,configuration,hook,message) {
		let operationAllowed=true;		 
		if(window.basketRecordType==='Inflight Change'){ 
			switch (hook) {
				case 'beforeConfigurationAdd':
					if(commercialChangesAllowedComponents.includes(compName)){
						if(window.amendType === 'Non-Commercial'){
							operationAllowed=false;
							break;
						}
							
					}else{
						operationAllowed=false;
						break;
					}
					break;
				case 'beforeRelatedProductAdd':
					if(commercialChangesAllowedComponents.includes(compName)){
						if(window.amendType === 'Non-Commercial' && configuration.replacedConfigId){
							operationAllowed=false;
							break;
						}
					}else{
						operationAllowed=false;
						break;
					}
					break;	
				case 'beforeConfigurationClone':
					if(configuration.replacedConfigId){
						operationAllowed=false;
					}
					break;
					
				case 'beforeRelatedProductDelete':
					if(configuration.replacedConfigId){
						operationAllowed=false;
					}
					break;
				case 'beforeConfigurationDelete':
					if(configuration.replacedConfigId){
						operationAllowed=false;
					}
					break;
			}
		}
		if(!operationAllowed)
			CS.SM.displayMessage(message, 'error');
		
		return operationAllowed;
	 },
         
    //replaceconfigid populated
    updateReplaceConfigAtt : async function(componentName, guid,replaceconfigAtt){
    	let solutionAM = await CS.SM.getActiveSolution();
    	let comp=await solutionAM.getComponentByName(componentName);
		let config=await comp.getConfiguration(guid);
		let updateMap={};
		updateMap[guid]=[];
		updateMap[guid].push({
			name: replaceconfigAtt,
			value: config.replacedConfigId
		});
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Aditya Pareek
	 * Method Name : populateNullValuesInflight
	 * Invoked When: On Cloning of Solution
	 * Description : Sets Redemption Values to Null
	 * Parameters  : configuration guid or left empty if doing for all configs
	 * Updated:    : Updated by Aditya for Edge-191075(Value and Display Value)
	 **************************************************************************************/
	populateNullValuesInflight: async function (componentName, configurations) {
		let updateConfigMap = {};
		//for (let configuration of configurations) {
			let mobSubsConfigGUID = "";
			mobSubsConfigGUID = configurations;
			if (mobSubsConfigGUID !== "") {
				updateConfigMap[mobSubsConfigGUID] = [
					{
						name: "InfCanStatus",
						value: '',
						displayValue: ''
					},
					{
						name: "InfAmndStatus",
						value: '',
						displayValue: ''
					}
				];
				let product = await CS.SM.getActiveSolution();
				let component = await product.getComponentByName(componentName);
				let keys = Object.keys(updateConfigMap);
				let complock = component.commercialLock; 
				if (complock) component.lock("Commercial", false);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
				if (complock) component.lock("Commercial", true);
			}
			return Promise.resolve(true);
		//}
	},
	/**************************************************************************************
	 * Author	   : Aditya Pareek
	 * Method Name : validateRemediationBeforeSave
	 * Invoked When: Before Save
	 * Description : Validation on Remediation BAsket for Edge 197580
	 **************************************************************************************/
	validateRemediationBeforeSave: async function (){
	let solutionAM = await CS.SM.getActiveSolution();
	let IsError = false;
	if(solutionAM.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
	let solConfigs = solutionAM.getConfigurations();
	for(var solConfig of Object.values(solConfigs)){
		if(solConfig.guid){
			if(solutionAM.components && Object.values(solutionAM.components).length > 0){
				Object.values(solutionAM.components).forEach((comp) => {
					if(comp.name != NEXTGENMOB_COMPONENT_NAMES.transitionDevice && IsError!= true){
						let configs = comp.getConfigurations();
						if(configs){
							Object.values(configs).forEach((config) => {
								if (config.guid && IsError!= true){
									amendallowed=  config.getAttribute('InfAmndStatus');
									remrequired =  config.getAttribute('InfRmdStatus');
									changeType =  config.getAttribute('ChangeType');

									if (amendallowed && amendallowed.value && amendallowed.value==='Amend Rejected' && remrequired && remrequired.value && remrequired.value==='Remediation Required' && (changeType.value === 'Inflight Cancel' || changeType.value === 'Inflight Amend')){
										//CS.SM.displayMessage('Please select Rollback Cancel in place of '+changeType.value+'.', 'error');
										IsError =true;
										
									}
								}
							});
						}
					}
				});
			}
		}
	}						
}
return IsError;
}
}
