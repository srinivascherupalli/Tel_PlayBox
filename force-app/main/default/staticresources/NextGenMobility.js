/******************************************************************************************
Sr.No.		Author 			    Date			Sprint   		Story Number	Description
1.			Aman Soni		    3-June-2020		20.08(New JS)	EDGE-148729		Next Generation Mobility Main JS || Use only standard CS hooks in this JS
2.          Aditya Pareek       4-June-2020     20.08           EDGE-150065   	Stock Check
3.			Laxmi Rahate		5-June-2020		20.09			EDGE-150795		Enabling Order Enrichment
4.          Shubhi				8-June-2020		20.08			EDGE-148662	    Enabling one fund and POS
5.			Laxmi Rahate		16-Jun-2020		20.09 			EDGE-155254     Added Method call to check Manadatory Paremeters Values
6.			Aman Soni 			23-Jun-2020		20.09			EDGE-148667     Added afterRelatedProductAdd,afterRelatedProductDelete 
7.          Shubhi				26-Jun-2020		20.09			Edge-149830 	Redemption on device and devicecare
8.          Arinjay Singh       21-Jul-2020     20.10           Edge-164211     JSUpgrade
9.          Aman Soni			20-July-2020	20.10			EDGE-154026 	Added Code for Next Gen Plan
10.          Gnana              28-July-2020    20.10           EDGE-155181     Added Method call to check Manadatory
11.         Shubhi Vijayvergia	21.08.2020		//added by shubhi for EDGE-169593 -redemptions fix for em,nguc and dop Paremeters Values for EM Plan
12     Ankit/Shubhi/aditya/aman  25/08/2020   20.11     post upgrade js upliftment
16      Shubhi /samish          28-july-2020    20.12          //EDGE-165013
17.     Shubhi/Hitesh        	28.July.2020    20.12           EDGE-157919,EDGE-157747,EDGE-157745
18.     Shubhi               	28.July.2020    20.12       	EDGE-157797(Ir Month Pass)
19.    		Aman Soni     		31-Aug-2020    	20.12       	EDGE-166327 	Added beforeRelatedProductAdd,beforeConfigurationDelete hook
20.    Manish/Vishal            07-Sept-2020    20.12           EDGE-168275/EDGE-164350    As a Sales Enterprise, Partner, R2R user when I am doing a Device Payout within Repayment period then system should force cancellation of associated Device Care if it is within 30 days Trial period
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/

var NEXTGENMOB_COMPONENT_NAMES = {
    solutionname: 'Adaptive Mobility',//EDGE-165013
    nextGenDevice: 'Device',
    mobDeviceCare: 'Mobile Device Care',
	nextGenPlan:'Enterprise Mobility', // Added by Aman Soni for EDGE-154026
	nextGenDevSchema:'NextGenMobileDevice', // Added by Aman Soni for EDGE-154026
	nextGenPlanSchema:'NGEMPlan', // Added by Aman Soni for EDGE-154026
	planOfferId:'DMCAT_Offer_001233',
    deviceOffeId:'DMCAT_Offer_001231',
    IDD:'International Direct Dial',//EDGE-157919,EDGE-157747,EDGE-157745 shubhi
    Message_Bank:'Message Bank',//EDGE-157919,EDGE-157747,EDGE-157745 shubhi
    Data_Features:'Data Features'//EDGE-157919,EDGE-157747,EDGE-157745 shubhi
};
var allowRPDel = false;//Added by Aman Soni for EDGE-166327
var executeSaveNGM = false;
var allowSaveNGM = false;
var DEFAULTSOLUTIONNAMENGD = 'Adaptive Mobility';//EDGE-165013
let callerName_NG_Device = ''; // Added as part of EDGE_150065
let communitySiteId_NGEM = ''; // Added as part of EDGE_150065
/*EDGE-148662 start--*/
var basketNum_NEXTGENMOB; 
var solutionName_NEXTGENMOB;
var accountId__NEXTGENMOB;
var solutionID;       
let IsDiscountCheckNeeded_ngdevice = false;
let IsRedeemFundCheckNeeded_ngdevice = false;
var configId; 
/* edge-14863 end----	*/
// added  for EDGE-157797 by shubhi
var NGEMPLans={
	Handheld:'Handheld',
	Enterprise_Wireless: 'Enterprise Wireless',
	Mobile_Broadband: 'Mobile Broadband'
};
var relatedprodtobeautodeleted=['Message Bank'];

// Arinjay Register Plugin

if (CS.SM.registerPlugin) { 
    window.document.addEventListener('SolutionConsoleReady', async function () { 
		await CS.SM.registerPlugin('Adaptive Mobility').then(NextGenMobPlugin => { 
                console.log("Plugin registered for Next Gen Mobility"); 
                // For Hooks
                NextGenMobPlugin_updatePlugin(NextGenMobPlugin); 
            }); 
    }); 
} 
NextGenMobPlugin_updatePlugin = async function NextGenMobPlugin_updatePlugin(NextGenMobPlugin) {
    window.addEventListener('message', NextGenMob_handleIframeMessage);
    setInterval(NextGenMob_processMessagesFromIFrame, 500);   
    setInterval(saveSolutionNxtGenMob, 500);	
    //NextGenMobPlugin.afterSolutionLoaded = async function(previousSolution, loadedSolution) {
    window.document.addEventListener('SolutionSetActive', async function (e) {
        console.log('Inside Next Generation Mobility SolutionSetActive--->');

        // Arinjay Lock
        await NextGenMobHelper.getBasketData(basketId, NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);

        let loadedSolution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            loadedSolution.lock('Commercial',false);
        }

        // Moved this from Helper to here due to lock - Arinjay
        if (window.accountId !== null && window.accountId !== '') {
            CommonUtills.setAccountID(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, window.accountId);
        }

        // Arinjay 13 Aug 
        Utils.updateImportConfigButtonVisibility();
        if (loadedSolution.componentType && loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
            window.currentSolutionName = loadedSolution.name;	
			//Aditya: Edge:142084 Enable New Solution in MAC Basket
			CommonUtills.setBasketChange();	
            await RedemptionUtilityCommon.claculateCurrentFundBalanceAmt();//EDGE-148662
            await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-148662
            //Added by Aman Soni as a part of EDGE-148455 || Start
            var solutionComponent = false;
            var componentMap = new Map();
            var componentMapattr = {};
            if(loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
                let config = Object.values(loadedSolution.schema.configurations)[0];
                if(config.replacedConfigId && config.replacedConfigId !== null){
                    solutionComponent = true;
                    var billingAccLook = Object.values(config.attributes).filter(a => {
                        return a.name === 'BillingAccountLookup' 
                    });			
                    componentMapattr['BillingAccountLookup'] = [];
                    componentMapattr['BillingAccountLookup'].push({ 'IsreadOnly': true, 'isVisible': true, 'isRequired': false });
                    componentMap.set(config.guid, componentMapattr);
                    await CommonUtills.attrVisiblityControl(NEXTGENMOB_COMPONENT_NAMES.solutionname, componentMap);
                    if(billingAccLook[0].value === null || billingAccLook[0].value === '')//changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                    {
                        await CommonUtills.setSubBillingAccountNumberOnCLI(NEXTGENMOB_COMPONENT_NAMES.solutionname,'BillingAccountLookup',solutionComponent);		
                    }			
                }
            }
            await NextGenMobController.AfterSolutionLoaded(null, loadedSolution); 
        }

        if (window.basketStage === 'Contract Accepted'){
			    loadedSolution.lock('Commercial',true);
		    }
        return Promise.resolve(true);
    });

    NextGenMobPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
        let componentName = component.name;
        let oldValue = oldValueMap['value'];
        let newValue = attribute.value;
        let guid = configuration.guid;
        console.log('Inside Next Generation Mobility afterAttributeUpdated');

		// EDGE-168275
		if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice 
		&& (newValue==='Active' || newValue==='Cancel')){
        	await CommonUtills.getIsDeviceCancellationPossible(newValue);
        }

        let solution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }

        await NextGenMobController.AfterAttributeUpdated(componentName, configuration, guid, attribute, oldValue, newValue);
        //if((componentName === 'Delivery details' || componentName === 'Customer requested Dates'  ) && (window.basketStage === 'Contract Accepted')){
        //Utils.beforeSaveOEValidations (NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice); //EDGE-155254
        //}
       
        console.log('solution is ' , solution );

         if(window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }

        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }

        return Promise.resolve(true);
    }

    NextGenMobPlugin.beforeSave  = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        console.log('Inside Next Generation Mobility beforeSave');
        var solution = await CS.SM.getActiveSolution();
		
		    let currentSolution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            currentSolution.lock('Commercial',false);
        }
        
        if(window.basketStage !== 'Contract Accepted' ){
			    RedemptionUtils.checkConfigurationStatus();
        }
               
        if (allowSaveNGM || allowSaveNGM === true) {
            allowSaveNGM = false;       
    			return Promise.resolve(true);		
    		}		
        executeSaveNGM = true;
        await NextGenMobHelper.updateSolutionNameNGD(NEXTGENMOB_COMPONENT_NAMES.solutionname,DEFAULTSOLUTIONNAMENGD);
    		//await Utils.beforeSaveOEValidations (NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);//EDGE-155254
    		//await Utils.beforeSaveOEValidations (NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenPlan); //EDGE-155181

        if(window.basketStage === 'Contract Accepted'){
            currentSolution.lock('Commercial',true);
        }
        return Promise.resolve(true);
    }

    NextGenMobPlugin.afterSave = async function(result,  configurationsProcessed, saveOnlyAttachment, configurationGuids){
        let solution = result.solution ; 
        if(solution == null || solution == undefined)
            solution = await CS.SM.getActiveSolution();

        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }

        console.log('result is ', result );
        console.log('Inside Next Generation Mobility afterSave', solution);
        //Utils.updateCustomButtonVisibilityForBasketStage();
        Utils.updateOEConsoleButtonVisibility(); // EDGE-150795
        await NextGenMobController.AfterSave(solution, configurationsProcessed, saveOnlyAttachment); //EDGE-148662
        await Utils.updateImportConfigButtonVisibility();
        await Utils.updateActiveSolutionTotals();		
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

        if (window.basketStage === 'Contract Accepted'){
    		await Utils.beforeSaveOEValidations (NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);//EDGE-155254
    		await Utils.beforeSaveOEValidations (NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenPlan); //EDGE-155181			
			
            solution.lock('Commercial',true);
        }
        return Promise.resolve(true);
    }
	
	//Added by Aman Soni as a part of EDGE-154028 || Start
	NextGenMobPlugin.afterConfigurationClone = async function (component, configuration, clonedConfiguration){
		console.log('Inside Next Generation Mobility afterConfigurationClone--->', component.name, configuration);

		if(((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) || (component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)) && (window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft')){
			await NextGenMobHelper.DeviceAndPlanCount();
		}
		if(window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft'){
			for(var config of configuration){
				var configGuid = config.guid;
				await NextGenMobHelper.InValidateNGEMPlan(configGuid);
			}
		}
		if((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice)){
			if(window.totalRedemptions>0){
				await RedemptionUtils.populateNullValuesforClonedPC(component.name, configuration); ////EDGE-148662
			}
        }
        
        await Utils.updateActiveSolutionTotals();
        CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

        console.log('solution is ' , solution );

        if (basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }

  		return Promise.resolve(true);
  	}
  	//Added by Aman Soni as a part of EDGE-154028 || End

    NextGenMobPlugin.afterConfigurationAdd = async function (component, configuration) {
		console.log('Inside Next Generation Mobility afterConfigurationAdd--->', component.name, configuration);
        if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
            var relatedProductnameList=[NEXTGENMOB_COMPONENT_NAMES.IDD,NEXTGENMOB_COMPONENT_NAMES.Message_Bank,NEXTGENMOB_COMPONENT_NAMES.Data_Features]
            CommonUtills.addRelatedProductonConfigurationAdd(component, configuration,component.name,NEXTGENMOB_COMPONENT_NAMES.IDD,false,1);
			CommonUtills.addRelatedProductonConfigurationAdd(component, configuration,component.name,NEXTGENMOB_COMPONENT_NAMES.Data_Features,false,1);
        }
		if(((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) || (component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)) && (window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft')){
		await NextGenMobHelper.DeviceAndPlanCount();
		}
		if(window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft'){
		await NextGenMobHelper.InValidateNGEMPlan(configuration.guid);
		}
		await Utils.updateImportConfigButtonVisibility();
		RedemptionUtils.populateNullValues(component.name, configuration); ////EDGE-148662
		Utils.addDefaultGenericOEConfigs( NEXTGENMOB_COMPONENT_NAMES.solutionname);// EDGE-150795
        return Promise.resolve(true);
    }

    NextGenMobPlugin.afterConfigurationDelete = async function(component, configuration){
	console.log('Inside Next Generation Mobility afterConfigurationDelete--->', component.name, configuration);
	await Utils.updateImportConfigButtonVisibility();
	if(((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) || (component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)) && (window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft')){
		await NextGenMobHelper.DeviceAndPlanCount();
	}
	if(window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft'){
		await NextGenMobHelper.InValidateNGEMPlan(configuration.guid);
	}
        return Promise.resolve(true);
    }
	
	//Added by Aman Soni for EDGE-166327 || Start
	NextGenMobPlugin.beforeRelatedProductAdd = async function (component, configuration, relatedProduct){
        console.log('Inside Next Generation Mobility beforeRelatedProductAdd--->', component.name, configuration, relatedProduct);
			let solution = await CS.SM.getActiveSolution();
			var selectPlanType;
			if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
				if (solution.components && Object.values(solution.components).length > 0){
					Object.values(solution.components).forEach((comp) =>{
						if(comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
							if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
								Object.values(comp.schema.configurations).forEach((config) =>{
									if(config.guid){
										let attribs = Object.values(config.attributes);
										selectPlanType = attribs.filter(obj =>{
										return obj.name === 'SelectPlanType'
										});
									}
								});
							}
							if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length === 1){
								allowRPDel = false;
							}
						}
					});
				}
			}
			if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
				var countIDD = 0;
				var countMB = 0;
				var countDF = 0;
				var listOfRelatedProducts = configuration.getRelatedProducts();
				Object.values(listOfRelatedProducts).forEach(rp => {
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features) {
						countDF++;
					}
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank) {
						countMB++;
					}
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.IDD) {
						countIDD++;
					}
				});
				if (countDF == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features){
				CS.SM.displayMessage('Only one Data Features can be configured per plan', 'error');
				return Promise.resolve(false);
				}
				if (countMB == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank){
				CS.SM.displayMessage('Only one Voicemail Feature can be configured per plan', 'error');
				return Promise.resolve(false);
				}
				if (countIDD == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.IDD){
				CS.SM.displayMessage('Only one Calling & Messaging Feature can be configured per plan', 'error');
				return Promise.resolve(false);				
				}
				if(selectPlanType[0].displayValue != NGEMPLans.Handheld){
					if (countMB == 0 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank){
					CS.SM.displayMessage('You cannot add Voicemail configuration under Related Products for the selected plan type', 'error');
					return Promise.resolve(false);
					}
				} 								
			}
        return Promise.resolve(true);
    }
	//Added by Aman Soni for EDGE-166327 || End

    //Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt ||  Start
    NextGenMobPlugin.afterRelatedProductAdd = async function (component, configuration, relatedProduct){
        console.log('Inside Next Generation Mobility afterRelatedProductAdd--->', component.name, configuration, relatedProduct);
        if(relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare && relatedProduct.type === 'Related Component'){
            var DeviceConfigId= '';
            await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedProduct.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
            await NextGenMobHelper.UpdateChildFromParentAtt(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice,NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);
        }
        if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
            await NextGenMobHelper.UpdateChildAttributedonAdd(NEXTGENMOB_COMPONENT_NAMES.solutionname,configuration.guid,component,relatedProduct);
        }
        return Promise.resolve(true);
    }

    NextGenMobPlugin.afterRelatedProductDelete = async function (component, configuration, relatedProduct){
        let solution = await CS.SM.getActiveSolution();
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }
        console.log('Inside Next Generation Mobility afterRelatedProductAdd--->', component.name, configuration, relatedProduct);
        if(relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare && relatedProduct.type === 'Related Component'){
            var DeviceConfigId= '';
            await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedProduct.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
        }
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }
        return Promise.resolve(true);
    }
//Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt || End
	
	//Added by Aman Soni for EDGE-166327 || Start
	NextGenMobPlugin.beforeConfigurationDelete = async function (component, configuration) {
		let configGuid = configuration.guid;
		if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
			allowRPDel = false;
			if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0){
				Object.values(component.schema.configurations).forEach((solConfig) => {
					if(solConfig.guid === configGuid){
						allowRPDel = true;
					}else{
						allowRPDel = false;
					}						
				});				
			} 
		}    
		return Promise.resolve(true);
	}
	//Added by Aman Soni for EDGE-166327 || End
		
	NextGenMobPlugin.beforeRelatedProductDelete = async function (component, configuration, relatedProduct){
		let solution = await CS.SM.getActiveSolution();
		let configGuid = configuration.guid;		
			//if(allowRPDel === false){
				if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
					if(allowRPDel === false){
						if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0){
						Object.values(component.schema.configurations).forEach((config) => {
							if(config.guid === configGuid){
								if(config.attributes && Object.values(config.attributes).length > 0){
									let attribs = Object.values(config.attributes);
									let planType = attribs.filter(obj => {
									return obj.name === 'SelectPlanType'
									});									
									if(planType[0].displayValue===NGEMPLans.Enterprise_Wireless || planType[0].displayValue===NGEMPLans.Mobile_Broadband || planType[0].displayValue===''){
										if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.dataFeatures && relatedProduct.type === 'Related Component'){
										CS.SM.displayMessage('One data feature configuration must exist for any plan', 'error');
										return Promise.resolve(false);	
										}
										if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.internationalDirectDial && relatedProduct.type === 'Related Component'){
										CS.SM.displayMessage('Not allowed to delete the Calling & Messaging feature configuration for any plan', 'error');
										return Promise.resolve(false);	
										}
									}else if(planType[0].displayValue===NGEMPLans.Handheld){
										if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.dataFeatures && relatedProduct.type === 'Related Component'){
										CS.SM.displayMessage('One data feature configuration must exist for any plan', 'error');
										return Promise.resolve(false);	
										}
										if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.internationalDirectDial && relatedProduct.type === 'Related Component'){
										CS.SM.displayMessage('Not allowed to delete the Calling & Messaging feature configuration for any plan', 'error');
										return Promise.resolve(false);	
										}
										if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.messageBank && relatedProduct.type === 'Related Component'){
										CS.SM.displayMessage('Not allowed to delete the Voicemail feature configuration for this plan', 'error');
										return Promise.resolve(false);	
										}
									}									
								}
							}							
						});
					}
				 }
				}
			//}
			else{
				return Promise.resolve(true);
			}
	//return Promise.resolve(true);
    }
	//Added by Aman Soni for EDGE-166327 || End

    //Added by Laxmi Rahate // EDGE-150795
    NextGenMobPlugin.afterOrderEnrichmentConfigurationAdd = async function(component, configuration, orderEnrichmentConfiguration){
        let solution = await CS.SM.getActiveSolution();
        console.log('NGUC Device afterOrderEnrichmentConfigurationAdd', component.name, configuration, orderEnrichmentConfiguration);
        await Utils.initializeGenericOEConfigs(NEXTGENMOB_COMPONENT_NAMES.solutionName);
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }
        return Promise.resolve(true);
    }

    // Arinjay
    window.document.addEventListener('OrderEnrichmentTabLoaded', async function(e){
		let solution = await CS.SM.getActiveSolution();
		if(solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname) || solution.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription)){
			console.log('afterOrderEnrichmentTabLoaded: ', e.detail.configurationGuid, e.detail.orderEnrichment.name);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, '');
		}
		return Promise.resolve(true);
	});
            
                
    //added by shubhi
    NextGenMobPlugin.afterConfigurationAddedToMacBasket = async function (componentName, configuration) {
        if (basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }
		NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
        NextGenMobHelper.checkConfigSubsStatusonaddtoMac(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice,'',configuration);
		NextGenMobHelper.checkConfigSubsStatusonaddtoMac(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan,'',configuration);
        await RedemptionUtilityCommon.updateRedeemFundonAddtoMac(componentName, configuration);
		//EDGE-164350
		 if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
			await CommonUtills.getChildServicesMobileDeviceCare();
		} 
		
        if (basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }
        await NextGenMobHelper.HideShowAttributeLstOnSaveNOnMac(componentName,NGDListOfLists,configuration);
        //await NextGenMobHelper.UpdateDataFeatureAttributesonMac(componentName,configuration);
        await RedemptionUtilityCommon.updateRedeemFundonAddtoMac(componentName, configuration);
        
        return Promise.resolve(true);
    }
	//added by shubhi
	NextGenMobPlugin.afterSolutionDelete = function (solution) {
            if(window.totalRedemptions>0)
                RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
	}
	NextGenMobPlugin.afterConfigurationDelete = function (solution) {
            if(window.totalRedemptions>0)
                RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-169593
	}
}

//Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt || End

//Arinjay JSUpgrade
async function saveSolutionNxtGenMob(){
    if (executeSaveNGM){
        executeSaveNGM = false;
        allowSaveNGM = true;
		let solution = await CS.SM.getActiveSolution();       
		
	if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',false);
        }
        /* if(window.basketStage !== 'Contract Accepted' ){
			RedemptionUtils.checkConfigurationStatus();
        }
		if(window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft'){		
			await NextGenMobHelper.DeviceAndPlanCount();
		} */
	
        //await NextGenMobHelper.updateSolutionNameNGD(NEXTGENMOB_COMPONENT_NAMES.solutionname,DEFAULTSOLUTIONNAMENGD);
        //await NextGenMobHelper.inValidateDeviceCareConfigOnEligibilityLoad(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
        
        //let currentBasket =  await CS.SM.getActiveBasket(); 
		//currentBasket.saveSolution(solution);
        //await currentBasket.saveSolution(solution.id);
        //await CS.SM.saveSolution();    
        if (window.basketStage === 'Contract Accepted'){
            solution.lock('Commercial',true);
        }   
    }
    return Promise.resolve(true);
}

//Added this method as part of EDGE_150065
function NextGenMob_processMessagesFromIFrame() {
    if (!communitySiteId_NGEM) {
        return;
    }
    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var childWindow = sessionStorage.getItem("childWindow");
    if (childWindow) {
        childWindow.postMessage('Hey', window.origin);
    }
    var message = {};
    if (data) {
        message['data'] = JSON.parse(data);
        NextGenMob_handleIframeMessage(message);
    }
    if (close) {
        message['data'] = close;
        NextGenMob_handleIframeMessage(message);
    }
}

// Added this method as part of EDGE_150065
async function NextGenMob_handleIframeMessage(e){
    console.log('handleIframeMessage from pricing:', e);
    var message = {};
    message = e['data'];
    message = message['data'];
    //Edge-143527 start
    //added by shubhi for EDGE-121376 start /////
    if (e.data && e.data['caller'] && e.data['command']) {
        if (e.data['caller'] && (e.data['caller'] !== 'Device')) {
            return;
        }
        else if(e.data['command'] === 'pageLoad'+callerName_NG_Device &&  e.data['data']===solutionID){
             await pricingUtils.postMessageToPricing(callerName_NG_Device,solutionID,IsDiscountCheckNeeded_ngdevice,IsRedeemFundCheckNeeded_ngdevice); // EDGE-148662 shubhi
        }
        else if (e.data['command'] === 'StockCheck' && e.data['data'] === solutionID) { //EDGE-146972--Get the Device details for Stock Check before validate and Save as well
            await stockcheckUtils.postMessageToStockCheck(callerName_NG_Device, solutionID)
        }
		else {
            await pricingUtils.handleIframeDiscountGeneric(e.data['command'], e.data['data'], e.data['caller'],e.data['IsDiscountCheckAttr'],e.data['IsRedeemFundCheckAttr'],e.data['ApplicableGuid']); // EDGE-148662 shubhi
        }
    }
}