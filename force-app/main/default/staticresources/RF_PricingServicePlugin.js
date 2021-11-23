// MC 2020-08-18: Please use a formatter so everything is formatted consistently, after you got through all the comments.
/******************************************************************************************************************************************************
Sr.No.		Author 			      Date			   Sprint   		Story Number	Description
1. 		 Jagadeswary			 8-01-2021		    21.01	        EDGE-197534
2. 		 Jagadeswary			 11-01-2021		    21.01	        EDGE-197199
3.      Antun B.                20-01-2021         21.01           EDGE-198536     Optimizing PRE response processing (we no longer update all configs 
                                                                                    from PRE response if only one config attribute was changed)
4.      Antun B.                25-01-2021          21.01           EDGE-188712     Pricing attributes set before cancelation logic was called
5.      Antun B.                25-01-2021          21.01           INC000094814023 Enable RP cancel scenario
6.      Madhu Gaurav		07-06-2021	    21.08           INC000095959063 fix
7.      Antun B                 08-02-2021          21.01           AB payload reduction fix
*******************************************************************************************************************************************************/

console.log('Loaded PRE Logic');
if (!CS || !CS.SM) {
    throw Error('Solution Console Api not loaded?');
}
const PRE_Logic = {};
var mainSolutionName = 'Dummy'; //to be set on solution load in main plugin
var PREfindComponentByConfigGuidCache = new Map(); //EDGE-198536
var pricingRuleGroupCodes = [];
const Const = {
    preDiscountsAttributeName: 'PRE Discounts',
    cpAttributeName: 'CommercialProductCode',
    totalPriceForMonths: 12, //12 matches calculations done on cfg side as it is annualized price
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
    },
    priceDerivingKeyword: 'PriceDeriving',
    attributeMappingField: 'Attribute_Mapping__c'
}

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
PRE_Logic.init = async function (mainSolName) {
    console.log('PRE_Logic initialised for: ' + mainSolName);
    mainSolutionName = mainSolName;
    //Initialize sidebar (pricing summary panel) logic as it is now required
    SidebarLogic.init();
    // MC 2020-08-18: This function call is async. Is it intentional not to wait for it to resolve?
    PRE_Logic.getPrToPrgMap();
    // set FA related context from the basket
    pricingRuleGroupCodes = await PRE_Logic.getPricingRuleGroupsForSolution();
}

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
        /*
        if (discount.type && discount.type === 'init') {
            discount.type = 'override';
        }
        */
    }
    return discount;
}

//To-Do - remove as SidebarLogicPlugin should probably use something from the discount/charges array
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
PRE_Logic.getSolutionConfigurations = function (solution, skipRelatedProducts) {
    skipRelatedProducts = skipRelatedProducts || false; //AB payload reduction fix
    var allConf = [];
    var configs = Object.values(solution.getAllConfigurations());
    configs.forEach(config => {
        //first add parent then RP so that we have everything nicely sorted
        allConf.push(config);
        if (!skipRelatedProducts) { //AB payload reduction fix
            config.relatedProductList.forEach(rp => allConf.push(rp.configuration));
        }
    });

    return allConf.filter(config => !config.macLock && (!config.disabled || config.softDeleted)); //ignoring all MACD PC that are not editable i.e. not added to basket
}
//fetches PRG used if FA is selected on basket
PRE_Logic.getPricingRuleGroupsForSolution = async function () {
    let inputMap = {};
    var currentBasket = await CS.SM.getActiveBasket();
    inputMap["GetBasket"] = currentBasket.basketId;
    var result = await currentBasket.performRemoteAction("SolutionActionHelper", inputMap);
    return JSON.parse(result['Prgs']);
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

    function toCartItem(config) {
        // perhaps a better mechanism of fetching sku/code?
        const catalogueItemAttr = config.attributeList.find(attr => attr.name === Const.cpAttributeName && attr.value);
        const catalogueItemId = catalogueItemAttr ? catalogueItemAttr.value : undefined;
        const cancCatalogueItemAttr = config.attributeList.filter(attr => attr.name === cancAttributeName && attr.value);
        const cancCatalogueItemId = (cancCatalogueItemAttr && cancCatalogueItemAttr.length > 0) ? cancCatalogueItemAttr[0].value : undefined;

        let childItems = {};
        let selectedProducts = [];
        let priceDerivingAttributes = config.getAttributeByOther(Const.priceDerivingKeyword);
        let requestAttributes = [];
        priceDerivingAttributes.forEach((att) => {
            requestAttributes.push({
                id: att.name,
                name: att.name,
                value: att.displayValue
            });
        });

        // get the related products data for the request
        config.relatedProductList.forEach((relProd) => {
            if (relProd.configuration.attributes['commercialproductcode']?.value) {
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
                childItems: childItems,
                attributes: requestAttributes
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

    const configurations = PRE_Logic.getSolutionConfigurations(solution, true); //AB payload reduction fix, skipping RP for this logic as we don't want them as top level items in request
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
    const staticBody = JSON.parse(result.body);
        
    console.info('Received raw :', staticBody);
    // MC 2020-08-18: Please find a better name for the variable, discData doesn't provide usefule meaning
    // MC 2020-08-18: What is the data supposed to be, please think about the variable name
    var discData = {};
    discData['Telstra Collaboration'] = {
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
                configIdsWithContractTerm[config.guid]['contractTerm'] = (ctAttribute != undefined ? (ctAttribute.displayValue != '' ? ctAttribute.displayValue.toString().split(' ')[0] : 12) : 12);   //Added .toString() to fix incident INC000095959063
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
                //INC000095494999 Start
                //handle ETC here but only for parent, child ETC will be handled in changeTypeModifyMethod
                if (item.id === crtItem.id) {
                    let itemConfig = solution.getConfiguration(item.id);
                    var etc = itemConfig.attributes[Const.etcAttributeName.toLowerCase()];
                    if (etc && etc.value && Number.parseFloat(etc.value) > 0) {
                        var etcValue = Number.parseFloat(etc.value);
                        var etcCharge = Const.etcListCharge;
                        etcCharge.amount = etcValue;
                        if (solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname) {
                            etcCharge.customData = { "promotion": true, "ETCBusinessID": 'DMCAT_NonRecurringCharge_000751' };
                        }
                        crtItem.pricing.discounts.push(etcCharge);
                    }
                }
                //INC000095494999 End
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
    await PRE_Logic.buildFindComponentByConfigGuidCache(); //INC000095494999 moved here
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
                        //INC000095494999 Start
                        //handling ETC on child items
                        var etc = childConfig.attributes[Const.etcAttributeName.toLowerCase()];
                        if (etc && etc.value && Number.parseFloat(etc.value) > 0) {
                            var etcValue = Number.parseFloat(etc.value);
                            var etcCharge = Const.etcListCharge;
                            etcCharge.amount = etcValue;
                            if (solution.name === NEXTGENMOB_COMPONENT_NAMES.solutionname) {
                                etcCharge.customData = { "promotion": true, "ETCBusinessID": 'DMCAT_NonRecurringCharge_000751' };
                            }
                            crtItem.pricing.discounts.push(etcCharge);
                        }
                        //INC000095494999 End
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
    //await PRE_Logic.buildFindComponentByConfigGuidCache(); //INC000095494999 moved this code slightly up

    body.cart.items.forEach(async (crtItem) => {
        //AB payload reduction fix start
        var itemsToProcess = []; //building a flat list of parent + child items so we can process them easily
        itemsToProcess.push(crtItem);
        crtItem.childItems.selectedRelatedProducts.forEach(rpItem => itemsToProcess.push(rpItem));
        itemsToProcess.forEach(async (currItem) => {
            //AB payload reduction fix end (below logic was existing but crtItem was renamed to currItem to avoid confusion)
            //Changing the discount charge to Discount source + Discount chargetype EDGE-169456
            currItem.pricing.discounts.forEach((discount) => {
                discount["description"] = discount["description"] || discount["source"]; //copy source to description if emtpy
                if ((discount["type"] == "override" || discount["type"] == "init") && discount["source"] != 'EarlyTerminationCharge') { //INC000095494999 added etc to condition

                    discount["discountCharge"] = 'BasePrices'; //value needs to be same for BasePrices and FAM otherwise it will be considered as 2 charges
                    if (discount.customData && discount.customData.customFields) {
                        var custFields = JSON.parse(discount.customData.customFields)
        				//Commented below line as it was erroring out the transaction - Jainish
                        //discount["description"] = custFields.pe.billDescription__c;//'BasePrices'; //description is used for SLI Name so we need to set it to this due to PS MS integration	
                    }
                    //discount["source"] = 'BasePrices'; do not change as this is only identifier of where this price came from, also used on quote/contract to find base price
                }
            });
            //EDGE-198536 start: save performance by skipping the rest of current iteration if we will not update any configs
            if (updateAllowedForGuids.length > 0 && !updateAllowedForGuids.contains(currItem.id)) {
                return; //this skips just the current iteration of body.cart.items.forEach
            }
            //EDGE-198536 end
            //not using total prices as we introduced Qty so we need to use sales prices
            var currComponent = solution.findComponentsByConfiguration(currItem.id); //this covers related products as well so better approach
            let componentForGuid = await PRE_Logic.findComponentByConfigGuidCached(currItem.id); //EDGE-198536
            //default list of attributes we would need updating
            // EDGE-198536 start
            const stringifiedDiscounts = JSON.stringify({
                discounts: currItem.pricing.discounts.map(PRE_Logic.makeDiscountReadOnlyForDealManagementPackage).map(PRE_Logic.copySourceToDescription)
            });
            //EDGE-198536 end
            let updateMap =
                [
                    { name: 'OC', value: currItem.pricing.salesOneOffPrice, displayValue: currItem.pricing.salesOneOffPrice },
                    { name: 'OneOffCharge', value: currItem.pricing.salesOneOffPrice, displayValue: currItem.pricing.salesOneOffPrice },
                    { name: 'RC', value: currItem.pricing.salesRecurringPrice, displayValue: currItem.pricing.salesRecurringPrice },
                    { name: 'IR Charge', value: currItem.pricing.salesRecurringPrice, displayValue: currItem.pricing.salesRecurringPrice },
                    { name: Const.preDiscountsAttributeName, value: stringifiedDiscounts, displayValue: stringifiedDiscounts } //EDGE-198536
                ];
            //logic to extract attribute mapping and transform it in to updateMap values
            currItem.pricing.charges.forEach(charge => {
                var custFields = JSON.parse(charge.customData.customFields || {});
                var attMappingSrc = (custFields.pe && custFields.pe[Const.attributeMappingField]) ? custFields.pe[Const.attributeMappingField] : '{}';
                var attributeMapping = JSON.parse(attMappingSrc);
                Object.keys(attributeMapping).forEach(attName => {
                    //add attribute to update map with corresponding value
                    var valueKey = attributeMapping[attName];
                    //if valueKey contains '.' then it is trying to access fields from pe, pet or pra objects which are under customData
                    var attValue;
                    valueKeySegment = valueKey.split('.');
                    if (valueKeySegment.length > 1) {
                        attValue = custFields[valueKeySegment[0]][valueKeySegment[1]];
                    } else {
                        attValue = charge[valueKeySegment[0]];   
                    }

                    if (attValue != undefined) {
                        //allowing updates for empty string and 0
                        updateMap.push({name: attName, value: attValue, displayValue: attValue});   
                    }
                });

            });
            //exclusion logic for specific cases like HRO for devices, removes some attributes from update map //krunal - added condition for Accessory
            if (componentForGuid && componentForGuid.name && (componentForGuid.name == 'Device' || componentForGuid.name == 'Accessory')) {
                //removing RC from update map but only if not cancelation, for cancelation we need to allow RC upodate as it is getting set to 0
                //EDGE-188712 start
                let itemConfig = solution.getConfiguration(currItem.id);
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
            currComponent.updateConfigurationAttribute(currItem.id, updateMap);
        }); //AB payload reduction fix end, end of itemsToProcess.forEach
    });

    if (typeof basketLockStages !== 'undefined' && basketLockStages.contains(basketStage)) {
        loadedSolutionUC.lock('Commercial', true);
    }
    //EDGE-188712 end
    // TODO: is this really necessary, can we do without this
    CS.currentPRECart = body.cart;
    console.log('Pricing totals:', body.cart.pricing);
    setTotalSolutionValue(totalSolutionOneOffCharge, totalSolutionRecurringCharge);
    console.time('CS.drawSidebar');
    CS.drawSidebar(body.cart); //EDGE-198536 await removed, probably not needed
    console.timeEnd('CS.drawSidebar');
    return body.cart;
}

/**
 * Wrapper function introduced for readability.
 * If configuration param is not provided prices will be refreshed for all active configurations
 */
PRE_Logic.refreshPrices = async function (config) {
    await PRE_Logic.calculateTotalPricesUsingPRE(config);
}

/**
 * Provides the user with an opportunity to do something once the attribute is updated.
 *
 * @param {string} component - Tab name where the attribute belongs to.
 * @param {object} attribute - The attribute which is being updated.
 * @param {string} beforeValue - Before change value.
 * @param {string} afterValue - New value to be updated.
 */
PRE_Logic.afterAttributeUpdated = async function (component, configuration, attribute, beforeValue, afterValue) {
    var otherValues = attribute.other.split(',');
    var priceDeriving = otherValues.includes(Const.priceDerivingKeyword);
    if (attribute && attribute.name === Const.cpAttributeName && (beforeValue !== afterValue)) {
        await PRE_Logic.calculateTotalPricesUsingPRE(configuration); //EDGE-198536 now passing in configuration
    } else if (attribute && priceDeriving && (beforeValue !== afterValue)) {
        //dynamic logic that uses attribute Other property
        await PRE_Logic.calculateTotalPricesUsingPRE(configuration);
    } else if (attribute && (attribute.name === 'ConnectionType' || attribute.name === 'GradeOfService' || attribute.name === 'APN Charge' || attribute.name === 'ShippingType' || attribute.name === Const.etcAttributeName) && (beforeValue !== afterValue)) {
        //backup logic with hardcoded attribute names for now until schema is updated
        await PRE_Logic.calculateTotalPricesUsingPRE(configuration);
    }

    return Promise.resolve(true);
}
/**
 * Hook executed after the configuration is added via the UI add configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object with attributes to be set
 */
PRE_Logic.afterConfigurationAdd = async function (componentName, configuration) {
    await PRE_Logic.calculateTotalPricesUsingPRE();
    return Promise.resolve(true);
}
/**
 * Hook executed before the configuration is deleted via the UI delete configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object which is going to be deleted
 */
PRE_Logic.beforeConfigurationDelete = async function (componentName, configuration) {
    return Promise.resolve(true);
}
/**
 * Hook executed after the configuration is deleted via the UI delete configuration button
 *
 * @param {string} componentName
 * @param {Object} configuration - Configuration object which was deleted
 */
PRE_Logic.afterConfigurationDelete = async function (componentName, configuration) {
    await PRE_Logic.calculateTotalPricesUsingPRE()
    return Promise.resolve(true);
}
/**
 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
 * boolean. The save will continue only if the promise resolve with true.
 */
PRE_Logic.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
    //console.log('Before save', complexProduct);
    //await PRE_Logic.calculateTotalPricesUsingPRE(); //this hook might not be needed as it is already too late for changes
    return Promise.resolve(true);
}
/**
 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
 * boolean. The save will continue only if the promise resolve with true.
 */
PRE_Logic.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
    return Promise.resolve(true);
}

PRE_Logic.afterSolutionLoaded = function () {
    console.log('PRE_Logic afterSolutionLoaded');
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
    return Promise.resolve(true);
}


/**
 * Function to refresh the Pricing summary widget
 */
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
    //implementation removed but function retained not to break other plugins.
    //not needed as ETC are handled as part of PRE response processing
    console.log('updatePREDiscountAttribute function is deprecated. ETC handled during PRE response processing. Please remove function calls from product plugins!');
    return Promise.resolve(true);
}