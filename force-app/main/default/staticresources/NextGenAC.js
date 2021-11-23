/******************************************************************************************
* Author	   : DPG Tungsten
Change Version History
Version No	Author 			        Date
1 			Romil                 Jun  2020       Adaptive Care Validation for DPG-2015
2			Monali				  Jun  2020       Cancel Flow for Adaptive Care DPG-1914
3			Shresth				  July 2020       Rate matrix flow for adaptive care DPG-2395
*****************************************************************************************/
var NextGenMobilityAC = 'Next Gen Mobility Adaptive Care Plugin';
console.log('Loading ', NextGenMobilityAC);

	//var basketId = null; //AB do not clear basketId
	let inputMap = {};

if(!CS || !CS.SM){
	throw Error('Solution Console Api not loaded?');
}

// Create a mapping to match your solution's components
// Add your own component names to map
	var NextGenFC_COMPONENTS = {			
		solution: 'Adaptive Mobility Care',
		AdaptiveCare: 'Adaptive Care',
	};

//var changetypeMACsolution = null;

if (CS.SM.registerPlugin) {
    console.log('Load NGAC plugin');
    window.document.addEventListener('SolutionConsoleReady', async function () {
        await CS.SM.registerPlugin(NextGenFC_COMPONENTS.solution)
            .then(async NGMACPlugin => {
                console.log("Plugin registered for Next Gen Mobility Adaptive Care");
                updateNGMACPlugin(NGMACPlugin);
                console.log("UpdatedPlugin calling");
                return Promise.resolve(true);
            });
        return Promise.resolve(true);
    });
}
/* Krunal
let NGMACPlugin = CS.SM;
if (CS && CS.SM && CS.SM.createPlugin) {
	NGMACPlugin = CS.SM.createPlugin(NextGenFC_COMPONENTS.solution);
	console.log('Created ', NGMACPlugin, ' for solution ', NextGenFC_COMPONENTS.solution);
}
if(!NGMACPlugin){
	throw Error('Unabled to create ', NGMACPlugin);
}
*/
function updateNGMACPlugin(NGMACPlugin) {

	
// HOOK: afterNavigate //No Change Krunal
		NGMACPlugin.afterNavigate = async function(currentComponent,previousComponent){
			/*if (currentComponent.name === NextGenFC_COMPONENTS.solution){
				console.log('Adaptive Care Rate Card');
				Utils.updateCustomAttributeLinkText('Adaptive Care Rate Card', 'View');
			}*/
		}

// HOOK: afterAttributeUpdated 

    //NGMACPlugin.afterAttributeUpdated =async function (componentName,guid, attribute, oldValue, newValue) {  //Krunal
	NGMACPlugin.afterAttributeUpdated =async function (component, configuration, attribute, oldValueMap) {
	console.log(NGMACPlugin, ': Updated attribute - after ', component.name, configuration.guid, attribute, oldValueMap);	
	let currentSolution = await CS.SM.getActiveSolution(); //EDGE-154489
	if (basketStage === "Contract Accepted") {
		currentSolution.lock("Commercial", false);
	}
	//Added for Cancel Story DPG-1914
    if (basketChangeType === 'Change Solution' && attribute.name === 'ChangeType') {
        //changetypeMACsolution = attribute.value; //added 
        NGMACPlugin_UpdateCancellationAttributes(component.name, configuration.guid, attribute.value);
    }
        if (basketChangeType === 'Change Solution' && component.name === NextGenFC_COMPONENTS.solution && attribute.name === 'DisconnectionDate'){
			NGMACPlugin_validateDisconnectionDate(component.name, configuration.guid, attribute.value);
		}

		//Added for DPG-2015
		
		if (component.name === NextGenFC_COMPONENTS.solution  && attribute.name === "BillingAccountShadowNextGenAC") {	
									var billingAccount=attribute;
				
			validationBillingCheck(billingAccount,component.name,configuration.guid);		
		} 
    	
    	//DPG-2084 Start
		if(component.name === NextGenFC_COMPONENTS.solution && attribute.name === 'OfferId'){							
			await NGMACPlugin_updateAttributeVisiblity('ShowADPRateCard',NextGenFC_COMPONENTS.solution, configuration.guid, false, attribute.value, false);    
    	}
    	//DPG-2084 End
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		}
		//For  EDGE-212397 shubhi start
		if (component.name === NextGenFC_COMPONENTS.solution && attribute.name === "BillingAccountLookup") {

			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await CHOWNUtils.getParentBillingAccount(NextGenFC_COMPONENTS.solution);
				if(parentBillingAccountATT){
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NextGenFC_COMPONENTS.AdaptiveCare,oldValueMap.value);
				}
			}
		}
		if (component.name === NextGenFC_COMPONENTS.solution && attribute.name === "Marketable Offer") {
			//updatevendordetails(configuration.guid);
			CommonUtills.updateSolutionfromOffer(configuration.guid);//For EDGE-207353 on 14APR2021 by Vamsi
		}
		//For EDGE-212397  shubhi end
        return Promise.resolve(true);
};
    
//---MACD
// HOOK: afterConfigurationAddedToMacBasket  //No Change Krunal
NGMACPlugin.afterConfigurationAddedToMacBasket = async function _solutionAfterConfigurationAdd(componentName, guid) {
        console.log('afterConfigurationAdd', componentName, guid);
		if (componentName === NextGenFC_COMPONENTS.AdaptiveCare) {
			   
		 	   var changetypeMACsolution = 'Cancel';
			   let updateMap = {};
				updateMap[guid] = [];

				updateMap[guid].push(
				{
					name: "ChangeType",
					value: changetypeMACsolution,
					label: "ChangeType",
					showInUi: true
				},
                // EDGE-207352 Start
                {
					name: "BillingAccountLookup",
					showInUi: false
				}
                // EDGE-207352 End
                );
			
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(componentName); 
			var complock = component.commercialLock;
			if(complock) component.lock('Commercial', false);
			let keys = Object.keys(updateMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
			}
			if (complock) component.lock('Commercial', true);
		}
		return Promise.resolve(true);
    }; 
    
    // HOOK: afterConfigurationAdd
	NGMACPlugin.afterConfigurationAdd = async function (component, configuration) {
		console.log(NGMACPlugin, ': Config add - after', component.name, configuration);
		//For EDGE-212397 by Shubhi starts
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			
			if (window.accountId !== null && window.accountId !== "") {
				CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
				await CHOWNUtils.getParentBillingAccount(NextGenFC_COMPONENTS.solution);
				if(parentBillingAccountATT){
					CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name);
				}
			}
		}
		//For EDGE-212397 by shubhi ends
		//NGMACPlugin_updateChangeTypeAttribute
		return Promise.resolve(true);
	};
                                                                                   
    // HOOK: beforeSave // No Change Krunal
	NGMACPlugin.beforeSave = async function (solution) {
        CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
		console.log(NGMACPlugin, ': Before save hook', solution);
        //Shresth DPG-2395 start
		await NGMACPlugin_updateAttributeVisiblity('ShowADPRateCard',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
        //Shresth DPG-2395 end
		return Promise.resolve(true);
	};
                                                                                   
    // HOOK: beforeAttributeUpdated
	//NGMACPlugin.beforeAttributeUpdated = function (componentName, guid, attribute, oldValue, newValue) { //Krunal
	NGMACPlugin.beforeAttributeUpdated = function (component, configuration, attribute, newValueMap) {
		//console.log('Updated attribute - before', componentName, attribute, oldValue, newValue);

		/** ADD YOUR CODE HERE like above example **/

		return Promise.resolve(true);
	};
                                                                                   // HOOK: beforeConfigurationAdd //Krunal No change

	NGMACPlugin.beforeConfigurationAdd = function (componentName, configuration) {
		console.log(NGMACPlugin, ': Config add - before', componentName, configuration);

		return Promise.resolve(true);
	};

// HOOK: beforeConfigurationDelete //Krunal No change
	NGMACPlugin.beforeConfigurationDelete = function (componentName, configuration) {
		console.log(NGMACPlugin, ': Config deleted - before', componentName, configuration);
        
		return Promise.resolve(true);
	};

// HOOK: afterConfigurationDelete //Krunal No change
	NGMACPlugin.afterConfigurationDelete = function (componentName, configuration) {
		console.log(NGMACPlugin, ': Config delete - after', componentName, configuration);

		return Promise.resolve(true);
	};
                                                                                        
                                                                                   	
//}
            
	window.document.addEventListener('SolutionSetActive', async function (e) {
        let loadedSolution = await CS.SM.getActiveSolution();
        //if (loadedSolution.componentType && loadedSolution.name.includes(NextGenFC_COMPONENTS.solution)) { 
        if (loadedSolution.name === NextGenFC_COMPONENTS.solution) {
            console.log('NGAC After Solution Loaded');
            let basketId = e.detail.solution.basketId;
            let currentBasket = await CS.SM.loadBasket(basketId);
            await CommonUtills.getBasketData(currentBasket);
            console.log('Basket: ', currentBasket);
            if (window.basketStage === "Contract Accepted") {
                loadedSolution.lock("Commercial", false);
            }
            //CommonUtills.setBasketChange();
            inputMap['AccountId'] = window.accountId;
			validationErrorBillingCheck();//DPG-2015
			// Added for DPG-1784
            if (window.accountId != null) {
                await CommonUtills.setAccountID(NextGenFC_COMPONENTS.solution, window.accountId);
            }
            
            window.currentSolutionName = loadedSolution.name;
            
		// Added for making BillingAccount ReadOnly in MACD Journey(DPG-1914) 
		if (loadedSolution.name.includes(NextGenFC_COMPONENTS.solution)) {
            if (basketChangeType === "Change Solution" && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId && Object.values(loadedSolution.schema.configurations)[0].replacedConfigId !== null) {
                let componentMap = new Map();
                let componentMapattr = {};
                let billingAccLook = Object.values(loadedSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
                componentMapattr["BillingAccountLookup"] = [];
                componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                componentMap.set(Object.values(loadedSolution.schema.configurations)[0].guid, componentMapattr);
                await CommonUtills.attrVisiblityControl(NextGenFC_COMPONENTS.solution, componentMap);
                if (billingAccLook.value === null || billingAccLook.value === "") {
                    //changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                    CommonUtills.setSubBillingAccountNumberOnCLI(NextGenFC_COMPONENTS.solution, "BillingAccountLookup", true);
                }
            }
        }
		//---MACD
			if (basketChangeType === 'Change Solution') {
				await CommonUtills.updateSolutionNameOnOLoad(NextGenFC_COMPONENTS.solution); // added by Vamsi for EDGE-207354
				await checkConfigurationSubscriptionsForNGAC('afterSolutionLoaded');
				await NGMACPlugin_UpdateMainSolutionChangeTypeVisibility(loadedSolution);
                /*
				CommonUtills.setSubBillingAccountNumberOnCLI(NextGenFC_COMPONENTS.solution,'BillingAccountLookup');		// Krunal //tocheck
				let componentMap = new Map();
				let componentMapattr = {};
				  
				if(loadedSolution ){
					//loadedSolution.schema.configurations.forEach((config) => {
					Object.values(loadedSolution.schema.configurations).forEach((config) => {
					if(config.attributes){
							componentMapattr['BillingAccountLookup'] = [];
							componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': true
							});
							componentMap.set(config.guid, componentMapattr);
					}
					});
					CommonUtills.attrVisiblityControl(NextGenFC_COMPONENTS.solution, componentMap);
				}
        		*/
			}//END DPG-1914
                
 	
				//Added by Shresth Start DPG-2395
				console.log('call methos: ', loadedSolution);
				if(NextGenFC_COMPONENTS.solution===loadedSolution.name){
                    console.log('in if: ');
					await handleAttributeVisibility(loadedSolution);
				}
			//Added by Shresth End DPG-2395
			if (basketStage === "Contract Accepted") {
				currentSolution.lock("Commercial", true);
			} //RF for lock issue
			return Promise.resolve(true);
		}
	});

// HOOK: onCustomAttributeEdit

/*Commented by shresth hook shifted in uipluin.js (does not work here)
NGMACPlugin.onCustomAttributeEdit = async function(componentName, configurationGuid, attributeName) {
    	//Added by shresth start DPG-2395
        var url = '';
		var vfRedirect = '';
        var offerid = '';
		let solution = await CS.SM.getActiveSolution();
       // await CS.SM.getActiveSolution().then((solution) => {
			//if (solution.type && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
			if (solution.componentType && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
				//if (solution.components && solution.components.length > 0) {
				if (solution.components && Object.values(solution.components).length > 0) {
					//solution.schema.configurations.forEach((config) => {
					Object.values(solution.schema.configurations).forEach((config) => {
						//if (config.attributes && config.attributes.length > 0){
						if (config.attributes && Object.values(config.attributes).length > 0) {
							//offerid = config.attributes.filter((attr) => {
							offerid = Object.values(config.attributes).filter(attr => {
								return attr.name === 'OfferId'
                            });
						}
                    });
                }
    		}
			//});
		console.log('offerIdreturn' +offerid.value);		
		var redirectURI = '/apex/';
		if (communitySiteId) {
			url = window.location.href;
		if (url.includes('partners.enterprise.telstra.com.au'))
			redirectURI = '/s/sfdcpage/%2Fapex%2F';
		else
			redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';
		}
		url = redirectURI;
	
		if(attributeName === 'ShowADPRateCard'){
            if(communitySiteId){
                url = url + encodeURIComponent('c__RateMatrixForIoT?offerid=' + offerid[0].value);
            }
            else{
    			url = 'c__RateMatrixForIoT?offerid=' + offerid[0].value;
			}
            vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
            return Promise.resolve(vfRedirect);
        }
		//Added by shresth end DPG-2395

		return Promise.resolve(true);
};
*/

// HOOK: afterSave
//NGMACPlugin.afterSave = async function(solution, configurationsProcessed, saveOnlyAttachment) { 
	//NGMACPlugin.afterSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
	NGMACPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        try{
    	let solution = result.solution;
		console.log('afterSave', solution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
    	console.log('afterSave - entering');
    
     	//Added for Cancel Story DPG-1914
    	if (basketChangeType === 'Change Solution') {
        	NGMACPlugin_UpdateMainSolutionChangeTypeVisibility(solution);
        	//checkConfigurationSubscriptionsForNGAC('afterSave');
        	//NGMACPlugin_UpdateAttributesForMacdOnSolution(solution);
    	}
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", false);
		} //RF for lock issue 
    	//Shresth DPG-2395 start
		//await handleAttributeVisibility(solution);
    	//Shresth DPG-2395 end
   		// NGMACPlugin_setchangeTypevisibility(solution);
    	await Utils.updateActiveSolutionTotals();//Added as part of EDGE-154489
    	CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
    	Utils.hideSubmitSolutionFromOverviewTab();
		if (basketStage === "Contract Accepted") {
			currentSolution.lock("Commercial", true);
		} //RF for lock issue
    }catch(error){
        CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
        console.log(error);
    }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
    	return Promise.resolve(true);
};

//----MACD
/* - Remove this to uncomment
	//Invokes on load & after save events on Mac basket
	async function NGMACPlugin_setchangeTypevisibility(product) {
		//console.log('setchangeTypevisibility');
		var updateSolnMap = {};
		//Changes as part of EDGE-154489 start
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(NextGenFC_COMPONENTS.solution);
		//Changes as part of EDGE-154489 end
		// Aditya: Edge:142084, Enable New Solution in MAC Basket
		if (window.BasketChange === 'Change Solution') {

			//console.log('addAllEMSSubscriptionstoMAC', product);
			if (product.schema.configurations) {
				Object.values(product.schema.configurations).forEach(config => {
					//Changes as part of EDGE-154489 start
					/*updateSolnMap[config.guid] = [{
						name: "ChangeType",
						value: {
							showInUi: true
						}
					}];*/
/* - Remove this to uncomment
					updateSolnMap[config.guid] = [];
					updateSolnMap[config.guid].push({
						name: "ChangeType",
						showInUi: true
					});
				});
			}
			//Changes as part of EDGE-154489 start
			if (updateSolnMap && Object.keys(updateSolnMap).length > 0) {
				keys = Object.keys(updateSolnMap);
				for (let i = 0; i < keys.length; i++) {
					await component.updateConfigurationAttribute(keys[i], updateSolnMap[keys[i]], true);
				}
			}
			
			return Promise.resolve(true);


		} else
			return Promise.resolve(true);
	}
*/ //- Remove this to uncomment

//----MACD
NGMACPlugin_UpdateAttributesForMacdOnSolution = async function(solution) {
	console.log('NGMACPlugin_UpdateAttributesForMacdOnSolution');
	let  changeTypeAtrtribute;
	let cancellationReasonAtribute;
	if (solution && /*solution.type &&*/ solution.name.includes(NextGenFC_COMPONENTS.solution)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			changeTypeAtrtribute = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
				return obj.name === 'ChangeType' && obj.displayValue === 'Cancel'
			});
			if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
				NGMACPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false,true, true);
			} else {
				NGMACPlugin_updateAttributeVisibility(solution.schema.name, 'CancellationReason', Object.values(solution.schema.configurations)[0].guid,false, false, false);
				Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'CancellationReason', false);
				Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, 'DisconnectionDate', false);
			}
			let comp = Object.values(solution.components).filter(c => {
				return c.schema && c.name === NextGenFC_COMPONENTS.AdaptiveCare && c.schema.configurations && Object.values(c.schema.configurations).length > 0
			});
			if (comp && comp.length > 0) {
				for (let i = 0; i < Object.values(comp[0].schema.configurations).length; i++) {
					let config = Object.values(comp[0].schema.configurations)[i];
					//console.log('print config---->'+config.guid+Object.values(config.attributes));
					changeTypeAtrtribute = Object.values(config.attributes).filter(obj => {
						return obj.name === 'ChangeType'
					});
					console.log('print changeTypeAtrtribute---->'+changeTypeAtrtribute[0].displayValue);
					
					if (changeTypeAtrtribute && changeTypeAtrtribute.length > 0) {
						//EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute[0].displayValue, selectPlanDisplayValue);
					}
				}
			}
		}
	}
	return Promise.resolve(true);
}
	
//----MACD
	  /****************************************************************************************************
	 * Author	: Monali Mukherjee
	 * Method Name : NGMACPlugin_UpdateMainSolutionChangeTypeVisibility
	 * Defect/US # : DPG-1914
	 * Invoked When: On Solution Load
	 * Description : For Setting Visibility 
	 ************************************************************************************************/
    NGMACPlugin_UpdateMainSolutionChangeTypeVisibility = async function(solution) { 
		if (basketChangeType !== 'Change Solution') {
			return;
		}
		//Added for Cancel Story -- START
		var chtype; 
		var replacedConfig; 
        
		if (solution && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
		if (solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
			for (const config of Object.values(solution.schema.configurations)) {
				chtype = Object.values(config.attributes).filter(a => {
					return a.name === 'ChangeType'
				});
                replacedConfig = config.replacedConfigId;
			}
			}
		}
		//if (solution && solution.solutionName.includes(NextGenFC_COMPONENTS.solution)) {
		//if (solution.components && Object.values(solution.components).length > 0) {
		//	chtype = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(obj => {
		//		return obj.name === 'ChangeType'
		//	});
        //}
        //}
		
		console.log('--changeType--'+chtype[0].value);
        
        //if((chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New') && (replacedConfig == null && replacedConfig == undefined && replacedConfig == "")){
        if(replacedConfig === null && replacedConfig === undefined && replacedConfig === ""){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: false},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
                {name: 'Space1', showInUi: false},
				{name: 'Space2', showInUi: false},
				{name: 'Space3', showInUi: false}
			];
			console.log('NGMACPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await NGMACPlugin_updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMACPlugin_updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await NGMACPlugin_updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if((chtype[0].value === '' || chtype[0].value === null || chtype[0].value === 'New') && (replacedConfig !== null && replacedConfig !== undefined && replacedConfig !== "")){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: false},
				{name: 'DisconnectionDate', showInUi: false},
                {name: 'Space1', showInUi: true},
				{name: 'Space2', showInUi: true},
				{name: 'Space3', showInUi: false}
			];
			console.log('NGMACPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await NGMACPlugin_updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMACPlugin_updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			await NGMACPlugin_updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, false, false);
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		if(chtype[0].value === 'Cancel'){
		
			let updateMap = {};
			//updateMap[solution.schema.configurations[0].guid] = [
			updateMap[Object.values(solution.schema.configurations)[0].guid] = [
				{name: 'ChangeType',     showInUi: true},
				{name: 'CancellationReason', showInUi: true},
				{name: 'DisconnectionDate', showInUi: true},
				{name: 'Space1', showInUi: false},
				{name: 'Space2', showInUi: false},
                {name: 'Space3', showInUi: false}
			];
			console.log('NGMACPlugin_UpdateMainSolutionChangeTypeVisibility', updateMap);
			await NGMACPlugin_updateAttributeVisiblity('ChangeType',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMACPlugin_updateAttributeVisiblity('CancellationReason', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, true);
			await NGMACPlugin_updateAttributeVisiblity('DisconnectionDate', NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, true, false);
			
			let activeSolution = await CS.SM.getActiveSolution();
			let component = await activeSolution.getComponentByName(NextGenFC_COMPONENTS.solution);
			if (updateMap && Object.keys(updateMap).length > 0) {
				keys = Object.keys(updateMap);
				for (let i = 0; i < keys.length; i++) {
						const config = await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
				}
			}
		}
		
		//Added for Cancel Story  -- END
	}
	
//----MACD
   /****************************************************************************************************
	 * Author	: Monali Mukherjee
	 * Method Name : NGMACPlugin_updateAttributeVisiblity
	 * Defect/US # : DPG-1914
	 * Invoked When: On Attribute Update
	 * Description : For Setting Visibility 
	 ************************************************************************************************/
    NGMACPlugin_updateAttributeVisiblity = async function(attributeName, componentName, guid, isReadOnly, isVisible, isRequired) { 
		console.log('inside NGMACPlugin_updateAttributeVisiblity',attributeName, componentName, guid, isReadOnly, isVisible, isRequired);
		let updateMap = {};
		updateMap[guid] = [];

		updateMap[guid].push(
		{
			name: attributeName,
				readOnly: isReadOnly,
				showInUi: isVisible,
				required: isRequired
		});

		let activeSolution = await CS.SM.getActiveSolution();
		let component = await activeSolution.getComponentByName(componentName); 
		console.log('updateMap'+updateMap);  
		  
		var complock = component.commercialLock;
		if(complock) component.lock('Commercial', false);
		let keys = Object.keys(updateMap);
		for (let i = 0; i < keys.length; i++) {
			await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 	
		}
		if (complock) component.lock('Commercial', true);
		return Promise.resolve(true);
	} 
	
	//----MACD
	 /****************************************************************************************************
	 * Author	: Monali Mukherjee
	 * Method Name : UpdateCancellationAttributes
	 * Defect/US # : DPG-1914
	 * Invoked When: On Attribute Update
	 * Description : For Setting Visibility 
	 ************************************************************************************************/
    NGMACPlugin_UpdateCancellationAttributes = function(componentName, guid, changeTypeValue) { 

		if (changeTypeValue === 'Cancel' ) {
			NGMACPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, true, true);
			NGMACPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, true, false);
            NGMACPlugin_updateAttributeVisiblity('Space1', componentName, guid, false, false, false);
            NGMACPlugin_updateAttributeVisiblity('Space2', componentName, guid, false, false, false);
		}
		//if (changeTypeValue === '' || changeTypeValue === null || changeTypeValue === 'New') {
		if (changeTypeValue != 'Cancel') {
			NGMACPlugin_updateAttributeVisiblity('CancellationReason', componentName, guid, false, false, false);	
			NGMACPlugin_updateAttributeVisiblity('DisconnectionDate', componentName, guid, false, false, false);
            NGMACPlugin_updateAttributeVisiblity('Space1', componentName, guid, false, true, false);
            NGMACPlugin_updateAttributeVisiblity('Space2', componentName, guid, false, true, false);
		}
	}
	
	//----MACD
     /****************************************************************************************************
	 * Author	: Monali Mukherjee
	 * Method Name : NGMACPlugin_validateDisconnectionDate
	 * Defect/US # : DPG-1914
	 * Invoked When: On Disconnection Date Update
	 * Description : For formatting of the Disconnection Date
	 ************************************************************************************************/
	NGMACPlugin_validateDisconnectionDate = async function(componentName, guid, newValue) { //Krunal
			let today = new Date();
			let attDate = new Date(newValue);
			today.setHours(0, 0, 0, 0);
			attDate.setHours(0, 0, 0, 0);
			let solution = await CS.SM.getActiveSolution();
			let component = await solution.getComponentByName(componentName); //PD
			let config = await component.getConfiguration(guid);//PD 
			
			if (attDate <= today) {
				CS.SM.displayMessage('Please enter a date that is greater than today', 'error');
				config.status = false;
				config.statusMessage = 'Disconnection date should be greater than today!';
			} else {
				config.status = true;
				config.statusMessage = '';
			}
		}
    
	//----MACD
    /****************************************************************************************************
	 * Author	: Romil Anand
	 * Method Name : checkConfigurationSubscriptionsForNGAC
	 * Defect/US # : DPG-1914
	 * Invoked When: Raised MACD on Active Subscription
	 * Description :Update the Change Type of NGAC to Cancel
	 ************************************************************************************************/
	checkConfigurationSubscriptionsForNGAC = async function(hookname) { //krunal
		console.log('checkConfigurationSubscriptionsForNGAC');
			var componentMap = {};
			var updateMap = {};
			var solutionComponent = false;
			let solution = await CS.SM.getActiveSolution();
				console.log('Cmp Map --->', componentMap);
				if (solution.componentType && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
					if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
						solutionComponent = true;
						checkConfigurationSubscriptionsForNGACForEachComponent(solution, solutionComponent, hookname);
					}
		
					if (solution.components && Object.values(solution.components).length > 0) {
						Object.values(solution.components).forEach((comp) => {
							solutionComponent = false;
							checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname);
						});
					}
				}
			//});
		
			return Promise.resolve(true);
	}
	

//------------------------------------------------------------------------------------------
/****************************************************************************************************
 * Author	: Monali Mukherjee
 * Method Name : checkConfigurationSubscriptionsForNGACForEachComponent
 * Defect/US # : 
 * Invoked When: Raised MACD on Active Subscription
 * Description :Update the Change Type of MS to Cancel
 ************************************************************************************************/
		async function checkConfigurationSubscriptionsForNGACForEachComponent(comp, solutionComponent, hookname, solution) { //Krunal
			console.log('checkConfigurationSubscriptionsForNGACForEachComponent', comp, solutionComponent, hookname);
			var componentMap = {};
			var updateMap = {};
			var ComName = comp.name;
			console.log('Cmp Map --->', componentMap , ComName);
			var optionValues = {};
			if (comp.name == NextGenFC_COMPONENTS.solution ){
				console.log('Inside comp.name--->');
				optionValues = [{
					"value": "Cancel",
					"label": "Cancel"
				}];
			}
			if (solutionComponent) {
				var cta = '';
				if (comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
					for (const config of Object.values(comp.schema.configurations)) {
						 cta = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType'
						});
					}
				}
				
				componentMap[comp.name] = [];
				componentMap[comp.name].push({
					'id': Object.values(comp.schema.configurations)[0].replacedConfigId,
					'guid': Object.values(comp.schema.configurations)[0].guid,
					'ChangeTypeValue': cta[0].value
				});
		
			} 
				else if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
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
		
							if (config.replacedConfigId)
								componentMap[comp.name].push({
									'id': config.replacedConfigId,
									'guid': config.guid,
									'ChangeTypeValue': cta[0].value
								});
							else
								componentMap[comp.name].push({
									'id': config.id,
									'guid': config.guid,
									'ChangeTypeValue': cta[0].value
								});
		
						}
					}
				});
			}
			console.log('Cmp Map --->', componentMap);
			if (Object.keys(componentMap).length > 0) {
				var parameter = '';
				Object.keys(componentMap).forEach(key => {
					if (parameter) {
						parameter = parameter + ',';
					}
					parameter = parameter + componentMap[key].map(e => e.id).join();
					console.log('--parameter--'+parameter);
				});
		
		
				let inputMap = {};
				inputMap['GetSubscriptionForConfiguration'] = parameter;
				console.log('GetSubscriptionForConfiguration: ', inputMap);
				var statuses;
				
				let currentBasket;
				currentBasket = await CS.SM.getActiveBasket();
				//await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
					console.log('GetSubscriptionForConfiguration result:', values);
					if (values['GetSubscriptionForConfiguration'])
						statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
				});
		
				console.log('checkConfigurationSubscriptionsForNGAC statuses;', statuses);
				if (statuses) {
		
					Object.keys(componentMap).forEach( async (comp) => {
						componentMap[comp].forEach(element => {
							var statusValue = 'New';
							var CustomerFacingId = '';
							var CustomerFacingName = '';
							var status = statuses.filter(v => {
								return v.csordtelcoa__Product_Configuration__c === element.id
							});
							if (status && status.length > 0) {
								statusValue = status[0].csord__Status__c;
							}
							console.log('---statusValue--'+statusValue);
							if (element.ChangeTypeValue !== 'Cancel' && element.ChangeTypeValue !== 'Modify' && (statusValue === 'Suspended' || statusValue === 'Active' || statusValue === 'Pending' )) {
								updateMap[element.guid] = [{
										name: 'ChangeType',
										options: optionValues,
										value: statusValue,
										displayValue: statusValue
									}];
							}
							if (element.ChangeTypeValue === 'Pending') {
								updateMap[element.guid] = [{
										name: 'ChangeType',
										readOnly: true
									}];
							}
							console.log('changetypevalue---->', element.ChangeTypeValue, '-->', ComName);
		
						});
		
						console.log('checkConfigurationSubscriptionsForNGAC update map', updateMap);

						
						if (updateMap && Object.values(updateMap).length > 0) {
						
						let component =  solution.getComponentByName(componentName);
						console.log('---component--'+comp);
						let keys = Object.keys(updateMap);
						for (let i = 0; i < keys.length; i++) {
							console.log('---In for loop--');
							component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
						}
							return Promise.resolve(true);
						}
					});
				}
		
			}
			return Promise.resolve(true);
		}  





//------------------------------------------------------------------------------------------

	  /****************************************************************************************************
	 * Author	: Romil Anand
	 * Method Name : validationBillingCheck
	 * Defect/US # : DPG-2015
	 * Invoked When: On attribute update
	 * Description :Billing Account Validation
	 ************************************************************************************************/
async function validationBillingCheck(billingAccount,componentName,guid){ //Krunal
    let updateMap =  new Map();
    let componentMapNew =   new Map();
	var billingInfo="";
    let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(componentName); //PD
    let config = await component.getConfiguration(guid);//PD 
	inputMap['billingDetails']=billingAccount.displayValue;
		inputMap['guid']=guid;
        console.log("inputMaP",inputMap);
		let currentBasket;
        currentBasket = await CS.SM.getActiveBasket();
		//await CS.SM.WebService.performRemoteAction('SolutionActionHelper', inputMap).then(result => { 
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			billingInfo = JSON.parse(result["billingDetails"]);	
			console.log('the basket is==>'+billingInfo);
			//validationErrorBillingCheck(billingInfo,componentName,guid);
			return Promise.resolve(true);
					});
       if(billingInfo===true)
			{
            componentMapNew.set('CheckBillingError',true);
			//CS.SM.updateConfigurationStatus(componentName,guid, false,'This Billing Account is already associated with one of the Solution.');
			config.status = false;
			config.statusMessage = 'This Billing Account is already associated with one of the Solution.';
			}
            else
            {
            	componentMapNew.set('CheckBillingError',false);
                //CS.SM.updateConfigurationStatus(componentName,guid, true);
				config.status = true;
                config.statusMessage = '';                                                             
            }
            if(componentMapNew && componentMapNew.size>0){
												updateMap.set(guid,componentMapNew);
												CommonUtills.UpdateValueForSolution(componentName,updateMap)
											}

}
/****************************************************************************************************
	 * Author	: Shresth Dixit
	 * Method Name : handleAttributeVisibility
	 * Defect/US # : DPG-2395
	 * Invoked When: aftersolutionloaded,onsave
	 * Description : Control visibility of rate card on the basis of offer id
	 ************************************************************************************************/
handleAttributeVisibility = async function(solution){ //Krunal

   	var offerid='';
    //if (solution.type && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
	if (solution.componentType && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
                //solution.schema.configurations.forEach((config) => {
				Object.values(solution.schema.configurations).forEach((config) => {
						//if (config.attributes && config.attributes.length > 0){
						if (config.attributes && Object.values(config.attributes).length > 0) {
							//offerid = config.attributes.filter((attr) => {
							offerid = Object.values(config.attributes).filter(attr => {
								return attr.name === 'OfferId'
                            });
						}
                    });
            }
             console.log('offerid'+offerid[0].value);
			await NGMACPlugin_updateAttributeVisiblity('ShowADPRateCard',NextGenFC_COMPONENTS.solution, Object.values(solution.schema.configurations)[0].guid, false, offerid[0].value, false);
            //Utils.updateCustomAttributeLinkText('Rate Card', 'View');
            return Promise.resolve(true);
}
            
/****************************************************************************************************
	 * Author	: Romil Anand
	 * Method Name : validationErrorBillingCheck
	 * Defect/US # : DPG-2015
	 * Invoked When: Onload and Aftersave
	 * Description :Billing Account Validation
	 ************************************************************************************************/
async function validationErrorBillingCheck(){ //Krunal
	//await CS.SM.getActiveSolution().then((solution) => {
		let solution = await CS.SM.getActiveSolution();
			//if (solution.name.includes(NextGenFC_COMPONENTS.solution)) {
				if (solution && solution.name.includes(NextGenFC_COMPONENTS.solution)) {
                //if (solution.schema && solution.schema.configurations && solution.schema.configurations.length > 0) {
					if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0){
                                //solution.schema.configurations.forEach((subsConfig) => {
								Object.values(solution.schema.configurations).forEach((subsConfig) => {
										var checkbilling = Object.values(subsConfig.attributes).filter(att => {
                                        return att.name === 'CheckBillingError'
                                    });
            							if(checkbilling[0].value===true)
            									{
            										//CS.SM.updateConfigurationStatus(solution.name,subsConfig.guid, false,'This Billing Account is already associated with one of the Solution.'); 
													subsConfig.status = false;
													subsConfig.statusMessage = 'This Billing Account is already associated with one of the Solution.';
        									}else{
            								//CS.SM.updateConfigurationStatus(solution.name,subsConfig.guid,true);
											subsConfig.status = true;
											subsConfig.statusMessage = '';
        }
                                    
                                });
            
                }
			}		
		//});
            
        }	
}
