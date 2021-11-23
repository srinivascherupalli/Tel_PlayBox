/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	Author 			                Date
1 			Laxmi Rahate & Aditya Prateek 	28-August-19
2           Venkata Ramanan G               06-Sept-2019   //Hiding the OOTB Add configuration & OOTB OE Console
3           Aditya Pareek                   09-August-19  // Method to blank the related lookup attribute
4           Venkata Ramanan G               11-Sept-2019  //Prevent save when Fibre availability is chosen Unavailable,
                                                            Prevent save Without Providing data in OE during Contract Accepted stage,
                                                            Prevent save by adding validations around OE CRD Dates,
                                                            Prevent adding Site On sites where commercial configuration is not allowed.
5			Laxmi Rahate					13-Sep-2019		Removed validation for 'Projectcontactid' and  'AfterHourscontactid'	as these are not mandatory	
6           Aman Soni			            14-Oct-2019      UI Changes for Bandwidth Downgrade Charge EDGE-113810 ||EDGE-113848							
7 			Aman Soni			            30-Oct-2019      TID Cancellation Journey || EDGE-105060
8			Laxmi Rahate		            11-Dec-2019	     Fix for PRM URL - changed methodname from TIDPlugin.processMessagesFromIFrame: to TIDPlugin_processMessagesFromIFrame:
9           Laxmi Rahate		            10-Dec-2019	     CRD and Feasibility Date Validations  EDGE-100709
10          Sandip Deshmane                 9/1/2020         EDGE-109355 Added code for TID Bandwidth Downgrade Waiver.
11          Pooja                           02-Jul-2020      EDGE-154489 Refactoring Offer_Managed Services for JS File
12.         Antun Bartonicek                01/06/2021       EDGE-198536: Performance improvements
 ********************/

var tidCommunitySiteId;
var cidn;
var TID_COMPONENT_NAMES = {
    solution: 'Internet',
    internetSite: 'Internet Site',
    InternetSiteDeviceEditableAttributeList: ['SelectZone', 'ServiceabilityLocation', 'FibreAvailabilityStatus', 'Bandwidth', 'AccessTechnology', 'IPAccessConfiguration', 'RemainingTerm', 'Contract Term'] //Added by Aman Soni as a part of EDGE-105060
};

var zonePatternID = "";
var executeSaveTID = false;
var TID_existingSiteIds = [];
var saveTID = false;
var basketStage = null;
var crdoeschemaid = null;
var bandwidthDownGradeChrg = 0;
var opptyId = null;
var notBeforeCRD = '';
var preferredCRD = '';
var basketChangeType = '';
var notBeforeCRDValidation = new Date();

notBeforeCRDValidation.setHours(0, 0, 0, 0);
notBeforeCRDValidation.setDate(notBeforeCRDValidation.getDate() + parseInt(30));


var targetMonth = parseInt(notBeforeCRDValidation.getMonth()) + parseInt(1);
console.log('Validation for Not Before CRD for TID ----------' + notBeforeCRDValidation + ' Month-----------' + targetMonth);
var month = targetMonth;
var date = notBeforeCRDValidation.getDate();

if (targetMonth < 10) {
    month = '0' + targetMonth;
}
if (date < 10) {
    date = '0' + date;
}
var formattedDate = notBeforeCRDValidation.getFullYear() + '-' + month + '-' + date;



// EDGE-154495 Register Plugin Spring 20 changes starts here
if (CS.SM.registerPlugin) {
    console.log('Load TID plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () {
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('Internet')
            .then(async TIDPlugin => {
                // For Hooks
                TIDPlugin_updatePlugin(TIDPlugin);
            });
    });
}

//if (CS.SM.createPlugin) {
//console.log('Load TID plugin');
//TIDPlugin = CS.SM.createPlugin('Internet');
async function TIDPlugin_updatePlugin(TIDPlugin) {
    //EDGE-198536 removed duplicate listener logic for active solution, logic moved to window.document.addEventListener('SolutionSetActive' block
    //Changes as part of EDGE-154495 start
    //TIDPlugin.beforeSave = function (solution, configurationsProcessed, saveOnlyAttachment) {
    TIDPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        //Changes as part of EDGE-154495 start
        if (saveTID) {
            saveTID = false;
            console.log('beforeSave - exiting true');
            return Promise.resolve(true);
        }
        executeSaveTID = true;
        return Promise.resolve(true);
    }

    //Changes as part of EDGE-154495 start
    //TIDPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment) {
    TIDPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        //Changes as part of EDGE-154495 end
        console.log('afterSave - entering');
        canExecuteValidation = true;
        Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
        Utils.updateOEConsoleButtonVisibility();
        await tidcheckConfigurationSubscriptions();
        Utils.updateCustomButtonVisibilityForBasketStage();

        if (basketChangeType === 'Change Solution') {
            console.log('afterSave - entering modify');
            TIDPlugin.UpdateAttributesForMacdOnSolutionTID(solution);//Added by Aman Soni as a part of EDGE-105060
        }
        TIDPlugin.updateChangeTypeAttributeTID(solution);//Added by Aman Soni as a part of EDGE-113848
        TIDPlugin.setOETabsVisibility();
        TIDPlugin.UpdateMainSolutionChangeTypeVisibility(solution);//Added by Aman Soni as a part of EDGE-105060
        showDowngradeBandwidthChargeOnAttSave();//Added by Aman Soni as a part of EDGE-113848
        hideDowngradeBandwidthCharge(solution);//Added by Aman Soni as a part of EDGE-105060
        //EDGE-135267		
        Utils.hideSubmitSolutionFromOverviewTab();
        await Utils.updateActiveSolutionTotals();//Added as part of EDGE-154495
        return Promise.resolve(true);
    }

    //TIDPlugin.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {//EDGE-154495
    TIDPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {//EDGE-154495
        console.log('TID afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration)//EDGE-154495
        initializeTIDOEConfigs();
        //window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);//EDGE-154495
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);//EDGE-154495
        return Promise.resolve(true);
    }

    //Added by Aman Soni
    //TIDPlugin.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {
    TIDPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {//EDGE-154495
        //window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);//EDGE-154495
        return Promise.resolve(true);
    };

    //Moved this code to UIPlugin as part of EDGE-154495
    /*TIDPlugin.buttonClickHandler = async function (buttonSettings) {//EDGE-154495- This method moved to UI Plugin js
        console.log('buttonClickHandler: id=', buttonSettings.id, buttonSettings);
        var url = '';
        var redirectURI = '/apex/';
        //Added check below to address URL issue for PRM User
        if (tidCommunitySiteId) {
            url = window.location.href;
            if (url.includes('partners.enterprise.telstra.com.au'))
                redirectURI = '/s/sfdcpage/%2Fapex%2F';
            else
                redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
        }
        url = redirectURI;
    
        if (buttonSettings.id === 'ScSelectSiteAddressBtnTID') {
            if (Utils.isCommNegotiationAllowed()) {
                var arrStr = '';
                if (TID_existingSiteIds && TID_existingSiteIds.length > 0) {
                    arrStr = TID_existingSiteIds.map(e => e.adborID).join();
                }
    
                var offerIdValue = await TIDPlugin.getOfferIdValue();
                console.log('basketId', basketId);
                console.log('TID_existingSiteIds', arrStr);
                console.log('offerIdValue', offerIdValue);
    
                if (tidCommunitySiteId) {
                    url = url + encodeURIComponent('c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&caller=' + TID_COMPONENT_NAMES.solution + '&offerId=' + offerIdValue);
                } else {
                    url = url + 'c__SCAddressSearchPage?basketId=' + basketId + '&adborIds=' + arrStr + '&caller=' + TID_COMPONENT_NAMES.solution + '&offerId=' + offerIdValue;
                }
                console.log('url: ', url);
                return Promise.resolve(url);
            } else {
                CS.SM.displayMessage('Can not add site when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        }
        else if (buttonSettings.id === 'orderEnrichment') {
            if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
                setTimeout(createOEUI, 200);
                return Promise.resolve('null');
            } else {
                CS.SM.displayMessage('Can not do order enrichment when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        }
    }*/


    //Changes as part of EDGE-154495 start
    //TIDPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(componentName, configuration) {
    TIDPlugin.afterConfigurationAdd = async function _solutionAfterConfigurationAdd(component, configuration) {
        //console.log('afterConfigurationAdd', componentName, configuration);
        console.log('afterConfigurationAdd', component, configuration);
        //if (componentName === TID_COMPONENT_NAMES.internetSite) { 
        if (component.name === TID_COMPONENT_NAMES.internetSite) {//Changes as part of EDGE-154495 end 
            TIDPlugin.getConfiguredSiteIds();
        }
        addDefaultTIDOEConfigs();
        return Promise.resolve(true);
    }

    //TIDPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, configuration) {
    TIDPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, configurationGuid) {
        console.log('afterConfigurationAdd---', componentName, configurationGuid);
        let currentSolution = await CS.SM.getActiveSolution();
        //let configuration = currentSolution.getConfiguration(configurationGuid);
        let component = currentSolution.getComponentByName(TID_COMPONENT_NAMES.internetSite);
        let updatemap = {};
        if (componentName === TID_COMPONENT_NAMES.internetSite) {
            //EDGE-154495 Spring20 changes starts here
            //var updatemap = [];

            /*updatemap[configuration] = [{
                name: "ChangeType",
                value: {
                    options: [
                        {
                            "value": "Modify",
                            "label": "Modify"
                        },
                        {
                            "value": "Cancel",
                            "label": "Cancel"
                        }],
                    showInUi: true,
                    required: true
                },
                name: "OpptyId",
                value: {
                    value: opptyId,
                    displayValue: opptyId
                },
            name: "AccessTechnology",
            value: {
                options: [{
                        "value": "Direct Fibre over NBN",
                        "label": "Direct Fibre over NBN"
                    },
                    {
                        "value": "Telstra Fibre Access",
                        "label": "Telstra Fibre Access"
                    }
                ]

            }
            }];*/
            
            updatemap[configurationGuid] = [];
            updatemap[configurationGuid].push({//check this
                name: "ChangeType",
                options: (
                    {
                        "value": "Modify",
                        "label": "Modify"
                    },
                    {
                        "value": "Cancel",
                        "label": "Cancel"
                    }),
                showInUi: true,
                required: true
            },
                {
                    name: 'OpptyId',
                    value: opptyId,
                    displayValue: opptyId
                },

                {
                    name: "AccessTechnology",
                    options: ({
                        "value": "Direct Fibre over NBN",
                        "label": "Direct Fibre over NBN"
                    },
                    {
                        "value": "Telstra Fibre Access",
                        "label": "Telstra Fibre Access"
                    })

                }


            );
        }
        //CS.SM.updateConfigurationAttribute(componentName, updatemap, true);
        if (updatemap && Object.keys(updatemap).length > 0) {
            keys = Object.keys(updatemap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updatemap[keys[i]], true);
            }
        }
        //EDGE-154495 Spring20 changes ends here
        changetypemodify(configurationGuid);
        //changetypemodify(configurationGuid);
        updateRemainingTermAfterSolutionLoadTID();
        //Added by Aman Soni || EDGE-105060 || Start
        if (basketChangeType === 'Change Solution') {
            SetAttributeReadOnlyForActiveState();
        }
        //Added by Aman Soni || EDGE-105060 || End
        return Promise.resolve(true);
    }

    //EDGE-154495 Spring20 changes starts here
    //TIDPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {//EDGE-154495
    TIDPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {//EDGE-154495
        //console.log('Attribute Update - After - OE ---', componentName, guid, attribute, 'oldValue:', oldValue, 'newValue:', newValue);//EDGE-154495
        console.log('Attribute Update - After - OE ---', component.name, configuration.guid, attribute, 'oldValue:', oldValueMap.value, 'newValue:', attribute.value);//EDGE-154495
        if (basketStage === 'Contract Accepted')
            //window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);//EDGE-154495
            //component.lock('Commercial', false);
            window.afterAttributeUpdatedOE(component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);//EDGE-154495

        //Aditya
        //if ((componentName === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'SelectZone'))) {//EDGE-154495
        if ((component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'SelectZone'))) {//EDGE-154495
            if (attribute.value === '')
                //emptyLookupAttributesTID(componentName, guid, attribute.name);
                emptyLookupAttributesTID(component.name, configuration.guid, attribute.name);
        }//Aditya

        //Modified by Aman Soni as part of EDGE-113848
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'ChangeType' && attribute.value === 'Modify') {//EDGE-154495
            console.log(' Change  type is changed to Modify !!!!!!!!!!!----------');
            //console.log('oldValue:----inside modify',oldValue,'newValue:---inside modify', newValue);
            changetypemodify(configuration.guid);//EDGE-154495 //Added await by Pooja
            updateRemainingTermAfterSolutionLoadTID();
            showDowngradeBandwidthChargeOnAttSave();//Added await by Pooja
            //console.log('on attribute update inside modify');
        }

        //Added by Aman Soni as a part of EDGE-98299 || Start
        if ((component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'AccessTechnology'))) {//EDGE-154495
            if (attribute.value === '')
                emptyZoneAttributesTID(component.name, configuration.guid, attribute.name);//EDGE-154495
        }
        //Added by Aman Soni as a part of EDGE-98299 || End

        //Added by Aman Soni as a part of EDGE-105060 || Start
        //if ((componentName === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'ChangeType')) && oldValue == 'Modify' && newValue === 'Cancel' && oldValue !== newValue) {
        if ((component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'ChangeType')) && oldValueMap.value == 'Modify' && attribute.value === 'Cancel' && oldValueMap.value !== attribute.value) {
            //refreshCancelAttributesTID(componentName, guid, attribute.name);
            refreshCancelAttributesTID(component.name, configuration.guid, attribute.name);

        }//Added by Aman Soni as a part of EDGE-105060 || End

        //if (componentName === TID_COMPONENT_NAMES.internetSite && attribute.name === 'Widefeas Code' && attribute.showInUi) {
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'Widefeas Code' && attribute.showInUi) {
            //validateWFCodeFormat(guid, newValue, attribute.required, componentName);
            validateWFCodeFormat(configuration.guid, attribute.value, attribute.required, component.name);//Added await by Pooja
            console.log('***126');
        }

        // Modified by Laxmi as part of - EDGE-100709
        if (component.name === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && attribute.value !== 0) {//EDGE-154495
            //Utils.markOEConfigurationInvalid(config.guid, 'Not Before CRD must be greater than today');
            notBeforeCRD = new Date(attribute.value).setHours(0, 0, 0, 0);//EDGE-154495
            //console.log ('***************notBeforeCRD------ date --'+notBeforeCRD.getDate() + ' Month ' + notBeforeCRD.getMonth()+ 'Year --' + notBeforeCRD.getFullYear() );
            if (notBeforeCRD <= notBeforeCRDValidation) {
                CS.SM.displayMessage('Not Before CRD date should be greater than- ' + formattedDate, 'error');

            }
            // CS.SM.updateConfigurationStatus(componentName,guid,false,'Not Before CRD date should be greater than- ' + formattedDate );
        }

        if (component.name === 'Customer requested Dates' && attribute.name === 'Preferred CRD') {//EDGE-154495
            //console.log (' value of Preferred CRD is -----**********************'+ newValue );
            preferredCRD = new Date(attribute.value).setHours(0, 0, 0, 0);//EDGE-154495
            // console.log ( 'preferredCRD ****************'+preferredCRD  + '&&&&&&&&&&&' + 'notBeforeCRD**************'+ notBeforeCRD); 

        }

        if (component.name === 'Customer requested Dates' && attribute.name === 'Preferred CRD' && attribute.value !== 0) {//EDGE-154495

            console.log('*************Preferred CRD is Updated now -------------' + attribute.value);//EDGE-154495
            preferredCRD = new Date(attribute.value).setHours(0, 0, 0, 0);//EDGE-154495
            if (notBeforeCRD === '') {
                notBeforeCRD = Utils.getAttributeValue('Not Before CRD', configuration.guid);//EDGE-154495
            }
            //console.log ( 'preferredCRD ****************'+preferredCRD  + '&&&&&&&&&&&' + 'notBeforeCRD**************'+ notBeforeCRD); 
            if (preferredCRD < notBeforeCRD) {
                //Utils.markOEConfigurationInvalid(config.guid, 'Not Before CRD must be greater than today');
                CS.SM.displayMessage('Preferred CRD date can not be less than  Not Before CRD!', 'error');
                //CS.SM.updateConfigurationStatus(componentName,guid,false,'Preferred CRD date can not be less than Not Before CRD - ^^^^^message from Attribute Update' );
            }
        }

        //Added by Aman Soni as part of EDGE-113848
        //if (componentName === TID_COMPONENT_NAMES.internetSite && attribute.name === 'BandwidthWeight' && oldValue !== newValue && newValue !== '' && newValue !== null) {
        //showDowngradeBandwidthChargeOnAttUpdate(guid, oldValue, newValue);
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'BandwidthWeight' && oldValueMap.value !== attribute.value && attribute.value !== '' && attribute.value !== null) {//EDGE-154495
            showDowngradeBandwidthChargeOnAttUpdate(configuration.guid, oldValueMap.value, attribute.value);//EDGE-154495 //Added await by Pooja
            console.log('Inside Modify Update');
        }
        //added by Sandip Deshmane as part of EDGE-109355
        if (component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'ETCWaiver' || attribute.name === 'CaseNumber')) {//EDGE-154495
            showDowngradeBandwidthChargeOnAttUpdate(configuration.guid, oldValueMap.value, attribute.value);//EDGE-154495 //Added await by Pooja
        }
        //Added by Aman Soni as part of EDGE-105060
        /*if (componentName === TID_COMPONENT_NAMES.internetSite && attribute.name === 'DisconnectionDate') {
            TIDPlugin.validateDisconnectionDate(componentName, guid, newValue);*/
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'DisconnectionDate') {//EDGE-154495
            TIDPlugin.validateDisconnectionDate(component.name, configuration.guid, attribute.value);//EDGE-154495
        }

        //Added by Aman Soni as a part of EDGE-105060
        //if (componentName === TID_COMPONENT_NAMES.internetSite && attribute.name === 'ChangeType') {
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'ChangeType') {//EDGE-154495
            hideDowngradeBandwidthCharge();//Added await by Pooja
        }

        //Added by Aman Soni as part of EDGE-105060
        /*if (componentName === TID_COMPONENT_NAMES.internetSite && basketChangeType === 'Change Solution' && attribute.name === 'ChangeType' && newValue === 'Cancel') {
            console.log('oldValue:', oldValue, 'newValue:', newValue, 'attribute.value:', attribute.value);
            TIDPlugin.UpdateAttributeVisibilityForMacdTID(componentName, guid, newValue);
        }*/

        if (component.name === TID_COMPONENT_NAMES.internetSite && basketChangeType === 'Change Solution' && attribute.name === 'ChangeType' && attribute.value === 'Cancel') {//EDGE-154495
            console.log('oldValue:', oldValueMap.value, 'newValue:', attribute.value, 'attribute.value:', attribute);
            TIDPlugin.UpdateAttributeVisibilityForMacdTID(component.name, configuration.guid, attribute.value);//EDGE-154495
        }

        //Added by Sandip Deshmane as part of EDGE-111053
        /*if (componentName === TID_COMPONENT_NAMES.internetSite && basketChangeType === 'Change Solution' && attribute.name === 'ChangeType' && newValue === 'Cancel') {
            updateEtcVisibility(guid);
        }*/

        if (component.name === TID_COMPONENT_NAMES.internetSite && basketChangeType === 'Change Solution' && attribute.name === 'ChangeType' && attribute.value === 'Cancel') {//EDGE-154495
            updateEtcVisibility(configuration.guid);//EDGE-154495 
        }

        //Added by Sandip Deshmane as part of EDGE-111053
        /*if (componentName === TID_COMPONENT_NAMES.internetSite && attribute.name === 'DisconnectionDate') {
            TIDPlugin.calculateTotalETCValue(guid);
        }*/

        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'DisconnectionDate') {//EDGE-154495
            await TIDPlugin.calculateTotalETCValue(configuration.guid);//EDGE-154495 //added await
        }
        //Added by Sandip Deshmane as part of EDGE-111053
        /*if (componentName === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'ETCWaiver' || attribute.name === 'CaseNumber')) {
            TIDPlugin.calculateTotalETCValue(guid);
        }*/

        if (component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'ETCWaiver' || attribute.name === 'CaseNumber')) {//EDGE-154495
            await TIDPlugin.calculateTotalETCValue(configuration.guid);//EDGE-154495 //added await
        }


        //Added by laxmi as part of EDGE-98299
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'AccessTechnology' && oldValueMap.value !== attribute.value && attribute.value !== '' && attribute.value !== null) {//EDGE-154495
            console.log(' Inside the AccessTechnology Attribute Update');
            invokeMicroService(configuration.guid);//EDGE-154495 //Added await by Pooja
        }

        //Added by laxmi as part of EDGE-100709
        if (component.name === TID_COMPONENT_NAMES.internetSite && attribute.name === 'FeasibilityExpiryDate') {//EDGE-154495
            console.log(' Inside the FeasibilityExpiryDate Attribute Update');
            validateFeasibilityDate(configuration.guid);//EDGE-154495 
        }
        //Added by Venkat 
        if (component.name === TID_COMPONENT_NAMES.internetSite && (attribute.name === 'AccessTechnology') && attribute.value !== '' && attribute.value !== 'Direct Fibre over NBN') {//EDGE-154495//check this

            defaultContracttermTID(component.name, configuration.guid, attribute.name);//EDGE-154495 
        }

        //EDGE-154495 Spring20 changes ends here

        return Promise.resolve(true);
    }

    /**
     * Author      : Antun Bartonicek 2019-08-30
     * Ticket      : EDGE-108959
     * Migrated from ConnectedWorkplace plugin.
     */
    //EDGE-154495 Spring 20 changes start here
    addIpSites = async function (siteData) {//made the function async
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution();
        //let component = await product.getComponentByName(TID_COMPONENT_NAMES.internetSite);
        console.log('TIDPlugin.addIpSite', product);
        if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product EDGE-154495
            if (product.components && Object.values(product.components).length > 0) {//EDGE-154495
                console.log('Components: ', product.components);
                Object.values(product.components).forEach((comp) => {//EDGE-154495
                    if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                        let updateMap = [];//EDGE-154495
                        //var updateMap = {};//EDGE-154495
                        for (var i = 0; i < siteData.length; i++) {
                            var sd = siteData[i];

                            ////EDGE-154495 changes start here
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
                            },
                            {
                                name: 'OpptyId',
                                value: {
                                    value: opptyId,
                                    displayValue: opptyId
                                }
                            }
                            ]);
                        }
                        //CS.SM.addConfigurations(comp.name, updateMap).then((component) => {
                        for (let p = 0; p < updateMap.length; p++) {
                            let configuration = comp.createConfiguration(updateMap[p]);
                            comp.addConfiguration(configuration);
                        }
                        //console.log("addConfigurations: ", component);
                        //});
                    }
                });
            }
        }
        //}).then(
        //() => Promise.resolve(true)
        // );
        return Promise.resolve(true);
        //EDGE-154495 changes end here

    }

    /**
     * Author      : Antun Bartonicek 2019-08-30
     * Ticket      : EDGE-108959
     * Migrated from ConnectedWorkplace plugin.
     */
    //Changes as part of EDGE-154495 start
    //TIDPlugin.updateIpSite = async function (siteData) {//made the function async
    updateIpSite = async function (siteData) {
        //var updateMap = [];
        var sd = siteData[0];
        //Changes as part of EDGE-154495 end
        let updateMap = {};
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.internetSite);
        //Changes as part of EDGE-154495 start
        /*updateMap[sd.ipSiteconfigId] = [{
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
        ];*/

        updateMap[sd.ipSiteconfigId] = [];
        updateMap[sd.ipSiteconfigId].push({
            name: 'Site Name',
            value: sd.siteName,
            displayValue: sd.siteName
        },
            {
                name: 'Site Address',
                value: sd.siteAddress,
                displayValue: sd.siteAddress
            },
            {
                name: 'Site ID',
                value: sd.siteId
            },
            {
                name: 'AdborID',
                value: sd.adborID
            },
            {
                name: 'NBNAvailability',
                value: sd.nbnAvailability
            },
            {
                name: 'NBNRFSDate',
                value: sd.nbnRFSDate
            },
            {
                name: 'NBNTechnologyType',
                value: sd.nbnTechnologyTypeAcrnym
            },
            {
                name: 'MaxUploadSpeed',
                value: sd.nbnMaxUploadSpeed
            },
            {
                name: 'MaxDownloadSpeed',
                value: sd.nbnMaxDownloadSpeed
            },
            {
                name: 'SQVacantCopperPairs',
                value: sd.copperPairIndicator
            },
            {
                name: 'NBNCompatibility',
                value: sd.nbnCompatibility
            },
            {
                name: 'ServiceabilityClass',
                value: sd.nbnServiceabilityClass
            });

        //CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.internetSite, updateMap, true).then(component => {

        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
        //Changes as part of EDGE-154495 end
        console.log('TIDPlugin.updateIpSite ', component);
        TIDPlugin.getConfiguredSiteIds();
        TID_updateConfigurationsName();

        return Promise.resolve(true);//Pooja
    }




    /**
     * Author      : Antun Bartonicek 2019-08-30
     * Ticket      : EDGE-108959
     * Migrated from ConnectedWorkplace plugin.
     */

    TIDPlugin.getConfiguredSiteIds = async function () {//Made the function async- EDGE-154495
        TID_existingSiteIds.length = 0;
        //CS.SM.getActiveSolution().then((currentSolution) => {//EDGE-154495--
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154495
        if (currentSolution && currentSolution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution //EDGE-154495
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154495
                Object.values(currentSolution.components).forEach((comp) => {//EDGE-154495
                    if (comp.name === TID_COMPONENT_NAMES.internetSite) {//EDGE-154495
                        TID_existingSiteIds.length = 0;
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                            Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                                console.log('config: ', config);
                                var entry = {
                                    siteId: '',
                                    configId: config.id,
                                    guid: config.guid,
                                    adborID: ''
                                };
                                Object.values(config.attributes).forEach((attribute) => {//EDGE-154495
                                    if (attribute.name === "Site ID" && attribute.value) {
                                        entry.siteId = attribute.value;
                                        console.log('Site ID: ', attribute.value);
                                    }
                                    if (attribute.name === "AdborID" && attribute.value) {
                                        entry.adborID = attribute.value;
                                        console.log('adborID: ', attribute.value);
                                    }
                                });
                                TID_existingSiteIds.push(entry);
                            });
                        }
                    }
                });
            }
            TIDPlugin.addrCheck();
        }
        //}).then(
        //() => Promise.resolve(true)
        //);
        return Promise.resolve(true);
    }

    /**
     * Author      : Antun Bartonicek 2019-08-30
     * Ticket      : EDGE-108959
     * Migrated from ConnectedWorkplace plugin.
     */
    TIDPlugin.addrCheck = async function () {//Made this function async- EDGE-154495 Spring 20 changes

        console.log('TIDPlugin.addrCheck called:', TID_existingSiteIds);
        if (TID_existingSiteIds.length == 0)
            return;
        var counts = [];
        var hasDuplicates = false;
        for (var i = 0; i < TID_existingSiteIds.length; i++) {
            if (counts[TID_existingSiteIds[i].adborID] != undefined) {
                counts[TID_existingSiteIds[i].adborID] = counts[TID_existingSiteIds[i].adborID] + 1;
                hasDuplicates = true;
            } else {
                counts[TID_existingSiteIds[i].adborID] = 1;
            }
        }

        console.log('hasDuplicates: ', hasDuplicates);
        //EDGE-154495 Spring 20 changes
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution();//EDGE-154495
        if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product - //EDGE-154495
            if (product.components && Object.values(product.components).length > 0) {//EDGE-154495
                Object.values(product.components).forEach((comp) => {//EDGE-154495
                    if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                            for (var j = Object.values(comp.schema.configurations).length - 1; j >= 0; j--) {//EDGE-154495
                                var config = Object.values(comp.schema.configurations)[j];//EDGE-154495
                                var valid = true;
                                var msg = config.statusMessage;
                                for (var k = 0; k < TID_existingSiteIds.length; k++) {
                                    if (counts[TID_existingSiteIds[k].adborID] != undefined && counts[TID_existingSiteIds[k].adborID] > 1) {
                                        for (var l = 0; l < Object.values(config.attributes).length; l++) {//EDGE-154495
                                            var attribute = Object.values(config.attributes)[l];//EDGE-154495
                                            if (attribute.name === "AdborID" && attribute.value && attribute.value == TID_existingSiteIds[k].adborID) {
                                                counts[TID_existingSiteIds[k].adborID] = counts[TID_existingSiteIds[k].adborID] - 1;
                                                valid = false;
                                                break;
                                            }
                                        };
                                    }
                                    if (!valid) break;
                                }
                                //msg = msg ? msg + ',\n' + 'The site address already exists. Please update the address.' : 'The site address already exists. Please update the address.'
                                //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, config.guid, valid, msg).then(configuration => console.log(configuration));
                                //updateConfigurationStatus('INTERNET_SITE_ADDRESS_CHECK',TID_COMPONENT_NAMES.internetSite, config.guid, valid, 'The site address already exists. Please update the address.');
                            }
                        }
                    }
                });
            }
        }
        //}).then(
        //() => Promise.resolve(true)
        //);
        return Promise.resolve(true);
    }

    /**
     * Author      : Antun Bartonicek 2019-08-30
     * Ticket      : EDGE-108959
     * Description : Getting offer id value from active solution, works only for TID as offer id lives directly on solution
     */

    //Moved this code to UIPlugin as part of EDGE-154495
    /*TIDPlugin.getOfferIdValue = async function () {
        var offerIdValue;
        //Changes as part of EDGE-155255 start
        //await CS.SM.getActiveSolution().then(product => {
        let product = await CS.SM.getActiveSolution();
        if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product
            if (product.schema && product.schema.configurations && Object.values(product.schema.configurations).length > 0) {//EDGE-154495
                var offerIdAttArray = Object.values(product.schema.configurations[0].attributes).filter(att => {
                    return att.name === 'OfferId'
                });
                if (offerIdAttArray && offerIdAttArray.length > 0) {
                    var offerIdAtt = offerIdAttArray[0];
                    if (offerIdAtt && offerIdAtt.value) {
                        offerIdValue = offerIdAtt.value;
                    }
                }
            }
        }
        //});//Changes as part of EDGE-155255 end
        return offerIdValue;
    }*/

    /**********************************************************************************************************************************************
     * Author	   : Aman Soni
     * Method Name : UpdateAttributesForMacdOnSolutionTID
     * Invoked When: after solution is loaded , after save
     * Description : Updates attribute visibility and readOnly value depending on ChangeType for mac basket for Internet site
     ********************************************************************************************************************************************/
    TIDPlugin.UpdateAttributesForMacdOnSolutionTID = function (solution) {
        let changeTypeAtrtribute;
        if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution -EDGE-154495
            if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes added 

                Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                            changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes
                                return obj.name === 'ChangeType'
                            });
                            console.log('changeTypeAtrtribute---', changeTypeAtrtribute[0].value);
                            if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                                TIDPlugin.UpdateAttributeVisibilityForMacdTID(comp.name, config.guid, changeTypeAtrtribute[0].value);
                                console.log('changeTypeAtrtribute111--', changeTypeAtrtribute[0].value);
                            }

                        });
                    }
                });
            }
        }

    }

    /**
     * Author      : Aman Soni 2019-11-04
     * Ticket      : EDGE-105060
     * Description : Updates attribute visibility and readOnly value depending on ChangeType for mac basket for Internet site
     */
    TIDPlugin.UpdateAttributeVisibilityForMacdTID = function (componentName, guid, changeTypeValue) {

        if (changeTypeValue === 'Cancel') {

            TIDPlugin.updateCancellationReasonTID(componentName, guid, true);

            if (componentName === TID_COMPONENT_NAMES.internetSite) {
                TIDPlugin.updateDisconnectionDate(componentName, guid, true, basketStage === 'Commercial Configuration', false);
                TIDPlugin.setAttributesReadonlyValueForConfigurationTID(componentName, guid, true, TID_COMPONENT_NAMES.InternetSiteDeviceEditableAttributeList);
                updateEtcVisibility(guid);
                console.log('TID_COMPONENT_NAMES.InternetSiteDeviceEditableAttributeList---', TID_COMPONENT_NAMES.InternetSiteDeviceEditableAttributeList);
            }
        }
        else if (changeTypeValue === 'Modify') {

            TIDPlugin.updateCancellationReasonTID(componentName, guid, false);

            if (componentName === TID_COMPONENT_NAMES.internetSite) {
                TIDPlugin.updateDisconnectionDate(componentName, guid, false, false, false);
                changetypemodify(guid);
            }
        }
        else if ((changeTypeValue === 'Active' || changeTypeValue === 'Pending') && changeTypeValue !== 'Modify' && changeTypeValue !== 'Cancel') {
            TIDPlugin.setAttributesReadonlyValueForConfigurationTID(componentName, guid, true, TID_COMPONENT_NAMES.InternetSiteDeviceEditableAttributeList);
        }
    }

    /**
     * Author      : Aman Soni 2019-10-31
     * Ticket      : EDGE-105060
     * Description : Method to show DisconnectionDate 
     */
    TIDPlugin.updateDisconnectionDate = async function (componentName, guid, isVisible, isMandatory, isReadonly) {//Made the function async - EDGE-154495 Spring 20 changes
        console.log('updateDisconnectionDate', componentName, guid, isVisible, isMandatory, isReadonly);
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154495 Spring 20 changes
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495 Spring 20 changes
        let updateMap = {};
        updateMap[guid] = [];
        updateMap[guid].push(
            {
                name: 'DisconnectionDate',
                //value: {//EDGE-154495 Spring 20 changes
                readOnly: isReadonly,
                showInUi: isVisible,
                required: isMandatory
                //} //EDGE-154495 Spring 20 changes
            });

        //Changes as part of EDGE-154495 start
        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            //Changes as part of EDGE-154495 end
        }
        return Promise.resolve(true);//Pooja

    }


    /**
     * Author      : Aman Soni 2019-10-31
     * Ticket      : EDGE-105060
     * Description : Method to show CancellationReason 
     */
    TIDPlugin.updateCancellationReasonTID = async function (componentName, guid, isVisible) {//Made the function async - EDGE-154495 Spring 20 changes
        console.log('updateCancellationReasonTID', componentName, guid, isVisible);
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154495 Spring 20 changes
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495 Spring 20 changes
        let updateMap = {};
        updateMap[guid] = [];
        updateMap[guid].push(
            {
                name: 'CancellationReason',
                //value: {EDGE-154495 Spring 20 changes
                readOnly: false,
                showInUi: isVisible,
                required: true
                // }EDGE-154495 Spring 20 changes
            });

        //Changes as part of EDGE-155255 start
        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            //Changes as part of EDGE-155255 end
        }
        return Promise.resolve(true);//Pooja
    }


    /**
     * Author      : Aman Soni 2019-10-31
     * Ticket      : EDGE-105060
     * Description : Method to update Main Solution ChangeType visibility
     */
    TIDPlugin.UpdateMainSolutionChangeTypeVisibility = async function (solution) {//Made the function async - EDGE-154495 Spring 20 changes

        if (basketChangeType !== 'Change Solution') {
            return;
        }

        //Changes as part of EDGE-155255 start
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);
        /*updateMap[solution.schema.configurations[0].guid] = [{
            name: 'ChangeType',
            value: {
                showInUi: true,
            },
            {
        name: 'Contract Term',
        value: {
            readOnly: true
        }
    }, {
        name: 'Installation Charge',
        value: {
			value: '',
            showInUi: false
        }
        }];*/

        let updateMap = {};
        updateMap[Object.values(solution.schema.configurations)[0].guid] = [];
        updateMap[Object.values(solution.schema.configurations)[0].guid].push({
            name: "ChangeType",
            showInUi: true
        },
            {
                name: 'Contract Term',
                readOnly: true
            },
            {
                name: 'Installation Charge',
                value: '',
                showInUi: false
            });

        console.log('UpdateMainSolutionChangeTypeVisibility', updateMap);
        //CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.solution, updateMap, true).catch((e) => Promise.resolve(true));
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            //Changes as part of EDGE-155255 end

        }
        return Promise.resolve(true);//Pooja
    }

    /**
     * Author      : Aman Soni 2019-10-31
     * Ticket      : EDGE-105060
     * Description : Method to make all the commercial attributes read only when ChangeType is Cancel
     */
    TIDPlugin.setAttributesReadonlyValueForConfigurationTID = async function (compName, guid, isReadOnly, attributeList) {//Made the function async - EDGE-154495 Spring 20 changes
        console.log('setAttributesReadonlyValueForConfigurationTID ', compName, guid, isReadOnly, attributeList);

        let updateMap = {};
        updateMap[guid] = [];
        //Changes as part of EDGE-155255 start
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);
        attributeList.forEach((attribute) => {
            updateMap[guid].push(
                {
                    name: attribute,
                    //value: {EDGE-154495 Spring 20 changes
                    readOnly: isReadOnly,
                    showInUi: true,
                    // }EDGE-154495 Spring 20 changes
                });
        });
        updateMap[guid].push({
            name: 'Installation Charge',
            value: '',
            showInUi: false
        });
        updateMap[guid].push({
            name: 'Widefeas Code',
            showInUi: false
        });

        updateMap[guid].push({
            name: 'FeasibilityExpiryDate',
            showInUi: false
        });

        console.log('setAttributesReadonlyValueForConfigurationTID updateMap', updateMap);
        //CS.SM.updateConfigurationAttribute(compName, updateMap, true).then((e) => console.log('setAttributesReadonlyValueForConfigurationTID: ', e));
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            //Changes as part of EDGE-155255 end
        }

        return Promise.resolve(true);
    }


    /**
                  * Author      : Aman Soni 2019-11-04
                  * Ticket      : EDGE-105060
                  * Description : Method to update ChangeType attribute
                  */
    TIDPlugin.updateChangeTypeAttributeTID = async function (solution) {//Made this async
        console.log('updateChangeTypeAttributeTID');
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495 Spring 20 changes
        // if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution
        if (solution && solution.name == TID_COMPONENT_NAMES.solution) {
            if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes
                //Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                for (const comp of Object.values(solution.components)) {
                    var updateMap = {};
                    var doUpdate = false;
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20 changes
                                Object.values(config.attributes).forEach((attribute) => {//EDGE-154495 Spring 20 changes
                                    if (attribute.name === 'ChangeType') {

                                        doUpdate = true;

                                        var changeTypeValue = attribute.value;
                                        if (!updateMap[config.guid])
                                            updateMap[config.guid] = [];

                                        console.log('changeTypeValue: ', changeTypeValue);
                                        console.log('basketChangeType: ', basketChangeType);
                                        if (!basketChangeType) {

                                            console.log('Non MACD basket');
                                            if (!changeTypeValue) {
                                                changeTypeValue = 'New';
                                            }
                                            updateMap[config.guid].push({
                                                name: attribute.name,
                                                //value: {//EDGE-154495 Spring 20 changes
                                                value: changeTypeValue,
                                                displayValue: changeTypeValue,
                                                showInUi: false,
                                                readOnly: true
                                                //}//EDGE-154495 Spring 20 changes
                                            });
                                        } else {

                                            console.log('MACD basket');

                                            var readonly = false;
                                            if (config.id && changeTypeValue === 'Cancel')
                                                readonly = true;
                                            console.log('changeTypeValue111 ', changeTypeValue);
                                            updateMap[config.guid].push({
                                                name: attribute.name,
                                                //value: {//EDGE-154495 Spring 20 changes
                                                showInUi: true,
                                                readOnly: false
                                                //}//EDGE-154495 Spring 20 changes
                                            });

                                            if ((changeTypeValue === 'Cancel') || (changeTypeValue === 'Modify')) {
                                                console.log('changeTypeValue---', changeTypeValue);
                                                updateWidefeasCodeReadonlyValueForMACDModifyTID(config.guid);
                                            }
                                        }
                                    }

                                    // Added by Aman Soni as a part of EDGE-125042 || Start
                                    if (attribute.name === 'Substatus' && attribute.value === 'Suspended') {
                                        console.log('Substatus----->');
                                        //}//EDGE-154495 Spring 20 changes start
                                        /* updateMap[config.guid] = [{
                                             name: 'ChangeType',
                                             value: {
                                                 options: ["cancel"]
                                             }
                                         }];*/

                                        updateMap[config.guid].push({
                                            name: ChangeType,
                                            options: ["cancel"]
                                        });
                                    }
                                    // Added by Aman Soni as a part of EDGE-125042 || End
                                    //}//EDGE-154495 Spring 20 changes end
                                });
                            }
                        });
                    }
                    if (doUpdate) {
                        console.log('updateChangeTypeAttributeTID', updateMap);
                        //Changes as part of EDGE-154495 start
                        //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            keys = Object.keys(updateMap);
                            for (let i = 0; i < keys.length; i++) {
                                currentComponent.lock('Commercial', false);
                                await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                //currentComponent.lock('Commercial', true);
                            }
                        }//Changes as part of EDGE-154495 end
                    }
                }//);
            }
        }
        return Promise.resolve(true);//Pooja
    }


    /**
     * Author      : Aman Soni 2019-11-04
     * Ticket      : EDGE-105060
     * Description : Method to validate disconnection date
     */
    TIDPlugin.validateDisconnectionDate = async function (componentName, guid, newValue) {//Made it async as part of EDGE- 154495
        let today = new Date();
        let attDate = new Date(newValue);
        today.setHours(0, 0, 0, 0);
        attDate.setHours(0, 0, 0, 0);
        let solution = await CS.SM.getActiveSolution();//EDGE-154495
        let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495 Spring 20 changes
        let config = await currentComponent.getConfiguration(guid);//EDGE-154495 Spring 20 changes
        if (attDate <= today) {
            CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
            //EDGE-154495 Spring 20 changes start
            //CS.SM.updateConfigurationStatus(componentName, guid, false, 'Disconnection date should be greater than today!');
            config.status = false;
            config.statusMessage = 'Disconnection date should be greater than today!';
            //EDGE-154495 Spring 20 changes end
        } else {
            //EDGE-154495 Spring 20 changes start
            //CS.SM.updateConfigurationStatus(componentName, guid, true, '');
            config.status = true;
            config.statusMessage = '';
            //EDGE-154495 Spring 20 changes end
        }
        return Promise.resolve(true);//Pooja
    }


    /**
                     * Author      : Aditya Pareek 2019-09-09
                     * Ticket      : EDGE-98282
                     * Description : Method to blank the OETAB for MAC
                     */
    TIDPlugin.setOETabsVisibility = async function () {//Made it async EDGE-154495
        console.log('setOETabsVisibility');
        //Changes as part of EDGE-154495 start
        let solution = await CS.SM.getActiveSolution();
        //CS.SM.getActiveSolution().then((solution) => {
        //Changes as part of EDGE-154495 end
        if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution
            if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes
                Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20 changes

                                if ((basketChangeType === 'Change Solution' && basketStage === 'Commercial Configuration') || !Utils.isOrderEnrichmentAllowed()) {

                                    CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
                                    console.log('setOETabsVisibility - hiding:', comp.name, config.guid);
                                } else {
                                    CS.SM.setOEtabsToLoad(comp.name, config.guid, undefined);
                                    console.log('setOETabsVisibility - showing:', comp.name, config.guid);
                                }
                            }
                        });
                    }
                });
            }
        }
        //});
        return Promise.resolve(true);//Pooja
    }

    TIDPlugin.blankOutCRDAttributesOnMACD = async function () {//Made it async- EDGE-154495 Spring 20 changes
        console.log('blankOutCRDAttributesOnMACD');
        if (basketChangeType !== 'Change Solution' || basketStage !== 'Contract Accepted')
            return;
        //Changes as part of EDGE-154495 start
        let product = await CS.SM.getActiveSolution();
        let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.solution);
        //CS.SM.getActiveSolution().then((product) => {
        //Changes as part of EDGE-154495 end
        console.log('blankOutCRDAttributesOnMACD', product);
        if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product
            if (product.components && Object.values(product.components).length > 0) {//EDGE-154495 Spring 20 changes
                //Object.values(product.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                for (const comp of Object.values(product.components)) {//EDGE-154495 Spring 20 changes
                    if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                            //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                            for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495 Spring 20 changes
                                var updateMap = {};
                                if (config.id && config.orderEnrichmentList && Object.values(config.orderEnrichmentList).length > 0) {//EDGE-154495 Spring 20 changes
                                    //Object.values(config.orderEnrichmentList).forEach((oeConfig) => {//EDGE-154495 Spring 20 changes
                                    for (const oeConfig of Object.values(config.orderEnrichmentList)) {//EDGE-154495 Spring 20 changes
                                        var blankedOutAttribute = Object.values(oeConfig.attributes).filter(a => {//EDGE-154495 Spring 20 changes
                                            return a.name === 'BlankedOut'
                                        });
                                        var nbcAttribute = Object.values(oeConfig.attributes).filter(a => {//EDGE-154495 Spring 20 changes
                                            return a.name === 'Not Before CRD'
                                        });
                                        var pcAttribute = Object.values(oeConfig.attributes).filter(a => {//EDGE-154495 Spring 20 changes
                                            return a.name === 'Preferred CRD'
                                        });
                                        console.log('blankedOutAttribute', blankedOutAttribute, blankedOutAttribute[0]);
                                        console.log('nbcAttribute', nbcAttribute);
                                        console.log('pcAttribute', pcAttribute);
                                        if (blankedOutAttribute && blankedOutAttribute.length > 0 && blankedOutAttribute[0] && (!blankedOutAttribute[0].value || blankedOutAttribute[0].value === '' || blankedOutAttribute[0].value === false)) {
                                            updateMap[oeConfig.guid] = [];
                                            if (nbcAttribute && nbcAttribute[0] && nbcAttribute[0].value) {
                                                updateMap[oeConfig.guid].push({
                                                    name: "Not Before CRD",
                                                    value: null
                                                });
                                            }
                                            if (pcAttribute && pcAttribute[0] && pcAttribute[0].value) {
                                                updateMap[oeConfig.guid].push({
                                                    name: "Preferred CRD",
                                                    value: null
                                                });
                                            }
                                        }
                                        console.log('blankOutCRDAttributesOnMACD updateMap:', updateMap);
                                        if (updateMap && Object.keys(updateMap).length > 0) {
                                            updateMap[oeConfig.guid].push({
                                                name: "BlankedOut",
                                                //value: {//EDGE-154495 Spring 20 changes
                                                value: true,
                                                displayValue: true,
                                                readOnly: false,
                                                required: false
                                                //}//EDGE-154495 Spring 20 changes
                                            });
                                            //Changes as part of EDGE-155255 start
                                            //CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(crdOEConfig => console.log('blankOutCRDAttributesOnMACD Attribute Update', crdOEConfig));
                                            console.log('initializeTIDOEConfigs updateMap:', updateMap);
                                            let keys = Object.keys(updateMap);
                                            console.log('initializeTIDOEConfigs keys:', keys);
                                            for (var h = 0; h < updateMap.length; h++) {
                                                await currentComponent.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false)
                                            }//Changes as part of EDGE-155255 end
                                        }

                                    }//);
                                }
                            }//);
                        }
                    }
                }//);
            }
        }
        // }).then(
        //() => Promise.resolve(true)
        //);
        return Promise.resolve(true);
    }

    /*****************************************************************************************************
     * Author	   : Sandip Deshmane
     * Method Name : calculateTotalETCValue
     * Invoked When: Solution is added to MACBasket and Change Type is set to Cancel.
     * Description : Calculate Total ETC Value in case of Product Cancellation
     * Parameters  : guid
     ****************************************************************************************************/
    TIDPlugin.calculateTotalETCValue = async function (guid) {//Made this function async -EDGE-154495
        console.log('calculateTotalETCValue', basketChangeType, guid);

        if (basketChangeType !== 'Change Solution') {
            return;
        }

        //Changes as part of EDGE-155255 start
        let product = await CS.SM.getActiveSolution();
        let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.solution);
        // CS.SM.getActiveSolution().then((product) => {
        //Changes as part of EDGE-155255 end
        let remainingTerm;
        let contractTerm;
        let disconnectionDate;
        let prodConfigID;
        let componentName;
        let etcWaiver;
        let caseNumber;
        let etcPercent;
        console.log('calculateTotalETCValue', product);
        if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product
            if (product.components && Object.values(product.components).length > 0) {//EDGE-154495 Spring 20 changes
                Object.values(product.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                            if (config.guid === guid) {
                                componentName = comp.name;
                                prodConfigID = config.replacedConfigId;
                                let dd = Object.values(config.attributes).filter(a => { return a.name === 'DisconnectionDate' && a.value });//EDGE-154495 Spring 20 changes
                                if (dd && dd.length > 0)
                                    disconnectionDate = new Date(dd[0].value);
                                let ct = Object.values(config.attributes).filter(a => { return a.name === 'Contract Term' && a.value });//EDGE-154495 Spring 20 changes
                                if (ct && ct.length > 0)
                                    contractTerm = ct[0].value;

                                let rt = Object.values(config.attributes).filter(a => { return a.name === 'RemainingTerm' && a.value });//EDGE-154495 Spring 20 changes
                                if (rt && rt.length > 0)
                                    remainingTerm = rt[0].value;

                                let ew = Object.values(config.attributes).filter(a => { return a.name === 'ETCWaiver' && a.value });//EDGE-154495 Spring 20 changes
                                if (ew && ew.length > 0)
                                    etcWaiver = ew[0].value;

                                let cn = Object.values(config.attributes).filter(a => { return a.name === 'CaseNumber' && a.value });//EDGE-154495 Spring 20 changes
                                if (cn && cn.length > 0)
                                    caseNumber = cn[0].value;

                                let ep = Object.values(config.attributes).filter(a => { return a.name === 'ETCPercentage' && a.value });//EDGE-154495 Spring 20 changes
                                if (ep && ep.length > 0)
                                    etcPercent = ep[0].value;
                            }
                        });
                    }
                });
                if (etcWaiver && caseNumber !== "" && caseNumber !== "null" && caseNumber !== undefined) {
                    //Changes as part of EDGE-154495 start
                    /*var updateMap = [];
                    updateMap[guid] = [{
                        name: 'EarlyTerminationCharge',
                        value: {
                            value: 0,
                            displayValue: 0
                        }
                    }];*/
                    let updateMap = {};
                    updateMap[guid] = [];
                    updateMap[guid].push({
                        name: "EarlyTerminationCharge",
                        value: 0,
                        displayValue: 0
                    });

                    //CS.SM.updateConfigurationAttribute(componentName, updateMap, true).then(component => console.log('calculateTotalETCValue Attribute update', component));
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                    }
                    //Changes as part of EDGE-154495 end

                } else {
                    console.log('remainingTerm=', remainingTerm, ', disconnectionDate=', disconnectionDate);
                    if (disconnectionDate && remainingTerm) {
                        var inputMap = {};
                        var updateMap = [];
                        inputMap["getETCChargesForTID"] = '';
                        inputMap["DisconnectionDate"] = disconnectionDate;
                        inputMap["ContractTerm"] = contractTerm;
                        inputMap["ProdConfigId"] = prodConfigID;
                        inputMap["ETCPercentage"] = etcPercent;
                        console.log('inputMap', inputMap);
                        let currentBasket = await CS.SM.getActiveBasket(); //EDGE-154495 Spring 20 changes
                        //CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => { //EDGE-154495 Spring 20 changes
                        currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async values => { //EDGE-154495 Spring 20 changes- added async
                            var charges = values["getETCChargesForTID"];
                            console.log('getETCChargesForTID Result', values["getETCChargesForTID"], charges);

                            //Changes as part of EDGE-154495 start
                            /*updateMap[guid] = [{
                                name: 'EarlyTerminationCharge',
                                value: {
                                    value: charges,
                                    displayValue: charges
                                }
                            }];*/
                            updateMap[guid] = [];
                            updateMap[guid].push({
                                name: "EarlyTerminationCharge",
                                value: charges,
                                displayValue: charges
                            });

                            //CS.SM.updateConfigurationAttribute(componentName, updateMap, true).then(component => console.log('calculateTotalETCValue Attribute update', component));
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }
                            //Changes as part of EDGE-154495 end
                        });
                    }
                }

            }
        }
        //});
        return Promise.resolve(true);//Pooja
    }

    //Changes as part of EDGE-154495 start
    //TIDPlugin.afterSolutionLoaded = async function (previousSolution, loadedSolution) {
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154489
        if (currentSolution.name === TID_COMPONENT_NAMES.solution) {
            let currentBasket;
            let loadedSolution;
            loadedSolution = await CS.SM.getActiveSolution()
            console.log('solution loaded!!!', loadedSolution);
            currentBasket = await CS.SM.getActiveBasket();
            basketId = currentBasket.basketId;
            window.currentSolutionName = loadedSolution.name;
            //EDGE-198536 Start: existing code moved inside active solution check
            //Changes as part of EDGE-154495 end
            window.addEventListener('message', TIDPlugin_handleIframeMessage);
            setInterval(TIDPlugin_processMessagesFromIFrame, 500);
            setInterval(saveSolutionTID, 500);
            document.addEventListener('click', function (e) {
                e = e || window.event;
                var target = e.target || e.srcElement;
                var text = target.textContent || target.innerText;
                if (text && text.toLowerCase() === 'internet site') {
                    Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
                    Utils.updateCustomButtonVisibilityForBasketStage();
                }

                if (text && text.toLowerCase().includes('stage')) {
                    Utils.updateCustomButtonVisibilityForBasketStage();
                    Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);
                }
                if (text) {
                    Utils.updateOEConsoleButtonVisibility();
                }
                if (window.currentSolutionName === TID_COMPONENT_NAMES.solution && text && (text.toLowerCase() === 'overview' || text.toLowerCase().includes('stage'))) {
                    Utils.hideSubmitSolutionFromOverviewTab();
                }

            }, false);
            //EDGE-198536 End: existing code moved inside active solution check

            await Utils.loadSMOptions();

            //Getting the basket ID which is needed for Adding Sites
            /*await CS.SM.getCurrentCart().then(cart => {
                console.log('Basket: ', cart);
                basketId = cart.id;
        
            });*/
            //Changes as part of EDGE-154495 end

            let map = {};
            map['GetSiteId'] = '';
            currentBasket.performRemoteAction('SolutionActionHelper', map).then(result => {//EDGE-154495
                console.log('GetSiteId call to check if this is PRM Profile finished with response: ', result);
                tidCommunitySiteId = result["GetSiteId"]
                console.log('tidCommunitySiteId: ', tidCommunitySiteId);
            });

            // get the bandwidth Charges for downgrade || Added by Aman Soni as part of EDGE-113848
            let map2 = {};
            currentBasket.performRemoteAction('SolutionHelperBandwidthOC', map2).then(result => {//EDGE-154495
                //console.log('Get the onetime bandwidth downgrade charges. ', result);
                var bandwidthDowngradeOC = result["bandwidthDowngradeOC"]
                //console.log('bandwidthDowngradeOC -------- : ', bandwidthDowngradeOC.cspmb__One_Off_Charge__c);
                bandwidthDownGradeChrg = bandwidthDowngradeOC.cspmb__One_Off_Charge__c;
            });


            // First get the pattern ID with which the call to the microservice will be made
            let map1 = {};
            currentBasket.performRemoteAction('SolutionHelperZonePattern', map1).then(result => {//EDGE-154495
                console.log('Get the onetime Zone Pattern from Charge Zone Object ', result);
                var chargeZone = result["chargeZone"];
                console.log('chargeZone.Charge_Zone_Pattern_Id__c-----> ', chargeZone.Charge_Zone_Pattern_Id__c);
                zonePatternID = chargeZone.Charge_Zone_Pattern_Id__c;
                console.log('zonePatternID-----> ', zonePatternID);

            });

            let inputMap = {};
            inputMap['GetBasket'] = basketId;
            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {//EDGE-154495
                console.log('GetBasket finished with response: ', result);
                var basket = JSON.parse(result["GetBasket"]);
                console.log('GetBasket: ', basket);
                basketChangeType = basket.csordtelcoa__Change_Type__c;
                basketStage = basket.csordtelcoa__Basket_Stage__c;
                accountId = basket.csbb__Account__c;
                cidn = basket.csbb__Account__r.CIDN__c;
                opptyId = basket.cscfga__Opportunity__c;
                console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId, 'opptyId:', opptyId + 'CIDN ---- ' + cidn);

                window.oeSetBasketData(basketId, basketStage, accountId);
            });
            // Get the Zone Pattern ID which will be needed to invoke the Microservice
            addDefaultTIDOEConfigs();
            await tidcheckConfigurationSubscriptions();
            TIDPlugin.updateChangeTypeAttributeTID(loadedSolution);
            TIDPlugin.getConfiguredSiteIds();
            Utils.updateComponentLevelButtonVisibility('Add IP Site', false, true);

            if (basketChangeType === 'Change Solution') {
                TIDPlugin.UpdateAttributesForMacdOnSolutionTID(loadedSolution);//Added by Aman Soni as a part of EDGE-105060
                TIDPlugin.setOETabsVisibility();
                updateRemainingTermAfterSolutionLoadTID();
            }
            TIDPlugin.UpdateMainSolutionChangeTypeVisibility(loadedSolution);//Added by Aman Soni as a part of EDGE-105060
            TIDPlugin.blankOutCRDAttributesOnMACD();
            showDowngradeBandwidthChargeOnAttSave();//Added by Aman Soni as a part of EDGE-113848	 
            hideDowngradeBandwidthCharge(loadedSolution);//Added by Aman Soni as a part of EDGE-105060
            //EDGE-198536 Start - init PRE for solution only when needed
            PRE_Logic.init(loadedSolution);
            PRE_Logic.afterSolutionLoaded();
            //EDGE-198536 End
        }
        return Promise.resolve(true);
    });


    //Changes as part of EDGE-154495 start
    //TIDPlugin.afterOETabLoaded = async function (configurationGuid, OETabName) {
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        //console.log('afterOETabLoaded : TIDPlugin: ', configurationGuid, OETabName);
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154495
        if (currentSolution.name === TID_COMPONENT_NAMES.solution) {//EDGE-154495
            console.log('OrderEnrichmentTabLoaded', e);//EDGE-154495
            console.log('e.detail.orderEnrichment.name', e.detail.orderEnrichment.name);
            var element = TID_existingSiteIds.filter(ev => { return ev.guid === e.detail.configurationGuid });
            var siteId = '';
            if (element && element.length > 0) {
                siteId = element[0].siteId;
            }
            //var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid); *///EDGE-154495
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);//EDGE-154495
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, siteId);
            //Changes as part of EDGE-154495 end
        }
        return Promise.resolve(true);
    });
}



async function addDefaultTIDOEConfigs() {
    if (basketStage !== 'Contract Accepted')
        return;
    console.log('addDefaultOEConfigs');
    var oeMap = [];
    //EDGE-154495 Spring 20 changes start here
    //await CS.SM.getActiveSolution().then((currentSolution) => {
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultOEConfigs ', currentSolution, TID_COMPONENT_NAMES.solution);
    if (currentSolution && currentSolution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution - //EDGE-154495
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) { //EDGE-154495
            Object.values(currentSolution.components).forEach((comp) => { //EDGE-154495
                Object.values(comp.schema.configurations).forEach((config) => { //EDGE-154495
                    Object.values(comp.orderEnrichments).forEach((oeSchema) => { //EDGE-154495
                        //Added the addition if condition for UC by Mahaboob o 27/07/2019 as UC is used across 2 solutions
                        //  if (!oeSchema.name.toLowerCase().includes('numbermanagementv1') 
                        //	&& !(config.name === 'Unified Communication' && oeSchema.name === 'Customer requested Dates')) {
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
                            //el.oeSchemaId = oeSchema.id;// EDGE-154495
                            el.oeSchema = oeSchema;//EDGE-154495
                            oeMap.push(el);

                            console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
                        }

                        //}
                    });
                });
            });
        }
    }
    //}//).then(() => 
    //Promise.resolve(true); //EDGE-154495
    console.log('addDefaultOEConfigs prepared');
    /*if (oeMap.length > 0) {
        var map = [];
        map.push({});
        console.log('Adding default oe config map:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
        };
    }*/
    if (oeMap.length > 0) {
        //let map = [];
        console.log('Adding default oe config map--:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            console.log(' Component name ----' + oeMap[i].componentName);
            //let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration(map);
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        };
    }

    await initializeTIDOEConfigs();
    return Promise.resolve(true);
}


/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : initializeTIDOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
async function initializeTIDOEConfigs() {
    console.log('initializeOEConfigs');
    //var currentSolution;
    //EDGE-154495 Spring 20 changes start here
    /*await CS.SM.getActiveSolution().then((solution) => {
        currentSolution = solution;
        console.log('initializeOEConfigs - getActiveSolution');
    }).then(() => Promise.resolve(true));*/
    let currentSolution = await CS.SM.getActiveSolution();
    let Component = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);
    if (currentSolution) {
        console.log('initializeOEConfigs - updating');
        if (currentSolution && currentSolution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154495
                for (var i = 0; i < Object.values(currentSolution.components).length; i++) {//EDGE-154495
                    var comp = Object.values(currentSolution.components)[i];//EDGE-154495
                    for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {//EDGE-154495
                        var config = Object.values(comp.schema.configurations)[j];//EDGE-154495
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {//EDGE-154495
                                var oe = Object.values(config.orderEnrichmentList)[k];//EDGE-154495

                                var basketAttribute = Object.values(oe.attributes).filter(a => {//EDGE-154495
                                    return a.name.toLowerCase() === 'basketid'
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    if (!updateMap[oe.guid])
                                        updateMap[oe.guid] = [];

                                    updateMap[oe.guid].push({ name: basketAttribute[0].name, value: basketId });
                                    console.log('Basket ID -------------' + basketId);
                                }

                                /** if (comp.name === TID_COMPONENT_NAMES.internetSite) {
 
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
 
                                 }**/
                            }
                        }
                        //EDGE-154495 Spring 20 changes start here
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            console.log('initializeTIDOEConfigs updateMap:', updateMap);
                            let keys = Object.keys(updateMap);
                            console.log('initializeTIDOEConfigs keys:', keys);
                            for (var h = 0; h < updateMap.length; h++) {
                                await Component.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false)
                            }
                            //CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));//check this
                        } //EDGE-154495 Spring 20 changes end here
                    };
                };
            }
        }
    }

    return Promise.resolve(true);
}

/**
 * Author      : Antun Bartonicek 2019-08-30
 * Ticket      : EDGE-108959
 * Functions for processing iFrame messages
 */
function TIDPlugin_processMessagesFromIFrame() {
    if (!tidCommunitySiteId) {
        return;
    }

    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var message = {};
    if (data) {
        console.log('TIDPlugin_processMessagesFromIFrame:', data);
        message['data'] = JSON.parse(data);
        TIDPlugin_handleIframeMessage(message);
    }
    if (close) {
        console.log('TIDPlugin_processMessagesFromIFrame:', data);
        message['data'] = close;
        TIDPlugin_handleIframeMessage(message);
    }
}

/**
 * Author      : Antun Bartonicek 2019-08-30
 * Ticket      : EDGE-108959
 * Migrated from ConnectedWorkplace plugin.
 */
//TIDPlugin_handleIframeMessage = function(e) {
async function TIDPlugin_handleIframeMessage(e) {//Made it async
    //Added by Pooja start
    let product = null;
    console.log('trying to get solution');
    try {
        product = await CS.SM.getActiveSolution();
    }
    catch (e) {
        console.log('Product is ' + product);
    }

    if (product == null) return Promise.resolve(true);
    //Added by Pooja end 

    console.log('TIDPlugin.handleIframeMessage:', e);

    if (!e.data || !e.data['command'] || e.data['command'] !== 'ADDRESS' || (e.data['caller'] && e.data['caller'] === TID_COMPONENT_NAMES.solution)) {
        sessionStorage.removeItem("payload");
        sessionStorage.removeItem("close");
    }
    if (e.data === 'close') {
        console.log('Closing modal window');
        /* try {
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
 
         } */
        try {
            var d = document.getElementsByClassName('mat-dialog-container');
            if (d) {
                for (var i = 0; i < d.length; i++) {
                    d[i].remove();
                }
            }
            var d2 = document.getElementsByClassName('container');
            if (d2) {
                for (var i = 0; i < d2.length; i++) {
                    d2[i].remove();
                }
            }

            var el = document.getElementsByClassName('cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing');
            if (el) {
                for (var i = 0; i < el.length; i++) {
                    el[i].remove();
                }
            }

        }
        catch (err) {
            console.log(err);
        }
    }

    if (e.data && e.data['command'] != undefined) {
        console.log('TIDPlugin.handleIframeTask:', e);
        console.log(e.data);

        if (e.data['command'] == 'ADDRESS') {

            if (e.data['caller'] && e.data['caller'] !== TID_COMPONENT_NAMES.solution) {
                return;
            }

            if (e.data['data'] && e.data['data'].length > 0 && e.data['data'][0] && e.data['data'][0]['ipSiteconfigId'] != undefined && e.data['data'][0]['ipSiteconfigId'].length > 0) {
                // TIDPlugin.updateIpSite(e.data['data']);//EDGE-154495
                updateIpSite(e.data['data']);//EDGE-154495
            } else {
                if (e.data['data'])
                    //TIDPlugin.addIpSites(e.data['data']);//EDGE-154495
                    addIpSites(e.data['data']);
            }
        }
    }
}



/**
 * Author      : Antun Bartonicek 2019-08-30
 * Ticket      : EDGE-108959
 * Migrated from ConnectedWorkplace plugin.
 */
async function TID_updateConfigurationsName() {

    console.log('TID_updateConfigurationsName');

    var updateConfigMapInternetSites = {};
    var internetSiteCount = 0;
    //await CS.SM.getActiveSolution().then((solution) => {//EDGE-154495
    let solution = await CS.SM.getActiveSolution();//EDGE-154495
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.internetSite);//EDGE-154495

    if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution //EDGE-154495
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495
            Object.values(solution.components).forEach((comp) => {//EDGE-154495
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                    Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495

                        console.log('TID_updateConfigurationsName configurationName: ', config.configurationName);

                        var changeTypeAttribute = Object.values(config.attributes).filter(a => {//EDGE-154495
                            return a.name === 'ChangeType' && a.displayValue
                        });

                        if (comp.name === TID_COMPONENT_NAMES.internetSite) {

                            internetSiteCount = internetSiteCount + 1;

                            var newSiteName = internetSiteCount + '. Internet Site'

                            var attribute = Object.values(config.attributes).filter(a => {////EDGE-154495
                                return a.name === 'Site Name'
                            });

                            if (attribute && attribute.length > 0) {
                                newSiteName = newSiteName + ' | ' + attribute[0].value;
                            }

                            if (changeTypeAttribute && changeTypeAttribute.length > 0) {
                                newSiteName = newSiteName + ' | ' + changeTypeAttribute[0].value;
                            }

                            //Changes as part of EDGE-154495 start
                            /*updateConfigMapInternetSites[config.guid] = [{
                                name: 'ConfigurationName',
                                value: newSiteName
                            }];*/

                            updateConfigMapInternetSites[config.guid] = [];
                            updateConfigMapInternetSites[config.guid].push({
                                name: "ConfigurationName",
                                value: newSiteName
                            });
                            //Changes as part of EDGE-154495 end
                        }
                    });
                }
            });
        }
    }
    //}//); //Changes as part of EDGE-154495 start

    if (updateConfigMapInternetSites && Object.keys(updateConfigMapInternetSites).length > 0) {
        console.log('TID_updateConfigurationsName updateConfigMapInternetSites ', updateConfigMapInternetSites);
        //await CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.internetSite, updateConfigMapInternetSites, true);
        keys = Object.keys(updateConfigMapInternetSites);
        for (let i = 0; i < keys.length; i++) {
            await currentComponent.updateConfigurationAttribute(keys[i], updateConfigMapInternetSites[keys[i]], true);
        }
        //Changes as part of EDGE-154495 end
    }
    return Promise.resolve(true);
}



/**
* Author      : Aditya Pareek 2019-09-09
* Ticket      : EDGE-96379
* Description : Method to blank the related lookup attribute
*/
async function emptyLookupAttributesTID(compname, guid, attr) {//Made the function async - EDGE-154495 Spring 20 changes
    //CS.SM.getActiveSolution().then((product) => { //EDGE-154495
    let product = await CS.SM.getActiveSolution();//EDGE-154495
    let Component = product.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495
    if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product- //EDGE-154495
        if (product.components && Object.values(product.components).length > 0) {//EDGE-154495

            var validcomp = Object.values(product.components).filter(comp => {//EDGE-154495
                return comp.name === compname
            });
            if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {//EDGE-154495
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(config => {//EDGE-154495
                    return config.guid === guid
                });
            }
            if (validconfig && validconfig[0].attributes) {
                //Changes as part of EDGE-154495 start
                //var updateMap = [];
                var updateMap = {};
                if (compname === TID_COMPONENT_NAMES.internetSite && attr === 'SelectZone') {
                    /*updateMap[validconfig[0].guid] = [{
                        name: "IPAccessConfiguration",
                        value: {
                            value: ''
                        }
                    }, {
                        name: "Bandwidth",
                        value: {
                            value: ''
                        }
                    }];*/

                    updateMap[validconfig[0].guid] = [];
                    updateMap[validconfig[0].guid].push({
                        name: "IPAccessConfiguration",
                        value: ''
                    },
                        {
                            name: "Bandwidth",
                            value: ''
                        });
                }
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await Component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                }
                //CS.SM.updateConfigurationAttribute(compname, updateMap, true);
                //Changes as part of EDGE-154495 end

            }
        }
    }
    //});
    return Promise.resolve(true);//Added by Pooja
}

/**
 * Author      : Aditya Pareek 2019-09-09
 * Ticket      : EDGE-96379
 * Description : Method to not save the solution if Fibre Availability Status is Unavailable
 */
async function saveSolutionTID() {

    if (executeSaveTID) {
        executeSaveTID = false;
        var count = 0;
        var oeerrorcount = 0;
        //await CS.SM.getActiveSolution().then((currentSolution) => {//EDGE-154495
        let currentSolution = await CS.SM.getActiveSolution();//EDGE-154495
        let siteComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.internetSite);//EDGE-154495

        if (currentSolution && currentSolution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed currentSolution.type to currentSolution
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {//EDGE-154495
                //Object.values(currentSolution.components).forEach((comp) => {//EDGE-154495
                for (const comp of Object.values(currentSolution.components)) {//EDGE-154495
                    //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                    for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495
                        // Object.values(config.attributes).forEach((attr) => {//EDGE-154495
                        let cnfg = await siteComponent.getConfiguration(config.guid);//EDGE-154495
                        for (const attr of Object.values(config.attributes)) {//EDGE-154495
                            if (attr.name === 'FibreAvailabilityStatus' && attr.value === 'Unavailable') {
                                count = count + 1;
                            }
                            // Laxmi - Added below condition to check additional condition - && config.disabled === false
                            // Removed validation for || attr.name === 'Projectcontactid' || attr.name === 'AfterHourscontactid' as these are not mandatory inputs
                            if (basketStage === 'Contract Accepted' && config.disabled === false) {
                                if (((attr.name === 'Not Before CRD' || attr.name === 'Preferred CRD') && attr.value === 0) || ((attr.name === 'Technicalcontactid' || attr.name === 'Primarycontactid') && attr.value === '')) {
                                    oeerrorcount = oeerrorcount + 1;

                                    //Changes as part of EDGE-154495 start
                                    //CS.SM.updateConfigurationStatus(comp.name, config.guid, false, 'Error in Order Enrichment');
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Error in Order Enrichment';
                                    //Changes as part of EDGE-154495 end
                                }
                                if (attr.name === 'Not Before CRD' && attr.value !== 0 && attr.value <= notBeforeCRDValidation) {

                                    oeerrorcount = oeerrorcount + 1;
                                    //Changes as part of EDGE-154495 start
                                    //CS.SM.updateConfigurationStatus(comp.name, config.guid, false, 'Error in Order Enrichment');
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Error in Order Enrichment';
                                    //Changes as part of EDGE-154495 end

                                } else if ((attr.name === 'Not Before CRD' && attr.value !== 0 && attr.value >= notBeforeCRDValidation)) {
                                    //Changes as part of EDGE-154495 start
                                    //CS.SM.updateConfigurationStatus(comp.name, config.guid, true, '');
                                    cnfg.status = true;
                                    cnfg.statusMessage = '';
                                    //Changes as part of EDGE-154495 end
                                }

                                if (attr.name === 'Preferred CRD' && attr.value !== 0 && attr.value <= Utils.getAttributeValue('Not Before CRD', config.guid)) {
                                    console.log('Utils.getAttributeValue' + Utils.getAttributeValue('Not Before CRD', config.guid));
                                    console.log('attr.value' + attr.value);
                                    console.log('Issue found dates arent proper!!!');
                                    oeerrorcount = oeerrorcount + 1;
                                    //Changes as part of EDGE-154495 start
                                    //CS.SM.updateConfigurationStatus(comp.name, config.guid, false, 'Error in Order Enrichment');
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Error in Order Enrichment';
                                    //Changes as part of EDGE-154495 end
                                }
                            }
                        }//);
                    }//);
                }//);
            }
        }
        //});

        if (count > 0 && !executeSaveTID) {
            CS.SM.displayMessage('TID is currently offered only for sites with existing Telstra Fibre!', 'error');
            //executeSaveTID = true;
            return Promise.resolve(false);
        } else if (oeerrorcount > 0 && !executeSaveTID) {
            CS.SM.displayMessage('Order Enrichment has errors.It can be either Mandatory fields not populated/Not before CRD is lesser than or equal to today/Preferred CRD is lesser than Not Before CRD.', 'error');
            //executeSaveTID = true;
            return Promise.resolve(false);
        }
        else {
            saveTID = true;
            //Changes as part of EDGE-154495 start
            //await CS.SM.saveSolution();
            let solution = await CS.SM.getActiveSolution();//EDGE-154495
            let currentBasket = await CS.SM.getActiveBasket();//EDGE-154495
            //await currentBasket.saveSolution(solution);
            //await currentBasket.saveSolution();
            //Changes as part of EDGE-154495 end
            return Promise.resolve(true);
        }
    }
}

/***********************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : checkConfigurationSubscriptions
 * Invoked When: Solution is Loaded
 * Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)

 ***********************************************************************************************/
async function tidcheckConfigurationSubscriptions() {
    console.log('checkConfigurationSubscriptions');
    var componentMap = {};
    //await CS.SM.getActiveSolution().then((solution) => {//EDGE-154495
    let solution = await CS.SM.getActiveSolution();//EDGE-154495
    let component = solution.getComponentByName(TID_COMPONENT_NAMES.solution);//EDGE-154495
    if (solution.type && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution- //EDGE-154495
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495
            Object.values(solution.components).forEach((comp) => {//EDGE-154495
                if ((comp.name === TID_COMPONENT_NAMES.internetSite) &&
                    comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                    Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                        if (config.replacedConfigId || config.id) {
                            var cta = Object.values(config.attributes).filter(a => {//EDGE-154495
                                return a.name === 'ChangeType' && a.displayValue !== 'Modify' && a.displayValue !== 'Cancel'
                            });
                            if (cta && cta.length > 0) {

                                if (!componentMap[comp.name])
                                    componentMap[comp.name] = [];

                                if (config.replacedConfigId)
                                    componentMap[comp.name].push({
                                        'id': config.replacedConfigId,
                                        'guid': config.guid,
                                        'ChangeTypeValue': cta[0].value
                                    }); // Modified by Aman Soni as a part of EDGE-125042
                                else
                                    componentMap[comp.name].push({
                                        'id': config.id,
                                        'guid': config.guid,
                                        'ChangeTypeValue': cta[0].value
                                    }); // Modified by Aman Soni as a part of EDGE-125042
                            }
                        }
                    });
                }
            });
        }
    }
    //});

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

        //Changes as part of EDGE-154495 start
        let currentBasket = await CS.SM.getActiveBasket();
        basketId = currentBasket.basketId;
        //await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
        //Changes as part of EDGE-154495 end

        await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {//EDGE-154495
            console.log('GetSubscriptionForConfiguration result:', values);
            if (values['GetSubscriptionForConfiguration'])
                statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
        });

        console.log('checkConfigurationSubscriptions statuses;', statuses);
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
                    //Changes as part of EDGE-154495 start
                    /*updateMap[element.guid] = [{
                        name: 'ChangeType',
                        value: {
                            value: statusValue,
                            displayValue: statusValue
                        },
                        { // Added by Aman Soni as a part of EDGE-125042 || Start
                        name: 'Substatus',
                        value: {
                            value: statusValue,
                            displayValue: statusValue,
                        }
                    }]; // Added by Aman Soni as a part of EDGE-125042 || End
                    }];*/

                    updateMap[element.guid] = [];
                    updateMap[element.guid].push({
                        name: "ChangeType",
                        value: statusValue,
                        displayValue: statusValue
                    },
                        { // Added by Aman Soni as a part of EDGE-125042 || Start
                            name: 'Substatus',
                            value: statusValue,
                            displayValue: statusValue,
                        } // Added by Aman Soni as a part of EDGE-125042 || End
                    );
                });

                console.log('checkConfigurationSubscriptions update map', updateMap);
                //CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptions Attribute Update', component));
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                } //Changes as part of EDGE-154495 end

            });
        }

    }

    return Promise.resolve(true);
}

/**
 * Author      : Aditya Pareek 2019-09-09
 * Ticket      : EDGE-98282
 * Description : Method to blank the related lookup attribute
 */

//Modified by Aman Soni as a part of EDGE-105060
async function changetypemodify(guid) {
    console.log('changetypemodify start', guid);
    //Changes as part of EDGE-154495 start
    //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
    let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.solution);
    //Changes as part of EDGE-154495 end
    if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product
        if (product.components && Object.values(product.components).length > 0) {//EDGE-154495
            //Object.values(product.components).forEach((comp) => {//EDGE-154495
            for (const comp of Object.values(product.components)) { //EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                    for (const config of Object.values(comp.schema.configurations)) { //EDGE-154495
                        if (config.guid === guid) {
                            var configUpdateMap = {};
                            //Changes as part of EDGE-155255 start
                            /*configUpdateMap[config.guid] = [{
                                name: "Widefeas Code",
                                value: {
                                    showInUi: false,
                                    required: false
                                }
                            },
                            {
                                name: "SelectZone",
                                value: {
                                    readOnly: true
                                }
                            },
                            {
                                name: "ChangeType",
                                value: {
                                    showInUi: true,
                                    required: true
                                }
                            }, {
                                name: "ServiceabilityLocation",
                                value: {
                                    readOnly: true
                                }
                            }, {
                                name: "FibreAvailabilityStatus",
                                value: {
                                    readOnly: true
                                }
                            }, {
                                name: "AccessTechnology",
                                value: {
                                    readOnly: true
                                }
                            }, {
                                name: "RemainingTerm",
                                value: {
                                    showInUi: true,
                                    readOnly: true
                                }
                            },
                            {
                                name: "IPAccessConfiguration",
                                value: {
                                    readOnly: true
                                }
                            },
                            {
                                name: "CancellationReason",
                                value: {
                                    value: '',
                                    showInUi: false,
                                    readOnly: true,
                                    required: false
                                }
                            },
                            {
                                name: "DisconnectionDate",
                                value: {
                                    value: '',
                                    showInUi: false,
                                    required: false
                                }
                            },
                            {
                                name: "EarlyTerminationCharge",
                                value: {
                                    value: '',
                                    showInUi: false,
                                    readOnly: true
                                }
                            },
                            {
                                name: "ETCWaiver",
                                value: {
                                    value: '',
                                    showInUi: false
                                }
                            },

                            {
                                name: "FeasibilityExpiryDate",
                                value: {
                                    readOnly: true
                                }
                            },
                            {
                                name: "Contract Term",
                                value: {
                                    readOnly: true
                                }
                            },
                            {
                                name: "CaseNumber",
                                value: {
                                    value: '',
                                    showInUi: false
                                }
                            },
                            {
                                name: "Bandwidth",
                                value: {
                                    showInUi: true,
                                    readOnly: false,
                                    required: true
                                }
                            },
                            {
                                name: "Installation Charge",
                                value: {
                                    value: '',
                                    showInUi: false
                                }
                            }
                            ,
                            {
                                name: "FeasibilityExpiryDate",
                                value: {
                                    showInUi: false
                                }
                            }];*/

                            configUpdateMap[config.guid] = [];
                            configUpdateMap[config.guid].push({
                                name: "Widefeas Code",
                                showInUi: false,
                                required: false
                            },
                                {
                                    name: "SelectZone",
                                    readOnly: true
                                },
                                {
                                    name: "ChangeType",
                                    showInUi: true,
                                    required: true
                                },
                                {
                                    name: "ServiceabilityLocation",
                                    readOnly: true
                                },
                                {
                                    name: "FibreAvailabilityStatus",
                                    readOnly: true
                                },
                                {
                                    name: "AccessTechnology",
                                    readOnly: true
                                },
                                {
                                    name: "RemainingTerm",
                                    showInUi: true,
                                    readOnly: true
                                },
                                {
                                    name: "IPAccessConfiguration",
                                    readOnly: true
                                },
                                {
                                    name: "CancellationReason",
                                    value: '',
                                    showInUi: false,
                                    readOnly: true,
                                    required: false
                                },
                                {
                                    name: "DisconnectionDate",
                                    value: '',
                                    showInUi: false,
                                    required: false
                                },
                                {
                                    name: "EarlyTerminationCharge",
                                    value: '',
                                    showInUi: false,
                                    readOnly: true
                                },
                                {
                                    name: "ETCWaiver",
                                    value: '',
                                    showInUi: false
                                },

                                {
                                    name: "FeasibilityExpiryDate",
                                    readOnly: true
                                },
                                {
                                    name: "Contract Term",
                                    readOnly: true
                                },
                                {
                                    name: "CaseNumber",
                                    value: '',
                                    showInUi: false
                                },
                                {
                                    name: "Bandwidth",
                                    showInUi: true,
                                    readOnly: false,
                                    required: true
                                },
                                {
                                    name: "Installation Charge",
                                    value: '',
                                    showInUi: false
                                }
                                ,
                                {
                                    name: "FeasibilityExpiryDate",
                                    showInUi: false
                                });
                        }
                        //CS.SM.updateConfigurationAttribute(comp.name, configUpdateMap, true);
                        if (configUpdateMap && Object.keys(configUpdateMap).length > 0) {
                            keys = Object.keys(configUpdateMap);
                            for (let i = 0; i < keys.length; i++) {
                                await currentComponent.updateConfigurationAttribute(keys[i], configUpdateMap[keys[i]], true);
                            }
                        }
                        //Changes as part of EDGE-155255 end
                        console.log('changetypemodify end ---', configUpdateMap);
                    }//);
                }
            }//);
        }
    }
    //}); 
    return Promise.resolve(true);//Added by Pooja
}

/**
* Author      : Aman Soni 2019-11-06
* Ticket      : EDGE-105060
* Description : Method to refresh attributes showing for Cancel ChangeType
*/
async function refreshCancelAttributesTID(compname, guid, attr) {//Made the function async - EDGE-154495 Spring 20 changes
    //Changes as part of EDGE-154495 start
    //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
    let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.solution);
    if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {//changed product.type to product
        if (product.components && Object.values(product.components).length > 0) {//EDGE-154495 Spring 20 changes 

            var validcomp = Object.values(product.components).filter(comp => {//EDGE-154495 Spring 20 changes 
                return comp.name === compname
            });
            if (validcomp && object.values(validcomp[0].schema.configurations).length > 0) {//EDGE-154495
                var validconfig = object.values(validcomp[0].schema.configurations).filter(config => {//EDGE-154495
                    return config.guid === guid
                });
            }
            if (validconfig && validconfig[0].attributes) {//EDGE-154495 
                //Changes as part of EDGE-154495 start
                // var updateMap = [];
                if (compname === TID_COMPONENT_NAMES.internetSite && attr === 'ChangeType') {
                    /*updateMap[validconfig[0].guid] = [{
                        name: "DisconnectionDate",
                        value: {
                            value: '',
                            showInUi: true,
                            required: true
                        }
                    }, {
                        name: "CancellationReason",
                        value: {
                            value: '',
                            showInUi: true,
                            required: true
                        }
                    }, {
                        name: "ETCWaiver",
                        value: {
                            value: '',
                            showInUi: true
                        }
                    }, 
                    {
                            name: "Installation Charge",
                            value: {
                                value: '',
                                showInUi: false
                            }
                        },
                        {
                        name: "EarlyTerminationCharge",
                        value: {
                            value: '',
                            showInUi: true
                        }
                    }];*/
                    let updateMap = {};
                    updateMap[validconfig[0].guid] = [];
                    updateMap[validconfig[0].guid].push({
                        name: "DisconnectionDate",
                        value: '',
                        showInUi: true,
                        required: true
                    }, {
                        name: "CancellationReason",
                        value: '',
                        showInUi: true,
                        required: true
                    }, {
                        name: "ETCWaiver",
                        value: '',
                        showInUi: true
                    },
                        {
                            name: "Installation Charge",
                            value: '',
                            showInUi: false
                        },
                        {
                            name: "EarlyTerminationCharge",
                            value: '',
                            showInUi: true
                        });
                }
                //CS.SM.updateConfigurationAttribute(compname, updateMap, true);
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                } //Changes as part of EDGE-154495 end

            }
        }
    }
    //});
    return Promise.resolve(true);//Added by Pooja
}



/**
 * Author      : Aman Soni 2019-10-14
 * Ticket      : EDGE-113848
 * Description : Method to show Bandwidth downgrade charge on UI by comparing previous bandwidth to new bandwidth on attribute update
 * Change : Sandip Deshmane: EDGE-109355 - Added changes related to EDGE-109355
 */
async function showDowngradeBandwidthChargeOnAttUpdate(guid, oldValue, newValue) {
    //Changes as part of EDGE-154495 start
    // await CS.SM.getActiveSolution().then((solution) => {
    let solution = await CS.SM.getActiveSolution();
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //Changes as part of EDGE-154495 end
    if (solution.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes
            var updateMap = {};
            //Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
            for (const comp of Object.values(solution.components)) {//EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                        //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                        for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20 changes
                                var changetype = Object.values(config.attributes).filter(obj => {
                                    return obj.name === 'ChangeType'
                                });
                                if (changetype[0].value === 'Modify') {
                                    var previousBandwidthWeight = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes
                                        return obj.name === 'PreviousBandwidthWeight'
                                    });
                                    var bandwidthWeight = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes
                                        return obj.name === 'BandwidthWeight'
                                    });
                                    var etcWaiver = Object.values(config.attributes).filter(obj => {
                                        return obj.name === 'ETCWaiver'
                                    });
                                    var caseNumber = Object.values(config.attributes).filter(obj => {
                                        return obj.name === 'CaseNumber'
                                    });
                                    bandwidthWeightInt = parseInt(bandwidthWeight[0].value);
                                    console.log('bandwidthWeightInt---- ', bandwidthWeightInt);
                                    previousBandwidthWeightInt = parseInt(previousBandwidthWeight[0].value);
                                    console.log('previousBandwidthWeightInt---- ', previousBandwidthWeightInt);

                                    if (previousBandwidthWeightInt > bandwidthWeightInt) {
                                        if (etcWaiver && etcWaiver[0].value === true && caseNumber && caseNumber.length > 0 && caseNumber[0].value !== '') {
                                            console.log('INSIDE IF Current band----', bandwidthWeight[0].value);
                                            console.log('INSIDE IF Previous band----', previousBandwidthWeight[0].value);

                                            //Changes as part of EDGE-154495 start
                                            /*updateMap[config.guid] = [];
                                                        updateMap[config.guid].push({
                                                            name: "BandwidthDowngradeOC",
                                                            value: {
                                                                showInUi: true,
                                                                displayValue: 0,
                                                                value: 0
                                                            }
                                                        });
                                                        updateMap[config.guid].push({
                                                            name: "ETCWaiver",
                                                            value: {
                                                                showInUi: true,
                                                            }
                                                        });
                                                        updateMap[config.guid].push({
                                                            name: "CaseNumber",
                                                            value: {
                                                                showInUi: true,
                                                            }
                                                        });*/

                                            updateMap[config.guid] = [];
                                            updateMap[config.guid].push({
                                                name: "BandwidthDowngradeOC",
                                                showInUi: true,
                                                displayValue: 0,
                                                value: 0
                                            });
                                            updateMap[config.guid].push({
                                                name: "ETCWaiver",
                                                showInUi: true,
                                            });
                                            updateMap[config.guid].push({
                                                name: "CaseNumber",
                                                showInUi: true,
                                            });
                                            //Changes as part of EDGE-154495 end
                                        }
                                        else {
                                            console.log('INSIDE IF Current band----', bandwidthWeight[0].value);
                                            console.log('INSIDE IF Previous band----', previousBandwidthWeight[0].value);
                                            updateMap[config.guid] = [];
                                            updateMap[config.guid].push({
                                                name: "BandwidthDowngradeOC",
                                                //value: {/EDGE-154495
                                                showInUi: true,
                                                displayValue: bandwidthDownGradeChrg,
                                                value: bandwidthDownGradeChrg
                                                //}//EDGE-154495
                                            });
                                            if (bandwidthDownGradeChrg > 0) {
                                                updateMap[config.guid].push({
                                                    name: "ETCWaiver",
                                                    // value: {//EDGE-154495
                                                    showInUi: true,
                                                    //}//EDGE-154495
                                                });
                                                updateMap[config.guid].push({
                                                    name: "CaseNumber",
                                                    // value: {//EDGE-154495
                                                    showInUi: true,
                                                    // }//EDGE-154495
                                                });
                                            }
                                        }
                                    }
                                    else if (previousBandwidthWeightInt <= bandwidthWeightInt) {
                                        console.log('INSIDE ELSE Current band----', bandwidthWeight[0].value);
                                        console.log('INSIDE ELSE Previous band----', previousBandwidthWeight[0].value);
                                        //Changes as part of EDGE-154495 start
                                        /*updateMap[config.guid] = [];
                                                updateMap[config.guid].push({
                                                    name: "BandwidthDowngradeOC",
                                                    value: {
                                                        showInUi: false,
                                                    }
                                                });
                                                updateMap[config.guid].push({
                                                    name: "ETCWaiver",
                                                    value: {
                                                        showInUi: false,
                                                    }
                                                });
                                                updateMap[config.guid].push({
                                                    name: "CaseNumber",
                                                    value: {
                                                        showInUi: false,
                                                    }
                                                });*/

                                        updateMap[config.guid] = [];
                                        updateMap[config.guid].push({
                                            name: "BandwidthDowngradeOC",
                                            showInUi: false
                                        });
                                        updateMap[config.guid].push({
                                            name: "ETCWaiver",
                                            showInUi: false,
                                        });
                                        updateMap[config.guid].push({
                                            name: "CaseNumber",
                                            showInUi: false,
                                        });
                                    }
                                }
                                // CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then((config) => { console.log('showDowngradeBandwidthChargeOnAttUpdate finished: ', config) });
                                if (updateMap && Object.keys(updateMap).length > 0) {
                                    keys = Object.keys(updateConfigMap);
                                    for (let i = 0; i < keys.length; i++) {
                                        await currentComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                    }
                                }//Changes as part of EDGE-154495 end
                            }//);

                        }
                    }
                }//);

            }
        }
        //}).then(() => Promise.resolve(true)
        //);
        return Promise.resolve(true);
    }
}

/**
 * Author      : Aman Soni 2019-10-14
 * Ticket      : EDGE-105060
 * Description : Method to hide Bandwidth downgrade charge on UI for ChangeType other than Modify
 */
async function hideDowngradeBandwidthCharge(solution) {
    //Changes as part of EDGE-154495 start
    let currentSolution = await CS.SM.getActiveSolution();
    solution = currentSolution;
    let currentComponent = currentSolution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //await CS.SM.getActiveSolution().then((solution) => {
    //Changes as part of EDGE-154495 end
    //if (solution.name.includes(TID_COMPONENT_NAMES.solution)) {//EDGE-154495
    if (solution.name == TID_COMPONENT_NAMES.solution) {//EDGE-154495
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20
            var updateMap = {};
            //Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20
            for (const comp of Object.values(solution.components)) {//EDGE-154495 
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20
                        //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20
                        for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495 
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20

                                var changetype = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20
                                    return obj.name === 'ChangeType'
                                });
                                console.log('changetype---- ', changetype[0].value);

                                if (changetype[0].value === 'Cancel' || changetype[0].value === 'Active' || changetype[0].value === 'New' || changetype[0].value === 'Pending') {
                                    //Changes as part of EDGE-154495 start
                                    /*updateMap[config.guid] = [
                                       {
                                           name: "BandwidthDowngradeOC",
                                           value: {
                                               showInUi: false,
                                               displayValue: 0.00,
                                               value: 0.00
                                           }
                                       }
                                   ];*/

                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "BandwidthDowngradeOC",
                                        showInUi: false,
                                        displayValue: 0.00,
                                        value: 0.00
                                    });

                                }
                            }
                            //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then((config) => { console.log('hideDowngradeBandwidthCharge finished: ', config) });
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    currentComponent.lock('Commercial', false);
                                    await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                    //currentComponent.lock('Commercial', true);
                                }
                            }//Changes as part of EDGE-154495 end
                        }//);

                    }
                }
            }//);

        }
    }
    //}).then(() => Promise.resolve(true)
    // );
    return Promise.resolve(true);
}

/**
 * Author      : Aman Soni 2019-10-14
 * Ticket      : EDGE-105060
 * Description : Method to make attributes read only in case of changetype Active
 */
async function SetAttributeReadOnlyForActiveState() {
    //Changes as part of EDGE-154495 start
    let solution = await CS.SM.getActiveSolution();
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //await CS.SM.getActiveSolution().then((solution) => {
    //Changes as part of EDGE-154495 end

    if (solution.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20
            var updateMap = {};
            //Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20
            for (const comp of Object.values(solution.components)) {//EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20
                        //Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20
                        for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20
                                var changetype = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20
                                    return obj.name === 'ChangeType'
                                });
                                console.log('changetype for Active Check---- ', changetype[0].value);

                                if (changetype[0].value === 'Active' || changetype[0].value === 'New' || changetype[0].value === 'Pending') {
                                    //Changes as part of EDGE-154495 start
                                    /*updateMap[config.guid] = [{
                                        name: "Widefeas Code",
                                        value: {
                                            showInUi: false,
                                            required: false
                                        }
                                    },
                                    {
                                        name: "SelectZone",
                                        value: {
                                            readOnly: true
                                        }
                                    },
                                    {
                                        name: "ChangeType",
                                        value: {
                                            showInUi: true,
                                            required: true
                                        }
                                    }, {
                                        name: "ServiceabilityLocation",
                                        value: {
                                            readOnly: true
                                        }
                                    }, {
                                        name: "FibreAvailabilityStatus",
                                        value: {
                                            readOnly: true
                                        }
                                    }, {
                                        name: "AccessTechnology",
                                        value: {
                                            readOnly: true
                                        }
                                    }, {
                                        name: "RemainingTerm",
                                        value: {
                                            showInUi: true,
                                            readOnly: true
                                        }
                                    },
                                    {
                                        name: "IPAccessConfiguration",
                                        value: {
                                            readOnly: true
                                        }
                                    },
                                    {
                                            name: "FeasibilityExpiryDate",
                                            value: {
                                                readOnly: true
                                            }
                                        },
                                        {
                                            name: "Contract Term",
                                            value: {
                                                readOnly: true
                                            }
                                        },
 
                                    {
                                        name: "Bandwidth",
                                        value: {
                                            showInUi: true,
                                            readOnly: true
                                        }
                                    }];*/

                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "Widefeas Code",
                                        showInUi: false,
                                        required: false
                                    },
                                        {
                                            name: "SelectZone",
                                            readOnly: true
                                        },
                                        {
                                            name: "ChangeType",
                                            showInUi: true,
                                            required: true
                                        }, {
                                        name: "ServiceabilityLocation",
                                        readOnly: true
                                    }, {
                                        name: "FibreAvailabilityStatus",
                                        readOnly: true
                                    }, {
                                        name: "AccessTechnology",
                                        readOnly: true
                                    }, {
                                        name: "RemainingTerm",
                                        showInUi: true,
                                        readOnly: true
                                    },
                                        {
                                            name: "IPAccessConfiguration",
                                            readOnly: true
                                        },
                                        {
                                            name: "FeasibilityExpiryDate",
                                            readOnly: true
                                        },
                                        {
                                            name: "Contract Term",
                                            readOnly: true
                                        },

                                        {
                                            name: "Bandwidth",
                                            showInUi: true,
                                            readOnly: true
                                        });
                                }
                            }
                            //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then((config) => { console.log('SetAttributeReadOnlyForActiveState finished: ', config) });
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }//Changes as part of EDGE-154495 end
                        }//);

                    }
                }
            }//);

        }
    }
    //}).then(() => Promise.resolve(true)
    //);
    return Promise.resolve(true);
}

/**
 * Author      : Aman Soni 2019-10-14
 * Ticket      : EDGE-113848
 * Description : Method to show Bandwidth downgrade charge on UI by comparing previous bandwidth to new bandwidth after save
 */
async function showDowngradeBandwidthChargeOnAttSave() {
    //Changes as part of EDGE-154495 start
    let solution = await CS.SM.getActiveSolution();
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //await CS.SM.getActiveSolution().then((solution) => {
    //Changes as part of EDGE-154495 end
    if (solution.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495
            var updateMap = {};
            //Object.values(solution.components).forEach((comp) => {//EDGE-154495
            for (const comp of Object.values(solution.components)) {//EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                        // Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                        for (const config of Object.values(comp.schema.configurations)) {//EDGE-154495
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495
                                var previousBandwidthWeight = Object.values(config.attributes).filter(obj => {//EDGE-154495
                                    return obj.name === 'PreviousBandwidthWeight'
                                });
                                var bandwidthWeight = Object.values(config.attributes).filter(obj => {//EDGE-154495
                                    return obj.name === 'BandwidthWeight'
                                });
                                bandwidthWeightInt = parseInt(bandwidthWeight[0].value);
                                console.log('bandwidthWeightInt---- ', bandwidthWeightInt);
                                previousBandwidthWeightInt = parseInt(previousBandwidthWeight[0].value);
                                console.log('previousBandwidthWeightInt---- ', previousBandwidthWeightInt);

                                if (previousBandwidthWeightInt > bandwidthWeightInt) {
                                    console.log('INSIDE IF Current band----', bandwidthWeight[0].value);
                                    console.log('INSIDE IF Previous band----', previousBandwidthWeight[0].value);
                                    //Changes as part of EDGE-154495 start
                                    /*updateMap[config.guid] = [{
                                        name: "BandwidthDowngradeOC",
                                        value: {
                                            showInUi: true,
                                            displayValue: bandwidthDownGradeChrg,
                                            value: bandwidthDownGradeChrg
                                        }
                                    }];*/

                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "BandwidthDowngradeOC",
                                        showInUi: true,
                                        displayValue: bandwidthDownGradeChrg,
                                        value: bandwidthDownGradeChrg
                                    });
                                    //Changes as part of EDGE-154495 end
                                }
                                else if (previousBandwidthWeightInt <= bandwidthWeightInt) {
                                    console.log('INSIDE ELSE Current band----', bandwidthWeight[0].value);
                                    console.log('INSIDE ELSE Previous band----', previousBandwidthWeight[0].value);
                                    //Changes as part of EDGE-154495 start
                                    /*updateMap[config.guid] = [{
                                        name: "BandwidthDowngradeOC",
                                        value: {
                                            showInUi: false
                                        }
                                    }];*/

                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "BandwidthDowngradeOC",
                                        showInUi: false
                                    });
                                }
                            }
                            //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then((config) => { console.log('showDowngradeBandwidthChargeOnAttSave finished: ', config) });
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }
                            //Changes as part of EDGE-154495 end
                        }//);

                    }
                }
            }//);

        }
    }
    //}).then(() => Promise.resolve(true)
    //);
    return Promise.resolve(true);
}



/**
 * Author      : Aman Soni 2019-11-04
 * Ticket      : EDGE-105060
 * Description : Method to make Widefeas Code hidden for ChangeType Modify and Cancel
 */
async function updateWidefeasCodeReadonlyValueForMACDModifyTID(guid) {//Made it async
    console.log('updateWidefeasCodeReadonlyValueForMACDModifyTID');
    //Changes as part of EDGE-154495 start
    let solution = await CS.SM.getActiveSolution();
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //CS.SM.getActiveSolution().then((solution) => {
    //Changes as part of EDGE-154495 end
    if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes 
            //Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes 
            for (const comp of Object.values(solution.components)) {//EDGE-154495
                var doUpdate = false;
                var updateMap = {};
                //updateMap[guid] = [];//check//EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes 
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes 
                            if (config.guid === guid && config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20 changes 

                                var wcAtrtribute = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes 
                                    return obj.name === 'Widefeas Code'
                                });

                                if (wcAtrtribute && wcAtrtribute.length > 0) {
                                    doUpdate = true;
                                    var isReadOnly = false;
                                    if (wcAtrtribute[0].value)
                                        isReadOnly = true;
                                    //Changes as part of EDGE-154495 start
                                    /*updateMap[config.guid] = [
                                        {
                                            name: wcAtrtribute[0].name,
                                            value: {
                                                readOnly: isReadOnly,
                                                showInUi: false,
                                                required: false
                                            }
                                        }];*/

                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: wcAtrtribute[0].name,
                                        vreadOnly: isReadOnly,
                                        showInUi: false,
                                        required: false
                                    });
                                }
                            }
                        });
                    }
                }
                if (doUpdate) {
                    //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true).then(component => console.log('updateWidefeasCodeReadonlyValueForMACDModifyTID:', component));
                    //Changes as part of EDGE-155255 start
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                    }//Changes as part of EDGE-154495 end
                }
            }//);
        }
    }
    //}).then(
    //() => 
    return Promise.resolve(true)
    //);
}

/**
 * Author      : Laxmi Rahate 2019-09-24
 * Ticket      : EDGE-98282
 * Description : Method to calculate Remaining Term
 */

async function updateRemainingTermAfterSolutionLoadTID() {//Made it async -EDGE-154495
    console.log('inside updateRemainingTermAfterSolutionLoadTID----');
    //Changes as part of EDGE-154495 start
    let solution = await CS.SM.getActiveSolution();
    //let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.solution);
    //CS.SM.getActiveSolution().then((solution) => {
    //Changes as part of EDGE-154495 end
    if (solution.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495

            Object.values(solution.components).forEach((comp) => {//EDGE-154495
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {

                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495
                        Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495
                                var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {//EDGE-154495
                                    return obj.name === 'ChangeType'
                                });
                                var contractTermObj = Object.values(config.attributes).filter(obj => {//EDGE-154495
                                    return obj.name === 'Contract Term'
                                });
                                var contractTerm = contractTermObj[0].value;
                                console.log('contractTerm --------------' + contractTerm);
                                if (changeTypeAtrtribute[0].value === 'Modify' || changeTypeAtrtribute[0].value === 'Cancel' || changeTypeAtrtribute[0].value === 'Active') {
                                    remainingTermTID(config, contractTerm, config.guid);
                                }
                            }

                        });

                    }
                }
            });

        }
    }
    //}).then(
    //() => Promise.resolve(true)
    // );
    return Promise.resolve(true);
}


async function remainingTermTID(config, contractTerm, configId) {//Made it async EDGE-154495

    console.log('remainingTermTID--->1150');
    /**var changeTypeAtrtribute = config.attributes.filter(obj => {
                                return obj.name === 'ChangeType'
                                                            });**/
    var remainingTerm = 0;
    var updateRemainingTermMap = {};
    if (contractTerm != 0) {
        let inputMap = {};
        var originalDiscount = 0;
        inputMap['getServiceForMAC'] = config.id;

        //Changes as part of EDGE-154495 start
        let currentBasket = await CS.SM.getActiveBasket();
        let solution = await CS.SM.getActiveSolution();
        let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.internetSite);
        //Changes as part of EDGE-154495 end

        console.log('remainingTermTID :: inputMap :: ', inputMap);
        //CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {//EDGE-154495
        currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(async result => {//EDGE-154495
            console.log('remainingTermTID:-------- ', result);
            var serviceStartDateString = result["getServiceForMAC"];
            if (serviceStartDateString) {
                console.log('remainingTermTID');
                var serviceStartDate = new Date(JSON.parse(serviceStartDateString));
                console.log('serviceStartDate: ', serviceStartDate);
                var oneDay = 24 * 60 * 60 * 1000;
                var today = new Date();
                today.setHours(0, 0, 0, 0);
                serviceStartDate.setHours(0, 0, 0, 0);
                if (serviceStartDateString === 'Invalid Date') {
                    remainingTerm = 0;
                }
                var remainingTerm = Math.ceil((contractTerm * 30 - ((today - serviceStartDate) / oneDay)) / 30);
                console.log('remainingTerm: ', remainingTerm);
                var remTerm = parseInt(remainingTerm);
                if (isNaN(remTerm)) {
                    remainingTerm = 0;
                }

                if (remainingTerm < 0 || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm === "null") {
                    remainingTerm = 0;
                }
                if (remainingTerm <= 0 || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm === "null") {

                    console.log('remainingTermTID If---');
                    //Changes as part of EDGE-154495 start
                    /*updateRemainingTermMap[config.guid] = [{
                        name: "RemainingTerm",
                        value: {
                            value: remainingTerm,
                            showInUi: false,
                            readOnly: true,
                            displayValue: remainingTerm
                        }
                    }
                        // 93656 Defect 20/8/19  ends
                    ];*/

                    updateRemainingTermMap[config.guid] = [];
                    updateRemainingTermMap[config.guid].push({
                        name: "RemainingTerm",
                        value: remainingTerm,
                        showInUi: false,
                        readOnly: true,
                        displayValue: remainingTerm
                    });

                }
                else {
                    console.log('remainingTermTID Else---');
                    /*updateRemainingTermMap[config.guid] = [{
                        name: "RemainingTerm",
                        value: {
                            value: remainingTerm,
                            showInUi: true,
                            readOnly: true,
                            displayValue: remainingTerm
                        }
                    }
                    ];*/

                    updateRemainingTermMap[config.guid] = [];
                    updateRemainingTermMap[config.guid].push({
                        name: "RemainingTerm",
                        value: remainingTerm,
                        showInUi: true,
                        readOnly: true,
                        displayValue: remainingTerm
                    });

                    //Changes as part of EDGE-154495 end
                    console.log('remainingTermTID :: updateRemainingTermMap :: Show in UI is true', updateRemainingTermMap);

                }
                console.log('remainingTermTID :: updateRemainingTermMap :: ', updateRemainingTermMap);


            }
            else {
                console.log('remainingTermTID Else IF Else---');
                //Changes as part of EDGE-154495 start
                /*updateRemainingTermMap[config.guid] = [{
                    name: 'RemainingTerm',
                    value: {
                        showInUi: true,
                        value: 0,
                        displayValue: 0
                    }
                }];*/

                updateRemainingTermMap[config.guid] = [];
                updateRemainingTermMap[config.guid].push({
                    name: "RemainingTerm",
                    showInUi: true,
                    value: 0,
                    displayValue: 0
                });
            }
            //CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.internetSite, updateRemainingTermMap, false);
            if (updateRemainingTermMap && Object.keys(updateRemainingTermMap).length > 0) {
                if (updateRemainingTermMap && Object.keys(updateRemainingTermMap).length > 0) {
                    keys = Object.keys(updateRemainingTermMap);
                    for (let i = 0; i < keys.length; i++) {
                        await currentComponent.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], false);
                    }
                }
            }
            //Changes as part of EDGE-154495 end
        })//.then(() => return Promise.resolve(true);
        return Promise.resolve(true);
    }
}


/*****************************************************************************************************
 * Author	   : Sandip Deshmane
 * Method Name : updateEtcVisibility
 * Invoked When: Solution is added to MACBasket and Change Type to Cancel
 * Description : Set attributes to True when Product is added to Mac Basket.
 * Parameters  : guid
 ****************************************************************************************************/
async function updateEtcVisibility(guid) {//Made the function async -EDGE-154495
    console.log('updateEtcVisibility');
    //Changes as part of EDGE-154495 start
    let solution = await CS.SM.getActiveSolution();
    let currentComponent = solution.getComponentByName(TID_COMPONENT_NAMES.internetSite);
    //CS.SM.getActiveSolution().then((solution) => {
    console.log('Active Solution from updateEtcvisibility', solution);
    if (solution && solution.name.includes(TID_COMPONENT_NAMES.solution)) {//changed solution.type to solution
        if (solution.components && Object.values(solution.components).length > 0) {//EDGE-154495 Spring 20 changes
            var setChangeType = '';
            var updateMap = {};
            Object.values(solution.components).forEach((comp) => {//EDGE-154495 Spring 20 changes
                if (comp.name === TID_COMPONENT_NAMES.internetSite && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {//EDGE-154495 Spring 20 changes
                    Object.values(comp.schema.configurations).forEach((config) => {//EDGE-154495 Spring 20 changes
                        if (!guid || guid === config.guid) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {//EDGE-154495 Spring 20 changes

                                var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes
                                    return obj.name === 'ChangeType'
                                });

                                var ETCAtrtribute = Object.values(config.attributes).filter(obj => {//EDGE-154495 Spring 20 changes
                                    return obj.name === 'EarlyTerminationCharge'
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
                                        name: 'ETCWaiver',
                                        //value: {//EDGE-154495 Spring 20 changes
                                        showInUi: visibleEtc
                                        //}//EDGE-154495 Spring 20 changes
                                    });

                                    var etcVal = { showInUi: visibleEtc };
                                    if (ETCAtrtribute && ETCAtrtribute.length > 0 && ETCAtrtribute[0].value) {
                                        etcVal.value = ETCAtrtribute[0].value;
                                    } else {
                                        etcVal.value = 0;
                                    }

                                    updateMap[config.guid].push({
                                        name: 'EarlyTerminationCharge',
                                        value: etcVal,
                                        readOnly: true
                                    });

                                    updateMap[config.guid].push({
                                        name: 'CaseNumber',
                                        //value: {//EDGE-154495 Spring 20 changes
                                        showInUi: visible
                                        //}//EDGE-154495 Spring 20 changes
                                    });

                                }
                            }
                        }
                    });
                }
            });
            console.log('updateEtcVisibility - updating: ', updateMap);
            //Changes as part of EDGE-154495 start
            //CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.internetSite, updateMap, true).then(component => console.log('updateEtcVisibility Attribute Update', component));
            if (updateMap && Object.keys(updateMap).length > 0) {
                keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await currentComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
            //Changes as part of EDGE-154495 end
        }
    }
    //}).then(
    //() => 
    return Promise.resolve(true)
    // );
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
async function validateWFCodeFormat(guid, attrValue, isRequired, componentName) {
    var validFormat = /^(WF-[0-9]{6})$/;
    //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
    let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.internetSite);//Pooja
    console.log('validateWFCodeFormat', guid, attrValue, isRequired, componentName);
    //if (product.type && (product.name.includes(COMPONENT_NAMES.solution) || product.name.includes(TID_COMPONENT_NAMES.solution))) {
    if (product.type && product.name.includes(TID_COMPONENT_NAMES.solution)) {
        var statusMsg;
        if (product.components && Object.values(product.components).length > 0) {
            Object.values(product.components).forEach((comp) => {
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    console.log('IP Site while updating Wifefeas Code', comp);
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        Object.values(comp.schema.configurations).forEach((ipSiteConfig) => {
                            //if (ipSiteConfig.relatedProductList && ipSiteConfig.relatedProductList.length > 0) {
                            //ipSiteConfig.relatedProductList.forEach((relatedConfig) => {
                            //if (relatedConfig.name === 'User' && relatedConfig.type === 'Related Component' && relatedConfig.guid === guid) {
                            statusMsg = ipSiteConfig.statusMessage;
                            // }
                            // });
                            //}
                        });
                    }
                }
            });
        }
        statusMsg = statusMsg ? statusMsg : '';
        //var compname = (componentName === TID_COMPONENT_NAMES.internetSite) ? TID_COMPONENT_NAMES.internetSite : TID_COMPONENT_NAMES.internetSite;//Pooja
        let config = await currentComponent.getConfiguration(guid);
        if (attrValue) {
            if (validFormat.test(attrValue)) {
                //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, true, statusMsg).then(configuration => console.log(configuration));
                //updateConfigurationStatus('IPSITE_WF_VALIDATION', compname, guid, true, '');
                config.status = true;
                config.statusMessage = '';
            }
            else {
                //statusMsg = statusMsg ? statusMsg + ',\n' + 'Enter the Widefeas Code in the format WF-000000' : 'Enter the Widefeas Code in the format WF-000000';
                //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, false, statusMsg).then(configuration => console.log(configuration));
                //updateConfigurationStatus('IPSITE_WF_VALIDATION', compname, guid, false, 'Enter the Widefeas Code in the format WF-000000');
                config.status = false;
                config.statusMessage = 'Enter the Widefeas Code in the format WF-000000';
            }
        } else {
            //CS.SM.updateConfigurationStatus(COMPONENT_NAMES.ipSite, guid, true, statusMsg).then(configuration => console.log(configuration));
            // updateConfigurationStatus('IPSITE_WF_VALIDATION', compname, guid, true, '');
            config.status = true;
            config.statusMessage = '';
        }
    }
    // }).then(
    //     () => Promise.resolve(true)
    // );
    return Promise.resolve(true);
}

/**
 * Author      : Venkat
 * Ticket      : 
 * Description : Method to default contract term attribute when AccessTechnology is not Direct Fibre over NBN
 */
async function defaultContracttermTID(compname, guid, attr) {//Made it async
    //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
    let Component = product.getComponentByName(TID_COMPONENT_NAMES.solution);
    if (product.type && product.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (product.components && Object.values(product.components).length > 0) {//Pooja

            var validcomp = Object.values(product.components).filter(comp => {//Pooja
                return comp.name === compname
            });
            if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {//Pooja
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(config => {//Pooja
                    return config.guid === guid
                });
            }
            if (validconfig && Object.values(validconfig[0].attributes)) {//Pooja
                //var updateMap = [];
                let updateMap = {};
                // if (compname === TID_COMPONENT_NAMES.internetSite && attr === 'AccessTechnology'){
                /*updateMap[validconfig[0].guid] = [{
                    name: "Contract Term",
                    value: {
                        value: '36'
                    }
                }];*/

                updateMap[validconfig[0].guid] = [];
                updateMap[validconfig[0].guid].push({
                    name: "Contract Term",
                    value: '36'
                });
            }
            //CS.SM.updateConfigurationAttribute(compname, updateMap, true);
            if (updateMap && Object.keys(updateMap).length > 0) {
                keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await Component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }

        }
    }
    //});
    return Promise.resolve(true);//Pooja
}

/**
 * Author      : Aman Soni
 * Ticket      : EDGE-98299
 * Description : Method to blank zone attributes when AccessTechnology is null
 */
async function emptyZoneAttributesTID(compname, guid, attr) {//Made it async
    //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
    let Component = product.getComponentByName(TID_COMPONENT_NAMES.solution);
    if (product.type && product.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (product.components && Object.values(product.components).length > 0) {//pooja

            var validcomp = Object.values(product.components).filter(comp => {//pooja
                return comp.name === compname
            });
            if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {//pooja
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(config => {//pooja
                    return config.guid === guid
                });
            }
            if (validconfig && Object.values(validconfig[0].attributes)) {//pooja
                //var updateMap = [];
                let updateMap = {};
                if (compname === TID_COMPONENT_NAMES.internetSite && attr === 'AccessTechnology') {
                    /*updateMap[validconfig[0].guid] = [{
                        name: "SelectZone",
                        value: {
                            value: ''
                        }
                    }, {
                        name: "ServiceabilityLocation",
                        value: {
                            value: ''
                        }
                    }, {
                        name: "ESACode",
                        value: {
                            value: ''
                        }
                    }, {
                        name: "Bandwidth",
                        value: {
                            value: ''
                        }
                    }];*/

                    updateMap[validconfig[0].guid] = [];
                    updateMap[validconfig[0].guid].push({
                        name: "SelectZone",
                        value: ''
                    }, {
                        name: "ServiceabilityLocation",
                        value: ''
                    }, {
                        name: "ESACode",
                        value: ''
                    }, {
                        name: "Bandwidth",
                        value: ''
                    });
                }
                // CS.SM.updateConfigurationAttribute(compname, updateMap, true);
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await Component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                }

            }
        }
    }
    //});
    return Promise.resolve(true);//Pooja
}

/*****************************************************************************************************
 * Author	   : Laxmi 
 * Method Name : validateFeasibilityDate
 * Invoked When: attribute Update for FeasibilityExpiryDate
 * Description : FeasibilityExpiryDate should be greater than FeasibilityDays
 * Parameters  : guid
 ****************************************************************************************************/

async function validateFeasibilityDate(guid) {//Made it async
    console.log('validateFeasibilityDate');
    //var configUpdateMap = {};
    let configUpdateMap = {};

    //CS.SM.getActiveSolution().then((solution) => {
    let solution = await CS.SM.getActiveSolution();
    let Component = solution.getComponentByName(TID_COMPONENT_NAMES.internetSite);
    let confg = await currentComponent.getConfiguration(guid);
    if (solution.type && solution.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (solution.components && Object.values(solution.components).length > 0) {
            // var setChangeType = '';
            // var updateMap = {};
            var feasibilityDateObj = '';
            var feasibilityExpiryLeadDaysObj = 0;
            var feasibilityDate;
            var feasibilityExpiryLeadDays;
            var selectedFeasDate;
            var targetFesDate = new Date();
            var month;
            //solution.components.forEach((comp) => {
            for (const comp of Object.values(solution.components)) {
                if (comp.name === TID_COMPONENT_NAMES.internetSite && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    // Object.values(comp.schema.configurations).forEach((config) => {
                    for (const config of Object.values(comp.schema.configurations)) {
                        if (!guid || guid === config.guid) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {

                                feasibilityDateObj = Object.values(config.attributes).filter(obj => {
                                    return obj.name === 'FeasibilityExpiryDate'
                                });

                                feasibilityExpiryLeadDaysObj = Object.values(config.attributes).filter(obj => {
                                    return obj.name === 'FeasibilityExpiryLeadDays'
                                });

                                feasibilityExpiryLeadDays = feasibilityExpiryLeadDaysObj[0].value;
                                feasibilityDate = feasibilityDateObj[0].value;
                                console.log('feasibilityExpiryLeadDays -----' + feasibilityExpiryLeadDays);
                            }
                            // (YYYY-MM-DD) 

                            // Format selected Feas Date
                            selectedFeasDate = new Date(feasibilityDate);
                            selectedFeasDate.setHours(0, 0, 0, 0);

                            // Get targetFeasDate - todays date + feasibilityExpiryLeadDays
                            targetFesDate.setHours(0, 0, 0, 0);
                            targetFesDate.setDate(targetFesDate.getDate() + parseInt(feasibilityExpiryLeadDays));

                            //console.log ( 'targetFesDate ---------' +targetFesDate.getYear());

                            //console.log ( 'selectedFeasDate ---------' +selectedFeasDate);
                            month = targetFesDate.getMonth() + parseInt('1');
                            if (month < 10) {
                                month = '0' + month;
                            }

                            // var selectFdate = selectedFeasDate.getFullYear() + '-' + selectedFeasDate.getDate() + '-' + selectedFeasDate.getMonth() + parseInt('1');
                            if (selectedFeasDate.getTime() < targetFesDate.getTime()) {
                                console.log('This date must be more than system date + X days (this X day must be configurable)');
                                //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, false, 'Feasibility date must be greater than ' + targetFesDate.getFullYear() + '/' + month + '/' + targetFesDate.getDate() + '   !!');
                                confg.status = false;
                                confg.statusMessage = 'Feasibility date must be greater than ' + targetFesDate.getFullYear() + '/' + month + '/' + targetFesDate.getDate() + '   !!';
                                /*configUpdateMap[guid] = [{
                                    name: "FeasibilityExpiryDate",
                                    value: {
                                        showInUi: true,
                                        required: true,
                                        readonly: false,
                                        displayValue: '',
                                        value: ''
                                    }
                                }];*/
                                configUpdateMap[guid] = [];
                                configUpdateMap[guid].push({
                                    name: "FeasibilityExpiryDate",
                                    showInUi: true,
                                    required: true,
                                    readonly: false,
                                    displayValue: '',
                                    value: ''
                                });
                            } else {
                                /*configUpdateMap[guid] = [{
                                    name: "FeasibilityExpiryDate",
                                    value: {
                                        showInUi: true,
                                        required: true,
                                        readonly: false,
                                        displayValue: Utils.formatDate(selectedFeasDate),
                                        value: Utils.formatDate(selectedFeasDate)
                                    }
                                }];*/

                                configUpdateMap[guid] = [];
                                configUpdateMap[guid].push({
                                    showInUi: true,
                                    required: true,
                                    readonly: false,
                                    displayValue: Utils.formatDate(selectedFeasDate),
                                    value: Utils.formatDate(selectedFeasDate)
                                });
                                //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, true, '');
                                confg.status = true;
                                confg.statusMessage = '';
                                console.log(' Updated value to -------' + Utils.formatDate(selectedFeasDate));
                            }


                            //console.log('updateEtcVisibility - updating: ', updateMap);
                            //CS.SM.updateConfigurationAttribute(TID_COMPONENT_NAMES.internetSite, configUpdateMap, true).then(component => console.log('FeasibilityExpiryDate Attribute Update', component));
                            if (configUpdateMap && Object.keys(configUpdateMap).length > 0) {
                                keys = Object.keys(configUpdateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await Component.updateConfigurationAttribute(keys[i], configUpdateMap[keys[i]], true);
                                }
                            }
                        }
                    }//);
                }
            }//);
        }
    }
    //}).then(
    //() => 
    return Promise.resolve(true);
    //);
}

/*****************************************************************************************************
 * Author	   : Laxmi/Aman Soni
 * Method Name : invokeMicroService
 * Invoked When: attribute Update for Access Technology
 * Description : get the Zone Pattern ID from Charge Zone Object
 * Parameters  : guid
 ****************************************************************************************************/

async function invokeMicroService(guid) {
    //var zonePatternID;
    var contractStartDate;
    var todayTime = new Date();
    var month = todayTime.getMonth() + 1;
    var day;
    day = todayTime.getDate();
    if (todayTime.getDate() < 10) {
        day = '0' + todayTime.getDate();
    }

    if (month < 10) {
        month = '0' + month;
        console.log('month ------------' + month);

    }

    var year = todayTime.getFullYear();
    contractStartDate = year + "-" + month + "-" + day;
    console.log('contractStartDate-----> ', contractStartDate);
    //contractStartDate = '2019-11-08';
    var zoneRental = 0;
    var zoneSLA;

    var adborID;
    var esaCode = '';
    var configUpdateMap = {};
    console.log('invokeMicroService start', guid);

    //CS.SM.getActiveSolution().then((product) => {//Pooja
    let product = await CS.SM.getActiveSolution();//Pooja
    let currentComponent = product.getComponentByName(TID_COMPONENT_NAMES.internetSite);//Pooja
    let currentBasket = await CS.SM.getActiveBasket();//Pooja
    basketId = currentBasket.basketId;//Pooja
    let confg = await currentComponent.getConfiguration(guid);//Pooja
    if (product.type && product.name.includes(TID_COMPONENT_NAMES.solution)) {
        if (product.components && Object.values(product.components).length > 0) {
            //Object.values(product.components).forEach((comp) => {
            for (const comp of Object.values(product.components)) {
                if (comp.name === TID_COMPONENT_NAMES.internetSite) {
                    //Object.values(comp.schema.configurations).forEach((config) => {
                    for (const config of Object.values(comp.schema.configurations)) {
                        if (config.guid === guid) {
                            adborID = Object.values(config.attributes).filter(obj => {
                                return obj.name === 'AdborID'
                            });
                            console.log('Here is teh Adbore ID---------------------' + adborID[0].value);
                            // Now with the help of Adbore ID and the CIDN invoke Remote Action to get the ESA COode
                            let map2 = {};
                            map2['adborID'] = adborID[0].value;
                            map2['cidn'] = cidn;

                            currentBasket.performRemoteAction('SolutionHelperESACode', map2).then(async result => {//Pooja
                                console.log('The ESA Code ', result);
                                var site = result["ESACode"];
                                esaCode = site.cscrm__Installation_Address__r.ESA_Code__c;
                                console.log('GetESACode----> ' + esaCode);
                                //esaCode = '';
                                if (esaCode === '') {
                                    console.log('ESA Code is blank!!----> ');

                                    // CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, false, 'ESA Code is not available for the selected site, please select different Site!!'); //Pooja

                                    confg.status = false;
                                    confg.statusMessage = 'ESA Code is not available for the selected site, please select different Site!!';
                                    return;
                                } else {
                                    //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, true, ''); //Pooja
                                    confg.status = true;
                                    confg.statusMessage = '';
                                }

                                let map3 = {};
                                //esaCode = 'SHLN';	
                                map3['esaCode'] = esaCode;
                                map3['czpId'] = zonePatternID;
                                console.log('zonePatternID 111----> ' + zonePatternID + '   --  ' + map3['czpId']);
                                map3['contractStartDate'] = contractStartDate;
                                console.log('ESA Code----> ' + esaCode);

                                //Call ChargeZoneController to get response against request || Added by Aman Soni Start
                                if (esaCode !== '' && esaCode !== null && contractStartDate !== '' && contractStartDate !== null && zonePatternID !== null && zonePatternID !== '') {
                                    console.log('ESA Code----> ' + esaCode + 'czpId ---->' + zonePatternID + 'contractStartDate' + contractStartDate);
                                    currentBasket.performRemoteAction('ChargeZoneController', map3).then(async result => {//Pooja
                                        console.log('Inside ChargeZoneController: result---->', result);
                                        if (result !== null) {
                                            zoneRental = result["Zone Rental"];
                                            console.log('zoneRental----> ', zoneRental);
                                            zoneSLA = result["Zone SLA"];
                                            console.log('zoneSLA----> ', zoneSLA);

                                            if (zoneRental === '') {
                                                zoneRental = '';
                                                //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, false, ' Rental Zone and Service Ability Location not foud for selected Site, Please select another site');

                                                confg.status = false;
                                                confg.statusMessage = 'Rental Zone and Service Ability Location not foud for selected Site, Please select another site';
                                                return;
                                            }
                                            else {

                                                //CS.SM.updateConfigurationStatus(TID_COMPONENT_NAMES.internetSite, guid, false, '');
                                                confg.status = false;
                                                confg.statusMessage = '';
                                            }
                                            //zoneSLA = 'Urban'
                                            //zoneRental =1;

                                            /*configUpdateMap = {};
                                            configUpdateMap[config.guid] = [{
                                                name: "ESACode",
                                                value: {
                                                    showInUi: false,
                                                    required: false,
                                                    readonly: true,
                                                    displayValue: esaCode,
                                                    value: esaCode
                                                }
                                            }, {
                                                name: "SelectZone",
                                                value: {
                                                    showInUi: true,
                                                    required: false,
                                                    readonly: true,
                                                    value: zoneRental
                                                }
                                            }, {
                                                name: "ServiceabilityLocation",
                                                value: {
                                                    showInUi: true,
                                                    required: false,
                                                    readonly: true,
                                                    value: zoneSLA
                                                }
                                            }];*/

                                            configUpdateMap[config.guid] = [];
                                            configUpdateMap[config.guid].push({
                                                name: "ESACode",
                                                showInUi: false,
                                                required: false,
                                                readonly: true,
                                                displayValue: esaCode,
                                                value: esaCode
                                            }, {
                                                name: "SelectZone",
                                                showInUi: true,
                                                required: false,
                                                readonly: true,
                                                value: zoneRental
                                            }, {
                                                name: "ServiceabilityLocation",
                                                showInUi: true,
                                                required: false,
                                                readonly: true,
                                                value: zoneSLA
                                            });
                                            //CS.SM.updateConfigurationAttribute(comp.name, configUpdateMap, true);
                                            if (configUpdateMap && Object.keys(configUpdateMap).length > 0) {
                                                keys = Object.keys(configUpdateMap);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await currentComponent.updateConfigurationAttribute(keys[i], configUpdateMap[keys[i]], true);
                                                }
                                            }
                                            console.log('invokeMicroService end ---', configUpdateMap);
                                        }
                                    }); // Charge Zone Controller
                                }
                            }); // ESA Code Remote Action
                        }
                    }//);
                }
            }//);
        }
    }
    //});
    //}).then(() => 
    return Promise.resolve(true);
}
