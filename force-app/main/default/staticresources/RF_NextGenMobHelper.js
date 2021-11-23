/********************************************************************************************************************************************
Sr.No. Author 		 Date			Sprint   	  Story number 	Description
1.	    Aman Soni	 3-June-2020	20.08(New JS) EDGE-148729	Next Generation Mobility Helper JS
2.	    Laxmi Rahate	 5-June-2020	20.09		  EDGE-150795	Enabling Order Enrichment
3.      Shubhi		 8-June-2020	20.08		  EDGE-148662	Enabling one fund and POS
4.      Aman Soni	23-June-2020	20.09		  EDGE-148667	Added EmptyRelProdAttLst,inValidateDeviceCareConfigOnEligibility,UpdateChildFromParentAtt
5.	    Ankit		26-june-2020	20.09		  EDGE-148733	Enabling Device Id on MACD
6.      Laxmi Rahate	30-Jun-2020		20.09		  EDGE-154021 	Handling OE for MAC and Cancel
7. 	    Aditya Pareek 15-July-20 	20.09		  EDGE-148738	Change Type is not updating for Main Solution on MAC
8.      Aman Soni	 20-July-2020	20.10		  EDGE-154026 	Added Code for Next Gen Plan
9.      Aman Soni	 20-July-2020	20.10		  EDGE-154028 	Added Code for Next Gen Plan
10.     Aman Soni	 20-July-2020	20.10		  EDGE-154029 	Added Code for Next Gen Plan
11.     Aman Soni	 20-July-2020	20.10		  EDGE-154238 	Added Code for Next Gen Plan
12.	    Laxmi Rahate	 27-July-2020	20.10 		  EDGE-154663   Added generic method for gettign attribute Value
13      Laxmi Rahate  30-July-2020   20.10		  EDGE-154680	MAC for Mobility Features
14.     Arinjay       20-Jul-2020   20.10          EDGE-164211   Spring 20 Upgrade
15      Ankit/Shubhi/aditya/aman  25/08/2020   20.11     post upgrade js upliftment
16      Shubhi /samish             28-july-2020    20.12          //EDGE-165013
17.     Shubhi/Hitesh 28.July.2020   20.12       EDGE-157919,EDGE-157747,EDGE-157745
18.     Shubhi        28.July.2020   20.12       EDGE-157797(Ir Month Pass)
19.     Gnana         31-Aug-2020    20.12       EDGE-154688 NGEM Plan Cancel
20.     Aman Soni     31-Aug-2020    20.12       EDGE-157745 	DefaultMsgBank
21.     Aman Soni     31-Aug-2020    20.12       EDGE-157745 	DefaultBDD
22.  	Aman Soni     31-Aug-2020    20.12       EDGE-160039 	RoundingOffAttribute
23.	    Laxmi 		 04-Sep-2020	20.12		EDGE-154696     Applecare Cancellation
24.   	Aarathi/Manish    04 Sept 2020   20.12           EDGE-164351    AppleCare Cancellation
25. 	Arinjay Singh	22-Sept-2020	20.13						JS Refactoring
26.		Aman Soni	  24/09/2020	20.13		 EDGE-164619 	Added by Aman Soni
27.		Aman Soni     7-Oct-2020    20.14		EDGE-182492     Commented by Aman Soni for bug(EDGE-182492)	
28.		Aman Soni     13-Oct-2020   20.14		EDGE-173469     Added getSyncTransitionDevice() for Sync Transition Device Functionality
29.     Aditya		 07.10.2020		20.14		EDGE-170011 	Removal of "Use Existing SIM" check box
30.     Shubhi       2/Nov/2020     20.14		EDGE-187727		 MACD basket || change type is blank
31.     Aman Soni	 03.11.2020		20.15		EDGE-186968		Added for Offer id fix for Device Care
32.		Aditya		 04.11.2020		20.15		EDGE-173696		MAC for Transition Device 
33.    Shweta       4/11/202                      EDGE-185652
34.     Pooja Bhat      5/11/2020	20.15       EDGE-175750
35.     Pallavi D    26.11.2020     20.15       EDGE-191285 Added a fix for charactor length issue in PC Name field.
36.     Pallavi D    28.11.2020     20.15       EDGE-191285 Added a fix for charactor length issue in PC Name field.
37.     Jagadeswary  		25/11/2020		    EDGE-188712 - method for calculating ETC for AM	
38.		shubhi V      17/12/2020    20.16      EDGE-185011
39.     Shubhi V		4/01/2020   20.17      INC000094689212 /EDGE-196285
40.     Krunal Taak    13/01/2021   20.16      Added updateConfigName_AccessoryperConfig and updateConfigName_AccessoryAllConfig
41.		Akanksha 	 30/11/2020		20.16		EDGE-170544 Added to code in setNextGenEMTabsVisibility to make MF tab read only for Inflight basket
42.		Aman Soni 	 25/01/2021		21.02		EDGE-191077 Transfer Hardware UX Enhancements 
43.     Krunal Taak  08/02/2021     21.02       DPG-4250    Making conditional mandatory for Accessory/Device/Transition Device
44.		Mahima Gandhe	   05/02/2021		21.02	 DPG- 4154, 4071, Added Mobile Device care for Accessory
45.     Krunal Taak      17/02/2021      21.03     Changes in 'CalculationforDeviceCompAtts'
46.     Hitesh Gandhi    01/03/2021      21.03    EDGE-200723 Added method addDeliveryDetails and deleteDeliveryDetails
47.		Aman Soni	17/02/2021		21.03		EDGE-203220
48.     Krunal Taak  24/02/2021     21.03       DPG-4509
49. 	Mahima/Monali  02/03/2021	21.03		DPG-3889, 4083
50.     Krunal Taak    18/03/2021   21.03       DPG-4725 - Model Name trim to 70 characters for Mobile Accessory (INC000095314671)
51.		Akanksha		26/03/2021  21.04      EDGE-211680 added Existing Active SIM value in DeleteDeliveryDetails_MAC method
52.		Aman Soni		12/04/2021  21.05      EDGE-207355 validate BAN on configurations in case of Migration Journey
53. 	Mahima 			20/04/2021	21.06		DPG-5235-Transition Accessory Trim logic for Config name
54.	Shubhi V		27/04/2021	21.06		EDGE-212647
55. Monali M         20/05/2021    21.07     DPG-5295 - Featch APN details with accountid
56.  		Mahima G		14/06/2021		21.08	 DPG- 5776 - Soft delete/Cancel for Accelerator MAC
57.  Mahima G		14/06/2021		21.08	 Soft delete/Cancel for APN MAC
58.		Antun B			07/06/2021	21.06		EDGE-198536 performance improvements
59.     Krunal Taak     09/06/2021  21.08      DPG-5621
60.     Monali Mukherjee 09/06/2021 21.08   DPG-5626 Enabling Device Id and Purchase Order No on MACD
61.		Aman Soni		24/06/2021	21.09		Remove ChangeType on Main component of Adaptive Mobility solution for EDGE-224779
62. 	Aman Soni      08/07/2021   21.09		INC000096625009  Added replacedConfigId and disabled checks
63.     Krunal Taak    12/07/2021   21.09       DPG-6099 - Change type and Reedem Attribute issue
64.     Ila A Verma    14/07/2021   21.09       DPG -6180 : Hide Show Attributes for Transition Accessory 
65. 	Mahima G	   07/07/2021	21.08		TON Disconnect
66.     Monali Mukherjee     01/07/2021     21.09       DPG-5731
65.     shubhi V		15/07/2021	21.10 		DIGI-1853
66.		Aditya 	P 		10/08/2021	21.11	DIGI-11546
67.     Krunal Taak     10/13/2021  21.15   DIGI-26615 - Handling Promotions Special Scenario
68. 	Shubhi V		10/22/2021  21.14	INC000097831064
69. Riya Anna Sunny     04/10/2021  21.12     R34UPGRADE
70. 	Mahima 			11/3/2021	21.15	Passed newValue as parameter in SoftdeleteBoltonMethod- DIGI-37564 - Mahima  
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/
console.log(':::::: Next Generation Mobility Helper resource ::::::');
var showMsg = true;
var pricingRuleGroupCode;
var NextGenMobHelper = {
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : MandateCompBasedOnOfferName
	 * Invoked When: Offer Name is updated
	 * Sprint	   : 20.10 (EDGE-154026)
         * Parameters  : NA
	 ************************************************************************************/
	MandateCompBasedOnOfferName: async function(){
		let offerId;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			let solutionConfigs = solution.getConfigurations();
			if (solutionConfigs){
				Object.values(solutionConfigs).forEach((solConfig) => {
					offerId = solConfig.getAttribute("OfferId");
				});
			}

			if(offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId){
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenPlan, 1, 9999);
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenDevice, 0, 9999);
				solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 0, 9999);
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenAccessory, 0, 9999);//Added by Krunal Taak for DPG-4250
				solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 0, 9999);//Added by Mahima for DPG-3889

				

			}

			if(offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId){
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenDevice, 1, 9999);
				solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 1, 9999);
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenPlan, 0, 9999);
				solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenAccessory, 1, 9999);//Added by Krunal Taak for DPG-4250
				solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 1, 9999);//Added by Mahima for DPG-3889
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : InValidateNGEMPlan
	 * Invoked When: Before Configuration Add
	 * Sprint	   : 20.10 (EDGE-154026)
	 * Parameters  : guid
	 ************************************************************************************/
	InValidateNGEMPlan: async function (guid) {
		var offerName;
		var offerId;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			let solutionConfigs = solution.getConfigurations();
			if (solutionConfigs) {
				Object.values(solutionConfigs).forEach((solConfig) => {
					offerId = solConfig.getAttribute("OfferId");
				});
			}
			let comp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
			if (comp && offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId) {
				let configs = comp.getConfigurations();
				Object.values(configs).forEach(async (config) => {
					config.status = false;
					config.statusMessage = "You have selected a Device Only offer. Device only offers cannot contain Mobile Subscriptions";
				});
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : InValidateNGEMPlanOnOfferChange
	 * Invoked When: Before Configuration Add
	 * Sprint	   : 20.10 (EDGE-154026)
	 * Parameters  : guid
	 ************************************************************************************/
	InValidateNGEMPlanOnOfferChange: async function (guid) {
		var offerId;
		var solConfigId;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			let config = solution.getConfiguration(guid);
			if (config) {
				offerId = config.getAttribute("OfferId");
				let comp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
				if (comp) {
					if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId) {
						let compConfigs = comp.getConfigurations();
						Object.values(compConfigs).forEach((compConfig) => {
							compConfig.status = false;
							compConfig.statusMessage = "You have selected a Device Only offer. Device only offers cannot contain Mobile Subscriptions";
						});
					} else if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId) {
						let compConfigs = comp.getConfigurations();
						Object.values(compConfigs).forEach((compConfig) => {
							compConfig.status = true;
							compConfig.statusMessage = "";
						});
					}
				}
			}
		}
	},
	/************************************************************************************
	 * Author	  : Aman Soni
	 * Method Name : EmptyRelProdAttLst - To Empty Related Product Attributes on parent component attribute changes
	 * Invoked When: related product is added
	 * Sprint	  : 20.09 (EDGE-148667)
	 * Parameters  : mainCompName, componentName, relatedCompName, attrList
	 ***********************************************************************************/
	EmptyRelProdAttLst: async function (guid, mainCompName, componentName, relatedCompName, attrList) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				Object.values(configs).forEach((config) => {
					if (config.guid) {
						if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
							Object.values(config.relatedProductList).forEach((relatedConfig) => {
								if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid === guid) {
									if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.guid) {
										NextGenMobHelper.EmptyAttributeLst(relatedConfig.configuration.guid, componentName, attrList);
									}
								}
							});
						}
					}
				});
			}
		}
	},
	/************************************************************************************
	 * Author	  : Aman Soni
	 * Method Name : EmptyAttributeLst
	 * Invoked When: multiple occurrences
	 * Parameters  : guid, componentName, attributeList
	 * EDGE-198536: reimplemented and introduced skipHooks parame
	 ***********************************************************************************/
	 EmptyAttributeLst: async function (guid, componentName, attributeList, skipHooks = true) {
        //EDGE-197578 skipHooks defaulted to true
        //EDGE-198536 Start reimplemented as old implementation wasn't bulkified
		if (guid && componentName && attributeList) {
            let solution = await CS.SM.getActiveSolution();
            let component = await solution.getComponentByName(componentName);
            let updateAttEmptyMap = {};
			updateAttEmptyMap[guid]=[];
			for (var attributeName of attributeList) {
				updateAttEmptyMap[guid].push({
					name:  attributeName,
					value: ''
				});
			}
			if (updateAttEmptyMap && updateAttEmptyMap[guid]) {
				await component.updateConfigurationAttribute(guid, updateAttEmptyMap[guid], skipHooks);
			}
		}
        return Promise.resolve(true);
        //EDGE-198536 End	
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : HideShowAttLst_MainSolution
	 * Invoked When: on attribute update
	 * Parameters  : mainCompName,attributeList
	 ***********************************************************************************/
	HideShowAttLst_MainSolution: async function(mainCompName,attributeList){
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(mainCompName)){
			let configs = solution.getConfigurations();
			if (configs){
				Object.values(configs).forEach((solConfig) => {
					if (solConfig.guid && solConfig.replacedConfigId){
						if(window.BasketChange === 'Change Solution') ////// EDGE-170016
						//NextGenMobHelper.HideShowAttributeLst(true, false, solConfig.guid, mainCompName, "", "", NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL10, false, true, false);//Commented for EDGE-224779 by Aman Soni
						NextGenMobHelper.ReadOnlyMarketableOffer(mainCompName, solConfig.guid);  
					}
				});
			}
		}
	},
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : HideShowAttLst_NGEMDevice
 * Invoked When: on attribute update
 * Parameters  : guid, mainCompName, componentName, attributeList
 ***********************************************************************************/
HideShowAttLst_NGEMDevice: async function (guid, mainCompName, componentName, attributeList) {
    console.log("Inside Next Generation Mobility afterAttributeUpdated -- Helper---"+mainCompName+'---'+componentName);
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)){
			let configs = solution.getConfigurations();
			var updateMap = {};
			let compNextGenDevice = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
			let compNextGenAccessory = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenAccessory);
				//Block used to do manipulations/calling methods for Parent Component - 'Device' || Start
                    if (compNextGenDevice && componentName === NXTGENCON_COMPONENT_NAMES.nextGenDevice) {
                        console.log("Inside Next Generation Mobility afterAttributeUpdated -- Device"+compNextGenAccessory);
						let compConfigs = compNextGenDevice.getConfigurations();
						Object.values(compConfigs).forEach((config) => {
							if (config.guid === guid){
									let payTypeLookup = config.getAttribute("PaymentTypeString");
									let manufacturer = config.getAttribute("MobileHandsetManufacturer");
									let color = config.getAttribute("MobileHandsetColour");
									let devType = config.getAttribute("Device Type");
									let inContractDevEnrElig = config.getAttribute("InContractDeviceEnrollEligibility");
									let ChangeTypeAtr = config.getAttribute("ChangeType");
									let RemainingTermVal = config.getAttribute("RemainingTerm");
									let model = config.getAttribute("MobileHandsetModel");
									
                                        if (payTypeLookup && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== '' && payTypeLookup.displayValue === 'Hardware Repayment') {
											if (!config.replacedConfigId){
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[0], false, false, false);	
											}                                           
                                            //NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[1], true, true, false);
                                           // NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[4], false, false, false);
                                           // NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[2], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[5], false, true, true);
                                        }
										
                                        if (payTypeLookup && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== '' && payTypeLookup.displayValue === 'Purchase') {
                                            

                                            //NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[1], true, false, false);
											if (!config.replacedConfigId){
												NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[0], false, true, false);
											}                                            
                                           // NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[2], false, false, false);
                                            //NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[3], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'',attributeList[5], false, false, false);
                                        }
                                        if ((manufacturer && manufacturer.value === '') || (model && model.value === '') || (color && color.value === '') || (devType && devType.value === '') || (payTypeLookup && payTypeLookup.value === '')) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[7], false, false, false);
                                        }
                                        if (!config.replacedConfigId) {
                                            if (payTypeLookup && payTypeLookup.value !== '' && payTypeLookup.value !== null && payTypeLookup.value !== undefined) {
                                                if (inContractDevEnrElig.value !== '' && inContractDevEnrElig.value !== null) {
                                                    if (inContractDevEnrElig.value === 'Eligible') {
													NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], false, true, false);
                                                    } else {
                                                        NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], true, true, false);
                                                    }
                                                } else {
                                                    NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[6], true, false, false);
                                                }
                                            }
                                        }
                                        if (payTypeLookup && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== '' && payTypeLookup.displayValue === 'Hardware Repayment' && config.replacedConfigId) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[13], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
                                        }
                                        if (config.replacedConfigId && payTypeLookup && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== '' && payTypeLookup.displayValue === 'Purchase') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[15], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false); //Added by ankit as part of EDGE-148733 
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[11], true, true, false);
                                        }
                                        if (config.replacedConfigId && payTypeLookup && payTypeLookup.displayValue === 'Hardware Repayment' && ChangeTypeAtr.displayValue === 'Cancel') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[16], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[17], false, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[49], true, false, false);

                                        }
										// EDGE-197578 Start
										if (config.replacedConfigId && payTypeLookup && payTypeLookup.displayValue === 'Hardware Repayment' && ChangeTypeAtr.displayValue === 'No Fault Return') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[44], false, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[45], true, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[46], true, false, false);
										}
										if (config.replacedConfigId && payTypeLookup && payTypeLookup.displayValue === 'Purchase' && ChangeTypeAtr.displayValue === 'No Fault Return') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[44], false, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[46], true, false, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[48], true, true, false);
										}
										// EDGE-197578 End
                                        if (config.replacedConfigId && ChangeTypeAtr.displayValue === 'Active' && RemainingTermVal.displayValue === null) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[12], true, true, false);
                                        }
                                        if (config.replacedConfigId) {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[10], false, true, false);
                                        }
                                        if (config.replacedConfigId && ChangeTypeAtr.displayValue === 'PaidOut') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[47], true, false, false);
                                        }
										

                                        //Block used to do manipulations/calling methods for Parent Component - 'Device' || End

                                        //Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
                                        if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                                            Object.values(config.relatedProductList).forEach((relatedConfig) => {
												var ChildChangeTypeAtr = relatedConfig.configuration.getAttribute("ChangeType");
                                                if (relatedConfig.guid && relatedConfig.configuration.replacedConfigId !== '' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                                                    NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
													// EDGE-197578 Start
													if(ChildChangeTypeAtr.displayValue!= 'PaidOut' && ChangeTypeAtr.displayValue == 'No Fault Return' )	{
														 NextGenMobHelper.updatechildAttfromParent('ChangeType', 'No Fault Return', true, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
														 NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[49], true, true, false);
														 NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[30], true, false, false);
														}
														else if(ChildChangeTypeAtr.displayValue!= 'PaidOut' && (ChangeTypeAtr.displayValue == 'Cancel' || ChangeTypeAtr.displayValue == 'PaidOut') ){
															NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Active', true, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
															NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Cancel', false, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
															NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[49], true, false, false);
															NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[30], true, true, false);

														}

														// EDGE-197578 End

														
                                                }
                                            });
                                        }
                                    //Block used to do manipulations for Related Component - 'Mobile Device Care' || End
                                }
                            });
                    }
					//Block used to do manipulations/calling methods for Parent Component - 'Accessory' || Start
					if (compNextGenAccessory  && componentName === NXTGENCON_COMPONENT_NAMES.nextGenAccessory) {
                        console.log("Inside Next Generation Mobility afterAttributeUpdated -- Accessory Helper");
						let compConfigs = compNextGenAccessory.getConfigurations();
						Object.values(compConfigs).forEach((config) => {
							if (config.guid === guid){
									let paymentTypeLookup = config.getAttribute("PaymentTypeShadow"); //Ila
									let ChangeTypeAtr = config.getAttribute("ChangeType");
									    if (paymentTypeLookup.displayValue === null || paymentTypeLookup.displayValue === '') {
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[39], false, false, false); //All Hide
                                        }
        								//Ila/Krunal - DPG-3358 //&& ChangeTypeAtr.displayValue === 'Cancel' - DPG-6099
										  if (paymentTypeLookup && paymentTypeLookup.displayValue !== null && paymentTypeLookup.displayValue !== '' && paymentTypeLookup.displayValue === 'Hardware Repayment' && ChangeTypeAtr.displayValue !== 'Cancel') {
                                         
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[36], false, true, false); //HRO Show
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[37], false, false, false); //HRO Hide
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[38], false, true, true); //Contract Term Show and Mandatory
											//Commented below line Prod incident fix- INC000095245663- Mahima 
                            				//NextGenMobHelper.UpdateAttValueOnHide(guid, mainCompName, componentName, 'OC', 0); //Set OC to 0
											NextGenMobHelper.UpdateAttValueOnHide(guid, mainCompName, componentName, 'RedeemFund',0); //Set RedeemFund value to 0
                                        }

										//Ila/Krunal - DPG-3358
										 if (paymentTypeLookup && paymentTypeLookup.displayValue !== null && paymentTypeLookup.displayValue !== '' && paymentTypeLookup.displayValue === 'Purchase') {
                                            
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[34], false, true, false); //Purchase Show
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[35], false, false, false); //Purchase Hide
											NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[38], false, false, false); //Contract Term Hide and Non Mandatory
											NextGenMobHelper.UpdateAttValueOnHide(guid, mainCompName, componentName, 'RC', 0); //Set RC to 0
											NextGenMobHelper.UpdateAttValueOnHide(guid, mainCompName, componentName, 'ContractTerm', 0);//Set ContractTerm to 0
                                        }
                                        //--krunal DPG-5621
										if (config.replacedConfigId && paymentTypeLookup && paymentTypeLookup.displayValue === 'Hardware Repayment' && ChangeTypeAtr.displayValue === 'Cancel') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[51], false, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[52], true, true, false);
                                        }
                        				if (config.replacedConfigId && paymentTypeLookup && paymentTypeLookup.displayValue === 'Hardware Repayment' && ChangeTypeAtr.displayValue === 'Active') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[51], false, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[52], false, true, false);
                                        }
										if (config.replacedConfigId && ChangeTypeAtr.displayValue === 'PaidOut') {
                                            NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[53], true, true, false);
                                        }
                                        //--krunal DPG-5621
                                }
                            });
                    }
					//Block used to do manipulations/calling methods for Parent Component - 'Accessory' || END
        }
    },	
/************************************************************************************
 * Author	  : Aman Soni
 * Method Name : HideShowAttLst_NGEMPlan
 * Invoked When: on attribute update
 * Parameters  : guid, mainCompName, componentName, attributeList
***********************************************************************************/
HideShowAttLst_NGEMPlan: async function (guid, mainCompName, componentName, attributeList) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)){
		let configs = solution.getConfigurations();
		var updateMap = {};
		let compNextGenPlan = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
                        if(compNextGenPlan){
							let compConfigs = compNextGenPlan.getConfigurations();
                                Object.values(compConfigs).forEach((planConfig) => {
                                    if(planConfig.guid === guid){
                                        let planTypeLookUp = planConfig.getAttribute("SelectPlanType");
										let ChangeTypeAtr = planConfig.getAttribute("ChangeType");
										
										if(planTypeLookUp.displayValue===NGEMPLans.Enterprise_Wireless){
						 					//NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[30], true, false, false);
										}
										if(planTypeLookUp.displayValue === NGEMPLans.Handheld || planTypeLookUp.displayValue === NGEMPLans.Mobile_Broadband){
											//NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[30], true, true, false);
										}
                                        if(planConfig.guid && planConfig.replacedConfigId !== '' && planConfig.replacedConfigId !== undefined && planConfig.replacedConfigId !== null && ChangeTypeAtr.displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[18], true, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[10], false, true, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[23], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[25], false, true, false);
                                        }
										// Added below block as part of EDGE-154688 - Start
                                        if(planConfig.replacedConfigId && ChangeTypeAtr.displayValue === 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[20], false, true, true);
                                            //NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[21], true, false, false);
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[22], true, true, false);
                                        }
						// Added below block as part of EDGE-170422 - Start
						if (planConfig.replacedConfigId && window.basketRecordType ==='Inflight Change') {
							NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, '', attributeList[22], true, true, false);
						}
						// Added block as part of EDGE-170422 - End
                                        if(planTypeLookUp.displayValue===NGEMPLans.Enterprise_Wireless && planConfig.replacedConfigId){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,'', attributeList[25], true, true, false);
                                        }
                                        if (planConfig.relatedProductList && Object.values(planConfig.relatedProductList).length > 0) {
                                            Object.values(planConfig.relatedProductList).forEach((relatedConfig) => {
                                                if(relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.dataFeatures) && relatedConfig.guid){
                                                    if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
                                                        if(planTypeLookUp.displayValue === NGEMPLans.Enterprise_Wireless){
                                                            NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[27], true, false, false);
															NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[26], false, true, false);
															//NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[29], true, true, false);
															//NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[28], true, false, false);
                                                        }
                                                    if(planTypeLookUp.displayValue === NGEMPLans.Handheld || planTypeLookUp.displayValue === NGEMPLans.Mobile_Broadband){
                                                    NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[26], true, false, false);
													NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[27], false, true, false);

													//NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[28], true, false, false);
													//NextGenMobHelper.HideShowAttributeLst(false, true, planConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[29], true, true, false);

                                                }
                                            }
                                        }
                                            });
                                        }

                                    }

                                    
                                });
                        }
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End
        }
	},
	/************************************************************************************
 * Author	  : Aditya Pareek
 * Method Name : HideShowAttLst_TransDevice
 * Invoked When: on attribute update
 * Parameters  : guid, mainCompName, componentName, attributeList
***********************************************************************************/
HideShowAttLst_TransDevice: async function (guid, mainCompName, componentName, attributeList) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)){
		let configs = solution.getConfigurations();
		var updateMap = {};
		let compTransitionDevice = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.transitionDevice);
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
                        if(compTransitionDevice){
							let compConfigs = compTransitionDevice.getConfigurations();
                                Object.values(compConfigs).forEach((transdeviceConfig) => {
                                    if(transdeviceConfig.guid === guid){
										let ChangeTypeAtr = transdeviceConfig.getAttribute("ChangeType");
										// Added below block as part of EDGE-154688 - Start
                                        if(transdeviceConfig.replacedConfigId && ChangeTypeAtr.displayValue === 'Cancel'){
											NextGenMobHelper.HideShowAttributeLst(false, false, transdeviceConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice,'', attributeList[32], true, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, transdeviceConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice,'', attributeList[33], true, false, false);
										}
										if(transdeviceConfig.replacedConfigId && ChangeTypeAtr.displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, transdeviceConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice,'', attributeList[32], true, false, false);
										}
										if(transdeviceConfig.replacedConfigId && ChangeTypeAtr.displayValue === 'PaidOut'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, transdeviceConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice,'', attributeList[33], true, false, false);
                                        }
                                        // Added block as part of EDGE-154688 - End

                                    }

                                    
                                });
                        }
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End
        }
    },

	/************************************************************************************
	 * Author	  : Aman Soni
	 * Method Name : HideShowAttributeLst
	 * Invoked When: multiple occurrences
	 * Parameters  : guid, mainCompName, componentName, attributeList, IsreadOnly, isVisible, isRequired
	 ***********************************************************************************/
	HideShowAttributeLst: async function (IsMain, IsRelated, guid, mainCompName, componentName, relatedproductName, attributeList, IsreadOnly, isVisible, isRequired) {
		let product = await CS.SM.getActiveSolution();
		var componentMapNextGen = new Map();
		var componentMapattrNextGen = {};
		//Block used to do manipulations for Main Solution Component - 'Next Generation Enterprise Mobility' || Start
		if (IsMain && !IsRelated && product.name === mainCompName) {
			let config = await product.getConfiguration(guid);
			if (config) {
				for (var i = 0; i < attributeList.length; i++) {
					componentMapattrNextGen[attributeList[i]] = [];
					componentMapattrNextGen[attributeList[i]].push({
						IsreadOnly: IsreadOnly,
						isVisible: isVisible,
						isRequired: isRequired
					});
				}
				componentMapNextGen.set(guid, componentMapattrNextGen);
			}
			CommonUtills.attrVisiblityControl(mainCompName, componentMapNextGen, activeNGEMSolution);
		}
		//Block used to do manipulations for Main Solution Component - 'Next Generation Enterprise Mobility' || End

		//Block used to do manipulations for Parent Component - 'Device' || Start
		if (!IsMain && !IsRelated && product.name === mainCompName) {
            console.log('--componentName--'+componentName);




			let comp = await product.getComponentByName(componentName);
			if (comp) {
				let config = await comp.getConfiguration(guid);




                console.log('--config--'+config);
				if (config) {
                    console.log('--Ifconfig--'+attributeList);
					for (var i = 0; i < attributeList.length; i++) {
						componentMapattrNextGen[attributeList[i]] = [];
						componentMapattrNextGen[attributeList[i]].push({
							IsreadOnly: IsreadOnly,
							isVisible: isVisible,
							isRequired: isRequired
						});
					}
					componentMapNextGen.set(guid, componentMapattrNextGen);
					CommonUtills.attrVisiblityControl(componentName, componentMapNextGen, activeNGEMSolution);
				}
			}
		}
		//Block used to do manipulations for Parent Component - 'Device' || End

		//Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
		if (!IsMain && IsRelated && product.name === mainCompName) {
			let comp = await product.getComponentByName(componentName);
			if (comp) {
				let config = await comp.getConfiguration(guid);
				if (config) {
					if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
						Object.values(config.relatedProductList).forEach((relatedConfig) => {
							if (relatedConfig.name.includes(relatedproductName) && relatedConfig.guid) {
								for (var i = 0; i < attributeList.length; i++) {
									componentMapattrNextGen[attributeList[i]] = [];
									componentMapattrNextGen[attributeList[i]].push({
										IsreadOnly: IsreadOnly,
										isVisible: isVisible,
										isRequired: isRequired
									});
								}
								componentMapNextGen.set(relatedConfig.guid, componentMapattrNextGen);
							}
						});
					}
				}
				CommonUtills.attrVisiblityControl(componentName, componentMapNextGen, activeNGEMSolution);
			}
		}
		//Block used to do manipulations for Related Component - 'Mobile Device Care' || End
	//hitesh EDGE-174694 added to do manipulations for related component -'International Roaming Month Pass' || start
	if (!IsMain && IsRelated && product.name === mainCompName) {
		if (product.components && Object.values(product.components).length > 0) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						let config = comp.getConfiguration(guid);
						if (config){
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach((relatedConfig) => {
									if (relatedConfig.name.includes(relatedproductName) && relatedConfig.guid) {
                                    console.log(relatedproductName+'--'+attributeList[0]);
										for (var i = 0; i < attributeList.length; i++) {
											componentMapattrNextGen[attributeList[i]] = [];
											componentMapattrNextGen[attributeList[i]].push({
												IsreadOnly: IsreadOnly,
												isVisible: isVisible,
												isRequired: isRequired
											});
										}
										componentMapNextGen.set(relatedConfig.guid, componentMapattrNextGen);
									}
								});
							}
							
						}
					}
					CommonUtills.attrVisiblityControl(componentName, componentMapNextGen);
				}
			}
		}//Block used to do manipulations for Related Component - 'International Roaming Month Pass' || End
	},
	/************************************************************************************
	 * Author	  : Aman Soni
	 * Method Name : UpdateOneAttFromAnotherAtt
	 * Invoked When: multiple occurrences
	 * Parameters  : guid, mainCompName, componentName, UpdatingAttribute, TobeUpdatedAttribute
	 ***********************************************************************************/
	UpdateOneAttFromAnotherAtt: async function (guid, mainCompName, componentName, UpdatingAttribute, TobeUpdatedAttribute) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let config = comp.getConfiguration(guid);
				if (config) {
					let updatingAtt = config.getAttribute(UpdatingAttribute);
					if (updatingAtt && updatingAtt.value !== null && updatingAtt.value !== "") {
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: TobeUpdatedAttribute,
							value: updatingAtt.value,
							displayValue: updatingAtt.displayValue
						});
					}
				}
				var complock = comp.commercialLock;
				if (complock) component.lock("Commercial", false);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
				if (complock) comp.lock("Commercial", true);
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : NGDDeviceEnrolmentOnAttUpdate
	 * Invoked When: multiple occurrences
	 * Parameters  : guid, mainCompName, componentName
	 ***********************************************************************************/
	NGDDeviceEnrolmentOnAttUpdate: async function (guid, mainCompName, componentName){
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMapNGD = {};
				let config = comp.getConfiguration(guid);
				if (config && !config.replacedConfigId) {
					let attrInContractDeviceEnrollEligibility = config.getAttribute("InContractDeviceEnrollEligibility");
					if (attrInContractDeviceEnrollEligibility) {
						if (attrInContractDeviceEnrollEligibility.value !== "" && attrInContractDeviceEnrollEligibility.value !== null) {
							if (attrInContractDeviceEnrollEligibility.value === "Eligible") {
								updateMapNGD[config.guid] = [
									{
										name: "DeviceEnrollment",
										value: "DO NOT ENROL",
										displayValue: "DO NOT ENROL",
										required: true,
										showInUI: true,
										readOnly: false,
										options: [CommonUtills.createOptionItem("ENROL"), CommonUtills.createOptionItem("DO NOT ENROL")] //R34UPGRADE
									}
								];
							} else {
								updateMapNGD[config.guid] = [
									{
										name: "DeviceEnrollment",
										value: "NOT ELIGIBLE",
										displayValue: "NOT ELIGIBLE",
										showInUi: true,
										readOnly: true,
										options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
									}
								];
							}
						} else {
							updateMapNGD[config.guid] = [
								{
									name: "DeviceEnrollment",
									value: "",
									displayValue: "",
									showInUi: false,
									readOnly: true,
									options: [CommonUtills.createOptionItem("")] //R34UPGRADE
								}
							];
						}

						var complock = comp.commercialLock;
						if (complock) comp.lock("Commercial", false);
						let keys = Object.keys(updateMapNGD);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMapNGD[keys[i]], true);
						}
						if (complock) comp.lock("Commercial", true);
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
	 * Author	  	: Aman Soni
	 * Method Name  : CalculationforDeviceCompAtts
	 * Invoked When : multiple occurences
	 * Sprint	    : 20.09 (EDGE-148667)
	 * Parameters   : mainCompName, componentName
	 ***********************************************************************************/
	CalculationforDeviceCompAtts: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid === guid) {
							let OCExGST = config.getAttribute("OC");
							let conTerm = config.getAttribute("ContractTerm");
                            let payTypeString;
                            let conTermString;
							if(componentName === NXTGENCON_COMPONENT_NAMES.nextGenAccessory){ //---added if-else by Krunal
								payTypeString = config.getAttribute("PaymentTypeShadow");
								conTermString = config.getAttribute("ContractTermShadow");
							}
							else{
								payTypeString = config.getAttribute("PaymentTypeString");
								conTermString = config.getAttribute("ContractTermString");
							}
							let OCExGSTRounded = parseFloat(OCExGST.value).toFixed(2);
							let ContTermStrValue = conTermString.value;
							let RCExGSTRounded;
							let RCIncGSTRounded;
							let OCIncGSTRounded;
							let RCExGSTFinal;
							let RCIncGSTFinal;
							let OCIncGSTFinal;

							if (payTypeString && payTypeString.value === "Hardware Repayment" && conTerm && conTerm.value !== null && conTerm.value !== "" && conTerm.value !== undefined) {
								if (OCExGSTRounded !== null && OCExGSTRounded !== "" && ContTermStrValue !== null && ContTermStrValue !== "") {
									RCExGSTRounded = OCExGSTRounded / ContTermStrValue;
									RCExGSTFinal = parseFloat(RCExGSTRounded).toFixed(2);
									if (RCExGSTFinal !== null && RCExGSTFinal !== "") {
										RCIncGSTRounded = RCExGSTFinal * 1.1;
										RCIncGSTFinal = parseFloat(RCIncGSTRounded).toFixed(2);
									}
								}
							}
							if (payTypeString && payTypeString.value === "Hardware Repayment" && (conTerm.value === null || conTerm.value === "" || conTerm.value === undefined)) {
								RCExGSTFinal = 0.0;
								RCIncGSTFinal = 0.0;
							}
							if (payTypeString && payTypeString.value === "Purchase") {
								RCExGSTFinal = 0.0;
								RCIncGSTFinal = 0.0;
								OCIncGSTRounded = OCExGSTRounded * 1.1;
								OCIncGSTFinal = parseFloat(OCIncGSTRounded).toFixed(2);
							}
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: "RC",
								value: RCExGSTFinal,
								displayValue: RCExGSTFinal
							});
							updateMap[config.guid].push({
								name: "OC",
								value: OCExGSTRounded,
								displayValue: OCExGSTRounded
							});
							updateMap[config.guid].push({
								name: "InstalmentChargeIncGST",
								value: RCIncGSTFinal,
								displayValue: RCIncGSTFinal
							});
							updateMap[config.guid].push({
								name: "OneOffChargeGST",
								value: OCIncGSTFinal,
								displayValue: OCIncGSTFinal
							});
						}
					});
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}
			}
		}
	},
	/************************************************************************************
	 * Author	  	: Aman Soni
	 * Method Name 	: CalcForDeviceCareCompAtts
	 * Invoked When	: multiple occurences
	 * Sprint	  	: 20.09 (EDGE-148667)
	 * Parameters  	: guid, mainCompName, componentName
	 ***********************************************************************************/
	CalcForDeviceCareCompAtts: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid) {
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.guid === guid) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
											let paymentType = relatedConfig.configuration.getAttribute("DeviceCarePaymentTypeLookup");
											let planType = relatedConfig.configuration.getAttribute("DeviceCarePlanLookup");
											let oc = relatedConfig.configuration.getAttribute("OC");

											let ocGST = relatedConfig.configuration.getAttribute("OneOffChargeGST");

											let OCRounded;
											if (oc && oc.value !== null && oc.value !== "") {
												OCRounded = parseFloat(oc.value).toFixed(2);
											}
											let ocGSTRounded;
											if (paymentType && paymentType.displayValue === "Purchase") {
												if (OCRounded !== null && OCRounded !== "") {
													ocGST = OCRounded * 1.1;
													ocGSTRounded = parseFloat(ocGST).toFixed(2);
												}
											}
											if (paymentType && (paymentType.displayValue === "" || paymentType.displayValue === null || paymentType.displayValue === undefined)) {
												OCRounded = 0.0;
												ocGSTRounded = 0.0;
											}
											if (planType && (planType.displayValue === "" || planType.displayValue === null || planType.displayValue === undefined)) {
												OCRounded = 0.0;
												ocGSTRounded = 0.0;
											}
											updateMap[relatedConfig.guid] = [];
											updateMap[relatedConfig.guid].push({
												name: "OC",
												value: OCRounded,
												displayValue: OCRounded
											});
											updateMap[relatedConfig.guid].push({
												name: "OneOffChargeGST",
												value: ocGSTRounded,
												displayValue: ocGSTRounded
											});
										}
									}
									let keys = Object.keys(updateMap);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
									}
								});
							}
						}
					});
				}
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : CalcforNGEMPlanCompAtts
	 * Invoked When: multiple occurences
	 * Sprint	   : 20.10 (EDGE-148667)
	 * Parameters  : mainCompName, componentName
	 ***********************************************************************************/
	CalcforNGEMPlanCompAtts: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid === guid) {
							let planName = config.getAttribute("Select Plan");
							let planType = config.getAttribute("SelectPlanType");
							let RCExGST = config.getAttribute("RC");
							let RCIncGST = config.getAttribute("RC Inc GST");
							let RCExGSTRounded = parseFloat(RCExGST.value).toFixed(2);
							let RCIncGSTRounded;

							if (RCExGSTRounded !== null && RCExGSTRounded !== "") {
								RCIncGST = RCExGSTRounded * 1.1;
								RCIncGSTRounded = parseFloat(RCIncGST).toFixed(2);
							}

							if ((planName && planName.value === "") || (planType && planType.value === "")) {
								RCExGSTRounded = 0.0;
								RCIncGSTRounded = 0.0;
							}
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: "RC",
								value: RCExGSTRounded,
								displayValue: RCExGSTRounded
							});
							updateMap[config.guid].push({
								name: "RC Inc GST",
								value: RCIncGSTRounded,
								displayValue: RCIncGSTRounded
							});
						}
					});
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : inValidateDeviceCareConfigOnEligibility
	 * Invoked When: related product is added
	 * Sprint	   : 20.09 (EDGE-148667)
	 * Parameters  : mainCompName, componentName, relatedConfigGuid
	 ***********************************************************************************/
	inValidateDeviceCareConfigOnEligibility: async function (DeviceConfigGuid, relatedguid, mainCompName, componentName) {
		var offerId;
		var offerName;
		var deviceCount;
		var planCount;
		var deviceConfig;
		var planConfig;
		var planReplaceConfig;
		var devReplaceConfig;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let configs = solution.getConfigurations();
			Object.values(configs).forEach((solConfig) => {
				if (solConfig.guid) {
					if (solConfig.attributes && Object.values(solConfig.attributes).length > 0) {
						offerName = solConfig.getAttribute("Marketable Offer");
						offerId = solConfig.getAttribute("OfferId");
					}
				}
			});
			let compNextGenDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
			//DPG-4071- Mahima
			let compNextGenAccessory= solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory);
			if (compNextGenDevice) {
				deviceCount = 0;
				let compConfigs = compNextGenDevice.getConfigurations();
				Object.values(compConfigs).forEach((devConfig) => {
					deviceConfig = devConfig.guid;
					devReplaceConfig = devConfig.replacedConfigId;
					if (deviceConfig && (devReplaceConfig === undefined || devReplaceConfig === null || devReplaceConfig === "")) {
						deviceCount = deviceCount + 1;
					}
				});
			}
			let compNextGenPlan = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
			if (compNextGenPlan) {
				planCount = 0;
				let compConfigs = compNextGenDevice.getConfigurations();
				Object.values(compConfigs).forEach((plnConfig) => {
					planConfig = plnConfig.guid;
					planReplaceConfig = plnConfig.replacedConfigId;
					if (planConfig && (planReplaceConfig === undefined || planReplaceConfig === null || planReplaceConfig === "")) {
						planCount = planCount + 1;
					}
				});
			}
			if ((offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && deviceCount <= planCount) || offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId) {
				let comp = solution.getComponentByName(componentName);
				if (comp) {
					//DPG-4071- added condition of Accessory-Mahima- start
					let compConfigs;
					if(componentName=='Device'){
						compConfigs = compNextGenDevice.getConfigurations();
					}
					else if(componentName=='Accessory'){
						compConfigs = compNextGenAccessory.getConfigurations();
					}
					//DPG-4071- added condition of Accessory- end
					Object.values(compConfigs).forEach(async (config) => {
						if (config.guid) {
							let DeviceReplaceConfigId = config.replacedConfigId;
                    		console.log('DeviceReplaceConfigId==>'+DeviceReplaceConfigId);
							let devCareEligibility = config.getAttribute("DeviceCareEligibility");
                    		console.log('devCareEligibility==>'+devCareEligibility.value);
							let deviceColor='';
							//DPG-4071- added condition of Accessory- start
							if(componentName=='Device'){deviceColor = config.getAttribute("MobileHandsetColour");}
							else if(componentName=='Accessory'){deviceColor = config.getAttribute("AccessoryModel");}
							//DPG-4071- added condition of Accessory- end
							console.log('deviceColor==>'+deviceColor.value);
							
							if (deviceColor.value !== "" && deviceColor.value !== null && deviceColor.value !== undefined && devCareEligibility.value !== "Eligible" && config.relatedProductList && (Object.values(config.relatedProductList).length > 0 || Object.values(config.relatedProductList).length === 1)) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									let cnfg = await comp.getConfiguration(config.guid);
									cnfg.status = false;
									cnfg.statusMessage = "Device Care is not applicable for the selected Device.";

									let cnfg1 = await comp.getConfiguration(relatedConfig.guid);
									cnfg1.status = false;
									cnfg1.statusMessage = "Device Care is not applicable for the selected Device.";
								});
							}
							if (devCareEligibility.value === "Eligible" && config.relatedProductList && Object.values(config.relatedProductList).length > 1) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.guid === relatedguid) {
										let cnfg = await comp.getConfiguration(relatedConfig.guid);
										cnfg.status = false;
										cnfg.statusMessage = "Only 1 Device Care can be configured for the selected Device.";
									}
								});
							} else if (devCareEligibility.value === "Eligible" && config.relatedProductList && Object.values(config.relatedProductList).length === 1) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.guid === relatedguid) {
										let cnfg = await comp.getConfiguration(relatedConfig.guid);
										cnfg.status = true;
										cnfg.statusMessage = "";
									}
								});
							}
							if (deviceColor.value !== "" && deviceColor.value !== null && deviceColor.value !== undefined && devCareEligibility.value === "Eligible" && config.relatedProductList && Object.values(config.relatedProductList).length === 1) {
								if (config.guid === DeviceConfigGuid) {
									Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
										let cnfg = await comp.getConfiguration(relatedConfig.guid);
										cnfg.status = false;
										cnfg.statusMessage = "Please reselect the Device Care Plan.";

										let cnfg1 = await comp.getConfiguration(config.guid);
										cnfg1.status = false;
										cnfg1.statusMessage = "Please reselect the Device Care Plan.";
									});
								}
							} else {
								if (devCareEligibility.value === "Eligible" && config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
									let cnfg = await comp.getConfiguration(config.guid);
									cnfg.status = true;
									cnfg.statusMessage = "";
								}
							}

							if (devCareEligibility.value !== "Eligible" && Object.values(config.relatedProductList).length === 0) {
								let cnfg = await comp.getConfiguration(config.guid);
								cnfg.status = true;
								cnfg.statusMessage = "";
							}
							//Commented by Aman Soni for bug(EDGE-182492) || Start
							/* if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (
										DeviceReplaceConfigId &&
										DeviceReplaceConfigId !== "" &&
										DeviceReplaceConfigId !== undefined &&
										DeviceReplaceConfigId !== null &&
										relatedConfig.guid &&
										(relatedConfig.configuration.replacedConfigId === "" || relatedConfig.configuration.replacedConfigId === null || relatedConfig.configuration.replacedConfigId === undefined)
									) {
										let cnfg = await comp.getConfiguration(relatedConfig.guid);
										cnfg.status = false;
										cnfg.statusMessage = "Device Care can only be added as part of New Order.";
									}
								});
							} */
							//Commented by Aman Soni for bug(EDGE-182492) || End
						}
					});
				}
			}
		}
	},

	/************************************************************************************
	 * Author	  	: Aman Soni
	 * Method Name 	: validateDeviceConfig
	 * Invoked When	: multiple occurences
	 * Sprint	  	: 20.09 (EDGE-148667)
	 * Parameters  	: guid, mainCompName, componentName
	 ***********************************************************************************/
	validateDeviceConfig: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid) {
							if (config.relatedProductList && Object.values(config.relatedProductList).length == 1) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.guid === guid) {
										let cnfg = await comp.getConfiguration(config.guid);
										cnfg.status = true;
										cnfg.statusMessage = "";

										let cnfgR = await comp.getConfiguration(relatedConfig.guid);
										cnfgR.status = true;
										cnfgR.statusMessage = "";
									}
								});
							}
						}
					});
				}
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : UpdateChildFromParentAtt - To update Parent comp att to Child att
	 * Invoked When: related product is added
	 * Sprint	   : 20.09 (EDGE-148667)
	 * Parameters  : mainCompName, componentName, relatedCompName
	 ************************************************************************************/
	UpdateChildFromParentAtt: async function (ConfigGuid, mainCompName, componentName, relatedCompName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let updateMapDeviceCare = {};
            console.log('componentName==>'+componentName);
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid === ConfigGuid) {
                        
							let parentSKU = '';
							let parentSpecValue = '';
                        	if(componentName=='Device'){
							parentSKU=config.getAttribute("DeviceSKU");
							parentSpecValue = 'DMCAT_ProductSpecification_001211_Fulfilment'; //DPG-4509 by Krunal Taak
							}
                        	//DPG-4071- Mahima - Start
                        	if(componentName=='Accessory'){
							parentSKU=config.getAttribute("AccessorySKU");
							parentSpecValue = 'DMCAT_ProductSpecification_001389_Fulfilment'; //DPG-4509 by Krunal Taak
							}                        	
                        	console.log('parentSKU==> '+parentSKU);
                        	//DPG-4071- Mahima - end
							let parentOfferId = config.getAttribute("OfferId");//Added for EDGE-186968 by Aman Soni
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach((relatedConfig) => {
									if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
											let childSKU = relatedConfig.configuration.getAttribute("DeviceSKU");
											let childOfferId = relatedConfig.configuration.getAttribute("OfferId");//Added for EDGE-186968 by Aman Soni
											let childParentSpec = relatedConfig.configuration.getAttribute("parentSpec"); //DPG-4509 by Krunal Taak
											updateMapDeviceCare[relatedConfig.guid] = [];
											updateMapDeviceCare[relatedConfig.guid].push({
												name: childSKU.name,
												showInUi: false,
												readOnly: true,
												value: parentSKU.value,
												displayValue: parentSKU.value
											},{
												name: childOfferId.name,
												showInUi: false,
												readOnly: true,
												value: parentOfferId.value,
												displayValue: parentOfferId.value
											}, {
												name: childParentSpec.name,
												showInUi: false,
												readOnly: true,
												value: parentSpecValue,
												displayValue: parentSpecValue
											});										
										}
									}
								});
							}
						}
						let keys = Object.keys(updateMapDeviceCare);
						var complock = comp.commercialLock;
						if (complock) comp.lock("Commercial", false);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMapDeviceCare[keys[i]], true);
						}
						if (complock) comp.lock("Commercial", true);
					});
				}
			}
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : DeviceAndPlanCount
	 * Invoked When: Device Configuration is added
	 * Sprint	   : 20.10 (EDGE-154028)
	 * Parameters  : Blank
	 ***********************************************************************************/
	DeviceAndPlanCount: async function () {
		let solution = await CS.SM.getActiveSolution();
		var deviceCount;
		var planCount;
		var transDevCount;
		var mobAccessoryCount; //Added by Krunal Taak for DPG-4250
		var transAccCount; // Added by Mahima Gandhe for DPG-3889
		var deviceConfig;
		var planConfig;
		var planReplaceConfig;
		var devReplaceConfig;
		var transDeviceConfig;//Added by Aman Soni for EDGE-173469
		var transDeviceReplaceConfig;//Added by Aman Soni for EDGE-173469
		var mobAccessoryConfig;//Added by Krunal Taak for DPG-4250
		var mobAccessoryReplaceConfig;//Added by Krunal Taak for DPG-4250
		var transAccConfig; //Added by Mahima For DPG-3889
		var transAccReplaceConfig;//Added by Mahima Dpg-3889
		var offerName;
		var offerId;
		if (solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname){
				let configs = solution.getConfigurations();
				Object.values(configs).forEach((solConfig) => {
					if (solConfig.guid) {
						if (solConfig.attributes && Object.values(solConfig.attributes).length > 0) {
							offerName = solConfig.getAttribute("Marketable Offer");
							offerId = solConfig.getAttribute("OfferId");
						}
					}
				});
				let compNextGenDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
				if (compNextGenDevice) {
					deviceCount = 0;
					let compConfigs = compNextGenDevice.getConfigurations();
					Object.values(compConfigs).forEach((devConfig) => {
						deviceConfig = devConfig.guid;
						devReplaceConfig = devConfig.replacedConfigId;
						if (deviceConfig && (devReplaceConfig === undefined || devReplaceConfig === null || devReplaceConfig === "")) {
							deviceCount = deviceCount + 1;
						}
					});
				}
				//Added by Aman Soni || Liverpool refactored code is breaking the functionality || 9th Oct || Start
				let compNextGenGenPlan = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
				if (compNextGenGenPlan){
					planCount = 0;
					if (compNextGenGenPlan.schema && compNextGenGenPlan.schema.configurations && Object.values(compNextGenGenPlan.schema.configurations).length > 0) {
						Object.values(compNextGenGenPlan.schema.configurations).forEach((plnConfig) => {
							planConfig = plnConfig.guid;
							planReplaceConfig = plnConfig.replacedConfigId;
							if (planConfig && (planReplaceConfig === undefined || planReplaceConfig === null || planReplaceConfig === "")) {
								planCount = planCount + 1;
							}
						});
					}
				}
				//Added by Aman Soni for EDGE-173469 || Start
				var compTransDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
				if(compTransDevice){
					transDevCount = 0;
					if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length > 0){
						Object.values(compTransDevice.schema.configurations).forEach((transDevConfig) => {
							transDeviceConfig = transDevConfig.guid;
							transDeviceReplaceConfig = transDevConfig.replacedConfigId;
							if (transDeviceConfig && (transDeviceReplaceConfig === undefined || transDeviceReplaceConfig === null || transDeviceReplaceConfig === "")) {
								transDevCount = transDevCount + 1;
							}
						});
					}					
				}
				//Added by Aman Soni for EDGE-173469 || End
			//Added by Krunal Taak for DPG-4250 || Start
			var compMobileAccessory = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory);
			if (compMobileAccessory) {
				mobAccessoryCount = 0;
				if (compMobileAccessory.schema && compMobileAccessory.schema.configurations && Object.values(compMobileAccessory.schema.configurations).length > 0) {
					Object.values(compMobileAccessory.schema.configurations).forEach((accessoryConfig) => {
						mobAccessoryConfig = accessoryConfig.guid;
						mobAccessoryReplaceConfig = accessoryConfig.replacedConfigId;
						if (mobAccessoryConfig && (mobAccessoryReplaceConfig === undefined || mobAccessoryReplaceConfig === null || mobAccessoryReplaceConfig === "")) {
							mobAccessoryCount = mobAccessoryCount + 1;
						}
					});
				}
			}
			//Added by Krunal Taak for DPG-4250 || End
			//Added by Mahima Gandhe for DPG-3889 || Start
				var compTransAcc = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);


				
				if(compTransAcc){
					transAccCount = 0;
					if(compTransAcc.schema && compTransAcc.schema.configurations && Object.values(compTransAcc.schema.configurations).length > 0){
						Object.values(compTransAcc.schema.configurations).forEach((transConfig) => {
							transAccConfig = transConfig.guid;
							transAccReplaceConfig = transConfig.replacedConfigId;
							if (transAccConfig && (transAccReplaceConfig === undefined || transAccReplaceConfig === null || transAccConfig === "")) {
								transAccCount = transAccCount + 1;
							}
						});
					}					
				}
				//Added by Mahima Gandhe for DPG-3889 || End	
				//Commented by Aman Soni || Liverpool refactored code is breaking the functionality || 9th Oct || End
			if (compNextGenDevice || compMobileAccessory) {
				//Added by Aman Soni for EDGE-173469 || Start //updated by Krunal Taak for DPG-4250 // Updated by Mahima - DPG-3889
				if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && (deviceCount > 0) && (transDevCount == 0) && (mobAccessoryCount == 0)&& (transAccCount==0)) {
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 0, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory, 0, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 0, 9999); //Added by Mahima for DPG-3889


				}
				if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && (mobAccessoryCount > 0) && (deviceCount == 0) && (transDevCount == 0) && (transAccCount==0)) {
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 0, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, 0, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 0, 9999); //Added by Mahima for DPG-3889
				}


				if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && (deviceCount == 0) && (transDevCount == 0) && (mobAccessoryCount == 0) && (transAccCount==0)) {
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 1, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, 1, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory, 1, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 1, 9999); //Added by Mahima for DPG-3889


				}
				//Added by Aman Soni for EDGE-173469 || End //updated by Krunal Taak for DPG-4250 // Updated by Mahima - DPG-3889
				if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && deviceCount > planCount) {
					if (compNextGenDevice.schema && compNextGenDevice.schema.configurations && Object.values(compNextGenDevice.schema.configurations).length > 0) {
						Object.values(compNextGenDevice.schema.configurations).forEach(async (devConfigToUpdate) => {
							deviceConfigToUpd = devConfigToUpdate.guid;
							devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
							if (deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === "")) {
								let cnfg = await compNextGenDevice.getConfiguration(deviceConfigToUpd);
								cnfg.status = false;
								cnfg.statusMessage = "Device quantity cannot exceed number of new plans " + planCount + " configured";
							}
						});
					}
				} else if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && deviceCount <= planCount) {
					if (compNextGenDevice.schema && compNextGenDevice.schema.configurations && Object.values(compNextGenDevice.schema.configurations).length > 0) {
						Object.values(compNextGenDevice.schema.configurations).forEach(async (devConfigToUpdate) => {
							deviceConfigToUpd = devConfigToUpdate.guid;
							devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
							if (deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === "")) {
								let cnfg = await compNextGenDevice.getConfiguration(deviceConfigToUpd);
								cnfg.status = true;
								cnfg.statusMessage = "";
							}
						});
					}
				} else if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && deviceCount > planCount) {
					if (compNextGenDevice.schema && compNextGenDevice.schema.configurations && Object.values(compNextGenDevice.schema.configurations).length > 0) {
						Object.values(compNextGenDevice.schema.configurations).forEach(async (devConfigToUpdate) => {
							deviceConfigToUpd = devConfigToUpdate.guid;
							devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
							if (deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === "")) {
								let cnfg = await compNextGenDevice.getConfiguration(deviceConfigToUpd);
								cnfg.status = true;
								cnfg.statusMessage = "";
							}
						});
					}
				}
			}
			
			//Added by Aman Soni for EDGE-173469 || Start
			if(offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && transDevCount > 0){
				if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length > 0){
						Object.values(compTransDevice.schema.configurations).forEach(async (transDevConfig) => {
							transDeviceConfig = transDevConfig.guid;
							let cnfg = await compTransDevice.getConfiguration(transDeviceConfig);
							cnfg.status = false;
							cnfg.statusMessage = "Please sync Transition Devices through Adaptive Mobility Device Offer";
						});
					}
			}
			if(offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && transDevCount > 0){
					//Commented by Aman Soni for EDGE-203220 || Start
					/* if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length > 0){
						Object.values(compTransDevice.schema.configurations).forEach(async (transDevConfig) => {
							transDeviceConfig = transDevConfig.guid;
							let cnfg = await compTransDevice.getConfiguration(transDeviceConfig);
							cnfg.status = false;
							cnfg.statusMessage = 'Please click on Validate and Save to save your changes';
						});
					} */
					//Commented by Aman Soni for EDGE-203220 || Start
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, 0, 9999);
				solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory, 0, 9999);//Added by Krunal Taak for DPG-4250
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 0, 9999);//Added by Mahima DPG-3889
			}
			//Added by Aman Soni for EDGE-173469 || End
			//Added by Mahima For Dpg- 3889 || Start

			

			if (offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.planOfferId && transAccCount > 0) {
				if (compTransAcc.schema && compTransAcc.schema.configurations && Object.values(compTransAcc.schema.configurations).length > 0) {
					Object.values(compTransAcc.schema.configurations).forEach(async (transConfig) => {
						transAccConfig = transConfig.guid;
						let cnfg = await compTransAcc.getConfiguration(transAccConfig);
						cnfg.status = false;
						cnfg.statusMessage = "Please sync Transition Devices through Adaptive Mobility Device Offer";
					});
				}
			}
			if(offerId.displayValue === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && transAccCount > 0){
					
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, 0, 9999);
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory, 0, 9999);//Added by Krunal Taak for DPG-4250
					solution.updateComponentQuantity(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 0, 9999);//Added by Mahima DPG-3889
			}
			//Added by Mahima For Dpg- 3889 || END
			
			//Commented by Aman Soni || Liverpool refactored code is breaking the functionality || 9th Oct || Start
			/* let compNextGenGenPlan = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
			if (compNextGenGenPlan) {
				planCount = 0;
				if (compNextGenGenPlan.schema && compNextGenGenPlan.schema.configurations && Object.values(compNextGenGenPlan.schema.configurations).length > 0) {
					Object.values(compNextGenGenPlan.schema.configurations).forEach((plnConfig) => {
						planConfig = plnConfig.guid;
						planReplaceConfig = plnConfig.replacedConfigId;
						if (planConfig && (planReplaceConfig === undefined || planReplaceConfig === null || planReplaceConfig === "")) {
							planCount = planCount + 1;
						}
					});
				}
			} */
			//Commented by Aman Soni || Liverpool refactored code is breaking the functionality || 9th Oct || End
		}
	},
	/************************************************************************************
	 * Author	   : Aman Soni
	 * Method Name : UpdatePlanAllowance
	 * Invoked When: multiple occurences
	 * Sprint	   : 20.10 (EDGE-154028)
	 * Parameters  : Blank
	 ***********************************************************************************/
	UpdatePlanAllowance: async function (guid, planValue) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			var inputMap = {};
			var selectedPlan = planValue;
			var allowanceRecId = "";
			var allowanceValue = "";
			let comp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
			if (comp) {
				let config = comp.getConfiguration(guid);
				if (config && selectedPlan != "") {
					inputMap["priceItemId"] = selectedPlan;
					await activeNGEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap).then(async (response) => {
						if (response && response["allowances"] != undefined) {
							response["allowances"].forEach((a) => {
								if (a.Id != null) {
									allowanceRecId = a.cspmb__allowance__r.Id;
									allowanceValue = a.cspmb__allowance__r.Name;
								}
							});
							if (allowanceRecId != "") {
								let updateConfigMap = {};
								updateConfigMap[config.guid] = [
									{
										name: "PlanAllowance",
										value: allowanceRecId,
										displayValue: allowanceValue
									}
								];
								let keys = Object.keys(updateConfigMap);
								let componentObj = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
								for (let i = 0; i < keys.length; i++) {
									await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
								}
							}
						} else {
							console.log("no response");
						}
					});
				}
			}
		}
		return Promise.resolve(true);
	},
	/**********************************************************************************************************************************************
	 * Author	   : Aman Soni
     * updated By  : Shweta Khandelwal EDGE-185652
	 * Method Name : updateConfigNameNGEMPlan
	 * Invoked When: after attribute updated
	 * Dynamic name: Payment Type + Plan Name
	 * Sprint	   : 20.10 (EDGE-154026)
	 * Parameters  : componentName, guid
	 *******************************************************************************************************************************************/
	updateConfigNameNGEMPlan: async function (componentName, guid) {
		let solution = await CS.SM.getActiveSolution();
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				let updateMap = {};
				let config = comp.getConfiguration(guid);
				if (config) {
					let configName = CommonUtills.genericSequenceNumberAddInConfigName(config, "PlanTypeString", "SelectPlanName");
					NextGenMobHelper.AMSequenceNumberAddInConfigName(comp, config, configName);
				}
			}	
				/*	let planType = config.getAttribute("PlanTypeString");
					let planName = config.getAttribute("SelectPlanName");
					if (planType.displayValue != "" && planName.displayValue == "") {
						configName = planType.displayValue;
					}
					if (planType.displayValue != "" && planName.displayValue != "") {
						configName = planType.displayValue + "-" + planName.displayValue;
					}
					if (planType.displayValue == "" && planName.displayValue == "") {
						configName = "Enterprise Mobility";
					}
					updateMap[config.guid] = [];
					updateMap[config.guid] = [
						{
							name: "ConfigName",
							value: configName,
							displayValue: configName
						}
					];
					config.configurationName = configName;
				}
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
				}
			}*/

		return Promise.resolve(true);
	},
	
	/************************************************************************************
	 * Author	  : Aman Soni
	 * Method Name : RoundingOffAttribute
	 * Invoked When: multiple occurrences
	 * Sprint	  : 20.12(EDGE-160039)
	 * Parameters  : guid, mainCompName, componentName,relatedCompName, attribute
	 ***********************************************************************************/
	RoundingOffAttribute: async function (guid, mainCompName, componentName, relatedCompName, attribute) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			var updateMap = {};
			let comp = solution.getComponentByName(componentName);
			if(comp){
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach((config) => {
						if (config.guid && !config.disabled) {
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.name.includes(relatedCompName) && relatedConfig.guid) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.guid) {
											let attribs = Object.values(relatedConfig.configuration.attributes);
											let attToBeRound = relatedConfig.configuration.getAttribute(attribute);
											let attRounded = parseFloat(attToBeRound.value).toFixed(2);
											updateMap[relatedConfig.guid] = [];
											if (relatedConfig.guid === guid) {
												updateMap[relatedConfig.guid].push({
													name: attribute,
													value: attRounded,
													displayValue: attRounded
												});
											}
										}
									}
									let keys = Object.keys(updateMap);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
									}
								});
							}
						}
					});
				}
			}
		//});
		}
	},
	/***********************************************************************************************
	 * Author	   : Aman Soni
	 * Sprint	   : 20.13(EDGE-164619)
	 * Method Name : NGEM_handlePortOutReversal
	 * Invoked When: Add to MAC & Config Add
	 * Description : Handling Port out reversal scenarios
	 * parameters  : guid
	 ***********************************************************************************************/
		NGEM_handlePortOutReversal: async function(guid){
		var updateMap = {};
		var isPortOutRevPermissions = false;
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
			let comp = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
					if(comp){
						let configs = comp.getConfigurations();	
						if(configs){						
							Object.values(configs).forEach(async (config) => {
								if(config.guid === guid && !config.disabled){
                                    //Commented as a part of EDGE-170011
									//let existingSIM = config.getAttribute("UseExitingSIM");
									let isPortOutRev = config.getAttribute("isPortOutReversal");								
									
									updateMap[config.guid] = [];								
									if(!config.replacedConfigId){
										isPortOutRevPermissions = hasPortOutReversalPermission;										
										if(isPortOutRevPermissions){
											updateMap[config.guid].push({
												name: 'isPortOutReversal',
												value: false,
												showInUi:true,
												readOnly:false
											});
										}								
									}																
									//Either not a portout reversa righst available or its Modify Config
									else if(config.replacedConfigId){
                                        //Commented as a part of EDGE-170011
										/*updateMap[config.guid].push ({
											name: 'UseExitingSIM',
											value: false,
											showInUi:false,
											readOnly:false
										}); */
										updateMap[config.guid].push({
											name: 'isPortOutReversal',
											value: false,
											showInUi: false,
											readOnly:false
										}); 
									} 	
								}
								let keys = Object.keys(updateMap);
								for (let i = 0; i < keys.length; i++){
									await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
								}
							});
						}
					}
		}
	},
	/***********************************************************************************************
	 * Author	   : Aman Soni
	 * Sprint	   : 20.13(EDGE-164619)
	 * Method Name : NGEM_handlePortOutReversalOnAttUpd
	 * Invoked When: On Att update
	 * Description : Handling Port out reversal scenarios
	 * parameters  : guid
	 ***********************************************************************************************/
		NGEM_handlePortOutReversalOnAttUpd: async function(guid){
		var updateMap = {};
		var isPortOutRevPermissions = false;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
			let comp = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
					if(comp){
							let configs = comp.getConfigurations();
							if(configs){						
							Object.values(configs).forEach(async (config) => {
								if(config.guid === guid && !config.disabled){	
                                    //Commented as a part of EDGE-170011						
									//let existingSIM = config.getAttribute("UseExitingSIM");
									let isPortOutRev = config.getAttribute("isPortOutReversal");	
									updateMap[config.guid] = [];
									//Commented as a part of EDGE-170011
									/*if(!config.replacedConfigId && isPortOutRev.value === true){
										updateMap[config.guid].push ({
											name: 'UseExitingSIM',
											value: false,
											showInUi:true,
											readOnly:false
										});								
									}else if(!config.replacedConfigId && isPortOutRev.value === false){
										updateMap[config.guid].push ({
											name: 'UseExitingSIM',
											value: false,
											showInUi:false,
											readOnly:false
										});
									}	*/																
								}
								let keys = Object.keys(updateMap);
								for (let i = 0; i < keys.length; i++){
									await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
								}
						 });
						}
					}
		}
	},
	/***********************************************************************************************
	 * Author	   : Aman Soni
	 * Sprint	   : 20.14(EDGE-173469)
	 * Method Name : getSyncTransitionDevice
	 * Invoked When: NA
	 * Description : Sync Transition Devices
	 * parameters  : NA
	 ***********************************************************************************************/
	 getSyncTransitionDevice: async function(){
        debugger;
		let solution = await CS.SM.getActiveSolution();		
		let deviceCount;
		let transDevCount;
		let deviceConfig;
		let devReplaceConfig;
		let transDeviceConfig;
		let transDeviceReplaceConfig;
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){			
			let comp = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
			if(comp){				
				var instanceIdList=[];
				var deviceInstId="";
				let configs = comp.getConfigurations();
				if(configs){
					Object.values(configs).forEach((config) => {
						if(config.guid){
						deviceInstId = config.getAttribute("DeviceInstanceId");
						}	
						instanceIdList.push(deviceInstId.displayValue);
					});
				}
				let inputMap = {};
				let currentBasket = await CS.SM.getActiveBasket();
				inputMap["basketId"] = currentBasket.basketId;
				inputMap["instanceIdList"] = instanceIdList.toString();
				await currentBasket.performRemoteAction('GetSyncTransitionDevice', inputMap).then(result => {
				let response = result["GetSyncTransitionDevice"];
				if(response != undefined){
					let getTransDevsStr = JSON.stringify(response);
					let getTransDevsParsed = JSON.parse(getTransDevsStr);			
						Object.keys(getTransDevsParsed).forEach(async (valueKey) => {
						let mainKey = valueKey.replace(/['"]+/g, "");
						let mainValueRecordStr = JSON.stringify(getTransDevsParsed[valueKey]);
						let mainValueRecordParsed = JSON.parse(mainValueRecordStr);
						console.log('mainKey-->',mainKey);
							if(mainKey === 'Ready for Sync'){
									Object.keys(mainValueRecordParsed).forEach(async (lstKey) => {									
										let instIdmapStr = JSON.stringify(mainValueRecordParsed[lstKey]);
										let instIdmapParsed = JSON.parse(instIdmapStr);
										let deviceID = instIdmapParsed.Device_Id__c; 
										let deviceTypeString = instIdmapParsed.Device_Type__c; 
										let paymentTypeString = instIdmapParsed.Contract_Type__c; 
										let remainingTerm = instIdmapParsed.Residual_Remaining_Term__c; 
										let deviceBillDescription = instIdmapParsed.Device_Description__c; 
										let oc = instIdmapParsed.Residual_Remaining_Amount__c; 
										let rc = instIdmapParsed.Monthly_Amount__c; 
										let deviceInstanceId = instIdmapParsed.Instance_Id__c;
										if(paymentTypeString == 'MRO'|| paymentTypeString == 'ARO'){
											 paymentTypeString = 'Hardware Repayment';
										}
										const configuration = comp.createConfiguration([{name: "DeviceID", value: { value: deviceID, displayValue: deviceID}}, {name: "DeviceTypeString", value: { value: deviceTypeString, displayValue: deviceTypeString}}, {name: "PaymentTypeString", value: { value: paymentTypeString, displayValue: paymentTypeString}}, {name: "ContractTerm", value: { value: remainingTerm, displayValue: remainingTerm}}, {name: "DeviceBillDescription", value: { value: deviceBillDescription, displayValue: deviceBillDescription}}, {name: "OC", value: { value: oc, displayValue: oc}}, {name: "RC", value: { value: rc, displayValue: rc}},{name: "DeviceInstanceId", value: { value: deviceInstanceId, displayValue: deviceInstanceId}}, {name: "ConfigName", value: { value: deviceBillDescription, displayValue: deviceBillDescription}}]);
										await comp.addConfiguration(configuration);						
										configuration.configurationName = deviceBillDescription;
										comp.updateConfigurationAttribute(configuration.guid,[{name: 'ConfigName', value: configuration.configurationName}]);
									});					
							}else if(mainKey === 'Sync Removal Pending'){
								Object.keys(mainValueRecordParsed).forEach(async (lstKey) => {									
									let instIdmapStr = JSON.stringify(mainValueRecordParsed[lstKey]);
									let instIdmapParsed = JSON.parse(instIdmapStr);
									let lstKeyRemoval = lstKey;
									let configsToDel = comp.getConfigurations();
									if(configsToDel){
										Object.values(configsToDel).forEach((configToDel) => {
											if(configToDel.guid){
											let devInsIdForRemoval = configToDel.getAttribute("DeviceInstanceId");	
												if(devInsIdForRemoval.displayValue === lstKeyRemoval){
													console.log('devInsIdForRemoval.displayValue-->',devInsIdForRemoval.displayValue);
													comp.deleteConfiguration(configToDel.guid);	
												}
											}
										});
									}											
								});					
							}							
						});
						
						let compNextGenDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
						if (compNextGenDevice){
							deviceCount = 0;
							let compConfigs = compNextGenDevice.getConfigurations();
							Object.values(compConfigs).forEach((devConfig) => {
								deviceConfig = devConfig.guid;
								devReplaceConfig = devConfig.replacedConfigId;
								if (deviceConfig && (devReplaceConfig === undefined || devReplaceConfig === null || devReplaceConfig === "")) {
									deviceCount = deviceCount + 1;
								}
							});
						}
						let compTransDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
						if(compTransDevice){
							transDevCount = 0;
							if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length > 0){
								Object.values(compTransDevice.schema.configurations).forEach((transDevConfig) => {
									transDeviceConfig = transDevConfig.guid;
									transDeviceReplaceConfig = transDevConfig.replacedConfigId;
									if(transDeviceConfig && (transDeviceReplaceConfig === undefined || transDeviceReplaceConfig === null || transDeviceReplaceConfig === "")){
										transDevCount = transDevCount + 1;
									}
								});
							}
						}

						if(deviceCount == 0){
							solution.updateComponentQuantity(NXTGENCON_COMPONENT_NAMES.nextGenDevice, 0, 9999);
						}
				}else{
					let compTransDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
					if(compTransDevice){
						if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length === 0){
							CS.SM.displayMessage("No devices available to transition", "info");
						}else if(compTransDevice.schema && compTransDevice.schema.configurations && Object.values(compTransDevice.schema.configurations).length > 0){
							CS.SM.displayMessage("Devices are synced successfully", "info");
						}
					}
				}				
			 });
			}
		}
		return Promise.resolve(true);
	 },
	
	/***********************************************************************************************
	 * Author	   : Aman Soni
	 * Sprint	   : 21.02(EDGE-191077)
	 * Method Name : createConfigforSelServiceAddOns
	 * Invoked When: Cliked on Add to Solution Button 
	 * Description : Create Configuration against Service Add Ons
	 * parameters  : componentName, servAddondata
	 ***********************************************************************************************/
	createConfigforSelServiceAddOns: async function (componentName, servAddondata) {
		let solution = await CS.SM.getActiveSolution();
		let servAddons = [];
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
			let comp = solution.getComponentByName(componentName);
			servAddons = JSON.parse(servAddondata);
			if(comp){
				if(servAddons != undefined){
					for(var rec of servAddons){
						let deviceID = rec.deviceID;
						let deviceType = rec.deviceType;	
						let deviceIDType = rec.deviceIDType;
						let deviceManufacturer = rec.deviceManufacturer;
						let deviceModel = rec.deviceModel;
						let deviceBillDescription = rec.deviceDescription;
						// Added by Jay(Osaka) as a part of DIGI-10894
                        let FullContractTerm = rec.FullContractTerm;
                                debugger; 
                        // Added by Mahima for 80 Char trim logic for config name- ARO - DPG-5235
                        if(rec.deviceDescription.length>80 && rec.paymentType=='ARO'){
                            deviceBillDescription = rec.deviceDescription.substring(0, 80);
                        }
						let paymentType = rec.paymentType;
						let remainingBalance = rec.remainingBalance;
						let remainingTerm = rec.remainingTerm;
						let recChargeIncGst = rec.recChargeIncGst;
						let deviceInstanceId = rec.deviceInstanceId;
						let legacyBillingAccount = rec.legacyBillingAccount;

						if((paymentType == 'MRO') || (paymentType == 'HRO') || (paymentType == 'ARO')){

							paymentType = 'Hardware Repayment';
						}
						
						const configuration = comp.createConfiguration([
						{ name: "DeviceID", value: { value: deviceID, displayValue: deviceID } }, 
						{ name: "DeviceTypeString", value: { value: deviceType, displayValue: deviceType } }, 
						{ name: "DeviceIDType", value: { value: deviceIDType, displayValue: deviceIDType } }, 
						{ name: "DeviceManufacturer", value: { value: deviceManufacturer, displayValue: deviceManufacturer } }, 
						{ name: "DeviceModel", value: { value: deviceModel, displayValue: deviceModel } }, 
						{ name: "DeviceBillDescription", value: { value: deviceBillDescription, displayValue: deviceBillDescription } }, 
						{ name: "PaymentTypeString", value: { value: paymentType, displayValue: paymentType } },
						{ name: "OC", value: { value: remainingBalance, displayValue: remainingBalance } }, 					
						{ name: "ContractTerm", value: { value: remainingTerm, displayValue: remainingTerm } }, 
						{ name: "RC", value: { value: recChargeIncGst, displayValue: recChargeIncGst } }, 
						{ name: "DeviceInstanceId", value: { value: deviceInstanceId, displayValue: deviceInstanceId } }, 
						{ name: "LegacyBillingAccount", value: { value: legacyBillingAccount, displayValue: legacyBillingAccount } }, 
						{ name: "ConfigName", value: { value: deviceBillDescription, displayValue: deviceBillDescription } },
						//Added by Jay(Osaka) as a part of DIGI-10894
                        { name: "FullContractTerm", value: { value: FullContractTerm, displayValue: FullContractTerm } }
					]);
						await comp.addConfiguration(configuration); 
						configuration.configurationName = deviceBillDescription;
						comp.updateConfigurationAttribute(configuration.guid, [{ name: 'ConfigName', value: configuration.configurationName }]);
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	
	/***********************************************************************************************
	 * Author	   : Aman Soni
	 * Sprint	   : 21.02(EDGE-191077)
	 * Method Name : removeConfigforSelServiceAddOns
	 * Invoked When: Cliked on Remove from Solution Button 
	 * Description : Remove Configuration against Service Add Ons
	 * parameters  : componentName, servAddondata
	 ***********************************************************************************************/
	removeConfigforSelServiceAddOns: async function (componentName, servAddondata){
		let solution = await CS.SM.getActiveSolution();
		let servAddons = [];
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
			let comp = solution.getComponentByName(componentName);
			servAddons = JSON.parse(servAddondata);
			if(comp){
				if(servAddons != undefined){
					for(var rec of servAddons){
						let lstKeyRemoval = rec.deviceInstanceId;
						let configsToDel = comp.getConfigurations();
						if (configsToDel){
							Object.values(configsToDel).forEach((configToDel) => {
								if (configToDel.guid) {
									let devInsIdForRemoval = configToDel.getAttribute("DeviceInstanceId");
									if (devInsIdForRemoval.displayValue === lstKeyRemoval) {
										comp.deleteConfiguration(configToDel.guid);
									}
								}
							});
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	* Author	   : Aman Soni
	* Sprint	  : 20.14(EDGE-173469)/21.02(EDGE-191077)
	* Method Name : updateSyncTransDeviceStatus
	* Invoked When: afterSave
	* Description : Sync Transition Devices and update status
	* parameters  : NA
	***********************************************************************************************/
	updateSyncTransDeviceStatus: async function(componentName, contrType){
		let solution = await CS.SM.getActiveSolution();		
		var solId = '';
		var solutionId = '';
		var contractType = contrType;
		var category = componentName;
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){			
			let solConfigs = solution.getConfigurations();
			for(var solConfig of Object.values(solConfigs)){
				if(solConfig.guid){
					solId = solConfig.getAttribute("SolutionId");
					solutionId = solId.displayValue;
				}
			}
			let comp = solution.getComponentByName(componentName);
			if(comp){				
				var insLstForStatusUpd=[];
				var deviceInstIdNew="";
				let configs = comp.getConfigurations();
				if(configs){
					Object.values(configs).forEach((config) => {
						if(config.guid){
						deviceInstIdNew = config.getAttribute("DeviceInstanceId");
						}	
						insLstForStatusUpd.push(deviceInstIdNew.displayValue);
					});
				}
				let inputMap = {};
				let currentBasket = await CS.SM.getActiveBasket();
				inputMap["basketId"] = currentBasket.basketId;
				inputMap["category"] = category;
				inputMap["contractType"] = contractType;
				inputMap["solutionId"] = solutionId;
				inputMap["insLstForStatusUpd"] = insLstForStatusUpd.toString();
				await currentBasket.performRemoteAction('GetSyncTransitionDevice', inputMap).then(result => {
				console.log('Synced Devices Status Successfully !!!');				
				});
			}
		}
		return Promise.resolve(true);
	 },
	
	/***********************************************************************************************
	* Author	  : Aman Soni
	* Sprint	  : 20.14(EDGE-207355)
	* Method Name : validateConfigsInMigrationScenario
	* Invoked When: afterSave
	* Description : validate BAN on configurations in case of Migration Journey 
	* parameters  : componentName
	***********************************************************************************************/
	validateConfigsInMigrationScenario: async function(componentName){
		let solution = await CS.SM.getActiveSolution();		
		let configCount = 0;
		let diffConfigCount = 0;
		if(solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){			
			let comp = solution.getComponentByName(componentName);
			if(comp){
				let configs = comp.getConfigurations();
				if(Object.values(configs).length > 0){
					Object.values(configs).forEach((config) => {
						//Added replacedConfigId and disabled by Aman Soni for INC000096625009
						if(!config.replacedConfigId && !config.disabled){
							configCount = configCount + 1 ;
							let firstbillAccAtt = configs[0].getAttribute("BillingAccountLookup");
							let firstbillAccAttValue = firstbillAccAtt.displayValue;
							let billAccAtt = config.getAttribute("BillingAccountLookup");
							let billAccAttValue = billAccAtt.displayValue;
							if((firstbillAccAttValue != '' || firstbillAccAttValue != undefined) && (billAccAttValue != '' || billAccAttValue != undefined)){
								if(firstbillAccAttValue != billAccAttValue){
									diffConfigCount = 0;
									diffConfigCount = diffConfigCount + 1;
								}else{
									diffConfigCount = configCount;
								}
							}
						}
					});	
				}
			}
			if(configCount != diffConfigCount && diffConfigCount == 1){
				let configurations = comp.getConfigurations();
				if(Object.values(configurations).length > 0){
					Object.values(configurations).forEach((cnfg) => {
						if(componentName === NEXTGENMOB_COMPONENT_NAMES.transitionDevice){
						cnfg.status = false;
						cnfg.statusMessage = "All the migration devices should have same target billing account number in an order";	
						}else if(componentName === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory){
						cnfg.status = false;
						cnfg.statusMessage = "All the migration accessories should have same target billing account number in an order";	
						}
					});
				}
				return Promise.resolve(false);
			}
			else{
				let configurations = comp.getConfigurations();
				if(Object.values(configurations).length > 0){
					Object.values(configurations).forEach((cnfg) => {
						cnfg.status = true;
						cnfg.statusMessage = "";
					});
				}
				return Promise.resolve(true);
			}
		}
	},
	/************************************************************************************
	 * Author      : Aditya Pareek
	 * Method Name : updateSolutionNameNGD
	 * Invoked When: multiple occurrences
	 * Parameters  : solutionname,DEFAULTSOLUTIONNAME
	 ***********************************************************************************/
	updateSolutionNameNGD: async function (solutionname, DEFAULTSOLUTIONNAME) {
		var listOfAttributes = ["Solution Name", "GUID"],
			attrValuesMap = {};
		var listOfAttrToGetDispValues = ["Offer Name"],
			attrValuesMap2 = {};
		attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, solutionname);
		attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, solutionname);
		if (attrValuesMap["Solution Name"] === DEFAULTSOLUTIONNAME) {
			let updateConfigMap = {};
			updateConfigMap[attrValuesMap["GUID"]] = [
				{
					name: "Solution Name",
					value: attrValuesMap2["Offer Name"],
					displayValue: attrValuesMap2["Offer Name"]
				}
			];
			if (updateConfigMap) {
				let solution = await CS.SM.getActiveSolution();
				let component = await solution.getComponentByName(solutionname);
				var complock = component.commercialLock;
				if (complock) component.lock("Commercial", false);
				let keys = Object.keys(updateConfigMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
				if (complock) component.lock("Commercial", true);
			}
		}
	},
	/************************************************************************************
	 * Author      : Aditya Pareek
	 * Method Name : restrictNoFaultReturntoUsers
	 * Invoked When: multiple occurrences
	 * Parameters  : NA
	 * EDGE        : 197578
	 ***********************************************************************************/
	 restrictNoFaultReturntoUsers: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
		let configs = component.getConfigurations();
		let inputMap = {};
		let profilePRM = '';
		let configcheck = false;
		inputMap["getLoginUserProfileName"] = "";
		await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
		profilePRM = result["getLoginUserProfileName"];
	});
		Object.values(configs).forEach(async (config) => {
			let cta = config.getAttribute("ChangeType");
			if(cta.displayValue === 'No Fault Return'){
				if (profilePRM.Name === "PRM Community User - Australia" || profilePRM.Name === "PRM Admin - Australia" || profilePRM.Name === "Sales-Enterprise-Unified" || profilePRM.Name === "Sales Enterprise B2B") {
					configcheck = true;

				} 
				}
			
		});
		return configcheck;
	},
	/****************************************************************************************************
	 * Author	: 	 Aditya Pareek
	 * Method Name : checkConfigurationSubscriptionStatusNGEM
	 * Defect/US # : EDGE-148731
	 * Invoked When: Raised MACD on Suspended Subscription
	 * Description :Update the Change Type to Active based on Subscription Status
	 ************************************************************************************************/
	checkConfigurationSubscriptionStatusNGEM: async function (mainCompName, componentName, hookname, configuration) {
		console.log("checkConfigurationSubscriptionStatusNGEM");
		var solutionComponent = false;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
				solutionComponent = true;
				NextGenMobHelper.checkConfigurationSubscriptionsForNGEM(solution, solutionComponent, NEXTGENMOB_COMPONENT_NAMES.solutionname, hookname);
			}
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					solutionComponent = false;
					NextGenMobHelper.checkConfigurationSubscriptionsForNGEM(comp, solutionComponent, comp.name, hookname);
				});
			}
		}
		return Promise.resolve(true);
	},
	/****************************************************************************************************
	 * Author	: 	 Aditya Pareek
	 * Method Name : checkConfigSubsStatusonaddtoMac
	 * Defect/US # : EDGE-148731
	 * Invoked When: Raised MACD on Suspended Subscription
	 * Description :Update the Change Type to Active based on Subscription Status
	 ************************************************************************************************/
	checkConfigSubsStatusonaddtoMac: async function (mainCompName, componentName, hookname, configid) {
		console.log("checkConfigSubsStatusonaddtoMac");
		var solutionComponent = false;
		var remainingTermValue = 0;
		var componentMap = {};
		var remainingTermValue = 0;
		var optionValues = [];
		//var AccessoryCheck = false; //krunal DPG-5621 - DPG-6099
		if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) optionValues =[CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("No Fault Return")];// EDGE-197578 //R34UPGRADE
		else if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionDevice) optionValues = [CommonUtills.createOptionItem("Cancel")];  //EDGE-196285 //R34UPGRADE
		else if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory) optionValues = [CommonUtills.createOptionItem("Cancel")];  //krunal DPG-5621 - DPG-6099 //R34UPGRADE
		else if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory) optionValues = [CommonUtills.createOptionItem("Cancel")];  //krunal DPG-5621 - DPG-6099 //R34UPGRADE
		else optionValues = [CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("Modify")]; //R34UPGRADE

		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
			if (comp) {
				let config = comp.getConfiguration(configid);
				if (config) {
					if (config.replacedConfigId || config.id) {
						let cta = config.getAttribute("ChangeType");
						let payTypeLookup = config.getAttribute("PaymentTypeString");
						let contractTermval = config.getAttribute("ContractTerm");
						if (payTypeLookup.displayValue === "Hardware Repayment" && config.replacedConfigId) {
							CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval.displayValue, config.id, comp.name, hookname);
						}
						if (cta) {
							if (!componentMap[componentName]) {
								componentMap[componentName] = [];
							}
							if (config.replacedConfigId && (config.id == null || config.id == "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "Yes",
									paymenttypelookup: payTypeLookup.displayValue,
									RemainingTerm: remainingTermValue
								});
							} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No",
									paymenttypelookup: payTypeLookup.displayValue,
									RemainingTerm: remainingTermValue
								});
							} else {
								componentMap[componentName].push({
									id: config.id,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No",
									paymenttypelookup: payTypeLookup.displayValue,
									RemainingTerm: remainingTermValue
								});
							}
						}
					}
				}
			}
			let compNextGenPlan = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
			if (compNextGenPlan) {
				let config = compNextGenPlan.getConfiguration(configid);
				if (config) {
					if (config.replacedConfigId || config.id) {
						let cta = config.getAttribute("ChangeType");
						if (cta) {
							if (!componentMap[componentName]) {
								componentMap[componentName] = [];
							}
							if (config.replacedConfigId && (config.id == null || config.id == "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "Yes"
								});
							} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							} else {
								componentMap[componentName].push({
									id: config.id,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							}
						}
					}
				}
			}
			let transDevice = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
			 if (transDevice) {
				let config = transDevice.getConfiguration(configid);
				if (config) {
					if (config.replacedConfigId || config.id) {
						var cta = config.getAttribute("ChangeType");
						if (cta) {
							if (!componentMap[comp.name]) {
								componentMap[comp.name] = [];
							}
	
							if (config.replacedConfigId && (config.id == null || config.id == "")) {
								componentMap[comp.name].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "Yes"
								});
							} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
								componentMap[comp.name].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							} else {
								componentMap[comp.name].push({
									id: config.id,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							}
						}
					}
				}
		}
		//krunal DPG-5621 - DPG-6099 - START
		let compAcc = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory);
			if (compAcc) {
				//AccessoryCheck = true;
				let config = compAcc.getConfiguration(configid);
				if (config) {
					if (config.replacedConfigId || config.id) {
						let cta = config.getAttribute("ChangeType");
						let payTypeLookup = config.getAttribute("PaymentTypeShadow");
						let contractTermval = config.getAttribute("ContractTerm");
						if (payTypeLookup.displayValue === "Hardware Repayment" && config.replacedConfigId) {
							CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval.displayValue, config.id, comp.name, hookname);
						}
						if (cta) {
							if (!componentMap[componentName]) {
								componentMap[componentName] = [];
							}
							if (config.replacedConfigId && (config.id == null || config.id == "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "Yes",
									paymenttypelookup: payTypeLookup.displayValue,
									//RemainingTerm: remainingTermValue
								});
							} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
								componentMap[componentName].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No",
									paymenttypelookup: payTypeLookup.displayValue,
									//RemainingTerm: remainingTermValue
								});
							} else {
								componentMap[componentName].push({
									id: config.id,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No",
									paymenttypelookup: payTypeLookup.displayValue,
									//RemainingTerm: remainingTermValue
								});
							}
						}
					}
				}
			}
		
		let transAcc = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
			 if (transAcc) {
				 //AccessoryCheck = true;
				let config = transAcc.getConfiguration(configid);
				if (config) {
					if (config.replacedConfigId || config.id) {
						var cta = config.getAttribute("ChangeType");
						if (cta) {
							if (!componentMap[comp.name]) {
								componentMap[comp.name] = [];
							}
	
							if (config.replacedConfigId && (config.id == null || config.id == "")) {
								componentMap[comp.name].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "Yes"
								});
							} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
								componentMap[comp.name].push({
									id: config.replacedConfigId,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							} else {
								componentMap[comp.name].push({
									id: config.id,
									guid: config.guid,
									ChangeTypeValue: cta.value,
									needUpdate: "No"
								});
							}
						}
					}
				}
		}
		//krunal DPG-5621 - DPG-6099 - END
			if (Object.keys(componentMap).length > 0) {
				var parameter = "";
				Object.keys(componentMap).forEach((key) => {
					if (parameter) {
						parameter = parameter + ",";
					}
					parameter = parameter + componentMap[key].map((e) => e.id).join();
				});

				let inputMap = {};
				inputMap["GetSubscriptionForConfiguration"] = parameter;
				var statuses;
				let activeNGEMBasket = await CS.SM.getActiveBasket();
				await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
					if (values["GetSubscriptionForConfiguration"]) 
					statuses = JSON.parse(values["GetSubscriptionForConfiguration"]);
				});

				if (statuses) {
					var updateMap = [];
					Object.keys(componentMap).forEach(async (comp) => {
						componentMap[comp].forEach((element) => {
							updateMap[element.guid] = [];
							var statusValue = "New";
							var CustomerFacingId = "";
							var status = statuses.filter((v) => {
								return v.csordtelcoa__Product_Configuration__c === element.id;
							});
							if (status && status.length > 0) {
								statusValue = status[0].csord__Status__c;
								CustomerFacingId = status[0].serviceMSISDN__c;
								const found = optionValues.find((element) => element === statusValue); //R34UPGRADE
								if (found === undefined) {
									optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34UPGRADE
								}
							}
							if (((element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") || ((element.ChangeTypeValue == "Modify" || element.ChangeTypeValue == "Cancel") && element.needUpdate == "Yes")) && element.paymenttypelookup !== "Purchase" && element.paymenttypelookup !== "Hardware Repayment") {
								updateMap[element.guid].push({
									name: "ChangeType",
									value: statusValue,
									displayValue: statusValue,
									options: optionValues,
									showInUi: true
								});
							}
							if ((element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") || ((element.ChangeTypeValue == "Modify" || element.ChangeTypeValue == "Cancel") && element.needUpdate == "Yes")) {
								updateMap[element.guid].push({
									name: "ChangeType",
									value: statusValue,
									displayValue: statusValue,
									showInUi: true
								},
								{
									name: "ChangeType",
									options: optionValues,
									showInUi: true
								}

								);

							}
							//krunal DPG-5621 - DPG-6099 - Added && componentName != NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory condition && componentName != NEXTGENMOB_COMPONENT_NAMES.transitionAccessory
							if (element.paymenttypelookup === "Purchase" && statusValue != "New" && (componentName != NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory && componentName != NEXTGENMOB_COMPONENT_NAMES.transitionAccessory)) {
								updateMap[element.guid] = [
									//Updated as a part of EDGE-197578
									{
										name: "ChangeType",
										value: "PaidOut",
										displayValue: "PaidOut",
										options: [CommonUtills.createOptionItem("PaidOut"),CommonUtills.createOptionItem("No Fault Return")],
										readOnly: false,
										showInUi: true
									}
								];
							}
							//krunal DPG-5621 - DPG-6099 - START
							if (element.paymenttypelookup === "Purchase" && statusValue != "New" && (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory || componentName === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory)) {
								updateMap[element.guid] = [
									{
										name: "ChangeType",
										value: "PaidOut",
										displayValue: "PaidOut",
										options: [CommonUtills.createOptionItem("PaidOut")], //R34 Upgrade
										readOnly: true,
										showInUi: true
									}
								];
							}
							//krunal DPG-5621 - DPG-6099 - END
							/*if (element.paymenttypelookup === "Hardware Repayment" && statusValue != "New") {
								NextGenMobHelper.CheckRemainingTerm(element.guid, hookname, statusValue);
							}*/
						});
						let solution = await CS.SM.getActiveSolution();
						let component = await solution.getComponentByName(componentName);// EDGE-187727
						var complock = component.commercialLock;
						if (complock) component.lock("Commercial", false);
						let keys = Object.keys(updateMap);
						//if (component.name === 'Device') { //commented for EDGE-187727
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						//}
						if (complock) component.lock("Commercial", true);
					});
				}
			}
		}
		return Promise.resolve(true);
	},
	////////////////////////////////////////////////////////////////////////////////////////////
	CheckRemainingTerm: async function (guid, hookname, statusValue) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			Object.values(solution.components).forEach((comp) => {
				let config = comp.getConfiguration(guid);
				if (config) {
					payTypeLookup = Object.values(config.attributes).filter((obj) => {
						return obj.name === "PaymentTypeString";
					});
				}
			});
		}
		NextGenMobHelper.UpdateChangeTypeHRO(guid, hookname, statusValue);
		return Promise.resolve(true);
	},
	///////////////////////////////////////////
	UpdateChangeTypeHRO: async function (guid, hookname, statusValue) {
		var optionValues = [];
		//EDGE-168275
		optionValues = [CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			Object.values(solution.components).forEach(async (comp) => {
				let config = comp.getConfiguration(guid);
				if (config) {
					let NGEMdev = [];
					let cta = config.getAttribute("ChangeType");
					payTypeLookup = config.getAttribute("PaymentTypeString");
					let remainingtermval;
					if (payTypeLookup.displayValue === "Hardware Repayment" && cta.value != "New") {
						remainingtermval = config.getAttribute("RemainingTerm");
					}
					if (remainingtermval) {
						if (parseInt(remainingtermval.value) <= 0) {
							NGEMdev[guid] = [];
							NGEMdev[guid] = [
								{
									name: "ChangeType",
									value: "PaidOut",
									displayValue: "PaidOut",
									readOnly: true
								}
							];
							let keys = Object.keys(NGEMdev);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true);
							}
						}
					} else {
						NGEMdev[guid] = [];
						const found = optionValues.find((element) => element === statusValue); //R34UPGRADE
						if (found === undefined) {
							optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34UPGRADE
						}
						NGEMdev[guid].push[
							{
								name: "ChangeType",
								value: statusValue,
								displayValue: statusValue,
								options: optionValues
							}
						];
						let keys = Object.keys(NGEMdev);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true);
						}
					}
				}
			});
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	 * Author	   : Aditya Pareek
	 * Method Name : checkConfigurationSubscriptionsForNGEM
	 * Invoked When: Solution is Loaded
	 * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
	 * Revision History : Function Signature and code changed to fix EDGE-131227
	 ***********************************************************************************************/
	checkConfigurationSubscriptionsForNGEM: async function (comp, solutionComponent, componentName, hookname) {
		console.log("checkConfigurationSubscriptionsForNGEM");
		var componentMap = {};
		var payTypeLookup;
		var remainingTermValue = 0;
		var optionValues = [];
		if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) optionValues = [CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("PaidOut")]; //R34UPGRADE
		else if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionDevice) optionValues = [CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
		else optionValues = [CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("Modify")]; //R34UPGRADE
		if (solutionComponent) {
			let config = comp.getConfigurations()[0];
			var cta = config.getAttribute("ChangeType");
			componentMap[comp.name] = [];
			componentMap[comp.name].push({
				id: config.replacedConfigId,
				guid: config.guid,
				ChangeTypeValue: cta.value,
				ChangeTypeDisplayValue: cta.displayValue,//EDGE-197578
				needUpdate: "No"
			});
		} else if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenDevice) {
			let configs = comp.getConfigurations();
			Object.values(configs).forEach((config) => {
				if (config.replacedConfigId || config.id) {
					var cta = config.getAttribute("ChangeType");
					payTypeLookup = config.getAttribute("PaymentTypeString");
					var contractTermval = config.getAttribute("ContractTerm");
					var payTypeLookupVal = "";
					var payTypeDisplayValue = "";
					if (payTypeLookup && payTypeLookup.value && payTypeLookup.value != null) {
						payTypeLookupVal = payTypeLookup.value;
						payTypeDisplayValue = payTypeLookup.displayValue;
					}
					if (payTypeDisplayValue === "Hardware Repayment" && config.replacedConfigId) {
						CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval.displayValue, config.id, comp.name, hookname);
					}
					if (cta) {
						if (!componentMap[comp.name]) componentMap[comp.name] = [];
						if (payTypeDisplayValue === "Purchase" && config.replacedConfigId) {
							componentMap[comp.name].push({
								id: config.id,
								guid: config.guid,
								ChangeTypeValue: "PaidOut",
								ChangeTypeDisplayValue: cta.displayValue,//EDGE-197578
								needUpdate: "No",
								paymenttypelookup: payTypeDisplayValue,
								RemainingTerm: remainingTermValue
							});
						} else if (config.replacedConfigId && (config.id == null || config.id == ""))
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "Yes",
								paymenttypelookup: payTypeDisplayValue,
								RemainingTerm: remainingTermValue
							});
						else if (config.replacedConfigId && (config.id != null || config.id != ""))
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No",
								paymenttypelookup: payTypeDisplayValue,
								RemainingTerm: remainingTermValue
							});
						else
							componentMap[comp.name].push({
								id: config.id,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No",
								paymenttypelookup: payTypeDisplayValue,
								RemainingTerm: remainingTermValue
							});
					}
				}
			});
		} else if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan) {
			let configs = comp.getConfigurations();
			Object.values(configs).forEach((config) => {
				if (config.replacedConfigId || config.id) {
					var cta = config.getAttribute("ChangeType");
					if (cta) {
						if (!componentMap[comp.name]) {
							componentMap[comp.name] = [];
						}

						if (config.replacedConfigId && (config.id == null || config.id == "")) {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "Yes"
							});
						} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No"
							});
						} else {
							componentMap[comp.name].push({
								id: config.id,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No"
							});
						}
					}
				}
			});
		}
		else if (componentName === NXTGENCON_COMPONENT_NAMES.transitionDevice) {
			let configs = comp.getConfigurations();
			Object.values(configs).forEach((config) => {
				if (config.replacedConfigId || config.id) {
					var cta = config.getAttribute("ChangeType");
					if (cta) {
						if (!componentMap[comp.name]) {
							componentMap[comp.name] = [];
						}

						if (config.replacedConfigId && (config.id == null || config.id == "")) {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "Yes"
							});
						} else if (config.replacedConfigId && (config.id != null || config.id != "")) {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No"
							});
						} else {
							componentMap[comp.name].push({
								id: config.id,
								guid: config.guid,
								ChangeTypeValue: cta.value,
								needUpdate: "No"
							});
						}
					}
				}
			});
		}
		if (Object.keys(componentMap).length > 0) {
			var parameter = "";
			Object.keys(componentMap).forEach((key) => {
				if (parameter) {
					parameter = parameter + ",";
				}
				parameter = parameter + componentMap[key].map((e) => e.id).join();
			});

			let inputMap = {};
			inputMap["GetSubscriptionForConfiguration"] = parameter;
			var statuses;
			await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
				if (values["GetSubscriptionForConfiguration"]) statuses = JSON.parse(values["GetSubscriptionForConfiguration"]);
			});

			if (statuses) {
				var updateMap = [];
				Object.keys(componentMap).forEach(async (comp) => {
					componentMap[comp].forEach((element) => {
						updateMap[element.guid] = [];
						var statusValue = "New";
						var CustomerFacingId = "";
						var status = statuses.filter((v) => {
							return v.csordtelcoa__Product_Configuration__c === element.id;
						});
						if (status && status.length > 0) {
							statusValue = status[0].csord__Status__c;
							CustomerFacingId = status[0].serviceMSISDN__c;
							const found = optionValues.find((element) => element === statusValue); //R34UPGRADE
							if (found === undefined) {
								optionValues.push(CommonUtills.createOptionItem(statusValue));//R34UPGRADE
							}
						}
						// Updated as a part of EDGE-148738
						if (componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice &&
							((element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") || ((element.ChangeTypeValue == "Modify" || element.ChangeTypeValue == "Cancel") && element.needUpdate == "Yes")) &&
							(element.paymenttypelookup === undefined || element.paymenttypelookup === "Purchase") &&
							element.paymenttypelookup !== "Hardware Repayment" &&
							element.ChangeTypeValue !== "PaidOut"
						) { //EDGE-187727
							updateMap[element.guid].push({
								name: "ChangeType",
								value: statusValue,
								displayValue: statusValue,
								options: optionValues
							});
						}
						//Added by Aman Soni for EDGE-154238 || Start
						else if ((componentName!==NEXTGENMOB_COMPONENT_NAMES.nextGenDevice && element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && element.ChangeTypeValue !== "PaidOut" && statusValue != "New") || ((element.ChangeTypeValue == "Modify" || element.ChangeTypeValue == "Cancel") && element.needUpdate == "Yes")) { //EDGE-187727
							if (!solutionComponent) {
								updateMap[element.guid].push(
									{
										name: "CustomerFacingServiceId",
										value: CustomerFacingId,
										displayValue: CustomerFacingId
									},
									{
										name: "ChangeType",
										value: statusValue,
										displayValue: statusValue,
										options: optionValues,
										showInUi: true
									}
								);
							}else{
							updateMap[element.guid].push({
								name: "ChangeType",
								value: statusValue,
								displayValue: statusValue,
								options: optionValues });//EDGE-188677 else if added by shubhi
							}
						}
						else if (componentName == NEXTGENMOB_COMPONENT_NAMES.nextGenDevice && (element.ChangeTypeDisplayValue == "PaidOut" || element.ChangeTypeDisplayValue == "No Fault Return")  && element.needUpdate == "No" && element.paymenttypelookup === "Purchase") { //EDGE-187727 // EDGE-197578 
							if (!solutionComponent) {
								updateMap[element.guid].push(
									{
										name: "ChangeType",
										value: element.ChangeTypeDisplayValue,
										displayValue: element.ChangeTypeDisplayValue,
										options: [CommonUtills.createOptionItem("PaidOut"),CommonUtills.createOptionItem("No Fault Return")],// Updated as a part of EDGE-197578 
										showInUi: true,
										readOnly: false
									});
							}else{
							updateMap[element.guid].push({
								name: "ChangeType",
								value: statusValue,
								displayValue: statusValue,
								options: optionValues });//EDGE-188677 else if added by shubhi
							}
						}
						else{
							if (!solutionComponent && CustomerFacingId!=='') { // added by shubhi for EDGE-185011
								updateMap[element.guid].push(
									{
									name: "CustomerFacingServiceId",
									value: CustomerFacingId,
									displayValue: CustomerFacingId
								});
							}
						}
						//Added by Aman Soni for EDGE-154238 || End
						if (element.paymenttypelookup === "Hardware Repayment" && statusValue != "New") {
							NextGenMobHelper.CheckRemainingTerm(element.guid, hookname, statusValue);
						}
					});
					let solution = await CS.SM.getActiveSolution();
					var comp1 = await solution.getComponentByName(componentName);
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp1.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				});
			}
		}
		return Promise.resolve(true);
	},

	CalculateTotalETCValue: async function (guid, mainCompName) {
		if (basketChangeType !== "Change Solution") {
			return;
		}
		let product = await CS.SM.getActiveSolution();
		let contractTerm;
		let disconnectionDate;
		let prodConfigID;
		let componentName;
		if (product.name.includes(mainCompName)) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					let config = comp.getConfiguration(guid);
					if (config) {
						componentName = comp.name;
						prodConfigID = config.replacedConfigId;
						let dd = config.getAttribute("DisconnectionDate");
						if (dd && dd.value) disconnectionDate = new Date(dd.value);
						let ct = config.getAttribute("ContractTerm");
						if (ct && ct.value) contractTerm = ct.displayValue;
					}
				});
				if (disconnectionDate && contractTerm) {
					var inputMap = {};
					var updateMap = [];
					inputMap["getETCChargesForAM"] = ""; //EDGE-188712 - method for calculating ETC for AM
					inputMap["DisconnectionDate"] = disconnectionDate;
					inputMap["etc_Term"] = contractTerm;
					inputMap["ProdConfigId"] = prodConfigID;

					let activeNGEMBasket = await CS.SM.getActiveBasket();
					activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (values) => {
						var charges = values["getETCChargesForAM"]; //EDGE-188712 - method for calculating ETC for AM
						var chargesGst = parseFloat(charges * 1.1).toFixed(2);
						updateMap[guid] = [
							{
								name: "EarlyTerminationCharge",
								value: charges,
								displayValue: charges
							},
							{
								name: "EarlyTerminationChargeIncGST",
								label: "Balance Due on Device(Inc. GST)",
								value: chargesGst,
								displayValue: chargesGst
							}
						];
						let component = await product.getComponentByName(componentName);
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); // DIGI-1853 changed to false so that after attribute hook is triggered
						}
					});
				}
			}
		}
	},

	ReadOnlyMarketableOffer: async function (mainCompName, guid) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)){
			let configs = solution.getConfigurations();
			Object.values(configs).forEach(async (config) => {
				if (config.attributes && Object.values(config.attributes).length > 0) {
					var updateConfigMap = {};
					updateConfigMap[guid] = [];
					updateConfigMap[guid].push({
						name: "Marketable Offer",
						readOnly: true
					});
					let component = await solution.getComponentByName(mainCompName);
					let keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
			});
		}
	},
	/**********************************************************************************************************************************************
	 * Author	   : Laxmi Rahate
	 * Method Name : resetPreferredCRD
	 * Invoked When: after attribute updated
	 * Parameters  : none
	 ******************************************************************************************************************************************/
	resetPreferredCRD: async function (notBeforeCRD, preferredCRD) {
		var hasErrors = false;
		var changeTypeAttributeVal = "";
		var updateMapNewConfig = {}; // Added to fix issue of CRD not getting Populated on PC - eixt
		let product = await CS.SM.getActiveSolution();
		if (product.name === NEXTGENMOB_COMPONENT_NAMES.solutionname) {
			let comp = solution.getComponentByName("Device");
			if (comp) {
				let configs = comp.getConfigurations();
				Object.values(configs).forEach(async (config) => {
					updateMapNewConfig = {};
					var changeTypeAttribute = config.getAttribute("ChangeType");
					if (changeTypeAttribute && changeTypeAttribute.value && changeTypeAttribute.value != null) {
						changeTypeAttributeVal = changeTypeAttribute.value;
					}

					if (!updateMapNewConfig[config.guid]) updateMapNewConfig[config.guid] = [];

					if (changeTypeAttributeVal !== "Cancel" && changeTypeAttributeVal !== "PaidOut") {
						var updateMapNew = {};

						if (config.orderEnrichmentList) {
							for (var k = 0; k < config.orderEnrichmentList.length; k++) {
								let oeAtt = config.orderEnrichmentList[k];
								let preferredCRDAttVal = "";
								let notBeforeCRDAttVal = "";
								let oeNameVal = "";

								let oeName;
								if(oeAtt.name == "Mobility Features NextGenEM 1") 
									oeName = oeAtt.getAttribute("OEListName");
								else
									oeName = oeAtt.getAttribute("OENAME");

								if (oeName.length > 0 && oeName.value && oeName.value != null) {
									oeNameVal = oeName.value;
								}
								if (oeNameVal === "CRD") {
									// Only perform below logic for CRD - this logic copies value from CNOt Before CRD to preferred CRD if preferred CRD is blank
									var preferredCRDAtt = oeAtt.getAttribute("Preferred CRD");
									var notBeforeCRDAtt = oeAtt.getAttribute("Not Before CRD");
									if (preferredCRDAtt && preferredCRDAtt.value && preferredCRDAtt.value != null) {
										preferredCRDAttVal = preferredCRDAtt.value;
									}
									if (notBeforeCRDAtt && notBeforeCRDAtt.value && notBeforeCRDAtt.value != null) {
										notBeforeCRDAttVal = notBeforeCRDAtt.value;
									}

									if (preferredCRDAttVal || notBeforeCRDAttVal) {
										if (!updateMapNew[oeAtt.guid]) updateMapNew[oeAtt.guid] = [];

										if (preferredCRDAttVal === "" || preferredCRDAttVal < notBeforeCRDAttVal || preferredCRDAttVal === "0" || preferredCRDAttVal === 0 || preferredCRDAttVal === NaN) {
											preferredCRDAttVal = notBeforeCRDAttVal;
											updateMapNew[oeAtt.guid].push({
												name: "Preferred CRD",
												showInUi: true,
												displayValue: notBeforeCRDAttVal,
												value: notBeforeCRDAttVal
											});
										}
										updateMapNew[oeAtt.guid].push({
											name: "Not Before CRD",
											showInUi: true,
											displayValue: notBeforeCRDAttVal,
											value: notBeforeCRDAttVal
										});

										var notBeforeCRDValidation = new Date();
										notBeforeCRDValidation.setHours(0, 0, 0, 0);
										notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);
										if (notBeforeCRDAttVal < notBeforeCRDValidation) {
											let cnfg = await comp.getConfiguration(config.guid);
											cnfg.status = false;
											cnfg.statusMessage = "Not Before CRD date should be greater than today!!!";
											hasErrors = true;
										} else {
											let cnfg = await comp.getConfiguration(config.guid);
											cnfg.status = true;
											cnfg.statusMessage = "";
											Utils.unmarkOEConfigurationInvalid(oeAtt.guid, "");
										}
									}
								}
							}
						}
						if (updateMapNew) {
							let keys = Object.keys(updateMapNew);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], updateMapNew[keys[i]], true);
							}
						}
					}
				});
			}
		}
		if (hasErrors && showMsg) {
			showMsg = false;
			hasErrors = false;
		}
	},
	/*******************************************************************************************************************************************
	 * Author	   : Shubhi Vijay
	 * Method Name : updateConfigName_Device
	 * Invoked When: after attribute updated
	 * Device Type + Model +Colour + Payment Type --> dynamic name
	 * Parameters  : componentName , guid
	 ******************************************************************************************************************************************/
	updateConfigName_DeviceperConfig: async function (componentName, guid) {
		let updateMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let config = comp.getConfiguration(guid);
				if (config) {
                    //var configName = "NextGenMobileDevice";
                    //Shweta Added EDGE-185652
                    let configName = config.configurationName;
                    let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
					var type = config.getAttribute("deviceTypeString");
					var model = config.getAttribute("ModelString");
					var colour = config.getAttribute("ColourString");
					var paymentType = config.getAttribute("PaymentTypeString");
					let paymentTypeStr = 'Purchase';
					if(paymentType.displayValue === 'Hardware Repayment') paymentTypeStr = 'HRO';//EDGE-191285
					if (type && model && colour && paymentType) {
                        configName = type.displayValue + " " + model.displayValue + " " + colour.displayValue + " " + paymentTypeStr + "_" + spaceIndex;//EDGE-191285
					   
					}
					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "ConfigName",
						value: configName,
						displayValue: configName
					});
					config.configurationName = configName;
				}
			}
		}
		if (updateMap) {
			let component = await product.getComponentByName(componentName);
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
			}
		}
		return Promise.resolve(true);
	},
	/******************************************************************************************************************************************
	 * Author	   : Shubhi Vijay
	 * Method Name : updateConfigName_Device
	 * Invoked When: attribute update paymentType
	 * Device Type + Model +Colour + Payment Type --> dynamic name
	 * Parameters  : componentName , guid
	 ******************************************************************************************************************************************/
	updateConfigName_DeviceAllConfig: async function (componentName) {
		let updateMap = {};
		let component;
		let product = await CS.SM.getActiveSolution();
		if (product.components && Object.values(product.components).length > 0) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				for (var config of Object.values(configs)) {
					 //var configName = "NextGenMobileDevice ";
                     //Shweta Added EDGE-185652
                     let configName = config.configurationName;
					 //let spaceIndex = configName.charAt(configName.length - 1);
					 let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
					var type = config.getAttribute("deviceTypeString");
					var model = config.getAttribute("ModelString");
					var colour = config.getAttribute("ColourString");
					var paymentType = config.getAttribute("PaymentTypeString");
					let paymentTypeStr = 'Purchase';
					if(paymentType.displayValue === 'Hardware Repayment') paymentTypeStr = 'HRO';//EDGE-191285
					if (type && model && colour && paymentType) {
                        configName = type.displayValue + " " + model.displayValue + " " + colour.displayValue + " " + paymentTypeStr + "_" + spaceIndex;//EDGE-191285
					   
					}
					
					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "ConfigName",
						value: configName,
						displayValue: configName
					});
					config.configurationName = configName;
				}
			}
			if (updateMap) {
				let keys = Object.keys(updateMap);

				var complock = comp.commercialLock;
				if(complock) comp.lock('Commercial',false);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
				}
				if(complock) comp.lock('Commercial',true);

			}
		}
		return Promise.resolve(true);
	},
	/*******************************************************************************************************************************************
	 * Author	   : Ankit Goswami
	 * Method Name : updateDeviceIdOnConfig
	 * Invoked When: On Load and On Save
	 * Parameters  : componentName
	 * EDGE Number : EDGE-148733
	 ******************************************************************************************************************************************/
	updateDeviceIdOnConfig: async function (componentName) {
		let componentMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				componentMap[comp.name] = [];
				if (configs) {
					Object.values(configs).forEach((config) => {
						var DeviceIDValue = config.getAttribute("DeviceID");
						if (config.replacedConfigId && DeviceIDValue && DeviceIDValue.value === "") {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid
							});
						}
					});
					if (componentMap) NextGenMobHelper.RemoteActionCall(componentMap, "DeviceID", componentName);
				}
			}
		}
	},
	/*******************************************************************************************************************************************
	 * Author	   : Ankit Goswami
	 * Method Name : RemoteActionCall
	 * Invoked When: On Load and On Save
	 * Parameters  : componentName
	 * EDGE Number	: EDGE-148733
	 ******************************************************************************************************************************************/
	RemoteActionCall: async function (componentMap, Attname, componentName) {
		let updateMap = {};
		if (Object.keys(componentMap).length > 0) {
			var parameter = "";
			Object.keys(componentMap).forEach((key) => {
				if (parameter) {
					parameter = parameter + ",";
				}
				parameter = parameter + componentMap[key].map((e) => e.id).join();
			});
			let inputMap = {};
			inputMap["GetAssetForConfiguration"] = parameter;

			var statuses;
			await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
				if (values["GetAssetForConfiguration"]) statuses = JSON.parse(values["GetAssetForConfiguration"]);
			});

			if (statuses) {
				Object.keys(componentMap).forEach(async (comp) => {
					componentMap[comp].forEach((element) => {
						var DeviceID = "";
						var status = statuses.filter((v) => {
							return v.csord__Service__r.csordtelcoa__Product_Configuration__c === element.id;
						});
						if (status && status.length > 0) {
							DeviceID = status[0].AssetID__c;
						}
						if (Attname === "DeviceID" && DeviceID != "" && DeviceID != null) {
							updateMap[element.guid] = [
								{
									name: Attname,
									value: DeviceID,
									displayValue: DeviceID,
									showInUi: true
								}
							];
						}
					});
					if (updateMap) {
						let solution = await CS.SM.getActiveSolution();
						let component = await solution.getComponentByName(componentName);
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
					}
				});
			}
		}
	},
	/**********************************************************************************************
	 * Author	  : Laxmi Rahate
	 * Method Name : setNextGenEMTabsVisibility
	 * Invoked When: after solution is loaded
	 * Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
	 * Parameters  : configuration guid or nothing
	 *********************************************************************************************/
 



	setNextGenEMTabsVisibility: async function (solutionName, component,isOnload) 
	{



		try{
			
		var changeTypeAttributeVal = "";
		let solution = await CS.SM.getActiveSolution();
		let updateConfigMapOE = {};
	let updateConfigMapConfig = {};
		if (solution.name.includes(solutionName)) {
			if (solution.components && Object.values(solution.components).length > 0) {

				for(let comp of Object.values(solution.components)) {
					//DPG-5621 - Krunal added Accessory
					if (comp.name === component || comp.name === "Enterprise Mobility" || comp.name === "Device" || comp.name === "Accessory" ) {
						// Laxmi - Added Device
						let oeToShow = [];
						let oeToShowMac = [];
						let oeToShowExistingNum = [];

						Object.values(comp.orderEnrichments).forEach((oeSchema) => {
							if (!oeSchema.name.toLowerCase().includes("number")) {
								oeToShow.push(oeSchema.name);
							}
							//EDGE-154680 MAC STory changes
							if (!oeSchema.name.toLowerCase().includes("number") && !oeSchema.name.toLowerCase().includes("feature") && !oeSchema.name.toLowerCase().includes("delivery")) {
								oeToShowMac.push(oeSchema.name);
							}		
							if (!oeSchema.name.toLowerCase().includes('number') && !oeSchema.name.toLowerCase().includes('delivery') ) {
								oeToShowExistingNum.push(oeSchema.name);
							}        						
						});
						//EDGE-154680 MAC STory changes
						//let oeToShowMac = [];
						let configs = comp.getConfigurations();
						//if (configs && config.disabled === false) {
							for(let i =0; i<Object.values(configs).length;i++){
								let config = Object.values(configs)[i];
							 //Object.values(configs).forEach(async (config) => {
								if (config && config.disabled === false)
								{
                                let  changeTypeAttribute = config.getAttribute("ChangeType");
                                //Commented as a part of EDGE-170011
								//let useExisting = config.getAttribute("UseExitingSIM");
								
								
								let  SimAvailabilityType;
								if ( comp.name === "Enterprise Mobility"){
								SimAvailabilityType= config.getAttribute("SimAvailabilityType");									
								}
								changeTypeAttributeVal = "";
								// get the AppleCare ChangeType Value -
								if (comp.name === "Device" && config.replacedConfigId) {
									appleCareChangeType = await OE.getRelatedConfigAttrValue(config, "ChangeType", "Mobile Device Care");
									//console.log ( 'appleCareChangeType **************', appleCareChangeType);
								} 
								//DPG-5621 Krunal
								else if (comp.name === "Accessory" && config.replacedConfigId) {
									appleCareChangeType = await OE.getRelatedConfigAttrValue(config, "ChangeType", "Mobile Device Care");
									//console.log ( 'appleCareChangeType **************', appleCareChangeType);
								}//DPG-5621 Krunal
								else appleCareChangeType = "NotDevice";

								if (changeTypeAttribute && changeTypeAttribute.value && changeTypeAttribute.value != null) {
									changeTypeAttributeVal = changeTypeAttribute.value;
									//console.log(" Change Type Value -------------", changeTypeAttributeVal);
								}
								let SimAvailabilityTypeVal ='';
								if (SimAvailabilityType && SimAvailabilityType.value && SimAvailabilityType.value != null) {
									SimAvailabilityTypeVal = SimAvailabilityType.value;
									console.log(" SimAvailabilityTypeVal  Value -------------", SimAvailabilityTypeVal);
								}
								//console.log("appleCareChangeType***************", appleCareChangeType + " ---changeTypeAttributeVal -----" + changeTypeAttributeVal);
									if (changeTypeAttributeVal === "Modify" || (changeTypeAttributeVal === "Active" || appleCareChangeType === "Cancel")&& !( window.basketRecordType==="Inflight Change")) /// EDGE-170544 akanksha added Inflight condition
									{
									// EDGE- 154696 //EDGE-154680 MAC STory changes
									console.log("adding MAC OE !!!");
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShowMac);
								} 
								
								else if( ( config.replacedConfigId === "" || config.replacedConfigId === undefined )&&   comp.name === "Enterprise Mobility" && SimAvailabilityTypeVal!== '' && ! ((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))  ) // Added Check for EDGE-166670
								{
									//CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShowExistingNum);
									console.log ( ' Existing SIM - Hiding Deivery Tab' ); 										
								}			
									else if (changeTypeAttributeVal === "Cancel" || changeTypeAttributeVal === "Paid Out" || changeTypeAttributeVal === "PaidOut" || (changeTypeAttributeVal === "Active" && appleCareChangeType === "NotDevice") && !( window.basketRecordType==="Inflight Change")) //EDGE-170544 akanksha added Inflight condition 
									{
									//Laxmi - Removed Active from this
									CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
									console.log("adding blank OE!!!");
								} //EDGE-154680 MAC STory changes end





								else if (isOnload && comp.name === "Enterprise Mobility" && SimAvailabilityTypeVal.toLowerCase().includes('new')) 
								{





									console.log("adding NEW OE !!!");
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
								}
								/**let updateConfigMap = {};
								updateConfigMap[config.guid] = [
									{
										name: "appleCare",
										value: appleCareChangeType,
										displayValue: appleCareChangeType
									}
								];**/
								
								
								// Code to default CRD Dates in case the APple Care is cancelled and Device Status is Active
								updateConfigMapOE = {};
									updateOEMapPOR = {};
									updateConfigMapConfig = {}; 
									//if (config.orderEnrichmentList && config.disabled == false && comp.name === "Device" && config.replacedConfigId ) {
									if (config.orderEnrichmentList && config.disabled == false   ) {

									for (var m = 0; m < Object.values(config.orderEnrichmentList).length; m++) {
										var oeAtt = Object.values(config.orderEnrichmentList)[m];
										var oeNameVal = "";
										//var oeName = CommonUtills.getAttribute(oeAtt, "OENAME"); // Wasnt working hence commented this is OE attribute
												
										var oeNameVal = "";
										var oeName = await oeAtt.getAttribute("OENAME");
										if (oeName.value && oeName.value != null) {
											oeNameVal = oeName.value;
										}


										//DPG-5621
										if ( (comp.name === "Device" || comp.name === "Accessory") && oeNameVal === "CRD" && appleCareChangeType === "Cancel")



										{
											updateConfigMapOE[oeAtt.guid] = [];
											updateConfigMapConfig[config.guid] = [];
											//if (appleCareChangeType === "Cancel") {
												console.log("made attrubutes read only for ", oeAtt.guid);
												updateConfigMapOE[oeAtt.guid].push({
													name: "Preferred CRD",
													showInUi: true,
													displayValue: Utils.formatDate(new Date().setHours(0, 0, 0, 0)),
													value: Utils.formatDate(new Date().setHours(0, 0, 0, 0)),
													readOnly: true
												});
												updateConfigMapOE[oeAtt.guid].push({
													name: "Not Before CRD",
													showInUi: true,
													displayValue: Utils.formatDate(new Date().setHours(0, 0, 0, 0)),
													value: Utils.formatDate(new Date().setHours(0, 0, 0, 0)),
													readOnly: true
												});
												updateConfigMapOE[oeAtt.guid].push({
													name: "Notes",
													showInUi: true,
													readOnly: true
												});
												//Config Attributes

												updateConfigMapConfig[config.guid].push({
												name: 'Preferred CRD',
												displayValue: 	Utils.formatDate((new Date()).setHours(0,0,0,0)),
												value: 	Utils.formatDate((new Date()).setHours(0,0,0,0))
												//readOnly :true
												
												});													
												updateConfigMapConfig[config.guid].push({
												name: 'Not Before CRD',
												displayValue: Utils.formatDate((new Date()).setHours(0,0,0,0)),
												value: Utils.formatDate((new Date()).setHours(0,0,0,0))
												//readOnly :true
												
												});													
											//Config Attributes End	
											//}
										}



									/*		else if (comp.name === "Enterprise Mobility" && oeNameVal === 'DD' )// Hitesh GAndhi, EDGE-200723, commented out this method as not needed anymore.



									{	
											let updateMapNew = {};
											if (!updateMapNew[oeAtt.guid]) updateMapNew[oeAtt.guid] = [];
												if (!(SimAvailabilityTypeVal.toLowerCase()).includes ('new')  && SimAvailabilityTypeVal!=='' ) // to Fix issue of making schema mandatory when SimAvailabilityType is blank
												{
													
												updateMapNew[oeAtt.guid].push({name: "DeliveryContact", required: false },{name: "DeliveryAddress", required: false });
														console.log  ( 'NOn Mandatory !!!!!!!!!!');
												}

												else  {
														updateMapNew[oeAtt.guid].push({name: "DeliveryContact", required: true},{name: "DeliveryAddress", required: true });
														console.log  ( 'Made Schema Mandatory !!!!!!!!!!');
												}

											    //updateMapNew[oeAtt.guid] = [];		
												
												
												//updateMapNew[oeAtt.guid].push({name: "DeliveryContact", required: false,value : "" },{name: "DeliveryAddress", required: false,value : "" });
												let keys = Object.keys(updateMapNew);
												var commerciallock = comp.commercialLock;
												if(commerciallock) comp.lock('Commercial', false);															
												
												for(let h=0; h< keys.length;h++){
													await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
												}
												
												//await comp.deleteOrderEnrichmentConfiguration( config.guid, oeAtt.guid,true );
												if(commerciallock) comp.lock('Commercial', true);
												//await config.validate();
												//console.log ( ' Deleted the Configuration!!!!!!!!!!!!!!!!!!!!!!!');
												
											//}

											
											
										}*/
											//EDGE-170544 akanksha added to make MF read only in case of Inflight Change basket for existing subs
										else if (oeNameVal === "MF" &&(window.basketRecordType!==undefined && window.basketRecordType==="Inflight Change" && config.replacedConfigId!==undefined && comp.name=== "Enterprise Mobility"))
										{
											console.log('Inside Inflight Change for MF');
											let updateMap = {};
											if (!updateMap[oeAtt.guid]) 
											updateMap[oeAtt.guid] = [];
											
												updateMap[oeAtt.guid].push({name: "InternationalRoaming", readOnly: true},{name: "callRestriction", readOnly: true},{name: "msgRestriction", readOnly: true},{name: "mmsEnabled", readOnly: true},{name: "dataBarring", readOnly: true});
											
											let keys = Object.keys(updateMap);
											var commerciallock = comp.commercialLock;
											if(commerciallock) 
											await comp.lock('Commercial', false);															
											for(let h=0; h< keys.length;h++){
												await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],true)
												
											}
											if(commerciallock) comp.lock('Commercial', true);
										}
										////EDGE-170544 akanksha ends
									}
								}
								if (Object.keys(updateConfigMapOE).length>0) {
									let keys = Object.keys(updateConfigMapOE);
									var commerciallock = comp.commercialLock;
									if(commerciallock) await comp.lock('Commercial', false);											
									for (let h = 0; h < keys.length; h++) {
										try {
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateConfigMapOE[keys[h]], true);
										//console.log("Updated map sucessfully!!!!!!!!!!!!!!!!!");
									}
									catch(error){
										console.log(error);
									}
									}
									if(commerciallock) comp.lock('Commercial', true);
									
								}
								
								if(Object.keys(updateConfigMapConfig).length>0)
								{
									var commerciallock = comp.commercialLock;
									if(commerciallock) await comp.lock('Commercial', false);									
									let keys = Object.keys(updateConfigMapConfig);
									for(let h=0; h< keys.length;h++){
										await comp.updateConfigurationAttribute(keys[h], updateConfigMapConfig[keys[h]], true); 

									}
									if(commerciallock) comp.lock('Commercial', true);
									//console.log ('Updated map sucessfully for config!!!!!!!!!!!!!!!!!');
								}
								
								/**if(updateMapNew)
								{
									var commerciallock = comp.commerciallock;
									if(commerciallock) comp.lock('Commercial', false);									
									let keys = Object.keys(updateMapNew);
									for(let h=0; h< keys.length;h++){
										await comp.updateConfigurationAttribute(keys[h], updateMapNew[keys[h]], true); 

									}
									if(commerciallock) comp.lock('Commercial', true);
									
									//console.log ('Updated map sucessfully for config!!!!!!!!!!!!!!!!!');
								}	**/							
							}	
							config.validate();//Added to address Issue							
							}

							}
					
					
					//await comp.validate();
				}
			}
			}
		}
		catch(error){
			console.log(error);
		}
	},
	getOEAttributeValues_New: async function (name, schemaName, OEGuId) {
		let oeData = getAllOrderEnrichment_New(schemaName, OEGuId);
		let schemaConfig = oeData.filter(function (item) {
			return item.guid == guid;
		});
		if (schemaConfig.length) {
			let attribute = schemaConfig[0].getAttribute(name);
			let cachedValue = null;
			if (window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]) {
				let cachedAttribute = window.rulesUpdateMap[guid].filter(function (item) {
					return item.name === name;
				});
				if (cachedAttribute && cachedAttribute[0] && typeof cachedAttribute[0].value !== "undefined") {
					cachedValue = cachedAttribute[0].value;
				}
			}
			if (attribute.length) {
				var returnValue = null,
					value = cachedValue ? cachedValue : attribute[0].value;
				switch (attribute.type) {
					case "Date":
						if (value == null || value == "") {
							returnValue = 0;
						} else {
							returnValue = value; //(new Date(value)).setHours(0,0,0,0); INC000093063735 Date Fix issue by ankit
						}
						break;
					default:
						returnValue = value;
						break;
				}
				return returnValue;
			}
		}
		return [];
	},

	getAllOrderEnrichment_New: async function (schemaName, OEGuId) {
		let oeData = CS.SM.getOrderEnrichmentList(schemaName, OEGuId);
		if (oeData.__zone_symbol__state) {
			return oeData.__zone_symbol__value;
		}
	},

	/**********************************************************************************************
	 * Author	   : Laxmi Rahate
	 * Method Name : getAttributeValue
	 * Invoked When: on need
	 * returns teh value of the attribute
	 * EDGE-154663
	 * EDGE-198536 AB: optimized by adding component and configuration params
	 *********************************************************************************************/

	getAttributeValue: async function (attributeName, schemaName, configGUID, configuration, component) {
		var returnAttrVal;
		//if configuration is not provided then get it from configGUID
		if (!configuration) {
            if (component) {
                configuration = component.getConfiguration(configGUID);
            } else {
            	let currentSolution = await CS.SM.getActiveSolution();
            	component = currentSolution.getComponentByName(schemaName);
            	configuration = component.getConfiguration(configGUID);
            }
		}

		if (configuration) {
	        var attributeVal = configuration.getAttribute(attributeName);
			if (attributeVal && attributeVal.value && attributeVal.value != null) {
			    returnAttrVal = attributeVal.value;
			}
		}
		return returnAttrVal;
	},
		/***********************************************************************************************
		 * Author	   : Shubhi Vijayvergia/Aman Soni
		 * EDGE number : EDGE-134880
		 * Method Name : HideShowAttributeLstOnSaveNOnMac()
		 * Invoked When: after config added to macd basket

			***********************************************************************************************/
	HideShowAttributeLstOnMac: async function (mainCompName, componentName, attributeList, guid) {
		let solution = await activeNGEMSolution;
		var comp = solution.getComponentByName(componentName);
		let config = await comp.getConfiguration(guid);
		config.status = true;
		config.statusMessage = "";
		if (config) {
			if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenDevice) {
				var payTypeLookup;
				payTypeLookup = config.getAttribute("PaymentTypeString");
				// var manufacturer = config.getAttribute('MobileHandsetManufacturer');
				// var model = config.getAttribute('MobileHandsetModel');
				// var color = config.getAttribute('MobileHandsetColour');
				// var devType = config.getAttribute('Device Type');
				// var inContractDevEnrElig = config.getAttribute('InContractDeviceEnrollEligibility');
				var ChangeTypeAtr = config.getAttribute("ChangeType");
				var RemainingTermVal = config.getAttribute("RemainingTerm");
				if (payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== "" && payTypeLookup.displayValue === "Hardware Repayment" && config.replacedConfigId) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[13], true, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[11], true, true, false);
				}
				if (config.replacedConfigId && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== "" && payTypeLookup.displayValue === "Purchase") {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[0], true, false, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[15], true, false, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[12], true, true, false); //Added by ankit as part of EDGE-148733
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[11], true, true, false);
				}
				if (config.replacedConfigId && payTypeLookup.displayValue === "Hardware Repayment" && ChangeTypeAtr.displayValue === "Cancel") {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[16], true, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[17], false, true, false);
				}
				if (config.replacedConfigId && ChangeTypeAtr.displayValue === "Active" && RemainingTermVal.displayValue === null) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[12], true, true, false);
				}
				if (config.replacedConfigId) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[10], false, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[29], true, false, false); //Added for EDGE-207352
				}
				if (config.replacedConfigId && window.basketRecordType ==='Inflight Change' ) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[29], true, true, false); //Added for EDGE-207352
				}
				if (config.replacedConfigId && ChangeTypeAtr.displayValue === "PaidOut") {
					//Updated as a part of EDGE-197578
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[10], false, true, false);
				}
				//Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
				if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
					for (var relatedConfig of Object.values(config.relatedProductList)) {
						if (relatedConfig.guid) {
							if(window.basketRecordType !=='Inflight Change'){
								NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
							}else if(window.basketRecordType ==='Inflight Change'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Inflight Amend', false, false, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
							NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
								await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[10], true, true, false);
							}
						}
						}
				}
			}
			//Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
			if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan) {
				var PlanTypeAtr = config.getAttribute("SelectPlanType");
					if (config.guid && config.replacedConfigId !== "" && config.replacedConfigId !== undefined && config.replacedConfigId !== null) {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, config.nextGenPlan, "", attributeList[18], true, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, "", attributeList[10], false, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, "", attributeList[29], true, false, false);

						// Hitesh EDGE-174694 to display change type in case for IR month pass
						if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                            await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Active', false, false, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenPlan);								
							for(var relatedConfig of Object.values(config.relatedProductList)) {
							if(window.basketRecordType !=='Inflight Change'){
								if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
								await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[10], false, true, false);
								await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[24], true, true, false);
								}
                                // Added By Mahima DPG-5776 Cancel Accelerator in MaC- start
								if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.nextGenAccelerator && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
                                    
                                    //await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Active', false, false, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenPlan);
                                    debugger;
                                    await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.nextGenAccelerator, attributeList[10], false, true, false);
                                    await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.nextGenAccelerator, attributeList[50], true, true, false);
								}
								// Added By Mahima DPG-5776 Cancel Accelerator in MaC- end
								
								// Added By Mahima APN Cancel in MaC- start
								if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.dataCustom && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
                                    
                                    //await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Active', false, false, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenPlan);
                                    debugger;
                                    await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.dataCustom, attributeList[10], false, true, false);
                                    await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.dataCustom, attributeList[54], true, true, false);
								}
								// Added By Mahima APN Cancel Accelerator in MaC- end
								// Added By Mahima DPG-5728 Cancel TON in MaC- start
								//if($Label.Is_TON_Enabled=='true'){
									if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.telstraOneNumber && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
										
										await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.telstraOneNumber, attributeList[10], false, true, false);
										await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.telstraOneNumber, attributeList[55], false, true, false);
									}
								//}
								// Added By Mahima DPG-5728 Cancel TON in MaC- end
							}
							else if(window.basketRecordType ==='Inflight Change'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Inflight Amend', false, false, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenPlan);

								if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass) {
									await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[10], true, false, false);
									await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[24], true, true, false);
								}
								else if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.internationalDirectDial) {
									await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.internationalDirectDial, attributeList[40], true, true, false);
								}
								else if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.dataFeatures ) {
									await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.dataFeatures, attributeList[41], true, true, false);
								}
								else if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.messageBank) {
									await NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.messageBank, attributeList[42], true, true, false);
								}
								}
							}
						}
					}
					//Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End	
				if (config.guid && config.replacedConfigId && window.basketRecordType ==='Inflight Change') {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, '', attributeList[22], true, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, '', attributeList[29], true, true, false); //Added for EDGE-207352

				}
			}
			//Block used to do manipulations/calling methods for - 'Transition Device' || Start
			if (componentName === NXTGENCON_COMPONENT_NAMES.transitionDevice) {
				var ChangeTypeAtrTrD = config.getAttribute("ChangeType");
				let RemainingTermValue = config.getAttribute("RemainingTerm");
				if (config.guid && config.replacedConfigId !== "" && config.replacedConfigId !== undefined && config.replacedConfigId !== null) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[10], false, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[31], false, false, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[29], true, false, false); //Added for EDGE-207352

				
				}	
				if (config.replacedConfigId && RemainingTermValue && RemainingTermValue.value <= 0) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[33], true, false, false);
				}
				if (config.replacedConfigId && window.basketRecordType ==='Inflight Change') {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[29], true, true, false);//Added for EDGE-207352
				}
		}
		//Block used to do manipulations/calling methods for - 'Transition Device' || End
			//Block used to do manipulations/calling methods for 'Accessory' || Added by Radhika for EDGE-195101 || Start
			if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenAccessory) {
					
				if (config.guid && config.replacedConfigId ) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenAccessory, '', attributeList[29], true, false, false);
				}

				if (config.guid && config.replacedConfigId && window.basketRecordType ==='Inflight Change') {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenAccessory, '', attributeList[43], true, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenAccessory, '', attributeList[29], true, true, false); //Added for EDGE-207352

				}
				//Added for EDGE-207352
				
			}
			//Block used to do manipulations/calling methods for ' Transition Accessory' || Added by Aditya for EDGE-207352 || End 
			if (componentName === NXTGENCON_COMPONENT_NAMES.transitionAccessory) {
				//DPG-6180 Fix || Ila Start
				let RemainingTermValue = config.getAttribute("RemainingTerm");
				if (config.guid && config.replacedConfigId !== "" && config.replacedConfigId !== undefined && config.replacedConfigId !== null) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, "", attributeList[10], false, true, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, "", attributeList[31], false, false, false);
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, "", attributeList[29], true, false, false); //Added for EDGE-207352

				
				}	
				if (config.replacedConfigId && RemainingTermValue && RemainingTermValue.value <= 0) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, "", attributeList[33], true, false, false);
				}
				//DPG-6180 Fix || Ila End
				if (config.guid && config.replacedConfigId ) {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, '', attributeList[29], true, false, false);
				}
				if (config.guid && config.replacedConfigId && window.basketRecordType ==='Inflight Change') {
					NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, '', attributeList[29], true, true, false); //Added for EDGE-207352

				}
			}
			//Block used to do manipulations/calling methods for ' Transition Accessory' || Added by Aditya for EDGE-207352 || End 
		}
	},
	/***********************************************************************************************
		 * Author	   : Shubhi Vijayvergia/Aman Soni
		 * EDGE number : EDGE-134880
		 * Method Name : HideShowAttributeLstOnSaveNOnMac()
		 * Invoked When: after config added to macd basket
	***********************************************************************************************/
	HideShowAttributeLstOnSaveOnMac: async function (attributeList) {
		let mainCompName=NXTGENCON_COMPONENT_NAMES.nxtGenMainSol;
		let solution = await activeNGEMSolution;
		var deviceComp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
		let deviceConfigs = await deviceComp.getConfigurations();
		if (deviceConfigs) {
			for(var config of Object.values(deviceConfigs)){
				if (deviceComp.name === NXTGENCON_COMPONENT_NAMES.nextGenDevice) {
					let componentName=NXTGENCON_COMPONENT_NAMES.nextGenDevice;
					var payTypeLookup;
					payTypeLookup = config.getAttribute("PaymentTypeString");
					var ChangeTypeAtr = config.getAttribute("ChangeType");
					var RemainingTermVal = config.getAttribute("RemainingTerm");
					if (payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== "" && payTypeLookup.displayValue === "Hardware Repayment" && config.replacedConfigId) {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[13], true, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[11], true, true, false);
					}
					if (config.replacedConfigId && payTypeLookup.displayValue !== null && payTypeLookup.displayValue !== "" && payTypeLookup.displayValue === "Purchase") {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[15], true, false, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[12], true, true, false); //Added by ankit as part of EDGE-148733
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[11], true, true, false);
					}
					if (config.replacedConfigId && payTypeLookup.displayValue === "Hardware Repayment" && ChangeTypeAtr.displayValue === "Cancel") {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[16], true, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[17], false, true, false);
					}
					if (config.replacedConfigId && ChangeTypeAtr.displayValue === "Active" && RemainingTermVal.displayValue === null) {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[12], true, true, false);
					}
					if (config.replacedConfigId) {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName, "", attributeList[10], false, true, false);
					}
					if (config.replacedConfigId && ChangeTypeAtr.displayValue === "PaidOut") {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, componentName,'', attributeList[47], true, false, false);
					}
					//Block used to do manipulations for Related Component - 'Mobile Device Care' || Start
					if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
						Object.values(config.relatedProductList).forEach((relatedConfig) => {
							var ChildChangeTypeAtr = relatedConfig.configuration.getAttribute("ChangeType");
							if (relatedConfig.guid && relatedConfig.configuration.replacedConfigId) { //INC000094689212 added condition //EDGE-197578
								NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare, attributeList[14], true, true, false);
								// Added as a part of EDGE-197578 Start
								if(ChildChangeTypeAtr.displayValue!= 'PaidOut' && ChangeTypeAtr.displayValue == 'No Fault Return' ){
									NextGenMobHelper.updatechildAttfromParent('ChangeType', 'No Fault Return', true, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
								   }
								   else if(ChildChangeTypeAtr.displayValue!= 'PaidOut' && (ChangeTypeAtr.displayValue == 'Cancel' || ChangeTypeAtr.displayValue == 'PaidOut') ){
									   NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Active', true, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
									   NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Cancel', false, true, config.guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
								   }
								   if(ChildChangeTypeAtr.displayValue== 'PaidOut')	{
									NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, componentName,'', attributeList[10], true, true, false);
								}
								   // EDGE-197578 End
							}
						});
					}
				}
			}
		}
		var planComp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
		let planConfigs = await planComp.getConfigurations();
		if(planConfigs){
			for(var config of Object.values(planConfigs)){
				//if (planComp.name === NXTGENCON_COMPONENT_NAMES.nextGenPlan) {
					var PlanTypeAtr = config.getAttribute("SelectPlanType");
					//let configs = planComp.getConfigurations();//commented for INC000097831064 
					//if (configs){//commented for INC000097831064 
						//for(var planConfig of Object.values(configs)){//commented for INC000097831064 
							if (config.guid && config.replacedConfigId !== "" && config.replacedConfigId !== undefined && config.replacedConfigId !== null) {
								NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, "", attributeList[18], true, true, false);
								NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, "", attributeList[10], false, true, false);
								// Hitesh EDGE-174694 to display change type in case for IR month pass
								if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
									Object.values(config.relatedProductList).forEach((relatedConfig) => {
										if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[10], false, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass, attributeList[24], true, true, false);
										}
                                        //Mahima- DPG-5776- to display change type in case for Accelerator
                                        if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.nextGenAccelerator && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.nextGenAccelerator, attributeList[10], false, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.nextGenAccelerator, attributeList[50], true, true, false);
										}
                                    	//Mahima- display change type in case for APN MACD
                                        if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.dataCustom && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataCustom, attributeList[10], false, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataCustom, attributeList[54], true, true, false);
										}
										// Added By Mahima DPG-5728 Cancel TON in MaC- start
										//if($Label.Is_TON_Enabled=='true'){
											if (relatedConfig.guid && relatedConfig.name === NXTGENCON_COMPONENT_NAMES.telstraOneNumber && relatedConfig.guid !== '' && relatedConfig.guid !== undefined && relatedConfig.guid !== null && relatedConfig.configuration.replacedConfigId) {												
												NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.telstraOneNumber, attributeList[10], false, true, false);
												NextGenMobHelper.HideShowAttributeLst(false, true, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, NXTGENCON_COMPONENT_NAMES.telstraOneNumber, attributeList[55], true, true, false);
											}
										//}
										// Added By Mahima DPG-5728 Cancel TON in MaC- end
									});
								}
							}
							//Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End	
					//}
				//}
				/*if (componentName === NXTGENCON_COMPONENT_NAMES.transitionDevice) {
					if (config.guid && config.replacedConfigId !== "" && config.replacedConfigId !== undefined && config.replacedConfigId !== null) {
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[10], false, true, false);
						NextGenMobHelper.HideShowAttributeLst(false, false, config.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, "", attributeList[31], false, false, false);
					}	
					*/ //commented for INC000097831064 
			}
		}
    },
	/***********************************************************************************************
 * Author	   : Shubhi Vijayvergia/Aman Soni
 * EDGE number : EDGE-134880
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

    ***********************************************************************************************/
	UpdateRelatedConfigForChild: async function (guid) {
		if (!window.BasketChange || window.BasketChange === "") return;
		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.componentType) {
			window.currentSolutionName = loadedSolution.name;
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				let comp = await loadedSolution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
				//Object.values(loadedSolution.components).forEach((comp) => {
					let subsConfig= comp.getConfiguration(guid);					
					if (subsConfig && subsConfig.name.includes(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan) && subsConfig.replacedConfigId && subsConfig.disabled === false && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
						subsConfig.relatedProductList.forEach(async (relatedConfig) => {
							if(relatedConfig.configuration.replacedConfigId==''){
								console.log('related Config Name:--'+relatedConfig.name);
								let inputMap = {};
								inputMap["GetConfigurationId"] = relatedConfig.guid;
								inputMap["basketId"] = basketId;
								let activeNGEMBasket = await CS.SM.getActiveBasket();
								await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
									var replaceId = result["replacedConfigid"];
									var configGuid = result["childGuid"];
									//var relatedConfigId = result["childId"];
									if (configGuid === relatedConfig.guid) {
									    relatedConfig.configuration.replacedConfigId = replaceId;
									    console.log(replaceId+'---'+configGuid);
									}
									//relatedConfig.configuration.id = relatedConfigId;
								});
							}
						});
					
					}
				//});
			}
			return Promise.resolve(true);
		}
	},
	/***********************************************************************************************
     * Author	   : Shubhi Vijayvergia/Aman soni
     * EDGE number : EDGE-134880
     * Method Name : EMPlugin_ChangeOptionValue()
     * Invoked When: After attribute changes
     * Description : Update Replace ConfigId

 ***********************************************************************************************/
	ChangeOptionValueNGEMPlan: async function (guid) {
		var updateMap = {};
		var optionValues = [];
		optionValues = [CommonUtills.createOptionItem("Modify"), CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.componentType) {
			window.currentSolutionName = loadedSolution.name;
			let comp = loadedSolution.getComponentByName("Enterprise Mobility");
			if (comp) {
				let config = comp.getConfiguration(guid);
				if (config) {

					updateMap[config.guid] = [

						{
							name: "ChangeType",
							options: optionValues
						}
					];
				}
			}
			let keys = Object.keys(updateMap);
			var complock = comp.commercialLock;
			if (complock) comp.lock("Commercial", false);
			for (let i = 0; i < keys.length; i++) {
				comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
		}
		return Promise.resolve(true);
	},

	ChangeOptionValueNGEMDevice: async function (guid) {
		var updateMap = {};
		var optionValues = [];
		optionValues = [CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("No Fault Return")]; // EDGE-197578 //R34UPGRADE

		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.componentType) {
			window.currentSolutionName = loadedSolution.name;
			let comp = loadedSolution.getComponentByName("Device");
			if (comp) {
				let subsConfig = comp.getConfiguration(guid);
				if (subsConfig.guid === guid) {
					updateMap[subsConfig.guid] = [
						{
							name: "ChangeType",
							options: optionValues
						}
					];
				}
				let keys = Object.keys(updateMap);
				var complock = comp.commercialLock;
				for (let i = 0; i < keys.length; i++) {
					comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
			return Promise.resolve(true);
		}
	},
	/***********************************************************************************************
 * Author	   : Shubhi Vijayvergia
 * EDGE number : EDGE-169973
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

    ***********************************************************************************************/
	/*UpdateRelatedConfigForChildMac: async function (guid, componentName) {
		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.componentType && loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
			window.currentSolutionName = loadedSolution.name;
			let comp = loadedSolution.getComponentByName(componentName);
			if (comp) {
				let subsConfig = comp.getConfiguration(guid);
				if (subsConfig.disabled === false && guid === subsConfig.guid && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
					subsConfig.relatedProductList.forEach(async (relatedConfig) => {
						let inputMap = {};
						inputMap["GetConfigurationId"] = relatedConfig.guid;
						inputMap["basketId"] = basketId;
						await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
							var replaceId = result["replacedConfigid"];
							var configGuid = result["childGuid"];
							var relatedConfigId = result["childId"];
							if (configGuid === relatedConfig.guid) relatedConfig.configuration.replacedConfigId = replaceId;
							relatedConfig.configuration.id = relatedConfigId;
						});
					});
				}
			}
			return Promise.resolve(true);
		}
	},
    */
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-169973
	 * Method Name : handleReloadinMacd()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadinMacd: async function () {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
		var updateConfigMap = {};
		if (comp) {
			let configs = comp.getConfigurations();
			if (configs) {
				for (var config of Object.values(configs)) {
					let cta = config.getAttribute("ChangeType");
					payTypeLookup = config.getAttribute("PaymentTypeString");
					let contractTermval = config.getAttribute("ContractTerm");
					let RemainingTermValue = config.getAttribute("RemainingTerm");
					var payTypeLookupVal = "";
					var payTypeDisplayValue = "";
				// Added below to fix issue of undefined
					if (payTypeLookup && payTypeLookup.value && payTypeLookup.value != null) {
						payTypeLookupVal = payTypeLookup.value;
						payTypeDisplayValue = payTypeLookup.displayValue;
					}

					if (payTypeDisplayValue === "Purchase" && config.replacedConfigId && !config.disabled && cta.displayValue!=='No Fault Return') { //added nfr check for DIGI-11546
						updateConfigMap[config.guid] = [];
						updateConfigMap[config.guid] = [
							{
								name: "TotalFundAvailable",
								value: currentFundBalance,
								displayValue: currentFundBalance,
								showInUi: true,
								readOnly: true
							},
							{
								name: "RedeemFund",
								value: 0,
								displayValue: 0,
								showInUi: true,
								readOnly: true
                            },
                            {   //Added EDGE-175750
								name: "RedeemFundIncGST",
								value: 0,
								displayValue: 0,
								showInUi: true,
								readOnly: true
							},
							{
								name: "ChangeType",
								value: "PaidOut",
								displayValue: "PaidOut",
								options: [CommonUtills.createOptionItem("PaidOut"),CommonUtills.createOptionItem("No Fault Return")],//R34 upgrade // EDGE-197578 
								showInUi: true,
								readOnly: false
							}
						];
						if (config.relatedProductList.length >= 0) {
							for (var ReletedConfig of config.relatedProductList) {
								if (ReletedConfig.guid && ReletedConfig.ReletedConfig) {
									updateConfigMap[ReletedConfig.guid] = [
										{
											name: "TotalFundAvailable",
											value: currentFundBalance,
											displayValue: currentFundBalance,
											showInUi: true,
											readOnly: true
										},
										{
											name: "RedeemFund",
											value: 0,
											displayValue: 0,
											showInUi: true,
											readOnly: true
                                        },
                                        {   //Added EDGE-175750
                                            name: "RedeemFundIncGST",
											value: 0,
											displayValue: 0,
											showInUi: true,
											readOnly: true
                                        }
									];
								}
							}
						}
					}
					if (payTypeDisplayValue === "Hardware Repayment" && config.replacedConfigId && !config.disabled) {
						if (RemainingTermValue && RemainingTermValue && RemainingTermValue.value <= 0) {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "TotalFundAvailable",
									value: currentFundBalance,
									displayValue: currentFundBalance,
									showInUi: false,
									readOnly: true
								},
								{
									name: "RedeemFund",
									value: 0,
									displayValue: 0,
									showInUi: false,
									readOnly: true
                                },
                                {
									name: "RedeemFundIncGST",
									value: 0,
									displayValue: 0,
									showInUi: false,
									readOnly: true
								},
								{
									name: "ChangeType",
									value: "PaidOut",
									displayValue: "PaidOut",
									showInUi: true,
									readOnly: true
								}
							];
						} else if (cta && cta.value === "Cancel") {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "TotalFundAvailable",
									value: currentFundBalance,
									displayValue: currentFundBalance,
									showInUi: true,
									readOnly: true
								},
								{
									name: "RedeemFund",
									value: 0,
									displayValue: 0,
									showInUi: true,
									readOnly: false
								},
								{   //Added EDGE-175750
									name: "RedeemFundIncGST",
									value: 0,
									displayValue: 0,
									showInUi: true,
									readOnly: false
								}
							];
						}
					}
				}
			}
			var complock = comp.commercialLock; //added by shubhi for EDGE-169593
			if (complock) comp.lock("Commercial", false);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
			if (complock) comp.lock("Commercial", true);
			//if(complock) comp.lock('Commercial', true);//added by shubhi for EDGE-169593
		}
		return Promise.resolve(true);
	},
		/***********************************************************************************************
	 * Author	   : Aditya Pareek
	 * EDGE number : EDGE-173696
	 * Method Name : handleReloadinMacdTransDevice()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadinMacdTransDevice: async function () {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
		var updateConfigMap = {};
		if (comp) {
			let configs = comp.getConfigurations();
			if (configs) {
				for (var config of Object.values(configs)) {
					let RemainingTermValue = config.getAttribute("RemainingTerm");
				// Added below to fix issue of undefined
					if (config.replacedConfigId && !config.disabled) {
						if (RemainingTermValue && RemainingTermValue && RemainingTermValue.value <= 0) {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "ChangeType",
									value: "PaidOut",
									displayValue: "PaidOut",
									showInUi: true,
									readOnly: true
								}
							];
						} 
					}
				}
			}
			var complock = comp.commercialLock; //added by shubhi for EDGE-169593
			if (complock) comp.lock("Commercial", false);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
			if (complock) comp.lock("Commercial", true);
			//if(complock) comp.lock('Commercial', true);//added by shubhi for EDGE-169593
		}
		return Promise.resolve(true);
	},
    
     /***********************************************************************************************
	 * Author	   : Krunal Taak
	 * EDGE number : DPG-5621
	 * Method Name : handleReloadinMacdAccessory()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadinMacdAccessory: async function () {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory);
		var updateConfigMap = {};
		if (comp) {
			let configs = comp.getConfigurations();
			if (configs) {
				for (var config of Object.values(configs)) {
					let cta = config.getAttribute("ChangeType");
					payTypeLookup = config.getAttribute("PaymentTypeShadow");
					let contractTermval = config.getAttribute("ContractTerm");
					let RemainingTermValue = config.getAttribute("RemainingTerm");
					var payTypeLookupVal = "";
					var payTypeDisplayValue = "";
				// Added below to fix issue of undefined
					if (payTypeLookup && payTypeLookup.value && payTypeLookup.value != null) {
						payTypeLookupVal = payTypeLookup.value;
						payTypeDisplayValue = payTypeLookup.displayValue;
					}

					if (payTypeDisplayValue === "Purchase" && config.replacedConfigId && !config.disabled) {
						updateConfigMap[config.guid] = [];
						updateConfigMap[config.guid] = [
							{
								name: "TotalFundAvailable",
								value: currentFundBalance,
								displayValue: currentFundBalance,
								showInUi: true,
								readOnly: true
							},
							{
								name: "RedeemFund",
								value: 0,
								displayValue: 0,
								showInUi: true,
								readOnly: true
                            },
                            {   //Added EDGE-175750
								name: "RedeemFundIncGST",
								value: 0,
								displayValue: 0,
								showInUi: true,
								readOnly: true
							},
							{
								name: "ChangeType",
								value: "PaidOut",
								displayValue: "PaidOut",
								//options: ["PaidOut"], // EDGE-197578 
								showInUi: true,
								readOnly: true
							}
						];
						if (config.relatedProductList.length >= 0) {
							for (var ReletedConfig of config.relatedProductList) {
								if (ReletedConfig.guid && ReletedConfig.ReletedConfig) {
									updateConfigMap[ReletedConfig.guid] = [
										{
											name: "TotalFundAvailable",
											value: currentFundBalance,
											displayValue: currentFundBalance,
											showInUi: true,
											readOnly: true
										},
										{
											name: "RedeemFund",
											value: 0,
											displayValue: 0,
											showInUi: true,
											readOnly: true
                                        },
                                        {   //Added EDGE-175750
                                            name: "RedeemFundIncGST",
											value: 0,
											displayValue: 0,
											showInUi: true,
											readOnly: true
                                        }
									];
								}
							}
						}
					}
					if (payTypeDisplayValue === "Hardware Repayment" && config.replacedConfigId && !config.disabled) {
						if (RemainingTermValue && RemainingTermValue && RemainingTermValue.value <= 0) {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "TotalFundAvailable",
									value: currentFundBalance,
									displayValue: currentFundBalance,
									showInUi: false,
									readOnly: true
								},
								{
									name: "RedeemFund",
									value: 0,
									displayValue: 0,
									showInUi: false,
									readOnly: true
                                },
                                {
									name: "RedeemFundIncGST",
									value: 0,
									displayValue: 0,
									showInUi: false,
									readOnly: true
								},
								{
									name: "ChangeType",
									value: "PaidOut",
									displayValue: "PaidOut",
									showInUi: true,
									readOnly: true
								}
							];

						} else if (RemainingTermValue && RemainingTermValue && RemainingTermValue.value > 0) {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "ChangeType",
									//value: "Cancel",
									//displayValue: "Cancel",
									showInUi: true,
									readOnly: false
								}
							];
						} else if (cta && cta.value === "Cancel") {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "TotalFundAvailable",
									value: currentFundBalance,
									displayValue: currentFundBalance,
									showInUi: true,
									readOnly: true
								},
								{
									name: "RedeemFund",
									value: 0,
									displayValue: 0,
									showInUi: true,
									readOnly: false
								},
								{   //Added EDGE-175750
									name: "RedeemFundIncGST",
									value: 0,
									displayValue: 0,
									showInUi: true,
									readOnly: false
								}
							];
						}
					}
				}
			}
			var complock = comp.commercialLock; //added by shubhi for EDGE-169593
			if (complock) comp.lock("Commercial", false);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
			if (complock) comp.lock("Commercial", true);
			//if(complock) comp.lock('Commercial', true);//added by shubhi for EDGE-169593
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	 * Author	   : Krunal Taak
	 * EDGE number : DPG-5621
	 * Method Name : handleReloadinMacdTransAccessory()
	 * Invoked When: On solution load and add to macd
	 * Description : on reload
	 ***********************************************************************************************/
	handleReloadinMacdTransAccessory: async function () {
		let product = await CS.SM.getActiveSolution();
		let comp = await product.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
		var updateConfigMap = {};
		if (comp) {
			let configs = comp.getConfigurations();
			if (configs) {
				for (var config of Object.values(configs)) {
					let RemainingTermValue = config.getAttribute("RemainingTerm");
				// Added below to fix issue of undefined
					if (config.replacedConfigId && !config.disabled) {
						if (RemainingTermValue && RemainingTermValue && RemainingTermValue.value <= 0) {
							updateConfigMap[config.guid] = [];
							updateConfigMap[config.guid] = [
								{
									name: "ChangeType",
									value: "PaidOut",
									displayValue: "PaidOut",
									showInUi: true,
									readOnly: true
								}
							];
						} 
					}
				}
			}
			var complock = comp.commercialLock; //added by shubhi for EDGE-169593
			if (complock) comp.lock("Commercial", false);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
			if (complock) comp.lock("Commercial", true);
			//if(complock) comp.lock('Commercial', true);//added by shubhi for EDGE-169593
		}
		return Promise.resolve(true);
	},
     
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-169973
	 * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
	 * Invoked When: On related product add to update attributes from parent to child or to default any value
	 ***********************************************************************************************/

	UpdateChildAttributedonAdd: async function (mainCompName, configGuid, component, relatedProduct) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			if (solution.components && Object.values(solution.components).length > 0) {
				var solutionOfferId = "";
				var solutionaccountId="";//Monali for AccountID DPG-5295
				let configs = solution.getConfigurations();
				for (var solConfig of Object.values(configs)) {
					if (solConfig.guid) {
						let offerId = solConfig.getAttribute("OfferId");
						if (offerId && offerId.value) {
							solutionOfferId = offerId.value;
						}
						break;
					}
				}
				//Start Monali - 1 for DPG-5295
				for (var solConfig of Object.values(configs)) {
					if (solConfig.guid) {
						let accountId = solConfig.getAttribute("AccountID");
						if (accountId && accountId.value) {
							solutionaccountId = accountId.value;
						}
						break;
					}
				}
				//End Monali - 1 for DPG-5295
				var comp = await solution.getComponentByName(component.name);
				var config = await comp.getConfiguration(configGuid);
				var selectPlanParent = "";
				if (config.guid) {
					var planAtt = config.getAttribute("Select Plan");
					if (planAtt && planAtt.value) {
						selectPlanParent = planAtt.value;
					}
				}
				var updateMapChild = {};
				if (relatedProduct.configuration.attributes) {
					updateMapChild[relatedProduct.guid] = [];
					updateMapChild[relatedProduct.guid].push(
						{
							name: "OfferId",
							showInUi: false,
							readOnly: true,
							value: solutionOfferId,
							displayValue: solutionOfferId
						},
						{
							name: "Select Plan",
							showInUi: false,
							readOnly: true,
							value: selectPlanParent,
							displayValue: selectPlanParent
						}
						//Start Monali - 2 for DPG-5295
						,
						{
							name: "AccountID",
							showInUi: false,
							readOnly: true,
							value: solutionaccountId,
							displayValue: solutionaccountId
						}
						//End Monali - 2 for DPG-5295-thorughVS code
					);
				}

				let keys = Object.keys(updateMapChild);
				for (let i = 0; i < keys.length; i++) {
					comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
				}
			}
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-169973
	 * Method Name : updatechildAttfromParent(attTobeUpdated,value,guid,compname)
	 * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
	 * Invoked When: On after parent attribute update  to update attributes from parent to child
	 ***********************************************************************************************/
	updatechildAttfromParent: async function (attTobeUpdated, value, readOnly, showInUi, guid, compname) {
		var solution = await CS.SM.getActiveSolution();
		var comp = await solution.getComponentByName(compname);
		var config = await comp.getConfiguration(guid);
		var updateMapChild = {};
		if (config.relatedProductList.length >= 0) {
			for (var ReletedConfig of config.relatedProductList) {
				if (ReletedConfig.guid) {
					updateMapChild[ReletedConfig.guid] = [
						{
							name: attTobeUpdated,
							value: value,
							displayValue: value,
							showInUi: showInUi,
							readOnly: readOnly
						}
					];
				}
			}
			let keys = Object.keys(updateMapChild);
			for (let i = 0; i < keys.length; i++) {
				comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
			}
		}
		return Promise.resolve(true);
	},
	/***********************************************************************************************
	 * Author	   : Shubhi Vijayvergia
	 * EDGE number : EDGE-169973
	 * Method Name : emptyChildAttfromParent(attTobeUpdated,value,guid,compname)
	 * Method Name : UpdateChildAttributedonAdd(mainCompName,configGuid,component,relatedProduct)
	 * Invoked When: On after parent attribute update  to update attributes from parent to child
	 ***********************************************************************************************/
	emptyChildAttfromParent: async function (attTobeUpdatedList, guid, compname, relatedProductName) {
		var solution = await CS.SM.getActiveSolution();
		var comp = await solution.getComponentByName(compname);
		var config = await comp.getConfiguration(guid);
		var updateMapChild = {};
		if (!config.replacedConfigId && config.relatedProductList.length >= 0) {
			for (var ReletedConfig of config.relatedProductList) {
				if (ReletedConfig.guid && ReletedConfig.name === relatedProductName) {
					updateMapChild[ReletedConfig.guid] = [];
					for (var i = 0; i < attTobeUpdatedList.length; i++) {
						updateMapChild[ReletedConfig.guid].push({
							name: attTobeUpdatedList[i],
							value: "",
							displayValue: ""
						});
					}
				}
			}
			let keys = Object.keys(updateMapChild);
			for (let i = 0; i < keys.length; i++) {
				comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
			}
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
	 * Author	: shubhi Vijayvergia
	 * edge     :166327
	 * Method Name : autoDeleterelatedProductonPlanChange,
	 * Invoked When: on parent config uis added
	 * Description :  on parent config uis added
	 * Parameters :value,guid,component
	 ***********************************************************************************/
	autoDeleterelatedProductonPlanChange: async function (planValue, guid, component) {
		var config = await component.getConfiguration(guid);
		if (!config.replacedConfigId && config.relatedProductList.length >= 0 && relatedprodtobeautodeleted) {
			for (var ReletedConfig of config.relatedProductList) {
				for (var relProdname of relatedprodtobeautodeleted) {
					if (ReletedConfig.guid && ReletedConfig.name === relProdname) {
						await component.deleteRelatedProduct(guid, ReletedConfig.guid, true);
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
	 * Author	: shubhi Vijayvergia
	 * edge     :EDGE-160037
	 * Method Name : autoDeleterelatedProductonPlanChange,
	 * Invoked When: on parent config uis added
	 * Description :  on parent config uis added
	 * Parameters :value,guid,component
	 ***********************************************************************************/
	autoUpdateAddonAfterPlanChangeinMac: async function (planValue, guid, component, relatedProductName, attributename, chargeId) {
		let updateMapChild = {};
		//let activeNGEMBasket = activeNGEMBasket;
		var config = await component.getConfiguration(guid);
		if (config.replacedConfigId && config.relatedProductList.length >= 0 && planValue != "") {
			for (var ReletedConfig of config.relatedProductList) {
				if (relatedProductName === ReletedConfig.name) {
					var addonName = "";
					var offer = "";
					var relConfig = await component.getConfiguration(ReletedConfig.guid);
					const IDD_ChargeLookup = relConfig.getAttribute(attributename);
					const offerid = relConfig.getAttribute("OfferId");
					addonName = IDD_ChargeLookup.displayValue;
					offer = offerid.value;
					let inputMap = {};
					inputMap["offerid"] = offer;
					inputMap["getAddonPriceItemAssociation"] = "";
					inputMap["chargeid"] = chargeId;
					inputMap["plan"] = planValue;
					inputMap["addonName"] = addonName;
					var AddonAssoc = {};
					if (addonName != "") {
						await activeNGEMBasket.performRemoteAction("MobileSubscriptionGetAddOnData", inputMap).then((response) => {
							if (response && response["getAddonPriceItemAssociation"] != undefined) {
								AddonAssoc = response["getAddonPriceItemAssociation"];
								if (AddonAssoc) {
									updateMapChild[ReletedConfig.guid] = [];
									updateMapChild[ReletedConfig.guid].push({
										name: attributename,
										value: AddonAssoc.Id,
										displayValue: AddonAssoc.AddOnName__c,
										lookup: AddonAssoc
									});
								} else {
									ReletedConfig.status = false;
									ReletedConfig.message = "Existing configured BoltOn is not applicable for the selected Plan";
								}
							} else {
								ReletedConfig.status = false;
								ReletedConfig.message = "Existing configured BoltOn is not applicable for the selected Plan";
							}
						});
					}
				}
			}
			let keys = Object.keys(updateMapChild);
			for (let i = 0; i < keys.length; i++) {
				component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false);
			}
		}
		return Promise.resolve(true);
	},
	/********************************************************************************
	 * Author	: shubhi Vijayvergia
	 * edge     :160037
	 * Method Name : autoDeleterelatedProductonPlanChange,
	 * Invoked When: on parent config uis added
	 * Description :  on parent config uis added
	 * Parameters :value,guid,component
	 ***********************************************************************************/
	autoUpdatedatafeaturesonPlanChangeinMac: async function (planValue, guid, component, relatedProductName) {
		let updateMapChild = {};
		//let activeNGEMBasket = activeNGEMBasket;
		var config = await component.getConfiguration(guid);
		if (config.replacedConfigId && config.relatedProductList.length >= 0) {
			for (var ReletedConfig of config.relatedProductList) {
				if (relatedProductName === ReletedConfig.name) {
					updateMapChild[ReletedConfig.guid] = [];
					var addonNameList = "";
					var chargeIdList = "DMCAT_NonRecurringCharge_001273,DMCAT_NonRecurringCharge_001274,DMCAT_RecurringCharge_001277";
					var offer = "";
					var planId = planValue;
					var relConfig = await component.getConfiguration(ReletedConfig.guid);
					const AutoDataTopup = relConfig.getAttribute("AutoDataTopup");
					if (AutoDataTopup && AutoDataTopup.displayValue != undefined && AutoDataTopup.displayValue != "") addonNameList += AutoDataTopup.displayValue + ",";
					const UnshapeUserChargeLookup = relConfig.getAttribute("UnshapeUserChargeLookup");
					if (UnshapeUserChargeLookup && UnshapeUserChargeLookup.displayValue != undefined && UnshapeUserChargeLookup.displayValue != "") addonNameList += UnshapeUserChargeLookup.displayValue + ",";
					const BusinessDemandData = relConfig.getAttribute("BusinessDemandData");
					addonNameList += BusinessDemandData.displayValue;
					const offerid = relConfig.getAttribute("OfferId");
					offer = offerid.value;
					let inputMap = {};
					inputMap["offerid"] = offerid.value;
					inputMap["getAddonPriceItemAssociationBulk"] = "";
					inputMap["chargeidList"] = chargeIdList;
					inputMap["plan"] = planId;
					inputMap["addonNameList"] = addonNameList;
					var AddonAssocMap = {};
					await activeNGEMBasket.performRemoteAction("MobileSubscriptionGetAddOnData", inputMap).then((response) => {
						if (response && response["setAddonPriceItemAssociation"] != undefined) {
							AddonAssocMap = response["setAddonPriceItemAssociation"];
							if (AddonAssocMap) {
								Object.keys(AddonAssocMap).forEach((chargeid) => {
									var addonAss = AddonAssocMap[chargeid];
									if (AutoDataTopup && AutoDataTopup.displayValue != undefined && AutoDataTopup.displayValue != "" && chargeid === "DMCAT_NonRecurringCharge_001273" && addonAss.cspmb__Add_On_Price_Item__r.addOn_Name__c === AutoDataTopup.displayValue) {
										updateMapChild[ReletedConfig.guid].push({
											name: "AutoDataTopup",
											value: addonAss.Id,
											displayValue: addonAss.AddOnName__c,
											lookup: addonAss
										});
									} else if (UnshapeUserChargeLookup && UnshapeUserChargeLookup.displayValue != undefined && UnshapeUserChargeLookup.displayValue != "" && chargeid === "DMCAT_NonRecurringCharge_001274" && addonAss.cspmb__Add_On_Price_Item__r.addOn_Name__c === UnshapeUserChargeLookup.displayValue) {
										updateMapChild[ReletedConfig.guid].push({
											name: "UnshapeUserChargeLookup",
											value: addonAss.Id,
											displayValue: addonAss.AddOnName__c,
											lookup: addonAss
										});
									} else if (chargeid === "DMCAT_RecurringCharge_001277" && addonAss.cspmb__Add_On_Price_Item__r.addOn_Name__c === BusinessDemandData.displayValue) {
										updateMapChild[ReletedConfig.guid].push({
											name: "BusinessDemandData",
											value: addonAss.Id,
											displayValue: addonAss.AddOnName__c,
											lookup: addonAss
										});
									}
								});
							}
						}
					});
				}
			}
			let keys = Object.keys(updateMapChild);
			for (let i = 0; i < keys.length; i++) {
				component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false);
			}
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
	 * Author	  	: Aditya Pareek
	 * Method Name 	: Update_UnshapeUser_OnDataFeat
	 * Invoked When	: On 'SelectPlanType' Change
	 * Sprint	  	: 20.12 (EDGE-157745)
	 * Parameters  	: guid
	 ***********************************************************************************/
	Update_UnshapeUser_OnDataFeat: async function (guid) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			var updateMapUnshpUsr = {};
			let comp = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
			if (comp) {
				let config = comp.getConfiguration(guid);
				if (config) {
					let selectPlanTypeUpd = config.getAttribute("SelectPlanType");
					if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
						Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
							if (relatedConfig.name.includes(NXTGENCON_COMPONENT_NAMES.dataFeatures) && relatedConfig.guid) {
								if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
									updateMapUnshpUsr[relatedConfig.guid] = [];
									if (selectPlanTypeUpd.displayValue != "" && selectPlanTypeUpd.displayValue === NGEMPLans.Enterprise_Wireless) {
										updateMapUnshpUsr[relatedConfig.guid].push({
											name: "UnshapeUser",
											value: false,
											displayValue: false
										});
									}
								}
								let keys = Object.keys(updateMapUnshpUsr);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateMapUnshpUsr[keys[i]], false);
								}
							}
						});
					}
				}
			}
		}
	},
	/********************************************************************************
	 * Author	: shubhi Vijayvergia
	 * edge     :160037
	 * Method Name : defaultAddonsonPlanChange,
	 * Parameters :value,guid,component
	 ***********************************************************************************/
	defaultAddonsonPlanChange: async function (planValue, guid, component, configuration) {
		let updateMapChild = {};
		var AddonAssocMap = {};
		var config = await component.getConfiguration(guid);
		var addonNameList = "";
		var chargeIdList = "DMCAT_RecurringCharge_001240,DMCAT_RecurringCharge_001277";
		var offer = "";
		var planId = planValue;
		let inputMap = {};
		inputMap["offerid"] = "DMCAT_Offer_001233";
		inputMap["getAddonPriceItemAssociationBulk"] = "";
		inputMap["chargeidList"] = chargeIdList;
		inputMap["plan"] = planId;
		await activeNGEMBasket.performRemoteAction("MobileSubscriptionGetAddOnData", inputMap).then((response) => {
			if (response && response["setAddonPriceItemAssociation"] != undefined) {
				AddonAssocMap = response["setAddonPriceItemAssociation"];
			}
		});
		if (!configuration.replacedConfigId && config.relatedProductList.length >= 0 && AddonAssocMap) {
			for (var ReletedConfig of config.relatedProductList) {
				updateMapChild[ReletedConfig.guid] = [];
				if (NXTGENCON_COMPONENT_NAMES.messageBank === ReletedConfig.name) {
					if (AddonAssocMap["DMCAT_RecurringCharge_001240"] && AddonAssocMap["DMCAT_RecurringCharge_001240"].isDefault__c === true) {
						updateMapChild[ReletedConfig.guid].push({
							name: "MessageBankAddonAssoc",
							value: AddonAssocMap["DMCAT_RecurringCharge_001240"].Id,
							displayValue: AddonAssocMap["DMCAT_RecurringCharge_001240"].AddOnName__c,
							lookup: AddonAssocMap["DMCAT_RecurringCharge_001240"]
						});
					}
				} else if (NXTGENCON_COMPONENT_NAMES.dataFeatures === ReletedConfig.name) {
					if (AddonAssocMap["DMCAT_RecurringCharge_001277"] && AddonAssocMap["DMCAT_RecurringCharge_001277"].isDefault__c === true) {
						updateMapChild[ReletedConfig.guid].push({
							name: "BusinessDemandData",
							value: AddonAssocMap["DMCAT_RecurringCharge_001277"].Id,
							displayValue: AddonAssocMap["DMCAT_RecurringCharge_001277"].AddOnName__c,
							lookup: AddonAssocMap["DMCAT_RecurringCharge_001277"]
						});
					}
				}
			}
			let keys = Object.keys(updateMapChild);
			for (let i = 0; i < keys.length; i++) {
				component.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], false);
			}
		}
		return Promise.resolve(true);
	},
	/************************************************************************************
EDGE-168275, EDGE-164351
Method: updateISPOSReversalRequired
Description: update basket field Is_OF_POS_Reversal_Required__c on the basis of RedeemFundCopy attribute
Inputs: inputMap
History
<03-09-2020> <Manish Berad/Aarathi>
************************************************************************************/
	updateISPOSReversalRequired: async function () {

		let loadedSolution = await CS.SM.getActiveSolution();

		let cmpName = loadedSolution.getComponentByName("Device");
		if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
			let configs = cmpName.getConfigurations();
			if (configs) {
				Object.values(configs).forEach(async (config) => {
					if (config.replacedConfigId && config.guid) {
						let RedeemFundCopy;
						let freeCancellationPeriod;
						if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
							Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
								RedeemFundCopy = relatedConfig.configuration.getAttribute("RedeemFundCopy");
								freeCancellationPeriod = relatedConfig.configuration.getAttribute("Free Cancellation Period");
							});
						}
						let inputMap = {};
						inputMap["getChildServicesForDeviceCare"] = config.replacedConfigId;
						activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
							let diviceCareServices = result["getChildServicesForDeviceCare"];
							let initialActivationDate = diviceCareServices.Initial_Activation_Date__c;
							let csordStatus = diviceCareServices.csord__Status__c;
							if (initialActivationDate && csordStatus === "Connected") {
								let serviceStartDate = new Date(initialActivationDate);
								let freeCancelPeriod = freeCancellationPeriod.displayValue;
								serviceStartDate.setDate(serviceStartDate.getDate() + parseInt(freeCancelPeriod));
								let todaysDate = new Date().setHours(0, 0, 0, 0);
								if (todaysDate < serviceStartDate) {
									isFreeCancellationPossible = true;
								} else {
									isFreeCancellationPossible = false;
								}
								if (isFreeCancellationPossible) {
									if (parseInt(RedeemFundCopy.displayValue) > 0) {
										let inputMap = {};
										inputMap["updateISPOSReversalRequired"] = activeNGEMBasket.basketId;
										activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
									}
								}
							}
						});
					}
				});
			}
				
		}
	},
/************************************************************************************
 EDGE-164351
Method: RemainingTermCalculation
Description: calculate Remaining Term
Inputs: inputMap
************************************************************************************/
RemainingTermCalculation: async function (mainCompName, componentName, hookname, guid) {   
	let currentSolution = activeNGEMSolution;
	if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
		let comp=currentSolution.getComponentByName(componentName);
		let config = comp.getConfiguration(guid);
		var TransDevice = false;
        var TransAccessory = false; //------DPG-5621 Krunal
		if(componentName=== NEXTGENMOB_COMPONENT_NAMES.transitionDevice){
			TransDevice = true;}
        //------DPG-5621 Krunal
       	if(componentName=== NEXTGENMOB_COMPONENT_NAMES.transitionAccessory){
			TransAccessory = true;}	
        //------DPG-5621 Krunal
		if (config && (componentName===NXTGENCON_COMPONENT_NAMES.nextGenDevice || componentName=== NEXTGENMOB_COMPONENT_NAMES.transitionDevice)){
			var cta = config.getAttribute("ChangeType");
			var payTypeLookup = config.getAttribute("PaymentTypeString");
			var contractTermval =  config.getAttribute("ContractTerm");
			if ((payTypeLookup.displayValue  === 'Hardware Repayment' && config.replacedConfigId) || TransDevice) {
				await CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval.displayValue, config.id,comp.name, hookname);
			}
		}
        //------DPG-5621 Krunal
		if (config && (componentName===NXTGENCON_COMPONENT_NAMES.nextGenAccessory || componentName=== NEXTGENMOB_COMPONENT_NAMES.transitionAccessory)){
			var cta = config.getAttribute("ChangeType");
			//DPG-6180 Start || Krunal/Ila
			var payTypeLookup;
			var contractTermval;
			if(componentName===NXTGENCON_COMPONENT_NAMES.nextGenAccessory){
				payTypeLookup = config.getAttribute("PaymentTypeShadow");
				contractTermval =  config.getAttribute("ContractTermShadow");
			}
			if(componentName===NXTGENCON_COMPONENT_NAMES.transitionAccessory){
				payTypeLookup = config.getAttribute("PaymentTypeString");
				contractTermval =  config.getAttribute("ContractTerm");
			}
			//DPG-6180 End || Krunal/Ila
			if ((payTypeLookup.displayValue  === 'Hardware Repayment' && config.replacedConfigId) || TransAccessory) {
				await CommonUtills.remainingTermEnterpriseMobilityUpdate(config, contractTermval.displayValue, config.id,comp.name, hookname);
			}
		}
		//------DPG-5621 Krunal
	}
},
    UpdateChangeTypePaidOut: async function (guid, hookname, statusValue,remainingTerm) {
        var optionValues = [];
				optionValues = [
					CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("No Fault Return")
                ]; // EDGE-197578 //R34UPGRADE
        let currentSolution = activeNGEMSolution;
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
			let comp=currentSolution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice); //EDGE-187727
            let config = comp.getConfiguration(guid);
			if (config){
				var NGEMdev = [];
				var cta = config.getAttribute("ChangeType");
				var payTypeLookup = config.getAttribute("PaymentTypeString");
				var contractTermval =  config.getAttribute("ContractTerm");
				if (payTypeLookup.displayValue === 'Hardware Repayment' && config.replacedConfigId) {
					NGEMdev[guid] = [];								
					if (remainingTerm <= 0) {
						optionValues.push(CommonUtills.createOptionItem("PaidOut")); //R34 Upgrade
						NGEMdev[guid] = [{
							name: 'ChangeType',
							value: 'PaidOut',
							displayValue: 'PaidOut',
							options: optionValues,
							readOnly: true
						}];
						let keys = Object.keys(NGEMdev);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	UpdateChangeTypePaidOutTransDevice: async function (guid, hookname, statusValue,remainingTerm) {
        var optionValues = [];
				optionValues = [];
        let currentSolution = activeNGEMSolution;
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
			let comp=currentSolution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice); //EDGE-187727
            let config = comp.getConfiguration(guid);
			if (config){
				var TransDev = [];
				if (config.replacedConfigId) {
					TransDev[guid] = [];								
					if (remainingTerm <= 0) {
						optionValues.push(CommonUtills.createOptionItem("PaidOut")); //R34 Upgrade
						TransDev[guid] = [{
							name: 'ChangeType',
							value: 'PaidOut',
							displayValue: 'PaidOut',
							readOnly: true
						}];
						let keys = Object.keys(TransDev);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], TransDev[keys[i]], true); 
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},
	UpdateETCTnasitionDevice: async function (ConfigId, guid,config,componentName) {
		let loadedSolution = await CS.SM.getActiveSolution();
		var billingaccountnumber = '';
		var OC = config.getAttribute("OC");
		var RC = config.getAttribute("RC");
		var RT =  config.getAttribute("RemainingTerm");
		console.log('OCRTRC--->', OC,RC,RT);
		if(loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
			let config = Object.values(loadedSolution.schema.configurations)[0];
			if(config.replacedConfigId && config.replacedConfigId !== null){
				solutionComponent = true;
				var billingAccLook = Object.values(config.attributes).filter((a) => {
					return a.name === "BillingAccountLookup";
				});	
				billingaccountnumber = billingAccLook[0].displayValue ;
			}
		}
		console.log('billingaccountnumber--->', billingaccountnumber,ConfigId);
			var inputMap = {};
			var updateMap = [];
			inputMap["transitionDeviceCancel"] = "";
			inputMap["ConfigId"] = config.replacedConfigId;
			inputMap["billingAccNum"] = billingaccountnumber;
		
			let activeNGEMBasket = await CS.SM.getActiveBasket();
			activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (values) => {
				var charges = values["transitionDeviceCancel"];
				var chargevalue = 0;
				console.log('charges--->', charges);
				if(charges === 'RCRT'){
					chargevalue = parseInt(RC.value)*parseInt(RT.value);
				}
				else if(charges === 'OC'){
					chargevalue = parseInt(OC.value);
				}
				/*var chargesGst = parseFloat(chargevalue * 1.1).toFixed(2);
				console.log('chargevalue--->', chargevalue,chargesGst);*/
				updateMap[guid] = [
					{
						name: "EarlyTerminationCharge",
						value: String(chargevalue),
						displayValue: String (chargevalue)
					}
					/*{
						name: "EarlyTerminationChargeIncGST",
						label: "Balance Due on Device(Inc. GST)",
						value: String(chargesGst),
						displayValue: String (chargesGst)
					}*/
					
				];
				let component = await loadedSolution.getComponentByName(componentName);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			});
		
		},
        //------DPG-5621 Krunal - UpdateChangeTypePaidOutAccessory   
        UpdateChangeTypePaidOutAccessory: async function (guid, hookname, statusValue,remainingTerm) {
        var optionValues = [];
				optionValues = [
					CommonUtills.createOptionItem("Cancel")
                ]; // EDGE-197578 //R34 Upgrade
        let currentSolution = activeNGEMSolution;
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
			let comp=currentSolution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //EDGE-187727
            let config = comp.getConfiguration(guid);
			if (config){
				var NGEMacc = [];
				var cta = config.getAttribute("ChangeType");
				var payTypeLookup = config.getAttribute("PaymentTypeShadow");
				var contractTermval =  config.getAttribute("ContractTerm"); //or ContractTermShadow
				if (payTypeLookup.displayValue === 'Hardware Repayment' && config.replacedConfigId) {
					NGEMacc[guid] = [];								
					if (remainingTerm <= 0) {
						optionValues.push(CommonUtills.createOptionItem("PaidOut")); //R34 Upgrade
						NGEMacc[guid] = [{
							name: 'ChangeType',
							value: 'PaidOut',
							displayValue: 'PaidOut',
							options: optionValues,
							readOnly: true
						}];
						let keys = Object.keys(NGEMacc);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], NGEMacc[keys[i]], true); 
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},
    //------DPG-5621 Krunal - UpdateChangeTypePaidOutTransAccessory
    UpdateChangeTypePaidOutTransAccessory: async function (guid, hookname, statusValue,remainingTerm) {
        var optionValues = [];
				optionValues = [];
        let currentSolution = activeNGEMSolution;
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
			let comp=currentSolution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory); //EDGE-187727
            let config = comp.getConfiguration(guid);
			if (config){
				var TransAcc = [];
				if (config.replacedConfigId) {
					TransAcc[guid] = [];								
					if (remainingTerm <= 0) {
						optionValues.push(CommonUtills.createOptionItem("PaidOut")); //R34 Upgrade
						TransAcc[guid] = [{
							name: 'ChangeType',
							value: 'PaidOut',
							displayValue: 'PaidOut',
							readOnly: true
						}];
						let keys = Object.keys(TransAcc);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], TransAcc[keys[i]], true); 
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},
     //------DPG-5621 Krunal - UpdateETCTnasitionAccessory   
     UpdateETCTnasitionAccessory: async function (ConfigId, guid,config,componentName) {
		let loadedSolution = await CS.SM.getActiveSolution();
		var billingaccountnumber = '';
		var OC = config.getAttribute("OC");
		var RC = config.getAttribute("RC");
		var RT =  config.getAttribute("RemainingTerm");
		console.log('OCRTRC--->', OC,RC,RT);
		if(loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
			let config = Object.values(loadedSolution.schema.configurations)[0];
			if(config.replacedConfigId && config.replacedConfigId !== null){
				solutionComponent = true;
				var billingAccLook = Object.values(config.attributes).filter((a) => {
					return a.name === "BillingAccountLookup";
				});	
				billingaccountnumber = billingAccLook[0].displayValue ;
			}
		}
		console.log('billingaccountnumber--->', billingaccountnumber,ConfigId);
			var inputMap = {};
			var updateMap = [];
			inputMap["transitionDeviceCancel"] = "";
			inputMap["ConfigId"] = config.replacedConfigId;
			inputMap["billingAccNum"] = billingaccountnumber;
		
			let activeNGEMBasket = await CS.SM.getActiveBasket();
			activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (values) => {
				var charges = values["transitionDeviceCancel"];
				var chargevalue = 0;
				console.log('charges--->', charges);
				if(charges === 'RCRT'){
					chargevalue = parseInt(RC.value)*parseInt(RT.value);
				}
				else if(charges === 'OC'){
					chargevalue = parseInt(OC.value);
				}
				/*var chargesGst = parseFloat(chargevalue * 1.1).toFixed(2);
				console.log('chargevalue--->', chargevalue,chargesGst);*/
				updateMap[guid] = [
					{
						name: "EarlyTerminationCharge",
						value: String(chargevalue),
						displayValue: String (chargevalue)
					}
					/*{
						name: "EarlyTerminationChargeIncGST",
						label: "Balance Due on Device(Inc. GST)",
						value: String(chargesGst),
						displayValue: String (chargesGst)
					}*/
					
				];
				let component = await loadedSolution.getComponentByName(componentName);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			});
		
		},
	/*******************************************************************************************************
	  * Author	    : Shweta Khandelwal 
	  * Method Name : AMSequenceNumberAddInConfigName
	  * Invoked When: afterAttributeUpdate and afterCOnfigurationClone for CMP and AM 
	  * Description : 1. updates number sequence for configuration Name, and name contains two attribute value
	  * EDGE-185652
	  ******************************************************************************************************/
	 AMSequenceNumberAddInConfigName: async function (component, configuration, configName) {
        let setUpdateMap = {};
        setUpdateMap[configuration.guid] = [];
        setUpdateMap[configuration.guid] = [
            {
                name: "ConfigName",
                value: configName,
                displayValue: configName
			}
        ];
        configuration.configurationName = configName;
        let keys = Object.keys(setUpdateMap);
        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], setUpdateMap[keys[i]], false);
		}
    },
    
    /*********************************************************************************************
	 * Author	   : Pooja Bhat
	 * Method Name : CalcDeviceRedeemFundGST
	 * Invoked When: Form NextGenMobController, method AfterAttributeUpdated - Case RedeemFund 
	 * Sprint	   : 20.15 (EDGE-175750)
	 * Parameters  : guid, newValue, componentName
	**********************************************************************************************/
	CalcDeviceRedeemFundGST: async function (guid, newValue, componentName) {
		let updateMap 	= 	{};
		updateMap[guid]	=	[];
		let solution 	=	await CS.SM.getActiveSolution();
		let comp 		= 	await solution.getComponentByName(componentName);
		if (comp && newValue !== null && newValue !== undefined) {
			let redeemFundExGSTRounded	= 	(newValue === "" || newValue === null || newValue === undefined ? 0 :  parseFloat(newValue).toFixed(2));
			let redeemFundIncGSTRounded	=	parseFloat(redeemFundExGSTRounded * 1.1).toFixed(2);
			updateMap[guid].push({
				name: "RedeemFundIncGST",
				value: redeemFundIncGSTRounded,
				displayValue: redeemFundIncGSTRounded
			});
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
		}
	},
	/************************************************************************************
	 * Author	  : Ila/Krunal
	 * Method Name : UpdateAttValueOnHide
	 * Invoked When: Attributes are hidden for Adaptive Mobility Accessory
	 * Parameters  : guid, mainCompName, componentName, attributeName, AttrValueToBeUpdated
	 ***********************************************************************************/
	UpdateAttValueOnHide: async function (guid, mainCompName, componentName, attributeName, AttrValueToBeUpdated) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let config = comp.getConfiguration(guid);
				if (config) {
					let updatingAtt = config.getAttribute(attributeName);
					if (updatingAtt!=null) {
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: attributeName,
							value: AttrValueToBeUpdated,
							displayValue: AttrValueToBeUpdated
						});
					}
				}
				var complock = comp.commercialLock;
				if (complock) component.lock("Commercial", false);
				console.log('complock+' ,complock);
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					console.log('inside If');
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
				if (complock) comp.lock("Commercial", true);
			}
		}
	},
	/*******************************************************************************************************************************************
	 * Author	   : Krunal Taak / Ila Verma
	 * Method Name : updateConfigName_Accessory
	 * Invoked When: after attribute updated of Purchase Type
	 * Device Type + Model + Purchase Type --> dynamic name
	 * Parameters  : componentName , guid
	 ******************************************************************************************************************************************/
	updateConfigName_AccessoryperConfig: async function (componentName, guid) {
        console.log('--inside updateConfigName_AccessoryperConfig--'+componentName+guid);
		let updateMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let config = comp.getConfiguration(guid);
				if (config) {
                    let configName = config.configurationName;
                    let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
					var type = config.getAttribute("TypeName");
					var model = config.getAttribute("ModelName");
					//DPG-4725 - Start - Krunal
                    var modelString = model.displayValue.toString();
                    var length = 70;
					var modelDisplay = modelString.substring(0, length);
                    //DPG-4725 - End - Krunal
					var paymentType = config.getAttribute("PaymentTypeShadow");
					let paymentTypeStr = 'PUR'; //DPG-4725
					if(paymentType.displayValue === 'Hardware Repayment') paymentTypeStr = 'HRO';
					if (type && model && paymentType) {
                        //configName = type.displayValue + " " + model.displayValue + " " + paymentTypeStr + "_" + spaceIndex;
						configName = modelDisplay + " " + paymentTypeStr + "_" + spaceIndex; //DPG-4725
					}
					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "ConfigName",
						value: configName,
						displayValue: configName
					});
					config.configurationName = configName;
				}
			}
		}
		if (updateMap) {
			let component = await product.getComponentByName(componentName);
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
			}
		}
		return Promise.resolve(true);
	},
	/******************************************************************************************************************************************
	 * Author	   : Krunal Taak / Ila Verma
	 * Method Name : updateConfigName_Accessory
	 * Invoked When: attribute update Purchase Type
	 * Device Type + Model + Purchase Type --> dynamic name
	 * Parameters  : componentName
	 ******************************************************************************************************************************************/
	updateConfigName_AccessoryAllConfig: async function (componentName) {
		let updateMap = {};
		let component;
		let product = await CS.SM.getActiveSolution();
		if (product.components && Object.values(product.components).length > 0) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				for (var config of Object.values(configs)) {
                    let configName = config.configurationName;
					let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
					var type = config.getAttribute("TypeName");
					var model = config.getAttribute("ModelName");
					//DPG-4725 - Start - Krunal
                    var modelString = model.displayValue.toString();
                    var length = 70;
					var modelDisplay = modelString.substring(0, length);
                    //DPG-4725 - End - Krunal
					var paymentType = config.getAttribute("PaymentTypeShadow");
					let paymentTypeStr = 'PUR'; //DPG-4725
					if(paymentType.displayValue === 'Hardware Repayment') paymentTypeStr = 'HRO';//EDGE-191285
					if (type && model && paymentType) {
                        //configName = type.displayValue + " " + model.displayValue + " " + paymentTypeStr + "_" + spaceIndex;
						configName = modelDisplay + " " + paymentTypeStr + "_" + spaceIndex; //DPG-4725
					}
					
					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "ConfigName",
						value: configName,
						displayValue: configName
					});
					config.configurationName = configName;
				}






			if (updateMap) {
				let keys = Object.keys(updateMap);

				var complock = comp.commercialLock;
				if(complock) comp.lock('Commercial',false);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
				}
				if(complock) comp.lock('Commercial',true);

			}
		}





		}

		return Promise.resolve(true);
	},
		/******************************************************************************************************************************************
	 * Author	   : Hitesh Gandhi / Akansha Jain
	 * Method Name : deleteDeliveryDetails
	 * Invoked When: SimAvailabilityType Attribute is updated in ContractAccepted basket stage while doing NumberReservation
	 * created as part of EDGE-200723, Deletes the DeliveryDetails OE if SimAvailabilityType is Existing Blank SIM
	 * Parameters  : Solution Name, componentName and Config GUID
	 ******************************************************************************************************************************************/
	deleteDeliveryDetails: async function (solutionName, component,guid) 
	{
	try 
	{
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(solutionName)) 
		{
			if (solution.components && Object.values(solution.components).length > 0) 
			{
				for (let comp of Object.values(solution.components))
				{
					if (comp.name === component) 
					{
						let configs = comp.getConfigurations();
						for (let i = 0; i < Object.values(configs).length; i++) 
						{
							let config = Object.values(configs)[i];
							if(config.guid === guid)
							{
								if (config && config.disabled === false)
								{
									if (config.orderEnrichmentList && config.disabled == false) 
									{
										for (var m = 0; m < Object.values(config.orderEnrichmentList).length; m++) 
										{
											var oeList = Object.values(config.orderEnrichmentList)[m];
											var oeNameVal = "";
											var oeName = await oeList.getAttribute("OENAME");
											if (oeName.value && oeName.value != null) 
											{
												oeNameVal = oeName.value;
											}
											if (oeNameVal === 'DD' )
											{	
												await comp.deleteOrderEnrichmentConfiguration( config.guid, oeList.guid,true);
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
	}//try
	catch (error) 
	{
		console.log(error);
	}
	return Promise.resolve(true);
	},
		/******************************************************************************************************************************************
	 * Author	   : Hitesh Gandhi / Akansha Jain
	 * Method Name : addDeliveryDetails
	 * Invoked When: SimAvailabilityType Attribute is updated in ContractAccepted basket stage while doing NumberReservation
	 * created as part of EDGE-200723, Adds back DeliveryDetails OE if SimAvailabilityType is changed form Existing Blank SIM to New SIM
	 * Parameters  : Solution Name, componentName and Config GUID
	 ******************************************************************************************************************************************/
addDeliveryDetails: async function (solutionName,component,guid) 
	{
		try 
		{
			let solution = await CS.SM.getActiveSolution();
			if (solution.name.includes(solutionName)) 
			{
			 if (solution.components && Object.values(solution.components).length > 0) 
			 {
				for (let comp of Object.values(solution.components))
				{
					if (comp.name === component) 
					{
						let configs = comp.getConfigurations();
						for (let i = 0; i < Object.values(configs).length; i++) 
						{
							let config = Object.values(configs)[i];
							if(config.guid === guid)
							{
								Object.values(comp.orderEnrichments).forEach((oeSchema) =>
								{
									let found = false;
									let oeMap=[];
									if (config.orderEnrichmentList) {
										let oeConfig = Object.values(config.orderEnrichmentList).find((oe) => oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId);
										if (oeConfig) found = true;
									}
									if (!found) 
									{
										let el = {};
										el.componentName = comp.name;
										el.configGuid = config.guid;
										el.oeSchema = oeSchema; //EDGE-154502
										oeMap.push(el);
										let configMap = [];
										let currentBasket =  CS.SM.getActiveBasket();
										configMap = [{name: "basketId", value: { value: currentBasket.basketId}}];
										configMap.push({ name: "OfferName", value: solutionName})				
										var orderEnrichmentConfiguration = oeMap[0].oeSchema.createConfiguration(configMap);
										comp.addOrderEnrichmentConfiguration(config.guid, orderEnrichmentConfiguration, false);
									}
								});
							}
						}	
					}
				}
			}//if
			}//if
		}//try
		catch (error) 
		{
			console.log(error);
		}
		return Promise.resolve(true);
	},
		/******************************************************************************************************************************************
	 * Author	   : Hitesh Gandhi / Akansha Jain
	 * Method Name : DeleteDeliveryDetails_MAC
	 * Invoked When: From AfterSolutionLoad method, to remove DD OE which gets added by generic method of OE Logic for the components where SimAvailabilityType is Existing Blank SIM. 
	 * Parameters  : Solution Name, componentName and Config GUID
	 ******************************************************************************************************************************************/
DeleteDeliveryDetails_MAC: async function (solutionName,component) 
	{
		try 
		{
			let solution = await CS.SM.getActiveSolution();
			if (solution.name.includes(solutionName)) 
			{
			 if (solution.components && Object.values(solution.components).length > 0) 
			 {
				for (let comp of Object.values(solution.components))
				{
					if (comp.name === component) 
					{
						let configs = comp.getConfigurations();
						for (let i = 0; i < Object.values(configs).length; i++) 
						{
							let config = Object.values(configs)[i];
							var SimAvailabilityType = config.getAttribute("SimAvailabilityType");
							 //EDGE-214802: Existing Deactivated SIM
							if(SimAvailabilityType.displayValue === 'Existing Blank SIM' || SimAvailabilityType.displayValue === 'Blank SIM' || SimAvailabilityType.displayValue === 'Existing Active SIM' || SimAvailabilityType.displayValue === 'Existing SIM') // EDGE-211680 , EDGE-224706 added active SIM value
							{
								await NextGenMobHelper.deleteDeliveryDetails(solutionName,component,config.guid);
							}
						}	
					}
				}
			}//if
			}//if
		}//try
		catch (error) 
		{
			console.log(error);
		}



		return Promise.resolve(true);
	},	
		/******************************************************************************************************************************************
	 * Author	   : Aditya Pareek
	 * Method Name : updateFundReversalAtt
	 * Invoked When: On Attribute Update
	 * Parameters  : componentName, guid,FundReversal
	 * Created for : Edge: 197578
	 ******************************************************************************************************************************************/
	updateFundReversalAtt: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid === guid) {
							let OCVal = config.getAttribute("OC");
							let RfundCopy = config.getAttribute("RedeemFundCopy");
													
							let OCVlaue = OCVal.value;
							let RfundValue = RfundCopy.value;
							let CRevValue = OCVlaue - RfundValue;

							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: "FundReversal",
								value: RfundValue,
								displayValue: RfundValue
							});
							updateMap[config.guid].push({
								name: "ChargeReversal",
								value: CRevValue,
								displayValue: CRevValue
							});
							updateMap[config.guid].push({
								name: "CancellationReason",
								value: 'No Fault Return',
								displayValue: 'No Fault Return'
							});
						}
					});
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}
			}
		}
	},
	/************************************************************************************
	 * Author	  	: Aditya Pareek
	 * Method Name 	: updateFundReversalAttChild
	 * Invoked When	: On Attribute Update
	 * Sprint	  	: 21.05 (EDGE-197578)
	 * Parameters  	: guid, mainCompName, componentName
	 ***********************************************************************************/
	 updateFundReversalAttChild: async function (guid, mainCompName, componentName) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(mainCompName)) {
			let comp = solution.getComponentByName(componentName);
			if (comp) {
				var updateMap = {};
				let configs = comp.getConfigurations();
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid ===guid) {
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									if (relatedConfig.guid) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
											let OCVal = relatedConfig.configuration.getAttribute("OC");
											let RedfundCopy = relatedConfig.configuration.getAttribute("RedeemFundCopy");

											let OCVlaue = OCVal.value;
											let RfundValue = RedfundCopy.value;
											let CRevValue = OCVlaue - RfundValue;
											
											
											updateMap[relatedConfig.guid] = [];
											updateMap[relatedConfig.guid].push({
												name: "FundReversal",
												value: RfundValue,
												displayValue: RfundValue
											});
											updateMap[relatedConfig.guid].push({
												name: "ChargeReversal",
												value: CRevValue,
												displayValue: CRevValue
											});
										}
									}
									let keys = Object.keys(updateMap);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
									}
								});
							}
						}
					});
				}
			}
		}
	},
	/************************************************************************************
	 * Author	  	: Shubhi V/Arun Selvan
	 * Method Name 	: updateDisplayValueAutodataTopUp
	 * Invoked When	: On Attribute Update
	 * Sprint	  	: 21.05 (EDGE-212647)
	 * Parameters  	: guid
	 ***********************************************************************************/
	updateDisplayValueAutodataTopUp: async function (guid) {	
		var solution = await CS.SM.getActiveSolution();
		var component= await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
		var config = await component.getConfiguration(guid);
		var updateMap = {};
		if (config.relatedProductList.length >= 0 ) {
			for (var relatedConfig of config.relatedProductList) {
				if(relatedConfig.name===NEXTGENMOB_COMPONENT_NAMES.Data_Features){
					const AutoDataTopup = relatedConfig.configuration.getAttribute("AutoDataTopup");
					let olvaluelist=['Small','Medium','Large'];
					if (AutoDataTopup && AutoDataTopup.displayValue != undefined && AutoDataTopup.displayValue != "" && olvaluelist.includes(AutoDataTopup.displayValue)){
						var newdisplayValue='';
						switch (AutoDataTopup.displayValue) {
							case 'Small':
								newdisplayValue='Auto data top-up (50GB)';
								break;
							case 'Large':
								newdisplayValue='Auto data top-up (250GB)';
								break;
							case 'Medium':
								newdisplayValue='Auto data top-up (1000GB)';
								break;
							

						}
						updateMap[relatedConfig.guid] = [];
						updateMap[relatedConfig.guid].push({
								name: "AutoDataTopup",
								displayValue: newdisplayValue
						});
					}

				}
				
			}
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
		}
		},
    
        //Added By mahima- DPG-5298 -start
        updatePreferredChkBoxAPN: async function(guid){
            var solution = await CS.SM.getActiveSolution();
            var component= await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
            var config = await component.getConfiguration(guid);
            var updateMap = {};
            if (config.relatedProductList.length >= 0) {
                //for (var relatedConfig of config.relatedProductList) {
                    console.log('config.name==>'+config.name);
                    if(config.name.includes(NXTGENCON_COMPONENT_NAMES.dataCustom)){
                        debugger;
                        var valueTxt=config.getAttribute("DataCustomAPN");
                        console.log('valueTxt==>'+valueTxt);
                        updateMap[config.guid] = [];
                        updateMap[config.guid].push({
								name: "PreferredChk",
								value: valueTxt.displayValue,
                            	readOnly: true
						});
                 //   }
            }
            let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
            }
        },
        //Added By mahima- DPG-5298 -end
        //Added By Monali- DPG-5626 -Start
	/*******************************************************************************************************************************************
	 * Author	   : Monali Mukherjee
	 * Method Name : updatePurchaseOrderNoOnConfig / Logistics Number
	 * Invoked When: On Load and On Save
	 * Parameters  : componentName
	 * EDGE Number : DPG-5626
	 ******************************************************************************************************************************************/
	updatePurchaseOrderNoOnConfig: async function (componentName) {
		let componentMap = {};
		let product = await CS.SM.getActiveSolution();
		if (product) {
			let comp = product.getComponentByName(componentName);
			if (comp) {
				let configs = comp.getConfigurations();
				componentMap[comp.name] = [];
				if (configs) {
					Object.values(configs).forEach((config) => {
						var PurchaseOrderNoValue = config.getAttribute("PurchaseOrderNo");
						if (config.replacedConfigId && PurchaseOrderNoValue && PurchaseOrderNoValue.value === "") {
							componentMap[comp.name].push({
								id: config.replacedConfigId,
								guid: config.guid
							});
						}
					});
					if (componentMap) NextGenMobHelper.RemoteActionCallPON(componentMap, "PurchaseOrderNo", componentName);
				}
			}
		}
	},
	/*******************************************************************************************************************************************
	 * Author	   : Monali Mukherjee
	 * Method Name : RemoteActionCall
	 * Invoked When: On Load and On Save
	 * Parameters  : componentName
	 * EDGE Number	: DPG-5626
	 ******************************************************************************************************************************************/
	RemoteActionCallPON: async function (componentMap, Attname, componentName) {
		let updateMap = {};
		if (Object.keys(componentMap).length > 0) {
			var parameter = "";
			Object.keys(componentMap).forEach((key) => {
				if (parameter) {
					parameter = parameter + ",";
				}
				parameter = parameter + componentMap[key].map((e) => e.id).join();
			});
			let inputMap = {};
			inputMap["GetPurchaseOrderNoForConfiguration"] = parameter;

			var statuses;
			await activeNGEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
				if (values["GetPurchaseOrderNoForConfiguration"]) statuses = JSON.parse(values["GetPurchaseOrderNoForConfiguration"]);
			});

			if (statuses) {
				Object.keys(componentMap).forEach(async (comp) => {
					componentMap[comp].forEach((element) => {
						var PurchaseOrderNo = "";
						var status = statuses.filter((v) => {
							return v.csordtelcoa__Product_Configuration__c === element.id;
						});
						if (status && status.length > 0) {
							PurchaseOrderNo = status[0].Logistics_Order_Number__c;
						}
						if (Attname === "PurchaseOrderNo" && PurchaseOrderNo != "" && PurchaseOrderNo != null) {
							updateMap[element.guid] = [
								{
									name: Attname,
									value: PurchaseOrderNo,
									displayValue: PurchaseOrderNo,
									showInUi: true
								}
							];
						}
					});
					if (updateMap) {
						let solution = await CS.SM.getActiveSolution();
						let component = await solution.getComponentByName(componentName);
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
					}
				});
			}
		}
	},
	//Added By Monali- DPG-5626 -End
	/************************************************************************************
 * Author	  : Ila 
 * Method Name : HideShowAttLst_TransAccessory
 * Invoked When: on attribute update
 * Parameters  : guid, mainCompName, componentName, attributeList
 * Sprint      : 21.09 (DPG-6180)
***********************************************************************************/
HideShowAttLst_TransAccessory: async function (guid, mainCompName, componentName, attributeList) {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(mainCompName)){
		let configs = solution.getConfigurations();
		var updateMap = {};
		let compTransitionAccessory = solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.transitionAccessory);
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || Start
                        if(compTransitionAccessory){
							let compConfigs = compTransitionAccessory.getConfigurations();
                                Object.values(compConfigs).forEach((transAccessoryConfig) => {
                                    if(transAccessoryConfig.guid === guid){
										let ChangeTypeAtr = transAccessoryConfig.getAttribute("ChangeType");
										// Added below block as part of EDGE-154688 - Start
                                        if(transAccessoryConfig.replacedConfigId && ChangeTypeAtr.displayValue === 'Cancel'){
											NextGenMobHelper.HideShowAttributeLst(false, false, transAccessoryConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory,'', attributeList[32], true, true, false);
											NextGenMobHelper.HideShowAttributeLst(false, false, transAccessoryConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory,'', attributeList[33], true, false, false);
										}
										if(transAccessoryConfig.replacedConfigId && ChangeTypeAtr.displayValue !== 'Cancel'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, transAccessoryConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory,'', attributeList[32], true, false, false);
										}
										if(transAccessoryConfig.replacedConfigId && ChangeTypeAtr.displayValue === 'PaidOut'){
                                            NextGenMobHelper.HideShowAttributeLst(false, false, transAccessoryConfig.guid, mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory,'', attributeList[33], true, false, false);
                                        }
                                        // Added block as part of EDGE-154688 - End

                                    }

                                    
                                });
                        }
                    //Block used to do manipulations/calling methods for Parent Component - 'NextGen Plan' || Added by Aman Soni for EDGE-154238 || End
        }
    },
	/*******************************************************************************************************************************************
	 * Author	   : Mahima Gandhe
	 * Method Name : SoftDeletePlanBoltOn
	 * Invoked When: On AttributeUpdate
	 * Parameters  : componentName
	 * EDGE Number	: DPG-5278
	 ******************************************************************************************************************************************/
	 SoftDeletePlanBoltOn: async function (component, guid, componentName,newValue) {
		let boltOnComp = await component.getComponentByName(componentName);
		if(boltOnComp){
			console.log('SoftDelete For '+componentName);
		let boltOnConfig = await boltOnComp.getConfiguration(guid);
		let changeTypeattr;
		if (boltOnConfig) {
			changeTypeattr = boltOnConfig.getAttribute("ChangeType");
			if (changeTypeattr && newValue === 'Cancel') {
				let deletedConfiguration = boltOnComp.softDeleteMACConfiguration(boltOnConfig);
				console.log('deletedConfiguration_TON', deletedConfiguration);
			}
		}}
	 },
	 /************************************************************************************
	 * Author      : Monali Mukherjee
	 * Method Name : isTONApplicable
	 * Invoked When: Before Save
	 * Parameters  : NA
	 * US          : DPG-5731
	 ***********************************************************************************/
	 isTONApplicable: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
		let TONapplicable = true;
        var cntTON =0;
        if (component) {
          	let configs = component.getConfigurations();
        	Object.values(configs).forEach((config) => {
			if (config.guid) {
            	let EMreplacedConfig = config.replacedConfigId;
				if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
					Object.values(config.relatedProductList).forEach((relatedConfig) => {
						if (relatedConfig.name.includes('Telstra One Number')) {
							if (EMreplacedConfig === null || EMreplacedConfig === undefined || EMreplacedConfig === ""){
                                TONapplicable = false;
                            }
						}
					});
				}
			}
			});
		}
        		
		return TONapplicable;
	},
	/************************************************************************************
   * Author	   : Krunal Taak
   * Method Name : updateParentAttributefromChild
   * Invoked When: update parent attribute from child
   * Sprint	   : 21.15 (DIGI-26615)
   * Parameters  : componentname, parentAttributeToBeUpdated, relatedProductName, childvalue, parentGuid
   ***********************************************************************************/
  updateParentAttributefromChild: async function (componentname, parentAttributeToBeUpdated, relatedProductName, childvalue, parentGuid) {
	  let solution = await CS.SM.getActiveSolution();
	  if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
		  let comp = solution.getComponentByName(componentname);
		  if (comp) {
			  let config = comp.getConfiguration(parentGuid);
			  if (config) {
				  let parentAttribute = config.getAttribute(parentAttributeToBeUpdated);
				  let parentattributeMap = new Map(); 
				  let childValuefromMAP;
				  let updatechildValue = childvalue;
				  if(parentAttribute.value){
					  parentattributeMap = JSON.parse(parentAttribute.value);
					  if(parentattributeMap[relatedProductName]){
						  childValuefromMAP = parentattributeMap[relatedProductName].toString();
						  if(childValuefromMAP.includes(childvalue) || childvalue === ''){
							  updatechildValue = childValuefromMAP;
						  }
						  else{
							  updatechildValue = childValuefromMAP + ',' + updatechildValue;
						  }
					  }
				  }
				  parentattributeMap[relatedProductName] = [updatechildValue];
				  let Stringvalue = JSON.stringify(parentattributeMap);
				  let updateConfigMap = {};
				  updateConfigMap[parentGuid] = [
					  {
						  name: parentAttributeToBeUpdated,
						  value: Stringvalue,
						  displayValue: Stringvalue
					  }
				  ];
				  let keys = Object.keys(updateConfigMap);
				  let componentObj = await solution.getComponentByName(componentname);
				  for (let i = 0; i < keys.length; i++) {
					  await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
				  }
			  }		else {
				  console.log("no response");
			  }

			  }
		  }
	  return Promise.resolve(true);
  },
	/************************************************************************************
   * Author	   : Krunal Taak
   * Method Name : updateChildAttributefromParentDiscount
   * Invoked When: update child attribute 'ignoreDiscountID' from parent 'ignoreDiscountIDForChild'
   * Sprint	   : 21.15 (DIGI-26615)
   * Parameters  : parentGuid, componentname, relatedProductName
   ***********************************************************************************/
  updateChildAttributefromParentDiscount: async function (parentGuid, componentname, relatedProductName ) {
	  let solution = await CS.SM.getActiveSolution();
		  if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			  let comp = solution.getComponentByName(componentname);
			  if (comp) {
				  let config = comp.getConfiguration(parentGuid);
				  if (config) {
					  let parentAttribute = config.getAttribute('ignoreDiscountIDForChild');
					  let parentattributeMap = new Map(); 
					  let childValuefromMAP;
					  if(parentAttribute.value){
						  parentattributeMap = JSON.parse(parentAttribute.value);
						  if(parentattributeMap[relatedProductName]){
							  childValuefromMAP = parentattributeMap[relatedProductName].toString();
							  NextGenMobHelper.updatechildAttfromParent('ignoreDiscountID',childValuefromMAP,true,true,parentGuid,componentname);                                 
						  }
						 }
				  }		
			  }
		  }
	  return Promise.resolve(true);
  }
};
