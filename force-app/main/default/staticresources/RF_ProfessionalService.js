/*******************************************************************************************************************************
Author 			:: [Brahm]
Ref    			:: [EDGE-113349]
Description	    :: To Set Spec ID for the Type selected in the solution of Professional Service
Created Date    :: [15/11/2019 5:10 PM]
Modified        :: [Brahm][24/11/2019]
Modified   	 	:: [Purushotma Sahu][06/12/2019] EDGE-120711 - Enable oe-product checkbox-wrapper  
Modified   	 	:: [RaviTeja][26/02/2020] EDGE-133590 - Conditional Subscription Selection 
Modified        :: [Aditya] [21/05/2020]  Edge-148455 - Billing Account On Solution 
Modified        :: [Gnana] [12/06/2020]  Edge-149887 - Solution Name change logic implemented
Modified        :: [RaviTeja] [15/07/2020]  EDGE-162597 - Check for Telstra COllaboration offer
Modified        :: [Pooja] [02/07/2020]  EDGE-155255 - Re Factoring JS as per the spring 20 changes
Modified        :: [Gnana & Aditya] [19/07/2020]  Spring'20 Upgrade
Modified        :: [Gnana] [23/07/2020]  EDGE-164917 - Changed logic to get Display Value for OfferName instead of Value which was giving Id
Modified        :: [Pooja] [11/09/202] EDGE-171653 JS Optimization
Modified        :: [RaviTeja] [26/10/2020] EDGE-186075 Professional Service Billing requirements-Customer Reference Number
Modified        ::[Antun Bartonicek] [01/06/2021] EDGE-198536: Performance improvements
Modified        :: Vivek               08/11/2021      DIGI-3208
**********************************************************************************************************************************/
/*var executeSavePFS = false;
var savePFS = false;*/ //unused


var ngucVariables = {

	NGUC_OFFER_NAME: 'Adaptive Collaboration',
	NGUC_PROF_SERV_OFFR_NAME: 'Adaptive Collaboration  Professional Services', //TO DO remove this variable after proper analysis (Mukta)
	NGUC_TENANCY_OFFER_NAME: 'Adaptive Collaboration Tenancy',
	NGUC_PROF_OFFR_NAME: 'Adaptive Collaboration Professional Services'
};

var PFS_COMPONENT_NAMES = {
	solution: ngucVariables.NGUC_PROF_OFFR_NAME, // 'Professional Services',  DIGI-3208
	telstraColPFS: ngucVariables.NGUC_PROF_SERV_OFFR_NAME,      //   DIGI-3208
	telstraColProfServFeatures: "Telstra Collab Prof Serv Features",
	pfsRelatedComponent: "Professional Service Features",
	OfferName: ngucVariables.NGUC_PROF_OFFR_NAME        //  DIGI-3208
};

var basketStage = null; //unused
/*var crdoeschemaid = null;
var show = false;*/ var communitySiteId;


var DEFAULTSOLUTIONNAME_TCPS = ngucVariables.NGUC_PROF_OFFR_NAME; // Added as part of EDGE-149887 ,  DIGI-3208
var RELATED_PC_ATTRIBUTES_TO_CATPTURE = ['PurchaseOrder']


// Added Register Plugin- EDGE-155255
if (CS.SM.registerPlugin) {
	//console.log('Load PFPS plugin');
	window.document.addEventListener("SolutionConsoleReady", async function () {
		//console.log('SolutionConsoleReady');
		await CS.SM.registerPlugin(ngucVariables.NGUC_PROF_SERV_OFFR_NAME).then(async (PFSPlugin) => {        //  DIGI-3208
			// For Hooks
			PFSPlugin_updatePlugin(PFSPlugin);
		});
	});
}

//Changes as part of EDGE-155255 start
async function PFSPlugin_updatePlugin(PFSPlugin) {
	// Added as part of EDGE-155255
	//Changes as part of EDGE-155255 end
	//console.log('Adding Hooks to PFSPlugin');
	//EDGE-198536: click listener and Utils.updateImportConfigButtonVisibility moved to window.document.addEventListener('SolutionSetActive' block

	//Changes as part of EDGE-155255
	PFSPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		//console.log('afterSave - entering');
        try{
		let currentSolution = await CS.SM.getActiveSolution();
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue
		Utils.updateCustomButtonVisibilityForBasketStage();
		Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals(); //Added as part of EDGE-155255
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
    }catch(error){
        CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
        console.log(error);
    }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
		return Promise.resolve(true);
	}

	//Changes as part of EDGE-155255 start
	PFSPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		//await updateSolutionName_TCPS(); // Added as part of EDGE-149887// added await
		let currentComponent = solution.getComponentByName(PFS_COMPONENT_NAMES.solution);
		//console.log('beforeSave');
		//Changes as part of EDGE-155255 end
		//EDGE-133590  Conditional Subscription Selection
		if (basketStage === "Contract Accepted") {
			solution.lock("Commercial", false);
		} //RF for lock issue

		var skipsave = false;
		if (basketStage !== "Contract Accepted") {
			return Promise.resolve(true);
		}
		var basketHasTC = false;
		if (solution.components && Object.values(solution.components).length > 0) {
			//for (const comp of Object.values(solution.components)) { //EDGE-155255  //RF--
			//if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {//RF--
			//if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			//for (const subsConfig of Object.values(comp.schema.configurations)) { //EDGE-155255
			let comp = solution.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
			if (comp) {
				//RF++
				let cmpConfig = await comp.getConfigurations(); //RF++
				if (cmpConfig && Object.values(cmpConfig).length > 0) {
					//RF++
					for (const subsConfig of Object.values(cmpConfig)) {
						//RF++
						let att = subsConfig.getAttribute("Network"); //RF++
						//if (subsConfig.attributes && Object.values(subsConfig.attributes).length > 0) {//155255
						//for (const att of Object.values(subsConfig.attributes)) {//EDGE-155255
						if (att.name === "Network" && att.value == "") {
							//RF++
							//if (att.value == '') {//RF--
							var basketsol = window.basketsolutions;
							Object.values(basketsol).forEach((comp) => {
								//EDGE-155255
								if (comp.OfferId == "DMCAT_Offer_000618") {
									basketHasTC = true;
									//console.log('basketHasTC' + basketHasTC);
								}
							});

							if (!basketHasTC) {
								//Changes as part of EDGE-155255 start
								let confg = await currentComponent.getConfiguration(subsConfig.guid);
								//let confg = await comp.getConfiguration(subsConfig.guid); //RF
								//console.log('config' + confg);//RF--
								confg.status = false;
								confg.statusMessage = "Please select the subscription in order enrichment.";
								//Changes as part of EDGE-155255 end

								skipsave = true;
							}
							//}
						}
						//}
						//}
					}
				}
			}
		}
		//}
		if (skipsave == true) {
			return Promise.resolve(true);
		}
		if (basketStage === "Contract Accepted") {
			solution.lock("Commercial", true);
		} //RF for lock issue
		return Promise.resolve(true);
	}

	//End-  EDGE-133590  Conditional Subscription Selection

	window.document.addEventListener("SolutionSetActive", async function (e) {
		//EDGE-155255
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-155255
		if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {
			//EDGE-155255
			//console.log('solution loaded!!!');
			let loadedSolution = await CS.SM.getActiveSolution(); //EDGE-155255
			let currentBasket = await CS.SM.getActiveBasket(); //EDGE-155255
			basketId = currentBasket.basketId; //EDGE-155255
			window.currentSolutionName = loadedSolution.name;
			await CommonUtills.getBasketData(currentBasket);

			//EDGE-198536 Start: existing code moved inside active solution check
			Utils.updateCustomButtonVisibilityForBasketStage(); //EDGE-155255  Check
			document.addEventListener(
				"click",
				function (e) {
					e = e || window.event;
					var target = e.target || e.srcElement;
					var text = target.textContent || target.innerText;
					//EDGE-135267 Aakil
					if (window.currentSolutionName === PFS_COMPONENT_NAMES.solution && text && (text.toLowerCase() === "overview" || text.toLowerCase().includes("stage"))) {
						Utils.hideSubmitSolutionFromOverviewTab();
					}
				},
				false
			);
			//EDGE-198536 End: existing code moved inside active solution check
			//Getting the baket Id
			//Changes as part of EDGE-155255 end
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", false);
			} //RF for lock issue
			//console.log('Basket ID--------' + basketId);
			let inputMap = {};
			inputMap["GetBasket"] = basketId;
			Utils.updateCustomButtonVisibilityForBasketStage();

			//currentBasket = (currentBasket == null ? await CS.SM.getActiveBasket() : currentBasket);
			//await CommonUtills.getBasketData(currentBasket);

			await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
				//EDGE-155255// added async
				//console.log('GetBasket finished with response: ', result);
				var basket = JSON.parse(result["GetBasket"]);
				//console.log('GetBasket: ', basket);
				//updated part of EDGE-162597
				var solutionconfig = basket.cscfga__Product_Configurations__r;
				if (solutionconfig) {
					var solutions = solutionconfig.records;
					if (solutions) {
						var Solumap = [];
						solutions.forEach((comp) => {
							var el = {};
							var offer = comp.Marketable_Offer__r;
							if (offer) {
								console.log("Marketable_Offer " + offer.Offer_ID__c);
								el.OfferId = offer.Offer_ID__c;
								Solumap.push(el);
							}
						});
					}
				}

				//var basketChangeType = basket.csordtelcoa__Change_Type__c;//RF-- unused
				var basketStage = basket.csordtelcoa__Basket_Stage__c;
				let accountId_ps = basket.csbb__Account__c;
				/*console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId);
				console.log('GetSiteId finished with response: ', result);*/
				communitySiteId = result["GetSiteId"];
				//console.log('communitySiteId: ', communitySiteId);
				window.oeSetBasketData(basketId, basketStage, accountId_ps);
				window.oeSetBasketsolutions(Solumap);
				//console.log('basketStage: ', basketStage);
				//Added by Aditya edge-148455 start
				if (accountId_ps != null) {
					CommonUtills.setAccountID(PFS_COMPONENT_NAMES.solution, accountId_ps);
				}
				//Added by Aditya edge-148455 end
				//await addDefaultPSOEConfigs(); //RF--
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_TCPS); //calling from addDefaultPSOEConfigs()
			});

			Utils.loadSMOptions();
			//AB rename customAttribute link text
			/*if (window.currentSolutionName === PFS_COMPONENT_NAMES.solution) {
				//again update link text value as UI is refreshed after save
				Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');//check
				Utils.updateCustomAttributeLinkText('Tenancy', 'View and Edit');
			}*/
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
			return Promise.resolve(true);
		}
	});

	PFSPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
		//Below method no longer availble in RF_OELogic, which is causing issue while deleting configurations removed part of INC000094834323
		//window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	}

	PFSPlugin.afterAttributeUpdated = async function solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {
		//EDGE-155255 //Remove _
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-155255
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue
		if (component.name === PFS_COMPONENT_NAMES.telstraColPFS && (attribute.name === "Type" || attribute.name === "Quantity" || attribute.name === "OC")) {
			//EDGE-155255- added component.name
			await setSpecIdBasedOnType(configuration.guid); //EDGE-155255
			//await EDMListToDecomposePFS(); RF
			//console.log(' i changed the value of Type ---- oldValue--' + oldValueMap['value'] + 'newvalue -----' + attribute.value);//EDGE-155255
		}
		//REVIEW RF++ //put basket stage
		if (
			basketStage === "Contract Accepted" &&
			(component.name === "Telstra Collaboration Tenancy details" || component.name === "Operations User" || component.name === "Subscription") &&
			(attribute.name === "Technical Contact" || attribute.name === "PurchaseOrder" || attribute.name === "TenancyID" || attribute.name === "Operational User" || attribute.name === "Network")
		) {
			//EDGE-155255
			//if (attribute.name === 'Technical Contact' || attribute.name === 'PurchaseOrder' || attribute.name === 'TenancyID') {
			await updateAttributeOnPS(configuration.parentConfiguration, attribute.value, attribute.name); //EDGE-155255
			//}
		} //added basket stage filter Pooja

		if (component.name === PFS_COMPONENT_NAMES.solution && attribute.name === "OfferName") {
			//RF++
			await CommonUtills.genericUpdateSolutionName(component, configuration, attribute.displayValue, attribute.displayValue); //RF++
		}

		//REVIEW RF--
		/*if (component.name === 'Operations User' && attribute.name === 'Operational User') {//EDGE-155255
			console.log('Operations User' + attribute);
			await updateAttributeOnPS(configuration.guid, attribute.value, attribute.name);//EDGE-155255
		}
	
		if (component.name === 'Subscription' && attribute.name === 'Network') {//EDGE-155255
			console.log('Network' + attribute);
			await updateAttributeOnPS(configuration.guid, attribute.value, attribute.name);//EDGE-155255
		}*/


		//EDGE-186075 Professional Service Billing requirements-Customer Reference Number  
		if (RELATED_PC_ATTRIBUTES_TO_CATPTURE.includes(attribute.name)) {
			let updateMap = {};
			if (currentSolution && currentSolution.name.includes(PFS_COMPONENT_NAMES.solution)) {
				let comp = currentSolution.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
				if (comp) {
					let cmpConfig = await comp.getConfigurations();
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const telstraColPFSConfig of Object.values(cmpConfig)) {
							if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {
								Object.values(telstraColPFSConfig.relatedProductList).forEach((relatedConfig) => {
									updateMap[relatedConfig.guid] = [];
									updateMap[relatedConfig.guid].push({
										name: attribute.name,
										value: attribute.value,
										displayValue: attribute.value,
										readOnly: true,
										required: false
									});
								});
							}
						}
					}
				}
			}

			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					console.log(keys[i]);
					await currentSolution.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		//End: EDGE-186075 Professional Service Billing requirements-Customer Reference Number


		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value); //EDGE-155255
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
		return Promise.resolve(true);
	}

	//This is not doing anything
	/*PFSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {//EDGE-155255
		console.log('afterConfigurationAdd', component, configuration);
		if (component.name === PFS_COMPONENT_NAMES.telstraColPFS) {//EDGE-155255- added component.name
		}
		return Promise.resolve(true);
	}*/

	//Aditya: Spring Update for changing basket stage to Draft
	PFSPlugin.afterSolutionDelete = function (solution) {
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	}

	//Changes as part of EDGE-155255 start
	window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-155255
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue
		if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {
			let schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid); //RF
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
			//Changes as part of EDGE-155255 end
		}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
		return Promise.resolve(true);
	})
}

/****************************************************************************
 * Author	   : Raviteja
 * Method Name : updateAttributeOnPS
 * Invoked When: Order  OE is updated
 * Description : to update attribute value
 * Parameters  : 1. String : configuration guid
 *               2. String : new value of the attribute
 ***************************************************************************/

async function updateAttributeOnPS(guid, attrValue, attributeName) {
	//check this attributeType to attributeName
	//Changes as part of EDGE-155255 start
	let product = await CS.SM.getActiveSolution(); //EDGE-155255
	//let component = await product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);//EDGE-155255
	//console.log('updateOrderTechinicalContactOnPS', product); //RF--
	//console.log('prod Name', product.name);//RF--
	//if (product && product.name.includes(PFS_COMPONENT_NAMES.solution) && (product.components && Object.values(product.components).length > 0)) {//changed product.type to product-//EDGE-155255//Merged in one if- RF
	//if (product.components && Object.values(product.components).length > 0) {//EDGE-155255 //RF--
	//for (const comp of Object.values(product.components)) {  //EDGE-155255 //RF--
	//console.log('@@comp.name', comp.name); //RF--
	//if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) { //RF--
	//console.log('UC while updating OPE on OE', comp); //RF--

	//let comp = await product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);//RF++
	//if (comp) {//RF++
	//let cmpConfig = await product.getConfiguration(guid);//RF++
	//if (comp.schema && cmpConfig && Object.values(cmpConfig).length > 0) {//RF++
	//let psConfigGUID;//RF var to let
	//if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255  //RF--
	//Object.values(comp.schema.configurations).forEach((psConfig) => {//EDGE-155255  //RF--
	//for (const psConfig of Object.values(cmpConfig)) {//RF++
	//let opeConfig = comp.getOrderEnrichmentConfigurationList([guid]);
	//if (opeConfig) {//EDGE-155255
	// (psConfig.orderEnrichmentList && Object.values(psConfig.orderEnrichmentList).length > 0) {//EDGE-155255
	/*let opeConfig = Object.values(psConfig.orderEnrichmentList).filter(config => {//EDGE-155255 //RF var to let and filter to find
		return config.guid === guid
	});*/
	//if (opeConfig && opeConfig[0]) {
	//psConfigGUID = psConfig.guid;
	//}
	//}
	//});
	//}
	//console.log('psConfigGUID', psConfigGUID);
	if (guid) {
		//console.log('Inside', psConfigGUID);
		//Changes as part of EDGE-155255 start
		let updateMap = {};
		updateMap[guid] = [];
		updateMap[guid].push({
			name: attributeName, //check this attributeType to attributeName
			value: attrValue,
			displayValue: attrValue,
			readOnly: true,
			required: false
		});

		if (updateMap && Object.keys(updateMap).length > 0) {
			//keys = Object.keys(updateMap);
			//for (let i = 0; i < keys.length; i++) {
			//component.lock('Commercial', false);
			//var complock = product.commercialLock;//RF++
			//comp.lock('Commercial', false);//RF component to comp
			//await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);//RF component to comp
			await product.updateConfigurationAttribute(guid, updateMap[guid], true); //RF component to comp
			//}
		}
		//console.log('updateMap', updateMap);
		//Changes as part of EDGE-155255 end
	}
	return Promise.resolve(true);
} //Commeted by Pooja__RF
//}
//}
//}
//}
//
//}

/*async function saveSolutionPFS() {
	let currentBasket = await CS.SM.getActiveBasket();//EDGE-155255
	if (executeSavePFS) {
		executeSavePFS = false;
		//var solution; RF
		savePFS = true;
		await currentBasket.saveSolution();//EDGE-155255
		return Promise.resolve(true);
	}
	console.log('I am inside Save Solution');
}*/ async function setSpecIdBasedOnType(guid) {
	//Changes as part of EDGE-155255 start
	let product = await CS.SM.getActiveSolution();
	//Changes as part of EDGE-155255 end
	if (product && product.name.includes(PFS_COMPONENT_NAMES.solution) && product.components && Object.values(product.components).length > 0) {
		//changed product.type  to product-//EDGE-155255
		//var statusMsg; RF
		//if (product.components && Object.values(product.components).length > 0) {//EDGE-155255//Merged in one if- RF--
		//for (const comp of Object.values(product.components)) {//EDGE-155255 //RF--
		//if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) { //RF--
		let comp = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
		if (comp) {
			//RF++
			let cmpConfig = await comp.getConfigurations(); //RF++
			if (comp.schema && cmpConfig && Object.values(cmpConfig).length > 0) {
				//RF++
				for (const telstraColPFSConfig of Object.values(cmpConfig)) {
					//RF++
					//console.log('IP Site while updating Handset Model', comp);
					//if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255 //RF--
					//for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) {//EDGE-155255 //RF--
					//var currtelstraColPFSConfigGUID; //RF-- not used
					var currType = "";
					var currspecId;
					//var updateMap = []; RF--
					var numberOfHours;
					var unitPrice;
					var totalCharge;
					var currOperHrs = "";
					//console.log('IP Site Config while updating Handset Model*** ', telstraColPFSConfig);
					if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {
						//EDGE-155255
						for (const relatedConfig of Object.values(telstraColPFSConfig.relatedProductList)) {
							//EDGE-155255
							if (relatedConfig.name === PFS_COMPONENT_NAMES.pfsRelatedComponent && relatedConfig.type === "Related Component" && relatedConfig.guid === guid) {
								//currtelstraColPFSConfigGUID = telstraColPFSConfig.guid; RF-- not used
								Object.values(relatedConfig.configuration.attributes).forEach((typeAttribute) => {
									//EDGE-155255
									if (typeAttribute.name === "Type") {
										currType = typeAttribute.value;
										//check if the type which is selected is already existing in other Types..
										/*if (typeAttribute.value === 'Config') {
											currSpecId = 'DMCAT_NonRecurringCharge_000930'
										}
										if (typeAttribute.value === 'Site Visit') {
											currSpecId = 'DMCAT_NonRecurringCharge_000934'
										}
										if (typeAttribute.value === 'Project Management') {
											currSpecId = 'DMCAT_NonRecurringCharge_000931'
										}
										if (typeAttribute.value === 'Training') {
											currSpecId = 'DMCAT_NonRecurringCharge_000932'
										}
										if (typeAttribute.value === 'Design') {
											currSpecId = 'DMCAT_NonRecurringCharge_000933'
										}
										if (typeAttribute.value === 'Install') {
											currSpecId = 'DMCAT_NonRecurringCharge_000929'
										}*/

										//REVIEW replaced with switch
										switch (currType) {
											case "Config":
												currSpecId = "DMCAT_NonRecurringCharge_000930";
												break;
											case "Site Visit":
												currSpecId = "DMCAT_NonRecurringCharge_000934";
												break;
											case "Project Management":
												currSpecId = "DMCAT_NonRecurringCharge_000931";
												break;
											case "Training":
												currSpecId = "DMCAT_NonRecurringCharge_000932";
												break;
											case "Design":
												currSpecId = "DMCAT_NonRecurringCharge_000933";
												break;
											case "Install":
												currSpecId = "DMCAT_NonRecurringCharge_000929";
												break;
											default:
										}
									}
									//console.log('Attribute Name ', typeAttribute.name);

									if (typeAttribute.name === "Quantity") {
										numberOfHours = typeAttribute.value;
									}
									if (typeAttribute.name === "OC") {
										unitPrice = typeAttribute.value;
									}
									if (typeAttribute.name === "OperationalHours") currOperHrs = typeAttribute.displayValue;

									/*console.log('setSpecIdBasedOnType Openhrs_value123 ', currOperHrs);
									console.log('setSpecIdBasedOnType type_value123 ', currType);*/ //RF--
								});
								await checkIfTypeExists(relatedConfig.guid, currType, currOperHrs); //[Brahm][Edge-113349/123281]//Pooja
								/*Put here*/
								totalCharge = numberOfHours * unitPrice; //RF-- //let component = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS); //RF--
								/*console.log('currtelstraColPFSConfigGUID ', currtelstraColPFSConfigGUID);
								console.log('currType ', currType);
								console.log('currSpecId ', currSpecId);
								console.log('number of hours ', numberOfHours);
								console.log('unitPrice ', unitPrice);
								console.log('totalCharge ', totalCharge);*/ let updateMap = {};
								updateMap[relatedConfig.guid] = [];
								updateMap[relatedConfig.guid].push(
									{
										name: "specId",
										value: currSpecId,
										displayValue: currSpecId,
										readOnly: true,
										required: false
									},
									{
										name: "TC",
										value: totalCharge,
										displayValue: totalCharge,
										readOnly: true,
										required: false
									}
								);

								if (updateMap && Object.keys(updateMap).length > 0) {
									//keys = Object.keys(updateMap);
									//for (let i = 0; i < keys.length; i++) {
									//await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);// RF--
									await comp.updateConfigurationAttribute(relatedConfig.guid, updateMap[relatedConfig.guid], true); //RF++
									//}
								}
							}
							//Changes as part of EDGE-155255 end
						}
					}
				}
			}
		}
		//}
		//}
	}
	return Promise.resolve(true); //Pooja
}

//will be  calling it from OELOGIC---RF
async function addDefaultPSOEConfigs() {
	if (basketStage !== "Contract Accepted") {
		return;
	}
	//console.log('addDefaultOEConfigs');
	let oeMap = []; //RF var to let
	//Changes as part of EDGE-155255 start
	let currentSolution = await CS.SM.getActiveSolution();
	//Changes as part of EDGE-155255 end
	//console.log('addDefaultOEConfigs ', currentSolution.name, PFS_COMPONENT_NAMES.solution);
	if (currentSolution && currentSolution.name.includes(PFS_COMPONENT_NAMES.solution) && currentSolution.components && Object.values(currentSolution.components).length > 0) {
		//changed currentSolution.type to currentSolution- EDGE-155255
		//console.log('addDefaultOEConfigs - looking components', currentSolution);
		//if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-155255//Merged in one if- RF
		Object.values(currentSolution.components).forEach(async (comp) => {
			//EDGE-155255
			//let cmpConfig = await comp.getConfigurations();//RF++
			//Object.values(cmpConfig).forEach((config) => {//EDGE-155255
			Object.values(comp.schema.configurations).forEach((config) => {
				//EDGE-155255
				Object.values(comp.orderEnrichments).forEach((oeSchema) => {
					//EDGE-155255
					let found = false; //RF var to let
					if (config.orderEnrichmentList) {
						let oeConfig = Object.values(config.orderEnrichmentList).filter((oe) => {
							return oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId;
						}); //EDGE-155255 //RF var to let
						if (oeConfig && oeConfig.length > 0) found = true;
					}
					if (!found) {
						let el = {}; //RF var to let
						el.componentName = comp.name;
						el.configGuid = config.guid;
						el.oeSchema = oeSchema; //EDGE-155255
						oeMap.push(el);
						//console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
					}
				});
			});
		});
		//}
	}
	if (oeMap.length > 0) {
		//console.log('Adding default oe config map--:', oeMap);
		for (let i = 0; i < oeMap.length; i++) {
			//RF var to let
			//console.log(' Component name ----' + oeMap[i].componentName);
			let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
			let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
			await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
		}
	}
	//Changes as part of EDGE-155255 end
	await initializePSOEConfigs();
	return Promise.resolve(true);
}

//will be  calling it from OELOGIC---RF
async function initializePSOEConfigs() {
	//console.log('initializeOEConfigs');
	let currentSolution = await CS.SM.getActiveSolution();
	//let currentComponent = currentSolution.getComponentByName(PFS_COMPONENT_NAMES.solution); RF--
	//Changes as part of EDGE-155255 end

	//if (currentSolution) {//Duplicate check- RF
	//console.log('initializeUCOEConfigs - updating');
	if (currentSolution && currentSolution.name.includes(PFS_COMPONENT_NAMES.solution) && currentSolution.components && Object.values(currentSolution.components).length > 0) {
		//changed currentSolution.type to currentSolution- EDGE-155255
		//if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-155255//Merged in one if- RF
		for (let i = 0; i < Object.values(currentSolution.components).length; i++) {
			//EDGE-155255 //RF var to let
			let comp = Object.values(currentSolution.components)[i]; //EDGE-155255 //RF var to let
			let cmpConfig = await comp.getConfigurations(); //RF++
			for (let j = 0; j < Object.values(cmpConfig).length; j++) {
				//EDGE-155255 //RF var to let  //RF++
				let config = Object.values(cmpConfig)[j]; //EDGE-155255 //RF var to let //RF++
				//for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {//EDGE-155255 //RF var to let
				//let config = Object.values(comp.schema.configurations)[j];//EDGE-155255 //RF var to let
				let updateMap = {}; //RF var to let
				if (config.orderEnrichmentList) {
					for (let k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {
						//EDGE-155255 //RF var to let
						let oe = Object.values(config.orderEnrichmentList)[k]; //EDGE-155255 //RF var to let
						let basketAttribute = Object.values(oe.attributes).filter((a) => {
							//EDGE-155255 //RF var to let
							return a.name.toLowerCase() === "basketid";
						});
						//console.log('oe.attributes: ' + oe.attributes);
						if (basketAttribute && basketAttribute.length > 0 && !updateMap[oe.guid]) {
							//if (!updateMap[oe.guid])//Merged in one if- RF
							updateMap[oe.guid] = [];
							updateMap[oe.guid].push({ name: basketAttribute[0].name, value: basketId });
						}
						updateMap[oe.guid].push({ name: "OfferName", value: PFS_COMPONENT_NAMES.OfferName });
					}
				}

				//Changes as part of EDGE-155255 start
				if (updateMap && Object.keys(updateMap).length > 0) {
					let keys = Object.keys(updateMap);
					//console.log('initializePSOEConfigs keys:', keys);
					for (let h = 0; h < Object.keys(updateMap).length; h++) {
						//RF var to let
						await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false); //check this
					}
					//console.log('initializeOEConfigs updateMap:', updateMap);
				}
				//Changes as part of EDGE-155255 end
			}
		}
		//}
	}
	//}
	return Promise.resolve(true);
}

/**
 * Author      : Laxmi Rahate 2019-11-08
 * Description : Method to check if the type value is already selected in other related Configurations, if thats selected thsi method throws an errror
 * Modified : [Brahm][[Edge-113349/123281][2019-11-22]
 */

async function checkIfTypeExists(guid, currType, currOperHrs) {
	//Changes as part of EDGE-155255 start
	let product = await CS.SM.getActiveSolution();
	//let Component = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS); RF--
	let currentComponent = product.getComponentByName(PFS_COMPONENT_NAMES.solution);
	//Changes as part of EDGE-155255 end
	if (product && product.name.includes(PFS_COMPONENT_NAMES.solution) && product.components && Object.values(product.components).length > 0) {
		//changed product.type to product- EDGE-155255
		//if (product.components && Object.values(product.components).length > 0) {//EDGE-155255 //Merged in one if-RF
		//for (const comp of Object.values(product.components)) {//EDGE-155255  //RF--
		//if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {//RF--
		let comp = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
		if (comp) {
			//RF++
			let cmpConfig = await comp.getConfigurations(); //RF++
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				//RF++
				for (const telstraColPFSConfig of Object.values(cmpConfig)) {
					//RF++
					//if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255  //RF--
					//for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) { //EDGE-155255  //RF--
					if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {
						//EDGE-155255
						let ErrorType = ""; //RF var to let/assigned
						let ErrorQty = ""; //RF var to let/assigned
						let updateMap = {}; //EDGE-155255
						let OperHrsVal = ""; //RF var to let/assigned
						let typeValue = ""; //RF var to let/assigned
						Object.values(telstraColPFSConfig.relatedProductList).forEach((relatedConfig) => {
							//EDGE-155255
							//OperHrsVal = '';//RF--
							//typeValue = '';//RF--
							//console.log('checkIfTypeExists currType =' + currType);

							Object.values(relatedConfig.configuration.attributes).forEach((attribute) => {
								//EDGE-155255
								if (guid != relatedConfig.guid) {
									if (attribute.name === "Type") typeValue = attribute.value;

									if (attribute.name === "OperationalHours")
										//[Brahm][Edge-113349/123281][start]
										OperHrsVal = attribute.displayValue;

									if (typeValue === currType && currOperHrs === OperHrsVal && typeValue != "" && currType != "" && currOperHrs != "" && OperHrsVal != "") {
										//console.log('Error ------- You can not select same Type and Operation Hours combination.');
										//Changes as part of EDGE-155255 start
										updateMap[guid] = [];
										updateMap[guid].push(
											{
												name: "Type",
												value: "",
												displayValue: "",
												readOnly: false,
												required: true
											},
											{
												name: "OperationalHours",
												value: "",
												displayValue: "",
												readOnly: false,
												required: true
											}
										);
										//Changes as part of EDGE-155255 end
										ErrorType = true;
									}
								}
								if (attribute.name === "Quantity") {
									quantVal = attribute.value;
									/*console.log('attribute:' + quantVal.indexOf("."));
									console.log('attribute:' + attribute.name);*/
									if (quantVal.indexOf(".") > -1) {
										q = quantVal.split(".");
										if (q[1].length > 2) {
											updateMap[relatedConfig.guid] = [];
											updateMap[relatedConfig.guid].push({
												name: "Quantity",
												value: "",
												displayValue: "",
												readOnly: false,
												required: true
											});
											//Changes as part of EDGE-155255 end
											//console.log('Error ------- You can not exceed the decimal limit more than two.');
											ErrorQty = true;
										}
									}
								}
							});
						});
						if (ErrorType === true) {
							//console.log('checkIfTypeExists_ 111135 =');
							//Changes as part of EDGE-155255 start
							if (updateMap && Object.keys(updateMap).length > 0) {
								//keys = Object.keys(updateMap);
								//for (let i = 0; i < keys.length; i++) {
								//await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);//RF
								await comp.updateConfigurationAttribute(relatedConfig.guid, updateMap[relatedConfig.guid], true); //RF++
								//}
							}

							let config = await currentComponent.getConfiguration(guid);
							config.status = false;
							config.statusMessage = "Selected Type and Operational Hours combination are already selected, please select different combination!";
							//Changes as part of EDGE-155255 end
						} else if (ErrorQty === true) {
							//console.log('checkIfTypeExists_ 111136 =');
							//Changes as part of EDGE-155255 start
							if (updateMap && Object.keys(updateMap).length > 0) {
								//keys = Object.keys(updateMap);
								//for (let i = 0; i < keys.length; i++) {
								//await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);//RF
								await comp.updateConfigurationAttribute(relatedConfig.guid, updateMap[relatedConfig.guid], true); //RF++
								//}
							}

							let config = await currentComponent.getConfiguration(guid);
							config.status = false;
							config.statusMessage = "Numbers of hours " + quantVal + " can not exceed the decimal limit more than two!";
							//Changes as part of EDGE-155255 end
						} else {
							//console.log('checkIfTypeExists_ 111137 =');
							//Changes as part of EDGE-155255 start
							let config = await currentComponent.getConfiguration(guid);
							config.status = true;
							//Changes as part of EDGE-155255 end
						} //[Brahm][Edge-113349/123281][End]
					}
				}
			}
		}
		//}
		//}
	}
	return Promise.resolve(true);
}

/*****************************************
 * Author      : Brahm  2019-11-12
 * Description : Method to update the EDMListToDecompose for the professional service based on its type selected on the Telstra Collab Prof Serv Features
 [Brahm][[Edge-113349]
 *****************************************/
/*async function EDMListToDecomposePFS() {//will be moved to PD rules
	//Changes as part of EDGE-155255 start
	let solution = await CS.SM.getActiveSolution();//Declare it globally //RF--
	//let Component = solution.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
	//Changes as part of EDGE-155255 end
	if (solution && solution.name.includes(PFS_COMPONENT_NAMES.solution) && (solution.components && Object.values(solution.components).length > 0)) {//changes from solution.type to solution- EDGE-155255
		//if (solution.components && Object.values(solution.components).length > 0) {//EDGE-155255 //merged in one if-RF
		let UpdEDMListToDecomMap = {};//EDGE-155255
		//for (const comp of Object.values(solution.components)) { //EDGE-155255 //RF--
		//if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {//RF--
		let comp = solution.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);//RF++
		if (comp) {//RF++
			let cmpConfig = await comp.getConfigurations();//RF++
			if (cmpConfig && Object.values(cmpConfig).length > 0) {//RF++
				for (const telstraColPFSConfig of Object.values(cmpConfig)) {//RF++
					//if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255 //RF--
					//console.log('EDMListToDecomposePFS entering schema=' + comp.schema);
					//console.log('EDMListToDecomposePFS entering config=' + comp.schema.configurations); //RF--
					//for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) { //EDGE-155255
					if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {//EDGE-155255
						//console.log('EDMListToDecomposePFS entering relateProd=' + telstraColPFSConfig.relatedProductList);
						for (const relatedConfig of Object.values(telstraColPFSConfig.relatedProductList)) {//EDGE-155255
							let guid = '';//RF var to let/assigned
							let EDMVal = '';//RF var to let/assigned
							let typeVal = '';//RF var to let/assigned
							Object.values(relatedConfig.configuration.attributes).forEach((attribute) => {//EDGE-155255
								if (attribute.name === 'Type') {
									typeVal = attribute.value;
									guid = relatedConfig.guid;
									console.log('EDMListToDecomposePFS typeValue =' + typeVal);

									if (typeVal === 'Config')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000929';
									if (typeVal === 'Site Visit')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000930';
									if (typeVal === 'Project Management')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000931';
									if (typeVal === 'Training')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000932';
									if (typeVal === 'Design')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000933';
									if (typeVal === 'Install')
										EDMVal = 'Telstra Collab Prof Serv Features_Billing_NonRecurringCharge_000934';

									//console.log('EDMval:' + EDMVal);
									UpdEDMListToDecomMap[guid] = [];
									UpdEDMListToDecomMap[guid].push({
										name: "EDMListToDecompose",
										value: EDMVal,
										displayValue: EDMVal
									});
									//console.log('EDMList - Related ConfigGUID' + guid);
								}

							});
							if (UpdEDMListToDecomMap && Object.keys(UpdEDMListToDecomMap).length > 0) {
								//keys = Object.keys(UpdEDMListToDecomMap);
								//for (let i = 0; i < keys.length; i++) {
								//await Component.updateConfigurationAttribute(keys[i], UpdEDMListToDecomMap[keys[i]], true);
								await comp.updateConfigurationAttribute(guid, UpdEDMListToDecomMap[guid], true);//RF++
								//}
							}
							//Changes as part of EDGE-155255 end
						}
						//console.log('EDMListToDecomposePFS UpdEDMListToDecomMap =' + UpdEDMListToDecomMap);
					}
				}
			}
		}
		//}
		//}
	}
	return Promise.resolve(true);
}*/

/*
	Added as part of EDGE-149887
	This method updates the Solution Name based on Offer Name if User didnt provide any input
	Modifications :
	1. Gnana - EDGE-164917 : Changed logic to get Display Value for OfferName instead of Value which was giving Id
*/
/*async function updateSolutionName_TCPS() {
	let listOfAttributes = ['Solution Name', 'GUID'], attrValuesMap = {};//var to let -RF
	let listOfAttrToGetDispValues = ['OfferName'], attrValuesMap2 = {};//var to let -RF
	let configGuid = '';//EDGE-155255 //RF assigned
	let solution = await CS.SM.getActiveSolution();//EDGE-155255
	let Component = solution.getComponentByName(PFS_COMPONENT_NAMES.solution);//EDGE-155255
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, PFS_COMPONENT_NAMES.solution);
	attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, PFS_COMPONENT_NAMES.solution);
	//console.log('attrValuesMap...' + attrValuesMap);
	if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_TCPS) {
		let updateConfigMap = {};
		configGuid = attrValuesMap['GUID'];
		updateConfigMap[configGuid] = [];
		updateConfigMap[configGuid].push({
			name: "Solution Name",
			value: attrValuesMap2['OfferName'],
			displayValue: attrValuesMap2['OfferName']
		});
		//if (updateConfigMap) {//RF--
		if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
			//keys = Object.keys(updateConfigMap);
			//for (let i = 0; i < keys.length; i++) {
			Component.lock('Commercial', false);
			//await Component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			await Component.updateConfigurationAttribute(configGuid, updateConfigMap[configGuid], true);
			//}
		}
		//Changes as part of EDGE-155255 end
		//}
	}
	return Promise.resolve(true);
}*/