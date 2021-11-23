/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	Author 			Date
1 			Tihomir  						Original Code
2			Laxmi Rahate	29-Jul-2019		Added code to create attachments for MDM Tenancy
3 			Venkata Ramanan 30-Jul-2019		Updated code,Json Schema for MDM Tenancy to create & view MDM Tenancy OE
4           Venkata Ramanan 09-Aug-2019             Updated code to error configuration when OE data not filled
5           Tihomir Baljak  13-08-2019      Code refactoring - save, OE
6           Venkata Ramanan 04-11-2019      Edge - 117274 - Tenancy Generic Modelling Changes 
7           Aniket Srivastava 24/01/2020    EDGE-119833
8           Shubhi             20/05/2020   Edge-148455
9			Gnana		    10-Jun-2020	    EDGE-149887 : Solution Name Update Logic 
10          Sukul Mongia      19/06/2020    Spring 20 Upgrade 
11			Gnana/Aditya 	19-July-2020	CS Spring'20 Upgrade
12          Pallavi D       18.08.2020      Added call to hide import button, and a fix to make the fields readonly in contract Accept stage
13          Krunal Taak     15-07-2020      Generate Net Price Button for PLATFORM 
14          Shresth Dixit     20-07-2020      Generate Rate Card Matrix(DPG - 2084)
15			Ila Anmol Verma	 28-07-2020			//DPG-2179: Added for reset custom attribute
16			Martand Atrey    3-10-2020		REFACTORED
17.         Martand A        06.12.2020    INC000094548575 fix
18          Payal Popat      3/12/2020      EDGE-189788 : Added Validation in before save and function for updating SIO attribute
19.         Vamsi Krishna Vaddipalli 14-APR-2021 EDGE-207353 for Preferred Billing Account
20.			Shubhi V		17/06/2021		EDGE-224663
21.         Antun Bartonicek 01/06/2021     EDGE-198536: Performance improvements
22.			Pooja Bhat		15/07/2021		EDGE-228932:QA2 || MDM Transition || On Rate card popup, after entering SIO value and clicked on save button, popup is not get disappeared and SIO is also not saved.			
 ********************/

const TENANCY_COMPONENT_NAMES = {
	solution: "Telstra Mobile Device Management - VMware", //'Telstra Mobile Device Management Tenancy',
	// solution: 'Tenancy',
	tenancy: "Platform"
};
var mdmtenancyid = null;

var executeSaveTMDM = false;
var allowSaveTMDM = false;
var solution = "";
var isTypeNew = false; //EDGE-119833
var tenancyAPIdone = false;
var updateVendorName = false;
var isVendorNull = false;
var offerName = "DMCAT_Offer_000681"; //EDGE-119833
var DEFAULTSOLUTIONNAME_TMDM = "Telstra Mobile Device Management - VMware"; // Added as part of EDGE-149887
var c = 0;
var billingAccount = "";
var communitySiteId = ""; //Added by shresth DPG-2084

if (!CS || !CS.SM) {
	throw Error("Solution Console Api not loaded?");
}

if (CS.SM.registerPlugin) {
	console.log("Load T-MDM plugin");
	window.document.addEventListener("SolutionConsoleReady", async function () {
		await CS.SM.registerPlugin(TENANCY_COMPONENT_NAMES.solution).then(async (TenancyPlugin) => {
			console.log("Plugin registered for TMDM");
			updateTenancyPlugin(TenancyPlugin);
			console.log("UpdatedPlugin calling");
			return Promise.resolve(true);
		});
		return Promise.resolve(true);
	});
}
function updateTenancyPlugin(TenancyPlugin) {
	//EDGE-198536: message listener and Utils.updateImportConfigButtonVisibility moved to window.document.addEventListener('SolutionSetActive' block
	//AB rename customAttribute link text, added click event listener
	/* document.addEventListener(
		"click",
		function (e) {
			e = e || window.event;
			var target = e.target || e.srcElement;
			var text = target.textContent || target.innerText;
			if (window.currentSolutionName === TENANCY_COMPONENT_NAMES.solution && text && text.toLowerCase() === TENANCY_COMPONENT_NAMES.tenancy.toLowerCase()) {
				//updateCustomAttributeLinkText("View Rate Card", "View test Price Breakdown");//REVIEW
			}
		},
		false
	); */
	//EDGE-135267 Aakil
	if (window.currentSolutionName === TENANCY_COMPONENT_NAMES.solution && text && (text.toLowerCase() === "overview" || text.toLowerCase().includes("stage"))) {
		//Utils.hideSubmitSolutionFromOverviewTab();
	}

	TenancyPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        try{
		let solution = result.solution;
		CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
		//updateCustomAttributeLinkText("View Rate Card", "View test Price Breakdown");//REVIEW
		//TenancyPlugin.setOEtabsforPlatform(solution);
		setOEtabsforPlatform(solution);
		//EDGE-135267
		//Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
            UpdateModuleChangeforOppty(solution);//Zeeshan : TMDM issue fix to set Modelchange flag to true when clicked on validate and save button- INC000094596954 
			CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
        }catch(error) {
            CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
            console.log(error);
        }
            CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
			return Promise.resolve(true);
	};
	//Aditya: Spring Update for changing basket stage to Draft
	TenancyPlugin.afterSolutionDelete = function (solution) {
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	};

	window.document.addEventListener("SolutionSetActive", async function (e) {
		let currentBasketTMDM = await CS.SM.getActiveBasket();
		let loadedSolutionTMDM = await CS.SM.getActiveSolution();
		if (loadedSolutionTMDM.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			window.currentSolutionName = loadedSolutionTMDM.name; //Added by Venkat to Hide OOTB OE Console Button

			if (loadedSolutionTMDM.componentType && loadedSolutionTMDM.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
				//EDGE-198536 Start: existing code moved inside active solution check
                window.addEventListener("message", TenancyPlugin_handleIframeMessage);
                Utils.updateImportConfigButtonVisibility();
                //EDGE-198536 End: existing code moved inside active solution check
				
				c = 0;

				basketId = currentBasketTMDM.basketId;
				solution = loadedSolutionTMDM;
				let inputMap = {};
				inputMap["GetSiteId"] = "";
				inputMap["GetBasket"] = basketId;
				if (basketStage === "Contract Accepted") {
					loadedSolutionTMDM.lock("Commercial", false);
				}
				await CommonUtills.getBasketData(currentBasketTMDM);
				await CommonUtills.getSiteDetails(currentBasketTMDM);
				handleButtonVisibility(loadedSolutionTMDM); //Shresth DPG-2084
                CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
				if (accountId != null) {
					await CommonUtills.setAccountID(TENANCY_COMPONENT_NAMES.solution, accountId);
				}
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_TMDM);
				setOEtabsforPlatform(solution);
				if (basketStage === "Contract Accepted") {
					loadedSolutionTMDM.lock("Commercial", true);
				}
				CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
			}
		}
		return Promise.resolve(true);
	});

	TenancyPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolutionTMDM) {
		return Promise.resolve(true);
	};

	TenancyPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		let currentBasketTMDM = await CS.SM.getActiveBasket();
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(component.name);
		var updateMap = {};
		var vendorname = "";
		let inputMap = {};
		inputMap["OfferId"] = offerName;
		await currentBasketTMDM.performRemoteAction("CSTenancyVendorlookup", inputMap).then(function (response) {
			if (response && response["vendor"] != undefined) {
				var vendorinfo = response["vendor"];
				vendorname = vendorinfo.Vendor__c;
			}
		});

		updateMap[configuration.guid] = [];
		updateMap[configuration.guid].push({
			name: "Vendor Name",
			value: vendorname
		});

		//EDGE-119833  Start
		let comp = currentSolution.getComponentByName("Platform");
		if (comp) {
			let configurations = comp.getConfigurations();
			if (configurations) {
				Object.values(configurations).forEach((config) => {
					let attributes = config.getAttributes();
					if (attributes) {
						Object.values(attributes).forEach((attribute) => {
							if (attribute.name == "ChangeType" && attribute.value == "New") {
								updateVendorName = true;
							}
							if (attribute.name == "Vendor Name" && attribute.value == "") {
								isVendorNull = true;
							}
						});
					}

					if (updateVendorName == true && isVendorNull == true) {
						if (updateMap && Object.keys(updateMap).length > 0) {
							keys = Object.keys(updateMap);

							for (let i = 0; i < keys.length; i++) {
								currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
							}
						}
						updateVendorName = false;
						isVendorNull = false;
					}
				});
			}
		}

		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){
				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		}
		//For EDGE-207353 on 14APR2021 by Vamsi ends

		//addDefaultTMDMOEConfigs();
		await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_TMDM);
		return Promise.resolve(true);
	};

	/* window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
		}
		return Promise.resolve(true);
	});

	TenancyPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {
		window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	}; */

	TenancyPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
		let oldValue = oldValueMap.value;//For EDGE-207353 on 14APR2021 by Vamsi
		let loadedSolutionTMDM = await CS.SM.getActiveSolution();
		if (attribute["Solution Name"] === DEFAULTSOLUTIONNAME_TMDM && attribute.name == "Marketable Offer") {
			CommonUtils.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue);
		}
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionTMDM.lock("Commercial", false);
		}
		if (component.name === "Tenancy Contact Details" && attribute.name === "TenancyPrimaryContact") {
			updateTenancyContactDetails(configuration.parentConfiguration, attribute.value);
		}
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "Marketable Offer" && attribute.value !== "") {
			updatevendordetails(configuration.guid);
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
		}
        //For EDGE-207353 on 14APR2021 by Vamsi starts
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup") {

			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){
				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', TENANCY_COMPONENT_NAMES.tenancy,oldValue);
				}
			}
		}
		
          //For EDGE-207353 on 14APR2021 by Vamsi ends
		//Shresth DPG-2084 Start
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "OfferId") {
			console.log("---offerid value==---" + attribute.value);
			//Utils.updateComponentLevelButtonVisibility("View Price Breakdown", attribute.value, false);
			handleButtonVisibility(loadedSolutionTMDM); // Added by Payal as a part of EDGE-189788
		}
		//Shresth DPG-2084 End
		//DPG-2168
		if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === "BillingAccountShadowTMDM") {
			//BillingAccountShadowTMDM
			billingAccount = attribute.value;
			console.log("---billingAccount==---" + billingAccount);
			//getExistingTenancySubscriptionsForBilling(billingAccount,component.Name,configuration.guid);
			getExistingTenancySubscriptionsForBilling(billingAccount);
			//getExistingTenancySubscriptions(accountId, loadedSolution);
		}

		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionTMDM.lock("Commercial", true);
		}
		CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
		return Promise.resolve(true);
	};

	TenancyPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
		//DO NOT PUT IN beforeSave ANY ADDITIONAL CODE,  ESPECIALLY CODE FOR UPDATING VALUES  OR ANY ASYNC CODE !!!!!

		/*if (allowSaveTMDM) {
			allowSaveTMDM = false;
			return Promise.resolve(true);
		}

		executeSaveTMDM = true;
		return Promise.resolve(true);*/
		//Added below criteria as per EDGE-189788
		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		if(!ExpectedSIO) {
            return Promise.resolve(false);
        }
		CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
		return Promise.resolve(true);
	}; 
}

/* async function saveSolutionTMDM() {
	//REVIEW REMOVE THIS METHOD ?
	let currentBasketTMDM = await CS.SM.getActiveBasket();
	if (executeSaveTMDM) {
		executeSaveTMDM = false;

		if (basketStage === "Contract Accepted") {
			let issaveallowed = true;
			let solution = await CS.SM.getActiveSolution();
			let configurations = solution.getConfigurations();
			for (var i = 0; i < Object.values(configurations).length; i++) {
				let config = Object.values(configurations)[i];
				let oeList = config.getOrderEnrichments();
				if (oeList) {
					for (let oeconfig of oeList) {
						if (oeconfig.parent !== mdmtenancyid) {
							for (var k = 0; k < oeconfig.attributes.length; k++) {
								var oeattr = oeconfig.attributes[k];
								if (oeattr.name === "TenancyPrimaryContact") {
									if (oeattr.value === "") {
										CS.SM.displayMessage("MDM Tenancy Contact details enrichment is incomplete", "error");
										issaveallowed = false;
									} else {
										await updateTenancyContactDetails(config.parentConfiguration, oeattr.value);
									}
								}
							}
						}
					}
				}
			}
			if (!issaveallowed) return Promise.resolve(false);
		}

		allowSaveTMDM = true;
		await currentBasketTMDM.saveSolution();
	}
	return Promise.resolve(true);
} */

//TenancyPlugin.setOEtabsforPlatform = function(solution){
const setOEtabsforPlatform = function (solution) {
	if (solution.componentType && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
		let comp = solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
		if (comp) {
			if (Utils.isOrderEnrichmentAllowed()) {
				let configurations = comp.getConfigurations();
				if (configurations) {
					Object.values(configurations).forEach((config) => {
						CS.SM.setOEtabsToLoad(comp.name, config.guid, ["Tenancy Contact Details"]);
					});
				}
			}
		}
	}
};

/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : addDefaultTMDMOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if there is none
 * Parameters  : none
 ********************************************************************************************************************************************/
/* const addDefaultTMDMOEConfigs = async () => {

	if (basketStage !== "Contract Accepted") return;
	var oeMap = [];
	let currentSolution = await CS.SM.getActiveSolution();
	if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
		let comp = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
		if (comp) {
			let configurations = comp.getConfigurations();
			if (configurations) {
				Object.values(configurations).forEach((config) => {
					let oeList = configurations.getOrderEnrichments();
					Object.values(oeList).forEach((oeSchema) => {
						var found = false;
						if (!oeSchema.name.includes("RateCard")) {
							if (oeList) {
								var oeConfig = oeList.filter((oe) => {
									return oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId;
								});

								if (oeConfig && oeConfig.length > 0) found = true;
							}
							if (!found) {
								var el = {};
								el.componentName = TENANCY_COMPONENT_NAMES.tenancy;
								el.configGuid = config.guid;
								el.oeSchema = oeSchema;
								oeMap.push(el);
							}
						} else mdmtenancyid = oeSchema.id;
					});
				});
			}
		}

		if (oeMap.length > 0) {
			for (var i = 0; i < oeMap.length; i++) {
				let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
				await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
			}
		}
		await initializeTMDMOEConfigs();
		return Promise.resolve(true);
	}
}; */

/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : initializeTMDMOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 * updated by shubhi after adding solution PD
 ********************************************************************************************************************************************/
/* const initializeTMDMOEConfigs = async () => {
	let currentSolution = await CS.SM.getActiveSolution();

	if (currentSolution) {
		if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			let comp = await currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
			if (comp) {
				let configurations = await comp.getConfigurations();
				if (configurations) {
					let config = Object.values(configurations)[j];
					var updateMap = {};
					if (config.orderEnrichmentList) {
						for (var k = 0; k < config.orderEnrichmentList.length; k++) {
							var oe = config.orderEnrichmentList[k];

							var basketAttribute = Object.values(oe.attributes).filter((a) => {
								return a.name.toLowerCase() === "basketid";
							});
							if (basketAttribute && basketAttribute.length > 0) {
								if (!updateMap[oe.guid]) updateMap[oe.guid] = [];

								updateMap[oe.guid].push({
									name: basketAttribute[0].name,
									value: basketId
								});
							}
						}
					}
					if (updateMap && Object.keys(updateMap).length > 0) {
						let keys = Object.keys(updateMap);
						for (var h = 0; h < updateMap.length; h++) {
							await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], true);
						}
					}
				}
			}
		}
	}
	return Promise.resolve(true);
}; */

const updateTenancyContactDetails = async (guid, newValue) => {
	if (basketStage !== "Contract Accepted") {
		return Promise.resolve(true);
	}
	let currentSolution = await CS.SM.getActiveSolution();

	if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
		let currentComponent = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
		if (currentComponent) {
			let config = currentComponent.getConfiguration(guid);
			if (config) {
				var updateConfigMap = {};
				updateConfigMap[config.guid] = [];
				updateConfigMap[config.guid].push({
					name: "TenancyPrimaryContact",
					value: newValue
				});
				if (basketStage === "Contract Accepted") {
					currentSolution.lock("Commercial", false);
				}
				if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					await currentComponent.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
				}
				if (basketStage === "Contract Accepted") {
					currentSolution.lock("Commercial", true);
				}
			}
		}
	}
	return Promise.resolve(true);
};

const updatevendordetails = async (guid) => {
	let currentSolution = await CS.SM.getActiveSolution();
	let currentBasketTMDM = await CS.SM.getActiveBasket();
	let component = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.solution);
	let solutionconfig = component.getConfigurations();
	let updateConfigMap = {};
	let inputMap = {};
	if (solutionconfig) {
		inputMap["OfferId"] = "DMCAT_Offer_000681";
		//CS.SM.WebService.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
		await currentBasketTMDM.performRemoteAction("CSTenancyVendorlookup", inputMap).then(function (response) {
			if (response && response["vendor"] != undefined) {
				var vendorinfo = response["vendor"];
				var vendorname = vendorinfo.Vendor__c;
				var vendorid = vendorinfo.Id;
				updateConfigMap[guid] = [];
				updateConfigMap[guid].push(
					{
						name: "Vendor Name",
						value: vendorname
					},
					{
						name: "Vendor",
						value: vendorid
					}
				);
			}
		});
	}
	if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
		keys = Object.keys(updateConfigMap);
		for (let i = 0; i < keys.length; i++) {
			component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
		}
	}
	return Promise.resolve(true);
};

//Added by Venkat - EDGE - 92244
const getExistingTenancySubscriptions = async (accountId, solution) => {
	let inputMap1 = {};
	let currentBasketTMDM = await CS.SM.getActiveBasket();
	var checkexistingsubs = false;
	inputMap1["getExistingTenancySubscriptions"] = accountId;
	//solution.schema.configurations.forEach((config)  => {
	let component = solution.getComponentByName("Platform");
	if (component) {
		let configurations = component.getConfigurations();
		if (configurations) {
			Object.values(configurations).forEach((config) => {
				//let changetypeattr = config.getAttribute("ChangeType"); NOT used
				//Monali
				checkexistingsubs = true;
				//if (changetypeattr && changetypeattr.length > 0 && (changetypeattr[0].value === 'New' || changetypeattr[0].value === 'Modify') && config.id === null) {
				//     checkexistingsubs = true;
				// }
			});
		}
	}
	if (checkexistingsubs) {
		//CS.SM.WebService.performRemoteAction('SolutionActionHelper',inputMap1).then(result => {
		await currentBasketTMDM.performRemoteAction("SolutionActionHelper", inputMap1).then((result) => {
			var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptions"]);
			if (existingsubscriptions != null && existingsubscriptions !== "") {
				var boo = window.confirm("This account has existing Active MDM Tenancy Subscription(s). Existing Tenancy Id(s) :" + existingsubscriptions + ".Do you want to proceed adding new Tenancies?");
				if (boo !== true) CS.SM.deleteSolution(solution.id);
			}
		});
	}
	return Promise.resolve(true);
};
/**
 * Author      : Payal : Added for capturing data from iFrame
 * Functions for processing iFrame messages
 */
function TenancyPlugin_processMessagesFromIFrame() {
	if (!communitySiteId) {
		return;
	}
	var data = sessionStorage.getItem("payload");
	var close = sessionStorage.getItem("close");
	var message = {};
	if (data) {
		message["data"] = JSON.parse(data);
		TenancyPlugin_handleIframeMessage(message);
	}
	if (close) {
		message["data"] = close;
		TenancyPlugin_handleIframeMessage(message);
	}
}
/*
    User Story : EDGE-119832
    Developer Name : Maq
    Desc : Changes made for MDM Tenancy
    */
const TenancyPlugin_handleIframeMessage = async (e) => {
	if (e.data && e.data["command"] && e.data["command"] === "AddLegacyTenancy" && e.data["caller"] && e.data["caller"] === "MDMTenancy") {
		await CHOWNUtils.getParentBillingAccount(TENANCY_COMPONENT_NAMES.solution); //EDGE-224663
		var TenancyList = new Array();
		let currentSolution = await CS.SM.getActiveSolution();
		if (tenancyAPIdone == false) {
			let payloadResponse = JSON.parse(e.data["data"]);
			var updateMap = [];
			for (var i = 0; i < payloadResponse.length; i++) {
				var tenancyRecord = payloadResponse[i];
				TenancyList.push(tenancyRecord.id);
				//Fix to update the map with each value
                updateMap.push(
					{
						name: "Tenancy Id",
                        value: {value: tenancyRecord.id,
                        displayValue: tenancyRecord.id}
                    });
                    updateMap.push({
						name: "Vendor Name",
                        value: {value: tenancyRecord.name,
                        displayValue: tenancyRecord.name}
                    });
                    updateMap.push({
						name: "ChangeType",
                        value: {value: "transition",
                        displayValue: "transition"}
                    });
					//EDGE-224663 start------
					if(accountId){
						updateMap.push({
							name: "AccountId",
							value: {value: accountId,
							displayValue: accountId}
						});
					}
					if(parentBillingAccountATT){
						updateMap.push({
							name: "BillingAccountLookup",
							value: {value: parentBillingAccountATT.value,
							displayValue: parentBillingAccountATT.displayValue}
						});
					}
					//EDGE-224663 end -----
			}
			//Fix to traverse the Config instead of method
			//let components = currentSolution.getComponents();
            let comp = currentSolution.getComponentByName("Platform");
            if (comp) {
                //Object.values(components).forEach((comp) => {
                /*  let configurations = comp.getConfigurations();
                    if (configurations) { */
                        Object.values(comp.schema.configurations).forEach((config) => {
                            let attribute = config.getAttribute("Tenancy Id");
                            if (attribute) {
								if (attribute.name === "Tenancy Id" && attribute.value) {
									if (TenancyList.includes(attribute.value)) {
										tenancyAPIdone = true;
									}
								}
							}
						});
                    //}
                //});
			}
			if (tenancyAPIdone === false && TenancyList.length > 0) {
				let comp = currentSolution.getComponentByName("Platform");
            if (comp) {
                    tenancyAPIdone = true;
                    //Fix to add the new Config
                    const newConfig = comp.createConfiguration(updateMap);
                    comp.addConfiguration(newConfig, true);
                    //CS.SM.addConfigurations(comp.name, updateMap);
				}
                //Fix to show only the Success Message.
				CS.SM.displayMessage("Legacy Tenancy Services added successfully", "success");
			} else {
				if (TenancyList.length == 0) CS.SM.displayMessage("No Legacy Tenancy Services Available", "error");
				else CS.SM.displayMessage("Legacy Tenancy Services already added", "error");
			}
		} else {
			CS.SM.displayMessage("Legacy Tenancy Services already added", "error");
		}
	}
	//Added as a part of EDGE-189788
	else if (e.data && e.data["command"] && e.data["command"] === "RateCard" && e.data["caller"] && e.data["caller"] === TENANCY_COMPONENT_NAMES.tenancy) { //EDGE-228932: Modified Value "TMDM" to "Platform"
		await CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],TENANCY_COMPONENT_NAMES.tenancy); //Added as a part of EDGE-189788 //EDGE-228932: Removed param callerNameNGUC
	}
	//Added as part of EDGE-228932: To handle close event in order to close the modal
	else if(e.data && e.data === 'close') {
		pricingUtils.closeModalPopup();
	}
	return Promise.resolve(true);
};

const populateRateCardinAttachmentTenancy = async () => {
	var c = 0;
	// CS.SM.getActiveSolution();
	if (basketStage !== "Contract Accepted") return;
	let currentBasketTMDM = await CS.SM.getActiveBasket();
	let currentSolution = await CS.SM.getActiveSolution();

	if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
		let comp = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
		if (comp) {
			let configurations = comp.getConfigurations();
			if (configurations) {
				let inputMap = {};
				inputMap["basketid"] = basketId;
				inputMap["Offer_Id__c"] = "DMCAT_Offer_000681";
				inputMap["SolutionId"] = currentSolution.id;

				await currentBasketTMDM.performRemoteAction("TierRateCardNCSHelper", inputMap).then(function (response) {
					if (response && response["UCRateCard"] != undefined) {
					}
				});
			}
		}
	}
	return Promise.resolve(true);
};

//Added by Monali - DPG - 2168
const getExistingTenancySubscriptionsForBilling = async (billingAccount) => {
	//async function getExistingTenancySubscriptionsForBilling(billingAccount,componentName,guid) {
	console.log("getExistingTenancySubscriptionsForBilling " + billingAccount);
	//let updateMap =  new Map();
	//let componentMapNew =   new Map();
	//let component = await solution.getComponentByName(componentName); //PD
	//let config = await component.getConfiguration(guid);//PD
	let inputMap1 = {};
	let currentBasket = await CS.SM.getActiveBasket();
	var checkexistingsubs = false;
	inputMap1["getExistingTenancySubscriptionsForBilling"] = billingAccount;
	//CS.SM.WebService.performRemoteAction('SolutionActionHelper',inputMap1).then(result => {
	await currentBasket.performRemoteAction("SolutionActionHelper", inputMap1).then((result) => {
		console.log("getExistingTenancySubscriptionsForBilling finished with response: ", result);
		var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptionsForBilling"]);
		console.log("getExistingTenancySubscriptionsForBilling: ", existingsubscriptions);
		if (existingsubscriptions != null && existingsubscriptions !== "") {
			var boo = window.confirm("There are existing MDM tenancies on the customer billing account. Existing Tenancy Id(s) :" + existingsubscriptions + ".Do you want to proceed adding new Tenancies?");
			//if (boo !== true)
			//	CS.SM.deleteSolution(solution.id);
			//config.status = false;
			//config.statusMessage = 'There are existing MDM tenancies on the customer billing account.';
		} else {
			//config.status = true;
			//config.statusMessage = '';
		}
		//if(componentMapNew && componentMapNew.size>0){
		//									updateMap.set(guid,componentMapNew);
		//									CommonUtills.UpdateValueForSolution(componentName,updateMap)
		//								}
	});
	return Promise.resolve(true);
};

/****************************************************************************************************
 * Author	: Shresth Dixit
 * Method Name : handleButtonVisibility
 * Defect/US # : DPG-2084
 * Invoked When: On Solution Load
 * Description : For Setting Visibility
 * Modified By: Payal : Modified as a part of EDGE-189788
 ************************************************************************************************/
const handleButtonVisibility = (solution) => {
	//shresth DPG-2084
	var readOnly = false;
	if (solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			var offerid = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter((att) => {
				return att.name === "OfferId";
			});
			if(offerid[0].value == undefined || offerid[0].value == ""){
				readOnly = true;
			}
				let component = solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
				if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0){
					Object.values(component.schema.configurations).forEach((config)=>{
						let attnameToattMap ={};
						var guid = config.guid;
						attnameToattMap[guid] = [];
						attnameToattMap[guid].push({
							name: 'TMDMRateCard',
							readOnly: readOnly
						});
						if (attnameToattMap && Object.keys(attnameToattMap) && Object.keys(attnameToattMap).length > 0) {
							component.updateConfigurationAttribute(guid, attnameToattMap[guid], true);
						}
					});
				}

		}
	}
};
/****************************************************************************************************
 * Author	: Mohammed Zeeshan
 * Method Name : 
 * Defect/US # :INC000094596954
 * Invoked When: On Solution Load
 * Description : For TMDM Fix
 ************************************************************************************************/
async function UpdateModuleChangeforOppty (solution) {
		 console.log("Inside UpdateModuleChangeforOppty");
         let inputMap = {};
         let currentBasket = await CS.SM.getActiveBasket();
    	//console.log("currentBasket-->",currentBasket);
         let comp=await solution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
         let configs=await comp.getConfigurations();
    	//console.log("configs-->",configs);
         for(let config of Object.values(configs)){
             //console.log("Inside for config");
            var ChangeType =await config.getAttribute('ChangeType');
            if(ChangeType && ChangeType.value==='transition'){
                //console.log("if ChangeType-->");
                inputMap["GetBasket"] = currentBasket.basketId;
                await currentBasket.performRemoteAction("UpdateModuleChangeforOppty", inputMap).then((result) => {});

		}
	}
};
