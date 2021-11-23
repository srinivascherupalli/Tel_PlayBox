/******************************************************************************************
	 * Author	   : CloudSense Team
	 Change Version History
	Version No	Author 			Date
	1 			Vamsi		 	26-Jul-19	Initial file
	2           Sandip			26-Jul-19	
	3           Jayesh			26-Jul-19	
	4			Vimal			27-Jul-19	Added OE related logic
	5			Sandip			29-Jul-19 	Added validations for 2nd User Creation and CRD fields on OE.
	6           Tihomir         07-08-19    Code cleanup
	7           Tihomir         13-08-2019      Code refactoring , OE
	8           Venkat          30-08-19     UC Sprint Story Tasks
	9           Venkat          23-Sep-19    NextGen UC MTS Sprint User story (New & Modify Journey)- EDGE 108257,EDGE 114158, 	EDGE 107435
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
	20.        Romil Anand     	25-10-2019      EDGE-119323 : GST Calculation of Net Charge while Redemption
	21.        Romil Anand    	22-10-2019      EDGE-127941 : Calculate Total Contract Value for a Basket
	22.        Romil Anand     	20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
	23          Aditya          27-12-19   		EDGE-125042: Update the Change Type of NGUC NG Voice to Cancel if subscriptions are suspended
	24.        Romil Anand     	15-01-2020      EDGE-130075 : Redeeming One Funds for Cancel Journey
	25.        Shubhi	    	05-02-2020     	EDGE-133963 :Discount Journey 
	26.        Sandip Deshmane  07-02-2020  	EDGE-EDGE-134972 - Added below fix to remove OE required in case of Cancel
	25.        Dheeraj Bhatt   13-02-2020      EDGE-100662 : UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
	26.         Sandip Deshmane 14-02-2020     EDGE-134972 - Added below fix to remove OE required in case of Cancel 
	27.         Romil Anand     19-FEB-2020    EDGE-136954- Implement code review comments provided by Governance Review
	27.        Shubhi/Aditya	03-03-2020  	EDGE-121376 :Discount Journey for Voice
	30. 		Laxmi 		    25-03-2020				EDGE-138001 - method call to hide importconfigurations button added
	31.       Shubhi			30-03-20202     EDGE-140157 NGUC Ui modify
	32.       Shubhi			30-03-20202     Edge-143527 POC for solution json 
	33.       shubhi/Aditya		23/4/2020		Edge-120919 NGUC consumption based model new
	34.		  Hitesh Gandhi		28/04/2020		Edge-120921	Added code for updateEDMListToDecomposeattribute
    35.		  Romil Anand		29/04/2020		EDGE-144161 : Enabling Redemption as Discount for Device Payout and NGUC 
	36.		  Hitesh Gandhi		14/05/2020		EDGE-146184 Added code under updateEDMListToDecomposeattribute for Wireless DECT
	37. 	  Aditya Pareek		14/05/2020		EDGE-144971- NGUC Consumption based Cancel
	38.       shubhi            16/05/2020		Edge-142082	
	38.       Aman Soni         16/05/2020		Edge-142082
	39.       RaviTeja          01/06/2020		EDGE-146972
    40.		  Gnana		    	10-Jun-2020	    EDGE-149887 : Solution Name Update Logic
    41. 	  Aman Soni			17-Jun-2020		EDGE-156214 EM mac || issue in billing account
    42.       Shubhi Vijay		13-Jun-20202    EDGE-162560
	43.       Pallavi D         02-Jul-2020     EDGE-154465 Spring 20 upgrade
	44.       Gnana/Aditya		17/07/2020		Modified as part of CS Spring'20 Upgrade
	45.		  Sandip Deshmane	20/07/2020		Reser CRDs in case of MACD. Moved it from MACD observer as part of Spring20 upgrade
    46.		  Sandip Deshmane	8/8/2020		Added function to set OE Data for Number Management
	47.		  Aditya			11-08-2020		Edge:142084, Enable New Solution in MAC Basket
    47.      Shubhi Vijayvergia	13/08/2020		//added by shubhi for EDGE-170148
	48.     Shubhi Vijayvergia	21.08.2020		//added by shubhi for EDGE-169593 -redemptions fix for em,nguc and dop
    49.     Shubhi V             27.08.2020     EDGE-173020

    50.     Pallavi              08.09.2020    EDGE-175185	
    51.     Pallavi               16.09.2020     Pallavi added check of basket type to avoid change type function execution in New 
    52.     Shubhi               16.09.2020    Commented basket lock in updateConfigName_Accesory
           
    ********************/
var communitySiteIdUC;
var NEXTGENUC_COMPONENTS = {
    solution: 'Telstra Collaboration',
    NextGenUC: 'NextGen UC',
    UnifiedCommunications: 'Unified Communications',
    UC: 'Business Calling',
    User: 'User',
    HuntGroup: 'Hunt Group',
    AutoAttendant: 'Auto Attendant',
    MainBusinessNumber: 'Main Business Number',
    Device: 'Unified Communication Device', //used in configuration add
    DevicesMTS: 'Devices',
    AccessoryMTS: 'Accessories',
    Accessory: 'Accessory', //used in configuration add
    UcComponent: 'Unified Communication Enterprise Schema',
    UCDeviceEditableAttributeList: ['Device Type', 'Model', 'Quantity'], // Aditya: Removed Contracttype for EDGE-137255
    AccessoryEditableAttributeList: ['AccessoriesType', 'Accessorymodel', 'ContractType', 'Quantity'],
    BroadsoftProductEditableAttributeList: ['callingPlans', 'concurrencyLimit', 'NumberofPhoneNumbers', 'UCUserQuantity', 'HuntGroupQuantity', 'AutoAttendantQuantity', 'MainBusinessNumberQuantity', 'HostedUCQuantity'],
    BroadsoftProductNonEditableAttributeList: ['ContractTerm']
};
var executeSaveNgUC = false;
var callUpdateImport = true;
var saveNgUC = false;
var valid = true;
var ratecardloaded = false;
var basketNum; // Added by Laxmi EDGE_135885
var solutionName; // Added by Laxmi EDGE_135885
var solutionID; // Edge-143527        
var uniquehexDigitCode; //Edge-143527
var callerNameNGUC = ''; //Edge-143527
let IsDiscountCheckNeeded = false;
let IsRedeemFundCheckNeeded = false; //EDGE-144161
var configId; //Edge-143527 
var isEapActive = true; //Edge-120921
var returnflag = true;
var DEFAULTSOLUTIONNAME_NGUC = 'Telstra Collaboration';
var DEFAULTOFFERNAME_NGUC = 'Telstra Collaboration';
var basketChangeType; // EDGE-154465
//Gnana : CS Spring'20 Upgradae Start
//var SIGNIFICANT_ATTRIBUTELIST = ['Mode','CountHS','CountMS','CountUser','PlanTRC','ProductStatus','RecurringPrice','TOC','TotalContractValue','TotalOneOffCharge','TotalRecurringPrice','TRC'];
//let IsBasketUpdateNeeded = false;
//Gnana : CS Spring'20 Upgradae End
/*if (CS.SM.createPlugin) {
    console.log('Load nUC plugin');
    UCEPlugin = CS.SM.createPlugin('Telstra Collaboration');
    //Added by Aditya for Deal Price
    window.addEventListener('message', UCEPlugin_handleIframeMessage);
    setInterval(UCEPlugin_processMessagesFromIFrame, 500);
    //Added by Aman Soni as a part of EDGE-133963 || Start
    Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
    Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
    Utils.updateCustomAttributeLinkText('Rate Card', 'View All');
    pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
    pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
    pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //added by Romil for 144161
    subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS); //added by Shubhi for EDGE-143957
    subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC); //added by Shubhi for EDGE-143957
    //Added by Aman Soni as a part of EDGE-133963 || End
    // Laxmi EDGE-138001 - method call  to hide the import configuraton button
    //Utils.updateImportConfigButtonVisibility();			
    setInterval(saveSolutionNgUC, 500);
}PD*/
// EDGE-154465 start
if (CS.SM.registerPlugin) {
    console.log('Loaded Telstra Collaboration Plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () {
        console.log('SolutionConsoleReady');
        await CS.SM.registerPlugin('Telstra Collaboration')
            .then(async UCEPlugin => {
                updateUCEPlugin(UCEPlugin);
            });
    });
}
// EDGE-154465 end
// EDGE-154465 start
async function updateUCEPlugin(UCEPlugin) { // EDGE-154465
    console.log('inside hooks', UCEPlugin);
    //Added by Aditya for Deal Price
    window.addEventListener('message', UCEPlugin_handleIframeMessage);
    //Edge-120921 Added by shubhi dynamic config name population end
    //UCEPlugin.afterSolutionLoaded = async function(previousSolution, loadedSolution) { // EDGE-154465
    window.document.addEventListener('SolutionSetActive', async function (e) { // EDGE-154465
        //added by shubhi for EDGE-170148
        Utils.updateCustomButtonVisibilityForBasketStage();
        Utils.updateImportConfigButtonVisibility();
        // EDGE-154465 start
        let currentBasket = await CS.SM.getActiveBasket();
        let loadedSolution = await CS.SM.getActiveSolution();
        if (loadedSolution.name === NEXTGENUC_COMPONENTS.solution) {
            // EDGE-154465 end	
            console.log('loadedSolution', loadedSolution);
            window.currentSolutionName = loadedSolution.name;
            //Added by romil EDGE-113083, EDGE-115925,EDGE-136954,EDGE-144161
            //calculateIsDiscountCheckNeeded();
            // Added for EDGE-138001
            Utils.updateImportConfigButtonVisibility();
            await RedemptionUtilityCommon.claculateCurrentFundBalanceAmt();//EDGE-169593
            await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
            //await RedemptionUtils.displayCurrentFundBalanceAmt();
            //await RedemptionUtils.calculateBasketRedemption();
            // await RedemptionUtils.checkRedeemDiscountonload(loadedSolution);
            await Utils.loadSMOptions();
            // ratecardloaded = false;
            // EDGE-154465 start
            basketId = currentBasket.basketId;
            /*await CS.SM.getCurrentCart().then(cart => {
                console.log('Basket: ', cart);
                basketId = cart.id;*/
            // EDGE-154465 end
            //Added by Aman Soni as a part of EDGE-133963 || Start
            Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
            Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
            Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
            await updateConfigName_Accesory(); //edge120921
            await updateConfigName_Device(); //edge-120921
            //Added by Aman Soni as a part of EDGE-133963 || End
            //});
            let inputMap = {};
            inputMap['GetBasket'] = basketId;
            inputMap['GetSiteId'] = '';
            //await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {EDGE-154465
            await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {//EDGE - 154465
                console.log('GetBasket finished with response: ', result);
                var basket = JSON.parse(result["GetBasket"]);
                console.log('GetBasket: ', basket);
                communitySiteIdUC = result["GetSiteId"]
                console.log('communitySiteId: ', communitySiteIdUC);
                basketChangeType = basket.csordtelcoa__Change_Type__c;
                basketStage = basket.csordtelcoa__Basket_Stage__c;
                basketNum = basket.Name; // EDGE-135885 Laxmi - code to get basket num
                accountId = basket.csbb__Account__c;
                console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: ', accountId)
                window.oeSetBasketData(basketId, basketStage, accountId);
                //  UCEPlugin.UpdateMainSolutionChangeTypeValue(loadedSolution);
                //Edge-142082 shubhi start
                if (accountId != null) {
                    CommonUtills.setAccountID(NEXTGENUC_COMPONENTS.solution, accountId);
                }
                //Edge-142082 shubhi end
                // Aditya: Edge:142084 Enable New Solution in MAC Basket
                CommonUtills.setBasketChange();
            });
            /*let map = {};
            map['GetSiteId'] = '';
            CS.SM.WebService.performRemoteAction('SolutionActionHelper', map).then(result => {
                console.log('GetSiteId finished with response: ', result);
            });*/
            //Method call to create User related Product automatically.
            if (basketStage === 'Contract Accepted') {
                loadedSolution.lock('Commercial', false);
            }
            await populateRateCardinAttachment();
              if (window.BasketChange === 'Change Solution') {
            await updateChangeTypeAttributeNGUC(loadedSolution);// Updated name to resolve
              }
            await addDefaultUCOEConfigs();
            await updateOeTabsVisibilityNGUC();
            await updatecontracttypeattributes(loadedSolution);
            // Edge 138108 MAC Consumption based
            await checkConfigurationSubscriptionsForNGUC('afterSolutionLoaded');
            pricingUtils.resetCustomAttributeVisibilityNGUC_Device(); //added by Aditya for 133963
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //added by Romil for EDGE-144161
            var showRateCart = false;
            //Added by Aman Soni as a part of EDGE-142082 || Start
            var solutionComponent = false;
            var componentMap = new Map();
            var componentMapattr = {};
            if (loadedSolution.name === (NEXTGENUC_COMPONENTS.solution)) {//EDGE-154465
                if (Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {//EDGE-154465
                    solutionComponent = true;
                    var billingAccLook = Object.values(Object.values(loadedSolution.schema.configurations)[0].attributes).filter(a => {//EDGE-154465
                        return a.name === 'BillingAccountLookup'
                    });
                    componentMapattr['BillingAccountLookup'] = [];
                    componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
                    componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);//EDGE-154465
                    await CommonUtills.attrVisiblityControl(NEXTGENUC_COMPONENTS.solution, componentMap);
                    if (billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                    {
                        CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                    }
                }
                if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
                    Object.values(loadedSolution.components).forEach((comp) => {
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
                }
            }
            //Added by Aman Soni as a part of EDGE-142082 || End
            if (window.totalRedemptions > 0) {
                await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.UC, '');//EDGE-169593
                await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.AccessoryMTS, '');//EDGE-1695930
            }
            if (window.BasketChange === 'Change Solution') {
                await UpdateMainSolutionChangeTypeVisibility(loadedSolution);
                await UpdateChangeTypeVisibility(loadedSolution);
                await UpdateAttributesForMacdOnSolution(loadedSolution);
                //Aditya for NGUC MACD EDGE-121389
                await pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart);
                //added by Romil EDGE-130075,EDGE-136954
                //RedemptionUtils.populatebasketAmountforCancel();
                //RedemptionUtils.populatebasketAmountforCancelAccessory();
                let updateConfigMapsubs = {};
            }
            //Added by Shubhi as a part of EDGE-133963 
            pricingUtils.checkDiscountValidation(loadedSolution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
            pricingUtils.checkDiscountValidation(loadedSolution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
            // Added for EDGE-138001
            Utils.updateImportConfigButtonVisibility();
            //END changes for EDGE-138001
            //Added for EDGE-138108
            //UCEPlugin.UpdateVisibilityBasedonContracttype(loadedSolution);       
            if (basketStage === 'Contract Accepted') {
                loadedSolution.lock('Commercial', true);
            }
            return Promise.resolve(true);
        }
    });
    setInterval(UCEPlugin_processMessagesFromIFrame, 500);
    //Added by Aman Soni as a part of EDGE-133963 || Start
    Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
    Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
    Utils.updateCustomAttributeLinkText('Rate Card', 'View All');
    //pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
    //pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
    //pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //added by Romil for 144161
    subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS); //added by Shubhi for EDGE-143957
    subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC); //added by Shubhi for EDGE-143957
    subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC); //added by Shubhi for EDGE-143957
    //Added by Aman Soni as a part of EDGE-133963 || End
    // Laxmi EDGE-138001 - method call  to hide the import configuraton button
    //Utils.updateImportConfigButtonVisibility();	
    setInterval(saveSolutionNgUC, 500);
    UCEPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {//PD added async
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', false);
        }
        //Added by romil EDGE-118038,EDGE-136954
        //await RedemptionUtils.checkConfigurationStatus();
        //await RedemptionUtils.checkConfigurationStatusforAccessory();
        var skipsaveDevice = pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        var skipsaveVoice = pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
        console.log('before save == ', solution);
        if (skipsaveDevice == true || skipsaveVoice == true) {
            skipsave = false;
            return Promise.resolve(false); // EDGE-154465
        }
        if (window.totalRedemptions > 0) {
            var skipdevicesave = await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.UC, '');//EDGE-169593
            var skipaccsave = await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENUC_COMPONENTS.AccessoryMTS, '');//EDGE-1695930
            if (skipdevicesave || skipaccsave)
                return Promise.resolve(false);//EDGE-1695930
        }
        if (saveNgUC) {
            saveNgUC = false;
            console.log('beforeSave - exiting true');
            return Promise.resolve(true);
        }
        executeSaveNgUC = true;
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', true);
        }
        return Promise.resolve(true);// EDGE-154465
    }
    UCEPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        let solution = result.solution;

        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', false);
        }

        // Edge 138108 MAC Consumption based
        await checkConfigurationSubscriptionsForNGUC('afterSave');
        console.log('afterSave - entering', solution);
        //Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954,EDGE-144161
        //await RedemptionUtils.checkRedeemDiscountonload(solution);
        await RedemptionUtils.calculateBasketRedemption();
        //await RedemptionUtils.displayCurrentFundBalanceAmt();
        //await RedemptionUtils.populatebasketAmount();
        //await RedemptionUtils.populatebasketAmountforAccessory();
        //await RedemptionUtils.populatebasketAmountforSaved();
        //await RedemptionUtils.populatebasketAmountforSavedAccessory();
        //await RedemptionUtils.populatebasketAmountforCancel();
        //await RedemptionUtils.populatebasketAmountforCancelAccessory();
        //await RedemptionUtils.checkConfigurationStatus();
        //await RedemptionUtils.checkConfigurationStatusforAccessory();
        var showRateCart = false
        //Added by Aman Soni as a part of EDGE-142082 || Start
        var solutionComponent = false;
        if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {
            if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) { // EDGE-154465
                solutionComponent = true;
                var componentMapASave = new Map();
                var componentMapattrAftSave = {};
                Object.values(solution.schema.configurations).forEach((config) => {// EDGE-154465
                    if (config.replacedConfigId && config.replacedConfigId != null) {
                        Object.values(config.attributes).forEach((attr) => {
                            var billingAccLook = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(a => { // EDGE-154465
                                return a.name === 'BillingAccountLookup'
                            });
                            if (billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                            {
                                CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENUC_COMPONENTS.solution, 'BillingAccountLookup', solutionComponent);
                            }
                            componentMapattrAftSave['BillingAccountLookup'] = [];
                            componentMapattrAftSave['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
                            componentMapASave.set(config.guid, componentMapattrAftSave);
                        });
                    }
                });
                CommonUtills.attrVisiblityControl(NEXTGENUC_COMPONENTS.solution, componentMapASave);
            }
        }
        //Added by Aman Soni as a part of EDGE-142082 || End
        if (window.BasketChange === 'Change Solution') {
            await UpdateAttributesForMacdOnSolution(solution);
            pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart);
              await updateChangeTypeAttributeNGUC(solution);// updated name to resolve conflicts
              await UpdateChangeTypeVisibility(solution);
              await UpdateMainSolutionChangeTypeVisibility(solution);
        }
        //Added by Aman Soni as a part of EDGE-133963 || Start
        if (window.currentSolutionName === NEXTGENUC_COMPONENTS.solution) {
            Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
            Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
            Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
        }
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS); //added by Shubhi for EDGE-143957
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC); //added by Shubhi for EDGE-143957
        //Added by Aman Soni as a part of EDGE-133963 || End
        UCEPlugin.setOEtabsforUC(solution);
        await updatecontracttypeattributes(solution);
        pricingUtils.resetCustomAttributeVisibilityNGUC_Device(); //added by Aditya for 133963
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI'); //added by Shubhi for 133963/121376
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIVoice'); //added by Shubhi for 133963/121376
        pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory'); //romil for 144161
        //Addde  for 138001
        Utils.updateImportConfigButtonVisibility();
        Utils.hideSubmitSolutionFromOverviewTab(); //EDGE-135267
        // Edge 138108 MAC Consumption based
        await checkConfigurationSubscriptionsForNGUC('afterSave');
        //Added for EDGE-138108
        //UCEPlugin.UpdateVisibilityBasedonContracttype();
        await updateConfigName_Accesory(); //edge120921
        await updateConfigName_Device(); //edge-120921
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade     
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', true);
        }
        return Promise.resolve(true);
    }
    UCEPlugin.afterOrderEnrichmentConfigurationAdd = async function (component, configuration, orderEnrichmentConfiguration) {
        let currentSolution = await CS.SM.getActiveSolution();
        if (basketStage === 'Contract Accepted') {
            currentSolution.lock('Commercial', false);
        }
        console.log('UCE afterOrderEnrichmentConfigurationAdd', component, configuration, orderEnrichmentConfiguration)
        initializeUCOEConfigs();
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        checkConfigurationSubscriptionsForNGUCForEachComponent(component, true, 'afterSave');
        if (basketStage === 'Contract Accepted') {
            currentSolution.lock('Commercial', true);
        }
        return Promise.resolve(true);
    }
    UCEPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    }
    //Aditya: Spring Update for changing basket stage to Draft
    UCEPlugin.afterSolutionDelete = function (solution) {
        if (window.totalRedemptions > 0)
            RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    }
    // EDGE-154465 start
    /*UCEPlugin.buttonClickHandler = async function(buttonSettings) {
        console.log('buttonClickHandler: id=', buttonSettings.id, buttonSettings);
        let url = '';
        var redirectURI = '/apex/';
        if (communitySiteIdUC) {
            //Fix for Number reservation url issue in Prod - Venkat 21-09-19
            url = window.location.href;
            if (url.includes('partners.enterprise.telstra.com.au'))
                redirectURI = '/s/sfdcpage/%2Fapex%2F';
            else
                redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
        }
        url = redirectURI;
        if (buttonSettings.id === 'UCReserveNumbersBtn') {
            console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
            var ucConfigId;
            if (basketStage === 'Contract Accepted') {
                //await CS.SM.getActiveSolution().then((currentSolution) => { PD
                let currentSolution = await CS.SM.getActiveSolution();
                    if (currentSolution.type && currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
                        if (currentSolution.components && currentSolution.components.length > 0) {
                            //currentSolution.components.forEach((comp) => {PD
                            for(const comp of Object.values(currentSolution.components)){
                                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                                    if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                                        var ucConfig = Object.values(config.attributes).filter(config => {
                                            return config.guid === buttonSettings.configurationGuid
                                        });
                                        //var ucConfig = comp.schema.configurations.filter(config => {
                                        //	return config.guid === buttonSettings.configurationGuid
                                        //});	PD								
                                        if (ucConfig && ucConfig[0] && ucConfig[0].id) {
                                            ucConfigId = ucConfig[0].id;
                                        }
                                    }
                                }
                            }
                        }
                    }
                //});PD
                console.log('ucConfigId', ucConfigId);
                if (ucConfigId) {
                    if (communitySiteIdUC) {
                        url = '/partners/';
                        url = url + 'c__NumberManagement?basketId=' + basketId + '&configId=' + ucConfigId;
                    } else {
                        url = url + 'c__NumberManagement?basketId=' + basketId + '&configId=' + ucConfigId;
                    }
                    return Promise.resolve(url);
                } else {
                    CS.SM.displayMessage('Can not reserve numbers, configuration is not saved!', 'info');
                    return Promise.resolve(true);
                }
            } else {
                CS.SM.displayMessage('Can not do number reservation when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        } else if (buttonSettings.id === 'checkInventory') { // EDGE-108289 - Fix to show check inventory button
            console.log('basketId', basketId);
            if (communitySiteIdUC) {
                url = '/partners/';
                url = url + 'c__StockCheckPage?basketID=' + basketId;
            } else {
                url = url + 'c__StockCheckPage?basketID=' + basketId;
            }
            console.log('url: ', url);
            return Promise.resolve(url);
        } else if (buttonSettings.id === 'reserveNumber') { // EDGE-59982  - Fix to show Number reservation button
            console.log('basketId', basketId);
            if (communitySiteIdUC) {
                // Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
                url = '/partners/';
                url = url + ('c__NumberReservationPage?basketId=' + basketId);
            } else {
                url = url + 'c__NumberReservationPage?basketId=' + basketId;
            }
            console.log('url: ', url);
            return Promise.resolve(url);
        } else if (buttonSettings.id === 'getPriceScheduleAPIAccessory') { // added by Romil for Edge-144161
            let solutionId = '';
            let discountStatus = '';
            let correlationId = '';
            var solName = '';
            IsDiscountCheckNeeded = false;
            IsRedeemFundCheckNeeded = false;
            callerNameNGUC = 'Accessories';
            solName = 'Accessory';
            uniquehexDigitCode = Date.now();
            //await CS.SM.getActiveSolution().then((product) => {PD
                let product = await CS.SM.getActiveSolution();
                solution = product;
                solutionId = product.solutionId;
                solutionID = product.solutionId;
                if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
                    if (solution.components && solution.components.length > 0) {
                        if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0) {
                            solution.schema.configurations.forEach((config) => {
                                //var correlationIds = config.attributes.filter(correlationId => {
                                //	return correlationId.name === 'correlationId_Accessory' && !correlationId.value
                                //});PD*													
                                var discount_Status = Object.values(config.attributes).filter(discount_Status => {
                                    return discount_Status.name === 'DiscountStatus_Accessory';
                                });//PD
                                if (discount_Status && discount_Status != null && discount_Status[0] && discount_Status[0].value) {
                                    discountStatus = discount_Status[0].value;
                                }
                                console.log('###discountStatus###' + discountStatus);
                            });
                        }
                        //solution.components.forEach((comp) => {PD
                        for(const comp of Object.values(solution.components)){
                            if (comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                                    //comp.schema.configurations.forEach((config) => {PD
                                    for(const config of Object.values(comp.schema.configurations)){										
                                        //var IsRedeemFundCheckNeededAttr = config.attributes.filter(IsRedeemFundCheckNeededAttr => {
                                        //	return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
                                        //});PD
                                        var IsRedeemFundCheckNeededAttr = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAttr => {
                                            return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded';
                                        });//PD
                                        if (IsRedeemFundCheckNeededAttr[0].value === true) {
                                            IsRedeemFundCheckNeeded = true;
                                        }										
                                    }
                                }
                            }
                        }
                    }
                }
            //});PD
            if (communitySiteIdUC) {
                var baseurl = window.location.href;
                if (baseurl.includes('partners.enterprise.telstra.com.au')) {
                    url = url = url + 'c__GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded + '&i=';
                } else {
                    url = '/partners/';
                    url = url + 'c__GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded + '&i=';
                }
            } else {
                url = url + 'c__GetPriceScheduleCommon?basketId=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded;
            }
            pricingUtils.setDiscountAttribute();
            pricingUtils.customLockSolutionConsole('lock');
            //let vfRedirect ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
            console.log('url---->' + url);
            return Promise.resolve(url);
        }
        //Added by Aman Soni as a part of EDGE-133963 || Start	
        else if (buttonSettings.id === 'getPriceScheduleAPI') { // updated by shubhi Edge-143527
            let solutionId = '';
            let discountStatus = '';
            let correlationId = '';
            var solName = '';
            IsDiscountCheckNeeded = false;
            IsRedeemFundCheckNeeded = false;
            callerNameNGUC = 'Devices';
            solName = 'Unified Communication Device';
            uniquehexDigitCode = Date.now();
            ///await CS.SM.saveSolution(true, true).then( solId => console.log(solId));
            //await CS.SM.getActiveSolution().then((product) => {PD
            let product = await CS.SM.getActiveSolution();
                solution = product;
                solutionId = product.solutionId;
                solutionID = product.solutionId;
                if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
                    if (solution.components && solution.components.length > 0) {
                        if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0) {
                            //solution.schema.configurations.forEach((config) => {	PD
                            for(const config of Object.values(solution.schema.configurations)){	
                                //var correlationIds = config.attributes.filter(correlationId => {
                                //	return correlationId.name === 'correlationId' && !correlationId.value
                                //});PD
                                var correlationIds = Object.values(config.attributes).filter(correlationId => {
                                    return correlationId.name === 'correlationId' && !correlationId.value;
                                });
                                if (correlationIds && correlationIds != null && correlationIds[0] && correlationIds[0].value) {
                                    correlationId = correlationIds[0].value;
                                }
                                console.log('###correlationId###' + correlationId);
                                //var discount_Status = config.attributes.filter(discount_Status => {
                                //	return discount_Status.name === 'DiscountStatus'
                                //});PD
                                var discount_Status = Object.values(config.attributes).filter(discount_Status => {
                                    return discount_Status.name === 'DiscountStatus';
                                });
                                if (discount_Status && discount_Status != null && discount_Status[0] && discount_Status[0].value) {
                                    discountStatus = discount_Status[0].value;
                                }
                                //console.log('###discountStatus[0].value###'+discountStatus[0].value);
                                console.log('###discountStatus###' + discountStatus);
                            }
                        }
                        //solution.components.forEach((comp) => {PD
                        for(const comp of Object.values(solution.components)){
                            // Aditya updated for Voice EDGE-121376
                            if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {									
                                    //comp.schema.configurations.forEach((config) => {PD
                                    for(const config of Object.values(comp.schema.configurations)){
                                        //var IsDiscountCheckNeededAtt = config.attributes.filter(IsDiscountCheckNeededAt => {
                                        //	return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
                                        //});PD
                                        var IsDiscountCheckNeededAtt = Object.values(config.attributes).filter(disIsDiscountCheckNeededAttcount_Status => {
                                            return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
                                        });
                                        //added by Romil for EDGE- 144161
                                        //var IsRedeemFundCheckNeededAttr = config.attributes.filter(IsRedeemFundCheckNeededAttr => {
                                        //	return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
                                        //});PD
                                        var IsRedeemFundCheckNeededAttr = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAttr => {
                                            return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
                                        });
                                        if (IsDiscountCheckNeededAtt[0].value === true && discountStatus !== 'Locked') {
                                            IsDiscountCheckNeeded = true;
                                        }
                                        console.log('###IsDiscountCheckNeededAtt###' + IsDiscountCheckNeeded);
                                        if (IsDiscountCheckNeededAtt[0].value === true && discountStatus === 'Locked' && correlationId === '') {
                                            IsDiscountCheckNeeded = true;
                                        }
                                        //EDGE-144161 Added check by Romil
                                        if (IsRedeemFundCheckNeededAttr[0].value === true) {
                                            IsRedeemFundCheckNeeded = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            if (communitySiteIdUC) {
                //Rohit Prodcution Fix Changes
                var baseurl = window.location.href;
                if (baseurl.includes('partners.enterprise.telstra.com.au')) {
                    url = url = url + 'c__GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded + '&i=';
                } else {
                    url = '/partners/';
                    url = url + 'c__GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded + '&i=';
                }
            } 
            else {
                url = url + 'c__GetPriceScheduleCommon?basketId=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&IsRedeemFundCheckNeeded=' + IsRedeemFundCheckNeeded;
            }
            //let payload11 ={
            //	command: 'childWindow',
            //	data: 'childWindow',
            //	caller: callerNameNGUC
            //};
            //sessionStorage.setItem("payload11", JSON.stringify(payload11));
            pricingUtils.setDiscountAttribute();
            pricingUtils.customLockSolutionConsole('lock');
            //let vfRedirect ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
            console.log('url---->' + url);
            return Promise.resolve(url);
        } else if (buttonSettings.id === 'getPriceScheduleAPIVoice') { //Added by Aman Soni as a part of Deal Management story
            let solutionId = '';
            let discountStatus = '';
            let correlationId = '';
            callerNameNGUC = 'Business Calling';
            let solName = 'Business Calling';
            IsDiscountCheckNeeded = false;
            uniquehexDigitCode = Date.now();
            //await CS.SM.getActiveSolution().then((product) => {PD
            let product = await CS.SM.getActiveSolution();	
                solution = product;
                solutionId = product.solutionId;
                solutionID = solutionId;
                if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
                    if (solution.components && solution.components.length > 0) {
                        if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0) {
                            //solution.schema.configurations.forEach((config) => {
                            Object.values(solution.schema.configurations).forEach((comp) => {
                                var correlationIds = config.attributes.filter(correlationId => {
                                    return correlationId.name === 'correlationId_voice' && !correlationId.value
                                });
                                if (correlationIds && correlationIds != null && correlationIds[0] && correlationIds[0].value) {
                                    correlationId = correlationIds[0].value;
                                }
                                console.log('###correlationId###' + correlationId);
                                var discount_Status = config.attributes.filter(discount_Status => {
                                    return discount_Status.name === 'DiscountStatus_voice'
                                });
                                if (discount_Status && discount_Status != null && discount_Status[0] && discount_Status[0].value) {
                                    discountStatus = discount_Status[0].value;
                                }
                                //console.log('###discountStatus[0].value###'+discountStatus[0].value);
                                console.log('###discountStatus###' + discountStatus);
                            });
                        }
                        //solution.components.forEach((comp) => {PD
                        Object.values(currentSolution.components).forEach((comp) => {
                            // Aditya updated for Voice EDGE-121376
                            if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                                    comp.schema.configurations.forEach((config) => {
                                        var IsDiscountCheckNeededAtt = config.attributes.filter(IsDiscountCheckNeededAt => {
                                            return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
                                        });
                                        if (IsDiscountCheckNeededAtt[0].value === true && discountStatus !== 'Locked') {
                                            IsDiscountCheckNeeded = true;
                                        }
                                        console.log('###IsDiscountCheckNeededAtt###' + IsDiscountCheckNeeded);
                                        if (IsDiscountCheckNeededAtt[0].value === true && discountStatus === 'Locked' && correlationId === '') {
                                            IsDiscountCheckNeeded = true;
                                        }
                                    });
                                }
                            }
                        });
                    }
                }
            //});PD
            if (communitySiteIdUC) {
                //Rohit Prodcution Fix Changes
                var baseurl = window.location.href;
                if (baseurl.includes('partners.enterprise.telstra.com.au')) {
                    url = url = url + 'GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&i=';
                } else {
                    url = '/partners/';
                    url = url + 'GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&i=';
                }
            } else {
                url = url + 'c__GetPriceScheduleCommon?basketid=' + basketId + '&SolutionId=' + solutionId + '&accountId=' + accountId + '&discountStatus=' + discountStatus + '&correlationId=' + correlationId + '&IsDiscountCheckNeeded=' + IsDiscountCheckNeeded + '&callerName=' + callerNameNGUC + '&solutionName=' + solName + '&basketNum=' + basketNum + '&hexid=' + uniquehexDigitCode + '&i=';
                // EDGE-135885 - added Basket Num and Solution Name in URL
            }
            //let payload11 ={
            //	command: 'childWindow',
            //	data: 'childWindow',
            //	caller: callerNameNGUC
            //};
            //sessionStorage.setItem("payload11", JSON.stringify(payload11));
            pricingUtils.setDiscountAttribute();
            pricingUtils.customLockSolutionConsole('lock');
            //let vfRedirect1 ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
            console.log('url---->' + url);
            return Promise.resolve(url);
        } else if (buttonSettings.id === 'numberreservationnew') {
            if (Utils.isOrderEnrichmentAllowed()) { //basketStage ==='Contract Accepted'
                if (communitySiteIdUC) {
                    // Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
                    //url = '/partners/';
                    var baseurl = window.location.href;
                    if (baseurl.includes('partners.enterprise.telstra.com.au')) {
                        url = ('c__NumberReservation?basketId=' + basketId);
                    } else {
                        url = '/partners/';
                        url = url + ('c__NumberReservation?basketId=' + basketId);
                    }
                } else {
                    url = '/apex/c__NumberReservation?basketId=' + basketId;
                }
                //EDGE-93081 - Kalashree, Conditionally render page - end
                return Promise.resolve(url);
                //return Promise.resolve('/apex/c__NumberReservationPage?basketId=' + basketId);
            } else {
                CS.SM.displayMessage('Can not do number reservation when basket is in ' + basketStage + ' stage', 'info');
                return Promise.resolve(true);
            }
        }
        //Added by Aman Soni as a part of EDGE-133963 || End	
        else if (buttonSettings.id === 'CheckOneFund') //Added by romil EDGE-130075,EDGE-136954
        {
            console.log('buttonSettings.id', buttonSettings.id);
            RedemptionUtils.displayRemainingBalanceAmt();
        }
        return Promise.resolve(true);
    }PD*/
    // EDGE-154465
    UCEPlugin.beforeConfigurationAdd = async function (component, configuration) {
        console.log('before configurationadd log' + configuration);
        await UCEPlugin.RewokeConfigurationOnCancel();
        console.log('returnflag-->', returnflag)
        return Promise.resolve(returnflag);
    }
    UCEPlugin.afterConfigurationAdd = async function (component, configuration) {
        console.log('afterConfigurationAdd', component, configuration);
        var updatemap = {}; // EDGE-154465
        //Added by romil EDGE-115925,EDGE-136954
        //await RedemptionUtils.calculateBasketRedemption();
        await RedemptionUtils.populateNullValues(component.name, configuration);
        //Added by Aman Soni as a part of EDGE-133963 || Start
        // Aditya updated for Voice EDGE-121376
        if (component.name === NEXTGENUC_COMPONENTS.DevicesMTS || NEXTGENUC_COMPONENTS.UC) {
            Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
            Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
            Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
        }
        //Added by Aman Soni as a part of EDGE-133963 || End	
        // EDGE-154465 start
        if (component.name === NEXTGENUC_COMPONENTS.UC) {
            updatemap[configuration.guid] = [];
            updatemap[configuration.guid].push({
                name: 'ChangeType',
                //showInUi: false,  // EDGE-154465
                value: 'New'
            });
            //CS.SM.updateConfigurationAttribute(componentName, updatemap, true);
            if (updatemap && Object.keys(updatemap).length > 0) {
                keys = Object.keys(updatemap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updatemap[keys[i]], true);
                }
            }
            // EDGE-154465 end
            //UCEPlugin.updateRCforUCFeatures(configuration.guid, 'UCUserQuantity', 1);
        }
        //added by shubhi for voice/device pricing
        let solution;
        //await CS.SM.getActiveSolution().then((product) => { // EDGE-154465
        let product = await CS.SM.getActiveSolution();
        solution = product;
        pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
        //}); // EDGE-154465
        await calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.DevicesMTS); //Edge-120919
        await calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.UC); //Edge-120919
        //pricingUtils.resetDiscountAttributes(configuration.guid, componentName); Aditya updated for Edge-120919 NGUC consumption based model new
        //added by shubhi for voice/device pricing end
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.DevicesMTS);
        subscribeToExpandButtonEvents(NEXTGENUC_COMPONENTS.UC);
        return Promise.resolve(true);
    }
    UCEPlugin.afterConfigurationAddedToMacBasket = async function (componentName, guid) {
        let solution = await CS.SM.getActiveSolution();
        let component = solution.getComponentByName(componentName);
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', false);
        }
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
        UCEPlugin.UpdateAttributeVisibilityForMacd(componentName, guid, changeTypeAtrtribute[0].value);
        // Arinjay 11 Aug End
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', true);
        }
        return Promise.resolve(true);
    }
    UCEPlugin.afterConfigurationDelete = async function (componentName, configuration) {
        console.log('Parent Config Delete - After', componentName, configuration);
        //Added by romil EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954
        //RedemptionUtils.calculateBasketRedemption();
        //await RedemptionUtils.populatebasketAmount();
        //await RedemptionUtils.populatebasketAmountforAccessory();
        if (window.totalRedemptions > 0)
            await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
    }
    UCEPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {// EDGE-154465
        let componentName = component.name; // EDGE-154465
        let guid = configuration.guid; // EDGE-154465
        console.log('Attribute Update - After', componentName, configuration, attribute, oldValueMap);// EDGE-154465
        let solution = await CS.SM.getActiveSolution();

        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', false);
        }

        if ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && (attribute.name === 'DisconnectionDate' || attribute.name === 'RedeemFund' || attribute.name === 'EarlyTerminationCharge')) {
            UCEPlugin.calculateTotalETCValue(guid);
            //added by Romil EDGE-130075,EDGE-136954
            //await RedemptionUtils.populatebasketAmountforCancel();
            //await RedemptionUtils.populatebasketAmountforCancelAccessory();
            if (attribute.name === 'EarlyTerminationCharge')
                RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //EDGE-169593               
        } //EDGE-81135 : Cancellation of CMP
        if (attribute.name === 'RedeemFund') {
            //RedemptionUtils.CheckRedeemFundDiscount(guid, componentName); //Added by Romil as part of EDGE-140968
            await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, attribute.value); //EDGE-169593
            await RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593
            if (attribute.value >= 0)
                await RedemptionUtilityCommon.validateBasketRedemptions(false, componentName, '');//EDGE-169593
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'DisconnectionDate') {
            UCEPlugin.validateDisconnectionDate(componentName, guid, /*newValue*/attribute.value);// EDGE-154465
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
                //calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.UC); //Edge-120919
            }
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && attribute.name === 'callingPlans') {
            await updateplanlookup(guid, /*newValue*/attribute.value);///EDGE-162560 // EDGE-154465
            calculateIsDiscountCheckNeeded(componentName);
            if (isEapActive) {
                pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Edge-120919 NGUC consumption based model new
                pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya
                //calculateIsDiscountCheckNeeded(NEXTGENUC_COMPONENTS.UC); //Edge-120919
            }
        }
        /*if (componentName === NEXTGENUC_COMPONENTS.UC && (attribute.name === 'UCUserQuantity' || attribute.name === 'HuntGroupQuantity' || attribute.name === 'AutoAttendantQuantity' || attribute.name === 'MainBusinessNumberQuantity' || attribute.name === 'HostedUCQuantity')) {
            UCEPlugin.updateRCforUCFeatures(guid, attribute.name, newValue);
        }*/ ///Edge-120919 commented by shubhi
        if (window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType') {
            UCEPlugin.UpdateAttributeVisibilityForMacd(componentName, guid, /*newValue*/ attribute.value);// EDGE-154465
        }
        if (componentName === NEXTGENUC_COMPONENTS.UC && window.BasketChange === 'Change Solution' && attribute.name === 'ChangeType' && attribute.value === 'Modify') //Aditya for NGUC MACD EDGE-121389---Start--->PD changed newValue to attribute.Value
        {
            var updateConfigMap = {};
            // EDGE-154465 start
            updateConfigMap[guid] = [];
            updateConfigMap[guid].push({
                name: "IsDiscountCheckNeeded",
                value: true
            }, {
                name: "Mode",
                readOnly: true
            });
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false);PD
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                let keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                }
            }
            //CS.SM.updateConfigurationStatus(componentName, guid, false, 'Please generate price schedule post configuration to view rate card and latest discount status');
            configuration.status = false;
            configuration.message = 'Please generate price schedule post configuration to view rate card and latest discount status';
            // EDGE-154465 end
            // Arinjay 11 Aug Start 
            pricingUtils.resetCustomAttributeVisibilityNGUC_Device();
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
            pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart);
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false);PD
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                let keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                }
            }
            //CS.SM.updateConfigurationStatus(componentName, guid, true);PD
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
            /*await RedemptionUtils.displayCurrentFundBalanceAmt();
            await RedemptionUtils.calculateBasketRedemption();
            await RedemptionUtils.populatebasketAmount();
            await RedemptionUtils.populatebasketAmountforSaved();*/
            await updatecontracttypeattributes(solution);
        }
        //added by Romil for fund Redemption EDGE-113083, EDGE-115925,EDGE-116121,EDGE-127941,EDGE-119323,EDGE-116121,EDGE-113091,EDGE-113570,EDGE-114977,EDGE-136954
        if (((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && (attribute.name === 'Accessorymodel' || attribute.name === 'AccessoriesType' || attribute.name === 'Quantity' || attribute.name === 'OC' || attribute.name === 'ContractType' || attribute.name === 'RedeemFund' || attribute.name === 'taxTreatment'))) {
            if (attribute.name === 'Accessorymodel') {
                await updateConfigName_Accesory(); //edge120921
            }
            if (attribute.name === 'ContractType' && attribute.displayValue === 'Hardware Repayment') {
                await RedemptionUtilityCommon.validateBasketRedemptions(false, componentName, '');//EDGE-169593
            } else if (attribute.name === 'ContractType' && attribute.displayValue === 'Purchase') {
                RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //EDGE-169593
            }
            /*await RedemptionUtils.displayCurrentFundBalanceAmt();
            await RedemptionUtils.calculateBasketRedemption();
            await RedemptionUtils.populatebasketAmountforAccessory();
            await RedemptionUtils.populatebasketAmountforSavedAccessory();*/
        }
        // added by Venkat for ContractTermPopulation
        if ((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attribute.name === 'ContractType' && attribute.value !== '') {
            // EDGE-154465 start
            var updateMap = {};


            // updated for Edge-updated for edge-175185
            if (attribute.displayValue === 'Purchase') {
                updateMap[guid] = [];
                updateMap[guid].push({
                    name: "ContractTerm",
                    showInUi: false,
                    //value: "NA"
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
                    //value: "NA"
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
                updateMap[guid].push({
                    name: "TotalFundAvailable",
                    showInUi: false
                });
                updateMap[guid].push({
                    name: "OneOffChargeGST",
                    showInUi: false
                });
            }
            //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                let keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                }
            }
        }
        // EDGE-154465 end
        /*if (componentName === NEXTGENUC_COMPONENTS.UC && (attribute.name === 'NumberofPhoneNumbers' || attribute.name === 'HuntGroupQuantity' || attribute.name === 'HostedUCQuantity' || attribute.name === 'concurrencyLimit' || attribute.name === 'UCUserQuantity' || attribute.name === 'AutoAttendantQuantity')) {
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya
        }*/ //Edge-120919 commented 
        //Added by shubhi for Device 
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Device Type') {
            console.log('Inside attribute ContractType');
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'BussinessId_Device', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'Model', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'ContractType', true);
            //pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya NGUC consumption based model new
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
        }
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Model') {
            console.log('Inside attribute ContractType');
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'BussinessId_Device', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'ContractType', true);
            //pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            await updateConfigName_Device(); //edge-120921
        }
        // Aditya updated for Voice EDGE-121376
        // Aditya updated for Voice EDGE-121376
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'Quantity') {
            console.log('Inside attribute ContractType');
            //pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated Edge-120919 NGUC consumption based model new
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
        }
        // added by shubhi EDGE-121376
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attribute.name === 'ContractType') {
            console.log('Inside attribute ContractType');
            //pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Edge-120919 NGUC consumption based model new
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.DevicesMTS, 'deviceShadowRCTCV', true);
        }
        /*if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'UCUserQuantity') {
            console.log('Inside attribute UCUserQuantity');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice');
            // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'UserShadowRCTCV', true);
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'NumberofPhoneNumbers') {
            console.log('Inside attribute NumberofPhoneNumbers');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'PhoneNumberShadowRCTCV', true);
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'HuntGroupQuantity') {
            console.log('Inside attribute HuntGroupQuantity');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'HuntGroupShadowRCTCV', true);
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'AutoAttendantQuantity') {
            console.log('Inside attribute AutoAttendantQuantity');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'AutoAttendantShadowRCTCV', true);
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'HostedUCQuantity') {
            console.log('Inside attribute HostedUCQuantity');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice'); // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'HostedUCShadowRCTCV', true);
        }
        if ((componentName === NEXTGENUC_COMPONENTS.UC) && attribute.name === 'concurrencyLimit') {
            console.log('Inside attribute UCUserQuantity');
            pricingUtils.resetDiscountAttributes(guid, componentName); // Aditya updated for Voice EDGE-121376
            pricingUtils.setDiscountStatusBasedonComponent('None', NEXTGENUC_COMPONENTS.solution, 'DiscountStatus_voice');; // Aditya updated for Voice EDGE-121376
            Utils.emptyValueOfAttribute(guid, NEXTGENUC_COMPONENTS.UC, 'VoiceLinesShadowRCTCV', true);
        }*/ ///commented by shubhi for Edge-120919
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
        if (componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD') {
            await updateNotBeforeCRDOnUC(guid, /*newValue*/ attribute.value); // EDGE-154465
        }
        if (componentName === 'Customer requested Dates' && attribute.name === 'Preferred CRD') {
            await updatePreferredCRDOnUC(guid, /*newValue*/ attribute.value); // EDGE-154465
        }
        //Added by Aman Soni as a part of EDGE-133963 || Start
        // Aditya updated for Voice EDGE-121376
        if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.UC) {
            Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
            Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
            Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
        }
        //Added by Aman Soni as a part of EDGE-133963 || End
        //Added by Shubhi as a part of EDGE-133963 
        //let solution;
        //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
        //let solution = await CS.SM.getActiveSolution();// EDGE-154465
        //solution = product;// EDGE-154465
        pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.UC);
        //});
        await window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValueMap.value, attribute.value);
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', true);
        }
        //added by Shubhi  edge-142082 start------
        return Promise.resolve(true);
    }
    UCEPlugin.UpdateAttributeVisibilityForMacd = async function (componentName, guid, changeTypeValue) {
        await updateOeTabsVisibilityNGUC(guid);
        if (changeTypeValue === 'Cancel') {
            await updateCancellationReason(componentName, guid, true);
            if (componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent || componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
                UCEPlugin.updateDisconnectionDate(componentName, guid, true, basketStage === 'Commercial Configuration', false);
            }
            if (componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
                UCEPlugin.updateETC(componentName, guid, true);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
            } else if (componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                UCEPlugin.updateETC(componentName, guid, true);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
            } else if (componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent) {
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductEditableAttributeList);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductNonEditableAttributeList);
            }
        }
        if (changeTypeValue !== 'Cancel') {
            await updateCancellationReason(componentName, guid, false);
            if (componentName === NEXTGENUC_COMPONENTS.UC || NEXTGENUC_COMPONENTS.UcComponent || componentName === NEXTGENUC_COMPONENTS.Accessory || NEXTGENUC_COMPONENTS.AccessoryMTS || componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
                UCEPlugin.updateDisconnectionDate(componentName, guid, false, false, false);
            }
            if (componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
                UCEPlugin.updateETC(componentName, guid, false);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
            } else if (componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                UCEPlugin.updateETC(componentName, guid, false);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
            } else if (componentName === NEXTGENUC_COMPONENTS.UC || componentName === NEXTGENUC_COMPONENTS.UcComponent) {
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, false, NEXTGENUC_COMPONENTS.BroadsoftProductEditableAttributeList);
                UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.BroadsoftProductNonEditableAttributeList);
            }
        }
        // Updated for EDGE-138108
        if (changeTypeValue === 'PaidOut' || changeTypeValue === 'Pending' || changeTypeValue === 'Paid Out') {
            UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.AccessoryEditableAttributeList);
            UCEPlugin.setAttributesReadonlyValueForConfiguration(componentName, guid, true, NEXTGENUC_COMPONENTS.UCDeviceEditableAttributeList);
        }
    }
    UCEPlugin.updateETC = async function (componentName, guid, isVisible) {
        console.log('updateDisconnectionDateAndETC ', componentName, guid, isVisible);
        // EDGE-154465 start
        let updateMap = {};
        updateMap[guid] = [];
        // updated for edge-175185
        /*let val = {
            readOnly: true,
            showInUi: isVisible,
            required: false
        };
        if (!isVisible) {
            val.value = '0';
        }*/
        let val = '0';
        updateMap[guid].push({//PD
            name: 'EarlyTerminationCharge',
            showInUi: isVisible,
            value: val
        });
        updateMap[guid].push({
            name: "RedeemFund",
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
        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);PD
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(componentName);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
        // EDGE-154465 end
    }
    UCEPlugin.updateDisconnectionDate = async function (componentName, guid, isVisible, isMandatory, isReadonly) {
        console.log('updateDisconnectionDate', componentName, guid, isVisible, isMandatory, isReadonly);
        // EDGE-154465 start
        let updateMap = {};
        updateMap[guid] = [];
        updateMap[guid].push({//PD
            name: 'DisconnectionDate',
            readOnly: isReadonly,
            showInUi: isVisible,
            required: isMandatory
        });
        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);PD
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(componentName);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
        // EDGE-154465
    }
    UCEPlugin.setAttributesReadonlyValueForConfiguration = async function (componentName, guid, isReadOnly, attributeList) {
        console.log('setAttributesReadonlyValueForConfiguration ', componentName, guid, isReadOnly, attributeList);
        // EDGE-154465
        let updateMap = {};
        updateMap[guid] = [];
        attributeList.forEach((attribute) => {
            updateMap[guid].push({//PD
                name: attribute,
                readOnly: isReadOnly
            });
        });
        console.log('setAttributesReadonlyValueForConfiguration updateMap', updateMap);
        //CS.SM.updateConfigurationAttribute(compName, updateMap, true).then((e) => console.log('setAttributesReadonlyValueForConfiguration: ', e));PD
        let activeSolution = await CS.SM.getActiveSolution();
        let component = await activeSolution.getComponentByName(componentName);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
        // EDGE-154465
    }
    /*
    UCEPlugin.UpdateMainSolutionChangeTypeValue = function(solution)  {
        let targetValue = 'New';
        if (window.BasketChange === 'Change Solution') {
            targetValue = 'Modify';
        }
        let changeTypeAttribute = solution.schema.configurations[0].attributes.filter(a => {return a.name==='ChangeType' && a.value==='Cancel'});
        if (changeTypeAttribute && changeTypeAttribute.length > 0) {
            return;
        }
        let updateMap= {};
        updateMap[solution.schema.configurations[0].guid] = [ {
            name: 'ChangeType',
            value: {
                value: targetValue,
                displayValue: targetValue
            }
        }];
        CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.solution, updateMap, true).catch(()=> Promise.resolve(true));
    }
    */
    UCEPlugin.calculateTotalETCValue = async function (guid) {  // EDGE-154465
        console.log('calculateTotalETCValue', window.BasketChange, guid);
        if (window.BasketChange !== 'Change Solution') {
            return;
        }
      //CS.SM.getActiveSolution().then((product) => { // EDGE-154465 // updated for edge-175185
        let currentBasket = await CS.SM.getActiveBasket();
        let product = await CS.SM.getActiveSolution();
        let contractTerm;
        let disconnectionDate;
        let prodConfigID;
      var updateMap = {};
      let componentName;
        console.log('calculateTotalETCValue', product);
        if (product.name === (NEXTGENUC_COMPONENTS.solution)) { // EDGE-154465 removed product.type && 
            if (product.components && Object.values(product.components).length > 0) {
                //product.components.forEach((comp) => { // EDGE-154465
                Object.values(product.components).forEach((comp) => { // EDGE-154465
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) { // EDGE-154465
                        //comp.schema.configurations.forEach((config) => { // EDGE-154465
                        Object.values(comp.schema.configurations).forEach((config) => { // EDGE-154465
                            if (config.guid === guid) {
                              componentName = comp.name; // EDGE-154465
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
                            }
                        });
                    }
                });
                console.log('contractTerm=', contractTerm, ', disconnectionDate=', disconnectionDate);
                if (disconnectionDate && contractTerm) {
                    var inputMap = {};
                  updateMap[guid] = [];
                    inputMap["getETCChargesForNGUC"] = '';
                    inputMap["DisconnectionDate"] = disconnectionDate;
                    inputMap["etc_Term"] = contractTerm;
                    inputMap["ProdConfigId"] = prodConfigID;
                    console.log('inputMap', inputMap);
                    //CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => { // EDGE-154465
                  await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
                        var charges = values["getETCChargesForNGUC"];
                        var chargesGst = parseFloat(charges * 1.1).toFixed(2); //added by Romil EDGE-130075,EDGE-136954
                        console.log('getETCChargesForNGUC Result', values["CalculateEtc"], charges);
                        // EDGE-154465 start
                        updateMap[guid].push({
                            name: 'EarlyTerminationCharge',
                            value: charges,
                            displayValue: charges
                      });
                      updateMap[guid].push( {
                            name: 'OneOffChargeGST', //added by Romil EDGE-130075,EDGE-136954
                            label: 'Balance Due On Device(Inc GST)',
                            value: chargesGst,
                            displayValue: chargesGst
                        });
                        //CS.SM.updateConfigurationAttribute(componentName, updateMap, true).then(component => console.log('calculateTotalETCValue Attribute update', component));
                    });
                    let activeSolution = await CS.SM.getActiveSolution();
                    let component = await activeSolution.getComponentByName(componentName);
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                    }
                    // EDGE-154465 end
                }
            }
        }
        //});
    }
    //Venkat 
    /*UCEPlugin.validateconfigquantity = function(solution) {
        for (let i = 0; i < solution.components.length; i++) {
            let comp = solution.components[i];
            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                for (let j = 0; j < comp.schema.configurations.length; j++) {
                    let errorflag = false;
                    let config = comp.schema.configurations[j];
                    if (config.attributes && config.attributes.length > 0) {
                        config.attributes.forEach((attr) => {
                            if (((attr.name === 'concurrencyLimit' || attr.name === 'NumberofPhoneNumbers' || attr.name === 'UCUserQuantity') && (attr.value === '0' || attr.value === '')) ||
                                ((attr.name === 'HuntGroupQuantity' || attr.name === 'AutoAttendantQuantity' || attr.name === 'MainBusinessNumberQuantity' || attr.name === 'HostedUCQuantity') && attr.value === '')) {
                                errorflag = true;
                            }
                        });
                    }
                    if (errorflag) {
                        CS.SM.displayMessage('One or more Quantity attributes in the configuration has invalid values/has not met the required minimum quantity', 'error');
                        CS.SM.updateConfigurationStatus(NEXTGENUC_COMPONENTS.UC, config.guid, true, 'One or more Quantity attributes in the configuration has invalid values/has not met the required minimum quantity');
                        return false;
                    }
                }
            }
            return true;
        }
    }*/ ///commented by shubhi for Edge-120919
    UCEPlugin.validateDisconnectionDate = async function (componentName, guid, attributeValue) {
        let solution = await CS.SM.getActiveSolution();
        let today = new Date();
        let attDate = new Date(attributeValue);
        today.setHours(0, 0, 0, 0);
        attDate.setHours(0, 0, 0, 0);
        let component = await solution.getComponentByName(componentName); //PD
        let config = await component.getConfiguration(guid);//PD 
        if (attDate <= today) {
            CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
            // EDGE-154465 start
            //CS.SM.updateConfigurationStatus(componentName, guid, false, 'Disconnection date should be greater than today!');PD
            config.status = false;
            config.statusMessage = 'Disconnection date should be greater than today!';
            // EDGE-154465 end
        } else {
            // EDGE-154465 start
            //CS.SM.updateConfigurationStatus(componentName, guid, true, ''); 
            config.status = true;
            config.statusMessage = '';
            // EDGE-154465 end
        }
    }
    UCEPlugin.setOEtabsforUC = function (solution) {
        if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && 
            if (solution.components && Object.values(solution.components).length > 0) {
                //solution.components.forEach((comp) => {// EDGE-154465
                Object.values(solution.components).forEach((comp) => {// EDGE-154465
                    if ((comp.name === NEXTGENUC_COMPONENTS.UC || comp.name === NEXTGENUC_COMPONENTS.UcComponent) && Utils.isOrderEnrichmentAllowed()) {
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                            //comp.schema.configurations.forEach((config) => {// EDGE-154465
                            Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                                CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Customer requested Dates', 'NumberManagementv1']);
                            });
                        }
                    }
                });
            }
        }
    }
    ///////////////////////added by Rohit
    UCEPlugin.afterNavigate = function (currentComponent, previousComponent) {
        console.log('Inside afterNavigate' + currentComponent + previousComponent);
        subscribeToExpandButtonEvents(currentComponent.name);
        //Addde  for 138001
        setTimeout(function () {
            Utils.updateImportConfigButtonVisibility();
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPI');
            pricingUtils.updateGenerateNetPriceButtonVisibility('getPriceScheduleAPIAccessory');
        }, 50);
        return Promise.resolve(true);
    }
    //Edge-120921 Added by shubhi dynamic config name population end
    //EDGE-144971 Added by Aditya for Consumption based Cancel--->Start 
    UCEPlugin.RewokeConfigurationOnCancel = async function () {
        console.log('RewokeConfigurationOnCancel');
        //CS.SM.getActiveSolution().then((solution) => {PD
        let solution = await CS.SM.getActiveSolution();
        if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {//PD removed solution.type && 
            if (solution.components && Object.values(solution.components).length > 0) {
                //solution.schema.configurations.forEach((config) => {
                Object.values(solution.schema.configurations).forEach((config) => {
                    if (config.attributes && Object.values(config.attributes).length > 0) {
                        // EDGE-154465 start
                        /*var changeTypeAtrtribute = config.attributes.filter(obj => {
                            return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
                        });*/
                        // EDGE-154465 end
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
        //});
    }
    updateChangeTypeAttributeNGUC = async function (solution) { // EDGE-154465
        console.log('updateChangeTypeAttributeNGUC');
        if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && 
            if (solution.components && Object.values(solution.components).length > 0) {
                //solution.components.forEach((comp) => { // EDGE-154465					
                for (let comp of Object.values(solution.components)) {
                    var updateMap = {};
                    console.log('COmponent name ==', comp.name);
                    var doUpdate = false;
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 && comp.replacedConfigId) {
                        //comp.schema.configurations.forEach((config) => {// EDGE-154465						
                        for (let config of Object.values(comp.schema.configurations)) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
                                //config.attributes.forEach((attribute) => {// EDGE-154465
                                Object.values(config.attributes).forEach((attribute) => {// EDGE-154465
                                    console.log('Attribute name ==', attribute.name);
                                    if (attribute.name === 'ChangeType') {
                                        doUpdate = true;
                                        var changeTypeValue = attribute.value;
                                        // EDGE-154465 start
                                        /*if (!updateMap[config.guid])
                                            updateMap[config.guid] = [];*/
                                        console.log('window.BasketChange: ', window.BasketChange);
                                        if (!window.BasketChange && window.BasketChange !== '' && changeTypeValue !== 'New'
                                            && window.BasketChange !== 'undefined') {
                                            console.log('Non MACD basket');
                                            if (!changeTypeValue) {
                                                changeTypeValue = 'New';
                                            }
                                            updateMap[config.guid] = [];
                                            updateMap[config.guid].push({//PD
                                                name: attribute.name,
                                                value: changeTypeValue,
                                                displayValue: changeTypeValue,
                                                showInUi: false,
                                                readOnly: true
                                            });
                                        } else {
                                            console.log('MACD basket ', config.id, '   ', changeTypeValue);
                                            var readonly = false;
                                            if (config.id && changeTypeValue === 'Cancel') {
                                                readonly = true;
                                                updateMap[config.guid] = [];
                                                updateMap[config.guid].push({//PD
                                                    name: attribute.name,
                                                    showInUi: true,
                                                    readOnly: false
                                                });
                                                console.log('map now ', updateMap);
                                            }
                                        }
                                        // EDGE-154465 end
                                    }
                                });
                            }
                        }
                    }
                    // EDGE-154465 start
                    /*if (doUpdate) {PD
                        console.log('updateChangeTypeAttribute', updateMap);
                        CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                    }*/
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                    }
                    // EDGE-154465 end
                }
            }
        }
        return Promise.resolve(true);
    }
    //UCEPlugin.afterOETabLoaded = async function(configurationGuid, OETabName) {
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
        let solution = await CS.SM.getActiveSolution();
        if (NEXTGENUC_COMPONENTS.solution == solution.name) {
            console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            await refreshNumberManagmentOE(e.detail.configurationGuid, e.detail.orderEnrichment.schema); //AB: OE attachment loading helper: refreshing NumberManagement OE data for display - Spring'20 Upgrade
            await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
        }
        return Promise.resolve(true);
    });
}
// EDGE-154465 end
/************************************************************************************
 * Author	: Tihomir Baljak
 * Method Name : validateCancelSolution
 * Invoked When: in as saveSolutionNgUC function (before save)
 * Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all pc change type is set to cancel
 * Parameters : solution
 ***********************************************************************************/
validateCancelSolution = function (solution) {// EDGE-154465 removed namespace
    let changeTypeAttribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(a => {
        return a.name === 'ChangeType' && a.value === 'Cancel'
    });
    if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
        return true;
    }
    //for (let i = 0; i < solution.components.length; i++) {// EDGE-154465
    for (const comp of Object.values(solution.components)) {
        //let comp = solution.components[i];
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
            //for (let j = 0; j < comp.schema.configurations.length; j++) {// EDGE-154465
            //for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
            for (const config of Object.values(comp.schema.configurations)) {
                //let config = comp.schema.configurations[j];// EDGE-154465
                //let config = Object.values(comp.schema.configurations)[j];
                if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
                    // EDGE-154465 start
                    /*changeTypeAttribute = config.attributes.filter(a => {
                        return a.name === 'ChangeType' && a.value !== 'Cancel' && a.value !== 'PaidOut' && a.value !== 'Inactive' && a.value !== 'Paid Out'
                    });*/
                    // EDGE-154465 end
                    changeTypeAttribute = Object.values(config.attributes).filter(a => {
                        return a.name === 'ChangeType' && a.value !== 'Cancel' && a.value !== 'PaidOut' && a.value !== 'Inactive' && a.value !== 'Paid Out'
                    });
                    // EDGE-154465 start
                    /*let ct = config.attributes.filter(a => {
                        return a.name === 'ContractType' && (a.displayValue === 'Hardware Repayment' || a.displayValue === 'Rental')
                    });*/
                    // EDGE-154465 end
                    let ct = Object.values(config.attributes).filter(a => {// EDGE-154465
                        return a.name === 'ContractType' && (a.displayValue === 'Hardware Repayment' || a.displayValue === 'Rental')
                    });
                    if (changeTypeAttribute && changeTypeAttribute.length > 0 && ct && ct.length > 0) {
                        CS.SM.displayMessage('When canceling whole solution all subscriptions and hardware repayment must be canceled too!', 'error');
                        return false;
                    }
                }
            }
        }
    }
    return true;
}
async function saveSolutionNgUC() {
    if (executeSaveNgUC) {
        executeSaveNgUC = false;
        //var solution;
        //await CS.SM.getActiveSolution().then((product) => {// EDGE-154465
        let currentBasket = await CS.SM.getActiveBasket();
        let solution = await CS.SM.getActiveSolution();
        //solution = product;
        //});// EDGE-154465
        // await UCEPlugin.updateOeStatus(); //Commented by Venkat as isNumberenriched will be set to true during Number Reservation
        if (!validateCancelSolution(solution)) {
            return Promise.resolve(false);
        }
        //await updateEDMListToDecomposeattribute_TC(solution); //Hitesh added to call to update the EDMListToDecompose attribute
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', false);
        }
        await updateSolutionName_NGUC(); // Added as part of EDGE-149887
        if (basketStage === 'Contract Accepted') {
            solution.lock('Commercial', true);
        }
        saveNgUC = true;
        //await CS.SM.saveSolution();// EDGE-154465
    }
    return Promise.resolve(true);
}
/****************************************************************************
 * Author	   : Venkata Ramanan G
 * Method Name : populateLookupStringValues
 * Invoked When: Value for Model is Updated
 * Description : 1. Updates the Display Value of Model in the attribute ModelString
 * Parameters  : 1. String : Component name
 *               2. String : configuration guid of the component on which update has been made
 *               3. String : Display value of the attribute Model.
 ***************************************************************************/
async function populateLookupStringValues(compname, guid, attr, value) {
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();
    if (product.name.includes(NEXTGENUC_COMPONENTS.solution)) {
        //if (product.components && product.components.length > 0) {// EDGE-154465
        if (product.components && Object.values(product.components).length > 0) {
            //var validcomp = product.components.filter(comp => {// EDGE-154465
            var validcomp = Object.values(product.components).filter(comp => {
                return comp.name === compname
            });
            if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {
                //var validconfig = validcomp[0].schema.configurations.filter(config => {
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(config => {// EDGE-154465
                    return config.guid === guid
                });
            }
            if (validconfig && validconfig[0].attributes) {
                //var updateMap = [];// EDGE-154465 start
                var updateMap = {};
                updateMap[validconfig[0].guid] = [];
                if (((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Model') || ((compname === NEXTGENUC_COMPONENTS.Accessory || compname === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'Accessorymodel')) {
                    updateMap[validconfig[0].guid].push({
                        name: "ModelName",
                        value: value,
                        readOnly: true,
                        required: false
                    });
                } else if (((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Device Type') || ((compname === NEXTGENUC_COMPONENTS.Accessory || compname === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'AccessoriesType')) {
                    updateMap[validconfig[0].guid].push({
                        name: "TypeName",
                        value: value,
                        readOnly: true,
                        required: false
                    });
                }
                //CS.SM.updateConfigurationAttribute(compname, updateMap, true);
                let component = await product.getComponentByName(compname);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
                }
                // EDGE-154465 end
            }
        }
    }
    //	});
}
   //updated for  updated for edge-175185
async function emptyLookupAttributes(componentName, guid, attr) {
    //CS.SM.getActiveSolution().then((product) => { // EDGE-154465
    let product = await CS.SM.getActiveSolution();
    if (product.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed product.type && 
        if (product.components && Object.values(product.components).length > 0) {
            // EDGE-154465 start
            /*var validcomp = product.components.filter(comp => {
                return comp.name === compname
            }); */
            // EDGE-154465 end
            var validcomp = (Object.values(product.components)[0]).filter(comp => { // EDGE-154465
                return comp.name === componentName
            });
            if (validcomp && Object.values(validcomp[0].schema.configurations).length > 0) {// EDGE-154465 removed index
                // EDGE-154465 start
                /*var validconfig = validcomp.schema.configurations.filter(config => {
                    return config.guid === guid
                });*/
                // EDGE-154465 end
                var validconfig = Object.values(validcomp[0].schema.configurations).filter(comp => {// EDGE-154465
                    return config.guid === guid
                });
            }
            if (validconfig && validconfig[0].attributes) {/// EDGE-154465 
                //var updateMap = [];
                // EDGE-154465 start
                var updateMap = {};
                updateMap[validconfig[0].guid] = [];
                if (((componentName === NEXTGENUC_COMPONENTS.Device || componentName === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Model') || ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'Accessorymodel')) {
                    updateMap[validconfig[0].guid].push({//PD 
                        name: "ModelName",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "ContractType",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "OneOffChargeGST",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "RedeemFund",
                        value: ''
                    });
                } else if ((compname === NEXTGENUC_COMPONENTS.Device || compname === NEXTGENUC_COMPONENTS.DevicesMTS) && attr === 'Device Type') {
                    updateMap[validconfig[0].guid].push({//PD removed index
                        name: "ModelName",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "TypeName",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "Model",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "ContractType",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "OneOffChargeGST",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "RedeemFund",
                        value: ''
                    });
                } else if ((componentName === NEXTGENUC_COMPONENTS.Accessory || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && attr === 'AccessoriesType') {
                    updateMap[validconfig[0].guid].push({//PD 
                        name: "ModelName",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "TypeName",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "Accessorymodel",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "ContractType",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "OneOffChargeGST",
                        value: ''
                    });
                    updateMap[validconfig[0].guid].push({
                        name: "RedeemFund",
                        value: ''
                    });
                }
                //CS.SM.updateConfigurationAttribute(compname, updateMap, true);
                let component = await solution.getComponentByName(componentName);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
                }
                // EDGE-154465 end
            }
        }
    }
    //});
}
/****************************************************************************
 * Author	   : Mahaboob Basha
 * Method Name : updateOrderPrimaryContactOnUC
 * Invoked When: Order Primary Contact on OE is updated
 * Description : 1. Updates the Order Primary Contact Id on its parent(UC)
 * Parameters  : 1. String : configuration guid of Order primary Contact tab
 *               2. String : new value of the Order Primary Contact attribute
 ***************************************************************************/
async function updateOrderPrimaryContactOnUC(guid, attrValue) {
    console.log('updateOrderPrimaryContactOnUC', guid);
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();
    console.log('updateOrderPrimaryContactOnUC', product);
    if (product.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed product.type && 
        if (product.components && Object.values(product.components).length > 0) { // EDGE-154465
            //product.components.forEach((comp) => { // EDGE-154465
            for (const comp of Object.values(product.components)) { // EDGE-154465
                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                    console.log('UC while updating OPE on OE', comp);
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        var ucConfigGUID;
                        //comp.schema.configurations.forEach((ucConfig) => {// EDGE-154465
                        Object.values(comp.schema.configurations).forEach((ucConfig) => {// EDGE-154465
                            if (ucConfig.orderEnrichmentList && Object.values(ucConfig.orderEnrichmentList).length > 0) {// EDGE-154465
                                var opeConfig = Object.values(ucConfig.orderEnrichmentList).filter(config => {// EDGE-154465
                                    return config.guid === guid
                                });
                                if (opeConfig && opeConfig[0]) {
                                    ucConfigGUID = ucConfig.guid;
                                }
                            }
                        });
                        console.log('ucConfigGUID', ucConfigGUID);
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
                            //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.UC, updateMap, true).then(component => console.log('updateOrderPrimaryContactOnUC Attribute Update', component));
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                let keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }
                            // EDGE-154465 end
                        }
                    }
                }
            }
        }
    }
    //}).then(PD
    //	() => Promise.resolve(true) PD
    //	);// EDGE-154465
    return Promise.resolve(true);
}
/******************************************************************************
 * Author	   : Mahaboob Basha
 * Method Name : updateNotBeforeCRDOnUC
 * Invoked When: Not Before CRD on OE is updated
 * Description : 1. Updates the Not Before CRD on its parent(UC)
 * Parameters  : 1. String : configuration guid of Customer reqeusted Dates tab
 *               2. String : new value of the Not Before CRD attribute
 *****************************************************************************/
async function updateNotBeforeCRDOnUC(guid, attrValue) {
    console.log('updateNotBeforeCRDOnUC', guid);
    //CS.SM.getActiveSolution().then((product) => { // EDGE-154465
    let product = await CS.SM.getActiveSolution();// EDGE-154465
    console.log('updateNotBeforeCRDOnUC', product);
    if (product.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465D removed product.type && 
        let updateMap = {};
        if (product.components && Object.values(product.components).length > 0) {// EDGE-154465
            //product.components.forEach((comp) => {// EDGE-154465
            for (const comp of Object.values(product.components)) {
                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                    console.log('UC while updating OPE on OE', comp);
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        var ucConfigGUID;
                        //comp.schema.configurations.forEach((ucConfig) => {// EDGE-154465
                        Object.values(comp.schema.configurations).forEach((ucConfig) => {
                            if (ucConfig.orderEnrichmentList && Object.values(ucConfig.orderEnrichmentList).length > 0) {// EDGE-154465
                                var opeConfig = Object.values(ucConfig.orderEnrichmentList).filter(config => {// EDGE-154465
                                    return config.guid === guid
                                });
                                if (opeConfig && opeConfig[0]) {
                                    ucConfigGUID = ucConfig.guid;
                                }
                            }
                        });
                        console.log('ucConfigGUID', ucConfigGUID);
                        if (ucConfigGUID) {
                            // EDGE-154465 start
                            updateMap[ucConfigGUID] = [];
                            updateMap[ucConfigGUID].push({
                                name: "Not Before CRD",
                                value: attrValue,
                                displayValue: attrValue,
                                readOnly: true,
                                required: false
                            });
                            //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.UC, updateMap, true).then(component => console.log('updateNotBeforeCRDOnUC Attribute Update', component));
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                let keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }
                            // EDGE-154465 start
                        }
                    }
                }
            }
        }
    }
    /*}).then(
        () => Promise.resolve(true)
    );*/ // EDGE-154465
    return Promise.resolve(true);
}
/******************************************************************************
 * Author	   : Mahaboob Basha
 * Method Name : updatePreferredCRDOnUC
 * Invoked When: Preferred CRD on OE is updated
 * Description : 1. Updates the Preferred CRD on its parent(UC)
 * Parameters  : 1. String : configuration guid of Customer reqeusted Dates tab
 *               2. String : new value of the Preferred CRD attribute
 *****************************************************************************/
async function updatePreferredCRDOnUC(guid, attrValue) {
    console.log('updateNotBeforeCRDOnUC', guid);
    //CS.SM.getActiveSolution().then((product) => { // EDGE-154465
    let product = await CS.SM.getActiveSolution();// EDGE-154465
    console.log('updateNotBeforeCRDOnUC', product);
    if (product.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465D removed product.type && 
        let updateMap = {};
        if (product.components && Object.values(product.components).length > 0) {// EDGE-154465
            //product.components.forEach((comp) => {// EDGE-154465
            for (const comp of Object.values(product.components)) {
                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                    console.log('UC while updating OPE on OE', comp);
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        var ucConfigGUID;
                        //comp.schema.configurations.forEach((ucConfig) => {// EDGE-154465
                        Object.values(comp.schema.configurations).forEach((ucConfig) => {
                            if (ucConfig.orderEnrichmentList && Object.values(ucConfig.orderEnrichmentList).length > 0) {// EDGE-154465
                                var opeConfig = Object.values(ucConfig.orderEnrichmentList).filter(config => {// EDGE-154465
                                    return config.guid === guid
                                });
                                if (opeConfig && opeConfig[0]) {
                                    ucConfigGUID = ucConfig.guid;
                                }
                            }
                        });
                        console.log('ucConfigGUID', ucConfigGUID);
                        if (ucConfigGUID) {
                            // EDGE-154465 start
                            updateMap[ucConfigGUID] = [];
                            updateMap[ucConfigGUID].push({
                                name: "Preferred CRD",
                                value: attrValue,
                                displayValue: attrValue,
                                readOnly: true,
                                required: false
                            });
                            //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.UC, updateMap, true).then(component => console.log('updateNotBeforeCRDOnUC Attribute Update', component));
                            if (updateMap && Object.keys(updateMap).length > 0) {
                                let keys = Object.keys(updateMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                }
                            }
                            // EDGE-154465 start
                        }
                    }
                }
            }
        }
    }
    /*}).then(
        () => Promise.resolve(true)
    );*/ // EDGE-154465
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
/**********************************************************************************************************************************************
 * Author	   : Vimal
 * Method Name : addDefaultOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. Adds one oe config for each comonent config if tehere is none (NumberManagementv1 is excluded)
 * Parameters  : none
 ********************************************************************************************************************************************/
async function addDefaultUCOEConfigs() {
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
                                    //	el.oeSchemaId = oeSchema.id; // EDGE-154465
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
    if (oeMap.length > 0) {
        map = [];
        map.push({});
        console.log('Adding default oe config map:', oeMap);
        for (var i = 0; i < oeMap.length; i++) {
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
    // EDGE-154465 end
    await initializeUCOEConfigs();
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Vimal
 * Method Name : initializeOEConfigs
 * Invoked When: after solution is loaded, after configuration is added
 * Description : 1. sets basket id to oe configs so it is available immediately after opening oe
 * Parameters  : none
 ********************************************************************************************************************************************/
async function initializeUCOEConfigs() {
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
}
/**********************************************************************************************************************************************
 * Author	   : Venkata Ramanan G
 * Method Name : populateRateCardinAttachment
 * Invoked When: after solution is loaded
 ********************************************************************************************************************************************/
async function populateRateCardinAttachment() {
    var c = 0;
    console.log(' Inside populateRateCardinAttachment!!!! ');
    // CS.SM.getActiveSolution();	
    if (basketStage !== 'Contract Accepted' || ratecardloaded)
        return;
    var configMap = [];
    //CS.SM.getActiveSolution().then((currentSolution) => {// // EDGE-154465
    let currentSolution = await CS.SM.getActiveSolution();
    //if(valid){
    //populatefixedvoiceratecard ();
    //valid = false;
    console.log('populateRateCardinAttachment ', currentSolution);
    if (currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type && 
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {// EDGE-154465
            //currentSolution.components.forEach((comp) => {// EDGE-154465
            for (const comp of Object.values(currentSolution.components)) {// EDGE-154465
                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                    if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        let inputMap = {};
                        inputMap['basketid'] = basketId;
                        inputMap['Offer_Id__c'] = 'DMCAT_Offer_000618';
                        inputMap['SolutionId'] = currentSolution.id;
                        //CS.SM.WebService.performRemoteAction('TierRateCardNCSHelper', inputMap).then(// EDGE-154465
                        let loadedSolution = await CS.SM.getActiveSolution();// EDGE-154465
                        let currentBasket = await CS.SM.getActiveBasket();// EDGE-154465
                        inputMap['GetBasket'] = basketId;
                        await currentBasket.performRemoteAction('TierRateCardNCSHelper', inputMap).then(
                            function (response) {
                                if (response && response['UCRateCard'] != undefined) {
                                    console.log('UCRateCard', response['UCRateCard']);
                                }
                            });
                    }
                }
            }
        }
        //}
    }
    //});
    return Promise.resolve(true);
}
async function updateplanlookup(guid, attributeValue) {
    var attribute;
    let updatelookup = {};
    let inputMap = {};
    let currentSolution = await CS.SM.getActiveSolution();
    let currentBasket = await CS.SM.getActiveBasket();
    //CS.SM.getActiveSolution().then((currentSolution) => {// EDGE-154465
    let solutcurrentSolutionion = await CS.SM.getActiveSolution();
    if (currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed currentSolution.type && 
        console.log('addDefaultOEConfigs - looking components', currentSolution);
        if (currentSolution.components && Object.values(currentSolution.components).length > 0) {// EDGE-154465
            //currentSolution.components.forEach((comp) => {// EDGE-154465
            for (const comp of Object.values(currentSolution.components)) {
                if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    for (const config of Object.values(comp.schema.configurations)) {
                        if (config.guid === guid) {
                            inputMap['priceItemId'] = attributeValue;
                            //CS.SM.WebService.performRemoteAction('SolutionGetAllowanceData', inputMap).then(// EDGE-154465
                            await currentBasket.performRemoteAction('SolutionGetAllowanceData', inputMap).then(
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
                                    //CS.SM.updateConfigurationAttribute(comp.name, updatelookup, true);
                                    if (updatelookup && Object.keys(updatelookup).length > 0) {
                                        let keys = Object.keys(updatelookup);
                                        for (let i = 0; i < keys.length; i++) {
                                            await comp.updateConfigurationAttribute(keys[i], updatelookup[keys[i]], true);
                                        }
                                    }
                                    // EDGE-154465 end
                                });
                        }
                        // console.log('updateConfigurationAttribute IDDallowance');
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
    //});
}
async function UCEPlugin_processMessagesFromIFrame() {
    if (!communitySiteIdUC) {
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
        //console.log('UCEPlugin_processMessagesFromIFrame:', data);
        message['data'] = close;
        await UCEPlugin_handleIframeMessage(message);
    }
}
//Aditya changes for EDGE-133963
async function UCEPlugin_handleIframeMessage(e) {
    //EDGE-154465 start
    let product = null;
    console.log('handleIframeMessage from pricing:', e);
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
        if (e.data['caller'] && (e.data['caller'] !== 'Devices' && e.data['caller'] != 'Business Calling' && e.data['caller'] != 'Accessories')) {
            return;
        } else if (e.data['command'] === 'pageLoad' + callerNameNGUC && e.data['data'] === solutionID) {
            await pricingUtils.postMessageToPricing(callerNameNGUC, solutionID, IsDiscountCheckNeeded, IsRedeemFundCheckNeeded)
        } else if (e.data['command'] === 'StockCheck' && e.data['data'] === solutionID && e.data['caller'] === 'Devices') { //EDGE-146972--Get the Device details for Stock Check before validate and Save as well
            await stockcheckUtils.postMessageToStockCheck(callerNameNGUC, solutionID)
        }
        else {
            await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller'], e.data['IsDiscountCheckAttr'], e.data['IsRedeemFundCheckAttr'], e.data['ApplicableGuid']); //added by shubhi for EDGE-121376
            if (e.data['command'] == 'ResponseReceived') {
                var showRateCart = true;
                if (window.BasketChange === 'Change Solution') {
                    pricingUtils.resetCustomAttributeVisibilityNGUC_Voice(showRateCart);
                }
            }
        }
    }
    //Edge-143527 end
    //	 //added by shubhi for EDGE-121376 end ////
    //EDGE-154465 end
    return Promise.resolve(true);
}
/*******************added by Rohit*********************/
function subscribeToExpandButtonEvents(currentComponentName) {
    //modify or remove this part to fit your component
    console.log('Inside afterNavigate-----' + currentComponentName);
    if (currentComponentName !== NEXTGENUC_COMPONENTS.UC && currentComponentName !== NEXTGENUC_COMPONENTS.DevicesMTS) {
        return;
    } else if (currentComponentName === NEXTGENUC_COMPONENTS.UC || currentComponentName === NEXTGENUC_COMPONENTS.DevicesMTS) {
        setTimeout(() => {
            //if user clicks on expand button in PC section header
            let buttons = document.getElementsByClassName('expand-btn');
            if (buttons) {
                for (let i = 0; i < buttons.length; i++) {
                    buttons[i].addEventListener("mouseup", (e) => {
                        setTimeout(() => {
                            customAttributeLinkTextReplacements();
                        }, 20);
                    });
                }
            }
            //if user clicks on Details link in PC section header
            let tabs = document.getElementsByClassName('tab-name');
            if (tabs) {
                for (let i = 0; i < tabs.length; i++) {
                    if (tabs[i].innerText !== 'Details') {
                        continue;
                    }
                    tabs[i].addEventListener("mouseup", (e) => {
                        setTimeout(() => {
                            customAttributeLinkTextReplacements();
                        }, 20);
                    });
                }
            }
            //if user clicks on PC name in PC section header
            let configs = document.getElementsByClassName('config-name');
            if (configs) {
                for (let i = 0; i < configs.length; i++) {
                    configs[i].addEventListener("mouseup", (e) => {
                        setTimeout(() => {
                            customAttributeLinkTextReplacements();
                        }, 20);
                    });
                }
            }
        }, 100);
    }
}
////////////////////////added by Rohit 
customAttributeLinkTextReplacements = async () => {
    console.log('Inside attribute link name update ***');
    Utils.updateCustomAttributeLinkText('Promotions and Discounts', 'View All');
    Utils.updateCustomAttributeLinkText('Price Schedule', 'View All');
    Utils.updateCustomAttributeLinkText('NGUCRateCardButton', 'View All');
    return Promise.resolve(true);
}
//Added for Edge 143957
async function checkConfigurationSubscriptionsForNGUCForEachComponent(comp, solutionComponent, hookname) {
    if (!window.BasketChange === 'Change Solution') {
        return;
    }


    console.log('checkConfigurationSubscriptionsForNGUC');
    var componentMap = {};
    var updateMap = {};
    var ComName = comp.name;
    console.log('Cmp Map --->', componentMap);
    var optionValues = [];
    if (comp.name == NEXTGENUC_COMPONENTS.UC)
        optionValues = [
            "Modify", "Cancel"
        ];
    else
        optionValues = [
            "Cancel"
        ];
    if (solutionComponent) {
        var cta = Object.values(Object.values(comp.schema.configurations)[0].attributes).filter(a => {// EDGE-154465
            return a.name === 'ChangeType'
        });
        componentMap[comp.name] = [];
        componentMap[comp.name].push({
            'id': Object.values(comp.schema.configurations)[0].replacedConfigId,// EDGE-154465
            'guid': Object.values(comp.schema.configurations)[0].guid,
            'ChangeTypeValue': cta[0].value
        });
    } else if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
        console.log('Cmp Map --->', componentMap);
        Object.values(comp.schema.configurations).forEach((config) => {
            if (config.replacedConfigId || config.id) {
                var cta = Object.values(config.attributes).filter(a => {
                    return a.name === 'ChangeType'
                });
                if (cta && cta.length > 0) {
                    console.log('Cmp Map --->', componentMap);
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
    console.log('Cmp Map --->', componentMap);
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
        console.log('GetSubscriptionForConfiguration: ', inputMap);
        var statuses;
        let loadedSolution = await CS.SM.getActiveSolution();// EDGE-154465
        let currentBasket = await CS.SM.getActiveBasket();// EDGE-154465
        //await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {// EDGE-154465
        await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {// EDGE-154465
            console.log('GetSubscriptionForConfiguration result:', values);
            if (values['GetSubscriptionForConfiguration'])
                statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
        });
        console.log('checkConfigurationSubscriptionsForNGUC statuses;', statuses);
        //notNewConfig = statuses;
        if (statuses) {
            //Object.keys(componentMap).forEach(comp => {
            for (const comp of Object.keys(componentMap)) {
                let componentLoaded = loadedSolution.getComponentByName(comp);
                //componentMap[comp].forEach(element => {
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

                            optionValues.push(statusValue);
                        }

                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            //value: {
                            options: optionValues,
                            showInUi: true,
                            value: statusValue,
                            displayValue: statusValue
                            //}
                        }
                        );
                    }
                    if (element.ChangeTypeValue === 'Pending') {
                        updateMap[element.guid] = [];
                        updateMap[element.guid].push({
                            name: 'ChangeType',
                            //value: {
                            readOnly: true
                            //}
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
                    console.log('changetypevalue---->', element.ChangeTypeValue, ComName)
                    if (ComName === NEXTGENUC_COMPONENTS.UC && element.ChangeTypeValue === 'Modify') // Edge 138108 MAC Consumption based Start----->
                    {
                        console.log('insidemodify---->', element.ChangeTypeValue, element.guid)
                        var updateConfigMap = {};
                        updateConfigMap[element.guid] = [];
                        updateConfigMap[element.guid].push({
                            name: "Mode",
                            //value: {
                            readOnly: true
                            //}
                        });
                        //CS.SM.updateConfigurationAttribute(ComName, updateConfigMap, true);
                        // EDGE-154465 start
                        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                            keys = Object.keys(updateConfigMap);
                            var complock = componentLoaded.commercialLock;


                            for (let i = 0; i < keys.length; i++) {
                                await componentLoaded.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                            }
                               if (complock) {
                                   componentLoaded.lock('Commercial', true);
                               }
                        }
                        // EDGE-154465 end
                    }
                    console.log('changetypevalue1---->', element.ChangeTypeValue)
                    if (ComName === NEXTGENUC_COMPONENTS.UC && (element.ChangeTypeValue === 'Active' || element.ChangeTypeValue === 'Cancel')) {
                        console.log('insideactive---->', element.ChangeTypeValue, element.guid)
                        var updateConfigMap = {};
                        updateConfigMap[element.guid] = [];
                        updateConfigMap[element.guid].push({
                            name: "Mode",
                            //value: {
                            readOnly: true
                            //}
                        });
                        updateConfigMap[element.guid].push({
                            name: "callingPlans",
                            //value: {
                            readOnly: true
                            //}
                        });
                        console.log('Inside active update map', updateConfigMap);
                        //CS.SM.updateConfigurationAttribute(ComName, updateConfigMap, true).then(component => console.log('checkConfigurationSubscriptionsForNGUC Attribute Update', component));
                        // EDGE-154465 start
                        if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                            keys = Object.keys(updateConfigMap);
                            var complock = componentLoaded.commercialLock;


                            for (let i = 0; i < keys.length; i++) {
                                await componentLoaded.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                            }
                               if (complock) {
                                   componentLoaded.lock('Commercial', true);
                               }
                        }
                        // EDGE-154465 end
                    }
                    // Edge 138108 MAC Consumption based End----->
                }//);
                console.log('checkConfigurationSubscriptionsForNGUC update map', updateMap);
                //CS.SM.updateConfigurationAttribute(comp, updateMap, true).then(component => console.log('checkConfigurationSubscriptionsForNGUC Attribute Update', component));
                // EDGE-154465 start
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    var complock = componentLoaded.commercialLock;


                    for (let i = 0; i < keys.length; i++) {
                        await componentLoaded.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                       if (complock) {
                           componentLoaded.lock('Commercial', true);
                       }
                }
                // EDGE-154465 end
            }//);
        }
    }
    // Edge 138108 MAC Consumption based Start----->
    //if(notNewConfig){
    CalculateRemainingTerm(hookname);
    //	}
    //UCEPlugin.UpdateVisibilityBasedonContracttype(hookname);
    // Edge 138108 MAC Consumption based End----->
    return Promise.resolve(true);
}
/////////////////////////////
//Edge-120919 NGUC consumption based model new	
async function calculateIsDiscountCheckNeeded(componentName) {
    let updateMap = {};
    var toBeUpdated = false;
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();
    console.log('Product == ', product);
    //if (product.components && product.components.length > 0) {// EDGE-154465
    if (Object.values(product.components).length > 0) {
        //product.components.forEach((comp) => {// EDGE-154465
        for (const comp of Object.values(product.components)) {
            if (comp.name === componentName) {
                //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {// EDGE-154465PD
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {
                        //var isEAPActiveAtt = config.attributes.filter(isEAPActiveAT => {// EDGE-154465
                        var isEAPActiveAtt = Object.values(config.attributes).filter(isEAPActiveAT => {
                            return isEAPActiveAT.name === 'isEAPActive'
                        });
                        //var forceScheduleButtonAtt = config.attributes.filter(forceScheduleButtonAt => {// EDGE-154465
                        var forceScheduleButtonAtt = Object.values(config.attributes).filter(forceScheduleButtonAt => {
                            return forceScheduleButtonAt.name === 'forceScheduleButton'
                        });
                        if (isEAPActiveAtt && isEAPActiveAtt[0] && (isEAPActiveAtt[0].value !== null || isEAPActiveAtt[0].value == null || isEAPActiveAtt[0].value == '') && (forceScheduleButtonAtt && forceScheduleButtonAtt[0] && forceScheduleButtonAtt[0].value === false)) {
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
                        } else if (isEAPActiveAtt && isEAPActiveAtt[0] && (isEAPActiveAtt[0].value == null || isEAPActiveAtt[0].value == '')) {
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
                    });
                }
                if (toBeUpdated === true) {
                    // EDGE-154465 start
                    //CS.SM.updateConfigurationAttribute(componentName, updateMap, false);PD
                    if (updateMap && Object.keys(updateMap).length > 0) {
                        keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                    }
                    // EDGE-154465 end
                }
            }
        }
    }
    //});
    return Promise.resolve(true);
}
//Edge-120921 NGUC consumption based model new 
//Spring 20 changes- method is moved to PD rule
/*async function updateEDMListToDecomposeattribute_TC(product) {
    if (product.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed product.type check
        var statusMsg;
        let updateMap = {};
        if (product.components && Object.values(product.components).length > 0) {// EDGE-154465
            //for (var i = 0; i < product.components.length; i++) {// EDGE-154465
            for (let i = 0; i < Object.values(product.components).length; i++) {// EDGE-154465
                var comp = Object.values(product.components)[i];// EDGE-154465
                if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        //for (var j = 0; j < comp.schema.configurations.length; j++) {// EDGE-154465
                        for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                            //var deviceConfig = comp.schema.configurations[j];// EDGE-154465
                            let deviceConfig = Object.values(comp.schema.configurations)[j];
                            if (deviceConfig.attributes && Object.values(deviceConfig.attributes).length > 0) {// EDGE-154465
                                var EDMListToDecompose = 'Unified Communication Device_Fulfilment,326_ASR,151_ASR';
                                // EDGE-154465 start
                                var TypeName = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'TypeName'
                                });
                                var ContractTypeString = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'ContractTypeString'
                                });
                                var EarlyTerminationCharge = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'EarlyTerminationCharge'
                                });
                                var ChangeType = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'ChangeType'
                                });
                                // EDGE-154465 end
                                if (TypeName && TypeName.length > 0 && ContractTypeString && ContractTypeString.length > 0) {
                                    if (TypeName[0].value && TypeName[0].value === "IADs" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_790';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IADs" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_791';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IADs" && ContractTypeString[0].value && ContractTypeString[0].value === "Rental") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_856';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IADs" && ContractTypeString[0].value && ContractTypeString[0].value === "Device Restock") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_916';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IP Handsets Device" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_788';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IP Handsets Device" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_789';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IP Handsets Device" && ContractTypeString[0].value && ContractTypeString[0].value === "Rental") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_857';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "IP Handsets Device" && ContractTypeString[0].value && ContractTypeString[0].value === "Device Restock") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_919';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Conference Phone" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_1160';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Conference Phone" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_1169';
                                    }
                                    //EDGE-146184 start
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Base and Handset" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_1177';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Base and Handset" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_1181';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Base Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_NRC_1179';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Base Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',622_RC_1183';
                                    }
                                    //EDGE-146184 end
                                }
                                if (EarlyTerminationCharge && EarlyTerminationCharge.length > 0 && ChangeType && ChangeType.length > 0) {
                                    if (EarlyTerminationCharge[0].value && EarlyTerminationCharge[0].value !== '' && ChangeType[0].value && ChangeType[0].value === "Cancel") {
                                        if (parseInt(EarlyTerminationCharge[0].value) > 0) {
                                            EDMListToDecompose = EDMListToDecompose + ',622_NRC_751';
                                        }
                                    }
                                }
                                console.log('EDMListToDecompose', EDMListToDecompose);
                                // EDGE-154465 start
                                updateMap[deviceConfig.guid] = [];
                                updateMap[deviceConfig.guid].push({
                                    name: 'EDMListToDecompose',
                                    value: EDMListToDecompose,
                                    displayValue: EDMListToDecompose
                                });
                                // EDGE-154465 end
                            }
                        }
                        // EDGE-154465 start
                        //await CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.DevicesMTS, updateMap, true);
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            keys = Object.keys(updateMap);
                            for (let i = 0; i < keys.length; i++) {
                                comp.lock('Commercial', false);
                                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                            }
                        }
                        // EDGE-154465 end
                    }
                }
                if (comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        updateMap = [];
                        //for (var j = 0; j < comp.schema.configurations.length; j++) {// EDGE-154465
                        for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {// EDGE-154465
                            //var deviceConfig = comp.schema.configurations[j];// EDGE-154465
                            let deviceConfig = Object.values(comp.schema.configurations)[j];// EDGE-154465
                            if (deviceConfig.attributes && Object.values(deviceConfig.attributes).length > 0) {// EDGE-154465
                                var EDMListToDecompose = 'Accessory_Fulfilment,326_ASR,151_ASR';
                                // EDGE-154465 start
                                var TypeName = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'TypeName'
                                });
                                var ContractTypeString = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'ContractTypeString'
                                });
                                var EarlyTerminationCharge = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'EarlyTerminationCharge'
                                });
                                var ChangeType = Object.values(deviceConfig.attributes).filter(a => {
                                    return a.name === 'ChangeType'
                                });
                                // EDGE-154465 end
                                if (TypeName && TypeName.length > 0 && ContractTypeString && ContractTypeString.length > 0) {
                                    if (TypeName[0].value && TypeName[0].value === "Camera" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_792';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Camera" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_793';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Power Supply" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_794';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Power Supply" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_795';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Headset UC" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1165';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Headset UC" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1172';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Headset CC" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1164';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Headset CC" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1173';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Speaker" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1166';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Speaker" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1174';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Repeaters" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1161';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Repeaters" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1175';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "KEM" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1162';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "KEM" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1170';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wall Mount" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1163';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wall Mount" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1171';
                                    }
                                    //EDGE-146184 start
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Handset Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1178';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Handset Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1182';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Handset Rugged Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Purchase") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_NRC_1180';
                                    }
                                    if (TypeName[0].value && TypeName[0].value === "Wireless DECT - Handset Rugged Only" && ContractTypeString[0].value && ContractTypeString[0].value === "Hardware Repayment") {
                                        EDMListToDecompose = EDMListToDecompose + ',623_RC_1184';
                                    }
                                    //EDGE-146184 end
                                }
                                if (EarlyTerminationCharge && EarlyTerminationCharge.length > 0 && ChangeType && ChangeType.length > 0) {
                                    if (EarlyTerminationCharge[0].value && EarlyTerminationCharge[0].value !== '' && ChangeType[0].value && ChangeType[0].value === "Cancel") {
                                        if (parseInt(EarlyTerminationCharge[0].value) > 0) {
                                            EDMListToDecompose = EDMListToDecompose + ',623_NRC_751';
                                        }
                                    }
                                }
                                console.log('EDMListToDecompose', EDMListToDecompose);
                                // EDGE-154465 start
                                updateMap[deviceConfig.guid] = [];
                                updateMap[deviceConfig.guid].push({
                                    name: 'EDMListToDecompose',
                                    value: EDMListToDecompose,
                                    displayValue: EDMListToDecompose
                                });
                                // EDGE-154465 end
                            }
                        }
                        // EDGE-154465 start
                        //await CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.AccessoryMTS, updateMap, true);PD
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            keys = Object.keys(updateMap);
                            for (let i = 0; i < keys.length; i++) {
                                comp.lock('Commercial', false);
                                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                            }
                        }
                        // EDGE-154465 end
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}*/
// Edge 138108 MAC Consumption based End----->
//Edge-120921 Added by shubhi dynamic config name population start	
async function updateConfigName_Device() {
    let updateMap = {};
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();// EDGE-154465
    if (product.components && Object.values(product.components).length > 0) {// EDGE-154465
        //product.components.forEach((comp) => {// EDGE-154465
        for (const comp of Object.values(product.components)) {
            if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                        var configName = 'Unified Communication Device ';
                        var type = Object.values(config.attributes).filter(att => {
                            return att.name === 'Device Type'
                        });
                        var model = Object.values(config.attributes).filter(att => {// EDGE-154465
                            return att.name === 'Model'
                        });
                        if (type && type[0] && type[0].value && model && model[0] && model[0].value) {
                            configName = type[0].displayValue + '-' + model[0].displayValue;
                        }
                        // EDGE-154465 start
                        updateMap[config.guid] = [];
                        updateMap[config.guid].push({
                            name: "ConfigName",
                            value: configName,
                            displayValue: configName
                        });
                        // EDGE-154465 end
                    });
                }
                // EDGE-154465 start
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                        component.lock('Commercial', false);
                    for (let i = 0; i < keys.length; i++) {
                        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                       component.lock('Commercial', true);
                }
                // EDGE-154465 end
            }
        }
    }
    //if (updateMap);
    //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.DevicesMTS, updateMap, false);
    //});
    return Promise.resolve(true);
}
//async function updateConfigName_Accesory(componentName) {PD param is not set from any method so commented.
async function updateConfigName_Accesory() {
    let updateMap = {};
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();// EDGE-154465
    //if (product.components && product.components.length > 0) {// EDGE-154465
    if (product.components && Object.values(product.components).length > 0) {// EDGE-154465
        //product.components.forEach((comp) => {// EDGE-154465
        for (const comp of Object.values(product.components)) {
            if (comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                        var configName = 'Accessory';
                        //var type = config.attributes.filter(att => {// EDGE-154465
                        var type = Object.values(config.attributes).filter(att => {// EDGE-154465
                            return att.name === 'AccessoriesType'
                        });
                        //var model = config.attributes.filter(att => {// EDGE-154465
                        var model = Object.values(config.attributes).filter(att => {// EDGE-154465
                            return att.name === 'Accessorymodel'
                        });
                        if (type && type[0] && type[0].value && model && model[0] && model[0].value) {
                            configName = type[0].displayValue + '-' + model[0].displayValue;
                        }
                        // EDGE-154465 start
                        updateMap[config.guid] = [];
                        updateMap[config.guid].push({
                            name: "ConfigName",
                            value: configName,
                            displayValue: configName
                        });
                        // EDGE-154465 end
                    });
                }
            }
        }
        //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.AccessoryMTS, updateMap, false);
        // EDGE-154465 start
        let component = product.getComponentByName(NEXTGENUC_COMPONENTS.AccessoryMTS);
        if (updateMap && Object.keys(updateMap).length > 0) {
            keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {


                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    //component.lock('Commercial', true); // added by shubhi for EDGE-173020 # Shubhi commented as it is locking basket before updating all attributes in commercial config 
            }
        }
        // EDGE-154465 end	
    }
    //});
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : updateOeTabsVisibility
 * Invoked When: after solution is loaded, after ChangeType is changed
 * Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
 * Parameters  : configuration guid or nothing
 ********************************************************************************************************************************************/
updateOeTabsVisibilityNGUC = async function (configGuid) {// updated Name to
    console.log('updateOeTabsVisibility');
    //CS.SM.getActiveSolution().then((solution) => {// EDGE-154465
    let solution = await CS.SM.getActiveSolution();// EDGE-154465
    if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && 
        if (solution.components && Object.values(solution.components).length > 0) {
            //solution.components.forEach((comp) => {// EDGE-154465
            Object.values(solution.components).forEach((comp) => {
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                        if (!configGuid || configGuid === config.guid) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
                                var changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {// EDGE-154465
                                    return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
                                });
                                if ((window.BasketChange === 'Change Solution' && changeTypeAtrtribute && changeTypeAtrtribute.length > 0) ||
                                    !Utils.isOrderEnrichmentAllowed()) {
                                    CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
                                    console.log('updateOeTabsVisibility - hiding:', comp.name, config.guid);
                                } else {
                                    if (comp.name === NEXTGENUC_COMPONENTS.UC || comp.name === NEXTGENUC_COMPONENTS.UcComponent) {
                                        CS.SM.setOEtabsToLoad(comp.name, config.guid, ['Customer requested Dates', 'NumberManagementv1']);
                                    } else {
                                        CS.SM.setOEtabsToLoad(comp.name, config.guid, undefined);
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
    //});
    return Promise.resolve(true);
}
   ////updated for  updated for edge-175185
updatecontracttypeattributes = async function (solution) {
    if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {/// EDGE-154465 removed solution.type && 
        if (solution.components && Object.values(solution.components).length > 0) {// EDGE-154465
            //solution.components.forEach((comp) => {// EDGE-154465
            for (const comp of Object.values(solution.components)) {
                if (comp.name === NEXTGENUC_COMPONENTS.Device || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.Accessory || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                    var updateMap = {};
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                        //comp.schema.configurations.forEach((config) => {// EDGE-154465
                        for (const config of Object.values(comp.schema.configurations)) {// EDGE-154465
                            //var contracttype = config.attributes.filter(attr => {// EDGE-154465
                            var contracttype = Object.values(config.attributes).filter(attr => {// EDGE-154465
                                return attr.name === 'ContractType'
                            });
                            if (contracttype && contracttype.length > 0) {
                                // EDGE-154465 start
                                if (contracttype[0].displayValue === 'Purchase') {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({
                                        name: "ContractTerm",
                                        showInUi: false,
                                        //value: "NA"
                                    });
                                    updateMap[config.guid].push({
                                        name: "RC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: true
                                    });
                                } else if (contracttype[0].displayValue === 'Hardware Repayment' && basketChangeType !== 'Change Solution') {
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
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: false
                                    });
                                } else if (contracttype[0].displayValue === 'Rental' && basketChangeType !== 'Change Solution') {
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
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
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
                                } else if ((contracttype[0].displayValue === 'Hardware Repayment' || contracttype[0].displayValue === 'Rental') && basketChangeType === 'Change Solution') {
                                    updateMap[config.guid] = [];
                                    updateMap[config.guid].push({//PD
                                        name: "ContractTerm",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OC",
                                        showInUi: false
                                    });
                                    updateMap[config.guid].push({
                                        name: "RedeemFund",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "TotalFundAvailable",
                                        showInUi: true
                                    });
                                    updateMap[config.guid].push({
                                        name: "OneOffChargeGST",
                                        showInUi: true
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
                        }
                        //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        if (updateMap && Object.keys(updateMap).length > 0) {
                          let keys = Object.keys(updateMap);
                            console.log('initializeOEConfigs updateMap:', updateMap);
                            var complock = comp.commercialLock;


                            for (let i = 0; i < keys.length; i++) {
                                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                            }
                          if (complock) {
                               comp.lock('Commercial', true);
                          }
                        }
                        // EDGE-154465 end
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
/*UCEPlugin.updateRCforUCFeatures = function(guid, attrname, value) {
        var ucConfig;
        /*CS.SM.getActiveSolution().then((currentSolution) => {   // Commented by Shubhi for error correction 
            if (currentSolution.type && currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
                if (currentSolution.components && currentSolution.components.length > 0) {
                    currentSolution.components.forEach((comp) => {
                        if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                            if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                                 ucConfig = comp.schema.configurations.filter(config => {
                                    return config.guid === guid
                                });
                            }
                        }
                    });
                }
            }
        });*/
/*	if (guid) {
        let inputMap = {};
        var updateMap = [];
        inputMap['Attribute_Name'] = attrname;
        inputMap['Offer_Id__c'] = 'DMCAT_Offer_000618';
        inputMap['quantity'] = value;
        CS.SM.WebService.performRemoteAction('NgUCFeaturesRCProvider', inputMap).then(
            function(response) {
                console.log('Inside rc update----->');
                console.log(response);
                if (response && response['TotalRecurringChargeforUser'] != undefined) {
                    updateMap[guid] = [{
                            name: 'TotalRecurringChargeforUser',
                            value: {
                                value: response.TotalRecurringChargeforUser.cspmb__Recurring_Charge__c
                            }
                        }, {
                            name: 'BussinessIDforUser',
                            value: {
                                value: response.TotalRecurringChargeforUser.Charge_Id__c
                            }
                        },
                        {
                            name: 'PriceitemIDforUser',
                            value: {
                                value: response.TotalRecurringChargeforUser.id
                            }
                        }
                    ];
                } else if (response && response['TotalRecurringChargeforHuntGroup'] != undefined) {
                    updateMap[guid] = [{
                        name: 'TotalRecurringChargeforHuntGroup',
                        value: {
                            value: response.TotalRecurringChargeforHuntGroup.cspmb__Recurring_Charge__c
                        }
                    }, {
                        name: 'BussinessIDforHuntGroup',
                        value: {
                            value: response.TotalRecurringChargeforHuntGroup.Charge_Id__c
                        }
                    }, {
                        name: 'PriceitemIDforHuntGroup',
                        value: {
                            value: response.TotalRecurringChargeforHuntGroup.id
                        }
                    }];
                } else if (response && response['TotalRecurringChargeforAutoAttendant'] != undefined) {
                    updateMap[guid] = [{
                        name: 'TotalRecurringChargeforAutoAttendant',
                        value: {
                            value: response.TotalRecurringChargeforAutoAttendant.cspmb__Recurring_Charge__c
                        }
                    }, {
                        name: 'BussinessIDforAutoAttendant',
                        value: {
                            value: response.TotalRecurringChargeforAutoAttendant.Charge_Id__c
                        }
                    }, {
                        name: 'PriceitemIDforAutoAttendant',
                        value: {
                            value: response.TotalRecurringChargeforAutoAttendant.id
                        }
                    }];
                } else if (response && response['TotalRecurringChargeforMainBusiness'] != undefined) {
                    updateMap[guid] = [{
                        name: 'TotalRecurringChargeforMainBusiness',
                        value: {
                            value: response.TotalRecurringChargeforMainBusiness.cspmb__Recurring_Charge__c
                        }
                    }, {
                        name: 'BussinessIDforMainBusiness',
                        value: {
                            value: response.TotalRecurringChargeforMainBusiness.Charge_Id__c
                        }
                    }, {
                        name: 'PriceitemIDforMainBusiness',
                        value: {
                            value: response.TotalRecurringChargeforMainBusiness.id
                        }
                    }];
                } else if (response && response['TotalRecurringChargeforHostedUC'] != undefined) {
                    updateMap[guid] = [{
                        name: 'TotalRecurringChargeforHostedUC',
                        value: {
                            value: response.TotalRecurringChargeforHostedUC.cspmb__Recurring_Charge__c
                        }
                    }, {
                        name: 'BussinessIDforHostedUC',
                        value: {
                            value: response.TotalRecurringChargeforHostedUC.Charge_Id__c
                        }
                    }, {
                        name: 'PriceitemIDforHostedUC',
                        value: {
                            value: response.TotalRecurringChargeforHostedUC.id
                        }
                    }];
                }
                CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.UC, updateMap, true);
            });
    }
    return Promise.resolve(true);
}*/
/************************************************************************************
 * Author	: Aman Soni
 * Method Name : onCustomAttributeEdit
 * Story : EDGE-133963
 * Parameters : solution
 updated by shubhi Edge-120919
 ***********************************************************************************/
/* Moved to UIPlugin
onCustomAttributeEdit = async function (solutionName, componentName, configurationGuid, attributeName) {
    console.log('Inside customAttributeEdit Guid--->' + configurationGuid + '@@@@@' + componentName);
    var url = '';
    var vfRedirect = '';
    var sol;
    var solutionId = '';
    var solutionName = '';
    let inputMap = {};
    var solution = window.currentSolutionName;
    var priceItemId = '';
    configId = configurationGuid;
    var BussinessId_Device = '';
    var CallingPlan = '';
    var offerid = '';
    var guid = '';
    var changeType = '';
    var Mode = ''; //Edge-120919
    //await CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    let product = await CS.SM.getActiveSolution();
    sol = product;
    solutionId = product.solutionId;// EDGE-154465
    solutionName = product.solutionName;// EDGE-154465
    if (sol.components && Object.values(sol.components).length > 0) {// EDGE-154465
        //sol.components.forEach((comp) => {// EDGE-154465
        Object.values(sol.components).forEach((comp) => {
            if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                        if (config.guid === configurationGuid) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
                                // EDGE-154465 start
                                //priceItemId = config.attributes.filter(a => {
                                //	return a.name === 'ContractType'
                                //});
                                //BussinessId_Device = config.attributes.filter(a => {
                                //	return a.name === 'BussinessId_Device'
                                //});PD
                                priceItemId = Object.values(config.attributes).filter(a => {
                                    return a.name === 'ContractType'
                                });
                                BussinessId_Device = Object.values(config.attributes).filter(a => {
                                    return a.name === 'BussinessId_Device'
                                });
                                // EDGE-154465 start
                            }
                        }
                    });
                }
            }
            if (comp.name === NEXTGENUC_COMPONENTS.UC) {
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                        if (config.guid === configurationGuid) {
                            if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
                                // EDGE-154465 start
                                //var CallingPlans = config.attributes.filter(a => {
                                //	return a.name === 'callingPlans'
                                //});PD
                                var CallingPlans = Object.values(config.attributes).filter(a => {
                                    return a.name === 'callingPlans'
                                });
                                if (CallingPlans && CallingPlans[0]) {
                                    CallingPlan = CallingPlans[0].displayValue;
                                }
                                //var Modes = config.attributes.filter(a => {
                                //	return a.name === 'Mode'
                                //});
                                // EDGE-154465 end
                                var Modes = Object.values(config.attributes).filter(a => {
                                    return a.name === 'Mode'
                                });
                                if (Modes && Modes[0]) {
                                    Mode = Modes[0].displayValue;
                                }
                                // EDGE-154465 start
                                //var offerids = config.attributes.filter(a => {
                                //	return a.name === 'OfferId'
                                //});
                                var offerids = Object.values(config.attributes).filter(a => {
                                    return a.name === 'OfferId'
                                });
                                // EDGE-154465 start
                                //if (offerids && offerids[0]) {
                                //	offerid = offerids[0].value;
                                }
                                //// EDGE-140157 start shubhi
                                guid = config.guid;
                                // EDGE-154465 start
                                //var ChangeTypes = config.attributes.filter(a => {
                                //	return a.name === 'ChangeType'
                                //});
                                var ChangeTypes = Object.values(config.attributes).filter(a => {
                                    return a.name === 'ChangeType'
                                });
                                // EDGE-154465 end
                                if (ChangeTypes && ChangeTypes[0]) {
                                    changeType = ChangeTypes[0].value;
                                }
                                //// EDGE-140157 end shubhi
                            }
                        }
                    });
                }
            }
        });
    }
    //});
    console.log('priceItemId-->' + priceItemId);
    console.log('@@offerid@@' + offerid + ' @@CallingPlan@@' + CallingPlan);
    console.log('@@guid@@' + guid + ' @@changeType@@' + changeType);
    var redirectURI = '/apex/';
    if (communitySiteIdUC) {
        url = window.location.href;
        if (url.includes('partners.enterprise.telstra.com.au'))
            redirectURI = '/s/sfdcpage/%2Fapex%2F';
        else
            redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
    }
    url = redirectURI;
    console.log('@@@@attributeName--->' + attributeName);
    //Added for Promotions and discounts
    if (attributeName === 'viewDiscounts') {
        //await CS.SM.saveSolution(true, true).then( solId => console.log(solId));
        pricingUtils.checkDiscountValidation(sol, 'IsDiscountCheckNeeded', NEXTGENUC_COMPONENTS.DevicesMTS);
        if (communitySiteIdUC) {
            url = '/partners/';
            url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId=' + solutionId + '&accessMode=ReadOnly' + '&customAttribute=' + attributeName + '&priceItemId=' + priceItemId + '&configId=' + configId + '&solutionName=Unified Communication Device';
            vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
            console.log('Url ---->', url);
        } else {
            url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId=' + solutionId + '&accessMode=ReadOnly' + '&customAttribute=' + attributeName + '&priceItemId=' + priceItemId + '&configId=' + configId + '&solutionName=Unified Communication Device';
            vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
            console.log('Url ---->', url);
        }
        console.log('vfRedirect--->' + vfRedirect);
    }
    //Added for Price Schedule
    if (attributeName === 'Price Schedule') {
        if (communitySiteIdUC) {
            url = '/partners/';
            url = url + 'c__PriceSchedulePage?configId=' + configId + '&BussinessId_Device=' + BussinessId_Device[0].value + '&solutionName=Unified Communication Device' + '&contractType=' + priceItemId[0].displayValue;
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
            console.log('Url ---->', url);
        } else {
            url = url + 'c__PriceSchedulePage?configId=' + configId + '&BussinessId_Device=' + BussinessId_Device[0].value + '&solutionName=Unified Communication Device' + '&contractType=' + priceItemId[0].displayValue;
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
            console.log('Url ---->', url);
        }
        console.log('vfRedirect--->' + vfRedirect);
    }
    // edge-
    //Added for Promotions and discounts
    if (attributeName === 'NGUCRateCardButton') {
        if (communitySiteIdUC) {
            url = '/partners/';
            //updated url for EDGE-140157
            url = url + 'c__RateDiscountCardNGUC?CallingPlan=' + CallingPlan + '&solutionId=' + solutionId + '&offerid=' + offerid + '&guid=' + guid + '&changeType=' + changeType + '&Mode=' + Mode; //Edge-120919
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="800px" width="820px"></iframe></div>';
            console.log('Url ---->', url);
        } else {
            //updated url for EDGE-140157
            url = url + 'c__RateDiscountCardNGUC?CallingPlan=' + CallingPlan + '&solutionId=' + solutionId + '&offerid=' + offerid + '&guid=' + guid + '&changeType=' + changeType + '&Mode=' + Mode; //Edge-120919
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
            console.log('Url ---->', url); 2162
        }
        console.log('vfRedirect--->' + vfRedirect);
    }
    return Promise.resolve(vfRedirect);
}*/
/****************************************************************************************************
 * Author	: Aditya Pareek
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
    //await CS.SM.getActiveSolution().then((solution) => {
    let solution = await CS.SM.getActiveSolution();
    console.log('Cmp Map --->', componentMap);
    if (solution.name == NEXTGENUC_COMPONENTS.solution) {
        //Added for Edge 143957
        // Edge 138108 MAC Consumption based Start----->
        if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
            solutionComponent = true;
            checkConfigurationSubscriptionsForNGUCForEachComponent(solution, solutionComponent, hookname);
        }
        if (solution.components && Object.values(solution.components).length > 0) {
            Object.values(solution.components).forEach((comp) => {
                solutionComponent = false;
                checkConfigurationSubscriptionsForNGUCForEachComponent(comp, solutionComponent, hookname);
            });
            // Edge 138108 MAC Consumption based End----->
        }
    }
    //});
    return Promise.resolve(true);
} //Aditya changes for EDGE-133963	
UpdateMainSolutionChangeTypeVisibility = async function (solution) {
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    let updateMap = {};
    updateMap[Object.values(solution.schema.configurations)[0].guid] = [];
    //updateMap[solution.schema.configurations[0].guid] .push({// EDGE-154465
    updateMap[Object.values(solution.schema.configurations)[0].guid].push({// EDGE-154465
        name: 'ChangeType',
        showInUi: true,
    });
    console.log('UpdateMainSolutionChangeTypeVisibility', updateMap);
    //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.solution, updateMap, true).catch((e) => Promise.resolve(true)); PD
    let comp = solution.getComponentByName(NEXTGENUC_COMPONENTS.solution);
    if (updateMap && Object.keys(updateMap).length > 0) {
        keys = Object.keys(updateMap);
        var complock = comp.commercialLock;

        for (let i = 0; i < keys.length; i++) {
            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);

        }
    }
}
/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : UpdateChangeTypeVisibility
 * Invoked When: after solution is loaded , after save
 * Description : When MAC basket set ChangeType attribute visible on UC Device & Accessory if Contract Type = Hardware Repayment else hide ChangeType attribute
 ********************************************************************************************************************************************/
////updated for  updated for edge-175185
UpdateChangeTypeVisibility = async function (solution) {
    if (window.BasketChange !== 'Change Solution') {
        return;
    }
    if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && 
        if (solution.components && Object.values(solution.components).length > 0) {// EDGE-154465
            //solution.components.forEach((comp) => {// EDGE-154465			
            for (let comp of Object.values(solution.components)) {// EDGE-154465
                let updateMap = {};
                if (comp.name === NEXTGENUC_COMPONENTS.UC || NEXTGENUC_COMPONENTS.UcComponent || comp.name === NEXTGENUC_COMPONENTS.Accessory || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS || comp.name === NEXTGENUC_COMPONENTS.Device || comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        //comp.schema.configurations.forEach((config) => {// EDGE-154465
                        Object.values(comp.schema.configurations).forEach((compconfig) => {// EDGE-154465
                            let visible = true;
                            if (comp.name !== NEXTGENUC_COMPONENTS.UC && comp.name !== NEXTGENUC_COMPONENTS.UcComponent) {
                                let ct = Object.values(compconfig.attributes).filter(a => {// EDGE-154465
                                    // Aditya: Changes for EDGE-137255 Cancel --------Start------>
                                    // Aditya: EDGE-144245
                                    return (a.name === 'ChangeType' && (a.value === 'New'))
                                });
                                if (ct && ct.length > 0) {
                                    visible = false;
                                }
                            } else {
                                visible = true;
                            }
                            /*	let changeT = config.attributes.filter(a => {
                                        // Aditya: Changes for EDGE-137255 Cancel --------Start------>
                                        // Aditya: EDGE-144245
                                        return (a.name === 'ChangeType' && (a.value === 'New'))
                                    });
                                    console.log('changeT---->',changeT)
                                if (changeT && changeT.length > 0) {
                                        visible = false;
                                    }*/
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
                        });
                    }
                }
                if (updateMap && Object.keys(updateMap).length > 0) {
                    keys = Object.keys(updateMap);
                    var complock = comp.commercialLock;


                    for (let i = 0; i < keys.length; i++) {
                        await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                    }
                       if (complock) {
                           comp.lock('Commercial', true);
                       }
                }
                // EDGE-154465 end
            }
        }
    }
    // EDGE-154465 start
    /*if (Object.keys(updateMap).length > 0) {
        Object.keys(updateMap).forEach(key => {
            CS.SM.updateConfigurationAttribute(key, updateMap[key], true);
        });
    } END EDGE- 154465 */
    return Promise.resolve(true);
}
/**********************************************************************************************************************************************
 * Author	   : Tihomir Baljak
 * Method Name : UpdateAttributesForMacdOnSolution
 * Invoked When: after solution is loaded , after save
 * Description : Updates attribute visibility and readOnly value depending on ChangeType for mac basket for UC Device & Accessory
 ********************************************************************************************************************************************/
UpdateAttributesForMacdOnSolution = async function (solution) {
    let changeTypeAtrtribute;
    if (solution.name === (NEXTGENUC_COMPONENTS.solution)) {// EDGE-154465 removed solution.type && 
        if (solution.components && Object.values(solution.components).length > 0) {// EDGE-154465
            // EDGE-154465 start
            /*changeTypeAtrtribute = solution.schema.configurations[0].attributes.filter(obj => {
                return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
            });PD*/
            changeTypeAtrtribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
                return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
            });
            // EDGE-154465 end
            if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
                //UCEPlugin.updateCancellationReason(solution.schema.name, solution.schema.configurations[0].guid, true);// EDGE-154465
                await updateCancellationReason(solution.schema.name, Object.values(solution.schema.configurations)[0].guid, true)// EDGE-154465
            } else {
                //UCEPlugin.updateCancellationReason(solution.schema.name, solution.schema.configurations[0].guid, false);// EDGE-154465
                await updateCancellationReason(solution.schema.name, Object.values(solution.schema.configurations)[0].guid, false);// EDGE-154465
            }
            //solution.components.forEach((comp) => {// EDGE-154465
            Object.values(solution.components).forEach((comp) => {
                if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                    //comp.schema.configurations.forEach((config) => {// EDGE-154465
                    Object.values(comp.schema.configurations).forEach((config) => {
                        // EDGE-154465 start
                        /*changeTypeAtrtribute = config.attributes.filter(obj => {
                            return obj.name === 'ChangeType'
                        });PD*/
                        changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
                            return obj.name === 'ChangeType'
                        });
                        // EDGE-154465 end
                        if (changeTypeAtrtribute && changeTypeAtrtribute.size > 0) {
                            //UCEPlugin.UpdateAttributeVisibilityForMacd(comp.name, config.guid, changeTypeAtrtribute[0].value);// EDGE-154465
                            UCEPlugin.UpdateAttributeVisibilityForMacd(comp.name, config.guid, Object.values(changeTypeAtrtribute)[0].value)// EDGE-154465
                        }
                    });
                }
            });
        }
    }
}
CalculateRemainingTerm = async function (hookname) {
    console.log('CalculateRemainingTerm');
    //CS.SM.getActiveSolution().then((product) => {// EDGE-154465
    var product = await CS.SM.getActiveSolution();// EDGE-154465
    if (product.components && Object.values(product.components).length > 0) {
        //product.components.forEach((comp) => {// EDGE-154465
        Object.values(product.components).forEach((comp) => {// EDGE-154465
            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
                //comp.schema.configurations.forEach((config) => {
                Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
                    // EDGE-154465 start
                    /*var ChangeTypeValue = config.attributes.filter(a => {
                        return a.name === 'ChangeType'
                    });
                    var ContractTermValue = config.attributes.filter(a => {
                        return a.name === 'ContractTerm'
                    });PD*/
                    var ChangeTypeValue = Object.values(config.attributes).filter(a => {
                        return a.name === 'ChangeType'
                    });
                    var ContractTermValue = Object.values(config.attributes).filter(a => {
                        return a.name === 'ContractTerm'
                    });
                    // EDGE-154465 end
                    console.log('insidemodify---->', ChangeTypeValue, comp.name, window.BasketChange)
                    if ((comp.name === NEXTGENUC_COMPONENTS.DevicesMTS || comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) && window.BasketChange === 'Change Solution' && ChangeTypeValue[0].value !== 'New') //Aditya for NGUC MACD EDGE-121389---Start--->
                    {
                        CommonUtills.remainingTermEnterpriseMobilityUpdate(config, ContractTermValue[0].displayValue, config.guid, comp.name, hookname);
                        //UCEPlugin.UpdateVisibilityBasedonContracttype(hookname);
                    }
                });
            }
        });
    }
    //});
    return Promise.resolve(true);
}
//EDGE-144971 Added by Aditya for Consumption based Cancel--->End
/* 	
Added as part of EDGE-149887 
This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
async function updateSolutionName_NGUC() {
    var listOfAttributes = ['Solution Name', 'GUID'];
    var attrValuesMap = {};
    let updateConfigMap = {};
    attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, NEXTGENUC_COMPONENTS.solution);
    console.log('attrValuesMap...' + attrValuesMap);
    if (attrValuesMap['Solution Name'] === DEFAULTSOLUTIONNAME_NGUC) {
        // EDGE-154465 start
        let configGuid;
        configGuid = attrValuesMap['GUID'];
        updateConfigMap[configGuid] = [];
        // EDGE-154465 start
        updateConfigMap[attrValuesMap['GUID']].push({
            name: 'Solution Name',
            value: DEFAULTOFFERNAME_NGUC,
            displayValue: DEFAULTOFFERNAME_NGUC
        });
    }
    //CS.SM.updateConfigurationAttribute(NEXTGENUC_COMPONENTS.solution, updateConfigMap, true);
    let solution = await CS.SM.getActiveSolution();
    let component = solution.getComponentByName(NEXTGENUC_COMPONENTS.solution);
    if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
        keys = Object.keys(updateConfigMap);
        var complock = component.commercialLock;


        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
        }
           if (complock) {
               component.lock('Commercial', true);
           }
    }
    return Promise.resolve(true);
    // EDGE-154465 end
};
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
    let currentSolution = await CS.SM.getActiveSolution();
    let component = currentSolution.getComponentByName(componentName);
    if (updateMap && Object.keys(updateMap).length > 0) {
        keys = Object.keys(updateMap);
        var complock = component.commercialLock;

        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
        }

    }
    // EDGE-154465
}
// Edge 138108 MAC Consumption based Start----->
UpdateVisibilityBasedonContracttype = async function (config, hookname, remainingTerm, componentName) {
    console.log('UpdateVisibilityBasedonContracttype');
    if (((hookname === 'afterSolutionLoaded' || hookname === 'afterSave' || hookname === 'afterConfigurationAddedToMacBasket') && config.id != null)) {
        var contractTypevalue = Object.values(config.attributes).filter(a => {
            return a.name === 'ContractType'
        });
        var RemainingTermValue = Object.values(config.attributes).filter(a => {
            return a.name === 'RemainingTerm'
        });
        console.log('insidemodify---->', contractTypevalue, RemainingTermValue, componentName, window.BasketChange)
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS)
            && window.BasketChange === 'Change Solution' && contractTypevalue[0].displayValue === 'Purchase'
            && config.replacedConfigId) //Aditya for NGUC MACD EDGE-121389---Start--->
        {
            console.log('insidemodify---->', contractTypevalue, RemainingTermValue)
            var updateConfigMap = {};
            // EDGE-154465 start
            //updateConfigMap[config.guid] = [];
            //updateConfigMap[config.guid].push({
            updateConfigMap[config.guid] = [];
            updateConfigMap[config.guid].push({//PD
                name: "ChangeType",
                value: "PaidOut",
                displayValue: "Paid Out",
                readOnly: true
            });
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false);PD
            let activeSolution = await CS.SM.getActiveSolution();
            let component = await activeSolution.getComponentByName(componentName);
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                }
            }
            // EDGE-154465 end
        }
        console.log('changetypevalue1---->', contractTypevalue)
        if ((componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) && window.BasketChange === 'Change Solution' && contractTypevalue[0].displayValue === 'Hardware Repayment' && remainingTerm <= 0 && config.replacedConfigId) //Aditya for NGUC MACD EDGE-121389---Start--->
        {
            console.log('insideactive---->', contractTypevalue, remainingTerm, config.guid)
            // EDGE-154465 start
            var updateConfigMap = {};
            updateConfigMap[config.guid] = [];
            updateConfigMap[config.guid].push({//PD
                name: "ChangeType",
                value: "PaidOut",
                displayValue: "Paid Out",
                readOnly: true
            });
            console.log('Inside active update map', updateConfigMap);
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, false).then(component => console.log('UpdateVisibilityBasedonContracttype Attribute Update', component));PD
            let activeSolution = await CS.SM.getActiveSolution();
            let component = await activeSolution.getComponentByName(componentName);
            if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                }
            }
            // EDGE-154465 end                
        }
    }
}
//AB: OE attachment loading helper start - Spring'20 Upgrade
refreshNumberManagmentOE = async function (configGuid, eventOeSchema) {
    //usage: refreshNumberManagmentOE(e.detail.configurationGuid, e.detail.orderEnrichment.schema);
    let schemaName = 'NumberManagement';
    var loadedData = [];
    var oeMap = [];
    const solution = await CS.SM.getActiveSolution();
    const config = solution.getConfiguration(configGuid);
    const component = solution.getComponent(config.other.dbDetails.componentId);
    //needed as eventOeSchema doesn't seem to be the same object
    const oeSchema = component.orderEnrichments[eventOeSchema.productOptionId];
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
        let currentBasket = await CS.SM.getActiveBasket()
        let result = await currentBasket.performRemoteAction('SolutionActionHelper', inputMap);
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