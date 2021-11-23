/******************************************************************************************
*Author	   : Cloud Sense Team
Change Version History
Version No	Author 			Date
1 			Aman Soni 	10-Sep-19
2 			Aman Soni	15-Oct-19 Changes made as part of EDGE-81138
3.         Vishal Arbune   01-10-2019      EDGE-113083 : Show available OneFund balance from CIDN at the time of basket creation
4.         Romil Anand     02-10-2019      EDGE-115925 : Calculation of Total Basket amount on Validate & Save
5.         Romil Anand     05-10-2019      EDGE-114977 : UI changes to be made on Subscription page
6.         Romil Anand     10-10-2019      EDGE-113570 : Redemption amount cannot be more than the Charge Amount
7.         Romil Anand     12-10-2019      EDGE-113091 : Show Fund balance details on Subscription page for each Solution in the Basket
8.         Vishal Arbune   13-10-2019      EDGE-112359 : Cloudsense Opportunity basket flow
9.         Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
10.        Romil Anand     25-12-2019      EDGE-118038 : Eligible Redeemable charges (from Sigma to CS)-New Scenario
11.        Romil Anand     25-10-2019      EDGE-119323 : GST Calculation of Net Charge while Redemption
12.        Romil Anand     22-10-2019      EDGE-127941 : Calculate Total Contract Value for a Basket
13.        Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
14. 	   Romil Anand     19-FEB-2020     EDGE-136954- Implement code review comments provided by Governance Review
15. 	   Gnana	       26-APR-2020     EDGE-140968 : Enabling POS Redemption as Discount for New order of Device Outright Purchase	
16. 	   Shubhi		   22-May-2020	   EDGE-142082 : Added By Shubhi to Set Account Id for BAN story
17 .       RaviTeja        01-Jun-2020	   EDGE-146972 : Get the Device details for Stock Check before validate and Save as well
18		   Gnana		   10-Jun-2020	   EDGE-149887 : Solution Name Update Logic 
19. 	   Aman Soni	   22-Jun-2020	   EDGE-155354 : Set By Default DeviceEnrollment value to 'DO NOT ENROL'
20.        Pallavi D       01-Jul-2020     EDGE-154471:Spring 20 upgrade
21.		   Aditya		   21-07-2020		Edge:142084, Enable New Solution in MAC Basket		
22.         shubhi         22-08-2020      redemptions  fix post upgrade	
23. 	   Martand		   3-10-2020		REFACTORED		
24.		   Pooja Bhat      10-11-2020		EDGE-175750	
25. 		Martand 	   12-01-2021		EDGE-197707
26.			Arunkumar V		23-02-2021		EDGE-203192
27.         Antun B        01/06/2021       EDGE-198536: Performance improvements
28.         Aditya Pareek  04/10/2021       Updating with respect to R34 
********************/

/**
 * Information:
 * Utils = OELogic.js
 * pricingUtils = PricingUtils.js
 * stockcheckUtils = StockCheckUtils.js
 */

 var executeSaveDO = false;
 var saveDOP = false;
 var DOP_COMPONENT_NAMES = {
	 solution: "Device Outright Purchase", //updated
	 deviceOutRight: "Mobile Device",
	 inactiveSIM: "Inactive SIM"
 };
 //Added by Vishal
 var basket = "";
 var currentFundBalance = "";
 var basketStage = null;
 var crdoeschemaid = null;
 var show = false;
 var allowSaveDO = false;
 var communitySiteId;
 var solutionID;
 var IsDiscountCheckNeeded_DOP = false; // Added as part of EDGE_140968
 var IsRedeemFundCheckNeeded_DOP = false; // Added as part of EDGE_140968
 var callerName_DOP = ""; // Added as part of EDGE_140968
 var basketNum; // Added as part of EDGE_140968
 var DEFAULTSOLUTIONNAME_DOP = "Device Outright Purchase"; // Added as part of EDGE-149887
 
 //Register Plugin for the Device Outright Purchase
 if (CS.SM.registerPlugin) {
	 console.log("Loaded Device Outright Purchase Plugin");
	 window.document.addEventListener("SolutionConsoleReady", async function () {
		 console.log("SolutionConsoleReady");
		 await CS.SM.registerPlugin("Device Outright Purchase").then(async (DOPPlugin) => {
			 updateDOPlugin(DOPPlugin);
		 });
	 });
 }
 
 //Plugin Start
 function updateDOPlugin(DOPlugin) {
	 console.log("Inside Hooks", DOPlugin);
	 window.document.addEventListener("SolutionSetActive", async function (e) {
		 //EDGE-154471
		 await solutionSetActiveMethod(e);
		 return Promise.resolve(true);
	 });
 
	 //Added by Aman Soni
	 DOPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		 let solution = result.solution;
	   try{
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", false);
		 }
 
		 console.log("afterSave - entering");
		 let basket = await CS.SM.getActiveBasket();
		 //Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954,EDGE-136954
		 await RedemptionUtils.calculateBasketRedemption(basket, basket.basketId); //Added as part of EDGE-140968
		 canExecuteValidation = true;
		 Utils.updateOEConsoleButtonVisibility();
		 Utils.updateCustomButtonVisibilityForBasketStage();
		 await updateDeviceEnrollmentAfterSolutionLoad1();//added await EDGE-203192 //UnCommented EDGE-197707
		 //EDGE-135267
		 //Utils.hideSubmitSolutionFromOverviewTab();
		 await Utils.updateActiveSolutionTotals();
		 CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
 
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", true);
		 }
		 }catch(error) {
			 CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
			 console.log(error);
		 }
			 CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
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
	 //Added by Aman Soni
	 DOPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {
		 //EDGE-154471
		 let componentName = component.name;
		 let guid = configuration.guid;
		 let solution = await CS.SM.getActiveSolution();
 
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", false);
		 }
 
		 await window.afterAttributeUpdatedOE(component.name, guid, attribute, oldValueMap.value, attribute.value); //EDGE-154471
		 /**if(componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && newValue !== 0 && Utils.getAttributeValue('Not Before CRD', guid) <= Date.now())
	  {
		  CS.SM.updateConfigurationStatus(componentName,guid,false,'Not Before CRD date should be greater than today!!!');
		 }
		 **/
		 /* ADDED BY Romil FOR AMOUNT REDEMPTION EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954 */
		 //Only for DEVICE Out Right Components
		 if (componentName === DOP_COMPONENT_NAMES.deviceOutRight) {
			 if (["Device Type", "Quantity", "MobileHandsetManufacturer", "OneOffCharge", "taxTreatment"].includes(attribute.name)) {
				 RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName);
			 }
 
			 /* Added as part of EDGE-140968 - Start */
			 if (attribute.name === "RedeemFund") {
				 //RedemptionUtils.CheckRedeemFundDiscount(guid, componentName);
				 await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, attribute.value); //Edge-149830
				 await RedemptionUtilityCommon.calculateBasketRedemption(); //Edge-149830
				 if (attribute.value >= 0) await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, ""); //EDGE-169593
				 CalcDeviceRedeemFundGST(guid, attribute.value, componentName); 	//EDGE-175750: Added method call to calculate "RedeemFundIncGST" value
			 }
 
			 /* Added as part of EDGE-140968 - End */
			 /*------------------------------*/
			 //Added by Aman Soni
			 if (attribute.name === "Device Type") {
				 let attrsList = ["MobileHandsetManufacturer", "MobileHandsetModel", "MobileHandsetColour", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ManufacturerString", "ModelString", "ColourString", "OneOffCharge", "OneOffChargeGST", "RedeemFund", "RedeemFundIncGST", "Quantity"]; //EDGE-175750: Added-"RedeemFundIncGST"
				 attrsList.forEach((attr) => Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, attr, true));
 
				 let updateConfigMap = {
					 [guid]: [
						 {
							 name: "deviceTypeString",
							 value: attribute.displayValue,
							 displayValue: attribute.displayValue
						 }
					 ]
				 };
				 //await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
				 ///////////////
				 //EDGE-154471 start
				 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateConfigMap, true);
				 if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					 let keys = Object.keys(updateConfigMap);
					 for (let i = 0; i < keys.length; i++) {
						 await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					 }
				 }
				 //EDGE-154471 end
			 }
 
			 //Added by Aman Soni
			 if (attribute.name === "MobileHandsetManufacturer") {
				 let attrsList = ["MobileHandsetModel", "MobileHandsetColour", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ModelString", "ColourString", "OneOffCharge", "OneOffChargeGST", "RedeemFund", "RedeemFundIncGST", "Quantity"]; //EDGE-175750: Added-"RedeemFundIncGST"
				 attrsList.forEach((attr) => {
					 Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, attr, true);
				 });
 
				 //EDGE-154471 start
				 let updateConfigMap = {
					 [guid]: [
						 {
							 name: "ManufacturerString",
							 value: attribute.displayValue,
							 displayValue: attribute.displayValue
						 }
					 ]
				 };
				 await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
 
				 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateConfigMap, true);
				 /* if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					 let keys = Object.keys(updateConfigMap);
					 for (let i = 0; i < keys.length; i++) {
					 }
				 } */
				 //EDGE-154471 end
			 }
 
			 //Added by Aman Soni
			 if (attribute.name === "MobileHandsetModel") {
				 let attrsList = ["MobileHandsetColour", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ColourString", "OneOffCharge", "OneOffChargeGST", "RedeemFund", "RedeemFundIncGST", "Quantity"]; //EDGE-175750: Added-"RedeemFundIncGST"
				 attrsList.forEach((attr) => {
					 Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, attr, true);
				 });
				 //EDGE-154471 start
				 let updateConfigMap = {
					 [guid]: {
						 name: "ModelString",
						 value: attribute.displayValue,
						 displayValue: attribute.displayValue
					 }
				 };
				 await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
 
				 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateConfigMap, true);
				 /* if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					 let keys = Object.keys(updateConfigMap);
					 for (let i = 0; i < keys.length; i++) {
						 //console.log('Before update config ', keys[i]);
						 await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					 }
				 } */
				 //EDGE-154471 end
			 }
			 //Added by Aman Soni
			 if (attribute.name === "MobileHandsetColour") {
				 let attrsList = ["RedeemFund", "RedeemFundIncGST"];		//EDGE-175750: Added-"RedeemFundIncGST", Removed-"Quantity"
				 attrsList.forEach((attr) => {
					 Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, attr, true); //EDGE-175750:"RedeemFund" removed hardcoded value and replace with variable "attr"
				 });
				 //EDGE-154471 start
				 let updateConfigMap = {
					 [guid]: {
						 name: "ColourString",
						 value: attribute.displayValue,
						 displayValue: attribute.displayValue
					 }
				 };
 
				 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateConfigMap, true);
				 if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
					 let keys = Object.keys(updateConfigMap);
					 for (let i = 0; i < keys.length; i++) {
						 //console.log('Before update config ', keys[i]);
						 await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
					 }
				 }
				 //EDGE-154471 end
			 }
			 //Added by Aman Soni as a part of Device Enrollment
			 if (attribute.name === "InContractDeviceEnrollEligibility") {
				 DeviceEligibilityEnrol(guid);
			 }
		 } //END Only for Device Out Right componnents
 
				 // Laxmi Changes ---  //EDGE-203192 start
		 if(componentName === "Customer requested Dates" || componentName === "Delivery details"){
 
		 let schemaName = await Utils.getSchemaNameForConfigGuid(configuration.parentConfiguration);
			 if (schemaName.includes("Device")) {
 
				 comp = await solution.getComponentByName(DOP_COMPONENT_NAMES.deviceOutRight);
			 
			 }
			 else if (schemaName.includes("Sim")) {
				 comp = await solution.getComponentByName(DOP_COMPONENT_NAMES.inactiveSIM);
				 
			 }
 
			 let updateMap = {}; 
				 updateMap[configuration.parentConfiguration] = [];
 
		 if (componentName === "Customer requested Dates" && attribute.name === "Not Before CRD" && attribute.value !== 0) {
			 //Utils.markOEConfigurationInvalid(config.guid, 'Not Before CRD must be greater than today');
				 
			 notBeforeCRD = Utils.formatDate(attribute.value);
				 notBeforeCRD = new Date(attribute.value).setHours(0, 0, 0, 0);
 
			 //notBeforeCRD = newValue;
			 preferredCRDVel = configuration.getAttribute("Preferred CRD");				
				 preferredCRD = Utils.formatDate(preferredCRDVel.value);
				 notBeforeCRD = new Date(attribute.value).setHours(0, 0, 0, 0);
 
			 console.log("Preferred CRD", preferredCRD);
 
			 //handSet = Utils.getConfigAttributeValue("OneOffCharge", guid);
			 //console.log("Value of preferredCRD ------------------ ", preferredCRD + " This is for -------one off-" + handSet + "       notBeforeCRD  " + notBeforeCRD);
			 //resetPreferredCRD(notBeforeCRD, preferredCRD);
			 if (preferredCRD === "" || preferredCRD < notBeforeCRD || preferredCRD === "0" || preferredCRD === 0 || preferredCRD === NaN) {
				 let solution = await CS.SM.getActiveSolution();
				 await solution.updateOrderEnrichmentConfigurationAttribute(configuration.guid, configuration.guid, { name: "Preferred CRD", showInUi: true, displayValue: notBeforeCRD, value: notBeforeCRD }, true);
				 
									 
					 updateMap[configuration.parentConfiguration].push({
						 name: 'Preferred CRD',
						 value: attribute.value,
						 displayValue: attribute.value
					 });
 
				 
					 if (updateMap && Object.keys(updateMap).length > 0) {
						 console.log('updateMap = '+updateMap); 
						 await comp.updateConfigurationAttribute(configuration.parentConfiguration, updateMap[configuration.parentConfiguration], true);
					 }
 
			 }
				 
 
 
			 //console.log ('***************notBeforeCRD------ date --'+notBeforeCRD.getDate() + ' Month ' + notBeforeCRD.getMonth()+ 'Year --' + notBeforeCRD.getFullYear() );
		 }
			 
 
 
		 //EDGE-203192 Start 
				 if (configuration.parentConfiguration) {
					 if(attribute.name === 'Preferred CRD'){						
						 updateMap[configuration.parentConfiguration].push({
							 name: 'Preferred CRD',
							 value: attribute.value,
							 displayValue: attribute.value
						 });
 
					 }
					 else if(attribute.name === 'Not Before CRD'){						
						 updateMap[configuration.parentConfiguration].push({
							 name: 'Not Before CRD',
							 value: attribute.value,
							 displayValue: attribute.value
						 });
 
					 }
					 else if(attribute.name === 'DeliveryAddress'){
							 updateMap[configuration.parentConfiguration].push({
							 name: 'SiteDeliveryAddress',
							 value: attribute.value,
							 displayValue: attribute.value
						 });
 
					 }
					 else if(attribute.name === 'DeliveryContact'){
							 updateMap[configuration.parentConfiguration].push({
							 name: 'SiteDeliveryContact',
							 value: attribute.value,
							 displayValue: attribute.value
						 });
 
					 }
					 else{					
						 updateMap[configuration.parentConfiguration].push({
							 name: attribute.name,
							 value: attribute.value,
							 displayValue: attribute.value
						 });
					 }
					 if (updateMap && Object.keys(updateMap).length > 0) {
						 console.log('updateMap = '+updateMap); 
						 await comp.updateConfigurationAttribute(configuration.parentConfiguration, updateMap[configuration.parentConfiguration], true);
					 }
				 }
 
			 //end
		 }
		 if (componentName === DOP_COMPONENT_NAMES.solution && attribute.name === "BillingAccountLookup" && attribute.value !== null) {
			 //updateSolutionName_DOP(); // Added as part of EDGE-149887
			 CommonUtills.genericUpdateSolutionName(component, configuration, DOP_COMPONENT_NAMES.solution, DOP_COMPONENT_NAMES.solution);
		 }
 
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", true);
		 }
 
		 return Promise.resolve(true);
	 };
	 //Added by Aman Soni
	 DOPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment) {
			 CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
 
		 saveSolutionDO();
 
		 //updateSolutionName_DOP(); // Added as part of EDGE-149887 // Spring 20 Upgrade
		 //Added by romil  EDGE-116121,EDGE-136954
		 //RedemptionUtils.checkConfigurationStatus();
		 if (window.totalRedemptions > 0) {
			 var skipsave = await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, ""); //EDGE-169593
			 if (skipsave) return Promise.resolve(false);
		 }
		 if (saveDOP) {
			 saveDOP = false;
			 console.log("beforeSave - exiting true");
			 return Promise.resolve(true);
		 }
		 executeSaveDO = true;
		 return Promise.resolve(true);
	 };
 
	 //Added by Aman Soni
	 DOPlugin.afterOrderEnrichmentConfigurationAdd = async function (Component, configuration, orderEnrichmentConfiguration) {
		 let componentName = Component.name; // Get the basketId with CS.SM Getbasket and assign the basket Id to OECOnfig
		 //await initializeDOPOEConfigs();
		 let solution = await CS.SM.getActiveSolution();
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", false);
		 }
		 await Utils.initializeGenericOEConfigs();
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", true);
		 }
		 await solution.updateOrderEnrichmentConfigurationAttribute(
			 configuration.guid,
			 orderEnrichmentConfiguration.guid,
			 {
				 name: "basketId",
				 value: await CS.SM.getActiveBasketId()
			 },
			 true
		 );
 
		 window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
		 return Promise.resolve(true);
	 };
 
	 //Added by Aman Soni
	 DOPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		 console.log("afterConfigurationAdd", component, configuration);
		 //let solution = await CS.SM.getActiveSolution();
		 let basket = await CS.SM.getActiveBasket();
		 //Added by romil //Added by romil  EDGE-115925,EDGE-136954
		 await RedemptionUtils.calculateBasketRedemption(basket, basket.basketId);
		 await RedemptionUtils.populateNullValues(component, configuration);
		 let solution = await CS.SM.getActiveSolution();
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", false);
		 }
		 await Utils.initializeGenericOEConfigs();
		 if (basketStage === "Contract Accepted") {
			 solution.lock("Commercial", true);
		 }
 
		 return Promise.resolve(true);
	 };
 
	 //Added by Romil Anand
	 DOPlugin.afterConfigurationDelete = async function (component, configuration) {
		 console.log("Parent Config Delete - After", component.name, configuration);
		 //Added by romil Added by romil EDGE-113083, EDGE-115925,EDGE-136954
		 //await RedemptionUtils.calculateBasketRedemption();
		 //await RedemptionUtils.populatebasketAmount();
		 if (window.totalRedemptions > 0) await RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593
		 return Promise.resolve(true);
	 };
 
	 //Aditya: Spring Update for changing basket stage to Draft
	 DOPlugin.afterSolutionDelete = async function (solution) {
		 if (window.totalRedemptions > 0) await RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593
		 CommonUtills.updateBasketStageToDraft();
		 return Promise.resolve(true);
	 };
 
	 //Added by Aman Soni
	 //EDGE-154471 start
	 //DOPlugin.afterOETabLoaded = async function (configurationGuid, OETabName) {
	 window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
		 let solution = await CS.SM.getActiveSolution();
		 if (DOP_COMPONENT_NAMES.solution == solution.name) {
			 //console.log('afterOrderEnrichmentTabLoaded: ', configurationGuid, OETabName);
			 console.log("afterOrderEnrichmentTabLoaded: ", e.detail.configurationGuid, e.detail.orderEnrichment.name);
			 //var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
			 var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			 //window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
			 await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
		 }
		 return Promise.resolve(true);
	 });
 
	 //EDGE-154471 end
	 /**
	  * Author      : Antun Bartonicek 2019-08-30
	  * Ticket      : EDGE-108959
	  * Functions for processing iFrame messages
	  */
	 DOPlugin.processMessagesFromIFrame = function () {
		 if (!communitySiteId) {
			 return;
		 }
		 if (data) {
			 //console.log('DOPlugin.processMessagesFromIFrame:', data);
			 DOPPlugin_handleIframeMessage({
				 ["data"]: JSON.parse(sessionStorage.getItem("payload"))
			 });
		 }
		 if (close) {
			 //console.log('DOPlugin.processMessagesFromIFrame:', data);
			 DOPPlugin_handleIframeMessage({
				 ["data"]: sessionStorage.getItem("close")
			 });
		 }
	 };
 }
 //Plugin End
 
 /**
  * Functions
  *
  */
 
 const solutionSetActiveMethod = async (e) => {
	 let currentBasket = await CS.SM.getActiveBasket();
	 let loadedSolution = await CS.SM.getActiveSolution();
	 if (loadedSolution.name === DOP_COMPONENT_NAMES.solution) {
		 //EDGE-198536 Start: existing code moved inside active solution check
		 Utils.updateCustomButtonVisibilityForBasketStage();
		 window.addEventListener("message", DOPPlugin_handleIframeMessage);
		 setInterval(DOPPlugin_processMessagesFromIFrame, 500);
		 //EDGE-198536 End: existing code moved inside active solution check
		 
		 if (currentBasket.basketStageValue === "Contract Accepted") {
			 loadedSolution.lock("Commercial", false);
			 //await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DOP);
		 }
 
		 await updateDeviceEnrollmentAfterSolutionLoad1();//added await EDGE-203192 UnCommented EDGE-197707
		 //Added by romil Added by romil EDGE-113083, EDGE-115925,EDGE-136954
		 window.currentSolutionName = loadedSolution.name;
		 await CommonUtills.getBasketData(currentBasket);
		 await CommonUtills.getSiteDetails(currentBasket);
		 //RedemptionUtils.displayCurrentFundBalanceAmt();
		 await RedemptionUtilityCommon.calculateCurrentFundBalanceAmt(window.basketNum, currentBasket);
		 await RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593
		 basketId = currentBasket.basketId; //EDGE-154471
		 let inputMap = {};
		 inputMap["GetBasket"] = basketId;
		 inputMap["GetSiteId"] = "";
		 //inputMap["getUserTheme"] = ""; //Not used
 
		 if (accountId != null && basketStage !== "Contract Accepted") {
			 CommonUtills.setAccountID(DOP_COMPONENT_NAMES.solution, accountId);
		 }
		 /* await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
			 //EDGE-154471
			 //console.log('GetBasket finished with response: ', result);
			 var basket = JSON.parse(result["GetBasket"]);
			 //console.log('GetBasket: ', basket);
			 basketChangeType = basket.csordtelcoa__Change_Type__c;
			 basketStage = basket.csordtelcoa__Basket_Stage__c;
			 basketNum = basket.Name; // EDGE-140968 Gnana - code to get basket num
			 //console.log('basketNum...' + basketNum);
			 accountId = basket.csbb__Account__c;
			 communitySiteId = result["GetSiteId"];
			 userThemeValue = result["getUserTheme"];
 
			 window.oeSetBasketData(basketId, basketStage, accountId);
 
			 //Edge-142082 shubhi start
			 if (accountId != null && basketStage !== "Contract Accepted") {
				 CommonUtills.setAccountID(DOP_COMPONENT_NAMES.solution, accountId);
			 }
			 // Remove this after the SolutionActionHelper
			 //Edge-142082 shubhi End
			 // Aditya: Edge:142084 Enable New Solution in MAC Basket
			 //CommonUtills.setBasketChange(); //Not needed as vsriable not used
 
			 //addDefaultDOPOEConfigs();
			 await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DOP);
			 //Utils.updateComponentLevelButtonVisibility("Add IP Site", false, true);
		 }); */
		 await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_DOP);
 
		 await Utils.loadSMOptions();
		 //addDefaultDOPOEConfigs();
		 //DOPlugin.getConfiguredSiteIds();
		 await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, ""); //EDGE-169593
		 //await RedemptionUtils.calculateBasketRedemption();
		 //await RedemptionUtils.checkRedeemDiscountonload(loadedSolution); // Added as part of EDGE-140968
		 //Utils.updateComponentLevelButtonVisibility("Add IP Site", false, true);//
		 if (window.basketChangeType === "Change Solution") {
			 //Edge-142082 shubhi start
			 if (loadedSolution) {
				 let configs = loadedSolution.getConfigurations();
				 Object.values(configs).forEach((config) => {
					 let componentMap = new Map();
					 let componentMapattr = {};
					 if (config.attributes) {
						 componentMapattr["BillingAccountLookup"] = [];
						 componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: true });
						 componentMap.set(config.guid, componentMapattr);
						 //component.updateConfigurationAttribute(config.guid, componentMap[config.guid], true); RF++
					 }
				 });
				 //CommonUtills.attrVisiblityControl(DOP_COMPONENT_NAMES.solution, componentMap);
			 }
			 //Edge-142082 shubhi end
		 }
		 if (currentBasket.basketStage === "Contract Accepted") {
			 loadedSolution.lock("Commercial", true);
		 }
	 }
 };
 
 //Added by Aman Soni as a part of Device Enrollment
 //UnCommented EDGE-197707
 const updateDeviceEnrollmentAfterSolutionLoad1 = async () => {
	 let solution = await CS.SM.getActiveSolution(); //EDGE-154471
	 console.log("inside updateDeviceEnrollmentAfterSolutionLoad");
	 if (solution && solution.name.includes("Device Outright Purchase")) {
		 let updateMap = {};
		 //console.log('inside updateDeviceEnrollmentAfterSolutionLoad');
		 if (solution.components && Object.values(solution.components).length > 0) {
			 //EDGE-154471
			 //CHANGED Get the Component from the Solution By name, EDGE-197707 changed the Component Variable
			 let comp = solution.getComponentByName(DOP_COMPONENT_NAMES.deviceOutRight);
			 let configurations;
			 if (comp) {
				 //If Component found then Get all the configurations
				 configurations = comp.getConfigurations();
				 //EDGE-154471
				 if (configurations) {
					 //EDGE-154471
					 Object.values(configurations).forEach((config) => {
						 //EDGE-154471
						 //Get only the particular attribute
						 let attribute = config.getAttribute("InContractDeviceEnrollEligibility");
						 //EDGE-154471
						 if (attribute) {
							 if (attribute.value === "Eligible") {
								 updateMap[config.guid] = [
									 {
										 //EDGE-154471
										 name: "DeviceEnrollment",
										 required: true,
										 showInUI: true,
										 readOnly: false,
										 options: [CommonUtills.createOptionItem("ENROL"), CommonUtills.createOptionItem("DO NOT ENROL")] //R34UPGRADE
									 }
								 ];
								 //EDGE-154471
							 } else {
								 updateMap[config.guid] = [
									 {
										 //EDGE-154471
										 name: "DeviceEnrollment",
										 value: "NOT ELIGIBLE",
										 displayValue: "NOT ELIGIBLE",
										 showInUI: true,
										 readOnly: true,
										 options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
									 }
								 ]; //EDGE-154471
							 }
						 }
					 });
 
					 //EDGE-154471 start
					 if (updateMap && Object.keys(updateMap).length > 0) {
						 keys = Object.keys(updateMap);
						 for (let i = 0; i < keys.length; i++) {
							 await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						 }
					 }
					 //EDGE-154471 end
				 }
			 }
		 }
	 }
	 return Promise.resolve(true); //EDGE-154471
 };
 //DOPlugin_handleIframeMessage
 const DOPPlugin_handleIframeMessage = async (e) => {
	 console.log("handleIframeMessage from pricing:", e); //
	 var message = {};
	 message = e["data"];
	 message = message["data"];
	 let solution = await CS.SM.getActiveSolution();
	 solutionID = solution.solutionId;
	 console.log(e.data["data"]);
	 console.log(e.data["command"]);
	 console.log(e.data["caller"]);
	 console.log("solutionID-->" + solutionID);
	 let data = e.data["data"],
		 command = e.data["command"],
		 caller = e.data["caller"];
 
	 if (e.data && caller && command) {
		 if (caller !== "Mobile Device") {
			 return;
		 } else if (command === "pageLoad" + callerName_DOP && data === solutionID) {
			 await pricingUtils.postMessageToPricing(callerName_DOP, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded_DOP);
		 } else if (command === "StockCheck" && data === solutionID) {
			 await stockcheckUtils.postMessageToStockCheck(callerName_DOP, solutionID);
		 } else {
			 await pricingUtils.handleIframeDiscountGeneric(command, data, caller, e.data["IsDiscountCheckAttr"], e.data["IsRedeemFundCheckAttr"], e.data["ApplicableGuid"]);
		 }
	 }
 };
 
 const DOPPlugin_processMessagesFromIFrame = () => {
	 if (!communitySiteId) {
		 return;
	 }
	 if (Object.keys(sessionStorage).includes("payload")) {
		 DOPPlugin_handleIframeMessage({
			 data: JSON.parse(sessionStorage.getItem("payload"))
		 });
	 }
 
	 if (Object.keys(sessionStorage).includes("close")) {
		 DOPPlugin_handleIframeMessage({
			 data: sessionStorage.getItem("close")
		 });
	 }
 };
 
 /* async function DOPPlugin_handleIframeMessage(e) {
	 console.log("handleIframeMessage from pricing:", e);
	 let command = e.data["command"];
	 let caller = e.data["caller"];
	 let data = e.data["data"];
	 if (e.data && caller && command) {
		 if (caller !== "Mobile Device") {
			 return;
		 } else if (command === "pageLoad" + callerName_DOP && data === solutionID) {
			 await pricingUtils.postMessageToPricing(callerName_DOP, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded_DOP);
		 } else if (command === "StockCheck" && data === solutionID) {
			 await stockcheckUtils.postMessageToStockCheck(callerName_DOP, solutionID);
		 } else {
			 await pricingUtils.handleIframeDiscountGeneric(command, data, caller, e.data["IsDiscountCheckAttr"], e.data["IsRedeemFundCheckAttr"], e.data["ApplicableGuid"]);
		 }
	 }
 } */
 
 /**********************************************************************************************************************************************
  * Author	   : Tihomir Baljak
  * Method Name : initializeTIDOEConfigs
  * Invoked When: after solution is loaded, after configuration is added
  * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
  * Parameters  : none
  ********************************************************************************************************************************************/
 /* const initializeDOPOEConfigs = async () => {
	 //TODO Look into this
	 //console.log('initializeOEConfigs');
	 let currentSolution = await CS.SM.getActiveSolution();
	 let configurationGuid = "";
	 if (currentSolution) {
		 if (currentSolution.type && currentSolution.name.includes(DOP_COMPONENT_NAMES.solution)) {
			 for (const config of currentSolution.getConfigurations()) {
				 configurationGuid = config.guid;
				 let updateMap = {};
				 for (let oe of config.getOrderEnrichments()) {
					 let basketAttribute = await oe.getAttribute("basketid");
					 if (basketAttribute) {
						 if (!updateMap[oe.guid]) {
							 updateMap[oe.guid] = [{ name: basketAttribute.name, value: basketId }];
						 }
					 }
				 }
				 if (updateMap && Object.keys(updateMap).length > 0) {
					 keys = Object.keys(updateMap);
					 for (var i = 0; i < updateMap.length; i++) {
						 await comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid, keys[i], updateMap[keys[i]], true);
					 }
				 }
			 }
		 }
	 }
	 return Promise.resolve(true);
 }; */
 
 const saveSolutionDO = async () => {
	 if (executeSaveDO) {
		 executeSaveDO = false;
		 var oeerrorcount = 0;
		 let currentSolution = await CS.SM.getActiveSolution();
		 if (currentSolution.name.includes(DOP_COMPONENT_NAMES.solution && basketStage === "Contract Accepted")) {
			 //EDGE-154471
			 let comps = currentSolution.getComponents();
			 if (comps) {
				 Object.values(comps).forEach((comp) => {
					 //EDGE-154471
					 let configurations = comp.getConfigurations();
					 Object.values(configurations).forEach((config) => {
						 //EDGE-154471
						 let attributes = config.getAttributes();
						 Object.values(attributes).forEach((attr) => {
							 //EDGE-154471
							 if (((attr.name === "Not Before CRD" || attr.name === "Preferred CRD") && attr.value === 0) || ((attr.name === "Technicalcontactid" || attr.name === "Primarycontactid") && attr.value === "") || (attr.name === "Not Before CRD" && attr.value !== 0 && attr.value <= Date.now())) {
								 oeerrorcount = oeerrorcount + 1;
								 config.updateStatus({ status: false, message: "Error in Order Enrichment" });
							 }
						 });
					 });
				 });
			 }
		 }
		 if (oeerrorcount > 0 && !executeSaveDO) {
			 CS.SM.displayMessage("Order Enrichment has errors.It can be either Mandatory fields not populated/Not before CRD is lesser than or equal to today/Preferred CRD is lesser than Not Before CRD.", "error");
			 return Promise.resolve(false);
		 } else {
			 saveDOP = true;
			 return Promise.resolve(true); //EDGE-154471
		 }
	 }
 };
 
 const resetPreferredCRD = async (notBeforeCRD, preferredCRD) => {
	 let solution = await CS.SM.getActiveSolution(); //EDGE-154471
	 if (solution.name === DOP_COMPONENT_NAMES.solution) {
		 let comp = solution.getComponentByName(DOP_COMPONENT_NAMES.deviceOutRight);
		 //EDGE-154471
		 if (comp) {
			 //EDGE-154471
			 let configurations = comp.getConfigurations();
			 //if(comp.schema.changeType==='Change Request'){
			 for (let config of Object.values(configurations)) {
				 //EDGE-154471
				 let updateMapNew = {};
				 let oeList = config.getOrderEnrichments();
				 if (oeList) {
					 Object.values(oeList).forEach((oe) => {
						 //if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
						 if (!updateMapNew[oe.guid]) updateMapNew[oe.guid] = [];
						 ////////////
						 if (preferredCRD === "" || preferredCRD < notBeforeCRD || preferredCRD === "0" || preferredCRD === 0 || preferredCRD === NaN) {
							 updateMapNew[oe.guid].push({ name: "Preferred CRD", showInUi: true, displayValue: notBeforeCRD, value: notBeforeCRD });
						 }
					 });
				 }
				 //EDGE-154471 start
				 if (updateMapNew && Object.keys(updateMapNew).length > 0) {
					 keys = Object.keys(updateMapNew);
					 for (var i = 0; i < updateMapNew.length; i++) {
						 await comp.updateOrderEnrichmentConfigurationAttribute(keys[i], keys[i], updateMapNew[keys[i]], true);
					 }
				 }
				 //EDGE-154471 end
				 var notBeforeCRDValidation = new Date();
				 notBeforeCRDValidation.setHours(0, 0, 0, 0);
				 if (notBeforeCRD <= notBeforeCRDValidation) {
					 CS.SM.displayMessage("Not Before CRD date should be greater than today ");
					 //EDGE-154471 start
					 //CS.SM.updateConfigurationStatus(DOP_COMPONENT_NAMES.deviceOutRight, config.guid, false, 'Not Before CRD date should be greater than today!!!');
					 config.status = false;
					 config.statusMessage = "Not Before CRD date should be greater than today!!!";
					 //EDGE-154471 end
				 } else {
					 //EDGE-154471 start
					 //CS.SM.updateConfigurationStatus(DOP_COMPONENT_NAMES.deviceOutRight, config.guid, true, '');
					 config.status = true;
					 config.statusMessage = "";
					 //EDGE-154471 end
				 } //TODO needs to be updated in the Attribute Value
			 }
		 }
	 }
 };
 
 /* 	
	 Added as part of EDGE-149887 
	 This method updates the Solution Name based on Offer Name if User didnt provide any input
 */
 const updateSolutionName_DOP = async () => {
	 var listOfAttributes = ["Solution Name", "Device Outright Purchase", "GUID"],
		 attrValuesMap = {};
	 attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, DOP_COMPONENT_NAMES.solution);
	 //console.log('attrValuesMap...' + attrValuesMap['Solution Name']);
	 //console.log('attrValuesMap...' + attrValuesMap['GUID']);
 
	 let updateConfigMap = {};
	 if (attrValuesMap["Solution Name"] === DEFAULTSOLUTIONNAME_DOP) {
		 //EDGE-154471 start
		 let configGuid;
		 configGuid = attrValuesMap["GUID"];
		 updateConfigMap[configGuid] = [];
		 updateConfigMap[attrValuesMap["GUID"]].push({
			 name: "Solution Name",
			 value: attrValuesMap["Device Outright Purchase"],
			 displayValue: attrValuesMap["Device Outright Purchase"]
		 });
		 //EDGE-154471 end
		 //EDGE-154471 start
		 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.solution, updateConfigMap, true);
		 let solution = await CS.SM.getActiveSolution();
		 let component = solution.getComponentByName(DOP_COMPONENT_NAMES.solution);
		 //solution.lock('Commertial',false);
		 if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
			 keys = Object.keys(updateConfigMap);
			 for (let i = 0; i < keys.length; i++) {
				 await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
			 }
		 }
		 //EDGE-154471 End
	 }
 };
 
 const DeviceEligibilityEnrol = async (guid) => {
	 let solution = await CS.SM.getActiveSolution(); //EDGE-154471
	 if (solution.name.includes("Device Outright Purchase")) {
		 let comp = Object.values(solution.components).find((comp) => comp.name === DOP_COMPONENT_NAMES.deviceOutRight);
		 //EDGE-154471
		 if (comp) {
			 let config = comp.getConfiguration(guid);
			 if (config) {
				 //EDGE-154471
				 if (config) {
					 let updateConfigMap = {};
					 let configAttr = config.getAttribute("InContractDeviceEnrollEligibility");
					 //EDGE-154471
					 if (configAttr) {
						 console.log("Inside config---", configAttr.value);
						 if (configAttr.value) {
							 updateConfigMap[config.guid] = [];
							 if (configAttr.value === "Eligible") {
								 updateConfigMap[config.guid].push({
									 //EDGE-154471
									 name: "DeviceEnrollment",
									 value: "DO NOT ENROL",
									 displayValue: "DO NOT ENROL",
									 required: true,
									 showInUI: true,
									 readOnly: false,
									 options: [CommonUtills.createOptionItem("ENROL"), CommonUtills.createOptionItem("DO NOT ENROL")] //R34UPGRADE
								 });
							 } else {
								 updateConfigMap[config.guid].push({
									 //EDGE-154471
									 name: "DeviceEnrollment",
									 value: "NOT ELIGIBLE",
									 displayValue: "NOT ELIGIBLE",
									 showInUI: true,
									 readOnly: true,
									 options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
								 });
							 }
						 } else {
							 updateConfigMap[config.guid] = [];
							 updateConfigMap[config.guid].push({
								 //EDGE-154471
								 name: "DeviceEnrollment",
								 value: "",
								 displayValue: "",
								 showInUI: false,
								 readOnly: false,
								 options: [CommonUtills.createOptionItem("")] //R34UPGRADE 
							 });
						 }
						 //CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateConfigMap, true); //EDGE-154471
						 if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
							 let keys = Object.keys(updateConfigMap);
							 for (let i = 0; i < keys.length; i++) {
								 await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
							 }
						 }
					 }
				 }
			 }
		 }
	 }
	 return Promise.resolve(true);
 };
 
 //EDGE-175750: Added below method to calculate RedeemFundIncGST price value
 const CalcDeviceRedeemFundGST = async (guid, newValue, componentName) => {
	 let updateMap = {};
	 updateMap[guid] = [];
	 let solution = await CS.SM.getActiveSolution();
	 let comp = await solution.getComponentByName(componentName);
	 if (comp && newValue !== null && newValue !== undefined) {
		 let redeemFundExGSTRounded = (newValue === "" || newValue === null || newValue === undefined ? 0 : parseFloat(newValue).toFixed(2));
		 let redeemFundIncGSTRounded = parseFloat(redeemFundExGSTRounded * 1.1).toFixed(2);
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
	 return Promise.resolve(true);
 }; 
