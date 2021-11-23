
/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	Author 			Date
1 			Laxmi Rahate 	16-Jul-19
2           Tihomir Baljak  16-Jul-19
3			Hitesh Gandhi	16-Jul-19
4           Tihomir Baljak	16-Jul-19 -commented line 5415 to prevent infinite loop //  updateNBNTechnologyTypeShadow();
5           Venkata Ramanan 17-Jul-19 - added function call to disableAddingMobileDevice() on afterRelatedProductAdd.
                                      - Incorporating Changes done by Aditya - added function calls to updatecontracttermattribute() on Aftersave,Onsoluitionloaded. Added new code on afterattributeupdated.
6           Tihomir Baljak  17-Jul-19 - reordering of function in afterSolutionLoaded hook
7			Shubhi VijayVergia 17-Jul-19 - Mac observations
8			Laxmi Rahate	18-Jul-10	Simplified the implementation of DisableBandwidthClip on
9           Tihomir Baljak	18-Jul-19   Display info message when adding IP handset
10          Tihomir Baljak	19-Jul-19   fix for configuration names , disabled changing names for Mobiliti due to issue with lookups
11          Rohit Tripathi	19-Jul-19   EDGE-99194 Mobility Number Reserve Page is Not opening
12   		Laxmi Rahate	22-Jul-19   EDGE-101214 - Widefeas code is geing made mandatory while adding bandwidth clip on
13          Zeeshan Moulvi  26-Jul-19   EDGE-93656 -  discount unchanged when MAC solution is raised
14          Sasidhar Devarapalli  27-Jul-19   EDGE-93425 -  plan discount unchanged when remaining term is not 0
                                                        -   update plan discount to 0 when remaining term is 0.
			Kalashree Borgaonkar 30-Jul-19 EDGE-93081 - Render enhanced number reservation page.
15          Rohit Tripathi	08-Aug-19   EDGE-103995	 ETC is not getting populated for Mobility Modify
16          Venkata Ramanan 02-Aug-19   EDGE-30181        Show Toast message of MDM Tenancy on addition of Mobility
17          Tihomir Baljak  12-08-2019  Hide custom buttons on config level depending on basket stage
18          Tihomir Baljak  13-08-2019  Code refactoring , OE
19          Manjunath Ediga 13-08-2019  Method to update TotalPlanBonus and RemainingTerm for Cancel changeType and PaymentType as Hardware repayment
20          Tihomir Baljak  21-08-2019  Moved some common OE code to OELogic plugin to be used by other plugins
21          Tihomir Baljak  29-08-2019  Hunt Group Unit price fix
22			Rohit Tripathi 	09-09-2019	Getting error when entered todays date in mobility disconnection date field
23          Tihomir Baljak  04-10-2019  fixed two bugs in blankOutCRDAttributesOnMACD
24 			Kalashree Borgaonkar 06-11-2019  Added button for 'Port-in'
25			Pawan Devaliya  14-11-2019 	Edge 92850 fix : Contract Term is still showing as 36 months
26			Laxmi Rahate   18-11-2019 	Code to resove PRM URL issue
27			Shubhi/Rohit	27-11-2019	 added for EDGE-123914 managed services PRM fix
28          Sowparnika/Harsh  26-11-2019  Replacing Mobility functionalities with CMP Mobility functionalities
29          Sandip Deshmane 9/12/2019   Updated code related to IP SIte ETC. EDGE-127631
30			Kiran Sattikar	20-04-2020	DPG-1513 Pricing Integration

31          Monali Mukherjee 26-05-2020 Added logic for DPG-1762 (CWP - New), DPG-1791 ( CWP - MAC)

31.         RaviTeja        02-Jun-2020	EDGE-146972-Get the Device details for Stock Check before validate and Save as well
********************/


var existingSiteIds = [];
var basketId;
var basketChangeType;
var basketStage;
var communitySiteId;
var gSolutionID;
var executeSave = false;
var allowSave = false;
var canExecuteValidation = true;
var ipnAdded = false;
var uceAdded = false;
var isMobileExists = false;
var huntGroupRecurringCharge = 0;
var productInError = false;
var callerNameCWP = 'CWP'; //DPG-1512
var basketNum = '';
var uniquehexDigitCode;//DPG-1512
var skipsave = false;


//Replacing Mobility functionalities with CMP Mobility functionalities as part of Mobile Retrofit
const COMPONENT_NAMES = {
    solution: 'Connected Workplace',
    ipSite: 'IP Site',
    //mobility: 'Mobility',
    mobileSubscription: 'CWP Mobile Subscription',
    device: 'Device',
    ipNetwork: 'IP Network',
    uc: 'Unified Communications',
    ipSiteEditableAttributeList: ['SiteNetworkZone', 'ServiceabilityLocation', 'Widefeas Code', 'WorkCost', 'WidefeasCategory'],
    ipSiteMacdReadonlyAttributeList: ['Technology Type'],
    //mobilityEditableAttributeList: ['MESSAGEBANK'],
    //mobilityReadonlyAttributeList: ['PlanQuantiy','MESSAGEBANK', 'MobilityPlan']
    mobileSubscriptionEditableAttributeList: ['SelectPlanType', 'Select Plan', 'InternationalDirectDial' ,'MessageBank'],
    mobileSubscriptionAddOnEditableAttributeList: ['Device Type', 'MobileHandsetManufacturer', 'MobileHandsetModel' ,'MobileHandsetColour', 'PaymentTypeLookup' , 'ContractTerm']
};

//This variable to used to allow deleting IP Sites without any error on User and Managed Router config deletion
var allowRPDel = 'No';

var configurationStatusData = {};
var updatedConfigurations = [];
function updateConfigurationStatus(ruleId, componentName, configurationGuid, status, message) {
    if (!configurationStatusData[configurationGuid])
        configurationStatusData[configurationGuid] = [];
    
    let newEntry = {
        ruleId: ruleId,
        componentName: componentName,
        configurationGuid: configurationGuid,
        status: status,
        message: message
    };
    
    let existing = configurationStatusData[configurationGuid].findIndex(obj => obj.ruleId ===ruleId);
    if (existing >= 0) {
        console.log('updateConfigurationStatus - update',ruleId, componentName, configurationGuid, status, message );
        configurationStatusData[configurationGuid][existing] = newEntry;
    }else {
        console.log('updateConfigurationStatus - new',ruleId, componentName, configurationGuid, status, message );
        configurationStatusData[configurationGuid].push(newEntry);
    }
    
    if (updatedConfigurations.findIndex(obj => obj ===configurationGuid)<0)
        updatedConfigurations.push(configurationGuid);
}

function removeConfigurationStatus(configurationGuid) {
    if (!configurationStatusData[configurationGuid])
        return;
    
    configurationStatusData[configurationGuid] = [];
}

async function processConfigurationStatus() {
    
    if (canExecuteValidation === false)
        return Promise.resolve(true);
    
    if (!updatedConfigurations ||updatedConfigurations.length===0 || !configurationStatusData || configurationStatusData.length===0)
        return Promise.resolve(true);
    
    canExecuteValidation = false;
    
    console.log('processConfigurationStatus');
    for (var i=0; i<updatedConfigurations.length; i++) {
        let id = updatedConfigurations[i];
        let csd = configurationStatusData[id];
        console.log('processConfigurationStatus ', csd);
        if (csd && csd.length > 0) {
            let validationMessage = '';
            let componentName = '';
            let configurationGuid = '';
            let isValid = true;
            csd.forEach((rule) => {
                console.log('processConfigurationStatus - rule', rule);
                componentName = rule.componentName;
                configurationGuid = rule.configurationGuid;
                if (rule.status === false) {
                isValid = false;
                if ( !validationMessage.includes(rule.message)) {
                validationMessage = validationMessage ? validationMessage + ',\n' : '';
                validationMessage = validationMessage + rule.message;
            }
                        }
                        });
            
            if (isValid) {
                console.log('processConfigurationStatus result: VALID ', componentName, configurationGuid);
                await CS.SM.updateConfigurationStatus(componentName, configurationGuid, true);
            } else {
                console.log('processConfigurationStatus result: ', id, validationMessage);
                await CS.SM.updateConfigurationStatus(componentName, configurationGuid, false, validationMessage).then(configuration => console.log(configuration));
            }
        }
    }
    
    updatedConfigurations = [];
    canExecuteValidation = true;
    return Promise.resolve(true);
}

if (CS.SM.createPlugin) {
    console.log('Load CWP plugin');
    CWPPlugin = CS.SM.createPlugin('Connected Workplace');
    
    window.addEventListener('message', handleIframeMessage);
    
    setInterval(processConfigurationStatus,1000);
    setInterval(processMessagesFromIFrame,500);
    setInterval(saveSolution,500);
    
    
    document.addEventListener('click', function(e) {
        e = e || window.event;
        var target = e.target || e.srcElement;
        var text = target.textContent || target.innerText;
        // console.log("Clicked on " ,e ,'target=',target, 'text=' , text);
		
		//EDGE-135267 Aakil
			if ( text && (text.toLowerCase() ==='overview' || text.toLowerCase().includes('stage'))) {
			Utils.hideSubmitSolutionFromOverviewTab();
			}
        
        if (text) {
            Utils.updateOEConsoleButtonVisibility();
        }
        
        if (text && text.toLowerCase() === 'ip site'){
            Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
            Utils.updateCustomButtonVisibilityForBasketStage();
        }
        console.log('event listener added for #'+text);
        if (text && text.toLowerCase().includes('mobile subscription')){
            Utils.updateComponentLevelButtonVisibility('Add Mobile Subscription', true, true);
    		pricingUtils.resetCustomAttributeVisibility();
            Utils.updateCustomButtonVisibilityForBasketStage();
	        Utils.updateCustomAttributeLinkText('Price Schedule','View All');
			Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
        }
        
        if (text && text.toLowerCase().includes('stage')){
            
            Utils.updateCustomButtonVisibilityForBasketStage();
            
            Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
            Utils.updateComponentLevelButtonVisibility('Add Mobile Subscription', true, true);
        }
        
    }, false);
}

async function  saveSolution() {
    if (executeSave) {
        
        executeSave = false;
        var solution;
        await CS.SM.getActiveSolution().then((product) => {
            solution = product;
        });
            
            let isValid = true;
            if (solution.components && solution.components.length > 0) {
            solution.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((parentConfig) => {
            if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
            let inContractDeviceCount = CWPPlugin.getInContractMobileDevices(parentConfig);
            if (inContractDeviceCount > 1) {
            CS.SM.displayMessage('There cannot be more than 1 device of payment type Contract for this plan.', 'error');
            show = true;
            isValid = false;
        }
        }
        });
        }
		pricingUtils.setIsDiscountCheckNeeded(comp.schema,comp.name);

        }
        });
            if (skipsave === true){
					return Promise.resolve(false);    
				}
        }
            UpdateRemainingTermOnParentCWP();
            
            if (!isValid) {
            return Promise.resolve(false);
        }
            /*if (productInError) {
                        show = false;//???
                        CS.SM.displayMessage('You cannot save Invalid PC.', 'error');
                        return Promise.resolve(false);
                    }*/
            if (await beforeSaveValidation() === false)
            return Promise.resolve(false);
            
            canExecuteValidation = false;
            
            await updateOeStatus();
            
            if (basketChangeType === 'Change Solution') {
            await updateMobilityChangeTypeAndAddToMacBasket();//Mobility modify functionality
            await updateIpNetworkAndUCChangeType();
        }
            
            await processConfigurationStatus();
            updateEDMListToDecomposeattributeCWP(solution); 
            
            allowSave = true;
            
            
            await CS.SM.saveSolution();
        }
            /*DPG-1512 Start*/
            Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');
           /*DPG-1512 End*/

            return Promise.resolve(true);
        }
            
            function processMessagesFromIFrame(){
            if (!communitySiteId)
            return;
            
            var data = sessionStorage.getItem("payload");
            // sessionStorage.removeItem("payload");
            var close = sessionStorage.getItem("close");
            //  sessionStorage.removeItem("close");
            var message = {};
            if (data){
            console.log('processMessagesFromIFrame:', data);
            message['data'] = JSON.parse(data);
            handleIframeMessage(message);
        messgae = message['data'];
        message = message['data'];
        if (message.command  && message.command  === 'TenancyIds') { // added for EDGE-123914
	
	if (message.caller && message.caller  !== 'Managed Services') {
                return;
            }
	// // added for EDGE-123914
	if (message) {
		//console.log('Inside EMSPlugin_handleIframeMessage Data is --->'+message.data['data']);
		console.log('Inside EMSPlugin_handleIframeMessage Data is --->'+message['data']);
		updateSelectedTenancyList(message['data']);
	} // EDGE-123914 end
	
		}
        }
            if (close){
            console.log('processMessagesFromIFrame:', data);
            message['data'] = close;
            handleIframeMessage(message);
        }
        }
            
            async function handleIframeMessagePricing(e)
            {
            	console.log('Start handleIframeMessagePricing');
            	console.log('data is --->'+e.data['data']);
				console.log('command is --->'+e.data['command']);
				console.log('caller is --->'+e.data['caller']);
            	
            	var message = {};
				message = e['data'];
				message = message['data'];

                if (e.data['command'] && e.data['command'] === 'correlationId') {
                    console.log('Inside CorrelationId is --->'+e.data['data']);
                 if (e.data['caller'] && e.data['caller']  !== 'CWP') {
                        return;
                    }
                    if (e.data['data']) {
                        pricingUtils.setCorrelationId(e.data['data'],COMPONENT_NAMES.enterpriseMobility);
                        }
                    }
                    /*
                    if (e.data['command'] && e.data['command'] === 'timeout') {
                        console.log('Inside timeout --->'+e.data['data']);
                        if (e.data['caller'] && e.data['caller']  !== 'CWP') {
                            return;
                    }
                    if (e.data['command'] && e.data['command'] === 'ResponseReceived') {	
                        if (e.data['caller'] && e.data['caller']  !== 'CWP') {
                            return;
                    }
                    if (e.data['data']) {
            			line('Line 330 ');
                        pricingUtils.customLockSolutionConsole('unlock');
                        pricingUtils.setCorrelationId(e.data['data'], COMPONENT_NAMES.enterpriseMobility);
                        pricingUtils.setDiscountStatus('None', COMPONENT_NAMES.enterpriseMobility);
                    }
*/
                        console.log('postMessageToshowPromo Condition begin '+e.data['command'] +'e.dataofdata =  '+e.data['data'] +' configId '+configId+ 'gSolutionID'+gSolutionID);

            	 if(e.data['command'] === 'pageLoad'+callerNameCWP &&  e.data['data']===gSolutionID){
            		console.log('Inside Condition to call postMessageToPricing');
						await pricingUtils.postMessageToPricing(callerNameCWP,gSolutionID,IsDiscountCheckNeeded);
        }else if (e.data['command'] === 'showPromo'){// && e.data['data']===configId){
            			console.log('postMessageToshowPromo Condition true');
            			configId = e.data['data'];
						await pricingUtils.postMessageToshowPromo(e.data['caller'],configId,"viewDiscounts");
				 } else if (e.data['command'] === 'StockCheck' && e.data['data'] === gSolutionID && e.data['caller']==='CWP'){//EDGE-146972
                        console.log('StockCheck Condition true');        
                        await stockcheckUtils.postMessageToStockCheck(e.data['caller'],gSolutionID)
					}else {
						await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller']); //added by shubhi for EDGE-121376
					}
                }
                     //---------DPG-1512 END-------------------//
       		 //  }
        //	}
            function handleIframeMessage(e) {
            //---------DPG-1512 Start-------------------//
                 console.log('handleIframeMessage');      
            if(e.data['data'] && e.data['caller'] && e.data['caller'].includes('CWP'))
            	handleIframeMessagePricing(e);
            
            if (!e.data ||  !e.data['command']  ||  e.data['command'] !== 'ADDRESS' ||  (e.data['caller'] &&  e.data['caller'] === COMPONENT_NAMES.solution)) {
            sessionStorage.removeItem("close");
            sessionStorage.removeItem("payload");
        }
            
            //   }
            
            /* if (e.data === 'close') {
                    console.log('Closing modal window');
                    try {
                        var d = document.getElementsByClassName('mat-dialog-container');
                        if (d) {
                            for (var i=0; i< d.length; i++)
                            {
                                d[i].style.display = "none";
                            }
                        }
                        var el = document.getElementsByClassName('cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing');
                        if (el) {
                            for (var i=0; i< el.length; i++) {
                                el[i].style.display = "none";
                            }
                        }
            
                    } catch (err) {
                        console.log(err);
                    }
                }*/
            
            
            if (e.data && e.data['command'] != undefined && e.data['caller']) {
            console.log('handleIframeTask:', e);
            console.log(e.data);
            
            if (e.data['command'] == 'ADDRESS') {
            
            if (e.data['caller'] && e.data['caller'] !== COMPONENT_NAMES.solution) {
            return;
        }
            
            if (e.data['data'] && e.data['data'].length> 0 && e.data['data'][0] && e.data['data'][0]['ipSiteconfigId'] != undefined && e.data['data'][0]['ipSiteconfigId'].length > 0) {
            updateIpSite(e.data['data']);
        } else {
            if (e.data['data'])
            addIpSites(e.data['data']);
        }
        } else if (e.data['command'] == 'RESERVE_FNN') {
            AddRecordsToNcJsonSchemaForNumberManagement(e.data['data'], e.data['configId']);
        } else if (e.data['command'] == 'UNRESERVE_FNN') {
            RemoveRecordsFromNcJsonSchemaForNumberManagement(e.data['data'], e.data['configId']);
        } else if (e.data['command'] == 'MACSQRESPONSE') {
            console.log('MACSQRESPONSE', e.data['data']);
            if (e.data['data'] && e.data['data'].length> 0 && e.data['data'][0] && e.data['data'][0]['configGUID'] != undefined && e.data['data'][0]['configGUID'].length > 0) {
            updateMACIpSite(e.data['data']);
        			}
        		}
        	}
        }
          
            
            
            /**************************** Start of Hooks ******************************************/
            
            
      	CWPPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {
            
            window.currentSolutionName = loadedSolution.name;
            
            configurationStatusData = {};
            updatedConfigurations = [];
            
            await CS.SM.getCurrentCart().then(cart => {
            console.log('Basket: ', cart);
            basketId = cart.id;
            Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
			Utils.updateCustomAttributeLinkText('Price Schedule','View All');
            });
            
            let inputMap = {};
            inputMap['GetBasket'] = basketId;
            await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
            console.log('GetBasket finished with response: ', result);
            var basket = JSON.parse(result["GetBasket"]);
            console.log('GetBasket: ', basket);
            basketChangeType = basket.csordtelcoa__Change_Type__c;
            basketStage= basket.csordtelcoa__Basket_Stage__c;
            accountId = basket.csbb__Account__c;
            basketNum = basket.Name;
            console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ',accountId)
            window.oeSetBasketData(basketId, basketStage, accountId);
            //Added CWP New - DPG1762 Monali
            if(accountId!=null){
            		console.log('COMPONENT_NAMES.solution-->'+COMPONENT_NAMES.solution);
                    CommonUtills.setAccountID(COMPONENT_NAMES.solution,accountId);
                 }
        });
            
            let map = {};
            map['GetSiteId'] = '';
            CS.SM.WebService.performRemoteAction('SolutionActionHelper', map).then(result => {
            console.log('GetSiteId finished with response: ', result);
            communitySiteId = result["GetSiteId"]
            console.log('communitySiteId: ', communitySiteId);
        });
            
            await Utils.loadSMOptions();
            
            await checkConfigurationSubscriptions();
            
            
            CWPPlugin.updateRemainingTermAfterSolutionLoad();
            CWPPlugin.updateDeviceEnrollmentAfterSolutionLoad() ;
            CWPPlugin.updateDevicestatusAfterSolutionLoad(loadedSolution);
            checkMACDBusinessRules();
            addDefaultOEConfigs();
            updateOeStatus();
            updateOeTabsVisibility();
            updateConfigurationsName();
            
            
            //Change Start by Aditya - Calling function updatecontracttermattribute after solution loaded
            // CS.SM.getActiveSolution().then((product) => {
            updatecontracttermattribute(loadedSolution);
            
            //          });
            //Change Ends by Aditya
            
            getConfiguredSiteIds();
            populateRemainingTerm();
            //  updateReservedNumbers();
            checkAllBusinessRules();
            //validateOE();
            // commented
            //	initHideOrShowTheAttibute();
            await updateAccesType();
            await updateBandwidhtClipOnTechnologyData();
            
            updateBandwidthOnIPSiteConfig();
            
            //Added by Mahaboob on 18/07/2019 to fix EDGE-100145
            if (basketChangeType === 'Change Solution' && basketStage === 'Contract Accepted') {
            blankOutCRDAttributesOnMACD();
        }
            //End by Mahaboob on 18/07/2019
            
            
            Utils.updateComponentLevelButtonVisibility('Add Mobile Subscription', true, true);
            Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI');
            Utils.updateCustomButtonVisibilityForBasketStage();
          	pricingUtils.checkDiscountValidation(loadedSolution, 'IsDiscountCheckNeeded', COMPONENT_NAMES.enterpriseMobility);

            let inputMapHg = {};
            inputMapHg['Hunt Group'] = 'cspmb__Recurring_Charge__c';
            CS.SM.WebService.performRemoteAction('SolutionGetBaskeData', inputMapHg).then( // class name needs to change or moved
            function (response) {
            if (response && response["Hunt Group"] != undefined) {
            huntGroupRecurringCharge = response["Hunt Group"].cspmb__Recurring_Charge__c;
            
        }
        });
            //Start: Added for making BillingAccount ReadOnly in MACD Journey(Added by Monali) DPG-1791 ( CWP - MAC)
        if (basketChangeType === 'Change Solution') {
            CommonUtills.setSubBillingAccountNumberOnCLI(COMPONENT_NAMES.solution,'BillingAccountLookup');		
            let componentMap = new Map();
            let componentMapattr = {};
            //Edge-142082 shubhi start
            if(loadedSolution ){
                loadedSolution.schema.configurations.forEach((config) => {
                    if(config.attributes){
                        componentMapattr['BillingAccountLookup'] = [];
                        componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': true });
                        componentMap.set(config.guid, componentMapattr);
                    }
                });
                CommonUtills.attrVisiblityControl(COMPONENT_NAMES.solution, componentMap);
            }
            }
            //End :changes end by Monali
            return Promise.resolve(true);
        }
            
            CWPPlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
            console.log('afterOETabLoaded: ', configurationGuid, OETabName);
            var element = existingSiteIds.filter(e => {return e.guid === configurationGuid});
            var siteId = '';
            if (element && element.length>0) {
            siteId = element[0].siteId;
        }
            var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
            window.afterOETabLoaded(configurationGuid, OETabName,schemaName ,siteId);
            return Promise.resolve(true);
        }
            
            
            CWPPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {
            console.log('Parent Config Add - After', componentName, configuration);
            if (componentName === COMPONENT_NAMES.ipSite) {
            getConfiguredSiteIds();
            autoAddUserConfigurations(configuration);
            autoAddManagedRouterConfigs(configuration);
            await setChangeTypeafterConfigurationAdd(componentName,configuration);
            await updateConfigurationsName();
            updateWidefeasCodeAndCategoryVisibility();
            updateTelstraFibreCompatibility();
            updateNBNCompatibility();
            //callign this method to calculate the Bandwidth on IP SIte Add
            updateBandwidthOnIPSiteConfig(configuration.guid);
            //await addIPNAndUCEToMACSolution();
        }
            
            if (componentName.includes(COMPONENT_NAMES.mobileSubscription)) {
            pricingUtils.resetDiscountAttributes(configuration.guid, COMPONENT_NAMES.mobileSubscription);
            await setChangeTypeafterConfigurationAdd(componentName,configuration);
            await Utils.updateCustomAttributeLinkText('Price Schedule','View All');
            await Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');
            await updateConfigurationsName();
            checkForTwoIPSites(componentName, configuration);
            //Added by Venkata Ramanan G for EDGE-30181
            CWPPlugin.showMDMtenancynotification();
            }
            
            await addDefaultOEConfigs();
            
            return Promise.resolve(true);
        };
            
            
            CWPPlugin.afterRelatedProductAdd = async function _solutionafterRelatedProductAdd(componentName, configuration, relatedProduct) {
            console.log('Related Product Add - After', componentName, configuration, relatedProduct);
            if (relatedProduct.name === 'User' && relatedProduct.type === 'Related Component') {
            await updateAccesType();
            updateExistingTypesOnUserConfig(relatedProduct);
        }
            
            if (relatedProduct.name === 'Bandwidth Clip On' && relatedProduct.type === 'Related Component') {
            updateFixedSeatUserQtyOnBandwidthConfig(relatedProduct);
            await updateBandwidhtClipOnTechnologyData();
            disableAddingBandwidthClipOn(componentName, configuration, relatedProduct);
            
        }
            //Change Starts by Venkata Ramanan G - Calling function disableaddingmultipleMobileDevice to restrict users from adding second mobile device to a Mobile Plan. Automatically deletes the 2nd MD attached to a Mobile Plan
            if (componentName === COMPONENT_NAMES.mobileSubscription && relatedProduct.name === 'Device' && relatedProduct.type === 'Related Component') {
            disableAddingMobileDevice(componentName, configuration, relatedProduct);
        }
            //Change Ends by Venkata Ramanan G
            
            if (relatedProduct.name === 'Hunt Group' && relatedProduct.type === 'Related Component') {
            
            let updateConfigMap = {};
            updateConfigMap[relatedProduct.guid] = [{
            name: 'HuntGroup',
            value: {
                value: huntGroupRecurringCharge,
                displayValue: huntGroupRecurringCharge
            }
        }];
                                             CS.SM.updateConfigurationAttribute('Hunt Group', updateConfigMap, true);
        /*
                    // set default unit price of Hunt Group
                    let inputMap = {};
                    inputMap['Hunt Group'] = 'cspmb__Recurring_Charge__c';
                    console.log('inputMap: ' + inputMap['Hunt Group']);
                    CS.SM.WebService.performRemoteAction('SolutionGetBaskeData', inputMap).then( // class name needs to change or moved
                        function (response) {
                            console.log('Response', response);
                            if (response && response["Hunt Group"] != undefined) {
                                let updateConfigMap = {};
            
                                updateConfigMap[relatedProduct.guid] = [{
                                    name: 'HuntGroup',
                                    value: {
                                        value: huntGroupRecurringCharge,
                                        displayValue: huntGroupRecurringCharge
                                    }
                                }];
                                CS.SM.updateConfigurationAttribute('Hunt Group', updateConfigMap, true);
                            }
                        });*/
    }
    
    if (relatedProduct.name === 'IAD Device' && relatedProduct.type === 'Related Component') {
        disableAddingIADDevice(componentName, configuration, relatedProduct);
        setTimeout(makeIADDeviceMandatory,2000);
    }
    
    if (relatedProduct.name === 'User' && relatedProduct.type === 'Related Component') {
        IADPortsFaxQuantityValidation();
    }
    
    if (relatedProduct.name === 'Managed Router' && relatedProduct.type === 'Related Component') {
        //disableAddingManagedDevice(componentName, configuration, relatedProduct);
    }
    
    if (basketChangeType === 'Change Solution')
    {
        CheckMacdBusinessRulesForRPAdd(componentName, configuration, relatedProduct);
    }
    
    
    // Changes by Anand Shekhar - Extracted from CMP js file as part of Mobile retrofit - Starts			
    let inContractDeviceCount = 0;
    if (relatedProduct.name === COMPONENT_NAMES.device && relatedProduct.type === 'Related Component') {
        
        var selectPlanFromParent = '';
        var selectedPlanValue = '';
        var ChangeTypeValue = '';
        configuration.attributes.forEach((planAttribute) => {
            if (planAttribute.name === 'Select Plan') {
            selectPlanFromParent = planAttribute.value;
            selectedPlanValue = planAttribute.displayValue;
        }
                                         if (planAttribute.name === 'ChangeType') {
            ChangeTypeValue = planAttribute.value;	
        }
    });
    if(selectedPlanValue!= '' ){
        relatedProduct.configuration.attributes.forEach((priceItemAttribute) => {
            if (priceItemAttribute.name === 'ParentPriceItem') {
            let updateConfigMap = {};
                                                        updateConfigMap[relatedProduct.guid] = [{
                                                        name: 'ParentPriceItem',
                                                        value: {
                                                        value: selectPlanFromParent,
                                                        displayValue: selectPlanFromParent
                                                        }
                                                        }
                                                        ];
                                                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.device, updateConfigMap, true);
        CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription, configuration.guid, true);
        /*--DPG-1512--*/
        //CS.SM.updateConfigurationStatus(componentName, configuration.guid, false, 'Please Click on Generate "Net Price" to update pricing of items in the basket');
		//skipsave = true;
   		console.log('_solutionafterRelatedProductAdd GNP Error');
    	/*--DPG-1512--*/
    }
});
inContractDeviceCount = CWPPlugin.getInContractMobileDevices(configuration);

if(inContractDeviceCount > 0){
    CS.SM.updateConfigurationStatus(COMPONENT_NAMES.device, relatedProduct.guid, false, 'There cannot be more than 1 In-Contract device for this plan.');
    //CS.SM.displayMessage('There cannot be more than 1 In-Contract device for this plan.','info');
}
}		

if(configuration && configuration.relatedProductList.length>0){
    configuration.relatedProductList.forEach((ReletedplanList) => {
        if(ReletedplanList.guid===relatedProduct.guid){
        configuration.attributes.forEach((parentDeviceAttribute) => {
        if(parentDeviceAttribute.name==='PlanTypeString'){
        relatedProduct.configuration.attributes.forEach((DevAttribute) => {
        if(DevAttribute.name==='PlanType'){
        let updateConfigMap = {};
                                             updateConfigMap[relatedProduct.guid] = [{
                                             name: 'PlanType',
                                             value: {
                                             value: parentDeviceAttribute.displayValue,
                                             displayValue: parentDeviceAttribute.displayValue
                                             }
                                             }];
                                             
                                             CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
    
}
});
}
});	
}
});		
}
}
// Changes by Anand Shekhar - Extracted from CMP js file as part of Mobile retrofit - Ends

return Promise.resolve(true);
};


CWPPlugin.beforeConfigurationDelete = function (componentName, configuration) {
    console.log('Parent Config Delete - Before', componentName, configuration);
    if (componentName === COMPONENT_NAMES.ipSite) {
        allowRPDel = 'Yes';
    }
    
    return Promise.resolve(true);
}


CWPPlugin.afterConfigurationDelete = function (componentName, configuration) {
    console.log('Parent Config Delete - After', componentName, configuration);
    if (componentName === COMPONENT_NAMES.ipSite) {
        unreserveNumbers(configuration);
        detachAccountFromSite(configuration);
        getConfiguredSiteIds();
    }
    
    removeConfigurationStatus(configuration.guid);
    updateConfigurationsName();
    return Promise.resolve(true);
}

CWPPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {
    console.log('Attribute Update - After', componentName, guid, attribute, oldValue, newValue);
    
    if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'TypeUser') {
        console.log('***109');
        updateUserAndIPSiteConfigurations(guid);
        if (attribute.name === 'TypeUser') {
            console.log('***112');
            makeIADDeviceMandatory();
            console.log('***114');
            fetchUserUnitPrice(guid);
        }
        await updateAccesType();
    }
    
    if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'ZonefromParent') {
        fetchUserUnitPrice(guid);
    }
    //Hitesh Gandhi
    if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'Technology Type') {
        updateNBNTechnologyTypeShadow();
    }// Change End
    
    if (componentName === COMPONENT_NAMES.ipSite){
        console.log('***116 - IADPortsFaxQuantityValidation');
        IADPortsFaxQuantityValidation();
    }
    
    if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'Quantity') {
        console.log('quantity changed===>>');
        makeWFCodeMandatoryOrOptional(guid);
        updateFixedSeatUserQtyOnBWQAndIPSiteConfig2(guid, newValue);
        showQuantityErrorMessages(guid);
        updateWidefeasCodeAndCategoryVisibility (null);
        updateNBNCompatibility();
        await updateAccesType();
        console.log('***120');
    }
    
    
    if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'Tier'){
        console.log('*** - updateBWTierOnIPSiteConfig');
        updateBWTierOnIPSiteConfig(guid, newValue);
    }
    
    // Changes by Anand Shekhar - Extracted from CMP js file as part of Mobile retrofit - Starts
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'DisconnectionDate') {
        console.log('Inside ETC calculation hook');
        CWPPlugin.calculateTotalETCValue(guid);
    }//EDGE-81135 : Cancellation of CMP
    
    
    if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType' && componentName === COMPONENT_NAMES.mobileSubscription)
    {
        CWPPlugin.UpdateAttributeVisibilityForMacdMobileSubscription(guid, newValue, await CWPPlugin.getSelectedPlanForMobileSubscription(guid));
        CWPPlugin.getattributesForMobileSubscription(guid,'SelectPlanType');
        CWPPlugin.updateAttributeVisibility(componentName,'Select Plan', guid, true,true);
        
        
    }
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && (newValue === 'Modify')) {
        checkDeviceSelectionLookupForModify(guid);
        console.log('Inside Modify Update');
    }
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ChangeTypeDevice'){
        console.log('Inside Modify Update for Cancel Flag');
        IsDeviceChange=true;
        checkCancelFlagAndETCForNonBYOPlans(guid);	
        updateRemainingTermAfterSave(guid);	
    }
    
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ChangeTypeDevice' && oldValue != newValue &&  newValue !== 'Payout') {
        console.log('Inside Modify Update for Cancel Flag');
        checkCancelFlagAndETCForNonBYOPlans(guid);
        //checkRemainingTermForBYOPlans(guid);
        
    }
    
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && (newValue === 'Modify' || newValue === 'Cancel')) {
        console.log('Inside Modify Update');
        IsMACBasket = true;
        CWPPlugin.updateRemainingTermAfterSolutionLoad();
        updateCancelDeviceTypeAfterSolutionLoad(guid);
        //updateRemainingTermAfterSave(guid);
        //----DPG-1512 Start-------//
        if(newValue === 'Modify'){
            var updateConfigMap = [];
			updateConfigMap[guid] = [];
			updateConfigMap[guid].push({
				name: "IsDiscountCheckNeeded",
				value: {
					value: true
				}
			});
			CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false);
			CS.SM.updateConfigurationStatus(componentName, guid, false, 'Please Click on Generate "Net Price" to update pricing of items in the basket');
			console.log('_solutionAfterAttributeUpdated GNP Error ');
        	}else{
              var updateConfigMap = [];
			  updateConfigMap[guid] = [];
			  updateConfigMap[guid].push({
				name: "IsDiscountCheckNeeded",
				value: {
					value: false
					}
				});
                CWPPlugin.updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'viewDiscounts', guid,true, false, false);
				CWPPlugin.updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, 'Price Schedule', guid,true, false, false);
                CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false);
				CS.SM.updateConfigurationStatus(componentName, guid, true);
            }
               //----DPG-1512 End-------//
          }
    
    if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'Select Plan' && oldValue != newValue && newValue !== '' && newValue !== null) {
        
        CS.SM.getActiveSolution().then((product) => {
            if (product.schema && product.schema.configurations && product.schema.configurations.length > 0) {
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((subsConfig) => {
            if (subsConfig.guid===guid){
            let updateConfigMap = {};
                                       /*if (attribute.displayValue === 'Basic' && isCommittedDataOffer == true){
													console.log('Inside If loop');

														updateConfigMap[guid] = [{
																						name: 'MDMEntitled',
																						value: {
																							value: false,
																							displayValue: false
																						}
																					}];
												}*/
                                       if (attribute.displayValue !== 'Basic') {
            console.log('Inside else loop');
            
            updateConfigMap[guid] = [{
                name: 'MDMEntitled',
                value: {
                    value: true,
                    displayValue: true
                }
            }];
            
            
            
        }
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true).then(component => console.log('updateFieldsVisibilityAfterSolutionLoad Attribute Update', component));
    }
    
});
}
}
});
}
});

//checkRemainingTermForBYOPlans(guid);
console.log('Inside Modify Update');
}
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'SelectPlanName' && oldValue != newValue && newValue !== '' && newValue !== null) {
    CS.SM.getActiveSolution().then((product) => {
        if (product.schema && product.schema.configurations && product.schema.configurations.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) { 
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((subsConfig) => {
        //let configNameString=subsConfig.configurationName;
        if(subsConfig.guid===guid){
        var changeTypeAtrtribute = subsConfig.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
    var SelectPlanNameAttribute = subsConfig.attributes.filter(obj => {
        return obj.name === 'SelectPlanName'
    });
}	
});
}	
}	
});
}
});

}		

// Changes by Anand Shekhar - Extracted from CMP js file as part of Mobile retrofit - Ends

//Change Started by Aditya
//Hiding ContractTermLookup when PaymentTypeLookup is Purchase
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'PaymentTypeLookup') {
    console.log('attribute.value: ' + newValue);
    let updateConfigMap = {};
    if (attribute.displayValue === 'Purchase') {
        updateConfigMap[guid] = [{
            name: 'ContractTermLookup',
            value: {
                showInUi: false,
                required: false,
                value: 'NA',
                displayValue: 'NA'
            }
        }];
    } else {
        updateConfigMap[guid] = [{
            name: 'ContractTermLookup',
            value: {
                showInUi: true,
                required: true,
                value: ''
            }
        }];
    }
    
    CS.SM.updateConfigurationAttribute('Device', updateConfigMap, true);
}
//Changes ended by Aditya

if (componentName === COMPONENT_NAMES.solution && attribute.name === 'OfferType') {
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        if (product.schema && product.schema.configurations && product.schema.configurations.length > 0) {
        var offerIdValue = null;
        product.schema.configurations.forEach((config) => {
        if (config.guid == guid) {
        offerIdValue = null;
        let updateConfigMap = {};
                                   if (config.guid == guid) {
        config.attributes.forEach((configAttr) => {
            if (configAttr.name === 'OfferId') {
            offerIdValue = configAttr.value;
        }												
                                  });
        
        if(offerIdValue!= '' && (offerIdValue === 'DMCAT_Offer_000646' || offerIdValue === 'DMCAT_Offer_000303')){
            updateConfigMap[config.guid] = [{
                name: 'ProdSpecId',
                value: {
                    value: 'DMCAT_ProductSpecification_000420',
                    displayValue: 'DMCAT_ProductSpecification_000420'
                }														
            }];
        }
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.solution, updateConfigMap, true);
        
        // create Allowances NC Schema ???
        product.orderEnrichments.forEach((oeSchema) => {
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
            CS.SM.deleteOrderEnrichments(product.name, config.guid, oeGUIDs);                        				
        }
            // add allowances NC records
            //addAllowancesOEConfigs(product.name, config.guid, oeSchema.id, newValue, '');
        }								                                		
        });
        }
            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.solution, updateConfigMap, true);
        }});
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            // make configuration invalid
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((subsConfig) => {
            let updateConfigMap = {};
            if(offerIdValue!= '' && (offerIdValue === 'DMCAT_Offer_000646' || offerIdValue === 'DMCAT_Offer_000303')){
            updateConfigMap[subsConfig.guid] = [{
            name: 'ProdSpecId',
            value: {
                value: 'DMCAT_ProductSpecification_000420',
                displayValue: 'DMCAT_ProductSpecification_000420'
            }														
        }];
                         CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
    }
    
});
}
}
});
}
}
});
}

/*---------- DPG-1512 -------------*/
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'IsDiscountCheckNeeded' && newValue === false) {
    console.log('Inside attribute IsDiscountCheckNeeded');
    CS.SM.updateConfigurationStatus(componentName, guid, true);
}
if (componentName === COMPONENT_NAMES.mobileSubscription)
{
    Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
	Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
}
/*---------- DPG-1512 -------------*/

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'SelectPlanType') {
    let updateConfigMapsubs = {};
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        
        comp.schema.configurations.forEach((subsConfig) => {
        if(subsConfig.guid===guid){
        console.log('***ENTERED INSIDE***');
        Utils.emptyValueOfAttribute(subsConfig.guid, COMPONENT_NAMES.mobileSubscription, 'InternationalDirectDial', true);
        Utils.emptyValueOfAttribute(subsConfig.guid, COMPONENT_NAMES.mobileSubscription, 'MessageBank', true);
        Utils.emptyValueOfAttribute(subsConfig.guid, COMPONENT_NAMES.mobileSubscription, 'IDD Charge', true);
        Utils.emptyValueOfAttribute(subsConfig.guid, COMPONENT_NAMES.mobileSubscription, 'Select Plan', true);
        Utils.emptyValueOfAttribute(subsConfig.guid, COMPONENT_NAMES.mobileSubscription, 'MessageBank RC', true);
        if(attribute.displayValue!=='Data'){
        console.log('***ENTERED INSIDE***'+attribute.displayValue);
        updateConfigMapsubs[subsConfig.guid] = [{
        name: 'InternationalDirectDial',
        value: {
        showInUi: true,
        required: false
    }
                                   },
                                   {
                                   name: 'MessageBank',
                                   value: {
                                   showInUi: true,
                                   required: true
                                   }
                                   },{
                                   name: 'MessageBank RC',
                                   value: {
                                   showInUi: true,
                                   required: false
                                   }
                                   },{
                                   name: 'IDD Charge',
                                   value: {
                                   showInUi: true,
                                   required: false
                                   }
                                   }];
                                   
                                   
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMapsubs, true);
    
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

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'Select Plan') {
    let updateConfigMap = {};
    let updateConfigMapsubs = {};
    //show = false;
    console.log('new plan value is  ' + newValue);
    var selectedPlan = newValue;
    var changeTypeAtrtribute = '';
    var selectPlanDisplayValue = '';
    var isRelatedDeviceAdded = false;
    var relatedConfigurationID = '';
    
    let inputMap = {};
    inputMap['priceItemId'] = newValue;
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        product.schema.configurations.forEach((config) => {
        
        if (product.components && product.components.length > 0) {
        
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        
        comp.schema.configurations.forEach((subsConfig) => {
        var PlanTypeSelected = '';
        //Changes made by Aditya
        if(subsConfig.guid == guid){
        var changeTypeAtrtribute = subsConfig.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
    subsConfig.attributes.forEach((attr) => {
        
        if (attr.name === 'Select Plan' && attr.value !== '') {
        selectPlanDisplayValue =attr.displayValue ;
        console.log('Selected Plan --> '+selectPlanDisplayValue);
        if(attr.displayValue !== 'Local' && !show && changeTypeAtrtribute !== 'Modify' && changeTypeAtrtribute !== 'Cancel' &&  attr.displayValue !== 'Basic'){
        //Added by Venkata for EDGE- 30181
        CWPPlugin.showMDMtenancynotification();
    }
                                  
                                  CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMapsubs, true);
    let updateConfigMap1 = {};
    //console.log('inputMap2>>>>>'+inputMap2.size)
    if(PlanTypeSelected !=='Data'){
        CS.SM.WebService.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(
            function (response) {
                if (response && response['addOnMsgBank'] != undefined) {
                    console.log('response[addOnMsgBank] ' + response['addOnMsgBank']);
                    addOnMsgBankCount = response['addOnMsgBank'].length;
                    
                    console.log('addOn MsgBank ' + response['addOnMsgBank'][0].Id);
                    updateConfigMap1[subsConfig.guid] = [
                        {
                            name: 'MessageBank',
                            value: {
                                value: response['addOnMsgBank'][0].Id,
                                displayValue: response['addOnMsgBank'][0].cspmb__Add_On_Price_Item__r.Message_Bank__c
                            }
                        },
                        {
                            name: 'MessageBank RC',
                            value: {
                                value: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c,
                                displayValue: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c
                            }
                        }];
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap1, true);
                }
                
            });
        
    }
    
    //Change Ends by Aditya
}
if (attr.name === 'ChangeType' && attr.value !== '' ){
    changeTypeAtrtribute = attr.value;
    console.log('Change Type Value is ----->'+changeTypeAtrtribute);
    
}


}); // Added by Tihomir Baljak
}

// update ParentPriceItem of related product
if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
    subsConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === COMPONENT_NAMES.device && relatedConfig.type === 'Related Component') {
        if(subsConfig.guid == guid){
        isRelatedDeviceAdded = true;
    }
                                          relatedConfig.configurationId = relatedConfigurationID ;
                                          console.log('relatedConfigurationID ---->'+relatedConfigurationID);
    relatedConfig.configuration.attributes.forEach((priceItemAttribute) => {
        if (priceItemAttribute.name === 'ParentPriceItem') {
        updateConfigMap[relatedConfig.guid] = [{
        name: 'ParentPriceItem',
        value: {
        value: newValue,
        displayValue: newValue
    }
                                                   }];
                                                   }
                                                   });
    // make device invalid
    //CS.SM.updateConfigurationStatus(relatedConfig.name, guid, false, 'Please reselect relevant device as the plan discount may have changed.');
}
});
}
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.device, updateConfigMap, true);
console.log('before get IDD ' + selectedPlan + selectPlanDisplayValue);
if (subsConfig.guid == guid && selectedPlan != '') {
    if (changeTypeAtrtribute !=='Modify' && changeTypeAtrtribute !=='Cancel' && changeTypeAtrtribute !=='Active'){
        validateMobileDevice(attribute.displayValue, subsConfig);
    }
    console.log('Before Inside selectPlanDisplayValue Validation  '+isRelatedDeviceAdded);
    if (!selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === false && isCommittedDataOffer === false){
        console.log('Inside selectPlanDisplayValue Validation  ');
        CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,subsConfig.guid,false,'Please add One mobile Device.');
    }
    /*else if (selectPlanDisplayValue.includes('BYO') && isRelatedDeviceAdded === true && relatedConfigurationID != '') {
													CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,subsConfig.guid,false,'Please remove the added mobile device because BYO plan does not allow purchase of mobile device');	
													}*/
    else if (isRelatedDeviceAdded == false){
        CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,subsConfig.guid,true);	
    }
    let inputMap = {};
    inputMap['priceItemId'] = selectedPlan;
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InternationalDirectDial', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDD Charge', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDDAllowance', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDD ChargeLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MessageBank', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MessageBank RC', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PlanDiscountLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'TotalPlanBonus', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PlanAllowance', true);
    
    //function call to recalculate PlanDiscount value
    let deviceRecord = null;
    let planRecord = selectedPlan;
    subsConfig.attributes.forEach((configAttr) => {
        if (configAttr.name === 'InContractDeviceRecId' && configAttr.value != null) {
        deviceRecord = configAttr.value;
        updatePlanDiscountCWP(subsConfig, planRecord, deviceRecord);
    }
                                  });
    
    //code to populate the Plan Allowance details based on the data present in the Junction Object
    /*let inputMap2 = {};
													inputMap2['priceItemId'] = newValue; */
    
    CS.SM.WebService.performRemoteAction('SolutionGetAllowanceData', inputMap).then(
        function (response) {
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
                        value: {
                            value: allowanceRecId,
                            displayValue: allowanceValue
                        }
                    }];
                    console.log('updateConfigurationAttribute IDDallowance');
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, false);
                }
            } else {
                console.log('no response');
            }
        });
    
    //code to autopopulate the IDD and MessageBank AddOns with values if auto-bestowed based on the data of Junction Objects
    var addOnIDDCount = 0;
    var addOnMsgBankCount = 0;
    if(PlanTypeSelected !=='Data'){
        CS.SM.WebService.performRemoteAction('MobileSubscriptionGetAddOnData', inputMap).then(
            function (response) {
                if (response && response['addOnIDD'] != undefined) {
                    console.log('response[addOnIDD] ' + response['addOnIDD']);
                    addOnIDDCount = response['addOnIDD'].length;
                    
                }
                if (response && response['addOnMsgBank'] != undefined) {
                    console.log('response[addOnMsgBank] ' + response['addOnMsgBank']);
                    addOnMsgBankCount = response['addOnMsgBank'].length;
                }
                if (addOnIDDCount === 1) {
                    let updateConfigMap2 = {};
                    console.log('addOn Idd ' + response['addOnIDD'][0].Id);
                    updateConfigMap2[subsConfig.guid] = [
                        {
                            name: 'InternationalDirectDial',
                            value: {
                                value: response['addOnIDD'][0].Id,
                                displayValue: response['addOnIDD'][0].AddOn_Name__c,
                                readOnly: true,
                            }
                        },
                        {
                            name: 'IDD Charge',
                            value: {
                                value: response['addOnIDD'][0].cspmb__Recurring_Charge__c,
                                displayValue: response['addOnIDD'][0].cspmb__Recurring_Charge__c
                            }
                        }
                    ];
                    if (updateConfigMap2[subsConfig.guid].length > 0) {
                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, false);
                    }
                }
                if (addOnMsgBankCount === 1) {
                    let updateConfigMap2 = {};
                    console.log('addOn MsgBank ' + response['addOnMsgBank'][0].Id);
                    updateConfigMap2[subsConfig.guid] = [
                        {
                            name: 'MessageBank',
                            value: {
                                value: response['addOnMsgBank'][0].Id,
                                displayValue: response['addOnMsgBank'][0].cspmb__Add_On_Price_Item__r.Message_Bank__c
                            }
                        }, {
                            name: 'MessageBank RC',
                            value: {
                                value: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c,
                                displayValue: response['addOnMsgBank'][0].cspmb__Recurring_Charge__c
                            }
                        }];
                    if (updateConfigMap2[subsConfig.guid].length > 0) {
                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, false);
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
});
}
});
}

// Laxmi - Added check for Technology Type as well - bandwidth will get calculated
if (componentName === COMPONENT_NAMES.ipSite && (attribute.name === 'CountTotalUserQty' || attribute.name === 'TierSelected' || attribute.name === 'Technology Type')){
    console.log('*** - updateBandwidthOnIPSiteConfig');
    updateBandwidthOnIPSiteConfig(guid);
}

if (componentName === COMPONENT_NAMES.ipSite && (attribute.name === 'WidefeasCategory' || attribute.name === 'WorkCost') || attribute.name === 'Technology Type') {
    updateWidefeasCodeAndCategoryVisibility (guid);
    updateTelstraFibreCompatibility();
}


if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'SiteNetworkZone') {
    updateZoneOnUserConfigurations(guid, newValue);
    console.log('***124');
}

if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'Widefeas Code' && attribute.showInUi) {
    validateWFCodeFormat(guid, newValue, attribute.required,componentName);
    console.log('***126');
}




// --- Handset and Accessories, IAD Device: Hide Contract Term attribute when Contract Type is not 'Hardware Repayment' ---
if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'ContractType') {
    console.log('attribute.value: ' + newValue);
    let updateConfigMap = {};
    if (newValue === 'Hardware Repayment') {
        updateConfigMap[guid] = [{
            name: 'ContractTerm',
            value: {
                showInUi: true,
                required: true
            }
        }];
    } else {
        updateConfigMap[guid] = [{
            name: 'ContractTerm',
            value: {
                showInUi: false,
                required: false,
                value: ''
            }
        }];
    }
    
    CS.SM.updateConfigurationAttribute('Handset and Accessories', updateConfigMap, true);
    CS.SM.updateConfigurationAttribute('IAD Device', updateConfigMap, true);
}
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'InternationalDirectDial') {
    console.log('here InternationalDirectDial ' + newValue);
    if(newValue!=null && newValue!=''){
        CS.SM.getActiveSolution().then((product) => {
            if (product.type && product.name === COMPONENT_NAMES.solution) {
            if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            console.log('here 2');		
            comp.schema.configurations.forEach((config) => {
            console.log('here 3');
            if (config.guid === guid) {
            Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDDAllowance', true);
            Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDD ChargeLookup', true);
            //invoke method to get the allowance details
            let inputMap = {};
                                       inputMap[newValue] = 'getAddOn';
                                       var addOnRecId = null;
                                       var addOnValue = null;
                                       console.log('before entering '+ newValue);
        CS.SM.WebService.performRemoteAction('SolutionGetPricingRecords', inputMap).then(
            function (response) {   
                console.log('response', response);										
                if (response && response['addOnList'] != undefined) {
                    console.log('addOnList', response['addOnList']);
                    response['addOnList'].forEach((a) => {
                        if(a.Id != null){
                        addOnRecId = a.Id;
                        addOnValue = a.Name;
                    }
                                                  });
                    console.log('addOnRecId ', addOnRecId);
                    if(addOnRecId!= ''){
                        let updateConfigMap1 = {};
                        updateConfigMap1[config.guid] = [{
                            name: 'IDD ChargeLookup',
                            value: {
                                value: addOnRecId,
                                displayValue: addOnValue
                            }														
                        }];
                        console.log('updateConfigurationAttribute IDDcharge');
                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap1, false);
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
            
            CS.SM.WebService.performRemoteAction('SolutionGetAllowanceData', inputMap2).then(
                function (response) {   
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
                                value: {
                                    value: allowanceRecId,
                                    displayValue: allowanceValue
                                }														
                            }];
                            console.log('updateConfigurationAttribute IDDallowance');
                            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, false);
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
});
}

}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'IDD ChargeLookup') {
    console.log('here IDD ChargeLookup ' + newValue);
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid == guid) {
        Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'IDDAllowance', true);
        if(newValue!=null){
        var allowanceRecId = null;
        var allowanceValue = null;
        
        let inputMap2 = {};
                                   inputMap2['addOnPriceItemId'] = newValue;
                                   
                                   CS.SM.WebService.performRemoteAction('SolutionGetAllowanceData', inputMap2).then(
        function (response) {   
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
                        value: {
                            value: allowanceRecId,
                            displayValue: allowanceValue
                        }														
                    }];
                    console.log('updateConfigurationAttribute IDDallowance');
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, false);
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

});
}
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'Device Type') {
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'deviceTypeString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetManufacturer', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetModel', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetColour', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTerm', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ColourString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermString', true);
    
}


if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetManufacturer') {
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetModel', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetColour', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTerm', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ModelString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ColourString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermString', true);
    
    let updateConfigMap = {};
    updateConfigMap[guid] = [{
        name: 'ManufacturerString',
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetModel') {
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetColour', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTerm', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ColourString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermString', true);
    
    let updateConfigMap = {};
    updateConfigMap[guid] = [{
        name: 'ModelString',
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }													
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetColour') {
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTerm', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermString', true);
    
    let updateConfigMap = {};
    updateConfigMap[guid] = [{
        name: 'ColourString',
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }													
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);		
}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'PaymentTypeLookup') {
    console.log('entered PaymentTypeLookup updates===');
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTerm', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermString', true);
    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
    console.log('entered PaymentTypeLookup updates==='+attribute.displayValue);
    //console.log('entered PaymentTypeLookup updateConfigMap before==='+updateConfigMap);
    let updateConfigMap = {};
    updateConfigMap[guid] = [{
        name: 'PaymentTypeString',
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }													
    }];
    console.log('entered PaymentTypeLookup updateConfigMap after==='+updateConfigMap);
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'InContractDeviceRecId') {
    if(newValue!=null){
        let deviceRecord = newValue;
        let planRecord = null;
        console.log('entering InContractDeviceRecId change');
        CS.SM.getActiveSolution().then((product) => {
            if (product.type && product.name === COMPONENT_NAMES.solution) {
            if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((parentConfig) => {
            if(parentConfig.guid === guid){
            Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PlanDiscountLookup', true);
            Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'TotalPlanBonus', true);
            parentConfig.attributes.forEach((configAttr) => {
            if (configAttr.name === 'Select Plan') {
            planRecord = configAttr.value;
        }
                                       });
        if(planRecord!=null){
            updatePlanDiscountCWP(parentConfig,planRecord,deviceRecord);
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
if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ContractTerm') {
    if(newValue!=null){
        let deviceRecord = newValue;
        let planRecord = null;
        console.log('entering InContractDeviceRecId change');
        CS.SM.getActiveSolution().then((product) => {
            if (product.type && product.name === COMPONENT_NAMES.solution) {
            if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((parentConfig) =>{
            if(parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0 ){
            parentConfig.relatedProductList.forEach((relatedConfig) => {
            if(relatedConfig.guid === guid){
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'PlanDiscountLookup', true);
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'TotalPlanBonus', true);
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'InContractDeviceEnrollEligibility', true);
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
            Utils.emptyValueOfAttribute(parentConfig.guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
            parentConfig.attributes.forEach((configAttr) => {
            if (configAttr.name === 'Select Plan') {
            planRecord = configAttr.value;
        }
                                       });
        if(planRecord!=null){
            updatePlanDiscountCWP(parentConfig,planRecord,deviceRecord);
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
});
}
}

if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ContractTerm') {
    console.log('test contract term value on hook ' + attribute.value + '===' + attribute.displayValue);
    let updateConfigMap = {};
    updateConfigMap[guid] = [{
        name: 'RemainingTerm',
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }
    }];
    
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
    
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((parentConfig) => {
        if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {	
        parentConfig.relatedProductList.forEach((relatedProduct) => {
        if (relatedProduct.guid === guid) {
        let inContractDeviceCount = CWPPlugin.getInContractMobileDevices(parentConfig);
        if(inContractDeviceCount > 1){
        CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription, parentConfig.guid, false, 'There cannot be more than 1 device of payment type Contract for this plan.');
    }else{
                                   let updateConfigMap2 = {};
                                   updateConfigMap2[parentConfig.guid] = [{
                                   name: 'InContractDeviceRecId',
                                   value: {
                                   value: attribute.value,
                                   displayValue: attribute.value
                                   }													
                                   }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, true);
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
});
}

// update Total Plan Bonus
if (componentName === COMPONENT_NAMES.device && attribute.name === 'MROBonus') {
    // get parent configuration
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === componentName) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((parentConfig) => {									
        if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {										
        parentConfig.relatedProductList.forEach((relatedProduct) => {
        if (relatedProduct.guid === guid) {
        									calculateTotalMROBonusCWP(componentName, parentConfig);
        // set valid config on mobile subscription
        CS.SM.updateConfigurationStatus(componentName, parentConfig.guid, true);
    }
                                   });
}
});
}
}
});
}
}
});
}
//ankit added as part of EDGE-112367
if(componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'InContractDeviceEnrollEligibility'){
    CS.SM.getActiveSolution().then((product) => {
        Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'DeviceEnrollment', true);
        
        if (product.type && product.name === COMPONENT_NAMES.solution) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === componentName) {
        
        
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((parentConfig) => {
        var changeTypeAtrtribute = parentConfig.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
        if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0  && (changeTypeAtrtribute[0].value !=='Modify' ||changeTypeAtrtribute[0].value !=='Cancel'|| changeTypeAtrtribute[0].value !=='Active')) {
        parentConfig.relatedProductList.forEach((relatedProduct) => {
        if (relatedProduct.guid === guid) {
        let updateConfigMap = {};
        
        
        relatedProduct.configuration.attributes.forEach((attr)=> {
        if(attr.name==='InContractDeviceEnrollEligibility' ) {
        console.log('Inside Cancel Update for ChangeType',attr.value);
        if(attr.value!=='' && attr.value!==null){
        if(attr.value==='Eligible'){
        updateConfigMap[relatedProduct.guid] = [{
        name: 'DeviceEnrollment',
        value: {
            value:"ENROL",
            displayValue: "ENROL",
            showInUi: true,
            readOnly:false,
            required:true,
            options: ["ENROL",
                      "DO NOT ENROL"
                     ]
            
        }
    }];
                                   }else{
                                   updateConfigMap[relatedProduct.guid] = [{
                                   name: 'DeviceEnrollment',
                                   value: {
                                   value:"NOT ELIGIBLE",
                                   displayValue: "NOT ELIGIBLE",
                                   showInUi: true,
                                   readOnly:true,
                                   options: ["NOT ELIGIBLE"]
                                   
                                   }
                                   }];
                                   }
                                   }else{
                                   updateConfigMap[relatedProduct.guid] = [{
                                   name: 'DeviceEnrollment',
                                   value: {
                                   value:"",
                                   displayValue: "",
                                   showInUi: false,
                                   readOnly:false,
                                   options: [""]
                                   
                                   }
                                   }];
                                   }
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
    
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
});

}
/*if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MESSAGEBANK') {
                    setMessageBankUnitPrice(guid, attribute.displayValue);
            
                    let updateConfigMap = {};
                    updateConfigMap[guid] = [{
                        name: 'MessageBankSelected',
                        value: attribute.displayValue
                    }];
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
                }
            
                if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetManufacturer') {//check for names
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetModel', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetColour', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermLookup', false);
                }
            
                if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetModel') {
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'MobileHandsetColour', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermLookup', false);
            
                    await updateConfigurationsName();
                }
            
                if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'MobileHandsetColour') {
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'PaymentTypeLookup', false);
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermLookup', false);
                }
            
                if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'PaymentTypeLookup') {
                    Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'ContractTermLookup', false);
                    //calculateMROBonusDiscount(guid, attribute);
                    //EDGE-93656
                    updateTotalPlanBonus(guid,attribute); //Edge-93036- Defect fix - added to set Plan DIscount to zero when payment type is purchase
                }
                
                if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ContractTermLookup') {
                    calculateMROBonusDiscount(guid, attribute);
                }
            
                if (componentName === COMPONENT_NAMES.mobileSubscription && (attribute.name === 'RC' || attribute.name === 'OC')) {
                    fetchMobileDeviceUnitPrice(guid);
                }*/

//fix for conflict on Contract Type on Model Selection. Merged the 'controlHandSetTypeAndModel' function in the hook
if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'HandsetandAccessoriesModel') {
    //return controlHandSetTypeAndModel(guid);
    console.log('***duplicate check 333 ', guid);
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating Handset Model', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var currIpSiteConfigGUID;
        var currHandsetType;
        var currHandsetModel;
        var typeAndModelMatched = false;
        console.log('IP Site Config while updating Handset Model ', ipSiteConfig);
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        currIpSiteConfigGUID = ipSiteConfig.guid;
        relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
        if (handsetAttribute.name === 'HandsetandAccessoriesType') {
        currHandsetType = handsetAttribute.value;
    }
                                   if (handsetAttribute.name === 'HandsetandAccessoriesModel') {
        currHandsetModel = handsetAttribute.value;
    }
});
}
});
console.log('currIpSiteConfigGUID ', currIpSiteConfigGUID);
console.log('currHandsetType ', currHandsetType);
console.log('currHandsetModel ', currHandsetModel);
var typeMatched = false;
var modelMatched = false;
ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
    if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid !== guid && ipSiteConfig.guid === currIpSiteConfigGUID &&
    (!basketChangeType || (basketChangeType  && !relatedConfig.id))) {
    console.log('Inside If');
    relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
    if (handsetAttribute.name === 'HandsetandAccessoriesType' && handsetAttribute.value === currHandsetType) {
    typeMatched = true;
}
                                        if (typeMatched && handsetAttribute.name === 'HandsetandAccessoriesModel' && handsetAttribute.value === currHandsetModel) {
    modelMatched = true;
}
});
if (typeMatched && modelMatched) {
    typeAndModelMatched = true;
    statusMsg = ipSiteConfig.statusMessage;
}
}
});
}
console.log('typeMatched ', typeMatched);
console.log('modelMatched ', modelMatched);
console.log('typeAndModelMatched ', typeAndModelMatched);
statusMsg = statusMsg ? statusMsg : '';
statusMsg = statusMsg ? statusMsg + ',\n' + 'Duplicate Type and Model selected' : 'Duplicate Type and Model selected';
/*if (typeAndModelMatched) {
                                                    console.log('Duplicate Type and Model selected for H&A');
                                                    CS.SM.updateConfigurationStatus('Handset and Accessories', guid, false, 'Duplicate Type and Model selected').then( configuration => console.log(configuration) );
                                                }*/
if (currIpSiteConfigGUID) {
    updateConfigurationStatus('HA_DTMS','Handset and Accessories', guid, typeAndModelMatched===false, 'Duplicate Type and Model selected');
}
});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

if (componentName === COMPONENT_NAMES.ipSite && (attribute.name === 'Recurring Charge' || attribute.name === 'One Off Charge')) {
    fetchHandSetAndIADDeviceUnitPrice(guid);
}
// -------------------------------

/*if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'HandsetandAccessoriesModel') {
                     return controlHandSetTypeAndModel(guid);
                }*/

// --- MobileSubscription: auto add Mobile Deive related product when plan == 'CWP Mobile Seat' ---
/*if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'Plan__c' && newValue === 'CWP Mobile Seat') {
                    console.log('attribute.value: ' + newValue);
                    //return addMobileDeviceConfigurations();
                    addMobileDeviceConfigurations();
                }*///Commented as part of Mobile retrofit
// ----------------
// To Make ETC Visible on MobileSubscription For Cancel scenario
/*if (componentName === COMPONENT_NAMES.mobileSubscription && attribute.name === 'ChangeType' && oldValue != newValue && (newValue === 'Modify' || newValue === 'Cancel')) {
                    updateMobilityEtcVisibility(guid)
                }*///Commented as part of Mobile retrofit

if (basketChangeType === 'Change Solution')
{
    CheckMacdBusinessRules(componentName, guid, attribute, oldValue, newValue);
}


if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'ChangeType' && newValue === 'Cancel') {
    updateOppforCancelledIPSiteConfig(guid);
}

if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'ChangeType' && oldValue != newValue && (newValue === 'Modify' || newValue === 'Cancel')) {
    await addIPNAndUCEToMACSolution();
}

if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'WaiveETC') {
    updateEtcVisibility(guid)
}

if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'DisconnectionDate') {
    calculateTotalETCValue(guid);
}

if (componentName === COMPONENT_NAMES.uc /* && attribute.name === 'Orderprimarycontactid'*/) {
    checkUcOeRules();
}

if (componentName === COMPONENT_NAMES.ipSite && attribute.name === 'HandsetandAccessoriesType' && attribute.displayValue === 'IP Handset') {
    CS.SM.displayMessage('Please note that you may require universal power supply for the handsets added to this order. If it is required please specify under the Accessories section', 'info');
}
//Start: EDGE-95718 -Manjunath Ediga -Osaka Method to update TotalPlanBonus and RemainingTerm for Cancel changeType and PaymentType as Hardware repayment
// Start: EDGE-93425:Osaka: Re-compute Remaining term on change type selection.
/*if (componentName === COMPONENT_NAMES.mobileSubscription) {
                    if (attribute.name === 'ChangeType') {
                        if( newValue === 'Cancel') {
                            updateTotalPlanBonusAndRemainingTerm(guid);
            
                        } else if ( newValue === 'Modify') {
                             CS.SM.getActiveSolution().then((product) => {
                             //Start of EDGE-93425:Calculate Remaining Term on load of MobileSubscription solution across change order types.
                             //Defect Fix: Reset plan bonus to zero for remaining term =0 on solution load.
                             updateRemainingTerm(product);
                             })
                    //Start of EDGE-93425:
                        }
                // End: EDGE-93425:Osaka
                    }
                }*/ //Commented as part of Mobile retrofit
//End: EDGE-95718 -Manjunath Ediga -Osaka
/*---- DPG-1512 Start--------*/
let solution;
		CS.SM.getActiveSolution().then((product) => {
			solution = product;
			pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', COMPONENT_NAMES.mobileSubscription);
		});
/*---- DPG-1512 End--------*/

window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);

return Promise.resolve(true);
};

//Mobile Retrofit Completed
CWPPlugin.afterRelatedProductDelete = function _solutionBeforeConfigurationDelete(componentName, configuration, relatedProduct) {
    if (relatedProduct.name === 'IAD Device' && relatedProduct.type === 'Related Component') {
        makeIADDeviceMandatory();
        IADPortsFaxQuantityValidation();
    }
    // Mobile Retrofit Changes
    let inContractDeviceCount = 0;
    if (relatedProduct.name === 'Device' && relatedProduct.type === 'Related Component') {
        // reculculate totalPlanBonus
        calculateTotalMROBonusCWP(componentName, configuration);
        inContractDeviceCount = CWPPlugin.getInContractMobileDevices(configuration);
    }
    if(inContractDeviceCount > 1){
        updateConfigurationStatus(componentName, configuration.guid, false, 'There cannot be more than 1 In-Contract device for this plan.');
    }
    updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,configuration.guid,true);
    //End of Mobile Retrofit
    
    removeConfigurationStatus(relatedProduct.guid);
    return Promise.resolve(true);
}

CWPPlugin.beforeRelatedProductDelete = function _solutionBeforeConfigurationDelete(componentName, configuration, relatedProduct) {
    console.log('Related Config Delete - Before', componentName, configuration, relatedProduct);
    
    if (basketChangeType === 'Change Solution')
    {
        if (!solutionBeforeConfigurationDeleteMacd(componentName, configuration, relatedProduct))
            return Promise.resolve(false);
    }
    
    if (relatedProduct.name === 'User' && relatedProduct.type === 'Related Component') {
        var fixedSeatUser = false;
        relatedProduct.configuration.attributes.forEach((userAttribute) => {
            if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
            fixedSeatUser = true;
        }
                                                        });
        //console.log('fixedSeatUser=', fixedSeatUser, 'allowRPDel=', allowRPDel, 'Del COndition=', (fixedSeatUser && allowRPDel === 'No'));
        if (fixedSeatUser && allowRPDel === 'No') {
            CS.SM.displayMessage('Not allowed to delete Fixed Seat User!', 'info');
            return Promise.resolve(false);
        } else {
            return Promise.resolve(true);
        }
    }
    if (relatedProduct.name === 'Managed Router' && relatedProduct.type === 'Related Component') {
        var defaultMRouter = false;
        relatedProduct.configuration.attributes.forEach((mRouterAttribute) => {
            if (mRouterAttribute.name === 'Default' && mRouterAttribute.value === true) {
            defaultMRouter = true;
        }
                                                        });
        if (defaultMRouter && allowRPDel === 'No') {
            CS.SM.displayMessage('Not allowed to delete Default Managed Device!', 'info');
            return Promise.resolve(false);
        } else {
            return Promise.resolve(true);
        }
    }
    
    
    
    return Promise.resolve(true);
    
};

/*CWPPlugin.beforeRelatedProductAdd = function _solutionBeforeRelatedProductAdd(componentName, configuration, relatedProduct) {
                console.log('Related Config Add - Before', componentName, configuration, relatedProduct);
            
                if (relatedProduct.name === 'Bandwidth Clip On' && relatedProduct.type === 'Related Component') {
                    return disableAddingBandwidthClipOn(relatedProduct);
                }*/
//can not use for now because we do not know what releted producti s added.
/*
                if (basketChangeType === 'Change Solution')
                {
                    return CheckMacdBusinessRulesForRPAdd(componentName, configuration);
                }
            */
/*return Promise.resolve(true);
            
            };*/

CWPPlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
    console.log('afterSave - entering');
    canExecuteValidation = true;
    checkMACDBusinessRules();
    Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
    Utils.updateComponentLevelButtonVisibility('Add Mobile Subscription', true, true);
    Utils.updateOEConsoleButtonVisibility();
    Utils.hideSubmitSolutionFromOverviewTab(); //EDGE-135267
    await checkConfigurationSubscriptions();
    
    checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave();
    Utils.updateCustomButtonVisibilityForBasketStage();
    CWPPlugin.updateFieldsVisibilityAfterSolutionLoad(solution);
    CWPPlugin.updateDeviceEnrollmentAfterSolutionLoad() ;
    
    
    updateConfigurationsName();
    checkUcOeRules();
    updateWidefeasCodeAndCategoryVisibility(); //venkat
    //Change Started by Aditya - calling function updatecontracttermattribute aftersave
    updateChangeTypeAttribute();
    CWPPlugin.updateDevicestatusAfterSolutionLoad(solution);
    
    updatecontracttermattribute(solution);
    //Change Ends by Aditya
    return Promise.resolve(true);
}

CWPPlugin.beforeSave =  function (solution, configurationsProcessed, saveOnlyAttachment) {
    
    //DO NOT PUT IN beforeSave ANY ADDITIONAL CODE,  ESPECIALLY CODE FOR UPDATING VALUES  OR ANY ASYNC CODE !!!!!
    
    console.log('beforeSave - entering');
    
    if (allowSave) {
        allowSave = false;
        console.log('beforeSave - exiting true');
        return Promise.resolve(true);
    }
    
    executeSave = true;
    console.log('beforeSave - exiting false');
    return Promise.resolve(false);
    
}

CWPPlugin.buttonClickHandler = async function (buttonSettings) {
    
    /**   console.log('buttonClickHandler: id=', buttonSettings.id, buttonSettings);
                var url= '';
                var redirectURI = '/apex/';
                if (communitySiteId) {
                    redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
                }
            
                url = redirectURI;
                
            ****/
    /// *********Added Below code to resolve teh PRM URL Issue.. Pls do not delete
    
    console.log('buttonSettings',buttonSettings.id);
    var url= '';
    var redirectURI = '/apex/';
    if (communitySiteId) {
        url = window.location.href;
        if (url.includes('partners.enterprise.telstra.com.au'))
            redirectURI = '/s/sfdcpage/%2Fapex%2F';
        else
            redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
    }
    url = redirectURI;
    
    if (buttonSettings.id === 'ScSelectSiteAddressBtn') {
        
        var arrStr = '';
        if (existingSiteIds && existingSiteIds.length > 0) {
            arrStr = existingSiteIds.map(e => e.adborID).join();
        }
        
        console.log('basketId', basketId);
        console.log('existingSiteIds', arrStr);
        
        if (communitySiteId) {
            url = url + encodeURIComponent('c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&caller=' + COMPONENT_NAMES.solution);
        } else {
            url = url + 'c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&caller=' + COMPONENT_NAMES.solution;
        }
        console.log('url: ', url);
        return Promise.resolve(url);
    } else if (buttonSettings.id === 'getPriceScheduleAPI') {  //Added by Aman Soni as a part of Deal Management story
		let solutionId = '';
		let discountStatus='';
		let correlationId='';
		IsDiscountCheckNeeded=false;
        callerNameCWP = 'CWP';
        solutionId = '';
        uniquehexDigitCode=Date.now();
		//await CS.SM.(false, true, true).then( solId => console.log(solId));
		await CS.SM.getActiveSolution().then((product) => {
			console.log('Inside getPriceScheduleAPI');
			console.log('Inside getPriceScheduleAPI :: product :: ' + product);
			console.log('Inside getPriceScheduleAPI :: product :: ' + product.solutionId);
			solution = product;
			solutionId=product.solutionId;
            gSolutionID = product.solutionId;
            console.log(' gSolutionID '+gSolutionID);
			//updated by shubhi for handling multiple clicks
			if (solution.name.includes(COMPONENT_NAMES.solution)) {
				if (solution.components && solution.components.length > 0) {
					if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0) {
						solution.schema.configurations.forEach((config) => {							
								var correlationIds = config.attributes.filter(correlationId =>{
									return correlationId.name === 'correlationId' && !correlationId.value
								});
								if(correlationIds && correlationIds!=null && correlationIds[0] && correlationIds[0].value && correlationIds[0].value!=null){
									correlationId=correlationIds[0].value;	
								}
								var discount_Status=config.attributes.filter(discount_Status =>{
									return discount_Status.name === 'DiscountStatus' 
								});
								if(discount_Status && discount_Status!=null && discount_Status[0] && discount_Status[0].value && correlationIds && correlationIds.length>0 && correlationIds[0].value!=null){
									discountStatus=discount_Status[0].value;	
								}	
								//Laxmi EDGE-135885 - Added Solution nae so that it can be sent in URL
								solutionName=config.attributes.filter(solutionName =>{
									return solutionName.name === 'Solution Name' 
								});								
						});
					}
					solution.components.forEach((comp) => {
            console.log('Line 2258 '+' comp '+comp.name+' sol name '+COMPONENT_NAMES.solution);
						if (comp.name.includes(COMPONENT_NAMES.mobileSubscription)) {
            		console.log('Line 2259 condition is true ');
							if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {	
								comp.schema.configurations.forEach((config) => {											
									var IsDiscountCheckNeededAtt = config.attributes.filter(IsDiscountCheckNeededAtt =>{
											return IsDiscountCheckNeededAtt.name === 'IsDiscountCheckNeeded' 
									});
									// EDGE-131531 - Added check that the change Type should not be Active/Cancel
									var changeType = config.attributes.filter(changeType =>{
											return changeType.name === 'ChangeType' 
									});	
									var changeTypeVal = changeType[0].value;	
									if(IsDiscountCheckNeededAtt[0].value === true && discountStatus!=='Locked' && changeTypeVal !='Active' && changeTypeVal != 'Cancel' ){
										IsDiscountCheckNeeded=true;
									}
									// EDGE-131531 - Added check that the change Type should not be Active/Cancel
									if(IsDiscountCheckNeededAtt[0].value === true && discountStatus ==='Locked' && correlationId==='' && changeTypeVal !='Active' && changeTypeVal!= 'Cancel' ){

										IsDiscountCheckNeeded=true;
									}								
								});
							}
						}
					
					});
					
				}
			}
		});
		
		console.log ('solutionName***************' + solutionName[0].value);
		//updated by shubhi for handling multiple clicks
		console.log('inside getpricescheduleApi'+'@@@ accid-->'+accountId+' @@@basketid-->'+basketId+' @@@solid-->'+solutionId +'@@@disStatus-'+discountStatus+'@@@corelId-'+correlationId+ '@@@@IsDiscountCheckNeeded--'+IsDiscountCheckNeeded);
		 if (communitySiteId) { 
		 //Rohit Prodcution Fix Changes
                var baseurl = window.location.href;
                if (baseurl.includes('partners.enterprise.telstra.com.au')){
                    url = 'c__GetPriceScheduleCommon?basketId='+basketId +'&SolutionId='+solutionId+'&accountId='+accountId+'&discountStatus='+discountStatus+'&correlationId='+correlationId+'&IsDiscountCheckNeeded='+IsDiscountCheckNeeded+'&basketNum='+basketNum+'&solutionName='+COMPONENT_NAMES.mobileSubscription+'&callerName='+callerNameCWP+'&hexid='+uniquehexDigitCode; // EDGE-135885 - added Basket Num and Solution Name in URL
                }
				else {
					url = '/partners/';
					url = url + 'c__GetPriceScheduleCommon?basketId='+basketId +'&SolutionId='+solutionId+'&accountId='+accountId+'&discountStatus='+discountStatus+'&correlationId='+correlationId+'&IsDiscountCheckNeeded='+IsDiscountCheckNeeded+'&basketNum='+basketNum+'&solutionName='+COMPONENT_NAMES.mobileSubscription+'&callerName='+callerNameCWP+'&hexid='+uniquehexDigitCode;// EDGE-135885 - added Basket Num and Solution Name in URL
				}				
			}else {
			url = url + 'c__GetPriceScheduleCommon?basketId='+basketId +'&SolutionId='+solutionId+'&accountId='+accountId+'&discountStatus='+discountStatus+'&correlationId='+correlationId+'&IsDiscountCheckNeeded='+IsDiscountCheckNeeded+'&basketNum='+basketNum+'&solutionName='+COMPONENT_NAMES.mobileSubscription+'&callerName='+callerNameCWP+'&hexid='+uniquehexDigitCode;// EDGE-135885 - added Basket Num and Solution Name in URL
		}
              var payload11 ={
                command: 'childWindow',
                data: 'childWindow',
                caller: 'CWP'
            };
        sessionStorage.setItem("payload11", JSON.stringify(payload11));
		pricingUtils.setDiscountAttribute();
		pricingUtils.customLockSolutionConsole('lock');
        //await sleep(11000);
        //var vfRedirect ='<div><iframe name="myIframeName" frameborder="0" scrolling="yes" src="'+ url +'" style="" height="100px" width="120px"></iframe></div>';
		return Promise.resolve(url);
          
		
	} else if (buttonSettings.id === 'ScReserveNumbersBtn') {
        
        console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
        var id = existingSiteIds.filter(obj => { return obj.guid === buttonSettings.configurationGuid});
        console.log('Config data: ', id);
        if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
            if (id && id.length > 0 && id[0].configId && id[0].configId.length > 0) {
                
                if (communitySiteId) {
                    url = url + encodeURIComponent('c__NumberManagement?basketId=' + basketId + '&configId=' + id[0].configId);
                } else {
                    url = url + 'c__NumberManagement?basketId=' + basketId + '&configId=' + id[0].configId;
                }
                console.log('url: ', url);
                return Promise.resolve(url);
            } else {
                CS.SM.displayMessage('Can not reserve numbers, configuration is not saved!', 'info');
            }
        } else {
            CS.SM.displayMessage('Can not do number reservation when basket is in ' + basketStage + ' stage', 'info');
            return Promise.resolve(true);
        }
    }
	//Added as part of DPG-563 for adding new button for ISDN30 tactical transition
    else if (buttonSettings.id === 'ScReserveISDNTransitionNumbersBtn') {

    	console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
        var id = existingSiteIds.filter(obj => { return obj.guid === buttonSettings.configurationGuid});
        console.log('Config data: ', id);
        if(basketChangeType === 'Change Solution'){
        	if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
            	if (id && id.length > 0 && id[0].configId && id[0].configId.length > 0) {
                     
                     if (communitySiteId) {
                     	url = url + encodeURIComponent('c__NumberManagementTacticalTransition?basketId=' + basketId + '&configId=' + id[0].configId);
                 	} else {
                     	url = url + 'c__NumberManagementTacticalTransition?basketId=' + basketId + '&configId=' + id[0].configId;
                 	}
                     console.log('url: ', url);
                     return Promise.resolve(url);
                 } else {
                     CS.SM.displayMessage('Can not reserve numbers, configuration is not saved!', 'info');
                 }
           } else {
                 CS.SM.displayMessage('Can not do number reservation when basket is in ' + basketStage + ' stage', 'info');
                     
           }
         }else{
              CS.SM.displayMessage('ISDN 10/20/30 Tactical screen is not available on New Provide', 'info');
              return Promise.resolve(true);
         }
    }
        else if (buttonSettings.id === 'ScModifySiteAddressBtn') {
            
            if (Utils.isCommNegotiationAllowed()) { //basketStage!=='Contract Accepted'
                var arrStr = '';
                if (existingSiteIds && existingSiteIds.length > 0) {
                    arrStr = existingSiteIds.map(e => e.adborID).join();
                }
                
                console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
                console.log('existingSiteIds', arrStr);
                
                if (communitySiteId) {
                    url = url + encodeURIComponent('c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&configId=' + buttonSettings.configurationGuid + '&caller=' + COMPONENT_NAMES.solution);
                } else {
                    url = url + 'c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&configId=' + buttonSettings.configurationGuid + '&caller=' + COMPONENT_NAMES.solution;
                }
                
                return Promise.resolve(url);
            } else {
                CS.SM.displayMessage('Can not change address when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        }
            else if (buttonSettings.id === 'ScSelectCheckpointBtn') {
                
                let inputMap = {};
                inputMap['GetBasket'] = basketId;
                await CS.SM.WebService.performRemoteAction('CustomButtonComparison', inputMap).then(result => {
                    //  alert(JSON.stringify(result));
                    isMobileExists = result['isMobileExists'];
                });
                    
                    if (communitySiteId) {
                    url = url + encodeURIComponent('c__CheckPointPage?id=' + basketId + '&isdtp=vw&isMobilityProduct='+ isMobileExists);
                }
                    else {
                    url = url + 'c__CheckPointPage?id=' + basketId+ '&isdtp=vw&isMobilityProduct='+ isMobileExists;
                }
                    console.log('BasketId: ', basketId);
                    
                    return Promise.resolve(url);
                    
                } else if (buttonSettings.id === 'numReserve') {
                    if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
                    
                    if (communitySiteId) {
						 url = '/partners/';
                    url = url + ('c__NumberReservationPage?basketId=' + basketId);
                }
                    else{
                    url = '/apex/c__NumberReservationPage?basketId=' + basketId;
                }
                    return Promise.resolve(url);
                    //return Promise.resolve('/apex/c__NumberManagementMobilityBulk?basketId=' + basketId);
                } else {
                    CS.SM.displayMessage('Can not do number reservation when basket is in ' + basketStage + ' stage', 'info');
                    return Promise.resolve(true);
                }
                } else if (buttonSettings.id === 'orderEnrichment') {
                    if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
                    setTimeout(createOEUI , 200, 'Mobile Subscription', COMPONENT_NAMES.mobileSubscription);
                    return Promise.resolve('null');
                } else {
                    CS.SM.displayMessage('Can not do order enrichment when basket is in ' + basketStage + ' stage', 'info');
                    return Promise.resolve(true);
                }
                } else if (buttonSettings.id === 'ScMACSQCheckBtn') {
                    console.log('BasketId in ScMACSQCheckBtn: ', basketId);
                    if (basketChangeType === 'Change Solution' && (basketStage === 'Draft' || basketStage === 'Commercial Configuration')) {
                    var siteAdborId;
                    var ipSiteConfigId;
                    await CS.SM.getActiveSolution().then((product) => {
                    console.log('ScMACSQCheckBtn', product);
                    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                    if (product.components && product.components.length > 0) {
                    product.components.forEach((comp) => {
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    console.log('IP Site when ScMACSQCheckBtn clicked', comp);
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    var ipSiteConfig = comp.schema.configurations.filter(config => {
                    return config.guid === buttonSettings.configurationGuid
                });
                    console.log('ipSiteConfig', ipSiteConfig);
                    if (ipSiteConfig && ipSiteConfig[0].attributes && ipSiteConfig[0].attributes.length > 0) {
                    if (ipSiteConfig[0].id && ipSiteConfig[0].replacedConfigId) {
                    ipSiteConfigId = ipSiteConfig[0].id;
                }
                    var adbordIdAttribute = ipSiteConfig[0].attributes.filter(attr => {
                    return attr.name === 'AdborID'
                });
                    console.log('adbordIdAttribute', adbordIdAttribute);
                    if (adbordIdAttribute) {
                    siteAdborId = adbordIdAttribute[0].value;
                }
                }
                }
                }
                });
                }
                }
                });
                    console.log('Site AdborId in ScMACSQCheckBtn: ', siteAdborId);
                    if (ipSiteConfigId) {
                    if (communitySiteId) {
                    url = url + encodeURIComponent('c__SCSQCheckPage?basketId=' + basketId + '&adborId=' + siteAdborId + '&configGUID=' + buttonSettings.configurationGuid);
                } else {
                    url = url + 'c__SCSQCheckPage?basketId=' + basketId + '&adborId=' + siteAdborId + '&configGUID=' + buttonSettings.configurationGuid;
                }
                    return Promise.resolve(url);
                } else {
                    CS.SM.displayMessage('Can not initiate SQ Check when IP Site is not added to MAC Basket', 'info');
                    return Promise.resolve(true);
                }
                } else {
                    if (basketChangeType !== 'Change Solution') {
                    CS.SM.displayMessage('Can not initiate SQ Check for new baskets', 'info');
                }
                    else {
                    CS.SM.displayMessage('Can not initiate SQ Check when basket is in ' + basketStage + ' stage', 'info');
                }
                    return Promise.resolve(true);
                }
                } else if (buttonSettings.id === 'checkInventory') {  // EDGE-108289 - Fix to show check inventory button
                    console.log('basketId', basketId);
                    console.log('existingSiteIds', arrStr);
                    callerNameCWP = 'CWP';
                    //Updated as part of EDGE-146972  Get the Device details for Stock Check before validate and Save as well,added query parameters solutionID,callerName
                    await CS.SM.getActiveSolution().then((product) => {
                    gSolutionID = product.solutionId;
                });
                    
                    if (communitySiteId) {
                    var baseurl = window.location.href;
                    if (baseurl.includes('partners.enterprise.telstra.com.au')){
                    url = 'c__StockCheckPage?basketID=' + basketId+ '&solutionId=' + gSolutionID+'&callerName='+callerNameCWP;
                }
                    else{
                    url = '/partners/';
                    url = url + 'c__StockCheckPage?basketID=' + basketId+ '&solutionId=' + gSolutionID+'&callerName='+callerNameCWP ;
                }
                    //url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId+ '&solutionId=' + gSolutionID+'&callerName='+callerNameCWP );
                } else {
                    url = url + 'c__StockCheckPage?basketID=' + basketId+ '&solutionId=' + gSolutionID+'&callerName='+callerNameCWP ;
                }
                    console.log('url: ', url);
                    return Promise.resolve(url);
                }
                    else if (buttonSettings.id === 'checkPortin') {  // EDGE-117585 - Show 'Port-in check' button
                    
                    if (communitySiteId) {
                    url = url + encodeURIComponent('c__PortInPage?basketID=' + basketId );
                } else {
                    url = url + 'c__PortInPage?basketID=' + basketId ;
                }
                    return Promise.resolve(url);
                } 
                    return Promise.resolve(true);
                };
                    
                    
                    CWPPlugin.afterOrderEnrichmentConfigurationAdd = function(componentName, configuration, orderEnrichmentConfiguration){
                    console.log('CWP afterOrderEnrichmentConfigurationAdd', componentName, configuration, orderEnrichmentConfiguration)
                    initializeOEConfigs(orderEnrichmentConfiguration.guid);
                    window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
                    return Promise.resolve(true);
                };
                    
                    CWPPlugin.afterOrderEnrichmentConfigurationDelete = function(componentName, configuration, orderEnrichmentConfiguration){
                    window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
                    return Promise.resolve(true);
                };
                    /************************************************************************************
             * Author	: Vasanthi Sowparnika
             * Method Name : updateFieldsVisibilityAfterSolutionLoad
             * Description : To set field visibility
             * Extracted from CMP js file as part of Mobile retrofit
            */
                                CWPPlugin.updateFieldsVisibilityAfterSolutionLoad = function(solution) {
                                console.log('inside updateFieldsVisibilityAfterSolutionLoad');
                                
                                if (solution.name.includes(COMPONENT_NAMES.solution)) {
                                let updateMapDevice = {};
                                let updateConfigMap = {};
                                let updateselectMap = {};
                                let changeTypeForSolution = 'New';
                                let BounsAllownceFlag = false;
                                //var isCommittedDataOffer = false;
                                console.log('inside updateFieldsVisibilityAfterSolutionLoad' + solution.changeType);
                                
                                if (solution.components && solution.components.length > 0) {
                                var setChangeType = '';
                                
                                solution.components.forEach((comp) => {
                                
                                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                                console.log('updateFieldsVisibilityAfterSolutionLoad--->81127');
                                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                                comp.schema.configurations.forEach((config) => {
                                var valid = true;
                                errorMessage = '';
                                config.attributes.forEach((attr) => {
                                var CancelCheck = '';
                                if (attr.name === 'ChangeType' && attr.Value === 'Cancel') {
                                CancelCheck = 'Cancel';
                            }
                                
                                if (attr.name === 'PlanTypeString' && CancelCheck !== 'Cancel') {
                                if (attr.displayValue !== 'Data') {
                                updateConfigMap[config.guid] = [{
                                name: 'InternationalDirectDial',
                                value: {
                                    showInUi: true,
                                    required: false
                                }
                            }, {
                                name: 'MessageBank',
                                value: {
                                    showInUi: true,
                                    required: true
                                }
                            }, {
                                name: 'MessageBank RC',
                                value: {
                                    showInUi: true,
                                    required: false
                                }
                            }, {
                                name: 'IDD Charge',
                                value: {
                                    showInUi: true,
                                    required: false
                                }
                            }];
                                                                                                                }
                                                                                                                //console.log('attr.name==='+attr.name+attr.value);
                                                                                                                }
                                                                                                                });
                            if (config.id) {
                                if (config.attributes && config.attributes.length > 0) {
                                    console.log('updateFieldsVisibilityAfterSolutionLoad--->81127');
                                    var changeTypeAtrtribute = config.attributes.filter(obj => {
                                        return obj.name === 'ChangeType'
                                    });
                                    
                                    if (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel') {
                                        //updateMapDevice[config.guid] = [];
                                        updateMapDevice[config.guid] = [{
                                            name: 'RemainingTerm',
                                            value: {
                                                showInUi: true,
                                                readOnly: true
                                            }
                                        }, {
                                            name: 'ChangeType',
                                            value: {
                                                showInUi: true,
                                                readOnly: true
                                            }
                                        },
                                                                        /*{
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        },*/
                                                                {
                                                                    name: 'CancelFlag',
                                                                    value: {
                                                                        showInUi: true,
                                                                        readOnly: true
                                                                    }
                                                                }];
                                
                            }
                            
                            if (config.relatedProductList && config.relatedProductList.length > 0 && (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel')) {
                                config.relatedProductList.forEach((relatedConfig) => {
                                    updateMapDevice[relatedConfig.guid] = [];
                                    if (relatedConfig.name.includes('Device')) {
                                    
                                    if ((relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !==undefined && relatedConfig.configuration.replacedConfigId !==null) && relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
                                    var changeTypeAtrtribute = config.attributes.filter(obj => {
                                    return obj.name === 'ChangeType'
                                });
                                    var earlyTerminationChargeAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                                    return obj.name === 'EarlyTerminationCharge'
                                });
                                    /*var cancelFlagAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                                                                        return obj.name === 'CancelFlag'
                                                                    });*/
                                                            var ChangeTypeDeviceAttribute = relatedConfig.configuration.attributes.filter(obj => {
                                                            return obj.name === 'ChangeTypeDevice'
                                                        });
                                                            console.log('updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product');
                                                            console.log('updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product' + ChangeTypeDeviceAttribute[0].value + earlyTerminationChargeAtrtribute[0].value);
                                                            if(ChangeTypeDeviceAttribute[0].value !== 'New'){
                                                            if (/*(cancelFlagAtrtribute[0].value === false || cancelFlagAtrtribute[0].value === '' || cancelFlagAtrtribute[0].value === null) && */(ChangeTypeDeviceAttribute[0].value === 'None' || ChangeTypeDeviceAttribute[0].value === '' || ChangeTypeDeviceAttribute[0].value === null) && (earlyTerminationChargeAtrtribute[0].value == 0 || earlyTerminationChargeAtrtribute[0].value == '' || earlyTerminationChargeAtrtribute[0].value == null)) {
                                                            console.log('inside iif');	
                                                            updateMapDevice[relatedConfig.guid].push({
                                                            name: 'RemainingTerm',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: false,
                                                                readOnly: true
                                                            }
                                                        }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: false,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'ChangeTypeDevice',
                                                            value: {
                                                                showInUi: true,
                                                                //readOnly: false
                                                            }
                                                        });
                                                        
                                                        
                                                    } else if(changeTypeAtrtribute[0].value === 'Cancel') {
                                                        console.log('inside iif');	
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'RemainingTerm',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'ChangeTypeDevice',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                    }else {
                                                        console.log('inside else');	
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'RemainingTerm',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                                        updateMapDevice[relatedConfig.guid].push({
                                                                            name: 'ChangeTypeDevice',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: false
                                                                            }
                                                                        });
                                                                    }
                        }
                    }
                            
                        }
});
}

}
}

});

}
}
});
//console.log('updateFieldsVisibilityAfterSolutionLoad - updating: ', updateselectMap);
console.log('updateFieldsVisibilityAfterSolutionLoad - updateMapDevice: ', updateMapDevice);
console.log('updateFieldsVisibilityAfterSolutionLoad - updateConfigMap: ', updateConfigMap);
if (Object.keys(updateMapDevice).length > 0) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateFieldsVisibilityAfterSolutionLoad updateMapDevice Attribute Update', component));
}
if (Object.keys(updateConfigMap).length > 0) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true).then(component => console.log('updateFieldsVisibilityAfterSolutionLoad updateConfigMap Attribute Update', component));
}
}
}

}
/************************************************************************************
             * Author	: Vasanthi Sowparnika
             * Method Name : updateRemainingTermAfterSolutionLoad
             * Description : Update RemainingTerm on Mobile subscription after solution load
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/

CWPPlugin.updateRemainingTermAfterSolutionLoad = function() {
    console.log('checkRemainingTermForBYOPlans');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.name.includes(COMPONENT_NAMES.solution)) {
        var updateMap = {};
                                   var updateSolMap = {};
                                   var isMacdOffer=false;
                                   if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var updateMapDevice = {};
        
        solution.components.forEach((comp) => {
            
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            
            console.log('checkRemainingTermForBYOPlans--->4817');
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
            var valid = true;
            errorMessage = '';
            //if (config.id ) {
            
            if (config.attributes && config.attributes.length > 0) {
            var contractTermAtrtribute = config.attributes.filter(obj => {
            return obj.name === 'ContractTerm'
        });
        var changeTypeAtrtribute = config.attributes.filter(obj => {
            return obj.name === 'ChangeType'
        });
        var contractTermInt = 24;
        //remainingTermsolutionUpdate(config,contractTermAtrtribute[0].displayValue,config.id);
        //remainingTermsolutionUpdate(config,contractTermInt,config.id);
        //	console.log('checkRemainingTermForBYOPlans--->4827'+contractTermAtrtribute[0].displayValue);
        if (config.relatedProductList && config.relatedProductList.length > 0 && (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel')) {
            
            config.relatedProductList.forEach((relatedConfig) => {
                updateMapDevice[relatedConfig.guid] = [];
                if (relatedConfig.name.includes('Device')) {
                
                if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0 && relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !==null ) {
                
                
                contractTermAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                return obj.name === 'ContractTerm'
            });
                /*var cancelFlagAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                                                                    return obj.name === 'CancelFlag'
                                                                });*/
                            var ChangeTypeDeviceattribute = relatedConfig.configuration.attributes.filter(obj => {
                            return obj.name === 'ChangeTypeDevice'
                        });
                            if (/*cancelFlagAtrtribute[0].value != true && */ChangeTypeDeviceattribute[0].value != 'PayOut' && ChangeTypeDeviceattribute[0].value != 'New' ) {
                            console.log('checkRemainingTermForBYOPlans--->4835' + contractTermAtrtribute[0].displayValue);
                            remainingTermsolutionUpdate(relatedConfig.configuration, contractTermAtrtribute[0].displayValue, config.guid);
                        }
                            
                        }
                            
                        }
                        });
                        }
                            
                        }
                            //}
                        });
                            
                        }
                        }
                        });
                            
                            //console.log('updateCancelFlagVisibility - updating: ', updateMapDevice);
                            //CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
                            
                        }
                        }
                        }).then(
                            () => Promise.resolve(true)
                            ).catch(() => Promise.resolve(true));
                        }
                            
                            /************************************************************************************
             * Author   : Vasanthi Sowparnika
             * Method Name : updateDeviceEnrollmentAfterSolutionLoad
             * Description : Device enrollemnt update on after solution load
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
                            CWPPlugin.updateDeviceEnrollmentAfterSolutionLoad = function() {
                            console.log('checkRemainingTermForBYOPlans');
                            CS.SM.getActiveSolution().then((solution) => {
                            if (solution.name.includes(COMPONENT_NAMES.solution)) {
                            var updateMap = {};
                            if (solution.components && solution.components.length > 0) {
                            var updateMapDevice = {};
                            solution.components.forEach((comp) => {
                            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                            comp.schema.configurations.forEach((config) => {
                            var changeTypeAtrtribute = config.attributes.filter(obj => {
                            return obj.name === 'ChangeType'
                        });
                            if (config.relatedProductList && config.relatedProductList.length > 0) {
                            config.relatedProductList.forEach((relatedConfig) => {
                            if (relatedConfig.name.includes('Device')) {
                            if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0 ){
                            relatedConfig.configuration.attributes.forEach((relatedConfigattr) => {
                            if(relatedConfig.configuration.replacedConfigId ==='' ||relatedConfig.configuration.replacedConfigId === undefined || relatedConfig.configuration.replacedConfigId ===null){
                            if(relatedConfigattr.name==='InContractDeviceEnrollEligibility'){
                            if(relatedConfigattr.value==='Eligible'){
                            updateMap[relatedConfig.guid] = [{
                            name: 'DeviceEnrollment',
                            value: {
                                showInUi: true,
                                readOnly:false,
                                required:true,
                                options: ["ENROL",
                                          "DO NOT ENROL"
                                         ]
                                
                            }
                        }];
                                                          }else{
                                                          updateMap[relatedConfig.guid] = [{
                                                          name: 'DeviceEnrollment',
                                                          value: {
                                                          value:"NOT ELIGIBLE",
                                                          displayValue: "NOT ELIGIBLE",
                                                          showInUi: true,
                                                          readOnly:true,
                                                          options: ["NOT ELIGIBLE"]
                                                          
                                                          }
                                                          }];
                                                          }
                                                          }
                                                          }else{
                                                          updateMap[relatedConfig.guid] = [{
                                                          name: 'DeviceEnrollment',
                                                          value: {
                                                          showInUi: false,
                                                          readOnly:true,	
                                                          }
                                                          }];
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
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));

}
}
}).then(
    () => Promise.resolve(true)
);
}

/************************************************************************************
             * Author   : Harsh Parmar
             * Method Name : getSelectedPlanForMobileSubscription
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
CWPPlugin.getSelectedPlanForMobileSubscription = async function (guid) {
    let selectPlanDisplayValue = '';
    await CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        let comp = product.components.filter(c => {return c.name===COMPONENT_NAMES.mobileSubscription});
    if (comp && comp.length> 0 &&  comp[0].schema && comp[0].schema.configurations && comp[0].schema.configurations.length > 0) {
        let config = comp[0].schema.configurations.filter(c => c.guid === guid);
        if (config && config.length > 0) {
            let att = config[0].attributes.filter(a => {return a.name === 'Select Plan'});
            if (att && att.length)
                selectPlanDisplayValue = att[0].displayValue;
        }
    }
}
}
});
return selectPlanDisplayValue;
}

/**************************************************************************************
             * Author	   : Vasanthi Sowparnika
             * Method Name : updateDevicestatusAfterSolutionLoad
             * Description : update device status from all related product
             * Invoked When: Device status is updated,
			 * Extracted from CMP js file as part of Mobile retrofit
            **************************************************************************************/
CWPPlugin.updateDevicestatusAfterSolutionLoad = function(solution) {
    
    if (solution.name.includes(COMPONENT_NAMES.solution)) {
        var updateMap = {};
        var ChangeAttr= false;
        if (solution.components && solution.components.length > 0) {
            solution.components.forEach((comp) => {
                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                comp.schema.configurations.forEach((config) => {
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                config.relatedProductList.forEach((relatedConfig) => {
                updateMap[relatedConfig.guid]=[];
                console.log('Check device updateMap'+updateMap.size);
                if (relatedConfig.name.includes('Device')) {
                if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
                var ReletedConfig=relatedConfig.configuration.replacedConfigId;
                var ChangeTypeDeviceAttr = relatedConfig.configuration.attributes.filter(obj => {
                return obj.name === 'ChangeTypeDevice'
            });
            var DeviceStatusAttr = relatedConfig.configuration.attributes.filter(obj => {
                return obj.name === 'DeviceStatus'
            });
            var ReplaceConfigAttr = relatedConfig.configuration.attributes.filter(obj => {
                return obj.name === 'ReplaceConfig'
            });
            console.log('Check device status flag'+ChangeTypeDeviceAttr[0].value+DeviceStatusAttr[0].value+ReletedConfig);
            
            if(ReletedConfig !=='' && ReletedConfig !==null && DeviceStatusAttr[0].value==='PaidOut'){
                
                
                console.log('insifr paidout');
                updateMap[relatedConfig.guid].push({
                    name: 'DeviceStatus',
                    value: {
                        
                        value:'PaidOut',
                        displayValue:'PaidOut',
                        showInUi: true,
                        readOnly:true
                    }
                });
            }else if(ReletedConfig !=='' && ReletedConfig !==null && ReletedConfig !==undefined && DeviceStatusAttr[0].value !=='PaidOut'){
                console.log('insifr ACTIVE MRO');
                updateMap[relatedConfig.guid].push({
                    name: 'DeviceStatus',
                    value: {
                        value:'ACTIVE MRO',
                        displayValue:'ACTIVE MRO',
                        showInUi: true,
                        readOnly:true
                        
                    }
                });
                
            }
                else{
                    console.log('insifrelse');
                    updateMap[relatedConfig.guid].push({
                        name: 'DeviceStatus',
                        value: {
                            showInUi: false,
                            readOnly:true,
                            value:'',
                            displayValue:'',
                        }
                    });
                }	
            
            updateMap[relatedConfig.guid].push({
                name: 'ReplaceConfig',
                value: {
                    value:ReletedConfig,
                    displayValue:ReletedConfig
                }
            });			
            
            
            
            console.log('updateCancelFlagVisibility - updating: ', updateMap);
            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
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
}

CWPPlugin.updateAttributeVisibility = function (componentName, attributeName, guid, isVisible, isRequired) {
    console.log('updateAttributeVisibility',attributeName, componentName, guid, isVisible,isRequired);
    let updateMap = {};
    updateMap[guid] = [];
    
    updateMap[guid].push(
        {
            name: attributeName,
            value: {
                readOnly: false,
                showInUi: isVisible,
                required: isRequired
            }
        });
    
    CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
    
}
/**************************** End of Hooks ******************************************/

/**************************************************************************************
             * Author	   : Li Tan
             * Method Name : addMobileDeviceConfigurations
             * Invoked When: Mobility product Plan attribute == 'CWP Mobile Seat'
             * Description : 1. auto add Mobile Device as a related product
             * Parameters  : None
             **************************************************************************************/
/*function addMobileDeviceConfigurations() {
                // let product = CS.SM.getActiveSolution();
                // console.log('product:');
                // console.log(product);
                CS.SM.getActiveSolution().then((product) => {
                    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                        var userRelatedCompId;
                        console.log('product.components: ');
                        console.log(product.components);
                        if (product.components && product.components.length > 0) {
                            product.components.forEach((comp) => {
                                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                                    console.log('mobileSubscription comp:', comp);
                                    if (comp.relatedComponents && comp.relatedComponents.length > 0) {
                                        comp.relatedComponents.forEach((relatedComp) => {
                                            if (relatedComp.name === 'Device') {
                                                console.log('relatedComp.name: ' + relatedComp.name);
                                                comp.schema.configurations.forEach((config) => {
                                                    /*if (config.relatedProductList && config.relatedProductList.length < 1) {
                                                        CS.SM.addRelatedProduct('Mobility', config.guid, relatedComp.id);
                                                    }*/
//Commented the above if block and Added the below lines by Mahaboob on 12/07/2019 for MRO Bonus calculation
/* var planAttribute = config.attributes.filter(a => {
                                                        return a.name === 'MobilityPlan'
                                                    });
                                                    var planId;
                                                    if (planAttribute) {
                                                        var planAtt = planAttribute[0];
                                                        console.log('planAtt: ', planAtt, planAtt.value, planAtt.displayValue);
                                                        if (planAtt && planAtt.value) {
                                                            planId = planAtt.value;
                                                        }
                                                    }
                                                    if (config.relatedProductList && config.relatedProductList.length < 1) {
                                                        CS.SM.addRelatedProduct(COMPONENT_NAMES.mobileSubscription, config.guid, relatedComp.id).then(mobilityConfig => {
                                                            console.log('New Added Mobile Device Config', mobilityConfig);
                                                            var updateMap = [];
                                                            if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
                                                                mobilityConfig.relatedProductList.forEach((relatedComp) => {
                                                                    if (relatedComp.name === 'Device' && relatedComp.configuration && relatedComp.configuration.guid) {
                                                                        updateMap[relatedComp.configuration.guid] = [{
                                                                            name: "MobilityPlanId",
                                                                            value: {
                                                                                value: planId,
                                                                                displayValue: planId,
                                                                                readOnly: true,
                                                                                required: false
                                                                            }
                                                                        }];
                                                                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('addMobileDeviceConfigurations Attribute update', component));
                                                                    }
                                                                });
                                                            }
                                                        });
                                                    }
                                                    //End by Mahaboob on 12/07/2019
                                                });
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    }
                }).then(
                    () => Promise.resolve(true)
                );
            }*/

/**************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : calculateMROBonusDiscount
             * Invoked When: Term on Mobile Device is updated
             * Description : 1. calculates the MRO Discount based on Payment Type
             * Parameters  : 1. guid        -   guid of the Mobile Device configuration
             *               2. attribute   -   Term attribute of Mobile Device
             *************************************************************************/
async function calculateMROBonusDiscount(guid, attribute) {
    var updateMap = {};
    var mroBonus = 0.00;
    var product;
    
    console.log('calculateMROBonusDiscount',guid, attribute);
    await CS.SM.getActiveSolution().then((p) => {
        product = p;
        console.log('calculateMROBonusDiscount - solution set');
    }).then(
        () => Promise.resolve(true)
        );
        
        console.log('calculateMROBonusDiscount - looking for configuration');
        
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        let componentList = product.components.filter((c) => {
        return c.name === COMPONENT_NAMES.mobileSubscription
    });
        if (componentList && componentList.length > 0) {
        let comp = componentList[0];
        console.log('calculateMROBonusDiscount mobileSubscription comp:', comp);
        for (let i = 0; i < comp.schema.configurations.length; i++) {
        var mobilityConfig = comp.schema.configurations[i];
        if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
        var mDeviceConfigList = mobilityConfig.relatedProductList.filter((d) => {
        return d.guid === guid
    });
        if (mDeviceConfigList && mDeviceConfigList.length > 0) {
        var mDeviceConfig = mDeviceConfigList[0];
        if (attribute && attribute.value && attribute.value !== '') {
        var paymentType;
        var devideId;
        if (attribute.name === 'PaymentTypeLookup') {
        paymentType = attribute.displayValue;
        var contractTermAttribute = mDeviceConfig.configuration.attributes.filter(a => {
        return a.name === 'ContractTermLookup'
    });
        if (contractTermAttribute && contractTermAttribute.length > 0) {
        var contractTermAttr = contractTermAttribute[0];
        console.log('calculateMROBonusDiscount contractTermAttr: ', contractTermAttr, contractTermAttr.value, contractTermAttr.displayValue);
        if (contractTermAttr && contractTermAttr.value) {
        devideId = contractTermAttr.value;
    }
    }
    } else if (attribute.name === 'ContractTermLookup') {
        devideId = attribute.value;
        var paymentTypeAttribute = mDeviceConfig.configuration.attributes.filter(a => {
        return a.name === 'PaymentTypeLookup'
    });
        if (paymentTypeAttribute && paymentTypeAttribute.length > 0) {
        var paymentTypeAttr = paymentTypeAttribute[0];
        console.log('calculateMROBonusDiscount paymentTypeAttr: ', paymentTypeAttr, paymentTypeAttr.value, paymentTypeAttr.displayValue);
        if (paymentTypeAttr && paymentTypeAttr.displayValue) {
        paymentType = paymentTypeAttr.displayValue;
    }
    }
        var updateMapRemainingTerm={};
        var changeTypeList = mobilityConfig.attributes.filter(att => { return att.name === "ChangeType"});
        console.log("New order details" , changeTypeList,paymentType);
        if (changeTypeList && changeTypeList[0].value && changeTypeList[0].value === "New" && paymentType === 'Hardware Repayment') {
        console.log("New order details");
        updateMapRemainingTerm [mobilityConfig.guid]=[{
        name: "Remaining Term",
        value: {
            value: attribute.displayValue,
            displayValue: attribute.displayValue
        }
    }];
                                         CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapRemainingTerm, false).then();
}
}

if (paymentType === 'Hardware Repayment') {
    var planAttribute = mobilityConfig.attributes.filter(a => {
        return a.name === 'MobilityPlan'
    });
    var planId;
    if (planAttribute) {
        var planAtt = planAttribute[0];
        console.log('calculateMROBonusDiscount planAtt: ', planAtt, planAtt.value, planAtt.displayValue);
        if (planAtt && planAtt.value) {
            planId = planAtt.value;
        }
    }
    var inputMap = {};
    //inputMap["DeviceId"] = attribute.value;
    inputMap["DeviceId"] = devideId;
    inputMap["PlanId"] = planId;
    console.log('Inputmap Solution helper'+inputMap);
    
    
    await CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => {
        console.log('Response Solution helper'+values);
        if (values && values["MRO Bonus"]) {
        console.log('calculateMROBonusDiscount MRO Bonus', values["MRO Bonus"], values["MRO Bonus"][0]["name"], values["MRO Bonus"][0]["value"], values["MRO Bonus"][0]["value"]["value"]);
        updateMap[mobilityConfig.guid] = values["MRO Bonus"];
    }
        //EDGE-93656 Defect Fix -Set Discount type to zero when discount is zero in selected product
        else{
        updateMap[mobilityConfig.guid] = [{
        name: "TotalPlanBonus",
        value: {
            value: 0,
            displayValue: 0
        }
    }];
                                                                                }
                                                                                });
    //EDGE: 93656 - Calculate Plan Discount 
    console.log("-comp--->",comp);
    if(comp.schema && comp.schema.configurations)
    {
        comp.schema.configurations.forEach((config) => {
            var changeTypeList = config.attributes.filter(att => { return att.name === "ChangeType"});
        var remainingTermList  =  config.attributes.filter(att => { return att.name === "Remaining Term"});
        var mobilityPlanSelectedList    =  config.attributes.filter(att => { return att.name === "MobilityPlan"});
        var originalPlanList   =  config.attributes.filter(att => { return att.name === "Original Plan"});
        console.log("-changeTypeList--->",changeTypeList);
        console.log("-remainingTermList--->",remainingTermList);
        console.log("-originalPlanList--->",originalPlanList);
        console.log("-mobilityPlanSelectedList--->",mobilityPlanSelectedList);
        if(changeTypeList && remainingTermList && mobilityPlanSelectedList && originalPlanList){
            if(changeTypeList.length>0 && remainingTermList.length>0 && mobilityPlanSelectedList.length>0 && originalPlanList.length>0){
                console.log("changeType is :", changeTypeList);
                if(changeTypeList[0].value === "Modify") {
                    var flag = 0;
                    //EDGE: 93425 - Invoking the method to update the remaining term . Sasi.
                    //	console.log("Calling remainingTermMobilityUpdate method with config", confid.id,config, " term: ", parseInt(attribute.displayValue));
                    // remainingTermMobilityUpdate(config,parseInt(attribute.displayValue));
                    //EDGE: 93425 - TotalPlanBonus remains the same when remainingTerm is greaterthan 0
                    //EDGE: 93425 - Set the TotalPlanBonus to 0 when remainingTerm is 0
                } else if(remainingTermList[0].value == "0" && changeTypeList[0].value != "New"){
                    updateMap[mobilityConfig.guid] = [{
                        name: "TotalPlanBonus",
                        value: {
                            value: 0,
                            displayValue: 0
                        }
                    }];
                }
                
            } 
        }
    });   
}
} 
//EDGE-93656 -Defect fix - Set Discount type to zero when discount is zero in selected product
else {                                
    updateMap[mobilityConfig.guid] = [{
        name: "TotalPlanBonus",
        value: {
            value: 0.0,
            displayValue: 0.0,
            readOnly: true,
            required: false
        }
    }];
}
//Start of EDGE: 93425
//Getting the Term value form Mobile Device and updating the same value in the Contract Term on Mobility.
var updateMapContractTerm = {};
updateMapContractTerm = {
    name: "Contract Term",
    value: {
        value: attribute.displayValue,
        displayValue: attribute.displayValue
    }
};
//Edge: 93425 updating remaining term from contract term
var updateMapRemainingTerm = {};

//CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobility, updateMapRemainingTerm, false).then();
var updateMapContractTermShadow = {};
updateMapContractTermShadow[mobilityConfig.guid] = [{
    name: "ContractTermShadow",
    value: {
        value: attribute.displayValue,
        displayValue: attribute.displayValue
    }
},updateMapContractTerm];

CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapContractTermShadow, false).then();
//End of EDGE: 93425
} else {
    
    if(comp.schema && comp.schema.configurations)
    {
        comp.schema.configurations.forEach((config) => {
            var changeTypeList = config.attributes.filter(att => { return att.name === "ChangeType"});
        var remainingTermList  =  config.attributes.filter(att => { return att.name === "Remaining Term"});
        console.log("updateTotalPlanBonus--->",changeTypeList,remainingTermList);
        if(changeTypeList &&  remainingTermList && changeTypeList[0].displayValue === "New" && remainingTermList[0].displayValue === "0"){
            var updateTotalPlanBonus = {};
            updateTotalPlanBonus[mobilityConfig.guid] = [{
                name: "TotalPlanBonus",
                value: {
                    value: 0.0,
                    displayValue: 0.0
                }
            }];
            console.log("step--->",updateTotalPlanBonus);
            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateTotalPlanBonus, false).then();
        }
        //Edge- 93656 - Reset Plan Discount when o products are selected
        /*else {
                                                    var updateTotalPlanBonus = {};
                                                    updateTotalPlanBonus[mobilityConfig.guid] = [{
                                                        name: "TotalPlanBonus",
                                                        value: {
                                                            value: 0.0,
                                                            displayValue: 0.0
                                                        }
                                                    }];
                                                  console.log("step1--->",updateTotalPlanBonus);
                                                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobility, updateTotalPlanBonus, false).then(); 
                                                }*/
        
        if(changeTypeList && changeTypeList[0].displayValue === "Modify"){
            parseInt(attribute.value)(config,0);
        }
        
    });
}
}
console.log("updateMap--->",updateMap);
if (updateMap && Object.keys(updateMap).length > 0) {
    console.log('calculateMROBonusDiscount updateMap', updateMap);
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, false).then(component => console.log('calculateMROBonusDiscount Attribute update', component));
}
}
}
}
}
}
}
}

/*************************************************************************************
            * Author                : Sasidhar Devarapalli
            * Method Name : remainingTermMobilityUpdate
            * Invoked When: Contract Term on Mobility is updated
            * Description : Calls this function to populate remaining term attribute
            
            ************************************************************************************/
function remainingTermMobilityUpdate(config,contractTerm){
    
    
    if(contractTerm != 0){
        let inputMap = {};
        var originalDiscount = 0;
        inputMap['getServiceForMAC'] = config.id;
        console.log('remainingTermMobilityUpdate :: inputMap :: ', inputMap);
        var originalPlanList   =  config.attributes.filter(att => { return att.name === "Original Plan"});
        //  93656 Defect 20/8/19 - Start :change Type modified from cancel to Modify
        var originaldiscountList     =  config.attributes.filter(att => { return att.name === "Original Unit Discount"});
        if(originaldiscountList && originaldiscountList.length>0 && originaldiscountList[0].displayValue )
            originalDiscount = originaldiscountList[0].displayValue;
        //  93656 Defect 20/8/19 - End
        // Get Service Activation date from replaced PC
        CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
            console.log('getServiceForMAC finished with response: ', result);
            var serviceStartDateString = result["getServiceForMAC"];
            if (serviceStartDateString) {
            var serviceStartDate = new Date(JSON.parse(serviceStartDateString));
            console.log('serviceStartDate: ', serviceStartDate);
            var oneDay = 24*60*60*1000;
            var today = new Date();
            today.setHours(0,0,0,0);
            serviceStartDate.setHours(0,0,0,0);
            var remainingTerm = 0;
            var remainingTerm = Math.ceil((contractTerm*30  - ((today - serviceStartDate)/oneDay)) / 30);
            console.log('remainingTerm: ', remainingTerm);
            if(remainingTerm < 0 ||  isNaN(remainingTerm) || remainingTerm === undefined || remainingTerm === "" || remainingTerm ==="null"){
            remainingTerm = 0;
        }
            var updateRemainingTermMap = {};
            // Reset Plan bonus and remaining term.
            
            if( remainingTerm  === 0){
            
            updateRemainingTermMap[config.guid] = [{
            name: "TotalPlanBonus",
            value: {
                value: 0.00,
                displayValue: 0.00
            }
        },{
            name: "Remaining Term",
            value: {
                value: remainingTerm,
                displayValue: remainingTerm
            }
        }]
                                                                                    }
                                                                                    else{
                                                                                    // Set computed value.
                                                                                    updateRemainingTermMap[config.guid] = [{
                                                                                    name: "Remaining Term",
                                                                                    value: {
                                                                                    value: remainingTerm,
                                                                                    displayValue: remainingTerm
                                                                                    }
                                                                                    },
                                                                                    // 93656 Defect 20/8/19 Chnage type from cancel to modify -start
                                                                                    {
                                                                                    name: "TotalPlanBonus",
                                                                                    value: {
                                                                                    value: originalDiscount,
                                                                                    displayValue: originalDiscount
                                                                                    }
                                                                                    }
                                                                                    // 93656 Defect 20/8/19  ends
                                                                                    ];
                                                                                    }
                                                                                    console.log('remainingTermMobilityUpdate :: updateRemainingTermMap :: ', updateRemainingTermMap);
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, false).then();                                                
        
    }
});
}
else{
    var updateRemainingTermMap = {};
    updateRemainingTermMap[config.guid] = [{
        name: 'Remaining Term',
        value: {
            value: 0,
            displayValue: 0
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, false).then();                                                
}

}
/**************************************************************************************
             * Author	   : Mohammed Zeeshan Moulvi
             * Method Name : updateTotalPlanBonus
             * Description : EDGE -93036 - Issue with Payment Type fixed
             * Parameters  : Payment Type attibure
             **************************************************************************************/

async function updateTotalPlanBonus(guid,attribute){
    console.log('calculateMROBonusDiscount Purchase', guid);
    console.log('calculateMROBonusDiscount Purchase', attribute);
    
    if(attribute && attribute.displayValue && (attribute.displayValue === "Purchase" || attribute.displayValue === "")){
        var product;
        console.log(' Product ==><==', product);
        await CS.SM.getActiveSolution().then((p) => {
            product = p;
        }).then(
            () => Promise.resolve(true)
            );
            console.log('<== Product Details==>', product);
            if (product.type && product.name.includes(COMPONENT_NAMES.solution) && product.components && product.components.length > 0) {
            
            let componentList = product.components.filter((c) => {
            return c.name === COMPONENT_NAMES.mobileSubscription
        });
            
            if (componentList && componentList.length > 0) {
            let comp = componentList[0];
            console.log('Calculate TotalPlanBonus==>', comp);
            for (let i = 0; i < comp.schema.configurations.length; i++) {
            var mobilityConfig = comp.schema.configurations[i];
            console.log('Inside for TotalPlanBonus==>', comp);
            console.log('Inside for mobilityConfig==>', mobilityConfig);
            if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
            console.log('Inside Var TotalPlanBonus==>', comp);  
            var mDeviceConfigList = mobilityConfig.relatedProductList.filter((d) => {
            return d.guid === guid
        });
            console.log('Inside GUID TotalPlanBonus==>', comp);
            if (mDeviceConfigList && mDeviceConfigList.length > 0) {
            var updateMap = {};
            var updateMapRemainingTerm = {};
            updateMap[mobilityConfig.guid] = [{
            name: "TotalPlanBonus",
            value: {
                value: 0.00,
                displayValue: 0.00
            }
        },
                                             {
                                                 name: "Contract Term",
                                                 value: {
                                                     value: 0,
                                                     displayValue: 0
                                                 }
                                             },
                                             
                                             {
                                                 name: "ContractTermShadow",
                                                 value: {
                                                     value: 0,
                                                     displayValue: 0
                                                 }
                                             },
                                             {
                                                 name: "Remaining Term",
                                                 value: {
                                                     value: 0,
                                                     displayValue: 0
                                                 }
                                             }];          
                                             
                                             console.log('updateMap===>', updateMap);
        
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, false).then(res => console.log('updateTotalPlanBonus', res));                     
    }
}
}
}
}

}
}

/*CWPPlugin.afterConfigurationAdd = function (componentName, configuration) {
                console.log('After', componentName, configuration);
                return new Promise(function (res, rej) {
                    res(true);
                }).then(
                    () => addUserConfigurations()
                //).then(
                    //() => propagateContractTermToComponents()
                );
            
            }*/



/*
            CWPPlugin.buttonIframeClosed = function(dialogResult, buttonSettings) {
                console.log('buttonIframeClosed: id=', buttonSettings.id);
                console.log('dialogResult= ', dialogResult);
                if (buttonSettings.id === 'ScSelectSiteAddressBtn') {
                    addIpSites(1);
                }
                return Promise.resolve(true);
            };
            */

/**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : addIpSites
             * Invoked When: A message is received from Address Search VF page (after user selects addresses and clicks save)
             * Description : 1. Adds IP Site configurations
             * Parameters  : Site data for IP Site configurations to create
             **************************************************************************************/
function addIpSites(siteData) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('addIpSite', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        console.log('Components: ', product.components);
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        var updateMap = [];
        for (var i = 0; i < siteData.length; i++) {
        var sd = siteData[i];
        updateMap.push([{
        name: 'Site Name',
        value: {
            value: sd.siteName,
            displayValue: sd.siteName
        }
    },
                                   {
                                       name: 'Site Address',
                                       value: {
                                           value: sd.siteAddress,
                                           displayValue: sd.siteAddress
                                       }
                                   },
                                   {
                                       name: 'Site ID',
                                       value: {
                                           value: sd.siteId
                                       }
                                   },
                                   {
                                       name: 'AdborID',
                                       value: {
                                           value: sd.adborID
                                       }
                                   },
                                   {
                                       name: 'NBNAvailability',
                                       value: {
                                           value: sd.nbnAvailability
                                       }
                                   },
                                   {
                                       name: 'NBNRFSDate',
                                       value: {
                                           value: sd.nbnRFSDate
                                       }
                                   },
                                   {
                                       name: 'NBNTechnologyType',
                                       value: {
                                           value: sd.nbnTechnologyTypeAcrnym
                                       }
                                   },
                                   {
                                       name: 'MaxUploadSpeed',
                                       value: {
                                           value: sd.nbnMaxUploadSpeed
                                       }
                                   },
                                   {
                                       name: 'MaxDownloadSpeed',
                                       value: {
                                           value: sd.nbnMaxDownloadSpeed
                                       }
                                   },
                                   {
                                       name: 'SQVacantCopperPairs',
                                       value: {
                                           value: sd.copperPairIndicator
                                       }
                                   },
                                   {
                                       name: 'NBNCompatibility',
                                       value: {
                                           value: sd.nbnCompatibility
                                       }
                                   },
                                   {
                                       name: 'ServiceabilityClass',
                                       value: {
                                           value: sd.nbnServiceabilityClass
                                       }
                                   }
                                   ]);
}
CS.SM.addConfigurations(comp.name, updateMap).then((component) => {
    console.log("addConfigurations: ", component);
});
}
});
}
}
}).then(
    () => Promise.resolve(true)
    );
    
}
    
    /**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : updateIpSite
             * Invoked When: A message is received from Address Search VF page (after user Change Site Address)
             * Description : 1. Updates IP Site address with new one
             * Parameters  : Site data for IP Site configuration to update
             **************************************************************************************/
    function updateIpSite(siteData) {
    var updateMap = [];
    var sd = siteData[0];
    updateMap[sd.ipSiteconfigId] = [{
    name: 'Site Name',
    value: {
        value: sd.siteName,
        displayValue: sd.siteName
    }
},
                                                   {
                                                       name: 'Site Address',
                                                       value: {
                                                           value: sd.siteAddress,
                                                           displayValue: sd.siteAddress
                                                       }
                                                   },
                                                   {
                                                       name: 'Site ID',
                                                       value: {
                                                           value: sd.siteId
                                                       }
                                                   },
                                                   {
                                                       name: 'AdborID',
                                                       value: {
                                                           value: sd.adborID
                                                       }
                                                   },
                                                   {
                                                       name: 'NBNAvailability',
                                                       value: {
                                                           value: sd.nbnAvailability
                                                       }
                                                   },
                                                   {
                                                       name: 'NBNRFSDate',
                                                       value: {
                                                           value: sd.nbnRFSDate
                                                       }
                                                   },
                                                   {
                                                       name: 'NBNTechnologyType',
                                                       value: {
                                                           value: sd.nbnTechnologyTypeAcrnym
                                                       }
                                                   },
                                                   {
                                                       name: 'MaxUploadSpeed',
                                                       value: {
                                                           value: sd.nbnMaxUploadSpeed
                                                       }
                                                   },
                                                   {
                                                       name: 'MaxDownloadSpeed',
                                                       value: {
                                                           value: sd.nbnMaxDownloadSpeed
                                                       }
                                                   },
                                                   {
                                                       name: 'SQVacantCopperPairs',
                                                       value: {
                                                           value: sd.copperPairIndicator
                                                       }
                                                   },
                                                   {
                                                       name: 'NBNCompatibility',
                                                       value: {
                                                           value: sd.nbnCompatibility
                                                       }
                                                   },
                                                   {
                                                       name: 'ServiceabilityClass',
                                                       value: {
                                                           value: sd.nbnServiceabilityClass
                                                       }
                                                   }
                                                   ];
                                                   
                                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => {
    console.log('updateIpSite ', component);
    getConfiguredSiteIds();
    updateConfigurationsName();
});
    
}
    
    /**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : getConfiguredSiteIds
             * Invoked When: Adding new sites (need to filter out already selected sites)
             * Description : 1. Gets Site Id from already added IP Sites
             * Parameters  : NA
             **************************************************************************************/
    function getConfiguredSiteIds() {
    existingSiteIds.length = 0;
    CS.SM.getActiveSolution().then((currentSolution) => {
    if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
    if (currentSolution.components && currentSolution.components.length > 0) {
    currentSolution.components.forEach((comp) => {
    if (comp.name === COMPONENT_NAMES.ipSite) {
    existingSiteIds.length = 0;
    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
    comp.schema.configurations.forEach((config) => {
    console.log('config: ', config);
    var entry = {siteId: '', configId: config.id, guid: config.guid, adborID:''};
                                                                                                                                                                        config.attributes.forEach((attribute) => {
    if (attribute.name === "Site ID" && attribute.value) {
    entry.siteId = attribute.value;
    console.log('Site ID: ', attribute.value);
}
if (attribute.name === "AdborID" && attribute.value) {
    entry.adborID = attribute.value;
    console.log('adborID: ', attribute.value);
}
});
existingSiteIds.push(entry);
});
}
}
});
}
addrCheck();
}
}).then(
    () => Promise.resolve(true)
);
}

/*****************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateMACIpSite
             * Invoked When: A message is received from SCSQCheckPage (after user performs SQ Check on MAC IP SIte
             * Description : 1. Updates SQ Check for MAC IP Site
             * Parameters  : Site data for IP Site configuration to update
             ****************************************************************************************************/
function updateMACIpSite(sqResponsesData) {
    var updateMap = [];
    var sd = sqResponsesData[0];
    updateMap[sd.configGUID] = [{
        name: 'Site Name',
        value: {
            value: sd.siteName,
            displayValue: sd.siteName
        }
    },
                                {
                                    name: 'Site Address',
                                    value: {
                                        value: sd.siteAddress,
                                        displayValue: sd.siteAddress
                                    }
                                },
                                {
                                    name: 'Site ID',
                                    value: {
                                        value: sd.siteId
                                    }
                                },
                                {
                                    name: 'AdborID',
                                    value: {
                                        value: sd.adborID
                                    }
                                },
                                {
                                    name: 'NBNAvailability',
                                    value: {
                                        value: sd.nbnAvailability
                                    }
                                },
                                {
                                    name: 'NBNRFSDate',
                                    value: {
                                        value: sd.nbnRFSDate
                                    }
                                },
                                {
                                    name: 'NBNTechnologyType',
                                    value: {
                                        value: sd.nbnTechnologyTypeAcrnym
                                    }
                                },
                                {
                                    name: 'MaxUploadSpeed',
                                    value: {
                                        value: sd.nbnMaxUploadSpeed
                                    }
                                },
                                {
                                    name: 'MaxDownloadSpeed',
                                    value: {
                                        value: sd.nbnMaxDownloadSpeed
                                    }
                                },
                                {
                                    name: 'SQVacantCopperPairs',
                                    value: {
                                        value: sd.copperPairIndicator
                                    }
                                },
                                {
                                    name: 'NBNCompatibility',
                                    value: {
                                        value: sd.nbnCompatibility
                                    }
                                },
                                {
                                    name: 'ServiceabilityClass',
                                    value: {
                                        value: sd.nbnServiceabilityClass
                                    }
                                }
                               ];
    
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => {
        console.log('updateMACIpSite ', component);
    });
    }
        
        /**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : unreserveNumbers
             * Invoked When: Deleting IP site
             * Description : 1. Call remoteaction to unreserve reserved numbers
             * Parameters  : IP Site configuration
             **************************************************************************************/
                    function unreserveNumbers(configuration){
                    if (configuration.id){
                    console.log('Unreserve numbers for configuration:', configuration);
                    var inputMap = {};
                    inputMap["UnreserveNumbers"] = configuration.id;
                    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
                    console.log('Unreserve numbers finished: ', values);
                });
                }
                }
                    
                    /**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : updateReservedNumbers
             * Invoked When: Solution is loaded
             * Description : 1. Call remoteaction to get reserved numbers and upddate OE if needed
             * Parameters  : IP Site configuration
             **************************************************************************************/
                    function updateReservedNumbers(){
                    
                    console.log('Updating reserved numbers in OE');
                    
                    CS.SM.getActiveSolution().then((currentSolution) => {
                    if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
                    if (currentSolution.components && currentSolution.components.length > 0) {
                    //currentSolution.components.forEach((comp) => {
                    //if (comp.name === COMPONENT_NAMES.ipSite) {
                    var comp = currentSolution.components.filter(o => {return o.name === COMPONENT_NAMES.ipSite})[0];
                    var oeId;
                    comp.orderEnrichments.forEach((element) => {
                    if (element.name === 'NumberManagementv1') {
                    oeId = element.id;
                }
                });
                    
                    comp.schema.configurations.forEach((config) => {
                    if (config.id) {
                    var inputMap = {};
                    inputMap["GetReservedNumbers"] = config.id;
                    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
                    console.log('GetReservedNumbers finished with response: ', values);
                    var reservedNumbers = JSON.parse(values["GetReservedNumbers"]);
                    console.log('Numbers: ', reservedNumbers);
                    
                    //first delete all OE records not in reservedNumbers
                    CS.SM.getOrderEnrichmentList(COMPONENT_NAMES.ipSite, config.guid).then((oelist) => {
                    var oeDeleteList = [];
                    var oeExistingList = [];
                    if (oelist) {
                    oelist.forEach((oe) => {
                    if (oe.attributes) {
                    var attribute = oe.attributes.filter(obj => {return obj.name === 'FNN'});
                    if (attribute && attribute.length > 0) {
                    var rn = reservedNumbers.filter(o => {return o.FNN === attribute[0].value});
                    if (rn && rn.length>0) {
                    oeExistingList.push({guid:oe.guid, FNN:attribute[0].value});
            } else {
                oeDeleteList.push(oe.guid);
            }
}
}
});
}
if (oeDeleteList.length > 0) {
    console.log('deleteOrderEnrichments: ', config.guid, oeDeleteList);
    CS.SM.deleteOrderEnrichments(COMPONENT_NAMES.ipSite, config.guid, oeDeleteList);
} else {
    console.log('Updating reserved numbers in OE - nothing to delete in OE');
}


//second add new OE record from reservedNumbers but not if number already exists in OE (oeExistingList)
var map = [];
reservedNumbers.forEach(oeRn => {
    var rn1 = oeExistingList.filter(o => {return o.FNN == oeRn.FNN});
if (!rn1 || rn1.length <= 0)	{
    map.push({
        "FNN": oeRn.FNN,
        "rangeFrom": oeRn.rangeFrom,
        "rangeTo": oeRn.rangeTo,
        "status": oeRn.status,
        "listCode": oeRn.listCode
    });
}
});

if (map.length > 0) {
    console.log('addOrderEnrichments: ', config.guid, oeId, map);
    CS.SM.addOrderEnrichments(COMPONENT_NAMES.ipSite, config.guid, oeId, map);
} else {
    console.log('Updating reserved numbers in OE - nothing to add to OE');
}

});
});
}
});

}
}
});
}


/**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : detachAccountFromSite
             * Invoked When: Deleting IP site
             * Description : 1. Call remote action to detach accout from ip site
             * Parameters  : IP Site configuration
             **************************************************************************************/

function detachAccountFromSite(configuration){
    
    console.log('Detach account from site configuration:', configuration);
    
    var adborId;
    configuration.attributes.forEach((attribute) => {
        if (attribute.name === "AdborID" && attribute.value) {
        adborId = attribute.value;
    }
                                     });
    
    
    CS.SM.getActiveSolution().then((currentSolution) => {
        if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
        if (currentSolution.components && currentSolution.components.length > 0) {
        for (var k=0; k<currentSolution.components.length; k++) {
        var comp = currentSolution.components[k];
        if (comp.name === COMPONENT_NAMES.ipSite) {
        var adborIdCount = 0;
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        for (var i=0 ; i<config.attributes.length; i++) {
        if (config.attributes[i].name === "AdborID") {
        if ( config.attributes[i].value && adborId == config.attributes[i].value) {
        adborIdCount++;
    }
                                   break;
                                   }
                                   };
                                   });
}
if (adborIdCount == 0) {
    var inputMap = {};
    inputMap["DetachAccountFromSite"] = adborId;
    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
        console.log('Detach account from site  finished: ', values);
    });
    }
    }
        break;
    };
    }
    }
        
        console.log('Detach account from site finnished with checking: ', configuration.guid);
    });
        
        
    }
        
        function AddRecordsToNcJsonSchemaForNumberManagement(stringData, configId) {
        console.log('AddRecordsToNcJsonSchemaForNumberManagement', stringData, configId);
        if (stringData) {
        var data = JSON.parse(stringData);
        console.log('Deserialized json data: ', data);
        var configuration = existingSiteIds.filter(obj => {
        return obj.configId === configId
    });
        console.log('configuration', configuration);
        if (configuration && configuration[0] && configuration[0].guid && configuration[0].guid.length > 0) {
        CS.SM.getActiveSolution().then((currentSolution) => {
        if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
        if (currentSolution.components && currentSolution.components.length > 0) {
        //console.log('currentSolution: ', currentSolution);
        currentSolution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        comp.orderEnrichments.forEach((oe) => {
        if (oe.name == 'NumberManagementv1') {
        var map = [];
        data.forEach((ed) => map.push({
        "FNN": ed.FNN,
        "rangeFrom": ed.rangeFrom,
        "rangeTo": ed.rangeTo,
        "status": ed.status,
        "listCode": ed.listCode
    }));
    CS.SM.addOrderEnrichments(COMPONENT_NAMES.ipSite, configuration[0].guid, oe.id, map);
    
}
});
}
});
}
}
});
}
}
}

function RemoveRecordsFromNcJsonSchemaForNumberManagement(stringData, configId) {
    console.log('RemoveRecordsToNcJsonSchemaForNumberManagement', stringData);
    if (stringData) {
        var data = JSON.parse(stringData);
        console.log('Deserialized json data: ', data);
        var configuration = existingSiteIds.filter(obj => {
            return obj.configId === configId
        });
        console.log('configuration', configuration);
        if (configuration && configuration[0] && configuration[0].guid && configuration[0].guid.length > 0) {
            CS.SM.getOrderEnrichmentList("IP Site", configuration[0].guid).then((oelist) => {
                console.log("OE list ", oelist);
                var oeDeleteList = [];
                if (oelist) {
                oelist.forEach((oe) => {
                if (oe.attributes) {
                var attribute = oe.attributes.filter(obj => {
                return obj.name === 'FNN'
            });
                if (attribute && attribute.length > 0 && data.includes(attribute[0].value)) {
                oeDeleteList.push(oe.guid);
            }
            }
            });
            }
                if (oeDeleteList.length > 0) {
                console.log('RemoveRecordsToNcJsonSchemaForNumberManagement: ', oeDeleteList );
                CS.SM.deleteOrderEnrichments(COMPONENT_NAMES.ipSite, configuration[0].guid, oeDeleteList).then((c) => {console.log('RemoveRecordsToNcJsonSchemaForNumberManagement after delete:', c );});
            }
            });
            }
            }
            }
                
                /**************************************************************************************
             * Author	   : Mahaboob Basha, (modified by Tihomir Baljak)
             * Method Name : autoAddUserConfigurations
             * Invoked When: A Configuration is created against IP SITE component
             * Description : 1. Creates Fixed Seat Type User Configuration when an IP Site is added
             * Parameters  : config - IP Site configuration to add to user configuration
             **************************************************************************************/
                function autoAddUserConfigurations(config) {
                
                CS.SM.getActiveSolution().then((product) => {
                //console.log('Product');
                console.log('autoAddUserConfigurations', product);
                var siteNetworkZone;
                if (config && config.attributes) {
                config.attributes.forEach((ipSiteAttr) => {
                if (ipSiteAttr.name === 'SiteNetworkZone') {
                siteNetworkZone = ipSiteAttr.value;
            }
            });
            }
                if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                var userRelatedCompAvail = 'No';
                var userRelatedCompId;
                if (product.components && product.components.length > 0) {
                product.components.forEach((comp) => {
                if (comp.name === COMPONENT_NAMES.ipSite) {
                console.log('IP Site while adding same', comp);
                if (comp.relatedComponents && comp.relatedComponents.length > 0) {
                comp.relatedComponents.forEach((relatedComp) => {
                if (relatedComp.name === 'User') {
                userRelatedCompAvail = 'Yes';
                userRelatedCompId = relatedComp.id;
            }
            });
            }
                console.log('user component available', userRelatedCompAvail);
                console.log('userRelatedCompId', userRelatedCompId);
                if (userRelatedCompAvail === 'Yes') {
                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                //comp.schema.configurations.forEach((config) => {
                if (config.relatedProductList && config.relatedProductList.length < 1) {
                //var inputMap = {};
                //CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => CS.SM.addConfigurations('User', values["User"], true).then(comp => console.log('Pro Service Products : ' + comp)));
                
                CS.SM.addRelatedProduct(COMPONENT_NAMES.ipSite, config.guid, userRelatedCompId).then(configuration => {
                console.log('Newly Added User', configuration);
                if (configuration.relatedProductList && configuration.relatedProductList.length > 0) {
                configuration.relatedProductList.forEach((newConfig) => {
                if (newConfig.name === 'User' && newConfig.type === 'Related Component') {
                var inputMap = {};
                /*var existingUserType;
                                                                if (newConfig.configuration && newConfig.configuration.attributes && newConfig.configuration.attributes.length > 0) {
                                                                    newConfig.configuration.attributes.forEach((attr) => {
                                                                        if (attr.name === 'ListOfSelectedUser1') {
                                                                            existingUserType = attr.value;
                                                                        }
                                                                    });
                                                                }*/
                inputMap["siteNetworkZone"] =  siteNetworkZone;
                var updateMap = [];
                var typeUserId;
                
                CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => {
                //console.log('Remote Action Result : ' + values["User"]);
                updateMap[newConfig.guid] = values["User"];
                var remoteActionResult = values["User"];
                remoteActionResult.forEach((val) => {
                if (val.name === 'TypeUser') {
                typeUserId = val.value.value;
            }
            });
                //CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, userUpdateMap, true).then( component => console.log('User Update', component));
                updateMap[config.guid] = [{
                name: "ListOfSelectedUser",
                value: {
                    value: typeUserId.concat(","),
                    displayValue: typeUserId.concat(","),
                    readOnly: true,
                    required: false
                }
            }];
                                                                                CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('autoAddUserConfigurations Attribute update', component));
        });
    }
});
}
});
}
//});
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/**************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : autoAddManagedRouterConfigs
             * Invoked When: A Configuration is created against IP SITE component
             * Description : 1. Creates Managed Router Configuration when an IP Site is added
             * Parameters  : config - IP Site configuration to add to Managed Router configuration
             **************************************************************************************/
function autoAddManagedRouterConfigs(config) {
    
    CS.SM.getActiveSolution().then((product) => {
        //console.log('Product');
        console.log('autoAddManagedRouterConfigs', product, config);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var mRouterRelatedCompAvail = 'No';
        var mRouterRelatedCompId;
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while adding same', comp);
        if (comp.relatedComponents && comp.relatedComponents.length > 0) {
        comp.relatedComponents.forEach((relatedComp) => {
        if (relatedComp.name === 'Managed Router') {
        mRouterRelatedCompAvail = 'Yes';
        mRouterRelatedCompId = relatedComp.id;
    }
    });
    }
        console.log('Managed Router component available', mRouterRelatedCompAvail);
        console.log('mRouterRelatedCompId', mRouterRelatedCompId);
        if (mRouterRelatedCompAvail === 'Yes') {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        if (config.relatedProductList && config.relatedProductList.length < 1) {
        
        CS.SM.addRelatedProduct(COMPONENT_NAMES.ipSite, config.guid, mRouterRelatedCompId).then(configuration => {
        if (configuration.relatedProductList && configuration.relatedProductList.length > 0) {
        configuration.relatedProductList.forEach((newConfig) => {
        if (newConfig.name === 'Managed Router' && newConfig.type === 'Related Component') {
        var updateMap = [];
        updateMap[newConfig.guid] = [{
        name: "Default",
        value: {
            value: true,
            displayValue: true,
            readOnly: true,
            required: false
        }
    }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('autoAddManagedRouterConfigs Attribute update', component));
}
});
}
});
}
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/******************************************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateUserAndIPSiteConfigurations
             * Invoked When: User Type is selected in every USER configuration
             * Description : 1. Updates every User configuration with the list of user types selected in all user configurations per IP SIte
             *				 2. Updates IP Site configuration with the list of all user types selected in all user configurations against it
             * Parameters  : 1. String : guid of the configuration which invokes this method
             ******************************************************************************************************************************/
function updateUserAndIPSiteConfigurations(userGuid) {
    console.log('User guid', userGuid);
    CS.SM.getActiveSolution().then((product) => {
        //console.log('Product');
        console.log('updateUserAndIPSiteConfigurations', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating TypeUser on User', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        var ipSiteConfigGuid;
        var selectedTypeUser = '';
        var updateMap = [];
        comp.schema.configurations.forEach((ipSiteConfig) => {
        ipSiteConfigGuid = ipSiteConfig.guid;
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        /*if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === userGuid) {
                                                        ipSiteConfigGuid = relatedConfig.parentComponent;
                                                    }*/
        if (/*relatedConfig.parentComponent === ipSiteConfig.guid && */relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        if (userAttribute.name === 'TypeUser') {
        selectedTypeUser = selectedTypeUser.concat(userAttribute.value);
        selectedTypeUser = selectedTypeUser.concat(",");
    }
    });
    }
    });
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
        updateMap[relatedConfig.guid] = [{
        name: "ListOfSelectedUser1",
        value: {
            value: selectedTypeUser,
            displayValue: selectedTypeUser,
            readOnly: true,
            required: false
        }
    }];
                                   }
                                   });
}
});
if (ipSiteConfigGuid) {
    updateMap[ipSiteConfigGuid] = [{
        name: "ListOfSelectedUser",
        value: {
            value: selectedTypeUser,
            displayValue: selectedTypeUser,
            readOnly: true,
            required: false
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateUserAndIPSiteConfigurations Attribute Update', component));
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/********************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateExistingTypesOnUserConfig
             * Invoked When: A configuration is created against USER component
             * Description : 1. Updates the newly created User configuration with the details from its parent IP SIte
             * Parameters  : 1. String : configuration which invokes this method
             *******************************************************************************************************/
function updateExistingTypesOnUserConfig(config) {
    console.log('User Config', config);
    CS.SM.getActiveSolution().then((product) => {
        //console.log('Product');
        console.log('updateExistingTypesOnUserConfig', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while adding User Config', comp);
        /*if (comp.relatedComponents && comp.relatedComponents.length > 0) {
                                        comp.relatedComponents.forEach((relatedComp) => {
                                            if (relatedComp.name === 'User' && relatedComp.type === 'Related Component') {
                                                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            
                                                }
                                            }
                                        });
                                    }*/
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    var ipSiteConfigGuid;
                    var selectedTypeUserFromParent = '';
                    var siteNetworkZone;
                    var updateMap = [];
                    comp.schema.configurations.forEach((ipSiteConfig) => {
                    ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
                    if (ipSiteAttribute.name === 'ListOfSelectedUser') {
                    selectedTypeUserFromParent = ipSiteAttribute.value;
                }
                    if (ipSiteAttribute.name === 'SiteNetworkZone') {
                    siteNetworkZone = ipSiteAttribute.value;
                }
                });
                    console.log('selectedTypeUserFromParent', selectedTypeUserFromParent);
                    console.log('SiteNetworkZone', siteNetworkZone);
                    if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
                    ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === config.guid) {
                    updateMap[config.guid] = [{
                    name: "ListOfSelectedUser1",
                    value: {
                        value: selectedTypeUserFromParent,
                        displayValue: selectedTypeUserFromParent,
                        readOnly: true,
                        required: false
                    }
                },
                                               {
                                                   name: "ZonefromParent",
                                                   value: {
                                                       value: siteNetworkZone,
                                                       displayValue: siteNetworkZone,
                                                       readOnly: true,
                                                       required: false
                                                   }
                                               }];
                                               CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateExistingTypesOnUserConfig Attribute Update', component));
            }
});
}

});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/******************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateFixedSeatUserQtyOnBandwidthConfig
             * Invoked When: A configuration is created against BANDWIDTH CLIP ON component
             * Description : 1. Updates the Fixed Seat User Quantity on this newly created configuration
             * Parameters  : 1. String : configuration which invokes this method
             ******************************************************************************************/
function updateFixedSeatUserQtyOnBandwidthConfig(config) {
    console.log('Bandwidth Config', config);
    CS.SM.getActiveSolution().then((product) => {
        console.log('updateFixedSeatUserQtyOnBandwidthConfig', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while adding Bandwidth Config', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var fixedSeatUserQty;
        var fixedSeatAttr = 'No';
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' /*&& relatedConfig.parentComponent === config.parentComponent*/) {
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        console.log('', userAttribute.name, userAttribute.displayValue, userAttribute.value);
        if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
        console.log('Inside TypeUser Attribute');
        fixedSeatAttr = 'Yes';
    }
        console.log('fixedSeatAttr', fixedSeatAttr);
        console.log('condition', (fixedSeatAttr === 'Yes' && userAttribute.name === 'Quantity'));
        if (fixedSeatAttr === 'Yes' && userAttribute.name === 'Quantity') {
        console.log('Fixed Seat User Quantity', userAttribute.value);
        fixedSeatUserQty = userAttribute.value;
    }
    });
    }
        if (relatedConfig.name === 'Bandwidth Clip On' && relatedConfig.type === 'Related Component' && relatedConfig.guid === config.guid) {
        console.log('fixedSeatUserQty', fixedSeatUserQty);
        if (fixedSeatUserQty) {
        var updateMap = [];
        updateMap[config.guid] = [{
        name: "User Quantity",
        value: {
            value: fixedSeatUserQty,
            displayValue: fixedSeatUserQty,
            readOnly: true,
            required: false
        }
    }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateFixedSeatUserQtyOnBandwidthConfig Attribute Update', component));
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
}).then(
    () => Promise.resolve(true)
);
}


/*******************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateFixedSeatUserQtyOnBWQAndIPSiteConfig2
             * Invoked When: Fixed Seat User Quantity is changed
             * Description : 1. Updates the Fixed Seat User Quantity on Bandwdith Clip On and IP Site Configs
             * Parameters  : 1. String : configuration guid of Quantity attr whose value changes invokes this method
             *			   : 2. String : Quantity value
             ******************************************************************************************************/
function updateFixedSeatUserQtyOnBWQAndIPSiteConfig2(guid, quantity) {
    console.log('User Config', guid);
    CS.SM.getActiveSolution().then((product) => {
        console.log('updateFixedSeatUserQtyOnBWQAndIPSiteConfig2', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating User Quantity 2', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        var fixedSeatUserQty;
        var bandwidthConfigGUID;
        var ipSiteConfigGUID;
        comp.schema.configurations.forEach((ipSiteConfig) => {
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        var fixedSeatAttr = false;
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        console.log('', userAttribute.name, userAttribute.displayValue, userAttribute.value);
        if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
        console.log('Inside TypeUser Attribute');
        fixedSeatAttr = true;
        ipSiteConfigGUID = ipSiteConfig.guid;
    }
    });
    }
        console.log('fixedSeatAttr', fixedSeatAttr);
        if (fixedSeatAttr && relatedConfig.name === 'Bandwidth Clip On' && relatedConfig.type === 'Related Component') {
        bandwidthConfigGUID = relatedConfig.guid;
    }
    });
    }
    });
        console.log('bandwidthConfigGUID', bandwidthConfigGUID);
        if (bandwidthConfigGUID) {
        var updateMap = [];
        updateMap[bandwidthConfigGUID] = [{
        name: "User Quantity",
        value: {
            value: quantity,
            displayValue: quantity,
            readOnly: true,
            required: false
        }
    }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateFixedSeatUserQtyOnBWQAndIPSiteConfig2 BW Attribute Update', component));
}
console.log('ipSiteConfigGUID', ipSiteConfigGUID);
if (ipSiteConfigGUID) {
    var updateMap = [];
    updateMap[ipSiteConfigGUID] = [{
        name: "CountTotalUserQty",
        value: {
            value: quantity,
            displayValue: quantity,
            readOnly: true,
            required: false
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, false).then(component => console.log('updateFixedSeatUserQtyOnBWQAndIPSiteConfig2 IP Site Attribute Update', component));
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/*******************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : controlHandSetTypeAndModel
             * Invoked When: Model attribute is updated on HANDSET AND ACCESSORIES component
             * Description : 1. Marks the configuration invalid if same Handset Type and Model exists
             * Parameters  : 1. String : guid of the configuration whose Model attribute is being updated
             *******************************************************************************************/
function controlHandSetTypeAndModel(guid) {
    // let product = CS.SM.getActiveSolution();
    // console.log('controlHandSetTypeAndModel', product, guid);
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating Handset Model in controlHandSetTypeAndModel', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var currIpSiteConfigGUID;
        var currHandsetType;
        var currHandsetModel;
        var typeAndModelMatched = false;
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        currIpSiteConfigGUID = ipSiteConfig.guid;
        relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
        if (handsetAttribute.name === 'HandsetandAccessoriesType') {
        currHandsetType = handsetAttribute.value;
    }
                                   if (handsetAttribute.name === 'HandsetandAccessoriesModel') {
        currHandsetModel = handsetAttribute.value;
    }
});
}
});
var typeMatched = false;
var modelMatched = false;
ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
    if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid !== guid && ipSiteConfig.guid === currIpSiteConfigGUID &&
    (!basketChangeType || (basketChangeType  && !relatedConfig.id))) {
    relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
    if (handsetAttribute.name === 'HandsetandAccessoriesType' && handsetAttribute.value === currHandsetType) {
    typeMatched = true;
}
                                        if (typeMatched && handsetAttribute.name === 'HandsetandAccessoriesModel' && handsetAttribute.value === currHandsetModel) {
    modelMatched = true;
}
});
if (typeMatched && modelMatched) {
    typeAndModelMatched = true;
    statusMsg = ipSiteConfig.statusMessage;
}
}
});
}
/*if (typeAndModelMatched) {
                                                statusMsg = statusMsg ? statusMsg : '';
                                                statusMsg = statusMsg ? statusMsg + ',\n' + 'Duplicate Type and Model selected' : 'Duplicate Type and Model selected';
                                                CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, ipSiteConfigGUID, false, statusMsg).then(configuration => console.log(configuration));
                                                //CS.SM.updateConfigurationStatus('Handset and Accessories', guid, false, 'Duplicate Type and Model selected').then( configuration => console.log(configuration) );
                                            }*/

updateConfigurationStatus('IPSITE_HA_DTMS',COMPONENT_NAMES.ipSite, guid, typeAndModelMatched===false, 'Duplicate Type and Model selected');

});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);

}


/****************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : makeWFCodeMandatoryOrOptional
             * Invoked When: Quantity on User Component is updated
             * Description : 1. Marks the Widefeas Code Optional/Mandatory based on Fixed Seat Type User Quantity
             * Parameters  : 1. String : guid of the configuration whose Quantity attribute is being updated
             ***************************************************************************************************/
function makeWFCodeMandatoryOrOptional(guid) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('makeWFCodeMandatoryOrOptional', product, guid);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating User Quantity 1', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        var existingWFCode;
        comp.schema.configurations.forEach((ipSiteConfig) => {
        ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
        if (ipSiteAttribute.name === 'Widefeas Code') {
        existingWFCode = ipSiteAttribute.value;
    }
    });
        console.log('existingWFCode', existingWFCode);
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        
        /* commented
                                                var isWFCodeVisible = false;
                                                ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
                                                    console.log('ipSiteAttribute', ipSiteAttribute.name, ipSiteAttribute.displayValue, ipSiteAttribute.value);
                                                    if (ipSiteAttribute.name === 'Widefeas Code' && ipSiteAttribute.showInUi === true) {
                                                        isWFCodeVisible = true;
                                                    }
                                                });
                                                */
                    
                    ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
                    var fixedSeatAttr = false;
                    var makeWFCodeMandatory = false;
                    if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
                    relatedConfig.configuration.attributes.forEach((userAttribute) => {
                    console.log('userAttribute', userAttribute.name, userAttribute.displayValue, userAttribute.value);
                    if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
                    fixedSeatAttr = true;
                }
                    if (fixedSeatAttr && userAttribute.name === 'Quantity' && userAttribute.value >= 18) {
                    makeWFCodeMandatory = true;
                }
                });
                    // commented
                    //if (fixedSeatAttr && isWFCodeVisible) {
                    if (fixedSeatAttr) {
                    statusMsg = ipSiteConfig.statusMessage;
                    var updateMap = [];
                    updateMap[ipSiteConfig.guid] = [{
                    name: "Widefeas Code",
                    value: {
                        value: existingWFCode,
                        displayValue: existingWFCode,
                        readOnly: false,
                        required: makeWFCodeMandatory
                    }
                }];
                                               CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('makeWFCodeMandatoryOrOptional Attribute Update', component));
            }
}
});
}
statusMsg = statusMsg ? statusMsg : '';
if (existingWFCode) {
    var validFormat = /^(WF-[0-9]{6})$/;
    if (validFormat.test(existingWFCode)) {
        //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, true, statusMsg).then(configuration => console.log(configuration));
        updateConfigurationStatus('IPSITE_WF_VALIDATION',COMPONENT_NAMES.ipSite, guid, true, '');
    } else {
        statusMsg = statusMsg ? statusMsg + ',\n' + 'Enter the Widefeas Code in the format WF-000000' : 'Enter the Widefeas Code in the format WF-000000';
        //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, false, statusMsg).then(configuration => console.log(configuration));
        updateConfigurationStatus('IPSITE_WF_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, 'Enter the Widefeas Code in the format WF-000000');
    }
}
});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/***********************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : showQuantityErrorMessages
             * Invoked When: Quantity is updated
             * Description : 1. Marks the Configurations with appropriate messages based on Quantity value
             * Parameters  : 1. String : guid of the configuration whose Quantity attribute is being updated
             **********************************************************************************************/
function showQuantityErrorMessages(guid) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('showQuantityErrorMessages', product, guid);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating Quantity in showQuantityErrorMessages', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        var existingWFCode;
        comp.schema.configurations.forEach((ipSiteConfig) => {
        //var msg = ipSiteConfig.statusMessage;
        var msg = '';
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        var fixedSeatAttr = false;
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        console.log('userAttribute', userAttribute.name, userAttribute.displayValue, userAttribute.value);
        if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
        fixedSeatAttr = true;
    }
        if (fixedSeatAttr && userAttribute.name === 'Quantity') {
        if (userAttribute.value < 1) {
        msg = 'Quantity should be greater than 0';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_FS_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
    }
        else if (userAttribute.value > 0 && userAttribute.value < 3) {
        msg = 'The Connected Workplace Offer requires a minimum of 3 Fixed Seats';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_FS_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
        
    }
        else if (userAttribute.value > 2 && userAttribute.value < 132) {
        msg = '';
        //CS.SM.updateConfigurationStatus('IP Site', guid, true, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_FS_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, true, msg);
    }
        else if (userAttribute.value > 131) {
        msg = 'The Connected Workplace Offer only supports a maximum of 131 Fixed Seats, please reduce the number of Fixed Seats.';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, 'The Connected Workplace Offer only supports a maximum of 131 Fixed Seats, please reduce the number of Fixed Seats.').then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_FS_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
    }
    }
    });
    }
        if (relatedConfig.name === 'Hunt Group' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        relatedConfig.configuration.attributes.forEach((huntGrpAttribute) => {
        console.log('huntGrpAttribute', huntGrpAttribute.name, huntGrpAttribute.displayValue, huntGrpAttribute.value);
        if (huntGrpAttribute.name === 'Quantity') {
        if(huntGrpAttribute.value < 1) {
        msg = 'Quantity should be greater than 0';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_HG_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
    }
        else {
        msg = '';
        //CS.SM.updateConfigurationStatus('IP Site', guid, true, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_HG_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, true, msg);
    }
    }
    });
    }
        if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
        console.log('handsetAttribute', handsetAttribute.name, handsetAttribute.displayValue, handsetAttribute.value);
        if (handsetAttribute.name === 'Quantity') {
        if(handsetAttribute.value < 1) {
        msg = 'Quantity should be greater than 0';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_HA_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
    }
        else {
        msg = '';
        //CS.SM.updateConfigurationStatus('IP Site', guid, true, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_HA_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, true, msg);
    }
    }
    });
    }
        if (relatedConfig.name === 'IAD Device' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        relatedConfig.configuration.attributes.forEach((iadAttribute) => {
        console.log('iadAttribute', iadAttribute.name, iadAttribute.displayValue, iadAttribute.value);
        if (iadAttribute.name === 'Quantity') {
        if(iadAttribute.value < 1) {
        msg = 'Please chose at least one IAD Device';
        //CS.SM.updateConfigurationStatus('IP Site', guid, false, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_IAD_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, false, msg);
    }
        else {
        msg = '';
        //CS.SM.updateConfigurationStatus('IP Site', guid, true, msg).then(configuration => console.log('showQuantityErrorMessages Configuration Status Update', configuration));
        updateConfigurationStatus('IPSITE_IAD_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, guid, true, msg);
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
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        
        /***********************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : makeIADDeviceMandatory
             * Invoked When: Type on User Component is updated
             * Description : 1. Marks the IPSite Config valid/invalid & shows message if Fax Line user is selected
             * Parameters  : 1. String : guid of the User configuration whose Type attribute is being updated
             ***********************************************************************************************/
                    function makeIADDeviceMandatory() {
                    //CS.SM.updateComponentQuantity('IAD Device', {min: 1 , max: 9999}).then( component => console.log(component));
                    CS.SM.getActiveSolution().then((product) => {
                    console.log('makeIADDeviceMandatory', product);
                    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                    var userConfigGUID;
                    var statusMsg;
                    if (product.components && product.components.length > 0) {
                    product.components.forEach((comp) => {
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    console.log('IP Site while updating Fax Line User', comp);
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    comp.schema.configurations.forEach((ipSiteConfig) => {
                    if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
                    
                    var rpIad = ipSiteConfig.relatedProductList.filter(obj => {return obj.name === 'IAD Device' && obj.type === 'Related Component'});
                    
                    var rpUser = ipSiteConfig.relatedProductList.filter(obj => {return obj.name === 'User' && obj.type === 'Related Component'});
                    if (rpUser && rpUser.length > 0) {
                    for (var i=0; i<rpUser.length; i++) {
                    var typeUserAttribute = rpUser[i].configuration.attributes.filter(obj =>{return (obj.name === 'TypeUser' && obj.displayValue==='Fax Line')});
                    
                    var message ='';
                    var valid = true;
                    
                    if (typeUserAttribute && typeUserAttribute.length>0 && (!rpIad || rpIad.length === 0)) {
                    message ='Please choose at least one IAD Device';
                    valid = false;
                }
                    
                    //CS.SM.updateConfigurationStatus('User', rpUser[i].guid, valid, message).then( configuration => console.log(configuration) );
                    updateConfigurationStatus('USER_IAD_VALIDATION','User', rpUser[i].guid, valid, message);
                }
                }
                }
                });
                }
                }
                });
                }
                }
                }).then(
                    () => Promise.resolve(true)
                    );
                }
                    
                    /***********************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : validateWFCodeFormat
             * Invoked When: Widefeas Code attribute is updated with a value on IP Component
             * Description : 1. Marks the IPSite Config invalid & shows message if WF Code format is not valid
             * Parameters  : 1. String : guid of the User configuration whose Type attribute is being updated
             *				 2. String : value of the attribute to be validated Regex : ^(WF-[0-9]{6})$
             *				 3. Boolean: flag specifying whether the attribute is required or not
             ***********************************************************************************************/
                    function validateWFCodeFormat(guid, attrValue, isRequired,componentName) {
                    var validFormat = /^(WF-[0-9]{6})$/;
                    CS.SM.getActiveSolution().then((product) => {
                    console.log('validateWFCodeFormat', guid, attrValue, isRequired,componentName);
                    if (product.type && (product.name.includes(COMPONENT_NAMES.solution) || product.name.includes(TID_COMPONENT_NAMES.solution))) {
                    var statusMsg;
                    if (product.components && product.components.length > 0) {
                    product.components.forEach((comp) => {
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    console.log('IP Site while updating Wifefeas Code', comp);
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    comp.schema.configurations.forEach((ipSiteConfig) => {
                    if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
                    ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
                    statusMsg = ipSiteConfig.statusMessage;
                }
                });
                }
                });
                }
                }
                });
                }
                    statusMsg = statusMsg ? statusMsg : '';
                    var compname =  (componentName === COMPONENT_NAMES.ipSite) ? COMPONENT_NAMES.ipSite : TID_COMPONENT_NAMES.internetSite;
                    if (attrValue) {
                    if (validFormat.test(attrValue)) {
                    //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, true, statusMsg).then(configuration => console.log(configuration));
                    
                    updateConfigurationStatus('IPSITE_WF_VALIDATION',compname, guid, true, '');
                } else {
                                               //statusMsg = statusMsg ? statusMsg + ',\n' + 'Enter the Widefeas Code in the format WF-000000' : 'Enter the Widefeas Code in the format WF-000000';
                                               //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, false, statusMsg).then(configuration => console.log(configuration));
                                               updateConfigurationStatus('IPSITE_WF_VALIDATION',compname, guid, false, 'Enter the Widefeas Code in the format WF-000000');
            }
} else {
    //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, true, statusMsg).then(configuration => console.log(configuration));
    updateConfigurationStatus('IPSITE_WF_VALIDATION',compname, guid, true, '');
}
}
}).then(
    () => Promise.resolve(true)
);
}

/****************************************************************************************************
             * Author	   : Malvika Sharma
             * Method Name : addrCheck
             * Invoked When:
             * Description :
             * Parameters  :
             ***************************************************************************************************/

function addrCheck() {
    
    console.log('addrCheck called:', existingSiteIds);
    if (existingSiteIds.length == 0)
        return;
    var counts = [];
    var hasDuplicates = false;
    for (var i = 0; i < existingSiteIds.length; i++) {
        if (counts[existingSiteIds[i].adborID] != undefined) {
            counts[existingSiteIds[i].adborID] = counts[existingSiteIds[i].adborID] + 1;
            hasDuplicates = true;
        } else {
            counts[existingSiteIds[i].adborID] = 1;
        }
    }
    
    console.log('hasDuplicates: ', hasDuplicates);
    
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        for (var j = comp.schema.configurations.length - 1; j >= 0; j--) {
        var config = comp.schema.configurations[j];
        var valid = true;
        var msg = config.statusMessage;
        for (var k = 0; k < existingSiteIds.length; k++) {
        if (counts[existingSiteIds[k].adborID] != undefined && counts[existingSiteIds[k].adborID] > 1) {
        for (var l=0; l<config.attributes.length; l++) {
        var attribute = config.attributes[l];
        if (attribute.name === "AdborID" && attribute.value && attribute.value == existingSiteIds[k].adborID) {
        counts[existingSiteIds[k].adborID] = counts[existingSiteIds[k].adborID]  - 1;
        valid = false;
        break;
    }
                                   };
                                   }
                                   if (!valid) break;
}
//msg = msg ? msg + ',\n' + 'The site address already exists. Please update the address.' : 'The site address already exists. Please update the address.'
//CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, config.guid, valid, msg).then(configuration => console.log(configuration));
updateConfigurationStatus('IPSITE_ADDRESS_CHECK',COMPONENT_NAMES.ipSite, config.guid, valid, 'The site address already exists. Please update the address.');
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/***********************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateZoneOnUserConfigurations
             * Invoked When: SiteNetworkZone is updated on IP Site
             * Description : 1. updates the zone into its user configurations
             * Parameters  : 1. guid of IP Site Config
             *				 2. newValue of SiteNetworkZone
             ***********************************************************************************************/
function updateZoneOnUserConfigurations(guid, attrValue) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('updateZoneOnUserConfigurations', product, guid, attrValue);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var updateMap = [];
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating SiteZetworkZone', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        if (ipSiteConfig.guid === guid && ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
        updateMap[relatedConfig.guid] = [{
        name: "ZonefromParent",
        value: {
            value: attrValue,
            displayValue: attrValue,
            readOnly: true,
            required: false
        }
    }];
                                   }
                                   });
}
});
}
}
});
}
if (updateMap) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, false).then(component => console.log('updateZoneOnUserConfigurations Attribute Update', component));
}
}
}).then(
    () => Promise.resolve(true)
);
}

/***********************************************************************************************
             * Author	   : Mate Dzelalija
             * Method Name : IADPortsFaxQuantityValidation
             * Invoked When: After attribute change & Solution is Loaded
             * Description : validation - sum of Fax line Qunatity has to be less then sum of IAD Device Available Ports
             * Parameters  : none
             ***********************************************************************************************/

function IADPortsFaxQuantityValidation () {
    
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site validation: Sum of IAD AvailablePorts >= Fax Line Quantity.',comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var sumAvailablePorts = 0;
        var sumFaxlineQuantity = 0;
        var validationRelatedGuids = [];
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        // sum all Fax line quantities per configuration
        var UserTypeRelatedList =  ipSiteConfig.relatedProductList.filter(obj => {return obj.name === 'User' && obj.type === 'Related Component'});
    for (let i = 0; i < UserTypeRelatedList.length; i++) {
        var typeUserAttribute = UserTypeRelatedList[i].configuration.attributes.filter(obj =>{return obj.name === 'TypeUser'});
        if (typeUserAttribute[0].displayValue === 'Fax Line') {
            let quantity = UserTypeRelatedList[i].configuration.attributes.filter(obj =>{return obj.name === 'Quantity'});
            validationRelatedGuids.push(UserTypeRelatedList[i].guid);
            sumFaxlineQuantity = parseInt(sumFaxlineQuantity) + parseInt(quantity[0].displayValue);
        }
    }
    // sum all IADDevice AvailablePorts per configuration
    var IADDeviceRelatedList = ipSiteConfig.relatedProductList.filter(obj => {return obj.name === 'IAD Device' && obj.type === 'Related Component'});
    for (let i = 0; i < IADDeviceRelatedList.length; i++) {
        let quantity = IADDeviceRelatedList[i].configuration.attributes.filter(obj =>{return obj.name === 'Quantity'});
        validationRelatedGuids.push(IADDeviceRelatedList[i].guid);
        let availablePorts = IADDeviceRelatedList[i].configuration.attributes.filter(obj =>{return obj.name === 'AvailablePorts'});
        sumAvailablePorts = parseInt(sumAvailablePorts) + (quantity[0].value * availablePorts[0].value);
    }
    console.log('ruleID: IPSITE_IADPORTSQTY_VALIDATION: '+ 'sumFaxlineQuantity=', sumFaxlineQuantity, ' sumAvailablePorts=',sumAvailablePorts);
    var message;
    
    if(isNaN(sumFaxlineQuantity)) sumFaxlineQuantity = 0;
    if(isNaN(sumAvailablePorts)) sumAvailablePorts = 0;
    
    if (sumFaxlineQuantity<=sumAvailablePorts){
        message = '';
    }else{
        
        //EDGE-103242 Uncommented below line - Multiple Looks up were causing the value of available ports coming as zero - which is rersolved
        message = 'Sum of Fax Lines can not be greater then sum of IAD Device Available ports'; 
    }
    
    for (let i = 0; i < validationRelatedGuids.length; i++){
        updateConfigurationStatus('IPSITE_IAD_VALIDATION',COMPONENT_NAMES.ipSite, validationRelatedGuids[i], sumFaxlineQuantity<=sumAvailablePorts, message);
    }
}

});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);


}


/***********************************************************************************************
             * Author	   : Mate Dzelalija
             * Method Name : validateOE
             * Invoked When: Solution is Loaded & before Save
             * Description : ValidateOE in case Basket Stage = 'Contract Accepted'
             * Parameters  : None
             ***********************************************************************************************/
function validateOE () {
    
    console.log('validating OE');
    
    let inputMap = {};
    let basketId = CS.SM.getCurrentBasketId().__zone_symbol__value;
    inputMap['basketId'] = basketId;
    
    
    CS.SM.WebService.performRemoteAction('SolutionGetBaskeData', inputMap).then(
        function(response) {
            console.log(' ValidateOE Response', response);
            //console.log(response.basket.Id);
            //console.log(response.basket.csordtelcoa__Basket_Stage__c);
            if (response && response.basket != undefined) {
                if (response.basket.csordtelcoa__Basket_Stage__c === 'Contract Accepted') {
                    console.log('Validating OE');
                }
            }
        })
    
    
    
    CS.SM.getActiveSolution().then((solution) => {
        
        console.log('Validate OE - Solution:',solution);
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        
        if (comp.name === COMPONENT_NAMES.ipSite) {
        var ipsiteUpdateMap = [];
        console.log('ValidateOE', comp.schema.configurations );
        
        /*
                                    comp.schema.configurations.forEach((ipSiteConfig) => {
                                        var makeWFCodeRedaonly = false;
                                        ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
                                            if (ipSiteAttribute.name === 'Widefeas Code' && ipSiteAttribute.value) {
                                                ipsiteUpdateMap[ipSiteConfig.guid] = [{
                                                    name: "Widefeas Code",
                                                    value: {
                                                        readOnly: true,
                                                    }
                                                }];
            
                                            }
                                        });
                                    });
            
                                    if (ipsiteUpdateMap) {
                                        console.log('checkMACDBusinessRules');
                                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, ipsiteUpdateMap, true).then(component => console.log('checkAllBusinessRules IP SiteAttribute Update', component));
                                    }
                                */
                    
                }
                    
                    
                });
                }
                }
                    
                    
                }).then(
                    () => Promise.resolve(true)
                    );
                    
                    
                }
                    
                    
                    /***********************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : checkAllBusinessRules
             * Invoked When: Solution is Loaded
             * Description : 1. Marks the Configs invalid & shows message if business rules are not satisfied
             * Parameters  : None
             ***********************************************************************************************/
                    function checkAllBusinessRules() {
                    
                    updateWidefeasCodeAndCategoryVisibility ();
                    updateNBNCompatibility();
                    updateTelstraFibreCompatibility();
                    IADPortsFaxQuantityValidation();
                    
                    var messageMap = new Map();
                    CS.SM.getActiveSolution().then((product) => {
                    console.log('checkAllBusinessRules');
                    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                    var ipSiteConfigGUID;
                    var firstHandsetInfo;
                    var ipSiteConfigInfo;
                    var firstHandsetGUID;
                    var firstHandsetType;
                    var firstHandsetModel;
                    var typeAndModelMatched = false;
                    var updateMap = [];
                    var existingWFCode;
                    if (product.components && product.components.length > 0) {
                    product.components.forEach((comp) => {
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    console.log('IP Site after loading solution', comp);
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    //comp.schema.configurations.forEach((ipSiteConfig) => {
                    var ipSiteConfig = comp.schema.configurations[0];
                    ipSiteConfigInfo = new Object();
                    ipSiteConfigInfo.guid = ipSiteConfig.guid;
                    ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
                    if (ipSiteAttribute.name === 'Site ID') {
                    ipSiteConfigInfo.siteId = ipSiteAttribute.value;
                }
                });
                    //});
                    comp.schema.configurations.forEach((ipSiteConfig) => {
                    //var msg = ipSiteConfig.statusMessage;
                    var makeWFCodeMandatory = false;
                    ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
                    if (ipSiteAttribute.name === 'Widefeas Code') {
                    existingWFCode = ipSiteAttribute.value;
                }
                    if (ipSiteAttribute.name === 'Widefeas Code' && ipSiteAttribute.value) {
                    var validFormat = /^(WF-[0-9]{6})$/;
                    if (!validFormat.test(ipSiteAttribute.value)) {
                    //msg = msg ? msg + ',\n' + 'Enter the Widefeas Code in the format WF-000000' : 'Enter the Widefeas Code in the format WF-000000';
                    updateConfigurationStatus('IPSITE_WF_VALIDATION',COMPONENT_NAMES.ipSite, ipSiteConfig.guid, false, 'Enter the Widefeas Code in the format WF-000000');
                } else {
                    updateConfigurationStatus('IPSITE_WF_VALIDATION',COMPONENT_NAMES.ipSite, ipSiteConfig.guid, true, '');
                }
                }
                    //08-05-19, LT, Added to fetch IR value from PC
                    if (ipSiteAttribute.name === 'IR') {
                    console.log('IP Site IR:', ipSiteConfig);
                    if (typeof ipSiteConfig.id !== "undefined" && ipSiteConfig.id !== null) {
                    let inputMap = {};
                    inputMap['GetPCData'] = ipSiteConfig.id;
                    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                    console.log('GetPCData finished with response: ', result);
                    var pcDataStr = result["GetPCData"];
                    if (pcDataStr &&  pcDataStr.length > 0) {
                    let pcData = JSON.parse(pcDataStr);
                    console.log('GetPCData IR: ' + pcData.Incremental_Revenue__c);
                    
                    if (isNaN(pcData.Incremental_Revenue__c) === false && pcData.Incremental_Revenue__c != 0) {
                    updateMap[ipSiteConfig.guid] = [{
                    name: "IR",
                    value: {
                        value: Number.parseFloat(pcData.Incremental_Revenue__c).toFixed(2),
                        displayValue: Number.parseFloat(pcData.Incremental_Revenue__c).toFixed(2)
                    }
                }];
                                               CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('checkAllBusinessRules Attribute Update', component));
            }
}
});
}
}
});
if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
    ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        /*
                                                    if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
                                                        var fixedSeatAttr = false;
                                                        var faxLineAttr;
                                                        var faxLineQty;
                                                        var iadQuantityValid = true;
                                                        relatedConfig.configuration.attributes.forEach((userAttribute) => {
                                                            console.log('userAttribute', userAttribute.name, userAttribute.displayValue, userAttribute.value);
            
            
            
                                                            if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fixed Seat') {
                                                                fixedSeatAttr = true;
                                                            }
                                                            if (fixedSeatAttr && userAttribute.name === 'Quantity' && userAttribute.value > 4) {
                                                                makeWFCodeMandatory = true;  // ######this logic-interdependancy is handled in updateWidefeasCodeAndCategoryVisibility  ######
                                                            }
                                                            if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fax Line') {
                                                                faxLineAttr = true;
                                                            }
                                                            if (faxLineAttr && userAttribute.name === 'Quantity' && userAttribute.value > 4) {
                                                                faxLineQty = userAttribute.value;
                                                                //msg = msg ? msg + ',\n' + 'Please chose at least one IAD Device' : 'Please chose atleast one IAD Device';
                                                                iadQuantityValid = false;  // ######## this logic is handled in function makeIADDeviceMandatory()  #########
                                                            }
                                                        });
                                                        updateConfigurationStatus('IPSITE_IAD_QUANTITY_VALIDATION',COMPONENT_NAMES.ipSite, ipSiteConfig.guid, iadQuantityValid, 'Please chose at least one IAD Device');
            
                                                    }
                                                    */
        if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component') {
        firstHandsetGUID = relatedConfig.guid;
        firstHandsetInfo = new Object();
        firstHandsetInfo.guid = relatedConfig.guid;
        firstHandsetInfo.parentGUID = ipSiteConfig.guid;
        relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
        if (handsetAttribute.name === 'HandsetandAccessoriesType') {
        firstHandsetType = handsetAttribute.value;
        firstHandsetInfo.type = handsetAttribute.value;
    }
                                            if (handsetAttribute.name === 'HandsetandAccessoriesModel') {
        firstHandsetModel = handsetAttribute.value;
        firstHandsetInfo.model = handsetAttribute.value;
    }
});
}
});
var typeMatched = false;
var modelMatched = false;
ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
    if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid !== firstHandsetInfo.guid && relatedConfig.guid === firstHandsetInfo.parentGUID &&
    (!basketChangeType || (basketChangeType  && !relatedConfig.id))) {
    relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
    if (handsetAttribute.name === 'HandsetandAccessoriesType' && handsetAttribute.value === firstHandsetInfo.type) {
    typeMatched = true;
}
                                        if (handsetAttribute.name === 'HandsetandAccessoriesModel' && handsetAttribute.value === firstHandsetInfo.model) {
    modelMatched = true;
}
});
if (typeMatched && modelMatched) {
    typeAndModelMatched = true;
    //msg = msg ? msg + ',\n' + 'Duplicate Type and Model selected' : 'Duplicate Type and Model selected';
}
updateConfigurationStatus('IPSITE_HA_DTMS',COMPONENT_NAMES.ipSite, ipSiteConfig.guid, typeAndModelMatched===false, 'Duplicate Type and Model selected');
}
});
}
/*if (msg) {
                                                console.log('msg', msg);
                                                messageMap.set(ipSiteConfig.guid, msg);
                                            }*/
/* // handled in function updateWidefeasCodeAndCategoryVisibility
                                            updateMap[ipSiteConfig.guid] = [{
                                                name: "Widefeas Code",
                                                value: {
                                                    value: existingWFCode,
                                                    displayValue: existingWFCode,
                                                    readOnly: false,
                                                    required: makeWFCodeMandatory
                                                }
                                            }];*/
});
}
}
});
}
console.log('IP Site updateMap2:' + updateMap);
if (updateMap) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('checkAllBusinessRules Attribute Update', component));
}
/*
                        if (messageMap) {
                            console.log('messageMap', messageMap);
                            messageMap.forEach(function (value, key, map) {
                                console.log('msgkey', key, 'msgvalue', value);
                                CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, key, false, value).then(configuration => console.log('checkAllBusinessRules Configuration Status Update', configuration));
            
                            });
                        }*/
}
}).then(
    () => Promise.resolve(true)
);
}

/***********************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : checkConfigurationSubscriptions
             * Invoked When: Solution is Loaded
             * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
            
             ***********************************************************************************************/
async function checkConfigurationSubscriptions() {
    console.log('checkConfigurationSubscriptions');
    var componentMap = {};
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if ((comp.name === COMPONENT_NAMES.ipSite || comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.replacedConfigId || config.id) {
        var cta = config.attributes.filter(a => {
        return a.name === 'ChangeType' && a.displayValue !== 'Modify' && a.displayValue !== 'Cancel'
    });
    if (cta && cta.length > 0) {
        
        if (!componentMap[comp.name])
            componentMap[comp.name] = [];
        
        if (config.replacedConfigId)
            componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid});
        else
            componentMap[comp.name].push({'id':config.id, 'guid': config.guid});
    }
}
});
}
});
}
}
});

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
await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
    console.log('GetSubscriptionForConfiguration result:', values);
    if (values['GetSubscriptionForConfiguration'])
    statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
});
    
    console.log ('checkConfigurationSubscriptions statuses;', statuses);
    if (statuses) {
    
    Object.keys(componentMap).forEach(comp => {
    var updateMap = {};
    componentMap[comp].forEach(element => {
    var statusValue = 'New';
    var status = statuses.filter(v => {
    return v.csordtelcoa__Product_Configuration__c === element.id
});
    if (status && status.length > 0) {
    statusValue = status[0].csord__Status__c;
}
    
    updateMap[element.guid] = [{
    name: 'ChangeType',
    value: {
        value: statusValue,
        displayValue: statusValue
    }
}];
                                                                                  });

console.log('checkConfigurationSubscriptions update map', updateMap);
CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptions Attribute Update', component));

});
}

}

return Promise.resolve(true);
}

function updateChangeTypeAttribute(){
    console.log('updateChangeTypeAttribute');
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMap = [];
        var doUpdate = false;
        if ((comp.name === COMPONENT_NAMES.ipSite || comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.attributes && config.attributes.length > 0) {
        config.attributes.forEach((attribute) => {
        if (attribute.name === 'ChangeType') {
        
        doUpdate = true;
        
        var changeTypeValue = attribute.value;
        if (updateMap[config.guid] === undefined)
        updateMap[config.guid] = [];
        
        console.log('basketChangeType: ' , basketChangeType);
        if (!basketChangeType) {
        
        console.log('Non MACD basket');
        if (!changeTypeValue) {
        changeTypeValue = 'New';
        
    }
                                   
                                   updateMap[config.guid].push({
                                   name: attribute.name,
                                   value: {
                                   value: changeTypeValue,
                                   displayValue: changeTypeValue,
                                   showInUi: false,
                                   readOnly: true
                                   }});
} else {
    
    console.log('MACD basket');
    
    /*
                                                        if (changeTypeValue === 'New' && (config.replacedConfigId || config.id) ) {
                                                            changeTypeValue = 'Active';
                                                        }*/
    
    var readonly = false;
    if (config.id && changeTypeValue==='Cancel')
        readonly = true;
    
    updateMap[config.guid].push({
        name: attribute.name,
        value: {
            showInUi: true,
            readOnly: false
        }});
    
    if (comp.name === COMPONENT_NAMES.ipSite) {
        setAttributesReadonlyValueForConfiguration(config.guid, true, COMPONENT_NAMES.ipSiteMacdReadonlyAttributeList);
        setAttributesReadonlyValueForConfigurationRp(config.guid, true);
    }
    
    if (changeTypeValue === 'Cancel') {
        if (comp.name === COMPONENT_NAMES.ipSite) {
            setAttributesReadonlyValueForConfiguration(config.guid, true, COMPONENT_NAMES.ipSiteEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, true);
        }
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            setAttributesReadonlyValueForConfiguration(config.guid, true, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, true);
        }
        
        updateDisconnectionDate(config.guid,true, basketStage==='Commercial Configuration', false);
        validateDisconnectionDateValue(config.guid,changeTypeValue);
    } else {
        updateDisconnectionDate(config.guid,false, false, false);
    }
    
    if (changeTypeValue==='Modify')
    {
        if (comp.name === COMPONENT_NAMES.ipSite) {
            setAttributesReadonlyValueForConfiguration(config.guid, false, COMPONENT_NAMES.ipSiteEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, false);
        }
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            setAttributesReadonlyValueForConfiguration(config.guid, false, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, true);
        }
        
        updateWidefeasCodeReadonlyValueForMACDModify(config.guid);
    }
    
    // if (changeTypeValue=== 'Active') {
    if (changeTypeValue !== 'Modify' && changeTypeValue !== 'Cancel' && changeTypeValue !== 'New') {
        if (comp.name === COMPONENT_NAMES.ipSite) {
            setAttributesReadonlyValueForConfiguration(config.guid, true, COMPONENT_NAMES.ipSiteEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, true);
        }
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            setAttributesReadonlyValueForConfiguration(config.guid, true, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
            setAttributesReadonlyValueForConfigurationRp(config.guid, true);
        }
    }
}
}
});
}
});
}
if (doUpdate) {
    console.log('updateChangeTypeAttribute', updateMap);
    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('CheckMacdBusinessRules Attribute Update', component));
}

});
}
}
}).then(
    () => Promise.resolve(true)
);
}

async function setChangeTypeafterConfigurationAdd(componentName, configuration) {
    var updateMap = {};
    var isVisible = false;
    
    if (componentName === COMPONENT_NAMES.ipSite || componentName === COMPONENT_NAMES.mobileSubscription) {
        if (basketChangeType){
            isVisible = true;
        }
        updateMap[configuration.guid] = [{
            name: 'ChangeType',
            value: {
                value: 'New',
                displayValue: 'New',
                readOnly: true,
                showInUi: isVisible
            }}];
        
        await CS.SM.updateConfigurationAttribute(componentName, updateMap, true).then(component => console.log('setChangeType', component));
    }
    return Promise.resolve(true);
}

function setAttributesReadonlyValueForConfiguration(guid, isReadOnly, attributeList)
{
    console.log ('setAttributesReadonlyValueForConfiguration ', guid, isReadOnly, attributeList);
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMap = [];
        var doUpdate = false;
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid === guid && config.attributes && config.attributes.length > 0) {
        config.attributes.forEach((attribute) => {
        if (attribute.showInUi) {
        if (attributeList.includes(attribute.name)) {
        doUpdate = true;
        if (updateMap[config.guid] === undefined)
        updateMap[config.guid] = [];
        updateMap[config.guid].push(
        {
        name: attribute.name,
        value: {
        readOnly: isReadOnly
    }
                                   });
}
}

});
}
});
}
if (doUpdate) {
    console.log('setAttributesReadonlyValueForConfiguration Updating: ', comp.name, updateMap);
    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('CheckMacdBusinessRules Attribute Update', component));
}

//}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}



function setAttributesReadonlyValueForConfigurationRp(configGuid, isReadOnly)
{
    console.log ('setAttributesReadonlyValueForConfigurationRp ', configGuid, isReadOnly);
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMap = [];
        var doUpdate = false;
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid === configGuid ) {
        
        if (comp.name === COMPONENT_NAMES.ipSite) {
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'User', isReadOnly, ['TypeUser','Quantity']);
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'Bandwidth Clip On', isReadOnly, ['Tier', 'Technology', 'Technology Type']);
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'Handset and Accessories', true, ['HandsetandAccessoriesType','HandsetandAccessoriesModel','Quantity', 'ContractTerm']);
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'IAD Device', true, ['Quantity', 'IADModel', 'ContractTerm']);
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'Hunt Group', isReadOnly, ['Quantity']);
    }
                                   if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        //for mobility is always readonly = true
        setAttributesReadonlyValueForConfigurationRelatedProducts(comp.name, config.relatedProductList, 'Mobile Device', true,
                                                                  ['MobileHandsetManufacturer', 'MobileHandsetModel','MobileHandsetColour','PaymentTypeLookup','ContractTermLookup']);
    }
    
}
});
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


function setAttributesReadonlyValueForConfigurationRelatedProducts(componentName, relatedProductList, relatedConfigName, isReadOnly, attributeList){
    console.log('setAttributesReadonlyValueForConfigurationRelatedProducts ', relatedProductList, relatedConfigName, isReadOnly, attributeList);
    if (relatedProductList && relatedProductList.length > 0) {
        var updateMap = {};
        var doUpdate = false;
        
        relatedProductList.forEach((relatedConfig) => {
            if (relatedConfig.name === relatedConfigName && relatedConfig.type === 'Related Component') {
            relatedConfig.configuration.attributes.forEach((attribute) => {
            if (attribute.showInUi && attributeList.includes(attribute.name)) {
            doUpdate = true;
            if (updateMap[relatedConfig.guid] === undefined)
            updateMap[relatedConfig.guid] = [];
            
            var readonlyValue = isReadOnly;
            updateMap[relatedConfig.guid].push({
            name:attribute.name,
            value: {
            readOnly: readonlyValue
        }
                                   });
    }
});
}
});

if (doUpdate === true) {
    console.log('setAttributesReadonlyValueForConfigurationRelatedProducts - updating: ', updateMap);
    CS.SM.updateConfigurationAttribute(relatedConfigName, updateMap, true).then(component => console.log('setAttributesReadonlyValueForConfigurationRelatedProducts Attribute Update', component));
}
}
}

function updateDisconnectionDate(guid, isVisible, isMandatory, isReadonly, disconnectionDate) {
    console.log ('updateDisconnectionDate ', guid, isVisible, isMandatory);
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMap = [];
        var doUpdate = false;
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid === guid && config.attributes && config.attributes.length > 0) {
        config.attributes.forEach((attribute) => {
        if (attribute.name === 'DisconnectionDate') {
        doUpdate = true;
        if (updateMap[config.guid] === undefined)
        updateMap[config.guid] = [];
        
        var val = {
        readOnly: isReadonly,
        showInUi: isVisible,
        required: isMandatory
    };
                                   if (disconnectionDate)
    val['value'] = disconnectionDate;
    
    updateMap[config.guid].push(
        {
            name: attribute.name,
            value: val
        });
}
});
}
});
}
if (doUpdate) {
    console.log('updateDisconnectionDate Updating: ', comp.name, updateMap);
    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('CheckMacdBusinessRules DisconnectionDate Update', component));
}

});
}
}
}).then(
    () => Promise.resolve(true)
);
}

function validateDisconnectionDateValue(guid, changeType) {
    
    if (basketStage != 'Commercial Configuration')
        return;
    
    console.log ('validateDisconnectionDateValue', guid, changeType);
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if ((comp.name === COMPONENT_NAMES.ipSite || comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        var valid = true;
        var errormessage = '';
        if (config.guid === guid && config.attributes && config.attributes.length > 0) {
        var cta = config.attributes.filter(a => {return a.name==='ChangeType' && a.displayValue==='Cancel'});
    if (changeType === 'Cancel' || cta && cta.length > 0) {
        console.log ('validateDisconnectionDateValue - validating');
        config.attributes.forEach((attribute) => {
            if (attribute.name === 'DisconnectionDate' && attribute.value && comp.name === COMPONENT_NAMES.ipSite) {
            
            var today = new Date();
            var futureDate = new Date();
            var attDate = new Date(attribute.value);
            today.setHours(0,0,0,0);
            futureDate.setTime(today.getTime() +  (10 * 24 * 60 * 60 * 1000));
            attDate.setHours(0,0,0,0);
            console.log ('DisconnectionDateValue:',attDate, futureDate);
            if (attDate < futureDate) {
            valid = false;
            errormessage = 'Please enter a date that is greater than 10 days from today';
        }
                                  }
                                  if (attribute.name === 'DisconnectionDate' && attribute.value && comp.name === COMPONENT_NAMES.mobileSubscription) {
            var today = new Date();
            var futureDate = new Date();
            var attDate = new Date(attribute.value);
            today.setHours(0,0,0,0);
            futureDate.setTime(today.getTime());
            attDate.setHours(0,0,0,0);
            console.log ('DisconnectionDateValue:',attDate, futureDate);
            // EDGE-106207 -> Getting error when entered todays date in mobility disconnection date field
            if (attDate < futureDate) {
                valid = false;
                errormessage = 'Please enter a date that is equal to or greater than Today';
            }
        }
    });
}
updateConfigurationStatus('DISCONNECTION_DATE_VALIDATION',comp.name, config.guid, valid, errormessage);
}

});
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

function updateWidefeasCodeReadonlyValueForMACDModify(guid){
    console.log ('updateWidefeasCodeReadonlyValueForMACDModify');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var doUpdate = false;
        var updateMap = {};
                                   updateMap[guid] = [];
                                   if (comp.name === COMPONENT_NAMES.ipSite) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
                if (config.guid === guid && config.attributes && config.attributes.length > 0 ) {
                
                var wcAtrtribute = config.attributes.filter(obj => {
                return obj.name === 'Widefeas Code'
            });
            
            if (wcAtrtribute && wcAtrtribute.length > 0) {
                doUpdate = true;
                var isReadOnly = false;
                if (wcAtrtribute[0].value)
                    isReadOnly = true;
                
                updateMap[config.guid] = [
                    {
                        name: wcAtrtribute[0].name,
                        value: {
                            readOnly: isReadOnly
                        }
                    }];
            }
        }
    });
}
}
if (doUpdate) {
    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('updateWidefeasCodeReadonlyValueForMACDModify:', component));
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}
function updateWidefeasCodeMandatoryValueForMACDModify(configGuid)
{
    console.log ('updateWidefeasCodeMandatoryValueForMACDModify');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var doUpdate = false;
        var updateMap = {};
                                   updateMap = [];
                                   if (comp.name === COMPONENT_NAMES.ipSite) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
                if (configGuid === config.guid && config.attributes && config.attributes.length > 0) {
                
                var changeTypeAtrtribute =  config.attributes.filter(obj => { return obj.name === 'ChangeType'});
            if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0 && changeTypeAtrtribute[0].value === 'Modify') {
                var wcAtrtribute = config.attributes.filter(obj => {
                    return obj.name === 'Widefeas Code'
                });
                
                if (wcAtrtribute && wcAtrtribute.length > 0) {
                    doUpdate = true;
                    updateMap[config.guid] = [
                        {
                            name: wcAtrtribute[0].name,
                            value: {
                                value: '',
                                displayValue: '',
                                readOnly: false,
                                required: true,
                                showInUi: true
                            }
                        }];
                }
            }
        }
    });
}
}
if (doUpdate) {
    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('updateWidefeasCodeMandatoryValueForMACDModify:', component));
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

function updateContractTerm(guid){
    console.log ('updateContractTerm');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid === guid && config.attributes && config.attributes.length > 0) {
        var remainingTerm =  config.attributes.filter(obj => { return obj.name === 'RemainingTerm'});
    if (remainingTerm && remainingTerm.length>0) {
        var updateMap = {};
        updateMap[config.guid] = [
            {
                name: "Contract Term",
                value: {
                    value: remainingTerm[0].value,
                    displayValue: remainingTerm[0].value,
                }
            }];
        CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('updateContractTerm:', component));
    }
}
});
}
}

});
}
}
}).then(
    () => Promise.resolve(true)
);
}

async function setAttributeValuesForRelatedComponent(guid, relatedComponentName, valueMap){
    console.log ('setAttributeValuesForRelatedComponent ', guid, relatedComponentName, valueMap);
    var updateMap = [];
    var doUpdate = false;
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.guid === guid && config.relatedProductList && config.relatedProductList.length > 0) {
        
        config.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === relatedComponentName && relatedConfig.type === 'Related Component') {
        relatedConfig.configuration.attributes.forEach((attribute) => {
        if (valueMap[attribute.name] !== undefined) {
        doUpdate = true;
        if (updateMap[relatedConfig.guid] === undefined)
        updateMap[relatedConfig.guid] = [];
        
        updateMap[relatedConfig.guid].push({
        name:attribute.name,
        value: {
        value: valueMap[attribute.name]
    }
                                         });
}
});
}
});
}
});
}

});
}
}
}).then(
    () => Promise.resolve(true)
);

if (doUpdate) {
    console.log('setAttributeValuesForRelatedComponent - updating: ', updateMap);
    await CS.SM.updateConfigurationAttribute(relatedComponentName, updateMap, true).then(component => console.log('setAttributeValuesForRelatedComponent Updated ', component));
}

return Promise.resolve(true);
}


function checkUserMacdRules(componentGuid, relatedComponentGuid){
    
    console.log('checkUserMacdRules ');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMap = [];
        var doUpdate = false;
        if ((comp.name === COMPONENT_NAMES.ipSite || comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if ((config.guid === componentGuid || !componentGuid) && config.attributes && config.attributes.length > 0) {
        updateConfigurationStatus('IPSITE_USER_TYPE_VALIDATION',COMPONENT_NAMES.ipSite, config.guid , true, '');
        updateConfigurationStatus('IPSITE_MOBILE_USER_VALIDATION',COMPONENT_NAMES.ipSite, config.guid , true, '');
        
        
        if (config.relatedProductList && config.relatedProductList.length > 0) {
        var updateMap = [];
        var doUpdate = false;
        
        var changeTypeAtrtribute =  config.attributes.filter(obj => { return obj.name === 'ChangeType'});
    
    console.log('checkUserMacdRules changeTypeAtrtribute: ', changeTypeAtrtribute);
    
    if (changeTypeAtrtribute && changeTypeAtrtribute[0].value === 'Modify') {
        var configsCountByType = {}
        var duplicateMessageSet = false;
        config.relatedProductList.forEach((relatedConfig) => {
            
            if ((relatedConfig.guid === relatedComponentGuid || !relatedComponentGuid) &&
            relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
            
            var validationMessage;
            
            var userTypeAttribute = relatedConfig.configuration.attributes.filter(a => {
            return a.name === 'TypeUser'
        });
        
        if (userTypeAttribute) {
            
            if (!configsCountByType[userTypeAttribute[0].displayValue])
                configsCountByType[userTypeAttribute[0].displayValue] = 0;
            
            configsCountByType[userTypeAttribute[0].displayValue] += 1;
            
            if (!duplicateMessageSet && configsCountByType[userTypeAttribute[0].displayValue] === 2) {
                duplicateMessageSet = true;
                //validationMessage = validationMessage ? validationMessage + ',\n' : '';
                //validationMessage = validationMessage + 'Cannot add new user product of the same type';
                updateConfigurationStatus('IPSITE_USER_TYPE_VALIDATION',COMPONENT_NAMES.ipSite, config.guid , false, 'Cannot add new user of the same type');
            }
            
            
            console.log('checkUserMacdRules userTypeAttribute: ', userTypeAttribute);
            
            //EDGE-101203 - Commented for this Bug - The Qty and Type User is becomign Readonly in Modify
            /*
                                                                if (userTypeAttribute[0].displayValue === 'Fax Line') {
                                                                    doUpdate = true;
                                                                    if (updateMap[relatedConfig.guid] === undefined)
                                                                        updateMap[relatedConfig.guid] = [];
            
                                                                    updateMap[relatedConfig.guid].push({
                                                                        name: 'TypeUser',
                                                                        value: {
                                                                            readOnly: true
                                                                        }
                                                                    });
                                                                    updateMap[relatedConfig.guid].push({
                                                                        name: 'Quantity',
                                                                        value: {
                                                                            readOnly: true
                                                                        }
                                                                    });
                                                                } */
            
            if (userTypeAttribute[0].displayValue === 'Mobile') {
                var quantityAttribute = relatedConfig.configuration.attributes.filter(a => {
                    return a.name === 'Quantity'
                });
                console.log('checkUserMacdRules quantityAttribute: ', quantityAttribute);
                if (quantityAttribute && quantityAttribute[0] > 4) {
                    //validationMessage = validationMessage ? validationMessage + ',\n' : '';
                    //validationMessage = validationMessage + 'Maximum number of user quantity is 4.';
                    updateConfigurationStatus('IPSITE_MOBILE_USER_VALIDATION',COMPONENT_NAMES.ipSite, config.guid , false, 'Maximum number of mobile users quantity is 4');
                }
            }
            
        }
        /*
                                                            if (validationMessage) {
                                                                CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, config.guid , false, validationMessage).then(configuration => console.log('checkUserMacdRules validation: ', configuration));
                                                            }*/
    }
});

if (doUpdate) {
    console.log('checkUserMacdRules - updating: ', updateMap);
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('checkUserMacdRules Attribute Update', component));
}
}
}
}
});
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

function updateRpAttributesVisibility(){
    console.log('updateRpAttributesVisibility ');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        var updateMapUser = {};
                                   var updateMapBCO = {};
                                   //added for 100185
                                   var	updateMapHuntGroup={};
                                   if ((comp.name === COMPONENT_NAMES.ipSite || comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
                if (config.attributes && config.attributes.length > 0) {
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                
                var changeTypeAtrtribute = config.attributes.filter(obj => {
                return obj.name === 'ChangeType'
            });
            
            if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                config.relatedProductList.forEach((relatedConfig) => {
                    
                    var showInUi = false;
                    
                    if (relatedConfig.type === 'Related Component') {
                    
                    if (relatedConfig.name === 'User') {
                    var userTypeAttribute = relatedConfig.configuration.attributes.filter(a => {
                    return a.name === 'TypeUser'
                });
                if (userTypeAttribute && userTypeAttribute[0].displayValue === 'Fax Line') {
                    if (updateMapUser[relatedConfig.guid] === undefined)
                        updateMapUser[relatedConfig.guid] = [];
                    
                    showInUi = false;
                    if (changeTypeAtrtribute[0].value === 'Modify')
                        showInUi = true;
                    
                    updateMapUser[relatedConfig.guid].push({
                        name: 'Cancel',
                        value: {
                            showInUi: showInUi,
                            readOnly: false
                        }
                    });
                }
            }
            
            if (relatedConfig.name === 'Bandwidth Clip On') {
                if (updateMapBCO[relatedConfig.guid] === undefined)
                    updateMapBCO[relatedConfig.guid] = [];
                
                showInUi = false;
                if (changeTypeAtrtribute[0].value === 'Modify')
                    showInUi = true;
                
                updateMapBCO[relatedConfig.guid].push({
                    name: 'Cancel',
                    value: {
                        showInUi: showInUi,
                        readOnly: false
                    }
                });
            }
            //EDGE-100185
            if (relatedConfig.name === 'Hunt Group') {
                if (updateMapHuntGroup[relatedConfig.guid] === undefined)
                    updateMapHuntGroup[relatedConfig.guid] = [];
                
                showInUi = false;
                if (changeTypeAtrtribute[0].value === 'Modify')
                    showInUi = true;
                
                updateMapHuntGroup[relatedConfig.guid].push({
                    name: 'Cancel',
                    value: {
                        showInUi: showInUi,
                        readOnly: false
                    }
                });
            }
            
            
        }
});
}
}
}
});
}
if (Object.keys(updateMapUser).length > 0) {
    console.log('updateRpAttributesVisibility - updating users: ', updateMapUser);
    CS.SM.updateConfigurationAttribute('User', updateMapUser, true).then(component => console.log('updateRpAttributesVisibility Attribute Update User', component));
}

if (Object.keys(updateMapBCO).length > 0) {
    console.log('updateRpAttributesVisibility - updating Bandwidth Clip On: ', updateMapBCO);
    CS.SM.updateConfigurationAttribute('Bandwidth Clip On', updateMapBCO, true).then(component => console.log('updateRpAttributesVisibility Attribute Update User', component));
}
//added for Edge-EDGE-100185
if (Object.keys(updateMapHuntGroup).length > 0) {
    console.log('updateRpAttributesVisibility - updating Hunt Grouo: ', updateMapHuntGroup);
    CS.SM.updateConfigurationAttribute('Hunt Group', updateMapHuntGroup, true).then(component => console.log('updateRpAttributesVisibility Attribute Update User', component));
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/******************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : calculateTotalETCValue
             * Invoked When: DisConnection Date is updated on IP SITE component
             * Description : 1. Calculates TOtal ETC on IP Site UI
             * Parameters  : 1. guid of IP Site Config
             *****************************************************************/
function calculateTotalETCValue(guid) {
    console.log('calculateTotalETCValue', basketChangeType, guid);
    if (basketChangeType === 'Change Solution') {
        CS.SM.getActiveSolution().then((product) => {
            var changeType;
            var disconnectionDate;
            var fixedSeatUserQuantity;
            var fixedSeatUserConfigId;
            console.log('calculateTotalETCValue', product);
            if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
            if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.ipSite) {
            console.log('IP Site while updating Disconnection Date', comp);
            
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((ipSiteConfig) => {
            if (ipSiteConfig.guid === guid) {
            ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
            if (ipSiteAttribute.name === 'DisconnectionDate' && ipSiteAttribute.value) {
            disconnectionDate = new Date(ipSiteAttribute.value);
            console.log('DisconnectionDate=', disconnectionDate);
        }
                                       if (ipSiteAttribute.name === 'ChangeType' && ipSiteAttribute.value) {
            changeType = ipSiteAttribute.value;
        }
    });
    if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
            if (relatedConfig.type === 'Related Component' && relatedConfig.name === 'User') {
            var userTypeAttribute = relatedConfig.configuration.attributes.filter(a => {
            return a.name === 'TypeUser' && a.displayValue ==='Fixed Seat'
        });
        
        if (userTypeAttribute && userTypeAttribute.length > 0) {
            var quantityAttribute = relatedConfig.configuration.attributes.filter(a => {
                return a.name === 'Quantity'
            });
            if (quantityAttribute && quantityAttribute.length > 0 && quantityAttribute[0].value) {
                fixedSeatUserQuantity = quantityAttribute[0].value;
                fixedSeatUserConfigId = relatedConfig.configuration.replacedConfigId;
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
console.log('changeType=', changeType, ', fixedSeatUserQuantity=', fixedSeatUserQuantity, ', fixedSeatUserConfigId=', fixedSeatUserConfigId, ', disconnectionDate=', disconnectionDate);
if (changeType === 'Cancel' && (fixedSeatUserQuantity || fixedSeatUserConfigId) && disconnectionDate) {
    var inputMap = {};
    var updateMap = [];
    inputMap["Quantity"] = fixedSeatUserQuantity;
    inputMap["TypeUser"] = 'Fixed Seat';
    inputMap["DisconnectionDate"] = disconnectionDate;
    inputMap["ReplacedConfigId"] = fixedSeatUserConfigId;
    console.log('inputMap', inputMap);
    CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => {
    console.log('Result', values["User"]);
    updateMap[guid] = values["User"];
	updateMap[guid].push({
		name: 'WaiveETC',
		value: {
			showInUi: true
		}
	});
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('calculateTotalETCValue Attribute update', component));
    });
    }
    }
    }
    }).then(
        () => Promise.resolve(true)
        );
    }
    }
        
        /********************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : addIPNAndUCEToMACSolution
             * Invoked When: A Configuration is created against IP SITE component
             * Description : 1. Adds IP Network and UCE configs to MAC Solution
             * Parameters  : NA
             *******************************************************************/
        async function addIPNAndUCEToMACSolution() {
        console.log('addIPNAndUCEToMACSolution', basketChangeType);
        var solutionId;
        var ipNetworkGUID;
        var uceGUID;
        if (basketChangeType === 'Change Solution') {
        await CS.SM.getActiveSolution().then((product) => {
        console.log('addIPNAndUCEToMACSolution', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        console.log('addIPNAndUCEToMACSolution SolutionId', product.id);
        solutionId = product.id;
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipNetwork) {
        console.log('IP Network while adding IP Site', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipNetworkConfig) => {
        if (!ipNetworkConfig.id) {
        ipNetworkGUID = ipNetworkConfig.guid;
    }
    });
    }
    }
        if (comp.name === COMPONENT_NAMES.uc) {
        console.log('UCE while adding IP Site', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ucConfig) => {
        if (!ucConfig.id) {
        uceGUID = ucConfig.guid;
    }
    });
    }
    }
    });
    }
        
    }
    }).then(
        () => Promise.resolve(true)
        );
        
        console.log('ipNetworkGUID=', ipNetworkGUID);
        if (ipNetworkGUID && ipnAdded === false) {
        ipnAdded = true;
        console.log('ipNetwork addConfigurationsToMAC ', ipNetworkGUID, ipnAdded);
        await CS.SM.addConfigurationsToMAC(solutionId, [ipNetworkGUID], COMPONENT_NAMES.ipNetwork);
    }
        console.log('uceGUID=', uceGUID);
        if (uceGUID && uceAdded === false) {
        uceAdded = true;
        console.log('uce addConfigurationsToMAC ', uceGUID);
        await CS.SM.addConfigurationsToMAC(solutionId, [uceGUID], COMPONENT_NAMES.uc);
    }
    }
        
        return Promise.resolve(true);
    }
        
        //Mobility modify functionality
        async function updateMobilityChangeTypeAndAddToMacBasket(){
        
        if (basketChangeType !== 'Change Solution') {
        return Promise.resolve(true);
    }
        
        console.log('updateMobilityChangeTypeAndAddToMacBasket');
        
        var isCanacel = true;
        var updateMapMobility = {};
        var solutionId;
        var guidList = [];
        await CS.SM.getActiveSolution().then((solution) => {
        solutionId = solution.id;
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        
        var ipSiteComponent = solution.components.filter(c => {
        return c.name === COMPONENT_NAMES.ipSite && c.schema && c.schema.configurations && c.schema.configurations.length > 0
    });
        if (ipSiteComponent != null && ipSiteComponent.length > 0) {
        
        ipSiteComponent[0].schema.configurations.forEach((config) => {
        
        if (config.attributes && config.attributes.length > 0) {
        
        var changeTypeAttribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType' && obj.value !== 'Cancel'
    });
        
        if (changeTypeAttribute && changeTypeAttribute.length > 0) {
        isCanacel = false;
    }
    }
    });
        
        
        if (isCanacel === true) {
        var mobilityComponent = solution.components.filter(c => {
        return c.name === COMPONENT_NAMES.mobileSubscription && c.schema && c.schema.configurations && c.schema.configurations.length > 0
    });
        
        if (mobilityComponent && mobilityComponent.length > 0) {
        mobilityComponent[0].schema.configurations.forEach((config1) => {
        
        if (!config1.id) {
        guidList.push(config1.guid);
        
        updateMapMobility[config1.guid] = [{
        name: 'ChangeType',
        value: {
            value: 'Cancel',
            displayValue: 'Cancel'
        }
    }];
                                                                          }
                                                                          });
    
}
}
}
}
}
}).then(
    () => {
        console.log('updateMobilityChangeTypeAndAddToMacBasket - finished preparation');
        Promise.resolve(true);
    }
        );
        
        console.log('updateMobilityChangeTypeAndAddToMacBasket - updating: ', updateMapMobility);
        if (updateMapMobility && Object.keys(updateMapMobility).length > 0) {
        await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapMobility, true).then(component => console.log('updateMobilityChangeTypeAndAddToMacBasket Attribute Update', component));
    }
        
        if (isCanacel === true && guidList.length > 0) {
        console.log('updateMobilityChangeTypeAndAddToMacBasket - adding to mac basket ',solutionId,  guidList);
        await CS.SM.addConfigurationsToMAC(solutionId, guidList, COMPONENT_NAMES.mobileSubscription);
    }
        console.log('updateMobilityChangeTypeAndAddToMacBasket - exiting');
        return Promise.resolve(true);
    }
        
        async function updateIpNetworkAndUCChangeType(){
        console.log('updateIpNetworkAndUCChangeType');
        
        var updateMapIP = {};
        var updateMapUC = {};
        await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var updateMap = {};
        var isCanacel = true;
        solution.components.forEach((comp) => {
        if (comp.name===COMPONENT_NAMES.ipSite &&  comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (!config.id || !config.replacedConfigId ) {
        setChangeType = 'Modify';
    }
        if (config.attributes && config.attributes.length > 0) {
        
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
        if (changeTypeAtrtribute && changeTypeAtrtribute.length>0 && (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute && changeTypeAtrtribute[0].value === 'Cancel')) {
        setChangeType = 'Modify';
    }
        
        if (!changeTypeAtrtribute || changeTypeAtrtribute.length===0 || changeTypeAtrtribute[0].value !== 'Cancel') {
        isCanacel = false;
    }
    }
    });
    }
    });
        
        if (isCanacel === true)
        setChangeType = 'Cancel';
        
        if (setChangeType) {
        var ipNetworkComponent = solution.components.filter(obj => {
        return obj.name === COMPONENT_NAMES.ipNetwork
    });
        if (ipNetworkComponent && ipNetworkComponent.length > 0) {
        updateMapIP = {};
        ipNetworkComponent[0].schema.configurations.forEach((config) => {
        updateMapIP[config.guid] = [{
        name: 'ChangeType',
        value: {
            value: setChangeType,
            displayValue: setChangeType
        }
    }];
    });
}

var ucComponent = solution.components.filter(obj => {
    return obj.name === COMPONENT_NAMES.uc
});
if (ucComponent && ucComponent.length > 0) {
    updateMapUC = {};
    ucComponent[0].schema.configurations.forEach((config) => {
        updateMapUC[config.guid] = [{
        name: 'ChangeType',
        value: {
            value: setChangeType,
            displayValue: setChangeType
        }
    }];
                                                 });
    
}
}
}
}
}).then(
    () => {
        console.log('updateIpNetworkAndUCChangeType - finished');
        Promise.resolve(true);
    }
        );
        
        console.log('updateIpNetworkChangeType - updating: ', updateMapIP);
        await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipNetwork, updateMapIP, true).then(component => console.log('updateIpNetworkAndUCChangeType Attribute Update', component));
        
        console.log('updateUCChangeType - updating: ', updateMapUC);
        await  CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.uc, updateMapUC, true).then(component => console.log('updateIpNetworkAndUCChangeType Attribute Update', component));
        
        console.log('updateIpNetworkAndUCChangeType - exiting');
        return Promise.resolve(true);
    }
        
        function updateEtcVisibility(guid) {
        console.log('updateEtcVisibility');
        
        CS.SM.getActiveSolution().then((solution) => {
        console.log('Active Solution from updateEtcvisibility', solution);
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var updateMap = {};
        solution.components.forEach((comp) => {
        if (comp.name===COMPONENT_NAMES.ipSite &&  comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (!guid || guid === config.guid) {
        if (config.attributes && config.attributes.length > 0) {
        
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
        
        var totalETCAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'TotalETC'
    });
        
        if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
        
        updateMap[config.guid] = [];
        var visible = false;
        var visibleEtc = false;
        if (changeTypeAtrtribute[0].value === 'Cancel') {
        visible = true;
        visibleEtc = true;
    }
        
        updateMap[config.guid].push({
        name: 'WaiveETC',
        value: {
            showInUi: visibleEtc
        }
    });

if (visible) {
    var waiveETCAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'WaiveETC'
    });
    if (waiveETCAtrtribute && waiveETCAtrtribute.length > 0 && waiveETCAtrtribute[0].value === false) {
        visible = false;
    }
}

//TotalETC ?
var etcVal = {showInUi: visibleEtc};
if (totalETCAtrtribute && totalETCAtrtribute.length > 0 && totalETCAtrtribute[0].value) {
    etcVal.value = totalETCAtrtribute[0].value;
} else {
    etcVal.value = 0;
}

updateMap[config.guid].push({
    name: 'TotalETC',
    value: etcVal
});

updateMap[config.guid].push({
    name: 'CaseNumber',
    value: {
        showInUi: visible
    }
});

updateMap[config.guid].push({
    name: 'CaseStatus',
    value: {
        showInUi: visible
    }
});

}
}
}
});
}
});
console.log('updateEtcVisibility - updating: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateEtcVisibility Attribute Update', component));
}
}
}).then(
    () => Promise.resolve(true)
);
}

///Function to Show  mobility ETC field for Cancel

function updateMobilityEtcVisibility(guid) {
    console.log('updateMobilityEtcVisibility');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var updateMap = {};
                                   solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        updateMap = [];
        console.log('updateMobilityEtcVisibility--->4817');
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.id) {
        if (config.attributes && config.attributes.length > 0) {
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
    console.log('updateMobilityEtcVisibility--->4824'+changeTypeAtrtribute[0].value);
    if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
        var visibleEtc = false;
        if (changeTypeAtrtribute[0].value === 'Cancel') {
            console.log('updateMobilityEtcVisibility--->4827');
            if (config.relatedProductList && config.relatedProductList.length > 0) {
                config.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name.includes('Mobile Device')) {
                    
                    if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
                    console.log('updateMobilityEtcVisibility--->4835');
                    var PaymentTypeAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                    return obj.name === 'PaymentTypeString'
                });
                console.log('updateMobilityEtcVisibility--->4839'+PaymentTypeAtrtribute[0]);
                if (PaymentTypeAtrtribute[0].value === 'Hardware Repayment'){
                    visibleEtc = true;
                    console.log('updateMobilityEtcVisibility--> PaymentTypeAtrtribute--->4840'+PaymentTypeAtrtribute);
                    console.log('updateMobilityEtcVisibility--->4841');
                    updateMap[config.guid] = [{
                        name: 'EarlyTerminationCharges',
                        value: {
                            showInUi: visibleEtc,
                            required: true
                        }
                    }];
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

console.log('populateETC: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('ETC For MobileSubscription Update', component));

}
}
}).then(
    () => Promise.resolve(true)
);
}


function updateWidefeasCodeAndCategoryVisibility(guid) {
    console.log('updateWidefeasCodeVisibility');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var updateMap = {};
                                   solution.components.forEach((comp) => {
        if (comp.name===COMPONENT_NAMES.ipSite &&  comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (!guid || guid === config.guid) {
        if (config.attributes && config.attributes.length > 0) {
        var fixedSeatUserQuantity = 0;
        updateMap[config.guid] = [];
        var isWidefeasCodeVisible = true;
        var isWidefeasCategoryVisible = true;
        var isWorkCostVisible = true;
        if (config.relatedProductList && config.relatedProductList.length > 0) {
        config.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.type === 'Related Component' && relatedConfig.name === 'User') {
        var userTypeAttribute = relatedConfig.configuration.attributes.filter(a => {
        return a.name === 'TypeUser' && a.displayValue ==='Fixed Seat'
    });
    
    if (userTypeAttribute && userTypeAttribute.length>0) {
        var quantityAttribute = relatedConfig.configuration.attributes.filter(a => {
            return a.name === 'Quantity'
        });
        if (quantityAttribute && quantityAttribute.length > 0 && quantityAttribute[0].value) {
            fixedSeatUserQuantity = fixedSeatUserQuantity + quantityAttribute[0].value;
        }
    }
}
});
}


if (fixedSeatUserQuantity<18) {
    isWidefeasCategoryVisible = false;
    isWidefeasCodeVisible = false;
}

var wfCategoryAttribute = config.attributes.filter(a => {
    return a.name === 'WidefeasCategory'
});

if (isWidefeasCodeVisible === true) {
    
    var workCostAttribute = config.attributes.filter(a => {
        return a.name === 'WorkCost' && a.displayValue > 500
    });
    
    var technologyTypeAttribute = config.attributes.filter(a => {
        return a.name === 'Technology Type' && a.displayValue !== 'Telstra Fibre Access'
    });
    
    if ((wfCategoryAttribute && wfCategoryAttribute.length > 0 && wfCategoryAttribute[0].displayValue !=='CAT1' && workCostAttribute && workCostAttribute.length > 0) ||
        (technologyTypeAttribute && technologyTypeAttribute.length > 0)) {
        isWidefeasCodeVisible = false;
    }
}

if (wfCategoryAttribute && wfCategoryAttribute.length > 0 && (wfCategoryAttribute[0].displayValue ==='CAT1' || !wfCategoryAttribute[0].displayValue)) {
    isWorkCostVisible = false;
}

//var widefeasCategoryValue = {showInUi: isWidefeasCategoryVisible};
var widefeasCategoryValue = {showInUi: isWidefeasCategoryVisible, required:isWidefeasCategoryVisible};
if (!isWidefeasCategoryVisible) {
    widefeasCategoryValue.value = '';
    widefeasCategoryValue.displayValue = '';
}

updateMap[config.guid].push({
    name: 'WidefeasCategory',
    value: widefeasCategoryValue
});

//var widefeasCodeValue = {showInUi: isWidefeasCodeVisible};
var widefeasCodeValue = {showInUi: isWidefeasCodeVisible, required: isWidefeasCodeVisible};
if (!isWidefeasCodeVisible) {
    widefeasCodeValue.value = '';
    widefeasCodeValue.displayValue = '';
}
updateMap[config.guid].push({
    name: 'Widefeas Code',
    value: widefeasCodeValue
});

var workCostValue = {showInUi: isWorkCostVisible};
if (!isWorkCostVisible)
    workCostValue.value = '0.00';
updateMap[config.guid].push({
    name: 'WorkCost',
    value: workCostValue
});

}
}
});
}
});
console.log('updateWidefeasCodeVisibility - updating: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateWidefeasCodeVisibility Attribute Update', component));
}
}
}).then(
    () => Promise.resolve(true)
);
}

function updateNBNCompatibility () {
    
    console.log('updateNBNCompatibility');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var updateMap = {};
                                   solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        updateMap = [];
        comp.schema.configurations.forEach((config) => {
        //	if (!guid || guid === config.guid) {
        console.log('updateNBNCompatibilitytreee');
        
        var numberOfUsers = 3;
        var NBNAvailability = '';
        var NBNTechnologyType = '';
        var VacantCopperPairAvailable = '';
        var NBNCompatibilityValue = '';
        if (config.relatedProductList && config.relatedProductList.length > 0) {
        config.relatedProductList.forEach((relatedConfig) => {
        console.log('updateNBNCompatibilityssss'+relatedConfig.name);
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
        
        var userTypeAttr = relatedConfig.configuration.attributes.filter(a => {
        return a.name === 'TypeUser' && a.displayValue === 'Fixed Seat'
    });
    
    if (userTypeAttr && userTypeAttr.length > 0) {
        var quantityAttr = relatedConfig.configuration.attributes.filter(a => {
            return a.name === 'Quantity'
        });
        
        if (quantityAttr && quantityAttr.length > 0 && quantityAttr[0].value) {
            numberOfUsers = quantityAttr[0].value;
        }
    }
}
});
}

if (config.attributes && config.attributes.length > 0) {
    config.attributes.forEach((attribute) => {
        
        if (attribute.name === 'NBNAvailability' && attribute.value) {
        NBNAvailability = attribute.value.toLowerCase() === 'available' ? 'yes' : 'no';
    }
                              
                              if (attribute.name === 'NBNTechnologyType') {
        NBNTechnologyType = attribute.value;
    }
    
    if (attribute.name === 'SQVacantCopperPairs') {
        VacantCopperPairAvailable = attribute.value;
    }
});
}


console.log('before updateNBNCompatibilitytreeeaaass',NBNAvailability , NBNTechnologyType , VacantCopperPairAvailable , NBNCompatibilityValue);

//	if (NBNAvailability && NBNTechnologyType && VacantCopperPairAvailable && NBNCompatibility &&  WidefeasCategory && WorkCost && TelstraFibreCompatibility) {
NBNCompatibilityValue = getNBNCompatibilityRule(numberOfUsers, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable);
console.log('print NBNCompatibilityValue'+NBNCompatibilityValue);
//}
updateMap[config.guid] = [{
    name: 'NBNCompatibility',
    value: {
        value: NBNCompatibilityValue,
        displayValue: NBNCompatibilityValue
    }
}];
//}
});
}
}
});
console.log('updateNBNCompatibilitytreeeaaass - updating: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(
    component => {
        console.log('updateNBNCompatibilitytreeeaaass Attribute Update', component);
        updateAccesType();
    });
    }
    }
    }).then(
        () => Promise.resolve(true)
        )
    }
        
        
        function updateTelstraFibreCompatibility() {
        console.log('updateTelstraFibreCompatibility');
        
        CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var updateMap = {};
        solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        updateMap = [];
        comp.schema.configurations.forEach((config) => {
        if (config.attributes && config.attributes.length > 0) {
        
        
        var wfCategoryAttribute = config.attributes.filter(a => {
        return a.name === 'WidefeasCategory'
    });
        
        var workCostAttribute = config.attributes.filter(a => {
        return a.name === 'WorkCost'
    });
        
        if (wfCategoryAttribute && wfCategoryAttribute.length > 0 && workCostAttribute && workCostAttribute.length > 0) {
        
        var telstraFibreCompatibilityValue = 'Yes';
        
        if (!wfCategoryAttribute[0].displayValue || (wfCategoryAttribute[0].displayValue != 'CAT1' && workCostAttribute[0].value && workCostAttribute[0].value > 500)) {
        telstraFibreCompatibilityValue = 'No';
    }
        
        updateMap[config.guid] = [{
        name: 'TelstraFibreCompatibility',
        value: {
            value: telstraFibreCompatibilityValue,
            displayValue: telstraFibreCompatibilityValue
        }
    }];
    }
    }
    
    });
}
});
console.log('updateTelstraFibreCompatibility - updating: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(
    component => {
        console.log('updateTelstraFibreCompatibility Attribute Update', component);
        updateAccesType();
    });
    }
    }
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        function CheckMacdBusinessRules(componentName, guid, attribute, oldValue, newValue){
        
        if (componentName === COMPONENT_NAMES.ipSite) {
        
        if (attribute.name === 'ChangeType') {
        if (newValue === 'Cancel') {
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.ipSiteEditableAttributeList);
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.ipSiteMacdReadonlyAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, true);
        updateDisconnectionDate(guid,true, basketStage==='Commercial Configuration', false);
        
        var valueMap = {};
        valueMap['TOC'] = '0';
        valueMap['TRC'] = '0';
        setAttributeValuesForRelatedComponent(guid, 'Handset and Accessories',valueMap);
        setAttributeValuesForRelatedComponent(guid, 'IAD Device',valueMap);
        valueMap = {};
        valueMap['Frequency'] = 'N/A';
        setAttributeValuesForRelatedComponent(guid, 'Bandwidth Clip On',valueMap);
    }
        
        if (newValue !== 'Cancel' && oldValue === 'Cancel') {
        setAttributesReadonlyValueForConfiguration(guid, false, COMPONENT_NAMES.ipSiteEditableAttributeList );
        setAttributesReadonlyValueForConfigurationRp(guid, false);
        updateDisconnectionDate(guid, false, false, false);
    }
        
        if (newValue === 'Modify') {
        setAttributesReadonlyValueForConfiguration(guid, false, COMPONENT_NAMES.ipSiteEditableAttributeList,);
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.ipSiteMacdReadonlyAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, false);
        updateWidefeasCodeReadonlyValueForMACDModify(guid);
        updateContractTerm(guid);
        checkUserMacdRules(guid, null);
        //checkHandsetAndAccessoriesMacdRules(guid, null)
    }
        
        // if (newValue === 'Active') {
        if (newValue !== 'Modify' && newValue !== 'Cancel' && newValue !== 'New') {
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.ipSiteEditableAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, true);
    }
        
        validateDisconnectionDateValue(guid, newValue);
        updateRpAttributesVisibility();
        updateEtcVisibility(guid);
        
    }
        
        //Commented for EDGE-101214 - Widefeas code is geing made mandatory while adding bandwidth clip on
        /**if (attribute.name === 'Bandwidth' && oldValue !== newValue) {
                        updateWidefeasCodeMandatoryValueForMACDModify(guid);
                    }**/
        if (attribute.name === 'Quantity' && (newValue >17 || oldValue>17)) {
        updateWidefeasCodeMandatoryValueForMACDModify(guid);
    }
        
        if (attribute.name === 'DisconnectionDate') {
        validateDisconnectionDateValue(guid, '');
    }
        
        if (attribute.name === 'Quantity') {
        checkUserMacdRules(null, guid);
    }
        
        if (attribute.name === 'TypeUser') {
        checkUserMacdRules(null, guid);
    }
        /*
            //covered by standard rules, no need for macd rules
                    if (attribute.name === 'HandsetandAccessoriesType' || attribute.name === 'HandsetandAccessoriesModel') {
                        checkHandsetAndAccessoriesMacdRules(null, guid);
                    }
            */
        
        
    } else if (componentName === COMPONENT_NAMES.mobileSubscription) {
        
        if (attribute.name === 'ChangeType') {
        if (newValue === 'Cancel') {
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, true);
        
        var today = new Date();
        today.setHours(0,0,0,0);
        updateDisconnectionDate(guid,true, basketStage==='Commercial Configuration', false, today);
    }
        if (newValue === 'Modify') {
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
        setAttributesReadonlyValueForConfiguration(guid, false, COMPONENT_NAMES.mobileSubscriptionEditableAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, true);
        validateDisconnectionDateValue(guid, newValue);
    }
        
        if (newValue !== 'Cancel' && oldValue === 'Cancel') {
        updateDisconnectionDate(guid, false, false, false);
        validateDisconnectionDateValue(guid, newValue);
    }
        
        //if (newValue === 'Active') {
        if (newValue !== 'Modify' && newValue !== 'Cancel' && newValue !== 'New') {
        setAttributesReadonlyValueForConfiguration(guid, true, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
        setAttributesReadonlyValueForConfigurationRp(guid, true);
        validateDisconnectionDateValue(guid, newValue);
    }
    }
        
        if (attribute.name === 'DisconnectionDate') {
        validateDisconnectionDateValue(guid, '');
    }
        
    }
        
        if (attribute.name === 'ChangeType') {
        updateOeTabsVisibility(guid);
    }
    }
        
        
        function checkMACDBusinessRules() {
        
        //updateEtcVisibility(null);
		updateEtcAttVisibilityOnLoad();
        if (basketChangeType !== 'Change Solution')
        return;
        
        updateOeTabsVisibility();
        updateChangeTypeAttribute();
        updateRpAttributesVisibility();
        
        console.log('checkMACDBusinessRules');
    }
        
        
        function  solutionBeforeConfigurationDeleteMacd(componentName, configuration, relatedProduct) {
        
        var changeTypeAttribute =  configuration.attributes.filter(o => {return o.name==='ChangeType'});
        if (changeTypeAttribute && relatedProduct.type === 'Related Component' && relatedProduct.configuration.id) {
        if (changeTypeAttribute[0].value === 'Modify') {
        
        if (relatedProduct.name === 'Mobile Device' ) {
        CS.SM.displayMessage('Not allowed to delete Mobile Device when changing Mobility configuration!', 'info');
        return false;
    }
        
        if (relatedProduct.name === 'IAD Device' ) {
        CS.SM.displayMessage('Not allowed to delete IAD Device when changing IP Site configuration!', 'info');
        return false;
    }
        
        if (relatedProduct.name === 'Hunt Group' ) {
        CS.SM.displayMessage('Not allowed to delete Hunt Group when changing IP Site configuration!', 'info');
        return false;
    }
        if (relatedProduct.name === 'Bandwidth Clip On' ) {
        CS.SM.displayMessage('Not allowed to delete Bandwidth Clip On when changing IP Site configuration!', 'info');
        return false;
    }
        
        if (relatedProduct.name === 'Handset and Accessories' ) {
        CS.SM.displayMessage('Not allowed to delete Handset and Accessories when changing IP Site configuration!', 'info');
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
        
        function CheckMacdBusinessRulesForRPAdd(componentName, configuration, relatedProduct ) {
        console.log('CheckMacdBusinessRulesForRPAdd');
        
        var changeTypeAttribute = configuration.attributes.filter(o => {
        return o.name === 'ChangeType'
    });
        
        if (changeTypeAttribute && relatedProduct.type === 'Related Component') {
        
        console.log('CheckMacdBusinessRulesForRPAdd - changeTypeAttribute ', changeTypeAttribute);
        
        /*  if (changeTypeAttribute[0].value === 'Active') {
                          CS.SM.displayMessage('Can not add related product when Change Type is Active', 'info');
                          CS.SM.deleteRelatedProducts(componentName, configuration.guid, [relatedProduct.guid]);
                      }
              */
        if (changeTypeAttribute[0].value === 'Cancel') {
        CS.SM.displayMessage('Not allowed to add  related products when canceling subscription!', 'info');
        CS.SM.deleteRelatedProducts(componentName, configuration.guid, [relatedProduct.guid]);
    } /*else if (changeTypeAttribute[0].value === 'Modify') {
                        if (relatedProduct.name === 'Hunt Group') {
                            CS.SM.displayMessage('Not allowed to add  Hunt Group when changing IP Site configuration!', 'info');
                            CS.SM.deleteRelatedProducts(componentName, configuration.guid, [relatedProduct.guid]);
                            return;
                        }
                    }*/
        else {
        if (changeTypeAttribute[0].value !== 'New') {
        if (relatedProduct.name === 'Managed Router') {
        CS.SM.displayMessage('Not allowed to add  Managed Device when Change Type is ' + changeTypeAttribute[0].value , 'info');
        CS.SM.deleteRelatedProducts(componentName, configuration.guid, [relatedProduct.guid]);
    }
    }
    }
        
        return;
    }
        
    }
        
        /******************************************************************************************
             * Author	   : Modified by Laxmi Rahate
             * Method Name : disableAddingBandwidthClipOn
             * Invoked When: BANDWIDTH CLIP ON needs to be disabled when the Access Type is Mobile Access
             * Description : 1. Shows an error msg to not add Bandwidth Clip On when Access Type is Mobile Access
             * Parameters  : 1. String : configuration which invokes this method
            
            
             ******************************************************************************************/
        function disableAddingBandwidthClipOn(componentName, config, relatedProduct ) {
        console.log('Bandwidth Config', config);
        //console.log( 'relatedProduct #### GUID' + relatedProduct.guid );
        var accessTypeMobile = false;
        
        config.attributes.forEach((attribute) =>
        {
        if (attribute.name === "Technology Type" && attribute.value === 'Mobile Access') {
        
        CS.SM.displayMessage('Not allowed to add  Bandwidth Clip On when Access Type is Mobile Access!', 'info');
        CS.SM.deleteRelatedProducts(componentName, config.guid, [relatedProduct.guid]);
    }
        
        console.log('The Access Type for this config is - ' +attribute.value  );
    }
        
        );
        return Promise.resolve(true);
    }
        
        /******************************************************************************************
             * Author	   : Malvika Sharma
             * Method Name : disableAddingIADDevice
             * Invoked When: IAD Device is added for Fixed seat user
             * Description : 1. Shows an error msg to not add IAD Device for Fixed seat user
             * Parameters  : 1. String : configuration which invokes this method
             ******************************************************************************************/
        function disableAddingIADDevice(componentName, config, relatedProduct ) {
        console.log('IAD Config', config);
        CS.SM.getActiveSolution().then((product) => {
        console.log('disableAddingIADDevice', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while adding IAD Config', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        console.log('check 1');
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var fixedSeatUserQty;
        var faxLineAttr  = 'No';
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        console.log('relatedConfig'+ relatedConfig.name);
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' /*&& relatedConfig.parentComponent === config.parentComponent*/) {
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        console.log('', userAttribute.name, userAttribute.displayValue, userAttribute.value);
        if (userAttribute.name === 'TypeUser' && userAttribute.displayValue === 'Fax Line') {
        console.log('Inside TypeUser Attribute');
        faxLineAttr  = 'Yes';
    }
        console.log('faxLineAttr ', faxLineAttr );
        /*console.log('condition', (fixedSeatAttr === 'Yes' && userAttribute.name === 'Quantity'));
                                                            if (fixedSeatAttr === 'Yes' && userAttribute.name === 'Quantity') {
                                                                console.log('Fixed Seat User Quantity', userAttribute.value);
                                                                fixedSeatUserQty = userAttribute.value;
                                                            }*/
    });
    }
        if (relatedConfig.name === 'IAD Device' && relatedConfig.type === 'Related Component' /*&& relatedConfig.guid === config.guid*/) {
        console.log('relatedConfig.name', relatedConfig.name);
        console.log('faxLineAttr -->', faxLineAttr );
        if (faxLineAttr === 'No') {
        CS.SM.displayMessage('Not allowed to add IAD Device for Fixed Seat User!', 'info');
        CS.SM.deleteRelatedProducts(componentName, config.guid, [relatedProduct.guid]);
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
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        /************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : disableAddingManagedDevice
             * Invoked When: Managed Device is added for IP Site manually
             * Description : 1. Shows an error msg to not add Managed Device for IP Site manually
             * Parameters  : 1. String : configuration which invokes this method
             ***********************************************************************************/
        function disableAddingManagedDevice(componentName, config, relatedProduct ) {
        var defaultManagedDevice = false;
        if (componentName === 'IP Site' && relatedProduct.name === 'Managed Router' && relatedProduct.type === 'Related Component') {
        if (relatedProduct.configuration) {
        relatedProduct.configuration.attributes.forEach((managedDvcAttribute) => {
        console.log('managedDvcAttribute', managedDvcAttribute.name, managedDvcAttribute.displayValue, managedDvcAttribute.value);
        if (managedDvcAttribute.name === 'Default' && managedDvcAttribute.value === true) {
        defaultManagedDevice = true;
    }
    });
        console.log('defaultManagedDevice', defaultManagedDevice);
        if (defaultManagedDevice === false) {
        CS.SM.displayMessage('Not allowed to add Managed Device!', 'info');
        CS.SM.deleteRelatedProducts(componentName, config.guid, [relatedProduct.guid]);
    }
    }
    }
    }
        
        /***********************************************************************************************
             * Author	   : Malvika Sharma
             * Method Name : updateOppforCancelledIPSiteConfig
             * Invoked When: change type is cancel
             * Description : 1. Fetched the Opportunity related to basket
             * Parameters  : 1. guid of IP Site Config
             ***********************************************************************************************/
        function updateOppforCancelledIPSiteConfig(guid) {
        CS.SM.getActiveSolution().then((product) => {
        console.log('updateOppforCancelledIPSiteConfig', product, guid);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var updateMap = [];
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating Change Type', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var inputMap = {};
        var basketId = CS.SM.session.basketId;
        inputMap['basketId'] = basketId;
        var updateMap = [];
        var opportunityId;
        if (ipSiteConfig.guid === guid) {
        CS.SM.WebService.performRemoteAction('SolutionOpportunityHelper', inputMap).then(values => {
        console.log('Remote Action Result1 : ' + values);
        console.log('Remote Action Result2 : ' + values["IP Site"]);
        updateMap[ipSiteConfig.guid] = values["IP Site"];
        updateMap[ipSiteConfig.guid] = [{name:"WaiveETC",value: {showInUi: true}}]; // show the checkbox on UI
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateOppforCancelledIPSiteConfig Attribute update', component));
});
}
});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}


/*************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : checkForTwoIPSites
             * Invoked When: Mobility Configuration is added
             * Description : 1. Shows an error msg to not add Mobility if 2 IP Sites are not added
             * Parameters  : 1. String : configuration which invokes this method
             ************************************************************************************/
function checkForTwoIPSites(compName, config) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('checkForTwoIPSites', product, compName, config);
        var stopAddingMobility = true;
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while adding Mobility', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 1) {
        stopAddingMobility = false;
    }
    }
    });
        if (stopAddingMobility === true) {
        CS.SM.displayMessage('Please add atleast 2 IP Sites before adding Mobility!', 'info');
        CS.SM.deleteConfigurations(compName, [config.guid], true);
    }
    }
    }
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        /*************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : populateRemainingTerm
             * Invoked When: solution is loaded
             * Description : Calls remote action for every IP site configuration and populate remaining term attribute
            
             ************************************************************************************/
                    function populateRemainingTerm() {
                    console.log('populateRemainingTerm');
                    
                    CS.SM.getActiveSolution().then((solution) => {
                    console.log('populateRemainingTerm Line 5347');
                    if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
                    console.log('populateRemainingTerm Line 5349');
                    if (solution.components && solution.components.length > 0) {
                    console.log('populateRemainingTerm Line 5351');
                    solution.components.forEach((comp) => {
                    console.log('populateRemainingTerm Line 5353');
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    var updateMap = [];
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    comp.schema.configurations.forEach((config) => {
                    console.log('populateRemainingTerm Line 5354');
                    /*  updateMap[config.guid] = [{
                                                    name: 'Remaining Term',
                                                    value: {
                                                        value: '',
                                                        displayValue: ''
                                                    }
                                                }];*/
                    
                    var contractTerm = 0;
                    if (config.contractTerm)
                    contractTerm = config.contractTerm;
                    
                    /*if (config.attributes && config.attributes.length > 0) {
                                                    var contractTermShadowAtrtribute = config.attributes.filter(obj => {
                                                        return obj.name === 'ContractTermShadow'
                                                    });
                                                    if (contractTermShadowAtrtribute && contractTermShadowAtrtribute.length > 0) {
                                                        contractTerm = contractTermShadowAtrtribute[0].value;
                                                    }
                                                }*/
                    
                    console.log('contractTerm: ', contractTerm);
                    if (contractTerm) {
                    let inputMap = {};
			console.log('getServiceForMAC configIdParent '+config.id);
		    inputMap['getServiceForMAC'] = config.id //Edge:92850
                    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
          	    console.log('getServiceForMAC finished with response: ', result); //Edge:92850
          	    var serviceStartDateString = result["getServiceForMAC"]; //Edge:92850          
		    if (serviceStartDateString) {
                    var serviceStartDate = new Date(JSON.parse(serviceStartDateString));
                    console.log('serviceStartDate: ', serviceStartDate);
                    var today = new Date();
                    today.setHours(0,0,0,0);
                    serviceStartDate.setHours(0,0,0,0);
                    // var remainingTerm = (contractTerm*30  - (today - serviceStartDate)) / 30;	   
                    
                    /*Added to fix Edge:92850
                                     **Pawan Devaliya start
                                     */
                    var calRemainingTerm = (contractTerm * 30 - ((today - serviceStartDate) / (1000 * 3600 * 24))) / 30;
                    var remainingTerm = Math.ceil(calRemainingTerm);
                    console.log('remainingTerm ' + remainingTerm);
						if(remainingTerm < 0){
							remainingTerm = 0;
						}
						else if(remainingTerm >= 0){
							//remainingTerm = remainingTerm;
						}
						else{
							remainingTerm = contractTerm;
						}
						
						console.log('remainingTerm 5762 '+remainingTerm);
                    //End Edge:92850											   
                    
                    updateMap[config.guid] = [{
                    name: 'RemainingTerm',
                    value: {
                        value: remainingTerm,
                        displayValue: remainingTerm
                    }
                }];
                                               console.log('Map:: ', updateMap);
                
                // Populating Remaining Term On User Fixed seat and Fax line
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    config.relatedProductList.forEach((relatedConfig) => {
                        console.log('Remaining Term: 5401');
                        if (relatedConfig.name.includes('User') && relatedConfig.type === 'Related Component') {
                        // relatedConfig.configuration.forEach((subrelatedConfig) => {
                        var subrelatedConfig = relatedConfig.configuration;
                        console.log('Remaining Term: 5404');
                        
                        updateMap[subrelatedConfig.guid] = [{
                        name: 'RemainingTerm',
                        value: {
                            value: remainingTerm,
                            displayValue: remainingTerm
                        }
                    }];
                                                      console.log('Remaining Term: ', updateMap);
                    
                    // });
                    
                }
            });
}
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('populateRemainingTerm Attribute Update1', component)); //Edge:92850
}
});
}
else {
    console.log('populateRemainingTerm-->Inside Else');
    if (config.relatedProductList && config.relatedProductList.length > 0) {
        config.relatedProductList.forEach((relatedConfig) => {
            console.log('Remaining Term: 5426');
            if (relatedConfig.name.includes('User') && relatedConfig.type === 'Related Component') {
            // relatedConfig.configuration.forEach((subrelatedConfig) => {
            console.log('Remaining Term: 5432');
            var remainingTermForUser = 36;
            updateMap[relatedConfig.configuration.guid] = [{
            name: 'Remaining Term',
            value: {
                value: remainingTermForUser,
                displayValue: remainingTermForUser
            }
        }];
                                          console.log('Remaining Term: ', updateMap);
        
        // });
        
    }
});
}
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('populateRemainingTerm Attribute Update2', component)); //Edge:92850
}

});

console.log('populateRemainingTerm - updating: ', updateMap);
		//Edge:92850	
//CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('populateRemainingTerm Attribute Update1', component));

}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

/********************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : fetchUserUnitPrice
             * Invoked When: User Type or User ZoneFromParent is changed
             * Description : 1. Updates the Unit Price of the User
             * Parameters  : 1. String : configuration guid of user product whose Quantity/ZoneFromParent is changed
             ******************************************************************************************************/
function fetchUserUnitPrice(guid) {
    console.log('fetchUserUnitPrice', guid);
    CS.SM.getActiveSolution().then((product) => {
        console.log('fetchUserUnitPrice', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating User Type/Quantity', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        var userType;
        var userZoneFromParent;
        relatedConfig.configuration.attributes.forEach((userAttribute) => {
        console.log('UserAttribute', userAttribute.name, userAttribute.displayValue, userAttribute.value);
        if (userAttribute.name === 'TypeUser' && userAttribute.displayValue) {
        userType = userAttribute.displayValue;
    }
        if (userAttribute.name === 'ZonefromParent' && userAttribute.value) {
        userZoneFromParent = userAttribute.value;
    }
    });
        if (userType && userZoneFromParent) {
        var inputMap = {};
        var updateMap = [];
        inputMap["TypeUser"] = userType;
        inputMap["ZonefromParent"] = userZoneFromParent;
        CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => {
        updateMap[guid] = values["User"];
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('fetchUserUnitPrice Attribute update', component));
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
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        /**********************************************************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : fetchHandSetAndIADDeviceUnitPrice
             * Invoked When: One Off Charge/Recurring Charge is changed
             * Description : 1. Updates the Unit Price of the HandSet and Accessories config or IAD Device config
             * Parameters  : 1. String : configuration guid of Handset and Accessories product/IAD Device whose One Off Charge/Recurring Charge is changed
             ********************************************************************************************************************************************/
                    function fetchHandSetAndIADDeviceUnitPrice(guid) {
                    console.log('fetchHandSetAndIADDeviceUnitPrice', guid);
                    CS.SM.getActiveSolution().then((product) => {
                    console.log('fetchHandSetAndIADDeviceUnitPrice', product);
                    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
                    if (product.components && product.components.length > 0) {
                    product.components.forEach((comp) => {
                    if (comp.name === COMPONENT_NAMES.ipSite) {
                    console.log('IP Site while updating Recurring Charge on Handset and IAD Device', comp);
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    comp.schema.configurations.forEach((ipSiteConfig) => {
                    if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
                    ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name === 'Handset and Accessories' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
                    var contractType;
                    var oneOffCharge;
                    var recurringCharge;
                    var updateMap = [];
                    relatedConfig.configuration.attributes.forEach((handsetAttribute) => {
                    console.log('HandsetAttribute', handsetAttribute.name, handsetAttribute.displayValue, handsetAttribute.value);
                    if (handsetAttribute.name === 'ContractType' && handsetAttribute.value) {
                    contractType = handsetAttribute.value;
                }
                    if (handsetAttribute.name === 'One Off Charge' && handsetAttribute.value) {
                    oneOffCharge = handsetAttribute.value;
                }
                    if (handsetAttribute.name === 'Recurring Charge' && handsetAttribute.value) {
                    recurringCharge = handsetAttribute.value;
                }
                });
                    if (contractType === 'Hardware Repayment') {
                    updateMap[guid] = [{
                    name: 'UnitPrice',
                    value: {
                        value: recurringCharge,
                        displayValue: recurringCharge
                    }
                }];
                                               CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
            } else {
                updateMap[guid] = [{
                    name: 'UnitPrice',
                    value: {
                        value: oneOffCharge,
                        displayValue: oneOffCharge
                    }
                }];
                CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
            }
}
else if (relatedConfig.name === 'IAD Device' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
    var contractType;
    var oneOffCharge;
    var recurringCharge;
    var updateMap = [];
    relatedConfig.configuration.attributes.forEach((iadDeviceAttribute) => {
        console.log('iadDeviceAttribute', iadDeviceAttribute.name, iadDeviceAttribute.displayValue, iadDeviceAttribute.value);
        if (iadDeviceAttribute.name === 'ContractType' && iadDeviceAttribute.value) {
        contractType = iadDeviceAttribute.value;
    }
        if (iadDeviceAttribute.name === 'One Off Charge' && iadDeviceAttribute.value) {
        oneOffCharge = iadDeviceAttribute.value;
    }
        if (iadDeviceAttribute.name === 'Recurring Charge' && iadDeviceAttribute.value) {
        recurringCharge = iadDeviceAttribute.value;
    }
    });
        if (contractType === 'Hardware Repayment') {
        updateMap[guid] = [{
        name: 'UnitPrice',
        value: {
            value: recurringCharge,
            displayValue: recurringCharge
        }
    }];
                                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
} else if (contractType === 'Purchase') {
    updateMap[guid] = [{
        name: 'UnitPrice',
        value: {
            value: oneOffCharge,
            displayValue: oneOffCharge
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
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
}).then(
    () => Promise.resolve(true)
);
}

async function updateAccesType () {
    
    console.log('updateAccesType');
    var solution;
    await CS.SM.getActiveSolution().then((sol) => {
        solution = sol;
    });
        
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        for (var i=0; i< solution.components.length; i++) {
        var comp = solution.components[i];
        if (comp.name === COMPONENT_NAMES.ipSite) {
        var updateMap = [];
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        for (var j=0;  j< comp.schema.configurations.length; j++) {
        var config = comp.schema.configurations[j];
        //	if (!guid || guid === config.guid) {
        console.log('updateAccesTyperr');
        
        var numberOfUsers = 3;
        var NBNAvailability = '';
        var NBNTechnologyType = '';
        var VacantCopperPairAvailable = '';
        var NBNCompatibility = '';
        var WidefeasCategory = '';
        var WorkCost = null;
        var TelstraFibreCompatibility = '';
        if (config.relatedProductList && config.relatedProductList.length > 0) {
        config.relatedProductList.forEach((relatedConfig) => {
        console.log('updateAccesTyperrssss' + relatedConfig.name);
        if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
        
        var userTypeAttr = relatedConfig.configuration.attributes.filter(a => {
        return a.name === 'TypeUser' && a.displayValue === 'Fixed Seat'
    });
        
        if (userTypeAttr && userTypeAttr.length > 0) {
        var quantityAttr = relatedConfig.configuration.attributes.filter(a => {
        return a.name === 'Quantity'
    });
        
        if (quantityAttr && quantityAttr.length > 0 && quantityAttr[0].value) {
        numberOfUsers = quantityAttr[0].value;
    }
    }
    }
    });
    }
        
        if (config.attributes && config.attributes.length > 0) {
        config.attributes.forEach((attribute) => {
        
        if (attribute.name === 'NBNAvailability' && attribute.value) {
        NBNAvailability = attribute.value.toLowerCase() === 'available' ? 'yes' : 'no';
    }
                                         
                                         if (attribute.name === 'NBNTechnologyType') {
        NBNTechnologyType = attribute.value;
    }
    
    if (attribute.name === 'SQVacantCopperPairs') {
        VacantCopperPairAvailable = attribute.value;
    }
    
    if (attribute.name === 'NBNCompatibility') {
        NBNCompatibility = attribute.value;
    }
    
    if (attribute.name === 'WidefeasCategory' && attribute.displayValue) {
        WidefeasCategory = attribute.displayValue;
    }
    
    if (attribute.name === 'WorkCost' && attribute.value) {
        WorkCost = attribute.value;
    }
    
    if (attribute.name === 'TelstraFibreCompatibility') {
        TelstraFibreCompatibility = attribute.value;
    }
    
});
}

var options = [];
options.push(ACCESS_TYPES.telstrFibreAccess);
options.push(ACCESS_TYPES.nbn);
options.push(ACCESS_TYPES.mobileAccess);
options.push(ACCESS_TYPES.noAccess);

console.log('before getAccessTypeRule', NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable, NBNCompatibility, WidefeasCategory, WorkCost, TelstraFibreCompatibility);

//	if (NBNAvailability && NBNTechnologyType && VacantCopperPairAvailable && NBNCompatibility &&  WidefeasCategory && WorkCost && TelstraFibreCompatibility) {
var rule = getAccessTypeRule(numberOfUsers, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable, NBNCompatibility, WidefeasCategory, WorkCost, TelstraFibreCompatibility);
if (rule) {
    console.log('Rule ', rule);
    options = rule.AccessType;
}
//}
await CS.SM.updateAttributePicklist(COMPONENT_NAMES.ipSite, config.guid, 'Technology Type', options).then((o) => {
    console.log('updateAccesType - updateAttributePicklist', o);
});
    
    if (options.length == 1) {
    var updateMap = [];
    updateMap[config.guid] = [{
    name: 'Technology Type',
    value: {
        value: options[0],
        displayValue: options[0]
    }
}];
                                                                                                          await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateAccesType Attribute update', component));
}

};
}
}
};
}
}
}

/******************************************************************************************
             * Author	   : Hitesh Gandhi
             * Method Name : updateNBNTechnologyTypeShadow
             * Invoked When: AccessType is updated/ Updates NBNTechnologyTypeShadow based on AccessType value.
            
             ******************************************************************************************/
function updateNBNTechnologyTypeShadow() {
    console.log('updateNBNTechnologyTypeShadow');
    
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        var updateMap = {};
                                   solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        updateMap = [];
        comp.schema.configurations.forEach((config) => {
        if (config.attributes && config.attributes.length > 0) {
        
        
        var TechnologyTypeAttribute = config.attributes.filter(a => {
        return a.name === 'Technology Type'
    });
    
    var NBNTechnologyType = config.attributes.filter(a => {
        return a.name === 'NBNTechnologyType'
    });
    
    if (TechnologyTypeAttribute && TechnologyTypeAttribute.length > 0 && NBNTechnologyType && NBNTechnologyType.length > 0)
    {
        var NBNTechnologyTypeShadowValue = '';
        console.log('TechnologyTypeAttribute', TechnologyTypeAttribute[0].value);
        if (TechnologyTypeAttribute[0].value && TechnologyTypeAttribute[0].value === "NBN Access") {
            NBNTechnologyTypeShadowValue = NBNTechnologyType[0].value;
        }
        console.log('NBNTechnologyTypeShadowValue', NBNTechnologyTypeShadowValue);
        updateMap[config.guid] = [{
            name: 'NBNTechnologyTypeShadow',
            value: {
                value: NBNTechnologyTypeShadowValue,
                displayValue: NBNTechnologyTypeShadowValue
            }
        }];
    }
}

});
}
});
console.log('updateNBNTechnologyTypeShadow - updating: ', updateMap);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(
    component => {
        console.log('updateNBNTechnologyTypeShadow Attribute Update', component);
        //  updateNBNTechnologyTypeShadow();
    });
    }
    }
    }).then(
        () => Promise.resolve(true)
        );
    }
        
        async function updateBandwidhtClipOnTechnologyData() {
        console.log('updateBandwidhtClipOnTechnologyData');
        
        var solution;
        await CS.SM.getActiveSolution().then((sol) => {
        solution = sol;
    });
        
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        for (var i = 0; i < solution.components.length; i++) {
        var comp = solution.components[i];
        if (comp.name === COMPONENT_NAMES.ipSite) {
        
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        for (var j = 0; j < comp.schema.configurations.length; j++) {
        config = comp.schema.configurations[j];
        var valueMap = {};
        
        var technologyTypeAttr = config.attributes.filter(o => {
        return o.name === 'Technology Type'
    });
        if (technologyTypeAttr && technologyTypeAttr.length > 0) {
        valueMap['Technology'] = technologyTypeAttr[0].displayValue;
    }
        
        var nbnTechnologyTypeAttr = config.attributes.filter(o => {
        return o.name === 'NBNTechnologyType'
    });
        if (nbnTechnologyTypeAttr && nbnTechnologyTypeAttr.length > 0) {
        valueMap['Technology Type'] = nbnTechnologyTypeAttr[0].value;
    }
        
        console.log('updateBandwidhtClipOnTechnologyData valueMap', valueMap);
        await setAttributeValuesForRelatedComponent(config.guid, 'Bandwidth Clip On', valueMap);
        
    }
    }
    }
    }
    }
    }
        
        
        return Promise.resolve(true);
    }
        
        
        /**************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateBWTierOnIPSiteConfig
             * Invoked When: Tier on Bandwidth Clip On is changed
             * Description : 1. Updates the Tier on Bandwidth Clip On product on IP Site Config
             * Parameters  : 1. String : configuration guid of Tier attr whose value change invokes this method
             *			   : 2. String : Tier value
             *************************************************************************************************/
        function updateBWTierOnIPSiteConfig(guid, tier) {
        console.log('BandwidthConfig', guid);
        CS.SM.getActiveSolution().then((product) => {
        console.log('updateBWTierOnIPSiteConfig', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating Bandwidth Clip On Tier', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        var ipSiteConfigGUID;
        var tierValue;
        comp.schema.configurations.forEach((ipSiteConfig) => {
        if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Bandwidth Clip On' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        ipSiteConfigGUID = ipSiteConfig.guid;
        relatedConfig.configuration.attributes.forEach((bwAttribute) => {
        console.log('bwAttribute', bwAttribute.name, bwAttribute.displayValue, bwAttribute.value);
        if (bwAttribute.name === 'Tier' && bwAttribute.value === tier) {
        console.log('Inside Tier Attribute');
        tierValue = bwAttribute.displayValue;
    }
    });
    }
    });
    }
    });
        console.log('ipSiteConfigGUID', ipSiteConfigGUID);
        if (ipSiteConfigGUID) {
        var updateMap = [];
        updateMap[ipSiteConfigGUID] = [{
        name: "TierSelected",
        value: {
            value: tierValue,
            displayValue: tierValue,
            readOnly: true,
            required: false
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, false).then(component => console.log('updateBWTierOnIPSiteConfig Attribute Update', component));
}
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

/*******************************************************************************************************************************
             * Author	   : Mahaboob Basha
             * Method Name : updateBandwidthOnIPSiteConfig
             * Invoked When: CountTotalUserQty OR TierSelected on IP Site is changed
             * Description : 1. Updates the Bandwidth on IP Site Config
             * Parameters  : 1. String : configuration guid of CountTotalUserQty OR TierSelected attr whose value change invokes this method
             ******************************************************************************************************************************/
function updateBandwidthOnIPSiteConfig(guid) {
    console.log('IPSiteConfig on CountTotalUserQty OR TierSelected', guid);
    CS.SM.getActiveSolution().then((product) => {
        console.log('updateBandwidthOnIPSiteConfig', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site while updating CountTotalUserQty OR TierSelected', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        if (ipSiteConfig.guid === guid || !guid) {
        var countTotalUserQty;
        var tierSelected = 0;
        var technologyType;
        var nbnTechnologyType;
        ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
        
        
        if (ipSiteAttribute.name === 'CountTotalUserQty' && ipSiteAttribute.value) {
        countTotalUserQty = ipSiteAttribute.value;
    }
        if (ipSiteAttribute.name === 'TierSelected' && ipSiteAttribute.value) {
        tierSelected = ipSiteAttribute.value;
    }
        if (ipSiteAttribute.name === 'Technology Type' && ipSiteAttribute.value) {
        technologyType = ipSiteAttribute.value;
    }
        if (ipSiteAttribute.name === 'NBNTechnologyType' && ipSiteAttribute.value) {
        nbnTechnologyType = ipSiteAttribute.value;
    }
    });
        console.log('updateBandwidthOnIPSiteConfig selections', countTotalUserQty , tierSelected , technologyType,nbnTechnologyType);
        if (countTotalUserQty && tierSelected != undefined && technologyType) {
        var inputMap = {};
        var updateMap = [];
        inputMap["CountTotalUserQty"] = countTotalUserQty;
        inputMap["TierSelected"] = tierSelected;
        inputMap["Technology"] = technologyType;
        inputMap["TechnologyType"] = nbnTechnologyType;
        CS.SM.WebService.performRemoteAction('SolutionHelper', inputMap).then(values => {
        console.log('values ', values);
        console.log('Bandwidth Calculation  ', values["IPSite"]);
        if ( values["IPSite"]) {
        updateMap[ipSiteConfig.guid] = values["IPSite"];
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, false).then(component => {
        console.log('updateBandwidthOnIPSiteConfig Attribute update', component);
        var ipSiteConfig = component.schema.configurations[0];
        var routerModel;
        var rounterVendor;
        ipSiteConfig.attributes.forEach((ipSiteAttribute) => {
        if (ipSiteAttribute.name === 'Router Model' && ipSiteAttribute.value) {
        routerModel = ipSiteAttribute.value;
    }
        if (ipSiteAttribute.name === 'Router Vendor' && ipSiteAttribute.value) {
        rounterVendor = ipSiteAttribute.value;
    }
    });
        if (routerModel && rounterVendor) {
        var mRouterConfigGUID;
        var updateMapChild = [];
        ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Managed Router' && relatedConfig.type === 'Related Component') {
        mRouterConfigGUID = relatedConfig.guid;
    }
    });
        if (mRouterConfigGUID) {
        updateMapChild[mRouterConfigGUID] = [{
        name: "Model",
        value: {
            value: routerModel,
            displayValue: routerModel,
            readOnly: true,
            required: false
        }
    },
                                   {
                                       name: "Vendor",
                                       value: {
                                           value: rounterVendor,
                                           displayValue: rounterVendor,
                                           readOnly: true,
                                           required: false
                                       }
                                   }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMapChild, false).then(component => console.log('updateBWTierOnIPSiteConfig MRouter Attribute Update', component));
}
}

});
} else {
    var updateMap2 = {};
    updateMap2[ipSiteConfig.guid] = [{
        name: "Bandwidth",
        value: {
            value: 'NA',
            displayValue: 'NA',
            readOnly: true,
            required: false
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap2, false);
}
});
} else {
    var updateMap1 = {};
    updateMap1[ipSiteConfig.guid] = [{
        name: "Bandwidth",
        value: {
            value: 'NA',
            displayValue: 'NA',
            readOnly: true,
            required: false
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap1, false);
}
}
});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}

/**************************************************************************************
             * Author	   : Violeta Jalsic
             * Method Name : setMessageBankUnitPrice
             * Invoked When: Changed Message Bank for Mobility
             * Description : 1. Call remoteaction to get Unit Price for selected Message Bank
             * Parameters  : Message Bank string
             **************************************************************************************/
function setMessageBankUnitPrice(guid, messageBank){
    if (messageBank){
        console.log('setMessageBankUnitPrice for messageBank:', messageBank);
        var inputMap = {};
        inputMap["GetMobileUnitPrice"] = messageBank;
        CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
            console.log('GetMobileUnitPrice: ', values);
            mobileUnitPrice = values["GetMobileUnitPrice"]
            console.log('GetMobileUnitPrice: ', mobileUnitPrice);
            
            if(mobileUnitPrice == null || mobileUnitPrice == ''){
            mobileUnitPrice = 0;
            mobileUnitPrice = mobileUnitPrice.toFixed(2);
        }
            
            let updateConfigMap = {};
            updateConfigMap[guid] = [{
            name: 'MessageBankUnitPrice',
            value: mobileUnitPrice
        }];
                                                                                    
                                                                                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true);
    });
}
}

/**************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : updateConfigurationsName
             * Invoked When: solution is loaded or configuration is added
             * Description : Sets configuration name
             * Parameters  : configuration guid or left empty if doing for all configs
             **************************************************************************************/
async function updateConfigurationsName() {
    
    console.log('updateConfigurationsName');
    
    var updateConfigMapIpSites = {};
    var updateConfigMapMobility = {};
    var mobilityCount = 0;
    var ipSiteCount = 0;
    
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        
        solution.components.forEach((comp) => {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        
        console.log('updateConfigurationsName configurationName: ', config.configurationName);
        
        var changeTypeAttribute = config.attributes.filter(a => {
        return a.name === 'ChangeType' && a.displayValue
    });
    
    if (comp.name === COMPONENT_NAMES.ipSite) {
        
        ipSiteCount = ipSiteCount+ 1;
        
        var newSiteName = ipSiteCount + '. IP Site'
        
        var attribute = config.attributes.filter(a => {
            return a.name === 'Site Name'
        });
        
        if (attribute && attribute.length > 0) {
            newSiteName = newSiteName + ' | ' + attribute[0].value;
        }
        
        if (changeTypeAttribute && changeTypeAttribute.length > 0) {
            newSiteName = newSiteName + ' | ' + changeTypeAttribute[0].value;
        }
        
        
        updateConfigMapIpSites[config.guid] = [{
            name: 'ConfigName',
            value: newSiteName
        }];
    }
    /*
                                        if (comp.name === COMPONENT_NAMES.mobility) {
                                            mobilityCount = mobilityCount + 1;
                                            var newMobilityName = mobilityCount + '. Mobility';
                                            if (config.relatedProductList && config.relatedProductList.length > 0) {
                                                config.relatedProductList.forEach((relatedConfig) => {
                                                    if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component' ) {
            
                                                        var modelAtt = relatedConfig.configuration.attributes.filter(a => {
                                                            return a.name === 'MobileHandsetModel' && a.displayValue
                                                        });
                                                        if (modelAtt && modelAtt.length > 0) {
                                                            newMobilityName = newMobilityName + ' | ' + modelAtt[0].displayValue;
                                                        }
                                                    }
                                                });
                                            }
            
                                            if (changeTypeAttribute && changeTypeAttribute.length > 0) {
                                                newMobilityName = newMobilityName + ' | ' + changeTypeAttribute[0].value;
                                            }
            
                                            updateConfigMapMobility[config.guid] = [{
                                                name: 'ConfigName',
                                                value: newMobilityName
                                            }];
                                        }*/
                
            });
}
});
}
}
});

if (updateConfigMapIpSites && Object.keys(updateConfigMapIpSites).length > 0) {
    console.log('updateConfigurationsName updateConfigMapIpSites ', updateConfigMapIpSites);
    await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateConfigMapIpSites, true);
}
/*
                if (updateConfigMapMobility && Object.keys(updateConfigMapMobility).length > 0) {
                    console.log('updateConfigurationsName updateConfigMapMobility ', updateConfigMapMobility);
                    await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobility, updateConfigMapMobility, true);
                }
            */
return Promise.resolve(true);
}


/**********************************************************************************************************************************************
             * Author	   : Violeta Jalsic
             * Method Name : fetchMobileDeviceUnitPrice
             * Invoked When: One Off Charge/Recurring Charge is changed
             * Description : 1. Updates the Unit Price of the Mobile Device config
             * Parameters  : 1. String : configuration guid of Mobile Device whose One Off Charge/Recurring Charge is changed
             ********************************************************************************************************************************************/
function fetchMobileDeviceUnitPrice(guid) {
    console.log('fetchMobileDeviceUnitPrice', guid);
    CS.SM.getActiveSolution().then((product) => {
        console.log('fetchMobileDeviceUnitPrice', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        console.log('Mobile Device while updating Recurring Charge:', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((mobileConfig) => {
        if (mobileConfig.relatedProductList && mobileConfig.relatedProductList.length > 0) {
        mobileConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
        var contractType;
        var oneOffCharge;
        var recurringCharge;
        var updateMap = [];
        relatedConfig.configuration.attributes.forEach((deviceAttribute) => {
        console.log('DeviceAttribute', deviceAttribute.name, deviceAttribute.displayValue, deviceAttribute.value);
        if (deviceAttribute.name === 'PaymentTypeLookup' && deviceAttribute.displayValue) {
        contractType = deviceAttribute.displayValue;
    }
        if (deviceAttribute.name === 'OC' && deviceAttribute.value) {
        oneOffCharge = deviceAttribute.value;
    }
        if (deviceAttribute.name === 'RC' && deviceAttribute.value) {
        recurringCharge = deviceAttribute.value;
    }
    });
        if (contractType === 'Hardware Repayment') {
        if(recurringCharge != undefined){
        updateMap[guid] = [{
        name: 'UnitPrice',
        value: {
            value: recurringCharge,
            displayValue: recurringCharge
        }
    }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
}
} else {
    if(oneOffCharge != undefined){
        updateMap[guid] = [{
            name: 'UnitPrice',
            value: {
                value: oneOffCharge,
                displayValue: oneOffCharge
            }
        }];
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true).then(component => console.log('fetchHandSetAndIADDeviceUnitPrice Attribute update', component));
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
}).then(
    () => Promise.resolve(true)
);
}

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : updateOeStatus
             * Invoked When: beforeSave
             * Description : 1. Updates isNumberEnrichComplete attribute
             * Parameters  :
             ********************************************************************************************************************************************/
async function updateOeStatus() {
    
    console.log('updateOeStatus');
    var updateMapMobility = {};
    var updateMapIpSites = {};
    var componentsIpSite;
    var componentsMobility;
    var componentsUc;
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        componentsMobility = comp;
    }
                                         if (comp.name === COMPONENT_NAMES.ipSite) {
        componentsIpSite = comp;
    }
    if (comp.name === COMPONENT_NAMES.uc) {
        componentsUc = comp;
    }
});
}
}
}).then(() => Promise.resolve(true));

if (componentsIpSite)
    updateMapIpSites = await getOeStatusMap(componentsIpSite);
if (componentsMobility)
    updateMapMobility = await getOeStatusMap(componentsMobility);

console.log('updateOeStatus updateMapMobility: ', updateMapMobility);
if (Object.keys(updateMapMobility).length > 0)
    await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapMobility, true).then(component => console.log('updateOeStatus Mobility completed: ', component));
console.log('updateOeStatus updateMapIpSites: ', updateMapIpSites);
if (Object.keys(updateMapIpSites).length > 0)
    await CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMapIpSites, true).then(component => console.log('updateOeStatus IpSites completed: ', component));

if (componentsUc) {
    await checkUcOeRules(componentsUc);
}

}

async function getOeStatusMap(comp) {
    var updateMap = {};
    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        for (var i=0; i<comp.schema.configurations.length; i++ ) {
            var config = comp.schema.configurations[i];
            var fixedSeatUserQty = 0;
            if (comp.name === COMPONENT_NAMES.ipSite && config.relatedProductList && config.relatedProductList.length > 0) {
                config.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component') {
                    var fty = relatedConfig.configuration.attributes.filter(a => {return a.name === 'TypeUser' && a.displayValue === 'Fixed Seat'});
                if (fty && fty.length > 0) {
                    var cntAttr = relatedConfig.configuration.attributes.filter(a => {return a.name === 'Quantity'});
                    if (cntAttr && cntAttr.length > 0){
                        fixedSeatUserQty += cntAttr[0].value;
                    }
                }
            }
        });
    }
    var isNumberEnrichComplete = false;
    var totalNumbers = 0;
    await CS.SM.getOrderEnrichmentList(comp.name, config.guid).then((oelist) => {
        oelist.forEach((oe) => {
        if (oe.attributes) {
        var attributeIp = oe.attributes.filter(obj => {
        return (obj.name === 'FNN' && obj.value)
    });
        if (attributeIp && attributeIp.length > 0) {
        isNumberEnrichComplete = true;
        totalNumbers += 1;
    }
        
        var attributeMob = oe.attributes.filter(obj => {
        return (obj.name === 'MobileNumber' && obj.value)
    });
        if (attributeMob && attributeMob.length > 0) {
        isNumberEnrichComplete = true;
    }
    }
    });
    });
        
        updateMap[config.guid] = [];
        
        if (comp.name === COMPONENT_NAMES.ipSite) {
        
        if (fixedSeatUserQty > totalNumbers)
        isNumberEnrichComplete = false;
        
        updateMap[config.guid].push({
        name: 'TotalNumbers',
        value: {
            value: totalNumbers,
            displayValue: totalNumbers
        }
    });
    
    updateMap[config.guid].push({
        name: 'TotalUserQty',
        value: {
            value: fixedSeatUserQty,
            displayValue: fixedSeatUserQty
        }
    });
    
}

if (comp.name === COMPONENT_NAMES.mobileSubscription) {
    var isDeliveryDetailsEnriched = false;
    var siteDeliveryAddressAttribute = config.attributes.filter(a => {return (a.name ==='SiteDeliveryAddress' || a.name ==='SiteDeliveryContact') &&  a.value});
    if (siteDeliveryAddressAttribute && siteDeliveryAddressAttribute.length>=2) {
        isDeliveryDetailsEnriched = true;
    }
    updateMap[config.guid].push({
        name: 'IsDeliveryDetailsEnriched',
        value: {
            value: isDeliveryDetailsEnriched,
            displayValue: isDeliveryDetailsEnriched
        }
    });
}

updateMap[config.guid].push({
    name: 'isNumberEnrichComplete',
    value: {
        value: isNumberEnrichComplete,
        displayValue: isNumberEnrichComplete
    }
});


}
}

return updateMap;
}

async function checkUcOeRules(comp) {
    
    if (!comp) {
        await CS.SM.getActiveSolution().then((solution) => {
            if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
            if (solution.components && solution.components.length > 0) {
            solution.components.forEach((cmp) => {
            if (cmp.name === COMPONENT_NAMES.uc) {
            comp = cmp;
        }
                                             });
    }
}
}).then(() => Promise.resolve(true));
}

if (comp.name !== COMPONENT_NAMES.uc)
    return;

if (basketStage !== 'Contract Accepted') {
    return;
}
console.log('checkUcOeRules ');
var updateMap = {};
if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
    for (var i = 0; i < comp.schema.configurations.length; i++) {
        var config = comp.schema.configurations[i];
        console.log('checkUcOeRules ',config);
        
        var attr = config.attributes.filter(a => {
            return a.name === 'Orderprimarycontactid' && a.value
        });
        console.log('checkUcOeRules attr', attr);
        
        if (attr && attr.length > 0) {
            updateConfigurationStatus('UC_OPC', COMPONENT_NAMES.uc, config.guid, true, '');
        } else {
            updateConfigurationStatus('UC_OPC', COMPONENT_NAMES.uc, config.guid, false, 'Select Order Primary Contact');
        }
        
    }
}
}

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : addDefaultOEConfigs
             * Invoked When: after solution is loaded, after configuration is added
             * Description : 1. Adds one oe config for each comonent config if tehere is none (NumberManagementv1 is excluded)
             * Parameters  : none
             ********************************************************************************************************************************************/
async function addDefaultOEConfigs(){
    
    if (basketStage !== 'Contract Accepted')
        return;
    console.log('addDefaultOEConfigs');
    var oeMap = [];
    await CS.SM.getActiveSolution().then((currentSolution) => {
        //console.log('addDefaultOEConfigs ',  currentSolution.name,  COMPONENT_NAMES.solution);
        if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
        //console.log('addDefaultOEConfigs - looking components', currentSolution);
        if (currentSolution.components && currentSolution.components.length > 0) {
        currentSolution.components.forEach((comp) => {
        comp.schema.configurations.forEach((config) => {
        comp.orderEnrichments.forEach((oeSchema) => {
        //Added the addition if condition for UC by Mahaboob o 27/07/2019 as UC is used across 2 solutions
        if (!oeSchema.name.toLowerCase().includes('numbermanagementv1') && !(config.name === 'Unified Communication' && oeSchema.name === 'Customer requested Dates')) {
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
    oeMap.push(el);
    console.log('Adding default oe config for:',comp.name,config.name, oeSchema.name );
}

}
});
});
});
}
}
}).then(() => Promise.resolve(true));
//console.log('addDefaultOEConfigs prepared');
if (oeMap.length> 0) {
    var map = [];
    map.push({});
    console.log('Adding default oe config map:',oeMap);
    for (var i=0; i< oeMap.length;i++) {
        await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
    };
}

await initializeOEConfigs();
return Promise.resolve(true);
}

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : initializeOEConfigs
             * Invoked When: after solution is loaded, after configuration is added
             * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
             * Parameters  : oeguid or none
             ********************************************************************************************************************************************/
async function initializeOEConfigs(oeguid){
    console.log('initializeOEConfigs');
    var currentSolution;
    await CS.SM.getActiveSolution().then((solution) => {
        currentSolution = solution;
        console.log('initializeOEConfigs - getActiveSolution');
    }).then(() => Promise.resolve(true));
        
        if (currentSolution) {
        console.log('initializeOEConfigs - updating');
        if (currentSolution.type && currentSolution.name.includes(COMPONENT_NAMES.solution)) {
        if (currentSolution.components && currentSolution.components.length > 0) {
        for (var i=0; i<currentSolution.components.length; i++) {
        var comp = currentSolution.components[i];
        for (var j=0; j<comp.schema.configurations.length; j++) {
        var config = comp.schema.configurations[j];
        var updateMap = {};
        if (config.orderEnrichmentList) {
        for (var k = 0; k < config.orderEnrichmentList.length; k++) {
        var oe = config.orderEnrichmentList[k];
        
        if (oeguid && oeguid !== oe.guid)
        continue;
        
        var basketAttribute = oe.attributes.filter(a => {
        return a.name.toLowerCase() === 'basketid'
    });
        if (basketAttribute && basketAttribute.length > 0) {
        if (!updateMap[oe.guid])
        updateMap[oe.guid] = [];
        
        updateMap[oe.guid].push({name: basketAttribute[0].name, value: basketId});
}

if (comp.name === COMPONENT_NAMES.ipSite) {
    
    var funcprimarycontactAttribute = oe.attributes.filter(a => {
        return a.name === 'Funcprimarycontact'
    });
    if (funcprimarycontactAttribute && funcprimarycontactAttribute.length > 0) {
        var siteIDAttribute = config.attributes.filter(a => {
            return a.name === 'Site ID'
        });
        if (siteIDAttribute && siteIDAttribute.length > 0) {
            let inputMap = {
                object: 'funccontact',
                id: siteIDAttribute[0].value
            };
            await CS.SM.WebService.performRemoteAction('OEDataProvider', inputMap).then((values) => {
                console.log('initializeOEConfigs - Funcprimarycontact:', values);
                if (values && values.length > 0 && values.response[0].Id) {
                if (!updateMap[oe.guid])
                updateMap[oe.guid] = [];
                
                updateMap[oe.guid].push({
                name: funcprimarycontactAttribute[0].name,
                value: values.response[0].Id
            });
        }
    }).then(() => Promise.resolve(true));
    
}
}

}
}
}
if (updateMap && Object.keys(updateMap).length > 0) {
    console.log('initializeOEConfigs updateMap:', updateMap);
    await CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
}
};
};
}
}
}

return Promise.resolve(true);
}

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : updateOeTabsVisibility
             * Invoked When: after solution is loaded, after ChangeType is changed
             * Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
             * Parameters  : configuration guid or nothing
             ********************************************************************************************************************************************/
function updateOeTabsVisibility(configGuid) {
    
    console.log('updateOeTabsVisibility');
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        
        let oeToShow = [];
        comp.orderEnrichments.forEach((oeSchema) => {
        if (!oeSchema.name.toLowerCase().includes('number')) {
        oeToShow.push(oeSchema.name);
    }
                                   });
    
    comp.schema.configurations.forEach((config) => {
        if (!configGuid || configGuid === config.guid) {
        if (config.attributes && config.attributes.length > 0) {
        
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
    });
    //console.log('updateOeTabsVisibility', basketChangeType, changeTypeAtrtribute, basketStage);
    if ((basketChangeType === 'Change Solution' && changeTypeAtrtribute && changeTypeAtrtribute.length > 0) ||
        (/*basketStage !== 'Contract Accepted')*/ !Utils.isOrderEnrichmentAllowed())) {
        CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
        console.log('updateOeTabsVisibility - hiding:', comp.name, config.guid);
    } else {
        //Commented the below line & add if else block by Mahaboob on 27/09/2019 as UC PD is used across 2 solutions with different OE Schema
        //CS.SM.setOEtabsToLoad(comp.name, config.guid, undefined);
        if (config.name === 'Unified Communication') {
            CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Order primary Contact']);
        } else {
            CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
        }
        console.log('updateOeTabsVisibility - showing:', comp.name, config.guid);
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

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : beforeSaveValidation
             * Invoked When: in beforeSave hook
             * Description : 1. do the validation before save
             * Parameters  :
             ********************************************************************************************************************************************/
async function beforeSaveValidation() {
    
    console.log('beforeSaveValidation');
    var isValid = true;
    if (await checkForValidNumberOfNonCanceledIpSites() === false)
    isValid = false;
    
    return isValid;
}

/**********************************************************************************************************************************************
             * Author	   : Tihomir Baljak
             * Method Name : checkForValidNumberOfNonCanceledIpSites
             * Invoked When: in beforeSaveValidation function
             * Description : 1. checks if solution contains valid number of ip sites : all canceled or at leas two with change type != cancel
             * Parameters  :
             ********************************************************************************************************************************************/
async function checkForValidNumberOfNonCanceledIpSites() {
    
    if (basketChangeType !== 'Change Solution') {
        return true;
    }
    console.log('checkForValidNumberOfNonCanceledIpSites');
    var count = 0;
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.attributes && config.attributes.length > 0) {
        
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType' && obj.displayValue !== 'Cancel'
    });
    console.log('checkForValidNumberOfNonCanceledIpSites changeTypeAtrtribute', changeTypeAtrtribute);
    if (changeTypeAtrtribute &&  changeTypeAtrtribute.length > 0) {
        count = count + 1;
    }
}
});
}
});
}
}
});
console.log('checkForValidNumberOfNonCanceledIpSites count', count);
if (count === 1) {
    CS.SM.displayMessage('Not allowed to save Solution with only one active IP Site!', 'error');
    return false;
}
return true;
}


/************************************************************************************
             * Author	: Venkata Ramanan G
             * Method Name : disableaddingmultipleMobileDevices
             * Invoked When: Mobile Device Related product is added to the Mobility component
             * Description : 1. Shows an error msg to not to add more than 1 MD
             * Parameters : 1. String : Component name in the solution 2. String : configuration which invokes this method 3. String : Related Products for the configuration
             ***********************************************************************************/
function disableAddingMobileDevice(componentName, config, relatedProduct) {
    if (componentName === COMPONENT_NAMES.mobileSubscription && relatedProduct.name === 'Mobile Device' && relatedProduct.type === 'Related Component') {
        console.log('check inside disableAddingMobileDevice function');
        
        if (config.relatedProductList && config.relatedProductList.length > 1) {
            CS.SM.displayMessage('Not allowed to add more than 1 Mobile Device!', 'info');
            CS.SM.deleteRelatedProducts(componentName, config.guid, [relatedProduct.guid]);
        }
    }
}
/************************************************************************************
             * Author	: Sasidhar
             * Method Name : updateRemainingTerm
             * Invoked When: TO compute remaining term and reset MRO bonus to zero for remaining term =0 on solution Load for mobility 
             * Description : To compute remaining term
            */
function updateRemainingTerm(product) {
    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        var remainingTerm='';
        if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
                if (comp.name === COMPONENT_NAMES.mobileSubscription && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                comp.schema.configurations.forEach((mobilityConfig) => {
                console.log("Mobility Config", mobilityConfig);
                var changeTypeList = mobilityConfig.attributes.filter(att => { return att.name === "ChangeType"});
            var contractTermList = mobilityConfig.attributes.filter(att => { return att.name === "Contract Term"});
            
            
            if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
                let updateConfigMap = {};
                mobilityConfig.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component') {
                    relatedConfig.configuration.attributes.forEach((relConfigAttr) => {
                    //console.log(event.type);
                    if (relConfigAttr.name === 'PaymentTypeLookup' && relConfigAttr.displayValue === 'Hardware Repayment' && contractTermList && contractTermList.length>0) {
                    
                    if(changeTypeList && changeTypeList.length>0 && changeTypeList[0].value === "Modify"){
                    remainingTermMobilityUpdate(mobilityConfig,contractTermList[0].displayValue )
                }   
                                                          }
                                                          });
            }
        });
    }
});

}
});
}
}
}

/************************************************************************************
             * Author	: Aditya Pareek
             * Method Name : updatecontracttermattribute
             * Invoked When: Mobile Device is added to the Mobility component
             * Description : 1. Hide the Term attribute if Payment type is Purchase
             * Parameters : 1. String : Current solution which invokes this method
             ***********************************************************************************/
function updatecontracttermattribute(product) {
    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && product.components.length > 0) {
            product.components.forEach((comp) => {
                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                let updateConfigIdMap = {}; //Added by Jayesh to update Mobility ConfigId Attribute - Bug fix - EDGE-115533
                                       comp.schema.configurations.forEach((mobilityConfig) => {
                console.log(mobilityConfig.name);
                //Added by Jayesh to update Mobility ConfigId Attribute - Bug fix - EDGE-115533
                mobilityConfig.attributes.forEach((ConfigAttr) => {
                console.log(ConfigAttr.name);
                if (ConfigAttr.name === 'ConfigId') {
                updateConfigIdMap[mobilityConfig.guid] = [{
                name: 'ConfigId',
                value: {
                    value: mobilityConfig.id,
                    displayValue: mobilityConfig.id
                }
            }];
            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigIdMap, true);  
        }
    });
    // Jayesh changes end
    if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
        let updateConfigMap = {};
        mobilityConfig.relatedProductList.forEach((relatedConfig) => {
            if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component') {
            relatedConfig.configuration.attributes.forEach((relConfigAttr) => {
            //console.log(event.type);
            if (relConfigAttr.name === 'PaymentTypeLookup') {
            if (relConfigAttr.displayValue === 'Purchase') {
            
            updateConfigMap[relatedConfig.configuration.guid] = [{
            name: 'ContractTermLookup',
            value: {
            showInUi: false,
            required: false,
            value: 'NA'
        }
                                                  }];
                                                  } else {
                                                  updateConfigMap[relatedConfig.configuration.guid] = [{
                                                  name: 'ContractTermLookup',
                                                  value: {
                                                  showInUi: true,
                                                  required: true
                                                  }
                                                  }];
                                                  }
                                                  }
                                                  
                                                  });
        CS.SM.updateConfigurationAttribute('Mobile Device', updateConfigMap, true);
    }
});
}
});
}
}
});
}
}
}

/****************************************************
             * Author	   : Mahaboob Basha
             * Method Name : blankOutCRDAttributesOnMACD
             * Invoked When: CWP Solution is Loaded
             * Description : 1. Blanks out CRD Attributes on MACD
             * Parameters  : None
             ***************************************************/
function blankOutCRDAttributesOnMACD() {
    console.log('blankOutCRDAttributesOnMACD');
    
    CS.SM.getActiveSolution().then((product) => {
        console.log('blankOutCRDAttributesOnMACD', product);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.ipSite) {
        console.log('IP Site in blankOutCRDAttributesOnMACD', comp);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((ipSiteConfig) => {
        var updateMap = {};
        if (ipSiteConfig.id && ipSiteConfig.orderEnrichmentList && ipSiteConfig.orderEnrichmentList.length > 0) {
        ipSiteConfig.orderEnrichmentList.forEach((ipSiteOEConfig) => {
        //if (ipSiteOEConfig.name && ipSiteOEConfig.name.includes('Customer requested Dates')) {
        //updateMap[ipSiteOEConfig.guid] = [];
        var blankedOutAttribute = ipSiteOEConfig.attributes.filter(a => {
        return a.name === 'BlankedOut'
    });
        var nbcAttribute = ipSiteOEConfig.attributes.filter(a => {
        return a.name === 'Not Before CRD'
    });
        var pcAttribute = ipSiteOEConfig.attributes.filter(a => {
        return a.name === 'Preferred CRD'
    });
        console.log('blankedOutAttribute', blankedOutAttribute, blankedOutAttribute[0]);
        console.log('nbcAttribute', nbcAttribute);
        console.log('pcAttribute', pcAttribute);
        if (blankedOutAttribute && blankedOutAttribute[0] && (blankedOutAttribute[0].value === '' || blankedOutAttribute[0].value === false)) {
        updateMap[ipSiteOEConfig.guid] = [];
        if (nbcAttribute && nbcAttribute[0] && nbcAttribute[0].value) {
        updateMap[ipSiteOEConfig.guid].push({
        name: "Not Before CRD",
        value: null
    });
}
if (pcAttribute && pcAttribute[0] && pcAttribute[0].value) {
    updateMap[ipSiteOEConfig.guid].push({
        name: "Preferred CRD",
        value: null
    });
}
}
console.log('blankOutCRDAttributesOnMACD updateMap:', updateMap);
if (updateMap && Object.keys(updateMap).length > 0) {
    updateMap[ipSiteOEConfig.guid].push({
        name: "BlankedOut",
        value: {
            value: true,
            displayValue: true,
            readOnly: false,
            required: false
        }
    });
    //CS.SM.updateOEConfigurationAttribute(comp.name, ipSiteOEConfig.guid, updateMap, false).then((crdOEConfig) => {
    //console.log('blankOutCRDAttributesOnMACD Attribute Update', crdOEConfig);
    //Promise.resolve(true);
    //});
    CS.SM.updateOEConfigurationAttribute(comp.name, ipSiteConfig.guid, updateMap, false).then( crdOEConfig => console.log('blankOutCRDAttributesOnMACD Attribute Update', crdOEConfig));
}
//}
});
}
});
}
}
});
}
}
}).then(
    () => Promise.resolve(true)
);
}
/************************************************************************************
             * Author	: Venkata Ramanan G
             * Method Name : showMDMtenancynotification
             * Defect/US # : EDGE-30181
             * Invoked When: Mobility configuration is added to the Mobility component
             * Description : Show Toast message about the MDM Tenancy
             * Parameters : N/A
             ***********************************************************************************/
CWPPlugin.showMDMtenancynotification = function() {
    
    CS.SM.getActiveSolution().then((product) => {
        if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        if (product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        if (comp.schema.configurations.length > 0) {
        CS.SM.displayMessage('Please note that you may require MDM Tenancy to this order. If it is required please add it from Solutions', 'info');
    }
                                   }
                                   
                                   });
}
}
});

}


/************************************************************************************
             * Author	: Manjunath Ediga
             * Method Name : updateTotalPlanBonusAndRemainingTerm
             * Invoked When: TO Reset remaining term and Total Plan Bonus to zero for Cancel Attribute update on mobility Product
             * Description : To set remaining term and Total Plan Bonus to Zero
            */
function updateTotalPlanBonusAndRemainingTerm(guid) {
    CS.SM.getActiveSolution().then((product) => {
        console.log('updateTotalPlanBonusAndRemainingTerm', product, guid);
        if (product.type && product.name.includes(COMPONENT_NAMES.solution) && product.components && product.components.length > 0) {
        product.components.forEach((comp) => {
        console.log('TotalPlanBonus and remainingTerm while updating Change Type', comp);
        if (comp.name === COMPONENT_NAMES.mobileSubscription && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((mobilityConfig) => {
        var totalPlanBonusList = mobilityConfig.attributes.filter(att => { return att.name === "TotalPlanBonus"});
        //var totalPlanBonusList = mobilityConfig.attributes.filter(att => { return att.name === "TotalPlanBonus"});
        
        if (mobilityConfig.relatedProductList && mobilityConfig.relatedProductList.length > 0) {
        mobilityConfig.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component') {
        relatedConfig.configuration.attributes.forEach((relConfigAttr) => {
        //console.log(event.type);
        if (relConfigAttr.name === 'PaymentTypeLookup' && relConfigAttr.displayValue === 'Hardware Repayment' && mobilityConfig.guid === guid && totalPlanBonusList && totalPlanBonusList.length>0) {
        if(totalPlanBonusList[0].value === undefined || totalPlanBonusList[0].value === "" || totalPlanBonusList[0].value === "0" || parseInt(totalPlanBonusList[0].value)> 0){
        var cancelOrderAttributes = {};
        cancelOrderAttributes[mobilityConfig.guid] = [{
        name: 'TotalPlanBonus',
        value: {
            value: 0,
            displayValue: 0
        }
    },{
        name: 'Remaining Term',
        value: {
            value: 0,
            displayValue: 0
        }
    }];
                                   CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription,cancelOrderAttributes,false).then();      
}
}
});
}
});
}
});
}

});
}
}).then(
    () => Promise.resolve(true)
);
}

/************************************************************************************
             * Author	: Vasanthi Sowparnika
             * Method Name : getInContractMobileDevices
             * Description : To set inContractDeviceCount
             * Extracted from CMP js file as part of Mobile retrofit
            */
CWPPlugin.getInContractMobileDevices = function(parentConfig){
    let inContractDeviceCount = 0;
    if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
        parentConfig.relatedProductList.forEach((relatedProduct) => {
            if (relatedProduct.name === COMPONENT_NAMES.device && relatedProduct.type === 'Related Component') {
            relatedProduct.configuration.attributes.forEach((attribute) => {
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

/************************************************************************************
             * Author	: Vasanthi Sowparnika
             * Method Name : UpdateRemainingTermOnParentCWP
             * Description : RemainingTerm calculate on Mobile subscription
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
function UpdateRemainingTermOnParentCWP(){
    CS.SM.getActiveSolution().then((solution) => {
        if (solution.name.includes(COMPONENT_NAMES.solution)) {
        var updateRemainingTermMap = {};
                                   if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {        
            updateRemainingTermMap[config.guid] = [];                        
            if (config.relatedProductList && config.relatedProductList.length === 1) {
            config.relatedProductList.forEach((relatedConfig) => {
            if (relatedConfig.name.includes('Device')) {
            if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
            var cancelFlag = '';
            var remainingTerm = 0;
            var remainingTermAttribute = relatedConfig.configuration.attributes.filter(obj => {
            return obj.name === 'RemainingTerm'
        });
        
        var cancelFlagAttribute = relatedConfig.configuration.attributes.filter(obj => {
            return obj.name === 'ChangeTypeDevice'
        });
        remainingTerm = remainingTermAttribute[0].value;
        cancelFlag =cancelFlagAttribute[0].value;
        
        console.log('updateremainingTermOnMS    RemainingTerm'+remainingTerm);
        console.log('updateremainingTermOnMS    cancelFlag'+cancelFlag);
        
        
        console.log('updateremainingTermOnMS    Inside else');
        updateRemainingTermMap[config.guid] = [{
            name: 'RemainingTerm',
            value: {
                value: remainingTerm,
                displayValue: remainingTerm
            }
        }];
        
        
        console.log('updateremainingTermOnMS ', updateRemainingTermMap);
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, true);
        
        
    }					
}
});
}else if (config.relatedProductList && config.relatedProductList.length > 1) {
    config.relatedProductList.forEach((relatedConfig) => {
        if (relatedConfig.name.includes('Device')) {
        if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
        var cancelFlag = '';
        var remainingTerm = 0;
        var remainingTermAttribute = relatedConfig.configuration.attributes.filter(obj => {
        return obj.name === 'RemainingTerm'
    });
    
    var cancelFlagAttribute = relatedConfig.configuration.attributes.filter(obj => {
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
            value: {
                value: remainingTerm,
                displayValue: remainingTerm
            }
        }];
        
        
        console.log('updateremainingTermOnMS ', updateRemainingTermMap);
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, true);
        
    }
}					
}
});
}
else {
    console.log('updateremainingTermOnMS    Inside outer else');
    updateRemainingTermMap[config.guid] = [{
        name: 'RemainingTerm',
        value: {
            value: 0,
            displayValue: 0
        }
    }];
    
    console.log('updateremainingTermOnMS ', updateRemainingTermMap);
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, true);
}

});

}
}
});

}
}
})
}

CWPPlugin.updateFieldsVisibilityAfterSolutionLoad = function(solution) {
    console.log('inside updateFieldsVisibilityAfterSolutionLoad');
    
    if (solution.name.includes(COMPONENT_NAMES.solution)) {
        let updateMapDevice = {};
        let updateConfigMap = {};
        let updateselectMap = {};
        let changeTypeForSolution = 'New';
        let BounsAllownceFlag = false;
        //var isCommittedDataOffer = false;
        console.log('inside updateFieldsVisibilityAfterSolutionLoad' + solution.changeType);
        
        if (solution.components && solution.components.length > 0) {
            var setChangeType = '';
            
            solution.components.forEach((comp) => {
                
                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                console.log('updateFieldsVisibilityAfterSolutionLoad--->81127');
                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                comp.schema.configurations.forEach((config) => {
                var valid = true;
                errorMessage = '';
                config.attributes.forEach((attr) => {
                var CancelCheck = '';
                if (attr.name === 'ChangeType' && attr.Value === 'Cancel') {
                CancelCheck = 'Cancel';
            }
                                        
                                        if (attr.name === 'PlanTypeString' && CancelCheck !== 'Cancel') {
                if (attr.displayValue !== 'Data') {
                    updateConfigMap[config.guid] = [{
                        name: 'InternationalDirectDial',
                        value: {
                            showInUi: true,
                            required: false
                        }
                    }, {
                        name: 'MessageBank',
                        value: {
                            showInUi: true,
                            required: true
                        }
                    }, {
                        name: 'MessageBank RC',
                        value: {
                            showInUi: true,
                            required: false
                        }
                    }, {
                        name: 'IDD Charge',
                        value: {
                            showInUi: true,
                            required: false
                        }
                    }];
                }
                //console.log('attr.name==='+attr.name+attr.value);
            }
        });
        if (config.id) {
            if (config.attributes && config.attributes.length > 0) {
                console.log('updateFieldsVisibilityAfterSolutionLoad--->81127');
                var changeTypeAtrtribute = config.attributes.filter(obj => {
                    return obj.name === 'ChangeType'
                });
                
                if (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel') {
                    //updateMapDevice[config.guid] = [];
                    updateMapDevice[config.guid] = [{
                        name: 'RemainingTerm',
                        value: {
                            showInUi: true,
                            readOnly: true
                        }
                    }, {
                        name: 'ChangeType',
                        value: {
                            showInUi: true,
                            readOnly: true
                        }
                    },
                                                    /*{
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        },*/
                                                    {
                                                        name: 'CancelFlag',
                                                        value: {
                                                            showInUi: true,
                                                            readOnly: true
                                                        }
                                                    }];
                    
                }
                
                if (config.relatedProductList && config.relatedProductList.length > 0 && (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel')) {
                    config.relatedProductList.forEach((relatedConfig) => {
                        updateMapDevice[relatedConfig.guid] = [];
                        if (relatedConfig.name.includes('Device')) {
                        
                        if ((relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !==undefined && relatedConfig.configuration.replacedConfigId !==null) && relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
                        var changeTypeAtrtribute = config.attributes.filter(obj => {
                        return obj.name === 'ChangeType'
                    });
                        var earlyTerminationChargeAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                        return obj.name === 'EarlyTerminationCharge'
                    });
                        /*var cancelFlagAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                                                                        return obj.name === 'CancelFlag'
                                                                    });*/
                        var ChangeTypeDeviceAttribute = relatedConfig.configuration.attributes.filter(obj => {
                        return obj.name === 'ChangeTypeDevice'
                    });
                        console.log('updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product');
                        console.log('updateFieldsVisibilityAfterSolutionLoad--->Inside Related Product' + ChangeTypeDeviceAttribute[0].value + earlyTerminationChargeAtrtribute[0].value);
                        if(ChangeTypeDeviceAttribute[0].value !== 'New'){
                        if (/*(cancelFlagAtrtribute[0].value === false || cancelFlagAtrtribute[0].value === '' || cancelFlagAtrtribute[0].value === null) && */(ChangeTypeDeviceAttribute[0].value === 'None' || ChangeTypeDeviceAttribute[0].value === '' || ChangeTypeDeviceAttribute[0].value === null) && (earlyTerminationChargeAtrtribute[0].value == 0 || earlyTerminationChargeAtrtribute[0].value == '' || earlyTerminationChargeAtrtribute[0].value == null)) {
                        console.log('inside iif');	
                        updateMapDevice[relatedConfig.guid].push({
                        name: 'RemainingTerm',
                        value: {
                            showInUi: true,
                            readOnly: true
                        }
                    });
                    updateMapDevice[relatedConfig.guid].push({
                        name: 'EarlyTerminationCharge',
                        value: {
                            showInUi: false,
                            readOnly: true
                        }
                    }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: false,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'ChangeTypeDevice',
                                                            value: {
                                                                showInUi: true,
                                                                //readOnly: false
                                                            }
                                                        });
                                                        
                                                        
                                                    } else if(changeTypeAtrtribute[0].value === 'Cancel') {
                                                        console.log('inside iif');	
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'RemainingTerm',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'ChangeTypeDevice',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                    }else {
                                                        console.log('inside else');	
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'RemainingTerm',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        });
                                                        updateMapDevice[relatedConfig.guid].push({
                                                            name: 'EarlyTerminationCharge',
                                                            value: {
                                                                showInUi: true,
                                                                readOnly: true
                                                            }
                                                        }); /*{
                                                                            name: 'CancelFlag',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: true
                                                                            }
                                                                        },*/
                                                                        updateMapDevice[relatedConfig.guid].push({
                                                                            name: 'ChangeTypeDevice',
                                                                            value: {
                                                                                showInUi: true,
                                                                                readOnly: false
                                                                            }
                                                                        });
                                                                    }
            }
        }
        
    }
});
}

}
}

});

}
}
});
//console.log('updateFieldsVisibilityAfterSolutionLoad - updating: ', updateselectMap);
console.log('updateFieldsVisibilityAfterSolutionLoad - updateMapDevice: ', updateMapDevice);
console.log('updateFieldsVisibilityAfterSolutionLoad - updateConfigMap: ', updateConfigMap);
if (Object.keys(updateMapDevice).length > 0) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateFieldsVisibilityAfterSolutionLoad updateMapDevice Attribute Update', component));
}
if (Object.keys(updateConfigMap).length > 0) {
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap, true).then(component => console.log('updateFieldsVisibilityAfterSolutionLoad updateConfigMap Attribute Update', component));
}
}
}

}	

/************************************************************************************
             * Author	: Anand Shekhar
             * Method Name : UpdateAttributeVisibilityForMacdMobileSubscription
             * Description : Update Attribute Visibility For MacdMobile Subscription
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
CWPPlugin.UpdateAttributeVisibilityForMacdMobileSubscription = function (guid, changeTypeValue, selectedPlan) {
    console.log('UpdateAttributeVisibilityForMacdMobileSubscription',guid, changeTypeValue, selectedPlan);
    
    if (changeTypeValue === 'Cancel') {
        
        CWPPlugin.updateAttributeVisibility(COMPONENT_NAMES.mobileSubscription, 'CancellationReason', guid, true, true);
        
        let isEtcVisible = true;
        if (selectedPlan.includes('BYO'))
            isEtcVisible = false;
        CWPPlugin.updateDisconnectionDateAndETC(COMPONENT_NAMES.mobileSubscription, guid, true, isEtcVisible , basketStage === 'Commercial Configuration', false);
        CWPPlugin.setAttributesReadonlyValueForConfiguration(COMPONENT_NAMES.mobileSubscription,guid, true, COMPONENT_NAMES.mobileSubscriptionEditableAttributeList);
    }
    if (changeTypeValue !== 'Cancel') {
        
        CWPPlugin.updateAttributeVisibility(COMPONENT_NAMES.mobileSubscription, 'CancellationReason', guid, false, false);
        
        Utils.emptyValueOfAttribute(guid, COMPONENT_NAMES.mobileSubscription, 'CancellationReason', false);
        
        CWPPlugin.updateDisconnectionDateAndETC(COMPONENT_NAMES.mobileSubscription,guid, false,false, false, false);
        
    }
    
    if (changeTypeValue === 'Modify') {
        
        CWPPlugin.setAttributesReadonlyValueForConfiguration(COMPONENT_NAMES.mobileSubscription,guid, true, ['SelectPlanType']);
        
        
    }
    
    //return Promise.resolve(true);
}



CWPPlugin.setAttributesReadonlyValueForConfiguration = function (componentName, guid, isReadOnly, attributeList) {
    console.log('setAttributesReadonlyValueForConfiguration ',componentName,  guid, isReadOnly, attributeList);
    
    let updateMap = {};
    updateMap[guid] = [];
    attributeList.forEach((attribute) => {
        updateMap[guid].push(
        {
        name: attribute,
        value: {
            readOnly: isReadOnly
        }
    });
});
console.log ('setAttributesReadonlyValueForConfiguration updateMap', updateMap);
CS.SM.updateConfigurationAttribute(componentName, updateMap, false).then(()=> Promise.resolve(true)).catch((e)=> Promise.resolve(true));


CS.SM.getActiveSolution().then((solution) => {
    if (solution.components && solution.components.length > 0) {
    solution.components.forEach((comp) => {
    
    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
    comp.schema.configurations.forEach((config) => {
    if (config.guid === guid) {
    if (comp.name === componentName) {
    var DeviceUpdate= false;
    console.log('setAttributesReadonlyValueForConfiguration config',config);
    if (componentName === COMPONENT_NAMES.mobileSubscription && config.relatedProductList && config.relatedProductList.length>0)
    
    
    CWPPlugin.setAttributesReadonlyValueForConfigurationRelatedProducts(componentName, config.relatedProductList, 'Device', isReadOnly, COMPONENT_NAMES.mobileSubscriptionAddOnEditableAttributeList);
    
    
}
                               }
                               });
}
});
}
});
}

CWPPlugin.updateDisconnectionDateAndETC = function (componentName, guid, isVisible,isVisibleETC , isMandatory, isReadonly) {
    console.log ('updateDisconnectionDateAndETC ',componentName, guid, isVisible,isVisibleETC, isMandatory,isReadonly);
    
    let updateMap = {};
    updateMap[guid] = [];
    updateMap[guid].push(
        {
            name: 'DisconnectionDate',
            value: {
                readOnly: isReadonly,
                showInUi: isVisible,
                required: isMandatory
            }
        });
    updateMap[guid].push(
        {
            name: 'EarlyTerminationCharge',
            value: {
                readOnly: true,
                showInUi: isVisibleETC,
                required: false
            }
        });
    
    
    CS.SM.updateConfigurationAttribute(componentName, updateMap, false).then(()=> Promise.resolve(true)).catch(()=> Promise.resolve(true));
}

/************************************************************************************
             * Author	: Anand Shekhar
             * Method Name : GetattributesForMobileSubscription
             * Description : Get Attributes For Mobile Subscription
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
CWPPlugin.getattributesForMobileSubscription =function (guid,attributeName) {
    let selectDisplayValue = '';
    let updateMap = {};
    CS.SM.getActiveSolution().then((product) => {
        if (product.components && product.components.length > 0) {
        let comp = product.components.filter(c => {return c.name===COMPONENT_NAMES.mobileSubscription});
    if (comp && comp.length> 0 &&  comp[0].schema && comp[0].schema.configurations && comp[0].schema.configurations.length > 0) {
        let config = comp[0].schema.configurations.filter(c => c.guid === guid);
        if (config && config.length > 0) {
            updateMap[guid] = [];
            let att = config[0].attributes.filter(a => {return a.name === attributeName});
            if (att && att.length)
                selectDisplayValue = att[0].displayValue;
            console.log('selectDisplayValue::::::',selectDisplayValue);
            if(selectDisplayValue==='Data'){
                updateMap[guid].push(
                    {
                        name: 'MessageBank',
                        value: {
                            readOnly: false,
                            showInUi: false,
                            required: false
                        }
                    });
                
                CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true);
                
            }else{
                console.log('inside else');
                updateMap[guid].push(
                    {
                        name: 'MessageBank',
                        value: {
                            readOnly: false,
                            showInUi: true,
                            required: true
                        }
                    });
                updateMap[guid].push(
                    {
                        name: 'InternationalDirectDial',
                        value: {
                            readOnly: false,
                            showInUi: true,
                            required: true
                        }
                    });
                
                CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true);
            }
        }
    }
}
});
console.log('selectDisplayValue:::'+selectDisplayValue);
return selectDisplayValue;
}


/************************************************************************************
			 * Author	: Anand Shekhar
			 * Method Name : checkDeviceSelectionLookupForModify
			 * Extracted from CMP js file as part of Mobile retrofit
			 ***********************************************************************************/
function checkDeviceSelectionLookupForModify(guid) {
    console.log('inside checkDeviceSelectionLookupForModify');
    
    CS.SM.getActiveSolution().then((solution) => {
        var mobilityAttributes = ["MobileHandsetManufacturer", "MobileHandsetModel", "MobileHandsetColour","PaymentTypeLookup","RemainingTerm","ContractTerm"];
        var updateMap = {};
                                   if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var updateMapDevice = {};
        
        solution.components.forEach((comp) => {
            
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            updateMap = [];
            console.log('checkDeviceSelectionLookupForModify--->81127');
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
            var valid = true;
            errorMessage = '';
            var updateselectplan={};
                                    if(config.guid===guid){
            var SelectPlanTypeAtrtribute = config.attributes.filter(obj => {
                return obj.name === 'SelectPlanType'
            });
            console.log('SelectPlanTypeAtrtribute[0].value>>>'+SelectPlanTypeAtrtribute[0].value);
            //if(SelectPlanTypeAtrtribute[0].value !==''){
            updateselectplan[config.guid]=[{
                name: 'SelectPlanType',
                value: {
                    showInUi: true,
                    readOnly: true
                }
            }];
            //}
            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateselectplan, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
            
        }
        if (config.id && !(config.name.includes('BYO'))) {
            if (config.attributes && config.attributes.length > 0) {
                var changeTypeAtrtribute = config.attributes.filter(obj => {
                    return obj.name === 'ChangeType'
                });
                var selectPlanAtrtribute = config.attributes.filter(obj => {
                    return obj.name === 'Select Plan'
                });
                console.log('checkDeviceSelectionLookupForModify--->4824'+changeTypeAtrtribute[0].value + selectPlanAtrtribute[0].value+selectPlanAtrtribute[0].displayValue);
                if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                    var visibleEtc = false;
                    // ask hitesh to get the name of select plan instead of Id and then uncomment below code
                    if (changeTypeAtrtribute[0].value === 'Modify' /*&& selectPlanAtrtribute[0].displayValue.includes('BYO')*/ ) {
                        console.log('checkDeviceSelectionLookupForModify--->4827');
                        if (config.relatedProductList && config.relatedProductList.length > 0) {
                            config.relatedProductList.forEach((relatedConfig) => {
                                updateMapDevice[relatedConfig.guid] = [];
                                if (relatedConfig.name.includes('Device')) {
                                
                                if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
                                var RemainingTermAttribute = relatedConfig.configuration.attributes.filter(obj => {
                                return obj.name === 'RemainingTerm'
                            });
                                if (RemainingTermAttribute[0].value > 0 && relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !==null ){
                                /*updateMapDevice[relatedConfig.guid].push({
																				 name: 'CancelFlag',
																				 value: {
																					showInUi: true,
																					readOnly: false
																						}
																			});	*/
                                            updateMapDevice[relatedConfig.guid].push({
                                            name: 'ChangeTypeDevice',
                                            value: {
                                                showInUi: true,
                                                readOnly: false
                                            }
                                        });	
                                        
                                    }
                                    
                                    
                                    if(mobilityAttributes.length > 0){
                                        mobilityAttributes.forEach((mobattribute) => {
                                            console.log('checkDeviceSelectionLookupForModify--->4835>>>>>>' + mobattribute);
                                            var MobileHandsetManufacturer = relatedConfig.configuration.attributes.filter(obj => {
                                            return obj.name === mobattribute
                                        });
                                            /*var cancelFlagAttribute = relatedConfig.configuration.attributes.filter(obj => {
																						return obj.name === 'CancelFlag'
																		});*/
                                            console.log('checkDeviceSelectionLookupForModify--->4839'+MobileHandsetManufacturer[0].value);
                                            if (MobileHandsetManufacturer[0].value != null &&  
                                            MobileHandsetManufacturer[0].value != '' && 
                                            MobileHandsetManufacturer[0].value != undefined) {
                                            console.log('Inside RemaingTerm Greater Than 0: ');
                                            updateMapDevice[relatedConfig.guid].push({
                                            name: mobattribute,
                                            value: {
                                                showInUi: true,
                                                readOnly: true
                                            }
                                        });
                                    }
                                });
                            }
                        }
                        
                    }
                });	
            }		
}
else {
    CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,config.guid,true);	
    
}
}
}
}
});

}
}
});

console.log('updateCancelFlagVisibility - updating: ', updateMapDevice);
CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));

}
}).then(
    () => Promise.resolve(true)
);
}

/************************************************************************************
             * Author	: Anand Shekhar
             * Method Name : checkCancelFlagAndETCForNonBYOPlans
             * Description : Check Cancel Flag And ETC For Non BYO Plans
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/

function checkCancelFlagAndETCForNonBYOPlans(guid) {
    console.log('checkCancelFlagAndETCForNonBYOPlans');
    
    CS.SM.getActiveSolution().then((solution) => {
        var updateMap = {};
                                   if (solution.components && solution.components.length > 0) {
        var setChangeType = '';
        var isCancelFlagTrue = false;
        var updateMapDevice = {};
        //Ritika:Start:EDGE - 81135
        var contractTerm;
        var unitPriceRC;
        var prodConfigID;
        var deviceConfigID;
        var charges;//Ritika:End:EDGE - 81135
        solution.components.forEach((comp) => {
            
            if (comp.name === COMPONENT_NAMES.mobileSubscription) {
            updateMap = [];
            console.log('checkCancelFlagAndETCForNonBYOPlans--->4817');
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
            var valid = true;
            errorMessage = '';
            if (config.id ) {
            if (config.attributes && config.attributes.length > 0 ) {
            var changeTypeAtrtribute = config.attributes.filter(obj => {
            return obj.name === 'ChangeType'
        });
        console.log('checkCancelFlagAndETCForNonBYOPlans--->4824'+changeTypeAtrtribute[0].value);
        if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
            var visibleEtc = false;
            if (changeTypeAtrtribute[0].value === 'Modify') {
                prodConfigID = config.id;
                console.log('checkCancelFlagAndETCForNonBYOPlans--->4827',config.id);
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    config.relatedProductList.forEach((relatedConfig) => {
                        if (relatedConfig.name.includes('Device') && relatedConfig.guid==guid){	
                        if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0){
                        console.log('checkRemainingTermForBYOPlans--->4835',relatedConfig);
                        
                        /*var cancelFlagAttribute = relatedConfig.configuration.attributes.filter(obj => {
																						return obj.name === 'CancelFlag'
																		});*/
                        var ChangeTypeDeviceAttribute = relatedConfig.configuration.attributes.filter(obj => {
                        return obj.name === 'ChangeTypeDevice'
                    });
                    var RemainingTermAttribute = relatedConfig.configuration.attributes.filter(obj => {
                        return obj.name === 'RemainingTerm'
                    });
                    
                    if (/*cancelFlagAttribute && cancelFlagAttribute.length > 0 && */ChangeTypeDeviceAttribute && ChangeTypeDeviceAttribute.length > 0){
                        contractTerm = relatedConfig.configuration.attributes.filter(a => {
                            return a.name === 'ContractTerm'
                        });
                        unitPriceRC = relatedConfig.configuration.attributes.filter(c => {
                            return c.name === 'InstalmentCharge'
                        });
                        var EarlyTerminationChargesAttribute = relatedConfig.configuration.attributes.filter(obj => {
                            return obj.name === 'EarlyTerminationCharge'
                        });
                        if(EarlyTerminationChargesAttribute && EarlyTerminationChargesAttribute.length > 0) {
                            if(/*cancelFlagAttribute[0].value === true && */		ChangeTypeDeviceAttribute[0].value === 'PayOut'){
                                deviceConfigID = relatedConfig.configuration.replacedConfigId;
                                //EDGE - 81135 : ETC calculation for Modify -cancelDevice : Start
                                console.log('contractTerm=', contractTerm, ',unitPriceRC=', unitPriceRC);
                                if (unitPriceRC && contractTerm) {
                                    var updateMap = [];
                                    var inputMap = {};
                                    inputMap["DisconnectionDate"] = new Date();
                                    inputMap["etc_Term"] = contractTerm[0].displayValue;
                                    inputMap["CalculateEtc"] = '';
                                    inputMap["etc_UnitPrice"] = unitPriceRC[0].displayValue;
                                    inputMap["ProdConfigId"] = prodConfigID;
                                    inputMap["deviceConfigID"] = deviceConfigID;
                                    inputMap["macdeviceConfigID"] = relatedConfig.configuration.id;
                                    console.log('inputMap', inputMap);
                                    CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
                                        charges = values["CalculateEtc"];
                                        console.log('Result', values["CalculateEtc"],charges,relatedConfig.guid);
                                        
                                        isCancelFlagTrue = true;
                                        var remainingTermValue = values["RemainingTerm"];
                                        var ETCValue = charges;
                                        var ChangeType = 'PayOut';
                                        productInError = false;
                                        
                                        updateMapDevice[relatedConfig.guid] = [];
                                        updateMapDevice[relatedConfig.guid].push({		
                                        name: 'EarlyTerminationCharge',
                                        value: {
                                            showInUi: true,
                                            readOnly: true,
                                            value: charges,
                                            displayValue: charges
                                        }
                                    });
                                    updateMapDevice[relatedConfig.guid].push({
                                        name: 'ChangeTypeDevice',
                                        value: {
                                            showInUi: true,
                                            readOnly: false,
                                            //value: ChangeType,
                                            //displayValue: ChangeType
                                        }
                                    });
                                    updateMapDevice[relatedConfig.guid].push({
                                        name: 'RemainingTerm',
                                        value: {
                                            showInUi: true,
                                            readOnly: true,
                                            //value: remainingTermValue,
                                            ///displayValue: remainingTermValue
                                        }
                                    });
                                    console.log('checkRemainingTermForBYOPlans--->4839'+productInError+isCancelFlagTrue+',charges',ETCValue);
                                    CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,config.guid,true);
                                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('calculateTotalETCValue Attribute update', component));
                                    
                                });
                            }
                            //EDGE - 81135 : ETC calculation for Modify -cancelDevice
                        }
                        else {
                            var ETCValue = 0;
                            var ChangeType = '';
                            productInError = true;
                            console.log('checkRemainingTermForBYOPlans--->4839'+productInError);
                            allowSaveEM = false;
                            if(config.name.includes('BYO')){
                                CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,config.guid,false,'Cannot change the plan to BYO while the associated device is In-Contract');}
                            updateMapDevice[relatedConfig.guid] = [];
                            updateMapDevice[relatedConfig.guid].push({
                                name: 'EarlyTerminationCharge',
                                value: {
                                    showInUi: false,
                                    readOnly: true,	
                                    value: ETCValue,
                                    displayValue: ETCValue
                                }
                                
                            });
                            updateMapDevice[relatedConfig.guid].push({
                                name: 'ChangeTypeDevice',
                                value: {
                                    showInUi: true,
                                    readOnly: false,
                                    //value: ChangeType,
                                    //displayValue: ChangeType
                                }
                            });
                            var contractTermAtrtribute = relatedConfig.configuration.attributes.filter(obj => {
                                return obj.name === 'ContractTerm'
                            });
                            //remainingTermsolutionUpdate(relatedConfig.configuration,contractTermAtrtribute[0].displayValue,config.guid);
                            /*updateMapDevice[relatedConfig.guid].push({
																						 name: 'RemainingTerm',
																						 value: {
																							showInUi: true,
																							readOnly: true,
																							value: RemainingTermAttribute[0].value,
																							displayValue: RemainingTermAttribute[0].value
																								}
																				});*/
                                        console.log('updateCancelFlagVisibility - updating: ', updateMapDevice);
                                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
                                    }
                                }
                                
                                
                            }
                            
                            
                        }
                    }
                    if (relatedConfig.name.includes('Device'))	{
                        if(isCancelFlagTrue){
                            console.log('checkRemainingTermForBYOPlans--->isCancelFlagTrue'+isCancelFlagTrue);
                            CS.SM.updateConfigurationStatus(COMPONENT_NAMES.mobileSubscription,relatedConfig.guid,true);
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
}).then(
    () => Promise.resolve(true)
);
}



/************************************************************************************
			 * Author	: Anand Shekhar
			 * Method Name : updateCancelDeviceTypeAfterSolutionLoad
			 * Invoked When: Change Device Type is updated as Modisy
			 * Description : Set value of Change Type
			 * Parameters : guid
			 * Extracted from CMP js file as part of Mobile retrofit
			 ***********************************************************************************/		
function updateCancelDeviceTypeAfterSolutionLoad(guid) {
    CS.SM.getActiveSolution().then((solution) => {
        var updateMapDevice = {};	
                                   solution.components.forEach((comp) => {
        if (comp.name === COMPONENT_NAMES.mobileSubscription) {
        console.log('updateCancelDeviceTypeAfterSolutionLoad::::::');
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {			
        comp.schema.configurations.forEach((config) => {
        var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
    if (config.attributes && config.attributes.length > 0) {	
        if (config.relatedProductList && config.relatedProductList.length > 0){
            if(changeTypeAtrtribute[0].value !== '' && changeTypeAtrtribute[0].value !== 'Active' && changeTypeAtrtribute[0].value !== 'New') {
                config.relatedProductList.forEach((relatedConfig) => {
                    if(relatedConfig.configuration.replacedConfigId !=='' && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !==null){
                    if(relatedConfig.guid===guid){
                    updateMapDevice[relatedConfig.guid] = [];
                    var RemainingTermAttr = relatedConfig.configuration.attributes.filter(obj => {
                    return obj.name === 'RemainingTerm'
                });
                var DeviceStatusAttr = relatedConfig.configuration.attributes.filter(obj => {
                    return obj.name === 'DeviceStatus'
                });
                var ChangeTypeDeviceAttr = relatedConfig.configuration.attributes.filter(obj => {
                    return obj.name === 'ChangeTypeDevice'
                });
                var contractTermAtrtribute =relatedConfig.configuration.attributes.filter(obj => {
                    return obj.name === 'ContractTerm'
                });
                console.log('ChangeTypeDeviceAttr[0].value'+ChangeTypeDeviceAttr[0].value);
                if (relatedConfig.name.includes('Device') && ChangeTypeDeviceAttr[0].value !=='New') {
                    
                    if (relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0 && changeTypeAtrtribute[0].value === 'Cancel' && RemainingTermAttr[0].value> 0 ) {
                        console.log('inside this')
                        updateMapDevice[relatedConfig.guid].push(
                            {
                                name: 'ChangeTypeDevice',
                                value: {
                                    value: 'PayOut',
                                    readOnly: true,
                                    showInUi: true
                                }
                            });
                        updateMapDevice[relatedConfig.guid].push(
                            {
                                name: 'RemainingTerm',
                                value: {
                                    value: 0,
                                    displayValue:0						
                                }
                            });
                        
                    }else if(DeviceStatusAttr[0].value !=='PaidOut' && ChangeTypeDeviceAttr[0].value==='PayOut' && changeTypeAtrtribute[0].value === 'Modify' && IsMACBasket){
                        IsMACBasket=false;
                        console.log('IsMACBasket>>>>>>'+IsMACBasket)
                        updateMapDevice[relatedConfig.guid].push(
                            {
                                name: 'ChangeTypeDevice',
                                value: {
                                    value: 'None',
                                    readOnly: false,
                                    showInUi: true
                                }
                            });	
                        remainingTermsolutionUpdate(relatedConfig.configuration, contractTermAtrtribute[0].displayValue, relatedConfig.guid);
                        
                    }else{
                        console.log('IsMACBasket111>>>>>>'+IsMACBasket)
                        updateMapDevice[relatedConfig.guid].push(
                            {
                                name: 'ChangeTypeDevice',
                                value: {
                                    //value: ChangeTypeDeviceAttr[0].value,
                                    //readOnly: true,
                                    //showInUi: true
                                }
                            });
                    }
                    console.log('updateCancelFlagVisibility Attribute Update11111111111'+updateMapDevice);
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMapDevice, true).then(component => console.log('updateCancelFlagVisibility Attribute Update', component));
                    
                }
            }
        }
    });
    
}

}
}
});
}
}
});
});	
}	


/************************************************************************************
             * Author	: Vasanthi Sowparnika
             * Method Name : remainingTermsolutionUpdate
             * Description : RemainingTerm calculate on Mobile subscription
             * Extracted from CMP js file as part of Mobile retrofit
             ***********************************************************************************/
async function remainingTermsolutionUpdate(config,contractTerm,configId){
    
    console.log('remainingTermsolutionUpdate--->81127');
    var changeTypeAtrtribute = config.attributes.filter(obj => {
        return obj.name === 'ChangeType'
    });
    //console.log('remainingTermsolutionUpdate--->81127'+changeTypeAtrtribute[0].value);
    //if (changeTypeAtrtribute[0].value != 'New' && changeTypeAtrtribute[0].value != '') {
    if(contractTerm != 0){
        let inputMap = {};
        var originalDiscount = 0;
        inputMap['getServiceForMAC'] = config.id;
        console.log('remainingTermMobilityUpdate :: inputMap :: ', inputMap);
        CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
            console.log('remainingTermsolutionUpdate--->81127');
            console.log('remainingTermsolutionUpdate: ', result);
            var serviceStartDateString = result["getServiceForMAC"];
            if (serviceStartDateString) {
            console.log('remainingTermsolutionUpdate--->81127');
            var serviceStartDate = new Date(JSON.parse(serviceStartDateString));
            console.log('serviceStartDate: ', serviceStartDate);
            var oneDay = 24*60*60*1000;
            var today = new Date();
            today.setHours(0,0,0,0);
            serviceStartDate.setHours(0,0,0,0);
            var remainingTerm = 0;
            var remainingTerm = Math.ceil((contractTerm*30  - ((today - serviceStartDate)/oneDay)) / 30);
            console.log('remainingTerm: ', remainingTerm);
            if(remainingTerm < 0 || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm ==="null"){
            remainingTerm = 0;
        }
            var updateRemainingTermMap = {};
            // Reset Plan bonus and remaining term.
            if( remainingTerm <= 0 || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm ==="null"){
            
            updateRemainingTermMap[config.guid] = [{
            name: "RemainingTerm",
            value: {
                value: 0,
                showInUi: true,
                readOnly: true,
                displayValue: 0
            }
        },{
            name: "ChangeType",
            value: {
                value: 'Cancel',
                showInUi: false,
                readOnly: true,
                displayValue: 'Cancel'
            }
        },{
            name: "ServiceStartDate",
            value: {
                value: serviceStartDate,
                showInUi: false,
                readOnly: true,
                displayValue: serviceStartDate
            }
        },{
            name: "CancelFlag",
            value: {
                showInUi: true,
                readOnly: true
            }
        }
                                                                                    ];
                                                                                    }
                                                                                    else{
                                                                                    // Set computed value.
                                                                                    updateRemainingTermMap[config.guid] = [{
                                                                                    name: "RemainingTerm",
                                                                                    value: {
                                                                                    value: remainingTerm,
                                                                                    showInUi: true,
                                                                                    readOnly: true,
                                                                                    displayValue: remainingTerm
                                                                                    }
                                                                                    },{
                                                                                    name: "ServiceStartDate",
                                                                                    value: {
                                                                                    value: serviceStartDate,
                                                                                    showInUi: false,
                                                                                    readOnly: true,
                                                                                    displayValue: serviceStartDate
                                                                                    }
                                                                                    }
                                                                                    // 93656 Defect 20/8/19  ends
                                                                                    ];
                                                                                    }
                                                                                    console.log('remainingTermsolutionUpdate :: updateRemainingTermMap :: ', updateRemainingTermMap);
        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, false).then();                                                
        
    }
});
}
else{
    var updateRemainingTermMap = {};
    updateRemainingTermMap[config.guid] = [{
        name: 'RemainingTerm',
        value: {
            value: 0,
            displayValue: 0
        }
    }];
    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateRemainingTermMap, false).then();                                                
}
//}
return Promise.resolve(true);

}

/***********************************************************************************************
	 * Author	   : Harsh Parmar
	 * Method Name : checkConfigurationSubscriptionsForEM
	 * Invoked When: Solution is Loaded
	 * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
	 * Extracted from CMP js file as part of Mobile retrofit

	 ***********************************************************************************************/
async function checkConfigurationSubscriptionsForEM() {
    console.log('checkConfigurationSubscriptionsForEM');
    var componentMap = {};
    var updateMap = {};
    await CS.SM.getActiveSolution().then((solution) => {
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
        if (solution.components && solution.components.length > 0) {
        solution.components.forEach((comp) => {
        if ((comp.name === COMPONENT_NAMES.mobileSubscription) &&
        comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        comp.schema.configurations.forEach((config) => {
        if (config.replacedConfigId || config.id) {
        var cta = config.attributes.filter(a => {
        return a.name === 'ChangeType' && a.displayValue !== 'Modify' && a.displayValue !== 'Cancel'
    });
    if (cta && cta.length > 0) {
        
        if (!componentMap[comp.name])
            componentMap[comp.name] = [];
        
        if (config.replacedConfigId)
            componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid});
        else
            componentMap[comp.name].push({'id':config.id, 'guid': config.guid});
    }
}
});
}
});
}
}
});

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
await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
    console.log('GetSubscriptionForConfiguration result:', values);
    if (values['GetSubscriptionForConfiguration'])
    statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
});
    
    console.log ('checkConfigurationSubscriptionsForEM statuses;', statuses);
    if (statuses) {
    
    Object.keys(componentMap).forEach(comp => {
    componentMap[comp].forEach(element => {
    var statusValue = 'New';
    var status = statuses.filter(v => {
    return v.csordtelcoa__Product_Configuration__c === element.id
});
    if (status && status.length > 0) {
    statusValue = status[0].csord__Status__c;
}
    updateMap[element.guid] =[{
    name: 'ChangeType',
    value: {
        value: statusValue,
        //showInUi: true,
        //readOnly:false,
        displayValue: statusValue
    }
}];
                                                                                  });

console.log('checkConfigurationSubscriptionsForEM update map', updateMap);
CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptionsForEM Attribute Update', component));

});
}

}

return Promise.resolve(true);
}

/**************************************************************************************
	 * Author	   : Harsh Parmar
	 * Method Name : calculateTotalMROBonus
	 * Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
	 * Invoked When: Device RP's MRO Bonus is updated, and
	 * 				 Device RP is deleted.
	 * Extracted from CMP js file as part of Mobile retrofit
	**************************************************************************************/
function calculateTotalMROBonusCWP(compName, parentConfig) {	
    
    let totalPlanBonus = 0;
    let updateConfigMap = {};
    
    // sum MROBonus of all related device
    if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
        totalPlanBonus = 0;
        parentConfig.relatedProductList.forEach((relatedProduct) => {
            if (relatedProduct.name === COMPONENT_NAMES.device && relatedProduct.type === 'Related Component') {
            relatedProduct.configuration.attributes.forEach((attribute) => {
            if (attribute.name === 'MROBonus' && attribute.value) {
            totalPlanBonus = parseFloat(totalPlanBonus) + parseFloat(attribute.value);
        }
                                                });
    }
});
}

updateConfigMap[parentConfig.guid] = [{
    name: 'TotalPlanBonus',
    value: {
        value: totalPlanBonus.toFixed(2),
        displayValue: totalPlanBonus.toFixed(2)
    }													
}];
// update total plan bonus on parent config
//CS.SM.updateConfigurationAttribute(compName, updateConfigMap, true);
}


/**************************************************************************************
	 * Author	   : Harsh Parmar
	 * Method Name : updatePlanDiscountCWP
	 * Extracted from CMP js file as part of Mobile retrofit
	**************************************************************************************/
function updatePlanDiscountCWP(parentConfig,planRecord,deviceRecord){
    let inputMap2 = {};
    inputMap2['planRecord'] = planRecord;
    inputMap2['deviceRecord'] = deviceRecord;
    
    let discountRecId = null;
    let discountValue = null;
    
    CS.SM.WebService.performRemoteAction('MobileSubscriptionGetDiscountData', inputMap2).then(
        function (response) {   
            console.log('response updatePlanDiscount', response);										
            if (response && response['planDiscountList'] != undefined) {
                console.log('planDiscountList', response['planDiscountList']);
                response['planDiscountList'].forEach((a) => {
                    if(a.Id != null){
                    discountRecId = a.Id;
                    discountValue = a.Recurring_Charge__c;
                }
                                                     });
                console.log('discountRecId ', discountRecId);
                if(discountRecId!= ''){
                    let updateConfigMap2 = {};
                    updateConfigMap2[parentConfig.guid] = [{
                        name: 'PlanDiscountLookup',
                        value: {
                            value: discountRecId,
                            displayValue: discountValue
                        }														
                    },
                                                           {
                                                               name: 'TotalPlanBonus',
                                                               value: {
                                                                   value: discountValue.toFixed(2),
                                                                   displayValue: discountValue.toFixed(2)
                                                               }														
                                                           }];
                    console.log('updateConfigurationAttribute PlanDiscountLookup');
                    CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateConfigMap2, true);
                }
            } else { 	 	  
                console.log('no response');
            }
        });
}

/**************************************************************************************
	 * Author	   : Sowparnika
	 * Method Name : updateEDMListToDecomposeattribute
	 * Extracted from CMP js file as part of Mobile retrofit
	**************************************************************************************/
function updateEDMListToDecomposeattributeCWP(product) {
    if (product.type && product.name.includes(COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && product.components.length > 0) {
            for (var i=0; i< product.components.length; i++) {
                var comp = product.components[i];
                if (comp.name === COMPONENT_NAMES.mobileSubscription) {
                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                        updateMap = [];
                        for (var j=0; j<comp.schema.configurations.length; j++) {
                            var mobilityConfig = comp.schema.configurations[j];
                            if (mobilityConfig.attributes && mobilityConfig.attributes.length > 0) {
                                
                                var EDMListToDecompose = 'Mobility_Fulfilment,Mobile Access_Fulfilment,420_RC_654,263_NRC_601,326_ASR,151_ASR';
                                var selectPlan = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'Select Plan'
                                });
                                
                                var OfferTypeString = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'OfferTypeString'
                                });
                                
                                var InternationalDirectDial = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'InternationalDirectDial'
                                });
                                
                                var MessageBank = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'MessageBank'
                                });
                                
                                //Added for EDGE-89294
                                var MDMEntitled = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'MDMEntitled'
                                });
                                //Added for EDGE-103386
                                /*var DataPackChargeRec = mobilityConfig.attributes.filter(a => {
										return a.name === 'DataPackChargeRec'
									});*/
                                var IDDCharge = mobilityConfig.attributes.filter(a => {
                                    return a.name === 'IDD Charge'
                                });
                                
                                if (MessageBank && MessageBank.length > 0) {
                                    if (MessageBank[0].displayValue && MessageBank[0].displayValue === "VOICE to TEXT") {
                                        EDMListToDecompose = EDMListToDecompose + ',420_RC_497';
                                    }
                                }
                                
                                if (InternationalDirectDial && InternationalDirectDial.length > 0 && selectPlan && selectPlan.length > 0) {
                                    if (InternationalDirectDial[0].value && InternationalDirectDial[0].value !== '') {
                                        if(parseInt(IDDCharge[0].value) !== 0){//parsing string to integer
                                            EDMListToDecompose = EDMListToDecompose + ',420_RC_669';
                                        }
                                    }
                                }
                                
                                if (OfferTypeString && OfferTypeString.length > 0) {
                                    if (OfferTypeString[0].value && OfferTypeString[0].value === "FairPlay Data") {
                                        EDMListToDecompose = EDMListToDecompose + ',420_AW_637';
                                    } /*else if (OfferTypeString[0].value === "Committed Data") {
											EDMListToDecompose = EDMListToDecompose + ',420_AW_806';
										} else if (OfferTypeString[0].value === "Aggregated Data") {
											EDMListToDecompose = EDMListToDecompose + ',420_AW_641';
										} else if (OfferTypeString[0].value === "Data Pool Data") {
											EDMListToDecompose = EDMListToDecompose + ',420_AW_642';
										}*/
                                    }
                                
                                
                                if (InternationalDirectDial && InternationalDirectDial.length > 0) {
                                    if (InternationalDirectDial[0].value !== '') {
                                        EDMListToDecompose = EDMListToDecompose + ',420_AW_644';
                                    }
                                }
                                //DPG-1166 Part of Mobile Retrofit Bug Fixes - Adding IR Day Pass and IR Data Top-up
                                if (selectPlan && selectPlan.length > 0) {
                                    if(selectPlan[0].displayValue !== "Global BYO" && selectPlan[0].displayValue !== "Global") {
                                        EDMListToDecompose = EDMListToDecompose + ',263_AW_606,263_AW_607';
                                    }

                                }

                                //Added for  EDGE-89294
                                if (MDMEntitled && MDMEntitled.length > 0) {
                                    if (MDMEntitled[0].value === 'true') {
                                        EDMListToDecompose = EDMListToDecompose + ',421_ASR';
                                    }
                                    
                                }
                                
                                console.log('EDMListToDecompose', EDMListToDecompose);
                                updateMap[mobilityConfig.guid] = [{
                                    name: 'EDMListToDecompose',
                                    value: {
                                        value: EDMListToDecompose,
                                        displayValue: EDMListToDecompose
                                    }
                                }];
                            }
                        }
                        CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobileSubscription, updateMap, true);
                    }
                }
            }
        }
    }
    
    return Promise.resolve(true);
}

/*****************************************************************************************************
 * Author   : Sandip Deshmane
 * Method Name : updateEtcAttVisibilityOnLoad On Solution Load
 * Invoked When: Solution is added to MACBasket and Change Type to Cancel
 * Description : Set attributes to True when Product is added to Mac Basket.
 * Parameters  : guid
 * EDGE-127631
 ****************************************************************************************************/
function updateEtcAttVisibilityOnLoad() {
    console.log('updateEtcAttVisibilityOnLoad');

    CS.SM.getActiveSolution().then((solution) => {
            console.log('Active Solution from updateEtcvisibility', solution);
        if (solution.type && solution.name.includes(COMPONENT_NAMES.solution)) {
            if (solution.components && solution.components.length > 0) {
                var setChangeType = '';
                var updateMap = {};
                solution.components.forEach((comp) => {
                    if (comp.name===COMPONENT_NAMES.ipSite && comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                        comp.schema.configurations.forEach((config) => {
                            if (config.attributes && config.attributes.length > 0) {

                                var changeTypeAtrtribute = config.attributes.filter(obj => {
                                    return obj.name === 'ChangeType'
                                });
                                var ETCAtrtribute = config.attributes.filter(obj => {
                                    return obj.name === 'TotalETC'
                                });

                                var etcWaiver = config.attributes.filter(obj => {
                                    return obj.name === 'WaiveETC'
                                });

                                var caseNumber = config.attributes.filter(obj => {
                                    return obj.name === 'CaseNumber'
                                });

                                if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {

                                    updateMap[config.guid] = [];
                                    var visible = false;
                                    var visibleEtc = false;
                                    if (changeTypeAtrtribute[0].value === 'Cancel') {
                                        visible = true;
                                        visibleEtc = true;
                                    }

                                    var etcVal = {showInUi: visibleEtc};
                                    if (ETCAtrtribute && ETCAtrtribute.length > 0 && ETCAtrtribute[0].value) {
                                        etcVal.value = ETCAtrtribute[0].value;
                                    } else {
                                        etcVal.value = 0;
                                    }

                                    updateMap[config.guid].push({
                                        name: 'TotalETC',
                                        value: etcVal,
                                        readOnly: true
                                    });

                                    //Show attribute when ETC value is > 0
                                    if (etcVal.value > 0 ){
                                    updateMap[config.guid].push({
                                        name: 'WaiveETC',
                                        value: {
                                            showInUi: visibleEtc
                                        }
                                    });

                                    updateMap[config.guid].push({
                                        name: 'CaseNumber',
                                        value: {
                                            showInUi: visibleEtc
                                        }
                                    });
                                    }
                                }
                            }
                        });
                    }
                    console.log('updateEtcVisibility - updating: ', updateMap);

CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.ipSite, updateMap, true).then(component => console.log('updateEtcVisibility Attribute Update', component));
                });
            }
        }
    });
CWPPlugin.onCustomAttributeEdit = async function(componentName,configurationGuid,attributeName){
    console.log('Inside customAttributeEdit Guid--->'+configurationGuid+'@@@@@'+componentName);
    var url= '';
    var vfRedirect = '';
    var solutionId = '';
    let inputMap = {};
    var solution=window.currentSolutionName;
    var selectplan;
    var internationalDirectDialIn;
    var configId=configurationGuid;
    var BussinessId_PI='';
    var BussinessId_Addon='';
    var EmChangeType='';
    /* DPG-1512 Kiran Changes Begin */
    await CS.SM.getActiveSolution().then((product) => {
	solution = product;
	solutionId=product.solutionId;
	if (solution.components && solution.components.length > 0) {
		solution.components.forEach((comp) => {
			if (comp.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription)) {
				if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
					comp.schema.configurations.forEach((config) => {
						if(config.guid === configurationGuid){
							if(config.attributes && config.attributes.length>0){
								selectplan = config.attributes.filter(a => {
									return a.name==='Select Plan' 
								});
								oldplan = config.attributes.filter(a => {
									return a.name==='OldPlanTypeString' 
								});
								oldIdd = config.attributes.filter(a => {
									return a.name==='OldIDD' 
								});
								initDate = config.attributes.filter(a => {
									return a.name==='initialActivationDate' 
								});
    							internationalDirectDialIn=config.attributes.filter(a => {
									return a.name==='InternationalDirectDial' && a.value
								});
								BussinessId_PI = config.attributes.filter(a => {
									return a.name==='BussinessId_PI'
								}); //Added by Aman Soni as a part of EDGE-123593 || Start
								EmChangeType = config.attributes.filter(a => {
									return a.name==='ChangeType'
								}); //Added by Aman Soni as a part of EDGE-123593 || End
								BussinessId_Addon = config.attributes.filter(a => {
									return a.name==='BussinessId_Addon'
								});
							}
						}								
					});
				}
			}
		});
	}
});
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
        if(attributeName === 'viewDiscounts'){	
            if(communitySiteId){
                url='/partners/';
                url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId='+solutionId+'&accessMode=ReadOnly'+'&customAttribute='+attributeName+'&priceItemId='+priceItemId+'&configId='+configId;
                vfRedirect ='<div><iframe id="viewDiscounts" iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="900px" width="820px"></iframe></div>';
                console.log('Url ---->',url);
            }
            else {
        		console.log('c__HandlingDiscounts else');
                url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId='+solutionId+'&accessMode=ReadOnly'+'&customAttribute='+attributeName+'&priceItemId='+priceItemId+'&configId='+configId+'&solutionName=Connected Workplace';
                vfRedirect ='<div><iframe id="viewDiscounts" iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="800px" width="820px"></iframe></div>';
 console.log('Url ---->',url);	
            }
            console.log('vfRedirect--->'+vfRedirect);	
        }
    console.log('Attribute name **'+attributeName + 'vfRedirect '+vfRedirect);
    if (attributeName === 'Price Schedule'){ // added by Kiran
	if(communitySiteId){
		url='/partners/';		
		url = url + 'c__PriceSchedulePage?configId='+configId + '&BussinessId_Addon=' +'&BussinessId_Addon='+'&BussinessId_PI=' +BussinessId_PI+'&planName='+planName+'&addOnName='+addOnName+'&EmChangeTypeValue='+EmChangeTypeValue+'&oldPlanName='+oldPlanName+'&oldIddName='+oldIddName+'&initialDate='+initialDate;//Added EmChangeTypeValue,oldPlanName and oldIddName by Aman Soni as a part of EDGE-123593
		vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="900px" width="820px"></iframe></div>';
		console.log('Url ---->',url);
	}else{
        console.log('inside else communitySiteId '+communitySiteId);
		url = url + 'c__PriceSchedulePage?configId='+configId + '&BussinessId_Addon=' +'&BussinessId_Addon='+'&BussinessId_PI=' +BussinessId_PI+'&planName='+planName+'&addOnName='+addOnName+'&EmChangeTypeValue='+EmChangeTypeValue+'&oldPlanName='+oldPlanName+'&oldIddName='+oldIddName+'&initialDate='+initialDate;//Added EmChangeTypeValue,oldPlanName and oldIddName by Aman Soni as a part of EDGE-123593
		vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="800px" width="820px"></iframe></div>';
		console.log('Url ---->',url);	
	}
	console.log('vfRedirect value--->'+vfRedirect);
}
return Promise.resolve(vfRedirect);	

};
        			
}