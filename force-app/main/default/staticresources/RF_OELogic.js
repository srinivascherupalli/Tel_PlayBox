/*************************************************************************************
1.	Kalashree Borgaonkar 06-11-2019  Added 'Port-in' for conditional rendering
2.  Aditya Pareek        24-12-2019  Edge-122962: Enable Order Enrichment tabs in read-only mode
3. Laxmi 				9-mar-2020		EDGE-138001 - customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment - Added Basket STages for Generate Net price Button
4. Rohit				1-April-2020 	INC000092470670 the address format within individual enrichment is not aligned to Bulk Enrichment
5. Rohit				8-April-2020 	INC000092513433 Enabling CS OOTB Bulk Feature for Device Outright Purchase Solution
6. Ankit Goswami        23-april-2020   EDGE-142924- Added Bulk Enrichment New string in List
7. Laxmi Rahate			5-Jun-2020		EDGE-152101 Enable OE console for Next Gen Mobile Device
8. Laxmi Rahate			16-Jun-2020		EDGE-155254 Added Generic Method to check Manadatory Paremeters Values
9. Laxmi Rahate			30-Jun-2020		EDGE-154021 
10. Ankit Goswami		14-Jul-2020		INC000093063735 Date Fix issue
11. Laxmi Rahate		30-Jul-2020     EDGE-154680 , EDGE-154663
12. Pallavi D            21-Jul-2020     EDGE-154502 Spring 20 upgrade
13  Laxmi 				31-AUg-2020		EDGE-173460
14. Shweta 				3-10-2020 		REFACTORED
15. Arinjay S           06.11.2020      EDGE-184862
16. Laxmi R             06.11.2020      EDGE-188102
17. Arinjay Singh		09.11.2020		EDGE-184862,EDGE-189374
16	Laxmi				14-20-2020		EDGE-174219
17	Shubhi				25/11/2020		EDGE-185011
18  Arinjay Singh		22.01.2021		EDGE-199353,EDGE-199416
19 Antun Bartonicek     26.01.2021      EDGE-198536
20 Arunkumar V          25.02.2021		EDGE-203192
21. Shubhi V			15.03.2021	    EDGE-204313
22. Pawan Singh			16.04.2021		EDGE-213750  Defect fix,added two new methods to update delivery details when doing bulk changes.
23. Pallavi Deshpande : INC000095385455 : EDGE-212567 Defect fix: Order enrichment details are not being saved
24. Antun Bartonicek	08.06.2021.		EDGE-198536 - performance improvements
25. Vivek               08/11/2021      DIGI-3208
26. Don Navarro			22/10/2021		DIGI-456 added updateOEConsoleButtonVisibility_v2() method
27. Hrvoje Sunjic		28.09.2021		R34 upgrade related fix for Select All (fix devised by Ashish)
***********************************************************************************/
var ngucVariables = {

    NGUC_OFFER_NAME : 'Adaptive Collaboration',
    NGUC_PROF_SERV_OFFR_NAME : 'Adaptive Collaboration Professional Services',
    NGUC_TENANCY_OFFER_NAME  : 'Adaptive Collaboration Tenancy'
};
const OE_INVALID = "oe-invalid"; // invalid class for styling517
const OE_DATA_PROVIDER = "OEDataProvider"; // remote action class name
window.activeGuid = null; // active Configuration Guid
window.activeSchemaConfigGuid = null; // active OE Schema Guid
window.RuleLibrary = {}; // full library of rules
window.onInitOESchema = {}; // runs before rules
window.onInitOETab = {}; // runs on breadcrumb tab click
window.noPredicate = {}; // runs after rules
window.oeSetBasketData = {};
window.runeRulesForFirstTab = {};
window.currentConfigWrapper = null;
window.basketStage = null;
window.accountId = null;
window.siteId = null;
window.afterRules = {};
window.notificationHTML = "";
window.cachedMap = null;
window.loadedOETabName = "";
window.loadedConfigSchemaName = "";
window.currentSolutionName = "";
window.basketsolutions = "";

window.solution = null;
window.isToggled = false;
//var OEComponentsList = ['Customer Requested Dates', 'Delivery Details', 'Mobility Features', 'Order Primary Contact', 'Site Details', 'Voice FNN Details']; // Full list of all OE component names
var OEComponentsList = ["Order primary Contact", "Unified Communications", "Customer requested Dates", "Site details", "Delivery details", "Mobility features", "Customer requested Dates Mobility", "Tenancy Contact Details", "Subscription"]; //Added by Venkat for Tenancy Contact Details-19.13 NgUC MTS Build EDGE - 114158

//values are populated in afterSolutionLoaded hook
let stagesNotAllowingCommNegotiation = [];
let stagesNotAllowingOrderEnrichment = [];
//EDGE-117585. Kalashree Borgaonkar. Added 'Port In Check'
// Edge-122962: Aditya:Enable Order Enrichment tabs in read-only mode
//EDGE-138001 Added Generate Net Price
let customButtonsToHideForStagesNotAllowingCommNegotiation = ["Add IP Site", "Add Site", "Port In Check", "Generate Net Price", "Update Quantity","Reactivate Service","Add BroadSoft Tenancy"]; // added Reactivate Service by shubhi for EDGE-18501, added Add BroadSoft Tenancy by Kalashree EDGE-216668
let customButtonsToHideForStagesNotAllowingOrderEnrichment = ["Number Reservation", "Bulk Enrichment", "Bulk Enrichment New", "Update Quantity"]; //Added Bulk Enrichment New as part of EDGE-142924 by ankit
// EDGE-138001  Added -     'Enriched' : ['Generate Net Pricet'],  'Contract Accepted' : ['Generate Net Price'],'Submitted' : ['Generate Net Price']
let customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment = {
	Submitted: ["Bulk Enrichment", "Bulk Enrichment New"], // Added Bulk Enrichment New as part of EDGE-142924 by ankit
	Enriched: ["Bulk Enrichment", "Bulk Enrichment New"] //Added Bulk Enrichment New as part of EDGE-142924 by ankit
};
// Change by Rohit For INC000092513433
let solutionsAllowingOEConsole = [ ngucVariables.NGUC_OFFER_NAME , ngucVariables.NGUC_TENANCY_OFFER_NAME , "Telstra Internet Direct", "Device Outright Purchase", "Adaptive Mobility"]; // Added Next Gen Device EDGE-152101
window.afterAttributeUpdatedOE = async function (componentName, guid, attribute, oldValue, newValue) {
	if (OEComponentsList.indexOf(componentName) > -1 && oldValue !== newValue && (componentName === Utils.getSchemaName() || componentName === Utils.getConfigName())) {
		await OE.runRules(Utils.getConfigName(), Utils.getSchemaName());
	}
};
window.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
	let oeConfig;

	if (window.currentSolutionName == "Corporate Mobile Plus" && orderEnrichmentConfiguration.name.includes("Delivery details") && orderEnrichmentConfiguration.attributes && orderEnrichmentConfiguration.attributes.length > 0) {
		// Changes for INC000092470670 Done by Rohit

		let nameAtrtribute = orderEnrichmentConfiguration.getattribute("Name");
		console.log(nameAtrtribute.value + nameAtrtribute.value);
		let addressAtrtribute = orderEnrichmentConfiguration.getattribute("Address");
		let deliveryContactNameString = nameAtrtribute.value;
		let deliveryAddressString = addressAtrtribute.value;

		if (configuration.orderEnrichmentList) {
			let oe = Object.values(configuration.orderEnrichmentList).find((oe) => oe.name.includes("Delivery details"));
			if (oe) {
				oeConfig = oe;
			} else return;

			updateMap = {};
			updateMap[oeConfig.guid] = [];
			updateMap[oeConfig.guid].push({ name: "DeliveryContact", displayValue: deliveryContactNameString });
			updateMap[oeConfig.guid].push({ name: "DeliveryAddress", displayValue: deliveryAddressString });

			let keys = Object.keys(updateMap);
			let currentComponent = currentSolution.getComponentByName(componentName);

			for (let h = 0; h < Object.values(updateMap).length; h++) {
				currentComponent.updateOrderEnrichmentConfigurationAttribute(configuration.guid, keys[h], updateMap[keys[h]], false);
			}
		}
	}
};

window.oeSetBasketData = function (solution, basketStage, accountid, basketNum, basketChangeType) {
	window.basketStage = basketStage;
	window.solution = solution;
	window.accountId = accountid;
	window.basketNum = basketNum;
	window.basketChangeType = basketChangeType;
};

window.oeSetBasketsolutions = function (basketsolutions) {
	window.basketsolutions = basketsolutions;
};
window.afterOETabLoaded = async function (configurationGuid, OETabName, configSchemaName, siteId) {
    Utils.addSelectAllButtonsToConfigurationComponents();//EDGE-198536 inject Select All buttons for convenience
	window.rulesUpdateMap = {};
	window.activeGuid = configurationGuid;
	window.loadedOETabName = OETabName;
	window.loadedConfigSchemaName = configSchemaName;
	window.siteId = siteId;
	Utils.cleanUI();
	Utils.hideNotification();
	Utils.getConfigurationWrapper();
	if (typeof window.onInitOETab[OETabName] === "function") {
		if (window.onInitOETab[OETabName]) window.onInitOETab[OETabName]();
		await OE.runRules(configSchemaName, OETabName);
	}
	if (configSchemaName === 'Mobile Subscription' ||  configSchemaName === 'Enterprise Mobility')  // EDGE-174219 Changes
	{
		let simAVailabilityType = await Utils.getConfigAttributeValue('SimAvailabilityType', configurationGuid);
		//console.log ( 'simAVailabilityType from OE ---', simAVailabilityType); 
		if (simAVailabilityType === ''  || simAVailabilityType === null) {
		//Utils.markOEConfigurationInvalid(guid, 'Please complete Number Enrichment before proceeding to Order Enrichment');
		CS.SM.displayMessage('Please complete Number Enrichment before proceeding to Order Enrichment');
		}
	}//// EDGE-174219 Changes END
	return Promise.resolve(true);
};
var Utils = {
    //EDGE-198536 start
    //button click handler for Select/Deselect All injected buttons
    OEselectAllHandler: function(e) {
        if (e.target.id.startsWith("SelectAll_")) {
            //handle button text change
            e.target.innerHTML = e.target.innerHTML == "Select All" ? "Deselect All" : "Select All";
            //skip index 0 as that is the Component name, not our 1st configuration
            for (var i = 1; i < e.path[2].children.length; i++) {
                //simulate manual click
                 // updated Sept 27 2021 by HS - R34 upgrade fix for Select All
				 e.path[2].children[i].children[0].children[0].click();
            }
        }
    },
    //function to inject Select All button to every component i.e. configuration group
    addSelectAllButtonsToConfigurationComponents: function() {
        var OEnode = document.getElementsByClassName("cdk-overlay-pane order-enrichment-modal");
        //if we can't find this element then we are probably not in Order enrichemnt console screen
        if (OEnode.length > 0) {
            //if we find even one event listener then we will assume our logic already ran
            if (OEnode[0].eventListeners().length == 0) {
                //add event listener only to the parent so that we don't need to add to every button element
                OEnode[0].addEventListener("click", Utils.OEselectAllHandler);
                var components = document.getElementsByClassName("component ng-star-inserted");
                for (var i = 0; i < components.length; i++) {
                    var id = "SelectAll_" + i;
                    //if not already created
                    if (!document.getElementById(id)) {
                        let button = document.createElement("button");
                        button.id = "SelectAll_" + i;
                        button.className = "button";
                        button.innerHTML = "Select All";
                        components[i].children[0].appendChild(button);
                    }
                }
            }
        }
    },
    //EDGE-198536 end

	/************************************************************************************
	 * Author	: Tihomir Baljak
	 * Method Name : hideSubmitSolutionFromOverviewTab
	 * Invoked When: multiple occurrences
	 * Description : On Overview tab hides part of a screen displayig Submit Solution
	 * Parameters : N/A
	 ***********************************************************************************/
	hideSubmitSolutionFromOverviewTab: function () {
		let column = document.getElementsByClassName("overview-column");
		if (column && column.length > 0) {
			let box = column[0].getElementsByClassName("box-wrapper");
			if (box && box.length > 0) {
				box[0].style.display = "none";
				let wm = document.getElementsByClassName("warning-message");
				if (wm && wm.length > 0) {
					for (var i = 0; i < wm.length; i++) {
						if (wm[i].innerText) wm[i].innerText = wm[i].innerText.replace('"Submit" button', '"Validate and Save" button');
					}
				}
			}
		}
	},
	/************************************************************************************
	 * Author	: Tihomir Baljak
	 * Method Name : updateOEConsoleButtonVisibility
	 * Invoked When: multiple occurrences
	 * Description : Shows or hides "Order Enrichment Console" button depending on solutionsAllowingOEConsole property
	 * Parameters : N/A
	 ***********************************************************************************/
	updateOEConsoleButtonVisibility: function () {
		let isVisible = false;
		if (solutionsAllowingOEConsole.includes(window.currentSolutionName) && Utils.isOrderEnrichmentAllowed()) isVisible = true;
		let buttons = document.getElementsByClassName("cs-btn btn-transparent no-icon");
		if (buttons) {
			for (let i = 0; i < buttons.length; i++) {
				let button = buttons[i];
				if (button.innerText && button.innerText.toLowerCase() === "order enrichment console") {
					if (isVisible) {
						button.style.display = "block";
					} else {
						button.style.display = "none";
					}
				}
			}
		}
	},
	
	/************************************************************************************
	 * Author	: Don Navarro
	 * Method Name : updateOEConsoleButtonVisibility_v2
	 * Invoked When: multiple occurrences
	 * Description : Shows or hides new "Order Enrichment" button depending on solutionsAllowingOEConsole property and Feature Toggling framework
	 * Parameters : activeBasket, inputKey (same value as one of the EnabledFlows in FeatureToggle.OrderEnrichment custom metadata)
	 ***********************************************************************************/
	updateOEConsoleButtonVisibility_v2: async function(activeBasket, inputKey) {
		let isVisible = false;
		//let isToggled = false;
		let buttons = document.getElementsByClassName("cs-btn btn-transparent no-icon");
		let inputmap = {};
		inputMap['OrderEnrichment'] =inputKey; // Update By Vijay DIGI-456
		 let loadedSolution = await CS.SM.getActiveSolution();
		await activeBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
			window.isToggled = values[inputKey];
		});
		isVisible = (solutionsAllowingOEConsole.includes(loadedSolution.name) && Utils.isOrderEnrichmentAllowed());
		console.log('[RF_OELogic] isToggled : ' + isToggled + ' | isVisible: ' + isVisible);
		
		if (buttons) {
			for (let i = 0; i < buttons.length; i++) {
				let button = buttons[i];
				
				if (button.innerText && button.innerText.toLowerCase() === "order enrichment console") {
					if (isVisible && !isToggled) {
						button.style.display = "block";
					} else {
						//button.style.display = "none";
						button.style.position = "absolute";
						button.style.left = "-999px";
					}
				}
				if (button.innerText && button.innerText.toLowerCase() === "order enrichment") {
					if (isToggled) {
						button.style.display = "block";
					} else {
						button.style.display = "none";
					}
				}
			}
		}
	},
	
	/************************************************************************************
	 * Author	: Laxmi  Rahate -  EDGE-138001
	 * Method Name : updateImportConfigButtonVisibility
	 * Invoked When: multiple occurrences
	 * Description : Hides import configurations button
	 * Parameters : N/A
	 ***********************************************************************************/
	updateImportConfigButtonVisibility: function () {
		let buttons = document.getElementsByClassName("slds-file-selector__dropzone");
		if (buttons.length > 0) {
			for (let i = 0; i < buttons.length; i++) {
				let button = buttons[i];
				// Arinjay fix for Import button visibility
				if (button.innerText && button.innerText.toLowerCase().includes("import")) {
					button.style.display = "none";
				}
			}
		}
	},
	/************************************************************************************
	 * Author	: Tihomir Baljak
	 * Method Name : updateCustomButtonVisibilityForBasketStage
	 * Invoked When: multiple occurrences
	 * Description : Shows or hides custom buttons on comonent level depending on a basket stage
	 * Parameters : N/A
	 ***********************************************************************************/
	updateCustomButtonVisibilityForBasketStage: function () {
		if (customButtonsToHideForStagesNotAllowingCommNegotiation || customButtonsToHideForStagesNotAllowingCommNegotiation.length > 0) {
			let isCommNegAllowed = Utils.isCommNegotiationAllowed();
			customButtonsToHideForStagesNotAllowingCommNegotiation.forEach((el) => {
				Utils.updateComponentLevelButtonVisibility(el, isCommNegAllowed, false);
			});
		}
		if (customButtonsToHideForStagesNotAllowingOrderEnrichment || customButtonsToHideForStagesNotAllowingOrderEnrichment.length > 0) {
			let isOEAllowed = Utils.isOrderEnrichmentAllowed();
			customButtonsToHideForStagesNotAllowingOrderEnrichment.forEach((el) => {
				let isVisible = isOEAllowed;
				if (customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment[window.basketStage] && customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment[window.basketStage].includes(el)) isVisible = true;
				Utils.updateComponentLevelButtonVisibility(el, isVisible, false);
			});
		}
	},
	/************************************************************************************
	 * Author	: Tihomir Baljak
	 * Method Name : isCommNegotiationAllowed
	 * Invoked When: multiple occurrences
	 * Description : Checks if commercial negotiation is allowed by comparing basket stage to unallowed stages for commercial negotiation
	 * Parameters : N/A
	 ***********************************************************************************/
	isCommNegotiationAllowed: function () {
		let res = stagesNotAllowingCommNegotiation.find((b) => b === window.basketStage);
		if (res) return false;
		return true;
	},
	/************************************************************************************
	 * Author	: Tihomir Baljak
	 * Method Name : isOrderEnrichmentAllowed
	 * Invoked When: multiple occurrences
	 * Description : Checks if order enrichment is allowed by comparing basket stage to unallowed stages for OE
	 * Parameters : N/A
	 ***********************************************************************************/
	isOrderEnrichmentAllowed: function () {
		let res = stagesNotAllowingOrderEnrichment.find((b) => b === window.basketStage);
		if (res) return false;
		return true;
	},
	loadSMOptions: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		if ((stagesNotAllowingCommNegotiation && stagesNotAllowingCommNegotiation.length > 0) || (stagesNotAllowingOrderEnrichment && stagesNotAllowingOrderEnrichment.length > 0)) {
			return Promise.resolve(true);
		}
		let smOptionMap = {};
		smOptionMap["GetSmOptions"] = "";
		await currentBasket.performRemoteAction("SolutionActionHelper", smOptionMap).then((result) => {
			console.log("GetSmOptions finished with response: ", result);
			let smOptions = JSON.parse(result["GetSmOptions"]);
			if (smOptions.cssmgnt__Stages_Not_Allowing_Comm_Negotiation__c) stagesNotAllowingCommNegotiation = smOptions.cssmgnt__Stages_Not_Allowing_Comm_Negotiation__c.split(",");
			if (smOptions.cssmgnt__Stages_Not_Allowing_Order_Enrichment__c) stagesNotAllowingOrderEnrichment = smOptions.cssmgnt__Stages_Not_Allowing_Order_Enrichment__c.split(",");
		});
		return Promise.resolve(true);
	},
	/**************************************************************************************
	 * Author	   : Violeta Jalsic
	 * Method Name : emptyValueOfAttribute
	 * Invoked When: Empty value of attribute
	 **************************************************************************************/
	emptyValueOfAttribute: async function (guid, componentName, attributeName, skipHooks) {
		if (guid != null && attributeName != null && attributeName != "") {
			let updateConfigMap = {};
            updateConfigMap[guid] = [{
					name: attributeName,
					value: ""
            }];
			// Arinjay - Spring 20
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(componentName);
			if (component) {
				await component.updateConfigurationAttribute(guid, updateConfigMap[guid], skipHooks);
			}
		}
	},
	/*******************************************************************************************************
	 * Author	  : Tihomir Baljak
	 * Method Name : updateComponentLevelButtonVisibility
	 * Invoked When: after Save of the Solution
	 * Description : 1. updates Component Level buttons visibility as required
	 * Parameters  : 1. buttonLabel      -   Label of the button
	 *               2. isVisible        -   Flag signifying whether the button should be visible or not
	 *               3. isDefaultButton  -   Flag signifying Whether this is Default button or Custom button
	 ******************************************************************************************************/
	updateComponentLevelButtonVisibility: function (buttonLabel, isVisible, isDefaultButton) {
		let buttons = document.getElementsByClassName("cs-btn btn-transparent");
		if (buttons) {
			for (let i = 0; i < buttons.length; i++) {
				let button = buttons[i];
				if (button.innerText && button.innerText.toLowerCase() === buttonLabel.toLowerCase()) {
					let child = button.getElementsByClassName("btn-icon icon-add");
					if ((isDefaultButton && child && child.length > 0) || (!isDefaultButton && (!child || child.length === 0))) {
						if (isVisible) {
							button.style.display = "block";
						} else {
							button.style.display = "none";
						}
					}
				}
			}
		}
	},
	/**********************************************************************************************************************************************
	 * EDGE-EDGE-204313
	 * Author   : Shubhi V
	 * Invoked When: multiple occurences
	 ********************************************************************************************************************************************/
	updateButtonVisibility: function (buttonlabel) {
		let buttonName='';
		if(buttonlabel && buttonlabel!='')
			buttonName=buttonlabel.toLowerCase();
		let buttons = document.getElementsByClassName("slds-button");
		if (buttons.length > 0) {
			for (let i = 0; i < buttons.length; i++) {
				let button = buttons[i];
				// Arinjay fix for Import button visibility
                if (buttonlabel && buttonName != '' && buttonlabel != '' && button.innerText && button.innerText.toLowerCase().includes(buttonName)) {
					button.style.display = "none";
				}
			}
		}
	},
	getSchemaNameForConfigGuid: async function (configGuid) {
		let schemaName;
		let currentSolution = await CS.SM.getActiveSolution();
		if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
			for (const comp of Object.values(currentSolution.components)) {
				const config = comp.getConfiguration(configGuid);
				if (config) {
					schemaName = comp.schema.name;
					break; //EDGE-198536
				}
			}
		}
		return schemaName;
	},
	on: function (elSelector, eventName, selector, fn) {
		let element = document.querySelector(elSelector);
		if (element) {
			element.addEventListener(eventName, function (event) {
				let possibleTargets = element.querySelectorAll(selector);
				let target = event.target;
				for (let i = 0, l = possibleTargets.length; i < l; i++) {
					let el = target;
					let p = possibleTargets[i];
					while (el && el !== element) {
						if (el === p) {
							return fn.call(p, event);
						}
						el = el.parentNode;
					}
				}
			});
		}
	},
	getClosestParent: function (elem, selector) {
		if (!Element.prototype.matches) {
			Element.prototype.matches =
				Element.prototype.matchesSelector ||
				Element.prototype.mozMatchesSelector ||
				Element.prototype.msMatchesSelector ||
				Element.prototype.oMatchesSelector ||
				Element.prototype.webkitMatchesSelector ||
				function (s) {
					let matches = (this.document || this.ownerDocument).querySelectorAll(s),
						i = matches.length;
					while (--i >= 0 && matches.item(i) !== this) {}
					return i > -1;
				};
		}
		// Get the closest matching element
		for (; elem && elem !== document; elem = elem.parentNode) {
			if (elem.matches(selector)) return elem;
		}
		return null;
	},

	getConfigName: function () {
		return window.loadedConfigSchemaName;
	},
	getSchemaName: function () {
		let wrapper = document.querySelectorAll("app-order-enrichment-editor .slds-path__nav .slds-is-active .slds-path__title");
		if (wrapper && wrapper[0]) {
			return wrapper[0].innerText;
		} else {
			let el = document.querySelectorAll("app-iframe-modal .slds-tabs_default__nav .slds-is-active a");
			if (el && el.length > 0) return el[0].innerText;
			else return "";
		}
	},

	getAllOrderEnrichment: async function (guid) {
		let solution = await CS.SM.getActiveSolution();
		if (basketStage === "Contract Accepted") {  //EDGE-203192
			solution.lock("Commercial", false);
		}
		if (basketStage === "Contract Accepted") {  //EDGE-203192		
			solution.lock("Commercial", false);
		}
		
		if (solution) {
			let config1 = await solution.getConfiguration(window.activeGuid);

			if (config1) {
				let activeSchemaConfig = Object.values(config1.getOrderEnrichments());
				return activeSchemaConfig;
			}
		}
		if (basketStage === "Contract Accepted") { //EDGE-203192
			await solution.lock("Commercial", true);
		}
	},

	dropDownFix: function (e) {
		let chElement = Utils.getClosestParent(e.srcElement, ".configuration-header");
		if (!chElement) return;
		let expandButton = chElement.querySelector(".expand-btn");
		if (expandButton && expandButton.className.indexOf("expanded") == -1) {
			expandButton.click();
		}
	},
	updateOEConfigurations: async function (updateMap) {
		if (updateMap) {
			let solution = await CS.SM.getActiveSolution();
			console.log("Configuration name :: ", Utils.getConfigName);
			const component = await solution.findComponentsByConfiguration(window.activeGuid);
			let keys = Object.keys(updateMap);
			let complock = component.commercialLock;
			if (complock) component.lock("Commercial", false);
			for (let i = 0; i < keys.length; i++) {
				await component.updateOrderEnrichmentConfigurationAttribute(window.activeGuid, keys[i], updateMap[keys[i]], false);
			}
			if (complock) component.lock("Commercial", true);
		}
		return Promise.resolve(true);
	},

	getAttributeValue: async function (name, guid) {
		let oeData = await Utils.getAllOrderEnrichment();

		let activeSchemaConfig = null;
		for (let i = 0; i < oeData.length; i++) {
			if (Object.values(oeData[i])[0].guid == guid) {
				activeSchemaConfig = Object.values(oeData[i])[0];
				break;
			}
		}

		if (activeSchemaConfig) {
			//let attribute = activeSchemaConfig.getAttribute(name);
			//let attribute= CommonUtills.getAttribute(activeSchemaConfig, name);
            //let attribute = Object.values(activeSchemaConfig.attributes).find((attr) => attr.name === name);
            let attribute = activeSchemaConfig.attributes[name.toLowerCase()]; //EDGE-198536
			let cachedValue = null;
			if (window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]) {
				let cachedAttribute = window.rulesUpdateMap[guid].find((item) => item.name === name);
				if (cachedAttribute && typeof cachedAttribute.value !== "undefined") {
					console.info("WILL BE FETCHED FROM CACHE", name);
					cachedValue = cachedAttribute.value;
				}
			}
			if (attribute && attribute.value && attribute.value != "") {
				let returnValue = null,
					value = cachedValue ? cachedValue : attribute.value;
				switch (attribute.type) {
					case "Date":
						if (value == null || value == "") {
							returnValue = 0;
						} else {
							returnValue = value; //(new Date(value)).setHours(0,0,0,0); INC000093063735 Date Fix issue by ankit
						}
						break;
					default:
						returnValue = value;
						break;
				}
				return returnValue;
			}
		}
		if (name === "Notes") {
			return "";
		}
		return [];
	},
    //EDGE-213750  start: defect fix to update delivery details for each configGuid.

	getAttributeValue_generic: async function (name, oeGuid, configGuid) {
		let oeData = await Utils.getAllOrderEnrichment_generic(configGuid);

		let activeSchemaConfig = null;
		for (let i = 0; i < oeData.length; i++) {
			if (Object.values(oeData[i])[0].guid == oeGuid) {
				activeSchemaConfig = Object.values(oeData[i])[0];
				break;
			}
		}
		

		if (activeSchemaConfig) {
			//let attribute = activeSchemaConfig.getAttribute(name);
			//let attribute= CommonUtills.getAttribute(activeSchemaConfig, name);
            //let attribute = Object.values(activeSchemaConfig.attributes).find((attr) => attr.name === name);
            let attribute = activeSchemaConfig.attributes[name.toLowerCase()]; //EDGE-198536
			let cachedValue = null;
			if (window.rulesUpdateMap !== null && window.rulesUpdateMap[oeGuid]) {
				let cachedAttribute = window.rulesUpdateMap[oeGuid].find((item) => item.name === name);
				if (cachedAttribute && typeof cachedAttribute.value !== "undefined") {
					console.info("WILL BE FETCHED FROM CACHE", name);
					cachedValue = cachedAttribute.value;
				}
			}
			if (attribute && attribute.value && attribute.value != "") {
				let returnValue = null,
					value = cachedValue ? cachedValue : attribute.value;
				switch (attribute.type) {
					case "Date":
						if (value == null || value == "") {
							returnValue = 0;
						} else {
							returnValue = value; //(new Date(value)).setHours(0,0,0,0); INC000093063735 Date Fix issue by ankit
						}
						break;
					default:
						returnValue = value;
						break;
				}
				return returnValue;
			}
		}
		if (name === "Notes") {
			return "";
		}
		return [];
	},
    getAllOrderEnrichment_generic: async function (configGuid) {
		let solution = await CS.SM.getActiveSolution();
		
		if (basketStage === "Contract Accepted") {  	
			solution.lock("Commercial", false);
		}
		
		if (solution) {
			let config1 = await solution.getConfiguration(configGuid);

			if (config1) {
				let activeSchemaConfig = Object.values(config1.getOrderEnrichments());
				return activeSchemaConfig;
			}
		}
		if (basketStage === "Contract Accepted") { 
			await solution.lock("Commercial", true);
		}
	},

	/////////////////// End \\\\\\\\\\\\\\\\\\\

	getAttributeDisplayValue: async function (name, guid) {
		let oeData = await Utils.getAllOrderEnrichment(guid);

		let activeSchemaConfig = null;
		for (let i = 0; oeData.length; i++) {
			if (Object.values(oeData[i])[0].guid == guid) {
				activeSchemaConfig = Object.values(oeData[i])[0];
				break;
			}
		}
		if (activeSchemaConfig) {
			let attribute = activeSchemaConfig.getAttribute(name);

			let cachedValue = null;
			if (window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]) {
				let cachedAttribute = window.rulesUpdateMap[guid].find((item) => item.name === name);
				if (cachedAttribute && typeof cachedAttribute.displayValue !== "undefined") {
					console.info("WILL BE FETCHED FROM CACHE displayValue", name);
					cachedValue = cachedAttribute.displayValue;
				}
			}
			if (Object.values(attribute)[0].length) {
				return cachedValue ? cachedValue : attribute.displayValue;
			}
		}
		if (name === "Notes") {
			return "";
		}
		return [];
	},
	getConfigAttributeValue: function (name) {
		if (window.currentConfigWrapper) {
            //let currentPC = Object.values(window.currentConfigWrapper.schema.configurations).find((item) => item.guid === window.activeGuid);
            let currentPC = window.currentConfigWrapper.schema.configurations[window.activeGuid]; //EDGE-198536

			if (currentPC) {
                //let attrWrapper = Object.values(currentPC.attributes).find((attr) => attr.name === name);
                let attrWrapper = currentPC.attributes[name.toLowerCase()]; //EDGE-198536

				if (attrWrapper) {
					return attrWrapper.value;
				}
			}
		}
		return null;
	},
	getConfigurationWrapper: async function () {
		let c = await CS.SM.getActiveSolution();
		let pc = Object.values(c.components).find((item) => item.schema.name == Utils.getConfigName());
		if (pc) {
			window.currentConfigWrapper = pc;
		}
		return Promise.resolve(true);
	},
	getOrderEnrichmentTemplateId: async function () {
		let c = await CS.SM.getActiveSolution();
		if (c) {
			let component = Object.values(c.components).find((item) => item.name === Utils.getConfigName());
			if (component) {
				let currentOE = Object.values(component.orderEnrichments).find((item) => item.name === Utils.getSchemaName());
				if (currentOE) {
					window.templateId = currentOE.id;
				}
			}
		}
	},
	updateOEPayload: function (payload, guid) {
		for (let i = 0; i < payload.length; i++) {
			if (window.rulesUpdateMap[guid]) {
				let existsIndex = window.rulesUpdateMap[guid].findIndex((item) => item.name == payload[i].name);
				let existing = null;
				if (existsIndex > -1) {
					existing = window.rulesUpdateMap[guid].splice(existsIndex, 1);
				}
				window.rulesUpdateMap[guid].push(payload[i]);
			}
		}
	},
	formatDate: function (_date) {
		let date = new Date(_date);
		return date.getFullYear() + "-" + (date.getMonth() < 9 ? "0" : "") + (date.getMonth() + 1) + "-" + (date.getDate() < 10 ? "0" : "") + date.getDate();
	},

	markOEConfigurationInvalid: function (guid, message) {
		let config = Array.prototype.slice.call(document.querySelectorAll("app-specification-editor-attribute input")).filter(function (item) {
			return item.value == guid;
		});
		if (config) {
			let wrapper = Utils.getClosestParent(config[0], ".oe-product-wrapper");
			if (wrapper && wrapper.className.indexOf(OE_INVALID) == -1) wrapper.className += " " + OE_INVALID;
			if (window.notificationHTML !== message + "<br />") window.notificationHTML += message + "<br />";
		}
	},
	unmarkOEConfigurationInvalid: function (guid) {
		let config = Array.prototype.slice.call(document.querySelectorAll("app-specification-editor-attribute input")).find((item) => item.value == guid);
		if (config) {
			let wrapper = Utils.getClosestParent(config[0], ".oe-product-wrapper");
			if (wrapper && wrapper.className.indexOf(OE_INVALID) > -1) wrapper.classList.remove(OE_INVALID);
		}
	},
	remoteAction: async function (inputMap, callback) {
		let currentBasket = await CS.SM.getActiveBasket();
		await currentBasket.performRemoteAction(OE_DATA_PROVIDER, inputMap).then((p) => {
			return callback(p);
		});
	},

	initNotification: function () {
		let notificationContainer = document.createElement("div");
		notificationContainer.id = "oe-notification";
		notificationContainer.style.position = "absolute";
		let wrapper = document.getElementsByClassName("configuration oe-product-wrapper ng-star-inserted"); // document.querySelector('.order-enrichment');
		if (wrapper && wrapper[0]) {
			notificationContainer.style.left = "65px";
			wrapper[0].appendChild(notificationContainer);
		} else {
			let o = document.getElementById("cdk-overlay-0");
			if (o) {
				notificationContainer.style.left = "200px";
				o.appendChild(notificationContainer);
			} else {
				let o1 = document.getElementsByClassName("cdk-overlay-pane");
				if (o1 && o1.length > 0) {
					notificationContainer.style.left = "65px";
					o1[0].appendChild(notificationContainer);
				}
			}
		}
	},
	showNotification: function (message) {
		let notificationContainer = document.querySelector("#oe-notification");
		if (!notificationContainer) {
			Utils.initNotification();
		}
		notificationContainer = document.querySelector("#oe-notification");
		if (notificationContainer) {
			notificationContainer.innerHTML = message;
		}
	},
	hideNotification: function () {
		let oe = document.querySelector("#oe-notification");
		if (oe) oe.innerHTML = "";
	},
	cleanUI: function () {
		if (document.querySelector(".specification-editor-table .oe-invalid") === null) {
			Utils.unmarkOEConfigurationInvalid(window.activeSchemaConfigGuid);
			Utils.hideNotification();
		}
	},
	isEmpty: function (obj) {
		for (let key in obj) {
			if (obj.hasOwnProperty(key)) return false;
		}
		return true;
	},

	/**********************************************************************************************************************************************
	 * Author	   : Tihomir Baljak/ Laxmi Rahate
	 * EDGE-152101
	 * Method Name : initializeTIDOEConfigs
	 * Invoked When: after solution is loaded, after configuration is added
	 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
	 * Parameters  : none
	 ********************************************************************************************************************************************/

	initializeGenericOEConfigs: async function (paramSolutionName) {
		//EDGE-154502 start
		let currentSolution = await CS.SM.getActiveSolution();
		//EDGE-154502 end
		//EDGE-154502
		let offerNameRequiredSoln = [ngucVariables.NGUC_PROF_SERV_OFFR_NAME]; // add solutions , DIGI-3208
		let components = currentSolution.getComponents();
		components = components.components;
		if (currentSolution && currentSolution.name.includes(paramSolutionName) && components && Object.values(components).length > 0) {
			//EDGE-154502
			let currentBasket = await CS.SM.getActiveBasket(); //EDGE-155255
			for (const comp of Object.values(components)) {
				//EDGE-154502

				if (comp) {
					let configuration = await comp.getConfigurations();

					for (const config of Object.values(configuration)) {
						console.log("comp testing ");
						//EDGE-154502
						//let config = Object.values(configuration)[j]; //EDGE-154502
						let updateMap = {};
						if (config.orderEnrichmentList) {
							for (const oe of Object.values(config.orderEnrichmentList)) {
								if (!updateMap[oe.guid]) updateMap[oe.guid] = [];
								updateMap[oe.guid].push({
									name: "basketId", //basketAttribute.name,
									value: currentBasket.basketId
								});
								//	}
								if (offerNameRequiredSoln && offerNameRequiredSoln.contains(currentSolution.name)) {
									let offerName = currentSolution.getConfigurations()[0].getAttribute("OfferName").displayValue;
									updateMap[oe.guid].push({ name: "OfferName", value: offerName });
								}
							}
						}
						if (updateMap && Object.keys(updateMap).length > 0) {
							//EDGE-154502 startr
							let keys = Object.keys(updateMap);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[i], updateMap[keys[i]], false); //check this
							}
							//EDGE-154502 end
						}
					}
				}
			}
		}
		return Promise.resolve(true);
	},

	/************************************************************************************
	 * Author	  :Laxmi Rahate
	 * EDGE-152101
	 * Method Name :addDefaultGenericDeviceOEConfigs
	 * Invoked When: multiple occurrences, Generic Method for Adding Fefault OE Configs
	 * Parameters  : N/A
	 ***********************************************************************************/
	/*addDefaultGenericOEConfigs: async function (paramSolutionName) {
		if (window.basketStage !== "Contract Accepted") return;
		let oeMap = [];
		//EDGE-154502
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154502
		//if (currentSolution.name.includes(paramSolutionName)) {//EDGE-154502
		if (currentSolution.name.includes(paramSolutionName) && currentSolution.components && Object.values(currentSolution.components).length > 0) {
			//EDGE-154502
			let components = currentSolution.getComponents();
			Object.values(components.components).forEach((comp) => {
				//EDGE-154502
				let configuration = comp.getConfigurations();
				Object.values(configuration).forEach((config) => {
					//EDGE-154502
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
						//EDGE-154502
						let found = false;
						if (config.orderEnrichmentList) {
							let oeConfig = Object.values(config.orderEnrichmentList).find((oe) => oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId);
							if (oeConfig) found = true;
						}
						if (!found) {
							let el = {};
							el.componentName = comp.name;
							el.configGuid = config.guid;
							//EDGE-154502
							el.oeSchema = oeSchema; //EDGE-154502
							oeMap.push(el);
						}
					});
				});
			});
		}

		if (oeMap.length > 0) {
			for (let i = 0; i < oeMap.length; i++) {
				//EDGE-154502 start
				let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
				await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
				//EDGE-154502 end
			}
		}
		//TODO
		await Utils.initializeGenericOEConfigs(paramSolutionName);
		return Promise.resolve(true);
    },*/
    
    addDefaultGenericOEConfigs: async function (paramSolutionName) {
		console.log('addDefaultGenericOEConfigs');
		try{
		if (window.basketStage !== "Contract Accepted") return;
		let currentBasket = await CS.SM.getActiveBasket();
		let offerNameRequiredSoln = [ ngucVariables.NGUC_PROF_SERV_OFFR_NAME ];// add solutions , DIGI-3208
		let offerNameForCancel = ["Adaptive Mobility",  ngucVariables.NGUC_OFFER_NAME ];
		let oeMap = [];
		//EDGE-154502
		let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154502
		if (currentSolution.name.includes(paramSolutionName) && currentSolution.components && Object.values(currentSolution.components).length > 0) {
			//EDGE-154502
			let components = currentSolution.getComponents();
			for(let i=0; i<Object.values(components.components).length; i++){
				//EDGE-154502
				let comp = Object.values(components.components)[i];
				let configuration = comp.getConfigurations();
				for(let j=0; j<Object.values(configuration).length;j++){
					let config = Object.values(configuration)[j];
                        if (!offerNameRequiredSoln.includes(paramSolutionName)) {
						let changeTypeAttrib = CommonUtills.getAttribute(config, 'ChangeType');
						let changeTypeAttributeVal =null;
						if(changeTypeAttrib && changeTypeAttrib != undefined &&  changeTypeAttrib.value && changeTypeAttrib.value != '' && changeTypeAttrib.value != null){
						//let changeTypeAttribute = config.getAttribute("ChangeType");
						//if (changeTypeAttribute && changeTypeAttribute.value != '' && changeTypeAttribute.value != null) {
							changeTypeAttributeVal = changeTypeAttrib.value;
							}
						if(config.disabled === false ){
							if(changeTypeAttributeVal && changeTypeAttributeVal === "Cancel" && offerNameForCancel.includes(paramSolutionName)){
								continue;
							}
						}
					}
					//EDGE-154502
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
						//EDGE-154502
						let found = false;
						if (config.orderEnrichmentList) {
							let oeConfig = Object.values(config.orderEnrichmentList).find((oe) => oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId);
							if (oeConfig) found = true;
						}
						if (!found) {
							let el = {};
							el.componentName = comp.name;
							el.configGuid = config.guid;
							//EDGE-154502
							el.oeSchema = oeSchema; //EDGE-154502
							oeMap.push(el);
						}
					});
					}
			}
		}
		if (oeMap.length > 0) {
			for (let i = 0; i < oeMap.length; i++) {
				let configMap = [];
				configMap = [{name: "basketId", value: { value: currentBasket.basketId}}];
				if(offerNameRequiredSoln && offerNameRequiredSoln.contains(currentSolution.name)){
					let offerNameAttrib = CommonUtills.getAttribute(currentSolution.getConfigurations()[0],"OfferName");
					if(offerNameAttrib && offerNameAttrib != undefined && offerNameAttrib.displayValue){
						let offerName = offerNameAttrib.displayValue;
						configMap.push({ name: "OfferName", value: {value:offerName} });
					}
				}
				try{
					var orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration(configMap);
					let todaysDate=Utils.formatDate((new Date()).setHours(0,0,0,0));
                        if ((currentSolution.name.includes("Adaptive Mobility") || currentSolution.name.includes("Corporate Mobile Plus")) &&
                            oeMap[i].oeSchema.solutionName === "Customer requested Dates") {
						orderEnrichmentConfiguration.attributes["not before crd"].value = todaysDate;
						orderEnrichmentConfiguration.attributes["preferred crd"].value 	= todaysDate;
					}
				}catch(err){
					console.log(err);
				}
				let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
                    await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);//EDGE-212567
				let updateMap = {};
                    if ((currentSolution.name.includes("Adaptive Mobility") || currentSolution.name.includes("Corporate Mobile Plus")) &&
                        oeMap[i].oeSchema.solutionName === "Customer requested Dates") {
						if (!updateMap[oeMap[i].configGuid]) updateMap[oeMap[i].configGuid] = [];
						let currentDate = Utils.formatDate((new Date()).setHours(0,0,0,0));
						updateMap[oeMap[i].configGuid].push({
							name: "Not Before CRD", 
							value: currentDate,
							displayValue: currentDate
                        }, {
							name: "Preferred CRD", 
							value: currentDate,
							displayValue: currentDate
					});
					if (updateMap && Object.keys(updateMap).length > 0) {
						let keys = Object.keys(updateMap);
						 var complock = component.commercialLock;
						if(complock) component.lock('Commercial', false);
						for (let j = 0; j < keys.length; j++) {
								await component.updateConfigurationAttribute(keys[j], updateMap[keys[j]], true); //EDGE-212567
						}
						if(complock) component.lock('Commercial', true);
					}
					
				}
			}
		}
        } catch (err) {
			console.log('ERROR');
			console.log(err);
		}
		//await Utils.initializeGenericOEConfigs(paramSolutionName);
		return Promise.resolve(true);
	},
	/**
	 * Author      : Laxmi Rahate  2020-06-16
	 * Ticket      : EDGE-155254
	 * Description : Generic Method to check Mandatory Parameters
	 */

	//CHeck TODO
	beforeSaveOEValidations: async function (paramSolutionName, componentName) {
		//let hasErrors = false;
		let changeTypeAttributeVal = ""; //EDGE-154021
		let product = await CS.SM.getActiveSolution(); //EDGE-154502
		let components =  product.getComponents();
		let simAVailabilityTypeVal = "";
		let simAVailabilityType = "";
		
		if (product.name === paramSolutionName && components && Object.values(components).length > 0) {
			//EDGE-154502

			let comp = product.getComponentByName(componentName);

			if (comp && comp != undefined) {
				let configuration = await comp.getConfigurations();
			//EDGE-154502
				//Object.values(configs).forEach(async (config) 
				//Object.values(configs).forEach(async (config) => {
				Object.values(configuration).forEach(async (config) => {
                        let changeTypeAttribute = config.getAttribute("ChangeType");
				
						let simAVailabilityType;
						
						if (changeTypeAttribute) {
							changeTypeAttributeVal = changeTypeAttribute.value;
						}
						//Added By Shweta as suggested by Laxmi
						if (componentName === "Enterprise Mobility"){
						simAVailabilityType = config.getAttribute("SimAvailabilityType");
						if (simAVailabilityType ) {
							simAVailabilityTypeVal = simAVailabilityType.value;
							console.log ( 'simAVailabilityTypeVal from OELOGIC----------', simAVailabilityTypeVal);
						}
                        } else
							simAVailabilityTypeVal = "New";
						
                        if (simAVailabilityTypeVal === "" || simAVailabilityTypeVal === undefined) {
							simAVailabilityTypeVal = "New";
						}
						// END hereAdded By Shweta as suggested by Laxmi
						////EDGE-154680 added Active in the below case
						if (config.orderEnrichmentList && changeTypeAttributeVal !== "Cancel" && changeTypeAttributeVal !== "PaidOut" && changeTypeAttributeVal !== "Paid Out" && changeTypeAttributeVal !== "Active" && config.disabled === false) {
							//EDGE-154021 - AVoiding the checks when status is cancel/PaidOut

							for (let k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {
								//EDGE-154502
								let oeAtt = Object.values(config.orderEnrichmentList)[k];

								var oeNameVal = "";
								var oeName = oeAtt.getAttribute("OENAME");
								if (oeName.value && oeName.value != null) {
									oeNameVal = oeName.value;
								}

								let phone = "";
								let email = "";
								let phoneVal = "";
								let emailVal = "";
								if (oeNameVal === "CRD") {
									let notBeforeCRDValidation = new Date();
									notBeforeCRDValidation.setHours(0, 0, 0, 0);
									notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);

									let preferredCRDAttVal = "";
									let notBeforeCRDAttVal = "";
									let preferredCRDAtt = "";
									let notBeforeCRDAtt = "";

									preferredCRDAtt = oeAtt.getAttribute("Preferred CRD");

									notBeforeCRDAtt = oeAtt.getAttribute("Not Before CRD");

									if (preferredCRDAtt.value && preferredCRDAtt.value != null) {
										preferredCRDAttVal = preferredCRDAtt.value;
										preferredCRDAttVal = Utils.formatDate(preferredCRDAttVal);
									}
									if (notBeforeCRDAtt.value && notBeforeCRDAtt.value != null) {
										notBeforeCRDAttVal = notBeforeCRDAtt.value;
										notBeforeCRDAttVal = Utils.formatDate(notBeforeCRDAttVal);
									}
									if (notBeforeCRDAtt !== undefined && notBeforeCRDAtt !== "") {
										if (notBeforeCRDAttVal < notBeforeCRDValidation) {
											config.status = false;
											config.statusMessage = "Order Enrichment has errors - CRD Date invalid."; //EDGE-154502
											//hasErrors = true;
											//break;
										}
									}

									if (notBeforeCRDAtt === "" || notBeforeCRDAttVal === undefined) {
										config.status = false;
										config.statusMessage = "Order Enrichment has errors - CRD Date invalid."; //EDGE-154502
										//hasErrors = true;
										//break;
										// }
									}
								}

								if (oeNameVal === "DD") {
									
									if ( simAVailabilityTypeVal.toLowerCase().includes ("new") )  {
									phone = oeAtt.getAttribute("Phone");
									email = oeAtt.getAttribute("Email");
									contact = oeAtt.getAttribute("DeliveryContact");
									address = oeAtt.getAttribute("DeliveryAddress");
									if (phone.value && phone.value != null) {
										phoneVal = phone.value;
									}
									if (email.value && email.value != null) {
										emailVal = email.value;
									}
									if (contact === undefined || contact ===  "" ||  address === undefined || address ===  "" ||   phoneVal === undefined || phoneVal === "undefined" || phoneVal === "" || email === undefined || email === "undefined" || email === "") {
										config.status = false;
										config.statusMessage = "Order Enrichment has errors - Delivery Contact invalid"; //EDGE-154502
										//hasErrors = true;

									}
								}

									// }

									/* if (!(hasErrors)) {
                                     console.log(' NO Errors!!!!!!!!!!!!!');
                                     //CS.SM.updateConfigurationStatus(componentName, config.guid, true, '');//EDGE-154502
                                     //config.status = true;
                                 }*/
								}
								// }
							} //end Cancel PaidOut chk
							//});
							//}
						}
						//config.validate();
					}
					//});
				);
			}
			//}
		}
		//});
	},

	updateActiveSolutionTotals: async function () {
		let currentSolution = await CS.SM.getActiveSolution();
		let currentBasket = await CS.SM.getActiveBasket();
		let inputMap = {};
		inputMap["updateSolutionTotals"] = currentSolution.id;
		//no need to wait for result
		currentBasket.performRemoteAction("SolutionActionHelper", inputMap);
	}
};
var OE = {
	// runRulesOld: async function(configName, schemaName){
	//     console.log('runRules ', configName, schemaName);
	//     window.notificationHTML = '';
	//     let c = await CS.SM.getActiveSolution();
	//     var nonComm = Object.values(c.components).filter(function(item){
	//             return item.schema.name == configName;
	//         });
	//         console.log('nonComm 123', nonComm);
	//         if(nonComm && nonComm[0]) {
	//             console.log('nonComm ', configName, schemaName, nonComm);
	//             var currentConfiguration = Object.values(nonComm[0].schema.configurations).filter(function (item) {
	//                 return item.guid == window.activeGuid;
	//             });
	//             RuleLibrary[schemaName] = {};
	//             if (currentConfiguration && currentConfiguration[0]) {
	//                 oeShema = Object.values(nonComm[0].orderEnrichments).filter((oeSchema) => {return oeSchema.name === schemaName});
	//                 console.log('currentConfiguration ', currentConfiguration[0], window.activeGuid, oeShema);

	//                 let enrichmentListSize = currentConfiguration[0].orderEnrichmentList.length;

	//                 for (var i = 0; i < enrichmentListSize; i++) {
	//                     if (!oeShema || oeShema.length===0 || currentConfiguration[0].orderEnrichmentList[i].name.includes(oeShema[0].name) ||
	//                         currentConfiguration[0].orderEnrichmentList[i].parent === oeShema[0].id ||
	//                         currentConfiguration[0].orderEnrichmentList[i].parent === oeShema[0].productOptionId) {

	//                             let currentGUID = currentConfiguration[0].orderEnrichmentList[i].guid;
	//                             setTimeout(async function (guid, schemaName) {
	// 							window.activeSchemaConfigGuid = currentGUID;
	// 							//let guid = currentGUID;
	//                             if (typeof window.onInitOESchema[schemaName] === 'function') {
	//                                 var rules = await window.onInitOESchema[schemaName](guid);
	//                                 RuleLibrary[schemaName][guid] = rules;
	//                                 console.log('RuleLibrary', schemaName, guid);
	//                                 await OE.reducePromises(RuleLibrary[schemaName][guid]).then(async function () {
	//                                     console.log('After rules promises');
	//                                     await Utils.updateOEConfigurations(window.rulesUpdateMap);
	//                                     console.log('await updateOEConfigurations');
	//                                     if (typeof window.noPredicate[schemaName] === 'function') {
	//                                         await window.noPredicate[schemaName](guid);
	//                                     }
	//                                     await Utils.getConfigurationWrapper();
	//                                     Utils.showNotification(window.notificationHTML);
	//                                     if (window.notificationHTML === '') Utils.unmarkOEConfigurationInvalid(guid);

	//                                });
	//                             }
	//                         }, 250, currentGUID, schemaName);
	//                     }
	//                 }
	//             }
	//         }
	//     //});
	// 	return Promise.resolve(true);
	// },
	//Renamed due to attribute Tenancy Primary Contact value not updating by Gunjan
	runRules: async function (configName, schemaName) {
		try {
			console.log("runRules ", configName, schemaName);
			window.notificationHTML = "";
			let c = await CS.SM.getActiveSolution();
			// let nonComm = await c.getComponentByName(configName)
			let nonComm = Object.values(c.components).find((item) => item.schema.name == configName);
			console.log("nonComm 123", nonComm);
			if (nonComm) {
				console.log("nonComm ", configName, schemaName, nonComm);
				let currentConfiguration = await c.getConfiguration(window.activeGuid);
				// let currentConfiguration = Object.values(nonComm.schema.configurations).find(item  =>
				//      item.guid == window.activeGuid
				// );
				RuleLibrary[schemaName] = {};
				if (currentConfiguration) {
					oeShema = Object.values(nonComm.orderEnrichments).find((oeSchema) => oeSchema.name === schemaName);
					//console.log('currentConfiguration ', currentConfiguration, window.activeGuid, oeShema);

					let enrichmentListSize = currentConfiguration.orderEnrichmentList.length;

					for (let i = 0; i < enrichmentListSize; i++) {
						if (!oeShema || Object.values(currentConfiguration.orderEnrichmentList)[i].name.includes(oeShema.name) || currentConfiguration.orderEnrichmentList[i].parent === oeShema.id || currentConfiguration.orderEnrichmentList[i].parent === oeShema.productOptionId) {
							let currentGUID = currentConfiguration.orderEnrichmentList[i].guid;

							(async function (guid, schemaName) {
								try {
									window.activeSchemaConfigGuid = guid;
									if (typeof window.onInitOESchema[schemaName] === "function") {
										let rules = await window.onInitOESchema[schemaName](guid);
										RuleLibrary[schemaName][guid] = rules;
										console.log("RuleLibrary", schemaName, guid);
										await OE.reducePromises(RuleLibrary[schemaName][guid]).then(async function () {
											console.log("After rules promises");
											await Utils.updateOEConfigurations(window.rulesUpdateMap);
											console.log("await updateOEConfigurations");
											if (typeof window.noPredicate[schemaName] === "function") {
												await window.noPredicate[schemaName](guid);
											}
											await Utils.getConfigurationWrapper();
											Utils.showNotification(window.notificationHTML);
											if (window.notificationHTML === "") Utils.unmarkOEConfigurationInvalid(guid);
											return Promise.resolve(true);
										});
									}
									return Promise.resolve(true);
								} catch (err) {
									console.log(err);
								}
							})(currentGUID, schemaName);

							// setTimeout(
							// 	async function (guid, schemaName) {
							// 		window.activeSchemaConfigGuid = guid;
							// 		if (typeof window.onInitOESchema[schemaName] === "function") {
							// 			let rules = await window.onInitOESchema[schemaName](guid);
							// 			RuleLibrary[schemaName][guid] = rules;
							// 			console.log("RuleLibrary", schemaName, guid);
							// 			await OE.reducePromises(RuleLibrary[schemaName][guid]).then(async function () {
							// 				console.log("After rules promises");
							// 				await Utils.updateOEConfigurations(window.rulesUpdateMap);
							// 				console.log("await updateOEConfigurations");
							// 				if (typeof window.noPredicate[schemaName] === "function") {
							// 					await window.noPredicate[schemaName](guid);
							// 				}
							// 				await Utils.getConfigurationWrapper();
							// 				Utils.showNotification(window.notificationHTML);
							// 				if (window.notificationHTML === "") Utils.unmarkOEConfigurationInvalid(guid);
							// 			});
							// 		}
							// 	},
							// 	250,
							// 	currentGUID,
							// 	schemaName
							// );
						}
					}
				}
			}
		} catch (error) {
			console.log(error);
		}
		//});
		return Promise.resolve(true);
	},
	getPredicateResult: async function (Predicates, RuleId, GUID) {
		let GroupedPredicates = {};
		//console.group("Rule No. " + RuleId);
		// Make Groups from list of predicates
		for (let l = 0; l < Predicates.length; l++) {
			let predicate = Predicates[l];
			if (typeof predicate.group !== "undefined" && predicate.group !== "") {
				if (typeof GroupedPredicates[predicate.group] === "undefined") {
					GroupedPredicates[predicate.group] = [predicate];
				} else {
					GroupedPredicates[predicate.group].push(predicate);
				}
			}
		}
		let groupedResults = []; // ARRAY OF GROUPED PREDICATES RESULTS
		for (let g in GroupedPredicates) {
			// FOR EACH GROUP OF PREDICATES
			let groupedResult = { groupConjuction: null, predicates: [], predResult: null, evalString: null };
			predResultString = "";
			for (let j = 0; j < GroupedPredicates[g].length; j++) {
				// ITERATE THRU PREDICATES
				// Predicates
				let groupedPredicate = await GroupedPredicates[g][j],
					attValue = await Utils.getAttributeValue(groupedPredicate.attName, GUID), // FETCH VALUE OF ATTRIBUTE
					evalString = "";
				if (attValue === undefined) attValue = "";
				// SET GROUP CONJUCTION IF ANY, ONLY PRESENT ON LAST PREDICATE OF GROUP
				if (typeof groupedPredicate.groupConjuction !== "undefined" && groupedPredicate.groupConjuction !== null) {
					groupedResult.groupConjuction = groupedPredicate.groupConjuction;
				}
				// CREATE A PREDICATE EVALUATION STRING
				evalString = "'" + attValue + "'" + groupedPredicate.operator + "'" + (await groupedPredicate.attValue) + "'";
				// PUSH RESULT TO GROUP RESULT PREDICATES ALONGSIDE CONJUCTION OPERATOR
				groupedResult.predicates.push({
					eval: groupedPredicate.attName + groupedPredicate.operator + groupedPredicate.attValue,
					evalString: evalString,
					result: eval(evalString),
					conjuction: groupedPredicate.conjuction
				});
			}
			// ITERATE THRU GROUP RESULT PREDICATES, COMBINE THEM TOGETHER AND EVAL ALL
			for (let k = 0; k < groupedResult.predicates.length; k++) {
				let item = groupedResult.predicates[k];
				predResultString += item.result + (item.conjuction !== null ? item.conjuction : "");
			}
			// Giving errors on evaluating expression 199353 / 199416
			if(predResultString.includes('truetrue'))
				predResultString = predResultString.replace("truetrue","true");
			else if(predResultString.includes('falsefalse'))
				predResultString = predResultString.replace("falsefalse","false");
			else if(predResultString.includes('falsetrue'))
				predResultString = predResultString.replace("falsetrue","false&&true");
			else if(predResultString.includes('truefalse'))
				predResultString = predResultString.replace("truefalse","true&&false");

			groupedResult.predResult = eval(predResultString); // SET GROUP VALIDITY
			groupedResult.evalString = predResultString;
			groupedResults.push(groupedResult);
		}
		// ITERATE THRU FINAL GROUP RESULTS, COMBINE THEM ALL TO STRING AND EVAL
		let finalResultString = "";
		for (let i = 0; i < groupedResults.length; i++) {
			finalResultString += groupedResults[i].predResult + (groupedResults[i].groupConjuction !== null ? groupedResults[i].groupConjuction : "");
		}
		if (Utils.isEmpty(GroupedPredicates)) finalResultString = "true";
		console.groupEnd();
		return eval(finalResultString);
	},
	reducePromises: async function (rules) {
		console.log("rules: ", rules);
		const tasks = rules;
		if (!rules || rules.length === 0) return Promise.resolve([]);
		return tasks.reduce(function (promiseChain, currentTask, currentIndex, sourceArray) {
			return promiseChain.then(async function (chainResults) {
				let predicateResult = await OE.getPredicateResult(sourceArray[currentIndex].Predicates, sourceArray[currentIndex].Id, window.activeSchemaConfigGuid);
				if (predicateResult) {
					return sourceArray[currentIndex].IfTrue();
				} else {
					return sourceArray[currentIndex].Else();
				}
			});
		}, Promise.resolve([]));
	},
	/**
	 * Author      : Laxmi Rahate  2020-07-20
	 * Ticket      : EDGE-154663
	 * Description : Generic Method to get relConfigGUID Based on OEGUID and schema name
	 */
	// getRelatedConfigID: async function (ConfigGuid, oeSchemaName) {
	// 	let solution = await CS.SM.getActiveSolution();
	// 	let config = await solution.getConfigurationById(ConfigGuid);
	// 	if(config && config.relatedProductList && config.relatedProductList.length > 0){
	// 		 let product = config.relatedProductList.find((relatedConfig) => relatedConfig.name === oeSchemaName);
	// 		 if(product){
	// 			relConfigGUID	 = product.guid;
	// 		 }
	// 	}

	// 	return relConfigGUID;
	// },
	getRelatedConfigID: async function (configGUID, oeSchemaName) {
		let relConfigGUID;
		let product = await CS.SM.getActiveSolution();
		// await CS.SM.getActiveSolution().then((currentSolution) => {
		/// if (product.type) {
		if (product.components && Object.values(product.components).length > 0) {
			for (var i = 0; i < Object.values(product.components).length; i++) {
				var comp = Object.values(product.components)[i];
				if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					//if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
					for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {
						var config = Object.values(comp.schema.configurations)[j];
						if (config.guid === configGUID) {
							if (config.relatedProductList && config.relatedProductList.length > 0) {
								config.relatedProductList.forEach((relatedConfig) => {
									if (relatedConfig.name === oeSchemaName) {
										relConfigGUID = relatedConfig.guid;
										//console.log ( 'relConfigGUID ----------- for Schema ' , relConfigGUID + oeSchemaName);
									}
								}); //for each Related END
							}
						}
						//}); // For Each Config END
						if (relConfigGUID) break;
					} // end For
				}
				if (relConfigGUID) break;
			}
		}
		//}
		// });
		return relConfigGUID;
	},
	getRelatedConfigAttrValue: async function (paramConfig, AttributeName, schemaName) {
            attrVal = "";
            if (paramConfig) {
                let relatedProductList = paramConfig.getRelatedProducts();
                for (let j = 0; j < Object.values(relatedProductList).length; j++) {
                    let relatedConfig = Object.values(relatedProductList)[j];
                    if (relatedConfig.name === schemaName) {
                        //let attributeVal = Object.values(relatedConfig.configuration).getAttribute(AttributeName); THIS IS INCORRECT //Commented By Laxmi
                        let attributeVal = relatedConfig.configuration.getAttribute(AttributeName);//Added by Laxmi
                        if (attributeVal && attributeVal.value) {
                            attrVal = attributeVal.value;
                        }
                        if (attrVal) break;
                    }
                }
            }
            return attrVal;
        }
	// Added By Shweta : This method call is replace by configuration.parentConfiguration in RF_NextGenMobController;
	//getConfigGuidForOEGUID: async function (OEGuid) {}
};