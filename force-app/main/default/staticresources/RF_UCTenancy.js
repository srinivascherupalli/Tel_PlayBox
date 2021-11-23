/******************************************************************************************
 * Author	   : CloudSense Team
 Change Version History
Version No	Author 			Date        Change Description 
1 			Venkat		 	18-Sept-19	Initial file  - EDGE 108257,EDGE 114158, EDGE 107435
2 			Aman Soni		19-May-2020		EDGE-148455 - To capture Billing Account
3           Gnana           10-Jun-2020     EDGE-149887 - Solution Name Update Logic 
4           Sandip          19-Jun-2020 	Modified as per SM Summer20 version
5 			Gnana & Aditya  19-Jul-2020		Spring'20 Upgrade
6 			Martand 		3-10-2020		Refactored
7          Anuj Pathak      24-Feb-2021     Edge-101003 - Populate tenancy legacy id
8          Vivek               08/11/2021      DIGI-3208
9          Vivek              09/26/2021       DIGI-14126
10.        Mukta             06/10/2021      DIGI-30100 Fix
11.			Vijay			07/11/2021		DIGI-456
 ********************/
var communitySiteIdUC;
var ngucVariables = {

	NGUC_OFFER_NAME: 'Adaptive Collaboration',
	NGUC_PROF_SERV_OFFR_NAME: 'Adaptive Collaboration Professional Services',
	NGUC_TENANCY_OFFER_NAME: 'Adaptive Collaboration Tenancy'
 };
var NEXTGENUCTENANCY_COMPONENTS = {
	UCTenancySol: ngucVariables.NGUC_TENANCY_OFFER_NAME, //'Unified Communication Tenancy'//Telstra Collaboration Tenancy', DIGI-3208
	UCTenancy: "Tenancy_BroadsoftTenancy",
	UCTenancyNew: 'Broadsoft Tenancy' //Added as part of EDGE-101003
};
var executeSaveNgUCtenancy = false;
var saveNgUCtenancy = false;
var DEFAULTSOLUTIONNAME_UCT = ngucVariables.NGUC_TENANCY_OFFER_NAME; // Added as part of EDGE-149887 , DIGI-3208
var DEFAULTOFFERNAME_UCT = "Unified Communication Tenancy"; //Added as part of EDGE-149887 TODO update in Schema
var saveUCtenancy = false; //Added as part of EDGE-149887


if (!CS || !CS.SM) {
	throw Error("Solution Console Api not loaded?");
}

if (CS.SM.registerPlugin) {
	console.log("Loaded Telstra Collaboration Tenancy Plugin");
	window.document.addEventListener("SolutionConsoleReady", async function () {
		console.log("SolutionConsoleReady");
		await CS.SM.registerPlugin(ngucVariables.NGUC_TENANCY_OFFER_NAME).then(async (UCTenancyPlugin) => {   // DIGI-3208
			updateUCTenancyPlugin(UCTenancyPlugin);
		});
	});
}

async function updateUCTenancyPlugin(UCTenancyPlugin) {
	console.log("inside hooks", UCTenancyPlugin);
	window.document.addEventListener("SolutionSetActive", async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
            //EDGE-220237 Starts
            window.addEventListener("message", UCTenancy_handleIframeMessage);
	        setInterval(UCTenancy_processMessagesFromIFrame, 500);
            //EDGE-220237 Ends
			console.log("SolutionSetActive", e);
			currentBasket = await CS.SM.getActiveBasket();
			const basketId = currentBasket.basketId;
            await CommonUtills.getBasketData(currentBasket);//RF++
            await CommonUtills.getSiteDetails(currentBasket);
			let inputMap = {};
			inputMap["GetBasket"] = basketId;
			await Utils.loadSMOptions(); //EDGE-216668
			/*await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
				console.log("GetBasket finished with response: ", result);
				var basket = JSON.parse(result["GetBasket"]);
				console.log("GetBasket: ", basket);
				basketChangeType = basket.csordtelcoa__Change_Type__c;
				basketStage = basket.csordtelcoa__Basket_Stage__c;
				accountId = basket.csbb__Account__c;
				console.log("basketChangeType: ", basketChangeType, " basketStage: ", basketStage, " accountId: ", accountId);
				window.oeSetBasketData(solution, basketStage, accountId);
				//Added by Aman Soni as a part of EDGE -148455 || Start
				if (accountId != null && basketStage !== "Contract Accepted") {
					CommonUtills.setAccountID(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol, accountId);
				}
				//Added by Aman Soni as a part of EDGE -148455 || End
			});*/
			//	addDefaultUCOETenancyConfigs();
			 //Vijay: DIGI-456 start...
			var activeNGUCBasket = await CS.SM.getActiveBasket();
			await Utils.updateOEConsoleButtonVisibility_v2(activeNGUCBasket, 'oeNGUCTenancy');
			//Vijay: DIGI-456 ...end
			if(!window.isToggled){//Added by vijay DIGI-456
				Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_UCT);
			}else{
				CommonUtills.oeErrorOrderEnrichment();
			}
			//EDGE-216668
			Utils.updateCustomButtonVisibilityForBasketStage();
			// DIGI-14126 : VIVEK
			var OpportunityType;
			let inputMap2 = {};
			inputMap2["GetBasket"] = basketId;

			await currentBasket.performRemoteAction("SolutionActionHelper", inputMap2).then(async (result) => {
				var basket = JSON.parse(result["GetBasket"]);
				OpportunityType = basket.Opportunity_Type__c;
				console.log('GetBasket: ', basket.Opportunity_Type__c);
			});


			if (OpportunityType == 'CHOWN') {
				var buttons = document.getElementsByClassName('cs-btn');
				for (var i = 0; i < buttons.length; i++) {
					if (buttons[i].innerText == 'Order Enrichment Console') {
						buttons[i].style.display = "none";
					}
				}
			}
		}
		return Promise.resolve(true);
	});

	//Event to handle load of OE tabs
	window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
			console.log("OrderEnrichmentTabLoaded", e);
			let schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
		}
		return Promise.resolve(true);
	});

	/**
	 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
	 * boolean. The save will continue only if the promise resolve with true.
	 * Updated by : Venkata Ramanan G
	 * To create case for the configuration in case the business criteria w.r.t to pricing has met
	 * @param {Object} complexProduct
	 */
	UCTenancyPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		try {
        updateSolutionName_UCT(); // Added as part of EDGE-149887
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		Utils.hideSubmitSolutionFromOverviewTab();

		Utils.updateCustomButtonVisibilityForBasketStage();
        } catch (error) {
            CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
            console.log(error);
        }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
		return Promise.resolve(true);
	};
	/**
	 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
	 * boolean. The save will continue only if the promise resolve with true.
	 * Updated by : Anuj Pathak
	 * To create case for the configuration in case the business criteria w.r.t to pricing has met
	 * @param {Object} complexProduct
	 */
	UCTenancyPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		// from here Added as part of EDGE-101003
		currentBasket = await CS.SM.getActiveBasket();
         
		/*if (currentBasket["basketStageValue"]=='Contract Accepted')
		{
		populateLegacyTenancyID(currentBasket);
		}*/
        var doNotStopValidateSave = await checkTenancyPCRecord(); 
             console.log('In doNotStopValidateSave', doNotStopValidateSave);
        if (!doNotStopValidateSave) {
            return Promise.resolve(false);
        }
         
		// till here Added as part of EDGE-101003
		// await Utils.updateActiveSolutionTotals();
		// CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		// Utils.hideSubmitSolutionFromOverviewTab();

		return Promise.resolve(true);
	};

	
	/**
	 * Hook executed after the Order Enrichment configuration is added via the UI add configuration button
	 *
	 * @param {string} component - Component object where the configuration resides
	 * @param {Object} configuration - Main configuration object for which OE configuration is  created
	 * @param {Object} orderEnrichmentConfiguration - Order Enrichment Configuration which is inserted
	 */
	UCTenancyPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) {
		Utils.initializeGenericOEConfigs();
		window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};

	/**
	 * Hook executed after the Order Enrichment configuration is deleted via the UI delete configuration button
	 *
	 * @param {string} component - Component object where the configuration resides
	 * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
	 * @param {Object} orderEnrichmentConfiguration - Order Enrichment object which is deleted
	 */
	UCTenancyPlugin.afterOrderEnrichmentConfigurationDelete = async function (component, configuration, orderEnrichmentConfiguration) {
		window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};

	/**
	 * Provides the user with an opportunity to do something once the attribute is updated.
	 *
	 * @param {string} component - Component object where the configuration resides
	 * @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
	 * @param {object} attribute - The attribute which is being updated.
	 * @param {string} oldValueMap - Before change value.
	 */
	UCTenancyPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		console.log("Attribute Update - After", component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);

		if (component.name === "Tenancy Contact Details" && attribute.name === "TenancyPrimaryContact") {
			window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
		}
		return Promise.resolve(true);
	};

	//Aditya: Spring Update for changing basket stage to Draft
	UCTenancyPlugin.afterSolutionDelete = function (solution) {
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	};
}

/**********************************************************************************************************************************************
 * Author	   : Venkat
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if tehere is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
/* async function addDefaultUCOETenancyConfigs() {
	if (basketStage !== "Contract Accepted") return;
	console.log("addDefaultOEConfigs");
	var oeMap = [];
	let currentSolution = await CS.SM.getActiveSolution();
	console.log("addDefaultOEConfigs ", currentSolution.name, NEXTGENUCTENANCY_COMPONENTS.UCTenancySol);
	if (currentSolution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
		console.log("addDefaultOEConfigs - looking components", currentSolution);
		let comps = await currentSolution.getComponents();
		if (comps) {
			Object.values(comps).forEach((comp) => {
                let configurations = await comp.getConfigurations();
                if(configurations){
                    Object.values(configurations).forEach((config) => {
                        let oeList = config.getOrderEnrichments();
                        Object.values(oeList).forEach((oeSchema) => {
                            if (oeSchema) {//REVIEW
                                let oeConfig = false;
                                oeConfig = oeList.some((oe) => {
                                        return  oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId;
                                    });
                                
                                if (!oeConfig) {
                                    oeMap.push({
                                        componentName: comp.name,
                                        configGuid: config.guid,
                                        oeSchema: oeSchema
                                    });
                                    console.log("Adding default oe config for:", comp.name, config.name, oeSchema.name);
                                }
                            }
                        });
                    });
                }
                
			});
		}
	}
	if (oeMap.length > 0) {
		console.log("Adding default oe config map:", oeMap);
		for (var i = 0; i < oeMap.length; i++) {
			let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
			let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
			component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
		}
	}
	await initializeUCOETenancyConfigs();
	return Promise.resolve(true);
} */
/**********************************************************************************************************************************************
 * Author	   : Vebkat
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
/* async function initializeUCOETenancyConfigs() {
	console.log("initializeOEConfigs");
	let currentSolution = await CS.SM.getActiveSolution();
	let configurationGuid = "";
	if (currentSolution) {
		console.log("initializeUCOEConfigs - updating");
		if (currentSolution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
			let comps = await currentSolution.getComponents();

			if (comps) {
				for (const comp of Object.values(comps)) {
					let configurations = await comp.getConfigurations();
					if (configurations) {
						for (const config of Object.values(configurations)) {
							configurationGuid = config.guid;
							var updateMap = {};
							let oeList = config.getOrderEnrichments();

							if (oeList) {
								for (const oe of oeList) {
									let basketAttribute = Object.values(oe.attributes).find((a) => {
										return a.name.toLowerCase() === "basketid";
									});
									if (basketAttribute) {
										if (!updateMap[oe.guid]) updateMap[oe.guid] = [];
										updateMap[oe.guid].push({ name: basketAttribute.name, value: basketId });
									}
								}
							}
							if (updateMap && Object.keys(updateMap).length > 0) {
								if (updateMap && Object.keys(updateMap).length > 0) {
									keys = Object.keys(updateMap);
									console.log("initializeOEConfigs updateMap:", updateMap);
									for (var i = 0; i < updateMap.length; i++) {
										comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid, keys[i], updateMap[keys[i]], true);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return Promise.resolve(true);
} */

/* 	
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_UCT() {
	var listOfAttributes = ["Solution Name", "GUID"],
		attrValuesMap = {};
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, NEXTGENUCTENANCY_COMPONENTS.UCTenancySol);
	let solution = await CS.SM.getActiveSolution();
	let component = solution.getComponentByName(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol);
	let guid;
	console.log("attrValuesMap..." + attrValuesMap);
	if (attrValuesMap["Solution Name"] === DEFAULTSOLUTIONNAME_UCT) {
		let updateConfigMap = {};
		// updateConfigMap[attrValuesMap['GUID']] = [{
		// 	name: 'Solution Name',
		// 	value: {
		// 		value: DEFAULTOFFERNAME_UCT,
		// 		displayValue: DEFAULTOFFERNAME_UCT
		// 	}

		// }];
		guid = attrValuesMap["GUID"];
		updateConfigMap[guid] = [];
		updateConfigMap[guid].push({
			name: "Solution Name",
			value: DEFAULTOFFERNAME_UCT,
			displayValue: DEFAULTOFFERNAME_UCT
		});
		//CS.SM.updateConfigurationAttribute(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol, updateConfigMap, true);
		if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
			keys = Object.keys(updateConfigMap);
			var complock = component.commercialLock;
			if (complock) component.lock("Commercial", false);

			for (let i = 0; i < keys.length; i++) {
				component.lock("Commercial", false);
				await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			}
			if (complock) {
				component.lock("Commercial", true);
			}
		}
	}
	return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Anuj Pathak
 * Method Name : populateLegacyTenancyID
 * Invoked When: after solution is save and validated,  configuration is updated
 * Description : 1. sets tenancy id to basket configs so it is available immediately after opening basket
 * Parameters  : currentBasket
 ********************************************************************************************************************************************/
 async function populateLegacyTenancyID(currentBasket) {
	let updateMap;
	let component;
	let loadedSolutionUC = await CS.SM.getActiveSolution();
	if (loadedSolutionUC.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {

		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
			for (let comp of Object.values(loadedSolutionUC.components)) {
				if (comp.name === NEXTGENUCTENANCY_COMPONENTS.UCTenancyNew) {
					component = comp;
					updateMap = {};
					let configurations = comp.getConfigurations();
					for (let config of Object.values(configurations)) {
						const basketId = currentBasket.basketId;
						let inputMap = {};
						inputMap["populateLegacyTenancyID"] = basketId;
						await currentBasket.performRemoteAction("LegacyTenancyHelper", inputMap).then((result) => {
							updateMap[config.guid] = [];
							console.log(result);
							if (result != null) {
								updateMap[config.guid].push({
									name: "LegacyTenancyID",
									value: result['TenancyID']
								});
							}
							else {
								updateMap[config.guid].push({
									name: "LegacyTenancyID",
									value: ''
								});
							}
						}
						)
					}
				}

			}

		}
           
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    var complock = component.commercialLock;
                    if (complock)
                                component.lock('Commercial', false);
    
                    for (let i = 0; i < keys.length; i++) {
                        //await solution.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                        component.lock('Commercial', false);
                        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                            if (complock) {
                                component.lock('Commercial', true);
                            }
                }
            
        }
        return Promise.resolve(true);		
    }

	async function checkTenancyPCRecord() {
		var doNotStopValidateSave = true;
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
			let component = solution.getComponentByName(NEXTGENUCTENANCY_COMPONENTS.UCTenancyNew);
			if (component) {
				let config = await component.getConfigurations();
				console.log('No of PCs', Object.values(config).length);
				if (config && Object.values(config).length == 0) {
					doNotStopValidateSave = false
					CS.SM.displayMessage('Atleast one Broadsoft Tenancy product configuration is required', 'error');
				}
			}
		}
	return doNotStopValidateSave;
}
// Added this method as part of EDGE-220237
function UCTenancy_processMessagesFromIFrame() {
    if (!communitySiteIdUC) {
        return;
    }
	//Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
			 pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var childWindow = sessionStorage.getItem("childWindow");
    if (childWindow) {
		childWindow.postMessage("Hey", window.origin);
	}
	var message = {};
	if (data) {
        console.log('data', data);
		message["data"] = JSON.parse(data);
		UCTenancy_handleIframeMessage(message);
	}
	if (close) {
		message["data"] = close;
        UCTenancy_handleIframeMessage(message);
    }
}
// Added this method as part of EDGE-220237
async function UCTenancy_handleIframeMessage(e) {
    if (e.data["command"] === "createBroadsoftTenancy" && e.data["caller"]) {
            
			await createConfigforBroadsoftTenancy(e);
    }
   else if (e["data"] === 'close') {
        	//await createConfigforBroadsoftTenancy(e);
			setTimeout(await pricingUtils.closeModalPopup(), 4000);
            }
    return Promise.resolve(true);
    
}
/***********************************************************************************************
	 * Author	   : Aishwarya,Dheeraj
	 * Sprint	   : 21.09(EDGE-220237)
	 * Method Name : createConfigforBroadsoftTenancy
	 * Invoked When: Cliked on Add Tenancy Button 
	 * Description : Create Configuration against Brodsoft Tenancy
	 * parameters  : componentName, attributeDetails
	 ***********************************************************************************************/
 async function createConfigforBroadsoftTenancy(e) {
    let solution = await CS.SM.getActiveSolution();
     
	if (solution.name.includes(NEXTGENUCTENANCY_COMPONENTS.UCTenancySol)) {
		let componentName = e.data["caller"];
		let attributeDetails = e.data["data"];
		let comp = solution.getComponentByName(componentName);
		if (comp) {
			let configs = await comp.getConfigurations();
			if (configs && Object.values(configs).length == 0) {
				const configuration = comp.createConfiguration(
					[{ name: "Info", value: { value: attributeDetails.get('Info'), displayValue: attributeDetails.get('Info') } },
					{ name: "LegacyTenancyId", value: { value: attributeDetails.get('LegacyTenancyId'), displayValue: attributeDetails.get('LegacyTenancyId') } },
					]);
				await comp.addConfiguration(configuration);
			} else {
				if (configs) {
					Object.values(configs).forEach(async (config) => {
						if (config.guid) {
							let legacyTenancyId = attributeDetails.get('LegacyTenancyId');
							await comp.updateConfigurationAttribute(config.guid, [{ name: 'LegacyTenancyId', value: legacyTenancyId }]);
						}
					});
				}
			}

		}
	}
	return Promise.resolve(true);
}
 