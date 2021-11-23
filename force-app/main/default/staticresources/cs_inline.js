var api = { };
var currentScrollTop;
var addingNAProduct = false;
var addingCAProduct = false;
var addingProduct = false;

function addRelatedProduct2(anchorRef)
{
    
    console.log( 'TTT:Entering addRelatedProduct2 function');
    jQuery('.loadingWheel').show();
    currentScrollTop = jQuery(window).scrollTop();
    var definitionId = getAssociatedProductDefId2(anchorRef);
    var prefix = CS.Util.configuratorPrefix;
    var localparams = {
        ref: anchorRef,
        id: definitionId
    };

    var availableProductOptions,
        availableProducts = [],
        index = CS.Service.getProductIndex();

    var availableProductOptions = CS.RPUtils.getSelectProductOptionsForAttrId(definitionId);
    var availableCategories = availableProductOptions['ProductCategories'];
    var availableDefinitions = availableProductOptions['ProductDefinitions'];

    var productId = (availableCategories.length === 0 && availableDefinitions.length === 1) ? availableDefinitions[0].Id : localparams.id;
    var productIndex = CS.Service.getProductIndex(productId);

    var self = this;
    var executionChain = CS.Util.getDeferred();
    var promise = CS.Util.getPromise(executionChain)
    .then(CS.Util.defer(startBusyIndicator, self));

    if (!productIndex) {
        promise = promise.then(CS.Util.defer(loadProductModel, self));
    } else {
        promise = promise.then(CS.Util.defer(function(d, p) {
            p.productIndex = productIndex;
            d.resolve(p);
        }, self));
        availableProducts.push(productIndex.all[productId]);
    }

    promise = promise.then(function success() {
        CS.Log.debug('availableProducts:', availableProducts);

        if (availableProducts.length === 1) {
            localparams.id = availableProducts[0].Id;
        }
        return customAddRelatedProduct2(prefix, localparams.ref, localparams.id, function() {});
    }).then(function() {
        CS.Service.saveAndContinue();
        return false;
    });

    CS.Util.onPromiseError(promise, errorHandler);
    executionChain.resolve({
        productId: productId,
        availableProducts: availableProducts
    });
    
    
    console.log('TTT:Before Set timeout');
    setTimeout(function()
    {
        console.log('TTT:Inside Set timeout');
        commonTimerFunction(anchorRef);
        //toggleSection(anchorRef);
    }, 5000);
    console.log('TTT:After Set timeout');
}

function customAddRelatedProduct2(prefix, anchorRef, productId, callback, containerSelector) {
    console.log('TTT:Inside customAddRelatedProduct2 function');
    var config = CS.Service.config;

    var currentScreen = {
        reference: '',
        index: 0
    };

    var products,
        productDef,
        parent = config[currentScreen.reference],
        anchorWrapper = config[anchorRef],
        attrDef = CS.Service.getAttributeDefinitionForReference(anchorRef);

    console.log('Debug: AnchorWrapper: ' + anchorWrapper + ', anchorRef: ' + anchorRef);

    var executionChain = CS.Util.getDeferred();

    if (!attrDef) {
        executionChain.reject(new Error('Cannot find attribute definition for reference "' + anchorRef + '"'));
        return CS.Util.getPromise(executionChain);
    }

    if (attrDef[prefix + 'Type__c'] != 'Related Product') {
        executionChain.reject(new Error('Cannot add related product on Attribute of type ' + attrDef[prefix + 'Type__c']));
        return CS.Util.getPromise(executionChain);
    }

    var min = attrDef[prefix + 'Min__c'];
    var max = attrDef[prefix + 'Max__c'];

    if (max == anchorWrapper.relatedProducts.length) {
        executionChain.reject(new Error('New item cannot be added - the maximum number of ' + anchorWrapper.definition.Name + ' records is ' + max));
        return CS.Util.getPromise(executionChain);
    }

    if (!productId) {
        products = this.getAvailableProducts(attrRef);
        productId = products[0][prefix + 'Product_Definition__c'];
    }

    if (CS.UI) {
        CS.UI.suspendUpdates();
    }

    var promiseContainer = {
        promise: CS.Util.getPromise(executionChain)
    };

    var configWrapper = createConfiguration2(prefix, config, anchorRef, productId, parent, promiseContainer);

    var self = this;
    var promise = promiseContainer.promise.then(function() {
        CS.Log.debug('***** After createConfiguration call...');

        // set proper config name for related product BUG-01451
        var numRelatedProducts = anchorWrapper.relatedProducts.length;
        var maxIndex = 0;
        // Backslash-escape all non-alphanumeric characters in the Attribute name
        var rpAttrName = attrDef['Name'].replace(/([^A-Za-z0-9 ])/g, function(match, $1) { return '\\' + $1; });
        var rpValidNameRegex = new RegExp(rpAttrName + ' \\d+');
        for (var i = 0; i < numRelatedProducts; i++) {
            var rpPcName = anchorWrapper.relatedProducts[i].config['Name'];
            if (!rpValidNameRegex.test(rpPcName)) {
                continue;
            }

            var lastToken = rpPcName.split(' ').pop();
            if (jQuery.isNumeric(lastToken)) {
                var sufixIndex = parseInt(lastToken);
                if (maxIndex < sufixIndex) {
                    maxIndex = sufixIndex;
                }
            }
        }
        maxIndex++;

        configWrapper.config.Name = attrDef['Name'] + ' ' + maxIndex;
        anchorWrapper.attr[prefix + 'Display_Value__c'] = configWrapper.config.Name;
        configWrapper.config[prefix + 'Configuration_Status__c'] = 'Valid';
    });

    promise = CS.Service.selectConfiguration(anchorRef, promise)
    .then(function success() {
        if (api.productHasChanged) {
            api.productHasChanged(CS.Service.getCurrentProductId(), 0);
        }
        displayScreen(0);
        CS.Rules.evaluateAllRules('after displayScreen in addRelatedProduct2');
        return false;
    });

    executionChain.resolve();
    return promise;
}

function createConfiguration2(prefix, configData, anchorRef, newProductId, parent, promiseContainer) {
    CS.Log.info('###>>> Starting createConfiguration(): ', configData, '/', anchorRef, '/', newProductId, '/', parent);

    var ROOT_REFERENCE = '';

    var productIndex = CS.Service.getProductIndex(newProductId);

    if (!productIndex) {
        throw 'Product index for ' + newProductId + ' not found';
    }

    var productDef = productIndex.productsById[newProductId],
        wrapper = configData[anchorRef],
        newAttrDefs = productIndex.attributeDefsByProduct[newProductId],
        idx = 0,
        name,
        newConfig = {},
        context,
        attr,
        defId,
        ref;

    if (anchorRef !== ROOT_REFERENCE && !wrapper) {
        return error('Could not locate reference ', anchorRef, configData);
    }

    if (!productDef) {
        return error('Could not find product definition for id', newProductId);
    }

    if (!newAttrDefs) {
        return error('Could not find attribute definitions for product id', newProductId);
    }

    if (anchorRef === ROOT_REFERENCE) {
        // root config
        ref = anchorRef;
    } else {
        // attaching a related product configuration to an attribute on the parent
        idx = wrapper.relatedProducts.length;
        name = wrapper.attr.Name;
        ref = CS.Util.stripReference(anchorRef) + idx;
    }

    context = getContext2(ref, name, idx, parent);

    newConfigWrapper = buildConfig2(prefix, productDef, ref, context);

    CS.Log.info('Creating configuration for reference ' + ref);
    if (anchorRef !== ROOT_REFERENCE) {
        // Link related product to parent and mark as unsaved
        newConfigWrapper.parent = parent;
        newConfigWrapper.unsaved = true;
        var relatedProducts = wrapper.relatedProducts.slice(0);
        relatedProducts[idx] = newConfigWrapper;
        CS.binding.update(anchorRef, {relatedProducts: relatedProducts});
    }
    var attrContext = {ref: context.ref, index: 0};

    for (defId in newAttrDefs) {
        attr = buildAttribute2(prefix, newAttrDefs[defId], attrContext, productIndex.find('selectOptionsByAttribute', defId), productIndex.find('attributeFieldDefsByAttributeDef', defId));
        configData[attr.reference] = attr;
    }
    var customLookupConfigs = getCustomLookupConfigs2(prefix, newAttrDefs, productIndex);
    populateScreens2(newProductId, newConfigWrapper);
    if (configData[ref]) {
        // Overlay config on parent attribute node in configuration for related product #0
        jQuery.extend(configData[anchorRef], newConfigWrapper);
    } else {
        configData[ref] = newConfigWrapper;
    }

    var linkedObjectPropertiesCacheKey = params.linkedId + '|' + newProductId;
    var linkedObjectPropertiesExist = CS.Util.isObject(configData[ref]['linkedObjectProperties']);
    var linkedObjectApiExists = (
        api['loadLinkedObjectProperties'] instanceof Function && api['getLinkedObjectId'] instanceof Function
    );

    if (linkedObjectPropertiesExist) {

        if (typeof linkedObjectPropertiesCache === 'undefined') {
            var linkedObjectPropertiesCache = {};
        }

        // If cache key doesn't exist... (mind the negation operator)
        if(!linkedObjectPropertiesCache.hasOwnProperty(linkedObjectPropertiesCacheKey)) {
            linkedObjectPropertiesCache[linkedObjectPropertiesCacheKey] =
                configData[ref]['linkedObjectProperties'];
        }
    }

    if (linkedObjectPropertiesExist || !linkedObjectApiExists) {

        loadRulesForConfig2(ref, productDef);

    } else {

        function _loadLinkedObjectProperties(deferred, params) {
            var key = params.linkedObjectPropertiesCacheKey;

            if (CS.Util.isObject(params.linkedObjectPropertiesCache[key])) {

                CS.Log.info('***** Linked object properties cache hit, cache key: ', key);
                params.configData[params.ref]['linkedObjectProperties'] = params.linkedObjectPropertiesCache[key];
                deferred.resolve(params);
            } else {

                CS.Log.info('***** Loading linked object properties (deferred)...');
                params.api.loadLinkedObjectProperties(params.linkedId, params.newProductId,
                                                      function linkedObjectPropertiesCallback(linkedObjectProperties) {

                                                          if (!CS.Util.isObject(linkedObjectProperties)) {
                                                              linkedObjectProperties = {};
                                                          }

                                                          params.linkedObjectPropertiesCache[params.linkedObjectPropertiesCacheKey] = params.configData[params.ref]['linkedObjectProperties'] = linkedObjectProperties;
                                                          deferred.resolve(params);
                                                      }
                                                     );
            }
        }

        function _loadCustomLookupReferencedAttributes(deferred, params) {
            if (!params.configData[params.ref]['customLookupReferencedAttributes'] && Object.keys(params.customLookupConfigs).length > 0) {
                CS.Log.info('***** Loading Custom Lookup Referenced Attributes (deferred) ...');

                params.api.loadCustomLookupReferencedAttributes(
                    JSON.stringify(params.customLookupConfigs),
                    function(customLookupReferencedAttributes) {
                        if (CS.Util.isObject(customLookupReferencedAttributes)) {
                            params.configData[params.ref]['customLookupReferencedAttributes'] = customLookupReferencedAttributes;
                        }
                        deferred.resolve(params);
                    }
                );
            } else {
                CS.Log.info('***** NOT Loading Custom Lookup Referenced Attributes (already loaded) ...');
                deferred.resolve(params);
            }
        }

        function _loadRulesForConfig() {
            CS.Log.info('***** Loading rules for configuration (deferred)...');
            loadRulesForConfig2(ref, productDef);
        }

        var self = this;
        if (!promiseContainer || !promiseContainer.promise) {
            promiseContainer = {};

            var executionChain = CS.Util.getDeferred();
            promiseContainer.promise = CS.Util.getPromise(executionChain);
            executionChain.resolve();
        }
        promiseContainer.promise = promiseContainer.promise.then(CS.Util.defer(function(d) {
            d.resolve({
                api: api,
                configData: configData,
                customLookupConfigs: customLookupConfigs,
                linkedObjectPropertiesCache: linkedObjectPropertiesCache,
                linkedObjectPropertiesCacheKey: linkedObjectPropertiesCacheKey,
                newProductId: newProductId,
                ref: ref
            });
        })).then(
            CS.Util.defer(_loadLinkedObjectProperties, self)
        ).then(
            CS.Util.defer(_loadCustomLookupReferencedAttributes, self)
        ).then(
            _loadRulesForConfig
        );
    }

    CS.Log.info('###>>> Ending createConfiguration(): ', newConfigWrapper);
    return newConfigWrapper;
}

function getContext2(ref, attrName, idx, parent) {
    return {ref: ref, attrName: attrName, index: (idx || 0), parent: parent};
}

function buildConfig2(prefix, def, reference, context) {
    var wrapper = {
        "reference" : reference,
        "config" : {
            "attributes" : {
                "type" : "Product_Configuration__c"
            }
        }
    };
    wrapper.config[prefix + 'Attribute_Name__c'] = context.attrName;
    wrapper.config[prefix + 'Billing_Frequency__c'] = CS.getFrequencyValueForName(def[prefix + 'Default_Billing_Frequency__c']);
    wrapper.config[prefix + 'Contract_Term__c'] = def[prefix + 'Default_Contract_Term__c'];
    wrapper.config[prefix + 'Contract_Term_Period__c'] = CS.getPeriodValueForName(def[prefix + 'Default_Contract_Term_Period__c']);
    wrapper.config[prefix + 'Description__c'] = def[prefix + 'Description__c'];
    wrapper.config[prefix + 'Index__c'] = context.index;
    wrapper.config[prefix + 'Last_Screen_Index__c'] = 0;
    wrapper.config.Name = CS.Util.getFirstDefinedValue([def.Name, def[prefix + 'Description__c']]);
    wrapper.config[prefix + 'Product_Definition__c'] = def.Id;
    wrapper.config[prefix + 'Recurrence_Frequency__c'] = CS.getFrequencyValueForName(def[prefix + 'Default_Frequency__c']);
    wrapper.config[prefix + 'Configuration_Status__c'] = 'Incomplete';
    wrapper.config[prefix + 'Validation_Message__c'] = '';
    wrapper.config[prefix + 'Product_Family__c'] = (def.Name.length > 40) ? def.Name.substr(0, 40) : def.Name;

    return wrapper;
}

function getCustomLookupConfigs2(prefix, attributeDefinitions, productIndex) {
    var customLookupConfigs = {};

    for (defId in attributeDefinitions) {
        if (!attributeDefinitions.hasOwnProperty(defId)) { continue; }

        var lookupConfigId = attributeDefinitions[defId][prefix + "Lookup_Config__c"];
        if (lookupConfigId) {
            var lookupConfig = productIndex.all[lookupConfigId];
            var lookupCustomisationClass = lookupConfig[prefix + "lookup_customisations_impl__c"];
            if (lookupCustomisationClass && !customLookupConfigs[lookupConfigId]) {
                customLookupConfigs[lookupConfigId] = lookupConfig[prefix + "lookup_customisations_impl__c"];
            }
        }
    }

    return customLookupConfigs;
}

function populateScreens2(productId, config) {
    var productIndex = CS.Service.getProductIndex(productId),
        screensByParent = null,
        configScreens = [],
        idx = 0,
        attrRefsByDef = {},
        newAttrDefs = productIndex.attributeDefsByProduct[productId],
        defId,
        attrContext = {ref: '', index: 0};

    var screenFlowName = CS.Service.getScreenFlowName();
    var usesScreenflow = false;
    if (screenFlowName !== '') {
        var flowIdsByProduct = productIndex.screenFlowIdsByNameAndProduct[screenFlowName];
        if (flowIdsByProduct && flowIdsByProduct[productId]) {
            var screenFlowId = flowIdsByProduct[productId];
            screensByParent = productIndex.screensByScreenFlow[screenFlowId];
            usesScreenflow = true;
        }
    }
    if (!usesScreenflow) {
        screensByParent = productIndex.screensByProduct[productId];
    }

    for (defId in newAttrDefs) {
        ref = CS.Util.generateReference(newAttrDefs[defId].Name, attrContext);
        attrRefsByDef[defId] = ref;
    }

    for (idx in screensByParent) {
        var screen = screensByParent[idx],
            attrs = productIndex.attributeDefsByScreen[screen.Id],
            attrRefs = [];

        for (var attrId in attrs) {
            attrRefs.push(attrRefsByDef[attrId]);
        }

        configScreens[idx] = {
            id: screen.Id,
            reference: screen._reference,
            attrs: attrRefs
        };
    }

    config.screens = configScreens;
}

function loadRulesForConfig2(reference, productDef) {
    if (CS.Rules.hasRules(reference)) {
        return;
    }

    var referenceField = CS.Util.configuratorPrefix + 'reference__c';
    if (!productDef.hasOwnProperty(referenceField)) {
        CS.Log.error('Could not find the field reference__c in the current product definition', productDef);
        return;
    }

    var definitionRef = productDef[referenceField];
    if (!definitionRef) {
        CS.Log.error('Current product definition\'s reference is not defined: ', productDef);
        return;
    }

    var tpl = jQuery('#' + CS.Util.generateId(definitionRef) + '__rules');
    var idx = 0; // this will be for 'leaf' Attributes which presently will always be index 0 (this will change if attribute arrays are introduced using the leaf node index)

    if (tpl.size() === 0) {
        CS.Log.warn('Could not find rules template with reference: ' + definitionRef);
    } else {
        var rules = CS.Util.applyContext(tpl.get(0).innerHTML, idx, reference);
        CS.Rules.addRules(reference, rules);
    }
}

function getAssociatedProductDefId2 (anchorRef) {
	var availableProducts = CS.Service.getAvailableProducts(anchorRef);
	var prodDefId = availableProducts[0]['cscfga__Product_Definition__c'];

	return prodDefId;
}

function startBusyIndicator(deferred, params) {
    if (CS.indicator && CS.indicator.start) {
        CS.indicator.start();
    }
    deferred.resolve(params);
}

function loadProductModel(deferred, params) {
    CS.Service.loadProduct(params.productId, function() {
        var productIndex = CS.Service.getProductIndex(params.productId);
        if (params.availableProducts && params.availableProducts.push) {
            params.availableProducts.push(productIndex.all[params.productId]);
        }

        jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(productIndex));
        params.productIndex = productIndex;

        deferred.resolve(params);
    });
}

function errorHandler(e) {
    CS.Log.error(e);
    CS.displayInfo('Could not open related product: ' + e);
    if (CS.indicator && CS.indicator.stop) {
        CS.indicator.stop();
    }
}

function buildAttribute2(prefix, def, context, selectOptions, attributeFields) {

    context = context || {};

    var wrapper = {
        "attr": {
            "attributes": {
                "type": prefix + "Attribute__c"
            }
        },
        "attributeFields": {},
        "definitionId": def.Id,
        "displayInfo": context.displayInfo || def[prefix + 'Type__c'],
        "reference": CS.Util.generateReference(def.Name, context),
        "relatedProducts": [],
        "selectOptions": selectOptions
    };
    var typeInfo = {'type': def[prefix + 'Data_Type__c'], 'scale': def[prefix + 'Scale__c']};

    wrapper.attr[prefix + "Attribute_Definition__c"] = def.Id;
    wrapper.attr[prefix + 'Cascade_value__c'] = def[prefix + 'Cascade_value__c'];
    wrapper.attr[prefix + 'Display_Value__c'] = (
        def[prefix + 'Type__c'] === 'Calculation'
            ? null
            : CS.DataConverter.localizeValue(def[prefix + 'Default_Value__c'], typeInfo)
    );
    wrapper.attr[prefix + 'Hidden__c'] = def[prefix + 'Hidden__c'];
    wrapper.attr[prefix + 'is_active__c'] = true;
    wrapper.attr[prefix + 'Is_Line_Item__c'] = def[prefix + 'Is_Line_Item__c'];
    wrapper.attr[prefix + 'Is_Required__c'] = def[prefix + 'Required__c'];
    wrapper.attr[prefix + 'Line_Item_Sequence__c'] = def[prefix + 'Line_Item_Sequence__c'];
    wrapper.attr[prefix + 'Line_Item_Description__c'] = def[prefix + 'Line_Item_Description__c'];
    wrapper.attr.Name = def.Name;
    wrapper.attr[prefix + 'Price__c'] = def[prefix + 'Base_Price__c'] || 0;
    wrapper.attr[prefix + 'Value__c'] = (
        def[prefix + 'Type__c'] === 'Calculation'
            ? ''
            : CS.DataConverter.normalizeValue(def[prefix + 'Default_Value__c'], typeInfo)
    );
    wrapper.attr[prefix + 'Recurring__c'] = def[prefix + 'Recurring__c'];

    if (def[prefix + 'Type__c'] === 'Select List' && def[prefix + 'Default_Value__c'] && selectOptions) {
        for (var i = 0; i < selectOptions.length; i++) {
            if (selectOptions[i] == def[prefix + 'Default_Value__c']) {
                wrapper.attr[prefix + 'Display_Value__c'] = selectOptions[i].Name;
                break;
            }
        }
    }
    _.each(attributeFields, function(a) {
        CS.Service.setAttributeField(wrapper, a.Name, a[prefix + 'Default_Value__c']);
    });

    return wrapper;
}

function commonTimerFunction(anchorRef) 
{
    console.log('TTT:Inside commonTimerFunction:currentScrollTop=' + currentScrollTop);
    jQuery(window).scrollTop(currentScrollTop);
    jQuery('.loadingWheel').hide();
}