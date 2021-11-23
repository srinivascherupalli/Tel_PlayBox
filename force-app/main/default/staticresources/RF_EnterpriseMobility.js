/******************************************************************************************
* Author                : Cloud Sense Team
Change Version History
Version No         Author                                Date
1                                           Hitesh Gandhi                                  25-07-2019
2                                           Venkat                                                              26-07-2019
3.                                          Kalashree Borgaonkar    20-08-2019                                                      EDGE-93081 - Render enhanced number reservation page.
4.          Tihomir Baljak                   13-08-2019                       Code refactoring - save, OE
5.                                          Rohit Tripathi                                   13-08-2019                                                      EDGE-88407 --> Cancel and Modify Implementation (checkConfigurationSubscriptions)
6.                                          Hitesh Gandhi                                  14-08-2019                                                      EDGE-81062 --> Changed the component refrence name to 'Corporate Mobile Plus'
7.                                          Ritika Jaiswal                                    19-08-2019                                                      EDGE-81135 --> Added alert message, when cancelling all CMPs, ETC calculation of CMP
8.                                          Abinash Barik                                    19-08-2019                                                      EDGE-81127 -> As sales / partner user, I want latest plan, discount price to be applied during plan change scenario but  
                                                                                                                                                                                                                                 MRO device price should NOT be changed.
9.          Venkata Ramanan                           19-08-2019              Fixed Bulk OE issues on load & save
10.                        Tihomir Baljak                  20-08-2019                                                      EDGE-108329, fixed EMPlugin_saveSolutionEM function
11          Tihomir Baljak                  21-08-2019                                       Hide custom buttons on config level depending on basket stage
12.                                       Laxmi Rahate                                   21-08-2019                                                      EDGE-89294 - Changes in EDM list to decompose
13.                        Tihomir Baljak                                  04-09-2019                                                      Bulk OE for mobility now use Mobility plugin
14.         Ankit Goswami                                09-04-2019                                                      Select plan changes on mobility and Device type added on Device
15.                                       Ritika Jaiswal                                    16-09-2019                                                      EDGE - 81135 : ETC calculation for CMP-Devices
16.                        Ritika Jaiswal                                    26-09-2019                                                      Defect fixes for CMP cancellation
17.         Ankit Goswami          09-04-2019                                              Committed data plan changes for CMP 
18.                                       Ankit Goswami/Hitesh    23-10-2019                                                      Committed data BonusPlan changes changes for CMP
19.                        Ritika Jaiswal                                    24-10-2019                                       EDGE - 81135 : RemainingTerm forCMP cancel
20.                                       Ankit Goswami/Hitesh    29-10-2019                                                      Committed data Specs changes for CMP
21.                                       Ankit Goswami/Hitesh    06-11-2019                                                      Channge Type Changes for Cancel 
22.                                       Kalashree Borgaonkar    06-11-2019                       Show 'Port-in check' button
23.         Venkata Ramanan G       08-11-2019                           Commented out the competitor attribute related codes as its no longer required
24.         Shubhi V                                           30-11-2019                           Edge-20132 Discounts 
25.         Ankit Goswami                                10-12-2019                                           EDGE-117256 Enable search on MSISDN in solution console
26.         Ankit Goswami                                30-01-2020                                           EDGE-132276 Device status update on Device for Macd 
27.         Romil Anand             15-01-2020                                              EDGE-130859 Redeeming One Funds for Cancel Journey
28.                                       Samish                                                              10-02-2020                                                      EDGE-132203 Error handling
28.         Laxmi Rahate            14-02-2020                               EDGE-127421 Added Remote Action - to check if PaymentType is OneFund and other changes for MRO Bonus STory
29.         Ankit Goswami           19-02-2020                                 EDGE-123594 call setMainSolutionCorrelationID function
30.         Laxmi Rahate            24-02-2020                               Merge Production Issue changes done by Rohit
31.         Dheeraj Bhatt           13-02-2020                               EDGE-100662 : UI Enhancements Fixed Number Search with Validations for Telstra
32.                                       Aman Soni                                                       26-02-2020                       EDGE-135278 : EM MAC Discounting - New fields to support MS to derive elapsed duration for Charge and Discount
33.                                       Laxmi                                                     26-02-2020                                                   EDGE-135885 - Added Solution Name and BAsketNum in the priceScedule URL    
34.                        Laxmi                                                                09-03-2020                                                      EDGE-138001 - method call to hide importconfigurations button added
35.                                       Rohit Tripathi                                   13-03-2020                                                      EDGE-140459 Restoring Logic for PRM handling in Prod and Deal logic for with and without deal config in one basket
36                                         Laxmi                                                                13-03-2020                                                      EDGE-131531 Hiding the SHow Promotion & Price Schedule Links
37.                                       Samish Kumar                                  10-03-2020              EDGE-120137  Set isRecontractingDiscountEligible(Cancel or Modify)
38.         Ankit Goswami                                18-03-2020                                       EDGE-134880 Enable search on MSISDN in solution console
39.                                       Ankit Goswami                                18-03-2020                                                      EDGE-140536 Set plandiscount and plandiscount lookup for MRO
40.         Sandip Deshmane         19-03-2020              EDGE-138631 - Added to validate Disconnection Date is not in the past. 
41.                                       Hitesh Gandhi                                  24-03-2020                                                      Incident INC000092474084 ,EMPlugin_updateEDMListToDecomposeattribute method updated
42.                                       Rohit Tripathi                                   26-03-2020                                                      EDGE-142087  As a User, I want to see correct Total Contract Value for committed data plan in basket during NEW, MAC - Add / Remove scenarios
43                                         Laxmi Rahate                                   07-APR-2020                                                   EDGE-131531 - Added check for Provisioning In Progress in UpdateLinkAttributesEMS method
44.                                       Ankit Goswami                                08-APR-2020                                    EDGE-143972 -  Added by Ankit Goswami
45.                                       Ankit Goswami                                08-apr-2020                                                     EDGE-137466 - Added condition for  bulk enrichment by ankit
46.         Shubhi Vijayvergia                          10-Apr-2020                                                    EDGE-137466 - added rules for oe new/modify
47.                                       Aman Soni                                                       08-APR-2020                                    EDGE-123593 -  Added by Aman Soni
48.                                       Sandip Deshmane                                          15-Apr-2020                                                    EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
49.                                       Ankit Goswami                                23-Apr-2020                                                    EDGE-140967-Enabling Redemption as Discount for Device Payout on EM
49.         Shubhi/Aman              29/4/2020                                                             Edge-143527 - POC solution json
50.                                       Laxmi Rahate                                   27-Apr-2020                                                    EDGE-142321 Port Out Reversal Changes
51.                                       Ankit Goswami                                13-May-2020                                                   EDGE-148661 To not throw GNP error in case of already Device PaidOut
52.                        Laxmi Rahate                                   14-May-2020                                                   EDGE-147474 & EDGE-147799 CHanges - BULK OE and Clear Plan Discount
53.                        Aditya Pareek                                  08-May-2020                                                   EDGE-138108 - Changed Signature of remainingTermEnterpriseMobilityUpdate 
54.                                       Ankit Goswami                                14-may-2020                                                   EDGE-147709 Hide MDM Entitlement FIX
55.                                       Aman Soni                                                       19-May-2020                                                  EDGE-148455 To capture Billing Account               
56.             Hitesh Gandhi                                             22-May-2020                                                   EDGE-146184 Added check for IDD charge            
57                                         Laxmi Rahate                                   27-May-2020                                                   EDGE-151380 - Defect Fix - Use Existing SIM case
58.         RaviTeja                01-Jun-2020                            EDGE-146972-Get the Device details for Stock Check before validate and Save as well
59.                        Gnana                                                               10-Jun-2020                                      EDGE-149887 : Solution Name Update Logic 
60.                        Hitesh Gandhi                                  15-Jun-2020                                                     EDGE-155203  : added Global Data SIM and Global Data SIM BYO to condition.
61.                        Aman Soni                                                       17-Jun-2020                                                     EDGE-156214 EM mac || issue in billing account
62.                        Aman Soni                                                       22-Jun-2020                                                     EDGE-155354 Set By Default DeviceEnrollment value to 'DO NOT ENROL'
63.         Shubhi V                                                          25-June-2020                                   EDGE-158034 Clone issue fix
64.                        Arinjay Singh                                    02-July-2020                                     EDGE-155247 JSPlugin Upgrade and Merge with 20.08
65.                                       Gnana/Aditya                                  19-July-2020                                     CS Spring'20 Upgrade
66.                        Arinjay Singh                                    12-Aug-2020                                                    EDGE-168703
67.         Shubhi/Ankit                                     14/08/2020                                                     device enrollement and validation handling 
68.         Shubhi                  21/08/2020              Misdnfix
69.         Shubhi                  31.08.2020              INC000093772606 fix 
70.         Pallavi D                                                           31/08/2020              added for EDGE-162025 Populating SelectIDD value
71.                                       Arinjay Singh                                    20/09/2020                                                      JS Refactoring
72.                                       Aman Soni                                                       24/09/2020                                                      Added for EDGE-164619 by Aman Soni

73.         Yash Rathod             09/10/2020              EDGE-177524/EDGE-143435 fix

74.         Aditya                                                               07.10.2020                                                       EDGE-170011 Removal of "Use Existing SIM" check box
75.         Pallavi D               15.10.20202             EDGE-184549,EDGE-184540 
76.         Pallavi D               22.10.20202             QA1 defect fix
77.         Pallavi D               03.11.2020              EDGE-187737- retrofit issue

78.         Shweta K                03.11.2020               EDGE-185652  
79.			Arinjay Singh			04.11.2020				EDGE-188102
80.         Pallavi D               27.11.2020              Removed extra comma
81.         Shubhi           	    26/11/2020    			EDGE-190170
82.         Pooja Bhat              26.11.2020              EDGE-190802
83. 		Sandhya					22.12.2020				INC000094141578 Fix
84.			laxmi					5/01/2020				INC000093943963 Fix
85.         Shubhi                  8/01/2020				EDGE-197623
86.         Ankit                   8/01/2020				EDGE-197555
87.         Kamlesh                 18/1/2020               EDGE-191955 - Added validation to remind user to click on validate and save once OE is done
88. 		Pawan Singh           	09/04/2021				EDGE-212827 - OE defect resolved
89.         Antun Bartonicek        01/06/2021              EDGE-198536: Performance improvements
90.         Ritika Gupta            09/09/2021              DIGI-20921:  Changed condition  
91.         Riya Sunny              2/11/2021               R34 Upgrade    
**************************************************************************************************************************************/

var ENTERPRISE_COMPONENTS = {
    enterpriseMobility: "Corporate Mobile Plus", //EDGE-81062
    mobileSubscription: "Mobile Subscription",
    device: "Device",
    solutionEditableAttributeList: ["Solution Name", "OfferName", "OfferType", "DataPackPlan"],
    mobileSubscriptionEditableAttributeList: ["SelectPlanType", "Select Plan", "InternationalDirectDial", "MessageBank"],
    mobileSubscriptionAddOnEditableAttributeList: ["Device Type", "MobileHandsetManufacturer", "MobileHandsetModel", "MobileHandsetColour", "PaymentTypeLookup", "ContractTerm"],
};
var mdmvalidmobconfig = 0;
var show = false;
var executeSaveEM = false;
var allowSaveEM = false;
var productInError = false;
var IsMACBasket = false;
var IsDeviceChange = false;
var communitySiteId;
var userThemeValue;
var allowanceValue = null;
var isCommittedDataOffer = false;
var datashow = false;
var datapackallowance = null;
var SolutionChangeType = false;
var closeNotAllowed = false;
let isPaymentTypeOneFund; // Added by Laxmi EDGE-127421
var basketNum; // Added by Laxmi EDGE_135885
var solutionName; // Added by Laxmi EDGE_135885
var contractSignedDate;
var rcmEligible = false;
var skipsave = false; //added by ankit EDGE-132203
var configId; //Edge-143527
var IsDiscountCheckNeeded_EM; //Edge-143527
var IsRedeemFundCheckNeeded_EM; //EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
var solutionID; // Edge-143527
var callerName_EM = ""; //Edge-143527
var hasPortOutReversalPermission = false; // EDGE-142321
var DEFAULTSOLUTIONNAME_EM = "Corporate Mobile Plus"; // Added as part of EDGE-149887

let activeEMSolution = null;
let currentEMBasket = null;

if (CS.SM.registerPlugin) {
    window.document.addEventListener("SolutionConsoleReady", async function () {
        await CS.SM.registerPlugin("Enterprise Mobility").then((EMPlugin) => {
            console.log("Plugin registered for Enterprise Mobility");
            EMPlugin_updatePlugin(EMPlugin);
        });
    });
}

function EMPlugin_updatePlugin(EMPlugin) {
    window.document.addEventListener("SolutionSetActive", async function (e) {
        try {
            activeEMSolution = activeEMSolution == null ? await CS.SM.getActiveSolution() : activeEMSolution;
            console.log("lock status ", activeEMSolution.commercialLock);
            if (activeEMSolution.componentType && activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
                currentEMBasket = currentEMBasket == null ? await CS.SM.getActiveBasket() : currentEMBasket;
                await CommonUtills.getBasketData(currentEMBasket);
               
                window.currentSolutionName = activeEMSolution.name; //Added by Venkat to Hide OOTB OE Console Button
                
                //EDGE-198536 Start: existing code moved inside active solution check
				window.addEventListener("message", EMPlugin_handleIframeMessage);
				setInterval(EMPlugin_processMessagesFromIFrame, 500);
				document.addEventListener(
					"click",
					function (e) {
						e = e || window.event;
						var target = e.target || e.srcElement;
						var text = target.textContent || target.innerText;
						if (text && text.toLowerCase() === "mobile subscription") {
							if (basketStage !== "Contract Accepted") {
								Utils.updateComponentLevelButtonVisibility("Order Enrichment", false, false);
								Utils.updateComponentLevelButtonVisibility("Bulk Enrichment New", false, false); //added by shubhi EDGE-137466
							}
							Utils.updateCustomButtonVisibilityForBasketStage();
							// Import button is hidden via css : refer OEStyle.css
						}
					},
					false
				);
				//EDGE-198536 End: existing code moved inside active solution check
                let mobileSubscriptionComponent = activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                pricingUtils.setIsDiscountCheckNeeded(mobileSubscriptionComponent.name);
                Utils.updateImportConfigButtonVisibility(); // Added for EDGE-131531
                if (skipsave == true) {
                    return Promise.resolve(false);
                }
                await Utils.loadSMOptions();
                if (window.BasketChange === "Change Solution") 
					//await EMPlugin_UpdateRelatedConfigForChild(); // EDGE-190170 //DIGI-23866
					await	RedemptionUtils.calculateBasketRedemption(currentEMBasket, basketNum);// EDGE-190170
					await	RedemptionUtils.displayCurrentFundBalanceAmt();// EDGE-190170
					await	CommonUtills.setBasketChange();// EDGE-190170
					await EMPlugin_addDefaultEMOEConfigs();
					// EDGE-212827 : moved after delivery 
					if (basketStage === "Contract Accepted" || basketStage === "Enriched") {
						await EMPlugin_setCMPTabsVisibility(); // EDGE-174218 akanksha added
						await activeEMSolution.validate(); //EDGE-174218 akanksha added
						activeEMSolution.lock("Commercial", false);
					}
                    
                    EMPlugin_CheckErrorsOnSolution(activeEMSolution); //INC000093772606
                if (accountId != null) {
                    CommonUtills.setAccountID(ENTERPRISE_COMPONENTS.enterpriseMobility, accountId);
                }
                // Laxmi Changes for EDGE-142321 -
                let inputMapPOR = {};
                await currentEMBasket.performRemoteAction("SolutionHelperPORPermissionChk", inputMapPOR).then((values) => {
                    if (values["hasPortOutReversalPermission"]) hasPortOutReversalPermission = values["hasPortOutReversalPermission"];
                });
                // Changes END for EDGE-142321

				//EMPlugin_setEMOETabsVisibility(); //EDGE-174218 akanksha commented
				//EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
				//await EMPlugin_checkConfigurationSubscriptionsForEM();

                await EMPlugin_checkConfigurationSubscriptionStatus();
                await EMPlugin_checkConfigurationServiceForEM();

                EMPlugin_updateFieldsVisibilityAfterSolutionLoad(activeEMSolution);
                EMPlugin_updateDeviceEnrollmentAfterSolutionLoad();
                EMPlugin_updateChangeTypeAttribute();
                EMPlugin_updateStatusAfterSolutionLoad();
                //pricingUtils.handleChargeVisibilityonLoad();
                await pricingUtils.resetCustomAttributeVisibility();

                // Added by Laxmi EDGE-127421 - Pass the OfferID for CMP and the AccountId and get if isPaymentTypeOneFund is true or false
                let inputMapOneFund = {};
                //let offerID = 'DMCAT_Offer_000646';
                inputMapOneFund["accountId"] = accountId;
                inputMapOneFund["offerID"] = "DMCAT_Offer_000646";
                await EMPlugin_checkContractingStatus(inputMapOneFund);

                //EDGE-109925 - render page on PRM, start
                let map = {};
                map["GetSiteId"] = "";
                map["getUserTheme"] = "";
                await currentEMBasket.performRemoteAction("SolutionActionHelper", map).then((result) => {
                    communitySiteId = result["GetSiteId"];
                    userThemeValue = result["getUserTheme"];
                });
                //EDGE-109925 - render page on PRM, end
                Utils.updateCustomButtonVisibilityForBasketStage();

                //Added by Aman Soni as a part of EDGE-148455 || Start
                if (activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
                    if (basketChangeType === "Change Solution" && Object.values(activeEMSolution.schema.configurations)[0].replacedConfigId && Object.values(activeEMSolution.schema.configurations)[0].replacedConfigId !== null) {
                        let componentMap = new Map();
                        let componentMapattr = {};
                        let billingAccLook = Object.values(activeEMSolution.schema.configurations)[0].getAttribute("BillingAccountLookup");
                        componentMapattr["BillingAccountLookup"] = [];
                        componentMapattr["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                        componentMap.set(Object.values(activeEMSolution.schema.configurations)[0].guid, componentMapattr);
                        await CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap);
                        if (billingAccLook.value === null || billingAccLook.value === "") {
                            //changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                            CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.enterpriseMobility, "BillingAccountLookup", true);
                        }
                    }
                    if (basketChangeType !== "Change Solution" && activeEMSolution.components && Object.values(activeEMSolution.components).length > 0) {
                        Object.values(activeEMSolution.components).forEach((comp) => {
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                Object.values(comp.schema.configurations).forEach((config) => {
                                    if (config.replacedConfigId !== null) {
                                        CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.mobileSubscription, "initialActivationDate", false);
                                        CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.mobileSubscription, "BillingAccountNumber", false);
                                    }
                                });
                            }
                        });
                    }
                }
                //Added by Aman Soni as a part of EDGE-148455 || End
                if (basketChangeType === "Change Solution") {
                    if (!(basketStage === "Commercial Configuration" || basketStage === "Draft")) {
                        EM_updateChangeTypeOptions();
                    }
                    RedemptionUtils.populatebasketAmountforCancelCMP();
                    RedemptionUtils.populatebasketAmountforModifyCMP();
                    EMPlugin_UpdateMainSolutionChangeTypeVisibility(activeEMSolution);
                    await EMPlugin_UpdateAttributesForMacdOnSolution(activeEMSolution);
                    await EMPlugin_setAttributesReadonlyValueForsolution();
                    pricingUtils.setMainSolutionCorrelationID();

                    //Added by Aman Soni as a part of EDGE-135278 || Start
                    //CommonUtills.setSubBillingAccountNumberOnCLI('Mobile Subscription','initialActivationDate');
                    //CommonUtills.setSubBillingAccountNumberOnCLI('Mobile Subscription','BillingAccountNumber');
                    //Added by Aman Soni as a part of EDGE-135278 || End

                    //Added by Laxmi - EDGE-131531
                    EMPlugin_updateLinksAttributeEMS(activeEMSolution);
                    EMPlugin_handleDeviceShipping(activeEMSolution); // Added for EDGE-142321 - laxmi - changing the DeviceShipping Flag
					
                    //Added by Ankit as part of Bulk OE story - EDGE-137466 || start
					
                    if (basketStage === "Contract Accepted") {
                        await EMPlugin_setCMPTabsVisibility(); // EDGE-212827 //Added for DIGI-23866
                        validateOERules.resetCRDDatesinOESchema(ENTERPRISE_COMPONENTS.enterpriseMobility, ENTERPRISE_COMPONENTS.mobileSubscription);
                        validateOERules.resetDeliverDetailsinOESchema(ENTERPRISE_COMPONENTS.enterpriseMobility, ENTERPRISE_COMPONENTS.mobileSubscription);
                        await validateOERules.resetCRDDatesinCaseOfModify(activeEMSolution.name, mobileSubscriptionComponent.name);
                    }
                    //Added by Ankit as part of Bulk OE story - EDGE-137466 || End
                } else {
                    CommonUtills.genericUpdateCompLevelBtnVisibility("Check OneFund Balance", false, false, activeEMSolution.name);
                }
                //await EMPlugin_handlePortOutReversal(); // Laxmi Added for EDGE-142321 || Commented by Aman Soni for EDGE-164619
                //await EMPlugin_resetDeliveryDetailsinOESchema(); // laxmi Added for EDGE-142321 || EDGE-174218 akanksha commented

                //checkOERequirementsforMACD call Added by Laxmi - EDGE-142321

                //Reset CRDs when PCs added to MAC basket - moved this from MACD Observer as part of Spring20 upgrade
                // if (basketChangeType === 'Change Solution' && basketStage === 'Contract Accepted') {
                //          if (activeEMSolution.components && Object.values(activeEMSolution.components).length > 0) {
                //                         for(const comp of Object.values(activeEMSolution.components)) {
                //                                        if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
                //                                                       await validateOERules.resetCRDDatesinCaseOfModify(activeEMSolution.name,comp.name);
                //                                        }
                //                         }
                //          }
                // }
                if (basketStage === "Contract Accepted") {
                    activeEMSolution.lock("Commercial", true);
                }
            }
            console.log("lock status ", activeEMSolution.commercialLock);
        } catch (error) {
            console.log(error);
        }
        return Promise.resolve(true);
    });

    window.document.addEventListener("OrderEnrichmentTabLoaded", async function (e) {
        if (activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) || activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.mobileSubscription)) {
            console.log("afterOrderEnrichmentTabLoaded: ", e.detail.configurationGuid, e.detail.orderEnrichment.name);
            var schemaName = await Utils.getSchemaNameForConfigGuid(e.detail.configurationGuid);
            window.afterOETabLoaded(e.detail.configurationGuid, e.detail.orderEnrichment.name, schemaName, "");
        }
        return Promise.resolve(true);
    });

    EMPlugin.afterConfigurationAddedToMacBasket = async function (componentName, configuration) {
        try {
            // Arinjay Start - EDGE 221460
            try {
                CommonUtills.UpdateRelatedConfigForChildMac(configuration,componentName,null);
            } catch (error) {
                console.log(error);
            }
            // Arinjay End - EDGE 221460
            let solution = activeEMSolution;
            let component = solution.getComponentByName(componentName);
            let config = Object.values(component.schema.configurations)[0];
            let changeTypeAtrtribute = config.getAttribute("ChangeType");

            //await EMPlugin_UpdateRelatedConfigForChildMac(configuration);
            let value1 = await EMPlugin_getSelectedPlanForMobileSubscription(configuration);
            EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute.displayValue, value1);
            EMPlugin_updateFieldsVisibilityAfterSolutionLoad(solution);
            EMPlugin_updateChangeTypeAttribute(true);
            EMPlugin_UpdateMainSolutionChangeTypeVisibility(solution);
            await EMPlugin_UpdateAttributesForMacdOnSolution(solution);
            // Added By ankit || start EDGE-169973

            await EMPlugin_checkConfigurationSubscriptionStatus();
            await EMPlugin_checkConfigurationServiceForEM();
            //await EMPlugin_updateDeviceEnrollmentAfterSolutionLoad();
            await EMPlugin_updateStatusAfterSolutionLoad();
            await EMPlugin_setAttributesReadonlyValueForsolution();
            await EMPlugin_handleDeviceShipping(solution);
            await handlePortOutReversalForIndvConf(configuration.guid); //  Added for EDGE-142321//EDGE-169973 added by shubhi
            //await resetDeliveryDetailsinOESchemaForIndvConf(configuration); //  Added for EDGE-142321// added by shubhi || //EDGE-174218 akanksha commented
            // Added By ankit || End EDGE-169973
        } catch (error) {
            console.log(error);
        }
    };

    EMPlugin.afterOrderEnrichmentConfigurationAdd = function (component, configuration, orderEnrichmentConfiguration) {
        console.log("EM afterOrderEnrichmentConfigurationAdd", component.name, configuration, orderEnrichmentConfiguration);
        EMPlugin_initializeEMOEConfigs(orderEnrichmentConfiguration.guid);
        window.afterOrderEnrichmentConfigurationAdd(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

    EMPlugin.afterOrderEnrichmentConfigurationDelete = function (component, configuration, orderEnrichmentConfiguration) {
        window.afterOrderEnrichmentConfigurationDelete(component.name, configuration, orderEnrichmentConfiguration);
        return Promise.resolve(true);
    };

    // added by shubhi for EDGE-170124 cloned configuration as afterConfigurationAdd wa not working after upgrade to be reviewed before moving to higher orgs
    EMPlugin.afterConfigurationClone = async function (component, configurations, clonedConfiguration) {
        if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
            //await pricingUtils.resetDiscountAttributes(configuration.guid,component.name);
            var updateConfigMap = {};
            for (var config of configurations) {
                //Shweta added EDGE-185652 Adding number sequence for cloned config
                let configName = CommonUtills.genericSequenceNumberAddInConfigName(config, "OfferTypeString", "SelectPlanName");
                                
                config.status = false;
                config.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                updateConfigMap[config.guid] = [];
                updateConfigMap[config.guid].push(
                    {
                        name: "IsDiscountCheckNeeded",
                        value: true
                    },
                    {
                        name: "Price Schedule",

                        showInUi: false


                    },
                     //Shweta added EDGE-185652 Adding number sequence for cloned config
                     {
                        name: "ConfigName",
                        value: configName,
                        displayValue: configName

                    }
                    // Shweta Chnages End Here
                  
                );
                config.configurationName = configName; //Shweta added EDGE-185652 Adding number sequence for cloned config
            }
            let keys = Object.keys(updateConfigMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
            }
        }
        return Promise.resolve(true);
    };

    EMPlugin.afterConfigurationAdd = async function (component, configuration) {
        console.log("Parent Config Add - After", component.name, configuration);
        if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
            //await EMPlugin_subscribeToExpandButtonEvents(ENTERPRISE_COMPONENTS.mobileSubscription);
            EMPlugin_clonedataplanattributevalue(datapackallowance);
            await EMPlugin_addDefaultEMOEConfigs();
            //EDGE -142321 - Setting the Attributes after MS config Add
            await handlePortOutReversalForIndvConf(configuration.guid); // Laxmi Added for EDGE-142321
            //await resetDeliveryDetailsinOESchemaForIndvConf(configuration.guid); // laxmi Added for EDGE-142321 || EDGE-174218 akanksha commented
            if (configuration.replacedConfigId === undefined || configuration.replacedConfigId === null || configuration.replacedConfigId === "") {
                await pricingUtils.resetDiscountAttributes(configuration.guid, component.name);
            }
            EMPlugin_updateChangeTypeAttribute();
        }
        return Promise.resolve(true);
    };

    EMPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
        try {
            console.log("Inside afterAttributeUpdated" + component.name + "  attribute.name " + attribute.name + " attribute.value " + attribute.value);
            console.log("lock status ", activeEMSolution.commercialLock);
                                             activeEMSolution = await CS.SM.getActiveSolution();
            let product = activeEMSolution;
            let componentName = component.name;
            let guid = configuration.guid;
            let oldValue = oldValueMap["value"];
            let newValue = attribute.value;

            if (basketStage === "Contract Accepted") {
                activeEMSolution.lock("Commercial", false);
            }

            // console.log('Before Modify Update:');
            if (componentName === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                let emComponent = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility);
                let emConfigurations = activeEMSolution.getConfigurations();
                if (attribute.name === "ChangeType" && oldValue != newValue && (newValue === "Modify" || newValue === "Cancel")) {
                    console.log("Inside Modify Update");
                    SolutionChangeType = true;
                    await EMPlugin_setAttributesReadonlyValueForsolution();
                }
                if (attribute.name === "OfferType") {
                    let config;
                    if (Object.values(emConfigurations).length > 0) {
                        let componentMap = new Map();
                        let componentMapattr = {};
                        let msComponent = activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                        if (msComponent) {
                            let msConfigurations = msComponent.getConfigurations();
                            if (Object.values(msConfigurations).length > 0) {
                                Object.values(msConfigurations).forEach((cnfg) => {
                                    cnfg.status = false;
                                    cnfg.statusMessage = "Please reselect relevant plan.";
                                });
                            }
                        }

                        config = emComponent.getConfiguration(guid);
                        if (config) {
                            let configAttr = config.getAttribute("OfferId");
                            let updateConfigMap = {};
                            if (configAttr) {
                                let offerIdValue = configAttr.value;
                                let attribs = ["DataPackPlan", "DataPackAllowanceValue", "Data Pack RC", "Data Pack Allowance", "BonusDataAllowance", "BonusDataAllowanceValue", "BonusDataPromotionEndDate"];
                                attribs.forEach((value) => {
                                    Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.enterpriseMobility, value, true);
                                });
                                if (offerIdValue != "" && (offerIdValue === "DMCAT_Offer_000646" || offerIdValue === "DMCAT_Offer_000303")) {
                                    updateConfigMap[config.guid] = [
                                        {
                                            name: "ProdSpecId",
                                            value: "DMCAT_ProductSpecification_000420",
                                            displayValue: "DMCAT_ProductSpecification_000420"
                                        }
                                    ];
                                }
                                if (attribute.displayValue === "Data Pool" || attribute.displayValue === "Committed Data") {
                                    console.log("Is comitted");
                                    componentMapattr["DataPackPlan"] = [];
                                    componentMapattr["Data Pack RC"] = [];
                                    componentMapattr["DataPackAllowanceValue"] = [];
                                    componentMapattr["DataPackPlan"].push({ IsreadOnly: false, isVisible: true, isRequired: true });
                                    componentMapattr["Data Pack RC"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                                    componentMapattr["DataPackAllowanceValue"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                } else {
                                    console.log("Is fairplay");
                                    componentMapattr["DataPackPlan"] = [];
                                    componentMapattr["Data Pack RC"] = [];
                                    componentMapattr["DataPackAllowanceValue"] = [];
                                    componentMapattr["BonusDataAllowance"] = [];
                                    componentMapattr["BonusDataAllowanceValue"] = [];
                                    componentMapattr["BonusDataPromotionEndDate"] = [];
                                    componentMapattr["DataPackPlan"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                    componentMapattr["Data Pack RC"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                    componentMapattr["DataPackAllowanceValue"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                    componentMapattr["BonusDataAllowance"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                    componentMapattr["BonusDataAllowanceValue"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                    componentMapattr["BonusDataPromotionEndDate"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                                }
                                componentMap.set(config.guid, componentMapattr);
                                Object.values(activeEMSolution.orderEnrichments).forEach((oeSchema) => {
                                    if (oeSchema.name.toLowerCase() === "allowance") {
                                        var found = false;
                                        if (config.orderEnrichmentList) {
                                            var oeConfig = config.orderEnrichmentList.filter((oe) => {
                                                return oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId;
                                            });
                                            if (oeConfig && oeConfig.length > 0) found = true;
                                        }
                                        if (found) {
                                            console.log("oeConfig", oeConfig);
                                            oeGUIDs = [];
                                            oeConfig.forEach((conf) => {
                                                oeGUIDs.push(conf.guid);
                                            });
                                            // delete oe records
                                            oeGUIDs.forEach((oeGUID) => {
                                                activeEMSolution.deleteOrderEnrichmentConfiguration(config.guid, oeGUID);
                                            });
                                        }
                                        // add allowances NC records
                                        //EMPlugin_addAllowancesOEConfigs(product.name, config.guid, oeSchema.id, newValue, '');
                                    }
                                });
                                updateConfigMap[config.guid] = [];
                                updateConfigMap[config.guid].push({
                                    name: "isPaymentTypeOneFund",
                                    value: isPaymentTypeOneFund,
                                    displayValue: isPaymentTypeOneFund,
                                    showInUi: false,
                                    readOnly: true
                                });
                            }
                            let keys = Object.keys(updateConfigMap);
                            for (let i = 0; i < keys.length; i++) {
                                await emComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                            }
                            CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap);
                        }
                    }
                    //await EMPlugin_updateSolutionNameEM(); // Added as part of EDGE-149887
                    await CommonUtills.genericUpdateSolutionName(emComponent, config, ENTERPRISE_COMPONENTS.enterpriseMobility + "_" + attribute.displayValue, ENTERPRISE_COMPONENTS.enterpriseMobility + "_" + attribute.displayValue);
                }
                if (attribute.name === "DataPackPlan") {
                    if (Object.values(emConfigurations).length > 0) {
                        let config = emComponent.getConfiguration(guid);
                        if (config) {
                            let configAttr = config.getAttribute("DataPackPlan");
                            if (configAttr) {
                                var priceItemid = configAttr.value;
                                let inputMap = {};
                                if (priceItemid !== "") {
                                    inputMap["priceItemId"] = priceItemid;
                                    var allowanceRecId = null;
                                    var allowanceValue = null;
                                    await currentEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap).then((response) => {
                                        if (response && response["allowances"] != undefined) {
                                            console.log("allowances", response["allowances"]);
                                            if (response["allowances"].length > 1) {
                                                response["allowances"].forEach(async (a) => {
                                                   allowanceRecId = a.cspmb__allowance__c;
                                                    allowanceRecName = a.cspmb__allowance__r.Name;
                                                    allowanceValue = a.cspmb__allowance__r.Value__c + " " + a.cspmb__allowance__r.Unit_Of_Measure__c;
                                                    allowanceExternalId = a.cspmb__allowance__r.External_Id__c;
                                                    allowanceEndDate = a.cspmb__allowance__r.endDate__c;
                                                    console.log("jainish.. " + allowanceValue);
                                                    let updateConfigMap = {};
                                                    updateConfigMap[config.guid] = [];
                                                    if (allowanceExternalId.includes("DMCAT_Allowance_000805")) {
                                                        let attribData_Pack_Allowance = config.getAttribute("Data Pack Allowance");
                                                        if (attribData_Pack_Allowance && allowanceRecId != "") {
                                                            updateConfigMap[config.guid].push({
                                                                name: "Data Pack Allowance",
                                                                value: allowanceRecId,
                                                                displayValue: allowanceRecId
                                                            });
                                                        }
                                                        let attribDataPackAllowance = config.getAttribute("DataPackAllowanceValue");
                                                        if (attribDataPackAllowance && allowanceRecId != "") {
                                                            updateConfigMap[config.guid].push({
                                                                name: "DataPackAllowanceValue",
                                                                value: allowanceValue,
                                                                displayValue: allowanceValue
                                                            });
                                                            datapackallowance = allowanceValue;
                                                        }
                                                    }
                                                    if (allowanceExternalId.includes("DMCAT_Allowance_000877")) {
                                                        let attribBonusDataAllowance = config.getAttribute("BonusDataAllowance");
                                                        if (attribBonusDataAllowance && allowanceRecId != "") {
                                                            updateConfigMap[config.guid].push({
                                                                name: "BonusDataAllowance",
                                                                value: allowanceRecId,
                                                                displayValue: allowanceRecName,
                                                                readOnly: true
                                                            });
                                                        }
                                                        let attribBonusDataAllowanceValue = config.getAttribute("BonusDataAllowance");
                                                        if (attribBonusDataAllowanceValue && allowanceValue != "") {
                                                            updateConfigMap[config.guid].push({
                                                                name: "BonusDataAllowanceValue",
                                                                value: allowanceValue,
                                                                displayValue: allowanceValue,
                                                                showInUi: true
                                                            });
                                                        }
                                                        let attribBonusDataPromotionEndDate = config.getAttribute("BonusDataPromotionEndDate");
                                                        if (attribBonusDataPromotionEndDate && allowanceEndDate != "") {
                                                            updateConfigMap[config.guid].push({
                                                                name: "BonusDataPromotionEndDate",
                                                                value: allowanceEndDate,
                                                                displayValue: allowanceEndDate
                                                            });
                                                        }
                                                    }
                                                    await emComponent.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
                                                    EMPlugin_clonedataplanattributevalue(datapackallowance);
                                                });
                                            } else {
                                                response["allowances"].forEach(async (a) => {
                                                    allowanceRecId = a.cspmb__allowance__c;
                                                    allowanceRecName = a.cspmb__allowance__r.Name;
                                                    allowanceValue = a.cspmb__allowance__r.Value__c + " " + a.cspmb__allowance__r.Unit_Of_Measure__c;
                                                    allowanceExternalId = a.cspmb__allowance__r.External_Id__c;
                                                    allowanceEndDate = a.cspmb__allowance__r.endDate__c;
                                                    console.log("jainish.. " + allowanceValue);
                                                    let updateConfigMap = {};
                                                    updateConfigMap[config.guid] = [];
                                                    let attribData_Pack_Allowance = config.getAttribute("Data Pack Allowance");
                                                    if (attribData_Pack_Allowance && allowanceRecId != "") {
                                                        updateConfigMap[config.guid].push({
                                                            name: "Data Pack Allowance",
                                                            value: allowanceRecId,
                                                            displayValue: allowanceRecId
                                                        });
                                                    }
                                                    let attribDataPackAllowanceValue = config.getAttribute("DataPackAllowanceValue");
                                                    if (attribDataPackAllowanceValue && allowanceValue != "") {
                                                        updateConfigMap[config.guid].push({
                                                            name: "DataPackAllowanceValue",
                                                            value: allowanceValue,
                                                            displayValue: allowanceValue
                                                        });
                                                        datapackallowance = allowanceValue;
                                                    }
                                                    let attribBonusDataAllowance = config.getAttribute("BonusDataAllowance");
                                                    if (attribBonusDataAllowance) {
                                                        updateConfigMap[config.guid].push({
                                                            name: "BonusDataAllowance",
                                                            value: "",
                                                            displayValue: "",
                                                            showInUi: false,
                                                            readOnly: true
                                                        });
                                                    }
                                                    let attribBonusDataAllowanceValue = config.getAttribute("BonusDataAllowanceValue");
                                                    if (attribBonusDataAllowanceValue) {
                                                        updateConfigMap[config.guid].push({
                                                            name: "BonusDataAllowanceValue",
                                                            value: "",
                                                            displayValue: "",
                                                            showInUi: false
                                                        });
                                                    }
                                                    let attribBonusDataPromotionEndDate = config.getAttribute("BonusDataPromotionEndDate");
                                                    if (attribBonusDataPromotionEndDate) {
                                                        updateConfigMap[config.guid].push({
                                                            name: "BonusDataPromotionEndDate",
                                                            value: "",
                                                            displayValue: "",
                                                            showInUi: false
                                                        });
                                                    }
                                                    await emComponent.updateConfigurationAttribute(config.guid, updateConfigMap[config.guid], true);
                                                    EMPlugin_clonedataplanattributevalue(datapackallowance);
                                                });
                                            }
                                        } else {
                                            console.log("no response");
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
            }

            if (componentName === ENTERPRISE_COMPONENTS.mobileSubscription) {
                let msComponent = activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                let msConfigurations = msComponent.getConfigurations();
                let emConfigurations = activeEMSolution.getConfigurations();
                if (attribute.name === "DisconnectionDate" || attribute.name === "RedeemFund") {
                    console.log("Inside ETC calculation hook");
                    //EDGE-138631 - Added to validate Disconnection Date is not in past.
                    //if(component.name === ENTERPRISE_COMPONENTS.mobileSubscription && attribute.name === 'DisconnectionDate'){
                    if (attribute.name === "DisconnectionDate") {
                        EMPlugin_validateDisconnectionDate(componentName, configuration.guid, newValue);
                        EMPlugin_calculateTotalETCValue(configuration.guid);
                    }
                    //added by Romil
                    RedemptionUtils.calculateBasketRedemption(currentEMBasket, basketNum);
                    RedemptionUtils.displayCurrentFundBalanceAmt();
                    RedemptionUtils.populatebasketAmountforCancelCMP();
                    if (attribute.name === "RedeemFund") {
                        await calcDeviceRedeemFundGST(guid, newValue, componentName); //Added: EDGE-190802
                    }
                } //EDGE-81135 : Cancellation of CMP
                if (basketChangeType === "Change Solution" && attribute.name === "ChangeType") {
					//EMPlugin_setEMOETabsVisibility(); //EDGE-174218 akanksha commented
                    EMPlugin_ChangeOptionValue(guid);
                    let result = await EMPlugin_getSelectedPlanForMobileSubscription(guid);
                    EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(guid, newValue, result);
                    EMPlugin_updateFieldsVisibilityAfterSolutionLoad(product);

                    let updateMapFundNew = new Map();
                    let componentMapForFund = new Map();
                    let visible = newValue === "Cancel" ? true : false;
                    EMPlugin_updateAttributeVisibility(componentName, "CancellationReason", guid, false, visible, visible);
                    if (!visible) {
                        let attribs = ["CancellationReason", "DisconnectionDate", "EarlyTerminationCharge", "OneOffChargeGST"];
                        attribs.forEach((value) => {
                            Utils.emptyValueOfAttribute(guid, componentName, value, false);
                        });
                        // Utils.emptyValueOfAttribute(guid, componentName, 'CancellationReason', false);
                        // Added as part of EDGE-140967\\ Start
                        // Utils.emptyValueOfAttribute(guid, componentName, 'DisconnectionDate', false);
                        // Utils.emptyValueOfAttribute(guid, componentName, 'EarlyTerminationCharge', false);
                        // Utils.emptyValueOfAttribute(guid, componentName, 'OneOffChargeGST', false);
                        //Utils.emptyValueOfAttribute(guid, componentName, 'RedeemFund', false);
                        //componentMapForFund.set('RedeemFund',0.00);
                        //updateMapFundNew.set(guid,componentMapForFund);
                        updateMapFundNew.set(guid, { RedeemFund: 0.0, RedeemFundIncGST: 0.0 }); //Added: EDGE-190802
                        //CommonUtills.UpdateValueForSolution(ENTERPRISE_COMPONENTS.mobileSubscription,updateMapFundNew);
                        // Added as part of EDGE-140967\\ End
                    }
                    EMPlugin_CheckRedeemFundDiscount(guid); //Added by ankit as part of EDGE-140967
                }
                if (attribute.name === "ChangeTypeDevice" || attribute.name === "RedeemFund") {
                    console.log("Inside Modify Update for Cancel Flag");
                    IsDeviceChange = true;
                    EMPlugin_checkCancelFlagAndETCForNonBYOPlans(guid);
                    EMPlugin_updateRemainingTermAfterSave(guid);
                    await RedemptionUtils.calculateBasketRedemption(currentEMBasket, basketNum);
                    await RedemptionUtils.displayCurrentFundBalanceAmt();
                    await RedemptionUtils.populatebasketAmountforModifyCMP();
                    if (basketChangeType === "Change Solution" && attribute.name === "RedeemFund") {
                        await EMPlugin_CheckRedeemFundDiscount(guid); //Added by ankit as part of EDGE-140967
                        await EMPlugin_CheckRedeemFundUpdate(guid); //Added by ankit as part of EDGE-140967
                        await calcDeviceRedeemFundGST(guid, newValue, componentName); //Added: EDGE-190802
                    }
                }
                if (attribute.name === "ChangeTypeDevice" && oldValue != newValue) {
                    console.log("Inside Modify Update for Cancel Flag");
                    //Utils.emptyValueOfAttribute(guid, componentName, 'RedeemFund', false);
                    if (newValue !== "Payout") EMPlugin_checkRemainingTermForBYOPlans(guid);
                    EMPlugin_setPlanDiscount(guid, componentName);
                }
                if (attribute.name === "ChangeType" && oldValue != newValue && (newValue === "Modify" || newValue === "Cancel")) {
                    console.log("Inside Modify Update");
                    IsMACBasket = true;
                    await EMPlugin_updateRemainingTermAfterSolutionLoad();
                    await EMPlugin_updateCancelDeviceTypeAfterSolutionLoad(guid);
                    await EMPlugin_setAttributesReadonlyValueForsolution();
                    //added by Romil
                    await RedemptionUtils.calculateBasketRedemption(currentEMBasket, basketNum); // EDGE-190170
                    await RedemptionUtils.displayCurrentFundBalanceAmt(); // EDGE-190170
                    await RedemptionUtils.populatebasketAmountforModifyCMP(); // EDGE-190170
					await EMPlugin_EnableAttributesforModify(guid); // EDGE-190170
                    if (newValue === "Cancel") {
                        await EMPlugin_DeviceAddconfigurationError(guid);
                        await RedemptionUtils.populatebasketAmountforCancelCMP(); //EDGE-190170
                    }
                    await EMPlugin_handleDeviceStatusAndPlanDiscount(guid);
                }
                if (attribute.name === "SelectPlanType") {
                    let componentMap = new Map();
                    let componentMapattr = {};
                    let config = msComponent.getConfiguration(guid);
                    if (config) {
                        let attribs = ["BussinessId_Addon", "InternationalDirectDial", "MessageBank", "IDD Charge", "Select Plan", "MessageBank RC"];
                        attribs.forEach((value) => {
                            Utils.emptyValueOfAttribute(config.guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                        });
                        pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                        if (attribute.displayValue === "Data") {
                            let attributes = ["PlanShadowTCV", "IDDShadowTCV", "PlanShadowTCV", "BussinessId_PI"];
                            attributes.forEach((value) => {
                                Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                            });
                            pricingUtils.resetDiscountAttributes(config.guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                            pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                            pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                            componentMapattr["InternationalDirectDial"] = [];
                            componentMapattr["MessageBank"] = [];
                            componentMapattr["MessageBank RC"] = [];
                            componentMapattr["IDD Charge"] = [];
                            componentMapattr["InternationalDirectDial"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                            componentMapattr["MessageBank"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                            componentMapattr["MessageBank RC"].push({ IsreadOnly: true, isVisible: false, isRequired: false });
                            componentMapattr["IDD Charge"].push({ IsreadOnly: true, isVisible: false, isRequired: false });
                        } else {
                            componentMapattr["InternationalDirectDial"] = [];
                            componentMapattr["MessageBank"] = [];
                            componentMapattr["MessageBank RC"] = [];
                            componentMapattr["IDD Charge"] = [];
                            componentMapattr["InternationalDirectDial"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                            componentMapattr["MessageBank"].push({ IsreadOnly: false, isVisible: true, isRequired: true });
                            componentMapattr["MessageBank RC"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            componentMapattr["IDD Charge"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                        }
                    }
                    componentMap.set(guid, componentMapattr);
                    console.log("SelectPlan Hook", componentMap);
                    CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.mobileSubscription, componentMap);
                }
                if (attribute.name === "Select Plan") {
                    // Added as part of EDGE-134880 by ankit || start
                    if (oldValue !== newValue) {
                        skipsave = true; //added by ankit EDGE-132203
                    }
                    let inputMapCLI = {};
                    inputMapCLI["guid"] = guid;
                    inputMapCLI["basketId"] = basketId;
                    // Added as part of EDGE-134880 by ankit || END
                    let updateConfigMapsubs = {};
                    var selectedPlan = newValue;
                    var changeTypeAtrtribute = "";
                    var selectPlanDisplayValue = "";
                    var isRelatedDeviceAdded = false;
                    var relatedConfigurationID = "";
                    let inputMap = {};
                    isCommittedDataOffer = false;
                    inputMap["priceItemId"] = newValue;
                    inputMapCLI["solutionID"] = product.solutionId;
                    if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        let configAttr = emConfigurations[0].getAttribute("OfferType");
                        if (configAttr && configAttr.displayValue.includes("Committed Data")) {
                            isCommittedDataOffer = true;
                        }

                        let config = msComponent.getConfiguration(guid);
                        if (config) {
                            var PlanTypeSelected = "";
                            updateConfigMapsubs[config.guid] = [];
                            let attribs = ["InternationalDirectDial", "IDD Charge", "IDDAllowance", "IDD ChargeLookup", "MessageBank", "MessageBank RC", "PlanDiscountLookup", "TotalPlanBonus", "PlanShadowTCV", "IDDShadowTCV", "BussinessId_Addon"];
                            attribs.forEach((value) => {
                                Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                            });
                            pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                            pricingUtils.setIsDiscountCheckNeeded(ENTERPRISE_COMPONENTS.mobileSubscription); //Aditya-Samish For EDGE-132203 Error handling
                            pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                            pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi

                            let changeTypeAtrtribute = config.getAttribute("ChangeType");
                            let planTypeString = config.getAttribute("PlanTypeString");
                            if (planTypeString && planTypeString.value === "Data") PlanTypeSelected = "Data";

                            let selectPlan = config.getAttribute("Select Plan");
                            if (selectPlan && selectPlan.value !== "") {
                                selectPlanDisplayValue = selectPlan.displayValue;
                                console.log("Selected Plan --> " + selectPlanDisplayValue);
                                if (selectPlan.displayValue === "Local" || selectPlan.displayValue === "Local BYO" || selectPlan.displayValue === "Basic" || selectPlan.displayValue === "Entry" || selectPlan.displayValue === "Standard") {
                                    updateConfigMapsubs[config.guid].push({
                                        name: "InternationalDirectDial",
                                        readOnly: false
                                    });
                                }
                                if (selectPlan.displayValue !== "Local" && !show && changeTypeAtrtribute && changeTypeAtrtribute.value !== "Modify" && changeTypeAtrtribute.value !== "Cancel" && selectPlan.displayValue !== "Basic") {
                                    //Added by Venkata for EDGE- 30181
                                    EMPlugin_showMDMtenancynotification();
                                }
                                if ((selectPlan.displayValue === "XX-Large Data SIM BYO" || selectPlan.displayValue === "X-Large Data SIM BYO") && !datashow && config.guid === guid && changeTypeAtrtribute && changeTypeAtrtribute.value !== "Modify" && changeTypeAtrtribute.value !== "Cancel") {
                                    //Added by Ankit for EDGE-112367
                                    EMPlugin_showDataSimnotification();
                                }
                                //Change Ends by Aditya
                            }

                            //Added this block here as part of EDGE-147709 by ankit || start
                            if (attribute.displayValue === "Basic" && isCommittedDataOffer === true) {
                                console.log("Inside If loop");
                                updateConfigMapsubs[config.guid].push({
                                    name: "MDMEntitled",
                                    value: false,
                                    displayValue: false
                                });
                            } else {
                                console.log("Inside else loop");
                                updateConfigMapsubs[config.guid].push({
                                    name: "MDMEntitled",
                                    value: true,
                                    displayValue: true
                                });
                            }
                            //Added this block here as part of EDGE-147709 by ankit || End
                            let keys = Object.keys(updateConfigMapsubs);
                            for (let i = 0; i < keys.length; i++) {
                                await msComponent.updateConfigurationAttribute(keys[i], updateConfigMapsubs[keys[i]], true);
                            }

                            // 2
                            if (config.guid == guid && selectedPlan != "") {
                                if (config.relatedProductList && config.relatedProductList.length > 0) {
                                    isRelatedDeviceAdded = false;
                                    isRelatedDevicePayout = false;
                                    config.relatedProductList.forEach((relatedConfig) => {
                                        if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === "Related Component") {
                                            isRelatedDeviceAdded = true;
                                        }
                                        let attribChangeTypeAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                        if (attribChangeTypeAttribute && attribChangeTypeAttribute.value === "PayOut") {
                                            isRelatedDevicePayout = true;
                                        }
                                    });
                                }
                                if (changeTypeAtrtribute && changeTypeAtrtribute.value !== "Modify" && changeTypeAtrtribute.value !== "Cancel" && changeTypeAtrtribute.value !== "Active") {
                                    EMPlugin_validateMobileDevice(attribute.displayValue, config);
                                }
                                console.log("Before Inside selectPlanDisplayValue Validation  " + isRelatedDeviceAdded);
                                if (selectPlanDisplayValue != "" && !selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === false && isCommittedDataOffer === false) {
                                    console.log("Inside selectPlanDisplayValue Validation  ");
                                    config.status = false;
                                    config.statusMessage = "Please add One mobile Device.";
                                } else if (selectPlanDisplayValue != "" && selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false) {
                                    console.log("Inside selectPlanDisplayValue Validation  ");
                                    config.status = false;
                                    config.statusMessage = "Please remove the added mobile device because BYO plan does not allow purchase of mobile device";
                                } else {
                                    //Aditya-Samish For EDGE-132203 Error handling
                                    pricingUtils.setIsDiscountCheckNeeded(ENTERPRISE_COMPONENTS.mobileSubscription);
                                }
                                let inputMap = {};
                                inputMap["priceItemId"] = selectedPlan;
                                //function call to recalculate PlanDiscount value
                                let deviceRecord = null;
                                let planRecord = selectedPlan;
                                let attribInContractDeviceRecId = config.getAttribute("InContractDeviceRecId");
                                if (attribInContractDeviceRecId && attribInContractDeviceRecId.value != null) {
                                    deviceRecord = attribInContractDeviceRecId.value;
                                    EMPlugin_updatePlanDiscount(config, planRecord, deviceRecord);
                                }
                                currentEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap).then(async (response) => {
                                    console.log("response", response);
                                    if (response && response["allowances"] != undefined) {
                                        console.log("allowances", response["allowances"]);
                                        response["allowances"].forEach((a) => {
                                            if (a.Id != null) {
                                                allowanceRecId = a.cspmb__allowance__r.Id;
                                                allowanceValue = a.cspmb__allowance__r.Name;
                                            }
                                        });
                                        console.log("allowanceRecId ", allowanceValue);
                                        if (allowanceRecId != "") {
                                            let updateConfigMap2 = {};
                                            updateConfigMap2[config.guid] = [
                                                {
                                                    name: "PlanAllowance",
                                                    value: allowanceRecId,
                                                    displayValue: allowanceValue
                                                }
                                            ];

                                            console.log("updateConfigurationAttribute IDDallowance");
                                            let keys = Object.keys(updateConfigMap2);
                                            for (let i = 0; i < keys.length; i++) {
                                                await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                                            }
                                        }
                                    } else {
                                        console.log("no response");
                                    }
                                });
								CalculateIDDMessageBank(config, msComponent, PlanTypeSelected,inputMap);
								// INC000094141578 Fix starts
                              /* var addOnIDDCount = 0;
                                var addOnMsgBankCount = 0;
                                if (PlanTypeSelected !== "Data") {
                                    await currentEMBasket.performRemoteAction("MobileSubscriptionGetAddOnData", inputMap).then(async (response) => {
                                        if (response && response["addOnIDD"] != undefined) {
                                            console.log("response[addOnIDD] " + response["addOnIDD"]);
                                            addOnIDDCount = response["addOnIDD"].length;
                                        }
                                        if (response && response["addOnMsgBank"] != undefined) {
                                            console.log("response[addOnMsgBank] " + response["addOnMsgBank"]);
                                            addOnMsgBankCount = response["addOnMsgBank"].length;
                                        }
                                        if (addOnIDDCount === 1 && response["addOnIDD"][0].cspmb__Recurring_Charge__c === 0) {
                                            // Hitesh EDGE-146184
                                            let updateConfigMap2 = {};
                                            console.log("addOn Idd " + response["addOnIDD"][0].Id);
                                            updateConfigMap2[config.guid] = [];
                                            updateConfigMap2[config.guid].push(
                                                {
                                                    name: "InternationalDirectDial",
                                                    value: response["addOnIDD"][0].Id,
                                                    displayValue: response["addOnIDD"][0].AddOn_Name__c,
                                                    readOnly: true
                                                },
                                                {
                                                    name: "SelectIDD",
                                                    value: response["addOnIDD"][0].AddOn_Name__c,
                                                    displayValue: response["addOnIDD"][0].AddOn_Name__c
                                                }, // added for EDGE-162025
                                                {
                                                    name: "IDD Charge",
                                                    value: Number(response["addOnIDD"][0].cspmb__Recurring_Charge__c).toFixed(2),
                                                    displayValue: Number(response["addOnIDD"][0].cspmb__Recurring_Charge__c).toFixed(2)
                                                },
                                                {
                                                    name: "BussinessId_Addon",
                                                    value: response["addOnIDD"][0].cspmb__Add_On_Price_Item__r.Charge_Id__c,
                                                    displayValue: response["addOnIDD"][0].cspmb__Add_On_Price_Item__r.Charge_Id__c
                                                },
                                                {
                                                    name: "IDDReadOnlyFlag",
                                                    value: true,
                                                    displayValue: true
                                                }
                                                
                                            );

                                            if (updateConfigMap2[config.guid].length > 0) {
                                                let keys = Object.keys(updateConfigMap2);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                                                }
                                            }
                                        }
                                        if (addOnIDDCount === 0) {
                                            // Hitesh EDGE-146184
                                            let updateConfigMap2 = {};
                                            console.log("addOn Idd " + response["addOnIDD"][0].Id);
                                            updateConfigMap2[config.guid] = [];
                                            updateConfigMap2[config.guid].push({
                                                name: "IDDReadOnlyFlag",
                                                value: true,
                                                displayValue: true
                                            });
                                            if (updateConfigMap2[config.guid].length > 0) {
                                                let keys = Object.keys(updateConfigMap2);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                                                }
                                            }
                                        }
                                        if (addOnMsgBankCount) {
                                            let updateConfigMap2 = {};
                                            console.log("addOn MsgBank " + response["addOnMsgBank"][0].Id);
                                            updateConfigMap2[config.guid] = [];
                                            updateConfigMap2[config.guid].push(
                                                {
                                                    name: "MessageBank",
                                                    value: response["addOnMsgBank"][0].Id,
                                                    readOnly: false,
                                                    displayValue: response["addOnMsgBank"][0].cspmb__Add_On_Price_Item__r.Message_Bank__c
                                                },
                                                {
                                                    name: "MessageBank RC",
                                                    value: Number(response["addOnMsgBank"][0].cspmb__Recurring_Charge__c).toFixed(2),
                                                    displayValue: Number(response["addOnMsgBank"][0].cspmb__Recurring_Charge__c).toFixed(2)
                                                }
                                            );
                                            if (updateConfigMap2[config.guid].length > 0) {
                                                let keys = Object.keys(updateConfigMap2);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); // false added by shubhi 14/08
                                                }
                                            }
                                        }
                                    });
                                }*/
								//INC000094141578 Fix Ends
                            }

                            // update ParentPriceItem of related product
                            if (config.relatedProductList && config.relatedProductList.length > 0) {
                                let updateConfigMap = {};
                                config.relatedProductList.forEach((relatedConfig) => {
                                    if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === "Related Component") {
                                        if (config.guid == guid) {
                                            isRelatedDeviceAdded = true;
                                        }
                                        //relatedConfig.configurationId = relatedConfigurationID ;//commented for EDGE-170151
                                        let attribParentPriceItem = relatedConfig.configuration.getAttribute("ParentPriceItem");
                                        if (attribParentPriceItem) {
                                            updateConfigMap[relatedConfig.guid] = [
                                                {
                                                    name: "ParentPriceItem",
                                                    value: newValue,
                                                    displayValue: newValue
                                                }
                                            ];
                                        }
                                    }
                                });
                                let keys = Object.keys(updateConfigMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                }
                                console.log("before get IDD " + selectedPlan + selectPlanDisplayValue);
                            }
                        }
                    }
                }
                if (attribute.name === "SelectPlanName" && oldValue != newValue && newValue !== "" && newValue !== null) {
                    if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        let setUpdateMap ={};
                        let configName = CommonUtills.genericSequenceNumberAddInConfigName(configuration, "OfferTypeString", "SelectPlanName");
                        // Shweta Added EDGE-185652 Adding number Sequence in config Name
                        setUpdateMap[configuration.guid] = [];
                        setUpdateMap[configuration.guid] = [
                            {
                                name: "ConfigName",
                                value: configName,
                                displayValue: configName
                            }
                        ];
                        configuration.configurationName = configName;
                        let keys = Object.keys(setUpdateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await component.updateConfigurationAttribute(keys[i], setUpdateMap[keys[i]], false);
                        }
                        //Shweta Changaes End here
                        let config = msComponent.getConfiguration(guid);
                        if (config) {
                            let changeTypeAtrtribute = config.getAttribute("ChangeType");
                            let SelectPlanNameAttribute = config.getAttribute("SelectPlanName");
                            if (changeTypeAtrtribute.value === "Modify" || changeTypeAtrtribute.value === "Cancel") {
                                productInError = false;
                                if ((subsConfig.configurationName.includes("XX-Large Data SIM BYO") || subsConfig.configurationName.includes("X-Large Data SIM BYO")) && (newValue === "Data SIM $5" || newValue === "Data SIM $40")) {
                                    config.status = false;
                                    config.statusMessage = "change of plan not allowed.";
                                    productInError = true;
                                }
                                if ((subsConfig.configurationName.includes("Data SIM $5") || subsConfig.configurationName.includes("Data SIM $40")) && (newValue === "XX-Large Data SIM BYO" || newValue === "X-Large Data SIM BYO")) {
                                    config.status = false;
                                    config.statusMessage = "change of plan not allowed.";
                                    productInError = true;
                                }
                            }
                        }
                    }
                }
                if (attribute.name === "InternationalDirectDial") {
                    // Added as part of EDGE-134880 by ankit || start
                    if (oldValue !== newValue) {
                        skipsave = true; //added by ankit EDGE-132203
                    }
                    let inputMapCLI = {};
                    inputMapCLI["guid"] = guid;
                    inputMapCLI["basketId"] = basketId;
                    console.log("inputMapCLI::: ", inputMapCLI);

                    // Added as part of EDGE-134880 by ankit || END
                    console.log("here InternationalDirectDial " + newValue);
                    let attribs = ["PlanShadowTCV", "IDDShadowTCV"];
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });
                    //pricingUtils.resetisDiscountMobileSubscriptionSAttributes(guid); //added for  edge-123575 by shubhi
                    //Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_Addon', true);//edge-123575 by shubhi
                    //Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'BussinessId_PI', true);//edge-123575 by shubhi
                    pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                    pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                    pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                    if (newValue != null && newValue != "") {
                        inputMapCLI["solutionID"] = activeEMSolution.solutionId;
                        if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                            let config = msComponent.getConfiguration(guid);
                            if (config) {
                                let attributes = ["IDDAllowance", "IDD ChargeLookup", "BussinessId_Addon"];
                                attributes.forEach((value) => {
                                    Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                                });
                                let inputMap = {};
                                inputMap[newValue] = "getAddOn";
                                var addOnRecId = null;
                                var addOnValue = null;
                                var addOncharge = null;
                                await currentEMBasket.performRemoteAction("SolutionGetPricingRecords", inputMap).then(async (response) => {
                                    console.log("response", response);
                                    if (response && response["addOnList"] != undefined) {
                                        console.log("addOnList", response["addOnList"]);
                                        response["addOnList"].forEach((a) => {
                                            if (a.Id != null) {
                                                addOnRecId = a.Id;
                                                addOnValue = a.Name;
                                                addOncharge = a.Charge_Id__c;
                                            }
                                        });
                                        console.log("addOnRecId ", addOnRecId);
                                        if (addOnRecId != "") {
                                            let updateConfigMap1 = {};
                                            updateConfigMap1[config.guid] = [
                                                {
                                                    name: "IDD ChargeLookup",
                                                    value: addOnRecId,
                                                    displayValue: addOnValue
                                                },
                                                {
                                                    name: "BussinessId_Addon",
                                                    value: addOncharge,
                                                    displayValue: addOncharge
                                                }
                                            ];
                                            console.log("updateConfigurationAttribute IDDcharge");
                                            let keys = Object.keys(updateConfigMap1);
                                            for (let i = 0; i < keys.length; i++) {
                                                await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap1[keys[i]], false);
                                            }
                                        }
                                    } else {
                                        console.log("no response");
                                    }
                                });
                                if (addOnRecId != null) {
                                    var allowanceRecId = null;
                                    var allowanceValue = null;

                                    let inputMap2 = {};
                                    inputMap2["addOnPriceItemId"] = addOnRecId;

                                    await currentEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap2).then(async (response) => {
                                        console.log("response", response);
                                        if (response && response["allowances"] != undefined) {
                                            console.log("allowances", response["allowances"]);
                                            response["allowances"].forEach((a) => {
                                                if (a.Id != null) {
                                                    allowanceRecId = a.cspmb__allowance__r.Id;
                                                    allowanceValue = a.cspmb__allowance__r.Name;
                                                }
                                            });
                                            console.log("allowanceRecId ", allowanceValue);
                                            if (allowanceRecId != "") {
                                                let updateConfigMap2 = {};
                                                updateConfigMap2[config.guid] = [
                                                    {
                                                        name: "IDDAllowance",
                                                        value: allowanceRecId,
                                                        displayValue: allowanceValue
                                                    }
                                                ];
                                                console.log("updateConfigurationAttribute IDDallowance");
                                                let keys = Object.keys(updateConfigMap2);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                                                }
                                            }
                                        } else {
                                            console.log("no response");
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
                if (attribute.name === "IDD ChargeLookup") {
                    console.log("here IDD ChargeLookup " + newValue);
                    if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        if (product.components && Object.values(product.components).length > 0) {
                            let config = msComponent.getConfiguration(guid);
                            if (config) {
                                let attribs = ["IDDAllowance", "PlanShadowTCV", "IDDShadowTCV"];
                                attribs.forEach((value) => {
                                    Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                                });
                                pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                                pricingUtils.setIsDiscountCheckNeeded(ENTERPRISE_COMPONENTS.mobileSubscription); //Aditya-Samish For EDGE-132203 Error handling
                                pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                                pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                                if (newValue != null) {
                                    var allowanceRecId = null;
                                    var allowanceValue = null;
                                    let inputMap2 = {};
                                    inputMap2["addOnPriceItemId"] = newValue;
                                    currentEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap2).then(async (response) => {
                                        console.log("response", response);
                                        if (response && response["allowances"] != undefined) {
                                            console.log("allowances", response["allowances"]);
                                            response["allowances"].forEach((a) => {
                                                if (a.Id != null) {
                                                    allowanceRecId = a.cspmb__allowance__r.Id;
                                                    allowanceValue = a.cspmb__allowance__r.Name;
                                                }
                                            });
                                            console.log("allowanceRecId ", allowanceValue);
                                            if (allowanceRecId != "") {
                                                let updateConfigMap2 = {};
                                                updateConfigMap2[config.guid] = [
                                                    {
                                                        name: "IDDAllowance",
                                                        value: allowanceRecId,
                                                        displayValue: allowanceValue
                                                    }
                                                ];
                                                console.log("updateConfigurationAttribute IDDallowance");
                                                let keys = Object.keys(updateConfigMap2);
                                                for (let i = 0; i < keys.length; i++) {
                                                    await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                                                }
                                            }
                                        } else {
                                            console.log("no response");
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
                if (attribute.name === "Device Type") {
                    let attribs = ["MobileHandsetManufacturer", "MobileHandsetModel", "MobileHandsetColour", "PaymentTypeLookup", "ContractTerm", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ColourString", "PaymentTypeString", "ContractTermString"];
                    //Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, 'deviceTypeString', true);
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });
                }
                if (attribute.name === "MobileHandsetManufacturer") {
                    let attribs = ["MobileHandsetModel", "MobileHandsetColour", "PaymentTypeLookup", "ContractTerm", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ModelString", "ColourString", "PaymentTypeString", "ContractTermString"];
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });
                    let updateConfigMap = {};
                    updateConfigMap[guid] = [
                        {
                            name: "ManufacturerString",
                            value: attribute.displayValue,
                            displayValue: attribute.displayValue
                        }
                    ];
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                }
                if (attribute.name === "MobileHandsetModel") {
                    let attribs = ["MobileHandsetColour", "PaymentTypeLookup", "ContractTerm", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ColourString", "PaymentTypeString", "ContractTermString"];
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });

                    let updateConfigMap = {};
                    updateConfigMap[guid] = [
                        {
                            name: "ModelString",
                            value: attribute.displayValue,
                            displayValue: attribute.displayValue
                        }
                    ];
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                }
                if (attribute.name === "MobileHandsetColour") {
                    let attribs = ["PaymentTypeLookup", "ContractTerm", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "PaymentTypeString", "ContractTermString"];
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });

                    let updateConfigMap = {};
                    updateConfigMap[guid] = [
                        {
                            name: "ColourString",
                            value: attribute.displayValue,
                            displayValue: attribute.displayValue
                        }
                    ];
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                }
                if (attribute.name === "PaymentTypeLookup") {
                    let attribs = ["ContractTerm", "InContractDeviceEnrollEligibility", "DeviceEnrollment", "ContractTermString"];
                    attribs.forEach((value) => {
                        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                    });
                    let updateConfigMap = {};
                    updateConfigMap[guid] = [
                        {
                            name: "PaymentTypeString",
                            value: attribute.displayValue,
                            displayValue: attribute.displayValue
                        }
                    ];
                    console.log("entered PaymentTypeLookup updateConfigMap after===" + updateConfigMap);
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                }
                if (attribute.name === "InContractDeviceRecId") {
                    if (newValue != null) {
                        let deviceRecord = newValue;
                        let planRecord = null;
                        console.log("entering InContractDeviceRecId change");
                        if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                            let config = msComponent.getConfiguration(guid);
                            if (config) {
                                let attribs = ["PlanDiscountLookup", "TotalPlanBonus"];
                                attribs.forEach((value) => {
                                    Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                                });
                                let attribSelect_Plan = config.getAttribute("Select Plan");
                                if (attribSelect_Plan && attribSelect_Plan.value != null) {
                                    EMPlugin_updatePlanDiscount(config, attribSelect_Plan.value, deviceRecord);
                                }
                            }
                        }
                    }
                }
                if (attribute.name === "ContractTerm") {
                    if (newValue != null) {
                        let deviceRecord = newValue;
                        console.log("entering InContractDeviceRecId change");
                        if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                            Object.values(msConfigurations).forEach((parentConfig) => {
                                if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
                                    parentConfig.relatedProductList.forEach((relatedConfig) => {
                                        if (relatedConfig.guid === guid) {
                                            let attribs = ["PlanDiscountLookup", "TotalPlanBonus"];
                                            attribs.forEach((value) => {
                                                Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, true);
                                            });
                                            let configAttr = parentConfig.getAttribute("Select Plan");
                                            if (configAttr) {
                                                EMPlugin_updatePlanDiscount(parentConfig, configAttr.value, deviceRecord);
                                            }
                                            let cnfg = msComponent.getConfiguration(guid);
                                            let InContrctDevcEnrolEligib = cnfg.getAttribute("InContractDeviceEnrollEligibility");
                                            if (InContrctDevcEnrolEligib && (!InContrctDevcEnrolEligib.value || InContrctDevcEnrolEligib.value == "")) {
                                                var upmap = {};
                                                upmap[guid] = [
                                                    {
                                                        name: "DeviceEnrollment",
                                                        value: "NOT ELIGIBLE",
                                                        displayValue: "NOT ELIGIBLE",
                                                        showInUi: true,
                                                        readOnly: true,
                                                        options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
                                                    }
                                                ];
                                                let keys = Object.keys(upmap);
                                                for (let i = 0; i < keys.length; i++) {
                                                    msComponent.updateConfigurationAttribute(keys[i], upmap[keys[i]], true);
                                                }
                                            }
                                        }
                                    });
                                }
                            });
                        }
                    }

                    // 2nd instance
                    let updateConfigMap = {};
                    updateConfigMap[guid] = [
                        {
                            name: "RemainingTerm",
                            value: attribute.displayValue,
                            displayValue: attribute.displayValue
                        }
                    ];

                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }

                    if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        let configs = msComponent.getConfigurations();
                        Object.values(configs).forEach((parentConfig) => {
                            if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
                                parentConfig.relatedProductList.forEach(async (relatedProduct) => {
                                    if (relatedProduct.guid === guid) {
                                        let inContractDeviceCount = EMPlugin_getInContractMobileDevices(parentConfig);
                                        if (inContractDeviceCount > 1) {
                                            let cnfg = await msComponent.getConfiguration(parentConfig.guid);
                                            cnfg.status = false;
                                            cnfg.statusMessage = "There cannot be more than 1 device of payment type Contract for this plan.";
                                        } else {
                                            let updateConfigMap2 = {};
                                            updateConfigMap2[parentConfig.guid] = [
                                                {
                                                    name: "InContractDeviceRecId",
                                                    value: attribute.value,
                                                    displayValue: attribute.value
                                                }
                                            ];
                                            let keys = Object.keys(updateConfigMap2);
                                            for (let i = 0; i < keys.length; i++) {
                                                await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], true);
                                            }
                                        }
                                    }
                                });
                            }
                        });
                    }
                }
                //ankit added as part of EDGE-112367
                if (attribute.name === "InContractDeviceEnrollEligibility") {
                    if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        Object.values(msConfigurations).forEach((parentConfig) => {
                            let changeTypeAtrtribute = parentConfig.getAttribute("ChangeType");
                            if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
                                parentConfig.relatedProductList.forEach(async (relatedProduct) => {
                                    if (relatedProduct.guid === guid) {
                                        let updateConfigMap = {};
                                        let attr = relatedProduct.configuration.getAttribute("InContractDeviceEnrollEligibility");
                                        if (attr && attr.value != null && attr != "") {
                                            if (attr.value === "Eligible") {
                                                updateConfigMap[relatedProduct.guid] = [
                                                    {
                                                        name: "DeviceEnrollment",
                                                        value: "DO NOT ENROL",
                                                        displayValue: "DO NOT ENROL",
                                                        showInUi: true,
                                                        readOnly: false,
                                                        required: true,
                                                        options: [CommonUtills.createOptionItem("ENROL"), CommonUtills.createOptionItem("DO NOT ENROL")] //R34UPGRADE
                                                    }
                                                ];
                                            } else {
                                                updateConfigMap[relatedProduct.guid] = [
                                                    {
                                                        name: "DeviceEnrollment",
                                                        value: "NOT ELIGIBLE",
                                                        displayValue: "NOT ELIGIBLE",
                                                        showInUi: true,
                                                        readOnly: true,
                                                        options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
                                                                        
                                                    }
                                                ];
                                            }
                                        } else {
                                            updateConfigMap[relatedProduct.guid] = [
                                                {
                                                    name: "DeviceEnrollment",
                                                    value: "",
                                                    displayValue: "",
                                                    showInUi: false,
                                                    readOnly: false,
                                                    options: [CommonUtills.createOptionItem("")] //R34UPGRADE
                                                }
                                            ];
                                        }
                                        let keys = Object.keys(updateConfigMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                        }
                                    }
                                });
                            }
                        });
                    }
                }
                //Ritika added for EDGE-81135 : Cancellation of CMP
                if (attribute.name === "ChangeType" && oldValue != newValue && newValue === "Cancel") {
                    EMPlugin_check_cancellationOfAllCMPs();
                    console.log("Inside Cancel Update for ChangeType");

                    // EDGE-131531 - Hiding Price Schedule and Show Promotion and Discounts   in case of Cancel and displaying incase of Modify
                    //EMPlugin.updateAttributeVisibility = function (componentName, attributeName, guid,isReadOnly,isVisible, isRequired) {
                    EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "viewDiscounts", guid, true, false, false);
                    EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "Price Schedule", guid, true, false, false);
                }
                //added for  edge-123575 by shubhi
                if (attribute.name === "DP Plan") {
                    pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                    pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                    pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                }
                if (attribute.name === "ChangeType" && oldValue != newValue && newValue === "Modify") {
                    //EMPlugin.updateAttributeVisibility = function (componentName, attributeName, guid,isReadOnly,isVisible, isRequired) {
                    console.log("Its Modify --- Making links Visible!!!!!!!!");
                    EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "viewDiscounts", guid, false, true, false);
                    EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "Price Schedule", guid, false, false, false);
                    pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription);
                    // EDGE-131531 - changes end
                    if (oldValue === "Cancel") {
                        await EMPlugin_updatePricescheduleCheck(guid);
                    }
                }
                //Added by Laxmi - EDGE-142321 - Port Out Reversal
                if (attribute.name === "IsDiscountCheckNeeded" && newValue === true) {
                    console.log("Inside attribute IsDiscountCheckNeeded");
                    let cnfg = await msComponent.getConfiguration(guid);
                    cnfg.status = false;
                    cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                }
                //Commented for EDGE-164619 by Aman Soni || Start
                /* if (attribute.name === "UseExitingSIM" && oldValue != newValue) {
                                                                           var simShipping;
                                                                           if (newValue === true) simShipping = "FALSE";
                                                                           else simShipping = "TRUE";

                                                                           let updateConfigMap = {};
                                                                           updateConfigMap[guid] = [
                                                                                          {
                                                                                                         name: "ShippingRequired",
                                                                                                         value: simShipping,
                                                                                                         displayValue: simShipping
                                                                                          }
                                                                           ];
                                                                           let keys = Object.keys(updateConfigMap);
                                                                           for (let i = 0; i < keys.length; i++) {
                                                                                          await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                                                           }
                                                            } */
                //Commented for EDGE-164619 by Aman Soni || End
                // Common calls for Mobile Subscription

                //Added for EDGE-164619 by Aman Soni || Start
                if (attribute.name === "isPortOutReversal") {
                    await EM_handlePortOutReversalOnAttUpd(guid);
                }
                //Added for EDGE-164619 by Aman Soni || End
            }
            // update Total Plan Bonus
            if (componentName === ENTERPRISE_COMPONENTS.device) {
                if (attribute.name === "MROBonus") {
                    if (activeEMSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                        Object.values(msConfigurations).forEach((parentConfig) => {
                            if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
                                parentConfig.relatedProductList.forEach(async (relatedProduct) => {
                                    if (relatedProduct.guid === guid) {
                                        let cnfg = await comp.getConfiguration(parentConfig.guid);
                                        cnfg.status = true;
                                        cnfg.statusMessage = "";
                                    }
                                });
                            }
                        });
                    }
                }
                if (attribute.name === "TotalPlanBonus") {
                    pricingUtils.resetDiscountAttributes(guid, ENTERPRISE_COMPONENTS.mobileSubscription); //added for  edge-123575 by shubhi
                    pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility); //added for  edge-123575 by shubhi
                    pricingUtils.resetCustomAttributeVisibility(); //added for  edge-123575 by shubhi
                }
            }
            //console.log('end afterAttributeUpdated');
            window.afterAttributeUpdatedOE(componentName, configuration.guid, attribute, oldValue, newValue);
            show = false;

            await EMPlugin_CheckErrorsOnSolution(activeEMSolution);
            if (basketStage === "Contract Accepted") {
                activeEMSolution.lock("Commercial", true);
            }
            console.log("lock status ", activeEMSolution.commercialLock);
        //EDGE-191955 - Added validation to remind user to click on validate and save once OE is done
        if(componentName === 'Customer requested Dates' || componentName === 'Delivery details' || componentName === 'Mobility features') {
                let msComponent = activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                        if (msComponent) {
                            //let msConfigurations = msComponent.getConfigurations();
                            let varconfig = await msComponent.getConfiguration(window.activeGuid);
                            varconfig.status = false;
                            varconfig.statusMessage = "Click on Validate and Save to save your changes.";
                        }
            }
        //END -191955
        } catch (error) {
            console.log(error);
        }
        return Promise.resolve(true);
    };

    EMPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //DO NOT PUT IN HERE ANY ADDITIONAL CODE OR MODIFY THIS FUNCTION !!!
        //DO ALL CHANGES ONLY IN EMPlugin_saveSolutionEM !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        try {
            if (basketStage === "Contract Accepted") {
                activeEMSolution.lock("Commercial", false);
            }
            let terminateSave = true;
            executeSaveEM = true;
            console.log("beforeSave - entering", activeEMSolution, configurationsProcessed, saveOnlyAttachment, configurationGuids);
            terminateSave = await EMPlugin_saveSolutionEM(activeEMSolution);
            if (basketStage === "Contract Accepted") {
                activeEMSolution.lock("Commercial", true);
            }
            if (!terminateSave) return Promise.resolve(false);
            return Promise.resolve(true);
        } catch (error) {
            console.log(error);
        }
    };

    EMPlugin.afterSave = async function (result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
        try {
            console.log("afterSave - entering with basket Changed Type ", basketChangeType);

            //EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
            //await EMPlugin_checkConfigurationSubscriptionsForEM();

			// EDGE-174218 akanksha added 
			let solution = result.solution ;
			if (solution == null || solution == undefined) solution = await CS.SM.getActiveSolution();
			if (basketStage === "Contract Accepted") {
				activeEMSolution.lock("Commercial", false);
				await EMPlugin_setCMPTabsVisibility();// EDGE-174218 akanksha added
				await solution.validate(); // EDGE-174218 akanksha added
				
			}
			// EDGE-174218 akanksha ends

            //EDGE-131227 - Added to set Main Solution ChangeType to Active in Case of MAC.
            //await EMPlugin_checkConfigurationSubscriptionsForEM();
            await EMPlugin_checkConfigurationSubscriptionStatus();
            await EMPlugin_checkConfigurationServiceForEM();

            console.log("currentSolution ", activeEMSolution);
            console.log("currentSolution.name ", activeEMSolution.name);

            //Added by Aman Soni as a part of EDGE-148455 || Start
            if (activeEMSolution && activeEMSolution !== null && activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
                var componentMapASave = new Map();
                var componentMapattrAftSave = {};
                let configurations = activeEMSolution.getConfigurations();
                Object.values(configurations).forEach((config) => {
                    if (config.replacedConfigId && config.replacedConfigId != null) {
                        let billingAccLook = config.getAttribute("BillingAccountLookup");
                        if (billingAccLook && (billingAccLook.value === null || billingAccLook.value === "")) {
                            //changed '&&' to '||' as part of EDGE-156214 by Aman Soni
                            CommonUtills.setSubBillingAccountNumberOnCLI(ENTERPRISE_COMPONENTS.enterpriseMobility, "BillingAccountLookup", true);
                        }
                        componentMapattrAftSave["BillingAccountLookup"] = [];
                        componentMapattrAftSave["BillingAccountLookup"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                        componentMapASave.set(config.guid, componentMapattrAftSave);
                    }
                });
                CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMapASave);
            }
            //Added by Aman Soni as a part of EDGE-148455 || End

            if (basketChangeType === "Change Solution") {
                //added by Romil
                RedemptionUtils.calculateBasketRedemption(currentEMBasket, basketNum);
                RedemptionUtils.displayCurrentFundBalanceAmt();
                RedemptionUtils.populatebasketAmountforCancelCMP();
                RedemptionUtils.populatebasketAmountforModifyCMP();
                RedemptionUtils.checkConfigurationStatus();
                await EMPlugin_UpdateAttributesForMacdOnSolution(activeEMSolution);

                if (basketStage === "Commercial Configuration") {
                    validateOERules.resetCRDDatesinCaseOfModify(ENTERPRISE_COMPONENTS.enterpriseMobility, ENTERPRISE_COMPONENTS.mobileSubscription);
                    //validateOERules.checkOERequirementsforMACD(ENTERPRISE_COMPONENTS.enterpriseMobility,ENTERPRISE_COMPONENTS.mobileSubscription,ENTERPRISE_COMPONENTS.device); // added by shubhi for EDGE-137466 -
                    //Commented above method call - EDGE-142321 - instead calling it on Provide/Modify on Ccommercial COnfig -added below condition
                }
            } else {
                CommonUtills.genericUpdateCompLevelBtnVisibility("Check OneFund Balance", false, false, activeEMSolution.name);
            }
            EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave();

            Utils.updateCustomButtonVisibilityForBasketStage();
            EMPlugin_updateFieldsVisibilityAfterSolutionLoad(activeEMSolution);
            EMPlugin_updateDeviceEnrollmentAfterSolutionLoad();
            EMPlugin_updateChangeTypeAttribute();
            EMPlugin_UpdateMainSolutionChangeTypeVisibility(activeEMSolution);
            await EMPlugin_updateStatusAfterSolutionLoad();
            await pricingUtils.resetCustomAttributeVisibility();
            //pricingUtils.hideRecurringCharges(solution);
            if (window.currentSolutionName === ENTERPRISE_COMPONENTS.enterpriseMobility) {
                Utils.hideSubmitSolutionFromOverviewTab();
            }
            // added by shubhi for EDGE-137466 || end
            //(ENTERPRISE_COMPONENTS.mobileSubscription);//Added by Aman Soni as a part of EDGE-123593
            // added by shubhi for EDGE-137466 || start

            // Function is not present in OELogic hence commenting the same
            await Utils.updateActiveSolutionTotals();
            await CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
            console.log("at end afterSave");
            if (basketStage === "Contract Accepted") {
                activeEMSolution.lock("Commercial", true);
            }
        } catch (error) {
            CommonUtills.updateTransactionLogging('after Save error'); //DIGI-3162
            console.log(error);
        }
        CommonUtills.updateTransactionLogging('after Save success'); //DIGI-3162
        return Promise.resolve(true);
    };
    //Aditya: Spring Update for changing basket stage to Draft
    EMPlugin.afterSolutionDelete = function (solution) {
        CommonUtills.updateBasketStageToDraft();
        return Promise.resolve(true);
    };

    EMPlugin.afterRelatedProductDelete = async function (component, configuration, relatedProduct) {
        try {
            console.log("afterRelatedProductDelete", component, configuration, relatedProduct);
            let inContractDeviceCount = 0;
            let cnfg = await component.getConfiguration(configuration.guid);
            if (relatedProduct.name === "Device" && relatedProduct.type === "Related Component") {
                // reculculate totalPlanBonus
                await EMPlugin_calculateTotalMROBonus(component.name, configuration, relatedProduct);
                inContractDeviceCount = EMPlugin_getInContractMobileDevices(configuration);
                if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) pricingUtils.resetDiscountAttributes(configuration.guid, ENTERPRISE_COMPONENTS.mobileSubscription);
                cnfg.status = false;
                cnfg.statusMessage = 'Please Click on Generate "Net Price" to update pricing of items in the basket';
                skipsave = true; //added by ankit EDGE-132203
            }
            if (inContractDeviceCount > 1) {
                cnfg.status = false;
                cnfg.statusMessage = "There cannot be more than 1 In-Contract device for this plan.";
            }
            EMPlugin_CheckErrorsOnSolution(activeEMSolution);
            //EMPlugin_handlePortOutReversal(); // Laxmi Added for EDGE-142321 || Commented by Aman Soni for EDGE-164619
            //EMPlugin_resetDeliveryDetailsinOESchema(); // laxmi Added for EDGE-142321 || EDGE-174218 akanksha commented 
        } catch (error) {
            console.log(error);
        }

        return Promise.resolve(true);
    };

    EMPlugin.afterRelatedProductAdd = async function (component, configuration, relatedProduct) {
        try {
            console.log("afterRelatedProductAdd", component, configuration, relatedProduct);
            let inContractDeviceCount = 0;
            if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === "Related Component") {
                if (component.name === ENTERPRISE_COMPONENTS.mobileSubscription) pricingUtils.resetDiscountAttributes(configuration.guid, ENTERPRISE_COMPONENTS.mobileSubscription);
                let attribSelectPlan = configuration.getAttribute("Select Plan");
                let attribIsDiscountCheckNeededValue = configuration.getAttribute("IsDiscountCheckNeeded");
                let IsDiscountCheckNeededValue = "";
                if (attribIsDiscountCheckNeededValue) IsDiscountCheckNeededValue = attribIsDiscountCheckNeededValue.value;
                let attribChangeType = configuration.getAttribute("ChangeType");
                var ChangeTypeValue = "";
                if (attribChangeType) ChangeTypeValue = attribChangeType.value;

                if (attribSelectPlan && attribSelectPlan.displayValue != "" && attribSelectPlan.displayValue.includes("BYO")) {
                    let cnfg = await component.getConfiguration(relatedProduct.guid);
                    cnfg.status = false;
                    cnfg.statusMessage = "Please remove the added mobile device because BYO plan does not allow purchase of mobile device.";
                } else {
                    let priceItemAttribute = relatedProduct.configuration.getAttribute("ParentPriceItem");
                    if (priceItemAttribute) {
                        let updateConfigMap = {};
                        updateConfigMap[relatedProduct.guid] = [
                            {
                                name: "ParentPriceItem",
                                value: attribSelectPlan.value,
                                displayValue: attribSelectPlan.value
                            }
                        ];
                        let keys = Object.keys(updateConfigMap);
                        for (let i = 0; i < keys.length; i++) {
                            await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                        }
                    }
                    skipsave = true;
                    inContractDeviceCount = EMPlugin_getInContractMobileDevices(configuration);
                    if (inContractDeviceCount > 0) {
                        let cnfg = await component.getConfiguration(relatedProduct.guid);
                        cnfg.status = false;
                        cnfg.statusMessage = "There cannot be more than 1 In-Contract device for this plan.";
                    }
                }

                if (configuration && configuration.relatedProductList.length > 0) {
                    configuration.relatedProductList.forEach(async (ReletedplanList) => {
                        if (ReletedplanList.guid === relatedProduct.guid) {
                            let parentDeviceAttribute = configuration.getAttribute("PlanTypeString");
                            if (parentDeviceAttribute) {
                                let DevAttribute = relatedProduct.configuration.getAttribute("PlanType");
                                if (DevAttribute) {
                                    let updateConfigMap = {};
                                    updateConfigMap[relatedProduct.guid] = [
                                        {
                                            name: "PlanType",
                                            value: parentDeviceAttribute.displayValue,
                                            displayValue: parentDeviceAttribute.displayValue
                                        }
                                    ];

                                    let keys = Object.keys(updateConfigMap);
                                    for (let i = 0; i < keys.length; i++) {
                                        await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                                    }
                                }
                            }
                        }
                    });
                }
            }
            await handlePortOutReversalForIndvConf(configuration.guid); // Laxmi Added for EDGE-142321
			//await resetDeliveryDetailsinOESchemaForIndvConf(configuration.guid); // laxmi Added for EDGE-142321 || //EDGE-174218 akanksha commented
            console.log("end of afterRelatedProductAdd");
        } catch (error) {
            console.log(error);
        }
        return Promise.resolve(true);
    };
}

EM_updateChangeTypeOptions = async function () {
    let configurations = activeEMSolution.getConfigurations();
    Object.values(configurations).forEach(async (config) => {
        let changeType = config.attributes["changetype"].value;
        let updateMap = {};
        let options = [CommonUtills.createOptionItem("Modify"), CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
        if (changeType && changeType != "Active") {
            updateMap[config.guid] = [];
            updateMap[config.guid].push({
                name: "ChangeType",
                options: options
            });
        }
        if (updateMap) {
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await activeEMSolution.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
    });

    Object.values(activeEMSolution.components).forEach((comp) => {
        let configs = comp.getConfigurations();
        Object.values(configs).forEach(async (config) => {
            let changeType = config.attributes["changetype"].value;
            let updateMap = {};
            let options = [CommonUtills.createOptionItem("Modify"), CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
           if (changeType && changeType != "Active") {
                updateMap[config.guid] = [];
                updateMap[config.guid].push({
                    name: "ChangeType",
                    options: options
                });
            }
            if (updateMap) {
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
        });
    });
};

async function EMPlugin_saveSolutionEM(solution) {
    CommonUtills.updateTransactionLogging('before Save'); //DIGI-3162
    try {
        if (solution == null || solution == undefined) solution = activeEMSolution;

        let hasError = await EMPlugin_CheckErrorsOnSolution(solution);
        if (hasError) {
            return Promise.resolve(false);
        }

        let isValid = true;
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let configs = msComponent.getConfigurations();
            Object.values(configs).forEach((parentConfig) => {
                if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
                    let inContractDeviceCount = EMPlugin_getInContractMobileDevices(parentConfig);
                    if (inContractDeviceCount > 1) {
                        CS.SM.displayMessage("There cannot be more than 1 device of payment type Contract for this plan.", "error");
                        show = true;
                        isValid = false;
                    }
                }
            });
        }

        await EMPlugin_UpdateRemainingTermOnParent();
        if (!EMPlugin_validateCancelSolution(solution)) {
            return Promise.resolve(false);
        }

        if (!isValid) {
            return Promise.resolve(false);
        }

        if (productInError) {
            show = false;
            CS.SM.displayMessage("You cannot save Invalid PC.", "error");
            return Promise.resolve(false);
        }

        // Change for EDGE-142087 Added By Rohit
        await EMPlugin_CalculateTotalRCForSolution();
        //await EMPlugin_updateSolutionNameEM(); // Added as part of EDGE-149887
        allowSaveEM = true;

        //Addde by laxmi for 138001
        Utils.updateImportConfigButtonVisibility();
        //Added by Laxmi - EDGE-131531
        await EMPlugin_updateLinksAttributeEMS(solution);
        await RedemptionUtils.checkConfigurationStatus();
    } catch (err) {
        console.log(err);
    }
    return Promise.resolve(true);
}

/***********************************************************************************************
* Author                : Samish Kumar
* EDGE                   : EDGE-120137
* Method Name : checkContractingStatus
* Invoked When: Solution is Loaded
* Description : Set isRecontractingDiscountEligible(Cancel or Modify)

***********************************************************************************************/
async function EMPlugin_checkContractingStatus(inputMapOneFund) {
    console.log("EMPlugin_checkContractingStatus");
    var componentMap = {};
    var updateMap = {};
    let solution = activeEMSolution;
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let configs = msComponent.getConfigurations();
            Object.values(configs).forEach((config) => {
                if (!componentMap[msComponent.name]) componentMap[msComponent.name] = [];
                if (config.replacedConfigId) componentMap[msComponent.name].push({ id: config.replacedConfigId, guid: config.guid });
                else componentMap[msComponent.name].push({ id: config.id, guid: config.guid });
            });
        }
    }

    console.log("EMPlugin_checkContractingStatus: ", inputMapOneFund);
    var statuses;
    await currentEMBasket.performRemoteAction("SolutionHelperPaymentTypeOneFund", inputMapOneFund).then((values) => {
        console.log("EMPlugin_checkContractingStatus result:", values);
        if (values["isRecontractingDiscountEligible"]) statuses = values["isRecontractingDiscountEligible"];

        isPaymentTypeOneFund = values["isPaymentTypeOneFund"];
        console.log("isPaymentTypeOneFund: ", isPaymentTypeOneFund);
    });

    console.log("EMPlugin_checkContractingStatus statuses;", statuses);
    if (statuses === "true") {
        Object.keys(componentMap).forEach(async (comp) => {
            componentMap[comp].forEach((element) => {
                if (statuses === "true") {
                   updateMap[element.guid] = [
                        {
                            name: "isRecontractingDiscountEligible",
                            value: statuses,
                            displayValue: statuses
                        }
                    ];
                }
            });
            console.log("EMPlugin_checkConfigurationSubscriptionsForEM update map", updateMap);
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            return Promise.resolve(true);
        });
    }
    return Promise.resolve(true);
}

EMPlugin_UpdateMainSolutionChangeTypeVisibility = async function (solution) {
    if (basketChangeType !== "Change Solution") {
        return;
    }
    let updateMap = {};
    updateMap[Object.values(solution.schema.configurations)[0].guid] = [
        {
            name: "ChangeType",
            showInUi: true
        }
    ];
    console.log("EMPlugin_UpdateMainSolutionChangeTypeVisibility", updateMap);
    let component = await solution.getComponentByName(solution.name);
    let keys = Object.keys(updateMap);
    for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
    }
    return Promise.resolve(true);
};

EMPlugin_UpdateAttributesForMacdOnSolution = async function (solution) {
    console.log("EMPlugin_UpdateAttributesForMacdOnSolution");
    let changeTypeAtrtribute;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (solution.components && Object.values(solution.components).length > 0) {
            let changeTypeAtrtribute = Object.values(solution.schema.configurations)[0].getAttribute("ChangeType");
            if (changeTypeAtrtribute && changeTypeAtrtribute.displayValue === "Cancel") {
                EMPlugin_updateAttributeVisibility(solution.schema.name, "CancellationReason", Object.values(solution.schema.configurations)[0].guid, false, true, true);
            } else {
                EMPlugin_updateAttributeVisibility(solution.schema.name, "CancellationReason", Object.values(solution.schema.configurations)[0].guid, false, false, false);
                let attribs = ["CancellationReason", "DisconnectionDate", "EarlyTerminationCharge", "OneOffChargeGST"];
                attribs.forEach((value) => {
                    Utils.emptyValueOfAttribute(Object.values(solution.schema.configurations)[0].guid, solution.schema.name, value, false);
                });
            }
            let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            // let comp = Object.values(solution.components).filter(c => {
            //              return c.schema && c.name === ENTERPRISE_COMPONENTS.mobileSubscription && c.schema.configurations && Object.values(c.schema.configurations).length > 0
            // });
            if (comp) {
                let configs = comp.getConfigurations();
                Object.values(configs).forEach((config) => {
                    let changeTypeAtrtribute = config.getAttribute("ChangeType");
                    let selectPlanDisplayValue = config.getAttribute("Select Plan");
                    if (changeTypeAtrtribute && selectPlanDisplayValue) {
                        EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription(config.guid, changeTypeAtrtribute.displayValue, selectPlanDisplayValue.displayValue);
                    }
                });
            }
        }
    }
    return Promise.resolve(true);
};

EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription = async function (guid, changeTypeValue, selectedPlan) {
    console.log("EMPlugin_UpdateAttributeVisibilityForMacdMobileSubscription", guid, changeTypeValue, selectedPlan);
    if (changeTypeValue === "Cancel") {
        EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "CancellationReason", guid, false, true, true);
        let isEtcVisible = true;
        if (selectedPlan.includes("BYO")) isEtcVisible = false;
        EMPlugin_updateDisconnectionDateAndETC(ENTERPRISE_COMPONENTS.mobileSubscription, guid, true, isEtcVisible, basketStage === "Commercial Configuration", false);
        await EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription, guid, true, ENTERPRISE_COMPONENTS.mobileSubscriptionEditableAttributeList);
    }
    if (changeTypeValue !== "Cancel") {
        EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "CancellationReason", guid, false, false, false);
        let attribs = ["CancellationReason", "DisconnectionDate", "EarlyTerminationCharge"];
        attribs.forEach((value) => {
            Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, value, false);
        });
        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, "CancellationReason", false);
        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, "DisconnectionDate", false);
        Utils.emptyValueOfAttribute(guid, ENTERPRISE_COMPONENTS.mobileSubscription, "EarlyTerminationCharge", false);
        EMPlugin_updateDisconnectionDateAndETC(ENTERPRISE_COMPONENTS.mobileSubscription, guid, false, false, false, false);
    }
    if (changeTypeValue === "Modify") {
        EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription, guid, true, ["SelectPlanType"]);
    }
};

EMPlugin_updateAttributeVisibility = async function (componentName, attributeName, guid, isReadOnly, isVisible, isRequired) {
    console.log("EMPlugin_updateAttributeVisibility", attributeName, componentName, guid, isReadOnly, isVisible, isRequired);
    let updateMap = {};
    updateMap[guid] = [];

    updateMap[guid].push({
        name: attributeName,
        readOnly: isReadOnly,
        showInUi: isVisible,
        required: isRequired
    });
    let product = activeEMSolution;
    let component = await product.getComponentByName(componentName);
    if (component && component != null && component != undefined) {
        let keys = Object.keys(updateMap);
        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
        }
    } else console.log("component not found with name ", componentName);
    return Promise.resolve(true);
};

EMPlugin_updateDisconnectionDateAndETC = async function (componentName, guid, isVisible, isVisibleETC, isMandatory, isReadonly) {
    console.log("EMPlugin_updateDisconnectionDateAndETC ", componentName, guid, isVisible, isVisibleETC, isMandatory, isReadonly);
    let updateMap = {};
    updateMap[guid] = [];
    updateMap[guid].push(
        {
            name: "DisconnectionDate",
            readOnly: isReadonly,
            showInUi: isVisible,
            required: isMandatory
        },
        {
            name: "EarlyTerminationCharge",
            readOnly: true,
            showInUi: isVisibleETC,
            required: false
        },
        {
            name: "RedeemFund",
            showInUi: isVisibleETC
        },
        {   //Added: EDGE-190802
            name: "RedeemFundIncGST",
            showInUi: isVisibleETC
        },
        {
            name: "OneOffChargeGST",
            showInUi: isVisibleETC
        },
        {
            name: "TotalFundAvailable",
            showInUi: isVisibleETC
        },
        {
            name: "RemainingTerm",
            readOnly: true,
            showInUi: isVisibleETC,
            required: false
        }
    );

    let component = await activeEMSolution.getComponentByName(componentName);
    let keys = Object.keys(updateMap);
    for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
    }
    return Promise.resolve(true);
};

EMPlugin_setAttributesReadonlyValueForConfiguration = async function (componentName, guid, isReadOnly, attributeList) {
    console.log("EMPlugin_setAttributesReadonlyValueForConfiguration ", componentName, guid, isReadOnly, attributeList);
    let solution = activeEMSolution;
    let updateMapNew = {};
    updateMapNew[guid] = [];
    attributeList.forEach((attribute) => {
        updateMapNew[guid].push({
            name: attribute,
            readOnly: isReadOnly
        });
    });
    console.log("EMPlugin_setAttributesReadonlyValueForConfiguration updateMap", updateMapNew);
	let component = solution.getComponentByName(componentName);
	// Added as a part of EDGE-169342 Start---->
    let keys = Object.keys(updateMapNew);
    for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(keys[i], updateMapNew[keys[i]], false);
	}
	// Added as a part of EDGE-169342 End---->
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && componentName === ENTERPRISE_COMPONENTS.mobileSubscription) {
        let comp = solution.getComponentByName(componentName);
        if (comp) {
            let config = comp.getConfiguration(guid);
            if (config) {
                console.log("EMPlugin_setAttributesReadonlyValueForConfiguration config", config);
                if (config.relatedProductList && config.relatedProductList.length > 0) EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts(componentName, config.relatedProductList, "Device", isReadOnly, ENTERPRISE_COMPONENTS.mobileSubscriptionAddOnEditableAttributeList);
            }
        }
    }
    return Promise.resolve(true);
};

EMPlugin_updateRemainingTermAfterSolutionLoad = async function () {
    console.log("EMPlugin_checkRemainingTermForBYOPlans");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let configs = comp.getConfigurations();
            Object.values(configs).forEach((config) => {
                let changeTypeAtrtribute = config.getAttribute("ChangeType");
                if (config.relatedProductList && config.relatedProductList.length > 0 && changeTypeAtrtribute.value === "Modify") {
                    config.relatedProductList.forEach((relatedConfig) => {
                        if (relatedConfig.name.includes("Device")) {
                            if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                                let contractTermAtrtribute = relatedConfig.configuration.getAttribute("ContractTerm");
                                let ChangeTypeDeviceattribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                if (ChangeTypeDeviceattribute.value != "PayOut" && ChangeTypeDeviceattribute.value != "New") {
                                    console.log("Remaining Term Getting called EMPlugin_updateRemainingTermAfterSolutionLoad!!");
                                    CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute.displayValue, config.guid, comp.name, ""); // EDGE-138108 Aditya Changed Signature, Added Comp Name
                                }
                            }
                        }
                    });
                }
            });
        }
    }
    return Promise.resolve(true);
};

/************************************************************************************
* Author             : Rohit Tripathi
* Method Name : EMPlugin_checkRemainingTermForBYOPlans
* Defect/US # : EDGE-88407
* Invoked When: Change Type is updated as Modisy
* Description : Show error message when RemainingTerm is greater than zero and Enable Cancel Flag on Device
* Parameters : guid
***********************************************************************************/
async function EMPlugin_checkRemainingTermForBYOPlans(guid) {
    console.log("EMPlugin_checkRemainingTermForBYOPlans");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0) {
            comp.schema.configurations.forEach((config) => {
                if (config.id && !config.name.includes("BYO")) {
                    if (config.guid == guid) {
                        CS.SM.displayMessage("Please note that changing your plan might affect the Plan Discount and Add-On prices. Price will be adjusted accordingly should you choose to Upgrade/Downgrade your Plan.", "info");
                        let changeTypeAtrtribute = config.getAttribute("ChangeType");
                        let selectPlanAtrtribute = config.getAttribute("Select Plan");
                        if (changeTypeAtrtribute) {
                            if (changeTypeAtrtribute.value === "Modify" && selectPlanAtrtribute.displayValue.includes("BYO")) {
                                console.log("EMPlugin_checkRemainingTermForBYOPlans--->4827");
                                if (config.relatedProductList && config.relatedProductList.length > 0) {
                                    config.relatedProductList.forEach((relatedConfig) => {
                                        if (relatedConfig.name.includes("Device")) {
                                            let RemainingTermAttribute = relatedConfig.configuration.getAttribute("RemainingTerm");
                                            if (RemainingTermAttribute && RemainingTermAttribute.value > 0) {
                                                config.status = false;
                                                config.statusMessage = "Cannot change the plan to BYO while the associated device is In-Contract";
                                                productInError = true;
                                                console.log("Inside RemaingTerm Greater Than 0: ");
                                            }
                                        }
                                    });
                                }
                            } else {
                                config.status = true;
                                config.statusMessage = "";
                            }
                        }
                    }
                }
            });
        }
    }
    return Promise.resolve(true);
}

function EMPlugin_getInContractMobileDevices(parentConfig) {
    let inContractDeviceCount = 0;
    if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 1) {
        parentConfig.relatedProductList.forEach((relatedProduct) => {
            if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === "Related Component") {
                let attribute = relatedProduct.configuration.getAttribute("RemainingTerm");


                if (attribute && attribute.value > 0) { // EDGE - 188102
                    inContractDeviceCount = inContractDeviceCount + 1;
                }
            }
        });
    }
    console.log("count of in contract device  " + inContractDeviceCount);
    return inContractDeviceCount;
}

function EMPlugin_solutionBeforeConfigurationDeleteMacd(componentName, configuration, relatedProduct) {
    let changeTypeAttribute = configuration.getAttribute("ChangeType");
    if (changeTypeAttribute && relatedProduct.type === "Related Component" && relatedProduct.configuration.id) {
        if (changeTypeAttribute.value === "Modify") {
            if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && configuration.relatedProductList.length === 1) {
                CS.SM.displayMessage("Not allowed to delete Mobile Device when changing Mobility configuration!", "info");
                return false;
            }
        } else {
            CS.SM.displayMessage("Not allowed to delete existing related product!", "info");
            return false;
        }
    }
    return true;
}

async function EMPlugin_validateMobileDevice(planValue, parentConfig) {
    if (planValue.includes("BYO")) {
        console.log("new plan is BYO");
        let component = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
            let cnfg = await component.getConfiguration(parentConfig.guid);
            cnfg.status = false;
            cnfg.statusMessage = "Please remove the added mobile device because BYO plan does not allow purchase of mobile device.";
        }
    }
}

/**************************************************************************************
* Author                : Ankit
* Method Name : EMPlugin_updateRemainingTermAfterSave
* Description : Calculated remaining term from all related product
* Invoked When: remaining term is updated,
**************************************************************************************/

async function EMPlugin_updateRemainingTermAfterSave(guid) {
    let solution = activeEMSolution;
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let updateRemainingTermMap = {};
        let component = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (component) {
            let configs = component.getConfigurations();
            Object.values(configs).forEach((config) => {
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    config.relatedProductList.forEach(async (relatedConfig) => {
                        if (relatedConfig.guid === guid && relatedConfig.name.includes("Device")) {
                            let contractTermAtrtribute = relatedConfig.configuration.getAttribute("ContractTerm");
                            let attrChangeTypeDevice = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                            if (attrChangeTypeDevice && attrChangeTypeDevice.value === "PayOut") {
                                updateRemainingTermMap[guid] = [
                                    {
                                        name: "RemainingTerm",
                                        value: 0,
                                        displayValue: 0
                                    }
                                ];
                                let keys = Object.keys(updateRemainingTermMap);
                                for (let i = 0; i < keys.length; i++) {
                                    await component.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true);
                                }
                                let cnfg = await component.getConfiguration(config.guid);
                                cnfg.status = true;
                                cnfg.statusMessage = "";
                            }
                            if (IsDeviceChange && attrChangeTypeDevice.value !== "PayOut" && attrChangeTypeDevice.value !== "New") {
                                CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute.displayValue, guid, component.name, ""); // EDGE-138108 Aditya Changed Signature, Added Comp Name
                            }
                        }
                    });
                }
            });
        }
    }
    return Promise.resolve(true);
}

/****************************************************************************************************
* Author             : Sandip Deshmane
* Method Name : EMPlugin_checkConfigurationSubscriptionStatus
* Defect/US # : EDGE-131227
* Invoked When: Raised MACD on Suspended Subscription
* Description :Update the Change Type to Active based on Subscription Status
************************************************************************************************/
EMPlugin_checkConfigurationSubscriptionStatus = async function () {
    console.log("EMPlugin_checkConfigurationSubscriptionStatus");
    var solutionComponent = false;
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (Object.values(solution.schema.configurations)[0].replacedConfigId) {
            solutionComponent = true;
            await EMPlugin_checkConfigurationSubscriptionsForEM(solution, solutionComponent);
        }
        if (solution.components && Object.values(solution.components).length > 0) {
            for (const comp of Object.values(solution.components)) {
                solutionComponent = false;
                await EMPlugin_checkConfigurationSubscriptionsForEM(comp, solutionComponent);
            }
        }
    }
    return Promise.resolve(true);
};

/***********************************************************************************************
* Author                : Rohit Tripathi
* Method Name : EMPlugin_checkConfigurationSubscriptionsForEM
* Invoked When: Solution is Loaded
* Description : Set change type for configuration based on subscription status, but only if change type of configuration is not set by user (Cancel or Modify)
* Revision History : Function Signature and code changed to fix EDGE-131227
***********************************************************************************************/
async function EMPlugin_checkConfigurationSubscriptionsForEM(comp, solutionComponent) {
    console.log("EMPlugin_checkConfigurationSubscriptionsForEM");
    var componentMap = {};
    console.log("Cmp Map --->", componentMap);
    var optionValues = [];
    if (comp.name == ENTERPRISE_COMPONENTS.mobileSubscription || comp.name == ENTERPRISE_COMPONENTS.enterpriseMobility) optionValues = [CommonUtills.createOptionItem("Modify"),CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
    if (solutionComponent && Object.values(comp.schema.configurations).length > 0) {
        let cta = Object.values(comp.schema.configurations)[0].getAttribute("ChangeType");
        componentMap[comp.name] = [];
        componentMap[comp.name].push({
            id: Object.values(comp.schema.configurations)[0].replacedConfigId,
            guid: Object.values(comp.schema.configurations)[0].guid,
            ChangeTypeValue: cta.value,
            needUpdate: "No"
        });
    } else if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
        let configs = comp.getConfigurations();
        Object.values(configs).forEach((config) => {
            if (config.replacedConfigId || config.id) {
                let cta = config.getAttribute("ChangeType");

                if (cta) {
                    if (!componentMap[comp.name]) componentMap[comp.name] = [];
                    if (config.replacedConfigId && cta.value === 'New') componentMap[comp.name].push({ id: config.replacedConfigId, guid: config.guid, ChangeTypeValue: cta.value, needUpdate: "Yes" }); //DIGI-20921:Changed Condition(config.id == null || config.id == "") to cta.value === 'New'
                    else if (config.replacedConfigId && (config.id != null || config.id != "")) componentMap[comp.name].push({ id: config.replacedConfigId, guid: config.guid, ChangeTypeValue: cta.value, needUpdate: "No" });
                    else componentMap[comp.name].push({ id: config.id, guid: config.guid, ChangeTypeValue: cta.value, needUpdate: "No" });
                }
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
        console.log("GetSubscriptionForConfiguration: ", inputMap);
        var statuses;
        await currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
            console.log("GetSubscriptionForConfiguration result:", values);
           if (values["GetSubscriptionForConfiguration"]) statuses = JSON.parse(values["GetSubscriptionForConfiguration"]);
        });

        console.log("EMPlugin_checkConfigurationSubscriptionsForEM statuses;", statuses);
        if (statuses) {
            var updateMap = [];
            for (const comp1 of Object.keys(componentMap)) {
                componentMap[comp1].forEach((element) => {
                    updateMap[element.guid] = [];
                    var statusValue = "New";
                    var CustomerFacingId = "";
                    //var InitialDate ='';//Added as a part of EDGE-138169 by Aman Soni
                    var status = statuses.filter((v) => {
                        return v.csordtelcoa__Product_Configuration__c === element.id;
                    });
                    if (status && status.length > 0) {
                        statusValue = status[0].csord__Status__c;
                        CustomerFacingId = status[0].serviceMSISDN__c;
                        //InitialDate = status[0].initialActivationDate__c;//Added as a part of EDGE-138169 by Aman Soni
                    }
                    if ((element.ChangeTypeValue !== "Modify" && element.ChangeTypeValue !== "Cancel" && statusValue != "New") || ((element.ChangeTypeValue == "Modify" || element.ChangeTypeValue == "Cancel") && element.needUpdate == "Yes")) {
                        console.log("Inside Change type Update");
                        const found = optionValues.find((element) => element === statusValue);
                        if (found === undefined) {
                            optionValues.push(CommonUtills.createOptionItem(statusValue));//R34UPGRADE
                        }
                        updateMap[element.guid].push({
                            name: "ChangeType",
                            value: statusValue,
                            options: optionValues,
                            displayValue: statusValue
                        });
                        if (!solutionComponent && CustomerFacingId!=="") { //EDGE-197623
                            updateMap[element.guid].push(
                                {
                                    // Start**EDGE-117256 | Enable search on MSISDN in solution console
                                    name: "CustomerFacingServiceId",
                                    value: CustomerFacingId,
                                    displayValue: CustomerFacingId
                                },
                                {
                                    name: "Substatus",
                                    value: statusValue,
                                    displayValue: statusValue
                                }
                            );
                        }
                    } else {
                        if (!solutionComponent && CustomerFacingId!=="") {//EDGE-197623
                            updateMap[element.guid].push({
                                // Start**EDGE-117256 | Enable search on MSISDN in solution console
                                name: "CustomerFacingServiceId",
                                value: CustomerFacingId,
                                displayValue: CustomerFacingId
                            });
                        }
                        /*,
                                                                                          {//Added as a part of EDGE-138169 by Aman Soni || Start
                                                                                                         name: 'initialActivationDate',
                                                                                                         value: {
                                                                                                                        value: InitialDate,
                                                                                                                        displayValue: InitialDate
                                                                                                         }
                                                                                          }*/ //Added as a part of EDGE-138169 by Aman Soni || End];
                    }
                });
                console.log("EMPlugin_checkConfigurationSubscriptionsForEM update map", updateMap);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
        }
    }
    return Promise.resolve(true);
}

/***********************************************************************************************
* Author                : Ankit Goswami
* Method Name : EMPlugin_checkConfigurationServiceForEM
* Invoked When: Solution is Loaded
* Description : EDGE-132276 Device status update on Device for Macd.
***********************************************************************************************/
async function EMPlugin_checkConfigurationServiceForEM() {
    console.log("EMPlugin_checkConfigurationServiceForEM");
    var componentMap = {};
    var updateMap = {};
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (solution.components && Object.values(solution.components).length > 0) {
            let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            if (comp) {
                let configs = comp.getConfigurations();
                Object.values(configs).forEach((config) => {
                    let cta = config.getAttribute("ChangeType");
                    //Added as part of EDGE-123594
                    if (!componentMap[comp.name]) componentMap[comp.name] = [];

                    if (config.replacedConfigId) {
                        componentMap[comp.name].push({ id: config.replacedConfigId, guid: config.guid, ChangeTypeValue: cta.value, IsRelated: "No" });
                    } else {
                        componentMap[comp.name].push({ id: config.id, guid: config.guid, ChangeTypeValue: cta.value, IsRelated: "No" });
                    }
                    //END as part of EDGE-123594
                    config.relatedProductList.forEach((Relatedconfig) => {
                        if (Relatedconfig.configuration.replacedConfigId !== "" && Relatedconfig.configuration.replacedConfigId !== undefined && Relatedconfig.configuration.replacedConfigId !== null) {
                            if (cta) {
                                if (!componentMap[comp.name]) componentMap[comp.name] = [];

                                if (Relatedconfig.replacedConfigId) componentMap[comp.name].push({ id: Relatedconfig.configuration.replacedConfigId, guid: Relatedconfig.configuration.guid, ChangeTypeValue: cta.value, IsRelated: "Yes" });
                                else
                                    componentMap[comp.name].push({
                                        id: Relatedconfig.configuration.replacedConfigId,
                                        guid: Relatedconfig.configuration.guid,
                                        ChangeTypeValue: cta.value,
                                        IsRelated: "Yes"
                                    });
                            }
                        }
                    });
                });
            }
        }
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
        inputMap["GetServiceForConfiguration"] = parameter;
        console.log("GetServiceForConfiguration: ", inputMap);
        var statuses;
        await currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((values) => {
            console.log("GetServiceForConfiguration result:", values);
            if (values["GetServiceForConfiguration"]) statuses = JSON.parse(values["GetServiceForConfiguration"]);
        });

        console.log("EMPlugin_checkConfigurationSubscriptionsForEM statuses;", statuses);
        if (statuses) {
            Object.keys(componentMap).forEach((comp) => {
                componentMap[comp].forEach((element) => {
                    var statusValue = "";
                    //var InitialDate ='';  //Added as part of EDGE-123594, Commented as a part of EDGE-38169 BY Aman Soni
                    var status = statuses.filter((v) => {
                        return v.csordtelcoa__Product_Configuration__c === element.id;
                    });
                    if (status && status.length > 0) {
                        statusValue = status[0].csord__Status__c;
                        //InitialDate=status[0].Initial_Activation_Date__c //Added as part of EDGE-123594, Commented as a part of EDGE-38169 BY Aman Soni
                    }
                    if ((element.ChangeTypeValue === "Modify" || element.ChangeTypeValue === "Cancel" || element.ChangeTypeValue === "Active") && element.IsRelated === "Yes") {
                        updateMap[element.guid] = [
                            {
                                name: "DeviceStatus",
                                value: statusValue,
                                displayValue: statusValue
                            }
                        ];
                    } /*//Added as part of EDGE-123594, Commented as a part of EDGE-138169 By Aman Soni || Start
                                                                           else if(element.IsRelated ==='No'){
                                                                                          updateMap[element.guid] =[{
                                                                                                         name: 'initialActivationDate',
                                                                                                         value: {
                                                                                                                        value: InitialDate,
                                                                                                                        displayValue: InitialDate
                                                                                                         }
                                                                                          }]
                                                                           }
                                                                           //END, Commented as a part of EDGE-138169 By Aman Soni || End*/
                });
                console.log("EMPlugin_checkConfigurationSubscriptionsForEM update map", updateMap);
            });
            let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
    }
    return Promise.resolve(true);
}

EMPlugin_updateFieldsVisibilityAfterSolutionLoad = function (solution) {
    console.log("inside EMPlugin_updateFieldsVisibilityAfterSolutionLoad >>" + solution.name);
    if (solution.name == ENTERPRISE_COMPONENTS.enterpriseMobility) {
        let BounsAllownceFlag = false;
        isCommittedDataOffer = false;
        console.log("inside EMPlugin_updateFieldsVisibilityAfterSolutionLoad" + solution.changeType);
        let configs = solution.getConfigurations();
        if (configs) {
            let componentMap = new Map();
            Object.values(configs).forEach((config) => {
                let componentMapattr = {};
                let attribOfferType = config.getAttribute("OfferType");
                let attribBonusDataAllowance = config.getAttribute("BonusDataAllowance");
                if (attribOfferType && attribOfferType.value.includes("Committed Data")) {
                    isCommittedDataOffer = true;
                }
                if (attribBonusDataAllowance && attribBonusDataAllowance.value !== "") {
                    BounsAllownceFlag = true;
                }
                if (attribOfferType) {
                    if (attribOfferType.displayValue === "Data Pool" || attribOfferType.displayValue === "Committed Data") {
                        if (BounsAllownceFlag) {
                            componentMapattr["DataPackPlan"] = [];
                            componentMapattr["Data Pack RC"] = [];
                            componentMapattr["DataPackAllowanceValue"] = [];
                            componentMapattr["BonusDataAllowance"] = [];
                            componentMapattr["BonusDataAllowanceValue"] = [];
                            componentMapattr["BonusDataPromotionEndDate"] = [];
                            componentMapattr["DataPackPlan"].push({ IsreadOnly: true, isVisible: true, isRequired: true });
                            componentMapattr["Data Pack RC"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                            componentMapattr["DataPackAllowanceValue"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            componentMapattr["BonusDataAllowance"].push({ IsreadOnly: true, isVisible: false, isRequired: false });
                            componentMapattr["BonusDataAllowanceValue"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            componentMapattr["BonusDataPromotionEndDate"].push({ IsreadOnly: true, isVisible: false, isRequired: false });
                        } else {
                            componentMapattr["DataPackPlan"] = [];
                            componentMapattr["Data Pack RC"] = [];
                            componentMapattr["DataPackAllowanceValue"] = [];
                            componentMapattr["BonusDataAllowance"] = [];
                            componentMapattr["BonusDataAllowanceValue"] = [];
                            componentMapattr["BonusDataPromotionEndDate"] = [];
                            componentMapattr["DataPackPlan"].push({ IsreadOnly: false, isVisible: true, isRequired: true });
                            componentMapattr["Data Pack RC"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            componentMapattr["DataPackAllowanceValue"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            //componentMapattr['TotalRCDataPack'].push({'IsreadOnly':true, 'isVisible': true,'isRequired':false});
                        }
                    } else {
                        componentMapattr["DataPackPlan"] = [];
                        componentMapattr["Data Pack RC"] = [];
                        componentMapattr["DataPackAllowanceValue"] = [];
                        componentMapattr["BonusDataAllowance"] = [];
                        componentMapattr["BonusDataAllowanceValue"] = [];
                        componentMapattr["BonusDataPromotionEndDate"] = [];
                        componentMapattr["DataPackPlan"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        componentMapattr["Data Pack RC"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        componentMapattr["DataPackAllowanceValue"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        componentMapattr["BonusDataAllowance"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        componentMapattr["BonusDataAllowanceValue"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        componentMapattr["BonusDataPromotionEndDate"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                    }
                }
                componentMap.set(config.guid, componentMapattr);
            });
            CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap);
        }
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                let componentMap = new Map();
                Object.values(msConfigs).forEach((config) => {
                    let componentMapattr = {};
                    let CancelCheck = "";
                    let makeMDMFalse = false;
                    let attribChangeType = config.getAttribute("ChangeType");
                    if (attribChangeType && attribChangeType.Value === "Cancel") {
                        CancelCheck = "Cancel";
                    }
                    let attribPlanTypeString = config.getAttribute("PlanTypeString");
                    if (attribPlanTypeString && attribPlanTypeString.value !== "Basic" && isCommittedDataOffer == true) {
                        makeMDMFalse = true;
                    }
                    if (attribPlanTypeString && CancelCheck !== "Cancel") {
                        if (attribPlanTypeString.displayValue === "Data") {
                            componentMapattr["InternationalDirectDial"] = [];
                            componentMapattr["MessageBank"] = [];
                            componentMapattr["MessageBank RC"] = [];
                            componentMapattr["IDD Charge"] = [];
                            componentMapattr["InternationalDirectDial"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                            componentMapattr["MessageBank"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                            componentMapattr["MessageBank RC"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                            componentMapattr["IDD Charge"].push({ IsreadOnly: false, isVisible: false, isRequired: false });
                        } else {
                            componentMapattr["InternationalDirectDial"] = [];
                            componentMapattr["MessageBank"] = [];
                            componentMapattr["MessageBank RC"] = [];
                            componentMapattr["IDD Charge"] = [];
                            componentMapattr["InternationalDirectDial"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                            componentMapattr["MessageBank"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                            componentMapattr["MessageBank RC"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                            componentMapattr["IDD Charge"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                        }
                    }
                    if (attribChangeType && (attribChangeType.value === "Modify" || attribChangeType.value === "Cancel")) {
                        componentMapattr["RemainingTerm"] = [];
                        componentMapattr["ChangeType"] = [];
                        componentMapattr["RemainingTerm"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                        componentMapattr["ChangeType"].push({ IsreadOnly: false, isVisible: true, isRequired: true });
                    }
                    componentMap.set(config.guid, componentMapattr);
                    if (config.id) {
                        if (config.relatedProductList && config.relatedProductList.length > 0 && (attribChangeType.value === "Modify" || attribChangeType.value === "Cancel")) {
                            let componentMapattr = {};
                            config.relatedProductList.forEach((relatedConfig) => {
                                if (relatedConfig.name.includes("Device")) {
                                    if (relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null && relatedConfig.configuration.attributes && relatedConfig.configuration.attributes.length > 0) {
                                        // if ((config.replacedConfigId !=='' && config.replacedConfigId !==undefined && config.replacedConfigId !==null)
                                        // && relatedConfig.configuration.attributes
                                        // && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                        let earlyTerminationChargeAtrtribute = relatedConfig.configuration.getAttribute("EarlyTerminationCharge");
                                        let ChangeTypeDeviceAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                        if (ChangeTypeDeviceAttribute.value !== "New") {
                                            if ((ChangeTypeDeviceAttribute.value === "None" || ChangeTypeDeviceAttribute.value === "" || ChangeTypeDeviceAttribute.value === null) && (earlyTerminationChargeAtrtribute.value == 0 || earlyTerminationChargeAtrtribute.value == "" || earlyTerminationChargeAtrtribute.value == null)) {
                                                console.log("inside iif");
                                                componentMapattr["RemainingTerm"] = [];
                                                componentMapattr["EarlyTerminationCharge"] = [];
                                                componentMapattr["ChangeTypeDevice"] = [];
                                                componentMapattr["TotalFundAvailable"] = [];
                                                componentMapattr["RedeemFund"] = [];
                                                componentMapattr["RedeemFundIncGST"] = [];  //Added: EDGE-190802
                                                componentMapattr["OneOffChargeGST"] = [];
                                                componentMapattr["RemainingTerm"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                                componentMapattr["EarlyTerminationCharge"].push({ IsreadOnly: true, isVisible: false, isRequired: false });
                                                componentMapattr["ChangeTypeDevice"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                                                componentMapattr["TotalFundAvailable"].push({ IsreadOnly: false, isVisible: false });
                                                componentMapattr["RedeemFund"].push({ IsreadOnly: false, isVisible: false });
                                                componentMapattr["RedeemFundIncGST"].push({ IsreadOnly: true, isVisible: false }); //Added: EDGE-190802
                                                componentMapattr["OneOffChargeGST"].push({ IsreadOnly: false, isVisible: false });
                                            } else if (attribChangeType.value === "Cancel") {
                                                console.log("inside iif");
                                                componentMapattr["RemainingTerm"] = [];
                                                componentMapattr["EarlyTerminationCharge"] = [];
                                                componentMapattr["ChangeTypeDevice"] = [];
                                                componentMapattr["RemainingTerm"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                                componentMapattr["EarlyTerminationCharge"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                                componentMapattr["ChangeTypeDevice"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                            } else {
                                                console.log("inside else");
                                                componentMapattr["RemainingTerm"] = [];
                                                componentMapattr["EarlyTerminationCharge"] = [];
                                                componentMapattr["ChangeTypeDevice"] = [];
                                                componentMapattr["TotalFundAvailable"] = [];
                                                componentMapattr["RedeemFund"] = [];
                                                componentMapattr["RedeemFundIncGST"] = [];  //Added: EDGE-190802
                                                componentMapattr["OneOffChargeGST"] = [];
                                                componentMapattr["RemainingTerm"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                                componentMapattr["EarlyTerminationCharge"].push({ IsreadOnly: true, isVisible: true, isRequired: false });
                                                componentMapattr["ChangeTypeDevice"].push({ IsreadOnly: false, isVisible: true, isRequired: false });
                                                componentMapattr["TotalFundAvailable"].push({ IsreadOnly: false, isVisible: true });
                                                componentMapattr["RedeemFund"].push({ IsreadOnly: false, isVisible: true });
                                                componentMapattr["RedeemFundIncGST"].push({ IsreadOnly: true, isVisible: true });  //Added: EDGE-190802
                                                componentMapattr["OneOffChargeGST"].push({ IsreadOnly: false, isVisible: true });
                                            }
                                        }
                                        componentMap.set(relatedConfig.guid, componentMapattr);
                                    }
                                }
                            });
                            CommonUtills.attrVisiblityControl(ENTERPRISE_COMPONENTS.mobileSubscription, componentMap);
                        }
                    }
                });
            }
        }
    }
};

EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts = async function (componentName, relatedProductList, relatedConfigName, isReadOnly, attributeList) {
    console.log("EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts ", relatedProductList, relatedConfigName, isReadOnly, attributeList);
    if (relatedProductList && relatedProductList.length > 0) {
        let updateMap = {};
        let doUpdate = false;
        relatedProductList.forEach((relatedConfig) => {
            if (relatedConfig.name === relatedConfigName && relatedConfig.type === "Related Component" && relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                let ChangeTypeDeviceattribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                if (ChangeTypeDeviceattribute.value !== "New") {
                    attributeList.forEach((attribute) => {
                        let attrib = CommonUtills.getAttribute(relatedConfig.configuration, attribute);
                        if (attrib && attrib.showInUi) {
                            doUpdate = true;
                            if (!updateMap[relatedConfig.guid]) updateMap[relatedConfig.guid] = [];

                            var readonlyValue = isReadOnly;
                            updateMap[relatedConfig.guid].push({
                                name: attrib.name,
                                readOnly: readonlyValue
                            });
                        }
                    });
                }
            }
        });
        if (doUpdate === true) {
            console.log("EMPlugin_setAttributesReadonlyValueForConfigurationRelatedProducts - updating: ", updateMap);
            let solution = activeEMSolution;
            let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
            }
        }
    }
};

async function EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave() {
    console.log("EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var updateMap = {};
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            var updateMapDevice = {};
            updateMap = [];
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    errorMessage = "";
                    if (config.id) {
                        let changeTypeAtrtribute = config.getAttribute("ChangeType");
                        console.log("EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4824" + changeTypeAtrtribute.value + IsMACBasket);
                        if (changeTypeAtrtribute) {
                            var visibleEtc = false;
                            if (changeTypeAtrtribute.value === "Modify" || changeTypeAtrtribute.value === "Cancel" || changeTypeAtrtribute.value === "Active") {
                                updateMapDevice[config.guid] = [
                                    {
                                        name: "ChangeType",
                                        showInUi: true
                                    }
                                ];
                            }
                            if (changeTypeAtrtribute.value === "Modify") {
                                console.log("EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4827");
                                if (config.relatedProductList && config.relatedProductList.length > 0) {
                                    config.relatedProductList.forEach((relatedConfig) => {
                                        if (relatedConfig.name.includes("Device")) {
                                            if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                                                console.log("EMPlugin_checkCancelFlagAndETCForNonBYOPlansAfterValidateAndSave--->4835");
                                                let ChangeTypeDeviceAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                                if (ChangeTypeDeviceAttribute && ChangeTypeDeviceAttribute.value !== "New") {
                                                    let EarlyTerminationChargesAttribute = relatedConfig.configuration.getAttribute("EarlyTerminationCharge");
                                                    if (EarlyTerminationChargesAttribute && EarlyTerminationChargesAttribute.value === "") {
                                                        console.log("EarlyTerminationChargesAttribute");
                                                        updateMapDevice[relatedConfig.guid] = [];
                                                        updateMapDevice[relatedConfig.guid].push(
                                                            {
                                                                name: "EarlyTerminationCharge",
                                                                showInUi: false,
                                                                readOnly: true
                                                            },
                                                            {
                                                                name: "OneOffChargeGST",
                                                                showInUi: false
                                                            },
                                                            {
                                                                name: "RedeemFund",
                                                                showInUi: false
                                                            },
                                                            {   //Added: EDGE-190802
                                                                name: "RedeemFundIncGST",
                                                                showInUi: false
                                                            },
                                                            {
                                                                name: "TotalFundAvailable",
                                                                showInUi: false
                                                            },
                                                            {
                                                                name: "ChangeTypeDevice",
                                                                showInUi: true,
                                                                readOnly: false
                                                            }
                                                        );
                                                    }
                                                }
                                            }
                                        }
                                    });
                                }
                            }
                        }
                    }
                });
            }
        }
        console.log("updateCancelFlagVisibility - updating: ", updateMapDevice);
        let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let keys = Object.keys(updateMapDevice);
        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true);
        }
    }
    return Promise.resolve(true);
}

async function EMPlugin_checkCancelFlagAndETCForNonBYOPlans(guid) {
    console.log("EMPlugin_checkCancelFlagAndETCForNonBYOPlans");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var updateMap = {};
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            var updateMapDevice = {};
            var prodConfigID;
            updateMap = [];
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    if (config.id) {
                        let changeTypeAtrtribute = config.getAttribute("ChangeType");
                        if (changeTypeAtrtribute) {
                            if (changeTypeAtrtribute.value === "Modify") {
                                prodConfigID = config.id;
                                if (config.relatedProductList && config.relatedProductList.length > 0) {
                                    config.relatedProductList.forEach(async (relatedConfig) => {
                                        if (relatedConfig.name.includes("Device") && relatedConfig.guid == guid) {
                                            if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                                let ChangeTypeDeviceAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                                if (ChangeTypeDeviceAttribute) {
                                                    let EarlyTerminationChargesAttribute = relatedConfig.configuration.getAttribute("EarlyTerminationCharge");
                                                    let SelectPlanNameAtrtribute = config.getAttribute("SelectPlanName");
                                                    if (EarlyTerminationChargesAttribute) {
                                                        if (ChangeTypeDeviceAttribute.value === "PayOut") {
                                                            EMPlugin_calculateTotalETCValue(relatedConfig.guid);
                                                        } else {
                                                            var ETCValue = 0;
                                                            allowSaveEM = false;
                                                            if (SelectPlanNameAtrtribute.value.includes("BYO")) {
                                                                let cnfg = await msComponent.getConfiguration(config.guid);
                                                               cnfg.status = false;
                                                                cnfg.statusMessage = "Cannot change the plan to BYO while the associated device is In-Contract";
                                                            }
                                                            updateMapDevice[relatedConfig.guid] = [];
                                                            updateMapDevice[relatedConfig.guid].push({
                                                                name: "EarlyTerminationCharge",
                                                                showInUi: false,
                                                                readOnly: true,
                                                                value: ETCValue,
                                                                displayValue: ETCValue
                                                            });
                                                            updateMapDevice[relatedConfig.guid].push({
                                                                name: "TotalFundAvailable",
                                                                showInUi: false
                                                            });
                                                            updateMapDevice[relatedConfig.guid].push({
                                                                name: "RedeemFund",
                                                                showInUi: false,
                                                                value: 0
                                                            });
                                                            updateMapDevice[relatedConfig.guid].push({  //Added: EDGE-190802
                                                                name: "RedeemFundIncGST",  
                                                                showInUi: false,
                                                                value: 0
                                                            });
                                                            updateMapDevice[relatedConfig.guid].push({
                                                                name: "OneOffChargeGST",
                                                                showInUi: false
                                                            });
                                                            console.log("updateCancelFlagVisibility - updating: ", updateMapDevice);
                                                            let keys = Object.keys(updateMapDevice);
                                                            for (let i = 0; i < keys.length; i++) {
                                                                await msComponent.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    });
                                }
                            }
                        }
                    }
                });
            }
        }
    }
    return Promise.resolve(true);
}

/************************************************************************************
* Author             : Ritika Jaiswal
* Method Name : EMPlugin_check_cancellationOfAllCMPs
* Defect/US # : EDGE-81135
* Invoked When: Mobile Subscription is being cancelled
* Description : To check if customer is cancelling all subscriptions
* Parameters : Solution
***********************************************************************************/
async function EMPlugin_check_cancellationOfAllCMPs() {
    var countCancel_CMP = 0;
    console.log("EMPlugin_check_cancellationOfAllCMPs :: checking if customer is cancelling all CMPs");
    let solution = activeEMSolution;
    if (solution.components && Object.values(solution.components).length > 0) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((subscriptionConfig) => {
                    let ChangeTypeAttribute = subscriptionConfig.getAttribute("ChangeType");
                    Object.values(subscriptionConfig.attributes).forEach((ChangeTypeAttribute) => {
                        if (ChangeTypeAttribute && ChangeTypeAttribute.value === "Cancel") {
                            countCancel_CMP++;
                        }
                    });
                });
                //console.log("alert for full CMP", comp.schema.configurations.length, countCancel_CMP);
                if (countCancel_CMP === msComponent.schema.configurations.length > 0) CS.SM.displayMessage("Cancelling these subscription(s) will result in the cancellation of entire CMP offer.", "info");
            }
        }
    }
    console.log("Counting cancellations:", countCancel_CMP);
}

/**************************************************************************************
* Author                : Ankit
* Method Name : calculate
* Description : Showing error after save
* Invoked When: Validate and save button
**************************************************************************************/
EMPlugin_updateStatusAfterSolutionLoad = async function () {
    console.log("EMPlugin_updateStatusAfterSolutionLoad");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (solution.components && Object.values(solution.components).length > 0) {
            isCommittedDataOffer = false;
            let configs = solution.getConfigurations();
            if (configs) {
                Object.values(configs).forEach((config) => {
                    let configAttr = config.getAttribute("OfferType");
                    if (configAttr && configAttr.displayValue === "Committed Data") {
                        console.log("Inside  Updating CommittedDataOffer ");
                        isCommittedDataOffer = true;
                    }
                });
                let updateConfigMapsubs = {};
                let updateConfigMapsubs1 = {};
                let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                if (msComponent) {
                    let isRelatedDeviceAdded = false;
                    let isRelatedDevicePayout = false;
                    let msConfigs = msComponent.getConfigurations();
                    if (msConfigs) {
                        Object.values(msConfigs).forEach(async (subsConfig) => {
                            updateConfigMapsubs[subsConfig.guid] = [];
                            updateConfigMapsubs1[subsConfig.guid] = [];
                            let OfferTypeAttribute = subsConfig.getAttribute("OfferTypeString");
                            let SelectPlanNameAttribute = subsConfig.getAttribute("SelectPlanName");
                            let changeTypeDisplayValue = "";
                            let selectPlanDisplayValue = "";
                            isRelatedDeviceAdded = false;
                            isRelatedDevicePayout = false;
                            let changeTypeAttribute = subsConfig.getAttribute("ChangeType");
                            if (changeTypeAttribute && changeTypeAttribute.value !== "Active") {
                                changeTypeDisplayValue = changeTypeAttribute.displayValue;
                            }
                            let selectPlanAttribute = subsConfig.getAttribute("Select Plan");
                            if (selectPlanAttribute && selectPlanAttribute.value !== "") {
                                selectPlanDisplayValue = selectPlanAttribute.displayValue;
                            }
                            if (selectPlanAttribute.name === "Select Plan" && selectPlanAttribute.value !== "" && changeTypeDisplayValue !== "Active") {
                                if (selectPlanAttribute.displayValue === "Local" || selectPlanAttribute.displayValue === "Local BYO" || selectPlanAttribute.displayValue === "Basic" || selectPlanAttribute.displayValue === "Entry" || selectPlanAttribute.displayValue === "Standard") {
                                    updateConfigMapsubs1[subsConfig.guid].push({
                                        name: "InternationalDirectDial",
                                        readOnly: false
                                    });
                                } else {
                                    updateConfigMapsubs1[subsConfig.guid].push({
                                        name: "InternationalDirectDial",
                                        readOnly: true
                                    });
                                }
                            }
                            let SubstatusAttribute = subsConfig.getAttribute("Substatus");
                            if (SubstatusAttribute && SubstatusAttribute.value === "Suspended") {
                                updateConfigMapsubs1[subsConfig.guid].push({
                                    name: "ChangeType",
                                    options: [CommonUtills.createOptionItem("Cancel")]//R34UPGRADE
                                });
                            }
                            let CustomerFacingServiceIdAttrib = subsConfig.getAttribute("CustomerFacingServiceId");
                            if (CustomerFacingServiceIdAttrib) {
                                 // Shweta added // EDGE-185652
                                 //let configName = CommonUtills.genericSequenceNumberAddInConfigName(subsConfig, "OfferTypeString", "SelectPlanName");
                                 // Shweta added 
                                // let configName = CommonUtills.genericSequenceNumberAddInConfigName(subsConfig, "OfferTypeString", "SelectPlanName");
                                 let configName = subsConfig.configurationName;
                                 let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
                                 //let configName = oldConfig;
                                 let getOfferType = subsConfig.getAttribute("OfferTypeString");
                                 let getplanName = subsConfig.getAttribute("SelectPlanName");
                                 if (getOfferType.displayValue != "" && getplanName.displayValue != "") {
                                     configName = getOfferType.displayValue + "-" + getplanName.displayValue + " _ " + spaceIndex;
                                 }
                                if (CustomerFacingServiceIdAttrib.value !== "") {
                                    // EDGE-185652
                                    configName = getOfferType.displayValue + "-" + getplanName.displayValue + "-" + CustomerFacingServiceIdAttrib.value+ " _ " + spaceIndex ;
                                    updateConfigMapsubs[subsConfig.guid] = [
                                        {
                                            name: "ConfigName",

                                            value: configName,// EDGE-185652
                                            displayValue: configName// EDGE-185652
                                            //value: OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value + "-" + CustomerFacingServiceIdAttrib.value,
                                            //displayValue: OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value + "-" + CustomerFacingServiceIdAttrib.value,


                                        }

                                    ];
                                    //subsConfig.configurationName = OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value + "-" + CustomerFacingServiceIdAttrib.value;
                                    subsConfig.configurationName = configName;// EDGE-185652
                                } else {
                                    updateConfigMapsubs[subsConfig.guid] = [
                                        {
                                            name: "ConfigName",
                                            value: configName, // EDGE-185652
                                            displayValue: configName // EDGE-185652
                                            //value: OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value,
                                            //displayValue: OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value,

                                        }

                                    ];
                                    subsConfig.configurationName = configName;// EDGE-185652
                                    //subsConfig.configurationName = OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value + ' '+count;
                                    //subsConfig.name = OfferTypeAttribute.value + "-" + SelectPlanNameAttribute.value + ' '+count;
                                }
                            }
                            if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                                subsConfig.relatedProductList.forEach((relatedConfig) => {
                                    if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === "Related Component") {
                                        isRelatedDeviceAdded = true;
                                    }
                                    console.log("isRelatedDeviceAdded:::::" + isRelatedDeviceAdded);
                                    if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                        let ChangeTypeDeviceAttrib = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                        if (ChangeTypeDeviceAttrib && ChangeTypeDeviceAttrib.value === "PayOut") {
                                            isRelatedDevicePayout = true;
                                        }
                                    }
                                });
                            }
                            if (selectPlanDisplayValue != "" && !selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === false && isCommittedDataOffer === false) {
                                console.log("Inside selectPlanDisplayValue Validation  ");
                                let config = await msComponent.getConfiguration(subsConfig.guid);
                                config.status = false;
                                config.statusMessage = "Please add One mobile Device.";
                            } else if (selectPlanDisplayValue != "" && selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false) {
                                console.log("Inside selectPlanDisplayValue Validation  ");
                                let config = await msComponent.getConfiguration(subsConfig.guid);
                                config.status = false;
                                config.statusMessage = "Please remove the added mobile device because BYO plan does not allow purchase of mobile device.";
                            }
                        });
                    }
                }
                console.log("updateConfigMapsubs::::", updateConfigMapsubs);
                let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                let keys = Object.keys(updateConfigMapsubs);
                var complock = component.commercialLock;
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMapsubs[keys[i]], true);
                }
                let keys1 = Object.keys(updateConfigMapsubs1);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMapsubs1[keys[i]], true);
                }
            }
        }
    }
};

/************************************************************************************
* Author             : Ankit Goswami
* Method Name : EMPlugin_updateCancelDeviceTypeAfterSolutionLoad
* Invoked When: Change Device Type is updated as Modisy
* Description : Set value of Change Type
* Parameters : guid
***********************************************************************************/

async function EMPlugin_updateCancelDeviceTypeAfterSolutionLoad(guid) {
    console.log("EMPlugin_updateCancelDeviceTypeAfterSolutionLoad");
    let solution = activeEMSolution;
    var updateMapDevice = {};
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let config = msComponent.getConfiguration(guid);
            if (config) {
                let changeTypeAtrtribute = config.getAttribute("ChangeType");
                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    if (changeTypeAtrtribute.value !== "" && changeTypeAtrtribute.value !== "Active" && changeTypeAtrtribute.value !== "New") {
                        for (const relatedConfig of config.relatedProductList) {
                            if (relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null) {
                                updateMapDevice[relatedConfig.guid] = [];
                                let RemainingTermAttr = relatedConfig.configuration.getAttribute("RemainingTerm");
                                let DeviceStatusAttr = relatedConfig.configuration.getAttribute("DeviceStatus");
                                let ChangeTypeDeviceAttr = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                let contractTermAtrtribute = relatedConfig.configuration.getAttribute("ContractTerm");
                                console.log("ChangeTypeDeviceAttr.value" + ChangeTypeDeviceAttr.value);
                                if (relatedConfig.name.includes("Device") && ChangeTypeDeviceAttr.value !== "New") {
                                    if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0 && changeTypeAtrtribute.value === "Cancel" && RemainingTermAttr.value > 0) {
                                        console.log("inside this");
                                        updateMapDevice[relatedConfig.guid].push(
                                            {
                                                name: "ChangeTypeDevice",
                                                value: "PayOut",
                                                readOnly: true,
                                                showInUi: true
                                            },
                                            {
                                                name: "RemainingTerm",
                                                value: 0,
                                                displayValue: 0
                                            },
                                            {
                                                name: "RedeemFund",
                                                showInUi: false
                                            },
                                            {   //Added: EDGE-190802
                                                name: "RedeemFundIncGST",
                                                showInUi: false
                                            },
                                            {
                                                name: "TotalFundAvailable",
                                                showInUi: false
                                            },
                                            {
                                                name: "OneOffChargeGST",
                                                showInUi: false
                                            }
                                        );
                                    } else if (DeviceStatusAttr.value !== "PaidOut" && ChangeTypeDeviceAttr.value === "PayOut" && changeTypeAtrtribute.value === "Modify" && IsMACBasket) {
                                        IsMACBasket = false;
                                        console.log("IsMACBasket>" + IsMACBasket);
                                        updateMapDevice[relatedConfig.guid].push(
                                            {
                                                name: "ChangeTypeDevice",
                                                value: "None",
                                                readOnly: false,
                                                showInUi: true
                                            },
                                            {
                                                name: "RedeemFund",
                                                readOnly: false,
                                                showInUi: true
                                            },
                                            {   //Added: EDGE-190802
                                                name: "RedeemFundIncGST",
                                                readOnly: true,
                                                showInUi: true
                                            },
                                            {
                                                name: "TotalFundAvailable",
                                                readOnly: false,
                                                showInUi: true
                                            }
                                        );
                                        updateMapDevice[relatedConfig.guid].push({
                                            name: "OneOffChargeGST",
                                            readOnly: false,
                                            showInUi: true
                                        });
                                        CommonUtills.remainingTermEnterpriseMobilityUpdate(relatedConfig.configuration, contractTermAtrtribute.displayValue, relatedConfig.guid, comp.name, ""); // EDGE-138108 Aditya Changed Signature, Added Comp Name
                                    } else {
                                        console.log("IsMACBasket111>" + IsMACBasket);
                                        updateMapDevice[relatedConfig.guid].push(
                                            {
                                                name: "ChangeTypeDevice",
                                                value: "None",
                                                showInUi: true
                                            },
                                            {
                                                name: "RedeemFund",
                                                readOnly: false,
                                                showInUi: false
                                            },
                                            {   //Added: EDGE-190802
                                                name: "RedeemFundIncGST",
                                                readOnly: true,
                                                showInUi: false
                                            },
                                            {
                                                name: "TotalFundAvailable",
                                                readOnly: false,
                                                showInUi: false
                                            },
                                            {
                                                name: "OneOffChargeGST",
                                                readOnly: false,
                                                showInUi: false
                                            }
                                        );
                                    }
                                    console.log("updateCancelFlagVisibility Attribute Update11111111111" + updateMapDevice);
                                    let keys = Object.keys(updateMapDevice);
                                    for (let i = 0; i < keys.length; i++) {
                                        await msComponent.updateConfigurationAttribute(keys[i], updateMapDevice[keys[i]], true);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

EMPlugin_getSelectedPlanForMobileSubscription = async function (guid) {
    console.log("inside EMPlugin_getSelectedPlanForMobileSubscription");
    let selectPlanDisplayValue = "";
    let product = activeEMSolution;
    if (product && product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (product.components && Object.values(product.components).length > 0) {
            let msComponent = product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            if (msComponent) {
                let config = msComponent.getConfiguration(guid);
                if (config) {
                    let att = config.getAttribute("Select Plan");
                    if (att) selectPlanDisplayValue = att.displayValue;
                }
            }
        }
    }
    return selectPlanDisplayValue;
};

EMPlugin_updateChangeTypeAttribute = async function (fromAddToMacBasket = false) {
    console.log("EMPlugin_updateChangeTypeAttribute");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var updateMap = [];
        var doUpdate = false;
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    let attribChangeType = config.getAttribute("ChangeType");
                    if (attribChangeType) {
                        doUpdate = true;
                        var changeTypeValue = attribChangeType.value;
                        if (!updateMap[config.guid]) updateMap[config.guid] = [];
                        console.log("basketChangeType: ", basketChangeType);
                        if (!basketChangeType || config.replacedConfigId === "" || config.replacedConfigId === undefined || config.replacedConfigId === null) {
                            console.log("Non MACD basket");
                            if (!changeTypeValue) {
                                changeTypeValue = "New";
                            }
                            updateMap[config.guid].push({
                                name: attribChangeType.name,
                                value: changeTypeValue,
                                displayValue: changeTypeValue,
                                showInUi: false,
                                readOnly: true
                            });
                        } else {
                            console.log("MACD basket");
                            if (changeTypeValue === "Active") {
                                EMPlugin_setAttributesReadonlyValueForConfiguration(ENTERPRISE_COMPONENTS.mobileSubscription, config.guid, true, ENTERPRISE_COMPONENTS.mobileSubscriptionEditableAttributeList);
                            }
                            var readonly = false;
                            if (config.id && changeTypeValue === "Cancel") readonly = true;
                            var showInUI = true;
                            if (!fromAddToMacBasket && config.id && changeTypeValue === "New") showInUI = false;

                            updateMap[config.guid].push({
                                name: attribChangeType.name,
                                showInUi: showInUI,
                                readOnly: false
                            });
                        }
                    }
                });
            }
            if (doUpdate) {
                console.log("EMPlugin_updateChangeTypeAttribute", updateMap);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await msComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
       }
    }
};

/************************************************************************************
* Author             : ankit G
* Method Name : showCommitedDataNotification
* Defect/US # : EDGE-112367
* Invoked When: Mobile Subscription configuration is added to the Mobile Subscription component
* Description : Show Toast message aboutX or XXL data SIM plan
* Parameters : N/A
***********************************************************************************/
function EMPlugin_showDataSimnotification() {
    if (!datashow) {
        CS.SM.displayMessage("Large Data SIM plans provide non-shareable data and do not share the data allowance chosen through committed data pack", "info");
    }
}

/**************************************************************************************
* Author                : Ankit
* Method Name : calculate
* Description : Calculated Device from all related produ
* Invoked When: Device is updated,
**************************************************************************************/
EMPlugin_updateDeviceEnrollmentAfterSolutionLoad = async function () {
    console.log("EMPlugin_updateDeviceEnrollmentAfterSolutionLoad");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var updateMap = {};
        var updateMapDevice = {};
        let count = 1; //EDGE-140536 added by ankit
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    if (config.relatedProductList && config.relatedProductList.length > 0) {
                        //EDGE-140536 added by ankit || start
                        if (config.relatedProductList.length > 1) {
                            count = 2;
                        }
                        //EDGE-140536 added by ankit || End
                        config.relatedProductList.forEach((relatedConfig) => {
                            if (relatedConfig.name.includes("Device")) {
                                if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                    var ReletedConfig = relatedConfig.configuration.replacedConfigId;
                                    let DeviceStatusAttr = relatedConfig.configuration.getAttribute("DeviceStatus");
                                    let InContractDeviceEnrollEligibilityAttr = relatedConfig.configuration.getAttribute("InContractDeviceEnrollEligibility");
                                    if (relatedConfig.configuration.replacedConfigId === "" || relatedConfig.configuration.replacedConfigId === null) {
                                        if (InContractDeviceEnrollEligibilityAttr) {
                                            if (InContractDeviceEnrollEligibilityAttr.value === "Eligible") { //DIGI-23866
                                                console.log("inside if:::");
                                                updateMap[relatedConfig.guid] = [
                                                    {
                                                        name: "DeviceEnrollment",
                                                        showInUi: true,
                                                        readOnly: false,
                                                        required: true,
                                                        options: [CommonUtills.createOptionItem("ENROL"), CommonUtills.createOptionItem("DO NOT ENROL")] //R34UPGRADE
                                                    },
                                                    {
                                                        name: "DeviceStatus",
                                                        showInUi: false,
                                                        readOnly: true,
                                                        value: "",
                                                        displayValue: ""
                                                    }
                                                ];
                                                console.log("update check: ", updateMap);
                                            } else {
                                                console.log("inside if else:::");
                                                updateMap[relatedConfig.guid] = [
                                                    {
                                                        name: "DeviceEnrollment",
                                                        value: "NOT ELIGIBLE",
                                                        displayValue: "NOT ELIGIBLE",
                                                        showInUi: true,
                                                        readOnly: true,
                                                        options: [CommonUtills.createOptionItem("NOT ELIGIBLE")] //R34UPGRADE
                                                    },
                                                    {
                                                        name: "DeviceStatus",
                                                        showInUi: false,
                                                        readOnly: true,
                                                        value: "",
                                                        displayValue: ""
                                                    }
                                                ];
                                            }
                                        }
                                    } else {
                                        console.log("insifrelse");
                                        if (ReletedConfig !== "" && ReletedConfig !== null && ReletedConfig !== undefined) {
                                            if (DeviceStatusAttr.value === "Connected" || DeviceStatusAttr.value === "ACTIVE MRO") {
                                                updateMap[relatedConfig.guid] = [
                                                    {
                                                        name: "DeviceStatus",
                                                        value: "ACTIVE MRO",
                                                        displayValue: "ACTIVE MRO",
                                                        showInUi: true,
                                                        readOnly: true
                                                    },
                                                    {
                                                        name: "DeviceEnrollment",
                                                        showInUi: false,
                                                        readOnly: true
                                                    }
                                                ];
                                            } else if (DeviceStatusAttr.value === "PaidOut") {
                                                updateMap[relatedConfig.guid] = [
                                                    {
                                                        name: "DeviceStatus",
                                                        value: "PaidOut",
                                                        displayValue: "PaidOut",
                                                        showInUi: true,
                                                        readOnly: true
                                                    },
                                                    {
                                                        name: "DeviceEnrollment",
                                                        showInUi: false,
                                                        readOnly: true
                                                    }
                                                ];
                                                if (count < 2) {
                                                    EMPlugin_setPlanDiscount(relatedConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    }
                });
            }
        }
        console.log("updateCancelFlagVisibility - updating: ", updateMap);
        let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let keys = Object.keys(updateMap);
        for (let i = 0; i < keys.length; i++) {
            await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
        }
    }
};

/*******************************************************************************
* Author      : Mahaboob Basha
* Method Name : EMPlugin_addDefaultEMOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. Adds one oe config for each comonent config if there is none
* Parameters  : none
******************************************************************************/
async function EMPlugin_addDefaultEMOEConfigs() {
    if (basketStage !== "Contract Accepted") return;
    console.log("EMPlugin_addDefaultEMOEConfigs");
    var oeMap = [];
    isCommittedDataOffer = false;
    let currentSolution = activeEMSolution;
    if (currentSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let configs = currentSolution.getConfigurations();
        Object.values(configs).forEach((config) => {
            let attribOfferType = config.getAttribute("OfferType");
            if (attribOfferType && attribOfferType.value.includes("Committed Data")) {
                isCommittedDataOffer = true;
            }
        });
        let msComponent = currentSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    let cancelconfig = config.getAttribute("ChangeType");
                    //Added by Ankit as part of Bulk OE story - EDGE-137466 || END
                    //if(cancelconfig && cancelconfig.length >0 && cancelconfig.value !== 'Cancel' && (isDeliveryEnrichmentNeededAtt.value ===true || isDeliveryEnrichmentNeededAtt.value==='true' || isCRDEnrichmentNeededAtt.value ===true || isCRDEnrichmentNeededAtt.value==='true')){// Added condition for EDGE-137466 bulk enrichment by ankit
                    if (cancelconfig && cancelconfig.value !== "Cancel") {
                        // Added condition for EDGE-137466 bulk enrichment by ankit// laxmi - removed few conditions original check above
                        Object.values(msComponent.orderEnrichments).forEach((oeSchema) => {
                            if (!oeSchema.name.toLowerCase().includes("numbermanagementv1")) {
                                var found = false;
                                if (config.orderEnrichmentList) {
                                    var oeConfig = config.orderEnrichmentList.filter((oe) => {
                                        return oe.name.includes(oeSchema.name) || oe.parent === oeSchema.id || oe.parent === oeSchema.productOptionId;
                                    });
                                    if (oeConfig && oeConfig.length > 0) found = true;
                                }
                                if (!found) {
                                    var el = {};
                                    el.componentName = msComponent.name;
                                    el.configGuid = config.guid;
                                    el.oeSchemaId = oeSchema.id;
                                    el.oeSchema = oeSchema;
                                    oeMap.push(el);
                                }
                            }
                        });
                    }
                });
            }
        }
    }

    if (oeMap.length > 0) {
        let map = [];
        console.log("Adding default oe config map--:", oeMap);
        for (var i = 0; i < oeMap.length; i++) {
            console.log(" Component name ----" + oeMap[i].componentName);
            let orderEnrichmentConfiguration = oeMap[i].oeSchema.createConfiguration();
            let component = currentSolution.findComponentsByConfiguration(oeMap[i].configGuid);
            await component.addOrderEnrichmentConfiguration(oeMap[i].configGuid, orderEnrichmentConfiguration, false);
        }
    }
    await EMPlugin_initializeEMOEConfigs();
    return Promise.resolve(true);
}

/**********************************************************************************************
* Author               : Mahaboob Basha
* Method Name : EMPlugin_initializeEMOEConfigs
* Invoked When: after solution is loaded, after configuration is added
* Description : 1. sets basket id to oe configs so it is available immediately after opening oe
* Parameters  : none
**********************************************************************************************/
async function EMPlugin_initializeEMOEConfigs(oeguid) {
    console.log("EMPlugin_initializeEMOEConfigs");
    let currentSolution = activeEMSolution;
    if (currentSolution) {
        if (currentSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
            if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
                for (let i = 0; i < Object.values(currentSolution.components).length; i++) {
                    let comp = Object.values(currentSolution.components)[i];
                    for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                        var config = Object.values(comp.schema.configurations)[j];
                        var updateMap = {};
                        if (config.orderEnrichmentList) {
                            for (let k = 0; k < config.orderEnrichmentList.length; k++) {
                                var oe = config.orderEnrichmentList[k];

                                if (oeguid && oeguid !== oe.guid) continue;

                                var basketAttribute = Object.values(oe.attributes).filter((a) => {
                                    return a.name.toLowerCase() === "basketid";
                                });
                                if (basketAttribute && basketAttribute.length > 0) {
                                    if (!updateMap[oe.guid]) updateMap[oe.guid] = [];

                                    updateMap[oe.guid].push({ name: basketAttribute[0].name, value: basketId });
                                }
                            }
                        }
                        if (updateMap && Object.keys(updateMap).length > 0) {
                            console.log("EMPlugin_initializeEMOEConfigs updateMap:", updateMap);
                            let keys = Object.keys(updateMap);
                            for (let h = 0; h < updateMap.length; h++) {
                                await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], false);
                            }
                        }
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}

/**
* Author      : Laxmi  2020-03-13
* Ticket      : EDGE-131531
* Description : Method to update ChangeType attribute
*/
EMPlugin_updateLinksAttributeEMS = async function (solution) {
    console.log("EMPlugin_updateLinksAttributeEMS");
    var doUpdate = false;
    var updateMap = [];
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    if (config.attributes && Object.values(config.attributes).length > 0) {
                        let attribChangeType = config.getAttribute("ChangeType");
                        let changeTypeValue = attribChangeType.value;
                        var readonly = false;
                        // EDGE-131531 - Added one more Status as  'Provisioning In Progress'
                        if ((config.id && changeTypeValue === "Cancel") || changeTypeValue === "Active" || changeTypeValue === "Provisioning In Progress") {
                            readonly = true;
                            doUpdate = true;
                            updateMap[config.guid] = [
                                {
                                    name: "viewDiscounts",
                                    showInUi: false
                                },
                                {
                                    name: "Price Schedule",
                                    showInUi: false
                                },
                                {
                                    name: "IsDiscountCheckNeeded",
                                    showInUi: false,
                                    readOnly: false,
                                    value: false
                                }
                            ];
                        } else if (config.id && changeTypeValue === "Modify") {
                            doUpdate = true;
                            updateMap[config.guid] = [
                                {
                                    name: "viewDiscounts",
                                    showInUi: true
                                }
                            ];
                        }
                    }
                });
            }
            if (doUpdate) {
                console.log("EMPlugin_updateLinksAttributeEMS", updateMap);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await msComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
        }
    }
};

// EMPlugin_subscribeToExpandButtonEvents = async(currentComponentName) => {

//     //////////////////////////////
//     //modify or remove this part to fit your component
//            console.log('Inside afterNavigate-----'+currentComponentName);
//     if (currentComponentName !== ENTERPRISE_COMPONENTS.mobileSubscription) {
//         return;
//     }

//     //////////////////////////////
//     setTimeout(() => {
//         //if user clicks on expand button in PC section header
//         let buttons = document.getElementsByClassName('expand-btn');

//         if (buttons) {
//             for (let i = 0; i < buttons.length; i++) {
//                 buttons[i].addEventListener("mouseup", (e) => {
//                     setTimeout(() => {
//                         EMPlugin_customAttributeLinkTextReplacements();
//                     }, 20);
//                 });
//             }
//         }

//         //if user clicks on Details link in PC section header
//         let tabs = document.getElementsByClassName('tab-name');
//         if (tabs) {
//             for (let i = 0; i < tabs.length; i++) {
//                 if (tabs[i].innerText !== 'Details') {
//                     continue;
//                 }
//                 tabs[i].addEventListener("mouseup", (e) => {
//                     setTimeout(() => {
//                         EMPlugin_customAttributeLinkTextReplacements();
//                     }, 20);
//                 });
//             }
//         }
//         //if user clicks on PC name in PC section header
//         let configs = document.getElementsByClassName('config-name');
//         if (configs) {
//             for (let i = 0; i < configs.length; i++) {
//                 configs[i].addEventListener("mouseup", (e) => {
//                     setTimeout(() => {
//                     }, 20);
//                 });
//             }
//         }
//            }, 100);

//            return Promise.resolve(true);
// }

// EMPlugin_customAttributeLinkTextReplacements = async() => {
//     return Promise.resolve(true);
// }

/**************************************************************************************
* Author                : Rohit Tripathi
* Method Name : EMPlugin_CalculateTotalRCForSolution
* Edge Number : EDGE-142087
* Description : This function will count the Quantity of Mobile Subscription Products added into the basket (Modify + New )
* Invoked When: Before Save
**************************************************************************************/
async function EMPlugin_CalculateTotalRCForSolution() {
    console.log("EMPlugin_CalculateTotalRCForSolution::::::::");
    var componentMap = {};
    var totalMSCount = 0;
    var OfferTypeVal;
    if (activeEMSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (activeEMSolution.schema && activeEMSolution.schema.configurations && Object.values(activeEMSolution.schema.configurations).length > 0) {
            Object.values(activeEMSolution.schema.configurations).forEach(async (parentConfig) => {
                componentMap[parentConfig.guid] = [];
                let attribOfferTypeString = parentConfig.getAttribute("OfferTypeString");
                OfferTypeVal = attribOfferTypeString.value;
                let msComponent = activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                if (OfferTypeVal == "Committed Data") {
                    if (msComponent) {
                        let msConfigs = msComponent.getConfigurations();
                        if (msConfigs) {
                            Object.values(msConfigs).forEach((config) => {
                                let cta = config.getAttribute("ChangeType");
                                let attribQuantity = config.getAttribute("Quantity");
                                if ((cta.value === "Modify" || cta.value === "New") && OfferTypeVal == "Committed Data") {
                                    console.log("Inside CTA New and Modify   ", cta.value, attribQuantity.value);
                                    totalMSCount = totalMSCount + parseInt(attribQuantity.value);
                                }
                            });
                        }
                        console.log("totalMSCount-->" + totalMSCount);
                        componentMap[parentConfig.guid] = [
                            {
                                name: "Quantity",
                                value: totalMSCount,
                                displayValue: totalMSCount,
                                showInUi: false,
                                readOnly: true
                            }
                        ];
                    }
                } else if (OfferTypeVal == "FairPlay Data") {
                    var qauntityforFairPlay = 1;
                    console.log("qauntityforFairPlay-->" + qauntityforFairPlay);
                    componentMap[parentConfig.guid] = [
                        {
                            name: "Quantity",
                            value: qauntityforFairPlay,
                            displayValue: qauntityforFairPlay,
                            showInUi: false,
                            readOnly: true
                        }
                    ];
                }
                if (componentMap) {
                    let component = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility);
                    let keys = Object.keys(componentMap);
                    for (let i = 0; i < keys.length; i++) {
                        await component.updateConfigurationAttribute(keys[i], componentMap[keys[i]], true);
                    }
                }
            });
        }
    }
    console.log("end of EMPlugin_CalculateTotalRCForSolution");
    return Promise.resolve(true);
}

//Hitesh added for setting EDMListToDecompose attribute at save
//This is shifted to PD Rule
async function EMPlugin_updateEDMListToDecomposeattribute(product) {
    console.log("EMPlugin_updateEDMListToDecomposeattribute");
    if (product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var statusMsg;
        if (product.components && Object.values(product.components).length > 0) {
            for (let i = 0; i < Object.values(product.components).length; i++) {
                var comp = Object.values(product.components)[i];
                if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        updateMap = [];
                        for (let j = 0; j < Object.values(comp.schema.configurations).length; j++) {
                            var mobilityConfig = Object.values(comp.schema.configurations)[j];
                            if (mobilityConfig.attributes && Object.values(mobilityConfig.attributes).length > 0) {
                                var EDMListToDecompose = "Mobility_Fulfilment,Mobile Access_Fulfilment,420_RC_654,263_NRC_601,326_ASR,151_ASR,263_AW_606,263_AW_607"; //Hitesh: Added 606,607 allowance spec to default list.
                                var selectPlan = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "Select Plan";
                                });

                                var OfferTypeString = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "OfferTypeString";
                                });

                                var InternationalDirectDial = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "InternationalDirectDial";
                                });

                                var MessageBank = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "MessageBank";
                                });

                                //Added for EDGE-89294
                                var MDMEntitled = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "MDMEntitled";
                                });
                                //Added for EDGE-103386
                                var DataPackChargeRec = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "DataPackChargeRec";
                                });
                                var IDDCharge = Object.values(mobilityConfig.attributes).filter((a) => {
                                    return a.name === "IDD Charge";
                                });

                                if (MessageBank && MessageBank.length > 0) {
                                    if (MessageBank[0].displayValue && MessageBank[0].displayValue === "VOICE to TEXT") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_RC_497";
                                    }
                                }

                                if (InternationalDirectDial && InternationalDirectDial.length > 0 && selectPlan && selectPlan.length > 0) {
                                    if (InternationalDirectDial[0].value && InternationalDirectDial[0].value !== "") {
                                        if (parseInt(IDDCharge[0].value) !== 0) {
                                            //Hitesh: Added parseInt for comparision condition.
                                            EDMListToDecompose = EDMListToDecompose + ",420_RC_669";
                                        }
                                    }
                                }

                                if (OfferTypeString && OfferTypeString.length > 0) {
                                    if (OfferTypeString[0].value && OfferTypeString[0].value === "FairPlay Data") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_637";
                                    } else if (OfferTypeString[0].value === "Committed Data") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_806";
                                    } else if (OfferTypeString[0].value === "Aggregated Data") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_641";
                                    } else if (OfferTypeString[0].value === "Data Pool Data") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_642";
                                    }
                                }

                                if (InternationalDirectDial && InternationalDirectDial.length > 0) {
                                    if (InternationalDirectDial[0].value !== "") {
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_644";
                                    }
                                }

                                if (selectPlan && selectPlan.length > 0) {
                                    //if (selectPlan[0].displayValue === "Global BYO" || selectPlan[0].displayValue === "Global" || selectPlan[0].displayValue === "Executive") {
                                    if (selectPlan[0].displayValue === "Global BYO" || selectPlan[0].displayValue === "Global" || selectPlan[0].displayValue === "Executive" || selectPlan[0].displayValue === "Global Data SIM" || selectPlan[0].displayValue === "Global Data SIM BYO") {
                                        //Hitesh Added for fix of EDGE-155203
                                        EDMListToDecompose = EDMListToDecompose + ",420_AW_670";
                                    }
                                }
                                //Added for  EDGE-89294
                                if (MDMEntitled && MDMEntitled.length > 0) {
                                    if (MDMEntitled[0].value === "true") {
                                        EDMListToDecompose = EDMListToDecompose + ",421_ASR";
                                    }
                                }
                                //Added for EDGE-103386
                                /*if (DataPackChargeRec && DataPackChargeRec.length > 0) {
                                                                                                                                       if (DataPackChargeRec[0].value !== '') {
                                                                                                                                                      EDMListToDecompose = EDMListToDecompose + ',420_RC_824';
                                                                                                                                       }

                                                                                                                        }*/

                                console.log("EDMListToDecompose", EDMListToDecompose);
                                updateMap[mobilityConfig.guid] = [
                                    {
                                        name: "EDMListToDecompose",
                                        // value: {
                                        value: EDMListToDecompose,
                                        displayValue: EDMListToDecompose
                                        // }
                                    }
                                ];
                            }
                        }
                        //await CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, updateMap, true);
                        //const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true);
                        let keys = Object.keys(updateMap);
                        var complock = comp.commercialLock;
                        // if(complock) comp.lock('Commercial', false);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                        }
                        //if(complock) comp.lock('Commercial', true);
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}

/************************************************************************************
* Author             : Ankit Goswami
* Method Name : EMPlugin_updateEDMListToDecomposeattributeForSolution
* Defect/US # : EDGE-103385
* Invoked When: Click on Validate and save button
* Description :Update EDMdecomposition field on PC
* Parameters : guid
***********************************************************************************/
// This is shifted to PD Rule
async function EMPlugin_updateEDMListToDecomposeattributeForSolution(loadedSolution) {
    console.log("EMPlugin_updateEDMListToDecomposeattributeForSolution");
    let updateSolMap = {};
    let commitedDataCheck = false;

    if (/*loadedSolution.type &&*/ loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        if (loadedSolution.schema && loadedSolution.schema.configurations && Object.values(loadedSolution.schema.configurations).length > 0) {
            Object.values(loadedSolution.schema.configurations).forEach((config) => {
                Object.values(config.attributes).forEach((attr) => {
                    if (attr.name === "OfferTypeString" && attr.value === "Committed Data") {
                        commitedDataCheck = true;
                    }
                });
            });

            Object.values(loadedSolution.schema.configurations).forEach(async (config) => {
                updateSolMap[config.guid] = [];
                Object.values(config.attributes).forEach((attr) => {
                    if (attr.name === "BonusDataPromotionEndDate" && commitedDataCheck) {
                        if (attr.value !== "") {
                            //if(basketContractSignDate <= BonusDataPromotionEndDate){
                            updateSolMap[config.guid].push({
                                name: "EDMListToDecompose",
                                // value: {
                                value: "420_AW_877,420_AW_805,420_RC_824",
                                displayValue: "420_AW_877,420_AW_805,420_RC_824"
                                // }
                            });
                            //}
                        } else {
                            updateSolMap[config.guid].push({
                                name: "EDMListToDecompose",
                                // value: {
                                value: "420_RC_824,420_AW_805",
                                displayValue: "420_RC_824,420_AW_805"
                                // }
                            });
                        }
                    } else if (attr.name === "BonusDataPromotionEndDate" && !commitedDataCheck) {
                        updateSolMap[config.guid].push({
                            name: "EDMListToDecompose",
                            // value: {
                            value: "No Specs",
                            displayValue: "No Specs"
                            // }
                        });
                    }
                });
                //CS.SM.updateConfigurationAttribute(ENTERPRISE_COMPONENTS.enterpriseMobility, updateSolMap, true);
                let component = await loadedSolution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility);
                //const cnfg = await component.updateConfigurationAttribute(config.guid, updateSolMap, true);
                let keys = Object.keys(updateSolMap);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateSolMap[keys[i]], true);
                }
            });
        }
    }
    return Promise.resolve(true);
}

/************************************************************************************
* Author             : Tihomir Baljak
* Method Name : validateCancelSolution
* Invoked When: in as EMPlugin_saveSolutionEM function (before save)
* Description : Show error message and prevent validate & save if Main solution change type is set as cancel and not all mobile subscriptions change type is set to cancel
* Parameters : solution
***********************************************************************************/
EMPlugin_validateCancelSolution = function (solution) {
    console.log("EMPlugin_validateCancelSolution");
    let configs = solution.getConfigurations();
    console.log("configs", configs);
    let changeTypeAttribute = Object.values(configs[0].attributes).filter((a) => {
        return a.name === "ChangeType" && a.value === "Cancel";
    });
    if (!changeTypeAttribute || changeTypeAttribute.length === 0) {
        return true;
    }

    let isValid = true;
    let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
    if (msComponent) {
        let msConfigs = msComponent.getConfigurations();
        if (msConfigs) {
            Object.values(msConfigs).forEach((mobilesubConfig) => {
                let changeTypeAttribute1 = mobilesubConfig.getAttribute("ChangeType");
                if (changeTypeAttribute1 && changeTypeAttribute1.value !== "Cancel") isValid = false;
            });
        }
    }
    if (!isValid) {
        CS.SM.displayMessage("When canceling whole solution all Mobile Subscriptions must be canceled too!", "error");
    }
    return isValid;
};

/**************************************************************************************
* Author                : Ankit
* Method Name : calculate
* Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
* Invoked When: PlanDiscount  is updated,
**************************************************************************************/
async function EMPlugin_setPlanDiscount(guid, componentName) {
    console.log("EMPlugin_setPlanDiscount");
    let solution = activeEMSolution;
    if (solution && solution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
        let msComponent = solution.getComponentByName(componentName);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach(async (parentConfig) => {
                    let planRecord = parentConfig.getAttribute("Select Plan");
                    let deviceRecord = parentConfig.getAttribute("InContractDeviceRecId");
                   if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
                        parentConfig.relatedProductList.forEach(async (relatedProduct) => {
                            if (relatedProduct.guid === guid) {
                                //Added by Ankit Goswami as a part of EDGE-143972 || Start
                                Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, "PlanShadowTCV", true);
                                Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, "IDDShadowTCV", true);
                                //Added by Ankit Goswami as a part of EDGE-143972 || End
                                let updateConfigMap = {};
                                // sum MROBonus of all related device

                                //Added by Ankit as a part of EDGE-148661 || End
                                let DeviceStatusAtrtribute = relatedProduct.configuration.getAttribute("DeviceStatus");
                                if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === "Related Component") {
                                    //Added As part of EDGE-123594 by end|| start
                                    let ChangeTypeDeviceAtrtribute = relatedProduct.configuration.getAttribute("ChangeTypeDevice");
                                    //Added As part of EDGE-123594|| End
                                    //relatedProduct.configuration.attributes.forEach((attribute) => {
                                    if (ChangeTypeDeviceAtrtribute.value === "PayOut" || DeviceStatusAtrtribute.value === "PaidOut") {
                                        //Added conditions As part of EDGE-123594
                                        updateConfigMap[parentConfig.guid] = [
                                            {
                                                name: "PlanDiscountLookup",
                                                value: "",
                                                displayValue: ""
                                            },
                                            {
                                                name: "TotalPlanBonus",
                                                value: 0,
                                                displayValue: 0
                                            }
                                        ];
                                        let keys = Object.keys(updateConfigMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
                                        }
                                    } else {
                                        EMPlugin_updatePlanDiscount(parentConfig, planRecord.value, deviceRecord.value);
                                    }
                                }
                                //Added by Ankit as a part of EDGE-148661 || Start
                                if (DeviceStatusAtrtribute.value !== "PaidOut") {
                                    pricingUtils.resetDiscountAttributes(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription);
                                    let cnfg = await msComponent.getConfiguration(parentConfig.guid);
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                                    skipsave = true;
                                } //Added by Ankit as a part of EDGE-148661 || End
                            }
                        });
                    }
                });
            }
        }
    }
}

/************************************************************************************
* Author                            : Ankit Goswami
* Method Name              : EMPlugin_EnableAttributesforModify
* Invoked When              : enable attributes
* Description    : enable schemas if it is active on Macd
* Parameters    : N/A
***********************************************************************************/
async function EMPlugin_EnableAttributesforModify(guid) {
    console.log("EMPlugin_EnableAttributesforModify");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let config = msComponent.getConfiguration(guid);
            if (config) {
                if (config.attributes && Object.values(config.attributes).length > 0) {
                    let changeTypeAtrtribute = config.getAttribute("ChangeType");
                    let PlanTypeStringAtrtribute = config.getAttribute("PlanTypeString");
                    let SelectPlanNameAtrtribute = config.getAttribute("SelectPlanName");
                    if (changeTypeAtrtribute.value === "Modify") {
                        EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "Select Plan", guid, false, true, true);
                        if (PlanTypeStringAtrtribute.value !== "Data") {
                            EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "MessageBank", guid, false, true, true);
                            if (SelectPlanNameAtrtribute.value === "Local" || SelectPlanNameAtrtribute.value === "Local BYO" || SelectPlanNameAtrtribute.value === "Basic" || SelectPlanNameAtrtribute.value === "Entry" || SelectPlanNameAtrtribute.value === "Standard") {
                                EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "InternationalDirectDial", guid, false, true, false);
                            } else {
                                EMPlugin_updateAttributeVisibility(ENTERPRISE_COMPONENTS.mobileSubscription, "InternationalDirectDial", guid, true, true, false);
                            }
                        }
                    }
                }
            }
        }
    }
}

/************************************************************************************
* Author                            : Ankit Goswami
* Method Name              : EMPlugin_DeviceAddconfigurationError
* Invoked When              : Add Device configuration and
* Description    : Read only schemas if it is active on Macd
* Parameters    : N/A
***********************************************************************************/
EMPlugin_DeviceAddconfigurationError = async function (guid) {
    console.log("EMPlugin_DeviceAddconfigurationError");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let configs = msComponent.getConfigurations();
            if (configs) {
                Object.values(configs).forEach((config) => {
                    let changeTypeAtrtribute = config.getAttribute("ChangeType");
                    if (changeTypeAtrtribute.value === "Cancel" && config.relatedProductList && config.relatedProductList.length > 1) {
                        config.relatedProductList.forEach(async (relatedConfig) => {
                            if (relatedConfig.guid === guid) {
                                let cnfg = await msComponent.getConfiguration(relatedConfig.guid);
                                cnfg.status = false;
                                cnfg.statusMessage = "You can not add device on Cancel Mobile subscription.";
                            }
                        });
                    }
                });
            }
        }
    }
};

/************************************************************************************
* Author             : ankit G
* Method Name : showCommitedDataNotification
* Defect/US # : EDGE-112122
* Invoked When:  Validate on save button
* Description : RemainingTerm calculate on Mobile subscription
* Parameters : N/A
***********************************************************************************/
async function EMPlugin_UpdateRemainingTermOnParent() {
    console.log("EMPlugin_UpdateRemainingTermOnParent");
    let solution = activeEMSolution;
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var updateRemainingTermMap = {};
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach(async (config) => {
                    updateRemainingTermMap[config.guid] = [];
                    if (config.relatedProductList && config.relatedProductList.length === 1) {
                        config.relatedProductList.forEach(async (relatedConfig) => {
                            if (relatedConfig.name.includes("Device")) {
                                if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                    var cancelFlag = "";
                                    var remainingTerm = 0;
                                    let remainingTermAttribute = relatedConfig.configuration.getAttribute("RemainingTerm");
                                    let cancelFlagAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                    remainingTerm = remainingTermAttribute.value;
                                    cancelFlag = cancelFlagAttribute.value;

                                    console.log("updateremainingTermOnMS    RemainingTerm" + remainingTerm);
                                    console.log("updateremainingTermOnMS    cancelFlag" + cancelFlag);
                                    console.log("updateremainingTermOnMS    Inside else");
                                    updateRemainingTermMap[config.guid] = [
                                        {
                                            name: "RemainingTerm",
                                            value: remainingTerm,
                                            displayValue: remainingTerm
                                        }
                                    ];

                                    console.log("updateremainingTermOnMS ", updateRemainingTermMap);
                                    let keys = Object.keys(updateRemainingTermMap);
                                    var complock = msComponent.commercialLock;
                                    if (complock) msComponent.lock("Commercial", false);
                                    for (let i = 0; i < keys.length; i++) {
                                        await msComponent.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true);
                                    }
                                    if (complock) msComponent.lock("Commercial", true);
                                }
                            }
                        });
                    } else if (config.relatedProductList && config.relatedProductList.length > 1) {
                        config.relatedProductList.forEach(async (relatedConfig) => {
                            if (relatedConfig.name.includes("Device")) {
                                if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                    var cancelFlag = "";
                                    var remainingTerm = 0;
                                    let remainingTermAttribute = relatedConfig.configuration.getAttribute("RemainingTerm");
                                    let cancelFlagAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");

                                    remainingTerm = remainingTermAttribute.value;
                                    cancelFlag = cancelFlagAttribute.value;

                                    console.log("updateremainingTermOnMS    RemainingTerm" + remainingTerm);
                                    console.log("updateremainingTermOnMS    cancelFlag" + cancelFlag);

                                    if (remainingTerm > 0) {
                                        console.log("updateremainingTermOnMS    Inside else");
                                        updateRemainingTermMap[config.guid] = [
                                            {
                                                name: "RemainingTerm",
                                                value: remainingTerm,
                                                displayValue: remainingTerm
                                            }
                                        ];
                                        console.log("updateremainingTermOnMS ", updateRemainingTermMap);
                                        let keys = Object.keys(updateRemainingTermMap);
                                        var complock = msComponent.commercialLock;
                                        if (complock) msComponent.lock("Commercial", false);
                                        for (let i = 0; i < keys.length; i++) {
                                            await msComponent.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true);
                                        }
                                        if (complock) msComponent.lock("Commercial", true);
                                    }
                                }
                            }
                        });
                    } else {
                        console.log("updateremainingTermOnMS    Inside outer else");
                        updateRemainingTermMap[config.guid] = [
                            {
                                name: "RemainingTerm",
                                value: 0,
                                displayValue: 0
                            }
                        ];

                        console.log("updateremainingTermOnMS ", updateRemainingTermMap);
                        let keys = Object.keys(updateRemainingTermMap);
                        var complock = msComponent.commercialLock;
                        if (complock) msComponent.lock("Commercial", false);
                        for (let i = 0; i < keys.length; i++) {
                            await msComponent.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], true);
                        }
                        if (complock) msComponent.lock("Commercial", true);
                    }
                });
            }
        }
    }
}

//EDGE - 81135 : Calculate ETC charges for cancellation type
EMPlugin_calculateTotalETCValue = async function (guid) {
    console.log("EMPlugin_calculateTotalETCValue", basketChangeType, guid);
    if (basketChangeType === "Change Solution") {
        let product = await activeEMSolution;
        var contractTerm;
        var disconnectionDate;
        var unitPriceRC;
        var prodConfigID;
        var prodConfigGuid;//Added by Aniket for CMP ETC issue EDGE-188102
        var deviceConfigID;
        var deviceConfig;
        var macdeviceConfig;
        console.log("EMPlugin_calculateTotalETCValue", product);
        if (product && product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
            let msComponent = product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            if (msComponent) {
                let msConfigs = msComponent.getConfigurations();
                if (msConfigs) {
                    Object.values(msConfigs).forEach(async (mobilesubConfig) => {
                        if (mobilesubConfig.id) {
                            let mBAttribute = mobilesubConfig.getAttribute("DisconnectionDate");
                            if (mBAttribute && mBAttribute.value) {
                                disconnectionDate = new Date(mBAttribute.value);
                                console.log("DisconnectionDate=", disconnectionDate);
                            }
                            if (mobilesubConfig.relatedProductList && Object.values(mobilesubConfig.relatedProductList).length > 0) {
                                Object.values(mobilesubConfig.relatedProductList).forEach((relatedConfig) => {
                                    if (relatedConfig.guid === guid || mobilesubConfig.guid === guid) {
                                        prodConfigID = mobilesubConfig.id;

										prodConfigGuid = mobilesubConfig.guid; //Added by Aniket for CMP ETC issue EDGE-188102




                                        if (relatedConfig.guid === guid) disconnectionDate = new Date();
                                        if (relatedConfig.type === "Related Component" && relatedConfig.name === "Device") {
                                            console.log("relatedConfig:", relatedConfig);
                                            deviceConfigID = relatedConfig.guid;
                                            deviceConfig = relatedConfig.configuration.replacedConfigId;
                                            macdeviceConfig = relatedConfig.configuration.id;
                                            let ChangeTypeDeviceattribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                            contractTerm = relatedConfig.configuration.getAttribute("ContractTerm");
                                            unitPriceRC = relatedConfig.configuration.getAttribute("InstalmentCharge");
                                        }
                                    }
                                });
                            }
                            if (disconnectionDate && contractTerm) {
                                var inputMap = {};
                                var updateMap = [];
                                inputMap["DisconnectionDate"] = disconnectionDate;
                                inputMap["etc_Term"] = contractTerm.displayValue;
                                inputMap["CalculateEtc"] = "";
                                inputMap["etc_UnitPrice"] = unitPriceRC.displayValue;
                                inputMap["ProdConfigId"] = prodConfigID;
                               inputMap["deviceConfigID"] = deviceConfig;
                                inputMap["macdeviceConfigID"] = macdeviceConfig;
                                console.log("inputMap", inputMap);
                                currentEMBasket = await CS.SM.getActiveBasket();
                                currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (values) => {
                                    var charges = values["CalculateEtc"];
                                    var chargesGst = parseFloat(charges * 1.1).toFixed(2);
                                    var deviceRemainingTerm = values["RemainingTerm"];
                                    console.log("Result", values["CalculateEtc"], charges);
                                    if (prodConfigGuid === guid) { //Added by Yash - EDGE-143435/EDGE-177524/EDGE-188102:: //Added prodConfigGuid by Aniket for CMP ETC issue
																																												updateMap[guid] = [
																																																 {
																																																				name: "EarlyTerminationCharge",
																																																				value: charges,
                                                displayValue: charges
																																																 },
																																																 {
																																																				name: "RemainingTerm", //Added by Yash - EDGE-143435/EDGE-177524
																																																				value: deviceRemainingTerm,
                                                displayValue: deviceRemainingTerm
																																																 },
																																																 {
																																																				name: "OneOffChargeGST",
																																																				label: "Balance Due On Device(Inc GST)",
																																																				value: chargesGst,
                                                displayValue: chargesGst
                                            }
                ];
              }
                                    if (deviceConfigID === guid) {
                                        updateMap[deviceConfigID] = [
                                            {
                                                name: "EarlyTerminationCharge",
                                                value: charges,
                                                displayValue: charges,

                                                showInUi: true


                                            },
                                            {
                                                name: "RemainingTerm", //Added by Yash - EDGE-143435/EDGE-177524
                                                value: deviceRemainingTerm,

                                                displayValue: deviceRemainingTerm


                                            },
                                            {
                                                name: "OneOffChargeGST",
                                                label: "Balance Due On Device(Inc GST)",
                                                value: chargesGst,
                                                displayValue: chargesGst,
                                                showInUi: true
                                            },
                                            {
                                                name: "RedeemFund",
                                                showInUi: true
                                            },
                                            {   //Added: EDGE-190802
                                                name: "RedeemFundIncGST",
                                                showInUi: true
                                            },
                                            {
                                                name: "TotalFundAvailable",
                                                showInUi: true
                                            }
                                        ];
                                    } else {
                                        updateMap[deviceConfigID] = [
                                            {
                                                name: "EarlyTerminationCharge",
                                                value: charges,
                                                displayValue: charges,

                                                showInUi: false


                                            },
                                            {
                                                name: "RemainingTerm", //Added by Yash - EDGE-143435/EDGE-177524
                                                value: deviceRemainingTerm,

                                                displayValue: deviceRemainingTerm


                                            },
                                            {
                                                name: "OneOffChargeGST",
                                                label: "Balance Due On Device(Inc GST)",
                                                value: chargesGst,
                                                displayValue: chargesGst,
                                                showInUi: false
                                            },
                                            {
                                                name: "RedeemFund",
                                                showInUi: false
                                            },
                                            {   //Added: EDGE-190802
                                                name: "RedeemFundIncGST",
                                                showInUi: false
                                            },
                                            {
                                                name: "TotalFundAvailable",
                                                showInUi: false
                                            }
                                        ];
                                    }
                                    let component = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                                    let keys = Object.keys(updateMap);
                                    for (let i = 0; i < keys.length; i++) {
                                        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                                    }
                                });
                            }
                        }
                    });
                }
            }
        }
    }
};

/************************************************************************************
* Author             : Sandip Deshmane
* Method Name : EMPlugin_validateDisconnectionDate
* Defect/US # : EDGE-138631
* Invoked When: Disconnection Date Attribute Updated
* Description : Validate Disconnection Date is not in the past.
* Parameters : componentName, guid, newValue
***********************************************************************************/
EMPlugin_validateDisconnectionDate = async function (componentName, guid, newValue) {
    let today = new Date();
    let attDate = new Date(newValue);
    today.setHours(0, 0, 0, 0);
    attDate.setHours(0, 0, 0, 0);
    let solution = await activeEMSolution;
    let component = await solution.getComponentByName(componentName);
    let config = await component.getConfiguration(guid);
    if (attDate < today) //INC000093943963 Laxmi removed = Sign
	{
        CS.SM.displayMessage("Please enter a date that is greater than today", "error");
        config.status = false;
        config.statusMessage = "Disconnection date should be greater than today!";
    } else {
        config.status = true;
        config.statusMessage = "";
    }
};

//Added by Aman Soni for EDGE-123575
function EMPlugin_processMessagesFromIFrame() {
    //console.log('EMPlugin_processMessagesFromIFrame');
    if (!communitySiteId) {
        return;
    }
    var data = sessionStorage.getItem("payload");
    var close = sessionStorage.getItem("close");
    var childWindow = sessionStorage.getItem("childWindow");
    //console.log('CW--->'+childWindow);
    if (childWindow) {
        childWindow.postMessage("Hey", window.origin);
    }
    var message = {};
    if (data) {
        //console.log('EMPlugin_processMessagesFromIFrame:', data);
        message["data"] = JSON.parse(data);
        EMPlugin_handleIframeMessage(message);
    }
    if (close) {
        //console.log('EMPlugin_processMessagesFromIFrame:', data);
        message["data"] = close;
        EMPlugin_handleIframeMessage(message);
    }
}

//Added by Aman Soni for EDGE-123575
async function EMPlugin_handleIframeMessage(e) {
	let product = activeEMSolution;
	// akanksha added for EDGE-174218
	 let currentBasket =  await CS.SM.getActiveBasket(); 
	if (e.data["command"] === "POCTEST" && e.data["caller"] === ENTERPRISE_COMPONENTS.mobileSubscription && e.data["data"]){
			let updateMap = {};
			let updateMap1 = {};//EDGE-197555
			let currentBasket =  await CS.SM.getActiveBasket(); 
            let solution = await CS.SM.getActiveSolution();
	        let solutionID = solution.solutionId;
			let payloadResponse = JSON.parse(e.data["data"]);
			Object.keys(payloadResponse).forEach(async (valueKey) =>
			{
				let mainKey = valueKey.replace(/['"]+/g, "");
				let mainValueRecordStr = JSON.stringify(payloadResponse[valueKey]);
				let mainValueRecordParsed = JSON.parse(mainValueRecordStr);
				let rec = mainValueRecordParsed[0];
				let rec1 = mainValueRecordParsed[1];//EDGE-197555
				let name = rec.name;
				updateMap[mainKey] = rec.value;
				updateMap1[mainKey] = rec1.value;//EDGE-197555
			});
	
			let updateMapConfig = {};
			if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) 
			{
				if (solution.components && Object.values(solution.components).length > 0) 
				{
					Object.values(solution.components).forEach(async(comp) => 
					{
						if ((comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) && comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {                    
							await	Object.values(comp.schema.configurations).forEach(async (config) => 
								{
									if(!config.disabled)
									{                                                                
										let simAvailabilityTypeVal = updateMap[config.guid];
										let pcSubType = updateMap1[config.guid];
										console.log ('simAvailabilityTypeVal--------Iframe',simAvailabilityTypeVal);
										if (simAvailabilityTypeVal!= null && simAvailabilityTypeVal!= undefined)
										{
											updateMapConfig[config.guid] = [];
											updateMapConfig[config.guid].push({
											name: 'SimAvailabilityType',
											value: simAvailabilityTypeVal,
											displayValue: simAvailabilityTypeVal
										});
										//EDGE-197555||start
										if (pcSubType!= null && pcSubType!= undefined)
										{
                                          updateMapConfig[config.guid].push({
											name: 'SubScenario',
											value: pcSubType,
											displayValue: pcSubType
										});
										}
											//EDGE-197555||End
										}
										var complock = comp.commercialLock;
										if (complock) await comp.lock("Commercial", false);
										let keys = Object.keys(updateMapConfig);
										for (let i = 0; i < keys.length; i++) {
											 comp.updateConfigurationAttribute(keys[i], updateMapConfig[keys[i]], true);
										}
										if (complock) comp.lock("Commercial", true);
										console.log ('updateMapConfig--------Iframe',updateMapConfig);
									} // config disabled
									
								});
							}
							await EMPlugin_setCMPTabsVisibility(); 
					});
				}
			}
	

	
		


	//await EMPlugin_resetDeliveryDetailsinOESchema(); // EDGE-174218 akanksha commented


	}
	// akanksha adding ends
    if (product && product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        var message = {};
        message = e["data"];
        message = message["data"];

        if (product == null) return Promise.resolve(true);

        if (e.data["command"] === "showPromo" && e.data["caller"] === "Enterprise Mobility" && e.data["data"] === configId) {
            await pricingUtils.postMessageToshowPromo(e.data["caller"], configId, "viewDiscounts");
        } else if (e.data["command"] === "StockCheck" && e.data["data"] === solutionID && e.data["caller"] === "Enterprise Mobility") {
            //EDGE-146972
            await stockcheckUtils.postMessageToStockCheck(e.data["caller"], solutionID);
        } else if (e.data["command"] === "pageLoadEnterprise Mobility" && e.data["data"] === solutionID) {
            pricingUtils.postMessageToPricing(callerName_EM, solutionID, IsDiscountCheckNeeded_EM, IsRedeemFundCheckNeeded_EM); //EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
        } else if (e.data && e.data["command"] != undefined) {
            if (e.data["command"] && e.data["command"] === "correlationId") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                if (e.data["data"]) {
                    pricingUtils.setCorrelationId(e.data["data"], ENTERPRISE_COMPONENTS.enterpriseMobility);
                }
            }
            //------------------ Added by Samish for EDGE-132203 on 10-02-2020 START ------------------//
            if (e.data["command"] && e.data["command"] === "timeout") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                if (e.data["data"]) {
                    pricingUtils.customLockSolutionConsole("unlock");
                    pricingUtils.setCorrelationId(e.data["data"], ENTERPRISE_COMPONENTS.enterpriseMobility);
                    pricingUtils.setDiscountStatus("None", ENTERPRISE_COMPONENTS.enterpriseMobility);
                }
            }
            //------------------ Added by Samish for EDGE-132203 on 10-02-2020 END ------------------//
            if (e.data["command"] && e.data["command"] === "ResponseReceived") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                if (e.data["data"]) {
                    var guidList = [];

                    if (product.components && product.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
                        let msComponent = product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                        if (msComponent) {
                            let msConfigs = msComponent.getConfigurations();
                            if (msConfigs) {
                                Object.values(msConfigs).forEach((config) => {
                                    guidList.push(config.guid);
                                });
                            }
                        }
                    }

                    guidList.toString();
                    // console.log('guidList-->' +guidList);
                    let inputMap = {};
                    inputMap["configIdList"] = guidList.toString();
                    inputMap["CorrelationId"] = e.data["data"];
                    // console.log(inputMap);
                    if (e.data["IsDiscountCheckAttr"] === "true") {
                        //EDGE-140967 added by ankit

                        currentEMBasket = await CS.SM.getActiveBasket();
                        await currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (response) => {
                            console.log(response);
                            var resultTCV = JSON.stringify(response["TCVMap"]);
                            if (resultTCV) {
                                var res = JSON.stringify(response);
                                var res1 = JSON.parse(res);
                                var res2 = JSON.stringify(res1.TCVMap);
                                var res3 = JSON.parse(res2);
                                var updateConfigMap1 = {};
                                var configTobeUpdated = false;
                                Object.keys(res3).forEach(async (valueKey) => {
                                    var mainKey = valueKey.replace(/['"]+/g, "");
                                    var attrNameMap = JSON.stringify(res3[valueKey]);
                                    var attrName = JSON.parse(attrNameMap);
                                    updateConfigMap1[mainKey.toString()] = [];
                                    Object.keys(attrName).forEach((keyValue) => {
                                        if (keyValue.toString() != null && keyValue.toString() != "" && keyValue.toString() != undefined) {
                                            updateConfigMap1[mainKey.toString()].push({
                                                name: keyValue.toString(),
                                                value: attrName[keyValue],
                                                displayValue: attrName[keyValue],
                                                readOnly: true
                                            });
                                            updateConfigMap1[mainKey.toString()].push({
                                                name: "IsDiscountCheckNeeded",
                                                value: false
                                            });
					    updateConfigMap1[mainKey.toString()].push({
                                                name: "Price Schedule",
                                                showInUi: true
                                            });
                                            configTobeUpdated = true;
                                        }
                                    });
                                    //added by ankit EDGE-132203 || start
                                    var IsUpadate = await EMPlugin_CheckErrorsOnSolution(product);
                                    if (!IsUpadate) {
                                        //added by ankit EDGE-132203 || end
                                        let component = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                                        let cnfg = await component.getConfiguration(mainKey.toString());
                                        cnfg.status = true;
                                    } /*else {
                                        pricingUtils.resetDiscountAttributes(ENTERPRISE_COMPONENTS.mobileSubscription);
                                    }*/
                                });
                                if (configTobeUpdated === true) {
                                    let solution = activeEMSolution;
                                    let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                                    let keys = Object.keys(updateConfigMap1);
                                    for (let i = 0; i < keys.length; i++) {
                                        await component.updateConfigurationAttribute(keys[i], updateConfigMap1[keys[i]], false);
                                    }
                                    // Arinjay or this has to be e.data['ApplicableGuid']
                                    pricingUtils.setDiscountStatus("Acknowledge", ENTERPRISE_COMPONENTS.enterpriseMobility);
                                }
                                skipsave = false; //added by ankit EDGE-132203
                                await EMPlugin_CheckErrorsOnSolution(product);
                            } else {
                                console.log("Price schedule could not be generated");
                                CS.SM.displayMessage("Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.", "error");
                            }
                            // }
                            return Promise.resolve(true);
                        });
                    } //EDGE-140967 added by ankit||start
                    if (e.data["IsRedeemFundCheckAttr"] === "true") {
                        if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                            return;
                        }
                        skipsave = false; //added by ankit EDGE-132203
                        pricingUtils.validateApplicableConfigsJS(e.data["ApplicableGuid"], ENTERPRISE_COMPONENTS.mobileSubscription);
                        await EMPlugin_CheckErrorsOnSolution(product);
                    }
                    //EDGE-140967 added by ankit||End
                    pricingUtils.customLockSolutionConsole("unlock");
                    //pricingUtils.setDiscountAttributesAtSolutionAfterResponse(message['data']);
                    pricingUtils.resetCustomAttributeVisibility();
                    setTimeout(function () {
                        pricingUtils.closeModalPopup();
                    }, 1000);
					// Added as a part of EDGE-169342
					await CS.SM.getActiveSolution().then(solution => {solution.validate()});
					
                    return Promise.resolve(true);
                }
				
            } else if (e.data["command"] && e.data["command"] === "unlockBasket") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                skipsave = false; //added by ankit EDGE-132203
                pricingUtils.validateNotApplicableConfigsJS(e.data["data"], ENTERPRISE_COMPONENTS.mobileSubscription);
                //pricingUtils.setDiscountAttributesToValidWhenDisNotApplicable();
                pricingUtils.setDiscountStatus("Acknowledge", ENTERPRISE_COMPONENTS.enterpriseMobility);
                pricingUtils.customLockSolutionConsole("unlock");
                EMPlugin_CheckErrorsOnSolution(product);
                setTimeout(function () {
                    pricingUtils.closeModalPopup();
				}, 1000);
				
				// Added as a part of EDGE-169342
				await CS.SM.getActiveSolution().then(solution => {solution.validate()});
				
                return Promise.resolve(true);
				
            } else if (e.data["command"] && e.data["command"] === "validNotApplicableConfigs") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                // added By Rohit EDGE-140459
                skipsave = false; //added by ankit EDGE-132203
                pricingUtils.validateNotApplicableConfigsJS(e.data["data"], ENTERPRISE_COMPONENTS.mobileSubscription);
                await EMPlugin_CheckErrorsOnSolution(product);
				
                return Promise.resolve(true);
            } else if (e.data["command"] && e.data["command"] === "Already triggered") {
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                skipsave = false; //added by ankit EDGE-132203
                pricingUtils.customLockSolutionConsole("unlock");
                setTimeout(function () {
                    pricingUtils.closeModalPopup();
                }, 1000);
				
				// Added as a part of EDGE-169342
				await CS.SM.getActiveSolution().then(solution => {solution.validate()});
				
                return Promise.resolve(true);
            } /////////////////added by shubhi start/////////////
            else if (e.data["command"] && e.data["command"] === "ErrorInResponse") {
                // added by shubhi //Edge-143527
                if (e.data["caller"] && e.data["caller"] !== "Enterprise Mobility") {
                    return;
                }
                pricingUtils.customLockSolutionConsole("unlock");
                pricingUtils.setDiscountStatusBasedonComponent("None", ENTERPRISE_COMPONENTS.enterpriseMobility, "DiscountStatus");
                console.log("Price schedule could not be generated");
                CS.SM.displayMessage("Price schedule could not be generated; Please try generating price schedule after sometime. If it continues to error out, please raise case.", "error"); // added by shubhi for error //Edge-121376
                setTimeout(function () {
                    pricingUtils.closeModalPopup();
                }, 1000);
								
                return Promise.resolve(true);
            } //////////////////// added by shubhi end ////////////////////////////////
            pricingUtils.resetCustomAttributeVisibility();
        }else if (e.data === 'close') { //EDGE-227318 defect fix
    await pricingUtils.closeModalPopup();
}
    }
    return Promise.resolve(true);
}

/**********************************************************************************************
* Author               : Mahaboob Basha
* Method Name : setEMOETabsVisibility
* Invoked When: after solution is loaded
* Description : 1. Do not render OE tabs for Cancel MACD or if basket stage !=contractAccepted
* Parameters  : configuration guid or nothing
*********************************************************************************************/
async function EMPlugin_setEMOETabsVisibility() {
    console.log("EMPlugin_setEMOETabsVisibility");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let oeToShow = [];
            Object.values(msComponent.orderEnrichments).forEach((oeSchema) => {
                if (!oeSchema.name.toLowerCase().includes("number")) {
                    oeToShow.push(oeSchema.name);
                }
            });
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                Object.values(msConfigs).forEach((config) => {
                    if (config.attributes && Object.values(config.attributes).length > 0) {
                        let changeTypeAttribute = config.getAttribute("ChangeType");
                        if (basketChangeType === "Change Solution" && changeTypeAttribute && changeTypeAttribute.displayValue === "Cancel") {
                            CS.SM.setOEtabsToLoad(msComponent.name, config.guid, []);
                            console.log("EMPlugin_setEMOETabsVisibility - hiding:", msComponent.name, config.guid);
                        } else {
                            CS.SM.setOEtabsToLoad(msComponent.name, config.guid, oeToShow);
                            console.log("EMPlugin_setEMOETabsVisibility - showing:", msComponent.name, config.guid);
                        }
                    }
                });
            }
        }
    }
    return Promise.resolve(true);
}

/************************************************************************************
* Author             : Ankit Goswami
* Method Name : EMPlugin_setAttributesReadonlyValueForsolution
* Invoked When: onloadsolution
* Description : Read only schemas if it is active on Macd
* Parameters : N/A
***********************************************************************************/
EMPlugin_setAttributesReadonlyValueForsolution = async function () {
    console.log("EMPlugin_setAttributesReadonlyValueForsolution");
    let solution = activeEMSolution;
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
        let componentMap = new Map();
        let configs = solution.getConfigurations();
        if (configs) {
            let componentMap = new Map();
            Object.values(configs).forEach((config) => {
                let componentMapattr = {};
                let changeTypesolution = config.getAttribute("ChangeType");
                Object.values(config.attributes).forEach((attr) => {
                    if (attr.name !== "ChangeType" && attr.name !== "ConfigName" && changeTypesolution.value !== "Modify" && changeTypesolution.value !== "Cancel") {
                        componentMapattr[attr.name] = [];
                        componentMapattr[attr.name].push({ IsreadOnly: true });
                    } else {
                        componentMapattr["DataPackPlan"] = [];
                        componentMapattr["DataPackPlan"].push({ IsreadOnly: false });
                    }
                });
                componentMap.set(config.guid, componentMapattr);
            });
            await CommonUtills.setAttributesReadonlyValue(ENTERPRISE_COMPONENTS.enterpriseMobility, componentMap);
        }
        if (solution.components && Object.values(solution.components).length > 0 && !SolutionChangeType) {
            let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            if (msComponent) {
                let msConfigs = msComponent.getConfigurations();
                if (msConfigs) {
                    Object.values(msComponent.schema.configurations).forEach((config) => {
                        let componentMapattr = {};
                        let changeTypeAtrtribute = config.getAttribute("ChangeType");
                        // if (changeTypeAtrtribute.value === 'Active' && attr.name !=='ChangeType' && attr.name !=='RedeemFund') {
                        // componentMapattr[attr.name] = [];
                        // componentMapattr[attr.name].push({'IsreadOnly':true});
                        // }
                        Object.values(config.attributes).forEach((attr) => {
                            if (changeTypeAtrtribute.value === "Active" && attr.name !== "ChangeType" && attr.name !== "RedeemFund") {
                                componentMapattr[attr.name] = [];
                                componentMapattr[attr.name].push({ IsreadOnly: true });
                            }
                        });
                        componentMap.set(config.guid, componentMapattr);
                        if (config.relatedProductList && config.relatedProductList.length > 0) {
                            config.relatedProductList.forEach((relatedConfig) => {
                                if (relatedConfig.name.includes("Device")) {
                                    if (relatedConfig.configuration.replacedConfigId !== "" && relatedConfig.configuration.replacedConfigId !== undefined && relatedConfig.configuration.replacedConfigId !== null && relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                        Object.values(relatedConfig.configuration.attributes).forEach((attr) => {
                                            if (attr.name !== "ChangeTypeDevice" && attr.name !== "RedeemFund") {
                                                componentMapattr[attr.name] = [];
                                                componentMapattr[attr.name].push({ IsreadOnly: true });
                                            }
                                        });
                                        componentMap.set(relatedConfig.guid, componentMapattr);
                                    }
                                }
                            });
                        }
                    });
                }
            }
        }
    }
};

/**************************************************************************************
* Author                : Ankit
* Method Name : calculate
* Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
* Invoked When: Device RP's MRO Bonus is updated, and
*                                                          Device RP is deleted.
**************************************************************************************/
async function EMPlugin_calculateDeviceEnrollEligibility(compName, parentConfig) {
    console.log("EMPlugin_calculateDeviceEnrollEligibility");
    let updateConfigMap = {};
    let DeviceEnroll = null;
    if (parentConfig.relatedProductList && parentConfig.relatedProductList.length > 0) {
        parentConfig.relatedProductList.forEach((relatedProduct) => {
            if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === "Related Component") {
                let attribute = relatedProduct.configuration.getAttribute("InContractDeviceEnrollEligibility");
                if (attribute && attribute.value) {
                    DeviceEnroll = attribute.value;
                }
            }
        });
    }
    updateConfigMap[parentConfig.guid] = [
        {
            name: "InContractDeviceEnrollEligibility",
            value: DeviceEnroll,
            displayValue: DeviceEnroll
        }
    ];
    let solution = activeEMSolution;
    let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
    let keys = Object.keys(updateConfigMap);
    for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
    }
}

/**********************************
* Aditya                          03-Dec-2019
* Populate the value of DataPackPlan of CMP to Mobile Subscription's DP Plan
*********************************/

EMPlugin_clonedataplanattributevalue = async function (parentValue) {
    var attrvalue = null;
   let solution = activeEMSolution;
    if (parentValue === null && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
        let datapackplan = Object.values(solution.schema.configurations)[0].getAttribute("DataPackAllowanceValue");
        if (datapackplan && datapackplan.value) {
            attrvalue = datapackplan.value;
        }
    } else attrvalue = parentValue.value;

    if (solution.components) {
        let msComponent = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let msConfigs = msComponent.getConfigurations();
            if (msConfigs) {
                let updateMap = [];
                Object.values(msConfigs).forEach((config) => {
                    let attribDPPlan = config.getAttribute("DP Plan");
                    if (attribDPPlan && parentValue != "" && attribDPPlan.value != parentValue) {
                        updateMap[config.guid] = [
                            {
                                name: "DP Plan",
                                value: attrvalue
                            }
                        ];
                    }
                });
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await msComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
                }
                updateComp = false;
            }
        }
    }
    return Promise.resolve(true);
};

/*************************************************************************************
* Author             : Venkata Ramanan G
* Method Name : EMPlugin_showMDMtenancynotification
* Defect/US # : EDGE-30181
* Invoked When: Mobile Subscription configuration is added to the Mobile Subscription component
* Description : Show Toast message about the MDM Tenancy
* Parameters : N/A
***********************************************************************************/
function EMPlugin_showMDMtenancynotification() {
    if (!show) {
        CS.SM.displayMessage("Please note that you may require MDM Tenancy to this order. If it is required please add it from Solutions", "info");
        mdmvalidmobconfig = 0;
        show = true;
    }
}

/**************************************************************************************
* Author                : Li Tan
* Method Name : EMPlugin_addAllowancesOEConfigs
* Descriptoin : create Allowance NC Schema record from allowances linked to the selected plan
* Invoked When: afterAttributeUpdated of
*                                                                        - Select Plan attribute in Mobile Subscription
*                                                                        - OfferType attribute in Enterprice Mobility
**************************************************************************************/
async function EMPlugin_addAllowancesOEConfigs(compName, compGUID, schemaId, priceItemid, addOnPriceItemId) {
    let inputMap = {};
    if (priceItemid !== "") {
        inputMap["priceItemId"] = priceItemid;
    }
    if (addOnPriceItemId !== "") {
        inputMap["addOnPriceItemId"] = addOnPriceItemId;
    }
    await currentEMBasket.performRemoteAction("SolutionGetAllowanceData", inputMap).then(async (response) => {
        if (response && response["allowances"] != undefined) {
            console.log("allowances", response["allowances"]);
            aArray = [];
            response["allowances"].forEach((a) => {
                let aData = {};
                aData["name"] = a.cspmb__allowance__r.Name;
                aData["specId"] = a.cspmb__allowance__r.specId__c;
                aData["billingSpecId"] = a.cspmb__allowance__r.billingSpecId__c;
                aData["ocsProdId"] = a.cspmb__allowance__r.ocsProdId__c;
                aData["startDate"] = a.cspmb__allowance__r.startDate__c;
                aData["endDate"] = a.cspmb__allowance__r.endDate__c;
                aData["type"] = a.cspmb__allowance__r.type__c;
                aData["subType"] = a.cspmb__allowance__r.subType__c;
                aData["unitOfMeasure"] = a.cspmb__allowance__r.Unit_Of_Measure__c;
                aData["amount"] = a.cspmb__allowance__r.cspmb__amount__c;
                aArray.push(aData);
            });

            let currentSolution = activeEMSolution;
            if (aArray.length > 0) {
                let map = [];
                for (let i = 0; i < aArray.length; i++) {
                    let orderEnrichmentConfiguration = aArray[i].oeSchema.createConfiguration(map);
                    let component = currentSolution.findComponentsByConfiguration(aArray[i].configGuid);
                    await component.addOrderEnrichmentConfiguration(aArray[i].configGuid, orderEnrichmentConfiguration, false);
                }
            }
        } else {
            console.log("no response");
        }
    });

    return Promise.resolve(true);
}

function EMPlugin_toDate(dateStr) {
    var parts = dateStr.split("/");
    return new Date(parts[2], parts[1] - 1, parts[0]);
}

/**************************************************************************************
* Author                : Li Tan
* Method Name : EMPlugin_calculateTotalMROBonus
* Description : Calculated Total Plan Bonus from all related product where there is MRO Bonus.
* Invoked When: Device RP's MRO Bonus is updated, and
*                                                          Device RP is deleted.
**************************************************************************************/
async function EMPlugin_calculateTotalMROBonus(compName, parentConfig, relatedProduct) {
    console.log("EMPlugin_CheckRedeemFundDiscount");
    let totalPlanBonus = 0;
    let updateConfigMap = {};
    ["PlanShadowTCV", "IDDShadowTCV"].forEach((el) => Utils.emptyValueOfAttribute(parentConfig.guid, ENTERPRISE_COMPONENTS.mobileSubscription, el, true));
    if (relatedProduct.name === ENTERPRISE_COMPONENTS.device && relatedProduct.type === "Related Component") {
        let ChangeTypeDeviceAtrtribute = relatedProduct.configuration.getAttribute("ChangeTypeDevice");
        let DeviceStatusAtrtribute = relatedProduct.configuration.getAttribute("DeviceStatus");
        //Added As part of EDGE-123594|| End
        Object.values(relatedProduct.configuration.attributes).forEach((attribute) => {
            if (attribute.name === "MROBonus" && attribute.value && ChangeTypeDeviceAtrtribute.value !== "PayOut" && DeviceStatusAtrtribute.value !== "PaidOut") {
                //Added conditions As part of EDGE-123594
                totalPlanBonus = parseFloat(totalPlanBonus) + parseFloat(attribute.value);
            }
        });
    }
    updateConfigMap[parentConfig.guid] = [
        {
            name: "TotalPlanBonus",
            value: totalPlanBonus.toFixed(2),
            displayValue: totalPlanBonus.toFixed(2)
        }
    ];
    let solution = activeEMSolution;
    let component = await solution.getComponentByName(compName);
    let keys = Object.keys(updateConfigMap);
    for (let i = 0; i < keys.length; i++) {
        await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], false);
    }
}

/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-140967
* Method Name : EMPlugin_CheckRedeemFundUpdate
* Invoked When: RedeemFund Will be update on device
* Description : Enabling Redemption as Discount for Device Payout on EM
***********************************************************************************************/

async function EMPlugin_CheckRedeemFundUpdate(guid) {
    let IsUpadateRequired = false;
    let updateMapFundonDevice = {};
    let solution = activeEMSolution;
    if (solution.name === ENTERPRISE_COMPONENTS.enterpriseMobility && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let subsConfig = await comp.getConfiguration(guid);
        if (subsConfig) {
            let ChangeTypeAttribute = subsConfig.getAttribute("ChangeType");
            let RedeemFundAttribute = subsConfig.getAttribute("RedeemFund");
            if (subsConfig.guid === guid) {
                if (ChangeTypeAttribute.value === "Cancel" && RedeemFundAttribute.value > 0) {
                    subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                        if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                            IsUpadateRequired = true;
                            updateMapFundonDevice[relatedConfig.guid] = [];
                            updateMapFundonDevice[relatedConfig.guid] = [
                                {
                                    name: "RedeemFund",
                                    value: RedeemFundAttribute.value,
                                    displayValue: RedeemFundAttribute.value
                                }
                            ];
                            updateMapFundonDevice[relatedConfig.guid] = [
                                {
                                    name: "RedeemFundIncGST",
                                    value: RedeemFundAttribute.value * 1.1,
                                    displayValue: RedeemFundAttribute.value * 1.1
                                }
                            ];
                        }
						if (IsUpadateRequired && updateMapFundonDevice) {
							let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
							// added by shubhi for EDGE-190170 start---------
							let keys = Object.keys(updateMapFundonDevice);
							for (let i = 0; i < keys.length; i++) {
								await component.updateConfigurationAttribute(keys[i], updateMapFundonDevice[keys[i]], true);
							} 
							//await component.updateConfigurationAttribute(relatedConfig.guid, updateMapFundonDevice, false);
							// added by shubhi for EDGE-190170 end---------

                }
                    });
            }
        }
    }

    }

    
}

/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-140967
* Method Name : EMPlugin_CheckRedeemFundDiscount
* Invoked When: RedeemFund Will be change or Change Type on Device or Change Type on Mobile device will change.
* Description : Enabling Redemption as Discount for Device Payout on EM
***********************************************************************************************/
async function EMPlugin_CheckRedeemFundDiscount(guid) {
    console.log("EMPlugin_CheckRedeemFundDiscount");
    var IsUpadateSubOnly = false;
    let updateMapFund = new Map();
    let componentMapNew = new Map();
    let solution = activeEMSolution;
    if (solution.name === ENTERPRISE_COMPONENTS.enterpriseMobility && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let subsConfig = await comp.getConfigurations();
        if (subsConfig) {
            Object.values(subsConfig).forEach(async (subsConfig) => {
                IsUpadateSubOnly = false;
                var IsUpdateAttribute = false;
                let ChangeTypeAttribute = subsConfig.getAttribute("ChangeType");
                let RedeemFundAttribute = subsConfig.getAttribute("RedeemFund");
                if (subsConfig.guid === guid) {
                    IsUpadateSubOnly = true;
                   if (ChangeTypeAttribute.value === "Cancel" && RedeemFundAttribute.value > 0) {
                        IsUpdateAttribute = true;
                    }
                } else if (ChangeTypeAttribute.value === "Modify") {
                    if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                        subsConfig.relatedProductList.forEach((relatedConfig) => {
                            if (relatedConfig.guid === guid) {
                                IsUpadateSubOnly = true;
                                if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === "Related Component") {
                                    if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                        let ChangeTypeDeviceAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                        let RedeemFundDeviceAttribute = relatedConfig.configuration.getAttribute("RedeemFund");
                                        if (ChangeTypeDeviceAttribute.value === "PayOut" && RedeemFundDeviceAttribute.value > 0) {
                                            IsUpdateAttribute = true;
                                        }
                                    }
                                }
                            }
                        });
                    }
                }
                if (IsUpdateAttribute) {
                    componentMapNew.set("IsRedeemFundCheckNeeded", true);
                } else if (IsUpadateSubOnly) {
                    componentMapNew.set("IsRedeemFundCheckNeeded", false);
                    let cnfg = await comp.getConfiguration(subsConfig.guid);
                    cnfg.status = true;
                    cnfg.statusMessage = "";
                }
               if (componentMapNew) {// EDGE-190170 
                    updateMapFund.set(subsConfig.guid, componentMapNew);
                }
            });
        }
        if (updateMapFund) {
            CommonUtills.UpdateValueForSolution(ENTERPRISE_COMPONENTS.mobileSubscription, updateMapFund);
        }
    }
}

/**************************************************************************************
* Author                : Ankit
* Method Name : calculate
* Edge Number               : EDGE-132203
* Description : Showing error For device
* Invoked When: While invoking
**************************************************************************************/
async function EMPlugin_CheckErrorsOnSolution(solution) {
    let IsUpdateStatus = false;
    try {
        if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
            isCommittedDataOffer = false;
            let solutionConfigs = solution.getConfigurations();
            let msComponent = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            let compConfig = await msComponent.getConfigurations();
            if (compConfig && Object.values(compConfig).length > 0 && solutionConfigs && Object.values(solutionConfigs).length > 0) {
                let configAttr = solutionConfigs[0].getAttribute("OfferType");
                if (configAttr && configAttr.displayValue === "Committed Data") {
                    isCommittedDataOffer = true;
                }
                Object.values(compConfig).forEach(async (subsConfig) => {
                    let changeTypeDisplayValue = "";
                    let selectPlanDisplayValue = "";
                    let IsDiscountCheckNeededval = "";
                    isRelatedDeviceAdded = false;
                    isRelatedDevicePayout = false;
                    let changeTypeAttr = subsConfig.getAttribute("ChangeType");
                    if (changeTypeAttr && changeTypeAttr.value !== "Active") changeTypeDisplayValue = changeTypeAttr.displayValue;
                    let selectPlanAttr = subsConfig.getAttribute("Select Plan");
                    if (selectPlanAttr && selectPlanAttr.value !== "") selectPlanDisplayValue = selectPlanAttr.displayValue;
                    let IsDiscountCheckNeededAttr = subsConfig.getAttribute("IsDiscountCheckNeeded");
                    if (IsDiscountCheckNeededAttr) IsDiscountCheckNeededval = IsDiscountCheckNeededAttr.value;
                    if (subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                        subsConfig.relatedProductList.forEach((relatedConfig) => {
                            if (relatedConfig.name === ENTERPRISE_COMPONENTS.device && relatedConfig.type === "Related Component") {
                                isRelatedDeviceAdded = true;
                            }
                            if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                let ChangeTypeAttribute = relatedConfig.configuration.getAttribute("ChangeTypeDevice");
                                if (ChangeTypeAttribute && ChangeTypeAttribute.value === "PayOut") isRelatedDevicePayout = true;
                            }
                        });
                    }
                                                                           //INC000093772606 added by shubhi----------------------
                                                                           if(subsConfig.replacedConfigId && subsConfig.disabled){
                                                                                          let activeSolutionUp = await CS.SM.getActiveSolution();
                                                                                          let componentUp = await activeSolutionUp.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
                                                                                          let cnfg = await componentUp.getConfiguration(subsConfig.guid); 
                                                                                          cnfg.status = true;
                                                                                          cnfg.statusMessage =''; 
                                                                           }//INC000093772606 added by shubhi end----------------------
                                                                           else if (selectPlanDisplayValue != "" && !selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === false && isCommittedDataOffer === false) {
                        IsUpdateStatus = true;
                        //let component1New = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription); // added by ankit/shubhi for Edge -EDGE-169319
                        //let cnfg = await component1New.getConfiguration(subsConfig.guid);
                        subsConfig.status = false;
                        subsConfig.statusMessage = "Please add One mobile Device.";
                    } else if (selectPlanDisplayValue.includes("BYO") && isRelatedDeviceAdded === true && isCommittedDataOffer === false && isRelatedDevicePayout === false) {
                        IsUpdateStatus = true;
                        //let componentUp = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
                        //let cnfg = await componentUp.getConfiguration(subsConfig.guid);
                        subsConfig.status = false;
                        subsConfig.statusMessage = "Please remove the added mobile device because BYO plan does not allow purchase of mobile device.";
                    } else if (IsDiscountCheckNeededval === "true" || IsDiscountCheckNeededval === true) {
                        //added by shubhi 14/08
                        IsUpdateStatus = true;
                        // let componentUp = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
                        // let cnfg = await componentUp.getConfiguration(subsConfig.guid);
                        subsConfig.status = false;
                        subsConfig.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                    } else {
                        // let componentUp = await activeEMSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);// // added by ankit/shubhi for Edge -EDGE-169319
                        // let cnfg = await componentUp.getConfiguration(subsConfig.guid);
                        subsConfig.status = true;
                        subsConfig.statusMessage = "";
                    }
                });
            }
        }
    } catch (err) {
        console.log(err);
    }
    console.log("EMPlugin_CheckErrorsOnSolution " + IsUpdateStatus);
    return IsUpdateStatus;
}

// Added by Aman Soni as a part of EDGE-123593
async function EMPlugin_updatePricescheduleCheck(guid) {
    console.log("EMPlugin_updatePricescheduleCheck");
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let config = await comp.getConfigurations(guid);
        if (config) {
            let cta = config.getAttribute("ChangeType");
            let OldPlanType = config.getAttribute("OldPlanTypeString");
            let OldDataPack = config.getAttribute("OldDataPackPlan");
            let OldIDDString = config.getAttribute("OldIDD");
            let NewIDD = config.getAttribute("InternationalDirectDial");
            let SelectPlan = config.getAttribute("Select Plan");
            let DPPlan = config.getAttribute("DP Plan");
            if (cta.value === "Modify" && (OldPlanType.value !== SelectPlan.displayValue || OldIDDString.value !== NewIDD.displayValue || DPPlan.value !== OldDataPack.value)) {
                pricingUtils.resetDiscountAttributes(ENTERPRISE_COMPONENTS.mobileSubscription);
            }
        }
    }
}

async function EMPlugin_updatePlanDiscount(parentConfig, planRecord, deviceRecord) {
    let inputMap2 = {};
    inputMap2["planRecord"] = planRecord;
    inputMap2["deviceRecord"] = deviceRecord;
    let discountRecId = null;
    let discountValue = null;
    //Laxmi Added Business ID for Device Type EDGE-127421
    let businessIDDeviceType = null;
    console.log("EMPlugin_updatePlanDiscount::::", inputMap2);
    await currentEMBasket.performRemoteAction("MobileSubscriptionGetDiscountData", inputMap2).then(async (response) => {
        console.log("response EMPlugin_updatePlanDiscount", response);
        if (response && response["planDiscountList"] != undefined) {
            console.log("planDiscountList", response["planDiscountList"]);
            response["planDiscountList"].forEach((a) => {
                if (a.Id != null) {
                    discountRecId = a.Id;
                    discountValue = a.Recurring_Charge__c;
                    businessIDDeviceType = a.DiscountChargeID__c; // Added for EDGE-127421
                }
            });
            if (discountRecId != "") {
                let updateConfigMap2 = {};
                updateConfigMap2[parentConfig.guid] = [
                    {
                        name: "PlanDiscountLookup",
                        value: discountRecId,
                        displayValue: discountValue
                    },
                    {
                        name: "TotalPlanBonus",
                        value: discountValue.toFixed(2),
                        displayValue: discountValue.toFixed(2)
                    },
                    //Laxmi - EDGE-127421 Added to Map deviceTypeBusinessID - value to be displaed coming from map
                    {
                        name: "deviceTypeBusinessID",
                        value: businessIDDeviceType,
                        displayValue: businessIDDeviceType
                    }
                ];
                let solution = activeEMSolution;
                let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
                let keys = Object.keys(updateConfigMap2);
                for (let i = 0; i < keys.length; i++) {
                    await component.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
                }
            }
        } else {
            console.log("no response");
        }
    });
}

/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-134880
* Method Name : EMPlugin_CancelledCLIRemoteAction
* Invoked When: Plan or IDD Will change
* Description : Set TCV as previous config

***********************************************************************************************/
async function EMPlugin_CancelledCLIRemoteAction(inputMapCLI, componentMap) {
    var updateMap = {};
    console.log("EMPlugin_CancelledCLIRemoteAction: ", inputMapCLI);
    var avgDiscountedPricePlan;
    var avgDiscountedPriceAddon;
    await currentEMBasket.performRemoteAction("SolutionHelperCancelledCLI", inputMapCLI).then((values) => {
        console.log("EMPlugin_CancelledCLIRemoteAction result:", values);
        if (values["avgDiscountedPricePlan"]) avgDiscountedPricePlan = values["avgDiscountedPricePlan"];
        if (values["avgDiscountedPriceAddon"]) avgDiscountedPriceAddon = values["avgDiscountedPriceAddon"];
    });

    if (avgDiscountedPricePlan) {
        Object.keys(componentMap).forEach(async (comp) => {
            componentMap[comp].forEach((element) => {
                updateMap[element.guid] = [
                    {
                        name: "PlanShadowTCV",
                        value: avgDiscountedPricePlan,
                        displayValue: avgDiscountedPricePlan
                    },
                    {
                        name: "IDDShadowTCV",
                        value: avgDiscountedPriceAddon,
                        displayValue: avgDiscountedPriceAddon
                    }
                ];
            });
            console.log("EMPlugin_checkConfigurationSubscriptionsForEM update map", updateMap);
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
           }
        });
    }
    return Promise.resolve(true);
}

/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-134880
* Method Name : EMPlugin_CancelledCLIRemoteAction
* Invoked When: Plan or IDD Will change
* Description : Set TCV as previous config

***********************************************************************************************/
async function EMPlugin_CancelledCLI(inputMapCLI) {
    console.log("EMPlugin_CancelledCLI::::::::");
    let componentMap = {};
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let compConfig = await comp.getConfigurations();
        Object.values(compConfig).forEach((config) => {
            let cta = config.getAttribute("ChangeType");
            let OldPlanType = config.getAttribute(OldPlanTypeString);
            let OldDataPack = config.getAttribute("OldDataPackPlan");
            let OldIDDString = config.getAttribute("OldIDD");
            let NewIDD = config.getAttribute("InternationalDirectDial");
            let SelectPlan = config.getAttribute("Select Plan");
            let DPPlan = config.getAttribute("DP Plan");
            if (cta.value === "Modify" && ((OldPlanType.value === SelectPlan.displayValue && OldIDDString.value === NewIDD.displayValue) || DPPlan.value !== OldDataPack.value)) {
                if (!componentMap[comp.name]) componentMap[comp.name] = [];
                if (config.replacedConfigId) componentMap[comp.name].push({ id: config.replacedConfigId, guid: config.guid });
                EMPlugin_CancelledCLIRemoteAction(inputMapCLI, componentMap);
            }
        });
    }
}

/***********************************************************************************************
* Author                : Laxmi Rahate
* EDGE                   : EDGE-142321
* Method Name : EMPlugin_resetDeliveryDetailsinOESchema
* Invoked When: Solution is Loaded
* Description : Handling Port out reversal scenarios

***********************************************************************************************/
async function EMPlugin_resetDeliveryDetailsinOESchema() {
	console.log("@@@@@@@@Inside EMPlugin_resetDeliveryDetailsinOESchema");
	var updateMap = {};
	let product = activeEMSolution;
	if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility && product.components && Object.values(product.components).length > 0) {
		let comp = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
		let compConfig = await comp.getConfigurations();
		if (compConfig) {
			Object.values(compConfig).forEach(async (config) => {
				if (!updateMap[config.guid]) updateMap[config.guid] = [];
				if (!config.disabled) {
					//EDGE-174218 akanksha added
					let SimAvailabilityType = await config.getAttribute("SimAvailabilityType");
					let deviceShipping = await config.getAttribute("DeviceShipping");
					let SimAvailabilityTypeVal = SimAvailabilityType.value;
					let simAvailabilityVal = 'FALSE';
					let deviceShippingVal = deviceShipping.value;
					if((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))
						simAvailabilityVal = 'TRUE';
					console.log('simAvailabilityVal----'+simAvailabilityVal+'deviceShippingVal-------'+deviceShippingVal);
						if (simAvailabilityVal === "TRUE" || deviceShippingVal === "TRUE") 
						{
							console.log("Either flag is true - Delivery is needed");
							updateMap[config.guid].push(
								{
									name: "isDeliveryEnrichmentNeededAtt",
									value: true
								});
								
								updateMap[config.guid].push(
								{
									name: "isDeliveryDetailsRequired",
									value: true
								});
							needsUpdate = true;
						} 
						else 
						{
							console.log("Flags are false - Delivery is NOT needeed");
							updateMap[config.guid].push(
								{
									name: "isDeliveryDetailsRequired",
									value: false
								},
								{
									name: "isDeliveryEnrichmentNeededAtt",
									value: false
								}
							);
							needsUpdate = true;
						}
					
					if (updateMap) {
						let keys = Object.keys(updateMap);
						comp.lock('Commercial', false);
						for (let h = 0; h < keys.length ; h++) {

							await comp.updateConfigurationAttribute(keys[h], updateMap[keys[h]], true);
							
						}
					}					
					var updateMapNew = {};
					if (config.orderEnrichmentList) {
						config.orderEnrichmentList.forEach(async (oe) => {
							if (!updateMapNew[oe.guid]) updateMapNew[oe.guid] = [];						
							if (simAvailabilityVal === "FALSE" && deviceShippingVal === "FALSE") {
								
								{
									console.log("Both Attribute Values are FALSE, made OE DeliveryDetails Optional");
									updateMapNew[oe.guid].push({ name: "DeliveryContact", required: false }, { name: "DeliveryAddress", required: false });
								}
								
							}
							else 
								console.log("DeliveryAddress OE Isnt Optional");
						});
					}
					if (updateMapNew) {
					let keys = Object.keys(updateMapNew);							
					for (let h = 0; h < keys.length; h++) {
						await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMapNew[keys[h]], true);
					}
					}
				}
			});
		}
	}
}

/**
* Author      : Laxmi  2020-04-29
* Ticket      : EDGE-142321
* Description : Handle DeviceSHipping Attribute
*/
EMPlugin_handleDeviceShipping = async function (solution) {
    console.log("EMPlugin_handleDeviceShipping");
    var doUpdate = false;
    var updateMap = [];
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let msComponent = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (msComponent) {
            let compConfig = await msComponent.getConfigurations();
            Object.values(compConfig).forEach((config) => {
                console.log("MACD basket");
                if (basketChangeType === "Change Solution") {
                    if (config.relatedProductList && config.relatedProductList.length > 0) {
                        config.relatedProductList.forEach((relatedConfig) => {
                            if (relatedConfig.configuration.replacedConfigId != undefined || relatedConfig.configuration.replacedConfigId != null) {
                                console.log("Replaced COnfig available for config id " + relatedConfig.guid + "Changing Shipping Required to False for this Config");
                                if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                                    doUpdate = true;
                                    if (!updateMap[relatedConfig.guid]) updateMap[relatedConfig.guid] = [];
                                    updateMap[relatedConfig.guid].push({
                                        name: "DeviceShipping",
                                        value: "FALSE"
                                    });
                                }
                            }
                        });
                    }
                }
            });
            if (doUpdate) {
                console.log("EMPlugin_handleDeviceShipping", updateMap);
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await msComponent.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
            }
        }
    }
};

/***********************************************************************************************
* Author                : Laxmi Rahate
* EDGE                   : EDGE-142321
* Method Name : EMPlugin_handlePortOutReversal
* Invoked When: Solution is Loaded
* Description : Handling Port out reversal scenarios

***********************************************************************************************/
async function EMPlugin_handlePortOutReversal() {
    console.log("EMPlugin_handlePortOutReversal");
    let updateMap = {};
    let deviceShippingVal = "";
    let isPortOutReversal = false;
    let mobSubDeviceShipping = "FALSE";
    let shippingRequired = "TRUE";
   // let existingSIM;
    let deviceAttribute;
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let compConfig = await comp.getConfigurations();
        Object.values(compConfig).forEach((config) => {
            if (!config.disabled) {
                deviceShippingVal = "";
                mobSubDeviceShipping = "FALSE";
                let changeTypeValue = "";
                //let existingSIMVar = "";
                let ChangeType = config.getAttribute("ChangeType");
				//Removed as a part of EDGE-170011
               // existingSIM = config.getAttribute("UseExitingSIM");
               /* if (existingSIM.length > 0 && existingSIM.value && existingSIM.value != null) {
                    existingSIMVar = existingSIM.value;
                }*/
                changeTypeValue = ChangeType.value;
                updateMap[config.guid] = [];
                if (window.BasketChange === "Change Solution" && changeTypeValue === "New" && config.replacedConfigId) {
                    isPortOutReversal = false;
                    shippingRequired = "FALSE";
                }
                if (changeTypeValue === "Active" || changeTypeValue === "Modify") {
                    isPortOutReversal = false;
                    shippingRequired = "FALSE";
                } else {
                    isPortOutReversal = hasPortOutReversalPermission;
                    /*if (existingSIMVar === true || existingSIMVar === "true") {
                        shippingRequired = "FALSE";
                        console.log("Shipping Required Value is TRUE!!!!!!!!!!!!!");
                    } else shippingRequired = "TRUE";*/
                }

                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    config.relatedProductList.forEach((relatedConfig) => {
                        if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                            deviceAttribute = CommonUtills.getAttribute(relatedConfig.configuration, "DeviceShipping");
                            if (deviceAttribute && deviceAttribute.value === "TRUE") {
                                mobSubDeviceShipping = "TRUE";
                            }
                        }
                    });
                }
                console.log("isPortOutReversal --------------------------value is " + isPortOutReversal);

                if (isPortOutReversal) {
                    updateMap[config.guid].push(
						//Removed as a part of EDGE-170011
                       /* {
                            name: "UseExitingSIM",
                            showInUi: true,
                            readOnly: false,

                        }*/

                        {
                            name: "isPortOutReversal",
                            value: true,
                            showInUi: isPortOutReversal,
                            readOnly: true
                        }
                    );
                } else {
                    updateMap[config.guid].push(
						//Removed as a part of EDGE-170011
                       /* {
                            name: "UseExitingSIM",
                            showInUi: false,
                            readOnly: false,

                        }*/

                        {
                            name: "isPortOutReversal",
                            value: false,
                            showInUi: false,
                            readOnly: false
                        }
                    );
                }

                updateMap[config.guid].push({
                    name: "ShippingRequired",
                    value: shippingRequired,
                    readOnly: true
                });
                if (deviceAttribute) {
                    updateMap[config.guid].push({
                        name: "DeviceShipping",
                        readOnly: true,
                        value: mobSubDeviceShipping
                    });
                }
                if (basketStage === "Contract Accepted") {
                    console.log("Bakset stage is COntract Accepted!!!!!!!!making attributes readonly");
					//Removed as a part of EDGE-170011
                   /* updateMap[config.guid].push({
                        name: "UseExitingSIM",
                        showInUi: isPortOutReversal,
                        readOnly: true,

                    });*/


                    if (isPortOutReversal) {
                        updateMap[config.guid].push({
                            name: "isPortOutReversal",
                            value: true,
                            showInUi: isPortOutReversal,
                            readOnly: true
                        });
                    }
                }
            }
        });
    }
    if (updateMap) {
        console.log("EMPlugin_handlePortOutReversal update map", updateMap);
        let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (component && component != null && component != undefined) {
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
            }
        }
    }
    return Promise.resolve(true);
}

/***********************************************************************************************
* Author                : Laxmi Rahate
* EDGE                   : EDGE-142321
* Method Name : handleDevice
* Invoked When: Solution is Loaded
* Description : EMPlugin_handleDeviceStatusAndPlanDiscount

***********************************************************************************************/
async function EMPlugin_handleDeviceStatusAndPlanDiscount(guid) {
    console.log("EMPlugin_handleDeviceStatusAndPlanDiscount");
    let updateMap = {};
    let blankOutPlanDiscount = true;
    let solution = activeEMSolution;
    if (solution && solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        let config = await comp.getConfiguration(guid);
        let changeTypeValue = "";
        let deviceStatusVal = "";
        let ChangeType = config.getAttribute("ChangeType");
        changeTypeValue = ChangeType.value;
        updateMap[config.guid] = [];
        if (config.id && changeTypeValue === "Modify") {
            if (config.relatedProductList && config.relatedProductList.length > 0) {
                config.relatedProductList.forEach((relatedConfig) => {
                    if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                        let deviceAttribute = relatedConfig.configuration.getAttribute("DeviceStatus");
                        if (deviceAttribute && deviceAttribute.value !== "PaidOut") blankOutPlanDiscount = false;
                    }
                });
            }
            if (blankOutPlanDiscount) {
                updateMap[config.guid].push({
                    name: "TotalPlanBonus",
                    value: 0,
                    displayValue: 0
                });
            }
        }
        if (updateMap) {
            console.log("EMPlugin_handleDeviceStatusAndPlanDiscount update map", updateMap);
            let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
            await component.updateConfigurationAttribute(config.guid, updateMap, false);
        }
    }
    return Promise.resolve(true);
}

/*           
               Added as part of EDGE-149887 
               This method updates the Solution Name based on Offer Name if User didnt provide any input
*/
/*async function EMPlugin_updateSolutionNameEM() {
    let solution = activeEMSolution;
               var listOfAttributes = ["Solution Name", "GUID"],
                              attrValuesMap = {};
               var listOfAttrToGetDispValues = ["OfferName", "OfferType"],
                              attrValuesMap2 = {};
               attrValuesMap = await CommonUtills.getAttributeValues(listOfAttributes, ENTERPRISE_COMPONENTS.enterpriseMobility);
               attrValuesMap2 = await CommonUtills.getAttributeDisplayValues(listOfAttrToGetDispValues, ENTERPRISE_COMPONENTS.enterpriseMobility);
               console.log("attrValuesMap..." + attrValuesMap);
               if (attrValuesMap["Solution Name"] === DEFAULTSOLUTIONNAME_EM) {
                              let updateConfigMap = {};
                              updateConfigMap[attrValuesMap["GUID"]] = [
                                             {
                                                            name: "Solution Name",
                                                            value: attrValuesMap2["OfferName"] + "_" + attrValuesMap2["OfferType"],
                                                            displayValue: attrValuesMap2["OfferName"] + "_" + attrValuesMap2["OfferType"]
                                             }
                              ];
                              if (updateConfigMap) {
                                             let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.enterpriseMobility);
                                             await component.updateConfigurationAttribute(attrValuesMap["GUID"], updateConfigMap, true);
                              }
               }
               return Promise.resolve(true);                      
}*/

/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-169973
* Method Name : EMPlugin_UpdateRelatedConfigForChild()
* Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

***********************************************************************************************/
async function EMPlugin_UpdateRelatedConfigForChild() {
    let loadedSolution = activeEMSolution;
    if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
        window.currentSolutionName = loadedSolution.name;
        let comp = await loadedSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let cmpConfig = await comp.getConfigurations();
            Object.values(cmpConfig).forEach(async (subsConfig) => {
                if (subsConfig.disabled == false && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                    subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                        let inputMap = {};
                        inputMap["GetConfigurationId"] = relatedConfig.guid;
                        inputMap["basketId"] = basketId;
                        await currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
                            var replaceId = result["replacedConfigid"];
                            var configGuid = result["childGuid"];
                            var relatedConfigId = result["childId"];
                            if (configGuid === relatedConfig.guid) relatedConfig.configuration.replacedConfigId = replaceId;
                            relatedConfig.configuration.id = relatedConfigId;
                        });
                    });
                }
            });
        }
    }
    return Promise.resolve(true);
}
/***********************************************************************************************
* Author                : Shubhi Vijayvergia
* EDGE number : EDGE-169973
* Method Name : EMPlugin_UpdateRelatedConfigForChild()
* Invoked When: On solution load and add to macd 
 * Description : Update Replace ConfigId

***********************************************************************************************/
async function EMPlugin_UpdateRelatedConfigForChildMac(guid) {
    let loadedSolution = activeEMSolution;
    if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
        window.currentSolutionName = loadedSolution.name;
        let comp = await loadedSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let subsConfig = await comp.getConfiguration(guid);
            if (subsConfig && subsConfig.disabled == false && subsConfig.relatedProductList && subsConfig.relatedProductList.length > 0) {
                subsConfig.relatedProductList.forEach(async (relatedConfig) => {
                    let inputMap = {};
                    inputMap["GetConfigurationId"] = relatedConfig.guid;
                    inputMap["basketId"] = basketId;
                    await currentEMBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
                        var replaceId = result["replacedConfigid"];
                        var configGuid = result["childGuid"];
                        var relatedConfigId = result["childId"];
                        if (configGuid === relatedConfig.guid) relatedConfig.configuration.replacedConfigId = replaceId;
                        relatedConfig.configuration.id = relatedConfigId;
                    });
                });
            }
        }
    }
    return Promise.resolve(true);
}
/***********************************************************************************************
* Author                : Ankit Goswami
* EDGE number : EDGE-169973
* Method Name : EMPlugin_ChangeOptionValue()
* Invoked When: After attribute changes
* Description : Update Replace ConfigId

***********************************************************************************************/
async function EMPlugin_ChangeOptionValue(guid) {
    let updateMap = {};
    let optionValues = [];
    optionValues = [CommonUtills.createOptionItem("Modify"), CommonUtills.createOptionItem("Cancel")]; //R34UPGRADE
    let loadedSolution = activeEMSolution;
    if (loadedSolution.componentType && loadedSolution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && loadedSolution.components && Object.values(loadedSolution.components).length > 0) {
        window.currentSolutionName = loadedSolution.name;
        let comp = await loadedSolution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let cmpConfig = await comp.getConfiguration(guid);
            if (cmpConfig) {
                updateMap[cmpConfig.guid] = [
                    {
                        name: "ChangeType",
                        options: optionValues
                    }
                ];
            }
            let keys = Object.keys(updateMap);
            var complock = comp.commercialLock;
            if (complock) comp.lock("Commercial", false);
            for (let i = 0; i < keys.length; i++) {
                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
            if (complock) comp.lock("Commercial", true);
        }
    }
    return Promise.resolve(true);
}

/*********************** added by shubhi EDGE-169973 ********************/
//Modified by Aman Soni for 164619 || Start
async function handlePortOutReversalForIndvConf(guid) {
    console.log("function handlePortOutReversalForIndvConf");
    let updateMap = {};
    let deviceShippingVal = "";
    let isPortOutReversal = false;
    let mobSubDeviceShipping = "FALSE";
    var existingSIM;
    var showPortOutinUI;
    let solution = activeEMSolution;
    let deviceAttribute;
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let config = await comp.getConfiguration(guid);
            if (config.guid === guid && !config.disabled) {
                deviceShippingVal = "";
                mobSubDeviceShipping = "FALSE";
                let isPortOutRevEM = config.getAttribute("isPortOutReversal");



                //var existingSIMEM = config.getAttribute("UseExitingSIM");



                updateMap[config.guid] = [];

                if (config.relatedProductList && config.relatedProductList.length > 0) {
                    config.relatedProductList.forEach((relatedConfig) => {
                        if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
                            deviceAttribute = CommonUtills.getAttribute(relatedConfig.configuration, "DeviceShipping");
                            if (deviceAttribute) {
                                deviceShippingVal = deviceAttribute.value;
                                if (deviceShippingVal === "TRUE") {
                                    mobSubDeviceShipping = "TRUE";
                                }
                            }
                        }
                    });
                }

                if (!config.replacedConfigId) {
                    isPortOutReversal = hasPortOutReversalPermission;
                }
                if (isPortOutReversal) {
                    updateMap[config.guid].push({
                        name: "isPortOutReversal",
                        value: false,
                        showInUi: true,
                        readOnly: false
                    });

                    if (isPortOutRevEM.value) {
                        updateMap[config.guid].push({
                            name: "isPortOutReversal",
                            value: isPortOutRevEM.value,
                            showInUi: true,
                            readOnly: false
                        });




                       /*  updateMap[config.guid].push({
                            name: "UseExitingSIM",
                            value: existingSIMEM.value,
                            showInUi: true,
                            readOnly: false,
                        }); */
                    }
                } else if (config.replacedConfigId) {
                    //Either not a portout reversa righst available or its Modify Config
                    /* updateMap[config.guid].push({
                        name: "UseExitingSIM",
                        value: false,
                        showInUi: false,
                        readOnly: false,
                    }); */




                    updateMap[config.guid].push({
                        name: "isPortOutReversal",
                        value: false,
                        showInUi: false,
                        readOnly: false
                    });
                }
                updateMap[config.guid].push({
                    name: "DeviceShipping",
                    readOnly: true,
                    value: mobSubDeviceShipping
                });

            }
        }
    }

    if (updateMap) {
        let component = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (component && component != null && component != undefined) {
            let keys = Object.keys(updateMap);
            var complock = component.commercialLock;
            if (complock) component.lock("Commercial", false);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], false);
            }
            if (complock) component.lock("Commercial", true);
        }
    }
    return Promise.resolve(true);
}
//Modified by Aman Soni for 164619 || End

/***********************************************************************************************
* Author                : Aman Soni
* Sprint                  : 20.13(EDGE-164619)
* Method Name : EM_handlePortOutReversalOnAttUpd
* Invoked When: On Att update
* Description : Handling Port out reversal scenarios
* parameters  : guid
***********************************************************************************************/
async function EM_handlePortOutReversalOnAttUpd(guid) {
    var updateMap = {};
    var isPortOutRevPermissions = false;
    let solution = await CS.SM.getActiveSolution();
    if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility) && solution.components && Object.values(solution.components).length > 0) {
        let comp = await solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let config = await comp.getConfiguration(guid);
            if (config.guid === guid && !config.disabled) {
                let isPortOutRev = config.getAttribute("isPortOutReversal");

                //var existingSIMEM = config.getAttribute("UseExitingSIM");



                updateMap[config.guid] = [];

                if (!config.replacedConfigId && isPortOutRev.value === true) {

                    /* updateMap[config.guid].push({
                        name: "UseExitingSIM",
                        value: false,
                        showInUi: true,
                        readOnly: false,
                    }); */
                } else if (!config.replacedConfigId && isPortOutRev.value === false) {
                    /* updateMap[config.guid].push({
                        name: "UseExitingSIM",
                        value: false,
                        showInUi: false,
                        readOnly: false,


                    }); */



                }

            }
            let keys = Object.keys(updateMap);
            for (let i = 0; i < keys.length; i++) {
                await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
            }
        }
    }
}

async function resetDeliveryDetailsinOESchemaForIndvConf(guid) {
    let updateMap = {}; //EDGE-147799
    let product = activeEMSolution;
    if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
        let comp = await product.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
        if (comp) {
            let config = await comp.getConfiguration(guid);
            if (!updateMap[config.guid])
                //EDGE-147799
                updateMap[config.guid] = []; //EDGE-147799
            if (!config.disabled) {
                let shippingRequired = config.getAttribute("shippingRequired");
                let deviceShipping = config.getAttribute("DeviceShipping");
                let shippingRequiredVal = shippingRequired.value;
                let deviceShippingVal = deviceShipping.value;

                //EDGE-147799 - Bulk OE implementation changes - laxmi
                if (basketStage === "Commercial Configuration" || basketStage === "Draft") {
                    if (shippingRequiredVal === "TRUE" || deviceShippingVal === "TRUE") {
                        console.log("Either flag is true - Delivery is needed");
                        updateMap[config.guid].push(
                            {
                                name: "isDeliveryEnrichmentNeededAtt",
                                value: true
                            },
                            {
                                name: "isDeliveryDetailsRequired",
                                value: true
                            }
                        );
                        needsUpdate = true;
                    } else {
                        console.log("Flags are false - Delivery is NOT needeed");
                        updateMap[config.guid].push(
                            {
                                name: "isDeliveryDetailsRequired",
                                value: false
                            },
                            {
                                name: "isDeliveryEnrichmentNeededAtt",
                                value: false
                            }
                        );
                        //EDGE-147597 added by ankit || End
                        needsUpdate = true;
                    }
                } //End contract Accepted check
                // //EDGE-147799 Changes END
                let updateMapNew = {};
                if (config.orderEnrichmentList) {
                    config.orderEnrichmentList.forEach((oe) => {
                        if (!updateMapNew[oe.guid]) updateMapNew[oe.guid] = [];
                        if (shippingRequiredVal === "FALSE" && deviceShippingVal === "FALSE") {
                            console.log("Both Attribute Values are FALSE, made OE DeliveryDetails Optional");
                            updateMapNew[oe.guid].push({ name: "DeliveryContact", required: false }, { name: "DeliveryAddress", required: false });
                        } else console.log("DeliveryAddress OE Isnt Optional");
                    });
                }
                if (updateMapNew) {
                    let keys = Object.keys(updateMapNew);
                    for (let h = 0; h < keys.length; h++) {
                        await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMapNew[keys[h]], true);
                    }
                }
                if (updateMap) {
                    let keys = Object.keys(updateMap);
                    for (let h = 0; h < keys.length; h++) {
                        await comp.updateOrderEnrichmentConfigurationAttribute(config.guid, keys[h], updateMap[keys[h]], true);
                    }
                }
            }
        }
    }
    return Promise.resolve(true);
}
/***********************************************************************************************
 * Author	   : Akanksha Jain
 * EDGE number : EDGE-174218
 * Method Name : EMPlugin_setCMPTabsVisibility()
 * Invoked When: On solution load, after save and iframe close
 * Description : Control Visibility of OE tabs
 ***********************************************************************************************/
async function EMPlugin_setCMPTabsVisibility() {
	console.log ( '**************EMPlugin_setCMPTabsVisibility'); 
	var changeTypeAttributeVal = '';
	let solution = await CS.SM.getActiveSolution();
	let updateConfigMapOE = {};
	let updateConfigMapConfig = {};
	let updateOEMapPOR = {};
	let mobSubDeviceShipping;	
	let SimAvailabilityTypeVal='';
	if (solution.name.includes(ENTERPRISE_COMPONENTS.enterpriseMobility)) {
		if (solution.components && Object.values(solution.components).length > 0) {
			Object.values(solution.components).forEach(async (comp) => 
			{
					// for new SIM starts
					if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription  || comp.name === ENTERPRISE_COMPONENTS.device) { 
					let oeToShow = [];
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
						if (!oeSchema.name.toLowerCase().includes('number')) {
							oeToShow.push(oeSchema.name);
						}
					});
						
					let oeToShowMac = [];
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
					if (!oeSchema.name.toLowerCase().includes('number') && !oeSchema.name.toLowerCase().includes('feature') && !oeSchema.name.toLowerCase().includes('delivery') ) 
					{
						oeToShowMac.push(oeSchema.name);
					}
					});	
					
					// for ExistingSIM starts
					let oeToShowExistingNum = [];
					Object.values(comp.orderEnrichments).forEach((oeSchema) => {
					if (!oeSchema.name.toLowerCase().includes('number') && !oeSchema.name.toLowerCase().includes('delivery') ) {
						oeToShowExistingNum.push(oeSchema.name);
					}
					});							
					
					// for existingSIM MAC
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) 
					{
						Object.values(comp.schema.configurations).forEach(async (config) => 
						{	
							let updateOEMapPOR = {};
							if (config.disabled === false) 
							{
								mobSubDeviceShipping ="FALSE";
								if (config.attributes) {
									var changeTypeAttribute = Object.values(config.attributes).filter(obj => {
										return obj.name === 'ChangeType'
									});
										var SimAvailabilityType = Object.values(config.attributes).filter(obj => {
										return obj.name === 'SimAvailabilityType'
									});							
									
								}
								changeTypeAttributeVal = '';
								if (changeTypeAttribute.length > 0 && changeTypeAttribute[0].value && changeTypeAttribute[0].value != null) {
									changeTypeAttributeVal = changeTypeAttribute[0].value;
								}
								SimAvailabilityTypeVal='';
								if (SimAvailabilityType.length > 0  && SimAvailabilityType[0].value != null)
								{
									SimAvailabilityTypeVal = SimAvailabilityType[0].value;
									
								}
								// get device shipping
								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
											deviceAttribute = CommonUtills.getAttribute(relatedConfig.configuration, "DeviceShipping");
											if (deviceAttribute && deviceAttribute.value === "TRUE") {
												 mobSubDeviceShipping = "TRUE";
											}
										}
									});
								}
								console.log ( 'SimAvailabilityTypeVal -------------', SimAvailabilityTypeVal )
								console.log ( 'mobSubDeviceShipping ------------',mobSubDeviceShipping)
								if ((changeTypeAttributeVal === 'Modify' || changeTypeAttributeVal === 'Active') && mobSubDeviceShipping === "FALSE")
								{  
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShowMac);										
								} 
								else if (changeTypeAttributeVal ==='Cancel')
								{
									CS.SM.setOEtabsToLoad(comp.name, config.guid, []);
								 
								} 
								else if((config.replacedConfigId === "" || config.replacedConfigId === undefined )&& comp.name === "Mobile Subscription" &&  mobSubDeviceShipping === "FALSE" && SimAvailabilityTypeVal!== '' && ! ((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))) 
								{
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShowExistingNum);
									console.log ( 'New connect and  Existing SIM - Hiding Deivery Tab' ); 										
								}
								else
								{
									CS.SM.setOEtabsToLoad(comp.name, config.guid, oeToShow);
									console.log ( 'New Connect and New SIM Tab!!!!!!!!!!' ); 
									
								}
								updateConfigMapOE = {}; 
								updateConfigMapConfig = {}; 
								if (config.orderEnrichmentList && config.disabled == false )
								{
									// EDGE-212827
								//	for (var m = 0; m < Object.values(config.orderEnrichmentList).length; m++) {
								    //	var oeAtt = Object.values(config.orderEnrichmentList)[m];
									Object.values(config.orderEnrichmentList).forEach(async (oeAtt) => {
										var oeNameVal = '';
										var oeName = Object.values(oeAtt.attributes).filter(att => {
											return att.name === 'OENAME'
										});
										if (oeName.length > 0 && oeName[0].value && oeName[0].value != null) {
											oeNameVal = oeName[0].value;
										}
										if (oeNameVal === 'DD' )
										{	
                        //                  let updateMapNew = {};                						   // EDGE-212827   updateMapNew removed 
						//					if (!updateMapNew[oeAtt.guid]) updateMapNew[oeAtt.guid] = [];  // EDGE-212827   updateMapNew removed 
											if (!((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))  && SimAvailabilityTypeVal!='' && mobSubDeviceShipping === "FALSE" || ((changeTypeAttributeVal ==='Modify' || changeTypeAttributeVal ==='Active') && mobSubDeviceShipping === "FALSE")) 
											{
						//						updateMapNew[oeAtt.guid].push({name: "DeliveryContact", required: false },{name: "DeliveryAddress", required: false }); // EDGE-212827   updateMapNew removed 
												updateOEMapPOR[config.guid] = [];
												updateOEMapPOR[config.guid].push(
												{
													name: "isDeliveryEnrichmentNeededAtt",
													value: false
												});
												
												updateOEMapPOR[config.guid].push(
												{
													name: "isDeliveryDetailsRequired",
													value: false
												});
												console.log  ('DD Optional----------');
											}
											else 
											{
                            //                  updateMapNew[oeAtt.guid].push({name: 'DeliveryContact', required: true},{name: 'DeliveryAddress', required: true}); // EDGE-212827   updateMapNew removed 
												updateOEMapPOR[config.guid] = [];
												updateOEMapPOR[config.guid].push(
												{
													name: "isDeliveryEnrichmentNeededAtt",
													value: true
												});
												
												updateOEMapPOR[config.guid].push(
												{
													name: "isDeliveryDetailsRequired",
													value: true
												});
                                                console.log('DD Required---------');
											}
											
											var commerciallock = comp.commercialLock;
											if(commerciallock) 
												await comp.lock("Commercial", false);
											//EDGE-212827   updateMapNew removed 
							//				let keys = Object.keys(updateMapNew);
							/*				for(let h=0; h< keys.length;h++)
											{
												await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
											}
                            */
											let keys1 = Object.keys(updateOEMapPOR);
							//				for(let h=0; h< keys1.length;h++)
							//				{
											await comp.updateConfigurationAttribute(keys1[0], updateOEMapPOR[keys1[0]], true); 

							//				}
											if(commerciallock) comp.lock('Commercial', true);
											await config.validate();
										}
									
									})
								}
								//  EDGE-212827 : start
                                if (!((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))  && SimAvailabilityTypeVal!='' && mobSubDeviceShipping === "FALSE" || ((changeTypeAttributeVal ==='Modify' || changeTypeAttributeVal ==='Active') && mobSubDeviceShipping === "FALSE")) 
								{
                                    await NextGenMobHelper.deleteDeliveryDetails(ENTERPRISE_COMPONENTS.enterpriseMobility, ENTERPRISE_COMPONENTS.mobileSubscription,config.guid)// To Delete Delivery Details tab for Existing sim : EDGE-212827
                                }
                                else
                                {
                                    await NextGenMobHelper.addDeliveryDetails(ENTERPRISE_COMPONENTS.enterpriseMobility, ENTERPRISE_COMPONENTS.mobileSubscription,config.guid);// To Add Delivery Details tab : EDGE-212827
                                }
								// EDGE-212827 : end
								console.log ('updateConfigMapConfig ---',updateConfigMapConfig);	
								console.log ('updateOEMapPOR ---',updateOEMapPOR);									
							}//config disabled
							await config.validate();
						});//for each config
					}
				}
			});
		}
	}	
}
//INC000094141578 Fix starts
	CalculateIDDMessageBank = async function (config, msComponent, PlanTypeSelected,inputMap){
		   var addOnIDDCount = 0;
			var addOnMsgBankCount = 0;
			if (PlanTypeSelected !== "Data") {
				await currentEMBasket.performRemoteAction("MobileSubscriptionGetAddOnData", inputMap).then(async (response) => {
					if (response && response["addOnIDD"] != undefined) {
						console.log("response[addOnIDD] " + response["addOnIDD"]);
						addOnIDDCount = response["addOnIDD"].length;
					}
					if (response && response["addOnMsgBank"] != undefined) {
						console.log("response[addOnMsgBank] " + response["addOnMsgBank"]);
						addOnMsgBankCount = response["addOnMsgBank"].length;
					}
					if (addOnIDDCount === 1 && response["addOnIDD"][0].cspmb__Recurring_Charge__c === 0) {
						// Hitesh EDGE-146184
						let updateConfigMap2 = {};
						console.log("addOn Idd " + response["addOnIDD"][0].Id);
						updateConfigMap2[config.guid] = [];
						updateConfigMap2[config.guid].push(
							{
								name: "InternationalDirectDial",
								value: response["addOnIDD"][0].Id,
								displayValue: response["addOnIDD"][0].AddOn_Name__c,
								readOnly: true
							},
							{
								name: "SelectIDD",
								value: response["addOnIDD"][0].AddOn_Name__c,
								displayValue: response["addOnIDD"][0].AddOn_Name__c
							}, // added for EDGE-162025
							{
								name: "IDD Charge",
								value: Number(response["addOnIDD"][0].cspmb__Recurring_Charge__c).toFixed(2),
								displayValue: Number(response["addOnIDD"][0].cspmb__Recurring_Charge__c).toFixed(2)
							},
							{
								name: "BussinessId_Addon",
								value: response["addOnIDD"][0].cspmb__Add_On_Price_Item__r.Charge_Id__c,
								displayValue: response["addOnIDD"][0].cspmb__Add_On_Price_Item__r.Charge_Id__c
							},
							{
								name: "IDDReadOnlyFlag",
								value: true,
								displayValue: true
							}
							
						);

						if (updateConfigMap2[config.guid].length > 0) {
							let keys = Object.keys(updateConfigMap2);
							for (let i = 0; i < keys.length; i++) {
								await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
							}
						}
					}
					if (addOnIDDCount === 0) {
						// Hitesh EDGE-146184
						let updateConfigMap2 = {};
						console.log("addOn Idd " + response["addOnIDD"][0].Id);
						updateConfigMap2[config.guid] = [];
						updateConfigMap2[config.guid].push({
							name: "IDDReadOnlyFlag",
							value: true,
							displayValue: true
						});
						if (updateConfigMap2[config.guid].length > 0) {
							let keys = Object.keys(updateConfigMap2);
							for (let i = 0; i < keys.length; i++) {
								await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false);
							}
						}
					}
					if (addOnMsgBankCount) {
						let updateConfigMap2 = {};
						console.log("addOn MsgBank " + response["addOnMsgBank"][0].Id);
						updateConfigMap2[config.guid] = [];
						updateConfigMap2[config.guid].push(
							{
								name: "MessageBank",
								value: response["addOnMsgBank"][0].Id,
								displayValue: response["addOnMsgBank"][0].cspmb__Add_On_Price_Item__r.Message_Bank__c,
								readOnly:true
							},
							{
								name: "MessageBank RC",
								value: Number(response["addOnMsgBank"][0].cspmb__Recurring_Charge__c).toFixed(2),
								displayValue: Number(response["addOnMsgBank"][0].cspmb__Recurring_Charge__c).toFixed(2)
							}
						);
						if (updateConfigMap2[config.guid].length > 0) {
							let keys = Object.keys(updateConfigMap2);
							for (let i = 0; i < keys.length; i++) {
								await msComponent.updateConfigurationAttribute(keys[i], updateConfigMap2[keys[i]], false); // false added by shubhi 14/08
							}
						}
						let updateConfigMapNew = {};
						updateConfigMapNew[config.guid] = [];
						updateConfigMapNew[config.guid].push(
						{
							name: "MessageBank",
							readOnly:false
						},
						);
						if (updateConfigMapNew[config.guid].length > 0) {
							let keys = Object.keys(updateConfigMapNew);
							for (let i = 0; i < keys.length; i++) {
								await msComponent.updateConfigurationAttribute(keys[i], updateConfigMapNew[keys[i]], false); // false added by shubhi 14/08
							}
						}
					}
					
				});
			}
		return Promise.resolve(true);
	}
//INC000094141578 Fix Ends

/*********************************************************************************************
 * Author	   : Pooja Bhat
 * Method Name : calcDeviceRedeemFundGST
 * Invoked When: afterAttributeUpdated
 * Sprint	   : 20.16 (EDGE-190802)
 * Parameters  : guid, newValue, componentName
**********************************************************************************************/
calcDeviceRedeemFundGST = async function (guid, newValue, componentName) {
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
    }
    return Promise.resolve(true);
};  
