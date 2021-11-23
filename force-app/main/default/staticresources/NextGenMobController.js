/*******************************************************************************************************************************************
Sr.No.		Author 			Date			Sprint   		 Story number		Description
1.			Aman Soni		3-June-2020		20.08(New JS)	 EDGE-148729		Next Generation Mobility Controller JS
2.			Laxmi Rahate	5-June-2020		20.09			 EDGE-150795		Enabling Order Enrichment
3.          Shubhi			8-June-2020		20.08			 EDGE-148662		Enabling one fund and POS
4.			Ankit			26-june-2020	20.09			 EDGE-148733		Enabling Device Id on MACD
5.      	Shubhi			26-Jun-2020		20.09			 Edge-149830 		Redemption on device and devicecare
6.     		Aman Soni		23-June-2020	20.09		  	 EDGE-148667		Invoked inValidateDeviceCareConfigOnEligibility,UpdateChildFromParentAtt
7			Laxmi Rahate	30-Jun-2020		20.09			 EDGE-154021 		Handling OE for MAC and Cancel
8.			Laxmi Rahate	16-Jul-2020		20.10			 EDGE-154663		Method call to save OE details on PC
9.          Arinjay         20-Jul-20202    20.10            EDGE-164211        Spring 20 Upgrade
10.         Aman Soni		20-July-2020	20.10			 EDGE-154026 	    Added Code for Next Gen Plan
11.			Laxmi Rahate	22-July-2020    20.10			 EDGE-154663		Added method call to set value for INT ROAM on PC
12.         Gnana           22-July-2020    20.10            EDGE-155181        Extened EDGE-154663 code to support OE for Next Gen EM Plan
13			Laxmi Rahate 	30-July-2020    20.10			 EDGE-154680		MAC for Mobility Features
14. 		Gnana			31-July-2020	20.10			 EDGE-155182		Modifed to support MAC for Next Gen EM Plan OE
15     		Ankit/Shubhi/aditya/aman  25/08/2020   20.11     					post upgrade js upliftment
16      	Shubhi/samish   28-july-2020    20.12           EDGE-165013
17.     	Shubhi/Hitesh   28.July.2020    20.12           EDGE-157919,EDGE-157747,EDGE-157745
18.     	Shubhi          28.July.2020    20.12           EDGE-157797			(Ir Month Pass)
19.     	Gnana           31-Aug-2020     20.12           EDGE-154688 		(NGEM Plan Cancel)
20.    		Aman Soni     	31-Aug-2020    	20.12       	EDGE-157745 		DefaultMsgBank,DefaultBDD
20.    		Aman Soni     	31-Aug-2020    	20.12       	EDGE-160039 		RoundingOffAttribute
21.         shubhi          05-09-2020      20.12           EDGE-160037         addonmac 
22.          Aarathi/Manish  04-09-2020      20.12           EDGE-164351         Apple Care Cancellation
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/
console.log('::::::: Next Generation Mobility controller resource ::::::');
var mainCompName;
var compName;
var basketType = '';
var NGDListOfLists = [];

//Added NGDHideShowOnChangeSolutionDeviceL12,NGDHideShowOnChangeSolutionDeviceL13 as part of EDGE-148733 by Ankit || Added nextGenPlan by Aman Soni for EDGE-154026 || Added NGEMPlanHideShowAttsInMACL18, NGEMPlanHideShowAttsInMACL19 by Aman Soni for EDGE-154238
var NXTGENCON_COMPONENT_NAMES = {
	nxtGenMainSol: 'Adaptive Mobility', //EDGE-165013 added by shubhi 
	nextGenDevice: 'Device',
	mobDeviceCare: 'Mobile Device Care',
	nextGenPlan:'Enterprise Mobility',
	dataFeatures:'Data Features',
	internationalDirectDial:'International Direct Dial',
	messageBank:'Message Bank',
	NGDEmptyAttOnDevType: ['MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'ManufacturerString', 'ModelString', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnManfacture: ['MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'ModelString', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnModel: ['MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnColor: ['ContractTerm', 'PaymentTypeString', 'ContractTermString'],
	MDCEmptyAttOnPlan: ['DeviceCarePaymentTypeLookup'],
	NGEMPlanEmptyAttOnPlanType: ['Select Plan'],
	NGDEmptyAttOnPayType: ['ContractTerm', 'ContractTermString'],
	NGEMEmptyAttIRonPlan: ['IR_MonthPass','IR_MonthPassRC','IR_MonthPassRC Inc GST'],
	NGDRoundOffAttribute: ['OC', 'RC', 'OneOffChargeGST', 'InstalmentChargeIncGST'],
	NGDHideShowOnPayTypeHRepL0: ['OneOffChargeGST', 'OC', 'TotalFundAvailable', 'RedeemFund'],
	NGDHideShowOnPayTypePurcL1: ['RC', 'InstalmentChargeIncGST'],
	NGDHideSpaceAttributesS2L2: ['Space2'],
	NGDHideSpaceAttributesS35467L3: ['Space3', 'Space5', 'Space4', 'Space6', 'Space7'],
	NGDHideSpaceAttributesS2345L4: ['Space2', 'Space3', 'Space4', 'Space5', 'Space6', 'Space7'],
	NGDHideShowOnContractTermL5: ['ContractTerm'],
	NGDHideShowOnDeviceEnrollmentL6: ['DeviceEnrollment'],
	NGDHideShowOnTaxTreatmentL7: ['OneOffChargeGST', 'OC', 'TotalFundAvailable', 'RedeemFund', 'RC', 'InstalmentChargeIncGST', 'DeviceEnrollment'],
	NGDHideShowOnTaxTreatmentL8: ['OneOffChargeGST', 'OC'],
	NGDHideShowOnChangeSolutionMainL9: ['ChangeType', 'Marketable Offer'],
	NGDHideShowOnChangeSolutionDeviceL10: ['ChangeType'],
	NGDHideShowOnChangeSolutionDeviceL11: ['Device Type', 'MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeString'],
	NGDHideShowOnChangeSolutionDeviceL12: ['DeviceID', 'Space9', 'Space10', 'Space11'],
	NGDHideShowOnChangeSolutionDeviceL13: ['DeviceID', 'ContractTerm', 'Space10', 'Space11'],
	NGDHideShowOnChangeSolutionDeviceL14: ['DeviceCarePlanLookup', 'DeviceCarePaymentTypeLookup', 'RedeemFund'],
	NGDHideShowOnChangeSolutionDeviceL15: ['RedeemFund', 'TotalFundAvailable', 'DeviceEnrollment'],
	NGDHideShowOnChangeSolutionDeviceL16: ['Space3', 'Space2', 'Space12', 'EarlyTerminationCharge', 'EarlyTerminationChargeIncGST', 'TotalFundAvailable'],
	NGDHideShowOnChangeSolutionDeviceL17: ['RedeemFund','DisconnectionDate','CancellationReason'],
	NGEMPlanHideShowAttsInMACL18: ['ChangeType','SelectPlanType','Space1','Space2','Space3','Space4'],
	NGEMPlanHideShowAttsIRonPlan19: ['IR_MonthPassRC','IR_MonthPassRC Inc GST'],//EDGE-157797
	EmptyIddAttListonPlanChange:['InternationalDirectDial','IDD ChargeLookup'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyMBAttListonPlanChange:['MessageBank'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyDFAttListonPlanChange:['UnshapeUserChargeLookup'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyDFAttListonPlanTypeChangeWireless:['UnshapeUserRC','UnshapeUserRC_Inc_GST','UnshapeUserChargeLookup'],
	EmptyDFAttListonPlanTypeChangeHDBB:['AutoDataTopup','ADTChargeNRC','ADT Charge GST','ADTChargeLookup'],
    EmptyDataFeatUnshapeRCS:['UnshapeUserRC','UnshapeUserRC_Inc_GST'],//Added by Aman Soni for EDGE-166327
    NGEMPlanHideShowAttsCancel20: ['ChangeType','DisconnectionDate','CancellationReason'],//EDGE-154688
    NGEMPlanHideShowAttsCancel21: ['Space3','Space4'],//EDGE-154688
    NGEMPlanHideShowAttsCancel22: ['SelectPlanType','Select Plan','IR_MonthPass','IR_MonthPassRC Inc GST'],//EDGE-154688
    NGEMPlanHideShowAttsCancel23: ['DisconnectionDate','CancellationReason'],//EDGE-154688
	NGEMPlanHideShowAttsCancel24: ['IR_MonthPass'],//Added by Aman Soni for EDGE-157797
	NGEMPlanHideShowAttsCancel25: ['Select Plan'],
	NGEMPlanHideShowAttsCancel26: ['AutoDataTopup','ADTChargeNRC','ADT Charge GST'],
	NGEMPlanHideShowAttsCancel27: ['UnshapeUser','UnshapeUserRC','UnshapeUserRC_Inc_GST'],
	NGEMPlanHideShowAttsCancel28: ['Space2'],
	NGEMPlanHideShowAttsCancel29: ['Space1']
	

};

//Added NGDHideShowOnChangeSolutionDeviceL12,NGDHideShowOnChangeSolutionDeviceL13 as part of EDGE-148733 by Ankit
NGDListOfLists = [NXTGENCON_COMPONENT_NAMES.NGDHideShowOnPayTypeHRepL0, 
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnPayTypePurcL1,NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS2L2,
	NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS35467L3, NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS2345L4, 
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnContractTermL5, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnDeviceEnrollmentL6, 
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnTaxTreatmentL7, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnTaxTreatmentL8,
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionMainL9,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL10,
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL11,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL12,
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL13,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL14,
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL15,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL16,
	NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL17,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsInMACL18,
    NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsIRonPlan19,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel20,
    NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel21,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel22,
	NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel23,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel24,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel25,
	NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel26,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel27,
	NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel28,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel29]; // NGEMPlanHideShowAttsIRonPlan19 : EDGE-157797, NGEMPlanHideShowAttsCancel20 : EDGE-154688

var NextGenMobController = {

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterSolutionLoaded
	* Invoked When: when solution is loaded or when invoked after a Solution is set as Active
	* Parameters  : previousSolution, loadedSolution
	***********************************************************************************/
	// Arinjay JSUpgrade 
	AfterSolutionLoaded: async function (previousSolution, loadedSolution) {
		await Utils.loadSMOptions();
		if (loadedSolution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			let currentBasket =  await CS.SM.getActiveBasket(); 
			basketId = currentBasket.basketId;
			await NextGenMobHelper.getBasketData(basketId, NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				for (var comp of Object.values(loadedSolution.components)) {
					await Utils.updateImportConfigButtonVisibility();
				}
			}
			await NextGenMobHelper.MandateCompBasedOnOfferName();//Added by Aman Soni for EDGE-154026
			Utils.updateCustomButtonVisibilityForBasketStage();
			await Utils.addDefaultGenericOEConfigs(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);// EDGE-150795
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
			}
		}

		//Added by Aman Soni as a part of EDGE-148729 || Start
		if (loadedSolution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
			mainCompName = NXTGENCON_COMPONENT_NAMES.nxtGenMainSol;
			if (loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
				var updateMap = {};
				Object.values(loadedSolution.components).forEach((comp) => {
					if (comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenDevice)){
						compName = NXTGENCON_COMPONENT_NAMES.nextGenDevice;
					}
				}); //loadedSolution.components.forEach
			}
		}

		await NextGenMobHelper.updateConfigName_DeviceAllConfig(compName);		
		await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, compName, NGDListOfLists);
	    //await NextGenMobHelper.inValidateDeviceCareConfigOnEligibilityLoad(mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenDevice);//Invoked inValidateDeviceCareConfigOnEligibilityLoad as a part of EDGE-148667 by Aman 
		NextGenMobHelper.NGDDeviceEnrolmentOnLoadNSave(mainCompName, compName);
		NextGenMobHelper.UpdateChildFromParentAtt(mainCompName, compName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare);//Invoked UpdateChildFromParentAtt as a part of EDGE-148667 by Aman 
		NextGenMobHelper.updateDeviceIdOnConfig(compName);
		//EDGE-150795
		//Added by Aman Soni as a part of EDGE-148729 || End
		await NextGenMobHelper.UpdateRelatedConfigForChild();
		//await NextGenMobHelper.UpdateDataFeatureAttributesonMac();
		   
        if (window.BasketChange === 'Change Solution'&& window.basketStage !=='Contract Accepted'){
            await NextGenMobHelper.handleReloadinMacd();
            await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice, 'AfterSolutionLoaded',null);
			await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,'AfterSolutionLoaded',null);
			
			await NextGenMobHelper.updateISPOSReversalRequired();//EDGE-164351
        } 
                    
		await NextGenMobHelper.setNextGenEMTabsVisibility(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol,NXTGENCON_COMPONENT_NAMES.nextGenDevice);
		

	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterAttributeUpdated
	* Invoked When: invoked after an Attribute is updated
	* Parameters  : componentName, guid, attribute, oldValue, newValue
	***********************************************************************************/
	// Arinjay JSUpgrade
	AfterAttributeUpdated: async function (componentName, configuration, guid, attribute, oldValue, newValue) {
		var DeviceConfigId = '';
		var relatedGuid = '';
		var OldVal = oldValue;
		var newVal = newValue;
		
		let keys;
		var varConfig = '';
		let solution = await CS.SM.getActiveSolution();
		let component = await solution.getComponentByName(componentName);
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			mainCompName = NXTGENCON_COMPONENT_NAMES.nxtGenMainSol;
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name.includes(componentName)) {
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((config) => {
								if (config.guid === guid) {
									DeviceConfigId = config.guid;
									if (config.relatedProductList && config.relatedProductList.length > 0) {
										config.relatedProductList.forEach((relatedConfig) => {
											if (relatedConfig.guid) {
												relatedGuid = relatedConfig.guid;
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
		//Added by Aman Soni for EDGE-154028 || Start
	 	if(componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan){
			if(attribute.name === 'SelectPlanType'){
				await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGEMPlanEmptyAttOnPlanType);
				if(attribute.displayValue===NGEMPLans.Enterprise_Wireless){
					await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGEMEmptyAttIRonPlan);
					await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeWireless,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
				}
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);// added  for EDGE-157797 by shubhi
				
				//Added by Shubhi for EDGE-166327 || Start
				if(attribute.displayValue && attribute.displayValue!='' && attribute.displayValue!==NGEMPLans.Handheld){
					await NextGenMobHelper.autoDeleterelatedProductonPlanChange(attribute.displayValue,guid,component);
				}
				//Added by Shubhi for EDGE-166327 || End
				if(attribute.displayValue && attribute.displayValue!='' && attribute.displayValue===NGEMPLans.Mobile_Broadband){
					await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeHDBB,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
					await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
				}
				//Added by Aman Soni for EDGE-166327 || Start
				if(attribute.displayValue && attribute.displayValue!='' && attribute.displayValue===NGEMPLans.Handheld){					
					CommonUtills.addRelatedProductonConfigurationAdd(component, configuration,component.name,NEXTGENMOB_COMPONENT_NAMES.IDD,false,1);
					CommonUtills.addRelatedProductonConfigurationAdd(component, configuration,component.name,NEXTGENMOB_COMPONENT_NAMES.Message_Bank,false,1);
					CommonUtills.addRelatedProductonConfigurationAdd(component, configuration,component.name,NEXTGENMOB_COMPONENT_NAMES.Data_Features,false,1);
					await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeHDBB,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
					await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
				}				
				//Added by Aman Soni for EDGE-166327 || End				
			}
			       await NextGenMobHelper.Update_UnshapeUser_OnDataFeat(guid);
			if(attribute.name === 'Select Plan'){
                var planValue = newValue;
                var config_p= await component.getConfiguration(guid);
                if(config_p.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
                    await NextGenMobHelper.UpdatePlanAllowance(guid, planValue);
                
                    //EDGE-157919,EDGE-157747,EDGE-157745,160037shubhi start------------
                    await NextGenMobHelper.updatechildAttfromParent('Select Plan',attribute.value,false,false,guid,componentName);
                    if(configuration && !configuration.replacedConfigId){
                        await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyIddAttListonPlanChange,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.IDD);
                        await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyMBAttListonPlanChange,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Message_Bank);
                        await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanChange,guid,componentName,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
						NextGenMobHelper.defaultAddonsonPlanChange(planValue,guid,component,configuration);
					}else if(configuration && configuration.replacedConfigId){
                        NextGenMobHelper.autoUpdateAddonAfterPlanChangeinMac(planValue,guid,component,NEXTGENMOB_COMPONENT_NAMES.IDD,'InternationalDirectDial','DMCAT_RecurringCharge_001258');
						NextGenMobHelper.autoUpdatedatafeaturesonPlanChangeinMac(planValue,guid,component,NEXTGENMOB_COMPONENT_NAMES.Data_Features);
						NextGenMobHelper.autoUpdateAddonAfterPlanChangeinMac(planValue,guid,component,NEXTGENMOB_COMPONENT_NAMES.Message_Bank,'MessageBankAddonAssoc','DMCAT_RecurringCharge_001240');
                    }
					await NextGenMobHelper.CalcforNGEMPlanCompAtts(mainCompName,componentName);
                }                
				//EDGE-157919,EDGE-157747,EDGE-157745,160037 shubhi end---------------				
			 
		    }
			if(attribute.name === 'SelectPlanName' || attribute.name === 'PlanTypeString'){
				await NextGenMobHelper.updateConfigNameNGEMPlan(componentName, guid);
			}
			if(attribute.name === 'SelectPlanType' || attribute.name === 'RC'){
				await NextGenMobHelper.CalcforNGEMPlanCompAtts(mainCompName,componentName);
            }
            // Added as part of EDGE-154688
            if (attribute.name === 'ChangeType' && (newValue === 'Cancel' || newValue === 'Modify')) {
                    await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
            }
			
			//Added by Aman Soni for EDGE-160039 || Start
			if(attribute.name === 'IDD Charge GST'){
                await NextGenMobHelper.RoundingOffAttribute(guid,mainCompName,componentName,NXTGENCON_COMPONENT_NAMES.internationalDirectDial,'IDD Charge GST');
            }
			if(attribute.name === 'MessageBank RC (Inc. GST)'){
                await NextGenMobHelper.RoundingOffAttribute(guid,mainCompName,componentName,NXTGENCON_COMPONENT_NAMES.messageBank,'MessageBank RC (Inc. GST)');
            }
			if(attribute.name === 'UnshapeUserRC_Inc_GST'){
                await NextGenMobHelper.RoundingOffAttribute(guid,mainCompName,componentName,NXTGENCON_COMPONENT_NAMES.dataFeatures,'UnshapeUserRC_Inc_GST');
            }
			if(attribute.name === 'BDD Charge GST'){
                await NextGenMobHelper.RoundingOffAttribute(guid,mainCompName,componentName,NXTGENCON_COMPONENT_NAMES.dataFeatures,'BDD Charge GST');
            }
			if(attribute.name === 'ADT Charge GST'){
                await NextGenMobHelper.RoundingOffAttribute(guid,mainCompName,componentName,NXTGENCON_COMPONENT_NAMES.dataFeatures,'ADT Charge GST');
            }
			//Added by Aman Soni for EDGE-160039 || End
		} 
		//Added by Aman Soni for EDGE-154028 || End
		
		if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
			if (attribute.name === 'Device Type') {
				await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnDevType);
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
			}
			if (attribute.name === 'MobileHandsetManufacturer') {
				await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnManfacture);
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
			}
			if (attribute.name === 'MobileHandsetModel') {
				await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnModel);
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
			}
			//Invoked EmptyAttributeLst as a part of EDGE-148667 by Aman Soni
			if (attribute.name === 'MobileHandsetColour') {
				await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnColor);
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
			}
			//Invoked UpdateChildFromParentAtt as a part of EDGE-148667 by Aman Soni
			if (attribute.name === 'DeviceSKU') {
				NextGenMobHelper.UpdateChildFromParentAtt(mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare);
			}
			if (attribute.name === 'PaymentTypeString') {
				NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnPayType);
				RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //Edge-149830
				await NextGenMobHelper.updateConfigName_DeviceperConfig(componentName, guid); // dynamic name shubhi
				if (attribute.value === 'Hardware Repayment') {
					await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
				}
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
			}
			if (attribute.name === 'PaymentTypeString' || attribute.name === 'ContractTermString') {
				await NextGenMobHelper.CalculationforDeviceCompAtts(mainCompName, componentName);
			}
			if (attribute.name === 'PaymentTypeString' || attribute.name === 'DeviceCarePlanLookup') {
				await NextGenMobHelper.CalcForDeviceCareCompAtts(guid, mainCompName, componentName);
			}
			if (attribute.name === 'ChangeType' && newValue === 'Cancel') {
				await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, componentName, NGDListOfLists);
             RedemptionUtilityCommon.updateTotalOneFundBalance(guid,componentName); //Edge-149830
			}
			if (attribute.name === 'DisconnectionDate' || attribute.name === 'RedeemFund' || attribute.name === 'EarlyTerminationCharge') {
				NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
			}
			if (attribute.name === 'InContractDeviceEnrollEligibility') {
				await NextGenMobHelper.NGDDeviceEnrolmentOnAttUpdate(guid, mainCompName, componentName);
			}
			//Invoked inValidateDeviceCareConfigOnEligibility as a part of EDGE-148667 by Aman Soni
			if (attribute.name === 'DeviceCareEligibility') {
				await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedGuid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
			}
			if (attribute.name === 'RedeemFund') {
				await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, newValue); //Edge-149830
				await RedemptionUtilityCommon.calculateBasketRedemption(); //Edge-149830
				if (newValue >= 0)
					await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
			}
        }
        
		//Added by Aman Soni for EDGE-154026 || Start 
		if(componentName === NXTGENCON_COMPONENT_NAMES.nxtGenMainSol){
			if(attribute.name === 'Marketable Offer'){
				await NextGenMobHelper.MandateCompBasedOnOfferName();
				if(window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft'){
				await NextGenMobHelper.InValidateNGEMPlanOnOfferChange(guid);
				await NextGenMobHelper.DeviceAndPlanCount();
				}
			}
		}		
		
		if (attribute.name === 'DeviceCarePlanLookup'){
			await NextGenMobHelper.EmptyRelProdAttLst(guid, mainCompName, componentName, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare, NXTGENCON_COMPONENT_NAMES.MDCEmptyAttOnPlan);
			await NextGenMobHelper.validateDeviceConfig(guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
		}
		
		if(attribute.name === 'UnshapeUser' && attribute.value === false){
		 await NextGenMobHelper.EmptyRelProdAttLst(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.dataFeatures, NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS);
		}
		//Added by Aman Soni for EDGE-154026 || End
		
		//Added by Aman Soni for EDGE-157745 || Start
		if(attribute.name === 'DefaultMsgBankSelection'){
			await NextGenMobHelper.DefaultMsgBank();
		}
		if(attribute.name === 'DefaultBDDSelection'){
			await NextGenMobHelper.DefaultBDD();
		}
		//Added by Aman Soni for EDGE-157745 || End
		
    //Added as part of EDGE-155181
		var configGUID, schemaName,relConfigIDCall,relConfigIDData,changeTypeVal;
		if(componentName === 'Customer requested Dates' || componentName === 'Delivery details'  ||  componentName === 'Enterprise Mobility Features'){
			configGUID = await OE.getConfigGuidForOEGUID (guid);
			schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
			console.log ( 'schemaName ----------------------', schemaName);
			if ( schemaName.includes("Device")	 )
			{
				changeTypeVal = await NextGenMobHelper.getAttributeValue ('ChangeType','Device',configGUID ) ; 

			}else{		
			changeTypeVal = await NextGenMobHelper.getAttributeValue ('ChangeType',schemaName,configGUID ) ; 
			}
			//phone = await NextGenMobHelper.getAttributeValue ('Phone','Enterprise Mobility',configGUID ) ; 
			if ( schemaName.includes("NextGenMobileDevice")){
			comp = 	await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice); 
			comp.lock('Commercial', false); // Added by laxmi to address lock issue
		
			}else
			if ( schemaName.includes("Enterprise")){
				comp = 	await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan); 
				comp.lock('Commercial', false); // Added by laxmi to address lock issue
				

			}	

			if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			
	            for (var j=0; j< Object.values(comp.schema.configurations).length; j++) {
				var config = Object.values(comp.schema.configurations)[j];							
				if (config.guid === configGUID) {
						varConfig = config;
						 break;						
					}
				}
			}

		}
		if (componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && newValue !== 0) {
		var notBeforeCRDValidation = new Date();
		notBeforeCRDValidation.setHours(0, 0, 0, 0);
		notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);	

		if (Utils.formatDate(newValue) < notBeforeCRDValidation )
		{
			//Utils.markOEConfigurationInvalid(guid, 'Not Before CRD cannot be a past Date');
			CS.SM.displayMessage('Not Before CRD cannot be a past Date');
			newValue = ''; // Blanking out the value when its past Date
			varConfig.status = false;
			varConfig.statusMessage = 'Not Before CRD cannot be a past Date.';//EDGE-154502			
			
		}else{
			varConfig.status = true;
			varConfig.statusMessage = '';//EDGE-154502	
		}
		//notBeforeCRDAttVal = Utils.formatDate(newValue);
		notBeforeCRDAttVal = newValue;
		console.log('Value of preferredCRD ------------------ ', preferredCRD + '       notBeforeCRD  ' + notBeforeCRD);
		let updateConfigMap = {};
		updateConfigMap[configGUID] = [{
		name: 'Not Before CRD',
		//value: {
			value: newValue,
			displayValue: newValue
		//}														
        }];
        
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMap, true); // Modified as part of EDGE-155181
		keys = Object.keys(updateConfigMap);
		
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
		}
		
		let updateMapNew = {};
		let updateConfigMapPC = {};
		
        preferredCRDAttVal = await Utils.getAttributeValue('Preferred CRD', guid);
		
		if (preferredCRDAttVal === '' || preferredCRDAttVal < notBeforeCRDAttVal || preferredCRDAttVal === '0' || preferredCRDAttVal === 0 || preferredCRDAttVal === NaN) {
			if (!updateMapNew[guid])
				updateMapNew[guid] = [];			
				updateMapNew[guid].push({
				name: 'Preferred CRD',
				showInUi: true,
				displayValue: newValue,
				value: newValue
			});		
			//CS.SM.updateOEConfigurationAttribute(schemaName, configGUID, updateMapNew, true); // Modified as part of EDGE-155181
			keys = Object.keys(updateMapNew);
			for(let h=0; h< keys.length;h++){
				await comp.updateOrderEnrichmentConfigurationAttribute(configGUID,keys[h],updateMapNew[keys[h]],true)
			}			
			
			
			updateConfigMapPC[configGUID] = [{
			name: 'Preferred CRD',
			//value: {
				value: notBeforeCRDAttVal,
				displayValue: notBeforeCRDAttVal
			//}														
			}];		
			//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPC, true);
			keys = Object.keys(updateConfigMapPC);
			for (let i = 0; i < keys.length; i++) {
				await comp.updateConfigurationAttribute(keys[i], updateConfigMapPC[keys[i]], true); 
			}			
		}
	}
	if (componentName === 'Customer requested Dates' && attribute.name === 'Preferred CRD' && newValue !== 0) {
		let updateConfigMapPref = {};
		updateConfigMapPref[configGUID] = [{
		name: 'Preferred CRD',
		//value: {
			value: newValue,
			displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true); // Modified as part of EDGE-155181
		keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}

	}
	
	if (componentName === 'Customer requested Dates' && attribute.name === 'Notes' && newValue !== 0) {
		let updateConfigMapPref = {};
		updateConfigMapPref[configGUID] = [{
		name: 'Notes',
		//value: {
			value: newValue,
			displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true); // Modified as part of EDGE-155181
		keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
	}
	
	if (componentName === 'Delivery details' && attribute.name === 'DeliveryContact' && newValue !== 0 && newValue !== '' && changeTypeVal === 'New') { 
	// Added Change Type as part of EDGE-155182
		let updateConfigMapPref = {};
		updateConfigMapPref[configGUID] = [{
		name: 'SiteDeliveryContact',
		//value: {
			value: newValue,
			displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true); // Modified as part of EDGE-155181
		keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
		
        phone = await Utils.getAttributeValue('Phone', guid);
		email = await Utils.getAttributeValue('Email', guid);
	
		if (phone ===  'undefined' || phone ===  undefined  || phone ===  '' || email ==='' || email ===  undefined || email ===  '')
		{
			//Utils.markOEConfigurationInvalid(guid, 'Not Before CRD cannot be a past Date');
			CS.SM.displayMessage('Selected delivery contact does not have email id or phone number; Please update the contact details');
			newValue = ''; // Blanking out the value when its past Date
			varConfig.status = false;
			varConfig.statusMessage = 'Selected delivery contact does not have email id or phone number; Please update the contact details';//EDGE-154502			
			
		}
		else{
			varConfig.status = true;
			varConfig.statusMessage = '';//EDGE-154502			
		}
		
	}	
	
	if (componentName === 'Delivery details' && attribute.name === 'DeliveryAddress' && newValue !== 0 && changeTypeVal === 'New') { 
	// Added Change Type as part of EDGE-155182
		let updateConfigMapPref = {};
		updateConfigMapPref[configGUID] = [{
		name: 'SiteDeliveryAddress',
		//value: {
			value: newValue,
			displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true); // Modified as part of EDGE-155181
		keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
	}
	
		// Added by laxmi for - EDGE-154663
		if (componentName === 'Enterprise Mobility Features' && attribute.name === 'InternationalRoaming' && newValue !== 0 && changeTypeVal === 'New') {
		let updateConfigMapPref = {};
		var intROAMVAl = "";
		if ( newValue === true )
		{
			intROAMVAl = "true";
		} else
		{
			intROAMVAl = "false";			
		}
		updateConfigMapPref[configGUID] = [{
		name: 'INTROAM',
		//value: {
			value: intROAMVAl,
			displayValue: intROAMVAl
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true);
		keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
	
	} //EDGE-154663 Changes END
		if (componentName === 'Enterprise Mobility Features' && attribute.name === 'mmsEnabled' && newValue !== 0 && changeTypeVal === 'New') {
		relConfigIDCall = await OE.getRelatedConfigID (configGUID,'International Direct Dial' );		
		if (relConfigIDCall !==  undefined && relConfigIDCall !== 'undefined'){

		console.log ('mmsEnabled ----------------- + Config ID' , newValue + relConfigIDCall);
		let updateConfigMapPref = {};
		var mmsEnabled = "";
		if ( newValue === true )
		{
			mmsEnabled = "true";
		} else
		{
			mmsEnabled = "false";
		}
		updateConfigMapPref[relConfigIDCall] = [{
		name: 'MMS Eligibility',
		//value: {
			value: mmsEnabled,
			//displayValue: mmsEnabled
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true);
		let keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
		}
	} //EDGE-154663 Changes END
	
		if (componentName === 'Enterprise Mobility Features' && attribute.name === 'msgRestriction' && newValue !== 0 && changeTypeVal === 'New') {
		relConfigIDCall = await OE.getRelatedConfigID (configGUID,'International Direct Dial' ); // Laxmi changed the name of the schema as part latest changes
		if (relConfigIDCall !==  undefined && relConfigIDCall !== 'undefined'){
		
		console.log ('msgRestriction ----------------- + Config ID' , newValue );
		let updateConfigMapPref = {};

		updateConfigMapPref[relConfigIDCall] = [{
		name: 'Message Restriction',
		//value: {
			value: newValue,
			//displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true);
		let keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}		
		}
	}
		if (componentName === 'Enterprise Mobility Features' && attribute.name === 'callRestriction' && newValue !== 0 && changeTypeVal === 'New') {
        configGUID = await OE.getConfigGuidForOEGUID (guid);
        schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
		relConfigIDCall = await OE.getRelatedConfigID (configGUID,'International Direct Dial' ); // Laxmi changed the name of the schema as part latest changes
		if (relConfigIDCall !==  undefined && relConfigIDCall !== 'undefined'){

		console.log ('callRestriction ----------------- + Config ID' , newValue );
		let updateConfigMapPref = {};

		updateConfigMapPref[relConfigIDCall] = [{
		name: 'Call Restriction',
		//value: {
			value: newValue,
			//displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true);
		let keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}
		}
	}
	
		if ( componentName === 'Enterprise Mobility Features' && attribute.name === 'dataBarring' && newValue !== 0 && changeTypeVal === 'New') {
		relConfigIDData = await OE.getRelatedConfigID (configGUID,'Data Features' ); // Laxmi changed the name of the schema as part latest changes
		if (relConfigIDCall !==  undefined && relConfigIDCall !== 'undefined'){

		console.log ('dataBarring ----------------- + Config ID' , newValue + relConfigIDData);
		let updateConfigMapPref = {};
		updateConfigMapPref[relConfigIDData] = [{
		name: 'Data Barring',
		//value: {
			value: newValue,
			//displayValue: newValue
		//}														
		}];
		//CS.SM.updateConfigurationAttribute(schemaName, updateConfigMapPref, true);
		let keys = Object.keys(updateConfigMapPref);
		for (let i = 0; i < keys.length; i++) {
			await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true); 
		}		
		}
	}
		window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
		//EDGE-150795 END
		if (attribute.name === 'ChangeType' && newValue !== 'Active' && newValue !== 'New' ) {
			await NextGenMobHelper.ChangeOptionValueNGEMPlan(guid);
		}
	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : BeforeSave
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	BeforeSave: function () {

	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterSave
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	//Arinjay JSUpgrade
	AfterSave: async function (solution1, configurationsProcessed, saveOnlyAttachment) {
		//Added by Aman Soni as a part of EDGE-148729 || Start
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			mainCompName = NXTGENCON_COMPONENT_NAMES.nxtGenMainSol;
			if (solution.components && Object.values(solution.components).length > 0) {
				Object.values(solution.components).forEach((comp) => {
					if (comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenDevice)) {
						compName = NXTGENCON_COMPONENT_NAMES.nextGenDevice;
					}
				});
			}
		}
		await NextGenMobHelper.updateConfigName_DeviceAllConfig(compName);
		//Added by Aman Soni as a part of EDGE-148729 || End
		if (window.basketStage === 'Commercial Configuration') {
        //EDGE-148662
        RedemptionUtils.calculateBasketRedemption();
		}
		//Added by Aman Soni as a part of EDGE-148729 || Start
		if(window.basketStage !=='Contract Accepted'){
			await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice,'AfterSave',null);
			await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,'AfterSave',null);
        }
        await NextGenMobHelper.updateISPOSReversalRequired();//EDGE-164351
		await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(mainCompName, compName, NGDListOfLists);
		await NextGenMobHelper.NGDDeviceEnrolmentOnLoadNSave(mainCompName, compName);
		await NextGenMobHelper.setNextGenEMTabsVisibility(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice); // Added to fix issue OE was editable after Save
		//Added by Aman Soni as a part of EDGE-148729 || End
	},
	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterConfigurationAdd
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	AfterConfigurationAdd: function (componentName, configuration) {

	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterConfigurationDelete
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	AfterConfigurationDelete: function () {

	},
}