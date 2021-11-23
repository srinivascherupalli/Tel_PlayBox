/******************************************************************************************
     * Author   : CloudSense Team
     Change Version History
    Version No Author Date
    1 Vamsi 26-Jul-19 Initial file
    2           Sandip 26-Jul-19
    3           Jayesh 26-Jul-19
    4 Vimal 27-Jul-19 Added OE related logic
    5 Sandip 29-Jul-19 Added validations for 2nd User Creation and CRD fields on OE.
    6           Tihomir         07-08-19    Code cleanup
    7           Tihomir         13-08-2019      Code refactoring , OE
    8           Venkat          30-08-19     UC Sprint Story Tasks
    9           Venkat          23-Sep-19    NextGen UC MTS Sprint User story (New & Modify Journey)- EDGE 108257,EDGE 114158, EDGE 107435
    10          Tihomir         01-10-19  NextGen cancellation finished
    11          Venkat          25-10-19   Removed Unwanted/MVP Implementation codes & New changes for Sprint 19.14
    12.         Vishal Arbune   01-10-2019      EDGE-113083 : Show available OneFund balance from CIDN at the time of basket creation
    13.         Romil Anand     02-10-2019      EDGE-115925 : Calculation of Total Basket amount on Validate & Save
    14.         Romil Anand     05-10-2019      EDGE-114977 : UI changes to be made on Subscription page
    15.         Romil Anand     10-10-2019      EDGE-113570 : Redemption amount cannot be more than the Charge Amount
    16.         Romil Anand     12-10-2019      EDGE-113091 : Show Fund balance details on Subscription page for each Solution in the Basket
    17.         Vishal Arbune   13-10-2019      EDGE-112359 : Cloudsense Opportunity basket flow
    18.         Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
    19.        Romil Anand     25-12-2019      EDGE-118038 : Eligible Redeemable charges (from Sigma to CS)-New Scenario
    20.        Romil Anand     25-10-2019      EDGE-119323 : GST Calculation of Net Charge while Redemption
    21.        Romil Anand     22-10-2019      EDGE-127941 : Calculate Total Contract Value for a Basket
    22.        Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
    23          Aditya          27-12-19   EDGE-125042: Update the Change Type of NGUC NG Voice to Cancel if subscriptions are suspended
    24.        Romil Anand     15-01-2020      EDGE-130075 : Redeeming One Funds for Cancel Journey
    25.        Shubhi     05-02-2020     EDGE-133963 :Discount Journey
    26.        Sandip Deshmane  07-02-2020   EDGE-EDGE-134972 - Added below fix to remove OE required in case of Cancel
    25.        Dheeraj Bhatt   13-02-2020      EDGE-100662 : UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
    26.         Sandip Deshmane 14-02-2020     EDGE-134972 - Added below fix to remove OE required in case of Cancel
    27.         Romil Anand     19-FEB-2020    EDGE-136954- Implement code review comments provided by Governance Review
    27.        Shubhi/Aditya 03-03-2020   EDGE-121376 :Discount Journey for Voice
    30. Laxmi    25-03-2020 EDGE-138001 - method call to hide importconfigurations button added
    31.       Shubhi 30-03-20202     EDGE-140157 NGUC Ui modify
    32.       Shubhi 30-03-20202     Edge-143527 POC for solution json
    33.       shubhi/Aditya 23/4/2020 Edge-120919 NGUC consumption based model new
    34.  Hitesh Gandhi 28/04/2020 Edge-120921 Added code for updateEDMListToDecomposeattribute
    35.  Romil Anand 29/04/2020 EDGE-144161 : Enabling Redemption as Discount for Device Payout and NGUC
    36.  Hitesh Gandhi 14/05/2020 EDGE-146184 Added code under updateEDMListToDecomposeattribute for Wireless DECT
    37.  Aditya Pareek 14/05/2020 EDGE-144971- NGUC Consumption based Cancel
    38.       shubhi            16/05/2020 Edge-142082
    38.       Aman Soni         16/05/2020 Edge-142082
    39.       RaviTeja          01/06/2020 EDGE-146972
    40.  Gnana     10-Jun-2020    EDGE-149887 : Solution Name Update Logic
    41.  Aman Soni 17-Jun-2020 EDGE-156214 EM mac || issue in billing account
    42.       Shubhi Vijay 13-Jun-20202    EDGE-162560
    43.       Pallavi D         02-Jul-2020     EDGE-154465 Spring 20 upgrade
    44.       Gnana/Aditya 17/07/2020 Modified as part of CS Spring'20 Upgrade
    45.  Sandip Deshmane 20/07/2020 Reser CRDs in case of MACD. Moved it from MACD observer as part of Spring20 upgrade
    46.  Sandip Deshmane 8/8/2020 Added function to set OE Data for Number Management
    47.  Aditya 11-08-2020 Edge:142084, Enable New Solution in MAC Basket
    47.      Shubhi Vijayvergia 13/08/2020 //added by shubhi for EDGE-170148
    48.     Shubhi Vijayvergia 21.08.2020 //added by shubhi for EDGE-169593 -redemptions fix for em,nguc and dop
    49.     Shubhi V             27.08.2020     EDGE-173020
    50.     Pallavi              08.09.2020    EDGE-175185
    51.     Pallavi               16.09.2020     Pallavi added check of basket type to avoid change type function execution in New
    52.     Shubhi               16.09.2020    Commented basket lock in updateConfigName_Accesory      
    53.    Pallavi D             02.09.20202      sprint 20.13 js refactor
    54.    Akshay G              08.10.2020     Added for Pricing Services
55.    Shradha               15.10.2020    EDGE-169456 - Pricing Service & Frame Agreements Package-Commenting code for pricing service enablement.
    56. Payal/Kamlesh            02.11.2020    EDGE-185639 - updated to add SIOs changes for rateCard  
    57. Pallavi D                07.11.2020   EDGE-186945    
    58. Pooja Bhat/Gokul	 	10.11.2020		20.15		EDGE-175750
59. Pallavi                  07.11.2020    EDGE-186945   
60. shubhi 					10.11.2020		EDGE-189501 
61. Pallavi D               EDGE-189677 added checks for replaced and disabled configs
62. Payal Popat             18/12/2020     EDGE-193480: Updated to hide DisconnectionDate for Device and Accessories

63. Gokul                   02/02/2021      EDGE-200705

64. Mukta Wadhwani          07/01/2021     EDGE-189340 : Commented call of populateRateCardinAttachment method
65. shubhi V 				17/03/2021		EDGE-208940
66. Anuj Pathak             23/03/2021     EDGE-207736 : Append Auto-number when multiple business callings are added in basket 
67. Ankit Goswami			06/04/2021	   EDGE-204030 : Associating Business Calling to Devices
68. Vivek 			        07/04/2021	   EDGE-206232 : Associating Business Calling to Broadsoft tenancy
69. Puneeth Kamath			28/05/2021	   EDGE-211087 : Remove Modify from Change Type for Business Calling
70. Vivek 			        14/06/2021	   EDGE-223950 : added lock and unlock logic
71. Ankit Goswami           06/07/2021     INC000095180309
72. Vivek                   07/08/2021     INC000096628734: BASE ORDER NAME BLANK
73. Mukta                   05/08/2021     DIGI-9268
74. Vivek                   08/11/2021     DIGI-3208
75. Mukta                   13/10/2021     Added to populate billing account lookup as part of DIGI-27422
76. Mukta                   28/10/2021     DIGI-36370
77. Aditya Pareek               04/10/2021      Updating Option Values as per CS R34 Upgrade
78. Mukta                   08/11/2021     DIGI-37283 and DIGI-37762
73. Vinay					06/11/2021     DIGI-456 Order Enrichment Upgrade and call CloneOrderEnrichment method
    ********************/
var ngucVariables = {

    NGUC_OFFER_NAME : 'Adaptive Collaboration',
    NGUC_PROF_SERV_OFFR_NAME : 'Adaptive Collaboration Professional Services',
    NGUC_TENANCY_OFFER_NAME  : 'Adaptive Collaboration Tenancy'
};

var NEXTGENUC_COMPONENTS = {
    solution: ngucVariables.NGUC_OFFER_NAME,  // DIGI-3208
    //NextGenUC: 'NextGen UC',
    //UnifiedCommunications: 'Unified Communications',
    UC: 'Business Calling',
    //User: 'User',
    //HuntGroup: 'Hunt Group',
    //AutoAttendant: 'Auto Attendant',
    //MainBusinessNumber: 'Main Business Number',
    Device: 'Unified Communication Device', //used in configuration add
    DevicesMTS: 'Devices',
    AccessoryMTS: 'Accessories',
    Accessory: 'Accessory', //used in configuration add
    //UcComponent: 'Unified Communication Enterprise Schema', //RF++ not in use
    UCDeviceEditableAttributeList: ['Device Type', 'Model', 'Quantity'], // Aditya: Removed Contracttype for EDGE-137255
    AccessoryEditableAttributeList: ['AccessoriesType', 'Accessorymodel', 'ContractType', 'Quantity'],
    // BroadsoftProductEditableAttributeList: ['callingPlans', 'concurrencyLimit', 'NumberofPhoneNumbers', 'UCUserQuantity', 'HuntGroupQuantity', 'AutoAttendantQuantity', 'MainBusinessNumberQuantity', 'HostedUCQuantity'],// RF++
    // BroadsoftProductNonEditableAttributeList: ['ContractTerm'] //RF++
};
//var executeSaveNgUC = false;
//var callUpdateImport = true;
//var saveNgUC = false;
//var valid = true;
var ratecardloaded = false;
var basketNum; // Added by Laxmi EDGE_135885
//var solutionName; // Added by Laxmi EDGE_135885
//var solutionID; // Edge-143527        
//var uniquehexDigitCode; //Edge-143527 PD commented on 03.09.2020
var callerNameNGUC = ''; //Edge-143527
let IsDiscountCheckNeeded = false;
let IsRedeemFundCheckNeeded = false; //EDGE-144161
//var configId; //Edge-143527
var isEapActive = true; //Edge-120921
var returnflag = true;
var DEFAULTSOLUTIONNAME_NGUC = ngucVariables.NGUC_OFFER_NAME;  // DIGI-3208
var DEFAULTOFFERNAME_NGUC = ngucVariables.NGUC_OFFER_NAME;  // DIGI-3208
var basketLockStages = ['Contract Accepted', 'Enriched', 'Submitted'];
// saperated out to reduce await calls
var currentBasketUC;
var loadedSolutionUC;
var basketStage;
//var basketChangeType; // EDGE-154465
var basketName;
// EDGE-154465 start
if (CS.SM.registerPlugin) {
    
    window.document.addEventListener('SolutionConsoleReady', async function () {
        await CS.SM.registerPlugin(ngucVariables.NGUC_OFFER_NAME)  // DIGI-3208
            .then(async UCEPlugin => {
                updateUCEPlugin(UCEPlugin);
            });
    });
}

// EDGE-154465 end
//Aditya changes for EDGE-133963
async function UCEPlugin_handleIframeMessage(e) {
    //EDGE-154465 start
    // let product = null;
    
    let solution = await CS.SM.getActiveSolution();
    if (solution && solution.name !== DEFAULTSOLUTIONNAME_NGUC) {
        return;
    }
    let solutionID = solution.solutionId;
    //console.log('handleIframeMessage from pricing:', e);
    var message = {};
    message = e['data'];
    message = message['data'];
    ///console.log('----->'+ e.data['data']);
    console.log(e.data['data']);
    console.log(e.data['command']);
    console.log(e.data['caller']);
    console.log('solutionID-->' + solutionID);
    //Edge-143527 start
    //added by shubhi for EDGE-121376 start /////
    if (e.data && e.data['caller'] && e.data['command']) {
		 //Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
				await pricingUtils.closeModalPopup();
				CommonUtills.oeErrorOrderEnrichment();
			}
		//Added By vijay ||end
        if (e.data['caller'] && (e.data['caller'] !== 'Devices' && e.data['caller'] != 'Business Calling' && e.data['caller'] != 'Accessories')) {
            return;
        } else if (e.data['command'] === 'pageLoad' + callerNameNGUC && e.data['data'] === solutionID) {
            await pricingUtils.postMessageToPricing(callerNameNGUC, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded)
        } else if (e.data['command'] === 'StockCheck' && e.data['data'] === solutionID && e.data['caller'] === 'Devices') { //EDGE-146972--Get the Device details for Stock Check before validate and Save as well
            await stockcheckUtils.postMessageToStockCheck(callerNameNGUC, solutionID)
        } //Added as a part of EDGE-185639
        else if(e.data && e.data['command'] && e.data['command'] === 'RateCard' && e.data['caller']){
            await CommonUtills.updateAttributeExpectedSIO(e.data['data'],e.data['guid'],e.data['caller']);
        }
         //Added as a part of EDGE-206232 : START VIVEK
         else if(e.data && e.data['command'] &&  e.data['actualTenancyId'] && e.data['command'] === 'TenancyIds' && e.data['caller'] === 'Business Calling'){
            console.log('i am in Broadsoft Tenancy' , e.data['actualTenancyId'] );
            await updateAttributeTenancyId(e.data['actualTenancyId']);
        }
        //Added as a part of EDGE-206232 : END
        else {
            await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller'], e.data['IsDiscountCheckAttr'], e.data['IsRedeemFundCheckAttr'], e.data['ApplicableGuid']); //added by shubhi for EDGE-121376
            if (e.data['command'] == 'ResponseReceived') {
                var showRateCart = true;
                if (window.BasketChange === 'Change Solution') {
                    // pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart); RF++
                }
            }
        }
    }else if (e.data === 'close') {
    	await pricingUtils.closeModalPopup();
    } //EDGE-227318 Defect Fix
    //Edge-143527 end
    // //added by shubhi for EDGE-121376 end ////    
    return Promise.resolve(true);
}

//AB: OE attachment loading helper start - Spring'20 Upgrade
refreshNumberManagmentOE = async function (configGuid, eventOeSchema) {
    
    let schemaName = 'NumberManagement';
    var loadedData = [];
    var oeMap = [];
    //const solution = await CS.SM.getActiveSolution();//RF++
    let config = loadedSolutionUC.getConfiguration(configGuid);//RF++
    let component = loadedSolutionUC.getComponent(config.other.dbDetails.componentId);//RF++
    //needed as eventOeSchema doesn't seem to be the same object
    let oeSchema = component.orderEnrichments[eventOeSchema.productOptionId];//rf++
    if (oeSchema && (oeSchema.name.toLowerCase().includes(schemaName.toLowerCase()))) {
        //first delete all existing OE configs for current OE schema, if any
        let oeToDelete = config.getOrderEnrichments();
        if (oeToDelete && oeToDelete[oeSchema.id]) {
            Object.values(config.getOrderEnrichments()[oeSchema.id]).forEach(oeConfig => {
                component.deleteOrderEnrichmentConfiguration(config.guid, oeConfig.guid, true);
            }
            );
        }
        //get and process received payload (attachment)
        let inputMap = {};
        inputMap['GetOeAttachment'] = config.id;
        inputMap['AttachmentName'] = schemaName;
        // let currentBasketUC = await CS.SM.getActiveBasket()
        let result = await currentBasketUC.performRemoteAction('SolutionActionHelper', inputMap);
        if (result["GetOeAttachment"]) {
            loadedData = JSON.parse(result["GetOeAttachment"]);
        }
        if (loadedData && loadedData.configurations && loadedData.configurations.length > 0) {
            loadedData.configurations.forEach(oeData => {
                var attList = [];
                //extract values for all schema attributes from received payload (attachment)
                Object.values(oeSchema.schema.attributes).forEach(schemaAtt => {
                    attList.push({
                        name: schemaAtt.name,
                        value: {
                            value: oeData[schemaAtt.name],
                            displayValue: oeData[schemaAtt.name],
                            readOnly: true
                        }
                    });
                }
                );
                let orderEnrichmentConfiguration = oeSchema.createConfiguration(attList);
                oeMap.push(orderEnrichmentConfiguration);
            }
            );
        }
    }
    if (oeMap.length > 0) {
        oeMap.forEach(oeConfig => {
            // API supports adding only one OE at the time
            component.addOrderEnrichmentConfiguration(configGuid, oeConfig, false);
        }
        );
    }
}
//AB: OE attachment loading helper end
/**********************************************************************************************************************************************
* Author   : Tihomir Baljak
* Method Name : UpdateChangeTypeVisibility
* Invoked When: after solution is loaded , after save
* Description : When MAC basket set ChangeType attribute visible on UC Device & Accessory if Contract Type = Hardware Repayment else hide ChangeType attribute
********************************************************************************************************************************************/
UpdateChangeTypeVisibility = async function () {//RF++ updated signature
    
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type &&
        for (let comp of Object.values(loadedSolutionUC.components)) {// EDGE-154465
            let updateMap = {};
            let configurations = comp.getConfigurations();
            if (comp.name === NEXTGENUC_COMPONENTS.UC /*|| NEXTGENUC_COMPONENTS.UcComponent */ || comp.name === NEXTGENUC_COMPONENTS.Accessory || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS || comp.name === NEXTGENUC_COMPONENTS.Device || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                if (configurations && Object.values(configurations).length > 0) { //RF++                      
                    //Object.values(comp.schema.configurations).forEach((compconfig) => {// EDGE-154465
                    for (let compconfig of Object.values(configurations)) {
                        let visible = true;
                       // if (comp.name !== NEXTGENUC_COMPONENTS.UC /*&& comp.name !== NEXTGENUC_COMPONENTS.UcComponent*/) {
                            let ct = Object.values(compconfig.attributes).filter(a => {// EDGE-154465
                                return (a.name === 'ChangeType' && (a.value === 'New'))
                            });
                            if (ct && ct.length > 0 || window.basketType === 'Outgoing') {//Added as part of DIGI-37762) {
                                visible = false;
                            }else {
                            visible = true;
                        }
                        
                        updateMap[compconfig.guid] = [];// EDGE-154465
                        updateMap[compconfig.guid].push({// EDGE-154465
                            name: 'ChangeType',
                            showInUi: visible
                        });
                        updateMap[compconfig.guid].push({
                            name: 'ContractType',
                            readOnly: true
                            // Aditya: Changes for EDGE-137255 Cancel --------End------>
                        });
                        updateMap[compconfig.guid].push({
                            name: "OneOffChargeGST",
                            showInUi: false
                        });
                    }//);                      
                }
                if (updateMap && Object.keys(updateMap).length > 0) {//RF++ lifted in previous loop
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
CalculateRemainingTerm = async function (hookname) {
    
    if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
        for (let comp of Object.values(loadedSolutionUC.components)) {   // EDGE-154465
            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                for (let config of Object.values(comp.schema.configurations)) {// EDGE-154465
                    let ChangeTypeValue = config.getAttribute('ChangeType');
                    let ContractTermValue = config.getAttribute('ContractTerm');
                    // EDGE-154465 end
                    //console.log('insidemodify---->', ChangeTypeValue, comp.name, window.BasketChange)
                    if ((comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) && window.BasketChange === 'Change Solution' && ChangeTypeValue.value !== 'New') //Aditya for NGUC MACD EDGE-121389---Start--->//RF++
                    {
                        await CommonUtills.remainingTermEnterpriseMobilityUpdate(config, ContractTermValue.displayValue, config.guid, comp.name, hookname);//RF++
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
async function genericUpdateConfigName(componentName, configName) {//RF++
    
    let updateMap = {};
    let comp = loadedSolutionUC.getComponentByName(componentName);
    let configurations = comp.getConfigurations();
    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
        for (let config of Object.values(configurations)) {
            let model;
            let type;
            if (componentName && componentName == NEXTGENUC_COMPONENTS.DevicesMTS) {
                type = config.getAttribute('Device Type');
                model = config.getAttribute('Model');
            }
            else if (componentName && componentName == NEXTGENUC_COMPONENTS.AccessoryMTS) {
                type = config.getAttribute('AccessoriesType');
                model = config.getAttribute('Accessorymodel');
            }
            if (type && type && type.value && model && model && model.value) {//RF++
                configName = type.displayValue + '-' + model.displayValue;//RF++
            }
            updateMap[config.guid] = [];
            updateMap[config.guid].push({
                name: "ConfigName",
                value: configName,
                displayValue: configName
            });
            if (comp && updateMap && Object.keys(updateMap).length > 0) {
                await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
            }
        }
    }
    return Promise.resolve(true);
}
//Added for Edge 143957
async function checkConfigurationSubscriptionsForNGUCForEachComponent(comp, solutionComponent, hookname) {
    
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    console.log('checkConfigurationSubscriptionsForNGUC');
    var componentMap = {};
    var updateMap = {};
    var ComName = comp.name;
    var optionValues = [];
    if (comp.name == NEXTGENUC_COMPONENTS.UC)
        optionValues = [
             CommonUtills.createOptionItem("Cancel") //R34UPGRADE
        ];
    else
        optionValues = [
             CommonUtills.createOptionItem("Cancel") //R34UPGRADE
        ];
    let configurations = comp.getConfigurations();
    if (solutionComponent) {
        /*var cta = Object.values(Object.values(comp.schema.configurations)[0].attributes).filter(a => {// EDGE-154465
            return a.name === 'ChangeType'
        });*/
        let cta = configurations[0].getAttribute('ChangeType');//RF++
        componentMap[comp.name] = [];
        componentMap[comp.name].push({
            'id': configurations[0].replacedConfigId,// EDGE-154465 //RF++
            'guid': configurations[0].guid,//RF++
            'ChangeTypeValue': cta.value,//RF++
			'needUpdate': 'No',
        });
    } else if (comp.schema && configurations && Object.values(configurations).length > 0) { //RF++
        //Object.values(comp.schema.configurations).forEach((config) => { //RF++
        for (let config of Object.values(configurations)) {
            if (config.replacedConfigId || config.id) {
                /*var cta = Object.values(config.attributes).filter(a => {
                    return a.name === 'ChangeType'
                });*/ //RF++
                let cta = config.getAttribute('ChangeType'); //RF++
                if (cta /*&& cta.length > 0*/) {//RF++
                    //console.log('Cmp Map --->', componentMap);
                    if (!componentMap[comp.name])
                        componentMap[comp.name] = [];
                    if (config.replacedConfigId && (config.id == null || config.id == ''))
                        componentMap[comp.name].push({
                            'id': config.replacedConfigId,
                            'guid': config.guid,
                            'needUpdate': 'Yes',
                            'ChangeTypeValue': cta.value
                        });
                    else if (config.replacedConfigId)
                        componentMap[comp.name].push({
                            'id': config.replacedConfigId,
                            'guid': config.guid,
                            'needUpdate': 'No',
                            'ChangeTypeValue': cta.value
                        });
                    else
                        componentMap[comp.name].push({
                            'id': config.id,
                            'guid': config.guid,
                            'needUpdate': 'No',
                            'ChangeTypeValue': cta.value
                        });
                }
            }
        }//);
    }
    //console.log('Cmp Map --->', componentMap);
    //var notNewConfig ;
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
        var statuses;
        await currentBasketUC.performRemoteAction('SolutionActionHelper', inputMap).then(values => {// EDGE-154465
            if (values['GetSubscriptionForConfiguration'])
                statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
        });
        if (statuses) {
            for (const comp of Object.keys(componentMap)) {
                let componentLoaded = loadedSolutionUC.getComponentByName(comp);
                for (const element of componentMap[comp]) {
                    var statusValue = 'New';
                    var CustomerFacingId = '';
                    var CustomerFacingName = '';
                    var status = statuses.filter(v => {
                        return v.csordtelcoa__Product_Configuration__c === element.id
                    });
                    if (status && status.length > 0) {
                        statusValue = status[0].csord__Status__c;
                    }
                    //Added for Edge 143957
                    if (((element.ChangeTypeValue !== 'Modify' && element.ChangeTypeValue !== 'Cancel' && element.ChangeTypeValue !== 'PaidOut') || ((element.ChangeTypeValue === 'Modify' || element.ChangeTypeValue === 'Cancel') && element.needUpdate == 'Yes')) && (statusValue === 'Suspended' || statusValue === 'Active' || statusValue === 'PaidOut' || statusValue === 'Paid Out' || statusValue === 'Pending' || statusValue === 'Closed Replaced')) {
                        updateMap[element.guid] = [];
                        const found = optionValues.find(element => element === statusValue);
                        if (found === undefined) {
                             optionValues.push(CommonUtills.createOptionItem(statusValue)); //R34UPGRADE
                        }
                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            options: optionValues,
                            showInUi: true,
                            value: statusValue,
                            displayValue: statusValue
                        }
                        );
                    }
                    if (element.ChangeTypeValue === 'Pending') {
                        updateMap[element.guid] = [];
                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            readOnly: true
                        }
                        );
                    }
                    if (element.ChangeTypeValue === 'Paid Out' || statusValue === 'Paid Out') {
                        updateMap[element.guid] = [];
                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            readOnly: true,
                            showInUi: true,
                            value: 'PaidOut',
                            displayValue: 'PaidOut'
                        }
                        );
                    }
                    //Added if as part of DIGI-37283
                    if (element.ChangeTypeValue === 'Cancel' && statusValue === 'Active') {
                        updateMap[element.guid] = [];
                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            readOnly: true,
                            showInUi: true,
                            value: 'Cancel',
                            displayValue: 'Cancel'
                        }
                        );
                    }
                    if (ComName === NEXTGENUC_COMPONENTS.UC && element.ChangeTypeValue === 'Modify') // Edge 138108 MAC Consumption based Start----->
                    {
                        console.log('insidemodify---->', element.ChangeTypeValue, element.guid)
                        var updateConfigMap = {};
                        updateConfigMap[element.guid] = [];
                        updateConfigMap[element.guid].push({
                            name: "Mode",
                            readOnly: true
                        });
                        // EDGE-154465 start
                        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                            //keys = Object.keys(updateConfigMap);
                            //for (let i = 0; i < keys.length; i++) {
                            await componentLoaded.updateConfigurationAttribute(element.guid, updateConfigMap[element.guid], true);
                            //}
                        }
                        // EDGE-154465 end
                    }
                    //console.log('changetypevalue1---->', element.ChangeTypeValue)
                    if (ComName === NEXTGENUC_COMPONENTS.UC && (element.ChangeTypeValue === 'Active' || element.ChangeTypeValue === 'Cancel')) {
                        var updateConfigMap = {};
                        updateConfigMap[element.guid] = [];
                        updateConfigMap[element.guid].push({
                            name: "Mode",
                            readOnly: true
                        });
                        updateConfigMap[element.guid].push({
                            name: "callingPlans",
                            readOnly: true
                        });
                        // EDGE-154465 start
                        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                            // keys = Object.keys(updateConfigMap);
                            //for (let i = 0; i < keys.length; i++) {
                            await componentLoaded.updateConfigurationAttribute(element.guid, updateConfigMap[element.guid], true);
                            // }
                        }
                        // EDGE-154465 end
                    }
                    // Edge 138108 MAC Consumption based End----->
                }
                // EDGE-154465 start
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                        await componentLoaded.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                }
                // EDGE-154465 end
            }
        }
    }
    await CalculateRemainingTerm(hookname);
    return Promise.resolve(true);
}
//Edge-120919 NGUC consumption based model new
async function calculateIsDiscountCheckNeeded(componentName) {
   
    let updateMap = {};
    var toBeUpdated = false;
    //let product = await CS.SM.getActiveSolution();//RF++
    //console.log('Product == ', product);
    if (Object.values(loadedSolutionUC.components).length > 0) {
        //for (const comp of Object.values(loadedSolutionUC.components)) {//RF++
        let comp = loadedSolutionUC.getComponentByName(componentName); //RF++
        //if (comp.name === componentName) {RF++
        //if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) { //RF++
        let configurations = comp.getConfigurations();//RF++
        //Object.values(comp.schema.configurations).forEach((config) => {//RF++
        for (let config of Object.values(configurations)) {
            /*var isEAPActiveAtt = Object.values(config.attributes).filter(isEAPActiveAT => {
                return isEAPActiveAT.name === 'isEAPActive'
            });*/ //RF++
            var isEAPActiveAtt = config.getAttribute('isEAPActive');
            /*var forceScheduleButtonAtt = Object.values(config.attributes).filter(forceScheduleButtonAt => {
                return forceScheduleButtonAt.name === 'forceScheduleButton'
            });*/ //RF++
            var forceScheduleButtonAtt = config.getAttribute('forceScheduleButton');
            if (isEAPActiveAtt && isEAPActiveAtt && (isEAPActiveAtt.value !== null || isEAPActiveAtt.value == null || isEAPActiveAtt.value == '') && (forceScheduleButtonAtt && forceScheduleButtonAtt && forceScheduleButtonAtt.value === false)) {//RF++
                if (componentName == NEXTGENUC_COMPONENTS.UC)
                    isEapActive = false;
                // EDGE-154465 start
                updateMap[config.guid] = [];
                updateMap[config.guid].push({
                    name: 'IsDiscountCheckNeeded',
                    value: false
                });
                toBeUpdated = true;
                config.status = true;
                config.message = '';
            } else if (isEAPActiveAtt && isEAPActiveAtt && (isEAPActiveAtt.value == null || isEAPActiveAtt.value == '')) {
                isEapActive = false;
                updateMap[config.guid] = [];
                updateMap[config.guid].push({
                    name: 'IsDiscountCheckNeeded',
                    value: false
                });
                toBeUpdated = true;
            }
            config.status = true;
            config.message = '';
            // EDGE-154465 end
            if (toBeUpdated === true) {
                if (updateMap && Object.keys(updateMap).length > 0) {
                    await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);
                }
            }//RF++ added within loop
        }//);
        // }
        /*if (toBeUpdated === true) {//RF++
            if (updateMap && Object.keys(updateMap).length > 0) {
                keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
            // EDGE-154465 end
        }*/
        // }
        // }
    }
    return Promise.resolve(true);
}
async function updateplanlookup(guid, attributeValue) {
   
    var attribute;
    let updatelookup = {};
    let inputMap = {};
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type &&
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);//RF++
        for (const config of Object.values(comp.schema.configurations)) {
            if (config.guid === guid) {
                inputMap['priceItemId'] = attributeValue;
                await currentBasketUC.performRemoteAction('SolutionGetAllowanceData', inputMap).then(
                    async function (response) {
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
                                // EDGE-154465 start
                                updatelookup[config.guid] = [];
                                updatelookup[config.guid].push({
                                    name: 'PlanAllowance',
                                    value: allowanceRecId,
                                    displayValue: allowanceValue
                                });
                            }
                        }
                        if (updatelookup && Object.keys(updatelookup).length > 0) {
                            // let keys = Object.keys(updatelookup);
                            //for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(config.guid, updatelookup[config.guid], true);
                            //}
                        }
                        // EDGE-154465 end
                    });
            }
        }
    }
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
* Author   : Tihomir Baljak
* Method Name : UpdateAttributesForMacdOnSolution
* Invoked When: after solution is loaded , after save
* Description : Updates attribute visibility and readOnly value depending on ChangeType for mac basket for UC Device & Accessory
********************************************************************************************************************************************/
UpdateAttributesForMacdOnSolution = async function () { //RF++ updated signature
   
    if (window.BasketChange !== 'Change Solution') return;
    let changeTypeAtrtribute;
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type &&
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {// EDGE-154465
            // EDGE-154465 start
            changeTypeAtrtribute = Object.values(Object.values(loadedSolutionUC.schema.configurations)[0].attributes).filter(obj => { //RF++
                return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
            });
            // EDGE-154465 end
            if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                await updateCancellationReason(loadedSolutionUC.schema.name, Object.values(loadedSolutionUC.schema.configurations)[0].guid, true)// EDGE-154465 //RF++
            } else {
                await updateCancellationReason(loadedSolutionUC.schema.name, Object.values(loadedSolutionUC.schema.configurations)[0].guid, false);// EDGE-154465 //RF++
            }
            Object.values(loadedSolutionUC.components).forEach((comp) => { //RF++
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {
                        // EDGE-154465 start                      
                        /*changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                            return obj.name === 'ChangeType'
                        });*/ //RF++
                        changeTypeAtrtribute = config.getAttribute('ChangeType');
                        // EDGE-154465 end
                        if (changeTypeAtrtribute /*&& changeTypeAtrtribute.size > 0*/) {//RF++
                            UpdateAttributeVisibilityForMacd(comp.name, config.guid, changeTypeAtrtribute.value)// EDGE-154465 //RF++
                        }
                    });
                }
            });
        }
    }
}
/****************************************************************************************************
* Author : Aditya Pareek
* Method Name : checkConfigurationSubscriptionsForNGUC
* Defect/US # : EDGE-125042
* Invoked When: Raised MACD on Suspended Subscription
* Description :Update the Change Type of NGUC NG Voice to Cancel if subscriptions are suspended
************************************************************************************************/
checkConfigurationSubscriptionsForNGUC = async function (hookname) {
   
    console.log('checkConfigurationSubscriptionsForNGUC');
    var componentMap = {};
    var updateMap = {};
    var solutionComponent = false;
    // let solution = await CS.SM.getActiveSolution(); //RF++
    console.log('Cmp Map --->', componentMap);
    if (loadedSolutionUC.name == NEXTGENUC_COMPONENTS.solution) { //RF++
        //Added for Edge 143957
        // Edge 138108 MAC Consumption based Start----->
        if (Object.values(loadedSolutionUC.schema.configurations)[0].replacedConfigId) {//RF++
            solutionComponent = true;
            await checkConfigurationSubscriptionsForNGUCForEachComponent(loadedSolutionUC, solutionComponent, hookname);
        }
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {//RF++
            for (let comp of Object.values(loadedSolutionUC.components)) {//RF++
                solutionComponent = false;
                await checkConfigurationSubscriptionsForNGUCForEachComponent(comp, solutionComponent, hookname);
            }
            // Edge 138108 MAC Consumption based End----->
        }
    }
    return Promise.resolve(true);
} //Aditya changes for EDGE-133963
updatecontracttypeattributes = async function () {//RF++ Updated signature 
      
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {/// EDGE-154465 removed solution.type && //RF++            
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {// EDGE-154465      //RF++
            for (let comp of Object.values(loadedSolutionUC.components)) {
                {//RF++
                    if (comp.name === NEXTGENUC_COMPONENTS.Device || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.Accessory || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                        let updateMap = {};
                        //if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465 //RF++
                        let configurations = comp.getConfigurations();//RF++
                        for (let config of Object.values(configurations)) {// EDGE-154465   //RF++                        
                            /*var contracttype = Object.values(config.attributes).filter(attr => {// EDGE-154465
                                return attr.name === 'ContractType'
                            });*/ //RF++
                            var contracttype = config.getAttribute('ContractType');
                            if (contracttype /*&& contracttype.length > 0*/) {//RF++
                                // EDGE-154465 start
                                if (contracttype.displayValue === 'Purchase') {//RF++
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "ContractTerm",
                                        showInUi: false,
                                        //value: "NA"
                                    });
//EDGE-169456 - Commenting below code For hiding Pricing Attribute Recurring charge for pricing service.
                                   /* updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: true
                                    });*/
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({   //Added EDGE-175750
                                        name: "RedeemFundIncGST",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: true
                                    });
									// Added as part of INC000095180309 || start
									 updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: false
                                    });
									// Added as part of INC000095180309 || End
//EDGE-169456 - Commenting below code For hiding Pricing Attribute UnitPriceIncGST for pricing service.
                                   /* updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: true
                                    });*/
                                } else if (contracttype.displayValue === 'Hardware Repayment' && window.BasketChange !== 'Change Solution') {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({//PD
                                        name: "ContractTerm",
                                        showInUi: true,
                                    });
                                    updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: false,
                                        value: 0.00
                                    });
                                    updateMap[config.guid].push({   //Added EDGE-175750
                                        name: "RedeemFundIncGST",
                                        showInUi: false,
                                        value: 0.00
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: false
                                    });
                                } else if (contracttype.displayValue === 'Rental' && window.BasketChange !== 'Change Solution') {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "ContractTerm",
                                        showInUi: false,
                                    });
                                    updateMap[config.guid].push({
                                        name: "OC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: false,
                                        value: 0.00
                                    });
                                    updateMap[config.guid].push({   //Added EDGE-175750
                                        name: "RedeemFundIncGST",
                                        showInUi: false,
                                        value: 0.00
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: false
                                    });
                                } else if ((contracttype.displayValue === 'Hardware Repayment' || contracttype.displayValue === 'Rental') && window.BasketChange === 'Change Solution') {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({//PD
                                        name: "ContractTerm",
                                        showInUi: true
                                    });
									// Added as part of INC000095180309 || start
									 updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: true
                                    });
									// Added as part of INC000095180309 || End
                                    updateMap[config.guid].push({
                                        name: "OC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({   //Added EDGE-175750
                                        name: "RedeemFundIncGST",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: false
                                    });
                                } else {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({//PD
                                        name: "ContractTerm",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OC",
                                        showInUi: false
                                    });
                                }
                            }
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);//RF++
                            }
                        }
                        /* if (updateMap && Object.keys(updateMap).length > 0) {//RF++
                            let keys = Object.keys(updateMap);
                            console.log('initializeOEConfigs updateMap:', updateMap);
                            for (var i = 0; i < keys.length; i++) {
                                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                            }
                        }*/
                        // EDGE-154465 end
                        //  }
                    }
                }
                //}
            }
            return Promise.resolve(true);
        }
    }
}
/**********************************************************************************************************************************************
 * Author   : Venkata Ramanan G
 * Method Name : populateRateCardinAttachment
 * Invoked When: after solution is loaded
 ********************************************************************************************************************************************/
async function populateRateCardinAttachment() { // RF++ Move this to UIPlugin
    
    var c = 0;
    console.log(' Inside populateRateCardinAttachment!!!! ');
    if (basketStage !== 'Contract Accepted' || ratecardloaded)
        return;
    var configMap = [];
    //let currentSolution = await CS.SM.getActiveSolution(); //RF++
    // console.log('populateRateCardinAttachment ', currentSolution);
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type &&
        //console.log('addDefaultOEConfigs - looking components', currentSolution);
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);//RF++
        //if (currentSolution.components && Object.values(currentSolution.components).length > 0) {// EDGE-154465 //RF++
        //for (const comp of Object.values(currentSolution.components)) {// EDGE-154465 //RF++
        //if (comp.name === NEXTGENUC_COMPONENTS.UC) { //RF++
        if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
            let inputMap = {};
            inputMap['basketid'] = basketId;
            inputMap['Offer_Id__c'] = 'DMCAT_Offer_000618';
            inputMap['SolutionId'] = loadedSolutionUC.id;//RF++
            // let loadedSolutionUC = await CS.SM.getActiveSolution();// EDGE-154465 //RF++
            //let currentBasketUC = await CS.SM.getActiveBasket();// EDGE-154465 //RF++
            inputMap['GetBasket'] = basketId;
            await currentBasketUC.performRemoteAction('TierRateCardNCSHelper', inputMap).then(
                function (response) {
                    if (response && response['UCRateCard'] != undefined) {
                        console.log('UCRateCard', response['UCRateCard']);
                    }
                });
        }
        // }
        // }
        // }
    }
    //return Promise.resolve(true);
}
/**********************************************************************************************************************************************
* Author   : Tihomir Baljak
* Method Name : updateOeTabsVisibility
* Invoked When: after solution is loaded, after ChangeType is changed
* Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
* Parameters  : configuration guid or nothing
********************************************************************************************************************************************/
updateOeTabsVisibilityNGUC = async function (configGuid) {
    
    if (window.basketStage !== "Contract Accepted") return Promise.resolve(true);
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type &&
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (const comp of Object.values(loadedSolutionUC.components)) {
                const config = comp.getConfiguration(configGuid);

                if (config && config.disabled === false) {
                    if (config && config.attributes && Object.values(config.attributes).length > 0) {
                        // Arinjay Commented and Modified 20th oct - Optimization
                        // let changeTypeAtrtribute = Object.values(config.attributes).find(obj => // EDGE-154465
                        //     obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
                        // );
                        let changeTypeAttribute = config.getAttribute("ChangeType");
                        if( changeTypeAttribute.value === null || changeTypeAttribute.value === "None" || changeTypeAttribute.value === "New" ){
                            continue;
                        }
                        if ((window.BasketChange === 'Change Solution' && changeTypeAttribute && changeTypeAttribute.value === "Cancel") ||

                        !Utils.isOrderEnrichmentAllowed()) {
                        CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
                        //console.log('updateOeTabsVisibility - hiding:', comp.name, config.guid);
                    } else {
                        if (comp.name === NEXTGENUC_COMPONENTS.UC /*|| comp.name === NEXTGENUC_COMPONENTS.UcComponent*/) {
                            CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Customer requested Dates', 'NumberManagementv1']);
                        } else {
                            CS.SM.setOEtabsToLoad(comp.name, config.guid, undefined);
                        }
                        //console.log('updateOeTabsVisibility - showing:', comp.name, config.guid);
                    }
                }
            }
        }

}

    }
    return Promise.resolve(true);
}
UpdateMainSolutionChangeTypeVisibility = async function () {//RF++
    
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    let updateMap = {};
    let guid = Object.values(loadedSolutionUC.schema.configurations)[0].guid;
    updateMap[guid] = [];
    updateMap[guid].push({// EDGE-154465
        name: 'ChangeType',
        showInUi: true,
    });
    if(window.basketType === 'Outgoing'){
        updateMap[guid].push({// EDGE-154465
            name: 'ChangeType',
            showInUi: false,
        }); 
    }
    console.log('UpdateMainSolutionChangeTypeVisibility', updateMap);
    //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.solution, updateMap, true).catch((e) => Promise.resolve(true)); PD
    let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.solution);//RF++
    if (updateMap && Object.keys(updateMap).length > 0) {
        // keys = Object.keys(updateMap);
        // for (let i = 0; i < keys.length; i++) {
        await comp.updateConfigurationAttribute(guid, updateMap[guid], true);
        // }
    }
}
updateCancellationReason = async function (componentName, guid, isVisible) {
   
    console.log('updateCancellationReason', componentName, guid, isVisible);
    // EDGE-154465 start
    let updateMap = {};
    updateMap[guid] = [];
    updateMap[guid].push({//PD
        name: 'CancellationReason',
        readOnly: false,
        showInUi: isVisible,
        required: false
    });
    //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);PD
    //let currentSolution = await CS.SM.getActiveSolution(); //RF++
    let component = loadedSolutionUC.getComponentByName(componentName); //RF++
    if (updateMap && Object.keys(updateMap).length > 0) {
        //let keys = Object.keys(updateMap);
        //for (let i = 0; i < keys.length; i++) {//RF++
        let complock = component.commercialLock;
        if (complock) {component.lock("Commercial", false);}
        await component.updateConfigurationAttribute(guid, updateMap[guid], true);
        if (complock) component.lock("Commercial", true);
        // }
    }
    // EDGE-154465
}
// Edge 138108 MAC Consumption based Start----->
UpdateVisibilityBasedonContracttype = async function (config, hookname, remainingTerm, componentName) {
    
    if (((hookname === 'afterSolutionLoaded' || hookname === 'afterSave' || hookname === 'afterConfigurationAddedToMacBasket') && config.id != null)) {
        let contractTypevalue = config.getAttribute('ContractType');
        let RemainingTermValue = config.getAttribute('RemainingTerm');
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS)
            && window.BasketChange === 'Change Solution' && contractTypevalue.displayValue === 'Purchase'//RF++
            && config.replacedConfigId) //Aditya for NGUC MACD EDGE-121389---Start--->
        {
            console.log('insidemodify---->', contractTypevalue, RemainingTermValue)
            var updateConfigMap = {};
            // EDGE-154465 start          
            updateConfigMap[config.guid] = [];
            updateConfigMap[config.guid].push({//PD
                name: "ChangeType",
                value: "PaidOut",
                displayValue: "Paid Out",
                readOnly: true
            });
            let component = await loadedSolutionUC.getComponentByName(componentName);//RF++
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                await component.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
            }
            // EDGE-154465 end
        }
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && window.BasketChange === 'Change Solution' && contractTypevalue.displayValue === 'Hardware Repayment' && remainingTerm <= 0 && config.replacedConfigId) //Aditya for NGUC MACD EDGE-121389---Start--->//RF++
        {
            // EDGE-154465 start
            var updateConfigMap = {};
            updateConfigMap[config.guid] = [];
            updateConfigMap[config.guid].push({//PD
                name: "ChangeType",
                value: "PaidOut",
                displayValue: "Paid Out",
                readOnly: true
            });
            let component = await loadedSolutionUC.getComponentByName(componentName);
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                await component.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
            }
            // EDGE-154465 end                
        }
    }
}
// EDGE-154465 start
async function updateUCEPlugin(UCEPlugin) { // EDGE-154465  

    //Edge-120921 Added by shubhi dynamic config name population end      
    window.document.addEventListener('SolutionSetActive', async function (e) { // EDGE-154465
        //added by shubhi for EDGE-170148
       
        currentBasketUC = await CS.SM.getActiveBasket();
        loadedSolutionUC = await CS.SM.getActiveSolution();
        basketId = currentBasketUC.basketId;//RF++
        // EDGE-154465 start
        if (loadedSolutionUC.name === NEXTGENUC_COMPONENTS.solution) {
            //Added by Aditya for Deal Price
            window.addEventListener('message', UCEPlugin_handleIframeMessage);
            await CommonUtills.getBasketData(currentBasketUC);//RF++
            await CommonUtills.getSiteDetails(currentBasketUC);
            if (basketLockStages.contains(basketStage)) {
                loadedSolutionUC.lock('Commercial', false);
            }
            if (accountId != null) {
                await CommonUtills.setAccountID(NEXTGENUC_COMPONENTS.solution, accountId);
            }
            // EDGE-154465 end
            window.currentSolutionName = loadedSolutionUC.name;
            //Added by romil EDGE-113083, EDGE-115925,EDGE-136954,EDGE-144161
            // Added for EDGE-138001
            RedemptionUtilityCommon.calculateBasketRedemption(loadedSolutionUC);//EDGE-169593     //RF++ 
			//EDGE-208940----
			basketName = await CS.SM.getBasketName();
            await RedemptionUtilityCommon.calculateCurrentFundBalanceAmt(basketName, currentBasketUC);//EDGE-169593// RF++ updated function name spell corrected			
            await Utils.loadSMOptions();
            // EDGE-154465 start          
            // let inputMap = {};
            // inputMap['GetBasket'] = basketId;
            // inputMap['GetSiteId'] = '';
            Utils.updateCustomButtonVisibilityForBasketStage();
            Utils.updateOEConsoleButtonVisibility();
            //Utils.updateImportConfigButtonVisibility();
            // Aditya: Edge:142084 Enable New Solution in MAC Basket
            CommonUtills.setBasketChange();
            //Vijay: DIGI-456 start...
			var activeNGUCBasket = await CS.SM.getActiveBasket();
			await Utils.updateOEConsoleButtonVisibility_v2(activeNGUCBasket, 'oeNGUC');
			//Vijay: DIGI-456 ...end
            //Method call to create User related Product automatically.              
            //await updateConfigName_Accesory(); //edge120921 PD Commented on 03.09.2020 //RF++
            await genericUpdateConfigName(NEXTGENUC_COMPONENTS.AccessoryMTS, NEXTGENUC_COMPONENTS.Accessory);
            //await updateConfigName_Device(); //edge-120921 //RF++
            await genericUpdateConfigName(NEXTGENUC_COMPONENTS.DevicesMTS, NEXTGENUC_COMPONENTS.Device);//RF++
			
           // await populateRateCardinAttachment(); //Comment as part of EDGE-189340
            await updateChangeTypeAttributeNGUC();// Updated name to resolve
			
			if(!window.isToggled){//Added by vijay DIGI-456
				UCEPlugin_setOEtabsforUC();
				await Utils.addDefaultGenericOEConfigs(DEFAULTSOLUTIONNAME_NGUC); //RF++
				//await addDefaultUCOEConfigs();
				await updateOeTabsVisibilityNGUC(); //RF+
            }else{//Added by vijay DIGI-456 || start
                CommonUtills.oeErrorOrderEnrichment();
            }
            //Added by vijay DIGI-456 ||End
            await updatecontracttypeattributes();//RF++ removed param from signature
            // Edge 138108 MAC Consumption based
            //await checkConfigurationSubscriptionsForNGUC('afterSolutionLoaded');
            //pricingUtils.resetCustomAttributeVisibilityNGUC_Device(); //added by Aditya for 133963 //RF++ check with Vimal
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //added by Romil for EDGE-144161
            var showRateCart = false;
            //Added by Aman Soni as a part of EDGE-142082 || Start
            var solutionComponent = false;
            var componentMap = new Map();
            var componentMapattr = {};
            if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {//EDGE-154465
                let config = Object.values(loadedSolutionUC.getConfigurations())[0];//RF++
                if (config.replacedConfigId && config.replacedConfigId !== null) {//EDGE-154465
                    solutionComponent = true;
                    billingAccLook = config.getAttribute('BillingAccountLookup');//RF++
                    componentMapattr['BillingAccountLookup'] = [];
                    componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
                    //componentMap.set(Object.values(loadedSolutionUC.schema.configurations)[0].guid, componentMapattr);//EDGE-154465 RF++
                    componentMap.set(config.guid, componentMapattr); //RF++
                    await CommonUtills.attrVisiblityControl(NEXTGENUC_COMPONENTS.solution, componentMap);
                    //if (billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni //RF++
                    if (billingAccLook.value === null || billingAccLook.value === '')//RF++
                    {
                        CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                    }
                }
                /*if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
                    Object.values(loadedSolutionUC.components).forEach((comp) => {
                        solutionComponent = false;
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            Object.values(comp.schema.configurations).forEach((config) => {
                                if (config.replacedConfigId !== null) {
                                    //CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.Device,'initialActivationDate',solutionComponent);
                                    //CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.Device,'BillingAccountNumber',solutionComponent);
                                }
                            });
                        }
                    });
                }*/// RF++
            }
            //Added by Aman Soni as a part of EDGE-142082 || End
            if (window.totalRedemptions > 0) {
                RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.UC, '');//EDGE-169593
                RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.AccessoryMTS, '');//EDGE-1695930
            }
            if (window.BasketChange === 'Change Solution') {
				await checkConfigurationSubscriptionsForNGUC('afterSolutionLoaded'); //EDGE-189501
                await UpdateMainSolutionChangeTypeVisibility();//RF++
                await UpdateChangeTypeVisibility();
                await UpdateAttributesForMacdOnSolution();
            }
            //Added by Shubhi as a part of EDGE-133963 
			
			// Added as part of EDGE-207736  || start
			if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)){
				for (let comp of Object.values(loadedSolutionUC.components)) {
					if(comp.name == NEXTGENUC_COMPONENTS.UC){	
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							for (let config of Object.values(comp.schema.configurations)) {
								updateBSConfigName(NEXTGENUC_COMPONENTS.UC,config,false); 
							}
						}
					}
				}	
			}
            // Added as part of EDGE-207736  || End		
            updateButtonConfigButtonVisibility();	
            pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
            pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
            // Added for EDGE-138001
            //Added for Pricing Services 
            PRE_Logic.init(loadedSolutionUC.name);
            PRE_Logic.afterSolutionLoaded();
           // PRE_Logic.afterSolutionLoaded();
           
            if (basketLockStages.contains(basketStage)) {
                loadedSolutionUC.lock('Commercial', true);
            }
            //END changes for EDGE-138001
            //Added for EDGE-138108
            return Promise.resolve(true);
        }
        return Promise.resolve(true);
    });
    UCEPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {//PD added async
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
        //Added by romil EDGE-118038,EDGE-136954
        var skipsaveDevice = pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        var skipsaveVoice = pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);

        console.log('before save == ', solution);
        if (skipsaveDevice == true || skipsaveVoice == true) {
            // skipsave = false; //RF++
            return Promise.resolve(false); // EDGE-154465
        }
		if (window.basketChangeType != undefined && window.basketChangeType == "Change Solution" && window.basketStage == 'Contract Accepted'){
			var isValidTeanacy=await checkTenecyIdValidation(solution)
            if(isValidTeanacy==true){
				return Promise.resolve(false);
			};		
		}
        if (window.totalRedemptions > 0) {
            var skipdevicesave = await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.UC, '');//EDGE-169593
            var skipaccsave = await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.AccessoryMTS, '');//EDGE-1695930
            if (skipdevicesave || skipaccsave)
                return Promise.resolve(false);//EDGE-1695930
        }
        if (!validateCancelSolution()) {
            return Promise.resolve(false);
        }
		//Added below validation as a part of EDGE-185639
		var isExpectedSIOPopulated = await CommonUtills.validateExpectedSIO();
        if(!isExpectedSIOPopulated) {
            return Promise.resolve(false);
        }
        /* if (saveNgUC) {
             saveNgUC = false;
             console.log('beforeSave - exiting true');
             return Promise.resolve(true);
         }
         executeSaveNgUC = true;
         */ //RF++
        //Added for Pricing Services
		//added as part of EDGE-204030|| start
		addDeviceToBusinessCalling(solution); 
		if(window.basketStage == "Contract Accepted"){
            if(window.basketChangeType == "Change Solution"){
				addBusinessCallingId(solution);
			}else{
				addPCIdIntoDevice(solution);
			}
			
		}
		//added as part of EDGE-204030|| end
        PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
        
        return Promise.resolve(true);// EDGE-154465
    }
    //EDGE-207736 Append Auto-number when multiple business callings are added in basket - Starts//
    UCEPlugin.afterConfigurationClone = async function (component, configuration, clonedConfiguration) {
		console.log("Inside afterConfigurationClone--->", component.name, configuration,window.basketStage);	
			if ((component.name === NEXTGENUC_COMPONENTS.UC ) && (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft")) {

                // Added as part of EDGE-207736  || start
				for (var config of configuration) {
					updateBSConfigName(component.name,config,true); 
				}
				// Added as part of EDGE-207736  || end
			return Promise.resolve(true);
		}

	}
    //EDGE-207736 Append Auto-number when multiple business callings are added in basket - End//
    UCEPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        try {
            let solution = result.solution;
        if (basketLockStages.contains(basketStage)) {
            solution.lock('Commercial', false);
        }
        // Edge 138108 MAC Consumption based
        await checkConfigurationSubscriptionsForNGUC('afterSave');
        //console.log('afterSave - entering', solution);
        //Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954,EDGE-144161
        RedemptionUtils.calculateBasketRedemption(currentBasketUC, basketName);//RF++
        var showRateCart = false
        //Added by Aman Soni as a part of EDGE-142082 || Start
        var solutionComponent = false;
        if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {
            let configurations = solution.getConfigurations(); //RF++
            if (Object.values(configurations).length > 0) { // EDGE-154465
                solutionComponent = true;
                let componentMapASave = new Map(); //RF++
                let componentMapattrAftSave = {}; //RF++
                // Object.values(solution.schema.configurations).forEach((config) => {// EDGE-154465 //RF++
                for (let config of Object.values(configurations)) {
                    if (config.replacedConfigId && config.replacedConfigId != null) {
                        // Object.values(config.attributes).forEach((attr) => { //RF++ this loop is not needed
                        /*var billingAccLook = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(a => { // EDGE-154465
                            return a.name === 'BillingAccountLookup'
                        });*/ //RF++
                        let billingAccLook = config.getAttribute('BillingAccountLookup');
                        /*if (billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                        {
                            CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                        }*/ //RF++
                        if (billingAccLook.value === null || billingAccLook.value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                        {
                            CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                        }
                        componentMapattrAftSave['BillingAccountLookup'] = [];
                        componentMapattrAftSave['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
                        componentMapASave.set(config.guid, componentMapattrAftSave);
                        //  });
                    }
                }
                //});
                CommonUtills.attrVisiblityControl(NEXTGENUC_COMPONENTS.solution, componentMapASave);
            }
			
        }
		// Added as part of EDGE-207736  || start
		if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)){
			for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.UC){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							updateBSConfigName(NEXTGENUC_COMPONENTS.UC,config,false); 

                        }
					}
				}
            }
			
            
		}
		// Added as part of EDGE-207736  || end
        //Added by Aman Soni as a part of EDGE-142082 || End
        if (window.BasketChange === 'Change Solution') {
            await UpdateAttributesForMacdOnSolution();
            await updateChangeTypeAttributeNGUC();// updated name to resolve conflicts// RF++ added with condn
            await UpdateChangeTypeVisibility();// RF++ added with condn
            await UpdateMainSolutionChangeTypeVisibility();// RF++ added with condn
            // pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart); RF++
        }
        //Added by Aman Soni as a part of EDGE-133963 || Start
        /* if (window.currentSolutionName === NEXTGENUC_COMPONENTS.solution) {
             Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
             Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
             Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
         }*/ //RF++
        /*subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS); //added by Shubhi for EDGE-143957
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC); //added by Shubhi for EDGE-143957*/ //RF++
        //Added by Aman Soni as a part of EDGE-133963 || End
        //UCEPlugin.setOEtabsforUC();//RF++
        await updatecontracttypeattributes();
        // pricingUtils.resetCustomAttributeVisibilityNGUC_Device(); //added by Aditya for 133963 //RF++
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //romil for 144161
        //Addde  for 138001
        //Utils.updateImportConfigButtonVisibility(); //RF++
        Utils.hideSubmitSolutionFromOverviewTab(); //EDGE-135267
        // Edge 138108 MAC Consumption based
        // await checkConfigurationSubscriptionsForNGUC('afterSave'); RF++
        //Added for EDGE-138108          
        //await updateConfigName_Accesory(); //edge120921 //RF++
        await genericUpdateConfigName(NEXTGENUC_COMPONENTS.AccessoryMTS, NEXTGENUC_COMPONENTS.Accessory); //RF++
        await genericUpdateConfigName(NEXTGENUC_COMPONENTS.DevicesMTS, NEXTGENUC_COMPONENTS.Device);
		//RF++
        //await updateConfigName_Device(); //edge-120921 //RF++
        await Utils.updateActiveSolutionTotals();
        await CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade  
        //Added for Pricing Services
        PRE_Logic.afterSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
        if (basketLockStages.contains(basketStage)) {
            solution.lock('Commercial', true);
        }
    } catch (error) {
        CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
        console.log(error);
    }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
        return Promise.resolve(true);
    }
    UCEPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) {
        //console.log('UCE afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration)
        //await initializeUCOEConfigs();//RF++
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        //await checkConfigurationSubscriptionsForNGUCForEachComponent(component, true, 'afterSave'); RF++
        return Promise.resolve(true);
    }
    UCEPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    }
    //Aditya: Spring Update for changing basket stage to Draft
    UCEPlugin.afterSolutionDelete = function (solution) {
        if (window.totalRedemptions > 0)
            RedemptionUtilityCommon.calculateBasketRedemption(loadedSolutionUC);//EDGE-169593//RF++
        CommonUtills.updateBasketStageToDraft();
        //Added for Pricing Services
        refreshPricingSummeryWidget();
        return Promise.resolve(true);
    }
    UCEPlugin.beforeConfigurationAdd = async function (component, configuration) {
        await UCEPlugin_RewokeConfigurationOnCancel();
        return Promise.resolve(returnflag);
    }
    UCEPlugin.afterConfigurationAdd = async function (component, configuration) {
        var updatemap = {}; // EDGE-154465
        //Added by romil EDGE-115925,EDGE-136954      
        RedemptionUtils.populateNullValues(component, configuration);
        //Added by Aman Soni as a part of EDGE-133963 || Start
        pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);//RF++
        pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);//RF++
        await calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.DevicesMTS); //Edge-120919
        await calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.UC); //Edge-120919      
        //added by shubhi for voice/device pricing end
        /*subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS);
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC);*/ //RF++
        //Added for Pricing Services
        //Added to populate billing account lookup as part of DIGI-27422
        if(component.name === NEXTGENUC_COMPONENTS.UC || component.name === NEXTGENUC_COMPONENTS.DevicesMTS || component.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {   
            if (window.accountId !== null && window.accountId !== "") {
					CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
					await CHOWNUtils.getParentBillingAccount(NEXTGENUC_COMPONENTS.solution);
					if(parentBillingAccountATT){                          
                            CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name,'');
					}
			}
        }
        //DIGI-27422 ended
        PRE_Logic.afterConfigurationAdd(component.name,configuration);
        return Promise.resolve(true);
    }
    /*
    */
    UCEPlugin.afterConfigurationAddedToMacBasket = async function (componentName, guid) {
        let solution = await CS.SM.getActiveSolution();
        let component = solution.getComponentByName(componentName);
        if (basketLockStages.contains(basketStage)) {
            loadedSolutionUC.lock('Commercial', false);
        }
        try {
            console.log('afterConfigurationAdd', componentName, guid);
            var updatemap = {};//PD
            if (componentName === NEXTGENUC_COMPONENTS.UC) {
                updatemap[guid] = [];
                // EDGE-154465 start
                //updateConupdateMapfigMap[guid].push({
                updatemap[guid].push({
                    name: "ChangeType",
                    options: [{
                        "value": "Modify",
                        "label": "Modify"
                    },
                    {
                        "value": "Cancel",
                        "label": "Cancel"
                    },
                    {
                        "value": "Active",
                        "label": "Active"
                    }
                    ],
                    showInUi: true
                });
                // EDGE-154465 end
            }
            if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                updatemap[guid] = [];
                updatemap[guid].push({ // EDGE-154465 start
                    name: "Quantity",
                    readOnly: true
                }); // EDGE-154465 end
            }
            // EDGE-154465 start
            //CS.SM.updateConfigurationAttribute(componentName, updatemap, true);
             let keys = Object.keys(updatemap);
             for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updatemap[keys[i]], false);
            }
            // EDGE-154465 end
            // Edge 138108 MAC Consumption based
            await checkConfigurationSubscriptionsForNGUC('afterConfigurationAddedToMacBasket');
            //Added for EDGE-138108
            //UCEPlugin.UpdateVisibilityBasedonContracttype();
            //Reset CRDs when PCs added to MAC basket - moved this from MACD Observer as part of Spring20 upgrade
            if (window.BasketChange === 'Change Solution') {
                if (solution.components && Object.values(solution.components).length > 0) {
                    for (const comp of Object.values(solution.components)) {
                        if (comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.UC) {
                            await validateOERules.resetCRDDatesinOESchema_ALL(solution.name, comp.name);
                        }
                    }
                }
            }
            // Arinjay 11 Aug Start
            // UpdateMainSolutionChangeTypeVisibility(solution);
            let config = Object.values(component.schema.configurations)[0];
            changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                return obj.name === 'ChangeType'
            });
            UpdateAttributeVisibilityForMacd(componentName, guid, changeTypeAtrtribute[0].value);
			CommonUtills.CloneOrderEnrichment(componentName, guid); // Added By vijay DIGI-456
			if(changeTypeAtrtribute[0].value =='Active'){
				AttributeReadOnly(solution,guid);
			}
            // Arinjay 11 Aug End
            if (basketLockStages.contains(basketStage)) {
                loadedSolutionUC.lock('Commercial', true);
            }        }
        catch (err) {
            console.log('test afterConfigurationAddedToMacBasket');
            console.log(err);
        }
        return Promise.resolve(true);
    }

    

    UCEPlugin.afterConfigurationDelete = async function (component, configuration) {
        console.log('Parent Config Delete - After', component, configuration);
        //Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954
        if (window.totalRedemptions > 0)
            RedemptionUtilityCommon.calculateBasketRedemption(loadedSolutionUC);//EDGE-169593//RF++
        //Added for Pricing Services    
        PRE_Logic.afterConfigurationDelete(component,configuration);    
    }
    UCEPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {// EDGE-154465
        
        let componentName = component.name; // EDGE-154465
        let guid = configuration.guid; // EDGE-154465
        console.log('Attribute Update - After', componentName, configuration, attribute, oldValueMap);// EDGE-154465
        //let solution = await CS.SM.getActiveSolution();//RF++
        //EDGE-207736 Append Auto-number when multiple business callings are added in basket - Starts//
        if((attribute.name==='Mode' || attribute.name==='callingPlans') && oldValueMap['value'] != attribute.value && attribute.value !== "" && attribute.value !== null)
        {

            updateBSConfigName(componentName,configuration,true);// Added as part of EDGE-207736   

        }
        //EDGE-207736 Append Auto-number when multiple business callings are added in basket - End//
        if (basketLockStages.contains(basketStage)) {
            loadedSolutionUC.lock('Commercial', false);//RF++
        }
        if (componentName === NEXTGENUC_COMPONENTS.solution) {
            await CommonUtills.genericUpdateSolutionName(component, configuration, DEFAULTOFFERNAME_NGUC, DEFAULTOFFERNAME_NGUC);//RF++
            //Added as part of DIGI-36370 to populate billing account on solution billing account change
            if (attribute.name === 'BillingAccountLookup' && oldValueMap['value'] != attribute.value && (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft')) {
                await CHOWNUtils.getParentBillingAccount(NEXTGENUC_COMPONENTS.solution);
                if(parentBillingAccountATT){
                    CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '',NEXTGENUC_COMPONENTS.AccessoryMTS,oldValueMap['value']);
                    CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NEXTGENUC_COMPONENTS.DevicesMTS,oldValueMap['value']);
                    CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NEXTGENUC_COMPONENTS.UC,oldValueMap['value']);
                }
            }
            //DIGI-36370 ended
        }
        if ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && (attribute.name === 'DisconnectionDate' || attribute.name === 'RedeemFund' || attribute.name === 'EarlyTerminationCharge' || (attribute.name === 'ChangeType' && attribute.displayValue === 'Cancel'))) {//Added change type condition for DIGI-9268
            //Added if condition for DeviceMTS and AccessoryMTS for EDGE-193480
			if(!(componentName === NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.DevicesMTS)){
				UCEPlugin_validateDisconnectionDate(componentName, guid, attribute.value);//RF++ added this call as it is needed for ETC calculation
            }
            UCEPlugin_calculateTotalETCValue(guid);
            //added by Romil EDGE-130075,EDGE-136954
            if (attribute.name === 'EarlyTerminationCharge')
                RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //EDGE-169593              
        } //EDGE-81135 : Cancellation of CMP
        if (attribute.name === 'RedeemFund') {
            await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, attribute.value); //EDGE-169593
            await RedemptionUtilityCommon.calculateBasketRedemption(loadedSolutionUC); //EDGE-169593 //RF++
            if (attribute.value >= 0) {
                await RedemptionUtilityCommon.validateBasketRedemptions(false, componentName, '');//EDGE-169593
            }
            calcDeviceRedeemFundGST(guid, attribute.value, componentName); //Added EDGE-175750
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC  /*||componentName === NEXTGENUC_COMPONENTS.UcComponent ||componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS*/) && attribute.name === 'DisconnectionDate') {//RF++
            UCEPlugin_validateDisconnectionDate(componentName, guid, /*newValue*/attribute.value);// EDGE-154465
        }
        if (componentName === 'Order primary Contact' && attribute.name === 'Order Primary Contact') {
            await updateOrderPrimaryContactOnUC(guid, /*newValue*/attribute.value);// EDGE-154465
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && attribute.name === 'Mode') {
            await updateplanlookup(guid, /*newValue*/attribute.value);// EDGE-154465
            calculateIsDiscountCheckNeeded(componentName);
            if (isEapActive) {
                Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'callingPlans', true);
                pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Edge-120919 NGUC consumption based model new
                pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya
            }
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && attribute.name === 'callingPlans') {
            await updateplanlookup(guid, /*newValue*/attribute.value);///EDGE-162560 // EDGE-154465
            calculateIsDiscountCheckNeeded(componentName);
            if (isEapActive) {
                pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Edge-120919 NGUC consumption based model new
                pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya
            }
        }
        if (window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType') {
            UpdateAttributeVisibilityForMacd(componentName, guid, /*newValue*/ attribute.value);// EDGE-154465
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType' && attribute.value === 'Modify') //Aditya for NGUC MACD EDGE-121389---Start--->PD changed newValue to attribute.Value
        {
            var updateConfigMap = {};
            // EDGE-154465 start
            updateConfigMap[guid] = [];
            updateConfigMap[guid].push({
                name: "IsDiscountCheckNeeded",
                value: true
            });
            updateConfigMap[guid].push({
                name: "Mode",
                readOnly: true
            });
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                // let keys = Object.keys(updateConfigMap);
                // for (let i = 0; i < keys.length; i++) {//RF++
                await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
                // }
            }
            configuration.status = false;
            configuration.message = 'Please generate price schedule post configuration to view rate card and latest discount status';
            // EDGE-154465 end
            // Arinjay 11 Aug Start
            //pricingUtils.resetCustomAttributeVisibilityNGUC_Device(); RF++
            // Arinjay 11 Aug End
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType' && /*newValue*/ attribute.value === 'Cancel') //Aditya for NGUC MACD EDGE-121389---Start--->
        {
            var showRateCart = false;
            // EDGE-154465 start
            let updateConfigMap = {};
            updateConfigMap[guid] = [];
            updateConfigMap[guid].push({
                name: "IsDiscountCheckNeeded",
                value: false
            });
            //pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart); //RF++
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                //let keys = Object.keys(updateConfigMap);
                //for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
                //}
            }
            configuration.status = true;
            // EDGE-154465 end
        }
        //EDGE-144971 Added by Aditya for Consumption based Cancel--->Start
        if (componentName === NEXTGENUC_COMPONENTS.solution && window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType' && /*newValue*/attribute.value === 'Cancel') //Aditya for NGUC MACD EDGE-121389---Start--->
        {
            CS.SM.displayMessage('Solution level cancellation requires all business calling, unpaid device and accessories to to be cancelled', 'info');
            return false;
        }
        //EDGE-144971 Added by Aditya for Consumption based Cancel--->End
        //Aditya for NGUC MACD EDGE-121389---End--->
        //Venkat
        if (((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && (attribute.name === 'Model' || attribute.name === 'Device Type')) || ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && (attribute.name === 'Accessorymodel' || attribute.name === 'AccessoriesType'))) {
            if (attribute.value !== '')
                await populateLookupStringValues(componentName, guid, attribute.name, attribute.displayValue);
            else
                await emptyLookupAttributes(componentName, guid, attribute.name);
        }
        //added by Romil for fund Redemption EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954
        if (((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && (attribute.name === 'Model' || attribute.name === 'Device Type' || attribute.name === 'Quantity' || attribute.name === 'OC' || attribute.name === 'Device Type' || attribute.name === 'ContractType' || attribute.name === 'RedeemFund' || attribute.name === 'taxTreatment'))) {
            if (attribute.name === 'ContractType' && attribute.displayValue === 'Hardware Repayment') {
                await RedemptionUtilityCommon.validateBasketRedemptions(false, componentName, '');//EDGE-169593
            } else if (attribute.name === 'ContractType' && attribute.displayValue === 'Purchase') {
                RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //EDGE-169593
            }
            await updatecontracttypeattributes();
        }
        //added by Romil for fund Redemption EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954
        if (((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && (attribute.name === 'Accessorymodel' || attribute.name === 'AccessoriesType' || attribute.name === 'Quantity' || attribute.name === 'OC' || attribute.name === 'ContractType' || attribute.name === 'RedeemFund' || attribute.name === 'taxTreatment'))) {
            if (attribute.name === 'Accessorymodel') {
                //await updateConfigName_Accesory(); //edge120921 //RF++
                await genericUpdateConfigName(NEXTGENUC_COMPONENTS.AccessoryMTS, NEXTGENUC_COMPONENTS.Accessory);
            }
            if (attribute.name === 'ContractType' && attribute.displayValue === 'Hardware Repayment') {
                await RedemptionUtilityCommon.validateBasketRedemptions(false, componentName, '');//EDGE-169593
            } else if (attribute.name === 'ContractType' && attribute.displayValue === 'Purchase') {
                RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //EDGE-169593
            }
            await updatecontracttypeattributes();//RF++
        }
        // added by Venkat for ContractTermPopulation
        if ((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attribute.name === 'ContractType' && attribute.value !== '') {
            // EDGE-154465 start
            var updateMap = {};
            if (attribute.displayValue === 'Purchase') {
                updateMap[guid] = [];
                updateMap[guid].push({
                    name: "ContractTerm",
                    showInUi: false,
                });
                updateMap[guid].push({
                    name: "RC",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "OC",
                    showInUi: true
                });
                updateMap[guid].push({
                    name: "RedeemFund",
                    showInUi: true
                });
                updateMap[guid].push({  //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    showInUi: true
                });
                updateMap[guid].push({
                    name: "TotalFundAvailable",
                    showInUi: true
                });
                updateMap[guid].push({
                    name: "OneOffChargeGST",
                    showInUi: true
                });
            } else if (attribute.displayValue === 'Hardware Repayment') {
                updateMap[guid] = [];
                updateMap[guid].push({//PD
                    name: "ContractTerm",
                    showInUi: true,
                });
                updateMap[guid].push({
                    name: "RC",
                    showInUi: true
                });
                updateMap[guid].push({
                    name: "OC",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "RedeemFund",
                    showInUi: false,
                    value: 0.00
                });
                updateMap[guid].push({  //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    showInUi: false,
                    value: 0.00
                });
                updateMap[guid].push({
                    name: "TotalFundAvailable",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "OneOffChargeGST",
                    showInUi: false
                });
            } else if (attribute.displayValue === 'Rental') {
                updateMap[guid] = [];
                updateMap[guid].push({//PD
                    name: "ContractTerm",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "OC",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "RC",
                    showInUi: true
                });
                updateMap[guid].push({
                    name: "RedeemFund",
                    showInUi: false,
                    value: 0.00
                });
                updateMap[guid].push({          //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    showInUi: false,
                    value: 0.00
                });
                updateMap[guid].push({
                    name: "TotalFundAvailable",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "OneOffChargeGST",
                    showInUi: false
                });
            }
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                //let keys = Object.keys(updateConfigMap);
                //for (let i = 0; i < keys.length; i++) { //RF++
                await component.updateConfigurationAttribute(guid, updateConfigMap[guid], true);
                // }
            }
        }
        // EDGE-154465 end
        //Added by shubhi for Device
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Device Type') {
            console.log('Inside attribute ContractType');
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'BussinessId_Device', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'Model', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'ContractType', true);
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
        }
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Model') {
            console.log('Inside attribute ContractType');
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'BussinessId_Device', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'ContractType', true);
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            //await updateConfigName_Device(); //edge-120921 //RF++
            await genericUpdateConfigName(NEXTGENUC_COMPONENTS.DevicesMTS, NEXTGENUC_COMPONENTS.Device);
        }
        // Aditya updated for Voice EDGE-121376
        // Aditya updated for Voice EDGE-121376
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Quantity') {
            console.log('Inside attribute ContractType');
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
        }
        // added by shubhi EDGE-121376
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'ContractType') {
            console.log('Inside attribute ContractType');
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && attribute.name === 'IsDiscountCheckNeeded' && /*newValue*/ attribute.value === false) { // EDGE-154465
            console.log('Inside attribute IsDiscountCheckNeeded');
            //CS.SM.updateConfigurationStatus(componentName, guid, true);
            configuration.status = true;
        }
        if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS && attribute.name === 'IsDiscountCheckNeeded' && /*newValue*/ attribute.value === false) { // EDGE-154465
            console.log('Inside attribute IsDiscountCheckNeeded');
            //CS.SM.updateConfigurationStatus(componentName, guid, true);
            configuration.status = true;
        }
        if (componentName === 'Customer requested Dates' && (attribute.name === 'Not Before CRD') || (attribute.name === 'Preferred CRD')) {
            await updatePreferredandNotBeforeCRDOnUC(guid, attribute.value, attribute.name); // EDGE-154465
        }//RF++
        //Added by Pooja for Change Type Issue || start
        if (window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType') {
            UCEPlugin_ChangeOptionValue(guid, componentName);
        }
        //Added by Pooja for Change Type Issue || end
        //Added by Aman Soni as a part of EDGE-133963 || Start
        // Aditya updated for Voice EDGE-121376
        /*if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.UC) {
            Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
            Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
            Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
        }*/ //RF++
        //Added by Aman Soni as a part of EDGE-133963 || End
        //Added by Shubhi as a part of EDGE-133963        
        pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        pricingUtils.checkDiscountValidation(loadedSolutionUC, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
        await window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValueMap.value, attribute.value);
        //Added for Pricing Services
        PRE_Logic.afterAttributeUpdated(componentName, configuration, attribute, oldValueMap.value, attribute.value);
        if (basketLockStages.contains(basketStage)) {
            loadedSolutionUC.lock('Commercial', true);
        }
        //added by Shubhi  edge-142082 start------
        return Promise.resolve(true);
    }
		window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
			//let solution = await CS.SM.getActiveSolution(); //RF++
			if (NEXTGENUC_COMPONENTS.solution == loadedSolutionUC.name) {
				// console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
				var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
				await refreshNumberManagmentOE(e.detail.configurationGuid, e.detail.orderEnrichment.schema); //AB: OE attachment loading helper: refreshing NumberManagement OE data for display - Spring'20 Upgrade
				await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
			}
			return Promise.resolve(true);
		});
	}
// EDGE-154465 end
/************************************************************************************
 * Author : Tihomir Baljak
 * Method Name : validateCancelSolution
 * Invoked When: in as saveSolutionNgUC function (before save)
 * Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all pc change type is set to cancel
 * Parameters : solution
 ***********************************************************************************/
validateCancelSolution = function () {// EDGE-154465 removed namespace
    let changeTypeAttribute = Object.values(Object.values(loadedSolutionUC.schema.configurations)[0].attributes).filter(a => { //RF++ updated solution to loadedSolutionUC
        return a.name === 'ChangeType' && a.value === 'Cancel'
    });
    if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
        return true;
    }
    let components = loadedSolutionUC.getComponents().components;
    for (let comp of Object.values(components)) {//RF++ updated solution to loadedSolutionUC
        //if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
        let configurations = comp.getConfigurations();
        for (const config of Object.values(configurations)) {//RF++
            if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465                      
                changeTypeAttribute = Object.values(config.attributes).filter(a => {
                    return a.name === 'ChangeType' && a.value !== 'Cancel' && a.value !== 'PaidOut' && a.value !== 'Inactive' && a.value !== 'Paid Out'
                });
                let ct = Object.values(config.attributes).filter(a => {// EDGE-154465
                    return a.name === 'ContractType' && (a.displayValue === 'Hardware Repayment' || a.displayValue === 'Rental')
                });
                if (changeTypeAttribute && changeTypeAttribute.length > 0 && ct && ct.length > 0) {
                    CS.SM.displayMessage('When canceling whole solution all subscriptions and hardware repayment must be canceled too!', 'error');
                    return false;
                }
            }
        }
        // }
    }
    return true;
}
/****************************************************************************
 * Author   : Venkata Ramanan G
 * Method Name : populateLookupStringValues
 * Invoked When: Value for Model is Updated
 * Description : 1. Updates the Display Value of Model in the attribute ModelString
 * Parameters  : 1. String : Component name
 *               2. String : configuration guid of the component on which update has been made
 *               3. String : Display value of the attribute Model.
 ***************************************************************************/
async function populateLookupStringValues(compname, guid, attr, value) {
    // let product = await CS.SM.getActiveSolution();//RF++
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            /*var validcomp = Object.values(loadedSolutionUC.components).filter(comp => {
                return comp.name === compname
            });*/ //RF++
            let validcomp = loadedSolutionUC.getComponentByName(compname);//RF++
            /*if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(config => {// EDGE-154465
                    return config.guid === guid
                });//RF++
            }*/
            let validconfig = validcomp.getConfiguration(guid);//RF++
            if (validconfig && validconfig.attributes) {//RF++ removed index
                var updateMap = {};
                updateMap[validconfig.guid] = [];//RF++ removed index
                if (((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Model') || ((compname === NEXTGENUC_COMPONENTS.Accessory || compname === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'Accessorymodel')) {
                    updateMap[validconfig.guid].push({//RF++ removed index
                        name: "ModelName",
                        value: value,
                        readOnly: true,
                        required: false
                    });
                } else if (((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Device Type') || ((compname === NEXTGENUC_COMPONENTS.Accessory || compname === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'AccessoriesType')) {
                    updateMap[validconfig.guid].push({//RF++ removed index
                        name: "TypeName",
                        value: value,
                        readOnly: true,
                        required: false
                    });
                }
                //let keys = Object.keys(updateMap);
                //for (let i = 0; i < keys.length; i++) {
                if (updateMap && Object.keys(updateMap).length > 0) {//RF++
                    await validcomp.updateConfigurationAttribute(validconfig.guid, updateMap[validconfig.guid], false);//RF++ removed index
                }
                //}
                // EDGE-154465 end
            }
        }
    }
}
async function emptyLookupAttributes(componentName, guid, attr) {
    
    //let product = await CS.SM.getActiveSolution();//RF++
    let validcomp = await solution.getComponentByName(componentName);//RF++
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed product.type &&
        //if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) { //RF++
        /*/var validcomp = (Object.values(loadedSolutionUC.components)[0]).filter(comp => { // EDGE-154465
            return comp.name === componentName
        });*///RF++
        if (validcomp && Object.values(validcomp.schema.configurations).length > 0) {// EDGE-154465 removed index
            /*var validconfig = Object.values(validcomp[0].schema.configurations).filter(comp => {// EDGE-154465
                return config.guid === guid
            });*///RF++
            var validconfig = validcomp.getConfiguration(guid); //RF++
        }
        if (validconfig && validconfig.attributes/* && validconfig[0].attributes*/) {/// EDGE-154465  //RF++
            var updateMap = {};
            updateMap[validconfig.guid] = [];
            if (((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Model') || ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'Accessorymodel')) {
                updateMap[validconfig.guid].push({
                    name: "ModelName",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "ContractType",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "OneOffChargeGST",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "RedeemFund",
                    value: ''
                });
                updateMap[validconfig.guid].push({  //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    value: ''
                });

            } else if ((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Device Type') {
                updateMap[validconfig.guid].push({
                    name: "ModelName",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "TypeName",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "Model",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "ContractType",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "OneOffChargeGST",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "RedeemFund",
                    value: ''
                });
                updateMap[validconfig.guid].push({  //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    value: ''
                });

            } else if ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'AccessoriesType') {
                updateMap[validconfig.guid].push({//PD
                    name: "ModelName",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "TypeName",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "Accessorymodel",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "ContractType",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "OneOffChargeGST",
                    value: ''
                });
                updateMap[validconfig.guid].push({
                    name: "RedeemFund",
                    value: ''
                });
                updateMap[validconfig.guid].push({  //Added EDGE-175750
                    name: "RedeemFundIncGST",
                    value: ''
                });

            }
            //let keys = Object.keys(updateMap);
            //for (let i = 0; i < keys.length; i++) { //RF++
            if (updateMap && Object.keys(updateMap).length > 0) {//RF++
                await component.updateConfigurationAttribute(validconfig.guid, updateMap[validconfig.guid], true);
            }
            // EDGE-154465 end  
        }
        //}
    }
}
/****************************************************************************
 * Author   : Mahaboob Basha
 * Method Name : updateOrderPrimaryContactOnUC
 * Invoked When: Order Primary Contact on OE is updated
 * Description : 1. Updates the Order Primary Contact Id on its parent(UC)
 * Parameters  : 1. String : configuration guid of Order primary Contact tab
 *               2. String : new value of the Order Primary Contact attribute
 ***************************************************************************/
async function updateOrderPrimaryContactOnUC(guid, attrValue) {
    
    //let product = await CS.SM.getActiveSolution(); //RF++
    //console.log('updateOrderPrimaryContactOnUC', product);
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed product.type &&
        //if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) { // EDGE-154465 //RF++
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);//RF++
        //for (const comp of Object.values(loadedSolutionUC.components)) { // EDGE-154465//RF++
        //if (comp.name === NEXTGENUC_COMPONENTS.UC) {//RF++
        console.log('UC while updating OPE on OE', comp);
        let configurations = comp.getConfigurations();//RF++
        //if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
        let ucConfigGUID; //RF
        //Object.values(comp.schema.configurations).forEach((ucConfig) => {// EDGE-154465 //RF++
        for (let ucConfig of Object.values(configurations)) {
            if (ucConfig.orderEnrichmentList && Object.values(ucConfig.orderEnrichmentList).length > 0) {// EDGE-154465 //RF
                let opeConfig = Object.values(ucConfig.orderEnrichmentList).filter(config => {// EDGE-154465
                    return config.guid === guid
                });
                if (opeConfig && opeConfig[0]) {
                    ucConfigGUID = ucConfig.guid;
                }
            }
        }//);
        // console.log('ucConfigGUID', ucConfigGUID);
        if (ucConfigGUID) {
            // EDGE-154465 start
            var updateMap = [];
            updateMap[ucConfigGUID].push({//PD
                name: "Orderprimarycontactid",
                value: attrValue,//PD
                displayValue: attrValue,
                readOnly: true,
                required: false
            });
            if (updateMap && Object.keys(updateMap).length > 0) {
                // let keys = Object.keys(updateMap);
                //for (let i = 0; i < keys.length; i++) {//RF++
                if (updateMap && Object.keys(updateMap).length > 0) {//RF++
                    await comp.updateConfigurationAttribute(ucConfigGUID, updateMap[ucConfigGUID], true);
                }
                //}
            }
            // EDGE-154465 end
        }
        // }
        //}
        //  }
        // }
    }
    return Promise.resolve(true);
}
/******************************************************************************
    * Author  : Pallavi Deshpande
    * Method Name : updatePreferredandNotBeforeCRDOnUC
    * Invoked When: Preferred CRD or Not Before CRD on OE is updated
    * Description : 1. Updates the Preferred CRD or NotBeforeCDR on its parent(UC)
    * Parameters  : 1. String : configuration guid of Customer reqeusted Dates tab
    *               2. String : new value of the Preferred CRD attribute
    *             : 3. String: new DateType should hold Preferred/ Not BeforeCRD
    *****************************************************************************/
async function updatePreferredandNotBeforeCRDOnUC(guid, attrValue, dateType) {
    
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465D removed product.type &&
        let updateMap = {};
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);//RF++
        var ucConfigGUID;
        let ucConfig = comp.getConfiguration(guid);
        if (ucConfig && ucConfig.orderEnrichmentList && Object.values(ucConfig.orderEnrichmentList).length > 0) {// EDGE-154465
            var opeConfig = Object.values(ucConfig.orderEnrichmentList).filter(config => {// EDGE-154465
                return config.guid === guid
            });
            if (opeConfig && opeConfig[0]) {
                ucConfigGUID = ucConfig.guid;
            }
            if (ucConfigGUID) {
                updateMap[ucConfigGUID] = [];
                updateMap[ucConfigGUID].push({
                    name: dateType,
                    value: attrValue,
                    displayValue: attrValue,
                    readOnly: true,
                    required: false
                });
                if (updateMap && Object.keys(updateMap).length > 0) {
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        await comp.updateConfigurationAttribute(ucConfigGUID, updateMap[ucConfigGUID], true);
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
Array.prototype.contains = function (obj) {
   
    var i = this.length;
    while (i--) {
        if (this[i] == obj) {
            return true;
        }
    }
    return false;
}
async function UCEPlugin_processMessagesFromIFrame() {
    
    // if (!communitySiteIdUC) {RF++
    if (!communitySiteId) {//RF++
        return;
    }
    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var message = {};
    if (data) {
        //console.log('UCEPlugin_processMessagesFromIFrame:', data);
        message['data'] = JSON.parse(data);
        await UCEPlugin_handleIframeMessage(message);
    }
    if (close) {
        //console.log('UCEPlugin_processMessagesFromIFrame:', data); /*discountcallout*/
        message['data'] = close;
        await UCEPlugin_handleIframeMessage(message);
    }
}
/***********************************************************************************************
* Author   : Pooja Gupta
* Method Name : UCEPlugin_ChangeOptionValue()
* Invoked When: After attribute changes
* Description : Added for the Active change Type issue
***********************************************************************************************/
async function UCEPlugin_ChangeOptionValue(guid, componentName) {
    
    let updateMap = {};
    let optionValues = [];
    //let loadedSolutionUC = await CS.SM.getActiveSolution(); //RF++
    //let configGuid;
    if (loadedSolutionUC.componentType && loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {
        let comp = loadedSolutionUC.getComponentByName(componentName);
        //window.currentSolutionName = loadedSolutionUC.name;
        //if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
        // for (comp of Object.values(loadedSolutionUC.components)) {
        //if (comp.name === NEXTGENUC_COMPONENTS.UC || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
        //if (comp && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
        optionValues = [];
        let config = comp.getConfiguration(guid);
        // for (let subsConfig of Object.values(comp.schema.configurations)) {
        //configGuid = subsConfig.guid;
        let contractTypevalue = Object.values(config.attributes).find(a => {
            return a.name === 'ContractType'
        });//RF++  
        let RemainingTermValue = Object.values(config.attributes).find(a => {
            return a.name === 'RemainingTerm'
        }); //RF++
        if (comp.name === NEXTGENUC_COMPONENTS.UC && config.guid === guid) {
             optionValues = [CommonUtills.createOptionItem("Cancel"), CommonUtills.createOptionItem("Active")];//R34UPGRADE
        }
        if ((comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) && config.guid === guid && (contractTypevalue && (contractTypevalue.displayValue === 'Purchase' || contractTypevalue.displayValue === 'Hardware Repayment')) && RemainingTermValue.value == 0) {//RF++
            optionValues = [CommonUtills.createOptionItem("Paid Out")];//R34UPGRADE
        }
        if ((comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) && config.guid === guid && (contractTypevalue && contractTypevalue.displayValue === 'Hardware Repayment') && RemainingTermValue.value > 0) {//RF++
            optionValues = [CommonUtills.createOptionItem("Cancel")];//R34UPGRADE
        }
        // }
        //}
        // }
        if (optionValues && optionValues.length > 0) {
            updateMap[guid] = [{
                name: 'ChangeType',
                options: optionValues
            }];
            // let keys = Object.keys(updateMap);
            // for (let i = 0; i < keys.length; i++) {//RF++
            if (updateMap && Object.keys(updateMap).length > 0) {
                await comp.updateConfigurationAttribute(guid, updateMap[guid], true);
            }
        }
        //}
        //  }
        //}
        return Promise.resolve(true);
    }
}
UpdateAttributeVisibilityForMacd = async function (componentName, guid, changeTypeValue) {
    
    if (window.BasketChange !== 'Change Solution') return;
    await updateOeTabsVisibilityNGUC(guid);
    if (changeTypeValue === 'Cancel') {
        await updateCancellationReason(componentName, guid, true);
		if (componentName === NEXTGENUC_COMPONENTS.UC || /*componentName === NEXTGENUC_COMPONENTS.UcComponent ||*/ componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.Device) {// Removed AccessoryMTS and DevicesMTS as per EDGE-193480
            UCEPlugin_updateDisconnectionDate(componentName, guid, true, basketStage === 'Commercial Configuration', false);
        }
        if (componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
            if(componentName === NEXTGENUC_COMPONENTS.DevicesMTS){
				await CommonUtills.updateDiscountDate(componentName, guid);//Added as a part of as per EDGE-193480

				UCEPlugin_calculateTotalETCValue(guid); //EDGE-200705

			}
			UCEPlugin_updateETC(componentName, guid, true);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
        } else if (componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
            if(componentName === NEXTGENUC_COMPONENTS.AccessoryMTS){
				await CommonUtills.updateDiscountDate(componentName, guid); //Added as a part of as per EDGE-193480
                UCEPlugin_calculateTotalETCValue(guid); //Added as part of DIGI-9268

            }
			UCEPlugin_updateETC(componentName, guid, true);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
		}
        /*else if (componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent) {
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductEditableAttributeList);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductNonEditableAttributeList);
        } */// RF++
    }
    if (changeTypeValue !== 'Cancel') {
        await updateCancellationReason(componentName, guid, false);
        if (componentName === NEXTGENUC_COMPONENTS.UC /*|| NEXTGENUC_COMPONENTS.UcComponent */ || componentName === NEXTGENUC_COMPONENTS.Accessory || NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
            
			UCEPlugin_updateDisconnectionDate(componentName, guid, false, false, false);
        }
        if (componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
            UCEPlugin_updateETC(componentName, guid, false);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
        } else if (componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
            UCEPlugin_updateETC(componentName, guid, false);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
        }/* else if (componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent) {
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.BroadsoftProductEditableAttributeList);
            UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductNonEditableAttributeList);
        }  *///RF++ Not in use any more
    }
    // Updated for EDGE-138108
    if (changeTypeValue === 'PaidOut' || changeTypeValue === 'Pending' || changeTypeValue === 'Paid Out') {
        UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
        UCEPlugin_setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
    }
}
UCEPlugin_updateETC = async function (componentName, guid, isVisible) {
    
    console.log('updateDisconnectionDateAndETC ', componentName, guid, isVisible);
    // EDGE-154465 start
    let updateMap = {};
    updateMap[guid] = [];
    /* let val = {
         readOnly: true,
         showInUi: isVisible,
         required: false
     };*/
    let val = '0';
    /* if (!isVisible) {
         val.value = '0';
     }*/
    updateMap[guid].push({//PD
        name: 'EarlyTerminationCharge',
        showInUi: isVisible,
        readOnly:true,
        required: false
       // value: val
    });
    updateMap[guid].push({
        name: "RedeemFund",
        showInUi: isVisible
    });
    updateMap[guid].push({          //Added EDGE-175750
        name: "RedeemFundIncGST",
        showInUi: isVisible
    });
    updateMap[guid].push({
        name: "TotalFundAvailable",
        showInUi: isVisible
    });
    updateMap[guid].push({
        name: "OneOffChargeGST",
        showInUi: isVisible
    });
    // let activeSolution = await CS.SM.getActiveSolution(); RF++
    let component = await loadedSolutionUC.getComponentByName(componentName); //RF++
    if (updateMap && Object.keys(updateMap).length > 0) {
        //  keys = Object.keys(updateMap);
        //for (let i = 0; i < keys.length; i++) { //RF++
        await component.updateConfigurationAttribute(guid, updateMap[guid], true);
        // }
    }
    // EDGE-154465 end
}
UCEPlugin_updateDisconnectionDate = async function (componentName, guid, isVisible, isMandatory, isReadonly) {
    
    console.log('updateDisconnectionDate', componentName, guid, isVisible, isMandatory, isReadonly);
    // EDGE-154465 start
    let updateMap = {};
    updateMap[guid] = [];
    updateMap[guid].push({
        name: 'DisconnectionDate',
        readOnly: isReadonly,
        showInUi: isVisible,
        required: isMandatory
    });
    //let activeSolution = await CS.SM.getActiveSolution();RF++
    let component = await loadedSolutionUC.getComponentByName(componentName);//RF++
    if (updateMap && Object.keys(updateMap).length > 0) {
        //   keys = Object.keys(updateMap);
        // for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(guid, updateMap[guid], true);
        // }
    }
    // EDGE-154465
}
UCEPlugin_setAttributesReadonlyValueForConfiguration = async function (componentName, guid, isReadOnly, attributeList) {
   
    console.log('setAttributesReadonlyValueForConfiguration ', componentName, guid, isReadOnly, attributeList);
    // EDGE-154465
    let updateMap = {};
    updateMap[guid] = [];
    // attributeList.forEach((attribute) => {//RF++
    for (let attribute of attributeList) {
        updateMap[guid].push({
            name: attribute,
            readOnly: isReadOnly
        });
    }//);
    //let activeSolution = await CS.SM.getActiveSolution();//RF++
    let component = await loadedSolutionUC.getComponentByName(componentName);//RF++
    if (updateMap && Object.keys(updateMap).length > 0) {
        //keys = Object.keys(updateMap);
        //for (let i = 0; i < keys.length; i++) { //RF++
        await component.updateConfigurationAttribute(guid, updateMap[guid], true);
        //}
    }
    // EDGE-154465
}
UCEPlugin_calculateTotalETCValue = async function (guid) {  // EDGE-154465
    
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    //let currentBasketUC = await CS.SM.getActiveBasket();//RF++
    //let product = await CS.SM.getActiveSolution();//RF++
    let contractTerm;
    let disconnectionDate;
    let prodConfigID;
    var updateMap = {};
    // let componentName; //RF++
    //console.log('calculateTotalETCValue', product);
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) { // EDGE-154465 removed product.type &&
        // if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
        //Object.values(loadedSolutionUC.components).forEach((comp) => { // EDGE-154465
        //if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) { // EDGE-154465
        let component = loadedSolutionUC.findComponentsByConfiguration(guid);//RF++
        let config = component.getConfiguration(guid);
        // Object.values(comp.schema.configurations).forEach((config) => { // EDGE-154465 //RF++
        // if (config.guid === guid) { //RF++
        // componentName = comp.name; // EDGE-154465
        prodConfigID = config.replacedConfigId;
        let dd = Object.values(config.attributes).filter(a => { // EDGE-154465
            return a.name === 'DisconnectionDate' && a.value
        });
        if (dd && dd.length > 0)
            disconnectionDate = new Date(dd[0].value);
        let ct = Object.values(config.attributes).filter(a => { // EDGE-154465
            return a.name === 'ContractTerm' && a.value
        });
        if (ct && ct.length > 0)
            contractTerm = ct[0].value;
        // }
        // });
        // }
        // });
        console.log('contractTerm=', contractTerm, ', disconnectionDate=', disconnectionDate);
        if (disconnectionDate && contractTerm) {
            var inputMap = {};
            inputMap["getETCChargesForNGUC"] = 0;//RF++
            inputMap["DisconnectionDate"] = disconnectionDate;
            inputMap["etc_Term"] = contractTerm;
            inputMap["ProdConfigId"] = prodConfigID;
            console.log('inputMap', inputMap);
            await currentBasketUC.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
                var charges = values["getETCChargesForNGUC"];
                var chargesGst = parseFloat(charges * 1.1).toFixed(2); //added by Romil EDGE-130075,EDGE-136954
                console.log('getETCChargesForNGUC Result', values["CalculateEtc"], charges);
                // EDGE-154465 start
                updateMap[guid] = [];
                updateMap[guid].push({
                    name: 'EarlyTerminationCharge',
                    value: charges,
                    readOnly:true,
                    displayValue: charges
                });
                updateMap[guid].push({
                    name: 'OneOffChargeGST', //added by Romil EDGE-130075,EDGE-136954
                    label: 'Balance Due On Device(Inc GST)',
                    value: chargesGst,
                    readOnly:true,
                    displayValue: chargesGst
                });
            });
            //let activeSolution = await CS.SM.getActiveSolution();//RF++                  
            if (updateMap && Object.keys(updateMap).length > 0) {
                //keys = Object.keys(updateMap);
                //for (let i = 0; i < keys.length; i++) { //RF++
                await component.updateConfigurationAttribute(guid, updateMap[guid], true);
                //}
            }
            // EDGE-154465 end
        }
        // }
    }
    return Promise.resolve(true);
}
UCEPlugin_validateDisconnectionDate = async function (componentName, guid, attributeValue) {
   
    //let solution = await CS.SM.getActiveSolution();//RF++
    let today = new Date();
    let attDate = new Date(attributeValue);
    today.setHours(0, 0, 0, 0);
    attDate.setHours(0, 0, 0, 0);
    let component = await loadedSolutionUC.getComponentByName(componentName); //RF++
    let config = await component.getConfiguration(guid);//PD
    if (attDate < today) { // EDGE-178229 - the disconnection date can be todays date hence removed = sign
        CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
        // EDGE-154465 start
        config.status = false;
        config.statusMessage = 'Disconnection date should be greater than today!';
        // EDGE-154465 end
    } else {
        // EDGE-154465 start              
        config.status = true;
        config.statusMessage = '';
    }
}
UCEPlugin_setOEtabsforUC = function () {//RF++
    
    if (window.basketStage !== "Contract Accepted") return;
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type &&
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
            Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Customer requested Dates', 'NumberManagementv1']);
            });
        }
    }
}
//Edge-120921 Added by shubhi dynamic config name population end
//EDGE-144971 Added by Aditya for Consumption based Cancel--->Start
UCEPlugin_RewokeConfigurationOnCancel = async function () {
    
    console.log('RewokeConfigurationOnCancel');
    //let solution = await CS.SM.getActiveSolution(); //RF++
    if (loadedSolutionUC.name === (NEXTGENUC_COMPONENTS.solution)) {//PD removed solution.type &&
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            Object.values(loadedSolutionUC.schema.configurations).forEach((config) => {
                if (config.attributes && Object.values(config.attributes).length > 0) {
                    var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                        return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
                    });
                    if ((window.BasketChange === 'Change Solution' && changeTypeAtrtribute && changeTypeAtrtribute.length > 0)) {
                        CS.SM.displayMessage('Cannot add configuration if main solution is cancel', 'error');
                        returnflag = false;
                    }
                    else {
                        returnflag = true;
                    }
                }
            });
        }
    }
}
updateChangeTypeAttributeNGUC = async function () { // EDGE-154465 //RF++ updated signature
    
    if (window.BasketChange !== 'Change Solution') return;
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && used loadedSolutionUC insted of solution
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
                var updateMap = {};
                // console.log('COmponent name ==', comp.name);
                var doUpdate = false;
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    for (let config of Object.values(comp.schema.configurations)) {
                        if (config.attributes && Object.values(config.attributes).length > 0 && config.replacedConfigId !== null) {// EDGE-154465
                            updateMap[config.guid] = [];
                            let attribute = config.getAttribute('ChangeType');//RF++
                            // if (attribute.name === 'ChangeType') { //RF++
                            doUpdate = true;
                            var changeTypeValue = attribute.value;
                            if (!window.BasketChange && window.BasketChange !== '' && window.BasketChange !== 'New'
                                && window.BasketChange !== 'undefined') {
                                console.log('Non MACD basket');
                                if (!changeTypeValue) {
                                    changeTypeValue = 'New';
                                }


                                updateMap[config.guid].push({//PD
                                    name: attribute.name,
                                    value: changeTypeValue,
                                    displayValue: changeTypeValue,
                                    showInUi: false,
                                    readOnly: true
                                });
                            } else {
                                var readonly = false;

                                if (config.id && (changeTypeValue === 'Cancel' || changeTypeValue === 'Modify')) {
                                    readonly = true;
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({//PD
                                        name: attribute.name,
                                        showInUi: true,
                                        readOnly: false
                                    });
                                }
                            }
                            if (updateMap && Object.keys(updateMap) && Object.keys(updateMap).length > 0) {
                                await comp.updateConfigurationAttribute(config.guid, updateMap[config.guid], true);//RF++
                            }
                        }
                    }
                }
                /*if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    for (let i = 0; i < keys.length; i++) {
                       await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);//RF++
                    }
                }*/ //RF++
            }
        }
    }
    return Promise.resolve(true);
}

/*********************************************************************************************
 * Author	   : Pooja Bhat
 * Method Name : calcDeviceRedeemFundGST
 * Invoked When: method AfterAttributeUpdated - Case RedeemFund 
 * Sprint	   : 20.15 (EDGE-175750)
 * Parameters  : guid, newValue, componentName

**********************************************************************************************/
calcDeviceRedeemFundGST = async function(guid, newValue, componentName) {
   
    let updateMap 	= 	{};
    updateMap[guid]	=	[];
    let solution 	=	await CS.SM.getActiveSolution();
    let comp 		= 	await solution.getComponentByName(componentName);
    if (comp && newValue !== null && newValue !== undefined) {
        let redeemFundExGSTRounded	= 	(newValue === "" || newValue === null || newValue === undefined ? 0 :  parseFloat(newValue).toFixed(2));
        let redeemFundIncGSTRounded	=	parseFloat(redeemFundExGSTRounded * 1.1).toFixed(2);
        updateMap[guid].push({
            name: "RedeemFundIncGST",
            value: redeemFundIncGSTRounded,
            displayValue: redeemFundIncGSTRounded
        });
        let keys = Object.keys(updateMap);
        for (let i = 0; i < keys.length; i++) {
            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
        }   
        return Promise.resolve(true);     
    }   
}

/*********************************************************************************************
 * Author	   : Anuj
 * Method Name : updateBSConfigName
 * Invoked When: method beforeSave
 * Sprint	   : 21.05 (EDGE-207736)
 * Parameters  : guid, newValue, componentName

**********************************************************************************************/
	updateBSConfigName = async function(componentName,configuration,flag){
		let setUpdateMap ={};
		if (componentName === NEXTGENUC_COMPONENTS.UC )
		{
			let configName;
			if(flag){
				configName = CommonUtills.genericSequenceNumberAddInConfigName(configuration, "Mode","callingPlans");
				configName = componentName +'-' + configName;
				setUpdateMap[configuration.guid] = [];
				setUpdateMap[configuration.guid] = [
					{
						name: "ConfigName",
						value: configName,
						displayValue: configName
					}
				];
				configuration.configurationName = configName;
			}else{
				configName=configuration.getAttribute('configName');
				// 7/8/2021 : INC000096628734 FIX @Apple : start
                if(configName && configName.value != "" && configName.value != null){
                    configuration.configurationName = configName.value;
                }
                // 7/8/2021 : INC000096628734 FIX @Apple : end

			}
			
			let keys = Object.keys(setUpdateMap);
			let solution 	=	await CS.SM.getActiveSolution();
            let comp 		= 	await solution.getComponentByName(componentName);
            // EDGE-223950 : added lock and unlock logic
            let complock = comp.commercialLock;
			if (complock) {comp.lock("Commercial", false);}
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], setUpdateMap[keys[i]], false);
            }
            if (complock) {comp.lock("Commercial", true);}

				
		}	
	}

/*********************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : addDeviceToBusinessCalling
 * Invoked When: method beforeSave
 * Sprint	   : 21.05 (EDGE-204030)

**********************************************************************************************/
addDeviceToBusinessCalling = async function(loadedSolutionUC) {
   
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {
		let BusinessCallingGuid=''
		let arr=new Map();
		var updateMap = {};
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.UC){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							var numb = config.configurationName.split("_");
							var keyMap=numb[1];
							if(keyMap !=null && keyMap != undefined && config.attributes.changetype.displayValue != 'Cancel') //Added change type condition as part of EDGE-228145
								arr.set(keyMap,config.guid);
						}
					}
				}
            }
        }
        console.log('arr.keys()',arr.keys());
        for (let key of arr.keys()) {
			console.log(key);
			if(key >= 1){
				BusinessCallingGuid=arr.get(key);
				break;
			}
		}
		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
               
				if(comp.name == NEXTGENUC_COMPONENTS.DevicesMTS){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: 'ParentGuid',
								value: BusinessCallingGuid
							});
						}
					}
					if (updateMap && Object.keys(updateMap).length > 0) {
						keys = Object.keys(updateMap);
						let complock = comp.commercialLock;
						if (complock) {comp.lock("Commercial", false);}
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						 if (complock) {comp.lock("Commercial", true);}
					}
				}
            }
        }
		
    }
}
/*********************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : addDeviceToBusinessCalling
 * Invoked When: method beforeSave
 * Sprint	   : 21.05 (EDGE-204030)
**********************************************************************************************/
addPCIdIntoDevice= async function(loadedSolutionUC) {
   
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {
		let BusinessCallingGuid=''
		let bsGuid=new Map();
		var updateMap = {};
        if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.UC){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							bsGuid.set(config.guid,config.id);
						}
					}
				}
            }
        }
		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.DevicesMTS){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							var configGuid=config.getAttribute('ParentGuid');
							var configString='DMCAT_ProductSpecification_000871_Fulfilment::'+(bsGuid.get(configGuid.value)).substring(0,15)
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: 'BusinessCallingId',
								value: configString
							});
						}
					}
					if (updateMap && Object.keys(updateMap).length > 0) {
						keys = Object.keys(updateMap);
						let complock = comp.commercialLock;
						if (complock) {comp.lock("Commercial", false);}
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
						 if (complock) {comp.lock("Commercial", true);}
					}
				}
            }
        }
		
    }
}
/*********************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : addBusinessCallingId
 * Invoked When: method beforeSave only for change solution
 * Sprint	   : 21.05 (EDGE-204030)
**********************************************************************************************/
addBusinessCallingId= async function(loadedSolutionUC) {
   
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {
		let BusinessCallingid=''
		var updateMap = {};
		var guid='';
		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.DevicesMTS){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							var cnfigGuid=config.getAttribute('ParentGuid');
                            var isdisabled = config.disabled != undefined ? config.disabled : false;
							if(cnfigGuid != undefined && cnfigGuid.value !=null && cnfigGuid.value!='' && !isdisabled){
								BusinessCallingid=cnfigGuid.value;
								break
							}
						}
					}
				}
            }
        }
		if(BusinessCallingid){
			var inputMap = {};
            inputMap["getGuid"] = BusinessCallingid;
            console.log('inputMap', inputMap);
            await currentBasketUC.performRemoteAction('SolutionHelperForGuid', inputMap).then(values => {
                guid = values["parentGuid"]; 
            });
		}
		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
            for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.DevicesMTS){	
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							var configGuid=config.getAttribute('ParentGuid');
                            var isdisabled = config.disabled != undefined ? config.disabled : false;
                            if(!isdisabled){
                                updateMap[config.guid] = [];
                                updateMap[config.guid].push({
                                    name: 'BusinessCallingId',
                                    value: guid
                                });
                            }
                        }
					}
					if (updateMap && Object.keys(updateMap).length > 0) {
						keys = Object.keys(updateMap);
						let complock = comp.commercialLock;
						if (complock) {comp.lock("Commercial", false);}
						for (let i = 0; i < keys.length; i++) {
							await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						} 
                        if (complock) {comp.lock("Commercial", true);}
					}
				}
            }
        }
		
    }
}

/*********************************************************************************************
 * Author	   : Vivek Makkar
 * Method Name : updateAttributeTenancyId
 * Sprint	   : 21.05 (EDGE-206232)
**********************************************************************************************/
//Added as a part of EDGE-206232 : START VIVEK

updateAttributeTenancyId = async function (TenancyId) {
    console.log('updating legacy TenancyId ' , TenancyId );
    var updateMap = {};
    
    var loadedSolutionUC = await CS.SM.getActiveSolution();
    if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
        for (let comp of Object.values(loadedSolutionUC.components)) {
            if(comp.name == NEXTGENUC_COMPONENTS.UC){   
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    for (let config of Object.values(comp.schema.configurations)) {
						var TenancyGuid=config.getAttribute('TenancyGuid');
						if(TenancyGuid.value == 'DMCAT_ProductSpecification_000311_Fulfilment' && !config.disabled){
							updateMap[config.guid] = [];
							updateMap[config.guid].push({
								name: 'TenancyGuid',
								value: TenancyId
							});
						}
                    }
                }
                
            }
        }
        var comp  =  await loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            // EDGE-223950 : added lock and unlock logic
            let complock = comp.commercialLock;
			if (complock) {comp.lock("Commercial", false);}
            for (let i = 0; i < keys.length; i++) {
                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            if (complock) {comp.lock("Commercial", true);}
        }
        
    }  
    return Promise.resolve(true); 
} 

/*********************************************************************************************
 * Author	   : Vivek Makkar
 * Method Name : updateButtonConfigButtonVisibility
 * Sprint	   : 21.05 (EDGE-206232)
**********************************************************************************************/
updateButtonConfigButtonVisibility = async function () {
    let buttonId=document.getElementById("TenancyButton")
    if ( window.basketChangeType == "Change Solution" && window.basketStage == 'Contract Accepted'){
    buttonId.style.display = "block";
    }
    else{
    buttonId.style.display = "none";
    }  

}
/*********************************************************************************************
 * Author	   : Vivek Makkar
 * Method Name : checkTenecyIdValidation
 * Sprint	   : 21.05 (EDGE-206232)
**********************************************************************************************/
//Added as a part of EDGE-206232 : START VIVEK

checkTenecyIdValidation = async function (loadedSolutionUC) {
	var isTenencyId=false;
		if (loadedSolutionUC.components && Object.values(loadedSolutionUC.components).length > 0) {
			for (let comp of Object.values(loadedSolutionUC.components)) {
				if(comp.name == NEXTGENUC_COMPONENTS.UC){   
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						for (let config of Object.values(comp.schema.configurations)) {
							var TenancyGuid=config.getAttribute('TenancyGuid');
							if(TenancyGuid.value == 'DMCAT_ProductSpecification_000311_Fulfilment' && !isTenencyId && !config.disabled && (config.replacedConfigId ===null || config.replacedConfigId =='' || config.replacedConfigId==undefined)){
								CS.SM.displayMessage('Please Select Tenancy Id before validate and Save','error');
								return true; 
							}
						}
					}
					
				}
			}
		} 
		
    return false; 
} 
/*********************************************************************************************
 * Author	   : Ankit Goswami
 * Method Name : AttributeReadOnly
 * Sprint	   : 21.09 ()
**********************************************************************************************/
async function AttributeReadOnly(loadedSolutionUC,guid) {
   
    var attribute;
    let updatelookup = {};
    let inputMap = {};
    if (loadedSolutionUC.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type &&
        let comp = loadedSolutionUC.getComponentByName(NEXTGENUC_COMPONENTS.UC);//RF++
		let config = comp.getConfiguration(guid); 
		var updateConfigMap = {};
		updateConfigMap[config.guid] = [];
		updateConfigMap[config.guid].push({
			name: "Mode",
			readOnly: true
		});
		updateConfigMap[config.guid].push({
			name: "callingPlans",
			readOnly: true
		});
		if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
			await comp.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
		}    
    }
    return Promise.resolve(true);
} 


/**********************************************************************************************************************************************
 * Author   : Vimal
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if tehere is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
/*async function addDefaultUCOEConfigs() {
    if (basketStage !== 'Contract Accepted')
        return;
    console.log('addDefaultOEConfigs');
    var oeMap = [];
    //await CS.SM.getActiveSolution().then((currentSolution) => {// EDGE-154465
    let currentSolution = await CS.SM.getActiveSolution();// EDGE-154465
    console.log('addDefaultOEConfigs ', currentSolution.name, NEXTGENUC_COMPONENTS.solution);
    if (currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type &&
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {// EDGE-154465
            //currentSolution.components.forEach((comp) => {/// EDGE-154465
            Object.values(currentSolution.components).forEach((comp) => {// EDGE-154465
                //comp.schema.configurations.forEach((config) => {// EDGE-154465
                Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                    //EDGE-EDGE-134972 - Added below fix to remove OE required in case of Cancel
                    var cancelconfig = Object.values(config.attributes).filter((attr => {// EDGE-154465
                        return attr.name === 'ChangeType'
                    }));
                    if (cancelconfig && cancelconfig.length > 0 && cancelconfig[0].value !== 'Cancel') {// EDGE-154465
                        Object.values(comp.orderEnrichments).forEach((oeSchema) => {
                            if (oeSchema && (oeSchema.name.toLowerCase().includes('customer requested dates') || oeSchema.name.toLowerCase().includes('delivery details') || oeSchema.name.toLowerCase().includes('order primary contact'))) { //&& oeSchema.name.toLowerCase().includes('order primary contact'))) {
                                var found = false;
                                if (config.orderEnrichmentList) {
                                    var oeConfig = Object.values(config.orderEnrichmentList).filter(oe => {// EDGE-154465
                                        return (oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId)
                                    });
                                    if (oeConfig && oeConfig.length > 0)
                                        found = true;
                                }
                                if (!found) {
                                    var el = {};
                                    el.componentName = comp.name; // EDGE-154465
                                    //el.componentName = NEXTGENUC_COMPONENTS.solution;
                                    el.configGuid = config.guid;
                                    // el.oeSchemaId = oeSchema.id; // EDGE-154465
                                    el.oeSchema = oeSchema;
                                    oeMap.push(el);
                                    console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
                                }
                            }
                        });
                    }
                });
            });
        }
    }
    //}).then(() => Promise.resolve(true));PD
    Promise.resolve(true);
    //console.log('addDefaultOEConfigs prepared');
    // EDGE-154465 start
    /*var map = {};
    //if (oeMap.length > 0) {
    //    map = [];
    //    map.push({});
   //     console.log('Adding default oe config map:', oeMap);
    //    for (var i = 0; i < oeMap.length; i++) {
    //        await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
    //    };
    //}
    if (oeMap.length > 0) {
        console.log('Adding default oe config map--:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            console.log(' Component name ----' + oeMap[i].componentName);
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        };
    }
    // EDGE-154465 end
    await initializeUCOEConfigs();
    return Promise.resolve(true);
}*/
/**********************************************************************************************************************************************
 * Author   : Vimal
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
/*async function initializeUCOEConfigs() {
    console.log('initializeOEConfigs');
    var currentSolution;
    //await CS.SM.getActiveSolution().then((solution) => {// EDGE-154465
    let solution = await CS.SM.getActiveSolution();// EDGE-154465
    currentSolution = solution;
    console.log('initializeUCOEConfigs - getActiveSolution');
    //}).then(() => Promise.resolve(true));// EDGE-154465
    Promise.resolve(true);
    if (currentSolution) {
        console.log('initializeUCOEConfigs - updating');
        if (currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type &&
            if (currentSolution.components && currentSolution.components.length > 0) {// EDGE-154465
                //for (var i = 0; i < currentSolution.components.length; i++) {// EDGE-154465
                for (let i = 0; i < Object.values(currentSolution.components).length; i++) {// EDGE-154465
                    var comp = currentSolution.components[i];
                    //for (var j = 0; j < comp.schema.configurations.length; j++) {// EDGE-154465
                    for (let i = 0; i < Object.values(comp.schema.configurations).length; i++) {// EDGE-154465
                        var config = comp.schema.configurations[j];
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for (var k = 0; k < Object.values(config.orderEnrichmentList).length; k++) {// EDGE-154465
                                var oe = config.orderEnrichmentList[k];
                                var basketAttribute = Object.values(oe.attributes).filter(a => {// EDGE-154465
                                    return a.name.toLowerCase() === 'basketid'
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    // EDGE-154465 start
                                    updateMap[oe.guid] = [];
                                    if (!updateMap[oe.guid])
                                        updateMap[oe.guid].push({
                                            name: basketAttribute[0].name,
                                            value: basketId
                                        });
                                    // EDGE-154465 end
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            // EDGE-154465 start
                            console.log('initializeOEConfigs updateMap:', updateMap);
                            //populateRateCardinAttachment();
                            //CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true)); PD
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[i], updateMap[keys[i]], false);
                                }
                            }
                            // EDGE-154465 end
                        }
                    };
                };
            }
        }
    }
    // populateRateCardinAttachment();
    return Promise.resolve(true);
}*/