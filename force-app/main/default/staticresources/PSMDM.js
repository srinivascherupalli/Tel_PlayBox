/****************************************************************************
 * Author	   : Raviteja
 * Method Name : updateOrderTechinicalContactOnPS
 * Invoked When: Order Techinical Contact on OE is updated
 * Description : 1. Updates the Order Techinical Contact Id on its parent(UC)
 * Parameters  : 1. String : configuration guid of Order Techinical Details tab
 *               2. String : new value of the Order Techinical Contact attribute
 *               console.log('T-MDM Professional Services static resource');//Added by Aman Soni as a part of EDGE -148455
 *               var DEFAULTSOLUTIONNAME_TMDM_PS = 'Professional Services';  // Added as part of EDGE-149887
 *               var DEFUALTOFFERNAME_TMDM_PS = 'Professional Services-MDM Config'; // Added as part of EDGE-149887
 *Sukul Mongia   28/06/2020    Spring 20 Upgrade 
 *Gnana/Aditya	 19-July-2020  CS Spring'20 Upgrade
 *RaviTeja       26/10/2020 EDGE-186075 Professional Service Billing requirements-Customer Reference Number
 *Vamsi Krishna Vaddipalli  21/APR/2021 EDGE-207353 Making billing account in child chevron's form preffered billing account.
 *Antun Bartonicek     01/06/2021     21.05       EDGE-198536: Performance improvements
 ***************************************************************************/
 console.log('T-MDM Professional Services static resource');//Added by Aman Soni as a part of EDGE -148455
 var DEFAULTSOLUTIONNAME_TMDM_PS = 'Professional Services';  // Added as part of EDGE-149887
 var DEFUALTOFFERNAME_TMDM_PS = 'Professional Services-MDM Config'; // Added as part of EDGE-149887
 
 const PSMDM_COMPONENT_NAMES = {
     //solution: 'Professional Services',
     solution: 'T-MDM Professional Services', 
     UC: 'Configurations', //'T-MDM Professional Services'
     PS: 'Professional Services-MDM Config',
     OfferName: 'T-MDM Professional Services'
 };
 
 if(!CS || !CS.SM){
     throw Error('Solution Console Api not loaded?');
 }
 
 if (CS.SM.registerPlugin) {
     console.log('Load PSMDM plugin');
     window.document.addEventListener('SolutionConsoleReady', async function () {
         await CS.SM.registerPlugin(PSMDM_COMPONENT_NAMES.solution)
             .then(async PSMDMPlugin => {
                 console.log("Plugin registered for PSMDM");
                 updatePSMDMPlugin(PSMDMPlugin);
                 return Promise.resolve(true);
             });
         return Promise.resolve(true);
     });
 }
 /*if (CS.SM.createPlugin) {
     PSMDMlugin = CS.SM.createPlugin(PSMDM_COMPONENT_NAMES.solution);
     document.addEventListener('click', function(e) {
         e = e || window.event;
         var target = e.target || e.srcElement;
         var text = target.textContent || target.innerText;
             //EDGE-135267 Aakil
             if ( text && (text.toLowerCase() ==='overview' || text.toLowerCase().includes('stage'))) {
             Utils.hideSubmitSolutionFromOverviewTab();
             }
             //
         },false);
 }*/
 function updatePSMDMPlugin(PSMDMPlugin) {
     console.log('Inside updatePlugin');
     //PSMDMlugin.afterSolutionLoaded = function _AfterSolutionLoaded(previousSolution, loadedSolution) {
     window.document.addEventListener('SolutionSetActive', async function (e) {
         let currentBasket = await CS.SM.getActiveBasket();
         let loadedSolution = await CS.SM.getActiveSolution();
         if(loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)){
            window.currentSolutionName = loadedSolution.name; //Added by Venkat to Hide OOTB OE Console Button
            //EDGE-198536 Start: existing code moved inside active solution check
            document.addEventListener('click', function (e) {
                e = e || window.event;
                var target = e.target || e.srcElement;
                var text = target.textContent || target.innerText;
                //EDGE-135267 Aakil
                if (text && (text.toLowerCase() === 'overview' || text.toLowerCase().includes('stage'))) {
                    Utils.hideSubmitSolutionFromOverviewTab();
                }
            }, false);
            //EDGE-198536 End: existing code moved inside active solution check
             //if (loadedSolution.type && loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
             if (loadedSolution.componentType && loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
                 //CS.SM.getCurrentCart().then(cart => {
                 //console.log('Basket: ', cart);
                 console.log('Basket: ', currentBasket);
                 basketId = currentBasket.basketId;
                 solution = loadedSolution;
                 let inputMap = {};
                 inputMap['GetBasket'] = basketId;
                 //CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                 currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
                     console.log('GetBasket finished with response: ', result);
                     var basket = JSON.parse(result["GetBasket"]);
                     console.log('GetBasket: ', basket);
                     basketChangeType = basket.csordtelcoa__Change_Type__c;
                     basketStage = basket.csordtelcoa__Basket_Stage__c;
                     accountId = basket.csbb__Account__c;
                     window.oeSetBasketData(basketId, basketStage, accountId);
                     console.log('basketChangeType: ', basketChangeType, ' basketStage: ', basketStage, ' accountId: PSMDM',accountId);
                     console.log('basketStage: ', basketStage);
                     if (basketStage === 'Contract Accepted'){
                         loadedSolution.lock('Commercial',false);
                     }
                     //Added by Aman Soni as a part of EDGE -148455 || Start
                     if(accountId!=null && basketStage !== 'Contract Accepted'){
                         CommonUtills.setAccountID(PSMDM_COMPONENT_NAMES.solution,accountId);
                     }
                     //Added by Aman Soni as a part of EDGE -148455 || End
                     addDefaultPSMDMOEConfigs();
                     if (basketStage === 'Contract Accepted'){
                         loadedSolution.lock('Commercial',true);
                     }
                 });
                 //});
             }
             CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
                     //DPG-3036 START
                     if (currentBasket.solutions && Object.values(currentBasket.solutions).length > 0) {
                         for (const basketSol of Object.values(currentBasket.solutions)) {
                             if (basketSol && basketSol.name.includes(EMS_COMPONENT_NAMES.solution)) {
                                 let cmpConfig = await basketSol.getConfigurations(); 
                                 if (cmpConfig && Object.values(cmpConfig).length > 0) {
                                     for (const config of Object.values(cmpConfig)) {
                                         tenancyIds = config.getAttribute("TenancyId");
                                            t1 = tenancyIds.value;
                                         MSUtils.setTenancyIdForProffesionalService(t1);
                                     }
                                 }
                             }
                         }
                         }
                     //DPG-3036 END
 
         }
         CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
         return Promise.resolve(true);
     }); //}
 
     //Purushottam Added
     //PSMDMlugin.afterOETabLoaded =  async function(configurationGuid, OETabName) {
     window.document.addEventListener('OrderEnrichmentTabLoaded', async function (e) {
         let loadedSolution = await CS.SM.getActiveSolution();
         if(loadedSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)){
             //console.log('afterOETabLoaded: ', configurationGuid, OETabName);
             //var schemaName = await Utils.getSchemaNameForConfigGuid(configurationGuid);
             console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
             var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
             //window.afterOETabLoaded(configurationGuid, OETabName,schemaName , '');
             window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
         }
         return Promise.resolve(true);
     });
     //}
 
     PSMDMPlugin.afterOrderEnrichmentConfigurationAdd = function (componentName, configuration, orderEnrichmentConfiguration) {
         console.log('UCE afterOrderEnrichmentConfigurationAdd', componentName, configuration, orderEnrichmentConfiguration)
         //EDGE-120711 : Start - added by Purushottam to Enable oe-product checkbox-wrapper 
         if (configuration["guid"]) {
             window.afterOETabLoaded(configuration["guid"], componentName, configuration["name"], '');
         }
         //EDGE-120711 : End
 
         initializePMDMOEConfigs();
         window.afterOrderEnrichmentConfigurationAdd(componentName, configuration, orderEnrichmentConfiguration);
         return Promise.resolve(true);
     };
 
     PSMDMPlugin.afterOrderEnrichmentConfigurationDelete = function (componentName, configuration, orderEnrichmentConfiguration) {
         console.log('Inside afterOrderEnrichmentConfigurationDelete');
         //Below method no longer availble in OELogic, which is causing issue while deleting configurations removed part of INC000094834323
         //window.afterOrderEnrichmentConfigurationDelete(componentName, configuration, orderEnrichmentConfiguration);
         return Promise.resolve(true);
     };	
     PSMDMPlugin.beforesave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
         return Promise.resolve(true);
     };
     //Purushottam code End
     //EDGE-135267
     //PSMDMlugin.afterSave  = async function(solution, configurationsProcessed, saveOnlyAttachment){
     PSMDMPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
         try{
        CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi 
        let solution = result.solution;
         if(window.basketStage === 'Contract Accepted'){
             solution.lock('Commercial',false);
         }
         console.log('Inside afterSave');
         //component.lock('Commercial',false);
         updateSolutionName_TMDM_PS(); // Added as part of EDGE-149887   
         Utils.hideSubmitSolutionFromOverviewTab();
         await Utils.updateActiveSolutionTotals();
         CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
         if(window.basketStage === 'Contract Accepted'){
             solution.lock('Commercial',true);
         }
         CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
        }catch(error) {
            CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
            console.log(error);
        }
            CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
         return Promise.resolve(true);
     }
      //Aditya: Spring Update for changing basket stage to Draft
      PSMDMPlugin.afterSolutionDelete = function (solution) {
         CommonUtills.updateBasketStageToDraft();
         return Promise.resolve(true);
     }
     //
     //PSMDMlugin.afterAttributeUpdated = function _solutionAfterAttributeUpdated(componentName, guid, attribute, oldValue, newValue) {
     PSMDMPlugin.afterAttributeUpdated = async function _solutionAfterAttributeUpdated(component, configuration, attribute, oldValueMap) {// Added 'async' by Aman Soni as a part of EDGE-148455
        CommonUtills.unlockSolution();//For EDGE-207353 on 14APR2021 by Vamsi 
        console.log('Attribute Update - After', component.name, configuration.guid, attribute.value, oldValueMap);
         let currentSolution = await CS.SM.getActiveSolution();
         let currentComponent = currentSolution.getComponentByName(component.name);
          // Added part of EDGE-186075 to avoid lock errors           
        if (basketStage === "Contract Accepted") {
             currentSolution.lock("Commercial", false);
         }
         //if (componentName === 'Technical Details') {//EDGE-137491 Component name changed
         //if(attribute.name === 'Technical Contact' || attribute.name === 'PurchaseOrder' || attribute.name === 'TenancyID'){
         if (component.name === 'Technical Details' || component.name === 'Tenancy') { //EDGE-137491 Component name changed
             if (attribute.name === 'Technical Contact' || attribute.name === 'PurchaseOrder' || attribute.name === 'TenancyID') {
                 //updateOrderTechinicalContactOnPS(guid, newValue,attribute.name);
                 updateOrderTechinicalContactOnPS(configuration.guid, attribute.value, attribute.name,currentSolution);
             }
         }
         //EDGE-132318
         //if (componentName === 'Operations User' && attribute.name === 'Operational User') {
         if (component.name === 'Operations User' && attribute.name === 'Operational User') {
             console.log('Operations User Selection' + attribute);
             //updateOrderTechinicalContactOnPS(guid, newValue,attribute.name);
             updateOrderTechinicalContactOnPS(configuration.guid, attribute.value, attribute.name,currentSolution);
         }
         //Code for validating decimal values upto 2 values for TMDM-Professional Services
         var updateMap = [];
         //if (componentName === PSMDM_COMPONENT_NAMES.UC &&  attribute.name === 'Quantity'){
         if (component.name === PSMDM_COMPONENT_NAMES.UC && attribute.name === 'Quantity') {
             quantVal = attribute.value;
             console.log('attribute:' + quantVal.indexOf("."));
             console.log('attribute:' + attribute.name);
             if (quantVal.indexOf(".") > -1) {
                 q = quantVal.split(".");
                 if (q[1].length > 2) {
                     /*updateMap[guid] = [{
                         name: "Quantity",
                         value: {
                             value: '',
                             displayValue: '',
                             readOnly: false,
                             required: true
                         }
                     }];*/
                     updateMap[configuration.guid] = [];
                     updateMap[configuration.guid].push({
                         name: "Quantity",
                         value: '',
                         displayValue: '',
                         readOnly: false,
                         required: true
                     });
                     console.log('Error ------- You can not exceed the decimal limit more than two.');
                     //CS.SM.updateConfigurationAttribute(PSMDM_COMPONENT_NAMES.UC, updateMap, true).then(component => console.log('Qualnity Attribute update', component));
                     if (updateMap && Object.keys(updateMap).length > 0) {
                         keys = Object.keys(updateMap);
                        
                         for (let i = 0; i < keys.length; i++) {
                             currentComponent.updateConfigurationAttribute(keys[i],updateMap[keys[i]],true).then(currentComponent => console.log('Qualnity Attribute update', currentComponent));
                         }
                     }   
                     //CS.SM.updateConfigurationAttribute(configuration.guid, updateMap, true).then(component => console.log('Qualnity Attribute update', component));
                     //CS.SM.updateConfigurationStatus(PSMDM_COMPONENT_NAMES.UC,guid,false,'You can only enter a value to two decimal places ('+ quantVal+ ')');
                     // Below code has to be checked
                     let config = await component.getConfiguration(configuration.guid);
                     //config.status = false;
                     //config.statusMessage = 'You can only enter a value to two decimal places ('+ quantVal+ ')';
                 }
             }
         }
         //window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);    
         window.afterAttributeUpdatedOE(component.name, configuration.guid, oldValueMap['value'], attribute.value);
       // Added part of EDGE-186075 to avoid lock errors
         if (basketStage === "Contract Accepted") {
             currentSolution.lock("Commercial", true);
         }
		    //For EDGE-207353 on 14APR2021 by Vamsi starts
		if(component.name ===  PSMDM_COMPONENT_NAMES.solution && attribute.name === 'BillingAccountLookup')
		{
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			
			if (window.accountId !== null && window.accountId !== "") {
				let solution = await CS.SM.getActiveSolution();
				let component = await solution.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
				let configs = component.getConfigurations();
					let childGuid = ''
					Object.values(configs).forEach(async (config) => {
					childGuid = config.guid;
					CommonUtills.setConfigAccountId(PSMDM_COMPONENT_NAMES.UC, window.accountId,childGuid);
					});
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(PSMDM_COMPONENT_NAMES.solution);
				if(parentBillingAccountATT){
				CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', PSMDM_COMPONENT_NAMES.UC, oldValueMap['value']);
				}
			}
		}
		}
		//For EDGE-207353 on 14APR2021 by Vamsi ends
        CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
         return Promise.resolve(true);
     }
 }
 
 async function addDefaultPSMDMOEConfigs() {
     let currentSolution = await CS.SM.getActiveSolution();
     console.log('Inside addDefaultPSMDMOEConfigs');
     if (basketStage !== 'Contract Accepted') {
         return;
     }
     console.log('addDefaultOEConfigs');
     var oeMap = [];
     //await CS.SM.getActiveSolution().then((currentSolution) => {
     console.log('addDefaultOEConfigs ', currentSolution.name, PSMDM_COMPONENT_NAMES.solution);
     //if (currentSolution.type && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
     if (currentSolution.componentType && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
         console.log('addDefaultOEConfigs - looking components', currentSolution);
         //if (currentSolution.components && currentSolution.components.length > 0) {
         if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
             Object.values(currentSolution.components).forEach((comp) => {
                 if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                     //comp.schema.configurations.forEach((config) => {
                     Object.values(comp.schema.configurations).forEach((config) => {
                         if (comp.orderEnrichments && Object.values(comp.orderEnrichments).length > 0) {
                             Object.values(comp.orderEnrichments).forEach((oeSchema) => {
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
                                     console.log('Adding default oe config for:', comp.name, config.name, oeSchema.name);
                                 }
                             });
                         }
                     });
                 }
             });
         }
     }
     //}).then(() => Promise.resolve(true));
     //console.log('addDefaultOEConfigs prepared');
     /*if (oeMap.length> 0) {
         var map = [];
         map.push({});
         console.log('Adding default oe config map:',oeMap);
         for (var i=0; i< oeMap.length;i++) {
             await CS.SM.addOrderEnrichments(oeMap[i].componentName, oeMap[i].configGuid, oeMap[i].oeSchemaId, map).then(() => Promise.resolve(true));
         };
     }*/
     if (oeMap.length > 0) {
         let map = [];
         console.log('Adding default oe config map--:', oeMap);
         for (var i = 0; i < oeMap.length; i++) {
             console.log(' Component name ----' + oeMap[i].componentName);
             //let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration(map);
             let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
             let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
             await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
         };
     }
     //Sukul
     await initializePMDMOEConfigs();
     //For EDGE-207353 on 14APR2021 by Vamsi starts
         if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
             
             if (window.accountId !== null && window.accountId !== "") {
                 CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
                 await CHOWNUtils.getParentBillingAccount(PSMDM_COMPONENT_NAMES.solution);
                 if(parentBillingAccountATT){
                 CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
                 }
             }
         }
         //For EDGE-207353 on 14APR2021 by Vamsi ends
     return Promise.resolve(true);
 }
 async function initializePMDMOEConfigs() {
     console.log('initializeOEConfigs');
     let currentSolution = await CS.SM.getActiveSolution();
     let currentComponent = currentSolution.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
     /*var currentSolution;
     await CS.SM.getActiveSolution().then((solution) => {
         currentSolution = solution;
         console.log('initializeUCOEConfigs - getActiveSolution');
     }).then(() => Promise.resolve(true));*/
     if (currentSolution) {
         console.log('initializeUCOEConfigs - updating');
         //if (currentSolution.type && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
         if (currentSolution.componentType && currentSolution.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
             //if (currentSolution.components && currentSolution.components.length > 0) {
             if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                 for (var i = 0; i < Object.values(currentSolution.components).length; i++) {
                     var comp = Object.values(currentSolution.components)[i];
                     if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                         for (var j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                             var config = Object.values(comp.schema.configurations)[j];
                             var updateMap = {};
                             //var oeConfigMap = {};
                             if (config.orderEnrichmentList) {
                                 for (var k = 0; k < config.orderEnrichmentList.length; k++) {
                                     var oe = config.orderEnrichmentList[k];
                                     //var basketAttribute = oe.attributes.filter(a => {
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
                                     }
                                     updateMap[oe.guid].push({
                                         name: 'OfferName',
                                         value: PSMDM_COMPONENT_NAMES.OfferName
                                     });
                                     //oeConfigMap.push(oe.guid, oe.configuration.guid);
                                 }
                             }
                             if (updateMap && Object.keys(updateMap).length > 0) {
                                 console.log('initializeOEConfigs updateMap:', updateMap);
                                 //CS.SM.updateOEConfigurationAttribute(comp.name, config.guid, updateMap, false).then(() => Promise.resolve(true));
                                 let keys = Object.keys(updateMap);
                                 console.log('initializeOEConfigs keys:', keys);
                                 for(var h = 0; h < Object.values(updateMap).length; h++){
                                     console.log('update Order Enrichment COnfiguration');
                                     currentComponent.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],false);
                                 }
                             }
                         };
                     }
                 };
             }
         }
     }
     return Promise.resolve(true);
 }
 
 
 
 
 /****************************************************************************
  * Author	   : Raviteja
  * Method Name : updateOrderTechinicalContactOnPS
  * Invoked When: Order Techinical Contact on OE is updated
  * Description : 1. Updates the Order Techinical Contact Id on its parent(UC)
  * Parameters  : 1. String : configuration guid of Order Techinical Details tab
  *               2. String : new value of the Order Techinical Contact attribute
  ***************************************************************************/
 function updateOrderTechinicalContactOnPS(guid, attrValue, attributeType, loadedSolution) {
     console.log('updateOrderTechinicalContactOnPS', guid);
     product = loadedSolution;
     let currentComponent = product.getComponentByName(PSMDM_COMPONENT_NAMES.UC);
     //CS.SM.getActiveSolution().then((product) => {
     console.log('updateOrderTechinicalContactOnPS', product);
     console.log('prod Name', product.name);
     //if (product.type && product.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
     if (product.componentType && product.name.includes(PSMDM_COMPONENT_NAMES.solution)) {
         //if (product.components && product.components.length > 0) {
         if (product.components && Object.values(product.components).length > 0) {
             //product.components.forEach((comp) => {
             Object.values(product.components).forEach((comp) => {
                 console.log('@@comp.name', comp.name);
                 if (comp.name === PSMDM_COMPONENT_NAMES.UC) {
                     console.log('UC while updating OPE on OE', comp);
                     //if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
                     if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                         var psConfigGUID;
                         //comp.schema.configurations.forEach((psConfig) => {
                         Object.values(comp.schema.configurations).forEach((psConfig) => {
                             if (psConfig.orderEnrichmentList && psConfig.orderEnrichmentList.length > 0) {
                                 var opeConfig = psConfig.orderEnrichmentList.filter(config => {
                                     return config.guid === guid
                                 });
                                 if (opeConfig && opeConfig[0]) {
                                     psConfigGUID = psConfig.guid;
                                 }
                             }
                         });
                         console.log('psConfigGUID', psConfigGUID);
                         if (psConfigGUID) {
                             console.log('Inside', psConfigGUID);
                             var updateMap = [];
                             /*updateMap[psConfigGUID] = [{
                                 name: attributeType,
                                 value: {
                                     value: attrValue,
                                     displayValue: attrValue,
                                     readOnly: true,
                                     required: false
                                 }
                             }];*/
                             updateMap[psConfigGUID] = [];
                             updateMap[psConfigGUID].push({
                                 name: attributeType,
                                 value: attrValue,
                                 displayValue: attrValue,
                                 readOnly: true,
                                 required: false
                             });
                             console.log('updateMap', updateMap);
                             //CS.SM.updateConfigurationAttribute(PSMDM_COMPONENT_NAMES.PS, updateMap, true).then(component => console.log('updateOrderTechinicalContactOnPSttribute Update', component));
                             if (updateMap && Object.keys(updateMap).length > 0) {
                                 keys = Object.keys(updateMap);
                                 //DPG-3391 Start
                                 if (basketStage === 'Contract Accepted'){ 
                                     loadedSolution.lock('Commercial',false);
                                 }
                                 //DPG-3391 End
                                 for (let i = 0; i < keys.length; i++) {
                                     currentComponent.updateConfigurationAttribute(keys[i],updateMap[keys[i]],true);
                                     console.log('updateOrderTechinicalContactOnPSttribute Update', currentComponent);
                                 }
                                 //DPG-3391 Start
                                 if (basketStage === 'Contract Accepted'){
                                     loadedSolution.lock('Commercial',true);
                                 }
                                 //DPG-3391 End
                             }   
                             //CS.SM.updateConfigurationAttribute(guid, updateMap, true).then(component => console.log('updateOrderTechinicalContactOnPSttribute Update', component));
                         }
                     }
                 }
             });
         }
     }
     /*}).then(
         () => Promise.resolve(true)
     );*/
 }
 /* 	
     Added as part of EDGE-149887 
     This method updates the Solution Name based on Offer Name if User didnt provide any input
 */
 async function updateSolutionName_TMDM_PS() {
     var listOfAttributes = ['Solution Name','GUID'], attrValuesMap = {};
     attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes,PSMDM_COMPONENT_NAMES.solution);
     let solution = await CS.SM.getActiveSolution();
     let component = solution.getComponentByName(PSMDM_COMPONENT_NAMES.solution)
     let guid ;
     console.log('attrValuesMap...'+attrValuesMap);
     if(attrValuesMap['Solution Name']===DEFAULTSOLUTIONNAME_TMDM_PS){
         let updateConfigMap = {};
         /*updateConfigMap[attrValuesMap['GUID']] = [{
             name: 'Solution Name',
             value: {
                 value: DEFUALTOFFERNAME_TMDM_PS,
                 displayValue: DEFUALTOFFERNAME_TMDM_PS
             }													
             
         }];*/
         guid = attrValuesMap['GUID'];
         updateConfigMap[guid] = [];
         updateConfigMap[guid].push({
             name: 'Solution Name',
             value: DEFUALTOFFERNAME_TMDM_PS,
             displayValue: DEFUALTOFFERNAME_TMDM_PS
         });
         if(updateConfigMap){
             //CS.SM.updateConfigurationAttribute(PSMDM_COMPONENT_NAMES.solution, updateConfigMap, true);	
             if (updateConfigMap && Object.keys(updateConfigMap).length > 0) {
                 keys = Object.keys(updateConfigMap);
                 for (let i = 0; i < keys.length; i++) {
                     //component.lock('Commercial',false);
                     await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                 }
             }
         }
     }		
 }
