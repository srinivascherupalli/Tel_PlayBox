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
10.         Gnana               28-July-2020    20.10           EDGE-155181     Added Method call to check Manadatory
11.         Shubhi Vijayvergia	21.08.2020		//added by shubhi for EDGE-169593 -redemptions fix for em,nguc and dop Paremeters Values for EM Plan
12     		Ankit/Shubhi/aditya/aman  25/08/2020   20.11     post upgrade js upliftment
16      	Shubhi /samish          28-july-2020    20.12          //EDGE-165013
17.     	Shubhi/Hitesh        	28.July.2020    20.12           EDGE-157919,EDGE-157747,EDGE-157745
18.     	Shubhi               	28.July.2020    20.12       	EDGE-157797(Ir Month Pass)
19.    		Aman Soni     		31-Aug-2020    	20.12       	EDGE-166327 	Added beforeRelatedProductAdd,beforeConfigurationDelete hook
20.    		Manish/Vishal            07-Sept-2020    20.12           EDGE-168275/EDGE-164350    As a Sales Enterprise, Partner, R2R user when I am doing a Device Payout within Repayment period then system should force cancellation of associated Device Care if it is within 30 days Trial period
21.			Hitesh					17-Sept-2020	20.13			EDGE -174694 - to add IR month pass as related product and remove it as attribute
21.         Gunjan Aswani  23-09-2020      20.12           JS Refactoring
22.			Aman Soni	  		24/09/2020		20.13			 EDGE-164619 	Added by Aman Soni for port out reversal	
23.    		Shubhi               06/10/2020		20.14			//Edge-172970
24.			Aman Soni			10-Oct-2020		20.14			EDGE-182492 
25      Vijay Kumar H R			08-Oct-2020										Added the PRE logic to all the aappropriate hooks and Hiding the pricing attributes from the UI.
26.			Aman Soni			13-Oct-2020		20.14			EDGE-173469 
27			Laxmi Rahate		15-Oct-2020		20.14			 EDGE-174219 OE Framework Changes
28         Shweta Khandelwal     4/11/2020         		EDGE-185652	
29.         shubhi v             28/12/2020             Edge-185856
30.         shubhi v             4-01-2020		21.01	add to mac fix		 
31.			Shubhi v 			 5-01-2020		21.01	INC000094689212
32. 		Jagadeswary			 8-01-2021		21.01	EDGE-197534
33.         Shweta Khandelwal    12-01-2021     21.01    EDGE-196714
34.         Ankit                13/01/2020		21.01		EDGE-197555
35. 		shubhi			     7/01/2021		21.01   EDGE-170016
36. 		Aman Soni			 25/01/2021		21.02   EDGE-191077		Tranfer Hardware UX Enhancements
37.         Krunal Taak          29/01/2021     21.02   DPG-4184 - OE Changes for Accessory
38.         Krunal Taak          08/02/2021     21.02   DPG-4250 - Added nextGenAccessory condition for DeviceAndPlanCount execution 

39.			Mahima Gandhe	   05/02/2021		21.02	 DPG- 4154, 4071, Added Mobile Device care for Accessory
39.			Shubhi				 9/02/2021		21.02		EDGE-201407
40.			Aman Soni			 17/02/2021		21.03		EDGE-203220
41.	    	Hitesh Gandhi		 01/03/2021		21.03		EDGE-200723 handelled update logic for SimAvailabilityType attribute.
42.         Krunal Taak          05/03/2021     21.03       INC000095203350 
43.			Mahima Gandhe		 26/02/2021		            DPG-3889, 4083
44.         Shubhi V			 10/03/2021 	21.04		EDGE-204313
45.			Shubhi V			 22/03/2021 	21.04		EDGE-210493
46.			Aman Soni       	 12/04/2021     21.05       EDGE-207355
47.      	Shubhi V           	 27/04/2021     21.06       EDGE-212647
48. 		Ila A. Verma		 15/04/2021  	21.05		DPG-4795 : Handled validation for Accelerator bolt on
49.			Krunal Taak			 21/05/2021     21.07       DPG-4529 : Handle UI validations for Data Custom
50.         Jenish Shingala      03/06/2021     21.08       DPG-5297 : APN |  P2O - Capture grade of service
51.         Antun Bartonicek     01/06/2021     21.05       EDGE-198536: Performance improvements
52.         Monali Mukherjee     01/07/2021     21.09       DPG-5731
53.			Shubhi V			 12/07/2021		21.10		DIGI-1853
54.         Arinjay Singh        29.07.2021     21.09       EDGE-221460
55.         Sayantan Halder      13/08/2021     21.11       EDGE-12691,12706: To have active solution after each iteration
56.			Shubhi V			 5/10/2021		21.14		DIGI-16898 carry forward discounts
57.         Krunal Taak          13/10/2021     21.15       DIGI-26615 - Handling Promotions Special Scenario
58.			Vasu Sankar			 13/10/2021		21.13		Toggeling New feature of order Enrichment
59.			Don Navarro			22/10/2021		21.14		DIGI-456 modified feature toggling approach for Order Enrichment
60.			Divakar Tangudu		28/10/2021		21.15		DIGI-25050 BDS Sync callout on MACD Cancel
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/

var NEXTGENMOB_COMPONENT_NAMES = {
	solutionname: "Adaptive Mobility", //EDGE-165013
	nextGenDevice: "Device",
	mobDeviceCare: "Mobile Device Care",
	nextGenPlan: "Enterprise Mobility", // Added by Aman Soni for EDGE-154026
	nextGenDevSchema: "NextGenMobileDevice", // Added by Aman Soni for EDGE-154026
	nextGenPlanSchema: "NGEMPlan", // Added by Aman Soni for EDGE-154026
	transitionDevice:"Transition Device",//Added by Aman Soni for EDGE-173469
    transitionAccessory: "Transition Accessory", //Added by Mahima/monali 3889, 4083
	planOfferId: "DMCAT_Offer_001233",
	deviceOffeId: "DMCAT_Offer_001231",
    IDD:'Calling & Messaging Features',//EDGE-157919,EDGE-157747,EDGE-157745 shubhi EDGE -174604 hitesh updated name
    Message_Bank:'Voicemail Features',//EDGE-157919,EDGE-157747,EDGE-157745 shubhi EDGE -174604 hitesh updated name 
    Data_Features:'Data Features',//EDGE-157919,EDGE-157747,EDGE-157745 shubhi
	IRMonthPass:'International Roaming Month Pass', // EDGE -174694 Hitesh
    nextGenAccessory:'Accessory', // DPG-3509-- Added by Mahima
	nextGenAccelerator:'Accelerator', //DPG-4795: Ila
	Data_Custom:'Data Custom', //DPG-4529 Krunal
	Telstra_One_Number:'Telstra One Number' //5731 Monali Krunal
};
var hasPortOutReversalPermission = false;//Added by Aman Soni for EDGE-164619
var allowRPDel = false;//Added by Aman Soni for EDGE-166327
var executeSaveNGM = false;
var allowSaveNGM = false;
var DEFAULTSOLUTIONNAMENGD = "Adaptive Mobility"; //EDGE-165013
let callerName_NG_Device = ""; // Added as part of EDGE_150065
let communitySiteId_NGEM = ""; // Added as part of EDGE_150065
var solutionName_NEXTGENMOB;
var accountId__NEXTGENMOB;
var solutionID;       
let IsDiscountCheckNeeded_ngdevice = false;
let IsRedeemFundCheckNeeded_ngdevice = false;
var configId; 
var BuffercountAcc = 0; // DPG-4795: Ila
// added  for EDGE-157797 by shubhi
var NGEMPLans={
	Handheld: "Handheld",
	Enterprise_Wireless: "Enterprise Wireless",
	Mobile_Broadband: "Mobile Broadband"
};
var relatedprodtobeautodeleted = ["Voicemail Features"];

var activeNGEMSolution = null;
var activeNGEMBasket = null;

if (CS.SM.registerPlugin) { 
	window.document.addEventListener("SolutionConsoleReady", async function () {
		await CS.SM.registerPlugin("Adaptive Mobility").then((NextGenMobPlugin) => {
                console.log("Plugin registered for Next Gen Mobility"); 
                NextGenMobPlugin_updatePlugin(NextGenMobPlugin); 
            }); 
    }); 
} 
NextGenMobPlugin_updatePlugin = async function NextGenMobPlugin_updatePlugin(NextGenMobPlugin) {
	window.document.addEventListener("SolutionSetActive", async function (e) {
		try {
			console.log("Inside Next Generation Mobility SolutionSetActive--->");
			Utils.updateImportConfigButtonVisibility();
			activeNGEMSolution = await CS.SM.getActiveSolution();
			//activeNGEMSolution = activeNGEMSolution == null ? await CS.SM.getActiveSolution() : activeNGEMSolution;
			let loadedSolution = await CS.SM.getActiveSolution();			
			if (loadedSolution.componentType && loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
				//EDGE-198536 Start: existing code moved inside active solution check
				window.addEventListener("message", NextGenMob_handleIframeMessage);
	            setInterval(NextGenMob_processMessagesFromIFrame, 500);
	            //setInterval(saveSolutionNxtGenMob, 500); //EDGE-198536 uncomment if actually needed, doesn't seem to do anything
			    Utils.updateImportConfigButtonVisibility();
                //EDGE-198536 End
				activeNGEMBasket = activeNGEMBasket == null ? await CS.SM.getActiveBasket() : activeNGEMBasket;
				//await NextGenMobHelper.getBasketData(basketId, NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);
				await CommonUtills.getBasketData(activeNGEMBasket);            	
				await CommonUtills.checkFeatureEligibility();
				//await NextGenMobHelper.getBasketData(basketId, NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);
				//Added by Aman Soni for EDGE-164619 || Start
				CommonUtills.unlockSolution(); //EDGE-201407
                //DN: DIGI-456 start...
				Utils.updateOEConsoleButtonVisibility_v2(activeNGEMBasket, 'oeAM');
               
				//DN: DIGI-456 ...end
           		if (window.accountId !== null && window.accountId !== "") {
					CommonUtills.setAccountID(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, window.accountId);
        		}
				if(window.basketRecordType ==='Inflight Change'){
					CommonUtills.setBasketRecordType(NXTGENCON_COMPONENT_NAMES.nextGenDevice, window.basketRecordType,'');//EDGE-213068

					CommonUtills.setBasketRecordType(NXTGENCON_COMPONENT_NAMES.nextGenPlan, window.basketRecordType,'');//EDGE-213068
					CommonUtills.setBasketRecordType(NXTGENCON_COMPONENT_NAMES.nextGenAccessory, window.basketRecordType,'');//EDGE-213068
				}
						
				let inputMapPOR = {};
				await activeNGEMBasket.performRemoteAction('SolutionHelperPORPermissionChk', inputMapPOR).then(values => {
				if (values['hasPortOutReversalPermission'])
					hasPortOutReversalPermission = values['hasPortOutReversalPermission'];
				});
				//Added by Aman Soni for EDGE-164619 || End	
				if(!window.OpportunityType.includes('CHOWN')){ //EDGE-152457
					
					await CommonUtills.getSiteDetails(activeNGEMBasket);
					
				if (basketStage !== 'Contract Accepted') {
					Utils.updateComponentLevelButtonVisibility('Order Enrichment', false, true);//EDGe-174219
					Utils.updateComponentLevelButtonVisibility('Number Reservation', false, false); //EDGe-174219
					Utils.updateComponentLevelButtonVisibility('Order Enrichment Console', false, true); //EDGe-174219
					Utils.updateComponentLevelButtonVisibility('Order Enrichment', false, false); //DN: DIGI-456 added
				}
					

                window.currentSolutionName = loadedSolution.name;	
                //Aditya: Edge:142084 Enable New Solution in MAC Basket
                CommonUtills.setBasketChange();	
        			
                await RedemptionUtilityCommon.calculateCurrentFundBalanceAmt(basketNum, activeNGEMBasket);//EDGE-148662
                await RedemptionUtilityCommon.calculateBasketRedemption();//EDGE-148662

					await NextGenMobController.AfterSolutionLoaded(null, loadedSolution); 
				}else{
					await CHOWNUtils.EmptyOEAttLst(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan,NEXTGENMOB_COMPONENT_NAMES.Data_Features, COMPONENT_NAMES.ParentOEList,COMPONENT_NAMES.ChildOEList);

					await CHOWNUtils.handleUpdateAttributesOnLoad(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
					if(window.basketType==='Incoming'){
						{
							await CHOWNUtils.handleVisibilityinCHOWN(); //EDGE-152457
							await CHOWNUtils.billingAccountUpdateRequired(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);
							await CHOWNUtils.handleUpdateBillingAccount(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan, 'BillingAccountLookup');//EDGE-152457
						}
						
					}
				}
				// Calling the Pricing Service on Solution Load
				PRE_Logic.init(loadedSolution.name);
				PRE_Logic.afterSolutionLoaded();
				
								
				CommonUtills.lockSolution(); //EDGE-201407
					await loadedSolution.validate();
				}
		} catch (error) {
			console.log("ERROR ", error);
        }
        return Promise.resolve(true);
    });

    NextGenMobPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
        //EDGE-198536 Start
        //CommonUtills.unlockSolution(); //EDGE-201407
        CommonUtills.commercialUnlockComponent(component); //unlocking component we are working with
        //EDGE-198536 End
        
        try{
			                BuffercountAcc = 0;
                let AcceleratorCount = 0;

            console.log('---inside try---',attribute.name, attribute.displayValue,attribute,'BuffercountAcc',BuffercountAcc); 
			let componentName = component.name;
			 let parentConfig = configuration.parentConfiguration;

			var excludedAttributes = ["FirstName", "LastName", "Phone", "Email", "Address Name", "Address Status", "Name", "Mobile", "PostCode","ADBOIRId","City","Street","Address"];
            if(excludedAttributes.includes(attribute.name)){
                //console.log('returning without update from --',attribute.name);
                return Promise.resolve(true);
            }
			let oldValue = oldValueMap["value"];
			let newValue = attribute.value;
            let newDsiplayValue = attribute.displayValue; //Ila: DPG-4795
			let guid = configuration.guid;
			 let countAcc = 0;
			let gradeofservice; //Jenish
            let gradeofserviceValue; //Jenish
			let updateConfigMap = {}; //Jenish
			let updateDataCustom = {}; //Jenish
			let relatedproductconfigids = []; //Jenish
            //console.log("Inside Next Generation Mobility afterAttributeUpdated");
            let solution = await CS.SM.getActiveSolution();
			            //DIGI-25050 START
						let configId=configuration.id;
						if(componentName === "Transition Device" || componentName === "Accessory" || componentName === "Device" || componentName === "Transition Accessory") 
						{
						if(newValue=='Cancel' && oldValue != 'Cancel') {
			
						console.log("inside if for DIGI-25050");
			
						await RemainingAmount.getTermAmountSync(configId);
			
						}
						}		
			
						//DIGI-25050 END	
			// Ila: DPG-4795 Start: Accelerator Validation			
            if(solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
                if (solution.components && Object.values(solution.components).length > 0){
                    Object.values(solution.components).forEach((comp) =>{
                        if(comp.name.includes(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)){
                            if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
                                Object.values(comp.schema.configurations).forEach((config) =>{
                                var listOfRelatedProducts = config.relatedProductList;
                                Object.values(listOfRelatedProducts).forEach((rp) => {
									if(rp.configuration.parentConfiguration === parentConfig){
                                if (rp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator) {
                                            let ChangeTypeVal = rp.configuration.getAttribute("ChangeType");
                                            if(ChangeTypeVal.displayValue !="Cancel") { //DPG-5854 Fix
                                                countAcc++;
                                                BuffercountAcc = countAcc;
                                              }

                                        }
										//DPG-5297 | Jenish | Capture Grade of Service | Start
										if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features) {
												 gradeofservice = rp.configuration.getAttribute("BusinessDemandData");
												 gradeofserviceValue = gradeofservice.displayValue;
												console.log("gradeofservice*afterattributechange" ,gradeofserviceValue);
											}
											if(rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Custom){
												console.log('rp.name*' ,rp.name);
												console.log('gradeofservice*afterattributechange' ,gradeofserviceValue);
												let gradeofServiceDataCustom = rp.configuration.getAttribute("APN_GradeOfService");
												console.log('gradeofServiceDataCustom*afterattributechange' ,gradeofServiceDataCustom);
												relatedproductconfigids.push(rp.configuration.guid);  
												updateDataCustom[rp.configuration.guid] = [];
												updateDataCustom[rp.configuration.guid].push({
															name: 'APN_GradeOfService',
															value: gradeofserviceValue,
															displayValue: gradeofserviceValue
												});
                                             
											}
											//DPG-5297 | Jenish | Capture Grade of Service | End
										 }	
                                if(rp.configuration.parentConfiguration === configuration.guid){
                                if (rp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator) {
	                                           let ChangeTypeVal = rp.configuration.getAttribute("ChangeType");
	                                            if(ChangeTypeVal.displayValue !="Cancel") { //DPG-5854 Fix
	                                                countAcc++;
	                                                AcceleratorCount = countAcc;
	                                              }
	                               }
	                                }
                                });
                            });
                            }
                        }
                    });
                }
            }   
			//DPG-5297 | Jenish | Capture Grade of Service | Start
				if(updateDataCustom){
                let keys = Object.keys(updateDataCustom);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateDataCustom[keys[i]], true);
							}
                }
			//DPG-5297 | Jenish | Capture Grade of Service | End
			if(attribute.name === "BusinessDemandData" && BuffercountAcc>0 && newDsiplayValue == "Business Demand Data"){
				console.log('rp.configuration.guid-->',relatedproductconfigids);
						updateConfigMap[configuration.guid] = [];
                updateConfigMap[configuration.guid].push({
							name: 'BusinessDemandData',
							value: "Standard",
							displayValue: "Standard"
                });
				//DPG-5297 | Jenish | Capture Grade of Service | Start
				if(relatedproductconfigids){
					for(var i=0;i<relatedproductconfigids.length;i++){
						updateDataCustom[relatedproductconfigids[i]] = [];
						updateDataCustom[relatedproductconfigids[i]].push({
									name: 'APN_GradeOfService',
									value: "Standard",
									displayValue: "Standard"
						});
					}
				}
                if(updateConfigMap){
                let keys = Object.keys(updateConfigMap);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
							}
                }
				if(updateDataCustom){
                let keys = Object.keys(updateDataCustom);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateDataCustom[keys[i]], true);
							}
                }
				//DPG-5297 | Jenish | Capture Grade of Service | End
				CS.SM.displayMessage(" Either BDD or Accelerator can be added as BDD & Accelerator are mutual exclusive", "error");
			 
			}
			if(attribute.name === "SelectPlanType" && AcceleratorCount>0 && newDsiplayValue== NGEMPLans.Enterprise_Wireless){
				let updateConfig = {};
						updateConfig[configuration.guid] = [];
                updateConfig[configuration.guid].push({
							name: 'SelectPlanType',
							value: oldValue,
							displayValue: oldValue
                });
                if(updateConfig){
                let keys = Object.keys(updateConfig);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateConfig[keys[i]], true);
							}
                }
				
				CS.SM.displayMessage(" Accelerator is not applicable for Enterprise Wireless", "error");
			}
			
			// Ila: DPG-4795 End: Accelerator Validation

            if (solution.componentType && solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
                await NextGenMobController.AfterAttributeUpdated(componentName, configuration, guid, attribute, oldValue, newValue);
			}
		} catch (error) {
			console.log(error);
		}
		// Calling the Pricing Service on after attribute update
		PRE_Logic.afterAttributeUpdated(component, configuration, attribute, oldValueMap.value, attribute.value);
		//EDGE-198536 Start
        //CommonUtills.lockSolution(); //EDGE-201407
        CommonUtills.commercialLockComponent(component); //unlocking component we are working with
        //EDGE-198536 End
		return Promise.resolve(true);
	};

	NextGenMobPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		CommonUtills.updateTransactionLogging('before Save'); //DIGI-1634
		console.log("Inside Next Generation Mobility beforeSave");
		let currentSolution = await CS.SM.getActiveSolution();
		CommonUtills.unlockSolution(); //EDGE-201407


		if(!window.OpportunityType.includes('CHOWN')){//EDGE-152457


		if (window.basketStage !== "Contract Accepted"){
			//RedemptionUtils.checkConfigurationStatus();
			var hasRedemptionError=false;
			hasRedemptionError=await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-172970
			var components=solution.getComponents();
			for(var comp of Object.values(components)){
                //for (var config of Object.values(configs)) {
                if(comp.error && window.basketRecordType!=='Inflight Change'){ //INC000094689212
                    return Promise.resolve(false);
                }
                //}
            }
			}
			//Added by Aditya for 197580
			if (window.basketType === 'Remediate'){
				let isError = await InflightBasketUtils.validateRemediationBeforeSave();
				if(isError) {return promise.resolve(false);} 
        }
		//Added by Aman Soni for EDGE-173469 || Start
		if((window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") && window.basketRecordType!=='Inflight Change' && window.BasketChange != 'Change Solution'){
			await NextGenMobHelper.DeviceAndPlanCount();
		}
		//Added by Aman Soni for EDGE-173469 || End
        await NextGenMobHelper.updateSolutionNameNGD(NEXTGENMOB_COMPONENT_NAMES.solutionname,DEFAULTSOLUTIONNAMENGD);
		//EDGE-197578 Start----->
		let configcheck = await NextGenMobHelper.restrictNoFaultReturntoUsers();
		if(configcheck) {
			CS.SM.displayMessage("Please Select other value apart from No Fault Return", "error");
			return promise.resolve(false);
		}
		//EDGE-197578 End----->
		//DPG-5731 Monali Start
		//if($Label.Is_TON_Enabled=='true'){
            		let isTONApplicable = await NextGenMobHelper.isTONApplicable();
            		if(!isTONApplicable) {
                		CS.SM.displayMessage("TON is not applicable for selection", "error");
                		return promise.resolve(false);
            		}
        	//}
		//DPG-5731 Monali end
		}
		// Calling the Pricing Service on before save
		PRE_Logic.beforeSave(solution, configurationsProcessed, saveOnlyAttachment,configurationGuids);
		
		CommonUtills.lockSolution(); //EDGE-201407
		return Promise.resolve(true);
	};

    NextGenMobPlugin.afterSave = async function(result,  configurationsProcessed, saveOnlyAttachment, configurationGuids){
        try{
            let solution = result.solution ; 
			if (solution == null || solution == undefined) solution = await CS.SM.getActiveSolution();
			CommonUtills.unlockSolution(); //EDGE-201407
             //EDGE-216217
            var hasRedemptionError=false;
			hasRedemptionError=await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-172970
			
            if(hasRedemptionError)
				CommonUtills.invalidateOnBasketRedemptions();
            
			CommonUtills.markBasketAsInvalid();
				//Added by Aman Soni for EDGE-173469 || Start
			if(!window.OpportunityType.includes('CHOWN')){ //EDGE-152457
				if((window.basketStage === "Commercial Configuration" || window.basketStage === "Draft" )&& window.basketRecordType!=='Inflight Change'){
					await NextGenMobHelper.updateSyncTransDeviceStatus(NEXTGENMOB_COMPONENT_NAMES.transitionDevice, 'MRO');//Added parameter for EDGE-191077

					await NextGenMobHelper.updateSyncTransDeviceStatus(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory, 'ARO');//Added parameter for DPG-3889, 4083
					

				}
				//Added by Aman Soni for EDGE-173469 || End			
				//Utils.updateCustomButtonVisibilityForBasketStage();
				
				/* DN: DIGI-456 start... */
				//Utils.updateOEConsoleButtonVisibility(); // EDGE-150795 //DN: commented out; replaced by _v2
				activeNGEMBasket = activeNGEMBasket == null ? await CS.SM.getActiveBasket() : activeNGEMBasket;
				Utils.updateOEConsoleButtonVisibility_v2(activeNGEMBasket, 'oeAM');
				/* DN: DIGI-456 ...end */
				
				await NextGenMobController.AfterSave(solution, configurationsProcessed, saveOnlyAttachment); //EDGE-148662
				await Utils.updateImportConfigButtonVisibility();
				await Utils.updateActiveSolutionTotals();		
				
				if (window.basketStage === "Contract Accepted") {
                    await Utils.beforeSaveOEValidations(NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory); //DPG-4184
					await Utils.beforeSaveOEValidations(NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice); //EDGE-155254
					await Utils.beforeSaveOEValidations(NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenPlan); //EDGE-155181
					await NextGenMobHelper.setNextGenEMTabsVisibility(NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenPlan, true,'');// added config Id
					await solution.validate(); // Calling for fixing issues of Error in configuration!!
				}

            }else{
                await CHOWNUtils.handleVisibilityinCHOWN(); //EDGE-152457
           		await CHOWNUtils.handleUpdateAttributesOnLoad(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan);// //EDGE-152457
            }
			CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

            CommonUtills.lockSolution(); //EDGE-201407
			//Added for EDGE-207355 by Aman Soni || Start
			if(window.OpportunityType === "Migration" && (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft')){
				await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
				await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
			}
			//Added for EDGE-207355 by Aman Soni || End
		} catch (error) {
			console.log(error);
			CommonUtills.updateTransactionLogging('after Save error'); //DIGI-1634
		}

		// start EDGE-197534
		if (window.basketStage !== "Contract Accepted" && window.basketStage !== "Enriched" && window.basketStage !== "Submitted"){
		// Updating the PRE Discount attributes
		//await updatePREDiscountAttribute(); // commented for DIGI-1853
		}
		//end EDGE-197534
		CommonUtills.updateTransactionLogging('after Save success'); //DIGI-1634
		return Promise.resolve(true);
	};

	//Added by Aman Soni as a part of EDGE-154028 || Start //Added nextGenAccessory condition by Krunal Taak for DPG-4250 //Added else if in for loop INC000095203350
	NextGenMobPlugin.afterConfigurationClone = async function (component, configuration, clonedConfiguration) {
		console.log("Inside Next Generation Mobility afterConfigurationClone--->", component.name, configuration);	
			if ((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory) && (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft")) {
				for (var config of configuration) {
					//Shweta added EDGE-185652 Adding number sequence for cloned config
					if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
					 let configName = CommonUtills.genericSequenceNumberAddInConfigName(config, "PlanTypeString", "SelectPlanName");
					 	NextGenMobHelper.AMSequenceNumberAddInConfigName(component,config,configName);
					}else if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory){
                        			NextGenMobHelper.updateConfigName_AccessoryperConfig(component.name,config.guid);
					}else{
				                // NextGenMobHelper.updateConfigName_DeviceAllConfig(component.name);
				                NextGenMobHelper.updateConfigName_DeviceperConfig(component.name,config.guid); // Shweta added EDGE-196714
					}
				 }
				 //Shweta end here
				 if(window.basketRecordType!=='Inflight Change' && window.BasketChange != 'Change Solution') //EDGE-210493
				 await NextGenMobHelper.DeviceAndPlanCount();
			}
			if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
				for(var config of configuration){
					var configGuid = config.guid;
					await NextGenMobHelper.InValidateNGEMPlan(configGuid);
				}
			}
			if (component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) {
				if(window.totalRedemptions>0){
					await RedemptionUtilityCommon.populateNullValuesforClonedPC(component.name, configuration); ////EDGE-148662
				}
			}
			
			await Utils.updateActiveSolutionTotals();
			CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade

			console.log("solution is ", solution);

			return Promise.resolve(true);
		
		
	};
	//Added by Aman Soni as a part of EDGE-154028 || End

	NextGenMobPlugin.afterConfigurationAdd = async function (component, configuration) {
		console.log("Inside Next Generation Mobility afterConfigurationAdd--->", component.name, configuration);
		if (component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan) {
			var relatedProductnameList = [NEXTGENMOB_COMPONENT_NAMES.IDD, NEXTGENMOB_COMPONENT_NAMES.Message_Bank, NEXTGENMOB_COMPONENT_NAMES.Data_Features];
			CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, NEXTGENMOB_COMPONENT_NAMES.IDD, false, 1);
			CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, NEXTGENMOB_COMPONENT_NAMES.Data_Features, false, 1);
		}


        //Added nextGenAccessory and transitionDevice condition by Krunal Taak for DPG-4250 // added transitionAccessory by Mahima 3889/4083
		if ((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory || component.name === NEXTGENMOB_COMPONENT_NAMES.transitionDevice || component.name === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory) && (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") && window.basketRecordType!=='Inflight Change' && window.BasketChange != 'Change Solution') { //EDGE-170016


			await NextGenMobHelper.DeviceAndPlanCount();
		}
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			await NextGenMobHelper.InValidateNGEMPlan(configuration.guid);
		// EDGE-207351 Start---->
			if (window.accountId !== null && window.accountId !== "") {
					CommonUtills.setConfigAccountId(component.name, window.accountId,configuration.guid);
					await CHOWNUtils.getParentBillingAccount(NEXTGENMOB_COMPONENT_NAMES.solutionname);
					if(parentBillingAccountATT){
                        let subScenario;
                        if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
                            subScenario=configuration.getAttribute('SubScenario');
                            if(subScenario.value!=='Reactivate')
                               CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name,'');
                        }else
                            CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, configuration.guid, component.name,'');
					}
			}
			// EDGE-207351 End---->
		}
		await NextGenMobHelper.NGEM_handlePortOutReversal(configuration.guid);//Added for EDGE-164619 by Aman Soni
		await Utils.updateImportConfigButtonVisibility();
		RedemptionUtils.populateNullValues(component, configuration); ////EDGE-148662
		Utils.addDefaultGenericOEConfigs( NEXTGENMOB_COMPONENT_NAMES.solutionname);// EDGE-150795

		PRE_Logic.afterConfigurationAdd(component.name,configuration);
        return Promise.resolve(true);
	};

	NextGenMobPlugin.afterConfigurationDelete = async function (component, configuration) {
		console.log("Inside Next Generation Mobility afterConfigurationDelete--->", component.name, configuration);
		await Utils.updateImportConfigButtonVisibility();
		//Added transitionDevice condtion by Aman Soni for EDGE-173469 //Added nextGenAccessory condition by Krunal Taak for DPG-4250
		if ((component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan || component.name === NEXTGENMOB_COMPONENT_NAMES.transitionDevice || component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory) && (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") && window.basketRecordType!=='Inflight Change' && window.BasketChange != 'Change Solution'){
			await NextGenMobHelper.DeviceAndPlanCount();
		}
		if (window.basketStage === "Commercial Configuration" || window.basketStage === "Draft") {
			await NextGenMobHelper.InValidateNGEMPlan(configuration.guid);
		}
		if (window.totalRedemptions > 0) RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593

		PRE_Logic.afterConfigurationDelete(component,configuration);

		return Promise.resolve(true);
	};

	//Added by Aman Soni for EDGE-166327 || Start
	NextGenMobPlugin.beforeRelatedProductAdd = async function (component, configuration, relatedProduct) {
		console.log("Inside Next Generation Mobility beforeRelatedProductAdd--->", component.name, configuration, relatedProduct);
		//// EDGE-170016 start---
		let allowAdd=true;
		let message='';
		message='Inflight amend operation does not allow this operation';
			if(window.basketRecordType==='Inflight Change')
				allowAdd=await InflightBasketUtils.isOperationAllowedInInflightBasket(component.name,configuration,'beforeRelatedProductAdd',message);
		
		//// EDGE-170016  end--------------
		if(window.OpportunityType.includes('CHOWN')){ //EDGE-152457 start---

		
			allowAdd=await CHOWNUtils.isOperationAllowedInCHOWN(component.name,configuration,'beforeRelatedProductAdd','');

		}//EDGE-152457 end---
		if(!allowAdd)
			return Promise.resolve(allowAdd);
		let solution = await CS.SM.getActiveSolution();
			var selectPlanType;
			if(solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)){
				if (solution.components && Object.values(solution.components).length > 0){
					Object.values(solution.components).forEach((comp) =>{
						if(comp.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)){
							if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
								Object.values(comp.schema.configurations).forEach((config) =>{
									if(config.guid && config.guid === configuration.guid){
										let attribs = Object.values(config.attributes);
									selectPlanType = attribs.filter((obj) => {
										return obj.name === "SelectPlanType";
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
				var countBdd = 0; // Ila: DPG-4795 
				var countdc = 0; //-------DPG-4529 Krunal
                		var countTON = 0; //-------DPG-5731 Monali
				var listOfRelatedProducts = configuration.getRelatedProducts();
			Object.values(listOfRelatedProducts).forEach((rp) => {
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features) {
						countDF++;
					}
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank) {
						countMB++;
					}
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.IDD) {
						countIDD++;
					}
					// Ila: DPG-4795 Start: Accelerator Validation
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features) {
						
						let bddAtr = rp.configuration.getAttribute("BusinessDemandData");
						let ChangeTypeAtr = rp.configuration.getAttribute("ChangeType");
						console.log("ChangeTypeAtr**" ,ChangeTypeAtr);
						if (ChangeTypeAtr.displayValue != "Cancel" && bddAtr && bddAtr.displayValue != undefined && bddAtr.displayValue != "" && bddAtr.displayValue === 'Business Demand Data' )  countBdd++;
					}
					console.log("rp.name*" ,rp.name);
					
					// Ila: DPG-4795 End: Accelerator Validation
					//-------DPG-4529 Krunal
					if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Custom) {
						countdc++;
					}
					//-------DPG-4529 Krunal
					//-------DPG-5731 Monali
					//if($Label.Is_TON_Enabled=='true'){
                        			if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Telstra_One_Number) {
                            				countTON++;
                        			}
                    			//}
					//-------DPG-5731 Monali
				});
				if (countDF == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features){
				CS.SM.displayMessage("Only one Data Features can be configured per plan", "error");
				return Promise.resolve(false);
			}
			if (countMB == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank) {
				CS.SM.displayMessage("Only one Voicemail Feature can be configured per plan", "error");
				return Promise.resolve(false);
			}
			if (countIDD == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.IDD) {
				CS.SM.displayMessage("Only one Calling & Messaging Feature can be configured per plan", "error");
				return Promise.resolve(false);				
				}
				if(selectPlanType[0].displayValue != NGEMPLans.Handheld){
					if (countMB == 0 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Message_Bank){
					CS.SM.displayMessage("You cannot add Voicemail configuration under Related Products for the selected plan type", "error");
					return Promise.resolve(false);
					}
				} 	

					// Ila: DPG-4795 Start: Accelerator Validation
				if((selectPlanType[0].displayValue === NGEMPLans.Handheld || selectPlanType[0].displayValue === NGEMPLans.Mobile_Broadband) && countBdd == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator && relatedProduct.type === "Related Component" ){
						
					CS.SM.displayMessage(" Either BDD or Accelerator can be added as BDD & Accelerator are mutual exclusive", "error");
						
					return Promise.resolve(false);
				}
				
				
			if(selectPlanType[0].displayValue === NGEMPLans.Enterprise_Wireless &&  relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator) {
			CS.SM.displayMessage(" Accelerator is not applicable for Enterprise Wireless", "error");
						
					return Promise.resolve(false);
			}
				// Ila: DPG-4795 End: Accelerator Validation
			//-------DPG-4529 Krunal
			if (countdc == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Data_Custom){
				CS.SM.displayMessage("Only one Data Custom can be configured per plan", "error");
				return Promise.resolve(false);
			}
			//-------DPG-4529 Krunal
			//-------DPG-5731 Monali
			//if($Label.Is_TON_Enabled=='true'){
                		if(selectPlanType[0].displayValue != NGEMPLans.Handheld){
                    			if (countTON == 0 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Telstra_One_Number){
                    				CS.SM.displayMessage("You cannot add Telstra One Number configuration under Related Products for the selected plan type", "error");
                    				return Promise.resolve(false);
                    			}
                		}
            		//}
			
            		//if($Label.Is_TON_Enabled=='true'){
                		if (countTON == 1 && relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.Telstra_One_Number){
                    			CS.SM.displayMessage("Only one Telstra One Number can be configured per plan", "error");
                    			return Promise.resolve(false);
                		}
            		//}
			//-------DPG-5731 Monali
			}
			//Added by Aman Soni for bug(EDGE-182492) || Start
			if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice || component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory){
				if(configuration.relatedProductList && (Object.values(configuration.relatedProductList).length >= 0)){
					if (configuration.replacedConfigId){
						if (relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare){
						CS.SM.displayMessage('Device Care can only be added as part of New Order.', 'error');
						return Promise.resolve(false);
						}
					}
				}
			}
			//Added by Aman Soni for bug(EDGE-182492) || End
        return Promise.resolve(true);
	};
	//Added by Aman Soni for EDGE-166327 || End

    //Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt ||  Start
	//Modiefied by Mahima- DPG-4071
    NextGenMobPlugin.afterRelatedProductAdd = async function (component, configuration, relatedProduct){
		console.log("Inside Next Generation Mobility afterRelatedProductAdd--->", component.name, configuration, relatedProduct);
		//DPG-5297 | Jenish | Capture Grade of Service | Start
			 let gradeofservice;
             let gradeofserviceValue;
             let updateConfigMap = {};
			 let activesolution = await CS.SM.getActiveSolution();
			 let parentConfig = configuration.guid;
			 if(activesolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
				if (activesolution.components && Object.values(activesolution.components).length > 0){
					Object.values(activesolution.components).forEach((comp) =>{
						if(comp.name.includes(NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)){
							if(comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0){
								Object.values(comp.schema.configurations).forEach((config) =>{
									var listOfRelatedProducts = config.relatedProductList;  
									console.log('--inside listOfRelatedProducts--',listOfRelatedProducts);
									Object.values(listOfRelatedProducts).forEach((rp) => {
										console.log('rp.configuration.parentConfiguration-->'+rp.configuration.parentConfiguration);
										console.log('parentConfig-->'+parentConfig);
										if(rp.configuration.parentConfiguration === parentConfig){
											console.log('inside parentconfig');
											if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Features) {
												 gradeofservice = rp.configuration.getAttribute("BusinessDemandData");
												 gradeofserviceValue = gradeofservice.displayValue;
												console.log("gradeofservice*" ,gradeofserviceValue);
											}
											if(rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Custom){
												console.log('rp.name*' ,rp.name);
												console.log('gradeofserviceValue&' ,gradeofserviceValue);
												let gradeofServiceDataCustom = rp.configuration.getAttribute("APN_GradeOfService");
												console.log('gradeofServiceDataCustom*' ,gradeofServiceDataCustom);
												   
												updateConfigMap[rp.configuration.guid] = [];
												updateConfigMap[rp.configuration.guid].push({
															name: 'APN_GradeOfService',
															value: gradeofserviceValue,
															displayValue: gradeofserviceValue
												});
                
											}
										}
									});
								});
							}
						}
					});
				}
			 }
			 if(updateConfigMap){
                let keys = Object.keys(updateConfigMap);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
							}
                }

		//DPG-5297 | Jenish | Capture Grade of Service | End
		let countAcc = 0; // Ila: DPG-4795 
		let APNBlankFlag = false; //Krunal DPG-4529
        let APNTypeBlankFlag = false; //Krunal DPG-4529
		if (relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare && relatedProduct.type === "Related Component") {
			var DeviceConfigId = "";
            //Added if else for device and accessory( DPG-4071)- Mahima
            if(component.name=='Device'){
            await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedProduct.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
            await NextGenMobHelper.UpdateChildFromParentAtt(configuration.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenDevice,NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);
        }
            //DPG-4071- Mahima -start
            else if(component.name=='Accessory'){
                await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedProduct.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory);
            	await NextGenMobHelper.UpdateChildFromParentAtt(configuration.guid,NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory,NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);      
            }
            //DPG-4071- Mahima -end
        }
        if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
			await NextGenMobHelper.UpdateChildAttributedonAdd(NEXTGENMOB_COMPONENT_NAMES.solutionname,configuration.guid,component,relatedProduct);
			// Ila: DPG-4795 Start: Accelerator Validation
			var listOfRelatedProducts = configuration.getRelatedProducts();  
			Object.values(listOfRelatedProducts).forEach((rp) => {
			if (rp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator) {
						let ChangeTypeVal = rp.configuration.getAttribute("ChangeType");
                        if(ChangeTypeVal.displayValue !="Cancel") {
                            countAcc++;
                            BuffercountAcc = countAcc;
                          }
						  //DIGI-26615 - START                                
						  let SubScenarioVal =   configuration.getAttribute("SubScenario");
						  NextGenMobHelper.updatechildAttfromParent('SubScenario',SubScenarioVal.value,true,false,configuration.guid,component.name);                                 
						  NextGenMobHelper.updateChildAttributefromParentDiscount(configuration.guid,component.name,rp.name); //update ignoreDiscountID
						  //DIGI-26615 - END
					}
            //-------DPG-4529 Krunal
			if (rp.name === NEXTGENMOB_COMPONENT_NAMES.Data_Custom) {
						let DC_addonAssocVal = rp.configuration.getAttribute("DC_addonAssoc");
						let APN_TypeVal = rp.configuration.getAttribute("APN Type");
						console.log("DC_addonAssocVal*" ,DC_addonAssocVal , "APN_TypeVal", APN_TypeVal);
                
                if(DC_addonAssocVal === "" || DC_addonAssocVal === null) {
							APNBlankFlag = true;
                          }
                if(DC_addonAssocVal != '' || DC_addonAssocVal != null ){ 
                    APNBlankFlag = false
                           if(APN_TypeVal === "" || APN_TypeVal === null) {
							APNTypeBlankFlag = true;
                          }
                }
                        
			}
			//-------DPG-4529 Krunal
			});
			//-------DPG-4529 Krunal
				if (APNBlankFlag === true){
					CS.SM.displayMessage(" Please select an Access Point Name", "error");
					return Promise.resolve(false);
				}
				else if (APNTypeBlankFlag === true){
					CS.SM.displayMessage(" APN Type not present", "error");
					return Promise.resolve(false);
				}
                //else{return Promise.resolve(true);} // Commented for DIGI-12231
				//-------DPG-4529 Krunal
            // Ila: DPG-4795 End: Accelerator Validation
        }
        //DPG5-4793-Pricing Fix. 
        setTimeout(PRE_Logic.afterConfigurationAdd, 1000, component.name, configuration); //PRE_Discount attribute update.
        return Promise.resolve(true);
	};

	NextGenMobPlugin.afterRelatedProductDelete = async function (component, configuration, relatedProduct) {
		let solution = await CS.SM.getActiveSolution();
		CommonUtills.unlockSolution(); //EDGE-201407
		console.log("Inside Next Generation Mobility afterRelatedProductAdd--->", component.name, configuration, relatedProduct);
		if (relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare && relatedProduct.type === "Related Component") {
			var DeviceConfigId = "";
			await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedProduct.guid, NEXTGENMOB_COMPONENT_NAMES.solutionname, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
		}
        // Ila: DPG-4795 Start: Accelerator Validation
        if(relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.nextGenAccelerator){
            BuffercountAcc=0;
        }
        // Ila: DPG-4795 End: Accelerator Validation
		
		//DPG-4899/98- mahima gandhe
		 PRE_Logic.afterConfigurationDelete(component,configuration);
		CommonUtills.lockSolution(); //EDGE-201407
		return Promise.resolve(true);
	};
//Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt || End
	
	//Added by Aman Soni for EDGE-166327 || Start
	NextGenMobPlugin.beforeConfigurationDelete = async function (component, configuration) {
		let configGuid = configuration.guid;
		//// EDGE-170016 start---
		let allowAdd=true;
		let message='';
		message='Inflight amend operation does not allow this operation';
		if(window.basketRecordType==='Inflight Change')
			allowAdd=await InflightBasketUtils.isOperationAllowedInInflightBasket(component.name,configuration,'beforeConfigurationDelete',message);
		if(window.OpportunityType.includes('CHOWN')){ //EDGE-152457 start---

			 
			allowAdd=await CHOWNUtils.isOperationAllowedInCHOWN(component.name,configuration,'beforeConfigurationDelete','');

		}//EDGE-152457 end---
		
		if(!allowAdd)
			return Promise.resolve(allowAdd);
		//// EDGE-170016  end--------------
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
	};
	//Added by Aman Soni for EDGE-166327 || End
		
	NextGenMobPlugin.beforeRelatedProductDelete = async function (component, configuration, relatedProduct){
		let solution = await CS.SM.getActiveSolution();
		let configGuid = configuration.guid;
		let tobeDelete = true;	
		//// EDGE-170016 start---
		let allowAdd=true;
		let message='';
		message='Inflight amend operation does not allow this operation';
		if(window.basketRecordType==='Inflight Change')
			allowAdd=await InflightBasketUtils.isOperationAllowedInInflightBasket(component.name,configuration,'beforeRelatedProductDelete',message);
		if(window.OpportunityType.includes('CHOWN')){ //EDGE-152457 start---

			
			allowAdd=await CHOWNUtils.isOperationAllowedInCHOWN(component.name,configuration,'beforeRelatedProductDelete','');

		}//EDGE-152457 end---
		if(!allowAdd)
			return Promise.resolve(allowAdd);
		//// EDGE-170016  end--------------
		if(component.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
			if(allowRPDel === false){
				if(component.schema && component.schema.configurations && Object.values(component.schema.configurations).length > 0){
				Object.values(component.schema.configurations).forEach((config) => {
					if(config.guid === configGuid){
						if(config.attributes && Object.values(config.attributes).length > 0){
							let attribs = Object.values(config.attributes);
						let planType = attribs.filter((obj) => {
							return obj.name === "SelectPlanType";
						});
						if (planType[0].displayValue === NGEMPLans.Enterprise_Wireless || planType[0].displayValue === NGEMPLans.Mobile_Broadband || planType[0].displayValue === "") {
							if (relatedProduct.name === NXTGENCON_COMPONENT_NAMES.dataFeatures && relatedProduct.type === "Related Component") {
								tobeDelete =false;
								CS.SM.displayMessage("One data feature configuration must exist for any plan", "error");
								return Promise.resolve(false);										
							}
							else if (relatedProduct.name === NXTGENCON_COMPONENT_NAMES.internationalDirectDial && relatedProduct.type === "Related Component") {
								tobeDelete =false;
								CS.SM.displayMessage("Not allowed to delete the Calling & Messaging feature configuration for any plan", "error");
								return Promise.resolve(false);
							}
							//Hitesh EDGE-174694 added for IR month pass Starts
							else if(relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.IRMonthPass && relatedProduct.type === 'Related Component' && relatedProduct.replacedConfigId){
								tobeDelete =false;
								CS.SM.displayMessage('Not allowed to delete the International Roaming Month Pass feature configuration for MAC basket', 'error');
								return Promise.resolve(false);										
							}
							//Hitesh EDGE-174694 added for IR month pass ends
						}else if (planType[0].displayValue === NGEMPLans.Handheld) {
							if(relatedProduct.name === NXTGENCON_COMPONENT_NAMES.dataFeatures && relatedProduct.type === "Related Component"){
								tobeDelete =false;
								CS.SM.displayMessage("One data feature configuration must exist for any plan", "error");
								return Promise.resolve(false);										
							}
							else if (relatedProduct.name === NXTGENCON_COMPONENT_NAMES.internationalDirectDial && relatedProduct.type === "Related Component") {
								tobeDelete =false;
								CS.SM.displayMessage("Not allowed to delete the Calling & Messaging feature configuration for any plan", "error");
								return Promise.resolve(false);										
							}
							else if (relatedProduct.name === NXTGENCON_COMPONENT_NAMES.messageBank && relatedProduct.type === "Related Component") {
								tobeDelete =false;	
								CS.SM.displayMessage("Not allowed to delete the Voicemail feature configuration for this plan", "error");
								return Promise.resolve(false);																		
							}
							//Hitesh EDGE-174694 added for IR month pass Starts
							else if(relatedProduct.name === NEXTGENMOB_COMPONENT_NAMES.IRMonthPass && relatedProduct.type === 'Related Component' && relatedProduct.replacedConfigId){
								tobeDelete =false;
								CS.SM.displayMessage('Not allowed to delete the International Roaming Month Pass feature configuration for MAC basket', 'error');
								return Promise.resolve(false);										
							}
							//Hitesh EDGE-174694 added for IR month pass ends 
						}
					}
				} });
			}			
		}
		}
		if(tobeDelete)
		return Promise.resolve(true);
};
	
	window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
		let solution = await CS.SM.getActiveSolution();
		if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname) || solution.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription)) {
			console.log("afterOrderEnrichmentTabLoaded: ", e.detail.configurationGuid, e.detail.orderEnrichment.name);
			var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
			await window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
		}
		return Promise.resolve(true);
	});
            
	//added by shubhi
	NextGenMobPlugin.afterConfigurationAddedToMacBasket = async function (componentName, configuration) {

	  // Arinjay Start - EDGE 221460
        try {
          	CommonUtills.UpdateRelatedConfigForChildMac(configuration,componentName,null);
        } catch (error) {
            console.log(error);
        }
 		// Arinjay End - EDGE 221460
		CommonUtills.CloneOrderEnrichment(componentName, configuration);//Added be vijay DIGI-456
		if(window.basketRecordType ==='Inflight Change'){
			CommonUtills.setBasketRecordType(componentName, window.basketRecordType,configuration);
		}
		if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)
			InflightBasketUtils.updateReplaceConfigAtt(componentName, configuration, 'ReplacedConfig');	
		else if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice || componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory)
			InflightBasketUtils.updateReplaceConfigAtt(componentName, configuration, 'ReplaceConfig');
			
		if(window.basketRecordType!=='Inflight Change'){ // EDGE-170016 
			await NextGenMobHelper.checkConfigSubsStatusonaddtoMac(NEXTGENMOB_COMPONENT_NAMES.solutionname,componentName, "", configuration);
			if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
                NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
                await CommonUtills.getChildServicesMobileDeviceCare();
                await RedemptionUtilityCommon.updateRedeemFundonAddtoMac(componentName, configuration);//EDGE-164350
            }
            else if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory){
                NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //For DPG-5626 by Monali
                //NextGenMobHelper.updatePurchaseOrderNoOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //For DPG-5626 by Mo
				//Digi-27111 commmenting line
                await CommonUtills.getChildServicesMobileDeviceCare();
                await RedemptionUtilityCommon.updateRedeemFundonAddtoMac(componentName, configuration);//EDGE-164350
            }
            else if(componentName===NEXTGENMOB_COMPONENT_NAMES.transitionAccessory){
                NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.transitionAccessory); //For DPG-5626 by Monali
            }
			else if(componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
				await ReactivateServiceUtils.resetSubscenario(configuration,componentName);//Edge-185856 
				await NextGenMobHelper.updateDisplayValueAutodataTopUp(configuration); //need to removed once we have heroku update api to update displayname EDGE-212647
				await NextGenMobHelper.UpdateRelatedConfigForChild(configuration); // Added by Mahima for ReplaceConfigId Fix
			} 
			if ((componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) || (componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory) || (componentName===NEXTGENMOB_COMPONENT_NAMES.nextGenPlan)) {
				await InflightBasketUtils.populateNullValuesInflight(componentName, configuration); 
			} // Added by Aditya for EDGE-191075 for all components 
			//await NextGenMobHelper.HideShowAttributeLstOnMac(NEXTGENMOB_COMPONENT_NAMES.solutionname,componentName,NGDListOfLists,configuration);
			//await NextGenMobHelper.UpdateDataFeatureAttributesonMac(componentName,configuration);
			await NextGenMobHelper.NGEM_handlePortOutReversal(configuration);//Added for EDGE-164619 by Aman Soni
			await NextGenMobHelper.RemainingTermCalculation(NEXTGENMOB_COMPONENT_NAMES.solutionname,componentName,'',configuration);
			
		}else{
			InflightBasketUtils.handleAddToInflight(componentName, configuration);	
		}//EDGE-170016
		await NextGenMobHelper.HideShowAttributeLstOnMac(NEXTGENMOB_COMPONENT_NAMES.solutionname,componentName,NGDListOfLists,configuration);
        return Promise.resolve(true);
	};
	//added by shubhi
	NextGenMobPlugin.afterSolutionDelete = function (solution) {
		if (window.totalRedemptions > 0) RedemptionUtilityCommon.calculateBasketRedemption(); //EDGE-169593

		refreshPricingSummeryWidget();// Method to refresh the Pricing Summary widget after Solution Delete

	};
	//EDGE-170016	start----------------------------------------------------------------------------------------
	NextGenMobPlugin.beforeConfigurationClone = async function (component, configuration) {
		let allowAdd=true;
		let message='';
		if(window.basketRecordType==='Inflight Change'){
			message='Inflight amend operation does not allow this operation';
			allowAdd=await InflightBasketUtils.isOperationAllowedInInflightBasket(component.name,configuration,'beforeConfigurationClone',message);
			return Promise.resolve(allowAdd);
		}
		if(window.OpportunityType.includes('CHOWN')){ //EDGE-152457 start---

			
			allowAdd=await CHOWNUtils.isOperationAllowedInCHOWN(component.name,configuration,'beforeRelatedProductDelete','');

			return Promise.resolve(allowAdd);
		}//EDGE-152457 end---
		return Promise.resolve(allowAdd);
	}
	NextGenMobPlugin.beforeConfigurationAdd = async function (component, configuration){
		let allowAdd=true;
		let message='';
		if(window.basketRecordType==='Inflight Change'){
			if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenDevice){
				message='Please raise commercial inflight basket if new device has to be added';
			}
			else if(component.name===NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory){
				message='Please raise commercial inflight basket if new accessory has to be added';
				
			}
			else{
				message='Inflight amend operation does not allow this operation';
			}
			allowAdd=await InflightBasketUtils.isOperationAllowedInInflightBasket(component.name,configuration,'beforeConfigurationAdd',message);
			return Promise.resolve(allowAdd);
		}
		if(window.OpportunityType.includes('CHOWN')){ //EDGE-152457 start---

			
			allowAdd=await CHOWNUtils.isOperationAllowedInCHOWN(component.name,configuration,'beforeRelatedProductDelete','');

			return Promise.resolve(allowAdd);
		}//EDGE-152457 end---
		return Promise.resolve(allowAdd);
	}
	//EDGE-170016	 end---------------------------------------------------------------------------------------------
};

//Added by Aman Soni as a part of EDGE-148667 || Invoked inValidateDeviceCareConfigOnEligibility, UpdateChildFromParentAtt || End

//Arinjay JSUpgrade
async function saveSolutionNxtGenMob(){
    if (executeSaveNGM){
        executeSaveNGM = false;
        allowSaveNGM = true;
		let solution = await CS.SM.getActiveSolution();
		CommonUtills.unlockSolution(); //EDGE-201407   
		CommonUtills.lockSolution(); //EDGE-201407   
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
		childWindow.postMessage("Hey", window.origin);
	}
	var message = {};
	if (data) {
		message["data"] = JSON.parse(data);
		NextGenMob_handleIframeMessage(message);
	}
	if (close) {
		message["data"] = close;
        NextGenMob_handleIframeMessage(message);
    }
}

// Added this method as part of EDGE_150065
async function NextGenMob_handleIframeMessage(e){
	//console.log("handleIframeMessage from pricing:", e);	
    let currentBasket =  await CS.SM.getActiveBasket(); 
	solutionID = window.activeSolutionID ;
	// Added below snippet for EDGE-174219 
	//console.log(e.data["caller"] + ' ------------e.data["caller"]')
	let updateMap = {};
	let updateMapNum = {};
	let updateMapSubType = {};//EDGE-197555
	if(e.data["data"] && e.data["caller"] && e.data["command"] === "POCTEST" ){
		if (e.data["caller"] === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan){
			let payloadResponse = JSON.parse(e.data["data"]);
			Object.keys(payloadResponse).forEach(async (valueKey) => {
			let mainKey = valueKey.replace(/['"]+/g, "");
			let mainValueRecordStr = JSON.stringify(payloadResponse[valueKey]);
			let mainValueRecordParsed = JSON.parse(mainValueRecordStr);
			let rec = mainValueRecordParsed[0];
			let rec1 = mainValueRecordParsed[1];//EDGE-197555
			let name = rec.name;
			 updateMap[mainKey] = rec.value;
			 updateMapNum[mainKey] = rec.assignnumber;
			 updateMapSubType[mainKey] = rec1.value;//EDGE-197555
			});
			//console.log ('updateMap--------',updateMap); 
			//if (solutionID!== '' && solutionID !== null && solutionID!== undefined  && solutionID!== 'undefined' )	{
			//console.log (window.activeSolutionID + ' ------------Active SOlution ID inside loop')
			//await currentBasket.submitSolution(solutionID);
			// await currentBasket.updateSolution (solutionID) .then( solution => console.log( solution ));
			let keysConfig = Object.keys(updateMap);
			//let updateMapConfig = {}; 
			var solution = await CS.SM.getActiveSolution();	
			if(solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
				if(solution.components && Object.values(solution.components).length > 0) {
					Object.values(solution.components).forEach((comp) => {
						if ((comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenPlan) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {					
								Object.values(comp.schema.configurations).forEach(async (config) => {
									let updateMapConfig = {}; //Hitesh Gandhi EDGE-200723, moved initialization of updateMapConfig withing for loop from outside.
									if(!config.disabled){                                    
									let simAvailabilityTypeVal = updateMap[config.guid];
									let assignedNumber = updateMapNum[config.guid];
									let pcSubType = updateMapSubType[config.guid];//EDGE-197555
									 if (!updateMapConfig[config.guid] && (assignedNumber!= undefined || simAvailabilityTypeVal!= undefined || pcSubType!= undefined)) //Hitesh Gandhi EDGE-200723, updated the criteria to declare updateMapConfig
									updateMapConfig[config.guid] = [];    
									
									//console.log ('assignedNumber --------',assignedNumber)
									if (simAvailabilityTypeVal!= null && simAvailabilityTypeVal!= undefined){
									//updateMapConfig[config.guid] = [];
									updateMapConfig[config.guid].push({
										name: 'SimAvailabilityType',
										value: simAvailabilityTypeVal,
										displayValue: simAvailabilityTypeVal
									});
									}
									if (assignedNumber!= null && assignedNumber!= undefined){
									
									updateMapConfig[config.guid].push({
										name: 'Assigned Number',
										value: assignedNumber,
										showInUI: true,
										displayValue: assignedNumber
									});
									}
									if (pcSubType!= null && pcSubType!= undefined){
									//EDGE-197555||start
										  updateMapConfig[config.guid].push({
											name: 'SubScenario',
											value: pcSubType,
											displayValue: pcSubType
										});
												
									//EDGE-197555||End										
																								
									}
									}
								
										//console.log('updateMapConfiguration ---------------------', updateMapConfig);
							var complock = comp.commercialLock;
							if (complock) await comp.lock("Commercial", false);
							let keys = Object.keys(updateMapConfig);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], updateMapConfig[keys[i]], false);
							}
							//await comp.updateConfigurationAttribute(config.guid, updateMapConfig, true); 
							if (complock) comp.lock("Commercial", true);
							
							 });
						}
					});
				}
			}
		

				await NextGenMobHelper.setNextGenEMTabsVisibility(NEXTGENMOB_COMPONENT_NAMES.solutionname,NEXTGENMOB_COMPONENT_NAMES.nextGenPlan,true);


			// Changes END - EDGE-174219
			return Promise.resolve(true);
		}//end Caller CHk
	} // End if e.getData
	var message = '';
	if(basketStage !== "Contract Accepted"){
        message = e["data"]; 
		if(message["data"]!==undefined)
        message = message["data"];
		//Edge-143527 start
		//added by shubhi for EDGE-121376 start /////
		if(message && message.includes("reactivateMisdns")) { 
			await ReactivateServiceUtils.handleReactivateServiceIframe(e["data"]);
            await pricingUtils.closeModalPopup();
			return Promise.resolve(true);
        }
		//Added by Aman Soni for EDGE-191077 || Start
		else if (e.data["command"] === "createConfigsforSelectedDevices" && e.data["caller"]){
            let componentName      = e.data["caller"];
            let configsTobeCreated = e.data["data"];
			await NextGenMobHelper.createConfigforSelServiceAddOns(componentName,configsTobeCreated);
			
			//Added by Aman Soni for EDGE-203220 || Start
			var solution = await CS.SM.getActiveSolution();
			var comp = solution.getComponentByName(componentName);
			var configs = comp.getConfigurations();
			Object.values(configs).forEach(async (config) => {
				config.status = true;
				config.statusMessage = '';
			});
			//Added by Aman Soni for EDGE-203220 || End
			
			return Promise.resolve(true);
		}
		else if (e.data["command"] === "removeConfigsforSelectedDevices" && e.data["caller"]){	
            let componentName       = e.data["caller"];
            let configsTobeRemoved = e.data["data"];
			await NextGenMobHelper.removeConfigforSelServiceAddOns(componentName,configsTobeRemoved);
			
			//Added by Aman Soni for EDGE-203220 || Start
			var solution = await CS.SM.getActiveSolution();
			var comp = solution.getComponentByName(componentName);
			var configs = comp.getConfigurations();
			Object.values(configs).forEach(async (config) => {
				config.status = false;
				config.statusMessage = 'Please click on Validate and Save to save your changes';
			});
			//Added by Aman Soni for EDGE-203220 || End
			
			return Promise.resolve(true);
		}else if(e["data"]==='close'){
			await pricingUtils.closeModalPopup();
			return Promise.resolve(true);			
		}
		//Added by Aman Soni for EDGE-191077 || End
    }
	if (e.data && e.data["caller"] && e.data["command"]) {
		 //Added By vijay ||start
	     if (e.data && e.data["command"]=='OEClose') { 
					await pricingUtils.closeModalPopup();
					   CommonUtills.oeErrorOrderEnrichment();
			}
						//Added By vijay ||end
		if (e.data["caller"] && e.data["caller"] !== "Device") {
			return;
		} else if (e.data["command"] === "pageLoad" + callerName_NG_Device && e.data["data"] === solutionID) {
			await pricingUtils.postMessageToPricing(callerName_NG_Device, solutionID, IsDiscountCheckNeeded_ngdevice, IsRedeemFundCheckNeeded_ngdevice); // EDGE-148662 shubhi
		} else if (e.data["command"] === "StockCheck" && e.data["data"] === solutionID) {
			//EDGE-146972--Get the Device details for Stock Check before validate and Save as well
			await stockcheckUtils.postMessageToStockCheck(callerName_NG_Device, solutionID);
		}else if(e.data==='close'){
			await pricingUtils.closeModalPopup(); 
		}
        //EDGE-185011 end
        else {
			await pricingUtils.handleIframeDiscountGeneric(e.data["command"], e.data["data"], e.data["caller"], e.data["IsDiscountCheckAttr"], e.data["IsRedeemFundCheckAttr"], e.data["ApplicableGuid"]); // EDGE-148662 shubhi
        }
    } else if (e.data === 'close') { //EDGE-223573 Fix
    		await pricingUtils.closeModalPopup();
	}
               
	} 
	