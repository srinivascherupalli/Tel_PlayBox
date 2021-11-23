/*----------------------------------------------------------
	1. Ankit Goswami 	18jan2020   	EDGE 127667		Created Generic java script 
	2. Aman Soni 		28Feb2020  		EDGE-135278		Added setSubBillingAccountNumberOnCLI method to get BillingAccountNumber on CLI from subscription as a part of 
	3. Ankit Goswami 	23Apr2020   	EDGE-140967    		Added UpdateValueForSolution method for attributeupdate
	4. Aman Soni		19-May-2020		EDGE-148455  		To capture Billing Account	
	5. Shubhi			19-May-2020		EDGE-148455  		Added setAccountID method to capture AccountId at Main component level
	6. Arinjay          30-May-2020     WDGE-155244             Spring 20 changes
	7. Gnana			18-Jul-2020							CS Spring'20 Upgrade
	8. Aditya			21-Jul-2020		Edge:142084		Enable New Solution in MAC Basket
	9. Gunjan     		19-09-2020 		JS Optimization
	10.Manish Berad 	03-09-2020 		EDGE-168275:
	11. Vishal Arbune 	03-09-2020 		EDGE-164350 
	12. Gunjan Aswani 	01-10-2020 		JS Refactoring
	13. Martand Atrey 	20/10/2020 		added method genericUpdateCompLevelBtnVisibility to not hide the "Check OneFund Balance" = EDGE-184554
	14. Shubhi       	30/10/2020  	added by shubhi for hard stop EDGE-185990
	15. Pallavi D   	04.11.2020   	QA1 version fix for overriding issue from other teams
	16. Shweta K  		01.11.2020 		EDGE-185652
	17. Shubhi	 		19/11/2020		EDGE-185011
	18.Akanksha			23/11/2020		EDGE-170544 added code to set session var for basket record type in getBasketData
	19. Payal       	01/12/2020  	EDGE-189788 added two generic Methods which will be called from TMDM,NextGenUC and EnterpriseManagedServices file
	20. Payal       	18/12/2020  	EDGE-178219 Added updateDiscountDate method for updating DisconnectionDate
	21. shubhi			7/01/2021		EDGE-170016
	22. Kamlesh     	5/1/2021 		EDGE-194599   Added validation message for actualSIOs
	23. Shubhi			9/02/2021		EDGE-201407 /EDGE-197580
	24. Shubhi			23/02/2021		EDGE-152457
    24. Payal           25/02/2021      DPG-4548 : added check for transition in validation message for Expected SIOs
	25. Shubhi V        10/03/2021      EDGE-204313 chown ux incoming bakset
    26. Jagadeswary     19/03/2021      EDGE-207998 added condition check for null values
    26. Jagadeswary     19/03/2021      EDGE-207998 added condition check for null values
	27. Shubhi V 		07/04/2021		EDGE-213068
    28. Aditya          13/04/2021      EDGE-EDGE-207351
    29. Vamsi Krishna V 21/APR/2021     EDGE-207354 It will update the Solution name to offerName if solution name contains billing account
    30. Shubhi V 	21/024/2021	 
    31. Vishal Arbune   10/05/2021      EDGE-216217 - POS Redemption
    32. Antun Bartonicek 07/06/2021     EDGE-198536 - Performance improvements (added: commercialUnlockComponent, commercialLockComponent)
    33. Krunal Taak     15/06/2021      DPG-5621 - Accessory HRO
    34. Shubhi          02/07/2021      EDGE-224336 Commented If logic
    35. Arinjay Singh   24/08/2021      DIGI-16041  Added Solution Name for replaceConfig
    36. Rajiv Singh     01/09/2021      DIGI-15041  replaced config.id with config.replacedConfigId
    37. Shubhi V        5/10/2021       DIGI-16898  carry forward discounts 
    38. Antun Bartonicek 03/10/2021		R34UPGRADE - R34 upgrade related changes
 	39. Vijay			07/11/2021		DIGI-456	added CloneOrderEnrichment Method
 ------------------------------------------------------------**/
 console.log("CommonUtills static resource");
 window.BasketChange = "";
 window.basketType="";
 window.OpportunityType="";
 var subscriptionNumber="";
 var pricingRuleGroupCode;
 window.allowCommercialChanges=true; // for locking solution JS review comments implemented
 
 var CommonUtillsVariables = {
     SIGNIFICANT_ATTRIBUTELIST: ["CountHS", "CountMS", "CountUser", "PlanTRC", "ProductStatus", "RecurringPrice", "TOC", "TotalContractValue", "TotalOneOffCharge", "TotalRecurringPrice", "TRC"]
 };
 var CommonUtills = {
      /**
      * helper function to create picklist option item as picklist now have value and label
      * R34UPGRADE
      */
       createOptionItem(value, label){
        label = label || value;
        var optionItem = {};
        optionItem.value = value;
        optionItem.label = label;
        return optionItem;
     },
     /************************************************************************************
      * Author	: Manish Berad
      * Method Name : getIsMbDeviceCareCancellationPossible
      * Invoked When: change type is updated on Device for offer Adaptive Mobility
      * Description : EDGE-168275: As a Sales Enterprise, Partner, R2R user when I am doing a Device Payout within Repayment period 	then system should force cancellation of associated Device Care if it is within 30 days Trial period
      * Parameters :null
      ***********************************************************************************/
     getIsDeviceCancellationPossible:async function(newValue){
             let loadedSolution = await CS.SM.getActiveSolution();
             let currentBasket =  await CS.SM.getActiveBasket(); 
         let cmpName = loadedSolution.getComponentByName("Device");
         let cmpConfig = await cmpName.getConfigurations();
             if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
             if (cmpConfig && Object.values(cmpConfig).length > 0) {
                 //Object.values(cmpConfig).forEach(async (config) => {//RF++
                 for (let config of Object.values(cmpConfig)) {
                     //RF++
                         let configguid=config.guid;
                         let confiiIId=config.id;
                         let repConfigId=config.replacedConfigId; 
                         if(repConfigId && configguid){
                             let relatedProductChType;
                             let freeCancellationPeriod;
                             if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
                                 Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
                                     let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
                                 relatedProductChType = relatedProductAttr.filter((obj) => {
                                     return obj.name === "ChangeType";
                                             });
                                 freeCancellationPeriod = relatedProductAttr.filter((obj) => {
                                     return obj.name === "Free Cancellation Period";
                                             });		
                                 });
                             }	
 
 
                             let payTypeLookup;
                             let manufacturer;
                             let devType;
                             let ChanngeTypeAtr;
                             if (config.attributes && Object.values(config.attributes).length > 0) {
                                 let attribs = Object.values(config.attributes);
                             payTypeLookup = attribs.filter((obj) => {
                                 return obj.name === "PaymentTypeString";
                             });
                             manufacturer = attribs.filter((obj) => {
                                 return obj.name === "MobileHandsetManufacturer";
                             });
                             devType = attribs.filter((obj) => {
                                 return obj.name === "Device Type";
                             });
                             ChanngeTypeAtr = attribs.filter((obj) => {
                                 return obj.name === "ChangeType";
                                         });
                             }
                             let inputMap = {};
                         inputMap["getChildServicesForDeviceCare"] = repConfigId;
                         currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
                                 let diviceCareServices = result["getChildServicesForDeviceCare"];
                                 let initialActivationDate=diviceCareServices.Initial_Activation_Date__c;
                                 let csordStatus=diviceCareServices.csord__Status__c;
                             if (initialActivationDate && csordStatus === "Connected") {
                                     let serviceStartDate =new Date(initialActivationDate);
                                     let freeCancelPeriod=freeCancellationPeriod[0].displayValue;
                                     serviceStartDate.setDate(serviceStartDate.getDate()+parseInt(freeCancelPeriod));
                                 let todaysDate = new Date().setHours(0, 0, 0, 0);
                                     if(todaysDate<serviceStartDate){
                                         isFreeCancellationPossible=true;
                                     }else{
                                         isFreeCancellationPossible=false;
                                     }
                                     if(isFreeCancellationPossible){
                                         let cnfg = cmpName.getConfiguration(configguid);
 
                                         if (confiiIId && ChanngeTypeAtr[0].displayValue === 'Cancel' 
                                             && relatedProductChType[0].displayValue!=='Cancel'){
                                                 cnfg.status = false;
                                         cnfg.statusMessage = "AppleCare+ must also be cancelled for this device under the Related Products tab";
                                         errorTobeDisplayed = "AppleCare+ must also be cancelled for this device under the Related Products tab";
                                             }else if(confiiIId && ChanngeTypeAtr[0].displayValue !== 'Cancel' 
                                                      && relatedProductChType[0].displayValue!=='Cancel'){
 
                                                          cnfg.status = false;
                                         cnfg.statusMessage = "AppleCare+ must also be cancelled for this device under the Related Products tab";
                                         errorTobeDisplayed = "AppleCare+ must also be cancelled for this device under the Related Products tab";
                                     }
 
 
                                     if (ChanngeTypeAtr[0].displayValue === "Active" || relatedProductChType[0].displayValue === "Cancel") {
                                         cnfg.status = true;
                                         cnfg.statusMessage = "";
                                         errorTobeDisplayed = "";
                                                      }
 
                                         if (confiiIId && ChanngeTypeAtr[0].displayValue === 'Cancel' && relatedProductChType[0].displayValue==='Cancel'){
                                                 var  updateMap = [];
                                                 updateMap[configguid] = [];
                                                 updateMap[configguid] = [{
                                                     name: "ChangeType",
                                                         value: "Cancel",
                                                             displayValue: "Cancel",
                                                                 readOnly: false
                                                                     }];
                                         if (updateMap && Object.keys(updateMap).length > 0) {
                                             await component.updateConfigurationAttribute(configguid, updateMap, true);
                                                 }
                                             } 
                                     }else{
                                         /*var  updateMap = [];
                                         updateMap[configguid] = [];
                                         updateMap[configguid] = [{
                                             name: 'ChangeType',
                                                 value: "PayOut",
                                                     displayValue: "Cancel",
                                                         readOnly: false
                                                             }];
                                         let keys = Object.keys(updateMap);
                                         for (let i = 0; i < keys.length; i++) {
                                             cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                                         }*/
                                     }
                                 }
                             });
                         }
                 }
                 }
             }
     },
 
     /************************************************************************************
      * Author	: Ankit Goswami
      * Method Name : hideSubmitSolutionFromOverviewTab
      * Invoked When: multiple occurrences
      * Description : On Overview tab hides part of a screen displayig Submit Solution
      * Parameters : N/A
      ***********************************************************************************/
     attrVisiblityControl: async function (componentName, ListofattributeMap, solution) {
         try {
             let updateMap = {};
             ListofattributeMap.forEach((value, attrName, map) => {
                 updateMap[attrName] = [];
                 Object.keys(value).forEach((valueKey) => {
                     value[valueKey].forEach((attrVisiblity) => {
                         updateMap[attrName].push({
                             name: valueKey,
                             readOnly: attrVisiblity.IsreadOnly,
                             showInUi: attrVisiblity.isVisible,
                             required: attrVisiblity.isRequired
                         });
                     });
                 });
             });
             let product = solution;
             if (product == null || product == undefined) product = await CS.SM.getActiveSolution();
             let component = await product.getComponentByName(componentName);
             let keys = Object.keys(updateMap);
             //let complock = component.commercialLock;
             component.lock("Commercial", false);
             //if(complock) component.lock('Commercial', false);
             for (let i = 0; i < keys.length; i++) {
                 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
             }
             //if(complock) component.lock('Commercial', true);
         } catch (error) {
             console.log("ERROR", error);
         }
         return Promise.resolve(true);
     },
     /************************************************************************************
      * Author	: Ankit Goswami
      * Method Name : UpdateValueForSolution
      * Invoked When: multiple occurrences
      * Description : Update the value of attribut EDGE-140967
      * Parameters :Component Name, Map of guid with attributes Name and value
      ***********************************************************************************/
     UpdateValueForSolution: async function (componentName, ListofattributeMap) {
         let updateMap = {};
         ListofattributeMap.forEach((ValueMap, guid, map) => {
             updateMap[guid] = [];
             ValueMap.forEach((Value, Key, map) => {
                 updateMap[guid].push({
                     name: Key,
                     value: Value
                 });
             });
         });
         let product = await CS.SM.getActiveSolution();
         let component = await product.getComponentByName(componentName);
         let keys = Object.keys(updateMap);
         for (let i = 0; i < keys.length; i++) {
             await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
         }
     }, // Updated for Edge 138108 MAC Consumption based
 
 
     /************************************************************************************
      * Author	: Ankit Goswami
      * Method Name : remainingTermEnterpriseMobilityUpdate
      * Invoked When: multiple occurrences
      * Description : Update the value of attribut EDGE-140967
      * Parameters :config,contractTerm,configId,componentName,hookname
      ***********************************************************************************/
     remainingTermEnterpriseMobilityUpdate: async function (config, contractTerm, configId, componentName, hookname) {
         //Spring 20
         let solution = await CS.SM.getActiveSolution();
         let currentBasket = await CS.SM.getActiveBasket();
         let ContractTypeValueStr = "";
         if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
             if (config.attributes && Object.values(config.attributes).length > 0) {
                 let ContractTypeValue = config.getAttribute("ContractType");
                 ContractTypeValueStr = ContractTypeValue.displayValue; //RF++
             }
         }
 
 
         if (ContractTypeValueStr !== "Purchase") {
             if (parseInt(contractTerm) != 0) {
                 let inputMap = {};
                 inputMap["getServiceForMAC"] = config.replacedConfigId;  //By Rajiv Singh (DIGI-15041)
                 let component = await solution.getComponentByName(componentName);
                 await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
                     let serviceStartDateString = result["getServiceForMAC"];
                     if (serviceStartDateString) {
                         let serviceStartDate = new Date(JSON.parse(serviceStartDateString));
                         let oneDay = 24 * 60 * 60 * 1000;
                         let today = new Date();
                         today.setHours(0, 0, 0, 0);
                         serviceStartDate.setHours(0, 0, 0, 0);
                         let remainingTerm = 0;
                         remainingTerm = Math.ceil((contractTerm * 30 - (today - serviceStartDate) / oneDay) / 30);
                         if (remainingTerm < 0 || isNaN(remainingTerm) || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm === "null") {
                             remainingTerm = 0;
                         }
                         let updateRemainingTermMap = {}; // Reset Plan bonus and remaining term.
                         updateRemainingTermMap[config.guid] = [];
                         if (remainingTerm <= 0 || isNaN(remainingTerm) || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm === "null" || remainingTerm === null) {
                             updateRemainingTermMap[config.guid].push({
                                 name: "RemainingTerm",
                                 value: 0,
                                 showInUi: true,
                                 readOnly: true,
                                 displayValue: 0
                             });
                             updateRemainingTermMap[config.guid].push({
                                 name: "ServiceStartDate",
                                 value: serviceStartDate,
                                 showInUi: false,
                                 readOnly: true,
                                 displayValue: serviceStartDate
                             });
                             updateRemainingTermMap[config.guid].push({
                                 name: "DeviceStatus",
                                 showInUi: true,
                                 value: "PaidOut",
                                 displayValue: "PaidOut"
                             });
                         } else {
                             updateRemainingTermMap[config.guid].push({
                                 name: "RemainingTerm",
                                 value: remainingTerm,
                                 showInUi: true,
                                 readOnly: true,
                                 displayValue: remainingTerm
                             });
                             updateRemainingTermMap[config.guid].push({
                                 name: "ServiceStartDate",
                                 value: serviceStartDate,
                                 showInUi: false,
                                 readOnly: true,
                                 displayValue: serviceStartDate
                             });
                         }
                         if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                             UpdateVisibilityBasedonContracttype(config, hookname, remainingTerm, componentName);
                         }
 
                         if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice)
                         {
                             NextGenMobHelper.UpdateChangeTypePaidOut(config.guid, '', 'Active',remainingTerm)
                         }
                         if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionDevice)
                         {
                             NextGenMobHelper.UpdateChangeTypePaidOutTransDevice(config.guid, '', 'Active',remainingTerm)
                         }
                 		 //------DPG-5621 Krunal
                         if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory)
                         {
                             NextGenMobHelper.UpdateChangeTypePaidOutAccessory(config.guid, '', 'Active',remainingTerm)
                         }
                         if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory)
                         {
                             NextGenMobHelper.UpdateChangeTypePaidOutTransAccessory(config.guid, '', 'Active',remainingTerm)
                         }
 						 //------DPG-5621 Krunal
                         let keys = Object.keys(updateRemainingTermMap);
                         for (let i = 0; i < keys.length; i++) {
                             component.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], false);
                         }
                     }
                 });
             } else {
                 var remainingTerm = 0;
                 var updateRemainingTermMap = {};
                 updateRemainingTermMap[config.guid].push({
                     name: "RemainingTerm",
                     value: 0,
                     displayValue: 0
                 });
                 let component = await solution.getComponentByName(componentName);
                 let keys = Object.keys(updateRemainingTermMap);
                 for (let i = 0; i < keys.length; i++) {
                     await component.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], false);
                 }
                 if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                     UpdateVisibilityBasedonContracttype(config, hookname, remainingTerm, componentName);
                 }
             }
         } else {
             var remainingTerm = 0;
             if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS) {
                 UpdateVisibilityBasedonContracttype(config, hookname, remainingTerm, componentName);
             }
         }
         return Promise.resolve(true);
     },
     setAttributesReadonlyValue: async function (componentName, ListofattributeMap) {
         let updateMap = {};
         ListofattributeMap.forEach((value, attrName, map) => {
             updateMap[attrName] = [];
             Object.keys(value).forEach((valueKey) => {
                 value[valueKey].forEach((attrVisiblity) => {
                     updateMap[attrName].push({
                         name: valueKey,
                         readOnly: attrVisiblity.IsreadOnly
                     });
                 });
             });
         });
         let solution = await CS.SM.getActiveSolution();
         let component = await solution.getComponentByName(componentName);
         let keys = Object.keys(updateMap);
         for (let i = 0; i < keys.length; i++) {
             await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
         }
     },
     setSubBillingAccountNumberOnCLI: async function (componentName, Attname, solutionComponent) {
         let componentMap = {};
         let updateMap = {};
         let solution = await CS.SM.getActiveSolution();
         let component = await solution.getComponentByName(componentName);
         let currentBasket = await CS.SM.getActiveBasket();
         let cmpConfig = await component.getConfigurations();
         if (solutionComponent) {
             if (cmpConfig && Object.values(cmpConfig).length > 0) {
                 let cta = config.getAttribute("ChangeType");
                 if (cta && cta.length > 0) {
                     if (!componentMap[solution.name]) componentMap[solution.name] = [];
 
 
                     if (cmpConfig[0].replacedConfigId) componentMap[solution.name].push({ id: Object.values(cmpConfig)[0].replacedConfigId, guid: Object.values(cmpConfig)[0].guid, ChangeTypeValue: cta[0].value });
                     else componentMap[solution.name].push({ id: Object.values(cmpConfig)[0].id, guid: Object.values(cmpConfig)[0].guid, ChangeTypeValue: cta[0].value });
                 }
             }
         } else {
             Object.values(solution.components).forEach((comp) => {
                 if (comp.name === componentName && cmpConfig && Object.values(cmpConfig).length > 0) {
                     Object.values(cmpConfig).forEach((config) => {
                         if (config.replacedConfigId || config.id) {
                             let cta = config.getAttribute("ChangeType");
                             if (cta && cta.length > 0) {
                                 if (!componentMap[comp.name]) componentMap[comp.name] = [];
 
 
                                 if (config.replacedConfigId) componentMap[comp.name].push({ id: config.replacedConfigId, guid: config.guid, ChangeTypeValue: cta[0].value });
                                 else componentMap[comp.name].push({ id: config.id, guid: config.guid, ChangeTypeValue: cta[0].value });
                             }
                         }
                     });
                 }
             });
         }
         if (Object.keys(componentMap).length > 0) {
             var parameter = "";
             Object.keys(componentMap).forEach((key) => {
                 if (parameter) {
                     parameter = parameter + ",";
                 }
                 parameter = parameter + componentMap[key].map((e) => e.id).join();
             });
             let inputMap = {};
             inputMap["GetSubscriptionForConfiguration"] = parameter;
 
 
             var statuses;
             await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
                 if (values["GetSubscriptionForConfiguration"]) statuses = JSON.parse(values["GetSubscriptionForConfiguration"]);
             });
 
 
             if (statuses) {
                 Object.keys(componentMap).forEach(async (comp) => {
                     componentMap[comp].forEach((element) => {
                         let billingAccount = "";
                         let billingAccountNumber = "";
                         let initialActivationDate = "";
                         let status = statuses.filter((v) => {
                             return v.csordtelcoa__Product_Configuration__c === element.id;
                         });
                         if (status && status.length > 0) {
                             billingAccount = status[0].Billing_Account__c;
                             billingAccountNumber = status[0].Billing_Account__r != null && status[0].Billing_Account__r != undefined ? status[0].Billing_Account__r.Billing_Account_Number__c : "";
                             initialActivationDate = status[0].initialActivationDate__c;
                         }
                         if (element.ChangeTypeValue !== "New" && Attname === "BillingAccountNumber" && billingAccountNumber != "" && billingAccountNumber != null) {
                             updateMap[element.guid] = [
                                 {
                                     name: Attname,
                                     value: billingAccountNumber,
                                     displayValue: billingAccountNumber
                                 }
                             ];
                         } else if (element.ChangeTypeValue !== "New" && Attname === "initialActivationDate" && initialActivationDate != "" && initialActivationDate != null) {
                             updateMap[element.guid] = [
                                 {
                                     name: Attname,
                                     value: initialActivationDate,
                                     displayValue: initialActivationDate
                                 }
                             ];
                         } else if (element.ChangeTypeValue !== "New" && Attname === "BillingAccountLookup" && billingAccount != "" && billingAccount != null) {
                             updateMap[element.guid] = [
                                 {
                                     name: Attname,
                                     value: billingAccount,
                                     displayValue: billingAccountNumber
                                 }
                             ];
                         }
                     });
                     let keys = Object.keys(updateMap);
                     for (let i = 0; i < keys.length; i++) {
                         await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                     }
                 });
             }
         }
         return Promise.resolve(true);
     },
     //Added by Aman Soni as a part of EDGE-135278 || End
     //Added by shubhi edge-148455 start ----------------
     /************************************************************************************
      * Author	: shubhi Vijayvergia
      * Method Name : setAccountID
      * Invoked When: onload after remote action
      * Description : to set account id
      * Parameters : solutionName, accountIdValue
      ***********************************************************************************/
     setAccountID: async function (solutionName, accIdValue) {
         let updateMap = {};
         let product = await CS.SM.getActiveSolution();
         let comp = await product.getComponentByName(solutionName);
         if (comp) {
             let cmpConfig = await comp.getConfigurations();
             if (cmpConfig && Object.values(cmpConfig)) {
                 if (product && product.name == solutionName && cmpConfig && accIdValue != null) {
                     Object.values(cmpConfig).forEach((cfg) => {
                         updateMap[cfg.guid] = [
                             {
                                 name: "AccountID",
                                 value: accIdValue
                             }
                         ];
                     });
                 }
             }
             let keys = Object.keys(updateMap);
             comp.lock("Commercial", false);
             //let commercialLock = comp.commercialLock;
             //if(commercialLock) comp.lock('Commercial', false);
             for (let i = 0; i < keys.length; i++) {
                 await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
             }
             //if(commercialLock) comp.lock('Commercial', true);
         }
         return Promise.resolve(true);
    },
    //Added by shubhi edge-148455 start ----------------
     /************************************************************************************
      * Author	: shubhi Vijayvergia
      * Method Name : setBasketRecordType
      * Invoked When: onload after remote action
      * Description : to set account id
      * Parameters : solutionName, accountIdValue
      * edge : EDGE-213068
      ***********************************************************************************/
      setBasketRecordType: async function (compName, basketRecortype,guid) {
        let updateMap = {};
        let product = await CS.SM.getActiveSolution();
        let comp = await product.getComponentByName(compName);
		if(guid && guid!=''){
			updateMap[guid] = [
				{
					name: "BasketRecordType",
					value: basketRecortype
				}
			];
		}
        else if (comp) {
            let cmpConfig = await comp.getConfigurations();
            if (cmpConfig && Object.values(cmpConfig)) {
				Object.values(cmpConfig).forEach((cfg) => {
					updateMap[cfg.guid] = [
						{
							name: "BasketRecordType",
							value: basketRecortype
						}
					];
				});
            }
		}
		if(updateMap){
			let keys = Object.keys(updateMap);
			comp.lock("Commercial", false);
			//let commercialLock = comp.commercialLock;
			//if(commercialLock) comp.lock('Commercial', false);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
		}
        return Promise.resolve(true);
    },
    //Added by shubhi edge-148455 start ----------------
     /************************************************************************************
      * Author	: Aditya Pareek
      * Method Name : setConfigAccountId
      * EDGE number : EDGE-EDGE-207351
      * Invoked When: onload after remote action
      * Description : to set account id
      * Parameters : solutionName, accountIdValue
      ***********************************************************************************/
      setConfigAccountId: async function (compName, accIdValue,guid) {
        let updateMap = {};
        let product = await CS.SM.getActiveSolution();
        let comp = await product.getComponentByName(compName);
		if(guid && guid!=''){
			//let cmpConfig = await comp.getConfiguration(guid);
			updateMap[guid] = [
				{
					name: "AccountID",
					value: accIdValue
				}
			];
		}
        else if (comp) {
            let cmpConfig = await comp.getConfigurations();
            if (cmpConfig && Object.values(cmpConfig)) {
				Object.values(cmpConfig).forEach((cfg) => {
					updateMap[cfg.guid] = [
						{
							name: "AccountID",
							value: accIdValue
						}
					];
				});
            }
		}
		let keys = Object.keys(updateMap);
		comp.lock("Commercial", false);
		//let commercialLock = comp.commercialLock;
		//if(commercialLock) comp.lock('Commercial', false);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
		}
        return Promise.resolve(true);
    },
    /***********************************************************************************************
	 * Author	   : Aditya Pareek
	 * EDGE number : EDGE-EDGE-207351
	 * Method Name : updateCompAttfromSolution(attTobeUpdated,value,guid,compname)
	 * Method Name : updateCompAttfromSolution(mainCompName,configGuid,component,relatedProduct)
	 * Invoked When: On after parent attribute update  to update attributes from parent to child
	 ***********************************************************************************************/
	updateCompAttfromSolution: async function (attTobeUpdated, attribute, readOnly, showInUi, guid, compname, oldValue) {
		var solution = await CS.SM.getActiveSolution();
		var comp = await solution.getComponentByName(compname);
		var config = await comp.getConfiguration(guid);
		var updateMapChild = {};
        
        if(guid && guid!=''){
			updateMapChild[guid] = [
				{
					name: attTobeUpdated,
					value: attribute.value,
					displayValue: attribute.displayValue,
					showInUi: showInUi,
					readOnly: readOnly
				}
			];
		}
        else{
			if(comp && attTobeUpdated && attribute){
				let cmpConfig = await comp.getConfigurations();
				if (cmpConfig && Object.values(cmpConfig)) {
					Object.values(cmpConfig).forEach((cfg) => {
						var att=cfg.getAttribute(attTobeUpdated);
						if((att.value === oldValue || !att.value || att.value==='') && !cfg.replacedConfigId && !cfg.disabled && !window.OpportunityType.includes('CHOWN')){ 
						
							updateMapChild[cfg.guid] = [
							{
								name: attTobeUpdated,
								value: attribute.value,
								displayValue: attribute.displayValue
							}];
						}else if(window.OpportunityType.includes('CHOWN')){ //EDGE-224839 added else block
							updateMapChild[cfg.guid] = [
							{
								name: attTobeUpdated,
								value: attribute.value,
								displayValue: attribute.displayValue
							}];
						}
					});
				}
			}
		}
		let keys = Object.keys(updateMapChild);
		for (let i = 0; i < keys.length; i++) {
			comp.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
		}
		return Promise.resolve(true);
	},
    /***********************************************************************************************
	 * Author	   : Aditya Pareek
	 * EDGE number : EDGE-EDGE-207351
	 * Method Name : updateSolutionfromOffer(attTobeUpdated,value,guid,compname)
	 * Method Name : updateSolutionfromOffer(mainCompName,configGuid,component,relatedProduct)
	 * Invoked When: On after parent attribute update  to update attributes from parent to child
	 ***********************************************************************************************/
	updateSolutionfromOffer: async function (guid) {
		var solution = await CS.SM.getActiveSolution();
		var config = await solution.getConfiguration(guid);
        let OfferName = config.getAttribute("Marketable Offer");
		var updateMapChild = {};
        
        if(guid && guid!=''){
			updateMapChild[guid] = [
				{
					name: "Solution Name",
					value: OfferName.displayValue,
					displayValue: OfferName.displayValue,
					showInUi: true,
					readOnly: false
				}
			];
		}
		let keys = Object.keys(updateMapChild);
		for (let i = 0; i < keys.length; i++) {
			solution.updateConfigurationAttribute(keys[i], updateMapChild[keys[i]], true);
		}
		return Promise.resolve(true);
	},
     getAttributeValues: async function (attributeNameList, SolutionName) {
         var returnAttrVal = {};
         let solution = await CS.SM.getActiveSolution();
         if (solution.name.includes(SolutionName)) {
             let comp = await solution.getComponentByName(SolutionName);
             if (comp) {
                 let cmpConfig = await comp.getConfigurations();
                 Object.values(cmpConfig).forEach((config) => {
                     if (config.attributes && Object.values(config.attributes).length > 0) {
                         attributeNameList.forEach((attributeInput) => {
                             let attrVal = config.getAttribute(attributeInput);
                             if (attrVal && attrVal.length > 0 && attrVal[0].value && attrVal[0].value !== undefined && attrVal[0].value !== "") {
                                 returnAttrVal[attributeInput] = attrVal[0].value;
                             }
                         });
                     }
                 });
             }
         }
         return returnAttrVal;
     },
     getAttributeDisplayValues: async function (attributeNameList, SolutionName) {
         var returnAttrVal = {};
         let solution = await CS.SM.getActiveSolution();
         if (solution.name.includes(SolutionName)) {
             let comp = await solution.getComponentByName(SolutionName);
             if (comp) {
                 let cmpConfig = await comp.getConfigurations();
                 Object.values(cmpConfig).forEach((config) => {
                     if (config.attributes && Object.values(config.attributes).length > 0) {
                         attributeNameList.forEach((attributeInput) => {
                             let attrVal = config.getAttribute(attributeInput);
                             if (attrVal && attrVal.length > 0 && attrVal[0].displayValue && attrVal[0].displayValue !== undefined && attrVal[0].displayValue !== "") {
                                 returnAttrVal[attributeInput] = attrVal[0].displayValue;
                             }
                         });
                     }
                 });
             }
         }
         return returnAttrVal;
     },
     /************************************************************************************
      * Author	: vishal Arbune
      * Method Name : getIsMbDeviceCareCancellationPossible
      * Invoked When: change type is updated on Mobile Device care for offer Adaptive Mobility
      * Description : EDGE-164350 As sales / partner / R2R user, while cancelling device care system should be able to check if its with in 30 days of  apple care activation or not based on that relevant message to be displayed
      * Parameters :null
      ***********************************************************************************/
 
 
       getChildServicesMobileDeviceCare:async function(){
             let loadedSolution = await CS.SM.getActiveSolution();
             let currentBasket =  await CS.SM.getActiveBasket(); 
             let cmpName=loadedSolution.getComponentByName('Device');
             if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
                 if(cmpName.schema && cmpName.schema.configurations && Object.values(cmpName.schema.configurations).length > 0) {
                     Object.values(cmpName.schema.configurations).forEach(async (config) => {
                         let configguid=config.guid;
                         let confiiIId=config.id;
                         let repConfigId=config.replacedConfigId; 
                         let relProdguid;
                         if(repConfigId && configguid){
                             let relatedProductChType;
                             let freeCancellationPeriod;
                             if (config.relatedProductList && Object.values(config.relatedProductList).length > 0){
                                 Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
                                     relProdguid=relatedConfig.guid;
                                     let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
                                     relatedProductChType= relatedProductAttr.filter(obj => {
                                         return obj.name === 'ChangeType'
                                             });
                                             freeCancellationPeriod= relatedProductAttr.filter(obj => {
                                         return obj.name === 'Free Cancellation Period'
                                             });	
                                 });
                             }
 
                             let payTypeLookup;
                             if (config.attributes && Object.values(config.attributes).length > 0) {
                                 let attribs = Object.values(config.attributes);
                                 payTypeLookup = attribs.filter(obj => {
                                     return obj.name === 'PaymentTypeString'
                                         });
                             }
 
                             let inputMap = {};
                                 inputMap['getChildServicesForDeviceCare'] =repConfigId;
                             currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                                 let diviceCareServices = result["getChildServicesForDeviceCare"];
                                 let initialActivationDate=diviceCareServices.Initial_Activation_Date__c;
                                 let csordStatus=diviceCareServices.csord__Status__c;
 
 
                                 if (initialActivationDate && csordStatus==='Connected'){
                                     let serviceStartDate =new Date(initialActivationDate);
                                     let freeCancelPeriod=freeCancellationPeriod[0].displayValue;
                                     serviceStartDate.setDate(serviceStartDate.getDate()+parseInt(freeCancelPeriod));
                                     let todaysDate=(new Date()).setHours(0,0,0,0);
                                     if(todaysDate<serviceStartDate){
                                         isFreeCancellationPossible=true;
                                     }else{
                                         isFreeCancellationPossible=false;
                                     }
                                     if(isFreeCancellationPossible){
                                         if(relProdguid && relatedProductChType[0].displayValue!=='Cancel'){
                                             var optionValues = [];
                                             optionValues = [CommonUtills.createOptionItem("Active"),CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
                                             var  updateMap = [];
                                             updateMap[relProdguid] = [];
                                             updateMap[relProdguid] = [{
                                                 name: 'ChangeType',
                                                     value: "Active",
                                                         displayValue: "Active",
                                                             readOnly: false,
                                                             showInUi:true,
                                                                 options: optionValues
                                                                     }];
 
 
                                             let keys = Object.keys(updateMap);
                                             for (let i = 0; i < keys.length; i++) {
                                                 cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                                             }
                                         }
 
 
                                                     //EDGE-168275
                                         if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Hardware Repayment') {
                                                 var optionValues = [];
                                                 optionValues = [
                                                    CommonUtills.createOptionItem("Active"),
                                                    CommonUtills.createOptionItem("Cancel"),
                                                    CommonUtills.createOptionItem("No Fault Return")
                                                 ]; //R34 Upgrade
 
 
                                                 var  NGEMdev = [];
                                                 NGEMdev[configguid] = [];
                                                 NGEMdev[configguid] = [{
                                                     name: 'ChangeType',
                                                         value: "Active",
                                                         displayValue: "Active",
                                                         readOnly: false,
                                                         options: optionValues
                                                 }];
                                                 let keys = Object.keys(NGEMdev);
                                                 for (let i = 0; i < keys.length; i++) {
                                                      cmpName.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
                                                 }
 
                                         }
 
                                     }else{
                                         var  updateMap = [];
                                         updateMap[relProdguid] = [];
                                         updateMap[relProdguid] = [{
                                             name: 'ChangeType',
                                                 value: "PaidOut",
                                                     displayValue: "PaidOut",
                                                     showInUi:true,
                                                         readOnly: true
                                                             }];
 
 
                                         let keys = Object.keys(updateMap);
                                         for (let i = 0; i < keys.length; i++) {
                                             cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                                         }
 
 
                                     }
                                 }
                             });
                         }
                     });
                 }
 
 
             }
         },
     // This performs remote action to update Basket Oppty Sync Flag
     updateBasketOppySynFlag: async function () {
         let currentBasket = await CS.SM.getActiveBasket();
         let inputMap = {};
         inputMap["updateBasketOppySynFlag"] = currentBasket.basketId;
         await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
     },
     // This performs remote action to enable transaction logging for DIGI-1634
    updateTransactionLogging: async function (event) {
        let currentBasket = await CS.SM.getActiveBasket();
        let currentSolution = await CS.SM.getActiveSolution();
        let basketIdstr = window.location.href ;
        let inputMap = {};
        inputMap["TransactionLogger"] ='';
        inputMap["correlationId"] =  window.OpportunityId+'-' +currentBasket.basketId;
        inputMap["event"] =  event;
        inputMap["OfferName"] =  currentSolution.name;
        inputMap["BasketUrl"] =  basketIdstr;
        inputMap["basketName"] = window.basketNum;
        inputMap["OrderType"] = window.OpportunityType;
        let allconfigurationList=currentSolution.getAllConfigurations();
        inputMap["configurationCount"] =  Object.values(allconfigurationList).length;
        await currentBasket.performRemoteAction("TransactionLogger", inputMap).then((result) => {});
    },
     // This performs remote action to update Basket Stage to Draft
     updateBasketStageToDraft: async function () {
         let currentBasket = await CS.SM.getActiveBasket();
         let inputMap = {};
         inputMap["updateBasketStageToDraft"] = currentBasket.basketId;
         await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
     },
     // This performs remote action to update Basket Stage to Commerical Configuration
     updateBasketDetails: async function () {
         let currentBasket = await CS.SM.getActiveBasket();
         let inputMap = {};
         if (currentBasket.basketStageValue != "Contract Accepted") {
             //'EDGE-164565.  Condition Added to avoid Sync flag update to false while saving OE data
             inputMap["updateBasketDetails"] = currentBasket.basketId;
             await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
         }
     },
     // Enable New Solution in MAC Basket
     setBasketChange: async function () {
         let product = await CS.SM.getActiveSolution();
         if (product) {
             let component = await product.getComponentByName(product.name);
             if (component) {
                 let cmpConfig = await component.getConfigurations();
                 if (product && Object.values(cmpConfig)[0].replacedConfigId && window.basketRecordType!=='Inflight Change') { //EDGE-170016
                     window.BasketChange = "Change Solution";
                 }
             }
         }
         return Promise.resolve(true);
     },
     /************************************************************************************
      * Author	: shubhi Vijayvergia
      * edge     :166327
      * Method Name : autoaddRelatedproduct,
      * Invoked When: on parent config uis added
      * Description :  on parent config uis added
      * Parameters :component, configuration,componentname,relatedComponentsnameList,skiphooks
      ***********************************************************************************/
     addRelatedProductonConfigurationAdd: async function (component, configuration, componentname, relatedComponentsname, skiphooks, max) {
         let solution = await CS.SM.getActiveSolution();
         let listOfRelatedProducts = configuration.getRelatedProducts();
         var rpcount = 0;
         Object.values(listOfRelatedProducts).forEach((rp) => {
             if (rp.name === relatedComponentsname) {
                 rpcount++;
             }
         });
         if (rpcount < max) {
             const relatedProduct = await component.createRelatedProduct(relatedComponentsname);
             await component.addRelatedProduct(configuration.guid, relatedProduct, skiphooks);
         }
         return Promise.resolve(true);
     },
     // Arinjay Start
     getBasketData: async (currentBasket) => {
         let inputMap = {};
         inputMap["GetBasket"] = currentBasket.basketId;
         await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
             var basket = JSON.parse(result["GetBasket"]);
             pricingRuleGroupCode = JSON.parse(result['Prgs']);
			 // EDGE-170544 akanksha adding starts //updated by shubhi for EDGE-170016
			 if(basket.RecordType !==undefined && basket.RecordType!=='')
             {
             	window.basketRecordType = basket.RecordType.Name; 
				window.amendType=basket.Amend_Type__c ;// EDGE-170016

				window.basketType=basket.BasketType__c;//EDGE-197580

             }
             if(basket.BasketType__c)
            	 window.basketType=basket.BasketType__c;//EDGE-197580
			 if(basket.Opportunity_Type__c)
                window.OpportunityType=basket.Opportunity_Type__c;
                window.OpportunityId = basket.cscfga__Opportunity__c;
			 // EDGE-170544 akanksha adding ends
            
            window.oeSetBasketData(currentBasket.basketId, basket.csordtelcoa__Basket_Stage__c, basket.csbb__Account__c, basket.Name, basket.csordtelcoa__Change_Type__c);
 
			let basketStageNotAllowingcommercilaChange=['Contract Accepted','Submitted','Enriched','Quote','Contract Initiated','Cancelled'] //EDGE-201407
			let basketTypeNotAllowingChange=['Outgoing']; //EDGE-152457 shubhi
			if (basketStageNotAllowingcommercilaChange.includes(basketStage) || basketTypeNotAllowingChange.includes(window.basketType)) {
				//solution.lock("Commercial", true);
				window.allowCommercialChanges=false;
			}
         });
         return Promise.resolve(true);
     },
 
 
     getSiteDetails: async (currentBasket) => {
         let inputMap = {};
         inputMap["GetSiteId"] = "";
         await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
             window.communitySiteId = result["GetSiteId"];
         });
         return Promise.resolve(true);
     },
     getAttribute: (config, attrName) => {
         let attrib;
         try {
             attrib = config.getAttribute(attrName);
         } catch (err) {
             console.log(err);
         }
         return attrib;
     },
     // Arinjay End
     genericUpdateSolutionName: async function (component, configuration, val, displayVal) {
         let updateConfigMap = {};
         updateConfigMap[configuration.guid] = [];
         updateConfigMap[configuration.guid].push({
             name: "Solution Name",
             value: val,
             displayValue: displayVal
         });
         if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
             await component.updateConfigurationAttribute(configuration.guid, updateConfigMap[configuration.guid], true);
         }
     },
     /*******************************************************************************************************
      * Author	  : Martand Atrey
      * Method Name : genericUpdateCompLevelBtnVisibility
      * Invoked When: in Solution Set Active of the Solution from EM
      * Description : 1. updates Component Level buttons visibility as required
      * Parameters  : 1. buttonLabel      -   Label of the button
      *               2. isVisible        -   Flag signifying whether the button should be visible or not
      *               3. isDefaultButton  -   Flag signifying Whether this is Default button or Custom button
      *               3. solutionName  	 -   Solution Name from which it is called
      ******************************************************************************************************/
     //EDGE-184554
     genericUpdateCompLevelBtnVisibility: async function (buttonLabel, isVisible, isDefaultButton, solutionName) {
         let solution = await CS.SM.getActiveSolution();
         let buttons = document.getElementsByClassName("cs-btn btn-transparent");
 
          if (buttons && solution.name === solutionName) {
              for (let i = 0; i < buttons.length; i++) {
                  let button = buttons[i];
                  if (button.innerText && button.innerText.toLowerCase() === buttonLabel.toLowerCase()) {
                      let child = button.getElementsByClassName("btn-icon icon-add");
                      if ((isDefaultButton && child && child.length > 0) || (!isDefaultButton && (!child || child.length === 0))) {
                          if (isVisible) {
                              button.style.display = "block";
                          } else {
                              button.style.display = "none";
                          }
                      }
                  }
              }
          }
          return Promise.resolve(true);
      },
      /*******************************************************************************************************
       * Author	  : Shubhi
       * Method Name : stopSaveonErrorinSolution
       * Invoked When: beforesave hook
       * Description : hard stop user form saving wrong configuration
       * Parameters  :
       * Jira		: EDGE-185990
       ******************************************************************************************************/
      stopSaveonErrorinSolution: async function () {
          let curbasket = await CS.SM.getActiveBasket();
          let inputMap = {};
          let allowHardStop=false;
          inputMap["allowHardStop"] = "";
          let solution = await CS.SM.getActiveSolution();
          await curbasket.performRemoteAction("SolutionActionHelper", inputMap).then((response) => {
              var result = response["AllowHardStop"];
              if(result==="true"){
                  allowHardStop=true;
                  if(solution && solution.error===true && allowHardStop===true){
                      allowHardStop=solution.error;
                      }
              }
          });
          return allowHardStop;
      },
      /*******************************************************************************************************
       * Author	  : Shubhi
       * Method Name : lockSolution
       * Invoked When: all hooks
       * Description : locking solution for basket stages that does not allow commercila changes
       * Parameters  :
       * Jira		: EDGE-185990
       ******************************************************************************************************/
        lockSolution: async function () {
		let solution = await CS.SM.getActiveSolution(); 
		if (!window.allowCommercialChanges) {
			solution.lock("Commercial", true);
		}
		
		
          return Promise.resolve(true);
      },
      /*******************************************************************************************************
       * Author	  : Shubhi
       * Method Name : unlockSolution
       * Invoked When: all hooks
       * Description : unlocking solution for basket stages that does not allow commercial changes to do programatic changes
       * Parameters  :
       * Jira		: EDGE-185990
       ******************************************************************************************************/
      unlockSolution: async function () {
		let solution = await CS.SM.getActiveSolution(); 
		//if (window.allowCommercialChanges) { //Commented if syntax by Shubhi for EDGE-224336
        solution.lock("Commercial", false);
		//}////Commented if syntax by Shubhi for EDGE-224336
		 return Promise.resolve(true);
	 },
         
      /*******************************************************************************************************
       * Author	  : Antun Bartonicek
       * Method Name : commercialUnlockComponent
       * Invoked When: all hooks
       * Description : unlocking component for basket stages that does not allow commercial changes to do programatic changes
       * Parameters  : component that needs to be unlocked
       * Jira		: EDGE-198536: Performance improvements
       ******************************************************************************************************/
       commercialUnlockComponent: async function (component) {
		if (!window.allowCommercialChanges) {
			component.lock("Commercial", false);
		}
		 return Promise.resolve(true);
	 },

      /*******************************************************************************************************
       * Author	  : Antun Bartonicek
       * Method Name : commercialLockComponent
       * Invoked When: all hooks
       * Description : locking component for basket stages that does not allow commercial changes to do programatic changes
       * Parameters  : component that needs to be unlocked
       * Jira		: EDGE-198536: Performance improvements
       ******************************************************************************************************/
       commercialLockComponent: async function (component) {
		if (!window.allowCommercialChanges) {
			component.lock("Commercial", true);
		}
		 return Promise.resolve(true);
	 },
         
      /*******************************************************************************************************
       * Author	  : Vishal Arbune
       * Method Name : markBasketAsInvalid
       * Invoked When: AfterSave
       * Description : Mark basket stage to Incomplete when Available OF balance is less that RedeemFund amount.
       * Parameters  :
       * Jira		: EDGE-216217
    ******************************************************************************************************/
	invalidateOnBasketRedemptions: async function () {
        let currentBasket = await CS.SM.getActiveBasket();
        let inputMap = {};
        if (currentBasket.basketStageValue != "Contract Accepted") {            
            inputMap["invalidateOnBasketRedemptions"] = currentBasket.basketId;
            await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
        }
    }, 
         
    markBasketAsInvalid: async function () {
        let currentBasket = await CS.SM.getActiveBasket();
        let inputMap = {};
        if (currentBasket.basketStageValue != "Contract Accepted") {            
            inputMap["markBasketAsInvalid"] = currentBasket.basketId;
            await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {});
        }
    }, 
	 	 /*******************************************************************************************************
	  * Author	  : Shweta Khandelwal 
	  * Method Name : genericSequenceNumberAddInConfigName
	  * Invoked When: afterAttributeUpdate and afterCOnfigurationClone for CMP and AM 
	  * Description : 1. updates number sequence for configuration Name, and name contains two attribute value
	  * Parameters  : 1. configuration      -   configuration for which need to add number
	  *               2. attr1        
	  *               3. attr2  
	  * EDGE-185652
	  ******************************************************************************************************/
	 genericSequenceNumberAddInConfigName: function (configuration, attr1, attr2) {
		let configName = configuration.configurationName;
		let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
        //let spaceIndex = configName.charAt(configName	.length-1);
        //let configName = oldConfig;
        let getOfferType = configuration.getAttribute(attr1);
        let getplanName = configuration.getAttribute(attr2);
        if (getOfferType.displayValue != "" && getplanName.displayValue != "") {

            configName = getOfferType.displayValue + "-" + getplanName.displayValue;
		}
         //added by shubhi for EDGE-185011 start----
         try{
             let cfs_id=configuration.getAttribute('CustomerFacingServiceId');
             let SubScenario=configuration.getAttribute('SubScenario');//Edge-185856 
             if(cfs_id.value && cfs_id.value!=='' && cfs_id.value!==null && SubScenario && SubScenario.value==='Reactivate')
                 configName+='_'+cfs_id.value;
         }catch(e){
             console.log('error in config name');
         }
         //added by shubhi for EDGE-185011 end----
         configName+= "_" + spaceIndex ;   
		return configName;
	 },

	 /**********************************************************************************************************************************************
	 * EDGE-189788
	 * Author   : Payal
	 * Invoked When: Save button on Rate and Expected SIO UI is clicked
	 * Description : 1. Update the json_sios attribute with expected sios value
	 ********************************************************************************************************************************************/
	updateAttributeExpectedSIO : async function(expectedSIO,guid,compName){
		let solution = await CS.SM.getActiveSolution();
		let comp = solution.getComponentByName(compName);
		let guidCompMap = {};
		if(expectedSIO){
			expectedSIO = expectedSIO.replace(/"/g,"'");
		}
		if (comp) {
			let config = comp.getConfiguration(guid);
			var jsonsios = config.getAttribute("json_sios");
			let attnameToattMap ={};
			if(jsonsios !== undefined){
				attnameToattMap[guid] = [];
				attnameToattMap[guid].push({
					name: jsonsios.name,
					displayValue : expectedSIO,
					value : expectedSIO
				});
				guidCompMap = attnameToattMap;
				if (guidCompMap && Object.keys(guidCompMap) && Object.keys(guidCompMap).length > 0) {
					comp.updateConfigurationAttribute(guid, guidCompMap[guid], true);
				}
			}
			return Promise.resolve(true);
		}
	},

	/**********************************************************************************************************************************************
	 * EDGE-189788
	 * Author   : Payal
	 * Invoked When: when validate and save button is clicked
	 * Description : 1. Check the json_sios attribute has expected sios value or not and based on that it will throw validation
	 *               2. And mark config invalid
     *               3. New validation message added for actualSIO
	 ********************************************************************************************************************************************/
	validateExpectedSIO : async function() {
        var hasExpectedSIO = false;
        var hasActualSIO = false;
		var doNotStopValidateSave = true;
		let solution = await CS.SM.getActiveSolution();
		if (solution.components && Object.values(solution.components).length > 0) {
			for(let comp of Object.values(solution.components)){
				let config = comp.getConfigurations();
				if (config && Object.values(config).length > 0) {
					for(let compconfig of Object.values(config)){

                       for(let attribute of Object.values(compconfig.attributes)){
                            hasExpectedSIO = false;
                            //EDGE-194599
                            hasActualSIO = false;
							if(attribute.name === "json_sios"){

						let att = compconfig.getAttribute("json_sios");
						let changeType = compconfig.getAttribute("ChangeType");
						var changeTypeVal = changeType.value;
                        if(att.value != ''){
                            att = (att.value).replace(/'/g,"\"");
						att = JSON.parse(att);
						for(let key in Object.values(att)) {
							if(att[key].expectedSIO > 0) {
								hasExpectedSIO = true;
                            }
                            //EDGE-194599
                            if(att[key].actualSIO > 0) {
								hasActualSIO = true;
                            }
                            }
						}
						if(hasExpectedSIO === false &&  (changeTypeVal  === 'New' || changeTypeVal === '' || changeTypeVal === 'transition')) {
							compconfig.status = false;
							compconfig.statusMessage = 'Atleast one expected SIOs must be greater than 0';
							doNotStopValidateSave = false;
                        }

                       //EDGE-194599         
                       else if(hasActualSIO === false &&  (changeTypeVal  === 'Modify')) {
							compconfig.status = false;
							compconfig.statusMessage = 'Atleast one SIOs must be greater than 0';
							doNotStopValidateSave = false;
                        }
                        
                        else {
							compconfig.status = true;
							compconfig.statusMessage = '';
						}
					}
				}

	
					}
				}

			}
		}
	   
		if(doNotStopValidateSave === false) {
            if(hasExpectedSIO === false) {
                CS.SM.displayMessage('Atleast one expected SIOs must be greater than 0', 'error');
            } 
            //EDGE-194599 
            else if(hasActualSIO === false) {
                CS.SM.displayMessage('Atleast one SIOs must be greater than 0','error');
            }
		}
        return doNotStopValidateSave;
	},
	/**********************************************************************************************************************************************
	 * EDGE-178219
	 * Author   : Payal
	 * Invoked When: when Change = Cancel is clicked for NGUC and AdaptiveMobility
	 * Description : updates disconnection date as Today's date
	 ********************************************************************************************************************************************/
	updateDiscountDate : async function(componentName,guid) {
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentName);
		let attnameToattMap ={};
		var currentDate = new Date();
		attnameToattMap[guid] = [];
		attnameToattMap[guid].push({
			name: 'DisconnectionDate',
			displayValue : currentDate,
			value : currentDate
		});
		if (attnameToattMap && Object.keys(attnameToattMap) && Object.keys(attnameToattMap).length > 0) {
			component.updateConfigurationAttribute(guid, attnameToattMap[guid], true);
		}
		
		return Promise.resolve(true);

	 },

/***********************************************************************************************
	 * Author	   : Vamsi Krishna Vaddipalli
	 * EDGE number : EDGE-207354
	 * Method Name : updateSolutionNameOnOLoad(solutionName)
	 * Invoked When: On solution load
     * Description : It will update the Solution name to offerName if solution name contains billing account.
	***********************************************************************************************/
	updateSolutionNameOnOLoad : async function(solutionName){
		let solution = await CS.SM.getActiveSolution();

		if (solution.name.includes(solutionName)) {
			let solutionConfigs = solution.getConfigurations();
			if (solutionConfigs) {
				Object.values(solutionConfigs).forEach((solConfig) => {
					let preferredBillingAccountATT=solConfig.getAttribute('BillingAccountLookup');
                    if(preferredBillingAccountATT && preferredBillingAccountATT.displayValue  )
                    {
                        for(var config of Object.values(solutionConfigs)){
                            if(config.configurationName && config.configurationName.includes(preferredBillingAccountATT.displayValue))
                            if(!config.disabled)
                            {
                                CommonUtills.updateSolutionfromOffer(config.guid);
                            }
                        }
                    
                    }
				});
			}
	    }
    },
    UpdateRelatedConfigForChildMac: async function (guid, componentName,attributeName) {
        let loadedSolution = await CS.SM.getActiveSolution();
        let currentBasket = await CS.SM.getActiveBasket();// DIGI-16041
        if (loadedSolution.componentType && 
            (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)
            || loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)
            || loadedSolution.name.includes(IOTMobility_COMPONENTS.solution)
            )) {
            window.currentSolutionName = loadedSolution.name;
            let comp = loadedSolution.getComponentByName(componentName);
            if (comp) {
                let subsConfig = comp.getConfiguration(guid);
                if (subsConfig.disabled === false && guid === subsConfig.guid && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                    var updateConfigMap = {};
                    /*var relatedConfigAttribValue ='';
                    let relatedConfigAttrib =  subsConfig.attributes['replacedConfigid'.toLowerCase()];
                        if(relatedConfigAttrib)  relatedConfigAttribValue = relatedConfigAttrib.value;
                        else{
                            let relatedConfigAttrib =  subsConfig.attributes['replacedConfig'.toLowerCase()];
                            if(relatedConfigAttrib)  relatedConfigAttribValue = relatedConfigAttrib.value;
                            else{
                                relatedConfigAttrib =  subsConfig.attributes['replaceConfigid'.toLowerCase()];
                                if(relatedConfigAttrib) relatedConfigAttribValue = relatedConfigAttrib.value;
                                else{
                                    relatedConfigAttrib =  subsConfig.attributes['replaceConfig'.toLowerCase()];
                                    if(relatedConfigAttrib) relatedConfigAttribValue = relatedConfigAttrib.value;
                                }
                            }
                        }*/
                                            
                    //updateConfigMap[relatedConfig.guid]
                    subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                        let inputMap = {};
                        inputMap["GetConfigurationId"] = relatedConfig.guid;
                        inputMap["basketId"] = basketId;
                        //inputMap["replacedConfigId"] = relatedConfigAttribValue;
                        inputMap["replacedConfigId"] = subsConfig.replacedConfigId;//Fix for DIGI-16041
                        var attName ;
                        let attribute =  subsConfig.attributes['replacedConfigid'.toLowerCase()];
                        if(attribute)  attName = attribute.name;
                        else{
                            let attribute =  subsConfig.attributes['replacedConfig'.toLowerCase()];
                            if(attribute)  attName = attribute.name;
                            else{
                                attribute =  subsConfig.attributes['replaceConfigid'.toLowerCase()];
                                if(attribute) attName = attribute.name;
                                else{
                                    attribute =  subsConfig.attributes['replaceConfig'.toLowerCase()];
                                    if(attribute) attName = attribute.name;
                                }
                            }
                        }
                        inputMap['attributeName'] = attName;
                        await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => { //Changed from activeNGEMBasket to currentBasket (DIGI-16041)
                            console.log(attName);
                            console.log('----------');
                            console.log(result);
                            var parentid = result[attName];
                            var configGuid = result["childGuid"];
                            var replaceId = result["childId"];
                            if (configGuid === relatedConfig.guid) {
                                relatedConfig.configuration.replacedConfigId = replaceId;
                                updateConfigMap[relatedConfig.guid] = [								{
                                    name: attName,
                                    value: replaceId,
                                }];
                            }
                            let keys = Object.keys(updateConfigMap);
                            for (let i = 0; i < keys.length; i++) {
                                comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
                            }
                            //relatedConfig.configuration.id = relatedConfigId;
                        });
                    });
                    
                }
            }
            return Promise.resolve(true);
        }
    },
        
    /*
        * DIGI-16898 
        * method to check in mac if configuration is already having discounts in base order and update the dli bussiness ids on config
    */
        updateCarryForwardDiscountonRelatedProduct: async function (componentName, configuration) {s
        let solution = await CS.SM.getActiveSolution();
        let comp = solution.getComponentByName(componentName);
        let subsConfig;
        if(configuration.relatedProductList && configuration.relatedProductList.length > 0)
            subsConfig= comp.getConfiguration(configuration.guid );
        else
                subsConfig=comp.getConfiguration(configuration.parentConfiguration);
        let currentBasket = await CS.SM.getActiveBasket();
        let replacedConfigIdList=[];
        let inputMap={};
        var updateConfigMap = {};
        if (!subsConfig.disabled) {
            subsConfig.relatedProductList.forEach((relatedConfig) => {
                replacedConfigIdList.push(relatedConfig.configuration.replacedConfigId);
                inputMap["configList"] = replacedConfigIdList.toString();
            });            
            inputMap['getCarryForwardDiscounts']='';
            console.log(inputMap["configList"]);
            await currentBasket.performRemoteAction("macDiscountHandler", inputMap).then((result) => {
                subsConfig.relatedProductList.forEach((relatedConfig) => {
                    if(result[relatedConfig.configuration.replacedConfigId] && relatedConfig.guid===configuration.guid){
                        updateConfigMap[relatedConfig.guid] = [
                        {
                            name: 'CarryForwardDiscount',
                            value: result[relatedConfig.configuration.replacedConfigId]
                        }];
                    }
                });
                let keys = Object.keys(updateConfigMap);
                for (let i = 0; i < keys.length; i++) {
                    comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
                }
                return Promise.resolve(true);
            });
        }
    },
    /*featureToggleCachedData method to invoked only onload and map to be used for checking feature eligibility later based on custom metadata name*/
    checkFeatureEligibility: async function(){
        let currentBasket = await CS.SM.getActiveBasket();  
        if(!window.FeatureEligibilityMap){
                let inputmap={};
            inputmap['checkFeatureEligibility']='';
            await currentBasket.performRemoteAction("macDiscountHandler", inputmap).then((result) => {
                window.FeatureEligibilityMap=result;
            });
        }
    },
	// Added by vijay DIGI-456 || start
	CloneOrderEnrichment: async function (componentName, guid) {
		let loadedSolution = await CS.SM.getActiveSolution();
		let comp = loadedSolution.getComponentByName(componentName);
		 let currentBasket = await CS.SM.getActiveBasket();  
		if (comp) {
			let subsConfig = comp.getConfiguration(guid);
			let inputmap={};
			inputmap['OrderReplacedId']=subsConfig.replacedConfigId;
			inputmap['pcid']=subsConfig.id;
			await currentBasket.performRemoteAction("SolutionActionHelper", inputmap).then((result) => {
				var response =result['OrderReplacedId'];
				console.log(response);
			});
		}
	},
 oeErrorOrderEnrichment: async function () {
		let loadedSolution = await CS.SM.getActiveSolution();
       if (window.basketStage !== "Contract Accepted") return;
		let solId = loadedSolution.id;
		 let currentBasket = await CS.SM.getActiveBasket();  
		if (solId) {
			let inputmap={};
			inputmap['oeError']=solId;
			await currentBasket.performRemoteAction("SolutionActionHelper", inputmap).then((result) => {
				var response =result['oeError'];
				if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
					for(let comp of Object.values(loadedSolution.components)){
						let config = comp.getConfigurations();
						if (config && Object.values(config).length > 0) {
							for(let compconfig of Object.values(config)){
                                 let ChanngeTypeAtr;
                                 if (compconfig.attributes && Object.values(compconfig.attributes).length > 0) {
                                     let attribs = Object.values(compconfig.attributes);
                                	 ChanngeTypeAtr = attribs.filter((obj) => {
                                    		 return obj.name === "ChangeType";
                                      });
                                 }
       							if(ChanngeTypeAtr && ChanngeTypeAtr.length> 0 && ChanngeTypeAtr[0].value  != 'Cancel' || ChanngeTypeAtr.length==0 ){
                                    for (let compErr of response){
                                        if(compconfig.id === compErr ) {
                                            compconfig.status = false;
                                            compconfig.statusMessage = 'Order Enrichment has an Error';
                                            break;
                                        }
                                        else {
                                            compconfig.status = true;
                                            compconfig.statusMessage = '';
                                        }
                                    }
                                    if(response.length ==0){
                                     compconfig.status = true;
                                     compconfig.statusMessage = '';
                                    }
   								}
							}
						}

					}
				}
			});
		}
	}
	// Added by vijay DIGI-456 || End
 };