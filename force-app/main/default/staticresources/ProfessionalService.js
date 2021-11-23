/******************************************************************************************
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
*******************/
var executeSavePFS = false;
var savePFS = false;
var PFS_COMPONENT_NAMES = {
	solution: 'Telstra Collaboration Professional Services',// 'Professional Services',    
	telstraColPFS: 'Telstra Collaboration  Professional Services',
	telstraColProfServFeatures: 'Telstra Collab Prof Serv Features',
	pfsRelatedComponent: 'Professional Service Features',
	OfferName: 'Telstra Collaboration Professional Services'
};

var basketStage = null;
var crdoeschemaid = null;
var show = false;
var communitySiteId;

var DEFAULTSOLUTIONNAME_TCPS = 'Telstra Collaboration Professional Services';  // Added as part of EDGE-149887

// Added Register Plugin- EDGE-155255
if (CS.SM.registerPlugin) {
	console.log('Load PFPS plugin');
	window.document.addEventListener('SolutionConsoleReady', async function () {
		console.log('SolutionConsoleReady');
		await CS.SM.registerPlugin('Telstra Collaboration Professional Services')
			.then(async PFSPlugin => {
				// For Hooks
				PFSPlugin_updatePlugin(PFSPlugin);
			});
	});
}

//Changes as part of EDGE-155255 start
//if (CS.SM.createPlugin){
//console.log('Loading Professional Service plugin');
//PFSPlugin = CS.SM.createPlugin(PFS_COMPONENT_NAMES.solution);
async function PFSPlugin_updatePlugin(PFSPlugin) {// Added as part of EDGE-155255
	//Changes as part of EDGE-155255 end
	console.log('Adding Hooks to PFSPlugin');
	Utils.updateCustomButtonVisibilityForBasketStage();//EDGE-155255
	document.addEventListener('click', function (e) {
		e = e || window.event;
		var target = e.target || e.srcElement;
		var text = target.textContent || target.innerText;
		//EDGE-135267 Aakil
		if (window.currentSolutionName === PFS_COMPONENT_NAMES.solution && text && (text.toLowerCase() === 'overview' || text.toLowerCase().includes('stage'))) {
			Utils.hideSubmitSolutionFromOverviewTab();
		}
		//
	}, false);

	//Changes as part of EDGE-155255 start
	//PFSPlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
	PFSPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('afterSave', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
		//Changes as part of EDGE-155255 end

		console.log('afterSave - entering');
		Utils.updateCustomButtonVisibilityForBasketStage();
		//EDMListToDecomposePFS();
		//EDGE-135267
		Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals();//Added as part of EDGE-155255
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		return Promise.resolve(true);
	}

	//Changes as part of EDGE-155255 start
	//PFSPlugin.beforeSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){ 
	PFSPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		await updateSolutionName_TCPS(); // Added as part of EDGE-149887// added await
		let currentComponent = solution.getComponentByName(PFS_COMPONENT_NAMES.solution);
		console.log('beforeSave');
		//Changes as part of EDGE-155255 end

		//EDGE-133590  Conditional Subscription Selection 
		var skipsave = false;
		if (basketStage !== 'Contract Accepted') {
			return Promise.resolve(true);
		}
		var basketHasTC = false;
		if (solution.components && Object.values(solution.components).length > 0) {
			//solution.components.forEach((comp) => {//EDGE-155255
			for (const comp of Object.values(solution.components)) { //EDGE-155255
				if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						//comp.schema.configurations.forEach((subsConfig) => {//EDGE-155255
						for (const subsConfig of Object.values(comp.schema.configurations)) { //EDGE-155255
							//comp.schema.configurations.forEach((subsConfig) => {//EDGE-155255
							if (subsConfig.attributes && Object.values(subsConfig.attributes).length > 0) {//155255
								//subsConfig.attributes.forEach((att) => {//Pooja
								for (const att of Object.values(subsConfig.attributes)) {//EDGE-155255
									if (att.name === 'Network') {
										if (att.value == '') {
											var basketsol = window.basketsolutions;
											Object.values(basketsol).forEach((comp) => {//EDGE-155255
												if(comp.OfferId=='DMCAT_Offer_000618')  {
													basketHasTC = true;
													console.log('basketHasTC' + basketHasTC);
												}
											});

											if (!basketHasTC) {
												//Changes as part of EDGE-155255 start
												//CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false, 'Please select the subscription in order enrichment.');
												let confg = await currentComponent.getConfiguration(subsConfig.guid);
												console.log('config' + confg);
												confg.status = false;
												confg.statusMessage = 'Please select the subscription in order enrichment.';
												//Changes as part of EDGE-155255 end

												skipsave = true;
											}
										}
									}
								}//);

							}


						}//);
					}



				}
			}//);
		}


		if (skipsave == true) {
			return Promise.resolve(false);
		}
		return Promise.resolve(true);
	}
	//End-  EDGE-133590  Conditional Subscription Selection 

	//PFSPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {//EDGE-155255
	window.document.addEventListener('SolutionSetActive', async function (e) {//EDGE-155255
		let currentSolution = await CS.SM.getActiveSolution();//EDGE-155255
		if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {//EDGE-155255
			console.log('solution loaded!!!');
			let currentBasket;//EDGE-155255
			let loadedSolution;//EDGE-155255
			loadedSolution = await CS.SM.getActiveSolution()//EDGE-155255
			currentBasket = await CS.SM.getActiveBasket();//EDGE-155255
			basketId = currentBasket.basketId;//EDGE-155255
			window.currentSolutionName = loadedSolution.name;
			//Getting the baket Id

			//Changes as part of EDGE-155255 start
			/*await CS.SM.getCurrentCart().then(cart => {
				console.log('Basket: ', cart);
				basketId = cart.id;
		
			});*/
			//Changes as part of EDGE-155255 end

			console.log('Basket ID--------' + basketId);
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			Utils.updateCustomButtonVisibilityForBasketStage();


			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async result => {//EDGE-155255// added async 
				console.log('GetBasket finished with response: ', result);
				var basket = JSON.parse(result["GetBasket"]);
				console.log('GetBasket: ', basket);
				//updated part of EDGE-162597
				var solutionconfig= basket.cscfga__Product_Configurations__r;
				if(solutionconfig){ 
					var solutions=solutionconfig.records;           
					if(solutions){
					   var Solumap = [];
					   solutions.forEach((comp) => {
								   var el = {};
								var offer=comp.Marketable_Offer__r;
								if(offer){
								console.log('Marketable_Offer '+offer.Offer_ID__c);
											el.OfferId = offer.Offer_ID__c;										
											Solumap.push(el);
								}
							});
					   }
					}
			
				var basketChangeType = basket.csordtelcoa__Change_Type__c;
				var basketStage= basket.csordtelcoa__Basket_Stage__c;
				var accountId = basket.csbb__Account__c;
				console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId);
				console.log('GetSiteId finished with response: ', result);
				communitySiteId = result["GetSiteId"]
				console.log('communitySiteId: ', communitySiteId);
				window.oeSetBasketData(basketId, basketStage, accountId);
				window.oeSetBasketsolutions(Solumap);
				console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId);
				console.log('basketStage: ', basketStage);
				//Added by Aditya edge-148455 start
				if(accountId!=null){
					CommonUtills.setAccountID(PFS_COMPONENT_NAMES.solution,accountId);
				 }
				//Added by Aditya edge-148455 end
				addDefaultPSOEConfigs();
			});
	 
		// addDefaultEMSOEConfigs();
	   // populateRateCardinAttachmentEMS();
		//EMSPlugin.getConfiguredSiteIds();
		Utils.loadSMOptions();
		//AB rename customAttribute link text
		if (window.currentSolutionName === PFS_COMPONENT_NAMES.solution) {
			//again update link text value as UI is refreshed after save
			Utils.updateCustomAttributeLinkText('Rate Card','View Rate Card');
			Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');
		}
		//await EDMListToDecomposePFS();
		return Promise.resolve(true);
	}
});

	//PFSPlugin.afterOrderEnrichmentConfigurationAdd = async function (componentName, configuration, orderEnrichmentConfiguration) {
	/*PFSPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) {//Made it async
		console.log('UCE afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration)
		//EDGE-120711 : Start - added by Purushottam to Enable oe-product checkbox-wrapper 
		if (configuration["guid"]) {
			//window.afterOETabLoaded(configuration["guid"],"Professional Service Enrichment" ,"Telstra Collaboration Professional Services" , '');
			//window.afterOETabLoaded(configuration["guid"], componentName, configuration["name"], '');//Commented by Pooja
			//Changes as part of EDGE-155255 end
			window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
				let currentSolution = await CS.SM.getActiveSolution();//EDGE-155255
				if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {
					console.log('OrderEnrichmentTabLoaded', e);
					//console.log('afterOETabLoaded: ', configurationGuid, OETabName);
					//var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
					var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
					window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
				}
				return Promise.resolve(true);
			});
		}
		//Changes as part of EDGE-155255 end
		//EDGE-120711 : End
		await initializePSOEConfigs();//Pooja
		//window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);//Commented by Pooja
		window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};*/

	//PFSPlugin.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {//Commented by Pooja
	PFSPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
		window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};

	//PFSPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {//EDGE-155255
	PFSPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {//EDGE-155255
		//return Promise.resolve(true);
		console.log('Attribute Update - After - OE ---', component.name, configuration.guid, attribute.value, oldValueMap['value']);//EDGE-155255
		//console.log('Attribute Update - After - OE ---', component, guid, attribute, 'oldValue:', oldValue, 'newValue:', newValue);//EDGE-155255
		//setSpecIdBasedOnType();
		if (component.name === PFS_COMPONENT_NAMES.telstraColPFS && (attribute.name === 'Type' || attribute.name === 'Quantity' || attribute.name === 'OC')) {//EDGE-155255- added component.name
			//UpdTypeForPFS(configuration.guid);
			//setSpecIdBasedOnType(guid);
			await setSpecIdBasedOnType(configuration.guid);//EDGE-155255
			await EDMListToDecomposePFS();
			//setSpecIdBasedOnType.
			//console.log(' i changed the value of Type ---- oldValue--' + oldValue + 'newvalue -----' + newValue);//EDGE-155255
			console.log(' i changed the value of Type ---- oldValue--' + oldValueMap['value'] + 'newvalue -----' + attribute.value);//EDGE-155255
		}
		//if (componentName === 'Telstra Collaboration Professional Service Details') {//EDGE-155255
		if (component.name === 'Telstra Collaboration Tenancy details') {//EDGE-155255
			console.log('Telstra Collaboration Tenancy details:' + attribute);
			if (attribute.name === 'Technical Contact' || attribute.name === 'PurchaseOrder' || attribute.name === 'TenancyID') {
				//updateAttributeOnPS(guid, newValue, attribute.name);
				await updateAttributeOnPS(configuration.guid, attribute.value, attribute.name);//EDGE-155255
			}
		}

		if (component.name === 'Operations User' && attribute.name === 'Operational User') {//EDGE-155255
			console.log('Operations User' + attribute);
			//updateAttributeOnPS(guid, newValue, attribute.name);
			await updateAttributeOnPS(configuration.guid, attribute.value, attribute.name);//EDGE-155255
		}

		if (component.name === 'Subscription' && attribute.name === 'Network') {//EDGE-155255
			console.log('Network' + attribute);
			//updateAttributeOnPS(guid, newValue, attribute.name);
			await updateAttributeOnPS(configuration.guid, attribute.value, attribute.name);//EDGE-155255
		}


		//window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);//EDGE-155255
		window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);//EDGE-155255

		return Promise.resolve(true);
	}


	//PFSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {
	PFSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {//EDGE-155255
		//console.log('afterConfigurationAdd', componentName, configuration);
		console.log('afterConfigurationAdd', component, configuration);
		//PopulateSpecIdForPFS();
		//if (componentName === PFS_COMPONENT_NAMES.telstraColPFS) {//EDGE-155255
		if (component.name === PFS_COMPONENT_NAMES.telstraColPFS) {//EDGE-155255- added component.name
			//Pooja summer 20 changes ends here
			//UpdTypeForPFS(configuration.guid);
			//EMSPlugin.getConfiguredSiteIds();
			//await DOP_updateConfigurationsName();
		}
		//addDefaultEMSOEConfigs();
		return Promise.resolve(true);
	}

    //Aditya: Spring Update for changing basket stage to Draft
    PFSPlugin.afterSolutionDelete = function (solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }

	//Changes as part of EDGE-155255 start
	//PFSPlugin.afterOETabLoaded = async function (configurationGuid, OETabName) {
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		let currentSolution = await CS.SM.getActiveSolution();//EDGE-155255
		if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {
			console.log('OrderEnrichmentTabLoaded', e);
			//console.log('afterOETabLoaded: ', configurationGuid, OETabName);
			//var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			//Changes as part of EDGE-155255 end
		}
		return Promise.resolve(true);
	});

}



//Changes as part of EDGE-155255 start
//PFSPlugin.afterOETabLoaded = async function (configurationGuid, OETabName) {
/*window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
	let currentSolution = await CS.SM.getActiveSolution();//EDGE-155255
	if (currentSolution.name === PFS_COMPONENT_NAMES.solution) {
		console.log('OrderEnrichmentTabLoaded', e);
		//console.log('afterOETabLoaded: ', configurationGuid, OETabName);
		//var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
		var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
		window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
		//Changes as part of EDGE-155255 end
	}
	return Promise.resolve(true);
});*/



//}





/****************************************************************************
 * Author	   : Raviteja
 * Method Name : updateAttributeOnPS
 * Invoked When: Order  OE is updated
 * Description : to update attribute value
 * Parameters  : 1. String : configuration guid 
 *               2. String : new value of the attribute
 ***************************************************************************/

async function updateAttributeOnPS(guid, attrValue, attributeType) {
	console.log('updateOrderTechinicalContactOnPS', guid);
	console.log('@@attrValue', attrValue);

	//Changes as part of EDGE-155255 start
	//CS.SM.getActiveSolution().then((product) => {

	let product = await CS.SM.getActiveSolution();//EDGE-155255
	let component = await product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);//EDGE-155255
	console.log('updateOrderTechinicalContactOnPS', product);
	console.log('prod Name', product.name);
	if (product && product.name.includes(PFS_COMPONENT_NAMES.solution)) {//changed product.type to product-//EDGE-155255
		if (product.components && Object.values(product.components).length > 0) {//EDGE-155255
			//Object.values(product.components).forEach((comp) => {//EDGE-155255
			for (const comp of Object.values(product.components)) {  //EDGE-155255
				console.log('@@comp.name', comp.name);
				if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {
					console.log('UC while updating OPE on OE', comp);
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255
						var psConfigGUID;
						Object.values(comp.schema.configurations).forEach((psConfig) => {//EDGE-155255
							if (psConfig.orderEnrichmentList && Object.values(psConfig.orderEnrichmentList).length > 0) {//EDGE-155255
								var opeConfig = Object.values(psConfig.orderEnrichmentList).filter(config => {//EDGE-155255
									return config.guid === guid
								});
								if (opeConfig && opeConfig[0]) {
									psConfigGUID = psConfig.guid;
								}
							}
						});
						console.log('psConfigGUID', psConfigGUID);
						if (psConfigGUID) {
							console.log('Inside', psConfigGUID);
							//Changes as part of EDGE-155255 start

							/*var updateMap = [];
							updateMap[psConfigGUID] = [{
								name: attributeType,
								value: {
									value: attrValue,
									displayValue: attrValue,
									readOnly: true,
									required: false
								}
							}];*/

							let updateMap = {};
							updateMap[psConfigGUID] = [];
							updateMap[psConfigGUID].push({
								name: attributeType,
								value: attrValue,
								displayValue: attrValue,
								readOnly: true,
								required: false
							});


							if (updateMap && Object.keys(updateMap).length > 0) {
								keys = Object.keys(updateMap);
								
								var complock = component.commercialLock;
								if (complock)
									component.lock('Commercial', false);

								for (let i = 0; i < keys.length; i++) {
									
									await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
								}
								if (complock) {
									component.lock('Commercial', true);
								}

							}
							console.log('updateMap', updateMap);
							//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.telstraColPFS, updateMap, true).then(component => console.log('updateOrderTechinicalContactOnPSttribute Update', component));
							//Changes as part of EDGE-155255 end

						}
					}
				}
			}
		}
	}
	//}).//EDGE-155255
	//then(//EDGE-155255
	return Promise.resolve(true);
	//);//EDGE-155255
}



async function saveSolutionPFS() {
	let currentBasket = await CS.SM.getActiveBasket();//EDGE-155255
	if (executeSavePFS) {
		executeSavePFS = false;
		//var oeerrorcount = 0;
		var solution;
		savePFS = true;
		/*await CS.SM.saveSolution().then((product) => {//EDGE-155255
			solution = product;
		});*/
		await currentBasket.saveSolution();//EDGE-155255
		Promise.resolve(true);
		//await EDMListToDecomposePFS(/*solution*/); 
	}

	console.log('I am inside Save Solution');

}


async function setSpecIdBasedOnType(guid) {
	//Changes as part of EDGE-155255 start
	let product = await CS.SM.getActiveSolution();
	//CS.SM.getActiveSolution().then((product) => {
	//Changes as part of EDGE-155255 end

	if (product && product.name.includes(PFS_COMPONENT_NAMES.solution)) {//changed product.type  to product-//EDGE-155255
		var statusMsg;
		if (product.components && Object.values(product.components).length > 0) {//EDGE-155255
			//Object.values(product.components).forEach((comp) => {//EDGE-155255
			for (const comp of Object.values(product.components)) {//EDGE-155255
				if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {
					console.log('IP Site while updating Handset Model', comp);
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255
						//Object.values(comp.schema.configurations).forEach((telstraColPFSConfig) => {//EDGE-155255
						for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) {//EDGE-155255
							var currtelstraColPFSConfigGUID;
							var currType = '';
							var currspecId;
							var updateMap = [];
							var numberOfHours;
							var unitPrice;
							var totalCharge;
							var currOperHrs = '';
							console.log('IP Site Config while updating Handset Model*** ', telstraColPFSConfig);
							if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {//EDGE-155255
								//Object.values(telstraColPFSConfig.relatedProductList).forEach((relatedConfig) => {//EDGE-155255
								for (const relatedConfig of Object.values(telstraColPFSConfig.relatedProductList)) {//EDGE-155255
									if (relatedConfig.name === PFS_COMPONENT_NAMES.pfsRelatedComponent && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
										currtelstraColPFSConfigGUID = telstraColPFSConfig.guid;
										Object.values(relatedConfig.configuration.attributes).forEach((typeAttribute) => {//EDGE-155255
											if (typeAttribute.name === 'Type') {
												currType = typeAttribute.value;


												//check if the type which is selected is already existing in other Types..
												//checkIfTypeExists( relatedConfig.guid , currType);

												if (typeAttribute.value === 'Config') {
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
												}
											}
											console.log('Attribute Name ', typeAttribute.name);

											if (typeAttribute.name === 'Quantity') {
												numberOfHours = typeAttribute.value;
											}
											if (typeAttribute.name === 'OC') {
												unitPrice = typeAttribute.value;
											}
											if (typeAttribute.name === 'OperationalHours')
												currOperHrs = typeAttribute.displayValue;

											console.log('setSpecIdBasedOnType Openhrs_value123 ', currOperHrs);
											console.log('setSpecIdBasedOnType type_value123 ', currType);

										});
										//console.log('Attribute Name456 ', currOperHrs);
										//console.log('Attribute value456 ', currType);
										await checkIfTypeExists(relatedConfig.guid, currType, currOperHrs);//[Brahm][Edge-113349/123281]//Pooja


										/*Put here*/

										totalCharge = numberOfHours * unitPrice;
										console.log('currtelstraColPFSConfigGUID ', currtelstraColPFSConfigGUID);
										console.log('currType ', currType);
										console.log('currSpecId ', currSpecId);
										console.log('number of hours ', numberOfHours);
										console.log('unitPrice ', unitPrice);
										console.log('totalCharge ', totalCharge);

										//Changes as part of EDGE-155255 start
										/*updateMap[relatedConfig.guid] = [{
											name: "specId",
											value: {
												value: currSpecId,
												displayValue: currSpecId,
												readOnly: true,
												required: false
											}
										},
										{
											name: "TC",
											value: {
												value: totalCharge,
												displayValue: totalCharge,
												readOnly: true,
												required: false

											}
										}
										];*/



										let component = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
										let updateMap = {};
										updateMap[relatedConfig.guid] = [];
										updateMap[relatedConfig.guid].push({
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
											});

										if (updateMap && Object.keys(updateMap).length > 0) {
											keys = Object.keys(updateMap);

											for (let i = 0; i < keys.length; i++) {
												await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
											}
										}
										//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.telstraColPFS, updateMap, true).then(component => console.log('addMobileDeviceConfigurations Attribute update', component));
									}
									//Changes as part of EDGE-155255 end
								}
							}

						}
					}
				}
			}
		}
	}
	//});
	return Promise.resolve(true);//Pooja
}

async function addDefaultPSOEConfigs() {
	if (basketStage !== 'Contract Accepted') {
		return;
	}
	console.log('addDefaultOEConfigs');
	var oeMap = [];
	//Changes as part of EDGE-155255 start
	let currentSolution = await CS.SM.getActiveSolution();
	//await CS.SM.getActiveSolution().then((currentSolution) => {
	//Changes as part of EDGE-155255 end
	console.log('addDefaultOEConfigs ', currentSolution.name, PFS_COMPONENT_NAMES.solution);
	if (currentSolution && currentSolution.name.includes(PFS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution- EDGE-155255
		console.log('addDefaultOEConfigs - looking components', currentSolution);
		if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-155255
			Object.values(currentSolution.components).forEach((comp) => {//EDGE-155255
				Object.values(comp.schema.configurations).forEach((config) => {//EDGE-155255
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {//EDGE-155255
						var found = false;
						if (config.orderEnrichmentList) {
							var oeConfig = Object.values(config.orderEnrichmentList).filter(oe => { return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId) });//EDGE-155255
							if (oeConfig && oeConfig.length > 0)
								found = true;
						}
						if (!found) {
							var el = {};
							el.componentName = comp.name;
							el.configGuid = config.guid;
							//el.oeSchemaId = oeSchema.id;//EDGE-155255
							el.oeSchema = oeSchema;//EDGE-155255
							oeMap.push(el);
							console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
						}
					});
				});
			});
		}
	}
	//Changes as part of EDGE-155255 start
	//}).then(() => Promise.resolve(true));
	//console.log('addDefaultOEConfigs prepared');
	/*if (oeMap.length > 0) {
		var map = [];
		map.push({});
		console.log('Adding default oe config map:', oeMap);
		for (var i = 0; i < oeMap.length; i++) {
			await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
		};
	}*/

	if (oeMap.length > 0) {
		//let map = [];
		console.log('Adding default oe config map--:', oeMap);
		for (var i = 0; i < oeMap.length; i++) {
			console.log(' Component name ----' + oeMap[i].componentName);
			let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
			let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
			await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
		};
	}
	//Changes as part of EDGE-155255 end
	await initializePSOEConfigs();
	return Promise.resolve(true);
}

async function initializePSOEConfigs() {
	console.log('initializeOEConfigs');
	//var currentSolution;//EDGE-155255

	//Changes as part of EDGE-155255 start
	/*await CS.SM.getActiveSolution().then((solution) => {
		currentSolution = solution;
		console.log('initializeUCOEConfigs - getActiveSolution');
	}).then(() => Promise.resolve(true));*/
	let currentSolution = await CS.SM.getActiveSolution();
	let currentComponent = currentSolution.getComponentByName(PFS_COMPONENT_NAMES.solution);
	//Changes as part of EDGE-155255 end

	if (currentSolution) {
		console.log('initializeUCOEConfigs - updating');
		if (currentSolution && currentSolution.name.includes(PFS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution- EDGE-155255
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-155255
				for (var i = 0; i < Object.values(currentSolution.components).length; i++) {//EDGE-155255
					var comp = Object.values(currentSolution.components)[i];//EDGE-155255
					for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {//EDGE-155255
						var config = Object.values(comp.schema.configurations)[j];//EDGE-155255
						var updateMap = {};
						if (config.orderEnrichmentList) {
							for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {//EDGE-155255
								var oe = Object.values(config.orderEnrichmentList)[k];//EDGE-155255

								var basketAttribute = Object.values(oe.attributes).filter(a => {//EDGE-155255
									return a.name.toLowerCase() === 'basketid'
								});
								console.log('oe.attributes: ' + oe.attributes);
								if (basketAttribute && basketAttribute.length > 0) {
									if (!updateMap[oe.guid])
										updateMap[oe.guid] = [];
									updateMap[oe.guid].push({ name: basketAttribute[0].name, value: basketId });
								}
								updateMap[oe.guid].push({ name: 'OfferName', value: PFS_COMPONENT_NAMES.OfferName });
							}
						}

						//Changes as part of EDGE-155255 start
						/*if (updateMap && Object.keys(updateMap).length > 0) {
							console.log('initializeOEConfigs updateMap:', updateMap);
							CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
						}*/

						if (updateMap && Object.keys(updateMap).length > 0) {
							let keys = Object.keys(updateMap);
							console.log('initializePSOEConfigs keys:', keys);
							for (var h = 0; h < Object.keys(updateMap).length; h++) {
								await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false)
							}
							console.log('initializeOEConfigs updateMap:', updateMap);
						}
						//Changes as part of EDGE-155255 end
					};
				};
			}
		}
	}
	return Promise.resolve(true);
}

/**
 * Author      : Laxmi Rahate 2019-11-08
 * Description : Method to check if the type value is already selected in other related Configurations, if thats selected thsi method throws an errror
 * Modified : [Brahm][[Edge-113349/123281][2019-11-22]
 */

async function checkIfTypeExists(guid, currType, currOperHrs) {
	//Changes as part of EDGE-155255 start
	//CS.SM.getActiveSolution().then((product) => {
	let product = await CS.SM.getActiveSolution();
	let Component = product.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
	let currentComponent = product.getComponentByName(PFS_COMPONENT_NAMES.solution);
	//Changes as part of EDGE-155255 end
	if (product && product.name.includes(PFS_COMPONENT_NAMES.solution)) {//changed product.type to product- EDGE-155255
		//var TypeArrUpd = ['Config','Site Visit','Proj Man','Training','Design','Install'];
		if (product.components && Object.values(product.components).length > 0) {//EDGE-155255
			//Object.values(product.components).forEach((comp) => {//EDGE-155255
			for (const comp of Object.values(product.components)) {//EDGE-155255
				if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {

					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255
						//Object.values(comp.schema.configurations).forEach((telstraColPFSConfig) => {//EDGE-155255
						for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) { //EDGE-155255
							if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {//EDGE-155255
								var ErrorType;
								var ErrorQty;
								//var updateMap = [];//EDGE-155255
								let updateMap = {};//EDGE-155255 
								var OperHrsVal;
								var typeValue;
								Object.values(telstraColPFSConfig.relatedProductList).forEach((relatedConfig) => {//EDGE-155255
									OperHrsVal = '';
									typeValue = '';
									console.log('checkIfTypeExists currType =' + currType);

									Object.values(relatedConfig.configuration.attributes).forEach((attribute) => {//EDGE-155255
										if (guid != relatedConfig.guid) {
											if (attribute.name === 'Type')
												typeValue = attribute.value;

											if (attribute.name === 'OperationalHours')//[Brahm][Edge-113349/123281][start]
												OperHrsVal = attribute.displayValue;

											//console.log('checkIfTypeExists_ typeValue4567 ='+typeValue+ " currType="+currType);
											//console.log('checkIfTypeExists_before_beforevalidation OperHrsVal4567 ='+OperHrsVal+ "currOperHrs="+currOperHrs+ ' CheckQty ='+CheckQty);

											if (typeValue === currType && currOperHrs === OperHrsVal && typeValue != "" && currType != "" && currOperHrs != "" && OperHrsVal != "") {
												console.log('Error ------- You can not select same Type and Operation Hours combination.');
												//Changes as part of EDGE-155255 start
												/*updateMap[guid] = [{
													name: "Type",
													value: {
														value: '',
														displayValue: '',
														readOnly: false,
														required: true
													}
												},
												{
													name: "OperationalHours",
													value: {
														value: '',
														displayValue: '',
														readOnly: false,
														required: true
													}
												}

												];*/
												updateMap[guid] = [];
												updateMap[guid].push({
													name: "Type",
													value: '',
													displayValue: '',
													readOnly: false,
													required: true
												},
													{
														name: "OperationalHours",
														value: '',
														displayValue: '',
														readOnly: false,
														required: true
													});
												//Changes as part of EDGE-155255 end
												ErrorType = true;
											}
										}
										if (attribute.name === 'Quantity') {
											quantVal = attribute.value;
											console.log('attribute:' + quantVal.indexOf("."));
											console.log('attribute:' + attribute.name);
											if (quantVal.indexOf(".") > -1) {
												q = quantVal.split(".");
												if (q[1].length > 2) {
													//Changes as part of EDGE-155255 start
													/*updateMap[relatedConfig.guid] = [{
														name: "Quantity",
														value: {
															value: '',
															displayValue: '',
															readOnly: false,
															required: true
														}
													}];*/

													updateMap[relatedConfig.guid] = [];
													updateMap[relatedConfig.guid].push({
														name: "Quantity",
														value: '',
														displayValue: '',
														readOnly: false,
														required: true
													});
													//Changes as part of EDGE-155255 end
													console.log('Error ------- You can not exceed the decimal limit more than two.');
													ErrorQty = true;
												}
											}
										}
									});
								});
								if (ErrorType === true) {
									console.log('checkIfTypeExists_ 111135 =');
									//Changes as part of EDGE-155255 start
									//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.telstraColPFS, updateMap, true).then(component => console.log('addMobileDeviceConfigurations Attribute update', component));
									if (updateMap && Object.keys(updateMap).length > 0) {
										keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											await Component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
										}
									}
									//CS.SM.updateConfigurationStatus(comp.name, guid, false, 'Selected Type and Operational Hours combination are already selected, please select different combination!');

									let config = await currentComponent.getConfiguration(guid);
									config.status = false;
									config.statusMessage = 'Selected Type and Operational Hours combination are already selected, please select different combination!';
									//Changes as part of EDGE-155255 end
								}
								else if (ErrorQty === true) {
									console.log('checkIfTypeExists_ 111136 =');
									//Changes as part of EDGE-155255 start
									//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.telstraColPFS, updateMap, true).then(component => console.log('addMobileDeviceConfigurations Attribute update', component));
									if (updateMap && Object.keys(updateMap).length > 0) {
										keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											await Component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
										}
									}
									//CS.SM.updateConfigurationStatus(comp.name, guid, false, 'Numbers of hours ' + quantVal + '  can not exceed the decimal limit more than two!');

									let config = await currentComponent.getConfiguration(guid);
									config.status = false;
									config.statusMessage = 'Numbers of hours ' + quantVal + ' can not exceed the decimal limit more than two!';
									//Changes as part of EDGE-155255 end
								}
								else {
									console.log('checkIfTypeExists_ 111137 =');
									//Changes as part of EDGE-155255 start
									//CS.SM.updateConfigurationStatus(comp.name, guid, true);
									let config = await currentComponent.getConfiguration(guid);
									config.status = true;
									//Changes as part of EDGE-155255 end
								}//[Brahm][Edge-113349/123281][End]
							}

						}//);

					}
				}

			}//);

		}
	}

	//});
	return Promise.resolve(true);

}

/*****************************************
 * Author      : Brahm  2019-11-12
 * Description : Method to update the EDMListToDecompose for the professional service based on its type selected on the Telstra Collab Prof Serv Features
 [Brahm][[Edge-113349]
 *****************************************/
async function EDMListToDecomposePFS() {
	//console.log('EDMListToDecomposePFS entering solution='+product);
	//Changes as part of EDGE-155255 start
	let solution = await CS.SM.getActiveSolution();
	let Component = solution.getComponentByName(PFS_COMPONENT_NAMES.telstraColPFS);
	//CS.SM.getActiveSolution().then((solution) => {
	//Changes as part of EDGE-155255 end
	if (solution && solution.name.includes(PFS_COMPONENT_NAMES.solution)) {//changes from solution.type to solution- EDGE-155255
		if (solution.components && Object.values(solution.components).length > 0) {//EDGE-155255
			//var UpdEDMListToDecomMap = [];//EDGE-155255
			let UpdEDMListToDecomMap = {};//EDGE-155255
			//Object.values(solution.components).forEach((comp) => {//EDGE-155255
			for (const comp of Object.values(solution.components)) { //EDGE-155255
				if (comp.name === PFS_COMPONENT_NAMES.telstraColPFS) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-155255
						console.log('EDMListToDecomposePFS entering schema=' + comp.schema);
						console.log('EDMListToDecomposePFS entering config=' + comp.schema.configurations);
						//Object.values(comp.schema.configurations).forEach((telstraColPFSConfig) => {//EDGE-155255
						for (const telstraColPFSConfig of Object.values(comp.schema.configurations)) { //EDGE-155255
							if (telstraColPFSConfig.relatedProductList && Object.values(telstraColPFSConfig.relatedProductList).length > 0) {//EDGE-155255
								console.log('EDMListToDecomposePFS entering relateProd=' + telstraColPFSConfig.relatedProductList);
								//telstraColPFSConfig.relatedProductList.forEach((relatedConfig) => {//EDGE-155255
								for (const relatedConfig of Object.values(telstraColPFSConfig.relatedProductList)) {//EDGE-155255
									var guid;
									var EDMVal;
									var typeVal;
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

											console.log('EDMval:' + EDMVal);

											//Changes as part of EDGE-155255 start
											/*UpdEDMListToDecomMap[guid] = [{
												name: 'EDMListToDecompose',
												value: {
													value: EDMVal,
													displayValue: EDMVal
												}
											}];*/

											UpdEDMListToDecomMap[guid] = [];
											UpdEDMListToDecomMap[guid].push({
												name: "EDMListToDecompose",
												value: EDMVal,
												displayValue: EDMVal
											});
											console.log('EDMList - Related ConfigGUID' + guid);
											//console.log('EDMList - UpdEDMListToDecomMap'+EDMListToDecompose);
										}

									});
									//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.telstraColPFS, UpdEDMListToDecomMap, true);
									if (UpdEDMListToDecomMap && Object.keys(UpdEDMListToDecomMap).length > 0) {
										keys = Object.keys(UpdEDMListToDecomMap);
										for (let i = 0; i < keys.length; i++) {
											await Component.updateConfigurationAttribute(keys[i], UpdEDMListToDecomMap[keys[i]], true);
										}
									}
									//Changes as part of EDGE-155255 end
								}//);
								console.log('EDMListToDecomposePFS UpdEDMListToDecomMap =' + UpdEDMListToDecomMap);
							}
						}//);

					}
				}
			}//);
		}
	}
	//});
	//});
	return Promise.resolve(true);
}

/* 	
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
	Modifications :
    1. Gnana - EDGE-164917 : Changed logic to get Display Value for OfferName instead of Value which was giving Id
*/
async function updateSolutionName_TCPS() {
	var listOfAttributes = ['Solution Name', 'GUID'], attrValuesMap = {};
	var listOfAttrToGetDispValues = ['OfferName'], attrValuesMap2 = {};
	let configGuid;//EDGE-155255
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, PFS_COMPONENT_NAMES.solution);
	attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues,PFS_COMPONENT_NAMES.solution);
	let solution = await CS.SM.getActiveSolution();//EDGE-155255
	let component = solution.getComponentByName(PFS_COMPONENT_NAMES.solution);//EDGE-155255
	console.log('attrValuesMap...' + attrValuesMap);
	if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_TCPS) {
		let updateConfigMap = {};
		//Changes as part of EDGE-155255 start
		/*updateConfigMap[attrValuesMap['GUID']] = [{
			name: 'Solution Name',
			value: {
				value: attrValuesMap['OfferName'],
				displayValue: attrValuesMap['OfferName']
			}

		}];*/

		configGuid = attrValuesMap['GUID'];
		updateConfigMap[configGuid] = [];
		updateConfigMap[configGuid].push({
			name: "Solution Name",
			value: attrValuesMap2['OfferName'],
			displayValue: attrValuesMap2['OfferName']
		});
		if (updateConfigMap) {
			//CS.SM.updateConfigurationAttribute(PFS_COMPONENT_NAMES.solution, updateConfigMap, true);
			if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
				keys = Object.keys(updateConfigMap);
				
				var complock = component.commercialLock;
				if (complock)
					component.lock('Commercial', false);
					
				for (let i = 0; i < keys.length; i++) {
					
					await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
				}
				if (complock) {
					component.lock('Commercial', true);
				}

			}
			//Changes as part of EDGE-155255 end
		}
	}
	return Promise.resolve(true);
}