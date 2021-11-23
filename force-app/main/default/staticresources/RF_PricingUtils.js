/******************************************************************************************
Version No	Author 			                Date					Edge
1 			Shubhi 							9-Jan-2019
2			Aditya							9-Jan-2019
3			Aman							9-Jan-2019
4			Laxmi							17-Feb-2020    CHanged 		SHowinUI as true for  name: "viewDiscounts",
															as promotions and discount needs to be shown always
5           Ankit Goswami		19-Feb-2020		EDGE-123594 Added setMainSolutionCorrelationID method
6. 			Laxmi 				9-mar-2020		EDGE-138001 - Changed Message when teh config is invalid
7			Laxmi 				23-Mar-2020		EDGE-131531	  Added code to handle Cancel and Active status
8.          Shubhi 				23.mrch.2020		Edge-121376	
9           Ankit Goswami		30-apr-2020		 EDGE-140967 Added Related List Loop on postMessageToPricing method	
10.			Romil Anand			30-apr-2020		 EDGE-144161 Enabling Redemption as Discount for NGUC
11.			Gnana				30-apr-2020		EDGE-140968 Enabling Redemption as Discount for Device Payout 
12. 		Aman Soni			5-May-2020		EGDE-143527 Added Modify and New check by Aman Soni To hide promotion link in case of 
10.			Romil Anand			6-May-2020		 EDGE-144161 Enabling Redemption as Discount for NGUC 
13.			Kiran				23-Apr-2020		DPG-1512 - CWP Adoption of Common Comp.
14. 		Aman Soni			13-May-2020 	Modified by Aman Soni as a part of EDGE-145148
15.         Shubhi V 			02-June-2020	EDGE-151069 taxtreatment in cli
16. 		Shubhi V 			28-June-2020    Edge-149830 device care pricing
17.         Arinjay Singh   	02-July-2020    EDGE-155244 : JSPlugin Upgrade  and Merge with 20.08
18.         Shubhi Vijayvergia	21.08.2020		//added by shubhi for EDGE-169593 -redemptions fix for em,nguc and dop
19.         Shubhi /samish             28-july-2020    20.12          //EDGE-165013
20. 		Gunjan Aswani       14-09-2020  20.12 JS Optimization

21.         Aarathi Iyer 12/10/2020   20.13     EDGE-183264 - changed the change type of device care
22.		    Pawan Singh			11-08-2021		DIGI-5648	replacing Telstra collaboration to Adaptive collaboration
23.		  	Sonalisa verma		17-09-2021		INC000097426025	fixes for div shadowing contract type lookup control in devices tab

*******************/
console.log('Load pricingUtils');
var NGUC_OFFER_NAME = 'Adaptive Collaboration'; //DIGI-5648
var ENTERPRISE_COMPONENTS = {
	enterpriseMobility: 'Corporate Mobile Plus',
	mobileSubscription: 'Mobile Subscription',
	device: 'Device',
};
// var solutionList = ['Corporate Mobile Plus', 'Telstra Collaboration', 'Connected Workplace','Device Outright Purchase']; DIGI-5648
var solutionList = ['Corporate Mobile Plus', NGUC_OFFER_NAME, 'Connected Workplace','Device Outright Purchase'];
var ENTERPRISE_Mobility = {
	mainSolution: 'Corporate Mobile Plus',
	componentName: 'Mobile Subscription',
	correlationId_attribute: 'correlationId',
	DiscountStatus_attribute: 'DiscountStatus',
	attribbuteListforCLi: ['Select Plan', 'SelectPlanName', 'isRecontractingDiscountEligible', 'TotalPlanBonus', 'IDD ChargeLookup', 'RemainingTerm', 'BussinessId_PI', 'IsDiscountCheckNeeded', 'PlanShadowTCV', 'IDDShadowTCV', 'IDD Charge', 'RC', 'ChangeType', 'SelectPlanType', 'PlanTypeString', 'BillingAccountNumber', 'OldPlanTypeString', 'OldIDD', 'OldDataPackPlan', 'DP Plan', 'BussinessId_Addon', 'initialActivationDate', 'InternationalDirectDial', 'ContractTerm', 'isPaymentTypeOneFund', 'deviceTypeBusinessID', 'IsRedeemFundCheckNeeded'],
	attribbuteListforDeviceCLi: ['GUID', 'MobileDeviceETC', 'EarlyTerminationCharge', 'RedeemFund', 'taxTreatmentETC'] // Added as part of EDGE-140967 //EDGE-151069
};
var NEXTGENUC_DEVICE = {
	// mainSolution: 'Telstra Collaboration',  DIGI-5648
	mainSolution: NGUC_OFFER_NAME,
	componentName: 'Devices',
	correlationId_attribute: 'correlationId',
	DiscountStatus_attribute: 'DiscountStatus',
	attribbuteListforCLi: ['ContractType', 'OC', 'BussinessId_Device', 'PriceItemId', 'RC', 'Quantity', 'IsDiscountCheckNeeded', 'IsRedeemFundCheckNeeded', 'RedeemFund', 'isEAPActive', 'forceScheduleButton', 'ContractTerm', 'taxTreatmentETC', 'ETCPriceItemID', 'taxTreatment', 'EarlyTerminationCharge'] ////EDGE-151069
};
var NEXTGENUC_VOICE = {
	// mainSolution: 'Telstra Collaboration',  DIGI-5648
	mainSolution: NGUC_OFFER_NAME,
	componentName: 'Business Calling',
	correlationId_attribute: 'correlationId_voice',
	DiscountStatus_attribute: 'DiscountStatus_voice',
	attribbuteListforCLi: ['ContractTerm', 'IsDiscountCheckNeeded', 'callingPlans', 'Mode', 'ModeString', 'isEAPActive', 'forceScheduleButton']
};
var NEXTGENUC_Accessory = {
	// mainSolution: 'Telstra Collaboration', DIGI-5648
	mainSolution: NGUC_OFFER_NAME,
	componentName: 'Accessories',
	correlationId_attribute: 'correlationId_Accessory',
	DiscountStatus_attribute: 'DiscountStatus_Accessory',
	attribbuteListforCLi: ['ContractType', 'ContractTerm', 'OC', 'BussinessId_Accessory', 'PriceItemId', 'RC', 'Quantity', 'IsDiscountCheckNeeded', 'IsRedeemFundCheckNeeded', 'RedeemFund', 'taxTreatmentETC', 'ETCPriceItemID', 'taxTreatment', 'EarlyTerminationCharge'] ////EDGE-151069
};
var CWP_Mobility = {
	mainSolution: 'Connected Workplace',
	componentName: 'CWP Mobile Subscription',
	correlationId_attribute: 'correlationId',
	DiscountStatus_attribute: 'DiscountStatus',
	attribbuteListforCLi: ['Select Plan', 'SelectPlanName', 'isRecontractingDiscountEligible', 'TotalPlanBonus', 'IDD ChargeLookup', 'RemainingTerm', 'BussinessId_PI', 'IsDiscountCheckNeeded', 'PlanShadowTCV', 'IDDShadowTCV', 'IDD Charge', 'RC', 'ChangeType', 'SelectPlanType', 'PlanTypeString', 'BillingAccountNumber', 'OldPlanTypeString', 'OldIDD', 'OldDataPackPlan', 'DP Plan', 'BussinessId_Addon', 'initialActivationDate', 'InternationalDirectDial', 'ContractTerm', 'isPaymentTypeOneFund', 'deviceTypeBusinessID']
};
var DOP_MOBILEDEVICE = {
	mainSolution: 'Device Outright Purchase',
	componentName: 'Mobile Device',
	correlationId_attribute: 'correlationId',
	DiscountStatus_attribute: 'DiscountStatus',
	attribbuteListforCLi: ['MobileHandsetColour', 'OneOffCharge', 'TotalOneOffCharge', 'Quantity', 'BussinessId', 'IsRedeemFundCheckNeeded', 'RedeemFund', 'taxTreatment'] //EDGE-151069
};
var NextGen_Device = {
	mainSolution: 'Adaptive Mobility',
	componentName: 'Device',
	correlationId_attribute: 'correlationId',
	DiscountStatus_attribute: 'DiscountStatus',
	attribbuteListforCLi: ['OC', 'TotalOneOffCharge', 'Quantity', 'BusinessId', 'IsRedeemFundCheckNeeded', 'RedeemFund', 'taxTreatment', 'PriceItemId', 'taxTreatmentETC', 'ETCPriceItemID', 'EarlyTerminationCharge'],
	attribbuteListforDeviceCLi: ['GUID', 'OC', 'TotalOneOffCharge', 'Quantity', 'BusinessId', 'IsRedeemFundCheckNeeded', 'RedeemFund', 'taxTreatment', 'PriceItemId', 'taxTreatmentETC', 'ETCPriceItemID', 'EarlyTerminationCharge'] // Added as part of Edge-149830 
};
var RedemptionApplicableCompList = ['Mobile Device', 'Accessories', 'Devices'];
var pricing_isChildApplicable = new Map([
	['Mobile Subscription', true],
	['Devices', false],
	['Accessories', false],
	['Device Outright Purchase', false],
	['Device', true],
	['CWP Mobile Subscription', false]
]);
var redemption_changeTypeChild = new Map([
	['Mobile Subscription', 'ChangeTypeDevice'],

	['Device', 'ChangeType']//EDGE-183264
]);
var callerName = '';
var pricingUtils = {
	//ADDED BY SHUBHI FOR HANDLE I-FRAME METHODS to getGuid list to be updated for TCV calculation
	getGuidListforRemoteAction: async function (mainSolutionName, pisolutionName) {
		let guidList = [];
		let product = await CS.SM.getActiveSolution();
		if (product && product.name === mainSolutionName && (product.components && Object.values(product.components).length > 0)) {          
			let comp = await product.getComponentByName(pisolutionName);
            if(comp){
				let cmpConfig = await comp.getConfigurations();
				if(cmpConfig && Object.values(cmpConfig).length > 0){
					Object.keys(cmpConfig).forEach((config) => {
						guidList.push(config.guid);							 
					});
				}              	
            }         
		}
		return Promise.resolve(guidList);
	},
	//ADDED BY SHUBHI FOR HANDLE I-FRAME METHODS
	handleIframeDiscountGeneric: async function (command, data, caller, IsDiscountCheckAttr, IsRedeemFundCheckAttr, ApplicableGuid) {
		let mainSolution = '';
		let componentName = '';
		callerName = caller;	
		switch(caller) {
			case 'Enterprise Mobility': 
				mainSolution = ENTERPRISE_Mobility.mainSolution;
				componentName = ENTERPRISE_Mobility.componentName;
			break;
			case 'Devices':
				mainSolution = NEXTGENUC_DEVICE.mainSolution;
				componentName = NEXTGENUC_DEVICE.componentName;
			break;
			case 'Accessories':
				mainSolution = NEXTGENUC_Accessory.mainSolution;
				componentName = NEXTGENUC_Accessory.componentName;
			break;
			case 'Business Calling':
				mainSolution = NEXTGENUC_VOICE.mainSolution;
				componentName = NEXTGENUC_VOICE.componentName;
			break;
			case 'Caller Identified as CWP':
				mainSolution = CWP_Mobility.mainSolution;
				componentName = CWP_Mobility.componentName;
			break;
			case 'Mobile Device':
				mainSolution = DOP_MOBILEDEVICE.mainSolution;
				componentName = DOP_MOBILEDEVICE.componentName;
			break;
			case 'Device':
				mainSolution = NextGen_Device.mainSolution;
				componentName = NextGen_Device.componentName;
			break;
			default:
				console.log("No caller match found");
		}
		if(command){
			switch(command) {
				case 'correlationId':
					pricingUtils.setCorrelationId(data, mainSolution);
				break;	
				case 'timeout':
					pricingUtils.customLockSolutionConsole('unlock');	
					if (data)
						pricingUtils.setCorrelationId(data, mainSolution);
					if (componentName === NEXTGENUC_VOICE.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus_voice');
					} else if (componentName === NEXTGENUC_Accessory.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus_Accessory'); //added by Romil 144161
					} else {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus');
					}
				break;
				case 'ResponseReceived':
					if (data) {
						let guidList = [];
						let product = await CS.SM.getActiveSolution();
						let currentBasket = await CS.SM.getActiveBasket();
						if (product && product.name === mainSolution && (product.components && Object.values(product.components).length > 0)) {
							let comp = await product.getComponentByName(mainSolution);							
								if(comp){
									let cmpConfig = await comp.getConfigurations();	
									Object.keys(cmpConfig).forEach((config) => {
										guidList.push(config.guid);							 
									});	
								} 
						}		
						let inputMap = {};
						inputMap['configIdList'] = guidList.toString();
						inputMap['CorrelationId'] = data;
						if (IsDiscountCheckAttr === 'true') {
							await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async response => {
								let resultTCV = JSON.stringify(response["TCVMap"]);								
								if (resultTCV) {					
									let res3 = response.TCVMap;
									let updateConfigMap1 = {};
									let configTobeUpdated = false;
									let mainKey = '';
									Object.keys(res3).forEach(valueKey => {
										mainKey = valueKey.replace(/['"]+/g, '');
										let attrNameMap = JSON.stringify(res3[valueKey])
										let attrName = JSON.parse(attrNameMap);
										updateConfigMap1[mainKey.toString()] = [];
										Object.keys(attrName).forEach(keyValue => {
											if (keyValue.toString() != null && keyValue.toString() != '' && keyValue.toString() != undefined) {
												updateConfigMap1[mainKey.toString()].push({
													name: keyValue.toString(),
													value: attrName[keyValue],
													displayValue: attrName[keyValue],
													readOnly: true
												},
												{
													name: "IsDiscountCheckNeeded",
													value: false
												},
												{
													name: "Price Schedule",
													showInUi: true
												});
											}
										});
									});
									if (configTobeUpdated === true) {
										let component = await product.getComponentByName(componentName);
										let keys = Object.keys(updateConfigMap1);
										for (let i = 0; i < keys.length; i++) {
											await component.updateConfigurationAttribute(keys[i], updateConfigMap1[keys[i]], false);
										}
										if (componentName === NEXTGENUC_VOICE.componentName) {
											pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus_voice');
										} else if (componentName === NEXTGENUC_Accessory.componentName) {
											pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus_Accessory');
										} else {
											pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus');
										}
										if (componentName === 'Mobile Subscription' || componentName === 'CWP Mobile Subscription') {
											let IsUpadate = CheckErrorsOnSolution();
											//console.log('updateConfigMap1:::', updateConfigMap1);
											if (!IsUpadate) {
												let cnfg = await component.getConfiguration(mainKey.toString());
												cnfg.status = true;
											} else {
												pricingUtils.resetDiscountAttributes(ENTERPRISE_COMPONENTS.mobileSubscription);
											}
										}
										['Promotions and Discounts', 'Price Schedule', 'Rate Card'].forEach(el => BulkUtils.updateCustomAttributeLinkText(el, 'View All'));
									}
								} else {
									CS.SM.displayMessage('Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.', 'error');
									/*DPG-1512 - Reset IsDiscountCheckNeeded as no response */
									let updateConfigMap1 = {};
									updateConfigMap1[guidList[0]] = [];
									updateConfigMap1[guidList[0]].push({
										name: "IsDiscountCheckNeeded",
										value: false
									});
									let component = await product.getComponentByName(componentName);
									if(updateConfigMap1 && Object.keys(updateConfigMap1).length > 0){
										await component.updateConfigurationAttribute(guidList[0], updateConfigMap1, false);
									}
								}
							});
						}
						if (IsRedeemFundCheckAttr === 'true') {
							pricingUtils.validateApplicableConfigsJS(ApplicableGuid, componentName);
						}
						setTimeout(function () {
							pricingUtils.closeModalPopup();
						}, 1000);
						pricingUtils.customLockSolutionConsole('unlock');
						return Promise.resolve(true);
					}
				break;
				case 'unlockBasket':
					if (data)
						pricingUtils.validateNotApplicableConfigsJS(data, componentName);
					if (componentName === NEXTGENUC_VOICE.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus_voice');
					} else if (componentName === NEXTGENUC_Accessory.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus_Accessory');
					} else {
						pricingUtils.setDiscountStatusBasedonComponent('Acknowledge', mainSolution, 'DiscountStatus');
					}
					pricingUtils.customLockSolutionConsole('unlock');
					setTimeout(function () {
						pricingUtils.closeModalPopup();
					}, 1000);
					return Promise.resolve(true);
				case 'validNotApplicableConfigs':
					if (data)
						pricingUtils.validateNotApplicableConfigsJS(data, componentName);
					return Promise.resolve(true);
				case 'Already triggered':
					pricingUtils.customLockSolutionConsole('unlock');
					setTimeout(function () {
						pricingUtils.closeModalPopup();
					}, 1000);
					return Promise.resolve(true);
				case 'ErrorInResponse':
					pricingUtils.customLockSolutionConsole('unlock');
					if (componentName === NEXTGENUC_VOICE.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus_voice');
					} else if (componentName === NEXTGENUC_Accessory.componentName) {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus_Accessory');
					} else {
						pricingUtils.setDiscountStatusBasedonComponent('None', mainSolution, 'DiscountStatus');
					}
					//console.log('Price schedule could not be generated');
					CS.SM.displayMessage('Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.', 'error'); // added by shubhi for error //Edge-121376
					setTimeout(function () {
						pricingUtils.closeModalPopup();
					}, 1000);
					return Promise.resolve(true);
				}          
		}
		return Promise.resolve(true);
	},
	//added by Aditya for edge-123575 // ***use only for EM not for other product for other product use -
	setDiscountAttribute: async function () {
		console.log('Inside setDiscountAttribute');
		let product = await CS.SM.getActiveSolution();
		let component = await product.getComponentByName(product.name);
		let updateMap = {};
		let updateCurr = false;
		if(component){
			let cmpConfig = await component.getConfigurations();
			if (product && product.components && (solutionList.includes(product.name)) && (cmpConfig && Object.values(cmpConfig).length > 0)) {						
				Object.values(cmpConfig).find(async (config) => {
					if (config.attributes && Object.values(config.attributes).length > 0) {
						Object.values(config.attributes).find((att) => {
							if (att.name === 'DiscountStatus') {
								updateMap[config.guid] = [{
									name: "DiscountStatus",
									value: "Locked",
								}];
								updateCurr = true;
							}
						});
						if (updateCurr) {
							let keys = Object.keys(updateMap);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
							}
							updateCurr = false;
						}
					}
				});			
		}
		}		
		return Promise.resolve(true);
	},
	// added by shubhi edge-123575
	//method to lock or unlock the solution console via custom stylesheets
	customLockSolutionConsole: function (actionStr) {
		let rootElement;
		url = window.location.href;
		if (url.includes('lightning')) {
			rootElement = document.getElementsByTagName("app-root")[0];
		} else {
			rootElement = document.getElementById("contentWrapper");
			if (!rootElement || rootElement === null)
				rootElement = document.getElementsByTagName("app-root")[0];
		}
		//get all buttons that this logic should support, asumption is that those buttons are never rendered together on the UI
		let buttonElements = document.querySelectorAll('*[id^="getPriceScheduleAPI"]');
		switch (actionStr) {
			case 'lock':
				rootElement.classList.add("spinner-overlay");
				rootElement.classList.add("custom-overlay-solution");
				buttonElements.forEach((buttonElem) => {
					buttonElem.classList.add("custom-allow-pointer-button");
				});
				break;
			case 'unlock':
				rootElement.classList.remove("spinner-overlay");
				rootElement.classList.remove("custom-overlay-solution");
				buttonElements.forEach((buttonElem) => {
					buttonElem.classList.remove("custom-allow-pointer-button");
				});
		}
		return Promise.resolve(true);
	},
	/// custom attribute Price schedule visiblity based on shadow tcv for EM edge-123575
	//Modified by Aman Soni as a part of EDGE-145148 
	resetCustomAttributeVisibility: async function () {
		console.log('@@@@@@@@@@@@@@inside reset@@@@@@@@@@@@');
		let solution = await CS.SM.getActiveSolution();
		//GA Changes REVIEW
		if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) || solution.name.includes('Connected Workplace')) {
			if (solution.components && Object.values(solution.components).length > 0) {
				let updateConfigMap = {};
				let updateCurr = false;
				Object.values(solution.components).forEach(async (comp) => {
					let cmpConfig = await comp.getConfigurations();
					if (comp.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription && (cmpConfig && Object.values(cmpConfig).length > 0))) {
						Object.values(cmpConfig).forEach((config) => {
							updateConfigMap[config.guid] = [];
							let IDDShadowTCV_value = '';
							let PlanShadowTCV_value = '';
							let TotalPlanBonus_value = '';
							let TotalPlanBonus = config.getAttribute('TotalPlanBonus');
							if (TotalPlanBonus.length > 0 && TotalPlanBonus.value && TotalPlanBonus.value != null) {
								TotalPlanBonus_value = TotalPlanBonus.value;
								console.log('TotalPlanBonus_value ' + TotalPlanBonus_value);
							}
							let IDDShadowTCV = config.getAttribute('IDDShadowTCV');
							let PlanShadowTCV = config.getAttribute('PlanShadowTCV');
							if (IDDShadowTCV.length > 0 && IDDShadowTCV.value && IDDShadowTCV.value != null) {
								IDDShadowTCV_value = IDDShadowTCV.value;
							}
							if (PlanShadowTCV.length > 0 && PlanShadowTCV.value && PlanShadowTCV.value != null) {
								PlanShadowTCV_value = PlanShadowTCV.value;
							}
							let changeTypeVal = '';;
							let ChangeType = config.getAttribute('ChangeType');
							if (ChangeType.length > 0 && ChangeType.value && ChangeType.value != null) {
								changeTypeVal = ChangeType.value;
							}
							if (IDDShadowTCV || PlanShadowTCV) {
								if (((IDDShadowTCV_value !== null && IDDShadowTCV_value !== '') || (PlanShadowTCV_value !== null && PlanShadowTCV_value !== '')) && (changeTypeVal === 'Modify' || (changeTypeVal === 'New' && (config.replacedConfigId === undefined || config.replacedConfigId === null)))) { //Added Modify and New check by Aman Soni as a part of EGDE-143527
									console.log('button vis inside if setting to true');
									updateConfigMap[config.guid].push({
										name: "Price Schedule",
										showInUi: true
									});
									if (comp.name.includes('CWP') && TotalPlanBonus_value != '') {
										updateConfigMap[config.guid].push({
											name: "viewDiscounts",
											showInUi: true
										});
									}
									updateCurr = true;
								} 
							}
							if (changeTypeVal != null && (changeTypeVal === 'Active' || changeTypeVal === 'Cancel')) {
								updateConfigMap[config.guid].push({
									name: "Price Schedule",
									showInUi: false
								}, {
									name: "viewDiscounts",
									showInUi: false
								});
								updateCurr = true;
							}
						});
						Utils.updateImportConfigButtonVisibility();
					}
				});
				if (updateCurr) {
					let activeSolution = await CS.SM.getActiveSolution();
					let component = await activeSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
					}
					['Promotions and Discounts', 'Price Schedule'].forEach(el => updateCustomAttributeLinkText(el, 'View All') );
					updateCurr = false;
				}
			}
		}
		return Promise.resolve(true);
	},
	resetCustomAttributeVisibilityNGUC_Device: async function () {
		console.log('@@@@@@@@@@@@@@inside reset@@@@@@@@@@@@');
		let solution = await CS.SM.getActiveSolution();
		if (solution && solution.name.includes(NEXTGENUC_DEVICE.mainSolution) && solution.components && Object.values(solution.components).length > 0) {
				let updateConfigMap = {};
				let updateCurr = false;		
				Object.values(solution.components).foreach(async (comp) => {
					let cmpConfig = await comp.getConfigurations();
					if (comp.name === NEXTGENUC_DEVICE.componentName && (cmpConfig && Object.values(cmpConfig).length > 0)) {
						Object.values(cmpConfig).find((config) => {
							updateConfigMap[config.guid] = [];
							let deviceShadowRCTCV_value = '';
							let deviceShadowRCTCV = Object.values(config.attributes).filter(deviceShadowRCTCV => {
								return deviceShadowRCTCV.name === 'deviceShadowRCTCV'
							});
							if (deviceShadowRCTCV.length > 0 && deviceShadowRCTCV[0].value && deviceShadowRCTCV[0].value != null) {
								deviceShadowRCTCV_value = deviceShadowRCTCV[0].value;
							}
							if (deviceShadowRCTCV) {
								if (deviceShadowRCTCV_value && deviceShadowRCTCV_value != undefined && deviceShadowRCTCV_value != null && deviceShadowRCTCV_value != "") {
									updateConfigMap[config.guid].push({
										name: "Price Schedule",
										showInUi: true
									});
									updateCurr = true;
								}
							}
						});
					}
				});
				if (updateCurr) {
					if (updateConfigMap) {
						let component = await solution.getComponentByName(solutionName);			
						if(updateConfigMap1 && Object.keys(updateConfigMap).length > 0){
							await component.updateConfigurationAttribute(config.guid, updateConfigMap, false);
						}
					}					
					updateCurr = false;
				}
		}
		return Promise.resolve(true);
	},
	//Aditya for NGUC MACD EDGE-121389---Start--->
	resetCustomAttributeVisibilityNGUC_Voice: async function (showRateCart) {
		let solution = await CS.SM.getActiveSolution(); // Spring 20
		if (solution && solution.name.includes(NEXTGENUC_VOICE.mainSolution && (solution.components && Object.values(solution.components).length > 0))) {
			let updateConfigMap = {};
			let updateCurr = false;
			//REVIEW with Pallavi GA Changes Also this method can be removed from NGUC as well as here
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === NEXTGENUC_VOICE.componentName) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							updateConfigMap[config.guid] = [];
							let ChangeType_Value = '';
							let IsDiscountCheckNeededAttr_value = '';
							let IsDiscountCheckNeededAttr = Object.values(config.attributes).filter(IsDiscountCheckNeededAttr => {
								return IsDiscountCheckNeededAttr.name === 'IsDiscountCheckNeeded'
							});
							let ChangeTypeAttr = Object.values(config.attributes).filter(ChangeTypeAttr => {
								return ChangeTypeAttr.name === 'ChangeType'
							});
							if (IsDiscountCheckNeededAttr.length > 0 && IsDiscountCheckNeededAttr[0].value && IsDiscountCheckNeededAttr[0].value != null) {
								IsDiscountCheckNeededAttr_value = IsDiscountCheckNeededAttr[0].value;
							}
							if (ChangeTypeAttr.length > 0 && ChangeTypeAttr[0].value && ChangeTypeAttr[0].value != null) {
								ChangeType_Value = ChangeTypeAttr[0].value;
							}
							if (ChangeTypeAttr) {
								//console.log('@@@@@@@@@@@@@@inside if 1 @@@@@@@@@@@@');
								//console.log('condition 1' + ChangeType_Value);
								if (showRateCart == false && ChangeType_Value && ChangeType_Value != undefined && ChangeType_Value != null && ChangeType_Value != "" && (ChangeType_Value == 'Modify' || ChangeType_Value == 'Active' || ChangeType_Value == 'New' || ChangeType_Value == 'Cancel')) {
									console.log('button vis inside if setting to true');
									updateConfigMap[config.guid].push({
										name: "NGUCRateCardButton",
										showInUi: false
									});
									updateCurr = true;
								}
								if (showRateCart == true && ChangeType_Value && ChangeType_Value != undefined && ChangeType_Value != null && ChangeType_Value != "" && ChangeType_Value == 'Modify') {
									console.log('button vis inside if setting to true');
									updateConfigMap[config.guid].push({
										name: "NGUCRateCardButton",
										showInUi: true
									});
									let cnfg = await comp.getConfiguration(config.guid); 
									cnfg.status = true;
									updateCurr = true;
								}
								if (IsDiscountCheckNeededAttr_value == false && ChangeType_Value && ChangeType_Value != undefined && ChangeType_Value != null && ChangeType_Value != "" && ChangeType_Value == 'Modify') {
									console.log('button vis inside if setting to true');
									updateConfigMap[config.guid].push({
										name: "NGUCRateCardButton",
										showInUi: true
									});
									let cnfg = await comp.getConfiguration(config.guid);
									cnfg.status = true;
									updateCurr = true;
								}
							}
						});
					}
				}
			});
			if (updateCurr) {
				if (updateConfigMap) {
					let component = await solution.getComponentByName(NEXTGENUC_VOICE.componentName);
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
				updateCurr = false;
			}
		}
		return Promise.resolve(true);
	},
	//Aditya for NGUC MACD EDGE-121389---END--->
	//// method to reset attributes if change in configurations Edge-123575 // also to call this method if new configuration is getting clonned from existing configuration before validate and save
	resetDiscountAttributes: async function (configId, componentName) {
		console.log('Inside reset check need-->' + configId);
		let updateConfigMap = [];
		updateConfigMap[configId] = [];
		updateConfigMap[configId].push({
			name: "IsDiscountCheckNeeded",
			value: true
		});
		if (componentName !== NEXTGENUC_VOICE.componentName) {
			updateConfigMap[configId].push({
				name: "Price Schedule",
				showInUi: false
			});
		}
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName);
		if (component && component != null && component != undefined) {
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
			}
		}
		else
		//console.log("Could not find component ", componentName);
		//console.log('reset IsDiscountCheckNeeded');		
		['Promotions and Discounts', 'Price Schedule', 'Rate Card'].forEach(el => BulkUtils.updateCustomAttributeLinkText(el, 'View All'));
		return Promise.resolve(true);
	},
	//adedd by shubhi for validNotApplicableConfigs
	validateNotApplicableConfigsJS: async function (guidListJson, componentname) {
		let guidListString = guidListJson;
		guidListString = guidListString.replace("[", '');
		guidListString = guidListString.replace("]", '');
		let guidList = guidListString.split(',');
		let updateConfigMap = {};
		let updateSub = false;
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentname);
		let guidID;
		guidList.forEach(async (guid) => {
			guidID = guid.trim();
			if (guidID !== null && guidID !== '') {
				console.log('Inside updatemap', guidID);
				updateSub = true;
				updateConfigMap[guidID] = [];
				updateConfigMap[guidID] = [{
					name: "IsDiscountCheckNeeded",
					value: false
				}];
			}
		});
		if (updateSub) {
			if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                let keys = Object.keys(updateConfigMap);
				for (let i = 0; i < keys.length; i++) {
                	var config= await component.getConfiguration(keys[i]);
                    config.status=true; 
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false); 
				}
			}
		}
		solution = await CS.SM.getActiveSolution();
		if (solution) {
			//Added by Shubhi as a part of EDGE-133963 
			//pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_DEVICE.componentName);
			//pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_VOICE.componentName);
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	 * Author	   : Ankit Goswami
	 * EDGE number : EDGE-140967
	 * Method Name : validateApplicableConfigsJS
	 * Invoked When: RedeemFund Will be change or Change Type on Device or Change Type on Mobile device will change.
	 * Description : Update RedeemCheck Flag as false
	 ***********************************************************************************************/
	validateApplicableConfigsJS: async function (guidListJson, componentname) {
		var guidListString=guidListJson;
        guidListString=guidListString.replace("[",'');
        guidListString=guidListString.replace("]",'');
        var guidList = guidListString.split(',');
		var updateConfigMap={};
		var updateSub=false;
		let activeSolution = await CS.SM.getActiveSolution();  
		let component = await activeSolution.getComponentByName(componentname); 
        guidList.forEach(async (guid) => {
            var guidID=guid.trim();
            if(guidID !==null && guidID !==''){
				updateSub = true;
				updateConfigMap[guidID] = [];
				updateConfigMap[guidID] = [{
					name: "IsRedeemFundCheckNeeded",
					value: false
                },{
						name: 'CheckOneFund',//added by shubhi for EDGE-169593
							value: false,
							displayValue: false
				}];
			}
		});
        if(updateSub){
			if (updateConfigMap){ //Aditya changes after Antun comment 
				let keys = Object.keys(updateConfigMap);
				for (let i = 0; i < keys.length; i++) {
					let config= await component.getConfiguration(keys[i]);
                    config.status=true;
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
				}
			}
		}
		return Promise.resolve(true);
	},
	///////////////////////////////////////////////Samish-Aditya For EDGE-132203 Error handling//////////////////////
	setIsDiscountCheckNeeded: async function (compSchema, cmpName) {
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(cmpName);
		if(component){
			let cmpConfig = await component.getConfigurations();
				if (cmpConfig  && Object.values(cmpConfig).length > 0) {
				Object.values(cmpConfig).forEach(async (subsConfig) => {
					console.log('Inside NGUC 2');
					let changeTypeAttribute = Object.values(subsConfig.getAttribute('ChangeType'));
					let OldPlanTypeStringAttr = Object.values(subsConfig.getAttribute('OldPlanTypeString'));
					let OldIDDAttr = Object.values(subsConfig.getAttribute('OldIDD'));
					let SelectPlanAttr = Object.values(subsConfig.getAttribute('Select Plan'));
					let InternationalDirectDialAttr = Object.values(subsConfig.getAttribute('InternationalDirectDial'));
					let IsRedeemFundCheckNeededAttr = Object.values(subsConfig.getAttribute('IsRedeemFundCheckNeeded'));
					if (subsConfig.attributes && Object.values(subsConfig.attributes).length > 0 && ((changeTypeAttribute[0].value !== 'Cancel' && changeTypeAttribute[0].value !== 'Active' && (OldPlanTypeStringAttr[0].value !== SelectPlanAttr[0].displayValue || OldIDDAttr[0].value !== InternationalDirectDialAttr[0].displayValue)) || IsRedeemFundCheckNeededAttr[0].value === true /*&& changeTypeAttribute[0].value !== 'Modify'*/ )) { // Added conditions as part of EDGE-134880 //Added IsRedeemFundCheckNeededAttr as part of EDGE-140967
						Object.values(subsConfig.attributes).forEach(async (att) => {
							console.log('Inside NGUC 3');
							if ((att.name === 'IsDiscountCheckNeeded' || att.name === 'IsRedeemFundCheckNeeded') && att.value === true) {
								let config = await component.getConfiguration(subsConfig.guid);
								config.status = false;
								config.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
							}
						});
					} else if (subsConfig.attributes && Object.values(subsConfig.attributes).length > 0 && changeTypeAttribute[0].value !== 'Cancel' && changeTypeAttribute[0].value !== 'Active' && OldPlanTypeStringAttr[0].value === SelectPlanAttr[0].displayValue && OldIDDAttr[0].value === InternationalDirectDialAttr[0].displayValue && IsRedeemFundCheckNeededAttr === false) {
						let config = await component.getConfiguration(subsConfig.guid);
						config.status = true;
					}
				});
			}
		}
		return Promise.resolve(true);
	},
	///////////////	added by shubhi to setCorrelationId ///////////////////////
	setCorrelationId: async function (correlationId, solutionName) {
		let correlationIdAttribute = '';
		let match = false;
		switch(callerName){
			case 'Voice':
				correlationIdAttribute = 'correlationId_voice';
				match = true;
				break;
			case 'Accessories':
				correlationIdAttribute = 'correlationId_accessory';
				match = true;
				break;
		}
		if(!match)
			correlationIdAttribute = 'correlationId';
		let product = await CS.SM.getActiveSolution();
		if (product.components && product.name.includes(solutionName)) {
			let updateMap = {};
			let comp = await product.getComponentByName(solutionName);
			if(comp){
				let cmpConfig = await comp.getConfigurations();		
				if(cmpConfig && Object.values(cmpConfig).length > 0){
						Object.values(cmpConfig).forEach((config) => {
							updateMap[config.guid] = [{
								name: correlationIdAttribute,
								value: correlationId,
								displayValue: correlationId
							}];
						});			
				}
			}
				if (updateMap){
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
					}
				}
		}
		return Promise.resolve(true);
	},
	/////added by shubhi to set discountStatus will in use only for EM now dont use if for other products////////////////
	setDiscountStatus: async function (statusValue, solutionName) {
		console.log('Inside setDiscountStatus' + statusValue);
		console.log('Inside setDiscountAttributeAfterResponse');
		let product = await CS.SM.getActiveSolution();	
		let comp = await product.getComponentByName(solutionName);
		if(comp){
			let cmpConfig = await comp.getConfigurations(); 
		if (product.components && product.name.includes(solutionName) && (cmpConfig && Object.values(cmpConfig).length > 0)) {
			let updateMap = {};	
			Object.values(cmpConfig).forEach((config) => {
				updateMap[config.guid] = [{
				name: 'DiscountStatus',
				value: statusValue
			}];
			});													
			if(updateMap && Object.keys(updateMap) > 0){
				await comp.updateConfigurationAttribute(config.guid, updateMap, false);
			}
		}
	}
		return Promise.resolve(true);
	},
	//////////////	added by shubhi to set discountStatus back to none ///////////////////////
	setDiscountStatusBasedonComponent: async function (statusValue, solutionName, attributeName) {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(solutionName);
		if (comp) {
			let updateMap = {};
			let cmpConfig = await comp.getConfigurations();		
			if(cmpConfig && Object.values(cmpConfig).length >0 ){
				if (cmpConfig&& Object.values(cmpConfig).length > 0) {
					Object.values(cmpConfig).forEach((config) => {
						updateMap[config.guid] = [{
							name: attributeName,
							value: statusValue
						}];
					});
				}
			}
			 let keys = Object.keys(updateMap);
			 for (let i = 0; i < keys.length; i++) {
			 	await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
			 }
		}
		return Promise.resolve(true);
	},
	//EDGE-123594 Added setMainSolutionCorrelationID method
	setMainSolutionCorrelationID: async function () {
		let product = await CS.SM.getActiveSolution();
		let comp = product.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility);
		if (comp && product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
			let updateMap = {};
			let cmpConfig = await comp.getConfigurations();
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				Object.values(cmpConfig).forEach((config) => {
					let onLoadFlagAttribute = config.getAttribute('onLoadFlag');
					if (onLoadFlagAttribute !== 'Yes') {
						updateMap[config.guid] = [{
							name: 'correlationId',
							value: '',
							displayValue: ''
						}, {
							name: 'onLoadFlag',
							value: 'Yes',
							displayValue: 'Yes'
						}];
					}
				});
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		return Promise.resolve(true);
	},
	//EDGE-123594 Added setMainSolutionCorrelationID method
	setMainSolutionCorrelationIDToNull: async function (solName) {
		let product = await CS.SM.getActiveSolution();
		if (product && product.components && product.name === solName) {
			let updateMap = {};
			let comp = await product.getComponentByName(solName);
			let cmpConfig = await comp.getConfigurations();
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				Object.values(cmpConfig).forEach((config) => {
					let onLoadFlagAttribute = config.getAttribute('onLoadFlag');
					if (onLoadFlagAttribute !== 'Yes') {
						updateMap[config.guid] = [{
							name: 'correlationId',
							value: '',
							displayValue: ''
						}, {
							name: 'onLoadFlag',
							value: 'Yes',
							displayValue: 'Yes'
						}];
					}
				});
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
				}
			}
		}
		return Promise.resolve(true);
	},
	//generic method to check if price schedules are generated or not and to invalidate configuration 
	checkDiscountValidation: async function (solution, attributeName, componentName) {
		let skipsave = false;
		let cmpConfigs;
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach(async (comp) => {
				cmpConfigs = await comp.getConfigurations();
				if (comp.name === componentName && (cmpConfigs && Object.values(cmpConfigs).length > 0)) {
					Object.values(cmpConfigs).forEach(async (config) => {
						let IsDiscountCheckNeededAtt = config.getAttribute(attributeName);
						if (IsDiscountCheckNeededAtt && IsDiscountCheckNeededAtt && IsDiscountCheckNeededAtt.value === true) {
							let cnfg = await comp.getConfiguration(config.guid);
							cnfg.status = false;
							cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
							skipsave = true;
						}
					});
				}
			});
		}
		return skipsave;
	},
	updateGenerateNetPriceButtonVisibility: function (buttonLabel) {
		console.log('Insie updateGenerateNetPriceButtonVisibility');
		let isCommNegAllowed = Utils.isCommNegotiationAllowed();
		let isDefaultButton = false;
		Utils.updateComponentLevelButtonVisibility(buttonLabel, isCommNegAllowed, isDefaultButton);
	},
	/*********************************************Edge-Edge-143527 *********************************/
	postMessageToPricing: async function (caller, solutionID, isDiscountcheckNeeded, IsRedeemFundCheckNeeded) {
		let mainSolution = '';
		let componentName = '';
		let attribbuteListforCLi = [];
		let attribbuteListforDeviceCLi = [];
		callerName = caller;
		let guidCompMap = {};
		switch(caller) {
			case 'Enterprise Mobility': 
				mainSolution = ENTERPRISE_Mobility.mainSolution;
				componentName = ENTERPRISE_Mobility.componentName;
				attribbuteListforCLi = ENTERPRISE_Mobility.attribbuteListforCLi;
				attribbuteListforDeviceCLi = ENTERPRISE_Mobility.attribbuteListforDeviceCLi
			break;
			case 'Devices':
				mainSolution = NEXTGENUC_DEVICE.mainSolution;
				componentName = NEXTGENUC_DEVICE.componentName;
				attribbuteListforCLi = NEXTGENUC_DEVICE.attribbuteListforCLi;
			break;
			case 'Accessories':
				mainSolution = NEXTGENUC_Accessory.mainSolution;
				componentName = NEXTGENUC_Accessory.componentName;
				attribbuteListforCLi = NEXTGENUC_Accessory.attribbuteListforCLi;
			break;
			case 'Business Calling':
				mainSolution = NEXTGENUC_VOICE.mainSolution;
				componentName = NEXTGENUC_VOICE.componentName;
				attribbuteListforCLi = NEXTGENUC_VOICE.attribbuteListforCLi;
			break;
			case 'Caller Identified as CWP':
				mainSolution = CWP_Mobility.mainSolution;
				componentName = CWP_Mobility.componentName;
				attribbuteListforCLi = CWP_Mobility.attribbuteListforCLi;
			break;
			case 'Mobile Device':
				mainSolution = DOP_MOBILEDEVICE.mainSolution;
				componentName = DOP_MOBILEDEVICE.componentName;
				attribbuteListforCLi = DOP_MOBILEDEVICE.attribbuteListforCLi;
			break;
			case 'Device':
				mainSolution = NextGen_Device.mainSolution;
				componentName = NextGen_Device.componentName;
				attribbuteListforCLi = NextGen_Device.attribbuteListforCLi;
				attribbuteListforDeviceCLi = NextGen_Device.attribbuteListforDeviceCLi
			break;
			default:
				console.log("No caller match found");
		}
		//console.log('Inside pricing pagelaod');
		let ifrm = [];
		let product = await CS.SM.getActiveSolution();
		let cmpConfig;
		if (product.name.includes(mainSolution) && (product.components && Object.values(product.components).length > 0)) {
			Object.values(product.components).forEach(async (comp) => {
				cmpConfig = comp.getConfigurations();			
					if (comp.name === componentName && (cmpConfig && Object.values(cmpConfig).length > 0)) {
						Object.values(cmpConfig).forEach((config) => {
							let guid = config.guid;
							let attnameToattMap = {};
							let changeTypeVal = '';
							if (config && config.attributes) {
								let ChangeTypes = config.getAttribute('ChangeType');
								if (ChangeTypes && ChangeTypes) {
									changeTypeVal = ChangeTypes.value;
								}
								for (let att of Object.values(config.attributes)) {
									if (attribbuteListforCLi.includes(att.name)) {
										if (changeTypeVal === 'Cancel' && (caller === 'Devices' || caller === 'Accessories' || caller === 'Device')) {
											if (att.name === 'taxTreatmentETC' || att.name === 'taxTreatment') {
												let taxTreatment = config.getAttribute('taxTreatmentETC');
												if (taxTreatment && taxTreatment) {
													let taxtreatmentAtt = {
														name: 'taxTreatment',
														value: taxTreatment.value
													}
													attnameToattMap['taxTreatment'] = taxtreatmentAtt;
												}
											} else if (att.name === 'OC' || att.name === 'EarlyTerminationCharge') {
												let etc = config.getAttribute('EarlyTerminationCharge');
												if (etc && etc) {
													let etcAtt = {
														name: 'OC',
														value: etc.value
													}
													attnameToattMap['OC'] = etcAtt;
												}
											} else if (att.name === 'PriceItemId' || att.name === 'ETCPriceItemID') {
												console.log('att.name-->' + att.name);
												let priceItemAtt = config.getAttribute('ETCPriceItemID');
												console.log('priceItemAtt-->' + priceItemAtt);
												if (priceItemAtt) {
													let priceItemAttVal = {
														name: 'PriceItemId',
														value: priceItemAtt.value
													}
													attnameToattMap['PriceItemId'] = priceItemAttVal;
												}
											} else {
                                                let atttribute={
													name:att.name,
													value:att.value,
													displayvalue:att.displayValue
												};
												attnameToattMap[att.name]=atttribute;
												//attnameToattMap[att.name] = att;
											}
										} else {
											let atttribute={
												name:att.name,
												value:att.value,
												displayvalue:att.displayValue
											};
											attnameToattMap[att.name]=atttribute;
											//attnameToattMap[att.name] = att;
										}
									}
								}
							}
							//Edge-149830  start-----------------
							let isChildApplicable = pricing_isChildApplicable.get(comp.name);
							let changeTypeExcludedList = ['Active', 'PaidOut', 'Pending'];
							let changeTypeChild = redemption_changeTypeChild.get(comp.name);
							// Added as part of EDGE-140967 || start
							if (isChildApplicable === true && IsRedeemFundCheckNeeded && config.relatedProductList && config.relatedProductList.length > 0) {
								let attMapChild = {};
								for (let relatedProduct of config.relatedProductList) {
									let ChangeType_child = Object.values(relatedProduct.configuration.attributes).filter(obj => {
										return obj.name === changeTypeChild
									});
									let changetype = '';
									if (ChangeType_child && ChangeType_child[0] && ChangeType_child[0].value) {
										changetype = ChangeType_child[0].value
									} else {
										changetype = 'New';
									}
									let ischildApplicable = {
										name: 'ischildApplicable',
										value: 'true'
									};
									attMapChild['ischildApplicable'] = ischildApplicable;
									for (let att of Object.values(relatedProduct.configuration.attributes)) {
										if (attribbuteListforDeviceCLi.includes(att.name) && !changeTypeExcludedList.includes(changetype)) {
											let atttribute={
												name:att.name,
												value:att.value,
												displayvalue:att.displayValue
											};
											attMapChild[att.name]=atttribute;
											//attMapChild[att.name] = att;
										}
									}
									guidCompMap[relatedProduct.guid] = attMapChild;
								}
							}
							guidCompMap[guid] = attnameToattMap;
						});
					}
			});
		}
		ifrm = document.getElementsByClassName('frame ng-star-inserted');
		let iframepayload = {
			command: solutionID,
			data: guidCompMap,
			caller: caller,
			isDiscountcheckNeeded: isDiscountcheckNeeded,
			IsRedeemFundCheckNeeded: IsRedeemFundCheckNeeded
		};
		if (ifrm.length > 0)
			ifrm[0].contentWindow.postMessage(iframepayload, '*');
		return Promise.resolve(true);
	},
	postMessageToshowPromo: async function (caller, configId, iframeID) {
		let mainSolution = '';
		let componentName = '';
		let attribbuteListforCLi = [];
		callerName = caller;		
		switch(caller) {
			case 'Enterprise Mobility': 
				mainSolution = ENTERPRISE_Mobility.mainSolution;
				componentName = ENTERPRISE_Mobility.componentName;
				attribbuteListforCLi = ENTERPRISE_Mobility.attribbuteListforCLi;
			break;
			case 'Devices':
				mainSolution = NEXTGENUC_DEVICE.mainSolution;
				componentName = NEXTGENUC_DEVICE.componentName;
				attribbuteListforCLi = NEXTGENUC_DEVICE.attribbuteListforCLi;
			break;
			case 'Voice':
				mainSolution = NEXTGENUC_VOICE.mainSolution;
				componentName = NEXTGENUC_VOICE.componentName;
				attribbuteListforCLi = NEXTGENUC_VOICE.attribbuteListforCLi;
			break;
			case 'Accessories':
				mainSolution = NEXTGENUC_Accessory.mainSolution;
				componentName = NEXTGENUC_Accessory.componentName;
				attribbuteListforCLi = NEXTGENUC_Accessory.attribbuteListforCLi;
			break;
			case 'CWP':
				mainSolution = CWP_Mobility.mainSolution;
				componentName = CWP_Mobility.componentName;
				attribbuteListforCLi = CWP_Mobility.attribbuteListforCLi;
			break;
			case 'Mobile Device':
				mainSolution = DOP_MOBILEDEVICE.mainSolution;
				componentName = DOP_MOBILEDEVICE.componentName;
				attribbuteListforCLi = DOP_MOBILEDEVICE.attribbuteListforCLi;
			break;
			case 'Device':
				mainSolution = NextGen_Device.mainSolution;
				componentName = NextGen_Device.componentName;
				attribbuteListforCLi = NextGen_Device.attribbuteListforCLi;
				attribbuteListforDeviceCLi = NextGen_Device.attribbuteListforDeviceCLi
			break;
			default:
				console.log("No caller match found");
		}
		let attnameToattMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product.name.includes(mainSolution)) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).find(async (comp) => {
					let cmpConfig = await comp.getConfigurations();
					if (comp.name === componentName && (cmpConfig && Object.values(cmpConfig).length > 0)) {
						Object.values(cmpConfig).forEach((config) => {
							if (configId == config.guid) {
								Object.values(config.attributes).forEach((att) => {
									if (attribbuteListforCLi.includes(att.name)) {
										attnameToattMap[att.name] = att;
									}
								});
							}
						});
					}
				});
			}
		}
		console.log('postMessageToshowPromo');
		let ifrme = document.getElementById(iframeID);
		let iframepayload = {
			command: configId,
			data: attnameToattMap,
			caller: caller
		};
		if (ifrme)
			ifrme.contentWindow.postMessage(iframepayload, '*');
		return Promise.resolve(true);
	},
	closeModalPopup: function () {
		console.log('inside modal popup');
		try {
			let d = document.getElementsByClassName('mat-dialog-container');
			if (d) {
				for (let i = 0; i < d.length; i++) {
					d[i].parentElement.removeChild(d[i]);
				}
			}
			let el = document.getElementsByClassName('cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing');
			if (el) {
				for (let i = 0; i < el.length; i++) {
					el[i].parentElement.removeChild(el[i]);
				}
			}
			/** Added by Sonalisa as Incident fix INC000097426025 **/
			let d1 = document.getElementsByClassName('cdk-overlay-pane');
			if (d1) {
				for (let i = 0; i < d1.length; i++) {
					d1[i].parentElement.removeChild(d1[i]);
				}
			}
		} catch (err) {
			console.log(err);
		}
	}
}