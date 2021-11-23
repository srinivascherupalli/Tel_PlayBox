/******************************************************************************************
Author	   : Shubhi
Change Version History
Version No	    Author 		Date           Story
    1.         Shubhi  		23-06-2020     Edge-149830 Redemption on device and devicecare
    2.         shubhi		14-07-2020     EDGE-162773 redemptions on device
	3.         Arinjay      21-07-2020     EDGE-164211 JSUpgrade
    4.         Aditya		21-07-2020	Edge:142084, Enable New Solution in MAC Basket
5.         shubhi		13-08-2020		EDGE-169593 js ugrade issue fixes
 6.       Shubhi /samish        28-july-2020    20.12          //EDGE-165013
 7.       sunil/manish          09/09/2020     20.12 EDGE-164351
******************************************************************************************/
var changeTypeExcludedList = ['Active', 'PaidOut', 'Pending'];
var componentnames_redemption = ['Corporate Mobile Plus', 'Telstra Collaboration', 'Device Outright Purchase', 'Next Generation Enterprise Mobility']
var basketStageslist = ['Draft', 'Quote', 'Commercial Configuration', 'Contract Initiated'];
var redemption_componentNameMap = new Map([
	['Corporate Mobile Plus', ['Mobile Subscription']],
	['Telstra Collaboration', ['Devices', 'Accessories']],
	["Connected Workplace", ['CWP Mobile Subscription']],
	["Device Outright Purchase", ['Mobile Device']],
	['Adaptive Mobility', ['Device']] //EDGE-165013
]);
var redemption_isChildApplicable = new Map([
	['Mobile Subscription', true],
	['Devices', false],
	['Accessories', false],
	['Device Outright Purchase', false],
	['Device', true]
]);
var redemption_changeTypeChild = new Map([
	['Mobile Subscription', 'ChangeTypeDevice'],
	['Device', 'ChangeType_Child']
]);
var redemption_childcomponentMap = new Map([
	['Corporate Mobile Plus', ['Device']],
	["Adaptive Mobility", ['Mobile Device Care']] //EDGE-165013
]);
window.totalRedemptions = 0;
window.currentFundBalance =0;
RedemptionUtilityCommon = {
	/**************************************************************************************
     * Author	   : Vishal Arbune
     * Method Name : displayCurrentFundBalanceAmt
     * Invoked When: On loading of Solution
     * Description : Fetch the Fund Balance From CIDN level
     **************************************************************************************/
	// Arinjay JSUpgrade
	claculateCurrentFundBalanceAmt: async function () {
    	let currentBasket=await CS.SM.getActiveBasket();
		await CS.SM.getBasketName().then(cart => { //EDGE-169593
        let inputMap = {};
    	inputMap['GetBasket'] = cart;
		currentBasket.performRemoteAction('FundBalanceAmountHelper', inputMap).then(result => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);
        		//console.log('currentFundBalance---------',currentFundBalance);
			return Promise.resolve(true);
		});
            return Promise.resolve(true);
    	}); 
                       		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : checkOnefundBalance
	 * Invoked When: On Clicking of checkonefund button
	 * Description : Calculates the dynamic balance this is generic new method
	 * Parameters  : configuration guid or left empty, if doing for all configs
	 **************************************************************************************/
	checkOnefundBalance: async function () {
		var showbalance = 0.00;
		var totalRedemption = 0.00;
		let inputMap = {};
		/*await CS.SM.getBasketName().then(cart => {
			inputMap['GetBasket'] = cart;	
			CS.SM.WebService.performRemoteAction('FundBalanceAmountHelper', inputMap).then(result => {
				window.currentFundBalance = JSON.parse(result["GetBasket"]);
			});
		 });*/
		/*await CS.SM.WebService.performRemoteAction('BasketRedemptionHelper', inputMap).then(result => {
				window.basket = JSON.parse(result["GetBasket"]);
				window.basketlevelRedemption=JSON.parse(result["GetBasket"]);
		});*/
		if (basketStageslist.includes(CS.SM.basketStageValue)|| basketStageslist.includes(basketStage)) {//Edge-149830
			await RedemptionUtilityCommon.calculateBasketRedemption();
			showbalance = parseFloat(window.currentFundBalance) - parseFloat(window.totalRedemptions);
			if (showbalance >= 0) {
				CS.SM.displayMessage('Available OneFund Balance ' + showbalance, 'success');
			}
			else {
				CS.SM.displayMessage('There is an Error in the Configuration or other Solution Configuration.', 'error');
			}
		}
		else {
			CS.SM.displayMessage('Available OneFund Balance ' + currentFundBalance, 'success');
		}
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : calculateBasketRedemption
	 * Invoked When: from validatebasketLevelRedemptions
	 * Description : Fetching the basket Redemption Amount from all the configurations
	 **************************************************************************************/
	// Arinjay JSUpgrade
	calculateBasketRedemption: async function () {
		var totalRedemption = 0;
		//CS.SM.getSolutions().then((solutions) => {
		let currentBasket = await CS.SM.getActiveBasket(); 
		let solutions = await currentBasket.getSolutions()
		if (solutions && Object.values(solutions).length > 0) {
			for (var product of Object.values(solutions)) {
				if (product && componentnames_redemption.includes(product.name) && product.components && Object.values(product.components).length > 0) {
					var componentNameList = redemption_componentNameMap.get(product.name);
					var totalfundRedeemed = 0;
					for (var comp of Object.values(product.components)) {
						if (componentNameList.includes(comp.name)) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								for (var subsConfig of Object.values(comp.schema.configurations)) {
									var ChangeType_Parent = ChangeType_Parent = Object.values(subsConfig.attributes).filter(att => { return att.name === 'ChangeType' });
									var changeType = '';
									if (ChangeType_Parent && ChangeType_Parent[0] && ChangeType_Parent[0].value) {
										changeType = ChangeType_Parent[0].value;
									} else {
										changeType = 'New';
									}
									if (!changeTypeExcludedList.includes(changeType) && !subsConfig.disabled) {
										//if(!subsConfig.id || subsConfig.id==='' || subsConfig.id===null){  
										if(comp.name!=='Mobile Subscription'){
										let fundRedeemed = 0;
										let RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund" });
										if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "" && RedeemFund[0].displayValue >= 0) {
											fundRedeemed = fundRedeemed + parseFloat(RedeemFund[0].displayValue);
											fundRedeemed = Math.round(fundRedeemed * 100) / 100;
											totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
										}
										}
										//}
										var isChildApplicable = redemption_isChildApplicable.get(comp.name);
										if (isChildApplicable === true && subsConfig && subsConfig.relatedProductList.length > 0) {
											for (var ReletedConfig of subsConfig.relatedProductList) {
												var changeTypeName = redemption_changeTypeChild.get(comp.name);
												var ChangeType_child = Object.values(ReletedConfig.configuration.attributes).filter(att => { return att.name === changeTypeName });
												var changeType = '';
												if (ChangeType_child && ChangeType_child[0] && ChangeType_child[0].value) {
													changeType = ChangeType_child[0].value;
												} else {
													changeType = 'New';
												}
												if (!changeTypeExcludedList.includes(changeType)) {
													//if(!ReletedConfig.id || ReletedConfig.id==='' || ReletedConfig.id===null){
													let fundRedeemed = 0;
													let RedeemFund = Object.values(ReletedConfig.configuration.attributes).filter(att => { return att.name === "RedeemFund" });
													if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "" && RedeemFund[0].displayValue >= 0) {
														fundRedeemed = fundRedeemed + parseFloat(RedeemFund[0].displayValue);
														fundRedeemed = Math.round(fundRedeemed * 100) / 100;
														totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
													}
													//}
												}
											}
										}
									}
								}
							}
						}
					}
					window.totalRedemptions = parseFloat(totalRedemption);
				}
			}
		}
		//});
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : TotalFundBalanceUpdate
	 * Invoked When: on attribute update (redeem fund)
	 * Description : validate the entered redeem fund
	 * Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	// Arinjay JSUpgrade
	updateTotalOneFundBalance: async function (guid, compName) {
		let inputMap = {};
		let currentBasket = await CS.SM.getActiveBasket();
		await CS.SM.getBasketName().then(cart => {
            inputMap['GetBasket'] = cart;
		currentBasket.performRemoteAction('FundBalanceAmountHelper', inputMap).then(result => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);
			});
		});
		let updateConfigMap = {};
		updateConfigMap[guid] = [];
		updateConfigMap[guid] = [
			{ 
				name: 'TotalFundAvailable', 
				//value: { 
					value: currentFundBalance, 
					displayValue: currentFundBalance 
				//} 
			},
			{ 
				name: 'RedeemFund', 
				//value: { 
					value: 0, 
					displayValue: 0 
				//} 
			}
		];
		//CS.SM.updateConfigurationAttribute(compName, updateConfigMap, true);
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(compName); 
		let keys = Object.keys(updateConfigMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
		}
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : TotalFundBalanceUpdate
	 * Invoked When: on attribute update (redeem fund)
	 * Description : validate the entered redeem fund
	 * Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	// Arinjay JSUpgrade
	updateRedeemCheckNeededFlag: async function (guid, compName, redeemfundAmt) {
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(compName); 
		let updateConfigMap = {};
		updateConfigMap[guid] = [];
		let isUpdated = false
		if (redeemfundAmt === 0 || redeemfundAmt === '0') {
			updateConfigMap[guid] = [{
				name: 'IsRedeemFundCheckNeeded', 
				// value: { 
					value: false, 
					displayValue: false 
				// }
			}];
			//CS.SM.updateConfigurationStatus(compName, guid, true);
			let cnfg = await component.getConfiguration(guid); 
			cnfg.status = true;
			isUpdated = true;
		} else if (redeemfundAmt > 0) {
			updateConfigMap[guid] = [{
				name: 'IsRedeemFundCheckNeeded', 
				// value: { 
					value: true, 
					displayValue: true 
				// }
			}];
			isUpdated = true;
		} else if (redeemfundAmt < 0) {
			//CS.SM.updateConfigurationStatus(compName, guid, false, 'Please Put the Valid Amount');
			let cnfg = await component.getConfiguration(guid); 
			cnfg.status = false;
			cnfg.statusMessage = 'Please Put the Valid Amount';
		}
		if (isUpdated === true) {
			//CS.SM.updateConfigurationAttribute(compName, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
	},
	/**************************************************************************************
	* Author	   : Shubhi Vijayvergia
	* Method Name : validateBasketRedemptionsGeneric
	* Invoked When: on attribute update (redeem fund)
	* Description : validate the entered redeem fund
	* Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	// Arinjay JSUPgrade
	validateBasketRedemptions: async function (isChildApplicable, compName, childCompName) {
        // Aditya: Edge:142084, Enable New Solution in MAC Basket
		if (window.BasketChange === 'Change Solution') {
			RedemptionUtilityCommon.validateBasketRedemptions_Macd(isChildApplicable, compName, childCompName);
		} else {
			let isRedeemFundInvalid = false;
			let updateConfigMap = {};
			let basketRedemp = 0;
			let inputMap = {};
			let currentFundBalance=window.currentFundBalance;
			let product = await CS.SM.getActiveSolution();
			//await CS.SM.getActiveSolution().then((product) => {
			if (product && product.components && Object.values(product.components).length > 0) {
				for (var comp of Object.values(product.components)) {
					if (comp && compName == comp.name && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (var subsConfig of Object.values(comp.schema.configurations)) {
							var totalFundRedeemed = 0;
							var mobSubsConfigGUID = "";
							if (subsConfig && isChildApplicable === true && subsConfig.relatedProductList.length > 0) {
								for (var Reletedconfig of subsConfig.relatedProductList) {
									var childGuid;
									if (childCompName === Reletedconfig.name) {
										var fundRedeemed_child = 0, netPriceIncGST_child = 0, oneOff_child = 0, debitFundCheck_child = false, quant_child = 1, netPriceExcGST_child = 0, totalcharge_child = 0;
										childGuid = Reletedconfig.guid;
										var redeemcheckNeeded = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded" });
										var onceOffCharge = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "OC" });
										if (onceOffCharge.length > 0) {
											if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].value && onceOffCharge[0].value !== undefined && onceOffCharge[0].value !== "")
												oneOff_child = parseFloat(onceOffCharge[0].value).toFixed(2);
										}
										var quantity = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "Quantity" });
										if (quantity && quantity.length > 0 && quantity[0].value && quantity[0].value !== undefined && quantity[0].value !== "") {
											quant_child = Math.trunc(quantity[0].value);
										}
										var RedeemFund = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "RedeemFund" });
										if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund[0].displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											//totalFundRedeemed+=fundRedeemed_child;										
											var taxtreatment = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "taxTreatment" });
											if (taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											}
											else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											//let reletedConfigComp = await product.getComponentByName(Reletedconfig.name);
											let cnfg = await comp.getConfiguration(childGuid);
											if (fundRedeemed_child === 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,true); 
												cnfg.status = true;
											}
											if (fundRedeemed_child < 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'Please Put the Valid Amount');
												cnfg.status = false;
												cnfg.statusMessage = 'Please Put the Valid Amount';
												isRedeemFundInvalid = true;
											}
											else if (fundRedeemed_child < (totalcharge_child * quant_child)) {
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child >= 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
												cnfg.status = false;
												cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
												isRedeemFundInvalid = true;
											} else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if ((currentFundBalance - basketRedemp) < 0) {
													//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
													cnfg.status = false;
													cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													errorTobeDisplayed = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													isRedeemFundInvalid = true;
												}
												else if ((currentFundBalance - basketRedemp) >= 0) {
													if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === 'true')) {
														//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
														cnfg.status = false;
														cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														isRedeemFundInvalid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
														//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid, true);
														cnfg.status = true;
														//isRedeemFundInvalid=false;	
													}
												}
											}
										}
									}
								}
							}
							var fundRedeemed = 0, netPriceIncGST = 0, oneOff = 0, debitFundCheck = false, quant = 1, netPriceExcGST = 0, totalcharge = 0;
							mobSubsConfigGUID = subsConfig.guid;
							var errorTobeDisplayed = '';
							var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded" });
							var onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "OneOffCharge" });
							if (onceOffCharge.length > 0) {
								if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
									oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
							} else {
								onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "OC" });
								if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
									oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
							}
							var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity" });
							if (quantity && quantity.length > 0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
								quant = Math.trunc(quantity[0].displayValue);
							var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund" });
							if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "") {
								fundRedeemed = parseFloat(RedeemFund[0].displayValue);
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								totalFundRedeemed += fundRedeemed;
							}
							var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment" });
							if (taxtreatment && taxtreatment[0] &&  taxtreatment[0].displayValue && taxtreatment[0].displayValue === "GST Applicable") {
								totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
							}
							else  {
								totalcharge = parseFloat(oneOff * 1).toFixed(2);
							}
							let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
							if (fundRedeemed < 0) {
								//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
								cnfg.status = false;
								cnfg.statusMessage = 'Please Put the Valid Amount';
								isRedeemFundInvalid = true;
							}
							else if (fundRedeemed >= 0 && fundRedeemed > (totalcharge * quant)) {
								//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
								cnfg.status = false;
								cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
								isRedeemFundInvalid = true;
							} else if (fundRedeemed == 0) {
								if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false'))
									cnfg.status = true;
								//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, true);
							}
							else if (window.totalRedemptions >= 0) {
								basketRedemp = window.totalRedemptions;
								var remainingAmt = currentFundBalance - basketRedemp;
								if (remainingAmt < 0) {
									//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
									cnfg.status = false;
									cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
									errorTobeDisplayed = 'You can not redeem amount greater than Charge amount and OneFund Balance';
									isRedeemFundInvalid = true;
								}
								else if ((currentFundBalance - basketRedemp) >= 0) {
									if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === 'true')) {
										if (fundRedeemed >= 0) {
											//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
											cnfg.status = false;
											cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
											isRedeemFundInvalid = true;
										}
									} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
										//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, true);
										cnfg.status = true;
										//isRedeemFundInvalid=false;	
									}
								}
							}
						}
					}
				}
			}
			//});
			return isRedeemFundInvalid;
		}
		//return isRedeemFundInvalid;
	},
	/**************************************************************************************
	* Author	   : Shubhi Vijayvergia
	* Method Name : validateBasketRedemptionsGeneric
	* Invoked When: on attribute update (redeem fund)
	* Description : validate the entered redeem fund
	* Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	// Arinjay JSUpgrade
	validateBasketRedemptions_Macd: async function (isChildApplicable, compName, childCompName) {
		let isRedeemFundInvalid = false;
		let updateConfigMap = {};
		let basketRedemp = 0;
		let inputMap = {};
		let product = await CS.SM.getActiveSolution();
		//await CS.SM.getActiveSolution().then((product) => {
		if (product && product.components && Object.values(product.components).length > 0) {
			for (var comp of Object.values(product.components)) {
				if (comp && compName == comp.name && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (var subsConfig of Object.values(comp.schema.configurations)) {
						var totalFundRedeemed = 0;
						var mobSubsConfigGUID = "";
						if (subsConfig && isChildApplicable === true && subsConfig.relatedProductList.length > 0) {
							for (var Reletedconfig of subsConfig.relatedProductList) {
								var childGuid;
								if (childCompName === Reletedconfig.name) {
									var fundRedeemed_child = 0, netPriceIncGST_child = 0, oneOff_child = 0, debitFundCheck_child = false, quant_child = 1, netPriceExcGST_child = 0, totalcharge_child = 0;
									childGuid = Reletedconfig.guid;
									var changeTypeName = redemption_changeTypeChild.get(comp.name);
									var ChangeType_child = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === changeTypeName });
									var changeType = '';
									if (ChangeType_child && ChangeType_child[0] && ChangeType_child[0].value) {
										changeType = ChangeType_child[0].value;
									} else {
										changeType = 'New';
									}
									if (!changeTypeExcludedList.includes(changeType) && subsConfig.replacedConfigId && !subsConfig.disabled) {
										var redeemcheckNeeded = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded" });
										var onceOffCharge = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "EarlyTerminationCharge" });
										if (onceOffCharge.length > 0 && onceOffCharge[0] && onceOffCharge[0].value) {
											if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].value && onceOffCharge[0].value !== undefined && onceOffCharge[0].value !== "")
												oneOff_child = parseFloat(onceOffCharge[0].value).toFixed(2);
										} else {
											onceOffCharge = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "OC" });
											if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].value && onceOffCharge[0].value !== undefined && onceOffCharge[0].value !== "")
												oneOff_child = parseFloat(onceOffCharge[0].value).toFixed(2);
										}
										var quantity = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "Quantity" });
										if (quantity && quantity.length > 0 && quantity[0].value && quantity[0].value !== undefined && quantity[0].value !== "") {
											quant_child = Math.trunc(quantity[0].value);
										}
										var RedeemFund = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "RedeemFund" });
										if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund[0].displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											//totalFundRedeemed+=fundRedeemed_child;										
											var taxtreatment = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "taxTreatment" });
											if (taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											}
											else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											let reletedConfigComp = await product.getComponentByName(Reletedconfig.name);
											if (fundRedeemed_child === 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,true);
												let cnfg = await comp.getConfiguration(childGuid);
												cnfg.status = true;
											}
											if (fundRedeemed_child < 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'Please Put the Valid Amount');
												let cnfg = await reletedConfigComp.getConfiguration(childGuid);
												cnfg.status = false;
												cnfg.statusMessage = 'Please Put the Valid Amount';
												isRedeemFundInvalid = true;
											}
											else if (fundRedeemed_child < (totalcharge_child * quant_child)) {
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child > 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
												let cnfg = await comp.getConfiguration(childGuid);
												cnfg.status = false;
												cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
												isRedeemFundInvalid = true;
											} else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if ((currentFundBalance - basketRedemp) < 0) {
													//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													errorTobeDisplayed = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													isRedeemFundInvalid = true;
												}
												else if ((currentFundBalance - basketRedemp) >= 0) {
													if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === 'true')) {
														//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = false;
														cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														isRedeemFundInvalid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
														//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid, true);
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = true;
														//isRedeemFundInvalid=false;	
													}
												}
											}
										}
									}
								}
							}
						}
						var fundRedeemed = 0, netPriceIncGST = 0, oneOff = 0, debitFundCheck = false, quant = 1, netPriceExcGST = 0, totalcharge = 0;
						mobSubsConfigGUID = subsConfig.guid;
						var errorTobeDisplayed = '';
						var ChangeType_Parent = ChangeType_Parent = Object.values(subsConfig.attributes).filter(att => { return att.name === 'ChangeType' });
						var changeType = '';
						if (ChangeType_Parent && ChangeType_Parent[0] && ChangeType_Parent[0].value) {
							changeType = ChangeType_Parent[0].value;
						} else {
							changeType = 'New';
						}
                        //EDGE-169593 added object.values..in all the pplaces below for subsConfig.attributes
						if (!changeTypeExcludedList.includes(changeType)&& subsConfig.replacedConfigId && !subsConfig.disabled) {
							var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded" });
							var onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "EarlyTerminationCharge" });
							if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "") {
								oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
							} else {
								onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "OC" });////EDGE-162773
								if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].value && onceOffCharge[0].value !== undefined && onceOffCharge[0].value !== "")
									oneOff = parseFloat(onceOffCharge[0].value).toFixed(2);
							}
							var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity" });
							if (quantity && quantity.length > 0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
								quant = Math.trunc(quantity[0].displayValue);
							var RedeemFund =Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund" });
							if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "") {
								fundRedeemed = parseFloat(RedeemFund[0].displayValue);
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								totalFundRedeemed += fundRedeemed;
							}
							var taxtreatment =Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment" });
							if (taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue === "GST Applicable") {
								totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
							}
							else{
								totalcharge = parseFloat(oneOff * 1).toFixed(2);
                            }
							if (fundRedeemed < 0) {
								//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
								let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								cnfg.status = false;
								cnfg.statusMessage = 'Please Put the Valid Amount';
								isRedeemFundInvalid = true;
							}
							else if (fundRedeemed >= 0 && fundRedeemed > (totalcharge * quant)) {
								//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
								let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								cnfg.status = false;
								cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
								isRedeemFundInvalid = true;
							} else if (fundRedeemed == 0) {
								if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
									//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, true);CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, true);
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = true;
								}
							}
							else if (window.totalRedemptions >= 0) {
								basketRedemp = window.totalRedemptions;
								var remainingAmt = currentFundBalance - basketRedemp;
								if (remainingAmt < 0) {
									//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = false;
									cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
									errorTobeDisplayed = 'You can not redeem amount greater than Charge amount and OneFund Balance';
									isRedeemFundInvalid = true;
								}
								else if ((currentFundBalance - basketRedemp) >= 0) {
									if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === 'true')) {
										if (fundRedeemed >= 0) {
											//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
											let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
											cnfg.status = false;
											cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
											isRedeemFundInvalid = true;
										}
									} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
										//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID, true);
										let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
										cnfg.status = true;
										//isRedeemFundInvalid=false;	
									}
								}
							}
						}
					}
				}
			}
		}
		//});
		return isRedeemFundInvalid;
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : updateRedeemFundonAddtoMac
	 * Invoked When: onaddToMac(redeem fund)
	 * Description : in MAC basket setting redeemFunds to 0
	 * Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	// Arinjay JSUpgrade
	updateRedeemFundonAddtoMac: async function (compName, configuration) {
		let updateConfigMap = {};
		let inputMap = {};
		let isUpdated = false;
		//await CS.SM.getBasketName().then(cart => {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		inputMap['GetBasket'] = currentBasket.basketId;
		currentBasket.performRemoteAction('FundBalanceAmountHelper', inputMap).then(result => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);
		});
		//});
		//CS.SM.getActiveSolution().then((product) => {

			//EDGE-164351 start( to copy value of redeemfund to redeemfundcopy during MAC)
			//////////////////////////////////////
				let loadedSolution = await CS.SM.getActiveSolution();
				let cmpName=loadedSolution.getComponentByName('Device');
				if(cmpName.schema && cmpName.schema.configurations && Object.values(cmpName.schema.configurations).length > 0) {
					Object.values(cmpName.schema.configurations).forEach(async (config) => {
						let repConfigId=config.replacedConfigId; 
						let relProdguid;
						let RedeemFund;
						if(repConfigId){
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									relProdguid=relatedConfig.guid;
									let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
									RedeemFund= relatedProductAttr.filter(obj => {
										return obj.name === 'RedeemFund'
											});
								});
							}	
							if(RedeemFund && RedeemFund[0] ){
								var  NGEMdev = [];
								NGEMdev[relProdguid] = [];
								NGEMdev[relProdguid] = [{
									name: 'RedeemFundCopy',
										value: RedeemFund[0].displayValue,
											displayValue:RedeemFund[0].displayValue,
												readOnly: false,

													showInUi:false
														}];
								let keys = Object.keys(NGEMdev);
								for (let i = 0; i < keys.length; i++) {
									cmpName.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
								}
							}		
						}
					});
				}
			/////////////////////////////////////////////
	        //EDGE-164351 end
		if (configuration) {
			if (configuration.guid && configuration.replacedConfigId) {
				updateConfigMap[configuration.guid] = [];
				updateConfigMap[configuration.guid] = [
					{ 
						name: 'TotalFundAvailable', 
						// value: { 
							value: currentFundBalance, 
							displayValue: currentFundBalance 
						// } 
					},
					{ 
						name: 'RedeemFund', 
						// value: { 
							value: 0, 
							displayValue: 0 
						// } 
					}
				];
				isUpdated = true;
				if (configuration.relatedProductList.length >= 0) {
					for (var ReletedConfig of configuration.relatedProductList) {
						if (ReletedConfig.guid && ReletedConfig.ReletedConfig) {
							updateConfigMap[ReletedConfig.guid] = [
								{ 
									name: 'TotalFundAvailable', 
									// value: { 
										value: currentFundBalance, 
										displayValue: currentFundBalance 
									// } 
								},
								{ 
									name: 'RedeemFund', 
									// value: { 
										value: 0, 
										displayValue: 0 
									// } 
								}
							];
						}
					}
				}
			}
		}
		//});
		if (isUpdated === true) {
			//CS.SM.updateConfigurationAttribute(compName, updateConfigMap, true);
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(compName); 
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
	},
	/**************************************************************************************
	* Author	   : Shubhi Vijayvergia
	* Method Name : validateBasketRedemptionsForEm
	* Invoked When: on attribute update (redeem fund)
	* Description : validate the entered redeem fund
	* Parameters  : isChildApplicable,compName,childCompName
	**************************************************************************************/
	validateBasketRedemptionsForEm: async function (compName, childCompName) {
			let isRedeemFundInvalid = false;
		let updateConfigMap = {};
		let basketRedemp = 0;
		let inputMap = {};
		let product = await CS.SM.getActiveSolution();
		//await CS.SM.getActiveSolution().then((product) => {
		if (product && product.components && Object.values(product.components).length > 0) {
			for (var comp of Object.values(product.components)) {
				if (comp && compName == comp.name && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (var subsConfig of Object.values(comp.schema.configurations)) {
						var totalFundRedeemed = 0;
						var mobSubsConfigGUID = "";
						if (subsConfig && subsConfig.relatedProductList.length > 0) {
							for (var Reletedconfig of subsConfig.relatedProductList) {
								var childGuid;
								if (childCompName === Reletedconfig.name) {
									var fundRedeemed_child = 0, netPriceIncGST_child = 0, oneOff_child = 0, debitFundCheck_child = false, quant_child = 1, netPriceExcGST_child = 0, totalcharge_child = 0;
									childGuid = Reletedconfig.guid;
									var changeTypeName = redemption_changeTypeChild.get(comp.name);
									var ChangeType_child = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === changeTypeName });
									var changeType = '';
									if (ChangeType_child && ChangeType_child[0] && ChangeType_child[0].value) {
										changeType = ChangeType_child[0].value;
									} else {
										changeType = 'New';
									}
                                    //var changeTypeName = redemption_changeTypeChild.get(comp.name);
									var ChangeTypeparent = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === 'ChangeType' });
									var changeTypeP = '';
									if (ChangeTypeparent && ChangeTypeparent[0] && ChangeTypeparent[0].value) {
										changeTypeP = ChangeType_child[0].value;
									} else {
										changeTypeP = 'New';
									}
									if (!changeTypeExcludedList.includes(changeType)) {
										var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded" });
										var onceOffCharge;
										if(changeTypeP==='PayOut'){
											onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "EarlyTerminationCharge" });
										}else{
											onceOffCharge = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "EarlyTerminationCharge" });
										}
										if (onceOffCharge.length > 0 && onceOffCharge[0] && onceOffCharge[0].value) {
											if (onceOffCharge && onceOffCharge.length > 0 && onceOffCharge[0].value && onceOffCharge[0].value !== undefined && onceOffCharge[0].value !== "")
												oneOff_child = parseFloat(onceOffCharge[0].value).toFixed(2);
										} 
										var quantity = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "Quantity" });
										if (quantity && quantity.length > 0 && quantity[0].value && quantity[0].value !== undefined && quantity[0].value !== "") {
											quant_child = Math.trunc(quantity[0].value);
										}
										var RedeemFund = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "RedeemFund" });
										if (RedeemFund && RedeemFund.length > 0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund[0].displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											//totalFundRedeemed+=fundRedeemed_child;										
											var taxtreatment = Object.values(Reletedconfig.configuration.attributes).filter(att => { return att.name === "taxTreatment" });
											if (taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											}
											else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											let reletedConfigComp = await product.getComponentByName(Reletedconfig.name);
											if (fundRedeemed_child === 0) {
												//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid,true);
												if(changeType==='Cancel'){
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = true;
												}
												else{
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = true;
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = true;
												}
											}
											if (fundRedeemed_child < 0) {
												isRedeemFundInvalid = true;
												if(changeType==='Cancel'){
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = 'Please Put the Valid Amount';
												}
												else{
													let cnfg = await reletedConfigComp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = 'Please Put the Valid Amount';
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = 'Please Put the Valid Amount';
												}
											}
											else if (fundRedeemed_child < (totalcharge_child * quant_child)) {
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child > 0) {
												if(changeTypeP==='Cancel'){
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
												}
												else{
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
												}
												isRedeemFundInvalid = true;
											}else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if ((currentFundBalance - basketRedemp) < 0) {
													if(changeTypeP==='Cancel'){
														let cnfgP = await comp.getConfiguration(subsConfig.guid);
														cnfgP.status = false;
														cnfgP.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
													}
													else{
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = false;
														cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
														let cnfgP = await comp.getConfiguration(subsConfig.guid);
														cnfgP.status = false;
													}
													isRedeemFundInvalid = true;
												}
												else if ((currentFundBalance - basketRedemp) >= 0) {
													if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === 'true')) {
														if(changeTypeP==='Cancel'){
															let cnfgP = await comp.getConfiguration(subsConfig.guid);
															cnfgP.status = false;
															cnfgP.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														}else{
															let cnfg = await comp.getConfiguration(childGuid);
															cnfg.status = false;
															cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
															let cnfgP = await comp.getConfiguration(subsConfig.guid);
															cnfgP.status = false;
															cnfgP.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														}
														isRedeemFundInvalid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === 'false')) {
														//CS.SM.updateConfigurationStatus(Reletedconfig.name,childGuid, true);
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = true;
														//isRedeemFundInvalid=false;	
													}
												}
											}
										}
									}
								}
							}						
						}
					}
				}
			}
		}
		//});
		return isRedeemFundInvalid;
	},
	/**************************************************************************************
     * Author	   : Shubhi Vijay
     * Method Name : populateNullValues
     * Invoked When: On Cloning of Solution
     * Description : Sets Redemption Values to Null
     * Parameters  : configuration guid or left empty if doing for all configs
     * Updated:    : Updated by Aditya for Edge-144971(Value and Display Value)
     * *   * Updated:    : Updated by Shubhi for Edge-144971(Value and Display Value)
     **************************************************************************************/
    populateNullValuesforClonedPC: async function(componentName,configurations) 
    {
        let updateConfigMap = {};
		for(var configuration of configurations){
			var mobSubsConfigGUID = "";
			mobSubsConfigGUID = configuration.guid;				
			if(mobSubsConfigGUID !==""){
				updateConfigMap[mobSubsConfigGUID] = [
				{
					name: 'TotalFundAvailable',
						value: currentFundBalance,
						displayValue: currentFundBalance
				},{
					name: 'RedeemFund',
					value: 0.00,
					displayValue: 0.00
				},{
					name: "IsRedeemFundCheckNeeded",
					value: false,
					displayValue: false
				},{
					name: 'CheckOneFund',
					value: false,
					displayValue: false
				}];
				config.status=true;
				let product = await CS.SM.getActiveSolution();
				let component = await product.getComponentByName(componentName); 
				let keys = Object.keys(updateConfigMap);
				var complock = component.commercialLock;//added by shubhi for EDGE-169593
				if(complock) component.lock('Commercial', false);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
				}
				if(complock) component.lock('Commercial', true);//added by shubhi for EDGE-169593
			}
			return Promise.resolve(true);
		}
	}
}