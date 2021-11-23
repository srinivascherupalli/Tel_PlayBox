/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	Author 			Date
1 			Tihomir  						Original Code
2			Laxmi Rahate	29-Jul-2019		Added code to create attachments for MDM Tenancy
3 			Venkata Ramanan 30-Jul-2019		Updated code,Json Schema for MDM Tenancy to create & view MDM Tenancy OE
4           Venkata Ramanan 09-Aug-2019             Updated code to error configuration when OE data not filled
5           Tihomir Baljak  13-08-2019      Code refactoring - save, OE
6           Venkata Ramanan 04-11-2019      Edge - 117274 - Tenancy Generic Modelling Changes 
7           Aniket Srivastava 24/01/2020    EDGE-119833
8           Shubhi             20/05/2020   Edge-148455
9			Gnana		    10-Jun-2020	    EDGE-149887 : Solution Name Update Logic 
10          Sukul Mongia      19/06/2020    Spring 20 Upgrade 
11			Gnana/Aditya 	19-July-2020	CS Spring'20 Upgrade
12          Pallavi D       18.08.2020      Added call to hide import button, and a fix to make the fields readonly in contract Accept stage

13          Krunal Taak     15-07-2020      Generate Net Price Button for PLATFORM 
14          Shresth Dixit     20-07-2020      Generate Rate Card Matrix(DPG - 2084)
15			Ila Anmol Verma	 28-07-2020			//DPG-2179: Added for reset custom attribute

 ********************/
const TENANCY_COMPONENT_NAMES = {
    solution: 'Telstra Mobile Device Management - VMware', //'Telstra Mobile Device Management Tenancy',
    // solution: 'Tenancy',
    tenancy: 'Platform',
};
var mdmtenancyid = null;
var executeSaveTMDM = false;
var allowSaveTMDM = false;
var solution = '';
var isTypeNew = false; //EDGE-119833 
var tenancyAPIdone = false;
var updateVendorName = false;
var isVendorNull = false;
var offerName = 'DMCAT_Offer_000681'; //EDGE-119833 
var DEFAULTSOLUTIONNAME_TMDM = 'Telstra Mobile Device Management - VMware';  // Added as part of EDGE-149887
var communitySiteId =''; //Added by shresth DPG-2084
var c = 0;
var billingAccount='';
if(!CS || !CS.SM){
    throw Error('Solution Console Api not loaded?');
}
if (CS.SM.registerPlugin) {
    console.log('Load T-MDM plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () {
        await CS.SM.registerPlugin(TENANCY_COMPONENT_NAMES.solution)
            .then(async TenancyPlugin => {
                console.log("Plugin registered for TMDM");
                updateTenancyPlugin(TenancyPlugin);
        		//Krunal
        		//window.addEventListener('message', handleIframeMessage);
				//setInterval(processMessagesFromIFrame, 500);
        		//Krunal
                console.log("UpdatedPlugin calling");
                return Promise.resolve(true);
            });
        return Promise.resolve(true);
    });
}
function updateTenancyPlugin(TenancyPlugin) {
    console.log('UpdatePlugin Called');
    window.addEventListener('message', TenancyPlugin_handleIframeMessage);
    Utils.updateImportConfigButtonVisibility();
    //AB rename customAttribute link text, added click event listener
    document.addEventListener('click', function (e) {
        e = e || window.event;
        var target = e.target || e.srcElement;
        var text = target.textContent || target.innerText;
        if (window.currentSolutionName === TENANCY_COMPONENT_NAMES.solution && text &&
            (text.toLowerCase() === TENANCY_COMPONENT_NAMES.tenancy.toLowerCase())) {
            Utils.updateCustomAttributeLinkText('View Rate Card', 'View Price Breakdown');
        }
    }, false);
    //EDGE-135267 Aakil
    if (window.currentSolutionName === TENANCY_COMPONENT_NAMES.solution && text && (text.toLowerCase() === 'overview' || text.toLowerCase().includes('stage'))) {
        Utils.hideSubmitSolutionFromOverviewTab();
    }
    //
    //setInterval(saveSolutionTMDM, 500); 
    //TenancyPlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
    TenancyPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        let solution = result.solution;
        updateSolutionName_TMDM(); // Added as part of EDGE-149887
        console.log('afterSave', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
        Utils.updateCustomAttributeLinkText('View Rate Card', 'View Price Breakdown');
        //TenancyPlugin.setOEtabsforPlatform(solution);
        setOEtabsforPlatform(solution);
        //EDGE-135267
        Utils.hideSubmitSolutionFromOverviewTab();
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
        return Promise.resolve(true);
    }
    //Aditya: Spring Update for changing basket stage to Draft
    TenancyPlugin.afterSolutionDelete = function (solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }
    //TenancyPlugin.afterSolutionLoaded = function _AfterSolutionLoaded(previousSolution, loadedSolution) {
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let currentBasket = await CS.SM.getActiveBasket();
        let loadedSolution = await CS.SM.getActiveSolution();
        if(loadedSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)){
            console.log('After Solution Loaded');
            window.currentSolutionName = loadedSolution.name; //Added by Venkat to Hide OOTB OE Console Button
            console.log('TMDM After Solution Loaded', loadedSolution);
            //if (loadedSolution.type && loadedSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
            if (loadedSolution.componentType && loadedSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
                //Getting the basket ID which is needed for Adding Sites
                c = 0;
                //CS.SM.getCurrentCart().then(cart => {
                console.log('Basket: ', currentBasket);
                basketId = currentBasket.basketId;
                solution = loadedSolution;
                let inputMap = {};
                inputMap['GetBasket'] = basketId;
            	//Added by shresth DPG-2084 Start
            	inputMap['GetSiteId'] = "";
            	//Added by shresth DPG-2084 End
                inputMap['GetBasket'] = basketId;
                //CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                    //Added by shresth DPG-2084 Start
                	communitySiteId = result["GetSiteId"];
                	//Added by shresth DPG-2084 End
                    console.log('GetBasket finished with response: ', result);
                    var basket = JSON.parse(result["GetBasket"]);
                    console.log('GetBasket: ', basket);
                    basketChangeType = basket.csordtelcoa__Change_Type__c;
                    basketStage = basket.csordtelcoa__Basket_Stage__c;
                    accountId = basket.csbb__Account__c;
                    //Added by Venkat for US# - EDGE - 92244
                    if (basketStage === 'Contract Accepted'){
                        loadedSolution.lock('Commercial',false);
                    }
                    if (basketStage === 'Commercial Configuration')
                        getExistingTenancySubscriptions(accountId, loadedSolution);
                    	//getExistingTenancySubscriptionsForBilling(accountId, 'a5P5P0000000FjoUAE', loadedSolution);
                    //Change ends by Venkat for EDGE - 92244
                    handleButtonVisibility(loadedSolution); //Shresth DPG-2084
                    //Added by shubhi edge-148455 start
                    if(accountId!=null && basketStage !== 'Contract Accepted'){
                        //console.log('DOP_COMPONENT_NAMES.solution-->'+DOP_COMPONENT_NAMES.solution);
                        CommonUtills.setAccountID(TENANCY_COMPONENT_NAMES.solution,accountId);
                    }
                    ////Added by shubhi edge-148455 end
                    //window.oeSetBasketData(basketId, basketStage, accountId);
                    window.oeSetBasketData(loadedSolution, basketStage, accountId);
                    console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId);
                    console.log('basketStage: ', basketStage);
                    addDefaultTMDMOEConfigs();
                    //populateRateCardinAttachmentTenancy();
                    Utils.updateCustomAttributeLinkText('View Rate Card', 'View Price Breakdown');
                    //TenancyPlugin.setOEtabsforPlatform(solution);
                    setOEtabsforPlatform(solution);
                    if (basketStage === 'Contract Accepted'){
                        loadedSolution.lock('Commercial',true);
                    }

                    //Added by shresth/ila/krunal
                    /*Commented by shresth (part of pricing)
                    var SelectPlan =result['SelectPlan'];
                	var BusinessId_Platform = result['BusinessId_Platform'];
                	//console.log('--Business Id--'+BusinessId_Platform);
                	//console.log('--SelectPlan--'+SelectPlan);
                	let updateMap={}; 
                	console.log('guid tmdm'+loadedSolution.schema.configurations[0].guid+'----'+SelectPlan+'===='+BusinessId_Platform);
                	updateMap[loadedSolution.schema.configurations[0].guid] = [{
        				name: 'Select Plan',
        				value: SelectPlan
    				},
                	{
        				name: 'BusinessId_Platform',
        				value: BusinessId_Platform
    				}];                                 
                	CS.SM.updateConfigurationAttribute(TENANCY_COMPONENT_NAMES.solution, updateMap, true);
                    console.log(Object.values(loadedSolution.schema.configurations)[0]);
                    let updateConfigMap={};
                    updateConfigMap[Object.values(loadedSolution.schema.configurations)[0].guid]=[{
        				name: 'Select Plan',
        				value: SelectPlan
    				},
                	{
        				name: 'BusinessId_Platform',
        				value: BusinessId_Platform
    				}];
                  	if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                    	keys = Object.keys(updateConfigMap);
                    	for (let i = 0; i < keys.length; i++) {
                        	loadedSolution.updateConfigurationAttribute(keys[i],updateConfigMap[keys[i]],true);
                        	//currentComponent.lock('Commercial',true);
                    	}
                	} */
            		//Added by shresth

                });
                //});
            }
        }
        return Promise.resolve(true);
    });
    //}
    TenancyPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution){
        console.log('afterSolutionLoaded');
       return Promise.resolve(true);
    }
    //TenancyPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {
    TenancyPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
        console.log('afterConfigurationAdd', component, configuration);
        console.log('component'+component.Name);
        let currentBasket = await CS.SM.getActiveBasket();
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(component.name);
        var updateMap = {};
        var vendorname = '';
        let inputMap = {};
        inputMap['OfferId'] = offerName;
        //await CS.SM.WebService.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
        await currentBasket.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
            function (response) {
                if (response && response['vendor'] != undefined) {
                    console.log('vendor', response['vendor']);
                    var vendorinfo = response["vendor"];
                    vendorname = vendorinfo.Vendor__c;
                }
            });
        //   alert('configuration' + configuration.guid);
        /*updateMap[configuration.guid] = [{
            name: "Vendor Name",
            value: vendorname
        }];*/
        updateMap[configuration.guid] = [];
        updateMap[configuration.guid].push({
            name: "Vendor Name",
            value: vendorname
        });
        // alert('updateMap@@::' + JSON.stringify(updateMap));
        /*await CS.SM.getActiveSolution().then((product) => {
            product.components.forEach((comp) => {
                if (comp.name == "Platform") {
                    CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                    isTypeNew = false;
                }
            });
        }); */
        //EDGE-119833  Start
        var sParentAttrib = null;
        //await CS.SM.getActiveSolution().then((currentSolution) => {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            Object.values(currentSolution.components).forEach((comp) => {
            //currentSolution.components.forEach((comp) => {
                // alert('comp.name@@::' + comp.name);
                if (comp.name == "Platform") {
                    // alert(JSON.stringify(comp.name)+"<----addConfigurations:--> "+ JSON.stringify(comp.type));
                    if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        //comp.schema.configurations.forEach((config) => {
                        Object.values(comp.schema.configurations).forEach((config) => {
                            if (config.attributes && Object.values(config.attributes).length > 0) {
                                Object.values(config.attributes).forEach((attribute) => {
                                    if (attribute.name == "ChangeType" && attribute.value == 'New') {
                                        updateVendorName = true;
                                    }
                                    if (attribute.name == "Vendor Name" && attribute.value == '') {
                                        isVendorNull = true;
                                    }
                                });
                            }
                            /*config.attributes.forEach((attribute) => {
                                if (attribute.name == "ChangeType" && attribute.value == 'New') {
                                    updateVendorName = true;
                                    //alert('attribute.name::' + attribute.name + '@@@attribute.value::' + attribute.value);
                                    //isTypeNew = true;
                                }
                            });
                            config.attributes.forEach((attribute) => {
                                if (attribute.name == "Vendor Name" && attribute.value == '') {
                                    isVendorNull = true;
                                    //alert('attribute.name::' + attribute.name + '@@@attribute.value::' + attribute.value);
                                    //isTypeNew = true;
                                }
                            });*/
                            if (updateVendorName == true && isVendorNull == true) {
                                if (updateMap && Object.keys(updateMap).length > 0) {
                                    keys = Object.keys(updateMap);
                                    for (let i = 0; i < keys.length; i++) {
                                        currentComponent.updateConfigurationAttribute(keys[i],updateMap[keys[i]],true);
                                    }
                                }    
                                //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                                //currentSolution.updateConfigurationAttribute(config.guid, updateMap, true);
                                updateVendorName = false;
                                isVendorNull = false;
                            }
                        });
                    }
                }
            });
        } //});
        /*if (isTypeNew == true) {
            var updateMap = {};
            var vendorname = '';
            let inputMap = {};
            inputMap['OfferId'] = offerName;
            await CS.SM.WebService.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
                function(response) {
                    if (response && response['vendor'] != undefined) {
                        console.log('vendor', response['vendor']);
                        var vendorinfo = response["vendor"];
                        vendorname = vendorinfo.Vendor__c;
                    }
                });
            //   alert('configuration' + configuration.guid);
            updateMap[configuration.guid] = [{
                name: "Vendor Name",
                value: vendorname
            }];
            // alert('updateMap@@::' + JSON.stringify(updateMap));
            await CS.SM.getActiveSolution().then((product) => {
                product.components.forEach((comp) => {
                    if (comp.name == "Platform") {
                        CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        isTypeNew = false;
                    }
                });
            });
        }*/
        //EDGE-119833 End
        addDefaultTMDMOEConfigs();
        return Promise.resolve(true);
    }
    //TenancyPlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        //console.log('afterOrderEnrichmentTabLoaded: ', configurationGuid, OETabName);
        if(solution.name.includes(TENANCY_COMPONENT_NAMES.solution)){
            console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
            //var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            //window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });
    //TenancyPlugin.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
    TenancyPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {
        console.log('CWP afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration)
        //  initializeTMDMOEConfigs();
        //getMDMRangeDataAddedinAttachment();
        //window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    }
    //TenancyPlugin.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {
    TenancyPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
        console.log('After afterOrderEnrichmentConfigurationDelete');
        //window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };
    //TenancyPlugin.afterAttributeUpdated = function (componentName, guid, attribute, oldValue, newValue) {
    TenancyPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
        let loadedSolution = await CS.SM.getActiveSolution();
        if(window.basketStage === 'Contract Accepted'){
            loadedSolution.lock('Commercial',false);
        }
        //console.log('Attribute Update', componentName, guid, attribute, oldValue, newValue);
        console.log('Attribute Update', component.name, configuration.guid, attribute.value, oldValueMap['value']);
        //if ( componentName=== 'Tenancy Contact Details' &&  attribute.name === 'TenancyPrimaryContact') {
        if (component.name === 'Tenancy Contact Details' && attribute.name === 'TenancyPrimaryContact') {
            //updateTenancyContactDetails(guid, newValue);
            updateTenancyContactDetails(configuration.guid, attribute.value);
            // getMDMRangeDataAddedinAttachment();
        }
        //if(componentName === TENANCY_COMPONENT_NAMES.solution && attribute.name === 'Marketable Offer' && attribute.value !== ''){
        if (component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === 'Marketable Offer' && attribute.value !== '') {
            //updatevendordetails(guid);
            updatevendordetails(configuration.guid);
        }
        //Shresth DPG-2084 Start
		if(component.name === TENANCY_COMPONENT_NAMES.solution && attribute.name === 'OfferId'){
        	console.log('---offerid value==---'+attribute.value);
       		Utils.updateComponentLevelButtonVisibility('View Price Breakdown', attribute.value, false);
    	}
        //Shresth DPG-2084 End
        //DPG-2168
        if (component.name === TENANCY_COMPONENT_NAMES.solution  && attribute.name === "BillingAccountShadowTMDM") {
            //BillingAccountShadowTMDM
			billingAccount=attribute.value;
            console.log('---billingAccount==---'+billingAccount);
        	//getExistingTenancySubscriptionsForBilling(billingAccount,component.Name,configuration.guid);
        	getExistingTenancySubscriptionsForBilling(billingAccount);
        	//getExistingTenancySubscriptions(accountId, loadedSolution);
    }
        //window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
        window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
        if(window.basketStage === 'Contract Accepted'){
            loadedSolution.lock('Commercial',true);
        }
        return Promise.resolve(true);
    }
    //Added by Venkat as workaround for Attribute updated hook not working for 1st update in OE. Can be removed once this issue is fixed
    TenancyPlugin.beforeSave = function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        console.log('Inside before save');
        //DO NOT PUT IN beforeSave ANY ADDITIONAL CODE,  ESPECIALLY CODE FOR UPDATING VALUES  OR ANY ASYNC CODE !!!!!
        if (allowSaveTMDM) {
            allowSaveTMDM = false;
            console.log('beforeSave - exiting true');
            return Promise.resolve(true);
        }
        executeSaveTMDM = true;
        //console.log('beforeSave - exiting false');
        //return Promise.resolve(false);
        return Promise.resolve(true);
    }
}
/*window.document.addEventListener('SolutionConsoleReady', function () {
    console.log('Inside UI Plugin Register');
    if (CS.SM.registerUIPlugin) {
        CS.SM.UIPlugin.onCustomAttributeEdit = async function (componentName, configurationGuid, attributeName) {
            var url = '';
            var vfRedirect = '';
            var offerid = '';
            var vendor = '';
            let solution = await CS.SM.getActiveSolution();
            //await CS.SM.getActiveSolution().then((solution) => {
            if (solution.type && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
                //if (solution.components && solution.components.length > 0) {
                if (solution.components && solution.components.size > 0) {
                    if (solution.schema && solution.schema.configurations && solution.schema.configurations.size > 0) {
                        //solution.schema.configurations.forEach((config) => {
                        Object.values(solution.schema.configurations).forEach((config) => {
                            //if (config.attributes && config.attributes.length > 0){
                            if (config.attributes && config.attributes.size > 0) {
                                //offerid = config.attributes.filter((attr) => {
                                offerid = Object.values(config.attributes).filter((attr) => {
                                    return attr.name === 'OfferId'
                                });
                                //vendor = config.attributes.filter((attr) => {
                                vendor = Object.values(config.attributes).filter((attr) => {
                                    return attr.name === 'Vendor'
                                });
                            }
                        });
                    }
                }
            }
            var redirectURI = '/apex/';
            if (communitySiteId) {
                url = window.location.href;
                if (url.includes('partners.enterprise.telstra.com.au'))
                    redirectURI = '/s/sfdcpage/%2Fapex%2F';
                else
                    redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
            }
            url = redirectURI;
            if (communitySiteId) {
                url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                console.log('Url ---->', url);
            } else {
                url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                //url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + 'Standard' + '&techSupport=' + 'Bus Hrs' + '&type=End User Support';
                console.log('Url ---->', url);
            }
            console.log('Offer Id --->' + offerid);
            console.log('Vendor Id --->' + vendor);
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="/apex/c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value + '" style="" height="300px" width="400px"></iframe></div>';
            //});
            return Promise.resolve(vfRedirect);
        }
        CS.SM.UIPlugin.buttonClickHandler = async function (buttonSettings) {
            //console.log('Inside customAttributeEdit Guid--->'+configurationGuid);
            var url = '';
            var vfRedirect = '';
            var offerid = '';
            var vendor = '';
            let solution = await CS.SM.getActiveSolution();
            //await CS.SM.getActiveSolution().then((solution) => {
            if (solution.type && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
                //if (solution.components && solution.components.length > 0) {
                if (solution.components && solution.components.size > 0) {
                    if (solution.schema && solution.schema.configurations && solution.schema.configurations.size > 0) {
                        //solution.schema.configurations.forEach((config) => {
                        Object.values(solution.schema.configurations).forEach((config) => {
                            //if (config.attributes && config.attributes.length > 0){
                            if (config.attributes && config.attributes.size > 0) {
                                //offerid = config.attributes.filter((attr) => {
                                offerid = Object.values(config.attributes).filter((attr) => {
                                    return attr.name === 'OfferId'
                                });
                                //vendor = config.attributes.filter((attr) => {
                                vendor = Object.values(config.attributes).filter((attr) => {
                                    return attr.name === 'Vendor'
                                });
                            }
                        });
                    }
                }
            }
            var redirectURI = '/apex/';
            if (communitySiteId) {
                url = window.location.href;
                if (url.includes('partners.enterprise.telstra.com.au'))
                    redirectURI = '/s/sfdcpage/%2Fapex%2F';
                else
                    redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
            }
            url = redirectURI;
            if (buttonSettings.id === 'ViewPriceBreakdownButton') {
                if (communitySiteId) {
                    url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                    console.log('Url ---->', url);
                } else {
                    url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                    //url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + 'Standard' + '&techSupport=' + 'Bus Hrs' + '&type=End User Support';
                    console.log('Url ---->', url);
                }
                console.log('Offer Id --->' + offerid);
                console.log('Vendor Id @buttonclick --->' + vendor);
                vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="/apex/c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value + '" style="" height="250px" width="500px"></iframe></div>';
                console.log('vfRedirect--->' + vfRedirect);
                console.log('vfRedirect. url--->' + url);
            }
            /*
            User Story : EDGE-119832
            Developer Name : Maq
            Desc : Changes made for MDM Tenancy
            *Sukul
            if (buttonSettings.id === 'SCAddLegacyTenancy') {
                // alert('****Im Inside Button setting'+JSON.stringify(buttonSettings));
                var arrStr = '';
                console.log('basketId', basketId);
                console.log('existingSiteIds', arrStr);
                if (communitySiteId) {
                    url = url + encodeURIComponent('c__SCAddLegacyTenancy?basketId=' + basketId + '&caller=MDMTenancy');
                } else {
                    url = url + 'c__SCAddLegacyTenancy?id=' + basketId + '&caller=MDMTenancy';
                }
                vfRedirect = url;
                return Promise.resolve(url);
            }
            // return Promise.resolve(url);	
            //});
            return Promise.resolve(vfRedirect);
        }
        console.log('Registering UI Plugin');
        //CS.SM.registerUIPlugin();
    }
});*/
async function saveSolutionTMDM() {
    let currentBasket = await CS.SM.getActiveBasket();
    console.log('Inside saveSolutionTMDM');
    if (executeSaveTMDM) {
        executeSaveTMDM = false;
        if (basketStage === 'Contract Accepted') {
            var issaveallowed = true;
            let solution = await CS.SM.getActiveSolution();
            /*await CS.SM.getActiveSolution().then((product) => {
                solution = product;
            });*/
            //if (solution.orderEnrichments && solution.orderEnrichments.length > 0) {
            if (solution.orderEnrichments && Object.values(solution.orderEnrichments).length > 0) {
                for (var i = 0; i < Object.values(solution.schema.configurations).length; i++) {
                    var config = Object.values(solution.schema.configurations)[i];
                    for (var j = 0; j < config.orderEnrichmentList.length; j++) {
                        var oeconfig = config.orderEnrichmentList[j];
                        if (oeconfig.parent !== mdmtenancyid) {
                            for (var k = 0; k < oeconfig.attributes.length; k++) {
                                var oeattr = oeconfig.attributes[k];
                                if (oeattr.name === 'TenancyPrimaryContact') {
                                    if (oeattr.value === '') {
                                        CS.SM.displayMessage('MDM Tenancy Contact details enrichment is incomplete', 'error');
                                        issaveallowed = false;
                                    } else {
                                        await updateTenancyContactDetails(oeconfig.guid, oeattr.value);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (!issaveallowed)
                return Promise.resolve(false);
        }
        allowSaveTMDM = true;
        //await CS.SM.saveSolution();
        await currentBasket.saveSolution();
    }
    return Promise.resolve(true);
}
//TenancyPlugin.setOEtabsforPlatform = function(solution){
setOEtabsforPlatform = function (solution) {
    console.log('setOEtabsforPlatform' + solution);
    //if (solution.type && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
    if (solution.componentType && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {
            //solution.components.forEach((comp) => {
            Object.values(solution.components).forEach((comp) => {
                if (comp.name === TENANCY_COMPONENT_NAMES.tenancy && Utils.isOrderEnrichmentAllowed()) {
                    //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        //comp.schema.configurations.forEach((config) => {
                        Object.values(comp.schema.configurations).forEach((config) => {
                            CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Tenancy Contact Details']);
                        });
                    }
                }
            });
        }
    }
}
/****************************************************************************************************
	 * Author	: Shresth Dixit
	 * Method Name : handleButtonVisibility
	 * Defect/US # : DPG-2084
	 * Invoked When: On Solution Load
	 * Description : For Setting Visibility 
	 ************************************************************************************************/
handleButtonVisibility = function(solution){//shresth DPG-2084
    var offerid='';
    console.log('Hello'+Object.values(solution.schema.configurations).length);
    console.log(solution.type);
    console.log(solution.name.includes(TENANCY_COMPONENT_NAMES.solution));
	if (solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
            console.log('Hello'+Object.values(solution.schema.configurations).length);
            var offerid = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(att => {
                return att.name === 'OfferId'
            });
            Utils.updateComponentLevelButtonVisibility('View Price Breakdown',offerid[0].value, false);
        }
    }
}
/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : addDefaultTMDMOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if there is none
 * Parameters  : none
 ********************************************************************************************************************************************/
async function addDefaultTMDMOEConfigs() {
    console.log('addDefaultTMDMOEConfigs------');
    if (basketStage !== 'Contract Accepted')
        return;
    var oeMap = [];
    //getMDMRangeDataAddedinAttachment();
    //await CS.SM.getActiveSolution().then((currentSolution) => {
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultTMDMOEConfigs ', currentSolution);
    //if (currentSolution.type && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
    if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        //currentSolution.components.forEach((comp) => {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            Object.values(currentSolution.components).forEach((comp) => {
                if (comp.name === TENANCY_COMPONENT_NAMES.tenancy) {
                    console.log('Tenancy component-->', comp);
                    //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        Object.values(comp.schema.configurations).forEach((config) => {
                            console.log('Tenancy component config-->', config);
                            Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                                var found = false;
                                if (!oeSchema.name.includes('RateCard')) {
                                    if (config.orderEnrichmentList) {
                                        var oeConfig = config.orderEnrichmentList.filter(oe => {
                                            return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId)
                                        });
                                        if (oeConfig && oeConfig.length > 0)
                                            found = true;
                                    }
                                    if (!found) {
                                        var el = {};
                                        el.componentName = TENANCY_COMPONENT_NAMES.tenancy;
                                        el.configGuid = config.guid;
                                        el.oeSchema = oeSchema;
                                        oeMap.push(el);
                                        console.log('Adding default oe config for:', TENANCY_COMPONENT_NAMES.tenancy, config.name, oeSchema.name);
                                    }
                                } else
                                    mdmtenancyid = oeSchema.id;
                                console.log('oeMap.length ------' + oeMap.length);
                                // }
                            });
                            //CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Tenancy Contact Details']);
                        });
                    }
                }
            });
        }
        //  });
        // }
    }
    //}).then(() => Promise.resolve(true));
    //console.log('addDefaultOEConfigs prepared');
    /*if (oeMap.length> 0) {
        var map = [];
        map.push({});
        console.log('Adding default oe config map--:',oeMap);
        for (var i=0; i< oeMap.length;i++) {
			console.log ( ' Component name ----' + oeMap[i].componentName);
            await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
        };
    }*/
    if (oeMap.length > 0) {
        console.log('Adding default oe config map--:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            console.log(' Component name ----' + oeMap[i].componentName);
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        };
    }
    await initializeTMDMOEConfigs();
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : initializeTMDMOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 * updated by shubhi after adding solution PD 
 ********************************************************************************************************************************************/
async function initializeTMDMOEConfigs() {
    console.log('initializeTMDMOEConfigs');
    let currentSolution = await CS.SM.getActiveSolution();
    /* await CS.SM.getActiveSolution().then((solution) => {
         currentSolution = solution;
         console.log('initializeTMDMOEConfigs - getActiveSolution');
     }).then(() => Promise.resolve(true));*/
    if (currentSolution) {
        console.log('initializeTMDMOEConfigs - updating');
        //if (currentSolution.type && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                for (let i = 0; i < Object.values(currentSolution.components).length; i++) {
                    let comp = Object.values(currentSolution.components)[i];
                    if (comp.name === TENANCY_COMPONENT_NAMES.tenancy) {
                        console.log('Tenancy component-->', comp);
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            //comp.schema.configurations.forEach((config) => {
                            for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                                let config = Object.values(comp.schema.configurations)[j];
                                var updateMap = {};
                                var oeConfigMap = {};
                                if (config.orderEnrichmentList) {
                                    for (var k = 0; k < config.orderEnrichmentList.length; k++) {
                                        var oe = config.orderEnrichmentList[k];
                                        var basketAttribute = Object.values(oe.attributes).filter(a => {
                                            return a.name.toLowerCase() === 'basketid'
                                        });
                                        if (basketAttribute && basketAttribute.length > 0) {
                                            if (!updateMap[oe.guid])
                                                updateMap[oe.guid] = [];
                                            updateMap[oe.guid].push({
                                                name: basketAttribute[0].name,
                                                value: basketId
                                            });
                                            //oeConfigMap[oe.guid] = [];
                                            //oeConfigMap[oe.guid].push(config.guid);
                                        }
                                    }
                                }
                                if (updateMap && Object.keys(updateMap).length > 0) {
                                    console.log('initializeTMDMOEConfigs updateMap:', updateMap);
                                    let keys = Object.keys(updateMap);
                                    console.log('initializeTMDMOEConfigs keys:', keys);
                                    for(var h=0; h< updateMap.length;h++){
                                        await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],true)
                                    }
                                    //	getMDMRangeDataAddedinAttachment();
                                    //await CS.SM.updateOEConfigurationAttribute(TENANCY_COMPONENT_NAMES.tenancy, config.guid, updateMap, false).then(() => Promise.resolve(true));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
async function updateTenancyContactDetails(guid, newValue) {
    console.log('updateTenancyContactDetails');
    if (basketStage !== 'Contract Accepted')
        return Promise.resolve(true);
    /*var currentSolution;
    await CS.SM.getActiveSolution().then((product) => {
        currentSolution = product;
    });*/
    let currentSolution = await CS.SM.getActiveSolution();
    let currentComponent = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.tenancy);
    //if (currentSolution.type && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
    if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            //for (let i=0; i<currentSolution.components.length; i++ ) {
            //  let comp = currentSolution.components[i];
            for (let i = 0; i < Object.values(currentSolution.components).length; i++) {
                let comp = Object.values(currentSolution.components)[i];
                if (comp.name === TENANCY_COMPONENT_NAMES.tenancy) {
                    console.log('Tenancy component-->', comp);
                    //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        //for (let j=0; j<comp.schema.configurations.length; j++) {
                        for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                            let config = Object.values(comp.schema.configurations)[j];
                            if (config.orderEnrichmentList) {
                                var oeConfig = config.orderEnrichmentList.filter(oe => {
                                    return (oe.guid === guid)
                                });
                                if (oeConfig && oeConfig.length > 0) {
                                    var updateConfigMap = {};
                                    /*updateConfigMap[config.guid] = [{
                                        name: 'TenancyPrimaryContact',
                                        value: {
                                            value: newValue
                                        }
                                    }];*/
                                    updateConfigMap[config.guid] = [];
                                    updateConfigMap[config.guid].push({
                                        name: "TenancyPrimaryContact",
                                        value: newValue
                                    });
                                    if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                                        keys = Object.keys(updateConfigMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            //currentComponent.lock('Commercial',false);
                                            await currentComponent.updateConfigurationAttribute(keys[i],updateConfigMap[keys[i]],true);
                                            //currentComponent.lock('Commercial',true);
                                        }
                                    }   
                                    //await CS.SM.updateConfigurationAttribute(TENANCY_COMPONENT_NAMES.solution, updateConfigMap, true);
                                    //await currentSolution.updateConfigurationAttribute(comp.configuration.guid, updateConfigMap, true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
async function updatevendordetails(guid) {
    console.log('updatevendordetails');
    /*var currentSolution;
    await CS.SM.getActiveSolution().then((product) => {
        currentSolution = product;
    });*/
    let currentSolution = await CS.SM.getActiveSolution();
    let currentBasket = await CS.SM.getActiveBasket();
    let component = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.solution);
    let solutionconfig = component.getConfigurations();
    let updateConfigMap = {};
    let inputMap = {};
            if (solutionconfig) {
                inputMap['OfferId'] = 'DMCAT_Offer_000681';
                //CS.SM.WebService.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
                await currentBasket.performRemoteAction('CSTenancyVendorlookup', inputMap).then(
                    function (response) {
                        if (response && response['vendor'] != undefined) {
                            console.log('vendor', response['vendor']);
                            var vendorinfo = response["vendor"];
                            var vendorname = vendorinfo.Vendor__c;
                            var vendorid = vendorinfo.Id;
                            updateConfigMap[guid] = [];
                            updateConfigMap[guid].push({
                                name: "Vendor Name",
                                value: vendorname
                            },{
                                name: 'Vendor',
                                value: vendorid
                            });
                        }
                    });
            }
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    component.updateConfigurationAttribute(keys[i],updateConfigMap[keys[i]],true);
                }
            }     
            //let component = currentSolution.getComponentByName(TENANCY_COMPONENT_NAMES.solution); 
            //CS.SM.updateConfigurationAttribute(TENANCY_COMPONENT_NAMES.solution, updateConfigMap, true);
            //component.updateConfigurationAttribute(guid, updateConfigMap, true);
            return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Laxmi Rahate/Shubhi
 * Method Name : getMDMRangeDataAddedinAttachment
 * Invoked When: after solution is loaded
 * Updated by shubhi after adding solution PD
 ********************************************************************************************************************************************/
/*
async function getMDMRangeDataAddedinAttachment(){
	console.log ( ' Inside getMDMRangeDataAddedinAttachment!!!! ' );
	// CS.SM.getActiveSolution();	
    if (basketStage !== 'Contract Accepted' || c > 0)
        return;
	var oeMap=[];
	 CS.SM.getActiveSolution().then((currentSolution) => {
        console.log('addDefaultTMDMOEConfigs ',  currentSolution);
        if (currentSolution.type && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
			currentSolution.components.forEach((comp) => {
				if (comp.name === TENANCY_COMPONENT_NAMES.tenancy) {
					console.log('Tenancy component-->',comp);
					if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
						comp.schema.configurations.forEach((config) => {
							if(config.orderEnrichmentList.length > 0){
								config.orderEnrichmentList.forEach((oelist) => {
									if(oelist.name.includes('MDM Tenancy') || oelist.parent===mdmtenancyid)
									c++;									
								});
							}
							if(c===0){
								currentSolution.components.forEach((comp) => {									
										comp.orderEnrichments.forEach((oeSchema) => {
											if(oeSchema.name === 'MDM Tenancy' && oeSchema.schema.configurations.length === 0){
												var el = {};
												el.componentName = TENANCY_COMPONENT_NAMES.tenancy;
												el.configGuid = config.guid;
												el.oeSchemaId = oeSchema.id;
												el.oeSchemaname = oeSchema.name;
												oeMap.push(el);
												console.log('Adding default oe config for:', TENANCY_COMPONENT_NAMES.solution, config.name, oeSchema.name);
											}
										});
								});
							}
						});
					}
				}
			});
        }
    });
	 let inputMap = {};
	 CS.SM.WebService.performRemoteAction('SolutionGetMDMTenancyRangeData', inputMap).then(
			function (response) {                
				if (response && response['mdmRangeData'] != undefined) {
					console.log('mdmRangeData', response['mdmRangeData']);                
					aArray = [];
					response['mdmRangeData'].forEach((rangeData) => {
						let aData = {};
						aData['rangeFrom'] = rangeData.rangeFrom__c;
						aData['rangeTo'] = rangeData.rangeTo__c;
						aData['price'] = rangeData.cspmb__Recurring_Charge__c;
						aArray.push(aData);
                    })
                    for(var i=0; i< oeMap.length;i++){
					console.log(' Comp name' + oeMap[i].componentName + ' compID : ' + oeMap[i].configGuid + ' oeId : '+ oeMap[i].oeSchemaId + 'oename:' +oeMap[i].oeSchemaname );
                    CS.SM.addOrderEnrichments(oeMap[i].componentName,oeMap[i].configGuid , oeMap[i].oeSchemaId, aArray);
                   // CS.SM.setOELockOnComponent(oeMap[i].oeSchemaname,true);	                
                    }
				} else {
					console.log('no response from SolutionGetMDMTenancyRangeData Or no Data Returned!');
				}
			})
}*/
//Added by Venkat - EDGE - 92244
async function getExistingTenancySubscriptions(accountId, solution) {
    console.log('InsidegetExistingTenancySubscriptions ' + solution);
    let inputMap1 = {}
    let currentBasket = await CS.SM.getActiveBasket();
    var checkexistingsubs = false;
    inputMap1['getExistingTenancySubscriptions'] = accountId;
    //solution.schema.configurations.forEach((config)  => {
    Object.values(solution.schema.configurations).forEach((config) => {
        var changetypeattr = Object.values(config.attributes).filter(attr => {
            return attr.name === 'ChangeType'
        });
    	//Monali
            checkexistingsubs = true;
        //if (changetypeattr && changetypeattr.length > 0 && (changetypeattr[0].value === 'New' || changetypeattr[0].value === 'Modify') && config.id === null) {
       //     checkexistingsubs = true;
       // }
    });
    if (checkexistingsubs) {
        //CS.SM.WebService.performRemoteAction('SolutionActionHelper',inputMap1).then(result => {
        await currentBasket.performRemoteAction('SolutionActionHelper', inputMap1).then(result => {
            console.log('getExistingTenancySubscriptions finished with response: ', result);
            var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptions"]);
            console.log('getExistingTenancySubscriptions: ', existingsubscriptions);
            if (existingsubscriptions != null && existingsubscriptions !== '') {
                var boo = window.confirm('This account has existing Active MDM Tenancy Subscription(s). Existing Tenancy Id(s) :' + existingsubscriptions + '.Do you want to proceed adding new Tenancies?');
                if (boo !== true)
                    CS.SM.deleteSolution(solution.id);
            }
        });
    }
    return Promise.resolve(true);
}
//Added by Monali - DPG - 2168
async function getExistingTenancySubscriptionsForBilling(billingAccount) {
//async function getExistingTenancySubscriptionsForBilling(billingAccount,componentName,guid) {
    console.log('getExistingTenancySubscriptionsForBilling ' + billingAccount);
    //let updateMap =  new Map();
    //let componentMapNew =   new Map();
	//let component = await solution.getComponentByName(componentName); //PD
    //let config = await component.getConfiguration(guid);//PD 
    let inputMap1 = {}
    let currentBasket = await CS.SM.getActiveBasket();
    var checkexistingsubs = false;
    inputMap1['getExistingTenancySubscriptionsForBilling'] = billingAccount;
    //CS.SM.WebService.performRemoteAction('SolutionActionHelper',inputMap1).then(result => {
    await currentBasket.performRemoteAction('SolutionActionHelper', inputMap1).then(result => {
   		console.log('getExistingTenancySubscriptionsForBilling finished with response: ', result);
        var existingsubscriptions = JSON.parse(result["getExistingTenancySubscriptionsForBilling"]);
        console.log('getExistingTenancySubscriptionsForBilling: ', existingsubscriptions);
        if (existingsubscriptions != null && existingsubscriptions !== '') {
        	var boo = window.confirm('There are existing MDM tenancies on the customer billing account. Existing Tenancy Id(s) :' + existingsubscriptions + '.Do you want to proceed adding new Tenancies?');
            //if (boo !== true)
            //	CS.SM.deleteSolution(solution.id);
            //config.status = false;
			//config.statusMessage = 'There are existing MDM tenancies on the customer billing account.';
            }
         else
            {
				//config.status = true;
                //config.statusMessage = '';                                                             
            }
            //if(componentMapNew && componentMapNew.size>0){
			//									updateMap.set(guid,componentMapNew);
			//									CommonUtills.UpdateValueForSolution(componentName,updateMap)
			//								}
        });
    return Promise.resolve(true);
}
/*
    User Story : EDGE-119832
    Developer Name : Maq
    Desc : Changes made for MDM Tenancy
    */
async function TenancyPlugin_handleIframeMessage(e) {
    console.log('Inside TenancyPlugin_handleIframeMessage');
    if (e.data && e.data['command'] && e.data['command'] === 'AddLegacyTenancy' && (e.data['caller'] && e.data['caller'] === 'MDMTenancy')) {
        // alert('****Im Inside Button setting'+JSON.stringify( e['data']));
        var TenancyList = new Array();
        let currentSolution = await CS.SM.getActiveSolution();
        if (tenancyAPIdone == false) {
            let payloadResponse = JSON.parse(e.data['data']);
            // alert('****Im Inside Button setting'+payloadResponse[0].name); 
            var updateMap = [];
            for (var i = 0; i < payloadResponse.length; i++) {
                var tenancyRecord = payloadResponse[i];
                TenancyList.push(tenancyRecord.id);
                updateMap.push([{
                        name: 'Tenancy Id',
                        value: tenancyRecord.id,
                        displayValue: tenancyRecord.id
                        // Spring 20 changes Start Here 
                        /*value: {
                            value: tenancyRecord.id,
                            displayValue: tenancyRecord.id
                        }*/
                        // Spring 20 changes End Here 
                    },
                    {
                        name: 'Vendor Name',
                        // Spring 20 changes Start Here 
                        value: tenancyRecord.name,
                        displayValue: tenancyRecord.name
                        /*value: {
                            value: tenancyRecord.name,
                            displayValue: tenancyRecord.name
                        }*/
                        // Spring 20 changes End Here 
                    },
                    {
                        name: 'ChangeType',
                        // Spring 20 changes Start Here 
                        value: 'transition',
                        displayValue: 'transition'
                        /*value: {
                            value: 'transition',
                            displayValue: 'transition'
                        }*/
                        // Spring 20 changes End Here 
                    }
                ]);
            }
            //await CS.SM.getActiveSolution().then((currentSolution) => {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                Object.values(currentSolution.components).forEach((comp) => {
                    //currentSolution.components.forEach((comp) => {
                    // alert(JSON.stringify(comp.name)+"<----addConfigurations:--> "+ JSON.stringify(comp.type));
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        Object.values(comp.schema.configurations).forEach((config) => {
                            //comp.schema.configurations.forEach((config) => {
                            if (config.attributes && Object.values(config.attributes).length > 0) {
                                Object.values(config.attributes).forEach((attribute) => {
                                    //config.attributes.forEach((attribute) => {
                                    /*
                                    if (attribute.name === "Vendor Name" && attribute.value)
                                    alert(JSON.stringify(attribute.name) + "<----attribute.value:--> " + JSON.stringify(attribute.value)); */
                                    if (attribute.name === "Tenancy Id" && attribute.value) {
                                        // alert(JSON.stringify(attribute.name) + "<----Tenancy Id:--> " + JSON.stringify(attribute.value)); 
                                        if (TenancyList.includes(attribute.value)) {
                                            tenancyAPIdone = true;
                                            // alert(JSON.stringify(attribute.name) + "<----Tenancy Id:--> " + JSON.stringify(attribute.value) + '-----' + comp.schema.configurations.length ); 
                                        }
                                    }
                                });
                            }
                        });
                    }
                });
            } //});
            //alert('****Im Inside Button setting' + JSON.stringify(updateMap));
            if (tenancyAPIdone === false && TenancyList.length > 0) {
                //CS.SM.getActiveSolution().then((product) => {
                if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                    //product.components.forEach((comp) => {
                    Object.values(currentSolution.components).forEach((comp) => {
                        if (comp.name == "Platform") {
                            tenancyAPIdone = true;
                            CS.SM.addConfigurations(comp.name, updateMap).then((component) => {
                                // alert("addConfigurations: ", JSON.stringify(component));
                            });
                        }
                    });
                }
                /*}).
                then(
                    () => Promise.resolve(true)
                ).than(CS.SM.displayMessage('Legacy Tenancy Services added successfully', 'success')).catch(CS.SM.displayMessage('Error has occurred', 'error'));*/
                Promise.resolve(true).then(CS.SM.displayMessage('Legacy Tenancy Services added successfully', 'success')).catch(CS.SM.displayMessage('Error has occurred', 'error'));
            } else {
                if (TenancyList.length == 0)
                    CS.SM.displayMessage('No Legacy Tenancy Services Available', 'error');
                else
                    CS.SM.displayMessage('Legacy Tenancy Services already added', 'error');
            }
        } else {
            CS.SM.displayMessage('Legacy Tenancy Services already added', 'error');
        }
    }
    return Promise.resolve(true);
}
async function populateRateCardinAttachmentTenancy() {
    var c = 0;
    console.log(' Inside populateRateCardinAttachment!!!! ');
    // CS.SM.getActiveSolution();	
    if (basketStage !== 'Contract Accepted')
        return;
    var configMap = [];
    let currentBasket = await CS.SM.getActiveBasket();
    let currentSolution = await CS.SM.getActiveSolution();
    //CS.SM.getActiveSolution().then((currentSolution) => {
    //if(valid){
    //populatefixedvoiceratecard ();
    //valid = false;
    console.log('populateRateCardinAttachment ', currentSolution);
    //if (currentSolution.type && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
    if (currentSolution.componentType && currentSolution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        //if (currentSolution.components && currentSolution.components.length > 0) {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            let currentComponent = Object.values(currentSolution.components);
            //currentSolution.components.forEach((comp) => {
            for (var i = 0; i < currentComponent.length; i++) {
                comp = currentComponent[i];
                if (comp.name === TENANCY_COMPONENT_NAMES.tenancy) {
                    if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        let inputMap = {};
                        inputMap['basketid'] = basketId;
                        inputMap['Offer_Id__c'] = 'DMCAT_Offer_000681';
                        inputMap['SolutionId'] = currentSolution.id;
                        await currentBasket.performRemoteAction('TierRateCardNCSHelper', inputMap).then(
                            function (response) {
                                if (response && response['UCRateCard'] != undefined) {
                                    console.log('UCRateCard', response['UCRateCard']);
                                }
                            });
                    }
                }
            } //});
        }
        //}
    }
    //});
    return Promise.resolve(true);
}
/* 	
	Added as part of EDGE-149887 
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_TMDM() {
	var listOfAttributes = ['Solution Name','Marketable Offer','GUID'], attrValuesMap = {};
	attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,TENANCY_COMPONENT_NAMES.solution);
	console.log('attrValuesMap...'+attrValuesMap);
	if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_TMDM){
        let updateConfigMap = {};
        // Spring 20 changes Start Here 
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(TENANCY_COMPONENT_NAMES.solution);
		/*updateConfigMap[attrValuesMap['GUID']] = [{
			name: 'Solution Name',
			value: {
				value: attrValuesMap['Marketable Offer'],
				displayValue: attrValuesMap['Marketable Offer']
			}													
        }];*/
        updateConfigMap[attrValuesMap['GUID']] = [];
        updateConfigMap[attrValuesMap['GUID']].push({
            name: 'Solution Name',
            value: attrValuesMap['Marketable Offer'],
			displayValue: attrValuesMap['Marketable Offer']
        });
      //  if(updateConfigMap){
        //    CS.SM.updateConfigurationAttribute(TENANCY_COMPONENT_NAMES.solution, updateConfigMap, true);	
        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
            keys = Object.keys(updateConfigMap);
            for (let i = 0; i < keys.length; i++) {
                component.updateConfigurationAttribute(keys[i],updateConfigMap[keys[i]],true);
            }
        }    
    }
    //}		
    // Spring 20 changes End Here 
}/*Commented by shresth
//krunal
function processMessagesFromIFrame() {
		if (!communitySiteId) {
			return;
		}
		var data = sessionStorage.getItem("payload");
		var close = sessionStorage.getItem("close");
		var message = {};
		if (data) {
            console.log('processMessagesFromIFrame:', data);
			message['data'] = JSON.parse(data);
             handleIframeMessage(message);
		}
		if (close) {
			message['data'] = close;
             handleIframeMessage(message);
		}
	}
	async function handleIframeMessage(e) {
		console.log('handleIframeMessage from pricing:', e);
		var message = {};
		message = e['data'];
		message = message['data'];
		///console.log('----->'+ e.data['data']);
		console.log(e.data['data']);
		console.log(e.data['command']);
		console.log(e.data['caller']);
		console.log('solutionID-->' + solutionID);
		if (e.data && e.data['caller'] && e.data['command']) {
			if (e.data['command'] === 'pageLoad' + callerName_TMDM && e.data['data'] === solutionID) {
				await pricingUtils.postMessageToPricing(callerName_TMDM, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded)
			} else if (e.data['command'] === 'showPromo' && e.data['data'] === configId) {
				await pricingUtils.postMessageToshowPromo(e.data['caller'], configId, "viewDiscounts");
			}
			else {
				await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller'], e.data['IsDiscountCheckAttr']);
			}
		}
        //await Utils.updateCustomAttributeLinkText('Promotions and Discounts','View All');// Added as part of Edge-123593 by ankit
		//await Utils.updateCustomAttributeLinkText('Price Schedule','View All');// Added as part of Edge-123593 by ankit
	}
//krunal
*/	
