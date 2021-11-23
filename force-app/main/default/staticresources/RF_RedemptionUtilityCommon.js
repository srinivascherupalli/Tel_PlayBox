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
	8.         Gunjan Aswani  23-09-2020      20.12           JS Refactoring
    9         Shubhi Vijayvergia 12/10/2020   20.13     EDGE-183264
	10        Aarathi Iyer 12/10/2020   20.13     EDGE-183264 - changed the change type of device care

	11.       Pallavi D     15.10.20202           EDGE-184554     

	12 		  Vijay Kumar H R 28-10-2020		  EDGE-169456 - Removed the Configuration message to click on generate net price
    13.       Pooja Gupta      11-11-2020         EDGE-189556 - Error validation missing on giving redeem amount greater than charge amount in MACD basket
    14.     Pooja Bhat/Gokul    06-11-2020      20.15: EDGE-175750	
    15.     Mahima Gandhe       12-2020				20.17- DPG-3509
	16.     Shubhi V       		1-02-2021			EDGE-193068 (sprint 20.02)
    17.		Vishal Arbune       01-02-2021          EDGE-198208 : Add ex. GST label with OneFund Balance in Product Basket and OneFund Balance at Account 

	18.    Mahima Gandhe       02-2021				21.02- DPG-4154
	19.     shubhi V		12-02-2021			EDGE-204091
	20.    Rajesh Bommadevara 19-02-2021        EDGE-205237
	21.    Pawan Singh			11-08-2021		DIGI-5648	replacing Telstra collaboration to Adaptive collaboration
******************************************************************************************/
var NGUC_OFFER_NAME = 'Adaptive Collaboration';  //DIGI-5648
var changeTypeExcludedList = ["Active", "PaidOut", "Pending","Inflight Cancel" ,"Rollback New","Inflight Amend"]; //EDGE-193068
var changeTypeInflightExclusion = ["Inflight Cancel","Rollback New"]; //EDGE-193068
// var componentnames_redemption = ["Corporate Mobile Plus", "Telstra Collaboration", "Device Outright Purchase", "Adaptive Mobility"];    DIGI-5648
var componentnames_redemption = ["Corporate Mobile Plus", NGUC_OFFER_NAME, "Device Outright Purchase", "Adaptive Mobility"];
var basketStageslist = ["Draft", "Quote", "Commercial Configuration", "Contract Initiated"];
var redemption_componentNameMap = new Map([
	["Corporate Mobile Plus", ["Mobile Subscription"]],
	// ["Telstra Collaboration", ["Devices", "Accessories"]],    DIGI-5648
	[NGUC_OFFER_NAME, ["Devices", "Accessories"]],
	["Connected Workplace", ["CWP Mobile Subscription"]],
	["Device Outright Purchase", ["Mobile Device"]],
	["Adaptive Mobility", ["Device","Accessory"]] // DPG-3509
]);
var redemption_isChildApplicable = new Map([
	["Mobile Subscription", true],
	["Devices", false],
	["Accessories", false],
	["Device Outright Purchase", false],
	["Device", true],

     ["Accessory",true]// DPG-3509// DPG-4154 added true

]);
var redemption_changeTypeChild = new Map([
	["Mobile Subscription", "ChangeTypeDevice"],
	["Device", "ChangeType"],//EDGE-183264
    ["Accessory","ChangeType"]// DPG-4154
    
]);
var redemption_childcomponentMap = new Map([
	["Corporate Mobile Plus", ["Device"]],
	["Adaptive Mobility", ["Mobile Device Care"]]
]);
window.totalRedemptions = 0;
window.currentFundBalance = 0;
window.isTotalRedemptionInValid=false; //EDGE-193068
RedemptionUtilityCommon = {
	/**************************************************************************************
	 * Author	   : Vishal Arbune
	 * Method Name : displayCurrentFundBalanceAmt
	 * Invoked When: On loading of Solution
	 * Description : Fetch the Fund Balance From CIDN level
	 **************************************************************************************/
	// Arinjay JSUpgrade
	calculateCurrentFundBalanceAmt: async function (basketId, currentBasket) {
		let inputMap = {};
		inputMap["GetBasket"] = basketId; // PD check name/ basketName
		await currentBasket.performRemoteAction("FundBalanceAmountHelper", inputMap).then((result) => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);//EDGE-204091
		});
		
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : checkOnefundBalance
	 * Invoked When: On Clicking of checkonefund button
	 * Description : Calculates the dynamic balance this is generic new method
	 * Parameters  : configuration guid or left empty, if doing for all configs
	 **************************************************************************************/
	checkOnefundBalance: async function () {
		let showbalance = 0.0;
		if (basketStageslist.includes(CS.SM.basketStageValue) || basketStageslist.includes(basketStage)) {
			//Edge-149830
			let currentBasket = await CS.SM.getActiveBasket(); 
			let solutions = await currentBasket.getSolutions();
			await RedemptionUtilityCommon.calculateBasketRedemption(solutions);
			showbalance = parseFloat(window.currentFundBalance) - parseFloat(window.totalRedemptions);
			if (showbalance >= 0) {
            	//EDGE-198208
				CS.SM.displayMessage("Available TEP Fund (ex. GST) " + showbalance, "success");
			} else {
				CS.SM.displayMessage("There is an Error in the Configuration or other Solution Configuration.", "error");//EDGE-205237
			}
		} else {
            //EDGE-198208
			CS.SM.displayMessage("Available TEP Fund (ex. GST) " + currentFundBalance, "success");//EDGE-205237
		}
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : calculateBasketRedemption
	 * Invoked When: from validatebasketLevelRedemptions
	 * Description : Fetching the basket Redemption Amount from all the configurations
	 **************************************************************************************/
	// Arinjay JSUpgrade // Added By Shweta EDGE-190170: removed parameter 
	calculateBasketRedemption: async function () {
		let totalRedemption = 0;
        let currentBasket = await CS.SM.getActiveBasket(); // Added By Shweta EDGE-190170
		let solutions = await currentBasket.getSolutions(); // Added By Shweta EDGE-190170
		if (solutions && Object.values(solutions).length > 0) {
			for (let product of Object.values(solutions)) {
				if (product && componentnames_redemption.includes(product.name) && product.components && Object.values(product.components).length > 0) {
					let componentNameList = redemption_componentNameMap.get(product.name);
					for (let comp of Object.values(product.components)) {
						let cmpConfig = await comp.getConfigurations();
						if (componentNameList.includes(comp.name)) {
							if (cmpConfig && Object.values(cmpConfig).length > 0) {
								for (let subsConfig of Object.values(cmpConfig)) {
									let ChangeType_Parent = subsConfig.getAttribute("ChangeType");
									let changeType = "";
									if (ChangeType_Parent && ChangeType_Parent && ChangeType_Parent.value) {
										changeType = ChangeType_Parent.value;
									} else {
										changeType = "New";
									}
									if (!changeTypeExcludedList.includes(changeType) && !subsConfig.disabled) {
										if (comp.name !== "Mobile Subscription") {
											let fundRedeemed = 0;
											let RedeemFund = subsConfig.getAttribute("RedeemFund");
											if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "" && RedeemFund.displayValue >= 0) {
												fundRedeemed = fundRedeemed + parseFloat(RedeemFund.displayValue);
												fundRedeemed = Math.round(fundRedeemed * 100) / 100;
												totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
											}
										}
										let isChildApplicable = redemption_isChildApplicable.get(comp.name);
										if (isChildApplicable === true && subsConfig && subsConfig.relatedProductList.length > 0) {
											for (let ReletedConfig of subsConfig.relatedProductList) {
												let changeTypeName = redemption_changeTypeChild.get(comp.name);
												let ChangeType_child = ReletedConfig.configuration.getAttribute(changeTypeName);
												let changeType = "";
												if (ChangeType_child && ChangeType_child && ChangeType_child.value) {
													changeType = ChangeType_child.value;
												} else {
													changeType = "New";
												}
												if (!changeTypeExcludedList.includes(changeType)) {
													let fundRedeemed = 0;
													let RedeemFund = ReletedConfig.configuration.getAttribute("RedeemFund");
													if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "" && RedeemFund.displayValue >= 0) {
														fundRedeemed = fundRedeemed + parseFloat(RedeemFund.displayValue);
														fundRedeemed = Math.round(fundRedeemed * 100) / 100;
														totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
													}
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

		inputMap["GetBasket"] = window.basketNum;

		currentBasket.performRemoteAction("FundBalanceAmountHelper", inputMap).then((result) => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);
		});
		let updateConfigMap = {};
		updateConfigMap[guid] = [];
		updateConfigMap[guid] = [
		{
			name: "TotalFundAvailable",
			value: currentFundBalance,
			displayValue: currentFundBalance
		},
		{
			name: "RedeemFund",
			value: 0,
			displayValue: 0
		},
		{   //Added EDGE-175750
			name: "RedeemFundIncGST",
			value: 0,
			displayValue: 0
		}
		];
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
		let isUpdated = false;
		if (redeemfundAmt === 0 || redeemfundAmt === "0") {
			updateConfigMap[guid] = [
				{
					name: "IsRedeemFundCheckNeeded",
					value: false,
					displayValue: false
				}
			];
			let cnfg = await component.getConfiguration(guid);
			cnfg.status = true;
			isUpdated = true;
		} else if (redeemfundAmt > 0) {
			updateConfigMap[guid] = [
				{
					name: "IsRedeemFundCheckNeeded",
					value: true,
					displayValue: true
				},{
					name: "RedeemFundCopy", //Edge-197578
					value: redeemfundAmt,
					displayValue: redeemfundAmt
				}
			];
			isUpdated = true;
		} else if (redeemfundAmt < 0) {
			let cnfg = await component.getConfiguration(guid);
			cnfg.status = false;
			cnfg.statusMessage = "Please Put the Valid Amount";
		}
		if (isUpdated === true) {
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
		if (window.BasketChange === "Change Solution" || window.basketRecordType==='Inflight Change') {
			RedemptionUtilityCommon.validateBasketRedemptions_Macd(isChildApplicable, compName, childCompName);
		} else {
			let isRedeemFundInvalid = false;
			let basketRedemp = 0;
			let currentFundBalance = window.currentFundBalance;
			let product = await CS.SM.getActiveSolution();
			if (product && product.components && Object.values(product.components).length > 0) {
				for (let comp of Object.values(product.components)) {
					let compConfig = await comp.getConfigurations();
					if (compConfig && Object.values(compConfig).length > 0) {
						for (let subsConfig of Object.values(compConfig)) {
							let mobSubsConfigGUID = "";
							if (subsConfig && isChildApplicable === true && subsConfig.relatedProductList.length > 0) {
								for (let Reletedconfig of subsConfig.relatedProductList) {
									let childGuid;
									if (childCompName === Reletedconfig.name) {
										let fundRedeemed_child = 0,
											oneOff_child = 0,
											debitFundCheck_child = false,
											quant_child = 1,
											 totalcharge_child = 0;
										childGuid = Reletedconfig.guid;
										let redeemcheckNeeded = Reletedconfig.configuration.getAttribute("IsRedeemFundCheckNeeded");
										let onceOffCharge = Reletedconfig.configuration.getAttribute("OC");
										if (onceOffCharge) {
											if (onceOffCharge && onceOffCharge.value && onceOffCharge.value !== undefined && onceOffCharge.value !== "") oneOff_child = parseFloat(onceOffCharge.value).toFixed(2);
										}
										let quantity;
										try{
											quantity=Reletedconfig.configuration.getAttribute("Quantity");
										}catch(Exception){
										}
										if (quantity && quantity.value && quantity.value !== undefined && quantity.value !== "") {
											quant_child = Math.trunc(quantity[0].value);
										}
										let RedeemFund = Reletedconfig.configuration.getAttribute("RedeemFund");
										if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund.displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											let taxtreatment = Reletedconfig.configuration.getAttribute("taxTreatment");
                                            let skipTaxTreatment = true;	//EDGE-175750: Skipping taxTreatment check
                                            if (!skipTaxTreatment && taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											} else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											let cnfg = await comp.getConfiguration(childGuid);
											if (fundRedeemed_child === 0) {
												cnfg.status = true;
											}
											if (fundRedeemed_child < 0) {
												cnfg.status = false;
												cnfg.statusMessage = "Please Put the Valid Amount";
												window.isTotalRedemptionInValid = true;
												return Promise.resolve(true); //EDGE-204091
											} else if (fundRedeemed_child <= totalcharge_child * quant_child) {		//EDGE-175750: Changed condition form < to <=
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child >= 0) {
												cnfg.status = false;
												cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
												window.isTotalRedemptionInValid = true;
												return Promise.resolve(true);//EDGE-204091
											} else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if (currentFundBalance - basketRedemp < 0) {
													cnfg.status = false;
													cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													errorTobeDisplayed = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													window.isTotalRedemptionInValid = true;
													return Promise.resolve(true);//EDGE-204091
												} /*else if (currentFundBalance - basketRedemp >= 0) {  //EDGE-169456 - Removed the Configuration message to click on generate net price as part of Pricing Service Enablement
													if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === true || redeemcheckNeeded.value === "true")) {
														cnfg.status = false;
														cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														isRedeemFundInvalid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
														cnfg.status = true;
													}
												}*/
												else 
												{
													cnfg.statusMessage = '';
													cnfg.status = true;
												}//This code was removed by Pricing team so we have added this code to handle the issue. Added by Pooja EDGE-189556/EDGE-190170
											} else {	//Added else condition as part of EDGE-175750 changes
												cnfg.status = true;
												cnfg.statusMessage = '';
												window.isTotalRedemptionInValid = false;
											}
										}
									}
								}
							}
							let fundRedeemed = 0,
								oneOff = 0,
								 quant = 1,
								totalcharge = 0;
							mobSubsConfigGUID = subsConfig.guid;
							let redeemcheckNeeded = Object.values(subsConfig.attributes).find((att) => {
								return att.name === "IsRedeemFundCheckNeeded";
							});
							let onceOffCharge = Object.values(subsConfig.attributes).find((att) => {
								return att.name === "OneOffCharge";
							});
							if (onceOffCharge) {
								if ( onceOffCharge.displayValue && onceOffCharge.displayValue !== undefined && onceOffCharge.displayValue !== "") oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
							} else {
								onceOffCharge = Object.values(subsConfig.attributes).find((att) => {
									return att.name === "OC";
								});
								if (onceOffCharge && onceOffCharge.displayValue && onceOffCharge.displayValue !== undefined && onceOffCharge.displayValue !== "") oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
							}
							let quantity = Object.values(subsConfig.attributes).find((att) => {
								return att.name === "Quantity";
							});
							if (quantity && quantity.displayValue && quantity.displayValue !== undefined && quantity.displayValue !== "") quant = Math.trunc(quantity.displayValue);
							let RedeemFund = Object.values(subsConfig.attributes).find((att) => {
								return att.name === "RedeemFund";
							});
							if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "") {
								fundRedeemed = parseFloat(RedeemFund.displayValue);
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								//totalFundRedeemed += fundRedeemed;
							}
							let taxtreatment = Object.values(subsConfig.attributes).find((att) => {
								return att.name === "taxTreatment";
							});
                            let skipTaxTreatment = true;	//EDGE-175750: Skipping taxTreatment check
                            if (!skipTaxTreatment && taxtreatment && taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
								totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
							} else {
								totalcharge = parseFloat(oneOff * 1).toFixed(2);
							}
							let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
							if (fundRedeemed < 0) {
								cnfg.status = false;
								cnfg.statusMessage = "Please Put the Valid Amount";
								window.isTotalRedemptionInValid = true;
								return Promise.resolve(true);//EDGE-204091
							} else if (fundRedeemed >= 0 && fundRedeemed > totalcharge * quant) {
								cnfg.status = false;
								cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
								window.isTotalRedemptionInValid = true;
								return Promise.resolve(true);//EDGE-204091
							} else if (fundRedeemed == 0) {
								if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) 
								    cnfg.status = true;
							} else if (window.totalRedemptions >= 0) {
								basketRedemp = window.totalRedemptions;
								let remainingAmt = currentFundBalance - basketRedemp;
								if (remainingAmt < 0) {
									cnfg.status = false;
									cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
									errorTobeDisplayed = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
									window.isTotalRedemptionInValid = true;
									return Promise.resolve(true);//EDGE-204091
								} /*else if (currentFundBalance - basketRedemp >= 0) { //EDGE-169456 - Removed the Configuration message to click on generate net price as part of Pricing Service Enablement
									if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === true || redeemcheckNeeded.value === "true")) {
										if (fundRedeemed >= 0) {
											cnfg.status = false;
											cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
											isRedeemFundInvalid = true;
										}
									} else if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
										cnfg.status = true;
									}
								}*/
								else {
                                    cnfg.statusMessage = '';
                                    cnfg.status = true;
                                }//This code was removed by Pricing team so we have added this code to handle the issue. Added by Pooja EDGE-189556/EDGE-190170
							} else {	//Added else condition as part of EDGE-175750 changes
								cnfg.status = true;
								cnfg.statusMessage = '';
								window.isTotalRedemptionInValid = false;
							}
						}
					}
				}
			}
			//return isRedeemFundInvalid;
		}
		return Promise.resolve(false); 
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
		let basketRedemp = 0;
		let product = await CS.SM.getActiveSolution();
		if (product) {
			let components = product.getComponents();
			//for (let comp of Object.values(components)) {
				let comp = product.getComponentByName(compName);
				let compConfig = comp.getConfigurations();
				if (compConfig && Object.values(compConfig).length > 0) {
					for (let subsConfig of Object.values(compConfig)) {
						let mobSubsConfigGUID = "";
						if (subsConfig && isChildApplicable === true && subsConfig.relatedProductList.length > 0) {
							for (let Reletedconfig of subsConfig.relatedProductList) {
								let childGuid;
								if (childCompName === Reletedconfig.name) {
									let fundRedeemed_child = 0,
										oneOff_child = 0,
										debitFundCheck_child = false,
										quant_child = 1,
										totalcharge_child = 0;
									childGuid = Reletedconfig.guid;
									let changeTypeName = redemption_changeTypeChild.get(comp.name);
									let ChangeType_child;
									try{
										ChangeType_child= Reletedconfig.configuration.getAttribute(changeTypeName);
									}catch(e){
										console.log('error'+e);
									}
									let changeType = "";
									if (ChangeType_child && ChangeType_child && ChangeType_child.value) {
										changeType = ChangeType_child.value;
									} else {
										changeType = "New";
									}
									if (!changeTypeExcludedList.includes(changeType) /*&& subsConfig.replacedConfigId*/ && !subsConfig.disabled) {	//Commented by Shubhi EDGE-189556/EDGE-190170
										let redeemcheckNeeded = Reletedconfig.configuration.getAttribute("IsRedeemFundCheckNeeded");
										let onceOffCharge;// = Reletedconfig.configuration.getAttribute("EarlyTerminationCharge");//Commented by Shubhi EDGE-189556/EDGE-190170
										if (onceOffCharge && onceOffCharge.value) {
											if (onceOffCharge && onceOffCharge.value && onceOffCharge.value !== undefined && onceOffCharge.value !== "") oneOff_child = parseFloat(onceOffCharge.value).toFixed(2);
										} else {
											onceOffCharge = Reletedconfig.configuration.getAttribute("OC");
											if (onceOffCharge  && onceOffCharge.value && onceOffCharge.value !== undefined && onceOffCharge.value !== "") oneOff_child = parseFloat(onceOffCharge.value).toFixed(2);
										}
										try {
											let quantity = Reletedconfig.configuration.getAttribute("Quantity");
											if (quantity && quantity.value && quantity.value !== undefined && quantity.value !== "") {
												quant_child = Math.trunc(quantity.value);
											}
										}catch(Exception){
										}											
										RedeemFund = Reletedconfig.configuration.getAttribute("RedeemFund");
										if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund.displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											taxtreatment = Reletedconfig.configuration.getAttribute("taxTreatment");
                                            let skipTaxTreatment = true;	//EDGE-175750: Skipping taxTreatment check
                                            if (!skipTaxTreatment && taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											} else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											let reletedConfigComp = await product.getComponentByName(Reletedconfig.name);
											if (fundRedeemed_child === 0) {
												let cnfg = await comp.getConfiguration(childGuid);
												cnfg.status = true;
											}
											if (fundRedeemed_child < 0) {
												let cnfg = await reletedConfigComp.getConfiguration(childGuid);
												cnfg.status = false;
												cnfg.statusMessage = "Please Put the Valid Amount";
												window.isTotalRedemptionInValid = true;
												return Promise.resolve(true);//EDGE-204091
											} else if (fundRedeemed_child <= totalcharge_child * quant_child) {		//EDGE-175750: Changed condition form < to <=
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child > 0) {
												let cnfg = await comp.getConfiguration(childGuid);
												cnfg.status = false;
												cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
												window.isTotalRedemptionInValid = true;
												return Promise.resolve(true);//EDGE-204091
											} else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if (currentFundBalance - basketRedemp < 0) {
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													errorTobeDisplayed = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													window.isTotalRedemptionInValid = true;
													return Promise.resolve(true);//EDGE-204091
												} /*else if (currentFundBalance - basketRedemp >= 0) {  //EDGE-169456 - Removed the Configuration message to click on generate net price as part of Pricing Service Enablement
													if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === true || redeemcheckNeeded[0].value === "true")) {
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = false;
														cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														window.isTotalRedemptionInValid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value === "false")) {
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = true;
													}
												}*/
												else 
												{
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.statusMessage = '';
													cnfg.status = true;
												}//This code was removed by Pricing team so we have added this code to handle the issue. Added by Pooja EDGE-189556/EDGE-190170
											} else {	//Added else condition as part of EDGE-175750 changes
												let cnfg = await comp.getConfiguration(childGuid);
												cnfg.status = true;
												cnfg.statusMessage = '';
												window.isTotalRedemptionInValid = false;
											}
										}
									}
								}
							}
						}
						let fundRedeemed = 0,
							 oneOff = 0,
							 quant = 1,
							totalcharge = 0;
						mobSubsConfigGUID = subsConfig.guid;
						let ChangeType_Parent = subsConfig.getAttribute('ChangeType');
						let changeType = "";
						if (ChangeType_Parent && ChangeType_Parent.value) {
							changeType = ChangeType_Parent.value;
						} else {
							changeType = "New";
						}
						//EDGE-169593 added object.values..in all the pplaces below for subsConfig.attributes
						if (!changeTypeExcludedList.includes(changeType) /*&& subsConfig.replacedConfigId*/ && !subsConfig.disabled) {// Commented  by Shubhi EDGE-189556/EDGE-190170
							let redeemcheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
							let onceOffCharge = subsConfig.getAttribute("EarlyTerminationCharge");
							if (onceOffCharge  && onceOffCharge.displayValue && onceOffCharge.displayValue !== undefined && onceOffCharge.displayValue !== "") {
								oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
							} else {
								onceOffCharge = subsConfig.getAttribute("OC");
								if (onceOffCharge && onceOffCharge.value > 0 && onceOffCharge.value !== undefined && onceOffCharge.value !== "") oneOff = parseFloat(onceOffCharge.value).toFixed(2);
							}
							try {
								let quantity = Reletedconfig.configuration.getAttribute("Quantity");
								if (quantity && quantity.value && quantity.value !== undefined && quantity.value !== "") {
									quant_child = Math.trunc(quantity.value);
								}
							}catch(Exception){
							}
							let RedeemFund = subsConfig.getAttribute("RedeemFund");
							if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "") {
								fundRedeemed = parseFloat(RedeemFund.displayValue);
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								//totalFundRedeemed += fundRedeemed;
							}
							let taxtreatment = subsConfig.getAttribute("taxTreatment");// implemented the correct syntax  EDGE-189556/EDGE-190170
                            let skipTaxTreatment = true;	//EDGE-175750: Skipping taxTreatment check
                            if (!skipTaxTreatment && taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
								totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
							} else {
								totalcharge = parseFloat(oneOff * 1).toFixed(2);
							}
							if (fundRedeemed < 0) {
								let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								cnfg.status = false;
								cnfg.statusMessage = "Please Put the Valid Amount";
								window.isTotalRedemptionInValid = true;
								return Promise.resolve(true);//EDGE-204091
							} else if (fundRedeemed >= 0 && fundRedeemed > totalcharge * quant) {
								let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								cnfg.status = false;
								cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
								window.isTotalRedemptionInValid = true;
								return Promise.resolve(true);//EDGE-204091
							} else if (fundRedeemed == 0) {
								if (redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = true;
								}
							} else if (window.totalRedemptions >= 0) {
								basketRedemp = window.totalRedemptions;
								let remainingAmt = currentFundBalance - basketRedemp;
								if (remainingAmt < 0) {
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = false;
									cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
									errorTobeDisplayed = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
									window.isTotalRedemptionInValid = true;
									return Promise.resolve(true);
								} /*else if (currentFundBalance - basketRedemp >= 0) {   //EDGE-169456 - Removed the Configuration message to click on generate net price as part of Pricing Service Enablement
									if (redeemcheckNeeded && (redeemcheckNeeded.value === true || redeemcheckNeeded.value === "true")) {
										if (fundRedeemed >= 0) {
											let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
											cnfg.status = false;
											cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
											window.isTotalRedemptionInValid = true;
										}
									} else if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
										let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
										cnfg.status = true;
									}
								}*/
								else 
								{
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.statusMessage = '';
									cnfg.status = true;
								}//This code was removed by Pricing team so we have added this code to handle the issue. Added by Pooja EDGE-189556/EDGE-190170
							} else {	//Added else condition as part of EDGE-175750 changes
								let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								cnfg.status = true;
								cnfg.statusMessage = '';
								window.isTotalRedemptionInValid = false;
							}
						}
					}
				}
			//}
		}
		return Promise.resolve(false); 
	},
	/**************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * Method Name : updateRedeemFundonAddtoMac
	 * Invoked When: onaddToMac(redeem fund)
	 * Description : in MAC basket setting redeemFunds to 0
	 * Parameters  : isChildApplicable,compName,childCompName
	 **************************************************************************************/
	// Arinjay JSUpgrade
	updateRedeemFundonAddtoMac: async function (compName, guid) {
		let updateConfigMap = {};
		let inputMap = {};
		let isUpdated = false;
		let currentBasket = await CS.SM.getActiveBasket();
		inputMap["GetBasket"] = currentBasket.basketId;
		currentBasket.performRemoteAction("FundBalanceAmountHelper", inputMap).then((result) => {
			window.currentFundBalance = JSON.parse(result["GetBasket"]);
		});
		//Added From QA1 by Gunjan Start
			//EDGE-164351 start( to copy value of redeemfund to redeemfundcopy during MAC)
			//////////////////////////////////////
			let loadedSolution = await CS.SM.getActiveSolution();
		let cmpName = loadedSolution.getComponentByName("Device");
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
							RedeemFund = relatedProductAttr.filter((obj) => {
								return obj.name === "RedeemFund";
										});
							});
						}	
						if(RedeemFund && RedeemFund[0] ){
							var  NGEMdev = [];
							NGEMdev[relProdguid] = [];
						NGEMdev[relProdguid] = [
							{
								name: "RedeemFundCopy",
									value: RedeemFund[0].displayValue,
										displayValue:RedeemFund[0].displayValue,
											readOnly: false,
												showInUi:false
							}
						];
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
		//From QA1 by Gunjan Start - end
		if (guid) {
            //EDGE-183264 start-------
            let sol=await CS.SM.getActiveSolution();
			let comp=sol.getComponentByName(compName);
			let configuration=comp.getConfiguration(guid);
            //EDGE-183264 end -----
			if (configuration.guid && configuration.replacedConfigId) {
				updateConfigMap[configuration.guid] = [];
				updateConfigMap[configuration.guid] = [
					{
						name: "TotalFundAvailable",
						value: currentFundBalance,
						displayValue: currentFundBalance
					},
					{
						name: "RedeemFund",
						value: 0,
						displayValue: 0
					},
					{	//EDGE-175750: Added 								
						name: "RedeemFundIncGST",
						value: 0,
						displayValue: 0
					}
				];
				isUpdated = true;
				if (configuration.relatedProductList.length >= 0) {
					for (let ReletedConfig of configuration.relatedProductList) {
						if (ReletedConfig.guid && ReletedConfig.ReletedConfig) {
							updateConfigMap[ReletedConfig.guid] = [
								{
									name: "TotalFundAvailable",
									value: currentFundBalance,
									displayValue: currentFundBalance
								},
								{
									name: "RedeemFund",
									value: 0,
									displayValue: 0
								},
                                {	//EDGE-175750: Added 								
                                    name: "RedeemFundIncGST",
                                    value: 0,
                                    displayValue: 0
                                }
							];
						}
					}
				}
			}
		}
		if (isUpdated === true) {
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
		//let updateConfigMap = {};
		let basketRedemp = 0;
		//let inputMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product && product.components && Object.values(product.components).length > 0) {
			for (let comp of Object.values(product.components)) {
				let compConfig = compName.getConfigurations();
				if (compConfig && Object.values(compConfig).length > 0) {
					for (let subsConfig of Object.values(compConfig)) {
						if (subsConfig && subsConfig.relatedProductList.length > 0) {
							for (let Reletedconfig of subsConfig.relatedProductList) {
								let childGuid;
								if (childCompName === Reletedconfig.name) {
									let fundRedeemed_child = 0,
										oneOff_child = 0,
										debitFundCheck_child = false,
										quant_child = 1,
										totalcharge_child = 0;
									childGuid = Reletedconfig.guid;
									let changeTypeName = redemption_changeTypeChild.get(comp.name);
									let ChangeType_child = Reletedconfig.configuration.getAttribute(changeTypeName);
									let changeType = "";
									if (ChangeType_child && ChangeType_child.value) {
										changeType = ChangeType_child.value;
									} else {
										changeType = "New";
									}
									let ChangeTypeparent = Reletedconfig.configuration.getAttribute(ChangeType);
									let changeTypeP = "";
									if (ChangeTypeparent && ChangeTypeparent.value) {
										changeTypeP = ChangeType_child.value;
									} else {
										changeTypeP = "New";
									}
									if (!changeTypeExcludedList.includes(changeType)) {
										let redeemcheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
										let onceOffCharge;
										if (changeTypeP === "PayOut") {
											onceOffCharge = subsConfig.getAttribute("EarlyTerminationCharge");
										} else {
											onceOffCharge = Reletedconfig.configuration.getAttribute("EarlyTerminationCharge");
										}
										if ( onceOffCharge && onceOffCharge.value) {
											if (onceOffCharge  && onceOffCharge.value && onceOffCharge.value !== undefined && onceOffCharge.value !== "") oneOff_child = parseFloat(onceOffCharge.value).toFixed(2);
										}
										quantity = Reletedconfig.configuration.getAttribute("Quantity");
										if (quantity && quantity.value && quantity.value !== undefined && quantity.value !== "") {
											quant_child = Math.trunc(quantity.value);
										}
										RedeemFund = Reletedconfig.configuration.getAttribute("RedeemFund");
										if (RedeemFund && RedeemFund.displayValue && RedeemFund.displayValue !== undefined && RedeemFund.displayValue !== "") {
											fundRedeemed_child = parseFloat(RedeemFund.displayValue);
											fundRedeemed_child = Math.round(fundRedeemed_child * 100) / 100;
											let taxtreatment = Reletedconfig.configuration.getAttribute("taxTreatment");
											if (taxtreatment && taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
												totalcharge_child = parseFloat(oneOff_child * 1.1).toFixed(2);
											} else {
												totalcharge_child = parseFloat(oneOff_child * 1).toFixed(2);
											}
											let reletedConfigComp = await product.getComponentByName(Reletedconfig.name);
											if (fundRedeemed_child === 0) {
												if (changeType === "Cancel") {
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = true;
												} else {
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = true;
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = true;
												}
											}
											if (fundRedeemed_child < 0) {
												window.isTotalRedemptionInValid = true;
												if (changeType === "Cancel") {
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = "Please Put the Valid Amount";
												} else {
													let cnfg = await reletedConfigComp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = "Please Put the Valid Amount";
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = "Please Put the Valid Amount";
												}
											} else if (fundRedeemed_child < totalcharge_child * quant_child) {
												debitFundCheck_child = true;
											}
											if (!debitFundCheck_child && fundRedeemed_child > 0) {
												if (changeTypeP === "Cancel") {
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
													cnfgP.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
												} else {
													let cnfg = await comp.getConfiguration(childGuid);
													cnfg.status = false;
													cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													let cnfgP = await comp.getConfiguration(subsConfig.guid);
													cnfgP.status = false;
												}
												window.isTotalRedemptionInValid = true;
											} else if (window.totalRedemptions >= 0) {
												basketRedemp = window.totalRedemptions;
												if (currentFundBalance - basketRedemp < 0) {
													if (changeTypeP === "Cancel") {
														let cnfgP = await comp.getConfiguration(subsConfig.guid);
														cnfgP.status = false;
														cnfgP.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
													} else {
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = false;
														cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
														let cnfgP = await comp.getConfiguration(subsConfig.guid);
														cnfgP.status = false;
													}
													window.isTotalRedemptionInValid = true;
												} /*else if (currentFundBalance - basketRedemp >= 0) {  //EDGE-169456 - Removed the Configuration message to click on generate net price as part of Pricing Service Enablement
													if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === true || redeemcheckNeeded.value === "true")) {
														if (changeTypeP === "Cancel") {
															let cnfgP = await comp.getConfiguration(subsConfig.guid);
															cnfgP.status = false;
															cnfgP.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														} else {
															let cnfg = await comp.getConfiguration(childGuid);
															cnfg.status = false;
															cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
															let cnfgP = await comp.getConfiguration(subsConfig.guid);
															cnfgP.status = false;
															cnfgP.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
														}
														window.isTotalRedemptionInValid = true;
													} else if (redeemcheckNeeded && redeemcheckNeeded && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
														let cnfg = await comp.getConfiguration(childGuid);
														cnfg.status = true;
													}
												}*/
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
		return window.isTotalRedemptionInValid;
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
	populateNullValuesforClonedPC: async function (componentName, configurations) {
		let updateConfigMap = {};
		for (let configuration of configurations) {
			let mobSubsConfigGUID = "";
			mobSubsConfigGUID = configuration.guid;
			if (mobSubsConfigGUID !== "") {
				updateConfigMap[mobSubsConfigGUID] = [
					{
						name: "TotalFundAvailable",
						value: currentFundBalance,
						displayValue: currentFundBalance
					},
					{
						name: "RedeemFund",
						value: 0.0,
						displayValue: 0.0
					},
                    {   //Added EDGE:175750
						name: "RedeemFundIncGST",
						value: 0.0,
						displayValue: 0.0
					},
					{
						name: "IsRedeemFundCheckNeeded",
						value: false,
						displayValue: false
					},
					{
						name: "CheckOneFund",
						value: false,
						displayValue: false
					}
				];
				let product = await CS.SM.getActiveSolution();
				let component = await product.getComponentByName(componentName);
				let keys = Object.keys(updateConfigMap);
				let complock = component.commercialLock; //added by shubhi for EDGE-169593
				if (complock) component.lock("Commercial", false);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
				if (complock) component.lock("Commercial", true); //added by shubhi for EDGE-169593
			}
			return Promise.resolve(true);
		}
	}
};