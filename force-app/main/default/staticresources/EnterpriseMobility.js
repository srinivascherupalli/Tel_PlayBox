/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	Author 			Date
1 			Hitesh Gandhi 			25-07-2019
2			Venkat					26-07-2019
3. 			Kalashree Borgaonkar 	20-08-2019 				EDGE-93081 - Render enhanced number reservation page.
4.          Tihomir Baljak  		13-08-2019      		Code refactoring - save, OE
5.			Rohit Tripathi			13-08-2019				EDGE-88407 --> Cancel and Modify Implementation (checkConfigurationSubscriptions)
6.			Hitesh Gandhi			14-08-2019				EDGE-81062 --> Changed the component refrence name to 'Corporate Mobile Plus'
7.			Ritika Jaiswal			19-08-2019				EDGE-81135 --> Added alert message, when cancelling all CMPs, ETC calculation of CMP
8.			Abinash	Barik			19-08-2019				EDGE-81127 -> As sales / partner user, I want latest plan, discount price to be applied during plan change scenario but  
															MRO device price should NOT be changed.
9.          Venkata Ramanan 		19-08-2019              Fixed Bulk OE issues on load & save
10. 		Tihomir Baljak  		20-08-2019				EDGE-108329, fixed EMPlugin_saveSolutionEM function
11          Tihomir Baljak  		21-08-2019  			Hide custom buttons on config level depending on basket stage
12.			Laxmi Rahate			21-08-2019				EDGE-89294 - Changes in EDM list to decompose
13. 		Tihomir Baljak			04-09-2019				Bulk OE for mobility now use Mobility plugin
14.         Ankit Goswami			09-04-2019				Select plan changes on mobility and Device type added on Device
15.			Ritika Jaiswal			16-09-2019				EDGE - 81135 : ETC calculation for CMP-Devices
16. 		Ritika Jaiswal 			26-09-2019				Defect fixes for CMP cancellation
17.         Ankit Goswami	        09-04-2019				Committed data plan changes for CMP 
18.			Ankit Goswami/Hitesh	23-10-2019				Committed data BonusPlan changes changes for CMP
19. 		Ritika Jaiswal			24-10-2019	    		EDGE - 81135 : RemainingTerm forCMP cancel
20.			Ankit Goswami/Hitesh	29-10-2019				Committed data Specs changes for CMP
21.			Ankit Goswami/Hitesh	06-11-2019				Channge Type Changes for Cancel 
22.			Kalashree Borgaonkar    06-11-2019      		Show 'Port-in check' button
23.         Venkata Ramanan G       08-11-2019     		    Commented out the competitor attribute related codes as its no longer required
24.         Shubhi V       			30-11-2019     		    Edge-20132 Discounts 
25.         Ankit Goswami			10-12-2019 			    EDGE-117256 Enable search on MSISDN in solution console
26.         Ankit Goswami			30-01-2020 			    EDGE-132276 Device status update on Device for Macd 
27.         Romil Anand             15-01-2020    		 	EDGE-130859 Redeeming One Funds for Cancel Journey
28.			Samish					10-02-2020 				EDGE-132203 Error handling
28.         Laxmi Rahate            14-02-2020       		EDGE-127421 Added Remote Action - to check if PaymentType is OneFund and other changes for MRO Bonus STory
29.         Ankit Goswami           19-02-2020     		    EDGE-123594 call setMainSolutionCorrelationID function
30.         Laxmi Rahate            24-02-2020      		Merge Production Issue changes done by Rohit
31.         Dheeraj Bhatt           13-02-2020      		EDGE-100662 : UI Enhancements Fixed Number Search with Validations for Telstra
32.			Aman Soni				26-02-2020      		EDGE-135278 : EM MAC Discounting - New fields to support MS to derive elapsed duration for Charge and Discount
33.			Laxmi				    26-02-2020	   		 	EDGE-135885 - Added Solution Name and BAsketNum in the priceScedule URL	
34. 		Laxmi 				   	09-03-2020				EDGE-138001 - method call to hide importconfigurations button added
35.			Rohit Tripathi			13-03-2020 				EDGE-140459 Restoring Logic for PRM handling in Prod and Deal logic for with and without deal config in one basket
36			Laxmi					13-03-2020				EDGE-131531 Hiding the SHow Promotion & Price Schedule Links
37.			Samish Kumar			10-03-2020              EDGE-120137  Set isRecontractingDiscountEligible(Cancel or Modify)
38.         Ankit Goswami			18-03-2020 	    		EDGE-134880 Enable search on MSISDN in solution console
39.			Ankit Goswami			18-03-2020				EDGE-140536 Set plandiscount and plandiscount lookup for MRO
40.         Sandip Deshmane         19-03-2020              EDGE-138631 - Added to validate Disconnection Date is not in the past. 
41.			Hitesh Gandhi			24-03-2020				Incident INC000092474084 ,EMPlugin_updateEDMListToDecomposeattribute method updated
42.			Rohit Tripathi			26-03-2020				EDGE-142087  As a User, I want to see correct Total Contract Value for committed data plan in basket during NEW, MAC - Add / Remove scenarios
43			Laxmi Rahate			07-APR-2020				EDGE-131531 - Added check for Provisioning In Progress in UpdateLinkAttributesEMS method
44.			Ankit Goswami			08-APR-2020 			EDGE-143972 -  Added by Ankit Goswami
45.			Ankit Goswami			08-apr-2020				EDGE-137466 - Added condition for  bulk enrichment by ankit
46.       	Shubhi Vijayvergia		10-Apr-2020				EDGE-137466 - added rules for oe new/modify
47.			Aman Soni				08-APR-2020 			EDGE-123593 -  Added by Aman Soni
48.			Sandip Deshmane			15-Apr-2020				EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
49.			Ankit Goswami			23-Apr-2020				EDGE-140967-Enabling Redemption as Discount for Device Payout on EM
49.        Shubhi/Aman              29/4/2020				Edge-143527 - POC solution json
50.			Laxmi Rahate			27-Apr-2020				EDGE-142321 Port Out Reversal Changes
51.			Ankit Goswami			13-May-2020				EDGE-148661 To not throw GNP error in case of already Device PaidOut
52. 		Laxmi Rahate			14-May-2020				EDGE-147474 & EDGE-147799 CHanges - BULK OE and Clear Plan Discount
53. 		Aditya Pareek 			08-May-2020				EDGE-138108 - Changed Signature of remainingTermEnterpriseMobilityUpdate 
54.			Ankit Goswami			14-may-2020				EDGE-147709 Hide MDM Entitlement FIX
55.			Aman Soni				19-May-2020			 	EDGE-148455 To capture Billing Account	
56. 	    Hitesh Gandhi			22-May-2020				EDGE-146184 Added check for IDD charge	
57			Laxmi Rahate			27-May-2020				EDGE-151380 - Defect Fix - Use Existing SIM case
58.         RaviTeja                01-Jun-2020		        EDGE-146972-Get the Device details for Stock Check before validate and Save as well
59. 		Gnana					10-Jun-2020	    		EDGE-149887 : Solution Name Update Logic 
60. 		Hitesh Gandhi			15-Jun-2020				EDGE-155203  : added Global Data SIM and Global Data SIM BYO to condition.
61. 		Aman Soni				17-Jun-2020				EDGE-156214 EM mac || issue in billing account
62. 		Aman Soni				22-Jun-2020				EDGE-155354 Set By Default DeviceEnrollment value to 'DO NOT ENROL'
63.         Shubhi V 				25-June-2020			EDGE-158034 Clone issue fix
64. 		Arinjay Singh			02-July-2020			EDGE-155247 JSPlugin Upgrade and Merge with 20.08
65.			Gnana/Aditya 			19-July-2020			CS Spring'20 Upgrade
66. 		Arinjay Singh			12-Aug-2020				EDGE-168703
67.         Shubhi/Ankit			14/08/2020 				device enrollement and validation handling 
68.         Shubhi                  21/08/2020              Misdnfix

69.         Shubhi                  31.08.2020              INC000093772606 fix 

********************/	 
var ENTERPRISE_COMPONENTS = {
	enterpriseMobility: 'Corporate Mobile Plus', //EDGE-81062 
	mobileSubscription: 'Mobile Subscription',
	device: 'Device',
	solutionEditableAttributeList: ['Solution Name','OfferName','OfferType','DataPackPlan'],
	mobileSubscriptionEditableAttributeList: ['SelectPlanType', 'Select Plan', 'InternationalDirectDial' ,'MessageBank'],
	mobileSubscriptionAddOnEditableAttributeList: ['Device Type', 'MobileHandsetManufacturer', 'MobileHandsetModel' ,'MobileHandsetColour', 'PaymentTypeLookup' , 'ContractTerm']
};
var mdmvalidmobconfig = 0;
var show = false;
var executeSaveEM = false;
var allowSaveEM = false;	
var productInError = false;
var IsMACBasket = false;
var IsDeviceChange = false;
var communitySiteId;
var userThemeValue;
var allowanceValue = null;
var isCommittedDataOffer = false;
var datashow = false;
var datapackallowance = null;
var SolutionChangeType=false;
var closeNotAllowed=false;
let isPaymentTypeOneFund;	// Added by Laxmi EDGE-127421
var basketNum;  // Added by Laxmi EDGE_135885
var solutionName; // Added by Laxmi EDGE_135885
var contractSignedDate;
var rcmEligible = false;
var skipsave = false;  //added by ankit EDGE-132203
var configId;//Edge-143527
var IsDiscountCheckNeeded_EM;//Edge-143527
var IsRedeemFundCheckNeeded_EM;//EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
var solutionID; // Edge-143527 
var callerName_EM = '';//Edge-143527
var hasPortOutReversalPermission = false; // EDGE-142321
var DEFAULTSOLUTIONNAME_EM = 'Corporate Mobile Plus';  // Added as part of EDGE-149887
// Arinjay Register Plugin
if (CS.SM.registerPlugin) { 
	//console.log('Load EM plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () { 
		await CS.SM.registerPlugin('Enterprise Mobility') 
            .then(EMPlugin => { 
                console.log("Plugin registered for Enterprise Mobility"); 
                // For Hooks
                EMPlugin_updatePlugin(EMPlugin); 
            }); 
    }); 
} 
function EMPlugin_updatePlugin(EMPlugin) {
    //console.log('Adding Hooks to EMPlugin');
     //Added by Aman Soni for Deal Price
	window.addEventListener('message', EMPlugin_handleIframeMessage );
	// Orignall it was setInterval(EMPlugin_processMessagesFromIFrame,500);
	setInterval(EMPlugin_processMessagesFromIFrame,500);
	document.addEventListener('click', function(e) {
		e = e || window.event;
		//console.log('EM click event listener ', e );
		var target = e.target || e.srcElement;
		var text = target.textContent || target.innerText;
		//console.log('Inside eventListner--->');
		if (text && text.toLowerCase()==='mobile subscription') {
			if (basketStage !== 'Contract Accepted') {
				Utils.updateComponentLevelButtonVisibility('Order Enrichment', false, false);
				Utils.updateComponentLevelButtonVisibility('Bulk Enrichment New', false, false); //added by shubhi EDGE-137466
			}
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// edge-120132
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');
			Utils.updateCustomButtonVisibilityForBasketStage();
            //console.log('i am inside enterprisemobility. remove me');
			// Laxmi EDGE-138001 - method call  to hide the import configuraton button
			Utils.updateImportConfigButtonVisibility();
			// Laxmi Changes End
            //pricingUtils.removeFileUploadTag();
			//pricingUtils.handleLockOnLoad(ENTERPRISE_COMPONENTS.enterpriseMobility);
		}
		if (window.currentSolutionName === ENTERPRISE_COMPONENTS.enterpriseMobility && text && (text.toLowerCase() ==='overview' || text.toLowerCase().includes('stage'))) {
			Utils.hideSubmitSolutionFromOverviewTab();
		}
	}, false);
	// Arinjay Commented temporary
	//setInterval(EMPlugin_saveSolutionEM,500);
	//EMPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {
	window.document.addEventListener('SolutionSetActive', async function (e) {
		//console.log('EM After Solution Loaded -------- ', previousSolution, loadedSolution);
		let loadedSolution = await CS.SM.getActiveSolution();
		if (basketStage === 'Contract Accepted'){
			loadedSolution.lock('Commercial',false);
		}
		if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			console.log('SolutionSetActive from EMPlugin', loadedSolution);
			let currentBasket =  await CS.SM.getActiveBasket(); 
			window.currentSolutionName = loadedSolution.name; //Added by Venkat to Hide OOTB OE Console Button
			//Aditya-Samish For EDGE-132203 Error handling
			//var skipsave = false;
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				Object.values(loadedSolution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) { 
						console.log('Inside EM 1----- comp.name'+comp.name );
						pricingUtils.setIsDiscountCheckNeeded(comp.schema,comp.name);
						Utils.updateImportConfigButtonVisibility(); // Added for EDGE-131531
						//skipsave = true;
					}
				});
				if (skipsave == true){
					return Promise.resolve(false);    
				}
			}
			// Laxmi EDGE-138001 - method call  to hide the import configuraton button
			/*	if (window.currentSolutionName === ENTERPRISE_COMPONENTS.enterpriseMobility && text && text.toLowerCase()==='mobile subscription' ){
				Utils.updateImportConfigButtonVisibility();
				}*/
				// Laxmi Changes End
			await Utils.loadSMOptions();
            EMPlugin_UpdateRelatedConfigForChild();
			//added by Romil	
			RedemptionUtils.calculateBasketRedemption();	
			RedemptionUtils.displayCurrentFundBalanceAmt();
			if (/*loadedSolution.type &&*/ loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
				//await CS.SM.getCurrentCart().then(cart => {
				if(currentBasket) {
					console.log('Basket: ', currentBasket);
					console.log('Basket.ID: ', currentBasket.id);
					console.log('BasketID: ', currentBasket.basketId);
					basketId = currentBasket.basketId;
					Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// edge-120132
					Utils.updateCustomAttributeLinkText('Price Schedule','View All');
				}
				EMPlugin_CheckErrorsOnSolution(loadedSolution); //INC000093772606
				let inputMap = {};
				inputMap['GetBasket'] = basketId;
				//await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
				await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
					console.log('EMPlugin_updatePlugin GetBasket finished with response: ', result);
					var basket = JSON.parse(result["GetBasket"]);
					console.log('EMPlugin_updatePlugin GetBasket: ', basket);
					basketChangeType = basket.csordtelcoa__Change_Type__c;
					basketStage = basket.csordtelcoa__Basket_Stage__c;
					accountId = basket.csbb__Account__c;
					basketNum = basket.Name;// EDGE-135885 Laxmi - code to get basket num
					window.oeSetBasketData(basketId, basketStage, accountId);
					console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId);
					console.log('basketStage: ', basketStage);
					console.log('basketNum: ', basketNum);
					//Added by Aman Soni as a part of EDGE -148455 || Start
					if(accountId!=null){
						CommonUtills.setAccountID(ENTERPRISE_COMPONENTS.enterpriseMobility,accountId);
					}
					//Added by Aman Soni as a part of EDGE -148455 || End
					// Aditya: Edge:142084 Enable New Solution in MAC Basket
                        CommonUtills.setBasketChange();
						console.log(window.BasketChange);

					EMPlugin_addDefaultEMOEConfigs();
				});

				// Laxmi Changes for EDGE-142321 - 
				let inputMapPOR = {};
				await currentBasket.performRemoteAction('SolutionHelperPORPermissionChk', inputMapPOR).then(values => {
					console.log('SolutionHelperPORPermissionChk result:', values);
					if (values['hasPortOutReversalPermission'])
						hasPortOutReversalPermission = values['hasPortOutReversalPermission'];
					console.log('hasPortOutReversalPermission: ', hasPortOutReversalPermission);
				});
				// Changes END for EDGE-142321		
				EMPlugin_setEMOETabsVisibility();
				//EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
				//await EMPlugin_checkConfigurationSubscriptionsForEM();
				await EMPlugin_checkConfigurationSubscriptionStatus();
				await EMPlugin_checkConfigurationServiceForEM();
				EMPlugin_updateFieldsVisibilityAfterSolutionLoad(loadedSolution);
				EMPlugin_updateDeviceEnrollmentAfterSolutionLoad() ;
				EMPlugin_updateChangeTypeAttribute();
				EMPlugin_updateStatusAfterSolutionLoad();
				//pricingUtils.handleChargeVisibilityonLoad();
				await pricingUtils.resetCustomAttributeVisibility();
			}
			// Added by Laxmi EDGE-127421 - Pass the OfferID for CMP and the AccountId and get if isPaymentTypeOneFund is true or false
			let inputMapOneFund = {};
			let offerID = 'DMCAT_Offer_000646';
			inputMapOneFund['accountId'] =accountId;
			inputMapOneFund['offerID'] = offerID;
			await EMPlugin_checkContractingStatus(inputMapOneFund);
			//});
			//Laxmi Changes End		
			//EDGE-109925 - render page on PRM, start
			let map = {};
			map['GetSiteId'] = '';
			map['getUserTheme'] = '';
			await currentBasket.performRemoteAction('SolutionActionHelper', map).then(result => {
				console.log('GetSiteId finished with response: ', result);
				communitySiteId = result["GetSiteId"];
				userThemeValue = result["getUserTheme"];
				console.log('communitySiteId: ', communitySiteId);
				console.log('userThemeValue: ', userThemeValue);
			});
			//EDGE-109925 - render page on PRM, end
			Utils.updateCustomButtonVisibilityForBasketStage();
			//Added by Aman Soni as a part of EDGE-148455 || Start
			var solutionComponent = false;
			var componentMap = new Map();
			var componentMapattr = {};
			if(/*loadedSolution.type &&*/ loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)){
				if(Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && 
											Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null){
					solutionComponent = true;
					var billingAccLook = Object.values(Object.values(loadedSolution.schema.configurations)[0].attributes).filter(a => {
					return a.name === 'BillingAccountLookup' 
					});			
					componentMapattr['BillingAccountLookup'] = [];
					componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
					componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
					await CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap);
					if(billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
					{
					CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.enterpriseMobility,'BillingAccountLookup',solutionComponent);		
					}			
				}
				if(loadedSolution.components && Object.values(loadedSolution.components).length > 0){
					Object.values(loadedSolution.components).forEach((comp) => {
					solutionComponent = false;
					if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
						Object.values(comp.schema.configurations).forEach((config) => {
						if(config.replacedConfigId !== null){
						CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.mobileSubscription,'initialActivationDate',solutionComponent);
						CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.mobileSubscription,'BillingAccountNumber',solutionComponent);
						}
						});
					}
					});
				}
			}
			//Added by Aman Soni as a part of EDGE-148455 || End

			if (window.BasketChange === 'Change Solution' ) {

				// Arinjay 12 Aug 
				if (!(basketStage === 'Commercial Configuration' || basketStage === 'Draft')) {
					EM_updateChangeTypeOptions();
				}
				EMPlugin_UpdateRelatedConfigForChildMac();
				// Arinjay 12 Aug
				//added by Romil	
				RedemptionUtils.populatebasketAmountforCancelCMP();	
				RedemptionUtils.populatebasketAmountforModifyCMP();
				EMPlugin_UpdateMainSolutionChangeTypeVisibility(loadedSolution);
				await EMPlugin_UpdateAttributesForMacdOnSolution(loadedSolution);
				await EMPlugin_setAttributesReadonlyValueForsolution();
				pricingUtils.setMainSolutionCorrelationID();
				//Added by Aman Soni as a part of EDGE-135278 || Start
				//CommonUtills.setSubBillingAccountNumberOnCLI('Mobile Subscription','initialActivationDate');
				//CommonUtills.setSubBillingAccountNumberOnCLI('Mobile Subscription','BillingAccountNumber');
				//Added by Aman Soni as a part of EDGE-135278 || End
				//Added by Laxmi - EDGE-131531
				EMPlugin_updateLinksAttributeEMS(loadedSolution);
				EMPlugin_handleDeviceShipping(loadedSolution); // Added for EDGE-142321 - laxmi - changing the DeviceShipping Flag
				//Added by Ankit as part of Bulk OE story - EDGE-137466 || start
				if (basketStage === 'Contract Accepted') {
					validateOERules.resetCRDDatesinOESchema(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription);
					validateOERules.resetDeliverDetailsinOESchema(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription);
				}
				//Added by Ankit as part of Bulk OE story - EDGE-137466 || End
			}
			//added by Romil	
			else	
			{	
				Utils.updateComponentLevelButtonVisibility('Check OneFund Balance', false, false);	
			}
			await EMPlugin_handlePortOutReversal (); // Laxmi Added for EDGE-142321
			await EMPlugin_resetDeliveryDetailsinOESchema (); // laxmi Added for EDGE-142321
			//checkOERequirementsforMACD call Added by Laxmi - EDGE-142321
			//Reset CRDs when PCs added to MAC basket - moved this from MACD Observer as part of Spring20 upgrade
            if (window.BasketChange === 'Change Solution'  && basketStage === 'Contract Accepted') {
                if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
                    for(const comp of Object.values(loadedSolution.components)) {
                        if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
                            await validateOERules.resetCRDDatesinCaseOfModify(loadedSolution.name,comp.name);
                        }
                    }
                }
            }
		}
		if (basketStage === 'Contract Accepted'){
			loadedSolution.lock('Commercial',true);
		}
		return Promise.resolve(true);
	});
	// EMPlugin.afterOETabLoaded =  async function _afterOETabLoadedEM (configurationGuid, OETabName) {
	// 	console.log('afterOETabLoaded: ', configurationGuid, OETabName);
	// 	var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
	// 	window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
	// 	return Promise.resolve(true);
	// }
	window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) ||  
									solution.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription)){
			//console.log('afterOrderEnrichmentTabLoaded: ', configurationGuid, OETabName);
			console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
			//var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			//window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
			window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
		}
		return Promise.resolve(true);
	});
	EMPlugin.afterConfigurationAddedToMacBasket = async function (componentName, configuration) {
		//console.log("afterConfigurationAddedToMacBasket START ");
		let solution  = await CS.SM.getActiveSolution();
		let component = solution.getComponentByName(componentName);
		let config = Object.values(component.schema.configurations)[0];
		changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
			return obj.name === 'ChangeType'
		});
		EMPlugin_UpdateRelatedConfigForChildMac(configuration);
		let value1 = await EMPlugin_getSelectedPlanForMobileSubscription(configuration);
		EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute[0].displayValue, value1 );
		EMPlugin_updateFieldsVisibilityAfterSolutionLoad(solution);
		EMPlugin_updateChangeTypeAttribute(true);
		EMPlugin_UpdateMainSolutionChangeTypeVisibility(solution);
		await EMPlugin_UpdateAttributesForMacdOnSolution(solution);
		// Added By ankit || start EDGE-169973


		await EMPlugin_checkConfigurationSubscriptionStatus();
		await EMPlugin_checkConfigurationServiceForEM();
		//await EMPlugin_updateDeviceEnrollmentAfterSolutionLoad();
		await EMPlugin_updateStatusAfterSolutionLoad();
		await EMPlugin_setAttributesReadonlyValueForsolution();
		await EMPlugin_handleDeviceShipping(solution); 
		await handlePortOutReversalForIndvConf (configuration); //  Added for EDGE-142321//EDGE-169973 added by shubhi
		await resetDeliveryDetailsinOESchemaForIndvConf (configuration); //  Added for EDGE-142321// added by shubhi
		// Added By ankit || End EDGE-169973
		//console.log("afterConfigurationAddedToMacBasket END ");
	}
	EMPlugin.afterOrderEnrichmentConfigurationAdd = function(component, configuration, orderEnrichmentConfiguration){
		console.log('EM afterOrderEnrichmentConfigurationAdd', component.name, configuration, orderEnrichmentConfiguration)
		EMPlugin_initializeEMOEConfigs(orderEnrichmentConfiguration.guid);
		window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};
	EMPlugin.afterOrderEnrichmentConfigurationDelete = function(component, configuration, orderEnrichmentConfiguration){
		window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
		return Promise.resolve(true);
	};
	/*method to add delay*/
	function sleep(ms) {
	  return new Promise(
		resolve => setTimeout(resolve, ms)
	  );
	}
    // added by shubhi for EDGE-170124 cloned configuration as afterConfigurationAdd wa not working after upgrade to be reviewed before moving to higher orgs
	EMPlugin.afterConfigurationClone = async function (component, configuration, clonedConfiguration) {
		//console.log('Parent Config Add - After', component.name, configuration);
		if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) {			
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');// edge-120132	
				//await pricingUtils.resetDiscountAttributes(configuration.guid,component.name);
			var updateConfigMap={};
			for(var config of configuration){
				config.status = false;
				config.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
				updateConfigMap[config.guid]=[];
                updateConfigMap[config.guid].push({
					name: "IsDiscountCheckNeeded",
				value: true
				});
				updateConfigMap[config.guid].push({
				name: "Price Schedule",
					showInUi:false
				});
			}
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false); 
			}
		}	
		return Promise.resolve(true);
	}
	EMPlugin.afterConfigurationAdd = async function (component, configuration) {
		console.log('Parent Config Add - After', component.name, configuration);
		if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) {			
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');// edge-120132	
			EMPlugin_subscribeToExpandButtonEvents(ENTERPRISE_COMPONENTS.mobileSubscription);
			EMPlugin_clonedataplanattributevalue(datapackallowance);
			await EMPlugin_addDefaultEMOEConfigs();	
			//EDGE -142321 - Setting the Attributes after MS config Add
			await handlePortOutReversalForIndvConf (configuration.guid); // Laxmi Added for EDGE-142321
			await resetDeliveryDetailsinOESchemaForIndvConf (configuration.guid); // laxmi Added for EDGE-142321
			if(configuration.replacedConfigId=== undefined || configuration.replacedConfigId === null || configuration.replacedConfigId === ''){
				await pricingUtils.resetDiscountAttributes(configuration.guid,component.name);
			}
			EMPlugin_updateChangeTypeAttribute();
		}
		return Promise.resolve(true);
	}
    // Hook afterAttributeUpdated
    EMPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		console.log('Inside afterAttributeUpdated' + component.name + '  attribute.name ' + attribute.name + ' attribute.value ' + attribute.value);
		//Spring 20
		let product = await CS.SM.getActiveSolution();
		let componentObj = await product.getComponentByName(component.name); 
		let currentBasket =  await CS.SM.getActiveBasket(); 
		let componentName = component.name;
		let guid = configuration.guid;
		let oldValue = oldValueMap['value'];
		let newValue = attribute.value;
		if (basketStage === 'Contract Accepted'){
			product.lock('Commercial',false);
		}

        console.log('Before Modify Update:');
        if (componentName === ENTERPRISE_COMPONENTS.enterpriseMobility && attribute.name === 'ChangeType' && 
			oldValueMap['value'] != attribute.value && (attribute.value === 'Modify' || attribute.value === 'Cancel')) {
            console.log('Inside Modify Update');
            SolutionChangeType=true;
            await EMPlugin_setAttributesReadonlyValueForsolution();
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && (attribute.name === 'DisconnectionDate'|| attribute.name === 'RedeemFund')) {
			console.log('Inside ETC calculation hook');
			//EDGE-138631 - Added to validate Disconnection Date is not in past.
			if(component.name === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'DisconnectionDate'){
				EMPlugin_validateDisconnectionDate(component.name, configuration.guid, attribute.value);
				EMPlugin_calculateTotalETCValue(configuration.guid);
			}
			//added by Romil	
			RedemptionUtils.calculateBasketRedemption();	
			RedemptionUtils.displayCurrentFundBalanceAmt();	
			RedemptionUtils.populatebasketAmountforCancelCMP();
		}//EDGE-81135 : Cancellation of CMP
		if (window.BasketChange === 'Change Solution'  && attribute.name === 'ChangeType') {
			EMPlugin_setEMOETabsVisibility();
			EMPlugin_ChangeOptionValue(guid);
		}
		if (window.BasketChange === 'Change Solution'  && attribute.name === 'ChangeType' && componentName === ENTERPRISE_COMPONENTS.mobileSubscription)
		{
			EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(guid, newValue, await EMPlugin_getSelectedPlanForMobileSubscription(guid));
			EMPlugin_updateFieldsVisibilityAfterSolutionLoad(product);
		}
		if (window.BasketChange === 'Change Solution'  && attribute.name === 'ChangeType')
		{
			let updateMapFundNew =  new Map();
			let componentMapForFund =   new Map();
			let visible = newValue === "Cancel" ? true : false;
			EMPlugin_updateAttributeVisibility(componentName,'CancellationReason', guid,false, visible,visible);
			if (!visible) {
					Utils.emptyValueOfAttribute(guid, componentName, 'CancellationReason', false);
					// Added as part of EDGE-140967\\ Start
					Utils.emptyValueOfAttribute(guid, componentName, 'DisconnectionDate', false);
					Utils.emptyValueOfAttribute(guid, componentName, 'EarlyTerminationCharge', false);
					Utils.emptyValueOfAttribute(guid, componentName, 'OneOffChargeGST', false);
					//Utils.emptyValueOfAttribute(guid, componentName, 'RedeemFund', false);
					componentMapForFund.set('RedeemFund',0.00);
					updateMapFundNew.set(guid,componentMapForFund);	
					//CommonUtills.UpdateValueForSolution(ENTERPRISE_COMPONENTS.mobileSubscription,updateMapFundNew);
					// Added as part of EDGE-140967\\ End
			}
			EMPlugin_CheckRedeemFundDiscount(guid); //Added by ankit as part of EDGE-140967
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && (attribute.name === 'ChangeTypeDevice' || attribute.name === 'RedeemFund')){
			console.log('Inside Modify Update for Cancel Flag');
			IsDeviceChange=true;
			EMPlugin_checkCancelFlagAndETCForNonBYOPlans(guid);	
			EMPlugin_updateRemainingTermAfterSave(guid);
				//added by Romil
			RedemptionUtils.calculateBasketRedemption();	
			RedemptionUtils.displayCurrentFundBalanceAmt();	
			RedemptionUtils.populatebasketAmountforModifyCMP();
			if(window.BasketChange === 'Change Solution'  && attribute.name === 'RedeemFund'){
				EMPlugin_CheckRedeemFundDiscount(guid); //Added by ankit as part of EDGE-140967
				EMPlugin_CheckRedeemFundUpdate(guid); //Added by ankit as part of EDGE-140967		
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ChangeTypeDevice' && oldValue != newValue ) {
			console.log('Inside Modify Update for Cancel Flag');
			//Utils.emptyValueOfAttribute(guid, componentName, 'RedeemFund', false);
			if( newValue !== 'Payout')
				EMPlugin_checkRemainingTermForBYOPlans(guid);
			    EMPlugin_setPlanDiscount(guid,componentName);
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && (newValue === 'Modify' || newValue === 'Cancel')) {
			console.log('Inside Modify Update');
			IsMACBasket = true;
			await EMPlugin_updateRemainingTermAfterSolutionLoad();
			await EMPlugin_updateCancelDeviceTypeAfterSolutionLoad(guid);
			await EMPlugin_setAttributesReadonlyValueForsolution();
			//added by Romil
			RedemptionUtils.calculateBasketRedemption();	
			RedemptionUtils.displayCurrentFundBalanceAmt();	
			RedemptionUtils.populatebasketAmountforModifyCMP();
			EMPlugin_EnableAttributesforModify(guid);
			if(newValue === 'Cancel'){
				EMPlugin_DeviceAddconfigurationError(guid);
				RedemptionUtils.populatebasketAmountforCancelCMP();
			}
			EMPlugin_handleDeviceStatusAndPlanDiscount(guid);		
		}
		if (componentName === ENTERPRISE_COMPONENTS.enterpriseMobility && attribute.name === 'OfferType') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility); 
			if (product && product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.schema && product.schema.configurations && Object.values(product.schema.configurations).length > 0) {
					let componentMap =  new Map();
					let componentMapattr = {};	
					Object.values(product.components).forEach((comp) => {
						if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
							// make configuration invalid
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
									//CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false, 'Please reselect relevant plan.');
									let cnfg = await comp.getConfiguration(subsConfig.guid); 
									cnfg.status = false;
									cnfg.statusMessage = 'Please reselect relevant plan.';
								});
							}
						}
					});
					var offerIdValue = null;
					Object.values(product.schema.configurations).forEach(async (config) => {
						if (config.guid == guid) {
						offerIdValue = null;
						let updateConfigMap = {};
						if (config.guid == guid) {
							Object.values(config.attributes).forEach((configAttr) => {
								if (configAttr.name === 'OfferId') {
									offerIdValue = configAttr.value;
								}												
							});
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'DataPackPlan', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'DataPackAllowanceValue', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'Data Pack RC', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'Data Pack Allowance', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'BonusDataAllowance', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'BonusDataAllowanceValue', true);
							Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, 'BonusDataPromotionEndDate', true);
							if(offerIdValue!= '' && (offerIdValue === 'DMCAT_Offer_000646' || offerIdValue === 'DMCAT_Offer_000303')){
								updateConfigMap[config.guid] = [{
									name: 'ProdSpecId',
									value: 'DMCAT_ProductSpecification_000420',
									displayValue: 'DMCAT_ProductSpecification_000420'
								}];
							}
							if (attribute.displayValue === 'Data Pool' || attribute.displayValue === 'Committed Data' ) {
								console.log('Is comitted');
								componentMapattr['DataPackPlan'] = [];
								componentMapattr['Data Pack RC'] = [];
								componentMapattr['DataPackAllowanceValue'] = [];
								componentMapattr['DataPackPlan'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':true});
								componentMapattr['Data Pack RC'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
								componentMapattr['DataPackAllowanceValue'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
							} else {
								console.log('Is fairplay');
								componentMapattr['DataPackPlan'] = [];
								componentMapattr['Data Pack RC'] = [];
								componentMapattr['DataPackAllowanceValue'] = [];
								componentMapattr['BonusDataAllowance'] = [];
								componentMapattr['BonusDataAllowanceValue'] = [];
								componentMapattr['BonusDataPromotionEndDate'] = [];
								componentMapattr['DataPackPlan'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
								componentMapattr['Data Pack RC'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
								componentMapattr['DataPackAllowanceValue'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
								componentMapattr['BonusDataAllowance'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
								componentMapattr['BonusDataAllowanceValue'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
								componentMapattr['BonusDataPromotionEndDate'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							}
							componentMap.set(config.guid,componentMapattr);
							// create Allowances NC Schema
							Object.values(product.orderEnrichments).forEach((oeSchema) => {
								if (oeSchema.name.toLowerCase()==='allowance') {
									var found = false;
									if (config.orderEnrichmentList) {
										var oeConfig = config.orderEnrichmentList.filter(oe => {return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId )});
										if (oeConfig && oeConfig.length > 0)
											found = true;
									}
									if (found) {
										console.log('oeConfig', oeConfig);
										oeGUIDs = [];
										oeConfig.forEach((conf) => {
											oeGUIDs.push(conf.guid);
										});
										// delete oe records
										//CS.SM.deleteOrderEnrichments(product.name, config.guid, oeGUIDs);   
										oeGUIDs.forEach((oeGUID) => {  
											product.deleteOrderEnrichmentConfiguration(config.guid,oeGUID ) ;        
										});      				
									}
									// add allowances NC records
									//EMPlugin_addAllowancesOEConfigs(product.name, config.guid, oeSchema.id, newValue, '');
								}								                                		
							});
						   //Added by Laxmi to set the value of isPaymentTypeOneFund depending on the Remote Action Resule
							updateConfigMap[config.guid] = [] ;
							updateConfigMap[config.guid].push({
								name: 'isPaymentTypeOneFund',
								value: isPaymentTypeOneFund,
								displayValue: isPaymentTypeOneFund,
								showInUi:false,
								readOnly: true
							});
							//Laxmi Changes END		
						}
						console.log('OfferType hook',componentMap);
						//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateConfigMap, true);
						//Spring 20
						let keys = Object.keys(updateConfigMap);
						for (let i = 0; i < keys.length; i++) {
							await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
						}
						CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility,componentMap);
						}
					});
				}
			}
			//});
			await EMPlugin_updateSolutionNameEM(); // Added as part of EDGE-149887
		}
		if (componentName === ENTERPRISE_COMPONENTS.enterpriseMobility && attribute.name === 'DataPackPlan') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility); 
			//CS.SM.getActiveSolution().then((product) => {
			if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				Object.values(product.schema.configurations).forEach(async (config) => {
					var priceItemid = null;
					Object.values(config.attributes).forEach((priceItemAttribute) => {
						if (priceItemAttribute.name === 'DataPackPlan') {
							priceItemid = priceItemAttribute.value;
						}										
					});
					if (config.guid == guid) {
						//invoke method to get the allowance details
						let inputMap = {};
						if (priceItemid !== '') {
							inputMap['priceItemId'] = priceItemid;
						}
						var allowanceRecId = null;
						var allowanceValue = null;
						await currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(response =>  {                
							if (response && response['allowances'] != undefined) {
								console.log('allowances', response['allowances']);
								if(response['allowances'].length > 1){
									response['allowances'].forEach((a) => {
										allowanceRecId = a.cspmb__allowance__c;
										allowanceRecName=a.cspmb__allowance__r.Name;
										allowanceValue = a.cspmb__allowance__r.Value__c + ' ' +a.cspmb__allowance__r.Unit_Of_Measure__c;
										allowanceExternalId= a.cspmb__allowance__r.External_Id__c;
										allowanceEndDate=a.cspmb__allowance__r.endDate__c;
										console.log('jainish.. ' + allowanceValue);
										let updateConfigMap = {};
										Object.values(config.attributes).forEach(async (priceItemAttribute) => {
											if(allowanceExternalId.includes('DMCAT_Allowance_000805')){
												if (priceItemAttribute.name === 'Data Pack Allowance' && allowanceRecId!= '') {
													updateConfigMap[config.guid]=[{
														name: 'Data Pack Allowance',
														value: allowanceRecId,
														displayValue: allowanceRecId
													}];
												}
												if(priceItemAttribute.name === 'DataPackAllowanceValue' && allowanceValue!= '') {
													updateConfigMap[config.guid]=[{
														name: 'DataPackAllowanceValue',
														value: allowanceValue,
														displayValue: allowanceValue
													}];
													datapackallowance = allowanceValue;
												}
											} if(allowanceExternalId.includes('DMCAT_Allowance_000877')){
												if (priceItemAttribute.name === 'BonusDataAllowance' && allowanceRecId!= '') {
													updateConfigMap[config.guid]=[{
														name: 'BonusDataAllowance',
														value: allowanceRecId,
														displayValue: allowanceRecName,
														readOnly: true
													}];
												}
												if(priceItemAttribute.name === 'BonusDataAllowanceValue' && allowanceValue!= '') {
													updateConfigMap[config.guid]=[{
														name: 'BonusDataAllowanceValue',
														value: allowanceValue,
														displayValue: allowanceValue,
														showInUi:true
													}];
												}
												if(priceItemAttribute.name === 'BonusDataPromotionEndDate' && allowanceEndDate!= '') {
													updateConfigMap[config.guid]=[{
														name: 'BonusDataPromotionEndDate',
														value: allowanceEndDate,
														displayValue: allowanceEndDate,
													}];
												}
											}
											//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateConfigMap, true);	
											let keys = Object.keys(updateConfigMap);
											for (let i = 0; i < keys.length; i++) {
												await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
											}
										});
										EMPlugin_clonedataplanattributevalue(datapackallowance);
									});
								}else{
									response['allowances'].forEach((a) => {
										allowanceRecId = a.cspmb__allowance__c;
										allowanceRecName=a.cspmb__allowance__r.Name;
										allowanceValue = a.cspmb__allowance__r.Value__c + ' ' +a.cspmb__allowance__r.Unit_Of_Measure__c;
										allowanceExternalId= a.cspmb__allowance__r.External_Id__c;
										allowanceEndDate=a.cspmb__allowance__r.endDate__c;
										console.log('jainish.. ' + allowanceValue);
										let updateConfigMap = {};
										Object.values(config.attributes).forEach(async (priceItemAttribute) => {
											if (priceItemAttribute.name === 'Data Pack Allowance' && allowanceRecId!= '') {
												updateConfigMap[config.guid]=[{
													name: 'Data Pack Allowance',
													value: allowanceRecId,
													displayValue: allowanceRecId
												}];
											}
											if(priceItemAttribute.name === 'DataPackAllowanceValue' && allowanceValue!= '') {
												updateConfigMap[config.guid]=[{
													name: 'DataPackAllowanceValue',
													value: allowanceValue,
													displayValue: allowanceValue
												}];
												datapackallowance = allowanceValue;
											}
											if (priceItemAttribute.name === 'BonusDataAllowance') {
												updateConfigMap[config.guid]=[{
													name: 'BonusDataAllowance',
													value: '',
													displayValue: '',
													showInUi:false,
													readOnly: true
												}];
											}
											if(priceItemAttribute.name === 'BonusDataAllowanceValue') {
												updateConfigMap[config.guid]=[{
													name: 'BonusDataAllowanceValue',
													value: '',
													displayValue: '',
													showInUi:false
												}];
											}
											if(priceItemAttribute.name === 'BonusDataPromotionEndDate') {
												updateConfigMap[config.guid]=[{
													name: 'BonusDataPromotionEndDate',
													value: '',
													displayValue: '',
													showInUi:false
												}];
											}
											//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateConfigMap, true);											
											let keys = Object.keys(updateConfigMap);
											for (let i = 0; i < keys.length; i++) {
												await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
											}
										});	
										EMPlugin_clonedataplanattributevalue(datapackallowance);
									});
								} 
							}else {
								console.log('no response');
							}
						});
					}
				});
			}
				//});
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'SelectPlanType') {
			let updateConfigMapsubs = {};
			let componentMap =  new Map();
			let componentMapattr = {};	
			//CS.SM.getActiveSolution().then((product) => {
			if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.components && Object.values(product.components).length > 0) {
					Object.values(product.components).forEach((comp) => {
						if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach((subsConfig) => {
									if(subsConfig.guid===guid){
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);
									console.log('Select Plan Type -- Aman');
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InternationalDirectDial', true);
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MessageBank', true);
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDD Charge', true);
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'Select Plan', true);
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MessageBank RC', true);
									pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
									if(attribute.displayValue==='Data'){Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);//added for  edge-123575 by shubhi
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);//added for  edge-123575 by shubhi
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);//added for  edge-123575 by aman
									Utils.emptyValueOfAttribute(subsConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_PI', true);//edge-123575 by shubhi
									pricingUtils.resetDiscountAttributes(subsConfig.guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
									pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
									pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
									componentMapattr['InternationalDirectDial'] = [];
									componentMapattr['MessageBank'] = [];
									componentMapattr['MessageBank RC'] = [];
									componentMapattr['IDD Charge'] = [];
									componentMapattr['InternationalDirectDial'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
									componentMapattr['MessageBank'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
									componentMapattr['MessageBank RC'].push({'IsreadOnly':true, 'isVisible': false,'isRequired':false});
									componentMapattr['IDD Charge'].push({'IsreadOnly':true, 'isVisible': false,'isRequired':false});
									}else{
									componentMapattr['InternationalDirectDial'] = [];
									componentMapattr['MessageBank'] = [];
									componentMapattr['MessageBank RC'] = [];
									componentMapattr['IDD Charge'] = [];
									componentMapattr['InternationalDirectDial'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
									componentMapattr['MessageBank'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':true});
									componentMapattr['MessageBank RC'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
									componentMapattr['IDD Charge'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});				
									}
									}
								});
								componentMap.set(guid,componentMapattr);
							}
							console.log('SelectPlan Hook',componentMap);
							CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.mobileSubscription,componentMap);
						}
					});
				}
			}
			//});		
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'Select Plan') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			// Added as part of EDGE-134880 by ankit || start
			if(oldValue !== newValue){
				skipsave=true; //added by ankit EDGE-132203
			}
			let inputMapCLI = {};
			inputMapCLI['guid'] =guid;
			inputMapCLI['basketId'] = basketId;
			console.log('inputMapCLI::: ', inputMapCLI);
			// Added as part of EDGE-134880 by ankit || END
			let updateConfigMapsubs = {};
			var selectedPlan = newValue;
			var changeTypeAtrtribute = '';
			var selectPlanDisplayValue = '';
			var isRelatedDeviceAdded = false;
			var relatedConfigurationID = '';
			let inputMap = {};
			isCommittedDataOffer = false;
			inputMap['priceItemId'] = newValue;
			//CS.SM.getActiveSolution().then((product) => {
			inputMapCLI['solutionID'] = product.solutionId;
			if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				Object.values(product.schema.configurations).forEach((config) => {
					Object.values(config.attributes).forEach((configAttr) => {
						if (configAttr.name === 'OfferType' && configAttr.displayValue.includes('Committed Data')) {
							console.log ('Inside  Updating CommittedDataOffer ');
							isCommittedDataOffer = true;
						}
					});
				});
				if (product.components && Object.values(product.components).length > 0) {
					Object.values(product.components).forEach((comp) => {
						if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {	
								Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
									var PlanTypeSelected = '';
									//Changes made by Aditya
									if(subsConfig.guid == guid){
										updateConfigMapsubs[subsConfig.guid]=[];
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InternationalDirectDial', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDD Charge', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDAllowance', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDD ChargeLookup', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MessageBank', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MessageBank RC', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanDiscountLookup', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'TotalPlanBonus', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);//added for  edge-123575 by shubhi
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);//added for  edge-123575 by shubhi
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);//edge-123575 by shubhi
										console.log('Select Plan -- Aman');
										//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_PI', true);//edge-123575 by shubhi
										pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
										pricingUtils.setIsDiscountCheckNeeded(comp.schema,ENTERPRISE_COMPONENTS.mobileSubscription);//Aditya-Samish For EDGE-132203 Error handling
										pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
										pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
										var changeTypeAtrtribute = Object.values(subsConfig.attributes).filter(obj => {
											return obj.name === 'ChangeType'
										});
										Object.values(subsConfig.attributes).forEach((attr) => {
											if(attr.name === 'PlanTypeString' && attr.value ==='Data'){
												PlanTypeSelected = 'Data';	
											}
											if (attr.name === 'Select Plan' && attr.value !== '') {
												selectPlanDisplayValue =attr.displayValue ;
												console.log('Selected Plan --> '+selectPlanDisplayValue);
												if (attr.displayValue === 'Local' || attr.displayValue === 'Local BYO' || attr.displayValue === 'Basic' ||  attr.displayValue ==='Entry'||  attr.displayValue ==='Standard') {
													updateConfigMapsubs[subsConfig.guid].push({
														name: 'InternationalDirectDial',
														readOnly: false
													});
												} if(attr.displayValue !== 'Local' && !show && changeTypeAtrtribute !== 'Modify' && changeTypeAtrtribute !== 'Cancel' &&  attr.displayValue !== 'Basic'){
													//Added by Venkata for EDGE- 30181
														EMPlugin_showMDMtenancynotification();
												}
												if((attr.displayValue === 'XX-Large Data SIM BYO' ||attr.displayValue === 'X-Large Data SIM BYO') && !datashow && subsConfig.guid === guid && changeTypeAtrtribute !== 'Modify' && changeTypeAtrtribute !== 'Cancel'){
													//Added by Ankit for EDGE-112367
														EMPlugin_showDataSimnotification();
												}
												//Change Ends by Aditya
											}
											if (attr.name === 'ChangeType' && attr.value !== '' ){
												changeTypeAtrtribute = attr.value;
												console.log('Change Type Value is ----->'+changeTypeAtrtribute);
											}
										}); // Added by Tihomir Baljak
										//Added this block here as part of EDGE-147709 by ankit || start
										if (attribute.displayValue === 'Basic' && isCommittedDataOffer === true){
											console.log('Inside If loop');
											updateConfigMapsubs[subsConfig.guid].push({
												name: 'MDMEntitled',
												value: false,
												displayValue: false
											});
										}
										else {
											console.log('Inside else loop');
											updateConfigMapsubs[subsConfig.guid].push({
												name: 'MDMEntitled',
												value: true,
												displayValue: true
											})
										}
										//Added this block here as part of EDGE-147709 by ankit || End
										//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMapsubs, true).then(component =>console.log('component::::::::',component));
										//Spring 20
										let keys = Object.keys(updateConfigMapsubs);
										for (let i = 0; i < keys.length; i++) {
											await componentObj.updateConfigurationAttribute(keys[i], updateConfigMapsubs[keys[i]], true); 
										}
									}
									if (subsConfig.guid == guid && selectedPlan != '') {
										if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
												isRelatedDeviceAdded = false;
												isRelatedDevicePayout=false;
												subsConfig.relatedProductList.forEach((relatedConfig) => {
													if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === 'Related Component') {
														isRelatedDeviceAdded = true;
													}
													console.log('isRelatedDeviceAdded:::::'+isRelatedDeviceAdded);
													if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
														Object.values(relatedConfig.configuration.attributes).forEach((ChangeTypeAttribute) => {
															if(ChangeTypeAttribute.name==='ChangeTypeDevice' && ChangeTypeAttribute.value==='PayOut'){
																isRelatedDevicePayout=true;
															}
														});
													}
												});
										}
										if (changeTypeAtrtribute !=='Modify' && changeTypeAtrtribute !=='Cancel' && changeTypeAtrtribute !=='Active'){
											EMPlugin_validateMobileDevice(attribute.displayValue, subsConfig);
										}
										console.log('Before Inside selectPlanDisplayValue Validation  '+isRelatedDeviceAdded);
										if (!selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === false && isCommittedDataOffer === false){
											console.log('Inside selectPlanDisplayValue Validation  ');
											//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please add One mobile Device.');
											let cmp = await product.getComponentByName(componentName);
											let cnfg = await cmp.getConfiguration(subsConfig.guid); 
											cnfg.status = false;
											cnfg.statusMessage = 'Please add One mobile Device.';
										}else if (selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false){
											console.log('Inside selectPlanDisplayValue Validation  ');
											//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please remove the added mobile device because BYO plan does not allow purchase of mobile device');
											let cnfg = await componentObj.getConfiguration(subsConfig.guid); 
											cnfg.status = false;
											cnfg.statusMessage = 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device';
										}
										else {	//Aditya-Samish For EDGE-132203 Error handling
											//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,true);	
											pricingUtils.setIsDiscountCheckNeeded(comp.schema,ENTERPRISE_COMPONENTS.mobileSubscription); 
										}
										let inputMap = {};
										inputMap['priceItemId'] = selectedPlan;
										//function call to recalculate PlanDiscount value
										let deviceRecord = null;
										let planRecord = selectedPlan;
										Object.values(subsConfig.attributes).forEach((configAttr) => {
											if (configAttr.name === 'InContractDeviceRecId' && configAttr.value != null) {
												deviceRecord = configAttr.value;
												EMPlugin_updatePlanDiscount(subsConfig, planRecord, deviceRecord);
											}
										});
										currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(async response => {
											console.log('response', response);
											if (response && response['allowances'] != undefined) {
												console.log('allowances', response['allowances']);
												response['allowances'].forEach((a) => {
													if (a.Id != null) {
														allowanceRecId = a.cspmb__allowance__r.Id;
														allowanceValue = a.cspmb__allowance__r.Name;
													}
												});
												console.log('allowanceRecId ', allowanceValue);
												if (allowanceRecId != '') {
													let updateConfigMap2 = {};
													updateConfigMap2[subsConfig.guid] = [{
														name: 'PlanAllowance',
														value: allowanceRecId,
														displayValue: allowanceValue
													}];
													console.log('updateConfigurationAttribute IDDallowance');
													//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false);
													let keys = Object.keys(updateConfigMap2);
													for (let i = 0; i < keys.length; i++) {
														await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
													}
												}
											} else {
												console.log('no response');
											}
										});
										var addOnIDDCount = 0;
										var addOnMsgBankCount = 0;
										if(PlanTypeSelected !=='Data'){
										await currentBasket.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(async response => {
												if (response && response['addOnIDD'] != undefined) {
													console.log('response[addOnIDD] ' + response['addOnIDD']);
													addOnIDDCount = response['addOnIDD'].length;
												}
												if (response && response['addOnMsgBank'] != undefined) {
													console.log('response[addOnMsgBank] ' + response['addOnMsgBank']);
													addOnMsgBankCount = response['addOnMsgBank'].length;
												}
												if (addOnIDDCount === 1 && response['addOnIDD'][0].cspmb__Recurring_Charge__c === 0 ) { // Hitesh EDGE-146184
													let updateConfigMap2 = {};
													console.log('addOn Idd ' + response['addOnIDD'][0].Id);
													// Arinjay
													updateConfigMap2[subsConfig.guid] = [];
													updateConfigMap2[subsConfig.guid].push({
														name: 'InternationalDirectDial',
														value: response['addOnIDD'][0].Id,
														displayValue: response['addOnIDD'][0].AddOn_Name__c,
														readOnly: true,
                                                        lookup:response['addOnIDD'][0]// added for EDGE-162025
													},
													{
														name: 'SelectIDD',													   
														value: response['addOnIDD'][0].AddOn_Name__c,													   
														displayValue: response['addOnIDD'][0].AddOn_Name__c													   
													},// added for EDGE-162025
													{
														name: 'IDD Charge',
														value: response['addOnIDD'][0].cspmb__Recurring_Charge__c,
														displayValue: response['addOnIDD'][0].cspmb__Recurring_Charge__c
													},
													{
														name: 'BussinessId_Addon',
														value: response['addOnIDD'][0].cspmb__Add_On_Price_Item__r.Charge_Id__c,
														displayValue: response['addOnIDD'][0].cspmb__Add_On_Price_Item__r.Charge_Id__c
													},
													{
														name: 'IDDReadOnlyFlag',
														//value: {
															value: true,
															displayValue: true
														//}
													}
													);
													if (updateConfigMap2[subsConfig.guid].length > 0) {
														//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false).then(component => EMPlugin_CancelledCLI(inputMapCLI));// Added as part of EDGE-134880 by ankit
														let keys = Object.keys(updateConfigMap2);
														for (let i = 0; i < keys.length; i++) {
															await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
														}
													}
												}
												if (addOnIDDCount === 0 ) { // Hitesh EDGE-146184
													let updateConfigMap2 = {};
													console.log('addOn Idd ' + response['addOnIDD'][0].Id);
													updateConfigMap2[subsConfig.guid] = [];
													updateConfigMap2[subsConfig.guid].push({
															name: 'IDDReadOnlyFlag',
															value: true,
															displayValue: true
													});
													if (updateConfigMap2[subsConfig.guid].length > 0) {
														//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false).then(component => EMPlugin_CancelledCLI(inputMapCLI));// Added as part of EDGE-134880 by ankit
														let keys = Object.keys(updateConfigMap2);
														for (let i = 0; i < keys.length; i++) {
															await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
														}
													}
												}
												if (addOnMsgBankCount) {
													let updateConfigMap2 = {};
													console.log('addOn MsgBank ' + response['addOnMsgBank'][0].Id);
													updateConfigMap2[subsConfig.guid] = [];
													updateConfigMap2[subsConfig.guid].push({
															name: 'MessageBank',
															value: response['addOnMsgBank'][0].Id,
															readOnly: false,
															displayValue: response['addOnMsgBank'][0].cspmb__Add_On_Price_Item__r.Message_Bank__c
														}, {
															name: 'MessageBank RC',
															value: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c,
															displayValue: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c
														});
													if (updateConfigMap2[subsConfig.guid].length > 0) {
														//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false);
														let keys = Object.keys(updateConfigMap2);
														for (let i = 0; i < keys.length; i++) {
															await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);  // false added by shubhi 14/08
														}
													}
												}
											});
										}
									}
								// update ParentPriceItem of related product
									if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
									let updateConfigMap = {};
										subsConfig.relatedProductList.forEach((relatedConfig) => {
											if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === 'Related Component') {
												if(subsConfig.guid == guid){
												isRelatedDeviceAdded = true;
												}
												//relatedConfig.configurationId = relatedConfigurationID ;//commented for EDGE-170151
												//console.log('relatedConfigurationID ---->'+relatedConfigurationID);//
												Object.values(relatedConfig.configuration.attributes).forEach((priceItemAttribute) => {
													if (priceItemAttribute.name === 'ParentPriceItem') {
														updateConfigMap[relatedConfig.guid] = [{
															name: 'ParentPriceItem',
															value: newValue,
															displayValue: newValue
														}];
													}
												});
											}
										});
										//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
										let keys = Object.keys(updateConfigMap);
										for (let i = 0; i < keys.length; i++) {
											await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
										}
										console.log('before get IDD ' + selectedPlan + selectPlanDisplayValue);
									}
								});
							}
						}
					});
				}
			}
			//});
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'SelectPlanName' && oldValue != newValue && newValue !== '' && newValue !== null) {
			//CS.SM.getActiveSolution().then((product) => {
			if ( product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.schema && product.schema.configurations && Object.values(product.schema.configurations).length > 0) {
					Object.values(product.components).forEach((comp) => {
						if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) { 
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
									if(subsConfig.guid===guid){
										var changeTypeAtrtribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'ChangeType'
										});
										var SelectPlanNameAttribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'SelectPlanName'
										});
										if(changeTypeAtrtribute[0].value==='Modify'  ||changeTypeAtrtribute[0].value==='Cancel'){
											productInError = false ;
											if((subsConfig.configurationName.includes('XX-Large Data SIM BYO')||subsConfig.configurationName.includes('X-Large Data SIM BYO')) && (newValue==='Data SIM $5' ||newValue==='Data SIM $40')){
												//CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false,'change of plan not allowed.');
												let cnfg = await comp.getConfiguration(subsConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'change of plan not allowed.';
												productInError = true ;
											}
											if((subsConfig.configurationName.includes('Data SIM $5')||subsConfig.configurationName.includes('Data SIM $40')) && (newValue==='XX-Large Data SIM BYO' ||newValue==='X-Large Data SIM BYO')){
												//CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false,'change of plan not allowed.');
												let cnfg = await comp.getConfiguration(subsConfig.guid); 
												cnfg.status = false;
												cnfg.statusMessage = 'change of plan not allowed.';
												productInError = true ;
											}
										}
									}	
								});
							}	
						}	
					});
				}
			}
			//});
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'InternationalDirectDial') {
			// Added as part of EDGE-134880 by ankit || start
			if(oldValue !== newValue){
				skipsave=true; //added by ankit EDGE-132203
			}
			let inputMapCLI = {};
			inputMapCLI['guid'] =guid;
			inputMapCLI['basketId'] = basketId;
			console.log('inputMapCLI::: ', inputMapCLI);
			// Added as part of EDGE-134880 by ankit || END
			console.log('here InternationalDirectDial ' + newValue);
			//pricingUtils.resetisDiscountMobileSubscriptionSAttributes(guid); //added for  edge-123575 by shubhi
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);//added for  edge-123575 by shubhi
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);//added for  edge-123575 by shubhi
			//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);//edge-123575 by shubhi
			//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_PI', true);//edge-123575 by shubhi
			pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
			pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
			pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
			if(newValue!=null && newValue!=''){
				//CS.SM.getActiveSolution().then((product) => {
				inputMapCLI['solutionID'] = product.solutionId;
				if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
					if (product.components && Object.values(product.components).length > 0) {
						Object.values(product.components).forEach((comp) => {
								if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
									if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									console.log('here 2');		
									Object.values(comp.schema.configurations).forEach(async (config) => {
										console.log('here 3');
										if (config.guid === guid) {
											Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDAllowance', true);
											Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDD ChargeLookup', true);
											Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);
											console.log('IDD -- Aman');
											//invoke method to get the allowance details
											let inputMap = {};
											inputMap[newValue] = 'getAddOn';
											var addOnRecId = null;
											var addOnValue = null;
											var addOncharge = null;
											console.log('before entering '+ newValue);
											currentBasket.performRemoteAction('SolutionGetPricingRecords', inputMap).then(async response => {   
												console.log('response', response);										
													if (response && response['addOnList'] != undefined) {
														console.log('addOnList', response['addOnList']);
														response['addOnList'].forEach((a) => {
															if(a.Id != null){
																addOnRecId = a.Id;
																addOnValue = a.Name;
																addOncharge = a.Charge_Id__c;
															}
														});
														console.log('addOnRecId ', addOnRecId);
														if(addOnRecId!= ''){
															let updateConfigMap1 = {};
															updateConfigMap1[config.guid] = [{
																	name: 'IDD ChargeLookup',
																	value: addOnRecId,
																	displayValue: addOnValue
															},
															{
																	name: 'BussinessId_Addon',
																	value: addOncharge,
																	displayValue: addOncharge
															}
															];
															console.log('updateConfigurationAttribute IDDcharge');
															//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap1, false).then(component => EMPlugin_CancelledCLI(inputMapCLI));// Added as part of EDGE-134880 by ankit
															//Arinjay
															let keys = Object.keys(updateConfigMap1);
															for (let i = 0; i < keys.length; i++) {
																await comp.updateConfigurationAttribute(keys[i], updateConfigMap1[keys[i]], false); 
															}
														}
													} else {
														console.log('no response');
													}
												});
												if(addOnRecId!=null){
													var allowanceRecId = null;
													var allowanceValue = null;
													let inputMap2 = {};
													inputMap2['addOnPriceItemId'] = addOnRecId;
													currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap2).then(async response => {   
													console.log('response', response);										
														if (response && response['allowances'] != undefined) {
															console.log('allowances', response['allowances']);
															response['allowances'].forEach((a) => {
																if(a.Id != null){
																	allowanceRecId = a.cspmb__allowance__r.Id;
																	allowanceValue = a.cspmb__allowance__r.Name;
																}
															});
															console.log('allowanceRecId ', allowanceValue);
															if(allowanceRecId!= ''){
																let updateConfigMap2 = {};
																updateConfigMap2[config.guid] = [{
																	name: 'IDDAllowance',
																	value: allowanceRecId,
																	displayValue: allowanceValue
																}];
																console.log('updateConfigurationAttribute IDDallowance');
																//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false);
																let keys = Object.keys(updateConfigMap2);
																for (let i = 0; i < keys.length; i++) {
																	await comp.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
																}
															}
														} else {
															console.log('no response');
														}
													});
												}
											}
										});
									}
								}
							});
						}
					}
				//});
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'IDD ChargeLookup') {
			console.log('here IDD ChargeLookup ' + newValue);
			//CS.SM.getActiveSolution().then((product) => {
			if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.components && Object.values(product.components).length > 0) {
						Object.values(product.components).forEach((comp) => {
							if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((config) => {
									if (config.guid == guid) {
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDAllowance', true);
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);//added for  edge-123575 by shubhi
										Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);//added for  edge-123575 by shubhi
										//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);//edge-123575 by shubhi
										//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_PI', true);//edge-123575 by shubhi
										pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
										pricingUtils.setIsDiscountCheckNeeded(comp.schema,ENTERPRISE_COMPONENTS.mobileSubscription); //Aditya-Samish For EDGE-132203 Error handling
										pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
										pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
										if(newValue!=null){
											var allowanceRecId = null;
											var allowanceValue = null;
											let inputMap2 = {};
											inputMap2['addOnPriceItemId'] = newValue;
											currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap2).then(async response => {   
											console.log('response', response);										
												if (response && response['allowances'] != undefined) {
													console.log('allowances', response['allowances']);
													response['allowances'].forEach((a) => {
														if(a.Id != null){
															allowanceRecId = a.cspmb__allowance__r.Id;
															allowanceValue = a.cspmb__allowance__r.Name;
														}
													});
													console.log('allowanceRecId ', allowanceValue);
													if(allowanceRecId!= ''){
														let updateConfigMap2 = {};
														updateConfigMap2[config.guid] = [{
															name: 'IDDAllowance',
															value: allowanceRecId,
															displayValue: allowanceValue
														}];
														console.log('updateConfigurationAttribute IDDallowance');
														//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, false);
														let keys = Object.keys(updateConfigMap2);
														for (let i = 0; i < keys.length; i++) {
															await comp.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
														}
													}
												} else {
													console.log('no response');
												}
											});
										}
									}
								});
								}
							}
						});
				}
			}
			//});
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'Device Type') {
			//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'deviceTypeString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetManufacturer', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetModel', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeLookup', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTerm', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTermString', true);
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'MobileHandsetManufacturer') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetModel', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeLookup', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTerm', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ModelString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTermString', true);
			let updateConfigMap = {};
			updateConfigMap[guid] = [{
				name: 'ManufacturerString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
				}
			];
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'MobileHandsetModel') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'MobileHandsetColour', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeLookup', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTerm', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ColourString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTermString', true);
			let updateConfigMap = {};
			updateConfigMap[guid] = [{
				name: 'ModelString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			}];
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'MobileHandsetColour') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeLookup', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTerm', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PaymentTypeString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTermString', true);
			let updateConfigMap = {};
			updateConfigMap[guid] = [{
				name: 'ColourString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			}];
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);		
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'PaymentTypeLookup') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			console.log('entered PaymentTypeLookup updates===');
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTerm', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'ContractTermString', true);
			Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
			console.log('entered PaymentTypeLookup updates==='+attribute.displayValue);
			//console.log('entered PaymentTypeLookup updateConfigMap before==='+updateConfigMap);
			let updateConfigMap = {};
			updateConfigMap[guid] = [{
				name: 'PaymentTypeString',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			}];
			console.log('entered PaymentTypeLookup updateConfigMap after==='+updateConfigMap);
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'InContractDeviceRecId') {
			if(newValue!=null){
				let deviceRecord = newValue;
				let planRecord = null;
				console.log('entering InContractDeviceRecId change');
				//CS.SM.getActiveSolution().then((product) => {
				if (/*product.type && */ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
					if (product.components && Object.values(product.components).length > 0) {
						Object.values(product.components).forEach((comp) => {
							if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((parentConfig) => {
										if(parentConfig.guid === guid){
											Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanDiscountLookup', true);
											Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'TotalPlanBonus', true);
											Object.values(parentConfig.attributes).forEach((configAttr) => {
												if (configAttr.name === 'Select Plan') {
													planRecord = configAttr.value;
												}
											});
											if(planRecord!=null){
												EMPlugin_updatePlanDiscount(parentConfig,planRecord,deviceRecord);
											}												
										}
									});
								}
							}
						});
					}
				}
				//});
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ContractTerm') {
			if(newValue!=null){
				let deviceRecord = newValue;
				let planRecord = null;
				console.log('entering InContractDeviceRecId change');
				//CS.SM.getActiveSolution().then((product) => {
				if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
					if (product.components && Object.values(product.components).length > 0) {
						Object.values(product.components).forEach((comp) => {
							if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((parentConfig) =>{
										if(parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0 ){
												parentConfig.relatedProductList.forEach((relatedConfig) => {
													if(relatedConfig.guid === guid){
														Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanDiscountLookup', true);
														Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'TotalPlanBonus', true);
														//Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
														//Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
														//Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
														//Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true);
														Object.values(parentConfig.attributes).forEach((configAttr) => {
															if (configAttr.name === 'Select Plan') {
																planRecord = configAttr.value;
															}
														});
														if(planRecord!=null){
															EMPlugin_updatePlanDiscount(parentConfig,planRecord,deviceRecord);
														}
														//added by shubhi 13/08 start------EDGE-169298
                        								//let solUp =  CS.SM.getActiveSolution();
														//let compUp =  solUp.getComponentByName(componentName);
														let cnfg =  comp.getConfiguration(guid);
                        								var InContrctDevcEnrolEligib = Object.values(cnfg.attributes).filter(obj => {
                                                            return obj.name === 'InContractDeviceEnrollEligibility'
                                                        });
                                                        if(InContrctDevcEnrolEligib && InContrctDevcEnrolEligib[0] && (!InContrctDevcEnrolEligib[0].value || InContrctDevcEnrolEligib[0].value=='')){
                                                            var upmap={};
                                                            upmap[guid]=[{
                                                                name: 'DeviceEnrollment',
																	value:"NOT ELIGIBLE",
																	displayValue: "NOT ELIGIBLE",
																	showInUi: true,
																	readOnly:true,
																	options: ["NOT ELIGIBLE"]
															}];
                                                            let keys = Object.keys(upmap);
                                                            for (let i = 0; i < keys.length; i++) {
                                                                comp.updateConfigurationAttribute(keys[i], upmap[keys[i]], true); 
                                                            }
                                                        }
														//added by shubhi 13/08 end ------EDGE-169298
													}
												});
											}	
									});
								}
							}
						});
					}	
				}
				//});
			}
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ContractTerm') {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			console.log('test contract term value on hook ' + attribute.value + '===' + attribute.displayValue);
			let updateConfigMap = {};
			updateConfigMap[guid] = [{
				name: 'RemainingTerm',
				value: attribute.displayValue,
				displayValue: attribute.displayValue
			}];
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
			//CS.SM.getActiveSolution().then((product) => {
			if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.components && Object.values(product.components).length > 0) {
					Object.values(product.components).forEach((comp) => {
							if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((parentConfig) => {
									if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {	
										parentConfig.relatedProductList.forEach(async (relatedProduct) => {
											if (relatedProduct.guid === guid) {
												let inContractDeviceCount = EMPlugin_getInContractMobileDevices(parentConfig);
												if(inContractDeviceCount > 1){
													//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription, parentConfig.guid, false, 'There cannot be more than 1 device of payment type Contract for this plan.');
													let cnfg = await comp.getConfiguration(parentConfig.guid); 
													cnfg.status = false;
													cnfg.statusMessage = 'There cannot be more than 1 device of payment type Contract for this plan.';
												}else{
													let updateConfigMap2 = {};
													updateConfigMap2[parentConfig.guid] = [{
														name: 'InContractDeviceRecId',
														value: attribute.value,
														displayValue: attribute.value
													}];
													//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, true);
													let keys = Object.keys(updateConfigMap2);
													for (let i = 0; i < keys.length; i++) {
														await comp.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], true); 
													}
												}
											}
										});
									}
								});
								}
							}
						});
				}
			}
			//});
		}
			// update Total Plan Bonus
		if (componentName === ENTERPRISE_COMPONENTS.device && attribute.name === 'MROBonus') {
			// get parent configuration
			//CS.SM.getActiveSolution().then((product) => {
			if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.components && Object.values(product.components).length > 0) {
					Object.values(product.components).forEach((comp) => {
						if (comp.name === componentName) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach((parentConfig) => {									
									if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {										
										parentConfig.relatedProductList.forEach(async (relatedProduct) => {
											if (relatedProduct.guid === guid) {
												//EMPlugin_calculateTotalMROBonus(componentName, parentConfig);
												// set valid config on mobile subscription
												//CS.SM.updateConfigurationStatus(componentName, parentConfig.guid, true);
												let cnfg = await comp.getConfiguration(parentConfig.guid); 
												cnfg.status = true;
											}
										});
									}
								});
							}
						}
					});
				}
			}
			//});
		}
		//ankit added as part of EDGE-112367
		if(componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'InContractDeviceEnrollEligibility'){
			//CS.SM.getActiveSolution().then((product) => {
			//Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DeviceEnrollment', true); commented by shubhi //commented by shubhi 13/08 end ------EDGE-169298
			if (/*product.type &&*/ product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				if (product.components && Object.values(product.components).length > 0) {
					Object.values(product.components).forEach((comp) => {
						if (comp.name === componentName) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach((parentConfig) => {
								var changeTypeAtrtribute = Object.values(parentConfig.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
								if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0  && (changeTypeAtrtribute[0].value !=='Modify' ||changeTypeAtrtribute[0].value !=='Cancel'|| changeTypeAtrtribute[0].value !=='Active')) {
									parentConfig.relatedProductList.forEach((relatedProduct) => {
										if (relatedProduct.guid === guid) {
											let updateConfigMap = {};
											Object.values(relatedProduct.configuration.attributes).forEach(async (attr)=> {
												if(attr.name==='InContractDeviceEnrollEligibility' ) {
													console.log('Inside Cancel Update for ChangeType',attr.value);
													if(attr.value!=='' && attr.value!==null){
														if(attr.value==='Eligible'){
														updateConfigMap[relatedProduct.guid] = [{
															name: 'DeviceEnrollment',
																// value: {
																	value:"DO NOT ENROL",
																	displayValue: "DO NOT ENROL",
																	showInUi: true,
																	readOnly:false,
																	required:true,
																	options: ["ENROL","DO NOT ENROL"]
																// }
															}];
														}else{
														updateConfigMap[relatedProduct.guid] = [{
															name: 'DeviceEnrollment',
																// value: {
																	value:"NOT ELIGIBLE",
																	displayValue: "NOT ELIGIBLE",
																	showInUi: true,
																	readOnly:true,
																	options: ["NOT ELIGIBLE"]
																// }
															}];
														}
													}else{
														updateConfigMap[relatedProduct.guid] = [{
															name: 'DeviceEnrollment',
																// value: {
																	value:"",
																	displayValue: "",
																	showInUi: false,
																	readOnly:false,
																	options: [""]
																// }
															}];
													}
													//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
													// Arinjay added on behalf of Shubhi  EDGE :: 169298
													let solution = await CS.SM.getActiveSolution();
													let component = await solution.getComponentByName(componentName);
													let keys = Object.keys(updateConfigMap);
													for (let i = 0; i < keys.length; i++) {
														await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
													}
												}
											});
										}
								});
							}
							});
						}
					}
					});
				}
			}
			//});
		}
		//Ritika added for EDGE-81135 : Cancellation of CMP
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue &&  newValue === 'Cancel') {			
			EMPlugin_check_cancellationOfAllCMPs(); 
			console.log('Inside Cancel Update for ChangeType');					
		}
		// if block added for edge-120132
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription){
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');// edge-120132
		}
		//added for  edge-123575 by shubhi
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'DP Plan') {
			pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
			pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
			pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
		}
		if (componentName === ENTERPRISE_COMPONENTS.device && attribute.name === 'TotalPlanBonus') {
			pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
			pricingUtils.setDiscountStatus('None',ENTERPRISE_COMPONENTS.enterpriseMobility);//added for  edge-123575 by shubhi
			pricingUtils.resetCustomAttributeVisibility();//added for  edge-123575 by shubhi
		}
		// EDGE-131531 - Hiding Price Schedule and Show Promotion and Discounts	 in case of Cancel and displaying incase of Modify
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && ( newValue === 'Cancel')) {
			//EMPlugin.updateAttributeVisibility = function (componentName, attributeName, guid,isReadOnly,isVisible, isRequired) {
			EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'viewDiscounts', guid,true, false, false);
			EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'Price Schedule', guid,true, false, false);
		}
		if(componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && newValue === 'Modify'){			
			//EMPlugin.updateAttributeVisibility = function (componentName, attributeName, guid,isReadOnly,isVisible, isRequired) {
			console.log ( 'Its Modify --- Making links Visible!!!!!!!!' );
			EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'viewDiscounts', guid,false, true, false);
			EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'Price Schedule', guid,false, false, false);
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');
			pricingUtils.resetDiscountAttributes(guid,ENTERPRISE_COMPONENTS.mobileSubscription);
			// EDGE-131531 - changes end
				if(oldValue === 'Cancel'){
					EMPlugin_updatePricescheduleCheck(guid);
				}
		}
		//Added by Aman Soni as a part of EDGE-123593 || End    
		//Added by Laxmi - EDGE-142321 - Port Out Reversal
		// Arinjay Aug 10 , Arinjay Uncommented this section , commented earlier  
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'IsDiscountCheckNeeded' && newValue === true) {
			console.log('Inside attribute IsDiscountCheckNeeded');
			//CS.SM.updateConfigurationStatus(componentName, guid, false, 'Please Click on "Generate Net Price" to update pricing of items in the basket');	
			let comp = await product.getComponentByName(componentName); 												
			let cnfg = await comp.getConfiguration(guid); 
			cnfg.status = false;
			cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
		}
		if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'UseExitingSIM' && oldValue != newValue ) {
			let componentObj = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			var simShipping ;
			if (newValue === true) 
			simShipping = 'FALSE';
			else
			simShipping = 'TRUE';
			let updateConfigMap = {};
			updateConfigMap[guid] = [
				{
					name: 'ShippingRequired',
					// value: {
						value: simShipping,
						displayValue: simShipping
					// }
				}
			];
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
			let keys = Object.keys(updateConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await componentObj.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
			}
		}
		console.log('end afterAttributeUpdated');
		//window.afterAttributeUpdatedOE = function(componentName, guid, attribute, oldValue, newValue){
		//window.afterAttributeUpdatedOE(componentName, configuration.guid, attribute, oldValueMap.value, attribute.value);
		window.afterAttributeUpdatedOE(componentName, configuration.guid, attribute, oldValueMap['value'], attribute.value);
		show = false;
		//EMPlugin_CheckErrorsOnSolution();
		// Arinjay 08 Aug
		EMPlugin_CheckErrorsOnSolution();
		// Arinjay 08 Aug
		
		if (basketStage === 'Contract Accepted'){
			product.lock('Commercial',false);
		}
		return Promise.resolve(true);	
	};
	/*
	EMPlugin.afterNavigate = function(currentComponent, previousComponent) {
		console.log('Inside afterNavigate'+currentComponent+previousComponent);
		EMPlugin_subscribeToExpandButtonEvents(currentComponent.name);
		return Promise.resolve(true);
	};
	*/
	EMPlugin.beforeSave =  async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//DO NOT PUT IN HERE ANY ADDITIONAL CODE OR MODIFY THIS FUNCTION !!!
		//DO ALL CHANGES ONLY IN EMPlugin_saveSolutionEM !!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!        
		if (basketStage === 'Contract Accepted'){
			solution.lock('Commercial',false);
		}

		var terminateSave=true;
		// Arinjay 06-Aug-2020
		executeSaveEM = true;
		console.log('beforeSave - entering', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
		terminateSave = await EMPlugin_saveSolutionEM(solution);
		if (basketStage === 'Contract Accepted'){
			solution.lock('Commercial',true);
		}
		if(!terminateSave)
			return Promise.resolve(false);
		return Promise.resolve(true);
		// Arinjay 06-Aug-2020
		console.log('beforeSave - entering');
		//added by Romil	
		// allowSaveEM= true;   // Commented by Sandeep
		console.log('allowSaveEM >> ' + allowSaveEM);
		if (allowSaveEM) {
			allowSaveEM = false;
			console.log('beforeSave - exiting true');
			return Promise.resolve(true);
		}
		executeSaveEM = true;
		//console.log('beforeSave 111 - exiting false');
		return Promise.resolve(true);
	}
	EMPlugin.afterSave  = async function(result,  configurationsProcessed, saveOnlyAttachment, configurationGuids){
		console.log('afterSave - entering with basket Changed Type ',window.BasketChange === 'Change Solution');
		//EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
		//await EMPlugin_checkConfigurationSubscriptionsForEM();
		console.log('result ' , result );
		let currentSolution = result.solution ; // await CS.SM.getActiveSolution();
		if(currentSolution == null || currentSolution == undefined)
			currentSolution =  await CS.SM.getActiveSolution();
		
		if (basketStage === 'Contract Accepted'){
			currentSolution.lock('Commercial',false);
		}
		
		await EMPlugin_checkConfigurationSubscriptionStatus();
		await EMPlugin_checkConfigurationServiceForEM();

		
		//console.log('currentSolution ' , currentSolution );
		//console.log('currentSolution.name ' , currentSolution.name );

		//Added by Aman Soni as a part of EDGE-148455 || Start
		var solutionComponent = false;
		if(currentSolution && currentSolution !== null){
		if(/*solution.type &&*/ currentSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)){
			if(currentSolution.schema && currentSolution.schema.configurations && Object.values(currentSolution.schema.configurations).length > 0){
				solutionComponent = true;
				var componentMapASave = new Map();
				var componentMapattrAftSave = {};
				Object.values(currentSolution.schema.configurations).forEach((config) =>{
					if(config.replacedConfigId && config.replacedConfigId != null){
						Object.values(config.attributes).forEach((attr) =>{
							var billingAccLook = Object.values(Object.values(currentSolution.schema.configurations)[0].attributes).filter(a => {
								return a.name === 'BillingAccountLookup' 
							});
							if(billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
							{
								CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.enterpriseMobility,'BillingAccountLookup',solutionComponent);		
							}
							componentMapattrAftSave['BillingAccountLookup'] = [];
							componentMapattrAftSave['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
							componentMapASave.set(config.guid, componentMapattrAftSave);
						});
					}
				});
				CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMapASave);	
			}
		}
	}
		//Added by Aman Soni as a part of EDGE-148455 || End
		if (window.BasketChange === 'Change Solution' )
		{
			 //added by Romil	
			RedemptionUtils.calculateBasketRedemption();	
			RedemptionUtils.displayCurrentFundBalanceAmt();	
			RedemptionUtils.populatebasketAmountforCancelCMP();	
			RedemptionUtils.populatebasketAmountforModifyCMP();	
			RedemptionUtils.checkConfigurationStatus();
			await EMPlugin_UpdateAttributesForMacdOnSolution(currentSolution);
		}
		else	
		{	
			//added by Romil	
			Utils.updateComponentLevelButtonVisibility('Check OneFund Balance', false, false);	
		}
		EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave();
		Utils.updateCustomButtonVisibilityForBasketStage();
		EMPlugin_updateFieldsVisibilityAfterSolutionLoad(currentSolution);
		EMPlugin_updateDeviceEnrollmentAfterSolutionLoad() ;
		if (basketStage === 'Commercial Configuration'){
			console.log(basketStage - 'Comcon');
			//await CS.SM.setBasketLockOnComponent('ENTERPRISE_COMPONENTS.mobileSubscription', true).then( result => console.log(result ));
		}
		//await EMPlugin_handlePortOutReversal (); 	 // Added by Laxmi for EDGE-142321
		//await EMPlugin_resetDeliveryDetailsinOESchema (); // Added by Laxmi for EDGE-142321	


		EMPlugin_updateChangeTypeAttribute();
		EMPlugin_UpdateMainSolutionChangeTypeVisibility(currentSolution);
		await EMPlugin_updateStatusAfterSolutionLoad();
		await pricingUtils.resetCustomAttributeVisibility();
		//pricingUtils.hideRecurringCharges(solution);
		if (window.currentSolutionName === ENTERPRISE_COMPONENTS.enterpriseMobility) {
			Utils.hideSubmitSolutionFromOverviewTab();
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// edge-120132
			Utils.updateCustomAttributeLinkText('Price Schedule','View All')
		}
		// added by shubhi for EDGE-137466 || end
		EMPlugin_subscribeToExpandButtonEvents(ENTERPRISE_COMPONENTS.mobileSubscription);//Added by Aman Soni as a part of EDGE-123593
		// added by shubhi for EDGE-137466 || start
		if (window.BasketChange === 'Change Solution'  && basketStage === 'Commercial Configuration')	{ 
			validateOERules.resetCRDDatesinCaseOfModify(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription);
			 //validateOERules.checkOERequirementsforMACD(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription,ENTERPRISE_COMPONENTS.device); // added by shubhi for EDGE-137466 -
			//Commented above method call - EDGE-142321 - instead calling it on Provide/Modify on Ccommercial COnfig -added below condition
		 }	
		/**if (basketStage === 'Commercial Configuration' ||basketStage === 'Draft'  )	{ // Added Draft status as well to status as first time the basket stage will be Draft// EDGE-142321 -moved the method call from
			validateOERules.checkOERequirementsforMACD(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription,ENTERPRISE_COMPONENTS.device); // added by shubhi for EDGE-137466 -
		 }
        **/
	   	await Utils.updateActiveSolutionTotals();
       	CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade 
		console.log('at end afterSave');
		if (basketStage === 'Contract Accepted'){
			currentSolution.lock('Commercial',true);
		}
		return Promise.resolve(true);
    }
    //Aditya: Spring Update for changing basket stage to Draft
    EMPlugin.afterSolutionDelete = function (solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }
	EMPlugin.afterRelatedProductDelete = async function (component, configuration, relatedProduct) {
		console.log('afterRelatedProductDelete', component, configuration, relatedProduct);
		let inContractDeviceCount = 0;
		let solution = await CS.SM.getActiveSolution();
		//let component = await solution.getComponentByName(componentName); 
		let cnfg = await component.getConfiguration(configuration.guid); 
		if (relatedProduct.name === 'Device' && relatedProduct.type === 'Related Component') {
			// reculculate totalPlanBonus
			await EMPlugin_calculateTotalMROBonus(component.name, configuration,relatedProduct);
			inContractDeviceCount = EMPlugin_getInContractMobileDevices(configuration);
			var IsUpdated=false;
			//if(IsDiscountCheckNeededValue){
			// CS.SM.getActiveSolution().then((product) => {
			// 	solution = product;
			// });
			if(component.name===ENTERPRISE_COMPONENTS.mobileSubscription)
				pricingUtils.resetDiscountAttributes(configuration.guid,ENTERPRISE_COMPONENTS.mobileSubscription);
			//CS.SM.updateConfigurationStatus(componentName, configuration.guid, false, 'Please Click on Generate "Net Price" to update pricing of items in the basket');
			cnfg.status = false;
			cnfg.statusMessage = 'Please Click on Generate "Net Price" to update pricing of items in the basket';
			skipsave = true;//added by ankit EDGE-132203
			//}
		}
		if(inContractDeviceCount > 1){
			//CS.SM.updateConfigurationStatus(componentName, configuration.guid, false, 'There cannot be more than 1 In-Contract device for this plan.');
			// let cnfg = await component.getConfiguration(configuration.guid); 
			cnfg.status = false;
			cnfg.statusMessage = 'There cannot be more than 1 In-Contract device for this plan.';
		}
		//if(!IsUpdated)
		//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,configuration.guid,true);	
		EMPlugin_handlePortOutReversal (); // Laxmi Added for EDGE-142321
		EMPlugin_resetDeliveryDetailsinOESchema (); // laxmi Added for EDGE-142321
		return Promise.resolve(true);
	}
	EMPlugin.afterRelatedProductAdd = async function (component, configuration, relatedProduct) {
		console.log('afterRelatedProductAdd', component, configuration, relatedProduct);
		let inContractDeviceCount = 0;
		let componentName = component.name;
		//Spring 20
		console.log('component.name = ' , componentName);
		//let solution = componentName;
		//let component = await solution.getComponentByName(componentName); 
		console.log('afterRelatedProductAdd component ',component);
		if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === 'Related Component') {
			if(componentName===ENTERPRISE_COMPONENTS.mobileSubscription)
				pricingUtils.resetDiscountAttributes(configuration.guid,ENTERPRISE_COMPONENTS.mobileSubscription);
			var selectPlanFromParent = '';
			var IsDiscountCheckNeededValue=''
			var selectedPlanValue = '';
			var ChangeTypeValue = '';
			Object.values(configuration.attributes).forEach((planAttribute) => {
				if (planAttribute.name === 'Select Plan') {
					selectPlanFromParent = planAttribute.value;
					selectedPlanValue = planAttribute.displayValue;
				}
				if (planAttribute.name === 'IsDiscountCheckNeeded') {
					IsDiscountCheckNeededValue = planAttribute.value;
				}
				if (planAttribute.name === 'ChangeType') {
					ChangeTypeValue = planAttribute.value;	
				}
			});
			if(selectedPlanValue!= '' && selectedPlanValue.includes('BYO')){
				//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.device,relatedProduct.guid,false,'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.');
				let cnfg = await component.getConfiguration(relatedProduct.guid); 
				cnfg.status = false;
				cnfg.statusMessage = 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.';
			}else{
				Object.values(relatedProduct.configuration.attributes).forEach(async (priceItemAttribute) => {
					if (priceItemAttribute.name === 'ParentPriceItem') {
						let updateConfigMap = {};
						updateConfigMap[relatedProduct.guid] = [{
							name: 'ParentPriceItem',
							value: selectPlanFromParent,
							displayValue: selectPlanFromParent												
						}
						];
						//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
						//Spring 20
						let keys = Object.keys(updateConfigMap);
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
						}
					}
					var IsUpdated=false;
					//if(IsDiscountCheckNeededValue){
					//Spring 20
					// CS.SM.getActiveSolution().then((product) => {
					// 	solution = product;
					// });
					//CS.SM.updateConfigurationStatus(componentName, configuration.guid, false, 'Please Click on Generate "Net Price" to update pricing of items in the basket');
					// Arinjay : Commented as per 20.08
					// let cnfg = await component.getConfiguration(configuration.guid); 
					// cnfg.status = false;
					// cnfg.statusMessage = 'Please Click on Generate "Net Price" to update pricing of items in the basket';
					skipsave = true;//added by ankit EDGE-132203
					//}
					/*if(!IsUpdated)
						CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription, configuration.guid, true);
					}*/
				});
				inContractDeviceCount = EMPlugin_getInContractMobileDevices(configuration);
				if(inContractDeviceCount > 0){
					//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.device, relatedProduct.guid, false, 'There cannot be more than 1 In-Contract device for this plan.');
					let cnfg = await component.getConfiguration(relatedProduct.guid); 
					cnfg.status = false;
					cnfg.statusMessage = 'There cannot be more than 1 In-Contract device for this plan.';
					//CS.SM.displayMessage('There cannot be more than 1 In-Contract device for this plan.','info');
				}
			}
			if(configuration && configuration.relatedProductList.length>0){
				configuration.relatedProductList.forEach((ReletedplanList) => {
				if(ReletedplanList.guid===relatedProduct.guid){
					Object.values(configuration.attributes).forEach((parentDeviceAttribute) => {
						if(parentDeviceAttribute.name==='PlanTypeString'){
							Object.values(relatedProduct.configuration.attributes).forEach(async (DevAttribute) => {
								if(DevAttribute.name==='PlanType'){
									let updateConfigMap = {};
									updateConfigMap[relatedProduct.guid] = [{
									name: 'PlanType',
									// value: {
										value: parentDeviceAttribute.displayValue,
										displayValue: parentDeviceAttribute.displayValue
									// }
									}];
									// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
									// Spring 20
									let keys = Object.keys(updateConfigMap);
									for (let i = 0; i < keys.length; i++) {
										await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
									}
								}
							});
							}
						});	
					}
				});		
			}
		}
		await handlePortOutReversalForIndvConf (configuration.guid); // Laxmi Added for EDGE-142321
		await resetDeliveryDetailsinOESchemaForIndvConf (configuration.guid); // laxmi Added for EDGE-142321
		console.log('end of afterRelatedProductAdd');
		return Promise.resolve(true);
	};
}
EM_updateChangeTypeOptions = async function(){
	let solution = await CS.SM.getActiveSolution();
	Object.values(solution.schema.configurations).forEach(async (config) => {
		let  changeType = config.attributes['changetype'].value;
		let updateMap = {};
		let options = ['Modify','Cancel'];
		if (changeType && changeType != 'Active') {
			updateMap[config.guid] = [];
			updateMap[config.guid].push({
				name: 'ChangeType',
				options: options
			});
		}
		if(updateMap){
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await solution.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
			}
		}
	});
	Object.values(solution.components).forEach((comp) => {
		Object.values(comp.schema.configurations).forEach(async (config) => {
			let  changeType = config.attributes['changetype'].value;
			let updateMap = {};
			let options = ['Modify','Cancel'];
			if (changeType && changeType != 'Active') {
				updateMap[config.guid] = [];
				updateMap[config.guid].push({
					name: 'ChangeType',
					options: options
				});
			}
			if(updateMap){
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
				}
			}
		});
	});
}
EM_checkConfigErrors = async function () {
    let solution = await CS.SM.getActiveSolution();
    if(solution.components && Object.values(solution.components).length > 0){
        console.log('CONFIGS _______________________________________________________________');
        Object.values(solution.components).forEach((comp) => {
			if(comp.error == true ) {
				console.log('CONFIGS Component name ' + comp.name +   
						' Error ' + comp.error + ' Error Msg : ' + comp.errorMessage , (comp.errorMessages) ) ;
				if(comp.schema && comp.schema.attributes && Object.values(comp.schema.attributes).length > 0){
					Object.values(comp.schema.attributes).forEach((att1) => {
						if(att1.error == true || att1.status == false ) {
							console.log('CONFIGS comp.schema.attributes name ' + config.name + ' config value : ' + config.value + 
								' Error ' + config.error + ' Error Msg : ' + config.errorMessage , (config.errorMessages) ) ;
						}
					});
				}
				if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
					Object.values(comp.schema.configurations).forEach((config) => {
						if(config.error == true || config.status == false ) {
							console.log('CONFIGS Comp.Schema.Config name ' + config.name + ' config value : ' + config.value + 
								' Error ' + config.error + ' Error Msg : ' + config.errorMessage , (config.errorMessages) ) ;
							Object.values(config.attributes).forEach((attrib) => {
								if(attrib.error == true  || attrib.status == false ) {
									console.log('\nCONFIGS Attrib name ' + attrib.name + ' attrib value : ' + attrib.value + 
										' Error ' + attrib.error + ' Error Msg : ' + attrib.errorMessage , (attrib.errorMessages) ) ;
								}
							});
						}
					});
				}
			}
        });
        console.log('CONFIGS _______________________________________________________________');
	}
	//debugger;
}
EM_checkAttribValue = async function (attribName , source ) {
    let solution = await CS.SM.getActiveSolution();
    if(solution.components && Object.values(solution.components).length > 0){
		console.log(' SOURCE ' + source );
		console.log('Attrib Value  _______________________________________________________________');
		if(solution.schema && solution.schema.attributes && Object.values(solution.schema.attributes).length > 0){
			Object.values(solution.schema.attributes).forEach((att2) => {
				if(att2.name === attribName) {
					console.log('SOLUTION ATTRIB  name ' + att2.name + ' SOLUTION ATTRIB value : ' + att2.value ) ;
				}
			});
		}
        Object.values(solution.components).forEach((comp) => {
			if(comp.schema && comp.schema.attributes && Object.values(comp.schema.attributes).length > 0){
				Object.values(comp.schema.attributes).forEach((att1) => {
					if(att1.name === attribName) {
						console.log('ATTRIB  name ' + att1.name + '  value : ' + att1.value ) ;
					}
				});
			}
			if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
				Object.values(comp.schema.configurations).forEach((config) => {
						Object.values(config.attributes).forEach((attrib) => {
							if(attrib.name === attribName ) {
								console.log('CONFIG ATTRIB  name ' + attrib.name + ' CONFIG ATTRIB  value : ' + attrib.value ) ;
							}
						});
						if (config.relatedProductList && config.relatedProductList.length > 0) {
							config.relatedProductList.forEach((relatedConfig) => {
								console.log('CONFIG ATTRIB  relatedConfig replacedConfigId ' + relatedConfig.configuration.replacedConfigId );
							});
						}
				});
			}
        });
        console.log('Attrib Value  _______________________________________________________________');
	}
	//debugger;
}
async function  EMPlugin_saveSolutionEM(solution) {
	//if (executeSaveEM) {
	if(solution == null || solution == undefined)
		solution = await CS.SM.getActiveSolution();
	//executeSaveEM = false;		
	//let currentBasket = await CS.SM.getActiveBasket();
	//Aditya-Samish For EDGE-132203 Error handling
	/*var skipsave = false;
	if (solution.components && Object.values(solution.components).length > 0) {	
		Object.values(solution.components).forEach((comp) => {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) { 
				console.log('Inside EM 1');
				pricingUtils.setIsDiscountCheckNeeded(comp.schema,comp.name);
			}
		});
		if (skipsave === true){
			return Promise.resolve(false);    
		}
	}*/ // //commented  by shubhi 14/08 added this condition in checkerror to handle all validations at one place
	let hasError=false;
	hasError=EMPlugin_CheckErrorsOnSolution(solution);
	if(hasError){
		return Promise.resolve(false);  
	}
	let isValid = true;
	if (solution.components && Object.values(solution.components).length > 0) {
		Object.values(solution.components).forEach((comp) => {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((parentConfig) => {
						if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
							let inContractDeviceCount = EMPlugin_getInContractMobileDevices(parentConfig);
							if (inContractDeviceCount > 1) {
								CS.SM.displayMessage('There cannot be more than 1 device of payment type Contract for this plan.', 'error');
								show = true;
								isValid = false;
							}
						}
					});
				}
			}
		});
	}
	EMPlugin_UpdateRemainingTermOnParent();
	if (!EMPlugin_validateCancelSolution(solution)) {
		return Promise.resolve(false);
	}
	if (!isValid) {
		return Promise.resolve(false);
	}
	if (productInError) {
		show = false;
		CS.SM.displayMessage('You cannot save Invalid PC.', 'error');
		return Promise.resolve(false);
	}
	//Arinjay Aug 09 Moved to PD Rules
	//await EMPlugin_updateEDMListToDecomposeattributeForSolution(solution);
	//await EMPlugin_updateEDMListToDecomposeattribute(solution); //Hitesh added to call to update the EDMListToDecompose attribute
	// Change for EDGE-142087 Added By Rohit
	await EMPlugin_CalculateTotalRCForSolution();
	//await EMPlugin_updateSolutionNameEM(); // Added as part of EDGE-149887
	allowSaveEM = true;
	//Addde by laxmi for 138001
	Utils.updateImportConfigButtonVisibility();
	//Added by Laxmi - EDGE-131531	
	await EMPlugin_updateLinksAttributeEMS(solution);
	await RedemptionUtils.checkConfigurationStatus();
	//}
	return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Samish Kumar
 * EDGE		   : EDGE-120137
 * Method Name : checkContractingStatus
 * Invoked When: Solution is Loaded
 * Description : Set isRecontractingDiscountEligible(Cancel or Modify)
 ***********************************************************************************************/
async function EMPlugin_checkContractingStatus(inputMapOneFund) {
	console.log('EMPlugin_checkContractingStatus');
	var componentMap = {};
	var updateMap = {};
	//await CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
				comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						//if (config.replacedConfigId || config.id) {
						if (!componentMap[comp.name])
							componentMap[comp.name] = [];
						if(config.replacedConfigId)
							componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid});
						else
							componentMap[comp.name].push({'id':config.id, 'guid': config.guid});   
						//}
					});
				}
			});
		}
	}
	//});
	let currentBasket =  await CS.SM.getActiveBasket(); 
	console.log('EMPlugin_checkContractingStatus: ', inputMapOneFund);
	var statuses;
	await currentBasket.performRemoteAction('SolutionHelperPaymentTypeOneFund', inputMapOneFund).then(values => {
		console.log('EMPlugin_checkContractingStatus result:', values);
		if (values['isRecontractingDiscountEligible'])
			statuses = values['isRecontractingDiscountEligible'];
		isPaymentTypeOneFund =values["isPaymentTypeOneFund"];
		console.log('isPaymentTypeOneFund: ', isPaymentTypeOneFund);
	});
	console.log ('EMPlugin_checkContractingStatus statuses;', statuses);
	if (statuses==='true') {
		Object.keys(componentMap).forEach(async comp => {
			componentMap[comp].forEach(element => {
				if(statuses === 'true'){
					updateMap[element.guid] =[{
						name: 'isRecontractingDiscountEligible',
						// value: {
							value: statuses,
							//showInUi: true,
							//readOnly:false,
							displayValue: statuses
						// }
					}];// End*
				}
			});
			console.log('EMPlugin_checkConfigurationSubscriptionsForEM update map', updateMap);
			//CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
			//const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
			}
			return Promise.resolve(true);
		});
	}
	return Promise.resolve(true);
}
EMPlugin_UpdateMainSolutionChangeTypeVisibility = async function(solution)  {
	if (window.BasketChange !== 'Change Solution') {
		return;
	}
	let updateMap= {};
	updateMap[Object.values(solution.schema.configurations)[0].guid] = [ {
		name: 'ChangeType',
		// value: {
			showInUi: true
		// }
	}];
	console.log('EMPlugin_UpdateMainSolutionChangeTypeVisibility',updateMap);
	//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateMap, true).catch((e)=> Promise.resolve(true));
	let component = await solution.getComponentByName(solution.name); 
	//const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true); 
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
	}
	return Promise.resolve(true);
}
EMPlugin_UpdateAttributesForMacdOnSolution = async function(solution) {
	console.log('EMPlugin_UpdateAttributesForMacdOnSolution');
	let  changeTypeAtrtribute;
	let cancellationReasonAtribute;
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			changeTypeAtrtribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
				return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
			});
			if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
				EMPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false,true, true);
			} else {
				EMPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false, false, false);
				Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'CancellationReason', false);
					// Added as part of EDGE-140967\\ Start
					Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'DisconnectionDate', false);
					Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'EarlyTerminationCharge', false);
					Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'OneOffChargeGST', false);
					//Utils.emptyValueOfAttribute(solution.schema.configurations[0].guid, solution.schema.name, 'RedeemFund', false);
					// Added as part of EDGE-140967\\ End
			}
			let comp = Object.values(solution.components).filter(c => {
				return c.schema && c.name === ENTERPRISE_COMPONENTS.mobileSubscription && c.schema.configurations && Object.values(c.schema.configurations).length > 0
			});
			if (comp && comp.length > 0) {
				for (let i = 0; i < Object.values(comp[0].schema.configurations).length; i++) {
					let config = Object.values(comp[0].schema.configurations)[i];
					//console.log('print config---->'+config.guid+Object.values(config.attributes));
					changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
						return obj.name === 'ChangeType'
					});
					console.log('print changeTypeAtrtribute---->'+changeTypeAtrtribute[0].displayValue);
					let selectPlanDisplayValue = '';
					let att = Object.values(config.attributes).filter(a => {
						return a.name === 'Select Plan'
					});
					if (att && att.length)
						selectPlanDisplayValue = att[0].displayValue;
						console.log('print selectPlanDisplayValue---->'+selectPlanDisplayValue);
					if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
						EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute[0].displayValue, selectPlanDisplayValue);
					}
				}
			}
		}
	}
	return Promise.resolve(true);
}


EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription = async function (guid, changeTypeValue, selectedPlan) {
	console.log('EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription',guid, changeTypeValue, selectedPlan);
	if (changeTypeValue === 'Cancel') {
		EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'CancellationReason', guid,false, true, true);
		let isEtcVisible = true;
		if (selectedPlan.includes('BYO'))
			isEtcVisible = false;
		EMPlugin_updateDisconnectionDateAndETC(ENTERPRISE_COMPONENTS.mobileSubscription, guid, true, isEtcVisible , basketStage === 'Commercial Configuration', false);
		await EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription,guid, true, ENTERPRISE_COMPONENTS.mobileSubscriptionEditableAttributeList);
	}
	if (changeTypeValue !== 'Cancel') {
		EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'CancellationReason', guid,false, false, false);
		Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'CancellationReason', false);
		// Added as part of EDGE-140967\\ Start
		Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'DisconnectionDate', false);
		Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'EarlyTerminationCharge', false);
		// Added as part of EDGE-140967\\ End
		EMPlugin_updateDisconnectionDateAndETC(ENTERPRISE_COMPONENTS.mobileSubscription,guid, false,false, false, false);
	}
	if (changeTypeValue === 'Modify') {
		EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription,guid, true, ['SelectPlanType']);
	}
}
EMPlugin_updateAttributeVisibility = async function (componentName, attributeName, guid,isReadOnly,isVisible, isRequired) {
	console.log('EMPlugin_updateAttributeVisibility',attributeName, componentName, guid,isReadOnly, isVisible,isRequired);
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
	let product = await CS.SM.getActiveSolution();
	let component = await product.getComponentByName(componentName); 
	//const config = await component.updateConfigurationAttribute(guid, updateMap, true); 
	if(component && component != null && component != undefined ) {
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
		}
	}
	else 
		console.log('component not found with name ', componentName);
	return Promise.resolve(true);
}
EMPlugin_updateDisconnectionDateAndETC = async function (componentName, guid, isVisible,isVisibleETC , isMandatory, isReadonly) {
	console.log ('EMPlugin_updateDisconnectionDateAndETC ',componentName, guid, isVisible,isVisibleETC, isMandatory,isReadonly);
	 let updateMap = {};
	 updateMap[guid] = [];
	 updateMap[guid].push(
		 {
			 name: 'DisconnectionDate',
			//  value: {
				 readOnly: isReadonly,
				 showInUi: isVisible,
				 required: isMandatory
			//  }
		 });
	 updateMap[guid].push(
		 {
			 name: 'EarlyTerminationCharge',
			//  value: {
				 readOnly: true,
				 showInUi: isVisibleETC,
				 required: false
			//  }
		 });
		 //added by Romil
	 updateMap[guid].push(	
			 {	
				 name: 'RedeemFund',	
				//  value: {	
					 showInUi: isVisibleETC,
				//  }	
			 });	
	updateMap[guid].push(	
			 {	
				 name: 'OneOffChargeGST',	
				//  value: {	
					 showInUi: isVisibleETC	
				//  }	
			 });	
	updateMap[guid].push(	
			 {	
				 name: 'TotalFundAvailable',	
				//  value: {	
					 showInUi: isVisibleETC	
				//  }	
			 });
	updateMap[guid].push(
		 {
			 name: 'RemainingTerm',
			//  value: {
				 readOnly: true,
				 showInUi: isVisibleETC,
				 required: false
			//  }
		 });
	//CS.SM.updateConfigurationAttribute(componentName, updateMap, false).then(()=> Promise.resolve(true)).catch(()=> Promise.resolve(true));
	let product = await CS.SM.getActiveSolution();
	let component = await product.getComponentByName(componentName); 
	//const config = await component.updateConfigurationAttribute(guid, updateMap, false); 
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
	}
	return Promise.resolve(true);
}
EMPlugin_setAttributesReadonlyValueForConfiguration = async function (componentName, guid, isReadOnly, attributeList) {
	console.log('EMPlugin_setAttributesReadonlyValueForConfiguration ',componentName,  guid, isReadOnly, attributeList);
	let solution = await CS.SM.getActiveSolution(); // Spring 20
	let updateMap = {};
	updateMap[guid] = [];
	attributeList.forEach((attribute) => {
		updateMap[guid].push(
		{
			name: attribute,
			// value: {
				readOnly: isReadOnly
			// }
		});
	});
	console.log ('EMPlugin_setAttributesReadonlyValueForConfiguration updateMap', updateMap);
	// Spring 20
	//CS.SM.updateConfigurationAttribute(componentName, updateMap, false).then(()=> Promise.resolve(true)).catch((e)=> Promise.resolve(true));
	let component = await solution.getComponentByName(componentName); 
	const config = await component.updateConfigurationAttribute(guid, updateMap, false); 	
	//CS.SM.getActiveSolution().then((solution) => {
	if (solution /*&& solution.type*/  && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						if (config.guid === guid) {
							if (comp.name === componentName) {
								var DeviceUpdate= false;
								console.log('EMPlugin_setAttributesReadonlyValueForConfiguration config',config);
								if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription && config.relatedProductList && config.relatedProductList.length>0 )
									EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts(componentName, config.relatedProductList, 'Device', isReadOnly, ENTERPRISE_COMPONENTS.mobileSubscriptionAddOnEditableAttributeList);
							}
						}
					});
				}
			});
		}
	}
	//});
	return Promise.resolve(true);
}
EMPlugin_updateRemainingTermAfterSolutionLoad = async function() {
	console.log('EMPlugin_checkRemainingTermForBYOPlans');
	// CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					console.log('EMPlugin_updateRemainingTermAfterSolutionLoad::--->4817');
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0) {
								var contractTermAtrtribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ContractTerm'
								});
								var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
								var contractTermInt = 24;
								if (config.relatedProductList && config.relatedProductList.length > 0 && (changeTypeAtrtribute[0].value === 'Modify' )) {
									config.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.name.includes('Device')) {
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 
											// Arinjay 10 Aug  Temporary Fix due to Cloud sense issue with device replacedConfigId
											//&& relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined 
											//&& relatedConfig.configuration.replacedConfigId !==null ) {
											&& config.replacedConfigId !=='' && config.replacedConfigId !== undefined 
											&& config.replacedConfigId !==null ) {
												contractTermAtrtribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
													return obj.name === 'ContractTerm'
												});
												var ChangeTypeDeviceattribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
													return obj.name === 'ChangeTypeDevice'
												});
												if (ChangeTypeDeviceattribute[0].value != 'PayOut' && ChangeTypeDeviceattribute[0].value != 'New' ) {
												console.log ( 'Remaining Term Getting called EMPlugin_updateRemainingTermAfterSolutionLoad!!' );
												CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute[0].displayValue, config.guid,comp.name,'');// EDGE-138108 Aditya Changed Signature, Added Comp Name
												}
											}
										}
									});
								}
							}
						});
					}
				}
			});
		}
	}
	// }).then(
	// 	() => Promise.resolve(true)
	// ).catch(() => Promise.resolve(true));
	return Promise.resolve(true);
}
/************************************************************************************
 * Author	: Rohit Tripathi
 * Method Name : EMPlugin_checkRemainingTermForBYOPlans
 * Defect/US # : EDGE-88407
 * Invoked When: Change Type is updated as Modisy
 * Description : Show error message when RemainingTerm is greater than zero and Enable Cancel Flag on Device
 * Parameters : guid
 ***********************************************************************************/
async function EMPlugin_checkRemainingTermForBYOPlans(guid) {
	console.log('EMPlugin_checkRemainingTermForBYOPlans');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
							var valid = true;
							errorMessage = '';
							if (config.id && !(config.name.includes('BYO'))) {
								if(config.guid == guid){
								CS.SM.displayMessage('Please note that changing your plan might affect the Plan Discount and Add-On prices. Price will be adjusted accordingly should you choose to Upgrade/Downgrade your Plan.','info');
								}
								if (config.attributes && Object.values(config.attributes).length > 0 && config.guid === guid) {
									var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'ChangeType'
								});
								var selectPlanAtrtribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'Select Plan'
								});
								console.log('EMPlugin_checkRemainingTermForBYOPlans--->4824'+changeTypeAtrtribute[0].value + selectPlanAtrtribute[0].value+selectPlanAtrtribute[0].displayValue);
								if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
									// ask hitesh to get the name of select plan instead of Id and then uncomment below code
									if (changeTypeAtrtribute[0].value === 'Modify' && selectPlanAtrtribute[0].displayValue.includes('BYO') ) {
										console.log('EMPlugin_checkRemainingTermForBYOPlans--->4827');
										if (config.relatedProductList && config.relatedProductList.length > 0) {
											config.relatedProductList.forEach(async (relatedConfig) => {
												if (relatedConfig.name.includes('Device')) {
													if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
														console.log('EMPlugin_checkRemainingTermForBYOPlans--->4835');
														var RemainingTermAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name === 'RemainingTerm'
														});															
														var cancelFlagAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name === 'CancelFlag'
														});
														var offerTypeAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name === 'OfferTypeString'
														});
														console.log('EMPlugin_checkRemainingTermForBYOPlans--->4839'+RemainingTermAttribute[0].value);
														if (RemainingTermAttribute[0].value > 0 ) {
															//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,config.guid,false,'Cannot change the plan to BYO while the associated device is In-Contract');
															let cnfg = await comp.getConfiguration(config.guid); 
															cnfg.status = false;
															cnfg.statusMessage = 'Cannot change the plan to BYO while the associated device is In-Contract';
															productInError = true ;
															console.log('Inside RemaingTerm Greater Than 0: ');
														}
													}
												}
												return Promise.resolve(true);
											});	
										}
									}
									else {
										//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,config.guid,true);	
										let cnfg = await comp.getConfiguration(config.guid); 
										cnfg.status = true;
									}
								}
							}
							return Promise.resolve(true);
						}
					});
				}
			}
		});
	}
	}
	// }).then(
	// 	() => Promise.resolve(true)
	// );
	return Promise.resolve(true);
}
function EMPlugin_getInContractMobileDevices(parentConfig){
	let inContractDeviceCount = 0;
	if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
		parentConfig.relatedProductList.forEach((relatedProduct) => {
			if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === 'Related Component') {
				Object.values(relatedProduct.configuration.attributes).forEach((attribute) => {
					if (attribute.name === 'RemainingTerm' && attribute.value > 0) {
						inContractDeviceCount = inContractDeviceCount +1;
					}
				});
			}
		});
	}
	console.log('count of in contract device  ' + inContractDeviceCount);
	return inContractDeviceCount;
}
function  EMPlugin_solutionBeforeConfigurationDeleteMacd(componentName, configuration, relatedProduct) {
	var changeTypeAttribute =  Object.values(configuration.attributes).filter(o => {return o.name==='ChangeType'});
	if (changeTypeAttribute && relatedProduct.type === 'Related Component' && relatedProduct.configuration.id) {
		if (changeTypeAttribute[0].value === 'Modify') {
			if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && configuration.relatedProductList.length === 1) {
				CS.SM.displayMessage('Not allowed to delete Mobile Device when changing Mobility configuration!', 'info');
				return false;
			}
		} else {
			//if (changeTypeAttribute[0].value === 'Cancel' || changeTypeAttribute[0].value === 'Active' || changeTypeAttribute[0].value === 'New') {
			CS.SM.displayMessage('Not allowed to delete existing related product!', 'info');
			return false;
		}
	}
	return true;
}
async function EMPlugin_validateMobileDevice(planValue, parentConfig){
	if(planValue.includes('BYO')){
		console.log('new plan is BYO');
		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
		if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
			parentConfig.relatedProductList.forEach(async (relatedProduct) => {
				//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription, parentConfig.guid, false, 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.');
				//Spring 20
				let cnfg = await component.getConfiguration(parentConfig.guid); 
				cnfg.status = false;
				cnfg.statusMessage = 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.';
			});
		}
	}
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : EMPlugin_updateRemainingTermAfterSave
 * Description : Calculated remaining term from all related product
 * Invoked When: remaining term is updated,
**************************************************************************************/
async function EMPlugin_updateRemainingTermAfterSave(guid) {	
	//CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
	var updateRemainingTermMap = {};
		if (solution && solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {									
							if (config.relatedProductList && config.relatedProductList.length > 0) {
								config.relatedProductList.forEach((relatedConfig) => {
									if(relatedConfig.guid===guid){
									if (relatedConfig.name.includes('Device')) {
										Object.values(relatedConfig.configuration.attributes).forEach(async (attr) => {
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
												contractTermAtrtribute =Object.values(relatedConfig.configuration.attributes).filter(obj => {
													return obj.name === 'ContractTerm'
												});
												if (attr.name==='ChangeTypeDevice' && attr.value ==='PayOut'){
														console.log('updateremainingTermOnMS    Inside IF');
																updateRemainingTermMap[guid] = [{
																		name: 'RemainingTerm',
																		// value: {
																			value: 0,
																			displayValue: 0
																		// }
																	}];
													//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateRemainingTermMap, true);
													//Spring 20
													let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
													let keys = Object.keys(updateRemainingTermMap);
													for (let i = 0; i < keys.length; i++) {
														await comp.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true); 
													}
													//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,config.guid,true);				
													let cnfg = await component.getConfiguration(config.guid); 
													cnfg.status = true;
												}if(IsDeviceChange && attr.name==='ChangeTypeDevice' && attr.value !=='PayOut' && attr.value !=='New'){
													CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute[0].displayValue, guid,comp.name,'');// EDGE-138108 Aditya Changed Signature, Added Comp Name
												}
											}
										});
									}
									}
								});
							}
						});
					}
				}
			});
		}
	}
	//})
	return Promise.resolve(true);
}
/****************************************************************************************************
 * Author	: Sandip Deshmane
 * Method Name : EMPlugin_checkConfigurationSubscriptionStatus
 * Defect/US # : EDGE-131227
 * Invoked When: Raised MACD on Suspended Subscription
 * Description :Update the Change Type to Active based on Subscription Status
 ************************************************************************************************/
EMPlugin_checkConfigurationSubscriptionStatus = async function() {
	console.log('EMPlugin_checkConfigurationSubscriptionStatus');
	var solutionComponent = false;
	let solution = await CS.SM.getActiveSolution();
	//await CS.SM.getActiveSolution().then((solution) => {
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
			solutionComponent = true;
			await EMPlugin_checkConfigurationSubscriptionsForEM(solution, solutionComponent);
		}
		if (solution.components && Object.values(solution.components).length > 0) {
			//Object.values(solution.components).forEach((comp) => {
			for(const comp of Object.values(solution.components)) {
				solutionComponent = false;
				await EMPlugin_checkConfigurationSubscriptionsForEM(comp, solutionComponent);
			//});
			}
		}
	}
	//});
	return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Rohit Tripathi
 * Method Name : EMPlugin_checkConfigurationSubscriptionsForEM
 * Invoked When: Solution is Loaded
 * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
 * Revision History : Function Signature and code changed to fix EDGE-131227
 ***********************************************************************************************/
async function EMPlugin_checkConfigurationSubscriptionsForEM(comp, solutionComponent) {
	console.log('EMPlugin_checkConfigurationSubscriptionsForEM');
	var componentMap = {};
	//var updateMap = {};
	/*await CS.SM.getActiveSolution().then((solution) => {
		if (solution.type && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			if (solution.components && solution.components.length > 0) {
				solution.components.forEach((comp) => {*/
	console.log('Cmp Map --->', componentMap);
	 var optionValues = [];
        if (comp.name == ENTERPRISE_COMPONENTS.mobileSubscription || comp.name ==ENTERPRISE_COMPONENTS.enterpriseMobility)
            optionValues = [
            "Modify", "Cancel"
        ];
	if (solutionComponent && Object.values(comp.schema.configurations).length > 0 ) {
		var cta = Object.values(Object.values(comp.schema.configurations)[0].attributes).filter(a => {
			return a.name === 'ChangeType' 
		});
		componentMap[comp.name] = [];
		componentMap[comp.name].push({
			'id': Object.values(comp.schema.configurations)[0].replacedConfigId,
			'guid': Object.values(comp.schema.configurations)[0].guid,
			'ChangeTypeValue':cta[0].value,
			'needUpdate':'No'
		});
	} else  if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
			comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
		Object.values(comp.schema.configurations).forEach((config) => {
			if (config.replacedConfigId || config.id) {
				var cta = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType' 
				});
				if (cta && cta.length > 0) {
					if (!componentMap[comp.name])
						componentMap[comp.name] = [];
					if (config.replacedConfigId && (config.id == null || config.id == ''))
						componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid,'ChangeTypeValue':cta[0].value,'needUpdate':'Yes'});
					else if (config.replacedConfigId && (config.id != null || config.id != ''))
					componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid,'ChangeTypeValue':cta[0].value,'needUpdate':'No'});
					else
						componentMap[comp.name].push({'id':config.id, 'guid': config.guid,'ChangeTypeValue':cta[0].value,'needUpdate':'No'});
				}
			}
		});
	}
	// Spring 20
	let currentBasket =  await CS.SM.getActiveBasket(); 
	if (Object.keys(componentMap).length > 0) {
		var parameter = '';
		Object.keys(componentMap).forEach(key => {
			if (parameter) {
				parameter = parameter + ',';
			}
			parameter = parameter + componentMap[key].map(e => e.id).join();
		});
		let inputMap = {};
		inputMap['GetSubscriptionForConfiguration'] = parameter;
		console.log('GetSubscriptionForConfiguration: ', inputMap);
		var statuses;
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
			console.log('GetSubscriptionForConfiguration result:', values);
			if (values['GetSubscriptionForConfiguration'])
				statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
		});
		console.log ('EMPlugin_checkConfigurationSubscriptionsForEM statuses;', statuses);
		if (statuses) {
			var updateMap = [];
			//Object.keys(componentMap).forEach(async comp1 => {
			for(const comp1 of Object.keys(componentMap)) {
				componentMap[comp1].forEach(element => {
					updateMap[element.guid] = [];
					var statusValue = 'New';
					var CustomerFacingId='';
					var CustomerFacingName='';
					//var InitialDate ='';//Added as a part of EDGE-138169 by Aman Soni
					var status = statuses.filter(v => {
						return v.csordtelcoa__Product_Configuration__c === element.id
					});
					if (status && status.length > 0) {
						statusValue = status[0].csord__Status__c;
						CustomerFacingId=status[0].serviceMSISDN__c;
						//InitialDate = status[0].initialActivationDate__c;//Added as a part of EDGE-138169 by Aman Soni
					}
					if((element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') 
						|| ((element.ChangeTypeValue == 'Modify' || element.ChangeTypeValue == 'Cancel') && element.needUpdate == 'Yes')){
							console.log('Inside Change type Update');
						const found = optionValues.find(element => element === statusValue);
						if(found === undefined){
							optionValues.push(statusValue);
						}
						updateMap[element.guid].push({
						name: 'ChangeType',
						// value: {
							value: statusValue,
							//showInUi: true,
							//readOnly:false,
							options: optionValues,
							displayValue: statusValue
						// }
					});
					if(!solutionComponent){
						updateMap[element.guid].push({// Start**EDGE-117256 | Enable search on MSISDN in solution console
						name: 'CustomerFacingServiceId',
						// value: {
							value: CustomerFacingId,
							displayValue: CustomerFacingId
						// }
						},{
							name: 'Substatus',
							// value: {
								value:statusValue,
								displayValue: statusValue,
							// }
						});// End*
					}
					}else {
						if(!solutionComponent){
								updateMap[element.guid].push({// Start**EDGE-117256 | Enable search on MSISDN in solution console
									name: 'CustomerFacingServiceId',
									// value: {
										value: CustomerFacingId,
										displayValue: CustomerFacingId
								// }
							});
						}
						/*,
						{//Added as a part of EDGE-138169 by Aman Soni || Start
							name: 'initialActivationDate',
							value: {
								value: InitialDate,
								displayValue: InitialDate
							}
						}*///Added as a part of EDGE-138169 by Aman Soni || End];
					}
				});
				console.log('EMPlugin_checkConfigurationSubscriptionsForEM update map', updateMap);
				//CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
				//const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true);
				let keys = Object.keys(updateMap);
				//var complock = comp.commercialLock;
				//if(complock) comp.lock('Commercial', false);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
				}
			//});
			}
		}
	}
	return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : EMPlugin_checkConfigurationServiceForEM
 * Invoked When: Solution is Loaded
 * Description : EDGE-132276 Device status update on Device for Macd.
 ***********************************************************************************************/
async function EMPlugin_checkConfigurationServiceForEM() {
	console.log('EMPlugin_checkConfigurationServiceForEM');
	var componentMap = {};
	var updateMap = {};
	let solution = await CS.SM.getActiveSolution();
	let currentBasket =  await CS.SM.getActiveBasket(); 
	//await CS.SM.getActiveSolution().then((solution) => {
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						var cta = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType' 
						});
						//Added as part of EDGE-123594 
						if (!componentMap[comp.name])
							componentMap[comp.name] = [];
						if (config.replacedConfigId){
							componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid,'ChangeTypeValue':cta[0].value,'IsRelated':'No'});
						}
						else{
							componentMap[comp.name].push({'id':config.id, 'guid': config.guid,'ChangeTypeValue':cta[0].value,'IsRelated':'No'});		
						}
						//END as part of EDGE-123594 
						config.relatedProductList.forEach((Relatedconfig) => {
							if (Relatedconfig.configuration.replacedConfigId !=='' && Relatedconfig.configuration.replacedConfigId !== undefined && Relatedconfig.configuration.replacedConfigId !==null) {
								if (cta && cta.length > 0) {
									if (!componentMap[comp.name])
										componentMap[comp.name] = [];
									if (Relatedconfig.replacedConfigId)
										componentMap[comp.name].push(
											{'id':Relatedconfig.configuration.replacedConfigId,
											 'guid': Relatedconfig.configuration.guid,
											 'ChangeTypeValue':cta[0].value,
											 'IsRelated':'Yes'});
									else
										componentMap[comp.name].push({
											'id':Relatedconfig.configuration.replacedConfigId,
											 'guid': Relatedconfig.configuration.guid,
											 'ChangeTypeValue':cta[0].value,
											 'IsRelated':'Yes'});
								}
							}
						});
					});
				}
			});
		}
	}
	//});
	if (Object.keys(componentMap).length > 0) {
		var parameter = '';
		Object.keys(componentMap).forEach(key => {
			if (parameter) {
				parameter = parameter + ',';
			}
			parameter = parameter + componentMap[key].map(e => e.id).join();
		});
		let inputMap = {};
		inputMap['GetServiceForConfiguration'] = parameter;
		console.log('GetServiceForConfiguration: ', inputMap);
		var statuses;
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
			console.log('GetServiceForConfiguration result:', values);
			if (values['GetServiceForConfiguration'])
				statuses = JSON.parse(values['GetServiceForConfiguration']);
		});
		console.log ('EMPlugin_checkConfigurationSubscriptionsForEM statuses;', statuses);
		if (statuses) {
			Object.keys(componentMap).forEach(comp => {
				componentMap[comp].forEach(element => {
					var statusValue = '';
            		//var InitialDate ='';  //Added as part of EDGE-123594, Commented as a part of EDGE-38169 BY Aman Soni
					var status = statuses.filter(v => {
						return v.csordtelcoa__Product_Configuration__c === element.id
					});
					if (status && status.length > 0) {
						statusValue = status[0].csord__Status__c;
            			//InitialDate=status[0].Initial_Activation_Date__c //Added as part of EDGE-123594, Commented as a part of EDGE-38169 BY Aman Soni
					}
					if((element.ChangeTypeValue === 'Modify' ||  element.ChangeTypeValue === 'Cancel' || element.ChangeTypeValue === 'Active') && element.IsRelated ==='Yes'){
							updateMap[element.guid] =[{
							name: 'DeviceStatus',
							// value: {
								value: statusValue,
								displayValue: statusValue
							// }
						}]
					}/*//Added as part of EDGE-123594, Commented as a part of EDGE-138169 By Aman Soni || Start
					else if(element.IsRelated ==='No'){
						updateMap[element.guid] =[{
							name: 'initialActivationDate',
							value: {
								value: InitialDate,
								displayValue: InitialDate
							}
						}]
					}
					//END, Commented as a part of EDGE-138169 By Aman Soni || End*/
				});
				console.log('EMPlugin_checkConfigurationSubscriptionsForEM update map', updateMap);
			});
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
			let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			//const cnfg = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true); 
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
			}
		}
	}
	return Promise.resolve(true);
}
EMPlugin_updateFieldsVisibilityAfterSolutionLoad = function(solution) {
	console.log('inside EMPlugin_updateFieldsVisibilityAfterSolutionLoad >>' + solution.name);
	if (solution.name == ENTERPRISE_COMPONENTS.enterpriseMobility) {
		let BounsAllownceFlag = false;
		isCommittedDataOffer = false;
		console.log('inside EMPlugin_updateFieldsVisibilityAfterSolutionLoad' + solution.changeType);
		Object.values(solution.schema.configurations).forEach((config) => {
			Object.values(config.attributes).forEach((configAttr) => {
				if (configAttr.name === 'OfferType' && configAttr.value.includes('Committed Data')) {
					isCommittedDataOffer = true;
				}if(configAttr.name === 'BonusDataAllowance' && configAttr.value !== ''){
					BounsAllownceFlag=true;
				}
			});
		});
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
			let componentMap =  new Map();
			Object.values(solution.schema.configurations).forEach((config) => {	
				let componentMapattr = {};	
				Object.values(config.attributes).forEach((attr) => {
					if (attr.name === 'OfferType') {
						if (attr.displayValue === 'Data Pool' || attr.displayValue === 'Committed Data') {
							if(BounsAllownceFlag){
								componentMapattr['DataPackPlan'] = [];
								componentMapattr['Data Pack RC'] = [];
								componentMapattr['DataPackAllowanceValue'] = [];
								componentMapattr['BonusDataAllowance'] = [];
								componentMapattr['BonusDataAllowanceValue'] = [];
								componentMapattr['BonusDataPromotionEndDate'] = [];
								componentMapattr['DataPackPlan'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':true});
								componentMapattr['Data Pack RC'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
								componentMapattr['DataPackAllowanceValue'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
								componentMapattr['BonusDataAllowance'].push({'IsreadOnly':true, 'isVisible': false,'isRequired':false});
								componentMapattr['BonusDataAllowanceValue'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
								componentMapattr['BonusDataPromotionEndDate'].push({'IsreadOnly':true, 'isVisible': false,'isRequired':false});
							}else{
								componentMapattr['DataPackPlan'] = [];
								componentMapattr['Data Pack RC'] = [];
								componentMapattr['DataPackAllowanceValue'] = [];
								componentMapattr['BonusDataAllowance'] = [];
								componentMapattr['BonusDataAllowanceValue'] = [];
								componentMapattr['BonusDataPromotionEndDate'] = [];
								componentMapattr['DataPackPlan'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':true});
								componentMapattr['Data Pack RC'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
								componentMapattr['DataPackAllowanceValue'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
								//componentMapattr['TotalRCDataPack'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});								
							}		
						}else{
							componentMapattr['DataPackPlan'] = [];
							componentMapattr['Data Pack RC'] = [];
							componentMapattr['DataPackAllowanceValue'] = [];
							componentMapattr['BonusDataAllowance'] = [];
							componentMapattr['BonusDataAllowanceValue'] = [];
							componentMapattr['BonusDataPromotionEndDate'] = [];
							componentMapattr['DataPackPlan'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							componentMapattr['Data Pack RC'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							componentMapattr['DataPackAllowanceValue'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							componentMapattr['BonusDataAllowance'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							componentMapattr['BonusDataAllowanceValue'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
							componentMapattr['BonusDataPromotionEndDate'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
						}
					}
				});
				componentMap.set(config.guid,componentMapattr);
			});
			CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility,componentMap);
		}
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				let componentMap =  new Map();
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					console.log('EMPlugin_updateFieldsVisibilityAfterSolutionLoad--->81127');
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							let componentMapattr = {};	
							Object.values(config.attributes).forEach((attr) => {
								var CancelCheck = '';
								if (attr.name === 'ChangeType' && attr.Value === 'Cancel') {
									CancelCheck = 'Cancel';
								}
								if (attr.name === 'PlanTypeString' && attr.value !== 'Basic' && isCommittedDataOffer == true) {
									makeMDMFalse = true;
								}
								if (attr.name === 'PlanTypeString' && CancelCheck !== 'Cancel') {
									if (attr.displayValue === 'Data') {
										componentMapattr['InternationalDirectDial'] = [];
										componentMapattr['MessageBank'] = [];
										componentMapattr['MessageBank RC'] = [];
										componentMapattr['IDD Charge'] = [];
										componentMapattr['InternationalDirectDial'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
										componentMapattr['MessageBank'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
										componentMapattr['MessageBank RC'].push({'IsreadOnly':false,'isVisible': false, 'isRequired':false});
										componentMapattr['IDD Charge'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
									}else {
										componentMapattr['InternationalDirectDial'] = [];
										componentMapattr['MessageBank'] = [];
										componentMapattr['MessageBank RC'] = [];
										componentMapattr['IDD Charge'] = [];
										componentMapattr['InternationalDirectDial'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
										componentMapattr['MessageBank'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
										componentMapattr['MessageBank RC'].push({'IsreadOnly':true,'isVisible': true, 'isRequired':false});
										componentMapattr['IDD Charge'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
									}
								}
							});
							if (config.attributes && Object.values(config.attributes).length > 0) {
								console.log('EMPlugin_updateFieldsVisibilityAfterSolutionLoad--->81127');
								var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
								if (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel') {
									componentMapattr['RemainingTerm'] = [];
									componentMapattr['ChangeType'] = [];
									componentMapattr['RemainingTerm'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
									componentMapattr['ChangeType'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':true});
								}
								componentMap.set(config.guid,componentMapattr);
								if (config.id) {
									if (config.relatedProductList && config.relatedProductList.length > 0 && (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel')){
										let componentMapattr = {};
										config.relatedProductList.forEach((relatedConfig) => {		
											if (relatedConfig.name.includes('Device')) {
												// Arinjay ::  Temporary Fix as replacedConfigId is not being populated , CS known issue
												if ((relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !==undefined && relatedConfig.configuration.replacedConfigId !==null) && relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
													// if ((config.replacedConfigId !=='' && config.replacedConfigId !==undefined && config.replacedConfigId !==null) 
													// && relatedConfig.configuration.attributes 
													// && Object.values(relatedConfig.configuration.attributes).length > 0) {
													var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
														return obj.name === 'ChangeType'
													});
													var earlyTerminationChargeAtrtribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
														return obj.name === 'EarlyTerminationCharge'
													});
													var ChangeTypeDeviceAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
														return obj.name === 'ChangeTypeDevice'
													});
													console.log('EMPlugin_updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product');
													console.log('EMPlugin_updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product' + ChangeTypeDeviceAttribute[0].value + earlyTerminationChargeAtrtribute[0].value);
													if(ChangeTypeDeviceAttribute[0].value !== 'New'){
														if ((ChangeTypeDeviceAttribute[0].value === 'None' || ChangeTypeDeviceAttribute[0].value === '' || ChangeTypeDeviceAttribute[0].value === null) && (earlyTerminationChargeAtrtribute[0].value == 0 || earlyTerminationChargeAtrtribute[0].value == '' || earlyTerminationChargeAtrtribute[0].value == null)) {
															console.log('inside iif');	
															componentMapattr['RemainingTerm'] = [];
																componentMapattr['EarlyTerminationCharge'] = [];
																componentMapattr['ChangeTypeDevice'] = [];
																componentMapattr['TotalFundAvailable'] = [];	
																componentMapattr['RedeemFund'] = [];	
																componentMapattr['OneOffChargeGST'] = [];
																componentMapattr['RemainingTerm'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
																componentMapattr['EarlyTerminationCharge'].push({'IsreadOnly':true, 'isVisible': false,'isRequired':false});
																componentMapattr['ChangeTypeDevice'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
																//added by Romil															
															componentMapattr['TotalFundAvailable'].push({'IsreadOnly':false,'isVisible': false });	
																componentMapattr['RedeemFund'].push({'IsreadOnly':false,'isVisible': false});	
																componentMapattr['OneOffChargeGST'].push({'IsreadOnly':false,'isVisible': false});
														} else if(changeTypeAtrtribute[0].value === 'Cancel') {
															console.log('inside iif');	
																componentMapattr['RemainingTerm'] = [];
																componentMapattr['EarlyTerminationCharge'] = [];
																componentMapattr['ChangeTypeDevice'] = [];
																componentMapattr['RemainingTerm'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
																componentMapattr['EarlyTerminationCharge'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
																componentMapattr['ChangeTypeDevice'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
														}else {
															console.log('inside else');	
															componentMapattr['RemainingTerm'] = [];
																componentMapattr['EarlyTerminationCharge'] = [];
																componentMapattr['ChangeTypeDevice'] = [];
																componentMapattr['TotalFundAvailable'] = [];	
																componentMapattr['RedeemFund'] = [];	
																componentMapattr['OneOffChargeGST'] = [];
																componentMapattr['RemainingTerm'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
																componentMapattr['EarlyTerminationCharge'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
																componentMapattr['ChangeTypeDevice'].push({'IsreadOnly':false, 'isVisible': true,'isRequired':false});
																//added by Romil
																componentMapattr['TotalFundAvailable'].push({'IsreadOnly':false,'isVisible': true });	
																componentMapattr['RedeemFund'].push({'IsreadOnly':false,'isVisible': true});	
																componentMapattr['OneOffChargeGST'].push({'IsreadOnly':false,'isVisible': true});
														}
													} // Arinjay 176103
													else if((relatedConfig.configuration.replacedConfigId == undefined || relatedConfig.configuration.replacedConfigId == null || relatedConfig.configuration.replacedConfigId == '' )
															) {
														componentMapattr['ChangeTypeDevice'] = [];
														componentMapattr['ChangeTypeDevice'].push({'IsreadOnly':false, 'isVisible': false,'isRequired':false});
													}
													componentMap.set(relatedConfig.guid,componentMapattr);
												}
											}
										});
									}
								}
							}
							//}
						});
					}
				}
				CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.mobileSubscription,componentMap);
			});
		}
	}
}
EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts = async function(componentName, relatedProductList, relatedConfigName, isReadOnly, attributeList) {
	console.log('EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts ', relatedProductList, relatedConfigName, isReadOnly, attributeList);
	if (relatedProductList && relatedProductList.length > 0) {
		let updateMap = {};
		let doUpdate = false;
		relatedProductList.forEach((relatedConfig) => {
			if (relatedConfig.name === relatedConfigName && relatedConfig.type === 'Related Component' && relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !==undefined && relatedConfig.configuration.replacedConfigId !==null) {
				var ChangeTypeDeviceattribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
					return obj.name === 'ChangeTypeDevice'
				});
				console.log('ChangeTypeDeviceattribute print--ash----->'+ChangeTypeDeviceattribute[0].value);
				if(ChangeTypeDeviceattribute[0].value !=='New'){
					Object.values(relatedConfig.configuration.attributes).forEach((attribute) => {
						if (attribute.showInUi && attributeList.includes(attribute.name)) {
							console.log('attribute print--ash----->'+attribute.name+attribute.value+attribute.displayValue+'---'+updateMap);
							doUpdate = true;
							if (!updateMap[relatedConfig.guid])
								updateMap[relatedConfig.guid] = [];
							var readonlyValue = isReadOnly;
							updateMap[relatedConfig.guid].push({
								name: attribute.name,
								// value: {
									readOnly: readonlyValue
								// }
							});
						}
					});
				}
			}
		});
		if (doUpdate === true) {
			console.log('EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts - updating: ', updateMap);
			// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, false).then(()=> Promise.resolve(true)).catch((e)=> Promise.resolve(true));
			// Spring 20
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
			}
		}
	}
}
async function EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave() {
	console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		var updateMap = {};
		if (solution.components && Object.values(solution.components).length > 0) {
			var setChangeType = '';
			var updateMapDevice = {};
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					updateMap = [];
					console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4817');
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							var valid = true;
							errorMessage = '';
							if (config.id) {
								if (config.attributes && Object.values(config.attributes).length > 0) {
									var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'ChangeType'
									});
									console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4824' + changeTypeAtrtribute[0].value + IsMACBasket);
									if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
										var visibleEtc = false;
										if (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel' || changeTypeAtrtribute[0].value === 'Active') {
											updateMapDevice[config.guid] = [{
												name: 'ChangeType',
												// value: {
													showInUi: true
												// }
											}];
										}
										if (changeTypeAtrtribute[0].value === 'Modify') {
											console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4827');
											if (config.relatedProductList && config.relatedProductList.length > 0) {
												config.relatedProductList.forEach((relatedConfig) => {
													if (relatedConfig.name.includes('Device')) {
														if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !==null) {
															console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4835');
															/*var cancelFlagAttribute = relatedConfig.configuration.attributes.filter(obj => {
																return obj.name === 'CancelFlag'
															});*/
															var ChangeTypeDeviceAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
																return obj.name === 'ChangeTypeDevice'
															});
															if (/*cancelFlagAttribute && cancelFlagAttribute.length > 0 &&*/ ChangeTypeDeviceAttribute && ChangeTypeDeviceAttribute.length > 0 && ChangeTypeDeviceAttribute[0].value!=='New') {
																var EarlyTerminationChargesAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
																	return obj.name === 'EarlyTerminationCharge'
																});
																if (EarlyTerminationChargesAttribute && EarlyTerminationChargesAttribute.length > 0 && EarlyTerminationChargesAttribute[0].value ==='') {
																	console.log('EarlyTerminationChargesAttribute')
																	updateMapDevice[relatedConfig.guid] = [];
																	updateMapDevice[relatedConfig.guid].push({
																		name: 'EarlyTerminationCharge',
																		// value: {
																			showInUi: false,
																			readOnly: true
																		// }
																	});
																	updateMapDevice[relatedConfig.guid].push({	
																			name: 'OneOffChargeGST',	
																			// value: {	
																				showInUi: false	
																			// }	
																		});	
																		updateMapDevice[relatedConfig.guid].push({	
																			name: 'RedeemFund',	
																			// value: {	
																				showInUi: false	
																			// }	
																		});	
																		updateMapDevice[relatedConfig.guid].push({	
																			name: 'TotalFundAvailable',	
																			// value: {	
																				showInUi: false	
																			// }	
																		});
																	updateMapDevice[relatedConfig.guid].push({
																		name: 'ChangeTypeDevice',
																		// value: {
																			showInUi: true,
																			readOnly: false
																		// }
																	});
																}
															}
														}
													}
												});
											}
										}
									}
								}
							}
						});
					}
				}
			});
			console.log('updateCancelFlagVisibility - updating: ', updateMapDevice);
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
			let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			var complock = component.commercialLock;
			//if(complock) component.lock('Commercial', false);
			let keys = Object.keys(updateMapDevice);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true); 
			}
		}
	}
	// }).then(
	// 	() => Promise.resolve(true)
	// );
	return Promise.resolve(true);
}
async function EMPlugin_checkCancelFlagAndETCForNonBYOPlans(guid) {
	console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlans');
	//CS.SM.getActiveSolution().then((solution) => {
	//Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		var updateMap = {};
		if (solution.components && Object.values(solution.components).length > 0) {
			var isCancelFlagTrue = false;
			var updateMapDevice = {};
			//Ritika:Start:EDGE - 81135
			var contractTerm;
			var unitPriceRC;
			var prodConfigID;
			var deviceConfigID;
			var charges;//Ritika:End:EDGE - 81135
			Object.values(solution.components).forEach((comp) => { 
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					updateMap = [];
				console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlans--->4817');
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						if (config.id ) {
							if (config.attributes && Object.values(config.attributes).length > 0 ) {
								var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
								console.log('EMPlugin_checkCancelFlagAndETCForNonBYOPlans--->4824'+changeTypeAtrtribute[0].value);
								if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
									if (changeTypeAtrtribute[0].value === 'Modify') {
										prodConfigID = config.id;
										if (config.relatedProductList && config.relatedProductList.length > 0) {
											config.relatedProductList.forEach(async (relatedConfig) => {
												if (relatedConfig.name.includes('Device') && relatedConfig.guid==guid){	
													if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){	
														var ChangeTypeDeviceAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name ==='ChangeTypeDevice' 
														});
														if (ChangeTypeDeviceAttribute && ChangeTypeDeviceAttribute.length > 0){
															var EarlyTerminationChargesAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
																return obj.name === 'EarlyTerminationCharge'
															});
															var SelectPlanNameAtrtribute = Object.values(config.attributes).filter(obj => {
																return obj.name === 'SelectPlanName'
															});
															if(EarlyTerminationChargesAttribute && EarlyTerminationChargesAttribute.length > 0) {
															if(ChangeTypeDeviceAttribute[0].value === 'PayOut'){
																EMPlugin_calculateTotalETCValue( relatedConfig.guid);	
																//EDGE - 81135 : ETC calculation for Modify -cancelDevice
															}
															else 
															{
																var ETCValue = 0;
																allowSaveEM = false;
																if(/*config.name.includes('BYO')*/SelectPlanNameAtrtribute[0].value.includes('BYO')){
																	//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,config.guid,false,'Cannot change the plan to BYO while the associated device is In-Contract');
																	let cnfg = await comp.getConfiguration(config.guid); 
																	cnfg.status = false;
																	cnfg.statusMessage = 'Cannot change the plan to BYO while the associated device is In-Contract';
																}
																updateMapDevice[relatedConfig.guid] = [];
																updateMapDevice[relatedConfig.guid].push({
																name: 'EarlyTerminationCharge',
																	// value: {
																		showInUi: false,
																		readOnly: true,	
																		value: ETCValue,
																		displayValue: ETCValue
																	// }
																});
																//added by Romil
																updateMapDevice[relatedConfig.guid].push({	
																	name: 'TotalFundAvailable',	
																	// value: {	
																		showInUi: false	
																			// }	
																		});	
																updateMapDevice[relatedConfig.guid].push({	
																	name: 'RedeemFund',	
																	// value: {	
																		showInUi: false,
																		value:0
																			// }	
																		});	
																updateMapDevice[relatedConfig.guid].push({	
																	name: 'OneOffChargeGST',	
																	// value: {	
																		showInUi: false,	
																			// }	
																		});
																console.log('updateCancelFlagVisibility - updating: ', updateMapDevice);
																//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
																let keys = Object.keys(updateMapDevice);
																for (let i = 0; i < keys.length; i++) {
																	await comp.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true); 
																}
															}
														}
													}
												}
											}
											});
										}
									}
								}
							}
						}
					});
				}
			}
			});
		}
	}
	// }).then(
	// () => Promise.resolve(true)
	// );
	return Promise.resolve(true);
}
/************************************************************************************
 * Author	: Ritika Jaiswal
 * Method Name : EMPlugin_check_cancellationOfAllCMPs
 * Defect/US # : EDGE-81135
 * Invoked When: Mobile Subscription is being cancelled
 * Description : To check if customer is cancelling all subscriptions
 * Parameters : Solution
 ***********************************************************************************/
async function EMPlugin_check_cancellationOfAllCMPs(){
	var countCancel_CMP = 0;
	console.log('EMPlugin_check_cancellationOfAllCMPs :: checking if customer is cancelling all CMPs')
	//CS.SM.getActiveSolution().then((solution)=>{
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution.components && Object.values(solution.components).length > 0) {
		Object.values(solution.components).forEach((comp) => {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {            	
				Object.values(comp.schema.configurations).forEach((subscriptionConfig) => {
					if (subscriptionConfig.attributes && Object.values(subscriptionConfig.attributes).length > 0) {	
						Object.values(subscriptionConfig.attributes).forEach((ChangeTypeAttribute) => {
							if(ChangeTypeAttribute.name==='ChangeType' && ChangeTypeAttribute.value==='Cancel'){
								countCancel_CMP++;
							}
						});
					}
				});
				console.log('alert for full CMP',comp.schema.configurations.length,countCancel_CMP);
				if(countCancel_CMP === comp.schema.configurations.length)
					CS.SM.displayMessage('Cancelling these subscription(s) will result in the cancellation of entire CMP offer.', 'info');					
			}
		});
	}
	console.log('Counting cancellations:',countCancel_CMP);
	//});
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : calculate
 * Description : Showing error after save 
 * Invoked When: Validate and save button
**************************************************************************************/
EMPlugin_updateStatusAfterSolutionLoad = async function() {
	console.log('EMPlugin_updateStatusAfterSolutionLoad');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			var setChangeType = '';
			var updateMapDevice = {};
			isCommittedDataOffer = false;
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.schema.configurations).forEach((config) => {			
					Object.values(config.attributes).forEach((configAttr) => {
						if (configAttr.name === 'OfferType' && configAttr.displayValue==='Committed Data') {
							console.log ('Inside  Updating CommittedDataOffer ');
							isCommittedDataOffer = true;
						}
					});
				});
				let updateConfigMapsubs = {};
				let updateConfigMapsubs1 = {};
				Object.values(solution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							let isRelatedDeviceAdded = false;
							let isRelatedDevicePayout = false;
							Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
								updateConfigMapsubs[subsConfig.guid]=[];
								updateConfigMapsubs1[subsConfig.guid]=[];
								let OfferTypeAttribute = Object.values(subsConfig.attributes).filter(obj => {
									return obj.name === 'OfferTypeString' 
								});
								let SelectPlanNameAttribute = Object.values(subsConfig.attributes).filter(obj => {
									return obj.name === 'SelectPlanName' 
								});
								let changeTypeDisplayValue = '';
								let selectPlanDisplayValue = '';
								isRelatedDeviceAdded = false;
								isRelatedDevicePayout=false;
								Object.values(subsConfig.attributes).forEach((attr) => {
									if(attr.name === 'ChangeType' && attr.value !== 'Active'){
										changeTypeDisplayValue=attr.displayValue ;
									}
									if (attr.name === 'Select Plan' && attr.value !== '') {
										selectPlanDisplayValue =attr.displayValue ;
									}
									if(attr.name === 'Select Plan' && attr.value !== '' && changeTypeDisplayValue !== 'Active'){
										if (attr.displayValue === 'Local' || attr.displayValue === 'Local BYO' || attr.displayValue === 'Basic' ||  attr.displayValue ==='Entry'||  attr.displayValue ==='Standard') {
											updateConfigMapsubs1[subsConfig.guid].push({
												name: 'InternationalDirectDial',
												readOnly: false,
											});
										}else{
											updateConfigMapsubs1[subsConfig.guid].push({
												name: 'InternationalDirectDial',
												readOnly: true,
											});
										} 
									}if(attr.name === 'Substatus' && attr.value === 'Suspended'){
										updateConfigMapsubs1[subsConfig.guid].push({
											name: 'ChangeType',
											options : ["Cancel"]
										});
									}if(attr.name === 'CustomerFacingServiceId' ){
										if(attr.value !== ''){
											updateConfigMapsubs[subsConfig.guid]=[{
												name: 'ConfigName',
												value: OfferTypeAttribute[0].value+'-'+SelectPlanNameAttribute[0].value+'-'+attr.value,
												displayValue: OfferTypeAttribute[0].value+'-'+SelectPlanNameAttribute[0].value+'-'+attr.value
											}];
											subsConfig.configurationName=OfferTypeAttribute[0].value+'-'+SelectPlanNameAttribute[0].value+'-'+attr.value;
										}else{
											updateConfigMapsubs[subsConfig.guid]=[{
												name: 'ConfigName',
												value: OfferTypeAttribute[0].value +'-'+ SelectPlanNameAttribute[0].value,
												displayValue: OfferTypeAttribute[0].value +'-'+ SelectPlanNameAttribute[0].value
											}];
										}
									}
								});
								if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
									subsConfig.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === 'Related Component') {
											isRelatedDeviceAdded = true;
										}
										console.log('isRelatedDeviceAdded:::::'+isRelatedDeviceAdded);
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
											Object.values(relatedConfig.configuration.attributes).forEach((ChangeTypeAttribute) => {
												if(ChangeTypeAttribute.name==='ChangeTypeDevice' && ChangeTypeAttribute.value==='PayOut'){
													isRelatedDevicePayout=true;
												}
											});
										}
									});
								}
								if (!selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === false && isCommittedDataOffer === false){
									console.log('Inside selectPlanDisplayValue Validation  ');
									//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please add One mobile Device.');
									let config = await comp.getConfiguration(subsConfig.guid); 
									config.status = false;
									config.statusMessage = 'Please add One mobile Device.';
								}else if (selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false){
									console.log('Inside selectPlanDisplayValue Validation  ');
									//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.');
									let config = await comp.getConfiguration(subsConfig.guid); 
									config.status = false;
									config.statusMessage = 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.';
								}
								//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMapsubs, true);
							});
						}
					}
				});
				console.log('updateConfigMapsubs::::',updateConfigMapsubs);
				let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
				//const config = await component.updateConfigurationAttribute(component.configuration.guid, updateConfigMapsubs, true); 
				var complock = component.commercialLock;
				if(complock) component.lock('Commercial', false);
				let keys = Object.keys(updateConfigMapsubs);
				var complock = component.commercialLock;
				//if (complock) component.lock('Commercial', false);
				for (let i = 0; i < keys.length; i++) {

					await component.updateConfigurationAttribute(keys[i], updateConfigMapsubs[keys[i]], true); 
				}

				if(complock) component.lock('Commercial', true);
				//const config = await component.updateConfigurationAttribute(component.configuration.guid, updateConfigMapsubs1, true); 
				let keys1 = Object.keys(updateConfigMapsubs1);
				var complock = component.commercialLock;
				if(complock) component.lock('Commercial', false);
				for (let i = 0; i < keys1.length; i++) {
					await component.updateConfigurationAttribute(keys1[i], updateConfigMapsubs1[keys1[i]], true); 
				}
				if(complock) component.lock('Commercial', true);
				// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMapsubs, true);
				// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMapsubs1, true);
			}
		}
	}
	//});
}
/************************************************************************************
 * Author	: Ankit Goswami
 * Method Name : EMPlugin_updateCancelDeviceTypeAfterSolutionLoad
 * Invoked When: Change Device Type is updated as Modisy
 * Description : Set value of Change Type
 * Parameters : guid
 ***********************************************************************************/		
async function EMPlugin_updateCancelDeviceTypeAfterSolutionLoad(guid) {
	//CS.SM.getActiveSolution().then((solution) => {
	//Spring 20
	console.log('EMPlugin_updateCancelDeviceTypeAfterSolutionLoad');
	let solution = await CS.SM.getActiveSolution();
	var updateMapDevice = {};
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {			
		for(const comp of Object.values(solution.components)) {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
				console.log('EMPlugin_updateCancelDeviceTypeAfterSolutionLoad::::::');
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {			
					for(const config of Object.values(comp.schema.configurations)) {
					if(config.guid===guid){
						var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
								return obj.name === 'ChangeType'
						});
						if (config.attributes && Object.values(config.attributes).length > 0) {	
							if (config.relatedProductList && config.relatedProductList.length > 0){
								if(changeTypeAtrtribute[0].value !== '' && changeTypeAtrtribute[0].value !== 'Active' && changeTypeAtrtribute[0].value !== 'New') {
									for(const relatedConfig of config.relatedProductList) {
										if(relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !==null){
											//if(relatedConfig.guid===guid){
											updateMapDevice[relatedConfig.guid] = [];
											var RemainingTermAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
													return obj.name === 'RemainingTerm'
												});
											var DeviceStatusAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'DeviceStatus'
											});
											var ChangeTypeDeviceAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'ChangeTypeDevice'
											});
											var contractTermAtrtribute =Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'ContractTerm'
											});
											console.log('ChangeTypeDeviceAttr[0].value'+ChangeTypeDeviceAttr[0].value);
											if (relatedConfig.name.includes('Device') && ChangeTypeDeviceAttr[0].value !=='New') {
												if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && changeTypeAtrtribute[0].value === 'Cancel' && RemainingTermAttr[0].value> 0 ) {
													console.log('inside this')
													updateMapDevice[relatedConfig.guid].push(
													{
													name: 'ChangeTypeDevice',
													// value: {
														value: 'PayOut',
														readOnly: true,
														showInUi: true
													// }
													});
													updateMapDevice[relatedConfig.guid].push(
													{
													name: 'RemainingTerm',
													// value: {
														value: 0,
														displayValue:0						
													// }
													});
													//added by Romil	
														updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'RedeemFund',	
														// value: {	
															showInUi:false						
														// }	
														});	
														updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'TotalFundAvailable',	
														// value: {	
															showInUi:false								
														// }	
														});	
														updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'OneOffChargeGST',	
														// value: {	
															showInUi:false								
														// }	
														});
												}else if(DeviceStatusAttr[0].value !=='PaidOut' && ChangeTypeDeviceAttr[0].value==='PayOut' && changeTypeAtrtribute[0].value === 'Modify' && IsMACBasket){
													IsMACBasket=false;
													console.log('IsMACBasket>'+IsMACBasket)
													updateMapDevice[relatedConfig.guid].push(
														{
														name: 'ChangeTypeDevice',
														// value: {
															value: 'None',
															readOnly: false,
															showInUi: true
														// }
													});	
													//added by Romil
													updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'RedeemFund',	
														// value: {	
															readOnly: false,	
															showInUi:true						
														// }	
													});	
													updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'TotalFundAvailable',	
														// value: {	
															readOnly: false,	
															showInUi:true	
														// }	
													});	
													updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'OneOffChargeGST',	
														// value: {	
															readOnly: false,	
															showInUi:true								
														// }	
													});
													CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute[0].displayValue, relatedConfig.guid,comp.name,'');// EDGE-138108 Aditya Changed Signature, Added Comp Name
												}else{
													console.log('IsMACBasket111>'+IsMACBasket)
													updateMapDevice[relatedConfig.guid].push(
													{
													name: 'ChangeTypeDevice',
													// value: {
														value:'None',
														//readOnly: true,
														showInUi: true
													// }
													});
													//added by Romil
													updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'RedeemFund',	
														// value: {	
															readOnly: false,	
															showInUi:false						
														// }	
														});	
														updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'TotalFundAvailable',	
														// value: {	
															readOnly: false,	
															showInUi:false	
														// }	
														});	
														updateMapDevice[relatedConfig.guid].push(	
														{	
														name: 'OneOffChargeGST',	
														// value: {	
															readOnly: false,	
															showInUi:false								
														// }	
														});
												}
												console.log('updateCancelFlagVisibility Attribute Update11111111111'+updateMapDevice);
												//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
												//Spring 20
												let keys = Object.keys(updateMapDevice);
												for (let i = 0; i < keys.length; i++) {
													await comp.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true); 
												}
											}
										//}
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
	//});	
}
EMPlugin_getSelectedPlanForMobileSubscription = async function (guid) {
	console.log('inside EMPlugin_getSelectedPlanForMobileSubscription')
	let selectPlanDisplayValue = '';
	//await CS.SM.getActiveSolution().then((product) => {
	let product = await CS.SM.getActiveSolution();
	if (product && /*product.type &&*/ product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (product.components && Object.values(product.components).length > 0) {
			let comp = Object.values(product.components).filter(c => {return c.name===ENTERPRISE_COMPONENTS.mobileSubscription});
			if (comp && comp.length> 0 &&  comp[0].schema && comp[0].schema.configurations && Object.values(comp[0].schema.configurations).length > 0) {
				let config = Object.values(comp[0].schema.configurations).filter(c => c.guid === guid);
				if (config && config.length > 0) {
					let att = Object.values(config[0].attributes).filter(a => {return a.name === 'Select Plan'});
					if (att && att.length)
						selectPlanDisplayValue = att[0].displayValue;
				}
			}
		}
	}
	//});
	return selectPlanDisplayValue;
}
EMPlugin_updateChangeTypeAttribute = async function (fromAddToMacBasket = false) {
	console.log('EMPlugin_updateChangeTypeAttribute');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach(async (comp) => {
				var updateMap = [];
				var doUpdate = false;
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						if (config.attributes && Object.values(config.attributes).length > 0) {
							Object.values(config.attributes).forEach((attribute) => {
								if (attribute.name === 'ChangeType') {
									doUpdate = true;
									var changeTypeValue = attribute.value;
									if (!updateMap[config.guid])
										updateMap[config.guid] = [];
									//console.log('window.BasketChange === 'Change Solution': ', window.BasketChange === 'Change Solution');
									if (!window.BasketChange === 'Change Solution' || (config.replacedConfigId ==='' || config.replacedConfigId ===undefined ||config.replacedConfigId ===null)) {
										console.log('Non MACD basket');
										if (!changeTypeValue) {
											changeTypeValue = 'New';
										}
										updateMap[config.guid].push({
											name: attribute.name,
											// value: {
												value: changeTypeValue,
												displayValue: changeTypeValue,
												showInUi: false,
												readOnly: true
											// }
										});
									} else {
										console.log('MACD basket');
										if(changeTypeValue === 'Active'){
											EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription,config.guid, true, ENTERPRISE_COMPONENTS.mobileSubscriptionEditableAttributeList);	
										}
										var readonly = false;
										if (config.id && changeTypeValue === 'Cancel')
											readonly = true;
										var showInUI = true;
										if(!fromAddToMacBasket && (config.id && changeTypeValue === 'New'))
											showInUI = false;
										updateMap[config.guid].push({
											name: attribute.name,
											// value: {
												showInUi: showInUI,
												readOnly: false
											// }
										});
									}
								}
							});
						}
					});
				}
				if (doUpdate) {
					console.log('EMPlugin_updateChangeTypeAttribute', updateMap);
					//CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
					//const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 
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
	// }).then(
	// 	() => Promise.resolve(true)
	// );
}
/************************************************************************************
 * Author	: ankit G
 * Method Name : showCommitedDataNotification
 * Defect/US # : EDGE-112367
 * Invoked When: Mobile Subscription configuration is added to the Mobile Subscription component
 * Description : Show Toast message aboutX or XXL data SIM plan
 * Parameters : N/A
 ***********************************************************************************/
function EMPlugin_showDataSimnotification(){
	if(!datashow){
		CS.SM.displayMessage('Large Data SIM plans provide non-shareable data and do not share the data allowance chosen through committed data pack', 'info');
	//datashow = true;
	}
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : calculate
 * Description : Calculated Device from all related produ
 * Invoked When: Device is updated,
**************************************************************************************/
EMPlugin_updateDeviceEnrollmentAfterSolutionLoad = async function() {
	console.log('EMPlugin_updateDeviceEnrollmentAfterSolutionLoad');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		var updateMap = {};
		if (solution.components && Object.values(solution.components).length > 0) {
			var updateMapDevice = {};
			let count= 1;//EDGE-140536 added by ankit
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && Object.values(comp.schema.configurations) && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((config) => {
							var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
								return obj.name === 'ChangeType'
							});
							if (config.relatedProductList && config.relatedProductList.length > 0) {
								//EDGE-140536 added by ankit || start
								if(config.relatedProductList.length > 1){
									count=2;
								}
								//EDGE-140536 added by ankit || End
								config.relatedProductList.forEach((relatedConfig) => {
									if (relatedConfig.name.includes('Device')) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 ){
											var ReletedConfig=relatedConfig.configuration.replacedConfigId;
											var ReletedConfigName=relatedConfig.configuration.name;
											var ChangeTypeDeviceAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'ChangeTypeDevice'
											});
											var DeviceStatusAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'DeviceStatus'
											});
											var ReplaceConfigAttr = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'ReplaceConfig'
											});
											Object.values(relatedConfig.configuration.attributes).forEach((relatedConfigattr) => {
												//updateMap[relatedConfig.guid]=[];
												if(relatedConfig.configuration.replacedConfigId ==='' || relatedConfig.configuration.replacedConfigId ===null){
													if(relatedConfigattr.name==='InContractDeviceEnrollEligibility'){
														if(relatedConfigattr.value==='Eligible'){
															console.log('inside if:::');
															updateMap[relatedConfig.guid]=[{
																name: 'DeviceEnrollment',
																	// value: {
																		showInUi: true,
																		readOnly:false,
																		required:true,
																		options: ["ENROL",
																		"DO NOT ENROL"
																		]
																	// }
																},{
																name: 'DeviceStatus',
																// value: {
																	showInUi: false,
																	readOnly:true,
																	value:'',
																	displayValue:''
																// }
															}];
															console.log('update check: ', updateMap);	
														}else{
															console.log('inside if else:::');
															updateMap[relatedConfig.guid]=[{
																name: 'DeviceEnrollment',
																	// value: {
																		value:"NOT ELIGIBLE",
																		displayValue: "NOT ELIGIBLE",
																		showInUi: true,
																		readOnly:true,
																		options: ["NOT ELIGIBLE"]
																	// }
															},{
																name: 'DeviceStatus',
																// value: {
																	showInUi: false,
																	readOnly:true,
																	value:'',
																	displayValue:''
																// }
															}];
														}
													}
												}else{
													console.log('insifrelse');
													if(ReletedConfig !=='' && ReletedConfig !==null && ReletedConfig !==undefined){
														if(DeviceStatusAttr[0].value ==='Connected' || DeviceStatusAttr[0].value ==='ACTIVE MRO'){
															//console.log('insifr ACTIVE MRO');
															updateMap[relatedConfig.guid]=[{
																name: 'DeviceStatus',
																	// value: {
																		value:'ACTIVE MRO',
																		displayValue:'ACTIVE MRO',
																		showInUi: true,
																		readOnly:true
																	// }
																},{
																	name: 'DeviceEnrollment',
																	// value: {
																		showInUi: false,
																		readOnly:true,	
																	// }
															}];
														}else if(DeviceStatusAttr[0].value ==='PaidOut'){
															updateMap[relatedConfig.guid]=[{
																name: 'DeviceStatus',
																	// value: {
																		value:'PaidOut',
																		displayValue:'PaidOut',
																		showInUi: true,
																		readOnly:true
																	// }
																},{
																	name: 'DeviceEnrollment',
																	// value: {
																		showInUi: false,
																		readOnly:true,	
																	// }
															}];
															//EDGE-140536 added by ankit || start
															if(count < 2){
																EMPlugin_setPlanDiscount(relatedConfig.guid,ENTERPRISE_COMPONENTS.mobileSubscription);
															}
															//EDGE-140536 added by ankit || End
														}
													}
												}	
											});
										}
									}
								});
							}
						});
					}
				}
			});
			console.log('updateCancelFlagVisibility - updating: ', updateMap);
			//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
			let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
			//const cnfg = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true); 
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
			}
		}
	}
	// }).then(
	// () => Promise.resolve(true)
	// );
}
/*******************************************************************************
* Author      : Mahaboob Basha
* Method Name : EMPlugin_addDefaultEMOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. Adds one oe config for each comonent config if there is none
* Parameters  : none
******************************************************************************/
async function EMPlugin_addDefaultEMOEConfigs(){
	if (basketStage !== 'Contract Accepted')
		return;
	console.log('EMPlugin_addDefaultEMOEConfigs');
	var oeMap = [];
	isCommittedDataOffer = false;
	//await CS.SM.getActiveSolution().then((currentSolution) => {
		let currentSolution = await CS.SM.getActiveSolution();
		if (/*currentSolution.type &&*/  currentSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			Object.values(currentSolution.schema.configurations).forEach((config) => {
			   Object.values(config.attributes).forEach((configAttr) => {
					if (configAttr.name === 'OfferType' && configAttr.value.includes('Committed Data')) {
						isCommittedDataOffer = true;
					}
				});
		  	});
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				Object.values(currentSolution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
						Object.values(comp.schema.configurations).forEach((config) => {
						   var cancelconfig = Object.values(config.attributes).filter((attr => {
							   return attr.name === 'ChangeType'
						   }));
							 //Added by Ankit as part of Bulk OE story - EDGE-137466 || start
						   var isDeliveryEnrichmentNeededAtt = Object.values(config.attributes).filter((attr => {
							   return attr.name === 'isDeliveryEnrichmentNeededAtt'
						   }));
						   var isCRDEnrichmentNeededAtt = Object.values(config.attributes).filter((attr => {
							   return attr.name === 'isCRDEnrichmentNeededAtt'
						   }));
						   //Added by Laxmi for - EDGE-142321 
						   var shippingRequired = Object.values(config.attributes).filter((attr => {
							   return attr.name === 'ShippingRequired'
						   }));
							//Added by Ankit as part of Bulk OE story - EDGE-137466 || END
						  	//if(cancelconfig && cancelconfig.length >0 && cancelconfig[0].value !== 'Cancel' && (isDeliveryEnrichmentNeededAtt[0].value ===true || isDeliveryEnrichmentNeededAtt[0].value==='true' || isCRDEnrichmentNeededAtt[0].value ===true || isCRDEnrichmentNeededAtt[0].value==='true')){// Added condition for EDGE-137466 bulk enrichment by ankit
					   		if(cancelconfig && cancelconfig.length >0 && cancelconfig[0].value !== 'Cancel'){// Added condition for EDGE-137466 bulk enrichment by ankit// laxmi - removed few conditions original check above 
								Object.values(comp.orderEnrichments).forEach((oeSchema) => {
									if (!oeSchema.name.toLowerCase().includes('numbermanagementv1')) {
										var found = false;
										if (config.orderEnrichmentList) {
											var oeConfig = config.orderEnrichmentList.filter(oe => {return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId )});
											if (oeConfig && oeConfig.length > 0)
												found = true;
										}
										if (!found) {
											var el = {};
											el.componentName = comp.name;
											el.configGuid = config.guid;
											el.oeSchemaId = oeSchema.id;
											el.oeSchema = oeSchema;
											oeMap.push(el);
											//console.log('Adding default oe config for:',comp.name,config.name, oeSchema.name );
										}
									}
								});
						   	}
						});
					}
				});
			}
		}
	//}).then(() => Promise.resolve(true));
	// if (oeMap.length> 0) {
	// 	var map = [];
	// 	map.push({});
	//    // console.log('Adding default oe config map:',oeMap);
	// 	for (var i=0; i< oeMap.length;i++) {
	// 		await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
	// 	};
	// }
	// Arinjay
    if (oeMap.length > 0) {
        let map = [];
        console.log('Adding default oe config map--:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            console.log(' Component name ----' + oeMap[i].componentName);
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        };
	}
	await EMPlugin_initializeEMOEConfigs();
    return Promise.resolve(true);
}
/**********************************************************************************************
* Author	  : Mahaboob Basha
* Method Name : EMPlugin_initializeEMOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. sets basket id to oe configs so it is available immediately after opening oe
* Parameters  : none
**********************************************************************************************/
async function EMPlugin_initializeEMOEConfigs(oeguid){
	console.log('EMPlugin_initializeEMOEConfigs');
	let currentSolution =  await CS.SM.getActiveSolution();
	// await CS.SM.getActiveSolution().then((solution) => {
	// 	currentSolution = solution;
	//    // console.log('EMPlugin_initializeEMOEConfigs - getActiveSolution');
	// }).then(() => Promise.resolve(true));
	if (currentSolution) {
	    // console.log('EMPlugin_initializeEMOEConfigs - updating');
		if (/*currentSolution.type &&*/ currentSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
				for (let i=0; i<Object.values(currentSolution.components).length; i++) {
					let comp = Object.values(currentSolution.components)[i];
					for (let j=0; j<Object.values(comp.schema.configurations).length; j++) {
						var config = Object.values(comp.schema.configurations)[j];
						var updateMap = {};
						if (config.orderEnrichmentList) {
							for (let k = 0; k < config.orderEnrichmentList.length; k++) {
								var oe = config.orderEnrichmentList[k];
								if (oeguid && oeguid !== oe.guid)
									continue;
								var basketAttribute = Object.values(oe.attributes).filter(a => {
									return a.name.toLowerCase() === 'basketid'
								});
								if (basketAttribute && basketAttribute.length > 0) {
									if (!updateMap[oe.guid])
										updateMap[oe.guid] = [];
									updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
								}
							}
						}
						if (updateMap && Object.keys(updateMap).length > 0) {
							console.log('EMPlugin_initializeEMOEConfigs updateMap:', updateMap);
							//await CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
							//Spring 20
							//const cnfg = await comp.updateConfigurationAttribute(config.guid, updateMap, false); 
							let keys = Object.keys(updateMap);
							for(let h=0; h< updateMap.length;h++){
								await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],false)
							}
						}
					};
				};
			}
		}
	}
	return Promise.resolve(true);
}
/**
 * Author      : Laxmi  2020-03-13
 * Ticket      : EDGE-131531
 * Description : Method to update ChangeType attribute
 */
EMPlugin_updateLinksAttributeEMS = function(solution) {
    console.log('EMPlugin_updateLinksAttributeEMS');
	var doUpdate = false;
	var updateMap = [];
    if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) ){
        if (solution.components && Object.values(solution.components).length > 0) {
            Object.values(solution.components).forEach(async (comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0) {
								Object.values(config.attributes).forEach((attribute) => {
									if (attribute.name === 'ChangeType') {
										var changeTypeValue = attribute.value;
										//console.log('changeTypeValue: ', changeTypeValue);
										//console.log('window.BasketChange === 'Change Solution': ', window.BasketChange === 'Change Solution');
										// if (window.BasketChange === 'Change Solution' ) {
										console.log('MACD basket');
										var readonly = false;
										// EDGE-131531 - Added one more Status as  'Provisioning In Progress'
										if (config.id && changeTypeValue === 'Cancel' || changeTypeValue === 'Active'  || changeTypeValue === 'Provisioning In Progress' ){
											readonly = true;
											doUpdate = true;
											updateMap[config.guid]=[
												{
													name: 'viewDiscounts',
													// value: {
														showInUi: false
													// }
												},
												{
													name: 'Price Schedule',
													// value: {
														showInUi: false
													// }
												},
												{
													name: 'IsDiscountCheckNeeded',
													// value: {
														showInUi: false,
														readOnly: false,
														value:false
													// }
												}
											];
										} else if ( config.id && changeTypeValue === 'Modify' ) // Added to fix the Issue
										{
											doUpdate = true;
											updateMap[config.guid]=[{
												name: 'viewDiscounts',
												// value: {
													showInUi: true
												// }
											}];
										}
									// }//Basket Check
									}//CHaneg Type Check
								});//For Each Attribute
							}//Attribute Length
						});
					}
					if (doUpdate){
						console.log('EMPlugin_updateLinksAttributeEMS', updateMap);
						Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// edge-120132
						Utils.updateCustomAttributeLinkText('Price Schedule','View All');
						//CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
						//const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
						}
					}			
				}
            });
		}
	}
}
EMPlugin_subscribeToExpandButtonEvents = async(currentComponentName) => {
    //////////////////////////////
    //modify or remove this part to fit your component
	console.log('Inside afterNavigate-----'+currentComponentName);
    if (currentComponentName !== ENTERPRISE_COMPONENTS.mobileSubscription) {
        return;
    }
    //////////////////////////////
    setTimeout(() => {
        //if user clicks on expand button in PC section header
        let buttons = document.getElementsByClassName('expand-btn');
        if (buttons) {
            for (let i = 0; i < buttons.length; i++) {
                buttons[i].addEventListener("mouseup", (e) => {
                    setTimeout(() => {
                        EMPlugin_customAttributeLinkTextReplacements();
                    }, 20);
                });
            }
        }
        //if user clicks on Details link in PC section header
        let tabs = document.getElementsByClassName('tab-name');
        if (tabs) {
            for (let i = 0; i < tabs.length; i++) {
                if (tabs[i].innerText !== 'Details') {
                    continue;
                }
                tabs[i].addEventListener("mouseup", (e) => {
                    setTimeout(() => {
                        EMPlugin_customAttributeLinkTextReplacements();
                    }, 20);
                });
            }
        }
        //if user clicks on PC name in PC section header
        let configs = document.getElementsByClassName('config-name');
        if (configs) {
            for (let i = 0; i < configs.length; i++) {
                configs[i].addEventListener("mouseup", (e) => {
                    setTimeout(() => {
                    }, 20);
                });
            }
        }
    }, 100);
}
EMPlugin_customAttributeLinkTextReplacements = async() => {
    Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
    Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
    return Promise.resolve(true);
}
/**************************************************************************************
 * Author	   : Rohit Tripathi
 * Method Name : EMPlugin_CalculateTotalRCForSolution
 * Edge Number : EDGE-142087
 * Description : This function will count the Quantity of Mobile Subscription Products added into the basket (Modify + New )
 * Invoked When: Before Save
**************************************************************************************/
async function EMPlugin_CalculateTotalRCForSolution() {
    console.log('EMPlugin_CalculateTotalRCForSolution::::::::');
    var componentMap = {};
    var totalMSCount = 0;
    var OfferTypeVal ;
	await CS.SM.getActiveSolution().then((solution) => {
		//let solution = await CS.SM.getActiveSolution();
		if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.schema.configurations).forEach(async (parentConfig) => {
					componentMap[parentConfig.guid] = [];
					Object.values(parentConfig.attributes).forEach((configAttr) => {
						if (configAttr.name === 'OfferTypeString') {
							OfferTypeVal = configAttr.value;
						}								
						console.log('EM     ',OfferTypeVal)
					});	
					if (solution.components && Object.values(solution.components).length > 0 && OfferTypeVal == 'Committed Data') {
						Object.values(solution.components).forEach((comp) => {
							if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
								comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((config) => {
									var cta = Object.values(config.attributes).filter(a => {
										return a.name === 'ChangeType'
									});
									var quant = Object.values(config.attributes).filter(a => {
										return a.name === 'Quantity'
									});
									if ((cta[0].value === 'Modify' || cta[0].value === 'New') && OfferTypeVal == 'Committed Data') {
										console.log('Inside CTA New and Modify   ', cta[0].value, quant[0].value)
										totalMSCount = totalMSCount + parseInt(quant[0].value);
									}
								});
							}
							console.log('totalMSCount-->'+totalMSCount);
							componentMap[parentConfig.guid] = [{
								name: 'Quantity',
								// value: {
									value: totalMSCount,
									displayValue: totalMSCount,
									showInUi: false,
									readOnly: true
								// }
							}];
						});
					}
					else if (OfferTypeVal == 'FairPlay Data') {
						var qauntityforFairPlay = 1;
						console.log('qauntityforFairPlay-->'+qauntityforFairPlay);
						componentMap[parentConfig.guid] = [{
							name: 'Quantity',
							// value: {
								value: qauntityforFairPlay,
								displayValue: qauntityforFairPlay,
								showInUi: false,
								readOnly: true
							// }
						}];
					}
					if (componentMap)
					{
						//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap, true);
						let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility); 
						var complock = component.commercialLock;
						if(complock) component.lock('Commercial', false);
						let keys = Object.keys(componentMap);
						// var complock = component.commercialLock;
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], componentMap[keys[i]], true); 
						}
						if(complock) component.lock('Commercial', true);
					}
				});
			};
		}
	});
	console.log('end of EMPlugin_CalculateTotalRCForSolution');
    return Promise.resolve(true);
}
//Hitesh added for setting EDMListToDecompose attribute at save
async function EMPlugin_updateEDMListToDecomposeattribute(product) {
	console.log('EMPlugin_updateEDMListToDecomposeattribute');
	if (/*product.type &&*/ product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		var statusMsg;
		if (product.components && Object.values(product.components).length > 0) {
			for (let  i=0; i< Object.values(product.components).length; i++) {
				var comp = Object.values(product.components)[i];
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						updateMap = [];
						for (let  j=0; j<Object.values(comp.schema.configurations).length; j++) {
							var mobilityConfig = Object.values(comp.schema.configurations)[j];
							if (mobilityConfig.attributes && Object.values(mobilityConfig.attributes).length > 0) {
								var EDMListToDecompose = 'Mobility_Fulfilment,Mobile Access_Fulfilment,420_RC_654,263_NRC_601,326_ASR,151_ASR,263_AW_606,263_AW_607'; //Hitesh: Added 606,607 allowance spec to default list.
								var selectPlan = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'Select Plan'
								});
								var OfferTypeString = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'OfferTypeString'
								});
								var InternationalDirectDial = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'InternationalDirectDial'
								});
								var MessageBank = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'MessageBank'
								});
								//Added for EDGE-89294
								var MDMEntitled = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'MDMEntitled'
								});
								//Added for EDGE-103386
								var DataPackChargeRec = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'DataPackChargeRec'
								});
								var IDDCharge = Object.values(mobilityConfig.attributes).filter(a => {
									return a.name === 'IDD Charge'
								});
								if (MessageBank && MessageBank.length > 0) {
									if (MessageBank[0].displayValue && MessageBank[0].displayValue === "VOICE to TEXT") {
										EDMListToDecompose = EDMListToDecompose + ',420_RC_497';
									}
								}
								if (InternationalDirectDial && InternationalDirectDial.length > 0 && selectPlan && selectPlan.length > 0) {
									if (InternationalDirectDial[0].value && InternationalDirectDial[0].value !== '') {
										if(parseInt(IDDCharge[0].value) !== 0){ //Hitesh: Added parseInt for comparision condition.
											EDMListToDecompose = EDMListToDecompose + ',420_RC_669';
										}
									}
								}
								if (OfferTypeString && OfferTypeString.length > 0) {
									if (OfferTypeString[0].value && OfferTypeString[0].value === "FairPlay Data") {
										EDMListToDecompose = EDMListToDecompose + ',420_AW_637';
									} else if (OfferTypeString[0].value === "Committed Data") {
										EDMListToDecompose = EDMListToDecompose + ',420_AW_806';
									} else if (OfferTypeString[0].value === "Aggregated Data") {
										EDMListToDecompose = EDMListToDecompose + ',420_AW_641';
									} else if (OfferTypeString[0].value === "Data Pool Data") {
										EDMListToDecompose = EDMListToDecompose + ',420_AW_642';
									}
								}
								if (InternationalDirectDial && InternationalDirectDial.length > 0) {
									if (InternationalDirectDial[0].value !== '') {
										EDMListToDecompose = EDMListToDecompose + ',420_AW_644';
									}
								}
								if (selectPlan && selectPlan.length > 0) {
									//if (selectPlan[0].displayValue === "Global BYO" || selectPlan[0].displayValue === "Global" || selectPlan[0].displayValue === "Executive") {
									if (selectPlan[0].displayValue === "Global BYO" || selectPlan[0].displayValue === "Global" || selectPlan[0].displayValue === "Executive" || selectPlan[0].displayValue === "Global Data SIM" || selectPlan[0].displayValue === "Global Data SIM BYO") { //Hitesh Added for fix of EDGE-155203
										EDMListToDecompose = EDMListToDecompose + ',420_AW_670';
									}
								}
								//Added for  EDGE-89294
								if (MDMEntitled && MDMEntitled.length > 0) {
									if (MDMEntitled[0].value === 'true') {
										EDMListToDecompose = EDMListToDecompose + ',421_ASR';
									}
								}
								//Added for EDGE-103386
								/*if (DataPackChargeRec && DataPackChargeRec.length > 0) {
									if (DataPackChargeRec[0].value !== '') {
										EDMListToDecompose = EDMListToDecompose + ',420_RC_824';
									}
								}*/
								console.log('EDMListToDecompose', EDMListToDecompose);
								updateMap[mobilityConfig.guid] = [{
									name: 'EDMListToDecompose',
									// value: {
										value: EDMListToDecompose,
										displayValue: EDMListToDecompose
									// }
								}];
							}
						}
						//await CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true);
						//const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 			
						let keys = Object.keys(updateMap);
						var complock = comp.commercialLock;
						// if(complock) comp.lock('Commercial', false);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
						}
						//if(complock) comp.lock('Commercial', true);
					}
				}
			}
		}
	}
	return Promise.resolve(true);
}
/************************************************************************************
 * Author	: Ankit Goswami
 * Method Name : EMPlugin_updateEDMListToDecomposeattributeForSolution
 * Defect/US # : EDGE-103385
 * Invoked When: Click on Validate and save button
 * Description :Update EDMdecomposition field on PC
 * Parameters : guid
 ***********************************************************************************/
async function EMPlugin_updateEDMListToDecomposeattributeForSolution(loadedSolution) {
	console.log('EMPlugin_updateEDMListToDecomposeattributeForSolution');
	let updateSolMap = {};
	let commitedDataCheck =false;
	if (/*loadedSolution.type &&*/ loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (loadedSolution.schema && loadedSolution.schema.configurations && Object.values(loadedSolution.schema.configurations).length > 0 ) {
			Object.values(loadedSolution.schema.configurations).forEach((config) => {
				Object.values(config.attributes).forEach((attr) => {
				if(attr.name === 'OfferTypeString' && attr.value==='Committed Data'){
				  commitedDataCheck=true;
				}
				});
			});
			Object.values(loadedSolution.schema.configurations).forEach(async (config) => {
				updateSolMap[config.guid]=[];
				Object.values(config.attributes).forEach((attr) => {
					if(attr.name === 'BonusDataPromotionEndDate' && commitedDataCheck){
						if(attr.value !== '' ){
							//if(basketContractSignDate <= BonusDataPromotionEndDate){
							updateSolMap[config.guid].push(
							{
								name: 'EDMListToDecompose',
								// value: {
									value: '420_AW_877,420_AW_805,420_RC_824',
									displayValue: '420_AW_877,420_AW_805,420_RC_824'
								// }
							});
							//}
						} else{
							updateSolMap[config.guid].push(
								{
								name: 'EDMListToDecompose',
								// value: {
									value: '420_RC_824,420_AW_805',
									displayValue: '420_RC_824,420_AW_805'
								// }
							});
						}
					}
					else if(attr.name === 'BonusDataPromotionEndDate' && !commitedDataCheck)
					{
						updateSolMap[config.guid].push(
							{
							name: 'EDMListToDecompose',
							// value: {
								value: 'No Specs',
								displayValue: 'No Specs'
							// }
						});
					}
				});
				//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateSolMap, true);
				let component = await loadedSolution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility); 
				//const cnfg = await component.updateConfigurationAttribute(config.guid, updateSolMap, true); 
				let keys = Object.keys(updateSolMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateSolMap[keys[i]], true); 
				}
			});
		}
	}
	return Promise.resolve(true);
}
/************************************************************************************
 * Author	: Tihomir Baljak
 * Method Name : validateCancelSolution
 * Invoked When: in as EMPlugin_saveSolutionEM function (before save)
 * Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all mobile subscriptions change type is set to cancel
 * Parameters : solution
 ***********************************************************************************/
EMPlugin_validateCancelSolution =  function (solution) {
	console.log('EMPlugin_validateCancelSolution');
	let configs = Object.values(solution.schema.configurations);
	console.log('configs',configs);
	let changeTypeAttribute = Object.values(configs[0].attributes).filter(a => {return a.name==='ChangeType' && a.value==='Cancel'});
	if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
		return true;
	}
	let isValid = true;
	Object.values(solution.components).forEach((comp) => {
		if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
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
		CS.SM.displayMessage('When canceling whole solution all Mobile Subscriptions must be canceled too!', 'error');
	}
	return isValid;
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : calculate
 * Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
 * Invoked When: PlanDiscount  is updated, 
**************************************************************************************/
async function EMPlugin_setPlanDiscount(guid,componentName) {
	//CS.SM.getActiveSolution().then((product) => {
	// Spring 20
	console.log('EMPlugin_setPlanDiscount');
	let product = await CS.SM.getActiveSolution();
	if (product && /*product.type &&*/  product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if (comp.name === componentName) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (parentConfig) => {	
							var planRecord = Object.values(parentConfig.attributes).filter(obj => {
									return obj.name === 'Select Plan'
							});
							var deviceRecord = Object.values(parentConfig.attributes).filter(obj => {
									return obj.name === 'InContractDeviceRecId'
							});
							if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {										
								parentConfig.relatedProductList.forEach(async (relatedProduct) => {
									if (relatedProduct.guid === guid) {
									//Added by Ankit Goswami as a part of EDGE-143972 || Start
									Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);
									Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);
									//Added by Ankit Goswami as a part of EDGE-143972 || End
									let updateConfigMap = {};
									// sum MROBonus of all related device
									//Added by Ankit as a part of EDGE-148661 || End
									var DeviceStatusAtrtribute = Object.values(relatedProduct.configuration.attributes).filter(obj => {
										return obj.name === 'DeviceStatus'
									});
									//Added by Ankit as a part of EDGE-148661 || End
									if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === 'Related Component') {
									//Added As part of EDGE-123594 by end|| start
									var ChangeTypeDeviceAtrtribute = Object.values(relatedProduct.configuration.attributes).filter(obj => {
										return obj.name === 'ChangeTypeDevice'
									});
									//Added As part of EDGE-123594|| End
									//relatedProduct.configuration.attributes.forEach((attribute) => {
										if (ChangeTypeDeviceAtrtribute[0].value ==='PayOut' || DeviceStatusAtrtribute[0].value ==='PaidOut') {//Added conditions As part of EDGE-123594
											updateConfigMap[parentConfig.guid] = [{
												name: 'PlanDiscountLookup',
												// value: {
													value: '',
													displayValue: ''
												// }														
											},
											{
												name: 'TotalPlanBonus',
												// value: {
													value: 0,
													displayValue: 0
												// }		
											}];
											//CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, true);
											// Spring 20
											//let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
											let keys = Object.keys(updateConfigMap);
											for (let i = 0; i < keys.length; i++) {
												await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false); 
											}
										}else{
											EMPlugin_updatePlanDiscount(parentConfig, planRecord[0].value, deviceRecord[0].value);
										}
									//});
									}
										//Added by Ankit as a part of EDGE-148661 || Start
										if(DeviceStatusAtrtribute[0].value !=='PaidOut'){
											pricingUtils.resetDiscountAttributes(parentConfig.guid,ENTERPRISE_COMPONENTS.mobileSubscription); 
											//CS.SM.updateConfigurationStatus(comp.name, parentConfig.guid, false, 'Please Click on "Generate Net Price" to update pricing of items in the basket');
											// Spring 20
											let cnfg = await comp.getConfiguration(parentConfig.guid); 
											cnfg.status = false;
											cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
											skipsave = true;
										}//Added by Ankit as a part of EDGE-148661 || End
									}
								});
							}
						});
					}
				}
			});
		}
	}
  	//});
}
/************************************************************************************
 * Author		: Ankit Goswami
 * Method Name 	: EMPlugin_EnableAttributesforModify
 * Invoked When	: enable attributes
 * Description 	: enable schemas if it is active on Macd
 * Parameters 	: N/A
 ***********************************************************************************/
async function EMPlugin_EnableAttributesforModify(guid){
	//CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	console.log('EMPlugin_EnableAttributesforModify');
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if(config.guid===guid){
								if (config.attributes && Object.values(config.attributes).length > 0){
									var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'ChangeType'
									});
									var PlanTypeStringAtrtribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'PlanTypeString'
									});	
									var SelectPlanNameAtrtribute = Object.values(config.attributes).filter(obj => {
											return obj.name === 'SelectPlanName'
									});	
										if (changeTypeAtrtribute[0].value === 'Modify'){
											EMPlugin_updateAttributeVisibility( ENTERPRISE_COMPONENTS.mobileSubscription,'Select Plan', guid,false,true,true);
											if(PlanTypeStringAtrtribute[0].value !=='Data'){
												EMPlugin_updateAttributeVisibility( ENTERPRISE_COMPONENTS.mobileSubscription,'MessageBank', guid,false,true,true);
												if(SelectPlanNameAtrtribute[0].value === 'Local' || SelectPlanNameAtrtribute[0].value === 'Local BYO' || SelectPlanNameAtrtribute[0].value === 'Basic' ||  SelectPlanNameAtrtribute[0].value ==='Entry'||  SelectPlanNameAtrtribute[0].value ==='Standard'){
													EMPlugin_updateAttributeVisibility( ENTERPRISE_COMPONENTS.mobileSubscription,'InternationalDirectDial', guid,false,true,false);
												}else{
													EMPlugin_updateAttributeVisibility( ENTERPRISE_COMPONENTS.mobileSubscription,'InternationalDirectDial', guid,true,true,false);
												}
											}
										}
								}
							}
						});
					}
				}
			});
		}
	}
	//});
}
/************************************************************************************
 * Author		: Ankit Goswami
 * Method Name 	: EMPlugin_DeviceAddconfigurationError
 * Invoked When	: Add Device configuration and  
 * Description 	: Read only schemas if it is active on Macd
 * Parameters 	: N/A
 ***********************************************************************************/
EMPlugin_DeviceAddconfigurationError = async function (guid){
	console.log('EMPlugin_DeviceAddconfigurationError');
	//CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0){
								var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
									return obj.name === 'ChangeType'
								});
								if (changeTypeAtrtribute[0].value === 'Cancel' && config.relatedProductList && config.relatedProductList.length > 1){
									config.relatedProductList.forEach(async (relatedConfig) => {	
										if(relatedConfig.guid===guid){
											// CS.SM.updateConfigurationStatus(comp.name, relatedConfig.guid, false, 'You can not add device on Cancel Mobile subscription.');
											// Spring 20
											let cnfg = await comp.getConfiguration(relatedConfig.guid); 
											cnfg.status = false;
											cnfg.statusMessage = 'You can not add device on Cancel Mobile subscription.';
										}
									});
								}
							}
						});
					}
				}
			});
		}
	}
	//})
}
/************************************************************************************
 * Author	: ankit G
 * Method Name : showCommitedDataNotification
 * Defect/US # : EDGE-112122
 * Invoked When:  Validate on save button
 * Description : RemainingTerm calculate on Mobile subscription
 * Parameters : N/A
 ***********************************************************************************/
async function EMPlugin_UpdateRemainingTermOnParent(){
	console.log('EMPlugin_UpdateRemainingTermOnParent');
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		var updateRemainingTermMap = {};
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {        
							updateRemainingTermMap[config.guid] = [];                        
							if (config.relatedProductList && config.relatedProductList.length === 1) {
								config.relatedProductList.forEach(async (relatedConfig) => {
									if (relatedConfig.name.includes('Device')) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
											var cancelFlag = '';
											var remainingTerm = 0;
											var remainingTermAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'RemainingTerm'
											});
											var cancelFlagAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
											return obj.name === 'ChangeTypeDevice'
											});
											remainingTerm = remainingTermAttribute[0].value;
											cancelFlag =cancelFlagAttribute[0].value;
											console.log('updateremainingTermOnMS    RemainingTerm'+remainingTerm);
											console.log('updateremainingTermOnMS    cancelFlag'+cancelFlag);
											console.log('updateremainingTermOnMS    Inside else');
											updateRemainingTermMap[config.guid] = [{
												name: 'RemainingTerm',
												// value: {
													value: remainingTerm,
													displayValue: remainingTerm
												// }
											}];
											console.log('updateremainingTermOnMS ', updateRemainingTermMap);
											//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateRemainingTermMap, true);
											//const cnfg = await comp.updateConfigurationAttribute(config.guid, updateRemainingTermMap, true); 
											let keys = Object.keys(updateRemainingTermMap);
											//comp.lock('Commercial', false);
											var complock = comp.commercialLock;
											// if(complock) comp.lock('Commercial', false);
											for (let i = 0; i < keys.length; i++) {
												await comp.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true); 
											}
											//if(complock) comp.lock('Commercial', true);
										}					
									}
								});
							}else if (config.relatedProductList && config.relatedProductList.length > 1) {
								config.relatedProductList.forEach(async (relatedConfig) => {
									if (relatedConfig.name.includes('Device')) {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
											var cancelFlag = '';
											var remainingTerm = 0;
											var remainingTermAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
												return obj.name === 'RemainingTerm'
											});
											var cancelFlagAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
											return obj.name === 'ChangeTypeDevice'
											});
											remainingTerm = remainingTermAttribute[0].value;
											cancelFlag =cancelFlagAttribute[0].value;
											console.log('updateremainingTermOnMS    RemainingTerm'+remainingTerm);
											console.log('updateremainingTermOnMS    cancelFlag'+cancelFlag);
											if(remainingTerm > 0){
												console.log('updateremainingTermOnMS    Inside else');
												updateRemainingTermMap[config.guid] = [{
													name: 'RemainingTerm',
													// value: {
														value: remainingTerm,
														displayValue: remainingTerm
													// }
												}];
												console.log('updateremainingTermOnMS ', updateRemainingTermMap);
												//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateRemainingTermMap, true);
												//const cnfg = await comp.updateConfigurationAttribute(config.guid, updateRemainingTermMap, true); 
												let keys = Object.keys(updateRemainingTermMap);
												//comp.lock('Commercial', false);
												var complock = comp.commercialLock;
												//if(complock) comp.lock('Commercial', false);
												for (let i = 0; i < keys.length; i++) {
													await comp.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true); 
												}
												//if(complock) comp.lock('Commercial', true);
											}
										}					
									}
								});
							}
							else {
								console.log('updateremainingTermOnMS    Inside outer else');
								updateRemainingTermMap[config.guid] = [{
									name: 'RemainingTerm',
										value: 0,
										displayValue: 0
								}];
								console.log('updateremainingTermOnMS ', updateRemainingTermMap);
								//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateRemainingTermMap, true);
								//const cnfg = await comp.updateConfigurationAttribute(config.guid, updateRemainingTermMap, true); 
								let keys = Object.keys(updateRemainingTermMap);
								//comp.lock('Commercial', false);
								var complock = comp.commercialLock;
								// if(complock) comp.lock('Commercial', false);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true); 
								}
								//if(complock) comp.lock('Commercial', true);
							}
						});
					}
				}
			});
		}
	}
	//})
}	
//EDGE - 81135 : Calculate ETC charges for cancellation type
EMPlugin_calculateTotalETCValue = async function(guid) {
	console.log('EMPlugin_calculateTotalETCValue', window.BasketChange === 'Change Solution', guid);
	if (window.BasketChange === 'Change Solution' ) {
		let product = await CS.SM.getActiveSolution();
		var contractTerm;
		var disconnectionDate;
		var unitPriceRC;
		var prodConfigID;
		var deviceConfigID;
		var deviceConfig;
		var macdeviceConfig;
		console.log('EMPlugin_calculateTotalETCValue', product);
		if (/*product.type &&*/ product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			if (product.components && Object.values(product.components).length > 0) {
				console.log('Subscription',Object.values(product.components,product.components).length);
				Object.values(product.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
						console.log('Inside Mobile-sub', comp);
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((mobilesubConfig) => {
								if (mobilesubConfig.guid === guid) {
									//prodConfigID = mobilesubConfig.id;
									Object.values(mobilesubConfig.attributes).forEach((mBAttribute) => {
										if (mBAttribute.name === 'DisconnectionDate' && mBAttribute.value) {
											disconnectionDate = new Date(mBAttribute.value);
											console.log('DisconnectionDate=', disconnectionDate);
										}
									});
								}
								if (mobilesubConfig.relatedProductList && Object.values(mobilesubConfig.relatedProductList).length > 0) {
										Object.values(mobilesubConfig.relatedProductList).forEach((relatedConfig) => {
										if(relatedConfig.guid===guid || mobilesubConfig.guid === guid ){
											prodConfigID = mobilesubConfig.id;
											if(relatedConfig.guid===guid){
												disconnectionDate = new Date();
											}
											if (relatedConfig.type === 'Related Component' && relatedConfig.name === 'Device') {
											console.log('relatedConfig:', relatedConfig);
												deviceConfigID = relatedConfig.guid;
												deviceConfig = relatedConfig.configuration.replacedConfigId;
												macdeviceConfig = relatedConfig.configuration.id;
												var ChangeTypeDeviceattribute = Object.values(relatedConfig.configuration.attributes).filter(att => { 
													return att.name === "ChangeTypeDevice"
												});
												contractTerm = Object.values(relatedConfig.configuration.attributes).filter(a => {
													return a.name === 'ContractTerm'
												});
												unitPriceRC = Object.values(relatedConfig.configuration.attributes).filter(c => {
													return c.name === 'InstalmentCharge'
												});
											}
										}
										});
									}
								// }
							});
						}
					}
				});
				console.log('contractTerm=', contractTerm, ', disconnectionDate=', disconnectionDate, ', unitPriceRC=', unitPriceRC);
				if (disconnectionDate && contractTerm) {
					var inputMap = {};
					var updateMap = [];
					inputMap["DisconnectionDate"] = disconnectionDate;
					inputMap["etc_Term"] = contractTerm[0].displayValue;
					inputMap["CalculateEtc"] = '';
					inputMap["etc_UnitPrice"] = unitPriceRC[0].displayValue;
					inputMap["ProdConfigId"] = prodConfigID;
					inputMap["deviceConfigID"] = deviceConfig;
					inputMap["macdeviceConfigID"] = macdeviceConfig;
					console.log('inputMap', inputMap);
					let currentBasket;
					currentBasket = await CS.SM.getActiveBasket(); // fetch current basket
					await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async values => {
						var charges = values["CalculateEtc"];
						var chargesGst=parseFloat(charges*1.1).toFixed(2);		    //added by Romil
						var deviceRemainingTerm = values["RemainingTerm"];
						console.log('Result', values["CalculateEtc"],charges);
						updateMap[guid] = [{
							name: 'EarlyTerminationCharge',
							// value: {
								value: charges,
								displayValue: charges
							// }
						},{	
								name: 'OneOffChargeGST',		    //added by Romil	
								// value: {	
									label: 'Balance Due On Device(Inc GST)',	
									value: chargesGst,	
									displayValue: chargesGst	
								// }	
							}];
						if(deviceConfigID===guid){
							updateMap[deviceConfigID] = [
								{
								name: 'EarlyTerminationCharge',
								// value: {
									value: charges,
									displayValue: charges,
									showInUi: true,
								// }
								},{	
									name: 'OneOffChargeGST',		    //added by Romil	
									// value: {	
										label: 'Balance Due On Device(Inc GST)',	
										value: chargesGst,	
										displayValue: chargesGst,	
										showInUi: true	
									// }	
								},{	
									name: 'RedeemFund',		    //added by Romil	
									// value: {	
										showInUi: true	
									// }	
								},{	
									name: 'TotalFundAvailable',		    //added by Romil	
									// value: {	
										showInUi: true	
									// }	
								}
							];
						}else{
							updateMap[deviceConfigID] = [
								{
								name: 'EarlyTerminationCharge',
								// value: {
									value: charges,
									displayValue: charges,
									showInUi: false,
								// }
								},{	
										name: 'OneOffChargeGST',		    //added by Romil	
										// value: {	
											label: 'Balance Due On Device(Inc GST)',	
											value: chargesGst,	
											displayValue: chargesGst,	
											showInUi: false	
										// }	
									},{	
										name: 'RedeemFund',		    //added by Romil	
										// value: {	
											showInUi: false	
										// }	
									},{	
										name: 'TotalFundAvailable',		    //added by Romil	
										// value: {	
											showInUi: false	
										// }	
									}
							];
						}	
						let component = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
						//const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap ,true );
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
						}
					});
				}
			}
		}
	}
}
/************************************************************************************
 * Author	: Sandip Deshmane
 * Method Name : EMPlugin_validateDisconnectionDate
 * Defect/US # : EDGE-138631
 * Invoked When: Disconnection Date Attribute Updated
 * Description : Validate Disconnection Date is not in the past.
 * Parameters : componentName, guid, newValue
 ***********************************************************************************/
EMPlugin_validateDisconnectionDate = async function (componentName, guid, newValue) {
    let today = new Date();
    let attDate = new Date(newValue);
    today.setHours(0,0,0,0);
	attDate.setHours(0,0,0,0);
	let activeSolution = await CS.SM.getActiveSolution();
	let component = await activeSolution.getComponentByName(componentName);
	let config = await component.getConfiguration(guid); 
    if (attDate <= today) {
        CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
		config.status = false;
		config.statusMessage = 'Disconnection date should be greater than today!';
    } else {
		config.status = true;
		config.statusMessage = '';
    }
}
//Added by Aman Soni for EDGE-123575	
function EMPlugin_processMessagesFromIFrame() {
	//console.log('EMPlugin_processMessagesFromIFrame');
    if (!communitySiteId) {
        return;
    }
    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var childWindow = sessionStorage.getItem("childWindow");
		//console.log('CW--->'+childWindow);
		if (childWindow){
			childWindow.postMessage('Hey', window.origin);
		}
    var message = {};
    if (data){
        //console.log('EMPlugin_processMessagesFromIFrame:', data);
        message['data'] = JSON.parse(data);
        EMPlugin_handleIframeMessage(message);
    }
    if (close){
        //console.log('EMPlugin_processMessagesFromIFrame:', data);
        message['data'] = close;
        EMPlugin_handleIframeMessage(message);
    }
}
//Added by Aman Soni for EDGE-123575
async function EMPlugin_handleIframeMessage(e) {
	//console.log('handleIframeMessage from pricing:', e);
	var message = {};
	message = e['data'];			
	message = message['data'];
	let product = null;
	console.log('trying to get solution');
	try{
		product = await CS.SM.getActiveSolution(); 
	}
	catch(e) {
		console.log('Product is ' + product); 
	}
	if(product == null ) return Promise.resolve(true);
	if (e.data['command'] === 'showPromo' && e.data['caller']==='Enterprise Mobility' && e.data['data']===configId){
	//console.log('configId inside i frame event listner'+configId);
	await pricingUtils.postMessageToshowPromo(e.data['caller'],configId,"viewDiscounts");
	}
	else if (e.data['command'] === 'StockCheck' && e.data['data'] === solutionID && e.data['caller']==='Enterprise Mobility'){//EDGE-146972
		await stockcheckUtils.postMessageToStockCheck(e.data['caller'], solutionID)
	}
	else if(e.data['command'] === 'pageLoadEnterprise Mobility' && e.data['data']===solutionID){
		//console.log('configId inside i frame event listner page laod'+solutionID+IsDiscountCheckNeeded_EM);
		pricingUtils.postMessageToPricing(callerName_EM,solutionID,IsDiscountCheckNeeded_EM,IsRedeemFundCheckNeeded_EM);//EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
	}else if (e.data && e.data['command'] != undefined){
		//console.log('data is --->'+e.data['data']);
		// console.log('command is --->'+e.data['command']);
		// console.log('caller is --->'+e.data['caller']);
		if (e.data['command'] && e.data['command'] === 'correlationId') {
			// console.log('Inside CorrelationId is --->'+e.data['data']);
			if (e.data['caller'] && e.data['caller']  !== 'Enterprise Mobility') {
				return;
			}
			if (e.data['data']) {
				pricingUtils.setCorrelationId(e.data['data'],ENTERPRISE_COMPONENTS.enterpriseMobility);
			}
		}
		//------------------ Added by Samish for EDGE-132203 on 10-02-2020 START ------------------//
		if (e.data['command'] && e.data['command'] === 'timeout') {
			// console.log('Inside timeout --->'+e.data['data']);
			if (e.data['caller'] && e.data['caller']  !== 'Enterprise Mobility') {
				return;
			}
			if (e.data['data']) {
				pricingUtils.customLockSolutionConsole('unlock');
				pricingUtils.setCorrelationId(e.data['data'], ENTERPRISE_COMPONENTS.enterpriseMobility);
				pricingUtils.setDiscountStatus('None', ENTERPRISE_COMPONENTS.enterpriseMobility);
			}
		}
		//------------------ Added by Samish for EDGE-132203 on 10-02-2020 END ------------------//
		if (e.data['command'] && e.data['command'] === 'ResponseReceived') {	
			if (e.data['caller'] && e.data['caller']  !== 'Enterprise Mobility') {
				return;
			}
			if (e.data['data']) {
				// console.log('Inside ResponseReceived Data is --->'+e.data['data']);				
                var guidList=[];
                if (product.components && product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
                    if (product.components && Object.values(product.components).length > 0) {
                        Object.values(product.components).forEach((comp) => {
                            if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
                                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {	
                                    Object.values(comp.schema.configurations).forEach((config) => {
                                        var guid=config.guid;
                                        guidList.push(config.guid);
                                    });
                                }
                            }
                        });
                    }
                }
				guidList.toString();
				// console.log('guidList-->' +guidList);
				let inputMap = {};
				inputMap['configIdList'] = guidList.toString();
				inputMap['CorrelationId']=e.data['data'];
				// console.log(inputMap);
				if(e.data['IsDiscountCheckAttr'] === 'true'){ //EDGE-140967 added by ankit
				let currentBasket; 
				currentBasket = await CS.SM.getActiveBasket(); 
				await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async response =>  {
					console.log(response);		
					// if(response && Object.values(response).length > 0 ) 
					// {
						var resultTCV = JSON.stringify(response["TCVMap"]);
						// console.log(resultTCV); 
						if (resultTCV){
							var res = JSON.stringify(response);
							// console.log(res);
							var res1 = JSON.parse(res);	
							// console.log(res1);
							// console.log(res1.TCVMap);
							var res2 = JSON.stringify(res1.TCVMap);
							// console.log(res2);								
							var res3 = JSON.parse(res2);
							// console.log(res3);	
							var updateConfigMap1 = {};
							var configTobeUpdated=false;
							Object.keys(res3).forEach(async valueKey => {
								// console.log('valueKey:::',valueKey);
								var mainKey=valueKey.replace(/['"]+/g, '');	
								// console.log('valueKey:::',res3[valueKey]);
								// console.log('valueKey:::',JSON.stringify(res3[valueKey]));
								var attrNameMap =JSON.stringify(res3[valueKey])
								var attrName = JSON.parse(attrNameMap);
								updateConfigMap1[mainKey.toString()] = [];
								Object.keys(attrName).forEach(keyValue => {
									// console.log('valueKey1:::',keyValue);
									// console.log('valueKey2:::',attrName[keyValue]);
									if(keyValue.toString() != null && keyValue.toString() != '' && keyValue.toString() != undefined ){
										updateConfigMap1[mainKey.toString()].push({
											name: keyValue.toString(),
											value: attrName[keyValue],
											displayValue :attrName[keyValue],
											//showInUi:true,
											readOnly:true									
										});
										updateConfigMap1[mainKey.toString()].push({
											name: "IsDiscountCheckNeeded",
											value: false
										});
										configTobeUpdated=true;
									}									
								});	
								//added by ankit EDGE-132203 || start
								var IsUpadate=EMPlugin_CheckErrorsOnSolution(product); 
								// console.log('updateConfigMap1:::',updateConfigMap1);
								if(!IsUpadate){	
									//added by ankit EDGE-132203 || end
									//let activeSolution = await CS.SM.getActiveSolution(); 
									let component = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
									let cnfg = await component.getConfiguration(mainKey.toString()); 
									cnfg.status = true; 
									//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,mainKey.toString(),true);
								}else{
									pricingUtils.resetDiscountAttributes(ENTERPRISE_COMPONENTS.mobileSubscription);
								}
							});	
							if(configTobeUpdated===true){
								let activeSolution = await CS.SM.getActiveSolution();  
								let component = await activeSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
								// const config = await component.updateConfigurationAttribute(component.configuration.guid, updateConfigMap1 ,false ); 
								let keys = Object.keys(updateConfigMap1);
								for(let i = 0; i < keys.length; i++){
									await component.updateConfigurationAttribute(keys[i],updateConfigMap1[keys[i]],false);
								}
								// Arinjay or this has to be e.data['ApplicableGuid']
								//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap1, false);	
								pricingUtils.setDiscountStatus('Acknowledge',ENTERPRISE_COMPONENTS.enterpriseMobility);
							}
							skipsave = false;//added by ankit EDGE-132203
							EMPlugin_CheckErrorsOnSolution(product);	
						} 
						else {
							console.log('Price schedule could not be generated');
							CS.SM.displayMessage('Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.', 'error');
						}
					// }
					return Promise.resolve(true);
				});
				}//EDGE-140967 added by ankit||start
				if(e.data['IsRedeemFundCheckAttr'] === 'true'){
					if (e.data['caller'] && e.data['caller'] !== 'Enterprise Mobility') {
						return;
					}
					skipsave = false;//added by ankit EDGE-132203
					pricingUtils.validateApplicableConfigsJS(e.data['ApplicableGuid'],ENTERPRISE_COMPONENTS.mobileSubscription);
					EMPlugin_CheckErrorsOnSolution(product);
				}				
				//EDGE-140967 added by ankit||End
				pricingUtils.customLockSolutionConsole('unlock');	
				//pricingUtils.setDiscountAttributesAtSolutionAfterResponse(message['data']);
				pricingUtils.resetCustomAttributeVisibility();	
				Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All'); // Added as part of Edge-123593 by ankit
				Utils.updateCustomAttributeLinkText('Price Schedule','View All');// Added as part of Edge-123593 by ankit
				setTimeout(function(){ pricingUtils.closeModalPopup(); }, 1000);
				return Promise.resolve(true);
			}
		}else if(e.data['command'] && e.data['command'] === 'unlockBasket'){
			if (e.data['caller'] && e.data['caller'] !== 'Enterprise Mobility') {
				return;
			}
			skipsave = false;//added by ankit EDGE-132203
			pricingUtils.validateNotApplicableConfigsJS(e.data['data'],ENTERPRISE_COMPONENTS.mobileSubscription);
			//pricingUtils.setDiscountAttributesToValidWhenDisNotApplicable();
			pricingUtils.setDiscountStatus('Acknowledge',ENTERPRISE_COMPONENTS.enterpriseMobility);
			pricingUtils.customLockSolutionConsole('unlock');	
			EMPlugin_CheckErrorsOnSolution(product);	
			setTimeout(function(){ pricingUtils.closeModalPopup(); }, 1000);
			return Promise.resolve(true);
		}else if(e.data['command'] && e.data['command'] === 'validNotApplicableConfigs'){
			if (e.data['caller'] && e.data['caller'] !== 'Enterprise Mobility') {
				return;
			}
            // added By Rohit EDGE-140459
			skipsave = false;//added by ankit EDGE-132203
			pricingUtils.validateNotApplicableConfigsJS(e.data['data'],ENTERPRISE_COMPONENTS.mobileSubscription);
			EMPlugin_CheckErrorsOnSolution(product);
			return Promise.resolve(true);
		}else if(e.data['command'] && e.data['command'] === 'Already triggered'){
			if (e.data['caller'] && e.data['caller'] !== 'Enterprise Mobility') {
				return;
			}
			skipsave = false;//added by ankit EDGE-132203
			pricingUtils.customLockSolutionConsole('unlock');
			setTimeout(function(){ pricingUtils.closeModalPopup(); }, 1000);			
			return Promise.resolve(true);
		}/////////////////added by shubhi start/////////////
		else if (e.data['command'] && e.data['command'] === 'ErrorInResponse') { // added by shubhi //Edge-143527
			if (e.data['caller'] && e.data['caller'] !== 'Enterprise Mobility') {
				return;
			}
			pricingUtils.customLockSolutionConsole('unlock');
			pricingUtils.setDiscountStatusBasedonComponent('None', ENTERPRISE_COMPONENTS.enterpriseMobility,'DiscountStatus'); 
			console.log('Price schedule could not be generated');
			CS.SM.displayMessage('Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.', 'error'); // added by shubhi for error //Edge-121376
			setTimeout(function(){ pricingUtils.closeModalPopup(); }, 1000);
            return Promise.resolve(true);
        }//////////////////// added by shubhi end ////////////////////////////////
		pricingUtils.resetCustomAttributeVisibility();
		Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// Added as part of Edge-123593 by ankit
		Utils.updateCustomAttributeLinkText('Price Schedule','View All');// Added as part of Edge-123593 by ankit
	}
	//console.log('end of EMPlugin_handleIframeMessage');
	return Promise.resolve(true);
}
/**********************************************************************************************
* Author	  : Mahaboob Basha
* Method Name : setEMOETabsVisibility
* Invoked When: after solution is loaded
* Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
* Parameters  : configuration guid or nothing
*********************************************************************************************/
async function EMPlugin_setEMOETabsVisibility() {
	console.log('EMPlugin_setEMOETabsVisibility');
	//CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
						let oeToShow = [];		
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {		
						if (!oeSchema.name.toLowerCase().includes('number')) {		
							oeToShow.push(oeSchema.name);		
						}		
					});
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							//if (!configGuid || configGuid === config.guid) {
								if (config.attributes && Object.values(config.attributes).length > 0) {
									var changeTypeAttribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
									});
									if (window.BasketChange === 'Change Solution'  && changeTypeAttribute && changeTypeAttribute.length > 0) 
									// ||!Utils.isOrderEnrichmentAllowed()) 
									{
										CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
										console.log('EMPlugin_setEMOETabsVisibility - hiding:', comp.name, config.guid);
									} else {
										CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
										console.log('EMPlugin_setEMOETabsVisibility - showing:', comp.name, config.guid);
									}
								}
							//}
						});
					}
				}
			});
		}
	}
	return Promise.resolve(true);
    //});
}
/************************************************************************************
 * Author	: Ankit Goswami
 * Method Name : EMPlugin_setAttributesReadonlyValueForsolution
 * Invoked When: onloadsolution
 * Description : Read only schemas if it is active on Macd
 * Parameters : N/A
 ***********************************************************************************/
EMPlugin_setAttributesReadonlyValueForsolution = async function () {
	console.log('EMPlugin_setAttributesReadonlyValueForsolution');
	let solution = await CS.SM.getActiveSolution();
	if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
			let componentMap =  new Map();
			Object.values(solution.schema.configurations).forEach((config) => {	
				let componentMapattr = {};
				var changeTypesolution = Object.values(config.attributes).filter(obj => {
					return obj.name === 'ChangeType'
				});
				Object.values(config.attributes).forEach((attr) => {
					if(attr.name !=='ChangeType' && attr.name !=='ConfigName' && changeTypesolution[0].value !== 'Modify' && changeTypesolution[0].value !== 'Cancel' ){
					componentMapattr[attr.name] = [];
					componentMapattr[attr.name].push({'IsreadOnly':true});	
					}else{
						componentMapattr['DataPackPlan'] = [];
						componentMapattr['DataPackPlan'].push({'IsreadOnly':false});	
					}
				});
				componentMap.set(config.guid,componentMapattr);
			});

			CommonUtills.setAttributesReadonlyValue(ENTERPRISE_COMPONENTS.enterpriseMobility,componentMap);

		}
		if (solution.components && Object.values(solution.components).length > 0 && !SolutionChangeType) {
			//Object.values(solution.components).forEach(async (comp) => {
			for(const comp of Object.values(solution.components)) {
			let componentMap =  new Map();
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							let componentMapattr = {};
							var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
								return obj.name === 'ChangeType'
							});
							Object.values(config.attributes).forEach((attr) => {
								if (changeTypeAtrtribute[0].value === 'Active' && attr.name !=='ChangeType' && attr.name !=='RedeemFund') {
									componentMapattr[attr.name] = [];
									componentMapattr[attr.name].push({'IsreadOnly':true});
								}
							});
							componentMap.set(config.guid,componentMapattr);
							if (config.relatedProductList && config.relatedProductList.length > 0){
								config.relatedProductList.forEach((relatedConfig) => {		
									if (relatedConfig.name.includes('Device')) {
										if ((relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !==undefined && relatedConfig.configuration.replacedConfigId !==null) && relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
											Object.values(relatedConfig.configuration.attributes).forEach((attr) => {
												if(attr.name !=='ChangeTypeDevice'&& attr.name !=='RedeemFund'){
												componentMapattr[attr.name] = [];
												componentMapattr[attr.name].push({'IsreadOnly':true});
												}
											});
											componentMap.set(relatedConfig.guid,componentMapattr);	
										}
									}
								});
							}
						});
					}
				}
				await CommonUtills.setAttributesReadonlyValue(ENTERPRISE_COMPONENTS.mobileSubscription,componentMap);
			//});
			}
		}
	}
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : calculate
 * Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
 * Invoked When: Device RP's MRO Bonus is updated, and
 * 				 Device RP is deleted.
**************************************************************************************/
async function EMPlugin_calculateDeviceEnrollEligibility(compName, parentConfig) {
	console.log('EMPlugin_calculateDeviceEnrollEligibility');
	let updateConfigMap = {};
	let DeviceEnroll = null;
	if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
		parentConfig.relatedProductList.forEach((relatedProduct) => {
			if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === 'Related Component') {
				Object.values(relatedProduct.configuration.attributes).forEach((attribute) => {
					if (attribute.name === 'InContractDeviceEnrollEligibility' && attribute.value) {
						DeviceEnroll = attribute.value;
					}
				});
			}
		});
	}
	updateConfigMap[parentConfig.guid] = [{
		name: 'InContractDeviceEnrollEligibility',
		// value: {
			value: DeviceEnroll,
			displayValue: DeviceEnroll
		// }
	}];
	//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap, true);
	//Spring 20
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
	let keys = Object.keys(updateConfigMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
	}
}
/**********************************
* Aditya                          03-Dec-2019          
* Populate the value of DataPackPlan of CMP to Mobile Subscription's DP Plan
*********************************/
EMPlugin_clonedataplanattributevalue = async function(parentValue) {
	var attrvalue = null;
	//CS.SM.getActiveSolution().then((product) => {
	// Spring 20
	let product = await CS.SM.getActiveSolution();
	if(parentValue === null && product.schema.configurations && Object.values(product.schema.configurations).length> 0 ){
		var datapackplan = Object.values(Object.values(product.schema.configurations)[0].attributes).filter(datapack =>{
			return datapack.name === 'DataPackAllowanceValue' && datapack.value
		});
		if(datapackplan.length >0 &&  datapackplan[0].value != null){
		attrvalue = datapackplan[0].value;
		}
	}
	else 
		attrvalue = parentValue;
	if (product.components) {
		Object.values(product.components).forEach(async (comp) => {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
				let updateMap = {};
				if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((cfg) => {
						Object.values(cfg.attributes).forEach((att) => {
							if (att.name === 'DP Plan' && parentValue != '' && att.value != parentValue) {
								updateMap[cfg.guid] = [{
									name: "DP Plan",
									// value: {
										value: attrvalue
									// }
								}]
							}
						});
					});
					// CS.SM.updateConfigurationAttribute(comp.name, updateMap, false);
					// Spring 20
					let keys = Object.keys(updateMap);
					for (let i = 0; i < keys.length; i++) {
						await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
					}
					updateComp = false;
				}
				return Promise.resolve(true);
			}
		});
	}
	//});
}
/*************************************************************************************
 * Author	: Venkata Ramanan G
 * Method Name : EMPlugin_showMDMtenancynotification
 * Defect/US # : EDGE-30181
 * Invoked When: Mobile Subscription configuration is added to the Mobile Subscription component
 * Description : Show Toast message about the MDM Tenancy
 * Parameters : N/A
 ***********************************************************************************/
function EMPlugin_showMDMtenancynotification(){
	if(!show){
		CS.SM.displayMessage('Please note that you may require MDM Tenancy to this order. If it is required please add it from Solutions', 'info');
		mdmvalidmobconfig = 0;
		show = true;
	}
}
/**************************************************************************************
 * Author	   : Li Tan
 * Method Name : EMPlugin_addAllowancesOEConfigs
 * Descriptoin : create Allowance NC Schema record from allowances linked to the selected plan
 * Invoked When: afterAttributeUpdated of 
 * 					- Select Plan attribute in Mobile Subscription
 * 					- OfferType attribute in Enterprice Mobility
**************************************************************************************/
async function EMPlugin_addAllowancesOEConfigs(compName, compGUID, schemaId, priceItemid, addOnPriceItemId) {
	console.log('EMPlugin_addAllowancesOEConfigs');
	console.log('compName', compName);
	console.log('compGUID', compGUID);
	console.log('schemaId', schemaId);
	console.log('priceItemid', priceItemid);
	console.log('addOnPriceItemId', addOnPriceItemId);
	let inputMap = {};
	if (priceItemid !== '') {
		inputMap['priceItemId'] = priceItemid;
	}
	if (addOnPriceItemId !== '') {
		inputMap['addOnPriceItemId'] = addOnPriceItemId;
	}
	let currentBasket = await CS.SM.getActiveBasket(); 
	await currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(async response => {                
		if (response && response['allowances'] != undefined) {
			console.log('allowances', response['allowances']);                
			aArray = [];
			response['allowances'].forEach((a) => {
				let aData = {};
				aData['name'] = a.cspmb__allowance__r.Name;
				aData['specId'] = a.cspmb__allowance__r.specId__c;
				aData['billingSpecId'] = a.cspmb__allowance__r.billingSpecId__c;
				aData['ocsProdId'] = a.cspmb__allowance__r.ocsProdId__c;
				aData['startDate'] = a.cspmb__allowance__r.startDate__c;
				aData['endDate'] = a.cspmb__allowance__r.endDate__c;
				aData['type'] = a.cspmb__allowance__r.type__c;
				aData['subType'] = a.cspmb__allowance__r.subType__c;
				aData['unitOfMeasure'] = a.cspmb__allowance__r.Unit_Of_Measure__c;
				aData['amount'] = a.cspmb__allowance__r.cspmb__amount__c;
				aArray.push(aData);
			})
			//CS.SM.addOrderEnrichments(compName, compGUID, schemaId, aArray);	 
			//Arinjay
			let currentSolution = await CS.SM.getActiveSolution();
			if (aArray.length > 0) {
				let map = [];
				for (let i = 0; i < aArray.length; i++) {
					let orderEnrichmentConfiguration = aArray[i].oeSchema.createConfiguration(map);
					let component = currentSolution.findComponentsByConfiguration(aArray[i].configGuid);
					await component.addOrderEnrichmentConfiguration(aArray[i].configGuid , orderEnrichmentConfiguration, false);
				}
			}
		} else {
			console.log('no response');
		}
	});
	return Promise.resolve(true);
}
function EMPlugin_toDate(dateStr) {
	var parts = dateStr.split("/")
	return new Date(parts[2], parts[1] - 1, parts[0]);
}
/*** add for edge-120132 ***/
/*
EMPlugin_onCustomAttributeEdit = async function(componentName,configurationGuid,attributeName){
	console.log('Inside customAttributeEdit Guid--->'+configurationGuid+'@@@@@'+componentName);
	var url= '';
	var vfRedirect = '';
	var solutionId = '';
	let inputMap = {};
	var solution=window.currentSolutionName;
	solutionName = 'Enterprise Mobility';
	var selectplan;
	var internationalDirectDialIn;
	configId=configurationGuid;
	var BussinessId_PI='';
	var BussinessId_Addon='';
	var EmChangeType='';//Added by Aman Soni as a part of EDGE-123593
	//await CS.SM.getActiveSolution().then((product) => {
	// Spring 20
	let currentSolution = await CS.SM.getActiveSolution();
	//solution = product;
	solutionId=currentSolution.solutionId;
	if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
		Object.values(currentSolution.components).forEach((comp) => {
			if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						if(config.guid === configurationGuid){
							if(config.attributes && Object.values(config.attributes).length>0){
								selectplan = Object.values(config.attributes).filter(a => {
									return a.name==='Select Plan' 
								});
								oldplan = Object.values(config.attributes).filter(a => {
									return a.name==='OldPlanTypeString' 
								});
								oldIdd = Object.values(config.attributes).filter(a => {
									return a.name==='OldIDD' 
								});
								initDate = Object.values(config.attributes).filter(a => {
									return a.name==='initialActivationDate' 
								});
								internationalDirectDialIn=Object.values(config.attributes).filter(a => {
									return a.name==='InternationalDirectDial' && a.value
								});
								BussinessId_PI = Object.values(config.attributes).filter(a => {
									return a.name==='BussinessId_PI'
								}); //Added by Aman Soni as a part of EDGE-123593 || Start
								EmChangeType = Object.values(config.attributes).filter(a => {
									return a.name==='ChangeType'
								}); //Added by Aman Soni as a part of EDGE-123593 || End
								BussinessId_Addon = Object.values(config.attributes).filter(a => {
									return a.name==='BussinessId_Addon'
								});
							}
						}								
					});
				}
			}
		});
	}
	//});
	var priceItemId='';
	var planName='';
	var addOnName='';
	//Added by Aman Soni as a part of EDGE-123593 || Start
	var oldPlanName='';
	var oldIddName='';
	var initialDate='';	
	var EmChangeTypeValue='';
	if(EmChangeType && EmChangeType[0]){
		EmChangeTypeValue=EmChangeType[0].value;
	}
	if(oldplan && oldplan[0]){
		oldPlanName=oldplan[0].value;
	}
	if(oldIdd && oldIdd[0]){
		oldIddName=oldIdd[0].value;
	}
	if(initDate && initDate[0]){
		initialDate=initDate[0].value;
	}
	console.log('oldPlanName-->'+oldPlanName+''+'oldIddName-->'+oldIddName);
	//Added by Aman Soni as a part of EDGE-123593 || End
	if(selectplan && selectplan[0]){
		priceItemId=selectplan[0].value;
		planName=selectplan[0].displayValue;
	}
	if(internationalDirectDialIn && internationalDirectDialIn[0]){
		//addonId=internationalDirectDialIn[0].value;
		addOnName=internationalDirectDialIn[0].displayValue;
	}
	console.log('priceItemId-->'+priceItemId);
	console.log('planName-->'+planName);
	//console.log('businessId-->'+businessId);
	var redirectURI = '/apex/';
	if (communitySiteId) {
		url = window.location.href;
		if (url.includes('partners.enterprise.telstra.com.au'))
			redirectURI = '/s/sfdcpage/%2Fapex%2F';
		else
			redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
	}
	url = redirectURI;
	console.log('@@@@attributeName--->'+attributeName);
	if(attributeName === 'viewDiscounts'){	
		if(communitySiteId){
			url='/partners/';
			url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId='+solutionId+'&accessMode=ReadOnly'+'&customAttribute='+attributeName+'&priceItemId='+priceItemId+'&configId='+configId+'&solutionName='+solutionName;
			vfRedirect ='<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="'+ url +'" style="" height="900px" width="820px"></iframe></div>';
			console.log('Url ---->',url);
		}
		else {			
			url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId='+solutionId+'&accessMode=ReadOnly'+'&customAttribute='+attributeName+'&priceItemId='+priceItemId+'&configId='+configId+'&solutionName='+solutionName;
			vfRedirect ='<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="'+ url +'" style="" height="500px" width="820px"></iframe></div>';
			console.log('Url ---->',url);	
		}
		//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="260px" width="820px"></iframe></div>';
		console.log('vfRedirect--->'+vfRedirect);	
	}
	if (attributeName === 'Price Schedule'){
		if(communitySiteId){
			url='/partners/';		
			url = url + 'c__PriceSchedulePage?configId='+configId + '&BussinessId_Addon=' +'&BussinessId_Addon='+'&BussinessId_PI=' +BussinessId_PI+'&planName='+planName+'&addOnName='+addOnName+'&EmChangeTypeValue='+EmChangeTypeValue+'&oldPlanName='+oldPlanName+'&oldIddName='+oldIddName+'&initialDate='+initialDate;//Added EmChangeTypeValue,oldPlanName,initialDate and oldIddName by Aman Soni as a part of EDGE-123593
			vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="900px" width="820px"></iframe></div>';
			console.log('Url ---->',url);
		}else{			
			url = url + 'c__PriceSchedulePage?configId='+configId + '&BussinessId_Addon=' +'&BussinessId_Addon='+'&BussinessId_PI=' +BussinessId_PI+'&planName='+planName+'&addOnName='+addOnName+'&EmChangeTypeValue='+EmChangeTypeValue+'&oldPlanName='+oldPlanName+'&oldIddName='+oldIddName+'&initialDate='+initialDate;//Added EmChangeTypeValue,oldPlanName and oldIddName by Aman Soni as a part of EDGE-123593
			vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="500px" width="820px"></iframe></div>';
			console.log('Url ---->',url);	
		}
		//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="260px" width="820px"></iframe></div>';
		console.log('vfRedirect--->'+vfRedirect);
	}
	return Promise.resolve(vfRedirect);	
}
*/
/**************************************************************************************
 * Author	   : Li Tan
 * Method Name : EMPlugin_calculateTotalMROBonus
 * Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
 * Invoked When: Device RP's MRO Bonus is updated, and
 * 				 Device RP is deleted.
**************************************************************************************/
async function EMPlugin_calculateTotalMROBonus(compName, parentConfig,relatedProduct) {	
	console.log('EMPlugin_CheckRedeemFundDiscount');
	let totalPlanBonus = 0;
	let updateConfigMap = {};
	Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'PlanShadowTCV', true);
	Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'IDDShadowTCV', true);
	// sum MROBonus of all related device
	if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === 'Related Component') {
			//Added As part of EDGE-123594 by end|| start
				var ChangeTypeDeviceAtrtribute = Object.values(relatedProduct.configuration.attributes).filter(obj => {
					return obj.name === 'ChangeTypeDevice'
				});
				var DeviceStatusAtrtribute = Object.values(relatedProduct.configuration.attributes).filter(obj => {
					return obj.name === 'DeviceStatus'
				});
				//Added As part of EDGE-123594|| End
				Object.values(relatedProduct.configuration.attributes).forEach((attribute) => {
					if (attribute.name === 'MROBonus' && attribute.value && ChangeTypeDeviceAtrtribute[0].value !=='PayOut' && DeviceStatusAtrtribute[0].value !=='PaidOut') {//Added conditions As part of EDGE-123594
						totalPlanBonus = parseFloat(totalPlanBonus) + parseFloat(attribute.value);
					}
				});
			}
			updateConfigMap[parentConfig.guid] = [{
				name: 'TotalPlanBonus',
				// value: {
					value: totalPlanBonus.toFixed(2),
					displayValue: totalPlanBonus.toFixed(2)
				// }													
			}];
	// update total plan bonus on parent config
	//CS.SM.updateConfigurationAttribute(compName, updateConfigMap, true);
	//Spring 20 
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(compName); 
	let keys = Object.keys(updateConfigMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false); 
	}
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-140967
 * Method Name : EMPlugin_CheckRedeemFundUpdate
 * Invoked When: RedeemFund Will be update on device
 * Description : Enabling Redemption as Discount for Device Payout on EM
 ***********************************************************************************************/
async function EMPlugin_CheckRedeemFundUpdate(guid) {
	var IsUpadateRequired=false;
	let updateMapFundonDevice = {}
	//await CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((subsConfig) => {
								let componentMapNew =   new Map();
								var ChangeTypeAttribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'ChangeType' 
								});
								var RedeemFundAttribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'RedeemFund' 
								});
								if(subsConfig.guid===guid){	
									if(ChangeTypeAttribute[0].value==='Cancel' && RedeemFundAttribute[0].value>0){
										subsConfig.relatedProductList.forEach((relatedConfig) => {
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
												IsUpadateRequired=true;
												updateMapFundonDevice[relatedConfig.guid] = [];
												updateMapFundonDevice[relatedConfig.guid] = [{
													name: 'RedeemFund',
													// value: {
														value: RedeemFundAttribute[0].value,
														displayValue: RedeemFundAttribute[0].value
													// }
												}];
											}
										});
									}	
								}
							});
						}
					}
				});
			}
		}
	}
	if(IsUpadateRequired && updateMapFundonDevice) {
		// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMapFundonDevice, true)
		// Spring 20
		let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
		let keys = Object.keys(updateMapFundonDevice);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMapFundonDevice[keys[i]], false); 
		}
	}
	//});
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-140967
 * Method Name : EMPlugin_CheckRedeemFundDiscount
 * Invoked When: RedeemFund Will be change or Change Type on Device or Change Type on Mobile device will change.
 * Description : Enabling Redemption as Discount for Device Payout on EM
 ***********************************************************************************************/
async function EMPlugin_CheckRedeemFundDiscount(guid) {
	console.log('EMPlugin_CheckRedeemFundDiscount');
	var IsUpadateSubOnly=false;
	let updateMapFund =  new Map();
	let componentMapNew =   new Map();
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution(); // Spring 20
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
								IsUpadateSubOnly=false;
								var IsUpdateAttribute = false;
								var ChangeTypeAttribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'ChangeType' 
								});
								var RedeemFundAttribute = Object.values(subsConfig.attributes).filter(obj => {
										return obj.name === 'RedeemFund' 
								});
								if(subsConfig.guid===guid){	
									IsUpadateSubOnly=true;
									if(ChangeTypeAttribute[0].value==='Cancel' && RedeemFundAttribute[0].value>0){
										IsUpdateAttribute=true;	
									}
								}
								else if(ChangeTypeAttribute[0].value==='Modify'){
									if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
										subsConfig.relatedProductList.forEach((relatedConfig) => {
											if(relatedConfig.guid===guid){	
												IsUpadateSubOnly=true;
												if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === 'Related Component') {
													if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
														var ChangeTypeDeviceAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name === 'ChangeTypeDevice' 
														});
														var RedeemFundDeviceAttribute = Object.values(relatedConfig.configuration.attributes).filter(obj => {
															return obj.name === 'RedeemFund' 
														});
														if(ChangeTypeDeviceAttribute[0].value==='PayOut' && RedeemFundDeviceAttribute[0].value>0){
															IsUpdateAttribute=true;	
														}
													}
												}
											}
										});
									}
								}
								if(IsUpdateAttribute){
									componentMapNew.set('IsRedeemFundCheckNeeded',true);
									//CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false, 'Please Click on "Generate Net Price" to update pricing of items in the basket');
									// Spring 20
									let cnfg = await comp.getConfiguration(subsConfig.guid); 
									//cnfg.status = false;
									//cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
								}else if(IsUpadateSubOnly) {
									componentMapNew.set('IsRedeemFundCheckNeeded',false);
									//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription, subsConfig.guid, true);
									// Spring 20
									let cnfg = await comp.getConfiguration(subsConfig.guid); 
									cnfg.status = true;
								}
								if(componentMapNew && Object.values(componentMapNew).length>0){
									updateMapFund.set(subsConfig.guid,componentMapNew);	
								}											
							});	
						}
						if(updateMapFund)
							CommonUtills.UpdateValueForSolution(ENTERPRISE_COMPONENTS.mobileSubscription,updateMapFund);
					}
				});
			}
		}
	}
	//});
}
/**************************************************************************************
 * Author	   : Ankit
 * Method Name : calculate
 * Edge Number 	: EDGE-132203
 * Description : Showing error For device
 * Invoked When: While invoking
**************************************************************************************/
function EMPlugin_CheckErrorsOnSolution(solution) {
	//console.log('EMPlugin_CheckErrorsOnSolution');
	let IsUpdateStatus = false;
	//CS.SM.getActiveSolution().then((solution) => {
	//let solution = await CS.SM.getActiveSolution(); // Spring 20
	if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			let setChangeType = '';
			let updateMapDevice = {};
			isCommittedDataOffer = false;
			if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
				Object.values(solution.schema.configurations).forEach((config) => {			
					Object.values(config.attributes).forEach((configAttr) => {
						if (configAttr.name === 'OfferType' && configAttr.displayValue==='Committed Data') {
							//console.log ('Inside  Updating CommittedDataOffer ');
							isCommittedDataOffer = true;
						}
					});
				});
				Object.values(solution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							var isRelatedDeviceAdded = false;
							var isRelatedDevicePayout = false;
							Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
								let OfferTypeAttribute = Object.values(subsConfig.attributes).filter(obj => {
									return obj.name === 'OfferTypeString'; 
								});
								let SelectPlanNameAttribute = Object.values(subsConfig.attributes).filter(obj => {
									return obj.name === 'SelectPlanName';
								});
								let changeTypeDisplayValue = '';
								let selectPlanDisplayValue = '';
								let IsDiscountCheckNeededval='';
								isRelatedDeviceAdded = false;
								isRelatedDevicePayout=false;
								Object.values(subsConfig.attributes).forEach((attr) => {
									if(attr.name === 'ChangeType' && attr.value !== 'Active'){
										changeTypeDisplayValue=attr.displayValue ;
									}
									if (attr.name === 'Select Plan' && attr.value !== '') {
										selectPlanDisplayValue =attr.displayValue ;
									}
									if(attr.name === 'IsDiscountCheckNeeded'){
										IsDiscountCheckNeededval=attr.value;
               						 }
								});
								if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
									subsConfig.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === 'Related Component') {
											isRelatedDeviceAdded = true;
										}
										//console.log('isRelatedDeviceAdded:::::'+isRelatedDeviceAdded);
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
											Object.values(relatedConfig.configuration.attributes).forEach((ChangeTypeAttribute) => {
												if(ChangeTypeAttribute.name==='ChangeTypeDevice' && ChangeTypeAttribute.value==='PayOut'){
													isRelatedDevicePayout=true;
												}
											});
										}
									});
								}
								//INC000093772606 added by shubhi----------------------
								if(subsConfig.replacedConfigId && subsConfig.disabled){
									let activeSolutionUp = await CS.SM.getActiveSolution();
									let componentUp = await activeSolutionUp.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
									let cnfg = await componentUp.getConfiguration(subsConfig.guid); 
									cnfg.status = true;
									cnfg.statusMessage =''; 
								}//INC000093772606 added by shubhi end----------------------
								else if (!selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === false && isCommittedDataOffer === false){
									//console.log('Inside selectPlanDisplayValue Validation  ');
									IsUpdateStatus=true;
									// CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please add One mobile Device.');
									// Spring 20
										let activeSolutionNew = await CS.SM.getActiveSolution();
										let component1New = await activeSolutionNew.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); // added by ankit/shubhi for Edge -EDGE-169319
										let cnfg = await component1New.getConfiguration(subsConfig.guid); 
										cnfg.status = false;
										cnfg.statusMessage = 'Please add One mobile Device.';
									}else if (selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false){
										IsUpdateStatus=true;
										//console.log('Inside selectPlanDisplayValue Validation  ');
										//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription,subsConfig.guid,false,'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.');
										let activeSolutionUp = await CS.SM.getActiveSolution();
										let componentUp = await activeSolutionUp.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
										let cnfg = await componentUp.getConfiguration(subsConfig.guid); 
										cnfg.status = false;
										cnfg.statusMessage = 'Please remove the added mobile device because BYO plan does not allow purchase of mobile device.';
									}else if(IsDiscountCheckNeededval==='true'|| IsDiscountCheckNeededval===true){ //added by shubhi 14/08
										IsUpdateStatus=true;
										let activeSolutionUp = await CS.SM.getActiveSolution();
										let componentUp = await activeSolutionUp.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
										let cnfg = await componentUp.getConfiguration(subsConfig.guid);                     				 	
										cnfg.status = false;
										cnfg.statusMessage ='Please Click on "Generate Net Price" to update pricing of items in the basket';
                                    }else{
                                        let activeSolutionUp = await CS.SM.getActiveSolution();
										let componentUp = await activeSolutionUp.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
										let cnfg = await componentUp.getConfiguration(subsConfig.guid); 
										cnfg.status = true;
                                        cnfg.statusMessage =''; 
									}
										//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMapsubs, true);
								});
								}
							}
						});
					}
			}
		}
		//});
		//console.log('EMPlugin_CheckErrorsOnSolution : returning IsUpdateStatus as ',IsUpdateStatus);
		return  IsUpdateStatus;
	}
// Added by Aman Soni as a part of EDGE-123593
async function EMPlugin_updatePricescheduleCheck(guid) {
	console.log('EMPlugin_updatePricescheduleCheck');
	var componentMap = {};
	//CS.SM.getActiveSolution().then((solution) => {
	let solution = await CS.SM.getActiveSolution();
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (config) => {
						if(config.guid===guid){
							var cta = Object.values(config.attributes).filter(a => {
								return a.name === 'ChangeType'
							});
							var OldPlanType = Object.values(config.attributes).filter(a => {
								return a.name === 'OldPlanTypeString'
							});
							var OldDataPack = Object.values(config.attributes).filter(a => {
								return a.name === 'OldDataPackPlan'
							});
							var OldIDDString = Object.values(config.attributes).filter(a => {
								return a.name === 'OldIDD'
							});
							var NewIDD = Object.values(config.attributes).filter(a => {
								return a.name === 'InternationalDirectDial'
							});
							var SelectPlan = Object.values(config.attributes).filter(a => {
								return a.name === 'Select Plan'
							});
							var DPPlan = Object.values(config.attributes).filter(a => {
								return a.name === 'DP Plan'
							});
							if(cta[0].value==='Modify' && (OldPlanType[0].value !== SelectPlan[0].displayValue || OldIDDString[0].value !==NewIDD[0].displayValue || DPPlan[0].value !==OldDataPack[0].value)){
								pricingUtils.resetDiscountAttributes(ENTERPRISE_COMPONENTS.mobileSubscription);
								//CS.SM.updateConfigurationStatus(ENTERPRISE_COMPONENTS.mobileSubscription, guid, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
								// Spring 20
								let cnfg = await comp.getConfiguration(guid); 
								//cnfg.status = false;
								//cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
							}
						}
					});
				}
			});
		}
	}
	//});
}
async function EMPlugin_updatePlanDiscount(parentConfig,planRecord,deviceRecord){
	let inputMap2 = {};
	inputMap2['planRecord'] = planRecord;
	inputMap2['deviceRecord'] = deviceRecord;
	let discountRecId = null;
	let discountValue = null;
	//Laxmi Added Business ID for Device Type EDGE-127421
	let businessIDDeviceType = null;
	console.log('EMPlugin_updatePlanDiscount::::',inputMap2);
	let currentBasket = await CS.SM.getActiveBasket(); 
	await currentBasket.performRemoteAction('MobileSubscriptionGetDiscountData', inputMap2).then(async response => {   
	console.log('response EMPlugin_updatePlanDiscount', response);										
		if (response && response['planDiscountList'] != undefined) {
			console.log('planDiscountList', response['planDiscountList']);
			response['planDiscountList'].forEach((a) => {
				if(a.Id != null){
					discountRecId = a.Id;
					discountValue = a.Recurring_Charge__c;
					businessIDDeviceType = a.DiscountChargeID__c; // Added for EDGE-127421
				}
			});
			console.log('discountRecId ', discountRecId);
			if(discountRecId!= ''){
				let updateConfigMap2 = {};
				updateConfigMap2[parentConfig.guid] = [{
					name: 'PlanDiscountLookup',
					// value: {
						value: discountRecId,
						displayValue: discountValue
					// }														
				},
				{
					name: 'TotalPlanBonus',
					// value: {
						value: discountValue.toFixed(2),
						displayValue: discountValue.toFixed(2)
					// }		
				},
								//Laxmi - EDGE-127421 Added to Map deviceTypeBusinessID - value to be displaed coming from map
				{
					name: 'deviceTypeBusinessID',
					// value: {
						value: businessIDDeviceType,
						displayValue: businessIDDeviceType
					// }														
				}//Laxmi Changes ENd
				];
				console.log('updateConfigurationAttribute PlanDiscountLookup');
				//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateConfigMap2, true);
				//Spring 20
				let solution = await CS.SM.getActiveSolution();
				let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
				let keys = Object.keys(updateConfigMap2);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); 
				}
			}
		} else { 	 	  
			console.log('no response');
		}
	});
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-134880
 * Method Name : EMPlugin_CancelledCLIRemoteAction
 * Invoked When: Plan or IDD Will change
 * Description : Set TCV as previous config
 ***********************************************************************************************/
async function EMPlugin_CancelledCLIRemoteAction(inputMapCLI,componentMap) {
    var updateMap = {};
		console.log('EMPlugin_CancelledCLIRemoteAction: ', inputMapCLI);
		var avgDiscountedPricePlan;
		var avgDiscountedPriceAddon;
		let currentBasket; 
		currentBasket = await CS.SM.getActiveBasket(); 
		await currentBasket.performRemoteAction('SolutionHelperCancelledCLI', inputMapCLI).then(values =>  {
		// Spring 20
		// await CS.SM.WebService.performRemoteAction('SolutionHelperCancelledCLI', inputMapCLI).then(values => {
			console.log('EMPlugin_CancelledCLIRemoteAction result:', values);
			if (values['avgDiscountedPricePlan'])
				avgDiscountedPricePlan = values['avgDiscountedPricePlan'];
			if(values['avgDiscountedPriceAddon'])
				avgDiscountedPriceAddon =values['avgDiscountedPriceAddon'];
		});
		console.log ('EMPlugin_CancelledCLIRemoteAction statuses;', avgDiscountedPricePlan,':::',avgDiscountedPriceAddon);
		if (avgDiscountedPricePlan) {
			Object.keys(componentMap).forEach(async comp => {
				componentMap[comp].forEach(element => {
					updateMap[element.guid] =[{
					name: 'PlanShadowTCV',
						// value: {
							value: avgDiscountedPricePlan,
							displayValue: avgDiscountedPricePlan
						// }
					},{
					name: 'IDDShadowTCV',
						// value: {
							value: avgDiscountedPriceAddon,
							displayValue: avgDiscountedPriceAddon
						// }
					}];
				});
				console.log('EMPlugin_checkConfigurationSubscriptionsForEM update map', updateMap);
				//CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
				// Spring 20
				let keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
					await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
				}
			});
		}
	return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-134880
 * Method Name : EMPlugin_CancelledCLIRemoteAction
 * Invoked When: Plan or IDD Will change
 * Description : Set TCV as previous config
 ***********************************************************************************************/
async function EMPlugin_CancelledCLI(inputMapCLI) {
	console.log('EMPlugin_CancelledCLI::::::::');
	var componentMap = {};
	//await CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (solution && /*solution.type &&*/  solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
						var cta = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType' 
						});
						var OldPlanType = Object.values(config.attributes).filter(a => {
							return a.name === 'OldPlanTypeString' 
						});
						var OldDataPack = Object.values(config.attributes).filter(a => {
							return a.name === 'OldDataPackPlan' 
						});
						var OldIDDString = Object.values(config.attributes).filter(a => {
							return a.name === 'OldIDD' 
						});
						var NewIDD = Object.values(config.attributes).filter(a => {
							return a.name === 'InternationalDirectDial' 
						});
						var SelectPlan = Object.values(config.attributes).filter(a => {
							return a.name === 'Select Plan' 
						});
						var DPPlan = Object.values(config.attributes).filter(a => {
							return a.name === 'DP Plan' 
						});
						if(cta[0].value==='Modify' && ((OldPlanType[0].value === SelectPlan[0].displayValue && OldIDDString[0].value ===NewIDD[0].displayValue) || DPPlan[0].value !==OldDataPack[0].value)){
							if (!componentMap[comp.name])
								componentMap[comp.name] = [];
							if(config.replacedConfigId)
							componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid}); 
							EMPlugin_CancelledCLIRemoteAction(inputMapCLI,componentMap);
						}
					});
				}
			});
		}
	}
	//});
}
/***********************************************************************************************
 * Author	   : Laxmi Rahate
 * EDGE		   : EDGE-142321
 * Method Name : EMPlugin_resetDeliveryDetailsinOESchema
 * Invoked When: Solution is Loaded
 * Description : Handling Port out reversal scenarios
 ***********************************************************************************************/
async function EMPlugin_resetDeliveryDetailsinOESchema(){
	console.log('@@@@@@@@Inside EMPlugin_resetDeliveryDetailsinOESchema');
	var updateMap={};//EDGE-147799
	let product = await CS.SM.getActiveSolution(); // Spring 20
	//await CS.SM.getActiveSolution().then((product) => {
	if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if(comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){		
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						//if(comp.schema.changeType==='Change Request'){
						Object.values(comp.schema.configurations).forEach(async (config) => {								
							if (!updateMap[config.guid]) //EDGE-147799
								updateMap[config.guid] = []; //EDGE-147799
							if(!config.disabled){
								var shippingRequired = Object.values(config.attributes).filter(att =>{
									return att.name === 'ShippingRequired' 
								});
								var deviceShipping  = Object.values(config.attributes).filter(att =>{
									return att.name === 'DeviceShipping' 
								});
								var shippingRequiredVal = shippingRequired[0].value;
								var deviceShippingVal = deviceShipping[0].value;
								//EDGE-147799 - Bulk OE implementation changes - laxmi 
								if (basketStage === 'Commercial Configuration' || basketStage === 'Draft') {
									if(shippingRequiredVal === 'TRUE' || deviceShippingVal === 'TRUE'  ) {
										console.log ( 'Either flag is true - Delivery is needed' ); 
										updateMap[config.guid].push({
											name: 'isDeliveryEnrichmentNeededAtt',
											value:  true
										});
										updateMap[config.guid].push({
											name: 'isDeliveryDetailsRequired',
											value:  true
										});
										needsUpdate=true;
									}else{
										console.log ( 'Flags are false - Delivery is NOT needeed' ); 
										updateMap[config.guid].push({
											name: 'isDeliveryDetailsRequired',
											value: false
										});
										//EDGE-147597 added by ankit || start
										updateMap[config.guid].push({
											name: 'isDeliveryEnrichmentNeededAtt',
											value:  false
										});
										//EDGE-147597 added by ankit || End
										needsUpdate=true;
									}
								}//End contract Accepted check
								// //EDGE-147799 Changes END									
								var updateMapNew = {};
								if (config.orderEnrichmentList) {
									config.orderEnrichmentList.forEach((oe) => {
										//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
										if (!updateMapNew[oe.guid])
											updateMapNew[oe.guid] = [];
											if (shippingRequiredVal === 'FALSE' &&  deviceShippingVal === 'FALSE')	{
												console.log( 'Both Attribute Values are FALSE, made OE DeliveryDetails Optional' );
												updateMapNew[oe.guid].push({name: 'DeliveryContact', required: false},{name: 'DeliveryAddress', required: false});
											}else
												console.log( 'DeliveryAddress OE Isnt Optional' );
									});
								}
								if(updateMapNew)
								{
									//CS.SM.updateOEConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, config.guid, updateMapNew, true);
									// Spring 20
									let keys = Object.keys(updateMapNew);
									for(let h=0; h< updateMapNew.length;h++){
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
									}
								}
								if(updateMap) {
									//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true);	 //EDGE-147799							
									// Spring 20
									let keys = Object.keys(updateMap);
									for(let h=0; h< updateMap.length;h++){
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],true)
									}
								}
							}
						});
					}
				}
			});
		}
	}
	//});
}
/**
 * Author      : Laxmi  2020-04-29
 * Ticket      : EDGE-142321
 * Description : Handle DeviceSHipping Attribute
 */
EMPlugin_handleDeviceShipping = function(solution) {
    console.log('EMPlugin_handleDeviceShipping');
     var doUpdate = false;
     var updateMap = [];
    if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) ){
        if (solution.components && Object.values(solution.components).length > 0) {
            Object.values(solution.components).forEach(async (comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							var changeTypeValue = '';
							var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
								return ChangeType.name === 'ChangeType' 
							});	
							changeTypeValue = ChangeType[0].value;
							console.log('MACD basket');
							var readonly = false;
							// EDGE-131531 - Added one more Status as  'Provisioning In Progress'
							//if ((config.id && changeTypeValue === 'Modify')   || (config.id && changeTypeValue === 'Active' ) ){
							if (window.BasketChange === 'Change Solution' ){ // EDGE-147799 Changed the check as this wasnt getting called earlier
								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
										if(relatedConfig.configuration.replacedConfigId !=undefined || relatedConfig.configuration.replacedConfigId !=null){
											console.log ( 'Replaced COnfig available for config id '  +relatedConfig.guid + 'Changing Shipping Required to False for this Config'  );
											if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
												doUpdate = true;
												if (!updateMap[relatedConfig.guid])
												updateMap[relatedConfig.guid] = [];
													updateMap[relatedConfig.guid].push({
													name: 'DeviceShipping',
													// value: {
														value: 'FALSE'
													// }
												});
											}
										}	
									});
								}
							} 
						});
					}
					if (doUpdate){
						console.log('EMPlugin_handleDeviceShipping', updateMap);
						//CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
						//Spring 20
						//let component = await solution.getComponentByName(comp.name); 
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
						}
					}			
				}
            });
		}
	}
}//ENd Method
/***********************************************************************************************
 * Author	   : Laxmi Rahate
 * EDGE		   : EDGE-142321
 * Method Name : EMPlugin_handlePortOutReversal
 * Invoked When: Solution is Loaded
 * Description : Handling Port out reversal scenarios
 ***********************************************************************************************/
async function EMPlugin_handlePortOutReversal() {
	console.log('EMPlugin_handlePortOutReversal');
	var updateMap = {};
	var deviceShippingVal = '';
	var isPortOutReversal = false;
	var mobSubDeviceShipping = 'FALSE';
	var shippingRequired = 'TRUE';
	var existingSIM ;
	var showPortOutinUI;
	//await CS.SM.getActiveSolution().then((solution) => {
	//Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if(!config.disabled){
								deviceShippingVal = '';
								mobSubDeviceShipping = 'FALSE';
								var changeTypeValue = '';
								var existingSIMVar = '';
								var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
									return ChangeType.name === 'ChangeType' 
								});	
								existingSIM = Object.values(config.attributes).filter(attribute =>{
									return attribute.name === 'UseExitingSIM' 
								});	
								if(existingSIM.length >0 &&  existingSIM[0].value && existingSIM[0].value != null){
									existingSIMVar=existingSIM[0].value;
								}									
								changeTypeValue = ChangeType[0].value;
								updateMap[config.guid] = [];
								if(window.BasketChange === 'Change Solution' && changeTypeValue ==='New' && config.replacedConfigId){
									isPortOutReversal = false;
									shippingRequired = 'FALSE';
								}
								if (changeTypeValue === 'Active' || changeTypeValue === 'Modify'){
									isPortOutReversal = false;
									shippingRequired = 'FALSE';
								}else{
									isPortOutReversal = hasPortOutReversalPermission;
									//if (existingSIMVar){ // removed === from check
									if ( existingSIMVar === true ||  existingSIMVar === 'true') { //EDGE-151380  Fix
										shippingRequired =  'FALSE';
										console.log( 'Shipping Required Value is TRUE!!!!!!!!!!!!!' );
									}
									else
									shippingRequired = 'TRUE';
								}
								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
											Object.values(relatedConfig.configuration.attributes).forEach((deviceAttribute) => {
												if(deviceAttribute.name==='DeviceShipping'){
													deviceShippingVal=deviceAttribute.value;
													console.log ('&&&&&&&&&&&&&&&DeviceSHippingvalue is - &&&&&&&&&&&&' + deviceShippingVal);
													if (deviceShippingVal==='TRUE'){
														mobSubDeviceShipping = 'TRUE';
													}
												}
											});
										}
									});
								}	
								console.log( 'isPortOutReversal --------------------------value is '+isPortOutReversal);
									if (isPortOutReversal) {
										updateMap[config.guid].push ({
											name: 'UseExitingSIM',
											// value: {
												showInUi:true,
												readOnly:false
											// }
										}); 
										updateMap[config.guid].push({
											name: 'isPortOutReversal',
											// value: {
												value: true,
												showInUi:isPortOutReversal,
												readOnly:true
											// }
										}); 						
									}
									else//Either not a portout reversa righst available or its Modify Config
									{
										updateMap[config.guid].push ({
										name: 'UseExitingSIM',
										// value: {
											showInUi:false,
											readOnly:false
										// }
									}); 
									updateMap[config.guid].push({
										name: 'isPortOutReversal',
										// value: {
											value: false,
											showInUi: false,
											readOnly:false
										// }
									}); 
								}
								updateMap[config.guid].push({
								name: 'ShippingRequired',
								// value: {
									value: shippingRequired,
									readOnly:true
								// }
								}); 	
								updateMap[config.guid].push ({
									name: 'DeviceShipping',
									// value: {
										readOnly:true,
										value:mobSubDeviceShipping
									// }
								});
								// if basket stage is Contract Accepted make the attrbute ReadOnly
								if (basketStage === 'Contract Accepted' ){
									console.log ( 'Bakset stage is COntract Accepted!!!!!!!!making attributes readonly' );
									updateMap[config.guid].push ({
									name: 'UseExitingSIM',
									// value: {
										showInUi:isPortOutReversal,
										readOnly:true
									// }
									}); 
									if (isPortOutReversal)
									{
										updateMap[config.guid].push({
											name: 'isPortOutReversal',
											// value: {
												value: true,
												showInUi:isPortOutReversal,
												readOnly:true
											// }
										}); 
									}
								}
							}
						});
				}
			});
		}
	}
	//});
	if (updateMap) {
		console.log('EMPlugin_handlePortOutReversal update map', updateMap);
		//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
		let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
		if(component && component !=null && component != undefined) {
			let keys = Object.keys(updateMap);
			var complock = component.commercialLock;
			// if(complock) component.lock('Commercial', false);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
			}
			//if(complock) component.lock('Commercial', true);
		}
	}
	return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Laxmi Rahate
 * EDGE		   : EDGE-142321
 * Method Name : handleDevice
 * Invoked When: Solution is Loaded
 * Description : EMPlugin_handleDeviceStatusAndPlanDiscount
 ***********************************************************************************************/
async function EMPlugin_handleDeviceStatusAndPlanDiscount(guid) {
	console.log('EMPlugin_handleDeviceStatusAndPlanDiscount');
	var updateMap = {};
	var blankOutPlanDiscount = true;
	var deviceStatusVal = '';
	let solution = await CS.SM.getActiveSolution();
	//await CS.SM.getActiveSolution().then((solution) => {
	// Spring 20
	if (solution && /*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					Object.values(comp.schema.configurations).forEach((config) => {
						if (config.guid === guid ){
							var changeTypeValue = '';
							var deviceStatus = '';
							var deviceStatusVal = '';
							var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
								return ChangeType.name === 'ChangeType' 
							});	
							changeTypeValue = ChangeType[0].value;
							updateMap[config.guid] = [];
							if (config.id && changeTypeValue === 'Modify' ){
								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
									if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
										Object.values(relatedConfig.configuration.attributes).forEach((deviceAttribute) => {
											if(deviceAttribute.name==='DeviceStatus'){
												deviceStatusVal=deviceAttribute.value;
												console.log ('&&&&&&&&&&&&&&&deviceStatusVal is - &&&&&&&&&&&&' + deviceStatusVal);
												if (deviceStatusVal!=='PaidOut'){
													blankOutPlanDiscount = false;
												}
											}
										});
									}
							});
						}	
						if (blankOutPlanDiscount) {
							updateMap[config.guid].push ({
							name: 'TotalPlanBonus',
							// value: {
								value:0,
								displayValue:0
							// }
						}); 
						}
							}
						}
					});
				}
			});
		}
	}
	//});
	if (updateMap) {
		console.log('EMPlugin_handleDeviceStatusAndPlanDiscount update map', updateMap);
		// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true).then(component => console.log('EMPlugin_handleDeviceStatusAndPlanDiscount Attribute Update', component));
		// Spring 20
		let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
		}
	}
	return Promise.resolve(true);
}
/* 	
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function EMPlugin_updateSolutionNameEM() {
	var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
	var listOfAttrToGetDispValues = ['OfferName','OfferType'], attrValuesMap2 = {};
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,ENTERPRISE_COMPONENTS.enterpriseMobility);
	attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues,ENTERPRISE_COMPONENTS.enterpriseMobility);
	console.log('attrValuesMap...'+attrValuesMap);
	if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_EM){
		let updateConfigMap = {};
		updateConfigMap[attrValuesMap['GUID']] = [{
			name: 'Solution Name',
			// value: {
			value: attrValuesMap2['OfferName']+'_'+attrValuesMap2['OfferType'],
			displayValue: attrValuesMap2['OfferName']+'_'+attrValuesMap2['OfferType']
			// }													
		}];
		if(updateConfigMap){
			// CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateConfigMap, true);	
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility); 
			let keys = Object.keys(updateConfigMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
            }
		}
	}		
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-169973
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId


 ***********************************************************************************************/
async function EMPlugin_UpdateRelatedConfigForChild() {
	let loadedSolution = await CS.SM.getActiveSolution();
	if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			let currentBasket =  await CS.SM.getActiveBasket(); 
			window.currentSolutionName = loadedSolution.name;
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				Object.values(loadedSolution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
								if (subsConfig.disabled== false && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
										subsConfig.relatedProductList.forEach(async (relatedConfig) => {
											let inputMap = {};
											inputMap['GetConfigurationId'] = relatedConfig.guid;
											inputMap['basketId'] = basketId;
											await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
												var replaceId = result["replacedConfigid"];
                    							var configGuid = result["childGuid"];
												var relatedConfigId = result["childId"];
                    							if(configGuid===relatedConfig.guid)
												relatedConfig.configuration.replacedConfigId=replaceId;
												relatedConfig.configuration.id=relatedConfigId;
											});
										});
								}
							});
						}
					}
				});
			}
			return Promise.resolve(true);
	}	
}
/***********************************************************************************************
 * Author	   : Shubhi Vijayvergia
 * EDGE number : EDGE-169973
 * Method Name : EMPlugin_UpdateRelatedConfigForChild()
 * Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId


 ***********************************************************************************************/
async function EMPlugin_UpdateRelatedConfigForChildMac(guid) {
	let loadedSolution = await CS.SM.getActiveSolution();
	if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
			let currentBasket =  await CS.SM.getActiveBasket(); 
			window.currentSolutionName = loadedSolution.name;
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				Object.values(loadedSolution.components).forEach((comp) => {
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
								if (subsConfig.disabled== false && guid==subsConfig.guid && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
										subsConfig.relatedProductList.forEach(async (relatedConfig) => {
											let inputMap = {};
											inputMap['GetConfigurationId'] = relatedConfig.guid;
											inputMap['basketId'] = basketId;
											await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
												var replaceId = result["replacedConfigid"];
                    							var configGuid = result["childGuid"];
												var relatedConfigId = result["childId"];
                    							if(configGuid===relatedConfig.guid)
												relatedConfig.configuration.replacedConfigId=replaceId;
												relatedConfig.configuration.id=relatedConfigId;
											});


										});
								}
							});
						}
					}
				});
			}
			return Promise.resolve(true);
	}	
}
/***********************************************************************************************
 * Author	   : Ankit Goswami
 * EDGE number : EDGE-169973
 * Method Name : EMPlugin_ChangeOptionValue()
 * Invoked When: After attribute changes
 * Description : Update Replace ConfigId


 ***********************************************************************************************/
async function EMPlugin_ChangeOptionValue(guid) {	
	var updateMap = {};
	 var optionValues = [];
		optionValues = [
            "Modify", "Cancel"
        ];
	let loadedSolution = await CS.SM.getActiveSolution();
	if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		window.currentSolutionName = loadedSolution.name;
		if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
			Object.values(loadedSolution.components).forEach((comp) => {
				if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
							if(subsConfig.guid===guid){
								updateMap[subsConfig.guid]=[{
									name: 'ChangeType',
									options: optionValues
								}];
							}	
						});
					}
					let keys = Object.keys(updateMap);
					var complock = comp.commercialLock;
					if(complock) comp.lock('Commercial', false);
					for (let i = 0; i < keys.length; i++) {
						comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					}
					if(complock) comp.lock('Commercial', true);
				}


			});
		}
		return Promise.resolve(true);
	}
}
/*********************** added by shubhi EDGE-169973 ********************/
async function handlePortOutReversalForIndvConf(guid) {
	////console.log('handlePortOutReversal');
	console.log('EMPlugin_handlePortOutReversal');


	var updateMap = {};
	var deviceShippingVal = '';
	var isPortOutReversal = false;
	var mobSubDeviceShipping = 'FALSE';
	var shippingRequired = 'TRUE';
	var existingSIM ;
	var showPortOutinUI;
	//await CS.SM.getActiveSolution().then((solution) => {
	//Spring 20
	let solution = await CS.SM.getActiveSolution();
	if (/*solution.type &&*/ solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach((comp) => {
				if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) &&
					comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						Object.values(comp.schema.configurations).forEach((config) => {
							if(!config.disabled && guid===config.guid){
								deviceShippingVal = '';
								mobSubDeviceShipping = 'FALSE';
								var changeTypeValue = '';
								var existingSIMVar = '';
								var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
									return ChangeType.name === 'ChangeType' 
								});	
								existingSIM = Object.values(config.attributes).filter(attribute =>{
									return attribute.name === 'UseExitingSIM' 
								});	
								if(existingSIM.length >0 &&  existingSIM[0].value && existingSIM[0].value != null){
									existingSIMVar=existingSIM[0].value;
								}									
								changeTypeValue = ChangeType[0].value;
								updateMap[config.guid] = [];
								if(window.BasketChange === 'Change Solution' && changeTypeValue ==='New' && config.replacedConfigId){
									isPortOutReversal = false;
									shippingRequired = 'FALSE';
								}
								if (changeTypeValue === 'Active' || changeTypeValue === 'Modify'){
									isPortOutReversal = false;
									shippingRequired = 'FALSE';
								}else{
									isPortOutReversal = hasPortOutReversalPermission;
									//if (existingSIMVar){ // removed === from check
									if ( existingSIMVar === true ||  existingSIMVar === 'true') { //EDGE-151380  Fix
										shippingRequired =  'FALSE';

										console.log( 'Shipping Required Value is TRUE!!!!!!!!!!!!!' );
									}
									else
									shippingRequired = 'TRUE';
								}

								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
											Object.values(relatedConfig.configuration.attributes).forEach((deviceAttribute) => {
												if(deviceAttribute.name==='DeviceShipping'){
													deviceShippingVal=deviceAttribute.value;

												//console.log ('&&&&&&&&&&&&&&&DeviceSHippingvalue is - &&&&&&&&&&&&' + deviceShippingVal);

													if (deviceShippingVal==='TRUE'){
														mobSubDeviceShipping = 'TRUE';
													}
												}
											});
										}
									});
								}	

						//console.log( 'isPortOutReversal --------------------------value is '+isPortOutReversal);

									if (isPortOutReversal) {
										updateMap[config.guid].push ({
											name: 'UseExitingSIM',
											// value: {
												showInUi:true,
												readOnly:false
											// }
										}); 

										updateMap[config.guid].push({
											name: 'isPortOutReversal',
											// value: {
												value: true,
												showInUi:isPortOutReversal,
												readOnly:true
											// }
										}); 						
									}
									else//Either not a portout reversa righst available or its Modify Config
									{
										updateMap[config.guid].push ({
										name: 'UseExitingSIM',
										// value: {
											showInUi:false,
											readOnly:false

										// }
									}); 

									updateMap[config.guid].push({
										name: 'isPortOutReversal',
										// value: {
											value: false,
											showInUi: false,
											readOnly:false

										// }
									}); 
								}

								updateMap[config.guid].push({
								name: 'ShippingRequired',
								// value: {
									value: shippingRequired,
									readOnly:true
								// }
								}); 	
								updateMap[config.guid].push ({
									name: 'DeviceShipping',
									// value: {
										readOnly:true,
										value:mobSubDeviceShipping
									// }
								});


								// if basket stage is Contract Accepted make the attrbute ReadOnly
								if (basketStage === 'Contract Accepted' ){
									console.log ( 'Bakset stage is COntract Accepted!!!!!!!!making attributes readonly' );
									updateMap[config.guid].push ({
									name: 'UseExitingSIM',
									// value: {
										showInUi:isPortOutReversal,
										readOnly:true
									// }
									}); 


									if (isPortOutReversal)
									{
										updateMap[config.guid].push({
											name: 'isPortOutReversal',
											// value: {
												value: true,
												showInUi:isPortOutReversal,
												readOnly:true
											// }
										}); 
									}
								}
							}


						});
				}
			});
		}
	}
	//});
	if (updateMap) {
		console.log('EMPlugin_handlePortOutReversal update map', updateMap);
		//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true).then(component => console.log('EMPlugin_checkConfigurationSubscriptionsForEM Attribute Update', component));
		let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); 
		if(component && component !=null && component != undefined) {
			let keys = Object.keys(updateMap);
			var complock = component.commercialLock;
			if(complock) component.lock('Commercial', false);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false); 
			}
			if(complock) component.lock('Commercial', true);
		}
	}
	return Promise.resolve(true);
}

async function resetDeliveryDetailsinOESchemaForIndvConf(guid){

	var updateMap={};//EDGE-147799
	let product = await CS.SM.getActiveSolution(); // Spring 20
	if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
		if (product.components && Object.values(product.components).length > 0) {
			Object.values(product.components).forEach((comp) => {
				if(comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){		
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						//if(comp.schema.changeType==='Change Request'){
						Object.values(comp.schema.configurations).forEach(async (config) => {								
							if (!updateMap[config.guid]) //EDGE-147799
								updateMap[config.guid] = []; //EDGE-147799
							if(!config.disabled && guid=== config.guid){
								var shippingRequired = Object.values(config.attributes).filter(att =>{
									return att.name === 'ShippingRequired' 
								});

								var deviceShipping  = Object.values(config.attributes).filter(att =>{
									return att.name === 'DeviceShipping' 
								});
								var shippingRequiredVal = shippingRequired[0].value;
								var deviceShippingVal = deviceShipping[0].value;

								//EDGE-147799 - Bulk OE implementation changes - laxmi 
								if (basketStage === 'Commercial Configuration' || basketStage === 'Draft') {
									if(shippingRequiredVal === 'TRUE' || deviceShippingVal === 'TRUE'  ) {
										console.log ( 'Either flag is true - Delivery is needed' ); 


										updateMap[config.guid].push({
											name: 'isDeliveryEnrichmentNeededAtt',
											value:  true
										});
										updateMap[config.guid].push({
											name: 'isDeliveryDetailsRequired',
											value:  true
										});
										needsUpdate=true;
									}else{
										console.log ( 'Flags are false - Delivery is NOT needeed' ); 


										updateMap[config.guid].push({
											name: 'isDeliveryDetailsRequired',
											value: false
										});
										//EDGE-147597 added by ankit || start
										updateMap[config.guid].push({
											name: 'isDeliveryEnrichmentNeededAtt',
											value:  false
										});
										//EDGE-147597 added by ankit || End
										needsUpdate=true;
									}


								}//End contract Accepted check
								// //EDGE-147799 Changes END									
								var updateMapNew = {};
								if (config.orderEnrichmentList) {
									config.orderEnrichmentList.forEach((oe) => {
										//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
										if (!updateMapNew[oe.guid])
											updateMapNew[oe.guid] = [];
											if (shippingRequiredVal === 'FALSE' &&  deviceShippingVal === 'FALSE')	{

												//console.log( 'Both Attribute Values are FALSE, made OE DeliveryDetails Optional' );

												updateMapNew[oe.guid].push({name: 'DeliveryContact', required: false},{name: 'DeliveryAddress', required: false});
											}else
												console.log( 'DeliveryAddress OE Isnt Optional' );
									});
								}
								if(updateMapNew)
								{
									//CS.SM.updateOEConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, config.guid, updateMapNew, true);
									// Spring 20
									let keys = Object.keys(updateMapNew);
									for(let h=0; h< updateMapNew.length;h++){
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
									}
								}


								if(updateMap) {
									//CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true);	 //EDGE-147799							
									// Spring 20
									let keys = Object.keys(updateMap);
									for(let h=0; h< updateMap.length;h++){
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],true)
									}
								}
							}
						});
					}
				}
			});
		}
	}
}