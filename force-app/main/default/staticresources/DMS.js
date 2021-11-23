/******************************************************************************************
 * Author	   : Kanhaiya Pasoria(Team Radium)
   Description : Static Resource File for Digital Managed Service.

   Change Version History
    Version No	             Author 			             Date                     Description

    1                        Nikhil Sharma                   06/08/2021               TenancyPlugin_handleIframeMessageDMS
	2						 Shashank kulshreshtha			 18/08/2021				  DIGI-4637 

 ********************/

const DMS_COMPONENT_NAMES = {
	solution: "Digital Managed Service",
	tenancy: "DMS Product"
};
var mdmtenancyid = null;


var solution = "";
var isTypeNew = false;
var tenancyAPIdone = false;
var offerName = "DMCAT_Offer_001540";
var DEFAULTSOLUTIONNAME_DMS = "Digital Managed Service";
var c = 0;
var billingAccount = "";
var communitySiteId = "";

if (!CS || !CS.SM) {
	throw Error("Solution Console Api not loaded?");
}

if (CS.SM.registerPlugin) {
	console.log("Load DMS plugin");
	window.document.addEventListener("SolutionConsoleReady", async function () {
		await CS.SM.registerPlugin(DMS_COMPONENT_NAMES.solution).then(async (TenancyPlugin) => {
			updateTenancyPluginDMS(TenancyPlugin);
			return Promise.resolve(true);
		});
		return Promise.resolve(true);
	});
}
function updateTenancyPluginDMS(TenancyPlugin) {
	window.addEventListener("message", TenancyPlugin_handleIframeMessageDMS);
	//Utils.updateCustomButtonVisibilityForBasketStage();
	//Utils.updateImportConfigButtonVisibility();

	TenancyPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		let solution = result.solution;
		CommonUtills.unlockSolution();
		//setOEtabsforPlatformDMS(solution);
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails();
            UpdateModuleChangeforOpptyDMS(solution);
			CommonUtills.lockSolution();
			return Promise.resolve(true);
	};

	TenancyPlugin.afterSolutionDelete = function (solution) {
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	};



	//######changes started by shashank  DIGI-4637
	//Event to handle load of OE tabs
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
			console.log('OrderEnrichmentTabLoaded', e);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			//addDefaultSDWAN_OETenancyConfigs();
		}
		return Promise.resolve(true);
	});

	/**
	 * Hook executed after the Order Enrichment configuration is deleted via the UI delete configuration button
	 *
	 * @param {string} component - Component object where the configuration resides
	 * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
	 * @param {Object} orderEnrichmentConfiguration - Order Enrichment object which is deleted
	 */
	TenancyPlugin.afterOrderEnrichmentConfigurationDelete = async function(component, configuration, orderEnrichmentConfiguration) {
	window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
	return Promise.resolve(true);
	};

	//###### */ changed ended here by shashank DIGI-4637



	window.document.addEventListener("SolutionSetActive", async function (e) {
		let currentBasketDMS = await CS.SM.getActiveBasket();
		let loadedSolutionDMS = await CS.SM.getActiveSolution();

		if (loadedSolutionDMS.name.includes(DMS_COMPONENT_NAMES.solution)) {
			window.currentSolutionName = loadedSolutionDMS.name;
			Utils.updateOEConsoleButtonVisibility();
			if (loadedSolutionDMS.componentType && loadedSolutionDMS.name.includes(DMS_COMPONENT_NAMES.solution)) {
				c = 0;

				basketId = currentBasketDMS.basketId;
				solution = loadedSolutionDMS;
				let inputMap = {};
				inputMap["GetSiteId"] = "";
				inputMap["GetBasket"] = basketId;
				if (basketStage === "Contract Accepted") {
					loadedSolutionDMS.lock("Commercial", false);
				}
				await CommonUtills.getBasketData(currentBasketDMS);
				await CommonUtills.getSiteDetails(currentBasketDMS);
				// handleButtonVisibilityDMS(loadedSolutionDMS);
                CommonUtills.unlockSolution();
				if (accountId != null) {

					await CommonUtills.setAccountID(DMS_COMPONENT_NAMES.solution, accountId);
				}
				console.log('addDefaultGenericOEConfigs');
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DMS);
				//setOEtabsforPlatformDMS(solution);
				if (basketStage === "Contract Accepted") {
					loadedSolutionDMS.lock("Commercial", true);
				}
				CommonUtills.lockSolution();
			}
		}
		return Promise.resolve(true);
	});

	TenancyPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolutionDMS) {
		return Promise.resolve(true);
	};

	TenancyPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		let currentBasketDMS = await CS.SM.getActiveBasket();
		let currentSolution = await CS.SM.getActiveSolution();
		let currentComponent = currentSolution.getComponentByName(component.name);
		var updateMap = {};
		var vendorname = "";
		let inputMap = {};
		inputMap["OfferId"] = offerName;


		let comp = currentSolution.getComponentByName("DMS Product");
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {

			if (window.accountId !== null && window.accountId !== "") {

				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(DMS_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){

				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		}



		await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DMS);
		return Promise.resolve(true);
	};


	TenancyPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		CommonUtills.unlockSolution();
		let oldValue = oldValueMap.value;
		let loadedSolutionDMS = await CS.SM.getActiveSolution();
		if (attribute["Solution Name"] === DEFAULTSOLUTIONNAME_DMS && attribute.name == "Marketable Offer") {
			CommonUtils.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue);
		}
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionDMS.lock("Commercial", false);

		// 	changes started by shashank  DIGI-4637
		if (component.name === 'Customer requested Dates') {
					window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		}
		}
		if (component.name === "Tenancy Admin Contact Details" && attribute.name === "TenancyPrimaryContact") {
			updateTenancyContactDetailsDMS(configuration.parentConfiguration, attribute.value);
		}
		// changes ended by shashank  DIGI-4637
		if (component.name === DMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup") {

			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(DMS_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){

				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', DMS_COMPONENT_NAMES.tenancy,oldValue);
				}
			}
		}



		if (component.name === DMS_COMPONENT_NAMES.solution && attribute.name === "OfferId") {


			//handleButtonVisibilityDMS(loadedSolutionDMS);
		}


		if (component.name === DMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountShadow") {

			billingAccount = attribute.value;


		}

		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		if (window.basketStage === "Contract Accepted") {
			loadedSolutionDMS.lock("Commercial", true);
		}
		CommonUtills.lockSolution();
		return Promise.resolve(true);
	};

	TenancyPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		CommonUtills.unlockSolution();



		var ExpectedSIO = await CommonUtills.validateExpectedSIO();
		if(!ExpectedSIO) {
            return Promise.resolve(false);
        }
		CommonUtills.lockSolution();
		return Promise.resolve(true);
	};
}

// const setOEtabsforPlatformDMS = function (solution) {
// 	if (solution.componentType && solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
// 		let comp = solution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
// 		if (comp) {
// 			if (Utils.isOrderEnrichmentAllowed()) {
// 				let configurations = comp.getConfigurations();
// 				if (configurations) {
// 					Object.values(configurations).forEach((config) => {
// 						CS.SM.setOEtabsToLoad(comp.name, config.guid, ["DMS Tenancy Admin Contact"]);
// 					});
// 				}
// 			}
// 		}
// 	}
// };

const updateTenancyContactDetailsDMS = async (guid, newValue) => {
	if (basketStage !== "Contract Accepted") {
		return Promise.resolve(true);
	}
	let currentSolution = await CS.SM.getActiveSolution();

	if (currentSolution.componentType && currentSolution.name.includes(DMS_COMPONENT_NAMES.solution)) {
		let currentComponent = currentSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
		if (currentComponent) {
			let config = currentComponent.getConfiguration(guid);
			if (config) {
				if (basketStage === "Contract Accepted") {
					currentSolution.lock("Commercial", false);
				}
				var updateConfigMap = {};
				updateConfigMap[config.guid] = [];
				updateConfigMap[config.guid].push({
					name: "TenancyPrimaryContact",
					value: newValue
				});
				
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



const getExistingTenancySubscriptionsDMS = async (accountId, solution) => {
	let inputMap1 = {};
	let currentBasketDMS = await CS.SM.getActiveBasket();
	var checkexistingsubs = false;
	inputMap1["getExistingTenancySubscriptionsDMS"] = accountId;
	let component = solution.getComponentByName("DMS Product");
	if (component) {
		let configurations = component.getConfigurations();
		if (configurations) {
			Object.values(configurations).forEach((config) => {

				checkexistingsubs = true;

			});
		}
	}
	if (checkexistingsubs) {
		await currentBasketDMS.performRemoteAction("SolutionActionHelper", inputMap1).then((result) => {
			var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptionsDMS"]);
			if (existingsubscriptions != null && existingsubscriptions !== "") {
				var boo = window.confirm("This account has existing Active DMS Tenancy Subscription(s). Existing Tenancy Id(s) :" + existingsubscriptions + ".Do you want to proceed adding new Tenancies?");
				if (boo !== true) CS.SM.deleteSolution(solution.id);
			}
		});
	}
	return Promise.resolve(true);
};
/**
 * Added for capturing data from iFrame
 * Functions for processing iFrame messages
 */
function TenancyPlugin_processMessagesFromIFrameDMS() {
	if (!communitySiteId) {
		return;
	}
	var data = sessionStorage.getItem("payload");
	var close = sessionStorage.getItem("close");
	var message = {};
	if (data) {
		message["data"] = JSON.parse(data);
		TenancyPlugin_handleIframeMessageDMS(message);
	}
	if (close) {
		message["data"] = close;
		TenancyPlugin_handleIframeMessageDMS(message);
	}
}

const TenancyPlugin_handleIframeMessageDMS = async (e) => {

	//Added by Nikhil as part of DIGI-603
	if(e.data && e.data === 'close') {
		pricingUtils.closeModalPopup();
	}
	return Promise.resolve(true);
};

const populateRateCardinAttachmentTenancyDMS = async () => {
	var c = 0;

	if (basketStage !== "Contract Accepted") return;
	let currentBasketDMS = await CS.SM.getActiveBasket();
	let currentSolution = await CS.SM.getActiveSolution();

	if (currentSolution.componentType && currentSolution.name.includes(DMS_COMPONENT_NAMES.solution)) {
		let comp = currentSolution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
		if (comp) {
			let configurations = comp.getConfigurations();
			if (configurations) {
				let inputMap = {};
				inputMap["basketid"] = basketId;
				inputMap["Offer_Id__c"] = offerName;
				inputMap["SolutionId"] = currentSolution.id;

				await currentBasketDMS.performRemoteAction("TierRateCardNCSHelper", inputMap).then(function (response) {
					if (response && response["UCRateCard"] != undefined) {
					}
				});
			}
		}
	}
	return Promise.resolve(true);
};

/********************************************
 * Invoked When: On Solution Load
 * Description : For Setting Visibility
 ********************************************/
const handleButtonVisibilityDMS = (solution) => {
	var readOnly = false;
	if (solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			var offerid = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter((att) => {
				return att.name === "OfferId";
			});
			if(offerid[0].value == undefined || offerid[0].value == ""){
				readOnly = true;
			}
				let component = solution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
				if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0){
					Object.values(component.schema.configurations).forEach((config)=>{
						let attnameToattMap ={};
						var guid = config.guid;
						attnameToattMap[guid] = [];
						attnameToattMap[guid].push({
							name: 'DMSRateCard',
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
/***********************************
 * Invoked When: On Solution Load
 * Description : For TMDM Fix
 ***********************************/
async function UpdateModuleChangeforOpptyDMS (solution) {
		 console.log("Inside UpdateModuleChangeforOpptyDMS");
         let inputMap = {};
         let currentBasket = await CS.SM.getActiveBasket();
         let comp=await solution.getComponentByName(DMS_COMPONENT_NAMES.tenancy);
         let configs=await comp.getConfigurations();
         for(let config of Object.values(configs)){
            var ChangeType =await config.getAttribute('ChangeType');
            if(ChangeType && ChangeType.value==='transition'){
                inputMap["GetBasket"] = currentBasket.basketId;
                await currentBasket.performRemoteAction("UpdateModuleChangeforOpptyDMS", inputMap).then((result) => {});

		}
	}
};
