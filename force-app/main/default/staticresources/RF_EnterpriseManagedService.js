/***********************************************************************************************************************************
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
10           Gnana                          23-July-2020         EDGE-164917 - Changed logic to get Display Value for OfferName instead of Value which was giving Id
11 			Gnana & Aditya  				19-Jul-2020			 Spring'20 Upgrade
12          Aditya                          21-July-2020		 Edge-142084, Enable New Solution in MAC Basket
13          Krunal Taak                     02-09-2020           DPG-2577 - P2O validation
14			Monali				            14-Sep-2020          DPG-2648 - Cancel Flow for Managed Service
15          Pooja Gupta                     11-Sep-2020          EDge-171651  JS optimization
16          Krunal Taak						08-Oct-2020          DPG-2647 - Modify Flow Managed Service
17			Shresth Dixit					18-Oct-2020			 DPG-3036
18          Payal Popat                     01-Dec-2020          EDGE-178214 - Added updateAttributeExpectedSIO and ValidateExpectedSIO methods
19          Krunal Taak                     10-Dec-2020          DPG-3631 EDGE-190311 Update validation message "Please add T-MDM Professional Services to the basket"
20          Monali M                        22-Dec-2020          DPG-3632 Order Type for User Support and Mobility Platform available to individually Cancel or Modify MS Modules
21          Kamlesh Kumar                   06-Jan-2021          EDGE-194599 - UX Consumption Offers - Rate card based sync Logic enhancements [Validation Message]
22          Monali M                        27-Jan-2021          DPG-4134 - MACD issue for Manage Service <INC000094814029>
23        Vamsi Krishna Vaddipalli          14-APR-2021          EDGE-207353 for Preferred Billing Account
24        Vamsi Krishna Vaddipalli          21APR2021            EDGE-207354
25			Antun Bartonicek                01/06/2021           EDGE-198536: Performance improvements
26          Kshitiz S. / Aman G.            27/07/2021           DIGI-809 Name Change
27			Akshay Gujar					25-Aug-2021			 DIGI-14770: Removed validation for TMDSM/PS/MS
28          Ronak Mandhanya                  13-Oct-2021          DIGI-33119: AMMS offer name changes
************************************************************************************************************************************/
var EMS_COMPONENT_NAMES = {
	solution: "Adaptive Mobility Managed Services",
	mobilityPlatformMgmt: "Endpoint Management - Platform Management", //DIGI-809 name change,DIGI-33119
	userSupport: "Endpoint Management - User Support", //DIGI-809 name change
};

var communitySiteId;
var changetypeMACsolution = null;
var DEFAULTSOLUTIONNAME_EMS = "Adaptive Mobility Managed Services"; // Added as part of EDGE-149887

// Changes as part of EDGE-154489 start
if (CS.SM.registerPlugin) {
		console.log('Load EMSPlugin');
		window.document.addEventListener('SolutionConsoleReady', async function () {
			await CS.SM.registerPlugin(EMS_COMPONENT_NAMES.solution)
				.then(async EMSPlugin => {
					console.log("Plugin registered for Managed Services");
					// For Hooks
					EMSPlugin_updatePlugin(EMSPlugin);
				});
		});
	}
// Changes as part of EDGE-154489 end

async function EMSPlugin_updatePlugin(EMSPlugin) {
	//EDGE-198536: message listener and Utils.updateImportConfigButtonVisibility moved to window.document.addEventListener('SolutionSetActive' block
	//Changes as part of EDGE-154489 start
	EMSPlugin.afterSave = async function (
		result,
		configurationsProcessed,
		saveOnlyAttachment,
		configurationGuids
	) 
    {
        try{
		Utils.updateOEConsoleButtonVisibility();
		Utils.updateCustomButtonVisibilityForBasketStage();
		//Added for Cancel Story DPG-2648
		if (BasketChange === "Change Solution") {
			EMSPlugin_UpdateMainSolutionChangeTypeVisibility(result.solution);
		}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue 
		//autoSelectTMDMSUpportValues(); //commented/added for one to many changes
		setchangeTypevisibility(result.solution);
		EMSPlugin_updateChangeTypeAttribute();
		//populateRateCardinAttachmentEMS();
		//EMSPlugin.setOETabsVisibility();//Commented by Pooja
		//EDGE-135267
		Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals(); //Added as part of EDGE-154489
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
	};

	//--BEFORESAVE - added by krunal - DPG-2577 - START
	EMSPlugin.beforeSave = async function (
		solution,
		configurationsProcessed,
		saveOnlyAttachment,
		configurationGuids
	) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
        let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		//-- p2o validation DPG-2577 -- Start -- Krunal //Telstra Mobile Device Management - VMware
		let currentActiveBasket = await CS.SM.getActiveBasket();
		let profServCheck = "Absent";
		let tmdmVMWareCheck = "Absent";
		let flag = "yes";
        let mobilityPlatformMgmtConfig = "Absent";
        let userSupportConfig = "Absent";
		var chtype;
        var replacedConfig; //DPG-4134
		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			if (currentActiveBasket.solutions && Object.values(currentActiveBasket.solutions).length > 0) {
				//EDGE-154489
				for (const basketSol of Object.values(currentActiveBasket.solutions)) {
					if (basketSol.name === "T-MDM Professional Services") {
						profServCheck = "PFPresent";
					} else if (
						basketSol.name === "Telstra Mobile Device Management - VMware"
					) {
						tmdmVMWareCheck = "TMDMPresent";
					} else {}
				}
			}
			
			if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {
				for (const config of Object.values(currentSolution.schema.configurations)) {
					chtype = Object.values(config.attributes).filter(a => {
						return a.name === 'ChangeType'
					});
                    replacedConfig = config.replacedConfigId; //DPG-4134
				}
			}
            //commented/added for one to many changes - START
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				let MobilityValue;//For EDGE-207353 on 14APR2021 by Vamsi
				let SupportValue;//For EDGE-207353 on 14APR2021 by Vamsi
				let compPM = await currentSolution.getComponentByName(
					EMS_COMPONENT_NAMES.mobilityPlatformMgmt
				);
				if (compPM) {
					let cmpConfig = await compPM.getConfigurations();
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						mobilityPlatformMgmtConfig = 'Present';
					}
					//For EDGE-207353 on 14APR2021 by Vamsi starts
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							MobilityValue = config.getAttribute("BillingAccountLookup").value; 
						}
					}//For EDGE-207353 on 14APR2021 by Vamsi ends
				}
				let compUS = await currentSolution.getComponentByName(
					EMS_COMPONENT_NAMES.userSupport
				);
				if (compUS) {
					let cmpConfig = await compUS.getConfigurations();
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						userSupportConfig = 'Present';
					}
					//For EDGE-207353 on 14APR2021 by Vamsi strats
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						for (const config of Object.values(cmpConfig)) {
							SupportValue = config.getAttribute("BillingAccountLookup").value; 
						}
					}
				}
				if(SupportValue !== MobilityValue)
				{
					CS.SM.displayMessage('Billing Account must be same for Platform Management and End User Support','error');
					cmpConfig.status = true;
					cmpConfig.statusMessage ="Billing Account must be same for Platform Management and End User Support";
				}//For EDGE-207353 on 14APR2021 by Vamsi ends
				
			}
			//commented/added for one to many changes -  END
            checkValidationForConfigurationMS();//DPG-3036
			var isExpectedSIOPopulated = await CommonUtills.validateExpectedSIO(); //Added as a part of EDGE-178214

            if(!isExpectedSIOPopulated) {   //EDGE-194599: Adding if condition for Expected SIO
                return Promise.resolve(false);
            }

		}
		//-- p2o validation DPG-2577 -- End -- Krunal - part of code from aftersave
		let Component = currentSolution.getComponentByName(EMS_COMPONENT_NAMES.solution); //EDGE-154489
		if (currentSolution && currentSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
			//changed currentSolution.type to currentSolution //EDGE-154489
			if (currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0) {
				//EDGE-154489
				//Object.values(currentSolution.schema.configurations).forEach((config) => {
				for (const config of Object.values(currentSolution.schema.configurations)) {
					//EDGE-154489
					if (config.attributes && Object.values(config.attributes).length > 0) {
						//EDGE-154489
						//Object.values(config.attributes).forEach((attr) => {
						for (const attr of Object.values(config.attributes)) {
							//EDGE-154489
                            //commented/added for one to many changes - START
							if(	mobilityPlatformMgmtConfig === "Absent" && userSupportConfig === "Absent")
                            {
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage =
									"Please select either Endpoint Management - Platform Management or Endpoint Management - User Support or Both"; //DIGI-809 Name change,DIGI-33119
							}
							//commented/added for one to many changes - END
							if (attr.name === "TenancyID" && Object.values(attr.value).length > 0 && tmdmVMWareCheck === "Absent" && BasketChange != 'Change Solution') 
                            {
								console.log("---5---");
								validationActiveManagedServiceSubscriptionCheck(attr,Component,config.guid);
							}
							// Commented as a part of DPG-14770 by Akshay G
							/*if (attr.name === "TenancyID" && (attr.value === "" || attr.value === null || attr.value === undefined) &&
								tmdmVMWareCheck === "Absent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)
							) {
								console.log("----1----");
								//Changes as part of EDGE-154489 start
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage =
									"Please select an existing tenancy or add a new tenancy";
								//currentSolution.errorMessage = 'Error in configurations';
								//currentSolution.error = true;
								//currentSolution.valid = true;
								//currentSolution.errorMessages.push('Error in configurations (Managed Services)');
								//Changes as part of EDGE-154489 end
							}*/
							//to check if Existing Tenancy is selected and adding new Telstra Mobile Device Management - VMware //-- p2o validation DPG-2577 -- Start -- Krunal
							if (attr.name === "TenancyID" && Object.values(attr.value).length > 0 &&
								tmdmVMWareCheck === "TMDMPresent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)
							) {
								console.log("----2----");
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage =
									"Basket cannot add new Telstra Mobile Device Management - VMware when existing Tenancy is selected";
							}
							//Commented as a part of DPG-14770 by Akshay G
                           /* else if (((attr.name === "TenancyID" && Object.values(attr.value).length > 0) || tmdmVMWareCheck === "TMDMPresent") && profServCheck === "Absent" && BasketChange != 'Change Solution') 
                            {
								console.log("----3----");
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage =
									"Please add T-MDM Professional Services to the basket";
							}*/



                            //Start:DPG-3632 --> Validation Check for Change Type Value Active Added
							////DPG-4134
							else if (chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'Active' || (chtype[0].value === 'New' && BasketChange === "Change Solution" && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")))

                            {
								//EDGE-154489
								console.log("----14----");
								let confg = await Component.getConfiguration(config.guid);
								confg.status = false;
								confg.statusMessage =
									"Please Select Change Type";
							}
                            else if ((attr.name === "TenancyID" && Object.values(attr.value).length > 0) || tmdmVMWareCheck === "TMDMPresent" && (chtype[0].value != 'Cancel' && chtype[0].value != '' && chtype[0].value != null)) 
                            {
								//EDGE-154489
								console.log("----4----");
								//Changes as part of EDGE-154489 start
								//CS.SM.updateConfigurationStatus(currentSolution.name, config.guid, true);
								let confg = await Component.getConfiguration(config.guid);
								confg.status = true;
								confg.statusMessage = "";
								return Promise.resolve(true);
								//Changes as part of EDGE-154489 end
							}
							else if (chtype[0].value === 'Cancel') 
                            {
								//EDGE-154489
								console.log("----14----");
								let confg = await Component.getConfiguration(config.guid);
								confg.status = true;
								confg.statusMessage = "";



                                //Start :DPG-3632- Validation for Cancel all solution



                                let terminateSave = true;
                                console.log("beforeSave - entering");
                                if (!EMSPlugin_validateCancelSolution(currentSolution)) {
                                    return Promise.resolve(false);
                                    terminateSave = false;
                                }
                                if (!terminateSave) return Promise.resolve(false);
                                //Start :DPG-3632
        
								return Promise.resolve(true);
							}
							//-- p2o validation DPG-2577 -- End -- Krunal
						} //);
					}
				} //);
			}
		}
		//return Promise.resolve(true);
		//validateMpmUsValues();








	};
	//--BEFORESAVE - added by krunal - DPG-2577 - END

	//Aditya: Spring Update for changing basket stage to Draft
	EMSPlugin.afterSolutionDelete = function (solution) {
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	};

	//Updated for edge-117563
	//Changes as part of EDGE-154489 start
	EMSPlugin.afterAttributeUpdated = async function (
		component,
		configuration,
		attribute,
		oldValueMap
	) {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		let oldValue = oldValueMap.value;//For EDGE-207353 on 14APR2021 by Vamsi
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		}
		if (
			component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt &&
			attribute.name === "TechnicalSupport"
		) {
			//autoSelectTMDMSUpportValues(); //commented/added for one to many changes
		}
		//- DPG-2577 - Krunal - Start
		if (
			(component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt ||
				component.name === EMS_COMPONENT_NAMES.userSupport) &&
			(attribute.name === "TechnicalSupport" ||
				attribute.name === "FeatureLevel")
		) {
			console.log(
				"*************Attribute Update - validateMpmUsValues---",
				component,
				configuration.guid,
				attribute,
				"oldValue:",
				oldValueMap["value"],
				"newValue:",
				attribute.value
			);
			//validateMpmUsValues(); //commented/added for one to many changes
		}
		//- DPG-2577 - Krunal - End

		if (
			component.name === EMS_COMPONENT_NAMES.solution &&
			attribute.name === "OfferName"
		) {
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
			//RF++
			await CommonUtills.genericUpdateSolutionName(
				component,
				configuration,
				attribute.displayValue,
				attribute.displayValue
			); //RF++
		}
		
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === 'ChangeType' && oldValueMap.value !== attribute.value && (attribute.value === 'Modify' || attribute.value === 'Cancel')) 
		{	//EDGE-154489
			changetypeMACsolution = attribute.value;
			//await addAllEMSSubscriptionstoMAC();
		}

		//Added for Cancel Story DPG-2648
		if (
			BasketChange === "Change Solution" &&
			attribute.name === "ChangeType"
		) {
			console.log('--inside kt--');
			EMSPlugin_UpdateCancellationAttributes(
				component.name,
				configuration.guid,
				attribute.value
			);
		}
		if (
			BasketChange === "Change Solution" &&
			component.name === EMS_COMPONENT_NAMES.solution &&
			attribute.name === "DisconnectionDate"
		) {
			EMSPlugin_validateDisconnectionDate(
				component.name,
				configuration.guid,
				attribute.value
			);
		}

		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (component.name === EMS_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup" && attribute.value !== "") {

			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(EMS_COMPONENT_NAMES.solutionname);
				if(parentBillingAccountATT){
				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', EMS_COMPONENT_NAMES.tenancy,oldValue);
				}
			}
		}
          //For EDGE-207353 on 14APR2021 by Vamsi ends
		return Promise.resolve(true);
	};

	//Changes as part of EDGE-154489 start
	window.document.addEventListener("SolutionSetActive", async function (e) {
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
		if (currentSolution.name === EMS_COMPONENT_NAMES.solution) {
			//EDGE-198536 Start: existing code moved inside active solution check
            //EDGE-154489
            Utils.updateCustomButtonVisibilityForBasketStage();
            window.addEventListener("message", EMSPlugin_handleIframeMessage);
            //EDGE-198536 End: existing code moved inside active solution check
			//EDGE-154489
			//Changes as part of EDGE-154489 end here
			validationErrorActiveManagedServiceSubscriptionCheck(); // Krunal DPG-2577

			let currentBasket = await CS.SM.getActiveBasket();
			let loadedSolution = await CS.SM.getActiveSolution();
			basketId = currentBasket.basketId;
			window.currentSolutionName = loadedSolution.name;
			await CommonUtills.getSiteDetails(currentBasket); //RF++
			await CommonUtills.getBasketData(currentBasket); //RF++
            //let basketChange = config.getAttribute("ChangeType");
            if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", false);
			} //RF for lock issue
            //CommonUtills.setBasketChange();
            let product = await CS.SM.getActiveSolution();
         if (product) {
             let component = await product.getComponentByName(product.name);
             if (component) {
                 let cmpConfig = await component.getConfigurations();
                 if (product && Object.values(cmpConfig)[0].replacedConfigId) {
                     window.BasketChange = "Change Solution";
                 }
             }
         }
            console.log('---acc id--'+accountId);
            if (accountId != null) {
                CommonUtills.setAccountID(EMS_COMPONENT_NAMES.solution, accountId);
            }
			
			// Added for making BillingAccount ReadOnly in MACD Journey DPG-2648 and DPG-4134
			if (loadedSolution.name.includes(EMS_COMPONENT_NAMES.solution)) {
				if (basketChangeType === "Change Solution" && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
					let componentMap = new Map();
					let componentMapattr = {};
					let billingAccLook = Object.values(loadedSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
					componentMapattr["BillingAccountLookup"] = [];
					componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
					componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
					await CommonUtills.attrVisiblityControl(EMS_COMPONENT_NAMES.solution, componentMap);
					if (billingAccLook.value === null || billingAccLook.value === "") {
						//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
						CommonUtills.setSubBillingAccountNumberOnCLI(EMS_COMPONENT_NAMES.solution, "BillingAccountLookup", true);
					}
				}
			}
			// Added for making BillingAccount ReadOnly in MACD Journey(DPG-2648) AND DPG-4134
			if (window.BasketChange === "Change Solution") {
				await CommonUtills.updateSolutionNameOnOLoad(EMS_COMPONENT_NAMES.solution);//For EDGE-207354 on 21APR2021 by Vamsi
				checkConfigurationSubscriptionsForMS('afterSolutionLoaded');
				await EMSPlugin_UpdateMainSolutionChangeTypeVisibility(loadedSolution);
				/*
				CommonUtills.setSubBillingAccountNumberOnCLI(
					EMS_COMPONENT_NAMES.solution,
					"BillingAccountLookup"
				); 
				let componentMap = new Map();
				let componentMapattr = {};
				if (loadedSolution) {
					Object.values(loadedSolution.schema.configurations).forEach((config) => {
						if (config.attributes) {
							componentMapattr["BillingAccountLookup"] = [];
							componentMapattr["BillingAccountLookup"].push({
								IsreadOnly: true,
								isVisible: true,
								isRequired: true,
							});
							componentMap.set(config.guid, componentMapattr);
						}
					});
					CommonUtills.attrVisiblityControl(
						EMS_COMPONENT_NAMES.solution,
						componentMap
					);
				}
				*/
			} //END DPG-2648
			// Aditya: Edge:142084 Enable New Solution in MAC Basket
			//CommonUtills.setBasketChange();
			//Added by Aman Soni as a part of EDGE -148455 || End
			EMSPlugin_updateChangeTypeAttribute();
			populateRateCardinAttachmentEMS();
			// autoSelectTMDMSUpportValues();  //commented/added for one to many changes
			//validateMpmUsValues(); //Krunal DPG-2577 //commented/added for one to many changes
			Utils.loadSMOptions();
			setchangeTypevisibility(loadedSolution);
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
			return Promise.resolve(true);
		}
	});


	//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed. 
	//EMSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {//EDGE-154489
	EMSPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {//EDGE-154489
		//console.log('afterConfigurationAdd', component, configuration);
		//if (component === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//EDGE-154489
		if (component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//EDGE-154489
			//EMSPlugin.getConfiguredSiteIds();
			//await DOP_updateConfigurationsName();
		}
		//addDefaultEMSOEConfigs();//Call generic method from OElogic if needed to use this- Pooja
		//Updated for edge-117563
		/*if (window.currentSolutionName === EMS_COMPONENT_NAMES.solution) {
			//again update link text value as UI is refreshed after save
			Utils.updateCustomAttributeLinkText('Rate Card', 'View Rate Card');
			//Utils.updateCustomAttributeLinkText('Tenancy','View and Edit');			//EDGE -145320 >> -
			Utils.updateCustomAttributeLinkText('Included Tenancies', 'Select Tenancies');//EDGE -145320 >> +
		}*/
		/*if (component.name === EMS_COMPONENT_NAMES.userSupport || component.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {//changed component to component.name //EDGE-154489
			//Changes as part of EDGE-154489 start here
			/*updateMap[configuration.guid] = [{
				name: "ChangeType",
				value: {
					value: "New",
					readOnly: true,
					showInUi: false
				}
			}];
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
		}*/
		//For EDGE-207353 on 14APR2021 by Vamsi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(EMS_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){
				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		}
		//For EDGE-207353 on 14APR2021 by Vamsi ends
		return Promise.resolve(true);
	}

	//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed.
	/*
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
	}*/

	//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed.
	/*EMSPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {
		//console.log('TID afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration);
		//initializeDOPOEConfigs();
		//window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	}*/


	/**
 * Finds all custom attributes by label (i.e. Rate Card) and sets new link text (i.e. Edit -> View Rate Card)
 */ //Moved to UIPlugin Pooja
	/*EMSPlugin.updateCustomAttributeLinkText = function (customAttributeLabel, newLinkText) {
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
	}*/

	// Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed. - Uncommented
	/*********************************
	 * Krunal / Monali 
	 * Cancel and Modify Journey DPG-2647 || DPG-2648
	 * Introduced logics for MAC journey
	 *********************************/
	EMSPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
			console.log('afterConfigurationAdd', componentName, guid);
			
			if (componentName === EMS_COMPONENT_NAMES.userSupport || componentName === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
				   
			   let updateMap = {};
				updateMap[guid] = [];
                if(changetypeMACsolution === 'Cancel'){
				updateMap[guid].push(
				{
					name: "ChangeType",
					value : changetypeMACsolution,
					label : "ChangeType",
					showInUi: true,
					readOnly: true
				});
                }
                else if (changetypeMACsolution === 'Modify'){
                    updateMap[guid].push(
                    {
                        name: "ChangeType",
                        value : changetypeMACsolution,
                        label : "ChangeType",
                        showInUi: true,
                        readOnly: false
                    });
                }
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

	//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed.
	//Changes as part of EDGE-154489 start
	//EMSPlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
    /*
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
		if (currentSolution.name === EMS_COMPONENT_NAMES.solution) {
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
		}
		return Promise.resolve(true);
	});
   */
	/****************************************************************************************************
* Author	: Monali Mukherjee
* Method Name : EMSPlugin_UpdateMainSolutionChangeTypeVisibility
* Defect/US # : DPG-1914
* Invoked When: On Solution Load
* Description : For Setting Visibility 
************************************************************************************************/
	EMSPlugin_UpdateMainSolutionChangeTypeVisibility = async function(solution) { //krunal
		if (BasketChange !== 'Change Solution') {
			return;
		}
		//Added for Cancel Story DPG-2648 //--DPG-2647 -- Krunal Taak -- START
		var chtype; 
		var replacedConfig; //DPG-4134
				
		//if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			for (const config of Object.values(solution.schema.configurations)) {
				chtype = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
				replacedConfig = config.replacedConfigId; //DPG-4134
			}
			}
		//}
		
		console.log('--changeType--'+chtype[0].value);
		//DPG-4134
		//if(chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New' ){
		if(replacedConfig === null || replacedConfig === undefined || replacedConfig === ""){
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: false},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
                {name: 'Space1', showInUi: true},                                                                      
				{name: 'Space2', showInUi: true}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
            //await EMSPlugin_updateAttributeVisiblity('TenancyButton', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, true, true, false);
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
		//DPG-4134
		if((chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New') && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")){
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
                {name: 'Space1', showInUi: true},                                                                      
				{name: 'Space2', showInUi: false}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			//await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
            //await EMSPlugin_updateAttributeVisiblity('TenancyButton', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, true, true, false);
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
            await EMSPlugin_updateAttributeVisiblity('TenancyButton', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
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
				{name: 'Space1', showInUi: true},
				{name: 'Space2', showInUi: false}
			];
			console.log('EMSPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await EMSPlugin_updateAttributeVisiblity('ChangeType',EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			//await EMSPlugin_updateAttributeVisiblity('CancellationReason', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//await EMSPlugin_updateAttributeVisiblity('DisconnectionDate', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			//await EMSPlugin_updateAttributeVisiblity('TenancyButton', EMS_COMPONENT_NAMES.solution, Object.values(solution.schema.configurations)[0].guid, false, true, false);
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
			readOnly: isReadOnly,
			showInUi: isVisible,
			required: isRequired
		});

		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName); 

		  console.log('updateMap'+updateMap);  
		  
		 var complock = component.commercialLock;
		if(complock) component.lock('Commercial', false);
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
		}
		if (complock) component.lock('Commercial', true);

		return Promise.resolve(true);
	} 

/**
 * Author      : Shubhi
 * Functions for processing iFrame messages
 */
function EMSPlugin_processMessagesFromIFrame() {
	if (basketStage === "Contract Accepted") {
		currentSolution.lock("Commercial", false);
	} //RF for lock issue
	if (!communitySiteId) {
		return;
	}
	var data = sessionStorage.getItem("payload");
	var close = sessionStorage.getItem("close");
	var message = {};
	if (data) {
		message["data"] = JSON.parse(data);
		EMSPlugin_handleIframeMessage(message);
	}
	if (close) {
		message["data"] = close;
		EMSPlugin_handleIframeMessage(message);
	}
	if (basketStage === "Contract Accepted") {
		currentSolution.lock("Commercial", true);
	} //RF for lock issue
}


/**********************************************************************************************************************************************
 * Author	   : Venkata Ramanan G
 * Method Name : populateRateCardinAttachmentEMS
 * Invoked When: after solution is loaded
 ********************************************************************************************************************************************/

async function populateRateCardinAttachmentEMS() {
	if (basketStage !== "Contract Accepted") return;
	let currentSolution = await CS.SM.getActiveSolution(); //RF--
	//Changes as part of EDGE-154489
	if (
		currentSolution &&
		currentSolution.name.includes(EMS_COMPONENT_NAMES.solution) &&
		currentSolution.components &&
		Object.values(currentSolution.components).length > 0
	) {
		//changed from currentSolution.type to currentSolution //EDGE-154489
		let comp = await currentSolution.getComponentByName(
			EMS_COMPONENT_NAMES.mobilityPlatformMgmt
		);
		if (comp) {
			let cmpConfig = await comp.getConfigurations(); //RF++
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				//RF++
				let inputMap = {};
				inputMap["basketid"] = basketId;
				inputMap["Offer_Id__c"] = "DMCAT_Offer_000854";
				inputMap["SolutionId"] = currentSolution.id;
			} //RF++
		} //RF++
	}
}

function EMSPlugin_handleIframeMessage(e) {
	if (
		!e.data ||
		!e.data["command"] ||
		e.data["command"] !== "ADDRESS" ||
		(e.data["caller"] && e.data["caller"] === EMS_COMPONENT_NAMES.solution)
	) {
		sessionStorage.removeItem("close");
		sessionStorage.removeItem("payload");
	}//Added as a part of EDGE-189788
	if (e.data && e.data["command"] && e.data["command"] === "RateCard" && e.data["caller"]) {
		CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],e.data["caller"]); //Added as a part of EDGE-178214
	}

	var message = {};
	message = e["data"];
	messgae = message["data"];
	if (message.command && message.command === "TenancyIds") {
		if (message.caller && message.caller !== "Managed Services") {
			return;
		}
		if (message) {
			updateSelectedTenancyList(message["data"]);
		}
	}
	
	//Uncommented by Purushottam as a part of EDGE -145320 || Start
	if (e.data === "close") {
		try {
			var d = document.getElementsByClassName("mat-dialog-container");
			if (d) {
				for (var i = 0; i < d.length; i++) {
					d[i].parentElement.removeChild(d[i]);
				}
			}
			var el = document.getElementsByClassName("cdk-global-overlay-wrapper");
			if (el) {
				for (var i = 0; i < el.length; i++) {
					el[i].parentNode.removeChild(el[i]);
				}
			}
		} catch (err) { }
	}
	//Uncommented by Purushottam as a part of EDGE -145320 || End
}

/* function to update tenancyid attribute on solution level */
async function updateSelectedTenancyList(data) {
	
   //--DPG-2647 -- start
	var t1 =""; 
	var t2 ="";
	var configGuid = "";
	var tenancyIdss = "";
	//--DPG-2647 -- end
	var tenancyIds = "";
	let updateMap = {}; //EDGE-154489
	let solution = await CS.SM.getActiveSolution(); //EDGE-154489
	let component = solution.getComponentByName(EMS_COMPONENT_NAMES.solution); //EDGE-154489
    var tenancyID="";//DPG-3036
	if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		//changed solution.type to solution -EDGE-154489
		let cmpConfig = await solution.getConfigurations(); //RF++
		if (cmpConfig && Object.values(cmpConfig).length > 0) {
			for (const config of Object.values(cmpConfig)) {
				tenancyIds = config.getAttribute("TenancyId"); //RF++
				t1 = tenancyIds.value;
                tenancyID = data.toString();//DPG-3036
				updateMap[config.guid] = [];
				updateMap[config.guid].push({
					name: "TenancyId",
					value: data.toString(),
					displayValue: data.toString(),
					showInUi: false,
					readOnly: false,
				});
				if (updateMap && Object.keys(updateMap).length > 0) {
					await component.updateConfigurationAttribute(
						config.guid,
						updateMap[config.guid],
						true
					);
				}
				//Changes as part of EDGE-154489 end
			}
			
			//--DPG-2647 -- Start
				if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
					for (const config of Object.values(solution.schema.configurations)) {//EDGE-154489
						configGuid = config.guid;					
						tenancyIdss = Object.values(config.attributes).filter(a => {//EDGE-154489
							return a.name === 'TenancyID'

						});
						t2 = tenancyIdss[0].value;
					}
					console.log('-----tenancyIds----'+tenancyIdss[0].name+'--'+tenancyIdss[0].value +'---'+BasketChange);

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
					//&& BasketChange != 'Change Solution')
					console.log('-1----t1----'+t1 +'--- t2 --'+t2);
					if((t2 === '' || t2 === null) && BasketChange != 'Change Solution'){
						console.log('--in t validationActiveManagedServiceSubscriptionCheck--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
					else if (tenancyIdss[0].name === 'TenancyID' && (t2 != '' || t2 != null)  && tmdmVMWareCheck === 'Absent' && BasketChange != 'Change Solution')  {
						console.log('---inside validationActiveManagedServiceSubscriptionCheck---');
						validationActiveManagedServiceSubscriptionCheck(tenancyIdss[0],component,configGuid);
					}
					else{}
					
					console.log('-----profServCheck----'+profServCheck +'--- BasketChange --'+BasketChange);
					console.log('-----t1----'+t1 +'--- t2 --'+t2);
					if((t1 === '' || t1 === null || t2 === '' || t2 === null)&& BasketChange === 'Change Solution'){
						console.log('--in t if--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
                    //Commented as a part of DPG-14770 by Akshay G
					/*  else if(((t1 != null || t1 != '') || (t2 != null || t2 != '')) &&  (t1 != t2) && BasketChange === 'Change Solution' && profServCheck === 'Absent'){
						console.log('--in t else if--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = false;
						confg.statusMessage = 'Please add T-MDM Professional Services to the basket';
					}*/
                    
					else{
						console.log('--in t else--');
						let confg = await component.getConfiguration(configGuid);
						confg.status = true;
						confg.statusMessage = '';
						//return Promise.resolve(true);
					}
				}
				//--DPG-2647 -- End 
			
			
		}
		if (solution.components && Object.values(solution.components).length > 0) {
			//EDGE-154489
			for (const comp of Object.values(solution.components)) {
				//EDGE-154489
				if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
					let cmpConfig = await comp.getConfigurations(); //RF++
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						//RF++
						for (const config of Object.values(cmpConfig)) {
							let confgAttr = config.getAttributes(); //RF++
							if (confgAttr && Object.values(confgAttr).length > 0) {
								tenancyIds = config.getAttribute("TenancyId"); //RF++
								updateMap[config.guid] = [];
								updateMap[config.guid].push({
									name: "TenancyId",
									value: data.toString(),
									displayValue: data.toString(),
									showInUi: false,
									readOnly: false,
								});

								if (updateMap && Object.keys(updateMap).length > 0) {
									await component.updateConfigurationAttribute(
										config.guid,
										updateMap[config.guid],
										true
									);
								}
								//Changes as part of EDGE-154489 end
							}
						}
					}
				}
				if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
					let cmpConfig = await comp.getConfigurations(); //RF++
					if (cmpConfig && Object.values(cmpConfig).length > 0) {
						//RF++
						for (const config of Object.values(cmpConfig)) {
							let confgAttr = config.getAttributes(); //RF++
							if (confgAttr && Object.values(confgAttr).length > 0) {
								//RF++
								tenancyIds = config.getAttribute("TenancyId"); //RF++
								updateMap[config.guid] = [];
								updateMap[config.guid].push({
									name: "TenancyId",
									value: data.toString(),
									displayValue: data.toString(),
									showInUi: false,
									readOnly: false,
								});
								if (updateMap && Object.keys(updateMap).length > 0) {
									await component.updateConfigurationAttribute(
										config.guid,
										updateMap[config.guid],
										true
									);
								}
								//Changes as part of EDGE-154489 end
							}
						}
					}
				}
			}
		}
        MSUtils.setTenancyIdForProffesionalService(tenancyID);//DPG-3036
	}
	
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
	let USmandatory = true;
	let MPMmandatory = true;
	var MPMComponentGuid;
	var USComponentGuid;
	var updateMap = {};
	console.log('Inside validateMpmUsValues ' + 'USmandatory' + USmandatory + 'MPMmandatory' + MPMmandatory);
	if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			if (solution.components && Object.values(solution.components).length > 0) {
				for (const comp of Object.values(solution.components)) {
					if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) {
						if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							for (const config of Object.values(comp.schema.configurations)) {
								MPMComponentGuid = config.guid;
								console.log('----MPMComponentGuid----' + MPMComponentGuid);
								if (config.attributes && Object.values(config.attributes).length > 0) {
									Object.values(config.attributes).forEach((attr) => {
										if (attr.name === 'TechnicalSupport')
											MPMtechSupport = attr.value;
										if (attr.name === 'FeatureLevel')
											MPMfeatureLevel = attr.value;
									});
								}
								console.log('inside mobilityPlatformMgmt---> MPMtechSupport -->' + MPMtechSupport + '-- MPMfeatureLevel -->' + MPMfeatureLevel);
							};
						}
					}
					else if (comp.name === EMS_COMPONENT_NAMES.userSupport) {
						if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							for (const config of Object.values(comp.schema.configurations)) {
								USComponentGuid = config.guid;
								console.log('----USComponentGuid----' + USComponentGuid);
								if (config.attributes && Object.values(config.attributes).length > 0) {
									Object.values(config.attributes).forEach((attr) => {
										if (attr.name === 'TechnicalSupport')
											UStechSupport = attr.value;
										if (attr.name === 'FeatureLevel')
											USfeatureLevel = attr.value;
									});
								}
								console.log('inside userSupport---> UStechSupport -->' + UStechSupport + '-- USfeatureLevel -->' + USfeatureLevel);
							};
						}
					}
				};
				if (MPMtechSupport === null || MPMtechSupport === '' || MPMfeatureLevel === null || MPMfeatureLevel === '') {
					console.log('inside MPM if -- MPMmandatory -- ' + MPMmandatory);
					MPMmandatory = true;
					hideShowAttributes(componentUpdate, USComponentGuid, true, ['TechnicalSupport', 'FeatureLevel']);
				}
				else {
					console.log('inside MPM else 1 -- MPMmandatory -- ' + MPMmandatory);
					MPMmandatory = false;
					hideShowAttributes(componentUpdate, USComponentGuid, false, ['TechnicalSupport', 'FeatureLevel']);
					console.log('inside MPM else 2 -- MPMmandatory -- ' + MPMmandatory);
				}
				if (UStechSupport === null || UStechSupport === '' || USfeatureLevel === null || USfeatureLevel === '') {
					console.log('inside userSupport if  -- USmandatory -- ' + USmandatory);
					USmandatory = true;
					hideShowAttributes(componentUpdate, MPMComponentGuid, true, ['TechnicalSupport', 'FeatureLevel']);
				}
				else {
					console.log('inside userSupport else 1 -- USmandatory -- ' + USmandatory);
					USmandatory = false;
					hideShowAttributes(componentUpdate, MPMComponentGuid, false, ['TechnicalSupport', 'FeatureLevel']);
					console.log('inside userSupport else 2 -- USmandatory -- ' + USmandatory);
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
	console.log('inside hideShowAttributes' + component, guid, isRequired, attributeArray);
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


/***
	
Auto select EU technical SUpport if the PM Technical SUpport is 24x7
//Updated for edge-117563 by shubhi
**/
async function autoSelectTMDMSUpportValues() {
	//Changes as part of EDGE-154489 start
	let solution = await CS.SM.getActiveSolution(); //RF--
	//Changes as part of EDGE-154489 end
	let pmTechnicalSupport;
	let pmTechnicalSupportDispl;
	let pmTechnicalSupportval;
	let updateMap = {}; //EDGE-154489
	if (
		solution &&
		solution.name.includes(EMS_COMPONENT_NAMES.solution) &&
		solution.schema.configurations &&
		Object.values(solution.schema.configurations).length > 0 &&
		solution.components &&
		Object.values(solution.components).length > 0
	) {
		//Replaced soltion.type to solution EDGE-154489
		let comp = await solution.getComponentByName(
			EMS_COMPONENT_NAMES.mobilityPlatformMgmt
		); //RF++
		if (comp) {
			//RF++
			let cmpConfig = await comp.getConfigurations(); //RF++
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				//RF++
				for (const config of Object.values(cmpConfig)) {
					//RF++
					pmTechnicalSupport = config.getAttribute("TechnicalSupport"); //RF++
				}
			}
			if (pmTechnicalSupport) {
				pmTechnicalSupportDispl = pmTechnicalSupport.displayValue;
				pmTechnicalSupportval = pmTechnicalSupport.value;
			}
		}
		let compUS = await solution.getComponentByName(
			EMS_COMPONENT_NAMES.userSupport
		); //RF++
		if (compUS) {
			//RF++
			let cmpConfig = await compUS.getConfigurations(); //RF++
			if (cmpConfig && Object.values(cmpConfig).length > 0) {
				//RF++
				for (const config of Object.values(cmpConfig)) {
					//RF++
					if (pmTechnicalSupportDispl === "24x7") {
						//Changes as part of EDGE-154489 start
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: "TechnicalSupport",
							showInUi: true,
							displayValue: pmTechnicalSupportDispl,
							readOnly: true,
							value: pmTechnicalSupportval,
						});
					} else {
						updateMap[config.guid] = [];
						updateMap[config.guid].push({
							name: "TechnicalSupport",
							readOnly: false,
							showInUi: true,
						});
					}
					if (updateMap && Object.keys(updateMap).length > 0) {
						await compUS.updateConfigurationAttribute(
							config.guid,
							updateMap[config.guid],
							true
						); //RF++
					}
					//Changes as part of EDGE-154489 end
				}
			}
		}
	}
}

//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed. - Uncommented
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
	// ADDED FOR DPG-4134
	var replacedConfig; //DPG-4134
    //if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
    if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
        for (const config of Object.values(solution.schema.configurations)) {
            chtype = Object.values(config.attributes).filter(a => {
                return a.name === 'ChangeType'
            });
            replacedConfig = config.replacedConfigId; //DPG-4134
        }
    }
    //}
	// End DPG-4134
	// Aditya: Edge:142084, Enable New Solution in MAC Basket
	if (window.BasketChange === 'Change Solution' && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")) {
	
		//console.log('addAllEMSSubscriptionstoMAC', product);
		if (product.schema.configurations) {
			Object.values(product.schema.configurations).forEach(config => {
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
		//Changes as part of EDGE-154489 end here
	
		return Promise.resolve(true);
	
	
	} else
		return Promise.resolve(true);
}

//Commented by Pooja it in refactoring as it not used anywhere till date, please uncomment as and when needed.
/*********************************
	 * Venkat                          25-Nov-2019          EDGE -92307 INtroduced logics for MAC journey
	 * Invokes on update of ChangeType at Main solution & invokes the function to add all subscriptions of component to the MAC basket.
	 *********************************/
	 /*
async function addAllEMSSubscriptionstoMAC() {
		//console.log('addAllEMSSubscriptionstoMAC', BasketChange);
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
/*
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
/*
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
	*/

/****************************************************************************************************
* Author	: Krunal Taak
* Method Name : validation Active Managed Service Subscription Check
* Defect/US # : DPG-2577
* Invoked When: On attribute update
* Description :validation Active Managed Service Subscription Check
****************************************************************************************************/
async function validationActiveManagedServiceSubscriptionCheck(tenancyId, component, guid) { //Krunal
	let updateMap = new Map();
	let componentMapNew = new Map();
	var tenancyInfo = "";
	let inputMap = {};
	let config = await component.getConfiguration(guid);
	inputMap['tenancyId'] = tenancyId.value;
	console.log('inputMaP', inputMap);
	let currentBasket;
	console.log('0');
	currentBasket = await CS.SM.getActiveBasket();
	console.log('1');
	await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
		console.log('2');
		tenancyInfo = JSON.parse(result["tenancyId"]);
		console.log('the tenancyInfo is==>' + tenancyInfo);
		return Promise.resolve(true);
	});
	if (tenancyInfo === true) {
		console.log('In true');
		componentMapNew.set('CheckTenancyError', true);
		config.status = false;
		config.statusMessage = 'Please select a different tenancy or add a new tenancy';
	}
	else {
		console.log('In false');
		componentMapNew.set('CheckTenancyError', false);
	}
	if (componentMapNew && componentMapNew.size > 0) {
		updateMap.set(guid, componentMapNew);
		CommonUtills.UpdateValueForSolution(component.name, updateMap)
	}
}
/****************************************************************************************************
* Author	: Krunal Taak
* Method Name : validation Active Managed Service Subscription Check - On Load
* Defect/US # : DPG-2577
* Invoked When: Onload and Aftersave
* Description :validation Active Managed Service Subscription Check
****************************************************************************************************/
async function validationErrorActiveManagedServiceSubscriptionCheck() { //Krunal
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			Object.values(solution.schema.configurations).forEach((subsConfig) => {
				var checkTenancy = Object.values(subsConfig.attributes).filter(att => {
					return att.name === 'CheckTenancyError'
				});
				if (checkTenancy[0].value === true) {
					subsConfig.status = false;
					subsConfig.statusMessage = 'Please select a different tenancy or add a new tenancy';
				}
				else {
					subsConfig.status = true;
					subsConfig.statusMessage = '';
				}
			});
		}
	}
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
				EMSPlugin_updateAttributeVisiblity('TenancyButton', componentName, guid, false, false, false);
				EMSPlugin_updateAttributeVisiblity('Space1', componentName, guid, true, false, false);
				EMSPlugin_updateAttributeVisiblity('Space2', componentName, guid, true, false, false);
			}


			//Strat: DPG-3632- Commented as it is not required


        	//else if (changeTypeValue === "Cancel" && (componentName === EMS_COMPONENT_NAMES.mobilityPlatformMgmt || componentName === EMS_COMPONENT_NAMES.userSupport)) {
            //	EMSPlugin_updateAttributeVisiblity(["ChangeType"], componentName, guid, true, true, true);
			//}
			//End: DPG-3632
			//--DPG-2647 -- Reused for Modify - START
			if (changeTypeValue === 'Modify' ) {	
				console.log('---1---');	
				EMSPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
				EMSPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
				EMSPlugin_updateAttributeVisiblity('TenancyButton', componentName, guid, false, true, false);	
				EMSPlugin_updateAttributeVisiblity('Space1', componentName, guid, true, true, false);	
				EMSPlugin_updateAttributeVisiblity('Space2', componentName, guid, true, false, false);				
			}
			
			if (changeTypeValue === '') {
				EMSPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
				EMSPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
				EMSPlugin_updateAttributeVisiblity('TenancyButton', componentName, guid, true, true, false);
				EMSPlugin_updateAttributeVisiblity('Space1', componentName, guid, true, true, false);
				EMSPlugin_updateAttributeVisiblity('Space2', componentName, guid, true, false, false);
			}
			//--DPG-2647 -- Reused for Modify - END
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
 * Method Name : EMSPlugin_UpdateAttributesForMacdOnSolution
 * Defect/US # : DPG-2648
************************************************************************************************/		
EMSPlugin_UpdateAttributesForMacdOnSolution = async function(solution) {
	console.log('EMSPlugin_UpdateAttributesForMacdOnSolution');
	let  changeTypeAtrtribute;
	let cancellationReasonAtribute;
	if (solution && /*solution.type &&*/ solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			changeTypeAtrtribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
				return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
			});
			if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
				EMSPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false,true, true);
			} else {
				EMSPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false, false, false);
				Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'CancellationReason', false);
				Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'DisconnectionDate', false);
			}
			let comp = Object.values(solution.components).filter(c => {
				return c.schema && (c.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt || c.name === EMS_COMPONENT_NAMES.userSupport)  && c.schema.configurations && Object.values(c.schema.configurations).length > 0
			});
			if (comp && comp.length > 0) {
				for (let i = 0; i < Object.values(comp[0].schema.configurations).length; i++) {
					let config = Object.values(comp[0].schema.configurations)[i];
					//console.log('print config---->'+config.guid+Object.values(config.attributes));
					changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
						return obj.name === 'ChangeType'
					});
					console.log('print changeTypeAtrtribute---->'+changeTypeAtrtribute[0].displayValue);
					
					if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
						//EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute[0].displayValue, selectPlanDisplayValue);
					}
				}
			}
		}
	}
	return Promise.resolve(true);
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
//----------------updateChangeTypeAttribute --- START
EMSPlugin_updateChangeTypeAttribute = async function (fromAddToMacBasket = false) {
	console.log('EMSPlugin_updateChangeTypeAttribute');
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach(async (comp) => {
				var updateMap = [];
				var doUpdate = false;
				if ((comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						if (config.attributes && Object.values(config.attributes).length > 0) {
							Object.values(config.attributes).forEach((attribute) => {
								if (attribute.name === 'ChangeType') {
									doUpdate = true;
									var changeTypeValue = attribute.value;
									if (!updateMap[config.guid])
										updateMap[config.guid] = [];
									if (!window.BasketChange === 'Change Solution' || (config.replacedConfigId ==='' || config.replacedConfigId ===undefined ||config.replacedConfigId ===null)) {
										console.log('Non MACD basket');
										if (!changeTypeValue) {
											changeTypeValue = 'New';
										}
										updateMap[config.guid].push({
											name: attribute.name,
												value: changeTypeValue,
												displayValue: changeTypeValue,
												showInUi: false,
												readOnly: true
										});
									} 



									//Start: DPG-3632 - Added handling for the MACD Basket


									else {
                                        console.log("MACD basket");
                                        //var readonly = false;
                            			//if (config.id && changeTypeValue === "Cancel") readonly = true;
                            			var readonly = true;
                            			var showInUI = true;
                            			//if (!fromAddToMacBasket && config.id && changeTypeValue === "New") showInUI = false;





                                        console.log("readonly" + readonly);
										console.log("showInUI" + showInUI);
                                        updateMap[config.guid].push({
												//name: attribute.name,
												//value: changeTypeValue,
												//displayValue: changeTypeValue,
												//showInUi: true,
												//readOnly: true
												name: attribute.name,
                                				showInUi: showInUI,
                                				readOnly: readonly
										});
                                    }
									//End: DPG-3632
								}
							});
						}
					});
				}
				
				if ((comp.name === EMS_COMPONENT_NAMES.userSupport) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						if (config.attributes && Object.values(config.attributes).length > 0) {
							Object.values(config.attributes).forEach((attribute) => {
								if (attribute.name === 'ChangeType') {
									doUpdate = true;
									var changeTypeValue = attribute.value;
									if (!updateMap[config.guid])
										updateMap[config.guid] = [];
									if (!window.BasketChange === 'Change Solution' || (config.replacedConfigId ==='' || config.replacedConfigId ===undefined ||config.replacedConfigId ===null)) {
										console.log('Non MACD basket');
										if (!changeTypeValue) {
											changeTypeValue = 'New';
										}
										updateMap[config.guid].push({
											name: attribute.name,
												value: changeTypeValue,
												displayValue: changeTypeValue,
												showInUi: false,
												readOnly: true
										});
									} 




									//Start: DPG-3632 - Added for the MACD basket

									else {
                                        console.log("MACD basket");
                                        //var readonly = false;
                            			//if (config.id && changeTypeValue === "Cancel") readonly = true;
                            			var readonly = true;
                            			var showInUI = true;
                            			//if (!fromAddToMacBasket && config.id && changeTypeValue === "New") showInUI = false;



                                        console.log("readonly" + readonly);
										console.log("showInUI" + showInUI);
                                        updateMap[config.guid].push({
												//name: attribute.name,
												//value: changeTypeValue,
												//displayValue: changeTypeValue,
												//showInUi: true,
												//readOnly: true
												name: attribute.name,
                                				showInUi: showInUI,
                                				readOnly: readonly
										});
                                    }
									//End: DPG-3632			
								}
							});
						}
					});
				}
				
				if (doUpdate) {
					console.log('EMSPlugin_updateChangeTypeAttribute', updateMap);
					let keys = Object.keys(updateMap);
					var complock = comp.commercialLock;
					if(complock) comp.lock('Commercial', false);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
					if(complock) comp.lock('Commercial', true);
				}
			});
		}
	}
}

/************************************************************************************
* Author             : Monali Mukherjee
* Method Name : validateCancelSolution DPG-3632
* Invoked When: before save when CHangeType is Cancel
* Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all subscriptions change type is set to cancel
* Parameters : solution
***********************************************************************************/
EMSPlugin_validateCancelSolution = function (solution) {
    console.log("EMSPlugin_validateCancelSolution");
    let configs = Object.values(solution.schema.configurations);
	console.log('configs',configs);
	let changeTypeAttribute = Object.values(configs[0].attributes).filter(a => {return a.name==='ChangeType' && a.value==='Cancel'});
	if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
		return true;
	}
	let isValid = true;
	Object.values(solution.components).forEach((comp) => {
		if (comp.name === EMS_COMPONENT_NAMES.mobilityPlatformMgmt || EMS_COMPONENT_NAMES.userSupport) {
			if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
				Object.values(comp.schema.configurations).forEach((mobilesubConfig) => {
					changeTypeAttribute = Object.values(mobilesubConfig.attributes).filter(a => {return a.name==='ChangeType' && a.value!=='Cancel'});
					if (changeTypeAttribute && changeTypeAttribute.length > 0) {
						isValid = false;
					}
				});
			}
		}
	});
	if (!isValid){


		CS.SM.displayMessage('When canceling whole solution all Subscriptions must be canceled too!', 'error');


	}
	return isValid;
};

//-------------updateChangeTypeAttribute ---END
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
											displayValue: statusValue
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
        //DPG-3036 START
        async function checkValidationForConfigurationMS(){
				
				let currentBasket;
                let solution;
                var updateMap = {};
				var isMsPresent;
                var totalCount=0;
				var tenancyID="";
				var configurations = [];
				var component;
            	var configGuid;
				
                currentBasket = await CS.SM.getActiveBasket();
                solution = currentBasket.solutions;
                if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
                    for (const basketSol of Object.values(currentBasket.solutions)) {
						if (basketSol.name === EMS_COMPONENT_NAMES.solution) {
							component = basketSol.getComponentByName(EMS_COMPONENT_NAMES.solution);
							let cmpConfig = await basketSol.getConfigurations(); 
							if (cmpConfig && Object.values(cmpConfig).length > 0) {
								for (const config of Object.values(cmpConfig)) {
                                    configGuid = config.guid;
									tenancyIds = config.getAttribute("TenancyId"); 
									t1 = tenancyIds.value;
									tenancyID = t1;
								}
							}
							
							if (basketSol.components && Object.values(basketSol.components).length > 0) {
								for (const comp of Object.values(basketSol.components)) {
									let cmpConfig = await comp.getConfigurations(); 
									if (cmpConfig && Object.values(cmpConfig).length > 0) {
										totalCount = totalCount + 1;
                                        for (const config of Object.values(cmpConfig)) {
                                            configurations.push(config.guid);
                                        }
									}	
								}
								if(totalCount > 0){
									for(const config of configurations){
										updateMap[config] = [];
                                        updateMap[config].push({
                                            name: "TenancyID",
                                            value: tenancyID,
                                            displayValue: tenancyID
                                        });
                                        if (updateMap && Object.keys(updateMap).length > 0) {
                                            await component.updateConfigurationAttribute(
                                                config,
                                                updateMap[config],
                                                true
                                            );
                                        }
									}	
									
								}
							}	
						}
					}
				}

}
//DPG-3036 END
}
	   //DPG-3036 START
       var MSUtils = {
           setTenancyIdForProffesionalService:async function(tenancyID){
                
                let currentBasket;
                let solution;
                var updateMap = {};
				var isMsPresent;
                
                console.log('0');
                currentBasket = await CS.SM.getActiveBasket();
                solution = currentBasket.solutions;
                if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
                    for (const basketSol of Object.values(currentBasket.solutions)) {
                        if (basketSol.name === PSMDM_COMPONENT_NAMES.solution) {
                            let component = basketSol.getComponentByName(PSMDM_COMPONENT_NAMES.solution);
                            let cmpConfig = await basketSol.getConfigurations();
                            if (cmpConfig && Object.values(cmpConfig).length > 0) {
                                for (const config of Object.values(cmpConfig)) {
                                    let confgAttr = config.getAttributes();
                                    if (confgAttr && Object.values(confgAttr).length > 0) {
                                        updateMap[config.guid] = [];
                                        updateMap[config.guid].push({
                                            name: "TenancyID",
                                            value: tenancyID,
                                            displayValue: tenancyID
                                        });
                                        if (updateMap && Object.keys(updateMap).length > 0) {
                                            await component.updateConfigurationAttribute(
                                                config.guid,
                                                updateMap[config.guid],
                                                true
                                            );
                                        }
                                        
                                    }
                                }
                            }
                            
                            if (basketSol.components && Object.values(basketSol.components).length > 0) {
                                for (const comp of Object.values(basketSol.components)) {
                                    if (comp.name === PSMDM_COMPONENT_NAMES.UC) {
                                        let cmpConfig = await comp.getConfigurations();
                                        if (cmpConfig && Object.values(cmpConfig).length > 0) {
                                            for (const config of Object.values(cmpConfig)) {
                                                let confgAttr = config.getAttributes();
                                                if (confgAttr && Object.values(confgAttr).length > 0) {
                                                    updateMap[config.guid] = [];
                                                    updateMap[config.guid].push({
                                                        name: "TenancyID",
                                                        value: tenancyID,
                                                        displayValue: tenancyID
                                                    });
                                                    if (updateMap && Object.keys(updateMap).length > 0) {
                                                        await component.updateConfigurationAttribute(
                                                            config.guid,
                                                            updateMap[config.guid],
                                                            true
                                                        );
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
};
