function setDisplayValue(attributeName, displayValue, isRelatedProduct) {
    if(isRelatedProduct){
        if(CS.countRelatedProducts(attributeName)>0){
            CS.setAttributeField(attributeName,'displayvalue',displayValue);
        }
    } else {
        CS.setAttributeField(attributeName,'displayvalue',displayValue);
    }
}

function makeEnrichmentAttributeRequiredForServiceDetailing() {
	var obj = CS.Service.config;
	for(var ob in obj) {
		var atr = obj[ob];
		if(atr.reference){
			if(atr.hasOwnProperty('attributeFields') && atr.attributeFields && atr.attributeFields.hasOwnProperty('Required_for_Fulfilment')) {
				var enrichmentStatus = CS.getAttributeFieldValue(atr.reference,"Required_for_Fulfilment");
				if(enrichmentStatus.toLowerCase() == 'enrichment') {
					var elemList = document.getElementsByName(atr.reference);
					if(elemList[0]) {
						atr.attr.cscfga__Is_Required__c = true;
					}
					else {
						atr.attr.cscfga__Is_Required__c = false;
					}
				}
			}
		}
	}
}

function populateScreens(productId, config) {
    var productIndex = CS.Service.getProductIndex(productId),
        screensByProduct = productIndex.screensByProduct[productId],
        configScreens = [],
        idx = 0,
        attrRefsByDef = {},
        newAttrDefs = productIndex.attributeDefsByProduct[productId],
        defId,
        attrContext = {ref: '', index: 0};

    for (defId in newAttrDefs) {
        ref = CS.Util.generateReference(newAttrDefs[defId].Name, attrContext);
        attrRefsByDef[defId] = ref;
    }

    for (idx in screensByProduct) {
        var screen = screensByProduct[idx],
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

function validateScreens(data, spec, highlight) {
    var index = CS.Service.getProductIndex(),
        result = {
            isValid: true,
            fieldErrors: {},
            screens: {}
        },
        configRef = typeof spec === 'object' ? spec.reference : spec,
        screenIndex = typeof spec === 'object' ? spec.index : undefined,
        wrapper = data[configRef],
        screens = wrapper ? wrapper.screens : undefined;

    if (highlight === undefined) {
        highlight = true;
    }

    if (!screens) {
        CS.Log.error('No screens found for validation');
        return result;
    }

    if (screenIndex || screenIndex === 0) {
        result = doScreenValidation(data, screens[screenIndex], highlight, configRef);
        if (highlight) {
            wrapper.screens[screenIndex].validation = result;
        }
    } else {
        jQuery.each(screens, function (i, screen) {
            var r = doScreenValidation(data, screen, highlight, configRef);
            if (highlight) {
                wrapper.screens[i].validation = r;
            }
            jQuery.extend(result.screens, r.screens);
            if (!r.isValid) {
                result.isValid = false;
                if (highlight) {
                    jQuery.extend(result.fieldErrors, r.fieldErrors);
                }
            }
        });
    }

    return result;
}

function doScreenValidation(data, screen, highlight, configRef) {
    var result = {
            isValid: true,
            fieldErrors: {},
            screens: {}
        };

    if (highlight === undefined) {
        highlight = true;
    }

    result.screens[screen.id] = true;
    if (typeof configRef === 'undefined') {
        configRef = CS.Service.getCurrentConfigRef();
    }

    var prefix = CS.Util.configuratorPrefix;
    jQuery.each(screen.attrs, function (i, ref) {
        var attrRef = (configRef === '' ? ref : configRef+':'+ref),
            it = data[attrRef],
            valueField = prefix + 'Value__c',
            fieldError = {validationError: false, validationMessage: undefined};

        if (it && it.attr) {
            var isRequiredActiveVisible = (it.attr[prefix + 'Is_Required__c'] && it.attr[prefix + 'is_active__c'] && ! it.attr[prefix + 'Hidden__c']);
            if (isRequiredActiveVisible && isValueBlank(it)) {
                fieldError.validationError = true;
                fieldError.validationMessage = 'This value is required';
            } else if (it.definition[prefix + 'Type__c'] === 'Related Product' &&
                    (it.relatedProducts instanceof Array) &&
                    it.relatedProducts.length > 0
                ) {
                for (var c = 0; c < it.relatedProducts.length; c++) {
                    var relatedConfig = it.relatedProducts[c].config;
                    if (relatedConfig[prefix + 'Configuration_Status__c'] !== 'Valid') {
                        fieldError.validationError = true;
                        fieldError.validationMessage = 'Related product attribute contains incomplete configurations';
                        break;
                    }
                }
            }

            result.fieldErrors[attrRef] = fieldError;
            if (fieldError.validationError) {
                result.screens[screen.id] = false;
                result.isValid = false;
            }
            if (highlight) {
                CS.binding.update(attrRef, result.fieldErrors[attrRef]);
            }
        }
    });

    return result;

    function isValueBlank(item) {
        var valueField = prefix + 'Value__c';
        var retValue = (item.attr[valueField] === null || item.attr[valueField] === '');

        if (item.definition) {
            if (item.definition[prefix + 'Type__c'] in {'Select List':'','Radio Button':''}) {
                retValue = retValue || (item.attr[valueField] === CS.NULL_OPTION_VALUE);
            } else if (item.definition[prefix + 'Type__c'] === 'Related Product') {
                // Ignore the Value field contents, check only related products array's size
                retValue = (item.relatedProducts.length < 1);
            }
        }

        return retValue;
    }
}

function loadRulesForConfig(reference, productDef) {
    if (!CS.Rules.hasRules(reference)) {
        var referenceField = CS.Util.configuratorPrefix + 'reference__c';
        if (!productDef.hasOwnProperty(referenceField)) {
            CS.Log.error('Could not find the field reference__c in the current product definition', productDef);
            return;
        }
        if (productDef[referenceField] === null) {
            CS.Log.error('Current product definition\'s reference is null ', productDef);
            return;
        }

        var tpl = jQuery('#' + CS.Util.generateId(productDef[CS.Util.configuratorPrefix + 'reference__c']) + '__rules'),
            rules,
            idx = 0; // this will be for 'leaf' Attributes which presently will always be index 0 (this will change if attribute arrays are introduced using the leaf node index)

        if (tpl.size() === 0) {
            CS.Log.warn('Could not find rules template with reference: ' + productDef[referenceField]);
        } else {
            var ref = reference ? reference + ':' : '';
            rules = tpl.get(0).innerHTML.replace(/%idx%/g, idx).replace(/%ctx%/g, ref);
            CS.Rules.addRules(reference, rules);
        }
    }
}

function buildAttribute(def, context, selectOptions, attributeFields) {
    context = context || {};
    var prefix = CS.Util.configuratorPrefix;
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
    var typeInfo = {
        'type': def[prefix + 'Data_Type__c'],
        'scale': def[prefix + 'Scale__c']
    };

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

function getContext(ref, attrName, idx, parent) {
    return {ref: ref, attrName: attrName, index: (idx || 0), parent: parent};
}

function buildConfig(def, reference, context) {
    var wrapper = {
        "reference": reference,
        "config": {
            "attributes": {
                "type": "Product_Configuration__c"
            }
        }
    };
    var prefix = CS.Util.configuratorPrefix;
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

function createConfiguration(configData, anchorRef, newProductId, parent) {
    var ROOT_REFERENCE = '';
    var productIndex = CS.Service.getProductIndex(newProductId);

    if (!productIndex) {
        throw 'Product index for ' + newProductId + ' not found';
    }

    var productDef = productIndex.productsById[newProductId],
        wrapper = configData[anchorRef],
        newAttrDefs = productIndex.attributeDefsByProduct[newProductId],
        screensByProduct = productIndex.screensByProduct[newProductId],
        configScreens = [],
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
    context = getContext(ref, name, idx, parent);

    newConfigWrapper = buildConfig(productDef, ref, context);

    CS.Log.info('Creating configuration for reference ' + ref);

    if (anchorRef !== ROOT_REFERENCE) {
        // Link related product to parent and mark as unsaved
        newConfigWrapper.parent = parent;
        newConfigWrapper.unsaved = true;
        var relatedProducts = wrapper.relatedProducts.slice(0);
        relatedProducts[idx] = newConfigWrapper;
        CS.binding.update(anchorRef, {
            relatedProducts: relatedProducts
        });
    }

    var attrContext = {
        ref: context.ref,
        index: 0
    };

    for (defId in newAttrDefs) {
        attr = buildAttribute(newAttrDefs[defId], attrContext, productIndex.find('selectOptionsByAttribute', defId), productIndex.find('attributeFieldDefsByAttributeDef', defId));
        attr.definition = productIndex.all[attr.definitionId];
        configData[attr.reference] = attr;
    }

    populateScreens(newProductId, newConfigWrapper);

    if (configData[ref]) {
        // Overlay config on parent attribute node in configuration for related product #0
        jQuery.extend(configData[anchorRef], newConfigWrapper);
    } else {
        configData[ref] = newConfigWrapper;
    }

    loadRulesForConfig(ref, productDef);

    return newConfigWrapper;
}

function relatedProductsRendered() {
    if (typeof CS.Service.config[''].bound !== 'undefined' && !CS.Service.config[''].bound) {
        CS.Log.debug('Rebinding');
        CS.binding = CS.DataBinder.bind(CS.Service.config, CS.Service.getProductIndex(), jQuery('#configurationContainer'));
        CS.binding.on('afterUpdate', function(ref, properties, event) {
            CS.Log.debug('After Update', ref, properties, event);
            if (!CS.rulesTimer) {
                CS.rulesTimer = window.setTimeout(function() {
                    CS.Rules.evaluateAllRules('after update: ' + ref);
                    CS.rulesTimer = undefined;
                }, 400);
            }
        });
        CS.Service.config[''].bound = true;
    }
}

function addRelatedProductInline(anchorRef, definitionId) {

    var params = {
        ref: anchorRef,
        id: definitionId
    };

    var availableProductOptions,
        availableProducts = [],
        index = CS.Service.getProductIndex();

    CS.Log.debug('Add related product...', params.ref);

    var availableProductOptions = CS.RPUtils.getSelectProductOptionsForAttrId(definitionId);
    var successFired = false;
    var synchroniser = CS.Util.callbackSynchroniser({
        success: function() {
            if(!successFired){
                successFired = true;
                console.log('prepareSelectProduct success call - availableProducts: ' + availableProducts)
                prepareSelectProduct(params, availableProducts);
            }
        }
    });

    var productId = (availableProductOptions['ProductCategories'].length === 0 && availableProductOptions['ProductDefinitions'].length === 1) ? availableProductOptions["ProductDefinitions"][0]['Id'] : params.Id;
    var productIndex = CS.Service.getProductIndex(productId);
    if (!productIndex) {
        synchroniser.register('Load Product Model ' + productId, function() {
            CS.Service.loadProduct(productId, function() {
                productIndex = CS.Service.getProductIndex(productId);
                availableProducts.push(productIndex.all[productId]);

                synchroniser.register('Load Product Templates ' + productId, function() {
                    CS.delegate.loadProductTemplateHtml(productId, function() {
                        jQuery.extend(CS.screens, CS.DataBinder.prepareScreenTemplates(productIndex));
                        synchroniser.complete('Load Product Templates ' + productId);
                        console.log('prepareSelectProduct call - availableProducts: ' + availableProducts);
                        if(!successFired){
                            successFired = true;
                            prepareSelectProduct(params, availableProducts);
                        }
                    });
                });

                synchroniser.complete('Load Product Model ' + productId);
                prepareSelectProduct(params, availableProducts);
            });
        });
    } else {
        availableProducts.push(productIndex.all[productId]);
    }

    synchroniser.start('Loading products');

    function prepareSelectProduct(params, availableProducts) {
        CS.Log.debug('availableProducts:', availableProducts);

        if (availableProducts.length === 1) {
            params.Id = availableProducts[0].Id;
            doAddRelatedProductInline(params.ref, params.Id);
        } else {
            doAddRelatedProductInline(params.ref, params.Id);
        }
    }
}

function doAddRelatedProductInline(anchorRef, productId, callback, containerSelector) {
    var products,
        productDef,
        parent = CS.Service.config[CS.Service.getCurrentConfigRef()],
        anchorWrapper = CS.Service.config[anchorRef],
        attrDef = CS.Service.getAttributeDefinitionForReference(anchorRef);

    if (!attrDef) {
        return;
    }

    var prefix = CS.Util.configuratorPrefix;

    if (attrDef[prefix + 'Type__c'] != 'Related Product') {
        CS.Log.error('Cannot add related product on Attribute of type ', attrDef[prefix + 'Type__c']);
        return;
    }

    var min = attrDef[prefix + 'Min__c'];
    var max = attrDef[prefix + 'Max__c'];
    if (max == anchorWrapper.relatedProducts.length) {
        CS.displayInfo('New item cannot be added - the maximum number of ' + anchorWrapper.definition.Name + ' records is ' + max);
        return;
    }

    if (!productId) {
        products = CS.Service.getAvailableProducts(anchorRef);
        productId = products[0][prefix + 'Product_Definition__c'];
    }

    var initialAttrs = [];
    jQuery.each(CS.Service.config, function(key, value) {
        initialAttrs.push(key);
    });

    var configWrapper = createConfiguration(CS.Service.config, anchorRef, productId, parent);

    // set proper config name for related product BUG-01451
    var numRelatedProducts = anchorWrapper.relatedProducts.length;
    var maxIndex = 0;
    var rpAttrName = attrDef['Name'];
    for (var i = 0; i < numRelatedProducts; i++) {
        var rpPcName = anchorWrapper.relatedProducts[i].config['Name'];
        if (rpPcName.indexOf(rpAttrName) === 0) {
            rpPcName = rpPcName.substring(rpAttrName.length - 1);
        }
        var tokens = rpPcName.split(' ');
        var lastToken = tokens[tokens.length - 1];
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
    configWrapper.config[CS.Util.configuratorPrefix + 'Configuration_Status__c'] = 'Valid';
    CS.Service.config[''].bound = false;
}

function callRules() {
    if (!CS.rulesTimer) {
        CS.rulesTimer = window.setTimeout(function() {
            CS.Rules.evaluateAllRules('after update: ' + ref);
            CS.rulesTimer = undefined;
        }, 600);
    }
}

function loadProduct(id) {
    var deferred = CS.Q.defer();

    CS.Service.loadProduct(id, function() {
        deferred.resolve();
    });

    return deferred.promise;
}

function addRelatedProduct(anchorRef, id) {
	console.log('AddRelatedProduct() started');
    var deferred = CS.Q.defer();

    if (!CS.Service.getProductIndex(id)) {
        return loadProduct(id)
                .then(function() {
                    return addRelatedProduct(anchorRef, id);
                });
    }
    doAddRelatedProductInline(anchorRef, id, function() {}, {} );
    relatedProductsRendered();
    callRules();
    console.log('AddRelatedProduct() ended');
}

/*
*	Given the name of an Attribute of type Related Product will return the Product Definition Id of the related Product definition
*/
function getAssociatedProductDefId (anchorRef) {
	var availableProducts = CS.Service.getAvailableProducts(anchorRef);
	var prodDefId = availableProducts[0]['cscfga__Product_Definition__c']; 
	
	return prodDefId;
}

function removeRelatedProduct(anchorRef) {
	console.log('RemoveRelatedProduct() started');
	if(CS.countRelatedProducts(anchorRef) > 0) {
		CS.Service.removeRelatedProduct(anchorRef);
	}
	console.log('RemoveRelatedProduct() ended');
}