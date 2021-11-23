require(['cs_js/cs-full'], function(CS) {
	var api = { };
	
	function buildInlineEditFunctions() {
		
		
		function getContext(ref, attrName, idx, parent) {
			return {ref: ref, attrName: attrName, index: (idx || 0), parent: parent};
		}

		function updateAttribute(input) {

			var invalue;

			if (input.type === 'select-one') {
				invalue = jQuery(input).find('option:selected').text();
			}
			else if (input.className && input.className.indexOf('select2') != -1) {
				invalue = input.value;
			} 
			else if (input.type === 'checkbox') {
				if (input.checked) {
					invalue = 'Yes';
				} 
				else {
					invalue = false;
				}
			}
			else if (input.type === 'date') {
				invalue = CS.DataConverter.DATA_TYPE_CONVERTERS.String(input.valueAsDate);
			}
			else {
				invalue = input.value;
			}
			
			CS.setAttributeValue(input.id, invalue, false);
			CS.Service.validateCurrentConfig(true);
			CS.Rules.evaluateAllRules('after update');
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

		function startBusyIndicator(deferred, params) {
			if (CS.indicator && CS.indicator.start) {
				CS.indicator.start();
			}
			deferred.resolve(params);
		}

		/**
		 * A custom handler for rejected promises, used in place of the default
		 * error handler method to inform the user of incorrect behaviour during
		 * adding or editing of related products
		 */
		function errorHandler(e) {
			CS.Log.error(e);
			CS.displayInfo('Could not open related product: ' + e);
			if (CS.indicator && CS.indicator.stop) {
				CS.indicator.stop();
			}
		}

		function countRelatedProducts(anchorRef, value) {

			var config = CS.Service.config;
			var anchorWrapper = config[anchorRef];

			return anchorWrapper.relatedProducts.length;
		}

		/*
		 * Add new inline related product
		 */
		function addRelatedProduct(anchorRef, definitionId) {

			console.log('Debug: DefinitionId:' + definitionId);

			var prefix = CS.Util.configuratorPrefix;
			var localparams = {
				ref: anchorRef,
				id: definitionId
			};

			var availableProductOptions,
				availableProducts = [],
				index = CS.Service.getProductIndex();

			CS.Log.debug('Add related product...', localparams.ref);

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

				return customAddRelatedProduct(prefix, localparams.ref, localparams.id, afterDisplay);
			}).then(function() {
				return CS.Service.saveAndContinue();
			});

			CS.Util.onPromiseError(promise, errorHandler);
			executionChain.resolve({
				productId: productId,
				availableProducts: availableProducts
			});
		}
		/*
		 * Called from addRelatedProduct (Implements Product Configuration creation and returns a promise)
		 */
		function customAddRelatedProduct(prefix, anchorRef, productId, callback, containerSelector) {

			var config = CS.Service.config;
			
			var currentScreen = {
				reference: '',
				index: 0
			};

			var products;
			var productDef;
			var parent = config[currentScreen.reference];
			var anchorWrapper = config[anchorRef];
			var attrDef = CS.Service.getAttributeDefinitionForReference(anchorRef);

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

			var promiseContainer = {};
			
			promiseContainer.promise = CS.Util.getPromise(executionChain);

			var configWrapper = createConfiguration(prefix, config, anchorRef, productId, parent, promiseContainer);

			var self = this;
			var promise = promiseContainer.promise.then(function() {
				/* jshint -W069 */
				CS.Log.debug('***** After createConfiguration call...');
				var maxIndex = CS.Service.getRelatedProductNameIndex(anchorWrapper) + 1;
				configWrapper.config.Name = attrDef['Name'] + ' ' + maxIndex;
				anchorWrapper.attr[prefix + 'Display_Value__c'] = configWrapper.config.Name;
											configWrapper.config[prefix + 'Configuration_Status__c'] = 'Valid';
			});

			promise = CS.Service.selectConfiguration(configWrapper.reference, promise)
			.then(function success() {
				if (api.productHasChanged) {
					api.productHasChanged(CS.Service.getCurrentProductId(), 0);
				}
				displayScreen(0);
				CS.Rules.evaluateAllRules('after displayScreen in addRelatedProduct');
			});

			executionChain.resolve();

			return promise;
		}

		function afterDisplay() {
			var productId = CS.Service.getCurrentProductId();
			var screenFlowName = CS.Service.getScreenFlowName();
			var index = CS.Service.getProductIndex();

			var usesScreenflow = false;
			if (screenFlowName !== '') {
				var screenflowIdsByProducts = index.screenFlowIdsByNameAndProduct[screenFlowName];
				if (screenflowIdsByProducts && screenflowIdsByProducts[productId]) {
					var screenFlowId = screenflowIdsByProducts[productId];
					populateScreenList(index.screensByScreenFlow[screenFlowId]);
					usesScreenflow = true;
				}
			}

			if (!usesScreenflow) {
				populateScreenList(index.screensByProduct[productId]);
			}

			displayButtons();
			CS.Rules.evaluateAllRules('after display');
			console.log('after display');
			activateControls();
		}

		/*
		 * Create new product configuration
		 */
		function createConfiguration(prefix, configData, anchorRef, newProductId, parent, promiseContainer) {
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
			
			context = getContext(ref, name, idx, parent);

			newConfigWrapper = buildConfig(prefix, productDef, ref, context);

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
				attr = buildAttribute(prefix, newAttrDefs[defId], attrContext, productIndex.find('selectOptionsByAttribute', defId), productIndex.find('attributeFieldDefsByAttributeDef', defId));
				configData[attr.reference] = attr;
			}
			var customLookupConfigs = getCustomLookupConfigs(prefix, newAttrDefs, productIndex);

			populateScreens(newProductId, newConfigWrapper);

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
				
				loadRulesForConfig(ref, productDef);
				
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
					loadRulesForConfig(ref, productDef);
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

		function loadRulesForConfig(reference, productDef) {
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

		/*
		 * Build new configuration
		 */
		function buildConfig(prefix, def, reference, context) {
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

		/*
		 * Build new attribute
		 */
		function buildAttribute(prefix, def, context, selectOptions, attributeFields) {
			
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

		function getCustomLookupConfigs(prefix, attributeDefinitions, productIndex) {
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

		function populateScreens(productId, config) {
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


		/*
		 * Script for creating and rendering Select2 lookup fields
		 */
		
		function initSll(elemId) {
			
			function getTotalColumnsWidth(columnSizeCSV) {
				if (!columnSizeCSV || columnSizeCSV === null || columnSizeCSV.length === 0) {
					return -1;
				}
				var totalColumnsWidth = columnSizeCSV.split(',').reduce(function(a, b) {
					return ((CS.Util.isInteger(+a)) ? +a : 0 ) + ((CS.Util.isInteger(+b)) ? +b : 0 );
				});
				return totalColumnsWidth;
			}
			
			function getLookupQueryReferencedAttributes(lookupConfigId, definitionId, reference) {
				// check if custom lookup implementation
				var lookupConfig = CS.Service.getProductIndex(definitionId).all[lookupConfigId];
				if (lookupConfig[prefix + 'lookup_customisations_impl__c']) {
					var ref = reference;
					var referencedAttributes = CS.Service.config[ref].customLookupReferencedAttributes[lookupConfigId];
					return JSON.parse(referencedAttributes);
				}
				var lookupQueries = CS.Service.getProductIndex(definitionId).lookupQueriesByName;
				for (id in lookupQueries) {
					var lookupQuery = lookupQueries[id];
					if (lookupQuery[prefix + 'Lookup_Config__c'] === lookupConfigId) {
						var referencedAttributes = lookupQuery[prefix + 'Referenced_Attributes__c'];
						if (referencedAttributes == '' || referencedAttributes == undefined) {
							return [];
						}
						return JSON.parse(referencedAttributes);
					}
				}
				return [];
			}
			
			function functionDecorator(f) {
				return function() {
					return f.apply(this, arguments);
				}
			}
			
			function formatSelection(lookupRecord, attrRef, currentSelectListLookupConfigId) {
				var id = lookupRecord.text.id;
				var name = lookupRecord.text.name;

				// check init selection, cache is not existing, we need just a value for display
				if (CS.selectListLookupDataCache === undefined) {
					if (name !== undefined) {
						return name;
					}
					return id;
				}

				var selectListLookupData = CS.selectListLookupDataCache[currentSelectListLookupConfigId];
				var attrWrapper = CS.getAttributeWrapper(attrRef);
				var listColumnsWidth = attrWrapper.definition[prefix + 'Column_Size_CSV__c'];
				listColumnsWidth = (listColumnsWidth) ? listColumnsWidth.split(',') : [];

				var displayValueField = listColumnsWidth.pop();
				var displayValue;
				if (displayValueField && !CS.Util.isInteger(displayValueField)) {
					displayValueField = displayValueField.toLowerCase();
					displayValue = (lookupRecord.text[displayValueField]) ? lookupRecord.text[displayValueField] : undefined;
				}

				if (selectListLookupData !== undefined) {
					if (displayValue !== undefined) {
						return displayValue;
					}
					if (name !== undefined) {
						return name;
					}
					return id;
				}

				if (displayValue !== undefined) {
					return displayValue;
				}
				if(name !== undefined) {
					return name;
				}
				return id;
			}
			
			function wrapConfiguratorAction(action, name, binding) {
				return _.debounce(function(e) {
					CS.Log.debug(name);
					var el = jQuery(e.currentTarget),
						group = el.attr('data-cs-group'),
						ref = el.attr('data-cs-ref'),
						json = el.attr('data-cs-params'),
						params = json ? JSON.parse(json) || {} : {},
						ret;

					params.el = el;
					params.group = group;
					params.ref = ref;
					//params.ref = binding.wrapper.reference;

					el.attr('disabled', 'disabled');
					try {
						ret = action(params, binding, e);
					} catch (err) {
						CS.Log.error(err.message, err);
					} finally {
						el.removeAttr('disabled')
						.css('opacity', '');
					}

					return ret ? ret : false;

				}, 500, true);
			}
			
			function getSelect2DisplayFieldName(attrRef) {
				var DEFAULT_SSL_DISPLAY_FIELD_NAME = 'Name';
				var attrWrapper = CS.getAttributeWrapper(attrRef);
				var listColumnsWidth = attrWrapper.definition[prefix + 'Column_Size_CSV__c'];
				listColumnsWidth = (listColumnsWidth) ? listColumnsWidth.split(',') : [];

				if (listColumnsWidth.length === 0) {
					return DEFAULT_SSL_DISPLAY_FIELD_NAME;
				}

				var displayFieldName = listColumnsWidth.pop();
				if (CS.Util.isInteger(+displayFieldName)) {
					return DEFAULT_SSL_DISPLAY_FIELD_NAME;
				}
				return displayFieldName;
			}
			
			function getSelectListLookup(attrRef, lookupConfigId, productDefinitionId, attributeValueParams, query) {
				
				var dynamicFilterParams = '';
				if (attributeValueParams) {
					nameIdPairs = attributeValueParams.split(',');
					for (i = 0 ; i < nameIdPairs.length ; i++) {
						var oneNameIdPair = nameIdPairs[i].split('|');
						if (dynamicFilterParams != '') {
							dynamicFilterParams += '|';
						}
						dynamicFilterParams += oneNameIdPair[0] + '=' + getAttributeValueByAttributeName(oneNameIdPair[0]);
					}
				}

				var lookupparams = {
					"lookupConfigId" : lookupConfigId,
					"searchTerm" : query.term,
					"pageNo" : query.page - 1,
					"productDefinitionId" : productDefinitionId,
					"attributeValueParams" : urlEncode(dynamicFilterParams)
				};

				CS.Service.getSelectListLookup(lookupparams, function(result, event) {

					if (event.status) {
						var selectListLookupJSON = result;
						var listColumnsMap = selectListLookupJSON.listColumns;
						var listColumnsNames = selectListLookupJSON.columnNames;
						var sortedListColumns = {};
						var sortedListColumnNames = {};

						for (var i = 0; i < listColumnsMap.length; i++) {
							for (key in listColumnsMap[i]) {
								sortedListColumns[key] = listColumnsMap[i][key];
								sortedListColumnNames[key] = listColumnsNames[i][key];
							}
						}

						if (CS.selectListLookupDataCache === undefined) {
							CS.selectListLookupDataCache = {};
						}

						CS.selectListLookupDataCache[lookupConfigId] = {
							listColumns : sortedListColumns,
							recordData : selectListLookupJSON.records,
							columnTypes : selectListLookupJSON.columnTypes,
							columnNames : sortedListColumnNames,
							orderOfRecords : selectListLookupJSON.orderOfRecords,
							warnings : selectListLookupJSON.warnings
						};

						currentSelectListLookupConfigId = lookupConfigId;
						selectListLookupQuery(query);
					}
				});
			}
			
			function selectListLookupQuery(query) {
				var SELECT_LIST_LOOKUP_PAGE_SIZE = 25;
				var data = {results: []};
				var selectListLookupData = CS.selectListLookupDataCache[currentSelectListLookupConfigId];
				var recordData = selectListLookupData.recordData;
				var orderOfRecords = selectListLookupData.orderOfRecords;
				var orderedData = [];

				for (key in orderOfRecords) {
					orderedData.push(recordData[orderOfRecords[key]]);
				}

				for (var i = 0, len = orderedData.length; i < len; i++) {
					data.results.push({id: orderedData[i].id, text: orderedData[i]});
				}

				if (Object.keys(orderedData).length > SELECT_LIST_LOOKUP_PAGE_SIZE) {
					// page has 25 records, 26th record (if it exists) is indicator that there are more records
					// pop 26th record (if it exists) to avoid duplicates
					data.results.pop();
					data.more = true;
				} else {
					data.more = false;
				}

				query.callback(data);

				if (selectListLookupData && selectListLookupData.warnings && selectListLookupData.warnings instanceof Array) {
					var attributeName = query.element && query.element[0] && query.element[0].name;
					for (var i = 0; i < selectListLookupData.warnings.length; i++) {
						CS.logWarning(
							attributeName,
							':',
							selectListLookupData.warnings[i]
						);
					}
				}
			}
			
			function getColumnWidthsArray(columnSizeCSV) {
				var columnWidths = [];
				if (!columnSizeCSV || columnSizeCSV === null || columnSizeCSV.length === 0) {
					return -1;
				}
				columnSizeCSV.split(',').map(function(a) {
					if (CS.Util.isInteger(+a)) {
						columnWidths.push(+a);
					}
				});
				return columnWidths;
			}
			
			function getColumnStyleWidths(attrRef, listColumns) {
				var attrWrapper = CS.getAttributeWrapper(attrRef);
				var columnSizeCSV = attrWrapper.definition[prefix + 'Column_Size_CSV__c'];
				var columnWidths = getColumnWidthsArray(columnSizeCSV);
				var columnStyleWidths = [];
				var listColumnsLength = Object.keys(listColumns).length;

				// no column information, evenly distributed column widths will be generated
				var averageWidth = (100 / listColumnsLength);
				if (columnWidths !== -1) {
					averageWidth = (100 / (listColumnsLength - columnWidths.length));
				}

				if (columnWidths === -1) {
					for (var i = 0; i < listColumnsLength; i++) {
						columnStyleWidths.push('style="width: ' + averageWidth + '%;"');
					}
				} else {
					// Generate column widths based on CSV list information available
					// Note that missing widths will be ignored and proportional
					for (var i = 0; i < listColumnsLength; i++) {
						var columnWidth = (columnWidths[i]) ? columnWidths[i] + 'em;"' : averageWidth + '%;"';
						columnStyleWidths.push('style="width:' + columnWidth);
					}
				}

				return columnStyleWidths;
			}
			
			function formatResult(lookupRecord, attrRef, lookupConfigId) {
				if (lookupRecord.id === undefined) {
					return;
				}
				var selectListLookupData = CS.selectListLookupDataCache[lookupConfigId];
				var recordData = selectListLookupData.recordData;
				var listColumns = selectListLookupData.listColumns;
				var columnTypes = selectListLookupData.columnTypes;
				var attrWrapper = CS.getAttributeWrapper(attrRef);
				var columnStyleWidths = getColumnStyleWidths(attrRef, listColumns);
				var columnCnt = 0;
				var htmlMarkup = [
					'<div class="rTable" style="width: 100%;">',
					' <div class="rTableRow">'
				];

				for (key in listColumns) {
					var fieldName = listColumns[key];
					var item = lookupRecord.text[fieldName];
					var attrDataType = { type: columnTypes[fieldName] };
					item = CS.DataConverter.normalizeValue(item, attrDataType);
					item = CS.DataConverter.localizeValue(item, attrDataType);
					htmlMarkup.push('<div class="rTableCell" title="', item, '" ', columnStyleWidths[columnCnt++], '>', item, '</div>');
				}
				htmlMarkup.push(
					' </div>',
					'</div>'
				);

				return htmlMarkup.join('');
			}
			
			function formatHeader(attrRef, lookupConfigId) {
				var selectListLookupData = CS.selectListLookupDataCache[lookupConfigId];
				var listColumns = selectListLookupData.listColumns;
				var columnNames = selectListLookupData.columnNames;
				var columnStyleWidths = getColumnStyleWidths(attrRef, listColumns);
				var columnCnt = 0;
				var macintoshNoScrollbarCSS = (navigator.appVersion.indexOf("Mac") !=-1 ) ? ' OSX' : '';
				var htmlMarkup = [
					'<ul class="select2-results tableHeader ', macintoshNoScrollbarCSS ,'">',
					' <li>',
					'  <div class="select2-result-label">',
					'   <div class="rTable" style="width: 100%;">',
					'    <div class="rTableRow">'
				];

				for (key in columnNames) {
					var fieldName = columnNames[key];
					htmlMarkup.push('<div class="rTableCell" title="', fieldName, '" ', columnStyleWidths[columnCnt++], '>', fieldName, '</div>');
				}

				htmlMarkup.push(
					'    </div>',
					'   </div>',
					'  </div>',
					' </li>',
					'</ul>'
				);

				return htmlMarkup.join('');
			}
				// Attributi
			function getAttributeValueByAttributeName(attributeName) {
				var attrValue = '';
				var attrPrice = '';
				var currentConfig = CS.Service.config;
				for (var ref in currentConfig) {
					var o = currentConfig[ref];
					
					if (o.attr && o.attr['Name'] === attributeName) {
						attrValue = o.attr[prefix + 'Value__c'];
						attrPrice = o.attr[prefix + 'Price__c'];
						break;
					}
				}

				return attrValue;
			}

			var name = undefined;
			var action = CS.UI.Actions.find(name);
			var func = action ? wrapConfiguratorAction(action.action, name, binding) : undefined;
			var a = {};
			var prefix = CS.Util.configuratorPrefix;
			var INPUT_DELAY_BEFORE_AJAX = 250;
			var SELECT_LIST_LOOKUP_DEFAULT_MINIMUM_INPUT_LENGTH = 3;
			var SELECT_LIST_LOOKUP_NOSCROLL_MAX_RECORD_TRESHOLD = 9;
			var SELECT_LIST_LOOKUP_BIGDROP_SIZE_MIN_WIDTH_TRESHOLD = 30;
			var SELECT_LIST_LOOKUP_BIGDROP_SIZE_MIN_COLUMN_TRESHOLD = 3;
			var minInputLength  = 0;
			var x  = document.getElementById(elemId);
			var el = jQuery(x).parent().find('[data-cs-select-list-lookup="true"]');
			var attrRef = el.attr('data-cs-binding');
			var attrWrapper = CS.getAttributeWrapper(attrRef);
			var ad = attrWrapper.definition;
			var productDefinitionId = attrWrapper.definition[prefix + 'Product_Definition__c'];
			var minInputLength = (ad[prefix + 'Minimum_Input_Length__c'] === null) ?
				SELECT_LIST_LOOKUP_DEFAULT_MINIMUM_INPUT_LENGTH : (ad[prefix + 'Minimum_Input_Length__c']);
			var lookupConfigId = ad[prefix + 'Lookup_Config__c'];
			var columnSizeCSV = ad[prefix + 'Column_Size_CSV__c'];
			var getSelectListLookupDebounced = _.debounce(getSelectListLookup, INPUT_DELAY_BEFORE_AJAX);
			var displayFieldName = getSelect2DisplayFieldName(attrRef);
			var attributeValueParams = getLookupQueryReferencedAttributes(lookupConfigId, ad.cscfga__Product_Definition__c, attrWrapper.reference.split(':')[0]).join(',');
			var a = attrWrapper.attr;
			var displayValue = a[prefix + 'Column_Size_CSV__c'];

			// prepare CSS fingerprint
			var extendedDropTableWidth = '';
			var listColumns = CS.Util.getListColumnsForLookupConfigId(lookupConfigId);
			if (listColumns.length > SELECT_LIST_LOOKUP_BIGDROP_SIZE_MIN_COLUMN_TRESHOLD) {
				extendedDropTableWidth = 'select2-bigdrop ';
			}
			
			// get select2 dropdown size in em units, if over 30 extend the table to wide variant
			if (extendedDropTableWidth === '') {
				var tableSizeInEms = getTotalColumnsWidth(null);
				if (tableSizeInEms > SELECT_LIST_LOOKUP_BIGDROP_SIZE_MIN_WIDTH_TRESHOLD) {
					extendedDropTableWidth = 'select2-bigdrop ';
				}
			}
			
			// Always use bigdrop
			extendedDropTableWidth = 'select2-bigdrop ';
			
			var dropdownCssClassExtended = extendedDropTableWidth + CS.Util.getCssFingerprint(attrRef);
			el.val(a[prefix + 'Display_Value__c']);

			el.select2({
				width : '100%',
				allowClear : true,
				minimumInputLength: minInputLength,
				escapeMarkup: function (m) { return m; },
				dropdownCssClass: dropdownCssClassExtended,
				formatSelection: function(lookupRecord) { return functionDecorator(formatSelection)(lookupRecord, attrRef, lookupConfigId); },
				formatResult: function(lookupRecord) { return functionDecorator(formatResult)(lookupRecord, attrRef, lookupConfigId); },
				initSelection : function (element, callback) { callback({id:a[prefix + 'Value__c'], text:{ name: a[prefix + 'Display_Value__c']}}) },
				placeholder: (minInputLength === 0) ?
					CS.Labels.selectlistlookup_Please_select_value : CS.Labels.selectlistlookup_Please_enter_search,
				query: function(query) { getSelectListLookupDebounced(attrRef, lookupConfigId, productDefinitionId, attributeValueParams, query) }
			})
			.on('select2-opening', function(e) {
				// remove dataLoaded class to reduce height
				var nodes = jQuery('.select2-drop.' + CS.Util.getCssFingerprint(attrRef));
				if (nodes.length === 1) {
					nodes.removeClass('dataLoaded');
				}
			})
			.on('select2-removed', function(e) {
				CS.setAttributeValue(attrRef, '');
			})
			.on('select2-loaded', function(e) {
				var nodes = jQuery('.select2-drop.' + CS.Util.getCssFingerprint(attrRef) + ' .select2-results');
				if (nodes.length === 1) {
					var html = formatHeader(attrRef, lookupConfigId);
					nodes.before(html);
				}
				if (CS.selectListLookupDataCache[lookupConfigId]) {
					var nodes = jQuery('.select2-drop.' + CS.Util.getCssFingerprint(attrRef));
					if (Object.keys(CS.selectListLookupDataCache[lookupConfigId].recordData).length > SELECT_LIST_LOOKUP_NOSCROLL_MAX_RECORD_TRESHOLD
						&& nodes.length === 1) {
							// append dataLoaded class to constrain height
							nodes.addClass('dataLoaded');
					}
				}
			})
			.on('change', function(e) {
				if (e.added) {
					var displayValue = e.added.text[displayFieldName];
					if (displayValue === undefined) {
						displayValue = e.added.text['id'];
					}
					a[prefix + 'Display_Value__c'] = displayValue;
					a[prefix + 'Value__c'] = e.val;

					var lookupRecord = e.added.text;
					var id = e.val;
					CS.lookupRecords[id] = lookupRecord;
				}
			});

			if (func && !j.data('CS.init')) {
				el.on('click.CS', func).css({cursor: 'pointer'}).data('CS.init', true);
			}
		}
		
		function waitForRulesToComplete(state) {
			function continueWaiting(state) {
				return new Promise(function(resolve, reject) {
					window.setTimeout(function(state) {
						return waitForRulesToComplete(state).then(resolve);
					}, 250, state);
				});
			}

			if (!state) {
				state = {c: 1, sc: 1};
			}

			if (state.c > 40 || (CS.rulesTimer === undefined && !CS.lookupQueriesAreQueued())) {
				if (state.sc < 2) {
					state.sc += 1;
					state.c = 1;
					console.log('waitForRulesToComplete: waiting for secondary evaluation...');
					return continueWaiting(state);
				}
				console.log('waitForRulesToComplete: rules complete.');
				return Promise.resolve();
			} else {
				state.c += 1;
				state.sc = 1;
				console.log('waitForRulesToComplete: waiting... ' + state.c);
				return continueWaiting(state);
			}
		}
		return {
			updateAttribute:                updateAttribute,
			addRelatedProduct:              addRelatedProduct,
			initSll:                        initSll,
			waitForRulesToComplete:         waitForRulesToComplete
		}
	}
	CS.InlineEdit = CS.InlineEdit || {};
	_.extend(CS.InlineEdit, buildInlineEditFunctions());
	var x = '<script type=\"text\/html\" id=\"CS.MultipleRelatedProductLE__tpl\">\r\n\t<%\tvar prefix = CS.Util.configuratorPrefix;\r\n\t\tvar max = definition[prefix + \'Max__c\'];\r\n\t\tvar inlineEdit =definition[\'Inline_Edit__c\'];\r\n\t\tvar disabled = ((max && relatedProducts.length >= max) ? \'disabled=\"disabled\"\' : \'\');\r\n\t\tvar prod;\r\n\t\tvar attRef;\r\n\t\tvar rowClass;\r\n\t\tvar errorClass;\r\n\t\tvar errorMessage;\r\n\t\tvar attr = anchor.attr;\r\n\t\tvar isReadOnly = attr[prefix + \'Is_Read_Only__c\'];\r\n\t\tvar isActive = attr[prefix + \'is_active__c\'];\r\n\t\tvar isRequired = attr[prefix + \'Is_Required__c\'];\r\n\t\tif (max && relatedProducts.length > max) {\r\n\t\t\terrorClass = \'attributeError\';\r\n\t\t\terrorMessage = \'<p class=\"attributeErrorMessage\">{!$Label.cscfga__attrcls_The_maximum_number_of} \' + max + \' {!$Label.cscfga__pchlpcls_exceeded_related_items}<\/p>\';\r\n\t\t}\r\n\t%>\r\n\t\t<article class=\"slds-card\"> \r\n\t\t\t\t\t<div class=\"\">\r\n\t\t\t\t\t\t<div class=\"slds-card__header slds-grid\">\r\n\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t<header class=\"slds-media slds-media--center slds-has-flexi-truncate\">  \r\n\t\t\t\t\t\t\t<div class=\"slds-media__body slds-truncate\">  \r\n\t\t\t\t\t\t\t\t<h2>\r\n\t<span class=\"slds-icon_container slds-icon-custom-custom57 slds-m-right--x-small icon-list\"><\/span>\r\n\t<% if (isRequired) { %><span class=\"required\" style=\"color:#FF0000;\">*<\/span><% } %>\r\n\t<span class=\"definition-name\"><%= definition.Name %><\/span>\r\n\t<% if (isReadOnly) { %><span class=\"readOnly\">(Read Only)<\/span><% } %>\r\n<\/h2>\r\n\t\t\t\t\t\t\t<\/div>\r\n\t\t\t\t\t\t<\/header> \r\n\t\t\t\t\t\t\t<div class=\"slds-no-flex\">\r\n\t\t\t\t\t\t\t<% if (isActive && !isReadOnly) { %>\r\n\t\t\t\t\t\t\t\t\t\t<% \r\n\t\t\t\t\t\t\t\t\t\t\tconsole.log(inlineEdit);\r\n\t\t\t\t\t\t\t\t\t\t\tif (inlineEdit === true) {\r\n\t\t\t\t\t\t\t\t\t\t%>\r\n\t\t\t\t\t\t\t\t\t\t\t<button class= \"slds-button slds-button--neutral\" <%= disabled %>  data-cs-control=\"<%= anchor.reference %>\" data-cs-ref=\"<%= anchor.reference %>\" onclick=\"CS.InlineEdit.addRelatedProduct(\'<%= anchor.reference %>\', \'<%= anchor.definitionId %>\')\" data-cs-type=\"add\" data-role=\"none\">New <%= definition.Name %><\/button>\r\n\t\t\t\t\t\t\t\t\t\t<%\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t\telse {\r\n\t\t\t\t\t\t\t\t\t\t%>\r\n\t\t\t\t\t\t\t\t\t\t\t<button <%= disabled %> class=\"slds-button slds-button--neutral\" data-cs-control=\"<%= anchor.reference %>\" data-cs-ref=\"<%= anchor.reference %>\" data-cs-action=\"addRelatedProduct\" data-cs-type=\"add\" data-role=\"none\">New <%= (definition[prefix + \'Label__c\']) ? definition[prefix + \'Label__c\'] : definition.Name %><\/button>\r\n\t\t\t\t\t\t\t\t\t\t<%\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t%>\r\n\t\t\t\t\t\t\t\t\t<% } %>\r\n\t\t\t\t\t\t\t<\/div>\r\n\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t<\/table>\r\n\t\t\t\t\t\t<\/div>\t\t\t\t\t\r\n\r\n<div class=\"pbBody\">\r\n\t<% if (relatedProducts.length > 0) { %>\r\n\t\t<table class=\"slds-table slds-table--bordered slds-table--cell-buffer\" data-cs-binding=\"<%= anchor.reference %>\" data-cs-control=\"<%= anchor.reference %>\" data-cs-type=\"list\">\r\n\t\t\t<thead>\r\n\t\t\t\t<tr class=\"slds-text-title_caps\">\r\n\t\t\t\t\t<th scope=\"col\" width=\"140px\"> <div class=\"slds-truncate\" title=\"Action\">Action<\/div><\/th>\r\n\t\t\t\t\t<th scope=\"col\"  style=\"width: 6em;\"> <div class=\"slds-truncate\" title=\"Status\">Status<\/div><\/th>\r\n\t\t\t\t\t<th scope=\"col\" > <div class=\"slds-truncate\" title=\"Name\">Name<\/div><\/th>\r\n\t<%\tfor (var i = 0; i < cols.length; i++) {\r\n\t\t\tvar spec = colSpecs[cols[i]]; %>\r\n\t\t\t\t<th scope=\"col\" >\r\n\t\t\t\t\t<%= spec.header %>\r\n\t\t\t\t<\/th>\r\n\t<%\t} %>\r\n\t\t\t\t<\/tr>\r\n\t\t\t<\/thead>\r\n\t<%\tfor (var i = 0; i < relatedProducts.length; i++) {\r\n\t\t\tprod = relatedProducts[i];\r\n\t\t\trowClass = \'dataRow \' + (i\/2 == Math.floor(i\/2) ? \'even \' : \'odd \') + (i == 0 ? \'first \' : \'\') + (i >= relatedProducts.length - 1 ? \'last\' : \'\');\r\n\t%>\r\n\t\t\t<tr data-cs-ref=\"<%= prod.reference %>\">\r\n\t\t\t\t<td width=\"140px\">\r\n\t\t\t\t<% if (isActive && ! isReadOnly) { %>\r\n\t\t\t\t\t<a href=\"javascript:void(0);\" style=\"<%= CS.getAttributeValue(prod.reference + \':\' + \'Hide_Edit_0\') ? \'visibility:hidden\' : \'visibility:shown\' %>\">\r\n\t\t\t\t\t<span style=\"color:#0070d2;\" data-cs-action=\"editRelatedProduct\" data-cs-ref=\"<%= prod.reference %>\">Edit<\/span><\/a> <a style=\"visibility:hidden\">|<\/a>\r\n\t\t\t\t\t<a href=\"javascript:void(0);\" style=\"<%= CS.getAttributeValue(prod.reference + \':\' + \'Hide_Delete_0\') ? \'visibility:hidden\' : \'visibility:shown\' %>\">\r\n\t\t\t\t\t\t<span style=\"color:#0070d2;\" data-cs-action=\"removeRelatedProduct\" data-cs-ref=\"<%= prod.reference %>\">Del<\/span>\r\n\t\t\t\t\t<\/a>\r\n\t\t\t\t\t<% if (disabled === \'\') { %>\r\n\t\t\t\t\t\t<a style=\"visibility:hidden\">|<\/a> <a href=\"javascript:void(0);\" style=\"<%= CS.getAttributeValue(prod.reference + \':\' + \'Hide_Copy_0\') ? \'visibility:hidden\' : \'visibility:shown\' %>\">\r\n\t\t\t\t\t\t<span style=\"color:#0070d2;\" data-cs-action=\"copyRelatedProduct\" data-cs-ref=\"<%= prod.reference %>\">Copy<\/span>\r\n\t\t\t\t\t\t<\/a>\r\n\t\t\t\t\t<% } %>\r\n\t\t\t\t<% } %>\r\n\t\t\t\t<\/td>\r\n\t\t\t\t<td><%= prod.config[prefix + \'Configuration_Status__c\'] %><\/td>\r\n\t\t\t\t<td ><span data-cs-action=\"editRelatedProduct\" data-cs-ref=\"<%= prod.reference %>\"><%= prod.config.Name %><\/span><\/td>\r\n\t<%\t\t\tvar prefix = CS.Util.configuratorPrefix;\r\n\t\t\t\tfor (var j = 0; j < cols.length; j++) {\r\n\t\t\t\tif (colSpecs[cols[j]].ref != undefined) {\r\n\t\t\t\t\tattRef = prod.reference + \':\' + colSpecs[cols[j]].ref;\r\n\t\t\t\t}\r\n\t\t\t\tif (attRef != undefined) {\r\n\t\t\t\t\tvar displayInfo = CS.Service.config[attRef][\'displayInfo\'];\r\n                    var definition = CS.Service.config[attRef].definition;\r\n                    console.log(displayInfo);\r\n\t\t\t\t\tif (\'User Input\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n\t%>\r\n                        <td><input class=\"slds-input\" data-cs-binding=\"<%=attRef%>\" id=\"<%=attRef%>\" name=\"<%=attRef%>\" type=\"text\" value=\"<%= CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\'] %>\" onchange=\"CS.InlineEdit.updateAttribute(this)\"><\/input><\/td>\r\n    <%\r\n                    } else if (\'Date\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n\t\t\t\t\t\t\r\n\t\t\t\t\t\t\r\n\t%>\r\n                        <td><input class=\"slds-input\" data-cs-binding=\"<%=attRef%>\" id=\"<%=attRef%>\" name=\"<%=attRef%>\" value=\"<%= CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\'] %>\" onchange=\"CS.InlineEdit.updateAttribute(this)\" data-role=\"none\" \r\n\t\t\t\t\tonfocus=\"DatePicker.pickDate(true, \'<%=attRef%>\', false );\" size=\"12\" \/><\/input>\r\n\t\t\t\t\t<\/td>\r\n    <%\r\n\t\t\t\t\t} else if (\'Checkbox\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n\t%>\r\n                       <% if (CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\') {\r\n    %>\r\n\t\r\n                            <td>\r\n\t\t\t\t\t\t\t<label>\r\n\t\t\t\t\t\t\t<input type=\"checkbox\" class=\"checkbox\" data-cs-binding=\"<%=attRef%>\" id=\"<%=attRef%>\" name=\"<%=attRef%>\" checked=\"checked\" value=\"<%= CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\' ? true : false %>\"  onchange=\"CS.InlineEdit.updateAttribute(this)\" ><\/input>\r\n\t\t\t\t\t\t\t<span class=\"checkbox-style\"><\/span>\r\n\t\t\t\t\t\t\t<\/label>\r\n\t\t\t\t\t\t\t<\/td>\r\n    <%\r\n                        } else {\r\n    %>\r\n                            <td>\r\n\t\t\t\t\t\t\t<label>\r\n\t\t\t\t\t\t\t<input type=\"checkbox\" class=\"checkbox\" data-cs-binding=\"<%=attRef%>\" id=\"<%=attRef%>\" name=\"<%=attRef%>\"  value=\"<%= CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\' ? true : false %>\"  onchange=\"CS.InlineEdit.updateAttribute(this)\" ><\/input>\r\n\t\t\t\t\t\t\t<span class=\"checkbox-style\"><\/span>\r\n\t                        <\/label>\r\n\t\t\t\t\t\t\t<\/td>\r\n\t<%\t\r\n                        } %>\r\n    <%\r\n\t\t\t\t\t    \r\n\t\t\t\t\t} else if (\'Lookup\' === displayInfo && !definition[prefix + \'Select_List_Lookup__c\'] && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']){ \r\n\r\n                        lookups = true;\r\n    %>\r\n                        <td>\r\n                            <span class=\"lookupInput\">\r\n                                <input type=\"text\"\r\n                                    id=\"<%=attRef%>\"\r\n                                    name=\"<%=attRef%>\"\r\n                                    data-cs-binding=\"<%=attRef%>\"\r\n                                    data-cs-select-list-lookup=\"false\"\r\n                                    data-role=\"none\"\r\n                                    data-mini=\"true\"\r\n                                    value=\"\"\r\n                                    size=\"20\"\r\n                                    onchange=\"CS.InlineEdit.updateAttribute(this)\" \/>\r\n                            <\/span>\r\n                        <\/td>\r\n    <%\r\n\t\t\r\n\t\r\n                    } else if (\'Lookup\' === displayInfo && definition[prefix + \'Select_List_Lookup__c\'] && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']){ \r\n\r\n                        lookups = true;\r\n    %>\r\n                        <td>\r\n                            <div class=\"form-control form-control-select-lookup\">\r\n                                <span class=\"lookupInput\">\r\n                                    <input style=\"border: none;\" type=\"text\"\r\n                                        id=\"<%=attRef%>\"\r\n                                        name=\"<%=attRef%>\"\r\n                                        data-cs-binding=\"<%=attRef%>\"\r\n                                        data-cs-select-list-lookup=\"true\"\r\n                                        data-role=\"none\"\r\n                                        data-mini=\"true\"\r\n                                        value=\"\"\r\n                                        size=\"20\"\r\n                                        onchange=\"CS.InlineEdit.updateAttribute(this)\" \/>\r\n                                <\/span>\r\n                            <\/div>\r\n                        <\/td>\r\n    <%              \r\n                        if (relatedProductsIds.indexOf(attRef) == -1) {\r\n                            relatedProductsIds.push(attRef);\r\n                        }\r\n\t\t\t\t\t\tconsole.log(\'stjepanTest\'+attRef);\r\n\t\t\t\t\t\tconsole.log(\'stjepanTest\'+isReadOnly);\r\n                    }\r\n                    else if (\'Select List\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n    %>\r\n                        <td>\r\n\t\t\t\t\t\t\t<div class=\"select-wrapper\">\t\r\n                            <select class=\"slds-select\" data-cs-binding=\"<%=attRef%>\" id=\"<%=attRef%>\" name=\"<%=attRef%>\" onchange=\"CS.InlineEdit.updateAttribute(this)\">\r\n    <%\r\n                            var options = CS.Service.config[attRef][\'selectOptions\'];\r\n                            for (var k = 0; k < options.length; k++) {\r\n                                var selected = (options[k][\'Name\'] === CS.Service.config[attRef][\'attr\'][\'cscfga__Display_Value__c\']);\r\n                                if (selected) {\r\n    %>\r\n                                    <option value=\"<%= options[k][\'cscfga__Value__c\'] %>\" selected=\"selected\"><%= options[k][\'Name\'] %><\/option>\r\n    <%\r\n                                } else {\r\n    %>      \r\n                                    <option value=\"<%= options[k][\'cscfga__Value__c\'] %>\"><%= options[k][\'Name\'] %><\/option>\r\n\t<%\t\t  }\r\n                            }\r\n    %>   \r\n                            <\/select>\r\n\t\t\t\t\t\t\t<span class=\"icon-arrow-down\"><\/span>\r\n\t\t\t\t\t\t\t<\/div>\r\n                        <\/td>\r\n    <%\r\n                    }\r\n                    else if (attRef.indexOf(\'Additional_Attributes\') != -1) {\r\n   \r\n\t\t\t\t\t\tvar addAtts = CS.getAttributeValue(attRef);\r\n\t\t\t\t\t\tif (addAtts != \'\') {\r\n\t%>\r\n    \t\t\t\t\t\t<td><table><tr>\r\n\t<%\r\n\t\t\t\t\t\t\taddAtts = addAtts.split(\',\');\r\n\t\t\t\t\t\t\tfor (var q = 0; q < addAtts.length; q++) {\r\n\t%>\r\n\t\t\t\t\t\t\t\t<th><%= addAtts[q] %><\/th>\r\n\t<%\r\n\t\t\t\t\t\t\t}\r\n\t%>\r\n\t\t\t\t\t\t\t<\/tr>\r\n\t\t\t\t\t\t\t<tr>\r\n\t<%\r\n\t\t\t\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\tfor (var q = 0; q < addAtts.length; q++) {\r\n\t\t\t\t\t\t\t\tvar addAttRef = prod.reference + \':\' + addAtts[q].split(\' \').join(\'_\') + \'_0\';\r\n\r\n\t%>\r\n\t<%\r\nvar displayInfo = CS.Service.config[addAttRef][\'displayInfo\'];\r\n                    var definition = CS.Service.config[addAttRef].definition;\r\n                    console.log(displayInfo);\r\n\t\t\t\t\tif (\'User Input\' === displayInfo && inlineEdit) {\r\n\t%>\r\n                        <td><input class=\"slds-input\" data-cs-binding=\"<%=addAttRef%>\" id=\"<%=addAttRef%>\" name=\"<%=addAttRef%>\" type=\"text\" value=\"<%= CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\'] %>\" onchange=\"CS.InlineEdit.updateAttribute(this)\"><\/input><\/td>\r\n    <%\r\n                    } else if (\'Date\' === displayInfo && inlineEdit) {\r\n\t%>\r\n                        <td><input class=\"form-control\" data-cs-binding=\"<%=addAttRef%>\" id=\"<%=addAttRef%>\" name=\"<%=addAttRef%>\" value=\"<%= CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\'] %>\" onchange=\"CS.InlineEdit.updateAttribute(this)\" data-role=\"none\" \r\n\t\t\t\t\tonfocus=\"DatePicker.pickDate(true, \'<%=addAttRef%>\', false );\" size=\"12\" \/><\/input>\r\n\t\t\t\t\t <span class=\"dateFormat\">\r\n\t\t\t\t\t    [&nbsp;<a href=\"\" class=\"todayPicker\" onclick=\"return (function(){ DatePicker.insertDate(CS.todayFormatted, \'<%=addAttRef%>\', true); return false; })();\"><%=CS.todayFormatted%><\/a>&nbsp;]\r\n\t\t\t\t    <\/span><\/td>\r\n    <%\r\n\t\t\t\t\t} else if (\'Checkbox\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n\t%>\r\n                       <% if (CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\') {\r\n    %>\r\n                            <td>\r\n\t\t\t\t\t\t\t<label>\r\n\t\t\t\t\t\t\t<input type=\"checkbox\" class=\"checkbox\" data-cs-binding=\"<%=addAttRef%>\" id=\"<%=addAttRef%>\" name=\"<%=addAttRef%>\" checked=\"checked\" value=\"<%= CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\' ? true : false %>\"  onchange=\"CS.InlineEdit.updateAttribute(this)\" ><\/input>\r\n\t\t\t\t\t\t\t<span class=\"checkbox-style\"><\/span>\r\n\t                        <\/label>\r\n\t\t\t\t\t\t\t<\/td>\r\n    <%\r\n                        } else {\r\n    %>\r\n                            <td>\r\n\t\t\t\t\t\t\t<label>\r\n\t\t\t\t\t\t\t<input type=\"checkbox\" class=\"checkbox\" data-cs-binding=\"<%=addAttRef%>\" id=\"<%=addAttRef%>\" name=\"<%=addAttRef%>\"  value=\"<%= CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\'] === \'Yes\' ? true : false %>\"  onchange=\"CS.InlineEdit.updateAttribute(this)\" ><\/input>\r\n\t\t\t\t\t\t\t<span class=\"checkbox-style\"><\/span>\r\n\t                        <\/label>\r\n\t\t\t\t\t\t\t<\/td>\r\n    <%                       \r\n                        } %>\r\n    <%              \r\n                    }\r\n                    else if (\'Select List\' === displayInfo && inlineEdit && !isReadOnly && CS.Service.config[attRef][\'attr\'][\'cscfga__is_active__c\']) {\r\n    %>\r\n                        <td>\r\n\t\t\t\t\t\t\t<div class=\"select-wrapper\">\r\n                            <select class=\"slds-select\" data-cs-binding=\"<%=addAttRef%>\" id=\"<%=addAttRef%>\" name=\"<%=addAttRef%>\" onchange=\"CS.InlineEdit.updateAttribute(this)\">\r\n    <%\r\n                            var options = CS.Service.config[addAttRef][\'selectOptions\'];\r\n                            for (var k = 0; k < options.length; k++) {\r\n                                var selected = (options[k][\'Name\'] === CS.Service.config[addAttRef][\'attr\'][\'cscfga__Display_Value__c\']);\r\n                                if (selected) {\r\n    %>\r\n                                    <option value=\"<%= options[k][\'cscfga__Value__c\'] %>\" selected=\"selected\"><%= options[k][\'Name\'] %><\/option>\r\n    <%\r\n                                } else {\r\n    %>      \r\n                                    <option value=\"<%= options[k][\'cscfga__Value__c\'] %>\"><%= options[k][\'Name\'] %><\/option>\r\n\t<%\t\t  }\r\n                            }\r\n    %>   \r\n                            <\/select>\r\n\t\t\t\t\t\t\t<span class=\"icon-arrow-down\"><\/span>\r\n\t\t\t\t\t\t\t<\/div>\r\n                        <\/td>\r\n    <%\r\n        }\r\n    %> \r\n\t\r\n\t<%\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t}\r\n\t%>\r\n\t\t\t\t\t\t\t<\/tr><\/table><\/td>\r\n    <%\r\n\t\t\t\t\t\t} \r\n\t\r\n                    }\r\n                    else {\r\n    %>\r\n                        <td><%= CS.getAttributeDisplayValue(attRef) %><\/td>\r\n    <%\r\n                    }\r\n                }\r\n            }\r\n    %>\r\n\t\t\t<\/tr>\r\n\t<%  } %>\r\n\t\t<\/table>\r\n\t<% } else { %>\r\n\t\t<table class=\"list\" data-cs-control=\"<%= anchor.reference %>\" data-cs-type=\"list\">\r\n\t\t\t<tr class=\"dataRow even first last\">\r\n\t\t\t\t<td class=\"dataCell\">\r\n\t\t\t\t\tNo items to display\r\n\t\t\t\t<\/td>\r\n\t\t\t<\/tr>\r\n\t\t<\/table>\r\n\t<% } %>\r\n\t\t\t\t\t<\/div>\r\n\t\t\t\t\t\t<div class=\"pbFooter secondaryPalette\">\r\n\t\t\t\t\t\t\t<div class=\"bg\"><\/div>\r\n\t\t\t\t\t\t<\/div>\r\n\t\t\t\t\t<\/div>\r\n\t\t\t\t<%= errorMessage %>\r\n\t\t<\/article>\r\n\t<\/script>\r\n';
	CS.App.Components.Repository.addComponent('configurator', 'MultipleRelatedProductLE', x);
	
});
