/*
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
14	Laxmi								Removed Method 

*/
const OE_INVALID = 'oe-invalid'; // invalid class for styling
const OE_DATA_PROVIDER = 'OEDataProvider'; // remote action class name
window.activeGuid = null; // active Configuration Guid
window.activeSchemaConfigGuid = null; // active OE Schema Guid
window.RuleLibrary = {}; // full library of rules
window.onInitOESchema = {}; // runs before rules
window.onInitOETab = {}; // runs on breadcrumb tab click
window.noPredicate = {}; // runs after rules
window.oeSetBasketData = {}
window.runeRulesForFirstTab = {}
window.currentConfigWrapper = null;
window.basketStage = null;
//window.basketId = null;
window.accountId = null;
window.siteId = null;
window.afterRules = {};
window.notificationHTML = '';
window.cachedMap = null;
window.loadedOETabName = '';
window.loadedConfigSchemaName = '';
window.currentSolutionName = '';
window.basketsolutions = '';

window.solution = null;
//var OEComponentsList = ['Customer Requested Dates', 'Delivery Details', 'Mobility Features', 'Order Primary Contact', 'Site Details', 'Voice FNN Details']; // Full list of all OE component names
var OEComponentsList = ['Order primary Contact', 'Unified Communications', 'Customer requested Dates', 'Site details', 'Delivery details', 'Mobility features', 'Customer requested Dates Mobility', 'Tenancy Contact Details', 'Subscription']; //Added by Venkat for Tenancy Contact Details-19.13 NgUC MTS Build EDGE - 114158 

//values are populated in afterSolutionLoaded hook
let stagesNotAllowingCommNegotiation = [];
let stagesNotAllowingOrderEnrichment = [];
//EDGE-117585. Kalashree Borgaonkar. Added 'Port In Check'
// Edge-122962: Aditya:Enable Order Enrichment tabs in read-only mode
//EDGE-138001 Added Generate Net Price
let customButtonsToHideForStagesNotAllowingCommNegotiation = ['Add IP Site', 'Add Site', 'Port In Check', 'Generate Net Price'];
let customButtonsToHideForStagesNotAllowingOrderEnrichment = ['Number Reservation', 'Order Enrichment', 'Bulk Enrichment', 'Bulk Enrichment New'];//Added Bulk Enrichment New as part of EDGE-142924 by ankit
// EDGE-138001  Added -     'Enriched' : ['Generate Net Pricet'],  'Contract Accepted' : ['Generate Net Price'],'Submitted' : ['Generate Net Price']
let customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment = {
    'Submitted': ['Bulk Enrichment', 'Bulk Enrichment New'], // Added Bulk Enrichment New as part of EDGE-142924 by ankit
    'Enriched': ['Bulk Enrichment', 'Bulk Enrichment New'] //Added Bulk Enrichment New as part of EDGE-142924 by ankit
};
// Change by Rohit For INC000092513433
let solutionsAllowingOEConsole = ['Telstra Collaboration', 'Telstra Collaboration Tenancy', 'Telstra Internet Direct', 'Device Outright Purchase', 'Adaptive Mobility']; // Added Next Gen Device EDGE-152101
window.afterAttributeUpdatedOE = async function (componentName, guid, attribute, oldValue, newValue) {
   // console.log('afterAttributeUpdatedOE:', componentName, 'guid:', guid,'attribute:', attribute,'oldValue:', oldValue,'newValue', newValue, '(', Utils.getSchemaName(), Utils.getConfigName(), ')');
    if (OEComponentsList.indexOf(componentName) > -1 && (oldValue !== newValue && (componentName === Utils.getSchemaName() || componentName === Utils.getConfigName()))) {
       // console.log('afterAttributeUpdatedOE: - running rules', Utils.getConfigName(), Utils.getSchemaName());
       // console.log('Pooja - running rules', Utils.getConfigName());
        await OE.runRules(Utils.getConfigName(), Utils.getSchemaName());
    }
								 
};
window.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
   // console.log('afterOrderEnrichmentConfigurationAdd'+orderEnrichmentConfiguration.guid);
	//console.log('componentName'+componentName);
  //  console.log('OE GUID -->');
    var oeConfig;
    // Prod Incident Fix --> INC000092093125
    if (window.currentSolutionName == 'Corporate Mobile Plus') {
        if (orderEnrichmentConfiguration.name.includes('Delivery details')) {
            if (orderEnrichmentConfiguration.attributes && orderEnrichmentConfiguration.attributes.length > 0) {
                // Changes for INC000092470670 Done by Rohit
                var nameAtrtribute = orderEnrichmentConfiguration.attributes.filter(obj => {
                    return obj.name === 'Name'
                });
                //console.log(nameAtrtribute[0].value + nameAtrtribute[0].value);
                var addressAtrtribute = orderEnrichmentConfiguration.attributes.filter(obj => {
                    return obj.name === 'Address'
                });
                var DeliveryAddresstmp = orderEnrichmentConfiguration.attributes.filter(obj => {
                    return obj.name === 'DeliveryAddress'
                });
                var deliveryContactNameString = nameAtrtribute[0].value;
                //var deliveryAddressString = streetAtrtribute[0].value + ' '	+ 	postcodeAtrtribute[0].value;
                var deliveryAddressString = addressAtrtribute[0].value;
                if (configuration.orderEnrichmentList) {
                    configuration.orderEnrichmentList.forEach((oe) => {
                        if (oe.name.includes('Delivery details')) {
                            oeConfig = oe;
                        }
                        else
                            return;
                    });
                  //  console.log('oeConfig     ' + oeConfig.name);
                   // console.log('oeConfig     ' + oeConfig.guid);
                    if (oeConfig.attributes && oeConfig.attributes.length > 0) {
                        var DCAtrtribute = oeConfig.attributes.filter(obj => {
                            return obj.name === 'DeliveryContact'
                        });
                      //  console.log('guidd     ' + oeConfig.guid);
                      //  console.log('DCAtrtribute     ' + DCAtrtribute[0].value);
                    }
                    updateMap = {};
                    updateMap[oeConfig.guid] = [];
                    updateMap[oeConfig.guid].push({ name: 'DeliveryContact', displayValue: deliveryContactNameString });
                    updateMap[oeConfig.guid].push({ name: 'DeliveryAddress', displayValue: deliveryAddressString });
                    //CS.SM.updateOEConfigurationAttribute('Mobile Subscription', configuration.guid, updateMap, false).then(() => Promise.resolve(true));
                    let keys = Object.keys(updateMap);
                    let currentComponent = currentSolution.getComponentByName(componentName);
                    console.log('initializeOEConfigs keys:', keys);
                    for (var h = 0; h < Object.values(updateMap).length; h++) {
                        console.log('update Order Enrichment COnfiguration');
                        currentComponent.updateOrderEnrichmentConfigurationAttribute(configuration.guid, keys[h], updateMap[keys[h]], false);
                    }
                    //CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true);




                }
            }
        }
    }
}
//can be called because of bulk OE so this will not be ok and need to stay commented
//if(componentName == Utils.getSchemaName()) OE.runRules(Utils.getConfigName(), Utils.getSchemaName());
window.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {
  //  console.log('afterOrderEnrichmentConfigurationDelete');
};
window.oeSetBasketData = function (solution, basketStage, accountid) {
    window.basketStage = basketStage;
    //window.basketId = basketid;
    window.solution = solution;
    window.accountId = accountid;
}
window.oeSetBasketsolutions = function (basketsolutions) {
    window.basketsolutions = basketsolutions;
}
window.afterOETabLoaded = async function (configurationGuid, OETabName, configSchemaName, siteId) {
  //  console.log('afterOETabLoadedOE: ', configurationGuid, OETabName, configSchemaName, siteId);
    window.rulesUpdateMap = {};
    window.activeGuid = configurationGuid;
    window.loadedOETabName = OETabName;
    window.loadedConfigSchemaName = configSchemaName;
    window.siteId = siteId;
    Utils.cleanUI();
    Utils.hideNotification();
    Utils.getConfigurationWrapper();
    if (typeof window.onInitOETab[OETabName] === 'function') {
        if (window.onInitOETab[OETabName]) window.onInitOETab[OETabName]();
        await OE.runRules(configSchemaName, OETabName);
    }
	return Promise.resolve(true);							 
}
var Utils = {
    /************************************************************************************
     * Author	: Tihomir Baljak
     * Method Name : hideSubmitSolutionFromOverviewTab
     * Invoked When: multiple occurrences
     * Description : On Overview tab hides part of a screen displayig Submit Solution
     * Parameters : N/A
     ***********************************************************************************/
    hideSubmitSolutionFromOverviewTab: function () {
        var column = document.getElementsByClassName('overview-column');
        if (column && column.length > 0) {
            var box = column[0].getElementsByClassName('box-wrapper');
            if (box && box.length > 0) {
                box[0].style.display = "none";
                var wm = document.getElementsByClassName('warning-message');
                if (wm && wm.length > 0) {
                    for (var i = 0; i < wm.length; i++) {
                      //  console.log('wm ', wm[i]);
                        if (wm[i].innerText)
                            wm[i].innerText = wm[i].innerText.replace('"Submit" button', '"Validate and Save" button');
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
        var isVisible = false;
        if (solutionsAllowingOEConsole.includes(window.currentSolutionName) &&
            Utils.isOrderEnrichmentAllowed())
            isVisible = true;
       // console.log('updateOEConsoleButtonVisibility', isVisible);
        var buttons = document.getElementsByClassName('cs-btn btn-transparent no-icon');
        if (buttons) {
            for (var i = 0; i < buttons.length; i++) {
                var button = buttons[i];
                if (button.innerText && button.innerText.toLowerCase() === 'order enrichment console') {
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
     * Author	: Laxmi  Rahate -  EDGE-138001
     * Method Name : updateImportConfigButtonVisibility
     * Invoked When: multiple occurrences
     * Description : Hides import configurations button
     * Parameters : N/A
     ***********************************************************************************/
    updateImportConfigButtonVisibility: function () {
        var buttons = document.getElementsByClassName('slds-file-selector__dropzone');
        if (buttons.length > 0) {
            //console.log('updateImportConfigButtonVisibility ');
            for (var i = 0; i < buttons.length; i++) {
                var button = buttons[i];
                // Arinjay fix for Import button visibility
                if (button.innerText && button.innerText.toLowerCase().includes('import')) {
                    //console.log('inside buttons chck updateImportConfigButtonVisibility  ');
                    //button.remove();
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
            var isCommNegAllowed = Utils.isCommNegotiationAllowed();
            customButtonsToHideForStagesNotAllowingCommNegotiation.forEach(
                el => {
                    Utils.updateComponentLevelButtonVisibility(el, isCommNegAllowed, false);
                }
            );
        }
        if (customButtonsToHideForStagesNotAllowingOrderEnrichment || customButtonsToHideForStagesNotAllowingOrderEnrichment.length > 0) {
            var isOEAllowed = Utils.isOrderEnrichmentAllowed();
            customButtonsToHideForStagesNotAllowingOrderEnrichment.forEach(
                el => {
                    let isVisible = isOEAllowed;
                    if (customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment[window.basketStage] && customButtonsToHideExceptionsForStagesNotAllowingOrderEnrichment[window.basketStage].includes(el))
                        isVisible = true;
                    Utils.updateComponentLevelButtonVisibility(el, isVisible, false);
                }
            );
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
        var res = stagesNotAllowingCommNegotiation.filter(b => {
            return b === window.basketStage
        });
        if (res && res.length > 0)
            return false;
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
        var res = stagesNotAllowingOrderEnrichment.filter(b => {
            return b === window.basketStage
        });
        if (res && res.length > 0)
            return false;
        return true;
    },
    loadSMOptions: async function () {
        let solutionManager = await CS.SM.getSolutionManager();
        let currentBasket = await CS.SM.getActiveBasket();
        if (stagesNotAllowingCommNegotiation && stagesNotAllowingCommNegotiation.length > 0 ||
            stagesNotAllowingOrderEnrichment && stagesNotAllowingOrderEnrichment.length > 0) {
            return Promise.resolve(true);
        }
        let smOptionMap = {};
        smOptionMap['GetSmOptions'] = '';
        console.log('currentBasket == ', currentBasket);
        //await CS.SM.WebService.performRemoteAction('SolutionActionHelper', smOptionMap).then(result => {
        await currentBasket.performRemoteAction('SolutionActionHelper', smOptionMap).then(result => {
            console.log('GetSmOptions finished with response: ', result);
            var smOptions = JSON.parse(result["GetSmOptions"]);
            if (smOptions.cssmgnt__Stages_Not_Allowing_Comm_Negotiation__c)
                stagesNotAllowingCommNegotiation = smOptions.cssmgnt__Stages_Not_Allowing_Comm_Negotiation__c.split(',');
            if (smOptions.cssmgnt__Stages_Not_Allowing_Order_Enrichment__c)
                stagesNotAllowingOrderEnrichment = smOptions.cssmgnt__Stages_Not_Allowing_Order_Enrichment__c.split(',');
            //console.log('stagesNotAllowingCommNegotiation: ', stagesNotAllowingCommNegotiation);
            //console.log('stagesNotAllowingOrderEnrichment: ', stagesNotAllowingOrderEnrichment);
        });
        return Promise.resolve(true);
    },
    /**************************************************************************************
     * Author	   : Violeta Jalsic
     * Method Name : emptyValueOfAttribute
     * Invoked When: Empty value of attribute
     **************************************************************************************/
    emptyValueOfAttribute: async function (guid, componentName, attributeName, skipHooks) {
        if (guid != null && attributeName != null && attributeName != '') {
            let updateConfigMap = {};
            updateConfigMap[guid] = [{
                name: attributeName,
                value: ''
            }];
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, skipHooks);
            // Arinjay - Spring 20
            let solution = await CS.SM.getActiveSolution();
            let component = await solution.getComponentByName(componentName);
           // console.log('component with name ' + componentName + ' is ', component + ' attributeName = ' + attributeName)  ;
            if (component) {
                const config = await component.updateConfigurationAttribute(guid, updateConfigMap[guid], skipHooks);
            }
            else
                console.log("ATTENTION :: Component not found with name :: " + componentName);
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
        //console.log('updateComponentLevelButtonVisibility', buttonLabel, isVisible, isDefaultButton);
        var buttons = document.getElementsByClassName('cs-btn btn-transparent');
        //console.log('updateComponentLevelButtonVisibility: ' , buttonLabel, buttons);
        if (buttons) {
            for (var i = 0; i < buttons.length; i++) {
                var button = buttons[i];
                //console.log('innerText: ' , button.innerText);
                if (button.innerText && button.innerText.toLowerCase() === buttonLabel.toLowerCase()) {
                    var child = button.getElementsByClassName('btn-icon icon-add');
                    //console.log('updateComponentLevelButtonVisibility check child: ' , child);
                    if ((isDefaultButton && child && child.length > 0) || (!isDefaultButton && (!child || child.length === 0))) {
                        //console.log('updateComponentLevelButtonVisibility hiding: ' , button);
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
    getSchemaNameForConfigGuid: async function (configGuid) {
        let schemaName;
        /*await CS.SM.getActiveSolution().then((currentSolution) => {
            if (currentSolution.type) {
                if (currentSolution.components && currentSolution.components.length > 0) {
                    for (var i=0; i<  currentSolution.components.length; i++) {
                        var comp = currentSolution.components[i];
                        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                            for (var j=0; j<comp.schema.configurations.length; j++) {
                                if (comp.schema.configurations[j].guid ===configGuid)
                                {
                                    schemaName = comp.schema.name;
                                    break;
                                }
                            }
                        }
                        if (schemaName)
                            break;
                    }
                }
            }
        });*/
        let currentSolution = await CS.SM.getActiveSolution();
        //if (currentSolution.type) {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            //Object.values(currentSolution.components).forEach((comp) => {
            for (const comp of Object.values(currentSolution.components)) {
                //Object.values(comp.schema.configurations).forEach((config) => {
                for (const config of Object.values(comp.schema.configurations)) {
                    if (config.guid === configGuid) {
                        schemaName = comp.schema.name;
                        break;
                    }
                }
            }
        }
        //}
        return schemaName;
    },
    on: function (elSelector, eventName, selector, fn) {
        var element = document.querySelector(elSelector);
        if (element) {
            element.addEventListener(eventName, function (event) {
                var possibleTargets = element.querySelectorAll(selector);
                var target = event.target;
                for (var i = 0, l = possibleTargets.length; i < l; i++) {
                    var el = target;
                    var p = possibleTargets[i];
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
        // Element.matches() polyfill
        if (!Element.prototype.matches) {
            Element.prototype.matches =
                Element.prototype.matchesSelector ||
                Element.prototype.mozMatchesSelector ||
                Element.prototype.msMatchesSelector ||
                Element.prototype.oMatchesSelector ||
                Element.prototype.webkitMatchesSelector ||
                function (s) {
                    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
                        i = matches.length;
                    while (--i >= 0 && matches.item(i) !== this) { }
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
        console.log('getConfigName', window.loadedConfigSchemaName);
        // Parent Config Name
        //return Array.prototype.slice.call(document.querySelectorAll('.navigation-header .slds-path__nav li.slds-is-active .slds-path__title')).filter(function(item){ return item.scrollHeight > 0; })[0].innerText;
        return window.loadedConfigSchemaName;
    },
    getSchemaName: function () {
        // JSON schema name
        var wrapper = document.querySelectorAll('app-order-enrichment-editor .slds-path__nav .slds-is-active .slds-path__title');
        if (wrapper && wrapper[0]) {
            return wrapper[0].innerText;
        } else {
            var el = document.querySelectorAll('app-iframe-modal .slds-tabs_default__nav .slds-is-active a');
            if (el && el.length > 0)
                return el[0].innerText;
            else
                return '';
        }
        return window.loadedOETabName;
    },
    getAllOrderEnrichment: async function () {
        let solution = await CS.SM.getActiveSolution();
        let configuration = solution.getConfiguration(window.activeGuid);
        let oeData = Object.values(configuration.getOrderEnrichments());
        return Object.values(oeData);
        /*if(oeData.__zone_symbol__state){
            return oeData.__zone_symbol__value;
        }*/
    },
    /*getAllOrderEnrichment: async function(){
        //let oeConfigData = CS.SM.getActiveSolution().then(solution=>{
        let solution = await CS.SM.getActiveSolution();
        // Arinjay Test
        const component = solution.findComponentsByConfiguration(window.activeGuid);
        console.log('component ', component);
        //var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
        //let oeData = Object.values(component.orderEnrichments).filter(att => { att.name == Utils.getSchemaName()});
        let oeData1 = component.getOrderEnrichmentConfigurationList(window.activeGuid);
        console.log('oeData1 ', oeData1);
        //).filter(att => { return att.name == Utils.getSchemaName()})
        let configuration = solution.getConfiguration(window.activeGuid);
        let oeData = Object.values(configuration.getOrderEnrichments());
        for(const oeList of Object.values(oeData)){
            console.log('oeList ', oeList);
            for(const oe of Object.values(oeList)){
                if(oe.configurationName.includes(Utils.getSchemaName())){
                    console.log('oe ', oe);
                    oeConfigData.push(oe);
        }
            }
        }
        return oeConfigData;        
        //});
        return oeConfigData;
    },
    */
    dropDownFix: function (e) {
        var chElement = Utils.getClosestParent(e.srcElement, '.configuration-header');
        if (!chElement)
            return;
        var expandButton = chElement.querySelector('.expand-btn');
        if (expandButton && expandButton.className.indexOf('expanded') == -1) {
            expandButton.click();
        }
    },
    updateOEConfigurations: async function (updateMap) {
        console.log('updateMap', updateMap);
        if (updateMap) {
            // await CS.SM.updateOEConfigurationAttribute(Utils.getConfigName(), window.activeGuid, updateMap, false).then(function(component){
            //     console.log(Date.now());
            //     Promise.resolve(true);
            // });
            let solution = await CS.SM.getActiveSolution();
            console.log("Configuration name :: ", Utils.getConfigName);
            //let component = await solution.getComponentByName(Utils.getConfigName()); 
            const component = solution.findComponentsByConfiguration(window.activeGuid);
            let keys = Object.keys(updateMap);
            var complock = component.commercialLock;
			if (complock)component.lock('Commercial', false);
            for (let i = 0; i < keys.length; i++) {
													  
                await component.updateOrderEnrichmentConfigurationAttribute(window.activeGuid, keys[i], updateMap[keys[i]], false);
													 
            }
            if (complock)component.lock('Commercial', true);
        }
        return Promise.resolve(true);
    },
    //Added by Venkat for EDGE - 117274 - Sprint 19.15. Invoked from Tenancy & EMS JS
    updateCustomAttributeLinkText: function (customAttributeLabel, newLinkText) {
        var customAttributes = document.getElementsByTagName('app-specification-editor-attribute-custom');
        var i;
        for (i = 0; i < customAttributes.length; i++) {
            //if link belongs to parent that has correct label value then update the link text to new value
            if (customAttributes[i].parentElement &&
                customAttributes[i].parentElement.parentElement &&
                customAttributes[i].parentElement.parentElement.previousSibling &&
                customAttributes[i].parentElement.parentElement.previousSibling.innerText === customAttributeLabel) {
                //customAttributes[i].firstElementChild.innerText = newLinkText; //no longer lowest level
                customAttributes[i].firstChild.firstChild.innerText = newLinkText; //lowest level i.e. here is save to change innerText as it has same value as innerHtml
            }
        }
    },
    getAttributeValue: async function (name, guid) {
        let oeData = await Utils.getAllOrderEnrichment();
        //console.log("oeData111",oeData);
        let activeSchemaConfig = oeData.filter(function (item) {
            for (const conf of Object.values(item)) {
                return conf.guid == guid;
            }
        });
        if (activeSchemaConfig.length) {
            /*let attribute = Object.values(Object.values(Object.values(activeSchemaConfig)[0]).attributes).filter(function(item){
                return item.name == name;
            });*/
            let attribute = Object.values(Object.values(activeSchemaConfig[0])[0].attributes).filter(function (item) {
                return item.name == name;
            });
            /*let attribute;
            Object.values(activeSchemaConfig).forEach((oe) => {
                if(Object.values(oe) && Object.values(oe).length>0){
                    Object.values(oe.attributes).forEach((att)=>{
                        if(att.length){
                            if(att.name==name){
                                attribute =  att;
                            }
                        }
                    });
                }
            });*/
            // check if attribute is already in payload, if yes get that value
            let cachedValue = null;
            if (window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]) {
                let cachedAttribute = window.rulesUpdateMap[guid].filter(function (item) { return item.name === name; });
                if (cachedAttribute && cachedAttribute[0] && typeof cachedAttribute[0].value !== 'undefined') {
                    console.info('WILL BE FETCHED FROM CACHE', name);
                    cachedValue = cachedAttribute[0].value;
                }
            }
            if (attribute.length) {
                var returnValue = null,
                    value = cachedValue ? cachedValue : attribute[0].value;
                switch (attribute[0].type) {
                    case 'Date':
                        if (value == null || value == '') {
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
        return [];
    },
    getAttributeDisplayValue: async function (name, guid) {
        let oeData = await Utils.getAllOrderEnrichment();
        let activeSchemaConfig = oeData.filter(function (item) {
            for (const conf of Object.values(item)) {
                return conf.guid == guid;
            }
        });
        if (activeSchemaConfig.length) {
            let attribute = Object.values(Object.values(activeSchemaConfig[0])[0].attributes).filter(function (item) {
                return item.name == name;
            });
            // check if attribute is already in payload, if yes get that value
            let cachedValue = null;
            if (window.rulesUpdateMap !== null && window.rulesUpdateMap[guid]) {
                let cachedAttribute = window.rulesUpdateMap[guid].filter(function (item) { return item.name === name; });
                if (cachedAttribute && cachedAttribute[0] && typeof cachedAttribute[0].displayValue !== 'undefined') {
                    console.info('WILL BE FETCHED FROM CACHE displayValue', name);
                    cachedValue = cachedAttribute[0].displayValue;
                }
            }
            if (attribute.length) {
                return cachedValue ? cachedValue : attribute[0].displayValue;
            }
        }
        return [];
    },
    getConfigAttributeValue: function (name) {
        if (window.currentConfigWrapper) {
            console.log('Check this ', Object.values(window.currentConfigWrapper.schema.configurations));
            let currentPC = Object.values(window.currentConfigWrapper.schema.configurations).filter(function (item) {
                return item.guid === window.activeGuid;
            });
            if (currentPC && currentPC[0]) {
                let attrWrapper = Object.values(currentPC[0].attributes).filter(function (item) {
                    return item.name === name;
                });
                if (attrWrapper && attrWrapper[0]) {
                    return attrWrapper[0].value;
                }
            }
        }
        return null;
    },
    getConfigurationWrapper: async function () {
        let c = await CS.SM.getActiveSolution();
        let pc = Object.values(c.components).filter(function (item) {
            return item.schema.name == Utils.getConfigName();
        });
        if (pc && pc[0]) {
            window.currentConfigWrapper = pc[0];
        }
        return Promise.resolve(true);
    },
    getOrderEnrichmentTemplateId: async function () {
        let c = await CS.SM.getActiveSolution();
        if (c) {
            let component = Object.values(c.components).filter(function (item) {
                return item.name === Utils.getConfigName();
            });
            if (component) {
                let currentOE = Object.values(component[0].orderEnrichments).filter(function (item) {
                    return item.name === Utils.getSchemaName();
                });
                if (currentOE) {
                    window.templateId = currentOE[0].id;
                }
            }
        }
    },
    updateOEPayload: function (payload, guid) {
       // console.log('updating payload', payload, guid);
        for (let i = 0; i < payload.length; i++) {
            if (window.rulesUpdateMap[guid]) {
                let existsIndex = window.rulesUpdateMap[guid].findIndex(function (item) {
                    return item.name == payload[i].name;
                });
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
        return date.getFullYear() + '-' + (date.getMonth() < 9 ? '0' : '') + (date.getMonth() + 1) + '-' + (date.getDate() < 10 ? '0' : '') + date.getDate();
    },
    markOEConfigurationInvalid: function (guid, message) {
        var config = Array.prototype.slice.call(document.querySelectorAll('app-specification-editor-attribute input')).filter(function (item) { return item.value == guid; });
        if (config) {
            let wrapper = Utils.getClosestParent(config[0], '.oe-product-wrapper');
            if (wrapper && wrapper.className.indexOf(OE_INVALID) == -1) wrapper.className += ' ' + OE_INVALID;
           // console.log('window.notificationHTML ', window.notificationHTML);
            if (window.notificationHTML !== (message + '<br />')) window.notificationHTML += (message + '<br />');
           // console.log(window.notificationHTML);
        } else {
           // console.log('Could not set error message for ', guid, message);
        }
    },
    unmarkOEConfigurationInvalid: function (guid) {
        var config = Array.prototype.slice.call(document.querySelectorAll('app-specification-editor-attribute input')).filter(function (item) { return item.value == guid; })
        if (config) {
            let wrapper = Utils.getClosestParent(config[0], '.oe-product-wrapper');
            if (wrapper && wrapper.className.indexOf(OE_INVALID) > -1) wrapper.classList.remove(OE_INVALID);
        }
    },
    remoteAction: async function (inputMap, callback) {
        let currentBasket = await CS.SM.getActiveBasket();
        await currentBasket.performRemoteAction(OE_DATA_PROVIDER, inputMap).then(p => {
            return callback(p);
        });
    },

    initNotification: function () {
        let notificationContainer = document.createElement('div');
        notificationContainer.id = 'oe-notification';
        notificationContainer.style.position = 'absolute';
        let wrapper = document.getElementsByClassName('configuration oe-product-wrapper ng-star-inserted'); // document.querySelector('.order-enrichment');
       // console.log('initNotification wrapper ', wrapper);
        if (wrapper && wrapper[0]) {
           // console.log('initNotification - found wrapper ');
            notificationContainer.style.left = '65px';
            wrapper[0].appendChild(notificationContainer);
        } else {
          //  console.log('initNotification - wrapper not found');
            var o = document.getElementById('cdk-overlay-0');
            if (o) {
             //   console.log('initNotification -  found cdk-overlay-0');
                notificationContainer.style.left = '200px';
                o.appendChild(notificationContainer);
            }
            else {
                var o1 = document.getElementsByClassName('cdk-overlay-pane');
                if (o1 && o1.length > 0) {
                    notificationContainer.style.left = '65px';
                    o1[0].appendChild(notificationContainer);
                }
            }
        }
    },
    showNotification: function (message) {
       // console.log('showNotification: ', message);
        // if(document.querySelector('.specification-editor-table .oe-invalid') !== null){
      //  console.log('showNotification - found selector ');
        let notificationContainer = document.querySelector('#oe-notification');
        if (!notificationContainer) {
            Utils.initNotification();
        }
        notificationContainer = document.querySelector('#oe-notification');
        if (notificationContainer) {
            notificationContainer.innerHTML = message;
        }
        // }
    },
    hideNotification: function () {
        var oe = document.querySelector('#oe-notification');
        if (oe)
            oe.innerHTML = '';
    },
    cleanUI: function () {
        if (document.querySelector('.specification-editor-table .oe-invalid') === null) {
            Utils.unmarkOEConfigurationInvalid(window.activeSchemaConfigGuid);
            Utils.hideNotification();
        }
    },
    isEmpty: function (obj) {
        for (var key in obj) {
            if (obj.hasOwnProperty(key))
                return false;
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
       // console.log('initializeGenericOEConfigs ');
        var currentSolution;

        //EDGE-154502 start
        //await CS.SM.getActiveSolution().then((solution) => {
        var currentSolution = await CS.SM.getActiveSolution();
        //currentSolution = solution;
        //}).then(() => Promise.resolve(true));
        //EDGE-154502 end
        if (currentSolution) {
            console.log('initializeGenericOEConfigs - updating');
            if (currentSolution.name.includes(paramSolutionName)) {//EDGE-154502
                if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154502
                    for (var i = 0; i < Object.values(currentSolution.components).length; i++) {//EDGE-154502
                        var comp = Object.values(currentSolution.components)[i];
                        for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {//EDGE-154502
                            var config = Object.values(comp.schema.configurations)[j];//EDGE-154502

                            var updateMap = {};
                            if (config.orderEnrichmentList) {
                                for (var k = 0; k < config.orderEnrichmentList.length; k++) {
                                    var oe = config.orderEnrichmentList[k];
                                    var basketAttribute = oe.attributes.filter(a => {
                                        return a.name.toLowerCase() === 'basketid'
                                    });
                                    if (basketAttribute && basketAttribute.length > 0) {
                                        if (!updateMap[oe.guid])
                                            updateMap[oe.guid] = [];
                                        updateMap[oe.guid].push({
                                            name: basketAttribute[0].name,
                                            value: basketId
                                        });
                                      //  console.log('Basket ID -------------' + basketId);
                                    }
                                }
                            }
                            if (updateMap && Object.keys(updateMap).length > 0) {

                                //EDGE-154502 startr
                                //console.log('Next Generation Mobility Update MAP:', updateMap);
                                // CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
                                let keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
                                }
                                //EDGE-154502 end

                            }
                        };
                    };
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
    addDefaultGenericOEConfigs: async function (paramSolutionName) {
        if (window.basketStage !== 'Contract Accepted')
            return;
      //  console.log('addDefaultGenericOEConfigs');
        var oeMap = [];

        //await CS.SM.getActiveSolution().then((currentSolution) => {//EDGE-154502
        let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154502
        if (currentSolution.name.includes(paramSolutionName)) {//EDGE-154502
            console.log('addDefaultOEConfigs - looking components', currentSolution);
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154502
                Object.values(currentSolution.components).forEach((comp) => {//EDGE-154502
                    Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154502
                        Object.values(comp.orderEnrichments).forEach((oeSchema) => {//EDGE-154502
                            var found = false;
                            if (config.orderEnrichmentList) {
                                var oeConfig = config.orderEnrichmentList.filter(oe => {
                                    return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId)
                                });
                                if (oeConfig && oeConfig.length > 0)
                                    found = true;
                            }
                            if (!found) {
                                var el = {};
                                el.componentName = comp.name;
                                el.configGuid = config.guid;

                                // el.oeSchemaId = oeSchema.id;//EDGE-154502
                                el.oeSchema = oeSchema;//EDGE-154502

                                oeMap.push(el);
                               // console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
                            }
                            //}
                        });
                    });
                });
            }
        }

        // }).then(() => Promise.resolve(true));

        //console.log('addDefaultOEConfigs prepared');
        if (oeMap.length > 0) {
            var map = [];
            map.push({});
           // console.log('Adding default oe config map:', oeMap);
            for (var i = 0; i < oeMap.length; i++) {

                //EDGE-154502 start
                //await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
                let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
                let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
                await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
                //EDGE-154502 end

            };
        }
        await Utils.initializeGenericOEConfigs();
        return Promise.resolve(true);
    },

/**
 * Author      : Laxmi Rahate  2020-06-16
 * Ticket      : EDGE-155254
 * Description : Generic Method to check Mandatory Parameters
 */
    beforeSaveOEValidations: async function (paramSolutionName, componentName) {
        console.log('@@@@@@@@beforeSaveOEValidations');
        var hasErrors = false;
        var changeTypeAttributeVal = ''; //EDGE-154021 
        let product = await CS.SM.getActiveSolution();//EDGE-154502
            if (product.name === paramSolutionName) {
                if (product.components && Object.values(product.components).length > 0) {//EDGE-154502
                   // Object.values(product.components).forEach((comp) => {
                    for (var i=0; i<  Object.values(product.components).length; i++) {
                        var comp =Object.values(product.components)[i];
						if (comp.name === componentName ){ 
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154502
                              //  Object.values(comp.schema.configurations).forEach((config) => {			//EDGE-154502	
                                    //EDGE-154021 -Changes Start
								for (var j=0; j< Object.values(comp.schema.configurations).length; j++) {
								var config = Object.values(comp.schema.configurations)[j];							
							//if (config.guid === configGUID){ 
									var changeTypeAttribute = Object.values(config.attributes).filter(obj => {//EDGE-154502
                                        return obj.name === 'ChangeType'
                                    });
                                    if (changeTypeAttribute.length > 0 && changeTypeAttribute[0].value && changeTypeAttribute[0].value != null) {
                                        changeTypeAttributeVal = changeTypeAttribute[0].value;
                                    }
									
									var useExistingSIM = Object.values(config.attributes).filter(obj => {//EDGE-154502
                                        return obj.name === 'UseExitingSIM'
                                    });
                                    if (useExistingSIM.length > 0 && useExistingSIM[0].value && useExistingSIM[0].value != null) {
                                        useExistingSIMVal = useExistingSIM[0].value;
                                    }									
										////EDGE-154680 added Active in the below case 
                                        if (changeTypeAttributeVal !=='Cancel' &&  changeTypeAttributeVal !== 'PaidOut'  &&  changeTypeAttributeVal !== 'Paid Out' &&  changeTypeAttributeVal !== 'Active' && config.disabled === false )  // EDGE-173460 -Added disabled check//EDGE-154021 - AVoiding the checks when status is cancel/PaidOut
                                    {
                                        var updateMapNew = {};
                                        if (config.orderEnrichmentList) {
                                            console.log('Utils.getSchemaName() ------------' + Utils.getSchemaName());
                                            for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {//EDGE-154502
 
												var oeAtt = config.orderEnrichmentList[k];
											
												var oeNameVal = '';
												var oeName = Object.values(oeAtt.attributes).filter(att => {
													return att.name === 'OENAME'
												});
												if (oeName.length > 0 && oeName[0].value && oeName[0].value != null) {
													oeNameVal = oeName[0].value;
												}												

                                                var phone = '';
                                                var email = '';
                                                var phoneVal = '';
                                                var emailVal = '';
												
	

										if (oeNameVal === 'CRD' ){

                                                var notBeforeCRDValidation = new Date();
                                                notBeforeCRDValidation.setHours(0, 0, 0, 0);
                                                notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);

												
                                                var preferredCRDAttVal = '';
                                                var notBeforeCRDAttVal = '';
                                                var preferredCRDAtt = '';
                                                var notBeforeCRDAtt = '';												
												
                                                var preferredCRDAtt = Object.values(oeAtt.attributes).filter(att => {//EDGE-154502
                                                    return att.name === 'Preferred CRD'
                                                });
                                                var notBeforeCRDAtt = Object.values(oeAtt.attributes).filter(att => {//EDGE-154502
                                                    return att.name === 'Not Before CRD'
                                                });
 
                                                if (preferredCRDAtt.length > 0 && preferredCRDAtt[0].value && preferredCRDAtt[0].value != null) {
                                                    preferredCRDAttVal = preferredCRDAtt[0].value;
                                                    preferredCRDAttVal = Utils.formatDate(preferredCRDAttVal);
                                                }
                                                if (notBeforeCRDAtt.length > 0 && notBeforeCRDAtt[0].value && notBeforeCRDAtt[0].value != null) {
                                                    notBeforeCRDAttVal = notBeforeCRDAtt[0].value;
                                                    notBeforeCRDAttVal = Utils.formatDate(notBeforeCRDAttVal);
                                                }
                                                if (notBeforeCRDAtt.length !== 0 && notBeforeCRDAtt !== undefined && notBeforeCRDAtt !== '') {
                                                    //if (oeAtt.attributes.includes ('Not Before CRD') ||oeAtt.attributes.includes ('Preferred CRD') ) {	
                                                    if (notBeforeCRDAttVal < notBeforeCRDValidation) {
                                                        console.log(' OE Has Errors with dates!!!!!!!!!!!!!');
                                                        //CS.SM.updateConfigurationStatus(componentName, config.guid, false, 'Order Enrichment have Errors, Mandatory Parameter values are Missing!!');//EDGE-154502
                                                        config.status = false;
                                                        config.statusMessage = 'Order Enrichment has errors - CRD Date invalid.';//EDGE-154502
                                                        hasErrors = true;
                                                        //break;
                                                    }
                                                }
												
                                                if (notBeforeCRDAtt === '' ||   notBeforeCRDAttVal === undefined) {
                                                        console.log(' OE Has Errors with dates!!!!!!!!!!!!!');
                                                        //CS.SM.updateConfigurationStatus(componentName, config.guid, false, 'Order Enrichment have Errors, Mandatory Parameter values are Missing!!');//EDGE-154502
                                                        config.status = false;
                                                        config.statusMessage = 'Order Enrichment has errors - CRD Date invalid.';//EDGE-154502
                                                        hasErrors = true;
                                                        //break;
                                                   // }
                                                }			
												}

 
										if (oeNameVal === 'DD' ) {
											if (useExistingSIMVal !== true &&  useExistingSIMVal !== 'true') {
											
												var phone = Object.values(oeAtt.attributes).filter(att => {//EDGE-154502
                                                    return att.name === 'Phone'
                                                });
                                                var email = Object.values(oeAtt.attributes).filter(att => {//EDGE-154502
                                                    return att.name === 'Email'
                                                });	
	                                                if (phone.length > 0 && phone[0].value && phone[0].value != null) {
                                                    phoneVal = phone[0].value;
                                                }
                                                if (email.length > 0 && email[0].value && email[0].value != null) {
                                                    emailVal = email[0].value;
                                                }											
                                                if ( phoneVal === undefined  || phoneVal === 'undefined'  ||  phoneVal === ''  || email === undefined  || email === 'undefined'  ||  email === ''  ) {
                                                    //if (oeAtt.attributes.includes ('Email') ||oeAtt.attributes.includes ('Phone') ) {
                                                    //if (phoneVal === '' || phoneVal === 'undefined' || emailVal === '' || emailVal === 'undefined') {
                                                        console.log(' Phone and EMail Has Errors!!!!!!!!!!!!!' + 'phoneVal ----' + phoneVal + 'emailVal ---' + emailVal);
                                                        //CS.SM.updateConfigurationStatus(componentName, config.guid, false, 'Order Enrichment have Errors, Mandatory Parameter values are Missing!!');//EDGE-154502
                                                        config.status = false;
                                                        //config.message = 'Order Enrichment has errors - Delivery Contact invalid';//EDGE-154502
                                                        config.statusMessage = 'Order Enrichment has errors - Delivery Contact invalid';//EDGE-154502
                                                        hasErrors = true;
													
                                                        //break;
                                                   // }
                                                }

												}
										}
												
                                                if (!(hasErrors)) {
                                                    console.log(' NO Errors!!!!!!!!!!!!!');
                                                    //CS.SM.updateConfigurationStatus(componentName, config.guid, true, '');//EDGE-154502
                                                    //config.status = true;
                                                }
                                            }
                                        }
                                    }//end Cancel PaidOut chk
                                //});
								}
                            }
                        }
                    //});
					}
                }
            }
        //});
    },






updateActiveSolutionTotals: async function () {
    let currentSolution = await CS.SM.getActiveSolution();
    let currentBasket = await CS.SM.getActiveBasket();
    let inputMap = {};
    inputMap['updateSolutionTotals'] = currentSolution.id;
    //no need to wait for result
    currentBasket.performRemoteAction('SolutionActionHelper', inputMap);
}
};
var OE = {
    runRules: async function(configName, schemaName){
        console.log('runRules ', configName, schemaName);
        window.notificationHTML = '';
        let c = await CS.SM.getActiveSolution();
        var nonComm = Object.values(c.components).filter(function(item){
                return item.schema.name == configName;
            });
            console.log('nonComm 123', nonComm);
            if(nonComm && nonComm[0]) {
                console.log('nonComm ', configName, schemaName, nonComm);
                var currentConfiguration = Object.values(nonComm[0].schema.configurations).filter(function (item) {
                    return item.guid == window.activeGuid;
                });
                RuleLibrary[schemaName] = {};
                if (currentConfiguration && currentConfiguration[0]) {
                    oeShema = Object.values(nonComm[0].orderEnrichments).filter((oeSchema) => {return oeSchema.name === schemaName});
                    console.log('currentConfiguration ', currentConfiguration[0], window.activeGuid, oeShema);
                    
                    let enrichmentListSize = currentConfiguration[0].orderEnrichmentList.length;
                     
                    for (var i = 0; i < enrichmentListSize; i++) {
                        if (!oeShema || oeShema.length===0 || currentConfiguration[0].orderEnrichmentList[i].name.includes(oeShema[0].name) ||
                            currentConfiguration[0].orderEnrichmentList[i].parent === oeShema[0].id ||
                            currentConfiguration[0].orderEnrichmentList[i].parent === oeShema[0].productOptionId) {
                            
                               
                           
                                let currentGUID = currentConfiguration[0].orderEnrichmentList[i].guid;

                                setTimeout(async function (guid, schemaName) {
                                window.activeSchemaConfigGuid = guid;
                                if (typeof window.onInitOESchema[schemaName] === 'function') {
                                    var rules = await window.onInitOESchema[schemaName](guid);
                                    RuleLibrary[schemaName][guid] = rules;
                                    console.log('RuleLibrary', schemaName, guid);
                                    await OE.reducePromises(RuleLibrary[schemaName][guid]).then(async function () {
                                        console.log('After rules promises');
                                        await Utils.updateOEConfigurations(window.rulesUpdateMap);
                                        console.log('await updateOEConfigurations');
                                        if (typeof window.noPredicate[schemaName] === 'function') {
                                            await window.noPredicate[schemaName](guid);
                                        }
                                        await Utils.getConfigurationWrapper();
                                        Utils.showNotification(window.notificationHTML);
                                        if (window.notificationHTML === '') Utils.unmarkOEConfigurationInvalid(guid);
									   
                                   });
                                }
                            }, 250, currentGUID, schemaName);
                        }
                    } 
                }
            }
        //});
		return Promise.resolve(true);  							 
    },
    getPredicateResult: async function (Predicates, RuleId, GUID) {
        var GroupedPredicates = {};
        //console.group('Rule No. ' + RuleId);
        // Make Groups from list of predicates
        for (var l = 0; l < Predicates.length; l++) {
            var predicate = Predicates[l];
            if (typeof predicate.group !== 'undefined' && predicate.group !== '') {
                if (typeof GroupedPredicates[predicate.group] === 'undefined') {
                    GroupedPredicates[predicate.group] = [predicate];
                } else {
                    GroupedPredicates[predicate.group].push(predicate);
                }
            }
        }
        var groupedResults = []; // ARRAY OF GROUPED PREDICATES RESULTS
        for (var g in GroupedPredicates) { // FOR EACH GROUP OF PREDICATES
            var groupedResult = { groupConjuction: null, predicates: [], predResult: null, evalString: null }
            predResultString = '';
            for (var j = 0; j < GroupedPredicates[g].length; j++) { // ITERATE THRU PREDICATES
                // Predicates
                var groupedPredicate = await GroupedPredicates[g][j],
                    attValue = await Utils.getAttributeValue(groupedPredicate.attName, GUID), // FETCH VALUE OF ATTRIBUTE
                    evalString = '';
                if (attValue === undefined)
                    attValue = '';
                // SET GROUP CONJUCTION IF ANY, ONLY PRESENT ON LAST PREDICATE OF GROUP
                if (typeof groupedPredicate.groupConjuction !== 'undefined' && groupedPredicate.groupConjuction !== null) {
                    groupedResult.groupConjuction = groupedPredicate.groupConjuction;
                }
                // CREATE A PREDICATE EVALUATION STRING
                evalString = "'" + attValue + "'" + groupedPredicate.operator + "'" + await groupedPredicate.attValue + "'";
                console.log('evalString ', evalString);
                console.log('Evaluating ' + groupedPredicate.attName + groupedPredicate.operator + (await groupedPredicate.attValue));
                // PUSH RESULT TO GROUP RESULT PREDICATES ALONGSIDE CONJUCTION OPERATOR
                groupedResult.predicates.push({
                    eval: groupedPredicate.attName + groupedPredicate.operator + groupedPredicate.attValue,
                    evalString: evalString,
                    result: eval(evalString),
                    conjuction: groupedPredicate.conjuction
                });
            }
            // ITERATE THRU GROUP RESULT PREDICATES, COMBINE THEM TOGETHER AND EVAL ALL
            for (var k = 0; k < groupedResult.predicates.length; k++) {
                var item = groupedResult.predicates[k];
                predResultString += item.result + (item.conjuction !== null ? item.conjuction : '');
            }
            //console.log(predResultString);
            groupedResult.predResult = eval(predResultString); // SET GROUP VALIDITY
            groupedResult.evalString = predResultString;
            groupedResults.push(groupedResult);
        }
        //console.log('Grouped predicates result ', groupedResults);
        // ITERATE THRU FINAL GROUP RESULTS, COMBINE THEM ALL TO STRING AND EVAL
        var finalResultString = '';
        for (var i = 0; i < groupedResults.length; i++) {
            finalResultString += groupedResults[i].predResult + (groupedResults[i].groupConjuction !== null ? groupedResults[i].groupConjuction : "");
        }
        if (Utils.isEmpty(GroupedPredicates)) finalResultString = 'true';
        //console.log(finalResultString);
        console.groupEnd();
        return eval(finalResultString);
    },
    reducePromises: async function (rules) {
        console.log('rules: ', rules);
        const tasks = rules;
        if (!rules || rules.length === 0)
            return Promise.resolve([]);
        //console.log('tasks: ', tasks);
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
getRelatedConfigID: async function (configGUID, oeSchemaName) {
        let relConfigGUID ;
		let product = await CS.SM.getActiveSolution();
       // await CS.SM.getActiveSolution().then((currentSolution) => {
           /// if (product.type) {
			if (product.components && Object.values(product.components).length > 0) {
                    for (var i=0; i<  Object.values(product.components).length; i++) {
                        var comp =Object.values(product.components)[i];
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                            for (var j=0; j< Object.values(comp.schema.configurations).length; j++) {
							//comp.schema.configurations.forEach((config) => {
							//var config = comp.schema.configurations[j];	
							var config = Object.values(comp.schema.configurations)[j];							
							if (config.guid === configGUID){
								if(config.relatedProductList && config.relatedProductList.length > 0 ){
									config.relatedProductList.forEach((relatedConfig) => {
									if ( relatedConfig.name === oeSchemaName){
										relConfigGUID	 = relatedConfig.guid;
										//console.log ( 'relConfigGUID ----------- for Schema ' , relConfigGUID + oeSchemaName);
									}
								});//for each Related END 		
								}		
							}								
							//}); // For Each Config END
								if (relConfigGUID)
									break;	
                            } // end For
                        }
                        if (relConfigGUID)
                            break;
                    }
                }
            //}
       // });
        return relConfigGUID;
    },	//ENd Method




	
	/**
 * Author      : Laxmi Rahate  2020-07-20
 * Ticket      : EDGE-154696
 * Description : Generic Method to get getRelatedAttribute value Based on OEGUID and schema name
 */
    getRelatedConfigAttrValue: async function (paramConfig, AttributeName, schemaName) {
        
		attrVal = '';
		if (paramConfig) {

				var relatedProductList = paramConfig.getRelatedProducts();		
				 for (var j=0; j< Object.values(relatedProductList).length; j++) {
						var relatedConfig = Object.values(relatedProductList)[j];	

						if ( relatedConfig.name === schemaName){
						var attributeVal = Object.values(relatedConfig.configuration.attributes).filter(att => {
						return att.name === AttributeName
						});
						//console.log ('attributeVal ************************',attributeVal)	
						if(attributeVal.length >0 &&attributeVal[0].value &&attributeVal[0].value != null){			
						attrVal = attributeVal[0].value;
						}	

						if (attrVal)
						break;	
						}
				}					


		}
			return attrVal;

			
		},
		
/***getRelatedConfigID: async function (paramConfig, schemaName) {
	    let relConfigGUID	= '';
        if(paramConfig){ 
            let relatedProductList = paramConfig.getRelatedProducts();
            for (let j=0; j< Object.values(relatedProductList).length; j++) {
                let relatedConfig = Object.values(relatedProductList)[j];    
                if ( relatedConfig.name === schemaName){
                    relConfigGUID = relatedConfig.guid;
                } 
        } 
    } 
        return relConfigGUID;
    } 	
		
	**/	

	}

;