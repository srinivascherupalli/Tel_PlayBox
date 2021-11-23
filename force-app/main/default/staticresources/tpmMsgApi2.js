require(['cs_js/cs-full', 'cs_js/cs-event-handler'], function(CS, EventHandler) {

	//some functions are similar because this used to be split in 2 files: commercial and non commercial.
	//to do: before final launch, clean this up, refactor it please
	//tpmMsgApi2

    var childDefinitions = {
        'Reserve Numbers' : '',
        'Site Details' : '',
        'Customer Requested Dates' : ''
    } 

	var tpe = function() {
		const TPE_FRAME_ID = '#technicalConfigFrame';
		var responseMethods = {
			"test": testMethod,
			"comMsgToTPE": comMsgToTPE,
			"techMsgToTPE": techMsgToTPE,
			"executeRules": executeRules,
			"getAllConfigs": getAllConfigs,
			"setValue": setValue,
			"setParentValue": setParentValue,
			"setValueTechnical": setValueTechnical,
			"setValueCommercial": setValueCommercial,
			"getConfig": getConfig,
			"getConfigTechnical": getConfigTechnical,
            "execute": execute,
            "executeAction" : executeAct,
			"resizeCommercial": resizeCommercial,
			"executeOnLoad": executeOnLoad,
			"registerOnLoad": registerOnLoad,
			"executeRulesOnParent": executeRulesOnParent,
			"markParentInvalid": markParentInvalid,
			"markParentInvalidQuantity": markParentInvalidQuantity,
			"executeRulesOnParentQuantity": executeRulesOnParentQuantity,
			"executeOnDelete": executeOnDelete,
			"registerOnDelete": registerOnDelete,
			"setOEValidation": setOEValidation
		};
		var onLoadEvents = {};
		var onDeleteEvents = {};
		var params = [];
		var frameHeights = {};
		var attributeMap = {};
		var evaluateAfterReloading = false;
		var childUnsavedChanges = {
			status: false,
			msg: 'There are unsaved changes on child configurations.'
		};
		var childQuantityValidation = {
			status: false,
			msg: 'There are invalid quantities on child configurations.'
		};

		function receiveMessageCommercial(event) {
			try {
				var response = JSON.parse(atob(event.data));
				if (response['sender'] === 'TPE') {
					var method = response['method'];
					if (method && responseMethods[method]) {
						responseMethods[method](response);
					}
				}
			} catch (err) {
				console.log('***** Ignoring msg:' + JSON.stringify(err));
			}
		}

		function updateSelectOptions(tabName, picklistName, values) {
			comMsgToTPE({
				tabName: tabName,
				picklistName: picklistName,
				values: values
			}, 'updateSelectOptions');
		}

		function changeColumnDisplay(tabName, data) {
			comMsgToTPE({
				tabName: tabName,
				data: data
			}, 'changeColumnDisplay');
		}

		function executeAction(tabName, actionName, inputMap) {
			comMsgToTPE({
				tabName: tabName,
				actionName: actionName,
				inputMap: inputMap
			}, 'executeAction');
		}

		function receiveMessageTechnical(event) {
			try {
				var response = JSON.parse(atob(event.data));
				var configId = CS.params.configId;
				if (response['recipient'] === configId || response['recipient'] === 'all') {
					var method = response['method'];
					if (method && responseMethods[method]) {
						responseMethods[method](response);
					}
				}
			} catch (err) {
				console.log('***** Ignoring msg:' + JSON.stringify(err));
			}
		}

		function executeRemoteAction(tabName, inputMap, className, handler) {
			comMsgToTPE({
				tabName: tabName,
				inputMap: inputMap,
				className: className,
				handler : handler
			}, 'executeRemoteAction');
		}

		function getAllConfigs(params) {
			comMsgToTPE(params.value, 'getConfigData');
		}

		function getConfig(tabName, method) {
			comMsgToTPE({
				tabName: tabName,
				method: method
			}, 'getConfig');
		}

		function setValue(tabName, attributeName, attributeValue) {
			comMsgToTPE({
				tabName: tabName,
				attributeName: attributeName,
				attributeValue: attributeValue
			}, 'setValue');
		}

		function setLookupValuesRemote(tabName, recordId, fieldsMap) {
			comMsgToTPE({
				tabName: tabName,
				recordId: recordId,
				fieldsMap: fieldsMap
			}, 'setLookupValuesRemote');
		}

		function setParentValue(attributeName, attributeValue) {
			techMsgToTPE({
				attributeName: attributeName,
				attributeValue: attributeValue
			}, 'setValueCommercial');
		}

		function execute(params) {
			eval(params.value.method + '(' + JSON.stringify(params.value.data) + ')');
        }
        
		function executeAct(params) {
			eval(params.value.actionName + '(' + JSON.stringify(params.value.inputMap.value) + ')');
		}        

		function setQuantity(tabName, min, max) {
			comMsgToTPE({
				tabName: tabName,
				min: min,
				max: max
			}, 'setQuantity');
		}

		function setValueTechnical(params) {
			CS.setAttribute(params.value.attributeName, params.value.attributeValue);
		}

		function setValueCommercial(params) {
			if(params.value.attributeName != 'childDefinitions') {
				CS.setAttribute(params.value.attributeName, params.value.attributeValue);
			}
			else {
				childDefinitions[params.value.attributeValue.name] = params.value.attributeValue.id;
			}
		}

		function getConfigTechnical(params) {
			techMsgToTPE({
				data: CS.Service.config,
				method: params.value.method
			}, 'getConfigCallback');
		}

		function executeRulesOnParent(params) {
			childUnsavedChanges.status = false;
			CS.Rules.evaluateAllRules();
		}

		function executeRulesOnParentQuantity(params) {
			childQuantityValidation.status = false;
			CS.Rules.evaluateAllRules();
		}

		//new validation method
		function setOEValidation(params) {
			if (CS.getAttributeValue('OE_Validation_0') != params.value) {
				CS.setAttributeValue('OE_Validation_0' , params.value);
			}
		}

		function markParentInvalid(params) {
			CS.markConfigurationInvalid(params.value);
			childUnsavedChanges.status = true;
			childUnsavedChanges.msg = params.value;
		}

		function markParentInvalidQuantity(params) {
			CS.markConfigurationInvalid(params.value);
			childQuantityValidation.status = true;
			childQuantityValidation.msg = params.value;
		}

		function techMsgToTPE(message, methodName) {
			var configId = CS.params.configId;
			var msg = btoa(JSON.stringify({
				value: message,
				sender: configId,
				recipient: 'TPE',
				method: methodName
			}));
			window.parent.postMessage(msg, '*');
		}

		function cancelConfiguration() {
			techMsgToTPE({
				defId: CS.params.definitionId
			}, 'onCancelConfiguration');
		}

		function comMsgToTPE(message, methodName) {
			var technicalFrame = jQuery(TPE_FRAME_ID);
			var win = technicalFrame[0].contentWindow || technicalFrame[0];
			var configId = CS.params.configId;
			var msg = btoa(JSON.stringify({
				value: message,
				sender: configId,
				recipient: 'TPE',
				method: methodName
			}));
			win.postMessage(msg, '*');
		}

		function testMethod(params) {
			console.log('Test method, params:' + JSON.stringify(params));
		}

		function resizeRequest(frameHeight) {
			techMsgToTPE({
				defId: CS.params.definitionId,
				height: frameHeight
			}, 'resizeTechnical');
			if (!CS.Service.validateCurrentConfig().isValid || CS.getConfigurationProperty('', 'status') === 'Incomplete') {
				var urlToParse = location.search;
				var resultParams = parseQueryString(urlToParse);
				techMsgToTPE(resultParams['definitionName'], 'singleIsChanged');
			}
		}

		function resizeCommercial(params) {
			var configFrame = jQuery('#technicalConfigFrame');
			if (params.value.tabs) {
                if(params.value.defId == childDefinitions['Reserve Numbers'] && params.value.height < 500) {
                    SPM.executeAction('Reserve Numbers', 'resizeRequest' , {value:1000});
                }
                if(params.value.defId == childDefinitions['Customer Requested Dates'] && params.value.height <= 291) {
                    SPM.executeAction('Customer Requested Dates', 'resizeRequest' , {value:331});
                }
                if(params.value.defId == childDefinitions['Site Details'] && params.value.height <= 400) {
                	//change for EDGE-74695 - lookups weren't visible but cut off because height was small
                    SPM.executeAction('Site Details', 'resizeRequest' , {value:400});
                }
				jQuery(configFrame).height(params.value.height);
				if (params.value.defId == 'initial') {
					frameHeights = {};
				}
				frameHeights[params.value.defId] = params.value.height;
			} else {
				if (frameHeights[params.value.defId] && params.value.defId != 'initial') {
					if (frameHeights[params.value.defId] != params.value.height) {
						if (params.value.height == 41) {
							params.value.height = 0;
						}
						jQuery(configFrame).height(jQuery(configFrame).height() + params.value.height - frameHeights[params.value.defId]);
						frameHeights[params.value.defId] = params.value.height;
					}
				} else {
					if (params.value.defId == 'initial') {
						jQuery(configFrame).height(params.value.height);
						frameHeights = {};
						if (evaluateAfterReloading) {
							childUnsavedChanges.status = false;
							CS.Rules.evaluateAllRules();
						} else {
							evaluateAfterReloading = true;
						}
					} else {
						jQuery(configFrame).height(jQuery(configFrame).height() + params.value.height);
					}
					frameHeights[params.value.defId] = params.value.height;
				}
			}


		}

		function waitForRulesToComplete(state) {
			function continueWaiting(state) {
				return new Promise(function(resolve, reject) {
					window.setTimeout(function(state) {
						return waitForRulesToComplete(state).then(resolve);
					}, 20, state);
				});
			}

			if (!state) {
				state = {
					c: 1,
					sc: 1
				};
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

		function executeRules(params) {
			var basketSpec = {
				Id: CS.params.basketId,
				linkedId: CS.params.linkedId,
				packageSlotId: CS.params.packageSlotId
			};
			CS.Rules.evaluateAllRules();
			waitForRulesToComplete().then(
				function(response) {

					// Validate PC
					var validationResult = CS.Service.validateCurrentConfig(true);
					var configurationStatus = CS.getConfigurationProperty('', 'status');

					if (configurationStatus === 'Incomplete' || !(validationResult.isValid)) {
						// There are validation errors within the configuration. The configuration can still be saved but the basket cannot be synchronised with an Opportunity until the errors have been corrected.
						CS.markConfigurationInvalid('{!$Label.cscfga__configuration_There_are_validation_errors}');
						console.log('***** Configuration invalid.');
					} else {}
					CS.Log.info('Persisting configuration...');
					CS.Service.persistConfiguration(basketSpec, (function(p) {
						return function(result, redirectCallback) {
							if (result._success) {
								CS.Log.info('Configuration persisted');
							} else {
								CS.markConfigurationInvalid(result._message);
								console.log('***** Configuration invalid.');
							}
						};
					})(params));

				},
				function(err) {
					techMsgToTPE('Invalid', 'test');
				}
			);
		}

		var parseQueryString = function(url) {
			var urlParams = {};
			url.replace(
				new RegExp("([^?=&]+)(=([^&]*))?", "g"),
				function($0, $1, $2, $3) {
					urlParams[$1] = $3;
				}
			);
			return urlParams;
		};

		function initConfigListener() {
			var urlToParse = location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['CommercialConfigurationId'] !== undefined) {
				window.addEventListener('message', receiveMessageTechnical);
			} else {
				window.addEventListener('message', receiveMessageCommercial);
			}
		}

		function registerOnLoad(definitionName, method) {
			if (onLoadEvents) {
				onLoadEvents[definitionName] = method;
			}
		}

		function registerOnDelete(definitionName, method) {
			if (onDeleteEvents) {
				onDeleteEvents[definitionName] = method;
			}
		}

		function executeOnLoad(params) {
			var decodedUrlName = decodeURIComponent(params.value.replace(/\+/g, ' '));
			if (onLoadEvents[decodedUrlName]) {
				onLoadEvents[decodedUrlName]();
			}
		}

		function executeOnDelete(params) {
			var decodedUrlName = decodeURIComponent(params.value.replace(/\+/g, ' '));
			if (onDeleteEvents[decodedUrlName]) {
				onDeleteEvents[decodedUrlName]();
			}
		}

		function sendOnLoadRequest() {
			var urlToParse = location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['definitionName']) {
				techMsgToTPE(resultParams['definitionName'], 'onLoadTechnical');
			}
		}
		function handleSpecificDefinitions() {
			try {
				var defsToInit = ['Site Details', 'Reserve Numbers', 'Customer Requested Dates'];
				var defName = CS.Service.config[""].config.Name;
				if(defsToInit.includes(defName)) {
					SPM.setParentValue('childDefinitions', {name: defName, id: CS.params.definitionId});
				}
			}
			catch(e) {
				console.log(e);
			}
		}

		var cleanUI = function() {
			var urlToParse = window.location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['CommercialConfigurationId'] !== undefined) {
				var cancelButtons = jQuery("button[data-cs-group='Cancel']");
				for (var i = 0; i < cancelButtons.length - 1; i++) {
					//cancelButtons[i].style.display = 'none';
					jQuery(cancelButtons[i]).attr('onclick', '').on('click', cancelConfiguration);
				}
				var finishButtons = jQuery("button[data-cs-group='Finish']");
				for (var j = 0; j < finishButtons.length; j++) {
					finishButtons[j].innerHTML = 'Save';
				}
				jQuery('#screensList').hide();
				jQuery('.slds-page-header').hide();
				jQuery('.powered-by').hide();
				jQuery('body').css('padding', '0');
				jQuery('body').css('margin', '0');
				jQuery('.screen-wrapper').css('border', 'none');
				jQuery('button[data-cs-group="Finish"]').css('border-radius', '0.25rem');
				jQuery('body').css('overflowY', 'hidden');
            }
            if(CS.Service.config && CS.Service.config[""].config) {
                if(CS.Service.config[""].config.Name == 'Site Details' || CS.Service.config[""].config.Name == 'Customer Requested Dates') {
                    jQuery('.slds-section table').css('margin-top' , 40);
                }
            }
		};
		var loadNonCommercialDefinitions = function(targetContainer, tabNames, render) {
					console.log('***initial loading');
			var targetSrc = jQuery('.screen-footer')[0];
			targetSrc = jQuery(targetSrc).prev()[0];
			var screenContent = targetSrc;
			if (targetContainer) {
				if (targetContainer.toUpperCase().indexOf('SECTION=') != -1) {
					var selectedSectionName = targetContainer.substring(8);
					var selectedSectionTitle = jQuery("h3:contains('" + selectedSectionName + "')");
					if (selectedSectionTitle[0]) {
						var contentContainer = jQuery(selectedSectionTitle[0]).parent().find('div[class="slds-section__content"]');
						if (contentContainer[0]) {
							targetSrc = contentContainer[0];
						}
					}

				}
			}
			var urlToParse = window.location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['CommercialConfigurationId'] === undefined) {
				if (!jQuery(screenContent).attr("data-tech") && CS.Service.getCurrentConfigRef() === '') {
					var tabNamesParameter = '&tabNames=';
					var configId = CS.params['configId'];
					var hostname = location.origin.replace('cscfga', 'csoe');
					var currentUrl = window.location.href;
					var firstPart = currentUrl.split('cscfga__')[0];
					var parts = firstPart.split('/');
					var urlPrefix = '';
					var communityPrefix = parts[parts.length - 2];
					if (communityPrefix.indexOf('force.com') > -1 || currentUrl.indexOf('.com.au/') > -1) {
						urlPrefix = '';
					} else {
						urlPrefix = communityPrefix;
					}

					var src = hostname + '/' + urlPrefix + '/csoe__ScalableProductModels?configurationId=' + configId + '&isdtp=vw';
					if (tabNames) {
						for (var i = 0; i < tabNames.length; i++) {
							tabNamesParameter += tabNames[i];
							if (i < tabNames.length - 1) {
								tabNamesParameter += '@@';
							}
						}
						src += tabNamesParameter;
					}
					if (render) {
						if (render.indexOf('Sections') != -1) {
							render = 'renderSections=true';
						}
						src += '&' + render;
					}
					var frameHeight = '550';
					var iframeHtml = '<iframe style=" width: 1px; min-width: 100%; *width: 100%; overflow:auto;-webkit-overflow-scrolling:touch" width="100%" height="' + frameHeight + '" scrolling="no" marginheight="0" marginwidth="0" frameborder="0" id="technicalConfigFrame" src="' + src + '"></iframe>';
					jQuery(iframeHtml).appendTo(jQuery(targetSrc));
					jQuery(screenContent).attr('data-tech', 'loaded');
				} else {
					console.log('***inital load else branch');
					/*deprecated
					if (CS.getConfigurationProperty('', 'status') === 'Incomplete') {
						CS.markConfigurationInvalid('testMessage');
					}
					if (childUnsavedChanges.status) {
						CS.markConfigurationInvalid(childUnsavedChanges.msg);
					}
					if (childQuantityValidation.status) {
						CS.markConfigurationInvalid(childQuantityValidation.msg);
					}
					*/
				}
			}
		};

		function getInitialAttributeValues() {
			var attributes = CS.Service.config;
			var attKeys = Object.keys(attributes);

			var map = {};

			for (var i = 0; i < attKeys.length; i++) {
				if (!(attributes[attKeys[i]].attr === undefined || attributes[attKeys[i]].attr === null))
					map[attKeys[i]] = attributes[attKeys[i]].attr.cscfga__Value__c;
			}
			attributeMap = map;
		}

		function compareAttributeValues() {
			var newAttributes = CS.Service.config;
			var newAttKeys = Object.keys(newAttributes);
			var flag = false;
			for (var i = 0; i < newAttKeys.length; i++) {
				if (!(newAttributes[newAttKeys[i]].attr === undefined || newAttributes[newAttKeys[i]].attr === null))
					if (newAttributes[newAttKeys[i]].attr.cscfga__Value__c != attributeMap[newAttKeys[i]]) {
						flag = true;
						break;
					}
			}
			if (flag) {
				var urlToParse = location.search;
				var resultParams = parseQueryString(urlToParse);
				techMsgToTPE(resultParams['definitionName'], 'singleIsChanged');
				getInitialAttributeValues();
			}
		}

		var setCommercialConfigurationId = function() {
			var urlToParse = location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['CommercialConfigurationId'] && CS.getAttributeValue('Configuration_Id_0') === '') {
				CS.setAttribute("Configuration_Id_0", resultParams['CommercialConfigurationId']);
			}
		};
		var initNonCommercialConfiguration = function() {
			var urlToParse = location.search;
			var resultParams = parseQueryString(urlToParse);
			if (resultParams['CommercialConfigurationId']) {
			    jQuery('html').css('position','static');
				setTimeout(function() {
					var frameHeight = jQuery('body').height();
					if (frameHeight != currentHeight && initialLoad) {
						resizeRequest(frameHeight);
						currentHeight = frameHeight;
					}
				}, 600);
				if (!initialLoad) {
					setCommercialConfigurationId();
					cleanUI();
					sendOnLoadRequest();
					handleSpecificDefinitions();
					initialLoad = true;
					getInitialAttributeValues();
					setTimeout(function() {
                        var currentframeHeight = jQuery('body').height();
						resizeRequest(currentframeHeight);
						currentHeight = currentframeHeight;
					}, 600);
					jQuery('body').css('overflowY', 'hidden');
				} else {
					compareAttributeValues();
				}
			}
		};

		var currentHeight = 0;
		var initialLoad = false;

		return {
			"registerOnLoad": registerOnLoad,
			"registerOnDelete": registerOnDelete,
			"testMethod": testMethod,
			"comMsgToTPE": comMsgToTPE,
			"techMsgToTPE": techMsgToTPE,
			"TPE_FRAME_ID": TPE_FRAME_ID,
			"initConfigListener": initConfigListener,
			"setValue": setValue,
			"setParentValue": setParentValue,
			"getConfig": getConfig,
			"onLoadEvents": onLoadEvents,
			"onDeleteEvents": onDeleteEvents,
			"sendOnLoadRequest": sendOnLoadRequest,
			"initNonCommercialConfiguration": initNonCommercialConfiguration,
			"loadNonCommercialDefinitions": loadNonCommercialDefinitions,
			"initialLoad": initialLoad,
			"frameHeights": frameHeights,
			"childUnsavedChanges": childUnsavedChanges,
			"childQuantityValidation": childQuantityValidation,
			"setQuantity": setQuantity,
			"setLookupValuesRemote": setLookupValuesRemote,
			"executeRemoteAction": executeRemoteAction,
			"resizeRequest": resizeRequest,
			"updateSelectOptions" : updateSelectOptions,
			"setOEValidation": setOEValidation,
			"executeAction" : executeAction,
			"changeColumnDisplay" : changeColumnDisplay,
			"childDefinitions" :childDefinitions
		};

	}

    CS.EventHandler.subscribe(CS.EventHandler.Event.AFTER_SAVE_ACTION, function (payload) {
      console.log('-------> AFTER_SAVE_ACTION');
      if (payload._success) {
       var configurationId;
       console.log('-------> payLoad -> ' + payload);
       for (var property in payload) {
        console.log(property + ' = ' + payload[property] + '\n');
        if (property == 'rootConfigIds') {
         configurationId = payload[property];
        }
       }
      console.log('-------> location.href = ' + window.location.href);
       for (var prop in CS.Service.config) {
        if (prop == 'Configuration_Id_0') {
         var currentUrl = window.location.href;
         var indOfRet = currentUrl.indexOf('&retURL');
         var secondPart = currentUrl.slice(indOfRet);
         var configIdString = '&configId=' + configurationId;
         payload.redirectUrl = currentUrl.replace(secondPart, configIdString.concat(secondPart));
         console.log('-------> ' + payload.redirectUrl);
         
         if (window.SPM !== undefined) {
          console.log('EnteredCollapseSection');
           var msg = {
            configId: configurationId,
            defId: CS.params.definitionId,
            noChange: true
           };
           window.SPM.techMsgToTPE(msg, 'onSaveConfiguration');
           console.log('-------> MsgSent');
          }
        }
       }
      }
     });
    
    CS.EventHandler.subscribe(CS.EventHandler.Event.AFTER_CANCEL_ACTION, function (payload) {
        console.log('AFTER_CANCEL_ACTION');
        console.log('payLoad -> ' + payload);
         for (var property in payload) {
          console.log(property + ' = ' + payload[property] + '\n');
         }
         console.log('location.href = ' + window.location.href);
        
        for (var prop in CS.Service.config) {
           if (prop == 'Configuration_Id_0') {
            var currentUrl = window.location.href;
           }
          }
    });

	window.SPM = tpe();
	window.SPM.initConfigListener();
	window.SPM.registerOnLoad('Voice FNN Details', onLoadVoiceFNNDetails);
	window.SPM.registerOnLoad('Site Details', onLoadSiteDetails);
	//window.SPM.registerOnLoad('Appointment', onLoadAppointment);
	window.SPM.registerOnLoad('Reserve Numbers',onLoadReserveNumber);
	window.SPM.registerOnLoad('Customer Requested Dates',onLoadCRD);
	jQuery('#configurationContainer').css('max-width', 'none');

});

function finish() {
	console.log('***finishMechEntered');
	var self = this;
	CS.Util.waitFor(
		function until() {
			CS.Log.info('*** finish(): Waiting for rules to finish... ');
			return (typeof CS.rulesTimer === 'undefined');
		},
		function payload() {
			var validationResult = CS.Service.validateCurrentConfig(true);
			var configurationStatus = CS.getConfigurationProperty('', 'status');

			if (configurationStatus === 'Incomplete' || !(validationResult.isValid)) {
				console.log('***saveEntered_statuIncomplete_isNotValid');
				updateFinishButtonUI(self);
				// There are validation errors within the configuration. The configuration can still be saved but the basket cannot be synchronised with an Opportunity until the errors have been corrected.
				CS.markConfigurationInvalid('There are validation errors within the configuration. The configuration can still be saved but the basket cannot be synchronised with an Opportunity until the errors have been corrected.');
				/*
				//mark stuff invalid test
				window.SPM.setOEValidation(params);
				*/
				var urlToParse = window.location.search;
				var resultParams = parseQueryString(urlToParse);
				if (resultParams['CommercialConfigurationId'] !== undefined) {
					setTimeout(function(){
						window.SPM.resizeRequest(jQuery('body').height());
					}, 200);
				}
			} else {
				saveConfiguration(self);
			}
		}
	);
}

function saveConfiguration(buttonElement) {
	console.log('***saveConfigurationStart');
	var basketSpec = {
		Id: params.basketId,
		linkedId: params.linkedId,
		packageSlotId: params.packageSlotId
	};
	if (typeof buttonElement === 'undefined') {
		buttonElement = this;
	}

	CS.Log.info('Persisting configuration...');
	CS.Service.persistConfiguration(basketSpec, (function(p) {
		return function(result, redirectCallback) {
			var urlToParse = window.location.search;
			var resultParams = parseQueryString(urlToParse);
			if (result._success) {
				var redirectUrl = buildAfterFinishUrl(p, result);
				if (resultParams['CommercialConfigurationId'] !== undefined) {
					redirectUrl = window.location.href;
					if (resultParams['definitionId'] !== undefined) {
						var indexOfDefId = redirectUrl.indexOf('&', redirectUrl.indexOf('definitionId'));
						if (indexOfDefId === -1) {
							redirectUrl = redirectUrl.slice(0, redirectUrl.indexOf('definitionId'));
						} else {
							redirectUrl = redirectUrl.slice(0, redirectUrl.indexOf('definitionId')) + redirectUrl.slice(indexOfDefId + 1);
						}
						var configurationId = result['rootConfigIds'].replace(/&quot;/g, '').replace(/[\]\[]/g, '');
						redirectUrl += '&configId=' + configurationId;
						if (window.SPM !== undefined) {
							var msg = {
								configId: configurationId,
								defId: CS.params.definitionId
							};
							window.SPM.techMsgToTPE(msg, 'onSaveConfiguration');
						}
					} else {
						if (window.SPM !== undefined) {
							var msg = {
								configId: configurationId,
								defId: CS.params.definitionId,
								noChange: true
							};
							window.SPM.techMsgToTPE(msg, 'onSaveConfiguration');
						}
					}
				} else if (resultParams['editorPage'] !== undefined) {
					redirectUrl = window.location.href;
					var configurationId = result['rootConfigIds'].replace(/&quot;/g, '').replace(/[\]\[]/g, '');
					redirectUrl += '&configId=' + configurationId;
				}
				CS.Log.info('Configuration persisted');
				CS.UI.navigateTo(redirectUrl);
			} else {
				console.log('***markingInvalidOnSaveConfiguration');
				CS.markConfigurationInvalid(result._message);
				if (resultParams['CommercialConfigurationId'] !== undefined) {
					window.SPM.resizeRequest(jQuery('body').height());
				}
				updateFinishButtonUI(buttonElement, true);
			}
		}
	})(params));
}

function onLoadVoiceFNNDetails() {
	SPM.setValue('Voice FNN Details','IPChangeTypeVFNN_0',CS.getAttributeDisplayValue('ChangeType_0'));
	SPM.setValue('Voice FNN Details','IPOldconfigidVFNN_0',CS.getAttributeDisplayValue('Oldconfigid_0'));
	SPM.setValue('Voice FNN Details','BasketStageVFNN_0',CS.getAttributeDisplayValue('BasketStage_0'));	
}
function onLoadSiteDetails() {
	SPM.setValue('Site Details','SiteID_0',CS.getAttributeDisplayValue('Site_ID_0'));
	SPM.setValue('Site Details','BasketStageSite_0',CS.getAttributeDisplayValue('BasketStage_0'));
}
//function onLoadAppointment() {
	//SPM.setValue('Appointment','Offer_Name_0',CS.getAttributeDisplayValue('Offer_Name_0')); 
	//SPM.setValue('Appointment','ParentConfigId_0',CS.getAttributeDisplayValue('ConfigId_0')); 
//}
function onLoadReserveNumber() {
	//Commented for EDGE-48933 SPM.setValue('Reserve Numbers','ParentConfigId_0',CS.getAttributeDisplayValue('ConfigId_0'));
	SPM.setValue('Reserve Numbers','ParentConfigName_0',CS.getAttributeDisplayValue('ProductDefNameShadow_0'));	
	
}
function onLoadCRD() {
	SPM.setValue('Customer Requested Dates','CommercialPDName_0',CS.getAttributeDisplayValue('ProductDefNameShadow_0'));
	SPM.setValue('Customer Requested Dates','ChangeType_0',CS.getAttributeDisplayValue('ChangeType_0'));
}
var parseQueryString = function(url) {
	var urlParams = {};
	url.replace(
		new RegExp("([^?=&]+)(=([^&]*))?", "g"),
		function($0, $1, $2, $3) {
			urlParams[$1] = $3;
		}
	);
	return urlParams;
};