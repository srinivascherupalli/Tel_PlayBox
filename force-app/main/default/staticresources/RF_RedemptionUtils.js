/******************************************************************************************
Author	   : Romil Anand && Vishal Arbune
Change Version History
Version No	    Author 			Date           Story
    1.         Vishal Arbune   01-10-2019      EDGE-113083 : Show available OneFund balance from CIDN at the time of basket creation
	2.         Romil Anand     02-10-2019      EDGE-115925 : Calculation of Total Basket amount on Validate & Save
	3.         Romil Anand     05-10-2019      EDGE-114977 : UI changes to be made on Subscription page
	4.         Romil Anand     10-10-2019      EDGE-113570 : Redemption amount cannot be more than the Charge Amount
	5.         Romil Anand     12-10-2019      EDGE-113091 : Show Fund balance details on Subscription page for each Solution in the Basket
	6.         Vishal Arbune   13-10-2019      EDGE-112359 : Cloudsense Opportunity basket flow
	7.         Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
	8.         Romil Anand     25-12-2019      EDGE-118038 : Eligible Redeemable charges (from Sigma to CS)-New Scenario
	9.         Romil Anand     25-10-2019      EDGE-119323 : GST Calculation of Net Charge while Redemption
	10.        Romil Anand     22-10-2019      EDGE-127941 : Calculate Total Contract Value for a Basket
	11.        Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
	12.        Romil Anand     15-01-2020      EDGE-130075 : Redeeming One Funds for Cancel Journey for NGUC
	13.        Romil Anand     15-01-2020      EDGE-130859 : Redeeming One Funds for Cancel Journey for CMP
    14. 	   Romil Anand     24-04-2020	   EDGE-144161 : Enabling Redemption as Discount for Device Payout and NGUC 
    15.        Aditya Pareek   15-05-2020      Edge-144971 : Updated by Aditya for setting Redeem fund vlaue as 0
    16. 	   Romil Ananad    26-05-2020	   EDGE-150132 : added OR part by Romil
    17.		   Ankit Goswami   01-06-2020	   EDGE-152069 : Fix issue For show Check OneFund 
    18.        Shubhi	       08-June-2020	   EDGE-148662 : Enabling one fund and POS
    19.        Arinjay Singh   02-July-2020    EDGE-155244 : JSPlugin Upgrade  and Merge with 20.08
	20.        shubhi		13-08-2020		EDGE-169593 js ugrade issue fixes
	21.		   martand Atrey	3-10-2020	Refactored
	22.		   martand Atrey	20-10-2020	Refactored 

	23.        Arinjay          22.10.2020  fixed Promice issue
24.                Shubhi           22.16        26/11/2020     EDGE-190170
	25.        Pooja Bhat       26.11.2020      EDGE-190802 : Sprint 20.16
    26.		   Vishal Arbune    01-02-2021      EDGE-198208 : Add ex. GST label with OneFund Balance in Product Basket and OneFund Balance at Account 
	27.		   Pawan Singh	    11-08-2021		DIGI-5648: replacing Telstra collaboration to Adaptive collaboration
******************************************************************************************/
var NGUC_OFFER_NAME = 'Adaptive Collaboration'; //DIGI-5648

window.currentFundBalance = 0.0;
window.basket = 0.0;
window.basketlevelRedemption = 0.0;
window.deductBalanceConfig = 0.0;
var Redemption_COMPONENT_NAMES = {
	DOPsolution: "Device Outright Purchase",
	solution: "Device Outright Purchase",
	enterpriseMobility: "Corporate Mobile Plus",
	mobileSubscription: "Mobile Subscription",
	// NGUC: "Telstra Collaboration",   DIGI-5648
	NGUC: NGUC_OFFER_NAME,
	deviceOutRight: "Mobile Device",
	device: "Device",
	DevicesMTS: "Devices",
	Device: "Unified Communication Device",
	AccessoryMTS: "Accessories",
	Accessory: "Accessory",
	inactiveSIM: "Inactive SIM",
	NextGenEM: "Next Generation Enterprise Mobility",
	nextGenEM_Device: "Device"
};
RedemptionUtils = {
	/**************************************************************************************
	 * Author	   : Vishal Arbune
	 * Method Name : displayCurrentFundBalanceAmt
	 * Invoked When: On loading of Solution
	 * Description : Fetch the Fund Balance From CIDN level
	 **************************************************************************************/
	displayCurrentFundBalanceAmt: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		let cart=await CS.SM.getBasketName();//.then((cart) => {
			let inputMap = {};
			inputMap["GetBasket"] = cart;
			currentBasket.performRemoteAction("FundBalanceAmountHelper", inputMap).then((result) => {
				window.currentFundBalance = JSON.parse(result["GetBasket"]);
				return Promise.resolve(true);
			});
			//return Promise.resolve(true);
		//});
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : calculateBasketRedemption
	 * Invoked When: On loading of Solution
	 * Description : Fetching the basket Redemption Amount from PC's level
	 **************************************************************************************/
	calculateBasketRedemption: async (currentBasket, basketName) => {
		//currentBasket = await CS.SM.getActiveBasket();
		let inputMap = {};
		inputMap["GetBasket"] = basketName;
		await currentBasket.performRemoteAction("BasketRedemptionHelper", inputMap).then((result) => {
			window.basket = JSON.parse(result["GetBasket"]);
			window.basketlevelRedemption = JSON.parse(result["GetBasket"]);
		});
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketAmount
	 * Invoked When: On loading of Solution
	 * Description : Sets Mobile Subscription configuration name
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmount: function (solution) {
		if (solution && (solution.name === Redemption_COMPONENT_NAMES.DOPsolution || solution.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) {
			let component = solution.getComponentByName(Redemption_COMPONENT_NAMES.deviceOutRight);
			if (component) {
				populatebasketAmountCommon(component);
			}
			component = solution.getComponentByName(Redemption_COMPONENT_NAMES.DevicesMTS);
			if (component) {
				populatebasketAmountCommon(component);
			}
			component = solution.getComponentByName(Redemption_COMPONENT_NAMES.nextGenEM_Device);
			if (component) {
				populatebasketAmountCommon(component);
			}
		}
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketAmountforAccessory
	 * Invoked When: On loading of Solution
	 * Description : Sets Mobile Subscription configuration name
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforAccessory: async function () {
		let solution = await CS.SM.getActiveSolution();
		if (solution && solution.name === Redemption_COMPONENT_NAMES.NGUC) {
			let component = solution.getComponentByName(Redemption_COMPONENT_NAMES.AccessoryMTS);
			if (component) {
				populatebasketAmountCommon(comp);
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populateNullValues
	 * Invoked When: On Cloning of Solution
	 * Description : Sets Redemption Values to Null
	 * Parameters  : configuration guid or left empty if doing for all configs
	 * Updated:    : Updated by Aditya for Edge-144971(Value and Display Value)
	 * *   * Updated:    : Updated by Shubhi for Edge-144971(Value and Display Value)
	 **************************************************************************************/
	populateNullValues: async function (component, configuration) {
		let updateConfigMap = {};
		var mobSubsConfigGUID = "";
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
				{   //Added: EDGE-190802
					name: "RedeemFundIncGST",
					value: 0.0,
					displayValue: 0.0
				}
			];
			await component.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap[mobSubsConfigGUID], true);
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : displayRemainingBalanceAmt
	 * Invoked When: On 49ing of checkonefund button
	 * Description : Calculates the dynamic balance
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	displayRemainingBalanceAmt: async function () {
		var showbalance = 0.0;
		var totalRedemption = 0.0;
		if (basketStage === "Draft" || basketStage === "Commercial Configuration" || basketStage === "Quote" || basketStage === "Contract Initiated") {
			let solution = await CS.SM.getActiveSolution();
			let components = solution.getComponents();
			if (components) {
				Object.values(components.components).forEach((comp) => {
					if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS || comp.name === Redemption_COMPONENT_NAMES.nextGenEM_Device) {
						let configurations = component.getConfigurations();
						if (configurations) {
							Object.values(configurations).forEach((subsConfig) => {
								if (!subsConfig.id || subsConfig.id === "" || subsConfig.id === null) {
									let fundRedeemed = 0;
									mobSubsConfigGUID = subsConfig.guid;
									let RedeemFund = subsConfig.getAttribute("RedeemFund");
									if (RedeemFund && RedeemFund.displayValue) fundRedeemed = fundRedeemed + parseFloat(RedeemFund.displayValue);
									fundRedeemed = Math.round(fundRedeemed * 100) / 100;
									if (fundRedeemed <= window.currentFundBalance) {
										totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
										showbalance = parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
									}
								}
							});
						}
					} else if (comp.name === Redemption_COMPONENT_NAMES.mobileSubscription) {
						let configurations = comp.getConfigurations();
						if (configurations) {
							Object.values(configurations).forEach((subsConfig) => {
								let fundRedeemed = 0;
								mobSubsConfigGUID = subsConfig.guid;
								let RedeemFund = subsConfig.getAttribute("RedeemFund");
								let ChangeTypeOnPlan = subsConfig.getAttribute("ChangeType");
								if (ChangeTypeOnPlan && ChangeTypeOnPlan.value === "Modify") {
									if (subsConfig && subsConfig.relatedProductList.length > 0) {
										subsConfig.relatedProductList.forEach((Reletedplanconfig) => {
											var ChangeTypeOnDevice = Reletedplanconfig.configuration.getAttribute("ChangeTypeDevice");
											var RedeemFundDevice = Reletedplanconfig.configuration.getAttribute("RedeemFund");
											if (ChangeTypeOnDevice.value === "PayOut") {
												if (RedeemFundDevice && RedeemFundDevice.displayValue) fundRedeemed = fundRedeemed + parseFloat(RedeemFundDevice.displayValue);
											}
										});
									}
								} else if (ChangeTypeOnPlan && ChangeTypeOnPlan.value === "Cancel") {
									if (RedeemFund && RedeemFund.displayValue) fundRedeemed = fundRedeemed + parseFloat(RedeemFund.displayValue);
								}
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								if (fundRedeemed <= window.currentFundBalance) {
									totalRedemption = parseFloat(totalRedemption) + fundRedeemed;
									showbalance = parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
								}
							});
						}
					}
				});
				showbalance = parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
				if (showbalance >= 0) {
                    //EDGE-198208
					CS.SM.displayMessage("Available OneFund (ex. GST) " + showbalance, "success");
				} else {
					CS.SM.displayMessage("There is an Error in the Configuration or other Solution Configuration.", "error");
				}
			}
			return Promise.resolve(true);
		} else {
            //EDGE-198208
			CS.SM.displayMessage("Available OneFund (ex. GST) " + currentFundBalance, "success");
		}
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketAmountforSaved
	 * Invoked When: On loading of Solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforSaved: async function () {
		let solution = await CS.SM.getActiveSolution();
		if (solution && (solution.name === Redemption_COMPONENT_NAMES.DOPsolution || solution.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) {
			let component = solution.getComponentByName(Redemption_COMPONENT_NAMES.deviceOutRight);
			if (component) {
				populatebasketAmountforSavedCommon(component);
			}
			component = solution.getComponentByName(Redemption_COMPONENT_NAMES.deviceOutRight);
			if (component) {
				populatebasketAmountforSavedCommon(component);
			}
			component = solution.getComponentByName(Redemption_COMPONENT_NAMES.deviceOutRight);
			if (component) {
				populatebasketAmountforSavedCommon(component);
			}
			/* Object.values(solution.components).forEach((comp) => {
                        if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {//REVIEW is the condition Correct ? 
					}
				});
			} */
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketAmountforSavedAccessory
	 * Invoked When: On loading of Solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforSavedAccessory: async function () {
		let solution = await CS.SM.getActiveSolution();
		if (/*solution.type &&*/ solution.name === Redemption_COMPONENT_NAMES.DOPsolution || solution.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM) {
			let component = solution.getComponentByName(Redemption_COMPONENT_NAMES.AccessoryMTS);
			if (component) {
				populatebasketAmountforSavedCommon(comp);
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : checkRedeemDiscountonload
	 * Invoked When: on load of solution
	 * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
	 * Parameters  : checks for all config
	 **************************************************************************************/
	checkRedeemDiscountonload: async function (solutionName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution && /*solution.type &&*/ (solution.name === Redemption_COMPONENT_NAMES.DOPsolution || solution.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) {
			let components = solution.getComponents();
			if (components) {
				var IsUpdateAttribute = false;
				Object.values(components).forEach((comp) => {
					if (comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS || comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || Redemption_COMPONENT_NAMES.nextGenEM_Device) {
						let configurations = comp.getConfigurations();
						if (configurations) {
							Object.values(configurations).forEach(async (subsConfig) => {
								mobSubsConfigGUID = subsConfig.guid;
								var redeemFundCheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
								if (redeemFundCheckNeeded && redeemFundCheckNeeded.value === true) {
									IsUpdateAttribute = true;
								}
								let cnfg = await comp.getConfiguration(subsConfig.guid);
								if (IsUpdateAttribute) {
									cnfg.status = false;
									cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
								} else {
									cnfg.status = true;
								}
							});
						}
					}
				});
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : CheckRedeemFundDiscount
	 * Invoked When: whenever redemption value gets populated.
	 * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
	 * Parameters  : configuration guid and componentName
	 **************************************************************************************/
	CheckRedeemFundDiscount: async function (guid, componentName) {
		var IsUpdateAttribute = false;
		let updateMapFund = new Map();
		let solution = await CS.SM.getActiveSolution();
		let comp = solution.getComponentByName(componentName);
		if (comp) {
			let configuration = comp.getConfiguration(guid);
			if (configuration) {
				let componentMapNew = new Map();
				let RedeemFund = subsConfig.getAttribute("RedeemFund");
				if (RedeemFund.displayValue > 0) {
					IsUpdateAttribute = true;
				}
				let cnfg = await comp.getConfiguration(subsConfig.guid);
				if (IsUpdateAttribute) {
					componentMapNew.set("IsRedeemFundCheckNeeded", true);
					cnfg.status = false;
					cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
				} else {
					componentMapNew.set("IsRedeemFundCheckNeeded", false);
					cnfg.status = true;
				}
			}
			if (componentMapNew && Object.values(componentMapNew).length > 0) {
				updateMapFund.set(subsConfig.guid, componentMapNew);
			}
			if (updateMapFund) CommonUtills.UpdateValueForSolution(componentName, updateMapFund);
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : CheckRedeemDiscountValidation
	 * Invoked When: whenever response from MS will come.
	 * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
	 * Parameters  : componentName
	 **************************************************************************************/
	CheckRedeemDiscountValidation: async function (componentName) {
		let solution = await CS.SM.getActiveSolution();
		let comp = solution.getComponents(componentName);
		if (comp) {
			if (basketChangeType !== "Change Solution" && (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device)) {
				populatebasketAmountCommon(comp);
				populatebasketAmountforSavedCommon(comp);
			} else if (basketChangeType === "Change Solution" && (comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device)) {
				populatebasketAmountforCancelCommon(comp);
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : checkConfigurationStatus
	 * Invoked When: before saving the solution
	 * Description : Check the configuration status and mark it valid or invalid on the basis of that
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	checkConfigurationStatus: async function () {
		let solution = await CS.SM.getActiveSolution();
		if (solution && (solution.name === Redemption_COMPONENT_NAMES.DOPsolution || solution.name === Redemption_COMPONENT_NAMES.NGUC || solution.name === Redemption_COMPONENT_NAMES.enterpriseMobility || Redemption_COMPONENT_NAMES.NextGenEM)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {
						//EDGE-148662
						checkConfigurationStatusCommon(comp);
					}
					if (comp.name === Redemption_COMPONENT_NAMES.mobileSubscription) {
						checkConfigurationStatusCommon(comp);
						if (comp.relatedComponents && Object.values(comp.relatedComponents).length > 0) {
							Object.values(comp.relatedComponents).forEach((relatedcomp) => {
								checkConfigurationStatusCommon(relatedcomp);
							});
						}
					}
				});
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : checkConfigurationStatusforAccessory
	 * Invoked When: before saving the solution
	 * Description : Check the configuration status and mark it valid or invalid on the basis of that
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	checkConfigurationStatusforAccessory: async function () {
		let solution = await CS.SM.getActiveSolution();
		if (solution && solution.name === Redemption_COMPONENT_NAMES.NGUC) {
			let comp = solution.getComponentByName(Redemption_COMPONENT_NAMES.AccessoryMTS);
			if (comp) {
				checkConfigurationStatusCommon(comp);
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketforCancelCMPScenario
	 * Invoked When: attribute update,before and on loading of saving the solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforCancelCMP: async function () {
		if (basketChangeType !== "Change Solution") {
			return;
		}
		let solution = await CS.SM.getActiveSolution();
		if (solution.name === Redemption_COMPONENT_NAMES.enterpriseMobility) {
			let comp = await solution.getComponentByName(Redemption_COMPONENT_NAMES.mobileSubscription);
			
			if (comp) {
				await populatebasketAmountforCancellationCMP(comp);
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketforModifyCMPScenario
	 * Invoked When: attribute update,before and on loading of saving the solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforModifyCMP: async function () {
		if (basketChangeType !== "Change Solution") {
			return;
		}
		let solution = await CS.SM.getActiveSolution();
		if (solution && solution.name === Redemption_COMPONENT_NAMES.enterpriseMobility) {
			let comp = await solution.getComponentByName(Redemption_COMPONENT_NAMES.mobileSubscription);
			if (comp) {
				if (comp.relatedComponents && Object.values(comp.relatedComponents).length > 0) {
					Object.values(comp.relatedComponents).forEach((relatedcomp) => {
						populatebasketAmountforModCMP(relatedcomp);
					});
				}
			}
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketforCancelScenario
	 * Invoked When: attribute update,before and on loading of saving the solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforCancel: async function () {
		if (basketChangeType !== "Change Solution") {
			return;
		}
		let solution = await CS.SM.getActiveSolution();
		if (solution && (solution.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) {
			let comp = solution.getComponentByName(Redemption_COMPONENT_NAMES.DevicesMTS);
			if (comp) {
				populatebasketAmountforCancelCommon(comp);
			}
			comp = solution.getComponentByName(Redemption_COMPONENT_NAMES.DevicesMTS);
			if (comp) {
				populatebasketAmountforCancelCommon(comp);
			}
			/* Object.values(solution.components).forEach((comp) => {
                if (comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) { // REVIEW
                    populatebasketAmountforCancelCommon(comp);
                }
            }); */
		}
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Romil Anand
	 * Method Name : populatebasketforCancelAccessoryScenario
	 * Invoked When: attribute update,before and on loading of saving the solution
	 * Description : it allows to edit the saved configuration
	 * Parameters  : configuration guid or left empty if doing for all configs
	 **************************************************************************************/
	populatebasketAmountforCancelAccessory: async function () {
		if (basketChangeType !== "Change Solution") {
			return;
		}
		let solution = await CS.SM.getActiveSolution();
		if (solution.name === Redemption_COMPONENT_NAMES.NGUC) {
			let comp = solution.getComponentByName(Redemption_COMPONENT_NAMES.AccessoryMTS);
			if (comp) {
				populatebasketAmountforCancelCommon(comp);
			}
		}
		return Promise.resolve(true);
	}
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : checkConfigurationStatusforCommon
 * Invoked When: before saving the solution
 * Description : Check the configuration status and mark it valid or invalid on the basis of that
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const checkConfigurationStatusCommon = (comp) => {
	let updateConfigMap = {};
	let mobSubsConfigGUID = "";
	let configurations = comp.getConfigurations();
	if (configurations) {
		Object.values(configurations).forEach(async (subsConfig) => {
			var checkonefund = false;
			mobSubsConfigGUID = subsConfig.guid;
			var configStatus = subsConfig.status;
			if (configStatus === false) {
				checkonefund = true;
			} else {
				checkonefund = false;
			}
			if (mobSubsConfigGUID !== "") {
				updateConfigMap[mobSubsConfigGUID] = [
					{
						name: "CheckOneFund",
						value: checkonefund,
						displayValue: checkonefund
					}
				];
				// Spring 20
				var complock = comp.commercialLock;
				if (complock) comp.lock("Commercial", false);
				await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap[mobSubsConfigGUID], true);
				if (complock) {
					comp.lock("Commercial", true);
				}
			}
		});
	}
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : populatebasketAmountforCancelCMP
 * Invoked When: attribute update,before and on loading of saving the solution
 * Description : Populate the values in Subscription level
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const populatebasketAmountforCancellationCMP = (comp) => {
	let updateConfigMap = {};
	
	var basketRedemp=0;
	if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
			var mobSubsConfigGUID = "";
			var mobSubsConfigRelatedGUID = "";
			var fundRedeemed = 0,
			netPriceIncGST = 0,
			etc = 0,
			debitFundCheck = false,
			quant = 1, //EDGE-190170
			netPriceExcGST = 0,
			totalcharge = 0,
			custredeem = 0,
			changeDeviceType = "",
			totalchargeExcGST = 0;  //Added: EDGE-190802
			mobSubsConfigGUID = subsConfig.guid;
			var changeType = subsConfig.getAttribute("ChangeType");
			if (changeType && changeType.displayValue === "Cancel") {
				if (subsConfig.relatedProductList && Object.values(subsConfig.relatedProductList).length > 0) {
					for (let relatedconfig of subsConfig.relatedProductList) { // EDGE-190170
							//Object.values(relatedcomp.configuration).forEach(async (relatedconfig) => {
								mobSubsConfigRelatedGUID = relatedconfig.configuration.guid; //EDGE-190170
								changeDeviceType = relatedconfig.configuration.getAttribute("ChangeTypeDevice"); //EDGE-190170
								var earlyTC = subsConfig.getAttribute("EarlyTerminationCharge");
								if (earlyTC && earlyTC.displayValue) etc = parseFloat(earlyTC.displayValue).toFixed(2);
								//var quantity = subsConfig.getAttribute("Quantity");//EDGE-190170
								//if (quantity && quantity.displayValue) quant = Math.trunc(quantity.displayValue);
								var RedeemFund = subsConfig.getAttribute("RedeemFund");
								if (RedeemFund && RedeemFund.displayValue) fundRedeemed = parseFloat(RedeemFund.displayValue);
								fundRedeemed = Math.round(fundRedeemed * 100) / 100;
								var taxtreatment = subsConfig.getAttribute("taxTreatment");
								var updateMap = [];
								if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
									totalcharge = parseFloat(etc * 1.1).toFixed(2);
									if (quant !== 0) {
										netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
									} else {
										netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
									}
									netPriceExcGST = parseFloat(netPriceIncGST / 1.1).toFixed(2);
									totalchargeExcGST = parseFloat(totalcharge / 1.1).toFixed(2);   //Added: EDGE-190802
									
									/*updateMap[mobSubsConfigGUID] = [
										{
											name: "OneOffChargeGST",
											label: "Balance Due On Device (Inc GST)",
											value: totalcharge,
											displayValue: totalcharge
										}
									];
									updateMap[mobSubsConfigRelatedGUID] = [
										{
											name: "OneOffChargeGST",
											label: "Balance Due On Device (Inc GST)",
											value: totalcharge,
											displayValue: totalcharge
										}
									];*/
								} else if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "TAX Exempt") {
									totalcharge = parseFloat(etc * 1).toFixed(2);
									if (quant !== 0) {
										netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
									} else {
										netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
									}
									netPriceExcGST = parseFloat(netPriceIncGST / 1).toFixed(2);
									totalchargeExcGST = parseFloat(totalcharge / 1).toFixed(2);   //Added: EDGE-190802
									/*updateMap[mobSubsConfigGUID] = [
										{
											name: "OneOffChargeGST",
											showInUi: false,
											label: "Balance Due On Device (Inc GST)",
											value: "NA",
											displayValue: "NA"
										}
									];
									updateMap[mobSubsConfigRelatedGUID] = [
										{
											name: "OneOffChargeGST",
											showInUi: false,
											label: "Balance Due On Device (Inc GST)",
											value: "NA",
											displayValue: "NA"
										}
									];*/
								}
								//let keys = Object.keys(updateMap);
								/*for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
								}*/
								if (quant !== 0) {
									custredeem = totalchargeExcGST * quant; //EDGE-190802: Modified totalcharge to totalchargeExcGST
								} else {
									custredeem = totalchargeExcGST; //EDGE-190802: Modified totalcharge to totalchargeExcGST
								}
								if (fundRedeemed > custredeem) {
									debitFundCheck = true;
								} else if (fundRedeemed < 0) {
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = false;
									cnfg.statusMessage = "Please Put the Valid Amount";
									return Promise.resolve(false);
								}
								if (!debitFundCheck && fundRedeemed >= 0) {
									basketRedemp = window.basket + fundRedeemed;
									window.basket = basketRedemp;
									if (currentFundBalance - basketRedemp < 0) {
										basketRedemp = window.basket - fundRedeemed;
										netPriceIncGST = totalcharge;
										return Promise.resolve(false);
									} else {
										let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
										cnfg.status = true;
										window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
									}
								} else {
									netPriceIncGST = totalcharge;
									let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
									cnfg.status = false;
									cnfg.statusMessage = "You can not redeem amount greater than Balance Due and OneFund Balance";
									//return Promise.resolve(false);
								}
								//let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
								//cnfg.status = true;
								window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
								if (mobSubsConfigGUID !== "" && mobSubsConfigRelatedGUID !== "") {
									updateConfigMap[mobSubsConfigGUID] = [
										{
											name: "BasketRedemptionAmount",
											value: window.basket,
											displayValue: window.basket
										},
										{
											name: "TotalFundAvailable",
											value: currentFundBalance,
											displayValue: currentFundBalance
										},
										{
											name: "FundAvailable",
											value: deductBalanceConfig,
											displayValue: deductBalanceConfig
										},
										{
											name: "NetPriceIncGST",
											value: netPriceIncGST,
											displayValue: netPriceIncGST
										},
										{
											name: "NetPriceExcGST",
											value: netPriceExcGST,
											displayValue: netPriceExcGST
										}
									];
									if (changeDeviceType.displayValue === "PayOut") {
										updateConfigMap[mobSubsConfigRelatedGUID] = [
											{
												name: "BasketRedemptionAmount",
												value: window.basket,
												displayValue: window.basket
											},
											/*{
												name: "RedeemFund",
												value: fundRedeemed,
												displayValue: fundRedeemed

											},
											{   //Added: EDGE-190802
												name: "RedeemFundIncGST",
												value: fundRedeemed * 1.1,
												displayValue: fundRedeemed * 1.1
											},*/
											{
												name: "TotalFundAvailable",
												value: currentFundBalance,
												displayValue: currentFundBalance
											},
											{
												name: "FundAvailable",
												value: deductBalanceConfig,
												displayValue: deductBalanceConfig
											},
											{
												name: "NetPriceIncGST",
												value: netPriceIncGST,
												displayValue: netPriceIncGST
											},
											{
												name: "NetPriceExcGST",
												value: netPriceExcGST,
												displayValue: netPriceExcGST
											}
										];
									}
									let keys = Object.keys(updateConfigMap);
									//let sol=await CS.SM.getActiveSolution();
									//let cmpup=await sol.getComponentByName('Mobile Subscription');
									for (let i = 0; i < keys.length; i++) {
										comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
									}
								//}
							}//);
						}
					}
				}
			});
	}
	
	return Promise.resolve(true);
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : populatebasketAmountforModCMP
 * Invoked When: attribute update,before and on loading of saving the solution
 * Description : Populate the values in Subscription level
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const populatebasketAmountforModCMP = (comp) => {
	let updateConfigMap = {};
	
	var basketRedemp=0;
	if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
			var mobSubsConfigGUID = "";
			var fundRedeemed = 0,
				netPriceIncGST = 0,
				etc = 0,
				debitFundCheck = false,
				quant = 0,
				netPriceExcGST = 0,
				totalcharge = 0,
				custredeem = 0,
				totalchargeExcGST = 0; //Added: EDGE-190802
			mobSubsConfigGUID = subsConfig.guid;
			var changeDeviceType = subsConfig.getAttribute("ChangeTypeDevice");
			if (changeDeviceType.displayValue === "PayOut") {
				var earlyTC = subsConfig.getAttribute("EarlyTerminationCharge");
				if (earlyTC && earlyTC.displayValue) etc = parseFloat(earlyTC.displayValue).toFixed(2);
				var quantity = 1; //subsConfig.getAttribute("Quantity"); //EDGE-190170
				if (quantity && quantity.displayValue) quant = Math.trunc(quantity.displayValue);
				var RedeemFund = subsConfig.getAttribute("RedeemFund");
				if (RedeemFund && RedeemFund.displayValue) fundRedeemed = parseFloat(RedeemFund.displayValue);
				fundRedeemed = Math.round(fundRedeemed * 100) / 100;
				var taxtreatment = subsConfig.getAttribute("taxTreatment");
				{
					var updateMap = [];
					if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
						totalcharge = parseFloat(etc * 1.1).toFixed(2);
						if (quant !== 0) {
							netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
						} else {
							netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
						}
						netPriceExcGST = parseFloat(netPriceIncGST / 1.1).toFixed(2);
						totalchargeExcGST = parseFloat(totalcharge / 1.1).toFixed(2); //Added: EDGE-190802
						
						/*updateMap[mobSubsConfigGUID] = [
							{
								name: "OneOffChargeGST",
								label: "Balance Due On Device (Inc GST)",
								value: totalcharge,
								displayValue: totalcharge
							}
						];*/
					} else if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "TAX Exempt") {
						totalcharge = parseFloat(etc * 1).toFixed(2);
						if (quant !== 0) {
							netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
						} else {
							netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
						}
						netPriceExcGST = parseFloat(netPriceIncGST / 1).toFixed(2);
						totalchargeExcGST = parseFloat(totalcharge / 1).toFixed(2); //Added: EDGE-190802
						/*updateMap[mobSubsConfigGUID] = [
							{
								name: "OneOffChargeGST",
								showInUi: false,
								label: "Balance Due On Device (Inc GST)",
								value: "NA",
								displayValue: "NA"
							}
							
						];*/
					}
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}
				if (quant !== 0) {
					custredeem = totalchargeExcGST * quant; //EDGE-190802: Modified totalcharge to totalchargeExcGST
				} else {
					custredeem = totalchargeExcGST; //EDGE-190802: Modified totalcharge to totalchargeExcGST
				}
				if (fundRedeemed > custredeem) {
					debitFundCheck = true;
				} else if (fundRedeemed < 0) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "Please Put the Valid Amount";
					return Promise.resolve(false);
				}
				if (!debitFundCheck && fundRedeemed >= 0) {
					basketRedemp = window.basket + fundRedeemed;
					window.basket = basketRedemp;
					if (currentFundBalance - basketRedemp < 0) {
						basketRedemp = window.basket - fundRedeemed;
						netPriceIncGST = totalcharge;
						return Promise.resolve(false);
					} else {
						let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
						cnfg.status = true;
						window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
					}
				} else {
					netPriceIncGST = totalcharge;
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "You can not redeem amount greater than Balance Due and OneFund Balance";
					//return Promise.resolve(false);
				}
				//let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
				//cnfg.status = true;
				window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
				if (mobSubsConfigGUID !== "") {
					updateConfigMap[mobSubsConfigGUID] = [
						{
							name: "BasketRedemptionAmount",
							value: window.basket,
							displayValue: window.basket
						},
						{
							name: "TotalFundAvailable",
							value: currentFundBalance,
							displayValue: currentFundBalance
						},
						{
							name: "FundAvailable",
							value: deductBalanceConfig,
							displayValue: deductBalanceConfig
						},
						{
							name: "NetPriceIncGST",
							value: netPriceIncGST,
							displayValue: netPriceIncGST
						},
						{
							name: "NetPriceExcGST",
							value: netPriceExcGST,
							displayValue: netPriceExcGST
						}
					];
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			}
		});
	}
	return Promise.resolve(true);
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : populatebasketAmountforCancelCommon
 * Invoked When: attribute update,before and on loading of saving the solution
 * Description : Populate the values in Subscription level
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const populatebasketAmountforCancelCommon = (comp) => {
	let updateConfigMap = {};
	var mobSubsConfigGUID = "";
	if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
			var fundRedeemed = 0,
				netPriceIncGST = 0,
				etc = 0,
				debitFundCheck = false,
				quant = 0,
				netPriceExcGST = 0,
				totalcharge = 0,
				custredeem = 0,
				totalchargeExcGST = 0;  //Added: EDGE-190802
			mobSubsConfigGUID = subsConfig.guid;
			var ChangeType = subsConfig.getAttribute("ChangeType");
			if (ChangeType && (ChangeType.value === "Cancel" || ChangeType.value === "PayOut")) {
				var redeemcheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
				var earlyTC = subsConfig.getAttribute("EarlyTerminationCharge");
				if (earlyTC && earlyTC.displayValue) etc = parseFloat(earlyTC.displayValue).toFixed(2);
				var quantity = subsConfig.getAttribute("Quantity");
				if (quantity && quantity.displayValue) quant = Math.trunc(quantity.displayValue);
				var RedeemFund = subsConfig.getAttribute("RedeemFund");
				if (RedeemFund && RedeemFund.displayValue) fundRedeemed = parseFloat(RedeemFund.displayValue);
				fundRedeemed = Math.round(fundRedeemed * 100) / 100;
				var taxtreatment = subsConfig.getAttribute("taxTreatment");
				var updateMap = [];
				if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
					totalcharge = parseFloat(etc * 1.1).toFixed(2);
					if (quant !== 0) {
						netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
					} else {
						netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
					}
					netPriceExcGST = parseFloat(netPriceIncGST / 1.1).toFixed(2);
					totalchargeExcGST = parseFloat(totalcharge / 1.1).toFixed(2);  //Added: EDGE-190802
					updateMap[mobSubsConfigGUID] = [
						{
							name: "OneOffChargeGST",
							label: "Balance Due On Device (Inc GST)",
							value: totalcharge,
							displayValue: totalcharge
						}
					];
				} else if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "TAX Exempt") {
					totalcharge = parseFloat(etc * 1).toFixed(2);
					if (quant !== 0) {
						netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
					} else {
						netPriceIncGST = parseFloat(totalcharge - fundRedeemed).toFixed(2);
					}
					netPriceExcGST = parseFloat(netPriceIncGST / 1).toFixed(2);
					totalchargeExcGST = parseFloat(totalcharge / 1).toFixed(2);  //Added: EDGE-190802
					updateMap[mobSubsConfigGUID] = [
						{
							name: "OneOffChargeGST",
							showInUi: false,
							label: "Balance Due On Device (Inc GST)",
							value: "NA",
							displayValue: "NA"
						}
					];
				}
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
				if (quant !== 0) {
					custredeem = totalchargeExcGST * quant; //EDGE-190802: Modified totalcharge to totalchargeExcGST
				} else {
					custredeem = totalchargeExcGST; //EDGE-190802: Modified totalcharge to totalchargeExcGST
				}
				if (fundRedeemed > custredeem) {
					debitFundCheck = true;
				} else if (fundRedeemed < 0) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "Please Put the Valid Amount";
					return Promise.resolve(false);
				}
				if (!debitFundCheck && fundRedeemed >= 0) {
					basketRedemp = window.basket + fundRedeemed;
					window.basket = basketRedemp;
					if (currentFundBalance - basketRedemp < 0) {
						basketRedemp = window.basket - fundRedeemed;
						netPriceIncGST = totalcharge;
						return Promise.resolve(false);
					} else {
						window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
					}
				} else {
					netPriceIncGST = totalcharge;
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "You can not redeem amount greater than Balance Due and OneFund Balance";
					return Promise.resolve(false);
				}
				if (redeemcheckNeeded && redeemcheckNeeded.value && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = true;
				}
				window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
				if (mobSubsConfigGUID !== "") {
					updateConfigMap[mobSubsConfigGUID] = [
						{
							name: "BasketRedemptionAmount",
							value: window.basket,
							displayValue: window.basket
						},
						{
							name: "TotalFundAvailable",
							value: currentFundBalance,
							displayValue: currentFundBalance
						},
						{
							name: "FundAvailable",
							value: deductBalanceConfig,
							displayValue: deductBalanceConfig
						},
						{
							name: "NetPriceIncGST",
							value: netPriceIncGST,
							displayValue: netPriceIncGST
						},
						{
							name: "NetPriceExcGST",
							value: netPriceExcGST,
							displayValue: netPriceExcGST
						}
					];
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			}
		});
	}
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : populatebasketAmountforSavedCommon
 * Invoked When: attribute update,before and on loading of saving the solution
 * Description : Populate the values in Subscription level
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const populatebasketAmountforSavedCommon = (comp) => {
	if (basketChangeType === "Change Solution") {
		return;
	}
	let updateConfigMap = {};
	var mobSubsConfigGUID = "";
	var totalfundRedeemed = 0;
	if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
			if (subsConfig.id && subsConfig.id !== "" && subsConfig.id !== null) {
				var fundRedeemed = 0,
					netPriceIncGST = 0,
					oneOff = 0,
					debitFundCheck = false,
					quant = 0,
					netPriceExcGST = 0,
					totalcharge = 0,
					totalchargeExcGST = 0;  //Added: EDGE-190802
				mobSubsConfigGUID = subsConfig.guid;
				var redeemcheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
				var totalfundAvailable = subsConfig.getAttribute("TotalFundAvailable");
				var onceOffCharge = subsConfig.getAttribute("OneOffCharge");
				if (onceOffCharge) {
					if (onceOffCharge.displayValue) oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
				} else {
					onceOffCharge = subsConfig.getAttribute("OC");
					if (onceOffCharge && onceOffCharge.displayValue) oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
				}
				var quantity = subsConfig.getAttribute("Quantity");
				if (quantity && quantity.displayValue) quant = Math.trunc(quantity.displayValue);
				var RedeemFund = subsConfig.getAttribute("RedeemFund");
				if (RedeemFund && RedeemFund.displayValue) fundRedeemed = parseFloat(RedeemFund.displayValue);
				fundRedeemed = Math.round(fundRedeemed * 100) / 100;
				totalfundRedeemed = totalfundRedeemed + fundRedeemed;
				var taxtreatment = subsConfig.getAttribute("taxTreatment");
				var updateMap = [];
				if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue == "GST Applicable") {
					totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
					netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
					netPriceExcGST = parseFloat(netPriceIncGST / 1.1).toFixed(2);
					totalchargeExcGST = parseFloat(totalcharge / 1.1).toFixed(2); //Added: EDGE-190802
					updateMap[mobSubsConfigGUID] = [
						{
							name: "OneOffChargeGST",
							showInUi: true,
							value: totalcharge,
							displayValue: totalcharge
						}
					];
				} else if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue == "TAX Exempt") {
					totalcharge = parseFloat(oneOff * 1).toFixed(2);
					netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
					netPriceExcGST = parseFloat(netPriceIncGST / 1).toFixed(2);
					totalchargeExcGST = parseFloat(totalcharge / 1).toFixed(2); //Added: EDGE-190802
					updateMap[mobSubsConfigGUID] = [
						{
							name: "OneOffChargeGST",
							showInUi: false,
							value: "NA",
							displayValue: "NA"
						}
					];
				}
				let keys = Object.keys(updateMap);
				var complock = comp.commercialLock;
				if (complock) comp.lock("Commercial", false);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
				if (complock) {
					comp.lock("Commercial", true);
				}
				if (fundRedeemed > totalchargeExcGST * quant) { //EDGE-190802: Modified totalcharge to totalchargeExcGST
					debitFundCheck = true;
				} else if (fundRedeemed < 0) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "Please Put the Valid Amount";
					return Promise.resolve(false);
				}
				if (!debitFundCheck && fundRedeemed >= 0) {
					basketRedemp = window.basket + fundRedeemed;
					window.basket = basketRedemp;
					if (currentFundBalance - basketRedemp < 0) {
						basketRedemp = window.basket - fundRedeemed;
						netPriceIncGST = totalcharge;
						let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
						cnfg.status = false;
						cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
						return Promise.resolve(false);
					} else {
						window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
					}
				} else {
					netPriceIncGST = totalcharge;
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
					return Promise.resolve(false);
				}
				if (redeemcheckNeeded && redeemcheckNeeded.value && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = true;
				} else {
					if (fundRedeemed != 0) {
						let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
						cnfg.status = false;
						cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
						return Promise.resolve(false);
					}
				}
				window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
				if (mobSubsConfigGUID !== "") {
					updateConfigMap[mobSubsConfigGUID] = [
						{
							name: "BasketRedemptionAmount",
							value: window.basket,
							displayValue: window.basket
						},
						{
							name: "TotalFundAvailable",
							value: currentFundBalance,
							displayValue: currentFundBalance
						},
						{
							name: "FundAvailable",
							value: deductBalanceConfig,
							displayValue: deductBalanceConfig
						},
						{
							name: "NetPriceIncGST",
							value: netPriceIncGST,
							displayValue: netPriceIncGST
						},
						{
							name: "NetPriceExcGST",
							value: netPriceExcGST,
							displayValue: netPriceExcGST
						}
					];
					let keys = Object.keys(updateConfigMap);
					var complock = comp.commercialLock;
					if (complock) comp.lock("Commercial", false);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
					if (complock) {
						comp.lock("Commercial", true);
					}
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = true;
					return Promise.resolve(true);
				}
			}
		});
	}
};
/**************************************************************************************
 * Author	   : Romil Anand
 * Method Name : populatebasketAmountCommon
 * Invoked When: attribute update,before and on loading of saving the solution
 * Description : Populate the values in Subscription level
 * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
const populatebasketAmountCommon = (comp) => {
	if (basketChangeType === "Change Solution") {
		return;
	}
	let updateConfigMap = {};
	var mobSubsConfigGUID = "";
	if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
			if (!subsConfig.id || subsConfig.id === "" || subsConfig.id === null) {
				var fundRedeemed = 0,
					netPriceIncGST = 0,
					oneOff = 0,
					debitFundCheck = false,
					quant = 0,
					netPriceExcGST = 0,
					totalcharge = 0,
					totalchargeExcGST = 0;  //Added: EDGE-190802
				mobSubsConfigGUID = subsConfig.guid;
				var redeemcheckNeeded = subsConfig.getAttribute("IsRedeemFundCheckNeeded");
				var onceOffCharge = subsConfig.getAttribute("OneOffCharge");
				if (onceOffCharge) {
					if (onceOffCharge.displayValue) oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
				} else {
					onceOffCharge = subsConfig.getAttribute("OC");
					if (onceOffCharge && onceOffCharge.displayValue) oneOff = parseFloat(onceOffCharge.displayValue).toFixed(2);
				}
				var quantity = subsConfig.getAttribute("Quantity");
				if (quantity && quantity.displayValue) quant = Math.trunc(quantity.displayValue);
				var RedeemFund = subsConfig.getAttribute("RedeemFund");
				if (RedeemFund && RedeemFund.displayValue) fundRedeemed = parseFloat(RedeemFund.displayValue);
				fundRedeemed = Math.round(fundRedeemed * 100) / 100;
				var taxtreatment = subsConfig.getAttribute("taxTreatment");
				{
					var updateMap = [];
					if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "GST Applicable") {
						totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
						netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
						netPriceExcGST = parseFloat(netPriceIncGST / 1.1).toFixed(2);
						totalchargeExcGST = parseFloat(totalcharge / 1.1).toFixed(2); //Added: EDGE-190802
						updateMap[mobSubsConfigGUID] = [
							{
								name: "OneOffChargeGST",
								showInUi: true,
								value: totalcharge,
								displayValue: totalcharge
							}
						];
					} else if (taxtreatment && taxtreatment.displayValue && taxtreatment.displayValue === "TAX Exempt") {
						totalcharge = parseFloat(oneOff * 1).toFixed(2);
						netPriceIncGST = parseFloat(totalcharge * quant - fundRedeemed).toFixed(2);
						netPriceExcGST = parseFloat(netPriceIncGST / 1).toFixed(2);
						totalchargeExcGST = parseFloat(totalcharge / 1).toFixed(2); //Added: EDGE-190802
						updateMap[mobSubsConfigGUID] = [
							{
								name: "OneOffChargeGST",
								showInUi: false,
								value: "NA",
								displayValue: "NA"
							}
						];
					}
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}
				if (fundRedeemed > totalchargeExcGST * quant) { //EDGE-190802: Modified totalcharge to totalchargeExcGST
					debitFundCheck = true;
				} else if (fundRedeemed < 0) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "Please Put the Valid Amount";
					return Promise.resolve(false);
				}
				if (!debitFundCheck && fundRedeemed >= 0) {
					basketRedemp = window.basket + fundRedeemed;
					window.basket = basketRedemp;
					if (currentFundBalance - basketRedemp < 0) {
						basketRedemp = window.basket - fundRedeemed;
						netPriceIncGST = totalcharge;
						let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
						cnfg.status = false;
						cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
						return Promise.resolve(false);
					} else {
						window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
					}
				} else {
					netPriceIncGST = totalcharge;
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = false;
					cnfg.statusMessage = "You can not redeem amount greater than Charge amount and Available TEPF Balance";
					return Promise.resolve(false);
				}
				if (redeemcheckNeeded && redeemcheckNeeded.value && (redeemcheckNeeded.value === false || redeemcheckNeeded.value === "false")) {
					let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
					cnfg.status = true;
				} else {
					if (fundRedeemed != 0) {
						let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
						cnfg.status = false;
						cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
						return Promise.resolve(false);
					}
				}
				window.deductBalanceConfig = parseFloat(currentFundBalance - basketRedemp).toFixed(2);
				if (mobSubsConfigGUID !== "") {
					updateConfigMap[mobSubsConfigGUID] = [
						{
							name: "BasketRedemptionAmount",
							value: window.basket,
							displayValue: window.basket
						},
						{
							name: "TotalFundAvailable",
							value: currentFundBalance,
							displayValue: currentFundBalance
						},
						{
							name: "FundAvailable",
							value: deductBalanceConfig,
							displayValue: deductBalanceConfig
						},
						{
							name: "NetPriceIncGST",
							value: netPriceIncGST,
							displayValue: netPriceIncGST
						},
						{
							name: "NetPriceExcGST",
							value: netPriceExcGST,
							displayValue: netPriceExcGST
						}
					];
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
					return Promise.resolve(true);
				}
			}
		});
	}
};