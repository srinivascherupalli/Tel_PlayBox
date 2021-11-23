	/******************************************************************************************
	Version No	Author 			                Date
	1 			Shubhi 							14-OCt-2019	
	2			Shubhi							30-Oct-2019		
	3           Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey	
	4           Aditya                          27-Nov-2019          EDGE -123607 Increased the width of Rate Card								
	5           Purushottam                     12-May-2020          EDGE -145320 Tenancy Lookup Model Fix TDS enchacement
	6			Aman Soni						19-May-2020			 EDGE -148455 - To capture Billing Account	
	7	        Gnana           				10-Jun-2020     	 EDGE-149887 - Solution Name Update Logic 
	8           Pooja                           02-Jul-2020          EDGE-154489 Refactoring Offer_Managed Services for JS File
	9           Aditya                          21-July-2020		 Edge-142084, Enable New Solution in MAC Basket	
	10           Gnana                           23-July-2020         EDGE-164917 - Changed logic to get Display Value for OfferName instead of Value which was giving Id
	11 			Gnana & Aditya  				19-Jul-2020			 Spring'20 Upgrade
	12          Aditya                          21-July-2020		 Edge-142084, Enable New Solution in MAC Basket
	13          Krunal Taak                     02-09-2020           DPG-2577 - P2O validation
	14			Monali				            14-Sep-2020          DPG-2648 - Cancel Flow for Managed Service
	*******************/
	var executeSaveEMS = false;
	var saveEMS = false;
	var EMS_COMPONENT_NAMES = {
		solution: 'Adaptive Mobility Managed Services',
		mobilityPlatformMgmt: 'Unified Endpoint Management - Platform Management',
		userSupport: 'Unified Endpoint Management - End User Support'
		//mobilityManagedService mobilityPlatformMgmt
	};

	var crdoeschemaid = null;
	var show = false;
	var UserAdded = false;
	var MobPlatformAdded = false;
	var changetypeMACsolution = null;
	var communitySiteId;

	//var DEFAULTSOLUTIONNAME_EMS = 'Enterprise Mobility Managed Services'; // Added as part of EDGE-149887
	var DEFAULTSOLUTIONNAME_EMS = 'Adaptive Mobility Managed Services'

	// Changes as part of EDGE-154489 start
	if (CS.SM.registerPlugin) {
		console.log('Load EMSPlugin');
		window.document.addEventListener('SolutionConsoleReady', async function () {
			console.log('SolutionConsoleReady for EMSPlugin');
			await CS.SM.registerPlugin(EMS_COMPONENT_NAMES.solution)
				.then(async EMSPlugin => {
					console.log("Plugin registered for Managed Services");
					// For Hooks
					EMSPlugin_updatePlugin(EMSPlugin);
				});
		});
	}
	// Changes as part of EDGE-154489 end


	//EMSPlugin_updatePlugin = async function (EMSPlugin) {//EDGE-154489
	async function EMSPlugin_updatePlugin(EMSPlugin) {//EDGE-154489
		console.log('Adding Hooks to EMSPlugin');
		//if (CS.SM.createPlugin){
		//console.log('Load  Managed Service Solution plugin');
		//EMSPlugin = CS.SM.createPlugin('Managed Services');		
		Utils.updateCustomButtonVisibilityForBasketStage();//EDGE-154489

		//Changes as part of EDGE-154489 end here
		//console.log('inside EMSPlugin_updatePlugin');
		window.addEventListener('message', EMSPlugin_handleIframeMessage);
		//setInterval(EMSPlugin_processMessagesFromIFrame, 500);//EDGE-154489
		//AB rename customAttribute link text, added click event listener
		document.addEventListener('click', function (e) {
			e = e || window.event;
			var target = e.target || e.srcElement;
			//var text = target.textContent || target.innerText;
			//console.log('test-->'+text);
			if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
				//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			  //EDGE -145320 >> -
				Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies'); //EDGE -145320 >> +
				Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
			}
			/*(if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution && text && 
				(text.toLowerCase() === EMS_COMPONENT_NAMES.mobilityPlatformMgmt.toLowerCase()) ||
				text.toLowerCase() === EMS_COMPONENT_NAMES.userSupport.toLowerCase()) {
				Utils.updateCustomAttributeLinkText('Rate Card','View Rate Card');
			}*/
			//autoSelectTMDMSUpportValues();
		}, false);
		setInterval(EMSPlugin_processMessagesFromIFrame, 500);



		//Changes as part of EDGE-154489 start
		//EMSPlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
		EMSPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
			//updateSolutionName_EMS(); // Added as part of EDGE-149887
			console.log('afterSave', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
			//Changes as part of EDGE-154489 end here

			console.log('afterSave - entering');
			Utils.updateOEConsoleButtonVisibility();
			Utils.updateCustomButtonVisibilityForBasketStage();
			//AB rename customAttribute link text
			if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
				//again update link text value as UI is refreshed after save
				Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
				//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			   //EDGE -145320 >> -
				Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies');  //EDGE -145320 >> +
			}
			//Added for Cancel Story DPG-2648
			if (basketChangeType === 'Change Solution') {
				EMSPlugin_UpdateMainSolutionChangeTypeVisibility(solution);
				//checkConfigurationSubscriptionsForNGAC('afterSave');
			}
			/*CS.SM.getActiveSolution().then((solution) => {
			if (solution.type && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
				if (solution.schema.configurations && solution.schema.configurations.size > 0) {
					Object.values(solution.schema.configurations).forEach((config) => {
						if (config.attributes && config.attributes.size > 0) {
							Object.values(config.attributes).forEach((attr) => {
								if (attr.name === 'TenancyID' && (attr.value === '' || attr.value === null || attr.value === undefined)) {
									CS.SM.updateConfigurationStatus(solution.name, config.guid, false, 'Please select Tenancy');//will check this
								}
								else if (attr.name === 'TenancyID' && attr.value.length > 0) {
									CS.SM.updateConfigurationStatus(solution.name, config.guid, true);	//will check this
								}
							});
						}
					});
				}
			}*/

			/* //--- Commented by Krunal -- moved to before save - DPG-2577 - START
			let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
			let Component = currentSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);//EDGE-154489
			if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution //EDGE-154489
				if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {//EDGE-154489
					//Object.values(currentSolution.schema.configurations).forEach((config) => {
					for (const config of Object.values(currentSolution.schema.configurations)) {//EDGE-154489
						if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
							//Object.values(config.attributes).forEach((attr) => {
							for (const attr of Object.values(config.attributes)) {//EDGE-154489
								if (attr.name === 'TenancyID' && (attr.value === '' || attr.value === null || attr.value === undefined)) {
									//Changes as part of EDGE-154489 start
									//CS.SM.updateConfigurationStatus(currentSolution.name, config.guid, false, 'Please select Tenancy');
									let confg = await Component.getConfiguration(config.guid);
									confg.status = false;
									confg.statusMessage = 'Please select Tenancy';
									//Changes as part of EDGE-154489 end

								}
								else if (attr.name === 'TenancyID' && Object.values(attr.value).length > 0) {//EDGE-154489
									//Changes as part of EDGE-154489 start
									//CS.SM.updateConfigurationStatus(currentSolution.name, config.guid, true);
									let confg = await Component.getConfiguration(config.guid);
									confg.status = true;
									//Changes as part of EDGE-154489 end
								}
							}//);
						}
					}//);
				}
			}*/ //-- Commented by Krunal -- moved to before save - DPG-2577 - END

			//});
			//populateRateCardinAttachmentEMS();
			//EMSPlugin.setOETabsVisibility();
			autoSelectTMDMSUpportValues();
			//updateDeviceEnrollmentAfterSolutionLoad1();
			setchangeTypevisibility(solution);
			//EDGE-135267		
			Utils.hideSubmitSolutionFromOverviewTab();
			await Utils.updateActiveSolutionTotals();//Added as part of EDGE-154489
			CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
			return Promise.resolve(true);
		}
		

	//--BEFORESAVE - added by krunal - DPG-2577 - START
		EMSPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
			let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
			//-- p2o validation DPG-2577 -- Start -- Krunal //Telstra Mobile Device Management - VMware
			let currentActiveBasket = await CS.SM.getActiveBasket();
			let profServCheck = 'Absent';
			let tmdmVMWareCheck = 'Absent';
			let flag = 'yes';
			if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
				if (currentActiveBasket.solutions && Object.values(currentActiveBasket.solutions).length > 0) {//EDGE-154489
					for (const basketSol of Object.values(currentActiveBasket.solutions)) {
						if (basketSol.name === 'T-MDM Professional Services') {
							profServCheck = 'PFPresent';
						}
						else if (basketSol.name === 'Telstra Mobile Device Management - VMware') {
							tmdmVMWareCheck = 'TMDMPresent';
						}
						else{}
					}
				}
			}
			//-- p2o validation DPG-2577 -- End -- Krunal - part of code from aftersave
			let Component = currentSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);//EDGE-154489
			if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution //EDGE-154489
				if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {//EDGE-154489
					//Object.values(currentSolution.schema.configurations).forEach((config) => {
					for (const config of Object.values(currentSolution.schema.configurations)) {//EDGE-154489
						if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
							//Object.values(config.attributes).forEach((attr) => {
							for (const attr of Object.values(config.attributes)) {//EDGE-154489
								if (attr.name === 'TenancyID' && Object.values(attr.value).length > 0  && tmdmVMWareCheck === 'Absent' && basketChangeType != 'Change Solution') {
									console.log('---5---');
									validationActiveManagedServiceSubscriptionCheck(attr,Component,config.guid);
								}
								
								if (attr.name === 'TenancyID' && (attr.value === '' || attr.value === null || attr.value === undefined) && tmdmVMWareCheck === 'Absent') {
									console.log('----1----');
									//Changes as part of EDGE-154489 start
									let confg = await Component.getConfiguration(config.guid);
									confg.status = false;
									confg.statusMessage = 'Please select an existing tenancy or add a new tenancy';
									//currentSolution.errorMessage = 'Error in configurations';
									//currentSolution.error = true;
									//currentSolution.valid = true;
									//currentSolution.errorMessages.push('Error in configurations (Managed Services)');
									//Changes as part of EDGE-154489 end
								}
								//to check if Existing Tenancy is selected and adding new Telstra Mobile Device Management - VMware //-- p2o validation DPG-2577 -- Start -- Krunal
								else if ((attr.name === 'TenancyID' && Object.values(attr.value).length > 0) && tmdmVMWareCheck === 'TMDMPresent' ) {
									console.log('----2----');
									let confg = await Component.getConfiguration(config.guid);
									confg.status = false;
									confg.statusMessage = 'Basket cannot add new Telstra Mobile Device Management - VMware when existing Tenancy is selected';
								}
								
								else if (((attr.name === 'TenancyID' && Object.values(attr.value).length > 0)|| tmdmVMWareCheck === 'TMDMPresent') && profServCheck === 'Absent' && basketChangeType != 'Change Solution') {
									console.log('----3----');
									let confg = await Component.getConfiguration(config.guid);
									confg.status = false;
									confg.statusMessage = 'Please add Professional Services to the basket';
								}
								
								else if ((attr.name === 'TenancyID' && Object.values(attr.value).length > 0) || tmdmVMWareCheck === 'TMDMPresent') {//EDGE-154489
									console.log('----4----');
									//Changes as part of EDGE-154489 start
									//CS.SM.updateConfigurationStatus(currentSolution.name, config.guid, true);
									let confg = await Component.getConfiguration(config.guid);
									confg.status = true;
									confg.statusMessage = '';
									return Promise.resolve(true);
									//Changes as part of EDGE-154489 end
								}
								//-- p2o validation DPG-2577 -- End -- Krunal
							}//);
						}
					}//);
				}
			}
			//return Promise.resolve(true);
			//validateMpmUsValues();
		}
		
	//--BEFORESAVE - added by krunal - DPG-2577 - END

		//Aditya: Spring Update for changing basket stage to Draft
		EMSPlugin.afterSolutionDelete = function (solution) {
			CommonUtills.updateBasketStageToDraft();
			return Promise.resolve(true);
		}

		//Updated for edge-117563
		//Changes as part of EDGE-154489 start
		//EMSPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {
		EMSPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
			console.log('---attribute.name---', attribute.name, '---component.name---', component.name);
			console.log('---configuration.name---', configuration.name, '---configuration---', configuration);
			console.log('---configuration.attributes---', configuration.attributes.tenancyid.name);
			//console.log('----1234----'+Object.values(Object.values(component)[0].schema.configurations)[0].attributes);
			if (component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt && attribute.name === 'TechnicalSupport') {
				//console.log('*************Attribute Update - After - OE ---', componentName, guid, attribute, 'oldValue:',oldValue,'newValue:', newValue);
				//console.log('*************Attribute Update - After - OE ---', component, configuration.guid, attribute, 'oldValue:', oldValueMap['value'], 'newValue:', attribute.value);//	//EDGE-154489

				autoSelectTMDMSUpportValues();
			}
			//- DPG-2577 - Krunal - Start
			if ((component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt || component.name === EMS_COMPONENT_NAMES.userSupport) && (attribute.name === 'TechnicalSupport' || attribute.name === 'FeatureLevel')) {
				console.log('*************Attribute Update - validateMpmUsValues---', component, configuration.guid, attribute, 'oldValue:', oldValueMap['value'], 'newValue:', attribute.value, 'oldValueMap:', oldValueMap);
				validateMpmUsValues();
			}
			
			if (component.name === EMS_COMPONENT_NAMES.solution  && attribute.name === 'TenancyID' ) {	
				// if(configuration.attributes.tenancyid.name === 'TenancyID'){
			console.log('*************inside TenancyId---', attribute.name, attribute.displayValue, attribute.value, configuration, attribute, 'oldValue:', oldValueMap.value, 'newValue:', attribute.value, 'oldValueMap:', oldValueMap, '----', oldValueMap['value']);
										//var tenancyId=attribute;
					
				//validationActiveManagedServiceSubscriptionCheck(tenancyId,component,configuration.guid);	
				// }				
			} 
			//- DPG-2577 - Krunal - End

			/*********************************
		 * Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey
		 * Invokes on update of ChangeType at Main solution & invokes the function to add all subscriptions of component to the MAC basket.
		 *********************************/
			//if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === 'ChangeType' && oldValue !== newValue && (newValue === 'Modify' || newValue === 'Cancel')) {
			if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === 'ChangeType' && oldValueMap.value !== attribute.value && (attribute.value === 'Modify' || attribute.value === 'Cancel')) {	//EDGE-154489
				//console.log('*************Attribute Update - After - OE ---', componentName, guid, attribute, 'oldValue:',oldValue,'newValue:', newValue);
				//console.log('*************Attribute Update - After - OE ---', component.name, configuration.guid, attribute, 'oldValue:', oldValueMap['value'], 'newValue:', attribute.value);	//EDGE-154489
				//changetypeMACsolution = newValue;
				changetypeMACsolution = attribute.value;
				await addAllEMSSubscriptionstoMAC();

			}
			//Updated for edge-117563
			if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
				//again update link text value as UI is refreshed after save
				Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
				//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			  //EDGE -145320 >> -
				Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies'); //EDGE -145320 >> +
			}
			
			//Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- Reused for Modify
			if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
				EMSPlugin_UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
			}
			if (basketChangeType === 'Change Solution' && component.name === EMS_COMPONENT_NAMES.solution && attribute.name === 'DisconnectionDate'){
				EMSPlugin_validateDisconnectionDate(component.name, configuration.guid, attribute.value);
			}

			return Promise.resolve(true);
		}


		//Changes as part of EDGE-154489 start
		//EMSPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {
		//if(window.currentSolutionName === EMS_COMPONENT_NAMES.solution){
		window.document.addEventListener('SolutionSetActive', async function (e) {
			let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
			if (currentSolution.name === EMS_COMPONENT_NAMES.solution) {//EDGE-154489
				//Changes as part of EDGE-154489 end here
				validationErrorActiveManagedServiceSubscriptionCheck() // Krunal DPG-2577
				//console.log('solution loaded!!!');
				//Changes as part of EDGE-154489 start
				let currentBasket;
				let loadedSolution;

				currentBasket = await CS.SM.getActiveBasket();
				loadedSolution = await CS.SM.getActiveSolution();
				basketId = currentBasket.basketId;

				/*await CS.SM.getCurrentCart().then(cart => {//check this
					console.log('Basket: ', cart);
					basketId = cart.id;
		
				});*/
				//Changes as part of EDGE-154489 end here

				//updateDeviceEnrollmentAfterSolutionLoad1();	
				window.currentSolutionName = loadedSolution.name;
				//console.log('window.currentSolutionName', window.currentSolutionName);
				//Getting the baket Id

				//EDGE-109925 - render page on PRM, start
				let map = {};
				map['GetSiteId'] = '';
				await currentBasket.performRemoteAction('SolutionActionHelper', map).then(result => {//EDGE-154489
					//console.log('GetSiteId finished with response: ', result);
					communitySiteId = result["GetSiteId"]
					//console.log('communitySiteId: ', communitySiteId);
				});

				//console.log('Basket ID--------' + basketId);
				let inputMap = {};
				inputMap['GetBasket'] = basketId;
				await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {//EDGE-154489
					//console.log('GetBasket finished with response: ', result);
					var basket = JSON.parse(result["GetBasket"]);
					//console.log('GetBasket: ', basket);
					basketChangeType = basket.csordtelcoa__Change_Type__c;
					basketStage = basket.csordtelcoa__Basket_Stage__c;
					accountId = basket.csbb__Account__c;
					inputMap['AccountId'] = accountId; //Krunal - DPG-2577
					console.log('---acc id--'+accountId);
					//console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId);
					//console.log('GetSiteId finished with response: ', result);
					//communitySiteId = result["GetSiteId"]
					//console.log('communitySiteId: ', communitySiteId);
					window.oeSetBasketData(basketId, basketStage, accountId);
					//Added by Aman Soni as a part of EDGE -148455 || Start
					if (accountId != null) {
						CommonUtills.setAccountID(EMS_COMPONENT_NAMES.solution, accountId);
					}
					// Aditya: Edge:142084 Enable New Solution in MAC Basket
					//CommonUtills.setBasketChange(); commenting as this function is not there in Generic Java Script
					//Added by Aman Soni as a part of EDGE -148455 || End
				});

				if (basketStage === 'Contract Accepted') {
					loadedSolution.lock('Commercial', true);
				}
				
				// Added for making BillingAccount ReadOnly in MACD Journey(DPG-2648) 
				if (basketChangeType === 'Change Solution') {
				//await checkConfigurationSubscriptionsForMS('afterSolutionLoaded');
					await EMSPlugin_UpdateMainSolutionChangeTypeVisibility(loadedSolution);
					CommonUtills.setSubBillingAccountNumberOnCLI(EMS_COMPONENT_NAMES.solution,'BillingAccountLookup');		// Krunal //tocheck
					let componentMap = new Map();
					let componentMapattr = {};
				  
					if(loadedSolution ){
						//loadedSolution.schema.configurations.forEach((config) => {
						Object.values(loadedSolution.schema.configurations).forEach((config) => {
						if(config.attributes){
							componentMapattr['BillingAccountLookup'] = [];
							componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': true });
							componentMap.set(config.guid, componentMapattr);
						}
						});
						CommonUtills.attrVisiblityControl(EMS_COMPONENT_NAMES.solution, componentMap);
					}
				}//END DPG-1914
					
				// addDefaultEMSOEConfigs();
				populateRateCardinAttachmentEMS();
				autoSelectTMDMSUpportValues();
				validateMpmUsValues(); //Krunal DPG-2577
				//EMSPlugin.getConfiguredSiteIds();
				Utils.loadSMOptions();
				//AB rename customAttribute link text
				if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
					//again update link text value as UI is refreshed after save
					Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
					//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			  //EDGE -145320 >> -
					Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies'); //EDGE -145320 >> +
				}
				setchangeTypevisibility(loadedSolution);
				return Promise.resolve(true);
			}
		});


		//EMSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {//EDGE-154489
		EMSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {//EDGE-154489
			//console.log('afterConfigurationAdd', component, configuration);
			//if (component === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//EDGE-154489
			if (component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//EDGE-154489
				//EMSPlugin.getConfiguredSiteIds();
				//await DOP_updateConfigurationsName();
			}
			addDefaultEMSOEConfigs();
			//Updated for edge-117563
			if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
				//again update link text value as UI is refreshed after save
				Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
				//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			//EDGE -145320 >> -
				Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies');//EDGE -145320 >> +
			}
			if (component.name === EMS_COMPONENT_NAMES.userSupport || component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//changed component to component.name //EDGE-154489
				//Changes as part of EDGE-154489 start here
				/*updateMap[configuration.guid] = [{
					name: "ChangeType",
					value: {
						value: "New",
						readOnly: true,
						showInUi: false
					}
				}];*/
				//CS.SM.updateConfigurationAttribute(component, updateMap, true);

				let updateMap = {};
				updateMap[configuration.guid] = [];
				updateMap[configuration.guid].push({
					name: "ChangeType",
					value: "New",
					readOnly: true,
					showInUi: false
				});

				if (updateMap && Object.keys(updateMap).length > 0) {
					keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
					}
				}


				//Changes as part of EDGE-154489 end here
			}
			return Promise.resolve(true);
		}

		/*/*** updated for edge-117563 ***/
		//EMSPlugin_onCustomAttributeEdit = async function (componentName, configurationGuid, attributeName) {
		/*EMSPlugin.onCustomAttributeEdit = async function (componentName, configurationGuid, attributeName) {//EDGE-154489
			console.log('Inside customAttributeEdit Guid--->' + configurationGuid);
			var url = '';
			var vfRedirect = '';
			var featureLevel = '';
			var techSupport = '';
			var type = '';
			var selectedTenancyIds = '';

			//Changes as part of EDGE-154489 start
			//await CS.SM.getActiveSolution().then((solution) => {
			let solution = await CS.SM.getActiveSolution();
			if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed solution.type to solution
				if (solution.components && Object.values(solution.components).length > 0) {
					Object.values(solution.schema.configurations).forEach((config) => {
						if (config.attributes && Object.values(config.attributes).length > 0) {
							Object.values(config.attributes).forEach((attr) => {
								if (attr.name === 'TenancyID') {
									selectedTenancyIds = attr.value;
									console.log('selectedTenancyIds-->' + selectedTenancyIds);
								}
							});
						}
					});


					Object.values(solution.components).forEach((comp) => {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0
							&& (comp.schema.name.includes(EMS_COMPONENT_NAMES.userSupport) || comp.schema.name.includes(EMS_COMPONENT_NAMES.mobilityPlatformMgmt))) {
							Object.values(comp.schema.configurations).forEach((config) => {
								console.log('Inside customAttributeEdit Config Guid--->' + config.guid);
								if (config.guid === configurationGuid) {
									if (config.attributes && Object.values(config.attributes).length > 0) {
										Object.values(config.attributes).forEach((attr) => {
											if (attr.name === 'Type')
												type = attr.value;
											if (attr.name === 'TechnicalSupport')
												techSupport = attr.displayValue;
											if (attr.name === 'FeatureLevel')
												featureLevel = attr.displayValue;
										});

										//Changes as part of EDGE-154489 end here
									}
								}
							});
						}
					});

				}
			}
			//});



			var redirectURI = '/apex/';
			if (communitySiteId) {
				url = window.location.href;
				if (url.includes('partners.enterprise.telstra.com.au'))
					redirectURI = '/s/sfdcpage/%2Fapex%2F';
				else
					//redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';  //EDGE -145320 >> -
					redirectURI = '/partners/';							//EDGE -145320 >> +
			}
			url = redirectURI;
			//updated for EDGE-123914
			if (attributeName === 'tmdmRateCardButton') {
				if (communitySiteId) {

					url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + featureLevel + '&techSupport=' + techSupport + '&type=' + type;
					// Updated for Edge-123607
					vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="930px" width="820px"></iframe></div>'; console.log('Url ---->', url);
				}
				else {
					url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + featureLevel + '&techSupport=' + techSupport + '&type=' + type;
					vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="530px" width="920px"></iframe></div>';
					//url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + 'Standard' + '&techSupport=' + 'Bus Hrs' + '&type=End User Support';
					console.log('Url ---->', url);
				}
				console.log('Filter Values --->' + featureLevel + type);
				//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="260px" width="820px"></iframe></div>';
				console.log('vfRedirect--->' + vfRedirect);
			}

			else if (attributeName === 'endUserSupportRateCardButton') {
				if (communitySiteId) {

					url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + featureLevel + '&techSupport=' + techSupport + '&type=' + type;
					vfRedirect = '<iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="960px" width="970px"></iframe>';
					console.log('Url ---->', url);
				}
				else {
					//url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + 'Standard' + '&techSupport=' + 'Bus Hrs' + '&type=End User Support';
					//url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + featureLevel + '&techSupport=' + techSupport + '&type='+type;
					url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + featureLevel + '&techSupport=' + techSupport + '&type=' + type;
					vfRedirect = '<iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="490px" width="960px"></iframe>';
					console.log('Url ---->', url);
				}
				console.log('Filter Values --->' + featureLevel + type);
				//vfRedirect ='<iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="800px" width="820px"></iframe>';
				console.log('vfRedirect--->' + vfRedirect);
			}

			else if (attributeName === 'TenancyButton') {

				console.log('basketId', basketId);
				console.log('accountId', accountId);
				console.log('TenancyId', selectedTenancyIds);

				var tenancyTypeProdIdList = ['DMCAT_ProductSpecification_000537'];

				if (communitySiteId) {
					url = url + 'c__existingTenancy?basketId=' + basketId + '&accountId=' + accountId + '&filterByTenancyType=' + 'true' + '&tenancyTypeProdIdList=' + tenancyTypeProdIdList + '&selectedTenancyIds=' + selectedTenancyIds;
					vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="850px"></iframe></div>';
				} else {
					url = url + 'c__existingTenancy?basketId=' + basketId + '&accountId=' + accountId + '&filterByTenancyType=' + 'true' + '&tenancyTypeProdIdList=' + tenancyTypeProdIdList + '&selectedTenancyIds=' + selectedTenancyIds;
					vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="850px"></iframe></div>';
				}
				console.log('url: ', url);
				console.log('Filter Values --->' + featureLevel + type);
				//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="800px" width="800px"></iframe></div>';
				console.log('vfRedirect--->' + vfRedirect);
			}
			return Promise.resolve(vfRedirect);
		}*/



		EMSPlugin.setOETabsVisibility = async function () {
			//console.log('setOETabsVisibility');

			//Changes as part of EDGE-154489 start
			let solution = await CS.SM.getActiveSolution();
			//CS.SM.getActiveSolution().then((solution) => {
			if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed solution.type to solution//EDGE-154489
				if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154489
					Object.values(solution.components).forEach((comp) => {//EDGE-154489
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
							Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154489
								if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
									// Aditya: Edge:142084, Enable New Solution in MAC Basket
									if ((window.BasketChange === 'Change Solution' && basketStage === 'Commercial Configuration') || !Utils.isOrderEnrichmentAllowed()) {

										CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
										//console.log('setOETabsVisibility - hiding:', comp.name, config.guid);
									} else {
										CS.SM.setOEtabsToLoad(comp.name, config.guid, undefined);
										//console.log('setOETabsVisibility - showing:', comp.name, config.guid);
									}
								}
							});
						}
					});
				}
			}
			//});//Changes as part of EDGE-154489 start
		}

		//EMSPlugin.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
		EMSPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {
			//console.log('TID afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration);
			//initializeDOPOEConfigs();
			//window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
			return Promise.resolve(true);
		}


		/**
		 * Finds all custom attributes by label (i.e. Rate Card) and sets new link text (i.e. Edit -> View Rate Card)
		 */
		EMSPlugin.updateCustomAttributeLinkText = function (customAttributeLabel, newLinkText) {
			//console.log('TID afterOrderEnrichmentConfigurationAdd');
			var customAttributes = document.getElementsByTagName('app-specification-editor-attribute-custom');
			var i;
			for (i = 0; i < customAttributes.length; i++) {
				//if link belongs to parent that has correct label value then update the link text to new value
				if (customAttributes[i].parentElement &&
					customAttributes[i].parentElement.parentElement &&
					customAttributes[i].parentElement.parentElement.previousSibling &&
					customAttributes[i].parentElement.parentElement.previousSibling.innerText === customAttributeLabel) {
					customAttributes[i].firstElementChild.innerText = newLinkText;
				}
			}
		}

		/*********************************
		 * Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey
		 *********************************/
		EMSPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
			console.log('afterConfigurationAdd', componentName, guid);
			
			if (componentName === EMS_COMPONENT_NAMES.userSupport || componentName === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
				   
			   let updateMap = {};
				updateMap[guid] = [];

				updateMap[guid].push(
				{
					name: "ChangeType",
					value : changetypeMACsolution,
					label : "ChangeType",
					showInUi: true,
					readOnly: true
				});
				////Added for Cancel Story DPG-2648 - START
				if(changetypeMACsolution === 'Cancel'){
					updateMap[guid].push(
					{
						name: "FeatureLevel",
						readOnly: true
					},
					{
						name: "TechnicalSupport",
						readOnly: true
					});	
				}
				//Added for Cancel Story DPG-2648 - END

			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(componentName); 
			var complock = component.commercialLock;
			if(complock) component.lock('Commercial', false);
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
			}
			if (complock) component.lock('Commercial', true);
			checkConfigurationSubscriptionsForMS('afterConfigurationAddedToMacBasket');
			}
			//--DPG-2647 -- Krunal Taak -- End
			return Promise.resolve(true);
		}


		//Changes as part of EDGE-154489 start
		//EMSPlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
		window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
			let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
			if (currentSolution.name === EMS_COMPONENT_NAMES.solution) {
				//console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
				//afterOrderEnrichmentTabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name);
				//console.log('afterOETabLoaded : EMSPlugin: ', configurationGuid, OETabName);
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
				//Changes as part of EDGE-154489 end here
			}
			return Promise.resolve(true);
		});
	}


	/**
		 * Author      : Shubhi
		 * Functions for processing iFrame messages
		 */
	function EMSPlugin_processMessagesFromIFrame() {
		//EMSPlugin_processMessagesFromIFrame = function () {
		//console.log('inside processMessagesFromIFrame');
		if (!communitySiteId) {
			return;
		}
		var data = sessionStorage.getItem("payload");
		var close = sessionStorage.getItem("close");
		//console.log('Data -->' + data);
		//console.log('close -->' + close);
		var message = {};
		if (data) {
			//console.log('EMSPlugin.processMessagesFromIFrame:', data);
			message['data'] = JSON.parse(data);
			EMSPlugin_handleIframeMessage(message);
		}
		if (close) {
			//console.log('EMSPlugin.processMessagesFromIFrame close:', data);
			message['data'] = close;
			EMSPlugin_handleIframeMessage(message);
		}
	}


	function updateEMSAfterSolutionLoad1() {
		//console.log('inside updateDeviceEnrollmentAfterSolutionLoad')
	}

	async function addDefaultEMSOEConfigs() {
		//console.log('addDefaultEMSOEConfigs');
		if (basketStage !== 'Contract Accepted')
			return;
		//console.log('addDefaultEMSOEConfigs');
		var oeMap = [];

		//Changes as part of EDGE-154489 start
		//await CS.SM.getActiveSolution().then((currentSolution) => {
		let currentSolution = await CS.SM.getActiveSolution();
		//console.log('addDefaultOEConfigs ', currentSolution, EMS_COMPONENT_NAMES.solution);
		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution- EDGE-154489 Spring 20 changes
			//console.log('addDefaultOEConfigs - looking components', currentSolution);
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154489
				Object.values(currentSolution.components).forEach((comp) => {//EDGE-154489
					Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154489
						Object.values(comp.orderEnrichments).forEach((oeSchema) => {//EDGE-154489
							//Added the addition if condition for UC by Mahaboob o 27/07/2019 as UC is used across 2 solutions
							//  if (!oeSchema.name.toLowerCase().includes('numbermanagementv1') 
							//	&& !(config.name === 'Unified Communication' && oeSchema.name === 'Customer requested Dates')) {
							var found = false;
							if (config.orderEnrichmentList) {
								var oeConfig = Object.values(config.orderEnrichmentList).filter(oe => { return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId) });//EDGE-154489
								if (oeConfig && oeConfig.length > 0)
									found = true;
								//Changes as part of EDGE-154489 end here
							}
							if (!found) {

								var el = {};
								el.componentName = comp.name;
								el.configGuid = config.guid;
								//el.oeSchemaId = oeSchema.id;//EDGE-154489
								el.oeSchema = oeSchema;//EDGE-154489
								oeMap.push(el);

								//console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
							}

							//}
						});
					});
				});
			}
		}
		//}).then(() => Promise.resolve(true));
		//console.log('addDefaultOEConfigs prepared');

		/*if (oeMap.length> 0) {
			var map = [];
			map.push({});
			console.log('Adding default oe config map:',oeMap);
			for (var i=0; i< oeMap.length;i++) {
				await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
			};
		}*/

		//Changes as part of EDGE-154489 start
		if (oeMap.length > 0) {
			//let map = [];
			for (var i = 0; i < oeMap.length; i++) {
				let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
				await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
			}
		}
		//Changes as part of EDGE-154489 end here

		await initializeEMSOEConfigs();
		return Promise.resolve(true);
	}


	/**********************************************************************************************************************************************
	 * Author	   : Tihomir Baljak
	 * Method Name : initializeTIDOEConfigs
	 * Invoked When: after solution is loaded, after configuration is added
	 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
	 * Parameters  : none
	 ********************************************************************************************************************************************/
	async function initializeEMSOEConfigs() {
		//console.log('initializeOEConfigs');

		//Changes as part of EDGE-154489 start
		let currentSolution = await CS.SM.getActiveSolution();
		let Component = currentSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
		/*await CS.SM.getActiveSolution().then((solution) => {
			currentSolution = solution;
			console.log('initializeOEConfigs - getActiveSolution');
		}).then(() => Promise.resolve(true));*/
		//Changes as part of EDGE-154489 end here


		if (currentSolution) {
			//console.log('initializeOEConfigs - updating');
			if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution- EDGE-154489 Spring 20 changes
				if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154489
					for (var i = 0; i < Object.values(currentSolution.components).length; i++) {//EDGE-154489
						var comp = Object.values(currentSolution.components)[i];//EDGE-154489
						for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {//EDGE-154489
							var config = Object.values(comp.schema.configurations)[j];//EDGE-154489
							var updateMap = {};
							if (config.orderEnrichmentList) {
								for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {//EDGE-154489
									var oe = Object.values(config.orderEnrichmentList)[k];//EDGE-154489

									var basketAttribute = Object.values(oe.attributes).filter(a => {//EDGE-154489
										return a.name.toLowerCase() === 'basketid'
									});
									if (basketAttribute && basketAttribute.length > 0) {
										if (!updateMap[oe.guid])
											updateMap[oe.guid] = [];

										updateMap[oe.guid].push({
											name: basketAttribute[0].name,
											value: basketId
										});
										//console.log('Basket ID -------------' + basketId);
									}

									/** if (comp.name === TID_COMPONENT_NAMES.internetSite) {
	 
										 var funcprimarycontactAttribute = oe.attributes.filter(a => {
											 return a.name === 'Funcprimarycontact'
										 });
										 if (funcprimarycontactAttribute && funcprimarycontactAttribute.length > 0) {
											 var siteIDAttribute = config.attributes.filter(a => {
												 return a.name === 'Site ID'
											 });
											 if (siteIDAttribute && siteIDAttribute.length > 0) {
												 let inputMap = {
													 object: 'funccontact',
													 id: siteIDAttribute[0].value
												 };
												 await CS.SM.WebService.performRemoteAction('OEDataProvider', inputMap).then((values) => {
													 console.log('initializeOEConfigs - Funcprimarycontact:', values);
													 if (values && values.length > 0 && values.response[0].Id) {
														 if (!updateMap[oe.guid])
															 updateMap[oe.guid] = [];
	 
														 updateMap[oe.guid].push({
															 name: funcprimarycontactAttribute[0].name,
															 value: values.response[0].Id
														 });
													 }
												 }).then(() => Promise.resolve(true));
	 
											 }
										 }
	 
									 }**/
								}
							}
							//Changes as part of EDGE-154489 start
							if (updateMap && Object.keys(updateMap).length > 0) {
								let keys = Object.keys(updateMap);
								//console.log('initializeEMSOEConfigs keys:', keys);
								for (var h = 0; h < Object.keys(updateMap).length; h++) {
									await Component.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false)
								}

								//console.log('initializeOEConfigs updateMap:', updateMap);
								//CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
								//Changes as part of EDGE-154489 end here	
							}
						};
					};
				}
			}
		}

		return Promise.resolve(true);
	}





	async function saveSolutionEMS() {
		console.log('saveSolutionEMS');

		if (executeSaveEMS) {
			executeSaveEMS = false;
			var oeerrorcount = 0;

			/*await CS.SM.getActiveSolution().then((currentSolution) => {
				if (currentSolution.type && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
					if (currentSolution.components && currentSolution.components.length > 0) {
						currentSolution.components.forEach((comp) => {                        
							comp.schema.configurations.forEach((config) => {
								config.attributes.forEach((attr) => {
									if(basketStage === 'Contract Accepted'){
										if(((attr.name === 'Not Before CRD' || attr.name === 'Preferred CRD') && attr.value===0) || ((attr.name === 'Technicalcontactid' || attr.name === 'Primarycontactid') && attr.value === '')){
											 oeerrorcount = oeerrorcount +1;
											
											CS.SM.updateConfigurationStatus(comp.name,config.guid,false,'Error in Order Enrichment');
		
										}								
										if(attr.name === 'Not Before CRD' && attr.value !== 0 && attr.value <= Date.now()){
		
											oeerrorcount = oeerrorcount +1;
											CS.SM.updateConfigurationStatus(comp.name,config.guid,false,'Error in Order Enrichment');
										}
									}
								});
							});
						
						});
					}
				}
			});
			if(oeerrorcount >0 && !executeSaveEMS){
					CS.SM.displayMessage('Order Enrichment has errors.It can be either Mandatory fields not populated/Not before CRD is lesser than or equal to today/Preferred CRD is lesser than Not Before CRD.', 'error');
					//executeSaveEMS = true;
										return Promise.resolve(false);
			}
			else{
				saveEMS = true;
				await CS.SM.saveSolution();
				Promise.resolve(true);
			} */
			//autoSelectTMDMSUpportValues();

			saveEMS = true;

			//Changes as part of EDGE-154489 start
			//await CS.SM.saveSolution();
			let currentBasket = await CS.SM.getActiveBasket();
			currentBasket.saveSolution(solution)
				.then(updatedSolution => console.log(updatedSolution));
			//Changes as part of EDGE-154489 start

			Promise.resolve(true);
		}

	}



	/**********************************************************************************************************************************************
	 * Author	   : Venkata Ramanan G
	 * Method Name : populateRateCardinAttachmentEMS
	 * Invoked When: after solution is loaded
	 ********************************************************************************************************************************************/

	async function populateRateCardinAttachmentEMS() {
		//console.log('populateRateCardinAttachmentEMS');
		var c = 0;
		//console.log(' EMS ----Inside populateRateCardinAttachment!!!! ');
		// CS.SM.getActiveSolution();	
		if (basketStage !== 'Contract Accepted')
			return;
		var configMap = [];

		//Changes as part of EDGE-154489 start
		let currentBasket;
		let loadedSolution;

		currentBasket = await CS.SM.getActiveBasket();
		loadedSolution = await CS.SM.getActiveSolution();

		let currentSolution = await CS.SM.getActiveSolution();
		//CS.SM.getActiveSolution().then((currentSolution) => {
		//Changes as part of EDGE-154489 end

		//if(valid){
		//populatefixedvoiceratecard ();
		//valid = false;
		//console.log('populateRateCardinAttachment ', currentSolution);
		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed from currentSolution.type to currentSolution //EDGE-154489
			//console.log('addDefaultOEConfigs - looking components', currentSolution);
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154489
				Object.values(currentSolution.components).forEach((comp) => {//EDGE-154489
					if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
						if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
							let inputMap = {};
							inputMap['basketid'] = basketId;
							inputMap['Offer_Id__c'] = 'DMCAT_Offer_000854';
							inputMap['SolutionId'] = currentSolution.id;

							//Changes as part of EDGE-154489 start
							//CS.SM.WebService.performRemoteAction('TierRateCardNCSHelper', inputMap).then(
							//Changes as part of EDGE-154489 end here

							currentBasket.performRemoteAction('TierRateCardNCSHelper', inputMap).then(//EDGE-154489
								function (response) {
									if (response && response['UCRateCard'] != undefined) {
										//console.log('UCRateCard', response['UCRateCard']);
									}
								});
						}
					}
					/**else
					if(comp.name === EMS_COMPONENT_NAMES.userSupport){
							if(comp.schema.configurations && comp.schema.configurations.length>0){
								let inputMap = {};
							 inputMap['basketid'] = basketId;
							 inputMap['Offer_Id__c'] = 'DMCAT_Offer_000854';
							 inputMap['SolutionId'] = currentSolution.id;
							CS.SM.WebService.performRemoteAction('TierRateCardNCSHelper', inputMap).then(
							function (response) {                
								if (response && response['UCRateCard'] != undefined) {
									console.log('UCRateCard', response['UCRateCard']);                
								}
							});
							}
					} **/

				});
			}
			//}
		}


		//});
	}

	/*/////*/
	//EDGE-154489 commnetes EMSPlugin.buttonClickHandler
	/*EMSPlugin.buttonClickHandler = async function (buttonSettings) {
		console.log('EMS buttonClickHandler: id=', buttonSettings.id, buttonSettings);
		var url= '';
		var redirectURI = '/apex/';
		//Added check below to address URL issue for PRM User
		if (CommunitySiteId) {
			url = window.location.href;
			if (url.includes('partners.enterprise.telstra.com.au'))
				redirectURI = '/s/sfdcpage/%2Fapex%2F';
			else
				redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
		}
		url = redirectURI;
		
		
	   if (buttonSettings.id === 'orderEnrichment') {
			if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
				setTimeout(createOEUI, 200);
				return Promise.resolve('null');
			} else {
				CS.SM.displayMessage('Can not do order enrichment when basket is in ' + basketStage + ' stage', 'info');
				return Promise.resolve(true);
			}
		}
		if (buttonSettings.id === 'TenancyButton') {

			if (Utils.isCommNegotiationAllowed()){ // Dont allow to open the Tenancy Page when the Basket stage is not commercial config

				//var accountId = '';
				var optyId = '';

				console.log('basketId', basketId);
				console.log('accountId', accountId);
				
				var tenancyTypeProdIdList=['DMCAT_ProductSpecification_000537'];

				if (communitySiteId) {
					url = url + encodeURIComponent('c__existingTenancy?basketId=' + basketId + '&accountId=' + accountId + '&filterByTenancyType=' + 'true'+ '&tenancyTypeProdIdList='+tenancyTypeProdIdList+'?isdtp=mn');
				} else {
					url = url + 'c__existingTenancy?basketId=' + basketId + '&accountId=' + accountId + '&filterByTenancyType=' + 'true'+ '&tenancyTypeProdIdList='+tenancyTypeProdIdList;
				}
				console.log('url: ', url);
				return Promise.resolve(url);
			}else 
			{
			CS.SM.displayMessage('Can not Save Tenancies when basket is in ' + basketStage + ' stage', 'info');
				return Promise.resolve(true);
		}	
			
		} // end (buttonSettings.id === 'saveTenantMSbutton') 
	}*/

	async function EMSPlugin_handleIframeMessage(e) {//made it async
	console.log('---inside EMSPlugin_handleIframeMessage--'+e);
		//Added by Pooja start
		let product = null;
		//console.log('trying to get solution');
		try {
			product = await CS.SM.getActiveSolution();
		}
		catch (e) {
			//console.log('Product is ' + product);
		}

		if (product == null) return Promise.resolve(true);
		//Added by Pooja end 

		//console.log('EMSPlugin_handleIframeMessage:', e);

		if (!e.data || !e.data['command'] || e.data['command'] !== 'ADDRESS' || (e.data['caller'] && e.data['caller'] === EMS_COMPONENT_NAMES.solution)) {
			sessionStorage.removeItem("close");
			sessionStorage.removeItem("payload");
		}

		var message = {};
		message = e['data'];
		messgae = message['data'];
		//console.log('message  Data 4--->'+message.data['data']);
		//console.log('message  Data Array--->' + messgae);
		if (message.command && message.command === 'TenancyIds') {

			if (message.caller && message.caller !== 'Managed Services') {
				return;
			}
			if (message) {
				//console.log('Inside EMSPlugin_handleIframeMessage Data is --->'+message.data['data']);
				//console.log('Inside EMSPlugin_handleIframeMessage Data is --->' + message['data']);
				updateSelectedTenancyList(message['data']);
			}


		}


		//Uncommented by Purushottam as a part of EDGE -145320 || Start
		if (e.data === 'close') {
			//console.log('Closing modal window');
			try {
				var d = document.getElementsByClassName('mat-dialog-container');
				if (d) {
					for (var i = 0; i < d.length; i++) {
						d[i].parentElement.removeChild(d[i]);
					}
				}
				var el = document.getElementsByClassName('cdk-global-overlay-wrapper');
				if (el) {
					for (var i = 0; i < el.length; i++) {
						el[i].parentNode.removeChild(el[i]);
					}
				}
			} catch (err) {
				//console.log(err);
			}
		}
		//Uncommented by Purushottam as a part of EDGE -145320 || End


	}

	/* function to update tenancyid attribute on solution level */
	async function updateSelectedTenancyList(data) {
		console.log('inside updateSelectedTenancyList'+data);
		//var updateMap = [];//EDGE-154489
		let updateMap = {};//EDGE-154489
		//--DPG-2647 -- Krunal Taak -- start
		var t1 =''; 
		var t2 ='';
		var configGuid = '';
		var tenancyIds = '';
		var tenancyIdss = '';
		//--DPG-2647 -- Krunal Taak -- end

		//CS.SM.getActiveSolution().then((solution) => {//EDGE-154489
		let solution = await CS.SM.getActiveSolution();//EDGE-154489
		let component = solution.getComponentByName(EMS_COMPONENT_NAMES.solution);//EDGE-154489
		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed solution.type to solution -EDGE-154489
			if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {//EDGE-154489
				//Object.values(solution.schema.configurations).forEach((config) => {//EDGE-154489
				for (const config of Object.values(solution.schema.configurations)) {//EDGE-154489
					tenancyIds = Object.values(config.attributes).filter(a => {//EDGE-154489
						return a.name === 'TenancyID'
					});
					t1 = tenancyIds[0].value; //--DPG-2647
					console.log('-----tenancyIds----'+tenancyIds[0].name+'--'+tenancyIds[0].value +'--t1--'+t1);
					//Changes as part of EDGE-154489 start
					/*updateMap[config.guid] = [{
						name: "TenancyId",
						value: {
							value: data.toString(),
							displayValue: data.toString(),
							showInUi: false,
							readOnly: false
						}
					}];*/

					updateMap[config.guid] = [];
					updateMap[config.guid].push({
						name: "TenancyId",
						value: data.toString(),
						displayValue: data.toString(),
						showInUi: false,
						readOnly: false
					});
					if (updateMap && Object.keys(updateMap).length > 0) {
						keys = Object.keys(updateMap);
					    console.log('inside updateMap--');
						for (let i = 0; i < keys.length; i++) {
							console.log('inside For--');
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
					}
					//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true);
					//Changes as part of EDGE-154489 end
				};
				//--DPG-2647 -- Start -- Krunal Taak
				if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {//EDGE-154489
				//Object.values(solution.schema.configurations).forEach((config) => {//EDGE-154489
					for (const config of Object.values(solution.schema.configurations)) {//EDGE-154489
						configGuid = config.guid;					
						tenancyIdss = Object.values(config.attributes).filter(a => {//EDGE-154489
							return a.name === 'TenancyID'

						});
						t2 = tenancyIdss[0].value;
					}
					console.log('-----tenancyIds----'+tenancyIdss[0].name+'--'+tenancyIdss[0].value +'---'+basketChangeType);

					let currentActiveBasket = await CS.SM.getActiveBasket();
					let profServCheck = 'Absent';
					let tmdmVMWareCheck = 'Absent';

					if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
						if (currentActiveBasket.solutions && Object.values(currentActiveBasket.solutions).length > 0) {
							for (const basketSol of Object.values(currentActiveBasket.solutions)) {
								if (basketSol.name === 'T-MDM Professional Services') {
									profServCheck = 'PFPresent';
								}
								else if (basketSol.name === 'Telstra Mobile Device Management - VMware') {
									tmdmVMWareCheck = 'TMDMPresent';
								}
								else{}
							}
						}
					}
					//&& basketChangeType != 'Change Solution')
					console.log('-1----t1----'+t1 +'--- t2 --'+t2);
					if((t2 === '' || t2 === null) && basketChangeType != 'Change Solution'){
						console.log('--in t validationActiveManagedServiceSubscriptionCheck--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
					else if (tenancyIdss[0].name === 'TenancyID' && (t2 != '' || t2 != null)  && tmdmVMWareCheck === 'Absent' && basketChangeType != 'Change Solution')  {
						console.log('---inside validationActiveManagedServiceSubscriptionCheck---');
						validationActiveManagedServiceSubscriptionCheck(tenancyIdss[0],component,configGuid);
					}
					else{}
					
					console.log('-----profServCheck----'+profServCheck +'--- basketChangeType --'+basketChangeType);
					console.log('-----t1----'+t1 +'--- t2 --'+t2);
					if((t1 === '' || t1 === null || t2 === '' || t2 === null)&& basketChangeType === 'Change Solution'){
						console.log('--in t if--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
					else if(((t1 != null || t1 != '') || (t2 != null || t2 != '')) &&  (t1 != t2) && basketChangeType === 'Change Solution' && profServCheck === 'Absent'){
						console.log('--in t else if--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = false;
						confg.statusMessage = 'Please add Professional Services to the basket';
					}
					else{
						console.log('--in t else--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
				}
				//--DPG-2647 -- End -- Krunal Taak
				
			}
			if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154489
				//Object.values(solution.components).forEach((comp) => {//EDGE-154489
				for (const comp of Object.values(solution.components)) {//EDGE-154489
					if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
						if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
							//Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154489
							for (const config of Object.values(comp.schema.configurations)) {//EDGE-154489
								if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
									//console.log('inside updateSelectedTenancyList mobilityPlatformMgmt--->' + data);
									tenancyIds = Object.values(config.attributes).filter(a => {//EDGE-154489
										return a.name === 'TenancyId'
									});
									//Changes as part of EDGE-154489 start
									/*updateMap[config.guid] = [{
										name: "TenancyId",
										value: {
											value: data.toString(),
											displayValue: data.toString(),
											showInUi: false,
											readOnly: false
										}
									}];*/


									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: "TenancyId",
										value: data.toString(),
										displayValue: data.toString(),
										showInUi: false,
										readOnly: false
									});

									if (updateMap && Object.keys(updateMap).length > 0) {
										keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
										}
									}
									//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true).then(component => console.log('updateSelectedTenancyList Attribute update', component));
									//Changes as part of EDGE-154489 end
								}
							};
						}
					}
					if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
						if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
							//Object.values(comp.schema.configurations).forEach((config) => {
							for (const config of Object.values(comp.schema.configurations)) {//EDGE-154489
								if (config.attributes && Object.values(config.attributes).length > 0) {	//EDGE-154489
									//console.log('inside updateSelectedTenancyList userSupport--->' + data);
									tenancyIds = Object.values(config.attributes).filter(a => {//EDGE-154489
										return a.name === 'TenancyId'
									});
									//Changes as part of EDGE-154489 start
									/*updateMap[config.guid] = [{
										name: "TenancyId",
										value: {
											value: data.toString(),
											displayValue: data.toString(),
											showInUi: false,
											readOnly: false
										}
									}];*/


									updateMap[config.guid] = [];
									updateMap[config.guid].push({
										name: "TenancyId",
										value: data.toString(),
										displayValue: data.toString(),
										showInUi: false,
										readOnly: false
									});
									if (updateMap && Object.keys(updateMap).length > 0) {
										keys = Object.keys(updateMap);

										for (let i = 0; i < keys.length; i++) {
											await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
										}
									}

									//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true).then(component => console.log('updateSelectedTenancyList Attribute update', component));
									//Changes as part of EDGE-154489 end
								}
							};
						}
					}

				};

			}
		}
		//});//Changes as part of EDGE-154489 end here
	}

	/***
	Author : Krunal Taak 
	DPG-2577 : Validate mandatory one of MPM or US
	**/
	async function validateMpmUsValues() {
		console.log('Inside validateMpmUsValues');
		let solution = await CS.SM.getActiveSolution();
		let componentUpdate = await solution.getComponentByName(EMS_COMPONENT_NAMES.solution);
		var MPMtechSupport;
		var MPMfeatureLevel;
		var UStechSupport;
		var USfeatureLevel;
		let USmandatory =true;
		let MPMmandatory =true;
		var MPMComponentGuid;
		var USComponentGuid;
		var updateMap = {};
		console.log('Inside validateMpmUsValues '+'USmandatory'+USmandatory+'MPMmandatory'+MPMmandatory);

		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
				if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
					if (solution.components && Object.values(solution.components).length > 0) {
						for (const comp of Object.values(solution.components)) {
							if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
								if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									for (const config of Object.values(comp.schema.configurations)) {
										MPMComponentGuid = config.guid;
										console.log('----MPMComponentGuid----'+MPMComponentGuid);
										if (config.attributes && Object.values(config.attributes).length > 0) {
											Object.values(config.attributes).forEach((attr) => {
												if (attr.name === 'TechnicalSupport')
													MPMtechSupport = attr.value;
												if (attr.name === 'FeatureLevel' )
													MPMfeatureLevel = attr.value;
											});
										}
										console.log('inside mobilityPlatformMgmt---> MPMtechSupport -->' + MPMtechSupport+ '-- MPMfeatureLevel -->' + MPMfeatureLevel);
									};
								}
								
							}
							
							else if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
								if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									for (const config of Object.values(comp.schema.configurations)) {
										USComponentGuid = config.guid;
										console.log('----USComponentGuid----'+USComponentGuid);
										if (config.attributes && Object.values(config.attributes).length > 0) {
											Object.values(config.attributes).forEach((attr) => {
												if (attr.name === 'TechnicalSupport')
													UStechSupport = attr.value;
												if (attr.name === 'FeatureLevel')
													USfeatureLevel = attr.value;
											});
										}
										console.log('inside userSupport---> UStechSupport -->' + UStechSupport+ '-- USfeatureLevel -->' + USfeatureLevel);
									};
								}
							}
						};
						
						
						if (MPMtechSupport === null || MPMtechSupport === '' || MPMfeatureLevel === null || MPMfeatureLevel === '' ) {
							console.log('inside MPM if -- MPMmandatory -- '+MPMmandatory);
							MPMmandatory = true;
							hideShowAttributes(componentUpdate,USComponentGuid,true,['TechnicalSupport','FeatureLevel']);
						}
						else{
							console.log('inside MPM else 1 -- MPMmandatory -- '+MPMmandatory);
							MPMmandatory = false;
							hideShowAttributes(componentUpdate,USComponentGuid,false,['TechnicalSupport','FeatureLevel']);
							console.log('inside MPM else 2 -- MPMmandatory -- '+MPMmandatory);
						}
						
						if (UStechSupport === null || UStechSupport === '' || USfeatureLevel === null || USfeatureLevel === '' ) {
							console.log('inside userSupport if  -- USmandatory -- ' + USmandatory);
							USmandatory = true;
							hideShowAttributes(componentUpdate,MPMComponentGuid,true,['TechnicalSupport','FeatureLevel']);
						}
						else{
							console.log('inside userSupport else 1 -- USmandatory -- '+USmandatory);
							USmandatory = false;
							hideShowAttributes(componentUpdate,MPMComponentGuid,false,['TechnicalSupport','FeatureLevel']);
							console.log('inside userSupport else 2 -- USmandatory -- '+USmandatory);
						}
					}
				}
			}
		
		return Promise.resolve(true);
	}

	/***
	Author : Krunal Taak 
	DPG-2577 : for hide show attributes , called from validateMpmUsValues()
	Param : ComponentId, guid, isRequiredflag(true/false), AttributeArray[string]
	**/
	hideShowAttributes = async function (component, guid, isRequired, attributeArray) {
		console.log('inside hideShowAttributes'+component,guid,isRequired, attributeArray);
		var obj;
		var updateMap = {};
		updateMap[guid] = [];
		attributeArray.forEach(attr => {
		obj = {

			name: attr,
			showInUi: true,
			required: isRequired

		}	
		updateMap[guid].push(obj);
		});

		console.log(updateMap);
		if (updateMap && Object.keys(updateMap).length > 0) {
			console.log('inside US update3');
			keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
		}
	}


	/***

	Auto select EU technical SUpport if the PM Technical SUpport is 24x7
	//Updated for edge-117563 by shubhi
	**/
	async function autoSelectTMDMSUpportValues() {
		//console.log('Inside autoSelectTMDMSUpportValues');
		//Changes as part of EDGE-154489 start
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(EMS_COMPONENT_NAMES.solution);//EDGE-154489
		//await CS.SM.getActiveSolution().then((solution) => {
		//Changes as part of EDGE-154489 end

		var pmTechnicalSupport;
		var pmTechnicalSupportDispl;
		var pmTechnicalSupportval;
		var updateMap = {};//EDGE-154489
		//console.log('Inside autoSelectTMDMSUpportValues');
		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {//Replaced soltion.type to solution EDGE-154489
			if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {//EDGE-154489
				if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154489
					//Object.values(solution.components).forEach((comp) => {
					for (const comp of Object.values(solution.components)) {//EDGE-154489
						if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
							if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
								//Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154489
								for (const config of Object.values(comp.schema.configurations)) {//EDGE-154489
									if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
										pmTechnicalSupport = Object.values(config.attributes).filter(obj => {//EDGE-154489
											return obj.name === 'TechnicalSupport'
										});
									}
									//console.log('inside updateSelectedTenancyList mobilityPlatformMgmt--->' + pmTechnicalSupport[0].displayValue);
									//});
								};
							}
							if (pmTechnicalSupport && pmTechnicalSupport.length > 0) {
								pmTechnicalSupportDispl = pmTechnicalSupport[0].displayValue;
								pmTechnicalSupportval = pmTechnicalSupport[0].value;
							}
						}
						if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
							if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
								//Object.values(comp.schema.configurations).forEach((config) => {
								for (const config of Object.values(comp.schema.configurations)) {//EDGE-154489
									if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154489
										//console.log('inside updateSelectedTenancyList userSupport--->'+data);

										var euTechnicalSupport = Object.values(config.attributes).filter(obj => {//EDGE-154489
											return obj.name === 'TechnicalSupport'
										});

										//console.log('inside autoSelectTMDMSUpportValues userSupport--->' + pmTechnicalSupportDispl);
										if (pmTechnicalSupportDispl === '24x7') {
											//Changes as part of EDGE-154489 start
											/*updateMap[config.guid] = [{
												name: "TechnicalSupport",
												value: {
													showInUi: true,
													displayValue: pmTechnicalSupportDispl,
													readOnly: true,
													value: pmTechnicalSupportval
												}
											}];*/


											updateMap[config.guid] = [];
											updateMap[config.guid].push({
												name: "TechnicalSupport",
												showInUi: true,
												displayValue: pmTechnicalSupportDispl,
												readOnly: true,
												value: pmTechnicalSupportval
											});
											//console.log(updateMap);

										}
										else {
											//console.log('Inside else automated selection');
											/*updateMap[config.guid] = [{
												name: "TechnicalSupport",
												value: {
													readOnly: false,
													showInUi: true
												}
											}];*/


											updateMap[config.guid] = [];
											updateMap[config.guid].push({
												name: "TechnicalSupport",
												readOnly: false,
												showInUi: true
											});
										}
										if (updateMap && Object.keys(updateMap).length > 0) {
											keys = Object.keys(updateMap);
											for (let i = 0; i < keys.length; i++) {
												await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
											}
										}
										//CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then((config) => {console.log('autoSelectTMDMSUpportValues finished: ',config)});	
										//Changes as part of EDGE-154489 end
									}
								};
							}
						}

					};

				}
			}
		}//then(() => Promise.resolve(true));
		return Promise.resolve(true);
	}


	/*********************************
		 * Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey
		 * Invokes on load & after save events on Mac basket
		 *********************************/
	async function setchangeTypevisibility(product) {
		//console.log('setchangeTypevisibility');
		var updateSolnMap = {};
		//Changes as part of EDGE-154489 start
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(EMS_COMPONENT_NAMES.solution);
		//Changes as part of EDGE-154489 end
		// Aditya: Edge:142084, Enable New Solution in MAC Basket
		if (window.BasketChange === 'Change Solution') {

			//console.log('addAllEMSSubscriptionstoMAC', product);
			if (product.schema.configurations) {
				Object.values(product.schema.configurations).forEach(config => {
					//Changes as part of EDGE-154489 start
					/*updateSolnMap[config.guid] = [{
						name: "ChangeType",
						value: {
							showInUi: true
						}
					}];*/

					updateSolnMap[config.guid] = [];
					updateSolnMap[config.guid].push({
						name: "ChangeType",
						showInUi: true
					});
				});
			}
			//Changes as part of EDGE-154489 start
			if (updateSolnMap && Object.keys(updateSolnMap).length > 0) {
				keys = Object.keys(updateSolnMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateSolnMap[keys[i]], true);
				}
			}
			//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateSolnMap, true);

			//Changes as part of EDGE-154489 end here

			return Promise.resolve(true);


		} else
			return Promise.resolve(true);
	}
	/*********************************
		 * Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey
		 * Invokes on update of ChangeType at Main solution & invokes the function to add all subscriptions of component to the MAC basket.
		 *********************************/
	async function addAllEMSSubscriptionstoMAC() {
		//console.log('addAllEMSSubscriptionstoMAC', basketChangeType);
		var solutionId;
		var EMSUserSupportGUID = [];
		var UsertobeaddedtoMAC = false;
		var MBPltfrmtobeaddedtoMAC = false;
		var MBPltfrmGUID = [];
		// Aditya: Edge:142084, Enable New Solution in MAC Basket
		if (window.BasketChange === 'Change Solution') {

			//Changes as part of EDGE-154489 start
			let product = await CS.SM.getActiveSolution();
			//await CS.SM.getActiveSolution().then((product) => {

			//console.log('addAllEMSSubscriptionstoMAC', product);
			if (product && product.name.includes(EMS_COMPONENT_NAMES.solution)) {//changed product.type to product -EDGE-154489
				//console.log('addAllEMSSubscriptionstoMAC SolutionId', product.id);
				solutionId = product.id;
				if (product.components && Object.values(product.components).length > 0) {//EDGE-154489
					Object.values(product.components).forEach((comp) => {//EDGE-154489
						if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
							//console.log('User support', comp);
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
								Object.values(comp.schema.configurations).forEach((userSupportconfig) => {//EDGE-154489
									//if (!userSupportconfig.id) {
									EMSUserSupportGUID = userSupportconfig.guid;
									UsertobeaddedtoMAC = userSupportconfig.disabled;
									//}
								});
							}
						}
						if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
							//console.log('Mobility Platform Management', comp);
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154489
								Object.values(comp.schema.configurations).forEach((MBPltfrmconfig) => {//EDGE-154489
									// if (!MBPltfrmconfig.id) {
									MBPltfrmGUID = MBPltfrmconfig.guid;
									MBPltfrmtobeaddedtoMAC = MBPltfrmconfig.disabled;
									// }
								});
							}
						}
					});
				}

			}
			console.log('User support GUID=', EMSUserSupportGUID);

			//});
			if (MBPltfrmGUID && MBPltfrmtobeaddedtoMAC) {
				// MobPlatformAdded = true;
				console.log('Mobility Platform Management addConfigurationsToMAC ', MobPlatformAdded);
				await CS.SM.addConfigurationsToMAC(solutionId, [MBPltfrmGUID], EMS_COMPONENT_NAMES.mobilityPlatformMgmt).then((solution) => {
					MobPlatformAdded = true;
				});;
			}
			if (MBPltfrmGUID) {
				//Changes as part of EDGE-154495 start
				/*var updateMapPltfrm = {};
				updateMapPltfrm[MBPltfrmGUID] = [{
					name: "ChangeType",
					value: {
						value: changetypeMACsolution,
						readOnly: true,
						showInUi: true
					}
				}];*/

				let component = await product.getComponentByName(EMS_COMPONENT_NAMES.mobilityPlatformMgmt);
				let updateMapPltfrm = {};
				updateMapPltfrm[MBPltfrmGUID] = [];
				updateMapPltfrm[MBPltfrmGUID].push({
					name: "ChangeType",
					value: changetypeMACsolution,
					readOnly: true,
					showInUi: true
				});


				if (updateMapPltfrm && Object.keys(updateMapPltfrm).length > 0) {
					keys = Object.keys(updateMapPltfrm);

					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateMapPltfrm[keys[i]], true);
					}
				}
				//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.mobilityPlatformMgmt, updateMapPltfrm, true);
				//Changes as part of EDGE-154495 end
			}
			if (EMSUserSupportGUID && UsertobeaddedtoMAC) {

				console.log('User support addConfigurationsToMAC ', EMSUserSupportGUID, UserAdded);
				await CS.SM.addConfigurationsToMAC(solutionId, [EMSUserSupportGUID], EMS_COMPONENT_NAMES.userSupport).then((solution) => {
					UserAdded = true;
				});
			}
			console.log('Mobility Platform Management=', MBPltfrmGUID);

			if (EMSUserSupportGUID) {
				//Changes as part of EDGE-154495 start
				/*var updateMapUser = {};
				updateMapUser[EMSUserSupportGUID] = [{
					name: "ChangeType",
					value: {
						value: changetypeMACsolution,
						readOnly: true,
						showInUi: true
					}
				}];*/

				let component = await product.getComponentByName(EMS_COMPONENT_NAMES.userSupport);
				let updateMapUser = {};
				updateMapUser[EMSUserSupportGUID] = [];
				updateMapUser[EMSUserSupportGUID].push({
					name: "ChangeType",
					value: changetypeMACsolution,
					readOnly: true,
					showInUi: true
				});

				if (updateMapUser && Object.keys(updateMapUser).length > 0) {
					keys = Object.keys(updateMapUser);

					for (let i = 0; i < keys.length; i++) {
						await component.updateConfigurationAttribute(keys[i], updateMapUser[keys[i]], true);
					}
				}
				//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.userSupport, updateMapUser, true);
				//Changes as part of EDGE-154489 end
			}
			return Promise.resolve(true);

		}
		else
			return Promise.resolve(true);
	}

	/* 	
		Added as part of EDGE-149887 
		This method updates the Solution Name based on Offer Name if User didnt provide any input
		Modifications :
		1. Gnana - EDGE-164917 : Changed logic to get Display Value for OfferName instead of Value which was giving Id
	*/
	async function updateSolutionName_EMS() {
		let configGuid;//EDGE-154489
		let solution = await CS.SM.getActiveSolution();//EDGE-154489
		let Component = solution.getComponentByName(EMS_COMPONENT_NAMES.solution);//EDGE-154489
		var listOfAttributes = ['Solution Name', 'OfferName', 'GUID'];
		var listOfAttrToGetDispValues = ['OfferName'], attrValuesMap2 = {};
		attrValuesMap = {};
		attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, EMS_COMPONENT_NAMES.solution);
		attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, EMS_COMPONENT_NAMES.solution);
		console.log('attrValuesMap...' + attrValuesMap);
		if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_EMS) {
			let updateConfigMap = {};
			//Changes as part of EDGE-154489 start
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
				//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateConfigMap, true);	
				if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					keys = Object.keys(updateConfigMap);
					for (let i = 0; i < keys.length; i++) {
						await Component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					}
				}
				//Changes as part of EDGE-154489 end
			}
		}
	}

	/****************************************************************************************************
	* Author	: Krunal Taak
	* Method Name : validation Active Managed Service Subscription Check
	* Defect/US # : DPG-2577
	* Invoked When: On attribute update
	* Description :validation Active Managed Service Subscription Check
	****************************************************************************************************/
	async function validationActiveManagedServiceSubscriptionCheck(tenancyId,component,guid){ //Krunal
		let updateMap =  new Map();
		let componentMapNew =   new Map();
		var tenancyInfo="";
		let inputMap = {};

		let config = await component.getConfiguration(guid);
		inputMap['tenancyId']=tenancyId.value;
		console.log('inputMaP',inputMap);
		let currentBasket;
		console.log('0');
		currentBasket = await CS.SM.getActiveBasket();
		console.log('1');
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			console.log('2');
			tenancyInfo = JSON.parse(result["tenancyId"]);	
			console.log('the tenancyInfo is==>'+tenancyInfo);
			return Promise.resolve(true);
		});
			
		if(tenancyInfo===true)
		{
			console.log('In true');
			componentMapNew.set('CheckTenancyError',true);
			config.status = false;
			config.statusMessage = 'Selected tenancy is already tagged to Active Managed Service, Please select a different tenancy or add a new tenancy';
		}
		else
		{
			console.log('In false');
			componentMapNew.set('CheckTenancyError',false);
		}
		if(componentMapNew && componentMapNew.size>0){
			updateMap.set(guid,componentMapNew);
			CommonUtills.UpdateValueForSolution(component.name,updateMap)
		}
	}

	/****************************************************************************************************
	* Author	: Krunal Taak
	* Method Name : validation Active Managed Service Subscription Check - On Load
	* Defect/US # : DPG-2577
	* Invoked When: Onload and Aftersave
	* Description :validation Active Managed Service Subscription Check
	****************************************************************************************************/
	async function validationErrorActiveManagedServiceSubscriptionCheck(){ //Krunal
		let solution = await CS.SM.getActiveSolution();
		if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
				Object.values(solution.schema.configurations).forEach((subsConfig) => {
						var checkTenancy = Object.values(subsConfig.attributes).filter(att => {
						return att.name === 'CheckTenancyError'
					});
					if(checkTenancy[0].value===true){
						subsConfig.status = false;
						subsConfig.statusMessage = 'Selected tenancy is already tagged to Active Managed Service, Please select a different tenancy or add a new tenancy';
					}
					else{
						subsConfig.status = true;
						subsConfig.statusMessage = '';
					}
				});
			}
		}		
	}
			
		 /****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : EMSPlugin_UpdateMainSolutionChangeTypeVisibility
		 * Defect/US # : DPG-1914
		 * Invoked When: On Solution Load
		 * Description : For Setting Visibility 
		 ************************************************************************************************/
		EMSPlugin_UpdateMainSolutionChangeTypeVisibility = async function(solution) { //krunal
		if (basketChangeType !== 'Change Solution') {
			return;
		}
		//Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- START
		var chtype; 
				
		//if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			for (const config of Object.values(solution.schema.configurations)) {
				chtype = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
			}
			}
		//}
		
		console.log('--changeType--'+chtype[0].value);
		
		if(chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New' ){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
				{name: 'Space2', showInUi: false}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true).catch((e) => Promise.resolve(true)); //Krunal
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if(chtype[0].value === 'Cancel'){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: true},
				{name: 'DisconnectionDate', showInUi: true},
				{name: 'Space1', showInUi: false},
				{name: 'Space2', showInUi: false}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, false);
			//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true).catch((e) => Promise.resolve(true)); //Krunal
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if(chtype[0].value === 'Modify'){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
				{name: 'Space2', showInUi: false}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//CS.SM.updateConfigurationAttribute(EMS_COMPONENT_NAMES.solution, updateMap, true).catch((e) => Promise.resolve(true)); //Krunal
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(EMS_COMPONENT_NAMES.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		//Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- END
	}

	   /****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : EMSPlugin_updateAttributeVisiblity
		 * Defect/US # : DPG-1914
		 * Invoked When: On Attribute Update
		 * Description : For Setting Visibility 
		 ************************************************************************************************/
		EMSPlugin_updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) { 
		console.log('inside EMSPlugin_updateAttributeVisiblity',attributeName, componentName, guid, isReadOnly, isVisible, isRequired);
		let updateMap = {};
		updateMap[guid] = [];

		updateMap[guid].push(
		{
			name: attributeName,
			// value: {
				readOnly: isReadOnly,
				showInUi: isVisible,
				required: isRequired
			// }
		});

		//CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName); 
		//const config = await component.updateConfigurationAttribute(guid, updateMap, true); 
		/*if(component && component != null && component != undefined ) {
			let keys = Object.keys(updateMap);
			console.log('---updateMap---'+updateMap);
			for (let i = 0; i < keys.length; i++) {
				console.log('---keys[i]---'+keys[i]+'---updateMap[keys[i]]---'+updateMap[keys[i]]);
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
			}
		}
		else 
			console.log('component not found with name ', componentName);*/
		  console.log('updateMap'+updateMap);  
		  
		 var complock = component.commercialLock;
									if(complock) component.lock('Commercial', false);
									let keys = Object.keys(updateMap);
									for (let i = 0; i < keys.length; i++) {
										await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
									}
									if (complock) component.lock('Commercial', true);
		/*							
		var complock = component.commercialLock;
			if (complock){	
			console.log('complock1'+complock);
				component.lock('Commercial', false);
			console.log('complock2'+complock);
			}
			const config = await component.updateConfigurationAttribute(guid, updateMap[guid], true);
			if (complock){
				console.log('complock3'+complock);
				component.lock('Commercial', true);
				console.log('complock4'+complock);
			}*/
		return Promise.resolve(true);
	} 
		
		 /****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : EMSPlugin_UpdateCancellationAttributes
		 * Defect/US # : DPG-1914
		 * Invoked When: On Attribute Update
		 * Description : For Setting Visibility 
		 ************************************************************************************************/
		EMSPlugin_UpdateCancellationAttributes = function(componentName, guid, changeTypeValue) { 

			if (changeTypeValue === 'Cancel' ) {
				EMSPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, true, true);
				EMSPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, true, false);
			}
			//--DPG-2647 -- Krunal Taak -- Reused for Modify - START
			if (changeTypeValue === 'Modify' ) {	
				console.log('---1---');	
				EMSPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
				EMSPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);	
			}
			
			if (changeTypeValue === '') {
				EMSPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
				EMSPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
			}
			//--DPG-2647 -- Krunal Taak -- Reused for Modify - END
		}
		
		 /****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : EMSPlugin_validateDisconnectionDate
		 * Defect/US # : DPG-1914
		 * Invoked When: On Disconnection Date Update
		 * Description : For formatting of the Disconnection Date
		 ************************************************************************************************/
		EMSPlugin_validateDisconnectionDate = async function(componentName, guid, newValue) { //Krunal
			let today = new Date();
			let attDate = new Date(newValue);
			today.setHours(0, 0, 0, 0);
			attDate.setHours(0, 0, 0, 0);
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(componentName); //PD
			let config = await component.getConfiguration(guid);//PD 
			
			if (attDate <= today) {
				CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
				//CS.SM.updateConfigurationStatus(componentName, guid, false, 'Disconnection date should be greater than today!');
				config.status = false;
				config.statusMessage = 'Disconnection date should be greater than today!';
			} else {
				//CS.SM.updateConfigurationStatus(componentName, guid, true, '');
				config.status = true;
				config.statusMessage = '';
			}
		}
		
		/****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : checkConfigurationSubscriptionsForMS
		 * Defect/US # : DPG-1914
		 * Invoked When: Raised MACD on Active Subscription
		 * Description :Update the Change Type of MS to Cancel
		 ************************************************************************************************/
		checkConfigurationSubscriptionsForMS = async function(hookname) { 
			console.log('checkConfigurationSubscriptionsForMS --> hookname'+hookname);
			var solutionComponent = false;
			let solution = await CS.SM.getActiveSolution();
				if (solution.componentType && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
					if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
						solutionComponent = true;
						checkConfigurationSubscriptionsForMSForEachComponent(solution, solutionComponent, hookname, solution);
					}
					if (solution.components && Object.values(solution.components).length > 0) {
						Object.values(solution.components).forEach((comp) => {
							solutionComponent = false;
							checkConfigurationSubscriptionsForMSForEachComponent(comp, solutionComponent, hookname, solution);
						});
					}
				}
			return Promise.resolve(true);
		}

	/****************************************************************************************************
		 * Author	: Monali Mukherjee
		 * Method Name : checkConfigurationSubscriptionsForMSForEachComponent
		 * Defect/US # : DPG-2648
		 * Invoked When: Raised MACD on Active Subscription
		 * Description :Update the Change Type of MS to Cancel
		 ************************************************************************************************/
		async function checkConfigurationSubscriptionsForMSForEachComponent(comp, solutionComponent, hookname, solution) { //Krunal
			console.log('checkConfigurationSubscriptionsForMSForEachComponent', comp, solutionComponent, hookname);
			//let activeSolution = await CS.SM.getActiveSolution();
			var componentMap = {};
			var updateMap = {};
			var ComName = comp.name;
			console.log('Cmp Map --->', componentMap , ComName);
			var optionValues = {};
			if (comp.name == EMS_COMPONENT_NAMES.solution ){
				console.log('Inside comp.name--->');
				optionValues = [{
					"value": "Cancel",
					"label": "Cancel"
				},
				{
					"value": "Modify",
					"label": "Modify"
				}];
			}
			if (solutionComponent) {
				//var cta = comp.schema.configurations[0].attributes.filter(a => {
				//var cta = Object.values(comp.schema.configurations[0].attributes).filter(a => {
				//	return a.name === 'ChangeType'
				//});

				var cta = '';
				if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (const config of Object.values(comp.schema.configurations)) {
						 cta = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType'
						});
					}
					}
				
				componentMap[comp.name] = [];
				componentMap[comp.name].push({
					//'id': comp.schema.configurations[0].replacedConfigId,
					'id': Object.values(comp.schema.configurations)[0].replacedConfigId,
					//'guid': comp.schema.configurations[0].guid,
					'guid': Object.values(comp.schema.configurations)[0].guid,
					'ChangeTypeValue': cta[0].value
				});
		
			} //else if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
				else if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				console.log('Cmp Map --->', componentMap);
				//comp.schema.configurations.forEach((config) => {
				Object.values(comp.schema.configurations).forEach((config) => {
					if (config.replacedConfigId || config.id) {
						//var cta = config.attributes.filter(a => {
						var cta = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType'
						});
						if (cta && cta.length > 0) {
							console.log('Cmp Map --->', componentMap);
		
							if (!componentMap[comp.name])
								componentMap[comp.name] = [];
		
							if (config.replacedConfigId)
								componentMap[comp.name].push({
									'id': config.replacedConfigId,
									'guid': config.guid,
									'ChangeTypeValue': cta[0].value
								});
							else
								componentMap[comp.name].push({
									'id': config.id,
									'guid': config.guid,
									'ChangeTypeValue': cta[0].value
								});
		
						}
					}
				});
			}
			console.log('Cmp Map --->', componentMap);
			if (Object.keys(componentMap).length > 0) {
				var parameter = '';
				Object.keys(componentMap).forEach(key => {
					if (parameter) {
						parameter = parameter + ',';
					}
					parameter = parameter + componentMap[key].map(e => e.id).join();
					console.log('--parameter--'+parameter);
				});
		
		
				let inputMap = {};
				inputMap['GetSubscriptionForConfiguration'] = parameter;
				console.log('GetSubscriptionForConfiguration: ', inputMap);
				var statuses;
				
				let currentBasket;
				currentBasket = await CS.SM.getActiveBasket();
				//await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
					console.log('GetSubscriptionForConfiguration result:', values);
					if (values['GetSubscriptionForConfiguration'])
						statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
				});
		
				console.log('checkConfigurationSubscriptionsForEMS statuses;', statuses);
				if (statuses) {
		
					Object.keys(componentMap).forEach(comp => {
						componentMap[comp].forEach(element => {
							var statusValue = 'New';
							var CustomerFacingId = '';
							var CustomerFacingName = '';
							var status = statuses.filter(v => {
								return v.csordtelcoa__Product_Configuration__c === element.id
							});
							if (status && status.length > 0) {
								statusValue = status[0].csord__Status__c;
							}
							console.log('---statusValue--'+statusValue);
							if (element.ChangeTypeValue !== 'Cancel' && element.ChangeTypeValue !== 'Modify' && (statusValue === 'Suspended' || statusValue === 'Active' || statusValue === 'Pending' )) {
								updateMap[element.guid] = [{
										name: 'ChangeType',
										//value: {
											options: optionValues,
											value: statusValue,
											displayValue: statusValue,
											//label: statusValue
										//}
									}
		
								];
							}
							if (element.ChangeTypeValue === 'Pending') {
								updateMap[element.guid] = [{
										name: 'ChangeType',
										//value: {
											readOnly: true
										//}
									}
		
								];
							}
							console.log('changetypevalue---->', element.ChangeTypeValue, '-->', ComName);
		
						});
		
						console.log('checkConfigurationSubscriptionsForMS update map', updateMap);
						//CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptionsForNGAC Attribute Update', component)); //Krunal
						
						if (updateMap && Object.values(updateMap).length > 0) {
						
						let component =  solution.getComponentByName(comp);
						console.log('---component--'+component.name);
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							console.log('---In for loop--');
							//await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
							component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
							return Promise.resolve(true);
						}
					});
				}
		
			}
			return Promise.resolve(true);
		}                 
