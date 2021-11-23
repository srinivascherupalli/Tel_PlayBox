/******************************************************************************************
* Author	   : DPG Neon
Change Version History
Version No	Author 			        Date

1 			Aditeyn                 Dec 2019          Created File for IOT 
2           Suyash Chiplunkar       01-03-2020        Cancel Flow for IOT DPG-970
3           Suyash Chiplunkar       23-04-2020        Shared Data Plan for IOT DPG-1132
4           Aruna Aware             23-04-2020        Added functionality for EDMListToDecompose attribute DPG-1132
5           Aruna Aware             05-05-2020        Added for bulk enrichment DPG-1692 & DPG-1723
6           Suyash Chiplunkar       20-05-2020        Added logic for Modify MAC DPG-1779
7           Anand Shekhar           20-05-2020        Added logic for DPG-1784 and DPG-1787
8           Sukul Mongia            25-06-2020        Spring 20 Upgrade
9           Suyash Chiplunkar       01-07-2020        Added logic for DPG-1964 Rate Card Matrix
10			Aruna Aware				16-07-2020		  Added logic for DPG-2130 Consistent use of the word "IoT" in Sales screens
11			Aruna Aware				16-07-2020		  Added logic for DPG-2131 Solution Name Validation for IoT
12 			Gnana & Aditya			19-Jul-2020		  Spring'20 Upgrade
13          Suyash Chiplunkar       01-Sep-2020       DPG-2620 - Add & configure the Digital Water Metering offer to basket
*****************************************************************************************/
// Aruna Aware : Added logic for DPG-2130 Consistent use of the word "IoT" in Sales screens
var IOTMobility_COMPONENTS = {
    solution: 'IoT solutions',
    IOTSubscription: 'IoT Subscription',
    solutionNonEditableAttributeListForCancel: ['OfferName', 'OfferType'],
    subscriptionNonEditableAttributeListForCancel: ['SelectPlanType', 'Select Plan'],
    hidesubscriptionHideFieldsForCancel: ['SIM Type', 'OC'],
    showSubscriptionFieldsForCancel: ['EarlyTerminationCharge'],
    comittedDataSolutionEditableFields: ['SharedPlan'],
    comittedDataSolutionNonEditableFields: ['PlanAllowanceValue', 'RC'],
    annualDataPlanSubscriptionFields: ['MaintenanceRC', 'RC'],//Changes related to DPG-2620 Start
};
var basketStage = null;
var communitySiteId;
var allowSaveIOT = false;
var executeSaveIOT = false;
var sharedDataPlan = 'Shared Data';
var DEFAULTSOLUTIONNAME_IoT = 'IoT solutions'; // Added logic for DPG-2131 Solution Name Validation for IoT
// Arinjay Register Plugin
var currentSolution;
if (CS.SM.registerPlugin) {
    console.log('Load IOT plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () {
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('IoT solutions')
            .then(async IOTPlugin => {
                // For Hooks
                IOTPlugin_updatePlugin(IOTPlugin);
            });
    });
}

async function IOTPlugin_updatePlugin(IOTPlugin) {

    console.log('Adding Hooks to IOTPlugin');

    // Arinjay - Kept intact from pervious version 
    document.addEventListener('click', function (e) {
        e = e || window.event;
        var target = e.target || e.srcElement;
        var text = target.textContent || target.innerText;
        //console.log("Clicked on ", text);

        if (text && text.toLowerCase() === 'iot subscription') {
            if (basketStage === 'Contract Accepted') {
                Utils.updateComponentLevelButtonVisibility('Add IoT Subscription', false, true);
            }
            Utils.updateCustomButtonVisibilityForBasketStage();
        }

        if (text && text.toLowerCase().includes('stage')) {
            Utils.updateCustomButtonVisibilityForBasketStage();
            if (basketStage === 'Contract Accepted') {
                Utils.updateComponentLevelButtonVisibility('Add IoT Subscription', false, true);
            }
        }
        if (text) {
            Utils.updateOEConsoleButtonVisibility();
        }

        //console.log("Clicked on ", currentSolution.name);
        //var currentSolutionName = currentSolution.name;

        if (currentSolutionName === 'IoT solutions') {
            var buttons = document.getElementsByClassName('slds-file-selector__dropzone');
            var vertDropDownButton = document.getElementsByClassName('cs-btn');
            if (buttons) {
                for (var i = 0; i < buttons.length; i++) {
                    var button = buttons[i];
                    button.style.display = "none";
                }
            }
            if (vertDropDownButton) {
                for (var i = 0; i < vertDropDownButton.length; i++) {
                    var vbutton = vertDropDownButton[i];
                    if (vbutton.innerText.toLowerCase() === 'order enrichment')
                        vbutton.style.display = "none";
                    else
                        vbutton.style.display = "compact";
                }
            }
        }

    }, false);

    setInterval(saveSolutionIOT, 500);
    //Added logic for DPG-1964
    Utils.updateCustomAttributeLinkText('Rate Card', 'View');

    // Arinjay - Hook
    //IOTPlugin.afterSolutionLoaded = async function(previousSolution, loadedSolution) {
    window.document.addEventListener('SolutionSetActive', async function (e) {
        let loadedSolution = await CS.SM.getActiveSolution();
        if (loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            console.log('SolutionSetActive', e);
            console.log('Testing Component fetching via config ');
            //let solution1 = await CS.SM.getActiveSolution();
            let solution1 = loadedSolution
            if (solution1.componentType && solution1.name.includes(IOTMobility_COMPONENTS.solution)) {
                Object.values(solution1.components).forEach((comp) => {
                    console.log(comp);
                    console.log('Component name ' + Object.values(comp.schema.configurations));
                    Object.values(comp.schema.configurations).forEach((config) => {
                        console.log('Config', config);
                    });
                });
                let component1 = await solution1.getComponentByName('Broadsofttenancy');
                console.log('Component ', component1);

                let solutionManager;
                let currentBasket;

                let basketId = e.detail.solution.basketId;
                console.log('basket id is ' + basketId);


                currentBasket = await CS.SM.loadBasket(basketId);
                //Added logic for DPG-1964
                Utils.updateCustomAttributeLinkText('Rate Card', 'View');
                console.log('current basket id is ' + currentBasket.basketId);
                let inputMap = {};
                inputMap['GetBasket'] = basketId;

                await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                    console.log('GetBasket finished with response: ', result);
                    var basket = JSON.parse(result["GetBasket"]);
                    console.log('GetBasket: ', basket);
                    basketChangeType = basket.csordtelcoa__Change_Type__c;
                    basketStage = basket.csordtelcoa__Basket_Stage__c;
                    accountId = basket.csbb__Account__c;
                    console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId);
                    window.oeSetBasketData(basketId, basketStage, accountId);
                    // Added for DPG-1784
                    // if (accountId != null) {
                    //     console.log('DOP_COMPONENT_NAMES.solution-->' + IOTMobility_COMPONENTS.solution);
                    //     CommonUtills.setAccountID(IOTMobility_COMPONENTS.solution, accountId);
                    // }
                    // Added for DPG-1692 & DPG-1723 bulk enrichment
                    //await addDefaultIOTConfigs();
                });

                if (window.basketStage === 'Contract Accepted'){
                    loadedSolution.lock('Commercial',false);
                }

                await addDefaultIOTConfigs();
                if (window.accountId != null) {
                    console.log('DOP_COMPONENT_NAMES.solution-->' + IOTMobility_COMPONENTS.solution);
                    await CommonUtills.setAccountID(IOTMobility_COMPONENTS.solution, accountId);
                }

                Utils.loadSMOptions();
                Utils.updateOEConsoleButtonVisibility();
                await checkConfigurationSubscriptionsForIOT();

                await IOTPlugin.updateChangeTypeAttribute();

                //Added for Cancel Story DPG-970
                if (basketChangeType === 'Change Solution') {
                    await IOTPlugin.updateStatusAfterSolutionLoad();
                    await IOTPlugin.UpdateMainSolutionChangeTypeVisibility(loadedSolution);
                    //Hide Fields of Subscription
                    await IOTPlugin.UpdateAttributesForSubscription(loadedSolution);
                }
                //Added for Shared Data Plan DPG-1132
                // Added for making BillingAccount ReadOnly in MACD Journey(Added by Pravin) DPG-1787
                await IOTPlugin.UpdateAttributesForSharedDataPlan(loadedSolution);

                //Billing Account DPG-1787
                var solutionComponent = false;
                var componentMap = new Map();
                var componentMapattr = {};
                //if (loadedSolution.type && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
                if (loadedSolution.componentType && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
                    //if (loadedSolution.schema.configurations[0].replacedConfigId && loadedSolution.schema.configurations[0].replacedConfigId !== null) {
                    if (Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
                        solutionComponent = true;
                        let config = Object.values(loadedSolution.schema.configurations)[0];
                        //var billingAccLook = loadedSolution.schema.configurations[0].attributes.filter(a => {
                        var billingAccLook = Object.values(config.attributes).filter(a => {
                            return a.name === 'BillingAccountLookup'
                        });
                        if (billingAccLook[0].value === null || billingAccLook[0].value === '') {
                            CommonUtills.setSubBillingAccountNumberOnCLI(IOTMobility_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                        }
                        componentMapattr['BillingAccountLookup'] = [];
                        componentMapattr['BillingAccountLookup'].push({
                            'IsreadOnly': true,
                            'isVisible': true,
                            'isRequired': true
                        });
                        //componentMap.set(loadedSolution.schema.configurations[0].guid, componentMapattr);
                        componentMap.set(config.guid, componentMapattr);
                        CommonUtills.attrVisiblityControl(IOTMobility_COMPONENTS.solution, componentMap);
                    }
                    /*if(loadedSolution.components && loadedSolution.components.length > 0){
                        loadedSolution.components.forEach((comp) => {
                        solutionComponent = false;
                        if(comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0){
                            comp.schema.configurations.forEach((config) => {
                            if(config.replacedConfigId !== null){
                            CommonUtills.setSubBillingAccountNumberOnCLI(IOTMobility_COMPONENTS.IOTSubscription,'initialActivationDate',solutionComponent);
                            CommonUtills.setSubBillingAccountNumberOnCLI(IOTMobility_COMPONENTS.IOTSubscription,'BillingAccountNumber',solutionComponent);
                            }
                            });
                        }
                        });
                    }*/
                }
                //Billing Account End DPG-1787					
                //changes end by Pravin
                //Added logic for DPG-1964 
                await IOTPlugin.updateRateCardAttribute(loadedSolution);

                if (window.basketStage === 'Contract Accepted'){
                    loadedSolution.lock('Commercial',true);
                }
            }
        }
        return Promise.resolve(true);
    });
    //}

    IOTPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {

        let loadedSolution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            loadedSolution.lock('Commercial',false);
        }

        //Added for Cancel Story DPG-970
        if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
            IOTPlugin.UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
        }
        /*
                  //spring 20 upgrade start
                 if(basketStage === 'Contract Accepted'){
                    await updateEDMListToDecomposeattributeForIOTSolution(solution);
                    await updateEDMListToDecomposeattributeIOT(solution); //Aruna added to call to update the EDMListToDecompose attribute
               
                  //spring 20 upgrade end
        */

        //Added for Shared Data Plan DPG-1132
        if (component.name === IOTMobility_COMPONENTS.solution && attribute.name === 'OfferType') {
            Utils.emptyValueOfAttribute(configuration.guid, component.name, 'PlanAllowance', true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, 'PlanAllowanceValue', true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, 'RC', true);
            Utils.emptyValueOfAttribute(configuration.guid, component.name, 'SharedPlan', true);
            //Added logic for DPG-1964
            if (attribute.displayValue != null || attribute.displayValue != '') {
                // CS.SM.getActiveSolution().then((product) => {
                //     IOTPlugin.updateRateCardAttribute(product); 
                // });
                //IOTPlugin.updateRateCardAttribute(product); 
                await IOTPlugin.updateAttributeVisiblity(['IoTRateCardButton'], IOTMobility_COMPONENTS.solution, configuration.guid, false, true, false);
                Utils.updateCustomAttributeLinkText('Rate Card', 'View');
            } else {
                await IOTPlugin.updateAttributeVisiblity(['IoTRateCardButton'], IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
            }

            if (attribute.displayValue === sharedDataPlan) {
                console.log('Is comitted');
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, true, false);
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, true, true, false);
            } else {
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, configuration.guid, false, false, false);
            }
            await updateSolutionNameIoT();//Spring 20' upgrade
        }

        if (component.name === IOTMobility_COMPONENTS.solution && attribute.name === 'SharedPlan') {
            //CS.SM.getActiveSolution().then((product) => {
            let product = await CS.SM.getActiveSolution();
            //if (product.type && product.name === IOTMobility_COMPONENTS.solution) {
            if (product.componentType && product.name === IOTMobility_COMPONENTS.solution) {
                Object.values(product.schema.configurations).forEach(async (config) => {
                    var priceItemid = null;
                    Object.values(config.attributes).forEach((priceItemAttribute) => {

                        if (priceItemAttribute.name === 'SharedPlan') {
                            priceItemid = priceItemAttribute.value;
                        }
                    });

                    if (config.guid == configuration.guid) {
                        //invoke method to get the allowance details
                        let inputMap = {};

                        if (priceItemid !== '') {
                            inputMap['priceItemId'] = priceItemid;
                        }
                        var allowanceRecId = null;
                        var allowanceValue = null;


                        let currentBasket = await CS.SM.getActiveBasket();

                        await currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(response => {
                            //CS.SM.WebService.performRemoteAction('SolutionGetAllowanceData', inputMap).then(function (response) {       
                            if (response && response['allowances'] != undefined) {
                                console.log('allowances', response['allowances']);
                                response['allowances'].forEach((a) => {
                                    allowanceRecId = a.cspmb__allowance__c;
                                    allowanceRecName = a.cspmb__allowance__r.Name;
                                    allowanceValue = a.cspmb__allowance__r.Value__c + ' ' + a.cspmb__allowance__r.Unit_Of_Measure__c;
                                    allowanceExternalId = a.cspmb__allowance__r.External_Id__c;
                                    allowanceEndDate = a.cspmb__allowance__r.endDate__c;
                                    console.log('allowanceValue.. ' + allowanceValue);
                                    let updateConfigMap = {};
                                    Object.values(config.attributes).forEach(async (priceItemAttribute) => {
                                        if (priceItemAttribute.name === 'PlanAllowance' && allowanceRecId != '') {
                                            updateConfigMap[config.guid] = [{
                                                name: 'PlanAllowance',
                                                value: allowanceRecId,
                                                displayValue: allowanceRecId
                                            }];
                                        }
                                        if (priceItemAttribute.name === 'PlanAllowanceValue' && allowanceValue != '') {
                                            updateConfigMap[config.guid] = [{
                                                name: 'PlanAllowanceValue',
                                                value: allowanceValue,
                                                displayValue: allowanceValue
                                            }];
                                            datapackallowance = allowanceValue;
                                        }

                                        //CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.solution, updateConfigMap, true);											
                                        //const config = await product.updateConfigurationAttribute(product.configuration.guid, updateConfigMap ,true );
                                        let keys = Object.keys(updateConfigMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            await product.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                        }
                                    });
                                });
                            } else {
                                console.log('no response');
                            }
                        });
                    }
                });
            }
            // });
        }

        //Changes related to DPG-2620 Start
        if (attribute.name === 'SelectPlanName' ) {
            if( attribute.value=='IoT Annual Data Plan'){
                IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.annualDataPlanSubscriptionFields, IOTMobility_COMPONENTS.IOTSubscription, configuration.guid, true, true, false);
            }else{
                Utils.emptyValueOfAttribute(configuration.guid, component.name, 'SIM Type', true);
                Utils.emptyValueOfAttribute(configuration.guid, component.name, 'OC', true);
                Utils.emptyValueOfAttribute(configuration.guid, component.name, 'RC', true);
                Utils.emptyValueOfAttribute(configuration.guid, component.name, 'MaintenanceRC', true);
                IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.annualDataPlanSubscriptionFields, IOTMobility_COMPONENTS.IOTSubscription, configuration.guid, true, false, false);
            }
        }
        //Changes related to DPG-2620 End
        
        if (window.basketStage === 'Contract Accepted'){
            loadedSolution.lock('Commercial',true);
        }

        return Promise.resolve(true);
    }

    IOTPlugin.beforeSave = function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        //(solution, configurationsProcessed, saveOnlyAttachment) {PD commented and added right signature
        if (allowSaveIOT) {
            allowSaveIOT = false;
            console.log('beforeSave - exiting true');
            //return Promise.resolve(true);
        }
        executeSaveIOT = true;
        //isBeforeUpdate = true;
        return Promise.resolve(true);
    }

    IOTPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        let solution = result.solution;
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }
        console.log('afterSave', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
        //isBeforeUpdate = false;
        console.log('afterSave - entering');
        Utils.updateCustomButtonVisibilityForBasketStage();
        Utils.updateOEConsoleButtonVisibility();
        if (currentSolutionName === 'IoT solutions') {
            var buttons = document.getElementsByClassName('slds-file-selector__dropzone');
            if (buttons) {
                for (var i = 0; i < buttons.length; i++) {
                    var button = buttons[i];
                    button.style.display = "none";
                }
            }
        }

        //Added for Cancel Story DPG-970
        await checkConfigurationSubscriptionsForIOT();
        await IOTPlugin.updateChangeTypeAttribute();
        if (basketChangeType === 'Change Solution') {
            await IOTPlugin.UpdateMainSolutionChangeTypeVisibility(solution);
            await IOTPlugin.UpdateAttributesForMacdOnSolution(solution);
            await IOTPlugin.UpdateAttributesForSubscription(solution);
            await IOTPlugin.updateStatusAfterSolutionLoad();
        }
        //Added for Shared Data Plan DPG-1132
        await IOTPlugin.UpdateAttributesForSharedDataPlan(solution);
        //Hide or Show Rate Card Link 
        await IOTPlugin.updateRateCardAttribute(solution);
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

        //code from save function
        /*executeSaveIOT = false;
            //let solution = await CS.SM.getActiveSolution();
            // await CS.SM.getActiveSolution().then((product) => {
            //     solution = product;
            // });
            if (!IOTPlugin.validateCancelSolution(solution)) {
                return Promise.resolve(false);
            }
        
            // Change for DPG- Added By Suyash 1132
            await CalculateTotalRCForIOTSolution();
            allowSaveIOT = true;
            await updateEDMListToDecomposeattributeForIOTSolution(solution);
            await updateEDMListToDecomposeattributeIOT(solution); //Aruna added to call to update the EDMListToDecompose attribute
            //await CS.SM.saveSolution();
            
            //solution.basket.saveSolution(solution)
            //.then( updatedSolution => console.log( updatedSolution ) );
            //return Promise.resolve(true);
            //*/
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }

        return Promise.resolve(true);
    }


    //Added for Cancel Story DPG-970
    IOTPlugin.UpdateMainSolutionChangeTypeVisibility = async function (solution) {
        if (basketChangeType !== 'Change Solution') {
            return;
        }

        let updateMap = {};
        //updateMap[solution.schema.configurations[0].guid] = [{
        updateMap[Object.values(solution.schema.configurations)[0].guid] = [{
            name: 'ChangeType',
            showInUi: true
        }];
        console.log('UpdateMainSolutionChangeTypeVisibility', updateMap);
        //Changes related to DPG-1779
        await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.solutionNonEditableAttributeListForCancel, IOTMobility_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, true, true, false);

        //CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.solution, updateMap, true).catch((e) => Promise.resolve(true));

        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(IOTMobility_COMPONENTS.solution);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
    }

    //Added for Shared Data Plan DPG-1132
    IOTPlugin.UpdateAttributesForSharedDataPlan = async function (solution) {
        let changeTypeAtrtribute;
        //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.schema && solution.schema.configurations && solution.schema.configurations.size > 0){
            if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
                Object.values(solution.schema.configurations).forEach((config) => {
                    Object.values(config.attributes).forEach(async (attr) => {
                        if (attr.name === 'OfferType') {
                            if (attr.displayValue === sharedDataPlan) {
                                //Changes related to task DPG-1796
                                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionEditableFields, IOTMobility_COMPONENTS.solution, config.guid, false, true, false);
                                await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.comittedDataSolutionNonEditableFields, IOTMobility_COMPONENTS.solution, config.guid, true, true, false);
                                //Changes related to DPG-1779
                                if (basketChangeType == 'Change Solution') {
                                    //IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.solutionNonEditableAttributeListForCancel,IOTMobility_COMPONENTS.solution, config.guid, true, true, false);
                                }
                            }
                        }
                    });

                });
            }
        }
        return Promise.resolve(true);
    }

    //Added logic for DPG-1964
    IOTPlugin.updateRateCardAttribute = async function (solution) {

        //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0){
            if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
                //solution.schema.configurations.forEach((config) => {
                Object.values(solution.schema.configurations).forEach((config) => {
                    //config.attributes.forEach((attr) => {
                    Object.values(config.attributes).forEach(async (attr) => {
                        if (attr.name === 'OfferType') {
                            if (attr.displayValue != null) {
                                await IOTPlugin.updateAttributeVisiblity(['IoTRateCardButton'], IOTMobility_COMPONENTS.solution, config.guid, false, true, false);
                                Utils.updateCustomAttributeLinkText('Rate Card', 'View');
                            } else {
                                await IOTPlugin.updateAttributeVisiblity(['IoTRateCardButton'], IOTMobility_COMPONENTS.solution, config.guid, false, false, false);
                            }
                        }
                    });
                });
            }
        }
        return Promise.resolve(true);
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.UpdateAttributesForSubscription = async function (solution) {
        let changeTypeAtrtribute;
        //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.components && solution.components.size > 0) {
            if (solution.components && Object.values(solution.components).length > 0) {

                let comp = Object.values(solution.components).filter(c => {
                    return c.schema && c.name === IOTMobility_COMPONENTS.IOTSubscription && c.schema.configurations && c.schema.configurations.size > 0
                });
                if (comp && comp.length > 0) {
                    //for (let i = 0; i < comp[0].schema.configurations.size; i++) {
                    for (let i = 0; i < Object.values(comp[0].schema.configurations).length; i++) {
                        let config = Object.values(comp[0].schema.configurations)[i];
                        changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                            return obj.name === 'ChangeType'
                        });
                        if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0 && changeTypeAtrtribute[0].value === 'Cancel') {
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.hidesubscriptionHideFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, false, false);
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.showSubscriptionFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, true, true, true);
                        }
                        // if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0 && changeTypeAtrtribute[0].value === 'Modify') {
                        //     IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.hidesubscriptionHideFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, true, false);
                        //     IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.showSubscriptionFieldsForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, false, false);
                        // }
                        if (basketChangeType == 'Change Solution') {
                            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.subscriptionNonEditableAttributeListForCancel, IOTMobility_COMPONENTS.IOTSubscription, config.guid, true, true, false);
                        }
                    }
                }
            }
        }
        return Promise.resolve(true);
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.UpdateAttributesForMacdOnSolution = async function (solution) {
        console.log('UpdateAttributesForMacdOnSolution');
        let changeTypeAtrtribute;
        //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.components && solution.components.size > 0) {
            if (solution.components && Object.values(solution.components).length > 0) {

                changeTypeAtrtribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
                    return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
                });
                if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                    await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], solution.schema.name, Object.values(solution.schema.configurations)[0].guid, false, true, true);

                } else {
                    await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], solution.schema.name, Object.values(solution.schema.configurations)[0].guid, false, false, false);
                    Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'CancellationReason', false);
                }

                let comp = Object.values(solution.components).filter(c => {
                    return c.schema && c.name === IOTMobility_COMPONENTS.IOTSubscription && c.schema.configurations && Object.values(c.schema.configurations).length > 0
                });
                if (comp && comp.length > 0) {
                    //for (let i = 0; i < comp[0].schema.configurations.size; i++) {
                    for (let i = 0; i < Object.values(comp[0].schema.configurations).length; i++) {
                        let config = Object.values(comp[0].schema.configurations)[i];
                        changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                            return obj.name === 'ChangeType'
                        });

                        //Changes related to DPG-1779
                        if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0 && changeTypeAtrtribute[0].value === 'Cancel') {
                            await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, true, true);
                            await IOTPlugin.updateAttributeVisiblity(['DisconnectionDate'], IOTMobility_COMPONENTS.IOTSubscription, config.guid, false, true, true);
                        }
                    }
                }
            }
        }

        return Promise.resolve(true);
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.UpdateCancellationAttributes = async function (componentName, guid, changeTypeValue) {
        if (changeTypeValue === 'Cancel') {
            await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], componentName, guid, false, true, true);
            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.solutionNonEditableAttributeListForCancel, componentName, guid, true, true, false);
        }
        if (changeTypeValue === 'Cancel' && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(['DisconnectionDate'], componentName, guid, false, true, true);
        }

        //Changes related to DPG-1779
        if (changeTypeValue === 'Modify' && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(['DisconnectionDate'], componentName, guid, false, false, false);
            await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], componentName, guid, false, false, false);
            await IOTPlugin.updateAttributeVisiblity(IOTMobility_COMPONENTS.subscriptionNonEditableAttributeListForCancel, componentName, guid, true, true, false);
        }

        if (changeTypeValue !== 'Cancel') {
            await IOTPlugin.updateAttributeVisiblity(['CancellationReason'], componentName, guid, false, false, false);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.solution, 'CancellationReason', true);
        }

        if (changeTypeValue !== 'Cancel' && componentName === IOTMobility_COMPONENTS.IOTSubscription) {
            await IOTPlugin.updateAttributeVisiblity(['DisconnectionDate'], componentName, guid, false, false, false);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.IOTSubscription, 'CancellationReason', true);
            Utils.emptyValueOfAttribute(guid, IOTMobility_COMPONENTS.IOTSubscription, 'DisconnectionDate', true);
        }
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.updateAttributeVisiblity = async function (attributeName, componentName, guid, isReadOnly, isVisible, isRequired) {
        let updateMap = {};
        updateMap[guid] = [];
        attributeName.forEach((attribute) => {
            updateMap[guid].push({
                name: attribute,
                readOnly: isReadOnly,
                showInUi: isVisible,
                required: isRequired
            });
        });
        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(componentName);
        //component.lock('Commercial', false);
        var complock = component.commercialLock;
        if (complock)	
            component.lock('Commercial', false);
        const config = await component.updateConfigurationAttribute(guid, updateMap[guid], true);
        if (complock) 
            component.lock('Commercial', true);
        // component.lock('Commercial', false);
    }

    /*IOTPlugin.buttonClickHandler = function(buttonSettings) {
        console.log('buttonSettings', buttonSettings.id);
        var url = '';
        var redirectURI = '/apex/';
        if (communitySiteId) {
            url = window.location.href;
            if (url.includes('partners.enterprise.telstra.com.au'))
                redirectURI = '/s/sfdcpage';
            else
                redirectURI = '/partners/s/sfdcpage';
        }
        url = redirectURI;
        
        if (buttonSettings.id === 'msViewRateCard') {
        
            urlWin = window.location.href;
            console.log('communitySiteId:', communitySiteId);
            if (communitySiteId) {
                url = url + encodeURIComponent('resource/RateCard');
            } else {
                console.log('urlWin:', urlWin);
                url = '/resource/RateCard';
                console.log('url:', url);
            }
            return Promise.resolve(url);
        
        }
        //Adityen -  Bulk order enrichment
        else if (buttonSettings.id === 'msOrderEnrichment') {
            if (Utils.isOrderEnrichmentAllowed()) {
                ///*basketStage === 'Contract Accepted'*
                setTimeout(createBulkOE, 200, 'IOT Subscription', IOTMobility_COMPONENTS.IOTSubscription);
                return Promise.resolve('null');
            } else {
                CS.SM.displayMessage('Can not do order enrichment when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        }
    }*/

    // Arinjay
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        let currentSolution = await CS.SM.getActiveSolution();
        if (currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            console.log('OrderEnrichmentTabLoaded', e);
            afterOrderEnrichmentTabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name);
        }
    });


    IOTPlugin.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
        console.log('IOT afterOrderEnrichmentConfigurationAdd', componentName, configuration, orderEnrichmentConfiguration)
        window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

    IOTPlugin.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

    //Aditya: Spring Update for changing basket stage to Draft
    IOTPlugin.afterSolutionDelete = function (solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.updateStatusAfterSolutionLoad = async function () {
        let solution = await CS.SM.getActiveSolution();
        //await CS.SM.getActiveSolution().then((solution) => {
        if (solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.components && solution.components.size > 0) {
            if (solution.components && Object.values(solution.components).length > 0) {
                //if (solution.schema && solution.schema.configurations && solution.schema.configurations.size > 0) {
                if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
                    let updateConfigMapsubs = {};
                    let updateConfigMapsubs1 = {};
                    Object.values(solution.components).forEach((comp) => {
                        if (comp.name === IOTMobility_COMPONENTS.IOTSubscription) {
                            //if (comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {

                                Object.values(comp.schema.configurations).forEach((subsConfig) => {
                                    updateConfigMapsubs[subsConfig.guid] = [];
                                    updateConfigMapsubs1[subsConfig.guid] = [];
                                    // var OfferTypeAttribute = subsConfig.attributes.filter(obj => {
                                    //     return obj.name === 'OfferTypeString'
                                    // // });
                                    var changeTypeAtrtribute = Object.values(subsConfig.attributes).filter(obj => {
                                        return obj.name === 'ChangeType'
                                    });


                                    Object.values(subsConfig.attributes).forEach((attr) => {
                                        if (attr.name === 'CustomerFacingServiceId') {
                                            if (attr.value !== '') {
                                                updateConfigMapsubs[subsConfig.guid].push({
                                                    name: 'ConfigName',
                                                    value: checkMSISDNPresent(subsConfig.configurationName, attr.value), //subsConfig.configurationName + '-' + attr.value,
                                                    displayValue: checkMSISDNPresent(subsConfig.configurationName, attr.value) //subsConfig.configurationName + '-' + attr.value
                                                });
                                            }
                                        }
                                        //if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0 && changeTypeAtrtribute[0].value === 'Cancel') {
                                        // if (attr.name === 'OC') {
                                        //     updateConfigMapsubs[subsConfig.guid].push({
                                        //         name: 'OC',
                                        //         value: {
                                        //             value: 0.00,
                                        //             displayValue: 0.00
                                        //         }
                                        //     });
                                        // }
                                        //}

                                    });

                                });
                            }
                        }
                    });
                    console.log('updateConfigMapsubs::::', updateConfigMapsubs);
                    if (updateConfigMapsubs && Object.keys(updateConfigMapsubs).length > 0) {
                        keys = Object.keys(updateConfigMapsubs);
                        let component = await solution.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
                        for (let i = 0; i < keys.length; i++) {
                            const config = await component.updateConfigurationAttribute(keys[i], updateConfigMapsubs[keys[i]], true);
                            console.log('updateConfigurationAttribute Update', config);
                        }
                    }
                }
            }
        }
        //});
        return Promise.resolve(true);
    }

    //Added for Cancel Story DPG-970
    IOTPlugin.updateChangeTypeAttribute = async function () {
        console.log('updateChangeTypeAttribute');
        //CS.SM.getActiveSolution().then((solution) => {
        let solution = await CS.SM.getActiveSolution();
        //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (solution && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (solution.components && solution.components.size > 0) {
            if (solution.components && Object.values(solution.components).length > 0) {
                Object.values(solution.components).forEach(async (comp) => {
                    var updateMap = [];
                    var doUpdate = false;
                    if ((comp.name === IOTMobility_COMPONENTS.IOTSubscription) &&
                        //comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
                        comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        Object.values(comp.schema.configurations).forEach((config) => {
                            //if (config.attributes && config.attributes.size > 0) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {
                                Object.values(config.attributes).forEach((attribute) => {
                                    console.log('Check');
                                    if (attribute.name === 'ChangeType') {
                                        doUpdate = true;
                                        var changeTypeValue = attribute.value;
                                        if (!updateMap[config.guid])
                                            updateMap[config.guid] = [];

                                        console.log('basketChangeType: ', basketChangeType);
                                        if (!basketChangeType || (config.replacedConfigId === '' || config.replacedConfigId === undefined || config.replacedConfigId === null)) {

                                            console.log('Non MACD basket');
                                            if (!changeTypeValue) {
                                                changeTypeValue = 'New';
                                            }
                                            updateMap[config.guid].push({
                                                name: attribute.name,
                                                value: changeTypeValue,
                                                displayValue: changeTypeValue,
                                                showInUi: false,
                                                readOnly: true
                                            });
                                        } else {

                                            console.log('MACD basket');
                                            var readonly = false;
                                            if (config.id && changeTypeValue === 'Cancel')
                                                readonly = true;

                                            updateMap[config.guid].push({
                                                name: attribute.name,
                                                showInUi: true,
                                                readOnly: false
                                            });
                                        }
                                    }
                                });
                            }
                        });
                    }
                    if (doUpdate) {
                        console.log('updateChangeTypeAttribute', updateMap);
                        //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        //const config = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true );
                        let keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
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

    IOTPlugin.afterConfigurationAddedToMacBasket = async function (componentName, guid) {
        let solution = await CS.SM.getActiveSolution();
        let component = solution.getComponentByName(componentName);
        console.log('afterConfigurationAddedToMacBasket***', componentName, guid);
        IOTPlugin.updateChangeTypeAttribute();
        await checkConfigurationSubscriptionsForIOT();
        //Reset CRDs when PCs added to MAC basket - moved this from MACD Observer as part of Spring20 upgrade
        if (basketChangeType === 'Change Solution') {
            if (solution.components && Object.values(solution.components).length > 0) {
                for (const comp of Object.values(solution.components)) {
                    if (solution.name === IOTMobility_COMPONENTS.solution && comp.name === IOTMobility_COMPONENTS.IOTSubscription) {
                        await validateOERules.resetCRDDatesinOESchema_ALL(solution.name, comp.name);
                    }
                }
            }
        }
        return Promise.resolve(true);
    }
}



//Added for Cancel Story DPG-970
async function saveSolutionIOT() {
    //Added logic for DPG-1964
    Utils.updateCustomAttributeLinkText('Rate Card', 'View');
    if (executeSaveIOT) {
        executeSaveIOT = false;
        let solution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }
        // await CS.SM.getActiveSolution().then((product) => {
        //     solution = product;
        // });
        if (!validateCancelSolution(solution)) {
            return Promise.resolve(false);
        }

        // Change for DPG- Added By Suyash 1132
        await CalculateTotalRCForIOTSolution();
        allowSaveIOT = true;
        //spring 20 upgrade start
        /* if(window.basketStage === 'Contract Accepted'){
           await updateEDMListToDecomposeattributeForIOTSolution(solution);
           await updateEDMListToDecomposeattributeIOT(solution); //Aruna added to call to update the EDMListToDecompose attribute
         }*/
        //spring 20 upgrade end
        //await updateSolutionNameIoT();  // Added logic for DPG-2131 Solution Name Validation for IoT //commented as part of spring 20'upgrade.
        //await CS.SM.saveSolution();

        //let currentBasket = await CS.SM.getActiveBasket();
        //await currentBasket.saveSolution(solution.id);
        // .then( updatedSolution => console.log( updatedSolution ) );
        //return Promise.resolve(true);
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }
    }
    
    return Promise.resolve(true);
}

// Arinjay
afterOrderEnrichmentTabLoaded = async function (configurationGuid, OETabName) {
    console.log('afterOETabLoaded: ', configurationGuid, OETabName);
    var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
    window.afterOETabLoaded(configurationGuid, OETabName, schemaName, '');
    return Promise.resolve(true);
}

/************************************************************************************
 * Author	: Aruna Aware
 * Method Name : addDefaultIOTConfigs
 * Defect/US # : DPG-1692 & DPG-1723 
 * Invoked When: After Click on Solution
 * Description :Check for bulk enrichment values
 ***********************************************************************************/
async function addDefaultIOTConfigs() {
    if (basketStage !== 'Contract Accepted')
        return;
    var oeMap = [];
    let currentSolution = await CS.SM.getActiveSolution();
    console.log('addDefaultIOTCOnfigs');
    //await CS.SM.getActiveSolution().then((currentSolution) => {
    //if (currentSolution.type && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
    if (currentSolution.componentType && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
        //if (currentSolution.components && currentSolution.components.size > 0) {
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
            Object.values(currentSolution.components).forEach((comp) => {
                if (comp.name === IOTMobility_COMPONENTS.IOTSubscription) {
                    Object.values(comp.schema.configurations).forEach((config) => {
                        var cancelconfig = Object.values(config.attributes).filter((attr => {
                            return attr.name === 'ChangeType'
                        }));
                        var isDeliveryEnrichmentNeededAtt = Object.values(config.attributes).filter((attr => {
                            return attr.name === 'isDeliveryEnrichmentNeededAtt'
                        }));
                        var isCRDEnrichmentNeededAtt = Object.values(config.attributes).filter((attr => {
                            return attr.name === 'isCRDEnrichmentNeededAtt'
                        }));
                        if (cancelconfig && cancelconfig.length > 0 && cancelconfig[0].value !== 'Cancel' && (isDeliveryEnrichmentNeededAtt[0].value === true || isDeliveryEnrichmentNeededAtt[0].value === 'true' || isCRDEnrichmentNeededAtt[0].value === true || isCRDEnrichmentNeededAtt[0].value === 'true')) {
                            //comp.orderEnrichments.forEach((oeSchema) => {
                            Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                                if (!oeSchema.name.toLowerCase().includes('numbermanagementv1')) {
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
                                        //el.oeSchemaId = oeSchema.id;
                                        el.oeSchema = oeSchema;
                                        oeMap.push(el);
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    }
    //})
    //.then(() => Promise.resolve(true));

    // if (oeMap.length> 0) {
    //     var map = [];
    //     map.push({});
    //     for (var i=0; i< oeMap.length;i++) {
    //         await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
    //     };
    // }

    if (oeMap.length > 0) {
        let map = [];
        for (var i = 0; i < oeMap.length; i++) {
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration(map);
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        }
    }

    await initializeIOTConfigs();
    return Promise.resolve(true);
}

/**********************************************************************************************
 * Author	  : Aruna Aware
 * Method Name : initializeIOTConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 **********************************************************************************************/
async function initializeIOTConfigs(oeguid) {
    console.log('initializeIOTConfigs');
    let currentSolution = await CS.SM.getActiveSolution();
    // await CS.SM.getActiveSolution().then((solution) => {
    //     currentSolution = solution;
    // }).then(() => Promise.resolve(true));
    if (currentSolution) {
        //if (currentSolution.type && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
        if (currentSolution.componentType && currentSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
            //if (currentSolution.components && currentSolution.components.size > 0) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                //for (var i=0; i<currentSolution.components.size; i++) {
                for (var i = 0; i < Object.values(currentSolution.components).length; i++) {
                    var comp = Object.values(currentSolution.components)[i];
                    //for (var j=0; j<comp.schema.configurations.size; j++) {
                    for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                        var config = Object.values(comp.schema.configurations)[j];
                        var updateMap = {};
                        //var oeConfigMap = {}; // Arinjay
                        if (config.orderEnrichmentList) {
                            for (var k = 0; k < config.orderEnrichmentList.length; k++) {
                                var oe = config.orderEnrichmentList[k];

                                if (oeguid && oeguid !== oe.guid)
                                    continue;
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
                                    //oeConfigMap.push(oe.guid,oe.configuration.guid); // Arinjay
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            console.log('initializeTMDMOEConfigs updateMap:', updateMap);
                            let keys = Object.keys(updateMap);
                            console.log('initializeTMDMOEConfigs keys:', keys);
                            for (var h = 0; h < updateMap.length; h++) {
                                await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], true)
                            }
                            //	getMDMRangeDataAddedinAttachment();
                            //await CS.SM.updateOEConfigurationAttribute(TENANCY_COMPONENT_NAMES.tenancy, config.guid, updateMap, false).then(() => Promise.resolve(true));

                        }
                        /*if (updateMap && Object.keys(updateMap).length > 0) {
                            for(var key in updateMap) {
                                let upConfigGuid = comp.configuration.guid;
                                let upOEConfigGuid = oeConfigMap.get(key);
                                let attributes = updateMap.get(key);
                                currentSolution.updateOrderEnrichmentConfigurationAttribute( upConfigGuid, upOEConfigGuid, attributes, false );
                            }
                            console.log('initializeEMOEConfigs updateMap:', updateMap);
                            //await CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
                        }*/
                    };
                };
            }
        }
    }
    return Promise.resolve(true);
}



/************************************************************************************
 * Author	: Aruna Aware
 * Method Name : updateEDMListToDecomposeattributeForSolution
 * Defect/US # : DPG-1132
 * Invoked When: Click on Validate and save button
 * Description :Update EDMdecomposition field on PC
 * Parameters : guid
 ***********************************************************************************/
async function updateEDMListToDecomposeattributeForIOTSolution(loadedSolution) {
    let updateSolMap = {};

    //if (loadedSolution.type && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
    if (loadedSolution && loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)) {
        //if (loadedSolution.schema && loadedSolution.schema.configurations && loadedSolution.schema.configurations.size > 0 ) {
        if (loadedSolution.schema && loadedSolution.schema.configurations && Object.values(loadedSolution.schema.configurations).length > 0) {

            Object.values(loadedSolution.schema.configurations).forEach(async (config) => {
                updateSolMap[config.guid] = [];
                Object.values(config.attributes).forEach((attr) => {
                    if (attr.name === 'OfferTypeString' && attr.value === 'Right Plan') {
                        updateSolMap[config.guid].push({
                            name: 'EDMListToDecompose',
                            value: '964_AW_1090',
                            displayValue: '964_AW_1090'
                        });
                    } else if (attr.name === 'OfferTypeString' && attr.value === sharedDataPlan) {
                        updateSolMap[config.guid].push({
                            name: 'EDMListToDecompose',
                            value: '964_AW_1078, 964_RC_1078',
                            displayValue: '964_AW_1078, 964_RC_1078'
                        });
                    }
                });
                //CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.solution, updateSolMap, true);
                //const configuration = await solution.updateConfigurationAttribute(solution.configuration.guid, updateSolMap ,true );
                let keys = Object.keys(updateSolMap);
                for (let i = 0; i < keys.length; i++) {
                    await loadedSolution.updateConfigurationAttribute(keys[i], updateSolMap[keys[i]], true);
                }
            });
        }

    }
    return Promise.resolve(true);
}


//added for setting EDMListToDecompose attribute at save
async function updateEDMListToDecomposeattributeIOT(product) {
    //if (product.type && product.name.includes(IOTMobility_COMPONENTS.solution)) {
    if (product && product.name.includes(IOTMobility_COMPONENTS.solution)) {
        var statusMsg;
        //if (product.components && product.components.size > 0) {
        if (product.components && Object.values(product.components).length > 0) {
            //for (var i=0; i< product.components.size; i++) {
            for (var i = 0; i < Object.values(product.components).length; i++) {
                var comp = Object.values(product.components)[i];
                if (comp.name === IOTMobility_COMPONENTS.IOTSubscription) {
                    //if (comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        updateMap = [];
                        //for (var j=0; j<comp.schema.configurations.size; j++) {
                        for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                            var iotConfig = Object.values(comp.schema.configurations)[j];
                            //if (iotConfig.attributes && iotConfig.attributes.size > 0) {
                            if (iotConfig.attributes && Object.values(iotConfig.attributes).length > 0) {
                                //DPG-1931 - condition to update EDMListToDecompose attribute for Cancel scenario - restrict OTC charges
                                var changeTypeAttr = Object.values(iotConfig.attributes).filter(a => {
                                    return a.name === 'ChangeType'
                                });
                                var EDMListToDecompose = '';
                                if (changeTypeAttr[0].value === 'Cancel') {
                                    EDMListToDecompose = 'Incident Management_Assurance,IOT Access_Fulfilment,IOT Mobility_Fulfilment,Telstra Managed Service Option 1_Assurance'; //Aruna: Added spec to default list.
                                } else {
                                    EDMListToDecompose = '965_NRC_984,Incident Management_Assurance,IOT Access_Fulfilment,IOT Mobility_Fulfilment,Telstra Managed Service Option 1_Assurance'; //Aruna: Added spec to default list.
                                }
                                //var EDMListToDecompose = '965_NRC_984,Incident Management_Assurance,IOT Access_Fulfilment,IOT Mobility_Fulfilment,Telstra Managed Service Option 1_Assurance'; //Aruna: Added spec to default list.

                                var OfferTypeString = Object.values(iotConfig.attributes).filter(a => {
                                    return a.name === 'OfferTypeString'
                                });

                                if (OfferTypeString && OfferTypeString.length > 0) {
                                    if (OfferTypeString[0].value && OfferTypeString[0].value === "Right Plan") {
                                        EDMListToDecompose = EDMListToDecompose + ',965_AW_1088';
                                    } else if (OfferTypeString[0].value === "Shared Data") {
                                        EDMListToDecompose = EDMListToDecompose + ',965_AW_1087';
                                    }
                                }
                                console.log('EDMListToDecompose', EDMListToDecompose);
                                updateMap[iotConfig.guid] = [{
                                    name: 'EDMListToDecompose',
                                    value: EDMListToDecompose,
                                    displayValue: EDMListToDecompose
                                }];
                            }
                        }
                        let component = await product.getComponentByName(IOTMobility_COMPONENTS.IOTSubscription);
                        //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap ,true );
                        let keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            // component.lock('Commercial', false);
                            await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                            //component.lock('Commercial', true);
                        }
                        //await CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.IOTSubscription, updateMap, true);
                    }
                }
            }
        }
    }

    return Promise.resolve(true);
}

//Added for Cancel Story DPG-970
async function checkConfigurationSubscriptionsForIOT() {
    console.log('checkConfigurationSubscriptionsForIOT');
    var componentMap = {};
    var updateMap = {};
    let solution = await CS.SM.getActiveSolution();

    var optionValues = [];
    optionValues = [
        "Modify", "Cancel"
    ];

    //await CS.SM.getActiveSolution().then((solution) => {
    //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
    if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        //if (solution.components && solution.components.size > 0) {
        if (solution.components && Object.values(solution.components).length > 0) {
            Object.values(solution.components).forEach((comp) => {
                if ((comp.name === IOTMobility_COMPONENTS.IOTSubscription) &&
                    //comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
                    comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    Object.values(comp.schema.configurations).forEach((config) => {
                        if (config.replacedConfigId || config.id) {
                            var cta = Object.values(config.attributes).filter(a => {
                                return a.name === 'ChangeType'
                            });
                            if (cta && cta.length > 0) {

                                if (!componentMap[comp.name])
                                    componentMap[comp.name] = [];
                                if (config.replacedConfigId && (config.id == null || config.id == ''))
                                    componentMap[comp.name].push({
                                        'id': config.replacedConfigId,
                                        'guid': config.guid,
                                        'needUpdate': 'Yes',
                                        'ChangeTypeValue': cta[0].value
                                    });

                                else if (config.replacedConfigId)
                                    componentMap[comp.name].push({
                                        'id': config.replacedConfigId,
                                        'guid': config.guid,
                                        'needUpdate': 'No',
                                        'ChangeTypeValue': cta[0].value
                                    });
                                else
                                    componentMap[comp.name].push({
                                        'id': config.id,
                                        'guid': config.guid,
                                        'needUpdate': 'No',
                                        'ChangeTypeValue': cta[0].value
                                    });
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

        // Arinjay
        let currentBasket;
        currentBasket = await CS.SM.getActiveBasket();
        await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
            console.log('GetSubscriptionForConfiguration result:', values);
            if (values['GetSubscriptionForConfiguration'])
                statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
        });

        console.log('checkConfigurationSubscriptionsForIOT statuses;', statuses);
        if (statuses) {
            Object.keys(componentMap).forEach(async comp => {
                componentMap[comp].forEach(element => {
                    var statusValue = 'New';
                    var CustomerFacingId = '';
                    var status = statuses.filter(v => {
                        return v.csordtelcoa__Product_Configuration__c === element.id
                    });
                    if (status && status.length > 0) {
                        statusValue = status[0].csord__Status__c;
                        CustomerFacingId = status[0].serviceMSISDN__c;
                    }

                    if (element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') {
                        //if (element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && statusValue != 'New') {
                        console.log('Check');
                        const found = optionValues.find(element => element === statusValue);
                        if (found === undefined) {
                            optionValues.push(statusValue);
                        }
                        updateMap[element.guid] = [{
                            name: 'ChangeType',
                            //value: {
                            options: optionValues,
                            showInUi: true,
                            value: statusValue,
                            displayValue: statusValue
                            //}
                        },
                        {
                            name: 'CustomerFacingServiceId',
                            value: CustomerFacingId,
                            displayValue: CustomerFacingId
                        }
                        ]; // End*
                    } else {
                        updateMap[element.guid] = [{
                            name: 'CustomerFacingServiceId',
                            value: CustomerFacingId,
                            displayValue: CustomerFacingId
                        }];

                    }
                });

                console.log('checkConfigurationSubscriptionsForIOT update map', updateMap);
                //CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptionsForIOT Attribute Update', component));
                //const config = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap ,true );
                if (updateMap && Object.values(updateMap).length > 0) {
                    let component = await solution.getComponentByName(comp);
                    let keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                    return Promise.resolve(true);
                }
            });
        }

    }

    return Promise.resolve(true);
}

//Added for Cancel Story DPG-970
function checkMSISDNPresent(configName, msisdn) {
    if (configName.includes("-")) {
        return configName;
    } else {
        return configName + '-' + msisdn;
    }
}

/**************************************************************************************
 * Author	   : Suyash Chiplunkar
 * Method Name : CalculateTotalRCForIOTSolution
 * Edge Number : DPG-1132
 * Description : This function will count the Quantity of IOT Subscription Products added into the basket
 * Invoked When: Before Save
 **************************************************************************************/
async function CalculateTotalRCForIOTSolution() {
    console.log('CalculateTotalRCForIOTSolution::::::::');
    var componentMap = {};
    var totalSubCount = 0;
    var OfferTypeVal;
    var recurringChargeValue = 0;
    let solution = await CS.SM.getActiveSolution();
    //await CS.SM.getActiveSolution().then((solution) => {
    //if (solution.type && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
    if (solution.componentType && solution.name.includes(IOTMobility_COMPONENTS.solution)) {
        //if (solution.schema && solution.schema.configurations && solution.schema.configurations.size > 0) {
        if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {

            Object.values(solution.schema.configurations).forEach(async (parentConfig) => {
                componentMap[parentConfig.guid] = [];
                Object.values(parentConfig.attributes).forEach((configAttr) => {
                    if (configAttr.name === 'OfferTypeString') {
                        OfferTypeVal = configAttr.value;
                    }
                    console.log('IOT     ', OfferTypeVal);
                });
                //if (solution.components && solution.components.size > 0 ) {//&& OfferTypeVal == sharedDataPlan
                if (solution.components && Object.values(solution.components).length > 0) { //&& OfferTypeVal == sharedDataPlan
                    Object.values(solution.components).forEach((comp) => {
                        if ((comp.name === IOTMobility_COMPONENTS.IOTSubscription) &&
                            //comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
                            comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach((config) => {
                                var cta = Object.values(config.attributes).filter(a => {
                                    return a.name === 'ChangeType'
                                });
                                var quant = Object.values(config.attributes).filter(a => {
                                    return a.name === 'Quantity'
                                });
                                //Changes related to DPG-1779
                                if (cta[0].value === 'Modify' || cta[0].value === 'New') { //&& OfferTypeVal == sharedDataPlan
                                    console.log('Inside New ', cta[0].value, quant[0].value);
                                    totalSubCount = totalSubCount + parseInt(quant[0].value);
                                }
                            });
                        }
                        console.log('totalSubCount-->' + totalSubCount);
                        componentMap[parentConfig.guid].push({
                            name: 'Quantity',
                            value: totalSubCount,
                            displayValue: totalSubCount,
                            showInUi: false,
                            readOnly: true
                        });

                    });
                }
                if (componentMap) {
                    //CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.solution, componentMap, true);
                    let component = await solution.getComponentByName(IOTMobility_COMPONENTS.solution);
                    //const config = await component.updateConfigurationAttribute(component.configuration.guid, componentMap ,true );
                    let keys = Object.keys(componentMap);
                    for (let i = 0; i < keys.length; i++) {
                        await component.updateConfigurationAttribute(keys[i], componentMap[keys[i]], true);
                    }
                }

            });
        };
    }
    //});
    return Promise.resolve(true);
}

//Added for Cancel Story DPG-970
function validateCancelSolution(solution) {
    let changeTypeAttribute;
    Object.values(solution.components).forEach((comp) => {
        Object.values(comp.schema.configurations).forEach((conf) => {
            Object.values(conf.attributes).filter(a => {
                if (a.name === 'ChangeType' && a.value === 'Cancel') {
                    changeTypeAttribute = a;
                }
            });
        });
    });
    if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
        return true;
    }

    let isValid = true;

    Object.values(solution.components).forEach((comp) => {
        if (comp.name === IOTMobility_COMPONENTS.IOTSubscription) {
            //if (comp.schema && comp.schema.configurations && comp.schema.configurations.size > 0) {
            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                Object.values(comp.schema.configurations).forEach((mobilesubConfig) => {
                    changeTypeAttribute = Object.values(mobilesubConfig.attributes).filter(a => {
                        return a.name === 'ChangeType' && a.value !== 'Cancel'
                    });
                    if (changeTypeAttribute && changeTypeAttribute.length > 0) {
                        isValid = false;
                    }
                });
            }
        }
    });

    if (!isValid) {
        CS.SM.displayMessage('When canceling whole solution all IOT Subscriptions must be canceled too!', 'error');
    }
    return isValid;
}

/* 	
	Added as part of DPG-2131 Solution Name Validation for IoT
	This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionNameIoT() {
    var listOfAttributes = ['Solution Name', 'GUID','OfferType'], attrValuesMap = {};
    var listOfAttrToGetDispValues = ['OfferName', 'OfferType'], attrValuesMap2 = {};
    attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, IOTMobility_COMPONENTS.solution);
    attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, IOTMobility_COMPONENTS.solution);
    console.log('attrValuesMap...' + attrValuesMap);
    console.log('attrValuesMap2...' + attrValuesMap2['OfferType']);
//Aruna - Added for change the Solution name after changing the offertype 
    var originalSolutionName = (attrValuesMap['Solution Name'].indexOf('_') != -1) ? attrValuesMap['Solution Name'].substring(0,attrValuesMap['Solution Name'].indexOf('_')) : attrValuesMap['Solution Name'];

 

    if (originalSolutionName === DEFAULTSOLUTIONNAME_IoT && attrValuesMap['OfferType'] != attrValuesMap2['OfferType']) {
        let updateConfigMap = {};
        // Spring 20 changes Start Here
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(IOTMobility_COMPONENTS.solution);
        /*updateConfigMap[attrValuesMap['GUID']] = [{
            name: 'Solution Name',
            value: {
                value: attrValuesMap['Solution Name']+'_'+attrValuesMap2['OfferType'],
                displayValue: attrValuesMap['Solution Name']+'_'+attrValuesMap2['OfferType']
            }                                                    
        }];*/
        updateConfigMap[attrValuesMap['GUID']] = [];
        updateConfigMap[attrValuesMap['GUID']].push({
            name: 'Solution Name',
            value: originalSolutionName + '_' + attrValuesMap2['OfferType'],
            displayValue: originalSolutionName + '_' + attrValuesMap2['OfferType']
        });

 

        /*if(updateConfigMap){
            CS.SM.updateConfigurationAttribute(IOTMobility_COMPONENTS.solution, updateConfigMap, true);    
        }*/
        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
            keys = Object.keys(updateConfigMap);
            for (let i = 0; i < keys.length; i++) {
                component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
            }
        }
        // Spring 20 changes End Here 
    }
}