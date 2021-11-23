// MC 2020-08-18: Please use a formatter so everything is formatted consistently, after you got through all the comments.
/******************************************************************************************************************************************************
Sr.No.		Author 			      Date			   Sprint   		Story Number	Description
1. 		 Jagadeswary			 8-01-2021		    21.01	        EDGE-197534
2. 		 Jagadeswary			 11-01-2021		    21.01	        EDGE-197199
3.      Antun B.                20-01-2021         21.01           EDGE-198536     Optimizing PRE response processing (we no longer update all configs 
                                                                                    from PRE response if only one config attribute was changed)
4.      Antun B.                25-01-2021          21.01           EDGE-188712     Pricing attributes set before cancelation logic was called
5.      Antun B.                25-01-2021          21.01           INC000094814023 Enable RP cancel scenario
6.      Madhu Gaurav		    07-06-2021	        21.08           INC000095959063  fix	 
7.      Shubhi V                16/07/2021          21.09           DIGI-1853      INC000095494999/DIGI-1853 fix CLi for ETC
8        . Vivek               08/11/2021           21.11           DIGI-3208
9.      Sandip D                25/08/2021          21.11           DIGI-10303 - Fixed find function issue
*******************************************************************************************************************************************************/

var ngucVariables = {

    NGUC_OFFER_NAME: 'Adaptive Collaboration',
    NGUC_PROF_SERV_OFFR_NAME: 'Adaptive Collaboration Professional Services',
    NGUC_TENANCY_OFFER_NAME: 'Adaptive Collaboration Tenancy'
};

console.log('Loaded PRE Logic');
if (!CS || !CS.SM) {
    throw Error('Solution Console Api not loaded?');
}
const PRE_Logic = {};
var mainSolutionName = 'Dummy'; //to be set on solution load in main plugin
var PREfindComponentByConfigGuidCache = new Map(); //EDGE-198536
const Const = {
    //mainSolutionName: 'Connectivity Solution',
    catalogueCodeAttributeName: 'CatalogueCode',
    preDiscountsAttributeName: 'PRE Discounts',
    cpAttributeName: 'CommercialProductCode',
    preBundleAttributeName: 'Bundle',
    totalPriceForMonths: 12, //12 matches calculations done on cfg side as it is annualized price
    //added for INC000095494999/DIGI-1853 
    etcAttributeName: 'EarlyTerminationCharge',
    etcListCharge: {
        "source": "EarlyTerminationCharge",
        "version": "3-1-0",
        "discountPrice": "list",
        "discountCharge": "EarlyTerminationCharge",
        "amount": 0,
        "type": "override", "chargeType": "oneOff", "recordType": "single",
        "customData": { "promotion": true },
        "description": "EarlyTerminationCharge"
    }
}
//where each bundle should be "stored"
const BundleCarrierConfigName = [{
    bundleStartsWith: 'Business IP',
    carrierConfigName: 'IPVPN Endpoint'
},
{
    bundleStartsWith: 'BIP',
    carrierConfigName: 'IPVPN Endpoint'
},
{
    bundleStartsWith: 'Connect IP',
    carrierConfigName: 'IPVPN Endpoint'
},
{
    bundleStartsWith: 'CIP',
    carrierConfigName: 'IPVPN Endpoint'
},
{
    bundleStartsWith: 'TID',
    carrierConfigName: 'Internet'
}
]; //To-Do replace TID?
let RetrievedData = {
    prToPrgMap: undefined
};
class ClassWatcher {
    constructor(targetNode, classToWatch, classAddedCallback, classRemovedCallback) {
        this.targetNode = targetNode;
        this.classToWatch = classToWatch;
        this.classAddedCallback = classAddedCallback;
        this.classRemovedCallback = classRemovedCallback;
        this.observer = null;
        this.lastClassState = targetNode.classList.contains(this.classToWatch);
        this.init();
    }
    init() {
        this.observer = new MutationObserver(this.mutationCallback);
        this.observe();
    }
    observe() {
        this.observer.observe(this.targetNode, {
            attributes: true
        });
    }
    disconnect() {
        this.observer.disconnect();
    }
    mutationCallback = mutationsList => {
        for (let mutation of mutationsList) {
            if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
                let currentClassState = mutation.target.classList.contains(this.classToWatch);
                if (this.lastClassState !== currentClassState) {
                    this.lastClassState = currentClassState;
                    if (currentClassState) {
                        this.classAddedCallback();
                    } else {
                        this.classRemovedCallback();
                    }
                }
            }
        }
    }
}
// MC 2020-08-18: It is evident that the init function is called init, do you need the comment?
//init
PRE_Logic.init = function (mainSolName) {
    console.log('PRE_Logic initialised for: ' + mainSolName);
    mainSolutionName = mainSolName;
    //Initialize sidebar (pricing summary panel) logic as it is now required
    SidebarLogic.init();
    // MC 2020-08-18: This function call is async. Is it intentional not to wait for it to resolve?
    PRE_Logic.getPrToPrgMap();
}
// define all PRE_Logic functions
// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// N milliseconds. If `immediate` is passed, trigger the function on the
// leading edge, instead of the trailing.
PRE_Logic.debounceF = function (func, wait, immediate) {
    var timeout;
    return function () {
        var context = this,
            args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) {
                func.apply(context, args);
            }
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) {
            func.apply(context, args);
        }
    };
}
PRE_Logic.wait = function () {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve();
        }, 100)
    });
}
PRE_Logic.debouncedCalculateTotalPricesUsingPRE = PRE_Logic.debounceF(
    () => {
        return PRE_Logic.calculateTotalPricesUsingPRE();
    },
    500
)
PRE_Logic.makeDiscountReadOnlyForDealManagementPackage = function (discount) {
    if (discount) {
        discount.customData = Object.assign(discount.customData || {}, {
            promotion: true
        });
    }
    return discount;
}
PRE_Logic.copySourceToDescription = function (discount) {
    if (discount) {
        discount.description = discount.description || discount.source;
        //quick fix for T-51875, needs to be removed once delivered
        if (discount.type && discount.type === 'init') {
            discount.type = 'override';
        }
    }
    return discount;
}
// MC 2020-08-18: A large function, could it be split into smaller componentes, potentially?
PRE_Logic.attachDiscountsAndChargesToConfigurations = async function (currentPRECart, skipRemoteAction) {
    const solution = await CS.SM.getActiveSolution();
    const allConfigs = PRE_Logic.getSolutionConfigurations(solution);
    const payload = {};
    const attrUpdateArray = [];
    //Variable to hold all the parent components for the related products
    const relatedProductsWithParentComponent = await PRE_Logic.getRelatedProductsWithParentComp(solution);
    for (const cartItem of currentPRECart.items) {
        const guid = cartItem.id;
        const discounts = cartItem.pricing.discounts;
        const stringifiedDiscounts = JSON.stringify({
            discounts: discounts.map(PRE_Logic.makeDiscountReadOnlyForDealManagementPackage).map(PRE_Logic.copySourceToDescription)
        });
        const config = allConfigs.find(config => config.guid === guid);
        const carrierConfigGuid = await PRE_Logic.getCarrierConfigurationGuid(cartItem.catalogueItemId);
        //we wouldn't have config for promotional items so nothing to update
        if (config) {
            if (config.id) {
                //config exists but still not saved so again no point in updating
                payload[config.id] = stringifiedDiscounts;
            }
            let retVal = await PRE_Logic.setSmAttributeValueByGuid(guid, Const.preDiscountsAttributeName, stringifiedDiscounts, 'return');
            //clear bundle name, will be set if we have bundles
            let retVal2 = await PRE_Logic.setSmAttributeValueByGuid(guid, Const.preBundleAttributeName, '', 'return');
            retVal.updateMap[guid] = retVal.updateMap[guid].concat(retVal2.updateMap[guid]);
            attrUpdateArray.push(retVal);
        } else if (carrierConfigGuid) {
            //no matching configs so it is a bundle
            let retVal = await PRE_Logic.setSmAttributeValueByGuid(carrierConfigGuid, Const.preDiscountsAttributeName, stringifiedDiscounts, 'return');
            let retVal2 = await PRE_Logic.setSmAttributeValueByGuid(carrierConfigGuid, Const.preBundleAttributeName, cartItem.catalogueItemId, 'return');
            //merge update maps, needs better way
            retVal.updateMap[carrierConfigGuid] = retVal.updateMap[carrierConfigGuid].concat(retVal2.updateMap[carrierConfigGuid]);
            attrUpdateArray.push(retVal);
        }
        // TODO: get and set the PRG Codes to attributes
    }
    const componentToUpdateMapMap = attrUpdateArray.reduce((acc, curr) => {
        if (!acc[curr.componentName]) {
            acc[curr.componentName] = {};
        }
        // MC 2020-08-18: Object assign works without returning the value, e.g. Object.assign(target, source) - The target will have the values set.
        acc[curr.componentName] = Object.assign(acc[curr.componentName], curr.updateMap);
        return acc;
    }, {});
    for (let componentName of Object.keys(componentToUpdateMapMap)) {
        for (var x = 0; x < Object.keys(componentToUpdateMapMap[componentName]).length; x++) {
            let currComponent = solution.getComponentByName(componentName);
            // Check if the config is a related product or parent product
            if (Object.keys(relatedProductsWithParentComponent).includes(Object.keys(componentToUpdateMapMap[componentName])[0])) {
                await relatedProductsWithParentComponent[Object.keys(componentToUpdateMapMap[componentName])[x]].updateConfigurationAttribute(Object.keys(componentToUpdateMapMap[componentName])[x], Object.values(componentToUpdateMapMap[componentName])[x]);
            }
            else {

                if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {
                    loadedSolutionUC.lock('Commercial', false);
                }
                await currComponent.updateConfigurationAttribute(Object.keys(componentToUpdateMapMap[componentName])[x], Object.values(componentToUpdateMapMap[componentName])[x]);
                if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {

                    loadedSolutionUC.lock('Commercial', true);
                }
            }
        }
    }
    if (!skipRemoteAction) {
        //let currentBasket = await CS.SM.getActiveBasket();
        //return currentBasket.performRemoteAction('PREConfigurationUpdater', payload);
    }
}
PRE_Logic.getPrToPrgMap = async function () {
    if (!RetrievedData.prToPrgMap) {
        let currentBasket = await CS.SM.getActiveBasket();
        RetrievedData.prToPrgMap = await currentBasket.performRemoteAction('PRG_Data_Retriever', {});
    }
    return RetrievedData.prToPrgMap;
}
PRE_Logic.getRelatedProductsWithParentComp = function (solution) {
    var relconfigMap = {};
    Object.values(solution.components).forEach((component) => {
        Object.values(component.relatedComponents).forEach((relComp) => {
            Object.keys(relComp.schema.configurations).forEach((relConfig) => {
                relconfigMap[relConfig] = component;
            });
        });
    });
    return relconfigMap;
}
// MC 2020-08-18: This function needs to be formatted properly
PRE_Logic.getSolutionConfigurations = function (solution) {
    var allConf = [];
    var configs = Object.values(solution.getAllConfigurations());
    configs.forEach(config => {
        //first add parent then RP so that we have everything nicely sorted
        allConf.push(config);
        config.relatedProductList.forEach(rp => allConf.push(rp.configuration));
    });

    return allConf.filter(config => !config.macLock && (!config.disabled || config.softDeleted)); //ignoring all MACD PC that are not editable i.e. not added to basket
    // MC 2020-08-18: If this is tracked through Copado, remove the commented code if it is not used
    //return Object.values(solution.getAllConfigurations());
    /*
    const allConfigs = solution.schema.configurations || [];
    return solution.components.reduce((acc, curr) => {
    const relatedProducts = curr.schema.configurations
    	.map(config => config.relatedProductList)
    	.reduce((acc, curr) => {
    		return acc.concat(curr.map(relatedProduct => {
    			return {
    				...relatedProduct.configuration,
    				isRelatedProduct: true
    			}
    		}));
    	}, []);
    return acc.concat(curr.schema.configurations).concat(relatedProducts);
    }, allConfigs);
    */
}
// MC 2020-08-18: Remove commented code if it is not used
PRE_Logic.getPricingRuleGroupsForSolution = function (solution) {
    const famPRGsAttributeName = 'Frame Agreement PRGs';
    const configurations = solution.getConfigurations();
    const cataloguePRG = configurations[0].getAttribute(Const.catalogueCodeAttributeName);
    //const cataloguePRG = attributes.find(it => it.name === Const.catalogueCodeAttributeName);
    const famPRGs = configurations[0].getAttribute(famPRGsAttributeName);
    //const famPRGs = solution.schema.configurations[0].attributes.find(it => it.name === famPRGsAttributeName);
    return [cataloguePRG ? cataloguePRG.value : ''].concat(famPRGs ? famPRGs.value.split(',') : []).filter(Boolean);
}

PRE_Logic.findComponentByConfigGuid = async function (configGuid) {
    const solution = await CS.SM.getActiveSolution();
    for (const component of Object.values(solution.components)) {
        for (const configuration of Object.values(component.schema.configurations)) {
            if (configuration.guid === configGuid) {
                return component;
            } else {
                for (const relatedComponent of Object.values(component.relatedComponents)) {
                    for (const relConfig of Object.values(relatedComponent.schema.configurations)) {
                        if (relConfig.guid === configGuid) {
                            return relatedComponent;
                        }
                    }
                }
            }
        }
    }
    for (const config of Object.values(solution.schema.configurations)) {
        if (config.guid === configGuid) {
            return solution;
        }
    }
    return;
}
// EDGE-198536 start
//builds component to config guids map to be used as a cache
PRE_Logic.buildFindComponentByConfigGuidCache = async function () {
    PREfindComponentByConfigGuidCache = new Map();
    const solution = await CS.SM.getActiveSolution();
    for (const component of Object.values(solution.components)) {
        PREfindComponentByConfigGuidCache.set(component, Object.keys(component.schema.configurations));
        for (const configuration of Object.values(component.schema.configurations)) {
            for (const relatedComponent of Object.values(component.relatedComponents)) {
                PREfindComponentByConfigGuidCache.set(relatedComponent, Object.keys(relatedComponent.schema.configurations));
            }
        }
    }
    PREfindComponentByConfigGuidCache.set(solution, Object.keys(solution.schema.configurations));
}
//cached version of findComponentByConfigGuid, buildFindComponentByConfigGuidCache MUST be called before using this method 
//so it only makes sense to use this method when expecting many calls
PRE_Logic.findComponentByConfigGuidCached = async function (configGuid) {
    //components are keys
    for (comp of PREfindComponentByConfigGuidCache.keys()) {
        if (PREfindComponentByConfigGuidCache.get(comp).contains(configGuid)) {
            return comp;
        }
    }
    return;
}
//EDGE-198536 end

PRE_Logic.getSmAttributeValue = async function (configName, attributeName) {
    const solution = await CS.SM.getActiveSolution();
    const solutionConfigurations = PRE_Logic.getSolutionConfigurations(solution);
    const config = solutionConfigurations.find(c => {
        return c.configurationName === configName;
    });
    if (!config) {
        return '';
    }
    //DIGI-10303 - Start - Fix to remove .find function
    /*const attribute = config.attributes.find((at) => {
        return at.name === attributeName;
    });*/
    const attribute = config.attributes[attributeName.toLowerCase()];
    //DIGI-10303 - End
    if (!attribute) {
        return '';
    }
    return attribute.value;
}
PRE_Logic.setSmAttributeValue = async function (configName, attributeName, attributeValue, returnOrUpdate) {
    const solution = await CS.SM.getActiveSolution();
    const solutionConfigurations = PRE_Logic.getSolutionConfigurations(solution);
    const config = solutionConfigurations.find(c => {
        return c.configurationName === configName;
    });
    if (!config) {
        return;
    }
    return PRE_Logic.setSmAttributeValueByGuid(config.guid, attributeName, attributeValue, returnOrUpdate);
}
PRE_Logic.setSmAttributeValueByGuid = async function (configGuid, attributeName, attributeValue, returnOrUpdate) {
    const currentSoln = await CS.SM.getActiveSolution();
    if (!returnOrUpdate) {
        returnOrUpdate = 'update';
    }
    const updateMap = {
        [configGuid]: [{
            name: attributeName,
            value: attributeValue,
            displayValue: attributeValue
        }]
    };
    const componentByName = await PRE_Logic.findComponentByConfigGuid(configGuid);
    const componentName = componentByName.name;
    if (returnOrUpdate === 'return') {
        return {
            componentName: componentName,
            updateMap: updateMap
        }
    } else if (returnOrUpdate === 'update') {
        // Check if the config is a related product or parent product
        if (Object.keys(relatedProductsWithParentComponent).includes(configGuid)) {
            await relatedProductsWithParentComponent[configGuid].updateConfigurationAttribute(configGuid, updateMap[configGuid]);
        }
        else {
            var currComp = currentSoln.findComponentsByConfiguration(configGuid);
            if (currComp) {
                await currComp.updateConfigurationAttribute(configGuid, updateMap[configGuid]);
            } else {
                await currentSoln.updateConfigurationAttribute(configGuid, updateMap[configGuid]);
            }
        }
    }
}

//EDGE-198536 method now has input param
PRE_Logic.calculateTotalPricesUsingPRE = async function (config) {
    console.log('PRE_Logic Calculating prices...');
    const version = '3-1-0';
    const cancAttributeName = 'Cancelled By Change Process';
    function getCommonCartSpec(id, pricingRuleGroupCodes) {
        return {
            version: version,
            id: id,
            pricingRuleGroupCodes: pricingRuleGroupCodes
        }
    }
    // MC 2020-08-18: Please remove all debugging comments and unused commented out code
    function toCartItem(config) {
        // perhaps a better mechanism of fetching sku/code?
        const catalogueItemAttr = config.attributeList.find(attr => attr.name === Const.cpAttributeName && attr.value);
        const catalogueItemId = catalogueItemAttr ? catalogueItemAttr.value : undefined;
        //console.log('>>>> ' + JSON.stringify(config.configurationName));
        //console.log('>>>> ' + JSON.stringify(config.configurationName) + 'isDisabled >> ' + config.disabled);
        const cancCatalogueItemAttr = config.attributeList.filter(attr => attr.name === cancAttributeName && attr.value);
        //console.log('cancCatalogueItemAttr = >> ' + JSON.stringify(cancCatalogueItemAttr));
        //console.log('cancCatalogueItemAttr.value = >> ' + cancCatalogueItemAttr[0].value);
        const cancCatalogueItemId = (cancCatalogueItemAttr && cancCatalogueItemAttr.length > 0) ? cancCatalogueItemAttr[0].value : undefined;
        //console.log('cancCatalogueItemId = >> ' + cancCatalogueItemId);
        let childItems = {};
        let selectedProducts = [];
        // get the related products data for the request
        config.relatedProductList.forEach((relProd) => {
            if (relProd.configuration.attributes['commercialproductcode'].value) {
                selectedProducts.push(toCartItem(relProd.configuration));
            }
        });
        childItems['selectedRelatedProducts'] = selectedProducts;
        if (catalogueItemId && !cancCatalogueItemId) {
            var qtyToUse;
            if (config.configurationProperties && config.configurationProperties.quantity) {
                qtyToUse = parseInt(config.configurationProperties.quantity);
            } else {
                qtyToUse = 1;
            }
            return {
                version: version,
                id: config.guid, // check if use something else
                // MC 2020-08-18: the quantity property needs to be formatted, it is unreadable at the moment
                quantity: qtyToUse, //was: quantity: (config.configurationProperties!= undefined)?(config.configurationProperties.quantity!= undefined?parseInt(config.configurationProperties.quantity):1):1,// If configuration properties hold the value then the quantity, else 1
                catalogueItemId: catalogueItemId,
                childItems: childItems
            }
        }
    }
    function uuidv4() {
        return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
            (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
        );
    }
    function setTotalSolutionValue(totalOneOff, totalRecurring) {
        function financial(x) {
            return Number.parseFloat(x).toFixed(3);
        }
        const total = totalOneOff + totalRecurring;
        document.querySelectorAll('.pricing-table-header .price .total-value')[0].innerText = financial(total);
    }
    // MC 2020-08-18: The code below needs to be formatted, please use a formatter in the future
    // MC 2020-08-18: Please remove unused code instead of commenting it out
    const solution = await CS.SM.getActiveSolution();
    // EDGE-198536 start
    let updateAllowedForGuids = [];
    if (config) {
        let itemConfig = solution.getConfiguration(config.guid);
        updateAllowedForGuids.push(config.guid); //add parent
        itemConfig.relatedProductList.forEach((relProd) => {
            updateAllowedForGuids.push(relProd.guid); //add all child products
        });
    }
    // EDGE-198536 end
    //const pricingRuleGroupCodes = ["TID_Premium"];
    var pricingRuleGroupCodes = []; //PRE_Logic.getPricingRuleGroupsForSolution(solution);
    if (pricingRuleGroupCode != undefined) {
        if (pricingRuleGroupCode.length > 0) {
            pricingRuleGroupCodes = pricingRuleGroupCodes.concat(pricingRuleGroupCode);
        }
    }
    /*
    if (!pricingRuleGroupCodes || pricingRuleGroupCodes.length === 0) {
    return;
    }
    */
    const configurations = PRE_Logic.getSolutionConfigurations(solution);
    const commonCart = {
        ...getCommonCartSpec(uuidv4(), pricingRuleGroupCodes),
        items: [
            ...Object.values(configurations).map(toCartItem).filter(Boolean)
        ]
    };
    console.log(commonCart);
    const start = performance.now();
    let currentBasket = await CS.SM.getActiveBasket();
    const result = await currentBasket.performRemoteAction('PREApiV4Pricings', {
        payload: JSON.stringify(commonCart)
    })
    const end = performance.now();
    console.log('Request time: ' + (end - start).toFixed(2) + 'ms');
    const body = JSON.parse(result.body);
    console.info('Received:', body);
    // MC 2020-08-18: Please find a better name for the variable, discData doesn't provide usefule meaning
    // MC 2020-08-18: What is the data supposed to be, please think about the variable name
    var discData = {};
    discData[ngucVariables.NGUC_OFFER_NAME] = {    // DIGI-3208
        'Devices': ['Early Adoption Discount'],
        'Accessories': ['Early Adoption Discount']
    };
    var configIdsWithCompName = {};
    var configIdsWithContractTerm = {};
    var productName = '';
    // Map to hold the contract term and the changetype for the configuration GUID
    // MC 2020-08-18: The active solution is fetched on line 507, why do you need to fetch it again?
    // MC 2020-08-18: Please remove out commented code if it will not be used.
    await CS.SM.getActiveSolution().then((product) => {
        productName = product.name;
        //if (Object.keys(discData).includes(product.name)) {
        Object.values(product.components).forEach((comp) => {
            Object.values(comp.schema.configurations).forEach((config) => {
                configIdsWithCompName[config.guid] = comp.name;
                configIdsWithContractTerm[config.guid] = {};
                // MC 2020-08-18: This needs to be formatter better, it is unreadable at the moment
                //not all configs have contractterm so we need to be aware of multiple attributes
                var ctAttribute;
                if (config.attributes['contracttermstring']) {
                    ctAttribute = config.attributes['contracttermstring'];
                } else {
                    ctAttribute = config.attributes['contractterm'];
                }
                configIdsWithContractTerm[config.guid]['contractTerm'] = (ctAttribute != undefined ? (ctAttribute.displayValue != '' ? ctAttribute.displayValue.toString().split(' ')[0] : 12) : 12);  //Added .toString() to fix incident INC000095959063
                configIdsWithContractTerm[config.guid]['changeType'] = (config.attributes['changetype'] != undefined ? config.attributes['changetype'].value : 'New');
            });
        });
        //}
    });
    // MC 2020-08-18: Please remove debugging comments
    var priceKeysList = [
        'listOneOffPrice',
        'listRecurringPrice',
        'salesOneOffPrice',
        'salesRecurringPrice',
        'totalListOneOffPrice',
        'totalListRecurringPrice',
        'totalSalesOneOffPrice',
        'totalSalesRecurringPrice',
        'unitListOneOffPrice',
        'unitListRecurringPrice',
        'unitSalesOneOffPrice',
        'unitSalesRecurringPrice'
    ];

    if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {
        loadedSolutionUC.lock('Commercial', false);
    }

    /******
    * Method  to make the price values as 0 for the configuration if the change type is 'Cancel'
    ******/
    // MC 2020-08-18: Why does the function contain the "Method" in the name? It provides no value, please think of a better name
    function changeTypeCancelMethod(item) {
        var listofChildIds = [];
        body.cart.items.forEach((crtItem) => {
            if (item.id === crtItem.id) {
                listofChildIds.push(crtItem.id);
                if (crtItem.childItems != null) {
                    crtItem.childItems.selectedRelatedProducts.forEach((childItem) => {
                        listofChildIds.push(childItem.id);
                        priceKeysList.forEach((key) => {
                            childItem.pricing[key] = 0;
                        });
                        childItem.pricing.discounts = [];
                    });
                }
            }
        });
        if (listofChildIds !== 'undefined' && listofChildIds.length > 0) {
            body.cart.items.forEach((crtItem) => {
                if (listofChildIds.contains(crtItem.id)) {
                    priceKeysList.forEach((key) => {
                        body.cart.pricing[key] -= crtItem.pricing[key];
                        crtItem.pricing[key] = 0;
                    });
                    crtItem.pricing.discounts = [];
                }
                //INC000095494999/DIGI-1853 Start
                //handle ETC here but only for parent, child ETC will be handled in changeTypeModifyMethod
                if (item.id === crtItem.id) {
                    let itemConfig = solution.getConfiguration(item.id);
                    var etc = itemConfig.attributes[Const.etcAttributeName.toLowerCase()];
                    if (etc && etc.value && Number.parseFloat(etc.value) > 0) {
                        var etcValue = Number.parseFloat(etc.value);
                        var etcCharge = Const.etcListCharge;
                        etcCharge.amount = etcValue;
                        if (solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname || solution.name === NEXTGENUC_COMPONENTS.solution) {
                            etcCharge.customData = { "promotion": true, "ETCBusinessID": 'DMCAT_NonRecurringCharge_000751' };
                        }
                        crtItem.pricing.discounts.push(etcCharge);
                        //console.log(crtItem);
                    }
                }
                //INC000095494999/DIGI-1853 End
            });
        }

    }
    /******
    * Method  to remove the discount values from the response if the change type is 'Cancel', If the discount is mentioned in the Map discData
    ******/
    // MC 2020-08-18: Why does the function contain the "Method" in the name? It provides no value, please think of a better name
    // MC 2020-08-18: Please format the method, this is unreadable
    function changeTypeModifyMethod(item) {
        if (Object.keys(configIdsWithCompName).includes(item.id)) {
            if (discData[productName] && Object.keys(discData[productName]).includes(configIdsWithCompName[item.id])) {
                item.pricing.discounts.forEach((disc) => {
                    if (discData[productName][configIdsWithCompName[item.id]].includes(disc.source)) {
                        let chrgType = disc.chargeType;
                        let discPrice = disc.discountPrice;
                        // MC 2020-08-18: Template strings should be used where possible, this is hard to understand
                        discTotalPrice = 'total' + discPrice[0].toLocaleUpperCase() + discPrice.slice(1, discPrice.length);
                        discUnitPrice = 'unit' + discPrice[0].toLocaleUpperCase() + discPrice.slice(1, discPrice.length);
                        chrgType = chrgType[0].toLocaleUpperCase() + chrgType.slice(1, chrgType.length);
                        // MC 2020-08-18: disc.discountPrice + chrgType + 'Price' - this could be extracted to a variable
                        if (priceMapToAdd[disc.discountPrice + chrgType + 'Price'] != undefined) {
                            priceMapToAdd[disc.discountPrice + chrgType + 'Price'] += disc.amount;
                            priceMapToAdd[discTotalPrice + chrgType + 'Price'] += disc.amount;
                            priceMapToAdd[discUnitPrice + chrgType + 'Price'] += disc.amount;
                        } else {
                            priceMapToAdd[disc.discountPrice + chrgType + 'Price'] = disc.amount;
                            priceMapToAdd[discTotalPrice + chrgType + 'Price'] = disc.amount;
                            priceMapToAdd[discUnitPrice + chrgType + 'Price'] = disc.amount;
                        }
                        if (itemDiscMap[disc.discountPrice + chrgType + 'Price'] != undefined) {
                            itemDiscMap[disc.discountPrice + chrgType + 'Price'] += disc.amount;
                            itemDiscMap[discTotalPrice + chrgType + 'Price'] += disc.amount;
                            itemDiscMap[discUnitPrice + chrgType + 'Price'] += disc.amount;
                        } else {
                            itemDiscMap[disc.discountPrice + chrgType + 'Price'] = disc.amount;
                            itemDiscMap[discTotalPrice + chrgType + 'Price'] = disc.amount;
                            itemDiscMap[discUnitPrice + chrgType + 'Price'] = disc.amount;
                        }
                        item.pricing.discounts.remove(disc);
                    }
                });
            }
        }
    }

    let priceMapToAdd = {};
    let totalSolutionOneOffCharge = 0;
    let totalSolutionRecurringCharge = 0;
    let listOfCanceledChildItems = []; //INC000094814023 canceled child items where parent is not canceled
    await PRE_Logic.buildFindComponentByConfigGuidCache(); //INC000095494999/DIGI-1853 moved here
    Object.values(body.cart.items).forEach((item) => {
        //EDGE-198536 start: save performance by skipping the rest of current iteration if we will not update any configs
        if (updateAllowedForGuids.length > 0 && !updateAllowedForGuids.contains(item.id)) {
            return; //this skips just the current iteration of body.cart.items.forEach
        }
        //EDGE-198536 end
        //get configuration this item represents so we can check if it is RP or not
        let itemConfig = solution.getConfiguration(item.id);
        let itemDiscMap = {};
        if (configIdsWithContractTerm[item.id]) {
            if (configIdsWithContractTerm[item.id].changeType == 'Cancel') {
                changeTypeCancelMethod(item);

            } else if (configIdsWithContractTerm[item.id].changeType == 'Modify' || configIdsWithContractTerm[item.id].changeType == 'Active') {

                //INC000094814023 start handle possible child item cancelation (parent cancelation is handled by if part) when parent is NOT canceled
                item.childItems.selectedRelatedProducts.forEach((childItem) => {
                    let childConfig = solution.getConfiguration(childItem.id);
                    //let childChangeType = childConfig.attributes['changetype']?.value || 'New'; //not supported in chrome??
                    let childChangeType = (childConfig.attributes['changetype'] && childConfig.attributes['changetype'].value) ? childConfig.attributes['changetype'].value : 'New';
                    if (childChangeType == 'Cancel') {
                        listOfCanceledChildItems.push(childItem.id); //remember the id as RP are repeated at the end of the response
                        priceKeysList.forEach((key) => {
                            //child affects only total pricing
                            if (key.startsWith('total')) {
                                //decrease parent pricing
                                item.pricing[key] -= childItem.pricing[key];
                                //decrease total pricing (as it is sum of parents)
                                body.cart.pricing[key] -= childItem.pricing[key];
                            }
                            //0 child item pricing as it is canceled
                            childItem.pricing[key] = 0;
                        });
                        //0 child item pricing discounts as it is canceled
                        childItem.pricing.discounts = [];
                        //INC000095494999/DIGI-1853 Start
                        //handling ETC on child items
                        var etc = childConfig.attributes[Const.etcAttributeName.toLowerCase()];
                        if (etc && etc.value && Number.parseFloat(etc.value) > 0) {
                            var etcValue = Number.parseFloat(etc.value);
                            var etcCharge = Const.etcListCharge;
                            etcCharge.amount = etcValue;
                            if (solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname || solution.name === NEXTGENUC_COMPONENTS.solution) {
                                etcCharge.customData = { "promotion": true, "ETCBusinessID": 'DMCAT_NonRecurringCharge_000751' };
                            }
                            crtItem.pricing.discounts.push(etcCharge);
                            //console.log(crtItem);
                        }
                        //INC000095494999/DIGI-1853 End
                    }
                });
                //INC000094814023 end
                //handle modify part for the parent
                changeTypeModifyMethod(item);
            }
            let priceKeys = Object.keys(itemDiscMap);
            priceKeys.forEach((key) => {
                item.pricing[key] += itemDiscMap[key];
            });
        }
        //INC000094814023 start RP are repeated at the end of the response so we need to clear those that were canceled (processed under parent item)
        if (listOfCanceledChildItems.contains(item.id)) {
            priceKeysList.forEach((key) => {
                item.pricing[key] = 0;
            });
            item.pricing.discounts = [];
        }
        //INC000094814023 end
        if (itemConfig && itemConfig.parentConfiguration === "") {
            //taking into account only parent configurations as they already include RP charges
            totalSolutionOneOffCharge += item.pricing.totalSalesOneOffPrice;
            totalSolutionRecurringCharge += item.pricing.totalSalesRecurringPrice * (configIdsWithContractTerm[item.id] != undefined ? configIdsWithContractTerm[item.id]['contractTerm'] : 12);
        }
    });
    Object.keys(priceMapToAdd).forEach((priceVal) => {
        body.cart.pricing[priceVal] += priceMapToAdd[priceVal];
    });
    //EDGE-188712 start - whole body.cart.items.forEach(async (crtItem) block moved after cancel/modify modification to pricing
    //EDGE-198536 build cache as PRE_Logic.findComponentByConfigGuid(crtItem.id); is time intensive as it loops over everything all the time
    //await PRE_Logic.buildFindComponentByConfigGuidCache(); //INC000095494999/DIGI-1853 moved this code slightly up

    body.cart.items.forEach(async (crtItem) => {
        //Changing the discount charge to Discount source + Discount chargetype EDGE-169456
        crtItem.pricing.discounts.forEach((discount) => {
            if (discount["type"] == "override" && discount["source"] != 'EarlyTerminationCharge') { //INC000095494999/DIGI-1853 added etc to condition
                discount["discountCharge"] = 'BasePrices'; //value needs to be same for BasePrices and FAM otherwise it will be considered as 2 charges
                discount["description"] = 'BasePrices'; //description is used for SLI Name so we need to set it to this due to PS MS integration
                //discount["source"] = 'BasePrices'; do not change as this is only identifier of where this price came from, also used on quote/contract to find base price
            }
        });
        //EDGE-198536 start: save performance by skipping the rest of current iteration if we will not update any configs
        if (updateAllowedForGuids.length > 0 && !updateAllowedForGuids.contains(crtItem.id)) {
            return; //this skips just the current iteration of body.cart.items.forEach
        }
        //EDGE-198536 end
        //not using total prices as we introduced Qty so we need to use sales prices
        var currComponent = solution.findComponentsByConfiguration(crtItem.id); //this covers related products as well so better approach
        let componentForGuid = await PRE_Logic.findComponentByConfigGuidCached(crtItem.id); //EDGE-198536
        //default list of attributes we would need updating
        // EDGE-198536 start
        const stringifiedDiscounts = JSON.stringify({
            discounts: crtItem.pricing.discounts.map(PRE_Logic.makeDiscountReadOnlyForDealManagementPackage).map(PRE_Logic.copySourceToDescription)
        });
        //EDGE-198536 end
        let updateMap =
            [
                { name: 'OC', value: crtItem.pricing.salesOneOffPrice, displayValue: crtItem.pricing.salesOneOffPrice },
                { name: 'OneOffCharge', value: crtItem.pricing.salesOneOffPrice, displayValue: crtItem.pricing.salesOneOffPrice },
                { name: 'RC', value: crtItem.pricing.salesRecurringPrice, displayValue: crtItem.pricing.salesRecurringPrice },
                { name: 'IR Charge', value: crtItem.pricing.salesRecurringPrice, displayValue: crtItem.pricing.salesRecurringPrice },
                { name: Const.preDiscountsAttributeName, value: stringifiedDiscounts, displayValue: stringifiedDiscounts } //EDGE-198536
            ];
        //exclusion logic for specific cases like HRO for devices, removes some attributes from update map //krunal - added condition for Accessory
        if (componentForGuid && componentForGuid.name && (componentForGuid.name == 'Device' || componentForGuid.name == 'Accessory')) {
            //removing RC from update map but only if not cancelation, for cancelation we need to allow RC upodate as it is getting set to 0
            //EDGE-188712 start
            let itemConfig = solution.getConfiguration(crtItem.id);
            let changeType = itemConfig.attributes['changetype'] ? itemConfig.attributes['changetype'].value : 'New';
            if (changeType != 'Cancel') {
                updateMap = updateMap.filter(att => { return att.name != 'RC' });
            }
            //EDGE-188712 end
        }
        // start EDGE-197534
        if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {
            loadedSolutionUC.lock('Commercial', false);
        }
        //end EDGE-197534
        currComponent.updateConfigurationAttribute(crtItem.id, updateMap);
    });

    if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {
        loadedSolutionUC.lock('Commercial', true);
    }
    //EDGE-188712 end

    /* The following code should be separate, not a part of the calculation mechanism */
    //PRE_Logic.attachDiscountsAndChargesToConfigurations(body.cart, true); //EDGE-198536 not needed as PRE Discounts update is part of pricing attributes update
    // TODO: is this really necessary, can we do without this
    CS.currentPRECart = body.cart;
    console.log('Pricing totals:', body.cart.pricing);
    setTotalSolutionValue(totalSolutionOneOffCharge, totalSolutionRecurringCharge);
    console.time('CS.drawSidebar');
    CS.drawSidebar(body.cart); //EDGE-198536 await removed, probably not needed
    console.timeEnd('CS.drawSidebar');
    return body.cart;
}
// MC 2020-08-18: Please remove debugging comments
PRE_Logic.getDefaultPRGAndFa = async function () {
    let currentBasket = await CS.SM.getActiveBasket();
    const basketId = await CS.SM.getActiveBasketId();
    const result = '';//await currentBasket.performRemoteAction('FAM_Data_Retriever', {
    //basketId: basketId
    //});
    const attributeValues = await Promise.all([
        PRE_Logic.getSmAttributeValue(mainSolutionName, 'AccountId'),
        PRE_Logic.getSmAttributeValue(mainSolutionName, 'Catalogue'),
        PRE_Logic.getSmAttributeValue(mainSolutionName, 'Frame Agreement'),
        PRE_Logic.getSmAttributeValue(mainSolutionName, Const.catalogueCodeAttributeName),
        PRE_Logic.getSmAttributeValue(mainSolutionName, 'Frame Agreement PRGs'),
    ]);
    if (result.accountId && !attributeValues[0]) await PRE_Logic.setSmAttributeValue(mainSolutionName, 'AccountId', result.accountId);
    if (result.catalogueName && !attributeValues[1]) await PRE_Logic.setSmAttributeValue(mainSolutionName, 'Catalogue', result.catalogueName);
    if (result.faName && !attributeValues[2]) await PRE_Logic.setSmAttributeValue(mainSolutionName, 'Frame Agreement', result.faName);
    if (result.selectedPRG && !attributeValues[3]) await PRE_Logic.setSmAttributeValue(mainSolutionName, Const.catalogueCodeAttributeName, result.selectedPRG);
    if (result.selectedFA && !attributeValues[4]) await PRE_Logic.setSmAttributeValue(mainSolutionName, 'Frame Agreement PRGs', result.selectedFA);
}
PRE_Logic.attachPRGsToBasket = async function (cart) {
    let localCart;
    if (!cart) {
        localCart = await PRE_Logic.calculateTotalPricesUsingPRE();
    } else {
        localCart = cart;
    }
    const allPrgs = localCart.pricingRuleGroupCodes;
    let currentBasket = await CS.SM.getActiveBasket();
    const payload = {
        [currentBasket.basketId]: allPrgs.filter(Boolean).join(',')
    };
    //return currentBasket.performRemoteAction('PREBasketUpdater', payload);
}
PRE_Logic.calculateBasketTotals = async function () {
    const basketId = await CS.SM.getActiveBasketId();
    const payload = {
        [basketId]: ''
    };
    //let currentBasket = await CS.SM.getActiveBasket();
    //return currentBasket.performRemoteAction('PREBasketCalculateTotals', payload);
}
// MC 2020-08-18: Please use the /** */ format for comments describing function behaviour
//For bundleName find if we have carrier configuration name defined and if we do then
//find configuration with matching name
//will not work correctly for multiple site scenario as we don't have that info on our bundles
PRE_Logic.getCarrierConfigurationGuid = async function (bundleName) {
    let carrierConfigName;
    let foundCarrierConfigName = BundleCarrierConfigName.filter(config => bundleName.startsWith(config.bundleStartsWith));
    if (foundCarrierConfigName && foundCarrierConfigName[0]) {
        carrierConfigName = foundCarrierConfigName[0].carrierConfigName;
        const solution = await CS.SM.getActiveSolution();
        const solutionConfigurations = PRE_Logic.getSolutionConfigurations(solution);
        //get the first config that matches our name
        const config = solutionConfigurations.find(c => {
            return c.name.startsWith(carrierConfigName); //quick fix initial save
        });
        // MC 2020-08-18: unnecessary comment
        //return guid
        return config ? config.guid : undefined;
    }
}
/**
 * Provides the user with an opportunity to do something once the attribute is updated.
 *
 * @param {string} componentName - Tab name where the attribute belongs to.
 * @param {object} attribute - The attribute which is being updated.
 * @param {string} beforeValue - Before change value.
 * @param {string} afterValue - New value to be updated.
 */
PRE_Logic.afterAttributeUpdated = function (componentName, configurationGuid, attribute, beforeValue, afterValue) {
    // MC 2020-08-18: Please remove commented out code if it will not be used, the if statement can also be simplified
    // hide/show the deal management button if a frame agreement is selected
    if (attribute && attribute.name === 'Frame Agreement' && afterValue) {
        // document.querySelectorAll('#redirectToDealManagement').forEach(elem => { elem.style.display = 'none' })
    } else if (attribute && attribute.name === 'Frame Agreement' && !afterValue) {
        // document.querySelectorAll('#redirectToDealManagement').forEach(elem => { elem.style.display = 'initial' })
    } else if (attribute && attribute.name === Const.cpAttributeName && (beforeValue !== afterValue)) {
        PRE_Logic.wait().then(PRE_Logic.calculateTotalPricesUsingPRE(configurationGuid)); //EDGE-198536 now passing in configurationGuid
    }
    //DIGI-1853 added for etc update
    else if (attribute && attribute.name === Const.etcAttributeName && (beforeValue !== afterValue)) {
        PRE_Logic.wait().then(PRE_Logic.calculateTotalPricesUsingPRE(configurationGuid)); //EDGE-198536 now passing in configurationGuid
    }
    /*else if (attribute && attribute.name === Const.catalogueCodeAttributeName && (beforeValue !== afterValue) && afterValue) {
PRE_Logic.wait().then(PRE_Logic.calculateTotalPricesUsingPRE).then(PRE_Logic.attachPRGsToBasket);
} */
    else if (attribute && attribute.name === 'Frame Agreement PRGs' && (beforeValue !== afterValue)) {
        PRE_Logic.wait().then(PRE_Logic.calculateTotalPricesUsingPRE).then(PRE_Logic.attachPRGsToBasket);
    }
    return Promise.resolve(true);
}
/**
 * Hook executed after the configuration is added via the UI add configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object with attributes to be set
 */
PRE_Logic.afterConfigurationAdd = function (componentName, configuration) {
    PRE_Logic.debouncedCalculateTotalPricesUsingPRE();
    return Promise.resolve(true);
}
/**
 * Hook executed before the configuration is deleted via the UI delete configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object which is going to be deleted
 */
PRE_Logic.beforeConfigurationDelete = function (componentName, configuration) {
    if (componentName === 'Internet') {
        PRE_Logic.wait().then(PRE_Logic.getAcessGuidForConfigGuid(configuration.guid));
    }
    if (componentName === 'IPVPN Endpoint') {
        PRE_Logic.wait().then(PRE_Logic.getAcessGuidForConfigGuid(configuration.guid));
    }
    return Promise.resolve(true);
}
/**
 * Hook executed after the configuration is deleted via the UI delete configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object which was deleted
 */
PRE_Logic.afterConfigurationDelete = function (componentName, configuration) {
    PRE_Logic.debouncedCalculateTotalPricesUsingPRE();
    return Promise.resolve(true);
}
/**
 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
 * boolean. The save will continue only if the promise resolve with true.
 *
 * @param {Object} complexProduct
 */
PRE_Logic.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
    //console.log('Before save', complexProduct);
    return PRE_Logic.attachPRGsToBasket().then(() => {
        return Promise.resolve(true);
    });
}
/**
 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
 * boolean. The save will continue only if the promise resolve with true.
 *
 * @param {Object} complexProduct
 */
PRE_Logic.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
    return PRE_Logic.wait()
        .then(PRE_Logic.calculateBasketTotals)
        .then(function () {
            return Promise.resolve(true);
        });
}
// MC 2020-08-18: This comment seems out of place, is it necessary?
/**
 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
 * boolean. The save will continue only if the promise resolve with true.
 *
 * @param {Object} complexProduct
 */
// MC 2020-08-18: Is this commented code necessary if you're using Copado? Historical changes should be tracked there, correct?
//CS.mutationObserver = undefined;
PRE_Logic.afterSolutionLoaded = function () {
    console.log('PRE_Logic afterSolutionLoaded');
    // MC 2020-08-18: Is this commented code necessary if you're using Copado? Historical changes should be tracked there, correct?
    // hide the deal management button if a frame agreement is selected
    /*PRE_Logic.getSmAttributeValue(mainSolutionName, 'Frame Agreement').then((value) => {
    if (value) {
    	//document.querySelectorAll('#redirectToDealManagement').forEach(elem => { elem.style.display = 'none' })
    }
    });*/
    if (CS.mutationObserver) {
        console.log('Removing mutation observer!');
        CS.mutationObserver.disconnect();
        CS.mutationObserver = undefined;
    }
    if (!CS.mutationObserver) {
        console.log('Adding mutation observer!');
        const target = document.getElementsByClassName('pricing-summary-wrapper')[0];
        CS.mutationObserver = new ClassWatcher(
            target,
            'collapsed', // class to watch out for
            () => {
                /* when it is collapsed do nothing */
            },
            () => {
                PRE_Logic.calculateTotalPricesUsingPRE();
            }
        );
    }
    // load the account Id and put it in a attribute to be used
    // in the frame agreement lookup
    return PRE_Logic.getDefaultPRGAndFa().then(PRE_Logic.wait).then(PRE_Logic.calculateTotalPricesUsingPRE);
}
/**
 * Hook to handle custom button click event
 *
 * @param {string} componentName
 * @param {Object} buttonSettings setting from the json schema for the button
 */
PRE_Logic.buttonClickHandler = function (buttonSettings) {
    if (buttonSettings.id === 'backToBasketInternal') {
        return Promise.resolve('/' + CS.SM.session.basketId);
    } else if (buttonSettings.id === 'redirectToDealManagement') {
        return Promise.resolve('/apex/csdiscounts__DiscountPage?basketId=' + CS.SM.session.basketId);
    }
    return Promise.resolve(true);
}
// MC 2020-08-18: Please use the format /** */ when writting comments describing function behaviour
/****
* Function to refresh the Pricing summary widget
****/
// MC 2020-08-18: Please format the function, it is unreadable at the moment
function refreshPricingSummeryWidget() {
    if (document.querySelectorAll('.modal-container')[0]) {
        document.querySelectorAll('.modal-container')[0].style.display = 'none';
        document.querySelectorAll('.modal-container')[0].innerHTML = '';
        let pricingSummaryCloseBtnList = document.getElementsByClassName('icon-close');
        let totalValue = document.getElementsByClassName('total-value');
        totalValue[totalValue.length - 1].innerText = 0;
        let totalCurrency = document.getElementsByClassName('total-currency');
        totalCurrency[totalCurrency.length - 1].innerText = '';
        document.getElementsByClassName('item-list-wrapper')[0].innerHTML = '';
        pricingSummaryCloseBtnList[pricingSummaryCloseBtnList.length - 1].click();
    }
}
/***** 
*Method to update the PRE Doscount attribute if the "EarlyTerminationCharge" is updated
*****/
async function updatePREDiscountAttribute() {
    const updateAttrArray = [];
    await CS.SM.getActiveSolution().then((product) => {
        if (product.components) {
            Object.values(product.components).forEach((comp) => {
                if (comp.schema.configurations) {
                    Object.values(comp.schema.configurations).forEach((cfg) => {
                        if (Object.keys(cfg.attributes).includes('changetype')) {
                            if (cfg.attributes['changetype'].value == 'Cancel') {
                                if (Object.keys(cfg.attributes).includes('earlyterminationcharge')) {
                                    if (cfg.attributes['earlyterminationcharge'].value != undefined && cfg.attributes['earlyterminationcharge'].value != '' && cfg.attributes['earlyterminationcharge'].value != 0) {
                                        if (Object.keys(cfg.attributes).includes('pre discounts')) {
                                            let preDisc = {};
                                            preDisc['discounts'] = [];
                                            preDisc["discounts"].push({ "source": "EarlyTerminationCharge", "version": "3-1-0", "discountPrice": "list", "discountCharge": "EarlyTerminationCharge", "amount": cfg.attributes['earlyterminationcharge'].value, "type": "override", "chargeType": "oneOff", "recordType": "single", "customData": { "promotion": true }, "description": "EarlyTerminationCharge" });
                                            updateAttrArray.push(comp.updateConfigurationAttribute(cfg.guid, [{ name: 'PRE Discounts', value: JSON.stringify(preDisc), displayValue: JSON.stringify(preDisc) }], true));
                                        }
                                    }
                                }
                            }
                        }
                    });
                }
            });
        }
    });
    await Promise.all(updateAttrArray);
    return Promise.resolve(true);
}