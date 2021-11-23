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
22.         shubhi         22-08-20202      redemptions  fix post upgrade																	 
********************/
var executeSaveDO = false;
var saveDOP = false;
var DOP_COMPONENT_NAMES = {
	solution: 'Device Outright Purchase', //updated
	deviceOutRight: 'Mobile Device',
	inactiveSIM: 'Inactive SIM'
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
let IsDiscountCheckNeeded_DOP = false; // Added as part of EDGE_140968
let IsRedeemFundCheckNeeded_DOP = false; // Added as part of EDGE_140968
let callerName_DOP = ''; // Added as part of EDGE_140968
var basketNum; // Added as part of EDGE_140968
var DEFAULTSOLUTIONNAME_DOP = 'Device Outright Purchase';  // Added as part of EDGE-149887
/*if (CS.SM.createPlugin) { //EDGE-154471 removed 
	console.log('Load Device Outright Purchase plugin');
	DOPlugin = CS.SM.createPlugin('Device Outright Purchase');
	window.addEventListener('message', DOPPlugin_handleIframeMessage);
	setInterval(DOPPlugin_processMessagesFromIFrame, 500);
	document.addEventListener('click', function (e) {
		e = e || window.event;
		var target = e.target || e.srcElement;
		var text = target.textContent || target.innerText;
		console.log('Inside eventListner--->');
		if (text && text.toLowerCase() === 'mobile device') {
		}
	}, false);
	setInterval(saveSolutionDO, 500);
}*///EDGE-154471 end
//EDGE-154471 start
if (CS.SM.registerPlugin) {
	console.log('Loaded Device Outright Purchase Plugin');
	window.document.addEventListener('SolutionConsoleReady', async function () {
		console.log('SolutionConsoleReady');
		await CS.SM.registerPlugin('Device Outright Purchase')
			.then(async DOPlugin => {
				updateDOPlugin(DOPlugin);
			});
	});
}
//EDGE-154471 end
//EDGE-154471 start
function updateDOPlugin(DOPlugin) {
	console.log('inside hooks', DOPlugin);

	//added by shubhi for EDGE-170148
    Utils.updateCustomButtonVisibilityForBasketStage();

	window.addEventListener('message', DOPPlugin_handleIframeMessage);
	setInterval(DOPPlugin_processMessagesFromIFrame, 500);
	document.addEventListener('click', function (e) {
		e = e || window.event;
		var target = e.target || e.srcElement;
		var text = target.textContent || target.innerText;
		console.log('Inside eventListner--->');
		if (text && text.toLowerCase() === 'mobile device') {
		}
	}, false);
	setInterval(saveSolutionDO, 500);
	//Added by Aman Soni
	//DOPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {//EDGE-154471
	window.document.addEventListener('SolutionSetActive', async function (e) {//EDGE-154471
		let currentBasket = await CS.SM.getActiveBasket();
		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.name === DOP_COMPONENT_NAMES.solution) {
			if (currentBasket.basketStageValue === 'Contract Accepted'){
                loadedSolution.lock('Commercial',false);
			}    
			 
			updateDeviceEnrollmentAfterSolutionLoad1();
			//Added by romil Added by romil EDGE-113083, EDGE-115925,EDGE-136954
			window.currentSolutionName = loadedSolution.name;
			//RedemptionUtils.displayCurrentFundBalanceAmt();
			await RedemptionUtilityCommon.claculateCurrentFundBalanceAmt();//EDGE-169593
			await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
			//Getting the baket Id
			//console.log('solution loaded name!!! ', loadedSolution.name);
			//if (loadedSolution.type && loadedSolution.name.includes(DOP_COMPONENT_NAMES.solution)) {
			//await CS.SM.getCurrentCart().then(cart => {//EDGE-154471
			//console.log('Basket: ', cart);
			basketId = currentBasket.basketId;//EDGE-154471
			//console.log('Basket ID CRD-------------' + basketId);
			//});
			let inputMap = {};
			inputMap['GetBasket'] = basketId;
			inputMap['GetSiteId'] = '';
			inputMap['getUserTheme'] = '';
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {//EDGE-154471
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
				//console.log('communitySiteId: ', communitySiteId);
				//console.log('userThemeValue: ', userThemeValue);
				//console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId)
				window.oeSetBasketData(basketId, basketStage, accountId);
				
				//Edge-142082 shubhi start
				if (accountId != null && basketStage !== 'Contract Accepted') {
					//console.log('DOP_COMPONENT_NAMES.solution-->' + DOP_COMPONENT_NAMES.solution);
					CommonUtills.setAccountID(DOP_COMPONENT_NAMES.solution, accountId);
				}
				 
				//Edge-142082 shubhi End
				 // Aditya: Edge:142084 Enable New Solution in MAC Basket
			    CommonUtills.setBasketChange();														
									  
				//addDefaultDOPOEConfigs();
				Utils.loadSMOptions();
				Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
			});

			//addDefaultDOPOEConfigs();
			Utils.addDefaultGenericOEConfigs(DOP_COMPONENT_NAMES.solution);
			//DOPlugin.getConfiguredSiteIds();
			await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, '');//EDGE-169593
			//await RedemptionUtils.calculateBasketRedemption();
			//await RedemptionUtils.checkRedeemDiscountonload(loadedSolution); // Added as part of EDGE-140968
			Utils.loadSMOptions();
			Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
			//}
			if (window.basketChangeType === 'Change Solution') {
				let componentMap = new Map();
				let componentMapattr = {};
				//Edge-142082 shubhi start
				if (loadedSolution) {
					Object.values(loadedSolution.schema.configurations).forEach((config) => {
						if (config.attributes) {
							componentMapattr['BillingAccountLookup'] = [];
							componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': true });
							componentMap.set(config.guid, componentMapattr);
						}
					});
					CommonUtills.attrVisiblityControl(DOP_COMPONENT_NAMES.solution, componentMap);
				}
				//Edge-142082 shubhi end
			}
			if (currentBasket.basketStage === 'Contract Accepted'){
                loadedSolution.lock('Commercial',true);
			} 
		}
		return Promise.resolve(true);
	});
	//Added by Aman Soni
	DOPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		let solution = result.solution;

		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',false);
		}

		console.log('afterSave - entering');
		//Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954,EDGE-136954
		await RedemptionUtils.calculateBasketRedemption();//Added as part of EDGE-140968
		/*await RedemptionUtils.checkRedeemDiscountonload(solution); // Added as part of EDGE-140968
		await RedemptionUtils.calculateBasketRedemption();
		await RedemptionUtils.displayCurrentFundBalanceAmt();
		await RedemptionUtils.populatebasketAmount();
		await RedemptionUtils.populatebasketAmountforSaved();
		await RedemptionUtils.checkConfigurationStatus();*/
		canExecuteValidation = true;
		Utils.updateOEConsoleButtonVisibility();
		Utils.updateCustomButtonVisibilityForBasketStage();
		updateDeviceEnrollmentAfterSolutionLoad1();
		//EDGE-135267		
		Utils.hideSubmitSolutionFromOverviewTab();
		await Utils.updateActiveSolutionTotals();
		CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}
		return Promise.resolve(true);
	}
	/**
		* Provides the user with an opportunity to do something once the attribute is updated.
		*
		* @param {string} component - Component object where the configuration resides
		* @param {Object} configuration - Main Configuration object to which the deleted OE configuration is linked to
		* @param {object} attribute - The attribute which is being updated.
		* @param {string} oldValueMap - Before change value.
		*/
	//Added by Aman Soni
	DOPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {//EDGE-154471
		let componentName = component.name;
		let guid = configuration.guid;
		let solution = await CS.SM.getActiveSolution();

		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',false);
		}
		//console.log('DOP Attribute Update - After', componentName, guid, attribute, oldValue, newValue);
		// COmmented for testing 
		//window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
		await window.afterAttributeUpdatedOE(component.name, guid, attribute, oldValueMap.value, attribute.value); //EDGE-154471
		/**if(componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && newValue !== 0 && Utils.getAttributeValue('Not Before CRD', guid) <= Date.now())
		{
			CS.SM.updateConfigurationStatus(componentName,guid,false,'Not Before CRD date should be greater than today!!!');
		}
		**/
		/* ADDED BY Romil FOR AMOUNT REDEMPTION EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954 */
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && (attribute.name === 'Device Type' || attribute.name === 'Quantity' || attribute.name === 'MobileHandsetManufacturer' || attribute.name === 'OneOffCharge' || attribute.name === 'RedeemFund' || attribute.name === 'taxTreatment')) {
			RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName);
			/*await RedemptionUtils.displayCurrentFundBalanceAmt();
			await RedemptionUtils.calculateBasketRedemption();
			await RedemptionUtils.populatebasketAmount();
			await RedemptionUtils.populatebasketAmountforSaved();*/
		}
		/* Added as part of EDGE-140968 - Start */
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'RedeemFund') {
			//RedemptionUtils.CheckRedeemFundDiscount(guid, componentName);
			await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, attribute.value); //Edge-149830
			await RedemptionUtilityCommon.calculateBasketRedemption(); //Edge-149830
                        if (attribute.value >= 0)
                                await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, '');//EDGE-169593
		}
		/* Added as part of EDGE-140968 - End */
		/*------------------------------*/
		//Added by Aman Soni
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'Device Type') {
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetManufacturer', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetModel', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ManufacturerString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ModelString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffCharge', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffChargeGST', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'RedeemFund', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'Quantity', true);
			let updateConfigMap = {};
			//EDGE-154471 start
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'deviceTypeString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			});
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
		//Added by Aman Soni
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'MobileHandsetManufacturer') {
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetModel', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ModelString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffCharge', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffChargeGST', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'RedeemFund', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'Quantity', true);
			let updateConfigMap = {};
			//EDGE-154471 start
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'ManufacturerString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			});
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
		//Added by Aman Soni
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'MobileHandsetModel') {
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffCharge', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffChargeGST', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'RedeemFund', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'Quantity', true);
			let updateConfigMap = {};
			//EDGE-154471 start
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'ModelString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			});
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
		//Added by Aman Soni
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'MobileHandsetColour') {
			//Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'InContractDeviceEnrollEligibility', true);spring 20' upgrade
			//Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'DeviceEnrollment', true);spring 20' upgrade
			//Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffCharge', true); //EDGE-154471
			//Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'OneOffChargeGST', true); //EDGE-154471
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'RedeemFund', true);
			Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'Quantity', true);
			let updateConfigMap = {};
			//EDGE-154471 start
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: 'ColourString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			});
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
		if (componentName === DOP_COMPONENT_NAMES.deviceOutRight && attribute.name === 'InContractDeviceEnrollEligibility') {
			DeviceEligibilityEnrol(guid);
		}
		// Laxmi Changes ---
		if (componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && attribute.value !== 0) {
			//Utils.markOEConfigurationInvalid(config.guid, 'Not Before CRD must be greater than today');
			notBeforeCRD = Utils.formatDate(attribute.value);
			//notBeforeCRD = newValue;
			preferredCRD = Utils.getAttributeValue('Preferred CRD', guid);
			handSet = Utils.getConfigAttributeValue('OneOffCharge', guid);
			console.log('Value of preferredCRD ------------------ ', preferredCRD + ' This is for -------one off-' + handSet + '       notBeforeCRD  ' + notBeforeCRD);
			resetPreferredCRD(notBeforeCRD, preferredCRD);
			notBeforeCRD = new Date(attribute.value).setHours(0, 0, 0, 0);
			//console.log ('***************notBeforeCRD------ date --'+notBeforeCRD.getDate() + ' Month ' + notBeforeCRD.getMonth()+ 'Year --' + notBeforeCRD.getFullYear() );
		}
		if(componentName === DOP_COMPONENT_NAMES.solution && attribute.name === 'BillingAccountLookup' && attribute.value !== null ){
			updateSolutionName_DOP(); // Added as part of EDGE-149887
		}

		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}

		return Promise.resolve(true);
	}
	//Added by Aman Soni
	DOPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment) {
		//updateSolutionName_DOP(); // Added as part of EDGE-149887 // Spring 20 Upgrade
		//Added by romil  EDGE-116121,EDGE-136954
		//RedemptionUtils.checkConfigurationStatus();
		if(window.totalRedemptions>0){
			var skipsave = await RedemptionUtilityCommon.validateBasketRedemptions(false, DOP_COMPONENT_NAMES.deviceOutRight, '');//EDGE-169593
			if(skipsave)
			return Promise.resolve(false);
		}
			if (saveDOP) {
			saveDOP = false;
			console.log('beforeSave - exiting true');
			return Promise.resolve(true);
		}
		executeSaveDO = true;
		return Promise.resolve(true);
	}
	//Added by Aman Soni
	DOPlugin.afterOrderEnrichmentConfigurationAdd = async function (Component, configuration, orderEnrichmentConfiguration) {
		let componentName = Component.name;
		let solution = await CS.SM.getActiveSolution();

		console.log('TID afterOrderEnrichmentConfigurationAdd', componentName, configuration, orderEnrichmentConfiguration);
		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}
		await initializeDOPOEConfigs();
		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}
		window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	}
	//Added by Aman Soni
	DOPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
		console.log('afterConfigurationAdd', component, configuration);
		let solution = await CS.SM.getActiveSolution();

		//Added by romil //Added by romil  EDGE-115925,EDGE-136954
		await RedemptionUtils.calculateBasketRedemption();
		await RedemptionUtils.populateNullValues(component.name, configuration);
			if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}
		await initializeDOPOEConfigs();
		if (basketStage === 'Contract Accepted'){ 
			solution.lock('Commercial',true);
		}
		return Promise.resolve(true);
	}
	//Added by Romil Anand
	DOPlugin.afterConfigurationDelete = async function (component, configuration) {
		console.log('Parent Config Delete - After', component.name, configuration);
		//Added by romil Added by romil EDGE-113083, EDGE-115925,EDGE-136954
		//await RedemptionUtils.calculateBasketRedemption();
		//await RedemptionUtils.populatebasketAmount();
		if(window.totalRedemptions>0)
			await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
		return Promise.resolve(true);
	}
	//Aditya: Spring Update for changing basket stage to Draft
	DOPlugin.afterSolutionDelete = async function (solution) {
		if(window.totalRedemptions>0)
			await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
		CommonUtills.updateBasketStageToDraft();
		return Promise.resolve(true);
	}
	//Added by Aman Soni
	//EDGE-154471 start
	//DOPlugin.afterOETabLoaded = async function (configurationGuid, OETabName) {
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if (DOP_COMPONENT_NAMES.solution == solution.name) {
			//console.log('afterOrderEnrichmentTabLoaded: ', configurationGuid, OETabName);
			console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
			//var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			//window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
			await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
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
		var data = sessionStorage.getItem("payload");
		var close = sessionStorage.getItem("close");
		var message = {};
		if (data) {
			//console.log('DOPlugin.processMessagesFromIFrame:', data);
			message['data'] = JSON.parse(data);
			DOPlugin_handleIframeMessage(message);
		}
		if (close) {
			//console.log('DOPlugin.processMessagesFromIFrame:', data);
			message['data'] = close;
			DOPlugin_handleIframeMessage(message);
		}
	}
}
//EDGE-154471 end
//Added by Aman Soni
async function addDefaultDOPOEConfigs() {
	if (basketStage !== 'Contract Accepted')
		return;
	console.log('addDefaultOEConfigs');
	var oeMap = [];
	//await CS.SM.getActiveSolution().then((currentSolution) => {
	let currentSolution = await CS.SM.getActiveSolution();
	console.log('addDefaultOEConfigs ', currentSolution, DOP_COMPONENT_NAMES.solution);
	if (currentSolution.name.includes(DOP_COMPONENT_NAMES.solution)) {//EDGE-154471
		if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154471
			Object.values(currentSolution.components).forEach((comp) => {
				Object.values(comp.schema.configurations).forEach((config) => {
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
						var found = false;
						if (config.orderEnrichmentList) {
							var oeConfig = Object.values(config.orderEnrichmentList).filter(oe => { return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId) });
							if (oeConfig && oeConfig.length > 0)
								found = true;
						}
						if (!found) {
							var el = {};
							el.componentName = comp.name;
							el.configGuid = config.guid;
							//el.oeSchemaId = oeSchema.id;
							el.oeSchema = oeSchema;
							oeMap.push(el);
							console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
						}
						//}
					});
				});
			});
		}
	}
	//}).then(() => Promise.resolve(true));
	//EDGE-154471 start
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
		console.log('Adding default oe config map--:', oeMap);
		for (var i = 0; i < oeMap.length; i++) {
			console.log(' Component name ----' + oeMap[i].componentName);
			let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
			let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
			await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
		};
	}
	//EDGE-154471 end
	await initializeDOPOEConfigs();	
	return Promise.resolve(true);
}
//Updated DeviceEnrollment value and displayValue to "DO NOT ENROL" from "ENROL" as part of EDGE-155354 by Aman Soni
async function DeviceEligibilityEnrol(guid) {
	//CS.SM.getActiveSolution().then((solution) => {//EDGE-154471 start
	//  Utils.emptyValueOfAttribute(guid, DOP_COMPONENT_NAMES.deviceOutRight, 'DeviceEnrollment', true);
	let currentBasket = await CS.SM.getActiveBasket();//EDGE-154471
	let solution = await CS.SM.getActiveSolution();//EDGE-154471
	if (solution.name.includes('Device Outright Purchase')) {
		if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154471
			for (let comp of Object.values(solution.components)) {//EDGE-154471
				if (comp.name === DOP_COMPONENT_NAMES.deviceOutRight) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154471
						for (let config of Object.values(comp.schema.configurations)) {//EDGE-154471
							if (config.guid === guid) {
								let updateConfigMap = {};
								for (let configAttr of Object.values(config.attributes)) {//EDGE-154471
									if (configAttr.name === 'InContractDeviceEnrollEligibility') {
										console.log('Inside config---', configAttr.value);
										if (configAttr.value !== '' && configAttr.value !== null) {
											updateConfigMap[config.guid] = [];
											if (configAttr.value === 'Eligible') {
												updateConfigMap[config.guid].push({//EDGE-154471
													name: 'DeviceEnrollment',
													value:"DO NOT ENROL",
													displayValue: "DO NOT ENROL",
													required:true,
													showInUI: true,
													readOnly:false,
													options: ["ENROL",
															"DO NOT ENROL"
													]
												});
											} else {
												updateConfigMap[config.guid].push({//EDGE-154471
													name: 'DeviceEnrollment',
													value: "NOT ELIGIBLE",
													displayValue: "NOT ELIGIBLE",
													showInUI: true,
													readOnly: true,
													options: ["NOT ELIGIBLE"]
												});
											}
										} else {
											updateConfigMap[config.guid] = [];
											updateConfigMap[config.guid].push({//EDGE-154471
												name: 'DeviceEnrollment',
												value: "",
												displayValue: "",
												showInUI: false,
												readOnly: false,
												options: [""]
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
				}
			}
		}
	}
	//}).then(() => Promise.resolve(true));//EDGE-154471 end 
	return Promise.resolve(true);
}
//Added by Aman Soni as a part of Device Enrollment
async function updateDeviceEnrollmentAfterSolutionLoad1() {
	let currentBasket = await CS.SM.getActiveBasket();//EDGE-154471
	let solution = await CS.SM.getActiveSolution();//EDGE-154471
	let solutionName = solution.name; //EDGE-154471
	console.log('inside updateDeviceEnrollmentAfterSolutionLoad');
	//CS.SM.getActiveSolution().then((solution) => {
	if (solution.name.includes('Device Outright Purchase')) {
		var updateMap = {};
		//console.log('inside updateDeviceEnrollmentAfterSolutionLoad');
		if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154471
			var updateMapDevice = {};
			for (let comp of Object.values(solution.components)) {//EDGE-154471
				if (comp.name === DOP_COMPONENT_NAMES.deviceOutRight) {
					//console.log('inside device component');
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154471
						Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154471
							//if (config.guid === guid) {
							Object.values(config.attributes).forEach((configAttr) => {//EDGE-154471
								//console.log('inside device config--');
								if (configAttr.name === 'InContractDeviceEnrollEligibility') {
									if (configAttr.value === 'Eligible') {
										updateMap[config.guid] = [];//EDGE-154471
										updateMap[config.guid].push({//EDGE-154471
											name: 'DeviceEnrollment',
											required: true,
											showInUI: true,
											readOnly: false,
											options: ["ENROL",
												"DO NOT ENROL"]
										});
									} else {
										updateMap[config.guid] = [];//EDGE-154471
										updateMap[config.guid].push({//EDGE-154471
											name: 'DeviceEnrollment',
											value: "NOT ELIGIBLE",
											displayValue: "NOT ELIGIBLE",
											showInUI: true,
											readOnly: true,
											options: ["NOT ELIGIBLE"]
										});
									}
								}
							});
							//}
						});
					}
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
			//CS.SM.updateConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, updateMap, true);			
		}
	}
	//EDGE-154471 start
	//}).then(
	//	() => Promise.resolve(true)
	//);
	//EDGE-154471 end
	return Promise.resolve(true);//EDGE-154471
}
/**********************************************************************************************************************************************
* Author	   : Tihomir Baljak
* Method Name : initializeTIDOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. sets basket id to oe configs so it is available immediately after opening oe
* Parameters  : none
********************************************************************************************************************************************/
async function initializeDOPOEConfigs(){
    //console.log('initializeOEConfigs');
	let currentSolution = await CS.SM.getActiveSolution();
	let configurationGuid = '';
	if (currentSolution) {
		//console.log('initializeOEConfigs - updating');
		currentSolution.get
        if (currentSolution.type && currentSolution.name.includes(DOP_COMPONENT_NAMES.solution)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                //for (var i=0; i<currentSolution.components.length; i++) {PD
				for(const comp of Object.values(currentSolution.components)){
                    //var comp = currentSolution.components[i];PD
				   // for (var j=0; j<comp.schema.configurations.length; j++) {PD
				   for(const config of Object.values(comp.schema.configurations)){
						//var config = comp.schema.configurations[j]; //PD
						configurationGuid = config.guid;
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {
                                var oe = Object.values(config.orderEnrichmentList)[k];
                                var basketAttribute = Object.values(oe.attributes).filter(a => {
                                    return a.name.toLowerCase() === 'basketid'
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    if (!updateMap[oe.guid])
                                        updateMap[oe.guid] = [];
                                    updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
									//console.log ('Basket ID -------------', basketId);
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
							keys = Object.keys(updateMap);
							//console.log('initializeOEConfigs updateMap:', updateMap);
							for(var i=0; i< updateMap.length;i++){
								await comp.updateOrderEnrichmentConfigurationAttribute(configurationGuid,keys[i],updateMap[keys[i]],true)
							}
						}
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}

async function saveSolutionDO() {
	if (executeSaveDO) {
		executeSaveDO = false;
		var oeerrorcount = 0;
		//await CS.SM.getActiveSolution().then((currentSolution) => {
		let currentBasket = await CS.SM.getActiveBasket();
		let currentSolution = await CS.SM.getActiveSolution();
		if (currentSolution.name.includes(DOP_COMPONENT_NAMES.solution)) {//EDGE-154471
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				Object.values(currentSolution.components).forEach((comp) => {//EDGE-154471
					Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154471
						Object.values(config.attributes).forEach((attr) => {//EDGE-154471
							if (basketStage === 'Contract Accepted') {
								if (((attr.name === 'Not Before CRD' || attr.name === 'Preferred CRD') && attr.value === 0) || ((attr.name === 'Technicalcontactid' || attr.name === 'Primarycontactid') && attr.value === '')) {
									oeerrorcount = oeerrorcount + 1;
									//CS.SM.updateConfigurationStatus(comp.name, config.guid, false, 'Error in Order Enrichment');										
									config.status = false;
									config.statusMessage = 'Error in Order Enrichment';
								}
								if (attr.name === 'Not Before CRD' && attr.value !== 0 && attr.value <= Date.now()) {
									oeerrorcount = oeerrorcount + 1;
									//CS.SM.updateConfigurationStatus(comp.name, config.guid, false, 'Error in Order Enrichment');
									config.status = false;
									config.statusMessage = 'Error in Order Enrichment';
								}
							}
						});
					});
				});
			}
		}
		//});
		if (oeerrorcount > 0 && !executeSaveDO) {
			CS.SM.displayMessage('Order Enrichment has errors.It can be either Mandatory fields not populated/Not before CRD is lesser than or equal to today/Preferred CRD is lesser than Not Before CRD.', 'error');
			//executeSaveDO = true;
			return Promise.resolve(false);
		}
		else {
			saveDOP = true;
			        
			return Promise.resolve(true);//EDGE-154471
		}
	}
}
// Added this method as part of EDGE_140968
function DOPPlugin_processMessagesFromIFrame() {
	if (!communitySiteId) {
		return;
	}
	var data = sessionStorage.getItem("payload");
	var close = sessionStorage.getItem("close");
	var childWindow = sessionStorage.getItem("childWindow");
	//console.log('CW--->' + childWindow);
	if (childWindow) {
		childWindow.postMessage('Hey', window.origin);
	}
	var message = {};
	if (data) {
		//console.log('EMPlugin_processMessagesFromIFrame:', data);
		message['data'] = JSON.parse(data);
		DOPPlugin_handleIframeMessage(message);
	}
	if (close) {
		//console.log('EMPlugin_processMessagesFromIFrame:', data);
		message['data'] = close;
		DOPPlugin_handleIframeMessage(message);
	}
}
// Added this method as part of EDGE_140968
async function DOPPlugin_handleIframeMessage(e) {
			//console.log('handleIframeMessage from pricing:', e); //
		var message = {};
		message = e['data'];
		message = message['data'];
		///console.log('----->'+ e.data['data']);
		//console.log(e.data['data']);
		//console.log(e.data['command']);
		//console.log(e.data['caller']);
		//console.log('solutionID-->' + solutionID);
		//Edge-143527 start
		//added by shubhi for EDGE-121376 start /////
		if (e.data && e.data['caller'] && e.data['command']) {
			if (e.data['caller'] && (e.data['caller'] !== 'Mobile Device')) {
				return;
			}
			else if (e.data['command'] === 'pageLoad' + callerName_DOP && e.data['data'] === solutionID) {
				await pricingUtils.postMessageToPricing(callerName_DOP, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded_DOP);
			}
			else if (e.data['command'] === 'StockCheck' && e.data['data'] === solutionID) { //EDGE-146972--Get the Device details for Stock Check before validate and Save as well
				await stockcheckUtils.postMessageToStockCheck(callerName_DOP, solutionID)
			}
		/*else if (e.data['command'] === 'showPromo' && e.data['data']===configId){
			console.log('showpromo.....');
			//await pricingUtils.postMessageToshowPromo(e.data['caller'],configId,"viewDiscounts");
		}*/else {
				await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller'], e.data['IsDiscountCheckAttr'], e.data['IsRedeemFundCheckAttr'], e.data['ApplicableGuid']);
			}
		}
}
async function resetPreferredCRD(notBeforeCRD, preferredCRD) {
	//console.log('@@@@@@@@resetPreferredCRD');

	//await CS.SM.getActiveSolution().then((product) => {//EDGE-154471
	let currentBasket = await CS.SM.getActiveBasket();//EDGE-154471
	var product = await CS.SM.getActiveSolution();//EDGE-154471
	if (product.name === DOP_COMPONENT_NAMES.solution) {
		if (product.components && Object.values(product.components).length > 0) {//EDGE-154471
			for (let comp of Object.values(product.components)) {//EDGE-154471
				if (comp.name === DOP_COMPONENT_NAMES.deviceOutRight) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						//if(comp.schema.changeType==='Change Request'){
						for (let config of Object.values(comp.schema.configurations)) {//EDGE-154471
							var updateMapNew = {};
							if (config.orderEnrichmentList) {
								Object.values(config.orderEnrichmentList).forEach((oe) => {
									//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
									if (!updateMapNew[oe.guid])
										updateMapNew[oe.guid] = [];
									////////////
									if (preferredCRD === '' || preferredCRD < notBeforeCRD || preferredCRD === '0' || preferredCRD === 0 || preferredCRD === NaN) {
										//console.log ('***************notBeforeCRD------ date --'+notBeforeCRD.getDate() + ' Month ' + notBeforeCRD.getMonth()+ 'Year --' + notBeforeCRD.getFullYear() );
										//Utils.updateOEPayload([{ name: "Preferred CRD", showInUi: true, readOnly: false, value: notBeforeCRD , displayValue: notBeforeCRD}], guid);
										/**updateMapNew[oe.guid] = [{
											name: 'Preferred CRD',
											value: {
												value:  notBeforeCRD ,
												showInUi: true, 
												readOnly: false,
												displayValue:  notBeforeCRD 
											}													
										}]; **/
										updateMapNew[oe.guid].push({ name: 'Preferred CRD', showInUi: true, displayValue: notBeforeCRD, value: notBeforeCRD });
									}
									//}	
								});
							}
							//EDGE-154471 start
							//CS.SM.updateOEConfigurationAttribute(DOP_COMPONENT_NAMES.deviceOutRight, config.guid, updateMapNew, true);
							if (updateMapNew && Object.keys(updateMapNew).length > 0) {
								keys = Object.keys(updateMapNew);
								//console.log('initializeOEConfigs updateMap:', updateMapNew);
								for (var i = 0; i < updateMapNew.length; i++) {
									await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[i], updateMapNew[keys[i]], true);
								}
							}
							//EDGE-154471 end
							var notBeforeCRDValidation = new Date();
							notBeforeCRDValidation.setHours(0, 0, 0, 0);
							if (notBeforeCRD <= notBeforeCRDValidation) {
								CS.SM.displayMessage('Not Before CRD date should be greater than today ');
								//EDGE-154471 start
								//CS.SM.updateConfigurationStatus(DOP_COMPONENT_NAMES.deviceOutRight, config.guid, false, 'Not Before CRD date should be greater than today!!!');
								config.status = false;
								config.statusMessage = 'Not Before CRD date should be greater than today!!!';
								//EDGE-154471 end 
							} else {	//EDGE-154471 start
								//CS.SM.updateConfigurationStatus(DOP_COMPONENT_NAMES.deviceOutRight, config.guid, true, '');
								config.status = true;
								config.statusMessage = '';
								//EDGE-154471 end
							}
						}
					}
				}
			}
		}
	}
	//});
}
/* 	
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_DOP() {
	var listOfAttributes = ['Solution Name', 'Device Outright Purchase', 'GUID'], attrValuesMap = {};
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, DOP_COMPONENT_NAMES.solution);
	//console.log('attrValuesMap...' + attrValuesMap['Solution Name']);
	//console.log('attrValuesMap...' + attrValuesMap['GUID']);

	let updateConfigMap = {};
	if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_DOP) {
		//EDGE-154471 start
		let configGuid;
		configGuid = attrValuesMap['GUID'];
		updateConfigMap[configGuid] = [];
		updateConfigMap[attrValuesMap['GUID']].push({
			name: 'Solution Name',
			value: attrValuesMap['Device Outright Purchase'],
			displayValue: attrValuesMap['Device Outright Purchase']
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
}